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
#         pr_table(data, p_col, ...)   console table, P values coloured
#               +-- ._p_cells()
#         pr_tree(x)                   structure tree of a nested result list
#               +-- ._obj_desc()
#         pr_box(x, header, footer)    rounded box of key-value lines
#               +-- ._kv_lines()
#         pr_spark(data, vars)         one distribution line per column
#
#   L2  shared internals
#         ._chip()       short label on a solid background (utils_display.R)
#         ._kv_lines()   named values -> aligned "key  value" lines
#         ._as_text()    values -> text, numbers as print() shows them
#         ._pr_restore() load methods for supported stored vector classes
#         ._pr_escape()  keep control characters within a single-line field
#         ._pr_trim()    trim only fields that exceed their display budget
#         ._pr_wrap()    wrap words and split overlong runs by display width
#         ._pr_count()   validate whole-number display controls
#         ._p_cells()    P values -> coloured cells (stat_pval() wording)
#         ._obj_desc()   object -> short "<type size>" description
#         ._pr_colour()  does stdout show ANSI colours?
#         ._pr_label()   class chip, or "<class>" without colour
#         ._pr_out()     write lines to stdout, return them invisibly
#
# Print methods write to stdout with cat(), as print() output is expected
# to; running notices belong to .cat_message() / .cat_step() instead.
# =============================================================================

# Does stdout show ANSI colours? cli's own styling follows its default
# stream, stderr outside interactive sessions, so `Rscript x.R > log.txt`
# from a terminal would otherwise write colour codes into the file.
._pr_colour <- function() cli::num_ansi_colors(stdout()) > 1L

# Class label: a chip where stdout shows colour, "<text>" otherwise, so the
# label still stands out in knitted documents and log files
._pr_label <- function(text, bg, fg) {
  text <- ._pr_escape(text)
  if (._pr_colour()) ._chip(text, bg, fg) else paste0("<", text, ">")
}

# Write lines to stdout and return them invisibly; no lines print nothing
# (cat(character(), sep = "\n") would still end an empty line). Colour
# codes are dropped when stdout shows no colour.
._pr_out <- function(lines) {
  if (!._pr_colour()) lines <- cli::ansi_strip(lines)
  if (length(lines)) cat(lines, sep = "\n")
  invisible(lines)
}

# Restore the methods for supported classed storage read from an RDS file.
# In particular, integer64 is a double bit pattern, not a double value.
._pr_restore <- function(v) {
  pkg <- if (inherits(v, "integer64")) "bit64" else
    if (inherits(v, "haven_labelled")) "haven" else
      if (inherits(v, c("Duration", "Period", "Interval"))) "lubridate" else NULL
  if (!is.null(pkg) && !requireNamespace(pkg, quietly = TRUE)) {
    cli::cli_abort("Printing {.cls {class(v)[1]}} values requires package {.pkg {pkg}}.")
  }
  v
}

# Escape layout controls without changing literal backslashes or ANSI styles.
._pr_escape <- function(text) {
  from <- c("\n", "\r", "\t", "\b", "\f", "\v")
  to <- c("\\n", "\\r", "\\t", "\\b", "\\f", "\\v")
  for (i in seq_along(from)) text <- gsub(from[i], to[i], text, fixed = TRUE)
  text
}

._pr_trim <- function(text, width) {
  over <- which(cli::ansi_nchar(text, type = "width") > width)
  text[over] <- cli::ansi_strtrim(text[over], width)
  text
}

# cli wraps at spaces; split overlong words or CJK runs without losing text.
._pr_wrap <- function(text, width, exdent = 0L) {
  width <- max(1L, floor(width))
  text[is.na(text)] <- "NA"
  lines <- as.character(cli::ansi_strwrap(text, width = width, exdent = exdent))
  unlist(lapply(lines, function(s) {
    out <- character()
    while (cli::ansi_nchar(s, type = "width") > width) {
      part <- cli::ansi_strtrim(s, width, ellipsis = "")
      n <- cli::ansi_nchar(part, type = "chars")
      if (!n) {
        n <- 1L
        part <- cli::ansi_strtrim(cli::ansi_substr(s, 1L, 1L), width)
      }
      out <- c(out, part)
      s <- cli::ansi_substr(s, n + 1L, cli::ansi_nchar(s, type = "chars"))
    }
    c(out, s)
  }), use.names = FALSE)
}

._pr_count <- function(value, arg, lower = 0L, null = FALSE, infinite = FALSE) {
  if (null && is.null(value)) return(invisible(value))
  ok <- is.numeric(value) && !is.object(value) && is.null(dim(value)) &&
    length(value) == 1L && !is.na(value)
  if (ok) {
    ok <- (infinite && is.infinite(value) && value > 0) ||
      (is.finite(value) && value >= lower && value == trunc(value))
  }
  if (!ok) {
    extra <- paste0(if (infinite) ", or Inf" else "", if (null) ", or NULL" else "")
    cli::cli_abort("{.arg {arg}} must be a single whole number >= {lower}{extra}.")
  }
  invisible(value)
}

# Values -> text: doubles to getOption("digits") significant digits, as
# print() shows them (as.character() writes 15: 1/3 -> 0.333333333333333);
# factors, dates and other classed vectors through their as.character()
._as_text <- function(v) {
  v <- ._pr_restore(v)
  if (is.double(v) && !is.object(v)) v <- signif(v, getOption("digits", 7L))
  missing <- if (is.expression(v)) is.na(as.list(v)) else
    if (is.language(v)) rep(FALSE, length(v)) else is.na(v)
  text <- as.character(v)
  text[missing] <- NA_character_
  if (is.factor(v)) text[!missing & is.na(text)] <- "<NA>"
  text
}

