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
  isolated$.register_integer64 <- get(".register_integer64", envir = environment(stat_pval))
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

test_that("external P-value stars preserve serialized integer64 labels", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  script <- file.path(scratch, "check.R")
  input <- file.path(scratch, "input.rds")
  labels <- setNames(bit64::as.integer64(c("9007199254740993", NA_character_)), c("one", "two"))
  saveRDS(list(labels = labels, libs = .libPaths(),
               path = getNamespaceInfo(asNamespace("UtilsR"), "path")), input)
  writeLines(c(sprintf("payload <- readRDS(%s)", deparse(input)),
    '.libPaths(payload[["libs"]])',
    'path <- payload[["path"]]',
    'if (file.exists(file.path(path, "Meta", "package.rds"))) {',
    '  library("UtilsR", lib.loc = dirname(path))',
    '} else pkgload::load_all(path, quiet = TRUE)',
    'stopifnot(!("bit64" %in% loadedNamespaces()))',
    'value <- UtilsR::stat_pval(payload[["labels"]], add_star_p = c(.001, .2))',
    'stopifnot(identical(value, c(one = "9007199254740993***", two = NA_character_)))',
    'cat("COLD_INTEGER_LABEL_OK\\n")'), script)
  output <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
  expect_true("COLD_INTEGER_LABEL_OK" %in% output)
})

test_that("repeated p-value strings parse only distinct text", {
  values <- c("0.001", "0.0010000000000000001", "0.005", "< 1e-5", "NaN", NA, " 0.50 ")
  x <- rep(values, length.out = 5000L)
  names(x) <- paste0("n", seq_along(x))
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$stat_pval <- fn
  env$.parse_decimal_tokens <- function(text) {
    if (length(text) > length(values)) stop("parsed the repeated strings")
    .parse_decimal_tokens(text)
  }
  environment(fn) <- env
  env$stat_pval <- fn
  for (mode in c("stars", "pvalue", "plain")) {
    expected <- stats::setNames(rep(stat_pval(values, mode = mode), length.out = length(x)), names(x))
    expect_identical(fn(x, mode = mode), expected)
  }
})

test_that("decimal P stars use intervals and correct only tied cutoffs", {
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  calls <- 0L
  env$findInterval <- function(x, ...) {
    calls <<- calls + 1L
    base::findInterval(x, ...)
  }
  environment(fn) <- env
  x <- c("0.01", "0.0100000000000000001", "0.0099999999999999999",
    "0.0500000000000000001", "1e-999", "0", NA)
  map <- c(loose = .05, first = .01, second = .01, zero = 0)
  expect_identical(fn(x, map_signif = map), c("0.010first", "0.010loose", "0.010first",
    "0.050", "<0.001first", "<0.001zero", NA_character_))
  expect_true(calls == 1L, info = "used no interval lookup")
})

test_that("p-value text avoids deduplication for mostly unique samples", {
  x <- sprintf("%.7f", seq_len(4100L) / 5000)
  x[2L] <- x[1L]
  x[5L] <- x[1L]
  names(x) <- sprintf("value-%d", seq_along(x))
  expected <- stat_pval(x, mode = "stars")
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$unique <- function(value, ...) {
    if (length(value) == length(x)) stop("deduplicated mostly unique p-value text")
    base::unique(value, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x, mode = "stars"), expected)
  expect_identical(fn(x[1:5], mode = "stars"), expected[1:5])
})

test_that("literal p-value bounds bypass decimal field width checks", {
  x <- c(lower = ">-1", upper = ">1e308", missing = NA_character_, exact = "0.5")
  out <- stat_pval(x, mode = "plain", digits = 8190L)
  expect_identical(out[1:3], x[1:3])
  expect_identical(unname(nchar(out[4L])), 8192L)
  expect_error(stat_pval(c(">1e308", "-1"), mode = "plain", digits = 8190L), "8192-byte")
})

