# ============================================================================
# fmt_ci.R -- Format confidence intervals and mean(SD)
# ============================================================================

#' Format Confidence Intervals or Mean (SD)
#'
#' Build CI strings from numeric vectors, or reformat existing CI strings
#' with different brackets and separators. Automatically detects
#' CI mode (3 vectors) or SD mode (2 vectors) for numeric input.
#'
#' @param x Numeric vector (estimate/mean) or character vector (CI strings to reformat).
#' @param y Numeric vector: lower CI bound (CI mode) or SD (SD mode).
#'   Ignored when \code{x} is character.
#' @param z Numeric vector (optional): upper CI bound. If provided, CI mode
#'   is used; otherwise SD mode. Ignored when \code{x} is character.
#' @param digits Integer, number of decimal places (default: 2 for CI, 1 for SD).
#'   For character input, default is auto-detected from the string.
#' @param bracket Character, bracket type: \code{"("} (default) or \code{"["}.
#' @param sep Character, separator between CI bounds (default: en dash).
#'   Only used in CI mode. Common choices: \code{"\u2013"}, \code{", "}, \code{" to "}.
#'
#' @return Character vector of formatted strings.
#'
#' @examples
#' # --- Numeric: CI mode (3 arguments) ---
#' fmt_ci(1.23, 0.95, 1.51)
#' # "1.23 (0.95\u20131.51)"
#'
#' fmt_ci(1.23, 0.95, 1.51, bracket = "[", sep = " to ")
#' # "1.23 [0.95 to 1.51]"
#'
#' # --- Numeric: SD mode (2 arguments) ---
#' fmt_ci(1.23, 0.15)
#' # "1.2(0.2)"
#'
#' # --- Character: reformat CI strings ---
#' fmt_ci("1.23 (0.95, 1.59)", bracket = "[", sep = "\u2013")
#' # "1.23 [0.95\u20131.59]"
#'
#' fmt_ci("1.23 [0.95\u20131.59]", sep = " to ", bracket = "(")
#' # "1.23 (0.95 to 1.59)"
#'
#' # --- In mutate() ---
#' # df %>% mutate(ci = fmt_ci(est, ci_low, ci_high))
#' # df %>% mutate(ci_new = fmt_ci(ci_old, bracket = "["))
#'
#' @export
fmt_ci <- function(x, y = NULL, z = NULL,
                   digits = NULL,
                   bracket = c("(", "["),
                   sep = c("\u2013", ", ", " to ")) {
  bracket <- match.arg(bracket)
  sep <- match.arg(sep)
  bp <- if (bracket == "(") c("(", ")") else c("[", "]")

  # --- Character input: reformat CI strings ---
  if (is.character(x)) {
    parsed <- .ci_extract(x)
    est <- parsed$estimate
    lo  <- parsed$lower
    hi  <- parsed$upper
    d   <- if (!is.null(digits)) rep(as.integer(digits), length(x)) else parsed$digits
    valid <- parsed$valid

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
  fmt <- sprintf("%%.%df%s%%.%df%s", d, bp[1], d, bp[2])
  sprintf(fmt, x, y)
}
