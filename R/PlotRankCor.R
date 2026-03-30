# ============================================================================
# PlotRankCor.R -- Rank Correlation Scatter Plot
# ============================================================================

#' Rank Correlation Scatter Plot
#'
#' Compare two methods by plotting their ranks against each other. Spearman
#' correlation and p-value are computed internally and displayed as subtitles.
#' When multiple groups exist (e.g. PHPT vs SHPT), each group is shown as a
#' separate facet with its own correlation statistics.
#'
#' @param data Data frame in long format. Must contain columns specified by
#'   \code{stat.by}, \code{value.by}, \code{group.by}, and \code{method.by}.
#' @param stat.by Character. Column name for the category labels
#'   (e.g. cell type). Labels are shown via \code{geom_text_repel}.
#' @param value.by Character. Column name for the numeric score used to
#'   compute ranks. Ranks are computed as \code{rank(-score)} (descending)
#'   within each \code{group.by} x \code{method.by} combination.
#' @param group.by Character. Column name for the grouping / faceting
#'   variable (e.g. comparison). Each level gets its own facet panel.
#'   If \code{NULL}, all data is treated as a single group (no faceting).
#' @param method.by Character. Column name identifying the two methods.
#'   Must have exactly 2 unique levels; the first level maps to the x-axis
#'   and the second to the y-axis.
#' @param use_rank Logical. If \code{TRUE} (default), plot ranks and compute
#'   Spearman correlation. If \code{FALSE}, plot raw values and compute
#'   Pearson correlation.
#' @param scale_x Character. Scaling method for x-axis values (only when
#'   \code{use_rank = FALSE}). One of \code{"none"} (default), \code{"minmax"},
#'   \code{"zscore"}, \code{"log1p"}, or \code{"rank"}. Applied per group.
#' @param scale_y Character. Scaling method for y-axis values (only when
#'   \code{use_rank = FALSE}). Same options as \code{scale_x}.
#' @param size_by Character or \code{NULL}. Column name for a numeric variable
#'   to map to point size. The column values are aggregated (mean) across the
#'   two methods per stat x group combination. A continuous size scale is added
#'   to the plot. Default \code{NULL} (all points use fixed \code{pt.size}).
#' @param size_range Numeric vector of length 2. Range of point sizes when
#'   \code{size_by} is specified. Default \code{c(1, 6)}.
#' @param alpha_by Character or \code{NULL}. Column name for a numeric
#'   variable to map to point transparency (alpha), producing a colour-depth
#'   effect -- darker points indicate higher values. Values are aggregated
#'   (mean) across the two methods per stat x group combination. Overrides
#'   the fixed \code{alpha}. Similar to \code{alpha.by} in
#'   \code{\link{PlotButterfly}}. Default \code{NULL} (uniform alpha).
#' @param alpha_range Numeric vector of length 2. Output alpha range for
#'   \code{alpha_by} mapping. Default \code{c(0.3, 1)}.
#' @param palette Named or unnamed character vector of colours for
#'   \code{group.by} levels. Default \code{NULL} uses
#'   \code{c("#B2182B", "#2166AC", ...)} from \code{pal_lancet}.
#' @param pt.size Numeric. Point size (used when \code{size_by = NULL}).
#'   Default 3.
#' @param alpha Numeric 0--1. Point transparency (used when
#'   \code{alpha_by = NULL}). Default 0.8.
#' @param label.size Numeric. Label text size. Default 3.
#' @param max.overlaps Integer. Maximum overlapping labels passed to
#'   \code{\link[ggrepel]{geom_text_repel}}. Default 20.
#' @param show.label Logical. Whether to display text labels. Default
#'   \code{TRUE}.
#' @param show.diag Logical. Whether to show the diagonal reference line
#'   (y = x). Default \code{TRUE}.
#' @param title Character. Plot title. Default \code{NULL} (auto-generated).
#' @param xlab Character. X-axis label. Default \code{NULL} (auto).
#' @param ylab Character. Y-axis label. Default \code{NULL} (auto).
#' @param base_size Numeric. Base font size. Default 13.
#' @param legend.position Legend position. Default \code{"none"}.
#' @param width Numeric. Output width in inches. Default 12.
#' @param height Numeric. Output height in inches. Default 6.
#' @param filename Character. File path to save the plot. Default
#'   \code{NULL} (no saving).
#'
#' @return A \code{ggplot} object. The correlation results are also
#'   attached as an attribute \code{"cor_results"} (a data frame with
#'   columns: \code{group}, \code{rho}, \code{p.value}).
#'
#' @examples
#' set.seed(42)
#' df <- data.frame(
#'   cell_type  = rep(LETTERS[1:8], times = 4),
#'   score      = runif(32, 0, 1),
#'   pvalue     = runif(32, 0, 0.1),
#'   comparison = rep(rep(c("PHPT", "SHPT"), each = 8), 2),
#'   method     = rep(c("scMMR", "miloR"), each = 16)
#' )
#'
#' # Basic usage
#' PlotRankCor(df, stat.by = "cell_type", value.by = "score",
#'             group.by = "comparison", method.by = "method")
#'
#' # With size mapping
#' PlotRankCor(df, stat.by = "cell_type", value.by = "score",
#'             group.by = "comparison", method.by = "method",
#'             size_by = "score", legend.position = "right")
#'
#' # With alpha depth (darker = higher score)
#' PlotRankCor(df, stat.by = "cell_type", value.by = "score",
#'             group.by = "comparison", method.by = "method",
#'             alpha_by = "score")
#'
#' # Combined: size + alpha depth
#' PlotRankCor(df, stat.by = "cell_type", value.by = "score",
#'             group.by = "comparison", method.by = "method",
#'             size_by = "score", alpha_by = "pvalue",
#'             legend.position = "right")
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_abline facet_wrap
#'   scale_color_manual scale_size_continuous scale_alpha_continuous
#'   labs guide_legend guides
#' @importFrom ggrepel geom_text_repel
#' @export
#' @family plot
PlotRankCor <- function(
    data,
    stat.by    = NULL,
    value.by   = NULL,
    group.by   = NULL,
    method.by  = NULL,
    use_rank   = TRUE,
    scale_x    = "none",
    scale_y    = "none",
    size_by    = NULL,
    size_range = c(1, 6),
    alpha_by   = NULL,
    alpha_range = c(0.3, 1),
    palette    = NULL,
    pt.size    = 3,
    alpha      = 0.8,
    label.size = 3,
    max.overlaps = 20,
    show.label = TRUE,
    show.diag  = TRUE,
    title      = NULL,
    xlab       = NULL,
    ylab       = NULL,
    base_size  = 13,
    legend.position = "none",
    width      = 12,
    height     = 6,
    filename   = NULL
) {

  # ---- Validation ----
  for (arg in c("stat.by", "value.by", "method.by")) {
    val <- get(arg)
    if (is.null(val))
      cli::cli_abort("{.arg {arg}} is required.")
    if (!val %in% names(data))
      cli::cli_abort("Column {.val {val}} not found in {.arg data}.")
  }
  if (!is.null(group.by) && !group.by %in% names(data))
    cli::cli_abort("Column {.val {group.by}} not found in {.arg data}.")
  if (!is.null(size_by) && !size_by %in% names(data))
    cli::cli_abort("Column {.val {size_by}} not found in {.arg data}.")
  if (!is.null(alpha_by) && !alpha_by %in% names(data))
    cli::cli_abort("Column {.val {alpha_by}} not found in {.arg data}.")

  methods <- unique(as.character(data[[method.by]]))
  if (length(methods) != 2L)
    cli::cli_abort("{.arg method.by} must have exactly 2 levels, got {length(methods)}.")

  # ---- Compute ranks ----
  if (is.null(group.by)) {
    data$.group <- "all"
    group.by_internal <- ".group"
  } else {
    group.by_internal <- group.by
  }

  # Compute plot values: rank or raw value
  if (use_rank) {
    rank_long <- do.call(rbind, lapply(
      split(data, interaction(data[[group.by_internal]], data[[method.by]],
                              drop = TRUE)),
      function(d) {
        d$.plot_val <- rank(-d[[value.by]], ties.method = "average")
        d
      }
    ))
  } else {
    rank_long <- data
    rank_long$.plot_val <- rank_long[[value.by]]
  }
  rownames(rank_long) <- NULL

  # ---- Aggregate extra aesthetic columns before pivot ----
  extra_cols <- unique(c(size_by, alpha_by))
  extra_cols <- extra_cols[!is.null(extra_cols)]

  if (length(extra_cols) > 0) {
    agg_key <- paste(rank_long[[stat.by]], rank_long[[group.by_internal]],
                     sep = "|||")
    agg_df <- do.call(rbind, lapply(split(rank_long, agg_key), function(d) {
      row <- d[1, c(stat.by, group.by_internal), drop = FALSE]
      for (ec in extra_cols) {
        row[[ec]] <- mean(d[[ec]], na.rm = TRUE)
      }
      row
    }))
    rownames(agg_df) <- NULL
  }

  # Aggregate duplicates before pivot (mean per stat.by x group x method)
  pivot_data <- rank_long[, c(stat.by, group.by_internal, method.by, ".plot_val")]
  agg_key_piv <- paste(pivot_data[[stat.by]], pivot_data[[group.by_internal]],
                        pivot_data[[method.by]], sep = "|||")
  pivot_data <- do.call(rbind, lapply(split(pivot_data, agg_key_piv), function(d) {
    row <- d[1, c(stat.by, group.by_internal, method.by), drop = FALSE]
    row$.plot_val <- mean(d$.plot_val, na.rm = TRUE)
    row
  }))
  rownames(pivot_data) <- NULL

  # Pivot to wide: one column per method
  rank_wide <- stats::reshape(
    pivot_data,
    idvar     = c(stat.by, group.by_internal),
    timevar   = method.by,
    v.names   = ".plot_val",
    direction = "wide"
  )
  colnames(rank_wide) <- gsub("^\\.plot_val\\.", "", colnames(rank_wide))

  # Merge extra columns back into rank_wide
  if (length(extra_cols) > 0) {
    rank_wide <- merge(rank_wide, agg_df,
                       by = c(stat.by, group.by_internal),
                       all.x = TRUE)
  }

  # ---- Scale x/y values (only when use_rank = FALSE) ----
  .scale_vec <- function(x, method) {
    switch(method,
      "none"   = x,
      "minmax" = {
        rng <- range(x, na.rm = TRUE)
        if (rng[2] == rng[1]) return(rep(0, length(x)))
        (x - rng[1]) / (rng[2] - rng[1])
      },
      "zscore" = {
        mu <- mean(x, na.rm = TRUE)
        sd_val <- stats::sd(x, na.rm = TRUE)
        if (sd_val == 0) return(rep(0, length(x)))
        (x - mu) / sd_val
      },
      "log1p"  = log1p(abs(x)) * sign(x),
      "rank"   = rank(-x, ties.method = "average"),
      x  # fallback
    )
  }

  if (!use_rank) {
    valid_methods <- c("none", "minmax", "zscore", "log1p", "rank")
    if (!scale_x %in% valid_methods)
      cli::cli_abort("{.arg scale_x} must be one of {.val {valid_methods}}.")
    if (!scale_y %in% valid_methods)
      cli::cli_abort("{.arg scale_y} must be one of {.val {valid_methods}}.")

    if (scale_x != "none") {
      for (g in unique(as.character(rank_wide[[group.by_internal]]))) {
        idx <- rank_wide[[group.by_internal]] == g
        rank_wide[[methods[1]]][idx] <- .scale_vec(
          rank_wide[[methods[1]]][idx], scale_x)
      }
    }
    if (scale_y != "none") {
      for (g in unique(as.character(rank_wide[[group.by_internal]]))) {
        idx <- rank_wide[[group.by_internal]] == g
        rank_wide[[methods[2]]][idx] <- .scale_vec(
          rank_wide[[methods[2]]][idx], scale_y)
      }
    }
  }

  # ---- Spearman correlation per group ----
  groups <- unique(as.character(rank_wide[[group.by_internal]]))
  cor_results <- do.call(rbind, lapply(groups, function(g) {
    sub <- rank_wide[rank_wide[[group.by_internal]] == g, ]
    x <- sub[[methods[1]]]
    y <- sub[[methods[2]]]
    ok <- complete.cases(x, y)
    if (sum(ok) < 3) {
      return(data.frame(group = g, rho = NA_real_, p.value = NA_real_,
                        stringsAsFactors = FALSE))
    }
    cor_method <- if (use_rank) "spearman" else "pearson"
    ct <- stats::cor.test(x[ok], y[ok], method = cor_method, exact = FALSE)
    data.frame(group = g, rho = ct$estimate, p.value = ct$p.value,
               stringsAsFactors = FALSE)
  }))
  rownames(cor_results) <- NULL

  # Print correlation results
  for (i in seq_len(nrow(cor_results))) {
    cat(sprintf("  %s: rho = %.3f, p = %.4g\n",
                cor_results$group[i], cor_results$rho[i],
                cor_results$p.value[i]))
  }

  # ---- Build subtitle with correlation info ----
  cor_label <- if (use_rank) "rho" else "r"
  sub_parts <- vapply(seq_len(nrow(cor_results)), function(i) {
    sprintf("%s: %s = %.3f (p = %.3g)",
            cor_results$group[i], cor_label, cor_results$rho[i],
            cor_results$p.value[i])
  }, character(1))
  subtitle <- paste(sub_parts, collapse = "    ")

  # ---- Resolve palette ----
  n_groups <- length(groups)
  if (is.null(palette)) {
    cols <- as.character(pal_lancet[seq_len(min(n_groups, length(pal_lancet)))])
  } else if (length(palette) == 1L && palette %in% names(palette_list)) {
    cols <- as.character(pal_get(palette, n = n_groups))
  } else {
    cols <- as.character(palette)
  }
  if (is.null(names(cols)) && length(cols) >= n_groups) {
    names(cols) <- groups
  }

  # ---- Labels ----
  if (use_rank) {
    x_suffix <- "rank"
    y_suffix <- "rank"
    cor_type <- "Rank"
  } else {
    x_suffix <- if (scale_x == "none") "value" else scale_x
    y_suffix <- if (scale_y == "none") "value" else scale_y
    cor_type <- "Value"
  }
  if (is.null(title)) title <- sprintf("%s Correlation: %s vs %s",
                                       cor_type, methods[1], methods[2])
  if (is.null(xlab)) xlab <- sprintf("%s (%s)", methods[1], x_suffix)
  if (is.null(ylab)) ylab <- sprintf("%s (%s)", methods[2], y_suffix)

  # ---- Plot ----
  p <- ggplot2::ggplot(rank_wide,
                       ggplot2::aes(x = .data[[methods[1]]],
                                    y = .data[[methods[2]]]))

  # Build point layer with conditional aesthetics
  point_aes <- ggplot2::aes(color = .data[[group.by_internal]])

  # Add size_by to aes if specified
  if (!is.null(size_by)) {
    point_aes <- utils::modifyList(point_aes,
                                    ggplot2::aes(size = .data[[size_by]]))
  }
  # Add alpha_by to aes if specified
  if (!is.null(alpha_by)) {
    point_aes <- utils::modifyList(point_aes,
                                    ggplot2::aes(alpha = .data[[alpha_by]]))
  }

  # Fixed params for geom_point
  fixed_params <- list()
  if (is.null(size_by))  fixed_params$size  <- pt.size
  if (is.null(alpha_by)) fixed_params$alpha <- alpha

  p <- p +
    do.call(ggplot2::geom_point,
            c(list(mapping = point_aes), fixed_params))

  if (isTRUE(show.diag)) {
    p <- p + ggplot2::geom_abline(slope = 1, intercept = 0,
                                   linetype = "dashed", color = "grey50")
  }

  if (isTRUE(show.label)) {
    p <- p + ggrepel::geom_text_repel(
      ggplot2::aes(label = .data[[stat.by]]),
      size = label.size, max.overlaps = max.overlaps
    )
  }

  if (length(groups) > 1) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", group.by_internal)))
  }

  # ---- Scales ----
  p <- p + ggplot2::scale_color_manual(values = cols)

  if (!is.null(size_by)) {
    p <- p + ggplot2::scale_size_continuous(range = size_range,
                                            name  = size_by)
  }

  if (!is.null(alpha_by)) {
    p <- p + ggplot2::scale_alpha_continuous(range = alpha_range,
                                             name  = alpha_by)
  }

  # Auto-show legend when size_by or alpha_by is used
  if (identical(legend.position, "none") &&
      (!is.null(size_by) || !is.null(alpha_by))) {
    legend.position <- c(0.8, 0.2)
  }

  p <- p +
    ggplot2::labs(title = title, subtitle = subtitle,
                  x = xlab, y = ylab) +
    theme_my(base_size = base_size, legend.position = legend.position)

  # Restore legend title when size_by or alpha_by is used
  if (!is.null(size_by) || !is.null(alpha_by)) {
    p <- p + ggplot2::theme(legend.title = ggplot2::element_text())
  }

  # ---- Save ----
  if (!is.null(filename)) {
    ggplot2::ggsave(filename, p,
                    width = width, height = height, dpi = 300, bg = "white")
    cli::cli_alert_success("Plot saved to {.file {filename}}")
  }

  attr(p, "cor_results") <- cor_results
  p
}
