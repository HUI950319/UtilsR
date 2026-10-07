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
#'     which marks all geom layers for rasterization at render time. Simple and
#'     fast. Text and theme elements are always preserved as vectors.}
#'   \item{\code{"ragg"}}{Renders each panel to a temporary PNG via
#'     \code{ragg::agg_png()}, then reads it back as a \code{rasterGrob}.
#'     Text/label grobs inside the panel are automatically detected and kept
#'     as vectors. Requires \code{width} and \code{height} to be specified
#'     (the panel rendering size). This method also fixes the panel size.}
#' }
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param method Rasterization backend: \code{"ggrastr"} (default, simple
#'   layer-level) or \code{"ragg"} (panel-level, also fixes panel size).
#' @param dpi Positive finite numeric scalar. Rasterization resolution in dots
#'   per inch. Default 300.
#' @param width,height Panel width and height for \code{method = "ragg"}.
#'   Ignored when \code{method = "ggrastr"}. If \code{NULL} (default), the
#'   current device size is used.
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
#' \subsection{How \code{"ragg"} preserves text}{
#' The function inspects each grob child inside a panel. Children whose name
#' or class matches \code{text}, \code{label}, \code{segments}, or
#' \code{legend} are kept as vector grobs. All other children (points, lines,
#' polygons, raster, etc.) are rendered in contiguous runs and read back as
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
    ggrastr::rasterise(p, dpi = dpi, dev = dev)
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

  original_device <- grDevices::dev.cur()
  measurement_device <- NULL
  if (original_device == 1L) {
    grDevices::pdf(NULL)
    measurement_device <- grDevices::dev.cur()
  }
  on.exit({
    if (!is.null(measurement_device) && measurement_device %in% grDevices::dev.list()) {
      grDevices::dev.off(measurement_device)
    }
    if (original_device %in% grDevices::dev.list()) grDevices::dev.set(original_device)
  }, add = TRUE)

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
  raster_table <- function(gtable) {
    # Nested patchworks contain complete gtables; keep their axes and labels.
    nested <- which(vapply(gtable$grobs, inherits, logical(1), "gtable"))
    for (idx in nested) gtable$grobs[[idx]] <- raster_table(gtable$grobs[[idx]])

    panel_index <- which(grepl("^panel(-[0-9]+)*$", gtable$layout$name) &
                           !vapply(gtable$grobs, inherits, logical(1), "zeroGrob"))
    if (length(panel_index) == 0) return(gtable)
    panels_found <<- panels_found + length(panel_index)

    panel_w <- .resolve_panel_size(gtable, panel_index, "width", width, units)
    panel_h <- .resolve_panel_size(gtable, panel_index, "height", height, units)

    for (i in seq_along(panel_index)) {
      idx <- panel_index[i]
      col_range <- gtable$layout$l[idx]:gtable$layout$r[idx]
      row_range <- gtable$layout$t[idx]:gtable$layout$b[idx]
      gtable$widths[col_range] <- grid::unit(rep(panel_w[i] / length(col_range),
                                               length(col_range)), units)
      gtable$heights[row_range] <- grid::unit(rep(panel_h[i] / length(row_range),
                                                length(row_range)), units)
      gtable$grobs[[idx]] <- .rasterize_panel_grob(
        gtable$grobs[[idx]], w = panel_w[i], h = panel_h[i], dpi = dpi,
        units = units, bg = bg
      )
    }
    gtable
  }
  gtable <- raster_table(gtable)
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

  # Infer from current gtable
  convert_fn <- if (dim == "width") grid::convertWidth else grid::convertHeight
  vapply(panel_index, function(idx) {
    if (dim == "width") {
      cols <- gtable[["layout"]][["l"]][idx]:gtable[["layout"]][["r"]][idx]
      val <- convert_fn(sum(gtable[["widths"]][cols]), units, valueOnly = TRUE)
    } else {
      rows <- gtable[["layout"]][["t"]][idx]:gtable[["layout"]][["b"]][idx]
      val <- convert_fn(sum(gtable[["heights"]][rows]), units, valueOnly = TRUE)
    }
    # Fallback if zero/null units
    if (is.na(val) || val < 0.01) val <- 4
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
  g$children <- do.call(grid::gList, output)
  g$childrenOrder <- names(g$children)
  g
}


# --- Detect whether a panel child is a text/label grob ---
#' @noRd
.is_text_grob <- function(child, child_nm) {
  # Check child name
  if (any(grepl("(text)|(label)", child_nm, ignore.case = TRUE))) {
    return(TRUE)
  }
  # Check viewport (text grobs often have their own vp)
  if (!is.null(child$vp)) return(TRUE)
  # Check class of first list element
  if (!is.null(child$list) && length(child$list) > 0) {
    cls <- class(child$list[[1]])
    if (any(grepl("(text)|(segments)|(legend)", cls, ignore.case = TRUE))) {
      return(TRUE)
    }
  }
  FALSE
}
