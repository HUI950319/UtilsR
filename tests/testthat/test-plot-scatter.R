scatter_main_points <- function(grob) {
  if (inherits(grob, "points") && grepl("geom_point", grob$name)) {
    return(length(grob$x))
  }
  children <- c(grob$grobs, as.list(grob$children))
  sum(vapply(children, scatter_main_points, numeric(1L)))
}

scatter_grob_labels <- function(grob) {
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  children <- c(grob$grobs, as.list(grob$children))
  c(labels, unlist(lapply(children, scatter_grob_labels), use.names = FALSE))
}

test_that("PlotScatter3 derives automatic histogram limits from paired differences", {
  withr::local_options(lifecycle_verbosity = "quiet")
  inset <- NULL
  testthat::local_mocked_bindings(ggplotGrob = function(x, ...) {
    inset <<- x
    grid::nullGrob()
  }, .package = "ggplot2")
  for (offset in c(10, -20)) {
    data <- data.frame(Control = offset + 0:5,
                       Treat = offset + c(1, 3, 4, 4, 6, 8),
                       group = rep(c("NS", "S"), 3))
    PlotScatter3(data, test_method = "none", cor_method = "none")
    histogram <- ggplot2::ggplot_build(inset)$data[[1]]
    expect_equal(sum(histogram$count), 6)
    expect_lte(inset$scales$get_scales("x")$limits[1], 1)
    expect_gte(inset$scales$get_scales("x")$limits[2], 3)
  }
  data$Treat <- data$Control + 2
  PlotScatter3(data, test_method = "none", cor_method = "none")
  expect_equal(sum(ggplot2::ggplot_build(inset)$data[[1]]$count), 6)
  expect_gt(diff(inset$scales$get_scales("x")$limits), 0)
  data$Treat <- data$Control
  PlotScatter3(data, test_method = "none", cor_method = "none")
  expect_equal(sum(ggplot2::ggplot_build(inset)$data[[1]]$count), 6)
  expect_gt(diff(inset$scales$get_scales("x")$limits), 0)
  PlotScatter3(data, test_method = "none", cor_method = "none", hist_x_limits = c(-2, 4))
  expect_identical(inset$scales$get_scales("x")$limits, c(-2, 4))
})

test_that("PlotScatter1 requires explicit mappings beyond twelve groups", {
  data <- data.frame(x = 1:26, y = rep(1:2, 13), g = rep(letters[1:13], each = 2))
  draw <- function(...) PlotScatter1(data, "x", "y", "g", show_ellipse = FALSE,
                                     box_jitter = FALSE, ...)
  expect_error(draw(), "12.*colors.*shapes")
  expect_error(draw(colors = grDevices::hcl.colors(13)), "12.*shapes")
  expect_error(draw(shapes = rep(16, 13)), "12.*colors")
  p <- draw(colors = grDevices::hcl.colors(13), shapes = rep(16, 13))
  expect_equal(scatter_main_points(attr(p, "grobs")$full), 26)
  recycled <- draw(colors = "red", shapes = 16)
  expect_equal(scatter_main_points(attr(recycled, "grobs")$full), 26)
  boundary <- PlotScatter1(data[1:24, ], "x", "y", "g", show_ellipse = FALSE,
                           box_jitter = FALSE)
  expect_equal(scatter_main_points(attr(boundary, "grobs")$full), 24)
})

