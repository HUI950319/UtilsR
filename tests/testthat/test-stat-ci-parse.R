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

test_that("linear confidence checks bypass log-scale asymmetry", {
  x <- c("2.00 (1.00, 3.00)", "2.00 (3.00, 5.00)", "0 (-1, 1)")
  expected <- suppressWarnings(stat_ci_parse(x, exp = FALSE, output = "p"))
  fn <- .ci_scale
  env <- new.env(parent = environment(fn))
  env$log <- function(...) stop("computed log asymmetry for a linear interval")
  environment(fn) <- env
  testthat::local_mocked_bindings(.ci_scale = fn, .package = "UtilsR")
  expect_warning(actual <- stat_ci_parse(x, exp = FALSE, output = "p"), "invalid")
  expect_identical(actual, expected)
})

test_that("interval dash normalization visits only strings with Unicode dashes", {
  x <- c(rep("0 (-1, 1)", 500L), "\u20131 (\u20132 to 0)", "1 (0\u20132)", NA)
  expected <- .ci_extract(x)
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  env$gsub <- function(pattern, replacement, x, ...) {
    if (grepl("\u2013", pattern, fixed = TRUE) && length(x) > 2L)
      stop("rewrote Unicode dashes in ASCII intervals")
    base::gsub(pattern, replacement, x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x), expected)
  expect_true(all(expected$valid[501:502]))
})

test_that("interval formatters isolate malformed text encodings", {
  for (encoding in c("UTF-8", "bytes")) {
    bad <- rawToChar(as.raw(255L))
    Encoding(bad) <- encoding
    x <- c(good = "1 (0, 2)", bad = bad, blank = "", missing = NA_character_)
    expect_warning(out <- stat_ci_parse(x, exp = FALSE, digits = 2), "1 element.*could not")
    expect_identical(out[["good"]], "1.00 (0.00, 2.00)")
    expect_identical(out[["bad"]], bad)
    expect_warning(p <- stat_ci_parse(x, exp = FALSE, output = "p"), "1 element.*could not")
    expect_true(is.finite(p[["good"]]))
    expect_true(is.na(p[["bad"]]))
    expect_warning(formatted <- stat_ci(x, digits = 2), "1 element.*could not")
    expect_identical(formatted[["bad"]], bad)
  }
})

test_that("CI with p-values assembles the decimal separator directly", {
  x <- c(strong = "9.0 (8.0, 10.0)", weak = "0 (-1, 1)", missing = NA_character_, bad = "text")
  expected <- suppressWarnings(stat_ci_parse(x, exp = FALSE, output = "ci_p"))
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$sub <- function(pattern, replacement, x, ...) {
    if (identical(pattern, "=<")) stop("rewrote complete CI strings to attach the p-value")
    base::sub(pattern, replacement, x, ...)
  }
  environment(fn) <- env
  actual <- suppressWarnings(fn(x, exp = FALSE, output = "ci_p"))
  expect_identical(actual, expected)
  expect_match(actual[["strong"]], "p<0.001", fixed = TRUE)
  expect_match(actual[["weak"]], "p=1.000", fixed = TRUE)
})

test_that("ratio confidence checks bypass linear asymmetry", {
  x <- c("2.00 (1.00, 4.00)", "1 (0, 2)", "9 (3, 27)", NA)
  expected <- suppressWarnings(stat_ci_parse(x, exp = TRUE, output = "p"))
  fn <- .ci_scale
  env <- new.env(parent = environment(fn))
  env$abs <- function(x) {
    if (identical(substitute(x), quote((hi - est) - (est - lo))))
      stop("computed additive asymmetry for a ratio interval")
    base::abs(x)
  }
  environment(fn) <- env
  local_mocked_bindings(.ci_scale = fn, .package = "UtilsR")
  expect_warning(actual <- stat_ci_parse(x, exp = TRUE, output = "p"), "invalid")
  expect_identical(actual, expected)
})

test_that("unparsed confidence intervals skip scale inference", {
  testthat::local_mocked_bindings(.ci_scale = function(...) stop("inferred scales without valid intervals"))
  d <- c(a = NA_character_, b = "", c = "not an interval")
  expect_warning(actual <- stat_ci_parse(d, output = "p"), "could not be parsed")
  expect_identical(actual, c(a = NA_real_, b = NA_real_, c = NA_real_))
  expect_warning(actual <- stat_ci_parse(d, output = "ci"), "could not be parsed")
  expect_identical(actual, d)
  expect_identical(stat_ci_parse(c(a = NA_character_, b = ""), output = "p_star"),
    c(a = NA_character_, b = NA_character_))
})

test_that("nearby confidence interval endpoints skip redundant logarithms", {
  estimate <- c(1.1, 1.2, 1.3)
  lower <- estimate/1.1
  upper <- estimate*1.1
  unit <- matrix(.001, length(estimate), 3L)
  entries <- list(estimate, lower, upper, unit, TRUE, rep(TRUE, length(estimate)))
  expected <- do.call(.ci_scale, entries)
  fn <- .ci_scale
  env <- new.env(parent = environment(fn))
  env$log <- function(...) stop("computed unnecessary logarithms of nearby endpoints")
  environment(fn) <- env
  expect_identical(do.call(fn, entries), expected)
})

test_that("repeated confidence intervals share tuple scale diagnostics", {
  at <- rep(1:4, 600)
  est <- c(2, 0, 3, NA_real_)[at]
  lo <- c(1, -1, 1, NA_real_)[at]
  hi <- c(4, 1, 5, NA_real_)[at]
  unit <- matrix(rep(c(0.1, 0.01, 0.1)[rep(1:3, each = length(at))], 1), ncol = 3)
  valid <- !is.na(est)
  fn <- .ci_scale
  environment(fn) <- list2env(list(log = function(x, ...) {
    if (length(x) > 8L) stop("repeated interval logarithms")
    base::log(x, ...)
  }, log1p = function(x) {
    if (length(x) > 8L) stop("repeated interval logarithms")
    base::log1p(x)
  }), parent = environment(fn))
  for (exponentiate in list("auto", TRUE, FALSE))
    expect_identical(fn(est, lo, hi, unit, exponentiate, valid),
      .ci_scale(est, lo, hi, unit, exponentiate, valid))
})

