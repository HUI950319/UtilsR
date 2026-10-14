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

test_that("distribution mappings support data pronouns and expressions", {
  d <- his_test_plot()$data
  for (mapping in list(ggplot2::aes(.data[["x"]], y), ggplot2::aes(.data$x, y))) {
    p <- ggplot2::ggplot(d, mapping) + ggplot2::geom_point()
    bars <- his_test_build(p, binwidth = 1)$data[[2L]]
    expect_equal(bars$count, c(10, 20, 30))
    expect_equal(bars$x, 1:3)
  }
  d$x <- exp(d$x - 1)
  p <- ggplot2::ggplot(d, ggplot2::aes(log(x), y)) + ggplot2::geom_point()
  bars <- his_test_build(p, binwidth = 1)$data[[2L]]
  expect_equal(bars$x, 0:2)
  expect_equal(bars$count, c(10, 20, 30))
  offset <- 5
  p <- ggplot2::ggplot(d, ggplot2::aes(log(x) + .env$offset, y)) + ggplot2::geom_point()
  bars <- his_test_build(p, binwidth = 1)$data[[2L]]
  expect_equal(bars$x, 5:7)
  expect_equal(bars$count, c(10, 20, 30))
})

test_that("distribution data and mappings fall back to applicable layers", {
  d <- his_test_plot()$data
  plots <- list(
    ggplot2::ggplot(d) + ggplot2::geom_point(ggplot2::aes(x, y)),
    ggplot2::ggplot(mapping = ggplot2::aes(x, y)) + ggplot2::geom_point(data = d),
    ggplot2::ggplot() + ggplot2::geom_point(data = d, ggplot2::aes(x, y)))
  for (p in plots) {
    before <- ggplot2::ggplot_build(p)$data[[1L]]
    after <- his_test_build(p, binwidth = 1)
    expect_equal(after$data[[2L]]$count, c(10, 20, 30))
    expect_identical(after$data[[1L]], before)
    expect_length(p$layers, 1L)
  }
})

test_that("layer data fallback skips annotations and missing requested columns", {
  d <- his_test_plot()$data
  x <- 2
  plots <- list(
    ggplot2::ggplot() + ggplot2::geom_hline(yintercept = 0) +
      ggplot2::geom_point(data = d, ggplot2::aes(x, y)),
    ggplot2::ggplot(mapping = ggplot2::aes(x, y)) +
      ggplot2::geom_hline(yintercept = 0) + ggplot2::geom_point(data = d))
  for (p in plots) {
    before <- ggplot2::ggplot_build(p)
    for (con_var in list(NULL, "x")) {
      for (type in c("h", "d")) {
        after <- his_test_build(p, type = type, con_var = con_var, binwidth = 1)
        overlay <- after$data[[3L]]
        if (type == "h") expect_equal(overlay$count, c(10, 20, 30))
        else expect_equal(unique(overlay$n), 60)
        expect_identical(after$data[1:2], before$data)
      }
    }
    expect_length(p$layers, 2L)
  }
  p <- ggplot2::ggplot() + ggplot2::geom_point(data = d, ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = transform(d, z = x), ggplot2::aes(z, y))
  expect_equal(his_test_build(p, con_var = "z", binwidth = 1)$data[[3L]]$count,
               c(10, 20, 30))
})

test_that("annotation fallback keeps function and formula data lazy", {
  d <- his_test_plot()$data
  for (formula in c(FALSE, TRUE)) {
    calls <- 0L
    callback <- if (formula) ~{ calls <<- calls + 1L; d } else
      function(data) { calls <<- calls + 1L; d }
    p <- ggplot2::ggplot(mapping = ggplot2::aes(x, y)) +
      ggplot2::geom_hline(yintercept = 0) + ggplot2::geom_point(data = callback)
    q <- fmt_his(p, binwidth = 1)
    expect_equal(calls, 0L)
    built <- ggplot2::ggplot_build(q)
    expect_equal(calls, 2L)
    expect_equal(built$data[[3L]]$count, c(10, 20, 30))
  }
})

