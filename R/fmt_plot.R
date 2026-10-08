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
#         .extract_discrete_levels()   read discrete axis levels off a plot
#
# The container helpers (.to_plot_list / .from_plot_list /
# flatten_patchwork) live in fmt_plot_utils.R, which is why every formatter
# accepts a ggplot, a patchwork or a plain list of plots.
# =============================================================================

# ---- fmt_axis ----

#' Hide or show axis elements for specific plots
#'
#' Selectively hide axis text, ticks, and titles for plots in a multi-plot
#' layout. Useful for removing redundant axes when plots share the same scale.
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param x.axis Logical or integer vector. `FALSE` (default) keeps all x-axes.
#'   `TRUE` hides x-axis for all but the last plot. An integer vector specifies
#'   which plot indices should have their x-axis hidden.
#' @param y.axis Logical or integer vector. `FALSE` (default) keeps all y-axes.
#'   `TRUE` hides y-axis for all but the first plot. An integer vector specifies
#'   which plot indices should have their y-axis hidden.
#' @param plot_dims Integer vector of length 1 or 2 giving `c(nrow, ncol)` of
#'   the layout. When provided, automatically determines which axes to hide:
#'   x-axes are hidden for all rows except the last, y-axes for all columns
#'   except the first.
#'
#' @return Same type as input (ggplot, patchwork, or list).
#'
#' @examples
#' library(ggplot2)
#' p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
#' p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()
#'
#' # Hide x-axis on first plot
#' fmt_axis(list(p1, p2), x.axis = 1)
#'
#' # Auto-detect 2x1 grid layout
#' fmt_axis(list(p1, p2), plot_dims = c(2, 1))
#'
#' @export
#' @family plot formatting
fmt_axis <- function(plot, x.axis = FALSE, y.axis = FALSE, plot_dims = NULL) {
  info <- .to_plot_list(plot, recurse = TRUE)
  plots <- info$plots
  n <- length(plots)
  if (n == 0L) return(plot)

  # When plot_dims is provided, compute which axes to hide

  if (!is.null(plot_dims)) {
    if (length(plot_dims) == 1L) {
      nr <- plot_dims[1]
      nc <- ceiling(n / nr)
    } else if (length(plot_dims) >= 2L) {
      nr <- plot_dims[1]
      nc <- plot_dims[2]
    } else {
      cli::cli_warn("{.arg plot_dims} format invalid, using original axis settings.")
      nr <- NA
      nc <- NA
    }

    if (!is.na(nr) && !is.na(nc) && nr > 0 && nc > 0) {
      # Hide x-axis for all rows except last
      if (nr > 1L) {
        last_row_start <- (nr - 1L) * nc + 1L
        x.axis <- seq_len(last_row_start - 1L)
        x.axis <- x.axis[x.axis <= n]
      }
      # Hide y-axis for all columns except first
      if (nc > 1L) {
        y.axis <- integer(0)
        for (row in seq_len(nr)) {
          for (col in 2L:nc) {
            idx <- (row - 1L) * nc + col
            if (idx <= n) y.axis <- c(y.axis, idx)
          }
        }
      }
    }
  }

  # Resolve indices to hide
  resolve_idx <- function(axis_arg, default_true) {
    if (isFALSE(axis_arg) || is.null(axis_arg)) return(integer(0))
    if (isTRUE(axis_arg)) return(default_true)
    if (is.numeric(axis_arg)) return(axis_arg[axis_arg >= 1L & axis_arg <= n])
    integer(0)
  }

  idx_x <- resolve_idx(x.axis, if (n > 1L) seq_len(n - 1L) else 1L)
  idx_y <- resolve_idx(y.axis, if (n > 1L) 2L:n else 1L)

  hide_x_theme <- ggplot2::theme(
    axis.text.x = ggplot2::element_blank(),
    axis.ticks.x = ggplot2::element_blank(),
    axis.title.x = ggplot2::element_blank(),
    axis.ticks.length.x = ggplot2::unit(0, "pt")
  )
  hide_y_theme <- ggplot2::theme(
    axis.text.y = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.ticks.length.y = ggplot2::unit(0, "pt")
  )

  for (i in idx_x) plots[[i]] <- plots[[i]] + hide_x_theme
  for (i in idx_y) plots[[i]] <- plots[[i]] + hide_y_theme

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
#'   Invalid positions raise an error.
#' @param size Positive finite numeric label sizes in points, recycled over
#'   data plots. Default 18.
#' @param color R colour specifications for text and borders, recycled over
#'   data plots. Numeric palette colours and `NA` are accepted. Default `"black"`.
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
  clear_tags <- function(p) {
    if (inherits(p, "patchwork")) {
      children <- lapply(seq_along(p), function(j) p[[j]])
      keep <- !vapply(children, function(child) {
        !inherits(child, "patchwork") && inherits(child, "inset_patch") &&
          isTRUE(attr(child, ".fmt_tag_generated"))
      }, logical(1))
      if (all(keep)) {
        for (j in seq_along(p)) p[[j]] <- clear_tags(children[[j]])
        return(p)
      }
      children <- lapply(children[keep], clear_tags)
      if (length(children) == 1L && all(lengths(p$patches$layout) == 0L) &&
          all(lengths(p$patches$annotation) == 0L)) return(children[[1]])
      restored <- patchwork::wrap_plots(children)
      restored$patches$layout <- p$patches$layout
      restored$patches$annotation <- p$patches$annotation
      return(restored)
    }
    if (inherits(p, "gg")) {
      if (inherits(p, c("spacer", "guide_area", "inset_patch"))) return(p)
      p$layers <- Filter(function(layer) !isTRUE(attr(layer, ".fmt_tag_generated")),
                          p$layers)
      return(p)
    }
    if (is.list(p)) return(lapply(p, clear_tags))
    p
  }
  plot <- clear_tags(plot)
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
  if (!(is.character(color) || is.numeric(color)) || length(color) == 0L ||
      !tryCatch({ grDevices::col2rgb(color); TRUE }, error = function(e) FALSE)) {
    cli::cli_abort("{.arg color} must contain valid R colour specifications.")
  }
  if (!(length(fontface) == 1L &&
        ((is.character(fontface) && fontface %in% c("plain", "bold", "italic", "bold.italic", "symbol")) ||
         (is.numeric(fontface) && fontface %in% 1:5)))) {
    cli::cli_abort("{.arg fontface} must be one valid font face name or number from 1 to 5.")
  }
  for (nm in c("label.padding", "label.r")) {
    value <- get(nm)
    allowed_lengths <- if (nm == "label.padding") c(1L, 2L, 4L) else 1L
    if (!grid::is.unit(value) || !length(value) %in% allowed_lengths ||
        any(!is.finite(as.numeric(value))) || any(as.numeric(value) < 0)) {
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
      plots[[i]] <- plots[[i]] + inset
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
#' @param label A non-empty character vector without missing values, or `NULL`.
#'   For one faceted plot, labels are recycled across the displayed levels of
#'   its first facet variable: the first wrap variable, or the first grid column
#'   variable (row variable when there are no columns). Other variables retain
#'   their labeller. For multiple plots, labels are recycled across leaf plots
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
#'   theme, so add complete themes such as \code{theme_bw()} before this call.
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
  plots <- list()
  for (p in info$plots) {
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
      if (!is.null(p$facet$.fmt_strip_hidden)) return(p)
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
        text_x = list(centered_strip_text(lc))
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
        lbl <- ggplot2::as_labeller(local({
          labels <- if (n == 1L) label else label[i]
          function(values) {
            levels <- unique(values)
            rep_len(labels, length(levels))[match(values, levels)]
          }
        }))

        # Keep every facet variable and setting. Bind the ggproto parent in
        # its own environment so later loop iterations cannot replace it.
        plots[[i]] <- plots[[i]] + local({
          facet <- old_facet
          params <- facet$params
          params$labeller <- do.call(
            ggplot2::labeller,
            c(stats::setNames(list(lbl), fvar), list(.default = params$labeller))
          )
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
#' New headers restore strip settings hidden by [fmt_strip()] and override
#' blank strip elements while retaining existing text sizes and angles.
#'
#' @param plot A ggplot, patchwork, or list of ggplot panels filling an
#'   `nrow x ncol` grid. Row-wise and column-wise filling are supported;
#'   aligned nested rectangular grids retain their layout and annotations.
#'   Spacers and guide areas are skipped while retaining their positions.
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
#'   R colour specifications as `top_fill`; `NULL` inherits the text colour.
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
    n <- length(children)
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
      p <- children[[i]]
      child_path <- c(path, i)
      if (inherits(p, "patchwork")) {
        return(collect_grid(lapply(seq_along(p), function(j) p[[j]]),
                            p$patches$layout, child_path))
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
          text_x = ggh4x::elem_list_text(colour = label_color, face = "bold"),
          text_y = ggh4x::elem_list_text(colour = label_color, face = "bold")
        )
      )
    } else if (need_top) {
      p <- p + ggh4x::facet_wrap2(
        ggplot2::vars(.top. = !!top_label[grid_col]), strip.position = "top",
        strip = ggh4x::strip_themed(
          background_x = ggh4x::elem_list_rect(fill = top_bg),
          text_x = ggh4x::elem_list_text(colour = label_color, face = "bold")
        )
      )
    } else { # need_right only
      p <- p + ggh4x::facet_wrap2(
        ggplot2::vars(.right. = !!right_label[grid_row]), strip.position = "right",
        strip = ggh4x::strip_themed(
          background_y = ggh4x::elem_list_rect(fill = right_bg),
          text_y = ggh4x::elem_list_text(colour = label_color, face = "bold")
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
#' @param x Numeric. Rotation angle (degrees) for X-axis text.
#'   Common values: \code{45} (diagonal), \code{90} (vertical).
#'   Default \code{NULL} (no change).
#' @param y Numeric. Rotation angle (degrees) for Y-axis text.
#'   Default \code{NULL} (no change).
#' @param x_hjust Numeric. Horizontal justification for X-axis text.
#'   Default \code{NULL} (auto: 1 when \code{x > 0}, 0 when \code{x < 0},
#'   0.5 when \code{x = 0}).
#' @param x_vjust Numeric. Vertical justification for X-axis text.
#'   Default \code{NULL} (auto: 0.5 when \code{abs(x) >= 90}, 1 otherwise).
#' @param y_hjust Numeric. Horizontal justification for Y-axis text.
#'   Default \code{NULL} (auto).
#' @param y_vjust Numeric. Vertical justification for Y-axis text.
#'   Default \code{NULL} (auto).
#' @param size Numeric. Text size for both axes. Default \code{NULL}
#'   (no change).
#' @param color Character. Text color for both axes. Default \code{NULL}
#'   (no change).
#' @param face Character. Font face (\code{"plain"}, \code{"bold"},
#'   \code{"italic"}, \code{"bold.italic"}). Default \code{NULL}
#'   (no change).
#' @param ... Additional arguments passed to [ggplot2::theme()].
#'
#' @return Same type as input.
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
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

  # ---- Auto-compute hjust/vjust for rotated text ----
  auto_just <- function(angle, hjust, vjust, axis = "x") {
    if (is.null(angle)) return(list(hjust = hjust, vjust = vjust))
    if (is.null(hjust)) {
      hjust <- if (axis == "x") {
        if (angle > 0) 1 else if (angle < 0) 0 else 0.5
      } else {
        if (angle > 0) 0 else if (angle < 0) 1 else 0.5
      }
    }
    if (is.null(vjust)) {
      vjust <- if (abs(angle) >= 90) 0.5 else if (axis == "x") 1 else 0.5
    }
    list(hjust = hjust, vjust = vjust)
  }

  # ---- Build X-axis text theme ----
  x_theme <- ggplot2::theme()
  if (!is.null(x) || !is.null(size) || !is.null(color) || !is.null(face)) {
    x_just <- auto_just(x, x_hjust, x_vjust, "x")
    x_args <- list()
    if (!is.null(x))     x_args$angle <- x
    if (!is.null(x))     x_args$hjust <- x_just$hjust
    if (!is.null(x))     x_args$vjust <- x_just$vjust
    if (!is.null(size))  x_args$size  <- size
    if (!is.null(color)) x_args$colour <- color
    if (!is.null(face))  x_args$face  <- face
    if (length(x_args) > 0L) {
      x_theme <- ggplot2::theme(
        axis.text.x = do.call(ggplot2::element_text, x_args)
      )
    }
  }

  # ---- Build Y-axis text theme ----
  y_theme <- ggplot2::theme()
  if (!is.null(y) || !is.null(size) || !is.null(color) || !is.null(face)) {
    y_just <- auto_just(y, y_hjust, y_vjust, "y")
    y_args <- list()
    if (!is.null(y))     y_args$angle <- y
    if (!is.null(y))     y_args$hjust <- y_just$hjust
    if (!is.null(y))     y_args$vjust <- y_just$vjust
    if (!is.null(size))  y_args$size  <- size
    if (!is.null(color)) y_args$colour <- color
    if (!is.null(face))  y_args$face  <- face
    if (length(y_args) > 0L) {
      y_theme <- ggplot2::theme(
        axis.text.y = do.call(ggplot2::element_text, y_args)
      )
    }
  }

  # ---- Combine + extra ... ----
  extra <- if (length(list(...)) > 0) do.call(ggplot2::theme, list(...)) else ggplot2::theme()
  text_theme <- x_theme + y_theme + extra

  # ---- Apply to plots ----
  info <- .to_plot_list(plot)
  info$plots <- lapply(info$plots, function(p) p + text_theme)
  .from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig)
}

# ---- fmt_axisTile ----

#' Add colored tiles between axis and labels
#'
#' Insert a strip of colored tiles between the plot area and the axis text
#' labels. Two modes are available:
#' \itemize{
#'   \item \code{"tile"} (default) — insert a \code{geom_tile} color strip
#'     between the axis line and text labels via patchwork. Labels appear
#'     below (x-axis) or beside (y-axis) the tiles.
#'   \item \code{"text"} — color the axis label text directly (no background
#'     tile), lightweight but uses unofficial vectorized \code{element_text}.
#' }
#'
#' @param plot A ggplot, patchwork, or list of ggplot objects.
#' @param colors Named character vector of colors, where names match the
#'   discrete axis levels (e.g. \code{c(setosa = "red", virginica = "blue")}).
#'   Required.
#' @param mode \code{"tile"} (default) or \code{"text"}.
#' @param axis Which axis to apply to: \code{"x"} (default) or \code{"y"}.
#' @param tile_height Numeric. Relative height of the tile strip when
#'   \code{axis = "x"}. Default 0.06.
#' @param tile_width Numeric. Relative width of the tile strip when
#'   \code{axis = "y"}. Default 0.06.
#' @param tile_border Color of tile borders. Default \code{"white"}.
#' @param tile_border_width Line width of tile borders. Default 0.2.
#' @param text_size Size of axis text labels below/beside tiles. Default 9.
#' @param text_face Font face of axis text labels. Default \code{"plain"}.
#' @param text_angle Rotation angle for axis text labels. Default \code{45}
#'   for x-axis, \code{0} for y-axis.
#' @param text_color Color of axis text labels. Default \code{"black"}.
#' @param show_text Logical. Show text labels below/beside tiles?
#'   Default \code{TRUE}. Set \code{FALSE} for color-only tiles.
#'
#' @return A patchwork object (when \code{mode = "tile"}) or same type as
#'   input (when \code{mode = "text"}).
#'
#' @examples
#' library(ggplot2)
#' cols <- c(setosa = "#E64B35", versicolor = "#4DBBD5", virginica = "#00A087")
#' p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
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
#' p2 <- ggplot(iris, aes(Sepal.Length, Species)) + geom_boxplot()
#' fmt_axisTile(p2, colors = cols, axis = "y")
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

  # Default text_angle: 45 for x-axis, 0 for y-axis
  if (is.null(text_angle)) text_angle <- if (axis == "x") 45 else 0

  info <- .to_plot_list(plot)
  plots <- info$plots

  # ---- Text mode: color axis labels directly ----
  if (mode == "text") {
    text_theme_fn <- function(p) {
      lvs <- .extract_discrete_levels(p, axis)
      if (is.null(lvs)) return(p)
      col_vec <- colors[lvs]
      col_vec[is.na(col_vec)] <- "black"
      if (axis == "x") {
        hjust <- if (text_angle > 0) 1 else if (text_angle < 0) 0 else 0.5
        p + ggplot2::theme(axis.text.x = ggplot2::element_text(
          colour = col_vec, face = text_face, size = text_size,
          angle = text_angle, hjust = hjust))
      } else {
        p + ggplot2::theme(axis.text.y = ggplot2::element_text(
          colour = col_vec, face = text_face, size = text_size,
          angle = text_angle))
      }
    }
    info$plots <- lapply(plots, text_theme_fn)
    return(.from_plot_list(info$plots, info$is_patchwork, info$is_single, pw_orig = info$pw_orig))
  }

  # ---- Tile mode: color strip + labels below/beside ----

  build_tile_bar <- function(lvs, orientation = "x") {
    df_bar <- data.frame(
      lbl = factor(lvs, levels = lvs),
      pos = 1
    )
    col_use <- colors[lvs]
    col_use[is.na(col_use)] <- "grey70"

    if (orientation == "x") {
      p_bar <- ggplot2::ggplot(df_bar, ggplot2::aes(
        x = .data[["lbl"]], y = .data[["pos"]], fill = .data[["lbl"]])) +
        ggplot2::geom_tile(color = tile_border, linewidth = tile_border_width) +
        ggplot2::scale_fill_manual(values = col_use, guide = "none") +
        ggplot2::scale_x_discrete(drop = FALSE) +
        ggplot2::theme_void() +
        ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))

      # Text labels below the tiles as axis text
      if (show_text) {
        hjust <- if (text_angle > 0) 1 else if (text_angle < 0) 0 else 0.5
        vjust <- if (abs(text_angle) >= 90) 0.5 else 1
        p_bar <- p_bar + ggplot2::theme(
          axis.text.x = ggplot2::element_text(
            size = text_size, face = text_face, color = text_color,
            angle = text_angle, hjust = hjust, vjust = vjust))
      }
    } else {
      p_bar <- ggplot2::ggplot(df_bar, ggplot2::aes(
        x = .data[["pos"]], y = .data[["lbl"]], fill = .data[["lbl"]])) +
        ggplot2::geom_tile(color = tile_border, linewidth = tile_border_width) +
        ggplot2::scale_fill_manual(values = col_use, guide = "none") +
        ggplot2::scale_y_discrete(drop = FALSE) +
        ggplot2::theme_void() +
        ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))

      if (show_text) {
        p_bar <- p_bar + ggplot2::theme(
          axis.text.y = ggplot2::element_text(
            size = text_size, face = text_face, color = text_color,
            angle = text_angle, hjust = 1))
      }
    }
    p_bar
  }

  blank <- ggplot2::element_blank()

  combine_one <- function(p) {
    lvs <- .extract_discrete_levels(p, axis)
    if (is.null(lvs)) return(p)
    p_bar <- build_tile_bar(lvs, axis)

    if (axis == "x") {
      # Hide original x-axis text, keep axis title on the main plot
      p <- p + ggplot2::theme(
        axis.text.x = blank, axis.ticks.x = blank,
        axis.title.x = blank)
      # Move x-axis title below tiles if present
      patchwork::wrap_plots(p, p_bar, ncol = 1,
                            heights = c(1, tile_height))
    } else {
      p <- p + ggplot2::theme(
        axis.text.y = blank, axis.ticks.y = blank,
        axis.title.y = blank)
      patchwork::wrap_plots(p_bar, p, ncol = 2,
                            widths = c(tile_width, 1))
    }
  }

  if (info$is_single) {
    return(combine_one(plots[[1]]))
  }

  combined <- lapply(plots, combine_one)
  if (info$is_patchwork) {
    patchwork::wrap_plots(combined)
  } else {
    combined
  }
}

#' Extract discrete axis levels from a ggplot
#' @noRd
.extract_discrete_levels <- function(p, axis = "x") {
  mapping_var <- p$mapping[[axis]]
  if (is.null(mapping_var)) return(NULL)
  var_name <- rlang::as_name(mapping_var)
  if (is.null(p$data) || !var_name %in% colnames(p$data)) return(NULL)
  col <- p$data[[var_name]]
  if (is.factor(col)) levels(col) else sort(unique(col))
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
