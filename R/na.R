# =============================================================================
# na.R -- Data quality analysis for missing and special values
# =============================================================================

#' Comprehensive Data Quality Analysis
#'
#' Analyze missing values and special values (e.g. "unknown", "blank", "n/a")
#' for each variable. Returns a styled \code{gt} table with conditional
#' formatting based on severity.
#'
#' @param data A data.frame with unique, non-empty column names. Selected
#'   columns must be one-dimensional. Grouped inputs are inspected across all
#'   rows.
#' @param ... Variable selection using \code{dplyr::select} syntax. Omit to
#'   inspect all columns. Renaming changes only the displayed variable names.
#' @param pattern \code{NULL} or a single non-missing character string used
#'   as a regex pattern for matching variable names. Takes precedence over
#'   \code{...}, with a warning when both are supplied; an invalid regular
#'   expression is an error. An empty string matches all columns. An
#'   unmatched pattern or selection inspects no columns and returns
#'   \code{NULL} with an informational message.
#' @param special \code{NULL} (default) for the built-in special-value markers,
#'   or a character vector of regular expressions that replaces them. Patterns
#'   are matched independently and case-insensitively, with a Unicode-aware
#'   \code{\\b}, anywhere in each whitespace-normalized value; anchor them with
#'   \code{^...$} or \code{\\b} as needed. A value matching multiple patterns
#'   counts once. \code{character(0)} counts no special values, and empty strings
#'   count only when a pattern matches them.
#' @param show_all A single non-missing logical. If \code{FALSE} (default),
#'   only variables with issues are shown.
#'
#' @return A \code{gt} table, returned visibly so that it prints in the console,
#'   renders in R Markdown, Quarto and pkgdown, and can be saved with
#'   \code{gt::gtsave()}. \code{NULL}, invisibly, when no table is produced:
#'   no selected columns, no rows, or no issues with \code{show_all = FALSE}.
#'
#' @details Inputs with zero rows or zero columns return \code{NULL} invisibly
#'   with an informational message and no table.
#'   Special-value counts apply to character and factor columns. Matching is
#'   case-insensitive and runs after collapsing whitespace, including Unicode
#'   spaces. The built-in markers are the whole words unknown(s), blank(s), n/a,
#'   na, missing, unspecified, not available, not applicable, not stated, not
#'   reported and null, values made only of ?, - or . characters, and empty or
#'   whitespace-only strings. A marker anywhere in a value counts it, so a
#'   category such as "Unknown primary site" counts as special; supply
#'   \code{special} to change the markers. Each value is counted once. Values
#'   recognized by \code{is.na()}, including SPSS user-missing codes, count only
#'   as missing values.
#'   Inspection loads methods for serialized haven-labelled and integer64
#'   columns before counting missing values. Integer64 columns require the
#'   optional \pkg{bit64} package.
#'   Dataset-size calculations use double precision, and counts are formatted
#'   as whole numbers without a 32-bit integer limit.
#'   Severity colors use unrounded percentages. Missing-value shading is
#'   yellow above 0\%, orange above 20\% and red above 50\%, and also tints
#'   the variable and type cells. Special-value shading deepens from light
#'   to dark blue above 0\%, 10\% and 30\%. A source note under the table
#'   repeats these thresholds. Percentages are rounded only
#'   for display, to one decimal place in cells and two in the summary.
#'   Positive percentages below these display resolutions appear as
#'   \code{<0.1\%} in cells and \code{<0.01\%} in the summary; zeros retain
#'   their usual numeric format.
#'   The subtitle counts variables containing issues; the summary counts
#'   individual missing and special values across the selected columns.
#'   Both summary percentages use every selected cell as the denominator,
#'   including columns that cannot hold special values.
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
check_na <- function(data, ..., pattern = NULL, special = NULL,
                     show_all = FALSE) {

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data.frame, not {.cls {class(data)}}.")
  }
  if (!is.logical(show_all) || !is.null(dim(show_all)) || length(show_all) != 1L || is.na(show_all)) {
    cli::cli_abort("{.arg show_all} must be a single non-missing logical.")
  }
  if (!is.null(pattern) &&
      (!is.character(pattern) || !is.null(dim(pattern)) || length(pattern) != 1L || is.na(pattern))) {
    cli::cli_abort("{.arg pattern} must be NULL or a single non-missing character string.")
  }
  if (!is.null(special) && (!is.character(special) || !is.null(dim(special)) || anyNA(special))) {
    cli::cli_abort("{.arg special} must be NULL or a character vector without missing values.")
  }
  invalid <- special[vapply(special, function(p) inherits(tryCatch(
    suppressWarnings(grepl(p, "", perl = TRUE)), error = function(e) e), "error"),
    logical(1))]
  if (length(invalid) > 0L) {
    cli::cli_abort(c("{.arg special} must hold valid regular expressions.",
                     "x" = "Invalid patterns: {.val {invalid}}."))
  }
  if (anyNA(names(data)) || any(!nzchar(names(data))) ||
      anyDuplicated(names(data)) > 0L) {
    cli::cli_abort("{.arg data} must have unique, non-empty column names.")
  }

  # Variable selection
  if (!is.null(pattern)) {
    if (...length() > 0L) {
      cli::cli_warn("{.arg pattern} takes precedence; the selection in {.arg ...} is ignored.")
    }
    matched <- tryCatch(suppressWarnings(grepl(pattern, names(data))),
                        error = function(e) e)
    if (inherits(matched, "error")) {
      cli::cli_abort(c("{.arg pattern} must be a valid regular expression.",
                       "x" = "{conditionMessage(matched)}"))
    }
    # Use positional column selection for data.table, without evaluating j in the data.
    data <- if (inherits(data, "data.table")) {
      data[, which(matched), with = FALSE, drop = FALSE]
    } else {
      data[, matched, drop = FALSE]
    }
  } else if (...length() > 0L) {
    data <- dplyr::select(dplyr::ungroup(data), ...)
  }
  if (ncol(data) == 0L) {
    pr_note("No variables selected for data quality analysis.")
    return(invisible(NULL))
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
    pr_note("No observations available for data quality analysis.")
    return(invisible(NULL))
  }

  counts <- vapply(data, function(x) {
    ordinary_factor <- is.factor(x) &&
      (identical(class(x), "factor") || identical(class(x), c("ordered", "factor")))
    if (!ordinary_factor) return(c(.count_missing_values(x), .count_special_values(x, special)))
    if (!is.null(special) && !length(special)) {
      codes <- unclass(x)
      return(c(if (anyNA(codes)) sum(is.na(codes)) else 0L, 0))
    }
    tally <- .factor_tally(x)
    c(length(x) - sum(tally$counts), .count_special_values(x, special, tally = tally))
  }, numeric(2L), USE.NAMES = FALSE)
  missing_count <- counts[1L, ]
  special_count <- counts[2L, ]
  rows <- if (show_all) {
    order(missing_count, special_count, decreasing = TRUE)
  } else {
    selected <- which(missing_count + special_count > 0)
    selected[order(missing_count[selected], special_count[selected], decreasing = TRUE)]
  }
  if (!length(rows)) {
    pr_head("check_na", "no missing or special values found", bg = "green")
    return(invisible(NULL))
  }
  missing_count <- missing_count[rows]
  special_count <- special_count[rows]
  res_na <- data.frame(
    variable = names(data)[rows],
    missing_count = missing_count,
    missing_percentage = (missing_count / n_total) * 100,
    special_count = special_count,
    special_percentage = (special_count / n_total) * 100,
    data_type = vapply(rows, function(i) class(data[[i]])[1L], character(1)),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  format_pct <- function(x, digits) {
    fmt <- paste0("%.", digits, "f%%")
    text <- sprintf(fmt, x)
    cutoff <- 10^(-digits)
    if (length(x) && max(x) > 0 && min(x) < cutoff)
      text[x > 0 & x < cutoff] <- paste0("<", sprintf(fmt, cutoff))
    text
  }
  total_missing_vars <- sum(res_na$missing_count > 0)
  total_special_vars <- sum(res_na$special_count > 0)

  display <- data.frame(
    variable = res_na$variable,
    missing_combined = sprintf("%.0f (%s)", missing_count, format_pct(res_na$missing_percentage, 1L)),
    special_combined = sprintf("%.0f (%s)", special_count, format_pct(res_na$special_percentage, 1L)),
    data_type = res_na$data_type,
    stringsAsFactors = FALSE
  )
  gt_table <- gt::gt(display) %>%
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

  shading_rows <- function(percent, limits) {
    if (!length(percent) || max(percent) == 0) return(list())
    bands <- findInterval(percent, c(0, limits), left.open = TRUE)
    rows <- which(bands > 0L)
    groups <- structure(4L - bands[rows], levels = c("high", "medium", "low"), class = "factor")
    split(rows, groups)
  }

  fill_cells <- function(table, rows, columns, color) {
    gt::tab_style(table,
      style = gt::cell_fill(color = color),
      locations = gt::cells_body(columns = dplyr::all_of(columns), rows = rows)
    )
  }
  missing_rows <- shading_rows(res_na$missing_percentage, c(20, 50))
  missing_fills <- c("#ffebee", "#fff3e0", "#fef9e7")
  count_fills <- c("#ffcdd2", "#ffcc80", "#fff176")
  for (i in which(lengths(missing_rows) > 0L)) {
    rows <- missing_rows[[i]]
    gt_table <- fill_cells(gt_table, rows, c("variable", "data_type"), missing_fills[i])
    gt_table <- fill_cells(gt_table, rows, "missing_combined", count_fills[i])
  }
  special_rows <- shading_rows(res_na$special_percentage, c(10, 30))
  special_fills <- c("#90caf9", "#bbdefb", "#e3f2fd")
  for (i in which(lengths(special_rows) > 0L)) {
    gt_table <- fill_cells(gt_table, special_rows[[i]], "special_combined", special_fills[i])
  }

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
    ) %>%
    gt::tab_source_note(
      source_note = gt::md(paste0(
        "**Shading:** missing values >0-20% yellow, >20-50% orange, >50% red; ",
        "special values >0-10%, >10-30%, >30% light to dark blue"
      ))
    )

  pr_head("check_na", if (show_all) {
    sprintf("showing all %.0f variables", nrow(res_na))
  } else {
    sprintf("%.0f variables with data quality issues", nrow(res_na))
  })

  gt_table
}