test_that("overlay controls reject unknown names and invalid numeric values", {
  p <- his_test_plot()
  expect_error(fmt_his(p, binwdith = 1), "binwdith")
  expect_error(fmt_his(p, binwidth = 1, binwidth = 2), "unique")
  expect_error(fmt_his(p, type = "h", height_ratio = 0.3, data = NULL, con_var = NULL, 1), "named")
  for (value in list(-0.1, 1.1, NA_real_, Inf, c(0.2, 0.3), "0.3", NULL))
    expect_error(fmt_his(p, height_ratio = value), "height_ratio")
  for (value in list(0, -1, NA_real_, Inf, c(1, 2), "1")) {
    expect_error(fmt_his(p, binwidth = value), "binwidth")
    expect_error(fmt_his(p, type = "d", adjust = value), "adjust")
  }
  for (value in list(-0.1, 1.1, NA_real_, Inf, c(0.2, 0.3), "0.5"))
    expect_error(fmt_his(p, his_alpha = value), "his_alpha")
  for (value in list("invalid-colour", c("red", "blue")))
    expect_error(fmt_his(p, his_color = value), "his_color")
  for (value in list(1, c(1, 2, 3), c(NA_real_, 2), c(1, Inf), "1"))
    expect_error(fmt_his(p, y_rescale = value), "y_rescale")
  for (value in list(1, c(1, 2, 3), c(1, Inf), "1"))
    expect_error(fmt_his(p, ylim = value), "ylim")
  for (value in list("", NA_character_, c("x", "y"), 1))
    expect_error(fmt_his(p, con_var = value), "con_var")
  expect_error(fmt_his(p, data = list(x = 1:3)), "data")
})

test_that("nullable defaults and mode-specific controls remain compatible", {
  p <- his_test_plot()
  for (type in c("h", "d")) {
    default <- his_test_build(p, type = type)$data[[2L]]
    nullable <- his_test_build(p, type = type, binwidth = NULL, adjust = NULL,
                              his_color = NULL, his_alpha = NULL, y_rescale = NULL, ylim = NULL)$data[[2L]]
    expect_identical(nullable, default)
  }
  expect_equal(sum(his_test_build(p, binwidth = function(x) 1)$data[[2L]]$count), 60)
  expect_equal(his_test_build(p, type = "h", adjust = 0, binwidth = 1)$data[[2L]]$count, c(10, 20, 30))
  expect_equal(his_test_build(p, type = "d", binwidth = 0)$data[[2L]]$n, rep(60, 512))
  q <- suppressMessages(fmt_his(p, binwidth = 1, ylim = c(NA, 12)))
  expect_equal(ggplot2::ggplot_build(q)$layout$panel_params[[1L]]$y.range[[2L]], 12)
})

test_that("formatting defers original statistics until one display build", {
  calls <- 0L
  summarize <- function(y) { calls <<- calls + 1L; mean(y) }
  p <- ggplot2::ggplot(his_test_plot()$data, ggplot2::aes(x = 1, y = y)) +
    ggplot2::stat_summary(fun = summarize, geom = "point")
  q <- suppressMessages(fmt_his(p, con_var = "x", binwidth = 1))
  expect_equal(calls, 0L)
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
  expect_equal(calls, 1L)
  expect_length(p$layers, 1L)
})

test_that("function and formula data remain lazy during formatting", {
  d <- his_test_plot()$data
  for (formula in c(FALSE, TRUE)) {
    calls <- 0L
    callback <- if (formula) ~{ calls <<- calls + 1L; d } else
      function(data) { calls <<- calls + 1L; d }
    p <- ggplot2::ggplot() + ggplot2::geom_point(data = callback, ggplot2::aes(x, y))
    q <- suppressMessages(fmt_his(p, binwidth = 1))
    expect_equal(calls, 0L)
    built <- ggplot2::ggplot_build(q)
    expect_equal(calls, 2L)
    expect_equal(built$data[[2L]]$count, c(10, 20, 30))
  }
})

