# =============================================================================
# PlotScatter2.R -- Dual-group scatter with multi-variable marginal boxplots
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  PlotScatter2(data, x, y, group, ...)        -- public API
#         +-- L2  .make_scatter2_legend()   bottom-right legend panel
#         +-- L2  .scatter_group_factor()   exact typed group labels (shared)
# =============================================================================

#' Dual-Group Scatter Plot with Multi-Variable Marginal Boxplots
#'
#' Scatter plot supporting two grouping variables (colour + shape) with
#' separate marginal boxplots for each grouping variable. Right-side panels
#' show column-wise boxplots, bottom panels show row-wise boxplots, arranged
#' via patchwork area layout. Suitable for multi-cohort PCoA/NMDS analysis or
#' two-factor gene correlation plots.
#'
#' Named \code{colors}, \code{shapes}, and \code{fill_colors_shape} vectors
#' must cover every observed, non-missing level of their grouping variable.
#' Unnamed vectors are matched in order of first appearance in \code{data}
#' and must supply at least one value per observed level. Extra entries are
#' accepted.
#'
#' Numeric axis values are preserved when a grouping column is also used
#' on an axis.
#' A column named \code{.data} may be used for an axis or grouping variable;
#' displayed labels retain the requested column names.
#' Grouping columns of class \code{integer64} require \pkg{bit64} so their
#' identifier labels remain exact.
#'
#' The bottom-right panel contains a fill legend for each grouping variable.
#' These fill legends are independent of the global theme's legend visibility.
#' Marginal numeric axes use the main plot's displayed ranges, including
#' ellipses and annotations. Density estimates use the original observations;
#' only their displayed ranges are zoomed.
#'
#' For single-group scatter with marginal boxplots, see
#' \code{\link{PlotScatter1}()}.
#' For paired scatter with rotated histogram inset, see
#' \code{\link{PlotScatter3}()}.
#'
#' @param data A data.frame.
#' @param x Column name for the X axis.
#' @param y Column name for the Y axis.
#' @param group Column name for colour grouping (e.g. Study).
#' @param group2 Column name for shape grouping (e.g. Group). NULL = no shape grouping.
#' @param colors Colour vector for \code{group} levels. NULL = auto palette
#'   (up to 12 groups); supply a complete mapping above this limit.
#' @param shapes Shape vector for \code{group2} levels. NULL = auto
#'   (up to 6 groups). Above 6 groups, supply both \code{shapes} and
#'   \code{fill_colors_shape} mappings.
#' @param fill_colors_shape Fill colours for \code{group2} in marginal boxplots.
#'   NULL = auto (up to 6 groups).
#' @param point_size Point size. Default 2.
#' @param point_alpha Point transparency. Default 0.8.
#' @param show_ellipse Whether to draw ellipses based on \code{group},
#'   independently of \code{group2}. Default FALSE.
#' @param show_cor Whether to auto-compute and display correlation. Default FALSE.
#' @param cor_method Correlation method: "pearson" or "spearman". Default "pearson".
#' @param show_regression Whether to show a regression line. Default FALSE.
#' @param reg_method Regression method: "lm" or "loess". Default "lm".
#' @param annot_text Annotation text in main plot (e.g. PERMANOVA). NULL = none.
#'   Manual input overrides \code{show_cor} auto text.
#' @param annot_pos Annotation position c(x, y). NULL = auto top-left using
#'   finite observations. An axis with no finite observations uses c(0, 1)
#'   as the reference range for automatic positioning.
#' @param annot_size Annotation text size. Default 5.
#' @param xlab X axis label. NULL = column name.
#' @param ylab Y axis label. NULL = column name.
#' @param x_top Whether to place X axis on top. Default TRUE.
#' @param marginal_type Marginal plot type: "boxplot", "violin", or "violin_box".
#' @param box_width Box/violin width in marginal plots. Default 0.7.
#' @param base_size Base font size. Default 16.
#' @param legend_color_pos Colour legend position in the main plot, independent
#'   of the shape legend. Default "none" (shown via marginal boxes).
#' @param legend_shape_pos Shape legend position in the main plot. Default
#'   c(0.15, 0.15), inside the panel.
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
  if (!is.null(filename)) .check_plot_filename(filename)

  marginal_type <- match.arg(marginal_type)

  # ---- Check dependencies ----
  for (pkg in c("ggplot2", "patchwork")) {
    if (!requireNamespace(pkg, quietly = TRUE))
      stop(sprintf("Package '%s' is required.", pkg))
  }

  # ---- Validate columns ----
  for (arg in c("x", "y", "group", "group2")) {
    value <- get(arg)
    if (arg == "group2" && is.null(value)) next
    if (!is.character(value) || !is.null(dim(value)) || length(value) != 1L ||
        is.na(value) || !nzchar(value))
      stop("'", arg, "' must be a single non-missing column name.", call. = FALSE)
  }
  for (arg in c("show_ellipse", "show_regression", "show_cor", "x_top")) {
    value <- get(arg)
    if (!is.logical(value) || !is.null(dim(value)) || length(value) != 1L || is.na(value))
      stop("'", arg, "' must be TRUE or FALSE.", call. = FALSE)
  }
  for (arg in c("point_size", "point_alpha", "box_width", "base_size", "layout_main", "layout_margin")) {
    value <- get(arg)
    positive <- arg %in% c("box_width", "base_size", "layout_main", "layout_margin")
    layout <- arg %in% c("layout_main", "layout_margin")
    if (!is.numeric(value) || is.object(value) || !is.null(dim(value)) || length(value) != 1L ||
        !is.finite(value) || value < 0 || (positive && value == 0) ||
        (arg == "point_alpha" && value > 1) ||
        (layout && (value != trunc(value) || value > .Machine$integer.max)))
      stop("'", arg, "' must be a finite scalar in its allowed range.", call. = FALSE)
  }
  if (show_cor || !is.null(annot_text)) {
    if (!is.numeric(annot_size) || is.object(annot_size) || !is.null(dim(annot_size)) ||
        length(annot_size) != 1L || !is.finite(annot_size) || annot_size < 0)
      stop("'annot_size' must be a single finite non-negative number.", call. = FALSE)
    if (!is.null(annot_pos) && (!is.numeric(annot_pos) || is.object(annot_pos) ||
        !is.null(dim(annot_pos)) || length(annot_pos) != 2L || any(!is.finite(annot_pos))))
      stop("'annot_pos' must contain two finite numbers.", call. = FALSE)
  }
  if (!is.data.frame(data)) stop("'data' must be a data.frame.", call. = FALSE)
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data)))
    stop("'data' must have unique, non-missing, non-empty column names.", call. = FALSE)
  need_cols <- c(x, y, group)
  if (!is.null(group2)) need_cols <- c(need_cols, group2)
  for (col in need_cols) {
    if (!col %in% colnames(data)) stop(sprintf("Column '%s' not found in data.", col))
  }
  for (col in unique(c(x, y))) {
    value <- data[[col]]
    if (is.complex(value) || is.list(value) || !is.null(dim(value)))
      stop("Column '", col, "' must contain a real vector.", call. = FALSE)
    if (inherits(value, "haven_labelled_spss")) {
      data[[col]] <- .scatter_axis_values(value)
    }
  }

  integer64_groups <- vapply(unique(c(group, group2)), function(col) {
    inherits(data[[col]], "integer64")
  }, logical(1L))
  if (any(integer64_groups) && !requireNamespace("bit64", quietly = TRUE)) {
    stop("Package 'bit64' is required for integer64 grouping columns.", call. = FALSE)
  }

  if (is.null(xlab)) xlab <- x
  if (is.null(ylab)) ylab <- y
  group_label <- group
  group2_label <- group2

  df <- data
  if (".data" %in% c(x, y, group, group2)) {
    data_col <- make.unique(c(names(df), ".scatter2_data"))[ncol(df) + 1L]
    df[[data_col]] <- df[[".data"]]
    if (x == ".data") x <- data_col
    if (y == ".data") y <- data_col
    if (group == ".data") group <- data_col
    if (!is.null(group2) && group2 == ".data") group2 <- data_col
  }
  for (col in intersect(c(x, y), c(group, group2))) {
    axis_col <- make.unique(c(names(df), ".scatter2_axis"))[ncol(df) + 1L]
    df[[axis_col]] <- df[[col]]
    if (x == col) x <- axis_col
    if (y == col) y <- axis_col
  }
  for (col in unique(c(x, y))) {
    if (inherits(df[[col]], "integer64")) df[[col]] <- .scatter_axis_values(df[[col]])
  }
  df[[group]] <- .scatter_group_factor(df[[group]])
  if (!is.null(group2)) {
    df[[group2]] <- .scatter_group_factor(df[[group2]])
  }

  # ---- Colours / shapes ----
  match_mapping <- function(values, lvls, arg) {
    if (!is.atomic(values) || !is.null(dim(values)))
      stop("'", arg, "' must be a one-dimensional vector.", call. = FALSE)
    if (!is.null(names(values)) &&
        (anyNA(names(values)) || (any(!nzchar(names(values))) && !"" %in% lvls) ||
         anyDuplicated(names(values))))
      stop("'", arg, "' must have unique, non-missing, non-empty mapping names.", call. = FALSE)
    if (is.null(names(values))) {
      if (length(values) < length(lvls)) {
        stop(sprintf(
          "'%s' must supply at least %d values, one for each observed group level.",
          arg, length(lvls)
        ), call. = FALSE)
      }
      return(stats::setNames(values[seq_along(lvls)], lvls))
    }
    missing_lvls <- setdiff(lvls, names(values))
    if (length(missing_lvls)) {
      stop(sprintf("'%s' is missing mappings for: %s.",
                   arg, paste(missing_lvls, collapse = ", ")), call. = FALSE)
    }
    values
  }

  color_lvls <- levels(df[[group]])
  n_color <- length(color_lvls)

  if (is.null(colors)) {
    if (n_color > 12L) {
      stop("More than 12 colour groups require an explicit colors mapping.", call. = FALSE)
    }
    default_cols <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
                      "#FF7F00", "#A65628", "#F781BF", "#999999",
                      "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3")
    colors <- stats::setNames(default_cols[seq_len(n_color)], color_lvls)
  }
  colors <- match_mapping(colors, color_lvls, "colors")

  if (!is.null(group2)) {
    shape_lvls <- levels(df[[group2]])
    n_shape <- length(shape_lvls)
    if (n_shape > 6L && (is.null(shapes) || is.null(fill_colors_shape))) {
      needed <- c(if (is.null(shapes)) "shapes",
                  if (is.null(fill_colors_shape)) "fill_colors_shape")
      stop(sprintf("More than 6 shape groups require explicit %s mappings.",
                   paste(needed, collapse = " and ")), call. = FALSE)
    }
    if (is.null(shapes)) {
      shapes <- stats::setNames(c(16, 17, 15, 18, 8, 7)[seq_len(n_shape)],
                                 shape_lvls)
    }
    if (is.null(fill_colors_shape)) {
      shape_pal <- c("#FFA500", "#4682B4", "#2CA02C", "#D62728",
                     "#9467BD", "#8C564B")
      fill_colors_shape <- stats::setNames(shape_pal[seq_len(n_shape)], shape_lvls)
    }
    shapes <- match_mapping(shapes, shape_lvls, "shapes")
    fill_colors_shape <- match_mapping(fill_colors_shape, shape_lvls,
                                       "fill_colors_shape")
  }

  # ---- Collect margin variables (for marginal boxplots) ----
  margin_vars <- list()
  margin_vars[[group]] <- list(
    col = group, fill = colors, label = group_label
  )
  if (!is.null(group2)) {
    margin_vars[[group2]] <- list(
      col = group2, fill = fill_colors_shape, label = group2_label
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
    ggplot2::scale_color_manual(values = colors, name = group_label,
      guide = if (legend_color_pos == "none") "none" else
        ggplot2::guide_legend(position = legend_color_pos))

  if (!is.null(group2)) {
    p_main <- p_main +
      ggplot2::scale_shape_manual(values = shapes, name = group2_label,
        guide = if (identical(legend_shape_pos, "none")) "none" else "legend")
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
      ggplot2::stat_ellipse(ggplot2::aes(
        x = .data[[x]], y = .data[[y]],
        color = .data[[group]], group = .data[[group]]
      ), inherit.aes = FALSE, show.legend = FALSE)
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
    annot_text <- .scatter_cor_label(df[[x]], df[[y]], cor_method)
  }

  # Annotation text
  if (!is.null(annot_text)) {
    if (is.null(annot_pos)) {
      finite_range <- function(z) {
        z <- z[is.finite(z)]
        if (length(z)) range(z) else c(0, 1)
      }
      x_rng <- finite_range(df[[x]])
      y_rng <- finite_range(df[[y]])
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
        legend.position = if (identical(legend_shape_pos, "none"))
          legend_color_pos else legend_shape_pos,
        legend.background = ggplot2::element_blank(),
        legend.title = ggplot2::element_text(size = base_size * 0.7),
        legend.text = ggplot2::element_text(size = base_size * 0.7)
      )
  } else {
    p_main <- p_main +
      ggplot2::theme(legend.position = legend_color_pos)
  }

  # Train shared display ranges; the main draw still reports its notices.
  main_ranges <- suppressMessages(suppressWarnings(
    ggplot2::ggplot_build(p_main)$layout$panel_params[[1]][c("x.range", "y.range")]
  ))

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
        ggplot2::coord_flip(ylim = main_ranges$x.range) +
        ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0)) +
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
        ggplot2::coord_cartesian(ylim = main_ranges$y.range) +
        ggplot2::scale_fill_manual(values = fill_vals)

      # Last right panel shows y-axis ticks
      if (show_axis_text) {
        p <- p +
          ggplot2::scale_y_continuous(position = "right",
                                     expand = ggplot2::expansion(mult = 0)) +
          ggplot2::scale_x_discrete(position = "top")
      } else {
        p <- p +
          ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0)) +
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
    # measured before writing, which creates the file
    existed <- file.exists(filename)
    ggplot2::ggsave(filename, p_combined,
                    width = width, height = height, dpi = dpi, bg = "white")
    .cat_saved("PlotScatter2: the plot has been saved to", filename,
               sprintf("%sx%s in", format(width), format(height)), existed,
               toupper(tools::file_ext(filename)))
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
        legend.position = "right",
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
    combined_legend <- gtable::gtable_row(
      "scatter2-legends", legend_grobs, height = grid::unit(1, "null"),
      clip = "off"
    )
  }

  p_leg <- ggplot2::ggplot() +
    ggplot2::theme_void() +
    ggplot2::annotation_custom(grob = combined_legend) +
    ggplot2::theme(plot.margin = ggplot2::margin(5, 5, 5, 5))

  p_leg
}
