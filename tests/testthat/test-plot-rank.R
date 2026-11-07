test_that("PlotRank rejects distinct groups with colliding character labels", {
  groups <- c(1, 1 + 1e-15)
  expect_length(unique(groups), 2L)
  expect_length(unique(as.character(groups)), 1L)
  data <- data.frame(cell_type = rep(groups, each = 3), gene = letters[1:6],
                     importance = c(9, 6, 3, 20, 10, 0))
  original <- data
  filename <- withr::local_tempfile(fileext = ".pdf")
  selections <- list(list(), list(groups = "1"), list(groups = groups[2]),
                     list(group_levels = "1"))
  for (selection in selections) {
    for (scale in c("none", "group", "top_n")) {
      for (type in c("plot", "data", "both")) {
        args <- c(list(data = data, value_scale = scale, return_type = type,
                       filename = filename), selection)
        error <- tryCatch(do.call(PlotRank, args), error = identity)
        expect_s3_class(error, "error")
        if (inherits(error, "error")) {
          expect_match(conditionMessage(error), "Distinct grouping values.*identical character labels")
          expect_match(conditionMessage(error), "unique character labels")
          expect_null(conditionCall(error))
        }
        expect_length(Sys.glob(filename), 0L)
      }
    }
  }
  expect_identical(data, original)
})

test_that("PlotRank ranks close numeric groups after explicit unique labelling", {
  data <- data.frame(cell_type = rep(c(1, 1 + 1e-15), each = 3),
                     gene = letters[1:6], importance = c(9, 6, 3, 20, 10, 0))
  data$cell_type <- sprintf("%.17g", data$cell_type)
  groups <- unique(data$cell_type)
  expected <- list(none = c(9, 6, 20, 10), group = c(1, .5, 1, .5),
                    top_n = c(1, 0, 1, 0))
  for (scale in names(expected)) {
    result <- PlotRank(data, max_show = 2, top_n = 1, value_scale = scale,
                         return_type = "both")
    expect_identical(levels(result$data$Group), groups)
    expect_identical(result$data$Label, c("a", "b", "d", "e"))
    expect_equal(unname(result$data$Score), expected[[scale]])
    built <- ggplot2::ggplot_build(result$plot)
    expect_identical(as.character(built$layout$layout$Group), groups)
    expect_equal(built$data[[1]]$y, expected[[scale]])
    expect_identical(built$data[[2]]$label, c("a", "d"))
  }
  selected <- PlotRank(data, groups = groups[2], return_type = "data")
  expect_identical(selected$Label, c("d", "e", "f"))
  expect_equal(unname(selected$Score), c(20, 10, 0))
})

test_that("PlotRank keeps numeric groups with distinct character labels", {
  data <- data.frame(cell_type = rep(c(2, 1, 1.00001), each = 3),
                     gene = letters[1:9], importance = c(8, 4, 0, 9, 6, 3, 20, 10, NA))
  original <- data
  control <- data
  control$cell_type <- as.character(control$cell_type)
  for (scale in c("none", "group", "top_n")) {
    result <- PlotRank(data, max_show = 2, value_scale = scale, return_type = "data")
    expected <- PlotRank(control, max_show = 2, value_scale = scale, return_type = "data")
    expect_identical(result, expected)
    expect_identical(levels(result$Group), c("2", "1", "1.00001"))
  }
  selected <- PlotRank(data, groups = "1.00001", return_type = "data")
  expect_identical(selected$Label, c("g", "h"))
  expect_equal(unname(selected$Score), c(20, 10))
  ordered <- PlotRank(data, group_levels = c("1.00001", "2"), return_type = "data")
  expect_identical(levels(ordered$Group), c("1.00001", "2"))
  expect_identical(ordered$Label, c("g", "h", "a", "b", "c"))
  expect_identical(data, original)
})

