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

test_that("check_packages marks inaccessible libraries and totals as unknown", {
  skip_on_os("windows")
  root <- withr::local_tempdir()
  lib <- file.path(root, "restricted")
  empty <- file.path(root, "empty")
  dir.create(lib)
  dir.create(empty)
  stopifnot(file.copy(find.package("compiler"), lib, recursive = TRUE))
  lib <- normalizePath(lib, winslash = "/", mustWork = TRUE)
  withr::local_libpaths(c(lib, empty), action = "prefix")
  withr::defer(Sys.chmod(lib, mode = "0700"))
  Sys.chmod(lib, mode = "0000")
  skip_if(file.access(lib, 5L) == 0L, "User can still read restricted directories")

  for (refresh in c(FALSE, TRUE)) {
    expect_warning(result <- check_packages(refresh = refresh), lib, fixed = TRUE)
    expect_identical(result[["Package_Count"]][1:2], c(NA_integer_, 0L))
    expect_identical(tail(result[["Package_Count"]], 1), NA_integer_)
  }
})

test_that("check_packages reports libraries that disappear after path registration", {
  root <- withr::local_tempdir()
  lib <- file.path(root, "library")
  empty <- file.path(root, "empty")
  dir.create(lib)
  dir.create(empty)
  lib <- normalizePath(lib, winslash = "/", mustWork = TRUE)
  withr::local_libpaths(c(lib, empty), action = "prefix")
  stopifnot(file.rename(lib, paste0(lib, "-moved")))

  expect_warning(out <- capture.output(result <- check_packages()), lib, fixed = TRUE)
  expect_identical(result[["Package_Count"]][1:2], c(NA_integer_, 0L))
  expect_identical(tail(result[["Package_Count"]], 1), NA_integer_)
  expect_match(paste(cli::ansi_strip(out), collapse = "\n"), "incomplete", fixed = TRUE)
  expect_match(paste(cli::ansi_strip(out), collapse = "\n"), "unavailable", fixed = TRUE)
})

test_that("check_packages continues after a library metadata read fails", {
  root <- withr::local_tempdir()
  lib <- file.path(root, "library")
  empty <- file.path(root, "empty")
  dir.create(file.path(lib, "broken", "Meta"), recursive = TRUE)
  dir.create(empty)
  saveRDS(1L, file.path(lib, "broken", "Meta", "package.rds"))
  lib <- normalizePath(lib, winslash = "/", mustWork = TRUE)
  withr::local_libpaths(c(lib, empty), action = "prefix")

  expect_warning(result <- check_packages(refresh = TRUE), lib, fixed = TRUE)
  expect_identical(result[["Package_Count"]][1:2], c(NA_integer_, 0L))
  expect_identical(tail(result[["Package_Count"]], 1), NA_integer_)
})

test_that("check_packages prints a report and invisibly returns the data frame", {
  withr::local_options(cli.num_colors = 0, cli.width = 120)
  out <- capture.output(visible <- withVisible(suppressMessages(check_packages())))
  plain <- cli::ansi_strip(out)

  expect_identical(visible[["visible"]], FALSE)
  expect_s3_class(visible[["value"]], "data.frame")
  expect_named(visible[["value"]], c("Library_Path", "Package_Count"))
  expect_match(paste(head(plain, 1), collapse = ""), "<check_packages>", fixed = TRUE)
  expect_match(paste(plain, collapse = "\n"), "Packages", fixed = TRUE)
  expect_match(paste(plain, collapse = "\n"), "Library", fixed = TRUE)
  expect_length(grep("^> +.*Total", plain), 1L)
  expect_match(paste(plain[startsWith(plain, "#")], collapse = " "),
               "installed copies", fixed = TRUE)
  expect_identical(any(grepl("Full paths", plain, fixed = TRUE)), FALSE)
})

test_that("check_packages fits narrow consoles without changing full paths", {
  withr::local_options(cli.num_colors = 0, cli.width = 48)
  root <- withr::local_tempdir()
  lib <- file.path(root, paste(rep("long_segment", 5), collapse = "_"))
  dir.create(lib)
  withr::local_libpaths(lib, action = "prefix")

  out <- cli::ansi_strip(capture.output(result <- check_packages()))
  expect_identical(result[["Library_Path"]][[1]], normalizePath(lib, winslash = "/"))
  expect_match(paste(out, collapse = "\n"), "Packages", fixed = TRUE)
  expect_match(paste(out, collapse = "\n"), "Library", fixed = TRUE)
  expect_lte(max(c(0L, nchar(out, type = "width"))), 48L)
  expect_match(paste(out, collapse = "\n"), "Full paths", fixed = TRUE)
})

test_that("check_packages prints all libraries and the total beyond twenty rows", {
  withr::local_options(cli.num_colors = 0, cli.width = 200)
  root <- withr::local_tempdir()
  libs <- file.path(root, sprintf("library-%02d", seq_len(21)))
  for (lib in libs) dir.create(lib)
  withr::local_libpaths(libs, action = "prefix")

  out <- cli::ansi_strip(capture.output(check_packages()))
  expect_match(paste(out, collapse = "\n"), "library-21", fixed = TRUE)
  expect_length(grep("^> +.*Total", out), 1L)
})

test_that("check_packages groups table counts without changing numeric results", {
  withr::local_options(cli.num_colors = 0, cli.width = 120)
  template <- utils::installed.packages(lib.loc = .Library)
  records <- template[rep_len(seq_len(nrow(template)), 1234L), , drop = FALSE]
  records[, "Package"] <- sprintf("pkg%04d", seq_len(nrow(records)))
  rownames(records) <- records[, "Package"]
  local_mocked_bindings(installed.packages = function(lib.loc, noCache) {
    records[, "LibPath"] <- lib.loc
    records
  }, .package = "utils")

  out <- cli::ansi_strip(capture.output(result <- check_packages()))
  expect_length(grep("^ +1,234 +", out), length(.libPaths()))
  total <- 1234L * length(.libPaths())
  expect_match(paste(out[startsWith(out, ">")], collapse = "\n"),
               paste0(format(total, big.mark = ",", trim = TRUE), " +Total"))
  expect_type(result[["Package_Count"]], "integer")
  expect_equal(result[["Package_Count"]], c(rep(1234L, length(.libPaths())), total))
})
