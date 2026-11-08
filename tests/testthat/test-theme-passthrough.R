test_that("theme overrides require unambiguous element names", {
  for (fun in list(function(...) theme_sc(NULL, 12, ...),
                   function(...) theme_blank(FALSE, .15, .15, "", "", 12, ...))) {
    expect_error(fun(!!!list(ggplot2::element_blank())), "named")
    args <- list(panel.grid = ggplot2::element_blank(), panel.grid = ggplot2::element_line())
    expect_error(fun(!!!args), "unique")
  }
  expect_null(theme_sc(panel.grid = NULL)[["panel.grid"]])
})

test_that("base theme constructors reject negative font and line dimensions", {
  for (arg in c("base_size", "base_line_size", "base_rect_size"))
    expect_error(do.call("theme_my", stats::setNames(list(-1), arg)), arg)
  expect_error(theme_alluvia(-1), "base_size")
  expect_error(theme_sc(base_size = -1), "base_size")
  expect_error(theme_blank(lab_size = -1), "lab_size")
  expect_s3_class(theme_my(base_size = 0), "theme")
  expect_s3_class(theme_alluvia(0), "theme")
  expect_s3_class(theme_sc(base_size = 0), "theme")
  expect_type(theme_blank(lab_size = 0, xlen_npc = -.1), "list")
})

test_that("ROC themes validate nonnegative sizes and layout settings", {
  for (arg in c("base_size", "axis_text_size", "axis_title_size", "title_size",
                "subtitle_size", "strip_size", "legend_text_size", "legend_title_size", "axis_linewidth"))
    expect_error(do.call("theme_ROC", stats::setNames(list(-1), arg)), arg)
  expect_error(theme_ROC(legend.position = matrix(c(.2, .8))), "legend.position")
  expect_error(theme_ROC(legend.position = "unknown"), "legend.position")
  expect_error(theme_ROC(plot_margin = c(1, 2, 3, 4)), "plot_margin")
  expect_error(theme_ROC(plot_margin = grid::unit(Inf, "pt")), "plot_margin")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + theme_ROC(legend.position = "none",
    plot_margin = ggplot2::margin(-1, 0, 1, 2), axis_text_size = ggplot2::rel(.9))), "gtable")
})

test_that("legend themes validate active colour and face inputs", {
  for (arg in c("bg_linewidth", "key_linewidth", "key_size", "text_size", "title_size"))
    expect_error(do.call("theme_legend", stats::setNames(list(-1), arg)), arg)
  for (arg in c("bg_fill", "bg_color", "key_fill", "key_color", "text_color", "title_color"))
    for (bad in list(matrix("red"), "not-a-colour"))
      expect_error(do.call("theme_legend", stats::setNames(list(bad), arg)), arg)
  expect_error(theme_legend(text_face = matrix("bold")), "text_face")
  expect_error(theme_legend(title_face = matrix("bold")), "title_face")
  expect_s3_class(theme_legend(show_title = FALSE, title_color = stop("unused"),
    title_face = stop("unused"), bg_fill = NULL), "theme")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x, colour = factor(x))) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + theme_legend(bg_fill = NA, text_color = "red")), "gtable")
})

test_that("prism palette selectors reject positional factor codes and arrays", {
  for (bad in list(factor("black_and_white"), NULL, NA_character_,
                   matrix("black_and_white"), c("black_and_white", "office")))
    expect_error(theme_my(palette = bad), "palette")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + theme_my(palette = "black_and_white")), "gtable")
})

test_that("prism themes validate panel spacing and preserve explicit units", {
  for (bad in list(matrix(1), numeric(), Inf, NA_real_,
                   structure(2, class = "encoded"), grid::unit(Inf, "pt")))
    expect_error(theme_my(panel.spacing = bad), "panel.spacing")
  spacing <- grid::unit(2, "cm")
  expect_identical(theme_my(panel.spacing = spacing)[["panel.spacing"]], spacing)
  relative <- grid::unit(0.5, "lines")
  expect_identical(theme_my(panel.spacing = relative)[["panel.spacing"]], relative)
  expect_equal(as.numeric(theme_my(panel.spacing = 2)[["panel.spacing"]]), 2)
})

test_that("alluvial themes reject invalid base sizes before family evaluation", {
  for (bad in list(NA_real_, Inf, numeric(), c(10, 12), matrix(12),
                   structure(12, class = "encoded_number")))
    expect_error(theme_alluvia(base_size = bad, base_family = stop("family evaluated")), "base_size")
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + theme_alluvia(12)), "gtable")
})

test_that("single-cell themes validate sizes and aspect ratios before overrides", {
  for (bad in list(NA_real_, Inf, numeric(), c(10, 12), matrix(12),
                   structure(12, class = "encoded_number")))
    expect_error(theme_sc(base_size = bad, plot.title = stop("override evaluated")), "base_size")
  for (bad in list(NA_real_, Inf, 0, -1, c(1, 2), matrix(1),
                   structure(1, class = "encoded_number")))
    expect_error(theme_sc(aspect.ratio = bad, plot.title = stop("override evaluated")), "aspect.ratio")
  expect_equal(theme_sc(aspect.ratio = 1.5)$aspect.ratio, 1.5)
})

