# Plot formatting functions
# fmt_axis, fmt_tag, fmt_legend, fmt_ref, fmt_plot

# ---- fmt_axis ----

#' Hide or show axis elements for specific plots
#'
#' Selectively hide axis text, ticks, and titles for plots in a multi-plot
#' layout. Useful for removing redundant axes when plots share the same scale.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param x.axis Logical or integer vector. `FALSE` (default) keeps all x-axes.
#'   `TRUE` hides x-axis for all but the last plot. An integer vector specifies
#'   which plot indices should have their x-axis hidden.
#' @param y.axis Logical or integer vector. `FALSE` (default) keeps all y-axes.
#'   `TRUE` hides y-axis for all but the first plot. An integer vector specifies
#'   which plot indices should have their y-axis hidden.
#' @param plot_dims Integer vector of length 1 or 2 giving `c(nrow, ncol)` of
#'   the layout. When provided, automatically determines which axes to hide:
#'   x-axes are hidden for all rows except the last, y-axes for all columns
#'   except the first.
#'
#' @return Same type as input (ggplot, patchwork, or list).
#' @export
fmt_axis <- function(plot, x.axis = FALSE, y.axis = FALSE, plot_dims = NULL) {
  info <- .to_plot_list(plot)
  plots <- info$plots
  n <- length(plots)

  # When plot_dims is provided, compute which axes to hide

  if (!is.null(plot_dims)) {
    if (length(plot_dims) == 1L) {
      nr <- plot_dims[1]
      nc <- ceiling(n / nr)
    } else if (length(plot_dims) >= 2L) {
      nr <- plot_dims[1]
      nc <- plot_dims[2]
    } else {
      cli::cli_warn("{.arg plot_dims} format invalid, using original axis settings.")
      nr <- NA
      nc <- NA
    }

    if (!is.na(nr) && !is.na(nc) && nr > 0 && nc > 0) {
      # Hide x-axis for all rows except last
      if (nr > 1L) {
        last_row_start <- (nr - 1L) * nc + 1L
        x.axis <- seq_len(last_row_start - 1L)
        x.axis <- x.axis[x.axis <= n]
      }
      # Hide y-axis for all columns except first
      if (nc > 1L) {
        y.axis <- integer(0)
        for (row in seq_len(nr)) {
          for (col in 2L:nc) {
            idx <- (row - 1L) * nc + col
            if (idx <= n) y.axis <- c(y.axis, idx)
          }
        }
      }
    }
  }

  # Resolve indices to hide
  resolve_idx <- function(axis_arg, default_true) {
    if (isFALSE(axis_arg) || is.null(axis_arg)) return(integer(0))
    if (isTRUE(axis_arg)) return(default_true)
    if (is.numeric(axis_arg)) return(axis_arg[axis_arg >= 1L & axis_arg <= n])
    integer(0)
  }

  idx_x <- resolve_idx(x.axis, if (n > 1L) seq_len(n - 1L) else 1L)
  idx_y <- resolve_idx(y.axis, if (n > 1L) 2L:n else 1L)

  hide_x_theme <- ggplot2::theme(
    axis.text.x = ggplot2::element_blank(),
    axis.ticks.x = ggplot2::element_blank(),
    axis.title.x = ggplot2::element_blank(),
    axis.ticks.length.x = ggplot2::unit(0, "pt")
  )
  hide_y_theme <- ggplot2::theme(
    axis.text.y = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.ticks.length.y = ggplot2::unit(0, "pt")
  )

  for (i in idx_x) plots[[i]] <- plots[[i]] + hide_x_theme
  for (i in idx_y) plots[[i]] <- plots[[i]] + hide_y_theme

  .from_plot_list(plots, info$is_patchwork, info$is_single)
}

# ---- fmt_tag ----

#' Add panel labels to plots
#'
#' Add text labels (e.g. A, B, C) to the corner of each plot panel using
#' [ggpp::annotate()] with NPC coordinates.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param labels Character vector of labels. If `NULL` (default), uses
#'   `LETTERS[1:n]`.
#' @param label_position Numeric vector of length 2 giving NPC coordinates
#'   `c(x, y)` for label placement. Default `c(0.02, 0.98)` is top-left.
#' @param size Numeric label size in points. Default 16.
#' @param color Label text color. Default `"black"`.
#' @param fontface Font face for labels. Default `"bold"`.
#' @param ... Additional arguments passed to [ggpp::annotate()].
#'
#' @return Same type as input.
#' @export
fmt_tag <- function(plot,
                    labels = NULL,
                    label_position = c(0.02, 0.98),
                    size = 16,
                    color = "black",
                    fontface = "bold",
                    ...) {
  info <- .to_plot_list(plot)
  plots <- info$plots
  n <- length(plots)

  if (is.null(labels)) labels <- LETTERS[seq_len(n)]
  if (length(labels) < n) {
    labels <- rep_len(labels, n)
    cli::cli_warn("Labels recycled to match number of plots.")
  }

  if (!is.numeric(label_position) || length(label_position) != 2L) {
    cli::cli_warn("{.arg label_position} must be numeric length 2, using default.")
    label_position <- c(0.02, 0.98)
  }

  npcx <- rep_len(label_position[1], n)
  npcy <- rep_len(label_position[2], n)
  size <- rep_len(size, n)
  color <- rep_len(color, n)

  for (i in seq_len(n)) {
    plots[[i]] <- plots[[i]] +
      ggpp::annotate(
        "label_npc",
        npcx = npcx[i],
        npcy = npcy[i],
        label = labels[i],
        size = size[i] / ggplot2::.pt,
        fontface = fontface,
        color = color[i],
        size.unit = "mm",
        ...
      )
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single)
}

