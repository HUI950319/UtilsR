# ============================================================================
# theme.R -- Custom ggplot2 themes based on ggprism
# ============================================================================

#' @import ggplot2
#' @importFrom grid unit
NULL

#' Custom ggplot2 Theme Based on ggprism
#'
#' A customizable ggplot2 theme built on top of \code{ggprism} palettes, with
#' additional control over grid lines, panel spacing, plot margins, and axis
#' text angle.
#'
#' @param palette Character. A valid ggprism palette name (e.g.
#'   \code{"black_and_white"}, \code{"office"}). See
#'   \code{names(ggprism::ggprism_data$themes)}.
#' @param base_size Numeric. Base font size (default 14).
#' @param base_family Character. Base font family (default \code{"sans"}).
#' @param base_fontface Character. Base font face (default \code{"bold"}).
#' @param base_line_size Numeric. Base line size.
#' @param base_rect_size Numeric. Base rect size.
#' @param axis_text_angle Numeric. Axis text rotation angle. Must be one of
#'   0, 45, 90, 270.
#' @param border Logical. Whether to draw panel border (default \code{TRUE}).
#' @param legend.position Legend position (default \code{"right"}).
#' @param panel.grid A \code{ggplot2::element_line} for major grid lines.
#' @param panel.grid.minor A \code{ggplot2::element_line} for minor grid lines.
#' @param panel.spacing Panel spacing. Accepts numeric (converted to pt),
#'   \code{grid::unit} object, or \code{NULL} (default: 0 pt).
#' @param plot.margin Plot margin. Accepts \code{NULL} (auto), a single
#'   numeric, or a length-4 numeric vector (top, right, bottom, left).
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(iris, aes(Petal.Length, Petal.Width)) +
#'   geom_point() +
#'   theme_my()
#'
#' ggplot(iris, aes(Petal.Length, Petal.Width)) +
#'   geom_point() +
#'   facet_wrap(~Species) +
#'   theme_my(panel.spacing = unit(0, "pt"))
#' }
#'
#' @export
#' @family ggplot2 themes
theme_my <- function(palette = "black_and_white", base_size = 14,
                     base_family = "sans", base_fontface = "bold",
                     base_line_size = base_size / 14,
                     base_rect_size = base_size / 14,
                     axis_text_angle = 0,
                     border = TRUE,
                     legend.position = "right",
                     panel.grid = element_line(color = "lightgray",
                                               linetype = "dashed",
                                               linewidth = 0.1),
                     panel.grid.minor = element_line(color = "lightgray",
                                                      linetype = "dashed",
                                                      linewidth = 0.1),
                     panel.spacing = unit(0, "pt"),
                     plot.margin = NULL) {

  # Process plot.margin
  if (is.null(plot.margin)) {
    margin_val <- rep(base_size / 2, 4)
  } else if (is.numeric(plot.margin)) {
    if (length(plot.margin) == 1) {
      margin_val <- rep(plot.margin, 4)
    } else if (length(plot.margin) == 4) {
      margin_val <- plot.margin
    } else {
      stop("plot.margin \u5fc5\u987b\u4e3a\u957f\u5ea6\u4e3a1\u62164\u7684\u6570\u503c\u5411\u91cf\uff0c\u6216\u4e3aNULL")
    }
  } else {
    stop("plot.margin \u5fc5\u987b\u4e3a\u6570\u503c\u6216NULL")
  }
  plot.margin <- ggplot2::margin(margin_val[1], margin_val[2],
                                  margin_val[3], margin_val[4])

  # Process panel.spacing
  if (is.null(panel.spacing)) {
    panel.spacing <- unit(base_size / 2, "pt")
  } else if (is.numeric(panel.spacing)) {
    panel.spacing <- unit(panel.spacing, "pt")
  } else if (inherits(panel.spacing, "unit")) {
    # already a unit object
  } else {
    stop("panel.spacing \u5fc5\u987b\u4e3a\u6570\u503c\u3001unit\u5bf9\u8c61\u6216NULL")
  }

  # Validate axis_text_angle
  angle <- axis_text_angle[1]
  if (!angle %in% c(0, 45, 90, 270))
    stop(sprintf("'axis_text_angle' must be one of [%s]",
                 paste(c(0, 45, 90, 270), collapse = ", ")),
         ".\nFor other angles, use the guide_axis() function in ggplot2 instead",
         call. = FALSE)

  # Get element colours from palette
  if (!palette %in% names(ggprism::ggprism_data$themes)) {
    stop("The palette ", paste(palette), " does not exist.
         See names(ggprism_data$themes) for valid palette names")
  }
  colours <- tibble::deframe(ggprism::ggprism_data$themes[[palette]])

  # Draw border or not
  if (!rlang::is_bool(border)) {
    stop("border must be either: TRUE or FALSE")
  } else {
    if (border) {
      panel.border <- element_rect(fill = NA)
      axis.line <- element_blank()
    } else {
      panel.border <- element_blank()
      axis.line <- element_line()
    }
  }

  thm <- theme(
    # Base elements
    line = element_line(colour = colours["axisColor"],
                        linewidth = base_line_size,
                        linetype = 1, lineend = "square"),
    rect = element_rect(fill = "white", colour = colours["axisColor"],
                         linewidth = base_rect_size, linetype = 1),
    text = element_text(family = base_family, face = base_fontface,
                         colour = colours["graphTitleColor"], size = base_size,
                         lineheight = 0.9, hjust = 0.5, vjust = 0.5, angle = 0,
                         margin = ggplot2::margin(), debug = FALSE),

    # Prism custom theme elements
    prism.ticks.length = unit(base_size / 5, "pt"),

    # Axis
    axis.line =          axis.line,
    axis.line.x =        NULL,
    axis.line.y =        NULL,
    axis.text =          element_text(size = rel(0.95),
                                      colour = colours["axisLabelColor"]),
    axis.text.x =        element_text(
      margin = ggplot2::margin(t = 0.8 * base_size / 4),
      angle = axis_text_angle,
      hjust = ifelse(axis_text_angle %in% c(45, 90, 270), 1, 0.5),
      vjust = ifelse(axis_text_angle %in% c(0, 90, 270), 0.5, 1)
    ),
    axis.text.x.top =    element_text(
      margin = ggplot2::margin(b = 0.8 * base_size / 4), vjust = 0
    ),
    axis.text.y =        element_text(
      margin = ggplot2::margin(r = 0.5 * base_size / 4), hjust = 1
    ),
    axis.text.y.right =  element_text(
      margin = ggplot2::margin(l = 0.5 * base_size / 4), hjust = 0
    ),
    axis.ticks =         element_line(),
    axis.ticks.length =  unit(base_size / 2.5, "pt"),
    axis.ticks.length.x = NULL,
    axis.ticks.length.x.top = NULL,
    axis.ticks.length.x.bottom = NULL,
    axis.ticks.length.y = NULL,
    axis.ticks.length.y.left = NULL,
    axis.ticks.length.y.right = NULL,
    axis.title =         element_text(colour = colours["axisTitleColor"]),
    axis.title.x =       element_text(
      margin = ggplot2::margin(t = base_size * 0.6), vjust = 1
    ),
    axis.title.x.top =   element_text(
      margin = ggplot2::margin(b = base_size * 0.6), vjust = 0
    ),
    axis.title.y =       element_text(
      angle = 90, margin = ggplot2::margin(r = base_size * 0.6), vjust = 1
    ),
    axis.title.y.right = element_text(
      angle = -90, margin = ggplot2::margin(l = base_size * 0.6), vjust = 0
    ),

    # Legend
    legend.background =  element_blank(),
    legend.spacing =     unit(base_size, "pt"),
    legend.spacing.x =   NULL,
    legend.spacing.y =   NULL,
    legend.margin =      ggplot2::margin(base_size / 2, base_size / 2,
                                          base_size / 2, base_size / 2),
    legend.key =         element_blank(),
    legend.key.size =    unit(1.2, "lines"),
    legend.key.height =  NULL,
    legend.key.width =   unit(base_size * 1.8, "pt"),
    legend.text =        element_text(size = rel(0.8), face = "plain"),
    legend.text.align =  NULL,
    legend.title =       element_blank(),
    legend.title.align = NULL,
    legend.position =    legend.position,
    legend.direction =   NULL,
    legend.justification = "center",
    legend.box =         NULL,
    legend.box.margin =  ggplot2::margin(0, 0, 0, 0, "cm"),
    legend.box.background = element_blank(),
    legend.box.spacing = unit(base_size, "pt"),

    # Panel
    panel.background = element_rect(
      fill = ifelse(palette == "office", colours["plottingAreaColor"], NA),
      colour = NA
    ),
    panel.border =       panel.border,
    panel.grid =         panel.grid,
    panel.grid.minor =   panel.grid.minor,
    panel.spacing =      panel.spacing,
    panel.spacing.x =    NULL,
    panel.spacing.y =    NULL,
    panel.ontop    =     FALSE,

    # Strip
    strip.background =   element_rect(fill = "grey85", colour = "grey20"),
    strip.text =         element_text(
      colour = colours["axisTitleColor"], size = rel(1),
      margin = ggplot2::margin(t = base_size / 1.5, r = base_size / 2.5,
                                b = base_size / 1.5, l = base_size / 2.5),
      hjust = 0.5, vjust = 0
    ),
    strip.text.x =       element_text(
      margin = ggplot2::margin(b = base_size / 3)
    ),
    strip.text.y =       element_text(
      angle = -90, margin = ggplot2::margin(l = base_size / 3)
    ),
    strip.text.y.left =  element_text(angle = 90),
    strip.placement =    "inside",
    strip.placement.x =  NULL,
    strip.placement.y =  NULL,
    strip.switch.pad.grid = unit(base_size / 4, "pt"),
    strip.switch.pad.wrap = unit(base_size / 4, "pt"),

    # Plot
    plot.background =    element_rect(fill = colours["pageBackgroundColor"],
                                       colour = NA),
    plot.title =         element_text(size = rel(1.2), hjust = 0.5, vjust = 1,
                                       margin = ggplot2::margin(b = base_size)),
    plot.title.position = "panel",
    plot.subtitle =      element_text(hjust = 0.5, vjust = 1,
                                       margin = ggplot2::margin(b = base_size / 2)),
    plot.caption =       element_text(size = rel(0.8), hjust = 1, vjust = 1,
                                       margin = ggplot2::margin(t = base_size / 2)),
    plot.caption.position = "panel",
    plot.tag =           element_text(size = rel(1.2), hjust = 0.5, vjust = 0.5),
    plot.tag.position =  "topleft",
    plot.margin =        plot.margin,
    complete = TRUE
  )

  # Remove deprecated legend alignment elements if not supported
  if (!"legend.text.align" %in% rlang::fn_fmls_names(theme)) {
    thm$legend.text.align  <- NULL
    thm$legend.title.align <- NULL
  }

  thm
}


#' Kaplan-Meier Plot Theme
#'
#' A preset theme for Kaplan-Meier survival plots with larger base size (20)
#' and bold legend text.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' p + theme_km
#' }
#'
#' @export
#' @family ggplot2 themes
theme_km <- NULL

#' RCS (Restricted Cubic Spline) Plot Theme
#'
#' Preset theme for Restricted Cubic Spline plots (Cox HR / Logistic OR /
#' Poisson rate vs. a continuous exposure). Built from [theme_my()] with
#' thinner rectangle / line linewidths matching the FeatureAnalysis source
#' convention (`base_rect_size = 0.6, base_line_size = 0.8`), minor grid
#' lines removed, and bold left-aligned legend text.
#'
#' Used as `+ theme_rcs` (no parentheses) -- it is a pre-built ggplot2 theme
#' object, populated lazily on package load.
#'
#' @examples
#' \dontrun{
#'   library(ggplot2)
#'   ggplot(mtcars, aes(mpg, disp)) + geom_point() + theme_rcs
#' }
#'
#' @export
#' @family ggplot2 themes
theme_rcs <- NULL

#' Scatter / Feature Plot Theme
#'
#' A clean theme aligned with scMMR's PlotScatter, PlotDynamicFeatures, and
#' FeaturePlot3. Based on \code{theme_bw()} with: title 14pt bold centered,
#' axis title 12pt, axis text 10pt black, strip text 10pt, legend title 11pt
#' bold, no minor grid lines.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' p + theme_scatter
#' }
#'
#' @export
#' @family ggplot2 themes
theme_scatter <- NULL

# Build the preset theme objects on package load
.onLoad_theme <- function() {
  km <- theme_my(base_rect_size = 1.5, base_size = 20) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      legend.title = element_text(hjust = 0),
      legend.text = element_text(hjust = 0, face = "bold")
    )

  # Thinner border + slightly thinner axis lines, matching the
  # FeatureAnalysis source RCS convention (base_rect_size = 0.6,
  # base_line_size = 0.8). Larger values made the panel look chunky.
  rcs <- theme_my(base_size      = 15,
                  base_rect_size = 0.6,
                  base_line_size = 0.8) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      legend.title     = element_text(hjust = 0),
      legend.text      = element_text(hjust = 0, face = "bold")
    )

  scatter <- ggplot2::theme_bw() %+replace%
    ggplot2::theme(
      plot.title       = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title       = ggplot2::element_text(size = 12),
      axis.text        = ggplot2::element_text(size = 10, color = "black"),
      strip.text       = ggplot2::element_text(size = 10),
      panel.grid.minor = ggplot2::element_blank(),
      legend.title     = ggplot2::element_text(face = "bold", size = 11),
      legend.text      = ggplot2::element_text(size = 10)
    )

  assign("theme_km", km, envir = asNamespace("UtilsR"))
  assign("theme_rcs", rcs, envir = asNamespace("UtilsR"))
  assign("theme_scatter", scatter, envir = asNamespace("UtilsR"))
}


