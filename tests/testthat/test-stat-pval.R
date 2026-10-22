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
