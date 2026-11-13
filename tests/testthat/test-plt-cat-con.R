# Saving of plt_cat() and plt_con(): the page each plot is laid out for.

cat_test_plot <- function(...) {
  p <- NULL
  invisible(utils::capture.output(p <- suppressMessages(plt_cat(...))))
  p
}

# Installed RegR versions report saving through either stdout or cli messages.
cat_test_output <- function(code) {
  messages <- character()
  output <- utils::capture.output(messages <- testthat::capture_messages(code))
  c(output, messages)
}

cat_test_text <- function(grob) {
  c(if (inherits(grob, "text")) as.character(grob$label),
    unlist(lapply(grob$grobs, cat_test_text), use.names = FALSE),
    unlist(lapply(grob$children, cat_test_text), use.names = FALSE))
}

cat_test_time_collisions <- function() {
  instant <- as.POSIXct(0.1 + c(0, .Machine$double.eps),
                        origin = "1970-01-01", tz = "UTC")
  clock <- as.POSIXct(c("2020-11-01 05:30:00", "2020-11-01 06:30:00"), tz = "UTC")
  attr(clock, "tzone") <- "America/New_York"
  list(Date = as.Date(c(0.1, 0.2), origin = "2020-01-01"),
       POSIXct = instant, POSIXlt = as.POSIXlt(instant),
       clock_ct = clock, clock_lt = as.POSIXlt(clock),
       difftime = as.difftime(c(1e15, 1e15 + 1), units = "secs"))
}

cat_test_lubridate_collisions <- function() {
  starts <- as.POSIXct(c(0.1, 0.2), origin = "1970-01-01", tz = "UTC")
  list(Duration = lubridate::dseconds(c(1e15, 1e15 + 1)),
       Period = lubridate::seconds(1 + c(0, .Machine$double.eps)),
       calendar = lubridate::period(month = c(1e15, 1e15 + 1)),
       Interval = lubridate::interval(starts, starts + 3600),
       length = lubridate::interval(starts[1], starts[1] + 1 + c(0, .Machine$double.eps)))
}

test_that("continuous plot controls validate selectors and panel counts", {
  d <- data.frame(value = 1:6, g = rep(c("L", "R"), each = 3))
  for (arg in c("group.by", "split.by", "bg.by")) {
    args <- list(data = d, stat.by = "value", group.by = "g", type = "box",
      base_size = quote(stop("theme evaluated")))
    args[[arg]] <- matrix("g")
    expect_error(do.call("plt_con", args), arg)
  }
  for (arg in c("facet_nrow", "facet_ncol"))
    for (bad in list(0, -1, 1.5, Inf, NA_real_, matrix(1),
                     structure(1, class = "encoded_count"), 2^31)) {
      args <- list(data = d, stat.by = "value", type = "box", base_size = quote(stop("theme evaluated")))
      args[[arg]] <- bad
      expect_error(do.call("plt_con", args), arg)
    }
})

test_that("categorical plot controls reject dimensional and encoded settings", {
  d <- data.frame(a = rep(c("a", "b"), 3), g = rep(c("L", "R"), each = 3))
  for (arg in c("group.by", "split.by", "bg.by", "label", "flip", "NA_stat",
                "keep_empty", "force", "facet_byrow", "facet_nrow", "facet_ncol")) {
    value <- if (arg %in% c("group.by", "split.by", "bg.by")) "g" else
      if (arg %in% c("facet_nrow", "facet_ncol")) 1 else TRUE
    args <- list(data = d, stat.by = "a", group.by = "g", base_size = quote(stop("theme evaluated")))
    args[[arg]] <- matrix(value)
    expect_error(do.call("plt_cat", args), arg)
  }
  for (arg in c("facet_nrow", "facet_ncol")) for (bad in list(structure(1, class = "encoded_count"), 2^31)) {
    args <- list(data = d, stat.by = "a", base_size = quote(stop("theme evaluated")))
    args[[arg]] <- bad
    expect_error(do.call("plt_cat", args), arg)
  }
})

test_that("plt_cat keeps colliding base time categories distinct", {
  for (values in cat_test_time_collisions()) {
    d <- data.frame(row = seq_len(4))
    d[["A"]] <- values[c(1, 2, 1, NA)]
    p <- cat_test_plot(d, "A", stat = "count", NA_stat = TRUE)
    expect_equal(p$data$n, c(2L, 1L, 1L))
    expect_length(unique(as.character(p$data$stat_var)), 3L)
    expect_equal(sum(ggplot2::ggplot_build(p)$data[[1]]$fill == "grey80"), 1L)
    q <- cat_test_plot(d, "A", stat = "count")
    expect_equal(q$data$n, c(2L, 1L))
  }
})

test_that("plt_cat keeps colliding lubridate categories distinct", {
  skip_if_not_installed("lubridate")
  for (values in cat_test_lubridate_collisions()) {
    d <- data.frame(row = seq_len(4))
    d[["A"]] <- values[c(1, 2, 1, NA)]
    p <- cat_test_plot(d, "A", stat = "count", NA_stat = TRUE)
    expect_equal(p$data$n, c(2L, 1L, 1L))
    expect_length(unique(as.character(p$data$stat_var)), 3L)
    expect_equal(sum(ggplot2::ggplot_build(p)$data[[1]]$fill == "grey80"), 1L)
    q <- cat_test_plot(d, "A", stat = "count")
    expect_equal(q$data$n, c(2L, 1L))
  }
})

test_that("plt_cat separates colliding time groups, splits and backgrounds", {
  for (values in cat_test_time_collisions()) {
    d <- data.frame(A = "a", group = c("one", "two", "one"))
    d[["time"]] <- values[c(1, 2, 1)]
    grouped <- cat_test_plot(d, "A", "time", stat = "count")
    expect_equal(grouped$data$n, c(2L, 1L))
    split <- cat_test_plot(d, "A", split.by = "time", stat = "count")
    expect_length(split, 2L)
    expect_equal(vapply(seq_len(length(split)), function(i) sum(split[[i]]$data$n), 0), c(2, 1))
    background <- cat_test_plot(d, "A", "group", bg.by = "time", position = "dodge")
    expect_length(unique(background$layers[[1]]$data$bg), 2L)
    expect_equal(as.character(ggplot2::ggplot_build(background)$data[[1]]$fill),
                 c("grey85", "transparent"))
  }
})

test_that("plt_cat resolves colliding base time membership exactly", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  for (values in cat_test_time_collisions()) {
    d <- data.frame(B = c(TRUE, FALSE, FALSE))
    d[["A"]] <- values[c(1, 2, 1)]
    p <- cat_test_plot(d, c("A", "B"), type = "upset",
                      stat_level = list(A = values[2], B = TRUE))
    expect_equal(p$data$intersection, list("B", "A"))
    expect_equal(ggplot2::ggplot_build(p)$data[[1]]$count, c(1, 1))
  }
})

test_that("plt_cat resolves colliding lubridate membership exactly", {
  skip_if_not_installed("lubridate")
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  for (values in cat_test_lubridate_collisions()) {
    d <- data.frame(B = c(TRUE, FALSE, FALSE))
    d[["A"]] <- values[c(1, 2, 1)]
    p <- cat_test_plot(d, c("A", "B"), type = "upset",
                      stat_level = list(A = values[2], B = TRUE))
    expect_equal(p$data$intersection, list("B", "A"))
    expect_equal(ggplot2::ggplot_build(p)$data[[1]]$count, c(1, 1))
  }
})

test_that("plt_cat preserves other time labels and named colours after disambiguation", {
  d <- data.frame(A = as.Date(c(0.1, 0.2, 2, 0.1, NA), origin = "2020-01-01"))
  p <- cat_test_plot(d, "A", stat = "count", NA_stat = TRUE)
  labels <- as.character(p$data$stat_var)
  expect_equal(p$data$n, c(2L, 1L, 1L, 1L))
  expect_equal(labels[3], "2020-01-03")
  expect_true(all(startsWith(labels[1:2], "2020-01-01")))
  palette <- stats::setNames(c("red", "blue", "green"), labels[1:3])
  q <- cat_test_plot(d[5:1, , drop = FALSE], "A", stat = "count", NA_stat = TRUE,
                    palette = palette)
  fills <- stats::setNames(as.character(ggplot2::ggplot_build(q)$data[[1]]$fill),
                           as.character(q$data$stat_var))
  expect_equal(unname(fills[labels]), c("red", "blue", "green", "grey80"))
})

test_that("plt_cat matches colliding difftime membership across units", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = as.difftime(c(1e15, 1e15 + 1, 1e15), units = "secs"),
                  B = c(TRUE, FALSE, FALSE))
  positive <- as.difftime((1e15 + 1) / 60, units = "mins")
  p <- cat_test_plot(d, c("A", "B"), type = "upset",
                    stat_level = list(A = positive, B = TRUE))
  expect_equal(p$data$intersection, list("B", "A"))
})

test_that("plt_cat Venn keeps exact membership for colliding time labels", {
  skip_if_not_installed("ggVennDiagram")
  withr::local_pdf(NULL)
  values <- cat_test_time_collisions()$Date
  d <- data.frame(A = values[c(1, 2, 1)], B = c(TRUE, FALSE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "venn",
                    stat_level = list(A = values[2], B = TRUE))
  regions <- unique(p$layers[[1]]$data[c("id", "count")])
  expect_equal(sort(regions$count), c(0, 1, 1))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
})

test_that("plt_cat resolves exact membership for AsIs dates and elapsed times", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  dates <- as.Date("2026-11-05") + c(0, 0.25, 1)
  delays <- as.difftime(c(1, 2, 3), units = "hours")
  inputs <- list(list(dates, dates[2]), list(delays, as.difftime(120, units = "mins")))
  for (input in inputs) {
    d <- data.frame(A = I(input[[1]]), B = c(FALSE, FALSE, TRUE))
    p <- cat_test_plot(d, c("A", "B"), type = "upset",
                      stat_level = list(A = input[[2]], B = TRUE))
    expect_equal(p$data$intersection, list("A", "B"))
  }
})

