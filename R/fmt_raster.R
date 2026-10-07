# =============================================================================
# fmt_raster.R -- Rasterize plot panels to shrink PDF output
# =============================================================================
#
# Architecture (4 layers):
#
#   L1  fmt_raster(plot, method, dpi, width, height, ...)   -- public API
#         |   method = "ggrastr" (default) | "ragg"
#         +-- L2  .fmt_raster_ggrastr()   re-wrap layers through ggrastr
#         +-- L2  .fmt_raster_ragg()      render panel grobs through ragg
#               +-- L3  .resolve_panel_size()     panel size in inches
#               +-- L3  .rasterize_panel_grob()   grob -> raster grob
#                     +-- L4  .is_text_grob()     keep text grobs vector
# =============================================================================

#' Rasterize Plot Panels
#'
#' Rasterize geometric layers (points, lines, polygons) in ggplot panels to
#' reduce PDF/SVG file size, while keeping text, axes, and legends as vectors.
#'
#' Two backends are available:
#' \describe{
#'   \item{\code{"ggrastr"}}{Wraps the plot with \code{ggrastr::rasterise()},
#'     which marks non-text geom layers for rasterization at render time.
#'     Text/label layers, custom annotations, and theme elements remain vectors.}
#'   \item{\code{"ragg"}}{Renders each panel to a temporary PNG via
#'     \code{ragg::agg_png()}, then reads it back as a \code{rasterGrob}.
#'     Text/label grobs inside the panel are automatically detected and kept
#'     as vectors. Uses the specified panel dimensions or the current device's
#'     grid layout when dimensions are \code{NULL}, then fixes the panel size.}
#' }
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param method Rasterization backend: \code{"ggrastr"} (default, simple
#'   layer-level) or \code{"ragg"} (panel-level, also fixes panel size).
#' @param dpi Positive finite numeric scalar. Rasterization resolution in dots
#'   per inch. Default 300.
#' @param width,height Panel width and height for \code{method = "ragg"}.
#'   Positive finite numeric scalar, or one value per panel in depth-first
#'   gtable order (column-major for grid facets). Panels sharing layout cells
#'   must have consistent dimensions, and nested plots must fit their layout.
#'   Ignored when \code{method = "ggrastr"}. If \code{NULL} (default), panel
#'   dimensions are resolved from the current device's grid layout.
#' @param units Units for \code{width}/\code{height}: \code{"in"} (default),
#'   \code{"cm"}, or \code{"mm"}.
#' @param dev Character. Graphics device for \code{ggrastr::rasterise()}.
#'   Default \code{"ragg"} (high-quality anti-aliasing). Only used when
#'   \code{method = "ggrastr"}.
#' @param bg Character. Background colour for panel rendering.
#'   Default \code{"transparent"}.
#'
#' @return Same type as input: a ggplot, patchwork, or list of ggplot objects.
#'   When \code{method = "ragg"}, returns a patchwork-wrapped gtable with
#'   a \code{size} attribute (list of width, height, units).
#'
#' @details
#' Panels with clipping disabled are kept as vectors, with a warning, to
#' preserve geometry drawn outside the panel. They do not receive the file-size
#' benefit of rasterization.
#'
#' \subsection{How \code{"ragg"} preserves text}{
#' The function inspects each grob child inside a panel. Children whose own
#' name or class identifies text/labels, or whose descendants contain text,
#' are kept as vectors. Mixed text/geometry trees are retained together to
#' preserve their internal layout. A viewport alone does not prevent
#' rasterization. Other children (points, lines, polygons, raster, etc.) are
#' rendered in contiguous runs and read back as
#' \code{rasterGrob} objects. Vector text and rasterized geometry retain their
#' original draw order, including text covered by a later geometric layer.
#' }
#'
#' @examples
#' library(ggplot2)
#'
#' set.seed(42)
#' df <- data.frame(x = rnorm(5000), y = rnorm(5000))
#' p <- ggplot(df, aes(x, y)) + geom_point(alpha = 0.3) + ggtitle("Demo")
#'
#' # ggrastr backend (simple)
#' fmt_raster(p)
#' fmt_raster(p, dpi = 150)
#'
#' # ragg backend (panel-level, also fixes panel size)
#' fmt_raster(p, method = "ragg", width = 4, height = 4)
#'
#' \donttest{
#' # Works with patchwork
#' library(patchwork)
#' p2 <- ggplot(df, aes(x)) + geom_histogram()
#' fmt_raster(p | p2, method = "ggrastr", dpi = 300)
#' }
#'
#' @export
#' @family plot formatting
fmt_raster <- function(
    plot,
    method  = c("ggrastr", "ragg"),
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

  if (method == "ragg") {
    for (arg in c("width", "height")) {
      value <- if (arg == "width") width else height
      if (!is.null(value) && (!is.numeric(value) || length(value) == 0L ||
                              any(!is.finite(value)) || any(value <= 0))) {
        cli::cli_abort("{.arg {arg}} must contain positive finite numeric values.")
      }
    }
  }

  if (method == "ggrastr") {
    return(.fmt_raster_ggrastr(plot, dpi = dpi, dev = dev))
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
    if (identical(p$coordinates$clip, "off")) {
      cli::cli_warn("Plots with clipping disabled are kept as vectors to preserve geometry outside the panel.")
      return(p)
    }
    p$layers <- lapply(p$layers, function(layer) {
      vector_layer <- any(grepl("text|label", class(layer$geom), ignore.case = TRUE)) ||
        inherits(layer$geom, "GeomCustomAnn")
      if (vector_layer) return(layer)
      ggrastr::rasterise(layer, dpi = dpi, dev = dev)
    })
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
  if (!requireNamespace("png", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg png} is required for {.code method = \"ragg\"}.")
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
  # Measure on a private device to preserve the caller's viewport and fonts.
  ragg::agg_capture(width = ceiling(device_size[1] * 72),
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
  ordered <- ordered[!vapply(g$children[ordered], inherits, logical(1), "zeroGrob")]
  output <- list()
  temp_files <- character()
  on.exit(unlink(temp_files), add = TRUE)

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
    temp <- tempfile(fileext = ".png")
    temp_files <<- c(temp_files, temp)
    previous_device <- grDevices::dev.cur()
    ragg::agg_png(temp, width = w, height = h, bg = "transparent",
                  res = dpi, units = units)
    raster_device <- grDevices::dev.cur()
    on.exit({
      if (raster_device %in% grDevices::dev.list()) grDevices::dev.off(raster_device)
      if (previous_device %in% grDevices::dev.list()) grDevices::dev.set(previous_device)
    }, add = TRUE)
    grid::grid.draw(g_geom)
    grDevices::dev.off(raster_device)
    grid::rasterGrob(png::readPNG(temp, native = TRUE))
  }

  # Capture contiguous geometry runs without moving them across vector text.
  pending <- integer()
  for (j in ordered) {
    child <- g$children[[j]]
    if (.is_text_grob(child, names(g$children)[j])) {
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
