test_that("expansion preserves continuous scale controls and transformed data", {
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_log10(name = "Dose", limits = c(1, 100),
      breaks = c(1, 10, 100), labels = c("Low", "Mid", "High"),
      position = "top", sec.axis = ggplot2::dup_axis(name = "Secondary dose"))
  original <- p$scales$get_scales("x")
  q <- suppressMessages(fmt_expand(p, mult = 0.1, axis = "x"))
  built <- ggplot2::ggplot_build(q)
  expect_equal(built$data[[1]]$x, c(0, 1, 2))
  expect_equal(built$layout$panel_params[[1]]$x.range, c(-0.2, 2.2))
  expect_identical(built$layout$panel_params[[1]]$x$get_labels(),
                   c("Low", "Mid", "High"))
  scale <- q$scales$get_scales("x")
  expect_identical(scale$name, "Dose")
  expect_identical(scale$position, "top")
  expect_identical(scale$secondary.axis$name, "Secondary dose")
  expect_s3_class(original$expand, "waiver")
  expect_identical(original$trans$name, "log-10")
  expect_null(p$scales$get_scales("y"))
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(p)$data)
})

test_that("expansion preserves discrete ordering and unused levels", {
  p <- ggplot2::ggplot(data.frame(x = factor(c("a", "b", "c")), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_discrete(limits = c("c", "b", "a", "d"),
      breaks = c("c", "a"), labels = c("C label", "A label"), drop = FALSE)
  q <- suppressMessages(fmt_expand(p, add = c(0.5, 0), axis = "x"))
  built <- ggplot2::ggplot_build(q)
  expect_equal(as.numeric(built$data[[1]]$x), c(3, 2, 1))
  expect_equal(built$layout$panel_params[[1]]$x.range, c(0.5, 4))
  expect_identical(built$layout$panel_params[[1]]$x$get_labels(),
                   c("C label", "A label"))
  expect_false(q$scales$get_scales("x")$drop)
  expect_s3_class(p$scales$get_scales("x")$expand, "waiver")
})

test_that("expansion preserves binned position scales", {
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_binned(breaks = c(1, 10, 100))
  q <- suppressMessages(fmt_expand(p, mult = 0.1, axis = "x"))
  expect_s3_class(q$scales$get_scales("x"), "ScaleBinnedPosition")
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(p)$data)
})

test_that("expansion defaults and named list returns remain unchanged", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  result <- fmt_expand(list(first = p, second = p))
  expect_named(result, c("first", "second"))
  for (q in result) {
    for (axis in c("x", "y")) {
      expect_equal(q$scales$get_scales(axis)$expand, c(0, 0, 0, 0))
    }
  }
})
