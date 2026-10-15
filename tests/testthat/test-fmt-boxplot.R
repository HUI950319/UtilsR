test_that("default boxplots match native layers without changing the caller", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  q <- fmt_boxplot(p)
  native <- p + ggplot2::geom_boxplot(width = 0.3, alpha = 0.2,
                                     na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  expect_length(p$layers, 1L)
  expect_identical(p$data, d)
  expect_identical(names(p$mapping), c("x", "y"))
  expect_identical(names(formals(fmt_boxplot)),
                   c("plot", "boxplot.args", "inherit.aes"))
})

test_that("independent boxplots retain explicit data and complete mappings", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  external <- data.frame(a = rep(c("c", "d"), each = 4), b = 21:28)
  args <- list(data = external, mapping = ggplot2::aes(a, b, fill = a))
  q <- fmt_boxplot(p, boxplot.args = args, inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(data = external,
    mapping = ggplot2::aes(a, b, fill = a), inherit.aes = FALSE,
    width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(q$layers[[2L]]$data, external)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(22.5, 26.5))
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  expect_identical(args$data, external)
  expect_length(p$layers, 1L)
})

test_that("independent boxplots fill only missing position mappings", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = x)) +
    ggplot2::geom_point()
  shift <- 100
  q <- fmt_boxplot(p, list(mapping = ggplot2::aes(y = y + shift, group = x)),
                   inherit.aes = FALSE)
  expect_setequal(names(q$layers[[2L]]$mapping), c("x", "y", "group"))
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
})

test_that("explicit boxplot callbacks stay deferred until plot building", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  calls <- 0L
  callback <- function(data) {
    calls <<- calls + 1L
    transform(data, y = y + 100)
  }
  q <- fmt_boxplot(p, list(data = callback), inherit.aes = FALSE)
  expect_identical(calls, 0L)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
  expect_identical(calls, 1L)
  q <- fmt_boxplot(p, list(data = ~ transform(.x, y = y + 100)),
                   inherit.aes = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
})

test_that("independent boxplots resolve data and mappings from existing layers", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot() + ggplot2::geom_point(data = d, ggplot2::aes(x, y))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  expect_identical(q$layers[[2L]]$data, d)
  expect_length(p$layers, 1L)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, colour = x)) +
    ggplot2::geom_point(ggplot2::aes(y = y))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_setequal(names(q$layers[[2L]]$mapping), c("x", "y"))
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  expect_null(p$mapping$y)
})

test_that("independent layers never restore unrelated parent aesthetics", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, colour = x)) +
    ggplot2::geom_point(ggplot2::aes(y = y))
  external <- data.frame(a = rep(c("c", "d"), each = 4), b = 21:28)
  q <- fmt_boxplot(p, list(data = external, mapping = ggplot2::aes(a, b)),
                   inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(22.5, 26.5))
})

test_that("layer data callbacks remain deferred and keep mapping environments", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  calls <- 0L
  shift <- 100
  p <- ggplot2::ggplot(d, ggplot2::aes(x, colour = x)) +
    ggplot2::geom_point(ggplot2::aes(y = y + shift), data = function(data) {
      calls <<- calls + 1L
      data
    })
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(calls, 0L)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
  expect_identical(calls, 2L)
})

test_that("single-axis boxplots stay independent and missing sources fail clearly", {
  d <- data.frame(y = 1:12)
  p <- ggplot2::ggplot(d, ggplot2::aes(y = y)) + ggplot2::geom_blank()
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, 6.5)
  expect_error(fmt_boxplot(ggplot2::ggplot(), inherit.aes = FALSE),
               "Cannot resolve boxplot data and position mappings")
})

test_that("nested patchworks format every leaf and retain layout and annotations", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- ((p / p) | p) + patchwork::plot_annotation(title = "Three plots")
  q <- fmt_boxplot(pw)
  expect_length(q[[1L]][[1L]]$layers, 2L)
  expect_length(q[[1L]][[2L]]$layers, 2L)
  expect_length(q[[2L]]$layers, 2L)
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  expect_identical(q[[1L]]$patches$layout, pw[[1L]]$patches$layout)
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
  expect_length(pw[[1L]][[1L]]$layers, 1L)
  expect_length(p$layers, 1L)
})

