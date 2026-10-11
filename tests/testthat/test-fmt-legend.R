legend_test_plot <- function(continuous = FALSE) {
  d <- data.frame(x = 1:6, y = c(2, 4, 3, 5, 4, 6),
                  group = factor(rep(c("a", "b", "c"), 2)), value = 1:6)
  mapping <- if (continuous) ggplot2::aes(x, y, colour = value) else
    ggplot2::aes(x, y, colour = group)
  ggplot2::ggplot(d, mapping) + ggplot2::geom_point()
}

legend_test_labels <- function(g) {
  labels <- if (inherits(g, "text")) as.character(g$label) else character()
  children <- if (inherits(g, "gtable")) g$grobs else g$children
  c(labels, unlist(lapply(children, legend_test_labels), use.names = FALSE))
}

test_that("legend titles cover default scales and layer mappings", {
  p <- legend_test_plot()
  changed <- fmt_legend(p, title = "New group")
  labels <- legend_test_labels(ggplot2::ggplotGrob(changed))
  expect_true("New group" %in% labels)
  expect_false("group" %in% labels)
  expect_true("group" %in% legend_test_labels(ggplot2::ggplotGrob(p)))
  expect_identical(ggplot2::ggplot_build(p)$data,
                   ggplot2::ggplot_build(changed)$data)
  layer_plot <- ggplot2::ggplot(p$data, ggplot2::aes(x, y)) +
    ggplot2::geom_point(ggplot2::aes(shape = group))
  expect_true("Layer group" %in% legend_test_labels(
    ggplot2::ggplotGrob(fmt_legend(layer_plot, title = "Layer group"))))
})

test_that("legend title updates leave shared scales and guides unchanged", {
  guide <- ggplot2::guide_legend(title = "Guide title", reverse = TRUE)
  sc <- ggplot2::scale_colour_discrete(name = "Scale title", guide = guide)
  original <- legend_test_plot() + sc
  sibling <- legend_test_plot() + sc
  changed <- fmt_legend(original, title = "Replacement")
  expect_identical(sc$name, "Scale title")
  expect_identical(original$scales$scales[[1]]$name, "Scale title")
  expect_identical(sibling$scales$scales[[1]]$name, "Scale title")
  expect_identical(guide$params$title, "Guide title")
  expect_true(changed$scales$scales[[1]]$guide$params$reverse)
  expect_true("Replacement" %in% legend_test_labels(ggplot2::ggplotGrob(changed)))
  expect_true("Guide title" %in% legend_test_labels(ggplot2::ggplotGrob(original)))
  explicit <- original + ggplot2::guides(colour = guide)
  output <- fmt_legend(explicit, title = "Explicit guide")
  expect_true("Explicit guide" %in% legend_test_labels(ggplot2::ggplotGrob(output)))
  expect_identical(explicit$guides$guides$colour$params$title, "Guide title")
})

test_that("legend titles recycle across editable nested plots", {
  p <- legend_test_plot()
  nested <- (p | patchwork::plot_spacer()) / (p | p)
  output <- fmt_legend(nested, title = c("First", "Second"))
  leaves <- .to_plot_list(output, recurse = TRUE)$plots
  expect_identical(vapply(leaves, function(x) x$labels$colour, character(1)),
                   c("First", "Second", "First"))
  expect_identical(output$patches$layout, nested$patches$layout)
  named <- fmt_legend(list(left = p, right = p), title = c("Left", "Right"))
  expect_identical(names(named), c("left", "right"))
  expect_true("Left" %in% legend_test_labels(ggplot2::ggplotGrob(named$left)))
})

test_that("legend formatting retains continuous and binned guide types", {
  controls <- list(list(scale = 0.8), list(ncol = 2),
                   list(legend_theme = ggplot2::theme(legend.title = ggplot2::element_blank())))
  for (p in list(legend_test_plot(TRUE), legend_test_plot(TRUE) +
                 ggplot2::scale_colour_steps())) {
    before <- ggplot2::ggplot_build(p)$plot$guides$guides[[1]]
    for (args in controls) {
      changed <- do.call(fmt_legend, c(list(plot = p), args))
      after <- ggplot2::ggplot_build(changed)$plot$guides$guides[[1]]
      expect_identical(class(after), class(before))
      expect_no_error(ggplot2::ggplotGrob(changed))
    }
  }
})

test_that("legend dimensions preserve discrete guides and disabled guides", {
  for (continuous in c(FALSE, TRUE)) {
    p <- legend_test_plot(continuous)
    before <- ggplot2::ggplot_build(p)$plot$guides$guides[[1]]
    changed <- fmt_legend(p, scale_width = 1.5, scale_height = 0.5)
    expect_warning(g <- ggplot2::ggplotGrob(changed), NA)
    expect_true(any(grepl("^guide-box", g$layout$name) &
                      vapply(g$grobs, inherits, logical(1), "gtable")))
    expect_identical(class(ggplot2::ggplot_build(changed)$plot$guides$guides[[1]]),
                     class(before))
    hidden_scale <- if (continuous) ggplot2::scale_colour_continuous(guide = "none") else
      ggplot2::scale_colour_discrete(guide = "none")
    for (hidden in list(p + ggplot2::guides(colour = "none"), p + hidden_scale)) {
      output <- fmt_legend(hidden, scale = 0.8, ncol = 2)
      expect_length(ggplot2::ggplot_build(output)$plot$guides$guides, 0L)
    }
  }
})