# Register supported serialized-vector methods before generic NA checks.
# Shared by check_na() and lv(), including their special-value counts.
.count_missing_values <- function(x) {
  if (inherits(x, "haven_labelled")) loadNamespace("labelled")
  if (inherits(x, "integer64") && !requireNamespace("bit64", quietly = TRUE)) {
    cli::cli_abort("Inspecting integer64 columns requires the {.pkg bit64} package.")
  }
  if (is.expression(x)) x <- as.list(x)
  ordinary_factor <- identical(class(x), "factor") || identical(class(x), c("ordered", "factor"))
  if ((!is.object(x) && !anyNA(x)) || (ordinary_factor && !anyNA(unclass(x)))) return(0L)
  sum(is.na(x))
}

# Count the values of a factor / character vector that mark a missing or
# unknown entry ("Unknown", "N/A", "Blanks", an empty string, ...); used by
# check_na() and lv(). A built-in marker must match a whole word, so
# "Regional" or "Canada" do not count through "na", and a value holding
# several markers counts once. Patterns are matched on the distinct values
# only and weighted by their counts after normalizing whitespace;
# whitespace-only values are blank. `special`, a character vector of regular
# expressions, replaces the built-in markers. Values recognized by is.na() are
# missing, not special.
.count_special_values <- function(x, special = NULL, tally = NULL, distinct = NULL) {
  if (!is.factor(x) && !is.character(x)) return(0L)
  if (!is.null(special) && length(special) == 0L) return(0)
  if (is.factor(x)) {
    tally <- tally %||% .factor_tally(x)
    u <- levels(x)
    if (length(tally$codes) != length(u)) u <- u[tally$codes]
    n <- tally$counts
  } else {
    # unique() may discard a character subclass before its is.na() is called.
    if (is.object(x)) {
      missing <- is.na(x)
      if (any(missing)) {
        x <- x[!missing]
        distinct <- NULL
      }
    }
    u <- distinct %||% unique(x)
    hit <- .is_special_value(u, special)
    if (!any(hit)) return(0)
    markers <- u[hit]
    if (length(markers) == length(u)) return(length(x) + 0)
    if (!is.object(x) && length(x) == length(u)) return(length(markers) + 0)
    return(sum(x %in% markers) + 0)
  }
  hit <- .is_special_value(u, special)
  if (!any(hit)) return(0)
  # Factor subclasses can declare missingness beyond absent integer codes.
  if (!identical(class(x), "factor") && !identical(class(x), c("ordered", "factor"))) {
    missing <- is.na(x)
    if (any(missing)) return(sum(tally$row_codes[!missing] %in% tally$codes[hit]) + 0)
  }
  sum(if (all(hit)) n else n[hit]) + 0
}

