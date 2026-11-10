raster_find_grobs <- function(g, cls) {
  kids <- if (inherits(g, "gtable")) g$grobs else if (inherits(g, "gTree")) g$children
  c(if (inherits(g, cls)) list(g),
    unlist(lapply(kids, raster_find_grobs, cls = cls), recursive = FALSE))
}

test_that("layer raster devices require scalar selectors only for active targets", {
  skip_if_not_installed("ggrastr")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x))
  for (bad in list(matrix("ragg"), NA_character_, character(), list("ragg")))
    expect_error(fmt_raster(p + ggplot2::geom_point(), dev = bad), "dev")
  lines <- p + ggplot2::geom_line()
  expect_identical(fmt_raster(lines, dev = stop("inactive")), lines)
  expect_s3_class(fmt_raster(p + ggplot2::geom_point(), dev = "ragg"), "ggplot")
})

test_that("image renders the whole plot, text included, into one raster", {
  skip_if_not_installed("ragg")
  grDevices::pdf(NULL, width = 10, height = 6)
  on.exit(grDevices::dev.off(), add = TRUE)
  device <- grDevices::dev.cur()
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::labs(title = "Title")

  result <- fmt_raster(p, method = "image", dpi = 50, width = 2, height = 1.5)
  expect_true(inherits(result, "patchwork"))
  expect_identical(attr(result, "size"),
                   list(width = 2, height = 1.5, units = "in"))
  full <- attr(result, "grobs")$full
  rasters <- raster_find_grobs(full, "rastergrob")
  expect_length(rasters, 1L)
  expect_equal(dim(rasters[[1]]$raster), c(75L, 100L))
  expect_length(raster_find_grobs(full, "text"), 0L)
  expect_identical(grDevices::dev.cur(), device)

  # Without a size the open device's size is used, in `units`.
  auto <- fmt_raster(p, method = "image", dpi = 10, units = "cm")
  expect_equal(attr(auto, "size"),
               list(width = 25.4, height = 15.24, units = "cm"))

  named <- fmt_raster(list(a = p, b = p), method = "image", dpi = 10,
                      width = 1, height = 1)
  expect_named(named, c("a", "b"))
  expect_error(fmt_raster(p, method = "image", width = c(1, 2), height = 1),
               "width")
})

test_that("image draws recorded plots and other printable objects", {
  skip_if_not_installed("ragg")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  grDevices::dev.control(displaylist = "enable")
  graphics::plot(1:3)
  recorded <- grDevices::recordPlot()
  # A classed list drawn by its own print method, as a forestplot is.
  rlang::local_bindings(print.fmt_raster_test_plot = function(x, ...) {
    grid::grid.newpage()
    grid::grid.rect(gp = grid::gpar(fill = "red", col = NA))
    invisible(x)
  }, .env = globalenv())
  drawn <- structure(list(1), class = "fmt_raster_test_plot")

  # Large enough for the base plot's default margins.
  result <- fmt_raster(list(recorded = recorded, drawn = drawn),
                       method = "image", dpi = 10, width = 4, height = 4)
  expect_named(result, c("recorded", "drawn"))
  pixels <- lapply(result, function(r) {
    raster_find_grobs(attr(r, "grobs")$full, "rastergrob")[[1]]$raster
  })
  expect_true(any(bitwAnd(bitwShiftR(pixels$recorded, 24), 255L) > 0))
  centre <- pixels$drawn[20, 20]
  expect_equal(c(bitwAnd(centre, 255L), bitwAnd(bitwShiftR(centre, 8), 255L)),
               c(255, 0))
  expect_error(fmt_raster(list(drawn, NULL), method = "image"), "All elements")
})

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
    result <- fmt_raster(plots[[i]], method = "ragg", dpi = 72)
    gt <- patchwork::patchworkGrob(result)
    expect_length(raster_find_grobs(gt, "rastergrob"), i + 1L)
    labels <- unlist(lapply(raster_find_grobs(gt, "text"), function(g) g$label))
    expect_true("Second" %in% labels)
    if (i == 2) expect_true("Third" %in% labels)
  }
})

