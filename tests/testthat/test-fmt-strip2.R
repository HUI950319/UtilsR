.fmt_strip_text <- function(plot, type = "text") {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  gt <- ggplot2::ggplotGrob(plot)
  text_nodes <- function(g) {
    if (inherits(g, type)) return(list(g))
    children <- if (inherits(g, "gtable")) g$grobs else as.list(g$children)
    unlist(lapply(children, text_nodes), recursive = FALSE)
  }
  strips <- gt$grobs[grepl("^strip", gt$layout$name)]
  unname(unlist(lapply(strips, text_nodes), recursive = FALSE))
}

test_that("fmt_strip centers strip text", {
  testthat::skip_if_not_installed("ggh4x")

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point()
  out <- fmt_strip(p, label = "Centered", label_fill = "grey90")
  strip_text <- out$facet$strip$given_elements$text_x[[1]]

  expect_equal(strip_text@hjust, 0.5)
  expect_equal(strip_text@vjust, 0.5)
  expect_equal(as.numeric(strip_text@margin)[c(1, 3)], c(3, 3))

  p_facet <- p + ggplot2::facet_wrap(ggplot2::vars(cyl))
  out_facet <- fmt_strip(p_facet, label = "Centered")

  expect_equal(out_facet$theme$strip.text@hjust, 0.5)
  expect_equal(out_facet$theme$strip.text@vjust, 0.5)
  expect_equal(
    as.numeric(out_facet$theme$strip.text@margin)[c(1, 3)],
    c(3, 3)
  )
})

test_that("fmt_strip maps label vectors within a single faceted plot", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  wrapped <- p + ggplot2::facet_wrap(ggplot2::vars(cyl))
  expect_identical(labels(fmt_strip(wrapped, c("Four", "Six", "Eight"))),
                   c("Four", "Six", "Eight"))
  expect_identical(labels(fmt_strip(wrapped, c("A", "B"))), c("A", "B", "A"))
  expect_identical(labels(fmt_strip(wrapped, "All")), rep("All", 3))
  expect_identical(labels(fmt_strip(wrapped)), rep("Figure1", 3))

  plots <- list(left = p, right = p, last = p)
  out <- fmt_strip(plots, c("A", "B"))
  expect_identical(names(out), names(plots))
  expect_identical(unname(vapply(out, labels, character(1))), c("A", "B", "A"))
})

test_that("fmt_strip handles facet expressions and repeated relabelling", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  facets <- list(
    ggplot2::facet_wrap(ggplot2::vars(factor(cyl))),
    ggplot2::facet_wrap(ggplot2::vars(Cylinders = factor(cyl))),
    ggplot2::facet_grid(cols = ggplot2::vars(.data[["cyl"]]))
  )
  for (facet in facets) {
    out <- fmt_strip(p + facet, c("A", "B", "C"))
    expect_identical(labels(out), c("A", "B", "C"))
    out <- fmt_strip(out, c("D", "E", "F"))
    expect_identical(labels(out), c("D", "E", "F"))
  }

  layered <- ggplot2::ggplot() +
    ggplot2::geom_point(data = function(data) mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::facet_wrap(ggplot2::vars(cyl))
  expect_identical(labels(fmt_strip(layered, c("A", "B", "C"))), c("A", "B", "C"))

  gridded <- p + ggplot2::facet_grid(am ~ cyl, labeller = ggplot2::label_both)
  out <- fmt_strip(gridded, c("A", "B", "C"))
  expect_setequal(labels(out), c("A", "B", "C", "am: 0", "am: 1"))
  expect_identical(gridded$facet$params$labeller, ggplot2::label_both)
})

test_that("fmt_strip preserves custom labellers and single-line formatting", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  margins <- p + ggplot2::facet_grid(am ~ cyl,
    labeller = ggplot2::labeller(.rows = ggplot2::label_both,
                               .cols = ggplot2::label_value))
  expect_identical(labels(fmt_strip(margins, c("A", "B", "C"))),
                   c("A", "B", "C", "am: 0", "am: 1"))
  mapped <- p + ggplot2::facet_grid(am ~ cyl,
    labeller = ggplot2::labeller(am = c(`0` = "Auto", `1` = "Manual")))
  expect_identical(labels(fmt_strip(mapped, c("A", "B", "C"))),
                   c("A", "B", "C", "Auto", "Manual"))

  d <- expand.grid(a = c("a", "b"), b = c("x", "y"))
  d$x <- seq_len(nrow(d))
  single <- ggplot2::ggplot(d, ggplot2::aes(x, x)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(ggplot2::vars(a, b), nrow = 1,
      labeller = ggplot2::labeller(.default = ggplot2::label_both, .multi_line = FALSE))
  changed <- fmt_strip(single, c("A", "B"))
  expect_identical(labels(changed), c("A, b: x", "A, b: y", "B, b: x", "B, b: y"))
  expect_identical(labels(fmt_strip(changed, c("C", "D"))),
                   c("C, b: x", "C, b: y", "D, b: x", "D, b: y"))
  expect_identical(labels(single), c("a: a, b: x", "a: a, b: y", "a: b, b: x", "a: b, b: y"))

  parsed <- single + ggplot2::facet_wrap(ggplot2::vars(a, b), nrow = 1,
                                        labeller = ggplot2::label_parsed)
  before <- .fmt_strip_text(parsed)
  after <- .fmt_strip_text(fmt_strip(parsed, c("A", "B")))
  expect_identical(lapply(after[c(2, 4, 6, 8)], `[[`, "label"),
                   lapply(before[c(2, 4, 6, 8)], `[[`, "label"))
  combined_labeller <- structure(function(labels) {
    ggplot2::label_parsed(labels, multi_line = FALSE)
  }, class = "labeller")
  combined <- single + ggplot2::facet_wrap(ggplot2::vars(a, b), nrow = 1,
                                          labeller = combined_labeller)
  texts <- .fmt_strip_text(fmt_strip(combined, c("A", "B")))
  expect_length(texts, 4L)
  expect_true(all(vapply(texts, function(x) is.language(x$label), logical(1))))
  expect_equal(ggplot2::ggplot_build(changed)$data, ggplot2::ggplot_build(single)$data)
})

