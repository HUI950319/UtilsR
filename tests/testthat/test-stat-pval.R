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

test_that("numeric P-value text is checked before double rounding", {
  invalid <- c("-1e-999", "-.1E-9999999999", "-0.0000000001e-999",
                "1.00000000000000001", "100000000000000001e-17",
                ".100000000000000001E+1")
  for (x in invalid) {
    for (mode in c("stars", "pvalue")) {
      expect_error(stat_pval(c(NA_character_, "0.05", x), mode = mode),
                   "between 0 and 1")
    }
  }
})

test_that("all bound operators validate the original P-value endpoint", {
  for (endpoint in c("-1e-999", "1.00000000000000001", ".100000000000000001E+1")) {
    for (operator in c("<", "<=", ">", ">=", "\u2264", "\u2265")) {
      x <- paste0("\u2009", operator, "\u00a0", endpoint, "\u202f")
      for (mode in c("stars", "pvalue")) {
        expect_error(stat_pval(x, mode = mode), "between 0 and 1")
      }
      expect_identical(stat_pval(x, mode = "plain"),
                       paste0(operator, "\u00a0", endpoint))
    }
  }
})

test_that("extreme exponents preserve valid tiny values and exact endpoints", {
  huge <- strrep("9", 400)
  zeros <- strrep("0", 400)
  tiny <- c(paste0("1e-", huge), paste0("+000.1E-", zeros, "999"))
  bounds <- c(paste0("<", tiny), paste0(">", tiny),
              paste0("<=-0e", huge), paste0("\u22650E-", huge),
              paste0(">=1e+", zeros), ">0.99999999999999999")
  x <- c(missing = NA_character_, first = tiny[[1]], second = tiny[[2]],
         setNames(bounds, paste0("bound", seq_along(bounds))), absent = "NaN")
  for (mode in c("stars", "pvalue", "plain")) {
    small <- switch(mode, stars = "<0.001***", pvalue = "<0.001", plain = "0.00")
    expected <- c(NA_character_, small, small, bounds, NA_character_)
    expect_identical(stat_pval(x, mode = mode), setNames(expected, names(x)))
  }
  impossible <- c(paste0("<0e", huge), paste0("<-0E-", huge),
                  paste0(">1e-", zeros), paste0(">.1e+", zeros, "1"))
  for (x in impossible) {
    for (mode in c("stars", "pvalue")) {
      expect_error(stat_pval(x, mode = mode), "possible P-value")
    }
    expect_identical(stat_pval(x, mode = "plain"), x)
  }
})

test_that("numeric parser overflow cannot hide invalid P-value text", {
  zeros <- strrep("0", 5000)
  above <- paste0("1", zeros, "1e-5001")
  negative <- paste0("-1", zeros, "e-9999999999")
  for (x in c(above, negative, paste0("<=", above), paste0("\u2265", negative))) {
    for (mode in c("stars", "pvalue")) {
      expect_error(stat_pval(x, mode = mode), "between 0 and 1")
    }
  }
  expect_error(stat_pval(paste0(">1", zeros, "e-5000")), "possible P-value")
})

test_that("long decimal strings equal to one retain their numeric value", {
  zeros <- strrep("0", 5000)
  one <- c(integer = paste0("1", zeros, "e-5000"),
           decimal = paste0("1", zeros, ".0e-5000"),
           trailing = paste0("1.", zeros),
           signed = paste0("+0001", zeros, ".000e-5000"),
           fractional = paste0("0.", zeros, "1e5001"),
           shifted = paste0(".1", zeros, "E+1"),
           exponent = paste0("1", zeros, "E-", strrep("0", 400), "5000"))
  for (mode in c("stars", "pvalue", "plain")) {
    expected <- if (mode == "plain") "1.00" else "1.000"
    expect_identical(stat_pval(one, mode = mode),
                     setNames(rep(expected, length(one)), names(one)))
  }
})

