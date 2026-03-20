# ============================================================================
# fmt_point.R -- Add data points to ggplot (point, jitter, beeswarm)
# ============================================================================

#' Add Data Points to a Plot
#'
#' Unified function to overlay data points on ggplot objects. Supports
#' plain points, jittered points, and beeswarm layout. Automatically
#' detects group aesthetics to apply dodge positioning.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param type Point layout type: \code{"point"} (default), \code{"jitter"},
#'   or \code{"beeswarm"}.
#' @param data Data for the point layer. Default \code{NULL} inherits from plot.
#'   Can be a data.frame or a function/formula applied to the plot data
#'   (e.g. \code{~ subset(.x, value > 10)}).
#' @param shape Point shape. Default 19 (solid circle).
#' @param size Point size. Default 1.
#' @param white_border Logical. If \code{TRUE}, converts shapes to fillable
#'   versions (21-24) with white stroke. Default \code{FALSE}.
#' @param dodge_width Dodge width for grouped data. Default 0.8.
#'   Set to 0 to disable dodging.
#' @param jitter_width Horizontal jitter. Only used when \code{type = "jitter"}.
#'   Default 0.2.
#' @param jitter_height Vertical jitter. Default 0.
#' @param cex Beeswarm spacing factor. Only used when \code{type = "beeswarm"}.
#'   Default 3.
#' @param corral Beeswarm boundary handling. Default \code{"wrap"}.
#' @param corral.width Beeswarm boundary width. Default 0.5.
#' @param rasterize Logical. If \code{TRUE}, rasterizes the point layer
#'   via \code{ggrastr::rasterise} for large datasets. Default \code{FALSE}.
#' @param rasterize_dpi DPI for rasterization. Default 300.
#' @param ... Additional arguments passed to \code{geom_point} or
#'   \code{geom_beeswarm}.
#'
#' @return Same type as input (ggplot, patchwork, or list).
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#'
#' # Plain points
#' fmt_point(p, color = "steelblue", alpha = 0.5)
#'
#' # Jittered points
#' fmt_point(p, type = "jitter", color = "red", alpha = 0.5)
#'
#' # Beeswarm
#' fmt_point(p, type = "beeswarm", color = "darkgreen", size = 1.2)
#'
#' # White border effect
#' fmt_point(p, type = "jitter", fill = "purple",
#'           white_border = TRUE, size = 2)
#'
#' # Grouped data (auto-dodge)
#' p2 <- ggplot(iris, aes(Species, Sepal.Length, color = Species)) +
#'   geom_boxplot()
#' fmt_point(p2, type = "jitter", alpha = 0.5)
#'
#' @export
#' @family plot formatting
fmt_point <- function(plot,
                      type = c("point", "jitter", "beeswarm"),
                      data = NULL,
                      shape = 19,
                      size = 1,
                      white_border = FALSE,
                      dodge_width = 0.8,
                      jitter_width = 0.2,
                      jitter_height = 0,
                      cex = 3,
                      corral = "wrap",
                      corral.width = 0.5,
                      rasterize = FALSE,
                      rasterize_dpi = 300,
                      ...) {
  type <- match.arg(type)

  # Set jitter defaults by type
  if (type == "point") {
    jitter_width <- 0
    jitter_height <- 0
  }

  fmt_point_one <- function(p) {
    # --- Compute position ---
    has_group <- any(c("fill", "colour", "color", "linetype", "shape", "size", "alpha") %in% names(p$mapping))

    if (type == "beeswarm") {
      position <- NULL
    } else if (dodge_width == 0 || !has_group) {
      if (jitter_width == 0 && jitter_height == 0) {
        position <- ggplot2::position_identity()
      } else {
        position <- ggplot2::position_jitter(
          width = jitter_width, height = jitter_height, seed = 42
        )
      }
    } else {
      if (jitter_width == 0 && jitter_height == 0) {
        position <- ggplot2::position_dodge(width = dodge_width, preserve = "total")
      } else {
        position <- ggplot2::position_jitterdodge(
          jitter.width = jitter_width, jitter.height = jitter_height,
          dodge.width = dodge_width, seed = 42
        )
      }
    }

    # --- Build params ---
    params <- list(size = size, shape = shape, ...)
    if (!is.null(data)) params$data <- data

    # --- White border ---
    if (white_border) {
      params$shape <- .shape_convert(params$shape)
      if (params$shape %in% 21:24) {
        params$size <- params$size * 1.5
        if ("color" %in% names(params) && !"fill" %in% names(params)) {
          params$fill <- params$color
        }
        params$color <- "#FFFFFF"
      }
    }

    # Skip fixed aesthetics if mapped
    if ("shape" %in% names(p$mapping)) params$shape <- NULL
    if ("size" %in% names(p$mapping)) params$size <- NULL

    # --- Create geom ---
    if (type == "beeswarm") {
      if (!requireNamespace("ggbeeswarm", quietly = TRUE)) {
        cli::cli_abort("Package {.pkg ggbeeswarm} is required for type='beeswarm'.")
      }
      params$dodge.width <- dodge_width
      params$cex <- cex
      params$corral <- corral
      params$corral.width <- corral.width
      geom <- do.call(ggbeeswarm::geom_beeswarm, params)
    } else {
      params$position <- position
      geom <- do.call(ggplot2::geom_point, params)
    }

    # --- Add layer (with optional rasterization) ---
    if (rasterize) {
      if (!requireNamespace("ggrastr", quietly = TRUE)) {
        cli::cli_abort("Package {.pkg ggrastr} is required for rasterize=TRUE.")
      }
      p + ggrastr::rasterise(geom, dpi = rasterize_dpi, dev = "ragg")
    } else {
      p + geom
    }
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_point_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single)
}

# --- Internal helper ---

#' @noRd
.shape_convert <- function(x) {
  dict <- c("0" = 22, "15" = 22,
            "1" = 21, "16" = 21, "19" = 21, "20" = 21,
            "2" = 24, "17" = 24,
            "5" = 23, "18" = 23)
  key <- as.character(x)
  if (key %in% names(dict)) unname(dict[key]) else x
}
