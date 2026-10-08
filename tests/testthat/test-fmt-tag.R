find_grobs <- function(g, cls) {
  kids <- if (inherits(g, "gtable")) g$grobs else if (inherits(g, "gTree")) g$children
  c(if (inherits(g, cls)) list(g),
    unlist(lapply(kids, find_grobs, cls = cls), recursive = FALSE))
}

test_that("inside tags draw one label with four-sided padding", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  original <- ggplot2::ggplot_build(p)
  res <- fmt_tag(p, labels = "A", fill = "red", alpha = 0.25)
  built <- ggplot2::ggplot_build(res)

  expect_equal(nrow(built$data[[2]]), 1L)
  expect_equal(built$data[[2]]$label, "A")
  expect_equal(built$data[[2]]$alpha, 0.25)
  expect_identical(built$data[[1]], original$data[[1]])
  expect_identical(built$layout$panel_params[[1]]$x.range,
                   original$layout$panel_params[[1]]$x.range)
  expect_identical(built$layout$panel_params[[1]]$y.range,
                   original$layout$panel_params[[1]]$y.range)
  tags <- Filter(function(g) identical(g$label, "A"),
                 find_grobs(ggplot2::ggplotGrob(res), "text"))
  expect_length(tags, 1L)
})

test_that("outside tags are drawn in a box honouring label.size / label.r", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  res <- fmt_tag(p, labels = "A", label_position = "tl-out",
                 label.size = 2, label.r = grid::unit(0.5, "lines"))

  expect_s3_class(res, "patchwork")
  boxes <- find_grobs(patchwork::patchworkGrob(res), "roundrect")
  expect_length(boxes, 1L)
  expect_equal(boxes[[1]]$gp$lwd, 2 * ggplot2::.pt)
  expect_equal(boxes[[1]]$r, grid::unit(0.5, "lines"))
  expect_null(res$labels$tag)
})

test_that("outside boxes are inset by half the border so it is not clipped", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  res <- fmt_tag(p, label_position = "tl-out", label.size = 2)

  trees <- Filter(
    function(g) any(vapply(g$children, inherits, logical(1), "roundrect")),
    find_grobs(patchwork::patchworkGrob(res), "gTree")
  )
  expect_length(trees, 1L)
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  vp <- trees[[1]]$vp
  expect_equal(grid::convertX(vp$x, "mm", valueOnly = TRUE), 1)
  expect_equal(
    grid::convertY(grid::unit(1, "npc") - vp$y, "mm", valueOnly = TRUE), 1
  )
})

test_that("outside tags keep the patchwork layout", {
  p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, qsec)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(p1, p2, ncol = 1)
  res <- fmt_tag(pw, label_position = "br_out")

  expect_s3_class(res, "patchwork")
  expect_length(find_grobs(patchwork::patchworkGrob(res), "roundrect"), 2L)
})

test_that("tags follow nested leaf plots and skip layout placeholders", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  nested <- ((p | p) / (p | p)) + patchwork::plot_annotation(title = "Overall")
  spaced <- patchwork::wrap_plots(p, patchwork::plot_spacer(),
                                  patchwork::guide_area(), p, ncol = 2)
  inset <- p + patchwork::inset_element(p, left = 0.6, bottom = 0.6,
                                        right = 1, top = 1)
  inputs <- list(nested = nested, spaced = spaced, inset = inset | p)
  for (pos in c("tl", "tl-out")) {
    for (nm in names(inputs)) {
      input <- inputs[[nm]]
      res <- fmt_tag(input, label_position = pos)
      tags <- unlist(lapply(find_grobs(patchwork::patchworkGrob(res), "text"),
                            function(g) g$label[g$label %in% LETTERS]))
      expect_equal(unname(tags), if (nm == "nested") LETTERS[1:4] else LETTERS[1:2])
      expect_identical(res$patches$layout, input$patches$layout)
      expect_identical(res$patches$annotation, input$patches$annotation)
    }
  }
  empty <- patchwork::wrap_plots(patchwork::plot_spacer(), patchwork::guide_area())
  expect_identical(fmt_tag(empty), empty)
  expect_identical(fmt_tag(list()), list())
  named <- list(first = p, empty = patchwork::plot_spacer(), last = p)
  res <- fmt_tag(named)
  expect_identical(names(res), names(named))
  expect_identical(res[[2]], named[[2]])
  expect_equal(res[[3]]$layers[[2]]$data$label, "B")
})

