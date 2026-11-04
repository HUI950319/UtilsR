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

test_that("plt_cat keeps the resolved NA colour for either palette path", {
  old_palette <- grDevices::palette()
  withr::defer(grDevices::palette(old_palette))
  grDevices::palette(c("black", "#123456"))
  d <- data.frame(g = c("A", NA_character_, "B", "A"))

  for (palette in list(NULL, c(A = "red", B = "blue"))) {
    p <- suppressMessages(plt_cat(d, "g", palette = palette, NA_stat = TRUE, NA_color = "2"))
    expect_true("#123456FF" %in% plt_cat_fills(p))
    expect_error(plt_cat(d, "g", palette = palette, NA_stat = TRUE, NA_color = "bogus_colour"),
                 "NA_color.*invalid colours")
  }
  expect_no_error(suppressMessages(plt_cat(d, "g", NA_stat = FALSE, NA_color = "bogus_colour")))
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
  expect_identical(grDevices::col2rgb(.resolve_color(2, n = 2)),
                   grDevices::col2rgb(rep(2, 2)))
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

test_that(".resolve_color fixes numeric indices to the current base palette", {
  old_palette <- grDevices::palette()
  withr::defer(grDevices::palette(old_palette))
  grDevices::palette(c("black", "#123456"))
  for (value in list(2, 2.8, "2", "2.8", "1e2", factor("2"))) {
    expect_identical(.resolve_color(value, n = 2L), rep("#123456FF", 2L))
  }
  mixed <- c("red", "2", NA_character_, "transparent", "#FF000080")
  expect_identical(.resolve_color(mixed),
                   c("red", "#123456FF", NA_character_, "transparent", "#FF000080"))
  expect_identical(.resolve_color(NULL, default = 2), "#123456FF")
  resolved <- .resolve_color(2)
  grDevices::palette(c("black", "#ABCDEF"))
  expect_identical(ggplot2::alpha(resolved, 1), "#123456FF")
  expect_identical(.resolve_color(2), "#ABCDEFFF")
})

test_that("numeric colours keep their precision and cannot overflow the native index", {
  old_palette <- grDevices::palette()
  withr::defer(grDevices::palette(old_palette))
  grDevices::palette(c("black", "red", "blue", "green"))

  expect_identical(.resolve_color(c(2 - .Machine$double.eps, 2.8, 0.5, NA_real_)),
                   c("#000000FF", "#FF0000FF", "#FFFFFF00", NA_character_))
  expect_identical(.resolve_color(c("0x2", "2e0", "2147483647")),
                   c("#FF0000FF", "#FF0000FF", "#0000FFFF"))
  for (value in list(2147483648, Inf, NaN, "2147483648", "1e309")) {
    expect_error(.resolve_color(value), "numeric colour index")
  }
  err <- tryCatch(.resolve_color(c("1e309", "bad_colour_xyz")), error = identity)
  expect_match(conditionMessage(err), "1e309")
  expect_match(conditionMessage(err), "bad_colour_xyz")
  expect_error(.resolve_color("2 "), "valid colour")
})

test_that("numeric colour strings are parsed before reaching the native colour lookup", {
  col2rgb <- grDevices::col2rgb
  token <- "2147483647999.99988080000e-3"
  testthat::local_mocked_bindings(
    col2rgb = function(col, ...) {
      if (any(col == token, na.rm = TRUE)) stop("Unchecked numeric string reached col2rgb")
      col2rgb(col, ...)
    },
    .package = "grDevices"
  )

  expect_identical(.resolve_color(token), .resolve_color(as.numeric(token)))
  expect_identical(.resolve_color(c("2e0", "0x1p1", "0x.8p2", "00", "0.5")),
                   .resolve_color(c(2, 2, 2, 0.5, 0.5)))
  expect_error(.resolve_color("0"), "valid colour")
  expect_error(.resolve_color("2\n"), "valid colour")
})

test_that("named plot colours are validated as literals before drawing", {
  d <- data.frame(g = factor(rep(c("A", "B"), each = 3)),
                  h = factor(rep(c("x", "y"), 3)), y = 1:6)
  expect_error(plt_cat(d, "g", palette = c(A = "bad_colour_xyz", B = "blue")),
               "palette.*invalid colours")
  expect_error(plt_con(d, "y", group.by = "g", palette = c(A = "bad_colour_xyz", B = "blue")),
               "palette.*invalid colours")
  expect_error(plt_dist(d, c("g", "h"), type = "bar", color = c(x = "bad_colour_xyz", y = "blue")),
               "color.*invalid colours")
  single <- droplevels(d[d$g == "A", ])
  expect_error(plt_cat(single, "g", palette = c(A = "lancet")), "palette.*invalid colours")
  old_palette <- grDevices::palette()
  withr::defer(grDevices::palette(old_palette))
  grDevices::palette(c("black", "#123456"))
  p <- suppressMessages(plt_cat(d, "g", palette = c(B = "blue", A = "2")))
  expect_identical(unname(plt_cat_fills(p)), c("#123456FF", "blue"))
})

test_that("internal empty named colours preserve missing-only split groups", {
  d <- data.frame(value = 1:6, group = factor(rep(NA_character_, 6L), exclude = NULL),
                  batch = rep(c("S1", "S2"), each = 3L))
  out <- suppressMessages(plt_con(d, "value", "group", split.by = "batch",
                                  type = "bar", combine = FALSE))
  expect_named(out, c("S1", "S2"))
  expect_equal(vapply(out, function(p) nrow(p$data), 1L), c(S1 = 3L, S2 = 3L))
  expect_equal(ggplot2::ggplot_build(out[[1L]])$data[[2L]]$y, 2)
})

test_that("a single named rank colour is a literal after subsetting groups", {
  d <- data.frame(id = rep(letters[1:3], 2L), value = c(1:3, 2:4),
                  group = "A", method = rep(c("M1", "M2"), each = 3L))
  invisible(capture.output(expect_error(
    PlotRankCor(d, "id", "value", "group", "method", palette = c(A = "lancet", B = "red")),
    "palette.*invalid colours"
  )))
})

test_that("a single named alluvial colour is a literal after subsetting groups", {
  skip_if_not_installed("ggalluvial")
  d <- data.frame(x = rep(c("X", "Y"), each = 2L), g = "A")
  expect_error(plt_alluvial(d, "x", "g", color = c(A = "lancet", B = "red")),
               "color.*invalid colours")
  p <- suppressMessages(plt_alluvial(d, "x", "g", color = c(B = "red", A = "blue")))
  expect_identical(ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")$map("A"), "blue")
})

test_that("named plot colours reject matrices before matching categories", {
  d <- data.frame(x = rep(c("X", "Y"), each = 2L), g = factor(rep(c("A", "B"), 2L)), y = 1:4)
  colours <- matrix(c("red", "blue"), nrow = 1L)
  names(colours) <- c("A", "B")
  expect_error(plt_cat(d, "g", palette = colours), "one-dimensional")
  expect_error(plt_con(d, "y", "g", type = "bar", palette = colours), "one-dimensional")
  expect_error(plt_dist(d, c("x", "g"), type = "bar", color = colours), "one-dimensional")
})

test_that("distribution and alluvial colours match an observed empty category", {
  skip_if_not_installed("ggalluvial")
  d <- data.frame(x = rep(c("X", "Y"), each = 2L), g = factor(rep(c("", "A"), 2L)))
  colours <- setNames(c("blue", "red"), c("A", ""))
  plots <- suppressMessages(list(
    plt_alluvial(d, "x", "g", color = colours),
    plt_dist(d, c("x", "g"), type = "alluvial", color = colours),
    plt_dist(d, c("x", "g"), type = "bar", color = colours)
  ))
  for (p in plots) {
    scale <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
    expect_identical(grDevices::col2rgb(scale$map(c("", "A"))),
                     grDevices::col2rgb(c("red", "blue")))
  }
  expect_error(plt_alluvial(d, "x", "g", color = c(A = "blue")), "cover every observed group")
})
