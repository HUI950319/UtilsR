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

test_that("point layers respect local mappings and explicit aesthetic overrides", {
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  native <- ggplot2::ggplot_build(p + ggplot2::geom_point(ggplot2::aes(shape = g)))$data[[1]]
  result <- ggplot2::ggplot_build(fmt_point(p, mapping = ggplot2::aes(shape = g)))$data[[1]]
  expect_equal(result$shape, native$shape)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, shape = g, size = y))
  result <- ggplot2::ggplot_build(fmt_point(p, shape = 17, size = 7))$data[[1]]
  expect_equal(result$shape, rep(17, 6))
  expect_equal(result$size, rep(7, 6))
  result <- ggplot2::ggplot_build(fmt_point(p, inherit.aes = FALSE,
    mapping = ggplot2::aes(x, y), size = 7))$data[[1]]
  expect_equal(result$size, rep(7, 6))
})

test_that("sampling uses the effective layer mapping", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  result <- fmt_point(p, mapping = ggplot2::aes(colour = g), sample_n = 2)
  expect_equal(nrow(result$layers[[1]]$data), 4L)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g))
  result <- fmt_point(p, inherit.aes = FALSE, mapping = ggplot2::aes(x, y), sample_n = 2)
  expect_equal(nrow(result$layers[[1]]$data), 2L)
})

test_that("automatic dodging uses explicit and layer-local groups", {
  d <- data.frame(x = rep(c("x", "y"), each = 4), y = 1:8,
                  g = rep(c("a", "b"), 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = g))
  native <- ggplot2::ggplot_build(p + ggplot2::geom_point(
    position = ggplot2::position_dodge(width = 0.8)))$data[[1]]
  result <- ggplot2::ggplot_build(fmt_point(p))$data[[1]]
  expect_equal(result$x, native$x)
  reference <- if (utils::packageVersion("ggplot2") < "4.0.0")
    p + ggplot2::aes(fill = factor(g)) else p
  native_jitter <- ggplot2::ggplot_build(reference + ggplot2::geom_point(
    position = ggplot2::position_jitterdodge(jitter.width = 0.2,
      jitter.height = 0, dodge.width = 0.8, seed = 42)))$data[[1]]
  expect_equal(ggplot2::ggplot_build(fmt_point(p, type = "jitter"))$data[[1]]$x,
               native_jitter$x)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  result <- ggplot2::ggplot_build(fmt_point(p, mapping = ggplot2::aes(group = g)))$data[[1]]
  expect_equal(result$x, native$x)
  result <- ggplot2::ggplot_build(fmt_point(p, mapping = ggplot2::aes(group = g),
                                           dodge.width = 0))$data[[1]]
  expect_equal(as.numeric(result$x), rep(1:2, each = 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g))
  result <- fmt_point(p, inherit.aes = FALSE, mapping = ggplot2::aes(x, y))
  expect_s3_class(result$layers[[1]]$position, "PositionIdentity")
})

test_that("beeswarm arguments reach the position adjustment", {
  skip_if_not_installed("ggbeeswarm")
  p <- ggplot2::ggplot(data.frame(x = rep("a", 8), y = rep(1:4, 2)),
                       ggplot2::aes(x, y))
  result <- fmt_point(p, type = "beeswarm",
                      beeswarm.args = list(priority = "descending", side = 1))
  native <- p + ggbeeswarm::geom_beeswarm(size = 1, shape = 19,
    cex = 3, corral = "wrap", corral.width = 0.5, dodge.width = 0.8,
    priority = "descending", side = 1)
  expect_equal(ggplot2::ggplot_build(result)$data[[1]]$x,
               ggplot2::ggplot_build(native)$data[[1]]$x)
  expect_identical(result$layers[[1]]$position$priority, "descending")
  expect_equal(result$layers[[1]]$position$side, 1)
  if (requireNamespace("ragg", quietly = TRUE)) {
    capture <- function(q) {
      device <- ragg::agg_capture(width = 640, height = 480, res = 100)
      on.exit(grDevices::dev.off(), add = TRUE)
      print(q)
      device(native = TRUE)
    }
    expect_identical(capture(result), capture(native))
  }
  expect_error(fmt_point(p, type = "beeswarm", beeswarm.args = list(priorit = "none")),
               "beeswarm.args.*priorit")
  expect_error(fmt_point(p, type = "beeswarm", beeswarm.args = list(cex = 2, cex = 3)),
               "beeswarm.args.*unique")
})

test_that("sampling controls reject invalid sizes consistently", {
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  for (mapping in list(ggplot2::aes(x, y), ggplot2::aes(x, y, colour = g))) {
    p <- ggplot2::ggplot(d, mapping)
    for (invalid in list(2.5, -1, NA_real_, Inf, numeric(), c(1, 2), TRUE, "2")) {
      expect_error(fmt_point(p, sample_n = invalid), "sample_n.*non-negative integer")
    }
    expect_equal(nrow(fmt_point(p, sample_n = 0)$layers[[1]]$data), 0L)
    expect_error(fmt_point(p, sample_n = 2, seed = NA_real_), "seed")
  }
})

