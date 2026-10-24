test_that("library counts include installed copies and exclude unrelated directories", {
  root <- withr::local_tempdir()
  lib <- file.path(root, "library")
  empty <- file.path(root, "empty-library")
  dir.create(lib)
  dir.create(empty)
  stopifnot(file.copy(find.package("compiler"), lib, recursive = TRUE))
  dir.create(file.path(lib, "00LOCK-compiler"))
  dir.create(file.path(lib, "notes"))
  dir.create(file.path(empty, "notes"))
  withr::local_libpaths(c(lib, empty), action = "prefix")
  paths <- .libPaths()
  result <- check_packages()
  expect_s3_class(result, "data.frame")
  expect_named(result, c("Library_Path", "Package_Count"))
  expect_identical(result$Library_Path, c(paths, "Total"))
  expect_equal(result$Package_Count[1:2], c(1L, 0L))
  expected <- vapply(paths, function(path) {
    nrow(utils::installed.packages(lib.loc = path, noCache = TRUE))
  }, integer(1))
  expect_equal(result$Package_Count, c(unname(expected), sum(expected)))
  # The compiler copy is counted in this library and in R's own library.
  all_packages <- utils::installed.packages(lib.loc = paths)
  expect_gt(result$Package_Count[nrow(result)], length(unique(all_packages[, "Package"])))
})

test_that("check_packages refreshes counts when library timestamps are unchanged", {
  root <- withr::local_tempdir()
  lib <- file.path(root, "library")
  dir.create(lib)
  stopifnot(file.copy(find.package("compiler"), lib, recursive = TRUE))
  dir.create(file.path(lib, "stats"))
  withr::local_libpaths(lib, action = "prefix")
  stopifnot(Sys.setFileTime(lib, Sys.time() - 60))

  expect_identical(check_packages()[["Package_Count"]][[1]], 1L)
  stamp <- file.info(lib)[["mtime"]]
  stopifnot(file.copy(find.package("stats"), lib, recursive = TRUE))
  expect_identical(file.info(lib)[["mtime"]], stamp)
  expect_identical(check_packages()[["Package_Count"]][[1]], 1L)
  expect_identical(check_packages(refresh = TRUE)[["Package_Count"]][[1]], 2L)
})

test_that("check_packages rejects invalid refresh flags", {
  for (refresh in list(NULL, NA, c(TRUE, FALSE), 1, "TRUE")) {
    expect_error(check_packages(refresh = refresh),
                 "'refresh' must be TRUE or FALSE.", fixed = TRUE)
  }
})