test_that("patchwork placeholders and overlays retain their original layers", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (placeholder in list(patchwork::plot_spacer(), patchwork::guide_area(),
                           patchwork::wrap_elements(grid::textGrob("Note")))) {
    for (inherit in c(TRUE, FALSE)) {
      q <- fmt_boxplot(p | placeholder, inherit.aes = inherit)
      expect_length(q[[1L]]$layers, 2L)
      expect_length(q[[2L]]$layers, 0L)
      expect_identical(class(q[[2L]]), class(placeholder))
    }
  }
  pw <- p + patchwork::inset_element(p, left = 0.6, bottom = 0.6,
                                    right = 1, top = 1)
  q <- fmt_boxplot(pw)
  expect_length(q[[1L]]$layers, 2L)
  expect_identical(q[[2L]]$layers, pw[[2L]]$layers)
  expect_s3_class(patchwork::patchworkGrob(q), "gtable")
})

test_that("named plot lists retain their names and format all nested plot leaves", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(single = p, combined = p / p)
  q <- fmt_boxplot(plots)
  expect_identical(names(q), names(plots))
  expect_length(q$single$layers, 2L)
  expect_length(q$combined[[1L]]$layers, 2L)
  expect_length(q$combined[[2L]]$layers, 2L)
  expect_length(plots$combined[[1L]]$layers, 1L)
})

test_that("explicit outlier shapes render like native layers", {
  d <- data.frame(x = "a", y = c(1:9, 100))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_blank()
  point_shapes <- function(g) {
    shapes <- if (inherits(g, "points")) g$pch else NULL
    children <- if (inherits(g, "gtable")) g$grobs else g$children
    c(shapes, unlist(lapply(children, point_shapes), use.names = FALSE))
  }
  for (shape in list(16, 1, NA, NULL)) {
    q <- fmt_boxplot(p, list(outlier.shape = shape))
    native <- p + ggplot2::geom_boxplot(width = 0.3, alpha = 0.2,
      na.rm = TRUE, outlier.shape = shape)
    expect_identical(ggplot2::ggplot_build(q)$data,
                     ggplot2::ggplot_build(native)$data)
    expect_identical(point_shapes(ggplot2::ggplotGrob(q)),
                     point_shapes(ggplot2::ggplotGrob(native)))
  }
  expect_identical(is.na(point_shapes(ggplot2::ggplotGrob(fmt_boxplot(p)))), TRUE)
  q <- fmt_boxplot(fmt_boxplot(p, list(outlier.shape = 16)),
                   list(outlier.shape = 1))
  expect_equal(point_shapes(ggplot2::ggplotGrob(q)), c(16, 1))
})

test_that("boxplot argument lists have unique nonempty names", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  invalid <- list(1, "width", data.frame(width = 0.2), ggplot2::aes(x, y),
                  list(0.2), setNames(list(0.2), " "),
                  setNames(list(0.2), NA_character_), list(width = 0.2, width = 0.8))
  for (args in invalid) {
    expect_error(fmt_boxplot(p, args), "must be NULL or a named list")
  }
  expect_identical(ggplot2::ggplot_build(fmt_boxplot(p, NULL))$data,
                   ggplot2::ggplot_build(fmt_boxplot(p))$data)
})

test_that("boxplot inheritance flags and explicit mappings are checked at entry", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (inherit in list(NULL, NA, c(TRUE, FALSE), 0, 1, "TRUE", list(TRUE))) {
    expect_error(fmt_boxplot(p, inherit.aes = inherit), "single TRUE or FALSE")
  }
  for (inherit in c(TRUE, FALSE)) {
    expect_error(fmt_boxplot(p, list(mapping = list(x = quote(x), y = quote(y))),
                             inherit.aes = inherit), "boxplot.args\\$mapping")
  }
  q <- fmt_boxplot(p, list(inherit.aes = FALSE), inherit.aes = TRUE)
  expect_identical(q$layers[[2L]]$inherit.aes, TRUE)
})

