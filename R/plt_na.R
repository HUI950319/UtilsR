#' Plot Missing Values
#'
#' Create a missing-value matrix, a missing-percentage bar chart, or one of
#' two combined layouts for a data frame or an `mlr3::Task`.
#' Use [plt_upset()] with `levels = NA` to visualise joint missing-value
#' patterns across selected variables.
#'
#' @param data A data frame, tibble, or object inheriting from `Task`.
#' @param name.map Optional named character vector used to replace variable
#'   names in the plot. Names must be the original variable names.
#' @param miss_palette Character vector of at least three colours. The first
#'   colour represents present values, the second represents missing values,
#'   and the third colours the 30% reference line. Defaults to the first three
#'   colours of [pal_lancet()].
#' @param output Plot layout to return. One of `"both"` (missingness matrix on
#'   the left and percentages on the right), `"both_reverse"` (percentages on
#'   the left and matrix on the right), `"matrix"`, or `"percentage"`.
#' @param sort Variable order by missing rate: `"desc"` (default, largest to
#'   smallest) or `"asc"` (smallest to largest).
#'
#' @return A single ggplot-compatible object. Combined outputs return a
#'   patchwork object, which inherits from ggplot. Returns `NULL` with a
#'   warning when no missing values are found.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("ToyData", quietly = TRUE)) {
#'   plt_na(ToyData::oc)
#'   plt_na(ToyData::oc, output = "both_reverse")
#'   plt_na(ToyData::oc, output = "matrix")
#'   plt_na(ToyData::oc, output = "percentage", sort = "asc")
#' }
#'
#' if (requireNamespace("ToyData", quietly = TRUE) &&
#'     requireNamespace("ggVennDiagram", quietly = TRUE)) {
#'   plt_upset(
#'     ToyData::oc0,
#'     vars = c("BMI_1", "BMI_2", "BMI_3"),
#'     levels = NA,
#'     output = "upset"
#'   )
#' }
#' }
#'
#' @seealso [fmt_strip()], [plt_upset()]
#' @export
#' @family inspect
plt_na <- function(
    data,
    name.map = NULL,
    miss_palette = as.character(pal_lancet[c(1, 2, 3)]),
    output = c("both", "both_reverse", "matrix", "percentage"),
    sort = c("desc", "asc")) {
  output <- match.arg(output)
  sort <- match.arg(sort)

  if (inherits(data, "Task")) {
    df <- data$data()
    miss_vec <- data$missings()
  } else if (is.data.frame(data)) {
    df <- data
    miss_vec <- vapply(df, \(x) mean(is.na(x)), numeric(1))
  } else {
    cli::cli_abort("{.arg data} must be a data.frame, tibble, or Task object.")
  }

  df <- as.data.frame(df)
  if (nrow(df) == 0L) {
    cli::cli_abort("{.arg data} must contain at least one observation.")
  }

  if (is.null(names(miss_vec))) {
    miss_vec <- vapply(df, \(x) mean(is.na(x)), numeric(1))
  } else {
    miss_vec <- miss_vec[names(miss_vec) %in% names(df)]
  }

  if (!is.null(name.map) &&
      (!is.character(name.map) || is.null(names(name.map)))) {
    cli::cli_abort("{.arg name.map} must be a named character vector or NULL.")
  }

  if (!is.character(miss_palette) || length(miss_palette) < 3L) {
    cli::cli_abort("{.arg miss_palette} must contain at least three colours.")
  }
  miss_palette <- miss_palette[seq_len(3L)]

  map_name <- function(x) {
    if (is.null(name.map)) {
      return(x)
    }
    mapped <- unname(name.map[x])
    mapped[is.na(mapped)] <- x[is.na(mapped)]
    mapped
  }

  missing_vars <- names(miss_vec[miss_vec > 0])
  if (length(missing_vars) == 0L) {
    warning("No missing values found in the dataset.", call. = FALSE)
    return(NULL)
  }

  missing_summary <- df |>
    dplyr::select(dplyr::all_of(missing_vars)) |>
    tidyr::pivot_longer(
      dplyr::everything(),
      names_to = "name",
      values_to = "value",
      values_transform = list(value = as.character)
    ) |>
    dplyr::mutate(isna = is.na(.data[["value"]])) |>
    dplyr::count(.data[["name"]], .data[["isna"]], name = "num") |>
    dplyr::group_by(.data[["name"]]) |>
    dplyr::mutate(
      total = sum(.data[["num"]]),
      pct = .data[["num"]] / .data[["total"]] * 100
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(label = map_name(.data[["name"]]))

  variable_summary <- missing_summary |>
    dplyr::filter(.data[["isna"]])
  variable_summary <- if (sort == "desc") {
    variable_summary |>
      dplyr::arrange(dplyr::desc(.data[["pct"]]))
  } else {
    variable_summary |>
      dplyr::arrange(.data[["pct"]])
  }
  variable_levels <- dplyr::pull(variable_summary, "label")

  missing_summary$label <- factor(
    missing_summary$label,
    levels = variable_levels
  )

  fill_values <- c("FALSE" = miss_palette[1], "TRUE" = miss_palette[2])
  fill_labels <- c("Present", "Missing")
  combined_gap <- 2

  build_percentage_plot <- function(
      reverse = FALSE,
      combined = FALSE,
      gap_side = NULL) {
    common_layers <- list(
      ggplot2::geom_bar(
        ggplot2::aes(
          x = .data[["label"]],
          y = .data[["pct"]],
          fill = .data[["isna"]]
        ),
        stat = "identity",
        alpha = 0.8
      ),
      ggplot2::geom_hline(
        yintercept = 30,
        color = miss_palette[3],
        linetype = "dashed",
        linewidth = 1
      ),
      ggplot2::scale_fill_manual(
        name = "",
        values = fill_values,
        labels = fill_labels
      ),
      ggplot2::scale_x_discrete(
        limits = rev(variable_levels),
        expand = c(0, 0)
      ),
      ggplot2::coord_flip(),
      ggplot2::labs(y = "Percentage of missing values", x = NULL),
      theme_my()
    )

    y_scale <- if (reverse) {
      ggplot2::scale_y_continuous(
        trans = "reverse",
        limits = c(100, 0),
        oob = scales::oob_squish,
        breaks = seq(0, 100, 25),
        expand = c(0, 0)
      )
    } else {
      ggplot2::scale_y_continuous(
        limits = c(0, 100),
        oob = scales::oob_squish,
        breaks = seq(0, 100, 25),
        expand = c(0, 0)
      )
    }

    plot <- ggplot2::ggplot(missing_summary) +
      common_layers +
      ggplot2::geom_label(
        data = \(x) dplyr::filter(x, .data[["isna"]]),
        ggplot2::aes(
          label = paste0(round(.data[["pct"]], 2), "%"),
          x = .data[["label"]],
          y = if (reverse) {
            pmax(.data[["pct"]] - 2.8, 2.8)
          } else {
            pmin(.data[["pct"]] + 2.8, 97.2)
          }
        ),
        vjust = 0.5,
        size = 3,
        color = "black"
      ) +
      y_scale

    if (combined) {
      plot_margin <- ggplot2::margin(0, 0, 0, 0, "pt")
      if (identical(gap_side, "left")) {
        plot_margin <- ggplot2::margin(0, 0, 0, combined_gap, "pt")
      } else if (identical(gap_side, "right")) {
        plot_margin <- ggplot2::margin(0, combined_gap, 0, 0, "pt")
      }
      combined_theme <- list(
        legend.position = "top",
        panel.spacing = grid::unit(0, "pt"),
        plot.margin = plot_margin
      )
      if (!reverse) {
        combined_theme$axis.text.y <- ggplot2::element_blank()
        combined_theme$axis.ticks.y <- ggplot2::element_blank()
      }
      plot <- plot + do.call(ggplot2::theme, combined_theme)
    }

    plot
  }

  build_matrix_plot <- function(
      show_legend = FALSE,
      show_y_labels = TRUE,
      gap_side = NULL) {
    matrix_data <- df |>
      dplyr::select(dplyr::all_of(missing_vars)) |>
      dplyr::mutate(id = dplyr::row_number()) |>
      tidyr::pivot_longer(
        -id,
        names_to = "name",
        values_to = "value",
        values_transform = list(value = as.character)
      ) |>
      dplyr::mutate(
        isna = is.na(.data[["value"]]),
        label = map_name(.data[["name"]]),
        label = factor(.data[["label"]], levels = variable_levels)
      )

    plot_margin <- ggplot2::margin(0, 0, 0, 0, "pt")
    if (identical(gap_side, "left")) {
      plot_margin <- ggplot2::margin(0, 0, 0, combined_gap, "pt")
    } else if (identical(gap_side, "right")) {
      plot_margin <- ggplot2::margin(0, combined_gap, 0, 0, "pt")
    }

    plot <- ggplot2::ggplot(
      matrix_data,
      ggplot2::aes(
        x = .data[["label"]],
        y = .data[["id"]],
        fill = .data[["isna"]]
      )
    ) +
      ggplot2::geom_tile(alpha = 0.8, colour = "black") +
      ggplot2::scale_fill_manual(
        name = "",
        values = fill_values,
        labels = fill_labels
      ) +
      ggplot2::scale_x_discrete(
        limits = rev(variable_levels),
        expand = c(0.03, 0)
      ) +
      ggplot2::scale_y_continuous(
        limits = c(0.5, nrow(df) + 0.5),
        expand = c(0, 0)
      ) +
      ggplot2::coord_flip() +
      ggplot2::labs(x = NULL, y = "Case Number") +
      theme_my() +
      ggplot2::theme(
        legend.position = if (show_legend) "right" else "none",
        panel.spacing = grid::unit(0, "pt"),
        plot.margin = plot_margin
      )

    if (!show_y_labels) {
      plot <- plot + ggplot2::theme(
        axis.text.y = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      )
    }

    plot
  }

  if (output == "percentage") {
    return(UtilsR::fmt_strip(
      build_percentage_plot(),
      label = "Percentage of Missing Values"
    ))
  }

  reverse <- output == "both_reverse"
  combined_output <- output %in% c("both", "both_reverse")
  matrix_gap_side <- if (combined_output) {
    if (reverse) "left" else "right"
  }

  matrix_plot <- build_matrix_plot(
    show_legend = output == "matrix",
    show_y_labels = output != "both_reverse",
    gap_side = matrix_gap_side
  )
  if (output == "matrix") {
    return(UtilsR::fmt_strip(
      matrix_plot,
      label = "Distribution of Missing Values"
    ))
  }

  percentage_plot <- build_percentage_plot(
    reverse = reverse,
    combined = TRUE,
    gap_side = if (reverse) "right" else "left"
  )

  if (reverse) {
    combined_plot <- patchwork::wrap_plots(
      percentage_plot,
      matrix_plot,
      ncol = 2
    )
    strip_labels <- c(
      "Percentage of Missing Values",
      "Distribution of Missing Values"
    )
  } else {
    combined_plot <- patchwork::wrap_plots(
      matrix_plot,
      percentage_plot,
      ncol = 2
    )
    strip_labels <- c(
      "Distribution of Missing Values",
      "Percentage of Missing Values"
    )
  }

  UtilsR::fmt_strip(combined_plot, label = strip_labels)
}