test_that("symmetric intervals skip unused asymmetric half widths", {
  x <- c("1.00 (0.00, 2.00)", "3.00 (1.00, 5.00)")
  expected <- stat_ci_parse(x, exp = FALSE, output = "p")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(ifelse = function(test, yes, no) {
    if (identical(substitute(test), quote(e_s > 0))) stop("unused asymmetric half width")
    base::ifelse(test, yes, no)
  }), parent = environment(fn))
  expect_identical(fn(x, exp = FALSE, output = "p"), expected)
})

test_that("difference intervals skip empty log scale assignments", {
  x <- c("1.00 (0.00, 2.00)", "3.00 (1.00, 5.00)")
  expected <- stat_ci_parse(x, exp = FALSE, output = "p")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (identical(x, c(1, 3)) && is.logical(i) && !any(i))
      stop("empty difference log assignment")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(fn))
  expect_identical(fn(x, exp = FALSE, output = "p"), expected)
})

test_that("ordinary intervals skip absent tight interval restoration", {
  x <- c("1.00 (0.00, 2.00)", "3.00 (1.00, 5.00)")
  expected <- stat_ci_parse(x, exp = FALSE, output = "p")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (identical(substitute(i), quote(tight)) && !length(i))
      stop("empty tight interval restoration")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(fn))
  expect_identical(fn(x, exp = FALSE, output = "p"), expected)
})

test_that("finite confidence interval captures avoid complete validity slices", {
  x <- c("1.0 (0.0, 2.0)", "3.0 (1.0, 5.0)")
  expected <- .ci_extract(x)
  fn <- .ci_extract
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (!missing(i) && identical(substitute(x), quote(hit)) && is.logical(i) &&
        length(i) && all(i)) stop("complete capture validity slice")
    if (missing(i)) base::"["(x, , ...) else base::"["(x, i, ...)
  }), parent = environment(fn))
  expect_identical(fn(x), expected)
  partly <- c(x, "1 (0, 1e9999)")
  expect_identical(fn(partly), .ci_extract(partly))
})

test_that("unparsed interval counts reuse normally encoded strings", {
  text <- c("unparsed", "", " \t ", NA_character_, "another")
  fn <- .ci_unparsed_count
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(x, text) && is.logical(i) && all(i)) stop("complete encoding row slice")
    base::"["(x, i, ...)
  }), parent = environment(fn))
  expect_equal(fn(text), 2)
})

test_that("complete confidence interval p values bypass validity reallocation", {
  x <- c(a = "1.00 (0.00, 2.00)", b = "3.00 (1.00, 5.00)")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(ifelse = function(test, yes, no) {
    if (identical(substitute(test), quote(valid)) && all(test))
      stop("reshaped complete CI probabilities")
    base::ifelse(test, yes, no)
  }), parent = environment(fn))
  expect_identical(fn(x, exp = FALSE, output = "p"), stat_ci_parse(x, exp = FALSE, output = "p"))
  mixed <- c(x, missing = NA_character_)
  expect_identical(fn(mixed, exp = FALSE, output = "p"), stat_ci_parse(mixed, exp = FALSE, output = "p"))
})

test_that("linear confidence intervals skip the log proximity pass", {
  input <- rep("0.2 (0.1, 0.3)", 70L)
  expected <- stat_ci_parse(input, output = "p", exp = FALSE)
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$pmax <- function(...) stop("computed log proximity for linear intervals")
  environment(fn) <- env
  expect_identical(fn(input, output = "p", exp = FALSE), expected)
})

test_that("asymmetric confidence widths touch only affected intervals", {
  input <- c(rep("0.2 (0.1, 0.3)", 80L), "0.2 (0.17, 0.5)", "-0.2 (-0.5, -0.17)")
  expected <- suppressWarnings(stat_ci_parse(input, output = "p", exp = FALSE))
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$ifelse <- function(test, yes, no) {
    if (identical(substitute(test), quote(e_s > 0)) && length(test) == length(input))
      stop("calculated asymmetric widths for symmetric intervals")
    base::ifelse(test, yes, no)
  }
  environment(fn) <- env
  expect_warning(actual <- fn(input, output = "p", exp = FALSE), "not symmetric")
  expect_identical(actual, expected)
})

test_that("ordinary confidence intervals use a scalar working scale", {
  input <- rep(c("0.2 (0.1, 0.3)", "-0.2 (-0.3, -0.1)"), 80L)
  expected <- stat_ci_parse(input, output = "ci_p", exp = FALSE, level = .80)
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$rep <- function(x, times, ...) {
    if (identical(x, 1) && !missing(times) && times == length(input))
      stop("allocated a full unit working scale")
    if (missing(times)) base::rep(x, ...) else base::rep(x, times, ...)
  }
  environment(fn) <- env
  expect_identical(fn(input, output = "ci_p", exp = FALSE, level = .80), expected)
})

