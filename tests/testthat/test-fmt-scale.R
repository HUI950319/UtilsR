x_params <- function(p) ggplot2::ggplot_build(p)$layout$panel_params[[1]]$x

test_that("fmt_scale() updates supplied fields and keeps the rest of an existing scale", {
  d <- data.frame(x = c(0, 50, 100), y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(limits = c(0, 120), breaks = seq(0, 120, 30),
                                sec.axis = ggplot2::dup_axis())
  out <- fmt_scale(p, x = list(labels = function(x) paste0(x, "d")))

  sc <- out$scales$get_scales("x")
  expect_identical(sc$breaks, seq(0, 120, 30))
  expect_identical(sc$limits, c(0, 120))
  expect_s3_class(sc$secondary.axis, "AxisSecondary")
  expect_identical(x_params(out)$get_labels(), paste0(seq(0, 120, 30), "d"))
  # The input plot is not modified by reference
  expect_identical(x_params(p)$get_labels(), as.character(seq(0, 120, 30)))
})

test_that("fmt_scale() keeps the existing transformation and re-expresses limits", {
  d <- data.frame(x = c(1, 25, 100), y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(transform = "sqrt", breaks = c(1, 25, 100))
  out <- fmt_scale(p, x = list(limits = c(0, 100)))
  sc <- out$scales$get_scales("x")
  expect_identical(sc$trans$name, "sqrt")
  expect_equal(sc$limits, c(0, 10))
  expect_identical(sc$breaks, c(1, 25, 100))

  lim <- suppressMessages(
    p + ggplot2::scale_x_continuous(transform = "sqrt", limits = c(1, 100))
  )
  logged <- fmt_scale(lim, x = list(transform = "log10"))$scales$get_scales("x")
  expect_identical(logged$trans$name, "log-10")
  expect_equal(logged$limits, c(0, 2))
})

test_that("fmt_scale() keeps temporal and discrete scale settings", {
  dates <- as.Date("2026-01-01") + c(0, 40, 80)
  lims <- as.Date(c("2025-12-01", "2026-04-01"))
  pd <- ggplot2::ggplot(data.frame(x = dates, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::scale_x_date(limits = lims)
  od <- fmt_scale(pd, x = list(date_breaks = "1 month", date_labels = "%b"))
  expect_equal(od$scales$get_scales("x")$limits, as.numeric(lims))
  date_labels <- x_params(od)$get_labels()
  expect_identical(date_labels[!is.na(date_labels)][1:2], c("Dec", "Jan"))

  pc <- ggplot2::ggplot(data.frame(x = c("a", "b", "c"), y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::scale_x_discrete(limits = c("c", "b", "a"))
  oc <- fmt_scale(pc, x = list(labels = toupper))
  expect_identical(oc$scales$get_scales("x")$limits, c("c", "b", "a"))
  expect_identical(as.character(x_params(oc)$get_labels()), c("C", "B", "A"))
})

test_that("fmt_scale() still adds a scale when none exists", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  out <- fmt_scale(p, y = list(breaks = 1:3))
  expect_s3_class(out$scales$get_scales("y"), "ScaleContinuousPosition")
  expect_identical(out$scales$get_scales("y")$breaks, 1:3)
})