test_that("full-range rank scaling keeps interleaved and constant groups aligned", {
  d <- data.frame(cell_type = rep(c("A", "B", "C"), 3), gene = rep(letters[1:3], each = 3),
    importance = c(3, 1e308, 5, 1, -1e308, 5, 2, 0, 5))
  result <- PlotRank(d, max_show = 2, value_scale = "group", return_type = "data")
  expect_equal(result$Score, c(1, 0.5, 1, 0.5, 0, 0))
  expect_identical(as.character(result$Group), rep(c("A", "B", "C"), each = 2))
  expect_identical(result$Label, c("a", "c", "a", "c", "a", "b"))
})

test_that("PlotRank scales extreme finite ranges without losing the middle score", {
  for (values in list(c(-1e308, 0, 1e308), c(-1.5e308, .5e308, 1.5e308))) {
    data <- stats::setNames(c(values, NA_real_), letters[1:4])
    before <- data
    control <- stats::setNames(c(values / 1e308, NA_real_), letters[1:4])
    for (mode in c("group", "top_n")) {
      actual <- PlotRank(data, value_scale = mode, return_type = "data")
      expected <- PlotRank(control, value_scale = mode, return_type = "data")
      expect_equal(actual, expected)
      expect_true(all(is.finite(actual$Score)))
    }
    expect_identical(data, before)
  }
  data <- stats::setNames(c(-1e308, 0, 1e308), letters[1:3])
  full_range <- PlotRank(data, value_scale = "group", max_show = 2, return_type = "data")
  shown_range <- PlotRank(data, value_scale = "top_n", max_show = 2, return_type = "data")
  expect_equal(unname(full_range$Score), c(1, .5))
  expect_equal(unname(shown_range$Score), c(1, 0))
})

test_that("PlotRank rejects non-vector and non-real score storage", {
  for (value in list(matrix(1:6, 3), array(1:6, c(3, 2, 1)), list(1, 2, 3),
                     c(1 + 1i, 2 + 2i, 3 + 3i), factor(1:3), as.raw(1:3))) {
    data <- data.frame(gene = letters[1:3])
    data$importance <- value
    expect_error(PlotRank(data, return_type = "data"), "one-dimensional real numeric")
  }
  data <- matrix(1:6, 3, dimnames = list(letters[1:3], c("A", "B")))
  result <- PlotRank(data, return_type = "data")
  expect_equal(nrow(result), 6L)
  expect_setequal(result$Label, letters[1:3])
  scores <- stats::setNames(c(3, NA, 1), letters[1:3])
  result <- PlotRank(scores, return_type = "data")
  expect_identical(result$Label, c("a", "c"))
  expect_equal(unname(result$Score), c(3, 1))
})

test_that("PlotRank excludes class-defined labelled missing scores", {
  skip_if_not_installed("haven")
  scores <- haven::labelled_spss(c(1, 99, 2, NA), na_values = 99)
  names(scores) <- letters[1:4]
  data <- data.frame(gene = letters[1:4], importance = scores)
  original <- data
  result <- PlotRank(data, top_n = 1, return_type = "both")
  expect_identical(result$data$Label, c("c", "a"))
  expect_identical(result$data$Label[result$data$IsTop], "c")
  expect_equal(as.numeric(ggplot2::ggplot_build(result$plot)$data[[1]]$y), c(2, 1))
  expect_s3_class(result$data$Score, "haven_labelled_spss")
  expect_identical(data, original)
  vector <- PlotRank(scores, top_n = 1, return_type = "data")
  expect_identical(vector$Label, c("c", "a"))
})

test_that("PlotRank rejects integer64 and time scores explicitly", {
  values <- list(as.Date(c("2020-01-01", "2020-01-02", NA)),
                 as.POSIXct(c("2020-01-01", "2020-01-02", NA), tz = "UTC"),
                 as.POSIXlt(as.POSIXct(c("2020-01-01", "2020-01-02", NA), tz = "UTC")),
                 as.difftime(c(1, 2, NA), units = "hours"))
  for (value in values) {
    data <- data.frame(gene = letters[1:3])
    data$importance <- value
    expect_error(PlotRank(data, return_type = "data"), "one-dimensional real numeric")
  }
  skip_if_not_installed("bit64")
  value <- bit64::as.integer64(c(1, 2, NA))
  expect_error(PlotRank(stats::setNames(value, letters[1:3]), return_type = "data"),
               "integer64.*not supported.*precision")
  data$importance <- value
  expect_error(PlotRank(data, return_type = "data"), "integer64.*not supported.*precision")
})

