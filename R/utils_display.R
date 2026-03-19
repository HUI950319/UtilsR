# ============================================================================
# utils_display.R -- Console display helpers
# ============================================================================

# ------------- Shared internals ---------------------------------------------

# Type configuration: symbol, border_col, line_col, ANSI bg code
._type_cfg <- function(type = c("info", "success", "warning", "error")) {
  type <- match.arg(type)
  cfg <- list(
    info    = list(symbol = "\u2139", col = "cyan",   ansi_bg = "\033[46m"),
    success = list(symbol = "\u2713", col = "green",  ansi_bg = "\033[42m"),
    warning = list(symbol = "\u26A0", col = "yellow", ansi_bg = "\033[43m"),
    error   = list(symbol = "\u2717", col = "red",    ansi_bg = "\033[41m")
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

# ANSI bold + white + bg helper (single line)
._ansi_styled <- function(text, ansi_bg) {
  paste0(ansi_bg, " \033[1m\033[97m", text, " \033[0m")
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
#' @keywords internal
.cat_line <- function(text,
                      type = c("info", "success", "warning", "error"),
                      line_char = "=",
                      width = console_width()) {
  cfg <- ._type_cfg(match.arg(type))
  label <- paste(cfg$symbol, text, cfg$symbol)

  tryCatch({
    bg <- ._cli_bg(cfg$type)
    styled <- cli::style_bold(cli::col_br_white(label))
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
    cat(ll, ._ansi_styled(label, cfg$ansi_bg), rl, "\n", sep = "")
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
#' @keywords internal
.cat_box <- function(cat_text,
                     type = c("info", "success", "warning", "error")) {
  cfg <- ._type_cfg(match.arg(type))
  label <- paste(cfg$symbol, cat_text, cfg$symbol)

  tryCatch({
    bg <- ._cli_bg(cfg$type)
    styled <- cli::style_bold(bg(cli::col_br_white(label)))
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
        ._ansi_styled(label, cfg$ansi_bg), "\n", sep = "")
    cat(rule, "\n", sep = "")
  })
  invisible()
}

# ------------- .cat_message -------------------------------------------------

#' Styled log message with timestamp
#'
#' Print a timestamped, type-coloured message. Supports multi-line messages
#' (split on \code{"\\n"}).
#'
#' @param message Character. The message text.
#' @param type One of \code{"info"}, \code{"success"}, \code{"warning"},
#'   \code{"error"}.
#' @param timestamp_format \code{strftime} format string (default
#'   \code{"[\%Y-\%m-\%d \%H:\%M:\%S]"}).
#' @param verbose Logical. If \code{FALSE}, suppress output.
#'
#' @keywords internal
.cat_message <- function(message,
                         type = c("info", "success", "warning", "error"),
                         timestamp_format = "[%Y-%m-%d %H:%M:%S]",
                         verbose = TRUE) {
  if (!verbose) return(invisible())
  cfg   <- ._type_cfg(match.arg(type))
  lines <- strsplit(as.character(message), "\n")[[1]]
  ts    <- format(Sys.time(), timestamp_format)

  tryCatch({
    bg    <- ._cli_bg(cfg$type)
    white <- cli::col_br_white
    ts_col <- cli::col_magenta(ts)

    for (i in seq_along(lines)) {
      body <- if (i == 1L) {
        paste0(" ", cli::style_bold(white(cfg$symbol)), " ",
               cli::style_bold(white(lines[i])), " ")
      } else {
        paste0(" ", cli::style_bold(white(lines[i])), " ")
      }
      prefix <- if (i == 1L) paste0(ts_col, " ") else strrep(" ", nchar(ts) + 3)
      cat(prefix, bg(body), "\n", sep = "")
    }
  }, error = function(e) {
    # ANSI fallback
    for (i in seq_along(lines)) {
      body <- if (i == 1L) paste(cfg$symbol, lines[i]) else lines[i]
      prefix <- if (i == 1L) paste0("\033[90m", ts, "\033[0m ") else strrep(" ", nchar(ts) + 3)
      cat(prefix, ._ansi_styled(body, cfg$ansi_bg), "\n", sep = "")
    }
  })
  invisible()
}

# ------------- .cat_formula -------------------------------------------------

#' Print model formula with styled header
#'
#' Displays a model formula (Cox, CRR, or logistic) with a styled box and
#' separator. Automatically detects model type from the number of distinct
#' outcome levels and presence of a time variable.
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
#' @keywords internal
.cat_formula <- function(data, co_var, time = "time", outcome = "DSS",
                         type = c("info", "success", "warning", "error")) {
  type <- match.arg(type)
  adj  <- if (length(co_var) == 1L) "unadj" else "adjus"
  rhs  <- paste(co_var, collapse = " + ")
  cat("\n")

  if (is.null(time)) {
    # Logistic model
    .cat_box(paste(adj, "log model"), type = type)
    .cat_line(sprintf("%s ~ %s", outcome, rhs), type = type)
  } else {
    # Survival model
    n_levels <- dplyr::n_distinct(data[[outcome]])
    model <- if (n_levels == 3L) "crr model" else "cox model"
    .cat_box(paste(adj, model), type = type)
    .cat_line(sprintf("Surv(%s, %s) ~ %s", time, outcome, rhs), type = type)
  }
  cat("\n\n")
  invisible()
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
#' @keywords internal
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
#' (24-bit) escape sequences.
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

  # Use cli::make_ansi_style for cross-terminal compatibility (256/truecolor)
  styled <- vapply(hex, function(h) {
    fg_col <- if (.luminance(h) > 0.179) "#000000" else "#FFFFFF"
    fg_style <- cli::make_ansi_style(fg_col, bg = FALSE, colors = 256)
    bg_style <- cli::make_ansi_style(h, bg = TRUE, colors = 256, grey = FALSE)
    cli::combine_ansi_styles(fg_style, bg_style)(paste0(" ", h, " "))
  }, character(1), USE.NAMES = FALSE)

  cat(paste(styled, collapse = " "), "\n")
  invisible(x)
}
