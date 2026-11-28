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
    if (!length(p)) return(invisible(NULL))
    invalid <- if (!is.object(p)) {
      min(Inf, p, na.rm = TRUE) < 0 || max(-Inf, p, na.rm = TRUE) > 1
    } else any(!is.na(p) & (!is.finite(p) | p < 0 | p > 1))
    if (invalid) {
      cli::cli_abort("{.arg {arg}} must contain finite P-values between 0 and 1, or missing values.")
    }
  }

  # --- Stars helper (shared) ---
  .add_stars <- function(pvals, map, endpoints = NULL) {
    .validate_signif_map(map)
    if (!length(map)) return(NULL)
    if (is.unsorted(map)) map <- sort(map)
    if (!is.object(pvals) && min(Inf, pvals, na.rm = TRUE) > map[[length(map)]])
      return(NULL)
    if (is.null(endpoints) && !is.object(pvals) && length(map) == 1L) {
      cutoff <- map[[1L]]
      marker <- names(map)[[1L]]
      if (length(pvals) > 1024L && isTRUE(max(pvals) <= cutoff)) {
        return(rep.int(marker, length(pvals)))
      }
      stars <- rep.int("", length(pvals))
      stars[which(pvals <= cutoff)] <- marker
      return(stars)
    }
    if (is.null(endpoints) && (!is.object(pvals) || identical(class(pvals), "AsIs"))) {
      index <- findInterval(pvals, map, left.open = TRUE) + 1L
      stars <- c(names(map), "")[index]
      if (anyNA(pvals)) stars[is.na(pvals)] <- ""
      return(stars)
    }
    if (is.null(endpoints)) {
      out <- rep("", length(pvals))
      observed <- !is.na(pvals)
      for (i in rev(seq_along(map))) out[observed & pvals <= map[[i]]] <- names(map)[[i]]
      return(out)
    }
    if (anyDuplicated(map)) map <- map[!duplicated(map)]
    index <- findInterval(pvals, map, left.open = TRUE) + 1L
    tied <- which(pvals == unname(map[index]))
    decimal <- function(text) {
      parts <- .pvalue_decimal_parts(text)
      mantissa <- parts$mantissa
      exponent <- parts$exponent
      places <- integer(length(mantissa))
      dotted <- grep(".", mantissa, fixed = TRUE)
      if (length(dotted)) places[dotted] <- nchar(sub("^.*[.]", "", mantissa[dotted]))
      coefficient <- sub("^0+", "", gsub("[.+-]", "", mantissa))
      list(power = ifelse(coefficient == "", -Inf, exponent - places + nchar(coefficient) - 1L),
           digits = sub("0+$", "", coefficient))
    }
    tied_groups <- if (length(tied)) {
      if (length(map) == 1L) list(tied) else split(tied, index[tied])
    }
    for (rows in tied_groups) {
      cut <- map[[index[rows[1L]]]]
      candidates <- sprintf("%.*g", 1:17, cut)
      cutoff <- decimal(candidates[which(as.numeric(candidates) == cut)[1L]])
      text <- endpoints[rows]
      lookup <- NULL
      if (length(text) > 1L && all(text == text[[1L]])) {
        text <- text[[1L]]
      } else if (length(text) > 32L && anyDuplicated(text)) {
        keys <- unique(text)
        lookup <- match(text, keys)
        text <- keys
      }
      input <- decimal(text)
      above <- input$power > cutoff$power
      equal_power <- which(input$power == cutoff$power)
      if (length(equal_power)) {
        digits <- input$digits[equal_power]
        n_digits <- nchar(digits)
        cutoff_width <- nchar(cutoff$digits)
        width <- pmax(n_digits, cutoff_width)
        a <- paste0(digits, strrep("0", width - n_digits))
        b <- paste0(cutoff$digits, strrep("0", width - cutoff_width))
        above[equal_power] <- a > b
      }
      if (!is.null(lookup)) above <- above[lookup]
      advance <- rows[above]
      if (length(advance)) index[advance] <- index[advance] + 1L
    }
    stars <- c(names(map), "")[index]
    if (anyNA(pvals)) stars[is.na(pvals)] <- ""
    stars
  }

  # --- Mode 2: Add stars to x based on external p ---
  if (!is.null(add_star_p)) {
    if (is.logical(add_star_p) && all(is.na(add_star_p))) {
      add_star_p <- as.double(add_star_p)
    }
    if (!is.numeric(add_star_p)) cli::cli_abort("{.arg add_star_p} must be numeric.")
    .validate_p(add_star_p, "add_star_p")
    if (!is.object(x) && length(add_star_p) != length(x)) {
      cli::cli_abort("{.arg x} and {.arg add_star_p} must have the same length.")
    }
    .register_integer64(x)
    missing_x <- if (is.expression(x)) is.na(as.list(x)) else if (is.object(x) || anyNA(x)) is.na(x)
    x <- as.character(x)
    if (length(add_star_p) != length(x)) {
      cli::cli_abort("{.arg x} and {.arg add_star_p} must have the same length.")
    }
    stars <- .add_stars(add_star_p, map_signif)
    # Keep paste0()'s encoding and coercion behavior for arbitrary labels.
    out <- if (is.null(stars) && !length(x)) character() else
      paste0(x, if (is.null(stars)) "" else stars)
    if (length(missing_x)) out[missing_x] <- NA_character_
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

  if (is.character(x) && !is.object(x) && length(x) > 1024L &&
      length(unique(x[seq.int(1L, length(x), length.out = 1024L)])) < 512L) {
    keys <- unique(x)
    if (length(keys) < length(x) / 2) {
      formatted <- stat_pval(keys, digits = d, mode = mode, map_signif = map_signif)
      out <- if (length(keys) == 1L) rep.int(formatted, length(x)) else formatted[match(x, keys)]
      return(stats::setNames(out, input_names))
    }
  }

  bound_at <- NULL
  x_num <- if (is.character(x)) {
    if (any(!validEnc(x) | Encoding(x) == "bytes")) {
      cli::cli_abort("{.arg x} must contain numeric strings or numeric bounds.")
    }
    text <- .trim_pvalue_space(x)
    number <- "[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?"
    prefix <- "(?:[<>]=?|[\u2264\u2265])[\\h\\v]*"
    present <- if (anyNA(text)) which(!is.na(text))
    observed <- if (is.null(present)) text else text[present]
    accepted <- paste0("^(?:", number, "|[+-]?Inf(?:inity)?|NaN|NA|", prefix, number, ")$")
    if (!all(grepl(accepted, observed, perl = TRUE))) {
      cli::cli_abort("{.arg x} must contain numeric strings or numeric bounds.")
    }
    bound_rows <- grep("^[<>\u2264\u2265]", observed)
    if (length(bound_rows)) bound_at <- if (is.null(present)) bound_rows else present[bound_rows]
    values <- text
    if (length(bound_rows)) {
      values[bound_at] <- sub(paste0("^", prefix), "", text[bound_at], perl = TRUE)
    }
    missing_tokens <- values %in% c("NA", "NaN")
    if (any(missing_tokens)) values[missing_tokens] <- NA_character_
    .parse_decimal_tokens(values)
  } else if (is.numeric(x)) {
    x
  } else if (is.logical(x) && all(is.na(x))) {
    rep(NA_real_, length(x))
  } else {
    cli::cli_abort("{.arg x} must be numeric or character.")
  }

  if (is.character(x) && mode != "plain") {
    interior <- length(x_num) && isTRUE(min(x_num) > 0 && max(x_num) < 1)
    edge <- if (!interior) which(!is.na(values) & (is.na(x_num) | x_num %in% c(0, 1)))
    if (length(edge)) {
      # Inspect decimal text where rounding or parser overflow can hide values.
      endpoint <- values[edge]
      parts <- .pvalue_decimal_parts(endpoint)
      mantissa <- parts$mantissa
      exponent <- parts$exponent
      decimals <- nchar(sub("^[^.]*[.]?", "", mantissa))
      coefficient <- sub("^0+", "", gsub("[.+-]", "", mantissa))
      zero <- coefficient == ""
      unit_exponent <- decimals - nchar(coefficient) + 1L
      one <- grepl("^10*$", coefficient) & exponent == unit_exponent
      negative <- startsWith(mantissa, "-") & !zero
      above_one <- !zero & (exponent > unit_exponent |
                              (exponent == unit_exponent & !one))
      if (any(negative | above_one)) {
        cli::cli_abort("{.arg x} must contain finite P-values between 0 and 1, or missing values.")
      }
      strict <- if (length(bound_at)) grepl("^[<>](?!=)", text[edge], perl = TRUE) else FALSE
      if (any(strict & ((startsWith(text[edge], "<") & zero) |
                        (startsWith(text[edge], ">") & one)))) {
        cli::cli_abort("{.arg x} contains a strict bound that cannot describe a possible P-value (<0 or >1).")
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
  # Reuse formatting work only for repeated ordinary numeric P-values.
  expand <- NULL
  repeat_one <- FALSE
  if (is.numeric(x) && !is.object(x) && length(x_num) > 1024L &&
      length(unique(x_num[seq.int(1L, length(x_num), length.out = 1024L)])) < 512L) {
    keys <- unique(x_num)
    if (length(keys) < length(x_num) / 2) {
      # unique() treats -0 and +0 as equal, but %f preserves the sign.
      same_zeros <- TRUE
      if (mode == "plain" && is.double(keys) && any(keys == 0, na.rm = TRUE)) {
        negative_zero <- 1 / x_num[which(x_num == 0)] < 0
        same_zeros <- !any(negative_zero) || all(negative_zero)
      }
      if (same_zeros) {
        repeat_one <- length(keys) == 1L
        if (!repeat_one) expand <- match(x_num, keys)
        x_num <- keys
      }
    }
  }

  # Only subset when some values do not need numeric formatting.
  missing_num <- anyNA(x_num)
  selective <- missing_num || length(bound_at) > 0L
  if (selective) {
    if (missing_num) {
      observed_num <- !is.na(x_num)
      if (length(bound_at)) observed_num[bound_at] <- FALSE
      format_at <- which(observed_num)
    } else {
      format_at <- seq_along(x_num)[-bound_at]
    }
    format_x <- x_num[format_at]
  } else {
    format_x <- x_num
  }
  # A finite double needs at most 310 bytes before the decimal point.
  # A validated plain probability needs at most two, including signed zero.
  if (d > 7881L && (mode == "plain" || is.object(format_x) || d == 8190L)) {
    widths <- nchar(sprintf("%.0f", trunc(format_x[is.finite(format_x)])))
    if (any(widths + 1L + d > 8192L)) {
      cli::cli_abort("{.arg digits} exceeds the 8192-byte limit for a formatted number in {.arg x}.")
    }
  }
  fmt <- sprintf("%%.%df", d)
  out <- sprintf(fmt, format_x)
  if (mode != "plain" && length(out)) {
    # Include a small margin for the binary approximation to the decimal boundary.
    magnitude <- if (is.object(format_x)) abs(format_x) else format_x
    cutoff <- 0.5 * 10^-d * (1 + 4 * .Machine$double.eps)
    if (is.object(magnitude) || !isTRUE(min(magnitude) > cutoff)) {
      maybe_zero <- which(magnitude <= cutoff)
      zero <- maybe_zero[grepl("^-?0\\.0*$", out[maybe_zero])]
      if (length(zero)) out[zero] <- paste0("<0.", strrep("0", d - 1L), "1")
    }
  }
  if (mode == "stars") {
    endpoints <- if (is.character(x)) {
      if (selective) values[format_at] else values
    } else NULL
    stars <- .add_stars(format_x, map_signif, endpoints)
    if (!is.null(stars)) out <- paste0(out, stars)
  }
  if (selective) {
    formatted <- rep(NA_character_, length(x_num))
    formatted[format_at] <- out
    if (length(bound_at)) formatted[bound_at] <- text[bound_at]
    out <- formatted
  }
  if (repeat_one) out <- rep.int(out, length(x))
  else if (!is.null(expand)) out <- out[expand]
  names(out) <- input_names
  out
}

# Only try the final whitespace run from its first character.
.trim_pvalue_space <- function(text) {
  trim <- "^[\\h\\v]+|(?<![\\h\\v])[\\h\\v]++\\z"
  if (is.character(text) && is.null(attributes(text)) && length(text) > 1024L) {
    edge <- "^[\\h\\v]|[\\h\\v]\\z"
    probe <- text[seq.int(1L, length(text), length.out = 128L)]
    if (!any(grepl(edge, probe, perl = TRUE))) {
      rows <- grep(edge, text, perl = TRUE)
      if (!length(rows)) return(text)
      if (length(rows) < length(text) / 2L) {
        text[rows] <- gsub(trim, "", text[rows], perl = TRUE)
        return(text)
      }
    }
  }
  gsub(trim, "", text, perl = TRUE)
}

#' @noRd
.pvalue_decimal_parts <- function(text) {
  mantissa <- text
  exponent <- numeric(length(text))
  scientific <- grep("[eE]", text)
  if (length(scientific)) {
    tokens <- text[scientific]
    at <- regexpr("[eE]", tokens, useBytes = TRUE)
    mantissa[scientific] <- substring(tokens, 1L, at - 1L)
    exponent[scientific] <- as.numeric(substring(tokens, at + 1L))
  }
  list(mantissa = mantissa, exponent = exponent)
}

#' @noRd
.parse_decimal_tokens <- function(text) {
  value <- as.numeric(text)
  if (!anyNA(value)) return(value)
  at <- which(is.nan(value) & !is.na(text))
  if (!length(at)) return(value)
  endpoint <- text[at]
  parts <- .pvalue_decimal_parts(endpoint)
  mantissa <- parts$mantissa
  exponent <- parts$exponent
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
  valid_storage <- is.numeric(map) && !is.object(map) && is.null(dim(map))
  if (valid_storage && !length(map)) return(invisible(NULL))
  valid_names <- !is.null(names(map)) && !anyNA(names(map))
  if (valid_storage && valid_names && !anyNA(map)) {
    if (min(map) >= 0 && max(map) <= 1) return(invisible(NULL))
  }
  cli::cli_abort("{.arg map_signif} must be a named numeric vector with finite thresholds between 0 and 1 and non-missing names.")
}
