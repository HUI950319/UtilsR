# =============================================================================
# utils_display.R -- Console display helpers
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  styled console output                       -- public API
#         .cat_line(text, type, ...)       separator rule with a label
#         .cat_box(cat_text, type, ...)    boxed notice
#         .cat_message(message, type)      timestamped log line
#         .cat_saved(subject, path, ...)   saved-file notice with size and
#                                          whether an earlier copy was
#                                          replaced
#               +-- .cat_message()
#         .cat_step(msg, i, n)             numbered step, timed when it ends
#         .cat_formula(data, co_var, ...)  model and formula in one notice
#               +-- .cat_message()
#         .cat_tb(...)                     table with pattern highlighting
#         show_color(x, rev)               colour swatches in the console
#
#   L2  shared internals
#         ._type_cfg()     type -> symbol / colour
#         ._cli_bg()       type -> cli background style
#         ._cli_fg()       type -> cli text colour on that background
#         ._chip()         short bold label on a solid background
#         console_width()  terminal width, with a fallback
# =============================================================================

# ------------- Shared internals ---------------------------------------------

# Type configuration: symbol and colour
._type_cfg <- function(type = c("info", "success", "warning", "error")) {
  type <- match.arg(type)
  cfg <- list(
    info    = list(symbol = "\u2139", col = "cyan"),
    success = list(symbol = "\u2713", col = "green"),
    warning = list(symbol = "\u26A0", col = "yellow"),
    error   = list(symbol = "\u2717", col = "red")
  )
  c(cfg[[type]], list(type = type))
}

# cli bg colour function by type
._cli_bg <- function(type) {
  switch(type,
    info    = cli::bg_cyan,
    success = cli::bg_green,
    warning = cli::bg_yellow,
    error   = cli::bg_red
  )
}

# cli text colour by type: black on the yellow warning background, where
# white text has too little contrast; bright white on the other backgrounds
._cli_fg <- function(type) {
  if (identical(type, "warning")) cli::col_black else cli::col_br_white
}

# Short bold label on a solid background, padded by one space on each side.
# `bg` and `fg` are cli ANSI style functions.
._chip <- function(text, bg, fg) {
  cli::combine_ansi_styles(bg, fg, "bold")(paste0(" ", text, " "))
}

# ------------- console_width ------------------------------------------------

#' Get console width
#' @return Integer console width.
#' @keywords internal
console_width <- function() {
  tryCatch(cli::console_width(), error = function(e) getOption("width", 80L))
}

# ------------- .cat_line ----------------------------------------------------

#' Styled separator line
#'
#' Print a coloured rule with centred text and type-specific symbol.
#'
#' @param text Character. Text to display.
#' @param type One of \code{"info"}, \code{"success"}, \code{"warning"},
#'   \code{"error"}.
#' @param line_char Character used for the rule (default \code{"="}).
#' @param width Total width (default: console width).
#'
#' @examples
#' .cat_line("Data summary", width = 40)
#'
#' @export
#' @family console display
.cat_line <- function(text,
                      type = c("info", "success", "warning", "error"),
                      line_char = "=",
                      width = console_width()) {
  ._pr_count(width, "width", lower = 1L)
  if (!is.character(line_char) || !is.null(dim(line_char)) || length(line_char) != 1L ||
      is.na(line_char) || !nzchar(line_char) || cli::ansi_nchar(line_char, type = "width") < 1L)
    cli::cli_abort("{.arg line_char} must be a single non-empty visible string.")
  if (length(text) != 1L || !is.null(dim(text)))
    cli::cli_abort("{.arg text} must contain one label without dimensions.")
  cfg <- ._type_cfg(match.arg(type))
  label <- paste(cfg$symbol, text, cfg$symbol)

  # no hand-written ANSI fallback: cli copes with any width (2026-10-25)
  bg <- ._cli_bg(cfg$type)
  styled <- cli::style_bold(._cli_fg(cfg$type)(label))
  cli::cat_rule(
    center   = bg(paste(" ", styled, " ")),
    line     = line_char,
    line_col = cfg$col,
    width    = width
  )
  invisible()
}

# ------------- .cat_box ----------------------------------------------------

#' Styled info box
#'
#' Print a rounded box with type-coloured border and background.
#' The box is a cli message and is silenced by \code{suppressMessages()}.
#'
#' @param cat_text Character. Text to display.
#' @param type One of \code{"info"}, \code{"success"}, \code{"warning"},
#'   \code{"error"}.
#'
#' @examples
#' .cat_box("Completed", type = "success")
#'
#' @export
#' @family console display
.cat_box <- function(cat_text,
                     type = c("info", "success", "warning", "error")) {
  cfg <- ._type_cfg(match.arg(type))
  cat_text <- gsub("\r\n", "\n", as.character(cat_text), fixed = TRUE)
  cat_text <- unlist(cli::ansi_strsplit(paste0(cat_text, "\n"), "\n", fixed = TRUE),
                     use.names = FALSE)
  label <- paste(cfg$symbol, cat_text, cfg$symbol)

  bg <- ._cli_bg(cfg$type)
  styled <- cli::style_bold(bg(._cli_fg(cfg$type)(label)))
  cli::cli_verbatim(cli::boxx(
    styled,
    padding      = 1,
    border_style = "round",
    float        = "center",
    align        = "center",
    border_col   = cfg$col,
    background_col = paste0("bg_", cfg$col)
  ))
  invisible()
}