test_that("plt_cat treats signed-zero time values as one category", {
  inputs <- list(
    Date = structure(c(-0, 0), class = "Date"),
    POSIXct = structure(c(-0, 0), class = c("POSIXct", "POSIXt"), tzone = "UTC"),
    difftime = structure(c(-0, 0), class = "difftime", units = "secs")
  )
  if (requireNamespace("lubridate", quietly = TRUE)) {
    inputs$Duration <- lubridate::dseconds(c(-0, 0))
  }
  for (values in inputs) {
    data <- data.frame(value = 1:4)
    data$group <- values[c(1, 1, 2, 2)]
    invisible(capture.output(p <- suppressMessages(plt_cat(data, "group", stat = "count"))))
    expect_identical(p$data$n, 4L)
    expect_length(levels(p$data$stat_var), 1L)
  }
})

test_that("plt_cat preserves time values and their original missingness", {
  skip_if_not_installed("lubridate")
  dates <- as.POSIXct(c("2020-01-01", "2020-01-02", NA), tz = "UTC")
  inputs <- list(dates, as.POSIXlt(dates), lubridate::dseconds(c(1, 2, NA)),
                 lubridate::seconds(c(1, 2, NA)),
                 lubridate::interval(dates, dates + c(3600, 7200, NA)))
  for (x in inputs) {
    d <- data.frame(group = c("one", "two", "three"))
    d[["category"]] <- x
    p <- cat_test_plot(d, "category", stat = "count")
    expect_equal(sum(p$data$n), 2L)
    expect_equal(as.character(p$data$stat_var), as.character(x[!is.na(x)]))
    q <- cat_test_plot(d, "category", stat = "count", NA_stat = TRUE)
    expect_equal(q$data$n, rep(1L, 3))
    expect_equal(sum(ggplot2::ggplot_build(q)$data[[1]]$fill == "grey80"), 1L)
  }
  d <- data.frame(category = c("A", "A", "B"), time = dates)
  p <- cat_test_plot(d, "category", split.by = "time", stat = "count", NA_stat = TRUE)
  expect_length(p, 3L)
  expect_equal(sum(vapply(seq_len(length(p)), function(i) sum(p[[i]]$data$n), 0)), 3)
})

test_that("plt_cat resolves positive membership before splitting", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(FALSE, FALSE, TRUE, TRUE), B = TRUE,
                  site = c("negative", "negative", "positive", "positive"))
  whole <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = "upset"))
  split <- cat_test_plot(d, c("A", "B"), type = "upset", split.by = "site")
  expect_equal(split[[1]]$data$intersection, whole$data$intersection[1:2])
  expect_equal(split[[1]]$data$intersection, list("B", "B"))
  expect_equal(split[[2]]$data$intersection, whole$data$intersection[3:4])
  explicit <- cat_test_plot(d, c("A", "B"), type = "upset", split.by = "site",
                           stat_level = list(A = FALSE, B = TRUE))
  expect_equal(explicit[[1]]$data$intersection, rep(list(c("A", "B")), 2))
  expect_equal(explicit[[2]]$data$intersection, list("B", "B"))
})

test_that("plt_cat chord records drawable output on a file device", {
  skip_if_not_installed("circlize")
  skip_if_not_installed("ragg")
  skip_if_not_installed("RegR")
  withr::local_pdf(NULL, width = 7, height = 7)
  device <- grDevices::dev.cur()
  output <- withr::local_tempfile(fileext = ".pdf")
  p <- cat_test_plot(data.frame(A = c("a", "b", "a"), B = c("x", "y", "y")),
                     c("A", "B"), type = "chord", save = list(filename = output))
  expect_s3_class(p, "recordedplot")
  expect_identical(grDevices::dev.cur(), device)
  expect_true(file.exists(output))
  pixels <- local({
    capture <- ragg::agg_capture(width = 300, height = 300, units = "px")
    on.exit(grDevices::dev.off())
    grDevices::replayPlot(p)
    capture()
  })
  expect_gt(length(unique(as.vector(pixels))), 1L)
})

test_that("plt_cat upset handles one observation and singleton facets", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = TRUE, B = TRUE)
  p <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = "upset", stat_level = TRUE))
  expect_equal(p$data$intersection, list(c("A", "B")))
  expect_equal(sum(ggplot2::ggplot_build(p)$data[[1]]$count), 1)
  d <- data.frame(A = c(TRUE, FALSE), B = TRUE, site = c("one", "two"))
  p <- cat_test_plot(d, c("A", "B"), type = "upset", split.by = "site", stat_level = TRUE)
  expect_equal(p[[1]]$data$intersection, list(c("A", "B")))
  expect_equal(p[[2]]$data$intersection, list("B"))
  expect_equal(vapply(seq_len(length(p)), function(i) {
    sum(ggplot2::ggplot_build(p[[i]])$data[[1]]$count)
  }, 0), c(1, 1))
})

test_that("plt_cat upset applies alpha without changing intersection counts", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, FALSE, TRUE, FALSE), B = TRUE,
                  site = rep(c("one", "two"), each = 2))
  for (alpha in c(0, 0.35, 1)) {
    p <- cat_test_plot(d, c("A", "B"), type = "upset", alpha = alpha)
    bars <- ggplot2::ggplot_build(p)$data[[1]]
    expect_equal(bars$alpha, rep(alpha, 2))
    expect_equal(bars$count, c(2, 2))
  }
  p <- cat_test_plot(d, c("A", "B"), type = "upset", alpha = 0.35, split.by = "site")
  for (i in seq_len(length(p))) {
    bars <- ggplot2::ggplot_build(p[[i]])$data[[1]]
    expect_equal(bars$alpha, rep(0.35, 2))
    expect_equal(bars$count, c(1, 1))
  }
})

test_that("plt_cat excludes unused selectors before checking and filtering", {
  skip_if_not_installed("circlize")
  original <- getFromNamespace(".plt_cat_chord", "UtilsR")
  received <- NULL
  local_mocked_bindings(.plt_cat_chord = function(data, stat.by, ...) {
    received <<- list(n = nrow(data), columns = stat.by)
    original(data, stat.by, ...)
  }, .package = "UtilsR")
  d <- data.frame(A = c("a", "b", "a"), B = c("x", "x", "y"), extra = c("z", NA, "z"))
  expect_warning(p <- cat_test_plot(d, c("A", "B", "extra"), type = "chord"), "first 2")
  expect_s3_class(p, "recordedplot")
  expect_equal(received, list(n = 3L, columns = c("A", "B")))
  d <- data.frame(A = rep(c("a", "b"), 51), extra = seq_len(102))
  expect_warning(p <- cat_test_plot(d, c("A", "extra"), stat = "count"), "first element")
  expect_equal(sum(p$data$n), 102L)
  expect_warning(p <- cat_test_plot(d, c("A", "absent"), stat = "count"), "first element")
  expect_equal(sum(p$data$n), 102L)
})

test_that("plt_cat chord drops unused levels before constructing frequencies", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(A = factor(c("a1", "a2"), levels = paste0("a", seq_len(50000))),
                  B = factor(c("b1", "b2"), levels = paste0("b", seq_len(50000))))
  captured <- NULL
  original <- circlize::chordDiagram
  local_mocked_bindings(chordDiagram = function(x, ...) {
    captured <<- x
    original(x, ...)
  }, .package = "circlize")
  p <- cat_test_plot(d, c("A", "B"), type = "chord", palette = "red")
  expect_s3_class(p, "recordedplot")
  expect_equal(dim(captured), c(2L, 2L))
  expect_equal(unname(captured), diag(2))
})

test_that("plt_cat chord rejects impossible observed frequency grids early", {
  skip_if_not_installed("circlize")
  d <- data.frame(A = factor(seq_len(50000)), B = factor(seq_len(50000)))
  expect_error(cat_test_plot(d, c("A", "B"), type = "chord", force = TRUE,
                            palette = "red"), "chord frequency table.*2\\^31")
})

test_that("plt_cat chord preserves blank categories alongside space categories", {
  skip_if_not_installed("circlize")
  withr::local_pdf(NULL)
  d <- data.frame(A = c("", "a", " ", ""), B = c("b", "c", "b", ""))
  palette <- stats::setNames(c("red", "blue", "green", "orange", "purple"),
                             c("", "a", " ", "b", "c"))
  captured <- NULL
  original <- circlize::chordDiagram
  local_mocked_bindings(chordDiagram = function(x, grid.col, ...) {
    captured <<- list(counts = x, colors = grid.col)
    original(x, grid.col = grid.col, ...)
  }, .package = "circlize")
  p <- cat_test_plot(d, c("A", "B"), type = "chord", palette = palette)
  expect_s3_class(p, "recordedplot")
  blank <- setdiff(names(captured$colors), names(palette))
  expect_length(blank, 1L)
  expect_match(blank, "^ +$")
  expect_identical(unname(captured$colors[blank]), "red")
  expect_identical(captured$colors[names(palette)[-1]], palette[-1])
  expected <- table(factor(d$A, levels = unique(d$A)),
                    factor(d$B, levels = unique(d$B)))
  expect_equal(unname(captured$counts), unname(unclass(expected)))
  expect_null(grDevices::replayPlot(p))
})