# Named values -> "key  value" lines with grey keys aligned by display width,
# so wide (CJK) keys line up. NULL values are dropped, atomic vectors joined
# with ", " (the first 20 items, then the count), and other objects described
# by ._obj_desc(). Values wrap at `width` under their own column, as do the
# lines of a value with embedded newlines.
._kv_lines <- function(x, arg = "x", width = Inf) {
  keys <- names(x)
  if (length(x) && (is.null(keys) || anyNA(keys) || !all(nzchar(keys)))) {
    cli::cli_abort("Every element of {.arg {arg}} must be named.")
  }
  x <- ._pr_restore(x)
  x <- if (is.atomic(x) && is.object(x)) {
    lapply(seq_along(x), function(i) x[i])
  } else as.list(x)
  keep <- !vapply(x, is.null, logical(1))
  if (!any(keep)) return(character())
  keys <- ._pr_escape(keys[keep])
  vals <- vapply(x[keep], function(v) {
    if (!is.atomic(v)) return(._obj_desc(v))
    size <- length(v)
    if (size > 20L) v <- ._pr_restore(v)[seq_len(20L)]
    v <- ._as_text(v)
    if (size > 20L) {
      total <- format(size, scientific = FALSE, trim = TRUE)
      v <- c(v, sprintf("%s (%s)", cli::symbol$ellipsis, total))
    }
    paste(v, collapse = ", ")
  }, character(1), USE.NAMES = FALSE)
  kw    <- min(max(cli::ansi_nchar(keys, type = "width")), max(1L, floor((width - 2L) / 2L)))
  keys  <- ._pr_trim(keys, kw)
  avail <- max(1L, width - kw - 2L)
  lead  <- strrep(" ", kw + 2)
  unlist(lapply(seq_along(keys), function(i) {
    segs <- strsplit(vals[[i]], "\n", fixed = TRUE)[[1]]
    body <- unlist(lapply(if (length(segs)) segs else "", function(s) {
      if (nzchar(s)) ._pr_wrap(s, width = avail) else ""
    }))
    c(paste0(cli::col_grey(cli::ansi_align(keys[i], kw)), "  ", body[1]),
      if (length(body) > 1L) paste0(lead, body[-1]))
  }))
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
#'   passed as \code{if (cond) "text"}. Numbers show as \code{print()}
#'   shows them, factors and dates as their labels. SPSS user-missing values
#'   are omitted; explicit missing factor levels remain as \code{<NA>}.
#' @param bg,fg Background and text colour of the chip: anything
#'   \code{cli::make_ansi_style()} accepts, i.e. an ANSI colour name such as
#'   \code{"blue"} or \code{"br_white"}, an R colour name or a hex code.
#'   Without colour (knitted documents, log files) the label prints as
#'   \code{<class>}.
#'
#' @details A line longer than the console is cut with an ellipsis.
#'
#' @return The printed line, invisibly.
#'
#' @examples
#' pr_head("sens_res", 'method = "cox"', "tipr 1.0.2", "n = 2,314")
#'
#' @export
#' @family print helpers
pr_head <- function(class, ..., bg = "blue", fg = "br_white") {
  # piece by piece: unlist() would turn a factor into its codes and a date
  # into a day count
  parts <- unlist(lapply(list(...), ._as_text), use.names = FALSE)
  parts <- parts[!is.na(parts) & nzchar(parts)]
  parts <- ._pr_escape(parts)
  line  <- ._pr_label(class, cli::make_ansi_style(bg, bg = TRUE),
                      cli::make_ansi_style(fg))
  if (length(parts)) {
    line <- paste(line, cli::col_grey(paste(parts, collapse = " \u00b7 ")))
  }
  ._pr_out(cli::ansi_strtrim(line, console_width()))
}

# ------------- pr_kv --------------------------------------------------------

#' Aligned key-value block for a print method
#'
#' Print one \code{key  value} line per element, keys in grey and aligned by
#' their display width, so Chinese or other wide-character keys line up.
#'
#' @param x A named list or named vector. Classed vector elements retain
#'   their types when split into fields. \code{NULL} elements are dropped,
#'   so optional settings can be passed as they are; atomic values are
#'   joined with \code{", "} (the first 20 items, then the count;
#'   numbers as \code{print()} shows them) and
#'   other objects are described by type and size, e.g.
#'   \code{<data.frame 6 x 11>} or \code{<lm>}. Long values
#'   wrap at the console width under the value column, as do the lines of a
#'   value that contains newlines. Long keys are shortened to reserve space
#'   for their values.
#'   SPSS user-missing values display as \code{NA}; explicit missing factor
#'   levels display as \code{<NA>}.
#' @param indent Non-negative integer. Spaces before each key (default 2).
#'   Must leave at least four console columns for the key and value.
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
  ._pr_count(indent, "indent")
  if (console_width() - indent < 4L) {
    cli::cli_abort("{.arg indent} must leave at least four columns for a key and value.")
  }
  lines <- ._kv_lines(x, width = console_width() - indent)
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
#' @param width Positive integer. Rule width in characters; \code{NULL} uses
#'   the console width, capped at 80 so the rule does not stretch across
#'   wide consoles. A title too long for the rule is cut with an ellipsis.
#'
#' @return The printed line, invisibly.
#'
#' @examples
#' pr_section("Effect ranges")
#'
#' @export
#' @family print helpers
pr_section <- function(title, width = NULL) {
  ._pr_count(width, "width", lower = 1L, null = TRUE)
  title <- ._pr_escape(title)
  width <- width %||% min(console_width(), 80L)
  # keep two line characters on each side of the title
  title <- ._pr_trim(title, max(1L, width - 6L))
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
#' in \code{"{{x}}"}. Text that cli cannot parse, such as data that
#' contains braces, is printed as written instead of failing the print.
#' Long notes wrap at the console width, every line starting with \code{#};
#' a \code{"\\n"} starts a new line. Unbroken text also wraps by display width.
#' Combining marks and multi-code-point emoji stay together during wrapping.
#' No supplied pieces print nothing; an explicit empty string prints only
#' the comment marker.
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
  raw  <- paste0(...)
  if (!length(raw)) return(._pr_out(character()))
  # line by line: format_inline() and ansi_strwrap() would join the lines
  segs <- unlist(lapply(strsplit(raw, "\n", fixed = TRUE),
                        function(s) if (length(s)) s else ""))
  body <- unlist(lapply(segs, function(s) {
    text <- tryCatch(cli::format_inline(s, .envir = .envir), error = function(e) s)
    if (nzchar(text)) ._pr_wrap(text, width = max(1L, console_width() - 2L))
    else ""
  }))
  ._pr_out(cli::col_grey(cli::style_italic(paste("#", body))))
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
#'   lengths, or length 1). Values are converted with \code{as.character()};
#'   SPSS user-missing values display as \code{NA}.
#'   Explicit missing factor levels display as \code{<NA>} categories.
#'   Layout controls in keys and values are escaped.
#' @param bg,fg Background and text colour of the value part: anything
#'   \code{cli::make_ansi_style()} accepts, as in \code{\link{pr_head}()}.
#'
#' @return A character vector of badges, one per key; without colour
#'   they read \code{[key: value]}.
#'
#' @examples
#' cat(pr_badge("model", "cox"), pr_badge("n", "2,314", bg = "green"),
#'     pr_badge("PH", "violated", bg = "red"), "\n")
#'
#' @export
#' @family print helpers
pr_badge <- function(key, value, bg = "blue", fg = "br_white") {
  key <- ._pr_restore(key)
  value <- ._pr_restore(value)
  if (inherits(key, "haven_labelled_spss")) key[is.na(key)] <- NA
  if (inherits(value, "haven_labelled_spss")) value[is.na(value)] <- NA
  n <- max(length(key), length(value))
  if (!all(c(length(key), length(value)) %in% c(1L, n))) {
    cli::cli_abort("{.arg key} and {.arg value} must have the same length, or length 1.")
  }
  key <- ._pr_escape(if (is.factor(key)) ._as_text(key) else as.character(key))
  value <- ._pr_escape(if (is.factor(value)) ._as_text(value) else as.character(value))
  if (!._pr_colour()) {
    return(sprintf("[%s: %s]", rep_len(key, n), rep_len(value, n)))
  }
  white <- cli::make_ansi_style("br_white")
  paste0(._chip(rep_len(key, n),
                cli::make_ansi_style("grey30", bg = TRUE), white),
         ._chip(rep_len(value, n),
                cli::make_ansi_style(bg, bg = TRUE), cli::make_ansi_style(fg)))
}

# ------------- pr_table -----------------------------------------------------

# P values -> cells: numbers take stat_pval()'s "<0.001" wording, with more
# decimals where it would round up to 0.05 or 0.01, text keeps its own; bold
# red below 0.001, red below 0.05, grey otherwise. A text bound is significant
# only when every possible value it describes is below the relevant cut-off.
._p_cells <- function(v) {
  if (is.numeric(v)) {
    num <- v
    txt <- stat_pval(v, mode = "pvalue")
    txt[which(!is.na(v) & v < 0.001)] <- "<0.001"
    # a value just under 0.05 or 0.01 rounds up to it (0.0499 -> "0.050"):
    # more decimals, so the text agrees with its colour and stars
    for (d in 4:18) {
      shown <- suppressWarnings(as.numeric(txt))
      up <- which(!is.na(shown) & ((v < 0.05 & shown >= 0.05) |
                                     (v < 0.01 & shown >= 0.01)))
      if (!length(up)) break
      txt[up] <- formatC(v[up], format = "f", digits = d)
    }
    op <- rep("", length(v))
    valid <- !is.na(num)
  } else {
    txt <- trimws(as.character(v), whitespace = "[\\h\\v]")
    number <- "[+-]?(?:[0-9]+\\.?[0-9]*|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?"
    bound <- "(?:[<>]=?|[\u2264\u2265])"
    valid <- grepl(paste0("^(?:", bound, "[\\h\\v]*)?", number, "$"), txt, perl = TRUE)
    op <- ifelse(grepl(paste0("^", bound), txt, perl = TRUE),
                 sub(paste0("^(", bound, ").*$"), "\\1", txt, perl = TRUE), "")
    decimal <- sub(paste0("^", bound, "[\\h\\v]*"), "", txt, perl = TRUE)
    exponent <- suppressWarnings(as.numeric(ifelse(grepl("[eE]", decimal),
      sub("^.*[eE]", "", decimal), "0")))
    mantissa <- sub("[eE].*$", "", decimal)
    negative <- grepl("^-", mantissa)
    mantissa <- sub("^[+-]", "", mantissa)
    places <- ifelse(grepl(".", mantissa, fixed = TRUE),
                     nchar(sub("^.*[.]", "", mantissa)), 0L)
    coefficient <- sub("^0+", "", gsub(".", "", mantissa, fixed = TRUE))
    zero <- coefficient == ""
    power <- exponent - places + nchar(coefficient) - 1L
    significant <- sub("0+$", "", coefficient)
    digit <- suppressWarnings(as.integer(substr(significant, 1L, 1L)))
    one <- power == 0 & significant == "1"
    valid <- valid & (!negative | zero) & (zero | power < 0 | one) &
      !(op == "<" & zero) & !(op == ">" & one)
  }
  below <- function(cut) {
    if (is.numeric(v)) {
      less <- num < cut
      equal <- num == cut
    } else {
      # Decimal endpoints can differ from a cut-off after parsing as doubles.
      cut_power <- if (cut == 0.001) -3L else -2L
      cut_digit <- if (cut == 0.05) 5L else 1L
      less <- zero | power < cut_power | (power == cut_power & digit < cut_digit)
      equal <- power == cut_power & significant == as.character(cut_digit)
    }
    valid & (op %in% c("", "<", "<=", "\u2264")) &
      (less | (op == "<" & equal))
  }
  strong <- below(0.001)
  sig    <- !strong & below(0.05)
  txt <- ._pr_escape(txt)
  # without colour, stars carry the significance instead
  if (!._pr_colour()) {
    two <- sig & below(0.01)
    stars <- ifelse(strong, "***", ifelse(two, "**", ifelse(sig, "*", "")))
    return(paste0(ifelse(is.na(txt), "NA", txt), stars))
  }
  out <- as.character(cli::col_grey(ifelse(is.na(txt), "NA", txt)))
  out[sig]    <- cli::col_red(txt[sig])
  out[strong] <- cli::style_bold(cli::col_red(txt[strong]))
  out
}

#' Console table for a print method
#'
#' Print a data frame as an aligned plain-text table: a bold header, a grey
#' rule, then one line per row. Columns are aligned by display width, so
#' Chinese text lines up; P-value columns are coloured by significance, and
#' chosen rows can be highlighted.
#'
#' Cells are formatted as follows. P-value columns: numbers take the
#' \code{\link{stat_pval}(mode = "pvalue")} wording (\code{"<0.001"}),
#' a number just under 0.05 or 0.01 that this wording would round up to the
#' cut-off taking the decimals it needs (\code{0.0499}, not \code{0.050}),
#' text is kept as written, and values print bold red below 0.001, red below
#' 0.05 and grey otherwise. Text bounds receive significance styling only
#' when their comparison guarantees a value below the cut-off; lower bounds
#' and invalid numeric text receive none. Decimal text is compared without
#' rounding its endpoint to double precision. Other double columns are rounded to
#' \code{digits} decimals, or none when every value is whole; a column whose
#' smallest non-zero value would round to zero gets enough decimals for two
#' significant digits, at most six. Nonzero values still rounded to zero,
#' and numbers wider than the available line, use scientific notation.
#' Missing values
#' print as a grey \code{NA}; an explicit missing factor level displays as
#' \code{<NA>}. Matrix and array columns are described one row
#' at a time, retaining all components. Packed data-frame columns show each
#' row as a named list. List-column cells are described as in
#' \code{\link{pr_tree}()}, e.g. \code{<dbl 2> 1.1, 2.2}. Everything else
#' uses \code{as.character()}. Classed numeric and time-span columns use their
#' format methods, retaining integer64 digits and time units. The optional
#' packages bit64, haven and lubridate are loaded by namespace when their
#' stored types are encountered.
#' POSIXlt date-times display as equivalent POSIXct vectors.
#' Layout control characters in cells and column names are escaped so they
#' cannot introduce extra table rows or misalign columns. A missing column
#' name is displayed as \code{<NA>}.
#' Without colour (knitted documents, log files), P values carry stars
#' (\code{***} below 0.001, \code{**} below 0.01, \code{*} below 0.05),
#' highlighted rows start with \code{>} and missing text cells read
#' \code{<NA>}.
#'
#' @param data A data frame (tibbles included).
#' @param p_col Character. Names of the P-value columns, or \code{NULL}.
#' @param highlight Rows to highlight in black on light yellow: integer row
#'   numbers or a logical vector. Highlighted rows drop their other colours.
#'   Missing, fractional and non-finite selectors are rejected; zero and
#'   positions outside the displayed rows are ignored.
#' @param rownames Logical. Show the row names as a first, unnamed column,
#'   e.g. the terms of \code{as.data.frame(coef(summary(fit)))}, which are
#'   otherwise not shown (default \code{FALSE}).
#'   Displayed row names are never treated as P values.
#' @param n Non-negative integer. Rows to show (default 20); the rest are
#'   counted in a grey footer. \code{NULL} or \code{Inf} shows every row.
#' @param align Column alignment, recycled: \code{"left"}, \code{"right"}
#'   or \code{"center"}. \code{NULL} (default) right-aligns numeric and
#'   P-value columns and left-aligns the rest.
#' @param digits Integer from 0 to 324. Decimals for double columns (default 2).
#' @param width Positive integer. Line width the table must fit; \code{NULL}
#'   (default) uses the console width. The first column and the P-value
#'   columns always show. Long required headings and, when necessary, cells
#'   are cut with an ellipsis; the other columns follow while they fit, and the
#'   footer names those left out.
#' @param indent Non-negative integer. Spaces before each line (default 2).
#'   Uncoloured highlighted output reserves at least two columns, including
#'   its marker, even when a smaller indent is requested.
#'
#' @return The printed lines, invisibly.
#'
#' @examples
#' res <- data.frame(
#'   Variable = c("Age >= 55", "Male", "Multifocal"),
#'   HR = c(1.85, 1.25, 1.08),
#'   P = c(0.0003, 0.012, 0.21)
#' )
#' pr_table(res, p_col = "P", highlight = 1)
#'
#' @export
#' @family print helpers
pr_table <- function(data, p_col = NULL, highlight = NULL, rownames = FALSE,
                     n = 20, align = NULL, digits = 2, width = NULL, indent = 2) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_friendly {data}}.")
  }
  ._pr_count(n, "n", null = TRUE, infinite = TRUE)
  ._pr_count(digits, "digits")
  if (digits > 324L) cli::cli_abort("{.arg digits} must not exceed the formatC limit of 324.")
  ._pr_count(width, "width", lower = 1L, null = TRUE)
  ._pr_count(indent, "indent")
  if (!is.null(highlight) &&
      (!(is.numeric(highlight) || is.logical(highlight)) || is.object(highlight) ||
       !is.null(dim(highlight)) || anyNA(highlight) ||
       (is.numeric(highlight) && any(!is.finite(highlight) | highlight < 0 |
                                     highlight != trunc(highlight))))) {
    cli::cli_abort("{.arg highlight} must be non-negative whole row numbers or a logical vector, without missing values.")
  }
  miss <- setdiff(p_col, names(data))
  if (length(miss)) {
    cli::cli_abort("{.arg p_col} names column{?s} absent from {.arg data}: {.val {miss}}.")
  }
  if (!ncol(data)) return(._pr_out(character()))
  data   <- as.data.frame(data)
  is_p <- names(data) %in% p_col
  # not automatic for character row names: rbind() of a named list leaves
  # "cox.1", "cox.2", which would become a column of their own
  if (isTRUE(rownames)) {
    data <- cbind(stats::setNames(data.frame(row.names(data)), " "), data)
    is_p <- c(FALSE, is_p)
  }
  n_rows <- nrow(data)
  if (!is.null(n) && n_rows > n) data <- data[seq_len(n), , drop = FALSE]

  colour <- ._pr_colour()
  hl <- if (is.logical(highlight)) which(highlight) else highlight
  if (!colour && any(seq_len(nrow(data)) %in% hl)) indent <- max(indent, 2L)
  is_num <- vapply(data, is.numeric, logical(1)) | is_p
  cells  <- lapply(seq_along(data), function(j) {
    v <- ._pr_restore(data[[j]])
    if (inherits(v, "POSIXlt")) v <- as.POSIXct(v)
    if (is_p[j]) return(._p_cells(v))
    if (is.data.frame(v)) {
      return(vapply(seq_len(nrow(v)), function(i) {
        ._obj_desc(as.list(v[i, , drop = FALSE]), width = 40, inside = TRUE)
      }, character(1)))
    }
    if (is.array(v)) {
      return(vapply(seq_len(nrow(v)), function(i) {
        at <- if (length(v)) seq.int(i, length(v), by = nrow(v)) else integer()
        ._obj_desc(v[at], width = 40)
      }, character(1)))
    }
    if (is.double(v) && is.numeric(v) && !is.object(v)) {
      fin  <- v[is.finite(v)]
      d    <- if (all(fin == round(fin))) 0L else digits
      # 0.0003 would print as 0.00: give the column two significant digits
      tiny <- abs(fin[fin != 0])
      if (d > 0L && length(tiny) && min(tiny) < 0.5 * 10^-d) {
        d <- min(6L, as.integer(ceiling(-log10(min(tiny)))) + 1L)
      }
      txt <- formatC(v, format = "f", digits = d)
      rounded <- suppressWarnings(as.numeric(txt))
      scientific <- which(is.finite(v) &
        ((v != 0 & rounded == 0) | nchar(txt) > max(10L, (width %||% console_width()) - indent)))
      if (length(scientific)) {
        txt[scientific] <- formatC(v[scientific], format = "e", digits = max(1L, min(digits, 15L)))
      }
    } else if (is.object(v) && (is.numeric(v) || inherits(v, "difftime"))) {
      txt <- format(v, trim = TRUE)
    } else if (is.list(v)) {
      # a list column: describe each cell, rather than deparse it (c(1.1, 2.2))
      txt <- vapply(v, ._obj_desc, character(1), width = 40)
    } else {
      txt <- ._as_text(v)
    }
    txt <- ._pr_escape(txt)
    missing <- if (is.expression(v)) is.na(as.list(v)) else is.na(v)
    ifelse(missing, if (!colour && !is.numeric(v)) "<NA>" else cli::col_grey("NA"),
           txt)
  })

  align <- if (is.null(align)) ifelse(is_num, "right", "left") else
    rep_len(match.arg(align, c("left", "right", "center"), several.ok = TRUE),
            ncol(data))
  headers <- names(data)
  headers[is.na(headers)] <- "<NA>"
  headers <- ._pr_escape(headers)
  col_w <- vapply(seq_along(cells), function(j) {
    max(cli::ansi_nchar(c(headers[j], cells[[j]]), type = "width"))
  }, numeric(1))
  # the first and the P-value columns always show; the others follow in
  # order until one no longer fits the line
  avail <- (width %||% console_width()) - indent
  keep  <- unique(c(1L, which(is_p)))
  gap <- 2L
  if (avail < length(keep)) {
    cli::cli_abort("The line width must leave at least one character per required column.")
  }
  if (length(keep) > 1L) gap <- min(gap, max(0L, floor((avail - length(keep)) / (length(keep) - 1L))))
  if (sum(col_w[keep]) + gap * (length(keep) - 1L) > avail) {
    # Shorten required headings before sacrificing P-value contents.
    for (j in setdiff(keep, 1L)) {
      col_w[j] <- min(col_w[j], max(c(1L, cli::ansi_nchar(cells[[j]], type = "width"))))
    }
    col_w[1] <- min(col_w[1], max(1L, avail - sum(col_w[setdiff(keep, 1L)]) - gap * (length(keep) - 1L)))
    over <- sum(col_w[keep]) + gap * (length(keep) - 1L) - avail
    while (over > 0) {
      j <- keep[which.max(col_w[keep])]
      cut <- min(over, col_w[j] - 1L)
      col_w[j] <- col_w[j] - cut
      over <- over - cut
    }
  }
  for (j in setdiff(seq_along(cells), keep)) {
    if (sum(col_w[c(keep, j)]) + gap * length(keep) > avail) break
    keep <- c(keep, j)
  }
  keep <- sort(keep)
  row <- function(x) {
    paste(vapply(keep, function(j) {
      s <- x[[j]]
      # only a cell that is too wide: below the ellipsis's width,
      # ansi_strtrim() gives a cut ellipsis even for text that fits ("A" -> ".")
      s <- ._pr_trim(s, col_w[j])
      cli::ansi_align(s, col_w[j], align[j])
    }, character(1)), collapse = strrep(" ", gap))
  }

  pad    <- strrep(" ", indent)
  header <- paste0(pad, cli::style_bold(row(headers)))
  rule   <- paste0(pad, cli::col_grey(strrep(cli::symbol$line,
                                             sum(col_w[keep]) + gap * (length(keep) - 1))))
  hl_bg  <- cli::make_ansi_style("#FFFF99", bg = TRUE)
  body   <- vapply(seq_len(nrow(data)), function(i) {
    r <- row(lapply(cells, `[`, i))
    if (!(i %in% hl)) return(paste0(pad, r))
    if (colour) return(paste0(pad, hl_bg(cli::col_black(cli::ansi_strip(r)))))
    paste0(">", strrep(" ", max(indent - 1L, 1L)), r)
  }, character(1))

  more <- function(k, what) {
    sprintf("%s %d more %s%s", cli::symbol$ellipsis, k, what, if (k == 1L) "" else "s")
  }
  dropped <- setdiff(seq_along(cells), keep)
  foot <- c(if (n_rows > nrow(data)) more(n_rows - nrow(data), "row"),
            if (length(dropped)) paste0(more(length(dropped), "column"), ": ",
                                          toString(headers[dropped])))
  if (length(foot)) {
    foot <- paste0(pad, cli::col_grey(._pr_wrap(
      paste("#", paste(foot, collapse = "; ")), width = avail, exdent = 2)))
  }
  ._pr_out(c(header, rule, body, foot))
}