# ------------- .cat_message -------------------------------------------------

#' Styled log message with timestamp
#'
#' Print a timestamped, type-coloured message. Supports multi-line messages
#' (split on \code{"\\n"}); lines longer than the console wrap, the
#' continuation lines starting under the text, unless \code{wrap = FALSE}.
#'
#' The message is a cli message, like those of \code{cli::cli_inform()}:
#' \code{suppressMessages()} silences it, and it is written to standard output
#' in interactive sessions and to standard error otherwise. The text is shown
#' verbatim, so braces are not interpolated.
#'
#' @param message Character. The message text: each element starts a new
#'   line, as does each \code{"\\n"}; a zero-length message prints nothing.
#' @param type One of \code{"info"}, \code{"success"}, \code{"warning"},
#'   \code{"error"}.
#' @param timestamp_format \code{strftime} format string (default
#'   \code{"[\%Y-\%m-\%d \%H:\%M:\%S]"}); \code{NULL} or \code{""} leaves
#'   the timestamp out.
#' @param style \code{"full"} (default) shades the whole message in the type
#'   colour after a magenta timestamp. \code{"chip"} prints the timestamp in
#'   grey and colours only a short type label (\code{INFO}, \code{DONE},
#'   \code{WARN}, \code{FAIL}), leaving the text plain.
#' @param wrap Logical. \code{FALSE} keeps every line whole, for a line
#'   meant to be copied, such as a call: wrapping would break it, or a
#'   string in it, across lines.
#' @param verbose Logical. If \code{FALSE}, suppress output.
#'
#' @examples
#' .cat_message("Loading simulated data", verbose = FALSE)
#' .cat_message("Saved forest.pdf", type = "success", style = "chip")
#'
#' @export
#' @family console display
.cat_message <- function(message,
                         type = c("info", "success", "warning", "error"),
                         timestamp_format = "[%Y-%m-%d %H:%M:%S]",
                         style = c("full", "chip"),
                         wrap = TRUE,
                         verbose = TRUE) {
  if (!is.logical(verbose) || !is.null(dim(verbose)) || length(verbose) != 1L || is.na(verbose))
    cli::cli_abort("{.arg verbose} must be TRUE or FALSE.")
  if (!verbose) return(invisible())
  if (!is.logical(wrap) || !is.null(dim(wrap)) || length(wrap) != 1L || is.na(wrap))
    cli::cli_abort("{.arg wrap} must be TRUE or FALSE.")
  if (!is.null(timestamp_format) && (!is.character(timestamp_format) ||
      !is.null(dim(timestamp_format)) || length(timestamp_format) != 1L || is.na(timestamp_format)))
    cli::cli_abort("{.arg timestamp_format} must be NULL or one non-missing format string.")
  if (!length(message)) return(invisible())
  cfg   <- ._type_cfg(match.arg(type))
  style <- match.arg(style)
  # Every element occupies at least one line, including "".
  lines <- as.character(message)
  lines[is.na(lines)] <- "NA"
  if (any(grepl("\n", lines, fixed = TRUE))) {
    lines <- gsub("\r\n", "\n", lines, fixed = TRUE)
    lines <- unlist(strsplit(paste0(lines, "\n"), "\n", fixed = TRUE), use.names = FALSE)
  }
  # format(x, "") would fall back to R's default format, not drop the stamp
  ts    <- if (is.null(timestamp_format) || !nzchar(timestamp_format)) "" else
    format(Sys.time(), timestamp_format)
  # columns the timestamp takes with the space after it
  ts_width <- cli::ansi_nchar(ts, type = "width")
  ts_w  <- if (nzchar(ts)) ts_width + 1L else 0L
  # wrap at the console width, less the timestamp and the label or symbol
  if (wrap) {
    avail <- max(1, console_width() - ts_width - if (style == "chip") 10 else 6)
    lines <- unlist(lapply(lines, function(l) {
      if (nzchar(l)) ._pr_wrap(l, avail) else l
    }))
  }

  bg    <- ._cli_bg(cfg$type)
  fg    <- ._cli_fg(cfg$type)
  ts_col <- if (nzchar(ts)) paste0(cli::col_magenta(ts), " ") else ""

  if (style == "chip") {
    label <- c(info = "INFO", success = "DONE",
               warning = "WARN", error = "FAIL")[[cfg$type]]
    lead  <- paste0(if (nzchar(ts)) paste0(cli::col_grey(ts), " "),
                    ._chip(label, bg, fg), " ")
    # continuation lines start under the text: timestamp, space, chip, space
    out   <- paste0(c(lead, rep(strrep(" ", ts_w + nchar(label) + 3),
                                length(lines) - 1L)), lines)
  } else {
    body <- paste0(" ", cli::style_bold(fg(lines)), " ")
    body[1L] <- paste0(" ", cli::style_bold(fg(cfg$symbol)), body[1L])
    prefix <- c(ts_col, rep(strrep(" ", ts_w + 2L), length(lines) - 1L))
    out <- paste0(prefix, bg(body))
  }
  # A cli message rather than cat(), so suppressMessages() silences it;
  # cli_verbatim() keeps the text as is, without glue interpolation.
  cli::cli_verbatim(out)
  invisible()
}