test_that("PlotRank rejects lubridate scores without implicit conversion", {
  skip_if_not_installed("lubridate")
  for (value in list(lubridate::dseconds(c(1, 2, NA)), lubridate::seconds(c(1, 2, NA)))) {
    data <- data.frame(gene = letters[1:3])
    data$importance <- value
    expect_error(PlotRank(data, return_type = "data"), "one-dimensional real numeric")
  }
})

test_that("PlotRank restores labelled missingness in a fresh process", {
  skip_if_not_installed("haven")
  skip_if_not_installed("bit64")
  isolated <- new.env(parent = asNamespace("stats"))
  for (name in c("PlotRank", ".pr_parse", ".pr_single", ".pr_facet")) {
    fn <- get(name, environment(PlotRank))
    environment(fn) <- isolated
    assign(name, fn, envir = isolated)
  }
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  scores <- haven::labelled_spss(c(1, 99, 2, NA), na_values = 99)
  names(scores) <- letters[1:4]
  saveRDS(list(functions = as.list(isolated), scores = scores, libs = .libPaths(),
               integer64 = stats::setNames(bit64::as.integer64(1:3), letters[1:3])), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)",
    "fixture <- readRDS(args[[1]])",
    ".libPaths(fixture[['libs']])",
    "stopifnot(!any(c('haven', 'bit64') %in% loadedNamespaces()))",
    "list2env(fixture[['functions']], .GlobalEnv)",
    "error <- tryCatch(PlotRank(fixture[['integer64']], return_type = 'data'), error = conditionMessage)",
    "stopifnot(is.character(error), grepl('integer64.*not supported', error), !'bit64' %in% loadedNamespaces())",
    "result <- PlotRank(fixture[['scores']], top_n = 1, return_type = 'data')",
    "saveRDS(list(labels = result[['Label']], top = result[['Label']][result[['IsTop']]]), args[[2]])"
  ), script)
  status <- system2(file.path(R.home("bin"), "Rscript"),
                     c("--vanilla", shQuote(script), shQuote(fixture), shQuote(output)),
                     stdout = TRUE, stderr = TRUE)
  expect_null(attr(status, "status"), info = paste(status, collapse = "\n"))
  if (is.null(attr(status, "status"))) {
    expect_identical(readRDS(output), list(labels = c("c", "a"), top = "c"))
  }
})

test_that("PlotRank skips empty factor levels and entirely missing groups", {
  data <- data.frame(cell_type = factor(rep(c("A", "B"), each = 3), levels = c("A", "B", "unused")),
                     gene = letters[1:6], importance = c(3, 1, 2, NA, NA, NA))
  original <- data
  for (scale in c("none", "group", "top_n")) {
    result <- PlotRank(data, value_scale = scale, return_type = "data")
    control <- PlotRank(droplevels(data[1:3, ]), value_scale = scale, return_type = "data")
    expect_identical(result, control)
    expect_identical(levels(result$Group), "A")
  }
  matrix <- matrix(c(3, 1, 2, NA, NA, NA), 3, dimnames = list(letters[1:3], c("A", "B")))
  result <- PlotRank(matrix, return_type = "data")
  expect_equal(nrow(result), 3L)
  expect_identical(levels(result$Group), "A")
  expect_identical(data, original)
})

test_that("PlotRank reports a clear error when no valid scores remain", {
  inputs <- list(stats::setNames(numeric(), character()),
                 stats::setNames(c(NA_real_, NaN), c("a", "b")),
                 data.frame(gene = character(), importance = numeric()),
                 data.frame(gene = c("a", "b"), importance = c(NA, NA)))
  for (data in inputs) expect_error(PlotRank(data, return_type = "data"), "No valid scores")
  data <- data.frame(cell_type = c("A", "B"), gene = c("a", "b"), importance = c(1, NA))
  expect_error(PlotRank(data, group_levels = "B", return_type = "data"), "No valid scores")
})

