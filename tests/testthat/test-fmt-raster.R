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
