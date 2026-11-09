dumbbell_plot <- function(data, ...) {
  withr::local_options(lifecycle_verbosity = "quiet")
  result <- NULL
  invisible(capture.output(result <- PlotDumbbell(data, ...)))
  result
}

test_that("dumbbell endpoint labels require scalar inputs before data evaluation", {
  for (arg in c("label_x", "label_xend"))
    for (bad in list(character(), c("a", "b"), matrix("a"))) {
      args <- c(list(data = quote(stop("data evaluated"))), stats::setNames(list(bad), arg))
      expect_error(do.call("PlotDumbbell", args), arg)
    }
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
  p <- dumbbell_plot(d, label_x = 1, label_xend = 2)
  expect_identical(unname(p$scales$get_scales("colour")$labels), c("1", "2"))
})

test_that("dumbbell dimensions validate active layers and leave hidden styles lazy", {
  for (arg in c("seg_size", "point_size", "delta_size", "zero_line_width", "mean_line_width", "dot_guide_size"))
    for (bad in list(-1, Inf, matrix(1), structure(1, class = "encoded"))) {
      args <- list(data = quote(stop("data evaluated")), show_delta = TRUE,
                   show_mean_lines = TRUE, dot_guide = TRUE)
      args[[arg]] <- bad
      expect_error(do.call("PlotDumbbell", args), arg)
    }
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
  p <- dumbbell_plot(d, show_zero_line = FALSE, delta_size = stop("unused"),
    zero_line_width = stop("unused"), mean_line_width = stop("unused"), dot_guide_size = stop("unused"))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
})

test_that("dumbbell display switches fail before data and keep inactive insets lazy", {
  for (arg in c("sort_descending", "show_delta", "show_zero_line", "show_mean_lines", "dot_guide"))
    for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
      args <- list(data = quote(stop("data evaluated")))
      args[[arg]] <- bad
      expect_error(do.call("PlotDumbbell", args), arg)
    }
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
  expect_no_warning(dumbbell_plot(d, inset_paired_line = stop("unused inset"),
    inset_jitter = stop("unused inset")))
})

test_that("dumbbell plots reject ambiguous input names before drawing", {
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3], start = 10:12, check.names = FALSE)
  expect_error(PlotDumbbell(d, theme_use = function() stop("theme evaluated")), "unique.*column names")
})

test_that("PlotDumbbell accepts numeric legend coordinates", {
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
  expect_no_warning(p <- dumbbell_plot(d, legend_pos = c(0.2, 0.8)))
  expect_equal(p$theme$legend.position.inside %||% p$theme$legend.position, c(0.2, 0.8))
  expect_equal(p$theme$legend.justification, c(0, 1))
  for (bad in list(NULL, NA_character_, c("left", "right"), 1, c(NA, 1), matrix(c(0, 1))))
    expect_error(PlotDumbbell(stop("data evaluated"), legend_pos = bad), "legend_pos")
})

test_that("PlotDumbbell diagnoses selectors and non-vector endpoints before drawing", {
  for (arg in c("x_col", "xend_col", "y_col")) {
    for (bad in list(NULL, character(), c("start", "end"), NA_character_,
                     matrix("start"), 1)) {
      args <- list(data = quote(stop("data evaluated")))
      args[arg] <- list(bad)
      expect_error(do.call(PlotDumbbell, args), arg)
    }
  }
  for (col in c("start", "end")) {
    for (bad in list(1:3 + 1i, matrix(1:3, 3), as.list(1:3))) {
      data <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
      data[[col]] <- bad
      expect_no_warning(expect_error(dumbbell_plot(data), col))
    }
  }
})