test_that("PlotRank validates top_n before ranking", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  invalid <- list(1.5, -1, NA_real_, NaN, Inf, -Inf, numeric(), c(1, 2),
                  NULL, "2", TRUE, 1 + 1i, list(1), as.raw(1), factor(1),
                  matrix(1, 1, 1), array(1, 1), structure(1, class = "count"))
  for (value in invalid) {
    error <- tryCatch(PlotRank(scores, top_n = value, return_type = "data"),
                       error = identity)
    expect_s3_class(error, "error")
    if (inherits(error, "error")) {
      expect_match(conditionMessage(error), "`top_n`.*finite.*non-negative integer")
      expect_null(conditionCall(error))
    }
  }
})

test_that("PlotRank validates max_show before selecting rows", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  invalid <- list(2.5, .5, 0, -1, NA_real_, NaN, Inf, -Inf, numeric(), c(1, 2),
                  NULL, "2", TRUE, 1 + 1i, list(1), as.raw(1), factor(1),
                  matrix(1, 1, 1), array(1, 1), structure(1, class = "count"))
  for (value in invalid) {
    error <- tryCatch(PlotRank(scores, max_show = value, return_type = "data"),
                       error = identity)
    expect_s3_class(error, "error")
    if (inherits(error, "error")) {
      expect_match(conditionMessage(error), "`max_show`.*finite.*positive integer")
      expect_null(conditionCall(error))
    }
  }
})

test_that("PlotRank validates ncol for single and faceted inputs", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  grouped <- matrix(1:6, 3, dimnames = list(letters[1:3], c("A", "B")))
  invalid <- list(1.5, 0, -1, NA_real_, NaN, Inf, -Inf, numeric(), c(1, 2),
                  "2", TRUE, 1 + 1i, list(1), as.raw(1), factor(1),
                  matrix(1, 1, 1), array(1, 1), structure(1, class = "count"))
  for (data in list(scores, grouped)) {
    for (value in invalid) {
      error <- tryCatch(PlotRank(data, ncol = value, return_type = "data"),
                         error = identity)
      expect_s3_class(error, "error")
      if (inherits(error, "error")) {
        expect_match(conditionMessage(error), "`ncol`.*finite.*positive integer")
        expect_null(conditionCall(error))
      }
    }
  }
})

test_that("PlotRank rejects ncol beyond the facet whole-number range", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  grouped <- matrix(1:6, 3, dimnames = list(letters[1:3], c("A", "B")))
  for (data in list(scores, grouped)) {
    for (value in c(2^53, .Machine$double.xmax)) {
      error <- tryCatch(PlotRank(data, ncol = value, return_type = "data"),
                         error = identity)
      expect_s3_class(error, "error")
      if (inherits(error, "error")) {
        expect_match(conditionMessage(error), "`ncol`.*supported whole-number range")
        expect_null(conditionCall(error))
      }
    }
  }
})

test_that("PlotRank keeps valid count boundaries without integer overflow", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  all <- PlotRank(scores, top_n = .Machine$double.xmax,
                   max_show = .Machine$double.xmax, return_type = "data")
  expect_identical(all$Rank, 1:3)
  expect_identical(all$Label, letters[1:3])
  expect_identical(all$IsTop, rep(TRUE, 3))

  grouped <- matrix(c(5, 3, 1, 6, 4, 2), 3,
                     dimnames = list(letters[1:3], c("A", "B")))
  first <- PlotRank(grouped, top_n = 0, max_show = 1, return_type = "both")
  expect_identical(first$data$Rank, c(1L, 1L))
  expect_identical(first$data$Label, c("a", "a"))
  expect_identical(first$data$Score, c(5, 6))
  expect_identical(first$data$IsTop, c(FALSE, FALSE))
  expect_equal(nrow(ggplot2::ggplot_build(first$plot)$data[[2]]), 0L)
  for (value in c(2^31, 2^52)) {
    plot <- PlotRank(grouped, ncol = value)
    expect_identical(ggplot2::ggplot_build(plot)$layout$layout$COL, c(1L, 2L))
  }
})

