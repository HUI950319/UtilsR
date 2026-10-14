his_test_plot <- function(ylim = c(0, 10)) {
  d <- data.frame(x = rep(1:3, c(10, 20, 30)), y = 5)
  ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::coord_cartesian(xlim = c(0.5, 3.5), ylim = ylim, expand = FALSE)
}

his_test_build <- function(plot, ...) {
  ggplot2::ggplot_build(suppressMessages(fmt_his(plot, ...)))
}

test_that("histogram overlays preserve nonzero and equal bin frequencies", {
  p <- his_test_plot()
  bars <- his_test_build(p, binwidth = 1)$data[[2L]]
  expect_equal(bars$count, c(10, 20, 30))
  expect_equal(bars$y, c(1, 2, 3))
  p$data <- data.frame(x = rep(1:3, each = 10), y = 5)
  bars <- his_test_build(p, binwidth = 1)$data[[2L]]
  expect_equal(bars$y, rep(3, 3))
})

test_that("density overlays preserve density ratios", {
  curve <- his_test_build(his_test_plot(), type = "d", adjust = 1)$data[[2L]]
  expect_equal(curve$y, 3 * curve$density / max(curve$density))
  expect_gt(min(curve$y), 0)
})
