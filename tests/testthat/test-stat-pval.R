test_that("default formatting and significance boundaries stay unchanged", {
  expect_identical(formals(stat_pval)$digits, NULL)
  expect_identical(formals(stat_pval)$mode, quote(c("stars", "pvalue", "plain")))
  expect_identical(eval(formals(stat_pval)$map_signif),
                   c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1))
  expect_identical(stat_pval(c(0.00049, 0.00099, 0.001, 0.001001,
                             0.01, 0.05, 0.050001, 0.1, 0.100001)),
                   c("<0.001***", "0.001***", "0.001***", "0.001**",
                     "0.010**", "0.050*", "0.050.", "0.100.", "0.100"))
  expect_identical(stat_pval(1.2345, mode = "plain"), "1.23")
  expect_identical(stat_pval("HR", add_star_p = 0.01, mode = "ignored",
                            digits = "ignored"), "HR**")
})

test_that("missing values stay missing when stars are appended", {
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(c(NA_real_, NaN), mode = mode),
                     rep(NA_character_, 2))
    expect_identical(stat_pval(c(NA_character_, "NA", "NaN"), mode = mode),
                     rep(NA_character_, 3))
  }
  expect_identical(stat_pval(c(NA_character_, "HR"), add_star_p = c(.01, NA)),
                   c(NA_character_, "HR"))
  expect_identical(stat_pval(c(NaN, 1), add_star_p = c(.01, .01)),
                   c(NA_character_, "1**"))
  expect_identical(stat_pval(c("", "HR"), add_star_p = c(NA, .01)), c("", "HR**"))
})

test_that("character bounds retain their meaning without inferred stars", {
  x <- c("<0.001", ">0.05", "<=0.01", ">=0.1", "\u22640.05", "\u22650.1")
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(x, mode = mode), x)
  }
  expect_identical(stat_pval(c("  < 0.001  ", " 1e-2 ")),
                   c("< 0.001", "0.010**"))
  for (x in c("1<2", "P=0.03", "0.03*", "", "text", "<<0.05", "<Inf")) {
    expect_error(stat_pval(x), "numeric strings")
  }
})

test_that("P-value paths reject nonfinite and out-of-range observations", {
  for (p in c(-0.1, 1.2, Inf, -Inf)) {
    for (mode in c("stars", "pvalue")) {
      expect_error(stat_pval(c(NA, .05, p), mode = mode), "between 0 and 1")
      expect_error(stat_pval(as.character(p), mode = mode), "between 0 and 1")
    }
    expect_error(stat_pval("HR", add_star_p = p), "between 0 and 1")
  }
  expect_error(stat_pval("<1.5"), "between 0 and 1")
  expect_error(stat_pval("1e999"), "between 0 and 1")
  expect_identical(stat_pval(c(0, 1)), c("<0.001***", "1.000"))
  expect_identical(stat_pval(c(-.1, 1.2, Inf, -Inf), mode = "plain"),
                   c("-0.10", "1.20", "Inf", "-Inf"))
})

test_that("special numeric storage cannot be mistaken for P-values", {
  values <- list(as.difftime(.01, units = "secs"), as.Date("1970-01-01"),
                 as.POSIXct("1970-01-01", tz = "UTC"))
  for (x in values) {
    for (mode in c("stars", "pvalue", "plain")) {
      expect_error(stat_pval(x, mode = mode), "ordinary numeric")
    }
    expect_error(stat_pval("HR", add_star_p = x), "ordinary numeric")
  }
})

test_that("integer64 input is rejected before reading its double storage", {
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(c(0, 1, NA))
  for (mode in c("stars", "pvalue", "plain")) {
    expect_error(stat_pval(x, mode = mode), "ordinary numeric")
  }
  expect_error(stat_pval(rep("HR", 3), add_star_p = x), "ordinary numeric")
  expect_identical(stat_pval(as.double(x)), c("<0.001***", "1.000", NA_character_))
})