test_that("plt_cat chord matches sector colours by name with unused levels", {
  skip_if_not_installed("circlize")
  d <- data.frame(A = factor(c("a", "b", "a"), levels = c("a", "unused", "b")),
                  B = c("x", "y", "x"))
  captured <- NULL
  original <- circlize::chordDiagram
  local_mocked_bindings(chordDiagram = function(x, grid.col, ...) {
    captured <<- grid.col
    original(x, grid.col = grid.col, ...)
  }, .package = "circlize")
  palette <- c(y = "orange", b = "blue", a = "red", x = "green")
  p <- cat_test_plot(d, c("A", "B"), type = "chord", palette = palette)
  expect_s3_class(p, "recordedplot")
  expect_identical(captured[names(palette)], palette)
  q <- cat_test_plot(d, c("A", "B"), type = "chord", palette = c("red", "blue", "green", "orange"))
  expect_identical(captured[c("a", "b", "x", "y")],
                   c(a = "red", b = "blue", x = "green", y = "orange"))
})

test_that("plt_cat area rejects layouts without two displayed group positions", {
  d <- data.frame(category = c("A", "B", "A"), group = "one")
  expect_error(cat_test_plot(d, "category", type = "area"), "group.by.*two displayed")
  expect_error(cat_test_plot(d, "category", "group", type = "area"), "group.by.*two displayed")
  d$group <- factor(d$group, levels = c("one", "two"))
  p <- cat_test_plot(d, "category", "group", type = "area", keep_empty = TRUE)
  expect_gt(nrow(ggplot2::ggplot_build(p)$data[[1]]), 0L)
  d <- data.frame(category = rep(c("A", "B"), 2),
                  group = rep(c("one", "two"), each = 2), site = rep(c("x", "y"), each = 2))
  expect_error(cat_test_plot(d, "category", "group", type = "area", split.by = "site"),
               "group.by.*two displayed")
})

test_that("plt_cat serialized plots do not retain unrelated input columns", {
  make_plot <- function(extra, split) {
    set.seed(12)
    d <- data.frame(category = rep(c("A", "B"), 1000),
                    group = rep(c("one", "two"), each = 1000),
                    site = rep(c("x", "y"), each = 1000))
    if (extra) for (i in seq_len(25)) d[[paste0("unused", i)]] <- stats::rnorm(nrow(d))
    p <- NULL
    invisible(utils::capture.output(p <- suppressMessages(UtilsR::plt_cat(
      d, "category", "group", split.by = if (split) "site" else NULL))))
    p
  }
  environment(make_plot) <- globalenv()
  files <- c(withr::local_tempfile(), withr::local_tempfile())
  for (split in c(FALSE, TRUE)) {
    small <- make_plot(FALSE, split)
    large <- make_plot(TRUE, split)
    if (split) {
      for (i in seq_len(length(small))) {
        expect_equal(ggplot2::ggplot_build(small[[i]])$data,
                     ggplot2::ggplot_build(large[[i]])$data)
      }
    } else {
      expect_equal(ggplot2::ggplot_build(small)$data, ggplot2::ggplot_build(large)$data)
    }
    saveRDS(small, files[1], compress = FALSE)
    saveRDS(large, files[2], compress = FALSE)
    expect_lt(diff(file.info(files)$size), 32768)
  }
})

test_that("plt_cat area and trend retain zero frequencies for interpolation", {
  d <- data.frame(category = factor(c("A", "A", "A", "A", "B", "B", "B")),
                  group = factor(c("G1", "G1", "G3", "G3", "G1", "G2", "G3")))
  for (type in c("area", "trend")) {
    p <- cat_test_plot(d, "category", "group", type = type, label = TRUE)
    b <- ggplot2::ggplot_build(p)
    expect_lte(max(b$data[[1]]$ymax), 100 + 1e-8)
    expect_equal(p$data$n[p$data$stat_var == "A" & p$data$group_var == "G2"], 0L)
    expect_false("0.0%" %in% b$data[[length(b$data)]]$label)
  }
})

cat_con_data <- function() {
  set.seed(7)
  data.frame(
    stage = factor(sample(c("I", "II", "III", "IV"), 120, TRUE)),
    sex = factor(sample(c("Female", "Male"), 120, TRUE)),
    site = factor(sample(c("A", "B", "C"), 120, TRUE)),
    age = stats::rnorm(120, 60, 10),
    bmi = stats::rnorm(120, 25, 4)
  )
}

test_that("plt_cat area endpoint labels stay inside the rendered panel", {
  d <- data.frame(category = factor(c("A", "A", "A", "A", "B", "B", "B")),
                  group = factor(c("G1", "G1", "G3", "G3", "G1", "G2", "G3")))
  withr::local_pdf(NULL, width = 4, height = 4)
  grid::pushViewport(grid::viewport(width = grid::unit(3, "inches"),
                                    height = grid::unit(3, "inches")))
  withr::defer(grid::popViewport())
  for (position in c("stack", "dodge")) {
    p <- cat_test_plot(d, "category", "group", type = "area",
                      position = position, label = TRUE)
    g <- ggplot2::ggplotGrob(p)
    panel <- g$grobs[[which(g$layout$name == "panel")]]
    tree <- panel$children[[which(vapply(panel$children, inherits, logical(1), "textrepeltree"))]]
    labels <- grid::makeContent(tree)$children
    labels <- labels[grepl("^textrepelgrob", names(labels))]
    expect_gt(length(labels), 0L)
    bounds <- vapply(labels, function(x) {
      c(grid::convertX(grid::grobX(x, "west"), "npc", valueOnly = TRUE),
        grid::convertX(grid::grobX(x, "east"), "npc", valueOnly = TRUE))
    }, numeric(2))
    expect_gte(min(bounds[1, ]), 0)
    expect_lte(max(bounds[2, ]), 1)
  }
})

test_that("plt_cat measures only the final split canvas", {
  skip_if_not_installed("RegR")
  original <- getFromNamespace(".save_sized", "UtilsR")
  calls <- 0L
  local_mocked_bindings(.save_sized = function(...) {
    calls <<- calls + 1L
    original(...)
  }, .package = "UtilsR")
  d <- data.frame(category = rep(c("A", "B"), 3), site = rep(c("x", "y", "z"), each = 2))
  p <- cat_test_plot(d, "category", split.by = "site")
  expect_equal(calls, 1L)
  expect_s3_class(p, "patchwork")
  expect_length(attr(p, "plot_size"), 2L)
  expect_equal(sum(vapply(seq_len(length(p)), function(i) sum(p[[i]]$data$n), 0)), 6)
})

test_that("plt_cat set plots honour labels titles and theme controls", {
  d <- data.frame(A = c(TRUE, TRUE, FALSE), B = c(TRUE, FALSE, TRUE))
  for (type in c("upset", "venn", "sankey")) {
    skip_if_not_installed(switch(type, upset = "ggupset", venn = "ggVennDiagram", sankey = "ggsankey"))
    p <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = type, label = FALSE,
                      base_size = 20, legend.position = "none", xlab = "X", ylab = "Y"))
    labs <- if (exists("get_labs", asNamespace("ggplot2"))) ggplot2::get_labs(p) else p$labels
    expect_equal(labs$x, "X")
    expect_equal(labs$y, "Y")
    expect_equal(p$theme$text$size, 20)
    expect_equal(p$theme$legend.position, "none")
    if (type == "upset") {
      expect_false(any(vapply(p$layers, function(l) inherits(l$geom, "GeomTextRepel"), logical(1))))
      q <- cat_test_plot(d, c("A", "B"), type = type, label = TRUE, label.size = 5, label.fg = "brown")
      layer <- ggplot2::ggplot_build(q)$data[[2]]
      expect_equal(unique(layer$colour), "brown")
      expect_equal(unique(layer$size), 5)
    }
    if (type == "venn") {
      labels <- unlist(lapply(ggplot2::ggplot_build(p)$data, function(x) x$label))
      expect_false(any(grepl("[0-9]", labels)))
    }
  }
})

test_that("plt_cat rejects malformed selectors empty input and unused arguments", {
  d <- data.frame(A = c(TRUE, FALSE), B = c(FALSE, TRUE))
  expect_error(plt_cat(d, "A", linewidth = 5), "unused|must be empty")
  expect_error(plt_cat(d, "A", group.by = c("A", "B")), "group.by.*single")
  expect_error(plt_cat(d, c("A", "A"), type = "upset"), "unique")
  expect_error(plt_cat(d[FALSE, ], "A"), "observation")
  expect_error(plt_cat(data.frame(A = c(NA, NA)), "A"), "observation")
  expect_error(plt_cat(d, c("A", "B"), split.by = "A", type = "chord"), "split.by.*chord")
  expect_error(plt_cat(d, "A", NA_stat = NA), "NA_stat")
  bad <- data.frame(A = I(list(1, 2)))
  expect_error(plt_cat(bad, "A"), "one-dimensional")
})

test_that("plt_cat checks explicit positive level mappings", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, FALSE), B = c(FALSE, TRUE))
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = list(A = TRUE)), "stat_level.*B")
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = c(TRUE, FALSE, TRUE)), "stat_level")
})

test_that("plt_cat dodge labels follow bar widths and overlay values", {
  d <- data.frame(category = c("A", "A", "B", "A", "A", "A", "B", "C"),
                  group = rep(c("G1", "G2"), c(3, 5)))
  for (type in c("bar", "rose", "trend", "ring")) {
    p <- cat_test_plot(d, "category", "group", type = type, stat = "count",
                      position = "dodge", label = TRUE)
    b <- ggplot2::ggplot_build(p)
    bar <- which(vapply(p$layers, function(l) inherits(l$geom, "GeomCol"), logical(1)))
    labs <- b$data[[length(b$data)]]
    expect_equal(as.numeric(labs$x), as.numeric(b$data[[bar]]$x))
    expect_equal(labs$y, b$data[[bar]]$ymax)
  }
  p <- cat_test_plot(d, "category", "group", type = "area", stat = "count",
                    position = "dodge", label = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$data[[length(b$data)]]$y, p$data$value)
})

