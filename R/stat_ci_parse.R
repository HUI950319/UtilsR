# =============================================================================
# stat_ci_parse.R -- Parse CI strings, derive p-values, re-level intervals
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  stat_ci_parse(x, output, level, exp, digits, ...)   -- public API
#         |   output = ci | p | ci_p | ci_star | p_star
#         +-- L2  .ci_extract()   "est (lo, hi)" -> estimate + bounds +
#                                 rounding unit of each printed number
#         +-- L2  .ci_scale()     ratio (log) or difference scale per element;
#                                 flags invalid, undecidable and asymmetric
#                                 intervals
# =============================================================================

#' Parse Confidence Interval Strings
#'
#' Extract components from CI strings like \code{"1.23 (0.95, 1.59)"},
#' compute p-values, adjust confidence levels, and optionally add stars.
#'
#' @param x Character vector of CI strings (e.g. \code{"1.23 (0.95, 1.59)"}).
#'   Brackets \code{()} or \code{[]}; separators \code{,} \code{;}
#'   \code{-} \code{~} en/em dash or \code{to}; numbers may carry a sign or
#'   an exponent. Full-width punctuation, the Unicode minus and an en or em
#'   dash written as a minus sign before a number are accepted.
#'   Whitespace, including non-breaking spaces, is allowed around brackets
#'   and separators and at either end of the string.
#'   Trailing stars are ignored, other trailing text is dropped with a
#'   warning, and \code{NA} / whitespace-only strings pass through silently.
#' @param output What to return:
#'   \describe{
#'     \item{\code{"ci"}}{(default) CI string (adjusted if \code{level} is set).}
#'     \item{\code{"p"}}{Numeric p-value vector.}
#'     \item{\code{"ci_p"}}{CI string with p-value appended.}
#'     \item{\code{"ci_star"}}{CI string with significance stars.}
#'     \item{\code{"p_star"}}{Formatted p-value with stars.}
#'   }
#' @param level Target confidence level for CI adjustment (e.g. \code{0.90}).
#'   Default \code{NULL} keeps original 95\% CI.
#' @param exp Scale of the interval: \code{TRUE} for ratios (HR, OR, RR;
#'   null = 1, normal approximation on the log scale), \code{FALSE} for
#'   differences (null = 0), or \code{"auto"} (default) to infer it. Set it
#'   explicitly whenever the effect measure is known. See Details.
#' @param digits A single finite integer from 0 to 8190, giving the decimal
#'   places for output. Default: the most decimals among the estimate and its
#'   bounds, so \code{output = "ci"}
#'   without \code{level} does not round the input; at least one with
#'   \code{level}. Detected precision has the same upper limit. Each formatted
#'   number must also fit within \code{sprintf()}'s 8192-byte limit, including
#'   the sign, integer part and decimal point; otherwise an error is raised.
#' @param map_signif Named numeric vector for star thresholds.
#'   Default: \code{c("***" = 0.001, "**" = 0.01, "*" = 0.05)}.
#'   Thresholds must be finite, non-missing values between 0 and 1, with
#'   non-missing names. Empty symbols are allowed; an empty numeric vector
#'   disables stars. For repeated thresholds, the first symbol is used.
#'   Only used when \code{output} is \code{"ci_star"} or \code{"p_star"}.
#'
#' @details
#' The input is read as a 95\% CI and the p-value is backed out with the
#' normal approximation of Altman & Bland (BMJ 2011;343:d2304):
#' \eqn{SE = (hi - lo) / (2 \times 1.96)} on the working scale. An interval
#' at another level (e.g. a 90\% CI) is still read as 95\% and gives a wrong
#' p-value; convert it first.
#' Log-scale comparisons use stable log ratios to avoid intermediate products
#' overflowing or underflowing for finite positive inputs.
#' Raw-scale comparisons and interval widths avoid intermediate overflow
#' for extreme finite values by rescaling before subtraction when needed.
#' If a difference-scale SE exceeds floating-point range, calculations use
#' rescaled values while retaining the same normal approximation.
#'
#' \strong{\code{exp = "auto"}.} An interval symmetric on the log scale is a
#' ratio, and one symmetric on the raw scale is a difference; bounds
#' \eqn{\le 0} rule out a ratio. The comparison allows for the rounding of
#' the printed digits, so a narrow interval such as \code{"0.98 (0.95, 1.01)"}
#' fits both scales. Such an interval takes the scale of the intervals in
#' \code{x} that can be decided, provided they all agree. Otherwise it is
#' treated as a ratio, with a warning.
#'
#' \strong{Asymmetric intervals.} An interval that stays clearly asymmetric
#' on its scale gets a warning (exact, profile-likelihood or bootstrap
#' intervals, or a typo). The threshold is \eqn{|hi + lo - 2 est| / (hi - lo)
#' > 0.2} after allowing for rounding. Its SE comes from the half of the
#' interval facing the null, so \code{p < 0.05} exactly when the interval
#' excludes the null. \code{level} rescales each half separately, so
#' \code{level = 0.95} returns the interval unchanged.
#'
#' \strong{Invalid intervals.} If the estimate lies outside its bounds, the
#' width is zero, or a bound is \eqn{\le 0} under \code{exp = TRUE}, the
#' string is returned as-is and its p-value is \code{NA}, with a warning.
#'
#' With \code{level}, the p-value is read off the re-levelled interval as if
#' it were a 95\% CI. Its stars therefore agree with the interval shown and
#' are not the p-value of the original test.
#'
#' @return Character vector (for ci/ci_p/ci_star/p_star) or numeric vector
#'   (for p), with the names of \code{x}, including for empty vectors.
#'
#' @examples
#' # Basic: return CI as-is
#' stat_ci_parse("1.23 (0.95, 1.59)")
#'
#' # Whitespace pasted from manuscripts
#' stat_ci_parse("\u00a01.23 ( 0.95, 1.59 )\u00a0", exp = TRUE)
#'
#' # Extract p-value
#' stat_ci_parse("2.45 (1.20, 4.80)", output = "p")
#'
#' # CI with stars
#' stat_ci_parse(c("2.45 (1.20, 4.80)", "1.23 (0.95, 1.59)"), output = "ci_star")
#'
#' # CI with p-value
#' stat_ci_parse("2.45 (1.20, 4.80)", output = "ci_p")
#'
#' # Adjust confidence level
#' stat_ci_parse("1.23 (0.95, 1.59)", level = 0.90)
#'
#' # In mutate()
#' # df %>% mutate(p = stat_ci_parse(hr_ci, output = "p"))
#' # df %>% mutate(hr_star = stat_ci_parse(hr_ci, output = "ci_star"))
#'
#' @export
#' @family stat formatting
stat_ci_parse <- function(x,
                     output = c("ci", "p", "ci_p", "ci_star", "p_star"),
                     level = NULL,
                     exp = "auto",
                     digits = NULL,
                     map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05)) {

  output <- match.arg(output)
  if (!is.character(x)) cli::cli_abort("{.arg x} must be a character vector.")
  if (!is.null(dim(x))) cli::cli_abort("{.arg x} must be a vector without dimensions.")
  if (!is.null(dim(exp)) || !(identical(exp, "auto") || isTRUE(exp) || isFALSE(exp))) {
    cli::cli_abort("{.arg exp} must be {.val auto}, {.code TRUE} or {.code FALSE}.")
  }
  if (!is.null(level) && !(is.numeric(level) && !is.object(level) &&
                           is.null(dim(level)) && length(level) == 1L &&
                           !is.na(level) && level > 0 && level < 1)) {
    cli::cli_abort("{.arg level} must be a single number between 0 and 1.")
  }
  if (!is.null(digits) && !(is.numeric(digits) && !is.object(digits) &&
                            is.null(dim(digits)) && length(digits) == 1L &&
                            is.finite(digits) && digits >= 0 &&
                            digits <= 8190L && digits == round(digits))) {
    cli::cli_abort("{.arg digits} must be a single integer between 0 and 8190.")
  }
  if (output %in% c("ci_star", "p_star")) .validate_signif_map(map_signif)
  if (!length(x)) {
    out <- if (output == "p") numeric(0) else character(0)
    names(out) <- names(x)
    return(out)
  }

  # --- Parse CI strings ---
  parsed <- .ci_extract(x)
  est <- parsed$estimate
  lo  <- parsed$lower
  hi  <- parsed$upper
  d   <- parsed$digits
  valid <- parsed$valid

  # Override digits
  if (!is.null(digits)) d[] <- as.integer(digits)

  # Warn about unparseable elements (NA and "" pass through silently)
  if (!all(valid)) {
    n_fail <- .ci_unparsed_count(x[!valid])
    if (n_fail > 0L) {
      cli::cli_warn("{n_fail} element{?s} could not be parsed as CI string{?s} and {?was/were} returned as-is.")
    }
  }
  n_tail <- sum(parsed$trailing)
  if (n_tail > 0L) {
    cli::cli_warn("{n_tail} element{?s} had trailing text after the closing bracket, which was dropped.")
  }

  if (any(valid)) {
    # --- Scale of each interval (ratio -> log scale, null = 0 there) ---
    scale <- .ci_scale(est, lo, hi, parsed$unit, exp, valid)
    is_exp <- scale$is_exp
    asym <- scale$asymmetric
    n_bad <- sum(scale$invalid)
    if (n_bad > 0L) {
      valid <- valid & !scale$invalid
      cli::cli_warn("{n_bad} interval{?s} {?is/are} invalid (estimate outside the bounds, zero width, or a bound <= 0 under {.code exp = TRUE}) and {?was/were} returned as-is.")
    }
    n_amb <- sum(scale$ambiguous)
    if (n_amb > 0L) {
      cli::cli_warn("{n_amb} interval{?s} did not reveal {?its/their} scale from the printed digits and {?was/were} treated as ratio{?s} ({.code exp = TRUE}); set {.arg exp} explicitly.")
    }
    n_asym <- sum(asym)
    if (n_asym > 0L) {
      cli::cli_warn("{n_asym} interval{?s} {?is/are} not symmetric on {?its/their} scale; p uses the half facing the null and {.arg level} rescales each half.")
    }
  }

  if (!any(valid)) {
    out <- switch(output, p = rep(NA_real_, length(x)),
                  p_star = rep(NA_character_, length(x)), x)
    names(out) <- names(x)
    return(out)
  }

  all_valid <- all(valid)
  adjust <- !is.null(level) && level != .95
  if (!is.null(level) && is.null(digits)) d <- pmax(d, 1L)
  if (output != "ci" || adjust) {
    # --- Compute SE and p-value on the working scale ---
    z95 <- qnorm(0.975)
    e_s <- est; l_s <- lo; h_s <- hi
    tight <- integer()
    exp_rows <- which(is_exp)
    if (length(exp_rows)) {
      if (length(exp_rows) == length(est)) {
        e_s <- log_est <- log(est)
        l_s <- log_lo <- log(lo)
        h_s <- log_hi <- log(hi)
      } else {
        e_s[exp_rows] <- log_est <- log(est[exp_rows])
        l_s[exp_rows] <- log_lo <- log(lo[exp_rows])
        h_s[exp_rows] <- log_hi <- log(hi[exp_rows])
      }
      tight <- exp_rows[pmax(abs(log_lo - log_est), abs(log_hi - log_est)) <
                          sqrt(.Machine$double.eps) * pmax(1, abs(log_est))]
    }
    if (length(tight)) {
      tight_lower <- log1p((est[tight] - lo[tight]) / lo[tight])
      tight_upper <- log1p((hi[tight] - est[tight]) / est[tight])
      tight_se <- ifelse(asym[tight], ifelse(e_s[tight] > 0, tight_lower, tight_upper),
                         (tight_lower + tight_upper) / 2) / z95
    }
    # Full width for symmetric intervals; for asymmetric ones the half facing
    # the null, so that p < 0.05 exactly when the interval excludes the null
    asymmetric_rows <- which(asym)
    se_of <- function(l, h) {
      full <- (h - l) / (2 * z95)
      wide <- if (length(full) && (!is.finite(max(full)) || !is.finite(min(full))))
        which(!is.finite(full))
      if (length(wide)) {
        wide <- wide[is.finite(l[wide]) & is.finite(h[wide])]
        full[wide] <- h[wide] / (2 * z95) - l[wide] / (2 * z95)
      }
      if (length(asymmetric_rows)) {
        center <- e_s[asymmetric_rows]
        lower <- l[asymmetric_rows]
        upper <- h[asymmetric_rows]
        half <- ifelse(center > 0, center - lower, upper - center) / z95
        wide <- which(!is.finite(half))
        if (length(wide)) {
          wide <- wide[is.finite(center[wide]) & is.finite(lower[wide]) & is.finite(upper[wide])]
          half[wide] <- ifelse(center[wide] > 0,
            center[wide] / z95 - lower[wide] / z95, upper[wide] / z95 - center[wide] / z95)
        }
        full[asymmetric_rows] <- half
      }
      if (length(tight)) full[tight] <- tight_se
      full
    }
    se <- se_of(l_s, h_s)
    work_scale <- 1
    unstable <- !is.finite(se) | (abs(se) < .Machine$double.xmin & l_s != h_s)
    if (adjust) {
      # Near zero, the central normal probability is linear to double precision.
      z_new <- if (level < sqrt(.Machine$double.eps)) sqrt(pi / 2) * level else
        qnorm((1 - level) / 2, lower.tail = FALSE)
      ratio <- z_new / z95
      adjusted_bounds <- function() {
        change <- z_new * se
        lo <- e_s - change
        hi <- e_s + change
        if (length(asymmetric_rows)) {
          rows <- asymmetric_rows
          lo[rows] <- e_s[rows] - (e_s[rows] - l_s[rows]) * ratio
          hi[rows] <- e_s[rows] + (h_s[rows] - e_s[rows]) * ratio
        }
        list(lower = lo, upper = hi)
      }
      adjusted <- adjusted_bounds()
      unstable <- unstable | !is.finite(adjusted$lower) | !is.finite(adjusted$upper)
    }
    rescale <- which(valid & !is_exp & unstable)
    if (length(rescale)) {
      finite <- is.finite(e_s[rescale]) & is.finite(l_s[rescale]) & is.finite(h_s[rescale])
      rescale <- rescale[finite]
    }
    if (length(rescale)) {
      work_scale <- rep(1, length(est))
      work_scale[rescale] <- pmax(abs(e_s[rescale]), abs(l_s[rescale]), abs(h_s[rescale]))
      e_s[rescale] <- e_s[rescale] / work_scale[rescale]
      l_s[rescale] <- l_s[rescale] / work_scale[rescale]
      h_s[rescale] <- h_s[rescale] / work_scale[rescale]
      se <- se_of(l_s, h_s)
    }

    # --- Adjust CI level; p is then read off the adjusted CI as a 95% CI ---
    if (!is.null(level)) {
      if (level != .95) {
        if (length(rescale)) adjusted <- adjusted_bounds()
        l_s <- adjusted$lower
        h_s <- adjusted$upper
        if (all_valid && !any(is_exp)) {
          lo <- l_s * work_scale
          hi <- h_s * work_scale
        } else {
          lo <- ifelse(valid, ifelse(is_exp, exp(l_s), l_s * work_scale), lo)
          hi <- ifelse(valid, ifelse(is_exp, exp(h_s), h_s * work_scale), hi)
        }
        if (length(tight)) {
          down <- ifelse(asym[tight], tight_lower * ratio, z_new * tight_se)
          up <- ifelse(asym[tight], tight_upper * ratio, z_new * tight_se)
          lo[tight] <- est[tight] * exp(-down)
          hi[tight] <- est[tight] * exp(up)
          tight_se <- tight_se * ratio
        }
        se <- se_of(l_s, h_s)
      }
    }
    # An estimate on the null has z = 0 even when its null-side half has
    # rounded to zero width (0 / 0)
    if (output != "ci") {
      z <- e_s / se
      null <- which(e_s == 0)
      if (length(null)) z[null] <- 0
      pval <- 2 * pnorm(-abs(z))
      if (!all_valid) pval[!valid] <- NA_real_
      underflow <- which(pval == 0)
      if (length(underflow)) {
        underflow <- underflow[is.finite(z[underflow])]
        pval[underflow] <- exp(log(2) + pnorm(-abs(z[underflow]), log.p = TRUE))
      }
    }
  }

  # --- Rebuild the CI string in its original bracket/separator style ---
  if (!all_valid) d[!valid] <- 0L
  upper_digits <- if (!anyNA(d)) max(d)
  if (is.null(upper_digits) || min(d) < 0 || upper_digits > 8190L) {
    cli::cli_abort("The detected {.arg digits} must be between 0 and 8190.")
  }
  # Only very high precision can require the formatted-number byte checks below.
  if (output %in% c("p", "p_star") && upper_digits <= 7881L) {
    out <- if (output == "p") pval else stat_pval(pval, map_signif = map_signif)
    names(out) <- names(x)
    return(out)
  }
  .format_once <- function(v, d) {
    v <- round(v, d)
    if (length(v) && !isTRUE(min(v) > 0 || max(v) < 0)) {
      zero <- which(v == 0)
      if (length(zero)) v[zero] <- 0    # -0 would print as "-0.00"
    }
    if (any(d > 7881L)) {
      at <- which(is.finite(v) & d > 7881L)
      widths <- nchar(sprintf("%.0f", trunc(v[at])))
      precision <- if (length(d) == 1L) d else d[at]
      if (any(widths + 1L + precision > 8192L)) {
        cli::cli_abort("{.arg digits} exceeds the 8192-byte limit for a formatted number.")
      }
    }
    sprintf("%.*f", d, v)
  }
  fmt <- function(v, d) {
    n <- length(v)
    if (n > 1024L && min(d) == max(d)) {
      if (.pal_use_unique(v)) {
        keys <- unique(v)
        if (length(keys) < n / 2) {
          return(.format_once(keys, d[[1L]])[match(v, keys)])
        }
      }
    } else if (n > 1024L) {
      probe <- seq.int(1L, n, length.out = 1024L)
      keys <- vctrs::new_data_frame(list(v = v[probe], d = d[probe]))
      if (attr(vctrs::vec_group_id(keys), "n") < length(probe) / 2) {
        ids <- vctrs::vec_group_id(vctrs::new_data_frame(list(v = v, d = d)))
        count <- attr(ids, "n")
        if (count < n / 2) {
          first <- if (count == 1L) 1L else which(!duplicated(ids, nmax = count))
          return(.format_once(v[first], d[first])[ids])
        }
      }
    }
    .format_once(v, d)
  }
  ci_str <- x
  if (all_valid) {
    ci_str <- paste0(fmt(est, d), " ", parsed$open, fmt(lo, d), parsed$sep,
                     fmt(hi, d), parsed$close)
  } else {
    precision <- d[valid]
    ci_str[valid] <- paste0(fmt(est[valid], precision), " ", parsed$open[valid],
                           fmt(lo[valid], precision), parsed$sep[valid],
                           fmt(hi[valid], precision), parsed$close[valid])
  }

  # --- Return based on output ---
  out <- switch(output,
    ci = ci_str,
    p = pval,
    ci_p = {
      text <- stat_pval(if (all_valid) pval else pval[valid], mode = "pvalue")
      intervals <- if (all_valid) ci_str else ci_str[valid]
      combined <- paste0(intervals, ", p", ifelse(startsWith(text, "<"), "", "="), text)
      if (all_valid) combined else {
        value <- x
        value[valid] <- combined
        value
      }
    },
    ci_star = {
      starred <- stat_pval(ci_str, add_star_p = pval, map_signif = map_signif)
      if (all_valid) starred else ifelse(valid, starred, x)
    },
    p_star = ifelse(valid,
      stat_pval(pval, map_signif = map_signif),
      NA_character_)
  )
  names(out) <- names(x)
  out
}


