# ============================================================================
# ci_parse.R -- Parse CI strings, compute p-values, adjust confidence levels
# ============================================================================

#' Parse Confidence Interval Strings
#'
#' Extract components from CI strings like \code{"1.23 (0.95, 1.59)"},
#' compute p-values, adjust confidence levels, and optionally add stars.
#'
#' @param x Character vector of CI strings (e.g. \code{"1.23 (0.95, 1.59)"}).
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
#' @param exp Exp-transformation detection:
#'   \code{"auto"} (default), \code{TRUE}, or \code{FALSE}.
#' @param digits Integer, decimal places for output. Default: auto-detect from input.
#' @param map_signif Named numeric vector for star thresholds.
#'   Only used when \code{output} is \code{"ci_star"} or \code{"p_star"}.
#'
#' @return Character vector (for ci/ci_p/ci_star/p_star) or numeric vector (for p).
#'
#' @examples
#' # Basic: return CI as-is
#' ci_parse("1.23 (0.95, 1.59)")
#'
#' # Extract p-value
#' ci_parse("2.45 (1.20, 4.80)", output = "p")
#'
#' # CI with stars
#' ci_parse(c("2.45 (1.20, 4.80)", "1.23 (0.95, 1.59)"), output = "ci_star")
#'
#' # CI with p-value
#' ci_parse("2.45 (1.20, 4.80)", output = "ci_p")
#'
#' # Adjust confidence level
#' ci_parse("1.23 (0.95, 1.59)", level = 0.90)
#'
#' # In mutate()
#' # df %>% mutate(p = ci_parse(hr_ci, output = "p"))
#' # df %>% mutate(hr_star = ci_parse(hr_ci, output = "ci_star"))
#'
#' @export
ci_parse <- function(x,
                     output = c("ci", "p", "ci_p", "ci_star", "p_star"),
                     level = NULL,
                     exp = "auto",
                     digits = NULL,
                     map_signif = c("***" = 0.001, "**" = 0.01, "*" = 0.05)) {

  output <- match.arg(output)
  if (!is.character(x)) cli::cli_abort("{.arg x} must be a character vector.")

  # --- Parse CI strings ---
  parsed <- .ci_extract(x)
  est <- parsed$estimate
  lo  <- parsed$lower
  hi  <- parsed$upper
  d   <- parsed$digits
  fmt_template <- parsed$format
  valid <- parsed$valid

  # Override digits
  if (!is.null(digits)) d[] <- as.integer(digits)

  # --- Detect exp transformation per element ---
  is_exp <- vapply(seq_along(x), function(i) {
    if (!valid[i]) return(FALSE)
    if (isTRUE(exp)) return(TRUE)
    if (isFALSE(exp)) return(FALSE)
    .is_exp(est[i], lo[i], hi[i])
  }, logical(1))

  # --- Compute SE and p-value ---
  z95 <- qnorm(0.975)
  se <- ifelse(valid,
    ifelse(is_exp,
      (log(hi) - log(lo)) / (2 * z95),
      (hi - lo) / (2 * z95)
    ), NA_real_)

  null_val <- ifelse(is_exp, 1, 0)
  z_stat <- ifelse(valid,
    ifelse(is_exp,
      (log(est) - log(null_val)) / se,
      (est - null_val) / se
    ), NA_real_)
  pval <- ifelse(valid, 2 * (1 - pnorm(abs(z_stat))), NA_real_)

  # --- Adjust CI level and recompute p-value from adjusted CI ---
  if (!is.null(level)) {
    if (level <= 0 || level >= 1) cli::cli_abort("{.arg level} must be between 0 and 1.")
    z_new <- qnorm(1 - (1 - level) / 2)
    lo <- ifelse(valid,
      ifelse(is_exp, exp(log(est) - z_new * se), est - z_new * se),
      lo)
    hi <- ifelse(valid,
      ifelse(is_exp, exp(log(est) + z_new * se), est + z_new * se),
      hi)
    # Recompute SE and p-value treating the adjusted CI as 95% CI
    se_adj <- ifelse(valid,
      ifelse(is_exp,
        (log(hi) - log(lo)) / (2 * z95),
        (hi - lo) / (2 * z95)
      ), NA_real_)
    z_stat_adj <- ifelse(valid,
      ifelse(is_exp,
        (log(est) - log(null_val)) / se_adj,
        (est - null_val) / se_adj
      ), NA_real_)
    pval <- ifelse(valid, 2 * (1 - pnorm(abs(z_stat_adj))), NA_real_)
  }

  # --- Format CI string ---
  ci_str <- ifelse(valid,
    mapply(function(e, l, h, dd, tmpl) {
      sprintf(tmpl, round(e, dd), round(l, dd), round(h, dd))
    }, est, lo, hi, d, fmt_template, USE.NAMES = FALSE),
    x)

  # --- Stars helper ---
  .get_stars <- function(p, map) {
    map <- sort(map)
    vapply(p, function(pv) {
      if (is.na(pv)) return("")
      hit <- map[map >= pv]
      if (length(hit) > 0L) names(which.min(hit)) else ""
    }, character(1))
  }

  # --- Return based on output ---
  switch(output,
    ci = ci_str,
    p = pval,
    ci_p = ifelse(valid,
      paste0(ci_str, ", p=", fmt_p(pval, mode = "pvalue")),
      x),
    ci_star = ifelse(valid,
      paste0(ci_str, .get_stars(pval, map_signif)),
      x),
    p_star = ifelse(valid,
      fmt_p(pval),
      NA_character_)
  )
}


