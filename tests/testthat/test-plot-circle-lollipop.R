test_that("circular group orders reject non-vector level containers", {
  for (bad in list(matrix(c("A", "B")), list("A", "B")))
    expect_error(PlotCircleLollipop(stop("data evaluated"), group_levels = bad), "group_levels")
  testthat::local_mocked_bindings(circos.initialize = function(...) stop("drawing started"), .package = "circlize")
  d <- data.frame(group = rep(c("A", "B"), each = 2), name = letters[1:4], value = 1:4)
  expect_error(PlotCircleLollipop(d, group_levels = c("B", "A", "unused"), show_labels = FALSE), "drawing started")
})

test_that("circular optional colour selectors validate before reading data", {
  for (bad in list(NA_character_, character(), c("a", "b"), matrix("colour")))
    expect_error(PlotCircleLollipop(stop("data evaluated"), color_col = bad), "color_col")
  testthat::local_mocked_bindings(circos.initialize = function(...) stop("drawing started"), .package = "circlize")
  d <- data.frame(group = rep(c("A", "B"), each = 2), name = letters[1:4], value = 1:4, colour = "red")
  expect_error(PlotCircleLollipop(d, color_col = "colour", show_labels = FALSE), "drawing started")
  expect_error(PlotCircleLollipop(d, color_col = "absent", show_labels = FALSE), "drawing started")
})

test_that("circular sector gaps are checked before output devices are opened", {
  d <- data.frame(group = rep(c("A", "B", "C"), each = 2), name = letters[1:6], value = 1:6)
  before <- grDevices::dev.cur()
  file <- withr::local_tempfile(fileext = ".pdf")
  for (gap in list(c(360, 2), c(20, 170), c(1e308, 1e308))) {
    expect_error(PlotCircleLollipop(d, gap_after = gap[1], gap_between = gap[2],
      show_labels = FALSE, show_links = FALSE, filename = file), "gap")
    expect_identical(file.exists(file), FALSE)
    expect_identical(grDevices::dev.cur(), before)
  }
})

test_that("circular top counts reject dimensional and encoded storage before drawing", {
  testthat::local_mocked_bindings(circos.initialize = function(...) stop("drawing started"),
                                  .package = "circlize")
  d <- data.frame(group = rep(c("A", "B"), each = 2), name = letters[1:4], value = 1:4)
  for (bad in list(matrix(1), structure(1, class = "encoded")))
    expect_error(PlotCircleLollipop(d, top_n = bad, show_labels = FALSE), "top_n")
})

test_that("circular geometry controls fail before graphics initialization", {
  for (arg in c("track_height", "gap_after", "gap_between", "start_degree", "point_cex",
                "line_lwd", "sector_cex", "link_lwd", "link_h", "label_cex", "label_height")) {
    args <- list(data = quote(stop("data evaluated")))
    args[[arg]] <- Inf
    expect_error(do.call("PlotCircleLollipop", args), arg)
  }
})

test_that("circular plots validate selectors and ambiguous input names", {
  for (arg in c("group_col", "name_col", "value_col"))
    for (bad in list(NULL, NA_character_, c("a", "b"), matrix("a"))) {
      args <- list(data = quote(stop("data evaluated")))
      args[arg] <- list(bad)
      expect_error(do.call("PlotCircleLollipop", args), arg)
    }
  d <- data.frame(group = c("A", "B"), name = c("x", "y"), value = 1:2,
    value = 3:4, check.names = FALSE)
  expect_error(PlotCircleLollipop(d), "unique.*column names")
})

test_that("circular switches are validated before accessing data or graphics", {
  for (arg in c("show_links", "show_labels", "show_yaxis"))
    for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
      args <- list(data = quote(stop("data evaluated")))
      args[[arg]] <- bad
      expect_error(do.call("PlotCircleLollipop", args), arg)
    }
})

test_that("circular scores reject lossy storage and unplottable ranges before drawing", {
  skip_if_not_installed("circlize")
  data <- data.frame(group = rep(c("A", "B"), each = 3), name = letters[1:6])
  before <- grDevices::dev.cur()
  for (values in list(complex(real = 1:6, imaginary = 1),
                      I(matrix(1:12, 6)), c(1:5, Inf),
                      rep(NA_real_, 6), rep(NaN, 6))) {
    data[["value"]] <- values
    expect_error(PlotCircleLollipop(data, show_labels = FALSE,
                                    show_links = FALSE, show_yaxis = FALSE),
                 "value")
    expect_identical(grDevices::dev.cur(), before)
  }
})