test_that("CI suffix rechecks only text with a terminal dot", {
  ci <- c("2 (1, 3) **. *", "2 (1, 3) **. suffix", rep("2 (1, 3)\u3000**", 60L), NA)
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  calls <- 0L
  env$sub <- function(pattern, replacement, x, ...) {
    if (startsWith(pattern, "(?<![*") && length(x) == length(ci)) {
      calls <<- calls + 1L
      if (calls > 1L) stop("retrimmed confidence interval text without dots")
    }
    base::sub(pattern, replacement, x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(ci), .ci_extract(ci))
})

test_that("CI parser skips extracting absent trailing text", {
  ci <- c(rep("2 (1, 3)", 100L), "2 (1, 3) extra", "\u22122 [\u22123, \u22121]", "bad", NA)
  expected <- .ci_extract(ci)
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  env$substring <- function(text, first, last = 1000000L) {
    if (missing(last) && length(text) > 1L) stop("extracted an empty suffix for complete intervals")
    base::substring(text, first, last)
  }
  environment(fn) <- env
  expect_identical(fn(ci), expected)
  expect_identical(which(expected$trailing), 101L)
})

test_that("CI precision extracts exponents only on scientific tokens", {
  x <- c(rep("2.00 (1.0, 3.000)", 100L), "2.1e-3 (1e-3, 3.00e-3)")
  fn <- .ci_extract
  env <- new.env(parent = environment(fn))
  env$sub <- function(pattern, replacement, x, ...) {
    if (identical(pattern, "^.*[eE]") && length(x) > 1L)
      stop("extracted exponents from ordinary decimal tokens")
    base::sub(pattern, replacement, x, ...)
  }
  environment(fn) <- env
  expected <- .ci_extract(x)
  expect_identical(fn(x), expected)
  expect_identical(as.integer(tail(expected$digits, 1L)), 5L)
})

test_that("CI scale probes and classification share rounding unit columns", {
  estimate <- seq(1, 4, length.out = 1100L)
  unit <- matrix(.001, nrow = length(estimate), ncol = 3L)
  fn <- .ci_scale
  env <- new.env(parent = environment(fn))
  accesses <- integer(3L)
  env[["["]] <- function(x, i, j, ...) {
    if (is.matrix(x) && missing(i) && !missing(j)) {
      accesses[j] <<- accesses[j] + 1L
      if (accesses[j] > 1L) stop("materialized a rounding unit column twice")
      return(base::"["(x, , j, ...))
    }
    if (missing(j)) base::"["(x, i, ...) else base::"["(x, i, j, ...)
  }
  environment(fn) <- env
  args <- list(estimate, estimate - .1, estimate + .2, unit, "auto", rep(TRUE, length(estimate)))
  expect_identical(do.call(fn, args), do.call(.ci_scale, args))
  expect_identical(accesses, rep(1L, 3L))
})

test_that("CI P-value stars keep invalid and missing intervals without remasking", {
  fn <- stat_ci_parse
  env <- new.env(parent = environment(fn))
  env$ifelse <- function(test, yes, no) {
    if (is.call(substitute(yes)) && identical(substitute(yes)[[1L]], quote(stat_pval)))
      stop("masked an already missing P-value twice")
    base::ifelse(test, yes, no)
  }
  environment(fn) <- env
  x <- c(a = "2.00 (1.00, 3.00)", bad = "2.00 (3.00, 4.00)", absent = NA, null = "0.00 (-1.00, 1.00)")
  expect_warning(out <- fn(x, output = "p_star", exp = FALSE), "invalid")
  expect_warning(p <- stat_ci_parse(x, output = "p", exp = FALSE), "invalid")
  expect_identical(out, stat_pval(p, map_signif = c("***" = .001, "**" = .01, "*" = .05)))
})

test_that("forced linear confidence intervals skip logarithmic eligibility", {
  fn <- .ci_scale
  environment(fn) <- list2env(list(">" = function(x, y) {
    if (identical(substitute(x), quote(lo)) && identical(y, 0))
      stop("computed logarithmic eligibility for linear intervals")
    base::">"(x, y)
  }), parent = environment(fn))
  unit <- matrix(.01, 4L, 3L)
  expect_identical(fn(c(-3, .5, 2, NA), c(-4, .1, 3, NA), c(-2, 1, 4, NA),
                      unit, FALSE, c(TRUE, TRUE, TRUE, FALSE)),
                   list(is_exp = rep(FALSE, 4L), invalid = c(FALSE, FALSE, TRUE, FALSE),
                        ambiguous = rep(FALSE, 4L), asymmetric = rep(FALSE, 4L)))
})

test_that("log confidence interval scoring extracts each positive endpoint once", {
  fn <- .ci_scale
  hits <- 0L
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(hi)) && identical(substitute(i), quote(pos))) {
      hits <<- hits + 1L
      if (hits > 1L) stop("extracted positive endpoints more than once")
    }
    if (missing(i)) return(base::"["(x, , ...))
    base::"["(x, i, ...)
  }), parent = environment(fn))
  args <- list(c(.5, 1, -3, 1.25), c(.125, .9, -5, .1), c(2, 1.1, -1, 16),
               matrix(.001, 4L, 3L), "auto", rep(TRUE, 4L))
  expect_identical(do.call(fn, args), do.call(.ci_scale, args))
})

test_that("valid confidence intervals keep their existing eligibility mask", {
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("!" = function(x) {
    if (identical(deparse(substitute(x)), "scale$invalid") && !any(x))
      stop("rebuilt CI eligibility with an empty invalidity mask")
    base::"!"(x)
  }), parent = environment(fn))
  data <- c("0.50 (0.25-0.75)", "-1.0 (-2.0,-0.0)", NA_character_)
  expect_identical(fn(data, exp = FALSE), stat_ci_parse(data, exp = FALSE))
  expect_warning(out <- fn(c(data, "9 (2, 3)"), exp = FALSE), "invalid")
  expect_identical(out[4L], "9 (2, 3)")
})

