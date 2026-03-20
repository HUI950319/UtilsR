# ============================================================================
# plt_cat.R -- Unified categorical variable plot
# ============================================================================

#' Unified Categorical Variable Plot
#'
#' A single entry point for 11 categorical chart types: bar, rose, ring, pie,
#' trend, area, dot, sankey, chord, venn, and upset.
#'
#' @param data A data frame (or Seurat object metadata).
#' @param stat.by Character. Column name(s) for the categorical variable to
#'   summarise. For standard types (bar, rose, ring, pie, trend, area, dot) a
#'   single column name. For set types (sankey, chord, venn, upset) a character
#'   vector of >= 2 column names.
#' @param group.by Character. Optional grouping variable for standard types.
#'   Ignored for set types.
#' @param split.by Character. Optional splitting variable. Splits data, creates
#'   one plot per level, and combines with \pkg{patchwork}.
#' @param type Chart type. One of \code{"bar"}, \code{"rose"}, \code{"ring"},
#'   \code{"pie"}, \code{"trend"}, \code{"area"}, \code{"dot"}, \code{"sankey"},
#'   \code{"chord"}, \code{"venn"}, \code{"upset"}.
#' @param stat Statistic to compute: \code{"percent"} (default) or
#'   \code{"count"}.
#' @param position Bar position: \code{"stack"} (default) or \code{"dodge"}.
#'   Only used for bar and trend types.
#' @param palette Colour palette. One of:
#'   \itemize{
#'     \item \code{NULL} (default): uses \code{pal_lancet}.
#'     \item A single string matching a name in \code{palette_list}: uses
#'       \code{pal_get()}.
#'     \item A character vector of colours: used directly.
#'   }
#' @param alpha Numeric 0--1. Colour transparency. Default 0.8.
#' @param label Logical. Show value labels? Default \code{FALSE}.
#' @param label.size Numeric. Label text size. Default 3.5.
#' @param flip Logical. Flip coordinates for bar type? Default \code{FALSE}.
#' @param na.rm Logical. Remove NA values before computing? Default \code{TRUE}.
#' @param facet_nrow Integer. Number of rows when combining split panels.
#'   Default \code{NULL} (auto).
#' @param base_size Numeric. Base font size for \code{theme_my()}.
#'   Default 14.
#' @param ... Additional arguments passed to the type-specific plot function.
#'
#' @return A ggplot object (or patchwork for split/set types).
#'
#' @note Set types require additional packages:
#'   \itemize{
#'     \item \code{sankey}: \pkg{ggsankey}
#'     \item \code{chord}: \pkg{circlize}
#'     \item \code{venn}, \code{upset}: \pkg{ggVennDiagram}
#'   }
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   Type = factor(sample(c("A","B","C"), 200, TRUE)),
#'   Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
#'   Batch = factor(sample(c("B1","B2"), 200, TRUE))
#' )
#'
#' # Bar chart (stacked percent)
#' plt_cat(df, "Type", "Group", type = "bar")
#'
#' # Bar chart (dodged count)
#' plt_cat(df, "Type", "Group", type = "bar", stat = "count",
#'         position = "dodge")
#'
#' # Pie chart
#' plt_cat(df, "Type", type = "pie")
#'
#' # Ring (donut) chart
#' plt_cat(df, "Type", type = "ring")
#'
#' # Rose chart
#' plt_cat(df, "Type", "Group", type = "rose")
#'
#' # Dot plot
#' plt_cat(df, "Type", "Group", type = "dot")
#'
#' # Trend line
#' plt_cat(df, "Type", "Group", type = "trend", stat = "count")
#'
#' # Area chart
#' plt_cat(df, "Type", "Group", type = "area")
#'
#' # Flipped bar with labels
#' plt_cat(df, "Type", "Group", type = "bar", flip = TRUE, label = TRUE)
#'
#' # Split by batch
#' plt_cat(df, "Type", "Group", split.by = "Batch", type = "bar")
#'
#' # Custom palette
#' plt_cat(df, "Type", type = "pie", palette = "Paired")
#'
#' # Sankey (set type, >= 2 stat.by)
#' plt_cat(df, c("Type", "Group"), type = "sankey")
#'
#' # Venn diagram
#' df_bin <- data.frame(
#'   A = sample(c("Yes","No"), 100, TRUE),
#'   B = sample(c("Yes","No"), 100, TRUE),
#'   C = sample(c("Yes","No"), 100, TRUE)
#' )
#' plt_cat(df_bin, c("A","B","C"), type = "venn")
#'
#' # UpSet plot
#' plt_cat(df_bin, c("A","B","C"), type = "upset")
#'
#' @export
#' @family plot
plt_cat <- function(data,
                    stat.by,
                    group.by = NULL,
                    split.by = NULL,
                    type = c("bar", "rose", "ring", "pie", "trend",
                             "area", "dot", "sankey", "chord",
                             "venn", "upset"),
                    stat = c("percent", "count"),
                    position = c("stack", "dodge"),
                    palette = NULL,
                    alpha = 0.8,
                    label = FALSE,
                    label.size = 3.5,
                    flip = FALSE,
                    na.rm = TRUE,
                    facet_nrow = NULL,
                    base_size = 14,
                    ...) {

  # --- Input validation -------------------------------------------------------
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.cls {class(data)}}.")
  }

  type     <- match.arg(type)
  stat     <- match.arg(stat)
  position <- match.arg(position)

  if (!is.character(stat.by) || length(stat.by) == 0) {
    cli::cli_abort("{.arg stat.by} must be a non-empty character vector.")
  }

  missing_cols <- stat.by[!stat.by %in% names(data)]
  if (length(missing_cols) > 0) {
    cli::cli_abort("Column{?s} not found in {.arg data}: {.val {missing_cols}}")
  }
  if (!is.null(group.by) && !group.by %in% names(data)) {
    cli::cli_abort("Column {.val {group.by}} not found in {.arg data}.")
  }
  if (!is.null(split.by) && !split.by %in% names(data)) {
    cli::cli_abort("Column {.val {split.by}} not found in {.arg data}.")
  }

  # --- Set types vs standard types --------------------------------------------
  set_types <- c("sankey", "chord", "venn", "upset")
  std_types <- c("bar", "rose", "ring", "pie", "trend", "area", "dot")

  if (type %in% set_types) {
    if (length(stat.by) < 2) {
      cli::cli_abort(
        "Type {.val {type}} requires {.arg stat.by} with >= 2 column names."
      )
    }
    # group.by is ignored for set types
    if (!is.null(group.by)) {
      cli::cli_warn(
        "{.arg group.by} is ignored for set type {.val {type}}."
      )
    }
  } else {
    # Standard types use single stat.by
    if (length(stat.by) > 1) {
      cli::cli_warn(
        "Type {.val {type}} uses only the first element of {.arg stat.by}."
      )
      stat.by <- stat.by[1]
    }
  }

  # --- Remove NAs if requested ------------------------------------------------
  if (na.rm) {
    cols_check <- c(stat.by, group.by, split.by)
    cols_check <- cols_check[!is.null(cols_check)]
    n_before <- nrow(data)
    for (col in cols_check) {
      data <- data[!is.na(data[[col]]), , drop = FALSE]
    }
    n_after <- nrow(data)
    if (n_after < n_before) {
      cli::cli_inform(
        "Removed {n_before - n_after} row{?s} containing NA values."
      )
    }
  }

  # --- Resolve colours --------------------------------------------------------
  if (type %in% std_types) {
    stat_levels <- levels(factor(data[[stat.by[1]]]))
    colors <- .resolve_colors(stat_levels, palette, alpha)
  } else {
    # For set types: resolve colors for all unique levels across stat.by vars
    all_levels <- unique(unlist(lapply(stat.by, function(s) levels(factor(data[[s]])))))
    colors <- .resolve_colors(all_levels, palette, 1)  # alpha handled internally
  }

  # --- Handle split.by --------------------------------------------------------
  if (!is.null(split.by)) {
    split_levels <- levels(factor(data[[split.by]]))
    plot_list <- lapply(split_levels, function(lv) {
      sub_data <- data[data[[split.by]] == lv, , drop = FALSE]
      p <- plt_cat(
        data = sub_data, stat.by = stat.by, group.by = group.by,
        split.by = NULL, type = type, stat = stat, position = position,
        palette = palette, alpha = alpha, label = label,
        label.size = label.size, flip = flip, na.rm = FALSE,
        facet_nrow = NULL, base_size = base_size, ...
      )
      p + ggplot2::ggtitle(lv)
    })
    return(
      patchwork::wrap_plots(plot_list, nrow = facet_nrow) +
        patchwork::plot_layout(guides = "collect")
    )
  }

  # --- Dispatch to type-specific functions ------------------------------------
  if (type %in% set_types) {
    p <- switch(type,
      sankey = .plt_cat_sankey(data = data, stat.by = stat.by, cols = colors, alpha = alpha),
      chord  = .plt_cat_chord(data = data, stat.by = stat.by, cols = colors, alpha = alpha),
      venn   = .plt_cat_venn(data = data, stat.by = stat.by, cols = colors),
      upset  = .plt_cat_upset(data = data, stat.by = stat.by, cols = colors)
    )
    return(p)
  }

  # --- Standard types: prepare data then plot ---------------------------------
  plotdata <- .prepare_cat_data(data, stat.by, group.by, stat, na.rm = FALSE)

  p <- switch(type,
    bar   = .plt_cat_bar(plotdata, cols = colors, alpha = alpha, position = position),
    rose  = .plt_cat_rose(plotdata, cols = colors, alpha = alpha, position = position),
    ring  = .plt_cat_ring(plotdata, cols = colors, alpha = alpha),
    pie   = .plt_cat_pie(plotdata, cols = colors, alpha = alpha),
    trend = .plt_cat_trend(plotdata, cols = colors, alpha = alpha, position = position),
    area  = .plt_cat_area(plotdata, cols = colors, alpha = alpha, position = position),
    dot   = .plt_cat_dot(plotdata, cols = colors, alpha = alpha)
  )

  # --- Labels -----------------------------------------------------------------
  if (label) {
    p <- .add_cat_labels(p, plotdata, stat, type, label.size)
  }

  # --- Flip -------------------------------------------------------------------
  if (flip && type == "bar") {
    p <- p + ggplot2::coord_flip()
  }

  # --- Theme ------------------------------------------------------------------
  p <- p + theme_my(base_size = base_size)

  p
}


