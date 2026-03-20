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
#' @param label.fg Character. Label foreground colour. Default \code{"black"}.
#' @param label.bg Character. Label background colour. Default \code{"white"}.
#' @param label.bg.r Numeric. Label background corner radius. Default 0.1.
#' @param bg.by Character. Column name for background grouping in dodge mode.
#'   Must be a superset of \code{group.by} (each group.by level belongs to
#'   exactly one bg.by level). Adds alternating background colour bands.
#'   Default \code{NULL} (no background).
#' @param bg_palette Character vector of background band colours.
#'   Default \code{NULL} uses alternating \code{c("grey85", "transparent")}.
#' @param bg_alpha Numeric 0--1. Background band transparency. Default 0.15.
#' @param flip Logical. Flip coordinates for bar type? Default \code{FALSE}.
#' @param NA_color Character. Colour for NA values. Default \code{"grey80"}.
#' @param NA_stat Logical. Include NA in the frequency table? Default
#'   \code{FALSE} (NAs are dropped). If \code{TRUE}, NAs are kept and shown
#'   with \code{NA_color}.
#' @param keep_empty Logical. Keep empty factor levels in plots?
#'   Default \code{FALSE}.
#' @param stat_level Character or list. For venn/upset types, the value(s) in
#'   each \code{stat.by} column that count as "positive". Default \code{NULL}
#'   auto-detects \code{TRUE}, \code{"Yes"}, \code{"yes"}, \code{1},
#'   \code{"TRUE"}, \code{"1"}, or uses the first factor level.
#' @param title Character. Plot title. Default \code{NULL}.
#' @param subtitle Character. Plot subtitle. Default \code{NULL}.
#' @param xlab Character. X-axis label. Default \code{NULL}.
#' @param ylab Character. Y-axis label. Default \code{NULL} (auto-set based on
#'   \code{stat}).
#' @param legend.position Legend position: \code{"right"} (default),
#'   \code{"left"}, \code{"bottom"}, \code{"top"}, or \code{"none"}.
#' @param legend.direction Legend direction: \code{"vertical"} (default) or
#'   \code{"horizontal"}.
#' @param aspect.ratio Numeric. Panel aspect ratio. Default \code{NULL} (auto).
#'   Automatically set to 1 for rose, ring, and pie types.
#' @param facet_nrow Integer. Number of rows when combining split panels.
#'   Default \code{NULL} (auto).
#' @param facet_ncol Integer. Number of columns when combining split panels.
#'   Default \code{NULL} (auto).
#' @param facet_byrow Logical. Fill split panels by row? Default \code{TRUE}.
#' @param base_size Numeric. Base font size for \code{theme_my()}.
#'   Default 14.
#' @param force Logical. Force plotting when variables have > 100 levels?
#'   Default \code{FALSE}.
#' @param ... Additional arguments passed to the type-specific plot function.
#'
#' @return A ggplot object (or patchwork for split/set types).
#'
#' @note Set types require additional packages:
#'   \itemize{
#'     \item \code{sankey}: \pkg{ggsankey}
#'     \item \code{chord}: \pkg{circlize}
#'     \item \code{venn}: \pkg{ggVennDiagram}
#'     \item \code{upset}: \pkg{ggupset}
#'   }
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   Type  = factor(sample(c("A","B","C"), 200, TRUE)),
#'   Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
#'   Batch = factor(sample(c("B1","B2"), 200, TRUE))
#' )
#' df$Region <- factor(ifelse(df$Group %in% c("X","Y"), "R1", "R2"))
#'
#' # ===== 1. Bar =====
#' plt_cat(df, "Type", "Group", type = "bar")                      # stacked %
#' plt_cat(df, "Type", "Group", type = "bar", stat = "count",
#'         position = "dodge")                                      # dodged count
#' plt_cat(df, "Type", "Group", type = "bar", flip = TRUE,
#'         label = TRUE)                                            # flipped + labels
#' plt_cat(df, "Type", "Group", type = "bar", position = "dodge",
#'         bg.by = "Region")                                        # background bands
#' plt_cat(df, "Type", "Group", type = "bar", position = "dodge",
#'         bg.by = "Region",
#'         bg_palette = c("lightblue", "lightyellow"))              # custom bg colors
#' plt_cat(df, "Type", type = "bar", stat = "count",
#'         label = TRUE, legend.position = "none")                  # no group
#'
#' # ===== 2. Rose =====
#' plt_cat(df, "Type", "Group", type = "rose")
#' plt_cat(df, "Type", "Group", type = "rose", stat = "count",
#'         position = "dodge")
#'
#' # ===== 3. Ring (donut) =====
#' plt_cat(df, "Type", type = "ring")
#' plt_cat(df, "Type", type = "ring", label = TRUE,
#'         palette = "Paired")
#' plt_cat(df, "Type", "Group", type = "ring", stat = "count",
#'         position = "dodge")
#'
#' # ===== 4. Pie =====
#' plt_cat(df, "Type", type = "pie", label = TRUE)
#' plt_cat(df, "Type", type = "pie", palette = "Paired",
#'         title = "Type Distribution", subtitle = "n = 200")
#' plt_cat(df, "Type", type = "pie", legend.position = "bottom",
#'         legend.direction = "horizontal")
#'
#' # ===== 5. Trend =====
#' plt_cat(df, "Type", "Group", type = "trend", stat = "count")
#' plt_cat(df, "Type", "Group", type = "trend", stat = "count",
#'         label = TRUE)
#'
#' # ===== 6. Area =====
#' plt_cat(df, "Type", "Group", type = "area", stat = "count")
#' plt_cat(df, "Type", "Group", type = "area", stat = "count",
#'         position = "dodge")
#'
#' # ===== 7. Dot =====
#' plt_cat(df, "Type", "Group", type = "dot")
#' plt_cat(df, "Type", "Group", type = "dot", label = TRUE,
#'         stat = "count")
#'
#' # ===== split.by / NA / keep_empty / aspect =====
#' plt_cat(df, "Type", "Group", split.by = "Batch", type = "bar")
#' plt_cat(df, "Type", split.by = "Batch", type = "pie",
#'         facet_ncol = 2)
#'
#' # NA handling
#' df_na <- df; df_na$Type[1:20] <- NA
#' plt_cat(df_na, "Type", "Group", type = "bar",
#'         NA_stat = TRUE, NA_color = "red")
#'
#' # keep_empty: preserve dropped levels
#' df2 <- df[df$Type != "C", ]
#' plt_cat(df2, "Type", "Group", type = "bar", keep_empty = TRUE)
#'
#' # aspect.ratio
#' plt_cat(df, "Type", "Group", type = "bar", aspect.ratio = 0.5)
#'
#' # ===== 8. Sankey =====
#' plt_cat(df, c("Type", "Group"), type = "sankey")
#' plt_cat(df, c("Type", "Group", "Batch"), type = "sankey")
#'
#' # ===== 9. Chord =====
#' plt_cat(df, c("Type", "Group"), type = "chord")
#'
#' # ===== 10. Venn =====
#' set.seed(42)
#' df_bin <- data.frame(
#'   A = sample(c("Yes","No"), 100, TRUE),
#'   B = sample(c("Yes","No"), 100, TRUE),
#'   C = sample(c("Yes","No"), 100, TRUE)
#' )
#' plt_cat(df_bin, c("A","B","C"), type = "venn")
#' plt_cat(df, c("Type","Group"), type = "venn", stat_level = c("A","X"))
#'
#' # ===== 11. UpSet =====
#' plt_cat(df_bin, c("A","B","C"), type = "upset")
#' plt_cat(df, c("Type","Group"), type = "upset", stat_level = c("A","X"))
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
                    label.fg = "black",
                    label.bg = "white",
                    label.bg.r = 0.1,
                    bg.by = NULL,
                    bg_palette = NULL,
                    bg_alpha = 0.15,
                    flip = FALSE,
                    NA_color = "grey80",
                    NA_stat = FALSE,
                    keep_empty = FALSE,
                    stat_level = NULL,
                    title = NULL,
                    subtitle = NULL,
                    xlab = NULL,
                    ylab = NULL,
                    legend.position = "right",
                    legend.direction = "vertical",
                    aspect.ratio = NULL,
                    facet_nrow = NULL,
                    facet_ncol = NULL,
                    facet_byrow = TRUE,
                    base_size = 14,
                    force = FALSE,
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
  if (!is.null(bg.by)) {
    if (!bg.by %in% names(data)) {
      cli::cli_abort("Column {.val {bg.by}} not found in {.arg data}.")
    }
    if (is.null(group.by)) {
      cli::cli_warn("{.arg bg.by} requires {.arg group.by}. Ignored.")
      bg.by <- NULL
    }
  }

  # --- Safety check for high-cardinality columns ------------------------------
  if (!force) {
    all_cols <- unique(c(stat.by, group.by, split.by))
    high_card <- vapply(all_cols, function(col) {
      length(unique(data[[col]]))
    }, integer(1))
    high_card <- high_card[high_card > 100]
    if (length(high_card) > 0) {
      cli::cli_abort(c(
        "Column{?s} with > 100 levels: {.val {names(high_card)}}.",
        "i" = "Set {.arg force = TRUE} to override."
      ))
    }
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
    if (!is.null(group.by)) {
      cli::cli_warn(
        "{.arg group.by} is ignored for set type {.val {type}}."
      )
    }
  } else {
    if (length(stat.by) > 1) {
      cli::cli_warn(
        "Type {.val {type}} uses only the first element of {.arg stat.by}."
      )
      stat.by <- stat.by[1]
    }
  }

  # --- Ensure factors ---------------------------------------------------------
  for (col in unique(c(stat.by, group.by, split.by, bg.by))) {
    if (!is.null(col) && col %in% names(data) && !is.factor(data[[col]])) {
      data[[col]] <- factor(data[[col]], levels = unique(data[[col]]))
    }
  }

  # --- NA handling ------------------------------------------------------------
  if (!NA_stat) {
    cols_check <- unique(c(stat.by, group.by, split.by))
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
  } else {
    for (col in unique(c(stat.by, group.by))) {
      if (any(is.na(data[[col]]))) {
        lvls <- levels(data[[col]])
        data[[col]] <- as.character(data[[col]])
        data[[col]][is.na(data[[col]])] <- "NA"
        data[[col]] <- factor(data[[col]], levels = c(lvls, "NA"))
      }
    }
  }

  # --- Resolve colours (NO alpha baked in -- alpha applied only in geoms) -----
  if (type %in% std_types) {
    stat_levels <- levels(factor(data[[stat.by[1]]]))
    colors <- .resolve_colors(stat_levels, palette)
    if (NA_stat && "NA" %in% stat_levels) {
      colors["NA"] <- NA_color
    }
  } else {
    all_levels <- unique(unlist(lapply(stat.by, function(s) levels(factor(data[[s]])))))
    colors <- .resolve_colors(all_levels, palette)
  }

  # --- Auto aspect.ratio for polar types --------------------------------------
  if (is.null(aspect.ratio) && type %in% c("rose", "ring", "pie")) {
    aspect.ratio <- 1
  }

  # --- Handle split.by --------------------------------------------------------
  if (!is.null(split.by)) {
    split_levels <- levels(factor(data[[split.by]]))
    plot_list <- lapply(split_levels, function(lv) {
      sub_data <- data[data[[split.by]] == lv, , drop = FALSE]
      plt_cat(
        data = sub_data, stat.by = stat.by, group.by = group.by,
        split.by = NULL, type = type, stat = stat, position = position,
        palette = palette, alpha = alpha, label = label,
        label.size = label.size, label.fg = label.fg, label.bg = label.bg,
        label.bg.r = label.bg.r, bg.by = bg.by, bg_palette = bg_palette,
        bg_alpha = bg_alpha, flip = flip,
        NA_color = NA_color, NA_stat = FALSE, keep_empty = keep_empty,
        stat_level = stat_level, title = lv, subtitle = subtitle,
        xlab = xlab, ylab = ylab, legend.position = legend.position,
        legend.direction = legend.direction, aspect.ratio = aspect.ratio,
        facet_nrow = NULL, facet_ncol = NULL, base_size = base_size,
        force = TRUE, ...
      )
    })
    return(
      patchwork::wrap_plots(plot_list, nrow = facet_nrow, ncol = facet_ncol,
                            byrow = facet_byrow) +
        patchwork::plot_layout(guides = "collect")
    )
  }

  # --- Dispatch to type-specific functions ------------------------------------
  if (type %in% set_types) {
    p <- switch(type,
      sankey = .plt_cat_sankey(data = data, stat.by = stat.by, cols = colors,
                               alpha = alpha),
      chord  = .plt_cat_chord(data = data, stat.by = stat.by, cols = colors,
                               alpha = alpha),
      venn   = .plt_cat_venn(data = data, stat.by = stat.by, cols = colors,
                              stat_level = stat_level),
      upset  = .plt_cat_upset(data = data, stat.by = stat.by, cols = colors,
                               stat_level = stat_level,
                               label.fg = label.fg, label.size = label.size,
                               label.bg = label.bg, label.bg.r = label.bg.r)
    )
    if (inherits(p, "gg")) {
      if (!is.null(title) || !is.null(subtitle)) {
        p <- p + ggplot2::labs(title = title, subtitle = subtitle)
      }
    }
    return(p)
  }

  # --- Standard types: prepare data then plot ---------------------------------
  plotdata <- .prepare_cat_data(data, stat.by, group.by, stat,
                                NA_stat = NA_stat, keep_empty = keep_empty)

  p <- switch(type,
    bar   = .plt_cat_bar(plotdata, cols = colors, alpha = alpha,
                          position = position, keep_empty = keep_empty),
    rose  = .plt_cat_rose(plotdata, cols = colors, alpha = alpha,
                           position = position, keep_empty = keep_empty),
    ring  = .plt_cat_ring(plotdata, cols = colors, alpha = alpha,
                          position = position, keep_empty = keep_empty),
    pie   = .plt_cat_pie(plotdata, cols = colors, alpha = alpha),
    trend = .plt_cat_trend(plotdata, cols = colors, alpha = alpha,
                            position = position, keep_empty = keep_empty),
    area  = .plt_cat_area(plotdata, cols = colors, alpha = alpha,
                           position = position, keep_empty = keep_empty),
    dot   = .plt_cat_dot(plotdata, cols = colors, alpha = alpha,
                          keep_empty = keep_empty)
  )

  # --- Background bands (bg.by) -----------------------------------------------
  if (!is.null(bg.by) && !is.null(group.by) &&
      type %in% c("bar", "trend", "dot") && position == "dodge") {
    bg_layer <- .build_bg_layer(data, group.by, bg.by, bg_alpha, bg_palette)
    if (!is.null(bg_layer)) {
      p$layers <- c(list(bg_layer), p$layers)
    }
  }

  # --- Y-axis formatting ------------------------------------------------------
  if (!type %in% c("dot", "pie", "ring", "rose")) {
    if (stat == "percent") {
      p <- p + ggplot2::scale_y_continuous(
        labels = function(x) paste0(round(x, 1), "%"),
        expand = ggplot2::expansion(mult = c(0, 0.05))
      )
    } else {
      p <- p + ggplot2::scale_y_continuous(
        labels = scales::label_number(),
        expand = ggplot2::expansion(mult = c(0, 0.05))
      )
    }
  }

  # --- Labels -----------------------------------------------------------------
  if (label) {
    p <- .add_cat_labels(p, plotdata, stat, type, position, label.size,
                         label.fg, label.bg, label.bg.r)
  }

  # --- Flip -------------------------------------------------------------------
  if (flip && type == "bar") {
    p <- p + ggplot2::coord_flip()
  }

  # --- Theme ------------------------------------------------------------------
  p <- p + theme_my(base_size = base_size)

  # --- Labs -------------------------------------------------------------------
  auto_ylab <- if (stat == "percent") "Percentage" else "Count"
  p <- p + ggplot2::labs(
    title = title,
    subtitle = subtitle,
    x = xlab,
    y = ylab %||% auto_ylab
  )

  # --- Legend & aspect --------------------------------------------------------
  p <- p + ggplot2::theme(
    legend.position = legend.position,
    legend.direction = legend.direction,
    aspect.ratio = aspect.ratio
  )

  p
}


