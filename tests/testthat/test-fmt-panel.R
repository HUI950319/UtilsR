panel_test_plot <- function() {
  ggplot2::ggplot(data.frame(x = 1:5, y = c(1, 4, 2, 5, 3)),
                  ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::theme_gray()
}

panel_test_grid_grobs <- function(g) {
  result <- if (inherits(g, "polyline") && grepl("^panel.grid\\.", g$name)) {
    data.frame(element = sub("^panel.grid\\.((major|minor)\\.[xy]).*", "\\1", g$name),
               colour = g$gp$col, linewidth = g$gp$lwd, linetype = g$gp$lty)
  } else NULL
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  do.call(rbind, c(list(result), lapply(children, panel_test_grid_grobs)))
}

panel_test_grids <- function(p) {
  panel_test_grid_grobs(ggplot2::ggplotGrob(p))
}

test_that("panel grid modes override axis-specific retained and hidden grids", {
  p <- panel_test_plot() + ggplot2::theme(
    panel.grid.major.x = ggplot2::element_line(colour = "blue"),
    panel.grid.minor.x = ggplot2::element_line(colour = "blue"))
  expected <- list(none = character(), major = c("major.x", "major.y"),
                   minor = c("minor.x", "minor.y"),
                   both = c("major.x", "major.y", "minor.x", "minor.y"),
                   x = "major.x", y = "major.y")
  for (mode in names(expected)) {
    grids <- panel_test_grids(fmt_panel(p, grid = mode))
    expect_setequal(grids$element %||% character(), expected[[mode]])
  }
  grids <- panel_test_grids(fmt_panel(p, grid = "both", grid_color = "red",
                                    grid_linewidth = 0.8, grid_linetype = "dashed"))
  expect_equal(grids$colour, rep("red", 4))
  expect_equal(grids$linewidth, rep(0.8 * 72.27 / 25.4, 4))
  expect_equal(grids$linetype, rep("dashed", 4))
})

test_that("panel grid mode switches restore enabled lines without new styling", {
  expected <- list(none = character(), major = c("major.x", "major.y"),
                   minor = c("minor.x", "minor.y"),
                   both = c("major.x", "major.y", "minor.x", "minor.y"),
                   x = "major.x", y = "major.y")
  p <- panel_test_plot()
  for (first in names(expected)) {
    for (second in names(expected)) {
      q <- fmt_panel(fmt_panel(p, grid = first), grid = second)
      expect_setequal(panel_test_grids(q)$element %||% character(), expected[[second]])
    }
  }
  for (theme in list(ggplot2::theme_classic(), ggplot2::theme_void())) {
    expect_setequal(panel_test_grids(fmt_panel(p + theme, grid = "both"))$element,
                    expected$both)
  }
  styled <- p + ggplot2::theme(
    panel.grid = ggplot2::element_line(colour = "purple", linewidth = 0.7),
    panel.grid.major.x = ggplot2::element_blank())
  before <- styled$theme
  grids <- panel_test_grids(fmt_panel(styled, grid = "x"))
  expect_equal(grids$colour, "purple")
  expect_equal(grids$linewidth, 0.7 * 72.27 / 25.4)
  expect_identical(styled$theme, before)
})

test_that("panel formatting reaches nested leaves and retains layouts and names", {
  p <- panel_test_plot()
  nested <- ((p | p) / (p | p)) +
    patchwork::plot_annotation(title = "Keep", tag_levels = "A")
  before <- nested
  output <- fmt_panel(nested, bg = "pink", border = TRUE)
  leaves <- .to_plot_list(output, recurse = TRUE)$plots
  expect_equal(vapply(leaves, function(z) z$theme$panel.background$fill, character(1)),
                rep("pink", 4))
  expect_null(panel_test_grid_grobs(patchwork::patchworkGrob(output)))
  expect_identical(output$patches$layout, nested$patches$layout)
  expect_identical(output$patches$annotation, nested$patches$annotation)
  expect_identical(output[[1]]$patches$layout, nested[[1]]$patches$layout)
  expect_identical(nested, before)
  plots <- list(top = nested, bottom = p)
  output <- fmt_panel(plots, bg = "pink")
  expect_named(output, names(plots))
  expect_equal(vapply(.to_plot_list(output, recurse = TRUE)$plots,
                      function(z) z$theme$panel.background$fill, character(1)),
                rep("pink", 5))
})

test_that("panel formatting retains the shape of nested lists", {
  p <- panel_test_plot()
  plots <- list(first = list(left = p, right = p | p), last = p)
  output <- fmt_panel(plots, bg = "pink")
  expect_named(output, names(plots))
  expect_named(output$first, names(plots$first))
  expect_equal(output$first$left$theme$panel.background$fill, "pink")
  expect_equal(output$first$right[[1]]$theme$panel.background$fill, "pink")
  expect_equal(output$first$right[[2]]$theme$panel.background$fill, "pink")
  expect_identical(fmt_panel(list()), list())
  expect_error(fmt_panel(list(p, "invalid")), "ggplot")
})

test_that("panel arguments reject malformed borders, widths and colours immediately", {
  p <- panel_test_plot()
  for (border in list(1, NA, c(TRUE, FALSE), logical(), character(),
                       c("red", "blue"), NA_character_)) {
    expect_error(fmt_panel(p, border = border), "border")
  }
  for (width in list(-1, Inf, NaN, NA_real_, numeric(), c(0.1, 0.2), "0.5", TRUE, 1 + 0i)) {
    expect_error(fmt_panel(p, grid_linewidth = width), "grid_linewidth")
    expect_error(fmt_panel(p, border_linewidth = width), "border_linewidth")
  }
  for (colour in list("invalid-colour", c("red", "blue"), character(), 1, TRUE)) {
    expect_error(fmt_panel(p, grid_color = colour), "grid_color")
    expect_error(fmt_panel(p, bg = colour), "bg")
  }
  expect_error(fmt_panel(p, border = "invalid-colour"), "border")
  expect_error(fmt_panel(p, border_linewidth = NULL), "border_linewidth")
  expect_silent(ggplot2::ggplotGrob(fmt_panel(p, grid = "both", grid_color = NA,
                                           bg = NA, grid_linewidth = 0,
                                           border = "transparent", border_linewidth = 0L)))
  expect_equal(fmt_panel(p, border = FALSE)$theme$panel.border, ggplot2::element_blank())
})

test_that("panel grid line types accept named, numeric and hexadecimal patterns", {
  p <- panel_test_plot()
  for (value in list(NA, numeric(), c(1, 2), -1, 7, 1.5, 1 + 0i, "invalid", "123", "10")) {
    expect_error(fmt_panel(p, grid_linetype = value), "grid_linetype")
  }
  for (value in list(NULL, 0L, 1, 6L, "solid", "dashed", "22", "F1F1")) {
    expect_silent(ggplot2::ggplotGrob(fmt_panel(p, grid = "major", grid_linetype = value)))
  }
})

test_that("panel formatting leaves fixed cells and inset overlays unchanged", {
  p <- panel_test_plot()
  fixed <- patchwork::wrap_elements(full = p)
  spacer <- patchwork::plot_spacer()
  guides <- patchwork::guide_area()
  for (input in list(fixed, spacer, guides)) {
    expect_identical(fmt_panel(input, border = TRUE, bg = "pink"), input)
    combined <- p | input
    output <- fmt_panel(combined, border = TRUE, bg = "pink")
    expect_identical(output[[2]], combined[[2]])
    expect_silent(patchwork::patchworkGrob(output))
  }
  input <- patchwork::free((p | p) / (p | fixed), side = "l")
  output <- fmt_panel(input, border = TRUE, bg = "pink")
  expect_identical(attr(output, "patchwork_free_settings"), attr(input, "patchwork_free_settings"))
  expect_equal(vapply(.to_plot_list(output, recurse = TRUE)$plots,
                      function(z) z$theme$panel.background$fill, character(1)),
                rep("pink", 3))
  expect_silent(patchwork::patchworkGrob(output))
  inset <- p + patchwork::inset_element(p, 0.1, 0.1, 0.5, 0.5)
  output <- fmt_panel(inset, border = TRUE, bg = "pink")
  expect_identical(output[[2]], inset[[2]])
  expect_equal(output[[1]]$theme$panel.background$fill, "pink")
  expect_silent(patchwork::patchworkGrob(output))
})

test_that("panel formatting preserves computed data and evaluates no data functions", {
  d <- data.frame(x = rep(1:3, 4), y = (1:12)^2,
                   group = rep(c("A", "B"), each = 6))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::stat_summary(fun = mean, geom = "line") + ggplot2::facet_wrap(~group) +
    ggplot2::scale_x_continuous(limits = c(0, 4), breaks = 1:3)
  before <- ggplot2::ggplot_build(p)
  output <- fmt_panel(p, grid = "major", border = TRUE, bg = "white")
  after <- ggplot2::ggplot_build(output)
  expect_identical(after$data, before$data)
  expect_identical(after$layout$layout, before$layout$layout)
  expect_identical(output$data, p$data)
  expect_identical(output$mapping, p$mapping)
  expect_identical(output$layers, p$layers)
  expect_identical(output$scales$get_scales("x")$limits, c(0, 4))
  expect_identical(output$scales$get_scales("x")$breaks, 1:3)
  expect_identical(class(output$scales$get_scales("x")), class(p$scales$get_scales("x")))
  expect_identical(p$scales$get_scales("x")$limits, c(0, 4))
  calls <- 0L
  dynamic <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(d) { calls <<- calls + 1L; d })
  formatted <- fmt_panel(dynamic, grid = "both", bg = "white")
  expect_equal(calls, 0L)
  ggplot2::ggplot_build(formatted)
  expect_equal(calls, 1L)
})