test_that("PlotDumbbell retains integer differences beyond the integer range", {
  data <- data.frame(start = as.integer(c(2e9, -1.8e9, 0, 10)),
                      end = as.integer(c(-2e9, 1.8e9, 3, 11)), category = letters[1:4])
  original <- data
  expect_no_warning(plot <- dumbbell_plot(data, sort_by = "delta", show_delta = TRUE))
  expect_identical(as.character(plot$data$category), c("a", "d", "c", "b"))
  expect_equal(plot$data$.delta, c(-4e9, 1, 3, 3.6e9))
  expect_equal(ggplot2::ggplot_build(plot)$data[[5]]$label, c(-4e9, 1, 3, 3.6e9))
  expect_identical(plot$data$start, data$start[c(1, 4, 3, 2)])
  expect_identical(plot$data$end, data$end[c(1, 4, 3, 2)])
  for (descending in c(FALSE, TRUE)) {
    plot <- dumbbell_plot(data, sort_by = "delta", sort_descending = descending, top_n = 2)
    want <- if (descending) c("d", "a") else c("c", "b")
    expect_identical(as.character(plot$data$category), want)
  }
  boundary <- data.frame(start = c(0L, -1L, 0L, 1L),
                          end = as.integer(c(2147483647, 2147483647, -2147483647, -2147483647)),
                          category = letters[1:4])
  expect_no_warning(plot <- dumbbell_plot(boundary, sort_by = "none", show_delta = TRUE))
  expect_equal(plot$data$.delta, c(2147483647, 2147483648, -2147483647, -2147483648))
  expect_identical(data, original)
})

test_that("PlotDumbbell preserves ordinary integer and classed differences", {
  data <- data.frame(start = 1:4, end = c(4L, 6L, 8L, 9L), category = letters[1:4])
  plot <- dumbbell_plot(data, sort_by = "none", show_delta = TRUE)
  expect_identical(plot$data$.delta, c(3L, 4L, 5L, 5L))
  for (kind in c("Date", "difftime")) {
    classed <- data
    if (kind == "Date") {
      classed$start <- as.Date("2026-01-01") + data$start
      classed$end <- as.Date("2026-01-01") + data$end
    } else {
      classed$start <- as.difftime(data$start, units = "hours")
      classed$end <- as.difftime(data$end, units = "hours")
    }
    original <- classed
    plot <- dumbbell_plot(classed, sort_by = "none", show_delta = TRUE,
                           show_zero_line = FALSE)
    expect_s3_class(plot$data$.delta, "difftime")
    expect_equal(as.double(plot$data$.delta), c(3, 4, 5, 5))
    expect_identical(attr(plot$data$.delta, "units"), if (kind == "Date") "days" else "hours")
    expect_identical(plot$data$start, classed$start)
    expect_identical(plot$data$end, classed$end)
    expect_identical(classed, original)
  }
})

test_that("PlotDumbbell paired t-test and bracket avoid integer overflow", {
  data <- data.frame(start = as.integer(c(2e9, -1.8e9, 0, 10)),
                      end = as.integer(c(-2e9, 1.8e9, 3, 11)), category = letters[1:4])
  inset <- NULL
  original <- get(".build_dumbbell_inset", asNamespace("UtilsR"))
  testthat::local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  expect_no_warning(dumbbell_plot(data, inset_plot = "auto", inset_test = "t.test",
                                  inset_jitter = FALSE))
  built <- ggplot2::ggplot_build(inset)
  expect_equal(built$data[[3]]$y, 2.2e9)
  expect_equal(built$data[[4]]$y, 2.36e9)
  expect_identical(built$data[[4]]$label, "p = 0.953")
  expect_type(inset$data$.value, "integer")
})

test_that("PlotDumbbell paired Wilcoxon and bracket avoid integer overflow", {
  data <- data.frame(start = as.integer(c(2e9, -1.8e9, 0, 10)),
                      end = as.integer(c(-2e9, 1.8e9, 3, 11)), category = letters[1:4])
  inset <- NULL
  original <- get(".build_dumbbell_inset", asNamespace("UtilsR"))
  testthat::local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  expect_no_warning(dumbbell_plot(data, inset_plot = "auto", inset_test = "wilcox",
                                  inset_jitter = FALSE))
  built <- ggplot2::ggplot_build(inset)
  expect_equal(built$data[[3]]$y, 2.2e9)
  expect_equal(built$data[[4]]$y, 2.36e9)
  expect_identical(built$data[[4]]$label, "p = 0.875")
  expect_type(inset$data$.value, "integer")
})