# ---- fmt_legend ----

#' Format legend position and style
#'
#' Adjust legend position, direction, layout, and optionally merge legends
#' across a multi-plot patchwork.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param legend.position Legend position. Either a character string
#'   (`"top"`, `"bottom"`, `"left"`, `"right"`, `"none"`) or a numeric vector
#'   of length 2 for coordinates inside the plot. Default `NULL` (no change).
#' @param legend.direction `"horizontal"` or `"vertical"`. Default `NULL`.
#' @param merge_legends Logical. If `TRUE` and input has multiple plots,
#'   collect legends into a single shared legend via patchwork. Default `FALSE`.
#' @param ncol Number of columns in the legend layout.
#' @param nrow Number of rows in the legend layout.
#' @param ... Additional arguments passed to [ggplot2::theme()].
#'
#' @return Same type as input.
#' @export
fmt_legend <- function(plot,
                       legend.position = NULL,
                       legend.direction = NULL,
                       merge_legends = FALSE,
                       ncol = NULL,
                       nrow = NULL,
                       ...) {
  info <- .to_plot_list(plot)
  plots <- info$plots
  n <- length(plots)

  if (!is.null(legend.direction) &&
      !legend.direction %in% c("horizontal", "vertical")) {
    cli::cli_warn("{.arg legend.direction} must be 'horizontal' or 'vertical'.")
    legend.direction <- NULL
  }

  # Build justification from character position

  legend.justification <- "center"
  if (is.character(legend.position)) {
    legend.justification <- switch(legend.position,
      "top"    = c(0.5, 0),
      "bottom" = c(0.5, 1),
      "left"   = c(1, 0.5),
      "right"  = c(0, 0.5),
      "none"   = c(0, 0),
      "center"
    )
  }

  # Build theme
  theme_args <- list(...)
  if (!is.null(legend.position))
    theme_args$legend.position <- legend.position
  if (!is.null(legend.direction))
    theme_args$legend.direction <- legend.direction
  theme_args$legend.justification <- legend.justification

  legend_theme <- do.call(ggplot2::theme, theme_args)

  # Guide layout
  guide_args <- list()
  if (!is.null(ncol) && is.numeric(ncol)) guide_args$ncol <- ncol
  if (!is.null(nrow) && is.numeric(nrow)) guide_args$nrow <- nrow

  if (length(guide_args) > 0) {
    guide_obj <- do.call(ggplot2::guide_legend, guide_args)
    legend_guides <- ggplot2::guides(
      fill = guide_obj, color = guide_obj, shape = guide_obj
    )
  } else {
    legend_guides <- NULL
  }

  # Merge legends mode for patchwork

  if (merge_legends && n > 1L && info$is_patchwork) {
    for (i in seq_len(n)) {
      plots[[i]] <- plots[[i]] + ggplot2::theme(legend.position = "none")
    }
    combined <- patchwork::wrap_plots(plots) +
      patchwork::plot_layout(guides = "collect")
    combined <- combined & legend_theme
    if (!is.null(legend_guides)) combined <- combined & legend_guides
    return(combined)
  }

  # Normal mode: apply to each plot

  for (i in seq_len(n)) {
    plots[[i]] <- plots[[i]] + legend_theme
    if (!is.null(legend_guides)) plots[[i]] <- plots[[i]] + legend_guides
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single)
}

# ---- fmt_ref ----

