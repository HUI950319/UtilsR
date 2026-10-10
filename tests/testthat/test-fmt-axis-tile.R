axis_tile_plot <- function() {
  ggplot2::ggplot(data.frame(category = factor(c("A", "B", "C")),
                              value = c(2, 5, 3)),
                   ggplot2::aes(category, value)) + ggplot2::geom_col()
}

axis_tile_colors <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")

axis_tile_text <- function(g) {
  result <- if (inherits(g, "text")) {
    data.frame(label = as.character(g$label),
               colour = rep_len(if (is.null(g$gp$col)) NA_character_ else g$gp$col, length(g$label)),
               hjust = rep_len(if (is.null(g$hjust)) NA_real_ else g$hjust, length(g$label)),
               vjust = rep_len(if (is.null(g$vjust)) NA_real_ else g$vjust, length(g$label)),
               angle = rep_len(if (is.null(g$rot)) NA_real_ else g$rot, length(g$label)))
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

test_that("axis tiles visit nested leaves and retain layouts and fixed entries", {
  p <- axis_tile_plot()
  inset <- p + patchwork::inset_element(p, 0.6, 0.6, 1, 1)
  fixed <- patchwork::wrap_elements(full = grid::textGrob("FIXED"))
  pw <- patchwork::free((p | patchwork::plot_spacer()) / (inset | fixed), side = "l") +
    patchwork::plot_annotation(title = "KEEP_TITLE", caption = "KEEP_CAPTION")
  for (mode in c("tile", "text")) {
    q <- fmt_axisTile(pw, axis_tile_colors, mode = mode)
    expect_identical(q$patches$layout, pw$patches$layout)
    expect_identical(q$patches$annotation, pw$patches$annotation)
    expect_identical(attr(q, "patchwork_free_settings"), attr(pw, "patchwork_free_settings"))
    leaves <- .to_plot_list(q, recurse = TRUE)$plots
    expect_true(all(vapply(leaves, function(z) inherits(z$guides$guides$x, "AxisTileGuide"), logical(1))))
    expect_true(all(c("KEEP_TITLE", "KEEP_CAPTION", "FIXED") %in%
      axis_tile_text(patchwork::patchworkGrob(q))$label))
  }
})

test_that("repeated axis formatting updates guides without nesting or duplicate tiles", {
  p <- axis_tile_plot()
  inputs <- list(p, list(first = p, second = p | p))
  for (input in inputs) {
    first <- fmt_axisTile(input, axis_tile_colors)
    second <- fmt_axisTile(first, axis_tile_colors)
    tree <- function(z) {
      if (inherits(z, "patchwork")) return(lapply(seq_along(z), function(i) tree(z[[i]])))
      if (is.list(z) && !inherits(z, "gg")) return(lapply(z, tree))
      "plot"
    }
    expect_identical(tree(second), tree(first))
    expect_identical(names(second), names(first))
    leaves <- .to_plot_list(second, recurse = TRUE)$plots
    expect_true(all(vapply(leaves, function(z) nrow(axis_tile_rects(ggplot2::ggplotGrob(z))) == 3L,
                           logical(1))))
    text <- fmt_axisTile(second, axis_tile_colors, mode = "text")
    expect_true(all(vapply(.to_plot_list(text, recurse = TRUE)$plots,
      function(z) is.null(axis_tile_rects(ggplot2::ggplotGrob(z))), logical(1))))
  }
})

test_that("axis tiles respect physical sides and preserve existing guide controls", {
  p <- axis_tile_plot()
  right <- ggplot2::ggplot(p$data, ggplot2::aes(value, category)) +
    ggplot2::geom_col(orientation = "y") + ggplot2::scale_y_discrete(position = "right")
  cases <- list(
    list(p + ggplot2::coord_flip(), "y", "axis-l"),
    list(p + ggplot2::scale_x_discrete(position = "top"), "x", "axis-t"),
    list(right, "y", "axis-r")
  )
  for (case in cases) {
    q <- fmt_axisTile(case[[1]], axis_tile_colors, axis = case[[2]])
    g <- ggplot2::ggplotGrob(q[[1]])
    name <- sub("axis-", "panel-axis-tile-", case[[3]])
    rects <- axis_tile_rects(g$grobs[[match(name, g$layout$name)]])
    expect_equal(rects$fill, unname(axis_tile_colors))
    labels <- axis_tile_text(g$grobs[[match(case[[3]], g$layout$name)]])
    reference <- case[[1]] + do.call(ggplot2::guides, stats::setNames(
      list(ggplot2::guide_axis(angle = if (case[[2]] == "x") 45 else 0)), case[[2]]))
    reference <- ggplot2::ggplotGrob(reference)
    expected <- axis_tile_text(reference$grobs[[match(case[[3]], reference$layout$name)]])
    expect_equal(labels$hjust, expected$hjust)
    expect_equal(labels$vjust, expected$vjust)
  }
  original <- ggplot2::guide_axis(n.dodge = 2, check.overlap = TRUE,
    theme = ggplot2::theme(axis.text = ggplot2::element_text(family = "mono")))
  params <- original$params
  p <- p + ggplot2::scale_x_discrete(guide = original) + ggplot2::coord_flip()
  q <- fmt_axisTile(p, axis_tile_colors, axis = "y")
  expect_equal(q[[1]]$guides$guides$y$params$n.dodge, 2)
  expect_identical(q[[1]]$guides$guides$y$params$check.overlap, TRUE)
  expect_identical(original$params, params)
  expect_no_error(patchwork::patchworkGrob(q))
})

test_that("axis tiles leave disabled and continuous axes visually unchanged", {
  p <- axis_tile_plot() + ggplot2::scale_x_discrete(guide = "none")
  for (mode in c("tile", "text")) {
    q <- fmt_axisTile(p, axis_tile_colors, mode = mode)
    expect_true(identical(q, p))
  }
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = 4:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::labs(x = "CONTINUOUS")
  before <- axis_tile_text(ggplot2::ggplotGrob(p))
  for (mode in c("tile", "text")) {
    q <- fmt_axisTile(p, axis_tile_colors, mode = mode)
    leaf <- if (inherits(q, "patchwork")) q[[1]] else q
    expect_equal(axis_tile_text(ggplot2::ggplotGrob(leaf)), before)
    expect_equal(ggplot2::ggplot_build(leaf)$data, ggplot2::ggplot_build(p)$data)
  }
})

test_that("axis tiles use non-empty layer data and reject unsupported coordinates", {
  p <- ggplot2::ggplot(data.frame(category = character(), value = numeric())) +
    ggplot2::geom_col(data = axis_tile_plot()$data, ggplot2::aes(category, value))
  q <- fmt_axisTile(p, axis_tile_colors)
  expect_equal(axis_tile_rects(patchwork::patchworkGrob(q))$fill, unname(axis_tile_colors))
  for (mode in c("tile", "text")) {
    for (coord in list(ggplot2::coord_polar(), ggplot2::coord_radial())) {
      expect_error(fmt_axisTile(axis_tile_plot() + coord, axis_tile_colors, mode = mode),
                     "Cartesian")
    }
  }
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

test_that("later axis formatters can hide and restyle colored guides", {
  for (mode in c("tile", "text")) {
    q <- fmt_axisTile(axis_tile_plot(), axis_tile_colors, mode = mode)
    hidden <- fmt_axis(q, x.axis = TRUE)
    g <- if (inherits(hidden, "patchwork")) patchwork::patchworkGrob(hidden) else ggplot2::ggplotGrob(hidden)
    expect_false(any(axis_tile_text(g)$label %in% c("A", "B", "C")))
    expect_null(axis_tile_rects(g))
    rotated <- fmt_axisText(q, x = 90, color = "black")
    g <- if (inherits(rotated, "patchwork")) patchwork::patchworkGrob(rotated) else ggplot2::ggplotGrob(rotated)
    labels <- axis_tile_text(g)
    index <- match(c("A", "B", "C"), labels$label)
    expect_equal(labels$angle[index], rep(90, 3))
    expect_equal(labels$colour[index], rep("black", 3))
  }
})