test_that("fmt_strip adds labels without changing plot or layer data", {
  d <- data.frame(x = 1:3, y = 3:1, .strip_label. = c("red", "green", "blue"))
  plots <- list(
    ggplot2::ggplot(d, ggplot2::aes(x, y, colour = .strip_label.)) +
      ggplot2::geom_point(),
    ggplot2::ggplot() + ggplot2::geom_point(data = d, ggplot2::aes(x, y)),
    ggplot2::ggplot(d[FALSE, ], ggplot2::aes(x, y)) + ggplot2::geom_point(),
    ggplot2::ggplot() + ggplot2::annotate("text", x = 1, y = 1, label = "Note")
  )
  for (p in plots) {
    out <- fmt_strip(p, "Heading")
    expect_identical(out$data, p$data)
    expect_identical(lapply(out$layers, function(x) x$data),
                     lapply(p$layers, function(x) x$data))
    expect_equal(ggplot2::ggplot_build(out)$data, ggplot2::ggplot_build(p)$data)
    expect_identical(vapply(.fmt_strip_text(out), `[[`, character(1), "label"),
                     "Heading")
    expect_identical(vapply(.fmt_strip_text(fmt_strip(out, "Again")),
                            `[[`, character(1), "label"), "Again")
  }
})

test_that("fmt_strip labels nested patchworks without counting placeholders", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  nested <- ((p | p) / p) + patchwork::plot_annotation(title = "Overall")
  out <- fmt_strip(nested, c("A", "B", "C"))
  expect_identical(c(labels(out[[1]][[1]]), labels(out[[1]][[2]]), labels(out[[2]])),
                   c("A", "B", "C"))
  expect_equal(out$patches$layout, nested$patches$layout)
  expect_equal(out$patches$annotation, nested$patches$annotation)
  expect_equal(out[[1]]$patches$layout, nested[[1]]$patches$layout)
  expect_length(.fmt_strip_text(nested[[1]][[1]]), 0L)
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")

  spaced <- patchwork::wrap_plots(p, patchwork::plot_spacer(),
                                  patchwork::guide_area(), p, ncol = 2)
  out <- fmt_strip(spaced, c("A", "B"))
  expect_identical(c(labels(out[[1]]), labels(out[[4]])), c("A", "B"))
  expect_identical(out[[2]], spaced[[2]])
  expect_identical(out[[3]], spaced[[3]])
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")

  out <- fmt_strip(list(group = nested, last = p))
  expect_identical(names(out), c("group", "last"))
  expect_identical(c(labels(out$group[[1]][[1]]), labels(out$group[[1]][[2]]),
                     labels(out$group[[2]]), labels(out$last)), paste0("Figure", 1:4))
})

