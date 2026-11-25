jaccard_payload_plot <- function(include_payload) {
  data <- data.frame(cell_type = c("A", "A", "B", "B"), gene = c("a", "b", "b", "c"))
  if (include_payload) data$unused <- I(lapply(1:4, function(i) as.raw((seq_len(250000) + i) %% 256)))
  PlotHeatmapJaccard(data, return_type = "both")
}

jaccard_cold_call <- function(data, group_levels = NULL, namespace) {
  fn <- PlotHeatmapJaccard
  environment(fn) <- new.env(parent = asNamespace("stats"))
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  saveRDS(list(fn = fn, data = data, group_levels = group_levels,
               namespace = namespace, libs = .libPaths()), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)", "fixture <- readRDS(args[[1]])", ".libPaths(fixture[['libs']])",
    "stopifnot(!fixture[['namespace']] %in% loadedNamespaces())",
    "data <- fixture[['data']]; groups <- fixture[['group_levels']]",
    "before <- data; groups_before <- groups",
    "value <- fixture[['fn']](data, group_levels = groups, return_type = 'data')",
    "saveRDS(list(value = value, unchanged = identical(data, before) && identical(groups, groups_before)), args[[2]])"
  ), script)
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script), shQuote(fixture), shQuote(output)), stdout = TRUE, stderr = TRUE)
  list(status = attr(status, "status"), output = status,
       result = if (is.null(attr(status, "status"))) readRDS(output) else NULL)
}

jaccard_timespans <- function(values) {
  start <- as.POSIXct("2000-01-01", tz = "UTC") + values * 60
  list(period = lubridate::period(month = values),
       calendar_period = lubridate::period(year = ifelse(values == 1, 1, 0),
         month = ifelse(values == 2, 12, 0), day = ifelse(values == 3, 1, 0)),
       duration = lubridate::duration(values),
       interval = lubridate::interval(start, start + 30))
}

test_that("Jaccard memberships reject dimensional columns and group orders", {
  d <- data.frame(cell_type = rep(c("A", "B"), each = 2), gene = c("x", "y", "x", "z"))
  for (col in names(d)) {
    bad <- d
    bad[[col]] <- cbind(d[[col]], rev(d[[col]]))
    expect_error(PlotHeatmapJaccard(bad, return_type = "data"), paste0(col, ".*one-dimensional"))
  }
  expect_error(PlotHeatmapJaccard(d, group_levels = matrix(c("A", "B")), return_type = "data"), "group_levels")
  expected <- matrix(c(1, 1/3, 1/3, 1), 2, dimnames = list(c("A", "B"), c("A", "B")))
  expect_identical(PlotHeatmapJaccard(d, return_type = "data"), expected)
})

test_that("Jaccard strips use only the colours needed for displayed groups", {
  d <- data.frame(cell_type = c("A", "B"), gene = c("x", "y"))
  result <- PlotHeatmapJaccard(d, show_strip = TRUE,
    strip_colors = c("red", "blue", "green"), return_type = "both")
  built <- ggplot2::ggplot_build(result$plot)
  expect_identical(built$data[[3]]$fill, c("red", "blue"))
  expect_identical(built$data[[4]]$fill, c("red", "blue"))
  expect_identical(result$matrix, PlotHeatmapJaccard(d, return_type = "data"))
})

test_that("Jaccard strips reject empty and malformed active palettes", {
  d <- data.frame(cell_type = c("A", "B"), gene = c("x", "y"))
  for (bad in list(character(), matrix("red"), "not-a-colour"))
    expect_error(PlotHeatmapJaccard(d, show_strip = TRUE, strip_colors = bad), "strip_colors")
  for (arg in c("low_color", "high_color")) {
    args <- list(data = d)
    args[[arg]] <- matrix("red")
    expect_error(do.call("PlotHeatmapJaccard", args), arg)
  }
  p <- PlotHeatmapJaccard(d, show_strip = TRUE, strip_colors = "red")
  built <- ggplot2::ggplot_build(p)
  expect_identical(built$data[[3]]$fill, rep("red", 2))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
  expect_type(PlotHeatmapJaccard(d, return_type = "data",
    strip_colors = stop("unused")), "double")
})

test_that("Jaccard column selectors reject dimensional storage on matrix returns", {
  d <- data.frame(cell_type = c("A", "B"), gene = c("x", "y"))
  for (arg in c("group_col", "name_col")) {
    args <- list(data = d, return_type = "data")
    args[[arg]] <- matrix(if (arg == "group_col") "cell_type" else "gene")
    expect_error(do.call("PlotHeatmapJaccard", args), arg)
  }
  expected <- diag(2)
  dimnames(expected) <- list(c("A", "B"), c("A", "B"))
  expect_identical(PlotHeatmapJaccard(d, return_type = "data"), expected)
})

test_that("Jaccard matrices reject ambiguous source columns", {
  d <- data.frame(cell_type = c("A", "B"), gene = c("x", "y"),
    gene = c("y", "z"), check.names = FALSE)
  expect_error(PlotHeatmapJaccard(d, return_type = "data"), "unique.*column names")
})

test_that("Jaccard plot controls fail clearly without affecting pure matrix returns", {
  data <- data.frame(cell_type = c("A", "B"), gene = c("g1", "g2"))
  for (arg in c("show_diag", "show_strip")) {
    for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
      args <- list(data = data)
      args[arg] <- list(bad)
      expect_error(do.call(PlotHeatmapJaccard, args), arg)
    }
  }
  for (arg in c("midpoint", "text_size", "strip_size")) {
    for (bad in list(NA_real_, Inf, numeric(), matrix(1))) {
      args <- list(data = data, show_strip = TRUE)
      args[arg] <- list(bad)
      expect_error(do.call(PlotHeatmapJaccard, args), arg)
    }
  }
  expect_identical(PlotHeatmapJaccard(data, return_type = "data", show_diag = stop("style evaluated")),
                   matrix(c(1, 0, 0, 1), 2L, dimnames = list(c("A", "B"), c("A", "B"))))
})

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
    "explicit <- if (args[[3]] == 'groups') fixture[['fn']](data, group_levels = c('1', '99', '2'), return_type = 'data') else NULL",
    "saveRDS(list(value = out, explicit = explicit, unchanged = identical(data, before)), args[[2]])"
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
      if (mode == "groups") {
        expected_explicit <- diag(c(1, 0, 1))
        dimnames(expected_explicit) <- list(c("1", "99", "2"), c("1", "99", "2"))
        expect_identical(out$explicit, expected_explicit)
      }
    }
  }
})

