x_params <- function(p) ggplot2::ggplot_build(p)$layout$panel_params[[1]]$x

test_that("fmt_scale() updates supplied fields and keeps the rest of an existing scale", {
  d <- data.frame(x = c(0, 50, 100), y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(limits = c(0, 120), breaks = seq(0, 120, 30),
                                sec.axis = ggplot2::dup_axis())
  out <- fmt_scale(p, x = list(labels = function(x) paste0(x, "d")))

  sc <- out$scales$get_scales("x")
  expect_identical(sc$breaks, seq(0, 120, 30))
  expect_identical(sc$limits, c(0, 120))
  expect_s3_class(sc$secondary.axis, "AxisSecondary")
  expect_identical(x_params(out)$get_labels(), paste0(seq(0, 120, 30), "d"))
  # The input plot is not modified by reference
  expect_identical(x_params(p)$get_labels(), as.character(seq(0, 120, 30)))
})

test_that("fmt_scale() keeps the existing transformation and re-expresses limits", {
  d <- data.frame(x = c(1, 25, 100), y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::scale_x_continuous(transform = "sqrt", breaks = c(1, 25, 100))
  out <- fmt_scale(p, x = list(limits = c(0, 100)))
  sc <- out$scales$get_scales("x")
  expect_identical(sc$trans$name, "sqrt")
  expect_equal(sc$limits, c(0, 10))
  expect_identical(sc$breaks, c(1, 25, 100))

  lim <- suppressMessages(
    p + ggplot2::scale_x_continuous(transform = "sqrt", limits = c(1, 100))
  )
  logged <- fmt_scale(lim, x = list(transform = "log10"))$scales$get_scales("x")
  expect_identical(logged$trans$name, "log-10")
  expect_equal(logged$limits, c(0, 2))
})

test_that("fmt_scale() keeps temporal and discrete scale settings", {
  dates <- as.Date("2026-01-01") + c(0, 40, 80)
  lims <- as.Date(c("2025-12-01", "2026-04-01"))
  pd <- ggplot2::ggplot(data.frame(x = dates, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::scale_x_date(limits = lims)
  od <- fmt_scale(pd, x = list(date_breaks = "1 month", date_labels = "%b"))
  expect_equal(od$scales$get_scales("x")$limits, as.numeric(lims))
  date_labels <- x_params(od)$get_labels()
  expect_identical(date_labels[!is.na(date_labels)][1:2],
                   format(as.Date(c("2025-12-01", "2026-01-01")), "%b"))

  pc <- ggplot2::ggplot(data.frame(x = c("a", "b", "c"), y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::scale_x_discrete(limits = c("c", "b", "a"))
  oc <- fmt_scale(pc, x = list(labels = toupper))
  expect_identical(oc$scales$get_scales("x")$limits, c("c", "b", "a"))
  expect_identical(as.character(x_params(oc)$get_labels()), c("C", "B", "A"))
})

test_that("fmt_scale() still adds a scale when none exists", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  out <- fmt_scale(p, y = list(breaks = 1:3))
  expect_s3_class(out$scales$get_scales("y"), "ScaleContinuousPosition")
  expect_identical(out$scales$get_scales("y")$breaks, 1:3)
})

test_that("changing transformation preserves observations across reversed limits", {
  d <- data.frame(x = c(1, 10, 100), y = 1:3)
  base <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  cases <- list(
    list(from = "identity", to = "reverse", x = c(-1, -10, -100)),
    list(from = "reverse", to = "identity", x = c(1, 10, 100)),
    list(from = "sqrt", to = "reverse", x = c(-1, -10, -100))
  )
  for (case in cases) {
    p <- base + ggplot2::scale_x_continuous(transform = case$from,
                                          limits = c(1, 100))
    original <- p$scales$get_scales("x")$limits
    q <- fmt_scale(p, x = list(transform = case$to))
    expect_equal(ggplot2::ggplot_build(q)$data[[1]]$x, case$x)
    expect_identical(p$scales$get_scales("x")$limits, original)
  }
  explicit <- fmt_scale(base, x = list(transform = "reverse", limits = c(1, 100)))
  expect_equal(ggplot2::ggplot_build(explicit)$data[[1]]$x, c(-1, -10, -100))
})

test_that("axis settings reach every nested patchwork leaf without changing layout", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  nested <- (p | p) / (p | p) + patchwork::plot_annotation(title = "Four panels")
  q <- fmt_scale(nested, x = list(breaks = c(1, 3)), y = list(labels = toupper))
  leaves <- .to_plot_list(q, recurse = TRUE)$plots
  expect_length(leaves, 4L)
  for (leaf in leaves) {
    expect_identical(ggplot2::ggplot_build(leaf)$layout$panel_params[[1]]$x$get_breaks(),
                     c(1, 3))
  }
  expect_identical(q$patches$layout, nested$patches$layout)
  expect_identical(q$patches$annotation, nested$patches$annotation)
  expect_null(p$scales$get_scales("x"))
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
})

test_that("function and formula layer data keep categorical axis settings", {
  d <- data.frame(x = factor(c("a", "b", "c")), y = 1:3)
  for (layer_data in list(function(d) d, ~ .x)) {
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point(data = layer_data)
    q <- fmt_scale(p, x = list(labels = toupper))
    built <- ggplot2::ggplot_build(q)
    expect_identical(as.character(built$layout$panel_params[[1]]$x$get_labels()),
                     c("A", "B", "C"))
    expect_equal(as.numeric(built$data[[1]]$x), 1:3)
    expect_null(p$scales$get_scales("x"))
  }
})

test_that("temporal settings use function output without extra data calls", {
  calls <- 0L
  layer_data <- function(d) {
    calls <<- calls + 1L
    d$x <- as.Date("2026-01-01") + d$x
    d
  }
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = layer_data)
  q <- fmt_scale(p, x = list(date_breaks = "1 day", date_labels = "%m-%d"))
  expect_identical(calls, 0L)
  built <- ggplot2::ggplot_build(q)
  expect_identical(calls, 1L)
  expect_s3_class(built$plot$scales$get_scales("x"), "ScaleContinuousDate")
  labels <- built$layout$panel_params[[1]]$x$get_labels()
  expect_identical(labels[!is.na(labels)], c("01-02", "01-03", "01-04"))
})

test_that("axis arguments require valid named lists before scale selection", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  invalid <- list(c(breaks = 1), list(1:3),
                  structure(list(1:3), names = NA_character_),
                  structure(list(1:3, 1:3), names = c("breaks", "breaks")))
  for (plot in list(p, p + ggplot2::scale_x_continuous())) {
    for (args in invalid) expect_error(fmt_scale(plot, x = args), "list|names")
    expect_error(fmt_scale(plot, y = c(breaks = 1)), "list")
    expect_error(fmt_scale(plot, x = list(brek = 1:3)), "Unknown|ambiguous")
    expect_error(fmt_scale(plot, x = list(lim = c(1, 2), limits = c(1, 3))), "unique")
  }
})

test_that("partial argument names update new and existing scales consistently", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (plot in list(p, p + ggplot2::scale_x_continuous(limits = c(1, 3)))) {
    q <- fmt_scale(plot, x = list(lim = c(1, 2), breaks = 1:2,
                                 lab = function(x) paste0("N", x)))
    expect_equal(q$scales$get_scales("x")$limits, c(1, 2))
    expect_identical(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x$get_labels(),
                     c("N1", "N2"))
  }
})

test_that("invalid temporal settings retain their original error without a type fallback", {
  p <- ggplot2::ggplot(data.frame(x = as.Date("2026-01-01") + 0:2, y = 1:3),
                       ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_error(fmt_scale(p, x = list(transform = "sqrt")), "x-axis")
  error <- tryCatch(fmt_scale(p, x = list(limits = c(0, 1))), error = identity)
  expect_s3_class(error, "error")
  if (inherits(error, "error")) {
    expect_match(conditionMessage(error), "x-axis")
    expect_s3_class(error$parent, "error")
    expect_match(conditionMessage(error$parent), "Date")
  }
  expect_null(p$scales$get_scales("x"))
})

test_that("binned position scales accept bin controls and retain transformations", {
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  scale_args <- list(name = "Dose", breaks = c(1, 10, 100), limits = c(1, 100),
                     transform = "log10", right = TRUE)
  original <- p + do.call(ggplot2::scale_x_binned, scale_args)
  q <- fmt_scale(original, x = list(right = FALSE, nice.breaks = FALSE, show.limits = TRUE))
  scale <- q$scales$get_scales("x")
  expect_s3_class(scale, "ScaleBinnedPosition")
  expect_identical(scale$trans$name, "log-10")
  expect_identical(scale$name, "Dose")
  expect_false(scale$right)
  expected <- p + do.call(ggplot2::scale_x_binned,
    utils::modifyList(scale_args, list(right = FALSE, nice.breaks = FALSE, show.limits = TRUE)))
  expect_equal(ggplot2::ggplot_build(q)$data, ggplot2::ggplot_build(expected)$data)
  trimmed <- fmt_scale(original, x = list(limits = c(1, 10)))
  expect_equal(trimmed$scales$get_scales("x")$limits, c(0, 1))
  expect_true(original$scales$get_scales("x")$right)
})

test_that("unchanged settings reuse scales and changed axes clone only once", {
  calls <- 0L
  scale <- ggplot2::ggproto("ScaleFmtTracked", ggplot2::scale_x_log10(breaks = c(1, 100)),
    custom_setting = "retained", clone = function(self) {
      calls <<- calls + 1L
      ggplot2::ggproto_parent(ggplot2::ScaleContinuous, self)$clone()
    })
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + scale + ggplot2::scale_y_continuous(breaks = 1:3)
  same <- fmt_scale(p, x = list(breaks = c(1, 100)), y = list(breaks = 1:3))
  expect_true(identical(same$scales, p$scales))
  calls <- 0L
  changed <- fmt_scale(p, x = list(breaks = c(1, 10, 100)), y = list(breaks = c(1, 3)))
  expect_identical(calls, 1L)
  expect_s3_class(changed$scales$get_scales("x"), "ScaleFmtTracked")
  expect_identical(changed$scales$get_scales("x")$custom_setting, "retained")
  expect_identical(p$scales$get_scales("y")$breaks, 1:3)
})

test_that("repeated scale changes keep storage bounded and retain earlier results", {
  p <- ggplot2::ggplot(data.frame(x = c(1, 10, 100), y = 1:3, g = factor(letters[1:3])),
                       ggplot2::aes(x, y, colour = g)) + ggplot2::geom_point()
  plots <- list(
    p + ggplot2::scale_x_log10() + ggplot2::scale_y_continuous(),
    p + ggplot2::aes(x = g) + ggplot2::scale_x_discrete(drop = FALSE),
    p + ggplot2::scale_x_binned(breaks = c(1, 10, 100)),
    p + ggplot2::geom_point(data = function(d) d)
  )
  for (plot in plots) {
    first <- fmt_scale(plot, x = list(labels = toupper), y = list(breaks = 1:3))
    initial_size <- length(serialize(first$scales, NULL))
    repeated <- first
    for (i in 1:25) repeated <- fmt_scale(repeated,
      x = list(labels = if (i %% 2L) tolower else toupper), y = list(breaks = c(1, 3)))
    expect_lte(length(serialize(repeated$scales, NULL)), initial_size + 8192)
    built <- ggplot2::ggplot_build(repeated)
    expect_identical(built$layout$panel_params[[1]]$y$get_breaks(), c(1, 3))
    expect_identical(ggplot2::ggplot_build(first)$layout$panel_params[[1]]$y$get_breaks(),
                     as.numeric(1:3))
  }
})

test_that("changing transformation keeps partial limits on the same observations", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 1:5), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  cases <- list(
    list(from = "identity", to = "reverse", limits = c(NA, 4), x = c(-1, -2, -3, -4, NA)),
    list(from = "identity", to = "reverse", limits = c(2, NA), x = c(NA, -2, -3, -4, -5)),
    list(from = "reverse", to = "identity", limits = c(NA, 4), x = c(NA, NA, NA, 4, 5)),
    list(from = "reverse", to = "log10", limits = c(2, NA), x = c(0, log10(2), NA, NA, NA)),
    list(from = "sqrt", to = "reverse", limits = c(NA, 4), x = c(-1, -2, -3, -4, NA))
  )
  for (case in cases) {
    original <- p + ggplot2::scale_x_continuous(transform = case$from,
                                               limits = case$limits)
    limits <- original$scales$get_scales("x")$limits
    q <- fmt_scale(original, x = list(transform = case$to))
    expect_equal(ggplot2::ggplot_build(q)$data[[1]]$x, case$x)
    expect_identical(original$scales$get_scales("x")$limits, limits)
  }
})

