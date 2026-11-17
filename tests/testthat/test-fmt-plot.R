plot_fixture <- function() {
  d <- data.frame(x = 1:3, y = c(2, 4, 3))
  ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
}

test_that("fmt_plot() and fmt_plot_base() format each plot of a plain list", {
  p <- plot_fixture()

  res <- fmt_plot(list(a = p, b = p), plot.margin = 4)
  expect_type(res, "list")
  expect_named(res, c("a", "b"))
  for (q in res) {
    expect_s3_class(q, "ggplot")
    expect_equal(as.numeric(q$theme$plot.margin), rep(4, 4))
  }

  res <- fmt_plot_base(list(p, p | p), ggtheme = ggplot2::theme_bw(),
                       labs_list = list(x = "X"))
  expect_length(res, 2L)
  expect_s3_class(res[[2]], "patchwork")
  # get_labs() exists only from ggplot2 4.0; 3.5.0 keeps labels in `$labels`.
  labs_of <- if (exists("get_labs", envir = asNamespace("ggplot2"), inherits = FALSE)) {
    ggplot2::get_labs
  } else {
    function(plot) plot$labels
  }
  expect_identical(labs_of(res[[1]])$x, "X")
  expect_identical(labs_of(res[[2]][[1]])$x, "X")

  expect_error(fmt_plot(list(p, 1), plot.margin = 4), "ggplot")
  expect_error(fmt_plot_base(list(p, 1), labs_list = list(x = "X")), "ggplot")
})

test_that("fmt_plot() rejects arguments it does not have", {
  p <- plot_fixture()
  expect_error(fmt_plot(p, fmt_strip_list = list(label = "A")), "unused argument")
  expect_error(fmt_plot(p, plot_margin = 4), "unused argument")
})

test_that("fmt_plot_base() applies scale settings through fmt_scale()", {
  d <- data.frame(x = 1:3, y = c(2, 4, 3), g = c("a", "b", "c"))
  p_con <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  p_dis <- ggplot2::ggplot(d, ggplot2::aes(g, y)) + ggplot2::geom_col()

  # A discrete axis keeps a discrete scale instead of failing to build.
  res <- fmt_plot_base(p_con | p_dis, scale_x_list = list(expand = c(0, 0)))
  expect_no_error(built <- ggplot2::ggplot_build(res[[2]]))
  expect_s3_class(built$layout$panel_scales_x[[1]], "ScaleDiscrete")

  # An existing scale keeps the settings the list leaves out, without messages.
  p_log <- p_con + ggplot2::scale_y_log10()
  expect_no_message(res <- fmt_plot_base(p_log | p_log, scale_y_list = list(limits = c(1, 10))))
  native <- (p_con + ggplot2::scale_y_log10(limits = c(1, 10)))$scales$get_scales("y")
  for (i in 1:2) {
    sc <- res[[i]]$scales$get_scales("y")
    expect_identical(sc$trans$name, "log-10")
    expect_equal(sc$limits, native$limits)
  }

  res <- fmt_plot_base(list(p_con, p_con), scale_y_list = list(limits = c(0, 5)))
  expect_length(res, 2L)
  expect_equal(res[[2]]$scales$get_scales("y")$limits, c(0, 5))
})

test_that("fmt_plot validates option lists and numeric margins before applying formatters", {
  for (arg in c("fmt_axis_list", "fmt_tag_list", "fmt_legend_list", "fmt_ref_list")) {
    for (bad in list(1, list(TRUE), list(plot = 1), setNames(list(1, 2), c("x", "x")))) {
      args <- list(plot = quote(stop("plot evaluated")))
      args[arg] <- list(bad)
      expect_error(do.call(fmt_plot, args), arg)
    }
  }
  for (bad in list(NA_real_, Inf, matrix(1), structure(1, class = "integer64"))) {
    expect_error(fmt_plot(stop("plot evaluated"), plot.margin = bad), "plot.margin")
  }
})

test_that("fmt_plot_base preflights named option lists before theme factories", {
  for (arg in c("labs_list", "scale_y_list", "scale_x_list")) {
    for (bad in list(1, list("x"), setNames(list(1, 2), c("x", "x")))) {
      args <- list(plot = plot_fixture(), ggtheme = function() stop("theme evaluated"))
      args[arg] <- list(bad)
      expect_error(do.call(fmt_plot_base, args), arg)
    }
  }
  p <- plot_fixture()
  expect_identical(fmt_plot_base(p, labs_list = list()), p)
})

test_that("plot-leaf traversal retains unchanged siblings and edits each data leaf once", {
  p <- plot_fixture()
  pw <- patchwork::wrap_plots(p, p + p, patchwork::plot_spacer()) +
    patchwork::plot_annotation(title = "Container")
  expect_identical(UtilsR:::.map_plot_leaves(pw, identity), pw)
  seen <- 0L
  out <- UtilsR:::.map_plot_leaves(pw, function(p) {
    seen <<- seen + 1L
    if (seen == 2L) p + ggplot2::labs(title = "Edited") else p
  })
  expect_identical(seen, 3L)
  expect_identical(out[[1]], pw[[1]])
  expect_identical(out[[2]][[1]]$labels$title, "Edited")
  expect_identical(out$patches$annotation, pw$patches$annotation)
  expect_identical(out$patches$layout, pw$patches$layout)
})

