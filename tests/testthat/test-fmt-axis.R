axis_grob_labels <- function(g) {
  labels <- if (inherits(g, "text")) as.character(g$label) else character()
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  c(labels, unlist(lapply(children, axis_grob_labels), use.names = FALSE))
}

test_that("axis hiding covers explicitly styled sides and secondary axes", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(sec.axis = ggplot2::dup_axis(name = "Secondary X")) +
    ggplot2::scale_y_continuous(sec.axis = ggplot2::dup_axis(name = "Secondary Y")) +
    ggplot2::theme_classic() + ggplot2::theme(
      axis.text.x.bottom = ggplot2::element_text(colour = "red"),
      axis.text.x.top = ggplot2::element_text(colour = "red"),
      axis.text.y.left = ggplot2::element_text(colour = "red"),
      axis.text.y.right = ggplot2::element_text(colour = "red"),
      axis.title.x.bottom = ggplot2::element_text(),
      axis.title.x.top = ggplot2::element_text(),
      axis.title.y.left = ggplot2::element_text(),
      axis.title.y.right = ggplot2::element_text(),
      axis.ticks.x.bottom = ggplot2::element_line(),
      axis.ticks.x.top = ggplot2::element_line(),
      axis.ticks.y.left = ggplot2::element_line(),
      axis.ticks.y.right = ggplot2::element_line(),
      axis.ticks.length.x.bottom = grid::unit(3, "mm"),
      axis.ticks.length.x.top = grid::unit(3, "mm"),
      axis.ticks.length.y.left = grid::unit(3, "mm"),
      axis.ticks.length.y.right = grid::unit(3, "mm")
    )
  hidden <- fmt_axis(p, x.axis = TRUE, y.axis = TRUE)
  labels <- axis_grob_labels(ggplot2::ggplotGrob(hidden))
  expect_false(any(labels %in% c("x", "y", "Secondary X", "Secondary Y")))
  expect_false(any(labels %in% as.character(1:4)))
  expect_identical(ggplot2::ggplot_build(hidden)$data,
                   ggplot2::ggplot_build(p)$data)
  x_only <- axis_grob_labels(ggplot2::ggplotGrob(fmt_axis(p, x.axis = TRUE)))
  expect_false(any(x_only %in% c("x", "Secondary X")))
  expect_true(all(c("y", "Secondary Y") %in% x_only))
})

test_that("axis hiding removes styled major and minor ticks but keeps axis lines", {
  skip_if_not("axis.minor.ticks.x.bottom" %in% names(ggplot2::get_element_tree()))
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::theme_classic() + ggplot2::scale_x_continuous(
      breaks = 1:4, minor_breaks = c(1.5, 2.5, 3.5),
      guide = ggplot2::guide_axis(minor.ticks = TRUE)
    ) + ggplot2::theme(
      axis.ticks.x.bottom = ggplot2::element_line(),
      axis.minor.ticks.x.bottom = ggplot2::element_line(colour = "red"),
      axis.ticks.length.x.bottom = grid::unit(3, "mm"),
      axis.minor.ticks.length.x.bottom = grid::unit(2, "mm")
    )
  axis_lines <- function(q) {
    g <- ggplot2::ggplotGrob(q)
    count <- function(z) {
      children <- if (inherits(z, "gtable")) z$grobs else z$children
      as.integer(inherits(z, "polyline")) + sum(vapply(children, count, integer(1)))
    }
    count(g$grobs[[which(g$layout$name == "axis-b")]])
  }
  expect_gt(axis_lines(p), 1L)
  expect_equal(axis_lines(fmt_axis(p, x.axis = TRUE)), 1L)
})