test_that("explicit labelled group levels exclude SPSS missing codes", {
  skip_if_not_installed("haven")
  for (groups in list(
    haven::labelled_spss(c(1, 2, 99, 98), na_values = c(98, 99)),
    haven::labelled_spss(c(1, 2, 99, 98), na_range = c(98, 99))
  )) {
    dat <- data.frame(cell_type = groups, gene = c("a", "b", "orphan1", "orphan2"))
    before <- dat
    order <- c(1, 99, 2, 98)
    expected <- diag(c(1, 0, 1, 0))
    dimnames(expected) <- list(as.character(order), as.character(order))
    for (levels in list(order, as.character(order))) {
      result <- PlotHeatmapJaccard(dat, group_levels = levels, return_type = "both")
      expect_identical(result$matrix, expected)
      expect_s3_class(ggplot2::ggplot_build(result$plot), "ggplot_built")
    }
    expect_identical(dat, before)
  }
})

test_that("classed group labels preserve matrix names and tile positions", {
  for (groups in list(
    as.Date(c(1, 2, 1), origin = "1970-01-01"),
    as.POSIXct(c(1, 2, 1), origin = "1970-01-01", tz = "UTC"),
    as.POSIXlt(as.POSIXct(c(1, 2, 1), origin = "1970-01-01", tz = "UTC")),
    as.difftime(c(1, 2, 1), units = "hours"),
    c(0.1234567890123456, 0.2345678901234567, 0.1234567890123456)
  )) {
    dat <- data.frame(gene = c("a", "b", "b"))
    dat$cell_type <- groups
    before <- dat
    labels <- as.character(groups[1:2])
    expected <- rbind(c(1, 0.5), c(0.5, 1))
    dimnames(expected) <- list(labels, labels)
    result <- PlotHeatmapJaccard(dat, return_type = "both")
    expect_identical(result$matrix, expected)
    tiles <- ggplot2::ggplot_build(result$plot)$data[[1L]]
    expect_identical(as.numeric(tiles$x), c(1, 2, 1, 2))
    expect_identical(as.numeric(tiles$y), c(1, 1, 2, 2))
    expect_identical(dat, before)
  }
})

test_that("repeated explicit group levels fail before every return path", {
  dat <- data.frame(cell_type = 1:2, gene = c("a", "b"))
  for (type in c("data", "plot", "both")) {
    expect_error(PlotHeatmapJaccard(dat, group_levels = c(1, 1), return_type = type),
      "group_levels.*duplicate")
  }
})

test_that("integer64 groups and features retain missingness in a cold session", {
  skip_if_not_installed("bit64")
  fn <- PlotHeatmapJaccard
  environment(fn) <- new.env(parent = asNamespace("stats"))
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  values <- c("9007199254740992", "9007199254740993")
  data <- list(
    features = data.frame(cell_type = c("A", "A", "B", "B"),
      gene = bit64::as.integer64(c(values[1L], NA, values[2L], NA))),
    groups = data.frame(cell_type = bit64::as.integer64(c(values, NA)),
      gene = c("a", "b", "orphan")))
  saveRDS(list(fn = fn, data = data, libs = .libPaths()), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)", "fixture <- readRDS(args[[1]])", ".libPaths(fixture[['libs']])",
    "stopifnot(!'bit64' %in% loadedNamespaces())",
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
      labels <- if (mode == "features") c("A", "B") else values
      expected <- diag(2)
      dimnames(expected) <- list(labels, labels)
      expect_identical(out$value, expected)
      expect_identical(out$unchanged, TRUE)
    }
  }
})

test_that("labelled group_levels load their namespace in a cold session", {
  skip_if_not_installed("haven")
  dat <- data.frame(cell_type = c(1, 2), gene = c("a", "b"))
  groups <- haven::labelled_spss(c(1, 99, 2), na_values = 99)
  out <- jaccard_cold_call(dat, groups, "haven")
  expect_null(out$status, info = paste(out$output, collapse = "\n"))
  if (is.null(out$status)) {
    expected <- diag(2)
    dimnames(expected) <- list(c("1", "2"), c("1", "2"))
    expect_identical(out$result$value, expected)
    expect_identical(out$result$unchanged, TRUE)
  }
})

test_that("integer64 group_levels load their namespace in a cold session", {
  skip_if_not_installed("bit64")
  values <- c("9007199254740992", "9007199254740993")
  dat <- data.frame(cell_type = values, gene = c("a", "b"))
  out <- jaccard_cold_call(dat, bit64::as.integer64(c(values[2L], NA, values[1L])), "bit64")
  expect_null(out$status, info = paste(out$output, collapse = "\n"))
  if (is.null(out$status)) {
    expected <- diag(2)
    dimnames(expected) <- list(rev(values), rev(values))
    expect_identical(out$result$value, expected)
    expect_identical(out$result$unchanged, TRUE)
  }
})

test_that("time span group_levels load their namespace in a cold session", {
  skip_if_not_installed("lubridate")
  for (groups in jaccard_timespans(c(1, 2))) {
    labels <- as.character(groups)
    dat <- data.frame(cell_type = labels, gene = c("a", "b"))
    out <- jaccard_cold_call(dat, groups[c(2L, NA_integer_, 1L)], "lubridate")
    expect_null(out$status, info = paste(out$output, collapse = "\n"))
    if (is.null(out$status)) {
      expected <- diag(2)
      dimnames(expected) <- list(rev(labels), rev(labels))
      expect_identical(out$result$value, expected)
      expect_identical(out$result$unchanged, TRUE)
    }
  }
})

test_that("time span features retain all value components and ignore names", {
  skip_if_not_installed("lubridate")
  for (features in jaccard_timespans(c(1, 2, 2, 2, 3, NA))) {
    names(features) <- paste0("row", seq_along(features))
    dat <- data.frame(cell_type = c("A", "A", "A", "B", "B", "B"))
    dat$gene <- features
    before <- dat
    expected <- rbind(c(1, 1/3), c(1/3, 1))
    dimnames(expected) <- list(c("A", "B"), c("A", "B"))
    result <- PlotHeatmapJaccard(dat, return_type = "both")
    expect_identical(result$matrix, expected)
    expect_s3_class(ggplot2::ggplot_build(result$plot), "ggplot_built")
    expect_identical(dat, before)
    with_empty <- rbind(c(0, 0, 0), c(0, 1, 1/3), c(0, 1/3, 1))
    dimnames(with_empty) <- list(c("empty", "B", "A"), c("empty", "B", "A"))
    expect_identical(PlotHeatmapJaccard(dat, group_levels = c("empty", "B", "A"),
                                      return_type = "data"), with_empty)
    all_missing <- dat
    all_missing$gene <- features[rep(NA_integer_, length(features))]
    expect_identical(PlotHeatmapJaccard(all_missing, return_type = "data"),
                     matrix(0, 2, 2, dimnames = list(c("A", "B"), c("A", "B"))))
    expect_identical(PlotHeatmapJaccard(dat[FALSE, ], group_levels = c("A", "B"),
                                      return_type = "data"),
                     matrix(0, 2, 2, dimnames = list(c("A", "B"), c("A", "B"))))
  }
})