test_that("recovered unit values keep their positions and significance symbols", {
  one <- paste0("1", strrep("0", 5000), "e-5000")
  x <- c(absent = NA_character_, unit = one, ordinary = "0.05",
         bound = paste0("<=", one), nan = "NaN", other_unit = "1")
  expected <- c(absent = NA_character_, unit = "1.000unit", ordinary = "0.050small",
                bound = paste0("<=", one), nan = NA_character_, other_unit = "1.000unit")
  expect_identical(stat_pval(x, map_signif = c(small = .05, unit = 1)), expected)
  expect_identical(stat_pval(one, map_signif = c(small = .05)), "1.000")
  expect_identical(stat_pval(one, map_signif = numeric()), "1.000")
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(x, mode = mode, digits = 4),
                     c(absent = NA_character_, unit = "1.0000",
                       ordinary = if (mode == "stars") "0.0500*" else "0.0500",
                       bound = paste0("<=", one), nan = NA_character_, other_unit = "1.0000"))
  }
})

test_that("long unit endpoints keep bound and range validation", {
  zeros <- strrep("0", 5000)
  one <- c(paste0("1", zeros, "e-5000"), paste0("1.", zeros))
  for (endpoint in one) {
    bounds <- paste0(c("<", "<=", ">=", "\u2264", "\u2265"), "\u00a0", endpoint)
    for (mode in c("stars", "pvalue", "plain")) {
      expect_identical(stat_pval(paste0("\u2009", bounds, "\u202f"), mode = mode), bounds)
    }
    impossible <- paste0(">\u00a0", endpoint)
    for (mode in c("stars", "pvalue")) {
      expect_error(stat_pval(impossible, mode = mode), "possible P-value")
      expect_error(stat_pval(paste0("-", endpoint), mode = mode), "between 0 and 1")
      expect_error(stat_pval(paste0("<=-", endpoint), mode = mode), "between 0 and 1")
    }
    expect_identical(stat_pval(impossible, mode = "plain"), impossible)
  }
  above_one <- paste0("1", zeros, "1e-5001")
  for (mode in c("stars", "pvalue")) {
    expect_error(stat_pval(above_one, mode = mode), "between 0 and 1")
    expect_error(stat_pval(paste0("<=", above_one), mode = mode), "between 0 and 1")
  }
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

test_that("P-value bounds must describe a possible value", {
  impossible <- c("<0", "< -0.0", "<+0e-10", "<.000e+999", ">1", ">+1.0",
                  ">10e-1", ">.1e1", ">00100.0e-2", ">\u00a01.0")
  for (x in impossible) {
    expect_error(stat_pval(x), "possible P-value")
    expect_error(stat_pval(x, mode = "pvalue"), "possible P-value")
    expect_identical(stat_pval(x, mode = "plain"), x)
  }
  valid <- c(a = "<=0", b = ">=1", c = "\u22640", d = "\u22651", e = "<1",
             f = ">0", g = "<1e-999", h = ">0.99999999999999999", i = NA_character_)
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(valid, mode = mode), valid)
  }
  expect_identical(stat_pval("<0", add_star_p = .01), "<0**")
})

test_that("SPSS numeric formatting handles discrete and ranged missing values", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(
    c(small = .0003, lower = .02, middle = .03, upper = .04, large = .5,
      code = 99, missing = NA_real_, nan = NaN, tagged = haven::tagged_na("a")),
    labels = c(Small = .0003, Missing = 99),
    na_values = 99, na_range = c(.02, .04)
  )
  before <- serialize(x, NULL)
  for (mode in c("stars", "pvalue", "plain")) {
    small <- switch(mode, stars = "<0.001***", pvalue = "<0.001", plain = "0.00")
    large <- if (mode == "plain") "0.50" else "0.500"
    expect_identical(stat_pval(x, mode = mode),
                     c(small = small, lower = NA_character_, middle = NA_character_,
                       upper = NA_character_, large = large, code = NA_character_,
                       missing = NA_character_, nan = NA_character_, tagged = NA_character_))
  }
  expect_identical(serialize(x, NULL), before)
})

test_that("SPSS P-values leave observed text unchanged when user-missing", {
  skip_if_not_installed("haven")
  p <- haven::labelled_spss(c(.01, .02, .03, .04, .5, 99, NA_real_,
                            haven::tagged_na("a")),
                          na_values = 99, na_range = c(.02, .04))
  x <- setNames(c("HR", "RR", "OR", "MD", NA, "SD", "AUC", "C"),
                paste0("effect", seq_along(p)))
  before <- serialize(list(x, p), NULL)
  expect_identical(stat_pval(x, add_star_p = p),
                   setNames(c("HR**", "RR", "OR", "MD", NA, "SD", "AUC", "C"), names(x)))
  expect_identical(serialize(list(x, p), NULL), before)
})