test_that("inside and outside tags accept one, two or four padding units", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  for (n in c(1L, 2L, 4L)) {
    for (pos in c("tl", "tl-out")) {
      res <- fmt_tag(p, label_position = pos,
                     label.padding = grid::unit(rep(0.3, n), "lines"))
      gt <- if (inherits(res, "patchwork")) patchwork::patchworkGrob(res)
            else ggplot2::ggplotGrob(res)
      tags <- Filter(function(g) identical(g$label, "A"), find_grobs(gt, "text"))
      expect_length(tags, 1L)
    }
  }
})

test_that("outside padding preserves each physical side and zero borders", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  res <- fmt_tag(p, label_position = "tl-out", label.size = 0,
                 label.padding = grid::unit(c(1, 2, 3, 10), "mm"))
  gt <- patchwork::patchworkGrob(res)
  trees <- Filter(function(g) any(vapply(g$children, inherits, logical(1), "roundrect")),
                   find_grobs(gt, "gTree"))
  tree <- trees[[1]]
  text <- find_grobs(tree, "text")[[1]]
  grid::pushViewport(tree$vp)
  width <- grid::convertWidth(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  height <- grid::convertHeight(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  tw <- grid::convertWidth(grid::grobWidth(text), "mm", valueOnly = TRUE)
  th <- grid::convertHeight(grid::grobHeight(text), "mm", valueOnly = TRUE)
  x <- grid::convertX(text$x, "mm", valueOnly = TRUE)
  y <- grid::convertY(text$y, "mm", valueOnly = TRUE)
  grid::popViewport()
  expect_equal(c(height - y - th / 2, width - x - tw / 2, y - th / 2, x - tw / 2),
               c(1, 2, 3, 10))
  expect_true(is.na(find_grobs(tree, "roundrect")[[1]]$gp$col))
})

test_that("repeated tags replace their own labels across placement modes", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point() +
    ggplot2::annotate("text", x = 20, y = 200, label = "USER")
  for (from in c("tl", "tl-out")) {
    for (to in c("br", "br-out")) {
      res <- fmt_tag(fmt_tag(p, labels = "A", label_position = from),
                     labels = "B", label_position = to)
      gt <- if (inherits(res, "patchwork")) patchwork::patchworkGrob(res)
            else ggplot2::ggplotGrob(res)
      texts <- unlist(lapply(find_grobs(gt, "text"), function(g) g$label))
      expect_equal(sum(texts == "A"), 0L)
      expect_equal(sum(texts == "B"), 1L)
      expect_equal(sum(texts == "USER"), 1L)
    }
  }
  res <- p
  for (i in 1:4) res <- fmt_tag(res, labels = "B", label_position = "tl-out")
  expect_length(find_grobs(patchwork::patchworkGrob(res), "roundrect"), 1L)
  expect_length(res, 2L)
})

test_that("tag replacement preserves annotations, styles and user insets", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  user <- ggplot2::ggplot() + ggplot2::annotate("text", x = 0, y = 0, label = "USER")
  input <- p + patchwork::inset_element(user, 0.6, 0.6, 1, 1)
  input <- (input | p) + patchwork::plot_annotation(title = "Overall")
  res <- fmt_tag(input, label_position = "tl-out") &
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "pink"))
  res <- fmt_tag(res, labels = c("C", "D"), label_position = "br-out")
  gt <- patchwork::patchworkGrob(res)
  texts <- unlist(lapply(find_grobs(gt, "text"), function(g) g$label))
  expect_equal(sum(texts == "USER"), 1L)
  expect_equal(sum(texts == "C"), 1L)
  expect_equal(sum(texts == "D"), 1L)
  expect_equal(sum(texts %in% c("A", "B")), 0L)
  expect_identical(res$patches$layout, input$patches$layout)
  expect_identical(res$patches$annotation$title, "Overall")
  fills <- vapply(find_grobs(gt, "rect"), function(g) {
    if (is.null(g$gp$fill)) "" else as.character(g$gp$fill)[1]
  }, character(1))
  expect_true("pink" %in% fills)
})

