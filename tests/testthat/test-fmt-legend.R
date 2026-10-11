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
