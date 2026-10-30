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

test_that(".resolve_color repeats a single literal colour as given", {
  expect_identical(.resolve_color("#FF000080", n = 2), rep("#FF000080", 2))
  expect_identical(.resolve_color("red", n = 2), c("red", "red"))
  expect_identical(.resolve_color("#FF000080"), "#FF000080")

  # A registered name still goes through the palette, in full or sized.
  expect_identical(.resolve_color("Reds", n = 2), UtilsR::pal_get("Reds", n = 2))
  expect_identical(.resolve_color("lancet"), UtilsR::pal_get("lancet"))
})

test_that(".resolve_color takes every colour R draws without a hint", {
  for (colour in c("transparent", "light blue", " red", "RED", "#F00")) {
    expect_no_message(.resolve_color(colour, n = 2))
  }
})

test_that(".resolve_color rejects what cannot be drawn", {
  # A near palette name is suggested, whatever the case.
  expect_error(.resolve_color("lanct", n = 2), "Did you mean.*lancet")
  expect_error(.resolve_color("LANCET"), "Did you mean.*lancet")
  expect_error(.resolve_color("notacolor_xyz", n = 2), "neither a registered palette")
  expect_error(.resolve_color("#GGGGGG", n = 2), "neither a registered palette")
  expect_error(.resolve_color(""), "neither a registered palette")

  # A vector holds colours only, and names the bad ones.
  expect_error(.resolve_color(c("lancet", "Reds")), "Not a valid colour")
  expect_error(.resolve_color(c("red", "#GGGGGG"), n = 2), "GGGGGG")

  expect_error(.resolve_color(character(0), n = 2), "non-empty")
  expect_error(.resolve_color(UtilsR::pal_heat, n = 2), "non-empty")
  expect_error(.resolve_color(function(n) "red", n = 2), "non-empty")

  # The error names the function the user called.
  outer_plot <- function(color) .resolve_color(color)
  err <- tryCatch(outer_plot("notacolor_xyz"), error = function(e) e)
  expect_identical(deparse(conditionCall(err))[[1L]], "outer_plot(\"notacolor_xyz\")")
})

test_that(".resolve_color keeps the inputs R can draw", {
  expect_identical(.resolve_color(c("red", "#0000FF")), c("red", "#0000FF"))
  expect_identical(.resolve_color(c(a = "red", b = "blue")), c("red", "blue"))
  expect_identical(.resolve_color(factor("red"), n = 2), c("red", "red"))
  expect_identical(.resolve_color(NA, n = 2), c(NA_character_, NA_character_))
  expect_identical(.resolve_color(2, n = 2), c("2", "2"))
  expect_identical(.resolve_color(UtilsR::pal_heat$blue_red, n = 2),
                   UtilsR::pal_heat$blue_red[1:2])
})
