# =============================================================================
# fmt_point.R -- Add data points to a plot (point / jitter / beeswarm)
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  fmt_point(plot, type, data, shape, size, ...)   -- public API
#         +-- L2  .shape_convert()   shape name or code -> ggplot2 shape
# =============================================================================

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
#' @param dodge.width Dodge width for grouped data. Default 0.8.
#'   Set to 0 to disable dodging.
#' @param jitter.args Named list of jitter arguments. Only used when
#'   \code{type = "jitter"}. Defaults: \code{list(width = 0.2, height = 0)}.
#' @param beeswarm.args Named list of beeswarm arguments. Only used when
#'   \code{type = "beeswarm"}.
#'   Defaults: \code{list(cex = 3, corral = "wrap", corral.width = 0.5)}.
#' @param sample_n Integer or \code{NULL}. When set, randomly subsample data
#'   before plotting to reduce overplotting. An explicit \code{group} mapping
#'   takes priority over discrete color/fill mappings, including expressions.
#'   Sampling takes at most \code{sample_n} points \strong{per group}; missing
#'   group values form a separate group. Continuous color/fill mappings do not
#'   define sampling groups. Default \code{NULL} (no sampling).
#' @param seed Random seed for reproducible sampling. Default 42. Sampling
#'   preserves the caller's random-number state.
#' @param rasterize Logical. If \code{TRUE}, rasterizes the point layer
#'   via \code{ggrastr::rasterise} for large datasets. Default \code{FALSE}.
#' @param rasterize.dpi Integer, DPI for rasterization. Default 300.
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
#' # Custom jitter width
#' fmt_point(p, type = "jitter", jitter.args = list(width = 0.4), alpha = 0.5)
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
#' # Subsample when too many points
#' fmt_point(p, type = "jitter", sample_n = 20, alpha = 0.5)
#'
#' # Stratified sampling (per group)
#' fmt_point(p2, type = "jitter", sample_n = 10, alpha = 0.5)
#'
#' @export
#' @family plot formatting
fmt_point <- function(plot,
                      type = c("point", "jitter", "beeswarm"),
                      data = NULL,
                      shape = 19,
                      size = 1,
                      white_border = FALSE,
                      dodge.width = 0.8,
                      jitter.args = list(width = 0.2, height = 0),
                      beeswarm.args = list(cex = 3, corral = "wrap", corral.width = 0.5),
                      sample_n = NULL,
                      seed = 42,
                      rasterize = FALSE,
                      rasterize.dpi = 300,
                      ...) {
  type <- match.arg(type)

  # Jitter defaults
  jit <- list(width = 0.2, height = 0)
  jit[names(jitter.args)] <- jitter.args
  if (type == "point") { jit$width <- 0; jit$height <- 0 }

  # Beeswarm defaults
  bee <- list(cex = 3, corral = "wrap", corral.width = 0.5)
  bee[names(beeswarm.args)] <- beeswarm.args

  fmt_point_one <- function(p) {
    # --- Subsample data ---
    if (!is.null(sample_n)) {
      old_seed <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
      on.exit({
        if (is.null(old_seed)) {
          if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
            rm(".Random.seed", envir = .GlobalEnv)
          }
        } else {
          assign(".Random.seed", old_seed, envir = .GlobalEnv)
        }
      }, add = TRUE)
      set.seed(seed)
      d <- data %||% p$data
      if (!is.null(d) && nrow(d) > sample_n) {
        # Use raw-data groups; stat/scale-stage mappings are not available yet.
        group_values <- NULL
        for (aes_name in c("group", "colour", "fill")) {
          mapping <- p$mapping[[aes_name]]
          if (is.null(mapping)) next
          expr <- rlang::get_expr(mapping)
          if (any(all.names(expr) %in% c("after_stat", "after_scale", "stage",
                                        "from_theme"))) next
          values <- rlang::eval_tidy(mapping, data = d)
          if (!is.null(values) &&
              (aes_name == "group" || is.factor(values) ||
               is.character(values) || is.logical(values))) {
            group_values <- rep_len(values, nrow(d))
            break
          }
        }
        if (!is.null(group_values)) {
          # Stratified: sample_n per group (keep all if group < sample_n)
          groups <- addNA(as.factor(group_values), ifany = TRUE)
          d <- do.call(rbind, lapply(split(d, groups), function(grp) {
            if (nrow(grp) <= sample_n) grp else grp[sample.int(nrow(grp), sample_n), ]
          }))
          rownames(d) <- NULL
        } else {
          # Global: sample_n total
          d <- dplyr::slice_sample(d, n = min(sample_n, nrow(d)))
        }
        data <- d
      }
    }

    # --- Compute position ---
    has_group <- any(c("fill", "colour", "linetype", "shape", "size", "alpha") %in% names(p$mapping))

    if (type == "beeswarm") {
      position <- NULL
    } else if (dodge.width == 0 || !has_group) {
      if (jit$width == 0 && jit$height == 0) {
        position <- ggplot2::position_identity()
      } else {
        position <- ggplot2::position_jitter(
          width = jit$width, height = jit$height, seed = 42
        )
      }
    } else {
      if (jit$width == 0 && jit$height == 0) {
        position <- ggplot2::position_dodge(width = dodge.width, preserve = "total")
      } else {
        position <- ggplot2::position_jitterdodge(
          jitter.width = jit$width, jitter.height = jit$height,
          dodge.width = dodge.width, seed = 42
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
      params$dodge.width <- dodge.width
      params$cex <- bee$cex
      params$corral <- bee$corral
      params$corral.width <- bee$corral.width
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
      p + ggrastr::rasterise(geom, dpi = rasterize.dpi, dev = "ragg")
    } else {
      p + geom
    }
  }

  info <- .to_plot_list(plot, recurse = TRUE)
  info$plots <- lapply(info$plots, fmt_point_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single,
                  pw_orig = info$pw_orig, recurse = TRUE)
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
