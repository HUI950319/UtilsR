axis_tile_plot <- function() {
  ggplot2::ggplot(data.frame(category = factor(c("A", "B", "C")),
                              value = c(2, 5, 3)),
                   ggplot2::aes(category, value)) + ggplot2::geom_col()
}

axis_tile_colors <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")

axis_tile_text <- function(g) {
  result <- if (inherits(g, "text")) {
    data.frame(label = as.character(g$label),
               colour = rep_len(g$gp$col, length(g$label)))
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  do.call(rbind, c(list(result), lapply(children, axis_tile_text)))
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
  expect_equal(ggplot2::ggplot_build(tile[[2]])$data[[1]]$fill,
                 c(axis_tile_colors[["A"]], "grey70", "grey70"))
  text <- suppressWarnings(fmt_axisTile(p, axis_tile_colors["A"], mode = "text",
                                         text_color = "purple"))
  labels <- axis_tile_text(ggplot2::ggplotGrob(text))
  expect_equal(labels$colour[match(c("A", "B", "C"), labels$label)],
                 c(axis_tile_colors[["A"]], "purple", "purple"))
  hidden <- fmt_axisTile(p, axis_tile_colors, mode = "text", show_text = FALSE)
  expect_false(any(axis_tile_text(ggplot2::ggplotGrob(hidden))$label %in% c("A", "B", "C")))
})

test_that("empty discrete data does not create a tile strip", {
  p <- ggplot2::ggplot(data.frame(category = character(), value = numeric()),
                       ggplot2::aes(category, value)) + ggplot2::geom_col()
  expect_identical(fmt_axisTile(p, axis_tile_colors), p)
})