test_that("SPSS display values stay missing when ordinary P-values add stars", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(c(a = 1.5, b = .02, c = .03, d = .04, e = 99,
                            f = NA_real_, g = NaN, h = haven::tagged_na("a")),
                          na_values = 99, na_range = c(.02, .04))
  before <- serialize(x, NULL)
  expect_identical(stat_pval(x, add_star_p = rep(.01, length(x))),
                   c(a = "1.5**", b = NA_character_, c = NA_character_,
                     d = NA_character_, e = NA_character_, f = NA_character_,
                     g = NA_character_, h = NA_character_))
  expect_identical(serialize(x, NULL), before)
})

test_that("SPSS character missing codes are removed before parsing or annotation", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(
    c(exact = "0.05", code = "missing", bound = "<0.001", absent = NA_character_,
      nan = "NaN", empty = ""), na_values = c("missing", "")
  )
  before <- serialize(x, NULL)
  for (mode in c("stars", "pvalue", "plain")) {
    exact <- switch(mode, stars = "0.050*", pvalue = "0.050", plain = "0.05")
    expect_identical(stat_pval(x, mode = mode),
                     c(exact = exact, code = NA_character_, bound = "<0.001",
                       absent = NA_character_, nan = NA_character_, empty = NA_character_))
  }
  expect_identical(stat_pval(x, add_star_p = rep(.01, length(x))),
                   c(exact = "0.05**", code = NA_character_, bound = "<0.001**",
                     absent = NA_character_, nan = "NaN**", empty = NA_character_))
  expect_identical(serialize(x, NULL), before)
})

test_that("empty and entirely missing SPSS vectors retain their return contract", {
  skip_if_not_installed("haven")
  for (x in list(haven::labelled_spss(numeric(), na_values = 99),
                 haven::labelled_spss(character(), na_values = "missing"))) {
    for (mode in c("stars", "pvalue", "plain")) {
      expect_identical(stat_pval(x, mode = mode), character())
    }
    expect_identical(stat_pval(x, add_star_p = numeric()), character())
  }
  x <- haven::labelled_spss(c(a = .01, b = .02, c = 99, d = NA_real_),
                          na_values = c(.01, 99), na_range = c(.02, .04))
  for (mode in c("stars", "pvalue", "plain")) {
    expect_identical(stat_pval(x, mode = mode), setNames(rep(NA_character_, 4), names(x)))
  }
  expect_identical(stat_pval(rep("HR", 4), add_star_p = x), rep("HR", 4))
  expect_identical(stat_pval(x, add_star_p = x), setNames(rep(NA_character_, 4), names(x)))
})

test_that("SPSS metadata does not hide invalid observed P-values or controls", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(c(.02, 1.2), na_values = .02)
  for (mode in c("stars", "pvalue")) {
    expect_error(stat_pval(x, mode = mode), "between 0 and 1")
  }
  expect_identical(stat_pval(x, mode = "plain"), c(NA_character_, "1.20"))
  expect_error(stat_pval(c("HR", "RR"), add_star_p = x), "between 0 and 1")
  expect_error(stat_pval(.01, digits = haven::labelled_spss(3)), "digits")
  expect_error(stat_pval(.01, map_signif = haven::labelled_spss(c("*" = .05))), "map_signif")
  expect_error(stat_pval("HR", add_star_p = haven::labelled_spss("missing", na_values = "missing")),
               "numeric")
})

test_that("SPSS normalization reports an unavailable optional dependency", {
  x <- structure(c(.01, 99), class = c("haven_labelled_spss", "haven_labelled"), na_values = 99)
  fn <- stat_pval
  isolated <- new.env(parent = environment(fn))
  isolated$requireNamespace <- function(package, quietly = FALSE) FALSE
  environment(fn) <- isolated
  expect_error(fn(x), "requires package.*haven")
  expect_error(fn(c("HR", "RR"), add_star_p = x), "requires package.*haven")
  expect_identical(fn(.01), "0.010**")
  expect_identical(fn("HR", add_star_p = .01), "HR**")
})

