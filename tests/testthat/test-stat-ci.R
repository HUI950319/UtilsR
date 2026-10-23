test_that("default CI and SD formatting stays unchanged", {
  expect_identical(stat_ci(1.23, .95, 1.59), "1.23 (0.95\u20131.59)")
  expect_identical(stat_ci(1.23, .95, 1.59, bracket = "[", sep = " to "),
                   "1.23 [0.95 to 1.59]")
  expect_identical(stat_ci(1.23, .15), "1.2(0.1)")
  expect_identical(stat_ci("1.23 (0.95, 1.59)", sep = " to "),
                   "1.23 (0.95 to 1.59)")
  expect_identical(stat_ci(12, 10, 15, digits = 0), "12 (10\u201315)")
})

test_that("digits is validated before coercion and formatting in every mode", {
  invalid <- list(-1, 1.9, NA_real_, Inf, numeric(), c(1, 2), "2", TRUE,
                  8191, .Machine$integer.max + 1, matrix(2),
                  as.difftime(2, units = "secs"))
  for (digits in invalid) {
    expect_error(stat_ci(1.23, .95, 1.59, digits = digits), "digits")
    expect_error(stat_ci(1.23, .15, digits = digits), "digits")
    expect_error(stat_ci("1.23 (0.95, 1.59)", digits = digits), "digits")
    expect_error(stat_ci(character(), digits = digits), "digits")
  }
  expect_identical(stat_ci(1.23, .95, 1.59, digits = 2L),
                   stat_ci(1.23, .95, 1.59, digits = 2))
})

test_that("large precision respects the formatted-number width limit", {
  expect_error(stat_ci(1e308, 0, Inf, digits = 8000), "digits.*8192")
  expect_error(stat_ci(0, 1e308, digits = 8000), "digits.*8192")
  expect_error(stat_ci("1e308 (0, 1e308)", digits = 8000), "digits.*8192")
  expect_no_error(stat_ci(1, 0, 2, digits = 8190))
  expect_no_error(stat_ci(1.23, .15, digits = 100))
})
