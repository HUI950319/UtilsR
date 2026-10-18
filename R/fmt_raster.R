# =============================================================================
# fmt_raster.R -- Rasterize plot panels to shrink PDF output
# =============================================================================
#
# Architecture (4 layers):
#
#   L1  fmt_raster(plot, method, dpi, width, height, ...)   -- public API
#         |   method = "ggrastr" (default) | "ragg" | "image"
#         +-- L2  .fmt_raster_ggrastr()   re-wrap layers through ggrastr
#         |     +-- L3  .opaque_raster_layer()   ggrastr layer drawn opaque
#         +-- L2  .fmt_raster_ragg()      render panel grobs through ragg
#         |     +-- L3  .resolve_panel_size()     physical panel dimensions
#         |     +-- L3  .rasterize_panel_grob()   grob -> raster grob
#         |           +-- L4  .is_text_grob()     keep text grobs vector
#         +-- L2  .fmt_raster_image()     whole plot, text included -> raster
# =============================================================================

#' Rasterize Plot Panels
#'
#' Rasterize geometric layers (points, lines, polygons) in ggplot panels to
#' reduce PDF/SVG file size, while keeping text, axes, and legends as vectors.
#' The `"image"` method instead renders the whole plot, text included, into
#' one image for fast on-screen redrawing.
#'
#' Three backends are available:
#' \describe{
#'   \item{\code{"ggrastr"}}{Wraps the plot's point and tile layers (as
#'     \code{geom_point()}, \code{geom_jitter()} and \code{geom_tile()} draw)
#'     with \code{ggrastr::rasterise()}, which rasterizes them at render
#'     time, as ggrastr does by default. Other layers, such as lines, bars,
#'     polygons, text and custom annotations, and theme elements remain
#'     vectors: they are few objects, which as an image only make a PDF
#'     larger. The raster is redrawn on every render, so on screen it can be
#'     slower than the vector plot. Each raster is drawn after an empty
#'     opaque polygon, so that \code{pdf()} does not paint it with the
#'     transparency of the grob before it; a repeated call rasterizes a
#'     layer once, at the latest \code{dpi}.}
#'   \item{\code{"ragg"}}{Captures panel geometry in memory via
#'     \code{ragg::agg_capture()} and inserts it as a \code{rasterGrob}.
#'     Text/label grobs inside the panel are automatically detected and kept
#'     as vectors. Uses the specified panel dimensions or the current device's
#'     grid layout when dimensions are \code{NULL}, then fixes the panel size.}
#'   \item{\code{"image"}}{Draws the whole plot once via
#'     \code{ragg::agg_capture()} and returns it as a single
#'     \code{rasterGrob}. Text is rasterized too, so the result redraws quickly
#'     (for example on every resize of the RStudio Plots pane) even when the
#'     plot is dominated by text, such as a forest-plot table, which the other
#'     backends keep as vectors. Use it for on-screen previews, not for
#'     publication export.}
#' }
#'
#' @param plot A ggplot, patchwork, or list containing either type. For
#'   \code{method = "image"}, also a grob, a recorded base plot
#'   (\code{grDevices::recordPlot()}) or any object its print method draws,
#'   such as a forestplot; only a plain list holds several plots.
#' @param method Rasterization backend: \code{"ggrastr"} (default, simple
#'   layer-level), \code{"ragg"} (panel-level, also fixes panel size), or
#'   \code{"image"} (the whole plot as one raster).
#' @param dpi Positive finite numeric scalar. Rasterization resolution in dots
#'   per inch. Default 300.
#' @param width,height Panel width and height for \code{method = "ragg"}.
#'   Positive finite numeric scalar, or one value per panel in depth-first
#'   gtable order (column-major for grid facets). Panels sharing layout cells
#'   must have consistent dimensions, and nested plots must fit their layout.
#'   Ignored when \code{method = "ggrastr"}. If \code{NULL} (default), panel
#'   dimensions are resolved from the current device's grid layout. With no
#'   open device, the width and height from \code{grDevices::pdf.options()}
#'   are used as the available plot size. For \code{method = "image"}, a
#'   single positive value each giving the size of the whole image; a
#'   \code{NULL} dimension takes the open device's size (or
#'   \code{pdf.options()}).
#' @param units Units for \code{width}/\code{height}: \code{"in"} (default),
#'   \code{"cm"}, or \code{"mm"}.
#' @param dev Character. Graphics device for \code{ggrastr::rasterise()}.
#'   Default \code{"ragg"} (high-quality anti-aliasing). Only used when
#'   \code{method = "ggrastr"}.
#' @param bg Character. Background colour for panel rendering.
#'   Default \code{"transparent"}. Used when \code{method} is \code{"ragg"}
#'   or \code{"image"}.
#'
#' @return The \code{"ggrastr"} backend preserves the input type. The
#'   \code{"ragg"} backend returns a patchwork-wrapped gtable with a
#'   \code{size} attribute: a list with \code{width}, \code{height}, and
#'   \code{units} describing the complete fixed plot dimensions. The
#'   \code{"image"} backend returns a patchwork-wrapped \code{rasterGrob}
#'   without plot margins, with the same \code{size} attribute for the
#'   rendered image. For list inputs, returns a corresponding list and
#'   preserves its names.
#'
#' @details
#' The \code{"ragg"} backend renders geometry immediately. Apply data,
#' scale, theme, and layer changes before calling this function. For export,
#' use the dimensions in the returned \code{size} attribute to retain the
#' fixed layout. The \code{"ggrastr"} backend rasterizes when the plot is
#' drawn and continues to use the output device's layout.
#'
#' Panels with clipping disabled are kept as vectors, with a warning, to
#' preserve geometry drawn outside the panel. They do not receive the file-size
#' benefit of rasterization.
#'
#' \subsection{How \code{"ragg"} preserves text}{
#' The function inspects each grob child inside a panel. Children whose own
#' name or class identifies text/labels, or whose descendants contain text,
#' are kept as vectors, as are the panel's background grid and border. Mixed
#' text/geometry trees are retained together to preserve their internal
#' layout. A viewport alone does not prevent rasterization. Empty grobs are
#' dropped. Other children (points, lines, polygons, raster, etc.) are
#' captured in contiguous runs and inserted as \code{rasterGrob} objects,
#' each after an empty opaque polygon so that \code{pdf()} does not draw it
#' with the transparency of the grob before it. Vector text and rasterized
#' geometry retain their original draw order, including text covered by a
#' later geometric layer.
#' }
#'
#' @seealso [grob_as()], [ggrastr::rasterise()]
#'
#' @md
#' @examplesIf requireNamespace("ggrastr", quietly = TRUE) && requireNamespace("ragg", quietly = TRUE)
#' library(ggplot2)
#'
#' set.seed(42)
#' df <- data.frame(x = rnorm(5000), y = rnorm(5000))
#' p <- ggplot(df, aes(x, y)) + geom_point(alpha = 0.3) + ggtitle("Demo")
#'
#' # ggrastr backend (simple)
#' p_ggrastr <- fmt_raster(p, dpi = 150)
#' p_ggrastr
#'
#' # ragg backend (panel-level, also fixes panel size)
#' p_ragg <- fmt_raster(p, method = "ragg", width = 4, height = 3)
#' p_ragg
#'
#' # image backend (whole plot, text included, for fast on-screen redraws)
#' p_image <- fmt_raster(p, method = "image", dpi = 72, width = 4, height = 3)
#' p_image
#'
#' \donttest{
#' # Works with patchwork
#' library(patchwork)
#' p2 <- ggplot(df, aes(x)) + geom_histogram(bins = 30)
#' p_nested <- fmt_raster((p | p2) / p, method = "ragg", dpi = 150)
#' p_nested
#' }
#'
#' @export
#' @family plot formatting
fmt_raster <- function(
    plot,
    method  = c("ggrastr", "ragg", "image"),
    dpi     = 300,
    width   = NULL,
    height  = NULL,
    units   = c("in", "cm", "mm"),
    dev     = "ragg",
    bg      = "transparent"
) {
  method <- match.arg(method)
  units  <- match.arg(units)
  if (!is.numeric(dpi) || length(dpi) != 1L || !is.finite(dpi) || dpi <= 0) {
    cli::cli_abort("{.arg dpi} must be a positive finite numeric scalar.")
  }

  if (method %in% c("ragg", "image")) {
    for (arg in c("width", "height")) {
      value <- if (arg == "width") width else height
      if (!is.null(value) && (!is.numeric(value) || length(value) == 0L ||
                              any(!is.finite(value)) || any(value <= 0))) {
        cli::cli_abort("{.arg {arg}} must contain positive finite numeric values.")
      }
      if (method == "image" && length(value) > 1L) {
        cli::cli_abort("{.arg {arg}} must be a single value for {.code method = \"image\"}.")
      }
    }
  }

  if (method == "ggrastr") {
    return(.fmt_raster_ggrastr(plot, dpi = dpi, dev = dev))
  }
  if (method == "image") {
    return(.fmt_raster_image(plot, dpi = dpi, width = width, height = height,
                             units = units, bg = bg))
  }

  # method == "ragg"
  .fmt_raster_ragg(plot, dpi = dpi, width = width, height = height,
                   units = units, bg = bg)
}


