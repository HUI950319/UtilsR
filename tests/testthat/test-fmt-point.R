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

test_that("nested patchworks add points to every ordinary leaf", {
  skip_if_not_installed("patchwork")
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y))
  original <- (p | p) / p + patchwork::plot_annotation(title = "Nested")
  result <- fmt_point(original)
  expect_equal(vapply(list(result[[1]][[1]], result[[1]][[2]], result[[2]]),
                      function(q) length(q$layers), integer(1)), rep(1L, 3))
  expect_equal(vapply(list(result[[1]][[1]], result[[1]][[2]], result[[2]]),
                      function(q) nrow(ggplot2::ggplot_build(q)$data[[1]]),
                      integer(1)), rep(3L, 3))
  expect_equal(vapply(list(original[[1]][[1]], original[[1]][[2]], original[[2]]),
                      function(q) length(q$layers), integer(1)), rep(0L, 3))
  expect_identical(result$patches$annotation$title, "Nested")
  expect_s3_class(patchwork::patchworkGrob(result), "gtable")
  results <- fmt_point(list(original, p))
  expect_length(results[[1]][[1]][[1]]$layers, 1L)
  expect_length(results[[2]]$layers, 1L)
})

test_that("point overlays preserve spacers and independent sibling layers", {
  skip_if_not_installed("patchwork")
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y))
  original <- p + patchwork::plot_spacer()
  result <- fmt_point(original, sample_n = 2)
  expect_s3_class(result[[2]], "spacer")
  expect_length(result[[2]]$layers, 0L)
  expect_s3_class(patchwork::patchworkGrob(result), "gtable")
  siblings <- fmt_point(list(p, p), sample_n = 2)
  siblings[[1]]$layers[[1]]$aes_params$size <- 8
  expect_equal(siblings[[2]]$layers[[1]]$aes_params$size, 1)
  expect_length(p$layers, 0L)
})
