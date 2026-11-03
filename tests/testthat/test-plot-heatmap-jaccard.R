jaccard_payload_plot <- function(include_payload) {
  data <- data.frame(cell_type = c("A", "A", "B", "B"), gene = c("a", "b", "b", "c"))
  if (include_payload) data$unused <- I(lapply(1:4, function(i) as.raw((seq_len(250000) + i) %% 256)))
  PlotHeatmapJaccard(data, return_type = "both")
}

test_that("Jaccard pure data returns avoid plotting while requested files are saved", {
  data <- data.frame(cell_type = c("A", "A", "B", "B"), gene = c("a", "b", "b", "c"))
  calls <- 0L
  original <- get(".build_jaccard_plot", environment(PlotHeatmapJaccard))
  testthat::local_mocked_bindings(.build_jaccard_plot = function(...) {
    calls <<- calls + 1L
    original(...)
  }, .package = "UtilsR")
  matrix <- PlotHeatmapJaccard(data, return_type = "data")
  expect_identical(calls, 0L)
  file <- withr::local_tempfile(fileext = ".pdf")
  saved <- suppressMessages(PlotHeatmapJaccard(data, return_type = "data", filename = file))
  expect_identical(saved, matrix)
  expect_identical(calls, 1L)
  expect_gt(file.info(file)$size, 0)
})

test_that("cached Jaccard sets retain original overlap and empty-set definitions", {
  reference <- function(data, groups) {
    sets <- lapply(groups, function(g) data$gene[which(data$cell_type == g & !is.na(data$gene))])
    result <- matrix(0, length(groups), length(groups), dimnames = list(groups, groups))
    for (i in seq_along(groups)) for (j in seq_len(i)) {
      n_union <- length(union(sets[[i]], sets[[j]]))
      result[i, j] <- if (n_union > 0) length(intersect(sets[[i]], sets[[j]])) / n_union else 0
      result[j, i] <- result[i, j]
    }
    result
  }
  for (features in list(c("x", "x", "y", "y", NA), c(1, 1, 2, 2, NA_real_),
                         factor(c("x", "x", "y", "y", NA), levels = c("x", "y", "unused")),
                         as.Date(c(1, 1, 2, 2, NA_real_), origin = "1970-01-01"))) {
    data <- data.frame(cell_type = factor(c("A", "A", "A", "B", "B"), levels = c("B", "A", "empty")),
                       gene = features)
    before <- data
    for (groups in list(levels(data$cell_type), c("A", "empty", "B"))) {
      actual <- PlotHeatmapJaccard(data, group_levels = groups, return_type = "data")
      expect_identical(actual, reference(data, groups))
    }
    expect_identical(data, before)
  }
})

test_that("Jaccard plots do not retain unselected input payloads", {
  full <- jaccard_payload_plot(TRUE)
  selected <- jaccard_payload_plot(FALSE)
  expect_identical(full$matrix, selected$matrix)
  expect_identical(ggplot2::ggplot_build(full$plot)$data, ggplot2::ggplot_build(selected$plot)$data)
  files <- c(withr::local_tempfile(), withr::local_tempfile())
  saveRDS(full$plot, files[1], compress = FALSE)
  saveRDS(selected$plot, files[2], compress = FALSE)
  expect_lt(abs(diff(file.info(files)$size)), 65536)
  skip_if_not_installed("lobstr")
  expect_lt(abs(as.numeric(lobstr::obj_size(full$plot)) - as.numeric(lobstr::obj_size(selected$plot))), 65536)
})