test_that("rounded-zero p-value detection visits only possible zeros", {
  x <- c(-0, 0, 1e-30, .0004999, .0005, .0005001, NA, seq(.01, 1, length.out = 3000L))
  expected <- stat_pval(x, mode = "stars")
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$grepl <- function(pattern, x, ...) {
    if (identical(pattern, "^-?0\\.0*$") && length(x) > 10L)
      stop("checked ordinary p-values for formatted zero")
    base::grepl(pattern, x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x, mode = "stars"), expected)
  expect_identical(fn(x[1:7], mode = "stars"), expected[1:7])
  expect_identical(fn(c(0, 5e-324, .1), digits = 325L, mode = "pvalue"),
                   stat_pval(c(0, 5e-324, .1), digits = 325L, mode = "pvalue"))
})

test_that("empty significance maps skip threshold indexing", {
  empty <- stats::setNames(numeric(), character())
  x <- c(a = .03, b = NA, c = .9)
  expected <- stat_pval(x, mode = "pvalue")
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$findInterval <- function(...) stop("indexed an empty significance map")
  environment(fn) <- env
  expect_identical(fn(x, mode = "stars", map_signif = empty), expected)
  expect_identical(fn(c("one", NA, "two"), add_star_p = x, map_signif = empty),
                   c("one", NA, "two"))
  expect_identical(fn(c("0.03", "<.01"), mode = "stars", map_signif = empty),
                   c("0.030", "<.01"))
})

test_that("p-value parsing strips operators only from bounded text", {
  x <- c(rep("0.025", 200L), "\u2264 0.05", "> 0.02", NA, "NaN")
  expected <- stat_pval(x, mode = "stars")
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$sub <- function(pattern, replacement, x, ...) {
    if (startsWith(pattern, "^(?:[<>]") && length(x) > 2L)
      stop("processed exact values with the bound operator expression")
    base::sub(pattern, replacement, x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x, mode = "stars"), expected)
  expect_error(fn(c("0.01", "bad"), mode = "pvalue"), "numeric strings")
})

test_that("p-value text diagnoses malformed bytes through input validation", {
  for (encoding in c("UTF-8", "bytes")) {
    bad <- rawToChar(as.raw(255L))
    Encoding(bad) <- encoding
    expect_error(stat_pval(c(".05", bad)), "numeric strings or numeric bounds", class = "rlang_error")
  }
  expect_identical(stat_pval(c("\u2264 .01", ".05", NA)), c("\u2264 .01", "0.050*", NA))
})

test_that("P value tokens use the applicable validation pattern", {
  x <- c("0.002", " <= 0.05 ", "\u22650.2", "0.30", NA, "NaN", "0.08", "<0.001")
  expected <- stat_pval(x)
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$grepl <- function(pattern, x, ...) {
    if (length(x) == length(expected) && startsWith(pattern, "^(?:")) {
      stop("applied both P-value grammars to every value")
    }
    base::grepl(pattern, x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x), expected)
  expect_error(fn(c("0.01", "<bad")), "numeric strings or numeric bounds", fixed = TRUE)
  expect_error(fn(c("0.01", "=")), "numeric strings or numeric bounds", fixed = TRUE)
})

test_that("numeric P-value formatting needs no bound vector", {
  x <- rep(c(.02, NA, .0001, .75), 400L)
  expected <- stat_pval(x)
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$rep <- function(x, ...) {
    if (identical(x, FALSE)) stop("allocated a bound vector for numeric P-values")
    base::rep(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x), expected)
})

test_that("external significance lengths validate before coercing values", {
  x <- rep("row", 1500L)
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$as.character <- function(x, ...) {
    if (length(x) == 1500L) stop("converted all values before checking external P-value length")
    base::as.character(x, ...)
  }
  environment(fn) <- env
  expect_error(fn(x, add_star_p = 0.01), "same length")
  expect_identical(fn(c("entry", NA), add_star_p = c(0.012, .5)), c("entry*", NA_character_))
})

test_that("plain numeric formatting reuses repeated nonzero values", {
  x <- rep(c(0.25, 1.5, -3.2, NA_real_, Inf), 500)
  expected <- stat_pval(x, mode = "plain", digits = 3)
  fn <- stat_pval
  environment(fn) <- list2env(list(sprintf = function(fmt, ...) {
    if (any(lengths(list(...)) > 8L)) stop("repeated plain numeric formatting")
    base::sprintf(fmt, ...)
  }), parent = environment(fn))
  expect_identical(fn(x, mode = "plain", digits = 3), expected)
  signed <- rep(c(0, -0, 0.1), 500)
  expect_identical(stat_pval(signed, mode = "plain"), sprintf("%.2f", signed))
})

