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

test_that("white borders preserve scaled group colours and existing fills", {
  d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
    ggplot2::scale_colour_manual(values = c(a = "red", b = "blue"))
  original <- ggplot2::ggplot_build(fmt_point(p))$data[[1]]
  result <- ggplot2::ggplot_build(fmt_point(p, white_border = TRUE))$data[[1]]
  expect_equal(result$fill, original$colour)
  expect_equal(result$colour, rep("#FFFFFF", 4))
  expect_equal(result$shape, rep(21, 4))
  result <- ggplot2::ggplot_build(fmt_point(p, white_border = TRUE,
                                           fill = "purple"))$data[[1]]
  expect_equal(result$fill, rep("purple", 4))
  grob <- ggplot2::ggplotGrob(fmt_point(p, white_border = TRUE))
  point_fills <- function(g) {
    if (inherits(g, "points")) return(as.character(g$gp$fill))
    unlist(c(lapply(g$grobs, point_fills), lapply(g$children, point_fills)),
           use.names = FALSE)
  }
  guides <- grob$grobs[grepl("guide-box", grob$layout$name)]
  expect_setequal(unlist(lapply(guides, point_fills)), c("#FF0000FF", "#0000FFFF"))
})

test_that("white borders normalize colour aliases and include shape 25", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y))
  for (spelling in c("color", "colour")) {
    result <- do.call(fmt_point, c(list(plot = p, white_border = TRUE),
                                   stats::setNames(list("red"), spelling)))
    built <- ggplot2::ggplot_build(result)$data[[1]]
    expect_equal(built$colour, rep("#FFFFFF", 3))
    expect_equal(built$fill, rep("red", 3))
  }
  result <- ggplot2::ggplot_build(fmt_point(p, shape = 25, colour = "red",
                                           fill = "blue", white_border = TRUE))$data[[1]]
  expect_equal(result$colour, rep("#FFFFFF", 3))
  expect_equal(result$fill, rep("blue", 3))
})

test_that("white borders retain mapped shapes and after-scale colours", {
  d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g, shape = g)) +
    ggplot2::scale_shape_manual(values = c(a = 16, b = 17))
  result <- ggplot2::ggplot_build(fmt_point(p, white_border = TRUE))$data[[1]]
  expect_equal(result$shape, c(21, 24, 21, 24))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y,
    colour = ggplot2::stage(start = g, after_scale = scales::alpha(colour, 0.5))))
  native <- ggplot2::ggplot_build(p + ggplot2::geom_point())$data[[1]]
  result <- ggplot2::ggplot_build(fmt_point(p, white_border = TRUE))$data[[1]]
  expect_equal(result$fill, native$colour)
  expect_equal(result$colour, rep("#FFFFFF", 4))
})

test_that("sampling function and formula data remains deferred", {
  d <- data.frame(x = 1:12, y = 12:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  calls <- 0L
  callback <- function(data) {
    calls <<- calls + 1L
    utils::head(data, 8)
  }
  withr::local_seed(321)
  before <- .Random.seed
  result <- fmt_point(p, data = callback, sample_n = 3)
  expect_identical(calls, 0L)
  first <- ggplot2::ggplot_build(result)$data[[1]]
  expect_identical(calls, 1L)
  expect_equal(nrow(first), 3L)
  expect_equal(first$x <= 8, rep(TRUE, 3))
  expect_identical(.Random.seed, before)
  expect_identical(ggplot2::ggplot_build(result)$data[[1]], first)
  expect_identical(calls, 2L)
  result <- fmt_point(p, data = ~ utils::head(.x, 8), sample_n = 3)
  expect_equal(nrow(ggplot2::ggplot_build(result)$data[[1]]), 3L)
  expect_equal(nrow(ggplot2::ggplot_build(
    fmt_point(p, data = ~ .x[FALSE, ], sample_n = 3))$data[[1]]), 0L)
})

test_that("sampled data callbacks retain only their own sampling context", {
  p <- ggplot2::ggplot(data.frame(x = 1:6, y = 6:1))
  p$mapping <- ggplot2::aes(x, y)
  for (name in names(p$mapping)) {
    p$mapping[[name]] <- rlang::new_quosure(rlang::get_expr(p$mapping[[name]]), baseenv())
  }
  formula <- rlang::new_formula(NULL, quote(utils::head(.x, 4)), baseenv())
  small <- fmt_point(list(p, p), data = formula, sample_n = 2)[[1]]
  peer <- ggplot2::ggplot(data.frame(x = 1:100000, y = seq_len(100000)))
  peer$mapping <- p$mapping
  large <- fmt_point(list(p, peer), data = formula, sample_n = 2)[[1]]
  expect_equal(length(serialize(large$layers[[1]]$data, NULL)),
               length(serialize(small$layers[[1]]$data, NULL)))
  expect_equal(nrow(ggplot2::ggplot_build(large)$data[[1]]), 2L)
})