test_that("fmt_plot explicit tags take precedence over automatic tagging", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  for (pos in c("tl", "tl-out")) {
    expect_warning(res <- fmt_plot(p | p, fmt_tag_list = list(label_position = pos),
                                   tag_levels = "A"), "tag_levels")
    texts <- unlist(lapply(find_grobs(patchwork::patchworkGrob(res), "text"),
                            function(g) g$label))
    expect_equal(sum(texts == "A"), 1L)
    expect_equal(sum(texts == "B"), 1L)
  }
})

test_that("automatic tags continue beyond Z and custom labels still recycle", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  res <- fmt_tag(rep(list(p), 53L))
  tags <- vapply(res[c(1, 26, 27, 52, 53)], function(x) {
    x$layers[[2]]$data$label
  }, character(1))
  expect_equal(tags, c("A", "Z", "AA", "AZ", "BA"))
  expect_warning(custom <- fmt_tag(rep(list(p), 3L), labels = c("X", "Y")),
                   "recycled")
  expect_equal(vapply(custom, function(x) x$layers[[2]]$data$label, character(1)),
               c("X", "Y", "X"))
})

test_that("tag arguments fail early with the responsible argument", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  invalid <- list(
    labels = list(character(), "", "  ", NA_character_, 1),
    label_position = list(c(NA_real_, 0.5), c(Inf, 0.5), c(-0.1, 1), c(0, 1.1),
                            0.5, "unknown", character()),
    size = list(numeric(), 0, -1, Inf, NA_real_, "large"),
    color = list(character(), "not-a-colour", list("black")),
    fontface = list("unknown", NA_character_, 0),
    label.size = list(numeric(), -1, Inf, NA_real_, c(1, 2)),
    label.padding = list(1, grid::unit(rep(1, 3), "mm"), grid::unit(-1, "mm"),
                           grid::unit(NA_real_, "mm")),
    label.r = list(1, grid::unit(-1, "mm"), grid::unit(c(1, 2), "mm"),
                     grid::unit(Inf, "mm"))
  )
  for (nm in names(invalid)) {
    for (value in invalid[[nm]]) {
      args <- c(list(plot = p), setNames(list(value), nm))
      expect_error(do.call(fmt_tag, args), nm)
    }
  }
  res <- fmt_tag(list(p, p), size = c(12, 20), color = c("red", "blue"),
                 label_position = c(0, 1), label.size = 0,
                 label.padding = grid::unit(0, "mm"), label.r = grid::unit(0, "mm"))
  expect_equal(vapply(res, function(x) x$layers[[2]]$aes_params$size, numeric(1)),
               c(12, 20))
  expect_equal(vapply(res, function(x) x$layers[[2]]$aes_params$colour, character(1)),
               c("red", "blue"))
})

test_that("facet tags retain panel data and the documented label count", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(ggplot2::vars(cyl), scales = "free")
  before <- ggplot2::ggplot_build(p)
  inside <- fmt_tag(p)
  after <- ggplot2::ggplot_build(inside)
  expect_identical(after$data[[1]], before$data[[1]])
  expect_identical(after$layout$layout, before$layout$layout)
  expect_equal(nrow(after$data[[2]]), 3L)
  tags <- Filter(function(g) identical(g$label, "A"),
                 find_grobs(ggplot2::ggplotGrob(inside), "text"))
  expect_length(tags, 3L)
  outside <- fmt_tag(p, label_position = "tl-out")
  tags <- Filter(function(g) identical(g$label, "A"),
                 find_grobs(patchwork::patchworkGrob(outside), "text"))
  expect_length(tags, 1L)
})