test_that("deferred scale and expansion settings compose independently on both axes", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 1:5), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = ~ .x)
  labels <- function(x) paste0("L", x)
  first <- fmt_scale(p, x = list(labels = labels), y = list(breaks = c(1, 3, 5)))
  q <- fmt_expand(first, axis = "x", mult = 0, add = 0)
  q <- fmt_scale(q, x = list(breaks = 1:5))
  built <- ggplot2::ggplot_build(q)
  expect_equal(built$layout$panel_params[[1]]$x.range, c(1, 5))
  expect_identical(built$layout$panel_params[[1]]$x$get_labels(), paste0("L", 1:5))
  expect_identical(built$layout$panel_params[[1]]$y$get_breaks(), c(1, 3, 5))
  expect_equal(ggplot2::ggplot_build(first)$layout$panel_params[[1]]$x.range, c(0.8, 5.2))

  q <- fmt_expand(p, axis = "y", mult = 0.1, add = 0)
  q <- fmt_scale(q, x = list(labels = labels, breaks = 1:5), y = list(breaks = 1:5))
  q <- fmt_expand(q, axis = "x", mult = 0.2, add = 0)
  built <- ggplot2::ggplot_build(q)
  expect_equal(built$layout$panel_params[[1]]$x.range, c(0.2, 5.8))
  expect_equal(built$layout$panel_params[[1]]$y.range, c(0.6, 5.4))
  expect_identical(built$layout$panel_params[[1]]$x$get_labels(), paste0("L", 1:5))
  expect_null(p$scales$get_scales("x"))
  expect_null(p$scales$get_scales("y"))
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
})