test_that("PlotRank keeps count semantics across every return path", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  grouped <- matrix(c(5, 3, 1, 6, 4, 2), 3,
                     dimnames = list(letters[1:3], c("A", "B")))
  long <- data.frame(cell_type = rep(c("A", "B"), each = 3),
                      gene = rep(letters[1:3], 2), importance = c(5, 3, 1, 6, 4, 2))
  for (data in list(scores, grouped, long)) {
    original <- data
    single <- is.numeric(data) && is.null(dim(data))
    groups <- if (single) "All" else c("A", "B")
    expected_scores <- if (single) c(5, 3) else c(5, 3, 6, 4)
    for (top in 0:1) {
      ranked <- PlotRank(data, top_n = top, max_show = 2, ncol = NULL,
                          return_type = "data")
      expect_identical(names(ranked), c("Group", "Rank", "Score", "Label", "IsTop"))
      expect_identical(ranked$Group, factor(rep(groups, each = 2), levels = groups))
      expect_identical(ranked$Rank, rep(1:2, length(groups)))
      expect_identical(ranked$Score, expected_scores)
      expect_identical(ranked$Label, rep(c("a", "b"), length(groups)))
      expect_identical(ranked$IsTop, rep(c(top == 1L, FALSE), length(groups)))
      plot <- PlotRank(data, top_n = top, max_show = 2, ncol = NULL)
      both <- PlotRank(data, top_n = top, max_show = 2, ncol = NULL,
                        return_type = "both")
      expect_identical(names(both), c("plot", "data"))
      expect_identical(both$data, ranked)
      for (p in list(plot, both$plot)) {
        expect_s3_class(p, "ggplot")
        built <- ggplot2::ggplot_build(p)
        expect_identical(built$data[[1]]$y, expected_scores)
        expect_equal(built$data[[1]]$x, rep(1:2, length(groups)))
        expected_colors <- if (top == 0L) rep("#BECEE3", 2) else c("#007D9B", "#BECEE3")
        expect_identical(built$data[[1]]$colour, rep(expected_colors, length(groups)))
        expect_equal(nrow(built$data[[2]]), top * length(groups))
        if (top == 1L) expect_identical(built$data[[2]]$label, rep("a", length(groups)))
      }
    }
    expect_identical(data, original)
  }
})

test_that("PlotRank rejects invalid counts before saving on every return path", {
  scores <- stats::setNames(c(5, 3, 1), letters[1:3])
  grouped <- matrix(1:6, 3, dimnames = list(letters[1:3], c("A", "B")))
  filename <- withr::local_tempfile(fileext = ".pdf")
  for (data in list(scores, grouped)) {
    for (return_type in c("plot", "data", "both")) {
      for (argument in c("top_n", "max_show", "ncol")) {
        args <- list(data = data, return_type = return_type, filename = filename)
        args[[argument]] <- 1.5
        error <- tryCatch(do.call(PlotRank, args), error = identity)
        expect_s3_class(error, "error")
        if (inherits(error, "error")) {
          expect_match(conditionMessage(error), paste0("`", argument, "`.*integer"))
          expect_null(conditionCall(error))
        }
        expect_length(Sys.glob(filename), 0L)
      }
    }
  }
})

test_that("rank data returns avoid constructing unused plots", {
  local_mocked_bindings(
    .pr_single = function(...) stop("unused plot constructed"),
    .pr_facet = function(...) stop("unused plot constructed"))
  scores <- c(a = 3, b = 1, c = 2)
  for (data in list(scores, cbind(A = scores, B = scores * 2))) {
    result <- PlotRank(data, return_type = "data", clean_names = FALSE)
    expect_equal(result$Rank, rep(1:3, length.out = nrow(result)))
    expect_equal(result$Label, rep(c("a", "c", "b"), length.out = nrow(result)))
  }
})