# ============================================================================
# Internal helpers
# ============================================================================

#' Prepare frequency table for categorical plots
#' @noRd
.prepare_cat_data <- function(data, stat.by, group.by, stat,
                              NA_stat = FALSE, keep_empty = FALSE) {
  data[[stat.by]] <- factor(data[[stat.by]])

  if (!is.null(group.by)) {
    data[[group.by]] <- factor(data[[group.by]])
    fml <- stats::as.formula(paste("~", stat.by, "+", group.by))
    tbl <- stats::xtabs(fml, data = data, addNA = NA_stat)
    df <- as.data.frame(tbl, stringsAsFactors = FALSE)
    names(df) <- c("stat_var", "group_var", "n")
  } else {
    fml <- stats::as.formula(paste("~", stat.by))
    tbl <- stats::xtabs(fml, data = data, addNA = NA_stat)
    df <- as.data.frame(tbl, stringsAsFactors = FALSE)
    names(df) <- c("stat_var", "n")
    df$group_var <- "all"
  }

  if (stat == "percent") {
    df <- df |>
      dplyr::group_by(.data[["group_var"]]) |>
      dplyr::mutate(
        total = sum(.data[["n"]]),
        value = dplyr::if_else(.data[["total"]] > 0,
                               .data[["n"]] / .data[["total"]] * 100, 0),
        label_text = sprintf("%.1f%%", .data[["value"]])
      ) |>
      dplyr::select(-"total") |>
      dplyr::ungroup()
  } else {
    df$value <- df$n
    df$label_text <- as.character(df$n)
  }

  df$stat_var <- factor(df$stat_var, levels = levels(data[[stat.by]]))
  if (!is.null(group.by)) {
    df$group_var <- factor(df$group_var, levels = levels(data[[group.by]]))
  }

  # Drop empty factor combinations
  if (!keep_empty) {
    df <- df[df$n > 0, , drop = FALSE]
  }

  df
}


