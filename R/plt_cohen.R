# ============================================================================
# plt_cohen.R -- Cleveland dot plot for Cohen's d effect sizes
# ============================================================================

#' Plot Cohen's d Effect Sizes
#'
#' Visualise Cohen's d values as a Cleveland dot plot (lollipop chart).
#' Variables are ordered by the effect size of a reference group.
#' Dashed lines at +/-0.2 indicate the small effect threshold.
#'
#' @param res Data frame from \code{stat_cohen()}: first column is
#'   \code{Variable}, remaining columns are Cohen's d per group.
#' @param ref_group Character, name of the reference group column used for
#'   sorting. Default \code{NULL} uses the first group column.
#' @param palette Colour palette name or character vector of colours.
#'   Default uses \code{pal_lancet}.
#' @param threshold Numeric, dashed reference line positions for small effect.
#'   Default \code{c(-0.2, 0.2)}.
#' @param add_line Logical, connect dots with lines. Default \code{TRUE}.
#' @param facet Logical, facet by group. Default \code{FALSE}.
#' @param base_size Base font size. Default 14.
#'
#' @return A ggplot object.
#'
#' @examples
#' # Using iris data
#' res <- stat_cohen(iris, group = "Species",
#'                   vars = c("Sepal.Length", "Sepal.Width",
#'                            "Petal.Length", "Petal.Width"))
#'
#' # Basic dot plot
#' plt_cohen(res)
#'
#' # Sort by a specific group
#' plt_cohen(res, ref_group = "versicolor")
#'
#' # With facet per group
#' plt_cohen(res, facet = TRUE)
#'
#' # Without connecting lines
#' plt_cohen(res, add_line = FALSE)
#'
#' # Custom threshold and palette
#' plt_cohen(res, threshold = c(-0.5, 0.5), palette = "Paired")
#'
#' # Simulated multi-group data
#' df <- data.frame(
#'   group = factor(sample(c("Control","Treatment","Placebo"), 150, TRUE)),
#'   age = rnorm(150, 50, 10),
#'   bmi = rnorm(150, 25, 5),
#'   score = rnorm(150, 100, 15)
#' )
#' res2 <- stat_cohen(df, "group", c("age", "bmi", "score"))
#' plt_cohen(res2)
#' plt_cohen(res2, facet = TRUE, palette = "Set2")
#'
#' @export
#' @family plot
plt_cohen <- function(res,
                      ref_group = NULL,
                      palette = NULL,
                      threshold = c(-0.2, 0.2),
                      add_line = TRUE,
                      facet = FALSE,
                      base_size = 14) {

  if (!is.data.frame(res) || ncol(res) < 2) {
    cli::cli_abort("{.arg res} must be a data frame from {.fn stat_cohen}.")
  }

  names(res)[1] <- "Variable"
  group_cols <- names(res)[-1]
  if (is.null(ref_group)) ref_group <- group_cols[1]
  if (!ref_group %in% group_cols) {
    cli::cli_abort("{.val {ref_group}} not found. Available: {.val {group_cols}}")
  }

  # Resolve colours
  n_groups <- length(group_cols)
  if (is.null(palette)) {
    cols <- as.character(pal_lancet[seq_len(min(n_groups, length(pal_lancet)))])
  } else if (length(palette) == 1 && palette %in% names(palette_list)) {
    cols <- as.character(pal_get(palette, n = n_groups))
  } else {
    cols <- rep_len(as.character(palette), n_groups)
  }

  # Long format, ordered by ref_group
  plotdata <- res %>%
    dplyr::mutate(Variable = forcats::fct_reorder(.data[["Variable"]],
                                                   .data[[ref_group]])) %>%
    tidyr::pivot_longer(cols = -1, names_to = "Group", values_to = "cohen_d") %>%
    dplyr::mutate(Group = factor(.data[["Group"]], levels = group_cols))

  # Build plot
  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["cohen_d"]], y = .data[["Variable"]],
    color = .data[["Group"]], group = .data[["Group"]]
  )) +
    ggplot2::geom_point(ggplot2::aes(shape = .data[["Group"]]), size = 3) +
    ggplot2::scale_color_manual(values = cols) +
    ggplot2::labs(x = "Cohen's d", y = NULL) +
    theme_my(base_size = base_size)

  # Reference lines
  for (th in threshold) {
    p <- p + ggplot2::geom_vline(
      xintercept = th, linetype = "dashed", color = "#ED0000FF", linewidth = 0.5
    )
  }

  # Connecting lines
  if (add_line) {
    p <- p + ggplot2::geom_line(orientation = "y", linewidth = 0.8)
  }

  # Facet
  if (facet) {
    p <- p +
      ggplot2::facet_wrap(~ .data[["Group"]], nrow = 1) +
      ggplot2::theme(legend.position = "none")
  }

  p
}
