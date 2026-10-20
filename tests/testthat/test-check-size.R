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