test_that("guide formatting defers data callbacks and retains later guide edits", {
  calls <- 0L
  p <- ggplot2::ggplot(mapping = ggplot2::aes(x, y, colour = value)) +
    ggplot2::geom_point(data = function(x) {
      calls <<- calls + 1L
      data.frame(x = 1:4, y = 4:1, value = 1:4)
    })
  set.seed(14)
  rng <- .Random.seed
  result <- fmt_legend(p, scale = 0.8, ncol = 2)
  expect_identical(calls, 0L)
  expect_identical(.Random.seed, rng)
  expect_s3_class(ggplot2::ggplot_build(result)$plot$guides$guides[[1]], "GuideColourbar")
  expect_identical(calls, 1L)
  hidden <- result + ggplot2::guides(colour = "none")
  expect_length(ggplot2::ggplot_build(hidden)$plot$guides$guides, 0L)
})

test_that("legend glyph scaling supports old and current guide callbacks", {
  output <- fmt_legend(legend_test_plot(), scale = 0.8)
  callback <- output$guides$.fmt_legend_process_keys[[1L]]
  for (method in list(function(self, params, layers, data = NULL) params,
                      function(self, params, layers, data = NULL, theme = NULL) params)) {
    native <- ggplot2::ggproto(NULL, ggplot2::GuideLegend, process_layers = method)
    self <- ggplot2::ggproto(NULL, native, .fmt_legend_source = native,
                            .fmt_legend_scale = 0.8)
    params <- list(decor = list(list(data = data.frame(size = 4))))
    expect_equal(callback(self, params, list())$decor[[1L]]$data$size, 3.2)
  }
})

legend_test_box_size <- function(p) {
  g <- ggplot2::ggplotGrob(p)
  index <- which(grepl("^guide-box", g$layout$name) &
                   vapply(g$grobs, inherits, logical(1), "gtable"))[1]
  box <- g$grobs[[index]]
  c(width = grid::convertWidth(sum(box$widths), "mm", valueOnly = TRUE),
    height = grid::convertHeight(sum(box$heights), "mm", valueOnly = TRUE))
}

test_that("later native legend layout edits override earlier formatting", {
  p <- legend_test_plot()
  earlier <- ggplot2::guide_legend(ncol = 1, reverse = TRUE)
  input <- p + ggplot2::guides(colour = earlier)
  changed <- fmt_legend(input, ncol = 2)
  expect_equal(ggplot2::ggplot_build(changed)$plot$guides$params[[1L]]$ncol, 2)
  expect_equal(earlier$params$ncol, 1)
  for (replacement in list(ggplot2::guide_legend(ncol = 3),
                           ggplot2::guide_legend(nrow = 1), ggplot2::guide_legend())) {
    for (input in list(p, p + ggplot2::guides(colour = earlier),
                       p + ggplot2::scale_colour_discrete(guide = earlier))) {
      formatted <- fmt_legend(input, ncol = 2, nrow = 2) +
        ggplot2::guides(colour = replacement)
      params <- ggplot2::ggplot_build(formatted)$plot$guides$params[[1L]]
      expect_identical(params$ncol, replacement$params$ncol)
      expect_identical(params$nrow, replacement$params$nrow)
      expect_equal(legend_test_box_size(formatted),
                   legend_test_box_size(input + ggplot2::guides(colour = replacement)))
    }
  }
  changed <- fmt_legend(p, ncol = 2, scale = 0.5) +
    ggplot2::scale_colour_discrete(guide = ggplot2::guide_legend(ncol = 3))
  expect_equal(ggplot2::ggplot_build(changed)$plot$guides$params[[1L]]$ncol, 3)
})

test_that("legend formatting leaves explicit axis guides untouched", {
  axis <- ggplot2::guide_axis(angle = 45,
    theme = ggplot2::theme(axis.text.x = ggplot2::element_text(size = 10)))
  p <- legend_test_plot() + ggplot2::guides(x = axis, y = ggplot2::guide_axis())
  axes <- function(p) {
    g <- ggplot2::ggplotGrob(p)
    lapply(g$grobs[grepl("^axis-", g$layout$name)], legend_test_labels)
  }
  before <- axes(p)
  for (args in list(list(legend.position = "right"), list(legend.position = "none"),
                   list(legend.direction = "horizontal"), list(scale = 0.8),
                   list(scale_width = 1.2, scale_height = 0.7))) {
    expect_no_error(output <- do.call(fmt_legend, c(list(plot = p), args)))
    expect_identical(output$guides$guides$x, p$guides$guides$x)
    expect_identical(output$guides$guides$y, p$guides$guides$y)
    expect_warning(after <- axes(output), NA)
    expect_identical(after, before)
  }
})

