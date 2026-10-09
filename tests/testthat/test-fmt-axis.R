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

test_that("layout-based selection consistently takes precedence over manual selectors", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- rep(list(p), 4)
  expect_identical(axis_hidden_indices(fmt_axis(plots, x.axis = TRUE,
                                                 y.axis = TRUE, plot_dims = c(1, 4))),
                   list(x = integer(), y = 2:4))
  expect_identical(axis_hidden_indices(fmt_axis(plots, x.axis = TRUE,
                                                 y.axis = TRUE, plot_dims = c(4, 1))),
                   list(x = 1:3, y = integer()))
  expect_identical(axis_hidden_indices(fmt_axis(plots, x.axis = FALSE,
                                                 y.axis = FALSE, plot_dims = c(2, 2))),
                   list(x = 1:2, y = c(2L, 4L)))
  expect_identical(axis_hidden_indices(fmt_axis(p, TRUE, TRUE, plot_dims = c(1, 1))),
                   list(x = integer(), y = integer()))
  # Existing patchwork positions are authoritative; dimensions do not rearrange it.
  pw <- patchwork::wrap_plots(plots, nrow = 2, ncol = 2)
  expect_identical(axis_hidden_indices(fmt_axis(pw, plot_dims = c(1, 4))),
                   list(x = 1:2, y = c(2L, 4L)))
})

test_that("empty selections retain input containers without evaluating data", {
  calls <- 0L
  p <- ggplot2::ggplot() + ggplot2::geom_point(
    data = function(data) {
      calls <<- calls + 1L
      data.frame(x = 1:4, y = c(1, 3, 2, 4))
    }, mapping = ggplot2::aes(x, y)
  )
  withr::local_seed(624)
  seed <- .Random.seed
  nested <- (p | patchwork::plot_spacer()) / (p | p)
  inputs <- list(p, list(A = p, B = p), nested,
                   patchwork::free(nested, side = "l"), list())
  for (input in inputs) {
    expect_identical(fmt_axis(input), input)
    expect_identical(fmt_axis(input, x.axis = integer(), y.axis = NULL), input)
  }
  expect_equal(calls, 0L)
  expect_identical(.Random.seed, seed)
  expect_error(fmt_axis(list(p, "invalid")), "ggplot")
  expect_error(fmt_axis(1), "ggplot")
  hidden <- fmt_axis(p, x.axis = TRUE)
  expect_identical(fmt_axis(hidden), hidden)
  expect_identical(fmt_axis(p, plot_dims = c(1, 1)), p)
})

test_that("combined axis hiding renders identically to separate axis calls", {
  skip_if_not_installed("ragg")
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::theme_classic()
  capture_plot <- function(q) {
    capture <- ragg::agg_capture(width = 600, height = 420, res = 100)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(q)
    capture(native = TRUE)
  }
  expect_identical(capture_plot(fmt_axis(p, TRUE, TRUE)),
                   capture_plot(fmt_axis(fmt_axis(p, x.axis = TRUE), y.axis = TRUE)))
  named <- list(A = p, B = p, C = p)
  combined <- fmt_axis(named, x.axis = c(1, 2), y.axis = c(2, 3))
  separate <- fmt_axis(fmt_axis(named, x.axis = c(1, 2)), y.axis = c(2, 3))
  expect_identical(capture_plot(patchwork::wrap_plots(combined)),
                   capture_plot(patchwork::wrap_plots(separate)))
  expect_identical(names(combined), names(named))
})

test_that("patchwork inset overlays do not consume editable axis indices", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  overlay <- (p | p) & ggplot2::labs(x = "Inset X", y = "Inset Y")
  pw <- (p | p) + patchwork::inset_element(overlay, 0.6, 0.6, 1, 1)
  expect_length(.to_plot_list(pw, recurse = TRUE)$plots, 2L)
  hidden <- fmt_axis(pw, plot_dims = c(1, 2))
  expect_identical(axis_hidden_indices(hidden), list(x = integer(), y = 2L))
  hidden <- fmt_axis(pw, x.axis = 1:2, y.axis = 1:2)
  labels <- axis_grob_labels(patchwork::patchworkGrob(hidden))
  expect_true(all(c("Inset X", "Inset Y") %in% labels))
  expect_false(any(c("x", "y") %in% labels))
  # Reference and legend formatters use the same leaf traversal.
  ref <- fmt_ref(pw, x = 2)
  expect_length(.to_plot_list(ref, recurse = TRUE)$plots, 2L)
  expect_no_error(patchwork::patchworkGrob(fmt_legend(ref, legend.position = "none")))
  freed <- patchwork::free(pw, side = "l")
  result <- fmt_axis(freed, plot_dims = c(1, 2))
  expect_identical(attr(result, "patchwork_free_settings"),
                   attr(freed, "patchwork_free_settings"))
  expect_no_error(patchwork::patchworkGrob(result))
})