# ============================================================================
# Internal helpers
# ============================================================================

#' Prepare frequency table for categorical plots
#'
#' Computes a long-format data frame of counts or percentages from one or two
#' categorical variables using \code{xtabs}.
#'
#' @param data Data frame.
#' @param stat.by Single column name for the statistic variable.
#' @param group.by Optional grouping column name.
#' @param stat Either \code{"percent"} or \code{"count"}.
#' @param na.rm Logical. Remove NAs.
#'
#' @return A data frame with columns: \code{stat_var}, \code{group_var},
#'   \code{value}, \code{label_text}.
#'
#' @noRd
.prepare_cat_data <- function(data, stat.by, group.by, stat, na.rm = TRUE) {
  # Ensure factors
  data[[stat.by]] <- factor(data[[stat.by]])

  if (!is.null(group.by)) {
    data[[group.by]] <- factor(data[[group.by]])
    fml <- stats::as.formula(paste("~", stat.by, "+", group.by))
    tbl <- stats::xtabs(fml, data = data)
    df <- as.data.frame(tbl, stringsAsFactors = FALSE)
    names(df) <- c("stat_var", "group_var", "n")
  } else {
    fml <- stats::as.formula(paste("~", stat.by))
    tbl <- stats::xtabs(fml, data = data)
    df <- as.data.frame(tbl, stringsAsFactors = FALSE)
    names(df) <- c("stat_var", "n")
    df$group_var <- "all"
  }

  # Compute value + label
  if (stat == "percent") {
    # Normalize within each group_var level
    df <- df |>
      dplyr::group_by(.data[["group_var"]]) |>
      dplyr::mutate(
        value = .data[["n"]] / sum(.data[["n"]]) * 100,
        label_text = sprintf("%.1f%%", .data[["value"]])
      ) |>
      dplyr::ungroup()
  } else {
    df$value <- df$n
    df$label_text <- as.character(df$n)
  }

  # Preserve factor levels

  df$stat_var  <- factor(df$stat_var, levels = levels(data[[stat.by]]))
  if (!is.null(group.by)) {
    df$group_var <- factor(df$group_var, levels = levels(data[[group.by]]))
  }

  df
}