test_that("PlotScatter2 requires explicit mappings beyond its default capacities", {
  data <- data.frame(x = 1:26, y = rep(1:2, 13), g = rep(letters[1:13], each = 2))
  expect_error(PlotScatter2(data, "x", "y", "g"), "12.*colors")
  p <- PlotScatter2(data, "x", "y", "g", colors = grDevices::hcl.colors(13))
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(nrow(points), 26L)
  expect_false(anyNA(points$colour))

  data <- data.frame(x = 1:14, y = rep(1:2, 7), g = "a",
                     h = rep(letters[1:7], each = 2))
  draw <- function(...) PlotScatter2(data, "x", "y", "g", group2 = "h", ...)
  shapes <- stats::setNames(rep(16, 7), letters[1:7])
  fills <- stats::setNames(grDevices::hcl.colors(7), letters[1:7])
  expect_error(draw(), "6.*shapes.*fill_colors_shape")
  expect_error(draw(shapes = shapes), "6.*fill_colors_shape")
  expect_error(draw(fill_colors_shape = fills), "6.*shapes")
  p <- draw(shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(nrow(points), 14L)
  expect_false(anyNA(points$shape))
  boundary <- PlotScatter2(data[1:12, ], "x", "y", "g", group2 = "h")
  expect_false(anyNA(ggplot2::ggplot_build(boundary[[1]])$data[[1]]$shape))
})

test_that("PlotScatter2 rejects incomplete explicit mappings", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  draw <- function(...) PlotScatter2(data, "x", "y", "g", group2 = "h", ...)
  mappings <- list(
    colors = c(b = "red", c = "blue", unused = "black"),
    shapes = c(Y = 17, Z = 15, unused = 16),
    fill_colors_shape = c(Y = "gold", Z = "green", unused = "black")
  )
  missing <- c(colors = "a", shapes = "X", fill_colors_shape = "X")
  for (arg in names(mappings)) {
    message <- tryCatch({
      do.call(draw, stats::setNames(list(mappings[[arg]]), arg))
      NULL
    }, error = conditionMessage)
    expect_identical(message, sprintf("'%s' is missing mappings for: %s.",
                                      arg, missing[[arg]]))

    message <- tryCatch({
      do.call(draw, stats::setNames(list(unname(mappings[[arg]][1:2])), arg))
      NULL
    }, error = conditionMessage)
    expect_identical(message, sprintf(
      "'%s' must supply at least 3 values, one for each observed group level.", arg
    ))
  }
})

test_that("PlotScatter2 matches complete named mappings by level", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = factor(rep(c("b", "a", "c"), each = 3),
                                levels = c("unused", "c", "a", "b")),
                     h = rep(c("Y", "X", "Z"), each = 3))
  colors <- c(c = "#336699", a = "#993333", b = "#339933", extra = "black")
  shapes <- c(Z = 15, X = 18, Y = 17, extra = 16)
  fills <- c(X = "#999933", Z = "#993399", Y = "#339999", extra = "white")
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h", colors = colors,
                    shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_identical(points$colour, unname(colors[as.character(data$g)]))
  expect_identical(points$shape, unname(shapes[data$h]))
  for (panel in c(2, 4)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, unname(colors[c("b", "a", "c")]))
  }
  for (panel in c(3, 5)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, unname(fills[c("Y", "X", "Z")]))
  }
})

test_that("PlotScatter2 matches unnamed mappings in order of first appearance", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  colors <- c("#336699", "#993333", "#339933", "black")
  shapes <- c(17, 18, 15, 16)
  fills <- c("#999933", "#993399", "#339999", "white")
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h", colors = colors,
                    shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_identical(points$colour, rep(colors[1:3], each = 3))
  expect_identical(points$shape, rep(shapes[1:3], each = 3))
  for (panel in c(2, 4)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, colors[1:3])
  }
  for (panel in c(3, 5)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, fills[1:3])
  }
})

test_that("PlotScatter2 labels shape fills from unnamed mappings", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h",
                    fill_colors_shape = c("gold", "green", "blue"))
  labels <- scatter_grob_labels(ggplot2::ggplotGrob(p[[6]]))
  expect_setequal(intersect(labels, c("Y", "X", "Z")), c("Y", "X", "Z"))
})

