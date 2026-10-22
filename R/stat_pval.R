# =============================================================================
# stat_pval.R -- Format p-values and numbers, and append significance stars
# =============================================================================

#' Format P-values, Numbers, or Add Stars to Any Value
#'
#' Unified formatting for p-values and plain numbers. When \code{x} is provided
#' alone, formats p-values. When \code{add_star_p} is also provided,
#' appends significance stars to \code{x} based on \code{add_star_p}.
#'
#' @param x Numeric/character vector of p-values (when \code{add_star_p} is NULL),
#'   or any value to annotate with stars (when \code{add_star_p} is provided).
#'   Numeric strings may use scientific notation. Strings beginning with
#'   \code{<}, \code{<=}, \code{>}, \code{>=}, or their Unicode equivalents
#'   are returned with outer whitespace removed, without inferring stars.
#'   Other non-numeric strings are rejected.
#'   In P-value modes, observed values and numeric bound endpoints must be
#'   finite and between 0 and 1. Ordinary numbers in \code{plain} mode are
#'   not restricted to that range.
#'   Numeric input must not use \code{integer64}, date, date-time, or
#'   time-span storage; convert such values explicitly before formatting.
#'   Matrix and array inputs are not supported.
#' @param add_star_p Numeric vector of p-values for star annotation. When provided,
#'   stars are appended to \code{x} based on these p-values.
#'   Missing values in \code{x} remain missing; a missing P-value leaves
#'   non-missing text unchanged.
#'   Observed P-values must be finite and between 0 and 1.
#'   Matrix and array inputs are not supported.
#' @param digits Single integer, decimal places (default: 3 for stars/pvalue,
#'   2 for plain). Must be at least 1 for P-value modes or 0 for \code{plain}.
#'   Ignored when \code{add_star_p} is provided.
#' @param mode Formatting mode (ignored when \code{add_star_p} is provided):
#'   \describe{
#'     \item{\code{"stars"}}{(default) P-value with significance stars.}
#'     \item{\code{"pvalue"}}{P-value with \code{"<0.001"} for small values.}
#'     \item{\code{"plain"}}{Plain number formatting.}
#'   }
#' @param map_signif Named numeric vector of significance thresholds.
#'   Default: \code{c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)}.
#'   Thresholds must be finite, non-missing values between 0 and 1, with
#'   non-missing names. Empty symbols are allowed; an empty numeric vector
#'   disables stars. For repeated thresholds, the first symbol is used.
#'   The smallest threshold greater than or equal to the unrounded P-value
#'   determines its symbol. Ignored in \code{pvalue} and \code{plain} modes
#'   when \code{add_star_p} is NULL.
#'
#' @return Character vector of formatted values, preserving the names of
#'   \code{x}. Empty input returns a zero-length character vector.
#'
#' @examples
#' # --- Format p-values (x only) ---
#' stat_pval(c(0.0003, 0.005, 0.03, 0.08, 0.5))
#' # "<0.001***" "0.005**"   "0.030*"    "0.080."    "0.500"
#'
#' stat_pval(c(0.0003, 0.05), mode = "pvalue")
#' # "<0.001" "0.050"
#'
#' stat_pval(1.2345, digits = 2, mode = "plain")
#' # "1.23"
#'
#' # --- Add stars to any value (x + add_star_p) ---
#' stat_pval(c(1.85, 0.72, 1.25), add_star_p = c(0.001, 0.05, 0.5))
#' # "1.85***" "0.72*"   "1.25"
#'
#' # With stat_ci output
#' # df %>% mutate(hr_ci = stat_pval(stat_ci(hr, lo, hi), add_star_p = pvalue))
#'
#' @export
#' @family stat formatting
stat_pval <- function(x,
                  add_star_p = NULL,
                  digits = NULL,
                  mode = c("stars", "pvalue", "plain"),
                  map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)) {

  if (!is.null(dim(x))) cli::cli_abort("{.arg x} must be a vector, not a matrix or array.")
  if (!is.null(dim(add_star_p))) cli::cli_abort("{.arg add_star_p} must be a vector, not a matrix or array.")
  input_names <- names(x)
  numeric_input <- if (is.null(add_star_p)) x else add_star_p
  if (inherits(numeric_input, c("integer64", "Date", "POSIXt", "difftime",
                                "Duration", "Period", "Interval"))) {
    arg <- if (is.null(add_star_p)) "x" else "add_star_p"
    cli::cli_abort("{.arg {arg}} must use ordinary numeric values, not integer64, date, date-time, or time-span storage.")
  }

  .validate_p <- function(p, arg) {
    if (any(!is.na(p) & (!is.finite(p) | p < 0 | p > 1))) {
      cli::cli_abort("{.arg {arg}} must contain finite P-values between 0 and 1, or missing values.")
    }
  }

  # --- Stars helper (shared) ---
  .add_stars <- function(pvals, map) {
    if (!is.numeric(map) || is.object(map) || !is.null(dim(map)) ||
        (length(map) > 0L && is.null(names(map))) || anyNA(names(map)) ||
        any(!is.finite(map) | map < 0 | map > 1)) {
      cli::cli_abort("{.arg map_signif} must be a named numeric vector with finite thresholds between 0 and 1 and non-missing names.")
    }
    map <- sort(map)
    out <- rep("", length(pvals))
    observed <- !is.na(pvals)
    for (i in rev(seq_along(map))) {
      out[observed & pvals <= map[[i]]] <- names(map)[[i]]
    }
    out
  }

  # --- Mode 2: Add stars to x based on external p ---
  if (!is.null(add_star_p)) {
    if (!is.numeric(add_star_p)) cli::cli_abort("{.arg add_star_p} must be numeric.")
    .validate_p(add_star_p, "add_star_p")
    missing_x <- is.na(x)
    x <- as.character(x)
    if (length(add_star_p) != length(x)) {
      cli::cli_abort("{.arg x} and {.arg add_star_p} must have the same length.")
    }
    out <- paste0(x, .add_stars(add_star_p, map_signif))
    out[missing_x] <- NA_character_
    names(out) <- input_names
    return(out)
  }

  # --- Mode 1: Format p-values ---
  mode <- match.arg(mode)
  d <- digits %||% if (mode == "plain") 2L else 3L
  min_digits <- if (mode == "plain") 0L else 1L
  if (!is.numeric(d) || is.object(d) || !is.null(dim(d)) || length(d) != 1L ||
      !is.finite(d) || d < min_digits || d %% 1 != 0 || d > .Machine$integer.max) {
    cli::cli_abort("{.arg digits} must be a single integer between {min_digits} and {(.Machine$integer.max)} for this mode.")
  }
  d <- as.integer(d)

  bounded <- rep(FALSE, length(x))
  x_num <- if (is.character(x)) {
    text <- trimws(x)
    number <- "[+-]?(?:[0-9]+\\.?[0-9]*|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?"
    prefix <- "(?:[<>]=?|[\u2264\u2265])\\s*"
    bounded <- !is.na(text) & grepl(paste0("^", prefix, number, "$"), text, perl = TRUE)
    exact <- grepl(paste0("^(?:", number, "|[+-]?Inf(?:inity)?|NaN|NA)$"),
                   text, perl = TRUE)
    if (any(!is.na(text) & !bounded & !exact)) {
      cli::cli_abort("{.arg x} must contain numeric strings or numeric bounds.")
    }
    values <- sub(paste0("^", prefix), "", text, perl = TRUE)
    values[values %in% c("NA", "NaN")] <- NA_character_
    as.numeric(values)
  } else if (is.numeric(x)) {
    x
  } else {
    cli::cli_abort("{.arg x} must be numeric or character.")
  }

  # plain mode
  if (mode == "plain") {
    fmt <- sprintf("%%.%df", d)
    out <- sprintf(fmt, x_num)
    out[is.na(x_num)] <- NA_character_
    if (any(bounded)) out[bounded] <- text[bounded]
    names(out) <- input_names
    return(out)
  }

  # pvalue / stars mode
  .validate_p(x_num, "x")
  fmt <- sprintf("%%.%df", d)
  out <- sprintf(fmt, x_num)
  out[is.na(x_num)] <- NA_character_
  threshold <- paste0("<0.", strrep("0", d - 1L), "1")
  out[!is.na(out) & grepl("^-?0\\.0*$", out)] <- threshold

  if (mode == "stars") {
    out <- paste0(out, .add_stars(x_num, map_signif))
    out[is.na(x_num)] <- NA_character_
  }

  if (any(bounded)) out[bounded] <- text[bounded]
  names(out) <- input_names
  out
}