test_that("sampling groups cannot silently recycle incompatible lengths", {
  d <- data.frame(x = 1:6, y = 6:1)
  bad_groups <- c("a", "b")
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = bad_groups))
  expect_error(fmt_point(p, sample_n = 2), "colour.*length")
})

test_that("point layout controls fail early with argument-specific errors", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y))
  expect_error(fmt_point(p, dodge.width = -1), "dodge.width")
  expect_error(fmt_point(p, white_border = NA), "white_border")
  expect_error(fmt_point(p, rasterize = NA), "rasterize")
  expect_error(fmt_point(p, rasterize = TRUE, rasterize.dpi = 0), "rasterize.dpi")
  for (args in list(list(0.2), list(width = 0.2, width = 0.3),
                    stats::setNames(list(0.2), NA_character_), list(widht = 0.2))) {
    expect_error(fmt_point(p, type = "jitter", jitter.args = args), "jitter.args")
  }
  expect_error(fmt_point(p, type = "jitter", jitter.args = list(width = -1)),
               "jitter.args.*width")
  native <- p + ggplot2::geom_point(shape = 19, size = 1,
    position = ggplot2::position_jitter(width = NULL, height = 0, seed = 42))
  result <- fmt_point(p, type = "jitter", jitter.args = list(width = NULL))
  expect_equal(ggplot2::ggplot_build(result)$data[[1]]$x,
               ggplot2::ggplot_build(native)$data[[1]]$x)
})

test_that("stratified sampling preserves data frames with one or complex columns", {
  d <- data.frame(x = 1:12)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, x, colour = factor(x %% 2)))
  sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
  expect_s3_class(sampled, "data.frame")
  expect_identical(names(sampled), "x")
  expect_equal(nrow(sampled), 4L)
  expect_equal(as.integer(table(sampled$x %% 2)), c(2L, 2L))
  d <- data.frame(x = 1:12, y = 12:1,
    g = factor(rep(c("b", "a", NA), 4), levels = c("b", "a", "unused")),
    date = as.Date("2020-01-01") + 1:12)
  d$list_column <- as.list(seq_len(12))
  d$matrix_column <- I(matrix(seq_len(24), ncol = 2))
  for (input in list(d, tibble::as_tibble(d))) {
    p <- ggplot2::ggplot(input, ggplot2::aes(x, y, colour = g))
    sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
    expect_identical(class(sampled), class(input))
    expect_identical(names(sampled), names(input))
    expect_identical(levels(sampled$g), levels(input$g))
    expect_identical(sampled$date, input$date[sampled$x])
    expect_identical(sampled$list_column, input$list_column[sampled$x])
    expect_equal(as.vector(sampled$matrix_column),
                 as.vector(input$matrix_column[sampled$x, , drop = FALSE]))
    expect_identical(dim(sampled$matrix_column), c(6L, 2L))
    expect_equal(nrow(sampled), 6L)
  }
})

test_that("sampled white-border jitter also renders through rasterization", {
  skip_if_not_installed("ggrastr")
  skip_if_not_installed("ragg")
  d <- data.frame(x = rep(c("x", "y"), each = 6), y = 1:12,
                  g = rep(c("a", "b"), 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g))
  result <- fmt_point(p, type = "jitter", data = ~ utils::head(.x, 10),
    sample_n = 2, white_border = TRUE, rasterize = TRUE)
  built <- ggplot2::ggplot_build(result)$data[[1]]
  expect_equal(nrow(built), 4L)
  expect_equal(built$colour, rep("#FFFFFF", 4))
  device <- ragg::agg_capture(width = 640, height = 480, res = 100)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_no_warning(print(result))
  expect_identical(dim(device(native = TRUE)), c(480L, 640L))
})

test_that("sampling uses the start expression of staged group colours", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = ggplot2::stage(
    start = factor(g), after_scale = scales::alpha(colour, 0.5))))
  result <- fmt_point(p, sample_n = 2, white_border = TRUE)
  expect_equal(as.integer(table(result$layers[[1]]$data$g)), c(2L, 2L))
  built <- ggplot2::ggplot_build(result)$data[[1]]
  expect_equal(nrow(built), 4L)
  expect_setequal(built$fill, c("#F8766D80", "#00BFC480"))
})

test_that("white borders retain visible non-fillable and named symbols", {
  d <- data.frame(x = rep(letters[1:6], each = 2), y = rep(1:2, 6),
                  g = factor(rep(letters[1:6], each = 2)))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g, shape = g))
  result <- fmt_point(p, white_border = TRUE)
  built <- ggplot2::ggplot_build(result)$data[[1]]
  colours <- function(g) {
    if (inherits(g, "points")) return(as.character(g$gp$col))
    unlist(c(lapply(g$grobs, colours), lapply(g$children, colours)), use.names = FALSE)
  }
  drawn <- colours(ggplot2::ggplotGrob(result))
  expect_true(all(scales::alpha(built$fill[!built$shape %in% 21:25], 1) %in% drawn))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  for (shape in list("circle", "triangle", NULL)) {
    result <- fmt_point(p, shape = shape, colour = "red", white_border = TRUE)
    expect_no_warning(built <- ggplot2::ggplot_build(result)$data[[1]])
    expect_true(all(built$shape %in% 21:25))
    expect_equal(built$fill, rep("red", nrow(d)))
  }
})

