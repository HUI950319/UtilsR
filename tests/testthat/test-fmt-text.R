test_that("fmt_text() collects identical axis titles of a patchwork by default", {
  skip_if_not_installed("patchwork")
  d <- data.frame(x = 1:3, y = c(2, 1, 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(p, p, p, p, ncol = 2)

  out <- fmt_text(pw, xlab = "Days", ylab = "Survival")
  expect_identical(out$patches$layout$axis_titles, "collect")
  expect_identical(out$patches$plots[[1]]$labels$y, "Survival")

  # Partial collection and opting out
  out_y <- fmt_text(pw, ylab = "Survival", axis_titles = "collect_y")
  expect_identical(out_y$patches$layout$axis_titles, "collect_y")
  kept <- patchwork::wrap_plots(p, p, ncol = 2) +
    patchwork::plot_layout(axis_titles = "keep")
  expect_identical(
    fmt_text(kept, ylab = "Survival", axis_titles = NULL)$patches$layout$axis_titles,
    "keep"
  )
})

test_that("fmt_text() axis_titles leaves single plots and lists unchanged", {
  d <- data.frame(x = 1:3, y = c(2, 1, 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  single <- fmt_text(p, ylab = "Survival")
  expect_s3_class(single, "ggplot")
  expect_false(inherits(single, "patchwork"))
  expect_identical(single$labels$y, "Survival")

  lst <- fmt_text(list(p, p), ylab = c("A", "B"))
  expect_type(lst, "list")
  expect_identical(lst[[2]]$labels$y, "B")
})