test_that("non-plot gg components fail with a clear input error", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  for (invalid in list(ggplot2::theme_bw(), ggplot2::aes(x, y),
                       list(p, ggplot2::theme_bw()))) {
    expect_error(fmt_boxplot(invalid), "Input must be a ggplot")
  }
  expect_identical(fmt_boxplot(list()), list())
})

test_that("explicit NULL position mappings remain cleared in both orientations", {
  d <- data.frame(group = rep(c("a", "b"), each = 10), value = 1:20)
  cases <- list(
    list(plot = ggplot2::ggplot(d, ggplot2::aes(group, value)) +
           ggplot2::geom_point(), mapping = ggplot2::aes(x = NULL, y = value)),
    list(plot = ggplot2::ggplot(d, ggplot2::aes(value, group)) +
           ggplot2::geom_point(), mapping = ggplot2::aes(x = value, y = NULL)))
  for (case in cases) {
    native <- case$plot + ggplot2::geom_boxplot(mapping = case$mapping,
      inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
    expected <- ggplot2::ggplot_build(native)$data
    q <- fmt_boxplot(case$plot, list(mapping = case$mapping), inherit.aes = FALSE)
    expect_identical(q$layers[[2L]]$mapping, case$mapping)
    expect_identical(ggplot2::ggplot_build(q)$data, expected)
    expect_equal(nrow(ggplot2::ggplot_build(q)$data[[2L]]), 1L)
  }
})

test_that("cleared source-layer axes do not reappear in independent overlays", {
  d <- data.frame(group = rep(c("a", "b"), each = 10), value = 1:20)
  p <- ggplot2::ggplot(mapping = ggplot2::aes(group, value)) +
    ggplot2::geom_boxplot(data = d, mapping = ggplot2::aes(x = NULL))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_null(q$layers[[2L]]$mapping$x)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, 10.5)
  expect_identical(rlang::get_expr(p$mapping$x), quote(group))
})

test_that("annotation layers are not selected as automatic boxplot samples", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  annotations <- list(
    ggplot2::annotate("text", x = "a", y = 100, label = "Note"),
    ggplot2::annotate("label", x = "a", y = 100, label = "Note"),
    ggplot2::annotate("segment", x = "a", y = 100, xend = "b", yend = 100),
    ggplot2::annotate("curve", x = "a", y = 100, xend = "b", yend = 100))
  for (annotation in annotations) {
    p <- ggplot2::ggplot() + annotation +
      ggplot2::geom_point(data = d, ggplot2::aes(x, y))
    q <- fmt_boxplot(p, inherit.aes = FALSE)
    native <- p + ggplot2::geom_boxplot(data = d, ggplot2::aes(x, y),
      inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
    expect_identical(ggplot2::ggplot_build(q)$data,
                     ggplot2::ggplot_build(native)$data)
    expect_equal(ggplot2::ggplot_build(q)$data[[3L]]$middle, c(5.5, 15.5))
  }
})

test_that("annotations do not replace valid single-axis boxplot sources", {
  d <- data.frame(y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(y = y)) + ggplot2::geom_boxplot()
  for (annotation in list(
    ggplot2::annotate("text", x = 1, y = 100, label = "Note"),
    ggplot2::annotate("label", x = 1, y = 100, label = "Note"),
    ggplot2::annotate("segment", x = 1, y = 100, xend = 2, yend = 100),
    ggplot2::annotate("curve", x = 1, y = 100, xend = 2, yend = 100))) {
    q <- fmt_boxplot(p + annotation, inherit.aes = FALSE)
    expect_equal(ggplot2::ggplot_build(q)$data[[3L]]$middle, 10.5)
    expect_null(q$layers[[3L]]$mapping$x)
  }
})

