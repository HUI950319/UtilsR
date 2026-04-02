# Plot formatting functions
# fmt_axis, fmt_tag, fmt_legend, fmt_ref, fmt_plot, fmt_panel

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
#'
#' @examples
#' library(ggplot2)
#' p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()
#'
#' # Hide x-axis on first plot
#' fmt_axis(list(p1, p2), x.axis = 1)
#'
#' # Auto-detect 2x1 grid layout
#' fmt_axis(list(p1, p2), plot_dims = c(2, 1))
#'
#' @export
#' @family plot formatting
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
#'
#' @examples
#' library(ggplot2)
#' p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()
#'
#' # Auto-label A, B
#' fmt_tag(list(p1, p2))
#'
#' # Custom labels
#' fmt_tag(list(p1, p2), labels = c("i", "ii"))
#'
#' @export
#' @family plot formatting
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
        size = size[i],
        fontface = fontface,
        color = color[i],
        size.unit = "pt",
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
#' @param legend.position Legend position. Accepts:
#'   \itemize{
#'     \item Character: `"top"`, `"bottom"`, `"left"`, `"right"`, `"none"`.
#'     \item Shorthand corner codes: `"br"`, `"bl"`, `"tr"`, `"tl"` (inside
#'       plot corners).
#'     \item Numeric vector of length 2: `c(x, y)` coordinates (0-1) for
#'       inside-plot positioning.
#'   }
#'   Default `NULL` (no change).
#' @param legend.direction `"horizontal"` or `"vertical"`. Default `NULL`.
#' @param merge_legends Logical. If `TRUE` and input has multiple plots,
#'   collect legends into a single shared legend via patchwork. Default `FALSE`.
#' @param legend_theme A ggplot2 theme object for legend styling, e.g.,
#'   [theme_legend1()]. Applied after position/direction settings so it can
#'   override them. Default `NULL` (no extra styling).
#' @param ncol Number of columns in the legend layout (passed to
#'   [ggplot2::guide_legend()]).
#' @param nrow Number of rows in the legend layout (passed to
#'   [ggplot2::guide_legend()]).
#' @param ... Additional arguments passed to [ggplot2::theme()], e.g.,
#'   `legend.text`, `legend.key.size`, `legend.background`.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()
#'
#' fmt_legend(p, legend.position = "bottom", legend.direction = "horizontal")
#' fmt_legend(p, legend.position = "none")
#' fmt_legend(p, legend.position = "br")
#' fmt_legend(p, legend.position = c(0.9, 0.2))
#' fmt_legend(p, legend.position = "br", legend_theme = theme_legend1())
#'
#' @export
#' @family plot formatting
fmt_legend <- function(plot,
                       legend.position = NULL,
                       legend.direction = NULL,
                       legend_theme = NULL,
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

  # ---- Resolve corner shorthand to numeric coordinates ----
  corner_map <- list(
    br = c(0.95, 0.05), bl = c(0.05, 0.05),
    tr = c(0.95, 0.95), tl = c(0.05, 0.95)
  )
  if (is.character(legend.position) && legend.position %in% names(corner_map)) {
    legend.position <- corner_map[[legend.position]]
  }

  # ---- Build justification ----
  legend.justification <- NULL
  if (is.numeric(legend.position) && length(legend.position) == 2) {
    # Inside-plot: anchor the nearest corner
    just_x <- ifelse(legend.position[1] > 0.5, 1, 0)
    just_y <- ifelse(legend.position[2] > 0.5, 1, 0)
    legend.justification <- c(just_x, just_y)
  } else if (is.character(legend.position)) {
    legend.justification <- switch(legend.position,
      "top"    = c(0.5, 0),
      "bottom" = c(0.5, 1),
      "left"   = c(1, 0.5),
      "right"  = c(0, 0.5),
      NULL     # "none" or unknown: don't set justification
    )
  }

  # ---- Build theme ----
  theme_args <- list(...)
  if (!is.null(legend.position))
    theme_args$legend.position <- legend.position
  if (!is.null(legend.direction))
    theme_args$legend.direction <- legend.direction
  if (!is.null(legend.justification))
    theme_args$legend.justification <- legend.justification

  leg_theme <- do.call(ggplot2::theme, theme_args)

  # Append legend_theme (e.g., theme_legend1()) — overrides conflicting keys
  if (!is.null(legend_theme) && inherits(legend_theme, "theme")) {
    leg_theme <- leg_theme + legend_theme
  }

  # ---- Guide layout (ncol/nrow) ----
  guide_args <- list()
  if (!is.null(ncol) && is.numeric(ncol)) guide_args$ncol <- ncol
  if (!is.null(nrow) && is.numeric(nrow)) guide_args$nrow <- nrow

  legend_guides <- NULL
  if (length(guide_args) > 0) {
    guide_obj <- do.call(ggplot2::guide_legend, guide_args)
    # Apply to all common legend aesthetics
    legend_guides <- ggplot2::guides(
      fill = guide_obj, colour = guide_obj,
      shape = guide_obj, size = guide_obj, alpha = guide_obj,
      linetype = guide_obj
    )
  }

  # ---- Merge legends mode for patchwork ----
  if (merge_legends && n > 1L && info$is_patchwork) {
    # Preserve original patchwork layout
    combined <- plot + patchwork::plot_layout(guides = "collect")
    combined <- combined & leg_theme
    if (!is.null(legend_guides)) combined <- combined & legend_guides
    return(combined)
  }

  # ---- Normal mode: apply to each plot ----
  for (i in seq_len(n)) {
    plots[[i]] <- plots[[i]] + leg_theme
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
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_ref(p, x = 5.5, y = 3.0)
#' fmt_ref(p, x = c(5, 6), color = c("red", "blue"))
#'
#' @export
#' @family plot formatting
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
#'
#' @examples
#' library(ggplot2)
#' p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()
#' p2 <- ggplot(iris, aes(Petal.Length, Petal.Width, color = Species)) + geom_point()
#'
#' # Single plot with reference line and legend
#' fmt_plot(p1, ref_x = 5.5, legend.position = "bottom")
#'
#' # Multi-plot with tags and merged legend
#' fmt_plot(list(p1, p2), tag = TRUE, merge_legends = TRUE)
#'
#' @export
#' @family plot formatting
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
# fmt_plot2.R
# Additional plot formatting functions: strip, comparison, background,
# histogram, scale, expand, boxplot overlay.

# ---- fmt_strip ----

#' Add facet strip labels to a plot
#'
#' Wraps each plot in a single-panel \code{ggh4x::facet_wrap2} so that a
#' coloured strip label appears above the panel.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param label Character vector of strip labels (recycled as needed).
#' @param label_color Text colour(s) for the strip label. Default \code{"white"}.
#' @param label_fill Background fill colour(s) for the strip. If \code{NULL},
#'   strips use a transparent background.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_strip(p, label = "Iris Data", label_fill = "steelblue")
#'
#' @export
#' @family plot formatting
fmt_strip <- function(plot, label = NULL, label_color = "white", label_fill = NULL) {
  info <- .to_plot_list(plot)
  plots <- info$plots
  n <- length(plots)

  if (is.null(label)) label <- paste0("Figure", seq_len(n))
  label <- rep_len(label, n)
  if (!is.null(label_color)) label_color <- rep_len(label_color, n)
  if (!is.null(label_fill))  label_fill  <- rep_len(label_fill, n)

  create_strip <- function(lc, lf) {
    if (!is.null(lf)) {
      ggh4x::strip_themed(
        background_x = ggh4x::elem_list_rect(fill = lf),
        text_x = list(ggplot2::element_text(colour = lc, face = "bold"))
      )
    } else if (!is.null(lc)) {
      ggh4x::strip_themed(
        text_x = ggh4x::elem_list_text(colour = lc, face = "bold")
      )
    } else {
      ggh4x::strip_themed()
    }
  }

  for (i in seq_len(n)) {
    cur_label <- label[i]
    # Inject the strip_label column into the plot data BEFORE setting facet
    if (!is.null(plots[[i]]$data) && is.data.frame(plots[[i]]$data)) {
      plots[[i]]$data$.strip_label. <- cur_label
    }
    facet_formula <- ggplot2::vars(.data[[".strip_label."]])
    plots[[i]] <- plots[[i]] +
      ggh4x::facet_wrap2(
        facet_formula,
        strip = create_strip(
          lc = if (!is.null(label_color)) label_color[i] else NULL,
          lf = if (!is.null(label_fill))  label_fill[i]  else NULL
        )
      )
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single)
}

# ---- fmt_panel ----

#' Format panel appearance
#'
#' Control panel grid lines, border, and background in one call.
#' Inspired by Seurat's \code{NoGrid()} but with fine-grained control
#' over each panel element.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param grid Which grid lines to display.
#'   \itemize{
#'     \item \code{"none"} — remove all grid lines (default).
#'     \item \code{"major"} — show only major grid lines.
#'     \item \code{"minor"} — show only minor grid lines.
#'     \item \code{"both"} — show both major and minor grid lines.
#'     \item \code{"x"} — show only vertical (x-axis) major grid lines.
#'     \item \code{"y"} — show only horizontal (y-axis) major grid lines.
#'   }
#' @param grid_color Color of retained grid lines. Default \code{NULL}
#'   (inherit from current theme).
#' @param grid_linewidth Numeric. Line width of retained grid lines.
#'   Default \code{NULL} (inherit from current theme).
#' @param grid_linetype Linetype of retained grid lines (e.g.
#'   \code{"solid"}, \code{"dashed"}, \code{"dotted"}).
#'   Default \code{NULL} (inherit from current theme).
#' @param border Logical or character.
#'   \itemize{
#'     \item \code{TRUE} — draw a black rectangle border around the panel.
#'     \item \code{FALSE} — remove the panel border.
#'     \item A color string (e.g. \code{"grey50"}) — draw border in that color.
#'     \item \code{NULL} (default) — no change.
#'   }
#' @param border_linewidth Numeric. Border line width. Default 0.5.
#' @param bg Panel background color. \code{NULL} (default) = no change,
#'   \code{"white"}, \code{"transparent"}, or any valid color string.
#' @param ... Additional arguments passed to [ggplot2::theme()].
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point()
#'
#' # Remove all grid lines (most common usage, like Seurat::NoGrid())
#' fmt_panel(p)
#'
#' # Keep only major grid lines
#' fmt_panel(p, grid = "major")
#'
#' # Keep only horizontal (y-axis) grid lines
#' fmt_panel(p, grid = "y")
#'
#' # Add border + white background + no grid
#' fmt_panel(p, grid = "none", border = TRUE, bg = "white")
#'
#' # Custom border color
#' fmt_panel(p, border = "grey40", border_linewidth = 1)
#'
#' # Dashed grey grid lines
#' fmt_panel(p, grid = "major", grid_color = "grey80",
#'           grid_linewidth = 0.3, grid_linetype = "dashed")
#'
#' # Dotted y-axis grid only
#' fmt_panel(p, grid = "y", grid_linetype = "dotted", grid_color = "grey70")
#'
#' @export
#' @family plot formatting
fmt_panel <- function(plot,
                      grid = c("none", "major", "minor", "both", "x", "y"),
                      grid_color = NULL,
                      grid_linewidth = NULL,
                      grid_linetype = NULL,
                      border = NULL,
                      border_linewidth = 0.5,
                      bg = NULL,
                      ...) {
  grid <- match.arg(grid)
  blank <- ggplot2::element_blank()

  # ---- Helper: build element_line for retained grid lines ----
  grid_line <- function() {
    args <- list()
    if (!is.null(grid_color))     args$colour   <- grid_color
    if (!is.null(grid_linewidth)) args$linewidth <- grid_linewidth
    if (!is.null(grid_linetype))  args$linetype  <- grid_linetype
    if (length(args) == 0L) return(NULL)
    do.call(ggplot2::element_line, args)
  }
  gl <- grid_line()

  # ---- Build grid theme ----
  grid_theme <- switch(grid,
    "none" = ggplot2::theme(
      panel.grid.major = blank,
      panel.grid.minor = blank
    ),
    "major" = {
      th <- ggplot2::theme(panel.grid.minor = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.major = gl)
      th
    },
    "minor" = {
      th <- ggplot2::theme(panel.grid.major = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.minor = gl)
      th
    },
    "both" = {
      if (!is.null(gl)) ggplot2::theme(panel.grid.major = gl, panel.grid.minor = gl)
      else ggplot2::theme()
    },
    "x" = {
      th <- ggplot2::theme(panel.grid.major.y = blank, panel.grid.minor = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.major.x = gl)
      th
    },
    "y" = {
      th <- ggplot2::theme(panel.grid.major.x = blank, panel.grid.minor = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.major.y = gl)
      th
    }
  )

  # ---- Build border theme ----
  border_theme <- ggplot2::theme()
  if (!is.null(border)) {
    if (isTRUE(border)) {
      border_theme <- ggplot2::theme(
        panel.border = ggplot2::element_rect(
          colour = "black", fill = NA, linewidth = border_linewidth
        )
      )
    } else if (isFALSE(border)) {
      border_theme <- ggplot2::theme(panel.border = blank)
    } else if (is.character(border)) {
      border_theme <- ggplot2::theme(
        panel.border = ggplot2::element_rect(
          colour = border, fill = NA, linewidth = border_linewidth
        )
      )
    }
  }

  # ---- Build background theme ----
  bg_theme <- ggplot2::theme()
  if (!is.null(bg)) {
    bg_theme <- ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = bg, colour = NA)
    )
  }

  # ---- Combine all + extra ... ----
  extra_theme <- if (length(list(...)) > 0) do.call(ggplot2::theme, list(...)) else ggplot2::theme()
  panel_theme <- grid_theme + border_theme + bg_theme + extra_theme

  # ---- Apply to plots ----
  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, function(p) p + panel_theme)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_axisText ----

