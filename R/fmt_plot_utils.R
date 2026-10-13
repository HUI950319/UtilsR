# =============================================================================
# fmt_plot_utils.R -- Shared plot-container helpers for the fmt_* family
# =============================================================================
#
# Architecture (1 layer; consumed by every formatter in fmt_plot.R):
#
#   L1  flatten_patchwork(plot)                     -- public API
#             flatten nested patchwork objects into a single grid
#
#   L2  .to_plot_list()        ggplot | patchwork | list -> list of ggplots
#       .from_plot_list()      list of ggplots -> original container type
#       .detect_scale_type()   classify x / y position scales
# =============================================================================

# ---- Internal helpers ----

#' @noRd
.map_plot_leaves <- function(plot, fun) {
  # An inset wrapping a patchwork is an overlay; a container ending in an
  # inset inherits its class but still owns ordinary grid cells.
  if (inherits(plot, "inset_patch") && (!inherits(plot, "patchwork") ||
      match("inset_patch", class(plot)) < match("patchwork", class(plot)))) return(plot)
  if (inherits(plot, "patchwork")) {
    free_settings <- attr(plot, "patchwork_free_settings")
    for (i in seq_along(plot)) plot[[i]] <- .map_plot_leaves(plot[[i]], fun)
    if (!is.null(free_settings)) {
      attr(plot, "patchwork_free_settings") <- free_settings
      class(plot) <- unique(c("free_plot", class(plot)))
    }
    return(plot)
  }
  # Indexing a patchwork's last plot also copies its container-only free class.
  if (inherits(plot, "free_plot") && is.null(attr(plot, "free_settings")) &&
      !is.null(attr(plot, "patchwork_free_settings"))) {
    attr(plot, "patchwork_free_settings") <- NULL
    class(plot) <- setdiff(class(plot), "free_plot")
  }
  if (inherits(plot, c("spacer", "guide_area", "inset_patch", "wrapped_patch"))) return(plot)
  if (is.list(plot) && !inherits(plot, "gg")) {
    return(lapply(plot, .map_plot_leaves, fun = fun))
  }
  fun(plot)
}

#' @noRd
.to_plot_list <- function(plot, recurse = FALSE) {
  if (recurse) {
    info <- .to_plot_list(plot)
    plots <- list()
    invisible(.map_plot_leaves(plot, function(p) {
      plots[[length(plots) + 1L]] <<- p
      p
    }))
    info$plots <- plots
    info$pw_orig <- plot
    return(info)
  }
  is_patchwork <- inherits(plot, "patchwork")
  is_single <- inherits(plot, "gg") && !is_patchwork

  if (is_single) {
    return(list(plots = list(plot), is_patchwork = FALSE, is_single = TRUE,
                pw_orig = NULL))
  }

  if (is_patchwork) {
    raw <- lapply(seq_along(plot), function(i) plot[[i]])
    # Keep only actual ggplot objects (skip layout/spacer elements)
    plots <- Filter(function(x) inherits(x, "gg"), raw)
    if (length(plots) == 0) {
      cli::cli_abort("Patchwork contains no ggplot objects.")
    }
    return(list(plots = plots, is_patchwork = TRUE, is_single = FALSE,
                pw_orig = plot))
  }

  if (is.list(plot)) {
    ok <- vapply(plot, inherits, logical(1), "gg")
    if (!all(ok)) cli::cli_abort("All elements in the list must be ggplot objects.")
    return(list(plots = plot, is_patchwork = FALSE, is_single = FALSE,
                pw_orig = NULL))
  }

  cli::cli_abort("Input must be a ggplot, patchwork, or list of ggplots.")
}

#' @noRd
.from_plot_list <- function(plot_list, was_patchwork, was_single, pw_orig = NULL,
                            recurse = FALSE, ...) {
  if (recurse) {
    i <- 0L
    return(.map_plot_leaves(pw_orig, function(p) {
      i <<- i + 1L
      plot_list[[i]]
    }))
  }
  if (was_single) return(plot_list[[1]])
  if (was_patchwork) {
    # In-place assignment preserves original layout (/, |, design, etc.)
    if (!is.null(pw_orig)) {
      free_settings <- attr(pw_orig, "patchwork_free_settings")
      # Map modified gg plots back to the correct positions in the patchwork
      gg_idx <- which(vapply(
        seq_along(pw_orig), function(i) inherits(pw_orig[[i]], "gg"), logical(1)
      ))
      for (j in seq_along(plot_list)) {
        if (j <= length(gg_idx)) {
          pw_orig[[gg_idx[j]]] <- plot_list[[j]]
        }
      }
      if (!is.null(free_settings)) {
        attr(pw_orig, "patchwork_free_settings") <- free_settings
        class(pw_orig) <- unique(c("free_plot", class(pw_orig)))
      }
      return(pw_orig)
    }
    return(patchwork::wrap_plots(plot_list, ...))
  }
  plot_list
}

