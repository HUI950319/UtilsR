# =============================================================================
# count_packages.R -- Count installed packages per library path
# =============================================================================

#' Count Installed Packages in Each Library Path
#'
#' Enumerate all \code{.libPaths()} and count the number of installed packages
#' in each directory using \code{utils::installed.packages()}. Unrelated
#' directories and installation locks are excluded. The total counts installed
#' copies across libraries, including packages installed in more than one library.
#'
#' @param refresh Logical scalar. If \code{TRUE}, bypass the installed-package
#'   cache and read package metadata from disk. Defaults to \code{FALSE}.
#'
#' @return Invisibly, a data.frame with columns \code{Library_Path} and
#'   \code{Package_Count}, including a total row. Failed libraries and the
#'   total have \code{NA} counts if any library cannot be read.
#'
#' @details A warning identifies each library that cannot be read. Counts for
#'   readable libraries are still returned; the total is not a partial sum.
#'   A formatted report is written to standard output. Long library paths may
#'   be shortened in the report; the returned data frame keeps full paths.
#'   Counts use comma thousands separators in the report; returned counts
#'   remain numeric.
#'
#' @examples
#' \dontrun{
#' check_packages()
#' check_packages(refresh = TRUE)
#' }
#'
#' @export
#' @family inspect
check_packages <- function(refresh = FALSE) {

  if (!is.logical(refresh) || length(refresh) != 1L || is.na(refresh)) {
    stop("'refresh' must be TRUE or FALSE.", call. = FALSE)
  }

  lib_paths <- .libPaths()

  pkg_counts <- vapply(lib_paths, function(path) {
    tryCatch({
      if (!dir.exists(path) || file.access(path, 5L) != 0L) {
        stop("directory does not exist or is not readable", call. = FALSE)
      }
      nrow(utils::installed.packages(lib.loc = path, noCache = refresh))
    }, error = function(e) {
      warning(sprintf("Cannot read package library %s: %s",
                      sQuote(path), conditionMessage(e)), call. = FALSE)
      NA_integer_
    })
  }, integer(1), USE.NAMES = FALSE)

  result <- data.frame(
    Library_Path = c(lib_paths, "Total"),
    Package_Count = c(pkg_counts, sum(pkg_counts)),
    stringsAsFactors = FALSE
  )

  total <- result[["Package_Count"]][nrow(result)]
  pr_head("check_packages", sprintf("%d libraries", length(lib_paths)),
          if (is.na(total)) "incomplete counts" else
            sprintf("%s installed copies", format(total, big.mark = ",", trim = TRUE)),
          if (refresh) "refreshed",
          bg = if (is.na(total)) "yellow" else "blue",
          fg = if (is.na(total)) "black" else "br_white")

  display <- result[c("Package_Count", "Library_Path")]
  names(display) <- c("Packages", "Library")
  display[["Packages"]] <- format(display[["Packages"]], big.mark = ",",
                                    scientific = FALSE, trim = TRUE)
  count_width <- max(nchar(c("Packages", display[["Packages"]]), type = "width"))
  display[["Library"]] <- as.character(cli::ansi_strtrim(
    display[["Library"]], max(8L, console_width() - count_width - 4L)))
  pr_table(display, highlight = nrow(display), n = NULL, align = c("right", "left"))
  pr_note("Counts are installed copies; the same package in multiple libraries is counted more than once.")
  if (is.na(total)) {
    pr_note("NA marks unreadable libraries; Total is unavailable.")
  }
  if (!identical(display[["Library"]], result[["Library_Path"]])) {
    pr_note("Full paths remain in the returned data frame.")
  }

  invisible(result)
}