test_that("legend scaling retains units and scale one preserves rendered size", {
  for (unit in list(grid::unit(4, "mm"), grid::unit(0.4, "cm"),
                    grid::unit(10, "pt"), grid::unit(0.8, "lines"),
                    grid::unit(3, "mm") + grid::unit(1, "pt"))) {
    p <- legend_test_plot() + ggplot2::theme(legend.key.size = unit,
      legend.box.spacing = grid::unit(8, "mm"),
      legend.spacing = grid::unit(7, "pt"))
    output <- fmt_legend(p, scale = 1)
    expect_equal(grid::convertWidth(output$theme$legend.key.size, "mm", valueOnly = TRUE),
                 grid::convertWidth(unit, "mm", valueOnly = TRUE))
    expect_equal(grid::convertWidth(output$theme$legend.box.spacing, "mm", valueOnly = TRUE), 8)
    expect_equal(legend_test_box_size(output), legend_test_box_size(p))
  }
})

test_that("independent legend dimensions multiply existing and global sizes", {
  p <- legend_test_plot() + ggplot2::theme(legend.key.width = grid::unit(4, "mm"),
    legend.key.height = grid::unit(8, "mm"))
  for (args in list(list(scale_width = 1, scale_height = 1),
                    list(scale_width = 2, scale_height = 0.5),
                    list(scale = 0.5, scale_width = 2, scale_height = 0.5))) {
    output <- do.call(fmt_legend, c(list(plot = p), args))
    factor <- if (is.null(args$scale)) 1 else args$scale
    expect_equal(grid::convertWidth(output$theme$legend.key.width, "mm", valueOnly = TRUE),
                 4 * factor * args$scale_width)
    expect_equal(grid::convertHeight(output$theme$legend.key.height, "mm", valueOnly = TRUE),
                 8 * factor * args$scale_height)
    expect_no_error(ggplot2::ggplotGrob(output))
  }
})

test_that("legend scaling uses each subplot and the newly applied theme", {
  p <- legend_test_plot()
  plots <- list(p + ggplot2::theme(legend.text = ggplot2::element_text(size = 10),
                                  legend.key.width = grid::unit(4, "mm")),
                p + ggplot2::theme(legend.text = ggplot2::element_text(size = 20),
                                  legend.key.width = grid::unit(8, "mm")))
  for (input in list(plots, plots[[1]] | plots[[2]])) {
    output <- fmt_legend(input, scale = 0.5)
    leaves <- .to_plot_list(output, recurse = TRUE)$plots
    expect_equal(vapply(leaves, function(x) x$theme$legend.text$size, numeric(1)), c(5, 10))
    expect_equal(vapply(leaves, function(x) grid::convertWidth(
      x$theme$legend.key.width, "mm", valueOnly = TRUE), numeric(1)), c(2, 4))
  }
  output <- fmt_legend(p, legend_theme = ggplot2::theme(
    legend.text = ggplot2::element_text(size = 20, colour = "red")), scale = 0.5)
  expect_equal(output$theme$legend.text$size, 10)
  expect_identical(output$theme$legend.text$colour, "red")
  collected <- fmt_legend(plots[[1]] | plots[[2]], collect = TRUE, scale = 0.5,
                          legend_theme = ggplot2::theme(legend.text = ggplot2::element_text(size = 20)))
  expect_equal(vapply(.to_plot_list(collected, recurse = TRUE)$plots,
                      function(x) x$theme$legend.text$size, numeric(1)), c(10, 10))
  expect_no_error(patchwork::patchworkGrob(collected))
})

test_that("legend scaling retains blank text and title elements", {
  p <- legend_test_plot() + ggplot2::theme(legend.title = ggplot2::element_blank())
  output <- fmt_legend(p, scale = 0.5)
  expect_s3_class(output$theme$legend.title, "element_blank")
  expect_false("group" %in% legend_test_labels(ggplot2::ggplotGrob(output)))
  blank <- fmt_legend(legend_test_plot(), scale = 0.5, legend_theme = ggplot2::theme(
    legend.title = ggplot2::element_blank(), legend.text = ggplot2::element_blank()))
  expect_s3_class(blank$theme$legend.text, "element_blank")
  expect_false(any(c("group", "a", "b", "c") %in% legend_test_labels(ggplot2::ggplotGrob(blank))))
})

