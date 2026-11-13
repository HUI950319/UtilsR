z95 <- qnorm(0.975)
p_of <- function(z) 2 * (1 - pnorm(abs(z)))

test_that("CI scale switches reject dimensional logical flags", {
  for (flag in c(TRUE, FALSE))
    expect_error(stat_ci_parse("2 (1, 4)", exp = matrix(flag)), "exp")
  expect_equal(stat_ci_parse("2 (1, 4)", output = "p", exp = TRUE),
               .05)
})

test_that("relevelled extreme difference intervals avoid intermediate overflow", {
  x <- c("1.0e308 (-1.0e308, 1.5e308)", "1.0e308 (0.0e308, 1.5e308)")
  control <- c("1.0 (-1.0, 1.5)", "1.0 (0.0, 1.5)")
  for (level in c(.5, .8, .9, .95, .99)) {
    expect_warning(actual <- stat_ci_parse(x, output = "p", level = level, exp = FALSE), "not symmetric")
    expect_warning(expected <- stat_ci_parse(control, output = "p", level = level, exp = FALSE), "not symmetric")
    expect_equal(actual, expected)
  }
  expect_warning(ci <- stat_ci_parse(x, level = .8, exp = FALSE), "not symmetric")
  expect_identical(grepl("Inf", ci, fixed = TRUE), c(FALSE, FALSE))
})

test_that("overflowing CI tokens remain unparsed without aborting other intervals", {
  x <- c(estimate = "1e309 (1e308, 1e310)",
         lower = "0 (-1e999, 1)", upper = "0 (-1, 1e999)",
         valid = "2.00 (1.00, 3.00)")
  expect_warning(formatted <- stat_ci(x), "could not be parsed")
  expect_identical(formatted[1:3], x[1:3])
  expect_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE),
                 "could not be parsed")
  expect_identical(unname(p[1:3]), rep(NA_real_, 3))
  expect_equal(unname(p[[4L]]), 2 * stats::pnorm(-2 * stats::qnorm(.975)))
})

test_that("difference intervals retain valid p-values when their SE exceeds double range", {
  large <- c("1.790e308 (-1.790e308, 1.797e308)", "-1.790e308 (-1.797e308, 1.790e308)")
  control <- c("1.790 (-1.790, 1.797)", "-1.790 (-1.797, 1.790)")
  for (level in list(NULL, .95, .9, .99)) {
    expect_warning(actual <- stat_ci_parse(large, output = "p", exp = FALSE, level = level), "not symmetric")
    expect_warning(expected <- stat_ci_parse(control, output = "p", exp = FALSE, level = level), "not symmetric")
    expect_equal(actual, expected, tolerance = 1e-12)
    expect_true(all(is.finite(actual) & actual > 0 & actual < 1))
  }
})

test_that("auto does not read a narrow ratio near 1 as a difference", {
  for (x in c("0.98 (0.95, 1.01)", "1.00 (0.99, 1.01)", "0.95 (0.90, 1.00)")) {
    expect_warning(p <- stat_ci_parse(x, output = "p"), "ratio")
    expect_identical(p, stat_ci_parse(x, output = "p", exp = TRUE))
  }
  se <- (log(1.01) - log(0.95)) / (2 * z95)
  expect_equal(suppressWarnings(stat_ci_parse("0.98 (0.95, 1.01)", output = "p")),
               p_of(log(0.98) / se))
})

test_that("auto borrows the scale of the wider intervals in the same vector", {
  hr <- c("1.50 (1.10, 2.05)", "0.98 (0.95, 1.01)")
  expect_no_warning(p <- stat_ci_parse(hr, output = "p"))
  expect_identical(p, stat_ci_parse(hr, output = "p", exp = TRUE))

  md <- c("-0.50 (-1.00, 0.00)", "1.00 (0.90, 1.10)")
  expect_no_warning(p <- stat_ci_parse(md, output = "p"))
  expect_identical(p, stat_ci_parse(md, output = "p", exp = FALSE))
})

test_that("symmetric intervals keep the full-width p-value and rescaling", {
  expect_no_warning(p <- stat_ci_parse("2.45 (1.20, 4.80)", output = "p"))
  expect_equal(p, p_of(log(2.45) / ((log(4.8) - log(1.2)) / (2 * z95))))
  expect_equal(stat_ci_parse("-0.50 (-0.90, -0.10)", output = "p"),
               p_of(-0.5 / (0.8 / (2 * z95))))

  se <- (log(1.53) - log(0.97)) / (2 * z95)
  z90 <- qnorm(0.95)
  expect_identical(
    stat_ci_parse("1.22 (0.97, 1.53)", level = 0.9),
    sprintf("%.2f (%.2f, %.2f)", 1.22, exp(log(1.22) - z90 * se),
            exp(log(1.22) + z90 * se))
  )
})

test_that("asymmetric intervals use the half facing the null", {
  expect_warning(p <- stat_ci_parse("0.10 (0.01, 0.30)", output = "p",
                                    exp = FALSE), "symmetric")
  expect_equal(p, p_of(0.10 / (0.09 / z95)))
  expect_lt(p, 0.05)

  expect_identical(
    suppressWarnings(stat_ci_parse("2.0 (1.9, 5.0)", level = 0.95)),
    "2.0 (1.9, 5.0)"
  )
  k <- qnorm(0.95) / z95
  expect_identical(
    suppressWarnings(stat_ci_parse("0.05 (-0.02, 0.40)", level = 0.9)),
    sprintf("%.2f (%.2f, %.2f)", 0.05, 0.05 - 0.07 * k, 0.05 + 0.35 * k)
  )
})

