#' Dual-Group Scatter Plot with Multi-Variable Marginal Boxplots
#'
#' Scatter plot supporting two grouping variables (colour + shape) with
#' separate marginal boxplots for each grouping variable. Right-side panels
#' show column-wise boxplots, bottom panels show row-wise boxplots, arranged
#' via patchwork area layout. Suitable for multi-cohort PCoA/NMDS analysis or
#' two-factor gene correlation plots.
#'
#' For single-group scatter with marginal boxplots, see [PlotScatter1()].
#' For paired scatter with rotated histogram inset, see [PlotScatter3()].
#'
#' @param data A data.frame.
#' @param x Column name for the X axis.
#' @param y Column name for the Y axis.
#' @param group Column name for colour grouping (e.g. Study).
#' @param group2 Column name for shape grouping (e.g. Group). NULL = no shape grouping.
#' @param colors Named colour vector for \code{group} levels. NULL = auto palette.
#' @param shapes Named shape vector for \code{group2} levels. NULL = auto.
#' @param fill_colors_shape Fill colours for \code{group2} in marginal boxplots. NULL = auto.
#' @param point_size Point size. Default 2.
#' @param point_alpha Point transparency. Default 0.8.
#' @param show_ellipse Whether to draw group ellipses (based on \code{group}). Default FALSE.
#' @param show_cor Whether to auto-compute and display correlation. Default FALSE.
#' @param cor_method Correlation method: "pearson" or "spearman". Default "pearson".
#' @param show_regression Whether to show a regression line. Default FALSE.
#' @param reg_method Regression method: "lm" or "loess". Default "lm".
#' @param annot_text Annotation text in main plot (e.g. PERMANOVA). NULL = none.
#'   Manual input overrides \code{show_cor} auto text.
#' @param annot_pos Annotation position c(x, y). NULL = auto top-left.
#' @param annot_size Annotation text size. Default 5.
#' @param xlab X axis label. NULL = column name.
#' @param ylab Y axis label. NULL = column name.
#' @param x_top Whether to place X axis on top. Default TRUE.
#' @param marginal_type Marginal plot type: "boxplot", "violin", or "violin_box".
#' @param box_width Box/violin width in marginal plots. Default 0.7.
#' @param base_size Base font size. Default 16.
#' @param legend_color_pos Colour legend position. Default "none" (shown via marginal boxes).
#' @param legend_shape_pos Shape legend position. Default c(0.15, 0.15).
#' @param layout_main Main plot grid size (rows/cols). Default 10.
#' @param layout_margin Marginal plot grid size (rows/cols). Default 3.
#' @param filename Output file path. NULL = no save.
#' @param width Output width in inches. Default 14.
#' @param height Output height in inches. Default 12.
#' @param dpi Output resolution. Default 300.
#'
#' @return A patchwork object (combined plot).
#'
#' @examples
#' library(ggplot2)
#'
#' # Simulated multi-cohort PCoA data
#' set.seed(42)
#' df <- data.frame(
#'   PC1   = c(rnorm(20, -1), rnorm(20, 1), rnorm(20, 0)),
#'   PC2   = c(rnorm(20, 0.5), rnorm(20, -0.5), rnorm(20, 0)),
#'   Study = rep(c("Study_A", "Study_B", "Study_C"), each = 20),
#'   Group = rep(c("Ctrl", "Case"), 30)
#' )
#'
#' # Single grouping (colour only)
#' PlotScatter2(df, x = "PC1", y = "PC2", group = "Study")
#'
#' # Dual grouping (colour + shape)
#' PlotScatter2(df, x = "PC1", y = "PC2",
#'              group = "Study", group2 = "Group")
#'
#' # With correlation and violin marginals
#' PlotScatter2(df, x = "PC1", y = "PC2",
#'              group = "Study", group2 = "Group",
#'              show_cor = TRUE, marginal_type = "violin")
#'
#' @family scatter plots
#' @export
PlotScatter2 <- function(
    data,
    x,
    y,
    group,
    group2 = NULL,             # second grouping column (shape)
    colors = NULL,             # colour per group level
    shapes = NULL,             # shape per group2 level
    fill_colors_shape = NULL,  # fill for group2 marginal boxes
    point_size = 2,            # point size
    point_alpha = 0.8,         # point transparency
    show_ellipse = FALSE,      # group ellipse
    show_cor = FALSE,          # show correlation
    cor_method = "pearson",    # correlation method
    show_regression = FALSE,   # regression line
    reg_method = "lm",         # regression method
    annot_text = NULL,         # annotation text
    annot_pos = NULL,          # annotation position
    annot_size = 5,            # annotation text size
    xlab = NULL,               # x axis label
    ylab = NULL,               # y axis label
    x_top = TRUE,              # x axis on top
    marginal_type = c("boxplot", "violin", "violin_box"), # marginal type
    box_width = 0.7,           # box/violin width
    base_size = 16,            # base font size
    legend_color_pos = "none", # colour legend position
    legend_shape_pos = c(0.15, 0.15), # shape legend position
    layout_main = 10,          # main plot grid size
    layout_margin = 3,         # marginal plot grid size
    filename = NULL,           # output file path
    width = 14,                # output width
    height = 12,               # output height
    dpi = 300                  # output resolution
) {

  marginal_type <- match.arg(marginal_type)

  # ---- Check dependencies ----
  for (pkg in c("ggplot2", "patchwork")) {
    if (!requireNamespace(pkg, quietly = TRUE))
      stop(sprintf("Package '%s' is required.", pkg))
  }

  # ---- Validate columns ----
  need_cols <- c(x, y, group)
  if (!is.null(group2)) need_cols <- c(need_cols, group2)
  for (col in need_cols) {
    if (!col %in% colnames(data)) stop(sprintf("Column '%s' not found in data.", col))
  }

  df <- data
  df[[group]] <- factor(df[[group]], levels = unique(df[[group]]))
  if (!is.null(group2)) {
    df[[group2]] <- factor(df[[group2]], levels = unique(df[[group2]]))
  }

  # ---- Colours / shapes ----
  color_lvls <- levels(df[[group]])
  n_color <- length(color_lvls)

  if (is.null(colors)) {
    default_cols <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
                      "#FF7F00", "#A65628", "#F781BF", "#999999",
                      "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3")
    colors <- stats::setNames(default_cols[seq_len(n_color)], color_lvls)
  }
  if (is.null(names(colors))) {
    colors <- stats::setNames(colors[seq_len(n_color)], color_lvls)
  }

  if (!is.null(group2)) {
    shape_lvls <- levels(df[[group2]])
    n_shape <- length(shape_lvls)
    if (is.null(shapes)) {
      shapes <- stats::setNames(c(16, 17, 15, 18, 8, 7)[seq_len(n_shape)],
                                 shape_lvls)
    }
    if (is.null(fill_colors_shape)) {
      shape_pal <- c("#FFA500", "#4682B4", "#2CA02C", "#D62728",
                     "#9467BD", "#8C564B")
      fill_colors_shape <- stats::setNames(shape_pal[seq_len(n_shape)], shape_lvls)
    }
  }

  if (is.null(xlab)) xlab <- x
  if (is.null(ylab)) ylab <- y

  # ---- Collect margin variables (for marginal boxplots) ----
  margin_vars <- list()
  margin_vars[[group]] <- list(
    col = group, fill = colors, label = group
  )
  if (!is.null(group2)) {
    margin_vars[[group2]] <- list(
      col = group2, fill = fill_colors_shape, label = group2
    )
  }

  # ---- Main scatter plot ----
  if (!is.null(group2)) {
    p_main <- ggplot2::ggplot(df, ggplot2::aes(
      x = .data[[x]], y = .data[[y]],
      color = .data[[group]], shape = .data[[group2]]
    ))
  } else {
    p_main <- ggplot2::ggplot(df, ggplot2::aes(
      x = .data[[x]], y = .data[[y]],
      color = .data[[group]]
    ))
  }

  p_main <- p_main +
    ggplot2::geom_point(size = point_size, alpha = point_alpha) +
    ggplot2::scale_color_manual(values = colors, name = group,
                                 guide = if (legend_color_pos == "none") "none" else "legend")

  if (!is.null(group2)) {
    p_main <- p_main +
      ggplot2::scale_shape_manual(values = shapes, name = group2)
  }

  p_main <- p_main +
    ggplot2::labs(x = xlab, y = ylab)

  # X axis position
  if (x_top) {
    p_main <- p_main +
      ggplot2::scale_x_continuous(position = "top")
  }

  # Ellipses
  if (show_ellipse) {
    p_main <- p_main +
      ggplot2::stat_ellipse(ggplot2::aes(color = .data[[group]]),
                             show.legend = FALSE)
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

  # Auto-compute correlation
  if (show_cor && is.null(annot_text)) {
    cor_res <- stats::cor.test(df[[x]], df[[y]], method = cor_method)
    annot_text <- sprintf(
      "%s:\nr = %.3f\np = %s",
      tools::toTitleCase(cor_method),
      cor_res$estimate,
      format(cor_res$p.value, digits = 3, scientific = TRUE)
    )
  }

  # Annotation text
  if (!is.null(annot_text)) {
    if (is.null(annot_pos)) {
      x_rng <- range(df[[x]], na.rm = TRUE)
      y_rng <- range(df[[y]], na.rm = TRUE)
      annot_pos <- c(x_rng[1] + diff(x_rng) * 0.02,
                     y_rng[2] - diff(y_rng) * 0.02)
    }
    p_main <- p_main +
      ggplot2::annotate("text", x = annot_pos[1], y = annot_pos[2],
                         label = annot_text, size = annot_size,
                         hjust = 0, vjust = 1)
  }

  # Theme
  p_main <- p_main +
    ggplot2::theme_test(base_size = base_size) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )

  # Shape legend position
  if (!is.null(group2)) {
    p_main <- p_main +
      ggplot2::theme(
        legend.position = legend_shape_pos,
        legend.background = ggplot2::element_blank(),
        legend.title = ggplot2::element_text(size = base_size * 0.7),
        legend.text = ggplot2::element_text(size = base_size * 0.7)
      )
  } else {
    p_main <- p_main +
      ggplot2::theme(legend.position = "none")
  }

  # ---- Helper: add marginal geom ----
  .add_mg <- function(p, mtype, w) {
    if (mtype == "violin") {
      p + ggplot2::geom_violin(show.legend = FALSE, alpha = 0.7,
                                trim = FALSE, linewidth = 0.4, width = w)
    } else if (mtype == "violin_box") {
      p + ggplot2::geom_violin(show.legend = FALSE, alpha = 0.5,
                                trim = FALSE, linewidth = 0.4, width = w) +
        ggplot2::geom_boxplot(show.legend = FALSE, width = w * 0.2,
                               outlier.shape = NA, alpha = 0.8)
    } else {
      p + ggplot2::geom_boxplot(width = w)
    }
  }

  make_margin_box <- function(var_axis, grp_col, fill_vals, side,
                               show_axis_text = FALSE, show_label = TRUE) {
    if (side == "bottom") {
      p <- ggplot2::ggplot(df, ggplot2::aes(
        x = .data[[grp_col]], y = .data[[var_axis]], fill = .data[[grp_col]]
      ))
      p <- .add_mg(p, marginal_type, box_width)
      p <- p +
        ggplot2::coord_flip() +
        ggplot2::scale_fill_manual(values = fill_vals) +
        ggplot2::theme_test(base_size = base_size) +
        ggplot2::theme(
          axis.title.x = ggplot2::element_blank(),
          axis.text.x = if (show_axis_text) {
            ggplot2::element_text(color = "black", size = base_size * 0.6)
          } else {
            ggplot2::element_blank()
          },
          axis.ticks.x = if (show_axis_text) {
            ggplot2::element_line()
          } else {
            ggplot2::element_blank()
          },
          axis.title.y = ggplot2::element_blank(),
          axis.text.y = if (show_label) {
            ggplot2::element_text(color = "black", size = base_size * 0.6)
          } else {
            ggplot2::element_blank()
          },
          axis.ticks.y = if (show_label) {
            ggplot2::element_line()
          } else {
            ggplot2::element_blank()
          },
          legend.position = "none",
          plot.margin = ggplot2::margin(0, 0, 0, 0)
        )
    } else {
      # side == "right"
      p <- ggplot2::ggplot(df, ggplot2::aes(
        x = .data[[grp_col]], y = .data[[var_axis]], fill = .data[[grp_col]]
      ))
      p <- .add_mg(p, marginal_type, box_width)
      p <- p +
        ggplot2::scale_fill_manual(values = fill_vals)

      # Last right panel shows y-axis ticks
      if (show_axis_text) {
        p <- p +
          ggplot2::scale_y_continuous(position = "right") +
          ggplot2::scale_x_discrete(position = "top")
      } else {
        p <- p +
          ggplot2::scale_x_discrete(position = "top")
      }

      p <- p +
        ggplot2::theme_test(base_size = base_size) +
        ggplot2::theme(
          axis.title.y = ggplot2::element_blank(),
          axis.text.y = if (show_axis_text) {
            ggplot2::element_text(color = "black", size = base_size * 0.6)
          } else {
            ggplot2::element_blank()
          },
          axis.ticks.y = if (show_axis_text) {
            ggplot2::element_line()
          } else {
            ggplot2::element_blank()
          },
          axis.title.x = ggplot2::element_blank(),
          axis.text.x = if (show_label) {
            ggplot2::element_text(color = "black", size = base_size * 0.6)
          } else {
            ggplot2::element_blank()
          },
          axis.ticks.x = if (show_label) {
            ggplot2::element_line()
          } else {
            ggplot2::element_blank()
          },
          legend.position = "none",
          plot.margin = ggplot2::margin(0, 0, 0, 0)
        )
    }
    p
  }

  # ---- Generate all marginal boxplots ----
  n_margins <- length(margin_vars)
  right_plots <- list()
  bottom_plots <- list()

  for (i in seq_along(margin_vars)) {
    mv <- margin_vars[[i]]
    is_last <- (i == n_margins)

    right_plots[[i]] <- make_margin_box(
      var_axis = y, grp_col = mv$col, fill_vals = mv$fill,
      side = "right",
      show_axis_text = is_last,
      show_label = TRUE
    )

    bottom_plots[[i]] <- make_margin_box(
      var_axis = x, grp_col = mv$col, fill_vals = mv$fill,
      side = "bottom",
      show_axis_text = is_last,
      show_label = TRUE
    )
  }

  # ---- Patchwork area layout ----
  M <- layout_main
  S <- layout_margin

  total_right <- S * n_margins
  total_bottom <- S * n_margins
  total_cols <- M + total_right
  total_rows <- M + total_bottom

  areas <- list()
  # 1. Main plot
  areas[[1]] <- patchwork::area(t = 1, l = 1, b = M, r = M)

  # 2. Right-side boxplots (side by side)
  for (i in seq_along(right_plots)) {
    l_start <- M + (i - 1) * S + 1
    l_end   <- M + i * S
    areas[[length(areas) + 1]] <- patchwork::area(
      t = 1, l = l_start, b = M, r = l_end
    )
  }

  # 3. Bottom boxplots (stacked)
  for (i in seq_along(bottom_plots)) {
    t_start <- M + (i - 1) * S + 1
    t_end   <- M + i * S
    areas[[length(areas) + 1]] <- patchwork::area(
      t = t_start, l = 1, b = t_end, r = M
    )
  }

  # 4. Bottom-right legend panel
  p_legend <- .make_scatter2_legend(margin_vars, base_size)
  areas[[length(areas) + 1]] <- patchwork::area(
    t = M + 1, l = M + 1, b = total_rows, r = total_cols
  )

  design <- Reduce(c, areas)

  all_plots <- c(list(p_main), right_plots, bottom_plots, list(p_legend))
  p_combined <- patchwork::wrap_plots(all_plots, design = design)

  # ---- Save or return ----
  if (!is.null(filename)) {
    ggplot2::ggsave(filename, p_combined,
                    width = width, height = height, dpi = dpi, bg = "white")
    message(sprintf("Plot saved to: %s", filename))
  }

  p_combined
}


