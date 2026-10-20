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

test_that("automatic labels keep nearby cut points in separate groups", {
  for (breaks in list(1 + c(0, 1e-15, 2e-15, 3e-15),
                     -1 + c(0, 1e-15, 2e-15, 3e-15),
                     1e12 + c(0, 0.001, 0.002, 0.003))) {
    result <- fct_num(c(breaks, Inf, NA), breaks = breaks)
    expect_identical(as.integer(result), c(1:5, NA_integer_))
    expect_length(levels(result), 5L)
    expect_identical(anyDuplicated(levels(result)), 0L)
  }
  expect_identical(levels(fct_num(1:10, breaks = c(2.5, 7.5))),
                   c("below_2.5", "2.5-7.5", "above_7.5"))
})

test_that("automatic bin counts are validated before integer conversion", {
  for (nbins in list(2.9, "3", factor("3", levels = c("2", "3")),
                    integer(), c(2, 3), NA_real_, NaN, Inf, -Inf, 1, 0, -2,
                    TRUE, list(3), 2 + 1i, matrix(3), .Machine$integer.max, 1e20)) {
    expect_no_warning(expect_error(fct_num(1:10, nbins = nbins),
                                   "nbins.*single finite integer"))
  }
  expect_identical(fct_num(1:6, nbins = 3),
                   factor(c("low", "low", "middle", "middle", "high", "high"),
                          levels = c("low", "middle", "high")))
  expect_identical(fct_num(1:6, nbins = 3), fct_num(1:6, nbins = 3L))
})

test_that("automatic binning reports constant data before constructing groups", {
  for (type in c("quantile", "equal")) {
    for (x in list(5, rep(5, 4), c(0, 0, NA, NaN), c(-3, NA, -3))) {
      expect_no_warning(expect_error(fct_num(x, nbins = 3, type = type),
                                     "constant.*x"))
    }
  }
  expect_identical(fct_num(rep(5, 3), breaks = 5),
                   factor(rep("below_5", 3), levels = c("below_5", "above_5")))
  expect_warning(result <- fct_num(c(1, 1, 1, 2), nbins = 4),
                 "reduced 4 bins to 2")
  expect_identical(result,
                   factor(c("low", "low", "low", "high"), levels = c("low", "high")))
})

test_that("numeric binning preserves custom labels and unused groups", {
  x <- c(-Inf, 0, 1, 2, Inf, NA, NaN)
  for (labels in list(c("A", "B", "C"), c("A", "A", "C"),
                     c("A", NA, "C"), setNames(c("A", "B", "C"), letters[1:3]),
                     factor(c("A", "B", "C")), c(10, 20, 30), list("A", "B", "C"))) {
    expect_identical(fct_num(x, breaks = c(0, 1), labels = labels),
                     cut(x, c(-Inf, 0, 1, Inf), labels = labels, include.lowest = TRUE))
  }
  expect_identical(fct_num(c(0, 10, NA), nbins = 4, type = "equal"),
                   factor(c("low", "very_high", NA),
                          levels = c("low", "medium", "high", "very_high")))
  expect_identical(fct_num(setNames(1:4, letters[1:4]), breaks = 2),
                   fct_num(1:4, breaks = 2))
})
