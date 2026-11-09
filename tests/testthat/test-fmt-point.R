test_that("point position options reject table containers only on active paths", {
  expect_error(fmt_point(stop("plot evaluated"), type = "jitter",
    jitter.args = data.frame(width = .2)), "jitter.args")
  expect_error(fmt_point(stop("plot evaluated"), type = "beeswarm",
    beeswarm.args = data.frame(cex = 3)), "beeswarm.args")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x))
  built <- ggplot2::ggplot_build(fmt_point(p, jitter.args = stop("unused"),
    beeswarm.args = stop("unused")))
  expect_equal(built$data[[1]]$x, 1:3)
})

test_that("white borders resolve stage masks in isolated mapping environments", {
  d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2))
  mapping <- ggplot2::aes(x, y, colour = g, shape = g)
  mapping[] <- lapply(mapping, function(x)
    rlang::new_quosure(rlang::get_expr(x), baseenv()))
  p <- ggplot2::ggplot(d, mapping) +
    ggplot2::scale_shape_manual(values = c(a = 16, b = 17))
  native <- ggplot2::ggplot_build(p + ggplot2::geom_point())$data[[1L]]
  built <- ggplot2::ggplot_build(fmt_point(p, white_border = TRUE))$data[[1L]]
  expect_identical(built$colour, rep("#FFFFFF", 4))
  expect_identical(built$fill, native$colour)
  expect_equal(built$shape, c(21, 24, 21, 24))
})

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

test_that("sampling keeps numeric groups with identical printed labels separate", {
  values <- c(1, 1 + 1e-15, 1 + 2e-15)
  d <- data.frame(x = 1:12, y = 12:1, g = rep(values, each = 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = g))
  for (data in list(NULL, ~ .x, identity)) {
    out <- fmt_point(p, data = data, sample_n = 2, dodge.width = 0)
    built <- ggplot2::ggplot_build(out)$data[[1]]
    expect_equal(nrow(built), 6L)
    expect_equal(tabulate(match(d$g[built$x], values), nbins = 3), rep(2L, 3))
  }
  expect_identical(p$data, d)
})

test_that("numeric sampling strata retain infinities and distinct missing values", {
  values <- c(-Inf, 1, 1 + 1e-15, Inf)
  d <- data.frame(x = 1:24, y = 24:1,
                  g = rep(c(values, NA_real_, NaN), each = 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = g))
  withr::local_seed(321)
  before <- .Random.seed
  for (k in c(0L, 2L, 10L)) {
    sampled <- fmt_point(p, sample_n = k)$layers[[1]]$data
    counts <- vapply(values, function(value) sum(sampled$g == value, na.rm = TRUE),
                     integer(1))
    expect_equal(counts, rep(min(4L, k), 4))
    expect_equal(sum(is.nan(sampled$g)), min(4L, k))
    expect_equal(sum(is.na(sampled$g) & !is.nan(sampled$g)), min(4L, k))
    expect_equal(nrow(sampled), 6L * min(4L, k))
    expect_identical(.Random.seed, before)
  }
  expect_identical(p$data, d)
})

test_that("numeric sampling preserves existing factor group ordering", {
  d <- data.frame(x = 1:28, y = 28:1,
                  g = rep(c(7, -Inf, 0, Inf, -3, NA_real_, NaN), each = 4))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = g))
  reference <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = factor(g)))
  for (k in c(0L, 2L, 7L)) {
    expect_identical(fmt_point(p, sample_n = k)$layers[[1]]$data,
                     fmt_point(reference, sample_n = k)$layers[[1]]$data)
  }
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
  stage <- ggplot2::stage
  d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g, shape = g)) +
    ggplot2::scale_shape_manual(values = c(a = 16, b = 17))
  result <- ggplot2::ggplot_build(fmt_point(p, white_border = TRUE))$data[[1]]
  expect_equal(result$shape, c(21, 24, 21, 24))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y,
    colour = stage(start = g, after_scale = scales::alpha(colour, 0.5))))
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
  expect_no_warning(result <- fmt_point(p, shape = NA_character_, white_border = TRUE))
  expect_true(all(is.na(ggplot2::ggplot_build(result)$data[[1]]$shape)))
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