test_that("legend controls merge guide settings and scale displayed key sizes", {
  p <- legend_test_plot()
  guide <- ggplot2::guide_legend(order = 3, reverse = TRUE,
    override.aes = list(alpha = 0.3, shape = 17, size = 5))
  input <- p + ggplot2::guides(colour = guide)
  output <- fmt_legend(input, scale = 0.5, ncol = 2)
  built <- ggplot2::ggplot_build(output)
  params <- built$plot$guides$params[[1]]
  expect_identical(params$order, 3L)
  expect_true(params$reverse)
  expect_equal(params$ncol, 2)
  expect_equal(params$decor[[1]]$data$size, rep(2.5, 3))
  expect_equal(params$decor[[1]]$data$alpha, rep(0.3, 3))
  expect_equal(params$decor[[1]]$data$shape, rep(17, 3))
  expect_identical(guide$params$override.aes, list(alpha = 0.3, shape = 17, size = 5))
  repeated <- fmt_legend(output, scale = 0.5)
  expect_equal(ggplot2::ggplot_build(repeated)$plot$guides$params[[1]]$decor[[1]]$data$size,
               rep(1.25, 3))
  sized <- p + ggplot2::aes(size = value)
  before <- ggplot2::ggplot_build(sized)$plot$guides$params
  after <- ggplot2::ggplot_build(fmt_legend(sized, scale = 0.5, ncol = 2))$plot$guides$params
  for (i in seq_along(before)) {
    expect_equal(after[[i]]$decor[[1]]$data$size, before[[i]]$decor[[1]]$data$size * 0.5)
  }
  expect_identical(ggplot2::ggplot_build(input)$data, built$data)
})

test_that("legend formatting overrides and scales local guide themes safely", {
  p <- legend_test_plot()
  guide <- ggplot2::guide_legend(direction = "vertical", position = "right",
    theme = ggplot2::theme(legend.text = ggplot2::element_text(size = 25, colour = "red"),
                          legend.key.width = grid::unit(8, "mm"),
                          legend.key.height = grid::unit(4, "mm")))
  for (input in list(p + ggplot2::guides(colour = guide),
                    p + ggplot2::scale_colour_discrete(guide = guide))) {
    output <- fmt_legend(input, legend.position = "bottom", legend.direction = "horizontal",
                          legend.text = ggplot2::element_text(size = 8),
                          scale = 0.5, scale_width = 0.5)
    built <- ggplot2::ggplot_build(output)
    params <- built$plot$guides$guides[[1]]$params
    expect_equal(params$theme$legend.text$size, 4)
    expect_identical(params$theme$legend.text$colour, "red")
    expect_equal(grid::convertWidth(params$theme$legend.key.width, "mm", valueOnly = TRUE), 2)
    expect_equal(grid::convertHeight(params$theme$legend.key.height, "mm", valueOnly = TRUE), 2)
    expect_identical(params$direction, "horizontal")
    expect_identical(params$position, "bottom")
    expect_no_error(ggplot2::ggplotGrob(output))
  }
  expect_equal(guide$params$theme$legend.text$size, 25)
  hidden <- fmt_legend(p + ggplot2::guides(colour = guide), legend.position = "none")
  expect_false(any(c("group", "a", "b", "c") %in%
                     legend_test_labels(ggplot2::ggplotGrob(hidden))))
})

test_that("continuous guide local dimensions and hidden titles retain their semantics", {
  guide <- ggplot2::guide_colourbar(theme = ggplot2::theme(
    legend.key.width = grid::unit(8, "mm"), legend.key.height = grid::unit(20, "mm"),
    legend.title = ggplot2::element_blank()))
  p <- legend_test_plot(TRUE) + ggplot2::guides(colour = guide)
  unchanged <- fmt_legend(p, scale = 1)
  expect_equal(legend_test_box_size(unchanged), legend_test_box_size(p))
  output <- fmt_legend(p, scale = 0.5, scale_height = 2)
  params <- ggplot2::ggplot_build(output)$plot$guides$guides[[1]]$params
  expect_equal(grid::convertWidth(params$theme$legend.key.width, "mm", valueOnly = TRUE), 4)
  expect_equal(grid::convertHeight(params$theme$legend.key.height, "mm", valueOnly = TRUE), 20)
  expect_s3_class(params$theme$legend.title, "element_blank")
  expect_no_error(ggplot2::ggplotGrob(output))
})

test_that("legend inputs fail clearly before changing any input objects", {
  p <- legend_test_plot() + ggplot2::scale_colour_discrete(name = "Original")
  bad <- list(legend.position = list(NA_character_, "bad", c("top", "bottom"),
                                   c(NA_real_, 0.2), c(-0.1, 0.2), c(0, Inf), 0.5),
              legend.direction = list(NA_character_, c("vertical", "horizontal"), "bad"),
              legend_theme = list(list(legend.text = "bad"), "bad"),
              collect = list(NA, c(TRUE, FALSE), 1), title = list(character(), NA_character_, 1),
              scale = list(0, -1, NA_real_, Inf, c(1, 2), "bad"),
              scale_width = list(0, -1, NA_real_, Inf, c(1, 2), "bad"),
              scale_height = list(0, -1, NA_real_, Inf, c(1, 2), "bad"),
              ncol = list(0, -1, NA_real_, Inf, 1.5, c(1, 2), "bad"),
              nrow = list(0, -1, NA_real_, Inf, 1.5, c(1, 2), "bad"))
  for (name in names(bad)) {
    for (value in bad[[name]]) {
      args <- list(plot = p, title = "Replacement")
      args[name] <- list(value)
      expect_error(do.call(fmt_legend, args), name)
      expect_identical(p$scales$scales[[1]]$name, "Original")
    }
  }
  expect_no_error(fmt_legend(p, title = ""))
})

