con_data <- function() {
  data.frame(
    x = c(1:6, 10:15), z = c(101:106, 110:115),
    g = factor(rep(c("A", "B"), each = 6)),
    batch = factor(rep(c("S1", "S2"), 6))
  )
}

con_plot <- function(data, stat.by = "x", group.by = "g", ...) {
  suppressMessages(plt_con(data, stat.by, group.by, combine = FALSE, ...))[[1L]]
}

con_time_categories <- function() {
  times <- as.POSIXct("2026-11-01 05:30:00", tz = "UTC") + c(3600, 0)
  attr(times, "tzone") <- "America/New_York"
  list(
    Date = as.Date("2026-01-01") + c(0.5, 0),
    POSIXct = times,
    POSIXlt = as.POSIXlt(times),
    difftime = as.difftime(c(1 + 1e-15, 1), units = "secs")
  )
}

test_that("con inputs exclude SPSS user missing values from each numeric feature", {
  skip_if_not_installed("haven")
  d <- data.frame(x = haven::labelled_spss(c(1, 99, 2), na_values = 99), g = "A")
  p <- con_plot(d, type = "bar")
  expect_equal(p$data$value, c(1, 2))
  expect_equal(ggplot2::ggplot_build(p)$data[[2L]]$y, 1.5)
  d$z <- haven::labelled_spss(c(3, 98, 4), na_range = c(97, 99))
  q <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE)
  expect_equal(q$data$value, c(1, 2, 3, 4))
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$y, c(1.5, 3.5))
})

test_that("con inputs recognize SPSS missing grouping and splitting codes", {
  skip_if_not_installed("haven")
  d <- data.frame(x = 1:4, g = haven::labelled_spss(c(1, 99, 1, 2), na_values = 99))
  p <- con_plot(d, type = "bar")
  expect_false("99" %in% levels(p$data$group.by))
  expect_equal(sum(is.na(p$data$group.by)), 1L)
  d$batch <- haven::labelled_spss(c(1, 99, 1, 2), na_values = 99)
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "bar"))
  expect_length(out, 2L)
})

test_that("con time categories retain observed groups and their first appearance order", {
  for (kind in c("POSIXct", "POSIXlt")) {
    d <- con_data()
    times <- as.POSIXct("2026-01-01", tz = "UTC") + rep(c(1, 0), each = 6)
    d$g <- if (kind == "POSIXlt") as.POSIXlt(times) else times
    for (stack in c(FALSE, TRUE)) {
      p <- con_plot(d, c("x", "z"), type = "box", stack = stack)
      expect_identical(levels(p$data$group.by), unique(as.character(times)))
      expect_equal(sum(is.na(p$data$group.by)), 0L)
      expect_equal(nrow(ggplot2::ggplot_build(p)$data[[2L]]), if (stack) 4L else 2L)
    }
  }
})

test_that("con time splitting and background categories retain valid observations", {
  d <- con_data()
  d$batch <- as.POSIXct("2026-01-01", tz = "UTC") + rep(c(1, 0), each = 6)
  out <- suppressMessages(plt_con(d, "x", "g", type = "box", split.by = "batch", combine = FALSE))
  expect_named(out, unique(as.character(d$batch)))
  expect_equal(unname(vapply(out, function(p) nrow(p$data), integer(1))), rep(6L, 2L))
  d$g <- factor(rep(c("A", "B", "C"), each = 4))
  d$region <- as.POSIXct("2026-01-01", tz = "UTC") + rep(c(0, 0, 1), each = 4)
  expect_no_warning(p <- con_plot(d, type = "box", bg.by = "region"))
  expect_true(inherits(p$layers[[1L]]$geom, "GeomRect"))
  bands <- ggplot2::ggplot_build(p)$data[[1L]]
  expect_equal(nrow(bands), 3L)
  expect_length(unique(bands$fill), 2L)
  d$g <- as.POSIXct("2026-01-01", tz = "UTC") + c(rep(0, 5), NA, rep(1, 6))
  p <- con_plot(d, type = "bar")
  expect_equal(sum(is.na(p$data$group.by)), 1L)
  expect_equal(nrow(ggplot2::ggplot_build(p)$data[[2L]]), 3L)
})

test_that("con time categories preserve identities when displayed labels collide", {
  for (values in con_time_categories()) {
    expect_length(unique(as.character(values)), 1L)
    d <- con_data()
    d$g <- rep(values, each = 6)
    for (stack in c(FALSE, TRUE)) {
      p <- con_plot(d, c("x", "z"), type = "box", stack = stack)
      expect_identical(sub(" \\[[^]]*\\]$", "", levels(p$data$group.by)), as.character(values))
      expect_identical(as.integer(p$data$group.by), rep(rep(1:2, each = 6), if (stack) 2L else 1L))
      expect_equal(nrow(ggplot2::ggplot_build(p)$data[[2L]]), if (stack) 4L else 2L)
    }
  }
})

test_that("con time splits and backgrounds preserve distinct category membership", {
  for (values in con_time_categories()) {
    d <- con_data()
    d$g <- rep(values, each = 6)
    labels <- levels(con_plot(d, type = "box")$data$group.by)
    d$g <- con_data()$g
    d$batch <- rep(values, each = 6)
    out <- suppressMessages(plt_con(d, "x", "g", type = "box", split.by = "batch", combine = FALSE))
    expect_named(out, labels)
    expect_equal(unname(lapply(out, function(p) p$data$value)), list(1:6, 10:15))
    expect_equal(unname(vapply(out, function(p) nrow(ggplot2::ggplot_build(p)$data[[2L]]), integer(1))), c(1L, 1L))
    d$g <- factor(rep(c("A", "B", "C"), each = 4))
    d$region <- rep(values, c(8, 4))
    p <- con_plot(d, type = "box", bg.by = "region", bg_palette = stats::setNames(c("red", "blue"), labels))
    expect_identical(as.character(ggplot2::ggplot_build(p)$data[[1L]]$fill), c("red", "red", "blue"))
  }
})

test_that("con time categories retain missing observations and dot counts", {
  indices <- c(rep(1L, 5), NA_integer_, rep(2L, 6))
  for (values in con_time_categories()) {
    d <- con_data()
    d$g <- values[indices]
    p <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE)
    expect_identical(is.na(p$data$group.by), rep(is.na(indices), 2L))
    expect_identical(sub(" \\[[^]]*\\]$", "", levels(p$data$group.by)), as.character(values))
    points <- ggplot2::ggplot_build(p)$data[[1L]]
    expect_equal(sum(p$layers[[1L]]$data$n), 24L)
    expect_equal(sort(unique(as.numeric(points$x))), c(1, 2, 3))
  }
})

test_that("con time spans preserve S4 labels and distinct stored categories", {
  skip_if_not_installed("lubridate")
  origin <- as.POSIXct("2026-01-01", tz = "UTC")
  cases <- list(
    lubridate::dseconds(c(1 + 1e-15, 1)),
    lubridate::seconds(c(1 + 1e-15, 1)),
    c(lubridate::period(month = 1), lubridate::days(30)),
    lubridate::interval(origin, origin + c(1 + 1e-5, 1)),
    lubridate::interval(origin + c(1, 0), origin + c(11, 10))
  )
  for (values in cases) {
    d <- con_data()
    d$g <- rep(values, each = 6)
    p <- con_plot(d, type = "box")
    labels <- levels(p$data$group.by)
    expect_identical(sub(" \\[[^]]*\\]$", "", labels), as.character(values))
    expect_identical(as.integer(p$data$group.by), rep(1:2, each = 6))
    expect_equal(nrow(ggplot2::ggplot_build(p)$data[[2L]]), 2L)
    d$batch <- d$g
    out <- suppressMessages(plt_con(d, "x", "g", type = "box", split.by = "batch", combine = FALSE))
    expect_named(out, labels)
    expect_equal(unname(vapply(out, function(p) nrow(p$data), integer(1))), c(6L, 6L))
  }
})

test_that("con time grouping keeps signed-zero instants together", {
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
    data$g <- values[c(1, 1, 2, 2)]
    invisible(capture.output(p <- con_plot(data, stat.by = "value", type = "box")))
    expect_length(levels(p$data$group.by), 1L)
    expect_identical(as.integer(p$data$group.by), rep(1L, 4))
  }
})

test_that("con numeric categories preserve distinctions beyond ordinary label precision", {
  d <- con_data()
  values <- c(1, 1 + 1e-15)
  labels <- sprintf("%.17g", values)
  d$g <- rep(values, each = 6)
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack,
                  comparisons = list(c(1L, 2L)), palette = stats::setNames(c("red", "blue"), labels))
    expect_identical(levels(p$data$group.by), labels)
    expect_equal(as.integer(table(p$data$group.by)), rep(if (stack) 12L else 6L, 2L))
    b <- ggplot2::ggplot_build(p)$data
    expect_equal(nrow(b[[1L]]), if (stack) 4L else 2L)
    expect_equal(unique(tail(b, 1L)[[1L]]$annotation), "**")
  }
})

test_that("con numeric splitting and background categories avoid formatted label collisions", {
  d <- con_data()
  values <- c(1, 1 + 1e-15)
  labels <- sprintf("%.17g", values)
  d$batch <- rep(values, each = 6)
  out <- suppressMessages(plt_con(d, "x", "g", type = "box", split.by = "batch", combine = FALSE))
  expect_named(out, labels)
  expect_equal(unname(vapply(out, function(p) nrow(p$data), integer(1))), rep(6L, 2L))
  d$g <- factor(rep(c("A", "B", "C"), each = 4))
  d$region <- rep(values, c(8, 4))
  p <- con_plot(d, type = "box", bg.by = "region", bg_palette = stats::setNames(c("red", "blue"), labels))
  expect_equal(as.character(ggplot2::ggplot_build(p)$data[[1L]]$fill), c("red", "red", "blue"))
})

test_that("con ordinary numeric and pre-existing factor labels retain their contracts", {
  d <- con_data()
  for (groups in list(rep(c(2, 1), each = 6), rep(c(1.25, 2.5), each = 6),
                     factor(rep(c("B", "A"), each = 6), levels = c("B", "unused", "A")))) {
    d$g <- groups
    p <- con_plot(d, type = "box")
    expect_identical(p$data$group.by, if (is.factor(groups)) groups else factor(groups, levels = unique(groups)))
  }
})

test_that("con inputs reject unsupported numeric storage and matrix columns", {
  skip_if_not_installed("bit64")
  d <- data.frame(x = bit64::as.integer64(c("9007199254740993", NA, "9007199254740994")), g = "A")
  expect_error(con_plot(d, type = "bar"), "integer64")
  d$x <- matrix(1:6, nrow = 3L)
  expect_error(con_plot(d, type = "box"), "one-dimensional")
  if (requireNamespace("lubridate", quietly = TRUE)) {
    d$x <- lubridate::seconds(1:3)
    expect_error(con_plot(d), "time-span")
  }
})

test_that("con inputs reject ambiguous columns and overlapping roles", {
  d <- data.frame(x = 1:3, z = 11:13, g = "A")
  names(d)[1:2] <- c("x", "x")
  expect_error(con_plot(d), "unique")
  d <- data.frame(x = rep(1:2, each = 3))
  expect_error(con_plot(d, group.by = "x"), "different|overlap")
  expect_error(con_plot(con_data(), group.by = c("g", "batch")), "group.by")
  expect_error(con_plot(con_data(), stat.by = NA_character_), "stat.by")
})

test_that("con inputs preserve a numeric variable named like the dummy group", {
  d <- data.frame(.all_groups = c(1, 2, 3))
  original <- d
  p <- con_plot(d, ".all_groups", group.by = NULL, type = "bar")
  expect_equal(p$data$value, 1:3)
  expect_equal(ggplot2::ggplot_build(p)$data[[2L]]$y, 2)
  expect_identical(d, original)
})

test_that("con bins draw constant dot data without losing counts", {
  d <- data.frame(x = rep(2, 6), z = rep(2, 6), g = "A")
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "dot", stack = stack)
    b <- ggplot2::ggplot_build(p)$data[[1L]]
    expect_equal(b$y, if (stack) c(2, 2) else 2)
    expect_equal(sum(p$layers[[1L]]$data$n), if (stack) 12L else 6L)
  }
})

