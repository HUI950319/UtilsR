# ============================================================================
# grob.R -- Grob conversion, layout, and inset utilities
# ============================================================================

#' @import ggplot2
#' @importFrom grid unit grobTree gList linesGrob textGrob gpar grobHeight grobWidth is.grob
NULL

# ----------------------------------------------------------------------------
# grob_as: Convert plot objects to grob
# ----------------------------------------------------------------------------

#' Convert a Plot Object to a Grob
#'
#' Convert various plot objects (ggplot, patchwork, gList, gtable) to a grob
#' (grid graphical object). This is a unified dispatcher that handles different
#' input types automatically.
#'
#' @param plot A plot object. Supported types: \code{gtable}, \code{grob},
#'   \code{gList}, \code{patchwork}, or \code{ggplot}.
#' @param ... Additional arguments passed to conversion functions.
#'
#' @return A grob or gtable object, or \code{NULL} with a warning if conversion
#'   is not supported.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
#' g <- grob_as(p)
#' class(g)
#'
#' @export
#' @family grob utilities
grob_as <- function(plot, ...) {
  if (inherits(plot, "gtable")) {
    return(plot)
  }
  if (inherits(plot, "gList")) {
    return(grid::grobTree(plot))
  }
  if (inherits(plot, "patchwork")) {
    if (requireNamespace("patchwork", quietly = TRUE)) {
      return(ggplot2::ggplotGrob(plot))
    } else {
      warning(
        "Package 'patchwork' is needed to convert patchwork objects.",
        call. = FALSE
      )
      return(NULL)
    }
  }
  if (inherits(plot, "ggplot")) {
    return(ggplot2::ggplotGrob(plot))
  }
  if (grid::is.grob(plot)) {
    return(plot)
  }
  warning(
    "Cannot convert object of class '", paste(class(plot), collapse = "/"),
    "' into a grob.",
    call. = FALSE
  )
  NULL
}


# ----------------------------------------------------------------------------
# grob_add: Add a grob to a gtable at top/bottom/left/right
# ----------------------------------------------------------------------------

#' Add a Grob to a Gtable at a Specified Position
#'
#' Add a grob or gtable to the margin of an existing gtable, aligned to the
#' panel area. Useful for appending side plots (e.g., density plots, bar charts)
#' around a main plot panel.
#'
#' @param plot A \code{ggplot}, \code{patchwork}, or \code{gtable} object to
#'   serve as the main plot.
#' @param grob A grob, gtable, or ggplot object to add.
#' @param position Where to place the grob. One of \code{"top"},
#'   \code{"bottom"}, \code{"left"}, \code{"right"}, or \code{"none"}.
#' @param space Space to allocate for the added grob. If \code{NULL}
#'   (default), calculated automatically from the grob dimensions.
#' @param clip Clipping mode. Default is \code{"on"}.
#'
#' @return A gtable object with the grob added at the specified position.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' main <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
#' side <- ggplot(mtcars, aes(x = wt)) + geom_density()
#' gt <- grob_add(main, grob_as(side), position = "top")
#' grid::grid.draw(gt)
#' }
#'
#' @export
#' @family grob utilities
grob_add <- function(
    plot,
    grob,
    position = c("top", "bottom", "left", "right", "none"),
    space = NULL,
    clip = "on") {
  position <- match.arg(position)

  if (!requireNamespace("gtable", quietly = TRUE)) {
    stop("Package 'gtable' is required for grob_add().", call. = FALSE)
  }

  # Convert main plot to gtable
  gt <- grob_as(plot)
  if (!inherits(gt, "gtable")) {
    stop("Failed to convert 'plot' to a gtable.", call. = FALSE)
  }

  if (position == "none" || is.null(grob)) {
    return(gt)
  }

  # Convert grob input if it's a ggplot
  if (inherits(grob, "ggplot") || inherits(grob, "patchwork")) {
    grob <- grob_as(grob)
  }

  # Auto-calculate space
  if (is.null(space)) {
    if (gtable::is.gtable(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- sum(grob$heights)
      } else {
        space <- sum(grob$widths)
      }
    } else if (grid::is.grob(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- grid::grobHeight(grob)
      } else {
        space <- grid::grobWidth(grob)
      }
    }
  }

  panel_rows <- gt$layout[grepl("panel", gt$layout$name), "t"]
  panel_cols <- gt$layout[grepl("panel", gt$layout$name), "l"]

  if (position == "top") {
    gt <- gtable::gtable_add_rows(gt, space, 0)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = 1,
      l = mean(panel_cols),
      clip = clip
    )
  }
  if (position == "bottom") {
    gt <- gtable::gtable_add_rows(gt, space, -1)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = dim(gt)[1],
      l = mean(panel_cols),
      clip = clip
    )
  }
  if (position == "left") {
    gt <- gtable::gtable_add_cols(gt, space, 0)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = mean(panel_rows),
      l = 1,
      clip = clip
    )
  }
  if (position == "right") {
    gt <- gtable::gtable_add_cols(gt, space, -1)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = mean(panel_rows),
      l = dim(gt)[2],
      clip = clip
    )
  }
  return(gt)
}