test_that("time span groups retain full keys with typed and character orders", {
  skip_if_not_installed("lubridate")
  for (groups in jaccard_timespans(c(1, 2, 1, NA))) {
    dat <- data.frame(gene = c("a", "b", "b", "orphan"))
    dat$cell_type <- groups
    before <- dat
    labels <- as.character(groups[1:2])
    expected <- rbind(c(1, 0.5), c(0.5, 1))
    dimnames(expected) <- list(labels, labels)
    expect_identical(PlotHeatmapJaccard(dat, return_type = "data"), expected)
    for (order in list(groups[2:1], rev(labels))) {
      result <- PlotHeatmapJaccard(dat, group_levels = order, return_type = "both")
      expect_identical(result$matrix, expected[2:1, 2:1])
      tiles <- ggplot2::ggplot_build(result$plot)$data[[1L]]
      expect_identical(as.numeric(tiles$x), c(1, 2, 1, 2))
    }
    with_empty <- rbind(c(1, 0, 0.5), c(0, 0, 0), c(0.5, 0, 1))
    order <- c(labels[2L], "empty", labels[1L])
    dimnames(with_empty) <- list(order, order)
    expect_identical(PlotHeatmapJaccard(dat, group_levels = order, return_type = "data"),
                     with_empty)
    expect_identical(dat, before)
    expect_identical(PlotHeatmapJaccard(dat[FALSE, ], group_levels = groups[1:2],
                                      return_type = "data"),
                     matrix(0, 2, 2, dimnames = list(labels, labels)))
  }
})

