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
#' @export
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
    strip_df <- data.frame(strip_label = cur_label)
    # Add strip column via a merge-safe approach (cbind constant column)
    plots[[i]] <- plots[[i]] +
      ggplot2::aes() +
      ggh4x::facet_wrap2(
        ~ strip_label,
        strip = create_strip(
          lc = if (!is.null(label_color)) label_color[i] else NULL,
          lf = if (!is.null(label_fill))  label_fill[i]  else NULL
        )
      )
    # Inject the strip_label column into the layer data
    plots[[i]]$data$strip_label <- cur_label
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single)
}

# ---- fmt_com ----

#' Add pairwise statistical comparisons
#'
#' Uses \code{ggpubr::geom_pwc} to overlay significance brackets.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param com_method Comparison method: \code{"con"} (consecutive), \code{"all"}
#'   (all pairs), or a list of length-2 character vectors.
#' @param label.y Numeric y-position for the first bracket (proportion of axis).
#' @param label Label type: \code{"p.signif"}, \code{"\{p.format\}\{p.signif\}"},
#'   or \code{"p.format"}.
#' @param ... Additional arguments passed to \code{ggpubr::geom_pwc}.
#'
#' @return Same type as input.
#' @export
fmt_com <- function(plot,
                    com_method = "con",
                    label.y = 0.8,
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
#' @export
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
#' @export
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
#' @export
fmt_scale <- function(plot, scale_x_list = NULL, scale_y_list = NULL) {
  apply_scale <- function(p, args, axis) {
    if (is.null(args) || length(args) == 0L) return(p)
    if (is.null(args$expand)) args$expand <- ggplot2::expansion(mult = c(0.02, 0.02))
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
#' @export
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
#' @export
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
