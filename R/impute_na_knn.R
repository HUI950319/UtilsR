#' Impute Missing Values with Weighted K-Nearest Neighbours
#'
#' Impute missing values in mixed-type data with
#' \code{\link[VIM]{kNN}}. Labelled variables are temporarily converted to
#' factors for distance calculation, then restored with their original storage
#' type, variable label, value labels, and other attributes.
#'
#' @param data A data frame or tibble. Other data-frame subclasses are processed
#'   as plain data frames.
#' @param k A positive integer giving the number of nearest neighbours. Defaults
#'   to \code{5}. It must not exceed the number of observed donors in any
#'   variable being imputed.
#' @param verbose Logical. If \code{TRUE}, report the variables being imputed.
#'
#' @return A data frame with missing values imputed where possible. A tibble is
#'   returned when \code{data} is a tibble.
#'
#' @examples
#' dat <- data.frame(
#'   age = c(30, 40, NA, 60),
#'   group = factor(c("A", "B", "B", "A")),
#'   marker = c(1, 5, 5, 1)
#' )
#'
#' if (requireNamespace("VIM", quietly = TRUE)) {
#'   impute_na_knn(dat, k = 1, verbose = FALSE)
#' }
#'
#' @family inspect
#' @seealso \code{\link{check_na}()}
#' @export
impute_na_knn <- function(data, k = 5, verbose = TRUE) {
  if (!is.data.frame(data)) {
    cli::cli_abort(
      "{.arg data} must be a data frame, not {.cls {class(data)}}."
    )
  }
  if (!is.numeric(k) || length(k) != 1L || is.na(k) || !is.finite(k) ||
      k < 1 || k %% 1 != 0 || k > .Machine$integer.max) {
    cli::cli_abort("{.arg k} must be a single positive integer.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    cli::cli_abort(
      "{.arg verbose} must be either {.code TRUE} or {.code FALSE}."
    )
  }

  input_is_tibble <- inherits(data, "tbl_df")
  data_for_impute <- as.data.frame(data)
  vars_with_missing <- names(data_for_impute)[
    vapply(data_for_impute, anyNA, logical(1))
  ]
  if (length(vars_with_missing) == 0L) {
    if (verbose) {
      cli::cli_inform(
        "No missing values found; returning {.arg data} unchanged."
      )
    }
    return(data)
  }

  if (!requireNamespace("VIM", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg VIM} is required for KNN imputation.",
      "i" = "Install it with {.code install.packages('VIM')}."
    ))
  }

  donor_counts <- vapply(
    data_for_impute[vars_with_missing],
    function(x) sum(!is.na(x)),
    integer(1)
  )
  insufficient <- donor_counts < k
  if (any(insufficient)) {
    details <- paste(
      sprintf(
        "%s (%d)",
        names(donor_counts)[insufficient],
        donor_counts[insufficient]
      ),
      collapse = ", "
    )
    cli::cli_abort(c(
      "Not enough observed donors for {.code k = {as.integer(k)}}.",
      "x" = "Insufficient donors: {details}.",
      "i" = "Reduce {.arg k} or provide more observed values."
    ))
  }

  labelled_cols <- vapply(
    data_for_impute,
    inherits,
    logical(1),
    what = "haven_labelled"
  )
  labelled_original <- data_for_impute[labelled_cols]

  data_for_impute[labelled_cols] <- lapply(
    data_for_impute[labelled_cols],
    labelled::to_factor,
    levels = "values",
    sort_levels = "none"
  )

  weighted_mean <- function(x, weights, ...) {
    stats::weighted.mean(x, w = weights, na.rm = TRUE)
  }

  if (verbose) {
    cli::cli_inform(c(
      "Imputing {length(vars_with_missing)} variable(s) with weighted KNN.",
      "i" = "Using {.code k = {as.integer(k)}}."
    ))
  }

  result <- VIM::kNN(
    data = as.data.frame(data_for_impute),
    variable = vars_with_missing,
    k = as.integer(k),
    numFun = weighted_mean,
    weightDist = TRUE,
    imp_var = FALSE,
    trace = FALSE
  )

  for (var_name in names(labelled_original)) {
    values <- result[[var_name]]
    if (is.factor(values)) {
      values <- as.character(values)
    }

    values <- switch(
      typeof(labelled_original[[var_name]]),
      double = as.double(values),
      integer = as.integer(values),
      character = as.character(values)
    )
    original <- labelled_original[[var_name]]
    missing <- is.na(original)
    original[missing] <- values[missing]
    attributes(original) <- attributes(labelled_original[[var_name]])
    result[[var_name]] <- original
  }

  if (input_is_tibble) {
    result <- tibble::as_tibble(result)
  }

  result
}
