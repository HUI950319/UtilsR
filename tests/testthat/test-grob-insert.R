test_that("grob_insert() excludes panel annotations when standard panels exist", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "panel")

  for (name in c("annotation-for-panel", "side-panel-note", "main_panel_label",
                 "panel-note", "panel-1-note", "panelist")) {
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = 5, l = 1, r = 6, name = name)
    before <- annotated

    result <- grob_insert(annotated, grid::textGrob("Inset"))
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), c(2, 2, 4, 5))
    expect_identical(annotated, before)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() retains the custom panel-name fallback", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 7), "cm"),
                          heights = grid::unit(rep(1, 6), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 3, l = 2, r = 3, name = "central-panel-left")
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 4, b = 5, l = 5, r = 6, name = "central-panel-right")
  table <- gtable::gtable_add_grob(table, grid::textGrob("Title"),
    t = 1, l = 1, r = 7, name = "title")

  result <- grob_insert(table, grid::rectGrob())
  added <- result$layout[nrow(result$layout), , drop = FALSE]

  expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), c(2, 2, 5, 6))
  expect_no_error(grid::grid.draw(result))
})

test_that("grob_insert() reports a missing panel without range warnings", {
  table <- gtable::gtable(widths = grid::unit(rep(1, 3), "cm"),
                          heights = grid::unit(rep(1, 2), "cm"))
  annotated <- gtable::gtable_add_grob(table, grid::textGrob("Title"),
    t = 1, l = 1, r = 3, name = "title")

  for (input in list(table, annotated)) {
    expect_no_warning(expect_error(
      grob_insert(input, grid::rectGrob()),
      "Cannot find the panel area in 'plot'.", fixed = TRUE
    ))
  }
})

test_that("grob_insert() spans faceted panels without including annotations", {
  withr::local_pdf(NULL)
  data <- expand.grid(x = 1:3, row = c("Top", "Bottom"),
                       column = c("Left", "Right"))
  data$y <- rep(c(2, 1, 3), 4)
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(
    plot + ggplot2::facet_wrap(~row, ncol = 2, scales = "free"),
    plot + ggplot2::facet_grid(row ~ column, switch = "both")
  )

  for (i in seq_along(plots)) {
    table <- ggplot2::ggplotGrob(plots[[i]])
    panels <- table$layout[grepl("^panel", table$layout$name), , drop = FALSE]
    expect_equal(nrow(panels), c(2L, 4L)[i])
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = nrow(table), l = 1, r = ncol(table), name = "panel-1-note")
    before <- annotated

    result <- grob_insert(annotated, grid::rectGrob())
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])),
                 c(min(panels$t), min(panels$l), max(panels$b), max(panels$r)))
    expect_equal(dim(result), dim(annotated))
    expect_identical(annotated, before)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() uses the panel area of patchwork compositions", {
  withr::local_pdf(NULL, width = 7, height = 7)
  data <- expand.grid(x = 1:3, row = c("Top", "Bottom"),
                       column = c("Left", "Right"))
  data$y <- rep(c(2, 1, 3), 4)
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(
    patchwork::wrap_plots(plot, plot + ggplot2::coord_fixed()),
    patchwork::wrap_plots(patchwork::wrap_plots(plot, plot),
                          patchwork::wrap_plots(plot, plot), ncol = 1),
    patchwork::wrap_plots(plot + ggplot2::facet_grid(row ~ column), plot)
  )

  for (composition in plots) {
    table <- patchwork::patchworkGrob(composition)
    panel_area <- table$layout[table$layout$name == "panel-area", , drop = FALSE]
    expect_equal(nrow(panel_area), 1L)
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = nrow(table), l = 1, r = ncol(table), name = "panel-note")

    for (input in list(composition, annotated)) {
      result <- grob_insert(input, grid::textGrob("Inset"))
      added <- result$layout[nrow(result$layout), , drop = FALSE]

      expect_equal(added[c("t", "l", "b", "r")],
                   panel_area[c("t", "l", "b", "r")], ignore_attr = TRUE)
      expect_equal(result$respect, table$respect)
      expect_equal(result$widths, table$widths)
      expect_equal(result$heights, table$heights)
      expect_no_error(grid::grid.draw(result))
    }
  }
})

test_that("grob_insert() keeps successive insets aligned to custom panels", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "custom-panel")

  result <- grob_insert(grob_insert(table, grid::rectGrob()),
                         grid::textGrob("Second inset"), left = 0.2, bottom = 0.2)
  insets <- result$layout[result$layout$name == "inset", , drop = FALSE]

  expect_equal(nrow(insets), 2L)
  expect_equal(insets$t, c(2, 2))
  expect_equal(insets$l, c(2, 2))
  expect_equal(insets$b, c(4, 4))
  expect_equal(insets$r, c(5, 5))
  expect_no_error(grid::grid.draw(result))
})

test_that("grob_insert() keeps panel, plot and full reference areas distinct", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "background")
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 3, l = 3, r = 4, name = "panel")
  table <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
    t = 1, b = 5, l = 1, r = 6, name = "annotation-for-panel")
  expected <- list(panel = c(3, 3, 3, 4), plot = c(2, 2, 4, 5),
                    full = c(1, 1, 5, 6))

  for (align_to in names(expected)) {
    result <- grob_insert(table, grid::rectGrob(), align_to = align_to)
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), expected[[align_to]])
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() supports plot and full alignment without panels", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::textGrob("Title"),
    t = 1, l = 2, r = 5, name = "title")

  for (align_to in c("plot", "full")) {
    result <- grob_insert(table, grid::rectGrob(), align_to = align_to)
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), c(1, 1, 5, 6))
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() preserves inset coordinates and drawing controls", {
  withr::local_pdf(NULL)
  data <- data.frame(x = 1:3, y = c(2, 1, 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  inset <- grid::gList(grid::rectGrob(), grid::textGrob("Inset"))
  table <- ggplot2::ggplotGrob(plot)

  for (on_top in c(TRUE, FALSE)) {
    result <- grob_insert(plot, inset, left = 0.2, bottom = 0.3,
                           right = 0.8, top = 0.7, on_top = on_top, clip = on_top)
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    viewport <- result$grobs[[length(result$grobs)]]$vp

    expect_equal(as.numeric(viewport$x), 0.2)
    expect_equal(as.numeric(viewport$y), 0.3)
    expect_equal(as.numeric(viewport$width), 0.6)
    expect_equal(as.numeric(viewport$height), 0.4)
    expect_equal(grid::unitType(viewport$width), "npc")
    expect_identical(added$clip, if (on_top) "on" else "off")
    expect_equal(added$z, if (on_top) max(table$layout$z) + 1L else 0L)
    expect_no_error(grid::grid.draw(result))
  }

  result <- grob_insert(table, grid::rectGrob(),
                         left = grid::unit(2, "mm"), bottom = grid::unit(3, "mm"),
                         right = grid::unit(12, "mm"), top = grid::unit(13, "mm"))
  viewport <- result$grobs[[length(result$grobs)]]$vp
  expect_equal(grid::convertWidth(viewport$width, "mm", valueOnly = TRUE), 10)
  expect_equal(grid::convertHeight(viewport$height, "mm", valueOnly = TRUE), 10)
  expect_no_error(grid::grid.draw(result))
})
