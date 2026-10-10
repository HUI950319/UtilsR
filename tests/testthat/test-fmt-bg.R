bg_plot <- function() {
  ggplot2::ggplot(data.frame(category = factor(c("A", "B", "C")),
                              value = c(2, 5, 3)),
                   ggplot2::aes(category, value)) + ggplot2::geom_point()
}

bg_colors <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")

bg_fills <- function(plot) {
  fills <- ggplot2::ggplot_build(plot)$data[[1]]$fill
  unname(grDevices::rgb(t(grDevices::col2rgb(fills)), maxColorValue = 255))
}

test_that("manual background colors override palettes without an optional dependency", {
  p <- bg_plot()
  expect_equal(bg_fills(fmt_bg(p, palcolor = bg_colors)), unname(bg_colors))
  expect_equal(bg_fills(fmt_bg(p, palcolor = unname(bg_colors))), unname(bg_colors))
  expect_equal(bg_fills(fmt_bg(p, palette = "invalid", palcolor = bg_colors)),
                 unname(bg_colors))
  expect_equal(bg_fills(fmt_bg(p, palcolor = "purple")), rep("#A020F0", 3))
  expect_length(p$layers, 1L)
})

test_that("background palette errors remain visible and defaults are retained", {
  p <- bg_plot()
  default <- unname(grDevices::rainbow(3))
  expect_equal(bg_fills(fmt_bg(p)), default)
  expect_equal(bg_fills(fmt_bg(p, palcolor = c(A = "black"))),
                 c("#000000", default[-1]))
  if (requireNamespace("plotthis", quietly = TRUE)) {
    expect_error(fmt_bg(p, palette = "invalid"), "palette|Palette")
    expected <- plotthis::palette_this(c("A", "B", "C"), palette = "Paired")
    expect_equal(bg_fills(fmt_bg(p, palette = "Paired")), unname(expected))
  }
  for (colors in list(character(), 1, NA_character_, "invalid-color",
                      c(A = "red", A = "blue"), stats::setNames("red", ""))) {
    expect_error(fmt_bg(p, palcolor = colors), "palcolor")
  }
})