test_that("circular scaling retains entirely missing groups without range warnings", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  data <- data.frame(group = rep(c("A", "B"), each = 3), name = letters[1:6],
                     value = c(.2, .4, .6, NA_real_, NA_real_, NA_real_))
  for (mode in c("none", "group", "top_n")) {
    expect_no_warning(PlotCircleLollipop(data, value_scale = mode,
      show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE))
  }
})

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

test_that("PlotCircleLollipop ranks and scales factor scores by their labels", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  observed <- numeric()
  observed_colors <- character()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, col, ...) {
    observed <<- c(observed, y)
    observed_colors <<- c(observed_colors, col)
    original(x, y, col = col, ...)
  }, .package = "circlize")
  for (ordered in c(FALSE, TRUE)) {
    data <- data.frame(
      group = rep(c("A", "B"), each = 3), name = letters[1:6],
      value = factor(c("0.1", "0.4", "0.9", "0.2", "0.8", "0.6"),
                     levels = c("0.9", "0.1", "0.8", "0.6", "0.4", "0.2", "unused"),
                     ordered = ordered),
      color = c("red", "blue", "green", "black", "purple", "orange")
    )
    before <- data
    observed <- numeric()
    PlotCircleLollipop(data, color_col = "color", show_labels = FALSE,
                       show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, c(.1, .4, .9, .2, .8, .6))
    expected <- list(none = c(.9, .4, .8, .6), group = c(1, .375, 1, 2 / 3),
                     top_n = c(1, 0, 1, 0))
    for (mode in names(expected)) {
      observed <- numeric()
      observed_colors <- character()
      PlotCircleLollipop(data, top_n = 2, value_scale = mode, color_col = "color",
                         show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
      expect_equal(observed, expected[[mode]])
      expect_identical(observed_colors, c("green", "blue", "purple", "orange"))
    }
    expect_identical(data, before)
  }
})

test_that("PlotCircleLollipop rejects fractional top_n before creating output", {
  skip_if_not_installed("circlize")
  data <- data.frame(group = rep(c("A", "B"), each = 3),
                     name = letters[1:6], value = seq(.1, .6, by = .1))
  devices <- grDevices::dev.list()
  for (n in c(.5, 1.5, 2.999, -1)) {
    file <- withr::local_tempfile(fileext = ".pdf")
    error <- tryCatch(
      suppressMessages(PlotCircleLollipop(data, top_n = n, filename = file,
        show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)),
      error = identity
    )
    expect_s3_class(error, "error")
    if (inherits(error, "error")) {
      expect_match(conditionMessage(error), "top_n.*non-negative integer")
    }
    expect_identical(file.exists(file), FALSE)
    expect_identical(grDevices::dev.list(), devices)
  }
})

