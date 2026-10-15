test_that("reference positions reject geom intercept argument names", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()

  expect_error(fmt_ref(p, xintercept = 2), "xintercept")
  expect_error(fmt_ref(p, yintercept = 2), "yintercept")
  expect_error(fmt_ref(p, x = 2, xintercept = 3), "Use.*x")
  expect_error(fmt_plot(p, fmt_ref_list = list(yintercept = 2)), "yintercept")
})

test_that("colour arguments direct callers to the supported color parameter", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (args in list(list(x = 2, colour = "red"),
                    list(x = 2, color = "blue", colour = "red"),
                    list(colour = "red"), list(x = 2, colour = NULL))) {
    expect_error(do.call(fmt_ref, c(list(plot = p), args)), "Use.*color.*colour")
  }
  expect_error(fmt_plot(p, fmt_ref_list = list(x = 2, colour = "red")), "Use.*color")
  expect_no_warning(result <- fmt_ref(p, x = 2, color = "red"))
  expect_equal(as.character(ggplot2::ggplot_build(result)$data[[2]]$colour), "red")
})

test_that("reference positions add vertical and horizontal lines", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  result <- fmt_ref(p, x = 2, y = 1)
  data <- ggplot2::ggplot_build(result)$data

  expect_equal(data[[2]]$xintercept, 2)
  expect_equal(data[[3]]$yintercept, 1)
  expect_equal(data[[1]], ggplot2::ggplot_build(p)$data[[1]])
  expect_length(p$layers, 1L)
})

test_that("multiple references share layers without changing per-line styles", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 5:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  result <- fmt_ref(p, x = c(2, 3, 4), y = c(1, 5),
                    color = c("red", "blue"), linetype = c("solid", "dashed"),
                    linewidth = c(0.3, 0.8), alpha = c(0.4, 0.9))
  expect_length(result$layers, 3L)
  data <- ggplot2::ggplot_build(result)$data
  expect_equal(data[[2]]$xintercept, c(2, 3, 4))
  expect_equal(as.character(data[[2]]$colour), c("red", "blue", "red"))
  expect_equal(as.character(data[[2]]$linetype), c("solid", "dashed", "solid"))
  expect_equal(as.numeric(data[[2]]$linewidth), c(0.3, 0.8, 0.3))
  expect_equal(as.numeric(data[[2]]$alpha), c(0.4, 0.9, 0.4))
  expect_equal(data[[3]]$yintercept, c(1, 5))
  expect_equal(as.character(data[[3]]$colour), c("red", "blue"))
  expect_equal(result$scales$scales, p$scales$scales)
})

test_that("reference styles survive facet replication", {
  p <- ggplot2::ggplot(data.frame(x = 1:6, y = 6:1, facet = rep(c("A", "B"), 3)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(~facet)
  result <- fmt_ref(p, x = c(2, 4), color = c("red", "blue"))
  expect_length(result$layers, 2L)
  data <- ggplot2::ggplot_build(result)$data[[2]]
  for (panel in unique(data$PANEL)) {
    rows <- data[data$PANEL == panel, ]
    expect_equal(rows$xintercept, c(2, 4))
    expect_equal(as.character(rows$colour), c("red", "blue"))
  }
})

test_that("extra geom arguments retain native reference-line behaviour", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 5:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  expected <- p + ggplot2::geom_vline(xintercept = 2, colour = "red", linetype = "dashed",
                                     linewidth = 0.5, alpha = 0.8, lineend = "round") +
    ggplot2::geom_vline(xintercept = 4, colour = "blue", linetype = "dashed",
                        linewidth = 0.5, alpha = 0.8, lineend = "round")
  result <- fmt_ref(p, x = c(2, 4), color = c("red", "blue"), lineend = "round")
  expect_equal(ggplot2::ggplot_build(result)$data,
               ggplot2::ggplot_build(expected)$data)
})

test_that("batched references render like native lines across plot layouts", {
  skip_if_not_installed("ragg")
  capture_plot <- function(q) {
    capture <- ragg::agg_capture(width = 700, height = 480, res = 100)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(q)
    capture(native = TRUE)
  }
  add_native <- function(q, x) {
    for (i in seq_along(x)) {
      q <- q + ggplot2::geom_vline(xintercept = x[i], colour = c("red", "blue", "red")[i],
                                   linetype = c("solid", "dashed", "solid")[i],
                                   linewidth = c(0.3, 0.8, 0.3)[i], alpha = c(0.4, 0.9, 0.4)[i])
    }
    q + ggplot2::geom_hline(yintercept = 3, colour = "red", linetype = "solid",
                             linewidth = 0.3, alpha = 0.4)
  }
  d <- data.frame(x = 1:6, y = 6:1, facet = rep(c("A", "B"), 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = facet)) + ggplot2::geom_point()
  fixtures <- list(single = p, facet = p + ggplot2::facet_wrap(~facet),
                   flipped = p + ggplot2::coord_flip(), duplicate = p,
                   continuous = ggplot2::ggplot(d, ggplot2::aes(x, y, colour = x)) +
                     ggplot2::geom_point(),
                   nested = (p | patchwork::plot_spacer()) / (p | p))
  for (name in names(fixtures)) {
    x <- if (name == "duplicate") c(3, 3, 3) else c(2, 3, 4)
    expected <- if (name == "nested") {
      (add_native(p, x) | patchwork::plot_spacer()) / (add_native(p, x) | add_native(p, x))
    } else add_native(fixtures[[name]], x)
    result <- fmt_ref(fixtures[[name]], x = x, y = 3, color = c("red", "blue"),
                      linetype = c("solid", "dashed"), linewidth = c(0.3, 0.8),
                      alpha = c(0.4, 0.9))
    expect_identical(capture_plot(result), capture_plot(expected), info = name)
  }
})
