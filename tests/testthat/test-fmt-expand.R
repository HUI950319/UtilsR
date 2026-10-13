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

test_that("scale inference reports invalid ordinary mappings before construction", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(missing_column, y)) + ggplot2::geom_point()
  expect_error(fmt_expand(p, axis = "x"), "Cannot infer the x-axis", class = "rlang_error")
  expect_error(fmt_scale(p, x = list(expand = c(0, 0))),
               "Cannot infer the x-axis", class = "rlang_error")
})

test_that("scale inference retains the cause of mapping evaluation errors", {
  failed_mapping <- function(x) stop("source mapping failed")
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(failed_mapping(x), y)) + ggplot2::geom_point()
  q <- fmt_expand(p, axis = "x")
  error <- tryCatch(ggplot2::ggplot_build(q), error = identity)
  expect_s3_class(error, "rlang_error")
  expect_match(conditionMessage(error), "source mapping failed")
})

test_that("computed statistic mappings retain their continuous defaults", {
  p <- ggplot2::ggplot(data.frame(x = 1:4),
                       ggplot2::aes(x, y = ggplot2::after_stat(count))) +
    ggplot2::geom_histogram(binwidth = 1)
  q <- fmt_expand(p, mult = 0.1)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(p)$data)
})

test_that("repeated unchanged expansion does not retain scale clone histories", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  q <- fmt_expand(p, mult = 0.05)
  invisible(q$scales$get_scales("x"))
  invisible(q$scales$get_scales("y"))
  original_size <- length(serialize(q$scales, NULL))
  repeated <- q
  for (i in 1:25) repeated <- fmt_expand(repeated, mult = 0.05)
  expect_lte(length(serialize(repeated$scales, NULL)), original_size)
  expect_identical(ggplot2::ggplot_build(repeated)$data,
                   ggplot2::ggplot_build(q)$data)
})

test_that("changing expansion remains isolated from earlier plot results", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  first <- fmt_expand(p, mult = 0.1)
  second <- fmt_expand(first, mult = 0.2, axis = "x")
  expect_equal(ggplot2::ggplot_build(first)$layout$panel_params[[1]]$x.range, c(0.8, 3.2))
  expect_equal(ggplot2::ggplot_build(second)$layout$panel_params[[1]]$x.range, c(0.6, 3.4))
  expect_equal(ggplot2::ggplot_build(second)$layout$panel_params[[1]]$y.range, c(0.8, 3.2))
})

test_that("scale inference does not run layer statistics eagerly", {
  calls <- 0L
  stat <- ggplot2::ggproto("StatExpandCounter", ggplot2::Stat,
    required_aes = c("x", "y"),
    compute_group = function(data, scales) {
      calls <<- calls + 1L
      data
    })
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(stat = stat)
  q <- fmt_expand(p)
  expect_identical(calls, 0L)
  invisible(ggplot2::ggplot_build(q))
  expect_identical(calls, 1L)
})

test_that("statistic mappings ignore same-named columns in source data", {
  for (count in list(c("unused", "unused", "unused"),
                     as.Date("2026-01-01") + 0:2)) {
    dat <- data.frame(x = factor(c("a", "b", "a")), count = count)
    p <- ggplot2::ggplot(dat, ggplot2::aes(x, y = ggplot2::after_stat(count))) +
      ggplot2::geom_bar()
    native <- ggplot2::ggplot_build(p)
    built <- ggplot2::ggplot_build(fmt_expand(p, mult = 0.05, axis = "y"))
    expect_identical(class(built$plot$scales$get_scales("y")),
                     class(native$plot$scales$get_scales("y")))
    expect_identical(built$layout$panel_params[[1]]$y$get_labels(),
                     native$layout$panel_params[[1]]$y$get_labels())
    expect_identical(built$data, native$data)
    q <- fmt_scale(p, y = list(breaks = c(0, 1, 2)))
    expect_s3_class(q$scales$get_scales("y"), "ScaleContinuousPosition")
  }
})