# ============================================================================
# Backend 1: ggrastr -- layer-level rasterization
# ============================================================================

#' @noRd
.fmt_raster_ggrastr <- function(plot, dpi, dev) {
  if (!requireNamespace("ggrastr", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggrastr} is required for {.code method = \"ggrastr\"}.")
  }

  raster_one <- function(p) {
    if (inherits(p, "patchwork")) {
      for (i in seq_along(p)) p[[i]] <- raster_one(p[[i]])
      return(p)
    }
    # Points and tiles, as ggrastr's own default: lines, bars and polygons are
    # few objects, and as images they only make a PDF larger.
    targets <- vapply(p$layers, function(layer) {
      inherits(layer$geom, c("GeomPoint", "GeomTile"))
    }, logical(1))
    if (!any(targets)) return(p)
    if (identical(p$coordinates$clip, "off")) {
      cli::cli_warn("Plots with clipping disabled are kept as vectors to preserve geometry outside the panel.")
      return(p)
    }
    p$layers[targets] <- lapply(p$layers[targets], .opaque_raster_layer,
                                dpi = dpi, dev = dev)
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, raster_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single,
                  pw_orig = info$pw_orig)
}


# ============================================================================
# Backend 2: ragg -- panel-level rasterization (thisplot-style)
# ============================================================================