test_that("con bins use numeric boundaries at large and tiny scales", {
  for (offset in c(0, 1e15)) {
    d <- data.frame(x = offset + 1:10, z = offset + 21:30, g = "A")
    for (stack in c(FALSE, TRUE)) {
      p <- con_plot(d, if (stack) c("x", "z") else "x", type = "dot", stack = stack)
      bins <- p$layers[[1L]]$data
      expect_true(all(bins$bins >= min(p$data$value)))
      expect_true(all(bins$bins <= max(p$data$value)))
      expect_equal(sum(bins$n), nrow(d) * if (stack) 2L else 1L)
    }
  }
  d <- data.frame(x = (1:10) * 1e-10, g = "A")
  p <- con_plot(d, type = "dot")
  expected_breaks <- seq(min(d$x), max(d$x), length.out = 15)
  ids <- cut(d$x, expected_breaks, include.lowest = TRUE, labels = FALSE)
  mids <- expected_breaks[-15L] + diff(expected_breaks) / 2
  expect_equal(sort(p$layers[[1L]]$data$bins), sort(unique(mids[ids])))
})

test_that("con dot bins are independent of unrelated feature scales in stacked plots", {
  d <- data.frame(x = 1:8, z = 1e6 + 1:8, g = rep(c("A", "B"), 4))
  separate <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "dot", combine = FALSE))
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE, flip = flip)
    at <- p$layers[[1L]]$data
    for (feature in c("x", "z")) {
      expected <- separate[[feature]]$layers[[1L]]$data
      actual <- at[at$feature == feature, c("group.by", "bins", "n")]
      expect_equal(actual$bins, expected$bins)
      expect_equal(actual$n, expected$n)
      expect_equal(as.character(actual$group.by), as.character(expected$group.by))
    }
  }
})

test_that("con split dot plots share feature-wide bins and keep automatic centres visible", {
  d <- data.frame(x = c(1, 2, 3, 1, 100, 200), g = "A", batch = rep(c("S1", "S2"), each = 3))
  original <- d
  out <- suppressMessages(plt_con(d, "x", "g", type = "dot", split.by = "batch", combine = FALSE))
  global <- con_plot(d, type = "dot")$layers[[1L]]$data
  first <- out[[1L]]$layers[[1L]]$data
  second <- out[[2L]]$layers[[1L]]$data
  expect_equal(first$bins[1L], second$bins[1L])
  expected <- stats::aggregate(n ~ bins, global, sum)
  actual <- stats::aggregate(n ~ bins, rbind(first, second), sum)
  expect_equal(actual, expected)
  for (p in out) {
    b <- ggplot2::ggplot_build(p)
    expect_equal(sum(p$layers[[1L]]$data$n), nrow(p$data))
    expect_true(all(b$data[[1L]]$y > b$layout$panel_params[[1L]]$y.range[1L]))
    expect_true(all(b$data[[1L]]$y < b$layout$panel_params[[1L]]$y.range[2L]))
  }
  expect_identical(d, original)
})

test_that("con common split bins remain independent across features and layouts", {
  to_list <- getFromNamespace(".to_plot_list", "UtilsR")
  d <- data.frame(x = c(1, 2, 3, 1, 100, 200), z = 5, g = "A", batch = rep(c("S1", "S2"), each = 3))
  global <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE, fill.by = "feature")$layers[[1L]]$data
  expected <- stats::aggregate(n ~ fill.by + bins, global, sum)
  for (stack in c(FALSE, TRUE)) {
    out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "dot", split.by = "batch",
      stack = stack, same.y.lims = TRUE, fill.by = "feature", combine = FALSE))
    frames <- lapply(out, function(p) lapply(to_list(p, recurse = TRUE)$plots, function(leaf) leaf$layers[[1L]]$data))
    actual <- stats::aggregate(n ~ fill.by + bins, do.call(rbind, unlist(frames, recursive = FALSE)), sum)
    expect_equal(actual, expected)
    expect_equal(unique(actual$bins[as.character(actual$fill.by) == "z"]), 5)
    for (p in out) {
      leaves <- to_list(p, recurse = TRUE)$plots
      ranges <- lapply(leaves, function(leaf) {
        b <- ggplot2::ggplot_build(suppressMessages(leaf + ggplot2::scale_y_log10()))
        expect_true(all(b$data[[1L]]$y <= b$layout$panel_params[[1L]]$y.range[2L]))
        b$layout$panel_params[[1L]]$y.range
      })
      if (!stack) expect_equal(ranges[[1L]], ranges[[2L]])
    }
  }
})

test_that("con common dot bins preserve raw overlays and explicit quantile zooms", {
  d <- data.frame(x = c(1, 2, 3, 1, 100, 200), g = "A", batch = rep(c("S1", "S2"), each = 3))
  out <- suppressMessages(plt_con(d, "x", "g", type = "dot", split.by = "batch", add_point = TRUE,
                                y.min = "q0", y.max = "q100", combine = FALSE))
  p <- out[[1L]]
  expect_equal(p$coordinates$limits$y, c(1, 3), ignore_attr = TRUE)
  expect_equal(ggplot2::ggplot_build(p)$data[[2L]]$y, c(1, 2, 3))
  expect_equal(sum(p$layers[[1L]]$data$n), 3L)
  expect_identical(p$data$value, d$x[1:3])
})

test_that("con dot counts include observed missing grouping strata", {
  d <- data.frame(x = 1:4, z = 11:14, g = c("A", NA, "B", NA))
  for (stack in c(FALSE, TRUE)) for (fill in c("group", "feature")) {
    p <- con_plot(d, c("x", "z"), type = "dot", stack = stack, fill.by = fill)
    counts <- p$layers[[1L]]$data
    expect_equal(sum(counts$n), if (stack) 8L else 4L)
    expect_equal(sum(counts$n[is.na(counts$group.by)]), if (stack) 4L else 2L)
    expect_length(unique(ggplot2::ggplot_build(p)$data[[1L]]$x), 3L)
  }
  d$g <- NA_character_
  p <- con_plot(d, type = "dot")
  expect_equal(sum(p$layers[[1L]]$data$n), 4L)
})

test_that("con dot feature plots use the same pooled quantity scale as stacked panels", {
  d <- data.frame(x = rep(1, 20), z = c(2, 2, rep(NA_real_, 18)), g = "A")
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "dot", combine = FALSE))
  sizes <- vapply(out, function(p) ggplot2::ggplot_build(p)$data[[1L]]$size, numeric(1))
  p <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE)
  expect_equal(unname(sizes), ggplot2::ggplot_build(p)$data[[1L]]$size)
  expect_gt(sizes[1L], sizes[2L])
  expect_equal(out[[1L]]$scales$get_scales("size")$limits, c(2L, 20L))
  expect_equal(out[[2L]]$scales$get_scales("size")$limits, c(2L, 20L))
})

test_that("con split dot quantity scales agree across nested feature plots", {
  to_list <- getFromNamespace(".to_plot_list", "UtilsR")
  d <- data.frame(x = rep(1, 22), z = rep(2, 22), g = "A", batch = rep(c("S1", "S2"), c(2, 20)))
  d$z[2] <- NA_real_
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "dot", split.by = "batch", combine = FALSE))
  leaves <- unlist(lapply(out, function(p) to_list(p, recurse = TRUE)$plots), recursive = FALSE)
  for (p in leaves) {
    expect_equal(p$scales$get_scales("size")$limits, c(1L, 20L))
    count <- p$layers[[1L]]$data$n
    expect_equal(ggplot2::ggplot_build(p)$data[[1L]]$size, 6 * sqrt(count / 20))
  }
  expect_true(all(vapply(out, function(p) length(attr(p, "plot_size")) == 2L, logical(1))))
  p <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "dot", split.by = "batch"))
  leaves <- to_list(p, recurse = TRUE)$plots
  expect_length(leaves, 4L)
  expect_true(all(vapply(leaves, function(p) identical(p$scales$get_scales("size")$limits, c(1L, 20L)), logical(1))))
})

test_that("con standalone dot scales retain native limits and count data", {
  d <- data.frame(x = c(1, 1, 1, 2), g = "A")
  p <- con_plot(d, type = "dot")
  expect_null(p$scales$get_scales("size")$limits)
  expect_equal(sum(p$layers[[1L]]$data$n), nrow(d))
  expect_equal(max(ggplot2::ggplot_build(p)$data[[1L]]$size), 6)
})

test_that("con dot counts retain keyed order and ordered factor levels", {
  d <- data.frame(x = c(2, 1, 1, 2, 2, 2, 1),
    g = ordered(c("B", "A", NA, "B", "A", NA, "A"), levels = c("A", "B", "unused")))
  for (fill in c("group", "feature")) {
    p <- con_plot(d, type = "dot", fill.by = fill)
    counts <- p$layers[[1L]]$data
    expect_identical(names(counts), c("group.by", "fill.by", "bins", "n"))
    expect_identical(as.character(counts$group.by), c("B", "A", NA, "A", NA))
    expect_identical(counts$n, c(2L, 1L, 1L, 2L, 1L))
    expect_identical(levels(counts$group.by), levels(d$g))
    expect_s3_class(counts$group.by, "ordered")
    expect_equal(sum(counts$n), nrow(d))
  }
})

test_that("con stacked comparisons test each feature separately", {
  d <- con_data()
  d$z <- c(1:6, (1:6) + 1.5)
  p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE,
               comparisons = list(c("A", "B")), multiplegroup_comparisons = TRUE)
  kinds <- vapply(p$layers, function(l) class(l$geom)[1L], character(1))
  expect_true("GeomSignif" %in% kinds)
  expect_true("GeomText" %in% kinds)
  b <- ggplot2::ggplot_build(p)$data
  bracket <- b[[which(kinds == "GeomSignif")]]
  global <- b[[which(kinds == "GeomText")]]
  expect_equal(as.character(tapply(bracket$annotation, bracket$PANEL, unique)), c("**", "ns"))
  expect_equal(as.character(global$label), c("**", "ns"))
})

test_that("con stacked statistical groups are independent of the fill variable", {
  d <- con_data()
  d$z <- c(1:6, (1:6) + 1.5)
  for (type in c("box", "bar")) for (flip in c(FALSE, TRUE)) {
    results <- lapply(c("group", "feature"), function(fill) {
      p <- con_plot(d, c("x", "z"), type = type, stack = TRUE, flip = flip,
        fill.by = fill, comparisons = list(c("A", "B")), multiplegroup_comparisons = TRUE)
      kinds <- vapply(p$layers, function(l) class(l$geom)[1L], "")
      b <- ggplot2::ggplot_build(p)$data
      list(bracket = do.call(rbind, b[kinds == "GeomSignif"]),
           global = do.call(rbind, b[kinds == "GeomText"]))
    })
    expect_equal(results[[2L]]$bracket[, c("PANEL", "annotation", "x", "xend", "y", "yend")],
                 results[[1L]]$bracket[, c("PANEL", "annotation", "x", "xend", "y", "yend")])
    expect_equal(results[[2L]]$global[, c("PANEL", "p", "label", "x", "y")],
                 results[[1L]]$global[, c("PANEL", "p", "label", "x", "y")])
  }
})

test_that("con statistical groups follow displayed positions with unused and missing levels", {
  d <- con_data()
  d$g <- factor(d$g, levels = c("unused", "A", "gap", "B"))
  d <- rbind(d, transform(d[1:3, ], g = NA, x = x + 2, z = z + 2))
  p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, fill.by = "feature",
               comparisons = list(c("B", "A")), multiplegroup_comparisons = TRUE)
  b <- ggplot2::ggplot_build(p)$data
  kinds <- vapply(p$layers, function(l) class(l$geom)[1L], "")
  bracket <- b[[which(kinds == "GeomSignif")]]
  global <- b[[which(kinds == "GeomText")]]
  expect_equal(as.integer(table(bracket$PANEL)), c(3L, 3L))
  expect_equal(sort(unique(c(bracket$x, bracket$xend))), c(2, 4))
  expect_equal(as.integer(global$PANEL), 1:2)
  expect_true(all(is.finite(global$p)))
})

test_that("con unavailable comparisons preserve valid tests in each feature", {
  d <- data.frame(x = 1:18, z = 51:68, g = factor(rep(c("A", "B", "C"), each = 6)))
  d$z[d$g == "C"] <- NA_real_
  pairs <- list(c("A", "B"), c("A", "C"))
  for (stack in c(FALSE, TRUE)) {
    expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
                       comparisons = pairs, stack = stack, combine = FALSE)), "Skipping.*z")
    p <- out[[if (stack) 1L else 2L]]
    expect_no_warning(b <- ggplot2::ggplot_build(p))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    if (stack) {
      expect_equal(as.integer(table(brackets$PANEL)), c(6L, 3L))
    } else {
      expect_equal(nrow(brackets), 3L)
    }
  }
})

