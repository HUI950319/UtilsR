# ============================================================================
# PlotButterfly.R -- Butterfly (back-to-back / tornado) chart
# ============================================================================

#' Butterfly Chart (Back-to-Back Symmetric Plot)
#'
#' Create a butterfly chart (also known as a tornado or back-to-back chart)
#' with three modes:
#' \itemize{
#'   \item \code{"bar"}: stacked horizontal bar chart (e.g. Risk vs Protective
#'     counts across two groups).
#'   \item \code{"bar_dodge"}: side-by-side (dodged) horizontal bar chart.
#'     Each \code{fill.by} level is drawn as a separate bar instead of stacked.
#'   \item \code{"violin"}: mirrored violin plots comparing continuous
#'     distributions between two conditions.
#' }
#'
#' @param data Data frame in long format (bar mode). Must contain columns
#'   specified by \code{stat.by}, \code{fill.by}, \code{value.by}, and
#'   \code{group.by}.
#' @param type Chart type: \code{"bar"} (default, stacked),
#'   \code{"bar_dodge"} (side-by-side), or \code{"violin"}.
#' @param stat.by Character. Column name for the y-axis category labels
#'   (bar mode). Default \code{NULL}.
#' @param fill.by Character. Column name for the stacked fill variable
#'   (bar mode, e.g. "Risk" / "Protective"). Default \code{NULL}.
#' @param value.by Character. Column name for the numeric value
#'   (bar mode). Default \code{NULL}.
#' @param group.by Character. Column name that defines the left vs right
#'   panels (bar mode; must have exactly 2 levels). Default \code{NULL}.
#' @param data.left Data frame in wide format (violin mode). Each column is
#'   a variable, each row is an observation.
#' @param data.right Data frame in wide format (violin mode). Same structure
#'   as \code{data.left}.
#' @param left.title Character. Title for the left panel. Default
#'   \code{NULL} (auto-detected from \code{group.by} levels or
#'   \code{"Left"}).
#' @param right.title Character. Title for the right panel. Default
#'   \code{NULL} (auto-detected from \code{group.by} levels or
#'   \code{"Right"}).
#' @param levels Display order for y-axis categories. One of:
#'   \itemize{
#'     \item \code{NULL} (default): original data order.
#'     \item \code{"up"}: sort by mean value ascending (smallest at bottom).
#'     \item \code{"down"}: sort by mean value descending (largest at bottom).
#'     \item A character vector: explicit custom order.
#'   }
#' @param palette Colour palette. One of:
#'   \itemize{
#'     \item \code{NULL} (default): uses \code{pal_lancet}.
#'     \item A single string matching a name in \code{palette_list}: uses
#'       \code{pal_get()}.
#'     \item A character vector of colours: used directly.
#'   }
#'   In bar mode, colours map to \code{fill.by} levels.
#'   In violin mode, colours map to each variable.
#' @param alpha Numeric 0--1. Fill transparency. Default 0.85.
#' @param bar.width Numeric. Bar width (bar mode). Default 0.7.
#' @param bar.border Character. Bar border colour. Default \code{"black"}.
#' @param alpha.by Character. Column name for mapping bar fill transparency
#'   (bar mode only). When provided, the alpha of each bar is scaled by
#'   this column's values (e.g. cell type percentage), producing darker
#'   bars for higher values. Overrides the fixed \code{alpha}. Default
#'   \code{NULL} (uniform alpha).
#' @param alpha.range Numeric vector of length 2. The output alpha range
#'   for \code{alpha.by} mapping. Default \code{c(0.3, 1)}.
#' @param minmax Logical. If \code{TRUE}, apply min-max scaling (0--1)
#'   to the \code{value.by} column within each combination of
#'   \code{group.by} and \code{fill.by} (bar mode only). Useful when
#'   comparing methods that produce values on different scales.
#'   Default \code{FALSE}.
#' @param add_box Logical. Overlay boxplot on violins (violin mode)?
#'   Default \code{TRUE}.
#' @param box.width Numeric. Box overlay width. Default 0.15.
#' @param add_point Logical. Overlay jittered points on violins?
#'   Default \code{FALSE}.
#' @param pt.size Numeric. Jitter point size. Default 0.8.
#' @param pt.alpha Numeric. Jitter point transparency. Default 0.5.
#' @param ref.line Numeric. Reference line x-position (violin mode).
#'   Default \code{NULL} (none).
#' @param ref.color Character. Reference line colour. Default
#'   \code{"#bf1a2c"}.
#' @param text.colors Character vector. Per-variable y-axis label colours
#'   (violin mode). Default \code{NULL} (all black).
#' @param left.title.color Character. Left panel title colour.
#'   Default \code{"#f04625"}.
#' @param right.title.color Character. Right panel title colour.
#'   Default \code{"#00a8ee"}.
#' @param title Character. Overall plot title. Default \code{NULL}.
#' @param xlab Character. X-axis label. Default \code{NULL} (auto).
#' @param base_size Numeric. Base font size. Default 14.
#' @param legend.position Legend position. Accepts standard ggplot2 values
#'   (\code{"bottom"}, \code{"right"}, \code{"none"}) or a numeric vector
#'   \code{c(x, y)} for inside-plot placement. Default \code{"bottom"}.
#' @param legend_theme A ggplot2 theme object for styling the legend box,
#'   e.g. \code{theme_legend1()}. When provided, legend formatting is
#'   applied via \code{\link{fmt_legend}}. Default \code{NULL}.
#' @param width Numeric. Output width in inches when saving. Default 12.
#' @param height Numeric. Output height in inches when saving. Default 8.
#' @param filename Character. File path to save the plot. Default
#'   \code{NULL} (no saving).
#'
#' @return A \code{patchwork} object.
#'
#' @examples
#' # --- Bar mode (stacked) ---
#' set.seed(42)
#' bar_df <- data.frame(
#'   celltype = rep(c("T cell", "B cell", "NK cell", "Macrophage"),
#'                  each = 2, times = 2),
#'   response = rep(c("Risk", "Protective"), times = 8),
#'   count    = sample(1:15, 16, replace = TRUE),
#'   group    = rep(c("PHPT", "SHPT"), each = 8)
#' )
#' PlotButterfly(bar_df, stat.by = "celltype", fill.by = "response",
#'               value.by = "count", group.by = "group")
#'
#' # --- Bar mode sorted by mean value (ascending) ---
#' PlotButterfly(bar_df, stat.by = "celltype", fill.by = "response",
#'               value.by = "count", group.by = "group", levels = "up")
#'
#' # --- Bar dodge mode (side-by-side) ---
#' PlotButterfly(bar_df, type = "bar_dodge", stat.by = "celltype",
#'               fill.by = "response", value.by = "count",
#'               group.by = "group",
#'               palette = c("#E74C3C", "#3498DB"))
#'
#' # --- Violin mode ---
#' set.seed(123)
#' dl <- data.frame(A = rnorm(40, 0.7, 0.2), B = rnorm(40, 0.3, 0.1))
#' dr <- data.frame(A = rnorm(40, 0.3, 0.15), B = rnorm(40, 0.7, 0.2))
#' PlotButterfly(type = "violin", data.left = dl, data.right = dr,
#'               left.title = "Condition A", right.title = "Condition B")
#'
#' # Violin with reference line and custom colours
#' PlotButterfly(type = "violin", data.left = dl, data.right = dr,
#'               left.title = "Group A", right.title = "Group B",
#'               palette = c("#66a686", "#5292c4"),
#'               ref.line = 0.25, add_point = TRUE)
#'
#' @importFrom ggplot2 ggplot aes geom_col geom_violin geom_boxplot
#'   geom_jitter geom_vline scale_fill_manual scale_x_continuous
#'   scale_y_discrete labs theme element_text element_blank element_line
#'   margin unit
#' @importFrom patchwork plot_annotation
#' @export
#' @family plot
PlotButterfly <- function(
    data        = NULL,
    type        = c("bar", "bar_dodge", "violin"),
    # ---- bar-mode columns ----
    stat.by     = NULL,
    fill.by     = NULL,
    value.by    = NULL,
    group.by    = NULL,
    # ---- violin-mode data ----
    data.left   = NULL,
    data.right  = NULL,
    left.title  = NULL,
    right.title = NULL,
    # ---- shared aesthetics ----
    levels      = NULL,
    palette     = NULL,
    alpha       = 0.85,
    # ---- bar options ----
    alpha.by    = NULL,
    alpha.range = c(0.3, 1),
    minmax      = FALSE,
    bar.width   = 0.7,
    bar.border  = "black",
    # ---- violin overlays ----
    add_box     = TRUE,
    box.width   = 0.15,
    add_point   = FALSE,
    pt.size     = 0.8,
    pt.alpha    = 0.5,
    ref.line    = NULL,
    ref.color   = "#bf1a2c",
    text.colors = NULL,
    left.title.color  = "#f04625",
    right.title.color = "#00a8ee",
    # ---- labels & theme ----
    title       = NULL,
    xlab        = NULL,
    base_size   = 14,
    legend.position = "bottom",
    legend_theme    = NULL,
    # ---- output ----
    width       = 12,
    height      = 8,
    filename    = NULL
) {

  type <- match.arg(type)

  # ---- Resolve palette helper ----
  .resolve_cols <- function(n) {
    if (is.null(palette)) {
      cols <- as.character(pal_lancet[seq_len(min(n, length(pal_lancet)))])
    } else if (length(palette) == 1L && palette %in% names(palette_list)) {
      cols <- as.character(pal_get(palette, n = n))
    } else {
      cols <- as.character(palette)
    }
    if (length(cols) < n) cols <- rep_len(cols, n)
    cols
  }

  # ========================================================================
  # Bar mode
  # ========================================================================
  if (type %in% c("bar", "bar_dodge")) {
    if (is.null(data)) cli::cli_abort("{.arg data} is required for bar mode.")
    for (col in c(stat.by, fill.by, value.by, group.by)) {
      if (is.null(col)) cli::cli_abort("All of {.arg stat.by}, {.arg fill.by}, {.arg value.by}, {.arg group.by} are required for bar mode.")
      if (!col %in% names(data))
        cli::cli_abort("Column {.val {col}} not found in {.arg data}.")
    }

    groups <- unique(as.character(data[[group.by]]))
    if (length(groups) != 2L)
      cli::cli_abort("{.arg group.by} must have exactly 2 levels, got {length(groups)}.")

    # Min-max scaling per group.by x fill.by
    if (isTRUE(minmax)) {
      data <- do.call(rbind, lapply(
        split(data, interaction(data[[group.by]], data[[fill.by]], drop = TRUE)),
        function(d) {
          rng <- range(d[[value.by]], na.rm = TRUE)
          d[[value.by]] <- (d[[value.by]] - rng[1]) /
            (rng[2] - rng[1] + 1e-12)
          d
        }
      ))
      rownames(data) <- NULL
    }

    # Complete missing stat.by x fill.by x group.by combinations with 0
    all_stats  <- unique(as.character(data[[stat.by]]))
    all_fills  <- unique(as.character(data[[fill.by]]))
    full_grid  <- expand.grid(.stat = all_stats, .fill = all_fills,
                              .group = groups, stringsAsFactors = FALSE)
    colnames(full_grid) <- c(stat.by, fill.by, group.by)
    data <- merge(full_grid, data, by = c(stat.by, fill.by, group.by),
                  all.x = TRUE)
    data[[value.by]][is.na(data[[value.by]])] <- 0

    # Factor levels: support "up" / "down" auto-sort by mean value
    if (is.character(levels) && length(levels) == 1L && levels %in% c("up", "down")) {
      ct_order <- stats::aggregate(
        data[[value.by]], by = list(.cat = data[[stat.by]]),
        FUN = mean, na.rm = TRUE
      )
      ct_order <- ct_order[order(ct_order$x, decreasing = (levels == "down")), ]
      data[[stat.by]] <- factor(data[[stat.by]], levels = ct_order$.cat)
    } else if (!is.null(levels)) {
      data[[stat.by]] <- factor(data[[stat.by]], levels = levels)
    } else if (!is.factor(data[[stat.by]])) {
      data[[stat.by]] <- factor(data[[stat.by]], levels = unique(data[[stat.by]]))
    }
    if (!is.factor(data[[fill.by]])) {
      data[[fill.by]] <- factor(data[[fill.by]], levels = unique(data[[fill.by]]))
    }

    n_fill <- nlevels(data[[fill.by]])
    cols <- .resolve_cols(n_fill)
    if (is.null(xlab)) xlab <- value.by

    # Titles from group levels
    if (is.null(left.title))  left.title  <- groups[1]
    if (is.null(right.title)) right.title <- groups[2]

    # -- Shared theme for bar mode --
    bar_theme <- theme_my(base_size = base_size, border = FALSE,
                          legend.position = "none") +
      ggplot2::theme(
        axis.ticks.length = unit(2, "mm"),
        axis.ticks  = element_line(color = "black", linewidth = 0.8),
        axis.line   = element_line(color = "black", linewidth = 0.8),
        axis.title  = element_blank(),
        plot.subtitle = element_text(hjust = 0.5, size = base_size + 2,
                                     face = "bold")
      )

    # Bar position: stack vs dodge
    bar_pos <- if (type == "bar_dodge") {
      ggplot2::position_dodge(width = bar.width)
    } else {
      "stack"
    }

    # Right panel (positive direction)
    df_right <- data[data[[group.by]] == groups[2], ]
    p_right <- ggplot(df_right,
                      aes(x = .data[[value.by]], y = .data[[stat.by]]))

    if (!is.null(alpha.by)) {
      p_right <- p_right +
        geom_col(aes(fill = .data[[fill.by]], alpha = .data[[alpha.by]]),
                 position = bar_pos,
                 color = bar.border, width = bar.width) +
        ggplot2::scale_alpha_continuous(range = alpha.range, guide = "none")
    } else {
      p_right <- p_right +
        geom_col(aes(fill = .data[[fill.by]]),
                 position = bar_pos,
                 color = bar.border, width = bar.width, alpha = alpha)
    }
    p_right <- p_right +
      ggplot2::scale_x_continuous(expand = c(0, 0), position = "top") +
      scale_fill_manual(values = cols) +
      labs(subtitle = right.title) +
      bar_theme +
      ggplot2::theme(
        axis.text.y = element_text(size = base_size, hjust = 0.5,
                                    color = "black"),
        plot.margin = margin(r = 10)
      )

    # Left panel (negative direction)
    df_left <- data[data[[group.by]] == groups[1], ]
    p_left <- ggplot(df_left,
                     aes(x = -.data[[value.by]], y = .data[[stat.by]]))

    if (!is.null(alpha.by)) {
      p_left <- p_left +
        geom_col(aes(fill = .data[[fill.by]], alpha = .data[[alpha.by]]),
                 position = bar_pos,
                 color = bar.border, width = bar.width) +
        ggplot2::scale_alpha_continuous(range = alpha.range,
                                        guide = ggplot2::guide_legend(title = alpha.by))
    } else {
      p_left <- p_left +
        geom_col(aes(fill = .data[[fill.by]]),
                 position = bar_pos,
                 color = bar.border, width = bar.width, alpha = alpha)
    }
    p_left <- p_left +
      scale_x_continuous(labels = function(x) format(abs(x)),
                         expand = c(0, 0), position = "top") +
      scale_y_discrete(position = "right") +
      scale_fill_manual(values = cols) +
      labs(subtitle = left.title) +
      bar_theme +
      ggplot2::theme(
        axis.text.y   = element_blank(),
        legend.position = legend.position,
        legend.title  = if (is.null(alpha.by)) element_blank()
                        else element_text(size = base_size - 2, face = "bold"),
        legend.text   = element_text(size = base_size - 2, color = "black"),
        legend.key.size = unit(0.5, "cm"),
        plot.margin   = margin(l = 10)
      )

    # Apply fmt_legend styling if legend_theme is provided
    if (!is.null(legend_theme)) {
      p_left <- fmt_legend(p_left,
                           legend.position = legend.position,
                           legend_theme    = legend_theme)
      # Restore alpha legend title (theme_legend1 blanks all titles)
      if (!is.null(alpha.by)) {
        p_left <- p_left + ggplot2::theme(
          legend.title = element_text(size = base_size - 2, face = "bold"))
      }
    }

    combined <- p_left + p_right +
      plot_annotation(
        title   = title,
        caption = xlab,
        theme   = ggplot2::theme(
          plot.title   = element_text(hjust = 0.5, size = base_size + 2,
                                      face = "bold"),
          plot.caption = element_text(hjust = 0.5, size = base_size + 2)
        )
      )

  # ========================================================================
  # Violin mode
  # ========================================================================
  } else {
    if (is.null(data.left) || is.null(data.right))
      cli::cli_abort("Violin mode requires both {.arg data.left} and {.arg data.right}.")

    # Pivot to long format
    long_left  <- tidyr::pivot_longer(data.left,  cols = tidyr::everything(),
                                      names_to = "Variable", values_to = "Value")
    long_right <- tidyr::pivot_longer(data.right, cols = tidyr::everything(),
                                      names_to = "Variable", values_to = "Value")

    # Variable order: support "up" / "down" auto-sort by mean value
    if (is.character(levels) && length(levels) == 1L && levels %in% c("up", "down")) {
      all_long <- rbind(
        data.frame(Variable = long_left$Variable,  Value = long_left$Value),
        data.frame(Variable = long_right$Variable, Value = long_right$Value)
      )
      mean_vals <- stats::aggregate(Value ~ Variable, data = all_long,
                                    FUN = mean, na.rm = TRUE)
      mean_vals <- mean_vals[order(mean_vals$Value,
                                   decreasing = (levels == "down")), ]
      var_order <- as.character(mean_vals$Variable)
    } else if (!is.null(levels)) {
      var_order <- levels
    } else {
      var_order <- colnames(data.left)
    }
    long_left$Variable  <- factor(long_left$Variable,  levels = var_order)
    long_right$Variable <- factor(long_right$Variable, levels = var_order)

    nvar <- length(var_order)
    cols <- .resolve_cols(nvar)

    # Per-variable y-axis label colours
    if (is.null(text.colors)) text.colors <- rep("black", nvar)
    if (length(text.colors) < nvar) text.colors <- rep_len(text.colors, nvar)

    # Titles
    if (is.null(left.title))  left.title  <- "Left"
    if (is.null(right.title)) right.title <- "Right"
    if (is.null(xlab)) xlab <- "Score"

    # -- Shared theme for violin mode --
    violin_theme <- theme_my(base_size = base_size, border = FALSE,
                             legend.position = "none") +
      ggplot2::theme(
        axis.ticks.length = unit(2, "mm"),
        plot.title = element_text(hjust = 0.5, size = base_size + 2,
                                   face = "bold")
      )

    # -- Helper: build one side --
    .build_violin <- function(long_df, negate = FALSE, show_y = TRUE,
                              panel_title, title_color) {
      val_expr <- if (negate) aes(y = Variable, x = -Value) else
                              aes(y = Variable, x = Value)

      p <- ggplot(long_df, aes(y = Variable, fill = Variable)) +
        geom_violin(aes(x = if (negate) -Value else Value),
                    trim = FALSE, alpha = alpha)

      if (add_box) {
        p <- p + geom_boxplot(
          aes(x = if (negate) -Value else Value),
          width = box.width, fill = "white", outliers = FALSE
        )
      }
      if (add_point) {
        p <- p + geom_jitter(
          aes(x = if (negate) -Value else Value),
          size = pt.size, width = 0, height = 0.1, alpha = pt.alpha
        )
      }

      if (!is.null(ref.line)) {
        ref_x <- if (negate) -ref.line else ref.line
        p <- p + geom_vline(xintercept = ref_x, linetype = "dashed",
                            color = ref.color, linewidth = 0.8)
      }

      # Axis adjustments
      if (negate) {
        p <- p +
          scale_x_continuous(expand = c(0, 0), position = "top",
                             labels = function(x) format(abs(x), nsmall = 1)) +
          scale_y_discrete(position = "right")
      } else {
        p <- p +
          scale_x_continuous(expand = c(0, 0), position = "top")
      }

      p <- p +
        scale_fill_manual(values = cols) +
        labs(title = panel_title, x = if (!negate) xlab else NULL) +
        violin_theme +
        ggplot2::theme(
          plot.title = element_text(color = title_color),
          axis.text.x = element_text(size = base_size, color = "black")
        )

      if (show_y) {
        p <- p + ggplot2::theme(
          axis.text.y = element_text(size = base_size, hjust = 0.5,
                                      colour = text.colors),
          axis.title.y = element_blank()
        )
      } else {
        p <- p + ggplot2::theme(
          axis.text.y = element_blank(),
          axis.title  = element_blank()
        )
      }
      p
    }

    p_right_v <- .build_violin(long_right, negate = FALSE, show_y = TRUE,
                               panel_title = right.title,
                               title_color = right.title.color)
    p_left_v  <- .build_violin(long_left, negate = TRUE, show_y = FALSE,
                               panel_title = left.title,
                               title_color = left.title.color)

    combined <- p_left_v + p_right_v
    if (!is.null(title)) {
      combined <- combined +
        plot_annotation(title = title,
                        theme = ggplot2::theme(
                          plot.title = element_text(hjust = 0.5,
                                                     size = base_size + 2,
                                                     face = "bold")
                        ))
    }
  }

  # ---- Save or return ----
  if (!is.null(filename)) {
    ggplot2::ggsave(filename, combined,
                    width = width, height = height, dpi = 300, bg = "white")
    cli::cli_alert_success("Plot saved to {.file {filename}}")
  }

  combined
}