# ---- Internal helpers (not exported) ----

#' @noRd
.ci_unparsed_count <- function(text) {
  bad <- !validEnc(text) | Encoding(text) == "bytes"
  if (!any(bad)) return(sum(grepl("[^\\h\\v]", text, perl = TRUE)))
  sum(bad) + sum(grepl("[^\\h\\v]", text[!bad], perl = TRUE))
}

.ci_extract <- function(x) {
  bad <- !validEnc(x) | Encoding(x) == "bytes"
  if (any(bad)) x[bad] <- NA_character_
  n <- length(x)
  if (n > 1024L &&
      length(unique(x[seq.int(1L, n, length.out = 1024L)])) < 512L) {
    keys <- unique(x)
    if (length(keys) < n / 2) {
      parsed <- .ci_extract(keys)
      if (length(keys) == 1L) {
        return(lapply(parsed, function(value) {
          if (!is.matrix(value)) return(rep.int(value, n))
          expanded <- rep(value, each = n)
          dim(expanded) <- c(n, ncol(value))
          expanded
        }))
      }
      index <- match(x, keys)
      return(lapply(parsed, function(value) {
        if (is.matrix(value)) value[index, , drop = FALSE] else value[index]
      }))
    }
  }
  # Full-width punctuation and Unicode spacing/minus (pasted from Word/PDF)
  space <- "[\\h\\v]"
  xs <- chartr("\u2212\uff08\uff09\uff0c\uff1b\uff5e", "-(),;~",
               sub(paste0("^", space, "+"), "", x, perl = TRUE))
  # An en or em dash right before a number is a minus sign, as Word and PDF
  # tables print negatives, when it opens the string or follows the bracket
  # or a separator; between two numbers it stays the separator
  dash_rows <- grepl("[\u2013\u2014]", xs, perl = TRUE)
  if (any(dash_rows)) {
    xs[dash_rows] <- gsub(paste0("(^|[[(,;~\u2013\u2014-]", space, "*|", space,
                                "to", space, "+)[\u2013\u2014](?=\\.?\\d)"),
                         "\\1-", xs[dash_rows], perl = TRUE)
  }
  suffix <- "(?<![*\\h\\v])[*\\h\\v]++$"
  xs <- sub(suffix, "", xs, perl = TRUE) # strip trailing stars/spaces
  dots <- which(endsWith(xs, "."))
  if (length(dots)) xs[dots] <- sub(suffix, "", sub("\\.$", "", xs[dots]), perl = TRUE)

  # est (lower sep upper) -- one pattern for every bracket and separator;
  # groups: 1 est, 2 open, 3 lower, 4 sep, 5 upper, 6 close
  num <- "([-+]?(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:[eE][-+]?\\d+)?)"
  re <- paste0("^", num, space, "*([[(])", space, "*", num,
               "(", space, "*[,;~\u2013\u2014-]", space, "*|",
               space, "+to", space, "+)", num, space, "*([])])")
  matched <- regexpr(re, xs, perl = TRUE)
  hit <- which(matched > 0L)
  if (!length(hit)) {
    empty <- rep.int(NA_real_, n)
    text <- rep.int(NA_character_, n)
    return(list(estimate = empty, lower = empty, upper = empty, digits = rep.int(2L, n),
      open = text, sep = text, close = text, valid = logical(n),
      unit = matrix(NA_real_, n, 3L), trailing = logical(n)))
  }
  starts <- attr(matched, "capture.start")
  lengths <- attr(matched, "capture.length")
  text <- if (length(hit) == n) xs else xs[hit]
  g <- lapply(seq_len(6L), function(k) {
    first <- starts[hit, k]
    substring(text, first, first + lengths[hit, k] - 1L)
  })
  paired <- (g[[2L]] == "(") == (g[[6L]] == ")")
  if (!all(paired)) {
    hit <- hit[paired]
    g <- lapply(g, "[", paired)
    text <- text[paired]
  }
  end <- 1L + attr(matched, "match.length")[hit]
  extra <- which(end <= nchar(text))
  has_trailing <- logical(length(hit))
  if (length(extra)) has_trailing[extra] <- grepl("[^\\h\\v]",
    substring(text[extra], end[extra]), perl = TRUE)
  values <- lapply(g[c(1, 3, 5)], .parse_decimal_tokens)
  finite <- vapply(values, function(v) !length(v) ||
    (is.finite(min(v)) && is.finite(max(v))), logical(1))
  ok <- if (all(finite)) TRUE else Reduce(`&`, lapply(values, is.finite))
  if (!all(ok)) {
    hit <- hit[ok]
    g <- lapply(g, "[", ok)
    values <- lapply(values, "[", ok)
    has_trailing <- has_trailing[ok]
  }

  complete <- length(hit) == n
  restore <- function(values, missing) {
    if (complete) return(unname(values))
    out <- rep.int(missing, n)
    out[hit] <- values
    out
  }
  est <- restore(values[[1L]], NA_real_)
  lo <- restore(values[[2L]], NA_real_)
  hi <- restore(values[[3L]], NA_real_)
  open <- restore(g[[2L]], NA_character_)
  close <- restore(g[[6L]], NA_character_)
  separators <- c("," = ", ", ";" = "; ", "~" = "~", "\u2013" = "\u2013",
                "\u2014" = "\u2014", "-" = "-", "to" = " to ")[trimws(g[[4]], whitespace = space)]
  # decimals shown = mantissa decimals - exponent ("1.2e-3" -> 4)
  dec <- lapply(g[c(1, 3, 5)], function(s) {
    scientific <- grep("[eE]", s)
    ex <- numeric(length(s))
    if (length(scientific)) {
      ex[scientific] <- as.numeric(sub("^.*[eE]", "", s[scientific]))
      s[scientific] <- sub("[eE].*$", "", s[scientific])
    }
    dotted <- grep(".", s, fixed = TRUE)
    if (length(dotted)) {
      ex[dotted] <- ex[dotted] - nchar(sub("^[-+]?\\d*\\.?", "", s[dotted], perl = TRUE))
    }
    -ex + 0
  })
  d <- restore(pmax(dec[[1L]], dec[[2L]], dec[[3L]], 0L), 2L)
  units <- 10^-do.call(cbind, dec)
  unit <- if (complete) units else {
    full <- matrix(NA_real_, n, 3L)
    full[hit, ] <- units
    full
  }

  trailing <- restore(has_trailing, FALSE)
  list(estimate = est, lower = lo, upper = hi, digits = d,
       open = open, sep = restore(separators, NA_character_), close = close, valid = !is.na(open),
       unit = unit, trailing = trailing)
}

