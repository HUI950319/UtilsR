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
