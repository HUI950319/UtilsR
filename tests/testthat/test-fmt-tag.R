find_grobs <- function(g, cls) {
  if (inherits(g, cls)) return(list(g))
  kids <- if (inherits(g, "gtable")) g$grobs else if (inherits(g, "gTree")) g$children
  unlist(lapply(kids, find_grobs, cls = cls), recursive = FALSE)
}

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

test_that("outside tags keep the patchwork layout", {
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, qsec)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(p1, p2, ncol = 1)
  res <- fmt_tag(pw, label_position = "br_out")

  expect_s3_class(res, "patchwork")
  expect_length(find_grobs(patchwork::patchworkGrob(res), "roundrect"), 2L)
})
