# Plot format utility helpers
# Internal helpers (.to_plot_list, .from_plot_list, .detect_scale_type)
# Exported: flatten_patchwork

# ---- Internal helpers ----

#' @noRd
.to_plot_list <- function(plot) {
  is_patchwork <- inherits(plot, "patchwork")
  is_single <- inherits(plot, "gg") && !is_patchwork

  if (is_single) {
    return(list(plots = list(plot), is_patchwork = FALSE, is_single = TRUE))
  }

  if (is_patchwork) {
    plots <- lapply(seq_along(plot), function(i) plot[[i]])
    return(list(plots = plots, is_patchwork = TRUE, is_single = FALSE))
  }

  if (is.list(plot)) {
    ok <- vapply(plot, inherits, logical(1), "gg")
    if (!all(ok)) cli::cli_abort("All elements in the list must be ggplot objects.")
    return(list(plots = plot, is_patchwork = FALSE, is_single = FALSE))
  }

  cli::cli_abort("Input must be a ggplot, patchwork, or list of ggplots.")
}

#' @noRd
.from_plot_list <- function(plot_list, was_patchwork, was_single, ...) {
  if (was_single) return(plot_list[[1]])
  if (was_patchwork) return(patchwork::wrap_plots(plot_list, ...))
  plot_list
}

#' @noRd
.detect_scale_type <- function(plot, axis = c("x", "y")) {
  axis <- match.arg(axis)
  existing_scales <- plot$scales$scales
  has_scale <- any(vapply(
    existing_scales,
    function(s) axis %in% s$aesthetics,
    logical(1)
  ))

  if (has_scale) {
    sc <- existing_scales[vapply(
      existing_scales,
      function(s) axis %in% s$aesthetics,
      logical(1)
    )][[1]]
    type <- if (inherits(sc, "ScaleDiscrete")) {
      "discrete"
    } else if (inherits(sc, c("ScaleDate", "ScaleDatetime"))) {
      "date"
    } else {
      "continuous"
    }
    return(paste0("scale_", axis, "_", type))
  }

  tryCatch({
    var_quo <- plot$mapping[[axis]]
    if (!is.null(var_quo) && !is.null(plot$data)) {
      d <- plot$data[[rlang::as_name(var_quo)]]
      if (is.factor(d) || is.character(d)) {
        return(paste0("scale_", axis, "_discrete"))
      } else if (inherits(d, c("Date", "POSIXct", "POSIXt"))) {
        return(paste0("scale_", axis, "_date"))
      }
    }
    paste0("scale_", axis, "_continuous")
  }, error = function(e) {
    paste0("scale_", axis, "_continuous")
  })
}

# ---- Exported ----

#' Flatten nested patchwork objects
#'
#' Recursively flatten nested patchwork objects into a single-level patchwork.
#'
#' @param plots A patchwork object (possibly nested) or a list of ggplot objects.
#' @param ... Arguments passed to [patchwork::wrap_plots()], e.g. `nrow`, `ncol`.
#' @param select_inds Integer vector of indices to keep after flattening.
#' @param nrow_inds_order Single integer to reorder plots by interleaving rows.
#'
#' @return A patchwork object with all sub-plots at one level.
#'
#' @examples
#' library(ggplot2)
#' library(patchwork)
#' p1 <- ggplot(mtcars, aes(mpg, disp)) + geom_point()
#' p2 <- ggplot(mtcars, aes(gear, disp, group = gear)) + geom_boxplot()
#' p3 <- ggplot(mtcars, aes(factor(gear))) + geom_bar()
#' p4 <- ggplot(mtcars, aes(factor(cyl), mpg)) + geom_violin()
#'
#' # Flatten nested patchwork
#' nested <- (p1 | p2) / (p3 | p4)
#' flatten_patchwork(nested, nrow = 1)
#'
#' # Select specific sub-plots
#' flatten_patchwork(nested, select_inds = c(1, 3))
#'
#' # Reorder by rows (column-first → row-first)
#' flatten_patchwork(nested, nrow_inds_order = 2, ncol = 2)
#'
#' @export
flatten_patchwork <- function(plots, ..., select_inds = NULL, nrow_inds_order = NULL) {
  flatten_recursive <- function(plot_obj) {
    if (inherits(plot_obj[[1]], "patchwork") && !inherits(plot_obj, "patchwork")) {
      plot_obj <- patchwork::wrap_plots(plot_obj)
    }
    if (!inherits(plot_obj, "patchwork")) return(list(plot_obj))
    unlist(lapply(plot_obj, flatten_recursive), recursive = FALSE)
  }

  all_subplots <- flatten_recursive(plots)

  if (!is.null(select_inds)) all_subplots <- all_subplots[select_inds]

  if (!is.null(nrow_inds_order) && length(nrow_inds_order) == 1L) {
    inds_order <- unlist(lapply(
      seq_len(nrow_inds_order),
      function(i) seq(i, length(all_subplots), by = nrow_inds_order)
    ))
    all_subplots <- all_subplots[inds_order]
  }

  patchwork::wrap_plots(all_subplots, ...)
}