#' @noRd
.fmt_raster_ragg <- function(plot, dpi, width, height, units, bg) {
  if (!requireNamespace("ragg", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ragg} is required for {.code method = \"ragg\"}.")
  }
  if (is.list(plot) && !inherits(plot, c("gg", "gtable"))) {
    plots <- .to_plot_list(plot)$plots
    return(lapply(plots, function(p) {
      .fmt_raster_ragg(p, dpi = dpi, width = width, height = height,
                       units = units, bg = bg)
    }))
  }

  original_device <- grDevices::dev.cur()
  device_size <- if (original_device == 1L) {
    unlist(grDevices::pdf.options()[c("width", "height")], use.names = FALSE)
  } else {
    grDevices::dev.size("in")
  }
  # Measure on a private device to preserve the caller's viewport.
  .agg_capture(width = ceiling(device_size[1] * 72),
               height = ceiling(device_size[2] * 72), units = "px",
               res = 72, background = "transparent")
  measurement_device <- grDevices::dev.cur()
  on.exit({
    if (measurement_device %in% grDevices::dev.list()) {
      grDevices::dev.off(measurement_device)
    }
    if (original_device %in% grDevices::dev.list()) grDevices::dev.set(original_device)
  }, add = TRUE)
  grid::pushViewport(grid::viewport(width = grid::unit(device_size[1], "in"),
                                    height = grid::unit(device_size[2], "in")))

  # Convert to gtable
  gtable <- if (inherits(plot, "patchwork")) {
    patchwork::patchworkGrob(plot)
  } else {
    grob_as(plot)
  }
  if (!inherits(gtable, "gtable")) {
    cli::cli_abort("Cannot convert input to a gtable.")
  }

  panels_found <- 0L
  unclipped_panels <- FALSE
  panel_indices <- function(gt) {
    which(grepl("^panel(-[0-9]+)*$", gt$layout$name) &
            !vapply(gt$grobs, inherits, logical(1), "zeroGrob"))
  }
  count_panels <- function(gt) {
    nested <- Filter(function(g) inherits(g, "gtable"), gt$grobs)
    length(panel_indices(gt)) + sum(vapply(nested, count_panels, integer(1)))
  }
  panel_total <- count_panels(gtable)
  for (arg in c("width", "height")) {
    value <- if (arg == "width") width else height
    if (!is.null(value) && !length(value) %in% c(1L, panel_total)) {
      cli::cli_abort("Length of {.arg {arg}} must be 1 or {panel_total} (number of panels).")
    }
  }
  panel_cursor <- 0L
  raster_table <- function(gtable) {
    grid::pushViewport(grid::viewport(layout = grid::grid.layout(
      nrow = length(gtable$heights), ncol = length(gtable$widths),
      widths = gtable$widths, heights = gtable$heights, respect = gtable$respect
    )))
    on.exit(grid::popViewport(), add = TRUE)
    # Freeze every cell so nested tables contribute to the complete plot size.
    for (dim in c("width", "height")) {
      cells <- if (dim == "width") seq_along(gtable$widths) else seq_along(gtable$heights)
      convert_fn <- if (dim == "width") grid::convertWidth else grid::convertHeight
      sizes <- vapply(cells, function(cell) {
        vp <- if (dim == "width") grid::viewport(layout.pos.col = cell) else
          grid::viewport(layout.pos.row = cell)
        grid::pushViewport(vp)
        value <- convert_fn(grid::unit(1, "npc"), units, valueOnly = TRUE)
        grid::popViewport()
        value
      }, numeric(1))
      gtable[[paste0(dim, "s")]] <- grid::unit(sizes, units)
    }
    nested <- which(vapply(gtable$grobs, function(g) {
      inherits(g, "gtable") && count_panels(g) > 0L
    }, logical(1)))
    for (idx in nested) {
      grid::pushViewport(grid::viewport(layout.pos.row = gtable$layout$t[idx]:gtable$layout$b[idx],
                                        layout.pos.col = gtable$layout$l[idx]:gtable$layout$r[idx]))
      gtable$grobs[[idx]] <- raster_table(gtable$grobs[[idx]])
      grid::popViewport()
    }

    indices <- panel_indices(gtable)
    if (length(indices)) {
      positions <- panel_cursor + seq_along(indices)
      panel_cursor <<- panel_cursor + length(indices)
      panels_found <<- panels_found + length(indices)
      widths <- if (length(width) > 1L) width[positions] else width
      heights <- if (length(height) > 1L) height[positions] else height
      panel_w <- .resolve_panel_size(gtable, indices, "width", widths, units)
      panel_h <- .resolve_panel_size(gtable, indices, "height", heights, units)

      # Shared columns/rows must have one consistent physical dimension.
      for (dim in c("width", "height")) {
        requested <- if (dim == "width") widths else heights
        if (is.null(requested)) next
        values <- if (dim == "width") panel_w else panel_h
        assigned <- rep(NA_real_, length(gtable[[paste0(dim, "s")]]))
        for (i in seq_along(indices)) {
          idx <- indices[i]
          cells <- if (dim == "width") gtable$layout$l[idx]:gtable$layout$r[idx] else
            gtable$layout$t[idx]:gtable$layout$b[idx]
          value <- values[i] / length(cells)
          previous <- assigned[cells]
          if (any(!is.na(previous) & abs(previous - value) > 1e-8)) {
            cli::cli_abort("{.arg {dim}} values for panels sharing layout cells must agree.")
          }
          assigned[cells] <- value
        }
        cells <- which(!is.na(assigned))
        gtable[[paste0(dim, "s")]][cells] <- grid::unit(assigned[cells], units)
      }
    }

    for (idx in nested) {
      child <- gtable$grobs[[idx]]
      available_w <- sum(gtable$widths[gtable$layout$l[idx]:gtable$layout$r[idx]])
      available_h <- sum(gtable$heights[gtable$layout$t[idx]:gtable$layout$b[idx]])
      if (grid::convertWidth(sum(child$widths), units, TRUE) >
          grid::convertWidth(available_w, units, TRUE) + 1e-8 ||
          grid::convertHeight(sum(child$heights), units, TRUE) >
          grid::convertHeight(available_h, units, TRUE) + 1e-8) {
        cli::cli_abort("Panel dimensions are incompatible with the nested layout; use NULL or consistent per-panel dimensions.")
      }
    }
    for (i in seq_along(indices)) {
      idx <- indices[i]
      panel <- gtable$grobs[[idx]]
      clip_on <- if (inherits(panel$vp, "viewport")) {
        isTRUE(panel$vp$clip)
      } else {
        identical(gtable$layout$clip[idx], "on")
      }
      if (clip_on) {
        gtable$grobs[[idx]] <- .rasterize_panel_grob(
          panel, w = panel_w[i], h = panel_h[i], dpi = dpi,
          units = units, bg = bg
        )
      } else {
        unclipped_panels <<- TRUE
      }
    }
    gtable
  }
  gtable <- raster_table(gtable)
  if (unclipped_panels) {
    cli::cli_warn("Panels with clipping disabled are kept as vectors to preserve geometry outside the panel.")
  }
  if (panels_found == 0) {
    cli::cli_warn("No panels detected. Returning plot as-is.")
    return(plot)
  }

  # Wrap and return
  p <- patchwork::wrap_plots(gtable)
  plot_w <- grid::convertWidth(sum(gtable[["widths"]]), units, valueOnly = TRUE)
  plot_h <- grid::convertHeight(sum(gtable[["heights"]]), units, valueOnly = TRUE)
  attr(p, "size") <- list(width = plot_w, height = plot_h, units = units)
  p
}


