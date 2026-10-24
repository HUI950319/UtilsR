.check_system_fixture <- function(os = "Linux", meminfo = character(),
                                  cim = NULL, legacy = list(), use_ps = FALSE) {
  env <- new.env(parent = environment(check_system))
  env$.Platform <- .Platform
  env$.Platform$OS.type <- if (os == "Windows") "windows" else "unix"
  env$Sys.info <- function() {
    info <- base::Sys.info()
    info[c("sysname", "release", "version", "machine")] <-
      c(os, "fixture", "fixture", "x86_64")
    info
  }
  env$requireNamespace <- function(package, ...) {
    if (package %in% c("pryr", "lobstr") || (package == "ps" && !use_ps))
      FALSE else base::requireNamespace(package, ...)
  }
  env$Sys.which <- function(...) if (is.null(cim)) "" else "powershell"
  env$system2 <- function(...) cim
  env$system <- function(command, ...) {
    if (command %in% names(legacy)) legacy[[command]] else character()
  }
  env$file.exists <- function(path) {
    os == "Linux" && path %in% c("/proc/meminfo", "/etc/os-release", "/proc/cpuinfo")
  }
  env$readLines <- function(con, ...) {
    switch(con, "/proc/meminfo" = meminfo,
           "/etc/os-release" = 'PRETTY_NAME="Linux fixture"',
           "/proc/cpuinfo" = "model name : Fixture CPU",
           stop("Unexpected fixture file"))
  }
  env$.check_system_cache <- new.env(parent = emptyenv())
  query <- check_system
  environment(query) <- env
  query
}

test_that("system diagnostics retain their result schema and visibility", {
  utils::capture.output(result <- withVisible(check_system(return_result = TRUE)))
  expect_true(result$visible)
  expect_named(result$value, c("system_info", "r_environment", "r_memory",
                               "system_memory", "cpu", "warnings", "timestamp"))
  expect_named(result$value$system_memory,
               c("total_gb", "used_gb", "free_gb", "usage_percent"))
  expect_named(result$value$cpu, c("name", "logical_cores", "physical_cores"))
  expect_s3_class(result$value$timestamp, "POSIXct")
  expect_gt(result$value$r_memory$used_bytes, 0)
  expect_type(result$value$warnings, "character")
  utils::capture.output(invisible_result <- withVisible(check_system()))
  expect_false(invisible_result$visible)
  expect_identical(names(invisible_result$value), names(result$value))
})

test_that("check_system prints its report with the print helpers", {
  out <- cli::ansi_strip(utils::capture.output(check_system()))
  expect_match(out[1], "^<check_system> ")
  rules <- out[grepl(cli::symbol$line, out, fixed = TRUE)]
  expect_gte(length(rules), 5L)
  expect_true(any(grepl("^  R\u7248\u672c +[0-9]", out)))
  expect_true(any(grepl("^  \u903b\u8f91\u6838\u5fc3 +[0-9]+$", out)))
})

test_that("Windows diagnostics obtain memory and CPU with PowerShell CIM", {
  skip_if(.Platform$OS.type != "windows", "Windows-specific CIM query")
  skip_if(!nzchar(Sys.which("powershell")), "PowerShell is not available")
  env <- new.env(parent = environment(check_system))
  env$requireNamespace <- function(package, ...) {
    if (package == "ps") FALSE else base::requireNamespace(package, ...)
  }
  env$.check_system_cache <- new.env(parent = emptyenv())
  query <- check_system
  environment(query) <- env
  utils::capture.output(result <- query(return_result = TRUE))
  memory <- unlist(result$system_memory, use.names = FALSE)
  expect_length(memory, 4L)
  expect_true(all(is.finite(memory)))
  expect_gt(result$system_memory$total_gb, 0)
  expect_gte(result$system_memory$free_gb, 0)
  expect_gte(result$system_memory$used_gb, 0)
  expect_gte(result$system_memory$usage_percent, 0)
  expect_lte(result$system_memory$usage_percent, 100)
  expect_equal(result$system_memory$total_gb,
                result$system_memory$free_gb + result$system_memory$used_gb)
  expect_true(nzchar(result$cpu$name))
  expect_false(identical(result$cpu$name, "Unknown"))
  expect_match(result$system_info$os_full_name, "Windows", ignore.case = TRUE)
})

