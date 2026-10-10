axis_text_plot <- function() {
  ggplot2::ggplot(data.frame(category = factor(c("Alpha", "Beta", "Gamma")),
                              value = c(2, 4, 6)),
                   ggplot2::aes(category, value)) + ggplot2::geom_point() +
    ggplot2::scale_y_continuous(breaks = c(2, 4, 6),
                                labels = c("Low", "Mid", "High")) +
    ggplot2::theme_classic() + ggplot2::labs(x = NULL, y = NULL)
}

axis_text_grobs <- function(g) {
  result <- if (inherits(g, "text")) {
    data.frame(label = as.character(g$label),
               angle = rep_len(g$rot, length(g$label)),
               hjust = rep_len(g$hjust, length(g$label)),
               vjust = rep_len(g$vjust, length(g$label)),
               size = rep_len(g$gp$fontsize, length(g$label)),
               colour = rep_len(g$gp$col, length(g$label)))
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  do.call(rbind, c(list(result), lapply(children, axis_text_grobs)))
}

axis_text_labels <- function(p, labels = c("Alpha", "Beta", "Gamma")) {
  grob <- if (inherits(p, "patchwork")) {
    patchwork::patchworkGrob(p)
  } else ggplot2::ggplotGrob(p)
  result <- axis_text_grobs(grob)
  result[result$label %in% labels, , drop = FALSE]
}

test_that("axis text justification works without supplying a rotation", {
  p <- axis_text_plot()
  for (size in list(NULL, 15)) {
    q <- fmt_axisText(p, x_hjust = 0.2, x_vjust = 0.3,
                        y_hjust = 0.8, y_vjust = 0.9, size = size)
    x <- axis_text_labels(q)
    y <- axis_text_labels(q, c("Low", "Mid", "High"))
    expect_equal(x$hjust, rep(0.2, 3))
    expect_equal(x$vjust, rep(0.3, 3))
    expect_equal(y$hjust, rep(0.8, 3))
    expect_equal(y$vjust, rep(0.9, 3))
    expect_equal(c(x$angle, y$angle), rep(0, 6))
  }
  p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30))
  expect_equal(axis_text_labels(fmt_axisText(p, x_hjust = 0.4))$angle, rep(30, 3))
})

test_that("axis text formatting visits nested data plots and retains containers", {
  p <- axis_text_plot()
  nested <- (p | p) / (p | p)
  annotated <- nested + patchwork::plot_annotation(title = "Keep", tag_levels = "A")
  freed <- patchwork::free(annotated, side = "l")
  for (input in list(annotated, freed, list(A = p | p, B = p | p))) {
    output <- fmt_axisText(input, x = 45)
    leaves <- .to_plot_list(output, recurse = TRUE)$plots
    expect_equal(vapply(leaves, function(z) axis_text_labels(z)$angle[1], numeric(1)),
                   rep(45, 4))
    plots <- if (is.list(output) && !inherits(output, "gg")) output else list(output)
    expect_equal(unlist(lapply(plots, function(z) axis_text_labels(z)$angle),
                          use.names = FALSE),
                   rep(45, 12))
    if (inherits(input, "patchwork")) {
      expect_identical(output$patches$layout, input$patches$layout)
      expect_identical(output$patches$annotation, input$patches$annotation)
      expect_identical(attr(output, "patchwork_free_settings"),
                         attr(input, "patchwork_free_settings"))
    } else expect_identical(names(output), names(input))
  }
})

test_that("axis text formatting preserves insets, spacers and frozen graphics", {
  p <- axis_text_plot()
  inset <- p + patchwork::inset_element(p, 0.6, 0.6, 1, 1)
  expect_equal(axis_text_labels(fmt_axisText(inset, x = 45))$angle,
                 c(rep(45, 3), rep(0, 3)))
  for (fixed in list(patchwork::plot_spacer(), patchwork::guide_area(),
                      patchwork::wrap_elements(full = p))) {
    input <- list(plot = p, fixed = fixed)
    output <- fmt_axisText(input, x = 45)
    expect_identical(output$fixed, fixed)
    expect_equal(axis_text_labels(output$plot)$angle, rep(45, 3))
  }
})

