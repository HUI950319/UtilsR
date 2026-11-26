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

test_that("many plain singleton groups validate their bounds as one vector", {
  x <- factor(rep(1:2000, each = 2L))
  groups <- rep(list(1L), 1200L)
  groups <- setNames(as.list(seq_along(groups)), paste0("tag", seq_along(groups)))
  expected <- fct_cat(x, groups = groups)
  f <- fct_to_group
  validate <- .check_integer_index
  calls <- 0L
  environment(f) <- list2env(list(.check_integer_index = function(...) {
    calls <<- calls + 1L
    validate(...)
  }), parent = environment(f))
  expect_identical(f(x, groups), expected)
  expect_identical(calls, 1L)
  groups[[300L]] <- 90000L
  expect_error(f(x, groups), "g_lis.*between")
})