#' Compact Legend Theme
#'
#' A minimal legend style with white background, small text, and reduced spacing.
#' Useful for plots where the legend should not dominate the layout.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() +
#'   theme_legend1()
#'
#' @export
#' @family ggplot2 themes
theme_legend1 <- function() {
  ggplot2::theme(
    legend.background = ggplot2::element_rect(fill = "white", colour = "grey", linewidth = 0.8),
    legend.key = ggplot2::element_rect(fill = "white", colour = "grey", linewidth = 0.8),
    legend.key.size = grid::unit(1, "lines"),
    legend.text = ggplot2::element_text(size = 8),
    legend.title = ggplot2::element_text(size = 9, face = "bold"),
    legend.box.spacing = grid::unit(0.2, "cm")
  )
}


#' Customizable Legend Theme
#'
#' A flexible legend theme with sensible defaults. All parameters can be
#' overridden. [theme_legend1()] is a convenience wrapper with fixed compact
#' styling; use \code{theme_legend()} when you need fine-grained control.
#'
#' @param bg_fill Background fill color. Default \code{"white"}.
#' @param bg_color Background border color. Default \code{"grey"}.
#' @param bg_linewidth Background border width. Default \code{0.8}.
#' @param key_fill Key background fill. Default \code{"white"}.
#' @param key_color Key border color. Default \code{NA} (no border).
#' @param key_linewidth Key border width. Default \code{0.5}.
#' @param key_size Key size in lines. Default \code{1}.
#' @param text_size Legend text size. Default \code{9}.
#' @param text_color Legend text color. Default \code{"black"}.
#' @param text_face Legend text font face. Default \code{"plain"}.
#' @param title_size Legend title size. Default \code{10}.
#' @param title_color Legend title color. Default \code{"black"}.
#' @param title_face Legend title font face. Default \code{"bold"}.
#' @param show_title Logical. Show legend title? Default \code{TRUE}.
#'   If \code{FALSE}, title is set to \code{element_blank()}.
#' @param spacing Spacing between legend and plot in cm. Default \code{0.2}.
#' @param margin Margin around legend content (top, right, bottom, left) in pt.
#'   Default \code{c(4, 4, 4, 4)}.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point()
#'
#' # Default
#' p + theme_legend()
#'
#' # No border, larger text
#' p + theme_legend(bg_color = NA, text_size = 11, title_size = 13)
#'
#' # No title, no background border
#' p + theme_legend(show_title = FALSE, bg_color = NA)
#'
#' # Transparent background
#' p + theme_legend(bg_fill = "transparent", bg_color = NA)
#'
#' @export
#' @family ggplot2 themes
theme_legend <- function(bg_fill = "white",
                         bg_color = "grey",
                         bg_linewidth = 0.8,
                         key_fill = "white",
                         key_color = NA,
                         key_linewidth = 0.5,
                         key_size = 1,
                         text_size = 9,
                         text_color = "black",
                         text_face = "plain",
                         title_size = 10,
                         title_color = "black",
                         title_face = "bold",
                         show_title = TRUE,
                         spacing = 0.2,
                         margin = c(4, 4, 4, 4)) {

  title_el <- if (show_title) {
    ggplot2::element_text(size = title_size, colour = title_color, face = title_face)
  } else {
    ggplot2::element_blank()
  }

  ggplot2::theme(
    legend.background = ggplot2::element_rect(
      fill = bg_fill, colour = bg_color, linewidth = bg_linewidth),
    legend.key = ggplot2::element_rect(
      fill = key_fill, colour = key_color, linewidth = key_linewidth),
    legend.key.size = grid::unit(key_size, "lines"),
    legend.text = ggplot2::element_text(
      size = text_size, colour = text_color, face = text_face),
    legend.title = title_el,
    legend.box.spacing = grid::unit(spacing, "cm"),
    legend.margin = ggplot2::margin(margin[1], margin[2], margin[3], margin[4])
  )
}