test_that("fmt_strip restores hidden strips and respects explicit style controls", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point() +
    ggplot2::theme(strip.text = ggplot2::element_text(colour = "red", face = "italic"))
  colour <- function(p) vapply(.fmt_strip_text(p), function(x) x$gp$col, character(1))
  wrapped <- p + ggplot2::facet_wrap(ggplot2::vars(cyl))
  expect_identical(colour(fmt_strip(p, "X", label_color = NULL)), "red")
  expect_identical(colour(fmt_strip(wrapped, "X", label_color = NULL)), rep("red", 3))

  specific <- wrapped + ggplot2::theme(
    strip.text.x.top = ggplot2::element_text(colour = "red", size = 17, angle = 15)
  )
  texts <- .fmt_strip_text(fmt_strip(specific, "X", label_color = "blue"))
  expect_identical(vapply(texts, function(x) x$gp$col, character(1)), rep("blue", 3))
  expect_equal(vapply(texts, function(x) x$gp$fontsize, numeric(1)), rep(17, 3))
  expect_equal(vapply(texts, function(x) x$rot, numeric(1)), rep(15, 3))

  themed <- p + ggh4x::facet_wrap2(
    ggplot2::vars(cyl),
    strip = ggh4x::strip_themed(
      text_x = ggh4x::elem_list_text(colour = "purple", size = 17),
      background_x = ggh4x::elem_list_rect(fill = "pink")
    )
  )
  expect_identical(colour(fmt_strip(themed, "X", label_color = "blue")), rep("blue", 3))
  filled <- fmt_strip(themed, "X", label_fill = "cyan")
  expect_identical(vapply(.fmt_strip_text(filled, "rect"), function(x) x$gp$fill,
                          character(1)), rep("cyan", 3))
  for (faceted in list(specific, themed)) {
    hidden <- fmt_strip(faceted, strip = FALSE)
    expect_length(.fmt_strip_text(hidden), 0L)
    expect_true(identical(fmt_strip(hidden, strip = FALSE), hidden))
    shown <- fmt_strip(hidden + ggplot2::labs(title = "Keep"), "Back", label_color = NULL)
    expect_identical(colour(shown), colour(faceted))
    expect_identical(vapply(.fmt_strip_text(shown), `[[`, character(1), "label"), rep("Back", 3))
    expect_identical(shown$labels$title, "Keep")
    expect_equal(ggplot2::ggplot_build(shown)$layout$layout,
                 ggplot2::ggplot_build(faceted)$layout$layout)
    expect_length(.fmt_strip_text(faceted), 3L)
  }
})

test_that("fmt_strip hides strips without executing data functions or statistics", {
  calls <- 0L
  data_calls <- 0L
  stat <- ggplot2::ggproto("StatStripTest", ggplot2::Stat,
    required_aes = c("x", "y"),
    compute_group = function(data, scales) {
      calls <<- calls + 1L
      data$y <- data$y + stats::runif(1)
      data
    }
  )
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::layer(stat = stat, geom = "point", position = "identity",
                   data = function(data) { data_calls <<- data_calls + 1L; data }) +
    ggplot2::facet_wrap(ggplot2::vars(cyl))
  set.seed(19)
  seed <- .Random.seed
  out <- fmt_strip(p, strip = FALSE)
  expect_identical(calls, 0L)
  expect_identical(data_calls, 0L)
  expect_identical(.Random.seed, seed)
  invisible(ggplot2::ggplotGrob(out))
  expect_identical(calls, 3L)
  expect_identical(data_calls, 1L)

  native <- ggplot2::ggplot(subset(mtcars, cyl == 4), ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() + ggplot2::facet_wrap(ggplot2::vars(cyl))
  hidden <- fmt_strip(native, strip = FALSE)
  expect_s3_class(hidden$facet, "FacetWrap")
  expect_length(.fmt_strip_text(hidden), 0L)
  hidden$data <- mtcars
  expect_equal(nrow(ggplot2::ggplot_build(hidden)$layout$layout), 3L)
  expect_length(.fmt_strip_text(hidden), 0L)
})

test_that("fmt_strip validates labels and colours before rendering", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  for (bad in list(character(), NA_character_, 1, list("A"))) {
    expect_error(fmt_strip(p, label = bad), "label")
  }
  for (arg in c("label_color", "label_fill")) {
    for (bad in list(character(), list("red"), "not-a-colour", Inf)) {
      expect_error(do.call(fmt_strip, c(list(plot = p), stats::setNames(list(bad), arg))), arg)
    }
  }
  expect_true(identical(fmt_strip(p, strip = FALSE, label = character(),
                                 label_fill = "not-a-colour"), p))
  expect_identical(fmt_strip(list()), list())
  expect_s3_class(ggplot2::ggplotGrob(fmt_strip(p, "", label_color = 1)), "gtable")
  transparent <- fmt_strip(p, "A", label_fill = NA)
  expect_true(all(vapply(.fmt_strip_text(transparent, "rect"),
                         function(x) grDevices::col2rgb(x$gp$fill, alpha = TRUE)[4, ] == 0,
                         logical(1))))
  inherited <- fmt_strip(p + ggplot2::theme(strip.background = ggplot2::element_rect(fill = "pink")))
  expect_identical(vapply(.fmt_strip_text(inherited, "rect"), function(x) x$gp$fill,
                          character(1)), "pink")
})