test_that("plt_cat counts columns with non syntactic names directly", {
  for (name in c("Tumor stage", "a+b", "x`y", ".")) {
    d <- setNames(data.frame(category = c("I", "II", "I", "III"),
                             group = c("a", "a", "b", "b")), c(name, "Group name"))
    p <- cat_test_plot(d, name, "Group name")
    expect_equal(p$data$n, rep(1L, 4))
    expect_equal(p$data$value, rep(50, 4))
    expect_equal(names(p$data), c("stat_var", "group_var", "n", "value", "label_text"))
    expect_s3_class(p$data, "tbl_df")
    q <- cat_test_plot(d, name, stat = "count")
    expect_equal(q$data$n, c(2L, 1L, 1L))
  }
})

test_that("plt_cat keeps unused category and group levels when requested", {
  d <- data.frame(category = factor(c("A", "B", "A"), levels = c("A", "B", "C")),
                  group = factor(c("G1", "G2", "G1"), levels = c("G1", "G2", "G3")))
  for (type in c("bar", "dot", "area", "trend")) {
    p <- cat_test_plot(d, "category", "group", type = type, stat = "count", keep_empty = TRUE)
    b <- ggplot2::ggplot_build(p)
    expect_equal(nrow(p$data), 9L)
    expect_equal(b$layout$panel_params[[1]]$x$get_labels(), c("G1", "G2", "G3"))
    expect_equal(b$plot$scales$get_scales("fill")$get_limits(), c("A", "B", "C"))
    expect_equal(sum(p$data$n), 3L)
  }
  q <- cat_test_plot(d, "category", "group", keep_empty = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x$get_labels(), c("G1", "G2"))
})

test_that("plt_cat ignores set grouping during filtering and cardinality checks", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, TRUE, FALSE), B = c(TRUE, FALSE, TRUE),
                  group = c(NA, "G", "G"))
  p <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = "upset"))
  expect_warning(q <- cat_test_plot(d, c("A", "B"), "group", type = "upset"), "ignored")
  expect_equal(nrow(q$data), nrow(p$data))
  many <- data.frame(A = rep(TRUE, 101), B = rep(FALSE, 101), group = seq_len(101))
  expect_warning(q <- cat_test_plot(many, c("A", "B"), "group", type = "upset"), "ignored")
  expect_equal(nrow(q$data), 101L)
})

test_that("plt_cat includes missing split groups and preserves missing colours", {
  d <- data.frame(category = c("A", NA, "A", NA),
                  site = factor(c("one", "one", NA, NA), exclude = NULL))
  p <- cat_test_plot(d, "category", split.by = "site", stat = "count",
                    NA_stat = TRUE, NA_color = "grey80", palette = "red")
  expect_length(p, 2L)
  expect_equal(sum(vapply(seq_len(length(p)), function(i) sum(p[[i]]$data$n), 0)), 4)
  for (i in seq_len(length(p))) {
    expect_equal(sum(ggplot2::ggplot_build(p[[i]])$data[[1]]$fill == "grey80"), 1L)
  }
})

test_that("plt_cat distinguishes literal NA labels from missing observations", {
  d <- data.frame(category = factor(c("NA", "A", NA)))
  p <- cat_test_plot(d, "category", NA_stat = TRUE, stat = "count",
                    palette = c(A = "red", `NA` = "blue"), NA_color = "grey80")
  b <- ggplot2::ggplot_build(p)
  expect_equal(p$data$n, rep(1L, 3))
  expect_equal(length(unique(as.character(p$data$stat_var))), 3L)
  expect_equal(b$data[[1]]$fill[p$data$stat_var == "NA"], "blue")
  expect_equal(sum(b$data[[1]]$fill == "grey80"), 1L)
})

test_that("plt_cat handles explicit missing factor levels", {
  d <- data.frame(category = factor(c("A", NA), exclude = NULL))
  p <- cat_test_plot(d, "category", stat = "count")
  expect_equal(sum(p$data$n), 1L)
  q <- cat_test_plot(d, "category", stat = "count", NA_stat = TRUE)
  expect_equal(sum(q$data$n), 2L)
  expect_equal(sort(ggplot2::ggplot_build(q)$data[[1]]$fill), sort(c(pal_lancet[1], "grey80")))
})

test_that("plt_cat respects SPSS user missing values before factor conversion", {
  skip_if_not_installed("haven")
  d <- data.frame(category = haven::labelled_spss(c(1, 99, 1), na_values = 99))
  p <- cat_test_plot(d, "category", stat = "count")
  expect_equal(as.character(p$data$stat_var), "1")
  expect_equal(p$data$n, 2L)
  q <- cat_test_plot(d, "category", stat = "count", NA_stat = TRUE)
  expect_equal(sort(q$data$n), c(1L, 2L))
  expect_false("99" %in% as.character(q$data$stat_var))
})

test_that("plt_cat pie and ring use shared radii and stable angular totals", {
  d <- data.frame(category = factor(c("A", "A", "B")))
  for (type in c("pie", "ring")) {
    builds <- lapply(c(FALSE, TRUE), function(label) {
      p <- cat_test_plot(d, "category", type = type, stat = "count", label = label)
      expect_warning(g <- ggplot2::ggplotGrob(p), NA)
      b <- ggplot2::ggplot_build(p)
      expect_length(unique(b$data[[1]]$x), 1L)
      expect_equal(sort(b$data[[1]]$ymax - b$data[[1]]$ymin), c(1, 2))
      expect_equal(b$layout$panel_params[[1]]$theta.range, c(0, 3))
      expect_false(anyNA(b$plot$scales$get_scales("fill")$get_limits()))
      b
    })
    expect_equal(builds[[1]]$data[[1]], builds[[2]]$data[[1]])
    labels <- builds[[2]]$data[[2]]
    expect_equal(as.numeric(labels$x), as.numeric(builds[[2]]$data[[1]]$x))
    expect_equal(labels$y, (builds[[2]]$data[[1]]$ymin + builds[[2]]$data[[1]]$ymax) / 2)
  }
})

test_that("plt_cat background helper preserves displayed group order", {
  d <- data.frame(category = factor(rep(c("Yes", "No", "Yes"), 3)),
                  group = factor(rep(c("C", "B", "A"), each = 3), levels = c("C", "B", "A")),
                  region = rep(c("R3", "R2", "R1"), each = 3))
  d$group <- factor(d$group, levels = c("left", "C", "unused", "B", "A", "right"))
  for (keep in c(FALSE, TRUE)) {
    p <- suppressMessages(plt_cat(d, "category", "group", position = "dodge", bg.by = "region",
                                  bg_palette = c("red", "blue", "green"), keep_empty = keep))
    b <- ggplot2::ggplot_build(p)
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    rects <- b$data[[which(kinds == "GeomRect")]]
    position <- match("B", b$layout$panel_params[[1L]]$x$get_labels())
    expect_equal(as.character(rects$fill[rects$xmin <= position & rects$xmax >= position]), "blue")
    expect_equal(b$layout$panel_params[[1L]]$x$get_labels(),
                 if (keep) c("left", "C", "unused", "B", "A", "right") else c("C", "B", "A"))
    if (keep) {
      expect_false(any(rects$xmin <= 1 & rects$xmax >= 1))
      expect_false(any(rects$xmin <= 6 & rects$xmax >= 6))
    }
  }
})

test_that("plt_cat saves at its page size and reports a split figure once", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_cat)), 1), "save")
  d <- cat_con_data()
  f <- withr::local_tempfile(fileext = ".pdf")
  for (type in c("bar", "pie")) {
    out <- cat_test_output(p <- plt_cat(
      d, stat.by = "stage", group.by = "sex", type = type, save = list(filename = f)))
    expect_saved_at_plot_size(out, p)
  }
  out <- cat_test_output(p <- plt_cat(
    d, stat.by = "stage", group.by = "sex", split.by = "site",
    save = list(filename = f)))
  expect_equal(sum(grepl("laid out for", out)), 1L)
  expect_saved_at_plot_size(out, p)
  utils::capture.output(one <- suppressMessages(plt_cat(d, stat.by = "stage",
                                                        group.by = "sex")))
  expect_gt(attr(p, "plot_size")[[1]], attr(one, "plot_size")[[1]])
})

test_that("plt_con saves at its page size and refuses a list of plots", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_con)), 1), "save")
  d <- cat_con_data()
  f <- withr::local_tempfile(fileext = ".pdf")
  out <- cli::cli_fmt(p <- suppressMessages(suppressWarnings(plt_con(
    d, stat.by = "age", group.by = "stage", save = list(filename = f)))))
  expect_saved_at_plot_size(out, p)
  out <- cli::cli_fmt(p <- suppressMessages(suppressWarnings(plt_con(
    d, stat.by = c("age", "bmi"), group.by = "stage", split.by = "sex",
    save = list(filename = f)))))
  expect_equal(sum(grepl("laid out for", out)), 1L)
  expect_saved_at_plot_size(out, p)
  expect_error(suppressMessages(suppressWarnings(plt_con(
    d, stat.by = c("age", "bmi"), group.by = "stage", combine = FALSE,
    save = list(filename = f)))), "list of plots")
})

test_that("plt_cat trend dodge keeps areas within the category positions", {
  d <- data.frame(category = c("A", "B", "A", "B"),
                  group = c("G1", "G1", "G2", "G2"),
                  region = c("North", "North", "South", "South"))
  for (flip in c(FALSE, TRUE)) {
    p <- cat_test_plot(d, "category", "group", type = "trend", stat = "count",
                      position = "dodge", label = TRUE, flip = flip)
    b <- ggplot2::ggplot_build(p)
    expect_true(all(b$data[[1]]$x >= 0.69 & b$data[[1]]$x <= 2.31))
    expect_equal(range(b$data[[1]]$ymax), c(0, 1))
    expect_equal(as.numeric(b$data[[2]]$x), as.numeric(b$data[[3]]$x))
    q <- cat_test_plot(d, "category", "group", type = "trend", stat = "count",
                      position = "dodge", label = TRUE, flip = flip, bg.by = "region")
    expect_equal(ggplot2::ggplot_build(q)$data[-1], b$data)
  }
  stacked <- cat_test_plot(d, "category", "group", type = "trend", stat = "count")
  expect_equal(max(ggplot2::ggplot_build(stacked)$data[[1]]$ymax), 2)
})