test_that("Jaccard interprets SPSS missingness before cold set construction", {
  skip_if_not_installed("haven")
  fn <- PlotHeatmapJaccard
  isolated <- new.env(parent = asNamespace("stats"))
  builder <- get(".build_jaccard_plot", environment(PlotHeatmapJaccard))
  environment(builder) <- isolated
  isolated$.build_jaccard_plot <- builder
  environment(fn) <- isolated
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  data <- list(
    features = data.frame(cell_type = c("A", "A", "B", "B"),
      gene = haven::labelled_spss(c(1, 99, 2, 99), na_values = 99)),
    groups = data.frame(cell_type = haven::labelled_spss(c(1, 2, 99), na_values = 99),
      gene = c("a", "b", "orphan")))
  saveRDS(list(fn = fn, data = data, libs = .libPaths()), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)", "fixture <- readRDS(args[[1]])", ".libPaths(fixture[['libs']])",
    "stopifnot(!'haven' %in% loadedNamespaces())",
    "data <- fixture[['data']][[args[[3]]]]", "before <- data",
    "out <- fixture[['fn']](data, return_type = 'data')",
    "saveRDS(list(value = out, unchanged = identical(data, before)), args[[2]])"
  ), script)
  for (mode in names(data)) {
    status <- system2(file.path(R.home("bin"), "Rscript"),
      c("--vanilla", shQuote(script), shQuote(fixture), shQuote(output), mode), stdout = TRUE, stderr = TRUE)
    expect_null(attr(status, "status"), info = paste(status, collapse = "\n"))
    if (is.null(attr(status, "status"))) {
      out <- readRDS(output)
      expected <- diag(2)
      dimnames(expected) <- if (mode == "features") list(c("A", "B"), c("A", "B")) else
        list(c("1", "2"), c("1", "2"))
      expect_identical(out$value, expected)
      expect_identical(out$unchanged, TRUE)
    }
  }
})

test_that("missing group labels do not create groups or shared features", {
  dat <- data.frame(cell_type = c("A", "B", NA), gene = c("a", "b", "orphan"))
  result <- PlotHeatmapJaccard(dat, return_type = "both")
  expected <- diag(2)
  dimnames(expected) <- list(c("A", "B"), c("A", "B"))
  expect_identical(result$matrix, expected)
  expect_s3_class(ggplot2::ggplot_build(result$plot), "ggplot_built")
})

test_that("missing feature names do not count as a shared feature", {
  dat <- data.frame(cell_type = c("A", "A", "B", "B"),
                    gene = c("a", NA, "b", NA))
  result <- PlotHeatmapJaccard(dat, return_type = "data")
  expect_equal(result["A", "B"], 0)
  expect_equal(diag(result), c(A = 1, B = 1))
  dat$gene[dat$cell_type == "A"] <- NA_character_
  result <- PlotHeatmapJaccard(dat, return_type = "data")
  expect_equal(result["A", "A"], 0)
  expect_equal(result["A", "B"], 0)
})

test_that("group order, duplicate features, and empty-set convention are retained", {
  dat <- data.frame(cell_type = factor(c("A", "A", "A", "B"),
                                      levels = c("B", "A", "empty")),
                    gene = c("a", "b", "a", "b"))
  result <- PlotHeatmapJaccard(dat, return_type = "data")
  expect_identical(rownames(result), c("B", "A", "empty"))
  expect_equal(result["A", "B"], 0.5)
  expect_equal(result["empty", ], c(B = 0, A = 0, empty = 0))
  reversed <- PlotHeatmapJaccard(dat, group_levels = c("A", "B"), return_type = "data")
  expect_identical(rownames(reversed), c("A", "B"))
  expect_equal(unname(reversed), unname(result[c("A", "B"), c("A", "B")]))
})

test_that("duplicate group levels fail consistently across return and save paths", {
  dat <- data.frame(cell_type = c("A", "B"), gene = c("a", "b"))
  for (groups in list(c("A", "A"), c("A", NA, "B", "A"),
                      c("A", "unobserved", "unobserved"))) {
    for (type in c("plot", "data", "both")) {
      path <- withr::local_tempfile(fileext = ".pdf")
      for (filename in list(NULL, path)) {
        expect_error(
          PlotHeatmapJaccard(dat, group_levels = groups, return_type = type,
                             filename = filename),
          "group_levels.*duplicate"
        )
      }
      expect_identical(file.exists(path), FALSE)
    }
  }
})

