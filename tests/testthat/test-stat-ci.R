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

test_that("numeric storage must represent ordinary one-dimensional values", {
  values <- list(structure(10, class = "integer64"), as.Date("2020-01-01"),
                 as.POSIXct("2020-01-01", tz = "UTC"),
                 as.difftime(10, units = "days"))
  for (x in values) {
    expect_error(stat_ci(x, 5, 20), "ordinary numeric")
    expect_error(stat_ci(10, x, 20), "ordinary numeric")
    expect_error(stat_ci(10, 5, x), "ordinary numeric")
    expect_error(stat_ci(10, x), "ordinary numeric")
  }
  for (x in list(matrix(1), array(1, c(1, 1, 1)))) {
    expect_error(stat_ci(x, 0, 2), "vector")
    expect_error(stat_ci(1, x, 2), "vector")
    expect_error(stat_ci(1, 0, x), "vector")
    expect_error(stat_ci(1, x), "vector")
  }
  expect_error(stat_ci(matrix("1.23 (0.95, 1.59)")), "vector")
  expect_identical(stat_ci(1.23, .95, 1.59), "1.23 (0.95\u20131.59)")
  expect_identical(stat_ci("1.23 (0.95, 1.59)", y = matrix(1), z = Sys.Date()),
                   "1.23 (0.95\u20131.59)")
})

test_that("empty inputs retain the character return type in every mode", {
  expect_identical(stat_ci(character()), character())
  expect_identical(stat_ci(character(), digits = 2L), character())
  expect_identical(stat_ci(numeric(), numeric(), numeric()), character())
  expect_identical(stat_ci(numeric(), numeric()), character())
  expect_error(stat_ci(character(), digits = -1), "digits")
})

test_that("discarded trailing text is reported once for the input vector", {
  x <- c("1.23 (0.95, 1.59), p=0.02", "1.23 (0.95, 1.59) footnote",
         "1.23 (0.95, 1.59)**", "1.23 (0.95, 1.59)")
  expect_warning(out <- stat_ci(x), "2 elements.*trailing text")
  expect_identical(out, rep("1.23 (0.95\u20131.59)", 4))
  expect_no_warning(stat_ci("1.23 (0.95, 1.59)** "))
  expect_no_warning(stat_ci("1.23 (0.95, 1.59)."))
})

test_that("missing numeric components produce genuine missing strings", {
  expect_identical(stat_ci(c(NA, 1, 1, NaN, 1), c(.1, NA, .5, 0, .5),
                           c(2, 1.5, NA, 1, 1.5)),
                   c(rep(NA_character_, 4), "1.00 (0.50\u20131.50)"))
  expect_identical(stat_ci(c(NA, 1, 1), c(.1, NA, .1)),
                   c(NA_character_, NA_character_, "1.0(0.1)"))
  expect_identical(stat_ci(NA, NA, NA), NA_character_)
  expect_identical(stat_ci(NA, NA), NA_character_)
  expect_error(stat_ci(TRUE, .1), "numeric")
  expect_identical(stat_ci(1, -Inf, Inf), "1.00 (-Inf\u2013Inf)")
})

test_that("serialized labelled missing codes retain their meaning", {
  x <- structure(c(1, 99, NA), na_values = 99,
                 class = c("haven_labelled_spss", "haven_labelled",
                           "vctrs_vctr", "double"))
  expect_identical(stat_ci(x, c(.5, 98, 0), c(1.5, 100, 1)),
                   c("1.00 (0.50\u20131.50)", NA_character_, NA_character_))
  expect_identical(stat_ci(c(1, 1, 1), x),
                   c("1.0(1.0)", NA_character_, NA_character_))
})

test_that("missing and whitespace-only strings pass through without warnings", {
  blanks <- c(NA_character_, "", " \t\n", "\u00a0\u2003")
  expect_no_warning(out <- stat_ci(blanks))
  expect_identical(out, blanks)
  expect_warning(out <- stat_ci(c(blanks, "Reference")), "1 element could not")
  expect_identical(out, c(blanks, "Reference"))
})

test_that("output names follow x in every formatting mode", {
  x <- c(first = 1.23, missing = NA_real_)
  expect_identical(stat_ci(x, c(.95, .5), c(1.59, 1.5)),
                   c(first = "1.23 (0.95\u20131.59)", missing = NA_character_))
  expect_identical(stat_ci(x, c(.15, .1)),
                   c(first = "1.2(0.1)", missing = NA_character_))
  expect_identical(stat_ci(c(first = "1.23 (0.95, 1.59)", missing = NA)),
                   c(first = "1.23 (0.95\u20131.59)", missing = NA_character_))
  expect_identical(stat_ci(c(missing = NA), NA), c(missing = NA_character_))
  empty <- stats::setNames(character(), character())
  expect_identical(stat_ci(empty), empty)
  expect_null(names(stat_ci(1.23, c(other = .95), 1.59)))
})

test_that("formatted zero loses its sign without changing other rounding", {
  expect_identical(stat_ci(-.0001, -.004, .004), "0.00 (0.00\u20130.00)")
  expect_identical(stat_ci(-.0001, -.0001, digits = 2), "0.00(0.00)")
  expect_identical(stat_ci("-0.0001 (-0.004, 0.004)", digits = 2),
                   "0.00 (0.00\u20130.00)")
  expect_identical(stat_ci(-.1, -.4, .4, digits = 0), "0 (0\u20130)")
  expect_identical(stat_ci(-.01, -.10, .20), "-0.01 (-0.10\u20130.20)")
  expect_identical(stat_ci(-.15, .15, digits = 1), sprintf("%.1f(%.1f)", -.15, .15))
  expect_warning(out <- stat_ci("Reference -0.00"), "could not be parsed")
  expect_identical(out, "Reference -0.00")
})
