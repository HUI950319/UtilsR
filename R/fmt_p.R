# ============================================================================
# fmt_p.R -- Format p-values and numbers
# ============================================================================

#' Format P-values or Numbers
#'
#' Unified formatting for p-values and plain numbers. Automatically handles
#' character inputs containing comparison operators (e.g. \code{"<0.001"}).
#'
#' @param x Numeric or character vector.
#' @param digits Integer, decimal places (default: 3 for stars/pvalue, 2 for plain).
#' @param mode Formatting mode:
#'   \describe{
#'     \item{\code{"stars"}}{(default) P-value with significance stars.}
#'     \item{\code{"pvalue"}}{P-value with \code{"<0.001"} for small values.}
#'     \item{\code{"plain"}}{Plain number formatting.}
#'   }
#' @param map_signif Named numeric vector of significance thresholds.
#'   Only used when \code{mode = "stars"}.
#'   Default: \code{c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)}.
#'
#' @return Character vector of formatted values.
#'
#' @examples
#' # Stars mode (default)
#' fmt_p(c(0.0003, 0.005, 0.03, 0.08, 0.5))
#' # "<0.001***" "0.005**"   "0.030*"    "0.080."    "0.500"
#'
#' # P-value mode (no stars)
#' fmt_p(c(0.0003, 0.05), mode = "pvalue")
#' # "<0.001" "0.050"
#'
#' # Plain number
#' fmt_p(1.2345, digits = 2, mode = "plain")
#' # "1.23"
#'
#' # Character input
#' fmt_p(c("<0.001", "0.05"))
#' # "<0.001***" "0.050*"
#'
#' # Custom significance levels
#' fmt_p(0.08, map_signif = c("*" = 0.1))
#' # "0.080*"
#'
#' # In mutate()
#' # df %>% mutate(p_fmt = fmt_p(pvalue))
#'
#' @export
fmt_p <- function(x,
                  digits = NULL,
                  mode = c("stars", "pvalue", "plain"),
                  map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)) {
  mode <- match.arg(mode)

  # Default digits by mode
  d <- digits %||% if (mode == "plain") 2L else 3L
  d <- as.integer(d)
  if (d < 0L) cli::cli_abort("{.arg digits} must be non-negative.")

  # Parse character input
  x_num <- if (is.character(x)) {
    as.numeric(gsub("[<>]", "", x))
  } else if (is.numeric(x)) {
    x
  } else {
    cli::cli_abort("{.arg x} must be numeric or character.")
  }

  # --- plain mode ---
  if (mode == "plain") {
    fmt <- sprintf("%%.%df", d)
    out <- ifelse(is.na(x_num), NA_character_, sprintf(fmt, x_num))
    return(out)
  }

  # --- pvalue / stars mode ---
  fmt <- sprintf("%%.%df", d)
  out <- ifelse(is.na(x_num), NA_character_, sprintf(fmt, x_num))

  # Replace rounded-to-zero with threshold string
  threshold <- paste0("<0.", strrep("0", d - 1L), "1")
  out <- ifelse(!is.na(out) & grepl("^0\\.0*$", out), threshold, out)

  # --- stars mode ---
  if (mode == "stars") {
    if (!is.numeric(map_signif) || is.null(names(map_signif))) {
      cli::cli_abort("{.arg map_signif} must be a named numeric vector.")
    }
    map_signif <- sort(map_signif)
    stars <- vapply(x_num, function(p) {
      if (is.na(p)) return("")
      hit <- map_signif[map_signif >= p]
      if (length(hit) > 0L) names(which.min(hit)) else ""
    }, character(1))
    out <- paste0(out, stars)
  }

  out
}

#' Add Significance Stars to Values Based on P-values
#'
#' Appends significance stars to an effect column (e.g. HR, OR, coefficient)
#' based on a corresponding p-value column. Works inside \code{mutate()}.
#'
#' @param effect Character or numeric vector to annotate with stars.
#' @param p Numeric vector of p-values.
#' @param map_signif Named numeric vector of significance thresholds.
#'   Default: \code{c("***" = 0.001, "**" = 0.01, "*" = 0.05)}.
#'
#' @return Character vector with stars appended.
#'
#' @examples
#' fmt_stars(c(1.85, 0.72, 1.25, 1.01), c(0.0005, 0.008, 0.03, 0.5))
#' # "1.85***" "0.72**"  "1.25*"   "1.01"
#'
#' # With fmt_ci CI output
#' # df %>% mutate(hr_ci = fmt_stars(fmt_ci(hr, ci_low, ci_high), pvalue))
#'
#' @export
fmt_stars <- function(effect, p,
                      map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05)) {
  if (!is.numeric(p)) cli::cli_abort("{.arg p} must be numeric.")
  effect <- as.character(effect)
  if (length(p) != length(effect)) {
    cli::cli_abort("{.arg p} and {.arg effect} must have the same length.")
  }
  map_signif <- sort(map_signif)
  stars <- vapply(p, function(pv) {
    if (is.na(pv)) return("")
    hit <- map_signif[map_signif >= pv]
    if (length(hit) > 0L) names(which.min(hit)) else ""
  }, character(1))
  paste0(effect, stars)
}