test_that("extra panel themes retain their documented override priority", {
  p <- panel_test_plot()
  output <- fmt_panel(p, grid = "none", bg = "white", border = TRUE,
                      panel.background = ggplot2::element_rect(fill = "pink"),
                      panel.grid.major.x = ggplot2::element_line(colour = "green"),
                      panel.border = ggplot2::element_rect(fill = NA, colour = "blue"))
  expect_equal(output$theme$panel.background$fill, "pink")
  expect_equal(output$theme$panel.border$colour, "blue")
  expect_equal(panel_test_grids(output)$element, "major.x")
  expect_equal(panel_test_grids(output)$colour, "green")
  expect_identical(fmt_panel(p, border_linewidth = 2)$theme$panel.border, p$theme$panel.border)
  expect_identical(names(formals(fmt_panel)),
                    c("plot", "grid", "grid_color", "grid_linewidth", "grid_linetype",
                      "border", "border_linewidth", "bg", "..."))
})

test_that("repeated panel formatting retains rendered pixels and stable themes", {
  skip_if_not_installed("ragg")
  capture <- function(p) {
    grab <- ragg::agg_capture(width = 360, height = 240, units = "px", res = 72)
    on.exit(grDevices::dev.off())
    print(p)
    grab(native = TRUE)
  }
  once <- fmt_panel(panel_test_plot(), grid = "y", grid_color = "grey70",
                     border = TRUE, bg = "white")
  twice <- fmt_panel(once, grid = "y", grid_color = "grey70", border = TRUE, bg = "white")
  expect_equal(sum(capture(once) != capture(twice)), 0L)
  repeated <- twice
  for (i in 1:20) repeated <- fmt_panel(repeated, grid = "y", grid_color = "grey70",
                                       border = TRUE, bg = "white")
  expect_identical(repeated$theme, twice$theme)
  expect_length(repeated$layers, length(once$layers))
})

