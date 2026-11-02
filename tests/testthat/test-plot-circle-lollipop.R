test_that("PlotCircleLollipop keeps extreme scaled heights finite in every mode", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  observed <- numeric()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original(x, y, ...)
  }, .package = "circlize")
  data <- data.frame(group = c(rep("A", 3), rep("B", 4)), name = letters[1:7],
                     value = c(rep(c(-1e308, 0, 1e308), 2), NA_real_))
  before <- data
  for (mode in c("none", "group", "top_n")) {
    observed <- numeric()
    PlotCircleLollipop(data, value_scale = mode, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    low <- if (mode == "none") .05 else 0
    expect_equal(observed, c(rep(c(low, .5, 1), 2), NA_real_))
  }
  for (mode in c("group", "top_n")) {
    observed <- numeric()
    PlotCircleLollipop(data[1:6, ], top_n = 2, value_scale = mode,
      show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, rep(c(1, if (mode == "group") .5 else 0), 2))
  }
  expect_identical(data, before)
})

test_that("PlotCircleLollipop omits unused sectors while preserving observed order", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  observed <- character()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, circlize::CELL_META$sector.index)
    original(x, y, ...)
  }, .package = "circlize")
  data <- data.frame(group = factor(rep(c("A", "B"), each = 2), levels = c("B", "unused", "A")),
                     name = letters[1:4], value = c(.2, .4, .6, .8))
  before <- data
  PlotCircleLollipop(data, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
  expect_identical(observed, c("B", "B", "A", "A"))
  observed <- character()
  PlotCircleLollipop(data, group_levels = c("A", "unused", "B"), show_labels = FALSE,
    show_links = FALSE, show_yaxis = FALSE)
  expect_identical(observed, c("A", "A", "B", "B"))
  expect_identical(data, before)
})

test_that("PlotCircleLollipop diagnoses missing groups before opening a device", {
  data <- data.frame(group = c("A", NA_character_, "B"), name = letters[1:3], value = c(.2, .4, .6))
  before <- grDevices::dev.cur()
  expect_error(PlotCircleLollipop(data), "Group labels.*missing")
  data$group <- c("A", "A", "B")
  expect_error(PlotCircleLollipop(data, group_levels = "A"), "Group labels.*excluded")
  expect_error(PlotCircleLollipop(data[FALSE, ]), "No observations")
  expect_identical(grDevices::dev.cur(), before)
})

test_that("PlotCircleLollipop draws constant global ranges at a finite height", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  withr::defer(circlize::circos.clear())
  observed <- numeric()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original(x, y, ...)
  }, .package = "circlize")
  for (values in list(rep(5, 4), rep(-1, 4), rep(.3, 4), c(5, 5, NA, 5))) {
    data <- data.frame(group = rep(c("A", "B"), each = 2), name = letters[1:4], value = values)
    before <- data
    observed <- numeric()
    invisible(capture.output(PlotCircleLollipop(data, show_labels = FALSE, show_links = FALSE,
                                                show_yaxis = FALSE)))
    expected <- if (all(values == .3, na.rm = TRUE)) values else replace(rep(.05, 4), is.na(values), NA_real_)
    expect_equal(observed, expected)
    expect_identical(data, before)
  }
})

test_that("PlotCircleLollipop restores caller graphics state after drawing and saving", {
  skip_if_not_installed("circlize")
  pdf <- withr::local_tempfile(fileext = ".pdf")
  png <- withr::local_tempfile(fileext = ".png")
  initial_devices <- grDevices::dev.list()
  initial_current <- grDevices::dev.cur()
  withr::defer({
    for (device in setdiff(grDevices::dev.list(), initial_devices)) grDevices::dev.off(device)
    if (initial_current %in% grDevices::dev.list()) grDevices::dev.set(initial_current)
    circlize::circos.clear()
  })
  grDevices::pdf(NULL)
  caller <- grDevices::dev.cur()
  grDevices::pdf(NULL)
  grDevices::dev.set(caller)
  graphics::par(mar = c(2, 3, 4, 5))
  devices <- grDevices::dev.list()
  margins <- graphics::par("mar")
  data <- data.frame(group = rep(c("A", "B"), each = 2), name = letters[1:4], value = c(.2, .4, .6, .8))
  for (file in list(NULL, pdf, png)) {
    invisible(capture.output(suppressMessages(PlotCircleLollipop(data, show_labels = FALSE, show_links = FALSE,
      show_yaxis = FALSE, filename = file, width = 4, height = 4, dpi = 72))))
    expect_identical(grDevices::dev.list(), devices)
    expect_identical(grDevices::dev.cur(), caller)
    expect_identical(graphics::par("mar"), margins)
    expect_length(circlize::get.all.sector.index(), 0L)
    if (!is.null(file)) expect_gt(file.info(file)$size, 0)
  }
})

test_that("PlotCircleLollipop closes only its own device when saving fails", {
  skip_if_not_installed("circlize")
  file <- withr::local_tempfile(fileext = ".pdf")
  initial_devices <- grDevices::dev.list()
  initial_current <- grDevices::dev.cur()
  withr::defer({
    for (device in setdiff(grDevices::dev.list(), initial_devices)) grDevices::dev.off(device)
    if (initial_current %in% grDevices::dev.list()) grDevices::dev.set(initial_current)
    circlize::circos.clear()
  })
  grDevices::pdf(NULL)
  caller <- grDevices::dev.cur()
  grDevices::pdf(NULL)
  grDevices::dev.set(caller)
  graphics::par(mar = c(2, 3, 4, 5))
  devices <- grDevices::dev.list()
  margins <- graphics::par("mar")
  data <- data.frame(group = rep(c("A", "B"), each = 2), name = letters[1:4], value = c(.2, .4, .6, .8))
  expect_error(PlotCircleLollipop(data, filename = file, unique_color = "not-a-colour",
    show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE), "colou?r")
  expect_identical(grDevices::dev.list(), devices)
  expect_identical(grDevices::dev.cur(), caller)
  expect_identical(graphics::par("mar"), margins)
  expect_length(circlize::get.all.sector.index(), 0L)
})