test_that("time span records retain their identity in a cold session", {
  skip_if_not_installed("lubridate")
  for (values in jaccard_timespans(c(1, 2))) {
    labels <- as.character(values)
    data <- list(features = data.frame(cell_type = c("A", "B")),
                 groups = data.frame(gene = c("a", "b")))
    data$features$gene <- values
    data$groups$cell_type <- values
    for (mode in names(data)) {
      out <- jaccard_cold_call(data[[mode]], namespace = "lubridate")
      expect_null(out$status, info = paste(out$output, collapse = "\n"))
      if (is.null(out$status)) {
        expected <- diag(2)
        axis <- if (mode == "features") c("A", "B") else labels
        dimnames(expected) <- list(axis, axis)
        expect_identical(out$result$value, expected)
        expect_identical(out$result$unchanged, TRUE)
      }
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

test_that("empty column selectors cannot silently create empty feature sets", {
  dat <- data.frame(cell_type = c("A", "A", "B"), gene = c("a", "b", "b"))
  for (argument in c("group_col", "name_col")) {
    input <- dat
    names(input)[if (argument == "group_col") 1L else 2L] <- ""
    for (type in c("data", "plot", "both")) {
      args <- list(data = input, group_levels = c("A", "B"), return_type = type)
      args[argument] <- list("")
      expect_error(do.call(PlotHeatmapJaccard, args), paste0(argument, ".*single"))
    }
  }
})

test_that("column selectors reject missing and non-scalar specifications", {
  dat <- data.frame(cell_type = c("A", "A", "B"), gene = c("a", "b", "b"))
  for (argument in c("group_col", "name_col")) {
    for (value in list(NULL, character(), NA_character_, c("cell_type", "gene"),
                        list("cell_type"), quote(cell_type))) {
      args <- list(data = dat, return_type = "data")
      args[argument] <- list(value)
      expect_error(do.call(PlotHeatmapJaccard, args, quote = TRUE), paste0(argument, ".*single"))
    }
  }
})

test_that("valid scalar column selectors retain numeric index compatibility", {
  dat <- data.frame("1" = c("A", "A", "B"), "2" = c("a", "b", "b"), check.names = FALSE)
  expected <- rbind(c(1, 0.5), c(0.5, 1))
  dimnames(expected) <- list(c("A", "B"), c("A", "B"))
  expect_identical(PlotHeatmapJaccard(dat, group_col = c(input = "1"),
                                    name_col = c(input = "2"), return_type = "data"), expected)
  expect_identical(PlotHeatmapJaccard(dat, group_col = 1L, name_col = 2L,
                                    return_type = "data"), expected)
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

test_that("Jaccard feature sets retain negative integer64 identities", {
  skip_if_not_installed("bit64")
  d <- data.frame(cell_type = c("A", "B", "C", "C"))
  d[["gene"]] <- bit64::as.integer64(c("-1", "-2", "-1", "-2"))
  actual <- PlotHeatmapJaccard(d, return_type = "data")
  d[["gene"]] <- as.character(d[["gene"]])
  expected <- PlotHeatmapJaccard(d, return_type = "data")
  expect_identical(actual, expected)
  expect_equal(actual["A", "B"], 0)
  expect_equal(actual["A", "C"], .5)
})

test_that("character Jaccard groups avoid repeated full column scans", {
  fn <- PlotHeatmapJaccard
  e <- new.env(parent = environment(fn))
  examined <- 0L
  e$which <- function(x) {
    examined <<- examined + length(x)
    base::which(x)
  }
  environment(fn) <- e
  d <- data.frame(cell_type = rep(sprintf("G%03d", 1:100), each = 50),
                  gene = rep(letters[1:10], 500))
  groups <- c(rev(unique(d$cell_type)), "absent")
  actual <- fn(d, group_levels = groups, return_type = "data")
  expect_lte(examined, 2L * nrow(d))
  expected <- matrix(1, 101, 101, dimnames = list(groups, groups))
  expected[101, ] <- 0
  expected[, 101] <- 0
  expect_identical(actual, expected)
  d$cell_type <- factor(d$cell_type)
  expect_identical(PlotHeatmapJaccard(d, group_levels = groups, return_type = "data"), expected)
})

test_that("Jaccard sets retain precise POSIXlt feature identities", {
  d <- data.frame(cell_type = c("A", "B", "C", "C", "C"))
  d$gene <- as.POSIXct(c(1, 1 + .Machine$double.eps, 1, 1 + .Machine$double.eps, NA), origin = "1970-01-01", tz = "UTC")
  expected <- PlotHeatmapJaccard(d, return_type = "data")
  d$gene <- as.POSIXlt(d$gene)
  before <- serialize(d, NULL)
  actual <- PlotHeatmapJaccard(d, return_type = "data")
  expect_identical(actual, expected)
  expect_identical(actual["A", "B"], 0)
  expect_identical(actual["A", "C"], .5)
  expect_identical(serialize(d, NULL), before)
})

test_that("Jaccard gradients preserve factor colour labels", {
  d <- data.frame(cell_type = c("A", "B"), gene = c("x", "y"))
  colours <- function(low, high) {
    ggplot2::layer_data(PlotHeatmapJaccard(d, show_diag = TRUE, midpoint = .5,
      low_color = low, high_color = high, text_size = 0))$fill
  }
  for (value in c("red", "#FF000080")) {
    encoded <- factor(value, levels = c("blue", value))
    expect_identical(colours(encoded, "navy"), colours(value, "navy"))
    expect_identical(colours("white", encoded), colours("white", value))
  }
  expect_identical(colours(2, 4), colours(palette()[2], palette()[4]))
})

test_that("Jaccard factor groups use one membership index", {
  d <- data.frame(group = factor(rep(c("A", "B", "C"), each = 50L), levels = c("C", "A", "B", "D")),
    gene = rep(paste0("gene", 1:50), 3L))
  d$gene[100L] <- NA_character_
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  scans <- 0L
  env[["=="]] <- function(x, y) {
    if (is.factor(x) && length(x) == nrow(d)) scans <<- scans + 1L
    base::`==`(x, y)
  }
  environment(fn) <- env
  result <- fn(d, group_col = "group", return_type = "data")
  expect_identical(scans, 0L)
  expect_identical(rownames(result), c("C", "A", "B", "D"))
  expect_equal(result["B", c("C", "A", "D")], c(C = .98, A = .98, D = 0))
  expect_identical(unname(diag(result)), c(1, 1, 1, 0))
})

test_that("Jaccard numeric group membership uses one exact index", {
  d <- data.frame(group = rep(c(.25, 2.5, 30), each = 4L),
    gene = c("a", "b", "b", NA, "a", "c", "c", "a", "a", "d", "d", "a"))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  scans <- 0L
  env[["=="]] <- function(x, y) {
    if (is.double(x) && length(x) == nrow(d) && length(y) == 1L) scans <<- scans + 1L
    base::`==`(x, y)
  }
  environment(fn) <- env
  m <- fn(d, group_col = "group", group_levels = c(30, .25, 2.5, 99), return_type = "data")
  expected <- matrix(0, 4L, 4L)
  expected[1:3, 1:3] <- 1/3
  diag(expected) <- c(1, 1, 1, 0)
  expect_identical(scans, 0L)
  expect_identical(rownames(m), c("30", "0.25", "2.5", "99"))
  expect_equal(unname(m), expected)
  expect_error(fn(d, group_col = "group", group_levels = c(.25, .25, 2.5, 30),
    return_type = "data"), "duplicate")
})

test_that("Jaccard diagonals and empty groups bypass membership scans", {
  d <- data.frame(group = c("A", "A", "B", "B"), gene = c("a", "b", "a", "c"))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  membership_scans <- 0L
  env[["%in%"]] <- function(x, table) {
    if (is.character(x) && all(x %in% c("a", "b", "c"))) membership_scans <<- membership_scans + 1L
    base::`%in%`(x, table)
  }
  environment(fn) <- env
  actual <- fn(d, group_col = "group", group_levels = c("A", "Z", "B"), return_type = "data")
  expect_identical(membership_scans, 1L)
  expect_equal(unname(actual), matrix(c(1, 0, 1/3, 0, 0, 0, 1/3, 0, 1), 3L))
})

test_that("Jaccard heatmaps keep exact close numeric group keys", {
  keys <- c(1, 1 + .Machine$double.eps)
  data <- data.frame(group = rep(keys, each = 2), feature = c("g1", "g2", "g2", "g3"))
  result <- PlotHeatmapJaccard(data, "group", "feature", return_type = "data")
  expect_equal(unname(result), matrix(c(1, 1/3, 1/3, 1), nrow = 2))
  expect_length(unique(rownames(result)), 2L)
  explicit <- PlotHeatmapJaccard(data, "group", "feature", group_levels = rev(keys),
                                return_type = "data")
  expect_identical(rownames(explicit), rev(rownames(result)))
  expect_error(PlotHeatmapJaccard(data, "group", "feature", group_levels = c(1, 1),
                                 return_type = "data"), "duplicate")
})

test_that("Jaccard heatmaps keep the factors created by matrix conversion", {
  build <- .build_jaccard_plot
  environment(build) <- list2env(list(factor = function(x, ...) {
    if (is.factor(x) && length(x) == 9L) stop("refactored the long table")
    base::factor(x, ...)
  }), parent = environment(build))
  groups <- c("Z", "", "A")
  mat <- matrix(c(1, .25, 0, .25, 1, 0, 0, 0, 0), 3L,
                dimnames = list(groups, groups))
  style <- list(show_diag = FALSE, show_strip = FALSE, midpoint = .5, text_size = 2,
                low_color = "white", high_color = "red")
  p <- build(mat, groups, style)
  expect_identical(levels(p$data$Group1), groups)
  expect_identical(levels(p$data$Group2), groups)
  diag(mat) <- NA_real_
  expect_identical(p$data$Jaccard, as.vector(mat))
})

test_that("Jaccard duration keys match across integer and double storage", {
  skip_if_not_installed("lubridate")
  keys <- lubridate::dseconds(1:3)
  data <- tibble::tibble(group = rep(keys, each = 2L), feature = c("a", "b", "b", "c", "d", "e"))
  expected <- PlotHeatmapJaccard(data, "group", "feature", return_type = "data")
  result <- PlotHeatmapJaccard(data, "group", "feature", group_levels = rev(keys), return_type = "data")
  expect_identical(result, expected[3:1, 3:1])
  expect_equal(result[2L, 3L], 1/3)
})

test_that("Jaccard mixed integer64 group keys do not truncate fractions", {
  skip_if_not_installed("bit64")
  i64 <- bit64::as.integer64(c(1, 1, 2, 2))
  d <- data.frame(group = i64, feature = c("a", "b", "b", "c"))
  compare <- function(data, keys) {
    PlotHeatmapJaccard(data, "group", "feature", group_levels = keys, return_type = "data")
  }
  expect_equal(as.vector(compare(d, c(1.5, 2.5, Inf, 2^63))), rep(0, 16L))
  expect_equal(as.vector(compare(d, c(1, 2))), c(1, 1/3, 1/3, 1))
  d$group <- c(1.5, 1, 2.5, 2)
  expect_equal(as.vector(compare(d, bit64::as.integer64(1:2))), c(1, 0, 0, 1))
})

test_that("integer64 Jaccard groups are indexed without repeated equality scans", {
  skip_if_not_installed("bit64")
  keys <- bit64::as.integer64(c("-9007199254740993", "-9007199254740992", "9007199254740993"))
  d <- data.frame(cell_type = rep(keys, each = 2L), gene = c("a", "b", "b", "c", "d", "e"))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["=="]] <- function(x, y) {
    if (inherits(x, "integer64") && length(x) == nrow(d)) stop("rescanned integer64 groups")
    base::`==`(x, y)
  }
  environment(fn) <- env
  m <- fn(d, group_levels = rev(keys), return_type = "data")
  expect_identical(rownames(m), as.character(rev(keys)))
  expect_equal(m[2L, 3L], 1 / 3)
  expect_identical(unname(diag(m)), rep(1, 3L))
  expect_equal(fn(d, return_type = "data"), m[3:1, 3:1])
})

test_that("Jaccard period membership uses one exact index", {
  skip_if_not_installed("lubridate")
  keys <- lubridate::period(months = c(1, 3, 5), days = c(0, 2, 1))
  d <- tibble::tibble(cell_type = rep(keys, each = 2L), gene = c("a", "b", "b", "c", "d", "e"))
  fn <- PlotHeatmapJaccard
  equal <- vctrs::vec_equal
  local_mocked_bindings(vec_equal = function(x, y, ...) {
    if (inherits(x, "Period") && length(x) == nrow(d) && length(y) == 1L) {
      stop("matched each time span group separately")
    }
    equal(x, y, ...)
  }, .package = "vctrs")
  m <- fn(d, group_levels = rev(keys), return_type = "data")
  expect_identical(rownames(m), as.character(rev(keys)))
  expect_equal(m[2L, 3L], 1 / 3)
  expect_equal(m[1L, 2L], 0)
})

test_that("logical Jaccard groups share one row index", {
  d <- data.frame(cell_type = c(FALSE, TRUE, NA, FALSE, TRUE), gene = c("x", "x", "z", "y", "w"))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["=="]] <- function(x, y) {
    if (is.logical(x) && length(x) == nrow(d)) stop("rescanned logical groups")
    base::`==`(x, y)
  }
  environment(fn) <- env
  m <- fn(d, group_levels = c(TRUE, FALSE), return_type = "data")
  expect_identical(rownames(m), c("TRUE", "FALSE"))
  expect_equal(m[1L, 2L], 1 / 3)
})

test_that("labelled Jaccard groups use their underlying codes", {
  skip_if_not_installed("haven")
  d <- data.frame(cell_type = haven::labelled_spss(c(4, 9, 99, 4, 9),
    labels = c(A = 4, B = 9, Missing = 99), na_values = 99),
    gene = c("x", "x", "z", "y", "w"))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["=="]] <- function(x, y) {
    if (is.double(x) && length(x) == nrow(d)) stop("rescanned labelled groups")
    base::`==`(x, y)
  }
  environment(fn) <- env
  m <- fn(d, return_type = "data")
  expect_identical(rownames(m), c("4", "9"))
  expect_equal(m[1L, 2L], 1 / 3)
})

test_that("indexed Jaccard groups avoid expanding scalar keys", {
  d <- data.frame(cell_type = c(5L, 9L, 9L, 5L), gene = c("x", "x", "z", "y"))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env$as.list <- function(x, ...) {
    if (identical(x, c(5L, 9L))) stop("expanded all indexed keys")
    base::as.list(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, return_type = "data"),
    matrix(c(1, 1 / 3, 1 / 3, 1), 2L, dimnames = list(c("5", "9"), c("5", "9"))))
})

test_that("sparse Jaccard intersections compare only shared features", {
  d <- data.frame(cell_type = rep(letters[1:8], each = 100L), gene = seq_len(800L))
  d$gene[seq.int(1L, 800L, by = 100L)] <- 0L
  d$gene[c(2L, 102L)] <- -1L
  expected <- PlotHeatmapJaccard(d, return_type = "data")
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(x, table) {
    if (is.integer(x) && length(x) > 2L) stop("compared globally unique features")
    base::`%in%`(x, table)
  }
  environment(fn) <- env
  result <- fn(d, return_type = "data")
  expect_identical(result, expected)
  expect_equal(result["a", "b"], 2 / 198)
  expect_equal(result["a", "c"], 1 / 199)
})

test_that("Jaccard scalar time groups use one exact row index", {
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["=="]] <- function(x, y) {
    if (inherits(x, c("Date", "POSIXt", "difftime")) && length(x) > 1L) {
      stop("rescanned a scalar time column")
    }
    base::`==`(x, y)
  }
  environment(fn) <- env
  for (keys in list(as.Date(c(1, 2), origin = "1970-01-01"),
                    as.POSIXct(c(1, 2), origin = "1970-01-01", tz = "UTC"),
                    as.difftime(c(1, 2), units = "hours"))) {
    d <- data.frame(cell_type = keys[c(1L, 1L, 2L, 2L, NA)], gene = c("a", "b", "b", "c", "b"))
    labels <- if (inherits(keys, "difftime")) as.difftime(c(120, 60), units = "mins") else rev(keys)
    expect_identical(fn(d, group_levels = labels, return_type = "data"),
      matrix(c(1, 1 / 3, 1 / 3, 1), 2L, dimnames = list(as.character(labels), as.character(labels))))
  }
})

test_that("Jaccard plot cells retain the factor order without converting a table", {
  d <- data.frame(cell_type = c("", "", "B", "C"), gene = c("a", "b", "b", "a"))
  fn <- .build_jaccard_plot
  env <- new.env(parent = environment(fn))
  env$as.table <- function(...) stop("converted the matrix to a table")
  environment(fn) <- env
  local_mocked_bindings(.build_jaccard_plot = fn, .package = "UtilsR")
  for (show in c(TRUE, FALSE)) {
    result <- PlotHeatmapJaccard(d, return_type = "both", show_diag = show)
    m <- result$matrix
    if (!show) diag(m) <- NA_real_
    expected <- as.data.frame(as.table(m))
    names(expected) <- c("Group1", "Group2", "Jaccard")
    expect_identical(result$plot$data, expected)
    expect_identical(unname(diag(result$matrix)), rep(1, 3L))
  }
})

test_that("typed Jaccard intersections skip globally unique feature keys", {
  skip_if_not_installed("bit64")
  d <- data.frame(cell_type = rep(letters[1:6], each = 20L))
  d$gene <- bit64::as.integer64("9007199254740992") + bit64::as.integer64(seq_len(nrow(d)))
  d$gene[seq.int(1L, nrow(d), by = 20L)] <- bit64::as.integer64("9007199254740992")
  d$gene[c(2L, 22L)] <- bit64::as.integer64("-1")
  base_in <- vctrs::vec_in
  testthat::local_mocked_bindings(vec_in = function(needles, haystack, ...) {
    if (is.data.frame(needles) && nrow(needles) > 2L) stop("compared globally unique typed features")
    base_in(needles, haystack, ...)
  }, .package = "vctrs")
  out <- PlotHeatmapJaccard(d, return_type = "data")
  expect_equal(out["a", "b"], 2 / 38)
  expect_equal(out["a", "c"], 1 / 39)
  expect_identical(unname(diag(out)), rep(1, 6L))
})

test_that("Jaccard factor levels map to requested labels without decoding rows", {
  d <- data.frame(cell_type = ordered(rep(c("", "B", "C", NA), 101L),
                   levels = c("unused", "", "B", "C", NA), exclude = NULL),
                  gene = rep(seq_len(101L), each = 4L))
  is.na(d$cell_type)[8L] <- TRUE
  d$gene[5L] <- NA_integer_
  args <- list(data = d, group_levels = c("B", "", "unused"), return_type = "data")
  expected <- do.call(PlotHeatmapJaccard, args)
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env$as.character <- function(x, ...) {
    if (is.factor(x) && length(x) > 100L) stop("decoded Jaccard group rows")
    base::as.character(x, ...)
  }
  environment(fn) <- env
  actual <- do.call(fn, args)
  expect_identical(actual, expected)
  expect_identical(rownames(actual), c("B", "", "unused"))
  expect_equal(unname(actual[1:2, 1:2]), matrix(c(1, 100/101, 100/101, 1), 2L))
})

test_that("Jaccard pruning keeps list feature elements intact", {
  keys <- list(c("a", "b"), c("b", "a"), letters[3:5], "solo",
               c("a", "b"), "w", letters[10:13], "q",
               c("a", "b"), "r", letters[14:15], "s")
  d <- data.frame(cell_type = rep(LETTERS[1:6], each = 2L))
  d$gene <- I(keys)
  group <- split(keys, d$cell_type)
  expected <- outer(seq_along(group), seq_along(group), Vectorize(function(i, j) {
    length(intersect(group[[i]], group[[j]])) / length(union(group[[i]], group[[j]]))
  }))
  dimnames(expected) <- list(names(group), names(group))
  expect_equal(PlotHeatmapJaccard(d, return_type = "data"), expected)
})

test_that("Jaccard factor selectors use their labels across different levels", {
  d <- data.frame(cell_type = factor(rep(c("x", "y"), each = 2L)),
                  gene = c("a", "b", "b", "c"))
  selector <- ordered(c("y", "x"), levels = c("y", "x", "z"))
  expected <- PlotHeatmapJaccard(d, group_levels = c("y", "x"), return_type = "data")
  expect_identical(PlotHeatmapJaccard(d, group_levels = selector, return_type = "data"), expected)
})

test_that("sparse Jaccard pairs do not compare groups sharing no features", {
  n <- 48L
  d <- data.frame(cell_type = rep(paste0("g", seq_len(n)), each = 4L),
    gene = as.vector(rbind(paste0("pair", rep(seq_len(n/2), each = 2)),
      paste0("local", seq_len(n)), paste0("extra", seq_len(n)), paste0("local", seq_len(n)))))
  expected <- PlotHeatmapJaccard(d, return_type = "data")
  expect_equal(expected[1, 2], 1/5)
  expect_identical(expected[1, 3], 0)
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(x, table) {
    if (identical(substitute(x), quote(gi))) stop("compared sparse feature groups individually")
    base::'%in%'(x, table)
  }
  environment(fn) <- env
  expect_identical(fn(d, return_type = "data"), expected)
})

test_that("frequently shared Jaccard features retain pairwise ratios", {
  d <- data.frame(cell_type = rep(LETTERS[1:20], each = 2), gene = c(rbind("shared", LETTERS[1:20])))
  result <- PlotHeatmapJaccard(d, return_type = "data")
  expect_equal(unname(result[row(result) != col(result)]), rep(1/3, 380L))
})

test_that("complete Jaccard inputs avoid missingness row masks", {
  d <- data.frame(group = rep(c("A", "B"), each = 3), name = letters[c(1, 2, 3, 2, 3, 4)])
  expected <- PlotHeatmapJaccard(d, group_col = "group", name_col = "name", return_type = "data")
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(is.na = function(x) {
    if (identical(x, d$name)) stop("complete Jaccard missingness rescan")
    base::is.na(x)
  }), parent = environment(fn))
  expect_identical(fn(d, group_col = "group", name_col = "name", return_type = "data"), expected)
})

test_that("identical Jaccard feature sets skip repeated membership matching", {
  d <- data.frame(group = rep(c("A", "B", "C"), each = 12), name = rep(letters[1:12], 3))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list("%in%" = function(x, table) {
    if (length(x) > 8L && identical(x, table)) stop("identical set membership")
    base::"%in%"(x, table)
  }), parent = environment(fn))
  expected <- matrix(1, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))
  expect_identical(fn(d, group_col = "group", name_col = "name", return_type = "data"), expected)
})

