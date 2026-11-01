scatter_main_points <- function(grob) {
  if (inherits(grob, "points") && grepl("geom_point", grob$name)) {
    return(length(grob$x))
  }
  children <- c(grob$grobs, as.list(grob$children))
  sum(vapply(children, scatter_main_points, numeric(1L)))
}

test_that("PlotScatter1 requires explicit mappings beyond twelve groups", {
  data <- data.frame(x = 1:26, y = rep(1:2, 13), g = rep(letters[1:13], each = 2))
  draw <- function(...) PlotScatter1(data, "x", "y", "g", show_ellipse = FALSE,
                                     box_jitter = FALSE, ...)
  expect_error(draw(), "12.*colors.*shapes")
  expect_error(draw(colors = grDevices::hcl.colors(13)), "12.*shapes")
  expect_error(draw(shapes = rep(16, 13)), "12.*colors")
  p <- draw(colors = grDevices::hcl.colors(13), shapes = rep(16, 13))
  expect_equal(scatter_main_points(attr(p, "grobs")$full), 26)
  recycled <- draw(colors = "red", shapes = 16)
  expect_equal(scatter_main_points(attr(recycled, "grobs")$full), 26)
  boundary <- PlotScatter1(data[1:24, ], "x", "y", "g", show_ellipse = FALSE,
                           box_jitter = FALSE)
  expect_equal(scatter_main_points(attr(boundary, "grobs")$full), 24)
})

test_that("PlotScatter2 requires explicit mappings beyond its default capacities", {
  data <- data.frame(x = 1:26, y = rep(1:2, 13), g = rep(letters[1:13], each = 2))
  expect_error(PlotScatter2(data, "x", "y", "g"), "12.*colors")
  p <- PlotScatter2(data, "x", "y", "g", colors = grDevices::hcl.colors(13))
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(nrow(points), 26L)
  expect_false(anyNA(points$colour))

  data <- data.frame(x = 1:14, y = rep(1:2, 7), g = "a",
                     h = rep(letters[1:7], each = 2))
  draw <- function(...) PlotScatter2(data, "x", "y", "g", group2 = "h", ...)
  shapes <- stats::setNames(rep(16, 7), letters[1:7])
  fills <- stats::setNames(grDevices::hcl.colors(7), letters[1:7])
  expect_error(draw(), "6.*shapes.*fill_colors_shape")
  expect_error(draw(shapes = shapes), "6.*fill_colors_shape")
  expect_error(draw(fill_colors_shape = fills), "6.*shapes")
  p <- draw(shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(nrow(points), 14L)
  expect_false(anyNA(points$shape))
  boundary <- PlotScatter2(data[1:12, ], "x", "y", "g", group2 = "h")
  expect_false(anyNA(ggplot2::ggplot_build(boundary[[1]])$data[[1]]$shape))
})