#' Format axis text rotation and style
#'
#' Rotate and style axis tick labels for X and/or Y axes. Inspired by
#' Seurat's \code{RotatedAxis()} but with independent control over both
#' axes, rotation angle, and text appearance.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param x Numeric. Rotation angle (degrees) for X-axis text.
#'   Common values: \code{45} (diagonal), \code{90} (vertical).
#'   Default \code{NULL} (no change).
#' @param y Numeric. Rotation angle (degrees) for Y-axis text.
#'   Default \code{NULL} (no change).
#' @param x_hjust Numeric. Horizontal justification for X-axis text.
#'   Default \code{NULL} (auto: 1 when \code{x > 0}, 0 when \code{x < 0},
#'   0.5 when \code{x = 0}).
#' @param x_vjust Numeric. Vertical justification for X-axis text.
#'   Default \code{NULL} (auto: 0.5 when \code{abs(x) >= 90}, 1 otherwise).
#' @param y_hjust Numeric. Horizontal justification for Y-axis text.
#'   Default \code{NULL} (auto).
#' @param y_vjust Numeric. Vertical justification for Y-axis text.
#'   Default \code{NULL} (auto).
#' @param size Numeric. Text size for both axes. Default \code{NULL}
#'   (no change).
#' @param color Character. Text color for both axes. Default \code{NULL}
#'   (no change).
#' @param face Character. Font face (\code{"plain"}, \code{"bold"},
#'   \code{"italic"}, \code{"bold.italic"}). Default \code{NULL}
#'   (no change).
#' @param ... Additional arguments passed to [ggplot2::theme()].
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#'
#' # Rotate X-axis 45 degrees (like Seurat::RotatedAxis())
#' fmt_axisText(p, x = 45)
#'
#' # Rotate X-axis 90 degrees (vertical)
#' fmt_axisText(p, x = 90)
#'
#' # Rotate both axes
#' fmt_axisText(p, x = 45, y = -30)
#'
#' # With custom size and bold
#' fmt_axisText(p, x = 45, size = 10, face = "bold")
#'
#' @export
#' @family plot formatting
fmt_axisText <- function(plot,
                     x = NULL,
                     y = NULL,
                     x_hjust = NULL,
                     x_vjust = NULL,
                     y_hjust = NULL,
                     y_vjust = NULL,
                     size = NULL,
                     color = NULL,
                     face = NULL,
                     ...) {

  # ---- Auto-compute hjust/vjust for rotated text ----
  auto_just <- function(angle, hjust, vjust, axis = "x") {
    if (is.null(angle)) return(list(hjust = hjust, vjust = vjust))
    if (is.null(hjust)) {
      hjust <- if (axis == "x") {
        if (angle > 0) 1 else if (angle < 0) 0 else 0.5
      } else {
        if (angle > 0) 0 else if (angle < 0) 1 else 0.5
      }
    }
    if (is.null(vjust)) {
      vjust <- if (abs(angle) >= 90) 0.5 else if (axis == "x") 1 else 0.5
    }
    list(hjust = hjust, vjust = vjust)
  }

  # ---- Build X-axis text theme ----
  x_theme <- ggplot2::theme()
  if (!is.null(x) || !is.null(size) || !is.null(color) || !is.null(face)) {
    x_just <- auto_just(x, x_hjust, x_vjust, "x")
    x_args <- list()
    if (!is.null(x))     x_args$angle <- x
    if (!is.null(x))     x_args$hjust <- x_just$hjust
    if (!is.null(x))     x_args$vjust <- x_just$vjust
    if (!is.null(size))  x_args$size  <- size
    if (!is.null(color)) x_args$colour <- color
    if (!is.null(face))  x_args$face  <- face
    if (length(x_args) > 0L) {
      x_theme <- ggplot2::theme(
        axis.text.x = do.call(ggplot2::element_text, x_args)
      )
    }
  }

  # ---- Build Y-axis text theme ----
  y_theme <- ggplot2::theme()
  if (!is.null(y) || !is.null(size) || !is.null(color) || !is.null(face)) {
    y_just <- auto_just(y, y_hjust, y_vjust, "y")
    y_args <- list()
    if (!is.null(y))     y_args$angle <- y
    if (!is.null(y))     y_args$hjust <- y_just$hjust
    if (!is.null(y))     y_args$vjust <- y_just$vjust
    if (!is.null(size))  y_args$size  <- size
    if (!is.null(color)) y_args$colour <- color
    if (!is.null(face))  y_args$face  <- face
    if (length(y_args) > 0L) {
      y_theme <- ggplot2::theme(
        axis.text.y = do.call(ggplot2::element_text, y_args)
      )
    }
  }

  # ---- Combine + extra ... ----
  extra <- if (length(list(...)) > 0) do.call(ggplot2::theme, list(...)) else ggplot2::theme()
  text_theme <- x_theme + y_theme + extra

  # ---- Apply to plots ----
  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, function(p) p + text_theme)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_axisTile ----

