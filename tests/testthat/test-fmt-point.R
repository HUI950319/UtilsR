test_that("sampling preserves the caller's random stream", {
  p <- ggplot2::ggplot(data.frame(x = 1:12, y = 12:1), ggplot2::aes(x, y))
  withr::local_seed(123)
  before <- .Random.seed
  first <- fmt_point(p, sample_n = 4)
  expect_identical(.Random.seed, before)
  second <- fmt_point(p, sample_n = 4)
  expect_identical(first$layers[[1]]$data, second$layers[[1]]$data)
  expect_identical(.Random.seed, before)
  invisible(fmt_point(p, sample_n = 100))
  expect_identical(.Random.seed, before)
})

test_that("sampling does not create a previously absent random seed", {
  withr::local_preserve_seed()
  if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    rm(".Random.seed", envir = .GlobalEnv)
  }
  p <- ggplot2::ggplot(data.frame(x = 1:6, y = 6:1), ggplot2::aes(x, y))
  invisible(fmt_point(p, sample_n = 2))
  expect_identical(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE), FALSE)
})