test_that("PlotDumbbell keeps endpoints distinct when their display labels match", {
  data <- data.frame(start = 1:4, end = c(4, 6, 8, 9), category = letters[1:4])
  plot <- dumbbell_plot(data, label_x = "Value", label_xend = "Value")
  built <- ggplot2::ggplot_build(plot)
  expect_identical(built$data[[2]]$colour, rep("#00468BFF", 4))
  expect_identical(built$data[[3]]$colour, rep("#ED0000FF", 4))
  expect_identical(as.character(built$plot$scales$get_scales("colour")$get_labels()),
                   c("Value", "Value"))
  inset <- NULL
  original <- get(".build_dumbbell_inset", asNamespace("UtilsR"))
  testthat::local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  dumbbell_plot(data, label_x = "Value", label_xend = "Value",
                 inset_plot = "auto", inset_test = "t.test")
  expect_equal(length(unique(inset$data$.group)), 2L)
  inset_built <- ggplot2::ggplot_build(inset)
  expect_identical(as.character(inset_built$layout$panel_params[[1]]$x$get_labels()),
                   c("Value", "Value"))
  expect_equal(unname(split(inset_built$data[[2]]$y, inset_built$data[[2]]$group)),
               lapply(1:4, function(i) c(data$start[i], data$end[i])))
  expect_identical(inset_built$data[[5]]$label,
                   sprintf("p = %.3f", stats::t.test(data$start, data$end, paired = TRUE)$p.value))
})

test_that("PlotDumbbell automatic inset works without jitter points", {
  data <- data.frame(start = 1:4, end = c(4, 6, 8, 9), category = letters[1:4])
  for (inset_type in c("boxplot", "violin")) {
    expect_no_warning(dumbbell_plot(data, inset_plot = "auto", inset_type = inset_type,
                                    inset_test = "none", inset_jitter = FALSE))
  }
})

test_that("PlotDumbbell validates inset types only for automatic insets", {
  data <- data.frame(start = 1:4, end = c(4, 6, 8, 9), category = letters[1:4])
  for (inset_type in list("typo", "box", NA_character_, character(),
                         c("boxplot", "violin"), TRUE)) {
    expect_error(dumbbell_plot(data, inset_plot = "auto", inset_type = inset_type,
                               inset_test = "none"), "inset_type.*boxplot.*violin")
  }
  expect_no_warning(dumbbell_plot(data, inset_type = "unused"))
  custom <- ggplot2::ggplot(data, ggplot2::aes(start, end)) + ggplot2::geom_point()
  expect_no_warning(dumbbell_plot(data, inset_plot = custom, inset_type = "unused"))
})

test_that("PlotDumbbell labels and guide origins ignore unrelated input columns", {
  data <- data.frame(
    start = 1:4, end = c(4, 6, 8, 9), category = letters[1:4],
    label_x = "metadata", label_xend = "other_metadata", x_min = 91:94
  )
  original <- data
  expect_no_warning(plot <- dumbbell_plot(data, dot_guide = TRUE,
                                          label_x = "Before", label_xend = "After"))
  expect_no_warning(built <- ggplot2::ggplot_build(plot))
  expect_equal(built$data[[1]]$x, rep(1, 4))
  expect_identical(built$data[[3]]$colour, rep("#00468BFF", 4))
  expect_identical(built$data[[4]]$colour, rep("#ED0000FF", 4))
  expect_identical(data, original)
})

test_that("PlotDumbbell accepts selected columns named after aesthetic constants", {
  data <- data.frame(start = 1:4, end = c(4, 6, 8, 9), category = letters[1:4])
  reference <- ggplot2::ggplot_build(dumbbell_plot(
    data, dot_guide = TRUE, label_x = "Before", label_xend = "After"
  ))$data
  for (role in names(data)) {
    for (field in c("label_x", "label_xend", "x_min")) {
      renamed <- data
      columns <- stats::setNames(names(data), names(data))
      columns[[role]] <- field
      names(renamed) <- unname(columns)
      original <- renamed
      plot <- dumbbell_plot(renamed, x_col = columns[["start"]],
                             xend_col = columns[["end"]], y_col = columns[["category"]],
                             dot_guide = TRUE, label_x = "Before", label_xend = "After")
      expect_equal(ggplot2::ggplot_build(plot)$data, reference)
      expect_identical(renamed, original)
    }
  }
})

