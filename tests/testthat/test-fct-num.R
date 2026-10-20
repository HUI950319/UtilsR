test_that("numeric binning rejects unsupported integer64 storage", {
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(c(1, 5, 9, NA))
  expect_error(fct_num(x, breaks = 5), "x.*integer64")
  expect_error(fct_num(x, nbins = 3), "x.*integer64")
  expect_error(fct_num(c(1, 5, 9), breaks = bit64::as.integer64(5)),
               "breaks.*integer64")
})

test_that("numeric binning retains right-closed boundaries and missing values", {
  x <- c(-Inf, 49, 50, 51, Inf, NA, NaN)
  expect_identical(fct_num(x, breaks = 50),
                   factor(c("below_50", "below_50", "below_50",
                            "above_50", "above_50", NA, NA),
                          levels = c("below_50", "above_50")))
  expect_identical(fct_num(c(44, 45, 54, 55, NA), breaks = c(44, 54),
                           labels = c("<45", "45-54", ">=55")),
                   factor(c("<45", "45-54", "45-54", ">=55", NA),
                          levels = c("<45", "45-54", ">=55")))
})

test_that("fixed cut points must be finite distinct numeric values", {
  for (breaks in list(numeric(), NA_real_, c(NA_real_, 5), NaN, Inf, -Inf,
                     c(5, Inf), c(5, 5), c("2", "10"), TRUE, list(5),
                     1 + 1i, matrix(c(2, 5), nrow = 1))) {
    expect_no_warning(expect_error(fct_num(c(1, 5, 9), breaks = breaks),
                                   "breaks.*(numeric|finite|distinct|value)"))
  }
  expect_identical(fct_num(c(1, 5, 9), breaks = c(7, 3)),
                   factor(c("below_3", "3-7", "above_7"),
                          levels = c("below_3", "3-7", "above_7")))
})
