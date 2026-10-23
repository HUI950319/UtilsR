# =============================================================================
# stat_ci.R -- Format confidence intervals and mean (SD)
# =============================================================================

#' Format Confidence Intervals or Mean (SD)
#'
#' Build CI strings from numeric vectors, or reformat existing CI strings
#' with different brackets and separators. Automatically detects
#' CI mode (3 vectors) or SD mode (2 vectors) for numeric input.
#'
#' @param x Numeric vector (estimate/mean) or character vector (CI strings to
#'   reformat). Trailing stars and a terminal period are ignored; other text
#'   after a parsed interval is dropped with a warning. Missing and
#'   whitespace-only strings pass through unchanged without a warning.
#' @param y Numeric vector: lower CI bound (CI mode) or SD (SD mode).
#'   Ignored when \code{x} is character.
#'   Numeric inputs must be one-dimensional; integer64, date, date-time and
#'   time-span storage are rejected instead of formatting their internal codes.
#' @param z Numeric vector (optional): upper CI bound. If provided, CI mode
#'   is used; otherwise SD mode. Ignored when \code{x} is character.
#' @param digits A single integer from 0 to 8190, giving the number of decimal
#'   places (default: 2 for CI, 1 for SD). For character input, default is
#'   auto-detected from the string. Each formatted number must fit within
#'   \code{sprintf()}'s 8192-byte limit, including its integer part and sign.
#' @param bracket Character, bracket type: \code{"("} (default) or \code{"["}.
#' @param sep Character, separator between CI bounds (default: en dash).
#'   Only used in CI mode. Common choices: \code{"\u2013"}, \code{", "}, \code{" to "}.
#'
#' @return Character vector of formatted strings. Empty input returns
#'   \code{character(0)}. In numeric modes, a missing component (including
#'   \code{NaN} and SPSS user-missing codes) makes the whole string
#'   \code{NA_character_}. Entirely missing logical vectors are accepted.
#'   Output names are taken from \code{x}. Rounded zeros are displayed without
#'   a minus sign; other rounding follows \code{sprintf()}.
#'
#' @examples
#' # --- Numeric: CI mode (3 arguments) ---
#' stat_ci(1.23, 0.95, 1.51)
#' # "1.23 (0.95\u20131.51)"
#'
#' stat_ci(1.23, 0.95, 1.51, bracket = "[", sep = " to ")
#' # "1.23 [0.95 to 1.51]"
#'
#' # --- Numeric: SD mode (2 arguments) ---
#' stat_ci(1.23, 0.15)
#' # "1.2(0.1)"
#'
#' # --- Character: reformat CI strings ---
#' stat_ci("1.23 (0.95, 1.59)", bracket = "[", sep = "\u2013")
#' # "1.23 [0.95\u20131.59]"
#'
#' stat_ci("1.23 [0.95\u20131.59]", sep = " to ", bracket = "(")
#' # "1.23 (0.95 to 1.59)"
#'
#' # --- In mutate() ---
#' # df %>% mutate(ci = stat_ci(est, ci_low, ci_high))
#' # df %>% mutate(ci_new = stat_ci(ci_old, bracket = "["))
#'
#' @export
#' @family stat formatting
stat_ci <- function(x, y = NULL, z = NULL,
                   digits = NULL,
                   bracket = c("(", "["),
                   sep = c("\u2013", ", ", " to ")) {
  bracket <- match.arg(bracket)
  sep <- match.arg(sep)
  bp <- if (bracket == "(") c("(", ")") else c("[", "]")
  input_names <- names(x)

  if (!is.null(digits)) {
    if (!is.numeric(digits) || is.object(digits) || !is.null(dim(digits)) ||
        length(digits) != 1L || !is.finite(digits) || digits < 0 ||
        digits %% 1 != 0 || digits > 8190L) {
      cli::cli_abort("{.arg digits} must be a single integer between 0 and 8190.")
    }
    digits <- as.integer(digits)
  }
  .check_precision <- function(d, ...) {
    if (any(!is.finite(d) | d < 0 | d > 8190L)) {
      cli::cli_abort("The detected {.arg digits} must be between 0 and 8190.")
    }
    if (any(d > 7881L)) {
      for (values in list(...)) {
        at <- which(is.finite(values) & d > 7881L)
        widths <- nchar(sprintf("%.0f", trunc(values[at])))
        if (any(widths + 1L + rep_len(d, length(values))[at] > 8192L)) {
          cli::cli_abort("{.arg digits} exceeds the 8192-byte limit for a formatted number.")
        }
      }
    }
  }
  .drop_signed_zero <- function(text) {
    gsub("-0(?=(?:\\.0+)?(?:[^0-9.]|$))", "0", text, perl = TRUE)
  }
  if (!is.null(dim(x))) cli::cli_abort("{.arg x} must be a vector, not a matrix or array.")
  if (!is.character(x)) {
    inputs <- list(x = x, y = y, z = z)
    for (arg in names(inputs)) {
      value <- inputs[[arg]]
      if (!is.null(dim(value))) {
        cli::cli_abort("{.arg {arg}} must be a vector, not a matrix or array.")
      }
      if (inherits(value, c("integer64", "Date", "POSIXt", "difftime",
                            "Duration", "Period", "Interval"))) {
        cli::cli_abort("{.arg {arg}} must use ordinary numeric values, not integer64, date, date-time, or time-span storage.")
      }
      if (inherits(value, "haven_labelled")) loadNamespace("labelled")
      if (is.logical(value) && all(is.na(value))) {
        inputs[[arg]] <- as.double(value)
      }
    }
    x <- inputs[["x"]]
    y <- inputs[["y"]]
    z <- inputs[["z"]]
  }

  # --- Character input: reformat CI strings ---
  if (is.character(x)) {
    if (!length(x)) return(stats::setNames(character(), input_names))
    parsed <- .ci_extract(x)
    est <- parsed$estimate
    lo  <- parsed$lower
    hi  <- parsed$upper
    d   <- if (!is.null(digits)) rep(as.integer(digits), length(x)) else parsed$digits
    valid <- parsed$valid
    .check_precision(d, est, lo, hi)

    # Warn about unparseable elements
    n_fail <- sum(!valid & !is.na(x) &
                    nzchar(trimws(x, whitespace = "[\\h\\v]")))
    if (n_fail > 0L) {
      cli::cli_warn("{n_fail} element{?s} could not be parsed as CI string{?s} and {?was/were} returned as-is.")
    }
    n_tail <- sum(parsed$trailing)
    if (n_tail > 0L) {
      cli::cli_warn("{n_tail} element{?s} had trailing text after the closing bracket, which was dropped.")
    }

    # Build new format template
    out <- ifelse(valid,
      mapply(function(e, l, h, dd) {
        fmt <- sprintf("%%.%df %s%%.%df%s%%.%df%s", dd, bp[1], dd, sep, dd, bp[2])
        sprintf(fmt, e, l, h)
      }, est, lo, hi, d, USE.NAMES = FALSE),
      x)
    out[valid] <- .drop_signed_zero(out[valid])
    names(out) <- input_names
    return(out)
  }

  # --- Numeric: CI mode (3 args) ---
  if (!is.null(z)) {
    if (!is.numeric(x) || !is.numeric(y) || !is.numeric(z)) {
      cli::cli_abort("All inputs must be numeric.")
    }
    n <- length(x)
    if (length(y) != n || length(z) != n) {
      cli::cli_abort("All vectors must have the same length.")
    }
    d <- digits %||% 2L
    observed <- !(is.na(x) | is.na(y) | is.na(z))
    out <- rep(NA_character_, n)
    .check_precision(d, x[observed], y[observed], z[observed])
    fmt <- sprintf("%%.%df %s%%.%df%s%%.%df%s", d, bp[1], d, sep, d, bp[2])
    out[observed] <- sprintf(fmt, x[observed], y[observed], z[observed])
    out[observed] <- .drop_signed_zero(out[observed])
    names(out) <- input_names
    return(out)
  }

  # --- Numeric: SD mode (2 args) ---
  if (is.null(y)) cli::cli_abort("At least 2 arguments required for numeric input.")
  if (!is.numeric(x) || !is.numeric(y)) {
    cli::cli_abort("All inputs must be numeric.")
  }
  if (length(x) != length(y)) {
    cli::cli_abort("All vectors must have the same length.")
  }
  d <- digits %||% 1L
  observed <- !(is.na(x) | is.na(y))
  out <- rep(NA_character_, length(x))
  .check_precision(d, x[observed], y[observed])
  fmt <- sprintf("%%.%df%s%%.%df%s", d, bp[1], d, bp[2])
  out[observed] <- sprintf(fmt, x[observed], y[observed])
  out[observed] <- .drop_signed_zero(out[observed])
  names(out) <- input_names
  out
}