test_that("complete decimal tokens skip unneeded NaN recovery scans", {
  text <- c("0.25", "2", "1e308", "Inf")
  fn <- .parse_decimal_tokens
  environment(fn) <- list2env(list(is.nan = function(x) {
    if (!anyNA(x)) stop("unneeded decimal NaN scan")
    base::is.nan(x)
  }), parent = environment(fn))
  expect_identical(fn(text), as.numeric(text))
  expect_identical(fn(c("0.25", NA_character_)), c(0.25, NA_real_))
})

test_that("external P-value stars avoid a complete label mask", {
  x <- stats::setNames(paste0("code", seq_len(800L)), paste0("row", seq_len(800L)))
  p <- rep(c(.001, .02, .9, NA_real_), 200L)
  expected <- stat_pval(x, add_star_p = p)
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$is.na <- function(v) {
    if (identical(v, x)) stop("allocated missing mask for complete external labels")
    base::is.na(v)
  }
  environment(fn) <- env
  expect_identical(fn(x, add_star_p = p), expected)
})

test_that("complete significance star vectors skip missing replacement", {
  p <- seq(0, .8, length.out = 512L)
  args <- list(x = rep("label", length(p)), add_star_p = p)
  expected <- do.call(stat_pval, args)
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$is.na <- function(x) {
    if (identical(substitute(x), quote(pvals)) && identical(x, p))
      stop("rewrote missing slots in complete star input")
    base::is.na(x)
  }
  environment(fn) <- env
  expect_identical(do.call(fn, args), expected)
})

test_that("ordinary P validation needs no vector finite check", {
  p <- c(.0001, .051, .8, NA_real_, NaN)
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$is.finite <- function(x) {
    if (identical(x, p)) stop("allocated a finite flag for every P-value")
    base::is.finite(x)
  }
  environment(fn) <- env
  expect_identical(fn(p), stat_pval(p))
  expect_identical(fn(c(NA_real_, NaN)), c(NA_character_, NA_character_))
  expect_error(fn(c(NA, Inf, .1)), "between 0 and 1")
  expect_error(fn(c(NA, .1, -.01)), "between 0 and 1")
})

test_that("ordinary decimal P-values skip building empty threshold tie groups", {
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$split <- function(x, f, ...) {
    if (identical(substitute(x), quote(tied)) && !length(x))
      stop("grouped an empty set of threshold ties")
    base::split(x, f, ...)
  }
  environment(fn) <- env
  for (x in list(c(".031", ".16", ".07", "3e-4", NA), c(".05", "0.050000000000000000001"))) {
    expect_identical(fn(x), stat_pval(x))
  }
})

test_that("decimal star formatting skips empty missing-symbol writes", {
  fn <- stat_pval
  environment(fn) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (identical(substitute(i), quote(is.na(pvals))) && !any(i))
      stop("replaced empty missing decimal significance symbols")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(fn))
  x <- c(".005", ".05", ".050000000000000001", "0.4", NA_character_, "<0.01")
  expect_identical(fn(x), stat_pval(x))
  expect_identical(fn(c("a", "b"), add_star_p = c(.02, NA)), c("a*", "b"))
})

test_that("sorted significance maps keep their existing order and duplicate precedence", {
  fn <- stat_pval
  map <- c("I" = 0, "first" = .05, "second" = .05, "wide" = .1)
  environment(fn) <- list2env(list(sort = function(x, ...) {
    if (identical(x, map)) stop("sorted an already ordered significance map")
    base::sort(x, ...)
  }), parent = environment(fn))
  x <- c(0, .01, .05, .06, .2, NA)
  for (p in list(x, as.character(x))) {
    expect_identical(fn(p, map_signif = map), stat_pval(p, map_signif = map))
  }
  expect_identical(fn(x, map_signif = rev(map)), stat_pval(x, map_signif = rev(map)))
})

