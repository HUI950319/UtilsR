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

test_that("fmt_plot() rejects arguments it does not have", {
  p <- plot_fixture()
  expect_error(fmt_plot(p, fmt_strip_list = list(label = "A")), "unused argument")
  expect_error(fmt_plot(p, plot_margin = 4), "unused argument")
})

test_that("fmt_plot_base() applies scale settings through fmt_scale()", {
  d <- data.frame(x = 1:3, y = c(2, 4, 3), g = c("a", "b", "c"))
  p_con <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  p_dis <- ggplot2::ggplot(d, ggplot2::aes(g, y)) + ggplot2::geom_col()

  # A discrete axis keeps a discrete scale instead of failing to build.
  res <- fmt_plot_base(p_con | p_dis, scale_x_list = list(expand = c(0, 0)))
  expect_no_error(built <- ggplot2::ggplot_build(res[[2]]))
  expect_s3_class(built$layout$panel_scales_x[[1]], "ScaleDiscrete")

  # An existing scale keeps the settings the list leaves out, without messages.
  p_log <- p_con + ggplot2::scale_y_log10()
  expect_no_message(res <- fmt_plot_base(p_log | p_log, scale_y_list = list(limits = c(1, 10))))
  native <- (p_con + ggplot2::scale_y_log10(limits = c(1, 10)))$scales$get_scales("y")
  for (i in 1:2) {
    sc <- res[[i]]$scales$get_scales("y")
    expect_identical(sc$trans$name, "log-10")
    expect_equal(sc$limits, native$limits)
  }

  res <- fmt_plot_base(list(p_con, p_con), scale_y_list = list(limits = c(0, 5)))
  expect_length(res, 2L)
  expect_equal(res[[2]]$scales$get_scales("y")$limits, c(0, 5))
})