test_that("overlay heights follow later scale and coordinate changes", {
  q <- suppressMessages(fmt_his(his_test_plot(), binwidth = 1))
  q <- suppressMessages(q + ggplot2::coord_cartesian(ylim = c(-5, 15), expand = FALSE))
  bars <- ggplot2::ggplot_build(q)$data[[2L]]
  expect_equal(bars$ymin, rep(-5, 3))
  expect_equal(bars$ymax, c(-3, -1, 1))
  q <- fmt_his(his_test_plot(), binwidth = 1) + ggplot2::scale_y_reverse()
  bars <- ggplot2::ggplot_build(q)$data[[2L]]
  # Older ggplot2 retains decreasing coordinate ranges under a reverse scale.
  reference <- ggplot2::ggplot_build(his_test_plot() + ggplot2::scale_y_reverse())
  range <- reference$layout$panel_params[[1L]]$y.range
  expect_equal(bars$ymin, rep(range[[1L]], 3))
  expect_equal(bars$ymax, range[[1L]] + diff(range) * c(0.1, 0.2, 0.3))
})

test_that("repeated calls retain independent overlay settings", {
  p <- his_test_plot()
  q <- suppressMessages(fmt_his(p, type = "h", binwidth = 1, height_ratio = 0.2))
  q <- suppressMessages(fmt_his(q, type = "d", height_ratio = 0.5))
  built <- ggplot2::ggplot_build(q)
  expect_length(q$layers, 3L)
  expect_equal(max(built$data[[2L]]$ymax), 2)
  expect_equal(max(built$data[[3L]]$ymax), 5)
  expect_equal(built$layout$panel_params[[1L]]$y.range, c(0, 10))
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
  expect_length(p$layers, 1L)
})

test_that("sparse and empty distribution panels preserve the original plot", {
  p <- his_test_plot()
  before <- ggplot2::ggplot_build(p)
  for (type in c("h", "d")) {
    for (x in list(numeric(), rep(NA_real_, 3), 1)) {
      warnings <- character()
      q <- fmt_his(p, type = type, data = data.frame(x = x), binwidth = 1)
      built <- withCallingHandlers(ggplot2::ggplot_build(q), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      })
      expect_false(any(grepl("Computation failed", warnings, fixed = TRUE)))
      expect_identical(built$data[[1L]], before$data[[1L]])
      expect_equal(built$layout$panel_params[[1L]]$y.range, c(0, 10))
      expect_s3_class(suppressWarnings(ggplot2::ggplotGrob(q)), "gtable")
    }
  }
  d <- data.frame(x = c(1, 2, 3, 1), y = c(1, 2, 3, 5),
                  panel = c("A", "A", "A", "B"))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(~panel, scales = "free")
  built <- suppressWarnings(his_test_build(p, type = "d", adjust = 1))
  curve <- built$data[[2L]]
  expect_true(any(is.finite(curve$y[as.integer(curve$PANEL) == 1L])))
  expect_false(any(is.finite(curve$y[as.integer(curve$PANEL) == 2L])))
  expect_identical(built$data[[1L]], ggplot2::ggplot_build(p)$data[[1L]])
})