# ------------- .cat_saved ---------------------------------------------------

#' Announce a saved file with its size and whether it replaced one
#'
#' One notice for every function that writes a file, in the shape
#' \code{<subject>: <path> [<size>, new <kind>]}, or
#' \code{<subject>: <path> [<size>, replaced the existing <kind>]} with the
#' replacement marker in red. Measure \code{existed} before the file is
#' written, since writing creates it. The notice is a
#' \code{\link{.cat_message}()}, so \code{suppressMessages()} silences it.
#'
#' @param subject Character. Leading clause, starting with the function name,
#'   e.g. \code{"PlotRank: the plot has been saved to"}.
#' @param path Character. Output file path, printed verbatim.
#' @param size Character. Size with its unit, e.g. \code{"12x10 in"} or
#'   \code{"12x5 cells"}.
#' @param existed Logical. \code{TRUE} when a file already occupied
#'   \code{path}.
#' @param kind Character. Output format shown in the marker, e.g.
#'   \code{"PDF"} or \code{"DOCX"}.
#'
#' @examples
#' path <- tempfile(fileext = ".pdf")
#' .cat_saved("the plot has been saved to", path, "7x5 in",
#'            file.exists(path), "PDF")
#'
#' @export
#' @family console display
.cat_saved <- function(subject, path, size, existed, kind) {
  if (!is.logical(existed) || !is.null(dim(existed)) || length(existed) != 1L || is.na(existed))
    cli::cli_abort("{.arg existed} must be TRUE or FALSE.")
  for (arg in c("subject", "path", "size", "kind")) {
    value <- get(arg)
    if (length(value) != 1L || !is.null(dim(value)))
      cli::cli_abort("{.arg {arg}} must contain one value without dimensions.")
  }
  # col_br_red() degrades to plain text when the console has no colour, so
  # the marker stays readable in logs and in captured output
  status <- if (isTRUE(existed)) {
    cli::col_br_red(sprintf("replaced the existing %s", kind))
  } else {
    sprintf("new %s", kind)
  }
  .cat_message(sprintf("%s: %s [%s, %s]", subject, path, size, status))
}

# ------------- .cat_step ----------------------------------------------------

#' Numbered, timed progress step
#'
#' Announce one step of a longer computation. The step is marked done, with
#' its elapsed time, when the next step starts or when the calling function
#' returns; an error marks it failed. A wrapper of
#' \code{cli::cli_progress_step()} that numbers steps and honours
#' \code{verbose}.
#'
#' @param msg Character. Step description. cli inline markup and glue
#'   interpolation are evaluated in \code{.envir}, so \code{"Fitting {n}
#'   models"} picks up \code{n} from the caller. Text that cli cannot parse,
#'   such as data that contains braces, is shown as written.
#' @param i,n Optional step number and total, shown as a grey \code{[i/n]}
#'   prefix (\code{[i]} when \code{n} is \code{NULL}).
#' @param msg_done Character. Text shown when the step completes; defaults
#'   to \code{msg}. It takes the same prefix.
#' @param verbose Logical. If \code{FALSE}, print nothing.
#' @param .envir Environment whose exit ends the step and in which
#'   \code{msg} is interpolated. Defaults to the caller of \code{.cat_step()};
#'   a helper that calls \code{.cat_step()} for its own caller passes its
#'   \code{parent.frame()}.
#'
#' @return The cli progress bar id, invisibly (\code{NULL} when
#'   \code{verbose = FALSE}).
#'
#' @examples
#' fit_all <- function() {
#'   .cat_step("Fitting models", i = 1, n = 2)
#'   Sys.sleep(0.1)
#'   .cat_step("Drawing plot", i = 2, n = 2, msg_done = "Drew plot")
#'   invisible()
#' }
#' fit_all()
#'
#' @export
#' @family console display
.cat_step <- function(msg, i = NULL, n = NULL, msg_done = msg,
                      verbose = TRUE, .envir = parent.frame()) {
  if (!is.logical(verbose) || length(verbose) != 1L ||
      !is.null(dim(verbose)) || is.na(verbose)) {
    cli::cli_abort("{.arg verbose} must be TRUE or FALSE.")
  }
  if (!verbose) return(invisible(NULL))
  if (!is.environment(.envir)) cli::cli_abort("{.arg .envir} must be an environment.")
  ._pr_count(i, "i", null = TRUE)
  ._pr_count(n, "n", null = TRUE)
  # force the default before `msg` gains its prefix, or it would get two
  force(msg_done)
  # text cli cannot parse (data with braces) is shown as written; cli would
  # otherwise fail inside the deferred on.exit() that closes the step
  as_written <- function(s) {
    if (is.character(s) && !any(grepl("[{}]", s))) return(s)
    ok <- tryCatch({ cli::format_inline(s, .envir = .envir); TRUE },
                   error = function(e) FALSE)
    if (ok) s else gsub("([{}])", "\\1\\1", s)
  }
  msg      <- as_written(msg)
  msg_done <- as_written(msg_done)
  if (!is.null(i)) {
    num <- if (is.null(n)) sprintf("[%.0f]", i) else
      sprintf("[%.0f/%.0f]", i, n)
    msg      <- paste(cli::col_grey(num), msg)
    msg_done <- paste(cli::col_grey(num), msg_done)
  }
  invisible(cli::cli_progress_step(msg, msg_done = msg_done, msg_failed = msg,
                                   .envir = .envir))
}

