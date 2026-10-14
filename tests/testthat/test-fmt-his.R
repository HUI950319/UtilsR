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

test_that("distribution fills start at their requested baseline", {
  for (bounds in list(c(-5, 5), c(5, 15))) {
    for (type in c("h", "d")) {
      layer <- his_test_build(his_test_plot(bounds), type = type, binwidth = 1)$data[[2L]]
      expect_equal(layer$ymin, rep(bounds[[1L]], nrow(layer)))
      expect_equal(max(layer$ymax), bounds[[1L]] + 3)
      expect_true(all(layer$ymax > layer$ymin))
    }
  }
  layer <- his_test_build(his_test_plot(), binwidth = 1, y_rescale = c(2, 6))$data[[2L]]
  expect_equal(layer$ymin, rep(2, 3))
  expect_equal(layer$ymax, c(10 / 3, 14 / 3, 6))
  for (type in c("h", "d")) {
    q <- suppressMessages(fmt_his(his_test_plot(c(-5, 5)), type = type, binwidth = 1))
    expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
  }
})

test_that("overlays preserve transformed axes and original coordinates", {
  d <- data.frame(x = 10^seq(0, 3, length.out = 60), y = 10^seq(1, 3, length.out = 60))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(p + ggplot2::scale_x_log10(), p + ggplot2::scale_y_log10(),
                p + ggplot2::scale_y_reverse(), p + ggplot2::coord_flip(clip = "off"),
                p + ggplot2::coord_fixed(ratio = 2))
  for (plot in plots) {
    before <- ggplot2::ggplot_build(plot)
    for (type in c("h", "d")) {
      q <- suppressMessages(fmt_his(plot, type = type))
      after <- ggplot2::ggplot_build(q)
      expect_equal(after$layout$panel_params[[1L]]$x.range, before$layout$panel_params[[1L]]$x.range)
      expect_equal(after$layout$panel_params[[1L]]$y.range, before$layout$panel_params[[1L]]$y.range)
      expect_identical(after$data[[1L]], before$data[[1L]])
      expect_identical(class(q$coordinates), class(plot$coordinates))
      expect_identical(q$coordinates$ratio, plot$coordinates$ratio)
      expect_identical(q$coordinates$clip, plot$coordinates$clip)
      native_y <- if (inherits(plot$coordinates, "CoordFlip"))
        before$layout$panel_params[[1L]]$x.range else before$layout$panel_params[[1L]]$y.range
      overlay <- after$data[[2L]]
      expect_equal(min(overlay$ymin), native_y[[1L]])
      expect_equal(max(overlay$ymax), native_y[[1L]] + diff(native_y) * 0.3)
      expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    }
  }
})