test_that("list layouts retain occupied spacer cells and nested containers", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (space in list(patchwork::plot_spacer(), patchwork::guide_area(),
                    patchwork::wrap_elements(full = grid::rectGrob()))) {
    plots <- list(A = p, space = space, B = p, C = p)
    result <- fmt_axis(plots, plot_dims = c(2, 2))
    expect_identical(axis_hidden_indices(result), list(x = 1L, y = 3L))
    expect_identical(names(result), names(plots))
    expect_identical(result$space, space)
    expect_identical(axis_hidden_indices(result), axis_hidden_indices(
      fmt_axis(patchwork::wrap_plots(plots, nrow = 2, ncol = 2),
               plot_dims = c(2, 2))))
    expect_error(fmt_axis(plots, plot_dims = c(1, 3)), "too few cells")
    expect_identical(axis_hidden_indices(fmt_axis(plots, plot_dims = 2)),
                     list(x = 1L, y = 3L))
  }
  nested <- list(A = p | p, B = p | p)
  expect_identical(axis_hidden_indices(fmt_axis(nested, plot_dims = c(1, 2))),
                   list(x = integer(), y = 2:4))
  expect_identical(axis_hidden_indices(fmt_axis(nested, plot_dims = 1)),
                   list(x = integer(), y = 2:4))
  plots <- list(p + ggplot2::labs(x = "X1", y = "Y1"), patchwork::plot_spacer(),
                p + ggplot2::labs(x = "X2", y = "Y2"),
                p + ggplot2::labs(x = "X3", y = "Y3"))
  rendered <- patchwork::patchworkGrob(patchwork::wrap_plots(
    fmt_axis(plots, plot_dims = c(2, 2)), nrow = 2, ncol = 2))
  labels <- axis_grob_labels(rendered)
  expect_true(all(c("Y1", "X2", "Y2", "X3") %in% labels))
  expect_false(any(c("X1", "Y3") %in% labels))
})

test_that("axis hiding overrides guide-local themes without changing input guides", {
  skip_if_not_installed("ggplot2", "3.5.0")
  guide <- ggplot2::guide_axis(n.dodge = 2, minor.ticks = TRUE, cap = "both",
    theme = ggplot2::theme(
      axis.text.x.bottom = ggplot2::element_text(colour = "red"),
      axis.text.x.top = ggplot2::element_text(colour = "red"),
      axis.text.y.left = ggplot2::element_text(colour = "blue"),
      axis.text.y.right = ggplot2::element_text(colour = "blue"),
      axis.ticks.x.bottom = ggplot2::element_line(),
      axis.ticks.y.left = ggplot2::element_line(),
      axis.ticks.length = grid::unit(3, "mm")))
  skip_if_not(inherits(guide, "Guide"))
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4),
                                  group = c("A", "A", "B", "B")),
                       ggplot2::aes(x, y, colour = group)) + ggplot2::geom_point() +
    ggplot2::theme_classic()
  scales <- list(
    ggplot2::scale_x_continuous(breaks = 1:4, labels = paste0("X", 1:4), guide = guide,
      sec.axis = ggplot2::dup_axis(name = "Secondary X", guide = guide)),
    ggplot2::scale_y_continuous(breaks = 1:4, labels = paste0("Y", 1:4), guide = guide,
      sec.axis = ggplot2::dup_axis(name = "Secondary Y", guide = guide)))
  for (q in list(p + scales, p + scales + ggplot2::guides(
      x = guide, y = guide, x.sec = guide, y.sec = guide,
      colour = ggplot2::guide_legend(theme = ggplot2::theme(
        legend.text = ggplot2::element_text(colour = "green")))))) {
    before <- axis_grob_labels(ggplot2::ggplotGrob(q))
    params <- guide$params
    hidden <- fmt_axis(q, x.axis = TRUE, y.axis = TRUE)
    labels <- axis_grob_labels(ggplot2::ggplotGrob(hidden))
    expect_true(all(c(paste0("X", 1:4), paste0("Y", 1:4)) %in% before))
    expect_false(any(c("x", "y", "Secondary X", "Secondary Y",
                       paste0("X", 1:4), paste0("Y", 1:4)) %in% labels))
    expect_true(all(c("A", "B", "group") %in% labels))
    expect_identical(guide$params, params)
    expect_identical(q$scales$scales[[1]]$guide, guide)
    expect_identical(q$scales$scales[[1]]$secondary.axis$guide, guide)
    expect_identical(hidden$guides$guides$colour, q$guides$guides$colour)
    expect_identical(hidden$scales$scales[[1]]$guide$params$n.dodge, 2)
    expect_identical(hidden$scales$scales[[1]]$guide$params$cap, "both")
    expect_identical(ggplot2::ggplot_build(hidden)$data,
                     ggplot2::ggplot_build(q)$data)
    x_only <- axis_grob_labels(ggplot2::ggplotGrob(fmt_axis(q, x.axis = TRUE)))
    expect_false(any(paste0("X", 1:4) %in% x_only))
    expect_true(all(c(paste0("Y", 1:4), "Secondary Y") %in% x_only))
  }
  axes <- ggplot2::ggplotGrob(fmt_axis(p + scales, TRUE, TRUE))
  count_lines <- function(g) {
    children <- if (inherits(g, "gtable")) g$grobs else g$children
    as.integer(inherits(g, "polyline")) + sum(vapply(children, count_lines, integer(1)))
  }
  expect_equal(count_lines(axes$grobs[[which(axes$layout$name == "axis-b")]]), 1L)
  indexed <- fmt_axis(list(p + scales, p + scales), x.axis = 1, y.axis = 2)
  expect_false(any(paste0("X", 1:4) %in% axis_grob_labels(
    ggplot2::ggplotGrob(indexed[[1]]))))
  expect_false(any(paste0("Y", 1:4) %in% axis_grob_labels(
    ggplot2::ggplotGrob(indexed[[2]]))))
})