test_that("dumbbell top counts reject arrays and encoded numbers before themes", {
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
  for (bad in list(matrix(1), structure(1, class = "encoded")))
    expect_error(PlotDumbbell(d, top_n = bad, theme_use = function() stop("theme evaluated")), "top_n")
})

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

test_that("PlotDumbbell validates theme specifications", {
  data <- data.frame(start = 1:4, end = c(2, 3, 3, 5), category = letters[1:4])
  expect_error(dumbbell_plot(data, theme_use = "theme_mimimal"), "Theme 'theme_mimimal' not found")
  expect_error(dumbbell_plot(data, theme_use = function() ggplot2::geom_point()),
               "must return a ggplot2 theme")
  expect_error(dumbbell_plot(data, inset_plot = "auto", inset_test = "none",
                              inset_theme_use = "theme_mimimal"), "Theme 'theme_mimimal' not found")
  named <- dumbbell_plot(data, theme_use = "theme_minimal")
  expect_equal(named$theme, dumbbell_plot(data, theme_use = ggplot2::theme_minimal())$theme)
  expect_equal(dumbbell_plot(data, theme_use = NULL)$theme,
               dumbbell_plot(data, theme_use = ggplot2::theme_classic())$theme)
})

test_that("PlotDumbbell reuses the resolved main theme in automatic insets", {
  data <- data.frame(start = 1:4, end = c(2, 3, 3, 5), category = letters[1:4])
  inset <- NULL
  original <- get(".build_dumbbell_inset", asNamespace("UtilsR"))
  testthat::local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  calls <- 0L
  factory <- function() {
    calls <<- calls + 1L
    ggplot2::theme_bw(base_size = 16 + calls)
  }
  plot <- dumbbell_plot(data, theme_use = factory, inset_plot = "auto", inset_test = "none")
  expect_identical(calls, 1L)
  expect_equal(plot[[1L]]$theme$text$size, 17)
  expect_equal(inset$theme$text$size, 17)

  calls <- 0L
  inset_calls <- 0L
  inset_factory <- function() {
    inset_calls <<- inset_calls + 1L
    ggplot2::theme_bw(base_size = 23)
  }
  plot <- dumbbell_plot(data, theme_use = factory, inset_plot = "auto", inset_test = "none",
                        inset_theme_use = inset_factory)
  expect_identical(c(calls, inset_calls), c(1L, 1L))
  expect_equal(plot[[1L]]$theme$text$size, 17)
  expect_equal(inset$theme$text$size, 23)
})

test_that("dumbbell category columns retain vector boundaries", {
  d <- data.frame(start = 1:2, end = 3:4)
  d[["category"]] <- I(matrix(c("a", "b"), ncol = 1L))
  expect_error(PlotDumbbell(d), "category.*vector")
  d[["category"]] <- c("a", "b")
  expect_s3_class(PlotDumbbell(d, legend_pos = "none"), "ggplot")
})

test_that("dumbbell numeric categories retain exact identity", {
  d <- data.frame(start = c(1, 3), end = c(2, 4), category = c(1, 1 + .Machine$double.eps))
  p <- PlotDumbbell(d, sort_by = "none", legend_pos = "none")
  expect_identical(as.integer(p$data$category), 1:2)
  expect_identical(levels(p$data$category), sprintf("%.17g", d$category))
  expect_equal(as.numeric(ggplot2::ggplot_build(p)$data[[1L]]$y), 1:2)
  d$category <- c(1, 2)
  expect_identical(levels(PlotDumbbell(d, legend_pos = "none")$data$category), c("1", "2"))
})

