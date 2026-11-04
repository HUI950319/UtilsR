z95 <- qnorm(0.975)
p_of <- function(z) 2 * (1 - pnorm(abs(z)))

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

test_that("level keeps at least one decimal for integer input", {
  expect_identical(stat_ci_parse("2 (1, 3)", level = 0.9, exp = FALSE),
                   "2.0 (1.2, 2.8)")
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

test_that("ci_p writes p<0.001, not p=<0.001", {
  expect_identical(stat_ci_parse("2.00 (1.50, 2.67)", output = "ci_p"),
                   "2.00 (1.50, 2.67), p<0.001")
  expect_identical(stat_ci_parse("1.23 (0.95, 1.59)", output = "ci_p"),
                   "1.23 (0.95, 1.59), p=0.115")
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
