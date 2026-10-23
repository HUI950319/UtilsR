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
#
#   L2  shared internals
#         ._chip()       short label on a solid background (utils_display.R)
#         ._kv_lines()   named values -> aligned "key  value" lines
#         ._p_cells()    P values -> coloured cells (stat_pval() wording)
#         ._obj_desc()   object -> short "<type size>" description
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
#' \code{digits} decimals, or none when every value is whole. Missing values
#' print as a grey \code{NA}. Everything else uses \code{as.character()}.
#'
#' @param data A data frame (tibbles included).
#' @param p_col Character. Names of the P-value columns, or \code{NULL}.
#' @param highlight Rows to highlight in black on light yellow: integer row
#'   numbers or a logical vector. Highlighted rows drop their other colours.
#' @param align Column alignment, recycled: \code{"left"}, \code{"right"}
#'   or \code{"center"}. \code{NULL} (default) right-aligns numeric and
#'   P-value columns and left-aligns the rest.
#' @param digits Integer. Decimals for double columns (default 2).
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
pr_table <- function(data, p_col = NULL, highlight = NULL, align = NULL,
                     digits = 2, indent = 2) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_friendly {data}}.")
  }
  miss <- setdiff(p_col, names(data))
  if (length(miss)) {
    cli::cli_abort("{.arg p_col} names column{?s} absent from {.arg data}: {.val {miss}}.")
  }
  if (!ncol(data)) return(._pr_out(character()))
  data <- as.data.frame(data)

  is_num <- vapply(data, is.numeric, logical(1)) | names(data) %in% p_col
  cells  <- lapply(names(data), function(nm) {
    v <- data[[nm]]
    if (nm %in% p_col) return(._p_cells(v))
    if (is.double(v) && is.numeric(v)) {
      fin <- v[is.finite(v)]
      txt <- formatC(v, format = "f",
                     digits = if (all(fin == round(fin))) 0L else digits)
    } else {
      txt <- as.character(v)
    }
    ifelse(is.na(v), cli::col_grey("NA"), txt)
  })

  align <- if (is.null(align)) ifelse(is_num, "right", "left") else
    rep_len(match.arg(align, c("left", "right", "center"), several.ok = TRUE),
            ncol(data))
  width <- vapply(seq_along(cells), function(j) {
    max(cli::ansi_nchar(c(names(data)[j], cells[[j]]), type = "width"))
  }, numeric(1))
  row <- function(x) {
    paste(vapply(seq_along(x), function(j) {
      cli::ansi_align(x[[j]], width[j], align[j])
    }, character(1)), collapse = "  ")
  }

  pad    <- strrep(" ", indent)
  header <- paste0(pad, cli::style_bold(row(names(data))))
  rule   <- paste0(pad, cli::col_grey(strrep(cli::symbol$line,
                                             sum(width) + 2 * (length(width) - 1))))
  hl     <- if (is.logical(highlight)) which(highlight) else as.integer(highlight)
  hl_bg  <- cli::make_ansi_style("#FFFF99", bg = TRUE)
  body   <- vapply(seq_len(nrow(data)), function(i) {
    r <- row(lapply(cells, `[`, i))
    if (i %in% hl) r <- hl_bg(cli::col_black(cli::ansi_strip(r)))
    paste0(pad, r)
  }, character(1))
  ._pr_out(c(header, rule, body))
}

# ------------- pr_tree ------------------------------------------------------