test_that("fmt_strip preserves facet structure and computed statistics", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(1, mpg)) +
    ggplot2::stat_summary(fun = mean, geom = "point")
  facets <- list(
    ggplot2::facet_grid(am ~ cyl, scales = "free", space = "free",
                        switch = "both", margins = TRUE, shrink = FALSE),
    ggplot2::facet_wrap(ggplot2::vars(am, cyl), scales = "free_y",
                        strip.position = "bottom", dir = "v", shrink = FALSE),
    ggh4x::facet_nested(~ am + cyl)
  )
  inputs <- lapply(facets, function(facet) p + facet)
  outputs <- fmt_strip(inputs, label = "Changed")
  for (i in seq_along(inputs)) {
    before <- ggplot2::ggplot_build(inputs[[i]])
    after <- ggplot2::ggplot_build(outputs[[i]])
    expect_equal(after$layout$layout, before$layout$layout)
    expect_equal(after$data, before$data)
    expect_identical(class(outputs[[i]]$facet), class(inputs[[i]]$facet))
    params <- setdiff(names(inputs[[i]]$facet$params), "labeller")
    expect_equal(outputs[[i]]$facet$params[params], inputs[[i]]$facet$params[params])
    expect_identical(outputs[[i]]$facet$shrink, inputs[[i]]$facet$shrink)
    expect_s3_class(ggplot2::ggplotGrob(outputs[[i]]), "gtable")
  }

  d <- transform(mtcars, cyl = factor(cyl, levels = c(4, 6, 8, 10)))
  original <- ggplot2::ggplot(d, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() + ggplot2::facet_wrap(ggplot2::vars(cyl), drop = FALSE)
  changed <- fmt_strip(original, "Changed")
  expect_equal(ggplot2::ggplot_build(changed)$layout$layout,
               ggplot2::ggplot_build(original)$layout$layout)
  expect_identical(original$facet$params$labeller, ggplot2::label_value)
})

test_that("fmt_strip(strip = FALSE) removes every strip", {
  testthat::skip_if_not_installed("ggh4x")

  drawn_strips <- function(plot) {
    grDevices::pdf(NULL)
    on.exit(grDevices::dev.off(), add = TRUE)
    g <- ggplot2::ggplotGrob(plot)
    strips <- g$grobs[grepl("^strip", g$layout$name)]
    sum(!vapply(strips, inherits, logical(1), "zeroGrob"))
  }
  n_panels <- function(plot) nrow(ggplot2::ggplot_build(plot)$layout$layout)

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point()
  expect_identical(fmt_strip(p, strip = FALSE), p)

  # A single-panel strip goes with its facet, so a later theme cannot revive it
  labelled <- fmt_strip(p, label = "A", label_fill = "grey90")
  out <- fmt_strip(labelled, strip = FALSE)
  expect_s3_class(out$facet, "FacetNull")
  expect_equal(drawn_strips(out + ggplot2::theme_bw()), 0)

  # Multi-panel facets keep their panels, both for ggh4x strips that carry
  # their own fills and for strip text set on a leaf theme element
  nested <- p + ggh4x::facet_nested(
    ~ cyl + am,
    strip = ggh4x::strip_nested(
      background_x = ggh4x::elem_list_rect(fill = c("pink", "cyan"))
    )
  )
  gridded <- p + ggplot2::facet_grid(ggplot2::vars(am), ggplot2::vars(cyl)) +
    ggplot2::theme(strip.text.x = ggplot2::element_text(face = "bold"))
  wrapped <- p + ggplot2::facet_wrap(ggplot2::vars(cyl))
  for (faceted in list(nested, gridded, wrapped)) {
    out <- fmt_strip(faceted, strip = FALSE)
    expect_equal(n_panels(out), n_panels(faceted))
    expect_no_warning(n_drawn <- drawn_strips(out))
    expect_equal(n_drawn, 0)
  }
  expect_gt(drawn_strips(nested), 0)

  # Nested patchworks are cleared all the way down
  out <- fmt_strip((labelled | nested) / gridded, strip = FALSE)
  expect_equal(
    c(drawn_strips(out[[1]][[1]]), drawn_strips(out[[1]][[2]]),
      drawn_strips(out[[2]])),
    c(0, 0, 0)
  )

  expect_error(fmt_strip(p, strip = NA), "strip")
})

test_that("theme_my centers facet strips with symmetric margins", {
  theme <- theme_my(base_size = 12)
  strip_x <- ggplot2::calc_element("strip.text.x.top", theme)
  strip_y <- ggplot2::calc_element("strip.text.y.right", theme)

  expect_equal(strip_x$hjust, 0.5)
  expect_equal(strip_x$vjust, 0.5)
  expect_equal(as.numeric(strip_x$margin)[c(1, 3)], c(4, 4))

  expect_equal(strip_y$hjust, 0.5)
  expect_equal(strip_y$vjust, 0.5)
  expect_equal(as.numeric(strip_y$margin)[c(2, 4)], c(4, 4))
})