test_that("sampling preserves joint aesthetic and existing facet strata", {
  d <- expand.grid(g = c("a", "b"), h = c("c", "d"), panel = c("u", "v", "w"),
                    replicate = 1:5)
  d$x <- seq_len(nrow(d))
  d$y <- rev(d$x)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g, fill = h)) +
    ggplot2::facet_wrap(~ panel)
  for (data in list(NULL, ~ .x)) {
    out <- fmt_point(p, sample_n = 2, data = data)
    built <- ggplot2::ggplot_build(out)$data[[1]]
    expect_equal(nrow(built), 24L)
    expect_true(all(table(built$colour, built$fill, built$PANEL) == 2L))
  }
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, group = g, colour = h)) +
    ggplot2::facet_grid(rows = ggplot2::vars(panel))
  sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
  expect_equal(as.integer(table(sampled$g, sampled$panel)), rep(2L, 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::facet_wrap(~ panel)
  sampled <- fmt_point(p, sample_n = 2)$layers[[1]]$data
  expect_equal(as.integer(table(sampled$panel)), rep(2L, 3))
  layer_data <- d[c("x", "y")]
  out <- fmt_point(p, data = layer_data, sample_n = 2)
  expect_equal(nrow(ggplot2::ggplot_build(out)$data[[1]]), 6L)
})

test_that("joint sampling retains lexical group order and matrix columns", {
  d <- expand.grid(g = letters[1:12], h = c("u", "v"), replicate = 1:3)
  d$g <- factor(d$g, levels = c("unused", letters[1:12], "last"))
  d$x <- seq_len(nrow(d))
  d$y <- rev(d$x)
  d$matrix <- I(matrix(seq_len(nrow(d) * 2), ncol = 2,
    dimnames = list(paste0("r", d$x), c("one", "two"))))
  expected <- c(9L, 21L, 10L, 22L, 35L, 47L, 36L, 24L, 49L, 61L, 2L, 14L,
                27L, 39L, 28L, 64L, 53L, 17L, 6L, 66L, 7L, 67L, 8L, 20L)
  for (input in list(d, tibble::as_tibble(d))) {
    p <- ggplot2::ggplot(input, ggplot2::aes(x, y, colour = g, fill = h))
    sampled <- fmt_point(p, sample_n = 1)$layers[[1L]]$data
    expect_identical(sampled$x, expected)
    expect_identical(levels(sampled$g), levels(input$g))
    expect_identical(class(sampled), class(input))
    expect_equal(as.vector(sampled$matrix),
                 as.vector(input$matrix[expected, , drop = FALSE]))
    expect_identical(p$data, input)
  }
})

test_that("sampling keeps exact numeric facet values in joint strata", {
  values <- c(1, 1 + 1e-15, 1 + 2e-15)
  d <- expand.grid(g = c("a", "b"), panel = values, replicate = 1:4)
  d$x <- seq_len(nrow(d))
  d$y <- rev(d$x)
  for (mapping in list(ggplot2::aes(x, y), ggplot2::aes(x, y, colour = g))) {
    p <- ggplot2::ggplot(d, mapping) + ggplot2::facet_wrap(~ panel)
    expected <- if (is.null(mapping$colour)) rep(2L, 3) else rep(4L, 3)
    for (data in list(NULL, ~ .x, identity)) {
      out <- fmt_point(p, data = data, sample_n = 2, dodge.width = 0)
      built <- ggplot2::ggplot_build(out)$data[[1]]
      panel_ids <- match(d$panel[built$x], values)
      expect_equal(tabulate(panel_ids, nbins = 3), expected)
      if (!is.null(mapping$colour)) {
        expect_equal(as.integer(table(built$colour, panel_ids)), rep(2L, 6))
      }
    }
    expect_identical(p$data, d)
  }
})