test_that("significance validation uses extrema on complete threshold maps", {
  fn <- .validate_signif_map
  env <- new.env(parent = environment(fn))
  env$is.finite <- function(x) stop("allocated a finiteness mask over the threshold map")
  environment(fn) <- env
  expect_no_error(fn(setNames(seq(0, 1, length.out = 250L), seq_len(250L))))
  expect_no_error(fn(numeric()))
  for (bad in list(c(a = -Inf), c(a = Inf), c(a = -1e-15), c(a = NA_real_),
      c(a = 2), c(a = NaN), c(.1), setNames(.1, NA_character_))) {
    expect_error(fn(bad), "map_signif")
  }
})

test_that("P-value boundary trimming visits both ends in one pass", {
  x <- c(" \t.05 \r\n", "\u00a0.25\u2002", "\t\n", " a\n b ", NA_character_,
         paste0("1", strrep(" ", 4000L), "0\n"))
  expected <- sub("(?<![\\h\\v])[\\h\\v]++\\z", "", sub("^[\\h\\v]+", "", x, perl = TRUE),
                  perl = TRUE)
  fn <- .trim_pvalue_space
  passes <- 0L
  environment(fn) <- list2env(list(sub = function(...) {
    passes <<- passes + 1L
    if (passes > 1L) stop("performed a second P-token whitespace scan")
    base::sub(...)
  }), parent = environment(fn))
  expect_identical(fn(x), expected)
})

test_that("validated ordinary p values do not need an absolute-value copy", {
  fn <- stat_pval
  environment(fn) <- list2env(list(abs = function(x) {
    if (identical(substitute(x), quote(format_x)) && !is.object(x))
      stop("allocated absolute values for validated probabilities")
    base::abs(x)
  }), parent = environment(fn))
  x <- c(-0, .00045, .0005, .00051, .01, .05, .5, 1, NA_real_, NaN)
  for (input in list(x, I(x), c("-0", "<.001", ".007", "0.0005", NA_character_))) {
    for (mode in c("pvalue", "stars")) expect_identical(fn(input, mode = mode), stat_pval(input, mode = mode))
  }
})

test_that("decimal significance maps avoid selecting an unchanged threshold dictionary", {
  map <- setNames(seq(0, 1, length.out = 400L), paste0("s", seq_len(400L)))
  fn <- stat_pval
  environment(fn) <- list2env(list(duplicated = function(x, ...) {
    if (identical(x, map)) stop("subselected a unique significance dictionary")
    base::duplicated(x, ...)
  }), parent = environment(fn))
  x <- c("0.0011", "0.03", "0", "0.05000000000000001", "0.912", NA)
  for (thresholds in list(map, c(map[1L], map))) {
    expect_identical(fn(x, map_signif = thresholds), stat_pval(x, map_signif = thresholds))
  }
})

test_that("significance map bounds need no temporary range vector input", {
  fn <- .validate_signif_map
  environment(fn) <- list2env(list(range = function(...) stop("copied significance thresholds to calculate their range")),
    parent = environment(fn))
  map <- setNames(seq(0, 1, length.out = 1024L), seq_len(1024L))
  expect_identical(fn(map), NULL)
  expect_error(fn(c(map, bad = Inf)), "map_signif")
  expect_error(fn(c(map, bad = -1e-9)), "map_signif")
})

test_that("plain P-value validation avoids rebuilding a numeric range", {
  f <- stat_pval
  environment(f) <- list2env(list(range = function(...) stop("recomputed the range of plain P-value inputs")),
                             parent = environment(f))
  for (x in list(c(a = .01, b = NA_real_, c = .2, d = 1), c(NA_real_, NaN), numeric())) {
    expect_identical(f(x), stat_pval(x))
  }
  expect_error(f(c(.5, -Inf)), "finite P-values")
  expect_error(f("1.1"), "finite P-values")
})

test_that("ordinary P value text skips an empty missing token update", {
  f <- stat_pval
  environment(f) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (is.character(x) && identical(value, NA_character_) && is.logical(i) && !any(i))
      stop("assigned an empty P-value missing token selection")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(f))
  for (x in list(c("<0.001", "0.02", "1"), c("0.02", "NA", "NaN", "0.9"))) {
    expect_identical(f(x), stat_pval(x))
  }
})

