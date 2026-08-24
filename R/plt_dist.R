# ============================================================================
# plt_dist.R -- Categorical distribution plots (alluvial / stacked bar / heatmap)
# ============================================================================

#' Plot Categorical Variable Distribution
#'
#' Visualise the cross-distribution of categorical variables. With 2 variables
#' the plot is an **alluvial / Sankey flow** (default) or a **stacked
#' proportion bar**, selected via \code{type}; with 3 variables it is a **tile
#' heatmap**. The alluvial mode uses [plt_alluvial()], so it supports native
#' faceting and only requires the suggested \pkg{ggalluvial} package.
#'
#' @param data A data frame.
#' @param dis_vars Character vector of variable names.
#'   \itemize{
#'     \item 2 variables: \code{c(x, fill)} \eqn{\rightarrow} alluvial flow
#'       (\code{type = "alluvial"}, default) or stacked bar (\code{type = "bar"}).
#'     \item 3 variables: \code{c(x, y, fill)} \eqn{\rightarrow} tile heatmap
#'       (\code{type} ignored).
#'   }
#' @param type Plot type for the 2-variable case: \code{"alluvial"} (default)
#'   or \code{"bar"} (stacked proportion bar). Ignored when \code{dis_vars} has
#'   3 variables.
#' @param facet Optional faceting variable name (string). Used by both
#'   2-variable plot types; ignored for the 3-variable heatmap.
#' @param color Colour specification, resolved by the internal colour resolver:
#'   \code{NULL} (default \code{pal_lancet}), a registered palette name (e.g.
#'   \code{"Paired"}), a single literal colour, or a vector of colours. In
#'   alluvial mode these are passed to [plt_alluvial()].
#' @param alpha Colour transparency. Default 0.7. In alluvial mode this is the
#'   flow ribbon transparency (\code{flow.alpha}).
#' @param label Label content, one of \code{"count_percent"} (default),
#'   \code{"count"}, \code{"percent"}, \code{"none"}. For the **bar chart** this
#'   selects the count / percentage text on each segment. For the **heatmap**
#'   any value other than \code{"none"} prints the third variable's category in
#'   each tile; \code{"none"} hides the labels. For the **alluvial** plot it
#'   maps to `label_args$style` in [plt_alluvial()]: \code{"count_percent"}
#'   \eqn{\rightarrow} name + count + percent, \code{"count"} \eqn{\rightarrow}
#'   name + count, \code{"percent"} \eqn{\rightarrow} name + percent,
#'   \code{"none"} \eqn{\rightarrow} no labels.
#' @param gap Alluvial only. Gap between strata as a fraction of total height,
#'   forwarded to [plt_alluvial()]. Default 0.01; set 0 for no gaps.
#' @param curve_type Alluvial only. Flow ribbon curve type forwarded to
#'   [plt_alluvial()]. Default \code{"linear"}; other
#'   options include \code{"sigmoid"}, \code{"cubic"}, \code{"xspline"}.
#' @param theme_use Theme specification, resolved by [.resolve_theme()].
#'   Default [theme_heat]\code{(14)} (clean look). Also accepts a
#'   \code{ggplot2::theme} object, a theme function, a function-name string
#'   (e.g. \code{"theme_my"}), or \code{NULL} (\eqn{\rightarrow} [theme_km]).
#'   In-plot label sizes scale with the theme's base size, so control sizing
#'   through the theme itself, e.g. \code{theme_use = theme_my(base_size = 16)}.
#'   Note on the legend: the **bar chart** always shows the fill legend (it is
#'   re-enabled when the theme -- such as the default \code{theme_heat()} --
#'   would otherwise hide it, but a custom theme's legend placement is kept);
#'   the **heatmap** never shows one, since each tile is labelled directly.
#'   In **alluvial** mode only the base font size is taken from \code{theme_use};
#'   [theme_alluvia()] supplies the plot's remaining theme settings.
#'
#' @return A ggplot object.
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
#' # Count + percent labels
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar")
#'
#' # Percent-only labels, with facet
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          facet = "race", label = "percent")
#'
#' # No labels
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar", label = "none")
#'
#' # Registered palette name / literal colour vector
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar", color = "Paired")
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          color = c("steelblue", "tomato"))
#'
#' # Theme + size carried by theme_use
#' plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
#'          theme_use = theme_my(base_size = 16))
#'
#' # --- Tile heatmap (3 variables; type ignored) -----------------------------
#' plt_dist(df, dis_vars = c("stage", "grade", "sex"))
#' plt_dist(df, dis_vars = c("stage", "grade", "sex"), label = "none")
#'
#' # --- Alluvial flow (default; needs ggalluvial) ----------------------------
#' if (requireNamespace("ggalluvial", quietly = TRUE)) {
#'   plt_dist(df, dis_vars = c("stage", "sex"))
#'   plt_dist(df, dis_vars = c("stage", "sex"), facet = "race")
#'   plt_dist(df, dis_vars = c("stage", "sex"), gap = 0.02)
#'   plt_dist(df, dis_vars = c("stage", "sex"), curve_type = "sigmoid")
#'   plt_dist(df, dis_vars = c("stage", "sex"), label = "percent")
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
                     label = c("count_percent", "count", "percent", "none"),
                     gap = 0.01,
                     curve_type = "linear",
                     theme_use = theme_heat(14)) {

  label <- match.arg(label)
  type  <- match.arg(type)

  # --- Validate ---
  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  if (length(dis_vars) < 2 || length(dis_vars) > 3) {
    cli::cli_abort("{.arg dis_vars} must have 2 or 3 variable names.")
  }
  missing_vars <- dis_vars[!dis_vars %in% names(data)]
  if (length(missing_vars) > 0) {
    cli::cli_abort("Variable{?s} not found in data: {.val {missing_vars}}")
  }

  # --- Resolve theme + fill colours ---
  # .resolve_theme(): NULL -> theme_km, else theme/function/name -> theme.
  # Label text size scales with the theme's base font size (so it is carried
  # by `theme_use`, not a separate base_size argument).
  thm <- .resolve_theme(theme_use)
  base_size <- tryCatch(thm$text$size, error = function(e) NULL)
  if (is.null(base_size) || !is.numeric(base_size)) base_size <- 14

  # --- Alluvial mode (2 variables only) -------------------------------------
  if (length(dis_vars) == 2L && type == "alluvial") {
    return(plt_alluvial(
      data = data,
      cat_var = dis_vars[1L],
      group = dis_vars[2L],
      facet = facet,
      color = color,
      flow_args = list(alpha = alpha, curve_type = curve_type),
      stratum_args = list(gap = gap),
      label_args = list(style = label),
      theme_use = theme_alluvia(base_size)
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
  pal_cols    <- ggplot2::alpha(.resolve_color(color, n = length(fill_levels)), alpha)

  # --- 2 variables: stacked bar ---
  if (length(dis_vars) == 2) {
    x_var <- dis_vars[1]

    # Compute proportions within each x (and facet) group
    grp_vars <- if (!is.null(facet)) c(x_var, fill_var, facet) else c(x_var, fill_var)
    plotdata <- data %>%
      dplyr::count(dplyr::across(dplyr::all_of(grp_vars))) %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(
        if (!is.null(facet)) c(x_var, facet) else x_var
      ))) %>%
      dplyr::mutate(prop = .data[["n"]] / sum(.data[["n"]])) %>%
      dplyr::ungroup()

    # Label text per `label` mode
    pct <- scales::percent(plotdata$prop, accuracy = 0.1)
    plotdata$.lab <- switch(label,
      count         = as.character(plotdata$n),
      percent       = pct,
      count_percent = sprintf("%s\n(%s)", plotdata$n, pct),
      none          = NA_character_
    )

    p <- ggplot2::ggplot(plotdata, ggplot2::aes(
      x = .data[[x_var]], y = .data[["prop"]], fill = .data[[fill_var]])) +
      ggplot2::geom_bar(stat = "identity",
                        position = ggplot2::position_fill(reverse = TRUE)) +
      ggplot2::scale_fill_manual(values = pal_cols) +
      ggplot2::labs(x = x_var, y = "Proportion") +
      thm

    # The stacked bar maps fill -> the second variable's levels, while the
    # on-bar labels show count / percent (not the level names), so a fill
    # legend is needed to read the chart. The default theme_heat() hides the
    # legend (it targets the self-labelled heatmap); re-enable it here when the
    # active theme would hide it, leaving a custom theme's placement intact.
    if (identical(thm$legend.position, "none")) {
      p <- p + ggplot2::theme(legend.position = "right")
    }

    if (label != "none") {
      p <- p + ggplot2::geom_label(
        ggplot2::aes(label = .data[[".lab"]]),
        position = ggplot2::position_fill(reverse = TRUE, vjust = 0.5),
        show.legend = FALSE, size = (base_size - 4) / ggplot2::.pt
      )
    }

    if (!is.null(facet)) {
      if (!facet %in% names(data)) cli::cli_abort("Facet variable {.val {facet}} not found.")
      if (!is.factor(data[[facet]])) data[[facet]] <- factor(data[[facet]])
      n_facet <- nlevels(data[[facet]])
      p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet)),
                                   nrow = ceiling(n_facet / 3))
    }

    return(p)
  }

  # --- 3 variables: heatmap ---
  x_var <- dis_vars[1]
  y_var <- dis_vars[2]

  plotdata <- data %>%
    dplyr::count(dplyr::across(dplyr::all_of(dis_vars)))

  # Resolved theme + the tile-grid overrides (no legend / grid / ticks / axis
  # line) that previously lived in theme_heat(); applied on top of `theme_use`.
  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[[y_var]])) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data[[fill_var]]),
                       color = "black", linewidth = 0.5) +
    ggplot2::scale_fill_manual(values = pal_cols) +
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::labs(x = NULL, y = NULL) +
    thm +
    ggplot2::theme(
      legend.position = "none",
      panel.grid = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    )

  if (label != "none") {
    p <- p + ggplot2::geom_label(
      ggplot2::aes(label = .data[[fill_var]]),
      color = "black", fontface = "bold",
      size = (base_size - 2) / ggplot2::.pt
    )
  }

  p
}
