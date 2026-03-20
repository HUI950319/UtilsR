# ============================================================================
# plt_sankey.R -- Sankey diagram for categorical variable flows
# ============================================================================

#' Sankey Diagram for Categorical Variables
#'
#' Visualise the flow/proportion changes across multiple categorical variables
#' using a Sankey (alluvial) diagram. Each node label shows the level name,
#' count, and percentage.
#'
#' @param data A data frame.
#' @param vars Character vector of categorical variable names (>= 2).
#'   Variables are displayed left-to-right in the given order.
#' @param palette Colour palette name from \code{pal_get()}, or a character
#'   vector of colours. Default \code{NULL} auto-generates colours per variable
#'   using sequential HCL palettes.
#' @param reverse_levels Logical, reverse factor levels for display.
#'   Default \code{TRUE}.
#' @param show_n Logical, show count in node labels. Default \code{TRUE}.
#' @param width Sankey node width. Default 0.4.
#' @param label_size Label text size. Default 3.
#' @param label_hjust Label horizontal justification. Default 0.5.
#' @param alpha Flow transparency. Default 0.6.
#' @param base_size Base font size. Default 14.
#'
#' @return A ggplot object.
#'
#' @note Requires the \pkg{ggsankey} package
#'   (\code{pak::pak("davidsjoberg/ggsankey")}).
#'
#' @examples
#' df <- data.frame(
#'   sex = factor(sample(c("M","F"), 200, TRUE)),
#'   stage = factor(sample(c("I","II","III"), 200, TRUE)),
#'   grade = factor(sample(c("Low","High"), 200, TRUE))
#' )
#'
#' # Basic sankey
#' plt_sankey(df, vars = c("sex", "stage", "grade"))
#'
#' # Two variables
#' plt_sankey(df, vars = c("sex", "stage"))
#'
#' # Custom palette
#' plt_sankey(df, vars = c("sex", "stage"), palette = "Paired")
#'
#' # Without counts in labels
#' plt_sankey(df, vars = c("sex", "stage", "grade"), show_n = FALSE)
#'
#' # Adjust appearance
#' plt_sankey(df, vars = c("sex", "stage"),
#'            width = 0.3, label_size = 4, alpha = 0.4)
#'
#' @export
#' @family plot formatting
plt_sankey <- function(data,
                       vars,
                       palette = NULL,
                       reverse_levels = TRUE,
                       show_n = TRUE,
                       width = 0.4,
                       label_size = 3,
                       label_hjust = 0.5,
                       alpha = 0.6,
                       base_size = 14) {

  if (!requireNamespace("ggsankey", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggsankey} is required. Install with: {.code pak::pak('davidsjoberg/ggsankey')}")
  }

  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  if (length(vars) < 2) cli::cli_abort("{.arg vars} must have at least 2 variables.")
  missing_vars <- vars[!vars %in% names(data)]
  if (length(missing_vars) > 0) cli::cli_abort("Variable{?s} not found: {.val {missing_vars}}")

  # Ensure factors
  for (v in vars) {
    if (!is.factor(data[[v]])) data[[v]] <- factor(data[[v]])
  }

  # Reverse levels if requested
  if (reverse_levels) {
    for (v in vars) data[[v]] <- forcats::fct_rev(data[[v]])
  }

  # Add count + percentage labels to each variable
  label_vars <- character(length(vars))
  for (i in seq_along(vars)) {
    v <- vars[i]
    lv <- paste0(v, "_label")
    label_vars[i] <- lv
    total <- nrow(data)
    data <- data %>%
      dplyr::group_by(.data[[v]]) %>%
      dplyr::mutate(
        .n = dplyr::n(),
        .pct = scales::percent(.data[[".n"]] / total, accuracy = 0.1)
      ) %>%
      dplyr::ungroup()
    if (show_n) {
      data[[lv]] <- sprintf("%s (%s, %s)", data[[v]], data$.n, data$.pct)
    } else {
      data[[lv]] <- sprintf("%s (%s)", data[[v]], data$.pct)
    }
    # Preserve factor order
    lvl_df <- dplyr::distinct(data[, c(v, lv)])
    lvl_df <- lvl_df[order(lvl_df[[v]]), ]
    data[[lv]] <- factor(data[[lv]], levels = lvl_df[[lv]])
    data$.n <- NULL
    data$.pct <- NULL
  }

  # Strip palette class from label columns before make_long (tidyr compatibility)
  for (lv in label_vars) {
    class(data[[lv]]) <- "factor"
  }

  # Build sankey data
  plot_data <- ggsankey::make_long(data, dplyr::all_of(label_vars))

  # Set node factor levels
  all_levels <- unlist(lapply(label_vars, function(lv) levels(data[[lv]])))
  plot_data$node <- factor(plot_data$node, levels = all_levels)

  # Generate colours (always as plain character, not palette class)
  if (is.null(palette)) {
    hcl_pals <- c("Blues", "Oranges", "Greens", "Purples", "Reds", "Grays")
    col_list <- lapply(seq_along(vars), function(i) {
      pal_name <- hcl_pals[((i - 1) %% length(hcl_pals)) + 1]
      n_lvs <- nlevels(data[[vars[i]]])
      grDevices::colorRampPalette(
        as.character(pal_get(paste0("hcl_", pal_name), n = 5))[2:4]
      )(n_lvs)
    })
    mycol <- unlist(col_list)
  } else if (length(palette) == 1 && palette %in% names(palette_list)) {
    mycol <- as.character(pal_get(palette, n = length(all_levels)))
  } else {
    mycol <- rep_len(as.character(palette), length(all_levels))
  }

  # Plot
  ggplot2::ggplot(plot_data, ggplot2::aes(
    x = .data[["x"]], next_x = .data[["next_x"]],
    node = .data[["node"]], next_node = .data[["next_node"]],
    fill = factor(.data[["node"]]),
    color = factor(.data[["node"]]),
    label = .data[["node"]]
  )) +
    ggsankey::geom_sankey(
      flow.alpha = alpha, flow.fill = "grey", flow.color = "grey80",
      width = width
    ) +
    ggsankey::geom_sankey_label(
      size = label_size, fill = "white", alpha = 1, hjust = label_hjust
    ) +
    ggplot2::scale_fill_manual(values = mycol) +
    ggplot2::scale_color_manual(values = mycol) +
    ggsankey::theme_sankey(base_size = base_size) +
    ggplot2::labs(x = NULL) +
    ggplot2::theme(legend.position = "none")
}