#' Add colored tiles between axis and labels
#'
#' Insert a strip of colored tiles between the plot area and the axis text
#' labels. Two modes are available:
#' \itemize{
#'   \item \code{"tile"} (default) — insert a \code{geom_tile} color strip
#'     between the axis line and text labels via patchwork. Labels appear
#'     below (x-axis) or beside (y-axis) the tiles.
#'   \item \code{"text"} — color the axis label text directly (no background
#'     tile), lightweight but uses unofficial vectorized \code{element_text}.
#' }
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param colors Named character vector of colors, where names match the
#'   discrete axis levels (e.g. \code{c(setosa = "red", virginica = "blue")}).
#'   Required.
#' @param mode \code{"tile"} (default) or \code{"text"}.
#' @param axis Which axis to apply to: \code{"x"} (default) or \code{"y"}.
#' @param tile_height Numeric. Relative height of the tile strip when
#'   \code{axis = "x"}. Default 0.06.
#' @param tile_width Numeric. Relative width of the tile strip when
#'   \code{axis = "y"}. Default 0.06.
#' @param tile_border Color of tile borders. Default \code{"white"}.
#' @param tile_border_width Line width of tile borders. Default 0.2.
#' @param text_size Size of axis text labels below/beside tiles. Default 9.
#' @param text_face Font face of axis text labels. Default \code{"plain"}.
#' @param text_angle Rotation angle for axis text labels. Default \code{45}
#'   for x-axis, \code{0} for y-axis.
#' @param text_color Color of axis text labels. Default \code{"black"}.
#' @param show_text Logical. Show text labels below/beside tiles?
#'   Default \code{TRUE}. Set \code{FALSE} for color-only tiles.
#'
#' @return A patchwork object (when \code{mode = "tile"}) or same type as
#'   input (when \code{mode = "text"}).
#'
#' @examples
#' library(ggplot2)
#' cols <- c(setosa = "#E64B35", versicolor = "#4DBBD5", virginica = "#00A087")
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#'
#' # Tile mode: color strip between axis and rotated labels
#' fmt_axisTile(p, colors = cols)
#'
#' # Tile mode: no text labels, color-only strip
#' fmt_axisTile(p, colors = cols, show_text = FALSE)
#'
#' # Text mode: colored axis labels (no tiles)
#' fmt_axisTile(p, colors = cols, mode = "text")
#'
#' # Y-axis tiles
#' p2 <- ggplot(iris, aes(Sepal.Length, Species)) + geom_boxplot()
#' fmt_axisTile(p2, colors = cols, axis = "y")
#'
#' @export
#' @family plot formatting
fmt_axisTile <- function(plot,
                         colors,
                         mode = c("tile", "text"),
                         axis = c("x", "y"),
                         tile_height = 0.06,
                         tile_width = 0.06,
                         tile_border = "white",
                         tile_border_width = 0.2,
                         text_size = 9,
                         text_face = "plain",
                         text_angle = NULL,
                         text_color = "black",
                         show_text = TRUE) {

  if (!requireNamespace("patchwork", quietly = TRUE))
    cli::cli_abort("Package {.pkg patchwork} is required for fmt_axisTile().")

  mode <- match.arg(mode)
  axis <- match.arg(axis)

  # Default text_angle: 45 for x-axis, 0 for y-axis
  if (is.null(text_angle)) text_angle <- if (axis == "x") 45 else 0

  info <- .to_plot_list(plot)
  plots <- info$plots

  # ---- Text mode: color axis labels directly ----
  if (mode == "text") {
    text_theme_fn <- function(p) {
      lvs <- .extract_discrete_levels(p, axis)
      if (is.null(lvs)) return(p)
      col_vec <- colors[lvs]
      col_vec[is.na(col_vec)] <- "black"
      if (axis == "x") {
        hjust <- if (text_angle > 0) 1 else if (text_angle < 0) 0 else 0.5
        p + ggplot2::theme(axis.text.x = ggplot2::element_text(
          colour = col_vec, face = text_face, size = text_size,
          angle = text_angle, hjust = hjust))
      } else {
        p + ggplot2::theme(axis.text.y = ggplot2::element_text(
          colour = col_vec, face = text_face, size = text_size,
          angle = text_angle))
      }
    }
    info$plots <- lapply(plots, text_theme_fn)
    return(.from_plot_list(info$plots, info$is_patchwork, info$is_single))
  }

  # ---- Tile mode: color strip + labels below/beside ----

  build_tile_bar <- function(lvs, orientation = "x") {
    df_bar <- data.frame(
      lbl = factor(lvs, levels = lvs),
      pos = 1
    )
    col_use <- colors[lvs]
    col_use[is.na(col_use)] <- "grey70"

    if (orientation == "x") {
      p_bar <- ggplot2::ggplot(df_bar, ggplot2::aes(
        x = .data[["lbl"]], y = .data[["pos"]], fill = .data[["lbl"]])) +
        ggplot2::geom_tile(color = tile_border, linewidth = tile_border_width) +
        ggplot2::scale_fill_manual(values = col_use, guide = "none") +
        ggplot2::scale_x_discrete(drop = FALSE) +
        ggplot2::theme_void() +
        ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))

      # Text labels below the tiles as axis text
      if (show_text) {
        hjust <- if (text_angle > 0) 1 else if (text_angle < 0) 0 else 0.5
        vjust <- if (abs(text_angle) >= 90) 0.5 else 1
        p_bar <- p_bar + ggplot2::theme(
          axis.text.x = ggplot2::element_text(
            size = text_size, face = text_face, color = text_color,
            angle = text_angle, hjust = hjust, vjust = vjust))
      }
    } else {
      p_bar <- ggplot2::ggplot(df_bar, ggplot2::aes(
        x = .data[["pos"]], y = .data[["lbl"]], fill = .data[["lbl"]])) +
        ggplot2::geom_tile(color = tile_border, linewidth = tile_border_width) +
        ggplot2::scale_fill_manual(values = col_use, guide = "none") +
        ggplot2::scale_y_discrete(drop = FALSE) +
        ggplot2::theme_void() +
        ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))

      if (show_text) {
        p_bar <- p_bar + ggplot2::theme(
          axis.text.y = ggplot2::element_text(
            size = text_size, face = text_face, color = text_color,
            angle = text_angle, hjust = 1))
      }
    }
    p_bar
  }

  blank <- ggplot2::element_blank()

  combine_one <- function(p) {
    lvs <- .extract_discrete_levels(p, axis)
    if (is.null(lvs)) return(p)
    p_bar <- build_tile_bar(lvs, axis)

    if (axis == "x") {
      # Hide original x-axis text, keep axis title on the main plot
      p <- p + ggplot2::theme(
        axis.text.x = blank, axis.ticks.x = blank,
        axis.title.x = blank)
      # Move x-axis title below tiles if present
      patchwork::wrap_plots(p, p_bar, ncol = 1,
                            heights = c(1, tile_height))
    } else {
      p <- p + ggplot2::theme(
        axis.text.y = blank, axis.ticks.y = blank,
        axis.title.y = blank)
      patchwork::wrap_plots(p_bar, p, ncol = 2,
                            widths = c(tile_width, 1))
    }
  }

  if (info$is_single) {
    return(combine_one(plots[[1]]))
  }

  combined <- lapply(plots, combine_one)
  if (info$is_patchwork) {
    patchwork::wrap_plots(combined)
  } else {
    combined
  }
}

