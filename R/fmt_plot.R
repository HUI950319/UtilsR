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
#
#   fmt_com: L1 validate arguments / recurse ordinary leaves
#              L2 fmt_com_one -> resolve statistical data and mappings
#                 L3 panel stat -> transform positions / preserve grouping
#                    L4 select_pairs / run_test -> adapt comparison methods
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
#'     \item Character: `"top"`, `"bottom"`, `"left"`, `"right"`, `"none"`, `"inside"`.
#'     \item Shorthand corner codes: `"br"`, `"bl"`, `"tr"`, `"tl"` (inside
#'       plot corners).
#'     \item Numeric vector of length 2: `c(x, y)` coordinates (0-1) for
#'       inside-plot positioning.
#'   }
#'   Default `NULL` (no change).
#' @param legend.direction `"horizontal"` or `"vertical"`. Default `NULL`.
#' @param legend_theme A ggplot2 theme object for legend styling, e.g.,
#'   [theme_legend1()]. Applied after position/direction settings so it can
#'   override them. Existing guide-local styling is merged with the requested
#'   legend styling. Default `NULL` (no extra styling).
#' @param collect Logical. If `TRUE` and input is a patchwork, collect guides
#'   at its top level, including a single data plot with a guide area.
#'   Identical rendered guides are deduplicated; different guides remain separate.
#'   Collection is skipped with a warning when its scope contains visible inside legends;
#'   their guides are kept in each subplot instead of being dropped by patchwork.
#'   Nested \code{keep} layouts and disabled guides do not block outer collection.
#'   List inputs retain their list type and produce a warning when collection is
#'   requested. Default `FALSE`.
#' @param title Character vector of legend titles, one per subplot. Recycled
#'   to match the number of subplots. Automatically detects which aesthetics
#'   (colour, fill, shape, etc.) are mapped and renames their legend titles.
#'   Also covers aesthetics renamed by \pkg{ggnewscale} for multiple scales.
#'   Default `NULL` (no change).
#' @param scale One finite positive number. Proportionally scale the legend.
#'   \code{0.8} = shrink to 80\%, \code{1.2} = enlarge to 120\%.
#'   Adjusts key size, text size, title size, point size, and spacing
#'   together, including explicit \code{legend.key.spacing.x/y}.
#'   Also scales \code{legend.margin}, \code{legend.box.margin} and margins
#'   set on or inherited by \code{legend.text} and \code{legend.title}.
#'   Each subplot uses its own theme after applying new legend styling.
#'   Blank text and title elements remain blank, and grid units are retained.
#'   Default \code{NULL} (no scaling).
#' @param scale_width One finite positive number. Scale legend key width independently.
#'   Multiplies the overall factor when `scale` is supplied.
#'   Default \code{NULL} (no change).
#' @param scale_height One finite positive number. Scale legend key height independently.
#'   Multiplies the overall factor when `scale` is supplied.
#'   Default \code{NULL} (no change).
#' @param ncol One finite positive integer giving the columns in the legend layout (passed to
#'   [ggplot2::guide_legend()]).
#' @param nrow One finite positive integer giving the rows in the legend layout (passed to
#'   [ggplot2::guide_legend()]).
#' @param ... Additional arguments passed to [ggplot2::theme()], e.g.,
#'   `legend.text`, `legend.key.size`, `legend.background`.
#'
#' @return Same type as input.
#'
#' @details Existing guide types, order, reversal and aesthetic overrides are
#'   retained. Layout controls apply to symbol legends; continuous colour bars
#'   and colour steps retain their native guide type. Disabled guides stay hidden.
#'   Explicit axis guides remain unchanged.
#'   Later explicit guide definitions replace earlier layout controls.
#'   Local guide dimensions use the guide's own position and direction.
#'   Independent dimensions retain inheritance from local key sizes.
#'   Automatic dimensions and margins continue to adapt after position changes.
#'   Reused scaled guides compose their glyph factors without recursive callbacks.
#'   Hiding via \code{legend.position = "none"} retains explicit guide settings,
#'   so a later position change can show them again; disabled guides stay disabled.
#'   Formatting does not modify caller-owned scales or guides and does not build
#'   the plot or evaluate layer data callbacks.
#'   Guide and scale clones do not retain the formatter's input or working plots.
#'   Repeated unchanged layouts reuse the guide container, and layout updates
#'   retain a stable parent while preserving current guide settings.
#'   Collection checks include fixed aesthetics with explicit scale limits when
#'   layers force their legend display through \code{show.legend = TRUE}.
#'   Mappings using \code{I()} without explicit scale limits do not block
#'   guide collection.
#'
#'   Nested patchwork layouts, annotations, list names and free settings are
#'   retained. Spacers, guide areas, wrapped graphics and inset overlays are
#'   preserved. Position, style and spacing changes also apply to annotations of
#'   existing collected-guide layouts at each nesting level.
#'   Calls with no formatting controls or only neutral size factors return the
#'   original object unchanged
#'   after checking the input container.
#'   Parameter validation also applies to containers without editable data plots.
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
  for (nm in c("scale", "scale_width", "scale_height")) {
    value <- get(nm)
    if (is.numeric(value) && !is.complex(value) && length(value) == 1L &&
        is.finite(value) && value == 1) assign(nm, NULL)
  }
  if (is.null(legend.position) && is.null(legend.direction) && is.null(legend_theme) &&
      identical(collect, FALSE) && is.null(title) && is.null(scale) &&
      is.null(scale_width) && is.null(scale_height) && is.null(ncol) &&
      is.null(nrow) && ...length() == 0L) {
    invisible(.to_plot_list(plot))
    return(plot)
  }
  info <- .to_plot_list(plot, recurse = TRUE)
  plots <- info$plots
  n <- length(plots)

  if (!is.null(legend.position)) {
    valid <- (is.character(legend.position) && length(legend.position) == 1L &&
      !is.na(legend.position) && legend.position %in%
        c("top", "bottom", "left", "right", "none", "inside", "br", "bl", "tr", "tl")) ||
      (is.numeric(legend.position) && !is.complex(legend.position) &&
       length(legend.position) == 2L && all(is.finite(legend.position)) &&
       all(legend.position >= 0 & legend.position <= 1))
    if (!valid) cli::cli_abort("{.arg legend.position} must be one supported position or two finite coordinates in [0, 1].")
  }
  if (!is.null(legend.direction) &&
      !(is.character(legend.direction) && length(legend.direction) == 1L &&
        !is.na(legend.direction) && legend.direction %in% c("horizontal", "vertical"))) {
    cli::cli_abort("{.arg legend.direction} must be 'horizontal' or 'vertical'.")
  }
  if (!is.null(legend_theme) && !inherits(legend_theme, "theme")) {
    cli::cli_abort("{.arg legend_theme} must be a ggplot2 theme object or NULL.")
  }
  if (!is.logical(collect) || length(collect) != 1L || is.na(collect)) {
    cli::cli_abort("{.arg collect} must be TRUE or FALSE.")
  }
  if (!is.null(title) && (!is.character(title) || !length(title) || anyNA(title))) {
    cli::cli_abort("{.arg title} must be a non-empty character vector without missing values.")
  }
  for (nm in c("scale", "scale_width", "scale_height", "ncol", "nrow")) {
    value <- get(nm)
    if (is.null(value)) next
    valid <- is.numeric(value) && !is.complex(value) && length(value) == 1L &&
      is.finite(value) && value > 0
    integer <- nm %in% c("ncol", "nrow")
    if (valid && integer) valid <- value == floor(value) && value <= .Machine$integer.max
    if (!valid) {
      requirement <- if (integer) "one finite positive integer" else "one finite positive number"
      cli::cli_abort("{.arg {nm}} must be {requirement} or NULL.")
    }
  }
  if (collect && !info$is_patchwork && !info$is_single) {
    cli::cli_warn("{.arg collect} requires a patchwork input; the formatted list retains its list type.")
  }
  if (n == 0L) return(plot)

  legend_aes <- c("colour", "color", "fill", "shape", "size",
                  "linewidth", "alpha", "linetype")
  is_legend_aes <- function(aesthetics) {
    sub("_ggnewscale_[0-9]+$", "", aesthetics) %in% legend_aes
  }
  # ---- Rename legend titles per subplot ----
  if (!is.null(title)) {
    title <- rep_len(title, n)
    rename_guide <- function(guide, label) {
      if (!inherits(guide, "Guide") || inherits(guide, "GuideNone")) return(guide)
      params <- guide$params
      params$title <- label
      do.call(ggplot2::ggproto, list(NULL, guide, params = params), envir = baseenv())
    }
    for (i in seq_len(n)) {
      p <- plots[[i]]
      mapped <- unique(c(names(p$mapping), unlist(lapply(p$layers, function(layer) {
        names(layer$mapping)
      }), use.names = FALSE), unlist(lapply(p$scales$scales, function(sc) {
        sc$aesthetics
      }), use.names = FALSE)))
      mapped <- mapped[is_legend_aes(mapped)]
      if (length(mapped)) {
        p <- p + do.call(ggplot2::labs, stats::setNames(
          rep(list(title[i]), length(mapped)), mapped
        ))
      }
      scales <- lapply(p$scales$scales, function(sc) {
        if (!any(is_legend_aes(sc$aesthetics))) return(sc)
        do.call(ggplot2::ggproto, list(NULL, sc, name = title[i],
          guide = rename_guide(sc$guide, title[i])), envir = baseenv())
      })
      if (!identical(scales, p$scales$scales)) {
        p$scales <- do.call(ggplot2::ggproto, list(NULL, p$scales, scales = scales),
                            envir = baseenv())
      }
      if (inherits(p$guides, "Guides")) {
        guides <- p$guides$guides
        selected <- names(guides)[is_legend_aes(names(guides))]
        guides[selected] <- lapply(guides[selected], rename_guide, label = title[i])
        if (!identical(guides, p$guides$guides)) {
          p$guides <- do.call(ggplot2::ggproto, list(NULL, p$guides, guides = guides),
                              envir = baseenv())
        }
      }
      plots[[i]] <- p
    }
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
  if (is.numeric(legend.position)) {
    theme_args$legend.position <- "inside"
    theme_args$legend.position.inside <- legend.position
    theme_args$legend.justification.inside <-
      theme_args$legend.justification.inside %||% legend.justification
  } else if (!is.null(legend.position)) {
    theme_args$legend.position <- legend.position
  }
  if (!is.null(legend.direction))
    theme_args$legend.direction <- legend.direction
  if (!is.null(legend.justification) && !is.numeric(legend.position))
    theme_args$legend.justification <- legend.justification

  leg_theme <- do.call(ggplot2::theme, theme_args)

  # Append legend_theme without replacing the existing guide type.
  if (!is.null(legend_theme) && inherits(legend_theme, "theme")) {
    leg_theme <- leg_theme + legend_theme
  }

  guide_args <- list()
  if (!is.null(ncol)) guide_args$ncol <- ncol
  if (!is.null(nrow)) guide_args$nrow <- nrow

  # ---- Style and scale each subplot from its effective theme ----
  get_unit <- function(theme, element) {
    el <- ggplot2::calc_element(element, theme)
    if (grid::is.unit(el)) el else grid::unit(1.2, "lines")
  }
  scaling <- !is.null(scale)
  factor <- if (scaling) scale else 1
  style_guide <- function(guide, th) {
    if (!inherits(guide, "Guide") || inherits(guide, "GuideNone")) return(guide)
    params <- guide$params
    if (length(guide_args) && inherits(guide, "GuideLegend") &&
        !inherits(guide, "GuideColourbar")) params[names(guide_args)] <- guide_args
    if (!is.null(leg_theme$legend.position)) {
      params$position <- if (identical(leg_theme$legend.position, "none")) NULL else
        leg_theme$legend.position
    }
    if (!is.null(leg_theme$legend.direction)) params$direction <- leg_theme$legend.direction
    if (!is.null(params$theme)) {
      local <- params$theme + leg_theme
      params$theme <- local
      if (scaling || !is.null(scale_width) || !is.null(scale_height)) {
        effective <- th + local
        args <- list()
        if (scaling) {
          for (nm in c("legend.text", "legend.title")) {
            el <- ggplot2::calc_element(nm, effective)
            if (inherits(el, "element_text") && !is.null(el$size)) {
              styled <- local[[nm]]
              if (!inherits(styled, "element_text")) styled <- ggplot2::element_text()
              styled$size <- el$size * factor
              if (!is.null(styled$margin) || any(as.numeric(el$margin) != 0, na.rm = TRUE)) {
                styled$margin <- el$margin * factor
              }
              args[[nm]] <- styled
            }
          }
          for (nm in c("legend.key.size", "legend.key.width", "legend.key.height",
                       "legend.key.spacing.x", "legend.key.spacing.y", "legend.margin")) {
            if (!is.null(local[[nm]])) args[[nm]] <- get_unit(effective, nm) * factor
          }
        }
        if (!is.null(scale_width) && !is.null(local$legend.key.width)) {
          args$legend.key.width <- get_unit(effective, "legend.key.width") * factor * scale_width
        }
        if (!is.null(scale_height) && !is.null(local$legend.key.height)) {
          args$legend.key.height <- get_unit(effective, "legend.key.height") * factor * scale_height
        }
        if (length(args)) params$theme <- local + do.call(ggplot2::theme, args)
      }
    }
    if (identical(params, guide$params)) return(guide)
    do.call(ggplot2::ggproto, list(NULL, guide, params = params), envir = baseenv())
  }
  for (i in seq_len(n)) {
    p <- plots[[i]]
    if (length(leg_theme) || isTRUE(attr(leg_theme, "complete"))) p <- p + leg_theme
    th <- ggplot2::theme_get() + p$theme
    if (inherits(p$guides, "Guides")) {
      guides <- p$guides$guides
      selected <- names(guides)[is_legend_aes(names(guides))]
      if (length(selected)) guides[selected] <- lapply(guides[selected], style_guide, th = th)
      if (!identical(guides, p$guides$guides)) {
        p$guides <- do.call(ggplot2::ggproto, list(NULL, p$guides, guides = guides),
                            envir = baseenv())
      }
    }
    scales <- lapply(p$scales$scales, function(sc) {
      if (!any(is_legend_aes(sc$aesthetics))) return(sc)
      guide <- style_guide(sc$guide, th)
      if (identical(guide, sc$guide)) return(sc)
      do.call(ggplot2::ggproto, list(NULL, sc, guide = guide), envir = baseenv())
    })
    if (!identical(scales, p$scales$scales)) {
      p$scales <- do.call(ggplot2::ggproto, list(NULL, p$scales, scales = scales),
                          envir = baseenv())
    }
    scale_args <- list()
    if (scaling) {
      for (element in c("legend.text", "legend.title")) {
        el <- ggplot2::calc_element(element, th)
        if (inherits(el, "element_text") && !is.null(el$size)) {
          styled <- th[[element]]
          if (!inherits(styled, "element_text")) styled <- ggplot2::element_text()
          styled$size <- el$size * factor
          if (!is.null(styled$margin) || any(as.numeric(el$margin) != 0, na.rm = TRUE)) {
            styled$margin <- el$margin * factor
          }
          scale_args[[element]] <- styled
        }
      }
      unit_elements <- c("legend.key.size", "legend.key.width", "legend.key.height",
                         "legend.key.spacing.x", "legend.key.spacing.y",
                         "legend.spacing", "legend.spacing.x", "legend.spacing.y",
                         "legend.box.spacing", "legend.margin", "legend.box.margin")
      for (element in intersect(unit_elements, names(ggplot2::get_element_tree()))) {
        if (element %in% c("legend.key.width", "legend.key.height") &&
            inherits(th[[element]], "rel")) next
        if (!is.null(th[[element]])) scale_args[[element]] <- get_unit(th, element) * factor
      }
    }
    if (!is.null(scale_width)) {
      width <- th$legend.key.width %||% ggplot2::rel(1)
      scale_args$legend.key.width <- if (inherits(width, "rel")) width * scale_width else
        get_unit(th, "legend.key.width") * factor * scale_width
    }
    if (!is.null(scale_height)) {
      height <- th$legend.key.height %||% ggplot2::rel(1)
      scale_args$legend.key.height <- if (inherits(height, "rel")) height * scale_height else
        get_unit(th, "legend.key.height") * factor * scale_height
    }
    if (length(scale_args)) p <- p + do.call(ggplot2::theme, scale_args)
    plots[[i]] <- p
  }

  # ---- Resolve default guide layout and glyph scaling during building ----
  if (length(guide_args) || scaling) {
    process_keys <- function(self, params, layers, data = NULL, theme = NULL) {
      native <- ggplot2::ggproto_parent(self$.fmt_legend_source, self)$process_layers
      args <- list(params, layers, data)
      if (any(c("theme", "...") %in% names(formals(environment(native)$f)))) args$theme <- theme
      params <- do.call(native, args)
      for (i in seq_along(params$decor)) {
        for (nm in c("size", "linewidth", "stroke")) {
          value <- params$decor[[i]]$data[[nm]]
          if (is.numeric(value)) params$decor[[i]]$data[[nm]] <- value * self$.fmt_legend_scale
        }
      }
      params
    }
    environment(process_keys) <- baseenv()
    # Resolve default guides during normal building, without evaluating data here.
    setup_guides <- function(self, scales, aesthetics = NULL,
                              default = self$missing, missing = self$missing) {
      resolved <- ggplot2::ggproto_parent(self$.fmt_legend_parent, self)$setup(
        scales, aesthetics, default, missing
      )
      explicit <- c(self$guides, lapply(scales, function(sc) sc$guide))
      guides <- lapply(seq_along(resolved$guides), function(j) {
        guide <- resolved$guides[[j]]
        if (!inherits(guide, "GuideLegend") ||
            inherits(guide, c("GuideColourbar", "GuideNone"))) return(guide)
        params <- guide$params
        updates <- self$.fmt_legend_args
        if (!any(vapply(explicit, identical, logical(1), y = guide))) {
          params[names(updates$layout)] <- updates$layout
        }
        if (!is.null(updates$scale)) {
          source <- guide
          glyph_scale <- updates$scale
          while (!is.null(source$.fmt_legend_source)) {
            glyph_scale <- glyph_scale * source$.fmt_legend_scale
            source <- source$.fmt_legend_source
          }
          return(do.call(ggplot2::ggproto, list(NULL, guide, params = params,
            .fmt_legend_source = source, .fmt_legend_scale = glyph_scale,
            process_layers = self$.fmt_legend_process_keys[[1L]]), envir = baseenv()))
        }
        do.call(ggplot2::ggproto, list(NULL, guide, params = params), envir = baseenv())
      })
      do.call(ggplot2::ggproto, list(NULL, resolved, guides = guides,
        params = lapply(guides, function(g) g$params)), envir = baseenv())
    }
    # Stored methods retain guide settings only, rather than the formatter's plots.
    environment(setup_guides) <- baseenv()
    for (i in seq_len(n)) {
      guides <- plots[[i]]$guides
      parent <- guides$.fmt_legend_parent %||% guides
      updates <- utils::modifyList(guides$.fmt_legend_args %||% list(),
                                   list(layout = guide_args))
      if (scaling) updates$scale <- (updates$scale %||% 1) * factor
      if (identical(updates, guides$.fmt_legend_args)) next
      members <- as.list(guides, all.names = TRUE)
      inherited <- as.list(parent, all.names = TRUE)
      members <- members[!vapply(names(members), function(nm) {
        identical(members[[nm]], inherited[[nm]])
      }, logical(1))]
      members$.fmt_legend_parent <- parent
      members$.fmt_legend_args <- updates
      members$.fmt_legend_process_keys <- list(process_keys)
      members$setup <- setup_guides
      plots[[i]]$guides <- do.call(ggplot2::ggproto, c(list(NULL, parent), members),
                                 envir = baseenv())
    }
  }

  # ---- Collect legends mode for patchwork ----
  output <- .from_plot_list(plots, info$is_patchwork, info$is_single,
                            pw_orig = info$pw_orig, recurse = TRUE)
  if (collect && info$is_patchwork && !identical(output$patches$layout$guides, "collect")) {
    output <- output + patchwork::plot_layout(guides = "collect")
  }
  collection_skipped <- FALSE
  is_inside <- function(position) {
    identical(position, "inside") || (is.numeric(position) && length(position) == 2L)
  }
  has_inside_legend <- function(p, annotation_inside = FALSE) {
    if (inherits(p, "inset_patch") && (!inherits(p, "patchwork") ||
        match("inset_patch", class(p)) < match("patchwork", class(p)))) return(FALSE)
    if (inherits(p, "patchwork")) {
      annotation_inside <- annotation_inside || is_inside(
        (ggplot2::theme_get() + p$patches$annotation$theme)$legend.position)
      return(any(vapply(seq_along(p), function(i) {
        child <- p[[i]]
        if (inherits(child, "patchwork") &&
            identical(child$patches$layout$guides, "keep")) return(FALSE)
        has_inside_legend(child, annotation_inside)
      }, logical(1))))
    }
    if (inherits(p, c("spacer", "guide_area", "wrapped_patch"))) return(FALSE)
    fixed <- unique(unlist(lapply(p$scales$scales, function(sc) {
      if (!is.null(sc$limits)) sc$aesthetics else character()
    })))
    mapped <- unique(unlist(lapply(p$layers, function(layer) {
      if (identical(layer$show.legend, FALSE)) return(character())
      mapping <- layer$mapping
      if (isTRUE(layer$inherit.aes)) {
        mapping <- c(p$mapping[setdiff(names(p$mapping), names(mapping))], mapping)
      }
      asis <- vapply(mapping, function(value) {
        expr <- rlang::get_expr(value)
        if (rlang::is_call(expr, "I", ns = "base")) return(TRUE)
        rlang::is_call(expr, "I", ns = "") &&
          identical(get("I", envir = rlang::get_env(value), mode = "function"), base::I)
      }, logical(1))
      aesthetics <- names(mapping)[!asis | names(mapping) %in% fixed]
      forced <- if (isTRUE(layer$show.legend)) names(layer$geom$default_aes) else
        names(layer$show.legend)[which(layer$show.legend %in% TRUE)]
      aesthetics <- union(aesthetics, intersect(forced, fixed))
      hidden <- names(layer$show.legend)[!is.na(layer$show.legend) & !layer$show.legend]
      setdiff(aesthetics, hidden)
    })))
    for (aes in mapped[is_legend_aes(mapped)]) {
      guide <- p$guides$guides[[aes]]
      if (is.null(guide) || inherits(guide, "waiver")) {
        matching <- Filter(function(sc) aes %in% sc$aesthetics, p$scales$scales)
        guide <- if (length(matching)) matching[[length(matching)]]$guide else NULL
      }
      if (identical(guide, "none") || identical(guide, FALSE) || inherits(guide, "GuideNone")) next
      position <- if (inherits(guide, "Guide")) guide$params$position else NULL
      position <- position %||% (ggplot2::theme_get() + p$theme)$legend.position
      if (annotation_inside || is_inside(position)) return(TRUE)
    }
    FALSE
  }
  sync_collection_theme <- function(p) {
    if (inherits(p, "inset_patch") && (!inherits(p, "patchwork") ||
        match("inset_patch", class(p)) < match("patchwork", class(p)))) return(p)
    if (inherits(p, "patchwork")) {
      free_settings <- attr(p, "patchwork_free_settings")
      for (i in seq_along(p)) {
        if (inherits(p[[i]], "patchwork")) p[[i]] <- sync_collection_theme(p[[i]])
      }
      if (identical(p$patches$layout$guides, "collect")) {
        if (length(leg_theme)) p <- p + patchwork::plot_annotation(theme = leg_theme)
        if (scaling) {
          th <- ggplot2::theme_get() + p$patches$annotation$theme
          args <- list()
          for (nm in c("legend.spacing", "legend.spacing.x", "legend.spacing.y",
                       "legend.box.spacing", "legend.box.margin")) {
            if (!is.null(th[[nm]])) args[[nm]] <- get_unit(th, nm) * factor
          }
          if (length(args)) p <- p + patchwork::plot_annotation(theme = do.call(ggplot2::theme, args))
        }
        if (has_inside_legend(p)) {
          p <- p + patchwork::plot_layout(guides = "keep")
          collection_skipped <<- TRUE
        }
      }
      if (!is.null(free_settings)) {
        attr(p, "patchwork_free_settings") <- free_settings
        class(p) <- unique(c("free_plot", class(p)))
      }
    } else if (is.list(p) && !inherits(p, "gg")) {
      p <- lapply(p, sync_collection_theme)
    }
    p
  }
  output <- sync_collection_theme(output)
  if (collection_skipped) {
    cli::cli_warn("Guide collection is skipped for layouts containing inside legends; guides use 'keep' to remain visible in each subplot.")
  }
  output
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
#' Comparisons follow displayed x-axis order and use observed groups in each
#' panel. Custom groups without observations are rejected; pairs absent from
#' an individual facet panel are skipped.
#'
#' @param plot A ggplot, nested patchwork, or list of ggplots/patchworks.
#'   Layouts, annotations and list names are retained. Spacers, guide areas,
#'   insets and frozen wrapped graphics are left unchanged.
#' @param com_method Comparison method: \code{"con"} (consecutive), \code{"all"}
#'   (all pairs), or a non-empty list of length-2 category-value vectors.
#'   Pairs must contain distinct observed values; reversed duplicate pairs
#'   are rejected. Values select categories rather than numeric axis indices.
#' @param label.y Numeric bracket positions in original y-data units, before
#'   scale transformation. A scalar sets the first bracket; a vector sets
#'   individual positions in comparison-family order. Custom vectors follow
#'   \code{com_method} order within each mapped subset; automatic vectors follow
#'   displayed global pairs, appending extra sparse-panel pairs. Filtering a
#'   panel retains the matching entries. Default \code{NULL} uses automatic positions.
#' @param label.y.prop Numeric proportion (0-1) of each panel's transformed
#'   y-axis data range for the first bracket. E.g., \code{0.9} is 90\% along
#'   the displayed range, including log scales and free-y facets. Ignored when
#'   \code{label.y} is provided. Explicit positions have no default nudge;
#'   \code{bracket.nudge.y} in \code{...} adds an optional offset.
#' @param label A ggpubr result column or glue template, such as
#'   \code{"p.signif"}, \code{"p.adj.signif"}, \code{"p.adj.format"}, or
#'   \code{"\{p.format\}\{p.signif\}"}. The default displays raw P-value stars;
#'   select an adjusted label to display multiplicity-adjusted results.
#' @param tip.length Fraction of panel height for tips: a scalar, one value per
#'   comparison, or two values per comparison in left/right order. Default \code{0.025}.
#' @param step.increase Vertical step as a fraction of panel height: a scalar
#'   or one value per comparison. Default \code{0.05}. Not added to explicit position vectors.
#' @param size Line width of the brackets. Default \code{0.8}.
#' @param ... Named arguments passed to \code{ggpubr::geom_pwc}, overriding
#'   formatting defaults. \code{method.args} may contain test options such as
#'   \code{paired} or \code{alternative}; select pairs with \code{com_method},
#'   not \code{method.args$comparisons}. Paired tests retain original observation
#'   order and jointly omit incomplete pairs. Original group sizes must match
#'   for order-based pairing. Supply \code{method.args = list(paired = TRUE,
#'   id = "subject")} to match a data column independently within each pair;
#'   IDs must be non-missing and unique within each comparison group/subset.
#'   One-sided custom pairs test the first group against the second. Reference
#'   comparisons test the reference against the other group; automatic pairs
#'   use the original mapped group order for direction, independently of axis
#'   display order.
#'   By default, inherited trajectory grouping is ignored and x groups are
#'   compared. Set \code{group.by = "x.var"} to compare mapped groups within
#'   each x value, or \code{group.by = "legend.var"} to compare x values within
#'   each mapped group. An explicit \code{mapping = aes(group = ...)} also
#'   enables grouped comparisons. \code{com_method} selects the corresponding
#'   comparison variable, with consecutive pairs resolved within each subset.
#'   When \code{ref.group} is supplied, it selects reference comparisons instead
#'   of automatic consecutive/all pairs; it cannot be combined with a custom
#'   \code{com_method} list. Names and displayed ranks are accepted, and
#'   \code{ref.group = "all"} compares each group against the pooled observations.
#'   Dunn, Tukey and Games-Howell methods compute their full comparison family
#'   before display filtering, retaining that family's adjustment. Methods
#'   returning only adjusted P values use adjusted significance stars.
#'
#' @details A categorical x axis and numeric y outcome are required. Statistical
#' data and mapping can be supplied explicitly through \code{...}; otherwise a
#' complete plot-level source is used, then an unambiguous layer-level source.
#' Multiple different layer sources require explicit \code{data} and
#' \code{mapping}. Statistical data must be a data frame; callbacks and
#' after-stat mappings are not supported. Missing panel-specific pairs are
#' skipped. The backend evaluates tests on the layer data during plot building;
#' scale transformations and scale limits affect the observations it receives.
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
#' # Display adjusted significance stars
#' fmt_com(p, label = "p.adj.signif", p.adjust.method = "bonferroni")
#'
#' # Adjust bracket y-position (absolute y-axis value, not proportion)
#' fmt_com(p, label.y = 8)
#' fmt_com(p + scale_y_log10(), label.y = 8)
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
  if (missing(label)) label <- label[1L]
  if (!is.character(label) || length(label) != 1L || is.na(label) || !nzchar(label))
    cli::cli_abort("label must be a single non-empty result column or template.")
  dots <- list(...)
  if (length(dots) && (is.null(names(dots)) || any(!nzchar(names(dots))) ||
                       anyDuplicated(names(dots))))
    cli::cli_abort("Arguments in ... must have unique, non-empty names.")
  if (!is.null(dots$method.args) && (!is.list(dots$method.args) ||
      (length(dots$method.args) && (is.null(names(dots$method.args)) ||
       any(!nzchar(names(dots$method.args))) || anyDuplicated(names(dots$method.args))))))
    cli::cli_abort("method.args must be a list with unique, non-empty option names.")
  if (!is.null(dots$method.args$comparisons))
    cli::cli_abort("Select comparisons with com_method, not method.args$comparisons.")
  paired <- isTRUE(dots$method.args$paired) || identical(dots$method, "sign_test")
  pair_id <- dots$method.args$id
  if (!is.null(pair_id) && (!paired || !is.character(pair_id) || length(pair_id) != 1L ||
      is.na(pair_id) || !nzchar(pair_id)))
    cli::cli_abort("method.args$id must name a subject column for a paired test.")
  ref_group <- if (is.null(dots$ref.group)) dots$method.args$ref.group else dots$ref.group
  if (!is.null(dots$ref.group) && !is.null(dots$method.args$ref.group) &&
      !identical(dots$ref.group, dots$method.args$ref.group))
    cli::cli_abort("Set ref.group only once, in ... or method.args.")
  if (!is.null(ref_group)) {
    valid_ref <- length(ref_group) == 1L && !anyNA(ref_group) &&
      ((is.character(ref_group) && nzchar(ref_group)) ||
       (is.numeric(ref_group) && is.finite(ref_group) && ref_group >= 1 && ref_group == floor(ref_group)))
    if (!valid_ref) cli::cli_abort("ref.group must be a group name, a positive integer rank, or 'all'.")
    if (is.list(com_method)) cli::cli_abort("Use ref.group or a custom com_method list, not both.")
    dots$ref.group <- ref_group
    dots$method.args$ref.group <- NULL
  }
  ref_all <- !is.null(ref_group) && ref_group %in% c("all", ".all.")
  if ("y.position" %in% names(dots))
    cli::cli_abort("Set bracket positions with label.y, not y.position.")
  if (!is.null(dots$mapping) && !inherits(dots$mapping, "uneval"))
    cli::cli_abort("mapping must be created with ggplot2::aes().")
  if (!is.null(dots$group.by) && (!is.character(dots$group.by) ||
      length(dots$group.by) != 1L || is.na(dots$group.by) ||
      !dots$group.by %in% c("x.var", "legend.var")))
    cli::cli_abort("group.by must be 'x.var' or 'legend.var'.")

  check_numeric <- function(value, name, lower = -Inf, upper = Inf, scalar = FALSE) {
    if (!is.null(value) && (!is.numeric(value) || is.complex(value) ||
        !is.null(dim(value)) || !length(value) || (scalar && length(value) != 1L) ||
        any(!is.finite(value)) || any(value < lower | value > upper)))
      cli::cli_abort("{name} must contain finite numeric values in [{lower}, {upper}]{if (scalar) ' with length one' else ''}.")
  }
  check_numeric(label.y, "label.y")
  check_numeric(label.y.prop, "label.y.prop", 0, 1, TRUE)
  check_numeric(tip.length, "tip.length", 0, 1)
  check_numeric(step.increase, "step.increase", 0)
  check_numeric(size, "size", 0, scalar = TRUE)
  check_numeric(dots$bracket.nudge.y, "bracket.nudge.y")
  if (is.list(com_method) && (!length(com_method) ||
      !all(vapply(com_method, function(pair) {
        (is.character(pair) || is.numeric(pair)) && !is.complex(pair) &&
          is.null(dim(pair)) && length(pair) == 2L && !anyNA(pair) &&
          all(nzchar(as.character(pair))) && length(unique(pair)) == 2L
      }, logical(1))) || anyDuplicated(lapply(com_method, function(pair) sort(as.character(pair))))))
    cli::cli_abort("com_method must contain distinct, non-missing pairs without duplicates.")

  merge_mapping <- function(base, replacement) {
    for (name in names(replacement)) base[[name]] <- replacement[[name]]
    base
  }

  get_comparisons <- function(p, cm, group_quo = NULL) {
    x_quo <- if (is.null(group_quo)) p$mapping$x else group_quo
    if (is.null(x_quo)) cli::cli_abort("No x variable found in ggplot mapping.")
    x_data <- tryCatch(
      rlang::eval_tidy(x_quo, data = p$data),
      error = function(e) cli::cli_abort("Cannot resolve the comparison mapping.", parent = e)
    )
    if (is.null(x_data)) cli::cli_abort("Cannot resolve x variable from plot mapping.")
    axis_data <- if (is.null(group_quo)) x_data else
      rlang::eval_tidy(p$mapping$x, data = p$data)
    if (!is.factor(axis_data) && !is.character(axis_data) && !is.logical(axis_data))
      cli::cli_abort("The x comparison axis must be categorical; use factor() for numeric categories.")
    y_data <- rlang::eval_tidy(p$mapping$y, data = p$data)
    if (!is.numeric(y_data) || is.complex(y_data) || !any(is.finite(y_data)))
      cli::cli_abort("The y comparison variable must contain finite numeric observations.")
    n <- nrow(p$data)
    if (!length(x_data) %in% c(1L, n) || !length(y_data) %in% c(1L, n))
      cli::cli_abort("Comparison mappings must have length one or match the statistical data rows.")
    x_data <- rep(x_data, length.out = n)
    y_data <- rep(y_data, length.out = n)
    observed <- unique(as.character(x_data[!is.na(x_data) & is.finite(y_data)]))
    if (length(observed) < 2L)
      cli::cli_abort("Comparisons require at least two observed groups with finite outcomes.")
    if (is.character(ref_group) && !ref_all && !ref_group %in% observed)
      cli::cli_abort("The ref.group has no observed comparison values.")

    if (is.list(cm)) {
      all_grps <- unique(unlist(cm))
      if (!all(all_grps %in% observed))
        cli::cli_abort("Some groups in com_method have no observed comparison values.")
      return(lapply(cm, as.character))
    }
    if (!is.character(cm) || length(cm) != 1L || !cm %in% c("con", "all"))
      cli::cli_abort("com_method must be 'con', 'all', or a list.")
    cm
  }

  fmt_com_one <- function(p) {
    source_data <- if (is.null(dots$data)) p$data else dots$data
    if (!is.null(dots$data) && !is.data.frame(dots$data))
      cli::cli_abort("Statistical data must be an explicit data.frame; data callbacks are not supported.")
    source_mapping <- if (isFALSE(dots$inherit.aes)) ggplot2::aes() else p$mapping
    source_mapping <- merge_mapping(source_mapping, dots$mapping)
    if (is.null(source_mapping$x) || is.null(source_mapping$y) || !is.data.frame(source_data)) {
      candidates <- list()
      for (existing in p$layers) {
        mapping <- if (isTRUE(existing$inherit.aes)) p$mapping else ggplot2::aes()
        mapping <- merge_mapping(merge_mapping(mapping, existing$mapping), dots$mapping)
        data <- if (!is.null(dots$data)) dots$data else existing$data
        if (is.null(data) || inherits(data, "waiver")) data <- p$data
        if (!is.null(mapping$x) && !is.null(mapping$y) && is.data.frame(data)) {
          candidates[[length(candidates) + 1L]] <- list(data = data, mapping = mapping)
        }
      }
      if (!length(candidates))
        cli::cli_abort("Supply a data.frame and resolvable x/y mapping for statistical comparisons.")
      first <- candidates[[1L]]
      if (!all(vapply(candidates, function(candidate) {
        identical(candidate$data, first$data) &&
          identical(candidate$mapping$x, first$mapping$x) &&
          identical(candidate$mapping$y, first$mapping$y)
      }, logical(1))))
        cli::cli_abort("Statistical layer sources are ambiguous; supply data and mapping explicitly.")
      source_data <- first$data
      source_mapping <- first$mapping
    }
    source <- list(data = source_data, mapping = source_mapping)
    grouped <- !is.null(dots$group.by) || !is.null(dots$mapping$group)
    group_quo <- dots$mapping$group
    if (grouped && is.null(group_quo)) group_quo <- source_mapping$group
    if (grouped && is.null(group_quo)) group_quo <- source_mapping$fill
    if (grouped && is.null(group_quo)) group_quo <- source_mapping$colour
    if (grouped && is.null(group_quo))
      cli::cli_abort("Grouped comparisons require a group, fill or colour mapping.")
    compare_group <- grouped && !identical(dots$group.by, "legend.var")
    comparisons <- get_comparisons(source, com_method, if (compare_group) group_quo else NULL)
    group_labels <- NULL
    if (grouped) {
      values <- rlang::eval_tidy(group_quo, data = source_data)
      group_labels <- levels(droplevels(factor(values)))
    }
    comparison_order <- if (compare_group) group_labels else
      levels(droplevels(factor(rlang::eval_tidy(source_mapping$x, data = source_data))))
    if (!is.null(label.y)) {
      y_scale <- p$scales$get_scales("y")
      if (!is.null(y_scale) && any(!is.finite(suppressWarnings(y_scale$transform(label.y)))))
        cli::cli_abort("label.y must lie within the y transformation's domain.")
    }
    layout_controls <- list(y = label.y, step = step.increase, tip = tip.length, nudge = dots$bracket.nudge.y)
    vector_layout <- any(lengths(layout_controls) > 1L)
    layout_keys <- character()
    pair_key <- function(a, b, context = "") {
      values <- c(context, sort(c(a, b)))
      paste0(nchar(values), ":", values, collapse = "")
    }
    if (vector_layout) {
      n <- nrow(source_data)
      axis_values <- rep(rlang::eval_tidy(source_mapping$x, data = source_data), length.out = n)
      group_values <- if (grouped) rep(rlang::eval_tidy(group_quo, data = source_data), length.out = n) else rep("", n)
      finite <- is.finite(rep(rlang::eval_tidy(source_mapping$y, data = source_data), length.out = n))
      axis_scale <- p$scales$get_scales("x")
      axis_scale <- if (is.null(axis_scale)) ggplot2::scale_x_discrete() else axis_scale$clone()
      axis_scale$train(axis_values)
      axis_order <- as.character(axis_scale$get_limits())
      layout_order <- if (compare_group) group_labels else axis_order
      context <- as.character(if (!grouped) rep("", n) else if (compare_group) axis_values else group_values)
      contexts <- if (!grouped) "" else if (compare_group) axis_order else group_labels
      values <- as.character(if (compare_group) group_values else axis_values)
      facet_values <- lapply(c(p$facet$params$facets, p$facet$params$rows, p$facet$params$cols),
                             rlang::eval_tidy, data = source_data)
      panels <- if (length(facet_values)) do.call(interaction,
        c(lapply(facet_values, function(value) factor(rep(value, length.out = n), exclude = NULL)), list(drop = TRUE))) else rep(1L, n)
      add_pairs <- function(value, subset, declared = FALSE) {
        available <- layout_order[!is.na(layout_order) & layout_order %in% value]
        reference <- if (is.numeric(ref_group)) layout_order[ref_group] else ref_group
        pairs <- if (ref_all) lapply(available, function(value) c(value, value)) else
          if (!is.null(reference)) lapply(setdiff(available, reference), function(value) c(reference, value)) else
          if (is.list(comparisons)) comparisons else
          if (length(available) < 2L) list() else
          if (comparisons == "con") Map(c, head(available, -1L), tail(available, -1L)) else
          utils::combn(available, 2L, simplify = FALSE)
        if (!declared) pairs <- Filter(function(pair) all(pair %in% available), pairs)
        keys <- vapply(pairs, function(pair) pair_key(pair[1L], pair[2L], subset), character(1))
        layout_keys <<- unique(c(layout_keys, keys))
      }
      for (subset in contexts) {
        rows <- which(finite & !is.na(context) & context == subset)
        if (!length(rows)) next
        add_pairs(values[rows], subset, declared = is.list(comparisons))
        for (panel in unique(panels[rows])) add_pairs(values[rows[panels[rows] == panel]], subset)
      }
      count <- length(layout_keys)
      for (name in c("y", "step", "nudge")) {
        if (length(layout_controls[[name]]) > 1L && length(layout_controls[[name]]) != count)
          cli::cli_abort("{switch(name, y = 'label.y', step = 'step.increase', nudge = 'bracket.nudge.y')} must have length one or {count}, the comparison-family size.")
      }
      if (!length(tip.length) %in% c(1L, count, 2L * count))
        cli::cli_abort("tip.length must have length one, {count}, or {2L * count}.")
    }
    if (paired) {
      if (ref_all) cli::cli_abort("Paired tests cannot use a pooled ref.group; select two groups.")
      comparison_values <- rep(rlang::eval_tidy(if (compare_group) group_quo else source_mapping$x,
                                              data = source_data), length.out = nrow(source_data))
      strata <- lapply(c(p$facet$params$facets, p$facet$params$rows, p$facet$params$cols),
                       rlang::eval_tidy, data = source_data)
      if (grouped) strata <- c(strata, list(rlang::eval_tidy(
        if (compare_group) source_mapping$x else group_quo, data = source_data)))
      strata_key <- if (length(strata)) do.call(interaction,
        c(lapply(strata, function(value) factor(rep(value, length.out = nrow(source_data)), exclude = NULL)),
          list(drop = TRUE))) else factor(rep(1L, nrow(source_data)))
      if (is.null(pair_id)) {
        counts <- table(as.character(comparison_values), strata_key)
        unequal <- apply(counts, 2L, function(n) {
          if (is.list(comparisons)) return(any(vapply(comparisons, function(pair) {
            sizes <- n[match(pair, names(n))]
            all(!is.na(sizes) & sizes > 0L) && sizes[1L] != sizes[2L]
          }, logical(1))))
          length(unique(n[n > 0L])) > 1L
        })
        if (any(unequal)) cli::cli_abort("Paired groups have unequal original sizes; supply method.args$id.")
        ids <- ave(seq_len(nrow(source_data)), interaction(factor(comparison_values), strata_key, drop = TRUE), FUN = seq_along)
      } else {
        if (!pair_id %in% names(source_data)) cli::cli_abort("method.args$id column is absent from statistical data.")
        ids <- source_data[[pair_id]]
        if (anyNA(ids) || anyDuplicated(data.frame(stratum = strata_key, comparison = comparison_values, id = ids)))
          cli::cli_abort("method.args$id must be non-missing and unique within each comparison group/subset.")
        ids <- match(ids, unique(ids))
      }
      id_column <- tail(make.unique(c(names(source_data), ".fmt_com_pair_id")), 1L)
      source_data[[id_column]] <- as.numeric(ids)
      source_mapping$.fmt_com_id <- rlang::new_quosure(rlang::sym(id_column), rlang::base_env())
    }
    source_mapping$group <- if (grouped) group_quo else NULL
    geom_args <- list(
        data = source_data,
        mapping = source_mapping,
        method.args = list(),
        symnum.args = list(
          cutpoints = c(0, 0.001, 0.01, 0.05, Inf),
          symbols = c("***", "**", "*", "ns")
        ),
        label = label,
        size = size,
        step.increase = step.increase,
        tip.length = tip.length,
        y.position = label.y,
        fontface = "bold"
      )
    geom_args <- utils::modifyList(geom_args,
      dots[setdiff(names(dots), c("mapping", "data"))], keep.null = TRUE)
    method_name <- if (is.character(geom_args$method))
      gsub(".", "_", geom_args$method, fixed = TRUE) else ""
    full_family <- method_name %in% c("dunn_test", "tukey_hsd", "games_howell_test", "games_howell")
    if (full_family && ref_all)
      cli::cli_abort("This full-family method does not support ref.group = 'all'.")
    if (full_family && paired)
      cli::cli_abort("This full-family method does not support paired comparisons.")
    if (method_name %in% c("tukey_hsd", "games_howell_test", "games_howell")) {
      geom_args$label <- gsub("p.signif", "p.adj.signif", geom_args$label, fixed = TRUE)
    }
    stat_mapping <- geom_args$mapping
    geom_args$mapping <- NULL
    layer <- do.call(ggpubr::geom_pwc, geom_args)
    layer$mapping <- stat_mapping
    native_stat <- layer$stat
    layer$stat <- ggplot2::ggproto(NULL, native_stat,
      optional_aes = unique(c(native_stat$optional_aes, ".fmt_com_id")),
      parameters = function(extra = FALSE) native_stat$parameters(extra),
      compute_panel = function(data, scales, ...) {
        args <- list(...)
        if (!is.null(args$y.position)) {
          args$y.position <- scales$y$transform(args$y.position)
        } else if (!is.null(label.y.prop)) {
          y_range <- scales$y$range$range
          args$y.position <- y_range[1] + label.y.prop * diff(y_range)
        }
        if (!is.null(args$y.position) && is.null(dots$bracket.nudge.y)) {
          args$bracket.nudge.y <- 0
        }
        layout_y <- args$y.position
        layout_nudge <- args$bracket.nudge.y
        if (vector_layout) {
          args$y.position <- 0
          args$step.increase <- args$bracket.nudge.y <- 0
          args$tip.length <- c(0, 0)
        }
        limits <- as.character(scales$x$get_limits())
        ref_lookup <- if (compare_group) group_labels else limits
        ref_id <- if (is.null(ref_group) || ref_all) NULL else
          if (is.numeric(ref_group)) as.integer(ref_group) else match(ref_group, ref_lookup)
        if (!is.null(ref_id)) args$ref.group <- ref_id
        select_pairs <- function(values, lookup) {
          available <- sort(unique(as.numeric(as.character(values))))
          available <- available[available %in% which(!is.na(lookup))]
          if (length(available) < 2L) return(list())
          pairs <- if (ref_all) {
            lapply(available, function(value) c(value, value))
          } else if (!is.null(ref_id)) {
            if (!ref_id %in% available) return(list())
            lapply(setdiff(available, ref_id), function(value) c(ref_id, value))
          } else if (is.list(comparisons)) {
            lapply(comparisons, function(pair) match(pair, lookup))
          } else if (comparisons == "con") {
            Map(c, head(available, -1L), tail(available, -1L))
          } else utils::combn(available, 2L, simplify = FALSE)
          Filter(function(pair) all(pair %in% available), pairs)
        }
        keys <- if (!grouped) rep("all", nrow(data)) else
          as.character(if (compare_group) data$x else data$group)
        values <- if (compare_group) data$group else data$x
        lookup <- if (compare_group) group_labels else limits
        eligible <- vapply(split(values, keys), function(value) {
          length(select_pairs(value, lookup)) > 0L
        }, logical(1))
        data <- data[keys %in% names(eligible)[eligible], , drop = FALSE]
        if (!nrow(data)) return(data.frame())
        positions <- sort(unique(as.numeric(data$x)))
        native_method <- args$method
        args$method <- function(data, formula, ...) {
          test_args <- list(...)
          test_details <- NULL
          test_classes <- NULL
          run_test <- function(d, context = "") {
            variable <- all.vars(formula)[2L]
            lookup <- if (variable == "group") group_labels else limits
            d[[variable]] <- droplevels(factor(d[[variable]]))
            pairs <- select_pairs(d[[variable]], lookup)
            if (!length(pairs)) return(data.frame(group1 = character(), group2 = character(),
              p = numeric(), p.adj = numeric(), n1 = integer(), n2 = integer(), .y. = character()))
            directional <- !is.null(test_args$alternative) &&
              match.arg(test_args$alternative, c("two.sided", "less", "greater")) != "two.sided"
            if (directional && is.null(ref_group) && !is.list(comparisons))
              pairs <- lapply(pairs, function(pair) pair[order(match(lookup[pair], comparison_order))])
            if (!full_family && !ref_all) test_args$comparisons <- lapply(pairs, as.character)
            if (full_family) test_args$ref.group <- NULL
            if (paired || (directional && !full_family && !ref_all)) {
              pair_args <- test_args
              pair_args$id <- pair_args$comparisons <- NULL
              parts <- lapply(pairs, function(pair) {
                part <- d[as.character(d[[variable]]) %in% as.character(pair), , drop = FALSE]
                if (paired) {
                  ids <- lapply(as.character(pair), function(group) part$.fmt_com_id[as.character(part[[variable]]) == group])
                  common <- intersect(ids[[1L]], ids[[2L]])
                  part <- part[part$.fmt_com_id %in% common, , drop = FALSE]
                  part <- part[order(part[[variable]], part$.fmt_com_id), , drop = FALSE]
                }
                part[[variable]] <- if (directional) factor(as.character(part[[variable]]), levels = as.character(pair)) else
                  droplevels(part[[variable]])
                do.call(native_method, c(list(data = part, formula = formula), pair_args))
              })
              details <- attr(parts[[1L]], "args")
              details$data <- d
              details$formula <- formula
              result <- rstatix::adjust_pvalue(dplyr::bind_rows(parts), method = test_args$p.adjust.method)
              attr(result, "args") <- details
            } else result <- do.call(native_method, c(list(data = d, formula = formula), test_args))
            if (full_family) {
              selected <- vapply(pairs, function(pair) paste(sort(as.character(pair)), collapse = ":"), character(1))
              keys <- mapply(function(a, b) paste(sort(c(as.character(a), as.character(b))), collapse = ":"),
                             result$group1, result$group2, USE.NAMES = FALSE)
              result <- result[keys %in% selected, , drop = FALSE]
            }
            if (!"p.adj" %in% names(result) && "p" %in% names(result))
              result <- rstatix::adjust_pvalue(result, method = test_args$p.adjust.method)
            if (vector_layout && nrow(result)) {
              first <- as.character(result$group1)
              first[first %in% c("all", ".all.")] <- as.character(result$group2[first %in% c("all", ".all.")])
              keys <- mapply(function(a, b) pair_key(lookup[as.integer(a)], lookup[as.integer(b)], context),
                             first, as.character(result$group2), USE.NAMES = FALSE)
              result$.fmt_com_layout <- match(keys, layout_keys)
              if (anyNA(result$.fmt_com_layout)) cli::cli_abort("Layout vectors cannot resolve this comparison; supply explicit com_method pairs.")
            }
            test_details <<- attr(result, "args")
            test_classes <<- class(result)
            result
          }
          if (dplyr::is_grouped_df(data)) {
            result <- dplyr::ungroup(dplyr::group_modify(data, function(.x, .y) {
              context <- if (compare_group) limits[as.numeric(as.character(.y$x))] else group_labels[as.numeric(as.character(.y$group))]
              result <- run_test(.x, context)
              if ("x" %in% names(.y)) {
                result$.fmt_com_x <- rep(as.numeric(as.character(.y$x)), nrow(result))
              }
              result
            }))
            test_details$data <- data
            test_details$formula <- formula
            attr(result, "args") <- test_details
            class(result) <- unique(c(test_classes, class(result)))
            return(result)
          }
          run_test(data)
        }
        if (!grouped) data$group <- data$x
        result <- do.call(native_stat$compute_panel, c(list(data = data, scales = scales), args))
        if (nrow(result)) {
          if (vector_layout) {
            index <- result$.fmt_com_layout
            pick <- function(value) if (length(value) == 1L) rep(value, nrow(result)) else value[index]
            y_range <- diff(scales$y$range$range)
            y <- if (is.null(layout_y)) rep(scales$y$range$range[2L], nrow(result)) else pick(layout_y)
            y <- y + y_range * pick(layout_nudge)
            if (length(layout_y) <= 1L) y <- y + y_range * pick(step.increase) * (result$bracket.group - 1L)
            tips <- if (length(tip.length) == 2L * length(layout_keys)) {
              list(left = tip.length[2L * index - 1L], right = tip.length[2L * index])
            } else list(left = pick(tip.length), right = pick(tip.length))
            n <- nrow(result) / 3L
            result$y <- y - y_range * tips$left * rep(c(TRUE, FALSE, FALSE), each = n)
            result$yend <- y - y_range * tips$right * rep(c(FALSE, FALSE, TRUE), each = n)
            result$.fmt_com_layout <- NULL
          }
          # Native brackets use dense positions; restore retained scale holes.
          left <- if (compare_group) result$.fmt_com_x else as.numeric(result$group1)
          right <- if (compare_group) result$.fmt_com_x else as.numeric(result$group2)
          left_shift <- left - match(left, positions)
          right_shift <- right - match(right, positions)
          n <- nrow(result) / 3L
          result$x <- result$x + ifelse(rep(c(TRUE, TRUE, FALSE), each = n), left_shift, right_shift)
          result$xend <- result$xend + ifelse(rep(c(TRUE, FALSE, FALSE), each = n), left_shift, right_shift)
          result$xmin <- result$xmin + left_shift
          result$xmax <- result$xmax + right_shift
          result$.fmt_com_x <- NULL
        }
        result
      }
    )
    p + layer
  }

  info <- .to_plot_list(plot, recurse = TRUE)
  info$plots <- lapply(info$plots, fmt_com_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single,
                  pw_orig = info$pw_orig, recurse = TRUE)
}