test_that("dumbbell endpoints normalize SPSS missing codes before arithmetic", {
  skip_if_not_installed("haven")
  d <- data.frame(category = letters[1:5], start = c(1, 99, 3, 4, 97), end = c(2, 6, 99, 8, 9))
  d$start <- haven::labelled_spss(d$start, na_values = 97, na_range = c(98, 100))
  d$end <- haven::labelled_spss(d$end, na_values = 99)
  before <- serialize(d, NULL)
  control <- haven::zap_missing(d)
  control$start <- vctrs::vec_data(control$start)
  control$end <- vctrs::vec_data(control$end)
  draw <- PlotDumbbell
  e <- new.env(parent = environment(draw))
  e$print <- function(x, ...) invisible(x)
  environment(draw) <- e
  for (sort in c("none", "delta", "start", "end")) {
    p <- draw(d, sort_by = sort, show_mean_lines = TRUE, show_delta = TRUE, legend_pos = "none")
    q <- draw(control, sort_by = sort, show_mean_lines = TRUE, show_delta = TRUE, legend_pos = "none")
    expect_identical(p$data$category, q$data$category)
    expect_equal(as.numeric(p$data$start), as.numeric(q$data$start))
    expect_equal(as.numeric(p$data$end), as.numeric(q$data$end))
    expect_equal(as.numeric(p$data$.delta), as.numeric(q$data$.delta))
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
  }
  expect_identical(serialize(d, NULL), before)
})

test_that("dumbbell inset paired t tests preserve extreme scale p values", {
  inset <- NULL
  original <- .build_dumbbell_inset
  local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  })
  x <- 1:8
  y <- c(2, 4, 3, 5, 7, 6, 9, 8)
  expected <- sprintf("p = %.3f", stats::t.test(x, y, paired = TRUE)$p.value)
  for (unit in c(1, 1e200, 1e-200)) {
    d <- data.frame(start = x * unit, end = y * unit, category = letters[1:8])
    expect_no_warning(p <- dumbbell_plot(d, inset_plot = "auto", inset_test = "t.test",
      legend_pos = "none", inset_jitter = FALSE, sort_by = "none"))
    text <- Filter(function(layer) "label" %in% names(layer), ggplot2::ggplot_build(inset)$data)
    expect_identical(unlist(lapply(text, `[[`, "label"), use.names = FALSE), expected)
    expect_identical(p[[1L]]$data$start, d$start)
    expect_identical(p[[1L]]$data$end, d$end)
  }
})

test_that("dumbbell inset tests accept typed time endpoints", {
  inset <- NULL
  original <- .build_dumbbell_inset
  local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  x <- c(1, 3, 2, 5, 8, 6)
  y <- c(2, 5, 3, 6, 9, 8)
  converters <- list(function(z) as.Date(z, origin = "2020-01-01"),
    function(z) as.POSIXct(z, origin = "2020-01-01", tz = "UTC"),
    function(z) as.POSIXlt(z, origin = "2020-01-01", tz = "UTC"),
    function(z) as.difftime(z, units = "mins"))
  for (convert in converters) {
    d <- data.frame(start = convert(x), end = convert(y), category = letters[1:6])
    before <- serialize(d, NULL)
    for (method in c("t.test", "wilcox")) {
      pval <- suppressWarnings(if (method == "t.test") stats::t.test(x, y, paired = TRUE)$p.value else
        stats::wilcox.test(x, y, paired = TRUE)$p.value)
      expected <- if (pval < .001) sprintf("p = %.1e", pval) else sprintf("p = %.3f", pval)
      suppressWarnings(dumbbell_plot(d, inset_plot = "auto", inset_test = method,
        legend_pos = "none", inset_jitter = FALSE, sort_by = "none"))
      text <- Filter(function(layer) "label" %in% names(layer), ggplot2::ggplot_build(inset)$data)
      expect_identical(unlist(lapply(text, `[[`, "label"), use.names = FALSE), expected)
      expect_true(inherits(inset$data$.value, class(d$start)[1L]))
    }
    expect_identical(serialize(d, NULL), before)
  }
})