test_that("con reference groups generate pairwise tests unless explicit pairs are supplied", {
  d <- data.frame(x = 1:18, z = 21:38, g = factor(rep(c("A", "B", "C"), each = 6)))
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack, ref_group = "B")
    q <- con_plot(d, c("x", "z"), type = "box", stack = stack,
                 comparisons = list(c("B", "A"), c("B", "C")))
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
  }
  p <- con_plot(d, type = "box", ref_group = "B", comparisons = list(c("A", "C")))
  q <- con_plot(d, type = "box", comparisons = list(c("A", "C")))
  expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
  expect_error(con_plot(d, type = "box", ref_group = "absent"), "ref_group")
})

test_that("con failed pairwise tests preserve successful comparisons per feature", {
  d <- data.frame(x = 1:18, z = 51:68, g = factor(rep(c("A", "B", "C"), each = 6)))
  d$x[14:18] <- NA_real_
  pairs <- list(c("A", "B"), c("A", "C"))
  for (stack in c(FALSE, TRUE)) for (label in c("p.signif", "p.format")) {
    expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
      comparisons = pairs, pairwise_method = "t.test", sig_label = label,
      stack = stack, combine = FALSE)), "Skipping.*comparison.*x")
    p <- out[[1L]]
    expect_no_warning(b <- ggplot2::ggplot_build(p))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    expect_equal(as.integer(table(brackets$PANEL)), if (stack) c(3L, 6L) else 3L)
    q <- con_plot(d, type = "box", comparisons = pairs[1L], pairwise_method = "t.test", sig_label = label)
    expected <- tail(ggplot2::ggplot_build(q)$data, 1L)[[1L]]$annotation
    expect_identical(brackets$annotation[brackets$PANEL == 1L], expected)
  }
})

test_that("con nonfinite pairwise p values are skipped without losing valid tests", {
  d <- data.frame(x = c(rep(1, 6), 2:7, rep(1, 6)), z = 11:28,
                   g = factor(rep(c("A", "B", "C"), each = 6)))
  pairs <- list(c("A", "B"), c("A", "C"))
  for (stack in c(FALSE, TRUE)) for (label in c("p.signif", "p.format")) {
    expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
      comparisons = pairs, sig_label = label, stack = stack, combine = FALSE)), "Skipping.*finite.*p-value")
    p <- out[[1L]]
    b <- suppressWarnings(ggplot2::ggplot_build(p))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    expect_equal(nrow(brackets), if (stack) 9L else 3L)
    q <- con_plot(d, type = "box", comparisons = pairs[1L], sig_label = label)
    expected <- suppressWarnings(tail(ggplot2::ggplot_build(q)$data, 1L)[[1L]]$annotation)
    expect_identical(brackets$annotation[brackets$PANEL == 1L], expected)
  }
})

test_that("con pairwise Kruskal and ANOVA use two samples in initial and repeated tests", {
  d <- con_data()
  for (method in c("kruskal.test", "anova")) {
    expected <- if (method == "kruskal.test") stats::kruskal.test(x ~ g, d)$p.value else
      summary(stats::aov(x ~ g, d))[[1L]][["Pr(>F)"]][1L]
    p <- suppressWarnings(con_plot(d, type = "box", comparisons = list(c("A", "B")),
      pairwise_method = method, sig_label = "p.format"))
    labels <- tail(ggplot2::ggplot_build(p)$data, 1L)[[1L]]$annotation
    expect_equal(as.numeric(unique(labels)), signif(expected, 2L), tolerance = 1e-10)
    callback <- tail(p$layers, 1L)[[1L]]$stat_params[["test"]]
    expect_type(callback, "closure")
    if (!is.function(callback)) next
    expect_equal(callback(d$x[d$g == "A"], d$x[d$g == "B"], paired = FALSE)$p.value, expected)
    d_log <- d
    d_log$x <- log10(d_log$x)
    expected_log <- if (method == "kruskal.test") stats::kruskal.test(x ~ g, d_log)$p.value else
      summary(stats::aov(x ~ g, d_log))[[1L]][["Pr(>F)"]][1L]
    expect_equal(callback(d_log$x[d_log$g == "A"], d_log$x[d_log$g == "B"], paired = FALSE)$p.value,
                 expected_log)
  }
})

test_that("con pairwise ANOVA skips constant samples instead of showing a spurious p value", {
  d <- con_data()
  d$x <- 1
  expect_warning(p <- con_plot(d, type = "box", comparisons = list(c("A", "B")),
    pairwise_method = "anova"), "constant")
  expect_length(p$layers[vapply(p$layers, function(l) inherits(l$geom, "GeomSignif"), logical(1))], 0L)
})

test_that("con pairwise results are reused while changed plot data are retested", {
  original <- getFromNamespace("t.test.default", "stats")
  calls <- 0L
  local_mocked_bindings(t.test.default = function(...) {
    calls <<- calls + 1L
    original(...)
  }, .package = "stats")
  d <- con_data()
  for (stack in c(FALSE, TRUE)) {
    calls <- 0L
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "box", stack = stack,
                 comparisons = list(c("A", "B")), pairwise_method = "t.test")
    expected <- if (stack) 2L else 1L
    expect_equal(calls, expected)
    invisible(ggplot2::ggplotGrob(p))
    invisible(ggplot2::ggplotGrob(p))
    expect_equal(calls, expected)
    invisible(suppressMessages(ggplot2::ggplotGrob(p + ggplot2::scale_y_log10())))
    expect_equal(calls, 2L * expected)
  }
})

test_that("con changed plot data skip a failed pair without losing valid comparisons", {
  d <- data.frame(x = c(1:6, 10:15, 20:25), z = 51:68,
                  g = factor(rep(c("A", "B", "C"), each = 6)))
  pairs <- list(c("A", "B"), c("A", "C"))
  for (stack in c(FALSE, TRUE)) for (label in c("p.signif", "p.format")) {
    features <- if (stack) c("x", "z") else "x"
    p <- con_plot(d, features, type = "box", stack = stack, comparisons = pairs,
                  pairwise_method = "t.test", sig_label = label)
    q <- p
    at <- q$data$group.by != "B"
    if (stack) at <- at & q$data$feature == "x"
    q$data$value[at] <- 1
    expect_warning(b <- ggplot2::ggplot_build(q), "Skipping pairwise comparison")
    actual <- do.call(rbind, b$data[vapply(q$layers, function(l) inherits(l$geom, "GeomSignif"), logical(1))])
    changed <- d
    changed$x[changed$g != "B"] <- 1
    expect_warning(fresh <- con_plot(changed, features, type = "box", stack = stack,
      comparisons = pairs, pairwise_method = "t.test", sig_label = label), "Skipping comparison")
    built <- ggplot2::ggplot_build(fresh)
    expected <- do.call(rbind, built$data[vapply(fresh$layers, function(l) inherits(l$geom, "GeomSignif"), logical(1))])
    expect_equal(nrow(actual), if (stack) 9L else 3L)
    keys <- c("PANEL", "annotation", "x", "xend")
    expect_equal(lapply(actual[keys], as.character), lapply(expected[keys], as.character))
    expect_identical(p$data$value, if (stack) c(d$x, d$z) else d$x)
  }
})

test_that("con changed plot data omit nonfinite pair results instead of labeling them nonsignificant", {
  d <- data.frame(x = c(1:6, 10:15, 20:25), g = factor(rep(c("A", "B", "C"), each = 6)))
  for (method in c("wilcox.test", "kruskal.test")) for (label in c("p.signif", "p.format")) {
    p <- con_plot(d, type = "box", comparisons = list(c("A", "B"), c("A", "C")),
                  pairwise_method = method, sig_label = label)
    p$data$value[p$data$group.by != "B"] <- 1
    warnings <- character()
    b <- withCallingHandlers(ggplot2::ggplot_build(p), warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    })
    bracket <- tail(b$data, 1L)[[1L]]
    expect_match(paste(warnings, collapse = "\n"), "Skipping pairwise comparison.*finite.*p-value")
    expect_equal(nrow(bracket), 3L)
    expect_equal(sort(unique(c(bracket$x, bracket$xend))), c(1, 2))
    expect_false(anyNA(bracket$annotation))
    expect_false(any(bracket$annotation %in% c("NS.", "ns", "NA", "NaN")))
    expect_s3_class(suppressWarnings(ggplot2::ggplotGrob(p)), "gtable")
  }
})

test_that("con pairwise labels retain native formatting at significance and precision boundaries", {
  p_value <- 0
  local_mocked_bindings(t.test.default = function(...) list(p.value = p_value), .package = "stats")
  d <- con_data()
  for (value in c(.Machine$double.eps / 2, 0.0001, 0.05, 1)) for (label in c("p.signif", "p.format")) {
    p_value <- value
    p <- con_plot(d, type = "box", comparisons = list(c("A", "B")),
                  pairwise_method = "t.test", sig_label = label)
    native <- ggplot2::ggplot(d, ggplot2::aes(g, x)) +
      ggpubr::stat_compare_means(comparisons = list(c("A", "B")), method = "t.test", label = label)
    actual <- tail(ggplot2::ggplot_build(p)$data, 1L)[[1L]]$annotation
    expect_identical(actual, ggplot2::ggplot_build(native)$data[[1L]]$annotation)
  }
})

test_that("con wholly invalid repeated comparisons leave a drawable plot without labels", {
  p <- con_plot(con_data(), type = "box", comparisons = list(c("A", "B")),
                pairwise_method = "kruskal.test")
  p$data$value[] <- 1
  expect_warning(b <- ggplot2::ggplot_build(p), "Skipping pairwise comparison.*finite.*p-value")
  expect_equal(nrow(tail(b$data, 1L)[[1L]]), 0L)
  expect_warning(g <- ggplot2::ggplotGrob(p), "Skipping pairwise comparison.*finite.*p-value")
  expect_s3_class(g, "gtable")
})

test_that("con reused pairwise results retain test warnings on each draw", {
  d <- data.frame(x = c(1, 1, 2, 2, 3, 3, 4, 4), g = rep(c("A", "B"), each = 4))
  p <- con_plot(d, type = "box", comparisons = list(c("A", "B")))
  expect_warning(ggplot2::ggplot_build(p), "cannot compute exact p-value with ties")
  expect_warning(ggplot2::ggplot_build(p), "cannot compute exact p-value with ties")
})

test_that("con cached comparisons share equal feature values without sharing plot changes", {
  original <- getFromNamespace("t.test.default", "stats")
  calls <- 0L
  local_mocked_bindings(t.test.default = function(...) {
    calls <<- calls + 1L
    original(...)
  }, .package = "stats")
  d <- con_data()
  d$z <- d$x
  p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE,
    comparisons = list(c("A", "B"), c("B", "A")), pairwise_method = "t.test")
  expect_equal(calls, 4L)
  invisible(ggplot2::ggplotGrob(p))
  expect_equal(calls, 4L)
  q <- p
  q$data$value[q$data$feature == "x"] <- log10(q$data$value[q$data$feature == "x"])
  invisible(ggplot2::ggplotGrob(q))
  expect_equal(calls, 6L)
  invisible(ggplot2::ggplotGrob(p))
  expect_equal(calls, 6L)
  expect_equal(p$data$value, rep(d$x, 2L))
})

test_that("con global test labels fit inside normal and flipped panels", {
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = stack, flip = flip,
                 multiplegroup_comparisons = TRUE, sig_label = "p.format")
    g <- ggplot2::ggplotGrob(p)
    for (i in grep("^panel", g$layout$name)) {
      labels <- Filter(function(child) inherits(child, "text") && any(grepl("^p = ", child$label)),
                       g$grobs[[i]]$children)
      expect_length(labels, 1L)
      for (label in labels) {
        width <- grid::convertWidth(grid::grobWidth(label), "in", valueOnly = TRUE) / 3.5
        expect_lte(as.numeric(label$x) + (1 - label$hjust) * width, 1)
        expect_gte(as.numeric(label$x) - label$hjust * width, 0)
      }
    }
  }
})

test_that("con degenerate global tests skip only invalid feature annotations", {
  d <- con_data()
  d$x <- 1
  for (method in c("anova", "kruskal.test")) for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "box", stack = stack,
                  multiplegroup_comparisons = TRUE, multiple_method = method)
    warnings <- character()
    b <- withCallingHandlers(ggplot2::ggplot_build(p), warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    })
    expect_match(paste(warnings, collapse = "\n"), "Skipping global comparison.*x")
    labels <- tail(b$data, 1L)[[1L]]
    expect_equal(nrow(labels), if (stack) 1L else 0L)
    if (stack) {
      expected <- ggpubr::compare_means(z ~ g, data = d, method = method)$p
      expect_equal(labels$p, expected)
      expect_equal(as.integer(labels$PANEL), 2L)
    }
  }
  d <- data.frame(x = 1:3, g = c("A", "B", "C"))
  p <- con_plot(d, type = "box", multiplegroup_comparisons = TRUE, multiple_method = "anova")
  warnings <- character()
  b <- withCallingHandlers(ggplot2::ggplot_build(p), warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  expect_match(paste(warnings, collapse = "\n"), "Skipping global comparison.*x")
  expect_equal(nrow(tail(b$data, 1L)[[1L]]), 0L)
})