test_that("Jaccard row splits reuse resolved integer group codes", {
  d <- data.frame(g = c("b", "a", "b", NA, "out"), item = c("X", "Y", "Y", "X", "X"))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(factor = function(x, ...) {
    if (is.integer(x)) stop("already resolved Jaccard group codes")
    base::factor(x, ...)
  }), parent = environment(fn))
  actual <- fn(d, "g", "item", group_levels = c("a", "b", "empty"), return_type = "data")
  expect_identical(actual, matrix(c(1, .5, 0, .5, 1, 0, 0, 0, 0), 3,
    dimnames = list(c("a", "b", "empty"), c("a", "b", "empty"))))
})

test_that("Jaccard fallback reuses feature rows from sparse indexing", {
  g <- sprintf("G%02d", 1:18)
  d <- data.frame(g = rep(g, each = 3), item = c(rbind("shared", paste0(g, "a"), paste0(g, "b"))))
  expected <- PlotHeatmapJaccard(d, group_col = "g", name_col = "item", return_type = "data")
  calls <- 0L
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(unlist = function(x, ...) {
    if (is.list(x) && length(x) == length(g)) {
      calls <<- calls + 1L
      if (calls > 1L) stop("Jaccard feature memberships flattened twice")
    }
    base::unlist(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, group_col = "g", name_col = "item", return_type = "data"), expected)
})

test_that("Jaccard sparse triple memberships avoid all group comparisons", {
  n <- 30L
  d <- data.frame(cell_type = rep(paste0("g", seq_len(n)), each = 3L),
    gene = c(rbind(paste0("triple", rep(seq_len(n / 3L), each = 3L)),
                   paste0("local", seq_len(n)), paste0("extra", seq_len(n)))))
  expected <- PlotHeatmapJaccard(d, return_type = "data")
  expect_equal(unname(expected[1L, 2:4]), c(.2, .2, 0))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(x, table) {
    if (identical(substitute(x), quote(gi))) stop("compared sparse triple feature groups")
    base::"%in%"(x, table)
  }
  environment(fn) <- env
  expect_identical(fn(d, return_type = "data"), expected)
})

test_that("Jaccard fallback matches shared feature codes instead of labels", {
  n <- 20L
  groups <- paste0("g", seq_len(n))
  d <- data.frame(cell_type = rep(groups, each = 4L),
    gene = c(rbind("shared-primary", rep(c("shared-even", "shared-odd"), n / 2L),
      "shared-third", paste0("local", seq_len(n)))))
  expected <- PlotHeatmapJaccard(d, return_type = "data")
  expect_equal(unname(expected[1L, 2:3]), c(1 / 3, 3 / 5))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(x, table) {
    if (identical(substitute(x), quote(gi)) && is.character(x)) stop("compared shared Jaccard labels again")
    base::"%in%"(x, table)
  }
  environment(fn) <- env
  expect_identical(fn(d, return_type = "data"), expected)
})

test_that("Jaccard text layers format repeated scores only once", {
  groups <- sprintf("g%02d", seq_len(34L))
  d <- data.frame(cell_type = rep(groups, each = 2L), gene = c(rbind("shared", groups)))
  p <- PlotHeatmapJaccard(d, show_diag = FALSE, text_size = 2)
  expected <- ggplot2::ggplot_build(p)$data[[2L]]$label
  fn <- .build_jaccard_plot
  env <- new.env(parent = environment(fn))
  env$sprintf <- function(fmt, x, ...) {
    if (identical(fmt, "%.2f") && length(x) > 10L) stop("formatted all repeated Jaccard scores")
    base::sprintf(fmt, x, ...)
  }
  environment(fn) <- env
  local_mocked_bindings(.build_jaccard_plot = fn)
  p <- PlotHeatmapJaccard(d, show_diag = FALSE, text_size = 2)
  expect_identical(ggplot2::ggplot_build(p)$data[[2L]]$label, expected)
})

test_that("sparse Jaccard pair keys directly recover matrix indices", {
  d <- data.frame(cell_type = rep(LETTERS[1:24], each = 3L),
    gene = c(rbind(paste0("triple", rep(1:8, each = 3L)),
      paste0("pair", rep(1:12, each = 2L)), paste0("local", 1:24))))
  fn <- PlotHeatmapJaccard
  env <- new.env(parent = environment(fn))
  env$match <- function(x, table, ...) {
    if (identical(substitute(x), quote(pairs))) stop("looked up the first observation of each encoded pair")
    base::match(x, table, ...)
  }
  environment(fn) <- env
  out <- fn(d, return_type = "data")
  expect_identical(out, PlotHeatmapJaccard(d, return_type = "data"))
  expect_equal(out["A", "B"], .5)
  expect_equal(out["A", "C"], .2)
  expect_equal(out["A", "D"], 0)
})

test_that("sparse Jaccard pair counts avoid hashing the encoded pairs twice", {
  groups <- sprintf("G%02d", 1:24)
  d <- do.call(rbind, lapply(seq_along(groups), function(i) {
    data.frame(g = groups[[i]], item = c(
      paste0("triple", (i - 1L) %/% 3L, "_", 1:60),
      paste0("pair-x", (i - 1L) %/% 2L, "_", 1:60),
      paste0("pair-y", (i - 1L) %/% 2L, "_", 1:60),
      paste0("local", i, "_", 1:60)))
  }))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(match = function(x, table, ...) {
    if (identical(substitute(x), quote(keys)) && identical(substitute(table), quote(pairs)))
      stop("matched sparse Jaccard pairs after grouping them")
    base::match(x, table, ...)
  }), parent = environment(fn))
  out <- fn(d, "g", "item", return_type = "data")
  expect_equal(unname(out[1L, 1:4]), c(1, .6, 1/7, 0))
  expect_identical(out, PlotHeatmapJaccard(d, "g", "item", return_type = "data"))
})