test_that("dumbbell duration coordinates share the start unit", {
  for (end_unit in c("secs", "hours")) {
    d <- data.frame(start = as.difftime(1:3, units = "mins"),
      end = as.difftime(2:4, units = "mins"), category = letters[1:3])
    units(d$end) <- end_unit
    before <- serialize(d, NULL)
    expected_delta <- d$end - d$start
    p <- suppressMessages(dumbbell_plot(d, sort_by = "none", legend_pos = "none",
      show_zero_line = FALSE, show_mean_lines = TRUE, dot_guide = TRUE))
    built <- suppressMessages(ggplot2::ggplot_build(p))$data
    expect_equal(built[[2L]]$x, as.numeric(1:3))
    expect_equal(built[[2L]]$xend, as.numeric(2:4))
    means <- unlist(lapply(Filter(function(layer) "xintercept" %in% names(layer), built),
                           `[[`, "xintercept"), use.names = FALSE)
    expect_equal(means, c(2, 3))
    expect_identical(p$data$.delta, expected_delta)
    expect_identical(attr(p$data$end, "units"), "mins")
    expect_identical(serialize(d, NULL), before)
  }
})

test_that("dumbbell factor endpoint colours retain their labels", {
  d <- data.frame(start = 1:3, end = 2:4, category = letters[1:3])
  red <- factor("red", levels = c("blue", "red"))
  inset <- NULL
  original <- .build_dumbbell_inset
  local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  for (auto in c(FALSE, TRUE)) {
    p <- dumbbell_plot(d, color_x = red, color_xend = "blue", legend_pos = "none",
      inset_plot = if (auto) "auto" else NULL, inset_test = "none")
    main <- if (auto) p[[1L]] else p
    layers <- ggplot2::ggplot_build(main)$data
    expect_identical(layers[[2L]]$colour, rep("red", 3))
    expect_identical(layers[[3L]]$colour, rep("blue", 3))
    if (auto) expect_identical(unname(inset$scales$get_scales("fill")$palette(2)), c("red", "blue"))
  }
})

test_that("dumbbell insets retain undefined Wilcoxon results", {
  d <- data.frame(start = 1:6, end = 1:6, category = letters[1:6])
  before <- d
  inset <- NULL
  original <- .build_dumbbell_inset
  local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  expect_warning(native <- stats::wilcox.test(d$start, d$end, paired = TRUE), "zeroes")
  expect_true(is.nan(native$p.value))
  expect_warning(p <- dumbbell_plot(d, inset_plot = "auto", inset_test = "wilcox",
    legend_pos = "none", inset_jitter = FALSE), "zeroes")
  text <- Filter(function(layer) "label" %in% names(layer), ggplot2::ggplot_build(inset)$data)
  expect_identical(unlist(lapply(text, `[[`, "label"), use.names = FALSE), "p = NaN")
  expect_s3_class(p, "patchwork")
  expect_identical(d, before)
})

test_that("dumbbell inset annotations avoid intermediate range overflow", {
  inset <- NULL
  original <- .build_dumbbell_inset
  local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  for (unit in c(1, 1e308)) {
    d <- data.frame(start = c(-1, -.7, .7, 1) * unit,
      end = c(-.9, -.5, .6, .9) * unit, category = letters[1:4])
    before <- d
    suppressWarnings(dumbbell_plot(d, inset_plot = "auto", inset_test = "wilcox",
      legend_pos = "none", inset_jitter = FALSE, inset_paired_line = FALSE))
    built <- ggplot2::ggplot_build(inset)$data
    bracket <- Filter(function(layer) "xend" %in% names(layer), built)[[1L]]
    label <- Filter(function(layer) "label" %in% names(layer), built)[[1L]]
    expect_true(all(is.finite(c(bracket$y, bracket$yend, label$y))))
    expect_equal(bracket$y / unit, 1.1)
    expect_equal(bracket$yend / unit, 1.1)
    expect_equal(label$y / unit, 1.18)
    expect_s3_class(ggplot2::ggplotGrob(inset), "gtable")
    expect_identical(d, before)
  }
})