test_that("impossible intervals give NA instead of a p-value", {
  bad <- c("1.50 (2.00, 3.00)", "1.50 (2.00, 1.00)")
  expect_warning(p <- stat_ci_parse(bad, output = "p"), "invalid")
  expect_identical(p, c(NA_real_, NA_real_))
  expect_identical(suppressWarnings(stat_ci_parse(bad, output = "ci_star")), bad)

  w <- capture_warnings(p <- stat_ci_parse("0.20 (-0.10, 0.50)",
                                           output = "p", exp = TRUE))
  expect_length(w, 1L)
  expect_match(w, "invalid")
  expect_identical(p, NA_real_)
})

test_that("common manuscript spellings parse to the same interval", {
  ref <- stat_ci_parse("-0.25 (-0.40, -0.10)", output = "p")
  for (x in c("−0.25 (−0.40, −0.10)", "-0.25 (-0.40--0.10)",
              "-0.25（-0.40，-0.10）", "-0.25 (-0.40~-0.10)",
              "-0.25 (-0.40; -0.10)", "-0.25 (-0.40—-0.10)",
              "-0.25 (-0.40～-0.10)", "-2.5e-1 (-4.0e-1, -1.0e-1)",
              "–0.25 (–0.40, –0.10)", "–0.25 (–0.40––0.10)",
              "—0.25 (—0.40 to —0.10)", "–.25 (–.40, –.10)")) {
    expect_no_warning(p <- stat_ci_parse(x, output = "p"))
    expect_equal(p, ref)
  }
  # a dash before a number is a minus sign; between two numbers, the separator
  expect_identical(stat_ci_parse("–0.15 (–0.40–0.10)"), "-0.15 (-0.40–0.10)")
  expect_identical(stat_ci_parse("0.25 (0.10–0.40)"), "0.25 (0.10–0.40)")
  expect_identical(stat_ci_parse("+0.25 (+0.10, +0.40)"), "0.25 (0.10, 0.40)")
  expect_identical(stat_ci_parse("1.23 (0.95~1.59)"), "1.23 (0.95~1.59)")
  expect_identical(stat_ci_parse("1.23 (0.95；1.59)"), "1.23 (0.95; 1.59)")
})

test_that("whitespace inside brackets preserves interval values and style", {
  x <- c(open = "1.00 ( 0.50, 1.50)", close = "1.00 (0.50, 1.50 )",
         square = "1.00 [ 0.50; 1.50 ]", multiline = "1.00 (\t0.50,\n1.50\r\n)")
  expected <- c(open = "1.00 (0.50, 1.50)", close = "1.00 (0.50, 1.50)",
                square = "1.00 [0.50; 1.50]", multiline = "1.00 (0.50, 1.50)")
  expect_no_warning(actual <- stat_ci_parse(x, exp = FALSE))
  expect_identical(actual, expected)
  expect_no_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE))
  expect_identical(p, stat_ci_parse(expected, output = "p", exp = FALSE))
})

test_that("surrounding Unicode whitespace is ignored without trailing-text warnings", {
  x <- c(leading = "\u00a01.00 (0.50, 1.50)",
         trailing = "1.00 (0.50, 1.50)\u00a0",
         mixed = " \t\u00a01.00 (0.50, 1.50)\u00a0\n",
         stars = "\u00a01.00 (0.50, 1.50)\u00a0**\u00a0")
  expected <- stats::setNames(rep("1.00 (0.50, 1.50)", length(x)), names(x))
  expect_no_warning(actual <- stat_ci_parse(x, exp = FALSE))
  expect_identical(actual, expected)
  expect_no_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE))
  expect_identical(p, stat_ci_parse(expected, output = "p", exp = FALSE))
})

test_that("Unicode gaps retain signed numbers, scientific notation and separators", {
  x <- c(comma = "\u20130.25\u00a0(\u00a0\u20130.40\u00a0,\u00a0\u20130.10\u00a0)\u00a0*\u00a0*",
         semicolon = "\u22120.25\uff08\u2003\u20140.40\u00a0;\u00a0\u20140.10\u2003\uff09",
         words = "2.5e-1\u00a0[\u202f1.0e-1\u00a0to\u20034.0e-1\u202f]")
  expected <- c(comma = "-0.25 (-0.40, -0.10)",
                semicolon = "-0.25 (-0.40; -0.10)",
                words = "0.25 [0.10 to 0.40]")
  expect_no_warning(actual <- stat_ci_parse(x, exp = FALSE))
  expect_identical(actual, expected)
  expect_no_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE))
  expect_identical(p, stat_ci_parse(expected, output = "p", exp = FALSE))
})

