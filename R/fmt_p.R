# ============================================================================
# fmt_p.R -- Format p-values, numbers, and add significance stars
# ============================================================================

#' Format P-values, Numbers, or Add Stars to Any Value
#'
#' Unified formatting for p-values and plain numbers. When \code{x} is provided
#' alone, formats p-values. When \code{add_star_p} is also provided,
#' appends significance stars to \code{x} based on \code{add_star_p}.
#'
#' @param x Numeric/character vector of p-values (when \code{add_star_p} is NULL),
#'   or any value to annotate with stars (when \code{add_star_p} is provided).
#' @param add_star_p Numeric vector of p-values for star annotation. When provided,
#'   stars are appended to \code{x} based on these p-values.
#' @param digits Integer, decimal places (default: 3 for stars/pvalue, 2 for plain).
#'   Ignored when \code{p} is provided.
#' @param mode Formatting mode (ignored when \code{p} is provided):
#'   \describe{
#'     \item{\code{"stars"}}{(default) P-value with significance stars.}
#'     \item{\code{"pvalue"}}{P-value with \code{"<0.001"} for small values.}
#'     \item{\code{"plain"}}{Plain number formatting.}
#'   }
#' @param map_signif Named numeric vector of significance thresholds.
#'   Default: \code{c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)}.
#'
#' @return Character vector of formatted values.
#'
#' @examples
#' # --- Format p-values (x only) ---
#' fmt_p(c(0.0003, 0.005, 0.03, 0.08, 0.5))
#' # "<0.001***" "0.005**"   "0.030*"    "0.080."    "0.500"
#'
#' fmt_p(c(0.0003, 0.05), mode = "pvalue")
#' # "<0.001" "0.050"
#'
#' fmt_p(1.2345, digits = 2, mode = "plain")
#' # "1.23"
#'
#' # --- Add stars to any value (x + add_star_p) ---
#' fmt_p(c(1.85, 0.72, 1.25), add_star_p = c(0.001, 0.05, 0.5))
#' # "1.85***" "0.72*"   "1.25"
#'
#' # With fmt_ci output
#' # df %>% mutate(hr_ci = fmt_p(fmt_ci(hr, lo, hi), add_star_p = pvalue))
#'
#' @export
fmt_p <- function(x,
                  add_star_p = NULL,
                  digits = NULL,
                  mode = c("stars", "pvalue", "plain"),
                  map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)) {

  # --- Stars helper (shared) ---
  .add_stars <- function(pvals, map) {
    map <- sort(map)
    vapply(pvals, function(pv) {
      if (is.na(pv)) return("")
      hit <- map[map >= pv]
      if (length(hit) > 0L) names(which.min(hit)) else ""
    }, character(1))
  }

  # --- Mode 2: Add stars to x based on external p ---
  if (!is.null(add_star_p)) {
    if (!is.numeric(add_star_p)) cli::cli_abort("{.arg add_star_p} must be numeric.")
    x <- as.character(x)
    if (length(add_star_p) != length(x)) {
      cli::cli_abort("{.arg x} and {.arg add_star_p} must have the same length.")
    }
    return(paste0(x, .add_stars(add_star_p, map_signif)))
  }

  # --- Mode 1: Format p-values ---
  mode <- match.arg(mode)
  d <- digits %||% if (mode == "plain") 2L else 3L
  d <- as.integer(d)
  if (d < 0L) cli::cli_abort("{.arg digits} must be non-negative.")

  x_num <- if (is.character(x)) {
    as.numeric(gsub("[<>]", "", x))
  } else if (is.numeric(x)) {
    x
  } else {
    cli::cli_abort("{.arg x} must be numeric or character.")
  }

  # plain mode
  if (mode == "plain") {
    fmt <- sprintf("%%.%df", d)
    return(ifelse(is.na(x_num), NA_character_, sprintf(fmt, x_num)))
  }

  # pvalue / stars mode
  fmt <- sprintf("%%.%df", d)
  out <- ifelse(is.na(x_num), NA_character_, sprintf(fmt, x_num))
  threshold <- paste0("<0.", strrep("0", d - 1L), "1")
  out <- ifelse(!is.na(out) & grepl("^0\\.0*$", out), threshold, out)

  if (mode == "stars") {
    if (!is.numeric(map_signif) || is.null(names(map_signif))) {
      cli::cli_abort("{.arg map_signif} must be a named numeric vector.")
    }
    out <- paste0(out, .add_stars(x_num, map_signif))
  }

  out
}

#' @rdname fmt_p
#' @usage fmt_stars(effect, add_star_p, map_signif)
#' @export
fmt_stars <- function(effect, add_star_p,
                      map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05)) {
  fmt_p(effect, add_star_p = add_star_p, map_signif = map_signif)
}