test_that("sampling distinguishes stage functions from ordinary column names", {
  d <- data.frame(x = 1:12, y = 12:1, stage = factor(rep(c("I", "II", "III"), 4)))
  for (name in c("stage", "after_stat", "after_scale", "from_theme")) {
    names(d)[3] <- name
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = !!rlang::sym(name)))
    sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
    expect_equal(as.integer(table(sampled[[name]])), rep(2L, 3))
  }
  names(d)[3] <- "stage"
  for (mapping in list(ggplot2::aes(x, y, group = stage),
                      ggplot2::aes(x, y, colour = factor(stage)),
                      ggplot2::aes(x, y, colour = ggplot2::stage(start = stage)))) {
    sampled <- fmt_point(ggplot2::ggplot(d, mapping), sample_n = 2)$layers[[1]]$data
    expect_equal(as.integer(table(sampled$stage)), rep(2L, 3))
  }
})

test_that("unmapped dplyr grouping does not change sampling", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(letters[1:3], 4))
  expected <- fmt_point(ggplot2::ggplot(d, ggplot2::aes(x, y)), sample_n = 2)$layers[[1]]$data
  for (input in list(dplyr::group_by(d, g), dplyr::rowwise(d))) {
    out <- fmt_point(ggplot2::ggplot(input, ggplot2::aes(x, y)), sample_n = 2)
    sampled <- out$layers[[1]]$data
    expect_equal(nrow(sampled), 2L)
    expect_identical(class(sampled), class(input))
    expect_identical(sampled$x, expected$x)
    expect_no_warning(ggplot2::ggplot_build(out))
  }
})

test_that("continuous and null aesthetics do not trigger dodge", {
  d <- data.frame(x = rep(c("x", "y"), each = 6), y = 1:12)
  for (mapping in list(ggplot2::aes(x, y, colour = y), ggplot2::aes(x, y, size = y),
                      ggplot2::aes(x, y, alpha = y), ggplot2::aes(x, y, colour = NULL))) {
    p <- ggplot2::ggplot(d, mapping)
    expected <- ggplot2::ggplot_build(fmt_point(p, type = "jitter", dodge.width = 0))$data[[1]]
    for (data in list(NULL, ~ .x)) {
      actual <- ggplot2::ggplot_build(fmt_point(p, type = "jitter", data = data))$data[[1]]
      expect_identical(actual$x, expected$x)
      expect_identical(actual$y, expected$y)
    }
  }
})

test_that("ignored geom arguments cannot partially match formatting controls", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(letters[1:3], 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g))
  expect_warning(out <- fmt_point(p, sample_n = 2, inherit.aes_extra = FALSE),
                 "Ignoring unknown parameters")
  expect_equal(nrow(out$layers[[1]]$data), 6L)
  expect_true(out$layers[[1]]$inherit.aes)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  expect_warning(out <- fmt_point(p, white_border = TRUE, fill_extra = "red"),
                 "Ignoring unknown parameters")
  expect_equal(ggplot2::ggplot_build(out)$data[[1]]$fill, rep("black", nrow(d)))
})

test_that("sampling diagnoses row vectors outside layer data", {
  d <- data.frame(x = 1:12, y = 12:1)
  colours <- rep(c("red", "blue"), 6)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  expect_error(fmt_point(p, sample_n = 2, colour = colours), "Sampling.*scalar")
  for (mapping in list(ggplot2::aes(x, y, colour = .env$colours),
                      ggplot2::aes(x, y, colour = colours),
                      ggplot2::aes(x, y, colour = factor(.env[["colours"]])))) {
    p <- ggplot2::ggplot(d, mapping)
    expect_error(fmt_point(p, sample_n = 2), "Sampling.*external")
    deferred <- fmt_point(p, data = ~ .x, sample_n = 2)
    expect_error(ggplot2::ggplot_build(deferred), "Sampling.*external")
    expect_no_warning(ggplot2::ggplot_build(fmt_point(p, sample_n = 20)))
  }
  d$colours <- colours
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = colours))
  expect_equal(nrow(ggplot2::ggplot_build(fmt_point(p, sample_n = 2))$data[[1]]), 4L)
  d$matrix_column <- I(matrix(1:24, nrow = 12))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, matrix_column[, 1], colour = colours))
  expect_equal(nrow(ggplot2::ggplot_build(fmt_point(p, sample_n = 2))$data[[1]]), 4L)
})

test_that("explicit positions override automatic point positioning", {
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g))
  expected <- ggplot2::ggplot_build(p + ggplot2::geom_point(
    position = ggplot2::position_nudge(x = 1, y = 2)))$data[[1]]
  for (type in c("point", "jitter")) {
    actual <- ggplot2::ggplot_build(fmt_point(p, type = type,
      position = ggplot2::position_nudge(x = 1, y = 2)))$data[[1]]
    expect_identical(actual$x, expected$x)
    expect_identical(actual$y, expected$y)
  }
})
