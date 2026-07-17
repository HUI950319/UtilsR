# ============================================================================
# set_wd.R -- Ensure a directory exists and switch the working directory to it
# ============================================================================

#' Create a Directory (if Needed) and Set It as the Working Directory
#'
#' Convenience wrapper for the common analysis-script preamble of "make an
#' output folder if it is not there yet, then \code{setwd()} into it". Unlike a
#' bare \code{dir.create()}, the directory is created recursively, so missing
#' intermediate parents are handled automatically.
#'
#' @param path Character scalar. Target directory. Intermediate directories are
#'   created when \code{create = TRUE}.
#' @param create Logical. Create \code{path} (recursively) when it does not
#'   exist. Default \code{TRUE}. When \code{FALSE}, a missing directory raises
#'   an error instead of being created.
#' @param verbose Logical. Print a short confirmation of the (new) working
#'   directory. Default \code{TRUE}.
#'
#' @return The previous working directory, returned invisibly (same convention
#'   as \code{\link[base]{setwd}}), so the original location can be restored.
#'
#' @examples
#' \dontrun{
#' # Make the folder if needed and move into it
#' set_wd("results/NAT/1.NAT_Ext_DSS_T3_PDAC")
#'
#' # Capture the old location and restore it afterwards
#' old <- set_wd(tempfile("run_"))
#' setwd(old)
#' }
#'
#' @seealso \code{\link[base]{setwd}}, \code{\link[base]{dir.create}}
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

  old_wd <- setwd(path)

  if (isTRUE(verbose)) {
    if (created) {
      cli::cli_alert_success("Created directory {.path {path}}")
    }
    cli::cli_alert_info("Working directory set to {.path {getwd()}}")
  }

  invisible(old_wd)
}