test_that("complete exact P-value strings validate the existing vector", {
  x <- c("0.001", ".02", "1", "0", "0.5", "0.00e+00")
  f <- stat_pval
  environment(f) <- list2env(list(which = function(x, ...) {
    if (identical(substitute(x), quote(!is.na(text))) && all(x))
      stop("collected rows for complete exact P-value strings")
    base::which(x, ...)
  }), parent = environment(f))
  for (value in list(x, c(x, NA_character_), c(x, "<0.002", "≥0.005"))) {
    expect_identical(f(value), stat_pval(value))
  }
  expect_error(f(c(x, "broken")), "numeric strings")
})

test_that("P-value star annotations accept expression entries without evaluation", {
  x <- expression(alpha, stop("do not evaluate"), NA_character_)
  names(x) <- c("label", "call", "missing")
  want <- c("alpha**", paste0(as.character(x)[2L], "**"), NA_character_)
  names(want) <- names(x)
  expect_identical(stat_pval(x, add_star_p = rep(.01, 3L)), want)
  expect_identical(stat_pval(expression(), add_star_p = numeric()), character())
})

test_that("identical threshold strings share decimal comparison work", {
  x <- rep(c("0.001", "0.100"), 40L)
  fn <- stat_pval
  environment(fn) <- list2env(list(sub = function(pattern, replacement, x, ...) {
    if (length(x) > 1L &&
        identical(pattern, "[eE].*$") && length(unique(x)) == 1L)
      stop("parsed identical tied P-value decimal text repeatedly")
    base::sub(pattern, replacement, x, ...)
  }), parent = environment(fn))
  expect_identical(fn(x), stat_pval(x))
  x[1:3] <- c("0.001000000000000000001", "0.000999999999999999999", "0.001")
  expect_identical(fn(x), stat_pval(x))
})

test_that("AsIs numeric P-value star selection uses threshold indexing", {
  x <- letters[1:6]
  p <- I(c(.001, .02, NA, NaN, .05, .2))
  f <- stat_pval
  environment(f) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (is.character(x) && length(x) == length(p) && is.logical(i) && value %in% c("*", "**", "***", "."))
      stop("assigned P-value stars separately for each AsIs threshold")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(f))
  expect_identical(f(x, add_star_p = p), stat_pval(x, add_star_p = p))
  expect_identical(f(setNames(x, x), add_star_p = p), stat_pval(setNames(x, x), add_star_p = p))
})

test_that("repeated mixed decimal ties compare one copy of each spelling", {
  x <- rep(c("0.04999999999999999999", "0.050000000000000001", "5e-2"), 110L)
  fn <- stat_pval
  environment(fn) <- list2env(list(sub = function(pattern, replacement, x, ...) {
    if (identical(pattern, "[eE].*$") && length(x) == 330L)
      stop("split decimal mantissas for repeated ties")
    base::sub(pattern, replacement, x, ...)
  }), parent = environment(fn))
  expected <- rep(c("0.050*", "0.050", "0.050*"), 110L)
  expect_identical(fn(x, mode = "stars", map_signif = c("*" = 0.05)), expected)
})