test_that("ROC themes validate scalar dimensions and retain relative text sizes", {
  withr::local_options(lifecycle_verbosity = "quiet")
  for (arg in c("base_size", "axis_text_size", "axis_title_size", "title_size",
                "subtitle_size", "strip_size", "legend_text_size", "legend_title_size", "axis_linewidth"))
    for (bad in list(NA_real_, Inf, numeric(), c(1, 2), matrix(1),
                     structure(1, class = "encoded_number"))) {
      args <- stats::setNames(list(bad), arg)
      expect_error(do.call("theme_ROC", args), arg)
    }
  p <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + theme_ROC(axis_text_size = ggplot2::rel(1.1))), "gtable")
})

test_that("legend themes validate dimensions and keep hidden titles lazy", {
  for (arg in c("bg_linewidth", "key_linewidth", "key_size", "text_size", "title_size", "spacing"))
    for (bad in list(NA_real_, Inf, numeric(), c(1, 2), matrix(1),
                     structure(1, class = "encoded_number")))
      expect_error(do.call("theme_legend", stats::setNames(list(bad), arg)), arg)
  for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE)))
    expect_error(theme_legend(show_title = bad), "show_title")
  for (bad in list(1, rep(NA_real_, 4), matrix(1, 4), rep(Inf, 4)))
    expect_error(theme_legend(margin = bad), "margin")
  expect_s3_class(theme_legend(show_title = FALSE, title_size = stop("title evaluated"),
    text_size = ggplot2::rel(1.2), margin = c(-1, 0, 1, 2)), "theme")
})

test_that("theme_sc preserves registered extension theme elements", {
  nest_line <- ggplot2::element_line(colour = "firebrick", linewidth = 2)
  thm <- theme_sc(ggh4x.facet.nestline = nest_line)
  expect_identical(thm[["ggh4x.facet.nestline"]], nest_line)

  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + thm), "gtable")
})

test_that("theme_blank preserves registered elements with and without arrows", {
  nest_line <- ggplot2::element_line(colour = "navy", linewidth = 2)
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  for (add_coord in c(FALSE, TRUE)) {
    out <- p + theme_blank(add_coord = add_coord,
                           ggh4x.facet.nestline = nest_line)
    expect_identical(out$theme[["ggh4x.facet.nestline"]], nest_line)
    expect_s3_class(ggplot2::ggplotGrob(out), "gtable")
  }
})

test_that("theme_sc accepts dynamically supplied extension elements", {
  nest_line <- ggplot2::element_line(colour = "firebrick", linewidth = 2)
  theme_args <- list(ggh4x.facet.nestline = nest_line)
  element_name <- "ggh4x.facet.nestline"

  spliced <- theme_sc(NULL, 12, !!!theme_args)
  expect_identical(spliced[[element_name]], nest_line)
  named <- theme_sc(NULL, 12, !!element_name := nest_line)
  expect_identical(named[[element_name]], nest_line)
})

test_that("theme_blank accepts dynamically supplied extension elements", {
  nest_line <- ggplot2::element_line(colour = "navy", linewidth = 2)
  theme_args <- list(ggh4x.facet.nestline = nest_line)
  element_name <- "ggh4x.facet.nestline"
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  spliced <- p + theme_blank(FALSE, 0.15, 0.15, "", "", 12, !!!theme_args)
  expect_identical(spliced$theme[[element_name]], nest_line)
  named <- p + theme_blank(TRUE, 0.15, 0.15, "", "", 12,
                           !!element_name := nest_line)
  expect_identical(named$theme[[element_name]], nest_line)
})

test_that("theme_sc evaluates forwarded extension expressions once", {
  nest_line <- ggplot2::element_line(colour = "firebrick")
  calls <- 0L
  make_line <- function() {
    calls <<- calls + 1L
    nest_line
  }
  forward <- function(...) theme_sc(...)

  thm <- forward(ggh4x.facet.nestline = make_line())
  expect_identical(thm[["ggh4x.facet.nestline"]], nest_line)
  expect_identical(calls, 1L)
})

test_that("theme_blank evaluates forwarded extension expressions once", {
  nest_line <- ggplot2::element_line(colour = "navy")
  calls <- 0L
  make_line <- function() {
    calls <<- calls + 1L
    nest_line
  }
  forward <- function(...) theme_blank(add_coord = FALSE, ...)
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  out <- p + forward(ggh4x.facet.nestline = make_line())
  expect_identical(out$theme[["ggh4x.facet.nestline"]], nest_line)
  expect_identical(calls, 1L)
})

