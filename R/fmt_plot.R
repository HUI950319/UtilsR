# =============================================================================
# fmt_plot.R -- ggplot / patchwork post-formatting family
# =============================================================================
#
# Architecture (2 layers). Every formatter takes a plot and returns the same
# container type, so they compose freely in a pipe.
#
#   L1  fmt_plot(plot, fmt_axis_list, fmt_tag_list, fmt_legend_list,
#         |       fmt_ref_list, plot.margin, tag_levels, axis_titles, ...)
#         |                                         -- master orchestrator
#         +-- rlang::exec(fmt_axis,   !!!fmt_axis_list)
#         +-- rlang::exec(fmt_tag,    !!!fmt_tag_list)
#         +-- rlang::exec(fmt_legend, !!!fmt_legend_list)
#         +-- rlang::exec(fmt_ref,    !!!fmt_ref_list)
#
#   L1  standalone formatters (public, usable without fmt_plot)
#         axes     fmt_axis / fmt_axisText / fmt_axisTile / fmt_scale /
#                  fmt_expand
#         labels   fmt_tag / fmt_text / fmt_strip / fmt_strip2
#         panel    fmt_panel / fmt_bg / fmt_plot_base
#         legend   fmt_legend
#         layers   fmt_ref / fmt_com / fmt_his / fmt_boxplot
#
#   L2  internals
#         .resolve_tag_position()      tag keyword -> panel coordinates
#         .axis_tile_guide()           style trained discrete axis guides
#         .axis_tile_facet()           attach panel-relative color strips
#
# The container helpers (.to_plot_list / .from_plot_list /
# flatten_patchwork) live in fmt_plot_utils.R, which is why every formatter
# accepts a ggplot, a patchwork or a plain list of plots.
# =============================================================================

# ---- fmt_axis ----

#' Hide axis elements for specific plots
#'
#' Selectively hide axis text, ticks, and titles for plots in a multi-plot
#' layout. Useful for removing redundant axes when plots share the same scale.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects. Editable plots are
#'   numbered recursively in their input order. Spacers, guide areas, inset
#'   overlays and fixed wrapped graphics do not consume indices. Format the
#'   original ggplot before using
#'   \code{\link[patchwork:wrap_elements]{patchwork::wrap_elements()}} to hide its axes.
#' @param x.axis Logical scalar or integer vector. `FALSE` (default) keeps the
#'   current x-axes; it does not restore previously hidden elements. `TRUE` hides
#'   the x-axis of a single plot, or all but the last editable plot in a container.
#'   An integer vector specifies
#'   which plot indices should have their x-axis hidden. Indices must be finite
#'   positive integers within the editable plot count; duplicates are applied once.
#'   `NULL` and an empty integer vector keep the current axes.
#' @param y.axis Logical scalar or integer vector. `FALSE` (default) keeps the
#'   current y-axes. `TRUE` hides the y-axis of a single plot, or all but the first
#'   editable plot in a container. An integer vector specifies
#'   which plot indices should have their y-axis hidden. Index validation and
#'   empty selections follow `x.axis`.
#' @param plot_dims Integer vector of length 1 or 2 giving `c(nrow, ncol)` of
#'   the layout. When provided, automatically determines which axes to hide:
#'   x-axes are hidden for all rows except the last, y-axes for all columns
#'   except the first. Patchwork positions follow the existing layout, including
#'   column-major filling, empty cells, nested grids and spanning design areas;
#'   `plot_dims` does not rearrange the plots. Insets do not occupy grid cells.
#'   Lists retain cells occupied by spacers, guide areas and fixed graphics,
#'   and nested containers retain their own layout. Dimensions must be finite
#'   positive integers with enough cells for the editable plots in a patchwork,
#'   or for the top-level grid entries in a list.
#'   A single value specifies the number of rows; columns are inferred. Empty
#'   trailing rows do not remove the x-axes of the last occupied row.
#'   When provided, layout-based selection overrides both `x.axis` and `y.axis`,
#'   including one-row and one-column layouts. Manual selectors are still validated.
#'
#' @details Hiding applies to axis text, major/minor ticks and titles on both
#'   sides, including secondary axes and guide-local themes. Guide settings
#'   unrelated to hiding are retained, and input guide objects are not modified.
#'   For \code{\link[ggplot2:coord_radial]{ggplot2::coord_radial()}}, `x.axis`
#'   controls the angular (theta) axis and `y.axis` the radius (r) axis, following
#'   ggplot2 theme inheritance regardless of the variable mapped to theta.
#'   Axis lines, data, scales, coordinates and
#'   facet structure are retained. The function does not verify or synchronize
#'   scales between plots; use automatic selection only for axes that can be
#'   meaningfully shared. Selections operate on whole plots, including all facets.
#'
#' @return Same type as input (ggplot, patchwork, or list), with list names,
#'   patchwork layout and annotations retained. Empty selections return the input.
#'
#' @examples
#' library(ggplot2)
#' data <- data.frame(x = rep(1:5, 2), y = c(1, 3, 2, 4, 3, 2, 4, 3, 5, 4),
#'                    group = rep(c("A", "B"), each = 5))
#' p1 <- ggplot(data, aes(x, y, colour = group)) + geom_point()
#' p2 <- ggplot(data, aes(x, y, colour = group)) + geom_line()
#'
#' # Hide the x-axis of a single plot
#' fmt_axis(p1, x.axis = TRUE)
#'
#' # Hide x-axis on first plot
#' fmt_axis(list(p1, p2), x.axis = 1)
#'
#' # Keep only the bottom row's x-axis in a two-row layout
#' fmt_axis(list(p1, p2), plot_dims = c(2, 1))
#'
#' # Follow the actual column-major patchwork layout
#' combined <- patchwork::wrap_plots(p1, p2, p1, p2, nrow = 2, byrow = FALSE)
#' fmt_axis(combined, plot_dims = c(2, 2))
#'
#' @export
#' @family plot formatting
fmt_axis <- function(plot, x.axis = FALSE, y.axis = FALSE, plot_dims = NULL) {
  empty_axis <- function(x) {
    is.null(x) || isFALSE(x) ||
      (typeof(x) %in% c("integer", "double") && !is.object(x) && !length(x))
  }
  no_axes <- is.null(plot_dims) && empty_axis(x.axis) && empty_axis(y.axis)
  info <- .to_plot_list(plot, recurse = !no_axes)
  plots <- info$plots
  n <- length(plots)
  cell_count <- n
  if (!is.null(plot_dims) && !info$is_patchwork && !info$is_single) {
    cell_count <- sum(vapply(plot, function(p) {
      !(inherits(p, "inset_patch") && (!inherits(p, "patchwork") ||
          match("inset_patch", class(p)) < match("patchwork", class(p))))
    }, logical(1)))
  }
  valid_dims <- function(x, lengths) {
    typeof(x) %in% c("integer", "double") && !is.object(x) &&
      length(x) %in% lengths && !anyNA(x) && all(is.finite(x)) &&
      all(x > 0 & x == floor(x) & x <= .Machine$integer.max)
  }
  if (!is.null(plot_dims) && !valid_dims(plot_dims, 1:2)) {
    cli::cli_abort("{.arg plot_dims} must contain one or two finite positive integers.")
  }
  if (!is.null(plot_dims) && length(plot_dims) == 2L && prod(plot_dims) < cell_count) {
    cli::cli_abort("{.arg plot_dims} has too few cells for the plots.")
  }
  check_axis <- function(x, arg) {
    if (is.null(x) || isTRUE(x) || isFALSE(x)) return(invisible(NULL))
    if (!(typeof(x) %in% c("integer", "double")) || is.object(x) ||
        anyNA(x) || any(!is.finite(x)) || any(x < 1 | x != floor(x))) {
      cli::cli_abort("{.arg {arg}} must be TRUE, FALSE, NULL or finite positive integer plot indices.")
    }
    if (any(x > n)) {
      cli::cli_abort("{.arg {arg}} indices exceed the number of editable plots ({n}).")
    }
  }
  check_axis(x.axis, "x.axis")
  check_axis(y.axis, "y.axis")
  if (n == 0L || no_axes) return(plot)

  # When plot_dims is provided, compute which axes to hide

  if (!is.null(plot_dims)) {
    if (length(plot_dims) == 1L) {
      nr <- plot_dims[1]
      nc <- ceiling(cell_count / nr)
    } else {
      nr <- plot_dims[1]
      nc <- plot_dims[2]
    }

    # Read cell positions without drawing the plots. Insets do not occupy cells.
    positions <- list()
    collect_positions <- function(children, lay, bounds = c(0, 0, 1, 1)) {
      insets <- vapply(children, function(p) {
        inherits(p, "inset_patch") && (!inherits(p, "patchwork") ||
          match("inset_patch", class(p)) < match("patchwork", class(p)))
      }, logical(1))
      children <- children[!insets]
      count <- length(children)
      if (!count) return(invisible(NULL))
      areas <- lay$design
      if (is.null(areas)) {
        rows <- lay$nrow
        cols <- lay$ncol
        if ((!is.null(rows) && !valid_dims(rows, 1L)) ||
            (!is.null(cols) && !valid_dims(cols, 1L))) {
          cli::cli_abort("Patchwork layout dimensions must be finite positive integers.")
        }
        if (is.null(cols) && length(lay$widths) > 1L) cols <- length(lay$widths)
        if (is.null(rows) && length(lay$heights) > 1L) rows <- length(lay$heights)
        if (is.null(rows) && is.null(cols)) {
          dims <- grDevices::n2mfrow(count)
          rows <- dims[2L]
          cols <- dims[1L]
        } else if (is.null(rows)) {
          rows <- ceiling(count / cols)
        } else if (is.null(cols)) {
          cols <- ceiling(count / rows)
        }
        if (rows * cols < count) {
          cli::cli_abort("The patchwork layout has too few cells for its plots.")
        }
        index <- seq_len(count) - 1L
        byrow <- is.null(lay$byrow) || isTRUE(lay$byrow)
        row <- if (byrow) index %/% cols + 1L else index %% rows + 1L
        col <- if (byrow) index %% cols + 1L else index %/% rows + 1L
        areas <- data.frame(t = row, l = col, b = row, r = col)
      } else {
        areas <- data.frame(t = areas$t, l = areas$l, b = areas$b, r = areas$r)
        if (nrow(areas) < count) {
          cli::cli_abort("The patchwork design has too few areas for its plots.")
        }
        rows <- max(areas$b)
        cols <- max(areas$r)
      }
      for (i in seq_len(count)) {
        area <- unlist(areas[i, c("t", "l", "b", "r")], use.names = FALSE)
        cell <- (area - c(1, 1, 0, 0)) / c(rows, cols, rows, cols)
        cell <- bounds[c(1, 2, 1, 2)] + cell *
          (bounds[c(3, 4, 3, 4)] - bounds[c(1, 2, 1, 2)])
        p <- children[[i]]
        if (inherits(p, "patchwork")) {
          collect_positions(lapply(seq_along(p), function(j) p[[j]]),
                            p$patches$layout, cell)
        } else if (!inherits(p, c("spacer", "guide_area", "wrapped_patch"))) {
          positions[[length(positions) + 1L]] <<- cell
        }
      }
    }
    if (info$is_patchwork) {
      collect_positions(lapply(seq_along(plot), function(i) plot[[i]]),
                        plot$patches$layout)
    } else {
      collect_positions(if (info$is_single) list(plot) else plot,
                        list(nrow = nr, ncol = nc))
    }
    if (length(positions) != n) {
      cli::cli_abort("Automatic axis placement cannot map this container's inset plots.")
    }
    positions <- do.call(rbind, positions)
    tolerance <- 16 * .Machine$double.eps
    x.axis <- which(positions[, 3L] < max(positions[, 3L]) - tolerance)
    y.axis <- which(positions[, 2L] > min(positions[, 2L]) + tolerance)
  }

  # Resolve indices to hide
  resolve_idx <- function(axis_arg, default_true) {
    if (isFALSE(axis_arg) || is.null(axis_arg)) return(integer(0))
    if (isTRUE(axis_arg)) return(default_true)
    unique(as.integer(axis_arg))
  }

  idx_x <- resolve_idx(x.axis, if (n > 1L) seq_len(n - 1L) else 1L)
  idx_y <- resolve_idx(y.axis, if (n > 1L) 2L:n else 1L)
  if (!length(idx_x) && !length(idx_y)) return(plot)

  hide_theme <- function(axis) {
    sides <- if (axis == "x") c("bottom", "top") else c("left", "right")
    radial_axis <- if (axis == "x") "theta" else "r"
    elements <- paste0("axis.", c("text", "ticks", "title"), ".", axis)
    blank_names <- c(elements, as.vector(outer(
      c(elements, paste0("axis.minor.ticks.", axis)), sides, paste, sep = "."
    )), paste0("axis.", c("text", "ticks", "minor.ticks"), ".", radial_axis))
    length_names <- c(paste0("axis.ticks.length.", axis),
                      paste0("axis.ticks.length.", axis, ".", sides),
                      paste0("axis.minor.ticks.length.", axis, ".", sides),
                      paste0("axis.", c("ticks.length", "minor.ticks.length"),
                             ".", radial_axis))
    args <- c(
      stats::setNames(rep(list(ggplot2::element_blank()), length(blank_names)),
                      blank_names),
      stats::setNames(rep(list(grid::unit(0, "pt")), length(length_names)),
                      length_names)
    )
    # Keep compatibility with ggplot2 versions without minor-tick elements.
    args <- args[names(args) %in% names(ggplot2::get_element_tree())]
    do.call(ggplot2::theme, args)
  }
  hide_x_theme <- if (length(idx_x)) hide_theme("x") else NULL
  hide_y_theme <- if (length(idx_y)) hide_theme("y") else NULL
  hide_x <- seq_len(n) %in% idx_x
  hide_y <- seq_len(n) %in% idx_y
  hide_both_theme <- if (any(hide_x & hide_y)) hide_x_theme + hide_y_theme else NULL
  hide_guide_theme <- function(guide, axis_theme) {
    if (!inherits(guide, "Guide") || is.null(guide$params$theme)) return(guide)
    params <- guide$params
    params$theme <- params$theme + axis_theme
    ggplot2::ggproto(NULL, guide, params = params)
  }
  for (i in which(hide_x | hide_y)) {
    axis_theme <- if (hide_x[i] && hide_y[i]) hide_both_theme else
      if (hide_x[i]) hide_x_theme else hide_y_theme
    p <- plots[[i]] + axis_theme
    axes <- c(if (hide_x[i]) "x", if (hide_y[i]) "y")
    radial <- inherits(p$coordinates, "CoordRadial")
    guide_axes <- if (radial) {
      c(if (hide_x[i]) "theta", if (hide_y[i]) "r")
    } else axes
    scale_axes <- if (radial) {
      c(if (hide_x[i]) p$coordinates$theta, if (hide_y[i]) p$coordinates$r)
    } else axes
    guide_names <- c(guide_axes, paste0(guide_axes, ".sec"))
    if (inherits(p$guides, "Guides")) {
      guides <- p$guides$guides
      selected <- intersect(names(guides), guide_names)
      guides[selected] <- lapply(guides[selected], hide_guide_theme, axis_theme = axis_theme)
      if (!identical(guides, p$guides$guides)) {
        # Supply the prototype by value before replacing the plot's container.
        p$guides <- do.call(ggplot2::ggproto, list(NULL, p$guides, guides = guides))
      }
    }
    scales <- lapply(p$scales$scales, function(scale) {
      if (!any(scale_axes %in% scale$aesthetics)) return(scale)
      guide <- hide_guide_theme(scale$guide, axis_theme)
      secondary <- scale$secondary.axis
      secondary_guide <- if (!is.null(secondary)) {
        hide_guide_theme(secondary$guide, axis_theme)
      } else NULL
      if (identical(guide, scale$guide) &&
          identical(secondary_guide, if (!is.null(secondary)) secondary$guide else NULL)) {
        return(scale)
      }
      if (!is.null(secondary) && !identical(secondary_guide, secondary$guide)) {
        secondary <- do.call(ggplot2::ggproto,
                             list(NULL, secondary, guide = secondary_guide))
      }
      ggplot2::ggproto(NULL, scale, guide = guide, secondary.axis = secondary)
    })
    if (!identical(scales, p$scales$scales)) {
      p$scales <- do.call(ggplot2::ggproto, list(NULL, p$scales, scales = scales))
    }
    plots[[i]] <- p
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig,
                  recurse = TRUE)
}

# ---- fmt_tag helpers ----

# Resolve label_position to a list(x, y, outside).
# Accepts numeric length-2 NPC pair OR keyword strings:
#   "tl"/"tr"/"bl"/"br"            -> inside corners
#   "tl-out"/"tr-out"/...          -> outside corners (underscore aliases ok)
.resolve_tag_position <- function(label_position) {
  map <- list(
    "tl"     = list(x = 0.02, y = 0.98, outside = FALSE),
    "tr"     = list(x = 0.98, y = 0.98, outside = FALSE),
    "bl"     = list(x = 0.02, y = 0.02, outside = FALSE),
    "br"     = list(x = 0.98, y = 0.02, outside = FALSE),
    "tl-out" = list(x = 0,    y = 1,    outside = TRUE),
    "tr-out" = list(x = 1,    y = 1,    outside = TRUE),
    "bl-out" = list(x = 0,    y = 0,    outside = TRUE),
    "br-out" = list(x = 1,    y = 0,    outside = TRUE)
  )

  if (is.character(label_position) && length(label_position) == 1L) {
    key <- gsub("_", "-", tolower(label_position))
    if (key %in% names(map)) return(map[[key]])
    cli::cli_abort(c(
      "Unknown {.arg label_position} keyword {.val {label_position}}.",
      i = "Valid keywords: {.val {names(map)}}."
    ))
  }

  if (is.numeric(label_position) && length(label_position) == 2L &&
      all(is.finite(label_position)) && all(label_position >= 0 & label_position <= 1)) {
    return(list(x = label_position[1], y = label_position[2], outside = FALSE))
  }

  cli::cli_abort(c(
    "{.arg label_position} must be a finite numeric length-2 NPC pair in [0, 1] or a keyword string.",
    i = "Valid keywords: {.val {names(map)}}."
  ))
}

# ---- fmt_tag ----