# ============================================================================
# Backend 3: image -- the whole plot, text included, as one raster
# ============================================================================

#' @noRd
.fmt_raster_image <- function(plot, dpi, width, height, units, bg) {
  if (!requireNamespace("ragg", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ragg} is required for {.code method = \"image\"}.")
  }
  # Only a plain list holds several plots; a classed list such as a forestplot
  # is one figure that its print method draws.
  if (is.list(plot) && !is.object(plot)) {
    if (any(vapply(plot, is.null, logical(1)))) {
      cli::cli_abort("All elements in the list must be plots.")
    }
    return(lapply(plot, .fmt_raster_image, dpi = dpi, width = width,
                  height = height, units = units, bg = bg))
  }

  # A missing dimension takes the open device's size (pdf.options() without
  # one), converted from inches to `units`.
  original_device <- grDevices::dev.cur()
  if (is.null(width) || is.null(height)) {
    device_size <- if (original_device == 1L) {
      unlist(grDevices::pdf.options()[c("width", "height")], use.names = FALSE)
    } else {
      grDevices::dev.size("in")
    }
    per_inch <- c("in" = 1, "cm" = 2.54, "mm" = 25.4)[[units]]
    if (is.null(width))  width  <- device_size[1] * per_inch
    if (is.null(height)) height <- device_size[2] * per_inch
  }

  capture <- .agg_capture(width = width, height = height, units = units,
                          res = dpi, background = bg)
  capture_device <- grDevices::dev.cur()
  on.exit({
    if (capture_device %in% grDevices::dev.list()) {
      grDevices::dev.off(capture_device)
    }
    if (original_device %in% grDevices::dev.list()) {
      grDevices::dev.set(original_device)
    }
  }, add = TRUE)
  if (inherits(plot, "grob")) {
    grid::grid.draw(plot)
  } else if (inherits(plot, "recordedplot")) {
    grDevices::replayPlot(plot)
  } else {
    print(plot)
  }
  image <- capture(native = TRUE)

  # No margins: shown at its own size, the image is drawn pixel for pixel.
  p <- patchwork::wrap_plots(.opaque_raster(image, interpolate = TRUE)) &
    ggplot2::theme(plot.margin = ggplot2::margin())
  attr(p, "size") <- list(width = width, height = height, units = units)
  p
}


