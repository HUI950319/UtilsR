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
