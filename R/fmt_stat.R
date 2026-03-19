# ============================================================================
# fmt_stat.R -- Format statistics (CI and mean±SD)
# ============================================================================

#' Format Confidence Intervals or Mean (SD)
#'
#' Combines numeric vectors into formatted strings. Automatically detects
#' CI mode (3 vectors) or SD mode (2 vectors).
#'
#' @param x Numeric vector: point estimate (CI mode) or mean (SD mode).
#' @param y Numeric vector: lower CI bound (CI mode) or SD (SD mode).
#' @param z Numeric vector (optional): upper CI bound. If provided, CI mode
#'   is used; otherwise SD mode.
#' @param digits Integer, number of decimal places (default: 2 for CI, 1 for SD).
#' @param bracket Character, bracket type: \code{"("} (default) or \code{"["}.
#' @param sep Character, separator between CI bounds (default: en dash).
#'   Only used in CI mode. Common choices: \code{"\u2013"}, \code{", "}, \code{" to "}.
#'
#' @return Character vector of formatted strings.
#'
#' @examples
#' # --- CI mode (3 arguments) ---
#' fmt_stat(1.23, 0.95, 1.51)
#' # "1.23 (0.95\u20131.51)"
#'
#' fmt_stat(c(1.23, 2.45), c(0.95, 2.10), c(1.51, 2.80))
#' # "1.23 (0.95\u20131.51)" "2.45 (2.10\u20132.80)"
#'
#' fmt_stat(1.23, 0.95, 1.51, bracket = "[", sep = " to ")
#' # "1.23 [0.95 to 1.51]"
#'
#' # --- SD mode (2 arguments) ---
#' fmt_stat(1.23, 0.15)
#' # "1.2(0.2)"
#'
#' fmt_stat(c(1.23, 2.45), c(0.15, 0.25), digits = 2)
#' # "1.23(0.15)" "2.45(0.25)"
#'
#' # --- In mutate() ---
#' # df %>% mutate(ci = fmt_stat(est, ci_low, ci_high))
#' # df %>% mutate(ms = fmt_stat(mean_val, sd_val))
#'
#' @export
fmt_stat <- function(x, y, z = NULL,
                     digits = NULL,
                     bracket = c("(", "["),
                     sep = "\u2013") {
  bracket <- match.arg(bracket)
  bp <- if (bracket == "(") c("(", ")") else c("[", "]")


  # --- CI mode ---
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

  # --- SD mode ---
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