#' Resolve colour palette (returns named vector, NO alpha applied)
#' @noRd
.resolve_colors <- function(stat_levels, palette) {
  n <- length(stat_levels)

  if (is.null(palette)) {
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
    cols <- rep_len(as.character(palette), n)
  }

  stats::setNames(as.character(cols), stat_levels)
}


#' Resolve stat_level for venn/upset
#' @noRd
.resolve_stat_level <- function(data, stat.by, stat_level) {
  default_positive <- c(TRUE, "TRUE", "Yes", "yes", 1, "1")

  if (is.null(stat_level)) {
    result <- stats::setNames(lapply(stat.by, function(s) {
      vals <- unique(data[[s]])
      hits <- vals[vals %in% default_positive]
      if (length(hits) > 0) {
        as.character(hits)
      } else {
        lv <- if (is.factor(data[[s]])) levels(data[[s]])[1] else sort(unique(data[[s]]))[1]
        cli::cli_inform(
          "Column {.val {s}}: using {.val {lv}} as positive level."
        )
        as.character(lv)
      }
    }), stat.by)
  } else if (is.character(stat_level) || is.numeric(stat_level) || is.logical(stat_level)) {
    stat_level <- rep_len(as.character(stat_level), length(stat.by))
    result <- stats::setNames(as.list(stat_level), stat.by)
  } else if (is.list(stat_level)) {
    if (is.null(names(stat_level))) names(stat_level) <- stat.by
    result <- lapply(stat_level, as.character)
  } else {
    cli::cli_abort("{.arg stat_level} must be NULL, a character vector, or a named list.")
  }

  result
}


