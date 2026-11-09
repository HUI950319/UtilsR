# =============================================================================
# PlotDumbbell.R -- Dumbbell (lollipop comparison) chart
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  PlotDumbbell(data, x_col, xend_col, y_col, ...)   -- public API
#         +-- L2  .resolve_theme()           theme_use -> ggplot2 theme
#         +-- L2  .build_dumbbell_inset()    paired box / violin inset panel
# =============================================================================

#' Dumbbell Chart for Paired Comparisons
#'
#' Create a horizontal dumbbell chart showing paired values (e.g., before/after,
#' control/treatment) for each category. Supports auto-sorting, mean reference
#' lines, delta labels, and an optional inset plot via patchwork.
#'
#' @param data A data.frame containing category, start, and end columns.
#'   Generated delta fields are kept separate from existing column names.
#'   Input columns do not override legend labels or dot-guide origins.
#'   Integer differences outside R's integer range are retained as doubles.
#' @param x_col Column name for the start (left) values. Default
#'   \code{"start"}.
#' @param xend_col Column name for the end (right) values. Default
#'   \code{"end"}.
#' @param y_col Column name for the category labels (Y axis). Default
#'   \code{"category"}.
#' @param sort_by How to sort categories: \code{"end"} (by xend_col),
#'   \code{"start"} (by x_col), \code{"delta"} (by difference),
#'   \code{"none"} (original order). Default \code{"end"}.
#' @param sort_descending Logical. Sort in descending order? Default
#'   \code{FALSE} (ascending, smallest at bottom).
#' @param top_n A single finite integer-valued number. Retain the last N
#'   categories after sorting. Default \code{NULL} (show all). Non-positive
#'   values and values at least as large as the row count also show all.
#' @param color_x Colour for start (x) points. Default \code{"#00468BFF"}.
#' @param color_xend Colour for end (xend) points. Default \code{"#ED0000FF"}.
#' @param label_x Label for start points (used in legend and auto inset).
#'   Default \code{NULL} (column name). Endpoints remain distinct even when
#'   both display labels are identical.
#' @param label_xend Label for end points (used in legend and auto inset).
#'   Default \code{NULL} (column name).
#' @param seg_color Segment line colour. Default \code{"grey60"}.
#' @param seg_size Segment line width. Default 0.8.
#' @param point_size Point size. Default 3.
#' @param point_shape Point shape. Default 19 (filled circle).
#' @param show_delta Logical. Show delta (difference) labels at the end of
#'   each segment? Default \code{FALSE}.
#' @param delta_size Text size for delta labels. Default 3.
#' @param delta_digits Number of decimal places for delta labels. Default 2.
#' @param delta_color Colour for delta labels. Default \code{"grey30"}.
#' @param show_zero_line Logical. Show a vertical line at x = 0? Default
#'   \code{TRUE}.
#' @param zero_line_color Colour for zero line. Default \code{"grey30"}.
#' @param zero_line_width Width for zero line. Default 0.3.
#' @param show_mean_lines Logical. Show vertical dashed lines at the mean of
#'   x and xend values? Default \code{FALSE}.
#' @param mean_line_width Width for mean lines. Default 0.3.
#' @param dot_guide Logical. Show faint horizontal guide lines from each
#'   point to the Y axis? Default \code{FALSE}.
#' @param dot_guide_color Colour for dot guide lines. Default
#'   \code{"grey80"}.
#' @param dot_guide_size Width for dot guide lines. Default 0.15.
#' @param x_label X axis label. Default \code{NULL} (no label).
#' @param y_label Y axis label. Default \code{NULL} (no label).
#' @param title Plot title. Default \code{NULL}.
#' @param legend_pos Legend position. Accepts:
#'   \itemize{
#'     \item \code{"none"} — hide legend.
#'     \item \code{"auto"} — inside bottom-right (default).
#'     \item \code{"br"}, \code{"bl"}, \code{"tr"}, \code{"tl"} — inside
#'       corners.
#'     \item \code{"bottom"}, \code{"top"}, \code{"left"}, \code{"right"} —
#'       outside (standard ggplot2 positions).
#'   }
#' @param legend_theme A ggplot2 theme object for legend styling, e.g.,
#'   \code{theme_legend1()}. Default \code{NULL} (no extra legend styling).
#' @param theme_use Theme object, zero-argument theme function, or theme name.
#'   Unknown names produce an error. Default \code{theme_my}; explicit
#'   \code{NULL} uses \code{ggplot2::theme_classic()}.
#' @param inset_plot Inset plot specification. One of:
#'   \itemize{
#'     \item \code{NULL} — no inset (default).
#'     \item \code{"auto"} — auto-generate a paired boxplot from the dumbbell
#'       data, with paired lines, jitter points, and a significance bracket.
#'     \item A \code{ggplot} object — embed a custom inset plot.
#'   }
#' @param inset_type Type of auto-generated inset: \code{"boxplot"} (default)
#'   or \code{"violin"}. Only used when \code{inset_plot = "auto"};
#'   unsupported values are rejected in that mode.
#' @param inset_test Paired test for auto inset significance bracket:
#'   \code{"t.test"}, \code{"wilcox"}, or \code{"none"}. Default
#'   \code{"t.test"}. Only used when \code{inset_plot = "auto"}.
#' @param inset_paired_line Logical. Show paired connecting lines in auto
#'   inset? Default \code{TRUE}. Each retained row defines one pair, even
#'   when category labels repeat.
#' @param inset_jitter Logical. Show jitter points in auto inset? Default
#'   \code{TRUE}.
#' @param inset_theme_use Theme for the automatic inset, with the same inputs as
#'   \code{theme_use}. Default \code{NULL} reuses the resolved main theme
#'   with compact styling.
#' @param inset_left,inset_bottom,inset_right,inset_top Inset boundaries
#'   (patchwork panel coordinates). Default 0.04, 0.68, 0.35, 0.94.
#' @param filename Output file path. Default \code{NULL} (no save, print
#'   only).
#' @param width,height Output dimensions in inches. Default 8 / 6.
#' @param dpi Output resolution. Default 300.
#' @param bg Output background colour. Default \code{"white"}.
#'
#' @return A ggplot (or patchwork) object (returned invisibly).
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   cell_type = paste0("Type", 1:10),
#'   sil_ref   = runif(10, -0.2, 0.5),
#'   sil_emb   = runif(10, 0, 0.8)
#' )
#' # Basic dumbbell
#' PlotDumbbell(df, x_col = "sil_ref", xend_col = "sil_emb",
#'              y_col = "cell_type", label_x = "PCA", label_xend = "scMMR")
#'
#' # Auto inset paired boxplot
#' PlotDumbbell(df, x_col = "sil_ref", xend_col = "sil_emb",
#'              y_col = "cell_type", label_x = "PCA", label_xend = "scMMR",
#'              inset_plot = "auto", inset_test = "t.test")
#'
#' # Custom inset
#' my_inset <- ggplot2::ggplot(df, ggplot2::aes(sil_ref, sil_emb)) +
#'   ggplot2::geom_point()
#' PlotDumbbell(df, x_col = "sil_ref", xend_col = "sil_emb",
#'              y_col = "cell_type", inset_plot = my_inset)
#' }
#'
#' @export
PlotDumbbell <- function(
    data,
    x_col            = "start",           # start (left) value column
    xend_col         = "end",             # end (right) value column
    y_col            = "category",        # category label column
    sort_by          = "end",             # sort: "end"/"start"/"delta"/"none"
    sort_descending  = FALSE,             # descending sort order
    top_n            = NULL,              # show only top N categories
    color_x          = "#00468BFF",       # colour for start points
    color_xend       = "#ED0000FF",       # colour for end points
    label_x          = NULL,              # legend label for start
    label_xend       = NULL,              # legend label for end
    seg_color        = "grey60",          # segment line colour
    seg_size         = 0.8,              # segment line width
    point_size       = 3,                # point size
    point_shape      = 19,               # point shape (19 = filled circle)
    show_delta       = FALSE,             # show delta labels
    delta_size       = 3,                # delta label text size
    delta_digits     = 2,                # delta label decimal places
    delta_color      = "grey30",          # delta label colour
    show_zero_line   = TRUE,              # show vertical line at x=0
    zero_line_color  = "grey30",          # zero line colour
    zero_line_width  = 0.3,              # zero line width
    show_mean_lines  = FALSE,             # show mean reference lines
    mean_line_width  = 0.3,              # mean line width
    dot_guide        = FALSE,             # show horizontal dot guide lines
    dot_guide_color  = "grey80",          # dot guide colour
    dot_guide_size   = 0.15,             # dot guide width
    x_label          = NULL,              # X axis label
    y_label          = NULL,              # Y axis label
    title            = NULL,              # plot title
    legend_pos       = "auto",            # "auto"/"br"/"bl"/"tr"/"tl"/"none"/ggplot2 pos
    legend_theme     = NULL,              # legend theme, e.g. theme_legend1()
    theme_use        = theme_my,          # theme function/object/string
    inset_plot       = NULL,              # NULL / "auto" / ggplot object
    inset_type       = "boxplot",         # auto inset type: "boxplot"/"violin"
    inset_test       = "t.test",          # auto inset test: "t.test"/"wilcox"/"none"
    inset_paired_line = TRUE,             # show paired lines in auto inset
    inset_jitter     = TRUE,              # show jitter points in auto inset
    inset_theme_use  = NULL,              # theme for auto inset (NULL = same)
    inset_left       = 0.04,             # inset left boundary
    inset_bottom     = 0.68,             # inset bottom boundary
    inset_right      = 0.35,             # inset right boundary
    inset_top        = 0.94,             # inset top boundary
    filename         = NULL,              # output file path (NULL = no save)
    width            = 8,                # output width (inches)
    height           = 6,                # output height (inches)
    dpi              = 300,              # output resolution
    bg               = "white"           # output background colour
) {
  if (!is.null(filename)) .check_plot_filename(filename)

  # ---- Validate inputs ----
  for (arg in c("sort_descending", "show_delta", "show_zero_line", "show_mean_lines", "dot_guide")) {
    value <- get(arg)
    if (!is.logical(value) || !is.null(dim(value)) || length(value) != 1L || is.na(value))
      stop("'", arg, "' must be TRUE or FALSE.", call. = FALSE)
  }
  for (arg in c("seg_size", "point_size", if (show_delta) "delta_size",
                if (show_zero_line) "zero_line_width", if (show_mean_lines) "mean_line_width",
                if (dot_guide) "dot_guide_size")) {
    value <- get(arg)
    if (!is.numeric(value) || is.object(value) || !is.null(dim(value)) ||
        length(value) != 1L || !is.finite(value) || value < 0)
      stop("'", arg, "' must be a single finite non-negative number.", call. = FALSE)
  }
  if (!(is.character(legend_pos) && is.null(dim(legend_pos)) &&
        length(legend_pos) == 1L && !is.na(legend_pos)) &&
      !(is.numeric(legend_pos) && !is.object(legend_pos) && is.null(dim(legend_pos)) &&
        length(legend_pos) == 2L && all(is.finite(legend_pos)))) {
    stop("'legend_pos' must be a position string or two finite coordinates.", call. = FALSE)
  }
  for (arg in c("label_x", "label_xend")) {
    value <- get(arg)
    if (!is.null(value) && (length(value) != 1L || !is.null(dim(value))))
      stop("'", arg, "' must be NULL or a single label.", call. = FALSE)
  }
  selectors <- list(x_col = x_col, xend_col = xend_col, y_col = y_col)
  for (arg in names(selectors)) {
    value <- selectors[[arg]]
    if (!is.character(value) || !is.null(dim(value)) || length(value) != 1L ||
        is.na(value) || !nzchar(value)) {
      stop("'", arg, "' must be a single non-missing column name.", call. = FALSE)
    }
  }
  data <- as.data.frame(data)
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data)))
    stop("'data' must have unique, non-missing, non-empty column names.", call. = FALSE)
  for (col in c(x_col, xend_col, y_col)) {
    if (!col %in% colnames(data)) {
      stop("Column '", col, "' not found in data.", call. = FALSE)
    }
  }
  if (!is.null(dim(data[[y_col]])))
    stop("Column '", y_col, "' must contain a category vector without dimensions.", call. = FALSE)
  for (col in c(x_col, xend_col)) {
    value <- data[[col]]
    .register_integer64(value)
    if (is.complex(value) || !is.null(dim(value)) ||
        !(is.numeric(value) || inherits(value, c("Date", "POSIXt", "difftime")))) {
      stop("Column '", col, "' must contain a numeric or time vector.", call. = FALSE)
    }
    if (inherits(value, "haven_labelled_spss")) data[[col]] <- .scatter_axis_values(value)
  }
  if (!is.null(top_n) &&
      (!is.numeric(top_n) || is.object(top_n) || !is.null(dim(top_n)) ||
       is.complex(top_n) || length(top_n) != 1L ||
       !is.finite(top_n) || top_n != trunc(top_n))) {
    stop("'top_n' must be NULL or a single finite integer-valued number.",
         call. = FALSE)
  }

  # ---- Labels ----
  if (is.null(label_x))    label_x    <- x_col
  if (is.null(label_xend)) label_xend <- xend_col
  if (is.factor(label_x)) label_x <- as.character(label_x)
  if (is.factor(label_xend)) label_xend <- as.character(label_xend)
  display_labels <- as.character(c(label_x, label_xend))
  label_keys <- make.unique(display_labels)

  # ---- Compute delta ----
  delta_fields <- utils::tail(make.unique(c(names(data), ".delta", ".delta_label", ".delta_x")), 3L)
  delta_var <- delta_fields[1L]
  delta_label_var <- delta_fields[2L]
  delta_x_var <- delta_fields[3L]
  start_values <- data[[x_col]]
  end_values <- data[[xend_col]]
  if (is.integer(start_values) && is.integer(end_values) &&
      !is.object(start_values) && !is.object(end_values)) {
    delta_values <- as.double(end_values) - as.double(start_values)
    if (all(abs(delta_values) <= .Machine$integer.max, na.rm = TRUE)) {
      delta_values <- as.integer(delta_values)
    }
  } else {
    delta_values <- end_values - start_values
  }
  data[[delta_var]] <- delta_values

  # ---- Sort ----
  sort_by <- match.arg(sort_by, c("end", "start", "delta", "none"))
  if (sort_by != "none") {
    sort_vals <- switch(sort_by,
      "end"   = data[[xend_col]],
      "start" = data[[x_col]],
      "delta" = data[[delta_var]]
    )
    ord <- order(sort_vals, decreasing = sort_descending)
    data <- data[ord, , drop = FALSE]
  }

  # ---- Top N ----
  if (!is.null(top_n) && top_n > 0 && top_n < nrow(data)) {
    data <- utils::tail(data, top_n)
  }

  # Continuous scales strip duration units, so align plotting coordinates
  # after computing deltas in the original units.
  if (inherits(data[[x_col]], "difftime") && inherits(data[[xend_col]], "difftime")) {
    units(data[[xend_col]]) <- units(data[[x_col]])
  }

  # ---- Factor Y axis (preserving sorted order) ----
  categories <- .butterfly_category_labels(data[[y_col]])
  if (is.factor(categories) && anyNA(levels(categories))) {
    labels <- levels(categories)
    labels[is.na(labels)] <- utils::tail(make.unique(c(labels[!is.na(labels)], "<NA>")), 1L)
    levels(categories) <- labels
  }
  if (y_col %in% c(x_col, xend_col)) {
    y_col <- utils::tail(make.unique(c(names(data), ".category")), 1L)
  }
  data[[y_col]] <- factor(categories, levels = unique(categories))

  # Keep a literal .data column separate from ggplot2's data pronoun.
  if (".data" %in% c(x_col, xend_col, y_col)) {
    alias <- utils::tail(make.unique(c(names(data), delta_fields, ".plot_data")), 1L)
    data[[alias]] <- data[[".data"]]
    if (x_col == ".data") x_col <- alias
    if (xend_col == ".data") xend_col <- alias
    if (y_col == ".data") y_col <- alias
  }

  # ---- Build plot ----
  p <- ggplot2::ggplot(data)

  # Dot guide lines (behind everything)
  if (dot_guide) {
    x_min <- min(c(data[[x_col]], data[[xend_col]]), na.rm = TRUE)
    p <- p +
      ggplot2::geom_segment(
        ggplot2::aes(
          x = !!x_min, xend = pmax(.data[[x_col]], .data[[xend_col]]),
          y = .data[[y_col]], yend = .data[[y_col]]
        ),
        color = dot_guide_color, linewidth = dot_guide_size,
        linetype = "dotted"
      )
  }

  # Connecting segments
  p <- p +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data[[x_col]], xend = .data[[xend_col]],
        y = .data[[y_col]], yend = .data[[y_col]]
      ),
      color = seg_color, linewidth = seg_size
    )

  # Start points (x) — map color to label for native legend
  p <- p +
    ggplot2::geom_point(
      ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]],
                   color = !!label_keys[1L]),
      size = point_size, shape = point_shape
    )

  # End points (xend)
  p <- p +
    ggplot2::geom_point(
      ggplot2::aes(x = .data[[xend_col]], y = .data[[y_col]],
                   color = !!label_keys[2L]),
      size = point_size, shape = point_shape
    )

  # Colour scale for legend
  if (is.factor(color_x)) color_x <- as.character(color_x)
  if (is.factor(color_xend)) color_xend <- as.character(color_xend)
  color_vals <- stats::setNames(c(color_x, color_xend), label_keys)
  p <- p +
    ggplot2::scale_color_manual(
      # Preserve the title inferred from the original colour mapping.
      name = "label_x",
      values = color_vals,
      labels = stats::setNames(display_labels, label_keys),
      guide  = ggplot2::guide_legend(
        override.aes = list(size = point_size * 0.8)
      )
    )

  # ---- Reference lines ----
  if (show_zero_line) {
    zero <- 0
    if (inherits(data[[x_col]], "Date")) zero <- .Date(0)
    if (inherits(data[[x_col]], "POSIXt")) {
      zero <- vctrs::vec_restore(0, as.POSIXct(data[[x_col]]))
    }
    p <- p +
      ggplot2::geom_vline(
        xintercept = zero, linewidth = zero_line_width, color = zero_line_color
      )
  }

  if (show_mean_lines) {
    mean_x    <- mean(data[[x_col]], na.rm = TRUE)
    mean_xend <- mean(data[[xend_col]], na.rm = TRUE)
    p <- p +
      ggplot2::geom_vline(
        xintercept = mean_x, linetype = "dashed",
        color = color_x, linewidth = mean_line_width
      ) +
      ggplot2::geom_vline(
        xintercept = mean_xend, linetype = "dashed",
        color = color_xend, linewidth = mean_line_width
      )
  }

  # ---- Delta labels ----
  if (show_delta) {
    data[[delta_label_var]] <- round(data[[delta_var]], delta_digits)
    data[[delta_x_var]] <- pmax(data[[x_col]], data[[xend_col]])
    p <- p +
      ggplot2::geom_text(
        data = data,
        ggplot2::aes(
          x = .data[[delta_x_var]], y = .data[[y_col]],
          label = .data[[delta_label_var]]
        ),
        hjust = -0.3, size = delta_size, color = delta_color
      )
  }

  # ---- Legend positioning ----
  # Map shorthand corner codes to ggplot2 legend.position coordinates
  corner_map <- list(
    br = c(0.85, 0.15),
    bl = c(0.15, 0.15),
    tr = c(0.85, 0.85),
    tl = c(0.15, 0.85)
  )
  if (identical(legend_pos, "auto")) legend_pos <- "br"

  if (identical(legend_pos, "none")) {
    leg_position <- "none"
  } else if (is.character(legend_pos) && legend_pos %in% names(corner_map)) {
    leg_position <- corner_map[[legend_pos]]
  } else {
    # Standard ggplot2 positions: "bottom", "top", "left", "right"
    leg_position <- legend_pos
  }

  # ---- Labels and theme ----
  thm <- .resolve_theme(theme_use %||% ggplot2::theme_classic)
  p <- p +
    ggplot2::labs(x = x_label, y = y_label, title = title) +
    thm +
    ggplot2::theme(legend.position = leg_position)

  # Inside-plot legends need justification
  if (is.numeric(leg_position)) {
    just_x <- ifelse(leg_position[1] > 0.5, 1, 0)
    just_y <- ifelse(leg_position[2] > 0.5, 1, 0)
    p <- p + ggplot2::theme(
      legend.justification = c(just_x, just_y)
    )
  }

  # Apply legend_theme (e.g., theme_legend1())
  if (!is.null(legend_theme) && inherits(legend_theme, "theme")) {
    p <- p + legend_theme
  }

  # ---- Inset plot ----
  inset_obj <- NULL

  if (is.character(inset_plot) && identical(inset_plot, "auto")) {
    # Auto-generate paired boxplot/violin from dumbbell data
    inset_obj <- .build_dumbbell_inset(
      data       = data,
      x_col      = x_col,
      xend_col   = xend_col,
      label_x    = label_x,
      label_xend = label_xend,
      color_x    = color_x,
      color_xend = color_xend,
      inset_type = inset_type,
      inset_test = inset_test,
      paired_line = inset_paired_line,
      jitter     = inset_jitter,
      theme_obj  = if (is.null(inset_theme_use)) thm else .resolve_theme(inset_theme_use)
    )
  } else if (inherits(inset_plot, "ggplot") || inherits(inset_plot, "grob") ||
             inherits(inset_plot, "gList") || inherits(inset_plot, "gtable")) {
    inset_obj <- inset_plot
  }

  if (!is.null(inset_obj)) {
    if (!requireNamespace("patchwork", quietly = TRUE)) {
      warning("Package 'patchwork' is needed for inset_plot.", call. = FALSE)
    } else {
      p <- p + patchwork::inset_element(
        inset_obj,
        left     = inset_left,
        bottom   = inset_bottom,
        right    = inset_right,
        top      = inset_top,
        align_to = "panel"
      )
    }
  }

  # ---- Save or print ----
  if (!is.null(filename)) {
    # measured before writing, which creates the file
    existed <- file.exists(filename)
    ggplot2::ggsave(
      filename, p,
      width = width, height = height, dpi = dpi, bg = bg
    )
    .cat_saved("PlotDumbbell: the plot has been saved to", filename,
               sprintf("%sx%s in", format(width), format(height)), existed,
               toupper(tools::file_ext(filename)))
  } else {
    print(p)
  }

  invisible(p)
}


