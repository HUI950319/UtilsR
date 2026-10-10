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