test_that("legacy statistic mappings retain native count scales", {
  dat <- data.frame(x = factor(c("a", "b", "a")))
  mappings <- list(ggplot2::aes(x, y = ..count..),
                   ggplot2::aes(x, y = stat(count)))
  for (mapping in mappings) {
    p <- ggplot2::ggplot(dat, mapping) + ggplot2::geom_bar()
    native <- suppressWarnings(ggplot2::ggplot_build(p))
    built <- suppressWarnings(ggplot2::ggplot_build(
      fmt_expand(p, mult = 0.05, axis = "y")))
    expect_identical(built$data, native$data)
    expect_identical(built$layout$panel_params[[1]]$y$get_labels(),
                     native$layout$panel_params[[1]]$y$get_labels())
  }
})

test_that("stage start mappings and ordinary stage-named errors stay distinct", {
  dat <- data.frame(category = factor(c("a", "b", "c")), value = 1:3)
  p <- ggplot2::ggplot(dat, ggplot2::aes(
    x = ggplot2::stage(start = category, after_scale = x), y = value)) +
    ggplot2::geom_point()
  built <- ggplot2::ggplot_build(fmt_expand(p, axis = "x"))
  expect_identical(built$data, ggplot2::ggplot_build(p)$data)
  invalid <- ggplot2::ggplot(dat, ggplot2::aes(factor(stage), value)) +
    ggplot2::geom_point()
  expect_error(ggplot2::ggplot_build(fmt_expand(invalid, axis = "x")))
  expect_error(fmt_scale(invalid, x = list(expand = c(0, 0))), "Cannot infer the x-axis")
})

test_that("function and formula layer data retain native position scale types", {
  dat <- data.frame(category = factor(c("a", "b", "c")), value = 1:3)
  for (layer_data in list(function(d) head(d, 2), ~ head(.x, 2))) {
    p <- ggplot2::ggplot(dat, ggplot2::aes(category, value)) +
      ggplot2::geom_point(data = layer_data)
    q <- fmt_expand(p, mult = 0.1)
    built <- ggplot2::ggplot_build(q)
    expect_s3_class(built$plot$scales$get_scales("x"), "ScaleDiscretePosition")
    expect_identical(built$data, ggplot2::ggplot_build(p)$data)
    expect_equal(built$plot$scales$get_scales("x")$expand,
                 ggplot2::expansion(mult = 0.1))
  }
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(d) {
      d$x <- as.Date("2026-01-01") + d$x
      d
    })
  built <- ggplot2::ggplot_build(fmt_expand(p, add = 1, axis = "x"))
  expect_s3_class(built$plot$scales$get_scales("x"), "ScaleContinuousDate")
  expect_identical(built$data, ggplot2::ggplot_build(p)$data)
  expect_equal(built$layout$panel_params[[1]]$x.range, c(20454, 20458))
})

