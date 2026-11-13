test_that("default CI and SD formatting stays unchanged", {
  expect_identical(stat_ci(1.23, .95, 1.59), "1.23 (0.95\u20131.59)")
  expect_identical(stat_ci(1.23, .95, 1.59, bracket = "[", sep = " to "),
                   "1.23 [0.95 to 1.59]")
  expect_identical(stat_ci(1.23, .15), "1.2(0.1)")
  expect_identical(stat_ci("1.23 (0.95, 1.59)", sep = " to "),
                   "1.23 (0.95 to 1.59)")
  expect_identical(stat_ci(12, 10, 15, digits = 0), "12 (10\u201315)")
})

test_that("character intervals allow whitespace inside both bracket types", {
  x <- c(open = "1.00 ( 0.50, 1.50)", close = "1.00 (0.50, 1.50 )",
         square = "1.00 [ 0.50; 1.50 ]", multiline = "1.00 (\t0.50,\n1.50\r\n)")
  expected <- stats::setNames(rep("1.00 (0.50\u20131.50)", length(x)), names(x))
  expect_no_warning(actual <- stat_ci(x))
  expect_identical(actual, expected)
  expect_no_warning(actual <- stat_ci(x, bracket = "[", sep = " to "))
  expect_identical(actual, stats::setNames(rep("1.00 [0.50 to 1.50]", length(x)), names(x)))
})

test_that("surrounding NBSP is ignored when character intervals are reformatted", {
  x <- c(leading = "\u00a01.00 (0.50, 1.50)",
         trailing = "1.00 (0.50, 1.50)\u00a0",
         mixed = " \t\u00a01.00 (0.50, 1.50)\u00a0\n",
         stars = "\u00a01.00 (0.50, 1.50)\u00a0**\u00a0")
  expected <- stats::setNames(rep("1.00 (0.50\u20131.50)", length(x)), names(x))
  expect_no_warning(actual <- stat_ci(x))
  expect_identical(actual, expected)
  expect_no_warning(actual <- stat_ci(x, bracket = "[", sep = ", "))
  expect_identical(actual, stats::setNames(rep("1.00 [0.50, 1.50]", length(x)), names(x)))
})

test_that("Unicode bracket gaps preserve signs and detected scientific precision", {
  x <- c(comma = "\u20130.25\u00a0(\u00a0\u20130.40\u00a0,\u00a0\u20130.10\u00a0)\u00a0*\u00a0*",
         semicolon = "\u22120.25\uff08\u2003\u20140.40\u00a0;\u00a0\u20140.10\u2003\uff09",
         words = "2.5e-1\u00a0[\u202f1.0e-1\u00a0to\u20034.0e-1\u202f]")
  expected <- c(comma = "-0.25 [-0.40 to -0.10]",
                semicolon = "-0.25 [-0.40 to -0.10]",
                words = "0.25 [0.10 to 0.40]")
  expect_no_warning(actual <- stat_ci(x, bracket = "[", sep = " to "))
  expect_identical(actual, expected)
})

test_that("Unicode whitespace does not hide malformed strings or trailing text", {
  x <- c(brackets = "1.00 (\u00a00.50,\u00a01.50 ]",
         estimate = "1.\u00a000 (0.50, 1.50)",
         sign = "1.00 (-\u00a00.50, 1.50)",
         exponent = "1.00 (0.50e\u00a0-1, 1.50)")
  expect_warning(actual <- stat_ci(x), "4 elements could not")
  expect_identical(actual, x)
  expect_warning(actual <- stat_ci(
    "\u00a01.00 (\u00a00.50, 1.50\u00a0)\u00a0footnote\u00a0"),
    "1 element had trailing text")
  expect_identical(actual, "1.00 (0.50\u20131.50)")
})