test_that("whitespace never joins broken numeric tokens or mismatched brackets", {
  x <- c(brackets = "1.00 (\u00a00.50,\u00a01.50 ]",
         estimate = "1.\u00a000 (0.50, 1.50)",
         sign = "1.00 (-\u00a00.50, 1.50)",
         exponent = "1.00 (0.50e\u00a0-1, 1.50)")
  expect_warning(actual <- stat_ci_parse(x, exp = FALSE), "4 elements could not")
  expect_identical(actual, x)
  expect_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE),
                 "4 elements could not")
  expect_identical(p, stats::setNames(rep(NA_real_, length(x)), names(x)))
  expect_warning(actual <- stat_ci_parse(
    "\u00a01.00 (\u00a00.50, 1.50\u00a0)\u00a0footnote\u00a0", exp = FALSE),
    "1 element had trailing text")
  expect_identical(actual, "1.00 (0.50, 1.50)")
})

test_that("whitespace leaves every output and confidence-level calculation unchanged", {
  for (exp in c(TRUE, FALSE)) {
    x <- if (exp) {
      c(effect = "2.00 (1.00, 4.00)", null = "1.00 (0.50, 2.00)")
    } else {
      c(effect = "-0.50 (-0.90, -0.10)", null = "0.00 (-1.00, 1.00)")
    }
    spaced <- gsub("(", "(\u00a0", x, fixed = TRUE)
    spaced <- gsub(")", "\u00a0)", spaced, fixed = TRUE)
    spaced <- stats::setNames(paste0("\u00a0", spaced, "\u00a0"), names(x))
    for (level in list(NULL, .9, .95)) {
      for (output in c("ci", "p", "ci_p", "ci_star", "p_star")) {
        expected <- stat_ci_parse(x, output = output, level = level, exp = exp)
        expect_no_warning(actual <- stat_ci_parse(
          spaced, output = output, level = level, exp = exp))
        expect_identical(actual, expected)
      }
    }
  }
})

test_that("Unicode blanks pass through silently in every output mode", {
  x <- c(missing = NA_character_, empty = "", ascii = " \t\n",
         nbsp = "\u00a0", unicode = "\u00a0\u2003")
  for (output in c("ci", "ci_p", "ci_star", "p", "p_star")) {
    expected <- switch(output,
      p = stats::setNames(rep(NA_real_, length(x)), names(x)),
      p_star = stats::setNames(rep(NA_character_, length(x)), names(x)),
      x)
    expect_no_warning(actual <- stat_ci_parse(x, output = output))
    expect_identical(actual, expected)
  }
  expect_warning(actual <- stat_ci_parse(c(x, reference = "Reference")),
                 "1 element could not")
  expect_identical(actual, c(x, reference = "Reference"))
})

test_that("NA and empty strings pass through silently; other text warns", {
  x <- c("1.23 (0.95, 1.59)", NA, "", "Reference")
  w <- capture_warnings(out <- stat_ci_parse(x, output = "ci"))
  expect_identical(out, x)
  expect_length(w, 1L)
  expect_match(w, "^1 element")
})

test_that("trailing text is dropped with a warning", {
  expect_warning(out <- stat_ci_parse("1.23 (0.95, 1.59), p=0.12"), "trailing")
  expect_identical(out, "1.23 (0.95, 1.59)")
  expect_no_warning(stat_ci_parse(c("1.23 (0.95, 1.59)** ", "1.23 (0.95, 1.59).")))
})

test_that("output keeps the printed precision, sign of zero and names", {
  expect_identical(stat_ci_parse("1.2 (0.95, 1.59)", exp = TRUE),
                   "1.20 (0.95, 1.59)")
  expect_identical(stat_ci_parse("12 (10, 15)", exp = FALSE), "12 (10, 15)")
  expect_identical(stat_ci_parse("0.20 (-0.04, 0.44)", level = 0.9),
                   "0.20 (0.00, 0.40)")
  expect_identical(stat_ci_parse(c(a = "1.23 (0.95, 1.59)")),
                   c(a = "1.23 (0.95, 1.59)"))
  expect_named(stat_ci_parse(c(a = "1.23 (0.95, 1.59)"), output = "p"), "a")
  expect_identical(stat_ci_parse(character(0)), character(0))
  expect_identical(stat_ci_parse(character(0), output = "p"), numeric(0))
})

test_that("empty outputs preserve both named and unnamed vector contracts", {
  for (x in list(character(), setNames(character(), character()))) {
    for (output in c("ci", "p", "ci_p", "ci_star", "p_star")) {
      expected <- if (output == "p") setNames(numeric(), names(x)) else x
      expect_no_warning(actual <- stat_ci_parse(x, output = output,
        level = .9, digits = 0, map_signif = numeric()))
      expect_identical(actual, expected)
    }
  }
})

test_that("level keeps at least one decimal for integer input", {
  expect_identical(stat_ci_parse("2 (1, 3)", level = 0.9, exp = FALSE),
                   "2.0 (1.2, 2.8)")
})

test_that("confidence levels below one retain finite normal quantiles", {
  level <- 1 - .Machine$double.eps / 2
  z <- stats::qnorm((1 - level) / 2, lower.tail = FALSE)
  expected <- sprintf("1.00 (%.2f, %.2f)", 1 - z / z95, 1 + z / z95)
  expect_no_warning(actual <- stat_ci_parse("1.00 (0.00, 2.00)",
                                            level = level, exp = FALSE))
  expect_identical(actual, expected)
  p <- stat_ci_parse("1.00 (0.00, 2.00)", level = level, exp = FALSE, output = "p")
  expect_equal(p, 2 * pnorm(-z95^2 / z))
  expect_true(is.finite(p) && p > .05 && p < 1)
})