test_that("axis text formatting overrides styled sides and secondary axes", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = c(2, 4, 6)),
                         ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(breaks = 1:3,
      labels = c("Alpha", "Beta", "Gamma"),
      sec.axis = ggplot2::dup_axis(labels = c("AlphaS", "BetaS", "GammaS"))) +
    ggplot2::scale_y_continuous(breaks = c(2, 4, 6),
      labels = c("Low", "Mid", "High"),
      sec.axis = ggplot2::dup_axis(labels = c("LowS", "MidS", "HighS"))) +
    ggplot2::theme_classic()
  names <- c("axis.text.x.bottom", "axis.text.x.top",
               "axis.text.y.left", "axis.text.y.right")
  element <- ggplot2::element_text(angle = 0, size = 9, colour = "red",
                                    margin = ggplot2::margin(3, 4, 5, 6))
  p <- p + do.call(ggplot2::theme, stats::setNames(rep(list(element), 4), names))
  q <- fmt_axisText(p, x = 45, y = -30, color = "blue", size = 16)
  x <- axis_text_labels(q, c("Alpha", "Beta", "Gamma", "AlphaS", "BetaS", "GammaS"))
  y <- axis_text_labels(q, c("Low", "Mid", "High", "LowS", "MidS", "HighS"))
  expect_equal(x$angle, rep(45, 6))
  expect_equal(y$angle, rep(-30, 6))
  expect_equal(c(x$colour, y$colour), rep("blue", 12))
  expect_equal(c(x$size, y$size), rep(16, 12))
  expect_identical(q$theme$axis.text.x.bottom$margin, element$margin)
  hidden <- fmt_axis(p, x.axis = TRUE)
  expect_equal(nrow(axis_text_labels(fmt_axisText(hidden, x = 45))), 0L)
})

test_that("axis text formatting overrides explicit radial styles", {
  skip_if_not(exists("coord_radial", asNamespace("ggplot2")))
  element <- ggplot2::element_text(angle = 0, colour = "red", size = 9)
  for (theta in c("x", "y")) {
    p <- axis_text_plot() + ggplot2::coord_radial(theta = theta) +
      ggplot2::theme(axis.text.theta = element, axis.text.r = element)
    q <- fmt_axisText(p, x = 45, y = -30, color = "blue", size = 16)
    angular <- if (theta == "x") c("Alpha", "Beta", "Gamma") else c("Low", "Mid", "High")
    radial <- if (theta == "x") c("Low", "Mid", "High") else c("Alpha", "Beta", "Gamma")
    x <- axis_text_labels(q, angular)
    y <- axis_text_labels(q, radial)
    expect_equal(x$angle, rep(45, 3))
    expect_equal(y$angle, rep(-30, 3))
    expect_equal(c(x$colour, y$colour), rep("blue", 6))
    expect_equal(c(x$size, y$size), rep(16, 6))
  }
})

test_that("axis text formatting respects guide locations and retains their settings", {
  p <- axis_text_plot()
  guide <- ggplot2::guide_axis(angle = 90, n.dodge = 2, cap = "both",
    minor.ticks = TRUE, theme = ggplot2::theme(
      axis.text.x.bottom = ggplot2::element_text(angle = 0, colour = "red", size = 9),
      axis.text.y.left = ggplot2::element_text(angle = 0, colour = "red", size = 9)))
  original <- guide$params
  inputs <- list(p + ggplot2::guides(x = guide, y = guide),
    p + ggplot2::scale_x_discrete(guide = guide) +
      ggplot2::scale_y_continuous(breaks = c(2, 4, 6),
        labels = c("Low", "Mid", "High"), guide = guide))
  for (input in inputs) {
    q <- fmt_axisText(input, x = 45, y = -30, color = "blue", size = 16)
    x <- axis_text_labels(q)
    y <- axis_text_labels(q, c("Low", "Mid", "High"))
    expect_equal(x$angle, rep(45, 3))
    expect_equal(y$angle, rep(-30, 3))
    expect_equal(c(x$colour, y$colour), rep("blue", 6))
    expect_equal(c(x$size, y$size), rep(16, 6))
    result <- if (length(q$guides$guides)) q$guides$guides$x else q$scales$get_scales("x")$guide
    expect_identical(result$params[c("n.dodge", "cap", "minor.ticks")],
                       original[c("n.dodge", "cap", "minor.ticks")])
    expect_identical(guide$params, original)
  }
  for (input in inputs) {
    q <- fmt_axisText(input + ggplot2::coord_flip(), x = 45, y = -30)
    expect_equal(axis_text_labels(q)$angle, rep(-30, 3))
    expect_equal(axis_text_labels(q, c("Low", "Mid", "High"))$angle, rep(45, 3))
  }
})