test_that("whitespace preserves precision overrides and output separators", {
  x <- c(decimal = "1.230 (0.950, 1.590)",
         scientific = "-1.2e-3 (-1.7e-3, -0.7e-3)")
  spaced <- gsub("(", "(\u00a0", x, fixed = TRUE)
  spaced <- gsub(")", "\u00a0)", spaced, fixed = TRUE)
  spaced <- stats::setNames(paste0("\u00a0", spaced, "\u00a0"), names(x))
  for (digits in list(NULL, 0L, 4L)) {
    for (sep in c(", ", " to ")) {
      expected <- stat_ci(x, digits = digits, bracket = "[", sep = sep)
      expect_no_warning(actual <- stat_ci(
        spaced, digits = digits, bracket = "[", sep = sep))
      expect_identical(actual, expected)
    }
  }
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

test_that("character vectors retain independently detected precision", {
  x <- c(integer = "12 (10, 15)", precise = "1.200 (0.950, 1.590)",
         scientific = "1.2e-3 (0.8e-3, 1.7e-3)", missing = NA_character_)
  expect_identical(stat_ci(x, bracket = "[", sep = " to "),
                   c(integer = "12 [10 to 15]", precise = "1.200 [0.950 to 1.590]",
                     scientific = "0.0012 [0.0008 to 0.0017]", missing = NA_character_))
})

test_that("repeated CI and SD formats avoid formatting every occurrence", {
  fn <- stat_ci
  e <- new.env(parent = environment(fn))
  formatted <- 0L
  e$sprintf <- function(fmt, ...) {
    formatted <<- formatted + max(c(length(fmt), lengths(list(...))))
    base::sprintf(fmt, ...)
  }
  environment(fn) <- e
  x <- c(-1e-9, (1:99) / 100)
  y <- x - .2
  z <- x + .2
  formatted <- 0L
  expect_identical(fn(rep(x, 100), rep(y, 100), rep(z, 100)), rep(stat_ci(x, y, z), 100))
  expect_lte(formatted, 2L * length(x))
  formatted <- 0L
  expect_identical(fn(rep(x, 100), rep(abs(y), 100)), rep(stat_ci(x, abs(y)), 100))
  expect_lte(formatted, 2L * length(x))
  text <- stat_ci(x, y, z)
  formatted <- 0L
  expect_identical(fn(rep(text, 100)), rep(stat_ci(text), 100))
  expect_lte(formatted, 2L * length(x))
})

test_that("CI formatting skips hashing large nearly unique inputs", {
  group_id <- vctrs::vec_group_id
  scans <- integer()
  testthat::local_mocked_bindings(vec_group_id = function(x) {
    scans <<- c(scans, nrow(x))
    group_id(x)
  }, .package = "vctrs")
  values <- seq_len(2000L)
  values[2L] <- values[1L]
  result <- stat_ci(values, values - 1L, values + 1L, digits = 0, sep = ", ")
  expect_identical(scans, 1024L)
  expect_identical(result, sprintf("%d (%d, %d)", values, values - 1L, values + 1L))

  scans <- integer()
  result <- stat_ci(rep(2, 2000), rep(1, 2000), rep(3, 2000), digits = 0, sep = ", ")
  expect_identical(scans, c(1024L, 2000L))
  expect_identical(result, rep("2 (1, 3)", 2000))
})

test_that("numeric interval formatting retains complete input storage", {
  fn <- stat_ci
  environment(fn) <- list2env(list(`[` = function(x, i, ...) {
    if (is.double(x) && length(x) == 400L && is.logical(i) && all(i))
      stop("copied complete numeric formatting inputs")
    base::`[`(x, i, ...)
  }), parent = environment(fn))
  x <- as.double(1:400)
  y <- x - .5
  z <- x + .5
  expect_identical(fn(x, y, z), stat_ci(x, y, z))
  expect_identical(fn(x, y), stat_ci(x, y))
  x[20L] <- NA
  expect_identical(fn(x, y, z), stat_ci(x, y, z))
})

test_that("mixed confidence interval text formats only parsed rows", {
  fn <- stat_ci
  env <- new.env(parent = environment(fn))
  env$sprintf <- function(fmt, ...) {
    if (startsWith(fmt, "%.*f") && length(list(...)[[1L]]) > 2L) stop("formatted unparsed rows")
    base::sprintf(fmt, ...)
  }
  environment(fn) <- env
  x <- c("1.20 (0.90, 1.50)", rep(NA_character_, 40), "2.00 [1.00; 3.00]", "")
  expect_identical(fn(x), stat_ci(x))
})

test_that("complete numeric confidence interval formatting avoids missing masks", {
  fn <- stat_ci
  env <- new.env(parent = environment(fn))
  env$is.na <- function(x) {
    if (is.double(x) && length(x) == 500L && !anyNA(x)) stop("built a full numeric missing mask")
    base::is.na(x)
  }
  environment(fn) <- env
  x <- stats::setNames(as.double(seq_len(500L)), seq_len(500L))
  expect_identical(fn(x, x - .5, x + .5), stat_ci(x, x - .5, x + .5))
  expect_identical(fn(x, x / 2), stat_ci(x, x / 2))
  expect_identical(fn(x[1:2], x[1:2] / 2, digits = 7900), stat_ci(x[1:2], x[1:2] / 2, digits = 7900))
})