test_that("fully parsed confidence interval input bypasses malformed-row inspection", {
  x <- c("1.5 (1.0, 2.0)", "-2.0 [-2.5; -1.5]")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(.ci_unparsed_count = function(text) {
    if (!length(text)) stop("inspected nonexistent malformed confidence intervals")
    .ci_unparsed_count(text)
  }), parent = environment(fn))
  expect_identical(fn(x, exp = FALSE, output = "p"), stat_ci_parse(x, exp = FALSE, output = "p"))
  expect_warning(out <- fn(c(x, "unparsed", NA), exp = FALSE, output = "p"), "1 element")
  expect_identical(out[3:4], rep(NA_real_, 2L))
})

test_that("automatic CI diagnostics scan logarithmic votes once", {
  fn <- .ci_scale
  scanned <- 0L
  environment(fn) <- list2env(list(any = function(..., na.rm = FALSE) {
    if (identical(substitute(list(...)), quote(list(log_wins)))) {
      scanned <<- scanned + 1L
      if (scanned > 1L) stop("rescanned confidence interval logarithmic votes")
    }
    base::any(..., na.rm = na.rm)
  }), parent = environment(fn))
  a <- list(c(1, 4, -2, 2), c(.5, 2, -3, 1), c(2, 8, -1, 4),
            matrix(.001, 4L, 3L), "auto", rep(TRUE, 4L))
  expect_identical(do.call(fn, a), do.call(.ci_scale, a))
  expect_identical(scanned, 1L)
})

test_that("complete interval captures reuse their original normalized text", {
  fn <- .ci_extract
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (!missing(i) && identical(substitute(x), quote(xs)) && identical(substitute(i), quote(hit)) &&
        length(i) == length(x)) stop("copied fully matched interval text")
    if (missing(i)) return(base::"["(x, , ...))
    base::"["(x, i, ...)
  }), parent = environment(fn))
  x <- c(" +1.00 [0.5, 2.0]", "\u22123.1 (\u22124.5; \u22122)", "2.1 (1.9 to 4.5)*")
  expect_identical(fn(x), .ci_extract(x))
  expect_identical(fn(c(x, NA, "missing", "2 [1, 3)")),
                   .ci_extract(c(x, NA, "missing", "2 [1, 3)")))
})

test_that("CI parsing reuses final row validity across output preparation", {
  x <- c(a = "1.20 (0.90, 1.50)", b = "-.2 [-.4; 0.0]")
  fn <- stat_ci_parse
  count <- 0L
  environment(fn) <- list2env(list(all = function(..., na.rm = FALSE) {
    if (identical(substitute(list(...)), quote(list(valid)))) {
      count <<- count + 1L
      if (count > 2L) stop("rescanned valid interval rows after the scale check")
    }
    base::all(..., na.rm = na.rm)
  }), parent = environment(fn))
  for (value in list(x, c(x, absent = NA_character_))) {
    count <- 0L
    expect_identical(fn(value, exp = FALSE, output = "ci_p"),
                     stat_ci_parse(value, exp = FALSE, output = "ci_p"))
  }
})

test_that("fully matched interval and probability text uses complete computed rows", {
  x <- c(a = "50 (49, 51)", b = "0.0 (-.5, .5)", c = "1.5 (0.0, 3.0)")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(pval)) && identical(substitute(i), quote(valid)) && all(i))
      stop("resliced each probability for already complete intervals")
    if (missing(i)) return(base::"["(x, , ...))
    base::"["(x, i, ...)
  }), parent = environment(fn))
  for (value in list(x, c(x, absent = NA_character_))) {
    expect_identical(fn(value, exp = FALSE, output = "ci_p"),
                     stat_ci_parse(value, exp = FALSE, output = "ci_p"))
  }
})

test_that("complete starred confidence intervals keep the formatted labels directly", {
  x <- c(a = "1.10 (0.90, 1.30)", b = "-1.1 (-2.0, -.2)")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(ifelse = function(test, yes, no) {
    if (identical(substitute(test), quote(valid)) && all(test))
      stop("allocated a selection vector for complete starred intervals")
    base::ifelse(test, yes, no)
  }), parent = environment(fn))
  for (value in list(x, c(x, absent = NA_character_))) {
    expect_identical(fn(value, exp = FALSE, output = "ci_star"),
                     stat_ci_parse(value, exp = FALSE, output = "ci_star"))
  }
})

test_that("undotted interval mantissas bypass fractional precision substitutions", {
  fn <- .ci_extract
  environment(fn) <- list2env(list(sub = function(pattern, replacement, x, ...) {
    if (identical(pattern, "^[-+]?\\d*\\.?") && any(!grepl(".", x, fixed = TRUE)))
      stop("searched undotted interval tokens for decimal digits")
    base::sub(pattern, replacement, x, ...)
  }), parent = environment(fn))
  x <- c("1 (0, 2)", "1e2 (50, 2e2)", "+.5 (0.120, 1.)", "1E-10 (0, 2e-10)", NA)
  expect_identical(fn(x), .ci_extract(x))
  expect_identical(fn(x)[["digits"]], c(0, 0, 3, 10, 2))
})

test_that("routine linear interval scoring checks only instability candidates", {
  fn <- .ci_scale
  environment(fn) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(est)) && length(x) > 10L)
      stop("scanned every CI estimate for the overflow fallback")
    base::is.finite(x)
  }), parent = environment(fn))
  x <- c(seq_len(30L), 0, NA_real_)
  lo <- c(seq_len(30L) - 1, -1.7e308, NA_real_)
  hi <- c(seq_len(30L) + 1, 1.7e308, NA_real_)
  args <- list(x, lo, hi, matrix(.005, length(x), 3L), FALSE, !is.na(x))
  expect_identical(do.call(fn, args), do.call(.ci_scale, args))
})