test_that("tag construction preserves RNG and defers data evaluation", {
  calls <- 0L
  p <- ggplot2::ggplot() + ggplot2::geom_point(
    data = function(data) { calls <<- calls + 1L; mtcars },
    mapping = ggplot2::aes(mpg, disp))
  set.seed(514)
  rng <- .Random.seed
  original_layer <- p$layers[[1]]
  inside <- fmt_tag(p)
  outside <- fmt_tag(p, label_position = "tl-out")
  expect_identical(.Random.seed, rng)
  expect_length(p$layers, 1L)
  expect_identical(p$layers[[1]], original_layer)
  expect_equal(calls, 0L)
  invisible(ggplot2::ggplot_build(inside))
  expect_equal(calls, 1L)
  invisible(patchwork::patchworkGrob(outside))
  expect_equal(calls, 2L)
})

test_that("outside tags compose with reference, legend, axis and strip formatting", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp, colour = factor(cyl))) +
    ggplot2::geom_point()
  input <- (p | p) + patchwork::plot_annotation(title = "Keep")
  res <- fmt_plot(input, fmt_tag_list = list(label_position = "tl-out"),
                  fmt_ref_list = list(x = 20),
                  fmt_legend_list = list(legend.position = "none"))
  grob <- patchwork::patchworkGrob(res)
  refs <- Filter(function(g) identical(g$gp$lty, "dashed"), find_grobs(grob, "segments"))
  texts <- unlist(lapply(find_grobs(grob, "text"), function(g) as.character(g$label)))
  expect_length(refs, 2L)
  expect_equal(sum(texts == "factor(cyl)"), 0L)
  expect_equal(sum(texts == "Keep"), 1L)
  expect_identical(res$patches$layout, input$patches$layout)

  hidden <- fmt_axis(res, x.axis = c(1, 2), y.axis = c(1, 2))
  texts <- unlist(lapply(find_grobs(patchwork::patchworkGrob(hidden), "text"),
                         function(g) as.character(g$label)))
  expect_equal(sum(texts %in% c("mpg", "disp")), 0L)
  stripped <- fmt_strip(res, label = c("First", "Second"))
  texts <- unlist(lapply(find_grobs(patchwork::patchworkGrob(stripped), "text"),
                         function(g) as.character(g$label)))
  expect_equal(sum(texts == "First"), 1L)
  expect_equal(sum(texts == "Second"), 1L)
  expect_equal(sum(texts %in% c("A", "B")), 2L)

  nested <- fmt_tag((p | patchwork::plot_spacer()) / (p | p), label_position = "tl-out")
  nested <- fmt_ref(nested, y = 300)
  refs <- Filter(function(g) identical(g$gp$lty, "dashed"),
                  find_grobs(patchwork::patchworkGrob(nested), "segments"))
  expect_length(refs, 3L)
  expect_length(p$layers, 1L)
})

test_that("inside tags stay in panel NPC under coordinate transformations", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, disp)) + ggplot2::geom_point()
  plots <- list(p, p + ggplot2::coord_flip(), p + ggplot2::coord_polar(),
                p + ggplot2::scale_x_reverse(), p + ggplot2::scale_x_log10(),
                p + ggplot2::coord_flip() + ggplot2::facet_wrap(ggplot2::vars(cyl), scales = "free"))
  positions <- list(tl = c(0.02, 0.98), br = c(0.98, 0.02))
  for (q in plots) {
    before <- ggplot2::ggplot_build(q)
    for (pos in names(positions)) {
      res <- fmt_tag(q, label_position = pos)
      expect_identical(ggplot2::ggplot_build(res)$data[[1]], before$data[[1]])
      trees <- Filter(function(g) any(vapply(g$children, inherits, logical(1), "roundrect")),
                       find_grobs(ggplot2::ggplotGrob(res), "gTree"))
      expect_length(trees, nrow(before$layout$layout))
      for (g in trees) {
        expect_equal(as.numeric(g$vp$x), positions[[pos]][1])
        expect_equal(as.numeric(g$vp$y), positions[[pos]][2])
      }
    }
  }
})