# Count observed factor codes in level order, including a coded NA level.
.factor_tally <- function(x) {
  k <- nlevels(x)
  row_codes <- as.integer(x)
  if (k > length(x)) {
    if (isFALSE(is.unsorted(row_codes, strictly = TRUE))) {
      return(list(codes = row_codes, counts = rep.int(1L, length(row_codes)), row_codes = row_codes))
    }
    if (length(row_codes) < 1024L) {
      distinct <- unique(row_codes)
      observed <- sort(distinct, na.last = NA)
      counts <- if (length(distinct) == length(row_codes)) rep.int(1L, length(observed)) else
        tabulate(match(row_codes, observed), nbins = length(observed))
      return(list(codes = observed, counts = counts, row_codes = row_codes))
    }
    ids <- vctrs::vec_group_id(row_codes)
    n_observed <- attr(ids, "n")
    if (n_observed == 1L) {
      code <- row_codes[1L]
      return(list(codes = if (is.na(code)) integer() else code,
                  counts = if (is.na(code)) integer() else length(row_codes), row_codes = row_codes))
    }
    unique_rows <- n_observed == length(row_codes)
    observed <- if (unique_rows) row_codes else unique(row_codes, nmax = n_observed)
    order_at <- order(observed, na.last = NA)
    counts <- if (unique_rows) rep.int(1L, length(order_at)) else
      tabulate(ids, nbins = length(observed))[order_at]
    return(list(codes = observed[order_at], counts = counts, row_codes = row_codes))
  }
  if (k && k == length(row_codes) && isTRUE(row_codes[1L] == 1L && row_codes[k] == k) &&
      isFALSE(is.unsorted(row_codes, strictly = TRUE))) {
    return(list(codes = row_codes, counts = rep.int(1L, k), row_codes = row_codes))
  }
  counts <- tabulate(row_codes, nbins = k)
  if (!k || min(counts) > 0L) {
    return(list(codes = seq_len(k), counts = counts, row_codes = row_codes))
  }
  observed <- which(counts > 0L)
  list(codes = observed, counts = counts[observed], row_codes = row_codes)
}

