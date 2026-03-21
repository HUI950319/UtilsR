# ============================================================================
# na.R -- Data quality analysis (missing & special values)
# ============================================================================

#' Comprehensive Data Quality Analysis
#'
#' Analyze missing values and special values (e.g. "unknown", "blank", "n/a")
#' for each variable. Outputs a styled \code{gt} table with conditional
#' formatting based on severity.
#'
#' @param data A data.frame.
#' @param ... Variable selection using \code{dplyr::select} syntax.
#' @param pattern Optional regex pattern for matching variable names.
#' @param show_all Logical. If \code{FALSE} (default), only variables with
#'   issues are shown.
#'
#' @return Invisibly returns the input data.
#'
#' @examples
#' \donttest{
#' # Analyze all variables
#' na_check(airquality)
#'
#' # Select specific columns
#' na_check(airquality, Ozone, Solar.R)
#'
#' # Show all variables including those without issues
#' na_check(airquality, show_all = TRUE)
#' }
#'
#' @export
#' @family inspect
na_check <- function(data, ..., pattern = NULL, show_all = FALSE) {

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data.frame, not {.cls {class(data)}}.")
  }

  # Variable selection
  if (!is.null(pattern)) {
    vars <- names(data)[grepl(pattern, names(data))]
  } else {
    vars <- names(dplyr::select(data, ...))
  }
  if (length(vars) == 0) {
    if (!is.null(pattern)) {
      cli::cli_alert_warning(
        "\u672a\u627e\u5230\u5339\u914d\u6a21\u5f0f '{pattern}' \u7684\u53d8\u91cf\uff0c\u5c06\u5206\u6790\u6240\u6709\u53d8\u91cf"
      )
    }
    vars <- names(data)
  }
  data <- data[, vars, drop = FALSE]

  n_total <- nrow(data)

  .count_special_values <- function(x) {
    if (is.factor(x) || is.character(x)) {
      x_clean <- tolower(as.character(x))
      special_patterns <- c("unknown", "blank", "n/a", "na", "missing",
                            "unspecified", "not available")
      count <- 0
      for (p in special_patterns) {
        count <- count + sum(grepl(p, x_clean, fixed = TRUE), na.rm = TRUE)
      }
      count <- count + sum(x_clean == "", na.rm = TRUE)
      return(count)
    } else {
      0
    }
  }

  result_list <- list()

  for (var_name in names(data)) {
    var_data <- data[[var_name]]
    missing_count <- sum(is.na(var_data))
    special_count <- .count_special_values(var_data)

    result_list[[var_name]] <- data.frame(
      variable = var_name,
      missing_count = missing_count,
      missing_percentage = round((missing_count / n_total) * 100, 2),
      special_count = special_count,
      special_percentage = round((special_count / n_total) * 100, 2),
      data_type = class(var_data)[1],
      stringsAsFactors = FALSE
    )
  }

  res_na <- do.call(rbind, result_list)
  rownames(res_na) <- NULL

  res_na <- res_na %>%
    dplyr::mutate(
      missing_combined = sprintf("%d (%.1f%%)", missing_count, missing_percentage),
      special_combined = sprintf("%d (%.1f%%)", special_count, special_percentage),
      total_issues = missing_count + special_count
    )

  if (!show_all) {
    res_na <- res_na %>%
      dplyr::filter(total_issues > 0)
  }

  res_na <- res_na %>%
    dplyr::arrange(dplyr::desc(missing_count), dplyr::desc(special_count))

  if (nrow(res_na) == 0 && !show_all) {
    .cat_box("No missing values or special values found in the dataset!",
             type = "success")
    return(invisible(data))
  }

  total_missing_vars <- sum(res_na$missing_count > 0)
  total_special_vars <- sum(res_na$special_count > 0)

  gt_table <- res_na %>%
    dplyr::select(variable, missing_combined, special_combined, data_type) %>%
    gt::gt() %>%
    gt::tab_header(
      title = gt::md("**Missing & Special Value Analysis**"),
      subtitle = gt::md(sprintf(
        "Dataset: *%d* observations, *%d* variables, *%d* missing, *%d* Unknown/Blank/N/A",
        n_total, ncol(data), total_missing_vars, total_special_vars
      ))
    ) %>%
    gt::cols_label(
      variable = gt::md("**Variable**"),
      missing_combined = gt::md("**Missing**"),
      special_combined = gt::md("**Unknown/Blank/N/A**"),
      data_type = gt::md("**Data Type**")
    ) %>%
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) %>%
    gt::tab_style(
      style = gt::cell_text(align = "center"),
      locations = gt::cells_body(
        columns = c("missing_combined", "special_combined")
      )
    ) %>%
    gt::tab_options(
      column_labels.background.color = "#E8F4FD",
      table.font.size = gt::px(12),
      heading.background.color = "#F0F8FF"
    )

  if (nrow(res_na) > 0) {
    high_missing_rows <- which(res_na$missing_percentage > 50)
    medium_missing_rows <- which(
      res_na$missing_percentage > 20 & res_na$missing_percentage <= 50
    )
    low_missing_rows <- which(
      res_na$missing_percentage > 0 & res_na$missing_percentage <= 20
    )

    high_special_rows <- which(res_na$special_percentage > 30)
    medium_special_rows <- which(
      res_na$special_percentage > 10 & res_na$special_percentage <= 30
    )
    low_special_rows <- which(
      res_na$special_percentage > 0 & res_na$special_percentage <= 10
    )

    gt_table <- gt_table %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#ffebee"),
        locations = gt::cells_body(
          columns = c("variable", "data_type"),
          rows = high_missing_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#ffcdd2"),
        locations = gt::cells_body(
          columns = "missing_combined",
          rows = high_missing_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#fff3e0"),
        locations = gt::cells_body(
          columns = c("variable", "data_type"),
          rows = medium_missing_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#ffcc80"),
        locations = gt::cells_body(
          columns = "missing_combined",
          rows = medium_missing_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#fef9e7"),
        locations = gt::cells_body(
          columns = c("variable", "data_type"),
          rows = low_missing_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#fff176"),
        locations = gt::cells_body(
          columns = "missing_combined",
          rows = low_missing_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#e3f2fd"),
        locations = gt::cells_body(
          columns = "special_combined",
          rows = high_special_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#bbdefb"),
        locations = gt::cells_body(
          columns = "special_combined",
          rows = medium_special_rows
        )
      ) %>%
      gt::tab_style(
        style = gt::cell_fill(color = "#e1f5fe"),
        locations = gt::cells_body(
          columns = "special_combined",
          rows = low_special_rows
        )
      )
  }

  if (nrow(res_na) > 0) {
    total_missing <- sum(res_na$missing_count)
    total_special <- sum(res_na$special_count)
    overall_missing_pct <- round(
      (total_missing / (n_total * ncol(data))) * 100, 2
    )
    overall_special_pct <- round(
      (total_special / (n_total * ncol(data))) * 100, 2
    )

    gt_table <- gt_table %>%
      gt::tab_source_note(
        source_note = gt::md(sprintf(
          "**Summary:** %d missing values (%.2f%%), %d special values (%.2f%%) out of %d total data points",
          total_missing, overall_missing_pct,
          total_special, overall_special_pct,
          n_total * ncol(data)
        ))
      )
  }

  if (show_all) {
    .cat_line(
      sprintf("Data quality analysis: showing all %d variables", nrow(res_na)),
      type = "info"
    )
  } else {
    .cat_line(
      sprintf("Data quality analysis: %d variables with data quality issues",
              nrow(res_na)),
      type = "info"
    )
  }

  print(gt_table)

  invisible(data)
}

#' @rdname na_check
#' @export
na <- na_check