test_that("unbounded P-value text needs no allocated bound flags", {
  x <- c(NA_character_, "0", "1", "0.05", "0.04", "nan")
  x[6L] <- "NaN"
  fn <- stat_pval
  environment(fn) <- list2env(list(rep = function(x, ...) {
    if (identical(x, FALSE)) stop("allocated bound flags for unbounded text")
    base::rep(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(x, mode = "stars"), stat_pval(x, mode = "stars"))
  expect_identical(fn(x, mode = "plain"), stat_pval(x, mode = "plain"))
})

test_that("one significance cut keeps ties together", {
  fn <- stat_pval
  environment(fn) <- list2env(list(split = function(...) {
    stop("split ties for a single P-value threshold")
  }), parent = environment(fn))
  x <- c("0.050000000000000001", "0.05", "5e-2", ".049999999999999999", NA, ">0.1")
  expect_identical(fn(x, mode = "stars", map_signif = c("*" = 0.05)),
                   c("0.050", "0.050*", "0.050*", "0.050*", NA, ">0.1"))
})

test_that("underflowing P-value powers avoid insignificant digit padding", {
  fn <- stat_pval
  environment(fn) <- list2env(list(strrep = function(x, times) {
    if (identical(x, "0") && length(times) == 4L) stop("padded digits for unequal decimal powers")
    base::strrep(x, times)
  }), parent = environment(fn))
  x <- c("1e-400", ".000e-500", "3e-500", "+0", ".1")
  expect_identical(fn(x, mode = "stars", map_signif = c("*" = 0)),
                   c("<0.001", "<0.001*", "<0.001", "<0.001*", "0.100"))
})

test_that("interior decimal P-values do not allocate endpoint flags", {
  x <- c("0.001", "0.0010000000000000001", "0.34", "0.99", "<0.05")
  fn <- stat_pval
  environment(fn) <- list2env(list(`%in%` = function(x, table) {
    if (identical(substitute(x), quote(x_num)) && identical(table, c(0, 1)))
      stop("compared every interior decimal P-value with both endpoints")
    base::`%in%`(x, table)
  }), parent = environment(fn))
  expect_identical(fn(x, mode = "stars"), stat_pval(x, mode = "stars"))
  expect_identical(fn(x, mode = "plain"), stat_pval(x, mode = "plain"))
})

test_that("P-values above the rounding boundary skip candidate flags", {
  f <- stat_pval
  environment(f) <- list2env(list(which = function(x, ...) {
    if (is.call(substitute(x)) && identical(substitute(x)[[2L]], quote(magnitude)))
      stop("looked for rounded zeros in interior P-values")
    base::which(x, ...)
  }), parent = environment(f))
  x <- c(a = .014, b = .121, c = NA_real_)
  expect_identical(f(x, mode = "pvalue"), c(a = "0.014", b = "0.121", c = NA_character_))
  expect_identical(stat_pval(c(0, .00023), mode = "pvalue"), rep("<0.001", 2L))
})

test_that("nonsignificant P-values bypass interval searches", {
  f <- stat_pval
  environment(f) <- list2env(list(findInterval = function(x, ...) {
    if (length(x) && min(x) > .05) stop("searched significance thresholds for nonsignificant values")
    base::findInterval(x, ...)
  }), parent = environment(f))
  levels <- c("*" = 0.05, "**" = 0.01)
  expect_identical(f(c(.1, .9), mode = "stars", map_signif = levels), c("0.100", "0.900"))
  expect_identical(f(c("0.100", "0.900"), mode = "stars", map_signif = levels), c("0.100", "0.900"))
  expect_identical(f(c(0.05, 0.009), mode = "stars", map_signif = levels), c("0.050*", "0.009**"))
})

test_that("empty P-value inputs skip finite-range evaluation", {
  f <- stat_pval
  environment(f) <- list2env(list(min = function(...) {
    if (identical(as.list(substitute(list(...)))[[2L]], quote(p)) && !length(list(...)[[1L]]))
      stop("scanned limits of empty P-values")
    base::min(...)
  }), parent = environment(f))
  expect_identical(f(numeric(), mode = "pvalue"), character())
  expect_identical(f(numeric(), mode = "stars"), character())
  expect_error(f(numeric(), mode = "stars", map_signif = c("*" = Inf)), "map_signif")
})

test_that("small plain P-value vectors bypass duplicate eligibility scans", {
  fn <- stat_pval
  environment(fn) <- list2env(list("==" = function(e1, e2) {
    if (identical(substitute(e1), quote(x_num)) && length(e1) <= 1024L) stop("unnecessary == in stat_pval")
    base::`==`(e1, e2)
  }), parent = environment(fn))
  expect_identical(fn(c(-0, 0, 0.04), mode = "plain"), c("-0.00", "0.00", "0.04"))
  x <- rep(c(-0, 0, .95), 650L)
  expect_identical(fn(x, mode = "plain"), rep(c("-0.00", "0.00", "0.95"), 650L))
})

test_that("missing P-values do not force significance work above all limits", {
  fn <- stat_pval
  environment(fn) <- list2env(list("findInterval" = function(x, vec, ...) {
    if (length(x) > 100L && !any(x < max(vec), na.rm = TRUE)) stop("unnecessary findInterval in stat_pval")
    base::findInterval(x, vec, ...)
  }), parent = environment(fn))
  text <- rep(c("observed", "missing"), 600L)
  expect_identical(fn(text, add_star_p = rep(c(.5, NA), 600L)), text)
  expect_identical(fn(text, add_star_p = rep(NA_real_, length(text))), text)
  expect_identical(fn("cell", add_star_p = .001), "cell***")
})

test_that("decimal star ties drop missing comparisons without a separate mask", {
  fn <- stat_pval
  environment(fn) <- list2env(list("is.na" = function(x) {
    if (identical(substitute(x), quote(pvals)) && !anyNA(x)) stop("unnecessary is.na in stat_pval")
    base::is.na(x)
  }), parent = environment(fn))
  x <- c("0.049999999999999999", "0.050000000000000001", "0.06", NA_character_)
  expect_identical(fn(x), c("0.050*", "0.050.", "0.060.", NA_character_))
  expect_identical(fn("0.05", map_signif = c("!" = 0.05)), "0.050!")
})

test_that("decimal significance rows are indexed once per cutoff", {
  fn <- stat_pval
  calls <- 0L
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(rows)) && identical(substitute(i), quote(above))) calls <<- calls + 1L
    base::"["(x, i, ...)
  }), parent = environment(fn))
  x <- c("0.049999999999999999", "0.050000000000000001")
  expect_identical(fn(x), stat_pval(x))
  expect_identical(calls, 1L)
})