#' Add reference lines to plots
#'
#' Add vertical and/or horizontal reference lines to one or more plots. When
#' multiple intercept values are provided with matching per-line colors, each
#' line is added individually so that colors are applied correctly.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param x Numeric vector of x-intercept values for vertical lines, or `NULL`.
#' @param y Numeric vector of y-intercept values for horizontal lines, or `NULL`.
#' @param linetype Line type. Default `"dashed"`.
#' @param linewidth Line width. Default `0.5`.
#' @param color Line color(s). Recycled to match the number of intercepts.
#'   Default `"gray50"`.
#' @param alpha Line transparency. Default `0.8`.
#' @param ... Additional arguments passed to [ggplot2::geom_vline()] or
#'   [ggplot2::geom_hline()].
#'
#' @return Same type as input.
#' @export
fmt_ref <- function(plot,
                    x = NULL,
                    y = NULL,
                    linetype = "dashed",
                    linewidth = 0.5,
                    color = "gray50",
                    alpha = 0.8,
                    ...) {
  info <- .to_plot_list(plot)
  plots <- info$plots

  .add_ref_one <- function(p) {
    if (!is.null(x)) {
      x_color <- rep_len(color, length(x))
      x_lt <- rep_len(linetype, length(x))
      x_lw <- rep_len(linewidth, length(x))
      x_alpha <- rep_len(alpha, length(x))
      for (j in seq_along(x)) {
        p <- p + ggplot2::geom_vline(
          xintercept = x[j], linetype = x_lt[j], linewidth = x_lw[j],
          color = x_color[j], alpha = x_alpha[j], ...
        )
      }
    }
    if (!is.null(y)) {
      y_color <- rep_len(color, length(y))
      y_lt <- rep_len(linetype, length(y))
      y_lw <- rep_len(linewidth, length(y))
      y_alpha <- rep_len(alpha, length(y))
      for (j in seq_along(y)) {
        p <- p + ggplot2::geom_hline(
          yintercept = y[j], linetype = y_lt[j], linewidth = y_lw[j],
          color = y_color[j], alpha = y_alpha[j], ...
        )
      }
    }
    p
  }

  for (i in seq_along(plots)) {
    plots[[i]] <- .add_ref_one(plots[[i]])
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single)
}

# ---- fmt_plot ----

#' Master plot formatting function
#'
#' Convenience wrapper that chains [fmt_axis()], [fmt_tag()], [fmt_legend()],
#' and [fmt_ref()] in sequence. Each sub-formatter is applied only when its
#' corresponding `*_list` argument is non-NULL.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param fmt_axis_list Named list of arguments for [fmt_axis()]. Set to `NULL`
#'   (default) to skip.
#' @param fmt_tag_list Named list of arguments for [fmt_tag()]. Set to `NULL`
#'   to skip.
#' @param fmt_legend_list Named list of arguments for [fmt_legend()]. Set to
#'   `NULL` to skip.
#' @param fmt_ref_list Named list of arguments for [fmt_ref()]. Set to `NULL`
#'   to skip.
#' @param plot.margin Numeric vector of length 1 or 4, or a [ggplot2::margin()]
#'   object. Applied to all plots via `&`.
#' @param tag_levels Character string for patchwork tag levels (e.g. `"A"`,
#'   `"a"`, `"1"`). Only used when input is a patchwork object.
#' @param axis_titles Passed to [patchwork::plot_layout()] `axis_titles`
#'   argument. Only used when input is a patchwork object.
#' @param ... Currently unused.
#'
#' @return Same type as input.
#' @export
fmt_plot <- function(plot,
                     fmt_axis_list = NULL,
                     fmt_tag_list = NULL,
                     fmt_legend_list = NULL,
                     fmt_ref_list = NULL,
                     plot.margin = NULL,
                     tag_levels = NULL,
                     axis_titles = NULL,
                     ...) {

  # Apply axis formatting

  if (!is.null(fmt_axis_list)) {
    plot <- rlang::exec(fmt_axis, plot = plot, !!!fmt_axis_list)
  }

  # Apply tag labels

  if (!is.null(fmt_tag_list)) {
    plot <- rlang::exec(fmt_tag, plot = plot, !!!fmt_tag_list)
  }

  # Apply legend formatting

  if (!is.null(fmt_legend_list)) {
    plot <- rlang::exec(fmt_legend, plot = plot, !!!fmt_legend_list)
  }

  # Apply reference lines

  if (!is.null(fmt_ref_list)) {
    plot <- rlang::exec(fmt_ref, plot = plot, !!!fmt_ref_list)
  }

  # Apply plot margin

  if (!is.null(plot.margin)) {
    if (inherits(plot.margin, "margin")) {
      margin_obj <- plot.margin
    } else if (is.numeric(plot.margin)) {
      if (length(plot.margin) == 1L) {
        margin_obj <- ggplot2::margin(
          plot.margin, plot.margin, plot.margin, plot.margin
        )
      } else if (length(plot.margin) == 4L) {
        margin_obj <- ggplot2::margin(
          plot.margin[1], plot.margin[2], plot.margin[3], plot.margin[4]
        )
      } else {
        cli::cli_abort(
          "{.arg plot.margin} must be length 1 or 4, not {length(plot.margin)}."
        )
      }
    } else {
      cli::cli_abort("{.arg plot.margin} must be numeric or a margin object.")
    }
    plot <- plot & ggplot2::theme(plot.margin = margin_obj)
  }

  # Apply patchwork tag_levels

  if (!is.null(tag_levels) && inherits(plot, "patchwork")) {
    plot <- plot + patchwork::plot_annotation(tag_levels = tag_levels)
  }

  # Apply patchwork axis_titles

  if (!is.null(axis_titles) && inherits(plot, "patchwork")) {
    plot <- plot + patchwork::plot_layout(axis_titles = axis_titles)
  }

  plot
}