test_that("panel fallback styles use the current global theme on every call", {
  old <- ggplot2::theme_set(ggplot2::theme_minimal())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot() + ggplot2::theme(panel.grid = ggplot2::element_blank())
  for (colour in c("orange", "purple")) {
    ggplot2::theme_set(ggplot2::theme_minimal() +
                        ggplot2::theme(panel.grid = ggplot2::element_line(colour = colour)))
    grids <- panel_test_grids(fmt_panel(p, grid = "both"))
    expect_equal(grids$colour, rep(colour, 4))
  }
  ggplot2::theme_set(ggplot2::theme_void())
  expect_setequal(panel_test_grids(fmt_panel(p, grid = "both"))$element,
                  c("major.x", "major.y", "minor.x", "minor.y"))
})

test_that("restored grids inherit parent styles during and after formatting", {
  p <- panel_test_plot()
  parent <- ggplot2::element_line(colour = "red", linewidth = 1.1,
                                 linetype = "dashed")
  for (hidden in c("panel.grid.major.x", "panel.grid.major", "panel.grid")) {
    input <- p + do.call(ggplot2::theme,
                         stats::setNames(list(ggplot2::element_blank()), hidden))
    before <- input$theme
    outputs <- list(
      fmt_panel(input, grid = "major", panel.grid.major = parent),
      fmt_panel(input, grid = "major") + ggplot2::theme(panel.grid.major = parent))
    for (output in outputs) {
      grids <- panel_test_grids(output)
      expect_setequal(grids$element, c("major.x", "major.y"))
      expect_equal(grids$colour, rep("red", 2))
      expect_equal(grids$linewidth, rep(1.1 * 72.27 / 25.4, 2))
      expect_equal(grids$linetype, rep("dashed", 2))
      expect_identical(ggplot2::ggplot_build(output)$data,
                       ggplot2::ggplot_build(input)$data)
    }
    expect_identical(input$theme, before)
  }
})