# ------------- pr_tree ------------------------------------------------------

# Rendered tables and pages that are lists underneath: opening them shows
# their internals (a gt table has some 20 `_data`, `_styles`, ... fields),
# not the result's parts, so they stay closed like data frames and plots.
._tree_leaf <- c("gt_tbl", "fmt_page", "shiny.tag.list")

# Short description of an object: "<tibble 12 x 7>", "<ggplot>"; atomic
# values follow their type, e.g. <chr> "cox" or <chr 3> "Age", "Sex", "Stage"
# (the first 10 values, the description cut to `width` characters). With
# `colour`, the type and size are grey and NA red, values in the text colour;
# with `inside`, a container that stays closed previews what it holds.
._obj_desc <- function(v, width = 80, colour = FALSE, inside = FALSE) {
  v <- ._pr_restore(v)
  g <- if (colour) cli::col_grey else identity
  if (is.null(v)) return(g("<NULL>"))
  big <- function(n) format(n, big.mark = ",", scientific = FALSE, trim = TRUE)
  # values as text: strings quoted, a labelled value with its label
  # ("1 [Male]"), NA red with `colour`
  text_of <- function(first, labs = attr(first, "labels", exact = TRUE)) {
    first <- ._pr_restore(first)
    missing <- is.na(first)
    vals <- if (is.character(first)) {
      encodeString(first, quote = "\"")
    } else if (is.factor(first)) {
      ifelse(is.na(first), "NA", encodeString(as.character(first)))
    } else if (is.integer(first) && !is.object(first)) {
      as.character(first)
    } else if (is.numeric(first) && !is.object(first)) {
      # format() keeps the integer part, which signif() rounded (1234.5678
      # showed as 1230, 123456L as 123000)
      vapply(first, format, character(1), digits = 3)
    } else {
      vapply(seq_along(first), function(i) format(first[i]), character(1))
    }
    vals[missing] <- "NA"
    if (length(names(labs))) {
      hit  <- names(labs)[match(unclass(first), unclass(labs))]
      vals <- ifelse(is.na(hit) | missing, vals, sprintf("%s [%s]", vals, ._pr_escape(hit)))
    }
    if (colour) vals[missing] <- cli::col_red(vals[missing])
    vals
  }
  # a POSIXlt time is a list underneath; show the time it holds
  if (inherits(v, "POSIXlt")) v <- as.POSIXct(v)
  cls <- ._pr_escape(class(v)[1])
  if (is.data.frame(v)) {
    lab  <- if (inherits(v, "tbl_df")) "tibble" else cls
    head <- sprintf("<%s %s x %s>", lab, big(nrow(v)), big(ncol(v)))
    if (!inside || !ncol(v)) return(g(head))
    # its column names, as far as the line goes
    room <- max(width - cli::ansi_nchar(head, type = "width") - 1L, 10L)
    return(paste(g(head), cli::ansi_strtrim(paste(._pr_escape(names(v)), collapse = g(", ")), room)))
  }
  if (!is.null(dim(v))) {
    # an atomic matrix or table with its element type: <int matrix 2 x 3>
    abbr <- if (is.atomic(v)) {
      tryCatch(vctrs::vec_ptype_abbr(as.vector(unclass(v))), error = function(e) NULL)
    }
    return(g(sprintf("<%s %s>", paste(c(abbr, cls), collapse = " "),
                     paste(big(dim(v)), collapse = " x "))))
  }
  if (is.function(v)) {
    # its arguments, as lobstr::tree() shows them; args() reads a primitive's
    a <- names(formals(if (is.primitive(v)) args(v) else v))
    if (length(a) > 4L) a <- c(a[1:4], cli::symbol$ellipsis)
    return(g(if (is.null(a) && is.primitive(v)) "<fn>" else
      sprintf("<fn(%s)>", paste(._pr_escape(a), collapse = ", "))))
  }
  # a classed environment, such as an R6 learner, is named by its class
  if (is.environment(v)) return(g(if (is.object(v)) sprintf("<%s>", cls) else "<env>"))
  if (is.list(v)) {
    if (is.object(v) && (!inherits(v, "list") || inherits(v, ._tree_leaf))) {
      return(g(sprintf("<%s>", cls)))
    }
    head <- sprintf("<%s %s>", if (is.object(v)) cls else "list", big(length(v)))
    nm   <- names(v)
    if (!inside || is.null(nm) || !length(v)) return(g(head))
    # its names, each single atomic value after its name, as far as the line goes
    items <- vapply(utils::head(seq_along(v), 20L), function(i) {
      key <- if (is.na(nm[i]) || !nzchar(nm[i])) sprintf("[[%d]]", i) else ._pr_escape(nm[i])
      e   <- v[[i]]
      if (is.atomic(e) && length(e) == 1L && is.null(dim(e))) {
        paste(g(paste(key, "=")), text_of(e))
      } else key
    }, character(1))
    room <- max(width - cli::ansi_nchar(head, type = "width") - 1L, 10L)
    return(paste(g(head), cli::ansi_strtrim(paste(items, collapse = g(", ")), room)))
  }
  if (is.atomic(v)) {
    # vctrs names classed vectors as well: drtn, dbl+lbl, int64, ord
    abbr <- ._pr_escape(tryCatch(vctrs::vec_ptype_abbr(v), error = function(e) typeof(v)))
    # as many values as the line could hold, as vctrs takes half its width
    first <- utils::head(v, max(10L, ceiling(width / 2)))
    vals  <- text_of(first, attr(v, "labels", exact = TRUE))
    # a named value with its name
    nm <- names(first)
    if (!is.null(nm)) {
      vals <- ifelse(is.na(nm) | !nzchar(nm), vals, paste(g(paste(._pr_escape(nm), "=")), vals))
    }
    # a factor with its number of levels, as str() gives it
    lev  <- if (is.factor(v)) {
      sprintf(", %s level%s", big(nlevels(v)), if (nlevels(v) == 1L) "" else "s")
    } else ""
    head <- if (length(v) == 1L) sprintf("<%s%s>", abbr, lev) else
      sprintf("<%s %s%s>", abbr, big(length(v)), lev)
    if (!length(vals)) return(g(head))
    room <- max(width - cli::ansi_nchar(head, type = "width") - 1L, 10L)
    text <- paste(vals, collapse = g(", "))
    # values left out show even when the ones taken fit
    if (length(v) > length(first)) text <- paste0(text, g(", "), cli::symbol$ellipsis)
    return(paste(g(head), cli::ansi_strtrim(text, room)))
  }
  if (is.language(v)) {
    abbr <- if (inherits(v, "formula")) "formula" else if (is.name(v)) "sym" else
      if (is.expression(v)) "expr" else "call"
    text <- paste(deparse(v, width.cutoff = 500L), collapse = " ")
    return(paste(g(sprintf("<%s>", abbr)),
                 cli::ansi_strtrim(text, max(width - nchar(abbr) - 3L, 10L))))
  }
  g(sprintf("<%s>", cls))
}