test_that("plt_cat split figures show overall titles once", {
  d <- data.frame(category = c("A", "B", "A", "B"),
                  site = c("one", "one", "two", "two"))
  p <- cat_test_plot(d, "category", split.by = "site", title = "Overall title",
                    subtitle = "Overall subtitle", base_size = 20)
  labels <- cat_test_text(patchwork::patchworkGrob(p))
  expect_equal(sum(labels == "Overall title"), 1L)
  expect_equal(sum(labels == "Overall subtitle"), 1L)
  expect_true(all(c("one", "two") %in% labels))
  expect_equal(p$patches$annotation$theme$text$size, 20)
  single <- cat_test_plot(d, "category", title = "Single title", subtitle = "Single subtitle")
  labels <- cat_test_text(ggplot2::ggplotGrob(single))
  expect_true(all(c("Single title", "Single subtitle") %in% labels))
})

test_that("plt_cat split figures collect partially overlapping fill legends", {
  d <- data.frame(category = factor(c("A", "B", "A", "C"),
                                   levels = c("C", "B", "A", "unused")),
                  site = c("one", "one", "two", "two"))
  for (type in c("bar", "pie", "ring", "trend", "dot")) {
    p <- cat_test_plot(d, "category", split.by = "site", type = type,
                      palette = c(C = "red", B = "blue", A = "green"))
    g <- patchwork::patchworkGrob(p)
    guide <- g$grobs[[which(g$layout$name == "guide-box")]]
    labels <- cat_test_text(guide)
    expect_equal(labels[labels %in% c("A", "B", "C", "unused")], c("C", "B", "A"))
    expect_equal(nrow(p[[1]]$data), 2L)
    expect_equal(as.character(p[[1]]$data$stat_var), c("B", "A"))
    expect_equal(ggplot2::ggplot_build(p[[2]])$plot$scales$get_scales("fill")$map(c("C", "A")),
                 c("red", "green"))
  }
})

test_that("plt_cat rejects Venn inputs beyond seven sets clearly", {
  d <- as.data.frame(setNames(rep(list(c(TRUE, FALSE, TRUE)), 8), LETTERS[1:8]))
  expect_error(plt_cat(d, names(d), type = "venn"), "seven.*upset")
  skip_if_not_installed("ggVennDiagram")
  p <- suppressMessages(cat_test_plot(d, names(d)[1:7], type = "venn"))
  expect_s3_class(p, "ggplot")
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
})

test_that("plt_cat Sankey stages accept backend reserved column names", {
  skip_if_not_installed("ggsankey")
  d <- data.frame(first = c("a", "b", "a"), second = c("x", "y", "x"))
  baseline <- suppressWarnings(cat_test_plot(d, names(d), type = "sankey"))
  expected <- ggplot2::ggplot_build(baseline)$data
  # Stage labels differ by design; compare next-stage positions numerically.
  for (i in seq_along(expected)) {
    if (is.factor(expected[[i]]$next_x)) expected[[i]]$next_x <- as.numeric(expected[[i]]$next_x)
  }
  for (stage_names in list(c("..r", "second"), c("node", "value"), c(".stage1", "Tumor stage"))) {
    names(d) <- stage_names
    original <- d
    p <- suppressWarnings(cat_test_plot(d, names(d), type = "sankey"))
    b <- ggplot2::ggplot_build(p)
    for (i in seq_along(b$data)) {
      if (is.factor(b$data[[i]]$next_x)) b$data[[i]]$next_x <- as.numeric(b$data[[i]]$next_x)
    }
    expect_equal(b$data, expected)
    expect_equal(b$layout$panel_params[[1]]$x$get_labels(), stage_names)
    expect_identical(d, original)
  }
})

test_that("plt_cat named palettes map empty string categories", {
  d <- data.frame(category = c("", "A", "", NA), site = c("one", "one", "two", "two"))
  colors <- setNames(c("red", "blue"), c("", "A"))
  p <- cat_test_plot(d, "category", stat = "count", palette = colors, NA_stat = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$data[[1]]$fill[as.character(p$data$stat_var) == ""], "red")
  expect_equal(b$data[[1]]$fill[as.character(p$data$stat_var) == "A"], "blue")
  expect_equal(sum(p$data$n), 4L)
  expect_equal(sum(b$data[[1]]$fill == "grey80"), 1L)
  q <- cat_test_plot(d, "category", split.by = "site", palette = colors, NA_stat = TRUE)
  expect_equal(ggplot2::ggplot_build(q[[2]])$data[[1]]$fill, c("red", "grey80"))
  expect_error(plt_cat(d, "category", palette = setNames(c("red", "blue"), c("", ""))), "unique")
})

test_that("plt_cat validates split layout dimensions before plotting", {
  d <- data.frame(category = c("A", "B", "A"), site = c("one", "two", "three"))
  for (arg in c("facet_nrow", "facet_ncol")) {
    for (value in list(0, -1, 1.5, NA_real_, Inf, TRUE, "2", c(1, 2), matrix(1))) {
      args <- list(data = d, stat.by = "category", split.by = "site")
      args[[arg]] <- value
      expect_error(do.call(plt_cat, args), paste0(arg, ".*positive integer"))
    }
  }
  expect_error(plt_cat(d, "category", split.by = "site", facet_nrow = 1, facet_ncol = 2),
               "facet_nrow.*facet_ncol.*panels")
  p <- cat_test_plot(d, "category", split.by = "site", facet_nrow = 1, facet_ncol = 3)
  expect_length(p, 3L)
  expect_s3_class(patchwork::patchworkGrob(p), "gtable")
})

test_that("plt_cat excludes ignored background columns before validation", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, FALSE, TRUE), B = c(TRUE, TRUE, FALSE),
                  group = c("one", "two", "one"))
  for (args in list(list(stat.by = "A", position = "dodge"),
                   list(stat.by = "A", group.by = "group"),
                   list(stat.by = "A", group.by = "group", type = "pie"),
                   list(stat.by = c("A", "B"), type = "upset"))) {
    baseline <- do.call(cat_test_plot, c(list(data = d), args))
    expect_warning(p <- do.call(cat_test_plot, c(list(data = d, bg.by = "absent"), args)),
                   "bg.by.*[Ii]gnored")
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(baseline)$data)
  }
  expect_error(plt_cat(d, "A", "group", position = "dodge", bg.by = "absent"), "absent.*not found")
})

test_that("plt_cat Sankey compresses repeated paths without changing flows", {
  skip_if_not_installed("ggsankey")
  d <- data.frame(A = factor(c("a", "b", "a", "a", NA), levels = c("b", "a", "unused")),
                  B = c("x", "y", "x", "x", "x"), C = c("u", "v", "u", "u", "v"))
  for (keep_na in c(FALSE, TRUE)) {
    p <- suppressWarnings(cat_test_plot(d, names(d), type = "sankey", NA_stat = keep_na))
    expect_equal(nrow(p$data), if (keep_na) 9L else 6L)
    expect_equal(sum(p$data$value[p$data$x == "A"]), if (keep_na) 5 else 4)
    expect_equal(sort(p$data$value[p$data$x == "A"]), if (keep_na) c(1, 1, 3) else c(1, 3))
    expanded <- p
    expanded$data <- p$data[rep(seq_len(nrow(p$data)), p$data$value), , drop = FALSE]
    expanded$data$value <- 1L
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(expanded)$data)
  }
})

test_that("plt_cat warns when UpSet hides intersections beyond twenty", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- expand.grid(A = c(FALSE, TRUE), B = c(FALSE, TRUE), C = c(FALSE, TRUE),
                   D = c(FALSE, TRUE), E = c(FALSE, TRUE))[-1, ]
  expect_warning(p <- cat_test_plot(d, names(d), type = "upset", stat_level = TRUE,
                                   label = TRUE), "20.*31")
  expect_warning(b <- ggplot2::ggplot_build(p), NA)
  expect_equal(nrow(b$data[[1]]), 20L)
  expect_equal(sum(b$data[[1]]$count), 20L)
  expect_equal(nrow(b$data[[2]]), 20L)
  expect_warning(q <- cat_test_plot(d[1:4, ], names(d), type = "upset", stat_level = TRUE), NA)
  expect_equal(sum(ggplot2::ggplot_build(q)$data[[1]]$count), 4L)
})

test_that("plt_cat retains empty UpSet facets with a visible placeholder", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = c(TRUE, FALSE), B = c(TRUE, FALSE), site = c("positive", "negative"))
  p <- cat_test_plot(d, c("A", "B"), split.by = "site", type = "upset", title = "All sites")
  expect_length(p, 2L)
  expect_equal(sum(ggplot2::ggplot_build(p[[1]])$data[[1]]$count), 1L)
  empty <- ggplot2::ggplot_build(p[[2]])$data[[1]]
  expect_equal(empty$label, "\u65e0\u5339\u914d\u6210\u5458")
  expect_equal(nrow(p[[2]]$data), 0L)
  labels <- cat_test_text(patchwork::patchworkGrob(p))
  expect_true(all(c("All sites", "positive", "negative") %in% labels))
  expect_error(plt_cat(d[2, ], c("A", "B"), type = "upset", stat_level = TRUE), "No rows match")
})