test_that("grid restoration leaves blank root lines and relative minor styles intact", {
  p <- panel_test_plot() + ggplot2::theme(line = ggplot2::element_blank(),
                                        panel.grid = ggplot2::element_blank())
  output <- fmt_panel(p, grid = "both")
  grids <- panel_test_grids(output)
  expect_identical(output$theme$line, p$theme$line)
  expect_setequal(grids$element, c("major.x", "major.y", "minor.x", "minor.y"))
  expect_equal(grids$linewidth[grepl("major", grids$element)], rep(0.5 * 72.27 / 25.4, 2))
  expect_equal(grids$linewidth[grepl("minor", grids$element)], rep(0.25 * 72.27 / 25.4, 2))
  updated <- output + ggplot2::theme(panel.grid = ggplot2::element_line(linewidth = 0.8))
  grids <- panel_test_grids(updated)
  expect_equal(grids$linewidth[grepl("major", grids$element)], rep(0.8 * 72.27 / 25.4, 2))
  expect_equal(grids$linewidth[grepl("minor", grids$element)], rep(0.4 * 72.27 / 25.4, 2))
})

test_that("panel width arguments use absolute millimetres and reject relative values", {
  p <- panel_test_plot()
  for (mode in c("none", "major", "minor", "both", "x", "y")) {
    expect_error(fmt_panel(p, grid = mode, grid_linewidth = ggplot2::rel(0.5)),
                 "grid_linewidth.*absolute")
    expect_error(fmt_panel(p, grid = mode, border = TRUE,
                           border_linewidth = ggplot2::rel(0.5)),
                 "border_linewidth.*absolute")
  }
  output <- fmt_panel(p, grid = "both", grid_linewidth = 0.3,
                      border = TRUE, border_linewidth = 0.8)
  expect_equal(panel_test_grids(output)$linewidth, rep(0.3 * 72.27 / 25.4, 4))
  expect_equal(ggplot2::calc_element("panel.border",
                                    ggplot2::theme_get() + output$theme)$linewidth, 0.8)
  relative <- fmt_panel(p, grid = "major",
                        panel.grid.major = ggplot2::element_line(linewidth = ggplot2::rel(0.5)))
  expect_equal(panel_test_grids(relative)$linewidth, rep(0.25 * 72.27 / 25.4, 2))
})

test_that("automatic restored grid colours remain visible on matching backgrounds", {
  skip_if_not_installed("ragg")
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot() + ggplot2::theme_classic() +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
  before <- p$theme
  capture <- function(plot) {
    grab <- ragg::agg_capture(width = 360, height = 240, units = "px", res = 96)
    on.exit(grDevices::dev.off())
    print(plot)
    grab(native = TRUE)
  }
  output <- fmt_panel(p, grid = "both")
  expect_equal(panel_test_grids(output)$colour, rep("grey70", 4))
  expect_gt(sum(capture(output) != capture(fmt_panel(p, grid = "none"))), 0)
  expect_identical(ggplot2::ggplot_build(output)$data, ggplot2::ggplot_build(p)$data)
  expect_identical(output$theme$panel.background, p$theme$panel.background)
  expect_identical(p$theme, before)
  ggplot2::theme_set(ggplot2::theme_gray() +
                      ggplot2::theme(panel.grid = ggplot2::element_line(colour = "grey70")))
  expect_equal(panel_test_grids(fmt_panel(p, grid = "both", bg = "grey70"))$colour,
               rep("grey30", 4))
})