#' Quick Legend Theme (with title)
#'
#' Shorthand for [theme_legend1()]. Compact legend with white background,
#' grey border, small text, and bold title.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() + leg1()
#'
#' @export
#' @family ggplot2 themes
leg1 <- function() theme_legend1()


#' Quick Legend Theme (no title)
#'
#' Identical to [leg1()] / [theme_legend1()] but with legend title removed.
#' White background, grey border, small text, no title.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() + leg2()
#'
#' @export
#' @family ggplot2 themes
leg2 <- function() {
  ggplot2::theme(
    legend.background = ggplot2::element_rect(fill = "white", colour = "grey", linewidth = 0.8),
    legend.key = ggplot2::element_rect(fill = "white", colour = "grey", linewidth = 0.8),
    legend.key.size = grid::unit(1, "lines"),
    legend.text = ggplot2::element_text(size = 8),
    legend.title = ggplot2::element_blank(),
    legend.box.spacing = grid::unit(0.2, "cm")
  )
}


#' Alluvial / Sankey Plot Theme
#'
#' A clean theme for alluvial and sankey plots. Based on
#' \code{thisplot::theme_alluvial()}, removes panel border, grid lines,
#' axis lines, and x-axis ticks for a minimal look.
#'
#' @param base_size Numeric. Base font size. Default 14.
#' @param base_family Character. Base font family. Default \code{""}.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#' p + theme_alluvia()
#'
#' @export
#' @family ggplot2 themes
theme_alluvia <- function(base_size = 14, base_family = "") {
  ggplot2::theme_bw(
    base_size = base_size, base_family = base_family,
    base_line_size = base_size / 22,
    base_rect_size = base_size / 22
  ) %+replace%
    ggplot2::theme(
      panel.border     = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.line        = ggplot2::element_blank(),
      axis.line.x      = ggplot2::element_blank(),
      axis.ticks.x     = ggplot2::element_blank(),
      axis.text.x      = ggplot2::element_text(
        size = base_size, face = "bold", color = "black"),
      axis.title.x     = ggplot2::element_blank(),
      axis.title.y     = ggplot2::element_blank(),
      legend.key       = ggplot2::element_blank(),
      legend.title     = ggplot2::element_blank(),
      strip.background = ggplot2::element_rect(
        fill = "white", colour = "transparent",
        linewidth = ggplot2::rel(2)),
      complete = TRUE
    )
}