test_that("dumbbell factor endpoint labels retain displayed text", {
  d <- data.frame(start = c(1, 3, 2, 5), end = c(2, 5, 3, 6), category = letters[1:4])
  inset <- NULL
  original <- .build_dumbbell_inset
  local_mocked_bindings(.build_dumbbell_inset = function(...) {
    inset <<- original(...)
    inset
  }, .package = "UtilsR")
  for (label in c("label_x", "label_xend")) {
    args <- list(data = d, label_x = "Before", label_xend = "After", legend_pos = "none",
      inset_plot = "auto", inset_test = "none", inset_jitter = FALSE)
    args[[label]] <- factor(args[[label]], levels = c("unused", args[[label]]))
    p <- do.call(dumbbell_plot, args)
    expect_identical(unname(p[[1L]]$scales$get_scales("colour")$labels), c("Before", "After"))
    actual <- ggplot2::ggplot_build(inset)$layout$panel_params[[1L]]$x$get_labels()
    expect_identical(as.character(actual), c("Before", "After"))
  }
  direct <- original(d, "start", "end", factor("Before", levels = c("unused", "Before")),
    "After", "red", "blue", "boxplot", "none", FALSE, FALSE, ggplot2::theme_classic())
  expect_identical(as.character(ggplot2::ggplot_build(direct)$layout$panel_params[[1L]]$x$get_labels()),
                   c("Before", "After"))
})

test_that("dumbbell category axes distinguish explicit factor missing levels", {
  d <- data.frame(start = 1:4, end = 2:5,
    category = structure(c(2L, NA_integer_, 1L, 3L),
      levels = c("ordinary", NA_character_, "<NA>"), class = "factor"))
  before <- d
  p <- dumbbell_plot(d, sort_by = "none", legend_pos = "none")
  expect_identical(as.character(p$data$category), c("<NA>.1", NA, "ordinary", "<NA>"))
  segment <- ggplot2::ggplot_build(p)$data[[1L]]
  expect_length(unique(segment$y), 4L)
  expect_identical(d, before)
})

test_that("dumbbell category roles preserve endpoint values", {
  d <- data.frame(start = c(3, 1, 2), end = c(4, 2, 5), .category = "occupied")
  for (role in c("start", "end")) {
    control <- d
    control$category <- as.character(d[[role]])
    expected <- ggplot2::ggplot_build(PlotDumbbell(control, sort_by = "none",
      show_delta = TRUE, show_mean_lines = TRUE, legend_pos = "none"))$data
    actual <- ggplot2::ggplot_build(PlotDumbbell(d, y_col = role, sort_by = "none",
      show_delta = TRUE, show_mean_lines = TRUE, legend_pos = "none"))$data
    expect_equal(actual, expected)
  }
})

test_that("dumbbell zero lines use date and datetime coordinates", {
  for (origin in list(as.Date("2026-01-01"), as.POSIXct("2026-01-01", tz = "UTC"))) {
    d <- data.frame(start = origin + 1:3, end = origin + 3:5, category = letters[1:3])
    p <- PlotDumbbell(d, show_delta = TRUE, show_mean_lines = TRUE, legend_pos = "none")
    expect_no_warning(built <- ggplot2::ggplot_build(p))
    expect_identical(as.numeric(built$data[[4L]]$xintercept), 0)
    expect_equal(as.numeric(built$data[[1L]]$x), as.numeric(d$start))
  }
})

test_that("dumbbell endpoints restore cold integer64 arithmetic", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  input <- file.path(scratch, "input.rds")
  script <- file.path(scratch, "verify.R")
  d <- data.frame(start = bit64::as.integer64(1:3), end = bit64::as.integer64(3:5),
    category = letters[1:3])
  path <- getNamespaceInfo(asNamespace("UtilsR"), "path")
  saveRDS(list(data = d, libs = .libPaths(), path = path), input)
  writeLines(c(sprintf("payload <- readRDS(%s)", deparse(input)),
    '.libPaths(payload[["libs"]])',
    'path <- payload[["path"]]',
    'if (file.exists(file.path(path, "Meta", "package.rds"))) {',
    '  library("UtilsR", lib.loc = dirname(path))',
    '} else {',
    '  pkgload::load_all(path, quiet = TRUE)',
    '}',
    'stopifnot(!("bit64" %in% loadedNamespaces()))',
    'p <- UtilsR::PlotDumbbell(payload[["data"]], sort_by = "none", legend_pos = "none")',
    'stopifnot("bit64" %in% loadedNamespaces(), identical(as.character(p[["data"]][[".delta"]]), rep("2", 3)))',
    'built <- ggplot2::ggplot_build(p)[["data"]][[1L]]',
    'stopifnot(all(built[["x"]] == 1:3), all(built[["xend"]] == 3:5))',
    'cat("COLD_DUMBBELL_OK\n")'), script)
  output <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
  expect_true("COLD_DUMBBELL_OK" %in% output)
})