#' Build bottom-right legend panel (internal helper for PlotScatter2)
#' @keywords internal
.make_scatter2_legend <- function(margin_vars, base_size) {
  legend_grobs <- list()

  for (mv in margin_vars) {
    fill_vals <- mv$fill
    grp_name  <- mv$label
    lvls <- names(fill_vals)

    dummy_df <- data.frame(
      x = seq_along(lvls),
      y = seq_along(lvls),
      grp = factor(lvls, levels = lvls)
    )

    p_dummy <- ggplot2::ggplot(dummy_df, ggplot2::aes(
      x = x, y = y, fill = grp
    )) +
      ggplot2::geom_tile() +
      ggplot2::scale_fill_manual(
        values = fill_vals, name = grp_name,
        guide = ggplot2::guide_legend(
          title.position = "top",
          ncol = 1,
          keywidth = ggplot2::unit(0.5, "cm"),
          keyheight = ggplot2::unit(0.5, "cm")
        )
      ) +
      ggplot2::theme(
        legend.title = ggplot2::element_text(
          size = base_size * 0.75, face = "bold"
        ),
        legend.text = ggplot2::element_text(size = base_size * 0.6),
        legend.background = ggplot2::element_blank()
      )

    g <- ggplot2::ggplotGrob(p_dummy)
    legend_idx <- which(sapply(g$grobs, function(x) x$name) == "guide-box")
    if (length(legend_idx) > 0) {
      legend_grobs[[length(legend_grobs) + 1]] <- g$grobs[[legend_idx[1]]]
    }
  }

  if (length(legend_grobs) == 0) {
    return(ggplot2::ggplot() + ggplot2::theme_void())
  }

  if (requireNamespace("gridExtra", quietly = TRUE)) {
    combined_legend <- gridExtra::arrangeGrob(
      grobs = legend_grobs, ncol = length(legend_grobs)
    )
  } else {
    combined_legend <- legend_grobs[[1]]
  }

  p_leg <- ggplot2::ggplot() +
    ggplot2::theme_void() +
    ggplot2::annotation_custom(grob = combined_legend) +
    ggplot2::theme(plot.margin = ggplot2::margin(5, 5, 5, 5))

  p_leg
}
