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
theme_km <- NULL

#' RCS (Restricted Cubic Spline) Plot Theme
#'
#' A preset theme for RCS plots with base size 15 and bold legend text.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' p + theme_rcs
#' }
#'
#' @export
theme_rcs <- NULL

# Build the preset theme objects on package load
.onLoad_theme <- function() {
  km <- theme_my(base_rect_size = 1.5, base_size = 20) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      legend.title = element_text(hjust = 0),
      legend.text = element_text(hjust = 0, face = "bold")
    )

  rcs <- theme_my(base_rect_size = 1.5, base_size = 15) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      legend.title = element_text(hjust = 0),
      legend.text = element_text(hjust = 0, face = "bold")
    )

  assign("theme_km", km, envir = asNamespace("UtilsR"))
  assign("theme_rcs", rcs, envir = asNamespace("UtilsR"))
}
