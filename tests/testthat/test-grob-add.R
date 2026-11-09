test_that("grob_add treats a grob list as one grouped margin graphic", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(1, "cm"), heights = grid::unit(1, "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(), t = 1, l = 1, name = "panel")
  graphics <- grid::gList(grid::rectGrob(), grid::textGrob("Margin"))
  for (position in c("top", "bottom", "left", "right")) {
    result <- grob_add(table, graphics, position = position, space = grid::unit(1, "cm"))
    expect_length(result$grobs, length(table$grobs) + 1L)
    added <- tail(result$grobs, 1L)[[1L]]
    expect_s3_class(added, "gTree")
    expect_length(added$children, 2L)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("margin additions prefer canonical panels to panel-named annotations", {
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "panel")
  table <- gtable::gtable_add_grob(table, grid::textGrob("Note"),
    t = 1, b = 5, l = 1, r = 6, name = "panel-note")
  before <- table
  for (position in c("top", "bottom", "left", "right")) {
    result <- grob_add(table, grid::rectGrob(), position = position,
                        space = grid::unit(1, "cm"))
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    if (position %in% c("top", "bottom")) {
      expect_equal(unname(unlist(added[c("l", "r")])), c(2, 5))
    } else {
      expect_equal(unname(unlist(added[c("t", "b")])), c(2, 4))
    }
    expect_identical(table, before)
  }
})

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

test_that("grob_add() preserves fixed-aspect patchwork constraints", {
  withr::local_pdf(NULL, width = 7, height = 7)
  data <- data.frame(x = 1:3, y = c(2, 1, 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  table <- grob_as(patchwork::wrap_plots(plot + ggplot2::coord_fixed(), plot))
  expect_true(is.matrix(table$respect))

  for (position in c("top", "bottom", "left", "right")) {
    result <- grob_add(table, grid::rectGrob(), position = position,
                        space = grid::unit(3, "mm"))
    expected <- switch(position, top = rbind(0, table$respect),
      bottom = rbind(table$respect, 0), left = cbind(0, table$respect),
      right = cbind(table$respect, 0))

    expect_equal(dim(result$respect), dim(result))
    expect_equal(result$respect, expected)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_add() keeps added margins out of subsequent panel alignment", {
  withr::local_pdf(NULL)
  sequences <- list(c("top", "left"), c("left", "top"),
                     c("bottom", "right"), c("right", "bottom"))
  expected <- list(c(3, 1, 5, 1), c(1, 3, 1, 6),
                    c(2, 7, 4, 7), c(6, 2, 6, 5))

  for (name in c("layout", "panel", "main-panel")) {
    table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                            heights = grid::unit(rep(1, 5), "cm"), name = name)
    table <- gtable::gtable_add_grob(table, grid::rectGrob(),
      t = 2, b = 4, l = 2, r = 5, name = "panel-1")
    for (i in seq_along(sequences)) {
      result <- table
      for (position in sequences[[i]]) {
        result <- grob_add(result, grid::rectGrob(), position = position,
                            space = grid::unit(2, "mm"))
      }
      added <- result$layout[nrow(result$layout), , drop = FALSE]

      expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), expected[[i]])
      expect_no_error(grid::grid.draw(result))
    }
  }
})

test_that("grob_add() prefers panel prefixes over unrelated panel mentions", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "panel-1")
  expected <- list(top = c(1, 2, 1, 5), bottom = c(6, 2, 6, 5),
                    left = c(2, 1, 4, 1), right = c(2, 7, 4, 7))

  for (name in c("annotation-for-panel", "side-panel-note", "main_panel_label")) {
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = 5, l = 1, r = 6, name = name)
    for (position in names(expected)) {
      result <- grob_add(annotated, grid::rectGrob(), position = position,
                          space = grid::unit(2, "mm"))
      added <- result$layout[nrow(result$layout), , drop = FALSE]

      expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), expected[[position]])
      expect_no_error(grid::grid.draw(result))
    }
  }

  table$layout$name <- "central-panel"
  for (position in names(expected)) {
    result <- grob_add(table, grid::rectGrob(), position = position,
                        space = grid::unit(2, "mm"))
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), expected[[position]])
  }
})

test_that("grob margins diagnose invalid controls before converting plots", {
  for (bad in list(NA_character_, "bad", c("on", "off"), matrix("on")))
    expect_error(grob_add(stop("plot evaluated"), grid::nullGrob(), clip = bad), "clip")
  for (bad in list(1, matrix(1), grid::unit(NA_real_, "mm")))
    expect_error(grob_add(stop("plot evaluated"), grid::nullGrob(), space = bad), "space")
})

test_that("margin additions reject non-graphics before building the main plot", {
  for (bad in list(1, "text", list(1)))
    expect_error(grob_add(stop("plot evaluated"), bad), "grob")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  expect_s3_class(grob_add(p, stop("inactive"), position = "none"), "gtable")
  additions <- list(grid::rectGrob(), grid::textGrob("Note"))
  expect_s3_class(grob_add(p, additions, space = grid::unit(1, "cm")), "gtable")
})

test_that("grob lists receive automatic margin dimensions", {
  withr::local_pdf(NULL)
  p <- gtable::gtable(widths = grid::unit(1, "in"), heights = grid::unit(1, "in"))
  p <- gtable::gtable_add_grob(p, grid::rectGrob(), t = 1, l = 1, name = "panel")
  additions <- list(grid::rectGrob(width = grid::unit(3, "cm"), height = grid::unit(1, "cm")),
                    grid::rectGrob(width = grid::unit(4, "cm"), height = grid::unit(2, "cm")))
  for (position in c("top", "bottom", "left", "right")) {
    actual <- grob_add(p, additions, position = position)
    vertical <- position %in% c("top", "bottom")
    expected <- grob_add(p, additions, position = position, space = grid::unit(if (vertical) 2 else 4, "cm"))
    expect_equal(actual$layout, expected$layout)
    size <- if (vertical) actual$heights else actual$widths
    reference <- if (vertical) expected$heights else expected$widths
    expect_equal(grid::convertUnit(size, "cm", valueOnly = TRUE), grid::convertUnit(reference, "cm", valueOnly = TRUE))
    expect_no_error(grid::grid.draw(actual))
  }
})