# ============================================================================
# theme_sc / theme_blank -- Ported from thisplot (scop ecosystem)
# ============================================================================

#' Single-Cell Style Theme
#'
#' A clean ggplot2 theme designed for single-cell analysis plots. Based on
#' \code{thisplot::theme_this} from the scop ecosystem, renamed to
#' \code{theme_sc}.
#'
#' @param aspect.ratio Aspect ratio of the panel. Default is \code{NULL}.
#' @param base_size Numeric. Base font size (default 12).
#' @param ... Arguments passed to \code{\link[ggplot2]{theme}}.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
#'   geom_point()
#' p + theme_sc()
#'
#' @export
#' @family ggplot2 themes
theme_sc <- function(
    aspect.ratio = NULL,
    base_size = 12,
    ...) {
  text_size_scale <- base_size / 12
  args1 <- list(
    aspect.ratio = aspect.ratio,
    text = element_text(
      size = 12 * text_size_scale,
      color = "black"
    ),
    plot.title = element_text(
      size = 14 * text_size_scale,
      colour = "black", vjust = 1
    ),
    plot.subtitle = element_text(
      size = 13 * text_size_scale,
      hjust = 0,
      margin = margin(b = 3)
    ),
    plot.background = element_rect(
      fill = "white",
      color = "white"
    ),
    axis.line = element_blank(),
    axis.title = element_text(
      size = 13 * text_size_scale,
      colour = "black"
    ),
    axis.text = element_text(
      size = 12 * text_size_scale,
      colour = "black"
    ),
    strip.text = element_text(
      size = 12.5 * text_size_scale,
      colour = "black",
      hjust = 0.5,
      margin = margin(3, 3, 3, 3)
    ),
    strip.background = element_rect(
      fill = "transparent", linetype = 0
    ),
    strip.switch.pad.grid = grid::unit(-1, "pt"),
    strip.switch.pad.wrap = grid::unit(-1, "pt"),
    strip.placement = "outside",
    legend.title = element_text(
      size = 12 * text_size_scale,
      colour = "black",
      hjust = 0
    ),
    legend.text = element_text(
      size = 11 * text_size_scale,
      colour = "black"
    ),
    legend.key = element_rect(
      fill = "transparent",
      color = "transparent"
    ),
    legend.key.size = grid::unit(10, "pt"),
    legend.background = element_blank(),
    panel.background = element_rect(
      fill = "white",
      color = "white"
    ),
    panel.border = element_rect(
      fill = "transparent",
      colour = "black",
      linewidth = 1
    )
  )
  args2 <- as.list(match.call())[-1]
  call_envir <- parent.frame(1)
  args2 <- lapply(args2, function(arg) {
    if (is.symbol(arg)) {
      eval(arg, envir = call_envir)
    } else if (is.call(arg)) {
      eval(arg, envir = call_envir)
    } else {
      arg
    }
  })
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% methods::formalArgs(theme)]
  out <- do.call(what = theme, args = args)
  return(out)
}