test_that("theme_sc preserves blank extension elements and default overrides", {
  blank <- ggplot2::element_blank()
  key_size <- grid::unit(4, "mm")
  thm <- theme_sc(ggh4x.facet.nestline = blank, axis.text = blank,
                  legend.key.size = key_size, legend.position = "bottom")

  expect_identical(thm[["ggh4x.facet.nestline"]], blank)
  expect_identical(thm$axis.text, blank)
  expect_identical(thm$legend.key.size, key_size)
  expect_identical(thm$legend.position, "bottom")
})

test_that("theme_blank preserves blank extension elements and default overrides", {
  blank <- ggplot2::element_blank()
  key_size <- grid::unit(4, "mm")
  plot_margin <- ggplot2::margin(1, 2, 3, 4)
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  out <- p + theme_blank(ggh4x.facet.nestline = blank,
                         legend.key.size = key_size, plot.margin = plot_margin,
                         legend.position = "bottom")

  expect_identical(out$theme[["ggh4x.facet.nestline"]], blank)
  expect_identical(out$theme$legend.key.size, key_size)
  expect_identical(out$theme$plot.margin, plot_margin)
  expect_identical(out$theme$legend.position, "bottom")
})

theme_passthrough_nested_colours <- function(modifier) {
  d <- expand.grid(batch = c("A", "B"), group = c("C", "D"), x = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, x)) + ggplot2::geom_point() +
    ggh4x::facet_nested(~ batch + group, nest_line = TRUE)
  collect_colours <- function(grob) {
    children <- c(grob$grobs, as.list(grob$children))
    c(grob$gp$col, unlist(lapply(children, collect_colours), use.names = FALSE))
  }
  collect_colours(ggplot2::ggplotGrob(p + modifier))
}

test_that("theme_sc extension elements control nested facet drawing", {
  colours <- theme_passthrough_nested_colours(
    theme_sc(ggh4x.facet.nestline = ggplot2::element_line(colour = "#AE12F4"))
  )
  expect_gt(sum(colours == "#AE12F4", na.rm = TRUE), 0)
})

test_that("theme_blank extension elements control nested facet drawing", {
  for (add_coord in c(FALSE, TRUE)) {
    colours <- theme_passthrough_nested_colours(
      theme_blank(add_coord = add_coord,
                  ggh4x.facet.nestline = ggplot2::element_line(colour = "#AE12F4"))
    )
    expect_gt(sum(colours == "#AE12F4", na.rm = TRUE), 0)
  }
})

test_that("theme_my diagnoses invalid numeric sizing and angle controls", {
  for (arg in c("base_size", "base_line_size", "base_rect_size")) {
    for (bad in list(NA_real_, Inf, c(1, 2), matrix(1), structure(1, class = "integer64"))) {
      args <- list(palette = quote(stop("palette evaluated")))
      args[arg] <- list(bad)
      expect_error(do.call(theme_my, args), arg)
    }
  }
  for (bad in list(NULL, c(0, 45), NA_real_, matrix(0))) {
    expect_error(theme_my(axis_text_angle = bad), "axis_text_angle")
  }
  for (bad in list(c(1, NA, 2, 3), Inf, matrix(1))) {
    expect_error(theme_my(plot.margin = bad), "plot.margin")
  }
  for (angle in c(0, 45, 90, 270)) {
    expect_s3_class(theme_my(axis_text_angle = angle, plot.margin = c(-1, 0, 1, 2)), "theme")
  }
})

test_that("theme_blank validates arrow controls and preserves disabled-arrow laziness", {
  for (bad in list(NULL, NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
    expect_error(theme_blank(add_coord = bad), "add_coord")
  }
  for (arg in c("xlen_npc", "ylen_npc", "lab_size")) {
    for (bad in list(NA_real_, Inf, c(1, 2), matrix(1), structure(1, class = "integer64"))) {
      args <- list()
      args[arg] <- list(bad)
      expect_error(do.call(theme_blank, args), arg)
    }
  }
  expect_type(theme_blank(add_coord = FALSE, xlen_npc = stop("length evaluated"),
                           ylen_npc = stop("length evaluated")), "list")
})

test_that("legend factor colours draw their labels rather than palette indices", {
  color <- factor("red", levels = c("blue", "red"))
  fields <- list(bg_fill = c("legend.background", "fill"), bg_color = c("legend.background", "colour"), key_fill = c("legend.key", "fill"), key_color = c("legend.key", "colour"), text_color = c("legend.text", "colour"), title_color = c("legend.title", "colour"))
  for (arg in names(fields)) {
    theme <- do.call(theme_legend, stats::setNames(list(color), arg))
    expect_identical(theme[[fields[[arg]][1L]]][[fields[[arg]][2L]]], "red")
  }
  expect_identical(theme_legend(bg_fill = 2)$legend.background$fill, 2)
  skip_if_not_installed("ragg")
  draw <- function(fill) {
    capture <- ragg::agg_capture(width = 20, height = 20, units = "px", background = "white")
    on.exit(grDevices::dev.off())
    theme <- theme_legend(bg_fill = fill)
    grid::grid.draw(ggplot2::element_grob(theme$legend.background))
    capture()[10L, 10L]
  }
  expect_identical(draw(color), draw("red"))
})