test_that("validated p-value bounds share one presence flag through formatting", {
  fn <- stat_pval
  environment(fn) <- list2env(list("any" = function(..., na.rm = FALSE) {
    if (identical(substitute(list(...))[[2L]], quote(bounded))) stop("unexpected any in stat_pval")
    base::any(..., na.rm = na.rm)
  }), parent = environment(fn))
  x <- rep(c("<=0", "0.01", " 0.5 ", ">=1", NA_character_), 300L)
  for (mode in c("stars", "plain")) expect_identical(fn(x, mode = mode), stat_pval(x, mode = mode))
  expect_error(fn(rep(c("0.1", "<0"), 300L)), "strict bound")
  expect_error(fn(c("<words", "0.5")), "numeric bounds")
})

test_that("decimal significance exponent extraction is limited to scientific spellings", {
  fn <- stat_pval
  environment(fn) <- list2env(list("sub" = function(pattern, replacement, x, ...) {
    if (identical(pattern, "^.*[eE]") && identical(substitute(x), quote(text))) stop("unexpected sub in stat_pval")
    base::sub(pattern, replacement, x, ...)
  }), parent = environment(fn))
  x <- c("0.05", "0.0500000000000000001", "5e-2", "50E-3", "0.0499999999999999999")
  expect_identical(fn(x, digits = 3L), stat_pval(x, digits = 3L))
  result <- fn(x, digits = 3L, mode = "stars")
  expect_identical(result, stat_pval(x, digits = 3L, mode = "stars"))
  expect_identical(endsWith(result, "*"), c(TRUE, FALSE, TRUE, TRUE, TRUE))
})

test_that("large vectors of identical character p values restore output by replication", {
  fn <- stat_pval
  environment(fn) <- list2env(list("match" = function(x, table, ...) {
    if (identical(substitute(table), quote(keys)) && length(table) == 1L && length(x) > 1000L) stop("unexpected match in stat_pval")
    base::match(x, table, ...)
  }), parent = environment(fn))
  x <- stats::setNames(rep("0.0499999", 1100L), paste0("g", 1:1100))
  expect_identical(fn(x), stats::setNames(rep(stat_pval(x[[1L]]), length(x)), names(x)))
  x[1L] <- "<0.01"
  expect_identical(fn(x), stat_pval(x))
})

test_that("one numeric p-value key expands without row remapping", {
  fn <- stat_pval
  environment(fn) <- list2env(list("match" = function(x, table, ...) {
    if (identical(substitute(x), quote(x_num)) && length(table) == 1L && length(x) >= 1024L) stop("unexpected match in stat_pval")
    base::match(x, table, ...)
  }), parent = environment(fn))
  for (v in c(0, 0.05, .85, NA_real_)) {
    x <- stats::setNames(rep(v, 1200L), paste0("cell", 1:1200))
    for (mode in c("plain", "pvalue", "stars")) {
      expect_identical(fn(x, mode = mode), stats::setNames(rep(stat_pval(v, mode = mode), length(x)), names(x)))
    }
  }
})

