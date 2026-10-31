# =============================================================================
# impute_na_knn.R -- Impute missing values with weighted k-nearest neighbours
# =============================================================================

#' Impute Missing Values with Weighted K-Nearest Neighbours
#'
#' Impute missing values in mixed-type data with
#' \code{\link[VIM]{kNN}}. Labelled variables are temporarily converted to
#' factors for distance calculation, then restored with their original storage
#' type, variable label, value labels, and other attributes.
#' SPSS user-missing codes are treated as missing rather than donor categories.
#' Labelled donor values are restored through their original category values,
#' without parsing rounded printed numbers.
#' Stored integer64 columns require \pkg{bit64}. When imputation is needed,
#' their observed values must be within +/-\code{2^53} for exact numeric
#' conversion. Imputed values are converted back to integer64 storage, with
#' fractional parts truncated.
#' VIM's distance weights and aggregation rules are retained. Degenerate
#' weights use equal weights for the selected neighbours. Wholly missing rows
#' are retained without imputation, and remaining missing values are reported.
#' Infinite numeric input is rejected when imputation is needed.
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
#' if (requireNamespace("VIM", quietly = TRUE) &&
#'     requireNamespace("ToyData", quietly = TRUE)) {
#'   oc_imputed <- impute_na_knn(ToyData::oc, k = 5, verbose = FALSE)
#'   utils::head(oc_imputed[, c("age", "BMI", "CA125")])
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
  integer64_cols <- vapply(data_for_impute, inherits, logical(1), what = "integer64")
  if (any(integer64_cols) && !requireNamespace("bit64", quietly = TRUE)) {
    cli::cli_abort("Inspecting integer64 columns requires package {.pkg bit64}.")
  }
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
  integer64_original <- data_for_impute[integer64_cols]
  for (var_name in names(integer64_original)) {
    x <- integer64_original[[var_name]]
    limit <- bit64::as.integer64("9007199254740992")
    if (any(x > limit | x < -limit, na.rm = TRUE)) {
      cli::cli_abort("Column {.val {var_name}} contains integer64 values beyond exact double precision; convert it explicitly before KNN imputation.")
    }
    data_for_impute[[var_name]] <- suppressWarnings(as.double(x))
  }

  data_for_impute[labelled_cols] <- lapply(
    data_for_impute[labelled_cols],
    labelled::to_factor,
    levels = "values",
    sort_levels = "none",
    user_na_to_na = TRUE
  )
  labelled_lookup <- list()
  for (var_name in names(labelled_original)) {
    original <- labelled_original[[var_name]]
    raw <- vctrs::vec_data(original)
    categories <- data_for_impute[[var_name]]
    values <- unique(raw[!is.na(original)])
    level_ids <- as.integer(categories)[match(values, raw)]
    if (anyDuplicated(level_ids)) {
      values <- values[order(level_ids)]
      codes <- match(raw, values)
      codes[is.na(original)] <- NA_integer_
      labels <- if (is.double(values)) sprintf("%.17g", values) else as.character(values)
      categories <- factor(codes, levels = seq_along(values), labels = labels)
      data_for_impute[[var_name]] <- categories
    }
    labelled_lookup[[var_name]] <- raw[match(seq_len(nlevels(categories)), as.integer(categories))]
  }

  non_finite <- vapply(data_for_impute, function(x) {
    is.numeric(x) && any(!is.finite(x) & !is.na(x))
  }, logical(1))
  if (any(non_finite)) {
    cli::cli_abort("KNN requires finite numeric observations; infinite values found in {.val {names(data_for_impute)[non_finite]}}.")
  }

  distance_weights <- function(weights) {
    if (!is.null(weights) && (!all(is.finite(weights)) || !any(weights > 0))) {
      weights <- rep(1, length(weights))
    }
    weights
  }
  weighted_mean <- function(x, weights = NULL, ...) {
    if (is.null(weights)) return(mean(x, na.rm = TRUE))
    stats::weighted.mean(x, w = distance_weights(weights), na.rm = TRUE)
  }
  weighted_category <- function(x, weights = NULL) {
    VIM::maxCat(x, weights = distance_weights(weights))
  }
  weighted_ordered <- function(x, weights = NULL) {
    VIM::medianSamp(x, weights = distance_weights(weights))
  }

  if (verbose) {
    cli::cli_inform(c(
      "Imputing {length(vars_with_missing)} variable(s) with weighted KNN.",
      "i" = "Using {.code k = {as.integer(k)}}."
    ))
  }

  backend_names <- paste0(".knn_", seq_along(data_for_impute))
  observed_rows <- rowSums(is.na(data_for_impute)) < ncol(data_for_impute)
  backend_data <- data_for_impute[observed_rows, , drop = FALSE]
  names(backend_data) <- backend_names
  backend_variables <- backend_names[vapply(backend_data, anyNA, logical(1))]
  result <- if (length(backend_variables)) withCallingHandlers(
    VIM::kNN(
      data = backend_data,
      variable = backend_variables,
      k = as.integer(k),
      numFun = weighted_mean,
      catFun = weighted_category,
      ordFun = weighted_ordered,
      weightDist = TRUE,
      useImputedDist = TRUE,
      methodStand = "range",
      imp_var = FALSE,
      trace = FALSE
    ),
    warning = function(w) {
      if (identical(conditionCall(w), quote(min(x[x > 0])))) invokeRestart("muffleWarning")
    }
  ) else backend_data
  names(result) <- names(data_for_impute)
  if (any(!observed_rows)) {
    expanded <- data_for_impute
    for (var_name in names(result)) expanded[[var_name]][observed_rows] <- result[[var_name]]
    result <- expanded
  }

  for (var_name in names(labelled_original)) {
    values <- result[[var_name]]
    codes <- if (is.factor(values)) as.integer(values) else
      match(as.character(values), levels(data_for_impute[[var_name]]))
    values <- labelled_lookup[[var_name]][codes]
    original <- labelled_original[[var_name]]
    missing <- is.na(original)
    original[missing] <- values[missing]
    attributes(original) <- attributes(labelled_original[[var_name]])
    result[[var_name]] <- original
  }
  for (var_name in names(integer64_original)) {
    original <- integer64_original[[var_name]]
    missing <- is.na(original)
    original[missing] <- bit64::as.integer64(result[[var_name]][missing])
    attributes(original) <- attributes(integer64_original[[var_name]])
    result[[var_name]] <- original
  }
  remaining <- vapply(result[vars_with_missing], function(x) sum(is.na(x)), numeric(1))
  if (any(remaining > 0)) {
    cli::cli_warn("KNN left {sum(remaining)} missing value(s) in {.val {names(remaining)[remaining > 0]}} because usable predictor information was unavailable.")
  }

  if (input_is_tibble) {
    result <- tibble::as_tibble(result)
  }

  result
}