#' @noRd
.detect_scale_type <- function(plot, axis = c("x", "y"), defer = FALSE) {
  axis <- match.arg(axis)
  sc <- plot$scales$get_scales(axis)
  if (!is.null(sc)) {
    type <- if (inherits(sc, "ScaleDiscrete")) {
      "discrete"
    } else if (inherits(sc, c("ScaleContinuousDatetime", "ScaleDatetime"))) {
      "datetime"
    } else if (inherits(sc, c("ScaleContinuousDate", "ScaleDate"))) {
      "date"
    } else if (identical(sc$trans$name, "hms")) {
      "time"
    } else {
      "continuous"
    }
    return(paste0("scale_", axis, "_", type))
  }

  mapping_is_late <- function(expr) {
    if (rlang::is_missing(expr)) return(FALSE)
    if (is.symbol(expr)) return(grepl("^\\.\\..+\\.\\.$", as.character(expr)))
    if (!is.call(expr)) return(FALSE)
    name <- rlang::call_name(expr)
    if (any(name %in% c("after_stat", "stat", "after_scale", "from_theme"))) return(TRUE)
    if (identical(name, "stage")) {
      start <- match.call(ggplot2::stage, expr)[["start"]]
      return(mapping_is_late(start))
    }
    any(vapply(as.list(expr)[-1L], mapping_is_late, logical(1)))
  }

  layers <- if (length(plot$layers)) plot$layers else list(NULL)
  for (layer in layers) {
    mapping <- as.list(plot$mapping)
    data <- plot$data
    if (!is.null(layer)) {
      mapping <- if (isTRUE(layer$inherit.aes)) {
        utils::modifyList(mapping, as.list(layer$mapping))
      } else as.list(layer$mapping)
      if (!is.null(layer$data) && !inherits(layer$data, "waiver")) data <- layer$data
    }
    var_quo <- mapping[[axis]]
    if (is.null(var_quo) || is.function(data)) next
    expr <- rlang::get_expr(var_quo)
    if (mapping_is_late(expr)) {
      if (defer) return(NULL)
      next
    }
    if (defer && is.call(expr)) {
      direct_column <- length(expr) == 3L &&
        any(rlang::call_name(expr) %in% c("$", "[[")) &&
        identical(expr[[2L]], as.name(".data")) && !is.call(expr[[3L]])
      if (!direct_column) return(NULL)
    }
    if (defer && is.symbol(expr) &&
        !(is.data.frame(data) && as.character(expr) %in% names(data))) {
      binding_env <- rlang::get_env(var_quo)
      while (!identical(binding_env, emptyenv())) {
        if (exists(as.character(expr), envir = binding_env, inherits = FALSE)) {
          if (bindingIsActive(as.character(expr), binding_env) ||
              rlang::env_binding_are_lazy(binding_env, as.character(expr))[[1L]])
            return(NULL)
          break
        }
        binding_env <- parent.env(binding_env)
      }
    }
    d <- tryCatch(
      rlang::eval_tidy(var_quo, data = if (is.data.frame(data)) data else NULL),
      error = function(e) {
        cli::cli_abort("Cannot infer the {axis}-axis scale from the mapping.", parent = e)
      }
    )
    if (length(d) == 0L) next
    if (defer && any(!class(d) %in% c(
      "factor", "ordered", "Date", "POSIXct", "POSIXlt", "POSIXt",
      "hms", "difftime", "numeric", "integer", "character", "logical"
    ))) return(NULL)
    if (is.factor(d) || is.character(d) || is.logical(d)) {
      return(paste0("scale_", axis, "_discrete"))
    } else if (inherits(d, "Date")) {
      return(paste0("scale_", axis, "_date"))
    } else if (inherits(d, c("POSIXct", "POSIXt"))) {
      return(paste0("scale_", axis, "_datetime"))
    } else if (inherits(d, "hms")) {
      return(paste0("scale_", axis, "_time"))
    }
    return(paste0("scale_", axis, "_continuous"))
  }
  if (defer) NULL else paste0("scale_", axis, "_continuous")
}