test_that("PlotCircleLollipop rejects nonnumeric score labels before creating output", {
  skip_if_not_installed("circlize")
  devices <- grDevices::dev.list()
  for (scores in list(c("0.2", "high", "0.6", "0.8"),
                     factor(c("0.2", "high", "0.6", "0.8")))) {
    data <- data.frame(group = rep(c("A", "B"), each = 2),
                       name = letters[1:4], score = scores)
    before <- data
    file <- withr::local_tempfile(fileext = ".pdf")
    warnings <- character()
    error <- withCallingHandlers(
      tryCatch(
        suppressMessages(PlotCircleLollipop(data, value_col = "score", filename = file,
          show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)),
        error = identity
      ),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    expect_s3_class(error, "error")
    if (inherits(error, "error")) {
      expect_match(conditionMessage(error), "score.*numeric")
    }
    expect_length(warnings, 0L)
    expect_identical(file.exists(file), FALSE)
    expect_identical(grDevices::dev.list(), devices)
    expect_identical(data, before)
  }
})

test_that("PlotCircleLollipop preserves missing scores and ranks numeric text numerically", {
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
  scores <- c(NA, "2", "6", "10", NA, "3", "7", "11")
  for (values in list(scores, factor(scores))) {
    data <- data.frame(group = rep(c("A", "B"), each = 4),
                       name = letters[1:8], value = values)
    before <- data
    observed <- numeric()
    PlotCircleLollipop(data, value_scale = "group", show_labels = FALSE,
                       show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, c(NA, 0, .5, 1, NA, 0, .5, 1))
    expected <- list(none = c(.8, .05, 1, .2), group = c(1, .5, 1, .5),
                     top_n = c(1, 0, 1, 0))
    for (mode in names(expected)) {
      observed <- numeric()
      PlotCircleLollipop(data, top_n = 2, value_scale = mode, show_labels = FALSE,
                         show_links = FALSE, show_yaxis = FALSE)
      expect_equal(observed, expected[[mode]])
    }
    expect_identical(data, before)
  }
})

test_that("PlotCircleLollipop validates top_n scalar type and integer range", {
  skip_if_not_installed("circlize")
  data <- data.frame(group = rep(c("A", "B"), each = 2),
                     name = letters[1:4], value = c(.2, .4, .6, .8))
  devices <- grDevices::dev.list()
  invalid <- list(numeric(), c(1, 2), NA_real_, NaN, Inf, -Inf,
                  .Machine$integer.max + 1, "2", TRUE, factor("2"), 1 + 1i)
  for (n in invalid) {
    file <- withr::local_tempfile(fileext = ".pdf")
    error <- tryCatch(
      PlotCircleLollipop(data, top_n = n, filename = file),
      error = identity
    )
    expect_s3_class(error, "error")
    if (inherits(error, "error")) {
      expect_match(conditionMessage(error), "top_n.*non-negative integer")
    }
    expect_identical(file.exists(file), FALSE)
    expect_identical(grDevices::dev.list(), devices)
  }
})

test_that("PlotCircleLollipop preserves valid whole-number and NULL top_n behavior", {
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
  data <- data.frame(group = rep(c("A", "B"), each = 2),
                     name = letters[1:4], value = c(.2, .4, .6, .8))
  counts <- list(NULL, 1L, 1, 2, 10, .Machine$integer.max)
  expected <- list(c(.2, .4, .6, .8), c(.4, .8), c(.4, .8),
                   c(.4, .2, .8, .6), c(.4, .2, .8, .6), c(.4, .2, .8, .6))
  for (i in seq_along(counts)) {
    observed <- numeric()
    PlotCircleLollipop(data, top_n = counts[[i]], show_labels = FALSE,
                       show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, expected[[i]])
  }
  error <- tryCatch(PlotCircleLollipop(data, top_n = 0), error = identity)
  expect_s3_class(error, "error")
  expect_match(conditionMessage(error), "No observations")
})

test_that("PlotCircleLollipop preserves labels when one column supplies groups and scores", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  observed <- numeric()
  sectors <- character()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    sectors <<- c(sectors, circlize::CELL_META$sector.index)
    original(x, y, ...)
  }, .package = "circlize")
  scores <- c("0.20", "0.20", "0.80", "0.80")
  for (values in list(scores, factor(scores, levels = c("0.80", "0.20")))) {
    data <- data.frame(score = values, name = letters[1:4])
    before <- data
    observed <- numeric()
    sectors <- character()
    error <- tryCatch(
      PlotCircleLollipop(data, group_col = "score", value_col = "score", top_n = 1,
        group_levels = c("0.20", "0.80"), show_labels = FALSE, show_links = FALSE,
        show_yaxis = FALSE),
      error = identity
    )
    expect_null(error)
    expect_equal(observed, c(.2, .8))
    expect_identical(sectors, c("0.20", "0.80"))
    expect_identical(data, before)
  }
})

