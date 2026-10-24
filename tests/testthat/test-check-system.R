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
  result <- suppressMessages(check_system(return_result = TRUE))
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