test_that("numeric-only CI results preserve names and formatting-limit errors", {
  x <- c(positive = "2.00 (1.00, 3.00)", zero = "0.00 (-1.00, 1.00)", missing = NA_character_)
  expected <- c(positive = 2 * pnorm(-2 * z95), zero = 1, missing = NA_real_)
  reference <- stat_ci_parse(x, output = "p", exp = FALSE, digits = 2)
  expect_equal(reference, expected)
  for (digits in c(7881, 8189)) {
    expect_identical(stat_ci_parse(x, output = "p", exp = FALSE, digits = digits), reference)
  }
  expect_error(stat_ci_parse("-1 (-2, 0)", output = "p", exp = FALSE, digits = 8190),
               "digits.*8192-byte")
})

test_that("an estimate on a printed bound still gets a finite p-value", {
  expect_identical(suppressWarnings(
    stat_ci_parse("1.0 (0.6, 1.0)", output = "p", exp = TRUE)), 1)
  p <- suppressWarnings(stat_ci_parse("1.50 (1.50, 2.00)", output = "p",
                                      exp = TRUE))
  expect_true(is.finite(p) && p < 0.05)
  expect_identical(suppressWarnings(
    stat_ci_parse("1.0 (0.6, 1.0)", output = "ci_p", exp = TRUE)),
    "1.0 (0.6, 1.0), p=1.000")
})

test_that("very small p-values do not underflow to 0", {
  se <- (log(6.25) - log(4)) / (2 * z95)
  p <- stat_ci_parse("5.00 (4.00, 6.25)", output = "p")
  expect_gt(p, 0)
  expect_equal(p, 2 * pnorm(-log(5) / se))
})

test_that("finite extreme ratio intervals avoid intermediate overflow", {
  x <- c("1e200 (5e199, 2e200)", "1e-200 (5e-201, 2e-200)",
         "1 (1e-200, 1e200)")
  expect_no_warning(p <- stat_ci_parse(x, output = "p", exp = TRUE))
  expected <- 2 * pnorm(-abs(log(c(1e200, 1e-200, 1))) /
                         (c(log(4), log(4), 400 * log(10)) / (2 * z95)))
  expect_equal(p, expected)
  expect_true(all(is.finite(p)))

  values <- c(1, 1 - 1e-14, 1 + 3e-14)
  for (scale in c(1, 1e200)) {
    interval <- sprintf("%.17e (%.17e, %.17e)",
                         values[1] * scale, values[2] * scale, values[3] * scale)
    expect_warning(p <- stat_ci_parse(interval, output = "p", exp = TRUE), "not symmetric")
    expect_true(is.finite(p))
  }
})

test_that("finite extreme difference intervals avoid intermediate overflow", {
  x <- c("1e308 (8e307, 1.2e308)", "-1e308 (-1.2e308, -8e307)",
         "1.00e307 (-1.00e308, 1.20e308)")
  reference <- c("1 (0.8, 1.2)", "-1 (-1.2, -0.8)", "0.10 (-1.00, 1.20)")
  expect_no_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE))
  expect_equal(log(p), log(stat_ci_parse(reference, output = "p", exp = FALSE)), tolerance = 1e-12)
  expect_true(all(is.finite(p)))
  expect_warning(auto <- stat_ci_parse(x[1], output = "p"), "treated as ratio")
  expect_identical(auto, stat_ci_parse(x[1], output = "p", exp = TRUE))
  expect_no_warning(auto <- stat_ci_parse("1.00e308 (8.00e307, 1.20e308)", output = "p"))
  expect_equal(log(auto), log(p[1]), tolerance = 1e-12)
  expect_warning(asymmetric <- stat_ci_parse("1.00e308 (-1.00e308, 1.20e308)",
    output = "p", exp = FALSE), "not symmetric")
  expect_warning(control <- stat_ci_parse("1.00 (-1.00, 1.20)", output = "p", exp = FALSE),
    "not symmetric")
  expect_equal(asymmetric, control, tolerance = 1e-12)
})

test_that("ratio rounding allowances remain stable near floating-point limits", {
  est <- c(1.40, 1.67, 1.38, 1.37)
  lo <- c(.9, .95, 1.1, .99)
  hi <- c(1.75, 1.74, 1.79, 1.7)
  unit <- rbind(c(.01, .1, .01), c(.01, .01, .01),
                c(.01, .1, .01), c(.01, .01, .1))
  reference <- UtilsR:::.ci_scale(est, lo, hi, unit, "auto", rep(TRUE, 4))
  large <- UtilsR:::.ci_scale(est * 1e308, lo * 1e308, hi * 1e308,
                             unit * 1e308, "auto", rep(TRUE, 4))
  expect_identical(large, reference)
  expect_warning(stat_ci_parse("1.38e308 (1.1e308, 1.79e308)", output = "p"),
                 "treated as ratio")
})

test_that("ci_p writes p<0.001, not p=<0.001", {
  expect_identical(stat_ci_parse("2.00 (1.50, 2.67)", output = "ci_p"),
                   "2.00 (1.50, 2.67), p<0.001")
  expect_identical(stat_ci_parse("1.23 (0.95, 1.59)", output = "ci_p"),
                   "1.23 (0.95, 1.59), p=0.115")
})