test_that("numeric Jaccard filtering detects all shared values in one pass", {
  d <- data.frame(g = rep(LETTERS[1:8], each = 5L),
    item = c(rbind(rep(c(-0, 0), 4L), rep(c(2, 3), each = 4L), 10:17,
                   c(Inf, 21:27), c(NA, NaN, 30:35))))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(duplicated = function(x, ..., fromLast = FALSE) {
    if (identical(substitute(x), quote(membership)) && fromLast)
      stop("scanned numeric Jaccard memberships twice for duplicates")
    base::duplicated(x, ..., fromLast = fromLast)
  }), parent = environment(fn))
  expected <- PlotHeatmapJaccard(d, "g", "item", return_type = "data")
  expect_identical(fn(d, "g", "item", return_type = "data"), expected)
  expect_equal(unname(expected[1L, 2:3]), c(1/3, 2/7))
})

test_that("complete Jaccard factors skip allocating a row missingness mask", {
  d <- data.frame(g = factor(c("B", "A", "A", "B"), levels = c("A", "B", "Empty")),
    item = ordered(c("a", "a", "b", "c"), levels = letters[1:5]))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(is.na = function(x) {
    if (identical(x, d[["g"]]) || identical(x, d[["item"]]))
      stop("allocated a missingness mask for complete Jaccard factors")
    base::is.na(x)
  }), parent = environment(fn))
  actual <- fn(d, "g", "item", return_type = "data")
  expected <- matrix(c(1, 1/3, 0, 1/3, 1, 0, 0, 0, 0), 3L,
    dimnames = list(levels(d[["g"]]), levels(d[["g"]])))
  expect_identical(actual, expected)
})

