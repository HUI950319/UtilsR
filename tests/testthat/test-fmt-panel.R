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