test_that("con comparison axes reserve automatic space and retain explicit zoom bounds", {
  d <- data.frame(x = 1:18, z = 51:68, g = factor(rep(c("A", "B", "C"), each = 6)))
  pairs <- list(c("A", "B"), c("A", "C"), c("B", "C"))
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip,
                 same.y.lims = TRUE, comparisons = pairs)
    b <- ggplot2::ggplot_build(p)
    axis <- if (flip) "x.range" else "y.range"
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    limits <- lapply(b$layout$panel_params, `[[`, axis)
    expect_equal(limits[[1L]], limits[[2L]])
    expect_gt(limits[[1L]][2L], max(c(brackets$y, brackets$yend)))
    for (stack in c(FALSE, TRUE)) {
      q <- con_plot(d, c("x", "z"), type = "box", stack = stack, flip = flip,
                   y.min = 0, y.max = 120, comparisons = pairs, multiplegroup_comparisons = TRUE)
      expect_equal(q$coordinates$limits$y, c(0, 120))
    }
  }
  d$z[d$g == "C"] <- NA_real_
  expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
                   same.y.lims = TRUE, comparisons = pairs, combine = FALSE)), "Skipping.*z")
  expect_equal(out[[1L]]$coordinates$limits$y, out[[2L]]$coordinates$limits$y)
})

test_that("con added log scales keep single comparison annotations inside the panel", {
  d <- con_data()
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, type = "box", comparisons = list(c("A", "B")),
      multiplegroup_comparisons = TRUE, flip = flip)
    q <- suppressMessages(p + ggplot2::scale_y_log10())
    b <- ggplot2::ggplot_build(q)
    bounds <- b$layout$panel_params[[1L]][[if (flip) "x.range" else "y.range"]]
    bracket <- b$data[[which(vapply(q$layers, function(l) inherits(l$geom, "GeomSignif"), logical(1)))]]
    global <- tail(b$data, 1L)[[1L]]
    expect_equal(nrow(bracket), 3L)
    expect_gt(min(bracket$y), max(log10(d$x)))
    expect_gt(global$y, max(bracket$y))
    expect_gt(bounds[2L], global$y)
    expect_lt(bounds[2L], 2)
    expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    expect_identical(p$data$value, d$x)
  }
})

test_that("con added log scales use transformed bar summaries for automatic annotations", {
  d <- data.frame(x = c(1, 100, 2, 200), z = c(10, 1000, 20, 2000),
                  g = factor(rep(c("A", "B"), each = 2)))
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "bar", stack = stack,
      fill.by = "feature", comparisons = list(c("A", "B")), multiplegroup_comparisons = TRUE)
    q <- suppressMessages(p + ggplot2::scale_y_log10())
    expect_warning(b <- ggplot2::ggplot_build(q),
                   "(log-10 transformation introduced|Transformation introduced) infinite values")
    kinds <- vapply(q$layers, function(l) class(l$geom)[1L], "")
    brackets <- do.call(rbind, b$data[kinds == "GeomSignif"])
    global <- do.call(rbind, b$data[kinds == "GeomText"])
    bars <- b$data[[which(kinds == "GeomCol")]]
    errors <- b$data[[which(kinds == "GeomErrorbar")]]
    expect_equal(nrow(brackets), if (stack) 6L else 3L)
    expect_equal(bars$y[1:2], c(1, log10(2) + 1))
    for (i in seq_along(b$layout$panel_params)) {
      bracket <- brackets[as.integer(brackets$PANEL) == i, ]
      label <- global$y[as.integer(global$PANEL) == i]
      bounds <- b$layout$panel_params[[i]]$y.range
      expect_gt(min(bracket$y), max(errors$ymax[as.integer(errors$PANEL) == i]))
      expect_gt(label, max(bracket$y))
      expect_gt(bounds[2L], label)
      expect_lt(bounds[2L], 6)
      expect_true(all(is.finite(bounds)))
    }
    expect_warning(g <- ggplot2::ggplotGrob(q),
                   "(log-10 transformation introduced|Transformation introduced) infinite values")
    expect_s3_class(g, "gtable")
  }
})

test_that("con transformed separate plots retain shared limits and annotation space", {
  d <- con_data()
  for (type in c("box", "bar")) for (flip in c(FALSE, TRUE)) {
    out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = type, flip = flip,
      same.y.lims = TRUE, comparisons = list(c("A", "B")), multiplegroup_comparisons = TRUE,
      combine = FALSE))
    built <- lapply(out, function(p) {
      q <- suppressMessages(p + ggplot2::scale_y_log10())
      if (type == "bar") {
        expect_warning(b <- ggplot2::ggplot_build(q),
                       "(log-10 transformation introduced|Transformation introduced) infinite values")
      } else b <- ggplot2::ggplot_build(q)
      b
    })
    axis <- if (flip) "x.range" else "y.range"
    expect_equal(built[[1L]]$layout$panel_params[[1L]][[axis]], built[[2L]]$layout$panel_params[[1L]][[axis]])
    for (b in built) {
      annotations <- tail(b$data, 2L)
      expect_gt(b$layout$panel_params[[1L]][[axis]][2L], max(annotations[[1L]]$y, annotations[[2L]]$y))
    }
  }
})

test_that("con transformed shared axes follow native ranges and preserve explicit partial bounds", {
  d <- con_data()
  for (scale in list(ggplot2::scale_y_sqrt(), ggplot2::scale_y_reverse())) {
    out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box", same.y.lims = TRUE, combine = FALSE))
    ranges <- lapply(out, function(p) ggplot2::ggplot_build(suppressMessages(p + scale))$layout$panel_params[[1L]]$y.range)
    native <- ggplot2::ggplot(data.frame(value = c(d$x, d$z)), ggplot2::aes(x = 1, y = value)) +
      ggplot2::geom_point() + scale
    expect_equal(unname(ranges[[1L]]), unname(ggplot2::ggplot_build(native)$layout$panel_params[[1L]]$y.range))
    expect_equal(ranges[[1L]], ranges[[2L]])
  }
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box", same.y.lims = TRUE,
                                  y.min = 1, combine = FALSE))
  built <- lapply(out, function(p) ggplot2::ggplot_build(suppressMessages(p + ggplot2::scale_y_log10())))
  expect_equal(built[[1L]]$layout$panel_params[[1L]]$y.range, built[[2L]]$layout$panel_params[[1L]]$y.range)
  expect_equal(out[[1L]]$coordinates$limits$y[1L], 1)
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box", same.y.lims = TRUE,
                                  y.min = 1, y.max = 100, combine = FALSE))
  built <- lapply(out, function(p) ggplot2::ggplot_build(suppressMessages(p + ggplot2::scale_y_reverse())))
  for (b in built) expect_equal(sort(unname(b$layout$panel_params[[1L]]$y.range)), c(-104.95, 3.95))
})

test_that("con shared range reuse is independent of sibling transformations", {
  d <- con_data()
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "bar", same.y.lims = TRUE, combine = FALSE))
  p <- suppressMessages(out[[1L]] + ggplot2::scale_y_log10())
  q <- suppressMessages(out[[2L]] + ggplot2::scale_y_sqrt())
  first <- suppressWarnings(ggplot2::ggplot_build(p))
  invisible(ggplot2::ggplot_build(q))
  second <- suppressWarnings(ggplot2::ggplot_build(p))
  expect_equal(first$layout$panel_params[[1L]]$y.range, second$layout$panel_params[[1L]]$y.range)
  expect_equal(first$data, second$data)
  expect_equal(ggplot2::ggplot_build(out[[1L]])$data[[2L]]$y, c(3.5, 12.5))
  expect_identical(out[[1L]]$data$value, d$x)
})

test_that("con shared transformed bar limits contain every feature SD interval", {
  d <- data.frame(x = c(1, 100, 2, 200), z = c(10, 1000, 20, 2000),
                  g = rep(c("A", "B"), each = 2))
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "bar", same.y.lims = TRUE,
    comparisons = list(c("A", "B")), combine = FALSE))
  ranges <- lapply(out, function(p) {
    q <- suppressMessages(p + ggplot2::scale_y_log10())
    expect_warning(b <- ggplot2::ggplot_build(q),
                   "(log-10 transformation introduced|Transformation introduced) infinite values")
    bracket <- tail(b$data, 1L)[[1L]]
    expect_gt(min(bracket$y), max(b$data[[3L]]$ymax))
    expect_gt(b$layout$panel_params[[1L]]$y.range[2L], max(bracket$y))
    b$layout$panel_params[[1L]]$y.range
  })
  expect_equal(ranges[[1L]], ranges[[2L]])
})

test_that("con transformed comparison axes retain explicit raw zoom bounds", {
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(con_data(), c("x", "z"), type = "bar", stack = stack,
      comparisons = list(c("A", "B")), y.min = 1, y.max = 1000)
    q <- suppressMessages(p + ggplot2::scale_y_log10())
    expect_warning(b <- ggplot2::ggplot_build(q),
                   "(log-10 transformation introduced|Transformation introduced) infinite values")
    expect_equal(q$coordinates$limits$y, c(1, 1000))
    for (panel in b$layout$panel_params) expect_equal(panel$y.range, c(-0.15, 3.15))
  }
})

test_that("con transformed annotation positions support multiple pairs and other continuous scales", {
  d <- data.frame(x = 1:18, g = factor(rep(c("A", "B", "C"), each = 6)))
  for (scale in list(ggplot2::scale_y_sqrt(), ggplot2::scale_y_reverse())) {
    p <- con_plot(d, type = "box", comparisons = list(c("A", "B"), c("A", "C")),
                  multiplegroup_comparisons = TRUE)
    q <- suppressMessages(p + scale)
    b <- ggplot2::ggplot_build(q)
    bracket <- b$data[[which(vapply(q$layers, function(l) inherits(l$geom, "GeomSignif"), logical(1)))]]
    global <- tail(b$data, 1L)[[1L]]
    expect_equal(nrow(bracket), 6L)
    expect_gt(min(bracket$y), max(scale$transform(d$x)))
    expect_gt(global$y, max(bracket$y))
    expect_gt(b$layout$panel_params[[1L]]$y.range[2L], global$y)
  }
})

test_that("con transformed shared flipped bar axes retain automatic room and a fixed lower bound", {
  p <- con_plot(con_data(), c("x", "z"), type = "bar", stack = TRUE, flip = TRUE,
    same.y.lims = TRUE, y.min = 1, comparisons = list(c("A", "B")),
    multiplegroup_comparisons = TRUE)
  q <- suppressMessages(p + ggplot2::scale_y_log10())
  expect_warning(b <- ggplot2::ggplot_build(q),
                 "(log-10 transformation introduced|Transformation introduced) infinite values")
  bounds <- lapply(b$layout$panel_params, `[[`, "x.range")
  expect_equal(bounds[[1L]], bounds[[2L]])
  expect_true(all(is.finite(bounds[[1L]])))
  expect_gt(bounds[[1L]][2L], max(tail(b$data, 2L)[[1L]]$y, tail(b$data, 1L)[[1L]]$y))
  expect_lt(bounds[[1L]][2L], 4)
  expect_equal(q$coordinates$limits$y[1L], 1)
})

test_that("con independent axes reserve space for effective comparisons only", {
  d <- con_data()
  pairs <- list(c("A", "absent"), c("B", "absent"))
  for (flip in c(FALSE, TRUE)) {
    none <- con_plot(d, type = "box", flip = flip)
    expect_warning(p <- con_plot(d, type = "box", flip = flip, comparisons = pairs), "Skipping")
    expect_equal(p$coordinates$limits$y, none$coordinates$limits$y)
    valid <- con_plot(d, type = "box", flip = flip, comparisons = list(c("A", "B")))
    expect_warning(mixed <- con_plot(d, type = "box", flip = flip,
      comparisons = c(list(c("A", "B")), pairs)), "Skipping")
    expect_equal(mixed$coordinates$limits$y, valid$coordinates$limits$y)
    expect_warning(explicit <- con_plot(d, type = "box", flip = flip, y.max = 20,
      comparisons = pairs), "Skipping")
    expect_equal(explicit$coordinates$limits$y, c(min(d$x), 20))
  }
})

