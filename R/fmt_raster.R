# ============================================================================
# fmt_raster.R -- Rasterize plot panels to reduce PDF file size
# ============================================================================

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
#' @param dpi Integer. Rasterization resolution. Default 300.
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
#' polygons, raster, etc.) are rendered into a single PNG and read back as a
#' \code{rasterGrob}. The two sets are then recombined, so the final output
#' has crisp vector text on top of a rasterized geometric layer.
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

  # Convert to gtable
  gtable <- grob_as(plot)
  if (!inherits(gtable, "gtable")) {
    cli::cli_abort("Cannot convert input to a gtable.")
  }

  # Find panel indices (non-zero panels)
  non_zero <- grep(
    "zeroGrob",
    vapply(gtable$grobs, as.character, character(1)),
    invert = TRUE
  )
  panel_index <- grep("panel", gtable[["layout"]][["name"]])
  panel_index <- intersect(panel_index, non_zero)
  if (length(panel_index) == 0) {
    cli::cli_warn("No panels detected. Returning plot as-is.")
    return(plot)
  }

  # Resolve panel sizes
  panel_w <- .resolve_panel_size(gtable, panel_index, "width", width, units)
  panel_h <- .resolve_panel_size(gtable, panel_index, "height", height, units)

  # Fix panel dimensions in the gtable
  for (i in seq_along(panel_index)) {
    idx <- panel_index[i]
    col_range <- gtable[["layout"]][["l"]][idx]:gtable[["layout"]][["r"]][idx]
    row_range <- gtable[["layout"]][["t"]][idx]:gtable[["layout"]][["b"]][idx]

    w_each <- panel_w[i] / length(col_range)
    h_each <- panel_h[i] / length(row_range)
    gtable[["widths"]][col_range]  <- grid::unit(rep(w_each, length(col_range)), units)
    gtable[["heights"]][row_range] <- grid::unit(rep(h_each, length(row_range)), units)
  }

  # Rasterize each panel
  for (i in seq_along(panel_index)) {
    idx <- panel_index[i]
    g <- gtable$grobs[[idx]]
    if (is.null(g) || inherits(g, "zeroGrob")) next

    gtable$grobs[[idx]] <- .rasterize_panel_grob(
      g, w = panel_w[i], h = panel_h[i], dpi = dpi, units = units, bg = bg
    )
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
  vp <- g$vp
  children_order <- g$childrenOrder

  # Separate text (vector) vs geometry (raster) children
  g_geom <- g          # copy for rendering to PNG (text removed)
  g_text <- g          # copy for vector output (geometry removed)

  if (is.null(g_geom$vp)) g_geom$vp <- grid::viewport()

  for (j in seq_along(g[["children"]])) {
    child    <- g[["children"]][[j]]
    child_nm <- names(g[["children"]])[j]

    is_text <- .is_text_grob(child, child_nm)

    if (is_text) {
      # Keep in g_text, remove from g_geom
      zero <- ggplot2::zeroGrob()
      zero$name <- child$name
      g_geom[["children"]][[j]] <- zero
    } else {
      # Keep in g_geom, remove from g_text
      g_text[["children"]][[j]] <- ggplot2::zeroGrob()
    }
  }

  # Render geometry to temporary PNG
  temp <- tempfile(fileext = ".png")
  on.exit(unlink(temp), add = TRUE)

  ragg::agg_png(temp, width = w, height = h, bg = bg,
                res = dpi, units = units)
  grid::grid.draw(g_geom)
  grDevices::dev.off()

  # Read back as rasterGrob
  g_ras <- grid::rasterGrob(png::readPNG(temp, native = TRUE))

  # Combine: raster at bottom, vector text on top
  g_out <- grid::addGrob(g_text, g_ras)
  g_out$vp <- vp
  g_out$childrenOrder <- c(g_ras$name, children_order)
  g_out
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