.scale_inference_parent <- function(scales) {
  do.call(ggplot2::ggproto,
          c(list(NULL), as.list(scales)[c("add_defaults", "add_missing")]),
          quote = TRUE, envir = baseenv())
}

.clone_plot_scales <- function(scales) {
  flatten <- function(original, copy) {
    parent <- original
    while (is.function(parent$super)) {
      candidate <- parent$super()
      if (!identical(class(candidate), class(original))) break
      parent <- candidate
    }
    fields <- list()
    object <- copy
    # Inherited as.list() does not propagate all.names to parent objects.
    repeat {
      own <- as.list(object, inherit = FALSE, all.names = TRUE)
      missing <- setdiff(names(own), names(fields))
      fields[missing] <- own[missing]
      if (!is.function(object$super)) break
      object <- object$super()
      if (is.null(object)) break
    }
    inherited <- as.list(parent, all.names = TRUE)
    fields <- fields[!vapply(names(fields), function(name) {
      is.function(fields[[name]]) && identical(fields[[name]], inherited[[name]])
    }, logical(1))]
    # Avoid evaluating stored calls or capturing this formatter's frame.
    result <- do.call(ggplot2::ggproto, c(list(NULL, parent), fields),
                      quote = TRUE, envir = baseenv())
    attributes(result) <- attributes(copy)
    result
  }
  copy <- scales$clone()
  copy$scales <- Map(flatten, scales$scales, copy$scales)
  if (!is.null(copy$.fmt_expand_parent))
    copy$.fmt_expand_parent <- .scale_inference_parent(copy$.fmt_expand_parent)
  flatten(scales, copy)
}

# Apply padding after ggplot2 selects a scale from actual layer values.
.add_expansion_defaults <- function(self, data, env) {
  .apply_deferred_scale_settings(self, "add_defaults", data, env)
}

.add_expansion_missing <- function(self, aesthetics, env) {
  .apply_deferred_scale_settings(self, "add_missing", aesthetics, env)
}

# ---- Exported ----