# ----------------------------------------------------------------------------
# grob_insert: Insert an inset plot inside another plot's panel
# ----------------------------------------------------------------------------

#' Insert an Inset Plot Inside Another Plot
#'
#' Place a smaller plot (inset) at a specified position within the panel area
#' of a main plot, similar to \code{patchwork::inset_element()}. Coordinates
#' use normalized panel coordinates (0-1) by default.
#'
#' @param plot A \code{ggplot} or \code{patchwork} object serving as the main
#'   plot.
#' @param inset A \code{ggplot}, \code{grob}, or other plot object to insert.
#' @param left Left boundary of the inset (0 = panel left edge, 1 = right
#'   edge). Default is \code{0.6}.
#' @param bottom Bottom boundary of the inset (0 = panel bottom, 1 = top).
#'   Default is \code{0.6}.
#' @param right Right boundary of the inset. Default is \code{1}.
#' @param top Top boundary of the inset. Default is \code{1}.
#' @param align_to Reference area for positioning. One of \code{"panel"}
#'   (default), \code{"plot"}, or \code{"full"}.
#' @param on_top Logical. Whether the inset is drawn on top of the main plot.
#'   Default is \code{TRUE}.
#' @param clip Logical. Whether to clip the inset to the specified boundaries.
#'   Default is \code{TRUE}.
#'
#' @return A gtable object with the inset placed inside the main plot.
#'
#' @details
#' Unlike \code{patchwork::inset_element()}, this function returns a
#' ready-to-draw \code{gtable} object (use \code{grid::grid.draw()} to
#' render). It does not require patchwork and works with any grob-convertible
#' plot object.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' main <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
#' inset <- ggplot(mtcars, aes(factor(cyl))) + geom_bar() +
#'   theme_void() + theme(plot.background = element_rect(fill = "white"))
#' gt <- grob_insert(main, inset,
#'   left = 0.6, bottom = 0.6, right = 1, top = 1
#' )
#' grid::grid.draw(gt)
#' }
#'
#' @export
#' @family grob utilities
grob_insert <- function(
    plot,
    inset,
    left = 0.6,
    bottom = 0.6,
    right = 1,
    top = 1,
    align_to = c("panel", "plot", "full"),
    on_top = TRUE,
    clip = TRUE) {
  align_to <- match.arg(align_to)

  if (!requireNamespace("gtable", quietly = TRUE)) {
    stop("Package 'gtable' is required for grob_insert().", call. = FALSE)
  }

  # Convert coordinates to units
  left <- if (inherits(left, "unit")) left else grid::unit(left, "npc")
  bottom <- if (inherits(bottom, "unit")) bottom else grid::unit(bottom, "npc")
  right <- if (inherits(right, "unit")) right else grid::unit(right, "npc")
  top <- if (inherits(top, "unit")) top else grid::unit(top, "npc")

  clip_mode <- if (isTRUE(clip)) "on" else "off"

  # Convert main plot to gtable
  gt <- grob_as(plot)
  if (!inherits(gt, "gtable")) {
    stop("Failed to convert 'plot' to a gtable.", call. = FALSE)
  }

  # Convert inset to grob
  inset_grob <- grob_as(inset)
  if (is.null(inset_grob)) {
    stop("Failed to convert 'inset' to a grob.", call. = FALSE)
  }

  # Find the reference area in the gtable layout
  if (align_to == "panel") {
    panel_layout <- gt$layout[grepl("panel", gt$layout$name), , drop = FALSE]
    ref_t <- min(panel_layout$t)
    ref_b <- max(panel_layout$b)
    ref_l <- min(panel_layout$l)
    ref_r <- max(panel_layout$r)
  } else if (align_to == "plot") {
    # Use the entire gtable minus the outer margins
    bg_layout <- gt$layout[gt$layout$name == "background", , drop = FALSE]
    if (nrow(bg_layout) > 0) {
      ref_t <- bg_layout$t[1]
      ref_b <- bg_layout$b[1]
      ref_l <- bg_layout$l[1]
      ref_r <- bg_layout$r[1]
    } else {
      ref_t <- 1
      ref_b <- nrow(gt)
      ref_l <- 1
      ref_r <- ncol(gt)
    }
  } else {
    # full: the entire gtable
    ref_t <- 1
    ref_b <- nrow(gt)
    ref_l <- 1
    ref_r <- ncol(gt)
  }

  # Build the inset viewport as a grob placed in the reference area
  inset_vp <- grid::viewport(
    x = left,
    y = bottom,
    width = right - left,
    height = top - bottom,
    just = c("left", "bottom")
  )

  # Wrap the inset grob in the viewport
  inset_wrapped <- grid::grobTree(inset_grob, vp = inset_vp)

  # Add to gtable: z-order depends on on_top
  z_val <- if (isTRUE(on_top)) max(gt$layout$z) + 1L else 0L

  gt <- gtable::gtable_add_grob(
    gt, inset_wrapped,
    t = ref_t,
    b = ref_b,
    l = ref_l,
    r = ref_r,
    z = z_val,
    clip = clip_mode,
    name = "inset"
  )

  return(gt)
}