# --- Resolve panel size: user-specified or from current gtable ---
#' @noRd
.resolve_panel_size <- function(gtable, panel_index, dim, user_val, units) {
  n <- length(panel_index)

  if (!is.null(user_val)) {
    if (length(user_val) == 1) return(rep(user_val, n))
    if (length(user_val) == n) return(user_val)
    cli::cli_abort(
      "Length of {.arg {dim}} must be 1 or {n} (number of panels), not {length(user_val)}."
    )
  }

  # Resolve null units through the complete grid layout, including respect.
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(
    nrow = length(gtable$heights), ncol = length(gtable$widths),
    widths = gtable$widths, heights = gtable$heights, respect = gtable$respect
  )))
  on.exit(grid::popViewport(), add = TRUE)
  convert_fn <- if (dim == "width") grid::convertWidth else grid::convertHeight
  vapply(panel_index, function(idx) {
    grid::pushViewport(grid::viewport(layout.pos.row = gtable$layout$t[idx]:gtable$layout$b[idx],
                                      layout.pos.col = gtable$layout$l[idx]:gtable$layout$r[idx]))
    val <- convert_fn(grid::unit(1, "npc"), units, valueOnly = TRUE)
    grid::popViewport()
    if (!is.finite(val) || val <= 0) {
      cli::cli_abort("Cannot resolve a positive panel {.arg {dim}}; supply it explicitly.")
    }
    val
  }, numeric(1))
}