#' Build set list for venn/upset from data + stat_level
#' @noRd
.build_set_list <- function(data, stat.by, stat_level) {
  resolved <- .resolve_stat_level(data, stat.by, stat_level)
  stats::setNames(lapply(stat.by, function(s) {
    vals <- data[[s]]
    keep <- !is.na(vals) & (as.character(vals) %in% resolved[[s]])
    which(keep)
  }), stat.by)
}


#' Build background colour bands for dodge-mode plots
#' @noRd
.build_bg_layer <- function(data, group.by, bg.by, bg_alpha,
                            bg_palette = NULL) {
  data[[group.by]] <- factor(data[[group.by]])
  data[[bg.by]]    <- factor(data[[bg.by]])

  bg_map <- tapply(data[[bg.by]], data[[group.by]], function(x) {
    ux <- unique(as.character(x))
    if (length(ux) != 1) return(NA_character_)
    ux
  })
  bg_map <- stats::setNames(as.character(bg_map), names(bg_map))

  if (any(is.na(bg_map))) {
    cli::cli_warn(
      "{.arg bg.by} is not a strict superset of {.arg group.by}. Background disabled."
    )
    return(NULL)
  }

  group_levels <- levels(data[[group.by]])
  bg_levels <- unique(bg_map[group_levels])

  if (is.null(bg_palette)) {
    bg_cols <- stats::setNames(
      rep(c("grey85", "transparent"), length.out = length(bg_levels)),
      bg_levels
    )
  } else {
    bg_cols <- stats::setNames(
      rep_len(as.character(bg_palette), length(bg_levels)),
      bg_levels
    )
  }

  bg_data <- data.frame(
    group = group_levels,
    x = seq_along(group_levels),
    bg = bg_map[group_levels],
    stringsAsFactors = FALSE
  )
  bg_data[["xmin"]] <- bg_data[["x"]] - 0.5
  bg_data[["xmax"]] <- bg_data[["x"]] + 0.5
  bg_data[["xmin"]][1] <- -Inf
  bg_data[["xmax"]][nrow(bg_data)] <- Inf
  bg_data[["fill"]] <- bg_cols[bg_data[["bg"]]]

  ggplot2::geom_rect(
    data = bg_data,
    ggplot2::aes(
      xmin = .data[["xmin"]], xmax = .data[["xmax"]],
      ymin = -Inf, ymax = Inf
    ),
    fill = bg_data[["fill"]],
    alpha = bg_alpha,
    inherit.aes = FALSE
  )
}


