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
