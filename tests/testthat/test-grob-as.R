grob_as_test_labels <- function(grob) {
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  children <- if (inherits(grob, "gtable")) grob$grobs else grob$children
  c(labels, unlist(lapply(children, grob_as_test_labels), use.names = FALSE))
}

test_that("grob_as() retains nested patchwork plots, annotations and guides", {
  withr::local_pdf(NULL, width = 7, height = 7)
  data <- data.frame(x = 1:6, y = c(2, 4, 1, 6, 3, 5),
                     group = rep(c("A", "B"), each = 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y, colour = group)) +
    ggplot2::geom_point() + ggplot2::theme_gray()
  first <- plot + ggplot2::labs(title = "First panel")
  second <- plot + ggplot2::labs(title = "Second panel")
  third <- plot + ggplot2::labs(title = "Third panel")
  combined <- ((first | second) / third) +
    patchwork::plot_layout(heights = c(1, 2), guides = "collect") +
    patchwork::plot_annotation(title = "Whole composition", tag_levels = "A")
  native <- patchwork::patchworkGrob(combined)

  result <- grob_as(combined)

  expect_s3_class(result, "gtable")
  expect_equal(result$layout, native$layout)
  expect_equal(grid::convertWidth(result$widths, "mm", valueOnly = TRUE),
               grid::convertWidth(native$widths, "mm", valueOnly = TRUE))
  expect_equal(grid::convertHeight(result$heights, "mm", valueOnly = TRUE),
               grid::convertHeight(native$heights, "mm", valueOnly = TRUE))
  labels <- grob_as_test_labels(result)
  for (label in c("First panel", "Second panel", "Third panel",
                  "Whole composition", "group")) {
    expect_equal(sum(labels == label), 1L)
  }
  expect_equal(labels, grob_as_test_labels(native))
  expect_no_error(grid::grid.draw(result))
})

test_that("grob_as() keeps composite plots through its downstream wrappers", {
  withr::local_pdf(NULL)
  data <- data.frame(x = 1:3, y = c(2, 1, 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  combined <- (plot + ggplot2::labs(title = "Left panel")) |
    (plot + ggplot2::labs(title = "Right panel"))

  wrapped <- ggplot2::ggplotGrob(grob_to_gg(combined))
  inserted <- grob_insert(combined, grid::textGrob("Inset label"))

  for (result in list(wrapped, inserted)) {
    labels <- grob_as_test_labels(result)
    expect_equal(sum(labels == "Left panel"), 1L)
    expect_equal(sum(labels == "Right panel"), 1L)
    expect_no_error(grid::grid.draw(result))
  }
  expect_equal(sum(grob_as_test_labels(inserted) == "Inset label"), 1L)
})

test_that("grob_as() preserves the other supported input conversions", {
  withr::local_pdf(NULL)
  data <- data.frame(x = 1:3, y = c(2, 1, 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  table <- ggplot2::ggplotGrob(plot)
  grob <- grid::textGrob("Single grob")
  grobs <- grid::gList(grob, grid::textGrob("Second grob"))

  expect_s3_class(grob_as(plot), "gtable")
  expect_identical(grob_as(table), table)
  expect_identical(grob_as(grob), grob)
  expect_equal(grob_as_test_labels(grob_as(grobs)),
               c("Single grob", "Second grob"))
  expect_warning(result <- grob_as(42), "Cannot convert object")
  expect_null(result)
})