test_that("explicit data and mappings work on annotation-only plots", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot() + ggplot2::annotate("text", x = "a", y = 100, label = "Note")
  q <- fmt_boxplot(p, list(data = d, mapping = ggplot2::aes(x, y)),
                   inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$data, d)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
})

test_that("unused incompatible parent data do not block valid sample layers", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  shift <- 100
  mappings <- list(ggplot2::aes(x, y),
                   ggplot2::aes(x, .data[["y"]] + .env$shift))
  for (mapping in mappings) {
    p <- ggplot2::ggplot(data.frame(x = "a"), mapping) +
      ggplot2::geom_point(data = d)
    q <- fmt_boxplot(p, inherit.aes = FALSE)
    native <- p + ggplot2::geom_boxplot(data = d, mapping = mapping,
      inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
    expect_equal(nrow(ggplot2::ggplot_build(p)$data[[1L]]), 20L)
    expect_identical(q$layers[[2L]]$data, d)
    expect_identical(ggplot2::ggplot_build(q)$data,
                     ggplot2::ggplot_build(native)$data)
  }
})

test_that("empty automatic data are skipped but explicit empty data are retained", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d[FALSE, ], ggplot2::aes(x, y)) +
    ggplot2::geom_blank() + ggplot2::geom_point(data = d)
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[3L]]$middle, c(5.5, 15.5))
  q <- fmt_boxplot(p, list(data = d[FALSE, ]), inherit.aes = FALSE)
  expect_identical(q$layers[[3L]]$data, d[FALSE, ])
  expect_equal(nrow(ggplot2::ggplot_build(q)$data[[3L]]), 0L)
})

test_that("source resolution follows the data and position mappings actually used", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  selected <- subset(d, y > 10)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point(data = selected)
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(q$layers[[2L]]$data, selected)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, 15.5)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    ggplot2::geom_point(ggplot2::aes(y = y + 100))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(105.5, 115.5))
  expect_identical(rlang::get_expr(p$mapping$y), quote(y))
})

test_that("automatic layer callbacks are selected without eager evaluation", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  calls <- 0L
  p <- ggplot2::ggplot(data.frame(x = "a"), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(data) {
      calls <<- calls + 1L
      d
    })
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(calls, 0L)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  expect_identical(calls, 2L)
})

test_that("identity boxplot statistics retain complete summary mappings", {
  d <- data.frame(group = rep(c("a", "b"), each = 10), value = 1:20)
  summaries <- data.frame(group = c("a", "b"), low = c(1, 11),
    q1 = c(3, 13), mid = c(5.5, 15.5), q3 = c(8, 18), high = c(10, 20))
  cases <- list(
    list(plot = ggplot2::ggplot(d, ggplot2::aes(group, value)) +
           ggplot2::geom_point(), orientation = "x",
         mapping = ggplot2::aes(x = group, ymin = low, lower = q1,
                               middle = mid, upper = q3, ymax = high)),
    list(plot = ggplot2::ggplot(d, ggplot2::aes(value, group)) +
           ggplot2::geom_point(), orientation = "y",
         mapping = ggplot2::aes(y = group, xmin = low, xlower = q1,
                               xmiddle = mid, xupper = q3, xmax = high)))
  for (case in cases) {
    for (stat in list("identity", ggplot2::StatIdentity)) {
      args <- list(data = summaries, mapping = case$mapping, stat = stat,
                   orientation = case$orientation)
      q <- fmt_boxplot(case$plot, args, inherit.aes = FALSE)
      native <- case$plot + do.call(ggplot2::geom_boxplot,
        c(args, list(inherit.aes = FALSE, width = 0.3, alpha = 0.2,
                     na.rm = TRUE, outlier.shape = NA)))
      expect_identical(q$layers[[2L]]$mapping, case$mapping)
      expect_identical(ggplot2::ggplot_build(q)$data,
                       ggplot2::ggplot_build(native)$data)
    }
  }
})

