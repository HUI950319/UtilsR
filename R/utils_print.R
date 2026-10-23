# =============================================================================
# utils_print.R -- Building blocks for S3 print methods
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  print helpers: write to stdout, return the lines invisibly -- public API
#         pr_head(class, ...)          class chip + grey one-line summary
#         pr_kv(x)                     aligned key-value block
#         pr_section(title)            grey rule with a bold title
#         pr_note(...)                 grey italic "# note", cli markup
#         pr_badge(key, value)         two-part badge strings (not printed)
#
#   L2  shared internals
#         ._chip()       short label on a solid background (utils_display.R)
#         ._kv_lines()   named values -> aligned "key  value" lines
#         ._pr_out()     write lines to stdout, return them invisibly
#
# Print methods write to stdout with cat(), as print() output is expected
# to; running notices belong to .cat_message() / .cat_step() instead.
# =============================================================================

# Write lines to stdout and return them invisibly; no lines print nothing
# (cat(character(), sep = "\n") would still end an empty line)
._pr_out <- function(lines) {
  if (length(lines)) cat(lines, sep = "\n")
  invisible(lines)
}

# Named values -> "key  value" lines with grey keys aligned by display width,
# so wide (CJK) keys line up. NULL values are dropped, atomic vectors joined
# with ", ", and other objects shown by their class.
._kv_lines <- function(x, arg = "x") {
  keys <- names(x)
  if (length(x) && (is.null(keys) || anyNA(keys) || !all(nzchar(keys)))) {
    cli::cli_abort("Every element of {.arg {arg}} must be named.")
  }
  x    <- as.list(x)
  keep <- !vapply(x, is.null, logical(1))
  if (!any(keep)) return(character())
  keys <- keys[keep]
  vals <- vapply(x[keep], function(v) {
    if (is.atomic(v)) paste(as.character(v), collapse = ", ")
    else paste0("<", class(v)[1], ">")
  }, character(1), USE.NAMES = FALSE)
  width <- max(cli::ansi_nchar(keys, type = "width"))
  paste0(cli::col_grey(cli::ansi_align(keys, width)), "  ", vals)
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

# ------------- pr_kv --------------------------------------------------------

#' Aligned key-value block for a print method
#'
#' Print one \code{key  value} line per element, keys in grey and aligned by
#' their display width, so Chinese or other wide-character keys line up.
#'
#' @param x A named list or named vector. \code{NULL} elements are dropped,
#'   so optional settings can be passed as they are; atomic values are
#'   joined with \code{", "} and other objects are shown by their class,
#'   e.g. \code{<lm>}.
#' @param indent Integer. Spaces before each key (default 2).
#'
#' @return The printed lines, invisibly.
#'
#' @examples
#' pr_kv(list(treat = "Surgery", outcome = "Surv(time, DSS)",
#'            conf_level = 0.95, instrument = NULL))
#'
#' @export
#' @family print helpers
pr_kv <- function(x, indent = 2) {
  lines <- ._kv_lines(x)
  if (length(lines)) lines <- paste0(strrep(" ", indent), lines)
  ._pr_out(lines)
}

# ------------- pr_section ---------------------------------------------------

#' Section rule for a print method
#'
#' Print a thin grey rule led by a bold title, to separate the blocks of a
#' print method.
#'
#' @param title Character. Section title.
#' @param width Integer. Rule width in characters; \code{NULL} (default) uses
#'   the console width, capped at 80 so the rule does not stretch across
#'   wide consoles.
#'
#' @return The printed line, invisibly.
#'
#' @examples
#' pr_section("Effect ranges")
#'
#' @export
#' @family print helpers
pr_section <- function(title, width = NULL) {
  width <- width %||% min(console_width(), 80L)
  line  <- cli::rule(left = cli::style_bold(title), line_col = cli::col_grey,
                     width = width)
  ._pr_out(as.character(line))
}

# ------------- pr_note ------------------------------------------------------

#' Grey note line for a print method
#'
#' Print a grey italic \code{# ...} line for caveats and next steps, such as
#' the plotting call that suits the printed result.
#'
#' The text goes through \code{cli::format_inline()}: \code{{x}} is
#' interpolated from \code{.envir}, inline markup such as \code{{.code ...}}
#' and \code{{.fn ...}} is styled, and in consoles that support hyperlinks
#' (recent RStudio versions) \code{{.run pkg::fun(x)}} and
#' \code{{.help pkg::fun}} become clickable links. Double literal braces, as
#' in \code{"{{x}}"}.
#'
#' @param ... Character pieces of the note, pasted together.
#' @param .envir Environment in which \code{{}} expressions are evaluated;
#'   defaults to the caller.
#'
#' @return The printed line, invisibly.
#'
#' @examples
#' n_panel <- 2
#' pr_note("RV / xRV are partial R2; E-values are risk-ratio multipliers.")
#' pr_note("Plot with {.run causalR::plt_sens(res)} ({n_panel} panels)")
#'
#' @export
#' @family print helpers
pr_note <- function(..., .envir = parent.frame()) {
  text <- cli::format_inline(..., .envir = .envir)
  ._pr_out(cli::col_grey(cli::style_italic(paste("#", text))))
}

# ------------- pr_badge -----------------------------------------------------

#' Two-part key-value badge
#'
#' Build badges in the style of a status badge: the key on dark grey, the
#' value on a colour that can carry its meaning (e.g. red for a violated
#' assumption). Unlike the other print helpers, \code{pr_badge()} returns the
#' strings without printing them, so several badges can share a line.
#'
#' @param key,value Keys and values, recycled to a common length (equal
#'   lengths, or length 1). Values are converted with \code{as.character()}.
#' @param bg,fg Background and text colour of the value part: anything
#'   \code{cli::make_ansi_style()} accepts, as in \code{\link{pr_head}()}.
#'
#' @return A character vector of badges, one per key.
#'
#' @examples
#' cat(pr_badge("model", "cox"), pr_badge("n", "2,314", bg = "green"),
#'     pr_badge("PH", "violated", bg = "red"), "\n")
#'
#' @export
#' @family print helpers
pr_badge <- function(key, value, bg = "blue", fg = "br_white") {
  n <- max(length(key), length(value))
  if (!all(c(length(key), length(value)) %in% c(1L, n))) {
    cli::cli_abort("{.arg key} and {.arg value} must have the same length, or length 1.")
  }
  white <- cli::make_ansi_style("br_white")
  paste0(._chip(rep_len(as.character(key), n),
                cli::make_ansi_style("grey30", bg = TRUE), white),
         ._chip(rep_len(as.character(value), n),
                cli::make_ansi_style(bg, bg = TRUE), cli::make_ansi_style(fg)))
}
