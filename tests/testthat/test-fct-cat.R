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
