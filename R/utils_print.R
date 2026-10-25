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
  x    <- as.list(x)
  keep <- !vapply(x, is.null, logical(1))
  if (!any(keep)) return(character())
  keys <- keys[keep]
  vals <- vapply(x[keep], function(v) {
    if (!is.atomic(v)) return(._obj_desc(v))
    v <- as.character(v)
    if (length(v) > 20L) {
      v <- c(v[1:20], sprintf("%s (%d)", cli::symbol$ellipsis, length(v)))
    }
    paste(v, collapse = ", ")
  }, character(1), USE.NAMES = FALSE)
  kw    <- max(cli::ansi_nchar(keys, type = "width"))
  avail <- max(20, width - kw - 2)
  lead  <- strrep(" ", kw + 2)
  unlist(lapply(seq_along(keys), function(i) {
    segs <- strsplit(vals[[i]], "\n", fixed = TRUE)[[1]]
    body <- unlist(lapply(if (length(segs)) segs else "", function(s) {
      if (nzchar(s)) as.character(cli::ansi_strwrap(s, width = avail)) else ""
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
#'   passed as \code{if (cond) "text"}.
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
  parts <- as.character(unlist(list(...), use.names = FALSE))
  parts <- parts[!is.na(parts) & nzchar(parts)]
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
#' @param x A named list or named vector. \code{NULL} elements are dropped,
#'   so optional settings can be passed as they are; atomic values are
#'   joined with \code{", "} (the first 20 items, then the count) and
#'   other objects are described by type and size, e.g.
#'   \code{<data.frame 6 x 11>} or \code{<lm>}. Long values
#'   wrap at the console width under the value column, as do the lines of a
#'   value that contains newlines.
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
#' @param width Integer. Rule width in characters; \code{NULL} (default) uses
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
  width <- width %||% min(console_width(), 80L)
  # keep two line characters on each side of the title
  title <- cli::ansi_strtrim(title, max(10L, width - 6L))
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
#' Long notes wrap at the console width, every line starting with \code{#}.
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
  text <- tryCatch(cli::format_inline(raw, .envir = .envir),
                   error = function(e) raw)
  body <- cli::ansi_strwrap(text, width = max(20, console_width() - 2))
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
#'   lengths, or length 1). Values are converted with \code{as.character()}.
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
  n <- max(length(key), length(value))
  if (!all(c(length(key), length(value)) %in% c(1L, n))) {
    cli::cli_abort("{.arg key} and {.arg value} must have the same length, or length 1.")
  }
  if (!._pr_colour()) {
    return(sprintf("[%s: %s]", rep_len(as.character(key), n),
                   rep_len(as.character(value), n)))
  }
  white <- cli::make_ansi_style("br_white")
  paste0(._chip(rep_len(as.character(key), n),
                cli::make_ansi_style("grey30", bg = TRUE), white),
         ._chip(rep_len(as.character(value), n),
                cli::make_ansi_style(bg, bg = TRUE), cli::make_ansi_style(fg)))
}

# ------------- pr_table -----------------------------------------------------

# P values -> cells: numbers take stat_pval()'s "<0.001" wording, text keeps
# its own; bold red below 0.001, red below 0.05, grey otherwise. A bound such
# as "<0.05" counts as below its endpoint.
._p_cells <- function(v) {
  if (is.numeric(v)) {
    num <- v
    txt <- stat_pval(v, mode = "pvalue")
    below <- rep(FALSE, length(v))
  } else {
    txt   <- trimws(as.character(v))
    num   <- suppressWarnings(as.numeric(sub("^[<>]=?\\s*", "", txt)))
    below <- grepl("^<", txt)
  }
  strong <- !is.na(num) & (num < 0.001 | (below & num <= 0.001))
  sig    <- !is.na(num) & !strong & (num < 0.05 | (below & num <= 0.05))
  # without colour, stars carry the significance instead
  if (!._pr_colour()) {
    two <- sig & (num < 0.01 | (below & num <= 0.01))
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
#' text is kept as written, and values print bold red below 0.001, red below
#' 0.05 and grey otherwise. Other double columns are rounded to
#' \code{digits} decimals, or none when every value is whole; a column whose
#' smallest non-zero value would round to zero gets enough decimals for two
#' significant digits, at most six. Missing values
#' print as a grey \code{NA}. Everything else uses \code{as.character()}.
#' Without colour (knitted documents, log files), P values carry stars
#' (\code{***} below 0.001, \code{**} below 0.01, \code{*} below 0.05),
#' highlighted rows start with \code{>} and missing text cells read
#' \code{<NA>}.
#'
#' @param data A data frame (tibbles included).
#' @param p_col Character. Names of the P-value columns, or \code{NULL}.
#' @param highlight Rows to highlight in black on light yellow: integer row
#'   numbers or a logical vector. Highlighted rows drop their other colours.
#' @param n Integer. Rows to show (default 20); the rest are counted in a
#'   grey footer. \code{NULL} shows every row.
#' @param align Column alignment, recycled: \code{"left"}, \code{"right"}
#'   or \code{"center"}. \code{NULL} (default) right-aligns numeric and
#'   P-value columns and left-aligns the rest.
#' @param digits Integer. Decimals for double columns (default 2).
#' @param width Integer. Line width the table must fit; \code{NULL}
#'   (default) uses the console width. The first column and the P-value
#'   columns always show; the other columns follow in order while they fit,
#'   and the footer names those left out.
#' @param indent Integer. Spaces before each line (default 2).
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
pr_table <- function(data, p_col = NULL, highlight = NULL, n = 20, align = NULL,
                     digits = 2, width = NULL, indent = 2) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_friendly {data}}.")
  }
  miss <- setdiff(p_col, names(data))
  if (length(miss)) {
    cli::cli_abort("{.arg p_col} names column{?s} absent from {.arg data}: {.val {miss}}.")
  }
  if (!ncol(data)) return(._pr_out(character()))
  data   <- as.data.frame(data)
  n_rows <- nrow(data)
  if (!is.null(n) && n_rows > n) data <- data[seq_len(n), , drop = FALSE]

  is_num <- vapply(data, is.numeric, logical(1)) | names(data) %in% p_col
  colour <- ._pr_colour()
  cells  <- lapply(names(data), function(nm) {
    v <- data[[nm]]
    if (nm %in% p_col) return(._p_cells(v))
    if (is.double(v) && is.numeric(v)) {
      fin  <- v[is.finite(v)]
      d    <- if (all(fin == round(fin))) 0L else digits
      # 0.0003 would print as 0.00: give the column two significant digits
      tiny <- abs(fin[fin != 0])
      if (d > 0L && length(tiny) && min(tiny) < 0.5 * 10^-d) {
        d <- min(6L, as.integer(ceiling(-log10(min(tiny)))) + 1L)
      }
      txt <- formatC(v, format = "f", digits = d)
    } else {
      txt <- as.character(v)
    }
    ifelse(is.na(v), if (!colour && !is.numeric(v)) "<NA>" else cli::col_grey("NA"),
           txt)
  })

  align <- if (is.null(align)) ifelse(is_num, "right", "left") else
    rep_len(match.arg(align, c("left", "right", "center"), several.ok = TRUE),
            ncol(data))
  col_w <- vapply(seq_along(cells), function(j) {
    max(cli::ansi_nchar(c(names(data)[j], cells[[j]]), type = "width"))
  }, numeric(1))
  # the first and the P-value columns always show; the others follow in
  # order until one no longer fits the line
  avail <- (width %||% console_width()) - indent
  keep  <- unique(c(1L, which(names(data) %in% p_col)))
  for (j in setdiff(seq_along(cells), keep)) {
    if (sum(col_w[c(keep, j)]) + 2 * length(keep) > avail) break
    keep <- c(keep, j)
  }
  keep <- sort(keep)
  row <- function(x) {
    paste(vapply(keep, function(j) {
      cli::ansi_align(x[[j]], col_w[j], align[j])
    }, character(1)), collapse = "  ")
  }

  pad    <- strrep(" ", indent)
  header <- paste0(pad, cli::style_bold(row(names(data))))
  rule   <- paste0(pad, cli::col_grey(strrep(cli::symbol$line,
                                             sum(col_w[keep]) + 2 * (length(keep) - 1))))
  hl     <- if (is.logical(highlight)) which(highlight) else as.integer(highlight)
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
                                        toString(names(data)[dropped])))
  if (length(foot)) {
    foot <- paste0(pad, cli::col_grey(cli::ansi_strwrap(
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
# (the first 10 values, cut at 40 characters).
._obj_desc <- function(v) {
  if (is.null(v)) return("<NULL>")
  # a POSIXlt time is a list underneath; show the time it holds
  if (inherits(v, "POSIXlt")) v <- as.POSIXct(v)
  cls <- class(v)[1]
  if (is.data.frame(v)) {
    lab <- if (inherits(v, "tbl_df")) "tibble" else cls
    return(sprintf("<%s %d x %d>", lab, nrow(v), ncol(v)))
  }
  if (!is.null(dim(v))) return(sprintf("<%s %s>", cls, paste(dim(v), collapse = " x ")))
  if (is.function(v)) return("<fn>")
  # a classed environment, such as an R6 learner, is named by its class
  if (is.environment(v)) return(if (is.object(v)) sprintf("<%s>", cls) else "<env>")
  if (is.list(v)) {
    if (is.object(v) && (!inherits(v, "list") || inherits(v, ._tree_leaf))) {
      return(sprintf("<%s>", cls))
    }
    return(sprintf("<%s %d>", if (is.object(v)) cls else "list", length(v)))
  }
  if (is.atomic(v)) {
    # vctrs names classed vectors as well: drtn, dbl+lbl, int64, ord
    abbr <- tryCatch(vctrs::vec_ptype_abbr(v), error = function(e) typeof(v))
    first <- utils::head(v, 10L)
    vals <- if (is.character(first) || is.factor(first)) {
      encodeString(as.character(first), quote = "\"")
    } else if (is.integer(first) && !is.object(first)) {
      as.character(first)
    } else if (is.numeric(first) && !is.object(first)) {
      # format() keeps the integer part, which signif() rounded (1234.5678
      # showed as 1230, 123456L as 123000)
      vapply(first, format, character(1), digits = 3)
    } else {
      vapply(seq_along(first), function(i) format(first[i]), character(1))
    }
    if (!length(vals)) return(sprintf("<%s 0>", abbr))
    preview <- cli::ansi_strtrim(paste(vals, collapse = ", "), 40)
    if (length(v) == 1L) return(sprintf("<%s> %s", abbr, preview))
    return(sprintf("<%s %d> %s", abbr, length(v), preview))
  }
  sprintf("<%s>", cls)
}

#' Structure tree of a nested result object
#'
#' Print the elements of a list-based result as a tree, each with a short
#' grey description such as \code{<tibble 12 x 7>},
#' \code{<chr 3> "Age", "Sex", "Stage"} or \code{<ggplot>}; clearer than
#' \code{str()} for the nested lists that analysis functions return. Atomic
#' vectors show their first values, and a list left unopened at
#' \code{max_depth} is marked with an ellipsis.
#'
#' The tree descends into plain lists and into classed objects that also
#' inherit from \code{"list"} (as \code{c("eff_res", "list")} does). Data
#' frames, plots and other objects are leaves, and so are gt tables, RegR
#' pages and htmltools tag lists, which are lists underneath; R6 and other
#' classed environments show their class. Attributes other than
#' names, class, dimensions, row names and srcref are listed under the node
#' that carries them, marked \code{attr}.
#'
#' @param x A list or list-based object.
#' @param max_depth Integer. Levels below the root to show (default 3).
#' @param max_items Integer. Elements shown per node before the rest are
#'   summarised as "... n more" (default 20).
#' @param max_lines Integer. Lines shown in all (default 200); a grey footer
#'   counts the rest.
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
  drop_attr <- c("names", "class", "dim", "dimnames", "row.names", "srcref")
  descend <- function(v) {
    is.list(v) && !is.data.frame(v) && !inherits(v, ._tree_leaf) &&
      (!is.object(v) || inherits(v, "list"))
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
    if (depth < max_depth && descend(v)) {
      nm <- names(v) %||% rep("", length(v))
      nm <- ifelse(is.na(nm) | !nzchar(nm), sprintf("[[%d]]", seq_along(v)), nm)
      for (k in seq_len(min(length(v), max_items))) {
        child <- v[[k]]
        h <- slot(shown)
        child_label <- ""
        if (h == "show") {
          child_label <- paste(nm[k], cli::col_grey(._obj_desc(child)))
          # a list left unopened at max_depth
          if (depth + 1 >= max_depth && descend(child) && length(child)) {
            child_label <- paste(child_label, cli::col_grey(cli::symbol$ellipsis))
          }
        }
        kid <- node(child, paste0(id, "/", k), child_label, depth + 1, h)
        if (h != "count") kids <- c(kids, kid)
      }
      if (length(v) > max_items) {
        h <- slot(shown)
        if (h != "count") kids <- c(kids, add(paste0(id, "/more"), if (h == "show") {
          cli::col_grey(sprintf("%s %d more", cli::symbol$ellipsis, length(v) - max_items))
        } else ""))
      }
      if (isTRUE(attrs)) {
        for (a in setdiff(names(attributes(v)), drop_attr)) {
          h <- slot(shown)
          if (h != "count") kids <- c(kids, add(paste0(id, "/@", a), if (h == "show") {
            paste(cli::col_cyan("attr"), a,
                  cli::col_grey(._obj_desc(attr(v, a, exact = TRUE))))
          } else ""))
        }
      }
    }
    if (how != "count") add(id, label, kids) else id
  }

  root_desc <- if (descend(x)) sprintf("<list %d>", length(x)) else ._obj_desc(x)
  root <- node(x, "x", paste(._pr_label(class(x)[1], cli::bg_blue, cli::col_br_white),
                             cli::col_grey(root_desc)), 0, slot(TRUE))
  tree <- as.character(cli::tree(data.frame(id = rows$id, children = I(rows$children),
                                            label = rows$label,
                                            stringsAsFactors = FALSE),
                                 root = root))
  if (rows$n > max_lines) {
    tree <- c(tree[seq_len(max_lines)], cli::col_grey(sprintf(
      "# %s %d more lines", cli::symbol$ellipsis, rows$n - max_lines)))
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
#'   line by line.
#' @param header,footer Character, or \code{NULL} for none. Text set into
#'   the top and bottom border.
#' @param col Border colour: anything \code{cli::make_ansi_style()} accepts
#'   (default \code{"cyan"}).
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
  # the borders and their padding take 6 columns
  avail <- console_width() - 6
  lines <- if (is.character(x) && is.null(names(x))) {
    unlist(lapply(x, function(s) as.character(cli::ansi_strwrap(s, width = avail))))
  } else {
    ._kv_lines(x, width = avail)
  }
  # cli::boxx() fails on no lines; an empty settings list prints nothing
  if (!length(lines)) return(._pr_out(character()))
  box <- cli::boxx(
    lines,
    # boxx() already pads the header and footer with a space on each side
    header = if (is.null(header)) "" else cli::style_bold(header),
    footer = if (is.null(footer)) "" else cli::col_grey(footer),
    border_style = "round", border_col = col, padding = c(0, 2, 0, 2)
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
#' values. Other columns show their class only.
#'
#' @param data A data frame (tibbles included).
#' @param vars Character. Columns to show; \code{NULL} (default) shows all.
#' @param bins Integer. Histogram bins, and the most levels drawn for a
#'   categorical column (default 12).
#' @param indent Integer. Spaces before each line (default 2).
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
  vars <- vars %||% names(data)
  miss <- setdiff(vars, names(data))
  if (length(miss)) {
    cli::cli_abort("{.arg vars} names column{?s} absent from {.arg data}: {.val {miss}}.")
  }
  if (!length(vars)) return(._pr_out(character()))

  # equal-width bins, or one per value for few whole numbers
  bin <- function(x) {
    u <- sort(unique(x))
    if (all(x == round(x)) && length(u) <= bins) {
      return(tabulate(match(x, u), nbins = length(u)))
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
  sig3 <- function(z) trimws(formatC(z, digits = 3, format = "fg", flag = "#"))
  # one column -> c(sparkline, summary, missing share)
  one <- function(v) {
    na <- sprintf("NA %.1f%%", 100 * mean(is.na(v)))
    if (inherits(v, c("Date", "POSIXct"))) {
      fin <- v[is.finite(v)]
      if (!length(fin)) return(c("", "all missing", na))
      return(c(spark(bin(as.numeric(fin))),
               sprintf("%s to %s", format(min(fin)), format(max(fin))), na))
    }
    if (is.numeric(v)) {
      fin <- v[is.finite(v)]
      if (!length(fin)) return(c("", "all missing", na))
      counts <- bin(fin)
      return(c(spark(counts),
               sprintf("mean %s  sd %s", sig3(mean(fin)), sig3(stats::sd(fin))), na))
    }
    if (is.factor(v) || is.character(v) || is.logical(v)) {
      tab <- table(v)
      if (!length(tab)) return(c("", "all missing", na))
      k   <- length(tab)
      top <- which.max(tab)
      lab <- names(tab)[top]
      if (!nzchar(lab)) lab <- "\"\""
      info <- sprintf("%d level%s \u00b7 top %s (%.1f%%)", k, if (k == 1L) "" else "s",
                      lab, 100 * tab[[top]] / sum(!is.na(v)))
      if (k > bins) tab <- sort(tab, decreasing = TRUE)[seq_len(bins)]
      return(c(spark(tab), info, na))
    }
    c("", paste0("<", class(v)[1], ">"), na)
  }

  parts <- lapply(vars, function(nm) one(data[[nm]]))
  col   <- function(j) {
    x <- vapply(parts, `[`, "", j)
    cli::ansi_align(x, max(cli::ansi_nchar(x, type = "width")))
  }
  name <- cli::ansi_align(vars, max(cli::ansi_nchar(vars, type = "width")))
  lines <- paste0(strrep(" ", indent), cli::style_bold(name), "  ",
                  cli::col_cyan(col(1)), "  ", col(2), "  ",
                  cli::col_grey(vapply(parts, `[`, "", 3)))
  ._pr_out(lines)
}