#' @noRd
.ci_scale <- function(est, lo, hi, unit, exp, valid) {
  n <- length(est)
  ue <- unit[, 1L]; ul <- unit[, 2L]; uh <- unit[, 3L]
  if (n > 1024L && is.null(names(est)) && is.null(names(lo)) &&
      is.null(names(hi)) && is.null(names(valid)) && is.null(rownames(unit))) {
    parts <- list(est = est, lo = lo, hi = hi, ue = ue, ul = ul, uh = uh, valid = valid)
    sample <- seq.int(1L, n, length.out = 128L)
    if (vctrs::vec_unique_count(vctrs::new_data_frame(lapply(parts, "[", sample))) < 64L) {
      groups <- vctrs::vec_group_id(vctrs::new_data_frame(parts))
      count <- attr(groups, "n")
      if (count < n / 2L) {
        at <- if (count == 1L) 1L else which(!duplicated(groups, nmax = count))
        result <- .ci_scale(est[at], lo[at], hi[at], unit[at, , drop = FALSE], exp, valid[at])
        return(lapply(result, "[", as.integer(groups)))
      }
    }
  }
  # Rounding moves each printed number by up to half its unit, no further
  invalid <- valid & (lo >= hi | est < lo - (ue / 2 + ul / 2) |
                        est > hi + (ue / 2 + uh / 2))
  ok <- valid & !invalid
  if (!isTRUE(exp)) {
    # Compare the two half-widths before subtracting to preserve small differences.
    span <- hi - lo
    a_lin <- abs((hi - est) - (est - lo)) / span
    r_lin <- (ul / 2 + uh / 2 + ue) / span
    wide <- which(ok & (!is.finite(span) | !is.finite(a_lin) | !is.finite(r_lin)))
    if (length(wide)) {
      wide <- wide[is.finite(est[wide]) & is.finite(lo[wide]) & is.finite(hi[wide])]
    }
    if (length(wide)) {
      magnitude <- pmax(abs(est[wide]), abs(lo[wide]), abs(hi[wide]))
      e <- est[wide] / magnitude; l <- lo[wide] / magnitude; h <- hi[wide] / magnitude
      a_lin[wide] <- abs((h - e) - (e - l)) / (h - l)
      r_lin[wide] <- (ul[wide] / magnitude / 2 + uh[wide] / magnitude / 2 +
                       ue[wide] / magnitude) / (h - l)
    }
  }
  if (identical(exp, FALSE)) {
    return(list(is_exp = rep(FALSE, length(est)), invalid = invalid,
                ambiguous = rep(FALSE, length(est)),
                asymmetric = ok & a_lin - r_lin > 0.2))
  }
  pos <- ok & lo > 0 & est > 0
  all_positive <- all(pos)
  if (isTRUE(exp)) {
    if (!all_positive) invalid <- invalid | (ok & !pos)
    ok <- pos
  }
  if (!any(pos)) {
    unset <- rep.int(FALSE, n)
    return(list(is_exp = unset, invalid = invalid, ambiguous = unset,
                asymmetric = if (isTRUE(exp)) unset else ok & a_lin - r_lin > 0.2))
  }
  log_ratio <- function(a, b) {
    relative <- (a - b) / b
    if (length(relative) && isTRUE(min(relative) > -0.5 && max(relative) < 0.5))
      return(log1p(relative))
    close <- is.finite(relative) & abs(relative) < 0.5
    if (all(close)) return(log1p(relative))
    if (!any(close)) return(log(a) - log(b))
    out <- numeric(length(a))
    out[close] <- log1p(relative[close])
    out[!close] <- log(a[!close]) - log(b[!close])
    out
  }
  if (all_positive) {
    w <- log_ratio(hi, lo)
    a_log <- abs(log_ratio(hi, est) - log_ratio(est, lo)) / w
    r_log <- (ul / lo / 2 + uh / hi / 2 + ue / est) / w
  } else {
    a_log <- rep.int(Inf, n)
    r_log <- numeric(n)
    lower <- lo[pos]
    estimate <- est[pos]
    upper <- hi[pos]
    w <- log_ratio(upper, lower)
    a_log[pos] <- abs(log_ratio(upper, estimate) - log_ratio(estimate, lower)) / w
    r_log[pos] <- (ul[pos] / lower / 2 + uh[pos] / upper / 2 +
                     ue[pos] / estimate) / w
  }

  if (identical(exp, "auto")) {
    # A scale is decided only when its asymmetry beats the other's by more
    # than rounding; bounds <= 0 decide "difference" outright
    log_wins <- pos & (a_lin - r_lin) > (a_log + r_log)
    lin_wins <- ok & (!pos | (a_log - r_log) > (a_lin + r_lin))
    undecided <- ok & !log_wins & !lin_wins
    # A vector usually holds one kind of effect: undecided intervals follow
    # the decided ones when those agree, and are read as ratios otherwise
    has_log_votes <- any(log_wins)
    agree <- has_log_votes != any(lin_wins)
    is_exp <- log_wins | (undecided & (!agree | has_log_votes))
    ambiguous <- undecided & !agree
  } else {
    return(list(is_exp = ok, invalid = invalid, ambiguous = rep(FALSE, length(est)),
                asymmetric = ok & a_log - r_log > 0.2))
  }

  excess <- ifelse(is_exp, a_log - r_log, a_lin - r_lin)
  list(is_exp = is_exp, invalid = invalid, ambiguous = ambiguous,
       asymmetric = ok & excess > 0.2)
}
