# =============================================================================
# fmt_point.R -- Add data points to a plot (point / jitter / beeswarm)
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  fmt_point(plot, type, data, shape, size, ...)   -- public API
#         +-- L2  .shape_convert()   shape name or code -> ggplot2 shape
#         +-- L2  .fmt_point_stage_args()   preserve staged aesthetics
#         +-- L2  .fmt_point_sample()   sample resolved layer data
#         +-- L2  .fmt_point_draw_panel()   white underlay for open symbols
#         +-- L2  .fmt_point_draw_key()     matching symbol keys
#         +-- L2  .fmt_point_jitterdodge_setup()   legacy group-only dodge
#         +-- L2  .fmt_point_position_setup()    resolve actual dodge groups
#         +-- L2  .fmt_point_position_layer()    delegate native positioning
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
#'   (e.g. \code{~ subset(.x, value > 10)}). Functions and formulas are evaluated
#'   at plot build time, before optional sampling.
#' @param shape Point shape. Default 19 (solid circle). Omitted values preserve
#'   mapped shapes; explicitly supplied values override mappings.
#' @param size Point size. Default 1. Omitted values preserve mapped sizes;
#'   explicitly supplied values override mappings.
#' @param white_border Logical. If \code{TRUE}, converts shapes to fillable
#'   versions (21-25) with white stroke, retaining scaled colours as fills.
#'   Other symbols retain their shape and colour over a white underlay.
#'   Default \code{FALSE}.
#' @param dodge.width Dodge width for grouped data. Default 0.8.
#'   Set to 0 to disable dodging.
#' @param jitter.args Named list of jitter arguments. Only used when
#'   \code{type = "jitter"}. Defaults: \code{list(width = 0.2, height = 0)}.
#'   Width and height must be non-negative numbers or \code{NULL} for native
#'   ggplot2 defaults.
#' @param beeswarm.args Named list of beeswarm arguments. Only used when
#'   \code{type = "beeswarm"}.
#'   Defaults: \code{list(cex = 3, corral = "wrap", corral.width = 0.5)}.
#'   Also accepts \code{method}, \code{side}, \code{priority}, \code{fast},
#'   \code{orientation}, \code{groupOnX}, \code{preserve.data.axis}, and
#'   \code{beeswarmArgs} when supported by ggbeeswarm. Values override the same
#'   arguments in \code{...}; use \code{dodge.width} to control dodging.
#' @param sample_n Non-negative integer or \code{NULL}. When set, subsample data
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
  shape_missing <- missing(shape)
  size_missing <- missing(size)
  if (!is.null(sample_n) &&
      (!is.numeric(sample_n) || length(sample_n) != 1L || !is.finite(sample_n) ||
       sample_n < 0 || sample_n != floor(sample_n))) {
    cli::cli_abort("{.arg sample_n} must be a non-negative integer or NULL.")
  }
  if (!is.null(sample_n) && !is.null(seed) &&
      (!is.numeric(seed) || length(seed) != 1L || !is.finite(seed) ||
       seed != floor(seed) || abs(seed) > .Machine$integer.max)) {
    cli::cli_abort("{.arg seed} must be a finite integer or NULL.")
  }
  for (name in c("white_border", "rasterize")) {
    value <- get(name)
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      cli::cli_abort("{.arg {name}} must be TRUE or FALSE.")
    }
  }
  if (!is.numeric(dodge.width) || length(dodge.width) != 1L ||
      !is.finite(dodge.width) || dodge.width < 0) {
    cli::cli_abort("{.arg dodge.width} must be one finite non-negative number.")
  }
  if (rasterize && (!is.numeric(rasterize.dpi) || length(rasterize.dpi) != 1L ||
      !is.finite(rasterize.dpi) || rasterize.dpi <= 0)) {
    cli::cli_abort("{.arg rasterize.dpi} must be one finite positive number.")
  }

  # Jitter defaults
  jit <- list(width = 0.2, height = 0)
  if (type == "jitter") {
    if (!is.list(jitter.args) ||
        (length(jitter.args) && (is.null(names(jitter.args)) ||
         anyNA(names(jitter.args)) || any(!nzchar(names(jitter.args))) ||
         anyDuplicated(names(jitter.args))))) {
      cli::cli_abort("{.arg jitter.args} must be a list with unique, non-empty names.")
    }
    if (length(setdiff(names(jitter.args), c("width", "height")))) {
      cli::cli_abort("{.arg jitter.args} only accepts width and height.")
    }
    jit <- utils::modifyList(jit, jitter.args, keep.null = TRUE)
    for (name in names(jit)) {
      value <- jit[[name]]
      if (!is.null(value) && (!is.numeric(value) || length(value) != 1L ||
          !is.finite(value) || value < 0)) {
        cli::cli_abort("{.arg jitter.args} {.val {name}} must be non-negative or NULL.")
      }
    }
  }
  if (type == "point") { jit$width <- 0; jit$height <- 0 }

  # Beeswarm defaults
  bee <- list(cex = 3, corral = "wrap", corral.width = 0.5)
  if (type == "beeswarm") {
    if (!requireNamespace("ggbeeswarm", quietly = TRUE)) {
      cli::cli_abort("Package {.pkg ggbeeswarm} is required for type='beeswarm'.")
    }
    if (!is.list(beeswarm.args) ||
        (length(beeswarm.args) && (is.null(names(beeswarm.args)) ||
         anyNA(names(beeswarm.args)) || any(!nzchar(names(beeswarm.args))) ||
         anyDuplicated(names(beeswarm.args))))) {
      cli::cli_abort("{.arg beeswarm.args} must be a list with unique, non-empty names.")
    }
    allowed <- intersect(c(setdiff(names(formals(ggbeeswarm::position_beeswarm)),
                                  "dodge.width"), "beeswarmArgs"),
                         names(formals(ggbeeswarm::geom_beeswarm)))
    unknown <- setdiff(names(beeswarm.args), allowed)
    if (length(unknown)) {
      cli::cli_abort("{.arg beeswarm.args} contains unsupported names: {.val {unknown}}.")
    }
    bee <- utils::modifyList(bee, beeswarm.args, keep.null = TRUE)
  }

  fmt_point_one <- function(p) {
    params <- list(size = size, shape = shape, ...)
    if ("color" %in% names(params) && !"colour" %in% names(params)) {
      params$colour <- params$color
      params$color <- NULL
    }
    layer_mapping <- if (isFALSE(params$inherit.aes)) list() else as.list(p$mapping)
    layer_mapping[names(params$mapping)] <- as.list(params$mapping)
    if (shape_missing && !is.null(layer_mapping$shape)) params$shape <- NULL
    if (size_missing && !is.null(layer_mapping$size)) params$size <- NULL
    for (aes_name in intersect(names(params), names(layer_mapping))) {
      if (!is.null(params[[aes_name]])) layer_mapping[[aes_name]] <- NULL
    }

    # --- Subsample data ---
    if (!is.null(sample_n)) {
      if (is.function(data) || rlang::is_formula(data)) {
        sampled_data <- function(d) .fmt_point_sample(data_fun(d), mapping, sample_n, seed)
        environment(sampled_data) <- list2env(list(
          .fmt_point_sample = .fmt_point_sample, data_fun = rlang::as_function(data),
          mapping = layer_mapping, sample_n = sample_n, seed = seed
        ), parent = baseenv())
        data <- sampled_data
      } else {
        data <- .fmt_point_sample(data %||% p$data, layer_mapping, sample_n, seed)
      }
    }

    # --- Compute position ---
    has_group <- any(c("group", "fill", "colour", "linetype", "shape", "size", "alpha") %in%
                       names(layer_mapping))

    if (type == "beeswarm") {
      position <- NULL
    } else if (dodge.width == 0 || !has_group) {
      if (isTRUE(jit$width == 0) && isTRUE(jit$height == 0)) {
        position <- ggplot2::position_identity()
      } else {
        position <- ggplot2::position_jitter(
          width = jit$width, height = jit$height, seed = 42
        )
      }
    } else {
      if (isTRUE(jit$width == 0) && isTRUE(jit$height == 0)) {
        position <- ggplot2::position_dodge(width = dodge.width, preserve = "total")
      } else {
        position <- ggplot2::position_jitterdodge(
          jitter.width = jit$width, jitter.height = jit$height,
          dodge.width = dodge.width, seed = 42
        )
        if (utils::packageVersion("ggplot2") < "4.0.0") {
          position <- do.call(ggplot2::ggproto, list(NULL, position,
            setup_params = .fmt_point_jitterdodge_setup), quote = TRUE, envir = baseenv())
        }
      }
      plain <- if (isTRUE(jit$width == 0) && isTRUE(jit$height == 0))
        ggplot2::position_identity() else
        ggplot2::position_jitter(width = jit$width, height = jit$height, seed = 42)
      position <- do.call(ggplot2::ggproto, list(NULL, ggplot2::Position,
        required_aes = c("x", "y"), dodge = position, plain = plain,
        explicit_group = !is.null(rlang::get_expr(layer_mapping[["group"]])),
        setup_params = .fmt_point_position_setup,
        compute_layer = .fmt_point_position_layer), quote = TRUE, envir = baseenv())
    }

    if (!is.null(data)) params$data <- data

    # --- White border ---
    if (white_border) {
      if ("color" %in% names(params)) {
        if ("colour" %in% names(params)) {
          cli::cli_abort("Supply only one of {.arg color} and {.arg colour}.")
        }
        params$colour <- params$color
        params$color <- NULL
      }
      border_mapping <- layer_mapping
      if (is.null(params$shape) && is.null(border_mapping$shape)) params$shape <- 19
      if (!is.null(params$shape)) params$shape <- .shape_convert(params$shape)
      if (!is.null(border_mapping$shape) || length(params$shape) > 0L) {
        if (!is.null(params$size)) params$size <- params$size * 1.5
        if (is.null(params$mapping)) params$mapping <- ggplot2::aes()
        if (!is.null(border_mapping$colour) && is.null(params$colour)) {
          colour_mapping <- border_mapping$colour
          args <- .fmt_point_stage_args(colour_mapping)
          if (is.null(params$fill) && is.null(border_mapping$fill)) {
            fill_expr <- args$after_scale %||% quote(colour)
            params$mapping$fill <- rlang::new_quosure(
              rlang::call2("after_scale", fill_expr, .ns = "ggplot2"),
              rlang::get_env(colour_mapping, default = baseenv())
            )
          }
          args$after_scale <- "#FFFFFF"
          params$mapping$colour <- rlang::new_quosure(
            rlang::call2("stage", !!!args, .ns = "ggplot2"),
            rlang::get_env(colour_mapping, default = baseenv())
          )
        } else {
          if (is.null(params$fill) && is.null(border_mapping$fill)) {
            params$fill <- params$colour %||% "black"
          }
          params$colour <- "#FFFFFF"
        }
        if (!is.null(border_mapping$shape)) {
          shape_mapping <- border_mapping$shape
          args <- .fmt_point_stage_args(shape_mapping)
          args$after_scale <- rlang::call2(
            ".fmt_point_shape", args$after_scale %||% quote(shape)
          )
          params$mapping$shape <- rlang::new_quosure(
            rlang::call2("stage", !!!args, .ns = "ggplot2"),
            rlang::env(rlang::get_env(shape_mapping, default = baseenv()),
                       .fmt_point_shape = .shape_convert)
          )
          params$shape <- NULL
        }
      }
    }

    # --- Create geom ---
    if (type == "beeswarm") {
      params$dodge.width <- dodge.width
      params[names(bee)] <- bee
      geom <- do.call(ggbeeswarm::geom_beeswarm, params)
    } else {
      params$position <- position
      geom <- do.call(ggplot2::geom_point, params)
    }
    if (white_border) {
      geom$geom <- do.call(ggplot2::ggproto, list(NULL, ggplot2::GeomPoint,
        draw_panel = .fmt_point_draw_panel, draw_key = .fmt_point_draw_key),
        quote = TRUE, envir = baseenv())
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

.fmt_point_sample <- function(data, mapping, sample_n, seed) {
  if (!is.data.frame(data)) {
    cli::cli_abort("Sampling requires {.arg data} to resolve to a data frame.")
  }
  if (nrow(data) <= sample_n) return(data)
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
  group_values <- NULL
  is_late <- function(expr) {
    if (!is.call(expr)) return(FALSE)
    if (rlang::call_name(expr) %in% c("after_stat", "after_scale", "stage", "from_theme"))
      return(TRUE)
    any(vapply(as.list(expr)[-1L], is_late, logical(1)))
  }
  for (aes_name in c("group", "colour", "fill")) {
    aesthetic <- mapping[[aes_name]]
    if (is.null(aesthetic)) next
    expr <- rlang::get_expr(aesthetic)
    if (is.call(expr) && identical(rlang::call_name(expr), "stage")) {
      expr <- .fmt_point_stage_args(aesthetic)$start
      if (is.null(expr)) next
      aesthetic <- rlang::new_quosure(expr, rlang::get_env(aesthetic, default = baseenv()))
    }
    if (is_late(expr)) next
    values <- rlang::eval_tidy(aesthetic, data = data)
    if (!is.null(values) &&
        (aes_name == "group" || is.factor(values) ||
         is.character(values) || is.logical(values))) {
      if (!length(values) %in% c(1L, nrow(data))) {
        cli::cli_abort("Sampling {.arg {aes_name}} must have length 1 or nrow(data).")
      }
      group_values <- rep_len(values, nrow(data))
      break
    }
  }
  if (!is.null(group_values)) {
    groups <- addNA(as.factor(group_values), ifany = TRUE)
    # Matrix columns retain rbind's existing class/dimname semantics.
    if (any(vapply(data, is.matrix, logical(1)))) {
      data <- do.call(rbind, lapply(split(data, groups), function(grp) {
        if (nrow(grp) <= sample_n) grp else
          grp[sample.int(nrow(grp), sample_n), , drop = FALSE]
      }))
      rownames(data) <- NULL
      return(data)
    }
    rows <- unlist(lapply(split(seq_len(nrow(data)), groups), function(indices) {
      if (length(indices) <= sample_n) indices else
        indices[sample.int(length(indices), sample_n)]
    }), use.names = FALSE)
    data <- data[rows, , drop = FALSE]
    rownames(data) <- NULL
    data
  } else {
    data <- data[sample.int(nrow(data), min(sample_n, nrow(data))), , drop = FALSE]
    rownames(data) <- NULL
    data
  }
}

#' @noRd
.shape_convert <- function(x) {
  shape_names <- c("square open" = 0, "circle open" = 1, "triangle open" = 2,
    "plus" = 3, "cross" = 4, "diamond open" = 5, "triangle down open" = 6,
    "square cross" = 7, "asterisk" = 8, "diamond plus" = 9, "circle plus" = 10,
    "star" = 11, "square plus" = 12, "circle cross" = 13, "square triangle" = 14,
    "triangle square" = 14, "square" = 15, "circle small" = 16, "triangle" = 17,
    "diamond" = 18, "circle" = 19, "bullet" = 20, "circle filled" = 21,
    "square filled" = 22, "diamond filled" = 23, "triangle filled" = 24,
    "triangle down filled" = 25)
  if (is.character(x) && length(x) && nchar(x[[1L]]) > 1L) {
    matched <- charmatch(x, names(shape_names))
    if (all(!is.na(matched) & matched > 0L)) x <- unname(shape_names[matched])
  }
  dict <- c("0" = 22, "15" = 22,
            "1" = 21, "16" = 21, "19" = 21, "20" = 21,
            "2" = 24, "17" = 24,
            "5" = 23, "18" = 23, "6" = 25)
  key <- as.character(x)
  converted <- unname(dict[key])
  if (all(!is.na(converted))) return(converted)
  x[!is.na(converted)] <- converted[!is.na(converted)]
  x
}

.fmt_point_draw_panel <- function(data, panel_params, coord, na.rm = FALSE) {
  base <- ggplot2::GeomPoint$draw_panel(data, panel_params, coord, na.rm = na.rm)
  foreground <- data[!data$shape %in% 21:25, , drop = FALSE]
  if (!nrow(foreground)) return(base)
  foreground$colour <- foreground$fill
  foreground$size <- foreground$size / 1.5
  grid::grobTree(base, ggplot2::GeomPoint$draw_panel(
    foreground, panel_params, coord, na.rm = na.rm))
}

.fmt_point_draw_key <- function(data, params, size) {
  base <- ggplot2::draw_key_point(data, params, size)
  if (data$shape %in% 21:25) return(base)
  data$colour <- data$fill
  data$size <- data$size / 1.5
  grid::grobTree(base, ggplot2::draw_key_point(data, params, size))
}

.fmt_point_jitterdodge_setup <- function(self, data) {
  if (!any(c("fill", "colour", "linetype", "shape", "size", "alpha") %in% names(data)))
    data$fill <- factor(data$group)
  ggplot2::ggproto_parent(ggplot2::PositionJitterdodge, self)$setup_params(data)
}

.fmt_point_position_setup <- function(self, data) {
  candidates <- intersect(c("fill", "colour", "linetype", "shape", "size", "alpha"), names(data))
  discrete <- vapply(data[candidates], function(x)
    is.factor(x) || is.character(x) || is.logical(x), logical(1))
  position <- if (self$explicit_group || any(discrete)) self$dodge else self$plain
  list(position = position, args = position$setup_params(data))
}

.fmt_point_position_layer <- function(data, params, layout) {
  params$position$compute_layer(data, params$args, layout)
}

.fmt_point_stage_args <- function(mapping) {
  expr <- rlang::get_expr(mapping)
  name <- if (is.call(expr)) rlang::call_name(expr) else NULL
  if (identical(name, "stage")) {
    return(as.list(match.call(ggplot2::stage, expr))[-1L])
  }
  if (identical(name, "after_stat")) return(list(after_stat = expr[[2L]]))
  if (identical(name, "after_scale")) return(list(after_scale = expr[[2L]]))
  list(start = expr)
}