test_that("linear CI rescaling checks only candidate rows", {
  v <- c("2.3 (1.3, 3.3)", "3.1 (2.5, 3.7)", "-1.1 (-2.1, -0.1)")
  f <- stat_ci_parse
  environment(f) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(e_s)) && length(x) == length(v))
      stop("scanned every confidence interval for rescaling finiteness")
    base::is.finite(x)
  }), parent = environment(f))
  expect_identical(f(v, output = "p", exp = FALSE),
                   stat_ci_parse(v, output = "p", exp = FALSE))
  extreme <- c(v, "5e307 (-1.1e308, 1.7e308)")
  expect_identical(suppressWarnings(f(extreme, output = "p", exp = FALSE)),
                   suppressWarnings(stat_ci_parse(extreme, output = "p", exp = FALSE)))
})

test_that("confidence z scores restore null values without a conditional result vector", {
  v <- c("0.00 (-0.3, 0.4)", "2.00 (2.0, 3.0)", "-0.4 (-0.8, 0.0)", NA_character_)
  f <- stat_ci_parse
  environment(f) <- list2env(list(ifelse = function(test, yes, no) {
    if (identical(substitute(test), quote(e_s == 0)))
      stop("selected every confidence interval z score with ifelse")
    base::ifelse(test, yes, no)
  }), parent = environment(f))
  p <- suppressWarnings(f(v, output = "p", exp = FALSE))
  expect_identical(p, suppressWarnings(stat_ci_parse(v, output = "p", exp = FALSE)))
  expect_identical(p[[1L]], 1)
})

test_that("ordinary CI widths avoid raw endpoint overflow masks", {
  x <- c("1.3 (0.2, 2.4)", "2.2 (1.9, 3.3)", "-2.6 (-3.9, -0.4)")
  f <- stat_ci_parse
  environment(f) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(l)) && length(x) == 3L)
      stop("tested every ordinary CI width for raw endpoint finiteness")
    base::is.finite(x)
  }), parent = environment(f))
  expect_identical(suppressWarnings(f(x, output = "p", exp = FALSE)),
                   suppressWarnings(stat_ci_parse(x, output = "p", exp = FALSE)))
  y <- "8e307 (-1e308, 1.7e308)"
  expect_identical(suppressWarnings(f(y, output = "p", exp = FALSE)),
                   suppressWarnings(stat_ci_parse(y, output = "p", exp = FALSE)))
})

test_that("complete linear confidence intervals restore endpoints directly", {
  x <- c("2.50 (1.40, 3.60)", "-0.40 (-1.70, 0.90)", "3.20 (2.10, 4.60)")
  f <- stat_ci_parse
  environment(f) <- list2env(list(ifelse = function(test, yes, no) {
    if (identical(substitute(test), quote(valid)) &&
        grepl("work_scale", paste(deparse(substitute(yes)), collapse = ""), fixed = TRUE))
      stop("selected adjusted complete linear bounds row by row")
    base::ifelse(test, yes, no)
  }), parent = environment(f))
  expect_identical(suppressWarnings(f(x, level = .89, output = "ci", exp = FALSE)),
                   suppressWarnings(stat_ci_parse(x, level = .89, output = "ci", exp = FALSE)))
})

test_that("asymmetric confidence width does not scan stable endpoint vectors", {
  input <- rep(c("0.20 (-1.30, 0.25)", "2.00 (1.95, 3.60)"), 80L)
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(is.finite = function(x) {
    expr <- substitute(x)
    if (is.symbol(expr) && as.character(expr) %in% c("center", "lower", "upper") && length(x) == 160L)
      stop("scanned all asymmetric endpoints")
    base::is.finite(x)
  }), parent = environment(fn))
  expect_identical(suppressWarnings(fn(input, exp = FALSE, output = "p")),
    suppressWarnings(stat_ci_parse(input, exp = FALSE, output = "p")))
  extreme <- c(input[1:2], "1.00e308 (-1.00e308, 1.20e308)")
  expect_identical(suppressWarnings(fn(extreme, exp = FALSE, output = "p")),
    suppressWarnings(stat_ci_parse(extreme, exp = FALSE, output = "p")))
})

test_that("confidence probability underflow recovery only checks zero candidates", {
  input <- rep(c("0.2 (-0.4, 0.8)", "0.8 (0.6, 1.0)"), 60L)
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(z)) && length(x) == 120L)
      stop("checked finite z values for every confidence interval")
    base::is.finite(x)
  }), parent = environment(fn))
  expect_identical(fn(input, exp = FALSE, output = "p"),
    stat_ci_parse(input, exp = FALSE, output = "p"))
  extreme <- append(input[1:2], "3.90 (3.70, 4.10)")
  expect_identical(fn(extreme, exp = FALSE, output = "p"),
    stat_ci_parse(extreme, exp = FALSE, output = "p"))
})

test_that("nonzero interval values avoid empty signed zero replacement", {
  d <- c("1.2 (0.4, 2.6)", "2.3 (0.4, 4.0)")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (identical(value, 0) && is.double(x) && !length(i))
      stop("assigned zero to an empty interval selection")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(fn))
  expect_identical(fn(d), stat_ci_parse(d))
  expect_identical(fn("-0.0001 (-2, 4)", digits = 2), "0.00 (-2.00, 4.00)")
})

test_that("tight log confidence checks omit ordinary linear rows", {
  d <- c(rep(c("1.2 (-1.5, 3.9)", "2.1 (-0.4, 4.6)"), 80L), "2.00 (1.00, 4.00)")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(pmax = function(..., na.rm = FALSE) {
    if (identical(substitute(list(...))[[2L]], quote(abs(l_s - e_s))))
      stop("compared linear confidence rows with tight log widths")
    base::pmax(..., na.rm = na.rm)
  }), parent = environment(fn))
  expect_identical(suppressWarnings(fn(d, output = "p")),
    suppressWarnings(stat_ci_parse(d, output = "p")))
})