test_that("identity boxplot data callbacks remain deferred", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  summaries <- data.frame(x = c("a", "b"), low = c(1, 11),
    q1 = c(3, 13), mid = c(5.5, 15.5), q3 = c(8, 18), high = c(10, 20))
  mapping <- ggplot2::aes(x = x, ymin = low, lower = q1,
                          middle = mid, upper = q3, ymax = high)
  calls <- 0L
  q <- fmt_boxplot(p, list(stat = "identity", mapping = mapping,
    data = function(data) { calls <<- calls + 1L; summaries }), inherit.aes = FALSE)
  expect_identical(calls, 0L)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, summaries$mid)
  expect_identical(calls, 1L)
  q <- fmt_boxplot(p, list(stat = "identity", mapping = mapping,
                           data = ~ summaries), inherit.aes = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, summaries$mid)
})

test_that("unknown argument names do not partially match boxplot controls", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  cases <- list(
    list(args = list(dataset = transform(d, y = y + 100)), expected = list()),
    list(args = list(mapping_extra = ggplot2::aes(x, y + 100)), expected = list()),
    list(args = list(mapping_extra = 1), expected = list()),
    list(args = list(mapping = ggplot2::aes(y = y + 100), stat_extra = "identity"),
         expected = list(mapping = ggplot2::aes(y = y + 100))))
  for (case in cases) {
    reference <- fmt_boxplot(p, case$expected, inherit.aes = FALSE)
    expect_warning(q <- fmt_boxplot(p, case$args, inherit.aes = FALSE),
                   "Ignoring unknown parameters")
    expect_identical(q$layers[[2L]]$data, reference$layers[[2L]]$data)
    expect_identical(ggplot2::ggplot_build(q)$data,
                     ggplot2::ggplot_build(reference)$data)
  }
})

test_that("unknown data callbacks are never used as layer data", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  calls <- 0L
  expect_warning(q <- fmt_boxplot(p, list(dataset = function(data) {
    calls <<- calls + 1L
    transform(data, y = y + 100)
  }), inherit.aes = FALSE), "Ignoring unknown parameters")
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  expect_identical(calls, 0L)
})

