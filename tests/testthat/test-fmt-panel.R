panel_test_plot <- function() {
  ggplot2::ggplot(data.frame(x = 1:5, y = c(1, 4, 2, 5, 3)),
                  ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::theme_gray()
}

panel_test_grid_grobs <- function(g) {
  result <- if (inherits(g, "polyline") && grepl("^panel.grid\\.", g$name)) {
    data.frame(element = sub("^panel.grid\\.((major|minor)\\.[xy]).*", "\\1", g$name),
               colour = g$gp$col, linewidth = g$gp$lwd, linetype = g$gp$lty)
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  do.call(rbind, c(list(result), lapply(children, panel_test_grid_grobs)))
}

panel_test_grids <- function(p) {
  panel_test_grid_grobs(ggplot2::ggplotGrob(p))
}

test_that("panel grid modes override axis-specific retained and hidden grids", {
  p <- panel_test_plot() + ggplot2::theme(
    panel.grid.major.x = ggplot2::element_line(colour = "blue"),
    panel.grid.minor.x = ggplot2::element_line(colour = "blue"))
  expected <- list(none = character(), major = c("major.x", "major.y"),
                   minor = c("minor.x", "minor.y"),
                   both = c("major.x", "major.y", "minor.x", "minor.y"),
                   x = "major.x", y = "major.y")
  for (mode in names(expected)) {
    grids <- panel_test_grids(fmt_panel(p, grid = mode))
    expect_setequal(grids$element %||% character(), expected[[mode]])
  }
  grids <- panel_test_grids(fmt_panel(p, grid = "both", grid_color = "red",
                                    grid_linewidth = 0.8, grid_linetype = "dashed"))
  expect_equal(grids$colour, rep("red", 4))
  expect_equal(grids$linewidth, rep(0.8 * 72.27 / 25.4, 4))
  expect_equal(grids$linetype, rep("dashed", 4))
})

test_that("panel grid mode switches restore enabled lines without new styling", {
  expected <- list(none = character(), major = c("major.x", "major.y"),
                   minor = c("minor.x", "minor.y"),
                   both = c("major.x", "major.y", "minor.x", "minor.y"),
                   x = "major.x", y = "major.y")
  p <- panel_test_plot()
  for (first in names(expected)) {
    for (second in names(expected)) {
      q <- fmt_panel(fmt_panel(p, grid = first), grid = second)
      expect_setequal(panel_test_grids(q)$element %||% character(), expected[[second]])
    }
  }
  for (theme in list(ggplot2::theme_classic(), ggplot2::theme_void())) {
    expect_setequal(panel_test_grids(fmt_panel(p + theme, grid = "both"))$element,
                    expected$both)
  }
  styled <- p + ggplot2::theme(
    panel.grid = ggplot2::element_line(colour = "purple", linewidth = 0.7),
    panel.grid.major.x = ggplot2::element_blank())
  before <- serialize(styled, NULL)
  grids <- panel_test_grids(fmt_panel(styled, grid = "x"))
  expect_equal(grids$colour, "purple")
  expect_equal(grids$linewidth, 0.7 * 72.27 / 25.4)
  expect_identical(serialize(styled, NULL), before)
})
