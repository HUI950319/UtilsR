# ============================================================================
# plt_dist.R -- Categorical distribution plots (stacked bar / heatmap)
# ============================================================================

#' Plot Categorical Variable Distribution
#'
#' Visualise the cross-distribution of categorical variables as a stacked
#' proportion bar chart (2 variables) or a tile heatmap (3 variables).
#' The plot type is automatically determined by the number of variables.
#'
#' @param data A data frame.
#' @param vars Character vector of variable names.
#'   \itemize{
#'     \item 2 variables: \code{c(x, fill)} \eqn{\rightarrow} stacked bar chart.
#'     \item 3 variables: \code{c(x, y, fill)} \eqn{\rightarrow} tile heatmap.
#'   }
#' @param facet Optional faceting variable name (string). Only used with
#'   2-variable bar charts.
#' @param palette Colour palette. A character vector of colours, or a palette
#'   name from \code{pal_get()}. Default uses \code{pal_lancet}.
#' @param alpha Colour transparency. Default 0.7.
#' @param label Logical, show count and percentage labels. Default \code{TRUE}.
#' @param base_size Base font size for the theme. Default 14.
#'
#' @return A ggplot object.
#'
#' @examples
#' # --- Stacked bar chart (2 variables) ---
#' df <- data.frame(
#'   stage = factor(sample(c("I","II","III","IV"), 200, TRUE)),
#'   sex = factor(sample(c("M","F"), 200, TRUE)),
#'   race = factor(sample(c("White","Black","Asian"), 200, TRUE)),
#'   grade = factor(sample(c("Low","Mid","High"), 200, TRUE))
#' )
#'
#' # Basic bar chart
#' plt_dist(df, vars = c("stage", "sex"))
#'
#' # With facet
#' plt_dist(df, vars = c("stage", "sex"), facet = "race")
#'
#' # Without labels
#' plt_dist(df, vars = c("stage", "sex"), label = FALSE)
#'
#' # Custom palette (name from palette_list)
#' plt_dist(df, vars = c("stage", "sex"), palette = "Paired")
#'
#' # Custom palette (colour vector)
#' plt_dist(df, vars = c("stage", "sex"), palette = c("steelblue", "tomato"))
#'
#' # --- Heatmap (3 variables, auto-detected) ---
#' plt_dist(df, vars = c("stage", "grade", "sex"))
#'
#' # Heatmap without labels
#' plt_dist(df, vars = c("stage", "grade", "sex"), label = FALSE)
#'
#' # Adjust transparency and font size
#' plt_dist(df, vars = c("stage", "sex"), alpha = 0.5, base_size = 12)
#'
#' @export
#' @family plot formatting
plt_dist <- function(data,
                     vars,
                     facet = NULL,
                     palette = NULL,
                     alpha = 0.7,
                     label = TRUE,
                     base_size = 14) {

  # --- Validate ---
  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  if (length(vars) < 2 || length(vars) > 3) {
    cli::cli_abort("{.arg vars} must have 2 or 3 variable names.")
  }
  missing_vars <- vars[!vars %in% names(data)]
  if (length(missing_vars) > 0) {
    cli::cli_abort("Variable{?s} not found in data: {.val {missing_vars}}")
  }

  # Ensure factors
  for (v in vars) {
    if (!is.factor(data[[v]])) data[[v]] <- factor(data[[v]])
  }

  # --- Resolve palette ---
  if (is.null(palette)) {
    fill_var <- vars[length(vars)]
    n_lvs <- nlevels(data[[fill_var]])
    pal_cols <- ggplot2::alpha(pal_lancet[seq_len(min(n_lvs, length(pal_lancet)))], alpha)
    if (n_lvs > length(pal_lancet)) {
      pal_cols <- ggplot2::alpha(grDevices::colorRampPalette(pal_lancet)(n_lvs), alpha)
    }
  } else if (length(palette) == 1 && palette %in% names(palette_list)) {
    fill_var <- vars[length(vars)]
    n_lvs <- nlevels(data[[fill_var]])
    raw <- pal_get(palette, n = n_lvs)
    pal_cols <- ggplot2::alpha(raw, alpha)
  } else {
    pal_cols <- ggplot2::alpha(palette, alpha)
  }

  # --- 2 variables: stacked bar ---
  if (length(vars) == 2) {
    x_var <- vars[1]
    fill_var <- vars[2]

    # Compute proportions
    grp_vars <- if (!is.null(facet)) c(x_var, fill_var, facet) else c(x_var, fill_var)
    plotdata <- data %>%
      dplyr::count(dplyr::across(dplyr::all_of(grp_vars))) %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(
        if (!is.null(facet)) c(x_var, facet) else x_var
      ))) %>%
      dplyr::mutate(
        prop = .data[["n"]] / sum(.data[["n"]]),
        label = sprintf("%s\n(%s)", .data[["n"]],
                        scales::percent(.data[["prop"]], accuracy = 0.1))
      ) %>%
      dplyr::ungroup()

    p <- ggplot2::ggplot(plotdata, ggplot2::aes(
      x = .data[[x_var]], y = .data[["prop"]], fill = .data[[fill_var]])) +
      ggplot2::geom_bar(stat = "identity",
                        position = ggplot2::position_fill(reverse = TRUE)) +
      ggplot2::scale_fill_manual(values = pal_cols) +
      ggplot2::labs(x = x_var, y = "Proportion") +
      theme_my(base_size = base_size)

    if (label) {
      p <- p + ggplot2::geom_label(
        ggplot2::aes(label = .data[["label"]]),
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
  x_var <- vars[1]
  y_var <- vars[2]
  fill_var <- vars[3]

  plotdata <- data %>%
    dplyr::count(dplyr::across(dplyr::all_of(vars)))

  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[[y_var]])) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data[[fill_var]]),
                       color = "black", linewidth = 0.5) +
    ggplot2::scale_fill_manual(values = pal_cols) +
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::labs(x = NULL, y = NULL) +
    theme_my(base_size = base_size) +
    ggplot2::theme(
      legend.position = "none",
      panel.grid = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    )

  if (label) {
    p <- p + ggplot2::geom_label(
      ggplot2::aes(label = .data[[fill_var]]),
      color = "black", fontface = "bold",
      size = (base_size - 2) / ggplot2::.pt
    )
  }

  p
}