test_that("contrast fallback preserves available and explicit grid colours", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot() + ggplot2::theme_classic() +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
  expect_equal(panel_test_grids(fmt_panel(p, grid = "both", grid_color = "white"))$colour,
               rep("white", 4))
  expect_equal(panel_test_grids(fmt_panel(p, grid = "both",
                                         panel.grid = ggplot2::element_line(colour = "white")))$colour,
               rep("white", 4))
  expect_equal(panel_test_grids(fmt_panel(p, grid = "major",
                                         panel.grid.major = ggplot2::element_line(colour = "white")))$colour,
               rep("white", 2))
  expect_equal(panel_test_grids(fmt_panel(p, grid = "both", bg = "black"))$colour,
               rep("white", 4))
  available <- panel_test_plot() + ggplot2::theme(
    panel.grid = ggplot2::element_line(colour = "purple"),
    panel.grid.major.x = ggplot2::element_blank())
  expect_equal(panel_test_grids(fmt_panel(available, grid = "x", bg = "purple"))$colour,
               "grey70")
  transparent <- fmt_panel(p, grid = "both", bg = NA,
                           plot.background = ggplot2::element_rect(fill = NA, colour = NA))
  expect_equal(panel_test_grids(transparent)$colour, rep("white", 4))
  expect_identical(transparent$theme$panel.background$fill, NA)
})

test_that("batch formatting resolves identical grid themes only once", {
  p <- panel_test_plot()
  before <- p$theme
  calc <- ggplot2::calc_element
  calls <- 0L
  testthat::local_mocked_bindings(calc_element = function(...) {
    calls <<- calls + 1L
    calc(...)
  }, .package = "ggplot2")
  single <- fmt_panel(p, grid = "both")
  single_calls <- calls
  calls <- 0L
  output <- fmt_panel(rep(list(p), 12), grid = "both")
  expect_gt(single_calls, 0L)
  expect_equal(calls, single_calls)
  expect_identical(lapply(output, function(z) z$theme), rep(list(single$theme), 12))
  expect_identical(p$theme, before)
})

test_that("batch theme reuse preserves mixed styles and refreshes between calls", {
  p <- panel_test_plot()
  q <- p + ggplot2::theme(panel.grid = ggplot2::element_line(colour = "purple"),
                          panel.grid.major.x = ggplot2::element_blank())
  plots <- rep(list(p, q, p + ggplot2::theme_classic(), p + ggplot2::theme_void()), 3)
  output <- fmt_panel(plots, grid = "both")
  expected <- lapply(plots, fmt_panel, grid = "both")
  expect_identical(lapply(output, function(z) z$theme), lapply(expected, function(z) z$theme))
  for (i in seq_along(output)) {
    expect_identical(ggplot2::ggplot_build(output[[i]])$data,
                     ggplot2::ggplot_build(expected[[i]])$data)
  }
  old <- ggplot2::theme_set(ggplot2::theme_minimal())
  withr::defer(ggplot2::theme_set(old))
  hidden <- p + ggplot2::theme(panel.grid = ggplot2::element_blank())
  for (colour in c("orange", "purple")) {
    ggplot2::theme_set(ggplot2::theme_minimal() +
                        ggplot2::theme(panel.grid = ggplot2::element_line(colour = colour)))
    output <- fmt_panel(rep(list(hidden), 3), grid = "both")
    expect_equal(lapply(output, function(z) panel_test_grids(z)$colour),
                 rep(list(rep(colour, 4)), 3))
  }
})

test_that("automatic contrast corrects restored group and axis colours", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot() + ggplot2::theme_classic()
  fields <- list(groups = c("panel.grid.major", "panel.grid.minor"),
                 axes = c("panel.grid.major.x", "panel.grid.major.y",
                          "panel.grid.minor.x", "panel.grid.minor.y"))
  for (elements in fields) {
    ggplot2::theme_set(ggplot2::theme_gray() + do.call(ggplot2::theme,
      stats::setNames(rep(list(ggplot2::element_line(colour = "white")),
                          length(elements)), elements)))
    hidden <- do.call(ggplot2::theme,
      stats::setNames(rep(list(ggplot2::element_blank()), length(elements)), elements))
    for (root in list(ggplot2::element_blank(),
                     ggplot2::element_line(colour = "purple"))) {
      input <- p + hidden + ggplot2::theme(panel.grid = root)
      before <- input$theme
      output <- fmt_panel(input, grid = "both")
      expect_equal(panel_test_grids(output)$colour, rep("grey70", 4))
      expect_identical(ggplot2::ggplot_build(output)$data,
                       ggplot2::ggplot_build(input)$data)
      expect_identical(input$theme, before)
      expect_equal(panel_test_grids(fmt_panel(input, grid = "both",
                                              grid_color = "white"))$colour,
                   rep("white", 4))
      explicit <- do.call(fmt_panel, c(list(plot = input, grid = "both"),
        stats::setNames(rep(list(ggplot2::element_line(colour = "white")),
                            length(elements)), elements)))
      expect_equal(panel_test_grids(explicit)$colour, rep("white", 4))
    }
  }
})

