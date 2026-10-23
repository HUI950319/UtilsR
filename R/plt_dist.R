# =============================================================================
# plt_dist.R -- Categorical distribution plots (alluvial / bar / heatmap)
# =============================================================================

#' Plot Categorical Variable Distribution
#'
#' Visualise the cross-distribution of categorical variables. With 2 variables
#' the plot is an \strong{alluvial / Sankey flow} (default) or a
#' \strong{stacked proportion bar}, selected via \code{type}; with 3 variables
#' it is a \strong{tile heatmap}. The alluvial mode uses
#' \code{\link{plt_alluvial}()}, so it supports native faceting and only
#' requires the suggested \pkg{ggalluvial} package.
#'
#' The list arguments (\code{label_args}, \code{flow_args},
#' \code{stratum_args}, \code{facet_args}, \code{legend_args}) follow
#' \code{\link{plt_alluvial}()}: a partial list is merged with the defaults
#' shown in the usage, and unknown or duplicated fields are rejected.
#'
#' @param data A data frame. Existing dplyr grouping is ignored; counts use
#'   only the variables selected by \code{dis_vars} and \code{facet}. Rows
#'   missing any required value are removed with a message in every mode;
#'   unrelated columns do not affect inclusion. An error is raised if no
#'   complete rows remain. Alluvial mode also removes explicit NA factor levels
#'   and SPSS user-defined missing values. The heatmap ignores \code{facet}.
#' @param dis_vars Character vector of 2 or 3 distinct, non-empty column names.
#'   Plain integer and double columns are treated as categories in numeric
#'   ascending order in every mode; values are not binned. Labelled columns
#'   (\code{haven_labelled}, also as \code{facet}) are converted with
#'   \code{labelled::to_factor()}, so they show their value labels. Existing factors
#'   keep their level order. Character columns retain their existing ordering:
#'   first appearance for alluvial plots, sorted for bar charts and heatmaps.
#'   \itemize{
#'     \item 2 variables: \code{c(x, fill)} \eqn{\rightarrow} alluvial flow
#'       (\code{type = "alluvial"}, default) or stacked bar (\code{type = "bar"}).
#'     \item 3 variables: \code{c(x, y, fill)} \eqn{\rightarrow} tile heatmap
#'       (\code{type} ignored). Each observed \code{(x, y)} cell must have
#'       only one fill category; otherwise an error prevents overplotting.
#'   }
#' @param type Plot type for the 2-variable case: \code{"alluvial"} (default)
#'   or \code{"bar"} (stacked proportion bar on a percentage axis, with the
#'   first fill category on top as in the legend and the alluvial plot).
#'   Ignored when \code{dis_vars} has
#'   3 variables.
#' @param facet Optional faceting variable name (string). Used by both
#'   2-variable plot types and must differ from \code{dis_vars}; ignored for
#'   the 3-variable heatmap. Plain integer and double facet values use numeric
#'   ascending order; existing factors keep their level order. Panel layout
#'   follows \code{facet_args}.
#' @param color Colour specification, resolved by the internal colour resolver:
#'   \code{NULL} (default \code{pal_lancet}), a registered palette name (e.g.
#'   \code{"Paired"}), a single literal colour, or a vector of colours. In
#'   a named vector, names must be unique category labels and include every
#'   observed fill category. Unnamed vectors follow factor-level order (data
#'   order for character alluvial groups). Unused bar/heatmap factor levels
#'   retain their positions in an unnamed palette.
#' @param alpha One finite number between 0 and 1 giving the opacity of the
#'   bar segments and heatmap tiles, and of the flow ribbons in alluvial mode
#'   (where \code{\link{plt_alluvial}()} calls it \code{flow_args$alpha}).
#'   Default 0.7.
#' @param label_args A named list controlling the in-plot labels:
#'   \describe{
#'     \item{\code{style}}{Character scalar selecting label content. Default
#'       \code{"count_percent"}. Bar chart: \code{"count_percent"} gives
#'       \code{count (percent)} on one line, \code{"count_percent_wrap"} puts
#'       the count above the percentage, \code{"count"} and \code{"percent"}
#'       give one of them, and \code{"none"} hides the labels. Alluvial plot:
#'       \code{"count_percent"} gives \code{name (count, percent)},
#'       \code{"count_percent_wrap"} puts the name above
#'       \code{count (percent)}, \code{"count"} gives \code{name (count)},
#'       \code{"percent"} gives \code{name percent}, and \code{"none"} hides
#'       the labels. Heatmap: any value other than \code{"none"} prints the
#'       third variable's category in each tile; \code{"none"} hides the
#'       labels and shows the fill legend. Counts use a comma as thousands
#'       separator.}
#'     \item{\code{min_pct}}{Numeric scalar in \eqn{[0, 1]}. Bar segments and
#'       alluvial strata whose within-category proportion is below it are left
#'       unlabelled. Not used by the heatmap. Default \code{0}.}
#'     \item{\code{size}}{\code{NULL} or a positive number giving the ggplot2
#'       text size. \code{NULL} (default) scales with the base font size of
#'       \code{theme_use}: \code{(base_size - 4) / .pt} on bars,
#'       \code{(base_size - 2) / .pt} on the heatmap and
#'       \code{3 * base_size / 14} in alluvial mode.}
#'     \item{\code{color}}{Character scalar giving the label text colour.
#'       Default \code{"black"}.}
#'     \item{\code{box}}{Logical scalar. \code{TRUE} (default) draws boxed
#'       labels; \code{FALSE} draws plain text.}
#'     \item{\code{fill}}{Character scalar giving the label box background;
#'       used only when \code{box = TRUE}. Default \code{"white"}.}
#'     \item{\code{alpha}}{Numeric scalar in \eqn{[0, 1]} giving the label
#'       opacity. Default \code{1}.}
#'     \item{\code{pct_accuracy}}{Positive number giving the rounding accuracy
#'       of percentages, as in \code{scales::percent()}: \code{0.1} (default)
#'       keeps one decimal place and \code{1} gives whole percentages. Not used
#'       by the heatmap.}
#'   }
#' @param flow_args A named list for the flow ribbons, used only in alluvial
#'   mode:
#'   \describe{
#'     \item{\code{curve_type}}{Character scalar: \code{"linear"} (default),
#'       \code{"cubic"}, \code{"quintic"}, \code{"sine"},
#'       \code{"arctangent"}, \code{"sigmoid"} or \code{"xspline"}.}
#'   }
#'   The ribbon opacity is set by \code{alpha}.
#' @param stratum_args A named list for the strata, used only in alluvial mode:
#'   \describe{
#'     \item{\code{width}}{Number in \eqn{(0, 1]} giving the stratum width
#'       relative to the spacing of the x positions. Default \code{0.5}.}
#'     \item{\code{color}}{Character scalar giving the stratum border colour.
#'       Default \code{"gray50"}.}
#'     \item{\code{linewidth}}{Non-negative number giving the stratum border
#'       width. Default \code{0.3}.}
#'     \item{\code{gap}}{Non-negative number giving the transparent gap between
#'       strata as a fraction of the panel height; the gaps together must stay
#'       below 1. Default \code{0.01}; \code{0} removes them.}
#'   }
#' @param facet_args A named list controlling \code{ggplot2::facet_wrap()}
#'   when \code{facet} is set (bar and alluvial modes):
#'   \describe{
#'     \item{\code{nrow}}{\code{NULL} or a positive integer giving the number
#'       of panel rows. \code{NULL} (default) puts up to three panels in a row
#'       on bar charts (unless \code{ncol} is set) and keeps
#'       \code{facet_wrap()}'s layout in alluvial mode. Only facet values
#'       present in the data are counted.}
#'     \item{\code{ncol}}{\code{NULL} or a positive integer giving the number
#'       of panel columns. Default \code{NULL}.}
#'     \item{\code{scales}}{\code{"fixed"} (default), \code{"free"},
#'       \code{"free_x"} or \code{"free_y"}.}
#'   }
#' @param legend_args A named list controlling the fill legend:
#'   \describe{
#'     \item{\code{position}}{\code{NULL} or one of \code{"right"},
#'       \code{"left"}, \code{"top"}, \code{"bottom"}, \code{"none"}.
#'       \code{NULL} (default) keeps the automatic placement: the bar chart
#'       uses the theme's position, or \code{"right"} when the theme hides the
#'       legend (as the default \code{theme_heat()} does); the heatmap hides
#'       the legend when its tiles are labelled and otherwise places it like
#'       the bar chart; the alluvial plot uses \code{"right"}.}
#'     \item{\code{ncol}}{Positive integer giving the number of legend
#'       columns. Default \code{1}.}
#'   }
#' @param theme_use Theme specification, resolved by the internal theme
#'   resolver. Default \code{\link{theme_heat}(14)} (clean look). Also accepts
#'   a \code{ggplot2::theme} object, a theme function, a function-name string
#'   (e.g. \code{"theme_my"}), or \code{NULL} (\eqn{\rightarrow}
#'   \code{\link{theme_km}()}). Unless \code{label_args$size} is set, label
#'   sizes follow the theme's base font size, e.g.
#'   \code{theme_use = theme_my(base_size = 16)}. In alluvial mode only the
#'   base font size is taken from \code{theme_use};
#'   \code{\link{theme_alluvia}()} supplies the remaining theme settings.
#'
#' @param save \code{NULL}, an empty list (default), or a named list forwarded
#'   to \code{RegR::save_plt()} for PDF output: \code{filename} and optionally
#'   \code{width} and \code{height}. A \code{width} or \code{height} left out
#'   defaults to the page the plot is laid out for -- for the alluvial plot see
#'   \code{\link{plt_alluvial}()}; 0.9 in per x level (at least 3 in) by 4 in
#'   per facet for the bar chart, and 1.1 in per column by 0.6 in per row of
#'   cells for the heatmap, beside the measured axis text and legend -- which
#'   every call prints with the matching \code{save} line. Saving, and the size
#'   note, need the \pkg{RegR} package.
#'
#' @return A ggplot object carrying that page size as \code{attr(p,
#'   "plot_size")}, \code{c(width, height)} in inches.
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   stage = factor(sample(c("I","II","III","IV"), 200, TRUE)),
#'   sex   = factor(sample(c("M","F"), 200, TRUE)),
#'   race  = factor(sample(c("White","Black","Asian"), 200, TRUE)),
#'   grade = factor(sample(c("Low","Mid","High"), 200, TRUE))
#' )
#'
#' # --- Stacked bar (type = "bar") -------------------------------------------
#' # "count (percent)" labels on one line
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar")
#'
#' # Count above percent, whole percentages, segments below 10% unlabelled
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          label_args = list(style = "count_percent_wrap", pct_accuracy = 1,
#'                            min_pct = 0.1))
#'
#' # Percent-only labels, facets in one column, legend below
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar", facet = "race",
#'          label_args = list(style = "percent"),
#'          facet_args = list(ncol = 1),
#'          legend_args = list(position = "bottom", ncol = 2))
#'
#' # No labels
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          label_args = list(style = "none"))
#'
#' # Registered palette name / literal colour vector
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar", color = "Paired")
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          color = c("steelblue", "tomato"))
#'
#' # Theme + label size carried by theme_use
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          theme_use = theme_my(base_size = 16))
#'
#' # --- Tile heatmap (3 variables; type ignored) -----------------------------
#' heat_data <- expand.grid(stage = c("I", "II", "III", "IV"),
#'                          grade = c("Low", "Mid", "High"))
#' heat_data$category <- factor(rep(c("A", "B"), 6))
#' plt_dist(heat_data, dis_vars = c("stage", "grade", "category"))
#' plt_dist(heat_data, dis_vars = c("stage", "grade", "category"),
#'          label_args = list(style = "none"))
#'
#' # --- Alluvial flow (default; needs ggalluvial) ----------------------------
#' if (requireNamespace("ggalluvial", quietly = TRUE)) {
#'   plt_dist(df, dis_vars = c("stage", "sex"))
#'   plt_dist(df, dis_vars = c("stage", "sex"), facet = "race")
#'   plt_dist(df, dis_vars = c("stage", "sex"),
#'            label_args = list(style = "count_percent_wrap"))
#'   plt_dist(df, dis_vars = c("stage", "sex"),
#'            flow_args = list(curve_type = "sigmoid"),
#'            stratum_args = list(width = 0.4, gap = 0.02))
#' }
#'
#' @export
#' @family plot
plt_dist <- function(data,
                     dis_vars,
                     type = c("alluvial", "bar"),
                     facet = NULL,
                     color = NULL,
                     alpha = 0.7,
                     label_args = list(style = "count_percent", min_pct = 0,
                                       size = NULL, color = "black", box = TRUE,
                                       fill = "white", alpha = 1,
                                       pct_accuracy = 0.1),
                     flow_args = list(curve_type = "linear"),
                     stratum_args = list(width = 0.5, color = "gray50",
                                         linewidth = 0.3, gap = 0.01),
                     facet_args = list(nrow = NULL, ncol = NULL, scales = "fixed"),
                     legend_args = list(position = NULL, ncol = 1),
                     theme_use = theme_heat(14),
                     save = list()) {

  # --- Validate ---
  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  if (!is.character(dis_vars) || !is.null(dim(dis_vars)) ||
      !length(dis_vars) %in% c(2L, 3L) || anyNA(dis_vars) ||
      any(!nzchar(dis_vars)) || anyDuplicated(dis_vars)) {
    cli::cli_abort("{.arg dis_vars} must have 2 or 3 distinct, non-empty column names.")
  }
  dis_vars <- unname(dis_vars)
  missing_vars <- dis_vars[!dis_vars %in% names(data)]
  if (length(missing_vars) > 0) {
    cli::cli_abort("Variable{?s} not found in data: {.val {missing_vars}}")
  }
  if (length(dis_vars) == 2L) {
    type <- match.arg(type)
    if (!is.null(facet)) {
      if (!is.character(facet) || length(facet) != 1L || is.na(facet) ||
          !nzchar(facet) || !facet %in% names(data) || facet %in% dis_vars) {
        cli::cli_abort("{.arg facet} must name one existing column different from {.arg dis_vars}.")
      }
      facet <- unname(facet)
    }
  }
  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      !is.finite(alpha) || alpha < 0 || alpha > 1) {
    cli::cli_abort("{.arg alpha} must be one finite number between 0 and 1.")
  }
  # --- List settings: merge partial lists into the documented defaults ---
  merge_args <- function(value, defaults, arg) {
    if (!is.list(value)) cli::cli_abort("{.arg {arg}} must be a named list.")
    if (length(value) == 0L) return(defaults)
    value_names <- names(value)
    if (is.null(value_names) || anyNA(value_names) || any(!nzchar(value_names))) {
      cli::cli_abort("Every element of {.arg {arg}} must have a non-empty name.")
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
  label_args <- merge_args(label_args, list(
    style = "count_percent", min_pct = 0, size = NULL, color = "black",
    box = TRUE, fill = "white", alpha = 1, pct_accuracy = 0.1
  ), "label_args")
  flow_args <- merge_args(flow_args, list(curve_type = "linear"), "flow_args")
  stratum_args <- merge_args(stratum_args, list(
    width = 0.5, color = "gray50", linewidth = 0.3, gap = 0.01
  ), "stratum_args")
  facet_args <- merge_args(facet_args,
                           list(nrow = NULL, ncol = NULL, scales = "fixed"),
                           "facet_args")
  legend_args <- merge_args(legend_args, list(position = NULL, ncol = 1),
                            "legend_args")

  # Fields used by the bar and heatmap code; plt_alluvial() checks
  # flow_args and stratum_args, which only alluvial mode uses.
  is_number <- function(value, lower = -Inf, upper = Inf, lower_open = FALSE) {
    is.numeric(value) && length(value) == 1L && !is.na(value) &&
      is.finite(value) && (if (lower_open) value > lower else value >= lower) &&
      value <= upper
  }
  is_string <- function(value) {
    is.character(value) && length(value) == 1L && !is.na(value)
  }
  is_count <- function(value) is_number(value, lower = 1) && value == trunc(value)
  one_of <- function(values) paste("one of", paste0('"', values, '"', collapse = ", "))
  check_field <- function(ok, arg, requirement) {
    if (!ok) cli::cli_abort("{.arg {arg}} must be {requirement}.")
  }
  label_styles <- c("count_percent", "count_percent_wrap", "count", "percent", "none")
  facet_scales <- c("fixed", "free", "free_x", "free_y")
  legend_positions <- c("right", "left", "top", "bottom", "none")
  check_field(is_string(label_args$style) && label_args$style %in% label_styles,
              "label_args$style", one_of(label_styles))
  check_field(is_number(label_args$min_pct, 0, 1), "label_args$min_pct",
              "between 0 and 1")
  check_field(is.null(label_args$size) ||
                is_number(label_args$size, 0, lower_open = TRUE),
              "label_args$size", "`NULL` or a number greater than 0")
  check_field(is_string(label_args$color), "label_args$color", "one colour string")
  check_field(isTRUE(label_args$box) || isFALSE(label_args$box), "label_args$box",
              "`TRUE` or `FALSE`")
  check_field(is_string(label_args$fill), "label_args$fill", "one colour string")
  check_field(is_number(label_args$alpha, 0, 1), "label_args$alpha",
              "between 0 and 1")
  check_field(is_number(label_args$pct_accuracy, 0, lower_open = TRUE),
              "label_args$pct_accuracy", "a number greater than 0")
  for (field in c("nrow", "ncol")) {
    check_field(is.null(facet_args[[field]]) || is_count(facet_args[[field]]),
                paste0("facet_args$", field), "`NULL` or a positive integer")
  }
  check_field(is_string(facet_args$scales) && facet_args$scales %in% facet_scales,
              "facet_args$scales", one_of(facet_scales))
  check_field(is.null(legend_args$position) ||
                (is_string(legend_args$position) &&
                   legend_args$position %in% legend_positions),
              "legend_args$position", paste("`NULL` or", one_of(legend_positions)))
  check_field(is_count(legend_args$ncol), "legend_args$ncol", "a positive integer")

  data <- dplyr::ungroup(data)
  required <- c(dis_vars, if (length(dis_vars) == 2L) facet)
  keep <- stats::complete.cases(data[required])
  if (length(dis_vars) == 2L && type == "alluvial") {
    for (v in required) {
      keep <- keep & !is.na(data[[v]]) & !is.na(as.character(data[[v]]))
    }
  }
  removed <- sum(!keep)
  if (removed > 0L) {
    cli::cli_inform("Removed {removed} row{?s} with missing values in required columns.")
    data <- data[keep, , drop = FALSE]
  }
  if (nrow(data) == 0L) {
    cli::cli_abort("No complete rows remain in the required columns.")
  }

  # Normalize labelled and plain numeric categories before palette and mode
  # dispatch, so value labels (not codes) name the categories.
  for (v in required) {
    if (inherits(data[[v]], "haven_labelled")) {
      data[[v]] <- labelled::to_factor(data[[v]])
    } else if ((is.integer(data[[v]]) || is.double(data[[v]])) && !is.object(data[[v]])) {
      data[[v]] <- factor(data[[v]])
    }
  }

  named_palette <- NULL
  if (!is.null(names(color))) {
    color_names <- names(color)
    if (!is.character(color) || anyNA(color_names) ||
        any(!nzchar(color_names)) || anyDuplicated(color_names)) {
      cli::cli_abort("Named {.arg color} values must have unique, non-empty category names.")
    }
    fill_values <- data[[dis_vars[length(dis_vars)]]]
    needed_levels <- if (is.factor(fill_values)) {
      levels(fill_values)[levels(fill_values) %in% as.character(fill_values)]
    } else {
      unique(as.character(fill_values[!is.na(fill_values)]))
    }
    missing_colors <- setdiff(needed_levels, color_names)
    if (length(missing_colors)) {
      cli::cli_abort("Named {.arg color} must include every observed fill category; missing {.val {missing_colors}}.")
    }
    named_palette <- color[needed_levels]
  }

  # --- Resolve theme + fill colours ---
  # .resolve_theme(): NULL -> theme_km, else theme/function/name -> theme.
  # Unless `label_args$size` is set, label text size scales with the theme's
  # base font size (so it is carried by `theme_use`).
  thm <- .resolve_theme(theme_use)
  base_size <- tryCatch(thm$text$size, error = function(e) NULL)
  if (is.null(base_size) || !is.numeric(base_size)) base_size <- 14

  # --- Alluvial mode (2 variables only) -------------------------------------
  if (length(dis_vars) == 2L && type == "alluvial") {
    label_args$size <- label_args$size %||% (3 * base_size / 14)
    return(plt_alluvial(
      data = data,
      cat_var = dis_vars[1L],
      group = dis_vars[2L],
      facet = facet,
      color = if (is.null(named_palette)) color else unname(named_palette),
      flow_args = list(alpha = alpha, curve_type = flow_args$curve_type),
      stratum_args = stratum_args,
      label_args = label_args,
      facet_args = facet_args,
      legend_args = list(ncol = legend_args$ncol,
                         position = legend_args$position %||% "right"),
      theme_use = theme_alluvia(base_size),
      save = save
    ))
  }

  # Ensure factors for the stacked-bar and heatmap branches.
  for (v in dis_vars) {
    if (!is.factor(data[[v]])) data[[v]] <- factor(data[[v]])
  }

  # .resolve_color(): NULL -> pal_lancet, registered name -> pal_get, literal
  # colour(s) -> recycled; sized to the number of fill levels. Alpha here.
  fill_var    <- dis_vars[length(dis_vars)]
  fill_levels <- levels(data[[fill_var]])
  pal_cols <- if (is.null(named_palette)) {
    stats::setNames(ggplot2::alpha(.resolve_color(color, n = length(fill_levels)), alpha),
                    fill_levels)
  } else {
    stats::setNames(ggplot2::alpha(unname(named_palette), alpha), names(named_palette))
  }

  # --- 2 variables: stacked bar ---
  if (length(dis_vars) == 2) {
    x_var <- dis_vars[1]
    internal_names <- tail(make.unique(c(names(data), "n", "prop", ".lab")), 3L)
    count_name <- internal_names[1L]
    prop_name <- internal_names[2L]
    label_name <- internal_names[3L]

    # Compute proportions within each x (and facet) group
    grp_vars <- if (!is.null(facet)) c(x_var, fill_var, facet) else c(x_var, fill_var)
    plotdata <- data %>%
      dplyr::count(dplyr::across(dplyr::all_of(grp_vars)), name = count_name) %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(
        if (!is.null(facet)) c(x_var, facet) else x_var
      ))) %>%
      dplyr::mutate(!!prop_name := .data[[count_name]] / sum(.data[[count_name]])) %>%
      dplyr::ungroup()

    # Label text per `label_args$style`; segments below `min_pct` get NA
    # labels, which are dropped when drawn without changing the stacking.
    counts <- scales::comma(plotdata[[count_name]], accuracy = 1)
    pct <- scales::percent(plotdata[[prop_name]], accuracy = label_args$pct_accuracy)
    plotdata[[label_name]] <- switch(label_args$style,
      count              = counts,
      percent            = pct,
      count_percent      = sprintf("%s (%s)", counts, pct),
      count_percent_wrap = sprintf("%s\n%s", counts, pct),
      none               = NA_character_
    )
    plotdata[[label_name]][plotdata[[prop_name]] < label_args$min_pct] <- NA_character_

    p <- ggplot2::ggplot(plotdata, ggplot2::aes(
      x = .data[[x_var]], y = .data[[prop_name]], fill = .data[[fill_var]])) +
      ggplot2::geom_bar(stat = "identity", position = ggplot2::position_fill()) +
      ggplot2::scale_fill_manual(values = pal_cols) +
      ggplot2::scale_y_continuous(labels = scales::label_percent()) +
      ggplot2::guides(fill = ggplot2::guide_legend(ncol = legend_args$ncol)) +
      ggplot2::labs(x = x_var, y = "Proportion") +
      thm

    # The stacked bar maps fill -> the second variable's levels, while the
    # on-bar labels show count / percent (not the level names), so a fill
    # legend is needed to read the chart. The default theme_heat() hides the
    # legend (it targets the self-labelled heatmap); re-enable it here when the
    # active theme would hide it, leaving a custom theme's placement intact.
    legend_position <- legend_args$position %||%
      (if (identical(thm$legend.position, "none")) "right")
    if (!is.null(legend_position)) {
      p <- p + ggplot2::theme(legend.position = legend_position)
    }

    if (label_args$style != "none") {
      # A fixed label fill drops the inherited fill mapping, so `group` keeps
      # the labels stacked like the bar segments.
      label_mapping <- ggplot2::aes(label = .data[[label_name]],
                                    group = .data[[fill_var]])
      label_position <- ggplot2::position_fill(vjust = 0.5)
      label_size <- label_args$size %||% ((base_size - 4) / ggplot2::.pt)
      p <- p + if (label_args$box) {
        ggplot2::geom_label(label_mapping, position = label_position,
                            size = label_size, colour = label_args$color,
                            fill = label_args$fill, alpha = label_args$alpha,
                            na.rm = TRUE, show.legend = FALSE)
      } else {
        ggplot2::geom_text(label_mapping, position = label_position,
                           size = label_size, colour = label_args$color,
                           alpha = label_args$alpha, na.rm = TRUE,
                           show.legend = FALSE)
      }
    }

    if (!is.null(facet)) {
      n_facet <- length(unique(data[[facet]]))
      p <- p + ggplot2::facet_wrap(
        ggplot2::vars(!!rlang::sym(facet)),
        nrow = facet_args$nrow %||%
          (if (is.null(facet_args$ncol)) ceiling(n_facet / 3)),
        ncol = facet_args$ncol,
        scales = facet_args$scales
      )
    }

    return(.save_sized(p, save, c(max(3, 0.9 * length(unique(data[[x_var]]))), 4),
                       lead = "bar chart laid out for",
                       filename = "Figure X. Distribution.pdf"))
  }

  # --- 3 variables: heatmap ---
  x_var <- dis_vars[1]
  y_var <- dis_vars[2]

  plotdata <- data %>%
    dplyr::count(dplyr::across(dplyr::all_of(dis_vars)))
  if (anyDuplicated(plotdata[dis_vars[1:2]])) {
    cli::cli_abort(c(
      "Heatmap cells must not contain more than one fill category.",
      "i" = "Use a bar or alluvial plot to show category composition."
    ))
  }

  # Resolved theme + the tile-grid overrides (no legend / grid / ticks / axis
  # line) that previously lived in theme_heat(); applied on top of `theme_use`.
  labelled <- label_args$style != "none"
  heat_legend <- legend_args$position %||%
    (if (labelled) "none" else
      if (identical(thm$legend.position, "none")) "right" else thm$legend.position)
  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[[y_var]])) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data[[fill_var]]),
                       color = "black", linewidth = 0.5) +
    ggplot2::scale_fill_manual(values = pal_cols) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol = legend_args$ncol)) +
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::labs(x = NULL, y = NULL) +
    thm +
    ggplot2::theme(
      legend.position = heat_legend,
      panel.grid = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    )

  if (labelled) {
    label_size <- label_args$size %||% ((base_size - 2) / ggplot2::.pt)
    p <- p + if (label_args$box) {
      ggplot2::geom_label(ggplot2::aes(label = .data[[fill_var]]),
                          colour = label_args$color, fill = label_args$fill,
                          alpha = label_args$alpha, fontface = "bold",
                          size = label_size)
    } else {
      ggplot2::geom_text(ggplot2::aes(label = .data[[fill_var]]),
                         colour = label_args$color, alpha = label_args$alpha,
                         fontface = "bold", size = label_size)
    }
  }

  .save_sized(p, save, c(max(3, 1.1 * length(unique(plotdata[[x_var]]))),
                         max(2, 0.6 * length(unique(plotdata[[y_var]])))),
              lead = "heatmap laid out for",
              filename = "Figure X. Distribution.pdf")
}