# ------------- .cat_formula -------------------------------------------------

#' Announce a model and its formula
#'
#' One \code{\link{.cat_message}()} line naming the model (Cox, CRR or
#' logistic), whether it is adjusted, and its formula, e.g.
#' \code{Cox model, unadjusted: Surv(time, DSS) ~ Sex}. The model type comes
#' from the number of distinct non-missing outcome values and whether there
#' is a time variable. \code{suppressMessages()} silences it.
#'
#' For survival models, SPSS user-missing codes and ranges in
#' \code{haven_labelled_spss} outcomes are excluded before counting values.
#' This requires the optional \pkg{haven} package, including for outcomes
#' restored from serialized files. Non-syntactic column names are quoted and
#' escaped as R names. The notice is not wrapped, preserving whitespace
#' within column names even on a narrow console.
#'
#' @param data A data.frame containing the outcome column.
#' @param co_var Character vector of covariate names.
#' @param time Character or \code{NULL}. Name of the time variable
#'   (\code{NULL} for logistic models).
#' @param outcome Character. Name of the outcome variable (default
#'   \code{"DSS"}).
#' @param type One of \code{"info"}, \code{"success"}, \code{"warning"},
#'   \code{"error"}.
#'
#' @return \code{NULL}, invisibly.
#'
#' @examples
#' formula_data <- data.frame(
#'   DSS = c(0, 1, 1, 0),
#'   time = c(5, 8, 12, 15),
#'   age = c(45, 52, 61, 39)
#' )
#' .cat_formula(formula_data, co_var = "age")
#' names(formula_data)[1:2] <- c("event status", "follow up")
#' .cat_formula(formula_data, co_var = "age", time = "follow up",
#'              outcome = "event status")
#'
#' @export
#' @family console display
.cat_formula <- function(data, co_var, time = "time", outcome = "DSS",
                         type = c("info", "success", "warning", "error")) {
  type <- match.arg(type)
  for (arg in c("time", "outcome")) {
    value <- get(arg)
    if (arg == "time" && is.null(value)) next
    if (!is.character(value) || !is.null(dim(value)) || length(value) != 1L ||
        is.na(value) || !nzchar(value))
      cli::cli_abort("{.arg {arg}} must be one non-missing, non-empty column name.")
  }
  if (!is.null(co_var) && (!is.character(co_var) || !is.null(dim(co_var)) ||
      anyNA(co_var) || any(!nzchar(co_var))))
    cli::cli_abort("{.arg co_var} must be a character vector of non-missing, non-empty column names.")
  adj  <- if (length(co_var) <= 1L) "unadjusted" else "adjusted"
  quote_names <- function(x) {
    vapply(x, function(nm) deparse1(as.name(nm), backtick = TRUE),
           character(1L), USE.NAMES = FALSE)
  }
  rhs  <- if (length(co_var)) paste(quote_names(co_var), collapse = " + ") else "1"
  # one line in place of a box and a rule, nine lines per model (2026-10-25)
  if (is.null(time)) {
    model   <- "Logistic"
    formula <- sprintf("%s ~ %s", quote_names(outcome), rhs)
  } else {
    # a missing outcome is not a level: 0/1 with NA is still a Cox model
    values <- data[[outcome]]
    if (is.null(values)) cli::cli_abort("Outcome column {.val {outcome}} was not found in {.arg data}.")
    if (inherits(values, "integer64")) .register_integer64(values)
    if (inherits(values, "haven_labelled_spss")) {
      if (!requireNamespace("haven", quietly = TRUE)) {
        cli::cli_abort("Interpreting SPSS user-missing values requires package {.pkg haven}.")
      }
      values <- haven::zap_missing(values)
    }
    model   <- if (dplyr::n_distinct(values, na.rm = TRUE) == 3L) "CRR" else "Cox"
    formula <- sprintf("Surv(%s, %s) ~ %s", quote_names(time),
                       quote_names(outcome), rhs)
  }
  .cat_message(sprintf("%s model, %s: %s", model, adj, formula),
               type = type, wrap = FALSE)
}

# ------------- .cat_tb ------------------------------------------------------