test_that("PlotCircleLollipop keeps close numeric groups separate while scaling", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  observed <- numeric()
  sectors <- character()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    sectors <<- c(sectors, circlize::CELL_META$sector.index)
    original(x, y, ...)
  }, .package = "circlize")
  groups <- c(1, 1 + 1e-15)
  data <- data.frame(group = rep(groups, each = 3), name = letters[1:6],
                     value = c(0, 5, 10, 100, 150, 200))
  before <- data
  for (mode in c("group", "top_n")) {
    observed <- numeric()
    sectors <- character()
    PlotCircleLollipop(data, value_scale = mode, show_labels = FALSE,
                       show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, rep(c(0, .5, 1), 2))
    expect_identical(as.numeric(unique(sectors)), groups)
    observed <- numeric()
    sectors <- character()
    PlotCircleLollipop(data, top_n = 2, value_scale = mode, show_labels = FALSE,
                       show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, rep(c(1, if (mode == "group") .5 else 0), 2))
    expect_identical(as.numeric(unique(sectors)), groups)
    expect_identical(as.numeric(sectors), rep(groups, each = 2))
  }
  expect_identical(data, before)
})

test_that("PlotCircleLollipop retains other group labels and ranked row colours", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  observed <- numeric()
  sectors <- character()
  colors <- character()
  positions <- numeric()
  original <- circlize::circos.points
  testthat::local_mocked_bindings(circos.points = function(x, y, col, ...) {
    observed <<- c(observed, y)
    sectors <<- c(sectors, circlize::CELL_META$sector.index)
    colors <<- c(colors, col)
    positions <<- c(positions, x)
    original(x, y, col = col, ...)
  }, .package = "circlize")
  groups <- c(1, 1 + 1e-15, 2)
  data <- data.frame(group = rep(groups, each = 3), name = letters[1:9],
                     value = c(.1, .4, .9, .2, .8, .6, .3, .7, .5),
                     color = c("red", "blue", "green", "black", "purple", "orange",
                               "pink", "gold", "cyan"))
  before <- data
  expected <- list(none = c(.9, .4, .8, .6, .7, .5),
                   group = c(1, .375, 1, 2 / 3, 1, .5),
                   top_n = rep(c(1, 0), 3))
  for (mode in names(expected)) {
    observed <- numeric()
    sectors <- character()
    colors <- character()
    positions <- numeric()
    PlotCircleLollipop(data, top_n = 2, value_scale = mode, color_col = "color",
                       show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, expected[[mode]])
    expect_identical(as.numeric(sectors), rep(groups, each = 2))
    expect_identical(tail(sectors, 2), c("2", "2"))
    expect_identical(colors, c("green", "blue", "purple", "orange", "gold", "cyan"))
    expect_equal(positions, rep(c(.25, .75), 3))
  }
  labels <- unique(sectors)
  observed <- numeric()
  sectors <- character()
  PlotCircleLollipop(data, top_n = 2, value_scale = "group",
                     group_levels = c(rev(labels), "unused"), show_labels = FALSE,
                     show_links = FALSE, show_yaxis = FALSE)
  expect_identical(sectors, rep(rev(labels), each = 2))
  expect_equal(observed, c(1, .5, 1, 2 / 3, 1, .375))
  expect_identical(data, before)
})

test_that("PlotCircleLollipop links and colours shared features across close groups", {
  skip_if_not_installed("circlize")
  grDevices::pdf(NULL)
  device <- grDevices::dev.cur()
  withr::defer(grDevices::dev.off(device))
  sectors <- character()
  colors <- character()
  linked <- character()
  original_points <- circlize::circos.points
  original_link <- circlize::circos.link
  testthat::local_mocked_bindings(
    circos.points = function(x, y, col, ...) {
      sectors <<- c(sectors, circlize::CELL_META$sector.index)
      colors <<- c(colors, col)
      original_points(x, y, col = col, ...)
    },
    circos.link = function(sector.index1, point1, sector.index2, point2, ...) {
      linked <<- c(linked, sector.index1, sector.index2)
      original_link(sector.index1, point1, sector.index2, point2, ...)
    },
    .package = "circlize"
  )
  groups <- c(1, 1 + 1e-15)
  data <- data.frame(group = rep(groups, each = 2),
                     name = c("shared", "A-only", "shared", "B-only"),
                     value = c(.2, .4, .6, .8))
  before <- data
  PlotCircleLollipop(data, value_scale = "group", show_yaxis = FALSE)
  expect_identical(as.numeric(sectors), rep(groups, each = 2))
  expect_identical(colors, rep(c("#4682B4", "#FF7F50"), 2))
  expect_identical(linked, unique(sectors))
  expect_length(circlize::get.all.sector.index(), 0L)
  expect_identical(data, before)
})