# Whether each distinct value is a special marker under the rules of
# .count_special_values(); lv() also highlights its table levels with it.
.is_special_value <- function(u, special = NULL) {
  if (!length(u) || (!is.null(special) && !length(special))) return(rep(FALSE, length(u)))
  # Normalize only values holding whitespace and match caselessly, so values
  # such as identifiers are not copied, lowercased or trimmed with TRE.
  ws <- grep("[\\h\\v]", u, perl = TRUE)
  if (length(ws)) {
    u[ws] <- gsub("^ | $", "", gsub("[\\h\\v]+", " ", u[ws], perl = TRUE),
                  perl = TRUE)
  }
  if (is.null(special)) {
    grepl(paste0("(*UCP)\\b(unknowns?|blanks?|n/a|na|missing|unspecified|",
                 "not (available|applicable|stated|reported)|null)\\b|^[?.-]*$"),
          u, ignore.case = TRUE, perl = TRUE)
  } else {
    # Keep capture groups, leading directives and comments local to each pattern.
    present <- if (anyNA(u)) which(!is.na(u))
    values <- if (is.null(present)) u else u[present]
    if (!length(values)) return(rep(FALSE, length(u)))
    hit <- grepl(paste0("(*UCP)", special[[1L]]), values, ignore.case = TRUE, perl = TRUE)
    if (length(special) > 1L) {
      remaining <- if (any(hit)) which(!hit) else seq_along(values)
      # Reuse the unmatched strings until a pattern actually removes rows.
      remaining_values <- if (length(remaining) == length(values)) values else values[remaining]
      n_patterns <- length(special)
      for (i in seq.int(2L, n_patterns)) {
        if (!length(remaining)) break
        matched <- grepl(paste0("(*UCP)", special[[i]]), remaining_values,
                         ignore.case = TRUE, perl = TRUE)
        if (any(matched)) {
          hit[remaining[matched]] <- TRUE
          if (i == n_patterns) break
          keep <- !matched
          remaining <- remaining[keep]
          remaining_values <- remaining_values[keep]
        }
      }
    }
    if (is.null(present)) return(hit)
    out <- logical(length(u))
    out[present] <- hit
    out
  }
}
