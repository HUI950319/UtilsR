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