test_that("circular sharing distinguishes nearby numeric feature identifiers", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  links <- 0L
  colours <- character()
  original_link <- circlize::circos.link
  original_points <- circlize::circos.points
  testthat::local_mocked_bindings(circos.link = function(...) {
    links <<- links + 1L
    original_link(...)
  }, circos.points = function(x, y, col, ...) {
    colours <<- c(colours, col)
    original_points(x, y, col = col, ...)
  }, .package = "circlize")
  d <- data.frame(group = c("A", "B"), name = c(1, 1 + .Machine$double.eps), value = c(.2, .8))
  PlotCircleLollipop(d, show_labels = FALSE, show_yaxis = FALSE)
  expect_identical(links, 0L)
  expect_identical(colours, rep("#FF7F50", 2L))
})

test_that("circular plots decode cold integer64 groups and scores", {
  skip_if_not_installed("bit64")
  skip_if_not_installed("circlize")
  scratch <- withr::local_tempdir()
  input <- file.path(scratch, "input.rds")
  script <- file.path(scratch, "verify.R")
  groups <- data.frame(group = bit64::as.integer64(c(-1, -1, -2, -2)), name = c("a", "b", "a", "c"), value = 1:4)
  scores <- data.frame(group = rep(c("A", "B"), each = 2), name = c("a", "b", "a", "c"), value = bit64::as.integer64(-1:-4))
  for (d in list(groups, scores)) {
    labels <- unique(as.character(d$group))
    saveRDS(list(fn = PlotCircleLollipop, data = d, labels = labels, libs = .libPaths()), input)
    writeLines(c(sprintf("payload <- readRDS(%s)", deparse(input)),
      '.libPaths(payload[["libs"]])',
      'stopifnot(!("bit64" %in% loadedNamespaces()))',
      'testthat::local_mocked_bindings(circos.initialize = function(factors, ...) {stopifnot(identical(levels(factors), payload[["labels"]])); stop("REACHED_DRAW")}, .package = "circlize")',
      'error <- tryCatch(payload[["fn"]](payload[["data"]]), error = conditionMessage)',
      'stopifnot(identical(error, "REACHED_DRAW"))',
      'cat("COLD_CIRCLE_OK\n")'), script)
    output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
    expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
    expect_true('COLD_CIRCLE_OK' %in% output)
  }
})

test_that("circular scores exclude SPSS user missing codes before ranking", {
  skip_if_not_installed("haven")
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  observed <- numeric()
  original <- circlize::circos.points
  local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original(x, y, ...)
  }, .package = "circlize")
  d <- data.frame(group = rep(c("A", "B"), each = 4), name = letters[1:8])
  d$value <- haven::labelled_spss(c(99, 2, 4, 6, 97, 3, 5, 7),
                                 na_values = 97, na_range = c(98, 100))
  before <- serialize(d, NULL)
  control <- haven::zap_missing(d)
  for (mode in c("none", "group", "top_n")) for (top in list(NULL, 2)) {
    observed <- numeric()
    expect_no_warning(PlotCircleLollipop(control, value_scale = mode, top_n = top,
      show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE))
    expected <- observed
    observed <- numeric()
    expect_no_warning(PlotCircleLollipop(d, value_scale = mode, top_n = top,
      show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE))
    expect_identical(observed, expected)
  }
  expect_identical(serialize(d, NULL), before)
})

test_that("circular factor point colours retain their labels", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(group = c("A", "A", "B", "B"), name = c("shared", "a", "shared", "b"),
    value = c(.2, .4, .6, .8))
  colours <- character()
  original <- circlize::circos.points
  local_mocked_bindings(circos.points = function(x, y, ...) {
    colours <<- c(colours, list(...)$col)
    original(x, y, ...)
  }, .package = "circlize")
  PlotCircleLollipop(d, common_color = factor("red", levels = c("blue", "red")),
    unique_color = "blue", show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
  expect_identical(colours, c("red", "blue", "red", "blue"))
})

