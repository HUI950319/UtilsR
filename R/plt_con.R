# ============================================================================
# plt_con.R -- Unified continuous variable plot
# ============================================================================

#' Unified Continuous Variable Plot
#'
#' A single entry point for continuous/numeric variable plotting with
#' violin, box, bar (mean +/- SD), and dot plot types. Supports statistical
#' comparisons via \pkg{ggpubr}, overlay layers (boxplot, jitter points,
#' trend lines), and the same split/group/bg patterns as
#' \code{\link{plt_cat}}.
#'
#' @param data A data frame.
#' @param stat.by Character vector. Column name(s) of numeric variables to
#'   plot.
#' @param group.by Character. Column name for the x-axis grouping variable.
#'   Default \code{NULL} (all data in one group).
#' @param split.by Character. Optional splitting variable. Splits data,
#'   creates one plot per level, and combines with \pkg{patchwork}.
#' @param bg.by Character. Column name for background colour bands.
#'   Must be a superset of \code{group.by}. Default \code{NULL}.
#' @param type Plot type: \code{"violin"} (default), \code{"box"},
#'   \code{"bar"}, or \code{"dot"}.
#' @param fill.by What variable to map to fill colour:
#'   \code{"group"} (default) colours by group.by levels;
#'   \code{"feature"} colours by stat.by name.
#' @param palette Colour palette. One of:
#'   \itemize{
#'     \item \code{NULL} (default): uses \code{pal_lancet}.
#'     \item A single string matching a name in \code{palette_list}: uses
#'       \code{pal_get()}.
#'     \item A character vector of colours: used directly.
#'   }
#' @param alpha Numeric 0--1. Fill transparency. Default 0.8.
#' @param add_box Logical. Overlay boxplot on violin? Default \code{FALSE}.
#' @param box_color Character. Box overlay colour. Default \code{"black"}.
#' @param box_width Numeric. Box overlay width. Default 0.1.
#' @param add_point Logical. Overlay jittered points? Default \code{FALSE}.
#' @param pt.color Character. Point colour. Default \code{"grey30"}.
#' @param pt.size Numeric. Point size. Default \code{NULL} (auto).
#' @param pt.alpha Numeric. Point transparency. Default 1.
#' @param jitter.width Numeric. Jitter width. Default 0.4.
#' @param jitter.height Numeric. Jitter height. Default 0.1.
#' @param add_trend Logical. Overlay trend line connecting medians/means?
#'   Default \code{FALSE}.
#' @param trend_color Character. Trend line colour. Default \code{"black"}.
#' @param trend_linewidth Numeric. Trend line width. Default 1.
#' @param trend_ptsize Numeric. Trend point size. Default 2.
#' @param comparisons A list of length-2 character vectors for pairwise tests.
#'   Default \code{NULL}.
#' @param ref_group Character. Reference group for comparisons.
#'   Default \code{NULL}.
#' @param pairwise_method Character. Pairwise test method.
#'   Default \code{"wilcox.test"}.
#' @param multiplegroup_comparisons Logical. Add global comparison?
#'   Default \code{FALSE}.
#' @param multiple_method Character. Global test method.
#'   Default \code{"kruskal.test"}.
#' @param sig_label Label type: \code{"p.signif"} or \code{"p.format"}.
#' @param sig_labelsize Numeric. Label text size. Default 3.5.
#' @param same.y.lims Logical. Use same y limits across features?
#'   Default \code{FALSE}.
#' @param y.min Numeric or character. Minimum y-axis limit.
#'   Character \code{"qN"} uses the Nth percentile. Default \code{NULL}.
#' @param y.max Numeric or character. Maximum y-axis limit.
#'   Character \code{"qN"} uses the Nth percentile. Default \code{NULL}.
#' @param y.nbreaks Integer. Number of y-axis breaks. Default 5.
#' @param sort Logical or character. Sort groups by median?
#'   \code{TRUE} or \code{"decreasing"} for descending,
#'   \code{"increasing"} for ascending. Default \code{FALSE}.
#' @param stack Logical. Stack features vertically using facet?
#'   Default \code{FALSE}.
#' @param flip Logical. Flip coordinates? Default \code{FALSE}.
#' @param title Character. Plot title. Default \code{NULL}.
#' @param subtitle Character. Plot subtitle. Default \code{NULL}.
#' @param xlab Character. X-axis label. Default \code{NULL}.
#' @param ylab Character. Y-axis label. Default \code{NULL}.
#' @param legend.position Legend position. Default \code{"right"}.
#' @param legend.direction Legend direction. Default \code{"vertical"}.
#' @param aspect.ratio Numeric. Panel aspect ratio. Default \code{NULL}.
#' @param base_size Numeric. Base font size for \code{theme_my()}.
#'   Default 14.
#' @param bg_palette Character vector. Background band colours.
#'   Default \code{NULL}.
#' @param bg_alpha Numeric. Background band transparency. Default 0.15.
#' @param facet_nrow Integer. Rows when combining panels.
#'   Default \code{NULL}.
#' @param facet_ncol Integer. Columns when combining panels.
#'   Default \code{NULL}.
#' @param combine Logical. \code{TRUE} returns single patchwork,
#'   \code{FALSE} returns list. Default \code{TRUE}.
#' @param force Logical. Override >100 level safety? Default \code{FALSE}.
#' @param seed Integer. Random seed for jitter. Default 11.
#'
#' @return A ggplot/patchwork object (if \code{combine = TRUE}) or a named
#'   list of ggplots.
#'
#' @examples
#' set.seed(1)
#' grp <- factor(sample(c("A", "B", "C"), 200, TRUE))
#' df <- data.frame(
#'   value1 = rnorm(200),
#'   value2 = rnorm(200, mean = 2),
#'   group  = grp,
#'   batch  = factor(sample(c("B1", "B2"), 200, TRUE)),
#'   region = factor(ifelse(grp == "C", "R2", "R1"))
#' )
#'
#' # Basic violin plot
#' plt_con(df, "value1", "group")
#'
#' \donttest{
#' # ===== Basic types =====
#' plt_con(df, "value1", "group", type = "box")
#' plt_con(df, "value1", "group", type = "bar")
#' plt_con(df, "value1", "group", type = "dot")
#'
#' # ===== Overlays =====
#' plt_con(df, "value1", "group", add_box = TRUE)
#' plt_con(df, "value1", "group", type = "box", add_point = TRUE)
#' plt_con(df, "value1", "group", type = "bar", add_trend = TRUE)
#' plt_con(df, "value1", "group", add_point = TRUE, add_box = TRUE)
#'
#' # ===== Multiple features =====
#' plt_con(df, c("value1", "value2"), "group")
#' plt_con(df, c("value1", "value2"), "group", stack = TRUE)
#' plt_con(df, c("value1", "value2"), "group", fill.by = "feature")
#'
#' # ===== Statistical comparisons =====
#' plt_con(df, "value1", "group",
#'         comparisons = list(c("A", "B"), c("A", "C")))
#' plt_con(df, "value1", "group",
#'         multiplegroup_comparisons = TRUE, sig_label = "p.format")
#'
#' # ===== Layout =====
#' plt_con(df, "value1", "group", flip = TRUE)
#' plt_con(df, "value1", "group", split.by = "batch")
#' plt_con(df, "value1", "group", bg.by = "region")
#' plt_con(df, "value1", "group", sort = TRUE)
#'
#' # ===== Y-axis control =====
#' plt_con(df, c("value1", "value2"), "group",
#'         same.y.lims = TRUE, y.max = 4)
#' }
#'
#' @export
#' @family plot
plt_con <- function(data,
                    stat.by,
                    group.by = NULL,
                    split.by = NULL,
                    bg.by = NULL,
                    type = c("violin", "box", "bar", "dot"),
                    fill.by = c("group", "feature"),
                    palette = NULL,
                    alpha = 0.8,
                    add_box = FALSE,
                    box_color = "black",
                    box_width = 0.1,
                    add_point = FALSE,
                    pt.color = "grey30",
                    pt.size = NULL,
                    pt.alpha = 1,
                    jitter.width = 0.4,
                    jitter.height = 0.1,
                    add_trend = FALSE,
                    trend_color = "black",
                    trend_linewidth = 1,
                    trend_ptsize = 2,
                    comparisons = NULL,
                    ref_group = NULL,
                    pairwise_method = "wilcox.test",
                    multiplegroup_comparisons = FALSE,
                    multiple_method = "kruskal.test",
                    sig_label = c("p.signif", "p.format"),
                    sig_labelsize = 3.5,
                    same.y.lims = FALSE,
                    y.min = NULL,
                    y.max = NULL,
                    y.nbreaks = 5,
                    sort = FALSE,
                    stack = FALSE,
                    flip = FALSE,
                    title = NULL,
                    subtitle = NULL,
                    xlab = NULL,
                    ylab = NULL,
                    legend.position = "right",
                    legend.direction = "vertical",
                    aspect.ratio = NULL,
                    base_size = 14,
                    bg_palette = NULL,
                    bg_alpha = 0.15,
                    facet_nrow = NULL,
                    facet_ncol = NULL,
                    combine = TRUE,
                    force = FALSE,
                    seed = 11) {

  # --- Input validation -------------------------------------------------------
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.cls {class(data)}}.")
  }

  type     <- match.arg(type)
  fill.by  <- match.arg(fill.by)
  sig_label <- match.arg(sig_label)

  if (!is.character(stat.by) || length(stat.by) == 0) {
    cli::cli_abort("{.arg stat.by} must be a non-empty character vector.")
  }
  stat.by <- unique(stat.by)

  missing_cols <- stat.by[!stat.by %in% names(data)]
  if (length(missing_cols) > 0) {
    cli::cli_abort("Column{?s} not found in {.arg data}: {.val {missing_cols}}")
  }

  non_numeric <- stat.by[!vapply(stat.by, function(s) {
    is.numeric(data[[s]])
  }, logical(1))]
  if (length(non_numeric) > 0) {
    cli::cli_abort(
      "Column{?s} must be numeric: {.val {non_numeric}}"
    )
  }

  # --- group.by handling ------------------------------------------------------
  dummy_group <- FALSE
  if (is.null(group.by)) {
    group.by <- ".all_groups"
    data[[group.by]] <- factor("All")
    xlab <- xlab %||% ""
    dummy_group <- TRUE
  }
  if (!group.by %in% names(data)) {
    cli::cli_abort("Column {.val {group.by}} not found in {.arg data}.")
  }

  # --- split.by / bg.by validation -------------------------------------------
  if (!is.null(split.by) && !split.by %in% names(data)) {
    cli::cli_abort("Column {.val {split.by}} not found in {.arg data}.")
  }
  if (!is.null(bg.by)) {
    if (!bg.by %in% names(data)) {
      cli::cli_abort("Column {.val {bg.by}} not found in {.arg data}.")
    }
    if (dummy_group) {
      cli::cli_warn("{.arg bg.by} requires {.arg group.by}. Ignored.")
      bg.by <- NULL
    }
  }

  # --- Ensure factors ---------------------------------------------------------
  for (col in unique(c(group.by, split.by, bg.by))) {
    if (!is.null(col) && col %in% names(data) && !is.factor(data[[col]])) {
      data[[col]] <- factor(data[[col]], levels = unique(data[[col]]))
    }
  }

  # --- Safety check for high-cardinality columns ------------------------------
  if (!force) {
    check_cols <- unique(c(group.by, split.by))
    high_card <- vapply(check_cols, function(col) {
      nlevels(data[[col]])
    }, integer(1))
    high_card <- high_card[high_card > 100]
    if (length(high_card) > 0) {
      cli::cli_abort(c(
        "Column{?s} with > 100 levels: {.val {names(high_card)}}.",
        "i" = "Set {.arg force = TRUE} to override."
      ))
    }
  }

  # --- Warnings for invalid combos -------------------------------------------
  if (type == "box" && isTRUE(add_box)) {
    cli::cli_inform("{.arg add_box} ignored when {.arg type} is {.val box}.")
    add_box <- FALSE
  }
  if (type == "dot") {
    if (isTRUE(add_box) || isTRUE(add_trend)) {
      cli::cli_warn(
        "{.arg add_box}/{.arg add_trend} ignored for {.val dot} type."
      )
      add_box <- FALSE
      add_trend <- FALSE
    }
    if (!is.null(comparisons) || isTRUE(multiplegroup_comparisons)) {
      cli::cli_warn(
        "Statistical comparisons are not supported for {.val dot} type. Ignored."
      )
      comparisons <- NULL
      multiplegroup_comparisons <- FALSE
    }
  }

  # --- Handle split.by via recursion ------------------------------------------
  if (!is.null(split.by)) {
    split_levels <- levels(data[[split.by]])
    plot_list <- lapply(split_levels, function(lv) {
      sub_data <- data[data[[split.by]] == lv, , drop = FALSE]
      plt_con(
        data = sub_data, stat.by = stat.by,
        group.by = if (dummy_group) NULL else group.by,
        split.by = NULL, bg.by = bg.by,
        type = type, fill.by = fill.by,
        palette = palette, alpha = alpha,
        add_box = add_box, box_color = box_color, box_width = box_width,
        add_point = add_point, pt.color = pt.color, pt.size = pt.size,
        pt.alpha = pt.alpha, jitter.width = jitter.width,
        jitter.height = jitter.height,
        add_trend = add_trend, trend_color = trend_color,
        trend_linewidth = trend_linewidth, trend_ptsize = trend_ptsize,
        comparisons = comparisons, ref_group = ref_group,
        pairwise_method = pairwise_method,
        multiplegroup_comparisons = multiplegroup_comparisons,
        multiple_method = multiple_method,
        sig_label = sig_label, sig_labelsize = sig_labelsize,
        same.y.lims = same.y.lims, y.min = y.min, y.max = y.max,
        y.nbreaks = y.nbreaks,
        sort = sort, stack = stack, flip = flip,
        title = lv, subtitle = subtitle,
        xlab = xlab, ylab = ylab,
        legend.position = legend.position,
        legend.direction = legend.direction,
        aspect.ratio = aspect.ratio, base_size = base_size,
        bg_palette = bg_palette, bg_alpha = bg_alpha,
        facet_nrow = NULL, facet_ncol = NULL, combine = TRUE,
        force = force, seed = seed
      )
    })
    return(
      patchwork::wrap_plots(plot_list, nrow = facet_nrow, ncol = facet_ncol) +
        patchwork::plot_layout(guides = "collect")
    )
  }

  # --- Auto pt.size -----------------------------------------------------------
  if (is.null(pt.size)) {
    pt.size <- min(3000 / nrow(data), 0.5)
  }

  # --- Sort group levels by median -------------------------------------------
  if (!isFALSE(sort) && !dummy_group) {
    df_sort <- stats::aggregate(
      data[[stat.by[1]]], by = list(data[[group.by]]), FUN = stats::median,
      na.rm = TRUE
    )
    decreasing <- !(is.character(sort) && sort == "increasing")
    sorted_levels <- as.character(
      df_sort[order(df_sort[[2]], decreasing = decreasing), 1]
    )
    data[[group.by]] <- factor(data[[group.by]], levels = sorted_levels)
  }

  # --- Resolve colours --------------------------------------------------------
  if (fill.by == "group") {
    color_levels <- levels(data[[group.by]])
  } else {
    color_levels <- stat.by
  }
  colors <- .resolve_colors(color_levels, palette)

  # --- Global y limits (same.y.lims) -----------------------------------------
  global_y_min <- NULL
  global_y_max <- NULL
  if (isTRUE(same.y.lims)) {
    all_values <- unlist(lapply(stat.by, function(s) {
      v <- data[[s]]
      v[is.finite(v)]
    }))
    global_y_max <- .resolve_y_limit(y.max, all_values, side = "max")
    global_y_min <- .resolve_y_limit(y.min, all_values, side = "min")
  }

  # --- Build one plot per feature --------------------------------------------
  plist <- stats::setNames(lapply(stat.by, function(f) {
    .plt_con_single(
      data = data, feature = f, group.by = group.by, bg.by = bg.by,
      type = type, fill.by = fill.by, colors = colors, alpha = alpha,
      add_box = add_box, box_color = box_color, box_width = box_width,
      add_point = add_point, pt.color = pt.color, pt.size = pt.size,
      pt.alpha = pt.alpha, jitter.width = jitter.width,
      jitter.height = jitter.height,
      add_trend = add_trend, trend_color = trend_color,
      trend_linewidth = trend_linewidth, trend_ptsize = trend_ptsize,
      comparisons = comparisons, ref_group = ref_group,
      pairwise_method = pairwise_method,
      multiplegroup_comparisons = multiplegroup_comparisons,
      multiple_method = multiple_method,
      sig_label = sig_label, sig_labelsize = sig_labelsize,
      y.min = global_y_min %||% y.min, y.max = global_y_max %||% y.max,
      y.nbreaks = y.nbreaks, flip = flip,
      title = title, subtitle = subtitle,
      xlab = xlab %||% (if (dummy_group) "" else group.by),
      ylab = ylab %||% f,
      legend.position = legend.position,
      legend.direction = legend.direction,
      aspect.ratio = aspect.ratio, base_size = base_size,
      bg_palette = bg_palette, bg_alpha = bg_alpha,
      seed = seed
    )
  }), stat.by)

  # --- Stack mode: facet_grid(feature ~ .) -----------------------------------
  if (isTRUE(stack) && length(stat.by) > 1) {
    plist <- list(.plt_con_stacked(
      data = data, stat.by = stat.by, group.by = group.by, bg.by = bg.by,
      type = type, fill.by = fill.by, colors = colors, alpha = alpha,
      add_box = add_box, box_color = box_color, box_width = box_width,
      add_point = add_point, pt.color = pt.color, pt.size = pt.size,
      pt.alpha = pt.alpha, jitter.width = jitter.width,
      jitter.height = jitter.height,
      add_trend = add_trend, trend_color = trend_color,
      trend_linewidth = trend_linewidth, trend_ptsize = trend_ptsize,
      y.min = global_y_min %||% y.min, y.max = global_y_max %||% y.max,
      y.nbreaks = y.nbreaks, flip = flip,
      title = title, subtitle = subtitle,
      xlab = xlab %||% (if (dummy_group) "" else group.by),
      ylab = ylab %||% "Value",
      legend.position = legend.position,
      legend.direction = legend.direction,
      aspect.ratio = aspect.ratio, base_size = base_size,
      bg_palette = bg_palette, bg_alpha = bg_alpha,
      seed = seed
    ))
  }

  # --- Combine ----------------------------------------------------------------
  if (isTRUE(combine)) {
    if (length(plist) == 1) {
      return(plist[[1]])
    }
    return(
      patchwork::wrap_plots(plist, nrow = facet_nrow, ncol = facet_ncol) +
        patchwork::plot_layout(guides = "collect")
    )
  }

  plist
}


