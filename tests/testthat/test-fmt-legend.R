legend_test_plot <- function(continuous = FALSE) {
  d <- data.frame(x = 1:6, y = c(2, 4, 3, 5, 4, 6),
                  group = factor(rep(c("a", "b", "c"), 2)), value = 1:6)
  mapping <- if (continuous) ggplot2::aes(x, y, colour = value) else
    ggplot2::aes(x, y, colour = group)
  ggplot2::ggplot(d, mapping) + ggplot2::geom_point()
}

legend_test_labels <- function(g) {
  labels <- if (inherits(g, "text")) as.character(g$label) else character()
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  c(labels, unlist(lapply(children, legend_test_labels), use.names = FALSE))
}

test_that("legend titles cover default scales and layer mappings", {
  p <- legend_test_plot()
  changed <- fmt_legend(p, title = "New group")
  labels <- legend_test_labels(ggplot2::ggplotGrob(changed))
  expect_true("New group" %in% labels)
  expect_false("group" %in% labels)
  expect_true("group" %in% legend_test_labels(ggplot2::ggplotGrob(p)))
  expect_identical(ggplot2::ggplot_build(p)$data,
                   ggplot2::ggplot_build(changed)$data)
  layer_plot <- ggplot2::ggplot(p$data, ggplot2::aes(x, y)) +
    ggplot2::geom_point(ggplot2::aes(shape = group))
  expect_true("Layer group" %in% legend_test_labels(
    ggplot2::ggplotGrob(fmt_legend(layer_plot, title = "Layer group"))))
})

test_that("legend title updates leave shared scales and guides unchanged", {
  guide <- ggplot2::guide_legend(title = "Guide title", reverse = TRUE)
  sc <- ggplot2::scale_colour_discrete(name = "Scale title", guide = guide)
  original <- legend_test_plot() + sc
  sibling <- legend_test_plot() + sc
  changed <- fmt_legend(original, title = "Replacement")
  expect_identical(sc$name, "Scale title")
  expect_identical(original$scales$scales[[1]]$name, "Scale title")
  expect_identical(sibling$scales$scales[[1]]$name, "Scale title")
  expect_identical(guide$params$title, "Guide title")
  expect_true(changed$scales$scales[[1]]$guide$params$reverse)
  expect_true("Replacement" %in% legend_test_labels(ggplot2::ggplotGrob(changed)))
  expect_true("Guide title" %in% legend_test_labels(ggplot2::ggplotGrob(original)))
  explicit <- original + ggplot2::guides(colour = guide)
  output <- fmt_legend(explicit, title = "Explicit guide")
  expect_true("Explicit guide" %in% legend_test_labels(ggplot2::ggplotGrob(output)))
  expect_identical(explicit$guides$guides$colour$params$title, "Guide title")
})

test_that("legend titles recycle across editable nested plots", {
  p <- legend_test_plot()
  nested <- (p | patchwork::plot_spacer()) / (p | p)
  output <- fmt_legend(nested, title = c("First", "Second"))
  leaves <- .to_plot_list(output, recurse = TRUE)$plots
  expect_identical(vapply(leaves, function(x) x$labels$colour, character(1)),
                   c("First", "Second", "First"))
  expect_identical(output$patches$layout, nested$patches$layout)
  named <- fmt_legend(list(left = p, right = p), title = c("Left", "Right"))
  expect_identical(names(named), c("left", "right"))
  expect_true("Left" %in% legend_test_labels(ggplot2::ggplotGrob(named$left)))
})

test_that("legend formatting retains continuous and binned guide types", {
  controls <- list(list(scale = 0.8), list(ncol = 2),
                   list(legend_theme = ggplot2::theme(legend.title = ggplot2::element_blank())))
  for (p in list(legend_test_plot(TRUE), legend_test_plot(TRUE) +
                 ggplot2::scale_colour_steps())) {
    before <- ggplot2::ggplot_build(p)$plot$guides$guides[[1]]
    for (args in controls) {
      changed <- do.call(fmt_legend, c(list(plot = p), args))
      after <- ggplot2::ggplot_build(changed)$plot$guides$guides[[1]]
      expect_identical(class(after), class(before))
      expect_no_error(ggplot2::ggplotGrob(changed))
    }
  }
})

test_that("legend dimensions preserve discrete guides and disabled guides", {
  for (continuous in c(FALSE, TRUE)) {
    p <- legend_test_plot(continuous)
    before <- ggplot2::ggplot_build(p)$plot$guides$guides[[1]]
    changed <- fmt_legend(p, scale_width = 1.5, scale_height = 0.5)
    expect_warning(g <- ggplot2::ggplotGrob(changed), NA)
    expect_true(any(grepl("^guide-box", g$layout$name) &
                      vapply(g$grobs, inherits, logical(1), "gtable")))
    expect_identical(class(ggplot2::ggplot_build(changed)$plot$guides$guides[[1]]),
                     class(before))
    hidden_scale <- if (continuous) ggplot2::scale_colour_continuous(guide = "none") else
      ggplot2::scale_colour_discrete(guide = "none")
    for (hidden in list(p + ggplot2::guides(colour = "none"), p + hidden_scale)) {
      output <- fmt_legend(hidden, scale = 0.8, ncol = 2)
      expect_length(ggplot2::ggplot_build(output)$plot$guides$guides, 0L)
    }
  }
})

