with_size_objects <- function(objects, code) {
  object_names <- paste0(".check_size_test_", names(objects))
  stopifnot(!any(vapply(object_names, exists, logical(1),
                       envir = .GlobalEnv, inherits = FALSE)))
  list2env(stats::setNames(objects, object_names), envir = .GlobalEnv)
  on.exit(rm(list = object_names, envir = .GlobalEnv), add = TRUE)
  code(object_names)
}

test_that("check_size renders lightweight bars without changing sizes", {
  with_size_objects(list(small = raw(16), large = raw(64)), function(nms) {
    result <- check_size(nms)
    data <- result[["_data"]]
    expect_identical(data[["Object"]], c("**TOTAL**", nms[[2]], nms[[1]]))
    sizes <- vapply(list(raw(64), raw(16)), function(x) {
      as.numeric(utils::object.size(x)) / 1024^2
    }, numeric(1))
    expect_equal(data[["Size"]], c(sum(sizes), sizes))
    html <- gt::as_raw_html(result)
    expect_match(html, "background-color:#4CAF50", fixed = TRUE)
    expect_false(grepl("<svg", html, fixed = TRUE))
  })
})

test_that("check_size renders zero-sized objects with finite bar widths", {
  with_size_objects(list(zero = NULL), function(nms) {
    result <- check_size(nms)
    expect_equal(result[["_data"]][["Size"]], c(0, 0))
    html <- gt::as_raw_html(result)
    expect_match(html, "width:0.0000%", fixed = TRUE)
    expect_false(grepl("NaN%|Inf%", html))
  })
})

test_that("check_size validates selectors before scanning objects", {
  with_size_objects(list(a = 1), function(nms) {
    for (bad in list(TRUE, list(nms), 0, -1, 1.9, NA_real_, Inf, 1e9,
                     NA_character_, "", matrix(1), structure(1, class = "index"))) {
      expect_error(check_size(bad), "Object names|indices")
    }
    for (bad in list(NA_character_, c("a", "b"), TRUE, character())) {
      expect_error(check_size(pattern = bad), "pattern")
    }
    expect_error(check_size(pattern = "["), "pattern")
  })
})

test_that("check_size does not expand unmatched or empty selections", {
  with_size_objects(list(a = 1), function(nms) {
    for (selected in list(character(), integer())) {
      invisible(capture.output(result <- check_size(selected)))
      data <- if (inherits(result, "gt_tbl")) result[["_data"]] else result
      expect_equal(nrow(data), 0L)
    }
    invisible(capture.output(result <- check_size(pattern = "^no_size_match$")))
    data <- if (inherits(result, "gt_tbl")) result[["_data"]] else result
    expect_equal(nrow(data), 0L)
  })
})

test_that("check_size deduplicates names and never inherits objects", {
  with_size_objects(list(a = raw(16)), function(nms) {
    index <- match(nms, ls(envir = .GlobalEnv, all.names = TRUE))
    result <- check_size(nms, index, nms)
    expect_identical(result[["_data"]][["Object"]], c("**TOTAL**", nms))
    expect_equal(result[["_data"]][["Size"]][[1]],
                 as.numeric(utils::object.size(raw(16))) / 1024^2)
    expect_warning(result <- check_size(nms, "mean"), "not found.*mean")
    expect_identical(result[["_data"]][["Object"]], c("**TOTAL**", nms))
  })
})

test_that("check_size returns a renderable empty gt table for no matches", {
  invisible(capture.output(result <- check_size(pattern = "^no_size_match$")))
  expect_s3_class(result, "gt_tbl")
  expect_named(result[["_data"]], c("Object", "Class", "Size", "Size_fmt", "Size_bar"))
  expect_equal(nrow(result[["_data"]]), 0L)
  expect_match(result[["_heading"]][["subtitle"]], "Total objects: 0", fixed = TRUE)
  expect_no_error(gt::as_raw_html(result))
})

test_that("check_size reports read failures without losing readable objects", {
  with_size_objects(list(ok = raw(16), bad = 1), function(nms) {
    rm(list = nms[[2]], envir = .GlobalEnv)
    makeActiveBinding(nms[[2]], function(value) stop("unreadable fixture"), .GlobalEnv)
    expect_warning(result <- check_size(nms), "Could not inspect.*bad")
    expect_identical(result[["_data"]][["Object"]], c("**TOTAL**", nms[[1]]))
    invisible(capture.output(expect_warning(empty <- check_size(nms[[2]]),
                                           "Could not inspect.*bad")))
    expect_s3_class(empty, "gt_tbl")
    expect_equal(nrow(empty[["_data"]]), 0L)
    expect_match(empty[["_heading"]][["subtitle"]], "Total objects: 0", fixed = TRUE)
  })
})

test_that("check_size handles a truly empty global environment", {
  fn_file <- tempfile(fileext = ".rds")
  script <- tempfile(fileext = ".R")
  on.exit(unlink(c(fn_file, script)), add = TRUE)
  saveRDS(check_size, fn_file)
  writeLines(c("local({", "f <- readRDS(commandArgs(trailingOnly = TRUE)[[1L]])",
               "stopifnot(length(ls(envir = .GlobalEnv, all.names = TRUE)) == 0L)",
               "out <- f()", "stopifnot(inherits(out, 'gt_tbl'))",
               "stopifnot(nrow(out[['_data']]) == 0L)",
               "invisible(gt::as_raw_html(out))", "})"), script)
  rscript <- file.path(R.home("bin"), if (.Platform[["OS.type"]] == "windows") "Rscript.exe" else "Rscript")
  output <- system2(rscript, c("--vanilla", shQuote(script), shQuote(fn_file)),
                    stdout = TRUE, stderr = TRUE)
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
})