test_that("returned point layers do not retain unrelated plot leaves", {
  make_plot <- function(n) {
    p <- ggplot2::ggplot(data.frame(x = rep(c("a", "b"), length.out = n),
      y = rep(1, n)), eval(quote(ggplot2::aes(x, y)), baseenv()))
    p$plot_env <- baseenv()
    p
  }
  environment(make_plot) <- baseenv()
  make_result <- function(n, settings) {
    do.call(fmt_point, c(list(plot = list(make_plot(12), make_plot(n))), settings))[[1L]]
  }
  environment(make_result) <- list2env(list(make_plot = make_plot, fmt_point = fmt_point),
                                      parent = baseenv())
  cases <- list(list(), list(sample_n = 2), list(white_border = TRUE),
    list(type = "jitter"), list(position = "identity"),
    list(data = rlang::new_formula(NULL, quote(.x), baseenv()), sample_n = 2))
  if (requireNamespace("ggbeeswarm", quietly = TRUE))
    cases <- c(cases, list(list(type = "beeswarm")))
  if (requireNamespace("ggrastr", quietly = TRUE))
    cases <- c(cases, list(list(rasterize = TRUE)))
  for (settings in cases) {
    small <- make_result(12L, settings)
    large <- make_result(2000L, settings)
    expect_equal(length(serialize(large, NULL)), length(serialize(small, NULL)))
    restored <- unserialize(serialize(large, NULL))
    expect_identical(ggplot2::ggplot_build(restored)$data,
                     ggplot2::ggplot_build(small)$data)
  }
})

test_that("factor configuration vectors do not count as external rows", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(c("Jan", "Feb"), 6))
  levels <- month.abb
  labels <- tolower(levels)
  mappings <- list(
    ggplot2::aes(x, y, colour = factor(g, levels = month.abb)),
    ggplot2::aes(x, y, colour = base::factor(g, .env$levels, .env$labels)),
    ggplot2::aes(x, y, colour = ordered(g, levels = .env$levels)))
  for (mapping in mappings) for (data in list(NULL, ~ .x)) {
    p <- ggplot2::ggplot(d, mapping)
    out <- fmt_point(p, sample_n = 2, data = data, dodge.width = 0)
    built <- ggplot2::ggplot_build(out)$data[[1L]]
    expect_equal(nrow(built), 4L)
    expect_equal(as.integer(table(built$colour)), c(2L, 2L))
  }
  colours <- rep(c("red", "blue"), 6)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = factor(colours, levels = colours)))
  expect_error(fmt_point(p, sample_n = 2), "Sampling.*external")
})

test_that("cut configuration vectors do not count as external rows", {
  d <- data.frame(x = 1:6, y = 6:1)
  breaks <- c(0, 2, 4, 6, 8, 10)
  labels <- letters[1:6]
  mappings <- list(
    ggplot2::aes(x, y, colour = cut(y, breaks = breaks)),
    ggplot2::aes(x, y, colour = base::cut(y, .env$breaks)),
    ggplot2::aes(x, y, colour = cut(y, 0:6, labels = .env$labels)))
  for (i in seq_along(mappings)) for (data in list(NULL, ~ .x, identity)) {
    p <- ggplot2::ggplot(d, mappings[[i]])
    out <- fmt_point(p, sample_n = 1, data = data, dodge.width = 0)
    built <- ggplot2::ggplot_build(out)$data[[1L]]
    expect_equal(nrow(built), c(3L, 3L, 6L)[[i]])
    expect_equal(as.integer(table(built$colour)), rep(1L, nrow(built)))
  }
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    ggplot2::facet_wrap(ggplot2::vars(cut(y, breaks = .env$breaks)))
  out <- fmt_point(p, sample_n = 1)
  expect_equal(as.integer(table(ggplot2::ggplot_build(out)$data[[1L]]$PANEL)),
               c(1L, 1L, 1L))
})