#' Blank Theme with Coordinate Arrows
#'
#' A minimalist ggplot2 theme that removes all panel elements and optionally
#' adds coordinate arrows in the bottom-left corner. Ideal for UMAP / t-SNE
#' embedding plots. Ported from \code{thisplot::theme_blank}.
#'
#' @param add_coord Logical. Whether to add coordinate arrows. Default is
#'   \code{TRUE}.
#' @param xlen_npc Numeric. Length of the x-axis arrow in "npc" units.
#' @param ylen_npc Numeric. Length of the y-axis arrow in "npc" units.
#' @param xlab Character. Label for the x-axis arrow.
#' @param ylab Character. Label for the y-axis arrow.
#' @param lab_size Numeric. Font size of the axis labels.
#' @param ... Arguments passed to \code{\link[ggplot2]{theme}}.
#'
#' @return A list of ggplot2 theme and annotation objects that can be added
#'   to a ggplot with \code{+}.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
#'   geom_point()
#' p + theme_blank()
#' p + theme_blank(xlab = "UMAP1", ylab = "UMAP2", lab_size = 14)
#'
#' @export
#' @family ggplot2 themes
theme_blank <- function(
    add_coord = TRUE,
    xlen_npc = 0.15,
    ylen_npc = 0.15,
    xlab = "",
    ylab = "",
    lab_size = 12,
    ...) {
  args1 <- list(
    panel.border = element_blank(),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    legend.background = element_blank(),
    legend.box.margin = margin(0, 0, 0, 0),
    legend.margin = margin(0, 0, 0, 0),
    legend.key.size = grid::unit(10, "pt"),
    plot.margin = margin(
      lab_size + 2, lab_size + 2, lab_size + 2, lab_size + 2,
      unit = "points"
    )
  )
  args2 <- as.list(match.call())[-1]
  call_envir <- parent.frame(1)
  args2 <- lapply(args2, function(arg) {
    if (is.symbol(arg)) {
      eval(arg, envir = call_envir)
    } else if (is.call(arg)) {
      eval(arg, envir = call_envir)
    } else {
      arg
    }
  })
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% methods::formalArgs(theme)]
  out <- do.call(what = theme, args = args)
  if (isTRUE(add_coord)) {
    g <- grid::grobTree(
      grid::gList(
        grid::linesGrob(
          x = grid::unit(c(0, xlen_npc), "npc"),
          y = grid::unit(c(0, 0), "npc"),
          arrow = grid::arrow(length = grid::unit(0.02, "npc")),
          gp = grid::gpar(lwd = 2)
        ),
        grid::textGrob(
          label = xlab,
          x = grid::unit(0, "npc"),
          y = grid::unit(0, "npc"),
          vjust = 4 / 3,
          hjust = 0,
          gp = grid::gpar(fontsize = lab_size)
        ),
        grid::linesGrob(
          x = grid::unit(c(0, 0), "npc"),
          y = grid::unit(c(0, ylen_npc), "npc"),
          arrow = grid::arrow(length = grid::unit(0.02, "npc")),
          gp = grid::gpar(lwd = 2)
        ),
        grid::textGrob(
          label = ylab,
          x = grid::unit(0, "npc"),
          y = grid::unit(0, "npc"),
          vjust = -2 / 3,
          hjust = 0,
          rot = 90,
          gp = grid::gpar(fontsize = lab_size)
        )
      )
    )
    return(list(
      list(ggplot2::annotation_custom(g)),
      list(theme_sc() + out),
      list(ggplot2::coord_cartesian(clip = "off"))
    ))
  } else {
    return(list(
      list(theme_sc() + out)
    ))
  }
}


