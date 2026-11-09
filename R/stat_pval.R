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
#'   Numeric strings may use scientific notation. Decimal strings equal to 1
#'   exactly remain formattable even when their mantissa is too long for the
#'   numeric parser. Strings beginning with
#'   \code{<}, \code{<=}, \code{>}, \code{>=}, or their Unicode equivalents
#'   are returned with outer whitespace removed, without inferring stars.
#'   ASCII and Unicode whitespace is accepted around numbers and after
#'   a bound operator; whitespace within a number is not accepted.
#'   Other non-numeric strings are rejected.
#'   In P-value modes, observed values and numeric bound endpoints must be
#'   finite and between 0 and 1. Numeric text is checked against these endpoints
#'   before double-precision rounding; negative values that underflow to zero
#'   are still rejected. Positive values below the numeric range remain valid.
#'   Strict bounds \code{<0} and \code{>1}
#'   are rejected because they cannot describe a possible P-value.
#'   Ordinary numbers in \code{plain} mode are
#'   not restricted to that range.
#'   Numeric input must not use \code{integer64}, date, date-time, or
#'   time-span storage; convert such values explicitly before formatting.
#'   Matrix and array inputs are not supported.
#'   A logical vector is accepted only when all its elements are missing.
#'   For SPSS vectors of class \code{haven_labelled_spss}, user-missing codes
#'   and defined missing ranges are treated as missing before formatting or
#'   star annotation. This requires the optional \pkg{haven} package, including
#'   for vectors restored from a serialized file.
#' @param add_star_p Numeric vector of p-values for star annotation. When provided,
#'   stars are appended to \code{x} based on these p-values.
#'   Missing values in \code{x} remain missing; a missing P-value leaves
#'   non-missing text unchanged.
#'   SPSS user-missing values are treated as missing, as described for \code{x}.
#'   Observed P-values must be finite and between 0 and 1.
#'   Matrix and array inputs are not supported.
#'   An entirely missing logical vector is also accepted.
#' @param digits Single integer, decimal places (default: 3 for stars/pvalue,
#'   2 for plain). Must be at least 1 for P-value modes or 0 for \code{plain}.
#'   At most 8190; a sign or a longer integer part can lower this limit to
#'   keep each formatted number within the 8192-byte limit of \code{sprintf}.
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

  .normalize_spss <- function(value) {
    if (!inherits(value, "haven_labelled_spss")) return(value)
    if (!requireNamespace("haven", quietly = TRUE)) {
      cli::cli_abort("Interpreting SPSS user-missing values requires package {.pkg haven}.")
    }
    # Normalize missing codes before comparisons or character conversion.
    vctrs::vec_data(haven::zap_missing(value))
  }
  x <- .normalize_spss(x)
  add_star_p <- .normalize_spss(add_star_p)

  .validate_p <- function(p, arg) {
    if (any(!is.na(p) & (!is.finite(p) | p < 0 | p > 1))) {
      cli::cli_abort("{.arg {arg}} must contain finite P-values between 0 and 1, or missing values.")
    }
  }

  # --- Stars helper (shared) ---
  .add_stars <- function(pvals, map, endpoints = NULL) {
    .validate_signif_map(map)
    map <- sort(map)
    if (is.null(endpoints) && !is.object(pvals)) {
      index <- findInterval(pvals, map, left.open = TRUE) + 1L
      stars <- c(names(map), "")[index]
      stars[is.na(pvals)] <- ""
      return(stars)
    }
    out <- rep("", length(pvals))
    observed <- !is.na(pvals)
    decimal <- function(text) {
      mantissa <- sub("[eE].*$", "", text)
      exponent <- as.numeric(ifelse(grepl("[eE]", text), sub("^.*[eE]", "", text), "0"))
      places <- ifelse(grepl(".", mantissa, fixed = TRUE), nchar(sub("^.*[.]", "", mantissa)), 0L)
      coefficient <- sub("^0+", "", gsub("[.+-]", "", mantissa))
      list(power = ifelse(coefficient == "", -Inf, exponent - places + nchar(coefficient) - 1L),
           digits = sub("0+$", "", coefficient))
    }
    for (i in rev(seq_along(map))) {
      below <- pvals <= map[[i]]
      tied <- which(observed & pvals == map[[i]])
      if (!is.null(endpoints) && length(tied)) {
        candidates <- sprintf("%.*g", 1:17, map[[i]])
        cutoff <- decimal(candidates[which(as.numeric(candidates) == map[[i]])[1L]])
        input <- decimal(endpoints[tied])
        width <- pmax(nchar(input$digits), nchar(cutoff$digits))
        a <- paste0(input$digits, strrep("0", width - nchar(input$digits)))
        b <- paste0(cutoff$digits, strrep("0", width - nchar(cutoff$digits)))
        below[tied] <- input$power < cutoff$power | (input$power == cutoff$power & a <= b)
      }
      out[observed & below] <- names(map)[[i]]
    }
    out
  }

  # --- Mode 2: Add stars to x based on external p ---
  if (!is.null(add_star_p)) {
    if (is.logical(add_star_p) && all(is.na(add_star_p))) {
      add_star_p <- as.double(add_star_p)
    }
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
      !is.finite(d) || d < min_digits || d %% 1 != 0 || d > 8190L) {
    cli::cli_abort("{.arg digits} must be a single integer between {min_digits} and 8190 for this mode.")
  }
  d <- as.integer(d)

  bounded <- rep(FALSE, length(x))
  x_num <- if (is.character(x)) {
    text <- trimws(x, whitespace = "[\\h\\v]")
    number <- "[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?"
    prefix <- "(?:[<>]=?|[\u2264\u2265])[\\h\\v]*"
    bounded <- !is.na(text) & grepl(paste0("^", prefix, number, "$"), text, perl = TRUE)
    exact <- grepl(paste0("^(?:", number, "|[+-]?Inf(?:inity)?|NaN|NA)$"),
                   text, perl = TRUE)
    if (any(!is.na(text) & !bounded & !exact)) {
      cli::cli_abort("{.arg x} must contain numeric strings or numeric bounds.")
    }
    values <- sub(paste0("^", prefix), "", text, perl = TRUE)
    values[values %in% c("NA", "NaN")] <- NA_character_
    .parse_decimal_tokens(values)
  } else if (is.numeric(x)) {
    x
  } else if (is.logical(x) && all(is.na(x))) {
    rep(NA_real_, length(x))
  } else {
    cli::cli_abort("{.arg x} must be numeric or character.")
  }

  if (is.character(x)) {
    edge <- which(!is.na(values) & (is.na(x_num) | x_num %in% c(0, 1)))
    if (length(edge)) {
      # Inspect decimal text where rounding or parser overflow can hide values.
      endpoint <- values[edge]
      mantissa <- sub("[eE].*$", "", endpoint)
      exponent <- as.numeric(ifelse(grepl("[eE]", endpoint),
                                    sub("^.*[eE]", "", endpoint), "0"))
      decimals <- nchar(sub("^[^.]*[.]?", "", mantissa))
      coefficient <- sub("^0+", "", gsub("[.+-]", "", mantissa))
      zero <- coefficient == ""
      unit_exponent <- decimals - nchar(coefficient) + 1L
      one <- grepl("^10*$", coefficient) & exponent == unit_exponent
      negative <- startsWith(mantissa, "-") & !zero
      above_one <- !zero & (exponent > unit_exponent |
                              (exponent == unit_exponent & !one))
      if (mode != "plain") {
        if (any(negative | above_one)) {
          cli::cli_abort("{.arg x} must contain finite P-values between 0 and 1, or missing values.")
        }
        strict <- bounded[edge] & grepl("^[<>](?!=)", text[edge], perl = TRUE)
        if (any(strict & ((startsWith(text[edge], "<") & zero) |
                          (startsWith(text[edge], ">") & one)))) {
          cli::cli_abort("{.arg x} contains a strict bound that cannot describe a possible P-value (<0 or >1).")
        }
      }
      # Long mantissas can parse as NaN even when the decimal value is exactly one.
      x_num[edge[one & !negative]] <- 1
    }
  }
  if (mode != "plain") .validate_p(x_num, "x")
  if (!length(x_num)) {
    if (mode == "stars") .add_stars(x_num, map_signif)
    return(stats::setNames(character(), input_names))
  }
  # A finite double needs at most 310 bytes before the decimal point.
  if (d > 7881L) {
    widths <- nchar(sprintf("%.0f", trunc(x_num[is.finite(x_num)])))
    if (any(widths + 1L + d > 8192L)) {
      cli::cli_abort("{.arg digits} exceeds the 8192-byte limit for a formatted number in {.arg x}.")
    }
  }

  # Reuse formatting work only for repeated ordinary numeric P-values.
  expand <- NULL
  if (mode != "plain" && is.numeric(x) && !is.object(x) && length(x_num) > 1024L &&
      length(unique(x_num[seq.int(1L, length(x_num), length.out = 1024L)])) < 512L) {
    keys <- unique(x_num)
    if (length(keys) < length(x_num) / 2) {
      expand <- match(x_num, keys)
      x_num <- keys
      bounded <- rep(FALSE, length(keys))
    }
  }

  # Only subset when some values do not need numeric formatting.
  selective <- anyNA(x_num) || any(bounded)
  if (selective) {
    format_at <- which(!is.na(x_num) & !bounded)
    format_x <- x_num[format_at]
  } else {
    format_x <- x_num
  }
  fmt <- sprintf("%%.%df", d)
  out <- sprintf(fmt, format_x)
  if (mode != "plain" && length(out)) {
    threshold <- paste0("<0.", strrep("0", d - 1L), "1")
    out[grepl("^-?0\\.0*$", out)] <- threshold
  }
  if (mode == "stars") {
    endpoints <- if (is.character(x)) {
      if (selective) values[format_at] else values
    } else NULL
    out <- paste0(out, .add_stars(format_x, map_signif, endpoints))
  }
  if (selective) {
    formatted <- rep(NA_character_, length(x_num))
    formatted[format_at] <- out
    if (any(bounded)) formatted[bounded] <- text[bounded]
    out <- formatted
  }
  if (!is.null(expand)) out <- out[expand]
  names(out) <- input_names
  out
}