test_that("plt_cat UpSet preserves set names containing its backend separator", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = c(TRUE, FALSE, FALSE), B = c(TRUE, FALSE, FALSE),
                  C = c(FALSE, TRUE, TRUE))
  names(d)[3] <- "A-__-__-_-B"
  p <- cat_test_plot(d, names(d), type = "upset", stat_level = TRUE, label = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(sort(b$data[[1]]$count), c(1, 2))
  expect_equal(sum(b$data[[1]]$count), 3)
  expect_true(all(names(d) %in% cat_test_text(ggplot2::ggplotGrob(p))))
  many <- expand.grid(A = c(FALSE, TRUE), B = c(FALSE, TRUE), C = c(FALSE, TRUE),
                      D = c(FALSE, TRUE), E = c(FALSE, TRUE))[-1, ]
  names(many)[3] <- names(d)[3]
  expect_warning(q <- cat_test_plot(many, names(many), type = "upset", stat_level = TRUE), "20.*31")
  expect_equal(ggplot2::ggplot_build(q)$data[[1]]$count, rep(1, 20))
})

test_that("plt_cat keeps distinct numeric values when their short labels coincide", {
  for (x in list(c(1e15, 1e15 + 1), c(1, 1 + .Machine$double.eps))) {
    d <- data.frame(A = c(x, NA))
    p <- cat_test_plot(d, "A", stat = "count", NA_stat = TRUE)
    expect_equal(p$data$n, rep(1L, 3))
    labels <- as.character(p$data$stat_var)[1:2]
    expect_identical(as.numeric(labels), x)
    expect_length(unique(labels), 2L)
    q <- cat_test_plot(data.frame(A = "x", g = x), "A", "g", stat = "count")
    expect_equal(q$data$n, c(1L, 1L))
  }
  p <- cat_test_plot(data.frame(A = c(1.2, 3.4)), "A")
  expect_equal(as.character(p$data$stat_var), c("1.2", "3.4"))
})

test_that("plt_cat keeps precise classed numeric and complex categories distinct", {
  skip_if_not_installed("haven")
  x <- c(1e15, 1e15 + 1, NA_real_)
  inputs <- list(I(x), haven::labelled(x),
                 haven::labelled_spss(c(x[1:2], 99), na_values = 99),
                 c(1 + 1i, (1 + .Machine$double.eps) + 1i, NA_complex_))
  for (values in inputs) {
    d <- data.frame(row = seq_along(values))
    d[["A"]] <- values
    p <- cat_test_plot(d, "A", stat = "count", NA_stat = TRUE)
    expect_equal(p$data$n, rep(1L, 3))
    expect_length(unique(as.character(p$data$stat_var)), 3L)
    q <- cat_test_plot(d, "A", stat = "count")
    expect_equal(q$data$n, c(1L, 1L))
  }
})

test_that("plt_cat resolves precise classed and complex positive values", {
  skip_if_not_installed("haven")
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  x <- c(1e15, 1e15 + 1, 1e15)
  inputs <- list(I(x), haven::labelled(x), haven::labelled_spss(x, na_values = 99),
                 c(1 + 1i, (1 + .Machine$double.eps) + 1i, 1 + 1i))
  for (values in inputs) {
    d <- data.frame(B = c(TRUE, FALSE, FALSE))
    d[["A"]] <- values
    p <- cat_test_plot(d, c("A", "B"), type = "upset",
                      stat_level = list(A = values[2], B = TRUE))
    expect_equal(p$data$intersection, list("B", "A"))
    expect_equal(ggplot2::ggplot_build(p)$data[[1]]$count, c(1, 1))
  }
})

test_that("plt_cat resolves numeric membership against precise category labels", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = c(1e15, 1e15 + 1, 1e15), B = c(TRUE, FALSE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "upset",
                    stat_level = list(A = 1e15 + 1, B = TRUE))
  expect_equal(p$data$intersection, list("B", "A"))
  expect_equal(ggplot2::ggplot_build(p)$data[[1]]$count, c(1, 1))
  if (requireNamespace("bit64", quietly = TRUE)) {
    d <- data.frame(A = bit64::as.integer64(c("9007199254740993", "9007199254740994")),
                    B = bit64::as.integer64(c("9007199254740994", "9007199254740993")))
    p <- cat_test_plot(d, c("A", "B"), type = "upset",
                      stat_level = bit64::as.integer64("9007199254740993"))
    expect_equal(p$data$intersection, list("A", "B"))
  }
})

test_that("plt_cat matches mixed integer64 selectors without lossy conversion", {
  skip_if_not_installed("ggupset")
  skip_if_not_installed("bit64")
  withr::local_options(lifecycle_verbosity = "quiet")
  ids <- bit64::as.integer64(c("1000000000000000", "1000000000000001", "1000000000000001"))
  draw <- function(a, target) {
    d <- data.frame(A = a, B = c(FALSE, TRUE, FALSE))
    cat_test_plot(d, c("A", "B"), type = "upset",
                  stat_level = list(A = target, B = TRUE))
  }
  expect_equal(draw(ids, 1e15)$data$intersection, list("A", "B"))
  expect_equal(draw(c(1e15, 2, 2), ids[1])$data$intersection, list("A", "B"))
  expect_error(draw(ids, 1.9), "stat_level.*integer64.*loss")
  expect_error(draw(c(2^53, 2, 2), bit64::as.integer64("9007199254740993")),
               "stat_level.*integer64.*loss")
})

test_that("plt_cat does not match a rounded numeric label as an exact value", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  near_one <- 1 + .Machine$double.eps
  d <- data.frame(A = c(near_one, 2, 2), B = c(FALSE, TRUE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "upset",
                    stat_level = list(A = 1, B = TRUE))
  expect_equal(p$data$intersection, list("B"))
  q <- cat_test_plot(d, c("A", "B"), type = "upset",
                    stat_level = list(A = near_one, B = TRUE))
  expect_equal(q$data$intersection, list("A", "B"))

  d <- data.frame(A = c(2, near_one, near_one), B = c(FALSE, FALSE, TRUE))
  p <- cat_test_plot(d, c("A", "B"), type = "upset")
  expect_equal(p$data$intersection, list("A", "B"))
})

test_that("plt_cat matches exact timestamps across time zones without label collisions", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  start <- as.POSIXct("2026-11-05 12:00:00", tz = "UTC")
  local_time <- as.POSIXct("2026-11-05 20:00:00", tz = "Asia/Shanghai")
  d <- data.frame(A = start + 0:2, B = c(FALSE, TRUE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "upset",
                    stat_level = list(A = local_time, B = TRUE))
  expect_equal(p$data$intersection, list("A", "B"))
})

test_that("plt_cat does not switch binary sets to observed negatives", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  for (negative in list(rep(FALSE, 3), factor(rep("No", 3), levels = c("No", "Yes")))) {
    d <- data.frame(A = negative, B = c(FALSE, TRUE, FALSE))
    p <- cat_test_plot(d, c("A", "B"), type = "upset")
    expect_equal(p$data$intersection, list("B"))
  }
  d <- data.frame(A = rep(FALSE, 3), B = c(FALSE, TRUE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "upset",
                     stat_level = list(A = FALSE, B = TRUE))
  expect_equal(p$data$intersection, list("A", c("A", "B"), "A"))
})

test_that("plt_cat UpSet excludes all-missing columns from automatic membership", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = rep(NA_character_, 3), B = c(FALSE, TRUE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "upset", NA_stat = TRUE)
  expect_equal(p$data$intersection, list("B"))
  q <- cat_test_plot(d, c("A", "B"), type = "upset", NA_stat = TRUE,
                    stat_level = list(A = "NA", B = TRUE))
  expect_equal(q$data$intersection, list("A", c("A", "B"), "A"))
})

