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
  package_path <- getNamespaceInfo("UtilsR", "path")
  writeLines(c("local({", "args <- commandArgs(trailingOnly = TRUE)",
               "if (file.exists(file.path(args[[2L]], 'R', 'check_size.R'))) {",
               "  pkgload::load_all(args[[2L]], quiet = TRUE, helpers = FALSE)",
               "} else { loadNamespace('UtilsR', lib.loc = dirname(args[[2L]])) }",
               "f <- readRDS(args[[1L]])",
               "stopifnot(length(ls(envir = .GlobalEnv, all.names = TRUE)) == 0L)",
               "out <- f()", "stopifnot(inherits(out, 'gt_tbl'))",
               "stopifnot(nrow(out[['_data']]) == 0L)",
               "invisible(gt::as_raw_html(out))", "})"), script)
  rscript <- file.path(R.home("bin"), if (.Platform[["OS.type"]] == "windows") "Rscript.exe" else "Rscript")
  output <- system2(rscript, c("--vanilla", shQuote(script), shQuote(fn_file), shQuote(package_path)),
                    stdout = TRUE, stderr = TRUE)
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
})

test_that("check_size reads an active binding once for both size and class", {
  with_size_objects(list(active = 1), function(nms) {
    rm(list = nms, envir = .GlobalEnv)
    reads <- 0L
    makeActiveBinding(nms, function(value) {
      reads <<- reads + 1L
      if (reads == 1L) rep(1, 100) else "changed"
    }, .GlobalEnv)
    result <- check_size(nms)[["_data"]]
    expect_identical(reads, 1L)
    expect_identical(result[["Class"]], c("Summary", "numeric"))
    expect_equal(result[["Size"]][[2]],
                 as.numeric(utils::object.size(rep(1, 100))) / 1024^2)
  })
})

test_that("check_size inspects promised objects without reevaluating them", {
  with_size_objects(list(lazy = 1), function(nms) {
    counter <- new.env(parent = emptyenv())
    counter[["evaluations"]] <- 0L
    delayedAssign(nms, { counter[["evaluations"]] <- counter[["evaluations"]] + 1L; raw(16) },
                  eval.env = environment(), assign.env = .GlobalEnv)
    result <- check_size(nms)[["_data"]]
    expect_identical(counter[["evaluations"]], 1L)
    expect_identical(result[["Class"]], c("Summary", "raw"))
  })
})

test_that("check_size distinguishes bytes from zero and uses consistent units", {
  with_size_objects(list(zero = NULL, tiny = integer(), kilo = raw(2000),
                         mega = raw(1024^2)), function(nms) {
    result <- check_size(nms)
    data <- result[["_data"]]
    labels <- stats::setNames(data[["Size_fmt"]], data[["Object"]])
    expect_identical(labels[[nms[[1]]]], "0 B")
    expect_identical(labels[[nms[[2]]]],
                     sprintf("%.0f B", as.numeric(utils::object.size(integer()))))
    expect_match(labels[[nms[[3]]]], " KB$", fixed = FALSE)
    expect_match(labels[[nms[[4]]]], " MB$", fixed = FALSE)
    expect_match(result[["_heading"]][["subtitle"]], labels[["**TOTAL**"]], fixed = TRUE)
  })
})

test_that("check_size applies its numeric gradient to the visible size cells", {
  with_size_objects(list(small = raw(16), large = raw(2000)), function(nms) {
    html <- gt::as_raw_html(check_size(nms))
    cells <- grep('headers="Size_fmt"', strsplit(html, "\n", fixed = TRUE)[[1]], value = TRUE)
    expect_length(cells, 3L)
    expect_match(cells[[2]], "background-color: #FF0000", fixed = TRUE)
    expect_match(cells[[3]], "background-color: #FFFFFF", fixed = TRUE)
  })
})

test_that("check_size respects later gt formatting without parsing display text", {
  with_size_objects(list(small = raw(1024), large = raw(2048)), function(nms) {
    result <- check_size(nms)
    formatters <- list(
      function(x) gt::fmt_number(x, columns = "Size_bar", decimals = 2),
      function(x) gt::fmt_number(x, columns = "Size_bar", decimals = 4, locale = "de"),
      function(x) gt::fmt_scientific(x, columns = "Size_bar")
    )
    for (formatter in formatters) {
      formatted <- formatter(result)
      expect_no_warning(html <- gt::as_raw_html(formatted))
      expect_false(grepl("background-color:#4CAF50", html, fixed = TRUE))
      expect_identical(formatted[["_data"]], result[["_data"]])
    }
  })
})

