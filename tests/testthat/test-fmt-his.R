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

test_that("each facet keeps its own ranges and overlay height", {
  d <- data.frame(x = c(rep(1:3, c(1, 2, 3)), rep(101:103, c(3, 2, 1))),
                  y = c(rep(c(1, 2, 3), c(1, 2, 3)), rep(c(101, 102, 103), c(3, 2, 1))),
                  panel = rep(c("A", "B"), each = 6))
  for (scales in c("fixed", "free_x", "free_y", "free")) {
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
      ggplot2::facet_wrap(~panel, scales = scales)
    before <- ggplot2::ggplot_build(p)
    for (type in c("h", "d")) {
      q <- suppressMessages(fmt_his(p, type = type, binwidth = 1))
      after <- ggplot2::ggplot_build(q)
      expect_identical(after$data[[1L]], before$data[[1L]])
      for (i in seq_along(before$layout$panel_params)) {
        pp <- before$layout$panel_params[[i]]
        expect_equal(after$layout$panel_params[[i]]$x.range, pp$x.range)
        expect_equal(after$layout$panel_params[[i]]$y.range, pp$y.range)
        overlay <- after$data[[2L]][as.integer(after$data[[2L]]$PANEL) == i, ]
        expect_equal(unique(overlay$ymin), pp$y.range[[1L]])
        expect_equal(max(overlay$ymax), pp$y.range[[1L]] + diff(pp$y.range) * 0.3)
      }
      expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    }
    expect_s3_class(p$facet, "FacetWrap")
    expect_false(inherits(p$facet, "FacetHis"))
  }
})

test_that("external samples are counted without retraining the original axes", {
  p <- his_test_plot()
  before <- ggplot2::ggplot_build(p)
  d <- data.frame(x = rep(100:102, c(10, 20, 30)))
  after <- his_test_build(p, data = d, con_var = "x", binwidth = 1)
  expect_equal(sum(after$data[[2L]]$count), 60)
  expect_equal(after$layout$panel_params[[1L]]$x.range, c(0.5, 3.5))
  expect_equal(after$layout$panel_params[[1L]]$y.range, c(0, 10))
  expect_identical(after$data[[1L]], before$data[[1L]])
})

test_that("distribution overlays do not inherit grouping or weights", {
  d <- rbind(transform(his_test_plot()$data, g = "A", weight = 10),
             transform(his_test_plot()$data, g = "B", weight = 20))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = g, colour = g, weight = weight)) +
    ggplot2::geom_point() + ggplot2::coord_cartesian(ylim = c(0, 10), expand = FALSE)
  for (type in c("h", "d")) {
    overlay <- his_test_build(p, type = type, binwidth = 1)$data[[2L]]
    expect_length(unique(overlay$group), 1L)
    expect_equal(max(overlay$ymax), 3)
    if (type == "h") expect_equal(sum(overlay$count), 120)
    else expect_equal(unique(overlay$n), 120)
    external <- his_test_build(p, type = type, data = d["x"], con_var = "x", binwidth = 1)
    expect_identical(external$data[[1L]], ggplot2::ggplot_build(p)$data[[1L]])
    expect_length(unique(external$data[[2L]]$group), 1L)
  }
})

test_that("nested patchworks format every leaf while retaining layout", {
  p <- his_test_plot()
  pw <- ((p / p) | p) + patchwork::plot_annotation(title = "Combined")
  q <- suppressMessages(fmt_his(pw, binwidth = 1))
  expect_length(q[[1L]][[1L]]$layers, 2L)
  expect_length(q[[1L]][[2L]]$layers, 2L)
  expect_length(q[[2L]]$layers, 2L)
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  expect_identical(q[[1L]]$patches$layout, pw[[1L]]$patches$layout)
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
  expect_length(p$layers, 1L)
})

test_that("patchwork placeholders and named plot lists retain their structure", {
  p <- his_test_plot()
  for (placeholder in list(patchwork::plot_spacer(),
                           patchwork::wrap_elements(grid::textGrob("Note")))) {
    q <- suppressMessages(fmt_his(p | placeholder, binwidth = 1))
    expect_length(q[[1L]]$layers, 2L)
    expect_identical(class(q[[2L]]), class(placeholder))
    expect_s3_class(patchwork::patchworkGrob(q), "gtable")
  }
  q <- suppressMessages(fmt_his(list(first = p, second = p), binwidth = 1))
  expect_identical(names(q), c("first", "second"))
  expect_equal(vapply(q, function(x) length(x$layers), integer(1)), c(first = 2L, second = 2L))
})