test_that("native statistical and layer arguments remain available", {
  d <- data.frame(x = "a", y = c(1:9, 20))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  q <- fmt_boxplot(p, list(coef = 1, position = "identity", show.legend = FALSE),
                   inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(mapping = ggplot2::aes(x, y), data = d,
    coef = 1, position = "identity", show.legend = FALSE, inherit.aes = FALSE,
    width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
})

test_that("explicit data do not restore unused parent position mappings", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  samples <- data.frame(a = d$x, b = d$y + 100)
  for (external in list(transform(samples, x = a, y = b + 100), samples)) {
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
      ggplot2::geom_point(data = external, ggplot2::aes(a, b))
    for (mapping in list(NULL, ggplot2::aes(y = b + 10))) {
      q <- fmt_boxplot(p, list(data = external, mapping = mapping),
                       inherit.aes = FALSE)
      expected_mapping <- if (is.null(mapping)) ggplot2::aes(a, b) else {
        ggplot2::aes(x = a, y = b + 10)
      }
      native <- p + ggplot2::geom_boxplot(data = external,
        mapping = expected_mapping, inherit.aes = FALSE,
        width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
      expect_identical(q$layers[[2L]]$data, external)
      expect_identical(ggplot2::ggplot_build(q)$data,
                       ggplot2::ggplot_build(native)$data)
    }
    expect_length(p$layers, 1L)
  }
})

test_that("valid single-axis sources retain priority over later two-axis layers", {
  d <- data.frame(value = 1:20)
  cases <- list(
    list(mapping = ggplot2::aes(y = value), orientation = "x",
         later = ggplot2::aes(x = 5, y = value + 100)),
    list(mapping = ggplot2::aes(x = value), orientation = "y",
         later = ggplot2::aes(x = value + 100, y = 5)))
  for (case in cases) {
    for (parent in c(TRUE, FALSE)) {
      p <- if (parent) {
        ggplot2::ggplot(d, case$mapping) + ggplot2::geom_boxplot()
      } else {
        ggplot2::ggplot() + ggplot2::geom_boxplot(data = d, mapping = case$mapping)
      }
      p <- p + ggplot2::geom_point(data = d, mapping = case$later)
      q <- fmt_boxplot(p, list(orientation = case$orientation), inherit.aes = FALSE)
      native <- p + ggplot2::geom_boxplot(data = d, mapping = case$mapping,
        orientation = case$orientation, inherit.aes = FALSE,
        width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
      expect_setequal(names(q$layers[[3L]]$mapping), names(case$mapping))
      expect_identical(ggplot2::ggplot_build(q)$data,
                       ggplot2::ggplot_build(native)$data)
      expect_length(p$layers, 2L)
    }
  }
})

test_that("vector position mappings work without an explicit data frame", {
  values <- 1:20
  shift <- 100
  for (mapping in list(ggplot2::aes(x = "a", y = values + shift),
                       ggplot2::aes(x = values + shift, y = "a"))) {
    for (parent in c(TRUE, FALSE)) {
      p <- if (parent) {
        ggplot2::ggplot(mapping = mapping) + ggplot2::geom_point()
      } else {
        ggplot2::ggplot() + ggplot2::geom_point(mapping = mapping)
      }
      q <- fmt_boxplot(p, inherit.aes = FALSE)
      native <- p + ggplot2::geom_boxplot(mapping = mapping, inherit.aes = FALSE,
        width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
      expect_identical(ggplot2::ggplot_build(q)$data,
                       ggplot2::ggplot_build(native)$data)
      expect_identical(q$layers[[2L]]$inherit.aes, FALSE)
      expect_length(p$layers, 1L)
    }
  }
})

test_that("explicit vector mappings remain deferred on an empty plot", {
  values <- 1:20
  calls <- 0L
  mapping <- ggplot2::aes(y = { calls <<- calls + 1L; values })
  p <- ggplot2::ggplot()
  q <- fmt_boxplot(p, list(mapping = mapping), inherit.aes = FALSE)
  expect_identical(calls, 0L)
  native <- p + ggplot2::geom_boxplot(mapping = mapping, inherit.aes = FALSE,
    width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
})

test_that("range-only blank layers are tried after ordinary sample layers", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  cases <- list(
    list(plot = ggplot2::ggplot() +
           ggplot2::geom_blank(data = data.frame(x = "a", y = 100),
                               mapping = ggplot2::aes(x, y)) +
           ggplot2::geom_point(data = d, ggplot2::aes(x, y)),
         mapping = ggplot2::aes(x, y)),
    list(plot = ggplot2::ggplot(d, ggplot2::aes(x, y)) +
           ggplot2::geom_blank() + ggplot2::geom_point(ggplot2::aes(y = y + 100)),
         mapping = ggplot2::aes(x, y + 100)),
    list(plot = ggplot2::ggplot(d, ggplot2::aes(x, y)) +
           ggplot2::geom_point(ggplot2::aes(y = y + 100)) + ggplot2::geom_blank(),
         mapping = ggplot2::aes(x, y + 100)))
  for (case in cases) {
    q <- fmt_boxplot(case$plot, inherit.aes = FALSE)
    native <- case$plot + ggplot2::geom_boxplot(data = d, mapping = case$mapping,
      inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
    expect_identical(q$layers[[3L]]$data, d)
    expect_identical(ggplot2::ggplot_build(q)$data,
                     ggplot2::ggplot_build(native)$data)
    expect_length(case$plot$layers, 2L)
  }
})

test_that("blank-only sources and explicitly selected point samples still work", {
  d <- data.frame(x = rep(c("a", "b"), each = 10), y = 1:20)
  p <- ggplot2::ggplot() + ggplot2::geom_blank(data = d, ggplot2::aes(x, y))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$middle, c(5.5, 15.5))
  p <- ggplot2::ggplot() + ggplot2::annotate("point", x = "a", y = 100) +
    ggplot2::geom_point(data = d, ggplot2::aes(x, y))
  q <- fmt_boxplot(p, list(data = d, mapping = ggplot2::aes(x, y)),
                   inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(data = d, ggplot2::aes(x, y),
    inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
})

test_that("scalar fixed source coordinates align independent boxplots", {
  d <- data.frame(value = 1:20)
  cases <- list(
    list(mapping = ggplot2::aes(y = value), fixed = list(x = 2), orientation = "x",
         expected = ggplot2::aes(x = 2, y = value),
         scale = ggplot2::scale_x_continuous(limits = c(-0.5, 2.5))),
    list(mapping = ggplot2::aes(x = value), fixed = list(y = 2), orientation = "y",
         expected = ggplot2::aes(x = value, y = 2),
         scale = ggplot2::scale_y_continuous(limits = c(-0.5, 2.5))))
  for (case in cases) {
    for (parent in c(TRUE, FALSE)) {
      p <- if (parent) {
        ggplot2::ggplot(d, case$mapping) + do.call(ggplot2::geom_point, case$fixed)
      } else {
        ggplot2::ggplot() + do.call(ggplot2::geom_point,
          c(list(data = d, mapping = case$mapping), case$fixed))
      }
      p <- p + case$scale
      q <- fmt_boxplot(p, list(orientation = case$orientation), inherit.aes = FALSE)
      native <- p + ggplot2::geom_boxplot(data = d, mapping = case$expected,
        orientation = case$orientation, inherit.aes = FALSE,
        width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
      expect_identical(ggplot2::ggplot_build(q)$data,
                       ggplot2::ggplot_build(native)$data)
      expect_s3_class(ggplot2::ggplotGrob(q), "gtable")
      expect_length(p$layers, 1L)
    }
  }
})

test_that("explicit boxplot positions take precedence over source constants", {
  d <- data.frame(value = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(y = value)) + ggplot2::geom_point(x = 2)
  for (mapping in list(ggplot2::aes(x = 4), ggplot2::aes(x = NULL))) {
    q <- fmt_boxplot(p, list(mapping = mapping), inherit.aes = FALSE)
    expected <- mapping
    expected$y <- ggplot2::aes(y = value)$y
    native <- p + ggplot2::geom_boxplot(data = d, mapping = expected,
      inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
    expect_identical(ggplot2::ggplot_build(q)$data,
                     ggplot2::ggplot_build(native)$data)
    expect_identical(q$layers[[2L]]$mapping$x, mapping$x)
  }
  q <- fmt_boxplot(p, list(x = 4), inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(data = d, ggplot2::aes(y = value), x = 4,
    inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  expect_null(q$layers[[2L]]$mapping$x)
})

test_that("source constants keep data callbacks deferred", {
  d <- data.frame(value = 1:20)
  calls <- 0L
  p <- ggplot2::ggplot(d, ggplot2::aes(y = value)) +
    ggplot2::geom_point(x = 2, data = function(data) {
      calls <<- calls + 1L
      subset(data, value > 10)
    })
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  expect_identical(calls, 0L)
  built <- ggplot2::ggplot_build(q)$data[[2L]]
  expect_equal(built$middle, 15.5)
  expect_equal(built$x, 2)
  expect_equal(built$xmin, 1.85)
  expect_identical(calls, 2L)
})

test_that("scalar fixed positions override source mappings without copying vectors", {
  d <- data.frame(value = 1:20)
  p <- ggplot2::ggplot(d, ggplot2::aes(value, value)) + ggplot2::geom_point(x = 2)
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(data = d, ggplot2::aes(x = 2, y = value),
    inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
  p <- ggplot2::ggplot(d, ggplot2::aes(y = value)) +
    ggplot2::geom_point(x = rep(2:3, each = 10))
  q <- fmt_boxplot(p, inherit.aes = FALSE)
  native <- p + ggplot2::geom_boxplot(data = d, ggplot2::aes(y = value),
    inherit.aes = FALSE, width = 0.3, alpha = 0.2, na.rm = TRUE, outlier.shape = NA)
  expect_null(q$layers[[2L]]$mapping$x)
  expect_identical(ggplot2::ggplot_build(q)$data,
                   ggplot2::ggplot_build(native)$data)
})