# ---- Internal: build auto inset paired boxplot/violin ----
.build_dumbbell_inset <- function(
    data, x_col, xend_col,
    label_x, label_xend,
    color_x, color_xend,
    inset_type, inset_test,
    paired_line, jitter,
    theme_obj
) {
  if (!is.character(inset_type) || length(inset_type) != 1L ||
      is.na(inset_type) || !inset_type %in% c("boxplot", "violin")) {
    stop("inset_type must be 'boxplot' or 'violin'.", call. = FALSE)
  }
  if (is.factor(label_x)) label_x <- as.character(label_x)
  if (is.factor(label_xend)) label_xend <- as.character(label_xend)
  group_labels <- as.character(c(label_x, label_xend))
  group_keys <- make.unique(group_labels)
  group_labels <- stats::setNames(group_labels, group_keys)

  # Reshape to long format
  df_long <- rbind(
    data.frame(
      .id    = seq_len(nrow(data)),
      .group = group_keys[1L],
      .value = data[[x_col]],
      stringsAsFactors = FALSE
    ),
    data.frame(
      .id    = seq_len(nrow(data)),
      .group = group_keys[2L],
      .value = data[[xend_col]],
      stringsAsFactors = FALSE
    )
  )
  df_long$.group <- factor(df_long$.group, levels = group_keys)

  # Colour mapping
  fill_vals  <- stats::setNames(c(color_x, color_xend), group_keys)
  color_vals <- fill_vals

  # Build inset
  pi <- ggplot2::ggplot(df_long, ggplot2::aes(
    x = .data$.group, y = .data$.value, fill = .data$.group
  ))

  if (inset_type == "violin") {
    pi <- pi + ggplot2::geom_violin(
      alpha = 0.7, width = 0.6, trim = TRUE,
      color = NA
    )
  } else {
    pi <- pi + ggplot2::geom_boxplot(
      width = 0.5, alpha = 0.7, outlier.shape = NA
    )
  }

  # Paired connecting lines
  if (paired_line) {
    pi <- pi + ggplot2::geom_line(
      ggplot2::aes(group = .data$.id),
      color = "grey60", linewidth = 0.2, alpha = 0.4
    )
  }

  # Jitter points
  if (jitter) {
    pi <- pi + ggplot2::geom_jitter(
      ggplot2::aes(color = .data$.group),
      width = 0.12, size = 1, alpha = 0.6
    )
  }

  pi <- pi +
    ggplot2::scale_x_discrete(labels = group_labels) +
    ggplot2::scale_fill_manual(values = fill_vals, labels = group_labels)
  if (jitter) {
    pi <- pi + ggplot2::scale_color_manual(values = color_vals, labels = group_labels)
  }

  # Significance bracket
  if (inset_test != "none") {
    test_fn <- switch(inset_test,
      "t.test" = .con_pairwise_test("t.test"),
      "wilcox" = stats::wilcox.test,
      stop("inset_test must be 't.test', 'wilcox', or 'none'.", call. = FALSE)
    )
    test_x <- data[[x_col]]
    test_xend <- data[[xend_col]]
    if (inherits(test_x, "difftime")) {
      test_x <- as.numeric(test_x, units = "secs")
    } else if (inherits(test_x, c("Date", "POSIXt")) ||
               (is.integer(test_x) && !is.object(test_x))) {
      test_x <- as.double(test_x)
    }
    if (inherits(test_xend, "difftime")) {
      test_xend <- as.numeric(test_xend, units = "secs")
    } else if (inherits(test_xend, c("Date", "POSIXt")) ||
               (is.integer(test_xend) && !is.object(test_xend))) {
      test_xend <- as.double(test_xend)
    }
    test_res <- test_fn(test_x, test_xend,
                        paired = TRUE, alternative = "two.sided")
    p_val <- test_res$p.value
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) {
      sprintf("p = %.1e", p_val)
    } else {
      sprintf("p = %.3f", p_val)
    }

    y_max <- max(df_long$.value, na.rm = TRUE)
    y_range <- range(df_long$.value, na.rm = TRUE)
    if (is.integer(y_range) && !is.object(y_range)) y_range <- as.double(y_range)
    y_span <- diff(y_range)
    bracket_offset <- y_span * 0.05
    text_offset <- y_span * 0.04
    if (!is.finite(y_span) && !is.object(y_range) && all(is.finite(y_range))) {
      bracket_offset <- y_range[2L] * 0.05 - y_range[1L] * 0.05
      text_offset <- y_range[2L] * 0.04 - y_range[1L] * 0.04
    }
    bracket_y <- y_max + bracket_offset

    pi <- pi +
      ggplot2::annotate("segment", x = 1, xend = 2,
                        y = bracket_y, yend = bracket_y,
                        color = "black", linewidth = 0.4) +
      ggplot2::annotate("text", x = 1.5, y = bracket_y + text_offset,
                        label = p_fmt, size = 2.5, color = "black")
  }

  # Theme: compact inset styling
  pi <- pi +
    ggplot2::labs(x = NULL, y = NULL) +
    theme_obj +
    ggplot2::theme(
      legend.position  = "none",
      axis.text.x      = ggplot2::element_text(color = "black", size = 7,
                                                face = "bold"),
      axis.text.y      = ggplot2::element_text(color = "black", size = 7),
      axis.line        = ggplot2::element_line(linewidth = 0.4),
      axis.ticks       = ggplot2::element_line(linewidth = 0.3),
      plot.background  = ggplot2::element_rect(fill = "white", color = "grey70",
                                                linewidth = 0.5),
      plot.margin      = ggplot2::margin(4, 4, 3, 3)
    )

  pi
}