test_that("fmt_strip2 protects native facet panels and statistics", {
  d <- data.frame(x = 1, y = c(0, 2, 100, 102), g = rep(c("A", "B"), each = 2))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    ggplot2::stat_summary(fun = mean, geom = "point") +
    ggplot2::facet_wrap(ggplot2::vars(g))
  before <- ggplot2::ggplot_build(p)
  hidden <- fmt_strip2(p)
  after <- ggplot2::ggplot_build(hidden)
  expect_equal(after$layout$layout, before$layout$layout)
  expect_equal(after$data, before$data)
  expect_length(.fmt_strip_text(hidden), 0L)
  expect_error(ggplot2::ggplot_build(fmt_strip2(p, "Top", "Right", ncol = 1)),
               "multiple panels")

  calls <- 0L
  stat <- ggplot2::ggproto("StatStrip2Test", ggplot2::Stat,
    required_aes = c("x", "y"),
    compute_group = function(data, scales) { calls <<- calls + 1L; data }
  )
  p$layers <- list(ggplot2::layer(stat = stat, geom = "point", position = "identity"))
  out <- fmt_strip2(p, "Top", ncol = 1)
  expect_identical(calls, 0L)
  expect_error(ggplot2::ggplot_build(out), "multiple panels")
  expect_identical(calls, 0L)

  single <- p
  single$data <- d[d$g == "A", ]
  expect_s3_class(ggplot2::ggplotGrob(fmt_strip2(single, "Top", ncol = 1)), "gtable")
  repeated <- fmt_strip2(fmt_strip2(single, "First", ncol = 1), "Again", ncol = 1)
  repeated$data <- d
  expect_error(ggplot2::ggplot_build(repeated), "multiple panels")
  labelled <- fmt_strip(single + ggplot2::facet_null(), "Old")
  expect_identical(vapply(.fmt_strip_text(fmt_strip2(labelled, "New", ncol = 1)),
                          `[[`, character(1), "label"), "New")
})

test_that("fmt_strip2 preserves shrink and single-panel scale ranges", {
  d <- data.frame(x = 1, y = c(0, 100), g = "One")
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
    ggplot2::stat_summary(fun = mean, geom = "point")
  facets <- list(
    ggplot2::facet_wrap(ggplot2::vars(g), shrink = FALSE),
    ggplot2::facet_grid(cols = ggplot2::vars(g), shrink = FALSE),
    ggh4x::facet_wrap2(ggplot2::vars(g), shrink = FALSE)
  )
  for (facet in facets) {
    native <- p + facet
    before <- ggplot2::ggplot_build(native)
    for (args in list(list(top_label = "Top"), list(right_label = "Right"),
                      list(top_label = "Top", right_label = "Right"))) {
      out <- do.call(fmt_strip2, c(list(plot = native), args))
      after <- ggplot2::ggplot_build(out)
      expect_identical(out$facet$shrink, FALSE)
      expect_equal(after$layout$panel_params[[1]]$y.range,
                   before$layout$panel_params[[1]]$y.range)
      expect_equal(after$data, before$data)
      expect_identical(fmt_strip2(out, "Again")$facet$shrink, FALSE)
    }
  }
})

test_that("fmt_strip2 adds headers without changing plot or layer data", {
  d <- data.frame(x = 1:3, y = 3:1, .top. = 11:13, .right. = c("A", "B", "C"))
  plots <- list(
    ggplot2::ggplot(d, ggplot2::aes(x, .top., colour = .right.)) + ggplot2::geom_point(),
    ggplot2::ggplot() + ggplot2::geom_point(data = d, ggplot2::aes(x, y)),
    ggplot2::ggplot(d[FALSE, ], ggplot2::aes(x, y)) + ggplot2::geom_point(),
    ggplot2::ggplot(d[FALSE, ], ggplot2::aes(x, y)) + ggplot2::geom_point(data = d),
    ggplot2::ggplot() + ggplot2::annotate("text", x = 1, y = 1, label = "Note"),
    ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point(data = d)
  )
  for (p in plots) {
    out <- fmt_strip2(p, "Top", "Right", ncol = 1)
    expect_identical(out$data, p$data)
    expect_identical(lapply(out$layers, function(x) x$data),
                     lapply(p$layers, function(x) x$data))
    expect_equal(ggplot2::ggplot_build(out)$data, ggplot2::ggplot_build(p)$data)
    expect_identical(vapply(.fmt_strip_text(out), `[[`, character(1), "label"),
                     c("Top", "Right"))
  }
  calls <- 0L
  p <- ggplot2::ggplot() + ggplot2::geom_point(
    data = function(data) { calls <<- calls + 1L; d }, ggplot2::aes(x, y)
  )
  out <- fmt_strip2(p, "Top", "Right", ncol = 1)
  expect_identical(calls, 0L)
  expect_identical(vapply(.fmt_strip_text(out), `[[`, character(1), "label"),
                   c("Top", "Right"))
  expect_identical(calls, 1L)
})