#' Add value labels to categorical plots (using ggrepel)
#' @noRd
.add_cat_labels <- function(p, plotdata, stat, type, position = "stack",
                            label.size = 3.5,
                            label.fg = "black", label.bg = "white",
                            label.bg.r = 0.1) {
  has_group <- !is.character(plotdata[["group_var"]])
  x_var <- if (has_group) "group_var" else "stat_var"

  # Match position to what the plot uses
  if (position == "dodge" && type %in% c("bar", "trend")) {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  } else {
    pos <- ggplot2::position_stack(vjust = 0.5)
  }

  # For trend/area: x-axis is continuous (x_num), not discrete
  if (type %in% c("trend", "area")) {
    plotdata[["x_num"]] <- as.numeric(factor(plotdata[[x_var]],
                                             levels = levels(factor(plotdata[[x_var]]))))
    x_aes <- "x_num"
  } else {
    x_aes <- x_var
  }

  if (type == "dot") {
    p <- p + ggrepel::geom_text_repel(
      data = plotdata,
      ggplot2::aes(
        x = .data[[x_aes]],
        y = .data[["stat_var"]],
        label = .data[["label_text"]]
      ),
      size = label.size, colour = label.fg,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      nudge_y = 0.15, direction = "x",
      show.legend = FALSE
    )
  } else if (type %in% c("pie", "ring")) {
    p <- p + ggrepel::geom_text_repel(
      data = plotdata,
      ggplot2::aes(
        x = if (has_group) .data[["group_var"]] else "",
        y = .data[["value"]],
        label = .data[["label_text"]]
      ),
      position = ggplot2::position_stack(vjust = 0.5),
      size = label.size, colour = label.fg,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      force = 0, min.segment.length = 0,
      show.legend = FALSE
    )
  } else {
    # bar, trend, area, rose
    p <- p + ggrepel::geom_text_repel(
      data = plotdata,
      ggplot2::aes(
        x = .data[[x_aes]],
        y = .data[["value"]],
        label = .data[["label_text"]],
        group = .data[["stat_var"]]
      ),
      position = pos,
      size = label.size, colour = label.fg,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      force = 0, min.segment.length = 0,
      show.legend = FALSE
    )
  }

  p
}
