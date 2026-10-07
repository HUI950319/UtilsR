raster_find_grobs <- function(g, cls) {
  kids <- if (inherits(g, "gtable")) g$grobs else if (inherits(g, "gTree")) g$children
  c(if (inherits(g, cls)) list(g),
    unlist(lapply(kids, raster_find_grobs, cls = cls), recursive = FALSE))
}

test_that("ragg preserves every panel and the labels of nested patchworks", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  plots <- list(p | (p + ggplot2::labs(title = "Second")),
                (p | (p + ggplot2::labs(title = "Second"))) /
                  (p + ggplot2::labs(title = "Third")))
  for (i in seq_along(plots)) {
    result <- fmt_raster(plots[[i]], method = "ragg", dpi = 72,
                         width = 1, height = 1)
    gt <- patchwork::patchworkGrob(result)
    expect_length(raster_find_grobs(gt, "rastergrob"), i + 1L)
    labels <- unlist(lapply(raster_find_grobs(gt, "text"), function(g) g$label))
    expect_true("Second" %in% labels)
    if (i == 2) expect_true("Third" %in% labels)
  }
})

test_that("unclipped panels retain geometry outside the panel", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("ggrastr")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  files <- replicate(3, tempfile(fileext = ".png"))
  on.exit(unlink(files), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1.08, y = 0.5), ggplot2::aes(x, y)) +
    ggplot2::geom_point(size = 14, colour = "red") +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, 1),
                             expand = FALSE, clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(0, 50, 0, 50))
  expect_warning(a <- fmt_raster(p, method = "ggrastr", dpi = 100), "clipping.*vectors")
  expect_warning(b <- fmt_raster(p, method = "ragg", dpi = 100,
                                 width = 2, height = 2), "clipping.*vectors")
  plots <- list(p, a, b)
  for (i in seq_along(plots)) {
    ragg::agg_png(files[i], width = 4, height = 3, units = "in", res = 100)
    print(plots[[i]])
    grDevices::dev.off()
  }
  red_pixels <- vapply(files, function(file) {
    image <- png::readPNG(file)
    sum(image[, , 1] > 0.7 & image[, , 2] < 0.4 & image[, , 3] < 0.4)
  }, numeric(1), USE.NAMES = FALSE)
  expect_gt(red_pixels[1], 1000)
  expect_equal(red_pixels[2], red_pixels[1])
  expect_gt(red_pixels[3], red_pixels[1] * 0.9)
})

test_that("ragg restores graphics devices after success and draw errors", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  initial <- grDevices::dev.list()
  on.exit({
    for (id in setdiff(grDevices::dev.list(), initial)) grDevices::dev.off(id)
  }, add = TRUE)
  grDevices::pdf(NULL)
  grDevices::pdf(NULL)
  current <- grDevices::dev.cur()
  devices <- grDevices::dev.list()
  p <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  fmt_raster(p, method = "ragg", dpi = 72, width = 1, height = 1)
  expect_identical(grDevices::dev.cur(), current)
  expect_identical(grDevices::dev.list(), devices)

  grDevices::dev.set(current)
  bad_geom <- ggplot2::ggproto("GeomBadColour", ggplot2::Geom,
    required_aes = c("x", "y"),
    draw_panel = function(data, panel_params, coord) {
      grid::rectGrob(name = "bad_geometry", gp = grid::gpar(fill = "invalid-colour"))
    }
  )
  bad <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::layer(geom = bad_geom, stat = "identity", position = "identity")
  expect_error(fmt_raster(bad, method = "ragg", dpi = 72, width = 1, height = 1),
               "invalid color")
  expect_identical(grDevices::dev.cur(), current)
  expect_identical(grDevices::dev.list(), devices)
})

test_that("invalid resolutions and panel dimensions fail before the backend", {
  local_mocked_bindings(
    .fmt_raster_ragg = function(...) stop("backend was called"),
    .fmt_raster_ggrastr = function(...) stop("backend was called"),
    .package = "UtilsR"
  )
  for (method in c("ragg", "ggrastr")) {
    for (value in list(0, -1, NA_real_, Inf, numeric(), c(72, 100), "300")) {
      expect_error(fmt_raster(NULL, method = method, dpi = value), "dpi.*positive")
    }
  }
  for (argument in c("width", "height")) {
    for (value in list(0, -1, NA_real_, Inf, numeric(), "2")) {
      args <- c(list(plot = NULL, method = "ragg"), setNames(list(value), argument))
      expect_error(do.call(fmt_raster, args), paste0(argument, ".*positive"))
    }
  }
})

test_that("ragg keeps the draw order between text and geometry", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  files <- c(tempfile(fileext = ".png"), tempfile(fileext = ".png"))
  on.exit(unlink(files), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 0.5, y = 0.5), ggplot2::aes(x, y)) +
    ggplot2::geom_text(label = "COVERED", colour = "black", size = 10) +
    ggplot2::annotate("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1,
                       fill = "red") +
    ggplot2::scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
    ggplot2::scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    ggplot2::theme_void()
  result <- fmt_raster(p, method = "ragg", dpi = 72, width = 2, height = 2)
  for (i in 1:2) {
    ragg::agg_png(files[i], width = 2, height = 2, units = "in", res = 72)
    print(if (i == 1) p else result)
    grDevices::dev.off()
  }
  black_pixels <- function(file) {
    image <- png::readPNG(file)
    sum(image[, , 1] < 0.2 & image[, , 2] < 0.2 & image[, , 3] < 0.2)
  }
  expect_equal(black_pixels(files[1]), 0)
  expect_equal(black_pixels(files[2]), 0)
  gt <- attr(result, "grobs")$full
  expect_length(raster_find_grobs(gt, "text"), 1L)
})

test_that("ragg rejects positive panel dimensions smaller than one pixel", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  expect_error(fmt_raster(p, method = "ragg", dpi = 72, width = 0.1,
                          height = 10, units = "mm"), "at least one pixel")
})