test_that("PlotScatter2 honors colour legend positions with and without shapes", {
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6),
                     h = rep(c("X", "Y"), each = 6))
  cases <- list(
    list(group2 = NULL, color = "right", shape = "none"),
    list(group2 = NULL, color = "bottom", shape = "none"),
    list(group2 = "h", color = "right", shape = c(0.15, 0.15)),
    list(group2 = "h", color = "left", shape = "none"),
    list(group2 = "h", color = "top", shape = "bottom"),
    list(group2 = "h", color = "none", shape = "right")
  )
  for (case in cases) {
    p <- PlotScatter2(data, "x", "y", "g", group2 = case$group2,
                      legend_color_pos = case$color, legend_shape_pos = case$shape)
    grob <- ggplot2::ggplotGrob(p[[1]])
    if (case$color != "none") {
      color_box <- grob$grobs[[which(grob$layout$name ==
                                      paste0("guide-box-", case$color))]]
      expect_setequal(intersect(scatter_grob_labels(color_box), c("g", "h")), "g")
    } else {
      expect_equal(sum(scatter_grob_labels(grob) == "g"), 0L)
    }
    if (!is.null(case$group2) && !identical(case$shape, "none")) {
      shape_position <- if (is.numeric(case$shape)) "inside" else case$shape
      shape_box <- grob$grobs[[which(grob$layout$name ==
                                      paste0("guide-box-", shape_position))]]
      expect_setequal(intersect(scatter_grob_labels(shape_box), c("g", "h")), "h")
    } else {
      expect_equal(sum(scatter_grob_labels(grob) == "h"), 0L)
    }
  }
})

test_that("PlotScatter2 retains both fill legends without gridExtra", {
  no_grid_env <- new.env(parent = environment(PlotScatter2))
  no_grid_env$requireNamespace <- function(package, ...) {
    if (identical(package, "gridExtra")) FALSE else base::requireNamespace(package, ...)
  }
  draw <- PlotScatter2
  environment(draw) <- no_grid_env
  legend <- .make_scatter2_legend
  environment(legend) <- no_grid_env
  no_grid_env$.make_scatter2_legend <- legend
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6),
                     h = rep(c("X", "Y"), each = 6))
  p <- draw(data, "x", "y", "g", group2 = "h")
  legend_grob <- ggplot2::ggplotGrob(p[[6]])
  expected <- c("g", "h", "a", "b", "X", "Y")
  expect_setequal(intersect(scatter_grob_labels(legend_grob), expected), expected)
  grid::grid.draw(legend_grob)
})

test_that("PlotScatter2 groups ellipses by colour independently of point shapes", {
  set.seed(42)
  data <- data.frame(x = rnorm(40), y = rnorm(40),
                     g = rep(c("a", "b"), each = 20), h = rep(c("X", "Y"), 20))
  single <- PlotScatter2(data, "x", "y", "g", show_ellipse = TRUE)
  dual <- PlotScatter2(data, "x", "y", "g", group2 = "h", show_ellipse = TRUE)
  single_ellipse <- ggplot2::ggplot_build(single[[1]])$data[[2]]
  dual_ellipse <- ggplot2::ggplot_build(dual[[1]])$data[[2]]
  expect_length(unique(dual_ellipse$group), 2L)
  expect_equal(dual_ellipse[c("x", "y", "colour")],
               single_ellipse[c("x", "y", "colour")])
})

test_that("PlotScatter2 aligns marginal numeric ranges with the main panel", {
  set.seed(42)
  data <- data.frame(x = rnorm(40), y = rnorm(40),
                     g = rep(c("a", "b"), each = 20), h = rep(c("X", "Y"), 20))
  cases <- list(
    list(),
    list(group2 = "h", show_ellipse = TRUE, x_top = FALSE),
    list(group2 = "h", annot_text = "Note", annot_pos = c(8, -8))
  )
  for (mtype in c("boxplot", "violin", "violin_box")) {
    for (case in cases) {
      p <- do.call(PlotScatter2, c(list(data, "x", "y", "g", marginal_type = mtype),
                                  case))
      main <- ggplot2::ggplot_build(p[[1]])$layout$panel_params[[1]]
      n_groups <- if (is.null(case$group2)) 1L else 2L
      for (i in seq_len(n_groups)) {
        right <- ggplot2::ggplot_build(p[[i + 1L]])$layout$panel_params[[1]]
        bottom <- ggplot2::ggplot_build(p[[i + n_groups + 1L]])$layout$panel_params[[1]]
        expect_equal(right$y.range, main$y.range)
        expect_equal(bottom$x.range, main$x.range)
      }
    }
  }
})