#' Enhanced Table Display with Pattern Highlighting
#'
#' Render one or more data objects (data.frame, gt, gtsummary) as styled
#' \code{gt} tables.
#'
#' @param ... Data objects to render (data.frame, gt, or gtsummary).
#'   A single unnamed list is also accepted.
#' @param highlight_pattern Regex pattern. Matching cells get
#'   \code{highlight_color} fill.
#' @param highlight_color Fill colour for highlighted cells (default
#'   \code{"lightcoral"}).
#' @param numeric_columns Character vector of column names to apply colour
#'   mapping. If \code{NULL}, numeric columns are formatted (2 decimals) but
#'   \emph{not} colour-mapped.
#' @param numeric_color Length-2 colour palette for colour mapping
#'   (low, high). Default \code{c("white", "blue")}.
#' @param theme One of \code{"excel"}, \code{"gt"}, \code{"none"}.
#' @param titles,subtitles,captions,footnotes Character vectors aligned with
#'   the data objects.
#'
#' @return A \code{gt} table or \code{gt_group} object (invisible when
#'   printed by RStudio viewer).
#'
#' @examples
#' table_data <- data.frame(
#'   group = c("A", "B"),
#'   value = c(1.25, 2.50)
#' )
#' .cat_tb(table_data, theme = "none")
#'
#' @export
#' @family console display
.cat_tb <- function(...,
                    highlight_pattern = NULL,
                    highlight_color = "lightcoral",
                    numeric_columns = NULL,
                    numeric_color = c("white", "blue"),
                    theme = c("excel", "gt", "none"),
                    titles = NULL,
                    subtitles = NULL,
                    captions = NULL,
                    footnotes = NULL) {

  theme <- match.arg(theme)
  if (!is.null(numeric_columns) && (!is.character(numeric_columns) ||
      !is.null(dim(numeric_columns)) || anyNA(numeric_columns)))
    cli::cli_abort("{.arg numeric_columns} must be NULL or a character vector without missing values.")
  for (arg in c("titles", "subtitles", "captions", "footnotes")) {
    value <- get(arg)
    if (!is.null(value) && (!is.character(value) || !is.null(dim(value))))
      cli::cli_abort("{.arg {arg}} must be NULL or a character vector.")
  }
  if (!is.null(highlight_pattern)) {
    if (!is.character(highlight_pattern) || length(highlight_pattern) != 1L ||
        !is.null(dim(highlight_pattern)) || is.na(highlight_pattern)) {
      cli::cli_abort("{.arg highlight_pattern} must be NULL or a single non-missing string.")
    }
    suppressWarnings(tryCatch(
      grepl(highlight_pattern, "", ignore.case = TRUE),
      error = function(e) cli::cli_abort("{.arg highlight_pattern} must be a valid regular expression.",
                                         parent = e)
    ))
    if (nzchar(highlight_pattern) &&
        (length(highlight_color) != 1L || !is.null(dim(highlight_color)) ||
         !is.character(highlight_color) ||
         !tryCatch({grDevices::col2rgb(highlight_color); TRUE}, error = function(e) FALSE)))
      cli::cli_abort("{.arg highlight_color} must be one valid colour string.")
  }

  # Collect inputs; unwrap single-list arg
  data_list <- list(...)
  if (length(data_list) == 1L && is.list(data_list[[1L]]) &&
      !inherits(data_list[[1L]], c("data.frame", "gt_tbl", "gtsummary"))) {
    data_list <- data_list[[1L]]
  }
  if (length(data_list) == 0L) stop("At least one data object is required.")

  # --- helpers (defined once, closed over parent args) -----------------------

  .apply_theme <- function(tb) {
    switch(theme,
      excel = gtExtras::gt_theme_excel(tb),
      gt    = gt::tab_options(tb,
                table.font.size        = gt::px(12),
                column_labels.background.color = "#E8F4FD"),
      tb
    )
  }

  .highlight_cells <- function(tb, df, pattern, color) {
    if (is.null(pattern) || !nzchar(pattern)) return(tb)
    for (j in seq_len(ncol(df))) {
      values <- df[[j]]
      if (!is.character(values) && !is.factor(values)) next
      if (!is.null(dim(values))) values <- values[seq_len(nrow(df))]
      rows <- if (is.factor(values)) {
        hit <- grepl(pattern, levels(values), ignore.case = TRUE)
        which(hit[as.integer(values)])
      } else {
        n <- length(values)
        keys <- NULL
        if (!is.object(values) && n > 1024L &&
            length(unique(values[seq.int(1L, n, length.out = 128L)])) < 64L) {
          distinct <- unique(values)
          if (length(distinct) < n / 2L) keys <- distinct
        }
        if (is.null(keys)) {
          which(grepl(pattern, values, ignore.case = TRUE))
        } else {
          hit <- grepl(pattern, keys, ignore.case = TRUE)
          which(hit[match(values, keys)])
        }
      }
      if (length(rows)) {
        tb <- gt::tab_style(tb,
          style     = gt::cell_fill(color = color),
          locations = gt::cells_body(columns = dplyr::all_of(names(df)[j]), rows = rows)
        )
      }
    }
    tb
  }

  .color_numerics <- function(tb, df, cols, palette) {
    # Always format to 2 decimals
    num_cols <- names(df)[vapply(df, is.numeric, logical(1))]
    fmt_cols <- if (!is.null(cols)) intersect(cols, names(df)) else num_cols
    if (length(fmt_cols) > 0L) {
      tb <- gt::fmt_number(tb, columns = fmt_cols, decimals = 2)
      labelled <- intersect(fmt_cols, num_cols)
      labelled <- labelled[vapply(df[labelled], inherits, logical(1), what = "haven_labelled")]
      if (length(labelled)) {
        # Keep gt's locale and output-specific formatters while adapting storage.
        formatters <- tail(tb[["_formats"]], 1L)[[1L]][["func"]]
        formatters <- lapply(formatters, function(fn) {
          callback <- function(x) fn(vctrs::vec_data(x))
          environment(callback) <- list2env(list(fn = fn), parent = baseenv())
          callback
        })
        tb <- gt::fmt(tb, columns = labelled, fns = formatters)
      }
    }
    # Colour-map only when user explicitly passed numeric_columns
    if (!is.null(cols)) {
      for (col in intersect(cols, names(df))) {
        v <- df[[col]]
        finite <- if (is.numeric(v)) is.finite(v) else FALSE
        if (any(finite)) {
          domain <- range(v[finite])
          encoded <- inherits(v, "integer64")
          origin <- NULL
          if (encoded) {
            approximate <- suppressWarnings(as.numeric(domain))
            if (diff(approximate) <= 2^53) origin <- domain[1L]
            domain <- if (is.null(origin)) approximate else as.numeric(domain - origin)
          }
          magnitude <- if (is.finite(diff(domain))) 1 else max(abs(domain))
          colour_fn <- scales::col_numeric(palette = palette, domain = domain / magnitude)
          tb <- gt::data_color(tb,
            columns = col,
            rows = which(!is.infinite(v)),
            fn = function(x) {
              if (encoded) x <- if (is.null(origin)) suppressWarnings(as.numeric(x)) else as.numeric(x - origin)
              colour_fn(x / magnitude)
            }
          )
        }
      }
    }
    tb
  }

  # --- process each data object ---------------------------------------------

  .process <- function(data, title, subtitle, caption, footnote) {
    # Restore encoded columns before gt captures formatting and colour data.
    df <- if (inherits(data, "gt_tbl")) {
      as.data.frame(data[["_data"]])
    } else if (inherits(data, "gtsummary")) {
      as.data.frame(data, col_labels = FALSE)
    } else as.data.frame(data)
    invisible(lapply(df, ._pr_restore))
    spss <- vapply(df, inherits, logical(1), what = "haven_labelled_spss")
    df[spss] <- lapply(df[spss], function(x) vctrs::vec_data(haven::zap_missing(x)))
    if (inherits(data, "gtsummary")) {
      tb <- gtsummary::as_gt(data)
    } else if (inherits(data, "gt_tbl")) {
      tb <- data
      if (any(spss)) tb[["_data"]][names(df)[spss]] <- df[spss]
    } else {
      tb <- gt::gt(df)
    }

    # Apply theme (skip for existing gt objects to preserve their styling)
    if (!inherits(data, "gt_tbl")) tb <- .apply_theme(tb)

    # Pattern highlighting
    tb <- .highlight_cells(tb, df, highlight_pattern, highlight_color)

    # Numeric formatting + optional colour mapping
    tb <- .color_numerics(tb, df, numeric_columns, numeric_color)

    # Header / footer
    if (!is.null(title) || !is.null(subtitle)) {
      args <- list()
      if (!is.null(title))    args$title    <- gt::md(title)
      if (!is.null(subtitle)) args$subtitle <- gt::md(subtitle)
      tb <- do.call(gt::tab_header, c(list(tb), args))
    }
    if (!is.null(caption))  tb <- gt::tab_source_note(tb, source_note = gt::md(caption))
    if (!is.null(footnote)) tb <- gt::tab_footnote(tb, footnote = gt::md(footnote))

    # Column label styling
    tb <- gt::tab_style(tb,
      style     = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    )
    tb <- gt::tab_options(tb,
      table.font.size                = gt::px(16),
      column_labels.background.color = "#E8F4FD",
      heading.background.color       = "#F0F8FF"
    )
    tb
  }

  # --- build all tables and combine -----------------------------------------

  gt_tables <- lapply(seq_along(data_list), function(i) {
    .process(
      data_list[[i]],
      title    = if (!is.null(titles)    && length(titles) >= i)    titles[i]    else NULL,
      subtitle = if (!is.null(subtitles) && length(subtitles) >= i) subtitles[i] else NULL,
      caption  = if (!is.null(captions)  && length(captions) >= i)  captions[i]  else NULL,
      footnote = if (!is.null(footnotes) && length(footnotes) >= i) footnotes[i] else NULL
    )
  })

  if (length(gt_tables) == 1L) gt_tables[[1L]] else do.call(gt::gt_group, gt_tables)
}