test_that("plt_cat Venn keeps all-missing columns empty under automatic membership", {
  skip_if_not_installed("ggVennDiagram")
  d <- data.frame(A = rep(NA_real_, 3), B = c(FALSE, TRUE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "venn", NA_stat = TRUE)
  regions <- unique(p$layers[[1]]$data[c("id", "count")])
  expect_equal(sort(regions$count), c(0, 0, 1))
})

test_that("plt_cat split backgrounds keep one category colour mapping", {
  d <- data.frame(category = rep(c("A", "B"), 4),
                  group = rep(c("G1", "G2", "G2", "G3"), each = 2),
                  region = rep(c("North", "South", "South", "East"), each = 2),
                  site = rep(c("one", "two"), each = 4))
  for (type in c("bar", "trend", "dot")) for (colors in list(NULL, c("red", "blue", "green"))) {
    p <- cat_test_plot(d, "category", "group", split.by = "site", position = "dodge",
                      type = type, bg.by = "region", bg_palette = colors)
    backgrounds <- lapply(seq_len(length(p)), function(i) p[[i]]$layers[[1]]$data)
    south <- vapply(backgrounds, function(x) x$fill[x$bg == "South"], "")
    expect_equal(south[1], south[2])
    b <- lapply(seq_len(length(p)), function(i) ggplot2::ggplot_build(p[[i]]))
    expect_equal(as.character(b[[1]]$data[[1]]$fill[2]), as.character(b[[2]]$data[[1]]$fill[1]))
  }
})

test_that("plt_cat split dot sizes use a shared quantity scale", {
  d <- data.frame(category = rep(c("A", "B", "A", "B"), c(1, 2, 10, 20)),
                  site = rep(c("one", "two"), c(3, 30)))
  p <- cat_test_plot(d, "category", split.by = "site", type = "dot", stat = "count")
  b <- lapply(seq_len(length(p)), function(i) ggplot2::ggplot_build(p[[i]]))
  expect_equal(b[[1]]$plot$scales$get_scales("size")$get_limits(), c(1, 20))
  expect_equal(b[[2]]$plot$scales$get_scales("size")$get_limits(), c(1, 20))
  expect_equal(b[[2]]$data[[1]]$size / b[[1]]$data[[1]]$size, rep(sqrt(10), 2))
  expect_equal(p[[1]]$data$n, c(1L, 2L))
  expect_equal(p[[2]]$data$n, c(10L, 20L))
  g <- patchwork::patchworkGrob(p)
  guide <- cat_test_text(g$grobs[[which(g$layout$name == "guide-box")]])
  expect_equal(sum(guide %in% c("20", "20.0")), 1L)
  scale <- p[[1]]$scales$get_scales("size")
  scale$limits <- c(0, 100)
  expect_equal(p[[2]]$scales$get_scales("size")$limits, c(1, 20))
})

test_that("plt_cat split Venn fills use a shared quantity scale", {
  skip_if_not_installed("ggVennDiagram")
  d <- data.frame(A = TRUE, B = TRUE, site = rep(c("one", "two"), c(1, 10)))
  p <- suppressMessages(cat_test_plot(d, c("A", "B"), split.by = "site", type = "venn",
                                     stat_level = TRUE, label = TRUE))
  b <- lapply(seq_len(length(p)), function(i) ggplot2::ggplot_build(p[[i]]))
  for (panel in b) expect_equal(panel$plot$scales$get_scales("fill")$get_limits(), c(0, 10))
  expect_false(identical(unique(b[[1]]$data[[1]]$fill), unique(b[[2]]$data[[1]]$fill)))
  expect_equal(vapply(seq_len(length(p)), function(i) max(p[[i]]$layers[[1]]$data$count), 0), c(1, 10))
  g <- patchwork::patchworkGrob(p)
  guide <- cat_test_text(g$grobs[[which(g$layout$name == "guide-box")]])
  expect_equal(sum(guide == "count"), 1L)
})

test_that("plt_cat Venn omits undefined percentages for empty memberships", {
  skip_if_not_installed("ggVennDiagram")
  labels <- function(p) {
    unique(unlist(lapply(ggplot2::ggplot_build(p)$data, function(layer) {
      as.character(layer$label)
    }), use.names = FALSE))
  }
  d <- data.frame(A = c(FALSE, FALSE), B = c(FALSE, FALSE))
  p <- cat_test_plot(d, c("A", "B"), type = "venn", stat_level = TRUE, label = TRUE)
  expect_setequal(labels(p), c("A", "B", "0"))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
  hidden <- cat_test_plot(d, c("A", "B"), type = "venn", stat_level = TRUE)
  expect_setequal(labels(hidden), c("A", "B"))
  d <- data.frame(A = c(TRUE, FALSE), B = c(TRUE, FALSE),
                  site = c("positive", "negative"))
  split <- cat_test_plot(d, c("A", "B"), split.by = "site", type = "venn",
                        stat_level = TRUE, label = TRUE)
  expect_setequal(labels(split[[2]]), c("A", "B", "0"))
  positive <- labels(split[[1]])
  expect_equal(positive[grepl("100%", positive, fixed = TRUE)], "1\n(100%)")
})

test_that("plt_cat Venn honours region alpha and label background controls", {
  skip_if_not_installed("ggVennDiagram")
  d <- data.frame(A = c(TRUE, TRUE, FALSE), B = c(FALSE, TRUE, TRUE))
  p <- suppressMessages(cat_test_plot(d, c("A", "B"), type = "venn", label = TRUE,
                                     alpha = 0.25, label.bg = "yellow", label.bg.r = 0.7))
  b <- ggplot2::ggplot_build(p)
  label <- which(vapply(p$layers, function(layer) inherits(layer$geom, "GeomLabel"), FALSE))
  expect_equal(unique(b$data[[1]]$alpha), 0.25)
  expect_equal(unique(b$data[[label]]$fill), "yellow")
  expect_equal(as.numeric(p$layers[[label]]$geom_params$label.r), 0.7)
  q <- suppressMessages(cat_test_plot(d, c("A", "B"), type = "venn", label = TRUE,
                                     alpha = 1, label.bg = "white", label.bg.r = 0.1))
  expect_equal(unique(ggplot2::ggplot_build(q)$data[[1]]$alpha), 1)
  expect_equal(p$layers[[1]]$data$count, q$layers[[1]]$data$count)
  if (requireNamespace("ragg", quietly = TRUE)) {
    capture <- function(p) {
      get <- ragg::agg_capture(width = 350, height = 300, units = "px")
      on.exit(grDevices::dev.off())
      print(p)
      get()
    }
    expect_false(identical(capture(p), capture(q)))
  }
})

test_that("plt_cat matches named positive vectors by column name", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = c("Yes", "No", "Yes"), B = c("No", "No", "Yes"))
  p <- cat_test_plot(d, c("A", "B"), type = "upset", stat_level = c(A = "Yes", B = "No"))
  q <- cat_test_plot(d, c("A", "B"), type = "upset", stat_level = c(B = "No", A = "Yes"))
  expect_equal(q$data$intersection, p$data$intersection)
  positional <- cat_test_plot(d, c("A", "B"), type = "upset", stat_level = c("Yes", "No"))
  expect_equal(positional$data$intersection, p$data$intersection)
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = c(A = "Yes")), "missing.*B")
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = c(A = "Yes", A = "No")), "unique")
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = list(A = "Yes", B = "No", typo = "Yes")), "unknown.*typo")
  d <- data.frame(A = c(1e15, 1e15 + 1, 1e15), B = c(1, 0, 0))
  p <- cat_test_plot(d, c("A", "B"), type = "upset", stat_level = c(B = 1, A = 1e15 + 1))
  expect_equal(p$data$intersection, list("B", "A"))
})

test_that("plt_cat checks retained levels and impossible frequency grids early", {
  d <- data.frame(A = factor(c("a1", "a2"), levels = paste0("a", seq_len(101))),
                  g = factor(c("g1", "g2")))
  expect_error(plt_cat(d, "A", "g", keep_empty = TRUE, palette = "red"), "100 levels")
  p <- cat_test_plot(d, "A", "g", stat = "count", keep_empty = FALSE, palette = "red")
  expect_equal(sum(p$data$n), 2L)
  q <- cat_test_plot(d, "A", "g", stat = "count", keep_empty = TRUE, force = TRUE, palette = "red")
  expect_equal(nrow(q$data), 202L)
  expect_equal(sum(q$data$n), 2L)
  huge <- data.frame(A = factor(c("a1", "a2"), levels = paste0("a", seq_len(50000))),
                     g = factor(c("g1", "g2"), levels = paste0("g", seq_len(50000))))
  expect_error(plt_cat(huge, "A", "g", keep_empty = TRUE, force = TRUE, palette = "red"),
               "frequency table.*2\\^31")
})

test_that("cold integer64 categories respect the cardinality guard", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  functions <- file.path(scratch, "functions.R")
  input <- file.path(scratch, "input.rds")
  script <- file.path(scratch, "verify.R")
  dump(c("plt_cat", ".register_integer64", ".cat_time_key"), functions, envir = environment(plt_cat))
  saveRDS(data.frame(x = bit64::as.integer64(-seq_len(101))), input)
  writeLines(c(sprintf("source(%s)", deparse(functions)),
    sprintf("d <- readRDS(%s)", deparse(input)),
    "stopifnot(!('bit64' %in% loadedNamespaces()))",
    "error <- tryCatch(plt_cat(d, 'x', palette = stop('PALETTE_EVALUATED')), error = conditionMessage)",
    "stopifnot(grepl('100 levels', error, fixed = TRUE))",
    "cat('COLD_LIMIT_OK\n')"), script)
  output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
  expect_identical(tail(output, 1L), 'COLD_LIMIT_OK')
})

test_that("categorical plots combine missing checks before subsetting", {
  d <- data.frame(a = factor(c("A", NA, "B", "A", "B", "A")),
    b = factor(c("X", "X", NA, "Y", "Y", "X"), exclude = NULL),
    g = rep(c("G1", "G2"), 3L))
  fn <- plt_cat
  env <- new.env(parent = environment(fn))
  subsets <- 0L
  env[["["]] <- function(x, ...) {
    result <- base::`[`(x, ...)
    if (is.data.frame(x) && is.data.frame(result) && all(c("a", "b") %in% names(x)) &&
        nrow(result) < nrow(x)) subsets <<- subsets + 1L
    result
  }
  environment(fn) <- env
  actual <- fn(d, stat.by = "a", group.by = "b", NA_stat = FALSE)
  keep <- !is.na(as.character(d$a)) & !is.na(as.character(d$b))
  reference <- plt_cat(d[keep, ], stat.by = "a", group.by = "b", NA_stat = FALSE)
  expect_identical(subsets, 1L)
  expect_equal(actual$data, reference$data)
})

test_that("categorical UpSet retains a source named intersection", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(intersection = c(TRUE, FALSE, TRUE), B = c(TRUE, TRUE, FALSE))
  p <- cat_test_plot(d, names(d), type = "upset")
  expect_identical(as.character(p$data$intersection), c("TRUE", "FALSE", "TRUE"))
  lists <- Filter(is.list, as.list(p$data))
  expect_length(lists, 1L)
  expect_identical(lists[[1L]], list(c("intersection", "B"), "B", "intersection"))
  expect_equal(sum(ggplot2::layer_data(p)$count), nrow(d))
})

test_that("categorical UpSet reuses repeated membership patterns", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = rep(c(TRUE, FALSE, FALSE, TRUE), 20L),
    B = rep(c(FALSE, TRUE, FALSE, TRUE), 20L))
  fn <- .plt_cat_upset
  env <- new.env(parent = environment(fn))
  env$apply <- function(...) stop("rebuilt every membership row")
  environment(fn) <- env
  local_mocked_bindings(.plt_cat_upset = fn, .package = "UtilsR")
  p <- cat_test_plot(d, names(d), type = "upset")
  expect_identical(p$data$intersection, rep(list("A", "B", c("A", "B")), 20L))
  expect_equal(sum(ggplot2::layer_data(p)$count), 60)
})