test_that("fmt_strip2 follows actual grid dimensions and filling order", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  three <- patchwork::wrap_plots(rep(list(p), 3))
  out <- fmt_strip2(three, c("T1", "T2", "T3"), "R1")
  expect_identical(lapply(seq_along(out), function(i) labels(out[[i]])),
                   list("T1", "T2", c("T3", "R1")))
  expect_equal(out$patches$layout, three$patches$layout)
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")

  by_col <- patchwork::wrap_plots(rep(list(p), 4), ncol = 2, byrow = FALSE)
  out <- fmt_strip2(by_col, c("T1", "T2"), c("R1", "R2"))
  expect_identical(lapply(seq_along(out), function(i) labels(out[[i]])),
                   list("T1", character(), c("T2", "R1"), "R2"))
  expect_equal(out$patches$layout, by_col$patches$layout)

  sized <- three + patchwork::plot_layout(widths = c(1, 2))
  out <- fmt_strip2(sized, c("T1", "T2"), c("R1", "R2"))
  expect_identical(lapply(seq_along(out), function(i) labels(out[[i]])),
                   list("T1", c("T2", "R1"), "R2"))

  incomplete <- patchwork::wrap_plots(rep(list(p), 5), ncol = 2)
  out <- fmt_strip2(incomplete, c("T1", "T2"), c("R1", "R2", "R3"))
  expect_identical(labels(out[[5]]), "R3")
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")
  one_col <- patchwork::wrap_plots(rep(list(p), 4), ncol = 1)
  expect_error(fmt_strip2(one_col, "Top", "Right", ncol = 2), "existing layout")
  designed <- patchwork::wrap_plots(rep(list(p), 4), design = "AB\nCD")
  expect_error(fmt_strip2(designed, "Top", "Right"), "design")
})

test_that("fmt_strip2 labels aligned nested grids and keeps placeholders", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  nested <- ((p | p) / (p | p)) + patchwork::plot_annotation(title = "Overall")
  out <- fmt_strip2(nested, c("T1", "T2"), c("R1", "R2"), ncol = 2)
  expect_identical(list(labels(out[[1]][[1]]), labels(out[[1]][[2]]),
                        labels(out[[2]][[1]]), labels(out[[2]][[2]])),
                   list("T1", c("T2", "R1"), character(), "R2"))
  expect_equal(out$patches$layout, nested$patches$layout)
  expect_equal(out$patches$annotation, nested$patches$annotation)
  expect_equal(out[[1]]$patches$layout, nested[[1]]$patches$layout)
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")

  spaced <- patchwork::wrap_plots(p, patchwork::plot_spacer(),
                                  patchwork::guide_area(), p, ncol = 2)
  out <- fmt_strip2(spaced, c("T1", "T2"), c("R1", "R2"))
  expect_identical(out[[2]], spaced[[2]])
  expect_identical(out[[3]], spaced[[3]])
  expect_identical(labels(out[[1]]), c("T1", "R1"))
  expect_identical(labels(out[[4]]), "R2")
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")
  empty <- patchwork::wrap_plots(patchwork::plot_spacer(), patchwork::guide_area())
  expect_identical(fmt_strip2(empty, "Top", "Right"), empty)
  named <- list(first = p, empty = patchwork::plot_spacer(), last = p)
  expect_identical(names(fmt_strip2(named, "Top", "Right", ncol = 2)), names(named))
  expect_error(fmt_strip2(p | (p / p), "Top", "Right"), "aligned")
})

test_that("fmt_strip2 keeps inset plots outside the grid cell count", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  labels <- function(p) vapply(.fmt_strip_text(p), `[[`, character(1), "label")
  for (content in list(p, p | p)) {
    inset <- p + patchwork::inset_element(content, .5, .5, 1, 1)
    out <- fmt_strip2(inset, "Top", "Right", ncol = 1)
    expect_identical(labels(out[[1]]), c("Top", "Right"))
    expect_identical(out[[2]], inset[[2]])
    expect_equal(out$patches$layout, inset$patches$layout)
    expect_s3_class(patchwork::patchworkGrob(out), "gtable")
  }
  nested <- patchwork::wrap_plots(inset, inset, ncol = 2)
  out <- fmt_strip2(nested, c("T1", "T2"), "Row", ncol = 2)
  expect_identical(labels(out[[1]][[1]]), "T1")
  expect_identical(labels(out[[2]][[1]]), c("T2", "Row"))
  expect_identical(out[[1]][[2]], nested[[1]][[2]])
  expect_identical(out[[2]][[2]], nested[[2]][[2]])
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")

  tagged <- fmt_tag(p | p, label_position = "tl-out")
  out <- fmt_strip2(tagged, c("T1", "T2"), "Row", ncol = 2)
  expect_identical(out[[1]][[2]], tagged[[1]][[2]])
  expect_identical(out[[2]][[2]], tagged[[2]][[2]])
  expect_s3_class(patchwork::patchworkGrob(out), "gtable")
})

