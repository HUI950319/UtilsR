# `.resolve_color()` and the plot functions on top of it. RegR imports the helper,
# so these tests cover its plot functions too.

test_that(".resolve_color is exported for RegR", {
  expect_true(".resolve_color" %in% getNamespaceExports("UtilsR"))
  expect_true("export(.resolve_color)" %in%
                readLines(system.file("NAMESPACE", package = "UtilsR")))
})

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

test_that(".resolve_color warns when groups would share a colour", {
  expect_warning(.resolve_color(c("red", "blue"), n = 3), "repeat")
  expect_warning(.resolve_color(NULL, n = 16), "repeat")
  expect_warning(.resolve_color(NULL, n = 4, default = c("red", "blue", "green")), "repeat")

  # One colour for all, enough colours, or a palette that interpolates.
  expect_no_warning(.resolve_color("red", n = 3))
  expect_no_warning(.resolve_color(NULL, n = 3, default = "red"))
  expect_no_warning(.resolve_color(NULL, n = 15))
  expect_no_warning(.resolve_color(c("red", "blue"), n = 2))
  expect_no_warning(.resolve_color(c("red", "blue", "green"), n = 2))
  expect_no_warning(.resolve_color("lancet", n = 16))
  expect_no_warning(.resolve_color(c("red", "blue")))

  # The colours themselves stay as they were.
  expect_identical(suppressWarnings(.resolve_color(c("red", "blue"), n = 3)),
                   c("red", "blue", "red"))
})

test_that(".resolve_color validates n before choosing a colour branch", {
  bad_n <- list(1.8, "2", TRUE, NA_real_, numeric(), c(1L, 2L),
                factor("2"), matrix(2L), 2 + 0i, Inf, -1)
  for (palette in list(NULL, "red", "lancet")) {
    for (n in bad_n) {
      expect_error(.resolve_color(palette, n = n), "n.*plain.*whole number")
    }
    expect_identical(.resolve_color(palette, n = 0L), character())
    expect_length(.resolve_color(palette, n = 2), 2L)
  }
  outer_plot <- function(n) .resolve_color("lancet", n = n)
  err <- tryCatch(outer_plot("2"), error = identity)
  expect_identical(conditionCall(err), quote(outer_plot("2")))
})

test_that(".resolve_color validates defaults as literal colour vectors", {
  for (bad in list("bad_colour_xyz", c("red", "bad_colour_xyz"),
                   character(), NULL, list("red"), "lancet")) {
    expect_error(.resolve_color(NULL, n = 2L, default = bad), "default")
  }
  expect_identical(.resolve_color(NULL, default = c(A = "red", B = "blue")),
                   c("red", "blue"))
  expect_identical(.resolve_color(NULL, n = 2L, default = NA),
                   c(NA_character_, NA_character_))
  expect_identical(.resolve_color("red", default = stop("unused")), "red")
  expect_error(.resolve_color(NULL, n = 0L, default = "bad_colour_xyz"), "default")
})

test_that(".resolve_color handles long colour vectors and identifies all bad values", {
  colours <- rep(c("#F00", "RED", "light blue", "transparent", NA_character_), 300L)
  expect_identical(.resolve_color(colours, n = length(colours)), colours)
  bad <- rep(c("red", "bad_colour_one", "bad_colour_two", NA_character_), 300L)
  err <- tryCatch(.resolve_color(bad), error = identity)
  expect_match(conditionMessage(err), "bad_colour_one")
  expect_match(conditionMessage(err), "bad_colour_two")
  expect_length(gregexpr("bad_colour_one", conditionMessage(err), fixed = TRUE)[[1L]], 1L)
})

test_that(".resolve_color handles factors and rejects ambiguous storage", {
  expect_identical(.resolve_color(factor("lancet"), n = 2L), pal_get("lancet", n = 2L))
  expect_identical(.resolve_color(ordered(c("red", "blue"))), c("red", "blue"))
  bad <- list(matrix(c("red", "blue"), 1L), array("red", c(1L, 1L, 1L)),
              as.raw(1:2), 1 + 2i, TRUE,
              structure(c(1, 2), class = "integer64"),
              structure(c(1, 2), class = "haven_labelled_spss"),
              as.Date("2026-01-01"), as.difftime(2, units = "days"))
  for (value in bad) {
    expect_error(.resolve_color(value), "plain.*colour.*vector|one-dimensional")
    expect_error(.resolve_color(NULL, default = value), "plain.*colour.*vector|one-dimensional")
  }
})
