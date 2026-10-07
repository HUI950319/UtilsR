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
