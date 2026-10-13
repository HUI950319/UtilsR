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
  expect_identical(date_labels[!is.na(date_labels)][1:2],
                   format(as.Date(c("2025-12-01", "2026-01-01")), "%b"))

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

test_that("changing transformation preserves observations across reversed limits", {
  d <- data.frame(x = c(1, 10, 100), y = 1:3)
  base <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  cases <- list(
    list(from = "identity", to = "reverse", x = c(-1, -10, -100)),
    list(from = "reverse", to = "identity", x = c(1, 10, 100)),
    list(from = "sqrt", to = "reverse", x = c(-1, -10, -100))
  )
  for (case in cases) {
    p <- base + ggplot2::scale_x_continuous(transform = case$from,
                                          limits = c(1, 100))
    original <- p$scales$get_scales("x")$limits
    q <- fmt_scale(p, x = list(transform = case$to))
    expect_equal(ggplot2::ggplot_build(q)$data[[1]]$x, case$x)
    expect_identical(p$scales$get_scales("x")$limits, original)
  }
})

test_that("axis settings reach every nested patchwork leaf without changing layout", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  nested <- (p | p) / (p | p) + patchwork::plot_annotation(title = "Four panels")
  q <- fmt_scale(nested, x = list(breaks = c(1, 3)), y = list(labels = toupper))
  leaves <- .to_plot_list(q, recurse = TRUE)$plots
  expect_length(leaves, 4L)
  for (leaf in leaves) {
    expect_identical(ggplot2::ggplot_build(leaf)$layout$panel_params[[1]]$x$get_breaks(),
                     c(1, 3))
  }
  expect_identical(q$patches$layout, nested$patches$layout)
  expect_identical(q$patches$annotation, nested$patches$annotation)
  expect_null(p$scales$get_scales("x"))
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
})

test_that("function and formula layer data keep categorical axis settings", {
  d <- data.frame(x = factor(c("a", "b", "c")), y = 1:3)
  for (layer_data in list(function(d) d, ~ .x)) {
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point(data = layer_data)
    q <- fmt_scale(p, x = list(labels = toupper))
    built <- ggplot2::ggplot_build(q)
    expect_identical(as.character(built$layout$panel_params[[1]]$x$get_labels()),
                     c("A", "B", "C"))
    expect_equal(as.numeric(built$data[[1]]$x), 1:3)
    expect_null(p$scales$get_scales("x"))
  }
})

test_that("temporal settings use function output without extra data calls", {
  calls <- 0L
  layer_data <- function(d) {
    calls <<- calls + 1L
    d$x <- as.Date("2026-01-01") + d$x
    d
  }
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = layer_data)
  q <- fmt_scale(p, x = list(date_breaks = "1 day", date_labels = "%m-%d"))
  expect_identical(calls, 0L)
  built <- ggplot2::ggplot_build(q)
  expect_identical(calls, 1L)
  expect_s3_class(built$plot$scales$get_scales("x"), "ScaleContinuousDate")
  labels <- built$layout$panel_params[[1]]$x$get_labels()
  expect_identical(labels[!is.na(labels)], c("01-02", "01-03", "01-04"))
})

test_that("axis arguments require valid named lists before scale selection", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  invalid <- list(c(breaks = 1), list(1:3),
                  structure(list(1:3), names = NA_character_),
                  structure(list(1:3, 1:3), names = c("breaks", "breaks")))
  for (plot in list(p, p + ggplot2::scale_x_continuous())) {
    for (args in invalid) expect_error(fmt_scale(plot, x = args), "list|names")
    expect_error(fmt_scale(plot, y = c(breaks = 1)), "list")
    expect_error(fmt_scale(plot, x = list(brek = 1:3)), "Unknown|ambiguous")
    expect_error(fmt_scale(plot, x = list(lim = c(1, 2), limits = c(1, 3))), "unique")
  }
})

test_that("partial argument names update new and existing scales consistently", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (plot in list(p, p + ggplot2::scale_x_continuous(limits = c(1, 3)))) {
    q <- fmt_scale(plot, x = list(lim = c(1, 2), breaks = 1:2,
                                 lab = function(x) paste0("N", x)))
    expect_equal(q$scales$get_scales("x")$limits, c(1, 2))
    expect_identical(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x$get_labels(),
                     c("N1", "N2"))
  }
})