#' Structure tree of a nested result object
#'
#' Print the elements of a list-based result as a tree, each with a short
#' description such as \code{<tibble 12 x 7>},
#' \code{<chr 3> "Age", "Sex", "Stage"} or \code{<ggplot>}; clearer than
#' \code{str()} for the nested lists that analysis functions return. Atomic
#' vectors show their first values, as many as fit the console width, a data
#' frame its column names, and a list left closed at \code{max_depth} its
#' names with the value of each single one (an unnamed list an ellipsis).
#' POSIXlt date-times display as equivalent POSIXct vectors.
#' Sibling names line up in a column. Types and sizes are grey, values in the
#' text colour with \code{NA} in red, and the names of elements that hold
#' others bold; a classed list starts with its class as a chip.
#' Closed previews restore methods for stored classed values; SPSS
#' user-missing values display as \code{NA}.
#'
#' The object passed in always opens: a model fit lists its components, a
#' data frame its columns and an S4 object its slots (as \code{@name}). Below
#' it the tree descends into plain lists and into classed objects that also
#' inherit from \code{"list"} (as \code{c("eff_res", "list")} does). Data
#' frames, plots and other objects are leaves, and so are gt tables, RegR
#' pages and htmltools tag lists, which are lists underneath; R6 and other
#' classed environments show their class. Attributes other than names,
#' class, dimensions, row names, srcref and those a type keeps for itself
#' (factor levels, a time zone, value labels) are listed under an open node,
#' marked \code{attr}, and named at the end of a closed node's line as
#' \code{[attr: name]}.
#'
#' @param x A list or list-based object.
#' @param max_depth Non-negative integer, or \code{Inf}. Levels below the
#'   root to show (default 3).
#' @param max_items Non-negative integer, or \code{Inf}. Elements per node
#'   before the rest are
#'   summarised as "... n more", with their names (default 20).
#' @param max_lines Non-negative integer, or \code{Inf}. Lines shown in all
#'   (default 200); a grey footer counts the rest.
#' @param attrs Logical. Show extra attributes (default \code{TRUE}).
#'
#' @return The printed lines, invisibly.
#'
#' @examples
#' res <- structure(
#'   list(Overall = list(table = data.frame(term = "Age", HR = 1.8),
#'                       method = "cox"),
#'        Subgroup = data.frame(term = c("Male", "Female"), HR = c(1.2, 1.4))),
#'   class = c("eff_res", "list"),
#'   analysis = list(n = 120, outcome = "DSS")
#' )
#' pr_tree(res)
#'
#' @export
#' @family print helpers
pr_tree <- function(x, max_depth = 3, max_items = 20, max_lines = 200,
                    attrs = TRUE) {
  ._pr_count(max_depth, "max_depth", infinite = TRUE)
  ._pr_count(max_items, "max_items", infinite = TRUE)
  ._pr_count(max_lines, "max_lines", infinite = TRUE)
  x <- ._pr_restore(x)
  if (inherits(x, "POSIXlt")) x <- as.POSIXct(x)
  drop_attr <- c("names", "class", "dim", "dimnames", "row.names", "srcref")
  descend <- function(v) {
    is.list(v) && !is.data.frame(v) && !inherits(v, ._tree_leaf) &&
      (!is.object(v) || inherits(v, "list"))
  }
  # the object asked about always opens: a model fit shows its components, a
  # data frame its columns and an S4 object its slots (as @name), which stay
  # closed further down
  opens <- function(v, depth) descend(v) || (depth == 0 && (is.list(v) || isS4(v)))
  parts <- function(v) {
    if (!isS4(v) || is.list(v)) return(v)
    s <- setdiff(names(attributes(v)), "class")
    stats::setNames(lapply(s, function(a) attr(v, a, exact = TRUE)), paste0("@", s))
  }
  # attributes beyond those a type keeps for itself (factor levels, a time
  # zone, value labels, a formula's environment, S7 properties), as str()
  # lists them on every node
  extra <- function(v) {
    if (isS4(v) || is.environment(v) || is.function(v)) return(character())
    own <- c(drop_attr, "levels", "contrasts", "tzone", "units", "labels", "balanced",
             ".Environment", ".internal.selfref", "S7_class",
             names(attr(attr(v, "S7_class", exact = TRUE), "properties", exact = TRUE)))
    a <- setdiff(names(attributes(v)), own)
    if (length(a) > 3L) c(a[1:3], cli::symbol$ellipsis) else a
  }
  rows <- new.env(parent = emptyenv())
  rows$id <- character(); rows$children <- list(); rows$label <- character()
  rows$n  <- 0L
  add <- function(id, label, children = character()) {
    rows$id       <- c(rows$id, id)
    rows$children <- c(rows$children, list(children))
    rows$label    <- c(rows$label, label)
    id
  }
  # Lines are counted in the order the tree prints them. Within max_lines a
  # line is described ("show"); past it, it is only counted, except that a
  # line under a shown parent stays as an empty "stub", so the shown lines
  # keep the branch glyphs of the full tree. Describing and drawing every
  # node first took 3 s for a 20 x 20 x 20 list cut to 200 lines (2026-10-25).
  slot <- function(parent_shown) {
    rows$n <- rows$n + 1L
    if (rows$n <= max_lines) "show" else if (parent_shown) "stub" else "count"
  }
  node <- function(v, id, label, depth, how) {
    shown <- how == "show"
    kids <- character()
    if (depth < max_depth && opens(v, depth)) {
      p  <- parts(v)
      take <- min(length(p), max_items + 50L)
      nm <- names(p)
      nm <- if (is.null(nm)) rep("", take) else nm[seq_len(take)]
      nm <- ._pr_escape(ifelse(is.na(nm) | !nzchar(nm), sprintf("[[%d]]", seq_len(take)), nm))
      # sibling names padded into a column, as str() lines them up, up to 18
      wid <- cli::ansi_nchar(nm, type = "width")
      pad <- min(max(c(0L, wid[seq_len(min(length(p), max_items))])), 18L)
      for (k in seq_len(min(length(p), max_items))) {
        child <- p[[k]]
        h <- slot(shown)
        child_label <- ""
        if (h == "show") {
          closed <- !(descend(child) && depth + 1 < max_depth)
          # a closed node's attributes, which no attr line below it lists
          more <- if (closed && isTRUE(attrs)) extra(child) else character()
          tag  <- if (length(more)) {
            cli::col_cyan(sprintf("[attr: %s]", paste(._pr_escape(more), collapse = ", ")))
          } else ""
          room <- console_width() - 2L * (depth + 1L) - max(wid[k], pad) - 1L -
            (if (nzchar(tag)) cli::ansi_nchar(tag, type = "width") + 1L else 0L)
          name <- if (descend(child) && length(child)) cli::style_bold(nm[k]) else nm[k]
          name <- paste0(name, strrep(" ", max(pad - wid[k], 0L)))
          child_label <- paste(name, ._obj_desc(child, room, colour = TRUE, inside = closed))
          if (nzchar(tag)) child_label <- paste(child_label, tag)
          # a list left unopened at max_depth; a named one previews its names
          if (depth + 1 >= max_depth && descend(child) && length(child) &&
              is.null(names(child))) {
            child_label <- paste(child_label, cli::col_grey(cli::symbol$ellipsis))
          }
          # what still overflows a narrow console (a type and an attribute tag
          # wider than the line) ends in an ellipsis; cli::tree() cut it bare
          child_label <- cli::ansi_strtrim(child_label,
                                           max(console_width() - 2L * (depth + 1L), 10L))
        }
        kid <- node(child, paste0(id, "/", k), child_label, depth + 1, h)
        if (h != "count") kids <- c(kids, kid)
      }
      if (length(p) > max_items) {
        h <- slot(shown)
        if (h != "count") kids <- c(kids, add(paste0(id, "/more"), if (h == "show") {
          rest <- sprintf("%s %s more", cli::symbol$ellipsis,
                          format(length(p) - max_items, big.mark = ","))
          # the names left out, as far as the line goes
          if (!is.null(names(p))) {
            rest <- cli::ansi_strtrim(paste0(rest, ": ", paste(
                utils::head(nm[seq.int(max_items + 1L, length(nm))], 50L), collapse = ", ")),
              console_width() - 2L * (depth + 1L))
          }
          cli::col_grey(rest)
        } else ""))
      }
      # an S4 object's attributes are its slots, listed above
      if (isTRUE(attrs) && !(isS4(v) && !is.list(v))) {
        for (a in setdiff(names(attributes(v)), drop_attr)) {
          h <- slot(shown)
          if (h != "count") kids <- c(kids, add(paste0(id, "/@", a), if (h == "show") {
            name <- ._pr_escape(a)
            paste(cli::col_cyan("attr"), name, ._obj_desc(
              attr(v, a, exact = TRUE),
              console_width() - 2L * (depth + 1L) - 6L - cli::ansi_nchar(name, type = "width"),
              colour = TRUE, inside = TRUE))
          } else ""))
        }
      }
    }
    if (how != "count") add(id, label, kids) else id
  }

  big <- function(n) format(n, big.mark = ",", scientific = FALSE, trim = TRUE)
  root_desc <- if (is.data.frame(x)) {
    cli::col_grey(sprintf("<%s %s x %s>", if (inherits(x, "tbl_df")) "tibble" else
      ._pr_escape(class(x)[1]), big(nrow(x)), big(ncol(x))))
  } else if (opens(x, 0)) {
    cli::col_grey(sprintf("<%s %s>", if (is.list(x)) "list" else "S4", big(length(parts(x)))))
  } else {
    ._obj_desc(x, console_width() - cli::ansi_nchar(class(x)[1], type = "width") - 3L,
               colour = TRUE)
  }
  # the class as a chip for a classed list, a model fit or an S4 object; a
  # plain list, a vector or a data frame names its class in the description
  # already ("<list> <list 3>")
  if (opens(x, 0) && is.object(x) && !is.data.frame(x)) {
    root_desc <- paste(._pr_label(class(x)[1], cli::bg_blue, cli::col_br_white), root_desc)
  }
  root <- node(x, "x", root_desc, 0, slot(TRUE))
  tree <- as.character(cli::tree(data.frame(id = rows$id, children = I(rows$children),
                                            label = rows$label,
                                            stringsAsFactors = FALSE),
                                 root = root))
  if (rows$n > max_lines) {
    # the argument that cut them, as rlang names what shows hidden frames
    tree <- c(tree[seq_len(max_lines)], ._pr_wrap(cli::col_grey(sprintf(
      "# %s %s more lines (max_lines = %d)", cli::symbol$ellipsis,
      format(rows$n - max_lines, big.mark = ","), max_lines)), console_width()))
  }
  ._pr_out(tree)
}

