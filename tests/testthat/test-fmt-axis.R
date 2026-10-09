axis_grob_labels <- function(g) {
  labels <- if (inherits(g, "text")) as.character(g$label) else character()
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  c(labels, unlist(lapply(children, axis_grob_labels), use.names = FALSE))
}

axis_hidden_indices <- function(plot) {
  plots <- .to_plot_list(plot, recurse = TRUE)$plots
  list(x = which(vapply(plots, function(p) {
    inherits(p$theme$axis.text.x, "element_blank")
  }, logical(1))), y = which(vapply(plots, function(p) {
    inherits(p$theme$axis.text.y, "element_blank")
  }, logical(1))))
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

test_that("automatic axes follow column-major layouts and retain layout metadata", {
  plots <- lapply(1:4, function(i) {
    ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                     ggplot2::aes(x, y)) + ggplot2::geom_point() +
      ggplot2::labs(x = paste0("X", i), y = paste0("Y", i))
  })
  pw <- patchwork::wrap_plots(plots, nrow = 2, ncol = 2, byrow = FALSE) +
    patchwork::plot_annotation(title = "Keep", tag_levels = "A")
  hidden <- fmt_axis(pw, plot_dims = c(2, 2))
  expect_identical(axis_hidden_indices(hidden), list(x = c(1L, 3L), y = 3:4))
  expect_identical(hidden$patches$layout, pw$patches$layout)
  expect_identical(hidden$patches$annotation, pw$patches$annotation)
  labels <- axis_grob_labels(patchwork::patchworkGrob(hidden))
  expect_true(all(c("X2", "X4", "Y1", "Y2", "Keep") %in% labels))
  expect_false(any(c("X1", "X3", "Y3", "Y4") %in% labels))
})

test_that("spacers and guide areas occupy cells without consuming plot indices", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (space in list(patchwork::plot_spacer(), patchwork::guide_area())) {
    pw <- (p | space) / (p | p)
    hidden <- fmt_axis(pw, plot_dims = c(2, 2))
    expect_identical(axis_hidden_indices(hidden), list(x = 1L, y = 3L))
    expect_identical(hidden$patches$layout, pw$patches$layout)
  }
  # A flat grid and its nested equivalent select the same leaves.
  expect_identical(axis_hidden_indices(fmt_axis((p | p) / (p | p),
                                                 plot_dims = c(2, 2))),
                   list(x = 1:2, y = c(2L, 4L)))
})

test_that("automatic axes account for spanning plots in custom designs", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(A = p, B = p, C = p, design = "AB\nAC")
  hidden <- fmt_axis(pw, plot_dims = c(2, 2))
  expect_identical(axis_hidden_indices(hidden), list(x = 2L, y = 2:3))
  expect_identical(hidden$patches$layout, pw$patches$layout)
  expect_no_error(patchwork::patchworkGrob(hidden))
})

test_that("automatic axes ignore inset overlays and preserve freed alignment", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  inset <- p + patchwork::inset_element(p, 0.6, 0.6, 1, 1)
  pw <- patchwork::free(inset / p, side = "l")
  hidden <- fmt_axis(pw, plot_dims = c(2, 1))
  expect_identical(axis_hidden_indices(hidden), list(x = 1L, y = integer()))
  expect_identical(attr(hidden, "patchwork_free_settings"),
                   attr(pw, "patchwork_free_settings"))
  expect_no_error(patchwork::patchworkGrob(hidden))
})

test_that("layout dimensions must be finite positive integers with enough cells", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  invalid <- list(numeric(), 0, -1, 1.5, NA_real_, Inf, "2", TRUE,
                   c(2, 2, 1), c(2, NA), c(2, Inf), 1 + 1i,
                   .Machine$integer.max + 1)
  for (dims in invalid) {
    expect_error(fmt_axis(p, plot_dims = dims), "plot_dims")
  }
  expect_error(fmt_axis(rep(list(p), 4), plot_dims = c(1, 2)), "too few cells")
  expect_error(fmt_axis(list(), plot_dims = 0), "plot_dims")
  # Empty final rows must not hide the last occupied row's x-axis.
  expect_identical(axis_hidden_indices(fmt_axis(rep(list(p), 3),
                                                 plot_dims = c(3, 2))),
                   list(x = 1:2, y = 2L))
  expect_identical(axis_hidden_indices(fmt_axis(rep(list(p), 4), plot_dims = 2)),
                   list(x = 1:2, y = c(2L, 4L)))
  expect_identical(fmt_axis(list(), plot_dims = c(1, 1)), list())
  expect_identical(axis_hidden_indices(fmt_axis(rep(list(p), 3),
                                                 plot_dims = c(1, .Machine$integer.max))),
                   list(x = integer(), y = 2:3))
})

test_that("axis selectors reject malformed and out-of-range indices", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(A = p, B = p)
  invalid <- list("all", c(TRUE, FALSE), NA, NA_integer_, Inf, 1.5,
                   c(1, NA), 0, -1, 3, 1 + 1i, factor(1), as.Date("2026-01-01"))
  for (index in invalid) {
    expect_error(fmt_axis(plots, x.axis = index), "x.axis")
    expect_error(fmt_axis(plots, y.axis = index), "y.axis")
  }
  expect_error(fmt_axis(list(), x.axis = 1), "x.axis")
  expect_error(fmt_axis(plots, x.axis = NA, plot_dims = c(1, 2)), "x.axis")
  expect_identical(names(fmt_axis(plots, x.axis = c(1, 1))), c("A", "B"))
  expect_identical(axis_hidden_indices(fmt_axis(plots, x.axis = c(1, 1))),
                   list(x = 1L, y = integer()))
  expect_identical(axis_hidden_indices(fmt_axis(plots, x.axis = integer(),
                                                 y.axis = NULL)),
                   list(x = integer(), y = integer()))
})