test_that("fmt_strip2 restores hidden strip themes while retaining text styles", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  for (theme in list(
    ggplot2::theme(strip.text = ggplot2::element_blank()),
    ggplot2::theme(strip.text.x.top = ggplot2::element_blank(),
                   strip.text.y.right = ggplot2::element_blank()),
    ggplot2::theme(strip.background = ggplot2::element_blank())
  )) {
    for (args in list(list(top_label = "Top", right_label = "Right"),
                       list(top_label = "Top"), list(right_label = "Right"))) {
      out <- do.call(fmt_strip2, c(list(plot = p + theme, ncol = 1), args))
      expect_identical(vapply(.fmt_strip_text(out), `[[`, character(1), "label"),
                       unname(unlist(args)))
    }
  }
  native <- p + ggplot2::facet_wrap(ggplot2::vars(One = "A")) + ggplot2::theme(
    strip.text.x.top = ggplot2::element_text(size = 17, angle = 15),
    strip.text.y.right = ggplot2::element_text(size = 18, angle = 25)
  )
  hidden <- fmt_strip(native, strip = FALSE)
  out <- fmt_strip2(hidden, "Top", "Right", ncol = 1, label_color = "blue")
  texts <- .fmt_strip_text(out)
  expect_identical(vapply(texts, `[[`, character(1), "label"), c("Top", "Right"))
  expect_equal(vapply(texts, function(x) x$gp$fontsize, numeric(1)), c(17, 18))
  expect_equal(vapply(texts, function(x) x$rot, numeric(1)), c(15, 25))
  expect_identical(vapply(texts, function(x) x$gp$col, character(1)), c("blue", "blue"))
  expect_length(.fmt_strip_text(hidden), 0L)
  again <- fmt_strip2(out, "Again", "Row", ncol = 1)
  expect_identical(vapply(.fmt_strip_text(again), `[[`, character(1), "label"),
                   c("Again", "Row"))
  old_theme <- ggplot2::theme_set(ggplot2::theme_gray() +
                                  ggplot2::theme(strip.text = ggplot2::element_blank()))
  withr::defer(ggplot2::theme_set(old_theme))
  expect_identical(vapply(.fmt_strip_text(fmt_strip2(p, "Top", "Right", ncol = 1)),
                          `[[`, character(1), "label"), c("Top", "Right"))
})

test_that("fmt_strip2 validates dimensions labels colours and palettes", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  for (bad in list(0, -1, 1.5, NA_real_, Inf, c(1, 2), "2", TRUE)) {
    expect_error(fmt_strip2(p, "Top", "Right", ncol = bad), "ncol")
  }
  for (arg in c("top_label", "right_label")) {
    for (bad in list(character(), NA_character_, 1, list("A"))) {
      expect_error(do.call(fmt_strip2, c(list(plot = p), stats::setNames(list(bad), arg))), arg)
    }
  }
  for (arg in c("top_fill", "right_fill", "label_color")) {
    for (bad in list(character(), list("red"), "not-a-colour", Inf)) {
      expect_error(do.call(fmt_strip2, c(list(plot = p, top_label = "Top",
                                             right_label = "Right"),
                                        stats::setNames(list(bad), arg))), arg)
    }
  }
  for (bad in list(character(), NA_character_, "", 1, c("Grays", "Greens", "Reds"),
                   "not-a-palette")) {
    expect_error(fmt_strip2(p, "Top", "Right", top_right_fill = bad), "top_right_fill")
  }
  invalid <- patchwork::wrap_plots(rep(list(p), 4), nrow = 1, ncol = 1)
  expect_error(fmt_strip2(invalid, "Top", "Right"), "layout")
  expect_identical(fmt_strip2(list()), list())
  expect_s3_class(ggplot2::ggplotGrob(fmt_strip2(p, "", "", label_color = 1)), "gtable")
})

test_that("fmt_strip2 generates only used palettes and supports transparent fills", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point() +
    ggplot2::theme(strip.background = ggplot2::element_rect(fill = "pink"))
  transparent <- fmt_strip2(p, "Top", "Right", ncol = 1,
                            top_fill = NA, right_fill = NA, top_right_fill = NULL)
  fills <- vapply(.fmt_strip_text(transparent, "rect"), function(x) x$gp$fill, character(1))
  expect_true(all(grDevices::col2rgb(fills, alpha = TRUE)[4, ] == 0))
  expect_identical(vapply(.fmt_strip_text(fmt_strip2(p, "Top", ncol = 1,
                                                   top_right_fill = NULL), "rect"),
                          function(x) x$gp$fill, character(1)), "grey85")

  calls <- 0L
  original <- colorspace::sequential_hcl
  testthat::local_mocked_bindings(
    sequential_hcl = function(...) { calls <<- calls + 1L; original(...) },
    .package = "colorspace"
  )
  out <- fmt_strip2(p, "Top", ncol = 1, top_right_fill = c("Grays", "unused-palette"))
  expect_identical(calls, 1L)
  expect_s3_class(ggplot2::ggplotGrob(out), "gtable")
  calls <- 0L
  invisible(fmt_strip2(p, right_label = "Right", ncol = 1,
                       top_right_fill = c("unused-palette", "Greens")))
  expect_identical(calls, 1L)
  calls <- 0L
  panels <- patchwork::wrap_plots(rep(list(p), 4), ncol = 2)
  out <- fmt_strip2(panels, c("T1", "T2"), c("R1", "R2"), top_right_fill = "Grays")
  expect_identical(calls, 1L)
  expect_identical(out[[2]]$facet$strip$given_elements$background_x[[1]]@fill,
                   out[[4]]$facet$strip$given_elements$background_y[[1]]@fill)
  calls <- 0L
  invisible(fmt_strip2(panels, "Top", "Right", top_fill = "pink", right_fill = "cyan"))
  expect_identical(calls, 0L)
  ignored <- fmt_strip2(p, top_right_fill = "unused-palette", top_fill = "not-a-colour")
  expect_identical(calls, 0L)
  expect_identical(ignored, p)
})