test_that("ragg native capture retains transparent and translucent pixels", {
  skip_if_not_installed("ragg")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot() +
    ggplot2::annotate("rect", xmin = 0.25, xmax = 0.75, ymin = 0.25, ymax = 0.75,
                       fill = "red", colour = NA, alpha = 0.5) +
    ggplot2::scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
    ggplot2::scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    ggplot2::theme_void()
  result <- fmt_raster(p, method = "ragg", dpi = 72, width = 1, height = 1)
  raster <- raster_find_grobs(attr(result, "grobs")$full, "rastergrob")[[1]]$raster
  expect_s3_class(raster, "nativeRaster")
  expect_equal(dim(raster), c(72L, 72L))
  pixels <- raster[cbind(c(1, 36), c(1, 36))]
  colours <- vapply(c(0, 8, 16, 24), function(shift) {
    bitwAnd(bitwShiftR(pixels, shift), 255L)
  }, integer(2))
  expect_equal(unname(colours[1, 4]), 0)
  expect_equal(unname(colours[2, ]), c(255, 0, 0, 128))
})

test_that("ragg detects custom text and rasterizes viewport geometry", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  base <- ggplot2::ggplot(data.frame(x = 0.5, y = 0.5), ggplot2::aes(x, y)) +
    ggplot2::theme_void()
  custom_text <- ggplot2::ggproto("GeomCustomText", ggplot2::Geom,
    required_aes = c("x", "y"),
    draw_panel = function(data, panel_params, coord) {
      grid::textGrob("custom text", name = "custom_content")
    }
  )
  text_plot <- base + ggplot2::layer(geom = custom_text, stat = "identity",
                                     position = "identity")
  text_result <- fmt_raster(text_plot, method = "ragg", dpi = 72,
                            width = 1, height = 1)
  expect_length(raster_find_grobs(attr(text_result, "grobs")$full, "text"), 1L)

  geometry <- base + ggplot2::annotation_custom(
    grid::rectGrob(name = "custom_geometry", gp = grid::gpar(fill = "red")))
  geom_result <- fmt_raster(geometry, method = "ragg", dpi = 72,
                            width = 1, height = 1)
  gt <- attr(geom_result, "grobs")$full
  panel <- gt$grobs[[which(gt$layout$name == "panel")]]
  expect_length(raster_find_grobs(panel, "rastergrob"), 1L)
  expect_length(raster_find_grobs(panel, "rect"), 0L)

  mixed <- ggplot2::ggproto("GeomMixedContent", custom_text,
    draw_panel = function(data, panel_params, coord) {
      grid::gTree(name = "custom_mixed", children = grid::gList(
        grid::rectGrob(), grid::textGrob("mixed content", name = "custom_content")))
    }
  )
  mixed_plot <- base + ggplot2::layer(geom = mixed, stat = "identity",
                                      position = "identity")
  mixed_result <- fmt_raster(mixed_plot, method = "ragg", dpi = 72,
                             width = 1, height = 1)
  expect_length(raster_find_grobs(attr(mixed_result, "grobs")$full, "text"), 1L)
})