# ============================================================================
# Internal helpers
# ============================================================================

#' Resolve y-axis limit (numeric or quantile string)
#' @noRd
.resolve_y_limit <- function(val, values, side = c("min", "max")) {
  side <- match.arg(side)
  if (is.null(val)) {
    if (side == "max") max(values, na.rm = TRUE) else min(values, na.rm = TRUE)
  } else if (is.character(val)) {
    q <- as.numeric(sub("^q(\\d+)$", "\\1", val)) / 100
    stats::quantile(values, q, na.rm = TRUE)
  } else {
    val
  }
}


#' Build a single feature plot
#' @noRd
.plt_con_single <- function(data, feature, group.by, bg.by,
                             type, fill.by, colors, alpha,
                             add_box, box_color, box_width,
                             add_point, pt.color, pt.size, pt.alpha,
                             jitter.width, jitter.height,
                             add_trend, trend_color, trend_linewidth,
                             trend_ptsize,
                             comparisons, ref_group, pairwise_method,
                             multiplegroup_comparisons, multiple_method,
                             sig_label, sig_labelsize,
                             y.min, y.max, y.nbreaks, flip,
                             title, subtitle, xlab, ylab,
                             legend.position, legend.direction,
                             aspect.ratio, base_size,
                             bg_palette, bg_alpha, seed) {

  dat <- data.frame(
    value    = data[[feature]],
    group.by = data[[group.by]],
    stringsAsFactors = FALSE
  )
  dat[["group.by"]] <- factor(dat[["group.by"]], levels = levels(data[[group.by]]))

  if (fill.by == "group") {
    dat[["fill.by"]] <- dat[["group.by"]]
  } else {
    dat[["fill.by"]] <- factor(feature, levels = names(colors))
  }

  # Remove NA values
  dat <- dat[is.finite(dat[["value"]]), , drop = FALSE]
  if (nrow(dat) == 0) {
    cli::cli_warn("No finite values for {.val {feature}}. Skipping.")
    return(NULL)
  }

  # --- Y limits ---------------------------------------------------------------
  values <- dat[["value"]]
  y_max_use <- .resolve_y_limit(y.max, values, "max")
  y_min_use <- .resolve_y_limit(y.min, values, "min")

  # --- Base ggplot ------------------------------------------------------------
  p <- ggplot2::ggplot(dat, ggplot2::aes(
    x = .data[["group.by"]],
    y = .data[["value"]],
    fill = .data[["fill.by"]]
  ))

  # --- Background bands -------------------------------------------------------
  if (!is.null(bg.by)) {
    bg_layer <- .build_bg_layer(data, group.by, bg.by, bg_alpha, bg_palette)
    if (!is.null(bg_layer)) {
      p <- p + bg_layer
    }
  }

  # --- Type-specific geom -----------------------------------------------------
  if (type == "violin") {
    # Remove groups with < 2 observations
    grp_counts <- table(dat[["group.by"]])
    small_groups <- names(grp_counts[grp_counts < 2])
    if (length(small_groups) > 0) {
      cli::cli_warn(
        "Removed {length(small_groups)} group{?s} with < 2 obs for violin: {.val {small_groups}}"
      )
      dat <- dat[!dat[["group.by"]] %in% small_groups, , drop = FALSE]
      dat[["group.by"]] <- droplevels(dat[["group.by"]])
      if (fill.by == "group") dat[["fill.by"]] <- dat[["group.by"]]
      # Rebuild the plot with filtered data
      p <- ggplot2::ggplot(dat, ggplot2::aes(
        x = .data[["group.by"]],
        y = .data[["value"]],
        fill = .data[["fill.by"]]
      ))
      if (!is.null(bg.by)) {
        bg_layer <- .build_bg_layer(data, group.by, bg.by, bg_alpha, bg_palette)
        if (!is.null(bg_layer)) p <- p + bg_layer
      }
    }
    p <- p + ggplot2::geom_violin(
      scale = "width", trim = TRUE, alpha = alpha,
      position = ggplot2::position_dodge()
    )
  } else if (type == "box") {
    p <- p +
      ggplot2::geom_boxplot(
        position = ggplot2::position_dodge(width = 0.9),
        color = "black", width = 0.8, alpha = alpha,
        outlier.shape = NA
      ) +
      ggplot2::stat_summary(
        fun = stats::median, geom = "point",
        position = ggplot2::position_dodge(width = 0.9),
        color = "black", fill = "white", size = 1.5, shape = 21
      )
  } else if (type == "bar") {
    p <- p +
      ggplot2::geom_hline(yintercept = 0, linetype = 2) +
      ggplot2::stat_summary(
        fun = mean, geom = "col",
        position = ggplot2::position_dodge(width = 0.9),
        width = 0.8, color = "black", alpha = alpha
      ) +
      ggplot2::stat_summary(
        fun.data = ggplot2::mean_sdl, fun.args = list(mult = 1),
        geom = "errorbar",
        position = ggplot2::position_dodge(width = 0.9),
        width = 0.2, color = "black"
      )
    y_min_use <- min(0, y_min_use)
  } else if (type == "dot") {
    brks <- seq(min(dat[["value"]], na.rm = TRUE),
                max(dat[["value"]], na.rm = TRUE), length.out = 15)
    bins <- cut(dat[["value"]], breaks = brks, include.lowest = TRUE)
    # Compute midpoints of each bin interval
    bin_lvls <- levels(bins)
    bins_mid <- vapply(bin_lvls, function(lbl) {
      nums <- regmatches(lbl, gregexpr("-?[0-9.]+[eE]?[+-]?[0-9]*", lbl))[[1]]
      mean(as.numeric(nums), na.rm = TRUE)
    }, numeric(1))
    dat[["bins"]] <- bins_mid[as.character(bins)]
    # Pre-aggregate counts to avoid stat_sum issues
    dot_df <- stats::aggregate(
      value ~ group.by + fill.by + bins,
      data = dat, FUN = length
    )
    names(dot_df)[names(dot_df) == "value"] <- "n"

    p <- ggplot2::ggplot(dat, ggplot2::aes(
      x = .data[["group.by"]],
      y = .data[["value"]],
      fill = .data[["fill.by"]]
    )) +
      ggplot2::geom_point(
        data = dot_df,
        ggplot2::aes(
          x = .data[["group.by"]],
          y = .data[["bins"]],
          fill = .data[["fill.by"]],
          size = .data[["n"]]
        ),
        shape = 21, alpha = alpha, inherit.aes = FALSE,
        position = ggplot2::position_dodge(width = 0.9)
      ) +
      ggplot2::scale_size_area(name = "Count", max_size = 6, n.breaks = 4) +
      ggplot2::guides(
        size = ggplot2::guide_legend(
          override.aes = list(fill = "grey30", shape = 21), order = 2
        )
      )
    if (!is.null(bg.by)) {
      bg_layer <- .build_bg_layer(data, group.by, bg.by, bg_alpha, bg_palette)
      if (!is.null(bg_layer)) {
        p$layers <- c(list(bg_layer), p$layers)
      }
    }
  }

  # --- Overlay: add_box -------------------------------------------------------
  if (isTRUE(add_box) && type != "box") {
    p <- p +
      ggplot2::geom_boxplot(
        position = ggplot2::position_dodge(width = 0.9),
        color = box_color, fill = box_color,
        width = box_width, outlier.shape = NA, show.legend = FALSE
      ) +
      ggplot2::stat_summary(
        fun = stats::median, geom = "point",
        position = ggplot2::position_dodge(width = 0.9),
        color = "black", fill = "white", size = 1.5, shape = 21
      )
  }

  # --- Overlay: add_point -----------------------------------------------------
  if (isTRUE(add_point)) {
    p <- p + ggplot2::geom_point(
      ggplot2::aes(
        x = .data[["group.by"]],
        y = .data[["value"]]
      ),
      inherit.aes = FALSE,
      color = pt.color, size = pt.size, alpha = pt.alpha,
      position = ggplot2::position_jitterdodge(
        jitter.width = jitter.width, jitter.height = jitter.height,
        dodge.width = 0.9, seed = seed
      ),
      show.legend = FALSE
    )
  }

  # --- Overlay: add_trend -----------------------------------------------------
  if (isTRUE(add_trend) && type %in% c("violin", "box", "bar")) {
    trend_fun <- if (type == "bar") mean else stats::median
    p <- p +
      ggplot2::stat_summary(
        fun = trend_fun, geom = "line",
        ggplot2::aes(group = 1),
        color = trend_color, linewidth = trend_linewidth
      ) +
      ggplot2::stat_summary(
        fun = trend_fun, geom = "point",
        ggplot2::aes(group = 1),
        color = "black", fill = "white", size = trend_ptsize, shape = 21
      )
  }

  # --- Statistical comparisons ------------------------------------------------
  if (!is.null(comparisons)) {
    p <- p + ggpubr::stat_compare_means(
      ggplot2::aes(
        x = .data[["group.by"]],
        y = .data[["value"]]
      ),
      comparisons = comparisons,
      ref.group = ref_group,
      method = pairwise_method,
      label = sig_label,
      label.y = y_max_use,
      size = sig_labelsize,
      step.increase = 0.1,
      tip.length = 0.03,
      vjust = 0
    )
    # Extend y_max to accommodate labels
    y_max_use <- y_max_use + (y_max_use - y_min_use) * 0.15 * length(comparisons)
  }

  if (isTRUE(multiplegroup_comparisons)) {
    p <- p + ggpubr::stat_compare_means(
      ggplot2::aes(
        x = .data[["group.by"]],
        y = .data[["value"]]
      ),
      method = multiple_method,
      label = sig_label,
      label.y = y_max_use,
      size = sig_labelsize,
      vjust = 1.2, hjust = 0
    )
    y_max_use <- y_max_use + (y_max_use - y_min_use) * 0.1
  }

  # --- Coordinates & scales ---------------------------------------------------
  if (isTRUE(flip)) {
    p <- p + ggplot2::coord_flip(ylim = c(y_min_use, y_max_use))
  } else {
    p <- p + ggplot2::coord_cartesian(ylim = c(y_min_use, y_max_use))
  }

  p <- p + ggplot2::scale_y_continuous(n.breaks = y.nbreaks)

  # --- Fill scale -------------------------------------------------------------
  p <- p +
    ggplot2::scale_fill_manual(values = colors, drop = FALSE) +
    ggplot2::guides(
      fill = ggplot2::guide_legend(
        title.hjust = 0, order = 1,
        override.aes = list(alpha = 1)
      )
    )

  # --- X axis -----------------------------------------------------------------
  p <- p + ggplot2::scale_x_discrete(drop = FALSE)

  # --- Theme ------------------------------------------------------------------
  p <- p +
    theme_my(base_size = base_size) +
    ggplot2::theme(
      legend.position  = legend.position,
      legend.direction = legend.direction,
      aspect.ratio     = aspect.ratio,
      panel.grid.major.y = ggplot2::element_line(
        color = "grey", linetype = 2, linewidth = 0.3
      )
    )

  # --- Labs -------------------------------------------------------------------
  p <- p + ggplot2::labs(
    title = title, subtitle = subtitle, x = xlab, y = ylab
  )

  p
}


