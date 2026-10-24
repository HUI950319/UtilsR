# =============================================================================
# check_system.R -- System resource and environment diagnostics
# =============================================================================

#' Check System Resources and Environment
#'
#' Display system information including OS, R version, memory usage, and CPU
#' details with colored console output.
#' Windows uses PowerShell CIM when available, with WMIC as a legacy fallback.
#'
#' @param return_result Logical. If \code{TRUE}, return the result list
#'   visibly. Default \code{FALSE}.
#' @param show_warnings Logical. If \code{TRUE}, display memory warnings.
#'   Default \code{FALSE}.
#'
#' @return A list (invisible by default) containing system_info, r_environment,
#'   r_memory, system_memory, cpu, warnings, and timestamp.
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
  r_mem_used_bytes <- if (requireNamespace("pryr", quietly = TRUE)) {
    pryr::mem_used()
  } else {
    gc_info <- gc()
    sum(gc_info[, 2]) * 1024^2
  }
  r_mem_used_gb <- as.numeric(r_mem_used_bytes) / 1024^3

  # Query Windows once for both memory and system details.
  windows_info <- NULL
  if (.Platform$OS.type == "windows" && nzchar(Sys.which("powershell"))) {
    windows_info <- tryCatch({
      command <- paste(
        "$ErrorActionPreference = 'Stop';",
        "[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false);",
        "$os = Get-CimInstance Win32_OperatingSystem;",
        "$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1;",
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
                              stringsAsFactors = FALSE, encoding = "UTF-8")
      fields <- c("TotalVisibleMemorySize", "FreePhysicalMemory", "Caption",
                  "Version", "CpuName")
      if (nrow(info) != 1L || !all(fields %in% names(info)))
        stop("Incomplete Windows CIM result.")
      memory <- suppressWarnings(as.numeric(info[1L, fields[1:2]]))
      if (any(!is.finite(memory)) || memory[1L] <= 0 ||
          memory[2L] < 0 || memory[2L] > memory[1L])
        stop("Invalid Windows CIM memory result.")
      info
    }, error = function(e) NULL)
  }

  # Internal: get system memory info
  .get_system_memory <- function() {
    tryCatch({
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
      } else {
        if (file.exists("/proc/meminfo")) {
          meminfo <- readLines("/proc/meminfo")
          get_mem_value <- function(pat) {
            line <- grep(paste0("^", pat), meminfo, value = TRUE)
            if (length(line) == 1L) {
              as.numeric(gsub("\\D", "", line)) / 1024^2
            } else {
              NA
            }
          }

          total_gb <- get_mem_value("MemTotal:")
          available_gb <- get_mem_value("MemAvailable:")
          if (is.na(available_gb)) {
            free_gb <- get_mem_value("MemFree:")
            cached_gb <- get_mem_value("Cached:")
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
      if (show_warnings) {
        warning("\u65e0\u6cd5\u83b7\u53d6\u7cfb\u7edf\u5185\u5b58\u4fe1\u606f: ",
                e$message, call. = FALSE)
      }
      list(total_gb = NA, free_gb = NA, used_gb = NA, usage_pct = NA)
    })
  }

  sys_mem <- .get_system_memory()
  if (any(lengths(sys_mem) != 1L)) {
    if (show_warnings)
      warning("Incomplete system memory query result.", call. = FALSE)
    sys_mem <- list(total_gb = NA_real_, free_gb = NA_real_,
                    used_gb = NA_real_, usage_pct = NA_real_)
  }

  cores_logical <- parallel::detectCores(logical = TRUE)
  cores_physical <- parallel::detectCores(logical = FALSE)

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
        } else tryCatch({
          ver_info <- system("wmic os get Caption,Version /format:list",
                             intern = TRUE)
          caption_line <- ver_info[grep("Caption=", ver_info)]
          version_line <- ver_info[grep("Version=", ver_info)]

          caption <- if (length(caption_line) > 0) {
            gsub("Caption=", "", caption_line)
          } else {
            "Windows"
          }
          version <- if (length(version_line) > 0) {
            gsub("Version=", "", version_line)
          } else {
            os_version
          }

          cpu_info <- system("wmic cpu get Name /format:list", intern = TRUE)
          cpu_line <- cpu_info[grep("Name=", cpu_info)]
          cpu_name <- if (length(cpu_line) > 0) {
            gsub("Name=", "", cpu_line)
          } else {
            "Unknown"
          }

          list(
            os_full_name = trimws(caption),
            os_version = trimws(version),
            cpu_name = trimws(cpu_name)
          )
        }, error = function(e) {
          list(
            os_full_name = paste("Windows", os_release),
            os_version = os_version,
            cpu_name = "Unknown"
          )
        })

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
                           "\u53ef\u7528\u5185\u5b58\u4e0d\u8db3 (<1GB)")
    }
  }

  if (r_mem_used_gb > 4) {
    memory_warnings <- c(memory_warnings,
                         "R\u8fdb\u7a0b\u5185\u5b58\u4f7f\u7528\u8f83\u9ad8 (>4GB)")
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
  pr_kv(list("\u5f53\u524d\u4f7f\u7528" = sprintf("%.2f GB", r_mem_used_gb)))

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
      "\u603b\u5185\u5b58" = sprintf("%.2f GB", sys_mem$total_gb),
      "\u5df2\u4f7f\u7528" = sprintf("%.2f GB (%.1f%%)", sys_mem$used_gb,
                                 sys_mem$usage_pct),
      "\u53ef\u7528"     = sprintf("%.2f GB", sys_mem$free_gb),
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
    "\u7269\u7406\u6838\u5fc3" = if (!is.na(cores_physical) && cores_physical != cores_logical)
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
