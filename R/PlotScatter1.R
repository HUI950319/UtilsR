#' Grouped Scatter Plot with Marginal Boxplots
#'
#' Single-group scatter plot with top and right marginal boxplots (with jitter)
#' and optional annotation panel (PERMANOVA / correlation). Suitable for
#' PCoA/NMDS ordination or gene correlation visualisation.
#'
#' For dual-group scatter with separate marginal panels, see [PlotScatter2()].
#' For paired scatter with rotated histogram inset, see [PlotScatter3()].
#'
#' @param data A data.frame.
#' @param x Column name for the X axis.
#' @param y Column name for the Y axis.
#' @param group Column name for the grouping variable.
#' @param group_levels Group order. NULL = data order.
#' @param colors Colour vector for groups. NULL = auto palette.
#' @param shapes Shape vector for groups. NULL = auto.
#' @param point_size Point size. Default 4.
#' @param point_alpha Point transparency. Default 0.8.
#' @param show_ellipse Whether to draw group ellipses. Default TRUE.
#' @param ellipse_level Ellipse confidence level. Default 0.95.
#' @param show_refline Whether to show x=0, y=0 reference lines. Default TRUE.
#' @param show_regression Whether to show a regression line. Default FALSE.
#' @param reg_method Regression method: "lm" or "loess". Default "lm".
#' @param show_cor Whether to display correlation coefficient. Default FALSE.
#' @param cor_method Correlation method: "pearson" or "spearman". Default "pearson".
#' @param annot_text Custom annotation text (e.g. PERMANOVA result). NULL = none.
#' @param annot_size Annotation text size. Default 4.
#' @param xlim Custom X axis limits, e.g. \code{c(0, 1)}. NULL = auto (with
#'   default 5\% expansion). When set, expansion is suppressed (\code{expand = FALSE}).
#' @param ylim Custom Y axis limits, e.g. \code{c(0, 1)}. NULL = auto.
#' @param xlab X axis label. NULL = column name.
#' @param ylab Y axis label. NULL = column name.
#' @param title Plot title. Default NULL.
#' @param marginal_type Marginal plot type: "boxplot", "violin", or "violin_box".
#' @param violin_scale Scale method for violin geom: \code{"width"} (default,
#'   normalises max-width so both marginals look visually consistent),
#'   \code{"area"}, or \code{"count"}.
#' @param box_jitter Whether to add jitter points in marginal plots. Default TRUE.
#' @param layout_ratio Size ratio c(marginal, main). Default c(1, 4).
#' @param legend_pos Legend position. Default c(0.85, 0.15).
#' @param legend_theme Legend theme object (e.g. \code{theme_legend1()}). Default NULL.
#' @param theme_use Theme for the main scatter panel. Default NULL (built-in theme).
#' @param raster Logical. Rasterise scatter points to reduce file size.
#'   \code{FALSE} = vector (default). \code{TRUE} = raster.
#' @param raster_method Character. Rasterisation backend when \code{raster = TRUE}:
#'   \code{"scattermore"} (default, fast, requires \pkg{scattermore}) or
#'   \code{"ggrastr"} (faithful colours, requires \pkg{ggrastr}).
#' @param raster.dpi Integer. Raster resolution in pixels (for scattermore) or
#'   DPI (for ggrastr). Default \code{512}.
#' @param filename Output file path. NULL = no save.
#' @param width Output width in inches. Default 10.
#' @param height Output height in inches. Default 8.
#' @param dpi Output resolution. Default 300.
#'
#' @return A patchwork object (combined plot).
#'
#' @examples
#' library(ggplot2)
#'
#' # Simulated PCoA data
#' set.seed(42)
#' df <- data.frame(
#'   PC1   = c(rnorm(30, -1), rnorm(30, 1)),
#'   PC2   = c(rnorm(30, 0.5), rnorm(30, -0.5)),
#'   Group = rep(c("Control", "Treatment"), each = 30)
#' )
#'
#' # Basic usage
#' PlotScatter1(df, x = "PC1", y = "PC2", group = "Group")
#'
#' # With correlation and violin marginals
#' PlotScatter1(df, x = "PC1", y = "PC2", group = "Group",
#'              show_cor = TRUE, marginal_type = "violin")
#'
#' # Custom annotation (e.g. PERMANOVA)
#' PlotScatter1(df, x = "PC1", y = "PC2", group = "Group",
#'              annot_text = "PERMANOVA\nR2 = 0.15, p = 0.001")
#'
#' @family scatter plots
#' @export
PlotScatter1 <- function(
    data,
    x,
    y,
    group,
    group_levels = NULL,       # group order
    colors = NULL,             # colour per group
    shapes = NULL,             # shape per group
    point_size = 4,            # point size
    point_alpha = 0.8,         # point transparency
    show_ellipse = TRUE,       # group ellipse
    ellipse_level = 0.95,      # ellipse confidence level
    show_refline = TRUE,       # x=0, y=0 reference lines
    show_regression = FALSE,   # regression line
    reg_method = "lm",         # regression method
    show_cor = FALSE,          # show correlation
    cor_method = "pearson",    # correlation method
    annot_text = NULL,         # custom annotation text
    annot_size = 4,            # annotation text size
    xlim = NULL,               # custom x axis limits c(min, max); NULL = auto
    ylim = NULL,               # custom y axis limits c(min, max); NULL = auto
    xlab = NULL,               # x axis label
    ylab = NULL,               # y axis label
    title = NULL,              # plot title
    marginal_type = c("boxplot", "violin", "violin_box"), # marginal type
    violin_scale = "width",    # geom_violin scale: "width" | "area" | "count"
    box_jitter = TRUE,         # jitter in marginal plots
    layout_ratio = c(1, 4),    # marginal:main ratio
    legend_pos = c(0.85, 0.15),# legend position
    legend_theme = NULL,       # legend theme
    theme_use = NULL,          # main scatter theme
    raster        = FALSE,                          # rasterise scatter points
    raster_method = c("scattermore", "ggrastr"),    # rasterisation backend
    raster.dpi    = 512,                            # pixels (scattermore) or DPI (ggrastr)
    filename = NULL,           # output file path
    width = 10,                # output width
    height = 8,                # output height
    dpi = 300                  # output resolution
) {

  # ---- Check dependencies ----
  for (pkg in c("ggplot2", "patchwork")) {
    if (!requireNamespace(pkg, quietly = TRUE))
      stop(sprintf("Package '%s' is required.", pkg))
  }

  marginal_type <- match.arg(marginal_type)
  raster_method <- match.arg(raster_method)

  # ---- Validate columns ----
  for (col in c(x, y, group)) {
    if (!col %in% colnames(data)) stop(sprintf("Column '%s' not found in data.", col))
  }

  df <- data
  if (!is.null(group_levels)) {
    df[[group]] <- factor(df[[group]], levels = group_levels)
  } else if (!is.factor(df[[group]])) {
    df[[group]] <- factor(df[[group]], levels = unique(df[[group]]))
  }

  grp_lvls <- levels(df[[group]])
  n_grp <- length(grp_lvls)

  # ---- Default colours ----
  if (is.null(colors)) {
    default_cols <- c("#B2182B", "#E69F00", "#56B4E9", "#009E73",
                      "#F0E442", "#0072B2", "#D55E00", "#CC79A7",
                      "#CC6666", "#9999CC", "#66CC99", "#ADD1E5")
    colors <- default_cols[seq_len(n_grp)]
  }
  if (length(colors) < n_grp) colors <- rep_len(colors, n_grp)

  # ---- Default shapes ----
  if (is.null(shapes)) {
    shapes <- c(16, 17, 15, 18, 8, 7, 9, 10, 11, 12, 13, 14)[seq_len(n_grp)]
  }
  if (length(shapes) < n_grp) shapes <- rep_len(shapes, n_grp)

  # ---- Labels ----
  if (is.null(xlab)) xlab <- x
  if (is.null(ylab)) ylab <- y

  # ---- Point layer helper: vector / scattermore / ggrastr ----
  .pt_layer <- function(size_val, alpha_val) {
    if (isTRUE(raster)) {
      if (raster_method == "scattermore") {
        if (!requireNamespace("scattermore", quietly = TRUE))
          stop("Package 'scattermore' is required for raster_method = 'scattermore'.",
               call. = FALSE)
        return(scattermore::geom_scattermore(
          pointsize = ceiling(size_val), alpha = alpha_val,
          pixels = c(raster.dpi, raster.dpi)
        ))
      } else {
        if (!requireNamespace("ggrastr", quietly = TRUE))
          stop("Package 'ggrastr' is required for raster_method = 'ggrastr'.",
               call. = FALSE)
        return(ggrastr::geom_point_rast(size = size_val, alpha = alpha_val,
                                        raster.dpi = raster.dpi))
      }
    }
    ggplot2::geom_point(size = size_val, alpha = alpha_val)
  }

  # ---- Main scatter plot ----
  p_main <- ggplot2::ggplot(df, ggplot2::aes(
    x = .data[[x]], y = .data[[y]],
    colour = .data[[group]], shape = .data[[group]]
  )) +
    .pt_layer(point_size, point_alpha) +
    ggplot2::scale_colour_manual(values = colors) +
    ggplot2::scale_shape_manual(values = shapes) +
    ggplot2::labs(x = xlab, y = ylab, title = title)

  # Apply user theme
  if (!is.null(theme_use)) {
    if (is.function(theme_use)) {
      p_main <- p_main + theme_use()
    } else if (inherits(theme_use, "theme")) {
      p_main <- p_main + theme_use
    }
  }

  # Panel and legend theme
  panel_theme <- list(
    panel.background = ggplot2::element_rect(fill = "white", colour = "black"),
    panel.grid = ggplot2::element_blank(),
    axis.title = ggplot2::element_text(size = 14, color = "black"),
    axis.text = ggplot2::element_text(size = 12, colour = "black"),
    axis.ticks = ggplot2::element_line(color = "black"),
    legend.title = ggplot2::element_blank(),
    legend.text = ggplot2::element_text(size = 12),
    legend.key = ggplot2::element_blank(),
    legend.position = legend_pos,
    legend.background = ggplot2::element_rect(colour = "grey70", linewidth = 0.3)
  )
  p_main <- p_main + do.call(ggplot2::theme, panel_theme)

  # Custom legend theme
  if (!is.null(legend_theme) && inherits(legend_theme, "theme")) {
    p_main <- p_main + legend_theme
  }

  p_main <- p_main +
    ggplot2::guides(
      colour = ggplot2::guide_legend(override.aes = list(size = 4))
    )

  # Reference lines
  if (show_refline) {
    p_main <- p_main +
      ggplot2::geom_vline(xintercept = 0, linetype = "dotted", colour = "grey50") +
      ggplot2::geom_hline(yintercept = 0, linetype = "dotted", colour = "grey50")
  }

  # Group ellipses
  if (show_ellipse) {
    p_main <- p_main +
      ggplot2::stat_ellipse(
        ggplot2::aes(colour = .data[[group]]),
        level = ellipse_level, show.legend = FALSE
      )
  }

  # Regression line
  if (show_regression) {
    p_main <- p_main +
      ggplot2::geom_smooth(
        mapping = ggplot2::aes(x = .data[[x]], y = .data[[y]]),
        method = reg_method, formula = y ~ x,
        colour = "red", linetype = "dashed", se = FALSE,
        inherit.aes = FALSE
      )
  }

  # Correlation annotation — only assigned to annot_text (rendered in p_annot)
  if (show_cor) {
    cor_res <- stats::cor.test(df[[x]], df[[y]], method = cor_method)
    cor_label <- sprintf(
      "%s:\nr = %.3f\np = %s",
      tools::toTitleCase(cor_method),
      cor_res$estimate,
      format(cor_res$p.value, digits = 3, scientific = TRUE)
    )
    if (is.null(annot_text)) annot_text <- cor_label
  }

  # ---- Helper: add marginal geom ----
  # violin_scale: passed to geom_violin(scale=); "width" normalises max-width
  # across groups so that both marginal panels look visually consistent
  # regardless of how concentrated or spread the data distribution is.
  .add_marginal_geom <- function(p, mtype, jitter, vscale = violin_scale) {
    if (mtype == "violin") {
      p <- p +
        ggplot2::geom_violin(show.legend = FALSE, alpha = 0.7,
                              trim = FALSE, linewidth = 0.4, scale = vscale)
    } else if (mtype == "violin_box") {
      p <- p +
        ggplot2::geom_violin(show.legend = FALSE, alpha = 0.5,
                              trim = FALSE, linewidth = 0.4, scale = vscale) +
        ggplot2::geom_boxplot(show.legend = FALSE, width = 0.15,
                               outlier.shape = NA, alpha = 0.8)
    } else {
      p <- p +
        ggplot2::geom_boxplot(show.legend = FALSE, outlier.shape = NA) +
        ggplot2::stat_boxplot(geom = "errorbar", width = 0.15, linewidth = 0.4)
    }
    if (jitter) {
      p <- p +
        ggplot2::geom_jitter(width = 0.15, size = 1, alpha = 0.5,
                              show.legend = FALSE)
    }
    p
  }

  # ---- p_main: show x-axis (bottom) and y-axis (left) ----------------------
  # Axis scale values live on the main scatter; marginals show distributions only.
  # plot.margin = 0 so gtable can equalise margins precisely.
  p_main <- p_main +
    ggplot2::theme(
      axis.text.x  = ggplot2::element_text(size = 11, colour = "black"),
      axis.ticks.x = ggplot2::element_line(colour = "black"),
      axis.text.y  = ggplot2::element_text(size = 11, colour = "black"),
      axis.ticks.y = ggplot2::element_line(colour = "black"),
      plot.margin  = ggplot2::margin(0, 0, 0, 0)
    )

  # Custom axis limits: coord_cartesian clips the view without removing data.
  # expand = FALSE removes the default 5% padding when limits are explicitly set.
  if (!is.null(xlim) || !is.null(ylim)) {
    p_main <- p_main +
      ggplot2::coord_cartesian(xlim = xlim, ylim = ylim, expand = FALSE)
  }

  # ---- Top marginal (x variable by group, coord_flip) ----------------------
  # After coord_flip: horizontal = X variable (hidden, shown on p_main bottom)
  #                   vertical   = group names (kept on left)
  p_top <- ggplot2::ggplot(
    df, ggplot2::aes(x = .data[[group]], y = .data[[x]], fill = .data[[group]])
  )
  p_top <- .add_marginal_geom(p_top, marginal_type, box_jitter)
  # coord_flip: original y-axis = x variable values; ylim sets its limits.
  # expand = FALSE when xlim is provided so the range matches p_main exactly.
  p_top <- p_top +
    ggplot2::scale_fill_manual(values = colors) +
    (if (!is.null(xlim))
       ggplot2::coord_flip(ylim = xlim, expand = FALSE)
     else
       ggplot2::coord_flip()) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid   = ggplot2::element_blank(),
      axis.title   = ggplot2::element_blank(),
      axis.line    = ggplot2::element_line(colour = "black"),
      # horizontal axis (after flip) = X variable values → hide (shown on p_main)
      axis.text.x  = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      # vertical axis (after flip) = group names → keep
      axis.text.y  = ggplot2::element_text(colour = "black", size = 11),
      axis.ticks.y = ggplot2::element_line(colour = "black"),
      plot.margin  = ggplot2::margin(0, 0, 0, 0)
    )

  # ---- Right marginal (y variable by group) --------------------------------
  # Y scale values are on p_main left; only group names remain at bottom.
  p_right <- ggplot2::ggplot(
    df, ggplot2::aes(x = .data[[group]], y = .data[[y]], fill = .data[[group]])
  )
  p_right <- .add_marginal_geom(p_right, marginal_type, box_jitter)
  # coord_cartesian on the right marginal: ylim aligns its y-extent with p_main.
  # expand = FALSE when ylim is provided so the range matches p_main exactly.
  p_right <- p_right +
    ggplot2::scale_fill_manual(values = colors) +
    (if (!is.null(ylim))
       ggplot2::coord_cartesian(ylim = ylim, expand = FALSE)
     else
       ggplot2::coord_cartesian()) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid   = ggplot2::element_blank(),
      axis.title   = ggplot2::element_blank(),
      axis.line    = ggplot2::element_line(colour = "black"),
      # y-axis = Y variable values → hide (shown on p_main)
      axis.text.y  = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      # x-axis = group names → keep (angled)
      axis.text.x  = ggplot2::element_text(
        colour = "black", size = 11, angle = 45, vjust = 1, hjust = 1
      ),
      axis.ticks.x = ggplot2::element_line(colour = "black"),
      plot.margin  = ggplot2::margin(0, 0, 0, 0)
    )

  # ---- Top-right annotation panel ------------------------------------------
  p_annot <- ggplot2::ggplot() + ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))

  if (!is.null(annot_text)) {
    p_annot <- p_annot +
      ggplot2::annotate(
        "text", x = 0.5, y = 0.5, label = annot_text,
        size = annot_size, hjust = 0.5, vjust = 0.5
      ) +
      ggplot2::xlim(0, 1) + ggplot2::ylim(0, 1)
  }

  # ---- Gapless assembly via gtable -----------------------------------------
  # cowplot::align_plots equalises panels by PADDING, which produces a visible
  # gap between the main scatter and the marginals.  Instead we directly
  # manipulate the underlying gtable column/row widths so that:
  #   • g_top$widths  == g_main$widths   → x-axes align pixel-perfectly
  #   • g_main$heights == g_right$heights → y-axes align pixel-perfectly
  # gtable_cbind / gtable_rbind then stacks them with ZERO extra spacing.

  M <- layout_ratio[2]
  S <- layout_ratio[1]

  # --- 1. Convert ggplot objects to gtable grobs ---
  g_top   <- ggplot2::ggplotGrob(p_top)
  g_annot <- ggplot2::ggplotGrob(p_annot)
  g_main  <- ggplot2::ggplotGrob(p_main)
  g_right <- ggplot2::ggplotGrob(p_right)

  # --- 2. Locate the panel cell (same row/col index for all ggplot2 grobs) ---
  pc <- g_main$layout$l[g_main$layout$name == "panel"][1]  # panel column
  pr <- g_main$layout$t[g_main$layout$name == "panel"][1]  # panel row

  # --- 3. Impose layout_ratio via null units on the panel cell ---
  # Left column (p_top / p_main)  → panel width  = M null
  # Right column (p_annot / p_right) → panel width = S null
  # Top row (p_top / p_annot)     → panel height = S null
  # Bottom row (p_main / p_right) → panel height = M null
  g_main$widths[pc]  <- grid::unit(M, "null")
  g_top$widths[pc]   <- grid::unit(M, "null")
  g_right$widths[pc] <- grid::unit(S, "null")
  g_annot$widths[pc] <- grid::unit(S, "null")

  g_main$heights[pr]  <- grid::unit(M, "null")
  g_right$heights[pr] <- grid::unit(M, "null")
  g_top$heights[pr]   <- grid::unit(S, "null")
  g_annot$heights[pr] <- grid::unit(S, "null")

  # --- 4. Equalise non-panel margins within each column / row ---
  # Left column: g_top and g_main must share identical widths so their panels
  # sit at the same horizontal position (x-axis alignment).
  eq_w_L <- grid::unit.pmax(g_top$widths,   g_main$widths)
  g_top$widths  <- eq_w_L
  g_main$widths <- eq_w_L

  # Right column: g_annot and g_right must share identical widths.
  eq_w_R <- grid::unit.pmax(g_annot$widths, g_right$widths)
  g_annot$widths <- eq_w_R
  g_right$widths <- eq_w_R

  # --- 5. Assemble with zero gaps ---
  # gtable_cbind: concatenates widths, pmax-equalises heights → rows align
  # gtable_rbind: concatenates heights, pmax-equalises widths → cols align
  top_row  <- cbind(g_top,  g_annot)   # dispatches to cbind.gtable
  bot_row  <- cbind(g_main, g_right)
  combined <- rbind(top_row, bot_row)   # dispatches to rbind.gtable

  # Wrap in a patchwork-compatible object so ggsave() works normally
  p_combined <- patchwork::wrap_elements(full = combined)

  # ---- Save or return ----
  if (!is.null(filename)) {
    ggplot2::ggsave(filename, p_combined,
                    width = width, height = height, dpi = dpi, bg = "white")
    message(sprintf("Plot saved to: %s", filename))
  }

  p_combined
}