test_that("failed or malformed CIM queries retain the legacy Windows fallback", {
  for (response in list(structure("CIM unavailable", status = 1L),
                       c('"Caption"', '"Windows"'),
                       c('"TotalVisibleMemorySize","FreePhysicalMemory","Caption","Version","CpuName"',
                         '"invalid","1024","Windows","10","CPU"'))) {
    query_count <- 0L
    legacy_queries <- character()
    env <- new.env(parent = environment(check_system))
    env$.Platform <- .Platform
    env$.Platform$OS.type <- "windows"
    env$Sys.which <- function(...) "powershell"
    env$requireNamespace <- function(package, ...) {
      if (package == "ps") FALSE else base::requireNamespace(package, ...)
    }
    env$.check_system_cache <- new.env(parent = emptyenv())
    env$system2 <- function(...) {
      query_count <<- query_count + 1L
      response
    }
    env$system <- function(command, ...) {
      legacy_queries <<- c(legacy_queries, command)
      switch(command,
        "wmic OS get TotalVisibleMemorySize /Value" = "TotalVisibleMemorySize=8388608",
        "wmic OS get FreePhysicalMemory /Value" = "FreePhysicalMemory=2097152",
        "wmic os get Caption,Version /format:list" = c("Caption=Windows fixture", "Version=10.0"),
        "wmic cpu get Name /format:list" = "Name=Fixture CPU",
        stop("Unexpected legacy query"))
    }
    query <- check_system
    environment(query) <- env
    expect_warning(result <- suppressMessages(query(return_result = TRUE)), NA)
    expect_identical(query_count, 1L)
    expect_length(legacy_queries, 4L)
    expect_identical(result$system_memory,
                     list(total_gb = 8, used_gb = 6, free_gb = 2, usage_percent = 75))
    expect_identical(result$system_info$os_full_name, "Windows fixture")
    expect_identical(result$cpu$name, "Fixture CPU")
  }
})

test_that("Linux cached memory does not include SwapCached", {
  query <- .check_system_fixture(meminfo = c(
    "MemTotal: 8388608 kB", "MemFree: 1048576 kB",
    "Cached: 2097152 kB", "SwapCached: 524288 kB"
  ))
  expect_no_error(utils::capture.output(result <- query(return_result = TRUE)))
  expect_identical(result$system_memory,
                   list(total_gb = 8, used_gb = 5, free_gb = 3, usage_percent = 62.5))
})

test_that("missing Windows memory query results do not abort diagnostics", {
  for (legacy in list(list(), list(
    "wmic OS get TotalVisibleMemorySize /Value" = "TotalVisibleMemorySize=8388608"
  ))) {
    query <- .check_system_fixture(os = "Windows", legacy = legacy)
    expect_no_error(utils::capture.output(result <- query(return_result = TRUE)))
    expect_true(all(is.na(unlist(result$system_memory))))
    expect_true(all(lengths(result$system_memory) == 1L))
    expect_identical(result$system_info$os_name, "Windows")
  }
})

test_that("invalid memory measurements cannot produce negative or undefined usage", {
  inputs <- list(
    c("MemTotal: 8388608 kB", "MemAvailable: 16777216 kB"),
    c("MemTotal: 0 kB", "MemAvailable: 0 kB"),
    c("MemTotal: 8388608 kB", "MemAvailable: unavailable"),
    c("MemTotal: 8388608 kB", "MemAvailable: -1048576 kB")
  )
  for (meminfo in inputs) {
    query <- .check_system_fixture(meminfo = meminfo)
    expect_no_error(utils::capture.output(result <- query(return_result = TRUE)))
    expect_true(all(is.na(unlist(result$system_memory))))
  }
  query <- .check_system_fixture(os = "Windows", legacy = list(
    "wmic OS get TotalVisibleMemorySize /Value" = "TotalVisibleMemorySize=8388608",
    "wmic OS get FreePhysicalMemory /Value" = "FreePhysicalMemory=16777216"
  ))
  utils::capture.output(result <- query(return_result = TRUE))
  expect_true(all(is.na(unlist(result$system_memory))))
})

test_that("Linux missing cached memory still provides a conservative fallback", {
  query <- .check_system_fixture(meminfo = c(
    "MemTotal: 8388608 kB", "MemFree: 1048576 kB"
  ))
  expect_no_error(utils::capture.output(result <- query(return_result = TRUE)))
  expect_identical(result$system_memory,
                   list(total_gb = 8, used_gb = 7, free_gb = 1, usage_percent = 87.5))
})

test_that("known physical cores still print when logical cores are unknown", {
  local_mocked_bindings(
    detectCores = function(all.tests = FALSE, logical = TRUE)
      if (logical) NA_integer_ else 2L,
    .package = "parallel"
  )
  query <- .check_system_fixture(os = "Windows")
  expect_no_error(utils::capture.output(result <- query(return_result = TRUE)))
  expect_true(is.na(result$cpu$logical_cores))
  expect_identical(result$cpu$physical_cores, 2L)
})

test_that("Linux physical cores are not reported as hardware threads", {
  skip_if_not_installed("ps")
  local_mocked_bindings(detectCores = function(...) 16L, .package = "parallel")
  local_mocked_bindings(
    ps_cpu_count = function(logical = TRUE) if (logical) 16L else 8L,
    .package = "ps"
  )
  query <- .check_system_fixture(use_ps = TRUE, meminfo = c(
    "MemTotal: 8388608 kB", "MemAvailable: 4194304 kB"
  ))
  utils::capture.output(result <- query(return_result = TRUE))
  expect_identical(result$cpu$logical_cores, 16L)
  expect_identical(result$cpu$physical_cores, 8L)

  query <- .check_system_fixture(meminfo = c(
    "MemTotal: 8388608 kB", "MemAvailable: 4194304 kB"
  ))
  utils::capture.output(result <- query(return_result = TRUE))
  expect_true(is.na(result$cpu$physical_cores))
})