# ------------- pr_box -------------------------------------------------------

#' Boxed summary for a print method
#'
#' Print a rounded box around key-value lines (as in \code{\link{pr_kv}()})
#' or plain lines, with an optional bold header in the top border and a grey
#' footer in the bottom one; suits a model specification such as outcome,
#' exposure, covariates and sample size.
#'
#' @param x A named list or named vector, shown as aligned key-value lines
#'   with \code{NULL} elements dropped, or an unnamed character vector, shown
#'   line by line. Missing plain lines display as \code{NA}.
#' @param header,footer Character, or \code{NULL} for none. Text set into
#'   the top and bottom border. Layout controls are escaped.
#' @param col Border colour: anything \code{cli::make_ansi_style()} accepts
#'   (default \code{"cyan"}).
#' @details Horizontal padding shrinks in very narrow consoles. A box needs
#'   at least three console columns, or five when border labels are supplied.
#'
#' @return The printed lines, invisibly. Nothing prints when \code{x} has no
#'   lines, e.g. when every element is \code{NULL}.
#'
#' @examples
#' pr_box(list(Outcome = "Surv(time, DSS)", Exposure = "Surgery (Yes vs No)",
#'             Adjust = "Age + Sex + Stage", N = "2,314 (412 events)"),
#'        header = "Cox model", footer = "adjusted")
#'
#' @export
#' @family print helpers
pr_box <- function(x, header = NULL, footer = NULL, col = "cyan") {
  # Keep the usual two-space padding while leaving room for narrow contents.
  width <- console_width()
  padding <- min(2L, max(0L, floor((width - 4L) / 2L)))
  avail <- max(1L, width - 2L - 2L * padding)
  lines <- if (is.character(x) && is.null(names(x))) {
    unlist(lapply(x, function(s) ._pr_wrap(s, width = avail)))
  } else {
    ._kv_lines(x, width = avail)
  }
  # cli::boxx() fails on no lines; an empty settings list prints nothing
  if (!length(lines)) return(._pr_out(character()))
  if (width < 3L) cli::cli_abort("The console must be at least three columns wide for a box.")
  if (!is.null(header)) header <- ._pr_escape(replace(header, is.na(header), "NA"))
  if (!is.null(footer)) footer <- ._pr_escape(replace(footer, is.na(footer), "NA"))
  if (any(nzchar(c(header, footer)))) {
    if (width < 5L) cli::cli_abort("The console must be at least five columns wide for box labels.")
    lines <- cli::ansi_align(lines, max(c(cli::ansi_nchar(lines, type = "width"), 3L - 2L * padding)))
  }
  box <- cli::boxx(
    lines,
    # boxx() already pads the header and footer with a space on each side
    header = if (is.null(header)) "" else cli::style_bold(header),
    footer = if (is.null(footer)) "" else cli::col_grey(footer),
    border_style = "round", border_col = col, padding = c(0, padding, 0, padding)
  )
  # a boxx is one string with embedded newlines
  ._pr_out(strsplit(as.character(box), "\n", fixed = TRUE)[[1]])
}