#' Extract discrete axis levels from a ggplot
#' @noRd
.extract_discrete_levels <- function(p, axis = "x") {
  mapping_var <- p$mapping[[axis]]
  if (is.null(mapping_var)) return(NULL)
  var_name <- rlang::as_name(mapping_var)
  if (is.null(p$data) || !var_name %in% colnames(p$data)) return(NULL)
  col <- p$data[[var_name]]
  if (is.factor(col)) levels(col) else sort(unique(col))
}

# ---- fmt_com ----

#' Add pairwise statistical comparisons
#'
#' Uses \code{ggpubr::geom_pwc} to overlay significance brackets.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param com_method Comparison method: \code{"con"} (consecutive), \code{"all"}
#'   (all pairs), or a list of length-2 character vectors.
#' @param label.y Numeric y-position for the first bracket (absolute y-axis value,
#'   not proportion). Default \code{NULL} lets ggpubr auto-calculate.
#' @param label Label type: \code{"p.signif"}, \code{"\{p.format\}\{p.signif\}"},
#'   or \code{"p.format"}.
#' @param ... Additional arguments passed to \code{ggpubr::geom_pwc}.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#'
#' # Consecutive comparisons (default)
#' fmt_com(p)
#'
#' # All pairwise comparisons
#' fmt_com(p, com_method = "all")
#'
#' # Custom comparisons
#' fmt_com(p, com_method = list(c("setosa", "virginica"), c("setosa", "versicolor")))
#'
#' # Show p-value instead of stars
#' fmt_com(p, label = "p.format")
#'
#' # Show both p-value and stars
#' fmt_com(p, label = "{p.format}{p.signif}")
#'
#' # Adjust bracket y-position (absolute y-axis value, not proportion)
#' fmt_com(p, label.y = 8)
#'
#' @export
#' @family plot formatting
fmt_com <- function(plot,
                    com_method = "con",
                    label.y = NULL,
                    label = c("p.signif", "{p.format}{p.signif}", "p.format"),
                    ...) {
  label <- match.arg(label)

  get_comparisons <- function(p, cm) {
    x_var <- rlang::as_name(p$mapping$x)
    if (is.null(x_var)) cli::cli_abort("No x variable found in ggplot mapping.")
    x_data <- p$data[[x_var]]
    lvs <- if (is.factor(x_data)) levels(x_data) else sort(unique(x_data))

    if (is.list(cm)) {
      if (!all(vapply(cm, length, integer(1)) == 2L))
        cli::cli_abort("com_method list must contain vectors of length 2.")
      all_grps <- unique(unlist(cm))
      if (!all(all_grps %in% lvs))
        cli::cli_abort("Some groups in com_method are not in x variable levels.")
      comps <- cm
    } else {
      comps <- switch(cm,
        con = Map(c, lvs[-length(lvs)], lvs[-1]),
        all = utils::combn(lvs, 2, simplify = FALSE),
        cli::cli_abort("com_method must be 'con', 'all', or a list.")
      )
    }
    # Convert to numeric indices
    lapply(comps, function(el) {
      if (!is.numeric(el)) which(lvs %in% el) else el
    })
  }

  fmt_com_one <- function(p) {
    p +
      ggpubr::geom_pwc(
        method.args = list(comparisons = get_comparisons(p, com_method)),
        symnum.args = list(
          cutpoints = c(0, 0.001, 0.01, 0.05, Inf),
          symbols = c("***", "**", "*", "ns")
        ),
        label = label,
        size = 0.8,
        step.increase = 0.05,
        tip.length = 0.025,
        y.position = label.y,
        fontface = "bold",
        ...
      )
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_com_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_bg ----

#' Add coloured background stripes
#'
#' Inserts shaded rectangles behind the data layer, one per level of the
#' categorical axis variable.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param palette Palette name passed to \code{plotthis::palette_this}.
#' @param palcolor Manual colour vector (overrides palette).
#' @param alpha Transparency of the background rectangles.
#' @param bg_axis Which axis holds the categorical variable: \code{"x"} or
#'   \code{"y"}.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#' fmt_bg(p, alpha = 0.2)
#'
#' @export
#' @family plot formatting
fmt_bg <- function(plot,
                   palette = NULL,
                   palcolor = NULL,
                   alpha = 0.3,
                   bg_axis = c("x", "y")) {
  bg_axis <- match.arg(bg_axis)

  # Unified background layer builder for both x and y axes
  build_bg_layer <- function(data, var_name, palette, palcolor, alpha,
                             facet_by = NULL, bg_axis = "x") {
    fct <- droplevels(data[[var_name]])
    lvs <- levels(fct)

    bg_color <- tryCatch(
      plotthis::palette_this(lvs, palette = palette, palcolor = palcolor),
      error = function(e) {
        cols <- grDevices::rainbow(length(lvs), alpha = 0.3)
        stats::setNames(cols, lvs)
      }
    )

    n <- length(lvs)
    nums <- seq_len(n)
    bg_data <- data.frame(pos = nums)

    if (bg_axis == "x") {
      bg_data$xmin <- ifelse(nums == 1L, -Inf, nums - 0.5)
      bg_data$xmax <- ifelse(nums == n,   Inf, nums + 0.5)
      bg_data$ymin <- -Inf
      bg_data$ymax <- Inf
    } else {
      bg_data$xmin <- -Inf
      bg_data$xmax <- Inf
      bg_data$ymin <- ifelse(nums == 1L, -Inf, nums - 0.5)
      bg_data$ymax <- ifelse(nums == n,   Inf, nums + 0.5)
    }
    bg_data$fill <- bg_color[lvs]

    # Handle faceting
    if (!is.null(facet_by) && length(facet_by) > 0) {
      valid_fb <- facet_by[facet_by %in% colnames(data)]
      if (length(valid_fb) > 0) {
        uv <- dplyr::distinct(data, dplyr::across(dplyr::all_of(valid_fb)))
        bg_data <- tidyr::expand_grid(bg_data, uv)
        for (fb in valid_fb) {
          if (is.factor(data[[fb]])) {
            bg_data[[fb]] <- factor(bg_data[[fb]], levels = levels(data[[fb]]))
          }
        }
      }
    }

    ggplot2::geom_rect(
      data = bg_data,
      ggplot2::aes(
        xmin = .data[["xmin"]], xmax = .data[["xmax"]],
        ymin = .data[["ymin"]], ymax = .data[["ymax"]]
      ),
      fill = bg_data$fill, alpha = alpha, inherit.aes = FALSE
    )
  }

  # Extract facet variables from a plot
  extract_facet_vars <- function(p) {
    if (is.null(p$facet)) return(NULL)
    tryCatch({
      fv <- NULL
      if (inherits(p$facet, "FacetWrap")) {
        fv <- p$facet$params$facets
        fv <- if (is.list(fv)) vapply(fv, rlang::as_name, character(1)) else rlang::as_name(fv)
      } else if (inherits(p$facet, "FacetGrid")) {
        rv <- p$facet$params$rows
        cv <- p$facet$params$cols
        fv <- character(0)
        if (length(rv) > 0) fv <- c(fv, vapply(rv, rlang::as_name, character(1)))
        if (length(cv) > 0) fv <- c(fv, vapply(cv, rlang::as_name, character(1)))
      }
      fv
    }, error = function(e) NULL)
  }

  fmt_bg_one <- function(p) {
    mapping_var <- p$mapping[[bg_axis]]
    if (is.null(mapping_var)) {
      cli::cli_warn("No {bg_axis}-axis mapping found; skipping background.")
      return(p)
    }
    axis_var <- rlang::as_name(mapping_var)
    facet_vars <- extract_facet_vars(p)

    bg_layer <- build_bg_layer(
      data = p$data, var_name = axis_var,
      palette = palette, palcolor = palcolor, alpha = alpha,
      facet_by = facet_vars, bg_axis = bg_axis
    )
    p$layers <- c(list(bg_layer), p$layers)
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_bg_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_his ----

#' Add marginal histogram or density overlay
#'
#' Overlays a rescaled histogram or density curve on the existing plot,
#' using the x-axis variable (or a user-supplied variable).
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param type \code{"histogram"} (or \code{"h"}) or \code{"density"}
#'   (or \code{"d"}).
#' @param height_ratio Fraction of the y-axis range used for the overlay height.
#' @param data Optional data frame. If \code{NULL}, uses the plot data.
#' @param con_var Variable name for the x-axis. If \code{NULL}, extracted from
#'   the plot mapping.
#' @param ... Additional arguments: \code{binwidth}, \code{adjust},
#'   \code{his_color}, \code{his_alpha}, \code{y_rescale}, \code{ylim}.
#'
#' @return Same type as input.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_his(p, type = "histogram", height_ratio = 0.3)
#' fmt_his(p, type = "density", height_ratio = 0.2)
#' }
#'
#' @export
#' @family plot formatting
fmt_his <- function(plot,
                    type = c("histogram", "density", "h", "d"),
                    height_ratio = 0.3,
                    data = NULL,
                    con_var = NULL,
                    ...) {
  type <- match.arg(type)
  if (startsWith(type, "h")) type <- "histogram"
  if (startsWith(type, "d")) type <- "density"

  dots <- list(...)
  binwidth  <- dots$binwidth  %||% 3

  adjust    <- dots$adjust    %||% 3
  his_color <- dots$his_color %||% "gray85"
  his_alpha <- dots$his_alpha %||% 0.5
  y_rescale <- dots$y_rescale
  ylim      <- dots$ylim

  fmt_his_one <- function(p) {
    # Resolve data and variable
    d <- data %||% p$data
    if (is.null(d)) cli::cli_abort("No data found in plot and `data` is NULL.")
    v <- con_var %||% {
      if (!is.null(p$mapping$x)) rlang::as_name(p$mapping$x)
      else cli::cli_abort("No x variable found and `con_var` is NULL.")
    }
    if (!v %in% names(d)) cli::cli_abort("Variable '{v}' not found in data.")

    # Y-axis range
    built <- ggplot2::ggplot_build(p)
    y_range <- built$layout$panel_params[[1]]$y.range %||% c(0, 1)
    y_min <- y_range[1]
    y_max <- y_range[2]
    hist_height <- (y_max - y_min) * height_ratio

    yr <- y_rescale %||% c(y_min, y_min + hist_height)
    yl <- ylim %||% c(y_min, y_max)

    if (type == "histogram") {
      p <- p +
        ggplot2::geom_histogram(
          data = d,
          mapping = ggplot2::aes(
            x = .data[[v]],
            y = scales::rescale(ggplot2::after_stat(count), yr)
          ),
          fill = his_color, color = his_color,
          binwidth = binwidth, alpha = his_alpha,
          position = "stack"
        ) +
        ggplot2::coord_cartesian(ylim = yl)
    } else {
      p <- p +
        ggplot2::geom_density(
          data = d,
          mapping = ggplot2::aes(
            x = .data[[v]],
            y = scales::rescale(ggplot2::after_stat(density), yr)
          ),
          fill = his_color,
          color = ggplot2::alpha(his_color, his_alpha),
          alpha = his_alpha, adjust = adjust
        ) +
        ggplot2::coord_cartesian(ylim = yl)
    }
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_his_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_scale ----

#' Set axis scales
#'
#' Automatically detects discrete / continuous / date scale type and applies
#' user-supplied arguments via \code{do.call}.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param scale_x_list Named list of arguments for the x-axis scale function.
#' @param scale_y_list Named list of arguments for the y-axis scale function.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_scale(p, scale_x_list = list(limits = c(4, 8), breaks = seq(4, 8, 1)))
#'
#' @export
#' @family plot formatting
fmt_scale <- function(plot, scale_x_list = NULL, scale_y_list = NULL) {
  apply_scale <- function(p, args, axis) {
    if (is.null(args) || length(args) == 0L) return(p)
    fn_name <- .detect_scale_type(p, axis)
    fn <- utils::getFromNamespace(fn_name, "ggplot2")
    tryCatch(
      p + do.call(fn, args),
      error = function(e) {
        fallback <- utils::getFromNamespace(paste0("scale_", axis, "_continuous"), "ggplot2")
        p + do.call(fallback, args)
      }
    )
  }

  fmt_scale_one <- function(p) {
    p <- apply_scale(p, scale_x_list, "x")
    p <- apply_scale(p, scale_y_list, "y")
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_scale_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_expand ----

#' Set axis expansion
#'
#' Applies \code{ggplot2::expansion()} to one or both axes, automatically
#' detecting the correct scale type.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param mult Multiplicative expansion factor.
#' @param add Additive expansion (length-2 vector for lower/upper).
#' @param axis \code{"x"}, \code{"y"}, or \code{NULL} (both).
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_expand(p, mult = 0.05)
#' fmt_expand(p, add = c(0.5, 0), axis = "x")
#'
#' @export
#' @family plot formatting
fmt_expand <- function(plot, mult = 0, add = c(0, 0), axis = NULL) {
  if (!is.null(axis) && !axis %in% c("x", "y"))
    cli::cli_abort("`axis` must be 'x', 'y', or NULL.")

  expansion_setting <- ggplot2::expansion(add = add, mult = mult)

  apply_expansion <- function(p, ax) {
    fn_name <- .detect_scale_type(p, ax)
    fn <- utils::getFromNamespace(fn_name, "ggplot2")
    tryCatch(
      p + fn(expand = expansion_setting),
      error = function(e) {
        fallback <- utils::getFromNamespace(paste0("scale_", ax, "_continuous"), "ggplot2")
        p + fallback(expand = expansion_setting)
      }
    )
  }

  fmt_expand_one <- function(p) {
    axes <- if (is.null(axis)) c("x", "y") else axis
    for (ax in axes) {
      p <- apply_expansion(p, ax)
    }
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_expand_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# ---- fmt_boxplot ----

#' Overlay a boxplot layer
#'
#' Adds \code{geom_boxplot} on top of existing layers (e.g. violin, jitter).
#' Outliers are suppressed by default.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param boxplot.args Named list of arguments passed to
#'   \code{ggplot2::geom_boxplot}. Defaults include \code{width = 0.3},
#'   \code{alpha = 0.2}, \code{na.rm = TRUE}.
#' @param inherit.aes Whether to inherit aesthetics from the parent plot.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_violin()
#' fmt_boxplot(p)
#' fmt_boxplot(p, boxplot.args = list(width = 0.2, alpha = 0.5))
#'
#' @export
#' @family plot formatting
fmt_boxplot <- function(plot,
                        boxplot.args = list(),
                        inherit.aes = TRUE) {
  # Set sensible defaults
  defaults <- list(width = 0.3, alpha = 0.2, na.rm = TRUE)
  for (nm in names(defaults)) {
    if (is.null(boxplot.args[[nm]])) boxplot.args[[nm]] <- defaults[[nm]]
  }
  boxplot.args$outlier.shape <- NA
  boxplot.args$inherit.aes <- inherit.aes

  fmt_boxplot_one <- function(p) {
    args <- boxplot.args
    if (!inherit.aes) {
      pd <- p$data
      pm <- p$mapping
      if (is.null(pd) || is.null(pm$x) || is.null(pm$y)) {
        cli::cli_warn("Cannot extract data/mapping; falling back to inherit.aes = TRUE.")
        args$inherit.aes <- TRUE
      } else {
        args$data <- pd
        args$mapping <- ggplot2::aes(x = !!pm$x, y = !!pm$y)
      }
    }
    p + rlang::exec(ggplot2::geom_boxplot, !!!args)
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_boxplot_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}