test_that("CI parser rejects dimensional strings and non-scalar controls before empty returns", {
  for (x in list(matrix("2 (1, 3)"), array(character(), c(0, 1, 1)))) {
    expect_error(stat_ci_parse(x), "x")
  }
  for (arg in c("level", "digits")) {
    value <- if (arg == "level") .95 else 2
    for (bad in list(matrix(value), array(value, c(1, 1, 1)),
                     structure(value, class = "unit_count"))) {
      args <- list(x = character())
      args[arg] <- list(bad)
      expect_error(do.call(stat_ci_parse, args), arg)
    }
  }
})

test_that("arguments are validated up front", {
  x <- "1.23 (0.95, 1.59)"
  expect_error(stat_ci_parse(x, exp = "yes"), "exp")
  for (dg in list(-1, NA, 1.5, c(1, 2))) {
    expect_error(stat_ci_parse(x, digits = dg), "digits")
  }
  for (lv in list(c(0.9, 0.95), NA, "0.9", 90)) {
    expect_error(stat_ci_parse(x, level = lv), "level")
  }
  expect_error(stat_ci_parse(x, output = "ci_star", map_signif = 0.05),
               "map_signif")
})

test_that("non-finite and excessive digits fail before coercion or empty returns", {
  for (dg in list(Inf, -Inf, NaN, 8191, .Machine$integer.max + 1, 1e100)) {
    for (x in list("1.23 (0.95, 1.59)", character())) {
      expect_no_warning(expect_error(stat_ci_parse(x, digits = dg), "digits"))
    }
  }
})

test_that("precision respects the formatted-number byte limit", {
  expect_no_warning(positive <- stat_ci_parse("1 (0, 2)", digits = 8190, exp = FALSE))
  expect_identical(nchar(positive), 24581L)
  expect_match(positive, "^1\\.0+ \\(0\\.0+, 2\\.0+\\)$")
  expect_no_warning(negative <- stat_ci_parse("-1 (-2, 0)", digits = 8189, exp = FALSE))
  expect_identical(nchar(negative), 24580L)
  expect_match(negative, "^-1\\.0+ \\(-2\\.0+, 0\\.0+\\)$")
  expect_no_warning(large <- stat_ci_parse("1e308 (8e307, 1.2e308)",
    digits = 7882, exp = FALSE))
  expect_identical(nchar(large), 24580L)

  for (case in list(list("-1 (-2, 0)", 8190),
                   list("1e308 (8e307, 1.2e308)", 7883),
                   list("-1e308 (-1.2e308, -8e307)", 7882))) {
    expect_no_warning(expect_error(stat_ci_parse(case[[1]], digits = case[[2]],
      exp = FALSE), "digits.*8192-byte"))
  }
})

test_that("excessive detected precision fails without integer coercion warnings", {
  for (x in c("1 (0e-8191, 2)", "1 (0e-2147483648, 2)")) {
    expect_no_warning(expect_error(stat_ci_parse(x, exp = FALSE), "detected.*digits"))
  }
  expect_no_warning(out <- stat_ci_parse("1 (0e-8190, 2)", exp = FALSE))
  expect_identical(nchar(out), 24581L)
  expect_warning(invalid <- stat_ci_parse("9 (0e-8191, 2)", exp = FALSE), "invalid")
  expect_identical(invalid, "9 (0e-8191, 2)")
})

test_that("star outputs share the stat_pval significance map contract", {
  x <- c(a = "2.00 (1.00, 3.00)", b = "0.00 (-1.00, 1.00)")
  p <- stat_ci_parse(x, output = "p", exp = FALSE)
  maps <- list(numeric(), setNames(.05, ""),
               c(loose = 1, first = .05, second = .05))
  for (map in maps) {
    expect_identical(stat_ci_parse(x, output = "ci_star", exp = FALSE, map_signif = map),
                     stat_pval(x, add_star_p = p, map_signif = map))
    expect_identical(stat_ci_parse(x, output = "p_star", exp = FALSE, map_signif = map),
                     stat_pval(p, map_signif = map))
  }
  invalid <- list(.05, c("*" = NA_real_), c("*" = Inf), c("*" = -.1),
                  c("*" = 1.2), setNames(.05, NA_character_), matrix(.05),
                  structure(.05, class = "integer64"))
  for (map in invalid) {
    for (output in c("ci_star", "p_star")) {
      expect_error(stat_ci_parse(x, output = output, map_signif = map), "map_signif")
      expect_error(stat_ci_parse(character(), output = output, map_signif = map), "map_signif")
    }
  }
  expect_identical(stat_ci_parse(x, output = "ci", exp = FALSE, map_signif = "ignored"), x)
  expect_identical(eval(formals(stat_ci_parse)$map_signif),
                   c("***" = .001, "**" = .01, "*" = .05))
})

test_that("subnormal difference intervals preserve scale invariant P values", {
  tiny <- c("5e-324 (0, 1e-323)", "1e-320 (0, 2e-320)")
  control <- c(".5 (0, 1)", "1 (0, 2)")
  for (level in list(NULL, .9, .95, .99))
    expect_equal(stat_ci_parse(tiny, exp = FALSE, level = level, output = "p"),
                 stat_ci_parse(control, exp = FALSE, level = level, output = "p"), tolerance = 1e-12)
})