test_that("dumbbell integer64 differences survive arithmetic overflow", {
  skip_if_not_installed("bit64")
  fn <- PlotDumbbell
  env <- new.env(parent = environment(fn))
  env$print <- function(x, ...) invisible(x)
  environment(fn) <- env
  d <- data.frame(start = bit64::as.integer64(c("9223372036854775807", "-9223372036854775807", "1", NA)),
    end = bit64::as.integer64(c("-9223372036854775807", "9223372036854775807", "4", "0")),
    category = letters[1:4])
  expect_no_warning(p <- fn(d, sort_by = "none", show_delta = TRUE, legend_pos = "none"))
  expect_identical(p$data$.delta, c(-2^64, 2^64, 3, NA_real_))
  expect_identical(p$data$start, d$start)
  regular <- fn(d[3:4, ], sort_by = "none", legend_pos = "none")
  expect_identical(regular$data$.delta, bit64::as.integer64(c("3", NA)))
})

test_that("integer64 dumbbell mean lines preserve fractions and cancellation", {
  skip_if_not_installed("bit64")
  fn <- PlotDumbbell
  env <- new.env(parent = environment(fn))
  env$print <- function(x, ...) invisible(x)
  environment(fn) <- env
  d <- data.frame(start = bit64::as.integer64(c("9223372036854775807", "-9223372036854775806")),
    end = bit64::as.integer64(c("2", "3")), category = c("a", "b"))
  p <- fn(d, sort_by = "none", show_zero_line = FALSE,
    show_mean_lines = TRUE, legend_pos = "none")
  expect_identical(p$layers[[4L]]$data$xintercept, 0.5)
  expect_identical(p$layers[[5L]]$data$xintercept, 2.5)
  expect_identical(p$data$start, d$start)
})

test_that("automatic dumbbell insets test exact integer64 paired differences", {
  skip_if_not_installed("bit64")
  offsets <- bit64::as.integer64(c("0", "9007199254740992"))
  differences <- c(1, 2, 3, 7, -5)
  expected <- stats::t.test(differences, numeric(length(differences)), paired = TRUE)$p.value
  for (i in seq_along(offsets)) {
    d <- data.frame(start = offsets[i] + bit64::as.integer64(1:5))
    d$end <- d$start + bit64::as.integer64(differences)
    expect_no_warning(inset <- .build_dumbbell_inset(d, "start", "end",
      "Start", "End", "blue", "red", "boxplot", "t.test", FALSE, FALSE,
      ggplot2::theme_classic()))
    label <- ggplot2::ggplot_build(inset)$data[[3L]]$label
    expect_identical(label, sprintf("p = %.3f", expected))
    expect_type(inset$data$.value, "double")
  }
})

test_that("dumbbell Date and datetime endpoints share one scale", {
  date <- as.Date("2026-01-01") + 1:4
  seconds <- c(30, 60, 90, 120)
  when <- as.POSIXct(date) + seconds
  d <- data.frame(date = date, instant = when)
  for (start in c("date", "instant")) {
    end <- setdiff(names(d), start)
    expect_no_warning(p <- PlotDumbbell(d, x_col = start, xend_col = end, y_col = "date",
      sort_by = "none", show_delta = TRUE, show_mean_lines = TRUE, legend_pos = "none"))
    expect_equal(as.numeric(p$data$.delta, units = "secs"), if (start == "date") seconds else -seconds)
    coords <- ggplot2::ggplot_build(p)$data[[1L]]
    expect_equal(coords$x, if (start == "date") as.numeric(as.POSIXct(date)) else as.numeric(when))
    expect_identical(p$data$date, date)
  }
})
