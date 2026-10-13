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

test_that("implicit temporal axes retain their scale types and time resolution", {
  cases <- list(
    list(x = as.Date("2026-10-13") + 0:2, transform = "date"),
    list(x = as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200),
         transform = "time"),
    list(x = structure(c(0, 3600, 7200), class = c("hms", "difftime"), units = "secs"),
         transform = "hms")
  )
  for (case in cases) {
    p <- ggplot2::ggplot(data.frame(x = case$x, y = 1:3),
                         ggplot2::aes(x, y)) + ggplot2::geom_point()
    q <- fmt_expand(p, mult = 0.05, axis = "x")
    expect_identical(q$scales$get_scales("x")$trans$name, case$transform)
    expect_equal(ggplot2::ggplot_build(q)$data[[1]]$x, as.numeric(case$x))
  }
})

test_that("additive temporal expansion uses days for dates and seconds for times", {
  cases <- list(
    list(x = as.Date("2026-10-13") + 0:2, add = 2),
    list(x = as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200),
         add = 3600)
  )
  for (case in cases) {
    p <- ggplot2::ggplot(data.frame(x = case$x, y = 1:3),
                         ggplot2::aes(x, y)) + ggplot2::geom_point()
    q <- fmt_expand(p, add = c(case$add, 0), axis = "x")
    expect_equal(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x.range,
                 c(min(as.numeric(case$x)) - case$add, max(as.numeric(case$x))))
  }
})

test_that("shared scale detection accepts temporal controls in fmt_scale", {
  dates <- as.Date("2026-10-13") + 0:2
  times <- as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200)
  date_plot <- ggplot2::ggplot(data.frame(x = dates, y = 1:3),
                               ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_date()
  time_plot <- ggplot2::ggplot(data.frame(x = times, y = 1:3),
                               ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_datetime()
  q_date <- suppressMessages(fmt_scale(date_plot, x = list(date_labels = "%Y-%m-%d")))
  q_time <- suppressMessages(fmt_scale(time_plot,
    x = list(date_labels = "%H:%M", timezone = "Asia/Shanghai")))
  expect_identical(q_date$scales$get_scales("x")$trans$name, "date")
  expect_identical(q_time$scales$get_scales("x")$trans$name, "time")
  expect_identical(q_time$scales$get_scales("x")$timezone, "Asia/Shanghai")
  expect_equal(ggplot2::ggplot_build(q_time)$data[[1]]$x, as.numeric(times))
})