test_that("circular shared feature links connect distinct groups only", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(group = c("A", "A", "B"), name = rep("shared", 3), value = c(.2, .4, .8))
  before <- d
  links <- list()
  original <- circlize::circos.link
  local_mocked_bindings(circos.link = function(sector.index1, point1, sector.index2, point2, ...) {
    links[[length(links) + 1L]] <<- c(sector.index1, sector.index2)
    original(sector.index1, point1, sector.index2, point2, ...)
  }, .package = "circlize")
  PlotCircleLollipop(d, show_labels = FALSE, show_yaxis = FALSE)
  expect_identical(links, rep(list(c("A", "B")), 2))
  expect_identical(d, before)
  links <- list()
  PlotCircleLollipop(d, show_links = FALSE, show_labels = FALSE, show_yaxis = FALSE)
  expect_identical(links, list())
  links <- list()
  PlotCircleLollipop(d[c(1, 3), ], show_labels = FALSE, show_yaxis = FALSE)
  expect_identical(links, list(c("A", "B")))
})

test_that("constant circular groups preserve missing score positions", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  original <- circlize::circos.points
  local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original(x, y, ...)
  }, .package = "circlize")
  for (value in c(-2, .2, 2)) {
    d <- data.frame(group = "A", name = letters[1:3], value = c(value, NA, value))
    before <- d
    for (mode in c("none", "group", "top_n")) {
      observed <- numeric()
      PlotCircleLollipop(d, value_scale = mode, show_labels = FALSE,
        show_links = FALSE, show_yaxis = FALSE)
      expect_identical(is.na(observed), is.na(d$value))
      expected <- if (mode != "none") 0 else if (value < 0 || value > 1) .05 else value
      expect_equal(observed[!is.na(observed)], rep(expected, 2))
    }
    expect_identical(d, before)
  }
})

test_that("circular integer64 scores retain narrow ranks and scaling domains", {
  skip_if_not_installed("bit64")
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  original_points <- circlize::circos.points
  original_initialize <- circlize::circos.initialize
  local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original_points(x, y, ...)
  }, circos.initialize = function(...) {
    displayed <<- get("df", parent.frame(), inherits = TRUE)
    original_initialize(...)
  }, .package = "circlize")
  d <- data.frame(group = "A", name = c("low", "mid", "high", "missing"),
    value = bit64::as.integer64(c("9007199254740992", "9007199254740993", "9007199254740994", NA)))
  before <- serialize(d, NULL)
  for (mode in c("none", "group", "top_n")) {
    observed <- numeric()
    PlotCircleLollipop(d, value_scale = mode, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, c(if (mode == "none") .05 else 0, .5, 1, NA_real_))
    expect_identical(class(displayed), if (mode == "top_n") "data.frame" else c("tbl_df", "tbl", "data.frame"))
    observed <- numeric()
    PlotCircleLollipop(d, top_n = 2, value_scale = mode, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_identical(displayed$name, c("high", "mid"))
    expect_equal(observed, switch(mode, none = c(1, .05), group = c(1, .5), top_n = c(1, 0)))
  }
  observed <- numeric()
  PlotCircleLollipop(d[1:2, ], top_n = 1, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
  expect_identical(displayed$name, "mid")
  expect_identical(serialize(d, NULL), before)
  both <- rbind(d, d)
  both$group <- rep(c("A", "B"), each = 4)
  both$value[5:8] <- c(-rev(d$value[1:3]), bit64::as.integer64(NA))
  both <- rbind(both, data.frame(group = "C", name = "missing_only", value = bit64::as.integer64(NA)))
  before_both <- serialize(both, NULL)
  for (mode in c("group", "top_n")) {
    observed <- numeric()
    PlotCircleLollipop(both, value_scale = mode, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_equal(observed, c(rep(c(0, .5, 1, NA_real_), 2), NA_real_))
  }
  expect_identical(serialize(both, NULL), before_both)
  d$value[c(1, 3)] <- d$value[2]
  before_constant <- serialize(d, NULL)
  for (mode in c("none", "group", "top_n")) {
    observed <- numeric()
    PlotCircleLollipop(d, value_scale = mode, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_identical(is.na(observed), is.na(d$value))
    expect_equal(observed[!is.na(observed)], rep(if (mode == "none") .05 else 0, 3))
  }
  expect_identical(serialize(d, NULL), before_constant)
})

test_that("circular integer64 scaling avoids signed range overflow", {
  skip_if_not_installed("bit64")
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  original <- circlize::circos.points
  local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original(x, y, ...)
  }, .package = "circlize")
  ranges <- list(c("-9223372036854775807", "9223372036854775807"),
    c("-1", "9223372036854775806"), c("-1", "9223372036854775807"))
  for (bounds in ranges) {
    lo <- bit64::as.integer64(bounds[1L])
    hi <- bit64::as.integer64(bounds[2L])
    d <- data.frame(group = "A", name = letters[1:4],
      value = c(lo, lo + bit64::as.integer64(1), hi, bit64::as.integer64(NA)))
    before <- serialize(d, NULL)
    expected_step <- suppressWarnings(.5 / (as.numeric(hi) / 2 - as.numeric(lo) / 2))
    for (mode in c("none", "group", "top_n")) {
      observed <- numeric()
      expect_no_warning(PlotCircleLollipop(d, value_scale = mode,
        show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE))
      expect_identical(is.na(observed), c(FALSE, FALSE, FALSE, TRUE))
      if (mode != "none") {
        expect_gt(observed[2L], 0)
        expect_equal(observed[2L] / expected_step, 1, tolerance = 1e-14)
      } else expect_equal(observed[2L], .05)
      expect_equal(observed[c(1, 3)], c(if (mode == "none") .05 else 0, 1))
    }
    expect_identical(serialize(d, NULL), before)
  }
})