test_that("explicit group levels ignore missing labels and retain empty groups", {
  dat <- data.frame(cell_type = c("A", "A", "B", NA),
                    gene = c("a", "b", NA, "orphan"))
  groups <- c("unobserved", "B", "A")
  expected <- rbind(c(0, 0, 0), c(0, 0, 0), c(0, 0, 1))
  dimnames(expected) <- list(groups, groups)
  for (order in list(groups, c(NA, "unobserved", "B", NA, "A", NA))) {
    result <- PlotHeatmapJaccard(dat, group_levels = order, return_type = "both")
    expect_identical(result$matrix, expected)
    expect_identical(levels(result$plot$data$Group1), groups)
    expect_identical(levels(result$plot$data$Group2), groups)
    expect_s3_class(ggplot2::ggplot_build(result$plot), "ggplot_built")
  }
  empty <- PlotHeatmapJaccard(dat[FALSE, ], group_levels = groups, return_type = "data")
  expect_identical(empty, matrix(0, 3, 3, dimnames = list(groups, groups)))
})

test_that("a saved heatmap is announced with its size and the file state", {
  dat <- data.frame(cell_type = c("A", "A", "B"), gene = c("a", "b", "b"))
  path <- withr::local_tempfile(fileext = ".pdf")
  saved <- function() {
    out <- cli::cli_fmt(PlotHeatmapJaccard(dat, filename = path))
    gsub("\\s+", " ", paste(cli::ansi_strip(out), collapse = " "))
  }
  first <- saved()
  expect_match(first, "PlotHeatmapJaccard: the plot has been saved to:", fixed = TRUE)
  expect_match(first, "[10x9 in, new PDF]", fixed = TRUE)
  expect_match(saved(), "[10x9 in, replaced the existing PDF]", fixed = TRUE)
})

test_that("data without non-missing groups fails clearly", {
  dat <- data.frame(cell_type = NA_character_, gene = "orphan")
  expect_error(PlotHeatmapJaccard(dat), "No non-missing groups")
  expect_error(PlotHeatmapJaccard(dat[FALSE, ]), "No non-missing groups")
})

test_that("the complete similarity matrix retains symmetric and empty-set results", {
  groups <- c("A", "B", "C", "empty")
  dat <- data.frame(cell_type = factor(c("A", "A", "B", "B", "C"), levels = groups),
                    gene = c("g1", "g2", "g2", "g3", "g4"))
  expected <- rbind(c(1, 1/3, 0, 0), c(1/3, 1, 0, 0), c(0, 0, 1, 0), c(0, 0, 0, 0))
  dimnames(expected) <- list(groups, groups)
  result <- PlotHeatmapJaccard(dat, return_type = "both")
  expect_identical(result$matrix, expected)
  expect_true(all(is.na(result$plot$data$Jaccard[result$plot$data$Group1 ==
                                                result$plot$data$Group2])))
})

test_that("axis strips keep valid colours beyond the default palette length", {
  dat <- data.frame(cell_type = sprintf("G%02d", 1:17), gene = paste0("gene", 1:17))
  plot <- PlotHeatmapJaccard(dat, show_strip = TRUE, text_size = 0)
  layers <- ggplot2::ggplot_build(plot)$data
  bottom <- layers[[2L]]$fill
  left <- layers[[3L]]$fill
  expect_length(bottom, 17)
  expect_false(anyNA(bottom))
  expect_identical(left, bottom)
  expect_identical(bottom[c(1L, 16L)], c("#E41A1C", "#B3B3B3"))
  expect_identical(bottom[17L], bottom[1L])
  expect_s3_class(ggplot2::ggplotGrob(plot), "gtable")

  custom <- PlotHeatmapJaccard(dat, show_strip = TRUE, text_size = 0,
                              strip_colors = c("red", "blue"))
  expect_identical(ggplot2::ggplot_build(custom)$data[[2L]]$fill,
                   rep_len(c("red", "blue"), 17))
})