test_that("check_size keeps HTML bars out of other output formats", {
  with_size_objects(list(kilo = raw(1024)), function(nms) {
    result <- check_size(nms)
    for (render in list(gt::as_latex, gt::as_rtf, gt::as_word)) {
      output <- as.character(render(result))
      expect_false(any(grepl("background-color:#4CAF50", output, fixed = TRUE)))
      expect_true(any(grepl(result[["_data"]][["Size_fmt"]][[2L]], output, fixed = TRUE)))
    }
  })
})

test_that("check_size distinguishes a TOTAL-named object from the summary", {
  with_size_objects(list(other = raw(1024)), function(nms) {
    reserved <- "**TOTAL**"
    stopifnot(!exists(reserved, envir = .GlobalEnv, inherits = FALSE))
    assign(reserved, raw(32), envir = .GlobalEnv)
    on.exit(rm(list = reserved, envir = .GlobalEnv), add = TRUE)
    result <- check_size(c(reserved, nms))
    expect_identical(result[["_data"]][["Object"]], c(reserved, nms, reserved))
    expect_match(result[["_heading"]][["subtitle"]], "Total objects: 2", fixed = TRUE)
    styles <- result[["_styles"]]
    object_rows <- styles[["rownum"]][styles[["colname"]] == "Object" &
                                       !is.na(styles[["rownum"]])]
    expect_identical(object_rows, 1L)
    html <- gt::as_raw_html(result)
    cells <- grep('headers="Size_fmt"', strsplit(html, "\n", fixed = TRUE)[[1]], value = TRUE)
    expect_length(cells, 3L)
    expect_match(cells[[3L]], "background-color: #FFFFFF", fixed = TRUE)
  })
})

test_that("check_size enumerates global names only when selection needs them", {
  with_size_objects(list(a = raw(16), b = raw(64)), function(nms) {
    enumerations <- 0L
    lookup <- new.env(parent = environment(check_size))
    lookup[["ls"]] <- function(...) {
      enumerations <<- enumerations + 1L
      base::ls(...)
    }
    inspect <- check_size
    environment(inspect) <- lookup
    result <- inspect(nms, nms[[1L]])
    expect_identical(enumerations, 0L)
    expect_identical(result[["_data"]][["Object"]], c("**TOTAL**", rev(nms)))
    indices <- match(nms, ls(envir = .GlobalEnv, all.names = TRUE))
    mixed <- inspect(nms, indices, indices)
    expect_identical(enumerations, 1L)
    expect_identical(mixed[["_data"]], result[["_data"]])
    patterned <- inspect(stop("pattern must take precedence"),
                         pattern = "^\\.check_size_test_[ab]$")
    expect_identical(patterned[["_data"]], result[["_data"]])
  })
})

test_that("check_size scales object bars independently of the total", {
  with_size_objects(list(small = raw(1024), large = raw(2048)), function(nms) {
    result <- check_size(nms)
    sizes <- result[["_data"]][["Size"]]
    html <- gt::as_raw_html(result)
    tokens <- regmatches(html, gregexpr("background-color:#4CAF50;width:[0-9.]+%", html))[[1L]]
    widths <- as.numeric(sub(".*width:([0-9.]+)%", "\\1", tokens))
    expect_equal(widths, c(100, 100, 100 * sizes[[3L]] / sizes[[2L]]),
                 tolerance = 0.0001)
    expect_true(all(widths <= 100))
  })
})

test_that("check_size sorts pattern matches without sorting every global name", {
  values <- stats::setNames(rep(list(raw(16)), 5L), c("z", "a", "A", "\u00e9", "\u4e2d"))
  with_size_objects(values, function(nms) {
    sort_requests <- logical()
    lookup <- new.env(parent = environment(check_size))
    lookup[["ls"]] <- function(..., sorted = TRUE) {
      sort_requests <<- c(sort_requests, sorted)
      base::ls(..., sorted = sorted)
    }
    inspect <- check_size
    environment(inspect) <- lookup
    expected <- ls(envir = .GlobalEnv, all.names = TRUE)
    expected <- expected[expected %in% nms]
    result <- inspect(pattern = "^\\.check_size_test_")
    expect_identical(sort_requests, FALSE)
    expect_identical(result[["_data"]][["Object"]], c("**TOTAL**", expected))
  })
})