test_that("ragg rejects conflicting dimensions in shared facet columns", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point() + ggplot2::facet_grid(vs ~ am)
  expect_error(fmt_raster(p, method = "ragg", dpi = 72,
                          width = c(1, 2, 3, 4), height = 1), "width.*sharing")
  expect_error(fmt_raster(p, method = "ragg", dpi = 72,
                          width = 1, height = c(1, 2, 3, 4)), "height.*sharing")
  expect_error(fmt_raster(p, method = "ragg", dpi = 72,
                          width = c(1, 2)), "width.*must be 1 or 4")
  result <- fmt_raster(p, method = "ragg", dpi = 72,
                       width = c(1, 1, 2, 2), height = 1)
  gt <- attr(result, "grobs")$full
  indices <- grep("^panel-", gt$layout$name)
  expected <- c(1, 1, 2, 2)
  for (i in seq_along(indices)) {
    panel <- gt$grobs[[indices[i]]]
    raster <- raster_find_grobs(panel, "rastergrob")[[1]]$raster
    expect_equal(ncol(raster) / 72, expected[i])
    columns <- gt$layout$l[indices[i]]:gt$layout$r[indices[i]]
    expect_equal(grid::convertWidth(sum(gt$widths[columns]), "in", TRUE), expected[i])
  }
})

test_that("automatic nested ragg outputs retain a complete physical size", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL, width = 8, height = 6)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  nested <- (p | p) / (p | p)
  result <- fmt_raster(nested, method = "ragg", dpi = 72)
  expect_equal(attr(result, "size")$width, 8)
  expect_equal(attr(result, "size")$height, 6)
  expect_error(fmt_raster((p | p) / p, method = "ragg", dpi = 72,
                          width = 1, height = 1), "incompatible.*nested")
})

test_that("automatic ragg panel sizes use the device and respect units", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL, width = 10, height = 6)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::theme_void()
  factors <- c("in" = 1, "cm" = 2.54, "mm" = 25.4)
  for (unit in names(factors)) {
    result <- fmt_raster(p, method = "ragg", dpi = 72, units = unit)
    expect_equal(attr(result, "size")$width / factors[[unit]], 10)
    expect_equal(attr(result, "size")$height / factors[[unit]], 6)
  }
  data <- data.frame(x = c(1, 2, 1, 10), y = 1, group = c("a", "a", "b", "b"))
  facets <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::facet_grid(~group, scales = "free_x", space = "free_x")
  gt <- ggplot2::ggplotGrob(facets)
  indices <- grep("^panel", gt$layout$name)
  widths <- UtilsR:::.resolve_panel_size(gt, indices, "width", NULL, "in")
  expect_equal(widths[2] / widths[1], 9)
  fixed <- fmt_raster(p + ggplot2::coord_fixed(ratio = 2), method = "ragg", dpi = 72)
  expect_equal(attr(fixed, "size")$height / attr(fixed, "size")$width, 2)
})

test_that("ragg preserves named plot lists and checks all elements first", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  result <- fmt_raster(list(first = p, second = p | p), method = "ragg",
                       dpi = 72, width = 1, height = 1)
  expect_named(result, c("first", "second"))
  expect_true(all(vapply(result, inherits, logical(1), "patchwork")))
  expect_length(raster_find_grobs(patchwork::patchworkGrob(result[[2]]), "rastergrob"), 2L)
  expect_equal(fmt_raster(list(), method = "ragg"), list())
  devices <- grDevices::dev.list()
  expect_error(fmt_raster(list(p, NULL), method = "ragg"), "All elements")
  expect_identical(grDevices::dev.list(), devices)
})

test_that("ggrastr rasterizes point and tile layers only", {
  skip_if_not_installed("ggrastr")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  data <- data.frame(x = c(0, 1, 1, 0), y = c(0, 0, 1, 1))
  # Lines, bars and polygons are few objects: as images they only grow a PDF.
  geoms <- list(point = ggplot2::geom_point(), jitter = ggplot2::geom_jitter(),
                tile = ggplot2::geom_tile(), col = ggplot2::geom_col(),
                polygon = ggplot2::geom_polygon(), line = ggplot2::geom_line())
  expected <- c(point = 1L, jitter = 1L, tile = 1L, col = 0L, polygon = 0L,
                line = 0L)
  for (name in names(geoms)) {
    p <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + geoms[[name]] +
      ggplot2::geom_text(label = "text") + ggplot2::geom_label(label = "label")
    result <- fmt_raster(p, dpi = 72)
    expect_length(raster_find_grobs(ggplot2::ggplotGrob(result), "rasteriser"),
                  expected[[name]])
  }
  # Nothing to rasterize: no warning about clipping.
  unclipped <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_line() +
    ggplot2::coord_cartesian(clip = "off")
  expect_no_warning(fmt_raster(unclipped, dpi = 72))
})

