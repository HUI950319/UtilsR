test_that("expansion preserves continuous scale controls and transformed data", {
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_log10(name = "Dose", limits = c(1, 100),
      breaks = c(1, 10, 100), labels = c("Low", "Mid", "High"),
      position = "top", sec.axis = ggplot2::dup_axis(name = "Secondary dose"))
  original <- p$scales$get_scales("x")
  q <- suppressMessages(fmt_expand(p, mult = 0.1, axis = "x"))
  built <- ggplot2::ggplot_build(q)
  expect_equal(built$data[[1]]$x, c(0, 1, 2))
  expect_equal(built$layout$panel_params[[1]]$x.range, c(-0.2, 2.2))
  expect_identical(built$layout$panel_params[[1]]$x$get_labels(),
                   c("Low", "Mid", "High"))
  scale <- q$scales$get_scales("x")
  expect_identical(scale$name, "Dose")
  expect_identical(scale$position, "top")
  expect_identical(scale$secondary.axis$name, "Secondary dose")
  expect_s3_class(original$expand, "waiver")
  expect_identical(original$trans$name, "log-10")
  expect_null(p$scales$get_scales("y"))
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(p)$data)
})

test_that("expansion preserves discrete ordering and unused levels", {
  p <- ggplot2::ggplot(data.frame(x = factor(c("a", "b", "c")), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_discrete(limits = c("c", "b", "a", "d"),
      breaks = c("c", "a"), labels = c("C label", "A label"), drop = FALSE)
  q <- suppressMessages(fmt_expand(p, add = c(0.5, 0), axis = "x"))
  built <- ggplot2::ggplot_build(q)
  expect_equal(as.numeric(built$data[[1]]$x), c(3, 2, 1))
  expect_equal(built$layout$panel_params[[1]]$x.range, c(0.5, 4))
  expect_identical(built$layout$panel_params[[1]]$x$get_labels(),
                   c("C label", "A label"))
  expect_false(q$scales$get_scales("x")$drop)
  expect_s3_class(p$scales$get_scales("x")$expand, "waiver")
})

test_that("expansion preserves binned position scales", {
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_binned(breaks = c(1, 10, 100))
  q <- suppressMessages(fmt_expand(p, mult = 0.1, axis = "x"))
  expect_s3_class(q$scales$get_scales("x"), "ScaleBinnedPosition")
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(p)$data)
})

test_that("expansion defaults and named list returns remain unchanged", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  result <- fmt_expand(list(first = p, second = p))
  expect_named(result, c("first", "second"))
  for (q in result) {
    for (axis in c("x", "y")) {
      expect_equal(q$scales$get_scales(axis)$expand, c(0, 0, 0, 0))
    }
  }
})

test_that("implicit temporal axes retain their scale types and time resolution", {
  cases <- list(
    list(x = as.Date("2026-10-13") + 0:2, transform = "date"),
    list(x = as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200),
         transform = "time"),
    list(x = structure(c(0, 3600, 7200), class = c("hms", "difftime"), units = "secs"),
         transform = "hms")
  )
  for (case in cases) {
    p <- ggplot2::ggplot(data.frame(x = case$x, y = 1:3),
                         ggplot2::aes(x, y)) + ggplot2::geom_point()
    q <- fmt_expand(p, mult = 0.05, axis = "x")
    expect_identical(q$scales$get_scales("x")$trans$name, case$transform)
    expect_equal(ggplot2::ggplot_build(q)$data[[1]]$x, as.numeric(case$x))
  }
})

test_that("additive temporal expansion uses days for dates and seconds for times", {
  cases <- list(
    list(x = as.Date("2026-10-13") + 0:2, add = 2),
    list(x = as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200),
         add = 3600)
  )
  for (case in cases) {
    p <- ggplot2::ggplot(data.frame(x = case$x, y = 1:3),
                         ggplot2::aes(x, y)) + ggplot2::geom_point()
    q <- fmt_expand(p, add = c(case$add, 0), axis = "x")
    expect_equal(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x.range,
                 c(min(as.numeric(case$x)) - case$add, max(as.numeric(case$x))))
  }
})