# ------------- show_color ---------------------------------------------------

#' Display Colour Swatches in Console
#'
#' Print colour hex codes as ANSI-coloured swatches with auto-contrasting
#' foreground text. Works in any terminal that supports ANSI true-colour
#' (24-bit) escape sequences. The displayed colour vector is also printed with
#' \code{dput()} so it can be copied back into R for assignment.
#' Swatches wrap to the console width without truncating the colour vector.
#' Decorative padding is reduced in narrow consoles. Labels wider than the
#' console remain intact on their own line.
#' Translucent swatches are composited onto white because ANSI backgrounds
#' cannot carry alpha. Their printed hex codes retain the original alpha.
#'
#' Swatches follow whatever colour depth the terminal reports through
#' \code{cli::num_ansi_colors()}. A terminal limited to 256 colours draws the
#' nearest palette entry instead of the exact hex, so a swatch can differ from
#' the code printed beside it. \code{options(cli.num_colors = 16777216)} forces
#' 24-bit output in a terminal that renders it without advertising it.
#' Colour depth is detected for stdout, including when stderr is redirected.
#' Versions of \pkg{cli} before 3.1.0 support at most 256 colours, including
#' when 24-bit output is requested.
#' On indexed terminals, text contrast uses the emitted ANSI colours and the
#' standard xterm palette. Custom terminal colour themes can change the result.
#'
#' Missing character values (\code{NA_character_}) and the literal colour
#' \code{"NA"} follow R's transparent-colour convention, so their swatches have
#' the same \code{#FFFFFF00} label as \code{"transparent"}. Their original
#' values, names and attributes are retained in the returned vector. The
#' copyable expression uses 17-digit precision for numeric attributes.
#' \code{dput()} cannot reconstruct every object exactly, including environment
#' attributes and names marked with the \code{"bytes"} encoding. Use
#' \code{saveRDS()} on the returned vector when exact object preservation is
#' required.
#' An empty character vector is also accepted.
#'
#' @param x Character vector without a class or dimensions, containing hex codes
#'   or named R colours. Numeric palette indices are not accepted.
#' @param rev Single non-missing logical value without a class or dimensions.
#'   Reverse colours and their names before display, retaining other attributes
#'   (default \code{FALSE}).
#' @return Invisibly returns \code{x}.
#'
#' @examples
#' show_color(c("#FF0000", "#00FF00", "#0000FF"))
#' show_color(rainbow(10))
#' show_color(c("steelblue", "tomato", "gold"), rev = TRUE)
#'
#' @export
show_color <- function(x, rev = FALSE) {
  if (!is.logical(rev) || is.object(rev) || length(rev) != 1L ||
      !is.null(dim(rev)) || is.na(rev)) {
    cli::cli_abort("{.arg rev} must be a single non-missing logical value without a class or dimensions.")
  }
  if (!is.character(x) || is.object(x) || !is.null(dim(x))) {
    cli::cli_abort("{.arg x} must be a character vector without a class or dimensions.")
  }
  numeric_index <- !is.na(suppressWarnings(as.numeric(x)))
  # Parse labels together, retaining alpha; inspect values only after failure.
  hex <- if (any(numeric_index)) NULL else {
    tryCatch(.pal_hex(x), error = function(e) NULL)
  }
  if (is.null(hex)) {
    to_check <- unique(x)
    if (length(to_check) <= 256L) {
      valid <- vapply(to_check, function(col) {
        tryCatch({
          grDevices::col2rgb(col)
          TRUE
        }, error = function(e) FALSE)
      }, logical(1), USE.NAMES = FALSE)
    } else {
      can_draw <- function(col) {
        tryCatch({ grDevices::col2rgb(col); TRUE }, error = function(e) FALSE)
      }
      valid <- rep(TRUE, length(to_check))
      for (start in seq.int(1L, length(to_check), by = 256L)) {
        at <- seq.int(start, min(start + 255, length(to_check)))
        if (!can_draw(to_check[at])) {
          valid[at] <- vapply(to_check[at], can_draw, logical(1), USE.NAMES = FALSE)
        }
      }
    }
    valid <- valid[match(x, to_check)]
    names(valid) <- if (is.null(names(x))) x else names(x)
    invalid <- which(numeric_index | !valid)
    cli::cli_abort("Invalid colours in {.arg x} at positions {.val {invalid}}: {.val {x[invalid]}}. Use R colour names or hex codes, not numeric palette indices.")
  }
  if (rev) {
    x_attributes <- attributes(x)
    x <- rev(x)
    if (length(x_attributes)) {
      x_attributes[["names"]] <- names(x)
      attributes(x) <- x_attributes
    }
    hex <- rev(hex)
  }

  width <- console_width()
  label_width <- max(nchar(hex, type = "width"), 7L)
  padding <- max(0L, min(2L, width - label_width))
  left_pad <- if (padding >= 1L) " " else ""
  right_pad <- if (padding == 2L) " " else ""

  # Compute relative luminance (WCAG formula) for contrast
  .luminance <- function(hex_col) {
    r <- strtoi(substr(hex_col, 2, 3), 16L) / 255
    g <- strtoi(substr(hex_col, 4, 5), 16L) / 255
    b <- strtoi(substr(hex_col, 6, 7), 16L) / 255
    lin <- function(v) ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
  }

  # Let cli pick the depth the terminal actually reports. Pinning `colors` to
  # 256 quantised every swatch onto the xterm palette, so the preview and the
  # hex codes underneath it disagreed: a diverging palette's pale midpoint
  # collapsed to grey and #B2182B was drawn as magenta.
  num_colors <- cli::num_ansi_colors(stdout())
  # cli 3.0.x cannot emit true colour even when it is explicitly requested.
  if (num_colors >= 16777216L && getNamespaceVersion("cli") < "3.1.0") {
    num_colors <- 256L
  }
  use_ansi <- if (num_colors > 1L) length(hex) > 0L else FALSE
  if (use_ansi) {
    old_colors <- options(cli.num_colors = num_colors)
    on.exit(options(old_colors), add = TRUE)
    ids <- if (anyDuplicated(hex)) match(unique(hex), hex) else seq_along(hex)
    rgba <- grDevices::col2rgb(if (length(ids) < length(hex)) x[ids] else x, alpha = TRUE)
    a <- rgba[4L, ] / 255
    preview <- grDevices::rgb(rgba[1L, ] * a + 255 * (1 - a),
                             rgba[2L, ] * a + 255 * (1 - a),
                             rgba[3L, ] * a + 255 * (1 - a),
                             maxColorValue = 255)
    preview_rgb <- grDevices::col2rgb(preview)
    foreground <- list()
    if (num_colors < 16777216L) {
      # Standard xterm entries; terminal themes may override these colours.
      base_colors <- c("#000000", "#CD0000", "#00CD00", "#CDCD00",
                       "#0000EE", "#CD00CD", "#00CDCD", "#E5E5E5",
                       "#7F7F7F", "#FF0000", "#00FF00", "#FFFF00",
                       "#5C5CFF", "#FF00FF", "#00FFFF", "#FFFFFF")
      # Decode each emitted SGR once rather than duplicating quantisation.
      luminance_cache <- new.env(parent = emptyenv())
      .displayed_luminance <- function(style) {
        shown <- style(" ")
        cached <- luminance_cache[[shown]]
        if (!is.null(cached)) return(cached)
        tag <- regmatches(shown, regexpr("\\[[0-9;]+m", shown))
        code <- as.integer(strsplit(substr(tag, 2L, nchar(tag) - 1L),
                                    ";", fixed = TRUE)[[1L]])
        index <- if (length(code) == 3L) code[[3L]] else {
          code[[1L]] %% 10L + if (code[[1L]] >= 90L) 8L else 0L
        }
        rgb <- if (index < 16L) {
          grDevices::col2rgb(base_colors[[index + 1L]])[, 1L]
        } else if (index >= 232L) {
          rep(8L + 10L * (index - 232L), 3L)
        } else {
          index <- index - 16L
          c(0, 95, 135, 175, 215, 255)[
            c(index %/% 36L, index %/% 6L %% 6L, index %% 6L) + 1L]
        }
        luminance_cache[[shown]] <- .luminance(grDevices::rgb(
          rgb[[1L]], rgb[[2L]], rgb[[3L]], maxColorValue = 255))
      }
      foreground <- lapply(c("#000000", "#FFFFFF"), function(col) {
        cli::make_ansi_style(col, bg = FALSE)
      })
      names(foreground) <- c("#000000", "#FFFFFF")
      fg_luminance <- vapply(foreground, .displayed_luminance, numeric(1))
      # Equal contrast occurs at the geometric mean of the offset luminances.
      foreground_cutoff <- sqrt(prod(fg_luminance + 0.05)) - 0.05
    }
    if (num_colors >= 16777216L) luminance <- .luminance(preview)
    foreground_cols <- if (num_colors >= 16777216L) character(length(ids)) else NULL
    style_group <- function(position) {
      j <- position[[1L]]
      i <- ids[position]
      bg_style <- cli::make_ansi_style(preview_rgb[, j, drop = FALSE], bg = TRUE, grey = FALSE)
      fg_col <- if (num_colors < 16777216L) {
        bg_luminance <- .displayed_luminance(bg_style)
        names(foreground)[[if (bg_luminance >= foreground_cutoff) 1L else 2L]]
      } else if (luminance[[j]] > 0.179) "#000000" else "#FFFFFF"
      if (is.null(foreground[[fg_col]])) {
        foreground[[fg_col]] <<- cli::make_ansi_style(fg_col, bg = FALSE)
      }
      fg_style <- foreground[[fg_col]]
      if (num_colors < 16777216L) {
        cli::combine_ansi_styles(fg_style, bg_style)(paste0(left_pad, hex[i], right_pad))
      } else {
        foreground_cols[position] <<- fg_col
        bg_style(paste0(left_pad, hex[i], right_pad))
      }
    }
    if (anyDuplicated(preview)) {
      # Share backgrounds after compositing, retaining every original HEX label.
      groups <- split(seq_along(ids), match(preview, unique(preview)))
      styled <- character(length(ids))
      for (position in groups) styled[position] <- style_group(position)
    } else {
      styled <- vapply(seq_along(ids), style_group, character(1), USE.NAMES = FALSE)
    }
    # Apply each true-colour foreground to its labels in one call.
    if (num_colors >= 16777216L) {
      for (fg_col in unique(foreground_cols)) {
        selection <- foreground_cols == fg_col
        styled[selection] <- foreground[[fg_col]](styled[selection])
      }
    }
    if (length(ids) < length(hex)) styled <- styled[match(hex, hex[ids])]
  } else {
    styled <- if (length(hex)) paste0(left_pad, hex, right_pad) else character()
  }

  per_line <- max(1L, (width + 1) %/% (label_width + padding + 1L))
  rows <- split(styled, ceiling(seq_along(styled) / per_line))
  if (!length(rows)) rows <- list(character())
  for (row in rows) cat(paste(row, collapse = " "), "\n", sep = "")
  dput(x, control = c("keepNA", "keepInteger", "niceNames", "showAttributes", "digits17"))
  invisible(x)
}
