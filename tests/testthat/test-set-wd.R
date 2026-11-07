# Run `set_wd()` in a sandbox and return its printed output with ANSI styling
# removed, restoring the working directory before returning. The notice wraps
# at the console width, so its lines are joined with single spaces.
capture_set_wd <- function(...) {
  old <- getwd()
  on.exit(setwd(old), add = TRUE)
  out <- cli::ansi_strip(paste(cli::cli_fmt(set_wd(...)), collapse = " "))
  gsub("\\s+", " ", out)
}

test_that("working-directory flags fail before creating or entering a directory", {
  old <- getwd()
  on.exit(setwd(old), add = TRUE)
  bad <- list(NULL, logical(), NA, c(TRUE, FALSE), matrix(TRUE), 1, "TRUE", list(TRUE))
  for (arg in c("create", "verbose")) for (value in bad) {
    path <- tempfile("invalid_set_wd_")
    args <- list(path = path)
    args[arg] <- list(value)
    error <- tryCatch(do.call(set_wd, args), error = identity)
    expect_s3_class(error, "error")
    if (inherits(error, "error")) expect_match(conditionMessage(error), arg)
    expect_identical(getwd(), old)
    expect_false(dir.exists(path))
    setwd(old)
    unlink(path, recursive = TRUE)
  }
})

test_that("set_wd reports a freshly created directory as empty", {
  target <- tempfile("set_wd_new_")
  on.exit(unlink(target, recursive = TRUE), add = TRUE)

  out <- capture_set_wd(target)

  expect_match(out, "[empty, new directory]", fixed = TRUE)
  expect_false(grepl("existing directory", out, fixed = TRUE))
})

test_that("set_wd reports file count and total size for an existing directory", {
  target <- tempfile("set_wd_old_")
  dir.create(file.path(target, "sub"), recursive = TRUE)
  on.exit(unlink(target, recursive = TRUE), add = TRUE)
  writeBin(raw(2048), file.path(target, "a.txt"))
  writeBin(raw(2048), file.path(target, "sub", "b.txt"))

  out <- capture_set_wd(target)

  expect_match(out, "[2 files, 4.00 KB, existing directory]", fixed = TRUE)
})

test_that("set_wd counts a single file without pluralising", {
  target <- tempfile("set_wd_one_")
  dir.create(target)
  on.exit(unlink(target, recursive = TRUE), add = TRUE)
  writeBin(raw(512), file.path(target, "a.txt"))

  out <- capture_set_wd(target)

  expect_match(out, "[1 file, 512 B, existing directory]", fixed = TRUE)
})

test_that("set_wd reports an existing but empty directory as empty", {
  target <- tempfile("set_wd_bare_")
  dir.create(target)
  on.exit(unlink(target, recursive = TRUE), add = TRUE)

  out <- capture_set_wd(target)

  expect_match(out, "[empty, existing directory]", fixed = TRUE)
})

test_that("set_wd stays silent and returns the previous directory", {
  target <- tempfile("set_wd_quiet_")
  old <- getwd()
  on.exit({
    setwd(old)
    unlink(target, recursive = TRUE)
  }, add = TRUE)

  expect_silent(previous <- set_wd(target, verbose = FALSE))
  expect_identical(previous, old)
})
