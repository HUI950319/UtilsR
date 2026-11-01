dumbbell_plot <- function(data, ...) {
  withr::local_options(lifecycle_verbosity = "quiet")
  result <- NULL
  invisible(capture.output(result <- PlotDumbbell(data, ...)))
  result
}

test_that("PlotDumbbell isolates generated delta fields from input columns", {
  data <- data.frame(start = c(1, 2, 3), end = c(4, 6, 8), category = letters[1:3])
  reference <- ggplot2::ggplot_build(dumbbell_plot(data, show_delta = TRUE))$data
  for (role in names(data)) {
    for (field in c(".delta", ".delta_label", ".delta_x")) {
      renamed <- data
      columns <- stats::setNames(names(data), names(data))
      columns[[role]] <- field
      names(renamed) <- unname(columns)
      original <- renamed
      plot <- dumbbell_plot(renamed, x_col = columns[["start"]],
                             xend_col = columns[["end"]], y_col = columns[["category"]],
                             show_delta = TRUE)
      expect_equal(ggplot2::ggplot_build(plot)$data, reference)
      expect_identical(renamed, original)
    }
  }
  data$.delta <- c(10, 20, 30)
  plot <- dumbbell_plot(data)
  expect_identical(plot$data$.delta, data$.delta)
})

test_that("PlotDumbbell inset keeps row pairs when category labels repeat", {
  inset <- NULL
  original <- get(".build_dumbbell_inset", asNamespace("UtilsR"))
  testthat::local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  data <- data.frame(start = 1:4, end = c(2, 4, 5, 7), category = c("A", "A", "B", "B"))
  before <- data
  dumbbell_plot(data, inset_plot = "auto", inset_test = "none")
  lines <- ggplot2::ggplot_build(inset)$data[[2]]
  expect_equal(length(unique(lines$group)), 4L)
  expect_equal(unname(split(lines$y, lines$group)), lapply(1:4, function(i) c(data$start[i], data$end[i])))
  expect_identical(data, before)
  data$category <- letters[1:4]
  dumbbell_plot(data, inset_plot = "auto", inset_test = "none")
  control <- ggplot2::ggplot_build(inset)$data[[2]]
  expect_equal(control[c("group", "x", "y")], lines[c("group", "x", "y")])
})