test_that("confidence formatting validates detected precision from its extrema", {
  d <- rep(c("12 (10, 14)", "0.12 (-0.31, 0.55)", "1.2 (0.5, 1.9)"), 40L)
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(d)) && length(x) == 120L)
      stop("built a finiteness mask for confidence precision")
    base::is.finite(x)
  }), parent = environment(fn))
  expect_identical(fn(d, exp = FALSE), stat_ci_parse(d, exp = FALSE))
})

test_that("confidence conversion reuses stable trial endpoints", {
  input <- rep(c("2.00 (1.20, 2.80)", "4.00 (1.00, 4.10)"), 50L)
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(ifelse = function(test, yes, no) {
    if (identical(substitute(yes), quote(e_s - (e_s - l_s) * ratio)))
      stop("recomputed all adjusted confidence endpoints")
    base::ifelse(test, yes, no)
  }), parent = environment(fn))
  run <- function(f, x, level) suppressWarnings(f(x, exp = FALSE, level = level, output = "ci_p"))
  expect_identical(run(fn, input, 0.90), run(stat_ci_parse, input, 0.90))
  wide <- c(input[1:2], "1.00e308 (-1.00e308, 1.20e308)")
  expect_identical(run(fn, wide, 0.99), run(stat_ci_parse, wide, 0.99))
})

test_that("fully parsed confidence fields avoid scattering every row", {
  input <- setNames(c("2.0 (1.0, 3.0)", "0.10 [0.03 to 0.17]", "9 (8; 10)"), letters[1:3])
  f <- .ci_extract
  environment(f) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (is.double(x) && length(x) == 3L && all(is.na(x)) && length(i) == 3L)
      stop("scattered all parsed interval rows into preallocated columns")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(f))
  expect_identical(f(input)$estimate, c(2, .1, 9))
  expect_identical(f(input)$open, c("(", "[", "("))
  expect_identical(f(input)$digits, c(1, 2, 0))
  expect_identical(f(c(input, "invalid")), .ci_extract(c(input, "invalid")))
})

test_that("uniform interval precision groups repeated values directly", {
  x <- rep(c("3.120 (2.275, 4.010)", "8.024 (7.012, 9.025)"), 750L)
  expected <- stat_ci_parse(x, exp = FALSE, digits = 4L)
  make <- vctrs::new_data_frame
  local_mocked_bindings(new_data_frame = function(x = list(), ...) {
    if (identical(names(x), c("v", "d"))) stop("hashed a repeated constant precision column")
    make(x, ...)
  }, .package = "vctrs")
  expect_identical(stat_ci_parse(x, exp = FALSE, digits = 4L), expected)
})

test_that("positive confidence intervals reuse log scale inputs", {
  fn <- .ci_scale
  environment(fn) <- list2env(list(`[` = function(x, i, ...) {
    if (identical(substitute(i), quote(pos))) stop("subset a completely positive interval column")
    base::`[`(x, i, ...)
  }), parent = environment(fn))
  est <- c(1, 2, 3, 0.7)
  lo <- c(0.5, 1, 1, 0.2)
  hi <- c(2, 7, 4, 1.3)
  unit <- matrix(0.01, length(est), 3L)
  expected <- .ci_scale(est, lo, hi, unit, "auto", rep(TRUE, length(est)))
  expect_identical(fn(est, lo, hi, unit, "auto", rep(TRUE, length(est))), expected)
})

test_that("mismatched brackets skip decimal conversion", {
  fn <- .ci_extract
  environment(fn) <- list2env(list(.parse_decimal_tokens = function(text) {
    if ("999" %in% text) stop("converted a rejected bracket row")
    .parse_decimal_tokens(text)
  }), parent = environment(fn))
  x <- c("999 (0, 1]", "2.0 [1, 3]", NA, "4 (3, 5) extra")
  got <- fn(x)
  expect_identical(got$estimate, c(NA_real_, 2, NA_real_, 4))
  expect_identical(got$valid, c(FALSE, TRUE, FALSE, TRUE))
  expect_identical(got$trailing, c(FALSE, FALSE, FALSE, TRUE))
  expect_identical(fn("999 [0, 1)"), .ci_extract("999 [0, 1)"))
})

test_that("interval scale detection skips log work for wholly nonpositive bounds", {
  fn <- .ci_scale
  environment(fn) <- list2env(list(log1p = function(...) {
    stop("computed a log ratio without eligible intervals")
  }), parent = environment(fn))
  est <- c(0, -4, -1, NA_real_)
  low <- c(-2, -5, -2, NA_real_)
  high <- c(2, -1, -1, NA_real_)
  units <- matrix(0.01, 4L, 3L)
  valid <- c(TRUE, TRUE, TRUE, FALSE)
  apply <- function(f, scale) f(est, low, high, units, scale, valid)
  expect_identical(apply(fn, "auto"), apply(.ci_scale, "auto"))
  expect_identical(apply(fn, TRUE), apply(.ci_scale, TRUE))
  expect_identical(apply(fn, TRUE)$invalid, c(TRUE, TRUE, TRUE, FALSE))
})

test_that("complete ratio interval inference uses full logarithm inputs", {
  x <- c("2.00 (1.00, 4.00)", "3.00 (1.00, 9.00)", "0.50 (0.25, 1.00)")
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(`[` = function(x, i, ...) {
    if (identical(substitute(i), quote(exp_rows)) && length(i) == length(x))
      stop("gathered an entire ratio interval column")
    base::`[`(x, i, ...)
  }), parent = environment(fn))
  expect_identical(fn(x, exp = TRUE, output = "p"), stat_ci_parse(x, exp = TRUE, output = "p"))
  expect_identical(fn(x, exp = TRUE, output = "ci", level = 0.8),
                   stat_ci_parse(x, exp = TRUE, output = "ci", level = 0.8))
})