test_that("panel formatting rejects non-plot gg components", {
  p <- panel_test_plot()
  before <- p$theme
  components <- list(ggplot2::theme_gray(), ggplot2::theme(),
                     ggplot2::aes(x, y), structure(list(), class = "gg"))
  for (component in components) {
    for (mode in c("none", "both")) {
      expect_error(fmt_panel(component, grid = mode), "Input must be a ggplot")
      expect_error(fmt_panel(list(first = p, next_plot = list(component)),
                             grid = mode), "Input must be a ggplot")
    }
  }
  expect_true(inherits(fmt_panel(p), "ggplot"))
  expect_true(inherits(fmt_panel(p | p), "patchwork"))
  expect_true(inherits(fmt_panel(list(p))[[1]], "ggplot"))
  expect_identical(p$theme, before)
})

test_that("automatic contrast uses known opaque composited backgrounds", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot() + ggplot2::theme_classic() +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
  before <- p$theme
  cases <- list(
    list(bg = "#FFFFFF80", outside = "white", grid = "white", expected = "grey70"),
    list(bg = "#00000080", outside = "black", grid = "black", expected = "grey70"),
    list(bg = "#FFFFFF80", outside = "black", grid = "#808080", expected = "grey70"),
    list(bg = "#FFFFFF80", outside = "black", grid = "white", expected = "white"),
    list(bg = "#FFFFFF80", outside = "#FFFFFF80", grid = "white", expected = "white"),
    list(bg = "#FFFFFF80", outside = NA, grid = "white", expected = "white"))
  for (case in cases) {
    ggplot2::theme_set(ggplot2::theme_gray() +
                        ggplot2::theme(panel.grid = ggplot2::element_line(colour = case$grid)))
    output <- fmt_panel(p, grid = "both", bg = case$bg,
                        plot.background = ggplot2::element_rect(fill = case$outside, colour = NA))
    expect_equal(panel_test_grids(output)$colour, rep(case$expected, 4))
    expect_identical(output$theme$panel.background$fill, case$bg)
    expect_identical(output$theme$plot.background$fill, case$outside)
    expect_identical(ggplot2::ggplot_build(output)$data, ggplot2::ggplot_build(p)$data)
  }
  ggplot2::theme_set(ggplot2::theme_gray())
  for (extra in list(list(grid_color = "white"),
                    list(panel.grid = ggplot2::element_line(colour = "white")))) {
    output <- do.call(fmt_panel, c(list(plot = p, grid = "both", bg = "#FFFFFF80",
      plot.background = ggplot2::element_rect(fill = "white", colour = NA)), extra))
    expect_equal(panel_test_grids(output)$colour, rep("white", 4))
  }
  if (requireNamespace("ragg", quietly = TRUE)) {
    capture <- function(p) {
      grab <- ragg::agg_capture(width = 360, height = 240, units = "px", res = 96)
      on.exit(grDevices::dev.off())
      print(p)
      grab(native = TRUE)
    }
    visible <- fmt_panel(p, grid = "both", bg = "#FFFFFF80",
                         plot.background = ggplot2::element_rect(fill = "white", colour = NA))
    hidden <- fmt_panel(p, grid = "none", bg = "#FFFFFF80",
                        plot.background = ggplot2::element_rect(fill = "white", colour = NA))
    expect_gt(sum(capture(visible) != capture(hidden)), 0L)
  }
  expect_identical(p$theme, before)
})

test_that("batch themes are reused beyond the initial cache and after misses", {
  p <- panel_test_plot()
  plots <- lapply(seq_len(9), function(i) p + ggplot2::theme(
    panel.grid = ggplot2::element_line(colour = grDevices::gray(i / 10))))
  patterns <- list(
    list(plots = c(plots[1:4], rep(plots[5], 12)), resolutions = 5L),
    list(plots = rep(plots[1:5], 3), resolutions = 5L),
    list(plots = c(plots[1:8], rep(plots[8], 12), rep(plots[9], 12)), resolutions = 9L))
  calls <- 0L
  calc <- ggplot2::calc_element
  testthat::local_mocked_bindings(calc_element = function(...) {
    calls <<- calls + 1L
    calc(...)
  }, .package = "ggplot2")
  fmt_panel(p, grid = "both")
  single_calls <- calls
  for (pattern in patterns) {
    before <- lapply(pattern$plots, function(z) z$theme)
    calls <- 0L
    output <- fmt_panel(pattern$plots, grid = "both")
    expect_equal(calls, pattern$resolutions * single_calls)
    expected <- lapply(pattern$plots, fmt_panel, grid = "both")
    expect_identical(lapply(output, function(z) z$theme),
                     lapply(expected, function(z) z$theme))
    expect_identical(lapply(pattern$plots, function(z) z$theme), before)
  }
})

