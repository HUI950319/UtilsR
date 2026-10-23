# =============================================================================
# utils_print.R -- Building blocks for S3 print methods
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  print helpers: write to stdout, return the lines invisibly -- public API
#         pr_head(class, ...)          class chip + grey one-line summary
#
#   L2  shared internals
#         ._chip()       short label on a solid background (utils_display.R)
#         ._pr_out()     write lines to stdout, return them invisibly
#
# Print methods write to stdout with cat(), as print() output is expected
# to; running notices belong to .cat_message() / .cat_step() instead.
# =============================================================================

# Write lines to stdout and return them invisibly
._pr_out <- function(lines) {
  cat(lines, sep = "\n")
  invisible(lines)
}

# ------------- pr_head ------------------------------------------------------

#' Header line for a print method
#'
#' Print a class label on a solid background followed by a grey one-line
#' summary: the first line of an S3 print method.
#'
#' @param class Character. Label shown on the chip, usually
#'   \code{class(x)[1]}.
#' @param ... Pieces of the summary, joined by a middle dot. \code{NULL},
#'   \code{NA} and empty strings are dropped, so optional pieces can be
#'   passed as \code{if (cond) "text"}.
#' @param bg,fg Background and text colour of the chip: anything
#'   \code{cli::make_ansi_style()} accepts, i.e. an ANSI colour name such as
#'   \code{"blue"} or \code{"br_white"}, an R colour name or a hex code.
#'
#' @return The printed line, invisibly.
#'
#' @examples
#' pr_head("sens_res", 'method = "cox"', "tipr 1.0.2", "n = 2,314")
#'
#' @export
#' @family print helpers
pr_head <- function(class, ..., bg = "blue", fg = "br_white") {
  parts <- as.character(unlist(list(...), use.names = FALSE))
  parts <- parts[!is.na(parts) & nzchar(parts)]
  line  <- ._chip(class, cli::make_ansi_style(bg, bg = TRUE),
                  cli::make_ansi_style(fg))
  if (length(parts)) {
    line <- paste(line, cli::col_grey(paste(parts, collapse = " \u00b7 ")))
  }
  ._pr_out(line)
}