test_that("inside legend coordinates use the current theme interface", {
  p <- legend_test_plot()
  for (position in list("br", "bl", "tr", "tl", c(0, 1), c(0.5, 0.5))) {
    expect_warning(output <- fmt_legend(p, legend.position = position), NA)
    expect_identical(output$theme$legend.position, "inside")
    expect_length(output$theme$legend.position.inside, 2L)
    expect_length(output$theme$legend.justification.inside, 2L)
    expect_no_error(ggplot2::ggplotGrob(output))
  }
})

test_that("legend collection preserves list returns and supports a guide area", {
  p <- legend_test_plot()
  expect_warning(output <- fmt_legend(list(left = p, right = p), collect = TRUE), "patchwork")
  expect_identical(names(output), c("left", "right"))
  expect_type(output, "list")
  expect_false(inherits(output, "patchwork"))
  input <- p | patchwork::guide_area()
  collected <- fmt_legend(input, collect = TRUE)
  expect_identical(collected$patches$layout$guides, "collect")
  expect_no_error(patchwork::patchworkGrob(collected))
  same <- fmt_legend(p | p, collect = TRUE)
  different <- fmt_legend(p | (p + ggplot2::labs(colour = "Other")), collect = TRUE)
  count <- function(x) {
    g <- patchwork::patchworkGrob(x)
    box <- g$grobs[[which(g$layout$name == "guide-box")]]
    sum(box$layout$name == "guides")
  }
  expect_identical(count(same), 1L)
  expect_identical(count(different), 2L)
})

test_that("legend styling updates existing nested collection themes and retains layouts", {
  p <- legend_test_plot()
  child <- (p | p) + patchwork::plot_layout(guides = "collect") +
    patchwork::plot_annotation(theme = ggplot2::theme(legend.position = "right"))
  input <- (child / p) + patchwork::plot_layout(guides = "keep") +
    patchwork::plot_annotation(title = "Keep title", tag_levels = "A")
  output <- fmt_legend(input, legend.position = "bottom")
  expect_identical(output$patches$layout, input$patches$layout)
  expect_identical(output$patches$annotation$title, "Keep title")
  expect_identical(output$patches$annotation$tag_levels, "A")
  expect_identical(output[[1]]$patches$annotation$theme$legend.position, "bottom")
  expect_no_error(patchwork::patchworkGrob(output))
  named <- fmt_legend(list(nested = child, single = p), legend.position = "bottom")
  expect_identical(names(named), c("nested", "single"))
  expect_identical(named$nested$patches$annotation$theme$legend.position, "bottom")
  hidden <- fmt_legend(child, legend.position = "none")
  expect_false(any(c("group", "a", "b", "c") %in%
                     legend_test_labels(patchwork::patchworkGrob(hidden))))
  freed <- patchwork::free(input, side = "l")
  result <- fmt_legend(freed, collect = TRUE, legend.position = "bottom")
  expect_identical(attr(result, "patchwork_free_settings"), attr(freed, "patchwork_free_settings"))
  expect_no_error(patchwork::patchworkGrob(result))
})

test_that("legend calls without formatting retain exact objects and validate containers", {
  p <- legend_test_plot()
  nested <- ((p | patchwork::guide_area()) / (p | patchwork::plot_spacer())) +
    patchwork::plot_layout(guides = "collect") +
    patchwork::plot_annotation(title = "Keep title", tag_levels = "A")
  for (input in list(p, nested, patchwork::free(nested, side = "l"),
                     list(left = p, nested = nested), list())) {
    expect_true(identical(fmt_legend(input), input))
    expect_true(identical(fmt_legend(input, legend.position = NULL, scale = NULL,
                                    collect = FALSE), input))
  }
  expect_error(fmt_legend(1), "Input")
  expect_error(fmt_legend(list(good = p, bad = "bad")), "ggplot")
})