test_that("con stacked dot plots retain requested raw point overlays", {
  d <- con_data()
  p <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE, add_point = TRUE)
  expect_length(p$layers, 2L)
  b <- ggplot2::ggplot_build(p)$data
  expect_equal(nrow(b[[2L]]), 2L * nrow(d))
})

test_that("con stacked points inherit a dodge aesthetic under either fill mode", {
  for (stack in c(FALSE, TRUE)) for (fill in c("group", "feature")) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = stack,
                 fill.by = fill, add_point = TRUE)
    b <- ggplot2::ggplot_build(p)$data
    points <- b[[length(b)]]
    expect_equal(nrow(points), if (stack) 24L else 12L)
    expect_true(all(points$x > 0.5 & points$x < 2.5))
  }
})

test_that("con scales honor shared and independent stacked axes in both orientations", {
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE, flip = flip)
    b <- ggplot2::ggplot_build(p)
    axis <- if (flip) "x.range" else "y.range"
    independent <- lapply(b$layout$panel_params, `[[`, axis)
    expect_lt(independent[[1L]][2L], independent[[2L]][1L])
    q <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE,
                  same.y.lims = TRUE, flip = flip)
    shared <- lapply(ggplot2::ggplot_build(q)$layout$panel_params, `[[`, axis)
    expect_equal(shared[[1L]], shared[[2L]])
    expect_true(shared[[1L]][1L] <= 1 && shared[[1L]][2L] >= 115)
    explicit <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE,
                         y.min = 0, y.max = 200, flip = flip)
    limits <- lapply(ggplot2::ggplot_build(explicit)$layout$panel_params, `[[`, axis)
    expect_equal(limits[[1L]], limits[[2L]])
    expect_true(limits[[1L]][1L] <= 0 && limits[[1L]][2L] >= 200)
  }
})

test_that("con independent vertical facets leave room for boundary tick labels", {
  for (size in c(14, 20)) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE, base_size = size)
    grob <- ggplot2::ggplotGrob(p)
    panels <- grob$layout[grepl("^panel-", grob$layout$name), , drop = FALSE]
    panels <- panels[order(panels$t), , drop = FALSE]
    gap <- sum(grob$heights[seq.int(panels$b[1L] + 1L, panels$t[2L] - 1L)])
    text <- grid::textGrob("-500", gp = grid::gpar(fontsize = size, fontface = "bold"))
    expect_gte(grid::convertHeight(gap, "pt", valueOnly = TRUE),
               grid::convertHeight(grid::grobHeight(text), "pt", valueOnly = TRUE))
  }
  p <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE, same.y.lims = TRUE)
  grob <- ggplot2::ggplotGrob(p)
  panels <- grob$layout[grepl("^panel-", grob$layout$name), , drop = FALSE]
  panels <- panels[order(panels$t), , drop = FALSE]
  gap <- sum(grob$heights[seq.int(panels$b[1L] + 1L, panels$t[2L] - 1L)])
  expect_equal(grid::convertHeight(gap, "pt", valueOnly = TRUE), 0)
})

test_that("con split panels retain group colours when local ordering changes", {
  d <- con_data()
  d$x <- c(1, 10, 2, 11, 3, 12, 13, 4, 14, 5, 15, 6)
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "bar",
                                  sort = TRUE, palette = c("red", "blue")))
  maps <- lapply(seq_len(length(out)), function(i) {
    p <- out[[i]]
    scale <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
    scale$map(c("A", "B"))
  })
  expect_identical(maps[[1L]], maps[[2L]])
  expect_setequal(maps[[1L]], c("red", "blue"))
})

test_that("con split palettes retain explicit missing factor levels", {
  d <- data.frame(x = 1:12, z = 21:32,
                  g = factor(rep(c("A", NA), 6), exclude = NULL),
                  batch = rep(c("S1", "S2"), each = 6))
  for (stack in c(FALSE, TRUE)) for (type in c("box", "bar", "dot")) {
    baseline <- con_plot(d, c("x", "z"), type = type, stack = stack)
    expected <- ggplot2::ggplot_build(baseline)$plot$scales$get_scales("fill")$map(c("A", NA))
    out <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch",
                                    type = type, stack = stack, combine = FALSE))
    expect_named(out, c("S1", "S2"))
    for (p in out) {
      expect_equal(nrow(p$data), if (stack) 12L else 6L)
      expect_equal(sum(is.na(as.character(p$data$group.by))), if (stack) 6L else 3L)
      b <- ggplot2::ggplot_build(p)
      expect_equal(b$plot$scales$get_scales("fill")$map(c("A", NA)), expected)
    }
  }
  d$g <- factor(rep(NA_character_, 12), exclude = NULL)
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "bar", combine = FALSE))
  expect_equal(vapply(out, function(p) nrow(p$data), 1L), c(S1 = 6L, S2 = 6L))
  expect_equal(ggplot2::ggplot_build(out[[1L]])$data[[2L]]$y, 3.5)
})

test_that("con empty string categories retain colours in split and background plots", {
  for (role in c("group", "background")) for (split in c(FALSE, TRUE)) for (named in c(FALSE, TRUE)) {
    d <- con_data()
    d$region <- ifelse(d$g == "A", "North", "South")
    if (role == "group") d$g <- factor(ifelse(d$g == "A", "", "B")) else d$region[d$region == "North"] <- ""
    original <- d
    palette <- if (named) stats::setNames(c("red", "blue"), levels(d$g)) else NULL
    background <- if (named) stats::setNames(c("grey85", "transparent"), unique(d$region)) else NULL
    out <- suppressMessages(plt_con(d, "x", "g", type = "box", bg.by = "region",
      split.by = if (split) "batch" else NULL, palette = palette, bg_palette = background, combine = FALSE))
    for (p in out) {
      expect_equal(nrow(p$data), if (split) 6L else 12L)
      b <- ggplot2::ggplot_build(p)
      expect_identical(unname(b$plot$scales$get_scales("fill")$map(levels(d$g))),
                       if (named) c("red", "blue") else as.character(pal_lancet)[1:2])
      expect_identical(unname(p$layers[[1L]]$data$fill), c("grey85", "transparent"))
    }
    expect_identical(d, original)
  }
})

test_that("con group sorting uses finite observations without losing unranked groups", {
  d <- data.frame(x = c(1, Inf, Inf, 2, 3, 4), z = 11:16, g = rep(c("A", "B"), each = 3))
  p <- con_plot(d, type = "box", sort = TRUE)
  expect_identical(levels(p$data$group.by), c("B", "A"))
  p <- con_plot(d, type = "box", sort = "increasing")
  expect_identical(levels(p$data$group.by), c("A", "B"))
  d$x[1:3] <- Inf
  p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, sort = TRUE)
  expect_identical(levels(p$data$group.by), c("B", "A"))
  expect_equal(sum(p$data$feature == "z" & p$data$group.by == "A"), 3L)
})

test_that("con axis limit validation rejects malformed or non-scalar bounds early", {
  d <- con_data()
  invalid <- list("95", "q-1", "q1.5", "q101", "x", NA_real_, Inf,
                  numeric(), c(1, 2), matrix(1, 1, 1), TRUE)
  for (arg in c("y.min", "y.max")) for (value in invalid) {
    args <- list(data = d, type = "box")
    args[[arg]] <- value
    expect_error(do.call(con_plot, args), arg)
  }
  p <- con_plot(d, type = "box", y.min = "q0", y.max = "q100")
  expect_equal(unname(p$coordinates$limits$y), range(d$x))
})

test_that("con logical switches and sorting reject ambiguous inputs", {
  flags <- c("add_box", "add_point", "add_trend", "multiplegroup_comparisons", "same.y.lims",
              "stack", "flip", "combine", "force")
  for (arg in flags) for (value in list(NA, c(TRUE, FALSE), 1L, "TRUE", logical(), matrix(TRUE, 1, 1))) {
    args <- list(data = con_data(), stat.by = "x", group.by = "g", type = "box")
    args[[arg]] <- value
    expect_error(do.call(plt_con, args), arg)
  }
  for (value in list("ascending", "", NA, c("increasing", "decreasing"), 1L, NULL, matrix("increasing", 1, 1))) {
    expect_error(con_plot(con_data(), type = "box", sort = value), "sort")
  }
  for (value in list(FALSE, TRUE, "increasing", "decreasing")) {
    p <- con_plot(con_data(), type = "box", sort = value)
    expect_identical(levels(p$data$group.by),
      if (isFALSE(value) || identical(value, "increasing")) c("A", "B") else c("B", "A"))
  }
})

test_that("con split combine FALSE returns named plots and rejects saving a list", {
  d <- con_data()
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box", combine = FALSE))
  expect_type(out, "list")
  expect_false(inherits(out, "patchwork"))
  expect_named(out, c("S1", "S2"))
  expect_true(all(vapply(out, inherits, logical(1), "ggplot")))
  expect_error(plt_con(d, "x", "g", split.by = "batch", combine = FALSE,
                       save = list(filename = tempfile(fileext = ".pdf"))), "combine = FALSE")
})

test_that("con split figures show overall titles once and retain panel titles", {
  text_labels <- function(grob) {
    c(if (inherits(grob, "text")) as.character(grob$label),
      unlist(lapply(grob$grobs, text_labels), use.names = FALSE),
      unlist(lapply(grob$children, text_labels), use.names = FALSE))
  }
  for (features in list("x", c("x", "z"))) {
    p <- suppressMessages(plt_con(con_data(), features, "g", split.by = "batch", type = "box",
      title = "Overall title", subtitle = "Overall subtitle"))
    labels <- text_labels(patchwork::patchworkGrob(p))
    expect_equal(sum(labels == "Overall title"), 1L)
    expect_equal(sum(labels == "Overall subtitle"), 1L)
    expect_true(all(c("S1", "S2") %in% labels))
  }
  out <- suppressMessages(plt_con(con_data(), "x", "g", split.by = "batch", type = "box",
    subtitle = "Panel subtitle", combine = FALSE))
  expect_equal(vapply(out, function(p) p$labels$title, ""), c(S1 = "S1", S2 = "S2"))
  expect_equal(vapply(out, function(p) p$labels$subtitle, ""),
               c(S1 = "Panel subtitle", S2 = "Panel subtitle"))
})

test_that("con missing split labels remain distinct from literal level names", {
  d <- data.frame(x = 1:18, g = rep(c("A", "B"), 9),
    batch = factor(rep(c("<NA>", "<NA>.1", NA), each = 6), exclude = NULL))
  for (missing_first in c(FALSE, TRUE)) {
    if (missing_first) d$batch <- factor(d$batch, levels = c(NA, "<NA>", "<NA>.1"), exclude = NULL)
    out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box", combine = FALSE))
    expect_setequal(names(out), c("<NA>", "<NA>.1", "<NA>.2"))
    expect_identical(anyDuplicated(names(out)), 0L)
    expect_equal(out[["<NA>"]]$data$value, 1:6)
    expect_equal(out[["<NA>.1"]]$data$value, 7:12)
    expect_equal(out[["<NA>.2"]]$data$value, 13:18)
    labels <- vapply(out, function(p) {
      if (exists("get_labs", envir = asNamespace("ggplot2"), inherits = FALSE)) {
        ggplot2::get_labs(p)$title
      } else p$labels$title
    }, "")
    expect_identical(unname(labels), names(out))
  }
})

test_that("con empty inputs fail clearly while usable features remain available", {
  d <- con_data()
  expect_error(con_plot(d[FALSE, ], type = "box"), "at least one observation")
  expect_error(con_plot(d[FALSE, ], group.by = NULL), "at least one observation")
  d$x <- NA_real_
  expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
                                                 combine = FALSE)), "No finite values.*x")
  expect_named(out, "z")
  expect_s3_class(out[[1L]], "ggplot")
  expect_error(con_plot(d, type = "box"), "No finite values remain")
  d$z <- Inf
  expect_error(con_plot(d, c("x", "z"), stack = TRUE), "No finite values remain")
})

test_that("con empty split levels are omitted without losing populated panels", {
  d <- con_data()
  d$batch <- factor(d$batch, levels = c("S1", "S2", "unused"))
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box", combine = FALSE))
  expect_named(out, c("S1", "S2"))
  d$x[d$batch == "S1"] <- NA_real_
  expect_warning(out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box",
                                                 combine = FALSE)), "S1.*no finite|no finite.*S1")
  expect_named(out, "S2")
})