#' ROC / Calibration Plot Theme
#'
#' A clean ggplot2 theme designed for ROC curves, calibration plots, and similar
#' diagnostic plots. Based on \code{theme_classic} with bold axis text, centred
#' titles, and a compact legend positioned inside the panel.
#'
#' @param base_size Numeric. Base font size (default 11).
#' @param axis_text_size Numeric. Axis tick-label size (default 13).
#' @param axis_title_size Numeric. Axis title size (default 14).
#' @param title_size Numeric. Plot title size (default 16).
#' @param subtitle_size Numeric. Subtitle size (default 9).
#' @param strip_size Numeric. Facet strip text size (default 12).
#' @param legend_text_size Numeric. Legend text size (default 9).
#' @param legend_title_size Numeric. Legend title size (default 8).
#' @param legend.position Legend position. Default \code{c(0.8, 0.3)} (inside
#'   panel). Use \code{"right"}, \code{"bottom"}, etc. for outside placement.
#' @param axis_linewidth Numeric. Axis line and tick width (default 0.8).
#' @param plot_margin Margin around the plot in pt. Default
#'   \code{margin(10, 10, 10, 10)}.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' library(ggplot2)
#'
#' # Basic ROC-style plot
#' set.seed(1)
#' df <- data.frame(FPR = seq(0, 1, length.out = 100),
#'                  TPR = sort(runif(100))^0.5)
#' ggplot(df, aes(FPR, TPR)) +
#'   geom_line(color = "steelblue", linewidth = 1) +
#'   geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
#'   coord_equal() +
#'   theme_ROC()
#'
#' # Customise legend position
#' ggplot(df, aes(FPR, TPR)) +
#'   geom_line() +
#'   theme_ROC(legend.position = "right")
#'
#' @export
#' @family ggplot2 themes
theme_ROC <- function(
    base_size         = 11,
    axis_text_size    = 13,
    axis_title_size   = 14,
    title_size        = 16,
    subtitle_size     = 9,
    strip_size        = 12,
    legend_text_size  = 9,
    legend_title_size = 8,
    legend.position   = c(0.8, 0.3),
    axis_linewidth    = 0.8,
    plot_margin       = ggplot2::margin(10, 10, 10, 10)
) {
  ggplot2::theme_classic(base_size = base_size) +
    ggplot2::theme(
      # Axis
      axis.text   = ggplot2::element_text(
        color = "black", size = axis_text_size, face = "bold"),
      axis.title  = ggplot2::element_text(
        color = "black", size = axis_title_size, face = "bold"),
      axis.line   = ggplot2::element_line(
        linewidth = axis_linewidth, color = "black"),
      axis.ticks  = ggplot2::element_line(
        linewidth = axis_linewidth, color = "black"),
      # Title / subtitle
      plot.title    = ggplot2::element_text(
        hjust = 0.5, size = title_size, face = "bold"),
      plot.subtitle = ggplot2::element_text(
        hjust = 0.5, size = subtitle_size, color = "grey40"),
      # Legend
      legend.text  = ggplot2::element_text(size = legend_text_size),
      legend.title = ggplot2::element_text(size = legend_title_size),
      legend.position = legend.position,
      # Strip (facet labels)
      strip.text = ggplot2::element_text(
        size = strip_size, face = "bold"),
      # Margin
      plot.margin = plot_margin
    )
}
