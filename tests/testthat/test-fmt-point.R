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

test_that("sampling evaluates group expressions and prioritizes explicit groups", {
  d <- data.frame(x = rep(1:2, each = 6), y = 1:12,
                  g = rep(c("a", "b"), 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = factor(g)))
  result <- fmt_point(p, sample_n = 2)
  expect_equal(table(result$layers[[1]]$data$g), c(a = 2L, b = 2L),
               ignore_attr = TRUE)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = y,
                                     group = interaction(x, g)))
  sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
  expect_equal(nrow(sampled), 8L)
  expect_equal(as.integer(table(sampled$x, sampled$g)), rep(2L, 4))
})

test_that("sampling retains missing groups and leaves small groups complete", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b", NA), 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g))
  sampled <- fmt_point(p, sample_n = 10)$layers[[1]]$data
  expect_equal(nrow(sampled), 12L)
  expect_equal(sum(is.na(sampled$g)), 4L)
  sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
  expect_equal(nrow(sampled), 6L)
  expect_equal(sum(is.na(sampled$g)), 2L)
})

test_that("continuous colour does not partition sampling into singleton groups", {
  p <- ggplot2::ggplot(data.frame(x = 1:12, y = 12:1),
                       ggplot2::aes(x, y, colour = y))
  sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
  expect_equal(nrow(sampled), 2L)
})