# ------------- pr_spark -----------------------------------------------------

#' One-line distribution of each column
#'
#' Print one line per column: its name, a sparkline of its distribution, a
#' short summary and the share of missing values, for a quick look at a
#' data set before modelling.
#'
#' Numeric columns show a histogram of \code{bins} equal-width bins over the
#' finite values, with their mean and SD (3 significant digits); whole
#' numbers with no more distinct values than \code{bins} get one bar per
#' value, so no empty bin falls between two values. Date and date-time
#' columns show the same histogram with their first and last dates. Factor,
#' character and logical columns show their level counts (in level order,
#' or the \code{bins} most frequent levels when there are more), the number
#' of levels and the most frequent one with its share of non-missing
#' values; one whose values all differ, such as an identifier, shows how many
#' there are. Other columns show their class only.
#' SPSS user-missing values are excluded from summaries and counted in the
#' missing share, consistently with ordinary missing values.
#' Small positive and near-complete missing shares use bounds when rounding
#' would hide the remaining missing or observed values.
#' Shorter scientific notation is used for extreme numeric summaries.
#' Centering and scaling retain finite spread at extreme magnitudes, and
#' narrow integer64 ranges retain their differences before double conversion.
#' Empty columns show \code{empty} with an unavailable missing share;
#' entirely missing columns and columns without finite values are identified
#' separately, without a most-frequent level or undefined percentage.
#' Lines that do not fit the console use a compact summary that retains the
#' missing share; long names and summary text are shortened with an ellipsis.
#' The default includes each column by position, even when names repeat.
#' Missing and empty column names display as \code{<NA>} and \code{""}.
#'
#' @param data A data frame (tibbles included).
#' @param vars Character. Columns to show; \code{NULL} (default) shows all.
#' @param bins Positive integer. Histogram bins, and the most levels drawn for a
#'   categorical column (default 12).
#' @param indent Non-negative integer. Spaces before each line (default 2).
#'   Must leave at least twelve console columns for the name and missing share.
#'
#' @return The printed lines, invisibly.
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(age = rnorm(200, 56, 11),
#'                  stage = factor(sample(c("I", "II", "III"), 200, TRUE)),
#'                  size_mm = rlnorm(200, 2.6, 0.5))
#' pr_spark(df)
#'
#' @export
#' @family print helpers
pr_spark <- function(data, vars = NULL, bins = 12, indent = 2) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_friendly {data}}.")
  }
  ._pr_count(bins, "bins", lower = 1L)
  ._pr_count(indent, "indent")
  columns <- if (is.null(vars)) seq_along(data) else match(vars, names(data))
  miss <- vars[is.na(columns)]
  if (length(miss)) {
    cli::cli_abort("{.arg vars} names column{?s} absent from {.arg data}: {.val {miss}}.")
  }
  if (!length(columns)) return(._pr_out(character()))
  if (console_width() - indent < 12L) {
    cli::cli_abort("{.arg indent} must leave at least twelve columns for the name and missing share.")
  }
  vars <- names(data)[columns]

  # equal-width bins, or one per value for few whole numbers
  bin <- function(x) {
    if (all(x == round(x))) {
      u <- unique(x)
      if (length(u) <= bins) {
        u <- sort(u)
        return(tabulate(match(x, u), nbins = length(u)))
      }
    }
    rng <- range(x)
    if (rng[1] == rng[2]) return(length(x))
    tabulate(findInterval(x, seq(rng[1], rng[2], length.out = bins + 1),
                          rightmost.closed = TRUE), nbins = bins)
  }
  spark <- function(counts) {
    if (!length(counts) || max(counts) == 0) return("")
    format(cli::spark_bar(as.numeric(counts) / max(counts)))
  }
  # 3 significant digits, trailing zeros kept, without formatC()'s padding
  sig3 <- function(z) {
    fixed <- trimws(formatC(z, digits = 3, format = "fg", flag = "#"))
    scientific <- trimws(formatC(z, digits = 2, format = "e"))
    ifelse(nchar(scientific) < nchar(fixed), scientific, fixed)
  }
  # one column -> c(sparkline, summary, missing share)
  one <- function(v) {
    v <- ._pr_restore(v)
    if (inherits(v, "POSIXlt")) v <- as.POSIXct(v)
    if (!length(v)) return(c("", "empty", "NA n/a"))
    missing <- if (is.expression(v)) is.na(as.list(v)) else is.na(v)
    percentage <- 100 * mean(missing)
    na <- sprintf("NA %.1f%%", percentage)
    if (percentage > 0 && na == "NA 0.0%") na <- "NA <0.1%"
    if (percentage < 100 && na == "NA 100.0%") na <- "NA >99.9%"
    if (all(missing)) return(c("", "all missing", na))
    if (inherits(v, c("Date", "POSIXct"))) {
      fin <- v[!missing & is.finite(v)]
      if (!length(fin)) return(c("", "no finite values", na))
      return(c(spark(bin(as.numeric(fin))),
               sprintf("%s to %s", format(min(fin)), format(max(fin))), na))
    }
    if (is.numeric(v)) {
      # classed numbers (integer64, labelled) as plain doubles: mean() of an
      # integer64 is an integer64, which formatC() writes as its raw bits
      num <- suppressWarnings(as.numeric(v))
      fin <- num[!missing & is.finite(num)]
      if (!length(fin)) return(c("", "no finite values", na))
      shape <- fin
      if (inherits(v, "integer64") && diff(range(fin)) <= 2^53) {
        observed <- v[!missing]
        shape <- suppressWarnings(as.numeric(observed - min(observed)))
      }
      counts <- bin(shape)
      spread <- stats::sd(shape)
      if (length(shape) > 1L && (!is.finite(spread) || (spread == 0 && any(shape != shape[1])))) {
        center <- min(shape) / 2 + max(shape) / 2
        shifted <- shape - center
        scale <- max(abs(shifted))
        if (scale > 0) spread <- stats::sd(shifted / scale) * scale
      }
      return(c(spark(counts),
               sprintf("mean %s  sd %s", sig3(mean(fin)), sig3(spread)), na))
    }
    if (is.factor(v) || is.character(v) || is.logical(v)) {
      # an identifier, every value different: count it rather than table() it
      # (0.1 s for 1e5 strings, drawn as a flat line of single counts)
      ok <- v[!missing]
      if (length(ok) > bins && !anyDuplicated(ok)) {
        return(c("", sprintf("%d unique values", length(ok)), na))
      }
      tab <- table(ok)
      if (!length(tab)) return(c("", "all missing", na))
      k   <- length(tab)
      top <- which.max(tab)
      lab <- names(tab)[top]
      if (is.na(lab)) lab <- "<NA>" else if (!nzchar(lab)) lab <- "\"\""
      lab <- ._pr_escape(lab)
      info <- sprintf("%d level%s \u00b7 top %s (%.1f%%)", k, if (k == 1L) "" else "s",
                      lab, 100 * tab[[top]] / sum(!missing))
      if (k > bins) tab <- sort(tab, decreasing = TRUE)[seq_len(bins)]
      return(c(spark(tab), info, na))
    }
    c("", paste0("<", ._pr_escape(class(v)[1]), ">"), na)
  }

  parts <- lapply(columns, function(j) one(data[[j]]))
  col   <- function(j) {
    x <- vapply(parts, `[`, "", j)
    cli::ansi_align(x, max(cli::ansi_nchar(x, type = "width")))
  }
  escaped <- ._pr_escape(vars)
  escaped[is.na(escaped)] <- "<NA>"
  escaped[!nzchar(escaped)] <- '""'
  name <- cli::ansi_align(escaped, max(cli::ansi_nchar(escaped, type = "width")))
  lines <- paste0(strrep(" ", indent), cli::style_bold(name), "  ",
                  cli::col_cyan(col(1)), "  ", col(2), "  ",
                  cli::col_grey(vapply(parts, `[`, "", 3)))
  wide <- which(cli::ansi_nchar(lines, type = "width") > console_width())
  for (i in wide) {
    tail <- parts[[i]][3]
    room <- max(1L, console_width() - indent - cli::ansi_nchar(tail, type = "width") - 2L)
    key <- ._pr_trim(escaped[i], max(1L, floor((room - 2L) / 3L)))
    prefix <- ._pr_trim(paste(cli::style_bold(key), parts[[i]][2]), room)
    lines[i] <- paste0(strrep(" ", indent), prefix, "  ", cli::col_grey(tail))
  }
  ._pr_out(lines)
}