test_that("categorical limits count SPSS missing values as one display group", {
  skip_if_not_installed("haven")
  d <- data.frame(s = haven::labelled_spss(c(1, 2, 101:201), na_range = c(101, 201)))
  p <- cat_test_plot(d, "s", stat = "count")
  expect_equal(p$data$n, c(1L, 1L))
  with_missing <- cat_test_plot(d, "s", stat = "count", NA_stat = TRUE)
  expect_equal(sort(with_missing$data$n), c(1L, 1L, 101L))
})

test_that("categorical limits count distinct period components", {
  skip_if_not_installed("lubridate")
  d <- data.frame(s = lubridate::period(months = seq_len(101L)))
  expect_error(plt_cat(d, "s", palette = "steelblue"), "100 levels")
  small <- cat_test_plot(d[c(2L, 1L, 2L), , drop = FALSE], "s", stat = "count")
  expect_equal(sort(small$data$n), c(1L, 2L))
})

test_that("sparse categorical counts avoid building an empty grid", {
  d <- data.frame(s = ordered(c("b", "", "b", "c"), levels = c("c", "b", "a", "")),
    g = factor(c("z", "z", "z", "y"), levels = c("z", "unused", "y")))
  fn <- .prepare_cat_data
  env <- new.env(parent = environment(fn))
  env$table <- function(...) stop("built the full categorical grid")
  environment(fn) <- env
  for (stat in c("count", "percent")) {
    original <- .prepare_cat_data(d, "s", "g", stat, keep_empty = TRUE)
    expected <- original[original$n > 0L, , drop = FALSE]
    expect_identical(fn(d, "s", "g", stat), expected)
  }
})

test_that("categorical missingness checks use ordinary factor codes", {
  d <- data.frame(s = ordered(rep(c("a", NA, "b"), 20L)))
  fn <- plt_cat
  env <- new.env(parent = environment(fn))
  env$as.character <- function(x, ...) {
    if (identical(x, d$s)) stop("converted every factor row")
    base::as.character(x, ...)
  }
  environment(fn) <- env
  invisible(utils::capture.output(p <- suppressMessages(fn(d, "s", stat = "count"))))
  expect_identical(p$data$n, c(20L, 20L))
})

test_that("categorical Sankey paths reshape their weights without backend grouping", {
  skip_if_not_installed("ggsankey")
  d <- data.frame(A = c("a", "b", "a", "a"), B = c("x", "y", "x", "x"),
                  C = c("u", "v", "u", "u"))
  expected <- cat_test_plot(d, names(d), type = "sankey")$data
  local_mocked_bindings(make_long = function(...) stop("re-expanded weighted paths"),
                        .package = "ggsankey")
  result <- cat_test_plot(d, names(d), type = "sankey")$data
  expect_identical(result, expected)
  expect_identical(result$next_node, c("x", "u", NA, "y", "v", NA))
  expect_identical(result$value, c(3L, 3L, 3L, 1L, 1L, 1L))
})

test_that("categorical panels avoid scanning the split column for each plot", {
  d <- data.frame(value = c("a", "b", "b", "a", "b"), panel = factor(
    c("P2", "P1", "", "P2", NA), levels = c("P2", "", "P1", "unused")))
  expected <- cat_test_plot(d, "value", split.by = "panel", NA_stat = TRUE, save = NULL)
  fn <- plt_cat
  env <- new.env(parent = environment(fn))
  env[["=="]] <- function(x, y) {
    if (identical(substitute(x), quote(data[[split.by]]))) stop("rescanned the split column")
    base::`==`(x, y)
  }
  environment(fn) <- env
  result <- suppressMessages(fn(d, "value", split.by = "panel", NA_stat = TRUE, save = NULL))
  expect_length(result, length(expected))
  for (i in seq_along(expected)) {
    expect_identical(result[[i]]$data, expected[[i]]$data)
    expect_identical(result[[i]]$labels$title, expected[[i]]$labels$title)
  }
})

test_that("categorical set palettes use observed factor codes", {
  skip_if_not_installed("ggsankey")
  d <- data.frame(a = ordered(c("", "b", "", "b"), levels = c("unused", "b", "")),
                  b = factor(c("x", "y", "x", "x"), levels = c("y", "x", "absent")))
  expected <- cat_test_plot(d, names(d), type = "sankey", save = NULL)
  fn <- plt_cat
  env <- new.env(parent = environment(fn))
  env$factor <- function(x, ...) {
    if (identical(substitute(x), quote(data[[s]]))) stop("rebuilt factor columns for the palette")
    base::factor(x, ...)
  }
  environment(fn) <- env
  result <- suppressMessages(fn(d, names(d), type = "sankey", save = NULL))
  expect_identical(result$data, expected$data)
  expect_identical(result$scales$get_scales("fill")$palette(4L),
                   expected$scales$get_scales("fill")$palette(4L))
})

test_that("categorical plots project selected data.table columns without a full copy", {
  skip_if_not_installed("data.table")
  d <- data.frame(value = c("A", "B", "B", "A"), group = c("g1", "g1", "g2", "g2"))
  table <- data.table::as.data.table(d)
  table$payload <- lapply(seq_len(nrow(table)), function(i) raw(10000L))
  before <- data.table::copy(table)
  fn <- plt_cat
  env <- new.env(parent = environment(fn))
  env$as.data.frame <- function(x, ...) {
    if (inherits(x, "data.table") && "payload" %in% names(x)) stop("copied unused data.table columns")
    base::as.data.frame(x, ...)
  }
  environment(fn) <- env
  result <- suppressMessages(fn(table, "value", "group", save = NULL))
  expected <- cat_test_plot(d, "value", "group", save = NULL)
  expect_identical(result$data, expected$data)
  expect_identical(table, before)
})

test_that("categorical set membership reads factor levels rather than every label", {
  d <- data.frame(A = factor(c("", "one", NA, "")), B = ordered(c("x", "x", "y", "y")))
  levels <- list(A = "", B = "x")
  fn <- .build_set_list
  env <- new.env(parent = environment(fn))
  env$as.character <- function(x, ...) {
    if (is.factor(x) && length(x) == nrow(d)) stop("converted all factor observations")
    base::as.character(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, names(d), levels), list(A = c(1L, 4L), B = c(1L, 2L)))
})

test_that("UpSet separator fallback encodes each visible combination once", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(A = rep(c(TRUE, FALSE, TRUE), c(100L, 120L, 120L)),
                  B = rep(c(FALSE, TRUE, TRUE), c(100L, 120L, 120L)))
  names(d)[2L] <- "B-__-__-_-old"
  expected <- cat_test_plot(d, names(d), type = "upset", stat_level = TRUE, save = NULL)
  fn <- .plt_cat_upset
  env <- new.env(parent = environment(fn))
  env$vapply <- function(X, FUN, FUN.VALUE, ...) {
    if (is.list(X) && length(X) == nrow(d)) stop("formatted repeated intersection rows")
    base::vapply(X, FUN, FUN.VALUE, ...)
  }
  environment(fn) <- env
  local_mocked_bindings(.plt_cat_upset = fn, .package = "UtilsR")
  result <- cat_test_plot(d, names(d), type = "upset", stat_level = TRUE, save = NULL)
  expect_identical(result$scales$get_scales("x")$limits, expected$scales$get_scales("x")$limits)
  expect_equal(ggplot2::layer_data(result)$count, ggplot2::layer_data(expected)$count)
})

test_that("categorical cardinality checks only observed or displayed values", {
  labels <- sprintf("level-%03d", seq_len(100L))
  for (x in list(c(labels, NA), c(seq_len(100L), NA_real_, NaN),
                 factor(c(labels, NA), levels = c(labels, NA), exclude = NULL))) {
    d <- data.frame(value = x)
    result <- cat_test_plot(d, "value", NA_stat = FALSE, palette = "hcl_Blues", save = NULL)
    expect_identical(nrow(result$data), 100L)
    expect_error(cat_test_plot(d, "value", NA_stat = TRUE, save = NULL), "100 levels")
  }
})

test_that("dense categorical counts tabulate existing factor codes", {
  d <- data.frame(s = ordered(c("c", "", "c", "b", NA), levels = c("", "c", "a", "b")),
    g = factor(c("Z", "Z", "Z", "X", "X"), levels = c("Z", "Y", "X")))
  native <- table(d$s, d$g)
  fn <- .prepare_cat_data
  env <- new.env(parent = environment(fn))
  env$table <- function(...) stop("rebuilt a table from category labels")
  environment(fn) <- env
  for (mode in c("count", "percent")) {
    out <- fn(d, "s", "g", mode, NA_stat = FALSE, keep_empty = TRUE)
    expect_identical(out$n, as.integer(native))
    expect_identical(levels(out$stat_var), levels(d$s))
    expect_identical(levels(out$group_var), levels(d$g))
    if (mode == "percent") expect_equal(out$value, c(1/3, 2/3, 0, 0, rep(0, 7L), 1) * 100)
  }
})

test_that("categorical trend and area labels reuse plotted coordinates", {
  d <- data.frame(
    category = rep(c("", "present"), 4L),
    group = factor(rep(c("later", "earlier", NA, "later"), each = 2L),
                   levels = c("later", "unused", "earlier"), ordered = TRUE)
  )
  fn <- .add_cat_labels
  env <- new.env(parent = environment(fn))
  env$factor <- function(...) stop("rebuilt categorical label coordinates")
  environment(fn) <- env
  local_mocked_bindings(.add_cat_labels = fn, .package = "UtilsR")
  for (type in c("trend", "area")) for (keep_empty in c(FALSE, TRUE)) {
    p <- cat_test_plot(d, "category", "group", type = type, stat = "count",
                      NA_stat = TRUE, keep_empty = keep_empty, label = TRUE)
    labels <- p$layers[[length(p$layers)]]$data
    expect_true(length(p$data$x_num) > 0L)
    expect_identical(labels$x_num, p$data$x_num)
    expect_length(labels$label_text, nrow(p$data))
  }
})