test_that("distribution layers survive facets added after formatting", {
  d <- data.frame(x = c(rep(1:3, c(1, 2, 3)), rep(101:103, c(3, 2, 1))),
                  y = c(rep(1:3, c(1, 2, 3)), rep(101:103, c(3, 2, 1))),
                  panel = rep(c("A", "B"), each = 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (type in c("h", "d")) {
    for (scales in c("fixed", "free")) {
      facet <- ggplot2::facet_wrap(~panel, scales = scales)
      before <- his_test_build(p + facet, type = type, binwidth = 1)
      q <- fmt_his(p, type = type, binwidth = 1) + facet
      after <- ggplot2::ggplot_build(q)
      expect_identical(after$data[[1L]], before$data[[1L]])
      expect_equal(after$data[[2L]], before$data[[2L]])
      expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    }
  }
  q <- fmt_his(p, type = "h", height_ratio = 0.2, binwidth = 1) +
    ggplot2::facet_grid(. ~ panel)
  q <- fmt_his(q, type = "d", height_ratio = 0.5)
  built <- ggplot2::ggplot_build(q)
  range <- built$layout$panel_params[[1L]]$y.range
  expect_equal(max(built$data[[2L]]$ymax), range[[1L]] + diff(range) * 0.2)
  expect_equal(max(built$data[[3L]]$ymax), range[[1L]] + diff(range) * 0.5)
  expect_false(inherits(p$facet, "FacetHis"))
  expect_length(p$layers, 1L)
})

test_that("coordinate reversal keeps the default baseline at the display bottom", {
  skip_if_not("reverse" %in% names(formals(ggplot2::coord_cartesian)))
  p <- his_test_plot()
  for (type in c("h", "d")) {
    for (reverse in c("x", "y", "xy")) {
      coord <- ggplot2::coord_cartesian(ylim = c(0, 10), expand = FALSE,
                                        reverse = reverse)
      before <- suppressMessages(ggplot2::ggplot_build(p + coord))
      q <- suppressMessages(fmt_his(p, type = type, binwidth = 1) + coord)
      built <- ggplot2::ggplot_build(q)
      curve <- built$data[[2L]]
      view <- q$coordinates$transform(
        data.frame(x = curve$x, y = curve$ymin), built$layout$panel_params[[1L]])
      top <- q$coordinates$transform(
        data.frame(x = curve$x, y = curve$ymax), built$layout$panel_params[[1L]])
      expect_equal(view$y, rep(0, nrow(curve)))
      expect_equal(max(top$y), 0.3)
      expect_identical(built$data[[1L]], before$data[[1L]])
      expect_identical(built$layout$panel_params[[1L]]$y.range,
                       before$layout$panel_params[[1L]]$y.range)
      expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    }
  }
})

test_that("individual facet transforms are applied once to distribution layers", {
  skip_if_not_installed("ggh4x")
  d <- data.frame(x = rep(c(1, 2, 3, 10, 100, 1000), each = 10),
                  y = rep(c(2, 4, 6, 10, 100, 1000), each = 10),
                  panel = rep(c("A", "B"), each = 30))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  facet <- ggplot2::facet_wrap(~panel, scales = "free")
  scales <- ggh4x::facetted_pos_scales(
    x = list(NULL, ggplot2::scale_x_log10()),
    y = list(NULL, ggplot2::scale_y_log10()))
  reference <- ggplot2::ggplot_build(p + facet + scales)
  for (type in c("h", "d")) {
    plots <- list(
      fmt_his(p + facet + scales, type = type, binwidth = 1),
      fmt_his(p + facet, type = type, binwidth = 1) + scales,
      fmt_his(p, type = type, binwidth = 1) + facet + scales)
    for (q in plots) {
      built <- ggplot2::ggplot_build(q)
      expect_identical(built$data[[1L]], reference$data[[1L]])
      curve <- built$data[[2L]][as.integer(built$data[[2L]]$PANEL) == 2L, ]
      expect_equal(range(curve$x), c(1, 3))
      expect_equal(unique(curve$ymin), 0.9)
      expect_equal(max(curve$ymax), 0.9 + 2.2 * 0.3)
      expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    }
    q <- fmt_his(p + facet + scales, type = type, binwidth = 1,
                 y_rescale = c(10, 100))
    curve <- ggplot2::ggplot_build(q)$data[[2L]]
    curve <- curve[as.integer(curve$PANEL) == 2L, ]
    expect_equal(unique(curve$ymin), 1)
    expect_equal(max(curve$ymax), 2)
  }
})

test_that("each distribution layer evaluates its x mapping once per build", {
  for (type in c("h", "d")) {
    calls <- 0L
    map_x <- function(x) {
      calls <<- calls + 1L
      if (calls == 3L) x + 100 else x
    }
    p <- his_test_plot()
    p$mapping <- ggplot2::aes(map_x(x), y)
    q <- fmt_his(p, type = type, binwidth = 1)
    expect_equal(calls, 0L)
    built <- ggplot2::ggplot_build(q)
    expect_equal(calls, 2L)
    expect_equal(range(built$data[[2L]]$x), c(1, 3))
    expect_equal(range(built$data[[1L]]$x), c(1, 3))
  }
})

test_that("internal distribution markers do not alter unrelated mapped fields", {
  p <- his_test_plot()
  p$mapping <- ggplot2::aes(x, y, .fmt_his = 1, .fmt_his_input = 999,
                            .fmt_his_x = 42)
  before <- ggplot2::ggplot_build(p)
  for (type in c("h", "d")) {
    q <- fmt_his(p, type = type, binwidth = 1)
    built <- ggplot2::ggplot_build(q)
    expect_identical(built$data[[1L]], before$data[[1L]])
    expect_equal(built$layout$panel_params[[1L]]$x.range,
                 before$layout$panel_params[[1L]]$x.range)
    expect_equal(built$layout$panel_params[[1L]]$y.range,
                 before$layout$panel_params[[1L]]$y.range)
    expect_equal(range(built$data[[2L]]$x), c(1, 3))
    expect_equal(max(built$data[[2L]]$ymax), 3)
    expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
  }
})

test_that("distribution builds reject non-Cartesian coordinates added later", {
  p <- his_test_plot()
  transformed <- if ("coord_transform" %in% getNamespaceExports("ggplot2"))
    ggplot2::coord_transform(y = "log10") else
      suppressWarnings(ggplot2::coord_trans(y = "log10"))
  for (type in c("h", "d")) {
    q <- fmt_his(p, type = type, binwidth = 1)
    for (coord in list(ggplot2::coord_polar(), transformed)) {
      invalid <- suppressMessages(q + coord)
      expect_error(ggplot2::ggplot_build(invalid),
                   "Distribution overlays require Cartesian coordinates.", fixed = TRUE)
      expect_error(ggplot2::ggplotGrob(invalid),
                   "Distribution overlays require Cartesian coordinates.", fixed = TRUE)
    }
    nested <- suppressMessages((q / (q + ggplot2::coord_polar())) | p)
    expect_error(patchwork::patchworkGrob(nested),
                 "Distribution overlays require Cartesian coordinates.", fixed = TRUE)
    q$layers <- q$layers[!vapply(q$layers, inherits, logical(1), "LayerHis")]
    expect_s3_class(ggplot2::ggplotGrob(suppressMessages(q + ggplot2::coord_polar())), "gtable")
  }
  expect_length(p$layers, 1L)
  expect_s3_class(p$coordinates, "CoordCartesian")
})

test_that("distribution scales transform x samples once per layer", {
  for (type in c("h", "d")) {
    for (external in c(FALSE, TRUE)) {
      p <- his_test_plot()
      samples <- if (external) data.frame(x = rep(c(10, 100, 1000), each = 20)) else NULL
      raw <- if (external) samples$x else p$data$x
      calls <- 0L
      transform_x <- function(x) {
        if (identical(x, raw)) calls <<- calls + 1L
        log10(x)
      }
      trans <- scales::new_transform("counted_log10", transform_x, function(x) 10^x)
      reference <- his_test_build(p + ggplot2::scale_x_log10(), type = type,
                                  data = samples, binwidth = 0.25, adjust = 1)
      q <- fmt_his(p + ggplot2::scale_x_continuous(transform = trans),
                   type = type, data = samples, binwidth = 0.25, adjust = 1)
      expect_equal(calls, 0L)
      built <- ggplot2::ggplot_build(q)
      expect_equal(calls, if (external) 1L else 2L)
      expect_equal(built$data[[1L]], reference$data[[1L]])
      expect_equal(built$data[[2L]], reference$data[[2L]])
    }
  }
})

test_that("unscaled x mappings retain native distribution statistics", {
  p <- his_test_plot()
  p$mapping <- ggplot2::aes(I(x), y)
  reversed <- p
  reversed$mapping <- ggplot2::aes(I(-x), y)
  plots <- list(
    p + ggplot2::scale_x_continuous(limits = c(0, 4)),
    p + ggplot2::scale_x_log10(limits = c(10^(-0.5), 10^3.5)),
    reversed + ggplot2::scale_x_reverse(limits = c(4, 0)))
  for (plot in plots) {
    original <- ggplot2::ggplot_build(plot)
    for (type in c("h", "d")) {
      native <- if (type == "h") ggplot2::geom_histogram(
        ggplot2::aes(y = ggplot2::after_stat(count)), binwidth = 1,
        position = "identity") else ggplot2::geom_density(
          ggplot2::aes(y = ggplot2::after_stat(density)), adjust = 1)
      reference <- ggplot2::ggplot_build(plot + native)$data[[2L]]
      built <- his_test_build(plot, type = type, binwidth = 1, adjust = 1)
      actual <- built$data[[2L]]
      if (type == "h") {
        expect_equal(sum(actual$count), 60)
        fields <- c("x", "count")
      } else {
        expect_equal(unique(actual$n), 60)
        fields <- c("x", "density", "n")
      }
      expect_equal(actual[fields], reference[fields])
      expect_identical(built$data[[1L]], original$data[[1L]])
      expect_equal(built$layout$panel_params[[1L]]$x.range,
                   original$layout$panel_params[[1L]]$x.range)
    }
  }
})

test_that("external densities retain the original statistical domain", {
  p <- his_test_plot()
  samples <- data.frame(x = rep(2:3, c(10, 20)))
  limits <- list(NULL, function(x) range(x) + c(-1, 1),
                 ~range(.x) + c(-1, 1), c(NA, 4))
  for (limit in limits) {
    plot <- p + ggplot2::scale_x_continuous(limits = limit)
    before <- ggplot2::ggplot_build(plot)
    reference <- ggplot2::ggplot_build(plot + ggplot2::geom_density(
      data = samples, ggplot2::aes(x, ggplot2::after_stat(density)),
      inherit.aes = FALSE, adjust = 1))$data[[2L]]
    built <- his_test_build(plot, type = "d", data = samples, adjust = 1)
    fields <- c("x", "density", "n")
    expect_equal(built$data[[2L]][fields], reference[fields])
    expect_identical(built$data[[1L]], before$data[[1L]])
    expect_equal(built$layout$panel_params[[1L]]$x.range,
                 before$layout$panel_params[[1L]]$x.range)
  }
  samples <- data.frame(x = rep(100:102, c(10, 20, 30)))
  built <- his_test_build(p, type = "d", data = samples, adjust = 1)
  expect_equal(range(built$data[[2L]]$x), c(1, 102))
  expect_equal(unique(built$data[[2L]]$n), 60)
  expect_equal(built$layout$panel_params[[1L]]$x.range, c(0.5, 3.5))
})

test_that("histogram limits retain the original resolved endpoints", {
  p <- his_test_plot()
  samples <- data.frame(x = rep(2:3, c(10, 20)))
  for (limit in list(function(x) range(x) + c(-1, 1),
                     ~range(.x) + c(-1, 1), c(NA, 4))) {
    plot <- p + ggplot2::scale_x_continuous(limits = limit)
    reference <- ggplot2::ggplot_build(plot + ggplot2::geom_histogram(
      data = samples, ggplot2::aes(x, ggplot2::after_stat(count)),
      inherit.aes = FALSE, binwidth = 1, position = "identity"))$data[[2L]]
    actual <- his_test_build(plot, data = samples, binwidth = 1)$data[[2L]]
    expect_equal(actual[c("x", "count")], reference[c("x", "count")])
  }
})

test_that("external density domains follow each panel's position scale", {
  d <- rbind(transform(his_test_plot()$data, panel = "A"),
             transform(his_test_plot()$data, x = x + 100, panel = "B"))
  samples <- d[d$x %in% c(2, 3, 102, 103), c("x", "panel")]
  for (scales in c("fixed", "free_x")) {
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
      ggplot2::facet_wrap(~panel, scales = scales)
    before <- ggplot2::ggplot_build(p)
    reference <- ggplot2::ggplot_build(p + ggplot2::geom_density(
      data = samples, ggplot2::aes(x, ggplot2::after_stat(density)),
      inherit.aes = FALSE, adjust = 1))$data[[2L]]
    built <- his_test_build(p, type = "d", data = samples, adjust = 1)
    fields <- c("x", "density", "n", "PANEL")
    expect_equal(built$data[[2L]][fields], reference[fields])
    expect_identical(built$data[[1L]], before$data[[1L]])
    for (i in seq_along(before$layout$panel_params))
      expect_equal(built$layout$panel_params[[i]]$x.range,
                   before$layout$panel_params[[i]]$x.range)
  }
})

test_that("time-difference samples retain native units and statistics", {
  for (units in c("hours", "secs")) {
    d <- his_test_plot()$data
    d$x <- as.difftime(d$x, units = units)
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
    before <- suppressMessages(ggplot2::ggplot_build(p))
    for (type in c("h", "d")) {
      native <- if (type == "h") ggplot2::geom_histogram(
        ggplot2::aes(y = ggplot2::after_stat(count)), binwidth = 1,
        position = "identity") else ggplot2::geom_density(adjust = 1)
      reference <- suppressMessages(ggplot2::ggplot_build(p + native))$data[[2L]]
      built <- suppressMessages(his_test_build(p, type = type, binwidth = 1, adjust = 1))
      fields <- if (type == "h") c("x", "count") else c("x", "density", "n")
      expect_equal(built$data[[2L]][fields], reference[fields])
      expect_identical(built$data[[1L]], before$data[[1L]])
      expect_equal(built$layout$panel_params[[1L]]$x.range,
                   before$layout$panel_params[[1L]]$x.range)
    }
    expect_identical(units(d$x), units)
  }
})

test_that("distribution layers preserve native after-scale x mappings", {
  for (type in c("h", "d")) {
    calls <- 0L
    modify_x <- function(x) { calls <<- calls + 1L; x * 2 }
    p <- his_test_plot()
    p$mapping <- ggplot2::aes(ggplot2::stage(start = x,
      after_scale = modify_x(x)), y)
    native <- if (type == "h") ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(count)), binwidth = 1,
      position = "identity") else ggplot2::geom_density(adjust = 1)
    reference <- ggplot2::ggplot_build(p + native)
    native_calls <- calls
    calls <- 0L
    q <- fmt_his(p, type = type, binwidth = 1, adjust = 1)
    expect_equal(calls, 0L)
    built <- ggplot2::ggplot_build(q)
    expect_equal(calls, native_calls)
    fields <- if (type == "h") c("x", "xmin", "xmax", "count") else
      c("x", "density", "n")
    expect_equal(built$data[[2L]][fields], reference$data[[2L]][fields])
    expect_identical(built$data[[1L]], reference$data[[1L]])
    expect_equal(built$layout$panel_params[[1L]]$x.range,
                 ggplot2::ggplot_build(p)$layout$panel_params[[1L]]$x.range)
  }
})

