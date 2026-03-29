# ============================================================================
# PlotDumbbell.R -- Dumbbell (lollipop comparison) chart
# ============================================================================

#' Dumbbell Chart for Paired Comparisons
#'
#' Create a horizontal dumbbell chart showing paired values (e.g., before/after,
#' control/treatment) for each category. Supports auto-sorting, mean reference
#' lines, delta labels, and an optional inset plot via patchwork.
#'
#' @param data A data.frame containing category, start, and end columns.
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
#' @param top_n Integer. Show only top N categories after sorting. Default
#'   \code{NULL} (show all).
#' @param color_x Colour for start (x) points. Default \code{"#00468BFF"}.
#' @param color_xend Colour for end (xend) points. Default \code{"#ED0000FF"}.
#' @param label_x Label for start points (used in legend and auto inset).
#'   Default \code{NULL} (column name).
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
#' @param theme_use Theme function, string, or theme object. Default
#'   \code{theme_my}. Controls axis text/title/line styling.
#' @param inset_plot Inset plot specification. One of:
#'   \itemize{
#'     \item \code{NULL} — no inset (default).
#'     \item \code{"auto"} — auto-generate a paired boxplot from the dumbbell
#'       data, with paired lines, jitter points, and a significance bracket.
#'     \item A \code{ggplot} object — embed a custom inset plot.
#'   }
#' @param inset_type Type of auto-generated inset: \code{"boxplot"} (default)
#'   or \code{"violin"}. Only used when \code{inset_plot = "auto"}.
#' @param inset_test Paired test for auto inset significance bracket:
#'   \code{"t.test"}, \code{"wilcox"}, or \code{"none"}. Default
#'   \code{"t.test"}. Only used when \code{inset_plot = "auto"}.
#' @param inset_paired_line Logical. Show paired connecting lines in auto
#'   inset? Default \code{TRUE}.
#' @param inset_jitter Logical. Show jitter points in auto inset? Default
#'   \code{TRUE}.
#' @param inset_theme_use Theme for auto inset. Default \code{NULL} (uses
#'   the same \code{theme_use} as the main plot with compact styling).
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

  # ---- Parse theme ----
  theme_fn <- .parse_theme(theme_use)

  # ---- Validate inputs ----
  data <- as.data.frame(data)
  for (col in c(x_col, xend_col, y_col)) {
    if (!col %in% colnames(data)) {
      stop("Column '", col, "' not found in data.", call. = FALSE)
    }
  }

  # ---- Labels ----
  if (is.null(label_x))    label_x    <- x_col
  if (is.null(label_xend)) label_xend <- xend_col

  # ---- Compute delta ----
  data$.delta <- data[[xend_col]] - data[[x_col]]

  # ---- Sort ----
  sort_by <- match.arg(sort_by, c("end", "start", "delta", "none"))
  if (sort_by != "none") {
    sort_vals <- switch(sort_by,
      "end"   = data[[xend_col]],
      "start" = data[[x_col]],
      "delta" = data$.delta
    )
    ord <- order(sort_vals, decreasing = sort_descending)
    data <- data[ord, , drop = FALSE]
  }

  # ---- Top N ----
  if (!is.null(top_n) && top_n > 0 && top_n < nrow(data)) {
    data <- utils::tail(data, top_n)
  }

  # ---- Factor Y axis (preserving sorted order) ----
  data[[y_col]] <- factor(data[[y_col]], levels = unique(data[[y_col]]))

  # ---- Build plot ----
  p <- ggplot2::ggplot(data)

  # Dot guide lines (behind everything)
  if (dot_guide) {
    x_min <- min(c(data[[x_col]], data[[xend_col]]), na.rm = TRUE)
    p <- p +
      ggplot2::geom_segment(
        ggplot2::aes(
          x = x_min, xend = pmax(.data[[x_col]], .data[[xend_col]]),
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
                   color = label_x),
      size = point_size, shape = point_shape
    )

  # End points (xend)
  p <- p +
    ggplot2::geom_point(
      ggplot2::aes(x = .data[[xend_col]], y = .data[[y_col]],
                   color = label_xend),
      size = point_size, shape = point_shape
    )

  # Colour scale for legend
  color_vals <- stats::setNames(c(color_x, color_xend), c(label_x, label_xend))
  p <- p +
    ggplot2::scale_color_manual(
      values = color_vals,
      guide  = ggplot2::guide_legend(
        override.aes = list(size = point_size * 0.8)
      )
    )

  # ---- Reference lines ----
  if (show_zero_line) {
    p <- p +
      ggplot2::geom_vline(
        xintercept = 0, linewidth = zero_line_width, color = zero_line_color
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
    data$.delta_label <- round(data$.delta, delta_digits)
    data$.delta_x <- pmax(data[[x_col]], data[[xend_col]])
    p <- p +
      ggplot2::geom_text(
        data = data,
        ggplot2::aes(
          x = .data$.delta_x, y = .data[[y_col]],
          label = .data$.delta_label
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
  if (legend_pos == "auto") legend_pos <- "br"

  if (legend_pos == "none") {
    leg_position <- "none"
  } else if (legend_pos %in% names(corner_map)) {
    leg_position <- corner_map[[legend_pos]]
  } else {
    # Standard ggplot2 positions: "bottom", "top", "left", "right"
    leg_position <- legend_pos
  }

  # ---- Labels and theme ----
  p <- p +
    ggplot2::labs(x = x_label, y = y_label, title = title) +
    theme_fn() +
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
      y_col      = y_col,
      label_x    = label_x,
      label_xend = label_xend,
      color_x    = color_x,
      color_xend = color_xend,
      inset_type = inset_type,
      inset_test = inset_test,
      paired_line = inset_paired_line,
      jitter     = inset_jitter,
      theme_fn   = if (!is.null(inset_theme_use)) .parse_theme(inset_theme_use) else theme_fn
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
    ggplot2::ggsave(
      filename, p,
      width = width, height = height, dpi = dpi, bg = bg
    )
    message("Plot saved to: ", filename)
  } else {
    print(p)
  }

  invisible(p)
}


# ---- Internal: parse theme argument ----
.parse_theme <- function(theme_use) {
  if (is.character(theme_use)) {
    tryCatch(match.fun(theme_use), error = function(e) ggplot2::theme_classic)
  } else if (is.function(theme_use)) {
    theme_use
  } else if (inherits(theme_use, "theme")) {
    local({
      obj <- theme_use
      function(...) obj
    })
  } else {
    ggplot2::theme_classic
  }
}


# ---- Internal: build auto inset paired boxplot/violin ----
.build_dumbbell_inset <- function(
    data, x_col, xend_col, y_col,
    label_x, label_xend,
    color_x, color_xend,
    inset_type, inset_test,
    paired_line, jitter,
    theme_fn
) {
  # Reshape to long format
  df_long <- rbind(
    data.frame(
      .id    = data[[y_col]],
      .group = label_x,
      .value = data[[x_col]],
      stringsAsFactors = FALSE
    ),
    data.frame(
      .id    = data[[y_col]],
      .group = label_xend,
      .value = data[[xend_col]],
      stringsAsFactors = FALSE
    )
  )
  df_long$.group <- factor(df_long$.group, levels = c(label_x, label_xend))

  # Colour mapping
  fill_vals  <- stats::setNames(c(color_x, color_xend), c(label_x, label_xend))
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
    ggplot2::scale_fill_manual(values = fill_vals) +
    ggplot2::scale_color_manual(values = color_vals)

  # Significance bracket
  if (inset_test != "none") {
    test_fn <- switch(inset_test,
      "t.test" = stats::t.test,
      "wilcox" = stats::wilcox.test,
      stop("inset_test must be 't.test', 'wilcox', or 'none'.", call. = FALSE)
    )
    test_res <- test_fn(data[[x_col]], data[[xend_col]],
                        paired = TRUE, alternative = "two.sided")
    p_val <- test_res$p.value
    p_fmt <- if (p_val < 0.001) {
      sprintf("p = %.1e", p_val)
    } else {
      sprintf("p = %.3f", p_val)
    }

    y_max <- max(df_long$.value, na.rm = TRUE)
    y_span <- diff(range(df_long$.value, na.rm = TRUE))
    bracket_y <- y_max + y_span * 0.05

    pi <- pi +
      ggplot2::annotate("segment", x = 1, xend = 2,
                        y = bracket_y, yend = bracket_y,
                        color = "black", linewidth = 0.4) +
      ggplot2::annotate("text", x = 1.5, y = bracket_y + y_span * 0.04,
                        label = p_fmt, size = 2.5, color = "black")
  }

  # Theme: compact inset styling
  pi <- pi +
    ggplot2::labs(x = NULL, y = NULL) +
    theme_fn() +
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
