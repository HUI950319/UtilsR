#' Plot a Faceted Alluvial Distribution
#'
#' Draw an alluvial plot for the distribution of `group` across the categories
#' of `cat_var`. Transparent strata create visible gaps between groups, and an
#' optional facet is normalized independently.
#'
#' @param data A data frame.
#' @param cat_var A single column name defining the horizontal categories.
#' @param group A single column name defining strata, flows, and fill colours.
#' @param facet An optional single column name used with
#'   [ggplot2::facet_wrap()].
#' @param y_type Display within-category percentages or raw counts.
#' @param color A registered UtilsR palette name, a single colour, or a colour
#'   vector. See the internal `.resolve_color()` resolver.
#' @param flow_args A named list controlling the alluvial flows:
#'   \describe{
#'     \item{\code{alpha}}{Numeric scalar in \eqn{[0, 1]}. Opacity of the flow
#'       ribbons; `0` is fully transparent and `1` is fully opaque. Default
#'       `0.4`.}
#'     \item{\code{curve_type}}{Character scalar selecting the ribbon curve.
#'       Supported values are `"linear"`, `"cubic"`, `"quintic"`, `"sine"`,
#'       `"arctangent"`, `"sigmoid"`, and `"xspline"`. Default `"linear"`.}
#'   }
#' @param stratum_args A named list controlling stratum bars and gaps:
#'   \describe{
#'     \item{\code{width}}{Numeric scalar in \eqn{(0, 1]}. Horizontal width of
#'       stratum bars and their flow endpoints relative to adjacent x-axis
#'       positions. Default `0.5`.}
#'     \item{\code{color}}{Character scalar giving the stratum border colour.
#'       Default `"gray50"`.}
#'     \item{\code{linewidth}}{Non-negative numeric scalar giving the stratum
#'       border line width. Default `0.3`.}
#'     \item{\code{gap}}{Non-negative numeric scalar controlling the transparent
#'       space inserted between adjacent groups. In percent mode it is the
#'       fraction of total panel height used by each gap; the total gap must be
#'       less than `1`. In count mode it is multiplied by the largest category
#'       total in each facet. Default `0.01`.}
#'   }
#' @param label_args A named list controlling labels:
#'   \describe{
#'     \item{\code{style}}{Character scalar selecting label content:
#'       `"count_percent"` gives `name (count, percent)`, `"count"` gives
#'       `name (count)`, `"percent"` gives `name percent`, `"name"` gives the
#'       group name, and `"none"` hides labels. Default `"count_percent"`.}
#'     \item{\code{min_pct}}{Numeric scalar in \eqn{[0, 1]}. Labels are shown
#'       only for groups at or above this within-`facet` by `cat_var`
#'       proportion. Default `0`.}
#'     \item{\code{size}}{Positive numeric scalar giving the ggplot2 text size.
#'       Default `3`.}
#'     \item{\code{color}}{Character scalar giving the label text colour.
#'       Default `"black"`.}
#'     \item{\code{box}}{Logical scalar. `TRUE` uses boxed labels and `FALSE`
#'       uses plain text. Default `TRUE`.}
#'     \item{\code{fill}}{Character scalar giving the boxed-label background
#'       colour; used only when `box = TRUE`. Default `"white"`.}
#'     \item{\code{alpha}}{Numeric scalar in \eqn{[0, 1]} controlling label
#'       opacity. Default `1`.}
#'   }
#' @param facet_args A named list controlling [ggplot2::facet_wrap()]:
#'   \describe{
#'     \item{\code{nrow}}{`NULL` or a positive integer giving the number of
#'       facet rows. Default `NULL`.}
#'     \item{\code{ncol}}{`NULL` or a positive integer giving the number of
#'       facet columns. Default `NULL`.}
#'     \item{\code{scales}}{Character scalar controlling scale sharing:
#'       `"fixed"`, `"free"`, `"free_x"`, or `"free_y"`. Default `"fixed"`.}
#'   }
#' @param legend_args A named list controlling the fill legend:
#'   \describe{
#'     \item{\code{ncol}}{Positive integer giving the number of legend columns.
#'       Default `1`.}
#'     \item{\code{position}}{Character scalar giving the legend position:
#'       `"right"`, `"left"`, `"top"`, `"bottom"`, or `"none"`. Default
#'       `"right"`.}
#'   }
#' @param theme_use A ggplot2 theme specification resolved internally by
#'   `.resolve_theme()`.
#' @param save `NULL`, an empty list, or a named list forwarded to
#'   `RegR::save_plt()`. Allowed fields are `filename`, `width`, and `height`.
#'
#' @details With `y_type = "percent"`, real strata are normalized within each
#' `facet` by `cat_var` combination before the requested gap space is inserted.
#' With `y_type = "count"`, gaps are scaled by the largest category total in
#' each facet. Rows with missing values in required columns are removed with an
#' informational message.
#'
#' @return A ggplot object. A non-empty `save` also writes the same plot to PDF.
#'
#' @examples
#' if (requireNamespace("ggalluvial", quietly = TRUE)) {
#'   set.seed(1)
#'   alluvial_example <- data.frame(
#'     stage = sample(c("I", "II", "III"), 120, TRUE),
#'     response = sample(c("CR", "PR", "SD"), 120, TRUE),
#'     cohort = sample(c("Training", "Validation"), 120, TRUE)
#'   )
#'
#'   plt_alluvial(alluvial_example, "stage", "response")
#'   plt_alluvial(
#'     alluvial_example,
#'     "stage",
#'     "response",
#'     facet = "cohort",
#'     label_args = list(style = "percent", min_pct = 0.05)
#'   )
#'
#'   p4 <- plt_alluvial(
#'     alluvial_example,
#'     "stage",
#'     "response",
#'     facet = "cohort",
#'     color = c("#2E86AB", "#F6AE2D", "#D1495B"),
#'     flow_args = list(alpha = 0.55, curve_type = "sigmoid"),
#'     stratum_args = list(width = 0.42, gap = 0.015),
#'     legend_args = list(position = "bottom", ncol = 3)
#'   )
#'   print(p4)
#' }
#'
#' @md
#' @export
plt_alluvial <- function(
  data,
  cat_var,
  group,
  facet = NULL,
  y_type = c("percent", "count"),
  color = pal_lancet,
  flow_args = list(alpha = 0.4, curve_type = "linear"),
  stratum_args = list(
    width = 0.5,
    color = "gray50",
    linewidth = 0.3,
    gap = 0.01
  ),
  label_args = list(
    style = "count_percent",
    min_pct = 0,
    size = 3,
    color = "black",
    box = TRUE,
    fill = "white",
    alpha = 1
  ),
  facet_args = list(nrow = NULL, ncol = NULL, scales = "fixed"),
  legend_args = list(ncol = 1, position = "right"),
  theme_use = theme_alluvia(15),
  save = list()
) {
  if (!requireNamespace("ggalluvial", quietly = TRUE)) {
    cli::cli_abort(
      "Package {.pkg ggalluvial} is required for {.fn plt_alluvial}."
    )
  }
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }

  check_column <- function(value, arg) {
    if (
      !is.character(value) ||
        length(value) != 1L ||
        is.na(value) ||
        !nzchar(value)
    ) {
      cli::cli_abort("{.arg {arg}} must be one non-empty column name.")
    }
    if (!value %in% names(data)) {
      cli::cli_abort(
        "Column {.val {value}} supplied to {.arg {arg}} was not found."
      )
    }
  }

  check_column(cat_var, "cat_var")
  check_column(group, "group")
  if (!is.null(facet)) {
    check_column(facet, "facet")
  }
  required <- c(cat_var, group, facet)
  if (anyDuplicated(required)) {
    cli::cli_abort(
      "{.arg cat_var}, {.arg group}, and {.arg facet} must name different columns."
    )
  }

  merge_args <- function(value, defaults, arg) {
    if (!is.list(value)) {
      cli::cli_abort("{.arg {arg}} must be a named list.")
    }
    if (length(value) == 0L) {
      return(defaults)
    }
    value_names <- names(value)
    if (
      is.null(value_names) ||
        any(is.na(value_names)) ||
        any(!nzchar(value_names))
    ) {
      cli::cli_abort(
        "Every element of {.arg {arg}} must have a non-empty name."
      )
    }
    if (anyDuplicated(value_names)) {
      cli::cli_abort("{.arg {arg}} must not contain duplicate names.")
    }
    unknown <- setdiff(value_names, names(defaults))
    if (length(unknown) > 0L) {
      cli::cli_abort("{.arg {arg}} has unknown field{?s}: {.val {unknown}}.")
    }
    utils::modifyList(defaults, value, keep.null = TRUE)
  }

  flow_args <- merge_args(
    flow_args,
    list(alpha = 0.4, curve_type = "linear"),
    "flow_args"
  )
  stratum_args <- merge_args(
    stratum_args,
    list(width = 0.5, color = "gray50", linewidth = 0.3, gap = 0.01),
    "stratum_args"
  )
  label_args <- merge_args(
    label_args,
    list(
      style = "count_percent",
      min_pct = 0,
      size = 3,
      color = "black",
      box = TRUE,
      fill = "white",
      alpha = 1
    ),
    "label_args"
  )
  facet_args <- merge_args(
    facet_args,
    list(nrow = NULL, ncol = NULL, scales = "fixed"),
    "facet_args"
  )
  legend_args <- merge_args(
    legend_args,
    list(ncol = 1, position = "right"),
    "legend_args"
  )

  is_number <- function(value, lower = -Inf, upper = Inf, lower_open = FALSE) {
    if (
      !is.numeric(value) ||
        length(value) != 1L ||
        is.na(value) ||
        !is.finite(value)
    ) {
      return(FALSE)
    }
    lower_ok <- if (lower_open) value > lower else value >= lower
    lower_ok && value <= upper
  }
  is_integer <- function(value) {
    is_number(value, lower = 1) && value == as.integer(value)
  }

  if (!is_number(flow_args$alpha, lower = 0, upper = 1)) {
    cli::cli_abort("{.arg flow_args$alpha} must be between 0 and 1.")
  }
  curve_types <- c(
    "linear",
    "cubic",
    "quintic",
    "sine",
    "arctangent",
    "sigmoid",
    "xspline"
  )
  if (
    !is.character(flow_args$curve_type) ||
      length(flow_args$curve_type) != 1L ||
      !flow_args$curve_type %in% curve_types
  ) {
    cli::cli_abort(
      "{.arg flow_args$curve_type} must be one of {.val {curve_types}}."
    )
  }
  if (!is_number(stratum_args$width, lower = 0, upper = 1, lower_open = TRUE)) {
    cli::cli_abort(
      "{.arg stratum_args$width} must be greater than 0 and at most 1."
    )
  }
  if (
    !is.character(stratum_args$color) ||
      length(stratum_args$color) != 1L ||
      is.na(stratum_args$color)
  ) {
    cli::cli_abort("{.arg stratum_args$color} must be one colour string.")
  }
  if (!is_number(stratum_args$linewidth, lower = 0)) {
    cli::cli_abort(
      "{.arg stratum_args$linewidth} must be a non-negative number."
    )
  }
  if (!is_number(stratum_args$gap, lower = 0)) {
    cli::cli_abort("{.arg stratum_args$gap} must be a non-negative number.")
  }

  label_styles <- c("count_percent", "count", "percent", "name", "none")
  if (
    !is.character(label_args$style) ||
      length(label_args$style) != 1L ||
      !label_args$style %in% label_styles
  ) {
    cli::cli_abort(
      "{.arg label_args$style} must be one of {.val {label_styles}}."
    )
  }
  if (!is_number(label_args$min_pct, lower = 0, upper = 1)) {
    cli::cli_abort("{.arg label_args$min_pct} must be between 0 and 1.")
  }
  if (!is_number(label_args$size, lower = 0, lower_open = TRUE)) {
    cli::cli_abort("{.arg label_args$size} must be greater than 0.")
  }
  if (
    !is.character(label_args$color) ||
      length(label_args$color) != 1L ||
      is.na(label_args$color)
  ) {
    cli::cli_abort("{.arg label_args$color} must be one colour string.")
  }
  if (
    !is.logical(label_args$box) ||
      length(label_args$box) != 1L ||
      is.na(label_args$box)
  ) {
    cli::cli_abort("{.arg label_args$box} must be `TRUE` or `FALSE`.")
  }
  if (
    !is.character(label_args$fill) ||
      length(label_args$fill) != 1L ||
      is.na(label_args$fill)
  ) {
    cli::cli_abort("{.arg label_args$fill} must be one colour string.")
  }
  if (!is_number(label_args$alpha, lower = 0, upper = 1)) {
    cli::cli_abort("{.arg label_args$alpha} must be between 0 and 1.")
  }

  if (!is.null(facet_args$nrow) && !is_integer(facet_args$nrow)) {
    cli::cli_abort(
      "{.arg facet_args$nrow} must be `NULL` or a positive integer."
    )
  }
  if (!is.null(facet_args$ncol) && !is_integer(facet_args$ncol)) {
    cli::cli_abort(
      "{.arg facet_args$ncol} must be `NULL` or a positive integer."
    )
  }
  facet_scales <- c("fixed", "free", "free_x", "free_y")
  if (
    !is.character(facet_args$scales) ||
      length(facet_args$scales) != 1L ||
      !facet_args$scales %in% facet_scales
  ) {
    cli::cli_abort(
      "{.arg facet_args$scales} must be one of {.val {facet_scales}}."
    )
  }
  if (!is_integer(legend_args$ncol)) {
    cli::cli_abort("{.arg legend_args$ncol} must be a positive integer.")
  }
  legend_positions <- c("right", "left", "top", "bottom", "none")
  if (
    !is.character(legend_args$position) ||
      length(legend_args$position) != 1L ||
      !legend_args$position %in% legend_positions
  ) {
    cli::cli_abort(
      "{.arg legend_args$position} must be one of {.val {legend_positions}}."
    )
  }

  y_type <- match.arg(y_type)
  keep <- stats::complete.cases(data[, required, drop = FALSE])
  removed <- sum(!keep)
  if (removed > 0L) {
    cli::cli_inform(c(
      "i" = "Removed {removed} row{?s} with missing values in required columns."
    ))
    data <- data[keep, , drop = FALSE]
  }
  if (nrow(data) == 0L) {
    cli::cli_abort("No complete rows remain in the required columns.")
  }

  observed_factor <- function(value) {
    value_chr <- as.character(value)
    if (is.factor(value)) {
      value_levels <- levels(value)
      value_levels <- value_levels[value_levels %in% value_chr]
    } else {
      value_levels <- unique(value_chr)
    }
    factor(value_chr, levels = value_levels, ordered = is.ordered(value))
  }

  facet_used <- !is.null(facet)
  plot_input <- data.frame(
    .facet = if (facet_used) observed_factor(data[[facet]]) else factor("All"),
    .cat_var = observed_factor(data[[cat_var]]),
    .group = observed_factor(data[[group]])
  )
  cat_levels <- levels(plot_input$.cat_var)
  group_levels <- levels(plot_input$.group)
  facet_levels <- levels(plot_input$.facet)

  frequency <- table(
    plot_input$.facet,
    plot_input$.cat_var,
    plot_input$.group
  )
  stat <- as.data.frame(frequency, responseName = "count")
  names(stat)[1:3] <- c(".facet", ".cat_var", ".group")
  stat$.facet <- factor(stat$.facet, levels = facet_levels)
  stat$.cat_var <- factor(stat$.cat_var, levels = cat_levels)
  stat$.group <- factor(stat$.group, levels = group_levels)
  stat$group_total <- ave(
    stat$count,
    stat$.facet,
    stat$.cat_var,
    FUN = sum
  )
  stat <- stat[stat$group_total > 0, , drop = FALSE]
  stat$percent <- stat$count / stat$group_total
  stat$.is_gap <- FALSE

  total_gap <- stratum_args$gap * max(length(group_levels) - 1L, 0L)
  if (y_type == "percent" && total_gap >= 1) {
    cli::cli_abort(
      "The total {.arg stratum_args$gap} space must be less than 1 in percent mode."
    )
  }
  stat$.y <- if (y_type == "percent") {
    stat$percent * (1 - total_gap)
  } else {
    stat$count
  }

  stat$.label <- NA_character_
  show_label <- stat$count > 0 &
    stat$percent >= label_args$min_pct &
    label_args$style != "none"
  if (any(show_label)) {
    group_name <- as.character(stat$.group[show_label])
    count_text <- as.character(stat$count[show_label])
    pct_text <- scales::percent(stat$percent[show_label], accuracy = 0.1)
    stat$.label[show_label] <- switch(
      label_args$style,
      count_percent = sprintf("%s (%s, %s)", group_name, count_text, pct_text),
      count = sprintf("%s (%s)", group_name, count_text),
      percent = sprintf("%s %s", group_name, pct_text),
      name = group_name,
      none = NA_character_
    )
  }

  gap_names <- character()
  if (stratum_args$gap > 0 && length(group_levels) > 1L) {
    gap_names <- paste0(".gap_", seq_len(length(group_levels) - 1L))
    observed <- unique(stat[, c(".facet", ".cat_var", "group_total")])
    max_total <- tapply(stat$group_total, stat$.facet, max)
    gap_rows <- lapply(gap_names, function(gap_name) {
      data.frame(
        .facet = observed$.facet,
        .cat_var = observed$.cat_var,
        .group = gap_name,
        count = 0,
        group_total = observed$group_total,
        percent = 0,
        .is_gap = TRUE,
        .y = if (y_type == "percent") {
          stratum_args$gap
        } else {
          stratum_args$gap * unname(max_total[as.character(observed$.facet)])
        },
        .label = NA_character_
      )
    })
    stat <- rbind(stat, do.call(rbind, gap_rows))
  }

  all_group_levels <- unlist(lapply(seq_along(group_levels), function(index) {
    if (index < length(group_levels)) {
      c(group_levels[index], gap_names[index])
    } else {
      group_levels[index]
    }
  }))
  stat$.facet <- factor(stat$.facet, levels = facet_levels)
  stat$.cat_var <- factor(stat$.cat_var, levels = cat_levels)
  stat$.group <- factor(stat$.group, levels = all_group_levels)

  colors <- .resolve_color(color, n = length(group_levels))
  real_colors <- stats::setNames(as.character(colors), group_levels)
  gap_colors <- stats::setNames(
    rep("transparent", length(gap_names)),
    gap_names
  )

  plot <- ggplot2::ggplot(
    stat,
    ggplot2::aes(
      x = .data$.cat_var,
      y = .data$.y,
      alluvium = .data$.group,
      stratum = .data$.group,
      fill = .data$.group
    )
  ) +
    ggalluvial::geom_alluvium(
      alpha = flow_args$alpha,
      width = stratum_args$width,
      curve_type = flow_args$curve_type
    ) +
    ggalluvial::geom_stratum(
      width = stratum_args$width,
      color = stratum_args$color,
      linewidth = stratum_args$linewidth
    )

  if (facet_used) {
    plot <- plot +
      ggplot2::facet_wrap(
        stats::as.formula("~ .facet"),
        nrow = facet_args$nrow,
        ncol = facet_args$ncol,
        scales = facet_args$scales
      )
  }

  if (label_args$style != "none" && any(!is.na(stat$.label))) {
    built <- ggplot2::ggplot_build(plot)
    stratum_data <- built$data[[2L]]
    if (is.factor(stratum_data$stratum)) {
      stratum_data$.group_chr <- as.character(stratum_data$stratum)
    } else if (is.numeric(stratum_data$stratum)) {
      stratum_data$.group_chr <- all_group_levels[as.integer(
        stratum_data$stratum
      )]
    } else {
      stratum_data$.group_chr <- as.character(stratum_data$stratum)
    }
    if (facet_used) {
      layout <- built$layout$layout
      layout_index <- match(
        as.character(stratum_data$PANEL),
        as.character(layout$PANEL)
      )
      stratum_data$.facet_chr <- as.character(layout$.facet[layout_index])
      panel_number <- as.integer(layout$PANEL[layout_index])
      stratum_data$.cat_var_chr <- vapply(
        seq_along(stratum_data$x),
        function(index) {
          panel_labels <- built$layout$panel_params[[panel_number[
            index
          ]]]$x$get_labels()
          as.character(panel_labels[as.integer(stratum_data$x[index])])
        },
        character(1)
      )
    } else {
      stratum_data$.facet_chr <- facet_levels[1L]
      stratum_data$.cat_var_chr <- cat_levels[as.integer(stratum_data$x)]
    }
    stratum_data$.y_center <- (stratum_data$ymin + stratum_data$ymax) / 2

    label_lookup <- stat[
      !stat$.is_gap & !is.na(stat$.label),
      c(".facet", ".cat_var", ".group", ".label")
    ]
    label_lookup$.facet_chr <- as.character(label_lookup$.facet)
    label_lookup$.cat_var_chr <- as.character(label_lookup$.cat_var)
    label_lookup$.group_chr <- as.character(label_lookup$.group)
    label_lookup <- label_lookup[
      c(".facet_chr", ".cat_var_chr", ".group_chr", ".label")
    ]
    label_data <- merge(
      stratum_data,
      label_lookup,
      by = c(".facet_chr", ".cat_var_chr", ".group_chr"),
      all = FALSE,
      sort = FALSE
    )
    label_data <- label_data[
      !grepl("^\\.gap_", label_data$.group_chr) & !is.na(label_data$.label),
      ,
      drop = FALSE
    ]
    label_data$.facet <- factor(label_data$.facet_chr, levels = facet_levels)

    if (nrow(label_data) > 0L) {
      label_mapping <- ggplot2::aes(
        x = .data$x,
        y = .data$.y_center,
        label = .data$.label
      )
      if (label_args$box) {
        plot <- plot +
          ggplot2::geom_label(
            data = label_data,
            mapping = label_mapping,
            inherit.aes = FALSE,
            size = label_args$size,
            color = label_args$color,
            fill = label_args$fill,
            alpha = label_args$alpha
          )
      } else {
        plot <- plot +
          ggplot2::geom_text(
            data = label_data,
            mapping = label_mapping,
            inherit.aes = FALSE,
            size = label_args$size,
            color = label_args$color,
            alpha = label_args$alpha
          )
      }
    }
  }

  plot <- plot +
    ggplot2::scale_fill_manual(
      values = c(real_colors, gap_colors),
      breaks = group_levels
    ) +
    ggplot2::labs(x = cat_var, y = NULL, fill = group) +
    ggplot2::guides(
      fill = ggplot2::guide_legend(ncol = as.integer(legend_args$ncol))
    ) +
    .resolve_theme(theme_use) +
    ggplot2::theme(
      legend.position = legend_args$position,
      legend.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(color = "black"),
      axis.title = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_blank()
    )
  if (y_type == "percent") {
    plot <- plot + ggplot2::scale_y_continuous(labels = scales::label_percent())
  }

  if (!is.null(save)) {
    if (!is.list(save)) {
      cli::cli_abort("{.arg save} must be `NULL` or a named list.")
    }
    if (length(save) > 0L) {
      save_names <- names(save)
      if (
        is.null(save_names) ||
          any(is.na(save_names)) ||
          any(!nzchar(save_names))
      ) {
        cli::cli_abort(
          "Every element of {.arg save} must have a non-empty name."
        )
      }
      if (anyDuplicated(save_names)) {
        cli::cli_abort("{.arg save} must not contain duplicate names.")
      }
      unknown_save <- setdiff(save_names, c("filename", "width", "height"))
      if (length(unknown_save) > 0L) {
        cli::cli_abort(
          "{.arg save} has unknown field{?s}: {.val {unknown_save}}."
        )
      }
      if (!requireNamespace("RegR", quietly = TRUE)) {
        cli::cli_abort(
          "Package {.pkg RegR} is required when {.arg save} is non-empty."
        )
      }
      do.call(RegR::save_plt, c(list(plot = plot), save))
    }
  }

  plot
}