test_that("con errorbar limits contain full SD intervals and the zero baseline", {
  for (sign in c(1, -1)) for (stack in c(FALSE, TRUE)) for (shared in c(FALSE, TRUE)) {
    d <- data.frame(x = sign * c(1, 100), z = sign * c(2, 200), g = "A")
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "bar", stack = stack,
                 same.y.lims = shared)
    b <- ggplot2::ggplot_build(p)
    intervals <- b$data[[3L]]
    for (i in seq_along(b$layout$panel_params)) {
      at <- intervals[as.integer(intervals$PANEL) == i, ]
      limits <- b$layout$panel_params[[i]]$y.range
      expect_lte(limits[1L], min(c(0, at$ymin), na.rm = TRUE))
      expect_gte(limits[2L], max(c(0, at$ymax), na.rm = TRUE))
    }
  }
})

test_that("con errorbar explicit zoom limits retain their requested bounds", {
  d <- data.frame(x = c(1, 100), z = c(2, 200), g = "A")
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "bar", stack = stack,
                 y.min = 10, y.max = 80)
    expect_equal(p$coordinates$limits$y, c(10, 80))
  }
})

test_that("con stacked bar comparisons clear the full SD intervals", {
  d <- data.frame(x = c(1, 100, 2, 200), z = c(10, 1000, 20, 2000),
                  g = rep(c("A", "B"), each = 2))
  for (flip in c(FALSE, TRUE)) for (shared in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, flip = flip,
                  same.y.lims = shared, comparisons = list(c("A", "B")),
                  multiplegroup_comparisons = TRUE)
    b <- ggplot2::ggplot_build(p)$data
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    errors <- b[[which(kinds == "GeomErrorbar")]]
    brackets <- do.call(rbind, b[which(kinds == "GeomSignif")])
    labels <- do.call(rbind, b[which(kinds == "GeomText")])
    for (panel in 1:2) {
      upper <- max(errors$ymax[as.integer(errors$PANEL) == panel])
      height <- max(brackets$y[as.integer(brackets$PANEL) == panel])
      expect_gt(height, upper)
      expect_gt(labels$y[as.integer(labels$PANEL) == panel], height)
    }
  }
})

test_that("con shared bar quantile limits use the original observations", {
  d <- data.frame(x = c(1, 2, 3, 100), z = c(4, 5, 6, 200), g = "A")
  expected <- unname(stats::quantile(c(d$x, d$z), c(0.05, 0.95)))
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "bar", stack = stack, flip = flip,
                 same.y.lims = TRUE, y.min = "q5", y.max = "q95")
    expect_equal(unname(p$coordinates$limits$y), expected)
  }
})

test_that("con independent stacked quantile zoom uses each feature without filtering statistics", {
  d <- data.frame(x = 1:20, z = 100 + 1:20, g = rep(c("A", "B"), each = 10))
  for (flip in c(FALSE, TRUE)) {
    separate <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box", flip = flip,
                     y.min = "q5", y.max = "q95", add_point = TRUE, combine = FALSE))
    p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip,
                 y.min = "q5", y.max = "q95", add_point = TRUE)
    baseline <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip, add_point = TRUE)
    b <- ggplot2::ggplot_build(p)
    axis <- if (flip) "x.range" else "y.range"
    for (i in 1:2) {
      expect_equal(unname(b$layout$panel_params[[i]][[axis]]),
                   unname(ggplot2::ggplot_build(separate[[i]])$layout$panel_params[[1L]][[axis]]))
    }
    expect_equal(b$data[[1L]][c("lower", "middle", "upper", "ymin", "ymax")],
                 ggplot2::ggplot_build(baseline)$data[[1L]][c("lower", "middle", "upper", "ymin", "ymax")])
    expect_equal(sort(b$data[[3L]]$y), sort(c(d$x, d$z)))
    bar <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, flip = flip, y.max = "q95")
    expected_bar <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, flip = flip)
    expect_equal(ggplot2::ggplot_build(bar)$data[[2L]]$y,
                 ggplot2::ggplot_build(expected_bar)$data[[2L]]$y)
  }
})

test_that("con stacked quantile zoom inherits added y transformations and keeps full-data statistics", {
  d <- con_data()
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip,
                  y.min = "q10", y.max = "q90")
    q <- suppressMessages(p + ggplot2::scale_y_log10())
    baseline <- suppressMessages(con_plot(d, c("x", "z"), type = "box", stack = TRUE,
                                          flip = flip) + ggplot2::scale_y_log10())
    separate <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box", flip = flip,
                                         y.min = "q10", y.max = "q90", combine = FALSE))
    b <- ggplot2::ggplot_build(q)
    axis <- if (flip) "x.range" else "y.range"
    for (i in 1:2) {
      reference <- ggplot2::ggplot_build(suppressMessages(separate[[i]] + ggplot2::scale_y_log10()))
      expect_equal(unname(b$layout$panel_params[[i]][[axis]]), unname(reference$layout$panel_params[[1L]][[axis]]))
      expect_identical(b$layout$panel_scales_y[[i]]$get_transformation()$name, "log-10")
      medians <- b$data[[2L]]$y[as.integer(b$data[[2L]]$PANEL) == i]
      expect_true(all(medians > b$layout$panel_params[[i]][[axis]][1L]))
      expect_true(all(medians < b$layout$panel_params[[i]][[axis]][2L]))
    }
    keys <- c("lower", "middle", "upper", "ymin", "ymax")
    expect_equal(b$data[[1L]][keys], ggplot2::ggplot_build(baseline)$data[[1L]][keys])
    expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
    expect_identical(ggplot2::ggplot_build(p)$layout$panel_scales_y[[1L]]$get_transformation()$name, "identity")
  }
})

test_that("con stacked quantile bar statistics respect added sqrt scales and fixed partial bounds", {
  d <- data.frame(x = c(1, 4, 9, 100), z = c(4, 16, 36, 400), g = rep(c("A", "B"), each = 2))
  p <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, y.min = 1, y.max = "q90")
  q <- suppressMessages(p + ggplot2::scale_y_sqrt())
  baseline <- suppressMessages(con_plot(d, c("x", "z"), type = "bar", stack = TRUE) +
                                 ggplot2::scale_y_sqrt())
  b <- ggplot2::ggplot_build(q)
  expect_equal(b$data[[2L]]$y, c(1.5, 6.5, 3, 13))
  expect_equal(b$data[[2L]]$y, ggplot2::ggplot_build(baseline)$data[[2L]]$y)
  for (i in 1:2) {
    expected <- sqrt(c(1, unname(stats::quantile(d[[c("x", "z")[i]]], 0.9))))
    expect_equal(unname(b$layout$panel_scales_y[[i]]$get_limits()), expected)
  }
})

test_that("con singleton violin groups retain raw points and summary overlays", {
  d <- data.frame(x = c(1:4, 10), g = c(rep("A", 4), "B"))
  expect_warning(p <- con_plot(d, type = "violin", add_point = TRUE, add_trend = TRUE),
                 "violin|density")
  expect_equal(nrow(p$data), 5L)
  expect_setequal(as.character(p$data$group.by), c("A", "B"))
  b <- ggplot2::ggplot_build(p)$data
  expect_equal(nrow(b[[2L]]), 5L)
  expect_equal(nrow(b[[3L]]), 2L)
  expect_equal(sort(b[[4L]]$y), c(2.5, 10))
})

test_that("con backgrounds align to displayed groups in single and stacked plots", {
  d <- data.frame(x = 1:9, z = 11:19,
                  g = factor(rep(c("A", "B", "C"), each = 3), levels = c("A", "unused", "B", "C")),
                  region = rep(c("R1", "R2", "R3"), each = 3))
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) for (type in c("box", "dot")) {
    p <- con_plot(d, c("x", "z"), type = type, stack = stack, flip = flip,
                 bg.by = "region", bg_palette = c("red", "blue", "green"))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    expect_true("GeomRect" %in% kinds)
    if (!"GeomRect" %in% kinds) next
    rects <- ggplot2::ggplot_build(p)$data[[which(kinds == "GeomRect")]]
    at <- rects$xmin <= 3 & rects$xmax >= 3
    expect_equal(as.character(rects$fill[at]), rep("blue", if (stack) 2L else 1L))
  }
})

test_that("con background categories keep their colours across sorted split panels", {
  d <- data.frame(x = c(1:3, 11:13, 11:13, 1:3), z = 101:112,
    g = factor(rep(c("A", "B", "A", "B"), each = 3)),
    batch = rep(c("S1", "S2"), each = 6),
    region = rep(c("North", "South", "North", "South"), each = 3))
  palettes <- list(c(South = "blue", North = "red"), c("red", "blue"), NULL)
  for (stack in c(FALSE, TRUE)) for (i in seq_along(palettes)) {
    out <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch",
      type = "box", sort = TRUE, stack = stack, bg.by = "region",
      bg_palette = palettes[[i]], combine = FALSE))
    expected <- if (i == 3L) c("grey85", "transparent") else c("red", "blue")
    for (p in out) {
      bands <- p$layers[[1L]]$data
      expect_identical(unname(bands$fill[match(c("North", "South"), bands$bg)]), expected)
      expect_setequal(as.character(ggplot2::ggplot_build(p)$data[[1L]]$fill), expected)
    }
  }
})

test_that("con background bands retain observed missing groups at their displayed positions", {
  for (explicit in c(FALSE, TRUE)) for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    d <- data.frame(x = 1:18, z = 101:118, g = rep(c("A", "B", NA), each = 6),
                    region = rep(c("North", "South", "Unknown"), each = 6))
    if (explicit) d$g <- factor(d$g, levels = c(NA, "B", "A"), exclude = NULL)
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack, flip = flip,
      bg.by = "region", bg_palette = c(North = "red", South = "blue", Unknown = "green"))
    b <- ggplot2::ggplot_build(p)
    position <- which(is.na(b$layout$panel_scales_x[[1L]]$get_limits()))
    expect_length(position, 1L)
    rects <- b$data[[1L]]
    expect_identical(as.character(rects$fill[rects$xmin <= position & rects$xmax >= position]),
                     rep("green", if (stack) 2L else 1L))
    expect_equal(nrow(p$data), if (stack) 36L else 18L)
  }
  d$category <- rep(c("Yes", "No"), 9)
  invisible(utils::capture.output(q <- suppressMessages(plt_cat(d, "category", "g", NA_stat = TRUE,
    position = "dodge", bg.by = "region", bg_palette = c(North = "red", South = "blue", Unknown = "green")))))
  bands <- q$layers[[1L]]$data
  expect_identical(unname(bands$fill[bands$bg == "Unknown"]), "green")
  d$x[is.na(as.character(d$g))] <- NA_real_
  p <- con_plot(d, type = "box", bg.by = "region")
  expect_equal(nrow(p$layers[[1L]]$data), 2L)
  expect_length(ggplot2::ggplot_build(p)$layout$panel_scales_x[[1L]]$get_limits(), 2L)
})

test_that("con shared background helper matches named colours in categorical plots", {
  d <- data.frame(category = rep(c("Yes", "No"), 6),
    g = factor(rep(c("A", "B"), each = 6), levels = c("B", "A")),
    region = rep(c("North", "South"), each = 6))
  invisible(utils::capture.output(p <- suppressMessages(plt_cat(d, "category", "g",
    position = "dodge", bg.by = "region", bg_palette = c(North = "red", South = "blue")))))
  bands <- p$layers[[1L]]$data
  expect_identical(unname(bands$fill[match(c("North", "South"), bands$bg)]), c("red", "blue"))
  expect_setequal(as.character(ggplot2::ggplot_build(p)$data[[1L]]$fill), c("red", "blue"))
  expect_error(con_plot(transform(d, x = 1:12), type = "box", bg.by = "region",
                       bg_palette = c(North = "red")), "bg_palette")
})

test_that("con background categories follow later discrete-axis reordering", {
  d <- con_data()
  d$region <- ifelse(d$g == "A", "North", "South")
  d$g <- factor(d$g, levels = c("A", "unused", "B"))
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack, flip = flip,
      bg.by = "region", bg_palette = c(North = "red", South = "blue"))
    q <- suppressMessages(p + ggplot2::scale_x_discrete(limits = c("B", "unused", "A")))
    b <- ggplot2::ggplot_build(q)
    bands <- b$data[[1L]]
    at <- match("A", b$layout$panel_scales_x[[1L]]$get_limits())
    expect_equal(as.character(bands$fill[bands$xmin <= at & bands$xmax >= at]),
                 rep("red", if (stack) 2L else 1L))
    expect_equal(ggplot2::ggplot_build(p)$layout$panel_scales_x[[1L]]$get_limits(),
                 c("A", "unused", "B"))
    invisible(ggplot2::ggplotGrob(q))
  }
  d$category <- rep(c("Yes", "No"), 6)
  invisible(utils::capture.output(p <- suppressMessages(plt_cat(d, "category", "g",
    position = "dodge", bg.by = "region", bg_palette = c(North = "red", South = "blue")))))
  b <- ggplot2::ggplot_build(suppressMessages(p + ggplot2::scale_x_discrete(limits = c("B", "A"))))
  bands <- b$data[[1L]]
  expect_equal(as.character(bands$fill[bands$xmin <= 2 & bands$xmax >= 2]), "red")
  for (flip in c(FALSE, TRUE)) {
    p <- suppressMessages(plt_cat(d, "category", "g", type = "trend", position = "dodge",
      bg.by = "region", flip = flip))
    native <- suppressMessages(plt_cat(d, "category", "g", type = "trend", position = "dodge",
      flip = flip))
    expect_identical(ggplot2::ggplot_build(p)$data[-1L], ggplot2::ggplot_build(native)$data)
    invisible(ggplot2::ggplotGrob(p))
  }
})

