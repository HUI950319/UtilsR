# ============================================================================
# stat_cohen.R -- Cohen's d effect size calculation
# ============================================================================

#' Compute Cohen's d Effect Size by Group
#'
#' Calculate Cohen's d for each variable across groups, comparing each group
#' to the overall sample. Supports continuous and categorical (one-hot encoded)
#' variables.
#'
#' @param data A data frame.
#' @param group Character, name of the grouping variable (factor).
#' @param vars Character vector of variable names to compare.
#' @param onehot Logical. If \code{TRUE} (default), categorical variables
#'   are one-hot encoded before computing Cohen's d.
#' @param col_labels Optional named character vector for renaming variables
#'   in the output (e.g. \code{c(age = "Age (years)")}).
#'
#' @return A data frame with columns: \code{Variable} and one column per
#'   group level, containing Cohen's d values.
#'
#' @note Requires the \pkg{effsize} package. For one-hot encoding,
#'   \pkg{fastDummies} is also needed.
#'
#' @examples
#' # Basic: continuous variables
#' stat_cohen(iris, group = "Species",
#'            vars = c("Sepal.Length", "Sepal.Width"))
#'
#' # With column label mapping
#' stat_cohen(iris, group = "Species",
#'            vars = c("Sepal.Length", "Sepal.Width"),
#'            col_labels = c(Sepal.Length = "Sepal L.", Sepal.Width = "Sepal W."))
#'
#' # Mixed variables with one-hot encoding
#' df <- data.frame(
#'   group = factor(sample(c("A","B","C"), 100, TRUE)),
#'   age = rnorm(100, 50, 10),
#'   sex = factor(sample(c("M","F"), 100, TRUE)),
#'   stage = factor(sample(c("I","II","III"), 100, TRUE))
#' )
#' stat_cohen(df, group = "group", vars = c("age", "sex", "stage"))
#'
#' # Without one-hot (numeric variables only)
#' stat_cohen(df, group = "group", vars = "age", onehot = FALSE)
#'
#' @export
#' @family statistics
stat_cohen <- function(data, group, vars,
                       onehot = TRUE,
                       col_labels = NULL) {

  if (!requireNamespace("effsize", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg effsize} is required. Install with: {.code install.packages('effsize')}")
  }
  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  if (!group %in% names(data)) cli::cli_abort("Column {.val {group}} not found.")
  missing_v <- vars[!vars %in% names(data)]
  if (length(missing_v) > 0) cli::cli_abort("Variable{?s} not found: {.val {missing_v}}")

  # Ensure group is factor
  if (!is.factor(data[[group]])) data[[group]] <- factor(data[[group]])

  # Select columns
  d <- data[, c(group, vars), drop = FALSE]

  # Apply column labels
  if (!is.null(col_labels)) {
    for (old_nm in names(col_labels)) {
      if (old_nm %in% names(d)) names(d)[names(d) == old_nm] <- col_labels[old_nm]
    }
    group <- names(d)[1]
    vars <- names(d)[-1]
  }

  # One-hot encode categoricals
  if (onehot) {
    factor_vars <- vars[vapply(d[vars], is.factor, logical(1))]
    if (length(factor_vars) > 0) {
      if (!requireNamespace("fastDummies", quietly = TRUE)) {
        cli::cli_abort("Package {.pkg fastDummies} is required for one-hot encoding.")
      }
      two_level <- factor_vars[vapply(d[factor_vars], nlevels, integer(1)) == 2L]
      multi_level <- setdiff(factor_vars, two_level)
      if (length(two_level) > 0) {
        d <- fastDummies::dummy_cols(d, select_columns = two_level,
                                    remove_selected_columns = TRUE,
                                    remove_first_dummy = TRUE)
      }
      if (length(multi_level) > 0) {
        d <- fastDummies::dummy_cols(d, select_columns = multi_level,
                                    remove_selected_columns = TRUE,
                                    remove_first_dummy = FALSE)
      }
      vars <- setdiff(names(d), group)
    }
  }

  # Convert remaining factors to numeric
  for (v in vars) {
    if (is.factor(d[[v]])) d[[v]] <- as.numeric(d[[v]])
  }

  # Split by group
  grp_levels <- levels(d[[group]])
  grp_list <- split(d, d[[group]])

  # Compute Cohen's d for each variable × group
  result <- data.frame(Variable = vars, stringsAsFactors = FALSE)
  for (gl in grp_levels) {
    result[[gl]] <- vapply(vars, function(v) {
      effsize::cohen.d(grp_list[[gl]][[v]], d[[v]],
                       pooled = TRUE, na.rm = TRUE)$estimate
    }, numeric(1))
  }

  result
}
