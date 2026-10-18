plot_fixture <- function() {
  d <- data.frame(x = 1:3, y = c(2, 4, 3))
  ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
}

test_that("fmt_plot() and fmt_plot_base() format each plot of a plain list", {
  p <- plot_fixture()

  res <- fmt_plot(list(a = p, b = p), plot.margin = 4)
  expect_type(res, "list")
  expect_named(res, c("a", "b"))
  for (q in res) {
    expect_s3_class(q, "ggplot")
    expect_equal(as.numeric(q$theme$plot.margin), rep(4, 4))
  }

  res <- fmt_plot_base(list(p, p | p), ggtheme = ggplot2::theme_bw(),
                       labs_list = list(x = "X"))
  expect_length(res, 2L)
  expect_s3_class(res[[2]], "patchwork")
  expect_identical(ggplot2::get_labs(res[[1]])$x, "X")
  expect_identical(ggplot2::get_labs(res[[2]][[1]])$x, "X")

  expect_error(fmt_plot(list(p, 1), plot.margin = 4), "ggplot")
  expect_error(fmt_plot_base(list(p, 1), labs_list = list(x = "X")), "ggplot")
})
