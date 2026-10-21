# =============================================================================
# na.R -- Data quality analysis for missing and special values
# =============================================================================

#' Comprehensive Data Quality Analysis
#'
#' Analyze missing values and special values (e.g. "unknown", "blank", "n/a")
#' for each variable. Outputs a styled \code{gt} table with conditional
#' formatting based on severity.
#'
#' @param data A data.frame with unique, non-empty column names. Selected
#'   columns must be one-dimensional. Grouped inputs are inspected across all
#'   rows, preserving the grouping in the returned input.
#' @param ... Variable selection using \code{dplyr::select} syntax. Omit to
#'   inspect all columns. Renaming changes only the displayed variable names.
#' @param pattern \code{NULL} or a single non-missing character string used
#'   as a regex pattern for matching variable names. Takes precedence over
#'   \code{...}. An empty string matches all columns. An unmatched pattern or
#'   selection inspects no columns and returns the input with an informational
#'   message.
#' @param show_all A single non-missing logical. If \code{FALSE} (default),
#'   only variables with issues are shown.
#'
#' @return Invisibly returns the complete input data unchanged, including
#'   columns that were not selected for inspection.
#'
#' @details Inputs with zero rows or zero columns return unchanged with an
#'   informational message and no table.
#'   Special-value counts apply to character and factor columns. Matching is
#'   case-insensitive and uses Unicode-aware whole-word markers after collapsing
#'   whitespace, including Unicode spaces. Whitespace-only strings count as
#'   blank values. Each value is counted once. Values recognized by
#'   \code{is.na()}, including SPSS user-missing codes, count only as missing
#'   values.
#'   Inspection loads methods for serialized haven-labelled and integer64
#'   columns before counting missing values. Integer64 columns require the
#'   optional \pkg{bit64} package.
#'   Dataset-size calculations use double precision, and counts are formatted
#'   as whole numbers without a 32-bit integer limit.
#'   Severity colors use unrounded percentages. Percentages are rounded only
#'   for display, to one decimal place in cells and two in the summary.
#'   Positive percentages below these display resolutions appear as
#'   \code{<0.1\%} in cells and \code{<0.01\%} in the summary; zeros retain
#'   their usual numeric format.
#'   The subtitle counts variables containing issues; the summary counts
#'   individual missing and special values across the selected columns.
#'
#' @examples
#' \donttest{
#' # Analyze all variables
#' check_na(airquality)
#'
#' # Select specific columns
#' check_na(airquality, Ozone, Solar.R)
#'
#' # Show all variables including those without issues
#' check_na(airquality, show_all = TRUE)
#' }
#'
#' @export
#' @family inspect
check_na <- function(data, ..., pattern = NULL, show_all = FALSE) {

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data.frame, not {.cls {class(data)}}.")
  }
  if (!is.logical(show_all) || length(show_all) != 1L || is.na(show_all)) {
    cli::cli_abort("{.arg show_all} must be a single non-missing logical.")
  }
  if (!is.null(pattern) &&
      (!is.character(pattern) || length(pattern) != 1L || is.na(pattern))) {
    cli::cli_abort("{.arg pattern} must be NULL or a single non-missing character string.")
  }
  if (anyNA(names(data)) || any(!nzchar(names(data))) ||
      anyDuplicated(names(data)) > 0L) {
    cli::cli_abort("{.arg data} must have unique, non-empty column names.")
  }
  input_data <- data

  # Variable selection
  if (!is.null(pattern)) {
    data <- data[, grepl(pattern, names(data)), drop = FALSE]
  } else if (...length() > 0L) {
    data <- dplyr::select(dplyr::ungroup(data), ...)
  }
  if (ncol(data) == 0L) {
    .cat_line("No variables selected for data quality analysis.", type = "info")
    return(invisible(input_data))
  }
  unsupported <- vapply(data, function(x) !is.null(dim(x)), logical(1))
  if (any(unsupported)) {
    cli::cli_abort(c(
      "Selected columns must be one-dimensional.",
      "x" = "Unsupported columns: {.val {names(data)[unsupported]}}."
    ))
  }

  n_total <- nrow(data)
  if (n_total == 0L) {
    .cat_line("No observations available for data quality analysis.", type = "info")
    return(invisible(input_data))
  }

  missing_count <- unlist(lapply(data, .count_missing_values),
                          use.names = FALSE)
  special_count <- unlist(lapply(data, .count_special_values), use.names = FALSE)
  res_na <- data.frame(
    variable = names(data),
    missing_count = missing_count,
    missing_percentage = (missing_count / n_total) * 100,
    special_count = special_count,
    special_percentage = (special_count / n_total) * 100,
    data_type = vapply(data, function(x) class(x)[1L], character(1)),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  format_pct <- function(x, digits) {
    fmt <- paste0("%.", digits, "f%%")
    text <- sprintf(fmt, x)
    text[x > 0 & x < 10^(-digits)] <- paste0("<", sprintf(fmt, 10^(-digits)))
    text
  }
  res_na <- res_na %>%
    dplyr::mutate(
      missing_combined = sprintf("%.0f (%s)", missing_count, format_pct(missing_percentage, 1L)),
      special_combined = sprintf("%.0f (%s)", special_count, format_pct(special_percentage, 1L)),
      total_issues = missing_count + special_count
    )

  if (!show_all) {
    res_na <- res_na %>%
      dplyr::filter(total_issues > 0)
  }

  res_na <- res_na %>%
    dplyr::arrange(dplyr::desc(missing_count), dplyr::desc(special_count))

  if (nrow(res_na) == 0) {
    .cat_box("No missing values or special values found in the dataset!",
             type = "success")
    return(invisible(input_data))
  }

  total_missing_vars <- sum(res_na$missing_count > 0)
  total_special_vars <- sum(res_na$special_count > 0)

  gt_table <- res_na %>%
    dplyr::select(variable, missing_combined, special_combined, data_type) %>%
    gt::gt() %>%
    gt::tab_header(
      title = gt::md("**Missing & Special Value Analysis**"),
      subtitle = gt::md(sprintf(
        paste0("Dataset: *%.0f* observations, *%.0f* variables, ",
               "*%.0f* variables with missing values, ",
               "*%.0f* variables with special values"),
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
      style = gt::cell_fill(color = "#90caf9"),
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
      style = gt::cell_fill(color = "#e3f2fd"),
      locations = gt::cells_body(
        columns = "special_combined",
        rows = low_special_rows
      )
    )

  total_missing <- sum(res_na$missing_count)
  total_special <- sum(res_na$special_count)
  n_points <- as.double(n_total) * ncol(data)
  overall_missing_pct <- (total_missing / n_points) * 100
  overall_special_pct <- (total_special / n_points) * 100

  gt_table <- gt_table %>%
    gt::tab_source_note(
      source_note = gt::md(sprintf(
        "**Summary:** %.0f missing values (%s), %.0f special values (%s) out of %.0f total data points",
        total_missing, format_pct(overall_missing_pct, 2L),
        total_special, format_pct(overall_special_pct, 2L),
        n_points
      ))
    )

  if (show_all) {
    .cat_line(
      sprintf("Data quality analysis: showing all %.0f variables", nrow(res_na)),
      type = "info"
    )
  } else {
    .cat_line(
      sprintf("Data quality analysis: %.0f variables with data quality issues",
              nrow(res_na)),
      type = "info"
    )
  }

  print(gt_table)

  invisible(input_data)
}


# Register supported serialized-vector methods before generic NA checks.
# Shared by check_na() and lv(), including their special-value counts.
.count_missing_values <- function(x) {
  if (inherits(x, "haven_labelled")) loadNamespace("labelled")
  if (inherits(x, "integer64") && !requireNamespace("bit64", quietly = TRUE)) {
    cli::cli_abort("Inspecting integer64 columns requires the {.pkg bit64} package.")
  }
  sum(is.na(x))
}

# Count the values of a factor / character vector that mark a missing or
# unknown entry ("Unknown", "N/A", "Blank(s)", an empty string, ...); used by
# check_na() and lv(). A pattern must match a whole word, so "Regional" or
# "Canada" do not count through "na", and a value holding several patterns
# counts once. Patterns are matched on the distinct values only and weighted
# by their counts after normalizing whitespace; whitespace-only values are
# blank. Values recognized by is.na() are missing, not special.
.count_special_values <- function(x) {
  if (!is.factor(x) && !is.character(x)) return(0L)
  if (is.factor(x)) {
    u <- levels(x)
    n <- tabulate(as.integer(x), nbins = length(u))
    observed <- n > 0L
    u <- u[observed]
    n <- n[observed]
  } else {
    u <- unique(x)
    n <- tabulate(match(x, u), nbins = length(u))
  }
  missing <- is.na(u)
  # Normalize only values holding whitespace and match caselessly, so values
  # such as identifiers are not copied, lowercased or trimmed with TRE.
  ws <- grepl("[\\h\\v]", u, perl = TRUE)
  u[ws] <- gsub("^ | $", "", gsub("[\\h\\v]+", " ", u[ws], perl = TRUE),
                perl = TRUE)
  special <- grepl(
    "(*UCP)\\b(unknown|blank|n/a|na|missing|unspecified|not available)\\b",
    u, ignore.case = TRUE, perl = TRUE
  ) | u %in% ""
  sum(n[special & !missing]) + 0
}
