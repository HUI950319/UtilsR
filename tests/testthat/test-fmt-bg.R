bg_plot <- function() {
  ggplot2::ggplot(data.frame(category = factor(c("A", "B", "C")),
                              value = c(2, 5, 3)),
                   ggplot2::aes(category, value)) + ggplot2::geom_point()
}

bg_colors <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")

bg_rects <- function(g) {
  result <- if (inherits(g, "rect") && grepl("geom_rect|fmt-bg-stripes", g$name)) {
    data.frame(fill = unname(grDevices::rgb(t(grDevices::col2rgb(g$gp$fill)), maxColorValue = 255)),
               x = as.numeric(g$x), y = as.numeric(g$y),
               width = as.numeric(g$width), height = as.numeric(g$height))
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  do.call(rbind, c(list(result), lapply(children, bg_rects)))
}

bg_fills <- function(plot) {
  bg_rects(ggplot2::ggplotGrob(plot))$fill
}

bg_grobs <- function(g) {
  if (identical(g$name, "fmt-bg-stripes")) return(list(g))
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  unlist(lapply(children, bg_grobs), recursive = FALSE)
}

test_that("manual background colors override palettes without an optional dependency", {
  p <- bg_plot()
  expect_equal(bg_fills(fmt_bg(p, palcolor = bg_colors)), unname(bg_colors))
  expect_equal(bg_fills(fmt_bg(p, palcolor = unname(bg_colors))), unname(bg_colors))
  expect_equal(bg_fills(fmt_bg(p, palette = "invalid", palcolor = bg_colors)),
                 unname(bg_colors))
  expect_equal(bg_fills(fmt_bg(p, palcolor = "purple")), rep("#A020F0", 3))
  expect_length(p$layers, 1L)
})

test_that("background stripes follow trained order and panel-specific categories", {
  p <- bg_plot()
  q <- fmt_bg(p + ggplot2::scale_x_discrete(limits = c("C", "B", "A")), palcolor = bg_colors)
  expect_equal(bg_fills(q), unname(bg_colors[c("C", "B", "A")]))
  subset <- p
  subset$data <- subset$data[c(1, 3), ]
  expect_equal(bg_fills(fmt_bg(subset + ggplot2::scale_x_discrete(drop = FALSE),
                                palcolor = bg_colors)), unname(bg_colors))
  subset$data$category[2] <- NA
  expect_equal(bg_fills(fmt_bg(subset, palcolor = bg_colors)), c(bg_colors[["A"]], "#CCCCCC"))
  d <- data.frame(category = factor(c("A", "B", "B", "C"), levels = c("A", "B", "C")),
                   value = 1:4, group = c("P1", "P1", "P2", "P2"))
  for (axis in c("x", "y")) {
    p <- if (axis == "x") ggplot2::ggplot(d, ggplot2::aes(category, value)) else
      ggplot2::ggplot(d, ggplot2::aes(value, category))
    p <- p + ggplot2::geom_point() + ggplot2::facet_wrap(~group, scales = paste0("free_", axis))
    q <- fmt_bg(p, palcolor = bg_colors, bg_axis = axis)
    expect_equal(bg_fills(q), unname(bg_colors[c("A", "B", "B", "C")]))
    old <- ggplot2::ggplot_build(p)
    new <- ggplot2::ggplot_build(q)
    expect_identical(new$data[-1], old$data)
    expect_equal(lapply(new$layout$panel_params, function(z) z[[paste0(axis, ".range")]]),
                   lapply(old$layout$panel_params, function(z) z[[paste0(axis, ".range")]]))
  }
  p <- bg_plot() + ggplot2::coord_flip()
  rects <- bg_rects(ggplot2::ggplotGrob(fmt_bg(p, palcolor = bg_colors)))
  expect_equal(rects$fill, unname(bg_colors))
  expect_equal(rects$width, rep(1, 3))
  expect_equal(length(unique(rects$y)), 3L)
})

test_that("background palette errors remain visible and defaults are retained", {
  p <- bg_plot()
  default <- unname(grDevices::rainbow(3))
  expect_equal(bg_fills(fmt_bg(p)), default)
  expect_equal(bg_fills(fmt_bg(p, palcolor = c(A = "black"))),
                 c("#000000", default[-1]))
  if (requireNamespace("plotthis", quietly = TRUE)) {
    expect_error(fmt_bg(p, palette = "invalid"), "palette|Palette")
    expected <- plotthis::palette_this(c("A", "B", "C"), palette = "Paired")
    expect_equal(bg_fills(fmt_bg(p, palette = "Paired")), unname(expected))
  }
  for (colors in list(character(), 1, NA_character_, "invalid-color",
                      c(A = "red", A = "blue"), stats::setNames("red", ""))) {
    expect_error(fmt_bg(p, palcolor = colors), "palcolor")
  }
})

test_that("backgrounds support categorical expressions and layer data", {
  p <- bg_plot()
  character_plot <- p
  character_plot$data$category <- as.character(character_plot$data$category)
  expect_equal(bg_fills(fmt_bg(character_plot, palcolor = bg_colors)), unname(bg_colors))
  logical_plot <- ggplot2::ggplot(data.frame(category = c(TRUE, FALSE), value = 1:2),
                                  ggplot2::aes(category, value)) + ggplot2::geom_point()
  expect_equal(length(bg_fills(fmt_bg(logical_plot))), 2L)
  expression_plot <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot()
  expect_length(bg_fills(fmt_bg(expression_plot)), 3L)
  pronoun_plot <- ggplot2::ggplot(p$data, ggplot2::aes(.data[["category"]], value)) +
    ggplot2::geom_point()
  expect_equal(bg_fills(fmt_bg(pronoun_plot, palcolor = bg_colors)), unname(bg_colors))
  for (layer_plot in list(
    ggplot2::ggplot(p$data) + ggplot2::geom_point(ggplot2::aes(category, value)),
    ggplot2::ggplot(mapping = ggplot2::aes(category, value)) + ggplot2::geom_point(data = p$data),
    ggplot2::ggplot() + ggplot2::geom_point(data = p$data, ggplot2::aes(category, value)))) {
    before <- ggplot2::ggplot_build(layer_plot)$data
    q <- fmt_bg(layer_plot, palcolor = bg_colors)
    expect_equal(bg_fills(q), unname(bg_colors))
    expect_identical(ggplot2::ggplot_build(q)$data[-1], before)
    expect_length(layer_plot$layers, 1L)
  }
  continuous <- ggplot2::ggplot(mtcars, ggplot2::aes(cyl, mpg)) + ggplot2::geom_point()
  expect_warning(q <- fmt_bg(continuous), "categorical")
  expect_identical(q, continuous)
})

test_that("backgrounds render expression facets and marginal panels without changing fill scales", {
  p <- bg_plot()
  p$data$group <- c("P1", "P1", "P2")
  for (facet in list(ggplot2::facet_wrap(ggplot2::vars(paste0("group_", group))),
                     ggplot2::facet_grid(. ~ group, margins = TRUE),
                     ggplot2::facet_grid(ggplot2::vars(row = substr(group, 2, 2)),
                                           ggplot2::vars(group)))) {
    z <- p + facet + ggplot2::aes(fill = category) +
      ggplot2::scale_fill_manual(values = bg_colors)
    before <- ggplot2::ggplot_build(z)
    q <- fmt_bg(z, palcolor = bg_colors)
    expect_equal(length(bg_fills(q)), 3L * nrow(before$layout$layout))
    after <- ggplot2::ggplot_build(q)
    expect_identical(after$data[-1], before$data)
    expect_identical(after$layout$layout, before$layout$layout)
    expect_identical(q$scales$scales[[1]], z$scales$scales[[1]])
    expect_identical(after$plot$scales$get_scales("fill")$get_limits(),
                       before$plot$scales$get_scales("fill")$get_limits())
  }
})

test_that("backgrounds span log-scaled panels without transforming infinite bounds", {
  for (axis in c("x", "y")) {
    p <- if (axis == "x") bg_plot() + ggplot2::scale_y_log10() else
      ggplot2::ggplot(bg_plot()$data, ggplot2::aes(value, category)) +
        ggplot2::geom_point() + ggplot2::scale_x_log10()
    q <- fmt_bg(p, palcolor = bg_colors, bg_axis = axis)
    expect_silent(g <- ggplot2::ggplotGrob(q))
    rects <- bg_rects(g)
    expect_equal(rects$fill, unname(bg_colors))
    expect_equal(rects[[if (axis == "x") "height" else "width"]], rep(1, 3))
    expect_identical(ggplot2::ggplot_build(q)$data[-1], ggplot2::ggplot_build(p)$data)
  }
})

test_that("backgrounds visit nested data plots while preserving container metadata", {
  p <- bg_plot()
  pw <- (p | p) / (p | p) + patchwork::plot_annotation(title = "Keep", tag_levels = "A")
  q <- fmt_bg(pw, palcolor = bg_colors)
  expect_equal(nrow(bg_rects(patchwork::patchworkGrob(q))), 12L)
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  expect_equal(vapply(.to_plot_list(pw, recurse = TRUE)$plots, function(z) length(z$layers), integer(1)),
                 rep(1L, 4))
  plots <- list(top = p | p, bottom = p | p)
  q <- fmt_bg(plots, palcolor = bg_colors)
  expect_identical(names(q), names(plots))
  expect_equal(vapply(.to_plot_list(q, recurse = TRUE)$plots, function(z) length(z$layers), integer(1)),
                 rep(2L, 4))
  fixed <- patchwork::wrap_elements(full = p)
  pw <- patchwork::free((p | p) / (patchwork::plot_spacer() | fixed))
  expect_silent(q <- fmt_bg(pw, palcolor = bg_colors))
  expect_equal(nrow(bg_rects(patchwork::patchworkGrob(q))), 6L)
  expect_identical(attr(q, "patchwork_free_settings"), attr(pw, "patchwork_free_settings"))
  expect_identical(fmt_bg(fixed, palcolor = bg_colors), fixed)
  inset <- p + patchwork::inset_element(p, 0.1, 0.1, 0.5, 0.5)
  q <- fmt_bg(inset, palcolor = bg_colors)
  expect_equal(nrow(bg_rects(patchwork::patchworkGrob(q))), 3L)
  expect_identical(q[[length(q)]], inset[[length(inset)]])
})

test_that("repeated background formatting replaces only its own layer", {
  p <- bg_plot() + ggplot2::geom_rect(
    data = data.frame(xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 2),
    ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = "black", inherit.aes = FALSE)
  once <- fmt_bg(p, palcolor = bg_colors)
  twice <- fmt_bg(once, palcolor = bg_colors)
  expect_length(twice$layers, length(once$layers))
  expect_identical(twice$layers[-1], p$layers)
  expect_length(once$layers, 3L)
  changed <- fmt_bg(once, palcolor = c(A = "purple", B = "purple", C = "purple"), alpha = 0.6)
  expect_length(changed$layers, 3L)
  expect_equal(bg_fills(changed)[1:3], rep("#A020F0", 3))
  expect_equal(changed$layers[[1]]$aes_params$alpha, 0.6)
  expect_equal(once$layers[[1]]$aes_params$alpha, 0.3)
  nested <- (bg_plot() | bg_plot()) / (bg_plot() | bg_plot())
  twice <- fmt_bg(fmt_bg(nested, palcolor = bg_colors), palcolor = bg_colors)
  expect_equal(vapply(.to_plot_list(twice, recurse = TRUE)$plots, function(z) length(z$layers), integer(1)),
                 rep(2L, 4))
})

test_that("repeated background formatting retains rendered opacity", {
  skip_if_not_installed("ragg")
  capture <- function(p) {
    grab <- ragg::agg_capture(width = 360, height = 240, units = "px", res = 72)
    on.exit(grDevices::dev.off())
    print(p)
    grab(native = TRUE)
  }
  once <- fmt_bg(bg_plot(), palcolor = bg_colors)
  twice <- fmt_bg(once, palcolor = bg_colors)
  expect_equal(sum(capture(twice) != capture(once)), 0L)
})

test_that("background opacity is validated and zero opacity skips evaluation", {
  p <- bg_plot()
  for (alpha in list(NULL, numeric(), c(0.2, 0.3), NA_real_, NaN, Inf,
                     -0.1, 1.1, TRUE, "0.3", 0.3 + 0i)) {
    expect_error(fmt_bg(p, alpha = alpha), "alpha")
  }
  expect_equal(fmt_bg(p, alpha = 1L)$layers[[1]]$aes_params$alpha, 1L)
  lazy <- ggplot2::ggplot(p$data, ggplot2::aes(stop("mapping evaluated"), value)) +
    ggplot2::geom_point()
  expect_identical(fmt_bg(lazy, alpha = 0), lazy)
  nested <- (p | p) / (p | p) + patchwork::plot_annotation(title = "Keep")
  expect_identical(fmt_bg(nested, alpha = 0), nested)
  expect_identical(fmt_bg(list(first = p, second = p), alpha = 0),
                     list(first = p, second = p))
  once <- fmt_bg(p, palcolor = bg_colors)
  expect_identical(fmt_bg(once, alpha = 0), once)
  expect_error(fmt_bg("invalid", alpha = 0), "Input")
  expect_error(fmt_bg(p, alpha = 0, palcolor = "invalid-color"), "palcolor")
})

test_that("backgrounds skip empty and all-missing categories", {
  for (categories in list(factor(character(), levels = c("A", "B")), character(),
                           factor(c(NA, NA), levels = c("A", "B")),
                           c(NA_character_, NA_character_), c(NA, NA))) {
    p <- ggplot2::ggplot(data.frame(category = categories, value = seq_along(categories)),
                           ggplot2::aes(category, value)) + ggplot2::geom_point()
    expect_identical(fmt_bg(p), p)
  }
  expect_identical(fmt_bg(list()), list())
})

test_that("backgrounds render polar sectors and radial bands", {
  for (axis in c("x", "y")) {
    p <- if (axis == "x") bg_plot() else
      ggplot2::ggplot(bg_plot()$data, ggplot2::aes(value, category)) + ggplot2::geom_point()
    for (theta in c("x", "y")) {
      for (coord in list(ggplot2::coord_polar(theta = theta),
                         ggplot2::coord_radial(theta = theta, inner.radius = 0.15))) {
        z <- p + coord
        q <- fmt_bg(z, palcolor = bg_colors, bg_axis = axis)
        expect_silent(g <- ggplot2::ggplotGrob(q))
        grob <- bg_grobs(g)[[1]]
        expect_equal(unname(grDevices::rgb(t(grDevices::col2rgb(grob$gp$fill)), maxColorValue = 255)),
                       unname(bg_colors))
        expect_identical(ggplot2::ggplot_build(q)$data[-1], ggplot2::ggplot_build(z)$data)
      }
    }
  }
})

test_that("backgrounds use function and formula layer data", {
  d <- bg_plot()$data
  mapped_colors <- stats::setNames(bg_colors, paste0("G", names(bg_colors)))
  for (axis in c("x", "y")) {
    mapping <- if (axis == "x") ggplot2::aes(category2, value) else
      ggplot2::aes(value, category2)
    for (data in list(
      function(x) transform(x, category2 = factor(paste0("G", category))),
      ~transform(.x, category2 = factor(paste0("G", category))))) {
      p <- ggplot2::ggplot(d) + ggplot2::geom_point(data = data, mapping = mapping)
      q <- fmt_bg(p, palcolor = mapped_colors, bg_axis = axis)
      expect_equal(bg_fills(q), unname(mapped_colors))
      expect_identical(ggplot2::ggplot_build(q)$data[-1], ggplot2::ggplot_build(p)$data)
    }
    p <- ggplot2::ggplot() + ggplot2::geom_point(
      data = function(x) transform(d, category2 = factor(paste0("G", category))), mapping = mapping)
    expect_equal(bg_fills(fmt_bg(p, palcolor = mapped_colors, bg_axis = axis)),
                   unname(mapped_colors))
  }
})

test_that("numeric annotations do not hide categorical background mappings", {
  for (axis in c("x", "y")) {
    p <- if (axis == "x") bg_plot() else
      ggplot2::ggplot(bg_plot()$data, ggplot2::aes(value, category)) + ggplot2::geom_point()
    p$layers <- c(list(ggplot2::annotate("text", x = 1, y = 1, label = "note")), p$layers)
    p <- p + if (axis == "x") ggplot2::scale_x_discrete() else ggplot2::scale_y_discrete()
    expect_silent(q <- fmt_bg(p, palcolor = bg_colors, bg_axis = axis))
    expect_equal(bg_fills(q), unname(bg_colors))
    expect_identical(ggplot2::ggplot_build(q)$data[-1], ggplot2::ggplot_build(p)$data)
  }
})

test_that("backgrounds use categorical values produced by statistics", {
  d <- data.frame(category = rep(c("A", "B", "C"), 1:3))
  p <- ggplot2::ggplot(d, ggplot2::aes(category, ggplot2::after_stat(factor(count)))) +
    ggplot2::geom_point(stat = "count")
  colors <- stats::setNames(bg_colors, 1:3)
  expect_silent(q <- fmt_bg(p, palcolor = colors, bg_axis = "y"))
  expect_equal(bg_fills(q), unname(colors))
  expect_identical(ggplot2::ggplot_build(q)$data[-1], ggplot2::ggplot_build(p)$data)
})

test_that("background formatting does not execute random mapping expressions", {
  d <- data.frame(category = factor(rep(c("A", "B", "C"), 20)), value = seq_len(60))
  for (axis in c("x", "y")) {
    mapping <- if (axis == "x") ggplot2::aes(sample(category), value) else
      ggplot2::aes(value, sample(category))
    p <- ggplot2::ggplot(d, mapping) + ggplot2::geom_point()
    set.seed(123)
    seed <- .Random.seed
    q <- fmt_bg(p, palcolor = bg_colors, bg_axis = axis)
    expect_identical(.Random.seed, seed)
    after <- ggplot2::ggplot_build(q)
    set.seed(123)
    before <- ggplot2::ggplot_build(p)
    expect_identical(after$data[-1], before$data)
  }
})

test_that("background formatting leaves mapping and data callbacks to ggplot", {
  d <- bg_plot()$data
  calls <- 0L
  categories <- function(x) {
    calls <<- calls + 1L
    x
  }
  p <- ggplot2::ggplot(d, ggplot2::aes(categories(category), value)) + ggplot2::geom_point()
  q <- fmt_bg(p, palcolor = bg_colors)
  expect_equal(calls, 0L)
  expect_equal(bg_fills(q), unname(bg_colors))
  expect_equal(calls, 1L)
  calls <- 0L
  p <- ggplot2::ggplot(d, ggplot2::aes(category, value)) + ggplot2::geom_point(
    data = function(x) {
      calls <<- calls + 1L
      x
    })
  q <- fmt_bg(p, palcolor = bg_colors)
  expect_equal(calls, 0L)
  expect_equal(bg_fills(q), unname(bg_colors))
  expect_equal(calls, 1L)
})

test_that("deferred mappings retain continuous-axis warnings and palette errors", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(as.numeric(cyl), mpg)) + ggplot2::geom_point()
  expect_silent(q <- fmt_bg(p))
  expect_warning(fills <- bg_fills(q), "categorical")
  expect_null(fills)
  expect_identical(ggplot2::ggplot_build(q)$data[-1], ggplot2::ggplot_build(p)$data)
  if (requireNamespace("plotthis", quietly = TRUE)) {
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) + ggplot2::geom_point()
    expect_error(bg_fills(fmt_bg(p, palette = "invalid")), "palette|Palette")
  }
})