test_that("guide formatting defers data callbacks and retains later guide edits", {
  calls <- 0L
  p <- ggplot2::ggplot(mapping = ggplot2::aes(x, y, colour = value)) +
    ggplot2::geom_point(data = function(x) {
      calls <<- calls + 1L
      data.frame(x = 1:4, y = 4:1, value = 1:4)
    })
  set.seed(14)
  rng <- .Random.seed
  result <- fmt_legend(p, scale = 0.8, ncol = 2)
  expect_identical(calls, 0L)
  expect_identical(.Random.seed, rng)
  expect_s3_class(ggplot2::ggplot_build(result)$plot$guides$guides[[1]], "GuideColourbar")
  expect_identical(calls, 1L)
  hidden <- result + ggplot2::guides(colour = "none")
  expect_length(ggplot2::ggplot_build(hidden)$plot$guides$guides, 0L)
})

legend_test_box_size <- function(p) {
  g <- ggplot2::ggplotGrob(p)
  index <- which(grepl("^guide-box", g$layout$name) &
                   vapply(g$grobs, inherits, logical(1), "gtable"))[1]
  box <- g$grobs[[index]]
  c(width = grid::convertWidth(sum(box$widths), "mm", valueOnly = TRUE),
    height = grid::convertHeight(sum(box$heights), "mm", valueOnly = TRUE))
}

test_that("legend scaling retains units and scale one preserves rendered size", {
  for (unit in list(grid::unit(4, "mm"), grid::unit(0.4, "cm"),
                    grid::unit(10, "pt"), grid::unit(0.8, "lines"),
                    grid::unit(3, "mm") + grid::unit(1, "pt"))) {
    p <- legend_test_plot() + ggplot2::theme(legend.key.size = unit,
      legend.box.spacing = grid::unit(8, "mm"),
      legend.spacing = grid::unit(7, "pt"))
    output <- fmt_legend(p, scale = 1)
    expect_equal(grid::convertWidth(output$theme$legend.key.size, "mm", valueOnly = TRUE),
                 grid::convertWidth(unit, "mm", valueOnly = TRUE))
    expect_equal(grid::convertWidth(output$theme$legend.box.spacing, "mm", valueOnly = TRUE), 8)
    expect_equal(legend_test_box_size(output), legend_test_box_size(p))
  }
})

test_that("independent legend dimensions multiply existing and global sizes", {
  p <- legend_test_plot() + ggplot2::theme(legend.key.width = grid::unit(4, "mm"),
    legend.key.height = grid::unit(8, "mm"))
  for (args in list(list(scale_width = 1, scale_height = 1),
                    list(scale_width = 2, scale_height = 0.5),
                    list(scale = 0.5, scale_width = 2, scale_height = 0.5))) {
    output <- do.call(fmt_legend, c(list(plot = p), args))
    factor <- if (is.null(args$scale)) 1 else args$scale
    expect_equal(grid::convertWidth(output$theme$legend.key.width, "mm", valueOnly = TRUE),
                 4 * factor * args$scale_width)
    expect_equal(grid::convertHeight(output$theme$legend.key.height, "mm", valueOnly = TRUE),
                 8 * factor * args$scale_height)
    expect_no_error(ggplot2::ggplotGrob(output))
  }
})

test_that("legend scaling uses each subplot and the newly applied theme", {
  p <- legend_test_plot()
  plots <- list(p + ggplot2::theme(legend.text = ggplot2::element_text(size = 10),
                                  legend.key.width = grid::unit(4, "mm")),
                p + ggplot2::theme(legend.text = ggplot2::element_text(size = 20),
                                  legend.key.width = grid::unit(8, "mm")))
  for (input in list(plots, plots[[1]] | plots[[2]])) {
    output <- fmt_legend(input, scale = 0.5)
    leaves <- .to_plot_list(output, recurse = TRUE)$plots
    expect_equal(vapply(leaves, function(x) x$theme$legend.text$size, numeric(1)), c(5, 10))
    expect_equal(vapply(leaves, function(x) grid::convertWidth(
      x$theme$legend.key.width, "mm", valueOnly = TRUE), numeric(1)), c(2, 4))
  }
  output <- fmt_legend(p, legend_theme = ggplot2::theme(
    legend.text = ggplot2::element_text(size = 20, colour = "red")), scale = 0.5)
  expect_equal(output$theme$legend.text$size, 10)
  expect_identical(output$theme$legend.text$colour, "red")
  collected <- fmt_legend(plots[[1]] | plots[[2]], collect = TRUE, scale = 0.5,
                          legend_theme = ggplot2::theme(legend.text = ggplot2::element_text(size = 20)))
  expect_equal(vapply(.to_plot_list(collected, recurse = TRUE)$plots,
                      function(x) x$theme$legend.text$size, numeric(1)), c(10, 10))
  expect_no_error(patchwork::patchworkGrob(collected))
})

test_that("legend scaling retains blank text and title elements", {
  p <- legend_test_plot() + ggplot2::theme(legend.title = ggplot2::element_blank())
  output <- fmt_legend(p, scale = 0.5)
  expect_s3_class(output$theme$legend.title, "element_blank")
  expect_false("group" %in% legend_test_labels(ggplot2::ggplotGrob(output)))
  blank <- fmt_legend(legend_test_plot(), scale = 0.5, legend_theme = ggplot2::theme(
    legend.title = ggplot2::element_blank(), legend.text = ggplot2::element_blank()))
  expect_s3_class(blank$theme$legend.text, "element_blank")
  expect_false(any(c("group", "a", "b", "c") %in% legend_test_labels(ggplot2::ggplotGrob(blank))))
})