test_that("sparse Jaccard similarities count pairs from one key grouping", {
  groups <- sprintf("G%02d", seq_len(30L))
  links <- paste0("link", seq_len(30L))
  d <- data.frame(g = rep(groups, each = 2L),
                  item = as.vector(rbind(links, c(links[30L], links[-30L]))))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(match = function(x, table, ...) {
    if (identical(substitute(x), quote(keys)) && identical(substitute(table), quote(pairs)))
      stop("looked up sparse Jaccard pair keys after deduplication")
    base::match(x, table, ...)
  }), parent = environment(fn))
  draw <- function(f) f(d, "g", "item", return_type = "data")
  expect_identical(draw(fn), draw(PlotHeatmapJaccard))
  expect_equal(draw(fn)["G01", "G02"], 1/3)
  d <- rbind(d, data.frame(g = groups[1:2], item = "shared"))
  expect_identical(draw(fn), draw(PlotHeatmapJaccard))
  expect_equal(draw(fn)["G01", "G02"], .5)
})

test_that("identical Jaccard group dictionaries reuse factor codes", {
  d <- data.frame(cell_type = ordered(rep(c("A", "B", "C"), 8L), levels = c("A", "B", "C")),
    gene = rep(letters[1:8], each = 3L))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(match = function(x, table, ...) {
    if (identical(substitute(x), quote(levels(keys))))
      stop("rematched the matching Jaccard level dictionary")
    base::match(x, table, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, group_levels = c("A", "B", "C"), return_type = "data"),
    PlotHeatmapJaccard(d, group_levels = c("A", "B", "C"), return_type = "data"))
})

test_that("Jaccard diagonal uses its occupied group positions", {
  d <- data.frame(cell_type = rep(c("A", "B", "C"), 2L), gene = c("a", "b", "c", "z", "z", "z"))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list("diag<-" = function(x, value) {
    stop("wrote the Jaccard diagonal from a second coverage vector")
  }), parent = environment(fn))
  group <- c("C", "A", "absent", "B")
  expect_identical(fn(d, group_levels = group, return_type = "data"),
    PlotHeatmapJaccard(d, group_levels = group, return_type = "data"))
})