test_that("ordinary intervals do not compute absent tight logarithms", {
  fn <- stat_ci_parse
  environment(fn) <- list2env(list(log1p = function(x) {
    if (!length(x)) stop("computed logarithms with no tight interval rows")
    base::log1p(x)
  }), parent = environment(fn))
  for (x in list(c("1.00 (0.00, 2.00)", "3.00 (1.00, 5.00)"),
                 c("1.00000000001 (1.00000000000, 1.00000000002)", "2 (1, 4)"))) {
    expect_identical(fn(x, exp = startsWith(x[[1L]], "1.000"),
                        output = "p"), stat_ci_parse(x, exp = startsWith(x[[1L]], "1.000"), output = "p"))
  }
})

test_that("parsed finite intervals skip full component finiteness flags", {
  x <- sprintf("%d (%d,%d)", 2:8, 1:7, 3:9)
  fn <- .ci_extract
  environment(fn) <- list2env(list(is.finite = function(x) {
    if (length(x) > 1L) stop("computed full finite flags for parsed intervals")
    base::is.finite(x)
  }), parent = environment(fn))
  expect_identical(fn(x), .ci_extract(x))
  expect_identical(.ci_extract(c(x, "1e309 (0,2)"))$valid, c(rep(TRUE, length(x)), FALSE))
})

test_that("ordinary rounded CI values avoid zero flag allocation", {
  f <- stat_ci_parse
  environment(f) <- list2env(list(which = function(x, ...) {
    if (identical(substitute(x), quote(v == 0))) stop("flagged zero in a positive CI component")
    base::which(x, ...)
  }), parent = environment(f))
  x <- c("2.50 (1.30,3.50)", "9.00 (7.80,10.20)")
  expect_identical(f(x, output = "ci"), stat_ci_parse(x, output = "ci"))
})

test_that("near ratio CI components use their relative extrema", {
  fn <- .ci_scale
  environment(fn) <- list2env(list(abs = function(x) {
    if (identical(substitute(x), quote(relative)) && all(base::abs(x) < .5))
      stop("allocated row flags for uniformly close CI ratios")
    base::abs(x)
  }), parent = environment(fn))
  est <- c(1.02, 1.2, 2, 3.5)
  lo <- est * .95
  hi <- est * 1.05
  args <- list(est, lo, hi, matrix(.01, 4L, 3L), TRUE, rep(TRUE, 4L))
  expect_identical(do.call(fn, args), do.call(.ci_scale, args))
})

test_that("parsed precision reuses its upper bound before the P-only return", {
  f <- stat_ci_parse
  environment(f) <- list2env(list(">" = function(e1, e2) {
    if (identical(substitute(e1), quote(d)) && identical(e2, 7881L) && length(e1) > 1L)
      stop("built a high precision mask before returning P-values")
    base::">"(e1, e2)
  }), parent = environment(f))
  x <- c("2.0 (1.0,3.0)", "3.00 (2.00,4.00)", "5.00 (4.00,6.00)")
  for (output in c("p", "p_star"))
    expect_identical(f(x, output = output, exp = FALSE), stat_ci_parse(x, output = output, exp = FALSE))
})

test_that("anchored interval parsing reuses the known match origin", {
  fn <- .ci_extract
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(matched))) stop("unnecessary [ in .ci_extract")
    base::`[`(x, i, ...)
  }), parent = environment(fn))
  x <- c("0.2 (0.1, 0.3)", "4 [2 to 8] after", "invalid", "8 [6, 9) wrong")
  parsed <- fn(x)
  expect_identical(parsed$valid, c(TRUE, TRUE, FALSE, FALSE))
  expect_identical(parsed$trailing, c(FALSE, TRUE, FALSE, FALSE))
  expect_identical(parsed$estimate, c(.2, 4, NA_real_, NA_real_))
})

test_that("repeated identical confidence intervals reuse a single parse index", {
  fn <- .ci_extract
  environment(fn) <- list2env(list("match" = function(x, table, ...) {
    if (length(table) == 1L && length(x) > 1024L) stop("unnecessary match in .ci_extract")
    base::match(x, table, ...)
  }), parent = environment(fn))
  x <- "0.2 [0.1, 0.7]"
  out <- fn(rep(x, 1200L))
  one <- fn(x)
  expect_identical(out$estimate, rep(one$estimate, 1200L))
  expect_identical(out$unit, one$unit[rep.int(1L, 1200L), , drop = FALSE])
  expect_identical(out$trailing, rep(FALSE, 1200L))
})

test_that("repeated identical interval components select their first row directly", {
  fn <- .ci_scale
  environment(fn) <- list2env(list("match" = function(x, table, ...) {
    if (length(x) == 1L && length(table) > 1024L) stop("unnecessary match in .ci_scale")
    base::match(x, table, ...)
  }), parent = environment(fn))
  unit <- matrix(.01, 1056L, 3L)
  out <- fn(rep(2, 1056L), rep(1, 1056L), rep(4, 1056L), unit, "auto", rep(TRUE, 1056L))
  one <- fn(2, 1, 4, unit[1L, , drop = FALSE], "auto", TRUE)
  expect_identical(out, lapply(one, rep, times = 1056L))
})

test_that("valid positive intervals preserve the original invalidity flags", {
  fn <- .ci_scale
  environment(fn) <- list2env(list("|" = function(e1, e2) {
    if (identical(substitute(e1), quote(invalid)) && !any(e2))
      stop("recombined validity for entirely positive intervals")
    base::"|" (e1, e2)
  }), parent = environment(fn))
  unit <- matrix(.01, 2L, 3L)
  expect_identical(fn(c(2, 4), c(1, 2), c(4, 8), unit, TRUE, c(TRUE, TRUE))$invalid, c(FALSE, FALSE))
  expect_identical(fn(c(2, 4), c(1, 0), c(4, 8), unit, TRUE, c(TRUE, TRUE))$invalid, c(FALSE, TRUE))
})

