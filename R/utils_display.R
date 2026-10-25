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
#         ._type_cfg()     type -> symbol / colour / ANSI background
#         ._cli_bg()       type -> cli background style
#         ._cli_fg()       type -> cli text colour on that background
#         ._chip()         short bold label on a solid background
#         ._ansi_styled()  wrap text in an ANSI background
#         console_width()  terminal width, with a fallback
# =============================================================================

# ------------- Shared internals ---------------------------------------------

# Type configuration: symbol, border_col, line_col, ANSI bg and text codes
._type_cfg <- function(type = c("info", "success", "warning", "error")) {
  type <- match.arg(type)
  cfg <- list(
    info    = list(symbol = "\u2139", col = "cyan",   ansi_bg = "\033[46m", ansi_fg = "\033[97m"),
    success = list(symbol = "\u2713", col = "green",  ansi_bg = "\033[42m", ansi_fg = "\033[97m"),
    warning = list(symbol = "\u26A0", col = "yellow", ansi_bg = "\033[43m", ansi_fg = "\033[30m"),
    error   = list(symbol = "\u2717", col = "red",    ansi_bg = "\033[41m", ansi_fg = "\033[97m")
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

# ANSI bold + text colour + bg helper (single line)
._ansi_styled <- function(text, ansi_bg, ansi_fg = "\033[97m") {
  paste0(ansi_bg, " \033[1m", ansi_fg, text, " \033[0m")
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
  cfg <- ._type_cfg(match.arg(type))
  label <- paste(cfg$symbol, text, cfg$symbol)

  tryCatch({
    bg <- ._cli_bg(cfg$type)
    styled <- cli::style_bold(._cli_fg(cfg$type)(label))
    cli::cat_rule(
      center   = bg(paste(" ", styled, " ")),
      line     = line_char,
      line_col = cfg$col,
      width    = width
    )
  }, error = function(e) {
    # ANSI fallback
    tw   <- nchar(label) + 4
    half <- (width - tw) / 2
    ll   <- paste(rep(line_char, max(floor(half), 0)), collapse = "")
    rl   <- paste(rep(line_char, max(ceiling(half), 0)), collapse = "")
    cat(ll, ._ansi_styled(label, cfg$ansi_bg, cfg$ansi_fg), rl, "\n", sep = "")
  })
  invisible()
}

# ------------- .cat_box ----------------------------------------------------

#' Styled info box
#'
#' Print a rounded box with type-coloured border and background.
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
  label <- paste(cfg$symbol, cat_text, cfg$symbol)

  tryCatch({
    bg <- ._cli_bg(cfg$type)
    styled <- cli::style_bold(bg(._cli_fg(cfg$type)(label)))
    cli::cat_boxx(
      styled,
      padding      = 1,
      border_style = "round",
      float        = "center",
      align        = "center",
      border_col   = cfg$col,
      background_col = paste0("bg_", cfg$col)
    )
  }, error = function(e) {
    # ANSI fallback: simple bracketed box
    w <- console_width()
    rule <- paste(rep("\u2500", w), collapse = "")
    cat(rule, "\n", sep = "")
    pad <- max((w - nchar(label) - 4) %/% 2, 0)
    cat(paste(rep(" ", pad), collapse = ""),
        ._ansi_styled(label, cfg$ansi_bg, cfg$ansi_fg), "\n", sep = "")
    cat(rule, "\n", sep = "")
  })
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
#' @param message Character. The message text.
#' @param type One of \code{"info"}, \code{"success"}, \code{"warning"},
#'   \code{"error"}.
#' @param timestamp_format \code{strftime} format string (default
#'   \code{"[\%Y-\%m-\%d \%H:\%M:\%S]"}).
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
  if (!verbose) return(invisible())
  cfg   <- ._type_cfg(match.arg(type))
  style <- match.arg(style)
  lines <- strsplit(as.character(message), "\n")[[1]]
  ts    <- format(Sys.time(), timestamp_format)
  # wrap at the console width, less the timestamp and the label or symbol
  avail <- max(20, console_width() - nchar(ts) - if (style == "chip") 10 else 6)
  lines <- unlist(lapply(if (length(lines)) lines else "", function(l) {
    if (wrap && nzchar(l)) as.character(cli::ansi_strwrap(l, width = avail)) else l
  }))

  tryCatch({
    bg    <- ._cli_bg(cfg$type)
    fg    <- ._cli_fg(cfg$type)
    ts_col <- cli::col_magenta(ts)

    out <- character(length(lines))
    if (style == "chip") {
      label <- c(info = "INFO", success = "DONE",
                 warning = "WARN", error = "FAIL")[[cfg$type]]
      lead  <- paste0(cli::col_grey(ts), " ", ._chip(label, bg, fg), " ")
      # continuation lines start under the text: timestamp, space, chip, space
      out   <- paste0(c(lead, rep(strrep(" ", nchar(ts) + nchar(label) + 4),
                                  length(lines) - 1L)), lines)
    } else for (i in seq_along(lines)) {
      body <- if (i == 1L) {
        paste0(" ", cli::style_bold(fg(cfg$symbol)), " ",
               cli::style_bold(fg(lines[i])), " ")
      } else {
        paste0(" ", cli::style_bold(fg(lines[i])), " ")
      }
      prefix <- if (i == 1L) paste0(ts_col, " ") else strrep(" ", nchar(ts) + 3)
      out[i] <- paste0(prefix, bg(body))
    }
    # A cli message rather than cat(), so suppressMessages() silences it;
    # cli_verbatim() keeps the text as is, without glue interpolation.
    cli::cli_verbatim(out)
  }, error = function(e) {
    # ANSI fallback
    out <- character(length(lines))
    for (i in seq_along(lines)) {
      body <- if (i == 1L) paste(cfg$symbol, lines[i]) else lines[i]
      prefix <- if (i == 1L) paste0("\033[90m", ts, "\033[0m ") else strrep(" ", nchar(ts) + 3)
      out[i] <- paste0(prefix, ._ansi_styled(body, cfg$ansi_bg, cfg$ansi_fg))
    }
    message(paste(out, collapse = "\n"))
  })
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
  if (!isTRUE(verbose)) return(invisible(NULL))
  # force the default before `msg` gains its prefix, or it would get two
  force(msg_done)
  # text cli cannot parse (data with braces) is shown as written; cli would
  # otherwise fail inside the deferred on.exit() that closes the step
  as_written <- function(s) {
    ok <- tryCatch({ cli::format_inline(s, .envir = .envir); TRUE },
                   error = function(e) FALSE)
    if (ok) s else gsub("([{}])", "\\1\\1", s)
  }
  msg      <- as_written(msg)
  msg_done <- as_written(msg_done)
  if (!is.null(i)) {
    num <- if (is.null(n)) sprintf("[%d]", as.integer(i)) else
      sprintf("[%d/%d]", as.integer(i), as.integer(n))
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
#'
#' @export
#' @family console display
.cat_formula <- function(data, co_var, time = "time", outcome = "DSS",
                         type = c("info", "success", "warning", "error")) {
  type <- match.arg(type)
  adj  <- if (length(co_var) == 1L) "unadjusted" else "adjusted"
  rhs  <- paste(co_var, collapse = " + ")
  # one line in place of a box and a rule, nine lines per model (2026-10-25)
  if (is.null(time)) {
    model   <- "Logistic"
    formula <- sprintf("%s ~ %s", outcome, rhs)
  } else {
    # a missing outcome is not a level: 0/1 with NA is still a Cox model
    model   <- if (dplyr::n_distinct(data[[outcome]], na.rm = TRUE) == 3L) "CRR" else "Cox"
    formula <- sprintf("Surv(%s, %s) ~ %s", time, outcome, rhs)
  }
  .cat_message(sprintf("%s model, %s: %s", model, adj, formula), type = type)
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
    for (i in seq_len(nrow(df))) {
      for (j in seq_len(ncol(df))) {
        val <- df[[j]][i]
        if ((is.character(val) || is.factor(val)) &&
            grepl(pattern, as.character(val), ignore.case = TRUE)) {
          tb <- gt::tab_style(tb,
            style     = gt::cell_fill(color = color),
            locations = gt::cells_body(columns = j, rows = i)
          )
        }
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
    }
    # Colour-map only when user explicitly passed numeric_columns
    if (!is.null(cols)) {
      for (col in intersect(cols, names(df))) {
        v <- df[[col]]
        if (is.numeric(v) && sum(!is.na(v)) > 0L) {
          tb <- gt::data_color(tb,
            columns = col,
            fn = scales::col_numeric(
              palette = palette,
              domain  = range(v, na.rm = TRUE)
            )
          )
        }
      }
    }
    tb
  }

  # --- process each data object ---------------------------------------------

  .process <- function(data, title, subtitle, caption, footnote) {
    # Convert to gt
    if (inherits(data, "gtsummary")) {
      df <- as.data.frame(data)
      tb <- gtsummary::as_gt(data)
    } else if (inherits(data, "gt_tbl")) {
      df <- as.data.frame(data[["_data"]])
      tb <- data
    } else {
      df <- as.data.frame(data)
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
#'
#' Swatches follow whatever colour depth the terminal reports through
#' \code{cli::num_ansi_colors()}. A terminal limited to 256 colours draws the
#' nearest palette entry instead of the exact hex, so a swatch can differ from
#' the code printed beside it. \code{options(cli.num_colors = 16777216)} forces
#' 24-bit output in a terminal that renders it without advertising it.
#'
#' @param x Character vector of colours (hex codes or named R colours).
#' @param rev Logical. Reverse the order before display (default \code{FALSE}).
#' @return Invisibly returns \code{x}.
#'
#' @examples
#' show_color(c("#FF0000", "#00FF00", "#0000FF"))
#' show_color(rainbow(10))
#' show_color(c("steelblue", "tomato", "gold"), rev = TRUE)
#'
#' @export
show_color <- function(x, rev = FALSE) {
  if (rev) x <- rev(x)

  # Convert any colour specification to hex "#RRGGBB"
  hex <- vapply(x, function(cc) {
    rgb_mat <- grDevices::col2rgb(cc)
    grDevices::rgb(rgb_mat[1], rgb_mat[2], rgb_mat[3], maxColorValue = 255)
  }, character(1), USE.NAMES = FALSE)

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
  styled <- vapply(hex, function(h) {
    fg_col <- if (.luminance(h) > 0.179) "#000000" else "#FFFFFF"
    fg_style <- cli::make_ansi_style(fg_col, bg = FALSE)
    bg_style <- cli::make_ansi_style(h, bg = TRUE, grey = FALSE)
    cli::combine_ansi_styles(fg_style, bg_style)(paste0(" ", h, " "))
  }, character(1), USE.NAMES = FALSE)

  cat(paste(styled, collapse = " "), "\n")
  dput(x)
  invisible(x)
}
