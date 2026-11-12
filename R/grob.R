# =============================================================================
# grob.R -- Grob conversion, layout, and inset utilities
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  grob_as(plot, ...)                          -- public API
#             ggplot | patchwork | gtable | gList -> gtable / grob
#   L1  grob_add(gtable, grob, ...)      place a grob at a gtable cell
#   L1  grob_insert(plot, inset, ...)    inset one plot inside another
#   L1  grob_to_gg(grob, ...)            grob / gtable -> ggplot object
#
#   L2  grob_add / grob_insert / grob_to_gg normalise their input through
#       grob_as() first, so all four entry points accept the same types.
# =============================================================================

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
#' @param ... Currently unused; reserved for future extensions.
#'
#' @return A grob or gtable object, or \code{NULL} with a warning if conversion
#'   is not supported.
#'
#' @details
#' Patchwork objects are converted with \code{patchwork::patchworkGrob()},
#' preserving the complete layout, annotations, and collected guides.
#'
#' Standalone patchwork wrappers created by \code{patchwork::wrap_elements()}
#' or \code{patchwork::wrap_ggplot_grob()} retain their wrapped graphics.
#'
#' When no graphics device is open, conversion uses a temporary null PDF
#' device that is closed before returning. An already open device is reused.
#'
#' @examples
#' library(ggplot2)
#' data <- data.frame(x = 1:6, y = c(2, 4, 1, 6, 3, 5))
#' p <- ggplot(data, aes(x, y)) + geom_point()
#' g <- grob_as(p)
#' class(g)
#' combined <- patchwork::wrap_plots(p, p, ncol = 2) +
#'   patchwork::plot_annotation(title = "Combined plots")
#' grid::grid.draw(grob_as(combined))
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
  if (inherits(plot, c("patchwork", "ggplot")) && grDevices::dev.cur() == 1L) {
    grDevices::pdf(NULL)
    null_device <- grDevices::dev.cur()
    on.exit({
      if (null_device %in% grDevices::dev.list()) grDevices::dev.off(null_device)
    }, add = TRUE)
  }
  if (inherits(plot, "patchwork") ||
      (inherits(plot, "ggplot") && inherits(plot, "patch"))) {
    if (requireNamespace("patchwork", quietly = TRUE)) {
      if (!inherits(plot, "patchwork")) plot <- patchwork::wrap_plots(plot)
      return(patchwork::patchworkGrob(plot))
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
#' @param grob A grob, gtable, gList, ggplot, or patchwork object to add.
#' @param position Where to place the grob. One of \code{"top"},
#'   \code{"bottom"}, \code{"left"}, \code{"right"}, or \code{"none"}.
#' @param space Space to allocate for the added grob. If \code{NULL}
#'   (default), calculated automatically from the grob dimensions.
#' @param clip Clipping mode. Default is \code{"on"}.
#'
#' @return A gtable object with the grob added at the specified position.
#'
#' @details
#' Top and bottom additions span the full width of the panel area; left and
#' right additions span its full height, including all facets. The main gtable
#' must contain a panel area unless \code{position = "none"} or \code{grob}
#' is \code{NULL}.
#'
#' Successive additions remain aligned to the main panel area.
#'
#' Standard panel names (\code{"panel"} and numeric suffixes) and
#' \code{"panel-area"} are preferred. For custom gtables without these names,
#' names containing \code{"panel"} are used.
#'
#' Fixed aspect ratio constraints in the main gtable are retained when margin
#' rows or columns are added.
#'
#' @examples
#' library(ggplot2)
#' data <- data.frame(x = 1:12, y = rep(c(2, 4, 1, 6, 3, 5), 2),
#'                    group = rep(c("A", "B"), each = 6))
#' main <- ggplot(data, aes(x, y)) + geom_point() + facet_wrap(~group)
#' side <- ggplot(data, aes(x)) + geom_density()
#' gt <- grob_add(main, grob_as(side), position = "top")
#' grid::grid.draw(gt)
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
  if (position != "none" && !is.null(grob)) {
    if (!grid::is.grob(grob) && !inherits(grob, c("ggplot", "patchwork", "gList")) &&
        !(is.list(grob) && all(vapply(grob, grid::is.grob, logical(1)))))
      stop("'grob' must be a graphic or a list of grobs.", call. = FALSE)
    if (!is.character(clip) || !is.null(dim(clip)) || length(clip) != 1L ||
        is.na(clip) || !clip %in% c("on", "off", "inherit"))
      stop("'clip' must be one of 'on', 'off' or 'inherit'.", call. = FALSE)
    if (!is.null(space) && (!grid::is.unit(space) ||
        (inherits(space, "simpleUnit") && any(!is.finite(as.numeric(space))))))
      stop("'space' must be NULL or a finite grid unit.", call. = FALSE)
  }

  if (!requireNamespace("gtable", quietly = TRUE)) {
    stop("Package 'gtable' is required for grob_add().", call. = FALSE)
  }

  # Convert main plot to gtable
  gt <- grob_as(plot)
  if (!inherits(gt, "gtable")) {
    stop("Failed to convert 'plot' to a gtable.", call. = FALSE)
  }

  if (position == "none" || is.null(grob) || (is.list(grob) && !grid::is.grob(grob) && !length(grob))) {
    return(gt)
  }

  if (inherits(grob, c("ggplot", "patchwork"))) {
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
    } else if (is.list(grob)) {
      measure <- if (position %in% c("top", "bottom")) grid::grobHeight else grid::grobWidth
      sizes <- lapply(grob, measure)
      space <- if (length(sizes)) do.call(grid::unit.pmax, sizes) else grid::unit(0, "cm")
    }
  }

  # Keep the measured children together in one layout cell.
  if (inherits(grob, "gList")) grob <- grob_as(grob)

  panel_index <- grepl("^panel(-[0-9]+)*$", gt$layout$name) |
    gt$layout$name %in% "panel-area"
  if (!any(panel_index)) panel_index <- grepl("panel", gt$layout$name)
  panel_layout <- gt$layout[panel_index, , drop = FALSE]
  if (nrow(panel_layout) == 0L) {
    stop("Cannot find the panel area in 'plot'.", call. = FALSE)
  }
  panel_rows <- range(panel_layout$t, panel_layout$b)
  panel_cols <- range(panel_layout$l, panel_layout$r)

  cells <- length(space)
  if (position == "top") {
    gt <- gtable::gtable_add_rows(gt, space, 0)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = 1,
      b = cells,
      l = panel_cols[1],
      r = panel_cols[2],
      clip = clip,
      name = "grob_add_top"
    )
  }
  if (position == "bottom") {
    gt <- gtable::gtable_add_rows(gt, space, -1)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = nrow(gt) - cells + 1L,
      b = nrow(gt),
      l = panel_cols[1],
      r = panel_cols[2],
      clip = clip,
      name = "grob_add_bottom"
    )
  }
  if (position == "left") {
    gt <- gtable::gtable_add_cols(gt, space, 0)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = panel_rows[1],
      b = panel_rows[2],
      l = 1,
      r = cells,
      clip = clip,
      name = "grob_add_left"
    )
  }
  if (position == "right") {
    gt <- gtable::gtable_add_cols(gt, space, -1)
    gt <- gtable::gtable_add_grob(
      gt, grob,
      t = panel_rows[1],
      b = panel_rows[2],
      l = ncol(gt) - cells + 1L,
      r = ncol(gt),
      clip = clip,
      name = "grob_add_right"
    )
  }
  if (is.matrix(gt$respect)) {
    respect <- gt$respect
    row_offset <- if (position == "top") nrow(gt) - nrow(respect) else 0L
    col_offset <- if (position == "left") ncol(gt) - ncol(respect) else 0L
    gt$respect <- matrix(0, nrow = nrow(gt), ncol = ncol(gt))
    gt$respect[seq_len(nrow(respect)) + row_offset,
               seq_len(ncol(respect)) + col_offset] <- respect
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
#' @param plot A \code{ggplot}, \code{patchwork}, or \code{gtable} object
#'   serving as the main plot.
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
#' With \code{align_to = "panel"}, the reference area spans all panels,
#' including facets. Standard names (\code{"panel"}, \code{"panel-1"},
#' \code{"panel-1-1"}, and other numeric suffixes) and patchwork's
#' \code{"panel-area"} take precedence over annotation names containing
#' \code{"panel"}. If no standard panel names exist, names containing
#' \code{"panel"} are used as a fallback for custom gtables. An error is
#' raised when neither kind is present; \code{align_to = "plot"} and
#' \code{align_to = "full"} do not require panels.
#'
#' @examples
#' library(ggplot2)
#' data <- data.frame(x = 1:12, y = rep(c(2, 4, 1, 6, 3, 5), 2),
#'                    group = rep(c("A", "B"), each = 6))
#' main <- ggplot(data, aes(x, y)) + geom_point() + facet_wrap(~group)
#' inset <- ggplot(data, aes(group)) + geom_bar() +
#'   theme_void() + theme(plot.background = element_rect(fill = "white"))
#' gt <- grob_insert(main, inset,
#'   left = 0.6, bottom = 0.6, right = 1, top = 1
#' )
#' grid::grid.draw(gt)
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

  coordinates <- list(left = left, bottom = bottom, right = right, top = top)
  for (arg in names(coordinates)) {
    value <- coordinates[[arg]]
    .register_integer64(value)
    if (!(is.numeric(value) || inherits(value, "unit")) ||
        length(value) != 1L || !is.null(dim(value)) ||
        !is.finite(as.numeric(value))) {
      stop("'", arg, "' must be a finite numeric scalar or a scalar grid unit.",
           call. = FALSE)
    }
  }
  flags <- list(on_top = on_top, clip = clip)
  for (arg in names(flags)) {
    value <- flags[[arg]]
    if (!is.logical(value) || length(value) != 1L ||
        !is.null(dim(value)) || is.na(value)) {
      stop("'", arg, "' must be TRUE or FALSE.", call. = FALSE)
    }
  }

  if (!grid::is.grob(inset) && !inherits(inset, c("ggplot", "patchwork", "gList")))
    stop("'inset' must be a grob, gList or plot object.", call. = FALSE)
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
    # Prefer standard panel names to avoid matching annotation names.
    panel_index <- grepl("^panel(-[0-9]+)*$", gt$layout$name) |
      gt$layout$name %in% "panel-area"
    if (!any(panel_index)) panel_index <- grepl("panel", gt$layout$name)
    panel_layout <- gt$layout[panel_index, , drop = FALSE]
    if (nrow(panel_layout) == 0L) {
      stop("Cannot find the panel area in 'plot'.", call. = FALSE)
    }
    ref_t <- min(panel_layout$t)
    ref_b <- max(panel_layout$b)
    ref_l <- min(panel_layout$l)
    ref_r <- max(panel_layout$r)
  } else if (align_to == "plot") {
    # Use the entire gtable minus the outer margins
    background <- match("background", gt$layout$name)
    if (!is.na(background)) {
      ref_t <- gt$layout$t[background]
      ref_b <- gt$layout$b[background]
      ref_l <- gt$layout$l[background]
      ref_r <- gt$layout$r[background]
      if (inherits(plot, "ggplot") && !inherits(plot, "patchwork") &&
          ref_t == 1L && ref_b == nrow(gt) && ref_l == 1L && ref_r == ncol(gt)) {
        ref_t <- ref_t + 1L
        ref_b <- ref_b - 1L
        ref_l <- ref_l + 1L
        ref_r <- ref_r - 1L
      }
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
    just = c("left", "bottom"),
    clip = clip_mode
  )

  # Wrap the inset grob in the viewport
  inset_wrapped <- grid::grobTree(inset_grob, vp = inset_vp)

  # Add to gtable: z-order depends on on_top
  z_val <- Inf
  if (!on_top) {
    layout <- gt$layout
    overlaps <- layout$t <= ref_b & layout$b >= ref_t &
      layout$l <= ref_r & layout$r >= ref_l
    background <- layout$name == "background"
    lowest <- min(Inf, layout$z[overlaps & !background], na.rm = TRUE)
    backgrounds <- layout$z[overlaps & background & layout$z < lowest]
    z_val <- max(min(0, lowest - 1), backgrounds, na.rm = TRUE)
  }

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

  # Keep the original plot and its analysis environment out of the wrapper.
  eval(quote(ggplot2::ggplot() + ggplot2::annotation_custom(g) +
               ggplot2::theme_void()),
       envir = list2env(list(g = g), parent = baseenv()))
}
