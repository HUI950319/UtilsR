# =============================================================================
# check_system.R -- System resource and environment diagnostics
# =============================================================================
#
# Architecture (3 layers):
#   L1 check_system()            collect, print and return diagnostics
#   L2   .valid_memory()        validate scalar memory values and bounds
#        .valid_text()          validate optional Windows metadata
#        .get_system_memory()   native ps, CIM/WMIC or Linux memory data
#   L3     get_mem_value()      parse exact /proc/meminfo fields
#   L2   .get_system_info()     collect platform labels and CPU details
#        pr_head/section/kv()   write the report to stdout
#   Selection: Windows -> ps + static CIM cache, then CIM/WMIC fallback;
#              Linux -> /proc/meminfo; macOS -> ps available memory.
#

# Cache only static Windows metadata within the current R session.
.check_system_cache <- new.env(parent = emptyenv())

#' Check System Resources and Environment
#'
#' Display system information including OS, R version, memory usage, and CPU
#' details with colored console output.
#' Windows uses the optional \code{ps} package for live memory queries and
#' caches static OS and CPU details obtained with PowerShell CIM. CIM and
#' legacy WMIC remain fallbacks when native memory queries are unavailable.
#' Linux physical core counts use the optional \code{ps} package and are
#' reported as missing when it is unavailable.
#' On macOS, system memory is obtained through the optional \code{ps} package.
#'
#' @param return_result Logical. If \code{TRUE}, return the result list
#'   visibly. Default \code{FALSE}.
#' @param show_warnings Logical. If \code{TRUE}, display memory warnings.
#'   Default \code{FALSE}.
#'
#' @return A list (invisible by default) containing system_info, r_environment,
#'   r_memory, system_memory, cpu, warnings, and timestamp.
#'
#' @details R memory measures the heap managed by R, not the operating system's
#'   resident process size (RSS). It uses \code{lobstr} when available, otherwise
#'   exact \code{gc()} cell counts. Memory fields ending in \code{_gb} retain
#'   their names and report gibibytes (GiB, \eqn{2^{30}} bytes).
#'   System \code{free_gb} represents available memory; \code{used_gb} is the
#'   difference between total and available memory. Unavailable measurements
#'   are returned as missing values.
#'
#' @examples
#' \dontrun{
#' check_system()
#' res <- check_system(return_result = TRUE)
#' }
#'
#' @export
#' @family inspect
check_system <- function(return_result = FALSE, show_warnings = FALSE) {

  # Get R memory usage
  r_mem_used_bytes <- if (requireNamespace("lobstr", quietly = TRUE)) {
    lobstr::mem_used()
  } else {
    gc_info <- gc()
    node_size <- if (.Machine[["sizeof.pointer"]] == 8L) 56 else 28
    sum(gc_info[, 1L] * c(node_size, 8))
  }
  r_mem_used_gb <- as.numeric(r_mem_used_bytes) / 1024^3

  .valid_memory <- function(memory) {
    values <- unlist(memory, use.names = FALSE)
    all(lengths(memory) == 1L) && is.numeric(values) &&
      all(is.finite(values)) && memory[["total_gb"]] > 0 &&
      memory[["free_gb"]] >= 0 && memory[["free_gb"]] <= memory[["total_gb"]]
  }
  .valid_text <- function(value) {
    length(value) == 1L && !is.na(value) && nzchar(trimws(value))
  }

  native_memory <- NULL
  if ((.Platform[["OS.type"]] == "windows" || Sys.info()[["sysname"]] == "Darwin") &&
      requireNamespace("ps", quietly = TRUE)) {
    native_memory <- tryCatch({
      memory <- ps::ps_system_memory()
      total_gb <- as.numeric(memory[["total"]]) / 1024^3
      available_gb <- as.numeric(memory[["avail"]]) / 1024^3
      memory <- list(total_gb = total_gb, free_gb = available_gb,
                     used_gb = total_gb - available_gb,
                     usage_pct = (total_gb - available_gb) / total_gb * 100)
      if (.valid_memory(memory)) memory else NULL
    }, error = function(e) NULL)
  }

  # Query Windows once for both memory and system details.
  windows_info <- NULL
  if (.Platform[["OS.type"]] == "windows" && !is.null(native_memory) &&
      !is.null(.check_system_cache[["windows_info"]])) {
    windows_info <- .check_system_cache[["windows_info"]]
  } else if (.Platform$OS.type == "windows" && nzchar(Sys.which("powershell"))) {
    windows_info <- tryCatch({
      command <- paste(
        "$ErrorActionPreference = 'Stop';",
        "[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false);",
        "$os = Get-CimInstance Win32_OperatingSystem;",
        "try { $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1 }",
        "catch { $cpu = $null };",
        "[pscustomobject]@{TotalVisibleMemorySize=$os.TotalVisibleMemorySize;",
        "FreePhysicalMemory=$os.FreePhysicalMemory; Caption=$os.Caption;",
        "Version=$os.Version; CpuName=$cpu.Name} | ConvertTo-Csv -NoTypeInformation"
      )
      lines <- suppressWarnings(system2(
        Sys.which("powershell"),
        c("-NoLogo", "-NoProfile", "-NonInteractive", "-Command", shQuote(command)),
        stdout = TRUE, stderr = TRUE
      ))
      if (!is.null(attr(lines, "status")) && attr(lines, "status") != 0L)
        stop("Windows CIM query failed.")
      info <- utils::read.csv(text = paste(lines, collapse = "\n"),
                              colClasses = "character", encoding = "UTF-8")
      fields <- c("TotalVisibleMemorySize", "FreePhysicalMemory", "Caption",
                  "Version", "CpuName")
      if (nrow(info) != 1L || !all(fields[1:2] %in% names(info)))
        stop("Incomplete Windows CIM result.")
      for (field in setdiff(fields, names(info))) info[[field]] <- NA_character_
      memory <- suppressWarnings(as.numeric(info[1L, fields[1:2]]))
      if (any(!is.finite(memory)) || memory[1L] <= 0 ||
          memory[2L] < 0 || memory[2L] > memory[1L])
        stop("Invalid Windows CIM memory result.")
      info
    }, error = function(e) NULL)
  }
  if (.Platform[["OS.type"]] == "windows" && !is.null(windows_info) &&
      all(vapply(windows_info[c("Caption", "Version", "CpuName")], .valid_text, logical(1)))) {
    .check_system_cache[["windows_info"]] <- windows_info[c("Caption", "Version", "CpuName")]
  }

  # Internal: get system memory info
  memory_error <- NULL
  .get_system_memory <- function() {
    tryCatch({
      if (!is.null(native_memory)) return(native_memory)
      if (.Platform$OS.type == "windows") {
        if (!is.null(windows_info)) {
          total_mem_kb <- as.numeric(windows_info[["TotalVisibleMemorySize"]])
          free_mem_kb <- as.numeric(windows_info[["FreePhysicalMemory"]])
        } else {
          total_cmd <- "wmic OS get TotalVisibleMemorySize /Value"
          free_cmd <- "wmic OS get FreePhysicalMemory /Value"

          total_info <- system(total_cmd, intern = TRUE)
          free_info <- system(free_cmd, intern = TRUE)

          total_line <- total_info[grep("TotalVisibleMemorySize", total_info)]
          free_line <- free_info[grep("FreePhysicalMemory", free_info)]

          total_mem_kb <- as.numeric(gsub("TotalVisibleMemorySize=", "", total_line))
          free_mem_kb <- as.numeric(gsub("FreePhysicalMemory=", "", free_line))
        }

        list(
          total_gb = total_mem_kb / 1024^2,
          free_gb = free_mem_kb / 1024^2,
          used_gb = (total_mem_kb - free_mem_kb) / 1024^2,
          usage_pct = ((total_mem_kb - free_mem_kb) / total_mem_kb) * 100
        )
      } else if (Sys.info()[["sysname"]] == "Darwin") {
        stop("macOS memory is unavailable; check the optional 'ps' package.")
      } else {
        if (file.exists("/proc/meminfo")) {
          meminfo <- readLines("/proc/meminfo")
          get_mem_value <- function(pat) {
            line <- grep(paste0("^", pat), meminfo, value = TRUE)
            if (length(line) == 1L) {
              value <- trimws(sub("^[^:]+:", "", line))
              suppressWarnings(as.numeric(sub("\\s.*$", "", value))) / 1024^2
            } else {
              NA
            }
          }

          total_gb <- get_mem_value("MemTotal:")
          available_gb <- get_mem_value("MemAvailable:")
          if (is.na(available_gb)) {
            free_gb <- get_mem_value("MemFree:")
            cached_gb <- get_mem_value("Cached:")
            if (is.na(cached_gb)) cached_gb <- 0
            available_gb <- free_gb + cached_gb
          }

          list(
            total_gb = total_gb,
            free_gb = available_gb,
            used_gb = total_gb - available_gb,
            usage_pct = ((total_gb - available_gb) / total_gb) * 100
          )
        } else {
          mem_info <- system("free -b | grep Mem", intern = TRUE)
          if (length(mem_info) > 0) {
            mem_split <- strsplit(trimws(mem_info), "\\s+")[[1]]
            total_gb <- as.numeric(mem_split[2]) / 1024^3
            available_gb <- as.numeric(mem_split[7]) / 1024^3

            list(
              total_gb = total_gb,
              free_gb = available_gb,
              used_gb = total_gb - available_gb,
              usage_pct = ((total_gb - available_gb) / total_gb) * 100
            )
          } else {
            stop("\u65e0\u6cd5\u83b7\u53d6\u5185\u5b58\u4fe1\u606f")
          }
        }
      }
    }, error = function(e) {
      memory_error <<- conditionMessage(e)
      list(total_gb = NA, free_gb = NA, used_gb = NA, usage_pct = NA)
    })
  }

  sys_mem <- .get_system_memory()
  if (!.valid_memory(sys_mem)) {
    if (show_warnings) {
      warning(if (is.null(memory_error)) "Unavailable or invalid system memory query result."
              else paste0("\u65e0\u6cd5\u83b7\u53d6\u7cfb\u7edf\u5185\u5b58\u4fe1\u606f: ",
                          memory_error), call. = FALSE)
    }
    sys_mem <- list(total_gb = NA_real_, free_gb = NA_real_,
                    used_gb = NA_real_, usage_pct = NA_real_)
  }

  cores_logical <- parallel::detectCores(logical = TRUE)
  cores_physical <- if (.Platform[["OS.type"]] != "windows" &&
                         Sys.info()[["sysname"]] == "Linux") {
    if (requireNamespace("ps", quietly = TRUE)) {
      tryCatch(ps::ps_cpu_count(logical = FALSE), error = function(e) NA_integer_)
    } else NA_integer_
  } else parallel::detectCores(logical = FALSE)

  # Internal: get system info
  .get_system_info <- function() {
    tryCatch({
      os_type <- .Platform$OS.type
      os_name <- Sys.info()[["sysname"]]
      os_release <- Sys.info()[["release"]]
      os_version <- Sys.info()[["version"]]
      machine <- Sys.info()[["machine"]]

      if (os_type == "windows") {
        sys_info <- if (!is.null(windows_info)) {
          list(
            os_full_name = trimws(windows_info[["Caption"]]),
            os_version = trimws(windows_info[["Version"]]),
            cpu_name = trimws(windows_info[["CpuName"]])
          )
        } else list(os_full_name = NA_character_, os_version = NA_character_,
                    cpu_name = NA_character_)
        if (!.valid_text(sys_info[["os_full_name"]]) ||
            !.valid_text(sys_info[["os_version"]])) {
          ver_info <- tryCatch(system("wmic os get Caption,Version /format:list",
                                      intern = TRUE),
                               error = function(e) character())
          for (field in c(os_full_name = "Caption", os_version = "Version")) {
            target <- if (field == "Caption") "os_full_name" else "os_version"
            if (!.valid_text(sys_info[[target]])) {
              line <- grep(paste0("^", field, "="), ver_info, value = TRUE)
              if (length(line) == 1L)
                sys_info[[target]] <- trimws(sub("^[^=]+=", "", line))
            }
          }
        }
        if (!.valid_text(sys_info[["cpu_name"]])) {
          cpu_info <- tryCatch(system("wmic cpu get Name /format:list", intern = TRUE),
                               error = function(e) character())
          cpu_line <- grep("^Name=", cpu_info, value = TRUE)
          if (length(cpu_line) == 1L)
            sys_info[["cpu_name"]] <- trimws(sub("^Name=", "", cpu_line))
        }
        if (!.valid_text(sys_info[["os_full_name"]]))
          sys_info[["os_full_name"]] <- paste("Windows", os_release)
        if (!.valid_text(sys_info[["os_version"]])) sys_info[["os_version"]] <- os_version
        if (!.valid_text(sys_info[["cpu_name"]])) sys_info[["cpu_name"]] <- "Unknown"

      } else {
        sys_info <- tryCatch({
          if (os_name == "Linux") {
            distro <- "Unknown Linux"
            if (file.exists("/etc/os-release")) {
              os_release_info <- readLines("/etc/os-release")
              pretty_name_line <- grep("PRETTY_NAME=",
                                       os_release_info, value = TRUE)
              if (length(pretty_name_line) > 0) {
                distro <- gsub("PRETTY_NAME=|\"", "", pretty_name_line[1])
              }
            } else if (file.exists("/etc/redhat-release")) {
              distro <- readLines("/etc/redhat-release")[1]
            } else if (file.exists("/etc/debian_version")) {
              debian_ver <- readLines("/etc/debian_version")[1]
              distro <- paste("Debian", debian_ver)
            }

            cpu_name <- "Unknown"
            if (file.exists("/proc/cpuinfo")) {
              cpuinfo <- readLines("/proc/cpuinfo")
              model_line <- grep("model name", cpuinfo, value = TRUE)[1]
              if (!is.na(model_line)) {
                cpu_name <- trimws(gsub("model name\\s*:\\s*", "",
                                        model_line))
              }
            }

            list(
              os_full_name = distro,
              os_version = os_release,
              cpu_name = cpu_name
            )

          } else if (os_name == "Darwin") {
            mac_version <- tryCatch(
              system("sw_vers -productVersion", intern = TRUE),
              error = function(e) os_release
            )
            mac_name <- tryCatch(
              system("sw_vers -productName", intern = TRUE),
              error = function(e) "macOS"
            )
            cpu_name <- tryCatch(
              system("sysctl -n machdep.cpu.brand_string", intern = TRUE),
              error = function(e) "Unknown"
            )

            list(
              os_full_name = paste(mac_name, mac_version),
              os_version = mac_version,
              cpu_name = cpu_name
            )

          } else {
            list(
              os_full_name = paste(os_name, os_release),
              os_version = os_version,
              cpu_name = "Unknown"
            )
          }
        }, error = function(e) {
          list(
            os_full_name = paste(os_name, os_release),
            os_version = os_version,
            cpu_name = "Unknown"
          )
        })
      }

      r_version <- paste(R.version$major, R.version$minor, sep = ".")
      r_platform <- R.version$platform

      list(
        os_type = os_type,
        os_name = os_name,
        os_full_name = sys_info$os_full_name,
        os_version = sys_info$os_version,
        architecture = machine,
        cpu_name = sys_info$cpu_name,
        r_version = r_version,
        r_platform = r_platform
      )

    }, error = function(e) {
      list(
        os_type = .Platform$OS.type,
        os_name = Sys.info()[["sysname"]],
        os_full_name = "Unknown",
        os_version = "Unknown",
        architecture = Sys.info()[["machine"]],
        cpu_name = "Unknown",
        r_version = paste(R.version$major, R.version$minor, sep = "."),
        r_platform = R.version$platform
      )
    })
  }

  sys_info <- .get_system_info()

  memory_warnings <- character(0)
  if (!is.na(sys_mem$usage_pct)) {
    if (sys_mem$usage_pct > 90) {
      memory_warnings <- c(memory_warnings,
                           "\u7cfb\u7edf\u5185\u5b58\u4f7f\u7528\u7387\u8fc7\u9ad8 (>90%)")
    }
    if (sys_mem$free_gb < 1) {
      memory_warnings <- c(memory_warnings,
                            "\u53ef\u7528\u5185\u5b58\u4e0d\u8db3 (<1GiB)")
    }
  }

  if (r_mem_used_gb > 4) {
    memory_warnings <- c(memory_warnings,
                         "R\u5bf9\u8c61\u5185\u5b58\u4f7f\u7528\u8f83\u9ad8 (>4GiB)")
  }

  # Pretty output, written to stdout through the print helpers; the keys
  # are Chinese, which pr_kv() aligns by display width
  pr_head("check_system", "\U0001f5a5\ufe0f \u7cfb\u7edf\u8d44\u6e90\u4fe1\u606f",
          format(Sys.time(), "%Y-%m-%d %H:%M"))

  pr_section("\U0001f310 \u64cd\u4f5c\u7cfb\u7edf")
  pr_kv(list(
    "\u7cfb\u7edf" = sys_info$os_full_name,
    "\u67b6\u6784" = sys_info$architecture,
    "\u7c7b\u578b" = if (sys_info$os_type == "windows") "Windows"
               else paste(sys_info$os_name, "(Unix-like)")
  ))

  pr_section("\U0001f4c8 R\u73af\u5883")
  pr_kv(list("R\u7248\u672c" = sys_info$r_version,
             "\u5e73\u53f0" = sys_info$r_platform))

  pr_section("\U0001f4ca R\u5185\u5b58\u4f7f\u7528")
  pr_kv(list("\u5f53\u524d\u4f7f\u7528" = sprintf("%.2f GiB", r_mem_used_gb)))

  pr_section("\U0001f4be \u7cfb\u7edf\u5185\u5b58")
  if (!is.na(sys_mem$total_gb)) {
    if (sys_mem$usage_pct < 70) {
      status_color <- cli::col_green("\u826f\u597d")
    } else if (sys_mem$usage_pct < 85) {
      status_color <- cli::col_yellow("\u6ce8\u610f")
    } else {
      status_color <- cli::col_red("\u8b66\u544a")
    }
    pr_kv(list(
      "\u603b\u5185\u5b58" = sprintf("%.2f GiB", sys_mem$total_gb),
      "\u5df2\u4f7f\u7528" = sprintf("%.2f GiB (%.1f%%)", sys_mem$used_gb,
                                 sys_mem$usage_pct),
      "\u53ef\u7528"     = sprintf("%.2f GiB", sys_mem$free_gb),
      "\u72b6\u6001"     = status_color
    ))
  } else {
    pr_kv(list("\u72b6\u6001" =
                 cli::col_red("\u65e0\u6cd5\u83b7\u53d6\u7cfb\u7edf\u5185\u5b58\u4fe1\u606f")))
  }

  pr_section("\U0001f527 \u5904\u7406\u5668")
  pr_kv(list(
    CPU = sys_info$cpu_name,
    "\u903b\u8f91\u6838\u5fc3" = cores_logical,
    "\u7269\u7406\u6838\u5fc3" = if (!is.na(cores_physical) &&
      (is.na(cores_logical) || cores_physical != cores_logical))
      cores_physical
  ))

  if (length(memory_warnings) > 0 && show_warnings) {
    pr_section("\u26a0\ufe0f \u8b66\u544a")
    ._pr_out(paste0("  ", cli::col_yellow(cli::symbol$warning), " ", memory_warnings))
  }

  result <- list(
    system_info = list(
      os_type = sys_info$os_type,
      os_name = sys_info$os_name,
      os_full_name = sys_info$os_full_name,
      os_version = sys_info$os_version,
      architecture = sys_info$architecture,
      is_windows = sys_info$os_type == "windows",
      is_linux = sys_info$os_name == "Linux",
      is_macos = sys_info$os_name == "Darwin"
    ),
    r_environment = list(
      version = sys_info$r_version,
      platform = sys_info$r_platform
    ),
    r_memory = list(
      used_bytes = as.numeric(r_mem_used_bytes),
      used_gb = r_mem_used_gb
    ),
    system_memory = list(
      total_gb = sys_mem$total_gb,
      used_gb = sys_mem$used_gb,
      free_gb = sys_mem$free_gb,
      usage_percent = sys_mem$usage_pct
    ),
    cpu = list(
      name = sys_info$cpu_name,
      logical_cores = cores_logical,
      physical_cores = cores_physical
    ),
    warnings = memory_warnings,
    timestamp = Sys.time()
  )

  if (return_result) {
    return(result)
  } else {
    invisible(result)
  }
}
