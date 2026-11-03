test_that("grob_add() uses full panel extents in all four directions", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 8), "cm"),
                          heights = grid::unit(rep(1, 7), "cm"))
  table <- gtable::gtable_add_grob(
    table, list(grid::rectGrob(), grid::rectGrob()),
    t = c(2, 5), b = c(3, 6), l = c(2, 5), r = c(3, 7),
    name = c("panel-1", "panel-2")
  )
  before <- table
  expected <- list(top = c(1, 2, 1, 7), bottom = c(8, 2, 8, 7),
                    left = c(2, 1, 6, 1), right = c(2, 9, 6, 9))
  space <- grid::unit(4, "mm")

  for (position in names(expected)) {
    result <- grob_add(table, grid::rectGrob(), position = position,
                        space = space, clip = "off")
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    bounds <- unname(unlist(added[c("t", "l", "b", "r")]))

    expect_equal(bounds, expected[[position]])
    expect_equal(bounds, round(bounds))
    expect_identical(added$clip, "off")
    if (position %in% c("top", "bottom")) {
      edge <- if (position == "top") 1L else nrow(result)
      expect_equal(grid::convertHeight(result$heights[edge], "mm", TRUE), 4)
    } else {
      edge <- if (position == "left") 1L else ncol(result)
      expect_equal(grid::convertWidth(result$widths[edge], "mm", TRUE), 4)
    }
    expect_no_error(grid::grid.draw(result))
  }
  expect_identical(table, before)
})

test_that("grob_add() spans all columns and rows of faceted ggplots", {
  withr::local_pdf(NULL)
  data <- expand.grid(x = 1:3, row = c("Top", "Bottom"),
                       column = c("Left", "Right"))
  data$y <- rep(c(2, 1, 3), 4)
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::facet_grid(row ~ column)
  native <- ggplot2::ggplotGrob(plot)
  panels <- native$layout[grepl("^panel", native$layout$name), , drop = FALSE]
  expect_equal(nrow(panels), 4L)

  for (position in c("top", "bottom", "left", "right")) {
    result <- grob_add(plot, grid::rectGrob(), position = position,
                        space = grid::unit(2, "mm"))
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    if (position %in% c("top", "bottom")) {
      expect_equal(c(added$l, added$r), c(min(panels$l), max(panels$r)))
    } else {
      expect_equal(c(added$t, added$b), c(min(panels$t), max(panels$b)))
    }
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_add() preserves single-panel placement and automatic spacing", {
  withr::local_pdf(NULL)
  data <- data.frame(x = 1:3, y = c(2, 1, 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  native <- ggplot2::ggplotGrob(plot)
  panel <- native$layout[native$layout$name == "panel", , drop = FALSE]
  side <- gtable::gtable(widths = grid::unit(2, "cm"),
                         heights = grid::unit(3, "cm"))

  for (position in c("top", "bottom", "left", "right")) {
    result <- grob_add(plot, side, position = position)
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    if (position %in% c("top", "bottom")) {
      expect_equal(c(added$l, added$r), c(panel$l, panel$r))
      edge <- if (position == "top") 1L else nrow(result)
      expect_equal(grid::convertHeight(result$heights[edge], "mm", TRUE), 30)
    } else {
      expect_equal(c(added$t, added$b), c(panel$t, panel$b))
      edge <- if (position == "left") 1L else ncol(result)
      expect_equal(grid::convertWidth(result$widths[edge], "mm", TRUE), 20)
    }
  }
})

test_that("grob_add() reports missing panels only when adding a grob", {
  table <- gtable::gtable(widths = grid::unit(1, "cm"),
                          heights = grid::unit(1, "cm"))
  expect_identical(grob_add(table, NULL), table)
  expect_identical(grob_add(table, grid::rectGrob(), position = "none"), table)
  expect_error(grob_add(table, grid::rectGrob()), "panel area")
})
