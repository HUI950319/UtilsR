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

scatter3_capture_inset <- function(...) {
  inset <- NULL
  plot <- testthat::with_mocked_bindings(
    PlotScatter3(..., theme_use = ggplot2::theme_classic),
    ggplotGrob = function(x, ...) {
      inset <<- x
      grid::nullGrob()
    }, .package = "ggplot2"
  )
  list(main = plot[[1]], inset = inset)
}

scatter3_integer_pairs <- function() {
  data.frame(
    Control = c(-2000000000L, -1999999998L, 2000000000L, 1999999998L,
                10L, 20L, 30L, 40L),
    Treat = c(2000000000L, 1999999995L, -1999999991L, -1999999990L,
              12L, 25L, 37L, 51L),
    group = rep(c("NS", "S"), 4)
  )
}

test_that("PlotScatter3 retains differences beyond the integer range", {
  data <- scatter3_integer_pairs()
  before <- serialize(data, NULL)
  differences <- as.double(data$Treat) - as.double(data$Control)
  expect_no_warning(p <- scatter3_capture_inset(
    data, test_method = "none", cor_method = "none"
  ))
  built <- ggplot2::ggplot_build(p$inset)
  expect_equal(sum(built$data[[1]]$count), nrow(data))
  expect_equal(built$data[[2]]$x, stats::median(differences))
  expect_equal(rlang::eval_tidy(p$inset$mapping$x, data = p$inset$data), differences)
  expect_identical(serialize(data, NULL), before)

  for (direction in c(-1L, 1L)) {
    data$Control <- direction * (-2000000000L + 0:7)
    data$Treat <- direction * (2000000000L - 0:7)
    expect_no_warning(p <- scatter3_capture_inset(
      data, test_method = "none", cor_method = "none"
    ))
    built <- ggplot2::ggplot_build(p$inset)
    expect_equal(sum(built$data[[1]]$count), nrow(data))
    expect_equal(built$data[[2]]$x,
                 stats::median(as.double(data$Treat) - as.double(data$Control)))
  }
})

test_that("PlotScatter3 paired tests agree with double precision reference tests", {
  data <- scatter3_integer_pairs()
  for (method in c("wilcox", "t.test")) {
    test_fn <- if (method == "wilcox") stats::wilcox.test else stats::t.test
    expected <- test_fn(as.double(data$Control), as.double(data$Treat),
                        paired = TRUE, alternative = "two.sided")
    expect_no_warning(p <- scatter3_capture_inset(
      data, test_method = method, cor_method = "none", show_refline = FALSE
    ))
    label <- ggplot2::ggplot_build(p$main)$data[[2]]$label
    expect_equal(label, paste0("p = ", format.pval(expected$p.value, digits = 2)))
  }
})

test_that("PlotScatter3 paired tests omit missing observations pairwise", {
  data <- data.frame(Control = c(1L, 2L, NA_integer_, 4L, 5L, 6L, 7L),
                     Treat = c(2L, 6L, 10L, NA_integer_, 10L, 12L, 20L),
                     group = rep(c("NS", "S"), length.out = 7))
  complete <- stats::complete.cases(data[c("Control", "Treat")])
  for (method in c("wilcox", "t.test")) {
    test_fn <- if (method == "wilcox") stats::wilcox.test else stats::t.test
    expected <- test_fn(data$Control[complete], data$Treat[complete], paired = TRUE)
    p <- scatter3_capture_inset(data, test_method = method, cor_method = "none",
                                show_refline = FALSE)
    label <- ggplot2::ggplot_build(p$main)$data[[2]]$label
    expect_equal(label, paste0("p = ", format.pval(expected$p.value, digits = 2)))
  }
})

test_that("PlotScatter3 draws every paired difference with coarse histogram bins", {
  data <- data.frame(
    Control = seq_len(8),
    Treat = seq_len(8) + c(-3, -2, -1, 0, 1, 2, 2.5, 4),
    group = rep(c("NS", "S"), 4)
  )
  for (bins in c(1L, 2L, 5L, 30L)) {
    p <- scatter3_capture_inset(data, test_method = "none", cor_method = "none",
                                hist_bins = bins)
    built <- ggplot2::ggplot_build(p$inset)
    histogram <- built$data[[1]]
    visible <- is.finite(histogram$xmin) & is.finite(histogram$xmax)
    expect_equal(sum(histogram$count[visible]), nrow(data))
    expect_equal(as.vector(tapply(histogram$count[visible], histogram$group[visible], sum)),
                 rep(4, 2))
    expect_equal(built$data[[2]]$x, 0.5)
    expect_equal(built$data[[3]]$label, 0.5)
    expect_no_warning(ggplot2::ggplotGrob(p$inset))
  }
})

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