test_that("CIM text fields fall back independently without losing valid memory", {
  legacy <- list(
    "wmic cpu get Name /format:list" = "Name=Legacy CPU",
    "wmic os get Caption,Version /format:list" =
      c("Caption=Legacy Windows", "Version=legacy-version")
  )
  for (cim in list(
    c('"TotalVisibleMemorySize","FreePhysicalMemory","Caption","Version","CpuName"',
      '"8388608","2097152","Windows fixture","10.0",""'),
    c('"TotalVisibleMemorySize","FreePhysicalMemory","Caption","Version"',
      '"8388608","2097152","Windows fixture","10.0"')
  )) {
    query <- .check_system_fixture(os = "Windows", cim = cim, legacy = legacy)
    utils::capture.output(result <- query(return_result = TRUE))
    expect_identical(result$cpu$name, "Legacy CPU")
    expect_identical(result$system_info$os_full_name, "Windows fixture")
    expect_identical(result$system_memory,
                     list(total_gb = 8, used_gb = 6, free_gb = 2, usage_percent = 75))
  }
  query <- .check_system_fixture(os = "Windows", legacy = legacy, cim = c(
    '"TotalVisibleMemorySize","FreePhysicalMemory","Caption","Version","CpuName"',
    '"8388608","2097152","","10.0","CIM CPU"'
  ))
  utils::capture.output(result <- query(return_result = TRUE))
  expect_identical(result$system_info$os_full_name, "Legacy Windows")
  expect_identical(result$system_info$os_version, "10.0")
  expect_identical(result$cpu$name, "CIM CPU")
})

test_that("macOS memory uses available bytes instead of Linux commands", {
  skip_if_not_installed("ps")
  local_mocked_bindings(
    ps_system_memory = function() list(total = 8 * 1024^3, avail = 3 * 1024^3,
                                     free = 1024^3, used = 4 * 1024^3),
    .package = "ps"
  )
  query <- .check_system_fixture(os = "Darwin", use_ps = TRUE)
  environment(query)$system <- function(command, ...) {
    if (grepl("free", command, fixed = TRUE)) stop("Linux memory command on macOS")
    switch(command, "sw_vers -productVersion" = "15.0",
           "sw_vers -productName" = "macOS",
           "sysctl -n machdep.cpu.brand_string" = "Apple fixture", character())
  }
  utils::capture.output(result <- query(return_result = TRUE))
  expect_identical(result$system_memory,
                   list(total_gb = 8, used_gb = 5, free_gb = 3, usage_percent = 62.5))
  expect_identical(result$cpu$name, "Apple fixture")
  expect_true(result$system_info$is_macos)
})

test_that("Windows metadata caching never caches live memory measurements", {
  skip_if_not_installed("ps")
  memory_queries <- 0L
  cim_queries <- 0L
  local_mocked_bindings(ps_system_memory = function() {
    memory_queries <<- memory_queries + 1L
    list(total = 8 * 1024^3, avail = if (memory_queries == 1L) 4 * 1024^3 else 2 * 1024^3)
  }, .package = "ps")
  cim <- c('"TotalVisibleMemorySize","FreePhysicalMemory","Caption","Version","CpuName"',
           '"8388608","4194304","Windows fixture","10.0","Fixture CPU"')
  query <- .check_system_fixture(os = "Windows", cim = cim, use_ps = TRUE)
  environment(query)$system2 <- function(...) {
    cim_queries <<- cim_queries + 1L
    cim
  }
  utils::capture.output(first <- query(return_result = TRUE))
  utils::capture.output(second <- query(return_result = TRUE))
  expect_identical(first$system_memory,
                   list(total_gb = 8, used_gb = 4, free_gb = 4, usage_percent = 50))
  expect_identical(second$system_memory,
                   list(total_gb = 8, used_gb = 6, free_gb = 2, usage_percent = 75))
  expect_identical(first$system_info, second$system_info)
  expect_identical(first$cpu, second$cpu)
  expect_identical(cim_queries, 1L)
})

test_that("failed native Windows memory queries retain fresh CIM fallback", {
  skip_if_not_installed("ps")
  local_mocked_bindings(ps_system_memory = function() stop("Native memory unavailable"),
                        .package = "ps")
  cim_queries <- 0L
  query <- .check_system_fixture(os = "Windows", cim = "available", use_ps = TRUE)
  environment(query)$system2 <- function(...) {
    cim_queries <<- cim_queries + 1L
    c('"TotalVisibleMemorySize","FreePhysicalMemory","Caption","Version","CpuName"',
      if (cim_queries == 1L) '"8388608","4194304","Windows fixture","10.0","Fixture CPU"'
      else '"8388608","2097152","Windows fixture","10.0","Fixture CPU"')
  }
  utils::capture.output(first <- query(return_result = TRUE))
  utils::capture.output(second <- query(return_result = TRUE))
  expect_identical(first$system_memory$free_gb, 4)
  expect_identical(second$system_memory$free_gb, 2)
})