test_that("mapping calls run only during native building and preserve random state", {
  calls <- 0L
  draw <- function() {
    calls <<- calls + 1L
    stats::runif(5)
  }
  p <- ggplot2::ggplot(data.frame(y = 1:5), ggplot2::aes(x = draw(), y = y)) +
    ggplot2::geom_point()
  set.seed(420)
  native <- ggplot2::ggplot_build(p)
  set.seed(420)
  calls <- 0L
  seed <- .Random.seed
  q <- fmt_scale(p, x = list(labels = function(x) paste0("L", x)))
  expect_identical(calls, 0L)
  expect_true(identical(.Random.seed, seed))
  built <- ggplot2::ggplot_build(q)
  expect_identical(calls, 1L)
  expect_identical(built$data, native$data)
  expect_null(p$scales$get_scales("x"))
})

test_that("lazy mapping values retain native evaluation order during formatting", {
  make_plot <- function() {
    env <- new.env()
    env$calls <- 0L
    delayedAssign("values", {
      calls <- calls + 1L
      stats::runif(3)
    }, assign.env = env, eval.env = env)
    mapping <- ggplot2::aes(x = stats::rnorm(3), y = values)
    mapping$y <- rlang::new_quosure(quote(values), env)
    list(plot = ggplot2::ggplot(mapping = mapping) + ggplot2::geom_point(), env = env)
  }
  set.seed(421)
  native <- ggplot2::ggplot_build(make_plot()$plot)
  set.seed(421)
  fixture <- make_plot()
  seed <- .Random.seed
  q <- fmt_scale(fixture$plot, x = list(breaks = c(-1, 0, 1)), y = list(labels = scales::label_number()))
  expect_identical(fixture$env$calls, 0L)
  expect_true(rlang::env_binding_are_lazy(fixture$env, "values")[[1L]])
  expect_true(identical(.Random.seed, seed))
  expect_identical(ggplot2::ggplot_build(q)$data, native$data)
  expect_identical(fixture$env$calls, 1L)
})