test_that("plot containers reject arrays before flattening away dimensions", {
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  plots <- structure(list(p, p), dim = c(1L, 2L))
  expect_error(fmt_text(plots, title = "Title"), "one-dimensional")
  expect_error(fmt_scale(plots), "one-dimensional")
  expect_identical(fmt_text(list(a = p, b = p)), list(a = p, b = p))
})

test_that("base plot formatting preserves quoted lab values", {
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  label <- quote(alpha + beta)
  plots <- fmt_plot_base(list(p, p), labs_list = list(title = label, x = quote(gamma)))
  for (plot in plots) {
    expect_identical(plot$labels$title, label)
    expect_identical(plot$labels$x, quote(gamma))
    expect_s3_class(ggplot2::ggplotGrob(plot), "gtable")
  }
})

test_that("strip formatting validates wrapped panels during leaf collection", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
  nested <- p | p
  fn <- fmt_strip
  env <- new.env(parent = environment(fn))
  env$inherits <- function(x, what, ...) {
    if (identical(what, "patchwork") && inherits(x, "patchwork")) {
      stop("ran a separate wrapped-panel traversal")
    }
    base::inherits(x, what, ...)
  }
  environment(fn) <- env
  expect_s3_class(fn(nested / p), "patchwork")
  expect_error(fn(nested / patchwork::wrap_elements(grid::rectGrob())), "wrap_elements")
})

test_that("recursive plot inspection walks patchwork leaves only once", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = 4:1), ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(p, patchwork::plot_spacer(), patchwork::wrap_plots(p, p))
  expected <- .to_plot_list(pw, recurse = TRUE)
  fn <- .to_plot_list
  env <- new.env(parent = environment(fn))
  env$.to_plot_list <- function(...) stop("scanned patchwork children before visiting leaves")
  environment(fn) <- env
  expect_identical(fn(pw, recurse = TRUE), expected)
  expect_length(expected$plots, 3L)
})

test_that("scale inference snapshots do not inspect unrelated bindings", {
  scales <- plot_fixture()$scales
  reads <- 0L
  makeActiveBinding("unused", function() { reads <<- reads + 1L; 1 }, scales)
  result <- .scale_inference_parent(scales)
  expect_equal(reads, 0L)
  for (name in c("add_defaults", "add_missing")) {
    original <- scales[[name]]
    copy <- result[[name]]
    expect_identical(environment(copy)[["f"]], environment(original)[["f"]])
  }
})

test_that("scale clones preserve deferred labels without evaluation", {
  for (active in c(TRUE, FALSE)) {
    reads <- 0L
    scale <- ggplot2::scale_x_continuous()
    rm("labels", envir = scale)
    if (active) makeActiveBinding("labels", function() { reads <<- reads + 1L; ggplot2::waiver() }, scale) else
      delayedAssign("labels", { reads <<- reads + 1L; ggplot2::waiver() }, assign.env = scale, eval.env = new.env(parent = environment()))
    p <- plot_fixture() + scale
    copy <- .clone_plot_scales(p$scales)$scales[[1L]]
    expect_equal(reads, 0L)
    if (active) expect_true(bindingIsActive("labels", copy)) else
      expect_true(rlang::env_binding_are_lazy(copy, "labels")[[1L]])
    expect_s3_class(copy$labels, "waiver")
    expect_equal(reads, 1L)
  }
})

test_that("facet strip scalar and named labels need no level discovery", {
  values <- list(g = rep(c("a", "b", "c"), 300L), h = rep("panel", 900L))
  fn <- .fmt_strip_labeller
  env <- new.env(parent = environment(fn))
  env$unique <- function(...) stop("deduplicated facet values")
  environment(fn) <- env
  for (replacement in list("Group", c(a = "A", c = "C"))) {
    expected <- .fmt_strip_labeller(ggplot2::label_value, "g", replacement)(values)
    expect_identical(fn(ggplot2::label_value, "g", replacement)(values), expected)
  }
})

test_that("background stripes reuse the categorical axis observation check", {
  d <- data.frame(g = rep(c("B", NA, "A"), 300L), y = seq_len(900L))
  p <- ggplot2::ggplot(d, ggplot2::aes(g, y)) + ggplot2::geom_point()
  expected <- ggplot2::ggplot_build(fmt_bg(p))$data[[1L]]
  fn <- fmt_bg
  env <- new.env(parent = environment(fn))
  checks <- 0L
  env$is.na <- function(x) {
    if (identical(x, d$g)) checks <<- checks + 1L
    base::is.na(x)
  }
  environment(fn) <- env
  expect_identical(ggplot2::ggplot_build(fn(p))$data[[1L]], expected)
  expect_identical(checks, 1L)
})

test_that("comparison preparation does not recycle full ordinary mappings", {
  d <- data.frame(g = rep(c("B", "A"), each = 200L), y = as.double(seq_len(400L)))
  p <- ggplot2::ggplot(d, ggplot2::aes(g, y)) + ggplot2::geom_boxplot()
  expected <- suppressMessages(fmt_com(p))
  fn <- fmt_com
  env <- new.env(parent = environment(fn))
  env$rep <- function(x, ..., length.out = NA) {
    if (!is.na(length.out) && length.out == length(x) && length(x) == 400L) {
      calls <- sys.calls()
      if (any(vapply(calls, function(cl) identical(cl[[1L]], quote(get_comparisons)), logical(1))))
        stop("recycled a full comparison column")
    }
    if (missing(length.out)) base::rep(x, ...) else base::rep(x, ..., length.out = length.out)
  }
  environment(fn) <- env
  result <- suppressMessages(fn(p))
  expect_length(result$layers, length(expected$layers))
})