test_that("PlotScatter2 defers ellipse notices until the main plot is drawn", {
  data <- data.frame(x = 1:6, y = c(3, 1, 4, 1, 5, 9),
                     g = rep(c("a", "b"), each = 3))
  get_messages <- function(code) {
    messages <- character()
    withCallingHandlers(force(code), message = function(m) {
      messages <<- c(messages, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
    messages
  }
  expect_length(get_messages(
    p <- PlotScatter2(data, "x", "y", "g", show_ellipse = TRUE)
  ), 0L)
  draw_messages <- get_messages(ggplot2::ggplot_build(p[[1]]))
  expect_match(paste(draw_messages, collapse = " "), "Too few points")
})

test_that("PlotScatter2 builds fill legends independently of global legend visibility", {
  original_theme <- ggplot2::theme_get()
  withr::defer(ggplot2::theme_set(original_theme))
  ggplot2::theme_set(ggplot2::theme_void() + ggplot2::theme(legend.position = "none"))
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6),
                     h = rep(c("X", "Y"), each = 6))
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h")
  labels <- scatter_grob_labels(ggplot2::ggplotGrob(p[[6]]))
  expected <- c("g", "h", "a", "b", "X", "Y")
  expect_setequal(intersect(labels, expected), expected)
})

test_that("PlotScatter2 keeps automatic annotation coordinates finite", {
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6))
  cases <- list(
    list(data = data, want = c(1.22, 11.78)),
    list(data = transform(data, x = replace(x, 1, Inf)), want = c(2.2, 11.78)),
    list(data = transform(data, y = replace(y, 1, Inf)), want = c(1.22, 10.8)),
    list(data = transform(data, y = NA_real_), want = c(1.22, 0.98)),
    list(data = data[FALSE, ], want = c(0.02, 0.98)),
    list(data = transform(data, y = replace(y, 1, Inf)),
         pos = c(-2, 5), want = c(-2, 5))
  )
  for (case in cases) {
    p <- suppressWarnings(PlotScatter2(case$data, "x", "y", "g",
                                       annot_text = "Annotation", annot_pos = case$pos))
    text <- ggplot2::ggplot_build(p[[1]])$data[[2]]
    expect_equal(c(text$x, text$y), case$want)
    grob <- suppressWarnings(ggplot2::ggplotGrob(p[[1]]))
    expect_equal(sum(scatter_grob_labels(grob) == "Annotation"), 1L)
  }
})

test_that("PlotScatter2 preserves numeric axes that are also grouping columns", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6),
                     g = rep(c("b", "a"), 6), h = rep(c("Y", "X"), each = 6),
                     .scatter2_axis = -seq_len(12), .scatter2_axis.1 = seq_len(12))
  before <- serialize(data, NULL)
  cases <- list(
    list(x = "x", y = "y", group = "x"),
    list(x = "x", y = "y", group = "x", group2 = "h", x_top = FALSE,
         show_cor = TRUE, show_regression = TRUE),
    list(x = "x", y = "y", group = "y"),
    list(x = "x", y = "y", group = "g", group2 = "x"),
    list(x = "x", y = "y", group = "g", group2 = "y"),
    list(x = "x", y = "y", group = "x", group2 = "y"),
    list(x = "x", y = "x", group = "x"),
    list(x = c(axis = "x"), y = "y", group = "x", x_top = FALSE)
  )
  for (case in cases) {
    p <- do.call(PlotScatter2, c(list(data = data), case))
    built <- ggplot2::ggplot_build(p[[1]])
    expect_equal(built$data[[1]]$x, data[[case$x]])
    expect_equal(built$data[[1]]$y, data[[case$y]])
    expect_equal(unname(p[[1]]$labels$x), unname(case$x))
    expect_equal(unname(p[[1]]$labels$y), unname(case$y))
    expect_identical(serialize(data, NULL), before)
    if (isTRUE(case$show_cor)) {
      expect_match(built$data[[3]]$label, "r = 0.000", fixed = TRUE)
      expect_equal(built$data[[2]]$y, rep(150, nrow(built$data[[2]])))
    }
    grid::grid.draw(patchwork::patchworkGrob(p))
  }
})