test_that("original confidence level preserves exact stored ratio bounds", {
  x <- c("1e200 (5e199, 2e200)", "1e-200 (5e-201, 2e-200)")
  expect_identical(stat_ci_parse(x, exp = TRUE, level = .95, digits = 1),
                   stat_ci_parse(x, exp = TRUE, digits = 1))
  expect_equal(stat_ci_parse(x, exp = TRUE, level = .95, output = "p"),
               stat_ci_parse(x, exp = TRUE, output = "p"))
})

test_that("CI stars followed by a terminal period are harmless suffixes", {
  x <- c("1 (0, 2)***.", "1 (0, 2) * . ")
  expect_warning(formatted <- stat_ci(x), NA)
  expect_identical(formatted, rep(stat_ci("1 (0, 2)"), 2L))
  expect_warning(p <- stat_ci_parse(x, exp = FALSE, output = "p"), NA)
  expect_equal(p, rep(.05, 2L))
  expect_warning(stat_ci("1 (0, 2) note."), "trailing text")
})

test_that("narrow ratio intervals retain their widths around extreme estimates", {
  for (estimate in c(1e200, 1e-200)) {
    lower <- estimate * (1 - 1e-14)
    upper <- estimate * (1 + 1e-14)
    x <- sprintf("%.17g (%.17g, %.17g)", estimate, lower, upper)
    for (level in c(.8, .9, .99)) {
      result <- stat_ci_parse(x, exp = TRUE, level = level, digits = 230)
      parsed <- .ci_extract(result)
      bounds <- c(parsed$lower, parsed$upper)
      ratio <- stats::qnorm((1 - level) / 2, lower.tail = FALSE) / stats::qnorm(.975)
      expect_lt(bounds[[1L]], estimate)
      expect_gt(bounds[[2L]], estimate)
      expect_equal((bounds - estimate) / (upper - lower), c(-ratio / 2, ratio / 2), tolerance = .03)
    }
  }
})

test_that("long scientific CI mantissas retain finite estimates and bounds", {
  long <- function(value) paste0(value, strrep("0", 5000L), "e-5000")
  short <- c("1 (0, 2)", "-1 (-2, 0)", "2 (1, 3)")
  input <- c(paste0(long(1), " (", long(0), ", ", long(2), ")"),
             paste0(long(-1), " (", long(-2), ", ", long(0), ")"),
             paste0(long(2), " (", long(1), ", ", long(3), ")"))
  expect_no_warning(actual <- stat_ci_parse(input, exp = FALSE, output = "p"))
  expect_equal(actual, stat_ci_parse(short, exp = FALSE, output = "p"))
  expect_no_warning(formatted <- stat_ci(input, digits = 2))
  expect_identical(formatted, stat_ci(short, digits = 2))
  expect_true(all(.ci_extract(input)$valid))
})

test_that("repeated CI vectors avoid rescanning every occurrence", {
  fn <- .ci_extract
  e <- new.env(parent = environment(fn))
  examined <- 0L
  e$grepl <- function(pattern, x, ...) {
    examined <<- examined + length(x)
    base::grepl(pattern, x, ...)
  }
  environment(fn) <- e
  e$.ci_extract <- fn
  catalog <- c("1.2 (0.8, 1.6)", "-1 [-2;0]", "bad", NA_character_, "1 (0, 2) note")
  x <- rep(catalog, 2000)
  actual <- fn(x)
  expect_lt(examined, length(x))
  reference <- .ci_extract(catalog)
  index <- rep(seq_along(catalog), 2000)
  expected <- lapply(reference, function(value) {
    if (is.matrix(value)) value[index, , drop = FALSE] else value[index]
  })
  expect_identical(actual, expected)
  expect_warning(stat_ci(rep("bad", 2000)), "2000.*could not be parsed")
})

test_that("parsed interval formatting reuses repeated value precision pairs", {
  fn <- stat_ci_parse
  e <- new.env(parent = environment(fn))
  formatted <- 0L
  e$sprintf <- function(fmt, ...) {
    if (identical(fmt, "%.*f")) formatted <<- formatted + max(lengths(list(...)))
    base::sprintf(fmt, ...)
  }
  environment(fn) <- e
  keys <- c("1.00 (0.90, 1.10)", "2.000 [1.900; 2.100]", "0.000 (-0.005, 0.005)")
  x <- stats::setNames(rep(keys, 1500), paste0("row", seq_len(4500)))
  for (output in c("ci", "ci_p", "ci_star", "p_star")) for (digits in list(NULL, 0L, 8L)) {
    expected <- stats::setNames(rep(stat_ci_parse(keys, output = output, digits = digits, exp = FALSE), 1500), names(x))
    formatted <- 0L
    expect_identical(fn(x, output = output, digits = digits, exp = FALSE), expected)
    expect_lt(formatted, 2L * length(x))
  }
  invalid <- rep(c(keys, "bad", NA_character_), 300)
  expect_warning(result <- fn(invalid, exp = FALSE), "300 elements could not be parsed")
  expect_identical(result[invalid %in% "bad"], rep("bad", 300))
  expect_identical(is.na(result), is.na(invalid))
})