test_that("digits is checked before conversion or formatting", {
  invalid <- list(-1, -.9, 1.9, NA_real_, Inf, numeric(), c(2, 3), "3", TRUE,
                  .Machine$integer.max + 1, as.difftime(3, units = "secs"))
  for (digits in invalid) {
    for (mode in c("stars", "pvalue", "plain")) {
      expect_error(stat_pval(.0123, digits = digits, mode = mode), "digits")
    }
  }
  expect_error(stat_pval(.1, digits = 0), "digits")
  expect_error(stat_pval(.1, digits = 0, mode = "pvalue"), "digits")
  expect_identical(stat_pval(1.2, digits = 0, mode = "plain"), "1")
  expect_identical(stat_pval(.0123, digits = 4L), "0.0123*")
})

test_that("star maps have the same validation in both entry paths", {
  invalid <- list(.05, c("*" = NA_real_), c("*" = Inf), c("*" = -.1),
                  c("*" = 1.2), setNames(.05, NA_character_), c("*" = "0.05"),
                  matrix(.05), structure(.05, class = "integer64"))
  for (map in invalid) {
    expect_error(stat_pval(.01, map_signif = map), "map_signif")
    expect_error(stat_pval("HR", add_star_p = .01, map_signif = map), "map_signif")
  }
  expect_identical(stat_pval(.01, map_signif = numeric()), "0.010")
  expect_identical(stat_pval("HR", add_star_p = .01, map_signif = numeric()), "HR")
  expect_identical(stat_pval(.01, map_signif = c(first = .05, second = .05)),
                   "0.010first")
  expect_identical(stat_pval(c(.01, .1), map_signif = setNames(c(.05, .1), c("", "!"))),
                   c("0.010", "0.100!"))
  expect_identical(stat_pval(.01, mode = "pvalue", map_signif = "ignored"), "0.010")
})

test_that("empty vectors have a stable character return type", {
  for (x in list(numeric(), character(), setNames(numeric(), character()))) {
    for (mode in c("stars", "pvalue", "plain")) {
      expect_identical(stat_pval(x, mode = mode), setNames(character(), names(x)))
    }
    expect_identical(stat_pval(x, add_star_p = numeric()),
                     setNames(character(), names(x)))
  }
})

test_that("formatting preserves names from x in every mode", {
  x <- c(low = .01, missing = NA_real_, high = .5)
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(x, mode = mode),
                     setNames(stat_pval(unname(x), mode = mode), names(x)))
  }
  expect_identical(stat_pval(c(bound = "<0.001", exact = "0.05")),
                   c(bound = "<0.001", exact = "0.050*"))
  expect_identical(stat_pval(c(effect = "HR", missing = NA_character_),
                            add_star_p = c(first = .01, second = .05)),
                   c(effect = "HR**", missing = NA_character_))
  expect_identical(x, c(low = .01, missing = NA_real_, high = .5))
})

test_that("matrix and array inputs are rejected instead of flattened", {
  for (x in list(matrix(.01, 1, 1), array(.01, c(1, 1, 1)))) {
    for (mode in c("stars", "pvalue", "plain")) {
      expect_error(stat_pval(x, mode = mode), "x.*vector")
    }
    expect_error(stat_pval(x, add_star_p = .01), "x.*vector")
    expect_error(stat_pval("HR", add_star_p = x), "add_star_p.*vector")
  }
})

test_that("star lookup respects unsorted maps, ties, and exact cutoffs", {
  p <- c(0, .01, .01 + 1e-12, .05, .05 + 1e-12, .1, .1 + 1e-12, 1, NA, NaN)
  map <- c(loose = .1, first = .01, second = .01, middle = .05)
  expected <- c("first", "first", "middle", "middle", "loose", "loose",
                "", "", "", "")
  expect_identical(stat_pval(rep("", length(p)), add_star_p = p, map_signif = map),
                   expected)
  formatted <- paste0(stat_pval(p, mode = "pvalue"), expected)
  formatted[is.na(p)] <- NA_character_
  expect_identical(stat_pval(p, map_signif = map), formatted)
  expect_identical(stat_pval(rep("HR", 2), add_star_p = c(NA_real_, NaN)),
                   rep("HR", 2))
  expect_identical(stat_pval(c(0, 1), map_signif = c(zero = 0, one = 1)),
                   c("<0.001zero", "1.000one"))
})

