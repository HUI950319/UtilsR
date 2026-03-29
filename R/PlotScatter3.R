# ============================================================================
# PlotScatter3.R -- Paired scatter plot with rotated histogram inset
# ============================================================================

#' Paired Scatter Plot with Rotated Histogram Inset
#'
#' Create a paired scatter plot with a rotated (-45 degree) difference histogram
#' inset in the upper-right corner. Suitable for Control vs Treatment paired
#' comparisons. Inspired by Cell journal figure style.
#'
#' For single-group scatter with marginal boxplots, see [PlotScatter1()].
#' For dual-group scatter with marginal boxplots, see [PlotScatter2()].
#'
#' @param data A data.frame containing x (control), y (treatment), and group columns.
#' @param x Column name for control values (X axis). Default \code{"Control"}.
#' @param y Column name for treatment values (Y axis). Default \code{"Treat"}.
#' @param group Column name for significance grouping (must have 2 levels).
#'   Default \code{"group"}.
#' @param group_levels Character vector of length 2: \code{c(insignificant,
#'   significant)}. \code{NULL} auto-detects from data.
#' @param highlight_color Colour for the significant group. Default
#'   \code{"#f71d53"}.
#' @param insig_border Border colour for insignificant points. Default
#'   \code{NULL} (same as \code{highlight_color}).
#' @param point_shape Point shape code. Default 21 (filled circle).
#' @param point_size Point size. Default 3.
#' @param point_stroke Point border width. Default 0.8.
#' @param xlab X axis label. Default \code{"Control"}.
#' @param ylab Y axis label. Default \code{"Treat"}.
#' @param axis_limits Numeric vector of length 2 for axis range. Default
#'   \code{NULL} (auto: symmetric range from data).
#' @param axis_breaks Numeric vector for axis tick positions. Default
#'   \code{NULL} (auto via \code{pretty()}).
#' @param show_refline Whether to show reference lines (x=0, y=0, y=x).
#'   Default \code{TRUE}.
#' @param test_method Paired test method: \code{"wilcox"}, \code{"t.test"}, or
#'   \code{"none"}. Default \code{"wilcox"}.
#' @param p_digits Number of digits for p-value. Default 2.
#' @param p_size Text size for p-value label. Default 4.
#' @param p_x,p_y Coordinates for p-value label. Default \code{NULL} (auto).
#' @param cor_method Correlation method: \code{"pearson"}, \code{"spearman"}, or
#'   \code{"none"}. Default \code{"pearson"}.
#' @param cor_size Text size for correlation label. Default 4.
#' @param cor_x,cor_y Coordinates for correlation label. Default \code{NULL}
#'   (auto).
#' @param hist_bins Number of histogram bins. Default 30.
#' @param hist_x_limits Histogram X axis range. Default \code{NULL} (auto).
#' @param hist_x_breaks Histogram X axis ticks. Default \code{NULL} (auto).
#' @param hist_border Histogram bar border colour. Default \code{NULL} (auto).
#' @param median_label_size Text size for median label. Default 5.
#' @param median_line_yend Height of median vertical line. Default \code{NULL}
#'   (auto).
#' @param inset_left,inset_bottom,inset_right,inset_top Inset boundaries
#'   (patchwork coordinates). Default 0.6, 0.6, 1.1, 1.1.
#' @param inset_angle Rotation angle for inset. Default -45.
#' @param inset_vp_width,inset_vp_height Viewport size for inset. Default
#'   0.85, 0.75.
#' @param theme_use Theme function, string, or theme object. Default
#'   \code{theme_my(border = FALSE, panel.grid = element_blank())}.
#' @param plot_margin Numeric vector of length 4 (top, right, bottom, left)
#'   for main plot margin. Default \code{c(80, 60, 5, 5)}.
#' @param filename Output file path. Default \code{NULL} (no save).
#' @param width Output width in inches. Default 6.
#' @param height Output height in inches. Default 6.5.
#' @param dpi Output resolution. Default 300.
#' @param bg Output background colour. Default \code{"white"}.
#'
#' @return A patchwork object (combined plot).
#'
#' @examples
#' library(ggplot2)
#'
#' # Simulated paired data (Control vs Treatment)
#' set.seed(42)
#' n <- 80
#' ctrl <- rnorm(n, mean = 0, sd = 1)
#' treat <- ctrl + rnorm(n, mean = 0.3, sd = 0.5)
#' sig <- abs(treat - ctrl) > 0.5
#' df <- data.frame(
#'   Control = ctrl,
#'   Treat   = treat,
#'   group   = ifelse(sig, "Significant", "NS")
#' )
#'
#' # Basic usage (auto axis, wilcoxon test, pearson correlation)
#' PlotScatter3(df)
#'
#' # Custom highlight colour and t-test
#' PlotScatter3(df, highlight_color = "#2a5acb", test_method = "t.test")
#'
#' # Spearman correlation, no reference lines
#' PlotScatter3(df, cor_method = "spearman", show_refline = FALSE)
#'
#' @family scatter plots
#' @export
PlotScatter3 <- function(
    data,
    x               = "Control",       # control column name (X axis)
    y               = "Treat",         # treatment column name (Y axis)
    group           = "group",         # grouping column (2 levels)
    group_levels    = NULL,            # c(insignificant, significant)
    highlight_color = "#f71d53",       # colour for significant group
    insig_border    = NULL,            # border colour for insignificant points
    point_shape     = 21,              # point shape (21 = filled circle)
    point_size      = 3,               # point size
    point_stroke    = 0.8,             # point border width
    xlab            = "Control",       # X axis label
    ylab            = "Treat",         # Y axis label
    axis_limits     = NULL,            # X/Y axis range (NULL = auto)
    axis_breaks     = NULL,            # X/Y axis ticks (NULL = auto)
    show_refline    = TRUE,            # show reference lines (x=0, y=0, y=x)
    test_method     = "wilcox",        # paired test: "wilcox"/"t.test"/"none"
    p_digits        = 2,               # p-value digits
    p_size          = 4,               # p-value text size
    p_x             = NULL,            # p-value label X position (NULL = auto)
    p_y             = NULL,            # p-value label Y position (NULL = auto)
    cor_method      = "pearson",       # correlation: "pearson"/"spearman"/"none"
    cor_size        = 4,               # correlation text size
    cor_x           = NULL,            # correlation label X position
    cor_y           = NULL,            # correlation label Y position
    hist_bins       = 30,              # histogram bin count
    hist_x_limits   = NULL,            # histogram X range (NULL = auto)
    hist_x_breaks   = NULL,            # histogram X ticks (NULL = auto)
    hist_border     = NULL,            # histogram bar border colour
    median_label_size = 5,             # median label text size
    median_line_yend  = NULL,          # median line height (NULL = auto)
    inset_left      = 0.6,             # inset left boundary
    inset_bottom    = 0.6,             # inset bottom boundary
    inset_right     = 1.1,             # inset right boundary
    inset_top       = 1.1,             # inset top boundary
    inset_angle     = -45,             # inset rotation angle
    inset_vp_width  = 0.85,            # inset viewport width
    inset_vp_height = 0.75,            # inset viewport height
    theme_use       = theme_my(border = FALSE, panel.grid = ggplot2::element_blank()),
    plot_margin     = c(80, 60, 5, 5), # main plot margin (top, right, bottom, left)
    filename        = NULL,            # output file path (NULL = no save)
    width           = 6,               # output width (inches)
    height          = 6.5,             # output height (inches)
    dpi             = 300,             # output resolution
    bg              = "white"          # output background colour
) {

  # ---- Ensure graphics device is available (needed for ggplotGrob) ----
  if (grDevices::dev.cur() == 1L) {
    grDevices::pdf(NULL)
    on.exit(grDevices::dev.off(), add = TRUE)
  }

  # ---- Parse theme ----
  if (is.character(theme_use)) {
    theme_fn <- tryCatch(match.fun(theme_use), error = function(e) {
      ggplot2::theme_classic
    })
  } else if (is.function(theme_use)) {
    theme_fn <- theme_use
  } else if (inherits(theme_use, "theme")) {
    theme_obj <- theme_use
    theme_fn  <- function(...) theme_obj
  } else {
    theme_fn <- ggplot2::theme_classic
  }

  # ---- Validate inputs ----
  data <- as.data.frame(data)
  for (col in c(x, y, group)) {
    if (!col %in% colnames(data)) {
      stop("Column '", col, "' not found in data.", call. = FALSE)
    }
  }

  if (is.null(group_levels)) {
    group_levels <- unique(data[[group]])
    if (length(group_levels) != 2) {
      stop("group must have exactly 2 levels (insignificant and significant).",
           call. = FALSE)
    }
  }
  data[[group]] <- factor(data[[group]], levels = group_levels)

  # Colour scheme
  if (is.null(insig_border)) insig_border <- highlight_color
  fill_vals   <- stats::setNames(c("#FFFFFF10", highlight_color), group_levels)
  border_vals <- stats::setNames(c(insig_border, highlight_color), group_levels)

  # ---- Auto-calculate axis_limits and axis_breaks from data ----
  if (is.null(axis_limits)) {
    data_range <- range(c(data[[x]], data[[y]]), na.rm = TRUE)
    axis_limits <- c(floor(data_range[1]), ceiling(data_range[2]))
    # Ensure symmetric if data spans both sides of zero
    if (axis_limits[1] < 0 && axis_limits[2] > 0) {
      abs_max <- max(abs(axis_limits))
      axis_limits <- c(-abs_max, abs_max)
    }
  }
  if (is.null(axis_breaks)) {
    axis_breaks <- pretty(axis_limits, n = 5)
  }

  # ---- Auto-calculate p-value label position ----
  if (is.null(p_x)) {
    p_x <- axis_limits[1] + diff(axis_limits) * 0.05
  }
  if (is.null(p_y)) {
    p_y <- axis_limits[2] - diff(axis_limits) * 0.02
  }

  # ---- Difference statistics ----
  diff_values <- data[[y]] - data[[x]]
  median_diff <- stats::median(diff_values, na.rm = TRUE)

  # ---- Paired test ----
  p_label <- NULL
  if (test_method != "none") {
    test_fn <- switch(test_method,
      "wilcox" = stats::wilcox.test,
      "t.test" = stats::t.test,
      stop("test_method must be 'wilcox', 't.test', or 'none'.", call. = FALSE)
    )
    test_res <- test_fn(data[[x]], data[[y]],
                        paired = TRUE, alternative = "two.sided")
    p_label <- paste0("p = ", format.pval(test_res$p.value, digits = p_digits))
  }

  # ---- Main scatter plot ----
  p1 <- ggplot2::ggplot(data, ggplot2::aes(
    x     = .data[[x]],
    y     = .data[[y]],
    fill  = .data[[group]],
    color = .data[[group]]
  )) +
    ggplot2::geom_point(
      shape = point_shape, size = point_size, stroke = point_stroke
    ) +
    ggplot2::scale_fill_manual(values = fill_vals) +
    ggplot2::scale_color_manual(values = border_vals)

  if (show_refline) {
    ref <- list(linetype = "dashed", color = "black", linewidth = 0.75)
    p1 <- p1 +
      do.call(ggplot2::geom_vline, c(list(xintercept = 0), ref)) +
      do.call(ggplot2::geom_hline, c(list(yintercept = 0), ref)) +
      do.call(ggplot2::geom_abline, c(list(slope = 1, intercept = 0), ref))
  }

  if (!is.null(p_label)) {
    p1 <- p1 +
      ggplot2::annotate("text", x = p_x, y = p_y, label = p_label,
                        size = p_size, hjust = 0, vjust = 1.2)
  }

  # ---- Correlation ----
  if (cor_method != "none") {
    cor_res <- stats::cor.test(data[[x]], data[[y]],
                               method = cor_method)
    r_val <- round(cor_res$estimate, 3)
    r_prefix <- if (cor_method == "spearman") "rho" else "r"
    cor_p <- cor_res$p.value
    cor_p_fmt <- if (cor_p < 0.001) "p < 0.001" else paste0("p = ", signif(cor_p, 2))
    cor_label <- paste0(r_prefix, " = ", r_val, ", ", cor_p_fmt)

    if (is.null(cor_x)) cor_x <- axis_limits[2] - diff(axis_limits) * 0.05
    if (is.null(cor_y)) cor_y <- axis_limits[1] + diff(axis_limits) * 0.08

    p1 <- p1 +
      ggplot2::annotate("text", x = cor_x, y = cor_y, label = cor_label,
                        size = cor_size, hjust = 1, vjust = 0,
                        fontface = "italic")
  }

  p1 <- p1 +
    ggplot2::scale_x_continuous(limits = axis_limits, breaks = axis_breaks) +
    ggplot2::scale_y_continuous(limits = axis_limits, breaks = axis_breaks) +
    ggplot2::labs(x = xlab, y = ylab) +
    theme_fn() +
    ggplot2::theme(
      legend.position = "none",
      plot.margin     = ggplot2::margin(
        t = plot_margin[1], r = plot_margin[2],
        b = plot_margin[3], l = plot_margin[4]
      )
    ) +
    ggplot2::coord_cartesian(clip = "off")

  # ---- Histogram ----
  if (is.null(hist_x_limits)) hist_x_limits <- axis_limits * 1.2
  if (is.null(hist_x_breaks)) {
    hist_x_breaks <- pretty(hist_x_limits, n = 4)
    hist_x_breaks <- hist_x_breaks[hist_x_breaks != 0]
  }

  if (is.null(median_line_yend)) {
    hdata <- graphics::hist(diff_values, breaks = hist_bins, plot = FALSE)
    median_line_yend <- max(max(hdata$counts) * 0.8, 1)
  }

  df_stats <- data.frame(median_diff = median_diff)

  if (is.null(hist_border)) {
    hist_color_vals <- stats::setNames(c("grey50", highlight_color), group_levels)
  } else {
    hist_color_vals <- stats::setNames(rep(hist_border, 2), group_levels)
  }

  p2 <- ggplot2::ggplot(data, ggplot2::aes(
    x     = .data[[y]] - .data[[x]],
    fill  = .data[[group]],
    color = .data[[group]]
  )) +
    ggplot2::geom_histogram(
      bins = hist_bins, position = "identity", linewidth = 1
    ) +
    ggplot2::scale_fill_manual(values = fill_vals) +
    ggplot2::scale_color_manual(values = hist_color_vals) +
    ggplot2::geom_segment(
      data = df_stats, inherit.aes = FALSE,
      ggplot2::aes(x = median_diff, xend = median_diff, y = 0, yend = median_line_yend),
      linetype = "solid", linewidth = 1, color = "black"
    ) +
    ggplot2::geom_text(
      data = df_stats, inherit.aes = FALSE,
      ggplot2::aes(x = median_diff, y = median_line_yend,
                   label = round(median_diff, 2)),
      size = median_label_size, vjust = -0.5
    ) +
    ggplot2::scale_x_continuous(
      limits = hist_x_limits, breaks = hist_x_breaks, expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(expand = c(0, 0)) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      legend.position = "none",
      axis.text       = ggplot2::element_text(size = 16),
      axis.title      = ggplot2::element_blank(),
      plot.margin     = ggplot2::margin(t = 30, r = 0, b = 0, l = 0)
    ) +
    ggplot2::coord_cartesian(clip = "off")

  # ---- Rotate and combine ----
  p2_rotated <- grid::grobTree(
    ggplot2::ggplotGrob(p2),
    vp = grid::viewport(
      width = inset_vp_width, height = inset_vp_height, angle = inset_angle
    )
  )

  # Use patchwork & to apply transparent background to ALL layers
  final_plot <- p1 + patchwork::inset_element(
    p2_rotated,
    left   = inset_left,
    bottom = inset_bottom,
    right  = inset_right,
    top    = inset_top,
    align_to = "plot"
  ) &
    ggplot2::theme(plot.background = ggplot2::element_blank())

  # ---- Save or return ----
  if (!is.null(filename)) {
    suppressWarnings(
      ggplot2::ggsave(
        filename, final_plot,
        height = height, width = width, dpi = dpi, bg = bg
      )
    )
    message("Plot saved to: ", filename)
  }

  final_plot
}