test_that("constant parsed precision is shared by repeated formatted keys", {
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("rep.int" = function(x, times) {
    if (identical(substitute(x), quote(d[[1L]]))) stop("unexpected rep.int in stat_ci_parse")
    base::rep.int(x, times)
  }), parent = environment(fn))
  candidates <- c("1.20 (0.90, 1.50)", "1.20 [0.90; 1.50]", "2.20 (1.90, 2.50)")
  x <- rep(candidates, 350L)
  expect_identical(fn(x, exp = FALSE), rep(stat_ci_parse(candidates, exp = FALSE), 350L))
  expect_identical(fn(x, exp = FALSE, digits = 7882L),
    rep(stat_ci_parse(candidates, exp = FALSE, digits = 7882L), 350L))
})

test_that("multi-key interval scaling tracks only observed representative IDs", {
  fn <- .ci_scale
  environment(fn) <- list2env(list("match" = function(x, table, ...) {
    if (identical(substitute(x), quote(seq_len(count))) && identical(substitute(table), quote(groups))) stop("unexpected match in .ci_scale")
    base::match(x, table, ...)
  }), parent = environment(fn))
  est <- rep(c(1, 2, 7), 600L)
  lo <- est - 0.2
  hi <- est + 0.3
  unit <- matrix(0.1, length(est), 3L)
  valid <- rep(TRUE, length(est))
  expect_identical(fn(est, lo, hi, unit, "auto", valid),
                   .ci_scale(est, lo, hi, unit, "auto", valid))
})

test_that("varying parsed precision tracks only observed format groups", {
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("match" = function(x, table, ...) {
    if (identical(substitute(x), quote(seq_len(count))) && identical(substitute(table), quote(ids))) stop("unexpected match in stat_ci_parse")
    base::match(x, table, ...)
  }), parent = environment(fn))
  keys <- c("1.2 (0.9, 1.5)", "1.20 (0.90, 1.50)", "2.20 [1.90; 2.50]", "2.2 (1.9, 2.5)")
  x <- rep(keys, 400L)
  expect_identical(fn(x, exp = FALSE), rep(stat_ci_parse(keys, exp = FALSE), 400L))
})

test_that("interval parsing collects notation positions directly", {
  fn <- .ci_extract
  environment(fn) <- list2env(list("which" = function(x, ...) {
    if (identical(substitute(x), quote(grepl("[eE]", s)))) stop("unexpected which in .ci_extract")
    base::which(x, ...)
  }), parent = environment(fn))
  x <- c("12 (10, 14)", "2.5e-3 [1.4e-03; 3.90e-3]", "5e1 (4.e1, 7.3E1)", NA_character_)
  got <- fn(x)
  expect_identical(got, .ci_extract(x))
  expect_equal(got$digits, c(0, 5, 0, 2))
  expect_equal(got$unit[2L, ], c(1e-4, 1e-4, 1e-5))
})

test_that("complete interval widths need no exceptional positions", {
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("is.finite" = function(x) {
    if (identical(substitute(x), quote(full)) && length(x) > 100L && all(base::is.finite(x))) stop("unexpected is.finite in stat_ci_parse")
    base::is.finite(x)
  }), parent = environment(fn))
  x <- rep(c("1.0 (0.5, 1.5)", "20.0 (10.0, 30.0)", "-0.2 (-1.2, 0.8)"), 70L)
  expect_identical(fn(x, exp = FALSE, output = "p"), stat_ci_parse(x, exp = FALSE, output = "p"))
  expect_equal(fn("0 (-1e308, 1e308)", exp = FALSE, output = "p"), 1)
})

test_that("standard confidence levels do not rebuild an unchanged interval", {
  fn <- stat_ci_parse
  environment(fn) <- list2env(list("qnorm" = function(p, ..., lower.tail = TRUE) {
    if (!lower.tail && isTRUE(abs(p - 0.025) < 1e-14)) stop("unexpected qnorm in stat_ci_parse")
    stats::qnorm(p, ..., lower.tail = lower.tail)
  }), parent = environment(fn))
  x <- c("1.03 (0.95, 1.11)", "2.419 (2.001, 2.835)", "-2.4 [-3.7, -1.1]",
    "1.0e308 (2e307, 1.78e308)", "1.0e-300 (0.2e-300, 1.8e-300)")
  expect_equal(fn(x, level = .95, output = "p", exp = FALSE),
    stat_ci_parse(x, output = "p", exp = FALSE), tolerance = 1e-14)
  expect_identical(fn(x, level = .90, output = "ci_p", exp = FALSE),
    stat_ci_parse(x, level = .90, output = "ci_p", exp = FALSE))
})

test_that("one parsed interval expands fields without creating row indices", {
  fn <- .ci_extract
  environment(fn) <- list2env(list("rep.int" = function(x, times) {
    if (identical(x, 1L) && times == 1400L) stop("unexpected rep.int in .ci_extract")
    base::rep.int(x, times)
  }), parent = environment(fn))
  for (token in c("3.25 [2.22, 4.3]", "", NA_character_)) {
    got <- fn(rep(token, 1400L))
    parsed <- .ci_extract(token)
    expect_identical(got$open, rep(parsed$open, 1400L))
    expect_identical(got$estimate, rep(parsed$estimate, 1400L))
    expect_equal(got$unit, parsed$unit[rep(1L, 1400L), , drop = FALSE])
    expect_identical(got, .ci_extract(rep(token, 1400L)))
  }
})