test_that("cut configuration handling still rejects external row inputs", {
  d <- data.frame(x = 1:6, y = 6:1)
  external <- d$y
  breaks <- c(0, 2, 4, 6, 8, 10)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y,
    colour = base::cut(.env$external, breaks = breaks)))
  expect_error(fmt_point(p, sample_n = 1), "Sampling.*external")
  cut <- function(x, breaks) ifelse(x > breaks, "high", "low")
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = cut(y, breaks)))
  expect_error(fmt_point(p, sample_n = 1), "Sampling.*external")
})

test_that("sampling accepts anonymous and dynamically selected functions", {
  d <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6))
  transform <- factor
  factory <- function() factor
  mappings <- list(
    ggplot2::aes(x, y, colour = (function(z) factor(z))(g)),
    ggplot2::aes(x, y, colour = (.env$transform)(g)),
    ggplot2::aes(x, y, colour = (factory())(g)))
  expected <- fmt_point(ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)),
    sample_n = 2, dodge.width = 0)
  for (mapping in mappings) for (data in list(NULL, ~ .x)) {
    p <- ggplot2::ggplot(d, mapping)
    out <- fmt_point(p, sample_n = 2, data = data, dodge.width = 0)
    expect_identical(ggplot2::ggplot_build(out)$data,
                     ggplot2::ggplot_build(expected)$data)
  }
  colours <- rep(c("red", "blue"), 6)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = (function(z) z)(colours)))
  expect_error(fmt_point(p, sample_n = 2), "Sampling.*external")
})

test_that("point leaves snapshot explicit and inherited position settings", {
  d <- data.frame(x = 1:6, y = 6:1)
  for (type in c("point", "jitter")) {
    parent <- ggplot2::position_nudge(x = 1, y = 2)
    position <- ggplot2::ggproto("PositionPointTest", parent)
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
      ggplot2::geom_point(position = position)
    out <- fmt_point(list(p, p), type = type, position = position)
    expected <- ggplot2::ggplot_build(p + ggplot2::geom_point(size = 1, shape = 19,
      position = ggplot2::position_nudge(x = 1, y = 2)))$data[[2L]]
    expect_identical(ggplot2::ggplot_build(out[[1L]])$data[[2L]], expected)
    expect_s3_class(out[[1L]]$layers[[2L]]$position, "PositionPointTest")
    position$x <- 3
    parent$y <- 4
    expect_equal(out[[1L]]$layers[[2L]]$position$x, 1)
    expect_equal(out[[2L]]$layers[[2L]]$position$y, 2)
    expect_identical(ggplot2::ggplot_build(out[[2L]])$data[[2L]], expected)
    out[[1L]]$layers[[2L]]$position$x <- 9
    expect_equal(out[[2L]]$layers[[2L]]$position$x, 1)
    expect_equal(position$x, 3)
    expect_equal(parent$x, 1)
    expect_identical(p$layers[[1L]]$position, position)
  }
})

