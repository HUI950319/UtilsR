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
