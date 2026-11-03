dumbbell_plot <- function(data, ...) {
  withr::local_options(lifecycle_verbosity = "quiet")
  result <- NULL
  invisible(capture.output(result <- PlotDumbbell(data, ...)))
  result
}

test_that("PlotDumbbell rejects invalid top_n values", {
  data <- data.frame(start = 1:4, end = 2:5, category = letters[1:4])
  invalid <- list(
    0.5, 1.5, -0.5, 6.5, 1 + .Machine$double.eps,
    NA, NA_real_, NaN, Inf, -Inf, numeric(), c(1, 2),
    "2", TRUE, list(2), factor("2"), 2 + 0i
  )
  for (top_n in invalid) {
    expect_error(dumbbell_plot(data, top_n = top_n),
                 "top_n.*single finite integer")
  }
})

test_that("PlotDumbbell accepts integer-valued top_n and uncapped inputs", {
  data <- data.frame(start = 1:4, end = 2:5, category = letters[1:4])
  original <- data
  for (top_n in list(2L, 2)) {
    plot <- dumbbell_plot(data, sort_by = "none", top_n = top_n)
    expect_identical(as.character(plot$data$category), c("c", "d"))
  }
  plot <- dumbbell_plot(data, sort_by = "none", top_n = 1L)
  expect_identical(as.character(plot$data$category), "d")
  for (top_n in list(NULL, 0, -2L, 4L, .Machine$integer.max + 1)) {
    plot <- dumbbell_plot(data, sort_by = "none", top_n = top_n)
    expect_identical(as.character(plot$data$category), letters[1:4])
  }
  expect_identical(data, original)
})

test_that("PlotDumbbell keeps the last top_n rows in each sort order", {
  data <- data.frame(
    start = c(3, 1, 5, 2, 4), end = c(8, 6, 7, 6, 5),
    category = letters[1:5]
  )
  expected <- list(
    end = list(c("d", "c", "a"), c("b", "d", "e")),
    start = list(c("a", "e", "c"), c("a", "d", "b")),
    delta = list(c("d", "a", "b"), c("d", "c", "e")),
    none = list(c("c", "d", "e"), c("c", "d", "e"))
  )
  for (sort_by in names(expected)) {
    for (descending in c(FALSE, TRUE)) {
      plot <- dumbbell_plot(data, sort_by = sort_by,
                             sort_descending = descending, top_n = 3)
      want <- expected[[sort_by]][[if (descending) 2L else 1L]]
      expect_identical(as.character(plot$data$category), want)
      expect_identical(levels(plot$data$category), want)
    }
  }
})

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