test_that("long malformed decimal tokens retain parser diagnostics", {
  bad <- paste0(strrep("9", 5000L), "x")
  warnings <- character()
  withCallingHandlers(expect_error(stat_pval(bad), "numeric strings"),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    })
  expect_identical(warnings, character())
  for (input in c(bad, paste0("1 (", bad, ", 2)"), paste0("1 (0, ", bad, ")"))) {
    for (fn in list(stat_ci, stat_ci_parse)) {
      warnings <- character()
      actual <- withCallingHandlers(fn(input), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      })
      expect_identical(actual, input)
      expect_length(warnings, 1L)
      expect_match(warnings, "1 element could not be parsed")
    }
  }
  expect_true(all(.ci_extract(c("+1. (0, 2.)", ".1 [.0; .2]", "1e-1 (0e0, 2e-1)"))$valid))
})

test_that("parsed confidence intervals preserve subnormal two sided probabilities", {
  z <- c(37, 38, 38.5, 39)
  half <- stats::qnorm(.975)
  ci <- sprintf("%.17g (%.17g, %.17g)", z, z - half, z + half)
  result <- stat_ci_parse(ci, exp = FALSE, output = "p")
  derived_z <- z * (2 * half) / ((z + half) - (z - half))
  expected <- exp(log(2) + stats::pnorm(-derived_z, log.p = TRUE))
  expect_gt(result[2L], 0)
  expect_identical(result[3:4], expected[3:4])
  expect_equal(result[2L] / expected[2L], 1, tolerance = 1e-7)
  expect_identical(result[1L], 2 * stats::pnorm(-z[1L] / (((z + half) - (z - half))[1L] / (2 * half))))
})

test_that("confidence interval extraction matches each full pattern once", {
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  matches <- 0L
  count <- function(pattern) {
    if (grepl("([[(])", pattern, fixed = TRUE)) matches <<- matches + 1L
  }
  env$grepl <- function(pattern, ...) { count(pattern); base::grepl(pattern, ...) }
  env$sub <- function(pattern, ...) { count(pattern); base::sub(pattern, ...) }
  env$regexpr <- function(pattern, ...) { count(pattern); base::regexpr(pattern, ...) }
  environment(fn) <- env
  d <- c("2 (1, 3)", "4 [3 to 5] notes\nmore", "1 (0, 2]", NA_character_,
    "\u22122\uff08\u22123\uff0c\u22121\uff09")
  result <- fn(d)
  expect_identical(matches, 1L)
  expect_equal(result$estimate, c(2, 4, NA, NA, -2))
  expect_identical(result$valid, c(TRUE, TRUE, FALSE, FALSE, TRUE))
  expect_identical(result$trailing, c(FALSE, TRUE, FALSE, FALSE, FALSE))
  expect_identical(result$sep, c(", ", " to ", NA, NA, ", "))
  expect_length(fn(character())$estimate, 0L)
})

test_that("interval suffix trimming handles long malformed annotation runs", {
  text <- paste0("2 (1, 3)", strrep("*", 25000L), "annotation")
  elapsed <- system.time(parsed <- .ci_extract(text))[["elapsed"]]
  expect_lt(elapsed, 2)
  expect_identical(parsed$valid, TRUE)
  expect_identical(parsed$trailing, TRUE)
  good <- .ci_extract(c("2 (1, 3) **. *", "2 (1, 3) **. suffix", "2 (1, 3)\u3000**"))
  expect_identical(good$trailing, c(FALSE, TRUE, FALSE))
})

test_that("significance output skips rebuilding parsed confidence intervals", {
  x <- c(null = "0 (-1, 1)", nonnull = "2 (1, 3)", missing = NA_character_)
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  rebuilt <- 0L
  env$sprintf <- function(fmt, ...) {
    if (identical(fmt, "%.*f")) rebuilt <<- rebuilt + 1L
    base::sprintf(fmt, ...)
  }
  environment(fn) <- env
  expected <- stat_pval(stat_ci_parse(x, exp = FALSE, output = "p"))
  actual <- fn(x, exp = FALSE, output = "p_star")
  expect_identical(rebuilt, 0L)
  expect_identical(actual, expected)
  expect_identical(names(actual), names(x))
  expect_error(fn("-1 (-2, 0)", digits = 8190L, exp = FALSE, output = "p_star"),
    "digits.*8192-byte")
})

test_that("interval whitespace preprocessing handles long interior runs", {
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  trims <- 0L
  env$trimws <- function(x, ...) {
    if (any(nchar(x) > 4000L, na.rm = TRUE)) trims <<- trims + 1L
    base::trimws(x, ...)
  }
  environment(fn) <- env
  padding <- strrep(" ", 12000L)
  x <- c(paste0("invalid", padding, "suffix"),
    paste0("2 (1, 3)", padding, "annotation"), "\u00a0\u2003 2 [1 to 3]\u00a0",
    "2 (1, 3) **. \n", "2 (1, 3)\n continuation", NA_character_)
  parsed <- fn(x)
  expect_identical(trims, 0L)
  expect_identical(parsed$valid, c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE))
  expect_identical(parsed$trailing, c(FALSE, TRUE, FALSE, FALSE, TRUE, FALSE))
  expect_equal(parsed$estimate, c(NA, 2, 2, 2, 2, NA))
})