test_that("sparse Jaccard groups come from cumulative set boundaries", {
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(rep = function(x, ...) {
    if (identical(substitute(x), quote(seq_len(n_ct))) && "times" %in% names(list(...)))
      stop("expanded all sparse Jaccard group memberships")
    base::rep(x, ...)
  }), parent = environment(fn))
  d <- data.frame(cell_type = rep(letters[1:20], each = 6L), gene = paste0("g", seq_len(120L)))
  d$gene[c(1L, 25L, 115L)] <- "shared"
  levels <- c("unused", "a", "unused2", letters[2:20])
  got <- fn(d, group_levels = levels, return_type = "data")
  expect_identical(got, PlotHeatmapJaccard(d, group_levels = levels, return_type = "data"))
  expect_equal(got[c("a", "e"), "t"], c(a = 1/11, e = 1/11))
  expect_identical(got["unused", "unused2"], 0)
})

test_that("one complete Jaccard group skips splitting row positions", {
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(split = function(x, ...) {
    if (identical(substitute(x), quote(rows)) && length(x) == 200L && any(!is.na(list(...)[[1L]]))) stop("split rows for the only Jaccard group")
    base::split(x, ...)
  }), parent = environment(fn))
  d <- data.frame(cell_type = factor(rep("T", 200L)), gene = rep(letters, length.out = 200L))
  expect_identical(fn(d, return_type = "data"), matrix(1, 1L, 1L, dimnames = list("T", "T")))
  expect_identical(fn(d, group_levels = "B", return_type = "data"),
                   matrix(0, 1L, 1L, dimnames = list("B", "B")))
  d$cell_type <- structure(rep.int(2L, nrow(d)), levels = c("T", NA_character_), class = "factor")
  expect_identical(fn(d, return_type = "data"), matrix(0, 1L, 1L, dimnames = list("T", "T")))
})

test_that("complete Jaccard group orders reuse their dictionary", {
  d <- data.frame(cell_type = c("B", "B", "A", "A"), gene = c("p", "q", "q", "r"))
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(is.na = function(x) {
    if (identical(substitute(x), quote(ct_names)) && !anyNA(x))
      stop("masked a complete Jaccard group dictionary")
    base::is.na(x)
  }), parent = environment(fn))
  p <- fn(d, return_type = "data")
  expect_identical(rownames(p), c("B", "A"))
  expect_equal(p[1L, 2L], 1/3)
  expect_identical(fn(d, group_levels = c("B", NA, "A"), return_type = "data"), p)
})

test_that("ordered Jaccard feature sets can reuse all input IDs", {
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list("unique" = function(x, ...) {
    if (is.numeric(x) && length(x) == 1000L && !is.unsorted(x, strictly = TRUE)) stop("unexpected unique in PlotHeatmapJaccard")
    base::unique(x, ...)
  }), parent = environment(fn))
  d <- data.frame(cell_type = rep(c("a", "b"), each = 1000L), gene = c(1:1000, 501:1500))
  result <- fn(d, return_type = "data")
  expect_equal(result["a", "b"], 1/3)
  dup <- rbind(d, d[c(10L, 1090L), ])
  expect_identical(fn(dup, return_type = "data"), result)
})

test_that("one sparse Jaccard pair uses its first overlap key", {
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list("duplicated" = function(x, ..., nmax = NA_integer_) {
    if (identical(substitute(x), quote(ids)) && !identical(nmax, attr(x, "n"))) stop("unexpected duplicated in PlotHeatmapJaccard")
    base::duplicated(x, ..., nmax = nmax)
  }), parent = environment(fn))
  a <- data.frame(cell_type = "a", gene = paste0("g", 1:100))
  b <- data.frame(cell_type = "b", gene = paste0("g", 51:150))
  rest <- data.frame(cell_type = letters[3:20], gene = paste0("private", 3:20))
  d <- rbind(a, b, rest)
  out <- fn(d, return_type = "data")
  expect_equal(out["a", "b"], 1/3)
  rest$gene[1L] <- "g90"
  moved <- fn(rbind(a, b, rest), return_type = "data")
  expect_equal(moved["c", c("a", "b")], c(a = .01, b = .01))
})

test_that("a complete single-group Jaccard matrix does not build a feature set", {
  fn <- PlotHeatmapJaccard
  environment(fn) <- list2env(list(unique = function(x, ...) {
    if (is.numeric(x) && length(x) > 1L) stop("constructed unnecessary feature set")
    base::unique(x, ...)
  }), parent = environment(fn))
  d <- data.frame(cell_type = rep("A", 50000L), gene = rep(1:5000, 10L))
  expected <- matrix(1, 1, 1, dimnames = list("A", "A"))
  expect_identical(fn(d, return_type = "data"), expected)
  d[["cell_type"]] <- factor(d[["cell_type"]])
  expect_identical(fn(d[0, ], return_type = "data"), expected * 0)
  d[["gene"]] <- NA_integer_
  expect_identical(fn(d, return_type = "data"), expected * 0)
})