test_that("point aliases override omitted defaults and mapped aesthetics", {
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  plain <- ggplot2::ggplot(d, ggplot2::aes(x, y))
  expect_no_warning(out <- fmt_point(plain, pch = 17, cex = 4))
  expect_identical(ggplot2::ggplot_build(out)$data,
                   ggplot2::ggplot_build(plain + ggplot2::geom_point(pch = 17, cex = 4))$data)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, shape = g, size = y))
  native <- p + ggplot2::geom_point(pch = 17, cex = 4)
  for (type in c("point", "jitter")) {
    expect_no_warning(out <- fmt_point(p, type = type, pch = 17, cex = 4,
      position = "identity"))
    expect_identical(ggplot2::ggplot_build(out)$data, ggplot2::ggplot_build(native)$data)
    expect_no_warning(out <- fmt_point(p, type = type, shape = 15, size = 2,
      pch = 17, cex = 4, position = "identity"))
    built <- ggplot2::ggplot_build(out)$data[[1L]]
    expect_equal(built$shape, rep(15, 6))
    expect_equal(built$size, rep(2, 6))
  }
  expect_no_warning(out <- fmt_point(p, pch = 17, cex = 4, white_border = TRUE))
  expected <- fmt_point(p, shape = 17, size = 4, white_border = TRUE)
  expect_identical(ggplot2::ggplot_build(out)$data, ggplot2::ggplot_build(expected)$data)
  expect_error(fmt_point(p, sample_n = 2, cex = 1:6), "Sampling.*scalar")
  if (requireNamespace("ggbeeswarm", quietly = TRUE)) {
    expect_no_warning(out <- fmt_point(p, type = "beeswarm", pch = 17, cex = 5,
      beeswarm.args = list(cex = 2)))
    expected <- fmt_point(p, type = "beeswarm", shape = 17, beeswarm.args = list(cex = 2))
    expect_identical(ggplot2::ggplot_build(out)$data, ggplot2::ggplot_build(expected)$data)
  }
})

test_that("unused sampling strata retain factor levels and matrix attributes", {
  d <- data.frame(x = 1:24, y = 24:1,
    g = factor(rep(c("b", "a", NA), 8),
      levels = c("unused_first", "b", "unused_middle", "a", "unused_last")))
  d$matrix <- I(matrix(1:48, ncol = 2,
    dimnames = list(paste0("row", 1:24), c("one", "two"))))
  for (input in list(d, tibble::as_tibble(d))) for (k in c(0, 2)) {
    p <- ggplot2::ggplot(input, ggplot2::aes(x, y, group = g, colour = g)) +
      ggplot2::scale_colour_discrete(drop = FALSE)
    reference <- p
    reference$mapping$group <- ggplot2::aes(group = droplevels(g))$group
    withr::local_seed(321)
    before <- .Random.seed
    out <- fmt_point(p, sample_n = k)
    expected <- fmt_point(reference, sample_n = k)
    expect_equal(nrow(out$layers[[1L]]$data), 3L * k)
    expect_identical(out$layers[[1L]]$data, expected$layers[[1L]]$data)
    expect_identical(ggplot2::ggplot_build(out)$data, ggplot2::ggplot_build(expected)$data)
    expect_identical(levels(out$layers[[1L]]$data$g), levels(input$g))
    expect_identical(p$data, input)
    expect_identical(.Random.seed, before)
  }
})

test_that("white-border shape names retain missing entries in either order", {
  data <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(data, ggplot2::aes(x, y))
  for (shape in list(c(NA_character_, "circle open", "square open"),
                     c("circle open", NA_character_, "square open"))) {
    out <- fmt_point(p, shape = shape, white_border = TRUE)
    expected <- ifelse(is.na(shape), NA_real_, ifelse(shape == "circle open", 21, 22))
    expect_identical(ggplot2::ggplot_build(out)$data[[1]]$shape, expected)
  }
})

test_that("point sampling and positioning controls reject encoded or dimensional scalars", {
  for (arg in c("sample_n", "seed", "dodge.width", "rasterize.dpi")) {
    for (bad in list(matrix(1), structure(1, class = "integer64"))) {
      args <- list(plot = quote(stop("plot evaluated")))
      if (arg == "seed") args$sample_n <- 1
      if (arg == "rasterize.dpi") args$rasterize <- TRUE
      args[arg] <- list(bad)
      expect_error(do.call(fmt_point, args), arg)
    }
  }
  for (arg in c("white_border", "rasterize")) {
    args <- list(plot = quote(stop("plot evaluated")))
    args[arg] <- list(matrix(TRUE))
    expect_error(do.call(fmt_point, args), arg)
  }
  expect_error(fmt_point(stop("plot evaluated"), type = "jitter",
                          jitter.args = list(width = matrix(.2))), "jitter.args")
})