test_that("unscaled histograms work without an explicit x scale", {
  d <- his_test_plot()$data
  d$x <- d$x / 4
  p <- ggplot2::ggplot(d, ggplot2::aes(I(x), y)) + ggplot2::geom_point() +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, 10), expand = FALSE)
  reference <- suppressWarnings(ggplot2::ggplot_build(p + ggplot2::geom_histogram(
    ggplot2::aes(y = ggplot2::after_stat(count)), binwidth = 0.25,
    position = "identity")))$data[[2L]]
  skip_if(!nrow(reference), "Native ggplot2 does not support this unscaled histogram.")
  before <- ggplot2::ggplot_build(p)
  q <- fmt_his(p, binwidth = 0.25)
  built <- ggplot2::ggplot_build(q)
  expect_equal(built$data[[2L]][c("x", "count")], reference[c("x", "count")])
  expect_equal(sum(built$data[[2L]]$count), 60)
  expect_identical(built$data[[1L]], before$data[[1L]])
  expect_equal(built$layout$panel_params[[1L]]$x.range,
               before$layout$panel_params[[1L]]$x.range)
  expect_null(p$scales$get_scales("x"))
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
})

test_that("histogram overlays retain native discrete-x validation", {
  for (x in list(factor(rep(1:3, each = 20)), rep(c("A", "B", "C"), each = 20),
                 rep(c(TRUE, FALSE), each = 30))) {
    p <- his_test_plot()
    p$data$x <- x
    expect_error(ggplot2::ggplot_build(fmt_his(p, binwidth = 1)), "requires a continuous")
  }
})