test_that("radial axes hide explicit themes and local guides in both theta mappings", {
  skip_if_not_installed("ggplot2", "3.5.0")
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = c(1, 3, 2, 4)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::theme_classic()
  radial_theme <- ggplot2::theme(
    axis.text.theta = ggplot2::element_text(),
    axis.text.r = ggplot2::element_text(),
    axis.ticks.theta = ggplot2::element_line(colour = "red"),
    axis.ticks.r = ggplot2::element_line(colour = "blue"),
    axis.line.theta = ggplot2::element_line(colour = "green"),
    axis.line.r = ggplot2::element_line(colour = "green"),
    axis.ticks.length.theta = grid::unit(3, "mm"),
    axis.ticks.length.r = grid::unit(3, "mm"))
  theta_guide <- ggplot2::guide_axis_theta(theme = radial_theme)
  radius_guide <- ggplot2::guide_axis(theme = radial_theme)
  for (theta in c("x", "y")) {
    x_guide <- if (theta == "x") theta_guide else radius_guide
    y_guide <- if (theta == "x") radius_guide else theta_guide
    base <- p + ggplot2::coord_radial(theta = theta, inner.radius = 0.2) +
      ggplot2::scale_x_continuous(breaks = 1:4, labels = paste0("X", 1:4),
        sec.axis = ggplot2::dup_axis(guide = if (theta == "x") "axis_theta" else "axis")) +
      ggplot2::scale_y_continuous(breaks = 1:4, labels = paste0("Y", 1:4),
        sec.axis = ggplot2::dup_axis(guide = if (theta == "y") "axis_theta" else "axis"))
    scale_guides <- p + ggplot2::coord_radial(theta = theta, inner.radius = 0.2) +
      ggplot2::scale_x_continuous(breaks = 1:4, labels = paste0("X", 1:4),
        guide = x_guide, sec.axis = ggplot2::dup_axis(guide = x_guide)) +
      ggplot2::scale_y_continuous(breaks = 1:4, labels = paste0("Y", 1:4),
        guide = y_guide, sec.axis = ggplot2::dup_axis(guide = y_guide))
    angular <- paste0(toupper(theta), 1:4)
    radial <- paste0(if (theta == "x") "Y" else "X", 1:4)
    for (q in list(base, base + radial_theme, scale_guides,
        base + ggplot2::guides(theta = theta_guide, theta.sec = theta_guide,
                              r = radius_guide, r.sec = radius_guide))) {
      before <- axis_grob_labels(ggplot2::ggplotGrob(q))
      both <- fmt_axis(q, TRUE, TRUE)
      labels <- axis_grob_labels(ggplot2::ggplotGrob(both))
      expect_true(all(c(angular, radial) %in% before))
      expect_false(any(c(angular, radial, "x", "y") %in% labels))
      x_only <- axis_grob_labels(ggplot2::ggplotGrob(fmt_axis(q, x.axis = TRUE)))
      y_only <- axis_grob_labels(ggplot2::ggplotGrob(fmt_axis(q, y.axis = TRUE)))
      expect_false(any(angular %in% x_only))
      expect_true(all(radial %in% x_only))
      expect_false(any(radial %in% y_only))
      expect_true(all(angular %in% y_only))
      expect_identical(ggplot2::ggplot_build(both)$data,
                       ggplot2::ggplot_build(q)$data)
      expect_identical(both$coordinates, q$coordinates)
    }
  }
  colours <- function(g) {
    children <- if (inherits(g, "gtable")) g$grobs else g$children
    c(g$gp$col, unlist(lapply(children, colours), use.names = FALSE))
  }
  q <- base + radial_theme
  expect_true(all(c("red", "blue", "green") %in% colours(ggplot2::ggplotGrob(q))))
  result_colours <- colours(ggplot2::ggplotGrob(fmt_axis(q, TRUE, TRUE)))
  expect_false(any(c("red", "blue") %in% result_colours))
  expect_true("green" %in% result_colours)
  params <- list(theta_guide$params, radius_guide$params)
  invisible(fmt_axis(scale_guides, TRUE, TRUE))
  expect_identical(list(theta_guide$params, radius_guide$params), params)
})
