scatter_main_points <- function(grob) {
  if (inherits(grob, "points") && grepl("geom_point", grob$name)) {
    return(length(grob$x))
  }
  children <- c(grob$grobs, as.list(grob$children))
  sum(vapply(children, scatter_main_points, numeric(1L)))
}

test_that("PlotScatter3 derives automatic histogram limits from paired differences", {
  withr::local_options(lifecycle_verbosity = "quiet")
  inset <- NULL
  testthat::local_mocked_bindings(ggplotGrob = function(x, ...) {
    inset <<- x
    grid::nullGrob()
  }, .package = "ggplot2")
  for (offset in c(10, -20)) {
    data <- data.frame(Control = offset + 0:5,
                       Treat = offset + c(1, 3, 4, 4, 6, 8),
                       group = rep(c("NS", "S"), 3))
    PlotScatter3(data, test_method = "none", cor_method = "none")
    histogram <- ggplot2::ggplot_build(inset)$data[[1]]
    expect_equal(sum(histogram$count), 6)
    expect_lte(inset$scales$get_scales("x")$limits[1], 1)
    expect_gte(inset$scales$get_scales("x")$limits[2], 3)
  }
  data$Treat <- data$Control + 2
  PlotScatter3(data, test_method = "none", cor_method = "none")
  expect_equal(sum(ggplot2::ggplot_build(inset)$data[[1]]$count), 6)
  expect_gt(diff(inset$scales$get_scales("x")$limits), 0)
  data$Treat <- data$Control
  PlotScatter3(data, test_method = "none", cor_method = "none")
  expect_equal(sum(ggplot2::ggplot_build(inset)$data[[1]]$count), 6)
  expect_gt(diff(inset$scales$get_scales("x")$limits), 0)
  PlotScatter3(data, test_method = "none", cor_method = "none", hist_x_limits = c(-2, 4))
  expect_identical(inset$scales$get_scales("x")$limits, c(-2, 4))
})

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

test_that("PlotScatter2 rejects incomplete explicit mappings", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  draw <- function(...) PlotScatter2(data, "x", "y", "g", group2 = "h", ...)
  mappings <- list(
    colors = c(b = "red", c = "blue", unused = "black"),
    shapes = c(Y = 17, Z = 15, unused = 16),
    fill_colors_shape = c(Y = "gold", Z = "green", unused = "black")
  )
  missing <- c(colors = "a", shapes = "X", fill_colors_shape = "X")
  for (arg in names(mappings)) {
    message <- tryCatch({
      do.call(draw, stats::setNames(list(mappings[[arg]]), arg))
      NULL
    }, error = conditionMessage)
    expect_identical(message, sprintf("'%s' is missing mappings for: %s.",
                                      arg, missing[[arg]]))

    message <- tryCatch({
      do.call(draw, stats::setNames(list(unname(mappings[[arg]][1:2])), arg))
      NULL
    }, error = conditionMessage)
    expect_identical(message, sprintf(
      "'%s' must supply at least 3 values, one for each observed group level.", arg
    ))
  }
})

test_that("PlotScatter2 matches complete named mappings by level", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = factor(rep(c("b", "a", "c"), each = 3),
                                levels = c("unused", "c", "a", "b")),
                     h = rep(c("Y", "X", "Z"), each = 3))
  colors <- c(c = "#336699", a = "#993333", b = "#339933", extra = "black")
  shapes <- c(Z = 15, X = 18, Y = 17, extra = 16)
  fills <- c(X = "#999933", Z = "#993399", Y = "#339999", extra = "white")
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h", colors = colors,
                    shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_identical(points$colour, unname(colors[as.character(data$g)]))
  expect_identical(points$shape, unname(shapes[data$h]))
  for (panel in c(2, 4)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, unname(colors[c("b", "a", "c")]))
  }
  for (panel in c(3, 5)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, unname(fills[c("Y", "X", "Z")]))
  }
})

test_that("PlotScatter2 matches unnamed mappings in order of first appearance", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  colors <- c("#336699", "#993333", "#339933", "black")
  shapes <- c(17, 18, 15, 16)
  fills <- c("#999933", "#993399", "#339999", "white")
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h", colors = colors,
                    shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_identical(points$colour, rep(colors[1:3], each = 3))
  expect_identical(points$shape, rep(shapes[1:3], each = 3))
  for (panel in c(2, 4)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, colors[1:3])
  }
  for (panel in c(3, 5)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, fills[1:3])
  }
})

test_that("PlotScatter2 labels shape fills from unnamed mappings", {
  skip_if_not_installed("gridExtra")
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h",
                    fill_colors_shape = c("gold", "green", "blue"))
  grob_labels <- function(grob) {
    labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
    children <- c(grob$grobs, as.list(grob$children))
    c(labels, unlist(lapply(children, grob_labels), use.names = FALSE))
  }
  labels <- grob_labels(ggplot2::ggplotGrob(p[[6]]))
  expect_setequal(intersect(labels, c("Y", "X", "Z")), c("Y", "X", "Z"))
})
