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

test_that("backgrounds support categorical expressions and layer data", {
  p <- bg_plot()
  character_plot <- p
  character_plot$data$category <- as.character(character_plot$data$category)
  expect_equal(bg_fills(fmt_bg(character_plot, palcolor = bg_colors)), unname(bg_colors))
  logical_plot <- ggplot2::ggplot(data.frame(category = c(TRUE, FALSE), value = 1:2),
                                  ggplot2::aes(category, value)) + ggplot2::geom_point()
  expect_equal(length(bg_fills(fmt_bg(logical_plot))), 2L)
  expression_plot <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot()
  expect_length(bg_fills(fmt_bg(expression_plot)), 3L)
  pronoun_plot <- ggplot2::ggplot(p$data, ggplot2::aes(.data[["category"]], value)) +
    ggplot2::geom_point()
  expect_equal(bg_fills(fmt_bg(pronoun_plot, palcolor = bg_colors)), unname(bg_colors))
  for (layer_plot in list(
    ggplot2::ggplot(p$data) + ggplot2::geom_point(ggplot2::aes(category, value)),
    ggplot2::ggplot(mapping = ggplot2::aes(category, value)) + ggplot2::geom_point(data = p$data),
    ggplot2::ggplot() + ggplot2::geom_point(data = p$data, ggplot2::aes(category, value)))) {
    before <- ggplot2::ggplot_build(layer_plot)$data
    q <- fmt_bg(layer_plot, palcolor = bg_colors)
    expect_equal(bg_fills(q), unname(bg_colors))
    expect_identical(ggplot2::ggplot_build(q)$data[-1], before)
    expect_length(layer_plot$layers, 1L)
  }
  continuous <- ggplot2::ggplot(mtcars, ggplot2::aes(cyl, mpg)) + ggplot2::geom_point()
  expect_warning(q <- fmt_bg(continuous), "categorical")
  expect_identical(q, continuous)
})