test_that("batch formatting retains empty theme entries alongside other themes", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot()
  empty <- p
  empty$theme <- NULL
  hidden <- p + ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  classic <- p + ggplot2::theme_classic()
  patterns <- list(list(empty, hidden, hidden, classic, classic),
                   list(hidden, empty, classic, classic, hidden),
                   list(empty, empty, hidden, classic, empty))
  for (plots in patterns) {
    before <- lapply(plots, function(z) z$theme)
    output <- fmt_panel(plots, grid = "both")
    expected <- lapply(plots, fmt_panel, grid = "both")
    expect_identical(lapply(output, function(z) z$theme),
                     lapply(expected, function(z) z$theme))
    for (i in seq_along(output)) {
      expect_setequal(panel_test_grids(output[[i]])$element %||% character(),
                      c("major.x", "major.y", "minor.x", "minor.y"))
    }
    expect_identical(lapply(output, function(z) ggplot2::ggplot_build(z)$data),
                     lapply(expected, function(z) ggplot2::ggplot_build(z)$data))
    expect_identical(lapply(plots, function(z) z$theme), before)
  }
  if (requireNamespace("ragg", quietly = TRUE)) {
    capture <- function(p) {
      grab <- ragg::agg_capture(width = 360, height = 240, units = "px", res = 96)
      on.exit(grDevices::dev.off())
      print(p)
      grab(native = TRUE)
    }
    output <- fmt_panel(patterns[[1]], grid = "both")
    expected <- lapply(patterns[[1]], fmt_panel, grid = "both")
    for (i in seq_along(output)) {
      expect_identical(capture(output[[i]]), capture(expected[[i]]))
    }
  }
})

test_that("automatic contrast includes grids restored past a blank root line", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot() + ggplot2::theme_void()
  inputs <- list(p, p + ggplot2::theme(
    panel.grid = ggplot2::element_line(linewidth = 0.8, inherit.blank = TRUE)))
  for (input in inputs) {
    before <- input$theme
    output <- fmt_panel(input, grid = "both", bg = "black")
    expect_equal(panel_test_grids(output)$colour, rep("grey85", 4))
    expect_identical(output$theme$line, input$theme$line)
    expect_identical(ggplot2::ggplot_build(output)$data,
                     ggplot2::ggplot_build(input)$data)
    expect_identical(input$theme, before)
    expect_equal(panel_test_grids(fmt_panel(input, grid = "both", bg = "black",
                                            grid_color = "black"))$colour,
                 rep("black", 4))
    expect_equal(panel_test_grids(fmt_panel(input, grid = "both", bg = "black",
      panel.grid = ggplot2::element_line(colour = "black")))$colour,
      rep("black", 4))
    if (requireNamespace("ragg", quietly = TRUE)) {
      capture <- function(p) {
        grab <- ragg::agg_capture(width = 360, height = 240, units = "px", res = 96)
        on.exit(grDevices::dev.off())
        print(p)
        grab(native = TRUE)
      }
      expect_gt(sum(capture(output) != capture(fmt_panel(input, grid = "none",
                                                        bg = "black"))), 0L)
    }
  }
  explicit <- p + ggplot2::theme(panel.grid = ggplot2::element_line(
    colour = "black", linewidth = 0.8, inherit.blank = TRUE))
  expect_equal(panel_test_grids(fmt_panel(explicit, grid = "both", bg = "black"))$colour,
               rep("grey70", 4))
  axis <- p + ggplot2::theme(panel.grid.major.x = ggplot2::element_line(
    colour = "black", inherit.blank = TRUE))
  grids <- panel_test_grids(fmt_panel(axis, grid = "both", bg = "black"))
  expect_equal(grids$colour[grids$element == "major.x"], "grey70")
  expect_equal(grids$colour[grids$element != "major.x"], rep("grey85", 3))
  transparent <- fmt_panel(p, grid = "both", bg = NA,
                           plot.background = ggplot2::element_rect(fill = NA, colour = NA))
  expect_equal(panel_test_grids(transparent)$colour, rep("grey85", 4))
})