test_that("plain decimal formatting skips P-value endpoint diagnostics", {
  fn <- stat_pval
  environment(fn) <- list2env(list(which = function(x, ...) {
    if (identical(substitute(x), quote(!is.na(values) & (is.na(x_num) | x_num %in% c(0, 1)))))
      stop("audited P-value endpoints in plain mode")
    base::which(x, ...)
  }), parent = environment(fn))
  x <- c(zero = "0", negzero = "-0", one = "1", exponent = "5e-400",
         beyond = "2", bound = " >1 ", long = paste0("1", strrep("0", 8000L), "e-8000"),
         absent = NA_character_)
  expect_identical(fn(x, mode = "plain"),
                   setNames(c("0.00", "-0.00", "1.00", "0.00", "2.00", ">1",
                              "1.00", NA_character_), names(x)))
  expect_error(stat_pval(x["beyond"]), "between 0 and 1")
  expect_error(stat_pval(">1"), "strict bound")
})

test_that("bound detection collects indices without a full logical mask", {
  x <- c(missing = NA_character_, left = " \u2264 0.05", exact = ".01",
         another = NA_character_, right = " >=1 ", tiny = "0.0002")
  fn <- stat_pval
  environment(fn) <- list2env(list(grepl = function(pattern, x, ...) {
    if (identical(pattern, "^[<>\u2264\u2265]")) stop("reserved a full bound mask")
    base::grepl(pattern, x, ...)
  }), parent = environment(fn))
  expect_identical(fn(x), stat_pval(x))
  expect_identical(fn(x[c(1L, 3L, 4L, 6L)]), stat_pval(x[c(1L, 3L, 4L, 6L)]))
  expect_identical(fn(x[-c(1L, 4L)]), stat_pval(x[-c(1L, 4L)]))
  expect_identical(fn(x[c(2L, 5L)]), stat_pval(x[c(2L, 5L)]))
  expect_error(fn(c(x, "<words")), "numeric strings or numeric bounds")
})

test_that("sparse p-value bounds are tracked by position without a second row mask", {
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$rep <- function(x, ...) {
    if (identical(x, FALSE)) stop("allocated a separate full-length bounds mask")
    base::rep(x, ...)
  }
  environment(fn) <- env
  x <- c(exact = "0.05", missing = NA_character_, bound = " > 0.10 ", zero = "0",
         token = "NaN", bound2 = "\u2264 1", plain = "0.20")
  expect_identical(fn(x), stats::setNames(c("0.050*", NA, "> 0.10", "<0.001***",
    NA, "\u2264 1", "0.200"), names(x)))
  expect_error(fn(c(NA_character_, " > 1 ", "<= 0")), "strict bound")
})

test_that("stat_pval does not allocate a vector of empty significance labels", {
  fn <- stat_pval
  env <- new.env(parent = environment(fn))
  env$paste0 <- function(...) {
    args <- list(...)
    if (length(args) != 2L || !identical(args[[2L]], ""))
      stop("pasted a vector of empty significance labels")
    base::paste0(...)
  }
  environment(fn) <- env
  x <- c(a = "ER", b = NA_character_, c = "PR")
  expect_identical(fn(x, add_star_p = c(.2, NA, .5)), x)
  expect_identical(fn(c(a = .2, b = NA, c = .5)), c(a = "0.200", b = NA, c = "0.500"))
  expect_identical(fn(x, add_star_p = c(.001, .001, .01), map_signif = numeric()), x)
  latin1 <- iconv("caf\u00e9", to = "latin1")
  Encoding(latin1) <- "latin1"
  expect_identical(Encoding(fn(latin1, add_star_p = .2)), Encoding(paste0(latin1, "")))
  expect_identical(fn(c(a = .001, b = .02), map_signif = numeric()), c(a = "0.001", b = "0.020"))
  expect_error(fn(.2, map_signif = c(star = Inf)), "map_signif")
})
