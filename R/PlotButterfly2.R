# ============================================================================
# PlotButterfly2.R -- Long-format Butterfly Plot (Violin / Box / Beeswarm)
# ============================================================================

#' Butterfly Plot from Long-Format Data
#'
#' Create a butterfly (back-to-back) plot from a single long-format data frame.
#' The \code{group.by} column (exactly 2 levels) defines the left/right panels.
#' An optional \code{fill.by} column adds a dodge dimension.
#'
#' Five plot types are available:
#' \itemize{
#'   \item \code{"violin_box"}: violin + boxplot overlay (default).
#'   \item \code{"violin"}: violin only.
#'   \item \code{"box"}: boxplot only.
#'   \item \code{"beeswarm"}: deterministic beeswarm points
#'     (\code{\link[ggbeeswarm]{geom_beeswarm}}).
#'   \item \code{"beeswarm_quasirandom"}: quasi-random beeswarm points
#'     (\code{\link[ggbeeswarm]{geom_quasirandom}}).
#' }
#'
#' @param data Data frame in long format. Each row is one observation.
#' @param stat.by Character. Column for the y-axis categories.
#' @param value.by Character. Column for the continuous x-axis value.
#' @param group.by Character. Column defining the left/right panels
#'   (must have exactly 2 unique levels).
#' @param fill.by Character or \code{NULL}. Column for dodge grouping.
#'   Default \code{NULL}.
#' @param type Chart type: \code{"violin_box"} (default), \code{"violin"},
#'   \code{"box"}, \code{"beeswarm"}, or \code{"beeswarm_quasirandom"}.
#' @param levels Display order for y-axis categories. One of:
#'   \code{NULL} (default), \code{"up"} (ascending by mean),
#'   \code{"down"} (descending), or a character vector.
#' @param palette Colour palette for \code{fill.by} levels. Default
#'   \code{NULL} uses \code{pal_lancet}.
#' @param alpha Numeric 0--1. Fill/point transparency. Default 0.85.
#' @param box.width Numeric. Boxplot width. Default 0.15.
#' @param add_point Logical. Overlay jittered points (violin/box modes)?
#'   Default \code{FALSE}.
#' @param pt.size Numeric. Point size. Default 0.8.
#' @param pt.alpha Numeric. Point alpha. Default 0.5.
#' @param violin.scale Character. How violin widths are scaled:
#'   \code{"width"} (default), \code{"area"}, or \code{"count"}.
#' @param dodge.width Numeric. Dodge width. Default 0.8.
#' @param color_by Character. Beeswarm colouring mode when
#'   \code{fill.by = NULL}: \code{"fixed"} (default, single colour) or
#'   \code{"logFC"} (gradient by \code{value.by}).
#' @param fixed_color Character. Point colour for \code{color_by = "fixed"}.
#'   Default \code{"#f33131"}.
#' @param gradient_colors Character vector of length 3 (low, mid, high)
#'   for \code{color_by = "logFC"}. Default
#'   \code{c("#2166AC", "white", "#B2182B")}.
#' @param cex Numeric. Beeswarm point spacing (passed to
#'   \code{geom_beeswarm}). Default 0.3.
#' @param ref.line Numeric or \code{NULL}. Reference line. Default
#'   \code{NULL}.
#' @param ref.color Character. Reference line colour. Default
#'   \code{"#bf1a2c"}.
#' @param text.colors Character vector. Per-variable y-axis colours.
#'   Default \code{NULL}.
#' @param left.title,right.title Character. Panel titles. Default
#'   \code{NULL} (auto from \code{group.by} levels).
#' @param left.title.color,right.title.color Character. Title colours.
#'   Default \code{"#f04625"} / \code{"#00a8ee"}.
#' @param title Character. Overall title. Default \code{NULL}.
#' @param xlab Character. X-axis label. Default \code{NULL}.
#' @param base_size Numeric. Base font size. Default 14.
#' @param legend.position Legend position. Default \code{"bottom"}.
#' @param legend_theme A ggplot2 theme object. Default \code{NULL}.
#' @param width,height Numeric. Output size in inches. Default 12 / 8.
#' @param filename Character or \code{NULL}. Save path. Default
#'   \code{NULL}.
#'
#' @return A \code{patchwork} object.
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   celltype   = rep(LETTERS[1:5], each = 40, times = 4),
#'   logFC      = rnorm(800),
#'   method     = rep(rep(c("scMMR", "miloR"), each = 200), 2),
#'   comparison = rep(c("PHPT", "SHPT"), each = 400)
#' )
#'
#' # Violin + boxplot (default)
#' PlotButterfly2(df, stat.by = "celltype", value.by = "logFC",
#'                group.by = "method", fill.by = "comparison",
#'                ref.line = 0)
#'
#' # Beeswarm with dodge
#' PlotButterfly2(df, stat.by = "celltype", value.by = "logFC",
#'                group.by = "method", fill.by = "comparison",
#'                type = "beeswarm_quasirandom", ref.line = 0)
#'
#' # Beeswarm with gradient colour
#' PlotButterfly2(df[df$comparison == "PHPT", ],
#'                stat.by = "celltype", value.by = "logFC",
#'                group.by = "method", type = "beeswarm",
#'                color_by = "logFC", ref.line = 0)
#'
#' @seealso \code{\link{PlotButterfly}}
#' @importFrom ggplot2 ggplot aes geom_violin geom_boxplot geom_jitter
#'   geom_vline scale_fill_manual scale_color_manual scale_color_gradient2
#'   scale_x_continuous scale_y_discrete position_dodge labs
#'   element_text element_blank element_line
#' @importFrom patchwork plot_annotation
#' @export
#' @family plot
PlotButterfly2 <- function(
    data,
    stat.by    = NULL,
    value.by   = NULL,
    group.by   = NULL,
    fill.by    = NULL,
    type       = c("violin_box", "violin", "box",
                    "beeswarm", "beeswarm_quasirandom"),
    levels     = NULL,
    palette    = NULL,
    alpha      = 0.85,
    box.width  = 0.15,
    add_point  = FALSE,
    pt.size    = 0.8,
    pt.alpha   = 0.5,
    violin.scale = "width",
    dodge.width = 0.8,
    # ---- beeswarm-specific ----
    color_by   = c("fixed", "logFC"),
    fixed_color = "#f33131",
    gradient_colors = c("#2166AC", "white", "#B2182B"),
    cex        = 0.3,
    # ---- reference line ----
    ref.line   = NULL,
    ref.color  = "#bf1a2c",
    text.colors = NULL,
    left.title  = NULL,
    right.title = NULL,
    left.title.color  = "#f04625",
    right.title.color = "#00a8ee",
    title       = NULL,
    xlab        = NULL,
    base_size   = 14,
    legend.position = "bottom",
    legend_theme    = NULL,
    width       = 12,
    height      = 8,
    filename    = NULL
) {

  # ---- Validation ----
  type <- match.arg(type)
  color_by <- match.arg(color_by)
  is_beeswarm <- type %in% c("beeswarm", "beeswarm_quasirandom")

  for (arg in c("stat.by", "value.by", "group.by")) {
    val <- get(arg)
    if (is.null(val))
      cli::cli_abort("{.arg {arg}} is required.")
    if (!val %in% names(data))
      cli::cli_abort("Column {.val {val}} not found in {.arg data}.")
  }
  if (!is.null(fill.by) && !fill.by %in% names(data))
    cli::cli_abort("Column {.val {fill.by}} not found in {.arg data}.")

  if (is_beeswarm && !requireNamespace("ggbeeswarm", quietly = TRUE))
    cli::cli_abort("Package {.pkg ggbeeswarm} is required for beeswarm types.")

  # ---- Filter NA / "Mixed" ----
  keep <- !is.na(data[[stat.by]]) & data[[stat.by]] != "Mixed"
  data <- data[keep, ]

  # ---- Two groups ----
  groups <- unique(as.character(data[[group.by]]))
  if (length(groups) != 2L)
    cli::cli_abort("{.arg group.by} must have exactly 2 levels, got {length(groups)}.")

  if (is.null(left.title))  left.title  <- groups[1]
  if (is.null(right.title)) right.title <- groups[2]

  # ==================================================================
  # Path A: fill.by = NULL AND non-beeswarm → delegate to PlotButterfly
  # ==================================================================
  if (is.null(fill.by) && !is_beeswarm) {
    .to_wide <- function(df) {
      cts   <- unique(as.character(df[[stat.by]]))
      max_n <- max(table(df[[stat.by]]))
      mat <- lapply(cts, function(ct) {
        vals <- df[[value.by]][df[[stat.by]] == ct]
        length(vals) <- max_n
        vals
      })
      out <- as.data.frame(mat)
      colnames(out) <- cts
      out
    }

    wide_left  <- .to_wide(data[data[[group.by]] == groups[1], ])
    wide_right <- .to_wide(data[data[[group.by]] == groups[2], ])
    common_ct  <- intersect(colnames(wide_left), colnames(wide_right))
    if (length(common_ct) == 0L)
      cli::cli_abort("No common {.arg stat.by} categories.")

    combined <- PlotButterfly(
      type = "violin",
      data.left  = wide_left[,  common_ct, drop = FALSE],
      data.right = wide_right[, common_ct, drop = FALSE],
      left.title = left.title, right.title = right.title,
      levels = levels, palette = palette, alpha = alpha,
      add_box = (type %in% c("violin_box", "box")), box.width = box.width,
      add_point = add_point, pt.size = pt.size, pt.alpha = pt.alpha,
      ref.line = ref.line, ref.color = ref.color,
      text.colors = text.colors,
      left.title.color = left.title.color,
      right.title.color = right.title.color,
      title = title, xlab = xlab, base_size = base_size,
      legend.position = legend.position, legend_theme = legend_theme,
      width = width, height = height, filename = filename
    )
    return(combined)
  }

  # ==================================================================
  # Path B: fill.by specified OR beeswarm types → build directly
  # ==================================================================

  # Factor fill.by if specified
  if (!is.null(fill.by) && !is.factor(data[[fill.by]]))
    data[[fill.by]] <- factor(data[[fill.by]],
                              levels = unique(data[[fill.by]]))

  # ---- Resolve levels (y-axis order) ----
  if (is.character(levels) && length(levels) == 1L &&
      levels %in% c("up", "down")) {
    agg <- stats::aggregate(
      data[[value.by]],
      by = list(.cat = data[[stat.by]]),
      FUN = function(x) mean(abs(x), na.rm = TRUE)
    )
    agg <- agg[order(agg$x, decreasing = (levels == "down")), ]
    var_order <- as.character(agg$.cat)
  } else if (!is.null(levels)) {
    var_order <- levels
  } else {
    var_order <- unique(as.character(data[[stat.by]]))
  }
  data[[stat.by]] <- factor(data[[stat.by]], levels = var_order)

  # ---- Resolve palette ----
  has_fill <- !is.null(fill.by)
  if (has_fill) {
    n_fill <- nlevels(data[[fill.by]])
    if (is.null(palette)) {
      cols <- as.character(pal_lancet[seq_len(min(n_fill, length(pal_lancet)))])
    } else if (length(palette) == 1L && palette %in% names(palette_list)) {
      cols <- as.character(pal_get(palette, n = n_fill))
    } else {
      cols <- as.character(palette)
    }
    if (length(cols) < n_fill) cols <- rep_len(cols, n_fill)
  } else {
    cols <- NULL
  }

  # ---- Per-variable y-axis label colours ----
  nvar <- length(var_order)
  if (is.null(text.colors)) text.colors <- rep("black", nvar)
  if (length(text.colors) < nvar) text.colors <- rep_len(text.colors, nvar)

  if (is.null(xlab)) xlab <- value.by

  # ---- Shared theme ----
  side_theme <- theme_my(base_size = base_size, border = FALSE,
                         legend.position = "none") +
    ggplot2::theme(
      axis.ticks.length = ggplot2::unit(2, "mm"),
      plot.title = ggplot2::element_text(
        hjust = 0.5, size = base_size + 2, face = "bold")
    )

  pos_d <- ggplot2::position_dodge(width = dodge.width, preserve = "single")

  # ---- Builder for one side ----
  .build_side <- function(side_data, negate, show_y, panel_title,
                          title_color) {
    # Left panel: use scale_x_reverse (not data negation) to preserve signs

    # Base aesthetics: beeswarm uses color/shape, not fill
    if (has_fill && !is_beeswarm) {
      p <- ggplot2::ggplot(
        side_data,
        ggplot2::aes(x = .data[[value.by]],
                     y = .data[[stat.by]],
                     fill = .data[[fill.by]])
      )
    } else {
      p <- ggplot2::ggplot(
        side_data,
        ggplot2::aes(x = .data[[value.by]],
                     y = .data[[stat.by]])
      )
    }

    # ---- Violin layer ----
    if (type %in% c("violin", "violin_box")) {
      p <- p + ggplot2::geom_violin(position = pos_d, trim = FALSE,
                                     alpha = alpha, scale = violin.scale)
    }

    # ---- Boxplot layer ----
    if (type %in% c("box", "violin_box")) {
      if (type == "box") {
        p <- p + ggplot2::geom_boxplot(
          position = pos_d, width = box.width,
          outliers = FALSE, alpha = alpha
        )
      } else {
        p <- p + ggplot2::geom_boxplot(
          ggplot2::aes(group = interaction(.data[[stat.by]],
                                            .data[[fill.by]])),
          position = pos_d, width = box.width,
          outliers = FALSE, fill = "white", show.legend = FALSE
        )
      }
    }

    # ---- Beeswarm layer ----
    if (is_beeswarm) {
      bee_args <- list(size = pt.size, alpha = pt.alpha)

      # geom_beeswarm accepts cex; geom_quasirandom does not
      if (type == "beeswarm") bee_args$cex <- cex

      if (has_fill && color_by == "logFC") {
        # Gradient colour + shape by group + dodge
        bee_args$mapping <- ggplot2::aes(color = .data[[value.by]],
                                          shape = .data[[fill.by]])
        bee_args$dodge.width <- dodge.width
      } else if (has_fill) {
        # Colour by fill.by groups with dodge
        bee_args$mapping  <- ggplot2::aes(color = .data[[fill.by]])
        bee_args$dodge.width <- dodge.width
      } else if (color_by == "logFC") {
        # Gradient by value
        bee_args$mapping <- ggplot2::aes(color = .data[[value.by]])
      } else {
        # Fixed single colour
        bee_args$color <- fixed_color
      }

      geom_fn <- if (type == "beeswarm") {
        ggbeeswarm::geom_beeswarm
      } else {
        ggbeeswarm::geom_quasirandom
      }
      p <- p + do.call(geom_fn, bee_args)
    }

    # ---- Jittered points (violin/box modes only) ----
    if (add_point && !is_beeswarm) {
      p <- p + ggplot2::geom_jitter(
        position = ggplot2::position_jitterdodge(
          jitter.width = 0, dodge.width = dodge.width),
        size = pt.size, alpha = pt.alpha, show.legend = FALSE
      )
    }

    # ---- Reference line ----
    if (!is.null(ref.line)) {
      p <- p + ggplot2::geom_vline(
        xintercept = ref.line, linetype = "dashed",
        color = ref.color, linewidth = 0.8)
    }

    # ---- Axis adjustments ----
    if (negate) {
      p <- p +
        ggplot2::scale_x_reverse(
          expand = c(0, 0), position = "top") +
        ggplot2::scale_y_discrete(position = "right")
    } else {
      p <- p +
        ggplot2::scale_x_continuous(expand = c(0, 0), position = "top")
    }

    # ---- Colour / fill scales ----
    gradient_midpoint <- if (!is.null(ref.line)) ref.line else 0

    if (has_fill && is_beeswarm && color_by == "logFC") {
      # Gradient colour + shape by group
      p <- p +
        ggplot2::scale_color_gradient2(
          name = xlab,
          low = gradient_colors[1], mid = gradient_colors[2],
          high = gradient_colors[3], midpoint = gradient_midpoint
        ) +
        ggplot2::scale_shape_manual(values = c(16, 17, 15, 18)[
          seq_len(n_fill)])
    } else if (has_fill) {
      if (is_beeswarm) {
        p <- p + ggplot2::scale_color_manual(values = cols)
      } else {
        p <- p + ggplot2::scale_fill_manual(values = cols)
      }
    } else if (is_beeswarm && color_by == "logFC") {
      p <- p + ggplot2::scale_color_gradient2(
        name = xlab,
        low = gradient_colors[1], mid = gradient_colors[2],
        high = gradient_colors[3], midpoint = gradient_midpoint
      )
    }

    # ---- Theme ----
    p <- p +
      ggplot2::labs(title = panel_title,
                    x = if (!negate) xlab else NULL) +
      side_theme +
      ggplot2::theme(
        plot.title = ggplot2::element_text(color = title_color),
        axis.text.x = ggplot2::element_text(
          size = base_size, color = "black")
      )

    if (show_y) {
      p <- p + ggplot2::theme(
        axis.text.y = ggplot2::element_text(
          size = base_size, hjust = 0.5, colour = text.colors),
        axis.title.y = ggplot2::element_blank()
      )
    } else {
      p <- p + ggplot2::theme(
        axis.text.y = ggplot2::element_blank(),
        axis.title  = ggplot2::element_blank()
      )
    }
    p
  }

  # ---- Build left & right ----
  df_left  <- data[data[[group.by]] == groups[1], ]
  df_right <- data[data[[group.by]] == groups[2], ]

  p_left <- .build_side(df_left,  negate = TRUE,  show_y = FALSE,
                        panel_title = left.title,
                        title_color = left.title.color)
  p_right <- .build_side(df_right, negate = FALSE, show_y = TRUE,
                         panel_title = right.title,
                         title_color = right.title.color)

  # Add legend to left panel
  show_legend <- has_fill || (is_beeswarm && color_by == "logFC")
  if (show_legend) {
    p_left <- p_left + ggplot2::theme(
      legend.position  = legend.position,
      legend.title     = ggplot2::element_blank(),
      legend.text      = ggplot2::element_text(
        size = base_size - 2, color = "black"),
      legend.key.size  = ggplot2::unit(0.5, "cm")
    )
    if (!is.null(legend_theme)) {
      p_left <- fmt_legend(p_left,
                           legend.position = legend.position,
                           legend_theme    = legend_theme)
    }
  }

  combined <- p_left + p_right
  if (!is.null(title)) {
    combined <- combined +
      patchwork::plot_annotation(
        title   = title,
        caption = xlab,
        theme   = ggplot2::theme(
          plot.title = ggplot2::element_text(
            hjust = 0.5, size = base_size + 2, face = "bold"),
          plot.caption = ggplot2::element_text(
            hjust = 0.5, size = base_size + 2))
      )
  }

  # ---- Save ----
  if (!is.null(filename)) {
    ggplot2::ggsave(filename, combined,
                    width = width, height = height,
                    dpi = 300, bg = "white")
    cli::cli_alert_success("Plot saved to {.file {filename}}")
  }

  combined
}