test_that("CI diagnostics skip trimming full strings", {
  forbid_full_trim <- function(x, ...) {
    if (any(nchar(x) > 1000L, na.rm = TRUE)) stop("CI diagnostics trimmed a full input")
    base::trimws(x, ...)
  }
  parser <- stat_ci_parse
  formatter <- stat_ci
  environment(parser) <- list2env(list(trimws = forbid_full_trim), parent = environment(parser))
  environment(formatter) <- list2env(list(trimws = forbid_full_trim), parent = environment(formatter))
  padding <- strrep(" ", 12000L)
  input <- c(ok = paste0("2", padding, "(1, 3)"), blank = "\u00a0\n", absent = NA,
             malformed = paste0("no", padding, "interval"))
  expect_warning(parsed <- parser(input, output = "ci", exp = FALSE), "1 element could not be parsed")
  expect_warning(formatted <- formatter(input, sep = ", "), "1 element could not be parsed")
  expect_identical(parsed[1L], c(ok = "2 (1, 3)"))
  expect_identical(formatted, parsed)
})

test_that("interval-only output skips normal tail probabilities", {
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$pnorm <- function(...) stop("calculated an unused p-value")
  environment(fn) <- env
  x <- c(first = "2.00 (1.00, 3.00)", second = "1.00 [0.50, 1.50]")
  expect_identical(fn(x, output = "ci", exp = FALSE, level = .9),
                   stat_ci_parse(x, output = "ci", exp = FALSE, level = .9))
})

test_that("mixed parsed intervals format only valid endpoints", {
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$sprintf <- function(fmt, ...) {
    if (identical(fmt, "%.*f") && length(list(...)[[2L]]) > 2L) stop("formatted invalid endpoints")
    base::sprintf(fmt, ...)
  }
  environment(fn) <- env
  x <- c("2.00 (1.00, 3.00)", rep(NA_character_, 25L), "", "1.00 [0.50, 1.50]")
  for (output in c("ci", "ci_p", "ci_star", "p", "p_star")) {
    expect_identical(fn(x, output, exp = FALSE), stat_ci_parse(x, output, exp = FALSE))
  }
})

test_that("empty interval sets skip normal quantile calculations", {
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$qnorm <- function(...) stop("computed a quantile with no valid intervals")
  environment(fn) <- env
  x <- c(blank = "", missing = NA_character_)
  for (output in c("ci", "ci_p", "ci_star", "p", "p_star")) {
    expect_identical(fn(x, output, exp = FALSE), stat_ci_parse(x, output, exp = FALSE))
  }
  expect_warning(out <- fn(c("Reference", ""), "p", exp = FALSE), "could not be parsed")
  expect_identical(out, c(NA_real_, NA_real_))
})

test_that("unchanged CI strings skip inference work while keeping precision", {
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$qnorm <- function(...) stop("calculated an unused standard error")
  environment(fn) <- env
  x <- stats::setNames(c("2 (1, 3)", "1.25 [1.00, 1.50]", NA), c("first", "second", "third"))
  expect_identical(fn(x, output = "ci", exp = FALSE), x)
  expect_identical(fn(x, output = "ci", exp = FALSE, level = .95),
    stats::setNames(c("2.0 (1.0, 3.0)", "1.25 [1.00, 1.50]", NA), names(x)))
})

test_that("CI parsing skips token extraction when no rows match", {
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  env$.parse_decimal_tokens <- function(...) stop("extracted tokens from empty matches")
  environment(fn) <- env
  for (x in list(character(), c(NA, "", "unparsed", "1-2"))) {
    out <- fn(x)
    expect_identical(out$valid, rep(FALSE, length(x)))
    expect_identical(out$digits, rep(2L, length(x)))
    expect_identical(out$trailing, rep(FALSE, length(x)))
    expect_identical(out$unit, matrix(NA_real_, length(x), 3L))
  }
})

test_that("sparsely repeated CI strings skip full deduplication", {
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  env$unique <- function(x, ...) {
    if (length(x) > 1024L) stop("hashed the full near-unique interval vector")
    base::unique(x, ...)
  }
  environment(fn) <- env
  n <- 4100L
  x <- sprintf("%d (%d, %d)", seq_len(n), seq_len(n) - 1L, seq_len(n) + 1L)
  sampled <- seq.int(1L, n, length.out = 1024L)
  x[sampled[2L]] <- x[sampled[1L]]
  x[3L] <- NA_character_
  expect_identical(fn(x), .ci_extract(x))
  expect_identical(fn(x)$estimate[sampled[1:2]], rep(1, 2L))
})

test_that("tiny positive confidence levels retain finite inferred p-values", {
  level <- 1e-20
  z <- sqrt(pi / 2) * level
  se <- 1 / stats::qnorm(.975)
  x <- c(positive = "1e-30 (-1, 1)", negative = "-1e-30 (-1, 1)")
  expected <- rep(2 * stats::pnorm(-1e-30 / (z * se * se)), 2L)
  expect_equal(stat_ci_parse(x, output = "p", exp = FALSE, level = level),
               stats::setNames(expected, names(x)), tolerance = 1e-13)
  expect_identical(stat_ci_parse("0 (-1, 1)", output = "p", exp = FALSE, level = level), 1)
})

test_that("linear interval asymmetry survives large common offsets", {
  x <- "1000000000000000.0000 (999999999999999.8750, 1000000000000000.2500)"
  expect_warning(out <- stat_ci_parse(x, exp = FALSE, level = .9, digits = 4),
                 "not symmetric")
  expect_identical(out, x)
  symmetric <- "1000000000000000.0000 (999999999999999.7500, 1000000000000000.2500)"
  expect_no_warning(stat_ci_parse(symmetric, exp = FALSE, level = .9, digits = 4))
})