#' Flatten nested patchwork objects
#'
#' Recursively extract ordinary grid cells from nested patchwork objects and
#' arrange them in a new patchwork, optionally selecting or reordering cells.
#'
#' @param plots A ggplot, patchwork object, grob, or nested list of these objects.
#' @param ... Named layout arguments passed to
#'   \code{\link[patchwork:wrap_plots]{patchwork::wrap_plots()}},
#'   such as \code{nrow}, \code{ncol}, \code{design}, \code{guides} and
#'   \code{axis_titles}. Unknown, unnamed and duplicate arguments are rejected.
#'   Supply additional graphics in \code{plots} as a list.
#' @param select_inds Integer indices applied after flattening. Positive indices
#'   select and may repeat plots; negative indices exclude plots. Zero is ignored.
#'   Missing, fractional, mixed-sign and out-of-range indices are rejected.
#'   Duplicate cell names matched by a character \code{design} are rejected;
#'   use an unnamed list to repeat cells by position in that design.
#' @param nrow_inds_order Single positive integer, at most the number of selected
#'   plots, to reorder them by interleaving rows. Applied after selection; it does
#'   not set the output layout's \code{nrow}.
#'
#' @return A patchwork object with ordinary grid cells at one level. Insets and
#'   their main plot stay together and count as one cell for selection/reordering.
#'   Containers marked with \code{patchwork::free()} also remain intact.
#'
#' @details Top-level plot annotations and the \code{guides}, \code{axes},
#'   \code{axis_titles} and \code{tag_level} settings are retained for patchwork
#'   input. Explicit arguments in \code{...} override inherited settings.
#'   Grid geometry (dimensions, widths, heights and design) is rebuilt using
#'   \code{...}; nested annotation and tagging scopes are not promoted.
#'   Selection indices refer to the extracted cells, including spacers, guide
#'   areas and wrapped graphics. A main plot with its insets, or a protected
#'   \code{free()} container, occupies one selection index. Named list entries
#'   that produce one cell retain their name; names inside nested lists are
#'   retained without container-name prefixes. These cell names can be matched
#'   to a character layout design by \code{wrap_plots()}.
#'
#'   Insets are emitted alongside ordinary hosts at the same layout level,
#'   allowing shared axes and axis titles to be collected. Composite inset hosts
#'   remain intact. The returned object's \code{length()} and \code{[[} follow
#'   native patchwork child indexing and include inset objects; selection and
#'   row interleaving use complete cells, including each host's insets.
#'   Nested lists are unwrapped before binding each inset to its preceding host,
#'   so list and patchwork inputs retain the same inset boundaries.
#'
#'   Flattening ordinary containers removes their nested collection scopes,
#'   including inner \code{guides = "keep"} or \code{guides = "collect"} settings.
#'   Collection is determined by the retained top-level settings and \code{...}.
#'   Guide areas move to the same output level; when collecting guides,
#'   patchwork uses only the first guide area if several are present. Use
#'   \code{patchwork::wrap_elements(full = group)} to retain an entire group,
#'   including its nested collection scopes, as one wrapped cell.
#'
#' @family plot formatting
#'
#' @examples
#' library(ggplot2)
#' library(patchwork)
#' p1 <- ggplot(mtcars, aes(mpg, disp)) + geom_point()
#' p2 <- ggplot(mtcars, aes(gear, disp, group = gear)) + geom_boxplot()
#' p3 <- ggplot(mtcars, aes(factor(gear))) + geom_bar()
#' p4 <- ggplot(mtcars, aes(factor(cyl), mpg)) + geom_violin()
#'
#' \donttest{
#' # Flatten nested patchwork
#' nested <- (p1 | p2) / (p3 | p4)
#' flatten_patchwork(nested, nrow = 1)
#'
#' # Select specific sub-plots
#' flatten_patchwork(nested, select_inds = c(1, 3))
#'
#' # Interleave indices 1, 3, 2, 4, then arrange in two columns
#' flatten_patchwork(nested, nrow_inds_order = 2, ncol = 2)
#'
#' # Retain the overall title and collect matching axis titles
#' annotated <- nested + plot_annotation(title = "Example plots")
#' flatten_patchwork(annotated, ncol = 2, axis_titles = "collect")
#'
#' # Names determine placement in a character design
#' flatten_patchwork(list(B = p2, A = p1), design = "AB")
#'
#' # Keep a composite inset host together
#' inset_group <- wrap_plots(list(p1 | p2)) +
#'   inset_element(p3, .5, .5, 1, 1, align_to = "full")
#' flatten_patchwork(list(inset_group, p4), ncol = 2)
#'
#' # Retain a nested guide scope inside a wrapped cell
#' kept_group <- (p1 | p2) + plot_layout(guides = "keep")
#' flatten_patchwork(list(wrap_elements(full = kept_group), p3), guides = "collect")
#' }
#'
#' @export
flatten_patchwork <- function(plots, ..., select_inds = NULL, nrow_inds_order = NULL) {
  is_inset <- function(plot) {
    inherits(plot, "inset_patch") && (!inherits(plot, "patchwork") ||
      match("inset_patch", class(plot)) < match("patchwork", class(plot)))
  }
  is_free <- function(plot) {
    inherits(plot, "free_plot") && (!inherits(plot, "patchwork") ||
      match("free_plot", class(plot)) < match("patchwork", class(plot)))
  }
  flatten_lists <- function(plot_obj) {
    if (!is.list(plot_obj) || inherits(plot_obj, c("ggplot", "patchwork", "grob"))) {
      return(list(plot_obj))
    }
    unlist(lapply(seq_along(plot_obj), function(i) {
      children <- flatten_lists(plot_obj[[i]])
      if (length(children) == 1L && is.null(names(children)) &&
          !is.null(names(plot_obj)) && nzchar(names(plot_obj)[i])) {
        names(children) <- names(plot_obj)[i]
      }
      children
    }), recursive = FALSE)
  }
  flatten_recursive <- function(plot_obj) {
    if (is_inset(plot_obj)) cli::cli_abort("An inset must follow its main plot.")
    if (is_free(plot_obj)) {
      return(list(list(plot = plot_obj, insets = list())))
    }
    if (!inherits(plot_obj, "patchwork")) {
      if (inherits(plot_obj, c("ggplot", "grob"))) {
        return(list(list(plot = plot_obj, insets = list())))
      }
      if (!is.list(plot_obj)) {
        cli::cli_abort("Input must contain ggplot, patchwork, or grob objects.")
      }
      children <- flatten_lists(plot_obj)
    } else {
      children <- vector("list", length(plot_obj))
      for (i in seq_along(children)) {
        children[[i]] <- tryCatch(plot_obj[[i]], error = function(e) {
          cli::cli_abort("Cannot read patchwork child {i}.", parent = e)
        })
      }
    }
    n <- length(children)
    cells <- list()
    i <- 1L
    while (i <= n) {
      child <- children[[i]]
      if (is_inset(child)) cli::cli_abort("An inset must follow its main plot.")
      next_i <- i + 1L
      insets <- list()
      while (next_i <= n && is_inset(children[[next_i]])) {
        insets <- c(insets, children[next_i])
        next_i <- next_i + 1L
      }
      child_cells <- if (length(insets)) {
        list(list(plot = child, insets = insets))
      } else flatten_recursive(child)
      if (length(child_cells) == 1L && is.null(names(child_cells)) &&
          !is.null(names(children)) && nzchar(names(children)[i])) {
        names(child_cells) <- names(children)[i]
      }
      cells <- c(cells, child_cells)
      i <- next_i
    }
    cells
  }

  all_subplots <- flatten_recursive(plots)

  if (!is.null(select_inds)) {
    if (!is.numeric(select_inds) || is.complex(select_inds) ||
        !is.null(dim(select_inds)) || any(!is.finite(select_inds)) ||
        any(select_inds != trunc(select_inds)) ||
        any(abs(select_inds) > length(all_subplots)) ||
        (any(select_inds < 0) && any(select_inds > 0))) {
      cli::cli_abort("{.arg select_inds} must contain finite integer indices within the plot range, without mixing positive and negative indices.")
    }
    all_subplots <- all_subplots[select_inds]
  }
  if (length(all_subplots) == 0L) {
    cli::cli_abort("There are no plots to arrange after flattening and selection.")
  }

  if (!is.null(nrow_inds_order)) {
    if (!is.numeric(nrow_inds_order) || is.complex(nrow_inds_order) ||
        !is.null(dim(nrow_inds_order)) || length(nrow_inds_order) != 1L ||
        !is.finite(nrow_inds_order) || nrow_inds_order != trunc(nrow_inds_order) ||
        nrow_inds_order < 1 || nrow_inds_order > length(all_subplots)) {
      cli::cli_abort("{.arg nrow_inds_order} must be a single positive integer no larger than the number of selected plots.")
    }
    inds_order <- unlist(lapply(
      seq_len(nrow_inds_order),
      function(i) seq(i, length(all_subplots), by = nrow_inds_order)
    ))
    all_subplots <- all_subplots[inds_order]
  }

  layout_args <- list()
  annotation <- NULL
  if (inherits(plots, "patchwork") && !is_free(plots)) {
    annotation <- plots$patches$annotation
    layout_args <- plots$patches$layout[c("guides", "axes", "axis_titles", "tag_level")]
    layout_args <- layout_args[!vapply(layout_args, is.null, logical(1))]
  }
  dots <- list(...)
  if (length(dots)) {
    dot_names <- names(dots)
    if (is.null(dot_names) || any(is.na(dot_names) | !nzchar(dot_names))) {
      cli::cli_abort("All arguments in {.code ...} must be named layout controls; supply additional graphics in {.arg plots} as a list.")
    }
    if (anyDuplicated(dot_names)) {
      cli::cli_abort("Layout control names in {.code ...} must be unique.")
    }
    allowed <- setdiff(names(formals(patchwork::wrap_plots)), "...")
    unknown <- setdiff(dot_names, allowed)
    if (length(unknown)) {
      cli::cli_abort("Unknown layout control in {.code ...}: {.arg {unknown}}.")
    }
  }
  if (is.character(dots$design) && !is.null(names(all_subplots))) {
    area_names <- sort(setdiff(unique(trimws(strsplit(dots$design, "")[[1]])), c("", "#")))
    if (all(names(all_subplots) %in% area_names)) {
      if (anyDuplicated(names(all_subplots))) {
        cli::cli_abort("Cell names must be unique when matched to a character {.arg design}; use an unnamed list to repeat cells by position.")
      }
      named_cells <- vector("list", length(area_names))
      names(named_cells) <- area_names
      named_cells[names(all_subplots)] <- all_subplots
      named_cells[vapply(named_cells, is.null, logical(1))] <-
        list(list(plot = patchwork::plot_spacer(), insets = list()))
      all_subplots <- named_cells
    }
  }
  plot_objects <- unlist(lapply(all_subplots, function(cell) {
    c(list(cell$plot), cell$insets)
  }), recursive = FALSE, use.names = FALSE)
  layout_args <- layout_args[setdiff(names(layout_args), names(dots))]
  result <- do.call(patchwork::wrap_plots, c(list(plot_objects), layout_args, dots))
  if (!is.null(annotation)) result <- result + annotation
  result
}

# NOTE: `.resolve_theme()` moved to utils-resolve.R (shared `.resolve_*` family).
