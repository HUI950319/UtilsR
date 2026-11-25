test_that("single-index group labels preserve supplied names and exact indices", {
  x <- factor(rep(letters, each = 3L), levels = letters)
  ids <- c(26L, 2L, 10L, 1L)
  groups <- setNames(as.list(ids), c("", "keep this", NA_character_, ""))
  names <- c("grp_26", "keep this", "grp_10", "grp_1")
  expect_identical(fct_to_group(x, groups, name_prefix = "grp_", name_sep = "+"),
                   fct_to_group(x, setNames(as.list(ids), names)))
  expect_identical(levels(fct_to_group(x, as.list(ids)))[seq_along(ids)],
                   paste0("g", ids))
})