test_that("ggrastr visits all leaves without changing nested layouts", {
  skip_if_not_installed("ggrastr")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  original <- ((p | p) / p) | p
  result <- fmt_raster(original, dpi = 72)
  expect_length(raster_find_grobs(patchwork::patchworkGrob(result), "rasteriser"), 4L)
  expect_equal(result$patches$layout, original$patches$layout)
  expect_equal(result[[1]]$patches$layout, original[[1]]$patches$layout)
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

test_that("raster dimensions reject class-encoded storage before selecting a device", {
  encoded <- structure(300, class = "integer64")
  expect_error(fmt_raster(stop("plot evaluated"), dpi = encoded), "dpi")
  for (method in c("ragg", "image")) {
    for (arg in c("width", "height")) {
      args <- list(plot = quote(stop("plot evaluated")), method = method)
      args[arg] <- list(encoded)
      expect_error(do.call(fmt_raster, args), arg)
    }
  }
})

test_that("raster background colours are diagnosed before device and plot work", {
  for (method in c("ragg", "image")) {
    for (bad in list("invalid-background", c("red", "blue"), matrix("white"))) {
      expect_error(fmt_raster(stop("plot evaluated"), method = method, bg = bad), "bg")
    }
  }
})

test_that("invalid resolutions and panel dimensions fail before the backend", {
  local_mocked_bindings(
    .fmt_raster_ragg = function(...) stop("backend was called"),
    .fmt_raster_ggrastr = function(...) stop("backend was called"),
    .package = "UtilsR"
  )
  for (method in c("ragg", "ggrastr")) {
    for (value in list(0, -1, NA_real_, Inf, numeric(), c(72, 100), "300",
                       matrix(72), grid::unit(72, "pt"))) {
      expect_error(fmt_raster(NULL, method = method, dpi = value), "dpi.*positive")
    }
  }
  for (argument in c("width", "height")) {
    for (value in list(0, -1, NA_real_, Inf, numeric(), "2", matrix(2))) {
      args <- c(list(plot = NULL, method = "ragg"), setNames(list(value), argument))
      expect_error(do.call(fmt_raster, args), paste0(argument, ".*positive"))
    }
    for (method in c("ragg", "image")) {
      args <- c(list(plot = NULL, method = method),
                setNames(list(grid::unit(2, "cm")), argument))
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
  red_pixels <- function(file) {
    image <- png::readPNG(file)
    sum(image[, , 1] > 0.7 & image[, , 2] < 0.4 & image[, , 3] < 0.4)
  }
  expect_gt(red_pixels(files[1]), 18000)
  expect_gt(red_pixels(files[2]), red_pixels(files[1]) * 0.9)
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

test_that("ragg and image leave the random stream where it was", {
  skip_if_not_installed("ragg")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  # ragg before 1.5.1 named each capture device with sample() (r-lib/ragg#211).
  capture <- ragg::agg_capture
  local_mocked_bindings(agg_capture = function(...) {
    sample.int(10L, 1L)
    capture(...)
  }, .package = "ragg")
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  set.seed(1)
  expected <- stats::runif(1)
  for (method in c("ragg", "image")) {
    set.seed(1)
    fmt_raster(p, method = method, dpi = 10, width = 1, height = 1)
    expect_identical(stats::runif(1), expected)
  }
})

test_that("pdf() draws rasters opaque after translucent vector grobs", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  data <- data.frame(x = c(1, 3), y = 1)
  p <- ggplot2::ggplot(mapping = ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = data[1, ], colour = "blue", size = 20) +
    ggplot2::annotate("text", x = 2, y = 1, label = "TEXT", alpha = 0.3, size = 10) +
    ggplot2::geom_point(data = data[2, ], colour = "blue", size = 20) +
    ggplot2::scale_x_continuous(limits = c(0, 4), expand = c(0, 0)) +
    ggplot2::theme_void()
  result <- fmt_raster(p, method = "ragg", dpi = 72, width = 4, height = 2)
  # Each raster comes after an opaque grob that resets pdf()'s fill alpha.
  holders <- Filter(function(g) {
    any(vapply(g$children, inherits, logical(1), "rastergrob"))
  }, raster_find_grobs(attr(result, "grobs")$full, "gTree"))
  expect_length(holders, 2L)
  for (g in holders) {
    expect_false(inherits(g$children[[1]], "rastergrob"))
    expect_equal(grDevices::col2rgb(g$children[[1]]$gp$fill, alpha = TRUE)[4], 255)
  }

  skip_if(!nzchar(Sys.which("pdftoppm")), "pdftoppm is not available")
  file <- tempfile(fileext = ".pdf")
  stub <- tempfile()
  on.exit(unlink(c(file, paste0(stub, ".png"))), add = TRUE)
  size <- attr(result, "size")
  grDevices::pdf(file, width = size$width, height = size$height)
  print(result)
  grDevices::dev.off()
  system2("pdftoppm", c("-r", "72", "-png", "-singlefile", file, stub))
  image <- png::readPNG(paste0(stub, ".png"))
  # The point drawn after the translucent text is as pure a blue as the first.
  blue <- image[, , 1] < 0.1 & image[, , 2] < 0.1 & image[, , 3] > 0.9
  left <- seq_len(ncol(blue) %/% 2)
  expect_gt(sum(blue[, left]), 100)
  expect_gt(sum(blue[, -left]), 0.9 * sum(blue[, left]))
})

test_that("pdf() draws ggrastr rasters opaque after translucent vector grobs", {
  skip_if_not_installed("ggrastr")
  skip_if_not_installed("ragg")
  skip_if_not_installed("png")
  skip_if(!nzchar(Sys.which("pdftoppm")), "pdftoppm is not available")
  data <- data.frame(x = c(1, 3), y = 1)
  p <- ggplot2::ggplot(mapping = ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = data[1, ], colour = "blue", size = 20) +
    ggplot2::annotate("text", x = 2, y = 1, label = "TEXT", alpha = 0.3, size = 10) +
    ggplot2::geom_point(data = data[2, ], colour = "blue", size = 20) +
    ggplot2::scale_x_continuous(limits = c(0, 4), expand = c(0, 0)) +
    ggplot2::theme_void()
  result <- fmt_raster(p, dpi = 72)
  file <- tempfile(fileext = ".pdf")
  stub <- tempfile()
  on.exit(unlink(c(file, paste0(stub, ".png"))), add = TRUE)
  grDevices::pdf(file, width = 4, height = 2)
  print(result)
  grDevices::dev.off()
  system2("pdftoppm", c("-r", "72", "-png", "-singlefile", file, stub))
  image <- png::readPNG(paste0(stub, ".png"))
  # The point drawn after the translucent text is as pure a blue as the first.
  blue <- image[, , 1] < 0.1 & image[, , 2] < 0.1 & image[, , 3] > 0.9
  left <- seq_len(ncol(blue) %/% 2)
  expect_gt(sum(blue[, left]), 100)
  expect_gt(sum(blue[, -left]), 0.9 * sum(blue[, left]))

  # A repeated call rasterizes each layer once, at the latest dpi.
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  rasters <- raster_find_grobs(ggplot2::ggplotGrob(fmt_raster(result, dpi = 150)), "rasteriser")
  expect_length(rasters, 2L)
  expect_identical(unname(vapply(rasters, function(g) g$dpi, numeric(1))), c(150, 150))
})

test_that("ragg keeps the panel grid and border vector and drops empty grobs", {
  skip_if_not_installed("ragg")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point() +
    ggplot2::annotate("text", x = 3, y = 30, label = "a") + ggplot2::geom_blank() +
    ggplot2::annotate("text", x = 4, y = 30, label = "b") + ggplot2::theme_bw()
  result <- fmt_raster(p, method = "ragg", dpi = 72, width = 2, height = 2)
  gt <- attr(result, "grobs")$full
  panel <- gt$grobs[[which(gt$layout$name == "panel")]]
  expect_length(raster_find_grobs(panel, "rastergrob"), 1L)
  expect_true(any(startsWith(names(panel$children), "grill")))
  expect_true(any(startsWith(names(panel$children), "panel.border")))
  expect_gt(length(raster_find_grobs(panel, "polyline")), 0L)
  expect_false(any(vapply(panel$children, inherits, logical(1), "null")))
})

test_that("image fills its own size without patchwork margins", {
  skip_if_not_installed("ragg")
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = "red", colour = NA))
  result <- fmt_raster(p, method = "image", dpi = 50, width = 2, height = 1)
  capture <- ragg::agg_capture(width = 2, height = 1, units = "in", res = 50,
                               background = "white")
  device <- grDevices::dev.cur()
  on.exit(grDevices::dev.off(device), add = TRUE)
  print(result)
  pixels <- capture()
  expect_identical(pixels[c(1, 50), c(1, 100)], matrix("red", 2, 2))
})

test_that("the ggrastr backend keeps fmt_com() brackets drawable", {
  skip_if_not_installed("ggrastr")
  skip_if_not_installed("ggpubr")
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  d <- data.frame(g = rep(c("A", "B", "C"), each = 20),
                  y = rep(1:3, each = 20) + rep(seq(-1, 1, length.out = 20), 3))
  p <- fmt_com(ggplot2::ggplot(d, ggplot2::aes(g, y)) + ggplot2::geom_boxplot() +
                 ggplot2::geom_point())
  # ggrastr::rasterise() cannot draw ggpubr's bracket layer, so it stays vector.
  expect_no_error(g <- ggplot2::ggplotGrob(fmt_raster(p, dpi = 72)))
  expect_length(raster_find_grobs(g, "rasteriser"), 1L)
})

test_that("ragg panel runs avoid copying geometry prefixes", {
  skip_if_not_installed("ragg")
  withr::local_pdf(NULL)
  geometry <- lapply(seq_len(70L), function(i) {
    grid::pointsGrob(x = i / 80, y = .5, name = paste0("points", i))
  })
  children <- do.call(grid::gList, c(geometry[1:35], list(grid::textGrob("middle", name = "middle")),
    geometry[36:70]))
  panel <- grid::gTree(children = children)
  fn <- .rasterize_panel_grob
  env <- new.env(parent = environment(fn))
  copied <- 0L
  env$c <- function(...) {
    args <- list(...)
    if (length(args) == 2L && is.integer(args[[1L]]) && is.integer(args[[2L]]) &&
        length(args[[2L]]) == 1L) copied <<- copied + length(args[[1L]])
    base::c(...)
  }
  environment(fn) <- env
  result <- fn(panel, w = 1, h = 1, dpi = 36, units = "in", bg = "transparent")
  expect_identical(copied, 0L)
  expect_length(result$children, 3L)
  expect_length(raster_find_grobs(result$children[[1L]], "rastergrob"), 1L)
  expect_identical(result$children[[2L]]$label, "middle")
  expect_length(raster_find_grobs(result$children[[3L]], "rastergrob"), 1L)
})

test_that("ragg discovers each nested gtable panel once", {
  skip_if_not_installed("ragg")
  withr::local_pdf(NULL, width = 2, height = 2)
  p <- ggplot2::ggplot(data.frame(x = 1:2, y = 2:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::theme_void()
  deep <- ggplot2::ggplotGrob(p)
  depth <- 8L
  for (i in seq_len(depth)) {
    table <- gtable::gtable(widths = grid::unit(1, "null"), heights = grid::unit(1, "null"))
    deep <- gtable::gtable_add_grob(table, deep, t = 1L, l = 1L, name = paste0("nested", i))
  }
  fn <- .fmt_raster_ragg
  env <- new.env(parent = environment(fn))
  scans <- 0L
  env$grepl <- function(pattern, x, ...) {
    if (identical(pattern, "^panel(-[0-9]+)*$") && length(x) && !all(grepl("^guide", x))) {
      if (any(startsWith(x, "nested")) || "panel" %in% x) scans <<- scans + 1L
    }
    base::grepl(pattern, x, ...)
  }
  environment(fn) <- env
  result <- fn(deep, dpi = 36, width = NULL, height = NULL, units = "in", bg = "transparent")
  expect_identical(scans, depth + 1L)
  expect_length(raster_find_grobs(attr(result, "grobs")$full, "rastergrob"), 1L)
})

test_that("ragg respects inherited panel viewport clipping", {
  skip_if_not_installed("ragg")
  withr::local_pdf(NULL, width = 2, height = 2)
  table <- gtable::gtable(widths = grid::unit(1, "in"), heights = grid::unit(1, "in"))
  for (spec in list(c("on", "on"), c("inherit", "on"), c("off", "on"), c("inherit", "off"))) {
    panel <- grid::grobTree(grid::pointsGrob(0.5, 0.5), vp = grid::viewport(clip = spec[1L]))
    input <- gtable::gtable_add_grob(table, panel, t = 1, l = 1, clip = spec[2L], name = "panel")
    clipped <- spec[1L] != "off" && spec[2L] == "on"
    if (clipped) {
      expect_no_warning(plot <- fmt_raster(input, method = "ragg", dpi = 20))
    } else {
      expect_warning(plot <- fmt_raster(input, method = "ragg", dpi = 20), "clipping disabled")
    }
    rasters <- raster_find_grobs(patchwork::patchworkGrob(plot), "rastergrob")
    expect_length(rasters, as.integer(clipped))
  }
})

test_that("ragg skips measuring tables without panels", {
  skip_if_not_installed("ragg")
  table <- gtable::gtable(widths = grid::unit(rep(1, 500), "pt"), heights = grid::unit(1, "in"))
  testthat::local_mocked_bindings(
    grid.layout = function(...) stop("layout measured for panel-free table"),
    .package = "grid"
  )
  expect_warning(result <- fmt_raster(table, method = "ragg", dpi = 20), "No panels detected")
  expect_identical(result, table)
  expect_error(fmt_raster(table, method = "ragg", dpi = 20, width = c(1, 2)), "number of panels")
})

test_that("ragg accepts bare panel grobs in custom tables", {
  skip_if_not_installed("ragg")
  withr::local_pdf(NULL, width = 2, height = 2)
  panel <- function(grob) {
    table <- gtable::gtable(widths = grid::unit(1, "in"), heights = grid::unit(1, "in"))
    gtable::gtable_add_grob(table, grob, t = 1L, l = 1L, clip = "on", name = "panel")
  }
  point <- fmt_raster(panel(grid::pointsGrob(.5, .5)), method = "ragg", dpi = 20)
  expect_length(raster_find_grobs(patchwork::patchworkGrob(point), "rastergrob"), 1L)
  text <- fmt_raster(panel(grid::textGrob("Keep this text")), method = "ragg", dpi = 20)
  expect_length(raster_find_grobs(patchwork::patchworkGrob(text), "text"), 1L)
  empty <- panel(grid::nullGrob())
  expect_warning(result <- fmt_raster(empty, method = "ragg", dpi = 20), "No panels detected")
  expect_identical(result, empty)
})
