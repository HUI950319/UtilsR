# =============================================================================
# stat_ci.R -- Format confidence intervals and mean (SD)
# =============================================================================

#' Format Confidence Intervals or Mean (SD)
#'
#' Build CI strings from numeric vectors, or reformat existing CI strings
#' with different brackets and separators. Automatically detects
#' CI mode (3 vectors) or SD mode (2 vectors) for numeric input.
#'
#' @param x Numeric vector (estimate/mean) or character vector (CI strings to reformat).
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
#' @return Character vector of formatted strings.
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
#' # "1.2(0.2)"
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
    }
  }

  # --- Character input: reformat CI strings ---
  if (is.character(x)) {
    parsed <- .ci_extract(x)
    est <- parsed$estimate
    lo  <- parsed$lower
    hi  <- parsed$upper
    d   <- if (!is.null(digits)) rep(as.integer(digits), length(x)) else parsed$digits
    valid <- parsed$valid
    .check_precision(d, est, lo, hi)

    # Warn about unparseable elements
    n_fail <- sum(!valid)
    if (n_fail > 0L) {
      cli::cli_warn("{n_fail} element{?s} could not be parsed as CI string{?s} and {?was/were} returned as-is.")
    }

    # Build new format template
    out <- ifelse(valid,
      mapply(function(e, l, h, dd) {
        fmt <- sprintf("%%.%df %s%%.%df%s%%.%df%s", dd, bp[1], dd, sep, dd, bp[2])
        sprintf(fmt, e, l, h)
      }, est, lo, hi, d, USE.NAMES = FALSE),
      x)
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
    .check_precision(d, x, y, z)
    fmt <- sprintf("%%.%df %s%%.%df%s%%.%df%s", d, bp[1], d, sep, d, bp[2])
    return(sprintf(fmt, x, y, z))
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
  .check_precision(d, x, y)
  fmt <- sprintf("%%.%df%s%%.%df%s", d, bp[1], d, bp[2])
  sprintf(fmt, x, y)
}
