test_that("default boxplots match native layers without changing the caller", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  q <- fmt_boxplot(p)
  native <- p + ggplot2::geom_boxplot(width = 0.3, alpha = 0.2,
                                     na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  expect_length(p$layers, 1L)
  expect_identical(p$data, d)
  expect_identical(names(p$mapping), c("x", "y"))
  expect_identical(names(formals(fmt_boxplot)),
                   c("plot", "boxplot.args", "inherit.aes"))
})

test_that("independent boxplots retain explicit data and complete mappings", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  external <- data.frame(a = rep(c("c", "d"), each = 4), b = 21:28)
  args <- list(data = external, mapping = ggplot2::aes(a, b, fill = a))
  q <- fmt_boxplot(p, boxplot.args = args, inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(data = external,
    mapping = ggplot2::aes(a, b, fill = a), inherit.aes = FALSE,
    width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(q$layers[[2L]]$data, external)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(22.5, 26.5))
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  expect_identical(args$data, external)
  expect_length(p$layers, 1L)
})

test_that("independent boxplots fill only missing position mappings", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = x)) +
    ggplot2::geom_point()
  shift <- 100
  q <- fmt_boxplot(p, list(mapping = ggplot2::aes(y = y + shift, group = x)),
                   inherit.aes = FALSE)
  expect_setequal(names(q$layers[[2L]]$mapping), c("x", "y", "group"))
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
})

test_that("explicit boxplot callbacks stay deferred until plot building", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  calls <- 0L
  callback <- function(data) {
    calls <<- calls + 1L
    transform(data, y = y + 100)
  }
  q <- fmt_boxplot(p, list(data = callback), inherit.aes = FALSE)
  expect_identical(calls, 0L)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
  expect_identical(calls, 1L)
  q <- fmt_boxplot(p, list(data = ~ transform(.x, y = y + 100)),
                   inherit.aes = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
})

test_that("independent boxplots resolve data and mappings from existing layers", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot() + ggplot2::geom_point(data = d, ggplot2::aes(x, y))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  expect_identical(q$layers[[2L]]$data, d)
  expect_length(p$layers, 1L)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, colour = x)) +
    ggplot2::geom_point(ggplot2::aes(y = y))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_setequal(names(q$layers[[2L]]$mapping), c("x", "y"))
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  expect_null(p$mapping$y)
})

test_that("independent layers never restore unrelated parent aesthetics", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, colour = x)) +
    ggplot2::geom_point(ggplot2::aes(y = y))
  external <- data.frame(a = rep(c("c", "d"), each = 4), b = 21:28)
  q <- fmt_boxplot(p, list(data = external, mapping = ggplot2::aes(a, b)),
                   inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(22.5, 26.5))
})

test_that("layer data callbacks remain deferred and keep mapping environments", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  calls <- 0L
  shift <- 100
  p <- ggplot2::ggplot(d, ggplot2::aes(x, colour = x)) +
    ggplot2::geom_point(ggplot2::aes(y = y + shift), data = function(data) {
      calls <<- calls + 1L
      data
    })
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(calls, 0L)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
  expect_identical(calls, 2L)
})

test_that("single-axis boxplots stay independent and missing sources fail clearly", {
  d <- data.frame(y = 1:12)
  p <- ggplot2::ggplot(d, ggplot2::aes(y = y)) + ggplot2::geom_blank()
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, 6.5)
  expect_error(fmt_boxplot(ggplot2::ggplot(), inherit.aes = FALSE),
               "Cannot resolve boxplot data and position mappings")
})

test_that("nested patchworks format every leaf and retain layout and annotations", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- ((p / p) | p) + patchwork::plot_annotation(title = "Three plots")
  q <- fmt_boxplot(pw)
  expect_length(q[[1L]][[1L]]$layers, 2L)
  expect_length(q[[1L]][[2L]]$layers, 2L)
  expect_length(q[[2L]]$layers, 2L)
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  expect_identical(q[[1L]]$patches$layout, pw[[1L]]$patches$layout)
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
  expect_length(pw[[1L]][[1L]]$layers, 1L)
  expect_length(p$layers, 1L)
})

test_that("patchwork placeholders and overlays retain their original layers", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (placeholder in list(patchwork::plot_spacer(), patchwork::guide_area(),
                           patchwork::wrap_elements(grid::textGrob("Note")))) {
    for (inherit in c(TRUE, FALSE)) {
      q <- fmt_boxplot(p | placeholder, inherit.aes = inherit)
      expect_length(q[[1L]]$layers, 2L)
      expect_length(q[[2L]]$layers, 0L)
      expect_identical(class(q[[2L]]), class(placeholder))
    }
  }
  pw <- p + patchwork::inset_element(p, left = 0.6, bottom = 0.6,
                                    right = 1, top = 1)
  q <- fmt_boxplot(pw)
  expect_length(q[[1L]]$layers, 2L)
  expect_identical(q[[2L]]$layers, pw[[2L]]$layers)
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
})

test_that("named plot lists retain their names and format all nested plot leaves", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(single = p, combined = p / p)
  q <- fmt_boxplot(plots)
  expect_identical(names(q), names(plots))
  expect_length(q$single$layers, 2L)
  expect_length(q$combined[[1L]]$layers, 2L)
  expect_length(q$combined[[2L]]$layers, 2L)
  expect_length(plots$combined[[1L]]$layers, 1L)
})