test_that("axis text formatting handles secondary guide angles and justification alone", {
  guide <- ggplot2::guide_axis(angle = 90)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = c(2, 4, 6)),
                         ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(breaks = 1:3,
      labels = c("Alpha", "Beta", "Gamma"),
      sec.axis = ggplot2::dup_axis(labels = c("AlphaS", "BetaS", "GammaS"), guide = guide)) +
    ggplot2::theme_classic()
  q <- fmt_axisText(p, x = 45)
  expect_equal(axis_text_labels(q, c("Alpha", "Beta", "Gamma", "AlphaS", "BetaS", "GammaS"))$angle,
                 rep(45, 6))
  p <- axis_text_plot() + ggplot2::guides(x = guide)
  labels <- axis_text_labels(fmt_axisText(p, x_hjust = 0.2))
  expect_equal(labels$angle, rep(90, 3))
  expect_equal(labels$hjust, rep(0.2, 3))
  expect_equal(axis_text_labels(fmt_axisText(p, color = "blue"))$angle, rep(90, 3))
})

test_that("axis text formatting updates radial guide themes for either mapping", {
  skip_if_not(exists("coord_radial", asNamespace("ggplot2")))
  theme <- ggplot2::theme(
    axis.text.theta = ggplot2::element_text(angle = 0, colour = "red"),
    axis.text.r = ggplot2::element_text(angle = 0, colour = "red"))
  for (theta in c("x", "y")) {
    p <- axis_text_plot() + ggplot2::coord_radial(theta = theta) +
      ggplot2::guides(theta = ggplot2::guide_axis_theta(theme = theme),
                       r = ggplot2::guide_axis(theme = theme))
    q <- fmt_axisText(p, x = 45, y = -30, color = "blue")
    angular <- if (theta == "x") c("Alpha", "Beta", "Gamma") else c("Low", "Mid", "High")
    radial <- if (theta == "x") c("Low", "Mid", "High") else c("Alpha", "Beta", "Gamma")
    expect_equal(axis_text_labels(q, angular)$angle, rep(45, 3))
    expect_equal(axis_text_labels(q, radial)$angle, rep(-30, 3))
    expect_equal(axis_text_labels(q, c(angular, radial))$colour, rep("blue", 6))
  }
})

test_that("axis text formatting retains rich text elements and hidden parents", {
  skip_if_not_installed("ggtext")
  p <- axis_text_plot() + ggplot2::scale_x_discrete(
    labels = function(x) paste0("<b>", x, "</b>"))
  element <- ggtext::element_markdown(size = 10, padding = ggplot2::margin(1, 2, 3, 4),
                                       lineheight = 1.4)
  for (name in c("axis.text.x", "axis.text.x.bottom")) {
    input <- p + do.call(ggplot2::theme, stats::setNames(list(element), name))
    expect_no_error(ggplot2::ggplotGrob(input))
    output <- fmt_axisText(input, x = 45, size = 16, color = "blue")
    expect_s3_class(output$theme[[name]], "element_markdown")
    expect_identical(output$theme[[name]]$padding, element$padding)
    expect_equal(output$theme[[name]]$lineheight, 1.4)
    expect_no_error(ggplot2::ggplotGrob(output))
    expect_identical(input$theme[[name]]$angle, element$angle)
  }
  theme <- ggplot2::theme(axis.text.x = element)
  input <- p + ggplot2::guides(x = ggplot2::guide_axis(theme = theme))
  output <- fmt_axisText(input, x = 45)
  expect_s3_class(output$guides$guides$x$params$theme$axis.text.x, "element_markdown")
  expect_no_error(ggplot2::ggplotGrob(output))
  for (name in c("axis.text.x", "axis.text.x.bottom")) {
    input <- axis_text_plot() + do.call(ggplot2::theme,
      stats::setNames(list(ggplot2::element_blank()), name))
    expect_equal(nrow(axis_text_labels(fmt_axisText(input, x = 45, size = 16))), 0L)
  }
  input <- axis_text_plot() + ggplot2::theme(
    axis.text.x = ggplot2::element_text(size = ggplot2::rel(0.8)))
  expect_equal(axis_text_labels(fmt_axisText(input, x = 45))$size,
                 axis_text_labels(input)$size)
})