# Avoid preloading UtilsR's Imports, which would register haven's S3 methods.
stat_pval_in_fresh_r <- function(args) {
  files <- c(script = tempfile(fileext = ".R"), input = tempfile(fileext = ".rds"),
             output = tempfile(fileext = ".rds"))
  on.exit(unlink(files), add = TRUE)
  isolated <- new.env(parent = baseenv())
  isolated$stat_pval <- stat_pval
  isolated$.validate_signif_map <- get(".validate_signif_map", envir = environment(stat_pval))
  isolated$.parse_decimal_tokens <- get(".parse_decimal_tokens", envir = environment(stat_pval))
  isolated$.trim_pvalue_space <- get(".trim_pvalue_space", envir = environment(stat_pval))
  isolated$`%||%` <- function(x, y) if (is.null(x)) y else x
  for (name in ls(isolated, all.names = TRUE)) environment(isolated[[name]]) <- isolated
  saveRDS(list(fn = isolated$stat_pval, args = args, libs = .libPaths()), files[["input"]])
  writeLines(c(
    "local({",
    "  args <- commandArgs(TRUE)",
    "  fixture <- readRDS(args[[1L]])",
    "  .libPaths(fixture[['libs']])",
    "  loaded_before <- 'haven' %in% loadedNamespaces()",
    "  before <- serialize(fixture[['args']], NULL)",
    "  error <- NULL",
    "  value <- tryCatch(do.call(fixture[['fn']], fixture[['args']]),",
    "                    error = function(e) { error <<- conditionMessage(e); NULL })",
    "  saveRDS(list(loaded_before = loaded_before, error = error, value = value,",
    "               unchanged = identical(before, serialize(fixture[['args']], NULL))),",
    "          args[[2L]])",
    "})"
  ), files[["script"]])
  executable <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  previous_tests <- Sys.getenv("R_TESTS", unset = NA_character_)
  Sys.unsetenv("R_TESTS")
  on.exit(if (is.na(previous_tests)) Sys.unsetenv("R_TESTS") else
    Sys.setenv(R_TESTS = previous_tests), add = TRUE)
  output <- system2(executable, c("--vanilla", shQuote(files[["script"]]),
                                 shQuote(files[["input"]]), shQuote(files[["output"]])),
                    stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(output, "status")) || !file.exists(files[["output"]])) {
    stop(paste(output, collapse = "\n"))
  }
  readRDS(files[["output"]])
}

test_that("serialized SPSS annotation P-values work before haven is loaded", {
  skip_if_not_installed("haven")
  p <- haven::labelled_spss(c(.01, .02, 99, NA_real_), na_values = c(.02, 99))
  result <- stat_pval_in_fresh_r(list(x = c(a = "HR", b = "RR", c = "OR", d = "MD"),
                                     add_star_p = p))
  expect_identical(result$loaded_before, FALSE)
  expect_null(result$error)
  expect_identical(result$value, c(a = "HR**", b = "RR", c = "OR", d = "MD"))
  expect_identical(result$unchanged, TRUE)
})

test_that("serialized SPSS numeric inputs work in every mode before haven is loaded", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(
    c(small = .0003, lower = .02, middle = .03, upper = .04, large = .5,
      code = 99, missing = NA_real_, nan = NaN, tagged = haven::tagged_na("a")),
    na_values = 99, na_range = c(.02, .04)
  )
  for (mode in c("stars", "pvalue", "plain")) {
    result <- stat_pval_in_fresh_r(list(x = x, mode = mode))
    small <- switch(mode, stars = "<0.001***", pvalue = "<0.001", plain = "0.00")
    large <- if (mode == "plain") "0.50" else "0.500"
    expect_identical(result$loaded_before, FALSE)
    expect_null(result$error)
    expect_identical(result$value,
                     c(small = small, lower = NA_character_, middle = NA_character_,
                       upper = NA_character_, large = large, code = NA_character_,
                       missing = NA_character_, nan = NA_character_, tagged = NA_character_))
    expect_identical(result$unchanged, TRUE)
  }
})

test_that("serialized SPSS display text keeps user-missing values missing", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(c(a = "HR", b = "missing", c = NA_character_, d = "RR"),
                          na_values = "missing")
  result <- stat_pval_in_fresh_r(list(x = x, add_star_p = c(.01, .01, .01, NA)))
  expect_identical(result$loaded_before, FALSE)
  expect_null(result$error)
  expect_identical(result$value, c(a = "HR**", b = NA_character_, c = NA_character_, d = "RR"))
  expect_identical(result$unchanged, TRUE)
})