# ---- Internal helpers (not exported) ----

#' @noRd
.ci_extract <- function(x) {
  n <- length(x)
  est <- lo <- hi <- rep(NA_real_, n)
  d <- rep(2L, n)
  fmt <- rep("%%.%1$df (%%.%1$df, %%.%1$df)", n)
  valid <- rep(FALSE, n)

  # Regex patterns: est (bracket_open) lower sep upper (bracket_close)
  patterns <- list(
    list(re = "^([0-9.-]+)\\s*\\(([0-9.-]+)\\s*[,]\\s*([0-9.-]+)\\)",
         tmpl = "%%.%1$df (%%.%1$df, %%.%1$df)"),
    list(re = "^([0-9.-]+)\\s*\\(([0-9.-]+)\\s*\u2013\\s*([0-9.-]+)\\)",
         tmpl = "%%.%1$df (%%.%1$df\u2013%%.%1$df)"),
    list(re = "^([0-9.-]+)\\s*\\(([0-9.-]+)\\s*-\\s*([0-9.-]+)\\)",
         tmpl = "%%.%1$df (%%.%1$df-%%.%1$df)"),
    list(re = "^([0-9.-]+)\\s*\\[([0-9.-]+)\\s*[,]\\s*([0-9.-]+)\\]",
         tmpl = "%%.%1$df [%%.%1$df, %%.%1$df]"),
    list(re = "^([0-9.-]+)\\s*\\[([0-9.-]+)\\s*\u2013\\s*([0-9.-]+)\\]",
         tmpl = "%%.%1$df [%%.%1$df\u2013%%.%1$df]"),
    list(re = "^([0-9.-]+)\\s*\\[([0-9.-]+)\\s*-\\s*([0-9.-]+)\\]",
         tmpl = "%%.%1$df [%%.%1$df-%%.%1$df]"),
    list(re = "^([0-9.-]+)\\s*\\(([0-9.-]+)\\s+to\\s+([0-9.-]+)\\)",
         tmpl = "%%.%1$df (%%.%1$df to %%.%1$df)"),
    list(re = "^([0-9.-]+)\\s*\\[([0-9.-]+)\\s+to\\s+([0-9.-]+)\\]",
         tmpl = "%%.%1$df [%%.%1$df to %%.%1$df]")
  )

  for (i in seq_len(n)) {
    xi <- trimws(x[i])
    xi <- gsub("[*. ]+$", "", xi)  # strip trailing stars/dots/spaces
    if (is.na(xi) || nchar(xi) == 0) next

    for (pat in patterns) {
      m <- regmatches(xi, regexec(pat$re, xi))[[1]]
      if (length(m) == 4) {
        e <- suppressWarnings(as.numeric(m[2]))
        l <- suppressWarnings(as.numeric(m[3]))
        h <- suppressWarnings(as.numeric(m[4]))
        if (!is.na(e) && !is.na(l) && !is.na(h)) {
          est[i] <- e; lo[i] <- l; hi[i] <- h
          valid[i] <- TRUE
          # Detect digits from estimate string
          dec <- sub("^-?[0-9]*\\.?", "", m[2])
          d[i] <- max(nchar(dec), 1L)
          # Build sprintf template with detected digits
          fmt[i] <- sprintf(pat$tmpl, d[i])
          break
        }
      }
    }
  }

  list(estimate = est, lower = lo, upper = hi,
       digits = d, format = fmt, valid = valid)
}

#' @noRd
.is_exp <- function(est, lower, upper) {
  # Negative values → definitely not exp-transformed

  if (any(c(lower, upper) <= 0, na.rm = TRUE)) return(FALSE)
  # Geometric mean ≈ estimate → exp; Arithmetic mean ≈ estimate → non-exp
  geo  <- sqrt(lower * upper)
  arith <- (lower + upper) / 2
  abs(est - geo) < abs(est - arith)
}