test_that("formatting does not execute or replace function layer data", {
  calls <- 0L
  layer_data <- function(d) {
    calls <<- calls + 1L
    head(d, 2)
  }
  p <- ggplot2::ggplot(data.frame(x = factor(c("a", "b", "c")), y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point(data = layer_data)
  q <- fmt_expand(p, mult = 0.1)
  expect_identical(calls, 0L)
  expect_identical(q$layers[[1]]$data, p$layers[[1]]$data)
  invisible(ggplot2::ggplot_build(q))
  expect_identical(calls, 1L)
  expect_null(p$scales$get_scales("x"))
  later <- q + ggplot2::scale_x_discrete(expand = ggplot2::expansion(add = 2))
  expect_equal(ggplot2::ggplot_build(later)$plot$scales$get_scales("x")$expand,
               ggplot2::expansion(add = 2))
})

test_that("function data padding also applies to native fallback axes", {
  p <- ggplot2::ggplot(data.frame(x = 1:3)) +
    ggplot2::geom_vline(data = function(d) d, ggplot2::aes(xintercept = x))
  built <- ggplot2::ggplot_build(fmt_expand(p, mult = 0.1))
  for (axis in c("x", "y")) {
    expect_equal(built$plot$scales$get_scales(axis)$expand,
                 ggplot2::expansion(mult = 0.1))
  }
})

test_that("empty position mappings do not determine later layer scales", {
  dat <- data.frame(category = factor(c("a", "b", "c")), value = 1:3)
  for (empty_x in list(numeric(), as.Date(character()),
                       as.POSIXct(character(), tz = "UTC"))) {
    empty <- data.frame(x = empty_x, y = numeric())
    p <- ggplot2::ggplot(dat, ggplot2::aes(category, value)) +
      ggplot2::geom_point(data = empty, ggplot2::aes(x, y), inherit.aes = FALSE) +
      ggplot2::geom_point()
    built <- ggplot2::ggplot_build(fmt_expand(p, axis = "x"))
    expect_s3_class(built$plot$scales$get_scales("x"), "ScaleDiscretePosition")
    expect_identical(built$data, ggplot2::ggplot_build(p)$data)
    q_scale <- fmt_scale(p, x = list(labels = toupper))
    expect_identical(as.character(ggplot2::ggplot_build(q_scale)$layout$panel_params[[1]]$x$get_labels()),
                     c("A", "B", "C"))
  }
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = data.frame(x = as.Date(character()), y = numeric())) +
    ggplot2::geom_point()
  built <- ggplot2::ggplot_build(fmt_expand(p, axis = "x"))
  expect_identical(built$plot$scales$get_scales("x")$trans$name, "identity")
  expect_identical(built$data, ggplot2::ggplot_build(p)$data)
})

test_that("changing padding repeatedly keeps scale storage bounded", {
  dat <- data.frame(x = c(1, 10, 100), y = 1:3, group = factor(c("a", "b", "c")))
  p <- ggplot2::ggplot(dat, ggplot2::aes(x, y, colour = group)) + ggplot2::geom_point()
  plots <- list(
    p + ggplot2::scale_x_log10() + ggplot2::scale_y_continuous() +
      ggplot2::scale_colour_discrete(),
    p + ggplot2::aes(x = group) + ggplot2::scale_x_discrete(drop = FALSE) +
      ggplot2::scale_y_continuous(),
    p + ggplot2::scale_x_binned(breaks = c(1, 10, 100)) + ggplot2::scale_y_continuous(),
    p + ggplot2::geom_point(data = function(d) d)
  )
  for (plot in plots) {
    first <- fmt_expand(plot, mult = 0.05)
    repeated <- fmt_expand(first, mult = 0.1)
    initial_size <- length(serialize(repeated$scales, NULL))
    for (i in 1:24) repeated <- fmt_expand(repeated, mult = if (i %% 2L) 0.05 else 0.1)
    expect_lte(length(serialize(repeated$scales, NULL)), initial_size + 8192)
    built <- ggplot2::ggplot_build(repeated)
    fresh <- ggplot2::ggplot_build(fmt_expand(plot, mult = 0.1))
    expect_identical(built$data, fresh$data)
    expect_equal(built$layout$panel_params[[1]]$x.range,
                 fresh$layout$panel_params[[1]]$x.range)
    expect_equal(built$layout$panel_params[[1]]$y.range,
                 fresh$layout$panel_params[[1]]$y.range)
    original_scale <- first$scales$get_scales("x")
    original_expand <- if (is.null(original_scale)) first$scales$.fmt_expand$x
      else original_scale$expand
    expect_equal(original_expand,
                 ggplot2::expansion(mult = 0.05))
  }
})

test_that("scale cloning retains custom fields, classes and clone behavior", {
  scale <- ggplot2::ggproto("ScaleExpandTracked", ggplot2::scale_x_log10(),
    clone_count = 0L, custom_setting = list(label = "retained"),
    .hidden_setting = "retained",
    clone = function(self) {
      result <- ggplot2::ggproto_parent(ggplot2::ScaleContinuous, self)$clone()
      result$clone_count <- self$clone_count + 1L
      result
    })
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + scale
  q <- fmt_expand(p, mult = 0.1, axis = "x")
  expect_s3_class(q$scales$get_scales("x"), "ScaleExpandTracked")
  expect_identical(q$scales$get_scales("x")$custom_setting, list(label = "retained"))
  expect_identical(q$scales$get_scales("x")$.hidden_setting, "retained")
  expect_identical(q$scales$get_scales("x")$clone_count, 1L)
  expect_identical(p$scales$get_scales("x")$clone_count, 0L)
  expect_identical(ggplot2::ggplot_build(q)$data, ggplot2::ggplot_build(p)$data)
})

test_that("formatting defers mapping calls to normal plot building", {
  calls <- 0L
  counted <- function(x) {
    calls <<- calls + 1L
    factor(x)
  }
  p <- ggplot2::ggplot(data.frame(x = c("a", "b", "c"), y = 1:3),
                       ggplot2::aes(counted(x), y)) + ggplot2::geom_point()
  q <- fmt_expand(p, mult = 0.1)
  expect_identical(calls, 0L)
  for (i in 1:10) q <- fmt_expand(q, mult = 0.1)
  expect_identical(calls, 0L)
  built <- ggplot2::ggplot_build(q)
  expect_identical(calls, 1L)
  expect_s3_class(built$plot$scales$get_scales("x"), "ScaleDiscretePosition")
  expect_equal(built$plot$scales$get_scales("x")$expand,
               ggplot2::expansion(mult = 0.1))
})

test_that("formatting preserves random mappings and the random number state", {
  p <- ggplot2::ggplot(data.frame(y = 1:5),
                       ggplot2::aes(x = rnorm(length(y)), y = y)) +
    ggplot2::geom_point()
  set.seed(407)
  native <- ggplot2::ggplot_build(p)
  set.seed(407)
  seed <- .Random.seed
  q <- fmt_expand(p, mult = 0.1)
  expect_identical(.Random.seed, seed)
  expect_identical(ggplot2::ggplot_build(q)$data, native$data)
})

test_that("computed categorical mappings retain native discrete scales", {
  p <- ggplot2::ggplot(data.frame(x = factor(c("A", "B", "A"))),
                       ggplot2::aes(x, y = ggplot2::after_stat(factor(count)))) +
    ggplot2::geom_point(stat = "count")
  native <- ggplot2::ggplot_build(p)
  q <- fmt_expand(p, mult = 0.1, axis = "y")
  built <- ggplot2::ggplot_build(q)
  expect_s3_class(built$plot$scales$get_scales("y"), "ScaleDiscretePosition")
  expect_identical(built$data, native$data)
  expect_equal(built$plot$scales$get_scales("y")$expand,
               ggplot2::expansion(mult = 0.1))
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
  expect_null(p$scales$get_scales("y"))
})

test_that("statistic default mappings retain native position scales", {
  calls <- 0L
  stat <- ggplot2::ggproto("StatExpandCategories", ggplot2::Stat,
    required_aes = "label",
    default_aes = ggplot2::aes(x = ggplot2::after_stat(category),
                               y = ggplot2::after_stat(value)),
    compute_group = function(data, scales) {
      calls <<- calls + 1L
      data.frame(category = factor(c("a", "b")), value = c(1, 2),
                 label = data$label)
    })
  p <- ggplot2::ggplot(data.frame(label = 1:2), ggplot2::aes(label = label)) +
    ggplot2::geom_point(stat = stat)
  native <- ggplot2::ggplot_build(p)
  calls <- 0L
  q <- fmt_expand(p, mult = 0.1)
  expect_identical(calls, 0L)
  built <- ggplot2::ggplot_build(q)
  expect_identical(calls, 1L)
  expect_s3_class(built$plot$scales$get_scales("x"), "ScaleDiscretePosition")
  expect_identical(built$data, native$data)
  for (axis in c("x", "y")) {
    expect_equal(built$plot$scales$get_scales(axis)$expand,
                 ggplot2::expansion(mult = 0.1))
    expect_null(p$scales$get_scales(axis))
  }
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
})

test_that("implicit extension scales retain native scale_type dispatch", {
  methods <- get(".__S3MethodsTable__.", envir = asNamespace("ggplot2"))
  method_name <- "scale_type.fmt_expand_binned"
  type_calls <- 0L
  registerS3method("scale_type", "fmt_expand_binned", function(x) {
    type_calls <<- type_calls + 1L
    "binned"
  }, envir = asNamespace("ggplot2"))
  tryCatch({
    dat <- data.frame(y = 1:4)
    dat$x <- structure(c(1.2, 1.8, 2.7, 3.4),
                       class = c("fmt_expand_binned", "numeric"))
    p <- ggplot2::ggplot(dat, ggplot2::aes(x, y)) + ggplot2::geom_point()
    native <- ggplot2::ggplot_build(p)
    type_calls <- 0L
    q <- fmt_expand(p, mult = 0.1, axis = "x")
    expect_identical(type_calls, 0L)
    built <- ggplot2::ggplot_build(q)
    expect_s3_class(built$plot$scales$get_scales("x"), "ScaleBinnedPosition")
    expect_identical(built$data, native$data)
    expect_equal(built$plot$scales$get_scales("x")$expand,
                 ggplot2::expansion(mult = 0.1))
  }, finally = rm(list = method_name, envir = methods))
})