test_that("circular top counts preserve input sector order", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  initialize <- circlize::circos.initialize
  sectors <- NULL
  local_mocked_bindings(circos.initialize = function(factors, ...) {
    sectors <<- levels(factors)
    initialize(factors, ...)
  }, .package = "circlize")
  data <- data.frame(group = rep(c("B", "A"), each = 3), name = letters[1:6], value = 1:6)
  for (n in list(NULL, 1L, 2L)) {
    PlotCircleLollipop(data, top_n = n, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
    expect_identical(sectors, c("B", "A"))
  }
  PlotCircleLollipop(data, top_n = 1L, group_levels = c("A", "B"),
    show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
  expect_identical(sectors, c("A", "B"))
})

test_that("missing circular names do not create shared features", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  original_points <- circlize::circos.points
  original_link <- circlize::circos.link
  local_mocked_bindings(circos.points = function(x, y, col, ...) {
    colours <<- c(colours, col)
    original_points(x, y, col = col, ...)
  }, circos.link = function(...) {
    links <<- links + 1L
    original_link(...)
  }, .package = "circlize")
  d <- data.frame(group = rep(c("A", "B"), each = 2),
    name = c(NA, "real", NA, "real"), value = c(.2, .4, .6, .8))
  for (draw_links in c(FALSE, TRUE)) {
    colours <- character()
    links <- 0L
    PlotCircleLollipop(d, common_color = "blue", unique_color = "orange",
      show_labels = FALSE, show_links = draw_links, show_yaxis = FALSE)
    expect_identical(colours, rep(c("orange", "blue"), 2))
    expect_identical(links, as.integer(draw_links))
  }
})

test_that("circular feature sharing is computed once for colours and links", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(group = c("A", "A", "B", "B"), name = c("shared", "a", "shared", "b"),
    value = c(.2, .4, .6, .8), col = "black")
  original <- dplyr::n_distinct
  checks <- 0L
  local_mocked_bindings(n_distinct = function(...) {
    checks <<- checks + 1L
    original(...)
  }, .package = "dplyr")
  PlotCircleLollipop(d, show_labels = FALSE, show_links = TRUE, show_yaxis = FALSE)
  expect_equal(checks, 3L)
  checks <- 0L
  PlotCircleLollipop(d, color_col = "col", show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
  expect_equal(checks, 0L)
})

test_that("close labelled feature names do not share circular arcs", {
  skip_if_not_installed("circlize")
  skip_if_not_installed("haven")
  withr::local_pdf(NULL)
  links <- 0L
  original <- circlize::circos.link
  local_mocked_bindings(circos.link = function(...) {
    links <<- links + 1L
    original(...)
  }, .package = "circlize")
  d <- data.frame(group = rep(c("A", "B"), 2), value = c(.2, .4, .6, .8))
  draw <- function() PlotCircleLollipop(d, show_labels = FALSE, show_yaxis = FALSE)
  d$name <- haven::labelled(c(1, 1 + .Machine$double.eps, 2, 3), label = "Feature")
  before <- d
  draw()
  expect_identical(links, 0L)
  expect_identical(d, before)
  d$name <- haven::labelled(c(1, 1, 2, 3), label = "Feature")
  draw()
  expect_identical(links, 1L)
})

