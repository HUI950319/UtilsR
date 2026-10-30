# `.resolve_color()` and the plot functions on top of it. RegR keeps a mirrored
# copy of the helper, tested in its own test-resolve-color.R.

plt_cat_fills <- function(p) {
  ld <- ggplot2::layer_data(p, 1L)
  fills <- unique(ld[c("group", "fill")])
  stats::setNames(fills$fill, fills$group)
}

test_that("plt_cat maps a named palette by level", {
  d <- data.frame(g = factor(rep(c("A", "B"), c(30, 20))))

  named <- plt_cat(d, stat.by = "g", palette = c(B = "blue", A = "red"))
  expect_identical(plt_cat_fills(named), c(`1` = "red", `2` = "blue"))

  # Extra names are ignored, and an unnamed palette still goes by position.
  extra <- plt_cat(d, stat.by = "g", palette = c(Z = "green", B = "blue", A = "red"))
  expect_identical(plt_cat_fills(extra), c(`1` = "red", `2` = "blue"))
  unnamed <- plt_cat(d, stat.by = "g", palette = c("blue", "red"))
  expect_identical(plt_cat_fills(unnamed), c(`1` = "blue", `2` = "red"))

  expect_error(plt_cat(d, stat.by = "g", palette = c(A = "red")),
               "Named .*palette.* must contain each level")
})

test_that("plt_cat gives a named palette's missing NA level the NA colour", {
  d <- data.frame(g = factor(c(rep("A", 5), rep("B", 3), NA)))
  p <- plt_cat(d, stat.by = "g", palette = c(B = "blue", A = "red"),
               NA_stat = TRUE, NA_color = "grey50")
  expect_identical(unname(plt_cat_fills(p)), c("red", "blue", "grey50"))
})

test_that("plt_cat keeps a level's colour in a split panel without other levels", {
  d <- data.frame(g = factor(c("B", "A", "B", "C")),
                  s = factor(c("x", "y", "y", "y")))
  p <- plt_cat(d, stat.by = "g", split.by = "s",
               palette = c("red", "blue", "green"))
  # Panel x holds only B, the second level.
  expect_identical(unname(plt_cat_fills(p[[1L]])), "blue")
  expect_identical(unname(plt_cat_fills(p[[2L]])), c("red", "blue", "green"))
})