#' @noRd
.parse_decimal_tokens <- function(text) {
  value <- as.numeric(text)
  at <- which(is.nan(value) & !is.na(text))
  if (!length(at)) return(value)
  endpoint <- text[at]
  mantissa <- sub("[eE].*$", "", endpoint)
  exponent <- as.numeric(ifelse(grepl("[eE]", endpoint), sub("^.*[eE]", "", endpoint), "0"))
  decimals <- nchar(sub("^[^.]*[.]?", "", mantissa))
  coefficient <- sub("^0+", "", gsub("[.+-]", "", mantissa))
  power <- exponent - decimals + nchar(coefficient) - 1L
  significant <- substr(coefficient, 1L, 32L)
  negative <- startsWith(mantissa, "-")
  restored <- ifelse(power < 0, 0, Inf) * ifelse(negative, -1, 1)
  finite <- which(is.finite(power) & nzchar(coefficient))
  normalized <- paste0(ifelse(negative[finite], "-", ""),
    substr(significant[finite], 1L, 1L), ".", substring(significant[finite], 2L),
    "e", format(power[finite], scientific = FALSE, trim = TRUE))
  restored[finite] <- as.numeric(normalized)
  restored[coefficient == ""] <- 0
  value[at] <- restored
  value
}

#' @noRd
.validate_signif_map <- function(map) {
  if (!is.numeric(map) || is.object(map) || !is.null(dim(map)) ||
      (length(map) > 0L && is.null(names(map))) || anyNA(names(map)) ||
      any(!is.finite(map) | map < 0 | map > 1)) {
    cli::cli_abort("{.arg map_signif} must be a named numeric vector with finite thresholds between 0 and 1 and non-missing names.")
  }
}