test_that("background category colors are shared across layers and free facets", {
  d <- data.frame(category = factor(rep(c("A", "C"), 2), levels = c("A", "B", "C")),
                   value = 1:4, group = rep(c("P1", "P2"), each = 2))
  extra <- data.frame(category = factor("B", levels = levels(d$category)),
                       value = 5, group = "P2")
  colors <- stats::setNames(unname(bg_colors), c("A", "C", "B"))
  for (axis in c("x", "y")) {
    for (deferred in c(FALSE, TRUE)) {
      mapping <- if (axis == "x") {
        if (deferred) ggplot2::aes(factor(category), value) else ggplot2::aes(category, value)
      } else {
        if (deferred) ggplot2::aes(value, factor(category)) else ggplot2::aes(value, category)
      }
      p <- ggplot2::ggplot(d, mapping) + ggplot2::geom_point() +
        ggplot2::geom_point(data = extra) +
        ggplot2::facet_wrap(~group, scales = paste0("free_", axis))
      before <- ggplot2::ggplot_build(p)
      categories <- unlist(lapply(seq_len(nrow(before$layout$layout)), function(i) {
        before$layout$get_scales(i)[[axis]]$get_limits()
      }), use.names = FALSE)
      q <- fmt_bg(p, palcolor = unname(bg_colors), bg_axis = axis)
      expect_equal(bg_fills(q), unname(colors[categories]))
      expect_equal(bg_fills(fmt_bg(p, palcolor = bg_colors, bg_axis = axis)),
                     unname(bg_colors[categories]))
      defaults <- stats::setNames(grDevices::rainbow(3), names(colors))
      expect_equal(bg_fills(fmt_bg(p, bg_axis = axis)), unname(defaults[categories]))
      if (requireNamespace("plotthis", quietly = TRUE)) {
        palette_colors <- plotthis::palette_this(names(colors), palette = "Paired")
        expect_equal(bg_fills(fmt_bg(p, palette = "Paired", bg_axis = axis)),
                       unname(palette_colors[categories]))
      }
      after <- ggplot2::ggplot_build(q)
      expect_identical(after$data[-1], before$data)
      expect_equal(lapply(after$layout$panel_params, function(z) z[[paste0(axis, ".range")]]),
                     lapply(before$layout$panel_params, function(z) z[[paste0(axis, ".range")]]))
    }
  }
})

test_that("repeated backgrounds retain a bounded serializable object", {
  once <- fmt_bg(bg_plot(), palcolor = bg_colors)
  repeated <- once
  for (i in seq_len(9)) repeated <- fmt_bg(repeated, palcolor = bg_colors)
  first_size <- length(serialize(once, NULL))
  repeated_bytes <- serialize(repeated, NULL)
  expect_lte(length(repeated_bytes), first_size * 1.05)
  restored <- unserialize(repeated_bytes)
  expect_length(restored$layers, 2L)
  expect_equal(bg_fills(restored), unname(bg_colors))
  expect_identical(ggplot2::ggplot_build(restored)$data[-1], ggplot2::ggplot_build(bg_plot())$data)
})