test_that("con legend titles describe the mapped variable and survive background layers", {
  text_labels <- function(grob) {
    c(if (inherits(grob, "text")) as.character(grob$label) else character(),
      unlist(lapply(grob$grobs, text_labels), use.names = FALSE),
      unlist(lapply(grob$children, text_labels), use.names = FALSE))
  }
  labels <- function(p) {
    g <- ggplot2::ggplotGrob(p)
    unlist(lapply(g$grobs[grep("guide-box", g$layout$name)], text_labels), use.names = FALSE)
  }
  d <- con_data()
  d$Treatment <- d$g
  d$region <- ifelse(d$g == "A", "North", "South")
  for (stack in c(FALSE, TRUE)) for (background in c(FALSE, TRUE)) for (fill in c("group", "feature")) {
    p <- con_plot(d, c("x", "z"), group.by = "Treatment", type = "box", stack = stack,
      fill.by = fill, bg.by = if (background) "region" else NULL)
    if (stack) p <- p + ggplot2::theme(legend.title = ggplot2::element_text())
    expect_true((if (fill == "group") "Treatment" else "Feature") %in% labels(p))
    expect_false("I(fill)" %in% labels(p))
  }
  p <- con_plot(d, group.by = NULL, type = "box")
  expect_null(p$labels$fill)
  expect_true("Custom" %in% labels(p + ggplot2::labs(fill = "Custom")))
})

test_that("con jitter defaults preserve numeric values and the random state", {
  expect_identical(formals(plt_con)$jitter.height, 0)
  d <- con_data()
  d$x <- d$x * 1e-10
  d$z <- d$z * 1e-10
  for (stack in c(FALSE, TRUE)) {
    set.seed(73)
    before <- .Random.seed
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack, add_point = TRUE)
    b <- ggplot2::ggplot_build(p)$data
    points <- b[[length(b)]]
    expect_equal(sort(points$y), sort(if (stack) c(d$x, d$z) else d$x))
    expect_identical(before, .Random.seed)
    expect_identical(points$x, ggplot2::ggplot_build(p)$data[[length(b)]]$x)
  }
})

test_that("con dispatch builds only the requested stacked plot", {
  original <- getFromNamespace(".plt_con_single", "UtilsR")
  separate_calls <- 0L
  local_mocked_bindings(.plt_con_single = function(...) {
    separate_calls <<- separate_calls + 1L
    original(...)
  }, .package = "UtilsR")
  p <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE)
  expect_equal(nrow(p$data), 24L)
  expect_equal(length(ggplot2::ggplot_build(p)$layout$panel_params), 2L)
  expect_equal(separate_calls, 0L)
})

test_that("con split figures measure the final canvas once and retain list sizes", {
  skip_if_not_installed("RegR")
  original <- getFromNamespace(".save_sized", "UtilsR")
  measured <- 0L
  local_mocked_bindings(.save_sized = function(...) {
    measured <<- measured + 1L
    original(...)
  }, .package = "UtilsR")
  d <- con_data()
  p <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch", type = "box"))
  expect_equal(measured, 1L)
  expect_length(attr(p, "plot_size"), 2L)
  measured <- 0L
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch",
                                  type = "box", combine = FALSE))
  expect_equal(measured, 2L)
  expect_named(out, c("S1", "S2"))
  expect_true(all(vapply(out, function(child) length(attr(child, "plot_size")) == 2L, logical(1))))
})

test_that("con memory does not retain unused input through plot environments", {
  skip_if_not_installed("lobstr")
  make <- function(extra, mode) {
    set.seed(20261030)
    d <- data.frame(x = rnorm(40), z = rnorm(40), g = rep(c("A", "B"), each = 20))
    if (extra) d$unused <- I(matrix(rnorm(40L * 5000L), nrow = 40L))
    suppressMessages(UtilsR::plt_con(d, if (mode == "stack") c("x", "z") else "x", "g",
                                   type = if (mode == "dot") "dot" else "box",
                                   stack = mode == "stack", add_point = TRUE, add_trend = mode == "box",
                                   combine = FALSE))[[1L]]
  }
  environment(make) <- globalenv()
  for (mode in c("box", "dot", "stack")) {
    invisible(make(FALSE, mode))
    small <- make(FALSE, mode)
    extra <- make(TRUE, mode)
    expect_lt(as.numeric(lobstr::obj_size(extra)) - as.numeric(lobstr::obj_size(small)), 100000)
    a <- withr::local_tempfile(fileext = ".rds")
    b <- withr::local_tempfile(fileext = ".rds")
    saveRDS(small, a)
    saveRDS(extra, b)
    expect_lt(file.info(b)$size - file.info(a)$size, 100000)
    expect_equal(ggplot2::ggplot_build(small)$data, ggplot2::ggplot_build(extra)$data)
  }
})

test_that("con single plot size is independent of sibling feature plots", {
  skip_if_not_installed("lobstr")
  make <- function(extra, type, background) {
    set.seed(215)
    d <- data.frame(x = rnorm(120), g = factor(rep(c("A", "B"), 60)), bg = rep(c("R1", "R2"), 60))
    features <- "x"
    if (extra) {
      for (i in 1:2) d[[paste0("z", i)]] <- rnorm(120)
      features <- c(features, paste0("z", 1:2))
    }
    suppressMessages(UtilsR::plt_con(d, features, "g", type = type,
      bg.by = if (background) "bg" else NULL, add_point = TRUE,
      add_box = type == "violin", add_trend = type == "bar", combine = FALSE,
      comparisons = if (type == "dot") NULL else list(c("A", "B"))))[[1L]]
  }
  environment(make) <- globalenv()
  for (type in c("violin", "box", "bar", "dot")) for (background in c(FALSE, TRUE)) {
    invisible(make(FALSE, type, background))
    a <- make(FALSE, type, background)
    b <- make(TRUE, type, background)
    expect_lt(as.numeric(lobstr::obj_size(b)) - as.numeric(lobstr::obj_size(a)), 100000)
    first <- withr::local_tempfile(fileext = ".rds")
    second <- withr::local_tempfile(fileext = ".rds")
    saveRDS(a, first)
    saveRDS(b, second)
    expect_lt(file.info(second)$size - file.info(first)$size, 100000)
    reference <- if (type == "dot") suppressMessages(a + ggplot2::scale_size_area(
      name = "Count", max_size = 6, n.breaks = 4, limits = b$scales$get_scales("size")$limits)) else a
    reference_data <- ggplot2::ggplot_build(reference)$data
    actual_data <- ggplot2::ggplot_build(b)$data
    if (type == "dot") {
      expect_identical(lapply(reference_data, function(d) sort(names(d))),
                       lapply(actual_data, function(d) sort(names(d))))
      reference_data <- Map(function(ref, actual) ref[names(actual)], reference_data, actual_data)
    }
    expect_identical(reference_data, actual_data)
  }
})

test_that("continuous bar error bars retain extreme finite numeric scales", {
  control <- c(1.5 - stats::sd(c(1, 2)), 1.5 + stats::sd(c(1, 2)))
  for (unit in c(1, 1e-160, 1e-200, 1e200)) {
    d <- data.frame(x = c(1, 2) * unit, g = "A")
    p <- suppressMessages(plt_con(d, "x", "g", type = "bar", combine = FALSE))[[1L]]
    built <- ggplot2::ggplot_build(p)
    index <- which(vapply(p$layers, function(layer) inherits(layer$geom, "GeomErrorbar"), logical(1)))
    expect_length(index, 1L)
    bounds <- unlist(built$data[[index]][c("ymin", "ymax")], use.names = FALSE) / unit
    expect_equal(bounds, control, tolerance = 1e-12)
    expect_gte(max(built$layout$panel_params[[1L]]$y.range) / unit, control[[2L]])
  }
})

test_that("continuous groups retain complex and AsIs identities", {
  groups <- list(complex(real = 1, imaginary = c(1, 1 + .Machine$double.eps)),
                 I(c(1, 1 + .Machine$double.eps)))
  for (group in groups) {
    d <- data.frame(x = 1:6, g = group[rep(1:2, each = 3)])
    original <- d
    p <- suppressMessages(plt_con(d, "x", "g", type = "box", combine = FALSE))[[1L]]
    expect_length(levels(p$data$g), 2L)
    expect_equal(as.integer(table(p$data$g)), c(3L, 3L))
    expect_equal(sort(ggplot2::layer_data(p)$middle), c(2, 5))
    expect_identical(d, original)
  }
})

test_that("continuous t tests retain p values at extreme finite scales", {
  x <- 1:3
  y <- 3:5
  reference <- stats::t.test(x, y)$p.value
  for (unit in c(1, 1e-200, 1e200)) {
    d <- data.frame(x = c(x, y) * unit, g = rep(c("A", "B"), each = 3))
    expect_no_warning(p <- suppressMessages(plt_con(d, "x", "g", type = "box", combine = FALSE,
      comparisons = list(c("A", "B")), pairwise_method = "t.test"))[[1L]])
    index <- which(vapply(p$layers, function(layer) inherits(layer$geom, "GeomSignif"), logical(1)))
    expect_length(index, 1L)
    if (length(index) != 1L) next
    callback <- p$layers[[index]]$stat_params$test
    expect_equal(callback(x * unit, y * unit, paired = FALSE)$p.value, reference)
    expect_equal(callback(x * unit, y * unit, mu = unit)$p.value, stats::t.test(x, y, mu = 1)$p.value)
    expect_identical(unique(ggplot2::layer_data(p, index)$annotation), "ns")
  }
})

test_that("continuous ANOVA comparisons preserve p values across finite scales", {
  x <- c(1:3, 3:5, 6:8)
  g <- rep(c("A", "B", "C"), each = 3)
  expected <- summary(stats::aov(x ~ g))[[1L]][["Pr(>F)"]][1L]
  pair <- .con_pairwise_test("anova")(x[1:3], x[4:6])$p.value
  for (unit in c(1, 1e-160, 1e-200, 1e200)) {
    expect_equal(.con_pairwise_test("anova")(x[1:3] * unit, x[4:6] * unit)$p.value, pair)
    d <- data.frame(x = x * unit, g = g)
    p <- suppressMessages(plt_con(d, "x", "g", type = "box", combine = FALSE,
      multiplegroup_comparisons = TRUE, multiple_method = "anova"))[[1L]]
    expect_no_warning(built <- ggplot2::ggplot_build(p))
    global <- tail(built$data, 1L)[[1L]]
    expect_equal(global$p, expected)
    expect_equal(global$y / unit, max(x))
  }
})

test_that("continuous comparisons index samples without scanning groups per pair", {
  groups <- factor(rep(c("A", "B", "C"), 5L), levels = c("C", "B", "A", "unused"))
  values <- c(1, 4, 8, 3, 5, 7, 2, 6, 9, 4, 3, 9, 5, 8, 6)
  comparisons <- list(c("A", "B"), c(1L, 2L), c("B", "A"))
  fn <- .con_comparisons
  env <- new.env(parent = environment(fn))
  scans <- 0L
  env[["=="]] <- function(x, y) {
    if (is.factor(x) && length(x) == length(groups)) scans <<- scans + 1L
    base::`==`(x, y)
  }
  environment(fn) <- env
  kept <- fn(comparisons, groups, "value", values, "t.test")
  cache <- attr(kept, ".con_test_cache")
  expect_identical(scans, 0L)
  expect_identical(cache[[1L]]$x$value, values[groups == "A"])
  expect_identical(cache[[2L]]$x$value, values[groups == "C"])
  expect_equal(cache[[3L]]$p.value, stats::t.test(values[groups == "B"], values[groups == "A"])$p.value)
})