# ----------------------------------------------------------------------------
# grob_to_gg: Wrap a grob/gtable back into a ggplot object
# ----------------------------------------------------------------------------

#' Convert a Grob or Gtable Back to a ggplot Object
#'
#' Wrap a grob, gtable, or grid object into a \code{ggplot} object so that it
#' can be further manipulated with ggplot2 operators (\code{+}), saved with
#' \code{ggsave()}, or combined in \code{patchwork} layouts.
#'
#' This is the reverse operation of \code{\link{grob_as}} and is especially
#' useful after \code{\link{grob_add}} or \code{\link{grob_insert}}, which
#' return gtable objects.
#'
#' @param grob A grob, gtable, gList, or any object accepted by
#'   \code{\link{grob_as}}.
#' @param ... Currently unused; reserved for future extensions.
#'
#' @return A \code{ggplot} object that draws the grob when printed or saved.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' # Build a composite layout with grob_add
#' main <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
#' side <- ggplot(mtcars, aes(x = wt)) + geom_density()
#' gt <- grob_add(main, grob_as(side), position = "top")
#'
#' # Convert back to ggplot -- now supports ggsave, patchwork, etc.
#' p <- grob_to_gg(gt)
#' ggsave("composite.pdf", p, width = 8, height = 6)
#'
#' # Use in patchwork
#' library(patchwork)
#' p1 <- ggplot(mtcars, aes(hp, mpg)) + geom_point()
#' p1 + p  # patchwork layout
#'
#' # Inset example
#' inset_gt <- grob_insert(main, side, left = 0.6, bottom = 0.6)
#' grob_to_gg(inset_gt)
#' }
#'
#' @export
#' @family grob utilities
grob_to_gg <- function(grob, ...) {
  # Ensure it's a valid grob/gtable
  g <- grob_as(grob)
  if (is.null(g)) {
    stop("Cannot convert object to a grob.", call. = FALSE)
  }

  # Build an empty ggplot canvas and use annotation_custom to place the grob
  ggplot2::ggplot() +
    ggplot2::annotation_custom(g) +
    ggplot2::theme_void()
}