test_that("shared scale detection accepts temporal controls in fmt_scale", {
  dates <- as.Date("2026-10-13") + 0:2
  times <- as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200)
  date_plot <- ggplot2::ggplot(data.frame(x = dates, y = 1:3),
                               ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_date()
  time_plot <- ggplot2::ggplot(data.frame(x = times, y = 1:3),
                               ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_datetime()
  q_date <- suppressMessages(fmt_scale(date_plot, x = list(date_labels = "%Y-%m-%d")))
  q_time <- suppressMessages(fmt_scale(time_plot,
    x = list(date_labels = "%H:%M", timezone = "Asia/Shanghai")))
  expect_identical(q_date$scales$get_scales("x")$trans$name, "date")
  expect_identical(q_time$scales$get_scales("x")$trans$name, "time")
  expect_identical(q_time$scales$get_scales("x")$timezone, "Asia/Shanghai")
  expect_equal(ggplot2::ggplot_build(q_time)$data[[1]]$x, as.numeric(times))
})

test_that("expansion resolves layer data, inherited mappings and layer overrides", {
  dat <- data.frame(category = factor(c("a", "b", "c")), value = 1:3)
  plots <- list(
    ggplot2::ggplot() + ggplot2::geom_col(data = dat, ggplot2::aes(category, value)),
    ggplot2::ggplot(mapping = ggplot2::aes(category, value)) +
      ggplot2::geom_col(data = dat),
    ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
      ggplot2::geom_col(data = dat, ggplot2::aes(category, value), inherit.aes = FALSE),
    ggplot2::ggplot() + ggplot2::geom_col(data = dat,
      ggplot2::aes(.data[["category"]], .data[["value"]]))
  )
  for (p in plots) {
    q <- fmt_expand(p, add = 0.5, axis = "x")
    expect_s3_class(q$scales$get_scales("x"), "ScaleDiscretePosition")
    expect_identical(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x$get_labels(),
                     c("a", "b", "c"))
  }
})

test_that("expansion evaluates mappings in their captured environments", {
  make_plot <- function() {
    category <- factor(c("a", "b", "c"))
    ggplot2::ggplot(data.frame(value = 1:3), ggplot2::aes(category, value)) +
      ggplot2::geom_point()
  }
  q <- fmt_expand(make_plot(), axis = "x")
  expect_s3_class(q$scales$get_scales("x"), "ScaleDiscretePosition")
  expect_equal(as.numeric(ggplot2::ggplot_build(q)$data[[1]]$x), 1:3)
})

test_that("layer inference also applies to temporal and y axes and fmt_scale", {
  times <- as.POSIXct("2026-10-13 08:00:00", tz = "UTC") + c(0, 3600, 7200)
  p <- ggplot2::ggplot() + ggplot2::geom_point(
    data = data.frame(time = times, category = factor(c("a", "b", "c"))),
    ggplot2::aes(time, category))
  q <- fmt_expand(p)
  expect_equal(ggplot2::ggplot_build(q)$data[[1]]$x, as.numeric(times))
  expect_s3_class(q$scales$get_scales("y"), "ScaleDiscretePosition")
  q_scale <- fmt_scale(p, y = list(labels = c("A", "B", "C")))
  expect_identical(ggplot2::ggplot_build(q_scale)$layout$panel_params[[1]]$y$get_labels(),
                   c("A", "B", "C"))
})

test_that("expansion visits every nested patchwork leaf and retains its layout", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- ((p | p) / p) + patchwork::plot_annotation(title = "KEEP", tag_levels = "A")
  q <- fmt_expand(pw, mult = 0.1)
  leaves <- .to_plot_list(q, recurse = TRUE)$plots
  expect_length(leaves, 3L)
  for (leaf in leaves) {
    panel <- ggplot2::ggplot_build(leaf)$layout$panel_params[[1]]
    expect_equal(panel$x.range, c(0.8, 3.2))
    expect_equal(panel$y.range, c(0.8, 3.2))
  }
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  expect_length(p$scales$scales, 0L)
})

test_that("recursive expansion retains named containers and special patchwork entries", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  inset <- p + patchwork::inset_element(p, 0.6, 0.6, 1, 1)
  fixed <- patchwork::wrap_elements(full = grid::textGrob("FIXED"))
  pw <- patchwork::free((p | patchwork::plot_spacer()) / (inset | fixed), side = "l") +
    patchwork::plot_annotation(title = "KEEP", caption = "CAPTION")
  result <- fmt_expand(list(plain = p, nested = pw), add = 1, axis = "x")
  expect_named(result, c("plain", "nested"))
  q <- result$nested
  leaves <- .to_plot_list(q, recurse = TRUE)$plots
  expect_length(leaves, 2L)
  for (leaf in leaves) {
    expect_equal(ggplot2::ggplot_build(leaf)$layout$panel_params[[1]]$x.range, c(0, 4))
    expect_null(leaf$scales$get_scales("y"))
  }
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  expect_identical(attr(q, "patchwork_free_settings"), attr(pw, "patchwork_free_settings"))
  labels <- function(g) {
    own <- if (inherits(g, "text")) as.character(g$label) else character()
    children <- if (inherits(g, "gtable")) g$grobs else g$children
    c(own, unlist(lapply(children, labels), use.names = FALSE))
  }
  expect_true(all(c("KEEP", "CAPTION", "FIXED") %in% labels(patchwork::patchworkGrob(q))))
})

test_that("expansion rejects malformed axis choices with a parameter error", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (axis in list(character(), c("x", "y"), list("x"), factor("x"),
                   NA_character_, TRUE, 1, "z")) {
    expect_error(fmt_expand(p, axis = axis), "axis", class = "rlang_error")
  }
})

test_that("expansion rejects non-finite padding values", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (parameter in c("mult", "add")) {
    for (value in list(NA_real_, NaN, Inf, -Inf)) {
      args <- list(plot = p, axis = "x")
      args[[parameter]] <- value
      expect_error(do.call(fmt_expand, args), "finite", class = "rlang_error")
    }
  }
})

test_that("valid asymmetric and negative padding retains ggplot2 behavior", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  q <- fmt_expand(p, mult = c(0, 0.1), add = c(2, 3), axis = "x")
  expect_equal(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x.range, c(-1, 6.2))
  expect_null(q$scales$get_scales("y"))
  trimmed <- fmt_expand(p, mult = -0.1, axis = "x")
  expect_equal(ggplot2::ggplot_build(trimmed)$layout$panel_params[[1]]$x.range, c(1.2, 2.8))
})
