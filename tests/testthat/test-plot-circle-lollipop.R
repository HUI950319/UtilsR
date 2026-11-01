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