test_that("textual P significance respects exact decimal boundaries", {
  x <- c("0.050000000000000000001", "0.010000000000000000001", "0.001000000000000000001")
  expect_identical(stat_pval(x), c("0.050.", "0.010*", "0.001**"))
  expect_identical(stat_pval(c("0.05", "0.01", "0.001")), c("0.050*", "0.010**", "0.001***"))
  expect_identical(stat_pval(c("1e-999", "0"), map_signif = c(Z = 0, S = .05)), c("<0.001S", "<0.001Z"))
  expect_identical(stat_pval(c("0.050000000000000005", "0.05000000000000002"), map_signif = c(S = .05000000000000001)), c("0.050S", "0.050"))
})

test_that("oversized decimal mantissas preserve finite P values", {
  zeros <- strrep("0", 5000L)
  x <- c(a = paste0("2", zeros, "e-5001"), b = paste0("123456", zeros, "e-5006"))
  expect_identical(stat_pval(x), c(a = "0.200", b = "0.123"))
  cold <- stat_pval_in_fresh_r(list(x = x))
  expect_null(cold$error)
  expect_identical(cold$value, stat_pval(x))
  expect_identical(stat_pval(paste0("-2", zeros, "e-5001"), mode = "plain"), "-0.20")
  expect_identical(stat_pval(paste0("<2", zeros, "e-5001")), paste0("<2", zeros, "e-5001"))
})

test_that("numeric significance lookup avoids repeated full vector comparisons", {
  fn <- stat_pval
  e <- new.env(parent = environment(fn))
  examined <- 0L
  e$`<=` <- function(x, y) {
    examined <<- examined + length(x)
    base::`<=`(x, y)
  }
  environment(fn) <- e
  p <- rep(c(0, .05, .5, 1, NA_real_), 2000)
  map <- stats::setNames(seq(0, 1, length.out = 30), sprintf("S%02d", 1:30))
  actual <- fn(p, map_signif = map)
  expect_lte(examined, 2L * length(p))
  expect_identical(actual, rep(c("<0.001S01", "0.050S03", "0.500S16", "1.000S30", NA_character_), 2000))
})

test_that("repeated numeric P values reuse validated formatting work", {
  fn <- stat_pval
  e <- new.env(parent = environment(fn))
  formatted <- 0L
  e$sprintf <- function(fmt, ...) {
    if (length(fmt) == 1L && grepl("^%\\.[0-9]+f$", fmt))
      formatted <<- formatted + max(lengths(list(...)))
    base::sprintf(fmt, ...)
  }
  environment(fn) <- e
  catalog <- c(0, -0, .0002, .05, .1, 1, NA_real_, NaN)
  p <- stats::setNames(rep(catalog, 600), paste0("row", seq_len(4800)))
  for (mode in c("stars", "pvalue")) for (map in list(c(S = .05, Z = 0, N = 1), numeric())) {
    expected <- stats::setNames(rep(stat_pval(catalog, mode = mode, map_signif = map), 600), names(p))
    formatted <- 0L
    expect_identical(fn(p, mode = mode, map_signif = map), expected)
    expect_lte(formatted, length(catalog))
  }
  expected <- stats::setNames(rep(stat_pval(catalog, mode = "plain"), 600), names(p))
  expect_identical(fn(p, mode = "plain", map_signif = stop("unused map")), expected)
  text <- rep(c("0.05", "0.050000000000000000001"), 1200)
  expect_identical(fn(text), rep(c("0.050*", "0.050."), 1200))
  expect_error(fn(c(rep(.05, 4800), 1.1)), "finite P-values")
})

test_that("P-value formatters trim only whitespace at the edges", {
  slow_trim <- function(x, ...) {
    if (any(nchar(x) > 1000L, na.rm = TRUE)) stop("repeated interior whitespace")
    base::trimws(x, ...)
  }
  p <- stat_pval
  cells <- UtilsR:::._p_cells
  environment(p) <- list2env(list(trimws = slow_trim), parent = environment(p))
  environment(cells) <- list2env(list(trimws = slow_trim, ._pr_colour = function() FALSE),
                                parent = environment(cells))
  padding <- strrep(" ", 12000L)
  values <- c(a = paste0("\u00a0<", padding, "0.01\u202f"), b = "\u20030.5\n")
  expect_true(identical(p(values), c(a = paste0("<", padding, "0.01"), b = "0.500")))
  expect_error(p(paste0("0.05", padding, "text")), "numeric strings or numeric bounds")
  expect_identical(cells(values), c(paste0("<", padding, "0.01**"), "0.5"))
})