#' Add panel labels to plots
#'
#' Add boxed labels to data plots using [ggpp::geom_label_npc()] inside panels
#' or [patchwork::inset_element()] at the corners of whole plots. Nested plots
#' are labelled in leaf order; spacers, guide areas and insets are skipped.
#' Fixed graphics created by [patchwork::wrap_elements()] are skipped with a
#' warning, without consuming labels.
#'
#' @param plot A ggplot, patchwork, or list of these objects.
#' @param labels Non-empty character vector without missing or blank labels.
#'   If `NULL` (default), uses A through Z, then AA, AB and so on. Short vectors
#'   are recycled with a warning; excess labels are ignored.
#' @param label_position Placement of the label. Accepts either:
#'   \itemize{
#'     \item Finite numeric length-2 vector `c(x, y)` in NPC, both values in
#'       `[0, 1]` — drawn inside the panel (default `c(0.02, 0.98)`).
#'     \item Keyword for inside corners: `"tl"`, `"tr"`, `"bl"`, `"br"`.
#'     \item Keyword for outside corners (a boxed label at the corner of the
#'       whole plot, drawn as a
#'       full-plot [patchwork::inset_element()]):
#'       `"tl-out"`, `"tr-out"`, `"bl-out"`, `"br-out"`. Underscore
#'       variants (`"tl_out"` etc.) are also accepted.
#'   }
#'   Both placements use a box styled by `label.size`,
#'   `label.padding` and `label.r`; `...` only applies to inside placements.
#'   Inside positions refer to the displayed panel, including flipped and
#'   non-linear coordinates.
#'   Invalid positions raise an error.
#' @param size Positive finite numeric label sizes in points, recycled over
#'   data plots. Default 18.
#' @param color R colour specifications for text and borders, recycled over
#'   data plots. Numeric palette colours are supported; `NA` is transparent.
#'   Default `"black"`.
#' @param fontface One font face: `"plain"`, `"bold"`, `"italic"`,
#'   `"bold.italic"`, `"symbol"`, or the corresponding number from 1 to 5.
#'   Default `"bold"`.
#' @param label.size One finite non-negative border width in mm. Zero removes
#'   the border. Default 1.
#' @param label.padding Padding around the label text, a [grid::unit()]
#'   vector with finite non-negative values and length 1, 2 or 4. Values are
#'   recycled to top, right, bottom, left; two values set top/bottom and
#'   right/left respectively. Asymmetric padding is honoured in both modes.
#'   Default `unit(c(0.2, 0.3, 0.2, 0.3), "lines")`.
#' @param label.r One finite non-negative [grid::unit()] corner radius.
#'   Default `unit(0.2, "lines")`.
#' @param ... Additional inside-label arguments passed to
#'   [ggpp::geom_label_npc()], such as `fill`, `alpha`, `family` or `parse`.
#'   Ignored when an `-out` keyword is used.
#'
#' @details Repeated calls replace only labels created by `fmt_tag()`, preserving
#'   user annotations and insets. Inside labels repeat the same plot label in
#'   each native facet; outside labels appear once per data plot. Containers
#'   without data plots are returned unchanged without validating styling.
#'   Axis, legend, reference-line and strip formatters operate on the data plots
#'   without counting outside-label insets.
#'   Compound padding and radius units are checked in both dimensions at the
#'   label font sizes on a 7 by 7 inch reference viewport. Simple units retain
#'   their usual relative semantics without opening a device.
#'   Existing patchwork automatic tag levels are preserved with a conflict
#'   warning, since these labels belong to the input rather than `fmt_tag()`.
#'
#' @return Same type as input. With an `-out` keyword each ggplot carries
#'   the label as a patchwork inset, so a single ggplot comes back as a
#'   (single-plot) patchwork. Replacing an outside tag with an inside tag removes
#'   a container created solely for the old tag.
#'
#' @examples
#' library(ggplot2)
#' library(patchwork)
#' d <- data.frame(x = 1:5, y = c(2, 4, 3, 5, 6), z = c(5, 3, 4, 2, 1))
#' p1 <- ggplot(d, aes(x, y)) + geom_point()
#' p2 <- ggplot(d, aes(x, z)) + geom_point()
#'
#' # Auto-label A, B (inside panel, top-left)
#' fmt_tag(list(p1, p2))
#'
#' # Custom labels
#' fmt_tag(list(p1, p2), labels = c("i", "ii"))
#'
#' # Inside, top-right corner via keyword
#' fmt_tag(list(p1, p2), label_position = "tr")
#'
#' # Outside the panel, top-left corner of the entire plot
#' fmt_tag(list(p1, p2), label_position = "tl-out")
#'
#' # Label nested data plots while skipping the spacer
#' nested <- (p1 | plot_spacer()) / (p2 | p1)
#' fmt_tag(nested)
#'
#' # Replace an outside tag with an inside tag
#' outside <- fmt_tag(p1, "A", label_position = "tl-out",
#'                    label.padding = grid::unit(0.3, "lines"))
#' fmt_tag(outside, "B", label_position = "br")
#'
#' @export
#' @family plot formatting
fmt_tag <- function(plot,
                    labels = NULL,
                    label_position = c(0.02, 0.98),
                    size = 18,
                    color = "black",
                    fontface = "bold",
                    label.size = 1,
                    label.padding = grid::unit(c(0.2, 0.3, 0.2, 0.3), "lines"),
                    label.r = grid::unit(0.2, "lines"),
                    ...) {
  wrapped <- FALSE
  automatic <- FALSE
  clear_tags <- function(p) {
    if (inherits(p, "patchwork")) {
      if (length(p$patches$annotation$tag_levels)) automatic <<- TRUE
      free_settings <- attr(p, "patchwork_free_settings")
      children <- lapply(seq_along(p), function(j) p[[j]])
      keep <- !vapply(children, function(child) {
        !inherits(child, "patchwork") && inherits(child, "inset_patch") &&
          isTRUE(attr(child, ".fmt_tag_generated"))
      }, logical(1))
      if (all(keep)) {
        for (j in seq_along(p)) p[[j]] <- clear_tags(children[[j]])
        if (!is.null(free_settings)) {
          attr(p, "patchwork_free_settings") <- free_settings
          class(p) <- unique(c("free_plot", class(p)))
        }
        return(p)
      }
      children <- lapply(children[keep], clear_tags)
      if (length(children) == 1L && all(lengths(p$patches$layout) == 0L) &&
          all(lengths(p$patches$annotation) == 0L) &&
          is.null(free_settings)) return(children[[1]])
      restored <- patchwork::wrap_plots(children)
      restored$patches$layout <- p$patches$layout
      restored$patches$annotation <- p$patches$annotation
      if (!is.null(free_settings)) {
        attr(restored, "patchwork_free_settings") <- free_settings
        class(restored) <- unique(c("free_plot", class(restored)))
      }
      return(restored)
    }
    if (inherits(p, "gg")) {
      if (inherits(p, c("spacer", "guide_area", "inset_patch"))) return(p)
      if (inherits(p, "wrapped_patch")) wrapped <<- TRUE
      p$layers <- Filter(function(layer) !isTRUE(attr(layer, ".fmt_tag_generated")),
                          p$layers)
      return(p)
    }
    if (is.list(p)) return(lapply(p, clear_tags))
    p
  }
  plot <- clear_tags(plot)
  if (wrapped) cli::cli_warn("Wrapped plots are skipped; only editable data plots receive tags.")
  info <- .to_plot_list(plot)
  map_leaves <- .map_plot_leaves
  plots <- list()
  for (p in info$plots) {
    invisible(map_leaves(p, function(leaf) {
      plots[[length(plots) + 1L]] <<- leaf
      leaf
    }))
  }
  n <- length(plots)
  if (n == 0L) return(plot)
  if (automatic) {
    cli::cli_warn("Existing patchwork tag levels are preserved; automatic labels may overlap the new fmt_tag() labels.")
  }

  if (is.null(labels)) {
    labels <- vapply(seq_len(n), function(i) {
      label <- ""
      while (i > 0L) {
        i <- i - 1L
        label <- paste0(LETTERS[i %% 26L + 1L], label)
        i <- i %/% 26L
      }
      label
    }, character(1))
  }
  if (!is.character(labels) || length(labels) == 0L ||
      anyNA(labels) || any(!nzchar(trimws(labels)))) {
    cli::cli_abort("{.arg labels} must be a non-empty character vector without missing or blank labels.")
  }
  for (nm in c("size", "label.size")) {
    value <- get(nm)
    if (!is.numeric(value) || length(value) == 0L || any(!is.finite(value)) ||
        (nm == "size" && any(value <= 0)) ||
        (nm == "label.size" && (length(value) != 1L || any(value < 0)))) {
      requirement <- if (nm == "size") "a non-empty vector of finite positive numbers"
                     else "one finite non-negative number"
      cli::cli_abort("{.arg {nm}} must be {requirement}.")
    }
  }
  if (!(is.character(color) || is.numeric(color) || (is.logical(color) && all(is.na(color)))) ||
      length(color) == 0L ||
      (is.numeric(color) && any(!is.finite(color) & !is.na(color)))) {
    cli::cli_abort("{.arg color} must contain valid R colour specifications.")
  }
  rgba <- tryCatch(grDevices::col2rgb(color, alpha = TRUE), error = function(e) {
    cli::cli_abort("{.arg color} must contain valid R colour specifications.", parent = e)
  })
  if (anyNA(color)) {
    missing <- is.na(color)
    color <- if (is.numeric(color)) {
      grDevices::rgb(rgba[1, ], rgba[2, ], rgba[3, ], rgba[4, ], maxColorValue = 255)
    } else as.character(color)
    color[missing] <- "transparent"
  }
  if (!(length(fontface) == 1L &&
        ((is.character(fontface) && fontface %in% c("plain", "bold", "italic", "bold.italic", "symbol")) ||
         (is.numeric(fontface) && fontface %in% 1:5)))) {
    cli::cli_abort("{.arg fontface} must be one valid font face name or number from 1 to 5.")
  }
  unit_values <- function(value) {
    if (inherits(value, "simpleUnit")) return(as.numeric(value))
    previous <- grDevices::dev.cur()
    grDevices::pdf(NULL, width = 7, height = 7)
    device <- grDevices::dev.cur()
    on.exit({
      grDevices::dev.off(device)
      if (previous > 1L) grDevices::dev.set(previous)
    })
    unlist(lapply(unique(size), function(font_size) {
      grid::pushViewport(grid::viewport(gp = grid::gpar(fontsize = font_size)))
      on.exit(grid::popViewport())
      c(grid::convertWidth(value, "mm", valueOnly = TRUE),
        grid::convertHeight(value, "mm", valueOnly = TRUE))
    }))
  }
  for (nm in c("label.padding", "label.r")) {
    value <- get(nm)
    allowed_lengths <- if (nm == "label.padding") c(1L, 2L, 4L) else 1L
    values <- if (grid::is.unit(value) && length(value) %in% allowed_lengths) {
      tryCatch(unit_values(value), error = function(e) NA_real_)
    } else NA_real_
    if (any(!is.finite(values)) || any(values < 0)) {
      cli::cli_abort("{.arg {nm}} must be a finite non-negative grid unit of length {.or {allowed_lengths}}.")
    }
  }
  label.padding <- rep(label.padding, length.out = 4L)

  if (length(labels) < n) {
    labels <- rep_len(labels, n)
    cli::cli_warn("Labels recycled to match number of plots.")
  }

  pos <- .resolve_tag_position(label_position)
  outside <- pos$outside
  npcx <- rep_len(pos$x, n)
  npcy <- rep_len(pos$y, n)
  size <- rep_len(size, n)
  color <- rep_len(color, n)

  for (i in seq_len(n)) {
    if (outside) {
      # Boxed label drawn OUTSIDE the panel, in the plot's margin region:
      # a full-plot patchwork inset (align_to = "full", NPC relative to the
      # whole plot) holding a label box anchored at the corner. The inset's
      # plot.background is blanked so it does not paint over the plot.
      # The box is pulled in by half its border width, otherwise the outer
      # half of the stroke falls outside the plot and is clipped.
      left <- npcx[i] < 0.5
      top <- npcy[i] > 0.5
      half <- grid::unit(label.size / 2, "mm")
      txt <- grid::textGrob(
        labels[i],
        gp = grid::gpar(fontsize = size[i], fontface = fontface, col = color[i])
      )
      txt$x <- grid::unit(0.5, "npc") + (label.padding[4] - label.padding[2]) / 2
      txt$y <- grid::unit(0.5, "npc") + (label.padding[3] - label.padding[1]) / 2
      box <- grid::grobTree(
        grid::roundrectGrob(
          r = label.r,
          gp = grid::gpar(col = if (label.size == 0) NA else color[i], fill = "white",
                          lwd = label.size * ggplot2::.pt)
        ),
        txt,
        vp = grid::viewport(
          x = grid::unit(npcx[i], "npc") + if (left) half else -half,
          y = grid::unit(npcy[i], "npc") + if (top) -half else half,
          width = grid::grobWidth(txt) + label.padding[2] + label.padding[4],
          height = grid::grobHeight(txt) + label.padding[1] + label.padding[3],
          just = c(if (left) 0 else 1, if (top) 1 else 0),
          gp = grid::gpar(fontsize = size[i])
        )
      )
      inset <- patchwork::inset_element(
        patchwork::wrap_elements(full = box) +
          ggplot2::theme(plot.background = ggplot2::element_blank()),
        left = 0, bottom = 0, right = 1, top = 1,
        align_to = "full", clip = FALSE, on_top = TRUE, ignore_tag = TRUE
      )
      attr(inset, ".fmt_tag_generated") <- TRUE
      tagged <- plots[[i]] + inset
      # Keep the inset as a child: an inset-class container suppresses automatic
      # tags on its data plot when ignore_tag is TRUE.
      holder <- patchwork::wrap_plots(list()) + patchwork::plot_layout()
      holder$patches <- tagged$patches
      holder$patches$plots <- lapply(seq_along(tagged), function(j) tagged[[j]])
      plots[[i]] <- holder
    } else {
      layer <- ggpp::geom_label_npc(
        data = data.frame(npcx = npcx[i], npcy = npcy[i], label = labels[i]),
        mapping = ggplot2::aes(npcx = .data[["npcx"]], npcy = .data[["npcy"]],
                               label = .data[["label"]]),
        inherit.aes = FALSE,
        show.legend = FALSE,
        size = size[i],
        fontface = fontface,
        color = color[i],
        size.unit = "pt",
        label.size = label.size,
        label.padding = label.padding,
        label.r = label.r,
        ...
      )
      # NPC belongs to the displayed panel, not the data coordinate system.
      layer$geom <- ggplot2::ggproto(NULL, ggpp::GeomLabelNpc,
        draw_panel = function(data, panel_params, coord, parse = FALSE, na.rm = FALSE,
                              label.padding = grid::unit(0.25, "lines"),
                              label.r = grid::unit(0.15, "lines"), label.size = 0.25,
                              size.unit = "mm") {
          panel_coord <- ggplot2::ggproto(NULL, coord,
            backtransform_range = function(panel_params) list(x = c(0, 1), y = c(0, 1)),
            transform = function(data, panel_params) data
          )
          ggpp::GeomLabelNpc$draw_panel(data, panel_params, panel_coord,
            parse = parse, na.rm = na.rm, label.padding = label.padding,
            label.r = label.r, label.size = label.size, size.unit = size.unit)
        }
      )
      attr(layer, ".fmt_tag_generated") <- TRUE
      plots[[i]] <- plots[[i]] + layer
    }
  }

  i <- 0L
  restored <- lapply(info$plots, map_leaves, fun = function(p) {
    i <<- i + 1L
    plots[[i]]
  })
  .from_plot_list(restored, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_legend ----

#' Format legend position and style
#'
#' Adjust legend position, direction, layout, scaling, and optionally
#' collect legends across a multi-plot patchwork.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param legend.position Legend position. Accepts:
#'   \itemize{
#'     \item Character: `"top"`, `"bottom"`, `"left"`, `"right"`, `"none"`.
#'     \item Shorthand corner codes: `"br"`, `"bl"`, `"tr"`, `"tl"` (inside
#'       plot corners).
#'     \item Numeric vector of length 2: `c(x, y)` coordinates (0-1) for
#'       inside-plot positioning.
#'   }
#'   Default `NULL` (no change).
#' @param legend.direction `"horizontal"` or `"vertical"`. Default `NULL`.
#' @param legend_theme A ggplot2 theme object for legend styling, e.g.,
#'   [theme_legend1()]. Applied after position/direction settings so it can
#'   override them. Default `NULL` (no extra styling).
#' @param collect Logical. If `TRUE` and input has multiple plots,
#'   collect legends into a single shared legend via patchwork. Default `FALSE`.
#' @param title Character vector of legend titles, one per subplot. Recycled
#'   to match the number of subplots. Automatically detects which aesthetics
#'   (colour, fill, shape, etc.) are mapped and renames their legend titles.
#'   Default `NULL` (no change).
#' @param scale Numeric. Proportionally scale the entire legend.
#'   \code{0.8} = shrink to 80\%, \code{1.2} = enlarge to 120\%.
#'   Adjusts key size, text size, title size, point size, and spacing
#'   together. Default \code{NULL} (no scaling).
#' @param scale_width Numeric. Scale legend key width independently.
#'   Default \code{NULL} (no change).
#' @param scale_height Numeric. Scale legend key height independently.
#'   Default \code{NULL} (no change).
#' @param ncol Number of columns in the legend layout (passed to
#'   [ggplot2::guide_legend()]).
#' @param nrow Number of rows in the legend layout (passed to
#'   [ggplot2::guide_legend()]).
#' @param ... Additional arguments passed to [ggplot2::theme()], e.g.,
#'   `legend.text`, `legend.key.size`, `legend.background`.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()
#'
#' fmt_legend(p, legend.position = "bottom", legend.direction = "horizontal")
#' fmt_legend(p, legend.position = "none")
#' fmt_legend(p, legend.position = "br")
#' fmt_legend(p, legend.position = c(0.9, 0.2))
#' fmt_legend(p, legend.position = "br", legend_theme = theme_legend1())
#'
#' # Scale legend to 80% of current size
#' fmt_legend(p, scale = 0.8)
#'
#' # Scale width and height independently
#' fmt_legend(p, scale_width = 1.5, scale_height = 0.5)
#'
#' @export
#' @family plot formatting
fmt_legend <- function(plot,
                       legend.position = NULL,
                       legend.direction = NULL,
                       legend_theme = NULL,
                       collect = FALSE,
                       title = NULL,
                       scale = NULL,
                       scale_width = NULL,
                       scale_height = NULL,
                       ncol = NULL,
                       nrow = NULL,
                       ...) {
  info <- .to_plot_list(plot, recurse = TRUE)
  plots <- info$plots
  n <- length(plots)
  if (n == 0L) return(plot)

  # ---- Rename legend titles per subplot ----
  if (!is.null(title)) {
    title <- rep_len(title, n)
    legend_aes <- c("colour", "color", "fill", "shape", "size",
                    "alpha", "linetype")
    for (i in seq_len(n)) {
      # Only rename scales that produce legends, skip positional (x/y) scales
      for (sc in plots[[i]]$scales$scales) {
        if (any(sc$aesthetics %in% legend_aes)) {
          sc$name <- title[i]
        }
      }
    }
    # Rebuild patchwork so collect mode sees updated titles
    if (info$is_patchwork) {
      plot <- .from_plot_list(plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig,
                              recurse = TRUE)
    }
  }

  if (!is.null(legend.direction) &&
      !legend.direction %in% c("horizontal", "vertical")) {
    cli::cli_warn("{.arg legend.direction} must be 'horizontal' or 'vertical'.")
    legend.direction <- NULL
  }

  # ---- Resolve corner shorthand to numeric coordinates ----
  corner_map <- list(
    br = c(0.95, 0.05), bl = c(0.05, 0.05),
    tr = c(0.95, 0.95), tl = c(0.05, 0.95)
  )
  if (is.character(legend.position) && legend.position %in% names(corner_map)) {
    legend.position <- corner_map[[legend.position]]
  }

  # ---- Build justification ----
  legend.justification <- NULL
  if (is.numeric(legend.position) && length(legend.position) == 2) {
    just_x <- ifelse(legend.position[1] > 0.5, 1, 0)
    just_y <- ifelse(legend.position[2] > 0.5, 1, 0)
    legend.justification <- c(just_x, just_y)
  } else if (is.character(legend.position)) {
    legend.justification <- switch(legend.position,
      "top"    = c(0.5, 0),
      "bottom" = c(0.5, 1),
      "left"   = c(1, 0.5),
      "right"  = c(0, 0.5),
      NULL
    )
  }

  # ---- Build theme ----
  theme_args <- list(...)
  if (!is.null(legend.position))
    theme_args$legend.position <- legend.position
  if (!is.null(legend.direction))
    theme_args$legend.direction <- legend.direction
  if (!is.null(legend.justification))
    theme_args$legend.justification <- legend.justification

  leg_theme <- do.call(ggplot2::theme, theme_args)

  # Append legend_theme — if it sets title to element_blank, also suppress at guide level
  no_title_guides <- NULL
  if (!is.null(legend_theme) && inherits(legend_theme, "theme")) {
    leg_theme <- leg_theme + legend_theme
    title_el <- legend_theme$legend.title
    if (inherits(title_el, "element_blank")) {
      no_title <- ggplot2::guide_legend(title = "")
      no_title_guides <- ggplot2::guides(
        colour = no_title, fill = no_title,
        shape = no_title, size = no_title,
        alpha = no_title, linetype = no_title
      )
    }
  }

  # ---- Scale legend proportionally ----
  scale_theme <- NULL
  scale_guides <- NULL
  if (!is.null(scale) && is.numeric(scale) && scale > 0) {
    .get_size <- function(p, element) {
      th <- ggplot2::theme_get() + p$theme
      el <- ggplot2::calc_element(element, th)
      if (inherits(el, "element_text") && !is.null(el$size)) el$size
      else NULL
    }
    .get_key_size <- function(p) {
      th <- ggplot2::theme_get() + p$theme
      el <- ggplot2::calc_element("legend.key.size", th)
      if (inherits(el, "simpleUnit") || inherits(el, "unit")) {
        as.numeric(el)
      } else {
        1.2
      }
    }
    .get_point_size <- function(p) {
      for (layer in p$layers) {
        if (inherits(layer$geom, "GeomPoint")) {
          sz <- tryCatch({
            s <- layer$aes_params$size
            if (is.null(s)) s <- layer$geom$default_aes$size
            if (is.numeric(s)) s else as.numeric(s)
          }, error = function(e) NULL)
          if (!is.null(sz) && is.numeric(sz)) return(sz)
        }
      }
      1.5
    }

    ref_p <- plots[[1]]
    text_sz  <- .get_size(ref_p, "legend.text") %||% 8.8
    title_sz <- .get_size(ref_p, "legend.title") %||% 11
    key_sz   <- .get_key_size(ref_p)
    pt_sz    <- .get_point_size(ref_p)

    scale_theme <- ggplot2::theme(
      legend.text     = ggplot2::element_text(size = text_sz * scale),
      legend.title    = ggplot2::element_text(size = title_sz * scale),
      legend.key.size = grid::unit(key_sz * scale, "lines"),
      legend.spacing  = grid::unit(0.2 * scale, "cm"),
      legend.box.spacing = grid::unit(0.2 * scale, "cm")
    )

    guide_obj_scale <- ggplot2::guide_legend(
      override.aes = list(size = pt_sz * scale)
    )
    scale_guides <- ggplot2::guides(
      colour = guide_obj_scale,
      fill = guide_obj_scale, shape = guide_obj_scale
    )
  }

  # ---- Scale width / height independently ----
  dim_theme <- NULL
  dim_guides <- NULL
  if (!is.null(scale_width) || !is.null(scale_height)) {
    .get_key_dim <- function(p, element) {
      th <- ggplot2::theme_get() + p$theme
      el <- ggplot2::calc_element(element, th)
      if (inherits(el, "simpleUnit") || inherits(el, "unit")) {
        as.numeric(el)
      } else {
        NULL
      }
    }
    ref_p <- plots[[1]]
    dim_args <- list()
    # guide_colorbar args for continuous scales
    bar_args <- list()
    if (!is.null(scale_width)) {
      kw <- .get_key_dim(ref_p, "legend.key.width") %||%
            .get_key_dim(ref_p, "legend.key.size") %||% 1.2
      dim_args$legend.key.width <- grid::unit(kw * scale_width, "lines")
      bar_args$barwidth <- grid::unit(kw * scale_width, "lines")
    }
    if (!is.null(scale_height)) {
      kh <- .get_key_dim(ref_p, "legend.key.height") %||%
            .get_key_dim(ref_p, "legend.key.size") %||% 1.2
      dim_args$legend.key.height <- grid::unit(kh * scale_height, "lines")
      bar_args$barheight <- grid::unit(kh * scale_height, "lines")
    }
    dim_theme <- do.call(ggplot2::theme, dim_args)
    # Apply to both legend and colorbar guides
    if (length(bar_args) > 0) {
      guide_cb <- do.call(ggplot2::guide_colorbar, bar_args)
      guide_lg <- do.call(ggplot2::guide_legend, list())
      dim_guides <- ggplot2::guides(colour = guide_cb, fill = guide_cb)
    }
  }

  # ---- Guide layout (ncol/nrow) ----
  guide_args <- list()
  if (!is.null(ncol) && is.numeric(ncol)) guide_args$ncol <- ncol
  if (!is.null(nrow) && is.numeric(nrow)) guide_args$nrow <- nrow

  legend_guides <- NULL
  if (length(guide_args) > 0) {
    guide_obj <- do.call(ggplot2::guide_legend, guide_args)
    legend_guides <- ggplot2::guides(
      fill = guide_obj, colour = guide_obj,
      shape = guide_obj, size = guide_obj, alpha = guide_obj,
      linetype = guide_obj
    )
  }

  # ---- Collect legends mode for patchwork ----
  if (collect && n > 1L && info$is_patchwork) {
    combined <- plot + patchwork::plot_layout(guides = "collect")
    combined <- combined & leg_theme
    if (!is.null(no_title_guides)) combined <- combined & no_title_guides
    if (!is.null(scale_theme))     combined <- combined & scale_theme
    if (!is.null(scale_guides))    combined <- combined & scale_guides
    if (!is.null(dim_theme))       combined <- combined & dim_theme
    if (!is.null(dim_guides))      combined <- combined & dim_guides
    if (!is.null(legend_guides))   combined <- combined & legend_guides
    return(combined)
  }

  # ---- Normal mode: apply to each plot ----
  for (i in seq_len(n)) {
    plots[[i]] <- plots[[i]] + leg_theme
    if (!is.null(no_title_guides)) plots[[i]] <- plots[[i]] + no_title_guides
    if (!is.null(scale_theme))     plots[[i]] <- plots[[i]] + scale_theme
    if (!is.null(scale_guides))    plots[[i]] <- plots[[i]] + scale_guides
    if (!is.null(dim_theme))       plots[[i]] <- plots[[i]] + dim_theme
    if (!is.null(dim_guides))      plots[[i]] <- plots[[i]] + dim_guides
    if (!is.null(legend_guides))   plots[[i]] <- plots[[i]] + legend_guides
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig,
                  recurse = TRUE)
}

# ---- fmt_ref ----

#' Add reference lines to plots
#'
#' Add vertical and/or horizontal reference lines to one or more plots. When
#' multiple intercept values are provided with matching per-line colors, each
#' line is added individually so that colors are applied correctly.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param x Numeric vector of x-intercept values for vertical lines, or `NULL`.
#' @param y Numeric vector of y-intercept values for horizontal lines, or `NULL`.
#' @param linetype Line type. Default `"dashed"`.
#' @param linewidth Line width. Default `0.5`.
#' @param color Line color(s). Recycled to match the number of intercepts.
#'   Default `"gray50"`.
#' @param alpha Line transparency. Default `0.8`.
#' @param ... Additional arguments passed to [ggplot2::geom_vline()] or
#'   [ggplot2::geom_hline()].
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_ref(p, x = 5.5, y = 3.0)
#' fmt_ref(p, x = c(5, 6), color = c("red", "blue"))
#'
#' @export
#' @family plot formatting
fmt_ref <- function(plot,
                    x = NULL,
                    y = NULL,
                    linetype = "dashed",
                    linewidth = 0.5,
                    color = "gray50",
                    alpha = 0.8,
                    ...) {
  info <- .to_plot_list(plot, recurse = TRUE)
  plots <- info$plots

  .add_ref_one <- function(p) {
    if (!is.null(x)) {
      x_color <- rep_len(color, length(x))
      x_lt <- rep_len(linetype, length(x))
      x_lw <- rep_len(linewidth, length(x))
      x_alpha <- rep_len(alpha, length(x))
      for (j in seq_along(x)) {
        p <- p + ggplot2::geom_vline(
          xintercept = x[j], linetype = x_lt[j], linewidth = x_lw[j],
          color = x_color[j], alpha = x_alpha[j], ...
        )
      }
    }
    if (!is.null(y)) {
      y_color <- rep_len(color, length(y))
      y_lt <- rep_len(linetype, length(y))
      y_lw <- rep_len(linewidth, length(y))
      y_alpha <- rep_len(alpha, length(y))
      for (j in seq_along(y)) {
        p <- p + ggplot2::geom_hline(
          yintercept = y[j], linetype = y_lt[j], linewidth = y_lw[j],
          color = y_color[j], alpha = y_alpha[j], ...
        )
      }
    }
    p
  }

  for (i in seq_along(plots)) {
    plots[[i]] <- .add_ref_one(plots[[i]])
  }

  .from_plot_list(plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig,
                  recurse = TRUE)
}

# ---- fmt_plot ----

#' Master plot formatting function
#'
#' Convenience wrapper that chains [fmt_axis()], [fmt_tag()], [fmt_legend()],
#' and [fmt_ref()] in sequence. Each sub-formatter is applied only when its
#' corresponding `*_list` argument is non-NULL.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param fmt_axis_list Named list of arguments for [fmt_axis()]. Set to `NULL`
#'   (default) to skip.
#' @param fmt_tag_list Named list of arguments for [fmt_tag()]. Set to `NULL`
#'   to skip.
#' @param fmt_legend_list Named list of arguments for [fmt_legend()]. Set to
#'   `NULL` to skip.
#' @param fmt_ref_list Named list of arguments for [fmt_ref()]. Set to `NULL`
#'   to skip.
#' @param plot.margin Numeric vector of length 1 or 4, or a [ggplot2::margin()]
#'   object. Applied to all plots via `&`.
#' @param tag_levels Character string for patchwork tag levels (e.g. `"A"`,
#'   `"a"`, `"1"`). Only used when input is a patchwork object. Ignored with a
#'   warning when `fmt_tag_list` supplies explicit labels.
#'   Automatic tag levels already present in `plot` are preserved, with a
#'   conflict warning from [fmt_tag()].
#' @param axis_titles Passed to [patchwork::plot_layout()] `axis_titles`
#'   argument. Only used when input is a patchwork object.
#' @param ... Currently unused.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' library(patchwork)
#' d <- data.frame(x = 1:6, y = c(2, 4, 3, 5, 6, 4),
#'                 group = rep(c("a", "b"), each = 3))
#' p1 <- ggplot(d, aes(x, y, colour = group)) + geom_point()
#' p2 <- ggplot(d, aes(y, x, colour = group)) + geom_point()
#'
#' # Single plot with reference line and legend
#' single <- fmt_plot(p1, fmt_ref_list = list(x = 3),
#'                    fmt_legend_list = list(legend.position = "bottom"))
#' single
#'
#' # Multi-plot with tags and merged legend
#' combined <- fmt_plot(p1 | p2, fmt_tag_list = list(),
#'                      fmt_legend_list = list(collect = TRUE))
#' combined
#'
#' @export
#' @family plot formatting
fmt_plot <- function(plot,
                     fmt_axis_list = NULL,
                     fmt_tag_list = NULL,
                     fmt_legend_list = NULL,
                     fmt_ref_list = NULL,
                     plot.margin = NULL,
                     tag_levels = NULL,
                     axis_titles = NULL,
                     ...) {

  if (!is.null(fmt_tag_list) && !is.null(tag_levels)) {
    cli::cli_warn("{.arg tag_levels} is ignored when {.arg fmt_tag_list} supplies explicit tags.")
    tag_levels <- NULL
  }

  # Apply axis formatting

  if (!is.null(fmt_axis_list)) {
    plot <- rlang::exec(fmt_axis, plot = plot, !!!fmt_axis_list)
  }

  # Apply tag labels

  if (!is.null(fmt_tag_list)) {
    plot <- rlang::exec(fmt_tag, plot = plot, !!!fmt_tag_list)
  }

  # Apply legend formatting

  if (!is.null(fmt_legend_list)) {
    plot <- rlang::exec(fmt_legend, plot = plot, !!!fmt_legend_list)
  }

  # Apply reference lines

  if (!is.null(fmt_ref_list)) {
    plot <- rlang::exec(fmt_ref, plot = plot, !!!fmt_ref_list)
  }

  # Apply plot margin

  if (!is.null(plot.margin)) {
    if (inherits(plot.margin, "margin")) {
      margin_obj <- plot.margin
    } else if (is.numeric(plot.margin)) {
      if (length(plot.margin) == 1L) {
        margin_obj <- ggplot2::margin(
          plot.margin, plot.margin, plot.margin, plot.margin
        )
      } else if (length(plot.margin) == 4L) {
        margin_obj <- ggplot2::margin(
          plot.margin[1], plot.margin[2], plot.margin[3], plot.margin[4]
        )
      } else {
        cli::cli_abort(
          "{.arg plot.margin} must be length 1 or 4, not {length(plot.margin)}."
        )
      }
    } else {
      cli::cli_abort("{.arg plot.margin} must be numeric or a margin object.")
    }
    plot <- plot & ggplot2::theme(plot.margin = margin_obj)
  }

  # Apply patchwork tag_levels

  if (!is.null(tag_levels) && inherits(plot, "patchwork")) {
    plot <- plot + patchwork::plot_annotation(tag_levels = tag_levels)
  }

  # Apply patchwork axis_titles

  if (!is.null(axis_titles) && inherits(plot, "patchwork")) {
    plot <- plot + patchwork::plot_layout(axis_titles = axis_titles)
  }

  plot
}

# ---- fmt_plot_base ----

#' Broadcast theme / labs / scales onto a patchwork via `&`
#'
#' Apply a theme, axis labels, and continuous y/x scales to **every** panel of
#' a patchwork in one call, using patchwork's \code{&} operator. This is the
#' packaged form of the legacy FeatureAnalysis helper \code{.fmt_plot.base()}:
#' a list-driven wrapper that is handy when assembling multi-panel figures.
#'
#' Each argument is applied only when non-\code{NULL}, so a bare
#' \code{fmt_plot_base(p)} returns \code{p} unchanged.
#'
#' @param plot A patchwork (or ggplot) object.
#' @param ggtheme Theme to broadcast. Polymorphic (resolved internally): a
#'   \code{ggplot2::theme} object, a theme **function** (e.g. \code{theme_my}),
#'   or a function-name **string** (e.g. \code{"theme_km"}). \code{NULL}
#'   (default) leaves the theme untouched.
#' @param labs_list Named list passed to \code{ggplot2::labs()}, e.g.
#'   \code{list(x = "ETE", y = "SHAP value")}. \code{NULL} = no change.
#' @param scale_y_list Named list passed to
#'   \code{ggplot2::scale_y_continuous()}, e.g.
#'   \code{list(limits = c(0, 1), breaks = seq(0, 1, 0.2))}. \code{NULL} = no change.
#' @param scale_x_list Named list passed to
#'   \code{ggplot2::scale_x_continuous()}. \code{NULL} = no change.
#'
#' @return The input plot with the requested layers broadcast via \code{&}.
#'
#' @examples
#' library(ggplot2); library(patchwork)
#' p <- (ggplot(mtcars, aes(wt, mpg)) + geom_point()) +
#'      (ggplot(mtcars, aes(hp, mpg)) + geom_point())
#'
#' # theme object / labs / y-scale broadcast to both panels
#' fmt_plot_base(p,
#'               ggtheme      = theme_my(base_size = 12),
#'               labs_list    = list(y = "Miles per gallon"),
#'               scale_y_list = list(limits = c(10, 35)))
#'
#' # ggtheme also accepts a function or a string
#' \dontrun{
#' fmt_plot_base(p, ggtheme = theme_km)     # function
#' fmt_plot_base(p, ggtheme = "theme_km")   # string
#' }
#'
#' @export
#' @family plot formatting
#' @seealso [fmt_plot()]
fmt_plot_base <- function(plot, ggtheme = NULL, labs_list = NULL,
                          scale_y_list = NULL, scale_x_list = NULL) {
  if (!is.null(ggtheme))      plot <- plot & .resolve_theme(ggtheme)
  if (!is.null(labs_list))    plot <- plot & do.call(ggplot2::labs, labs_list)
  if (!is.null(scale_y_list)) plot <- plot & do.call(ggplot2::scale_y_continuous, scale_y_list)
  if (!is.null(scale_x_list)) plot <- plot & do.call(ggplot2::scale_x_continuous, scale_x_list)
  plot
}

# fmt_plot2.R
# Additional plot formatting functions: strip, comparison, background,
# histogram, scale, expand, boxplot overlay.

# ---- fmt_strip ----

#' Add facet strip labels to a plot
#'
#' Add a top strip to an unfaceted plot or update the labels and style of an
#' existing facet. Facet variables, layout, scales, statistics and plot/layer
#' data are preserved. Strip text is horizontally and vertically centered.
#' Set \code{strip = FALSE} to hide strips without building the plot.
#'
#' @param plot A ggplot, patchwork, or list of these. Nested patchworks retain
#'   their layout; spacers and guide areas are skipped.
#'   Panels made with [patchwork::wrap_elements()] are rejected; format the
#'   original ggplot before wrapping it.
#' @param label A non-empty character vector without missing values, or `NULL`.
#'   For one faceted plot, labels are recycled across the displayed levels of
#'   its first facet variable: the first wrap variable, or the first grid column
#'   variable (row variable when there are no columns). Other variables retain
#'   their labeller, including row/column labellers and single-line formatting.
#'   For multiple plots, labels are recycled across leaf plots
#'   in their existing order. `NULL` generates `Figure1`, `Figure2`, etc.; `""`
#'   gives a blank label.
#' @param label_color Text colour(s). Default \code{"black"} uses bold text.
#'   `NULL` inherits the existing text colour and face. Valid R colour names,
#'   hexadecimal colours, numeric palette indices and `NA` are accepted.
#'   Colours are recycled across leaf plots; one faceted plot uses the first.
#' @param label_fill Background fill colour(s), recycled across leaf plots.
#'   One faceted plot uses the first fill. `NULL` inherits the current theme or
#'   ggh4x strip background; use `NA` or `"transparent"` for a transparent fill.
#'   Accepts the same colour specifications as `label_color`.
#' @param strip Logical. \code{TRUE} (default) adds the strip labels.
#'   \code{FALSE} shows no strip at all and ignores \code{label},
#'   \code{label_color} and \code{label_fill}: strips already on the plot,
#'   from an earlier \code{fmt_strip()} / \code{\link{fmt_strip2}()} call or
#'   from its own facets, are removed. Synthetic facets created by this function
#'   are dropped; native facets keep their panels with strips hidden through the
#'   theme. Complete themes such as \code{theme_bw()} can reveal native strips;
#'   reapply this formatter to hide them again.
#'   A later `strip = TRUE` call restores the hidden strip settings and applies
#'   its new labels and colours. Layer data functions and statistics are not
#'   evaluated by this formatter.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' d <- data.frame(
#'   x = rep(seq_len(5), 3), y = sin(seq_len(15) / 3),
#'   group = rep(c("A", "B", "C"), each = 5)
#' )
#' p <- ggplot(d, aes(x, y)) + geom_point()
#' fmt_strip(p, label = "Example", label_color = "white", label_fill = "steelblue")
#'
#' # Rename facet levels without changing panel membership
#' p_facet <- p + facet_wrap(vars(group))
#' fmt_strip(p_facet, label = c("First", "Second", "Third"), label_fill = NA)
#'
#' # Hide strips and restore them later
#' hidden <- fmt_strip(p_facet, strip = FALSE)
#' fmt_strip(hidden, label = c("First", "Second", "Third"))
#'
#' # Nested layouts skip spacers when assigning labels
#' library(patchwork)
#' fmt_strip((p | plot_spacer() | p) / p, label = c("A", "B", "C"))
#'
#' @md
#' @export
#' @family plot formatting
fmt_strip <- function(plot, label = NULL, label_color = "black", label_fill = NULL,
                      strip = TRUE) {
  if (!is.logical(strip) || length(strip) != 1L || is.na(strip)) {
    cli::cli_abort("{.arg strip} must be a single TRUE or FALSE.")
  }
  info <- .to_plot_list(plot)
  map_leaves <- .map_plot_leaves
  check_wrapped <- function(p) {
    if (inherits(p, "inset_patch") && (!inherits(p, "patchwork") ||
        match("inset_patch", class(p)) < match("patchwork", class(p)))) return(invisible(NULL))
    if (inherits(p, "patchwork")) {
      for (j in seq_along(p)) check_wrapped(p[[j]])
    } else if (inherits(p, "wrapped_patch")) {
      cli::cli_abort("Strip formatting cannot modify panels created by {.fn patchwork::wrap_elements}. Format the original ggplot before wrapping it.")
    }
    invisible(NULL)
  }
  plots <- list()
  for (p in info$plots) {
    check_wrapped(p)
    invisible(map_leaves(p, function(leaf) {
      plots[[length(plots) + 1L]] <<- leaf
      leaf
    }))
  }
  restore <- function(plots) {
    i <- 0L
    restored <- lapply(info$plots, map_leaves, fun = function(p) {
      i <<- i + 1L
      plots[[i]]
    })
    .from_plot_list(restored, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
  }
  n <- length(plots)
  hidden_elements <- c("strip.text.x.top", "strip.text.x.bottom",
                       "strip.text.y.left", "strip.text.y.right",
                       "strip.background.x", "strip.background.y")

  if (!strip) {
    # Only remove synthetic facets owned by this function. Native facets keep
    # their structure without evaluating data or statistics. Blank leaf elements,
    # since a user-set `strip.text.x` ignores a blank parent. ggh4x themed / nested
    # strips carry text and fill elements that beat the theme, so those are
    # cleared on ggproto children, leaving the input plot as is. ggproto()
    # re-reads a parent by name, so never reassign `facet` or `old_strip`.
    plots <- lapply(plots, function(p) {
      if (inherits(p$facet, "FacetNull")) return(p)
      if (!is.null(p$facet$.fmt_strip_hidden)) {
        if (all(vapply(hidden_elements, function(nm) {
          inherits(p$theme[[nm]], "element_blank")
        }, logical(1)))) return(p)
        blank <- ggplot2::element_blank()
        return(p + do.call(ggplot2::theme,
          stats::setNames(rep(list(blank), length(hidden_elements)), hidden_elements)))
      }
      if (isTRUE(p$facet$.fmt_strip_generated)) return(p + ggplot2::facet_null())

      facet <- p$facet
      old_strip <- facet$strip
      hidden <- list(
        theme = stats::setNames(lapply(hidden_elements, function(nm) p$theme[[nm]]),
                                hidden_elements),
        strip = old_strip
      )
      new_strip <- old_strip
      if (!is.null(old_strip$given_elements)) {
        given <- old_strip$given_elements
        given[c("text_x", "text_y", "background_x", "background_y")] <- list(NULL)
        new_strip <- ggplot2::ggproto(
          NULL, old_strip,
          given_elements = given,
          # strip_nested() warns on the NULL sizes of blank multi-layer strips
          assemble_strip = function(self, ...) {
            suppressWarnings(
              ggplot2::ggproto_parent(old_strip, self)$assemble_strip(...)
            )
          }
        )
      }
      p <- p + ggplot2::ggproto(NULL, facet, strip = new_strip,
                                .fmt_strip_hidden = hidden)
      blank <- ggplot2::element_blank()
      p + ggplot2::theme(
        strip.text.x.top = blank, strip.text.x.bottom = blank,
        strip.text.y.left = blank, strip.text.y.right = blank,
        strip.background.x = blank, strip.background.y = blank
      )
    })
    return(restore(plots))
  }

  if (!is.null(label) && (!is.character(label) || length(label) == 0L || anyNA(label))) {
    cli::cli_abort("{.arg label} must be NULL or a non-empty character vector without missing values.")
  }
  colours <- list(label_color = label_color, label_fill = label_fill)
  for (arg in names(colours)) {
    value <- colours[[arg]]
    if (is.null(value)) next
    if (length(value) == 0L ||
        !(is.character(value) || is.numeric(value) || (is.logical(value) && all(is.na(value)))) ||
        (is.numeric(value) && any(!is.finite(value) & !is.na(value)))) {
      cli::cli_abort("{.arg {arg}} must be NULL or a non-empty vector of valid R colours.")
    }
    rgba <- tryCatch(grDevices::col2rgb(value, alpha = TRUE), error = function(e) {
      cli::cli_abort("{.arg {arg}} must contain valid R colours.", parent = e)
    })
    if (anyNA(value)) {
      missing <- is.na(value)
      value <- if (is.numeric(value)) {
        grDevices::rgb(rgba[1, ], rgba[2, ], rgba[3, ], rgba[4, ], maxColorValue = 255)
      } else {
        as.character(value)
      }
      value[missing] <- "transparent"
      colours[[arg]] <- value
    }
  }
  label_color <- colours$label_color
  label_fill <- colours$label_fill

  if (is.null(label)) label <- paste0("Figure", seq_len(n))
  if (n > 1L) label <- rep_len(label, n)
  if (!is.null(label_color)) label_color <- rep_len(label_color, n)
  if (!is.null(label_fill))  label_fill  <- rep_len(label_fill, n)

  centered_strip_text <- function(colour, face = "bold") {
    ggplot2::element_text(
      colour = colour,
      face = face,
      hjust = 0.5,
      vjust = 0.5,
      margin = ggplot2::margin(t = 3, b = 3, unit = "pt")
    )
  }

  create_strip <- function(lc, lf) {
    if (!is.null(lf)) {
      ggh4x::strip_themed(
        background_x = ggh4x::elem_list_rect(fill = lf),
        text_x = list(centered_strip_text(lc, face = if (is.null(lc)) NULL else "bold"))
      )
    } else if (!is.null(lc)) {
      ggh4x::strip_themed(
        text_x = list(centered_strip_text(lc))
      )
    } else {
      ggh4x::strip_themed(
        text_x = list(centered_strip_text(NULL, face = NULL))
      )
    }
  }

  # Helper: check if a plot already has a non-trivial facet
  .has_facet <- function(p) {
    fc <- p$facet
    !is.null(fc) && !inherits(fc, "FacetNull")
  }

  for (i in seq_len(n)) {
    hidden <- plots[[i]]$facet$.fmt_strip_hidden
    if (!is.null(hidden)) {
      for (nm in names(hidden$theme)) {
        if (inherits(plots[[i]]$theme[[nm]], "element_blank")) {
          plots[[i]]$theme[[nm]] <- hidden$theme[[nm]]
        }
      }
      plots[[i]] <- plots[[i]] + local({
        facet <- plots[[i]]$facet
        ggplot2::ggproto(NULL, facet, strip = hidden$strip, .fmt_strip_hidden = NULL)
      })
    }
    if (.has_facet(plots[[i]])) {
      # Facet quosure names are the columns passed to the labeller, including
      # named expressions and .data pronouns. Leave the expressions untouched.
      old_facet <- plots[[i]]$facet
      facet_vars <- c(names(old_facet$params$facets),
                      names(old_facet$params$cols), names(old_facet$params$rows))

      if (length(facet_vars) > 0) {
        fvar <- facet_vars[1]
        # The labeller receives levels in facet order, which can differ
        # from their first appearance in the raw data.
        # Keep every facet variable and setting. Bind the ggproto parent in
        # its own environment so later loop iterations cannot replace it.
        plots[[i]] <- plots[[i]] + local({
          facet <- old_facet
          params <- facet$params
          original <- attr(params$labeller, ".fmt_strip_original_labeller")
          if (is.null(original)) original <- params$labeller
          variable <- fvar
          replacement <- if (n == 1L) label else label[i]
          params$labeller <- function(values) {
            if (!variable %in% names(values)) return(original(values))
            levels <- unique(values[[variable]])
            mapped <- rep_len(replacement, length(levels))[match(values[[variable]], levels)]
            if (length(values) == 1L) return(stats::setNames(list(mapped), variable))
            out <- original(values)
            if (length(out) > 1L) {
              out[[match(variable, names(values))]] <- mapped
              return(out)
            }
            # Combined labels stay on one line. Keep the facet context when
            # asking the original labeller to format the remaining variables.
            others <- values[setdiff(names(values), variable)]
            for (nm in c("type", "facet")) attr(others, nm) <- attr(values, nm)
            remaining <- original(others)[[1L]]
            out[[1L]] <- if (is.expression(remaining) || is.list(remaining)) {
              Map(function(text, value) {
                if (is.expression(value) && length(value) == 1L) value <- value[[1L]]
                as.expression(list(substitute(paste(text, ", ", value),
                                              list(text = text, value = value))))
              }, mapped, as.list(remaining))
            } else {
              paste(mapped, remaining, sep = ", ")
            }
            out
          }
          class(params$labeller) <- c("function", "labeller")
          attr(params$labeller, ".fmt_strip_original_labeller") <- original
          ggplot2::ggproto(NULL, facet, params = params)
        })
      }

      # Apply strip style via theme
      strip_theme <- list()
      lc_val <- if (is.null(label_color)) NULL else label_color[i]
      text_element <- centered_strip_text(lc_val, face = if (is.null(lc_val)) NULL else "bold")
      for (nm in c("strip.text", "strip.text.x", "strip.text.y", hidden_elements[1:4])) {
        strip_theme[[nm]] <- text_element
      }
      if (!is.null(label_fill)) {
        background_element <- ggplot2::element_rect(fill = label_fill[i], colour = "black")
        for (nm in c("strip.background", "strip.background.x", "strip.background.y")) {
          strip_theme[[nm]] <- background_element
        }
      }
      plots[[i]] <- plots[[i]] + do.call(ggplot2::theme, strip_theme)

      # ggh4x elements override the theme; merge only the requested properties.
      if (!is.null(plots[[i]]$facet$strip$given_elements)) {
        plots[[i]] <- plots[[i]] + local({
          facet <- plots[[i]]$facet
          old_strip <- facet$strip
          given <- old_strip$given_elements
          for (nm in c("text_x", "text_y")) {
            if (!is.null(given[[nm]])) {
              given[[nm]] <- lapply(given[[nm]], function(el) {
                ggplot2::merge_element(text_element, el)
              })
            }
          }
          if (!is.null(label_fill)) {
            for (nm in c("background_x", "background_y")) {
              if (!is.null(given[[nm]])) {
                given[[nm]] <- lapply(given[[nm]], function(el) {
                  ggplot2::merge_element(background_element, el)
                })
              }
            }
          }
          ggplot2::ggproto(NULL, facet,
                           strip = ggplot2::ggproto(NULL, old_strip, given_elements = given))
        })
      }

    } else {
      # A constant facet expression leaves plot/layer data and mappings intact.
      cur_strip <- create_strip(
        lc = if (!is.null(label_color)) label_color[i] else NULL,
        lf = if (!is.null(label_fill))  label_fill[i]  else NULL
      )
      facet_formula <- ggplot2::vars(.strip_label. = !!label[i])
      facet <- ggh4x::facet_wrap2(facet_formula, strip = cur_strip)
      facet$.fmt_strip_generated <- TRUE
      plots[[i]] <- plots[[i]] + facet
    }
  }

  restore(plots)
}

# ---- fmt_strip2 ----

#' Add facet-grid-style strips to a patchwork grid (top headers + side labels)
#'
#' For an assembled patchwork laid out as an `nrow x ncol` grid, add
#' shared strips: column-header strips only on the **top row**
#' and row-label strips on the **right-most occupied panel** of each row
#' (rotated). The headers describe crossed dimensions, such as plot type across
#' columns and a stratifier down rows.
#'
#' Typical use: a `get_vpd(EXP.obj, c(stratifier, exposure))` result flattened
#' via [flatten_patchwork()] into a `4 x 2` grid (rows = stratifier levels,
#' columns = Variable / Partial dependence plot) -- `fmt_strip2()` then labels
#' the two columns on top and the four rows on the right.
#'
#' In RegR, \code{\link[RegR:get_rcs_all]{RegR::get_rcs_all()}} uses this
#' helper for its shared-strip 2 x 2 composites when `strip_style = "grid"`.
#' Existing facets retain their panels when no new header is assigned. A plot
#' receiving a header must have one panel; native facets with multiple panels
#' are rejected during plot building, before statistics are computed.
#' Single-panel facets retain their `shrink` setting and corresponding scale ranges.
#' New headers restore strip settings hidden by [fmt_strip()] and override
#' blank strip elements while retaining existing text sizes and angles.
#' Text settings supplied by ggh4x themed strips are inherited as well.
#'
#' @param plot A ggplot, patchwork, or list of ggplot panels filling an
#'   `nrow x ncol` grid. Row-wise and column-wise filling are supported;
#'   aligned nested rectangular grids retain their layout and annotations.
#'   Spacers and guide areas are skipped while retaining their positions.
#'   Insets retain their placement without consuming grid cells.
#'   Panels made with [patchwork::wrap_elements()] are rejected; format the
#'   original ggplot before wrapping it.
#'   Custom `design` and non-aligned nested layouts are rejected.
#' @param top_label Non-empty character vector of column-header labels without
#'   missing values, recycled to `ncol`. Placed on the top-row panels only.
#'   `NULL` gives no top strips; `""` gives a blank label.
#' @param right_label Non-empty character vector of row labels without missing
#'   values, recycled to `nrow`.
#'   Placed on the right-most occupied panel of each row (rotated 90 degrees).
#'   `NULL` gives no right strips; `""` gives a blank label.
#' @param ncol Single positive integer giving the number of columns in the grid.
#'   If `NULL`, inferred from the patchwork layout, including dimensions implied
#'   by its widths/heights and aligned nested grids. Lists use patchwork's default
#'   grid dimensions. An explicit value must agree with a labelled patchwork's
#'   existing grid.
#' @param top_fill,right_fill Background fill colour(s) for the top / right
#'   strips (recycled to `ncol` / `nrow`). `NULL` = light grey when
#'   `top_right_fill = NULL`. Accepts R colour names, hexadecimal colours,
#'   numeric palette indices and `NA`; `NA` gives a transparent fill.
#' @param label_color Strip text colour. Default `"black"`. Accepts the same
#'   R colour specifications as `top_fill`; `NULL` inherits the text colour
#'   from the theme or existing ggh4x strip.
#' @param top_right_fill Character vector of one or two `colorspace` sequential
#'   HCL palette names used to generate the top and right fills. The first
#'   palette is used for top strips and the second for right strips; a single
#'   palette is reused for both directions. Defaults to
#'   `c("Grays", "Greens")`. Explicit `top_fill` and `right_fill` values take
#'   precedence. Palette lookup is skipped for unused header directions.
#'
#' @details
#' When both label arguments are `NULL`, existing strips are hidden through
#' [fmt_strip()] without evaluating layer data or statistics. Styling and palette
#' arguments are ignored in that case.
#'
#' @return Same type as input: ggplot, patchwork, or list. Input plot and layer
#'   data, mappings and nested container metadata are preserved.
#'
#' @examples
#' library(ggplot2)
#' library(patchwork)
#' d <- data.frame(x = seq_len(6), y = c(2, 4, 3, 6, 5, 8))
#' points <- ggplot(d, aes(x, y)) + geom_point()
#' trend <- ggplot(d, aes(x, y)) + geom_line()
#' grid <- wrap_plots(points, trend, points, trend, ncol = 2)
#' labelled <- fmt_strip2(
#'   grid, top_label = c("Points", "Trend"), right_label = c("Row 1", "Row 2")
#' )
#' labelled
#' \dontshow{print(labelled)}
#'
#' # Aligned nested grids retain their layout; NA gives transparent headers
#' nested <- (points | trend) / (points | trend)
#' transparent <- fmt_strip2(
#'   nested, top_label = c("Points", "Trend"), right_label = c("Row 1", "Row 2"),
#'   ncol = 2, top_fill = NA, right_fill = NA
#' )
#' transparent
#' \dontshow{print(transparent)}
#'
#' @md
#' @export
#' @family plot formatting
#' @seealso [fmt_strip()] for per-plot strip labels;
#'   \code{\link[RegR:get_rcs_all]{RegR::get_rcs_all()}} for the higher-level
#'   RCS composite that uses this helper with `strip_style = "grid"`.
fmt_strip2 <- function(plot,
                       top_label   = NULL,
                       right_label = NULL,
                       ncol        = NULL,
                       top_fill    = NULL,
                       right_fill  = NULL,
                       label_color = "black",
                       top_right_fill = c("Grays", "Greens")) {

  check_dimension <- function(value, arg) {
    if (!is.null(value) && (length(value) != 1L || !is.numeric(value) ||
        is.na(value) || !is.finite(value) || value <= 0 ||
        value > .Machine$integer.max || value != floor(value))) {
      cli::cli_abort("{.arg {arg}} must be a single positive integer or NULL.")
    }
  }
  check_dimension(ncol, "ncol")
  labels <- list(top_label = top_label, right_label = right_label)
  for (arg in names(labels)) {
    value <- labels[[arg]]
    if (!is.null(value) && (!is.character(value) || !length(value) || anyNA(value))) {
      cli::cli_abort("{.arg {arg}} must be NULL or a non-empty character vector without missing values.")
    }
  }
  if (is.null(top_label) && is.null(right_label)) return(fmt_strip(plot, strip = FALSE))
  colours <- list(
    top_fill = if (!is.null(top_label)) top_fill,
    right_fill = if (!is.null(right_label)) right_fill,
    label_color = if (!is.null(top_label) || !is.null(right_label)) label_color
  )
  for (arg in names(colours)) {
    value <- colours[[arg]]
    if (is.null(value)) next
    if (!length(value) ||
        !(is.character(value) || is.numeric(value) || (is.logical(value) && all(is.na(value)))) ||
        (is.numeric(value) && any(!is.finite(value) & !is.na(value)))) {
      cli::cli_abort("{.arg {arg}} must be NULL or a non-empty vector of valid R colours.")
    }
    rgba <- tryCatch(grDevices::col2rgb(value, alpha = TRUE), error = function(e) {
      cli::cli_abort("{.arg {arg}} must contain valid R colours.", parent = e)
    })
    if (anyNA(value)) {
      missing <- is.na(value)
      value <- if (is.numeric(value)) {
        grDevices::rgb(rgba[1, ], rgba[2, ], rgba[3, ], rgba[4, ], maxColorValue = 255)
      } else {
        as.character(value)
      }
      value[missing] <- "transparent"
      colours[[arg]] <- value
    }
  }
  if (!is.null(top_label)) top_fill <- colours$top_fill
  if (!is.null(right_label)) right_fill <- colours$right_fill
  label_color <- colours$label_color
  info  <- .to_plot_list(plot)

  protect_facet <- function(original, replacement) {
    if (!is.null(original$.fmt_strip2_original_facet)) {
      original <- original$.fmt_strip2_original_facet
    }
    replacement$shrink <- original$shrink
    if (inherits(original, "FacetNull") || isTRUE(original$.fmt_strip_generated)) {
      return(replacement)
    }
    guarded <- ggplot2::ggproto(NULL, replacement,
      compute_layout = function(self, data, params) {
        native_params <- original$params
        native_params$plot_env <- params$plot_env
        native_params <- original$setup_params(data, native_params)
        native_data <- original$setup_data(data, native_params)
        if (nrow(original$compute_layout(native_data, native_params)) != 1L) {
          cli::cli_abort(
            "`fmt_strip2()` cannot replace a native facet with multiple panels."
          )
        }
        ggplot2::ggproto_parent(replacement, self)$compute_layout(data, params)
      }
    )
    guarded$.fmt_strip2_original_facet <- original
    guarded
  }

  # Each nested grid contributes its dimensions without rebuilding the container.
  collect_grid <- function(children, lay = NULL, path = integer()) {
    cell_indices <- which(vapply(children, function(p) {
      # Containers ending in an inset inherit its classes, but dispatch as
      # patchworks. An inset wrapped around a patchwork dispatches as an inset.
      !inherits(p, "inset_patch") || (inherits(p, "patchwork") &&
        match("patchwork", class(p)) < match("inset_patch", class(p)))
    }, logical(1)))
    n <- length(cell_indices)
    if (!n) return(list(nrow = 0L, ncol = 0L, entries = list()))
    if (!is.null(lay$design)) {
      cli::cli_abort("`fmt_strip2()` requires a regular grid without a custom `design`.")
    }
    nr <- lay$nrow
    nc <- lay$ncol
    check_dimension(nr, "layout nrow")
    check_dimension(nc, "layout ncol")
    if (is.null(nc) && length(lay$widths) > 1L) nc <- length(lay$widths)
    if (is.null(nr) && length(lay$heights) > 1L) nr <- length(lay$heights)
    if (is.null(nr) && is.null(nc)) {
      dims <- grDevices::n2mfrow(n)
      nr <- dims[2]
      nc <- dims[1]
    } else if (is.null(nc)) {
      nc <- ceiling(n / nr)
    } else if (is.null(nr)) {
      nr <- ceiling(n / nc)
    }
    if (nr * nc < n) cli::cli_abort("The patchwork layout has too few cells for its plots.")
    indices <- seq_len(n) - 1L
    byrow <- is.null(lay$byrow) || isTRUE(lay$byrow)
    rows <- if (byrow) indices %/% nc + 1L else indices %% nr + 1L
    cols <- if (byrow) indices %% nc + 1L else indices %/% nr + 1L
    grids <- lapply(seq_len(n), function(i) {
      child_index <- cell_indices[i]
      p <- children[[child_index]]
      child_path <- c(path, child_index)
      if (inherits(p, "patchwork")) {
        return(collect_grid(lapply(seq_along(p), function(j) p[[j]]),
                            p$patches$layout, child_path))
      }
      if (inherits(p, "wrapped_patch")) {
        cli::cli_abort("Strip formatting cannot modify panels created by {.fn patchwork::wrap_elements}. Format the original ggplot before wrapping it.")
      }
      entries <- if (inherits(p, c("spacer", "guide_area"))) list() else
        list(list(plot = p, path = child_path, row = 1L, col = 1L))
      list(nrow = 1L, ncol = 1L, entries = entries)
    })
    row_sizes <- rep(1L, nr)
    col_sizes <- rep(1L, nc)
    for (i in seq_len(n)) {
      row_sizes[rows[i]] <- max(row_sizes[rows[i]], grids[[i]]$nrow)
      col_sizes[cols[i]] <- max(col_sizes[cols[i]], grids[[i]]$ncol)
    }
    entries <- list()
    for (i in seq_len(n)) {
      child <- grids[[i]]
      if (!length(child$entries)) next
      if (child$nrow != row_sizes[rows[i]] || child$ncol != col_sizes[cols[i]]) {
        cli::cli_abort("Nested patchworks must form aligned rectangular grids.")
      }
      row_offset <- sum(row_sizes[seq_len(rows[i] - 1L)])
      col_offset <- sum(col_sizes[seq_len(cols[i] - 1L)])
      for (entry in child$entries) {
        entry$row <- entry$row + row_offset
        entry$col <- entry$col + col_offset
        entries[[length(entries) + 1L]] <- entry
      }
    }
    list(nrow = sum(row_sizes), ncol = sum(col_sizes), entries = entries)
  }
  lay <- if (info$is_patchwork) info$pw_orig$patches$layout else list(ncol = ncol)
  grid <- collect_grid(info$plots, lay)
  if (info$is_patchwork && !is.null(ncol) && ncol != grid$ncol) {
    cli::cli_abort("`ncol` must agree with the patchwork's existing layout ({grid$ncol}).")
  }
  if (!length(grid$entries)) return(plot)
  ncol <- grid$ncol
  nrow <- grid$nrow
  plots <- lapply(grid$entries, function(entry) entry$plot)
  n <- length(plots)
  grid_rows <- vapply(grid$entries, function(entry) entry$row, integer(1))
  grid_cols <- vapply(grid$entries, function(entry) entry$col, integer(1))
  rightmost <- grid_cols == stats::ave(grid_cols, grid_rows, FUN = max)

  if (!is.null(top_right_fill)) {
    if (!is.character(top_right_fill) || !length(top_right_fill) || length(top_right_fill) > 2L ||
        anyNA(top_right_fill) || any(!nzchar(top_right_fill))) {
      cli::cli_abort(
        "`top_right_fill` must contain one or two non-empty palette names."
      )
    }
    top_right_fill <- rep_len(top_right_fill, 2L)
    make_hcl_fill <- function(palette, n) {
      ramp <- tryCatch(colorspace::sequential_hcl(n = 100L, palette = palette),
        error = function(e) {
          cli::cli_abort("Invalid palette {.val {palette}} in {.arg top_right_fill}.", parent = e)
        }
      )
      start_idx <- if (n == 2L) 40L else 30L
      rev(grDevices::colorRampPalette(ramp[start_idx:80])(n))
    }

    generate_top <- !is.null(top_label) && any(grid_rows == 1L) && is.null(top_fill)
    generate_right <- !is.null(right_label) && is.null(right_fill)
    if (generate_top) {
      top_fill <- make_hcl_fill(top_right_fill[1], ncol)
    }
    if (generate_right) {
      right_fill <- if (generate_top && top_right_fill[1] == top_right_fill[2] && ncol == nrow) {
        top_fill
      } else {
        make_hcl_fill(top_right_fill[2], nrow)
      }
    }
  }

  # ---- recycle labels / fills ----
  if (!is.null(top_label))   top_label   <- rep_len(top_label,   ncol)
  if (!is.null(right_label)) right_label <- rep_len(right_label, nrow)
  if (!is.null(top_fill))    top_fill    <- rep_len(top_fill,    ncol)
  if (!is.null(right_fill))  right_fill  <- rep_len(right_fill,  nrow)

  base_theme <- ggplot2::theme_get()
  base_strip_theme <- base_theme[grepl("^strip\\.", names(base_theme))]
  for (i in seq_len(n)) {
    grid_row <- grid_rows[i]
    grid_col <- grid_cols[i]
    need_top   <- isTRUE(grid_row == 1L)    && !is.null(top_label)
    need_right <- rightmost[i] && !is.null(right_label)
    # Hide native strips without changing their panel membership or statistics.
    if (!need_top && !need_right) {
      plots[[i]] <- fmt_strip(plots[[i]], strip = FALSE)
      next
    }

    p <- plots[[i]]
    original_facet <- p$facet
    hidden <- original_facet$.fmt_strip_hidden
    if (!is.null(hidden)) {
      for (nm in names(hidden$theme)) {
        if (inherits(p$theme[[nm]], "element_blank")) p$theme[[nm]] <- hidden$theme[[nm]]
      }
    }
    visible_elements <- c(
      if (need_top) c("strip.text.x.top", "strip.text.x.bottom", "strip.background.x"),
      if (need_right) c("strip.text.y.left", "strip.text.y.right", "strip.background.y")
    )
    strip_theme <- c(base_strip_theme, p$theme[grepl("^strip\\.", names(p$theme))])
    if (any(vapply(strip_theme, inherits, logical(1), "element_blank"))) {
      plot_theme <- base_theme + p$theme
      for (nm in visible_elements) {
        if (inherits(ggplot2::calc_element(nm, plot_theme), "element_blank")) {
          element <- ggplot2::calc_element(nm, base_theme)
          if (inherits(element, "element_blank")) {
            element <- ggplot2::calc_element(nm, ggplot2::theme_gray())
          }
          element@inherit.blank <- FALSE
          p$theme[[nm]] <- element
        }
      }
    }

    given_text <- if (!is.null(hidden)) hidden$strip$given_elements else
      original_facet$strip$given_elements
    header_text <- function(axis) {
      elements <- ggh4x::elem_list_text(colour = label_color, face = "bold")
      inherited <- given_text[[axis]]
      if (length(inherited) && !inherits(inherited[[1L]], "element_blank")) {
        elements <- lapply(elements, function(element) {
          ggplot2::merge_element(element, inherited[[1L]])
        })
      }
      elements
    }
    top_bg   <- if (!is.null(top_fill))   top_fill[grid_col]  else "grey85"
    right_bg <- if (!is.null(right_fill)) right_fill[grid_row] else "grey85"

    if (need_top && need_right) {
      # facet_grid2: cols -> top strip, rows -> right strip
      p <- p + ggh4x::facet_grid2(
        rows = ggplot2::vars(.right. = !!right_label[grid_row]),
        cols = ggplot2::vars(.top. = !!top_label[grid_col]),
        strip = ggh4x::strip_themed(
          background_x = ggh4x::elem_list_rect(fill = top_bg),
          background_y = ggh4x::elem_list_rect(fill = right_bg),
          text_x = header_text("text_x"),
          text_y = header_text("text_y")
        )
      )
    } else if (need_top) {
      p <- p + ggh4x::facet_wrap2(
        ggplot2::vars(.top. = !!top_label[grid_col]), strip.position = "top",
        strip = ggh4x::strip_themed(
          background_x = ggh4x::elem_list_rect(fill = top_bg),
          text_x = header_text("text_x")
        )
      )
    } else { # need_right only
      p <- p + ggh4x::facet_wrap2(
        ggplot2::vars(.right. = !!right_label[grid_row]), strip.position = "right",
        strip = ggh4x::strip_themed(
          background_y = ggh4x::elem_list_rect(fill = right_bg),
          text_y = header_text("text_y")
        )
      )
    }
    p$facet <- protect_facet(original_facet, p$facet)
    p$facet$.fmt_strip_generated <- is.null(p$facet$.fmt_strip2_original_facet)
    plots[[i]] <- p
  }

  replace_leaf <- function(p, path, value) {
    if (!length(path)) return(value)
    p[[path[1]]] <- replace_leaf(p[[path[1]]], path[-1], value)
    p
  }
  restored <- info$plots
  for (i in seq_len(n)) restored <- replace_leaf(restored, grid$entries[[i]]$path, plots[[i]])
  .from_plot_list(restored, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_panel ----

#' Format panel appearance
#'
#' Control panel grid lines, border, and background in one call.
#' Inspired by Seurat's \code{NoGrid()} but with fine-grained control
#' over each panel element.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param grid Which grid lines to display.
#'   \itemize{
#'     \item \code{"none"} — remove all grid lines (default).
#'     \item \code{"major"} — show only major grid lines.
#'     \item \code{"minor"} — show only minor grid lines.
#'     \item \code{"both"} — show both major and minor grid lines.
#'     \item \code{"x"} — show only vertical (x-axis) major grid lines.
#'     \item \code{"y"} — show only horizontal (y-axis) major grid lines.
#'   }
#' @param grid_color Color of retained grid lines. Default \code{NULL}
#'   (inherit from current theme).
#' @param grid_linewidth Numeric. Line width of retained grid lines.
#'   Default \code{NULL} (inherit from current theme).
#' @param grid_linetype Linetype of retained grid lines (e.g.
#'   \code{"solid"}, \code{"dashed"}, \code{"dotted"}).
#'   Default \code{NULL} (inherit from current theme).
#' @param border Logical or character.
#'   \itemize{
#'     \item \code{TRUE} — draw a black rectangle border around the panel.
#'     \item \code{FALSE} — remove the panel border.
#'     \item A color string (e.g. \code{"grey50"}) — draw border in that color.
#'     \item \code{NULL} (default) — no change.
#'   }
#' @param border_linewidth Numeric. Border line width. Default 0.5.
#' @param bg Panel background color. \code{NULL} (default) = no change,
#'   \code{"white"}, \code{"transparent"}, or any valid color string.
#' @param ... Additional arguments passed to [ggplot2::theme()].
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point()
#'
#' # Remove all grid lines (most common usage, like Seurat::NoGrid())
#' fmt_panel(p)
#'
#' # Keep only major grid lines
#' fmt_panel(p, grid = "major")
#'
#' # Keep only horizontal (y-axis) grid lines
#' fmt_panel(p, grid = "y")
#'
#' # Add border + white background + no grid
#' fmt_panel(p, grid = "none", border = TRUE, bg = "white")
#'
#' # Custom border color
#' fmt_panel(p, border = "grey40", border_linewidth = 1)
#'
#' # Dashed grey grid lines
#' fmt_panel(p, grid = "major", grid_color = "grey80",
#'           grid_linewidth = 0.3, grid_linetype = "dashed")
#'
#' # Dotted y-axis grid only
#' fmt_panel(p, grid = "y", grid_linetype = "dotted", grid_color = "grey70")
#'
#' @export
#' @family plot formatting
fmt_panel <- function(plot,
                      grid = c("none", "major", "minor", "both", "x", "y"),
                      grid_color = NULL,
                      grid_linewidth = NULL,
                      grid_linetype = NULL,
                      border = NULL,
                      border_linewidth = 0.5,
                      bg = NULL,
                      ...) {
  grid <- match.arg(grid)
  blank <- ggplot2::element_blank()

  # ---- Helper: build element_line for retained grid lines ----
  grid_line <- function() {
    args <- list()
    if (!is.null(grid_color))     args$colour   <- grid_color
    if (!is.null(grid_linewidth)) args$linewidth <- grid_linewidth
    if (!is.null(grid_linetype))  args$linetype  <- grid_linetype
    if (length(args) == 0L) return(NULL)
    do.call(ggplot2::element_line, args)
  }
  gl <- grid_line()

  # ---- Build grid theme ----
  grid_theme <- switch(grid,
    "none" = ggplot2::theme(
      panel.grid.major = blank,
      panel.grid.minor = blank
    ),
    "major" = {
      th <- ggplot2::theme(panel.grid.minor = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.major = gl)
      th
    },
    "minor" = {
      th <- ggplot2::theme(panel.grid.major = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.minor = gl)
      th
    },
    "both" = {
      if (!is.null(gl)) ggplot2::theme(panel.grid.major = gl, panel.grid.minor = gl)
      else ggplot2::theme()
    },
    "x" = {
      th <- ggplot2::theme(panel.grid.major.y = blank, panel.grid.minor = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.major.x = gl)
      th
    },
    "y" = {
      th <- ggplot2::theme(panel.grid.major.x = blank, panel.grid.minor = blank)
      if (!is.null(gl)) th <- th + ggplot2::theme(panel.grid.major.y = gl)
      th
    }
  )

  # ---- Build border theme ----
  border_theme <- ggplot2::theme()
  if (!is.null(border)) {
    if (isTRUE(border)) {
      border_theme <- ggplot2::theme(
        panel.border = ggplot2::element_rect(
          colour = "black", fill = NA, linewidth = border_linewidth
        )
      )
    } else if (isFALSE(border)) {
      border_theme <- ggplot2::theme(panel.border = blank)
    } else if (is.character(border)) {
      border_theme <- ggplot2::theme(
        panel.border = ggplot2::element_rect(
          colour = border, fill = NA, linewidth = border_linewidth
        )
      )
    }
  }

  # ---- Build background theme ----
  bg_theme <- ggplot2::theme()
  if (!is.null(bg)) {
    bg_theme <- ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = bg, colour = NA)
    )
  }

  # ---- Combine all + extra ... ----
  extra_theme <- if (length(list(...)) > 0) do.call(ggplot2::theme, list(...)) else ggplot2::theme()
  panel_theme <- grid_theme + border_theme + bg_theme + extra_theme

  # ---- Apply to plots ----
  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, function(p) p + panel_theme)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_text ----

#' Format plot labels and their text style
#'
#' Set and style plot text elements (title, subtitle, caption, axis titles,
#' legend title) in one call. Supports per-plot labels when input is a
#' patchwork or list (pass a vector to \code{xlab}, \code{ylab}, etc.).
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param xlab X-axis title. \code{NULL} = no change, \code{""} = remove.
#'   A vector sets different labels per plot.
#' @param ylab Y-axis title. \code{NULL} = no change, \code{""} = remove.
#'   A vector sets different labels per plot.
#' @param title Plot title. \code{NULL} = no change, \code{""} = remove.
#'   A vector sets different titles per plot.
#' @param subtitle Plot subtitle. \code{NULL} = no change.
#'   A vector sets different subtitles per plot.
#' @param caption Plot caption. \code{NULL} = no change.
#'   A vector sets different captions per plot.
#' @param legend_title Legend title. \code{NULL} = no change, \code{""} = remove.
#' @param title_size Numeric. Title font size. Default \code{NULL}.
#' @param title_face Character. Title font face. Default \code{NULL}.
#' @param title_color Character. Title color. Default \code{NULL}.
#' @param title_hjust Numeric. Title horizontal justification. Default \code{NULL}.
#' @param subtitle_size Numeric. Subtitle font size. Default \code{NULL}.
#' @param subtitle_face Character. Subtitle font face. Default \code{NULL}.
#' @param subtitle_color Character. Subtitle color. Default \code{NULL}.
#' @param caption_size Numeric. Caption font size. Default \code{NULL}.
#' @param caption_face Character. Caption font face. Default \code{NULL}.
#' @param caption_color Character. Caption color. Default \code{NULL}.
#' @param axis_title_size Numeric. Font size for both axis titles. Default \code{NULL}.
#' @param axis_title_face Character. Font face for both axis titles. Default \code{NULL}.
#' @param axis_title_color Character. Color for both axis titles. Default \code{NULL}.
#' @param ... Additional arguments passed to [ggplot2::labs()].
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()
#'
#' # Set labels
#' fmt_text(p, title = "Iris", xlab = "Length", ylab = "Width")
#'
#' # Per-plot labels (patchwork)
#' fmt_text(p + p, ylab = c("Width 1", "Width 2"))
#'
#' @export
#' @family plot formatting
fmt_text <- function(plot,
                     xlab = NULL,
                     ylab = NULL,
                     title = NULL,
                     subtitle = NULL,
                     caption = NULL,
                     legend_title = NULL,
                     title_size = NULL,
                     title_face = NULL,
                     title_color = NULL,
                     title_hjust = NULL,
                     subtitle_size = NULL,
                     subtitle_face = NULL,
                     subtitle_color = NULL,
                     caption_size = NULL,
                     caption_face = NULL,
                     caption_color = NULL,
                     axis_title_size = NULL,
                     axis_title_face = NULL,
                     axis_title_color = NULL,
                     ...) {

  info <- .to_plot_list(plot)
  n <- length(info$plots)

  # ---- Vectorize label params (recycle to n plots) ----
  vec_or_null <- function(x) {
    if (is.null(x)) return(rep(list(NULL), n))
    as.list(rep_len(x, n))
  }
  xlab_vec     <- vec_or_null(xlab)
  ylab_vec     <- vec_or_null(ylab)
  title_vec    <- vec_or_null(title)
  subtitle_vec <- vec_or_null(subtitle)
  caption_vec  <- vec_or_null(caption)

  # ---- Build text style theme ----
  .build_element <- function(size, face, color, hjust = NULL) {
    args <- list()
    if (!is.null(size))  args$size   <- size
    if (!is.null(face))  args$face   <- face
    if (!is.null(color)) args$colour <- color
    if (!is.null(hjust)) args$hjust  <- hjust
    if (length(args) == 0L) return(NULL)
    do.call(ggplot2::element_text, args)
  }

  theme_args <- list()
  el <- .build_element(title_size, title_face, title_color, title_hjust)
  if (!is.null(el)) theme_args$plot.title <- el
  el <- .build_element(subtitle_size, subtitle_face, subtitle_color)
  if (!is.null(el)) theme_args$plot.subtitle <- el
  el <- .build_element(caption_size, caption_face, caption_color)
  if (!is.null(el)) theme_args$plot.caption <- el
  el <- .build_element(axis_title_size, axis_title_face, axis_title_color)
  if (!is.null(el)) theme_args$axis.title <- el

  style_theme <- if (length(theme_args) > 0L) {
    do.call(ggplot2::theme, theme_args)
  } else {
    NULL
  }

  # ---- Handle legend title (guides + labs for full override) ----
  legend_layer <- NULL
  if (!is.null(legend_title)) {
    if (legend_title == "") {
      legend_layer <- ggplot2::theme(legend.title = ggplot2::element_blank())
    } else {
      guide_obj <- ggplot2::guide_legend(title = legend_title)
      legend_layer <- list(
        ggplot2::labs(fill = legend_title, colour = legend_title,
                      shape = legend_title, size = legend_title,
                      alpha = legend_title, linetype = legend_title),
        ggplot2::guides(fill = guide_obj, colour = guide_obj,
                        shape = guide_obj, size = guide_obj,
                        alpha = guide_obj, linetype = guide_obj,
                        color = guide_obj)
      )
    }
  }

  # ---- Extra labs via ... ----
  extra_labs <- list(...)
  extra_layer <- if (length(extra_labs) > 0L) {
    do.call(ggplot2::labs, extra_labs)
  } else {
    NULL
  }

  # ---- Apply per plot ----
  for (i in seq_len(n)) {
    p <- info$plots[[i]]
    labs_i <- list()
    if (!is.null(xlab_vec[[i]]))     labs_i$x        <- xlab_vec[[i]]
    if (!is.null(ylab_vec[[i]]))     labs_i$y        <- ylab_vec[[i]]
    if (!is.null(title_vec[[i]]))    labs_i$title    <- title_vec[[i]]
    if (!is.null(subtitle_vec[[i]])) labs_i$subtitle <- subtitle_vec[[i]]
    if (!is.null(caption_vec[[i]]))  labs_i$caption  <- caption_vec[[i]]
    if (length(labs_i) > 0L) p <- p + do.call(ggplot2::labs, labs_i)
    if (!is.null(extra_layer))  p <- p + extra_layer
    if (!is.null(style_theme))  p <- p + style_theme
    if (!is.null(legend_layer)) {
      if (is.list(legend_layer) && !inherits(legend_layer, "theme")) {
        for (ll in legend_layer) p <- p + ll
      } else {
        p <- p + legend_layer
      }
    }
    info$plots[[i]] <- p
  }

  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_axisText ----

#' Format axis text rotation and style
#'
#' Rotate and style axis tick labels for X and/or Y axes. Inspired by
#' Seurat's \code{RotatedAxis()} but with independent control over both
#' axes, rotation angle, and text appearance.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param x Finite numeric scalar. Rotation angle (degrees) for X-axis text.
#'   Common values: \code{45} (diagonal), \code{90} (vertical).
#'   Default \code{NULL} (no change).
#' @param y Finite numeric scalar. Rotation angle (degrees) for Y-axis text.
#'   Default \code{NULL} (no change).
#' @param x_hjust Finite numeric scalar. Horizontal justification for X-axis text.
#'   Can be set without supplying `x`.
#'   Default \code{NULL}: automatic alignment follows the bottom or top axis side
#'   when `x` is supplied; otherwise the existing alignment is retained.
#' @param x_vjust Finite numeric scalar. Vertical justification for X-axis text.
#'   Can be set without supplying `x`.
#'   Default \code{NULL}: automatic alignment follows the bottom or top axis side
#'   when `x` is supplied; otherwise the existing alignment is retained.
#' @param y_hjust Finite numeric scalar. Horizontal justification for Y-axis text.
#'   Can be set without supplying `y`.
#'   Default \code{NULL}: automatic alignment follows the left or right axis side
#'   when `y` is supplied; otherwise the existing alignment is retained.
#' @param y_vjust Finite numeric scalar. Vertical justification for Y-axis text.
#'   Can be set without supplying `y`.
#'   Default \code{NULL}: automatic alignment follows the left or right axis side
#'   when `y` is supplied; otherwise the existing alignment is retained.
#' @param size Non-negative finite numeric scalar. Text size in points for both
#'   axes, or [ggplot2::rel()] relative to the parent axis text size.
#'   Default \code{NULL} (no change).
#' @param color One valid R color or numeric palette index for both axes.
#'   `NA` makes text transparent. Default \code{NULL} (no change).
#' @param face Character. Font face (\code{"plain"}, \code{"bold"},
#'   \code{"italic"}, \code{"oblique"}, \code{"bold.italic"}). Default \code{NULL}
#'   (no change).
#' @param ... Additional arguments passed to [ggplot2::theme()], applied after
#'   the generated formatting. Explicit axis text fields in these arguments
#'   take precedence; side-specific fields take precedence over their parent.
#'
#' @details Data plots are edited recursively within nested patchworks and lists.
#'   Layouts, annotations, list names and freed alignment are retained. Spacers,
#'   guide areas, fixed wrapped graphics and inset overlays are not edited.
#'   Styling also updates explicitly styled axis sides and radial text elements.
#'   Explicitly blank side elements are retained.
#'   Guide-local themes and rotation settings are updated without modifying the
#'   original guides or their other settings. With justification alone, an
#'   existing guide rotation is retained.
#'   Guide formatting retains text classes inherited from the plot theme.
#'   Existing text element classes, including rich text elements, are retained.
#'   Text inherited from the global theme is retained unless a complete plot
#'   theme overrides it.
#'   Automatic Cartesian alignment follows each rendered axis side and treats
#'   full turns periodically. Explicit justification takes precedence.
#'   Justification values may lie outside the usual 0--1 interval.
#'   When every formatting argument is `NULL` and `...` is empty, the validated
#'   input object is returned unchanged without evaluating plot data.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' dat <- data.frame(
#'   category = factor(rep(c("Alpha", "Beta", "Gamma"), each = 3)),
#'   value = c(2, 3, 4, 4, 5, 6, 1, 2, 3)
#' )
#' p <- ggplot(dat, aes(category, value)) + geom_boxplot()
#'
#' # Rotate X-axis 45 degrees (like Seurat::RotatedAxis())
#' fmt_axisText(p, x = 45)
#'
#' # Rotate X-axis 90 degrees (vertical)
#' fmt_axisText(p, x = 90)
#'
#' # Rotate both axes
#' fmt_axisText(p, x = 45, y = -30)
#'
#' # With custom size and bold
#' fmt_axisText(p, x = 45, size = 10, face = "bold")
#'
#' # Adjust justification while retaining the existing angle
#' fmt_axisText(p, x_hjust = 0.2)
#'
#' # Preserve a nested layout and named list
#' nested <- patchwork::wrap_plots(p, p, nrow = 1)
#' fmt_axisText(list(main = nested, detail = p), x = 45)
#'
#' @md
#' @export
#' @family plot formatting
fmt_axisText <- function(plot,
                     x = NULL,
                     y = NULL,
                     x_hjust = NULL,
                     x_vjust = NULL,
                     y_hjust = NULL,
                     y_vjust = NULL,
                     size = NULL,
                     color = NULL,
                     face = NULL,
                     ...) {

  values <- list(x = x, y = y, x_hjust = x_hjust, x_vjust = x_vjust,
                   y_hjust = y_hjust, y_vjust = y_vjust, size = size)
  dots <- list(...)
  if (all(vapply(values, is.null, logical(1))) && is.null(color) &&
      is.null(face) && !length(dots)) {
    .to_plot_list(plot)
    return(plot)
  }
  for (name in names(values)) {
    value <- values[[name]]
    if (!is.null(value) && (!is.numeric(value) || length(value) != 1L ||
        !is.null(dim(value)) || !is.finite(value))) {
      stop(sprintf("`%s` must be NULL or a finite numeric scalar.", name), call. = FALSE)
    }
  }
  if (!is.null(size) && size < 0) {
    stop("`size` must be non-negative.", call. = FALSE)
  }
  if (!is.null(color) && (!(is.character(color) || is.numeric(color) ||
      identical(color, NA)) || length(color) != 1L || !is.null(dim(color)) ||
      (is.numeric(color) && !is.na(color) && !is.finite(color)) ||
      !tryCatch({ grDevices::col2rgb(color); TRUE }, error = function(e) FALSE,
                  warning = function(w) FALSE))) {
    stop("`color` must be NULL or one valid R color, palette index or NA.", call. = FALSE)
  }
  if (!is.null(face) && (!is.character(face) || length(face) != 1L ||
      !is.null(dim(face)) || is.na(face) ||
      !face %in% c("plain", "bold", "italic", "oblique", "bold.italic"))) {
    stop("`face` must be NULL or one of plain, bold, italic, oblique or bold.italic.",
         call. = FALSE)
  }

  # ---- Auto-compute hjust/vjust for rotated text ----
  auto_just <- function(angle, hjust, vjust, side = "bottom") {
    if (is.null(angle)) return(list(hjust = hjust, vjust = vjust))
    radians <- (angle %% 360) * pi / 180
    sine <- sin(radians)
    cosine <- cos(radians)
    sine <- if (abs(sine) < 1e-12) 0 else sign(sine)
    cosine <- if (abs(cosine) < 1e-12) 0 else sign(cosine)
    defaults <- switch(side,
      bottom = c(0.5 + 0.5 * sine, 0.5 + 0.5 * cosine),
      top = c(0.5 - 0.5 * sine, 0.5 - 0.5 * cosine),
      left = c(0.5 + 0.5 * cosine, 0.5 - 0.5 * sine),
      right = c(0.5 - 0.5 * cosine, 0.5 + 0.5 * sine))
    if (is.null(hjust)) hjust <- defaults[1L]
    if (is.null(vjust)) vjust <- defaults[2L]
    list(hjust = hjust, vjust = vjust)
  }

  # ---- Build X-axis text theme ----
  x_args <- list()
  if (!is.null(x) || !is.null(x_hjust) || !is.null(x_vjust) ||
      !is.null(size) || !is.null(color) || !is.null(face)) {
    x_just <- auto_just(x, x_hjust, x_vjust, "bottom")
    if (!is.null(x))     x_args$angle <- x
    if (!is.null(x_just$hjust)) x_args$hjust <- x_just$hjust
    if (!is.null(x_just$vjust)) x_args$vjust <- x_just$vjust
    if (!is.null(size))  x_args$size  <- size
    if (!is.null(color)) x_args$colour <- color
    if (!is.null(face))  x_args$face  <- face
  }

  # ---- Build Y-axis text theme ----
  y_args <- list()
  if (!is.null(y) || !is.null(y_hjust) || !is.null(y_vjust) ||
      !is.null(size) || !is.null(color) || !is.null(face)) {
    y_just <- auto_just(y, y_hjust, y_vjust, "left")
    if (!is.null(y))     y_args$angle <- y
    if (!is.null(y_just$hjust)) y_args$hjust <- y_just$hjust
    if (!is.null(y_just$vjust)) y_args$vjust <- y_just$vjust
    if (!is.null(size))  y_args$size  <- size
    if (!is.null(color)) y_args$colour <- color
    if (!is.null(face))  y_args$face  <- face
  }

  # ---- Combine + extra ... ----
  extra <- if (length(dots)) do.call(ggplot2::theme, dots) else NULL
  element_names <- names(ggplot2::get_element_tree())
  text_theme_for <- function(theme, axes = c("x", "y"), guide_angle = NULL) {
    if (!is.null(extra)) theme <- theme + extra
    args <- list()
    for (axis in axes) {
      fields <- if (axis == "x") x_args else y_args
      if (!length(fields)) next
      if (!is.null(guide_angle)) fields$angle <- guide_angle
      sides <- if (axis == "x") c("bottom", "top") else c("left", "right")
      parent <- paste0("axis.text.", axis)
      elements <- c(parent, paste0(parent, ".", sides),
                      paste0("axis.text.", if (axis == "x") "theta" else "r"))
      elements <- intersect(elements, element_names)
      for (name in elements) {
        element <- theme[[name]]
        side <- if (name %in% paste0(parent, ".", sides)) sub(".*\\.", "", name) else sides[1L]
        if (is.null(element) && name != parent &&
            (is.null(fields$angle) || !(name %in% paste0(parent, ".", sides)) ||
             inherits(theme[[parent]], "element_blank"))) next
        if (inherits(element, "element_blank")) {
          args[[name]] <- element
          next
        }
        if (is.null(element)) {
          inherited <- theme[[parent]]
          element <- if (inherits(inherited, "element_text")) inherited else ggplot2::element_text()
          if (inherits(element$size, "rel")) element$size <- ggplot2::rel(1)
        }
        element_fields <- fields
        if (inherits(fields$size, "rel") && name != parent) {
          element_fields$size <- ggplot2::rel(1)
        }
        just <- auto_just(fields$angle, if (axis == "x") x_hjust else y_hjust,
                            if (axis == "x") x_vjust else y_vjust, side)
        if (!is.null(just$hjust)) element_fields$hjust <- just$hjust
        if (!is.null(just$vjust)) element_fields$vjust <- just$vjust
        if (name != parent && inherits(extra[[parent]], "element_text")) {
          for (field in names(element_fields)) {
            value <- extra[[parent]][[field]]
            if (!is.null(value)) {
              element_fields[[field]] <- if (field == "size" && inherits(value, "rel"))
                ggplot2::rel(1) else value
            }
          }
        }
        for (field in names(element_fields)) element[[field]] <- element_fields[[field]]
        args[[name]] <- element
      }
    }
    output <- do.call(ggplot2::theme, args)
    if (is.null(extra)) output else output + extra
  }
  format_guide <- function(guide, axis, plot_theme) {
    if (!inherits(guide, "GuideAxis")) return(guide)
    fields <- if (axis == "x") x_args else y_args
    params <- guide$params
    reset_angle <- any(c("angle", "hjust", "vjust") %in% names(fields)) &&
      !is.null(params$angle) && !inherits(params$angle, "waiver")
    if (is.null(params$theme) && !reset_angle) return(guide)
    angle <- if (reset_angle && is.null(fields$angle)) params$angle else NULL
    theme <- if (is.null(params$theme)) ggplot2::theme() else params$theme
    params$theme <- theme + text_theme_for(plot_theme + theme,
                                           axes = axis, guide_angle = angle)
    if (reset_angle) params$angle <- NULL
    ggplot2::ggproto(NULL, guide, params = params)
  }

  # ---- Apply to plots ----
  info <- .to_plot_list(plot, recurse = TRUE)
  axes <- c(if (length(x_args)) "x", if (length(y_args)) "y")
  global_theme <- ggplot2::theme_get()
  info$plots <- lapply(info$plots, function(p) {
    p <- p + text_theme_for(global_theme + p$theme)
    radial <- inherits(p$coordinates, "CoordRadial")
    guide_axes <- if (radial) c(x = "theta", y = "r")[axes] else
      stats::setNames(axes, axes)
    if (inherits(p$guides, "Guides")) {
      guides <- p$guides$guides
      for (axis in axes) {
        for (name in intersect(c(guide_axes[[axis]], paste0(guide_axes[[axis]], ".sec")),
                                names(guides))) {
          guides[[name]] <- format_guide(guides[[name]], axis, p$theme)
        }
      }
      if (!identical(guides, p$guides$guides)) {
        p$guides <- do.call(ggplot2::ggproto, list(NULL, p$guides, guides = guides))
      }
    }
    scale_axes <- if (radial) c(x = p$coordinates$theta, y = p$coordinates$r)[axes] else
      if (inherits(p$coordinates, "CoordFlip")) c(x = "y", y = "x")[axes] else guide_axes
    scales <- lapply(p$scales$scales, function(scale) {
      selected <- axes[scale_axes %in% scale$aesthetics]
      if (!length(selected)) return(scale)
      axis <- selected[1L]
      guide <- format_guide(scale$guide, axis, p$theme)
      secondary <- scale$secondary.axis
      secondary_guide <- if (!is.null(secondary))
        format_guide(secondary$guide, axis, p$theme) else NULL
      if (identical(guide, scale$guide) &&
          identical(secondary_guide, if (!is.null(secondary)) secondary$guide else NULL)) {
        return(scale)
      }
      if (!is.null(secondary) && !identical(secondary_guide, secondary$guide)) {
        secondary <- do.call(ggplot2::ggproto, list(NULL, secondary, guide = secondary_guide))
      }
      ggplot2::ggproto(NULL, scale, guide = guide, secondary.axis = secondary)
    })
    if (!identical(scales, p$scales$scales)) {
      p$scales <- do.call(ggplot2::ggproto, list(NULL, p$scales, scales = scales))
    }
    p
  })
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig,
                  recurse = TRUE)
}

# ---- fmt_axisTile ----

#' Color discrete axis tiles or text labels
#'
#' Insert colored tiles at the discrete axis or color its text labels.
#' Colors are matched to trained scale values, independently of displayed
#' labels. Scale order, selected breaks, dropped levels and missing categories
#' are respected. Data and statistics are evaluated only when the plot is built.
#' Two modes are available:
#' \itemize{
#'   \item \code{"tile"} (default) — draw a colored strip between the
#'     axis line and labels using the axis guide. Axis titles are retained.
#'   \item \code{"text"} — color individual axis labels without vectorized
#'     theme elements or a background tile.
#' }
#'
#' Only Cartesian coordinates, including \code{coord_flip()}, are supported.
#' Continuous axes and disabled axis guides retain their displayed appearance.
#' Other guide kinds are left unchanged; coloring adapts \code{GuideAxis} objects
#' and the default \code{"axis"} guide.
#' Tile positions follow each panel's trained scale and expansion, including
#' free facets. Existing guide settings, axis titles and scale labels are retained.
#' Rich-text axis elements retain their class, markup and layout properties.
#' In patchworks, color strips are collected together with matching axis guides.
#' Editable leaves in nested patchworks and named lists are formatted while
#' layouts, annotations, fixed graphics and inset overlays are preserved.
#' Repeated calls update the formatting and can switch between modes.
#' Subsequent calls to \code{\link[=fmt_axis]{fmt_axis()}} or
#' \code{\link[=fmt_axisText]{fmt_axisText()}} can hide or restyle the guides.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param colors Named character vector of colors, where names match the
#'   discrete axis levels (e.g. \code{c(setosa = "red", virginica = "blue")}).
#'   Required; names must be unique and non-empty. Missing colors use
#'   \code{"grey70"} in tile mode or \code{text_color} in text mode.
#' @param mode \code{"tile"} (default) or \code{"text"}.
#' @param axis Physical axis to apply to: \code{"x"} (horizontal, default) or
#'   \code{"y"} (vertical), including after \code{coord_flip()}.
#' @param tile_height Positive finite numeric. Relative height of the tile strip when
#'   \code{axis = "x"}, as a fraction of the main panel height. Default 0.06.
#' @param tile_width Positive finite numeric. Relative width of the tile strip when
#'   \code{axis = "y"}, as a fraction of the main panel width. Default 0.06.
#' @param tile_border Color of tile borders. Default \code{"white"}.
#' @param tile_border_width Non-negative finite line width of tile borders. Default 0.2.
#' @param text_size Positive finite size of axis text labels below/beside tiles. Default 9.
#' @param text_face Font face name or number from 1 to 5. Default \code{"plain"}.
#' @param text_angle Rotation angle for axis text labels. Default \code{45}
#'   for x-axis, \code{0} for y-axis.
#' @param text_color Color of tile-mode labels and fallback for unmatched
#'   text-mode labels. Default \code{"black"}.
#' @param show_text Logical. Show text labels below/beside tiles?
#'   Default \code{TRUE}. Set \code{FALSE} to hide labels in either mode.
#'
#' @return In tile mode, a formatted standalone ggplot is wrapped in a patchwork;
#'   patchworks retain their container and lists return lists of formatted plots.
#'   Text mode retains the input container type. Empty-data and disabled-guide
#'   plots are unchanged.
#'
#' @examples
#' library(ggplot2)
#' dat <- data.frame(
#'   category = factor(rep(c("A", "B", "C"), each = 4)),
#'   value = c(2, 3, 4, 5, 4, 5, 7, 8, 1, 2, 3, 4)
#' )
#' cols <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")
#' p <- ggplot(dat, aes(category, value)) + geom_boxplot()
#'
#' # Tile mode: color strip between axis and rotated labels
#' fmt_axisTile(p, colors = cols)
#'
#' # Tile mode: no text labels, color-only strip
#' fmt_axisTile(p, colors = cols, show_text = FALSE)
#'
#' # Text mode: colored axis labels (no tiles)
#' fmt_axisTile(p, colors = cols, mode = "text")
#'
#' # Y-axis tiles
#' p2 <- ggplot(dat, aes(value, category)) + geom_boxplot()
#' fmt_axisTile(p2, colors = cols, axis = "y")
#'
#' # Match colors to scale values rather than their display labels
#' p3 <- p + scale_x_discrete(limits = c("C", "B", "A"),
#'                          labels = c(C = "Gamma", B = "Beta", A = "Alpha"))
#' fmt_axisTile(p3, colors = cols)
#'
#' # Select the physical vertical axis after flipping
#' fmt_axisTile(p + coord_flip(), colors = cols, axis = "y")
#'
#' @export
#' @family plot formatting
fmt_axisTile <- function(plot,
                         colors,
                         mode = c("tile", "text"),
                         axis = c("x", "y"),
                         tile_height = 0.06,
                         tile_width = 0.06,
                         tile_border = "white",
                         tile_border_width = 0.2,
                         text_size = 9,
                         text_face = "plain",
                         text_angle = NULL,
                         text_color = "black",
                         show_text = TRUE) {

  if (!requireNamespace("patchwork", quietly = TRUE))
    cli::cli_abort("Package {.pkg patchwork} is required for fmt_axisTile().")

  mode <- match.arg(mode)
  axis <- match.arg(axis)

  if (!is.character(colors) || !length(colors) || is.null(names(colors)) ||
      anyNA(names(colors)) || any(!nzchar(trimws(names(colors)))) ||
      anyDuplicated(names(colors))) {
    cli::cli_abort("{.arg colors} must be a non-empty character vector with unique, non-empty names.")
  }
  colour_args <- list(colors = colors, tile_border = tile_border, text_color = text_color)
  for (arg in names(colour_args)) {
    value <- colour_args[[arg]]
    if (arg != "colors" && (length(value) != 1L ||
        !(is.character(value) || identical(value, NA)))) {
      cli::cli_abort("{.arg {arg}} must be one valid R colour or NA.")
    }
    tryCatch(grDevices::col2rgb(value, alpha = TRUE), error = function(e) {
      cli::cli_abort("{.arg {arg}} must contain valid R colours.", parent = e)
    })
  }
  numeric_args <- list(tile_height = tile_height, tile_width = tile_width,
                       tile_border_width = tile_border_width, text_size = text_size,
                       text_angle = text_angle)
  for (arg in names(numeric_args)) {
    value <- numeric_args[[arg]]
    if (arg == "text_angle" && is.null(value)) next
    positive <- arg %in% c("tile_height", "tile_width", "text_size")
    if (length(value) != 1L || !is.numeric(value) || is.complex(value) ||
        is.object(value) || !is.finite(value) ||
        (arg != "text_angle" && if (positive) value <= 0 else value < 0)) {
      cli::cli_abort("{.arg {arg}} must be one finite numeric value{if (positive) ' greater than zero' else if (arg != 'text_angle') ' at least zero' else ''}.")
    }
  }
  if (length(show_text) != 1L || !is.logical(show_text) || is.na(show_text)) {
    cli::cli_abort("{.arg show_text} must be TRUE or FALSE.")
  }
  if (length(text_face) != 1L || is.na(text_face) ||
      !(is.character(text_face) && text_face %in% c("plain", "bold", "italic", "bold.italic", "symbol") ||
        is.numeric(text_face) && !is.complex(text_face) && text_face %in% 1:5)) {
    cli::cli_abort("{.arg text_face} must be one valid font face name or number from 1 to 5.")
  }

  # Default text_angle: 45 for x-axis, 0 for y-axis
  if (is.null(text_angle)) text_angle <- if (axis == "x") 45 else 0

  info <- .to_plot_list(plot, recurse = TRUE)
  format_one <- function(p) {
    if (!inherits(p$coordinates, "CoordCartesian")) {
      cli::cli_abort("fmt_axisTile() supports Cartesian coordinates only, including coord_flip().")
    }
    if (is.data.frame(p$data) && nrow(p$data) == 0L &&
        all(vapply(p$layers, function(layer) {
          is.null(layer$data) || inherits(layer$data, "waiver") ||
            is.data.frame(layer$data) && nrow(layer$data) == 0L
        }, logical(1)))) return(p)
    original <- p$guides$guides[[axis]]
    scale_axis <- if (inherits(p$coordinates, "CoordFlip")) {
      if (axis == "x") "y" else "x"
    } else axis
    scale <- p$scales$get_scales(scale_axis)
    if (is.null(original) && !is.null(scale)) original <- scale$guide
    if (inherits(original, "AxisTileGuide")) {
      params <- original$params
      params$axis_tile <- NULL
      original <- do.call(ggplot2::ggproto, list(NULL, original$axis_tile_parent, params = params))
    }
    if (!inherits(original, "GuideAxis")) {
      if (is.null(original) || inherits(original, "waiver") || identical(original, "axis")) {
        original <- ggplot2::guide_axis()
      } else return(p)
    }
    guide <- .axis_tile_guide(original, list(
      colors = colors, mode = mode, tile_height = tile_height, tile_width = tile_width,
      tile_border = tile_border, tile_border_width = tile_border_width,
      text_size = text_size, text_face = text_face, text_angle = text_angle,
      text_color = text_color, show_text = show_text,
      theme = ggplot2::theme_get() + p$theme
    ))
    p <- p + do.call(ggplot2::guides, stats::setNames(list(guide), axis))
    facet <- p$facet
    if (inherits(facet, "AxisTileFacet")) facet <- facet$axis_tile_parent
    if (any(vapply(p$guides$guides, function(g) {
      inherits(g, "AxisTileGuide") && identical(g$params$axis_tile$mode, "tile")
    }, logical(1)))) facet <- .axis_tile_facet(facet)
    p$facet <- facet
    p
  }
  info$plots <- lapply(info$plots, format_one)
  result <- .from_plot_list(info$plots, info$is_patchwork, info$is_single,
                            pw_orig = info$pw_orig, recurse = TRUE)
  if (mode == "tile" && !info$is_patchwork) {
    if (info$is_single) {
      if (!identical(result, plot)) result <- patchwork::wrap_plots(result)
    } else {
      for (i in seq_along(result)) {
        if (!inherits(plot[[i]], "patchwork") && !identical(result[[i]], plot[[i]])) {
          result[[i]] <- patchwork::wrap_plots(result[[i]])
        }
      }
    }
  }
  result
}

#' Adapt an axis guide to color trained discrete categories
#' @noRd
.axis_tile_guide <- function(parent, settings) {
  params <- parent$params
  params$axis_tile <- settings
  ggplot2::ggproto("AxisTileGuide", parent,
    axis_tile_parent = parent,
    params = params,
    hashables = c(parent$hashables, rlang::exprs(axis_tile)),
    extract_key = function(scale, aesthetic, ...) {
      key <- parent$extract_key(scale, aesthetic, ...)
      if (!scale$is_discrete() || settings$mode == "text") return(key)
      values <- scale$get_limits()
      if (!length(values)) return(key)
      positions <- scale$map(values)
      full <- data.frame(.value = values, .fmt_lower = positions - 0.5,
                           .fmt_upper = positions + 0.5)
      full[[aesthetic]] <- positions
      index <- match(values, key$.value)
      full$.label <- if (is.null(key)) rep(NA_character_, length(values)) else key$.label[index]
      full$.fmt_label <- !is.na(index)
      full
    },
    extract_params = function(scale, params, ...) {
      params <- parent$extract_params(scale, params, ...)
      params$fmt_discrete <- scale$is_discrete()
      params
    },
    transform = function(params, coord, panel_params) {
      original <- params
      params <- parent$transform(params, coord, panel_params)
      if (!isTRUE(params$fmt_discrete) || settings$mode != "tile") return(params)
      display_axis <- if (params$position %in% c("left", "right")) "y" else "x"
      for (field in c(".fmt_lower", ".fmt_upper")) {
        bounds <- original
        bounds$decor <- NULL
        bounds$key[[original$aesthetic]] <- original$key[[field]]
        bounds <- parent$transform(bounds, coord, panel_params)
        params$key[[field]] <- bounds$key[[display_axis]]
      }
      params
    },
    draw = function(self, theme, position = NULL, direction = NULL, params = self$params) {
      if (!isTRUE(params$fmt_discrete)) {
        return(parent$draw(theme, position, direction, params))
      }
      ggplot2::ggproto_parent(parent, self)$draw(theme, position, direction, params)
    },
    override_elements = function(params, elements, theme) {
      params$angle <- settings$text_angle
      elements <- parent$override_elements(params, elements, theme)
      active <- theme
      baseline <- settings$theme
      if (!is.null(params$theme)) active <- active + params$theme
      if (!is.null(parent$params$theme)) baseline <- baseline + parent$params$theme
      axis <- if (params$vertical) "y" else "x"
      if (settings$mode == "tile" && inherits(elements$ticks, "element_blank")) {
        tick_names <- c("axis.ticks", paste0("axis.ticks.", axis),
                          paste0("axis.ticks.", axis, ".", params$position))
        elements$fmt_hide_tiles <- any(vapply(tick_names, function(name) {
          !identical(active[[name]], baseline[[name]])
        }, logical(1)))
      }
      if (settings$show_text) {
        angle <- settings$text_angle
        text <- elements$text
        if (!inherits(text, "element_text")) text <- ggplot2::element_text()
        text$colour <- settings$text_color
        text$size <- settings$text_size
        text$face <- settings$text_face
        text$angle <- angle
        text$inherit.blank <- FALSE
        text_names <- c("axis.text", paste0("axis.text.", axis),
                          paste0("axis.text.", axis, ".", params$position))
        blank_changed <- FALSE
        for (name in text_names) {
          updated <- active[[name]]
          previous <- baseline[[name]]
          if (identical(updated, previous)) next
          if (inherits(updated, "element_blank")) blank_changed <- TRUE
          if (!inherits(updated, "element_text")) next
          for (field in c("colour", "size", "face", "angle", "hjust", "vjust")) {
            value <- updated[[field]]
            old <- if (inherits(previous, "element_text")) previous[[field]] else NULL
            if (!is.null(value) && !identical(value, old)) {
              if (field == "size" && inherits(value, "rel")) value <- elements$text$size
              text[[field]] <- value
              if (field == "colour") elements$fmt_colour_override <- TRUE
            }
          }
        }
        inherited <- elements$text
        if (blank_changed && inherits(inherited, "element_blank")) {
          text <- inherited
        } else if (inherits(inherited, "element_blank")) {
          inherited <- ggplot2::calc_element("axis.text", ggplot2::theme_gray())
        }
        elements$text <- ggplot2::merge_element(text, inherited)
      } else elements$text <- ggplot2::element_blank()
      if (settings$mode == "tile") {
        elements$major_length <- grid::unit(0, "cm")
        elements$minor_length <- grid::unit(0, "cm")
      }
      elements
    },
    build_ticks = function(key, elements, params, ...) {
      if (settings$mode != "tile") return(parent$build_ticks(key, elements, params, ...))
      if (isTRUE(elements$fmt_hide_tiles)) return(grid::nullGrob())
      low <- pmax(0, pmin(key$.fmt_lower, key$.fmt_upper))
      high <- pmin(1, pmax(key$.fmt_lower, key$.fmt_upper))
      keep <- is.finite(low) & is.finite(high) & high > low
      fill <- unname(settings$colors[as.character(key$.value[keep])])
      fill[is.na(fill)] <- "grey70"
      position <- (low[keep] + high[keep]) / 2
      width <- high[keep] - low[keep]
      tile <- grid::rectGrob(
        x = if (params$vertical) 0.5 else position,
        y = if (params$vertical) position else 0.5,
        width = if (params$vertical) 1 else width,
        height = if (params$vertical) width else 1,
        default.units = "npc", name = "axis-color-tiles",
        gp = grid::gpar(fill = fill, col = settings$tile_border,
                        lwd = settings$tile_border_width * 72.27 / 25.4)
      )
      attr(tile, "axis_tile") <- list(vertical = params$vertical, position = params$position,
        fraction = if (params$vertical) settings$tile_width else settings$tile_height)
      tile
    },
    build_labels = function(key, elements, params) {
      if (settings$mode == "tile") key <- key[key$.fmt_label, , drop = FALSE]
      labels <- parent$build_labels(key, elements, params)
      if (settings$mode != "text" || !settings$show_text || !nrow(key) ||
          isTRUE(elements$fmt_colour_override)) return(labels)
      fill <- unname(settings$colors[as.character(key$.value)])
      fill[is.na(fill)] <- settings$text_color
      index_at <- function(positions) {
        index <- match(positions, key[[params$aes]])
        for (i in which(is.na(index))) {
          index[i] <- which.min(abs(key[[params$aes]] - positions[i]))
        }
        index
      }
      color_labels <- function(g, index = NULL) {
        if (inherits(g, "richtext_grob")) {
          for (i in seq_along(g$children)) {
            child <- g$children[[i]]
            position <- as.numeric(if (params$vertical) child$y else child$x)
            g$children[[i]] <- color_labels(child, index_at(position))
          }
          return(g)
        }
        if (inherits(g, "text")) {
          if (is.null(index)) index <- index_at(as.numeric(if (params$vertical) g$y else g$x))
          g$gp$col <- fill[index]
        }
        for (i in seq_along(g$children)) g$children[[i]] <- color_labels(g$children[[i]], index)
        g
      }
      lapply(labels, color_labels)
    }
  )
}

#' Attach axis-guide tiles using the panel's relative dimensions
#' @noRd
.axis_tile_facet <- function(parent) {
  ggplot2::ggproto("AxisTileFacet", parent,
    axis_tile_parent = parent,
    draw_panels = function(...) {
      table <- parent$draw_panels(...)
      strips <- list()
      for (i in grep("^axis-[bltr]", table$layout$name)) {
        tile <- NULL
        remove_tile <- function(g) {
          if (identical(g$name, "axis-color-tiles")) {
            tile <<- g
            return(grid::nullGrob())
          }
          if (inherits(g, "gtable")) {
            g$grobs <- lapply(g$grobs, remove_tile)
          } else {
            for (j in seq_along(g$children)) g$children[[j]] <- remove_tile(g$children[[j]])
          }
          g
        }
        axis <- remove_tile(table$grobs[[i]])
        if (is.null(tile)) next
        settings <- attr(tile, "axis_tile")
        lines <- which(vapply(axis$children, inherits, logical(1), "polyline"))
        strip <- if (length(lines)) {
          do.call(grid::grobTree, c(list(tile), as.list(axis$children[lines])))
        } else tile
        for (j in lines) axis$children[[j]] <- grid::nullGrob()
        slot <- paste0("axis-tile-slot-", i, "-", axis$name)
        handle <- grid::grob(children = grid::gList(strip), name = slot, cl = "axis_tile_strip")
        axis <- grid::addGrob(axis, handle)
        table$grobs[[i]] <- axis
        proxy <- ggplot2::zeroGrob()
        proxy$vp <- grid::viewport(name = slot)
        strips[[length(strips) + 1L]] <- list(index = i, grob = proxy, settings = settings)
      }
      panels <- grep("^panel", table$layout$name)
      for (vertical in c(FALSE, TRUE)) {
        selected <- which(vapply(strips, function(s) identical(s$settings$vertical, vertical), logical(1)))
        if (!length(selected)) next
        positions <- vapply(strips[selected], function(s) {
          cell <- table$layout[s$index, ]
          if (vertical) {
            if (s$settings$position == "left") cell$r else cell$l - 1L
          } else if (s$settings$position == "top") cell$b else cell$t - 1L
        }, numeric(1))
        for (position in sort(unique(positions), decreasing = TRUE)) {
          group <- selected[positions == position]
          first <- strips[[group[1L]]]
          cell <- table$layout[first$index, ]
          candidates <- if (vertical) {
            panels[table$layout$t[panels] <= cell$t & table$layout$b[panels] >= cell$b]
          } else panels[table$layout$l[panels] <= cell$l & table$layout$r[panels] >= cell$r]
          distances <- if (vertical) abs(table$layout$l[candidates] - cell$l) else
            abs(table$layout$t[candidates] - cell$t)
          panel <- candidates[which.min(distances)]
          size <- first$settings$fraction * if (vertical) {
            table$widths[table$layout$l[panel]]
          } else table$heights[table$layout$t[panel]]
          table <- if (vertical) gtable::gtable_add_cols(table, size, pos = position) else
            gtable::gtable_add_rows(table, size, pos = position)
          for (j in group) {
            strip <- strips[[j]]
            cell <- table$layout[strip$index, ]
            table <- gtable::gtable_add_grob(table, strip$grob,
              t = if (vertical) cell$t else position + 1L,
              b = if (vertical) cell$b else position + 1L,
              l = if (vertical) position + 1L else cell$l,
              r = if (vertical) position + 1L else cell$r,
              # Include strips in the panel extent so patchwork retains null units.
              clip = "off", z = -Inf,
              name = paste0("panel-axis-tile-", substr(strip$settings$position, 1, 1)))
          }
        }
      }
      table
    }
  )
}

#' Draw a collected axis strip in its panel-relative viewport
#' @noRd
#' @importFrom grid drawDetails
#' @export
drawDetails.axis_tile_strip <- function(x, recording) {
  saved <- grid::current.vpPath()
  on.exit(grid::seekViewport(saved, recording = FALSE))
  grid::seekViewport(x$name, recording = FALSE)
  grid::grid.draw(x$children[[1]], recording = FALSE)
}

# ---- fmt_com ----

#' Add pairwise statistical comparisons
#'
#' Uses \code{ggpubr::geom_pwc} to overlay significance brackets.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param com_method Comparison method: \code{"con"} (consecutive), \code{"all"}
#'   (all pairs), or a list of length-2 character vectors.
#' @param label.y Numeric y-position for the first bracket (absolute y-axis
#'   value). Default \code{NULL} lets ggpubr auto-calculate.
#' @param label.y.prop Numeric proportion (0-1) of the y-axis data range for
#'   the first bracket position. E.g., \code{0.9} = 90\% of data range.
#'   Ignored when \code{label.y} is provided. Default \code{NULL}.
#' @param label Label type: \code{"p.signif"}, \code{"\{p.format\}\{p.signif\}"},
#'   or \code{"p.format"}.
#' @param tip.length Length of the bracket tips. Default \code{0.025}.
#' @param step.increase Vertical step increase between brackets. Default \code{0.05}.
#' @param size Line width of the brackets. Default \code{0.8}.
#' @param ... Additional arguments passed to \code{ggpubr::geom_pwc}.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#'
#' # Consecutive comparisons (default)
#' fmt_com(p)
#'
#' # All pairwise comparisons
#' fmt_com(p, com_method = "all")
#'
#' # Custom comparisons
#' fmt_com(p, com_method = list(c("setosa", "virginica"), c("setosa", "versicolor")))
#'
#' # Show p-value instead of stars
#' fmt_com(p, label = "p.format")
#'
#' # Show both p-value and stars
#' fmt_com(p, label = "{p.format}{p.signif}")
#'
#' # Adjust bracket y-position (absolute y-axis value, not proportion)
#' fmt_com(p, label.y = 8)
#'
#' @export
#' @family plot formatting
fmt_com <- function(plot,
                    com_method = "con",
                    label.y = NULL,
                    label.y.prop = NULL,
                    label = c("p.signif", "{p.format}{p.signif}", "p.format"),
                    tip.length = 0.025,
                    step.increase = 0.05,
                    size = 0.8,
                    ...) {
  label <- match.arg(label)

  get_comparisons <- function(p, cm) {
    x_quo <- p$mapping$x
    if (is.null(x_quo)) cli::cli_abort("No x variable found in ggplot mapping.")
    # Evaluate the x aesthetic to get actual data values
    x_data <- tryCatch(
      rlang::eval_tidy(x_quo, data = p$data),
      error = function(e) {
        # Fallback: try as_name for simple symbols
        x_var <- rlang::as_name(x_quo)
        p$data[[x_var]]
      }
    )
    if (is.null(x_data)) cli::cli_abort("Cannot resolve x variable from plot mapping.")
    lvs <- if (is.factor(x_data)) levels(x_data) else sort(unique(x_data))

    if (is.list(cm)) {
      if (!all(vapply(cm, length, integer(1)) == 2L))
        cli::cli_abort("com_method list must contain vectors of length 2.")
      all_grps <- unique(unlist(cm))
      if (!all(all_grps %in% lvs))
        cli::cli_abort("Some groups in com_method are not in x variable levels.")
      comps <- cm
    } else {
      comps <- switch(cm,
        con = Map(c, lvs[-length(lvs)], lvs[-1]),
        all = utils::combn(lvs, 2, simplify = FALSE),
        cli::cli_abort("com_method must be 'con', 'all', or a list.")
      )
    }
    # Convert to numeric indices
    lapply(comps, function(el) {
      if (!is.numeric(el)) which(lvs %in% el) else el
    })
  }

  fmt_com_one <- function(p) {
    # Determine y position: label.y (absolute) takes priority over label.y.prop
    y_pos <- label.y
    if (is.null(y_pos) && !is.null(label.y.prop)) {
      y_quo <- p$mapping$y
      y_data <- tryCatch(
        rlang::eval_tidy(y_quo, data = p$data),
        error = function(e) NULL
      )
      if (!is.null(y_data) && is.numeric(y_data)) {
        y_range <- range(y_data, na.rm = TRUE)
        y_pos <- y_range[1] + label.y.prop * (y_range[2] - y_range[1])
      }
    }

    p +
      ggpubr::geom_pwc(
        # Override inherited `group` aesthetic. Paired / repeated-measures
        # plots (e.g. ggwithinstats partial-dependence panels) set
        # `aes(group = subject_id)` at the plot level to draw trajectory
        # lines; without this override, geom_pwc inherits that grouping
        # and computes within-subject pairwise tests -- each subject has
        # one observation per x level, so all tests degenerate to "ns"
        # at scattered positions.
        mapping = ggplot2::aes(group = NULL),
        method.args = list(comparisons = get_comparisons(p, com_method)),
        symnum.args = list(
          cutpoints = c(0, 0.001, 0.01, 0.05, Inf),
          symbols = c("***", "**", "*", "ns")
        ),
        label = label,
        size = size,
        step.increase = step.increase,
        tip.length = tip.length,
        y.position = y_pos,
        fontface = "bold",
        ...
      )
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_com_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_bg ----

#' Add coloured background stripes
#'
#' Inserts shaded rectangles behind the data layer, one per level of the
#' categorical axis variable.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param palette Palette name passed to \code{plotthis::palette_this}.
#' @param palcolor Manual colour vector (overrides palette).
#' @param alpha Transparency of the background rectangles.
#' @param bg_axis Which axis holds the categorical variable: \code{"x"} or
#'   \code{"y"}.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
#' fmt_bg(p, alpha = 0.2)
#'
#' @export
#' @family plot formatting
fmt_bg <- function(plot,
                   palette = NULL,
                   palcolor = NULL,
                   alpha = 0.3,
                   bg_axis = c("x", "y")) {
  bg_axis <- match.arg(bg_axis)

  # Unified background layer builder for both x and y axes
  build_bg_layer <- function(data, var_name, palette, palcolor, alpha,
                             facet_by = NULL, bg_axis = "x") {
    fct <- droplevels(data[[var_name]])
    lvs <- levels(fct)

    bg_color <- tryCatch(
      plotthis::palette_this(lvs, palette = palette, palcolor = palcolor),
      error = function(e) {
        cols <- grDevices::rainbow(length(lvs), alpha = 0.3)
        stats::setNames(cols, lvs)
      }
    )

    n <- length(lvs)
    nums <- seq_len(n)
    bg_data <- data.frame(pos = nums)

    if (bg_axis == "x") {
      bg_data$xmin <- ifelse(nums == 1L, -Inf, nums - 0.5)
      bg_data$xmax <- ifelse(nums == n,   Inf, nums + 0.5)
      bg_data$ymin <- -Inf
      bg_data$ymax <- Inf
    } else {
      bg_data$xmin <- -Inf
      bg_data$xmax <- Inf
      bg_data$ymin <- ifelse(nums == 1L, -Inf, nums - 0.5)
      bg_data$ymax <- ifelse(nums == n,   Inf, nums + 0.5)
    }
    bg_data$fill <- bg_color[lvs]

    # Handle faceting
    if (!is.null(facet_by) && length(facet_by) > 0) {
      valid_fb <- facet_by[facet_by %in% colnames(data)]
      if (length(valid_fb) > 0) {
        uv <- dplyr::distinct(data, dplyr::across(dplyr::all_of(valid_fb)))
        bg_data <- tidyr::expand_grid(bg_data, uv)
        for (fb in valid_fb) {
          if (is.factor(data[[fb]])) {
            bg_data[[fb]] <- factor(bg_data[[fb]], levels = levels(data[[fb]]))
          }
        }
      }
    }

    ggplot2::geom_rect(
      data = bg_data,
      ggplot2::aes(
        xmin = .data[["xmin"]], xmax = .data[["xmax"]],
        ymin = .data[["ymin"]], ymax = .data[["ymax"]]
      ),
      fill = bg_data$fill, alpha = alpha, inherit.aes = FALSE
    )
  }

  # Extract facet variables from a plot
  extract_facet_vars <- function(p) {
    if (is.null(p$facet)) return(NULL)
    tryCatch({
      fv <- NULL
      if (inherits(p$facet, "FacetWrap")) {
        fv <- p$facet$params$facets
        fv <- if (is.list(fv)) vapply(fv, rlang::as_name, character(1)) else rlang::as_name(fv)
      } else if (inherits(p$facet, "FacetGrid")) {
        rv <- p$facet$params$rows
        cv <- p$facet$params$cols
        fv <- character(0)
        if (length(rv) > 0) fv <- c(fv, vapply(rv, rlang::as_name, character(1)))
        if (length(cv) > 0) fv <- c(fv, vapply(cv, rlang::as_name, character(1)))
      }
      fv
    }, error = function(e) NULL)
  }

  fmt_bg_one <- function(p) {
    mapping_var <- p$mapping[[bg_axis]]
    if (is.null(mapping_var)) {
      cli::cli_warn("No {bg_axis}-axis mapping found; skipping background.")
      return(p)
    }
    axis_var <- rlang::as_name(mapping_var)
    facet_vars <- extract_facet_vars(p)

    bg_layer <- build_bg_layer(
      data = p$data, var_name = axis_var,
      palette = palette, palcolor = palcolor, alpha = alpha,
      facet_by = facet_vars, bg_axis = bg_axis
    )
    p$layers <- c(list(bg_layer), p$layers)
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_bg_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_his ----

#' Add marginal histogram or density overlay
#'
#' Overlays a rescaled histogram or density curve on the existing plot,
#' using the x-axis variable (or a user-supplied variable).
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param type \code{"histogram"} (or \code{"h"}) or \code{"density"}
#'   (or \code{"d"}).
#' @param height_ratio Fraction of the y-axis range used for the overlay height.
#' @param data Optional data frame. If \code{NULL}, uses the plot data.
#' @param con_var Variable name for the x-axis. If \code{NULL}, extracted from
#'   the plot mapping.
#' @param ... Additional arguments: \code{binwidth}, \code{adjust},
#'   \code{his_color}, \code{his_alpha}, \code{y_rescale}, \code{ylim}.
#'
#' @return Same type as input.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_his(p, type = "histogram", height_ratio = 0.3)
#' fmt_his(p, type = "density", height_ratio = 0.2)
#' }
#'
#' @export
#' @family plot formatting
fmt_his <- function(plot,
                    type = c("histogram", "density", "h", "d"),
                    height_ratio = 0.3,
                    data = NULL,
                    con_var = NULL,
                    ...) {
  type <- match.arg(type)
  if (startsWith(type, "h")) type <- "histogram"
  if (startsWith(type, "d")) type <- "density"

  dots <- list(...)
  binwidth  <- dots$binwidth  %||% 3

  adjust    <- dots$adjust    %||% 3
  his_color <- dots$his_color %||% "gray85"
  his_alpha <- dots$his_alpha %||% 0.5
  y_rescale <- dots$y_rescale
  ylim      <- dots$ylim

  fmt_his_one <- function(p) {
    # Resolve data and variable
    d <- data %||% p$data
    if (is.null(d)) cli::cli_abort("No data found in plot and `data` is NULL.")
    v <- con_var %||% {
      if (!is.null(p$mapping$x)) rlang::as_name(p$mapping$x)
      else cli::cli_abort("No x variable found and `con_var` is NULL.")
    }
    if (!v %in% names(d)) cli::cli_abort("Variable '{v}' not found in data.")

    # Y-axis range
    built <- ggplot2::ggplot_build(p)
    y_range <- built$layout$panel_params[[1]]$y.range %||% c(0, 1)
    y_min <- y_range[1]
    y_max <- y_range[2]
    hist_height <- (y_max - y_min) * height_ratio

    yr <- y_rescale %||% c(y_min, y_min + hist_height)

    # Adding a fresh coord_cartesian() REPLACES the plot's coordinate system,
    # and its default expand = TRUE would silently override a caller's
    # expand = FALSE (turning a tight, edge-to-edge y-axis back into 5% padding).
    # Freeze the ORIGINAL built panel ranges with expand = FALSE: x.range /
    # y.range already bake in whatever expansion the plot had, so re-applying
    # them with expand = FALSE reproduces the original axes exactly and the
    # overlay can no longer shift or re-pad them. `clip` is inherited.
    x_range   <- built$layout$panel_params[[1]]$x.range
    old_coord <- p$coordinates
    keep_clip <- if (inherits(old_coord, "CoordCartesian") &&
                     !is.null(old_coord$clip)) old_coord$clip else "on"

    yl <- ylim %||% y_range

    new_coord <- ggplot2::coord_cartesian(
      xlim = x_range, ylim = yl, expand = FALSE, clip = keep_clip
    )

    if (type == "histogram") {
      p <- p +
        ggplot2::geom_histogram(
          data = d,
          mapping = ggplot2::aes(
            x = .data[[v]],
            y = scales::rescale(ggplot2::after_stat(count), yr)
          ),
          fill = his_color, color = his_color,
          binwidth = binwidth, alpha = his_alpha,
          position = "stack"
        ) +
        new_coord
    } else {
      p <- p +
        ggplot2::geom_density(
          data = d,
          mapping = ggplot2::aes(
            x = .data[[v]],
            y = scales::rescale(ggplot2::after_stat(density), yr)
          ),
          fill = his_color,
          color = ggplot2::alpha(his_color, his_alpha),
          alpha = his_alpha, adjust = adjust
        ) +
        new_coord
    }
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_his_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_scale ----

#' Set axis scales
#'
#' Automatically detects discrete / continuous / date scale type and applies
#' user-supplied arguments via \code{do.call}.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param x Named list of arguments for the x-axis scale function.
#'   E.g. \code{list(limits = c(4, 8), breaks = seq(4, 8, 1))}.
#' @param y Named list of arguments for the y-axis scale function.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_scale(p, x = list(limits = c(4, 8), breaks = seq(4, 8, 1)))
#' fmt_scale(p, y = list(labels = scales::label_percent()))
#'
#' @export
#' @family plot formatting
fmt_scale <- function(plot, x = NULL, y = NULL) {
  apply_scale <- function(p, args, axis) {
    if (is.null(args) || length(args) == 0L) return(p)
    fn_name <- .detect_scale_type(p, axis)
    fn <- utils::getFromNamespace(fn_name, "ggplot2")
    tryCatch(
      p + do.call(fn, args),
      error = function(e) {
        fallback <- utils::getFromNamespace(paste0("scale_", axis, "_continuous"), "ggplot2")
        p + do.call(fallback, args)
      }
    )
  }

  fmt_scale_one <- function(p) {
    p <- apply_scale(p, x, "x")
    p <- apply_scale(p, y, "y")
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_scale_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_expand ----

#' Set axis expansion
#'
#' Applies \code{ggplot2::expansion()} to one or both axes, automatically
#' detecting the correct scale type.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param mult Multiplicative expansion factor.
#' @param add Additive expansion (length-2 vector for lower/upper).
#' @param axis \code{"x"}, \code{"y"}, or \code{NULL} (both).
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' fmt_expand(p, mult = 0.05)
#' fmt_expand(p, add = c(0.5, 0), axis = "x")
#'
#' @export
#' @family plot formatting
fmt_expand <- function(plot, mult = 0, add = c(0, 0), axis = NULL) {
  if (!is.null(axis) && !axis %in% c("x", "y"))
    cli::cli_abort("`axis` must be 'x', 'y', or NULL.")

  expansion_setting <- ggplot2::expansion(add = add, mult = mult)

  apply_expansion <- function(p, ax) {
    fn_name <- .detect_scale_type(p, ax)
    fn <- utils::getFromNamespace(fn_name, "ggplot2")
    tryCatch(
      p + fn(expand = expansion_setting),
      error = function(e) {
        fallback <- utils::getFromNamespace(paste0("scale_", ax, "_continuous"), "ggplot2")
        p + fallback(expand = expansion_setting)
      }
    )
  }

  fmt_expand_one <- function(p) {
    axes <- if (is.null(axis)) c("x", "y") else axis
    for (ax in axes) {
      p <- apply_expansion(p, ax)
    }
    p
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_expand_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_boxplot ----

#' Overlay a boxplot layer
#'
#' Adds \code{geom_boxplot} on top of existing layers (e.g. violin, jitter).
#' Outliers are suppressed by default.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param boxplot.args Named list of arguments passed to
#'   \code{ggplot2::geom_boxplot}. Defaults include \code{width = 0.3},
#'   \code{alpha = 0.2}, \code{na.rm = TRUE}.
#' @param inherit.aes Whether to inherit aesthetics from the parent plot.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_violin()
#' fmt_boxplot(p)
#' fmt_boxplot(p, boxplot.args = list(width = 0.2, alpha = 0.5))
#'
#' @export
#' @family plot formatting
fmt_boxplot <- function(plot,
                        boxplot.args = list(),
                        inherit.aes = TRUE) {
  # Set sensible defaults
  defaults <- list(width = 0.3, alpha = 0.2, na.rm = TRUE)
  for (nm in names(defaults)) {
    if (is.null(boxplot.args[[nm]])) boxplot.args[[nm]] <- defaults[[nm]]
  }
  boxplot.args$outlier.shape <- NA
  boxplot.args$inherit.aes <- inherit.aes

  fmt_boxplot_one <- function(p) {
    args <- boxplot.args
    if (!inherit.aes) {
      pd <- p$data
      pm <- p$mapping
      if (is.null(pd) || is.null(pm$x) || is.null(pm$y)) {
        cli::cli_warn("Cannot extract data/mapping; falling back to inherit.aes = TRUE.")
        args$inherit.aes <- TRUE
      } else {
        args$data <- pd
        args$mapping <- ggplot2::aes(x = !!pm$x, y = !!pm$y)
      }
    }
    p + rlang::exec(ggplot2::geom_boxplot, !!!args)
  }

  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, fmt_boxplot_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}
