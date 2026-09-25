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
#'   an exponent. Full-width punctuation and the Unicode minus are accepted.
#'   Trailing stars are ignored, other trailing text is dropped with a
#'   warning, and \code{NA} / \code{""} pass through silently.
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
#' @param digits Integer, decimal places for output. Default: auto-detect from input.
#' @param map_signif Named numeric vector for star thresholds.
#'   Only used when \code{output} is \code{"ci_star"} or \code{"p_star"}.
#'
#' @details
#' The input is read as a 95\% CI and the p-value is backed out with the
#' normal approximation of Altman & Bland (BMJ 2011;343:d2304):
#' \eqn{SE = (hi - lo) / (2 \times 1.96)} on the working scale.
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
#' @return Character vector (for ci/ci_p/ci_star/p_star) or numeric vector (for p).
#'
#' @examples
#' # Basic: return CI as-is
#' stat_ci_parse("1.23 (0.95, 1.59)")
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
  if (!(identical(exp, "auto") || isTRUE(exp) || isFALSE(exp))) {
    cli::cli_abort("{.arg exp} must be {.val auto}, {.code TRUE} or {.code FALSE}.")
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
  n_fail <- sum(!valid & !is.na(x) & nzchar(trimws(x)))
  if (n_fail > 0L) {
    cli::cli_warn("{n_fail} element{?s} could not be parsed as CI string{?s} and {?was/were} returned as-is.")
  }
  n_tail <- sum(parsed$trailing)
  if (n_tail > 0L) {
    cli::cli_warn("{n_tail} element{?s} had trailing text after the closing bracket, which was dropped.")
  }

  # --- Scale of each interval (ratio -> log scale, null = 0 there) ---
  scale <- .ci_scale(est, lo, hi, parsed$unit, exp, valid)
  is_exp <- scale$is_exp
  asym <- scale$asymmetric
  valid <- valid & !scale$invalid
  n_bad <- sum(scale$invalid)
  if (n_bad > 0L) {
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

  # --- Compute SE and p-value on the working scale ---
  z95 <- qnorm(0.975)
  e_s <- est; l_s <- lo; h_s <- hi
  e_s[is_exp] <- log(est[is_exp])
  l_s[is_exp] <- log(lo[is_exp])
  h_s[is_exp] <- log(hi[is_exp])
  # Full width for symmetric intervals; for asymmetric ones the half facing
  # the null, so that p < 0.05 exactly when the interval excludes the null
  se_of <- function(l, h) {
    ifelse(asym, ifelse(e_s > 0, e_s - l, h - e_s) / z95, (h - l) / (2 * z95))
  }
  se <- se_of(l_s, h_s)

  # --- Adjust CI level; p is then read off the adjusted CI as a 95% CI ---
  if (!is.null(level)) {
    if (level <= 0 || level >= 1) cli::cli_abort("{.arg level} must be between 0 and 1.")
    z_new <- qnorm(1 - (1 - level) / 2)
    l_s <- ifelse(asym, e_s - (e_s - l_s) * z_new / z95, e_s - z_new * se)
    h_s <- ifelse(asym, e_s + (h_s - e_s) * z_new / z95, e_s + z_new * se)
    lo <- ifelse(valid, ifelse(is_exp, exp(l_s), l_s), lo)
    hi <- ifelse(valid, ifelse(is_exp, exp(h_s), h_s), hi)
    se <- se_of(l_s, h_s)
  }
  pval <- ifelse(valid, 2 * (1 - pnorm(abs(e_s / se))), NA_real_)

  # --- Rebuild the CI string in its original bracket/separator style ---
  fmt <- function(v) sprintf("%.*f", d, round(v, d))
  ci_str <- ifelse(valid,
    paste0(fmt(est), " ", parsed$open, fmt(lo), parsed$sep, fmt(hi),
           parsed$close),
    x)

  # --- Return based on output ---
  switch(output,
    ci = ci_str,
    p = pval,
    ci_p = ifelse(valid,
      paste0(ci_str, ", p=", stat_pval(pval, mode = "pvalue")),
      x),
    ci_star = ifelse(valid,
      stat_pval(ci_str, add_star_p = pval, map_signif = map_signif),
      x),
    p_star = ifelse(valid,
      stat_pval(pval, map_signif = map_signif),
      NA_character_)
  )
}


# ---- Internal helpers (not exported) ----

#' @noRd
.ci_extract <- function(x) {
  n <- length(x)
  est <- lo <- hi <- rep(NA_real_, n)
  d <- rep(2L, n)
  open <- close <- sep <- rep(NA_character_, n)
  unit <- matrix(NA_real_, n, 3L)   # rounding unit of est, lower, upper

  # Full-width punctuation and the Unicode minus sign (pasted from Word/PDF)
  xs <- chartr("\u2212\uff08\uff09\uff0c\uff1b\uff5e", "-(),;~", trimws(x))
  xs <- gsub("[* ]+$", "", xs)       # strip trailing stars/spaces
  xs <- gsub("\\.$", "", xs)          # strip single trailing dot

  # est (lower sep upper) -- one pattern for every bracket and separator;
  # groups: 1 est, 2 open, 3 lower, 4 sep, 5 upper, 6 close, 7 trailing text
  num <- "([-+]?(?:\\d+\\.?\\d*|\\.\\d+)(?:[eE][-+]?\\d+)?)"
  re <- paste0("^", num, "\\s*([[(])", num,
               "(\\s*[,;~\u2013\u2014-]\\s*|\\s+to\\s+)", num, "([])])")
  hit <- which(grepl(re, xs, perl = TRUE))
  grab <- function(k) {
    sub(paste0("(?s)", re, "(.*)$"), paste0("\\", k), xs[hit], perl = TRUE)
  }
  g <- lapply(1:7, grab)
  ok <- paste0(g[[2]], g[[6]]) %in% c("()", "[]")
  hit <- hit[ok]
  g <- lapply(g, `[`, ok)

  est[hit] <- as.numeric(g[[1]]); lo[hit] <- as.numeric(g[[3]])
  hi[hit] <- as.numeric(g[[5]])
  open[hit] <- g[[2]]; close[hit] <- g[[6]]
  sep[hit] <- c("," = ", ", ";" = "; ", "~" = "~", "\u2013" = "\u2013",
                "\u2014" = "\u2014", "-" = "-", "to" = " to ")[trimws(g[[4]])]
  # decimals shown = mantissa decimals - exponent ("1.2e-3" -> 4)
  dec <- lapply(g[c(1, 3, 5)], function(s) {
    ex <- ifelse(grepl("[eE]", s), sub("^.*[eE]", "", s), "0")
    nchar(sub("^[-+]?\\d*\\.?", "", sub("[eE].*$", "", s), perl = TRUE)) -
      as.integer(ex)
  })
  d[hit] <- pmax(dec[[1]], 1L)      # output digits follow the estimate
  unit[hit, ] <- 10^-do.call(cbind, dec)

  list(estimate = est, lower = lo, upper = hi, digits = d,
       open = open, sep = sep, close = close, valid = !is.na(open),
       unit = unit, trailing = !is.na(open) & nzchar(trimws(
         replace(rep("", n), hit, g[[7]]))))
}

#' @noRd
.ci_scale <- function(est, lo, hi, unit, exp, valid) {
  ue <- unit[, 1]; ul <- unit[, 2]; uh <- unit[, 3]
  # Rounding moves each printed number by up to half its unit, no further
  invalid <- valid & (lo >= hi | est < lo - (ue + ul) / 2 |
                        est > hi + (ue + uh) / 2)
  ok <- valid & !invalid
  pos <- ok & lo > 0 & est > 0
  if (isTRUE(exp)) {
    invalid <- invalid | (ok & !pos)
    ok <- pos
  }

  # Asymmetry a = |hi + lo - 2 est| / (hi - lo) on each scale, and r = the
  # part of it that rounding alone can produce
  a_lin <- abs(hi + lo - 2 * est) / (hi - lo)
  r_lin <- ((ul + uh) / 2 + ue) / (hi - lo)
  a_log <- rep(Inf, length(est)); r_log <- rep(0, length(est))
  w <- log(hi[pos] / lo[pos])
  a_log[pos] <- abs(log(hi[pos] * lo[pos] / est[pos]^2)) / w
  r_log[pos] <- (ul[pos] / (2 * lo[pos]) + uh[pos] / (2 * hi[pos]) +
                   ue[pos] / est[pos]) / w

  if (identical(exp, "auto")) {
    # A scale is decided only when its asymmetry beats the other's by more
    # than rounding; bounds <= 0 decide "difference" outright
    log_wins <- pos & (a_lin - r_lin) > (a_log + r_log)
    lin_wins <- ok & (!pos | (a_log - r_log) > (a_lin + r_lin))
    undecided <- ok & !log_wins & !lin_wins
    # A vector usually holds one kind of effect: undecided intervals follow
    # the decided ones when those agree, and are read as ratios otherwise
    agree <- any(log_wins) != any(lin_wins)
    is_exp <- log_wins | (undecided & (!agree | any(log_wins)))
    ambiguous <- undecided & !agree
  } else {
    is_exp <- ok & exp
    ambiguous <- rep(FALSE, length(est))
  }

  excess <- ifelse(is_exp, a_log - r_log, a_lin - r_lin)
  list(is_exp = is_exp, invalid = invalid, ambiguous = ambiguous,
       asymmetric = ok & excess > 0.2)
}
