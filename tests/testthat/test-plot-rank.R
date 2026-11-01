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
