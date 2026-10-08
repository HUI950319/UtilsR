find_grobs <- function(g, cls) {
  kids <- if (inherits(g, "gtable")) g$grobs else if (inherits(g, "gTree")) g$children
  c(if (inherits(g, cls)) list(g),
    unlist(lapply(kids, find_grobs, cls = cls), recursive = FALSE))
}

test_that("inside tags draw one label with four-sided padding", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  original <- ggplot2::ggplot_build(p)
  res <- fmt_tag(p, labels = "A", fill = "red", alpha = 0.25)
  built <- ggplot2::ggplot_build(res)

  expect_equal(nrow(built$data[[2]]), 1L)
  expect_equal(built$data[[2]]$label, "A")
  expect_equal(built$data[[2]]$alpha, 0.25)
  expect_identical(built$data[[1]], original$data[[1]])
  expect_identical(built$layout$panel_params[[1]]$x.range,
                   original$layout$panel_params[[1]]$x.range)
  expect_identical(built$layout$panel_params[[1]]$y.range,
                   original$layout$panel_params[[1]]$y.range)
  tags <- Filter(function(g) identical(g$label, "A"),
                 find_grobs(ggplot2::ggplotGrob(res), "text"))
  expect_length(tags, 1L)
})

test_that("outside tags are drawn in a box honouring label.size / label.r", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  res <- fmt_tag(p, labels = "A", label_position = "tl-out",
                 label.size = 2, label.r = grid::unit(0.5, "lines"))

  expect_s3_class(res, "patchwork")
  boxes <- find_grobs(patchwork::patchworkGrob(res), "roundrect")
  expect_length(boxes, 1L)
  expect_equal(boxes[[1]]$gp$lwd, 2 * ggplot2::.pt)
  expect_equal(boxes[[1]]$r, grid::unit(0.5, "lines"))
  expect_null(res$labels$tag)
})

test_that("outside boxes are inset by half the border so it is not clipped", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  res <- fmt_tag(p, label_position = "tl-out", label.size = 2)

  trees <- Filter(
    function(g) any(vapply(g$children, inherits, logical(1), "roundrect")),
    find_grobs(patchwork::patchworkGrob(res), "gTree")
  )
  expect_length(trees, 1L)
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  vp <- trees[[1]]$vp
  expect_equal(grid::convertX(vp$x, "mm", valueOnly = TRUE), 1)
  expect_equal(
    grid::convertY(grid::unit(1, "npc") - vp$y, "mm", valueOnly = TRUE), 1
  )
})

test_that("outside tags keep the patchwork layout", {
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, qsec)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(p1, p2, ncol = 1)
  res <- fmt_tag(pw, label_position = "br_out")

  expect_s3_class(res, "patchwork")
  expect_length(find_grobs(patchwork::patchworkGrob(res), "roundrect"), 2L)
})