test_that("local guide scaling follows its own position", {
  for (continuous in c(FALSE, TRUE)) {
    for (position in c("top", "bottom", "left", "right")) {
      guide <- if (continuous) ggplot2::guide_colourbar(position = position,
        theme = ggplot2::theme()) else ggplot2::guide_legend(position = position,
        theme = ggplot2::theme())
      input <- legend_test_plot(continuous) + ggplot2::guides(colour = guide)
      output <- fmt_legend(input, scale = 1)
      expect_equal(legend_test_box_size(output), legend_test_box_size(input))
      expect_identical(ggplot2::ggplot_build(output)$plot$guides$guides[[1]]$params$position,
                       position)
    }
  }
  guide <- ggplot2::guide_colourbar(position = "bottom", direction = "vertical",
                                   theme = ggplot2::theme())
  input <- legend_test_plot(TRUE) + ggplot2::guides(colour = guide)
  expect_equal(legend_test_box_size(fmt_legend(input, scale = 1)),
               legend_test_box_size(input))
})

test_that("scaled local guides adapt automatic dimensions after position changes", {
  for (continuous in c(FALSE, TRUE)) {
    guide <- if (continuous) ggplot2::guide_colourbar else ggplot2::guide_legend
    input <- legend_test_plot(continuous) + ggplot2::guides(
      colour = guide(position = "bottom", theme = ggplot2::theme()))
    for (factor in c(1, 0.5, 1.5)) {
      after <- fmt_legend(fmt_legend(input, scale = factor), legend.position = "right")
      expected <- fmt_legend(input, legend.position = "right", scale = factor)
      expect_equal(legend_test_box_size(after), legend_test_box_size(expected))
      expect_identical(ggplot2::ggplot_build(after)$data, ggplot2::ggplot_build(input)$data)
      restored <- fmt_legend(after, legend.position = "bottom")
      expect_equal(legend_test_box_size(restored),
                   legend_test_box_size(fmt_legend(input, scale = factor)))
    }
    fixed <- legend_test_plot(continuous) + ggplot2::guides(colour = guide(
      position = "bottom", theme = ggplot2::theme(legend.key.width = grid::unit(8, "mm"),
        legend.key.height = grid::unit(4, "mm"), legend.text = ggplot2::element_text(size = 12))))
    after <- fmt_legend(fmt_legend(fixed, scale = 0.5), legend.position = "right")
    expect_equal(legend_test_box_size(after),
                 legend_test_box_size(fmt_legend(fixed, scale = 0.5, legend.position = "right")))
  }
})

test_that("inside legends survive requested and existing collection", {
  p <- legend_test_plot()
  for (position in list("br", "inside", c(0.9, 0.1))) {
    expect_warning(output <- fmt_legend(p | p, collect = TRUE,
                                         legend.position = position), "inside.*keep")
    expect_identical(output$patches$layout$guides, "keep")
    expect_equal(sum(legend_test_labels(patchwork::patchworkGrob(output)) == "group"), 2)
  }
  expect_warning(output <- fmt_legend(p | p, collect = TRUE,
    legend_theme = ggplot2::theme(legend.position = "inside")), "inside.*keep")
  expect_equal(sum(legend_test_labels(patchwork::patchworkGrob(output)) == "group"), 2)
  inside <- p + ggplot2::theme(legend.position = "inside")
  expect_warning(mixed <- fmt_legend(inside | p, collect = TRUE), "inside.*keep")
  expect_equal(sum(legend_test_labels(patchwork::patchworkGrob(mixed)) == "group"), 2)
  local <- p + ggplot2::guides(colour = ggplot2::guide_legend(position = "inside"))
  expect_warning(output <- fmt_legend(local | p, collect = TRUE), "inside.*keep")
  expect_equal(sum(legend_test_labels(patchwork::patchworkGrob(output)) == "group"), 2)
  child <- (p | p) + patchwork::plot_layout(guides = "collect")
  nested <- (child / p) + patchwork::plot_layout(guides = "collect") +
    patchwork::plot_annotation(title = "Keep title", tag_levels = "A")
  expect_warning(output <- fmt_legend(nested, legend.position = "br"), "inside.*keep")
  expect_identical(output$patches$layout$guides, "keep")
  expect_identical(output[[1]]$patches$layout$guides, "keep")
  expect_identical(output$patches$annotation$title, "Keep title")
  expect_identical(output$patches$annotation$tag_levels, "A")
  expect_equal(sum(legend_test_labels(patchwork::patchworkGrob(output)) == "group"), 3)
  expect_identical(nested$patches$layout$guides, "collect")
})