test_that("paired tests preserve exact differences at extreme offsets", {
  test <- .con_pairwise_test("t.test")
  for (power in c(-700, 900)) {
    centre <- 1.5 * 2^power
    step <- 2^(power - 52)
    x <- centre + c(3, 5, 8, 9, 20) * step
    y <- centre + c(2, 3, 4, 7, 18) * step
    difference <- (x - y) / step
    for (mu in c(0, 1)) {
      reference <- stats::t.test(difference, numeric(length(x)), paired = TRUE, mu = mu,
        alternative = "greater")
      actual <- test(c(NA_real_, x), c(centre, y), paired = TRUE, mu = mu * step,
        alternative = "greater")
      expect_equal(actual$p.value, reference$p.value, tolerance = 1e-14)
      expect_equal(actual$statistic, reference$statistic, tolerance = 1e-14)
    }
  }
})

test_that("continuous ANOVA preserves variation around extreme offsets", {
  x <- c(2, 5, 8, 11, 20)
  y <- c(12, 14, 15, 16, 21)
  test <- .con_pairwise_test("anova")
  expected <- test(x, y)$p.value
  for (power in c(-700, 900)) {
    offset <- 1.5 * 2^power
    step <- 2^(power - 52)
    actual <- test(offset + x * step, offset + y * step)$p.value
    expect_equal(actual, expected, tolerance = 1e-13)
  }
})

test_that("unpaired tests retain finite differences around extreme offsets", {
  test <- .con_pairwise_test("t.test")
  x <- c(2, 5, 8, 11, 20)
  y <- c(12, 14, 15, 16, 21)
  for (power in c(-700, 900)) {
    offset <- 1.5 * 2^power
    step <- 2^(power - 52)
    for (equal in c(FALSE, TRUE)) {
      expected <- stats::t.test(x, y, var.equal = equal, mu = 1)$p.value
      actual <- test(offset + x * step, offset + y * step,
        var.equal = equal, mu = step)$p.value
      expect_equal(actual, expected, tolerance = 1e-13)
    }
  }
})

test_that("continuous dot bin midpoints retain subnormal endpoints", {
  step <- .Machine$double.xmin * .Machine$double.eps
  expect_identical(.con_dot_bins(step * c(1, 2), step * c(1, 2)) / step, c(2, 2))
  expect_identical(.con_dot_bins(step * c(-2, -1), step * c(-2, -1)) / step, c(-2, -2))
  expect_equal(.con_dot_bins(c(1.5e308, 1.7e308), c(1.5e308, 1.7e308)), rep(1.6e308, 2L))
})

test_that("continuous dot counts do not retain group member rows", {
  data <- data.frame(group = factor(c("B", "B", "A", "B", "A"), levels = c("A", "B", "C")),
                     value = c(2, 1, 1, 2, 2))
  reference <- .con_dot_counts(data, c("group", "value"))
  testthat::local_mocked_bindings(vec_group_loc = function(...) stop("allocated all dot member rows"),
                                .package = "vctrs")
  actual <- .con_dot_counts(data, c("group", "value"))
  expect_identical(actual, reference)
  expect_equal(sum(actual$n), nrow(data))
  expect_identical(levels(actual$group), levels(data$group))
})

test_that("continuous t tests inspect only finite magnitude bounds", {
  x <- seq(.01, 4, length.out = 2000)
  y <- seq(.02, 4.1, length.out = 2000)
  fn <- .con_pairwise_test("t.test")
  environment(fn) <- list2env(list(abs = function(x) {
    if (length(x) > 100L) stop("copied every test value for its magnitude")
    base::abs(x)
  }), parent = environment(fn))
  for (paired in c(FALSE, TRUE)) {
    expect_equal(fn(x, y, paired = paired)$p.value, stats::t.test(x, y, paired = paired)$p.value)
    expect_equal(fn(x * 1e200, y * 1e200, paired = paired)$p.value,
                 .con_pairwise_test("t.test")(x * 1e200, y * 1e200, paired = paired)$p.value)
  }
})

test_that("single violin retains a missing group singleton as a point", {
  d <- data.frame(group = factor(c("A", "A", "B", "B", NA)), value = c(1, 2, 4, 5, 9))
  expect_warning(p <- suppressMessages(plt_con(d, "value", "group", type = "violin",
    add_point = TRUE)), "Omitted violin density")
  layer <- Filter(function(x) inherits(x$geom, "GeomViolin"), p$layers)[[1L]]
  expect_equal(layer$data$value, d$value[1:4])
  expect_identical(nrow(p$data), 5L)
  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("stacked violin densities require two finite feature observations", {
  d <- data.frame(g = rep(c("A", "B"), each = 3L),
    left = c(1, 2, 3, 5, NA, NA), right = c(8, NA, NA, 4, 5, 6))
  expect_warning(p <- suppressMessages(plt_con(d, c("left", "right"), "g", type = "violin",
    stack = TRUE, add_point = TRUE)), "Omitted violin density")
  layer <- Filter(function(x) inherits(x$geom, "GeomViolin"), p$layers)[[1L]]
  expect_equal(layer$data$value, c(1, 2, 3, 4, 5, 6))
  expect_identical(nrow(p$data), 8L)
  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("continuous split panels reuse rows for observed factor codes", {
  d <- data.frame(x = c(1, 2, 3, 4, 5, 6), g = rep(c("A", "B"), 3L),
    site = factor(c("", "B", "B", "", NA, NA), levels = c("B", "", NA), exclude = NULL))
  fn <- plt_con
  env <- new.env(parent = environment(fn))
  env[["=="]] <- function(x, y) {
    if (identical(x, as.integer(d$site)) && length(y) == 1L) stop("rescanned continuous split codes")
    base::`==`(x, y)
  }
  environment(fn) <- env
  plots <- suppressMessages(fn(d, "x", "g", split.by = "site", combine = FALSE, type = "box"))
  expect_identical(names(plots), c("B", "", "<NA>"))
  expect_equal(lapply(plots, function(p) p$data$value), list(B = c(2, 3), c(1, 4), c(5, 6)) |>
    stats::setNames(names(plots)))
})

test_that("continuous dot ordering uses only representative rows", {
  d <- data.frame(g = ordered(rep(c("B", "A", "B", NA), 50L), levels = c("A", "B", "unused")),
    x = rep(c(1L, 1L, 2L, 3L), 50L))
  fn <- .con_dot_counts
  env <- new.env(parent = environment(fn))
  env$match <- function(x, table, ...) {
    if (length(x) == nrow(d)) stop("matched all original rows")
    base::match(x, table, ...)
  }
  environment(fn) <- env
  result <- fn(d, c("g", "x"))
  expect_identical(result$g, d$g[1:4])
  expect_identical(result$x, c(1L, 1L, 2L, 3L))
  expect_identical(result$n, rep(50L, 4L))
})

test_that("shared continuous limits retain finite interior values on log scales", {
  d <- data.frame(a = c(-1, 1, 5, 10), b = c(2, 10, 100, 200), g = rep(c("A", "B"), each = 2L))
  plots <- suppressMessages(plt_con(d, c("a", "b"), "g", type = "box", same.y.lims = TRUE,
    combine = FALSE))
  build <- function(p) withCallingHandlers(ggplot2::ggplot_build(p + ggplot2::scale_y_log10()),
    warning = function(w) {
      if (grepl("NaNs produced|log-10 transformation|Removed 1 row", conditionMessage(w))) {
        invokeRestart("muffleWarning")
      }
    })
  ranges <- lapply(plots, function(p) build(p)$layout$panel_params[[1L]]$y.range)
  expect_identical(ranges[[1L]], ranges[[2L]])
  expect_true(ranges[[1L]][1L] <= 0)
  expect_true(ranges[[1L]][2L] >= log10(200))
})

test_that("stacked quantile bounds swap sides on reversed scales", {
  d <- data.frame(x = 1:10, z = seq(100, 190, by = 10), g = rep(c("A", "B"), each = 5L))
  for (flip in c(FALSE, TRUE)) {
    for (bound in list(list(y.max = "q90"), list(y.min = "q10"))) {
      p <- do.call(con_plot, c(list(d, c("x", "z"), type = "box", stack = TRUE, flip = flip), bound))
      a <- ggplot2::ggplot_build(p)$layout$panel_params
      b <- ggplot2::ggplot_build(suppressMessages(p + ggplot2::scale_y_reverse()))$layout$panel_params
      axis <- if (flip) "x.range" else "y.range"
      for (i in seq_along(a)) expect_equal(b[[i]][[axis]], -rev(a[[i]][[axis]]))
    }
  }
})

test_that("independent continuous zooms reverse along with their data", {
  d <- data.frame(x = 1:10, z = seq(100, 190, by = 10), g = rep(c("A", "B"), each = 5L))
  for (flip in c(FALSE, TRUE)) {
    for (bound in list(list(y.max = "q90"), list(y.min = "q10"))) {
      p <- do.call(con_plot, c(list(d, "x", type = "box", stack = FALSE, flip = flip), bound))
      a <- ggplot2::ggplot_build(p)$layout$panel_params
      b <- ggplot2::ggplot_build(suppressMessages(p + ggplot2::scale_y_reverse()))$layout$panel_params
      axis <- if (flip) "x.range" else "y.range"
      for (i in seq_along(a)) expect_equal(b[[i]][[axis]], -rev(a[[i]][[axis]]))
    }
  }
})

test_that("stacked continuous long data bind only finite rows", {
  d <- data.frame(x = c(1L, NA, 5L, 8L), z = c(Inf, 1.5, 3, NA),
                  g = factor(c("b", "a", "b", "a"), levels = c("b", "a")))
  fn <- .plt_con_stacked
  env <- new.env(parent = environment(fn))
  env$do.call <- function(what, args, ...) {
    if (identical(what, base::rbind) && length(args) &&
        all(c("value", "feature") %in% names(args[[1L]])) &&
        sum(vapply(args, nrow, integer(1L))) > 5L) stop("bound discarded rows")
    base::do.call(what, args, ...)
  }
  environment(fn) <- env
  local_mocked_bindings(.plt_con_stacked = fn, .package = "UtilsR")
  p <- con_plot(d, c("x", "z"), group.by = "g", stack = TRUE, type = "box")
  expect_identical(p$data$value, c(1, 5, 8, 1.5, 3))
  expect_identical(rownames(p$data), c("1", "3", "4", "6", "7"))
  expect_identical(levels(p$data$feature), c("x", "z"))
  expect_identical(levels(p$data$group.by), c("b", "a"))
})

test_that("continuous quantile zooms follow a composed decreasing scale", {
  d <- data.frame(x = 1:10, z = seq(100, 190, by = 10), g = rep(c("A", "B"), each = 5L))
  trans <- scales::transform_compose("log10", "reverse")
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "box", stack = stack, flip = flip,
                  y.max = "q90")
    b <- ggplot2::ggplot_build(suppressMessages(p + ggplot2::scale_y_continuous(
      trans = trans, expand = c(0, 0))))
    axis <- if (flip) "x.range" else "y.range"
    for (i in seq_along(b$layout$panel_params)) {
      x <- d[[c("x", "z")[i]]]
      expected <- -log10(c(unname(stats::quantile(x, .9)), min(x)))
      expect_equal(unname(b$layout$panel_params[[i]][[axis]]), expected)
    }
  }
})

test_that("continuous plots keep extreme shared limits without comparisons", {
  d <- data.frame(x = c(-1e308, -5e307, 5e307, 1e308), z = 1:4,
    g = rep(c("A", "B"), each = 2L))
  plots <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
    same.y.lims = TRUE, combine = FALSE))
  for (p in plots) expect_equal(unname(p$coordinates$limits$y / 1e308), c(-1, 1))
})

test_that("shared transformed ranges retain extreme bounds with zero comparisons", {
  values <- c(-1e308, -5e307, 5e307, 1e308, 1:4)
  scale <- ggplot2::scale_y_reverse()
  result <- .con_shared_range(values, NULL, 0L, FALSE)(scale)
  expect_equal(result$data / 1e308, c(-1, 1))
  expect_equal(result$limits / 1e308, c(-1, 1))
})

test_that("stacked bar comparisons reuse existing feature frames", {
  skip_if_not_installed("ggpubr")
  d <- con_data()
  fn <- .plt_con_stacked
  env <- new.env(parent = environment(fn))
  splits <- 0L
  env$split <- function(x, f, ...) {
    if (is.data.frame(x) && "feature" %in% names(x)) {
      splits <<- splits + 1L
      if (splits > 1L) stop("split the feature frame again")
    }
    base::split(x, f, ...)
  }
  environment(fn) <- env
  testthat::local_mocked_bindings(.plt_con_stacked = fn, .package = "UtilsR")
  p <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, comparisons = list(c("A", "B")))
  layers <- ggplot2::ggplot_build(p)$data
  expect_identical(splits, 1L)
  expect_true(any(vapply(layers, function(x) "annotation" %in% names(x), logical(1))))
})