test_that("circular top counts parse character scores once", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  fn <- PlotCircleLollipop
  e <- new.env(parent = environment(fn))
  seen <- 0L
  e$as.numeric <- function(x, ...) {
    if (is.character(x) && length(x) && all(grepl("^0[.][0-9]+$", x))) seen <<- seen + length(x)
    base::as.numeric(x, ...)
  }
  environment(fn) <- e
  values <- c(.4, .2, .1, .9, .6, .3)
  d <- data.frame(group = rep(c("B", "A"), each = 3), name = letters[1:6],
    value = as.character(values))
  observed <- numeric()
  original <- circlize::circos.points
  local_mocked_bindings(circos.points = function(x, y, ...) {
    observed <<- c(observed, y)
    original(x, y, ...)
  }, .package = "circlize")
  fn(d, top_n = 2L, show_labels = FALSE, show_yaxis = FALSE, show_links = FALSE)
  expect_identical(seen, nrow(d))
  expect_equal(sort(observed), c(.2, .4, .6, .9))
})

test_that("circular arcs reuse indexed shared feature rows", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  ids <- paste0("feature", seq_len(24L))
  d <- data.frame(group = rep(c("A", "B"), each = length(ids)),
    name = rep(ids, 2L), value = rep(seq_along(ids) / length(ids), 2L))
  fn <- PlotCircleLollipop
  env <- new.env(parent = environment(fn))
  full_scans <- 0L
  env[["=="]] <- function(x, y) {
    if (is.character(x) && length(x) == nrow(d) && length(y) == 1L) {
      full_scans <<- full_scans + 1L
    }
    base::`==`(x, y)
  }
  environment(fn) <- env
  links <- list()
  local_mocked_bindings(circos.link = function(sector.index1, point1, sector.index2, point2, ...) {
    links[[length(links) + 1L]] <<- list(sector.index1, point1, sector.index2, point2)
    invisible(NULL)
  }, .package = "circlize")
  fn(d, show_labels = FALSE, show_yaxis = FALSE)
  expect_identical(full_scans, 0L)
  expect_length(links, length(ids))
  expect_true(all(vapply(links, function(x) x[[1L]] == "A" &&
    x[[3L]] == "B" && x[[2L]] == x[[4L]], logical(1))))
})

test_that("circular arcs skip individual comparisons for same sector pairs", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(group = c(rep("A", 40L), "B", "C"), name = "shared",
    value = seq_len(42L) / 42)
  fn <- PlotCircleLollipop
  env <- new.env(parent = environment(fn))
  comparisons <- 0L
  env[["=="]] <- function(x, y) {
    if (is.factor(x) && is.factor(y) && length(x) == 1L) comparisons <<- comparisons + 1L
    base::`==`(x, y)
  }
  environment(fn) <- env
  links <- character()
  local_mocked_bindings(circos.link = function(sector.index1, point1, sector.index2, point2, ...) {
    links <<- c(links, paste0(sector.index1, sector.index2))
    invisible(NULL)
  }, .package = "circlize")
  fn(d, show_labels = FALSE, show_yaxis = FALSE)
  expect_identical(comparisons, 0L)
  expect_identical(links, c(rep(c("AB", "AC"), 40L), "BC"))
})

test_that("circular label frames are built only for visible labels", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(group = rep(c("A", "B"), each = 3L), name = letters[1:6], value = 1:6)
  fn <- PlotCircleLollipop
  env <- new.env(parent = environment(fn))
  labels <- 0L
  env$data.frame <- function(...) {
    if (all(c("chr", "start", "end", "label") %in% names(list(...)))) labels <<- labels + 1L
    base::data.frame(...)
  }
  environment(fn) <- env
  fn(d, show_labels = FALSE, show_links = FALSE, show_yaxis = FALSE)
  expect_identical(labels, 0L)
  fn(d, show_labels = TRUE, show_links = FALSE, show_yaxis = FALSE)
  expect_identical(labels, 1L)
})