test_that("legend collection only checks visible guides in its own scope", {
  p <- legend_test_plot()
  inside <- p + ggplot2::theme(legend.position = "inside")
  kept <- (inside | inside) + patchwork::plot_layout(guides = "keep")
  scoped <- (kept / (p | p)) + patchwork::plot_layout(guides = "collect")
  outside <- inside + ggplot2::guides(colour = ggplot2::guide_legend(position = "right"))
  scale_outside <- inside + ggplot2::scale_colour_discrete(
    guide = ggplot2::guide_legend(position = "right"))
  hidden <- list(inside + ggplot2::guides(colour = "none"),
                 inside + ggplot2::guides(colour = ggplot2::guide_none()),
                 inside + ggplot2::scale_colour_discrete(guide = "none"))
  no_keys <- ggplot2::ggplot(p$data, p$mapping) + ggplot2::geom_point(show.legend = FALSE) +
    ggplot2::theme(legend.position = "inside")
  inputs <- c(list(scoped, outside | outside, scale_outside | scale_outside,
                   no_keys | p | p,
                   (p + ggplot2::guides(fill = ggplot2::guide_legend(position = "inside"))) | p),
              lapply(hidden, function(x) x | p | p))
  for (input in inputs) {
    native <- input + patchwork::plot_layout(guides = "collect")
    expect_warning(output <- fmt_legend(input, collect = TRUE), NA)
    expect_identical(output$patches$layout$guides, "collect")
    expect_equal(sum(legend_test_labels(patchwork::patchworkGrob(output)) == "group"),
                 sum(legend_test_labels(patchwork::patchworkGrob(native)) == "group"))
  }
  expect_identical(fmt_legend(scoped, collect = TRUE)[[1L]]$patches$layout$guides, "keep")
})

test_that("guide clones do not retain formatter plots or grow with repeated calls", {
  p <- legend_test_plot()
  for (args in list(list(scale = 1), list(ncol = 2), list(title = "New group"),
                    list(legend.position = "bottom"))) {
    input <- do.call(fmt_legend, c(list(plot = p), args))
    first_size <- length(serialize(input, NULL))
    for (i in seq_len(5L)) input <- do.call(fmt_legend, c(list(plot = input), args))
    expect_lt(length(serialize(input, NULL)), first_size * 1.25)
    restored <- unserialize(serialize(input, NULL))
    expect_no_error(ggplot2::ggplotGrob(restored))
    expect_equal(legend_test_box_size(restored), legend_test_box_size(input))
    expect_identical(ggplot2::ggplot_build(restored)$data, ggplot2::ggplot_build(p)$data)
  }
  output <- fmt_legend(p, scale = 1)
  retained <- get("env", envir = environment(get("super", envir = output$guides,
                                                inherits = FALSE)), inherits = FALSE)
  expect_false(any(c("plots", "output", "info") %in% ls(retained)))
  expect_false(identical(get("plot", envir = retained, inherits = FALSE), p))
})

test_that("position hiding is reversible without enabling disabled guides", {
  for (continuous in c(FALSE, TRUE)) {
    guide <- if (continuous) ggplot2::guide_colourbar(position = "right", reverse = TRUE,
      order = 2, title = "Original", theme = ggplot2::theme()) else
      ggplot2::guide_legend(position = "right", reverse = TRUE, order = 2,
        title = "Original", override.aes = list(shape = 17), theme = ggplot2::theme())
    sc <- if (continuous) ggplot2::scale_colour_continuous(guide = guide) else
      ggplot2::scale_colour_discrete(guide = guide)
    for (input in list(legend_test_plot(continuous) + ggplot2::guides(colour = guide),
                      legend_test_plot(continuous) + sc)) {
      hidden <- fmt_legend(input, legend.position = "none")
      expect_false("Original" %in% legend_test_labels(ggplot2::ggplotGrob(hidden)))
      hidden <- fmt_legend(hidden, title = "Restored")
      expect_false("Restored" %in% legend_test_labels(ggplot2::ggplotGrob(hidden)))
      restored <- fmt_legend(hidden, legend.position = "right")
      expect_true("Restored" %in% legend_test_labels(ggplot2::ggplotGrob(restored)))
      params <- ggplot2::ggplot_build(restored)$plot$guides$guides[[1]]$params
      expect_true(params$reverse)
      expect_equal(params$order, 2)
      expect_identical(guide$params$title, "Original")
      expect_identical(guide$params$position, "right")
    }
    for (disabled in list(legend_test_plot(continuous) + ggplot2::guides(colour = "none"),
                           legend_test_plot(continuous) + ggplot2::guides(
                             colour = ggplot2::guide_none()))) {
      restored <- fmt_legend(fmt_legend(disabled, legend.position = "none"),
                             legend.position = "right")
      expect_length(ggplot2::ggplot_build(restored)$plot$guides$guides, 0L)
    }
  }
})