test_that("restored grid placeholders respect blank parent grids", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot()
  for (base in list(p, p + ggplot2::theme_void())) {
    for (mode in c("major", "minor")) {
      group <- paste0("panel.grid.", mode)
      for (hidden in c(paste0(group, ".x"), group, "panel.grid")) {
        input <- base + do.call(ggplot2::theme,
          stats::setNames(list(ggplot2::element_blank()), hidden))
        before <- input$theme
        formatted <- fmt_panel(input, grid = mode)
        expect_setequal(panel_test_grids(formatted)$element,
                        paste0(mode, c(".x", ".y")))
        for (parent in c(group, "panel.grid")) {
          args <- stats::setNames(list(ggplot2::element_blank()), parent)
          outputs <- list(formatted + do.call(ggplot2::theme, args),
                          do.call(fmt_panel, c(list(plot = input, grid = mode), args)))
          for (output in outputs) {
            expect_null(panel_test_grids(output))
            expect_identical(ggplot2::ggplot_build(output)$data,
                             ggplot2::ggplot_build(input)$data)
          }
        }
        expect_identical(input$theme, before)
      }
    }
  }
  explicit <- p + ggplot2::theme(panel.grid.major.x = ggplot2::element_line(
    colour = "red", linewidth = 0.6, linetype = "solid", inherit.blank = FALSE))
  output <- fmt_panel(explicit, grid = "major") +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank())
  expect_equal(panel_test_grids(output)$element, "major.x")
  expect_equal(panel_test_grids(output)$colour, "red")
  expect_identical(output$theme$panel.grid.major.x, explicit$theme$panel.grid.major.x)
})

test_that("displayed grids stay visible on matching panel backgrounds", {
  old <- ggplot2::theme_set(ggplot2::theme_gray())
  withr::defer(ggplot2::theme_set(old))
  p <- panel_test_plot()
  expect_equal(panel_test_grids(fmt_panel(p, grid = "major", bg = "white"))$colour,
               rep("grey70", 2))
  grey <- p + ggplot2::theme(panel.grid = ggplot2::element_line(colour = "grey70"))
  expect_equal(panel_test_grids(fmt_panel(grey, grid = "y", bg = "grey70"))$colour, "grey30")
  expect_equal(panel_test_grids(fmt_panel(p, grid = "major"))$colour, rep("white", 2))
  for (extra in list(list(grid_color = "white"),
                    list(panel.grid.major = ggplot2::element_line(colour = "white")),
                    list(panel.grid.major.x = ggplot2::element_line(colour = "white"),
                         panel.grid.major.y = ggplot2::element_line(colour = "white")))) {
    output <- do.call(fmt_panel, c(list(plot = p, grid = "major", bg = "white"), extra))
    expect_equal(panel_test_grids(output)$colour, rep("white", 2))
  }
  void <- fmt_panel(p + ggplot2::theme_void(), grid = "both")
  expect_equal(panel_test_grids(void)$colour, rep("grey85", 4))
  expect_identical(ggplot2::ggplot_build(void)$data, ggplot2::ggplot_build(p)$data)
})

test_that("grid = 'keep' changes the background and border but not the grid", {
  styled <- panel_test_plot() + ggplot2::theme(
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_line(colour = "purple"))
  grid_theme <- function(p) p$theme[grepl("^panel\\.grid", names(p$theme))]
  # Row names follow the grob order, which the border changes.
  grids <- function(p) {
    out <- panel_test_grids(p)
    rownames(out) <- NULL
    out
  }
  for (extra in list(list(), list(grid_color = "red", grid_linewidth = 1))) {
    out <- do.call(fmt_panel, c(list(plot = styled, grid = "keep", bg = "white",
                                     border = TRUE), extra))
    expect_identical(grids(out), grids(styled))
    expect_identical(grid_theme(out), grid_theme(styled))
    expect_identical(ggplot2::calc_element("panel.background",
                                           ggplot2::theme_get() + out$theme)$fill, "white")
    expect_identical(ggplot2::calc_element("panel.border",
                                           ggplot2::theme_get() + out$theme)$colour, "black")
  }
  expect_identical(formals(fmt_panel)$grid,
                   quote(c("none", "major", "minor", "both", "x", "y", "keep")))
  expect_null(panel_test_grids(fmt_panel(styled, bg = "white")))
})
