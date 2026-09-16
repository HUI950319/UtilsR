# =============================================================================
# set_wd.R -- Create a directory if needed and make it the working directory
# =============================================================================

#' Create a Directory (if Needed) and Set It as the Working Directory
#'
#' Convenience wrapper for the common analysis-script preamble of "make an
#' output folder if it is not there yet, then \code{setwd()} into it". Unlike a
#' bare \code{dir.create()}, the directory is created recursively, so missing
#' intermediate parents are handled automatically.
#'
#' With \code{verbose = TRUE} the destination is announced as a single
#' \code{\link{.cat_message}} line, in the same
#' \code{... [<contents>, <status>]} shape the \pkg{RegR} savers use for files:
#'
#' \itemize{
#'   \item a directory this call just created reports \code{empty} and a green
#'     \code{new directory} marker;
#'   \item a directory that was already there reports its recursive file count
#'     and total size, and a red \code{existing directory} marker -- the red
#'     flags that whatever the script writes next lands beside, or on top of,
#'     earlier output.
#' }
#'
#' The contents are measured before \code{setwd()} moves in, because a relative
#' \code{path} stops resolving once the working directory has changed.
#'
#' @param path Character scalar. Target directory. Intermediate directories are
#'   created when \code{create = TRUE}.
#' @param create Logical. Create \code{path} (recursively) when it does not
#'   exist. Default \code{TRUE}. When \code{FALSE}, a missing directory raises
#'   an error instead of being created.
#' @param verbose Logical. Print the one-line notice described above. Default
#'   \code{TRUE}. The recursive scan behind the file count and total size runs
#'   only when this is \code{TRUE} \emph{and} the directory already existed, so
#'   \code{verbose = FALSE} also skips walking a very large tree.
#'
#' @return The previous working directory, returned invisibly (same convention
#'   as \code{\link[base]{setwd}}), so the original location can be restored.
#'
#' @examples
#' \dontrun{
#' # Make the folder if needed and move into it
#' set_wd("results/NAT/1.NAT_Ext_DSS_T3_PDAC")
#' #> [2026-09-16 14:32:10] i working directory set to: ... [empty, new directory]
#'
#' # Running the same script again finds the outputs from last time
#' set_wd("results/NAT/1.NAT_Ext_DSS_T3_PDAC")
#' #> [2026-09-16 15:04:22] i working directory set to: ... [42 files, 12.63 MB, existing directory]
#'
#' # Capture the old location and restore it afterwards
#' old <- set_wd(tempfile("run_"))
#' setwd(old)
#' }
#'
#' @seealso \code{\link[base]{setwd}}, \code{\link[base]{dir.create}},
#'   \code{\link{.cat_message}}
#' @export
#' @family file system
set_wd <- function(path, create = TRUE, verbose = TRUE) {

  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("`path` must be a single non-empty character string.", call. = FALSE)
  }

  created <- FALSE
  if (!dir.exists(path)) {
    if (!isTRUE(create)) {
      stop("Directory does not exist and `create = FALSE`: ", path, call. = FALSE)
    }
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    if (!dir.exists(path)) {
      stop("Failed to create directory: ", path, call. = FALSE)
    }
    created <- TRUE
  }

  # Measured here rather than after `setwd()`: a relative `path` no longer
  # resolves once the working directory has moved into it. A directory created
  # just above is empty by construction, so it is never walked.
  contents <- "empty"
  if (isTRUE(verbose) && !created) {
    fmt_bytes <- function(b) {
      if (b >= 1024^3)      sprintf("%.2f GB", b / 1024^3)
      else if (b >= 1024^2) sprintf("%.2f MB", b / 1024^2)
      else if (b >= 1024)   sprintf("%.2f KB", b / 1024)
      else                  sprintf("%.0f B",  b)
    }
    files <- list.files(path, all.files = TRUE, recursive = TRUE)
    if (length(files) > 0L) {
      contents <- sprintf(
        "%d file%s, %s",
        length(files),
        if (length(files) == 1L) "" else "s",
        fmt_bytes(sum(file.size(file.path(path, files)), na.rm = TRUE))
      )
    }
  }

  old_wd <- setwd(path)

  if (isTRUE(verbose)) {
    # `col_br_*()` degrades to plain text when the console has no ANSI colour,
    # so the marker stays readable in a log file or in captured output.
    status <- if (created) {
      cli::col_br_green("new directory")
    } else {
      cli::col_br_red("existing directory")
    }
    .cat_message(sprintf("working directory set to: %s [%s, %s]",
                         getwd(), contents, status))
  }

  invisible(old_wd)
}