#' Build stacked (faceted) plot for multiple features
#' @noRd
.plt_con_stacked <- function(data, stat.by, group.by, bg.by,
                              type, fill.by, colors, alpha,
                              add_box, box_color, box_width,
                              add_point, pt.color, pt.size, pt.alpha,
                              jitter.width, jitter.height,
                              add_trend, trend_color, trend_linewidth,
                              trend_ptsize,
                              y.min, y.max, y.nbreaks, flip,
                              title, subtitle, xlab, ylab,
                              legend.position, legend.direction,
                              aspect.ratio, base_size,
                              bg_palette, bg_alpha, seed) {

  # Pivot to long format
  dat_long <- do.call(rbind, lapply(stat.by, function(f) {
    d <- data.frame(
      value    = data[[f]],
      group.by = data[[group.by]],
      feature  = f,
      stringsAsFactors = FALSE
    )
    d
  }))
  dat_long[["feature"]] <- factor(dat_long[["feature"]], levels = stat.by)
  dat_long[["group.by"]] <- factor(
    dat_long[["group.by"]], levels = levels(data[[group.by]])
  )

  if (fill.by == "group") {
    dat_long[["fill.by"]] <- dat_long[["group.by"]]
  } else {
    dat_long[["fill.by"]] <- dat_long[["feature"]]
  }

  # Remove non-finite

  dat_long <- dat_long[is.finite(dat_long[["value"]]), , drop = FALSE]

  # Y limits
  values <- dat_long[["value"]]
  y_max_use <- .resolve_y_limit(y.max, values, "max")
  y_min_use <- .resolve_y_limit(y.min, values, "min")

  p <- ggplot2::ggplot(dat_long, ggplot2::aes(
    x = .data[["group.by"]],
    y = .data[["value"]],
    fill = .data[["fill.by"]]
  ))

  # --- Type-specific geom ---
  if (type == "violin") {
    p <- p + ggplot2::geom_violin(
      scale = "width", trim = TRUE, alpha = alpha,
      position = ggplot2::position_dodge()
    )
  } else if (type == "box") {
    p <- p +
      ggplot2::geom_boxplot(
        position = ggplot2::position_dodge(width = 0.9),
        color = "black", width = 0.8, alpha = alpha,
        outlier.shape = NA
      ) +
      ggplot2::stat_summary(
        fun = stats::median, geom = "point",
        position = ggplot2::position_dodge(width = 0.9),
        color = "black", fill = "white", size = 1.5, shape = 21
      )
  } else if (type == "bar") {
    p <- p +
      ggplot2::geom_hline(yintercept = 0, linetype = 2) +
      ggplot2::stat_summary(
        fun = mean, geom = "col",
        position = ggplot2::position_dodge(width = 0.9),
        width = 0.8, color = "black", alpha = alpha
      ) +
      ggplot2::stat_summary(
        fun.data = ggplot2::mean_sdl, fun.args = list(mult = 1),
        geom = "errorbar",
        position = ggplot2::position_dodge(width = 0.9),
        width = 0.2, color = "black"
      )
    y_min_use <- min(0, y_min_use)
  } else if (type == "dot") {
    brks <- seq(min(dat_long[["value"]], na.rm = TRUE),
                max(dat_long[["value"]], na.rm = TRUE), length.out = 15)
    bins <- cut(dat_long[["value"]], breaks = brks, include.lowest = TRUE)
    bin_lvls <- levels(bins)
    bins_mid <- vapply(bin_lvls, function(lbl) {
      nums <- regmatches(lbl, gregexpr("-?[0-9.]+[eE]?[+-]?[0-9]*", lbl))[[1]]
      mean(as.numeric(nums), na.rm = TRUE)
    }, numeric(1))
    dat_long[["bins"]] <- bins_mid[as.character(bins)]
    dot_df <- stats::aggregate(
      value ~ group.by + fill.by + feature + bins,
      data = dat_long, FUN = length
    )
    names(dot_df)[names(dot_df) == "value"] <- "n"
    dot_df[["feature"]] <- factor(dot_df[["feature"]], levels = stat.by)
    p <- p +
      ggplot2::geom_point(
        data = dot_df,
        ggplot2::aes(
          x = .data[["group.by"]],
          y = .data[["bins"]],
          fill = .data[["fill.by"]],
          size = .data[["n"]]
        ),
        shape = 21, alpha = alpha, inherit.aes = FALSE,
        position = ggplot2::position_dodge(width = 0.9)
      ) +
      ggplot2::scale_size_area(name = "Count", max_size = 6, n.breaks = 4) +
      ggplot2::guides(
        size = ggplot2::guide_legend(
          override.aes = list(fill = "grey30", shape = 21), order = 2
        )
      )
  }

  # --- Overlays ---
  if (isTRUE(add_box) && type %in% c("violin", "bar")) {
    p <- p +
      ggplot2::geom_boxplot(
        position = ggplot2::position_dodge(width = 0.9),
        color = box_color, fill = box_color,
        width = box_width, outlier.shape = NA, show.legend = FALSE
      ) +
      ggplot2::stat_summary(
        fun = stats::median, geom = "point",
        position = ggplot2::position_dodge(width = 0.9),
        color = "black", fill = "white", size = 1.5, shape = 21
      )
  }

  if (isTRUE(add_point) && type != "dot") {
    p <- p + ggplot2::geom_point(
      ggplot2::aes(x = .data[["group.by"]], y = .data[["value"]]),
      inherit.aes = FALSE,
      color = pt.color, size = pt.size %||% 0.3, alpha = pt.alpha,
      position = ggplot2::position_jitterdodge(
        jitter.width = jitter.width, jitter.height = jitter.height,
        dodge.width = 0.9, seed = seed
      ),
      show.legend = FALSE
    )
  }

  if (isTRUE(add_trend) && type %in% c("violin", "box", "bar")) {
    trend_fun <- if (type == "bar") mean else stats::median
    p <- p +
      ggplot2::stat_summary(
        fun = trend_fun, geom = "line",
        ggplot2::aes(group = 1),
        color = trend_color, linewidth = trend_linewidth
      ) +
      ggplot2::stat_summary(
        fun = trend_fun, geom = "point",
        ggplot2::aes(group = 1),
        color = "black", fill = "white", size = trend_ptsize, shape = 21
      )
  }

  # --- Facet by feature ---
  if (isTRUE(flip)) {
    p <- p +
      ggplot2::facet_grid(. ~ feature) +
      ggplot2::coord_flip(ylim = c(y_min_use, y_max_use))
  } else {
    p <- p +
      ggplot2::facet_grid(feature ~ ., scales = "free_y") +
      ggplot2::coord_cartesian(ylim = c(y_min_use, y_max_use))
  }

  # --- Scales ---
  p <- p +
    ggplot2::scale_y_continuous(
      breaks = scales::breaks_pretty(n = y.nbreaks)
    ) +
    ggplot2::scale_fill_manual(values = colors, drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE)

  # --- Theme ---
  p <- p +
    theme_my(base_size = base_size) +
    ggplot2::theme(
      legend.position  = legend.position,
      legend.direction = legend.direction,
      aspect.ratio     = aspect.ratio,
      strip.text.y     = ggplot2::element_text(angle = 0),
      panel.grid.major.y = ggplot2::element_line(
        color = "grey", linetype = 2, linewidth = 0.3
      )
    )

  p <- p + ggplot2::labs(
    title = title, subtitle = subtitle, x = xlab, y = ylab
  )

  p
}
