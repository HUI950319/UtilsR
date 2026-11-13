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
#' Labelled missingness is interpreted even when \pkg{haven} has not been loaded.
#' Labelled donor values are restored through their original category values,
#' without parsing rounded printed numbers.
#' Stored integer64 columns require \pkg{bit64}. When imputation is needed,
#' their observed values must be within +/-\code{2^53} for exact numeric
#' conversion. Imputed values are converted back to integer64 storage, with
#' fractional parts truncated.
#' Ordinary integer columns also retain truncation toward zero when converting
#' their weighted means back to integer storage.
#' VIM's distance weights and aggregation rules are retained. Degenerate
#' weights use equal weights for the selected neighbours. Wholly missing rows
#' are retained without imputation, and remaining missing values are reported.
#' Infinite numeric input is rejected when imputation is needed.
#' Dates, date-times, time differences and durations use numeric distances
#' and retain their original classes, time zones and units. Calendar periods
#' and intervals, complex vectors and raw vectors require explicit conversion
#' before imputation.
#'
#' @param data A data frame or tibble. Other data-frame subclasses are processed
#'   as plain data frames. Columns must have unique, non-missing, non-empty
#'   names and one-dimensional atomic storage (date-time vectors may also
#'   use POSIXlt storage). At least one predictor column is needed for imputation.
#' @param k A positive integer giving the number of nearest neighbours. Defaults
#'   to \code{5}. It must not exceed the number of observed donors in any
#'   variable being imputed.
#' @param verbose Logical. If \code{TRUE}, report the variables being imputed.
#'
#' @details Numeric variables use distance-weighted means. If a weighted sum
#'   overflows, finite donor values are rescaled before averaging to keep the
#'   imputed mean finite. Labelled variables
#'   retain categorical treatment, and VIM's categorical and ordered
#'   aggregators are retained for ordinary finite weights. Previously imputed
#'   values participate in subsequent distance calculations, so column order
#'   can affect results. Categorical tie breaking uses R's random number
#'   generator; call \code{set.seed()} before imputation when needed.
#'
#' @return A data frame with missing values imputed where possible. A tibble is
#'   returned when \code{data} is a tibble. Observation order and data-frame row
#'   names are retained.
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
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data))) {
    cli::cli_abort("{.arg data} must have unique, non-missing, non-empty column names.")
  }
  if (!is.numeric(k) || is.object(k) || length(k) != 1L || !is.null(dim(k)) || is.na(k) || !is.finite(k) ||
      k < 1 || k %% 1 != 0 || k > .Machine$integer.max) {
    cli::cli_abort("{.arg k} must be a single positive integer.")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || !is.null(dim(verbose)) || is.na(verbose)) {
    cli::cli_abort(
      "{.arg verbose} must be either {.code TRUE} or {.code FALSE}."
    )
  }

  input_is_tibble <- inherits(data, "tbl_df")
  input_is_data_table <- inherits(data, "data.table")
  data_for_impute <- if (input_is_data_table) data else as.data.frame(data)
  supported <- vapply(data_for_impute, function(x) {
    is.null(dim(x)) && ((!is.list(x) && !is.expression(x)) || inherits(x, "POSIXlt"))
  }, logical(1))
  if (!all(supported)) {
    cli::cli_abort("Columns must be one-dimensional atomic vectors; unsupported columns: {.val {names(data_for_impute)[!supported]}}.")
  }
  integer64_cols <- vapply(data_for_impute, inherits, logical(1), what = "integer64")
  if (any(integer64_cols) && !requireNamespace("bit64", quietly = TRUE)) {
    cli::cli_abort("Inspecting integer64 columns requires package {.pkg bit64}.")
  }
  time_methods <- vapply(data_for_impute, inherits, logical(1), what = c("Duration", "Period", "Interval"))
  if (any(time_methods) && !requireNamespace("lubridate", quietly = TRUE)) {
    cli::cli_abort("Inspecting time-span columns requires package {.pkg lubridate}.")
  }
  labelled_cols <- vapply(data_for_impute, inherits, logical(1), what = "haven_labelled")
  if (any(labelled_cols) && !requireNamespace("haven", quietly = TRUE)) {
    cli::cli_abort("Inspecting labelled columns requires package {.pkg haven}.")
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
  if (input_is_data_table) data_for_impute <- as.data.frame(data_for_impute)
  if (ncol(data_for_impute) < 2L) {
    cli::cli_abort("KNN imputation needs at least one predictor column in addition to the variable being imputed.")
  }
  unsupported <- vapply(data_for_impute, function(x) {
    inherits(x, c("Period", "Interval")) ||
      (!typeof(x) %in% c("logical", "integer", "double", "character") && !inherits(x, "POSIXlt"))
  }, logical(1))
  if (any(unsupported)) {
    cli::cli_abort("Columns {.val {names(data_for_impute)[unsupported]}} use unsupported storage or calendar spans; convert them explicitly before KNN imputation.")
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
  time_cols <- vapply(data_for_impute, inherits, logical(1), what = c("Date", "POSIXt", "difftime", "Duration"))
  time_original <- data_for_impute[time_cols]
  for (var_name in names(time_original)) {
    x <- time_original[[var_name]]
    data_for_impute[[var_name]] <- if (inherits(x, "POSIXlt")) as.double(as.POSIXct(x)) else as.double(x)
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
    weights <- distance_weights(weights)
    value <- if (is.null(weights)) mean(x, na.rm = TRUE) else
      stats::weighted.mean(x, w = weights, na.rm = TRUE)
    if ((!is.finite(value) || abs(value) <= .Machine$double.xmin) &&
        length(x) && all(is.finite(x))) {
      scale <- max(abs(x))
      if (!is.finite(value) || (scale > 0 && scale < .Machine$double.xmin)) {
        # Preserve ordinary means and integer truncation outside extreme scales.
        scaled <- if (is.null(weights)) mean(x / scale, na.rm = TRUE) else
          stats::weighted.mean(x / scale, w = weights, na.rm = TRUE)
        # Roundoff must not push the scaled mean beyond the finite donor bound.
        value <- max(-1, min(1, scaled)) * scale
      }
    }
    if (is.integer(x)) as.integer(value) else value
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

  factor_na <- vapply(data_for_impute, function(x) {
    is.factor(x) && anyNA(levels(x))
  }, logical(1))
  factor_na_original <- data_for_impute[factor_na]
  for (var_name in names(factor_na_original)) {
    x <- factor_na_original[[var_name]]
    attr(x, "levels") <- paste0(".knn_level_", seq_len(nlevels(x)))
    data_for_impute[[var_name]] <- x
  }

  backend_names <- paste0(".knn_", seq_along(data_for_impute))
  complete_columns <- setdiff(names(data_for_impute), vars_with_missing)
  observed_rows <- if (length(complete_columns) &&
                       !anyNA(data_for_impute[[complete_columns[[1L]]]])) {
    rep(TRUE, nrow(data_for_impute))
  } else {
    observed <- rep(FALSE, nrow(data_for_impute))
    for (column in data_for_impute) {
      observed <- observed | !is.na(column)
      if (all(observed)) break
    }
    observed
  }
  backend_data <- if (all(observed_rows)) data_for_impute else
    data_for_impute[observed_rows, , drop = FALSE]
  names(backend_data) <- backend_names
  backend_scales <- rep(1, ncol(backend_data))
  backend_centers <- rep(0, ncol(backend_data))
  for (j in seq_along(backend_data)) {
    values <- backend_data[[j]]
    if (!is.numeric(values)) next
    bounds <- range(values, na.rm = TRUE)
    if (all(is.finite(bounds)) && !is.finite(diff(bounds))) {
      backend_scales[j] <- max(abs(bounds))
      backend_data[[j]] <- values / backend_scales[j]
    } else if (is.double(values) && !is.object(values) && all(is.finite(bounds)) &&
               diff(bounds) > 0 && max(abs(bounds)) / diff(bounds) > 1 / sqrt(.Machine$double.eps)) {
      # Center before the backend divides by range and subtracts distances.
      backend_centers[j] <- bounds[1L]
      backend_data[[j]] <- values - backend_centers[j]
    }
  }
  backend_variables <- backend_names[vapply(backend_data, anyNA, logical(1))]
  backend_args <- list(
    data = backend_data, variable = backend_variables, k = as.integer(k),
    numFun = weighted_mean, catFun = weighted_category, weightDist = TRUE,
    useImputedDist = TRUE, imp_var = FALSE, trace = FALSE
  )
  backend_formals <- names(formals(VIM::kNN))
  if ("ordFun" %in% backend_formals) backend_args$ordFun <- weighted_ordered
  if ("methodStand" %in% backend_formals) backend_args$methodStand <- "range"
  result <- if (length(backend_variables)) withCallingHandlers(
    do.call(VIM::kNN, backend_args),
    warning = function(w) {
      if (identical(conditionCall(w), quote(min(x[x > 0])))) invokeRestart("muffleWarning")
    }
  ) else backend_data
  for (j in which(backend_scales != 1 | backend_centers != 0)) {
    original <- data_for_impute[[j]][observed_rows]
    missing <- is.na(original)
    original[missing] <- result[[j]][missing] * backend_scales[j] + backend_centers[j]
    result[[j]] <- original
  }
  names(result) <- names(data_for_impute)
  if (any(!observed_rows)) {
    expanded <- data_for_impute
    for (var_name in names(result)) expanded[[var_name]][observed_rows] <- result[[var_name]]
    result <- expanded
  }

  for (var_name in names(factor_na_original)) {
    original <- factor_na_original[[var_name]]
    missing <- is.na(original)
    codes <- match(as.character(result[[var_name]][missing]), levels(data_for_impute[[var_name]]))
    restored <- as.integer(original)
    restored[missing] <- codes
    attributes(restored) <- attributes(original)
    result[[var_name]] <- restored
  }
  for (var_name in names(labelled_original)) {
    original <- labelled_original[[var_name]]
    missing <- is.na(original)
    if (any(missing)) {
      values <- result[[var_name]][missing]
      codes <- if (is.factor(values)) as.integer(values) else
        match(as.character(values), levels(data_for_impute[[var_name]]))
      original[missing] <- labelled_lookup[[var_name]][codes]
      attributes(original) <- attributes(labelled_original[[var_name]])
    }
    result[[var_name]] <- original
  }
  for (var_name in names(integer64_original)) {
    original <- integer64_original[[var_name]]
    missing <- is.na(original)
    original[missing] <- bit64::as.integer64(result[[var_name]][missing])
    attributes(original) <- attributes(integer64_original[[var_name]])
    result[[var_name]] <- original
  }
  for (var_name in names(time_original)) {
    original <- time_original[[var_name]]
    missing <- is.na(original)
    if (!any(missing)) {
      result[[var_name]] <- original
      next
    }
    values <- result[[var_name]][missing]
    if (inherits(original, "Date")) {
      values <- as.Date(values, origin = "1970-01-01")
    } else if (inherits(original, "POSIXt")) {
      tz <- attr(original, "tzone")
      tz <- if (length(tz)) tz[1] else ""
      values <- as.POSIXct(values, origin = "1970-01-01", tz = tz)
      if (inherits(original, "POSIXlt")) values <- as.POSIXlt(values, tz = tz)
    } else if (inherits(original, "difftime")) {
      values <- as.difftime(values, units = attr(original, "units"))
    } else {
      values <- lubridate::duration(values)
    }
    original[missing] <- values
    attributes(original) <- attributes(time_original[[var_name]])
    result[[var_name]] <- original
  }
  remaining <- vapply(result[vars_with_missing], function(x) sum(is.na(x)), numeric(1))
  if (any(remaining > 0)) {
    cli::cli_warn("KNN left {sum(remaining)} missing value(s) in {.val {names(remaining)[remaining > 0]}} because usable predictor information was unavailable.")
  }

  if (input_is_tibble) {
    result <- tibble::as_tibble(result)
  } else if (!identical(rownames(result), rownames(data_for_impute))) {
    rownames(result) <- rownames(data_for_impute)
  }

  result
}