# ---- fmt_bg ----

#' Add coloured background stripes
#'
#' Inserts shaded rectangles behind the data layer, one per level of the
#' categorical axis variable, including in faceted and combined plots.
#'
#' @param plot A ggplot, patchwork, or list of ggplots.
#' @param palette Palette name passed to \code{plotthis::palette_this}.
#'   Requires \pkg{plotthis} only when palette colours are needed. \code{NULL}
#'   retains the default rainbow colours.
#' @param palcolor Manual colour vector (overrides palette). Named vectors match
#'   category values, with unmatched categories using the palette. Unnamed
#'   vectors are interpolated to the number of levels.
#'   Named colours covering all displayed categories, after scale limits are
#'   applied, do not require \pkg{plotthis}.
#' @param alpha A finite numeric value from 0 to 1 giving the opacity of the
#'   background rectangles. Zero returns the input unchanged.
#' @param bg_axis Which axis holds the categorical variable: \code{"x"} or
#'   \code{"y"}.
#'
#' @details Factor, character and logical axes, categorical mapping expressions
#'   and layer data supplied as data frames, functions or formulas are supported.
#'   The first applicable categorical layer mapping is used; numeric annotation
#'   positions are skipped. Explicit discrete position scales also support
#'   numeric mapped or fixed positions. Continuous axes are skipped with a warning.
#'   Mapping expressions, including [ggplot2::after_stat()], and data callbacks
#'   are evaluated only by ggplot during rendering. For these mappings,
#'   categorical-axis checks and palette resolution are deferred until drawing.
#'
#'   Stripes follow the trained scale order, including unused categories and
#'   the local categories of free-scale facets. Category colours are shared
#'   across panels, including categories contributed by later layers. Missing
#'   categories use
#'   \code{"grey80"}, including panels containing only missing categories when
#'   other panels have non-missing categories. Facet expressions, marginal
#'   panels, flipped and polar
#'   coordinates, radial bands and log-scaled continuous axes are supported.
#'   Backgrounds retain the plot's panel ranges, fill scales and legends, and
#'   stay clipped to the panel even when foreground clipping is disabled.
#'
#'   Nested data plots are formatted recursively. Patchwork layouts,
#'   annotations and list names are retained; spacers, guide areas, inset
#'   overlays and fixed wrapped graphics are left unchanged. Format the
#'   original ggplot before wrapping it with [patchwork::wrap_elements()].
#'   Repeated calls replace this function's background layer while retaining
#'   all other layers, so transparency does not accumulate. Background drawing
#'   closures retain only their colour and axis settings, keeping serialized
#'   plots bounded across repeated calls.
#'   Direct column mappings with empty or entirely missing categories are
#'   returned unchanged; deferred mappings with no categories draw no background.
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' set.seed(123)
#' dat <- data.frame(category = factor(rep(c("A", "B", "C"), each = 8)),
#'                   value = rnorm(24))
#' p <- ggplot(dat, aes(category, value)) + geom_boxplot()
#' fmt_bg(p, alpha = 0.2)
#' fmt_bg(p + scale_x_discrete(limits = c("C", "B", "A")),
#'        palcolor = c(A = "#E64B35", B = "#4DBBD5", C = "#00A087"))
#'
#' @export
#' @md
#' @family plot formatting
fmt_bg <- function(plot,
                   palette = NULL,
                   palcolor = NULL,
                   alpha = 0.3,
                   bg_axis = c("x", "y")) {
  bg_axis <- match.arg(bg_axis)

  if (!is.numeric(alpha) || is.complex(alpha) || length(alpha) != 1L ||
      !is.finite(alpha) || alpha < 0 || alpha > 1) {
    cli::cli_abort("{.arg alpha} must be a finite number between 0 and 1.")
  }

  if (!is.null(palcolor)) {
    if (!is.character(palcolor) || !length(palcolor) || anyNA(palcolor)) {
      cli::cli_abort("{.arg palcolor} must be a non-empty character colour vector.")
    }
    color_names <- names(palcolor)
    if (!is.null(color_names) &&
        (anyNA(color_names) || any(!nzchar(color_names)) || anyDuplicated(color_names))) {
      cli::cli_abort("{.arg palcolor} names must be non-empty and unique.")
    }
    tryCatch(grDevices::col2rgb(palcolor), error = function(e) {
      cli::cli_abort("{.arg palcolor} contains an invalid colour.", parent = e)
    })
  }

  if (alpha == 0) {
    invisible(.to_plot_list(plot))
    return(plot)
  }

  resolve_bg_colors <- function(lvs) {
    if (!is.null(palcolor)) {
      if (is.null(names(palcolor))) {
        cols <- if (length(palcolor) == length(lvs)) palcolor else
          grDevices::colorRampPalette(palcolor)(length(lvs))
        return(stats::setNames(cols, lvs))
      }
      if (all(lvs %in% names(palcolor))) return(palcolor[lvs])
    }
    if (is.null(palette)) {
      cols <- stats::setNames(grDevices::rainbow(length(lvs), alpha = 0.3), lvs)
    } else {
      if (!requireNamespace("plotthis", quietly = TRUE)) {
        cli::cli_abort("Package {.pkg plotthis} is required for {.arg palette}.")
      }
      cols <- plotthis::palette_this(lvs, palette = palette)
    }
    if (!is.null(palcolor)) {
      matched <- lvs %in% names(palcolor)
      cols[matched] <- palcolor[lvs[matched]]
    }
    cols
  }
  environment(resolve_bg_colors) <- list2env(list(palette = palette, palcolor = palcolor),
                                             parent = environment(fmt_bg))

  # Unified background layer builder for both x and y axes
  build_bg_layer <- function(lvs, alpha, bg_axis = "x") {
    # Keep lazy arguments from retaining the caller's plot in ggproto closures.
    force(lvs)
    force(alpha)
    force(bg_axis)

    bg_color <- if (length(lvs) &&
                    (is.null(names(palcolor)) || all(lvs %in% names(palcolor)))) {
      resolve_bg_colors(lvs)
    } else NULL

    bg_data <- data.frame(.bg = TRUE)

    bg_geom <- ggplot2::ggproto("GeomBgStripes", ggplot2::GeomRect,
      required_aes = character(),
      setup_data = function(data, params) data,
      draw_layer = function(self, data, params, layout, coord) {
        params$bg_scales <- lapply(seq_len(nrow(layout$layout)), function(i) {
          layout$get_scales(i)[[bg_axis]]
        })
        if (!any(vapply(params$bg_scales, function(scale) scale$is_discrete(), logical(1)))) {
          cli::cli_warn("The {bg_axis}-axis must be categorical; skipping background.")
        }
        trained_limits <- unlist(lapply(params$bg_scales, function(scale) {
          if (scale$is_discrete()) scale$get_limits() else character()
        }), use.names = FALSE)
        params$bg_has_categories <- any(!is.na(trained_limits))
        limits <- unique(c(lvs, trained_limits))
        limits <- limits[!is.na(limits)]
        shown <- unique(trained_limits[!is.na(trained_limits)])
        params$bg_colors <- if (!is.null(names(palcolor)) && all(shown %in% names(palcolor))) {
          palcolor[shown]
        } else if (!is.null(bg_color) && all(limits %in% lvs)) bg_color else resolve_bg_colors(limits)
        ggplot2::ggproto_parent(ggplot2::GeomRect, self)$draw_layer(data, params, layout, coord)
      },
      draw_panel = function(data, panel_params, coord, bg_scales, bg_colors,
                            bg_has_categories, na.rm = FALSE) {
        scale <- bg_scales[[as.integer(data$PANEL[1])]]
        if (!scale$is_discrete()) return(ggplot2::zeroGrob())
        limits <- scale$get_limits()
        positions <- as.numeric(scale$map(limits))
        keep <- is.finite(positions)
        limits <- limits[keep]
        positions <- positions[keep]
        if (!length(limits) || !bg_has_categories) return(ggplot2::zeroGrob())
        fills <- unname(bg_colors[match(limits, names(bg_colors))])
        fills[is.na(limits)] <- "grey80"
        edges <- (head(positions, -1L) + tail(positions, -1L)) / 2
        rectangles <- data[rep(1L, length(limits)), , drop = FALSE]
        rectangles$xmin <- -Inf
        rectangles$xmax <- Inf
        rectangles$ymin <- -Inf
        rectangles$ymax <- Inf
        rectangles[[paste0(bg_axis, "min")]] <- c(-Inf, edges)
        rectangles[[paste0(bg_axis, "max")]] <- c(edges, Inf)
        rectangles$fill <- fills
        grob <- ggplot2::GeomRect$draw_panel(rectangles, panel_params, coord)
        grob$vp <- grid::viewport(clip = "on")
        grob$name <- "fmt-bg-stripes"
        grob
      })
    bg_layer <- ggplot2::geom_rect(
      data = bg_data,
      ggplot2::aes(),
      fill = NA, alpha = alpha, inherit.aes = FALSE, show.legend = FALSE
    )
    bg_layer$geom <- bg_geom
    bg_layer
  }
  environment(build_bg_layer) <- list2env(list(resolve_bg_colors = resolve_bg_colors,
                                              palcolor = palcolor),
                                          parent = environment(fmt_bg))

  fmt_bg_one <- function(p) {
    mapping_var <- p$mapping[[bg_axis]]
    axis_values <- NULL
    has_layer_mapping <- FALSE
    deferred <- FALSE
    layers <- p$layers
    if (!length(layers)) layers <- list(list(mapping = p$mapping, data = p$data, inherit.aes = FALSE))
    for (layer in layers) {
      layer_mapping <- layer$mapping[[bg_axis]]
      if (is.null(layer_mapping) && layer$inherit.aes) layer_mapping <- mapping_var
      if (is.null(layer_mapping)) next
      has_layer_mapping <- TRUE
      expression <- rlang::get_expr(layer_mapping)
      layer_data <- if (is.data.frame(layer$data)) layer$data else p$data
      if (is.function(layer$data) || inherits(layer$data, "formula") ||
          (is.language(expression) && !is.symbol(expression)) ||
          (is.symbol(expression) &&
           (!is.data.frame(layer_data) || !as.character(expression) %in% names(layer_data)))) {
        deferred <- TRUE
        break
      }
      values <- if (is.symbol(expression)) layer_data[[as.character(expression)]] else expression
      if (is.factor(values) || is.character(values) || is.logical(values)) {
        axis_values <- values
        if (length(values) && any(!is.na(values))) break
      }
    }
    axis_scale <- p$scales$get_scales(bg_axis)
    has_discrete_scale <- !is.null(axis_scale) && axis_scale$is_discrete()
    if (has_discrete_scale && is.null(axis_values)) deferred <- TRUE
    if (!has_layer_mapping && !has_discrete_scale) {
      cli::cli_warn("No {bg_axis}-axis mapping found; skipping background.")
      return(p)
    }
    if (!deferred && !is.factor(axis_values) && !is.character(axis_values) && !is.logical(axis_values)) {
      cli::cli_warn("The {bg_axis}-axis must be categorical; skipping background.")
      return(p)
    }
    if (!deferred && (!length(axis_values) || all(is.na(axis_values)))) return(p)
    lvs <- if (is.factor(axis_values)) levels(droplevels(axis_values)) else levels(factor(axis_values))
    bg_layer <- build_bg_layer(lvs, alpha = alpha, bg_axis = bg_axis)
    p$layers <- c(list(bg_layer), Filter(function(layer) {
      !inherits(layer$geom, "GeomBgStripes")
    }, p$layers))
    p
  }

  info <- .to_plot_list(plot, recurse = TRUE)
  info$plots <- lapply(info$plots, fmt_bg_one)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single,
                  pw_orig = info$pw_orig, recurse = TRUE)
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