test_that("point sampling retains cold integer64 strata", {
  skip_if_not_installed("bit64")
  directory <- withr::local_tempdir()
  functions <- file.path(directory, "sample.R")
  fixture <- file.path(directory, "input.rds")
  script <- file.path(directory, "verify.R")
  dump(c(".fmt_point_sample", ".fmt_point_stage_args"), functions, envir = environment(fmt_point))
  d <- data.frame(x = 1:8, y = 8:1)
  d[["id"]] <- bit64::as.integer64(rep(c("-1", "-2", "-3", "-4"), each = 2L))
  saveRDS(d, fixture)
  writeLines(c(sprintf("source(%s)", deparse(functions)),
    sprintf("d <- readRDS(%s)", deparse(fixture)),
    "stopifnot(!('bit64' %in% loadedNamespaces()))",
    "result <- .fmt_point_sample(d, ggplot2::aes(x, y, group = id), sample_n = 1, seed = 42)",
    "stopifnot(nrow(result) == 4L, identical(sort(as.character(result$id)), c('-1', '-2', '-3', '-4')))",
    "cat('COLD_SAMPLE_OK\n')"), script)
  output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
  expect_identical(tail(output, 1L), 'COLD_SAMPLE_OK')
  p <- fmt_point(ggplot2::ggplot(d, ggplot2::aes(x, y, group = id)), sample_n = 1)
  expect_equal(nrow(p$layers[[1L]]$data), 4L)
})

test_that("point sampling preserves typed time strata and their source columns", {
  skip_if_not_installed("lubridate")
  values <- list(as.Date(c(1, 1.5), origin = "1970-01-01"),
    as.POSIXct(c(1, 1 + .Machine$double.eps), origin = "1970-01-01", tz = "UTC"),
    as.difftime(c(1, 1 + .Machine$double.eps), units = "secs"),
    lubridate::seconds(c(1, 1 + .Machine$double.eps)),
    lubridate::dseconds(c(1, 1 + .Machine$double.eps)))
  withr::local_seed(321)
  before_seed <- .Random.seed
  for (value in values) {
    d <- data.frame(x = 1:8, y = 8:1)
    d$g <- rep(value, each = 4)
    before <- serialize(d, NULL)
    for (facet in c(FALSE, TRUE)) {
      p <- if (facet) ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::facet_wrap(~g) else
        ggplot2::ggplot(d, ggplot2::aes(x, y, group = g))
      sampled <- fmt_point(p, sample_n = 1)$layers[[1L]]$data
      expect_equal(nrow(sampled), 2L)
      expect_length(vctrs::vec_unique(sampled$g), 2L)
      expect_identical(class(sampled$g), class(d$g))
      expect_identical(serialize(d, NULL), before)
      expect_identical(.Random.seed, before_seed)
    }
  }
})

test_that("point sampling separates explicit NA factor levels from missing codes", {
  for (class in list("factor", c("ordered", "factor"))) {
    d <- data.frame(x = 1:8, y = 8:1)
    d$g <- structure(rep(c(1L, NA_integer_), each = 4), levels = NA_character_, class = class)
    for (facet in c(FALSE, TRUE)) for (k in c(0, 1, 3)) {
      p <- if (facet) ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::facet_wrap(~g) else
        ggplot2::ggplot(d, ggplot2::aes(x, y, group = g))
      sampled <- fmt_point(p, sample_n = k)$layers[[1L]]$data
      expect_equal(nrow(sampled), 2L * k)
      expect_equal(sum(is.na(sampled$g)), k)
      expect_equal(sum(!is.na(sampled$g)), k)
      expect_identical(levels(sampled$g), levels(d$g))
      expect_identical(class(sampled$g), class(d$g))
    }
  }
})
