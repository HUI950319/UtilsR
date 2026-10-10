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