# --- Core: rasterize a single panel grob, preserving text ---
#' @noRd
.rasterize_panel_grob <- function(g, w, h, dpi, units, bg) {
  ordered <- match(g$childrenOrder, names(g$children))
  # Empty grobs draw nothing: they neither become nor split a raster run.
  ordered <- ordered[!vapply(g$children[ordered], inherits, logical(1),
                             c("zeroGrob", "null"))]
  output <- list()
  # A panel background belongs below every run, including vector text.
  if (!is.na(bg) && bg != "transparent") {
    output <- list(grid::rectGrob(gp = grid::gpar(fill = bg, col = NA)))
  }
  capture_run <- function(indices) {
    inches <- switch(units, "in" = 1, "cm" = 1 / 2.54, "mm" = 1 / 25.4)
    if (w * inches * dpi < 1 || h * inches * dpi < 1) {
      cli::cli_abort("Panel dimensions and {.arg dpi} must produce at least one pixel per dimension.")
    }
    g_geom <- g
    g_geom$children <- do.call(grid::gList, g$children[indices])
    g_geom$childrenOrder <- names(g_geom$children)
    if (is.null(g_geom$vp)) g_geom$vp <- grid::viewport()
    previous_device <- grDevices::dev.cur()
    capture <- .agg_capture(width = w, height = h, background = "transparent",
                            res = dpi, units = units)
    raster_device <- grDevices::dev.cur()
    on.exit({
      if (raster_device %in% grDevices::dev.list()) grDevices::dev.off(raster_device)
      if (previous_device %in% grDevices::dev.list()) grDevices::dev.set(previous_device)
    }, add = TRUE)
    grid::grid.draw(g_geom)
    pixels <- capture(native = TRUE)
    grDevices::dev.off(raster_device)
    .opaque_raster(pixels)
  }

  # Capture contiguous geometry runs without moving them across vector text;
  # the background grid and the border stay vector too.
  pending <- integer()
  for (j in ordered) {
    child <- g$children[[j]]
    name <- names(g$children)[j]
    if (grepl("^(grill|panel\\.border)", name) || .is_text_grob(child, name)) {
      if (length(pending)) {
        output <- c(output, list(capture_run(pending)))
        pending <- integer()
      }
      output <- c(output, list(child))
    } else {
      pending <- c(pending, j)
    }
  }
  if (length(pending)) output <- c(output, list(capture_run(pending)))
  g <- grid::setChildren(g, do.call(grid::gList, output))
  g
}


# --- ggrastr layer whose rasters pdf() draws opaque ---
#' @noRd
.opaque_raster_layer <- function(layer, dpi, dev) {
  # Built here, not in the caller, so the returned layer does not carry the
  # whole input plot in its environment. A layer rasterized by an earlier
  # call is rasterized again from its source, not on top of its raster.
  source <- layer$fmt_raster_source %||% layer
  rasterised <- ggrastr::rasterise(source, dpi = dpi, dev = dev)
  ggplot2::ggproto(NULL, rasterised, fmt_raster_source = source,
    draw_geom = function(self, data, layout) {
      grobs <- ggplot2::ggproto_parent(rasterised, self)$draw_geom(data, layout)
      lapply(grobs, function(g) if (inherits(g, "zeroGrob")) g else .opaque_grob(g))
    })
}


# --- Raster that pdf() draws opaque ---
#' @noRd
.opaque_raster <- function(image, ...) .opaque_grob(grid::rasterGrob(image, ...))

#' @noRd
.opaque_grob <- function(grob) {
  # pdf() paints a raster with the fill alpha of the grob drawn before it
  # (VPetukhov/ggrastr#39); an empty opaque polygon resets that alpha first.
  grid::grobTree(
    grid::polygonGrob(c(0, 0, 0), c(0, 0, 0),
                      gp = grid::gpar(fill = "white", col = NA)),
    grob
  )
}


# --- In-memory ragg device that leaves the random stream alone ---
#' @noRd
.agg_capture <- function(...) {
  # ragg before 1.5.1 names the device with sample() (r-lib/ragg#211).
  seed <- get0(".Random.seed", envir = globalenv(), inherits = FALSE)
  on.exit(if (is.null(seed)) {
    if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }
  } else {
    assign(".Random.seed", seed, envir = globalenv())
  })
  ragg::agg_capture(...)
}


# --- Detect whether a panel child is a text/label grob ---
#' @noRd
.is_text_grob <- function(child, child_nm) {
  if (any(grepl("text|label", c(child_nm, class(child)), ignore.case = TRUE))) {
    return(TRUE)
  }
  children <- if (inherits(child, "gtable")) child$grobs else
    if (inherits(child, "gTree")) child$children
  any(vapply(children, function(g) .is_text_grob(g, g$name), logical(1)))
}