test_that("global and local key spacing scale equally in the rendered legend", {
  p <- legend_test_plot()
  spacing <- ggplot2::theme(legend.key.spacing.x = grid::unit(10, "mm"),
                             legend.key.spacing.y = grid::unit(10, "mm"))
  for (position in c("right", "bottom")) {
    global <- p + ggplot2::theme(legend.position = position) + spacing
    local <- p + ggplot2::guides(colour = ggplot2::guide_legend(position = position,
                                                              theme = spacing))
    expect_equal(legend_test_box_size(fmt_legend(global, scale = 1)),
                 legend_test_box_size(global))
    for (input in list(global, local)) {
      output <- fmt_legend(input, scale = 0.5)
      g <- ggplot2::ggplotGrob(output)
      box <- g$grobs[[which(grepl("^guide-box", g$layout$name) &
                              vapply(g$grobs, inherits, logical(1), "gtable"))[1L]]]
      guide <- box$grobs[[which(box$layout$name == "guides")[1L]]]
      gaps <- if (position == "right") grid::convertHeight(guide$heights, "mm", TRUE) else
        grid::convertWidth(guide$widths, "mm", TRUE)
      expect_true(any(abs(gaps - 5) < 1e-8))
      expect_false(any(abs(gaps - 10) < 1e-8))
    }
    expect_equal(legend_test_box_size(fmt_legend(global, scale = 0.5)),
                 legend_test_box_size(fmt_legend(local, scale = 0.5)))
  }
})

test_that("multiple ggnewscale legends receive titles and styling", {
  skip_if_not_installed("ggnewscale")
  p <- legend_test_plot()
  colour <- p + ggplot2::scale_colour_discrete(name = "First",
    guide = ggplot2::guide_legend(title = "First guide", reverse = TRUE, order = 2)) +
    ggnewscale::new_scale_colour() + ggplot2::geom_point(ggplot2::aes(colour = value),
                                                       shape = 17) +
    ggplot2::scale_colour_gradient(name = "Second")
  fill <- ggplot2::ggplot(p$data, ggplot2::aes(x, y, fill = group)) +
    ggplot2::geom_point(shape = 21) + ggplot2::scale_fill_discrete(name = "First",
      guide = ggplot2::guide_legend(title = "First guide", reverse = TRUE, order = 2)) +
    ggnewscale::new_scale_fill() + ggplot2::geom_point(ggplot2::aes(fill = value),
                                                     shape = 22) +
    ggplot2::scale_fill_gradient(name = "Second")
  for (input in list(colour, fill)) {
    output <- fmt_legend(input, title = "Unified", scale = 0.8, ncol = 2)
    labels <- legend_test_labels(ggplot2::ggplotGrob(output))
    expect_equal(sum(labels == "Unified"), 2)
    expect_false(any(c("First guide", "Second") %in% labels))
    expect_identical(vapply(output$scales$scales, function(sc) sc$name, character(1)),
                     c("Unified", "Unified"))
    expect_identical(input$scales$scales[[1]]$name, "First")
    expect_true("First guide" %in% legend_test_labels(ggplot2::ggplotGrob(input)))
    expect_identical(ggplot2::ggplot_build(output)$data, ggplot2::ggplot_build(input)$data)
    explicit <- output$scales$scales[[1]]$guide$params
    expect_true(explicit$reverse)
    expect_equal(explicit$order, 2)
    expect_identical(explicit$title, "Unified")
    expect_warning(hidden <- fmt_legend(input, legend.position = "none"), NA)
    expect_false(any(c("First guide", "Second") %in%
                       legend_test_labels(ggplot2::ggplotGrob(hidden))))
  }
  third <- colour + ggnewscale::new_scale_colour() +
    ggplot2::geom_point(ggplot2::aes(colour = group), shape = 15) +
    ggplot2::scale_colour_discrete(name = "Third")
  output <- fmt_legend(third, title = "Unified")
  expect_equal(sum(legend_test_labels(ggplot2::ggplotGrob(output)) == "Unified"), 3)
  explicit <- p + ggplot2::guides(colour = ggplot2::guide_legend(title = "Explicit")) +
    ggnewscale::new_scale_colour() + ggplot2::geom_point(ggplot2::aes(colour = value))
  output <- fmt_legend(explicit, title = "Unified")
  expect_equal(sum(legend_test_labels(ggplot2::ggplotGrob(output)) == "Unified"), 2)
  expect_identical(explicit$guides$guides$colour_ggnewscale_1$params$title, "Explicit")
  expect_identical(output$guides$guides$colour_ggnewscale_1$params$title, "Unified")
})

test_that("containers without editable plots still validate legend controls", {
  inputs <- list(list(), patchwork::plot_spacer(), patchwork::guide_area(),
                 patchwork::wrap_elements(legend_test_plot()),
                 patchwork::plot_spacer() | patchwork::guide_area())
  invalid <- list(legend.position = "bad", legend.direction = "bad",
                  legend_theme = list(), collect = NA, title = NA_character_,
                  scale = -1, scale_width = 0, scale_height = Inf, ncol = 1.5, nrow = 0)
  for (input in inputs) {
    for (name in names(invalid)) {
      expect_error(do.call(fmt_legend, c(list(plot = input), invalid[name])), name)
    }
    expect_identical(fmt_legend(input), input)
    expect_identical(fmt_legend(input, legend.position = "inside", scale = 1,
                                title = "", ncol = 1), input)
  }
  expect_warning(output <- fmt_legend(list(), collect = TRUE), "patchwork")
  expect_identical(output, list())
})