test_that("signed zero follows the same P-value display and star rules", {
  for (x in list(-1 / Inf, "-0", "-0.0e0")) {
    expect_identical(stat_pval(x), "<0.001***")
    expect_identical(stat_pval(x, mode = "pvalue", digits = 4), "<0.0001")
    expect_identical(stat_pval(x, map_signif = c(zero = 0)), "<0.001zero")
  }
  expect_identical(stat_pval("-0", mode = "plain"), "-0.00")
})

test_that("logical vectors are accepted only when entirely missing", {
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(c(a = NA, b = NA), mode = mode),
                     c(a = NA_character_, b = NA_character_))
    expect_identical(stat_pval(logical(), mode = mode), character())
    expect_error(stat_pval(c(NA, TRUE), mode = mode), "numeric or character")
    expect_error(stat_pval(FALSE, mode = mode), "numeric or character")
  }
  expect_identical(stat_pval(c(a = "HR", b = NA_character_), add_star_p = c(NA, NA)),
                   c(a = "HR", b = NA_character_))
  expect_identical(stat_pval(character(), add_star_p = logical()), character())
  expect_error(stat_pval("HR", add_star_p = TRUE), "numeric")
  expect_error(stat_pval("HR", add_star_p = NA, map_signif = .05), "map_signif")
})

test_that("decimal precision respects the formatter's output limit", {
  for (x in list(.01, numeric(), NA_real_)) {
    for (mode in c("stars", "pvalue", "plain")) {
      expect_error(stat_pval(x, digits = 8191, mode = mode), "digits")
    }
  }
  expect_error(stat_pval(numeric(), digits = 1000000), "digits")
  expect_error(stat_pval(-.Machine$double.xmax, digits = 8000, mode = "plain"),
               "8192-byte")
  expect_error(stat_pval("-0", digits = 8190), "8192-byte")
  expect_identical(nchar(stat_pval(.01, digits = 8190, mode = "pvalue")), 8192L)
  expect_identical(nchar(stat_pval(9.99, digits = 8190, mode = "plain")), 8192L)
  expect_identical(stat_pval(numeric(), digits = 8190), character())
  expect_error(stat_pval(numeric(), map_signif = .05), "map_signif")
})

test_that("mixed missing, bounded and exact values retain their positions", {
  x <- c(a = NA_character_, b = "<0.001", c = "0.01", d = "NaN", e = ">=0.5")
  expect_identical(stat_pval(x),
                   c(a = NA_character_, b = "<0.001", c = "0.010**",
                     d = NA_character_, e = ">=0.5"))
  expect_identical(stat_pval(x, mode = "plain"),
                   c(a = NA_character_, b = "<0.001", c = "0.01",
                     d = NA_character_, e = ">=0.5"))
  expect_identical(stat_pval(c(Inf, NA, -Inf), mode = "plain"),
                   c("Inf", NA_character_, "-Inf"))
  for (x in list(c(NA_real_, NaN), c("<0.001", ">0.5"))) {
    expect_error(stat_pval(x, map_signif = .05), "map_signif")
    expect_identical(stat_pval(x, map_signif = numeric()),
                     stat_pval(x, mode = "pvalue"))
  }
})

test_that("numeric text accepts Unicode outer and bound-prefix whitespace", {
  for (space in c("\u00a0", "\u2009", "\u202f", "\u3000", "\u2028", "\t\n")) {
    x <- c(exact = paste0(space, "0.05", space),
           bound = paste0(space, "<", space, "0.001", space),
           unicode = paste0(space, "\u2264", space, "0.05", space),
           missing = paste0(space, "NA", space))
    for (mode in c("stars", "pvalue", "plain")) {
      expected <- c(exact = switch(mode, stars = "0.050*", pvalue = "0.050", plain = "0.05"),
                    bound = paste0("<", space, "0.001"),
                    unicode = paste0("\u2264", space, "0.05"), missing = NA_character_)
      expect_identical(stat_pval(x, mode = mode), expected)
    }
    expect_error(stat_pval(paste0("0", space, ".05")), "numeric strings")
    expect_error(stat_pval(space), "numeric strings")
  }
  expect_identical(stat_pval("\u00a0HR\u00a0", add_star_p = .01),
                   "\u00a0HR\u00a0**")
})