# Short description of an object: "<tibble 12 x 7>", "<chr 3>", "<ggplot>";
# a length-1 atomic value is shown after its type, e.g. <chr> "cox".
._obj_desc <- function(v) {
  if (is.null(v)) return("<NULL>")
  cls <- class(v)[1]
  if (is.data.frame(v)) {
    lab <- if (inherits(v, "tbl_df")) "tibble" else cls
    return(sprintf("<%s %d x %d>", lab, nrow(v), ncol(v)))
  }
  if (!is.null(dim(v))) return(sprintf("<%s %s>", cls, paste(dim(v), collapse = " x ")))
  if (is.function(v)) return("<fn>")
  if (is.environment(v)) return("<env>")
  if (is.list(v)) {
    if (is.object(v) && !inherits(v, "list")) return(sprintf("<%s>", cls))
    return(sprintf("<%s %d>", if (is.object(v)) cls else "list", length(v)))
  }
  if (is.atomic(v)) {
    abbr <- if (is.factor(v)) "fct" else if (inherits(v, "Date")) "date" else
      if (inherits(v, "POSIXct")) "dttm" else
        switch(typeof(v), logical = "lgl", integer = "int", double = "dbl",
               character = "chr", complex = "cpl", typeof(v))
    if (length(v) != 1L) return(sprintf("<%s %d>", abbr, length(v)))
    val <- if (is.character(v)) encodeString(v, quote = "\"") else format(v)
    return(sprintf("<%s> %s", abbr, cli::ansi_strtrim(val, 30)))
  }
  sprintf("<%s>", cls)
}

#' Structure tree of a nested result object
#'
#' Print the elements of a list-based result as a tree, each with a short
#' grey description such as \code{<tibble 12 x 7>}, \code{<chr 3>} or
#' \code{<ggplot>}; clearer than \code{str()} for the nested lists that
#' analysis functions return.
#'
#' The tree descends into plain lists and into classed objects that also
#' inherit from \code{"list"} (as \code{c("eff_res", "list")} does). Data
#' frames, plots and other objects are leaves. Attributes other than
#' names, class, dimensions, row names and srcref are listed under the node
#' that carries them, marked \code{attr}.
#'
#' @param x A list or list-based object.
#' @param max_depth Integer. Levels below the root to show (default 3).
#' @param max_items Integer. Elements shown per node before the rest are
#'   summarised as "... n more" (default 20).
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
pr_tree <- function(x, max_depth = 3, max_items = 20, attrs = TRUE) {
  drop_attr <- c("names", "class", "dim", "dimnames", "row.names", "srcref")
  descend <- function(v) {
    is.list(v) && !is.data.frame(v) && (!is.object(v) || inherits(v, "list"))
  }
  rows <- new.env(parent = emptyenv())
  rows$id <- character(); rows$children <- list(); rows$label <- character()
  add <- function(id, label, children = character()) {
    rows$id       <- c(rows$id, id)
    rows$children <- c(rows$children, list(children))
    rows$label    <- c(rows$label, label)
    id
  }
  node <- function(v, id, label, depth) {
    kids <- character()
    if (depth < max_depth && descend(v)) {
      nm <- names(v) %||% rep("", length(v))
      nm <- ifelse(is.na(nm) | !nzchar(nm), sprintf("[[%d]]", seq_along(v)), nm)
      for (k in seq_len(min(length(v), max_items))) {
        kids <- c(kids, node(v[[k]], paste0(id, "/", k),
                             paste(nm[k], cli::col_grey(._obj_desc(v[[k]]))),
                             depth + 1))
      }
      if (length(v) > max_items) {
        kids <- c(kids, add(paste0(id, "/more"), cli::col_grey(sprintf(
          "%s %d more", cli::symbol$ellipsis, length(v) - max_items))))
      }
      if (isTRUE(attrs)) {
        for (a in setdiff(names(attributes(v)), drop_attr)) {
          kids <- c(kids, add(paste0(id, "/@", a), paste(
            cli::col_cyan("attr"), a,
            cli::col_grey(._obj_desc(attr(v, a, exact = TRUE))))))
        }
      }
    }
    add(id, label, kids)
  }

  root_desc <- if (descend(x)) sprintf("<list %d>", length(x)) else ._obj_desc(x)
  root <- node(x, "x", paste(._chip(class(x)[1], cli::bg_blue, cli::col_br_white),
                             cli::col_grey(root_desc)), 0)
  tree <- cli::tree(data.frame(id = rows$id, children = I(rows$children),
                               label = rows$label, stringsAsFactors = FALSE),
                    root = root)
  ._pr_out(as.character(tree))
}
