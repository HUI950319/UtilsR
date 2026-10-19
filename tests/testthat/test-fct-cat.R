test_that("recoding into an unmatched level keeps every observation", {
  x <- factor(c("a", "b", "c", NA), levels = letters[1:4])
  expected <- factor(c("b", "b", "c", NA), levels = c("b", "c"))

  expect_identical(fct_cat(x, b = "a"), expected)
  expect_identical(fct_cat(x, b = 1L), expected)
  expect_identical(fct_cat(x, groups = list(b = 1L)), expected)
  expect_identical(fct_to_group(x, list(b = 1L)), expected)
  expect_identical(levels(x), letters[1:4])
  expect_identical(as.character(x), c("a", "b", "c", NA_character_))
})

test_that("recoding retains group-first ordering and drops unused levels", {
  x <- factor(c("a", "b", "c"), levels = letters[1:4])
  expect_identical(fct_cat(x, Z = "c"),
                   factor(c("a", "b", "Z"), levels = c("Z", "a", "b")))
})

test_that("binary reference labels cannot collide with the other group", {
  x <- factor(c("Oth", "a"), levels = c("Oth", "a"))
  expect_error(fct_cat(x, binary_ref = 1L), "conflicts with.*Oth")
  expect_identical(fct_cat(x, binary_ref = 2L),
                   factor(c("Oth", "a"), levels = c("a", "Oth")))
  expect_identical(fct_cat(factor("Oth"), binary_ref = 1L), factor("Oth"))
})

test_that("dots cannot be silently ignored by another factor mode", {
  x <- factor(letters[1:3])
  expect_error(fct_cat(x, A = "a", reverse = TRUE), "Only one mode")
  expect_error(fct_cat(x, "b", binary_ref = 1L), "Only one mode")
  expect_error(fct_cat(x, A = "a", groups = list(B = 2L)), "Only one mode")
  expect_error(fct_cat(x, A = "a", new_labels = LETTERS[1:3]), "Only one mode")
  expect_error(fct_cat(x, stop("dots must not be evaluated"), reverse = TRUE),
               "Only one mode")
  expect_identical(fct_cat(x, reverse = FALSE), x)
  expect_identical(fct_cat(x, A = "a", reverse = FALSE),
                   factor(c("A", "b", "c")))
})

test_that("factor modes validate logical flags and finite integer indices", {
  x <- factor(letters[1:3])
  for (flag in list(NA, NULL, 1, c(TRUE, FALSE))) {
    expect_error(fct_cat(x, reverse = flag), "single.*logical")
  }
  for (idx in list(NA_integer_, NaN, Inf, -Inf, 1.5, 1 + 1i)) {
    expect_no_warning(expect_error(fct_cat(x, binary_ref = idx), "finite integer"))
    expect_no_warning(expect_error(fct_cat(x, groups = list(A = idx)), "finite integer"))
    expect_no_warning(expect_error(fct_cat(x, idx), "finite integer"))
  }
  expect_no_warning(expect_error(fct_cat(x, 1e20), "between"))
  expect_error(fct_cat(x, "a", "a"), "duplicated")
  expect_error(fct_cat(x, groups = setNames(list(1L), "")), "non-empty names")
  expect_error(fct_cat(x, groups = setNames(list(1L), NA_character_)), "non-empty names")
})

test_that("recoding resolves each group's index or label before checking it", {
  x <- factor(c("a", "b", "c", NA))
  expect_identical(fct_cat(x, A = 1L, B = "b"),
                   factor(c("A", "B", "c", NA)))
  expect_error(fct_cat(x, A = "typo"), "not found.*typo")
  expect_error(fct_cat(x, A = 1L, B = "a"), "non-unique")
  expect_error(fct_cat(x, A = list("a")), "character.*integer")
  expect_identical(fct_cat(x, groups = list(A = 1L, A = 2L)),
                   factor(c("A", "A", "c", NA)))
})
