z95 <- qnorm(0.975)
p_of <- function(z) 2 * (1 - pnorm(abs(z)))

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
              "-0.25 (-0.40～-0.10)", "-2.5e-1 (-4.0e-1, -1.0e-1)")) {
    expect_no_warning(p <- stat_ci_parse(x, output = "p"))
    expect_equal(p, ref)
  }
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

test_that("exp must be auto, TRUE or FALSE", {
  expect_error(stat_ci_parse("1.20 (0.90, 1.60)", exp = "yes"), "exp")
})