test_that("PlotScatter2 supports a column named .data in each plotting role", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6),
                     g = rep(c("b", "a"), 6), h = rep(c("Y", "X"), each = 6),
                     .scatter2_data = -seq_len(12), .scatter2_data.1 = seq_len(12))
  for (role in c("x", "y", "group", "group2")) {
    columns <- c(x = "x", y = "y", group = "g", group2 = "h")
    renamed <- data
    names(renamed)[match(columns[[role]], names(renamed))] <- ".data"
    columns[[role]] <- ".data"
    before <- serialize(renamed, NULL)
    p <- do.call(PlotScatter2, c(list(data = renamed), as.list(columns),
      list(colors = c(b = "#112233", a = "#445566"),
           shapes = c(Y = 16, X = 17))))
    points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
    expect_equal(points$x, data$x)
    expect_equal(points$y, data$y)
    expect_identical(points$colour, rep(c("#112233", "#445566"), 6))
    expect_identical(points$shape, rep(c(16, 17), each = 6))
    expect_equal(p[[1]]$labels$x, columns[["x"]])
    expect_equal(p[[1]]$labels$y, columns[["y"]])
    labels <- scatter_grob_labels(ggplot2::ggplotGrob(p[[6]]))
    expected <- unname(columns[c("group", "group2")])
    expect_setequal(intersect(labels, expected), expected)
    expect_identical(serialize(renamed, NULL), before)
    grid::grid.draw(patchwork::patchworkGrob(p))
  }
  names(data)[1] <- ".data"
  p <- PlotScatter2(data, ".data", "y", ".data", group2 = "h")
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(points$x, data[[".data"]])
  expect_equal(points$y, data$y)
  grid::grid.draw(patchwork::patchworkGrob(p))
})

test_that("PlotScatter2 preserves integer64 group identifiers in a fresh process", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  source_file <- file.path(scratch, "scatter2.R")
  input_file <- file.path(scratch, "groups.rds")
  script_file <- file.path(scratch, "verify.R")
  dump(c("PlotScatter2", ".make_scatter2_legend"), file = source_file,
       envir = environment(PlotScatter2))
  data <- data.frame(x = 1:12, y = 12:1)
  data$g <- bit64::as.integer64(rep(c("9007199254740993", "9007199254740995"), 6))
  data$h <- bit64::as.integer64(rep(c("9007199254741001", "9007199254741003"), each = 6))
  saveRDS(data, input_file)
  writeLines(c(
    "options(device = function(...) grDevices::pdf(NULL, ...), lifecycle_verbosity = 'quiet')",
    sprintf("sys.source(%s, envir = globalenv())", deparse(source_file)),
    sprintf("data <- readRDS(%s)", deparse(input_file)),
    "stopifnot(!('bit64' %in% loadedNamespaces()))",
    "colors <- c('9007199254740993' = '#112233', '9007199254740995' = '#445566')",
    "shapes <- c('9007199254741001' = 16, '9007199254741003' = 17)",
    "fills <- c('9007199254741001' = '#3377AA', '9007199254741003' = '#AA7733')",
    "p <- PlotScatter2(data, 'x', 'y', 'g', group2 = 'h', colors = colors,",
    "                  shapes = shapes, fill_colors_shape = fills)",
    "stopifnot(identical(levels(p[[1]]$data$g), names(colors)),",
    "          identical(levels(p[[1]]$data$h), names(shapes)))",
    "grid::grid.draw(patchwork::patchworkGrob(p))",
    "cat('INTEGER64_GROUPS_OK\\n')"
  ), script_file)
  output <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script_file)), stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  expect_identical(status, 0L, info = paste(output, collapse = "\n"))
  expect_identical(tail(output, 1L), "INTEGER64_GROUPS_OK")
})

test_that("PlotScatter2 reports the missing integer64 grouping dependency", {
  skip_if_not_installed("bit64")
  no_bit64_env <- new.env(parent = environment(PlotScatter2))
  no_bit64_env$requireNamespace <- function(package, ...) {
    if (identical(package, "bit64")) FALSE else base::requireNamespace(package, ...)
  }
  draw <- PlotScatter2
  environment(draw) <- no_bit64_env
  data <- data.frame(x = 1:4, y = 4:1)
  data$g <- bit64::as.integer64(c("9007199254740993", "9007199254740995", NA, NA))
  message <- tryCatch({
    draw(data, "x", "y", "g")
    NULL
  }, error = conditionMessage)
  expect_identical(message, "Package 'bit64' is required for integer64 grouping columns.")
})