test_that("fmt_strip2 preserves RNG state and statistic execution counts", {
  calls <- 0L
  data_calls <- 0L
  stat <- ggplot2::ggproto("StatStrip2Random", ggplot2::Stat,
    required_aes = c("x", "y"),
    compute_group = function(data, scales) {
      calls <<- calls + 1L
      data$y <- data$y + stats::runif(1)
      data
    }
  )
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::layer(
    stat = stat, geom = "point", position = "identity",
    data = function(data) { data_calls <<- data_calls + 1L; data }
  )
  grid <- patchwork::wrap_plots(rep(list(p), 4), ncol = 2)
  set.seed(19)
  seed <- .Random.seed
  out <- fmt_strip2(grid, c("T1", "T2"), c("R1", "R2"))
  expect_identical(.Random.seed, seed)
  expect_identical(calls, 0L)
  expect_identical(data_calls, 0L)
  before <- lapply(seq_along(grid), function(i) ggplot2::ggplot_build(grid[[i]])$data)
  final_seed <- .Random.seed
  calls <- data_calls <- 0L
  assign(".Random.seed", seed, envir = .GlobalEnv)
  after <- lapply(seq_along(out), function(i) ggplot2::ggplot_build(out[[i]])$data)
  expect_identical(calls, 4L)
  expect_identical(data_calls, 4L)
  expect_identical(.Random.seed, final_seed)
  expect_equal(after, before)
  expect_null(p$facet$.fmt_strip_generated)
})

test_that("fmt_strip2 supports top_right_fill strip palettes", {
  testthat::skip_if_not_installed("ggh4x")

  panels <- lapply(seq_len(4), function(i) {
    ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point()
  })

  out <- fmt_strip2(
    panels,
    top_label = c("Top 1", "Top 2"),
    right_label = c("Right 1", "Right 2"),
    ncol = 2,
    top_right_fill = c("Reds", "Blues")
  )

  top_fill <- vapply(
    out[[2]]$facet$strip$given_elements$background_x,
    function(x) x@fill,
    character(1)
  )
  right_fill <- vapply(
    out[[2]]$facet$strip$given_elements$background_y,
    function(x) x@fill,
    character(1)
  )

  expect_length(top_fill, 1L)
  expect_length(right_fill, 1L)
  expect_false(identical(top_fill, "grey85"))
  expect_false(identical(right_fill, "grey85"))
})

test_that("fmt_strip2 keeps explicit fills ahead of top_right_fill palettes", {
  testthat::skip_if_not_installed("ggh4x")

  panels <- lapply(seq_len(4), function(i) {
    ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point()
  })

  out <- fmt_strip2(
    panels,
    top_label = c("Top 1", "Top 2"),
    right_label = c("Right 1", "Right 2"),
    ncol = 2,
    top_fill = "pink",
    right_fill = "cyan",
    top_right_fill = c("Reds", "Blues")
  )

  expect_identical(
    out[[2]]$facet$strip$given_elements$background_x[[1]]@fill,
    "pink"
  )
  expect_identical(
    out[[2]]$facet$strip$given_elements$background_y[[1]]@fill,
    "cyan"
  )
})

test_that("fmt_strip2 uses top_right_fill palettes by default", {
  testthat::skip_if_not_installed("ggh4x")

  panels <- lapply(seq_len(4), function(i) {
    ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point()
  })

  out <- fmt_strip2(
    panels,
    top_label = c("Top 1", "Top 2"),
    right_label = c("Right 1", "Right 2"),
    ncol = 2
  )

  expect_identical(
    formals(fmt_strip2)$top_right_fill,
    quote(c("Grays", "Greens"))
  )
  expect_false(
    identical(
      out[[2]]$facet$strip$given_elements$background_x[[1]]@fill,
      "grey85"
    )
  )
  expect_false(
    identical(
      out[[2]]$facet$strip$given_elements$background_y[[1]]@fill,
      "grey85"
    )
  )
  expect_identical(
    out[[2]]$facet$strip$given_elements$background_x[[1]]@fill,
    "#7C7C7C"
  )
  expect_identical(
    out[[4]]$facet$strip$given_elements$background_y[[1]]@fill,
    "#58AC56"
  )
})
