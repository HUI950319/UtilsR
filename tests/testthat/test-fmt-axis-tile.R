axis_tile_plot <- function() {
  ggplot2::ggplot(data.frame(category = factor(c("A", "B", "C")),
                              value = c(2, 5, 3)),
                   ggplot2::aes(category, value)) + ggplot2::geom_col()
}

axis_tile_colors <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")

axis_tile_text <- function(g) {
  result <- if (inherits(g, "text")) {
    data.frame(label = as.character(g$label),
               colour = rep_len(if (is.null(g$gp$col)) NA_character_ else g$gp$col, length(g$label)))
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  result <- do.call(rbind, c(list(result), lapply(children, axis_tile_text)))
  rownames(result) <- NULL
  result
}

axis_tile_rects <- function(g) {
  result <- if (inherits(g, "rect") &&
      any(g$gp$fill %in% c(axis_tile_colors, "grey70", "#B3B3B3"))) {
    data.frame(fill = grDevices::rgb(t(grDevices::col2rgb(g$gp$fill)), maxColorValue = 255),
               x = as.numeric(g$x), y = as.numeric(g$y),
               width = as.numeric(g$width), height = as.numeric(g$height))
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  do.call(rbind, c(list(result), lapply(children, axis_tile_rects)))
}

test_that("axis tiles validate color keys and scalar styling arguments", {
  p <- axis_tile_plot()
  bad_colors <- list(character(), unname(axis_tile_colors),
                       c(A = "red", A = "blue"), stats::setNames("red", ""),
                       stats::setNames("red", NA_character_), c(A = "not-a-color"),
                       c(A = 1))
  for (colors in bad_colors) expect_error(fmt_axisTile(p, colors), "colors")
  for (arg in c("tile_height", "tile_width", "text_size")) {
    for (value in list(0, -1, NA_real_, Inf, c(1, 2), "1", TRUE)) {
      expect_error(do.call(fmt_axisTile, c(list(p, axis_tile_colors),
                                          stats::setNames(list(value), arg))), arg)
    }
  }
  for (value in list(-1, NA_real_, Inf, c(1, 2))) {
    expect_error(fmt_axisTile(p, axis_tile_colors, tile_border_width = value),
                   "tile_border_width")
  }
  expect_error(fmt_axisTile(p, axis_tile_colors, show_text = NA), "show_text")
  expect_error(fmt_axisTile(p, axis_tile_colors, show_text = 1), "show_text")
  expect_error(fmt_axisTile(p, axis_tile_colors, text_angle = Inf), "text_angle")
  expect_error(fmt_axisTile(p, axis_tile_colors, text_face = "heavy"), "text_face")
  expect_error(fmt_axisTile(p, axis_tile_colors, text_color = "not-a-color"), "text_color")
  expect_error(fmt_axisTile(p, axis_tile_colors, tile_border = "not-a-color"), "tile_border")
})

test_that("missing axis colors use documented fallbacks and text visibility", {
  p <- axis_tile_plot()
  tile <- fmt_axisTile(p, axis_tile_colors["A"])
  expect_equal(axis_tile_rects(patchwork::patchworkGrob(tile))$fill,
                 c(axis_tile_colors[["A"]], "#B3B3B3", "#B3B3B3"))
  text <- suppressWarnings(fmt_axisTile(p, axis_tile_colors["A"], mode = "text",
                                         text_color = "purple"))
  labels <- axis_tile_text(ggplot2::ggplotGrob(text))
  expect_equal(labels$colour[match(c("A", "B", "C"), labels$label)],
                 c(axis_tile_colors[["A"]], "purple", "purple"))
  hidden <- fmt_axisTile(p, axis_tile_colors, mode = "text", show_text = FALSE)
  expect_false(any(axis_tile_text(ggplot2::ggplotGrob(hidden))$label %in% c("A", "B", "C")))
})

test_that("axis colors follow trained scale order, breaks and display labels", {
  p <- axis_tile_plot() + ggplot2::scale_x_discrete(
    limits = c("C", "B", "A"), breaks = c("C", "A"), labels = c("Gamma", "Alpha"))
  tile <- fmt_axisTile(p, axis_tile_colors)
  g <- patchwork::patchworkGrob(tile)
  expect_equal(axis_tile_rects(g)$fill, unname(axis_tile_colors[c("C", "B", "A")]))
  expect_true(all(c("Gamma", "Alpha") %in% axis_tile_text(g)$label))
  expect_false(any(axis_tile_text(g)$label %in% c("A", "B", "C")))
  text <- fmt_axisTile(p, axis_tile_colors, mode = "text")
  labels <- axis_tile_text(ggplot2::ggplotGrob(text))
  expect_equal(labels$colour[match(c("Gamma", "Alpha"), labels$label)],
                 unname(axis_tile_colors[c("C", "A")]))
})

test_that("axis tiles support expression and layer mappings without eager evaluation", {
  colors <- stats::setNames(c("red", "blue", "green"), c("4", "6", "8"))
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) + ggplot2::geom_boxplot()
  for (mode in c("tile", "text")) {
    q <- fmt_axisTile(p, colors, mode = mode)
    expect_no_error(if (mode == "tile") patchwork::patchworkGrob(q) else ggplot2::ggplotGrob(q))
  }
  p <- ggplot2::ggplot() + ggplot2::geom_col(
    data = axis_tile_plot()$data, ggplot2::aes(.data[["category"]], value))
  q <- fmt_axisTile(p, axis_tile_colors)
  expect_equal(nrow(axis_tile_rects(patchwork::patchworkGrob(q))), 3L)
  calls <- 0L
  p <- ggplot2::ggplot(data.frame(category = c("A", "B"), value = 1:2),
                       ggplot2::aes(category, value)) + ggplot2::geom_point(
    data = function(d) { calls <<- calls + 1L; d })
  set.seed(42)
  seed <- .Random.seed
  q <- fmt_axisTile(p, axis_tile_colors)
  expect_equal(calls, 0L)
  expect_identical(.Random.seed, seed)
  patchwork::patchworkGrob(q)
  expect_equal(calls, 1L)
})

test_that("axis tiles follow dropped and missing categories", {
  p <- axis_tile_plot()
  p$data <- p$data[c(1, 3), ]
  q <- fmt_axisTile(p, axis_tile_colors)
  expect_equal(axis_tile_rects(patchwork::patchworkGrob(q))$fill,
                 unname(axis_tile_colors[c("A", "C")]))
  p$data$category[2] <- NA
  q <- fmt_axisTile(p, axis_tile_colors)
  expect_equal(axis_tile_rects(patchwork::patchworkGrob(q))$fill,
                 c(axis_tile_colors[["A"]], "#B3B3B3"))
})

test_that("empty discrete data does not create a tile strip", {
  p <- ggplot2::ggplot(data.frame(category = character(), value = numeric()),
                       ggplot2::aes(category, value)) + ggplot2::geom_col()
  expect_identical(fmt_axisTile(p, axis_tile_colors), p)
})

test_that("axis tile positions follow each facet's trained expansion and statistics", {
  dat <- data.frame(category = factor(c("A", "B", "A", "C")),
                       group = c("one", "one", "two", "two"))
  p <- ggplot2::ggplot(dat, ggplot2::aes(category)) + ggplot2::geom_bar() +
    ggplot2::facet_wrap(~group, scales = "free_x") +
    ggplot2::scale_x_discrete(expand = ggplot2::expansion(add = 2)) +
    ggplot2::labs(x = "CATEGORY_TITLE")
  q <- fmt_axisTile(p, axis_tile_colors)
  build <- ggplot2::ggplot_build(q[[1]])
  expect_equal(build$data, ggplot2::ggplot_build(p)$data)
  g <- ggplot2::ggplotGrob(q[[1]])
  indices <- grep("^panel-axis-tile-b", g$layout$name)
  indices <- indices[order(g$layout$l[indices])]
  for (i in seq_along(indices)) {
    rects <- axis_tile_rects(g$grobs[[indices[i]]])
    scale <- build$layout$panel_params[[i]]$x
    positions <- scale$break_positions()
    span <- diff(scale$continuous_range)
    low <- pmax(0, positions - 0.5 / span)
    high <- pmin(1, positions + 0.5 / span)
    expect_equal(rects$x, (low + high) / 2)
    expect_equal(rects$width, high - low)
    expect_equal(rects$fill, unname(axis_tile_colors[scale$get_limits()]))
  }
  expect_true("CATEGORY_TITLE" %in% axis_tile_text(g)$label)
})

test_that("axis tile thickness retains panel proportions and independent axis modes", {
  p <- axis_tile_plot()
  q <- fmt_axisTile(p, axis_tile_colors, tile_height = 0.12)
  g <- ggplot2::ggplotGrob(q[[1]])
  strip <- g$layout$t[match("panel-axis-tile-b", g$layout$name)]
  panel <- g$layout$t[match("panel", g$layout$name)]
  expect_equal(as.numeric(g$heights[strip]) / as.numeric(g$heights[panel]), 0.12)
  expect_equal(grid::unitType(g$heights[strip]), "null")
  p$data$second <- factor(c("D", "E", "F"))
  p <- ggplot2::ggplot(p$data, ggplot2::aes(category, second)) + ggplot2::geom_point()
  colors_y <- stats::setNames(axis_tile_colors, c("D", "E", "F"))
  both <- fmt_axisTile(fmt_axisTile(p, axis_tile_colors), colors_y, axis = "y")
  expect_equal(nrow(axis_tile_rects(patchwork::patchworkGrob(both))), 6L)
  mixed <- fmt_axisTile(both, colors_y, axis = "y", mode = "text")
  expect_equal(nrow(axis_tile_rects(patchwork::patchworkGrob(mixed))), 3L)
  text <- fmt_axisTile(mixed, axis_tile_colors, mode = "text")
  expect_null(axis_tile_rects(patchwork::patchworkGrob(text)))
})