#' Resolve colour palette for categorical plots
#'
#' @param stat_levels Character vector of stat.by factor levels.
#' @param palette User-supplied palette argument.
#' @param alpha Numeric transparency.
#'
#' @return Character vector of hex colours (length = n levels).
#'
#' @noRd
.resolve_colors <- function(stat_levels, palette, alpha) {
  n <- length(stat_levels)

  if (is.null(palette)) {
    # Default: pal_lancet
    if (n <= length(pal_lancet)) {
      cols <- as.character(pal_lancet[seq_len(n)])
    } else {
      cols <- as.character(
        grDevices::colorRampPalette(as.character(pal_lancet))(n)
      )
    }
  } else if (length(palette) == 1 && palette %in% names(palette_list)) {
    cols <- as.character(pal_get(palette, n = n))
  } else {
    # Direct colour vector
    cols <- rep_len(as.character(palette), n)
  }

  # Apply alpha
  if (alpha < 1) {
    cols <- ggplot2::alpha(cols, alpha)
  }

  as.character(cols)
}


#' Add value labels to categorical plots
#'
#' @param p A ggplot object.
#' @param plotdata Data frame from \code{.prepare_cat_data()}.
#' @param stat \code{"percent"} or \code{"count"}.
#' @param type Chart type string.
#' @param label.size Numeric text size.
#'
#' @return Modified ggplot with labels.
#'
#' @noRd
.add_cat_labels <- function(p, plotdata, stat, type, label.size) {
  has_group <- !all(plotdata$group_var == "all")

  if (type == "dot") {
    # For dot: position by x = group_var, y = value
    p <- p + ggplot2::geom_text(
      data = plotdata,
      ggplot2::aes(
        x = .data[["group_var"]],
        y = .data[["value"]],
        label = .data[["label_text"]]
      ),
      size = label.size,
      vjust = -0.8,
      show.legend = FALSE
    )
  } else if (type %in% c("pie", "ring")) {
    # For polar types: use position_stack with vjust
    p <- p + ggplot2::geom_text(
      data = plotdata,
      ggplot2::aes(
        x = if (has_group) .data[["group_var"]] else "",
        y = .data[["value"]],
        label = .data[["label_text"]]
      ),
      position = ggplot2::position_stack(vjust = 0.5),
      size = label.size,
      show.legend = FALSE
    )
  } else if (type %in% c("bar", "trend")) {
    # Stacked/dodged bar: use position matching the plot
    p <- p + ggplot2::geom_text(
      data = plotdata,
      ggplot2::aes(
        x = if (has_group) .data[["group_var"]] else .data[["stat_var"]],
        y = .data[["value"]],
        label = .data[["label_text"]],
        group = .data[["stat_var"]]
      ),
      position = ggplot2::position_stack(vjust = 0.5),
      size = label.size,
      show.legend = FALSE
    )
  } else {
    # rose, area: generic
    p <- p + ggplot2::geom_text(
      data = plotdata,
      ggplot2::aes(
        x = if (has_group) .data[["group_var"]] else .data[["stat_var"]],
        y = .data[["value"]],
        label = .data[["label_text"]]
      ),
      position = ggplot2::position_stack(vjust = 0.5),
      size = label.size,
      show.legend = FALSE
    )
  }

  p
}
