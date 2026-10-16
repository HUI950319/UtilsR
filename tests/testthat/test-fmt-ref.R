test_that("reference positions reject geom intercept argument names", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()

  expect_error(fmt_ref(p, xintercept = 2), "xintercept")
  expect_error(fmt_ref(p, yintercept = 2), "yintercept")
  expect_error(fmt_ref(p, x = 2, xintercept = 3), "Use.*x")
  expect_error(fmt_plot(p, fmt_ref_list = list(yintercept = 2)), "yintercept")
})

test_that("colour arguments direct callers to the supported color parameter", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (args in list(list(x = 2, colour = "red"),
                    list(x = 2, color = "blue", colour = "red"),
                    list(colour = "red"), list(x = 2, colour = NULL))) {
    expect_error(do.call(fmt_ref, c(list(plot = p), args)), "Use.*color.*colour")
  }
  expect_error(fmt_plot(p, fmt_ref_list = list(x = 2, colour = "red")), "Use.*color")
  expect_no_warning(result <- fmt_ref(p, x = 2, color = "red"))
  expect_equal(as.character(ggplot2::ggplot_build(result)$data[[2]]$colour), "red")
})

test_that("reference positions add vertical and horizontal lines", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  result <- fmt_ref(p, x = 2, y = 1)
  data <- ggplot2::ggplot_build(result)$data

  expect_equal(data[[2]]$xintercept, 2)
  expect_equal(data[[3]]$yintercept, 1)
  expect_equal(data[[1]], ggplot2::ggplot_build(p)$data[[1]])
  expect_length(p$layers, 1L)
})

test_that("active references reject empty or non-vector styles early", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  styles <- list(linetype = "solid", linewidth = 0.5, color = "red", alpha = 0.8)
  for (name in names(styles)) {
    value <- styles[[name]]
    for (invalid in list(NULL, value[FALSE], as.list(value), matrix(value))) {
      args <- c(list(plot = p, x = 2), stats::setNames(list(invalid), name))
      expect_error(do.call(fmt_ref, args), paste0(name, ".*non-empty vector"))
    }
    args <- c(list(plot = p, y = 2, lineend = "round"),
              stats::setNames(list(NULL), name))
    expect_error(do.call(fmt_ref, args), paste0(name, ".*non-empty vector"))
  }
})

test_that("unused and native missing styles retain their existing meaning", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  expect_identical(fmt_ref(p, color = character(), alpha = NULL), p)
  expect_identical(fmt_ref(p, x = numeric(), y = NULL, linetype = list()), p)
  expect_no_error(result <- fmt_ref(p, x = c(1, 2), color = c(NA, "red"),
                                     linetype = c(0, 2), linewidth = c(0, 0.5),
                                     alpha = c(NA, 0.8)))
  expect_no_warning(ggplot2::ggplotGrob(result))
  expect_equal(as.numeric(ggplot2::ggplot_build(result)$data[[2]]$linetype), c(0, 2))
})

test_that("factor colors use labels and numeric palette colors retain their meaning", {
  skip_if_not_installed("ragg")
  capture_plot <- function(q) {
    capture <- ragg::agg_capture(width = 700, height = 480, res = 100)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(q)
    capture(native = TRUE)
  }
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 5:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (colors in list(factor(c("red", "blue", NA), levels = c("blue", "red")),
                      c(2, 4), c("#FF000080", "#0000FF40", NA))) {
    expected_colors <- if (is.factor(colors)) as.character(colors) else colors
    expected <- p
    for (i in seq_len(3L)) {
      color <- rep_len(expected_colors, 3L)[i]
      expected <- expected + ggplot2::geom_vline(xintercept = i + 1, colour = color,
                                                 linetype = "dashed", linewidth = 0.5,
                                                 alpha = 0.8)
    }
    for (extra in list(list(), list(inherit.aes = FALSE))) {
      result <- do.call(fmt_ref, c(list(plot = p, x = 2:4, color = colors), extra))
      expect_true(identical(capture_plot(result), capture_plot(expected)))
    }
  }
})

test_that("returned reference plots do not retain data from peer plots", {
  plots <- local({
    make_plot <- function(n) {
      d <- data.frame(x = seq_len(n), y = sin(seq_len(n)), unused = cos(seq_len(n)))
      ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
    }
    list(small = make_plot(5L), large = make_plot(50000L))
  }, envir = new.env(parent = baseenv()))
  invisible(ggplot2::ggplotGrob(plots$small))
  peer_bytes <- length(serialize(plots$large$data, NULL))
  for (extra in list(list(), list(inherit.aes = FALSE))) {
    small_peer <- do.call(fmt_ref, c(list(plot = list(plots$small, plots$small),
                                         x = c(2, 4), y = 3), extra))[[1]]
    large_peer <- do.call(fmt_ref, c(list(plot = plots, x = c(2, 4), y = 3), extra))[[1]]
    extra_bytes <- length(serialize(large_peer, NULL)) - length(serialize(small_peer, NULL))
    expect_lt(extra_bytes, peer_bytes / 10)
    expect_equal(ggplot2::ggplot_build(large_peer)$data,
                 ggplot2::ggplot_build(small_peer)$data)
  }
})

test_that("multiple references share layers without changing per-line styles", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 5:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  result <- fmt_ref(p, x = c(2, 3, 4), y = c(1, 5),
                    color = c("red", "blue"), linetype = c("solid", "dashed"),
                    linewidth = c(0.3, 0.8), alpha = c(0.4, 0.9))
  expect_length(result$layers, 3L)
  data <- ggplot2::ggplot_build(result)$data
  expect_equal(data[[2]]$xintercept, c(2, 3, 4))
  expect_equal(as.character(data[[2]]$colour), c("red", "blue", "red"))
  expect_equal(as.character(data[[2]]$linetype), c("solid", "dashed", "solid"))
  expect_equal(as.numeric(data[[2]]$linewidth), c(0.3, 0.8, 0.3))
  expect_equal(as.numeric(data[[2]]$alpha), c(0.4, 0.9, 0.4))
  expect_equal(data[[3]]$yintercept, c(1, 5))
  expect_equal(as.character(data[[3]]$colour), c("red", "blue"))
  expect_equal(result$scales$scales, p$scales$scales)
})

test_that("reference styles survive facet replication", {
  p <- ggplot2::ggplot(data.frame(x = 1:6, y = 6:1, facet = rep(c("A", "B"), 3)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(~facet)
  result <- fmt_ref(p, x = c(2, 4), color = c("red", "blue"))
  expect_length(result$layers, 2L)
  data <- ggplot2::ggplot_build(result)$data[[2]]
  for (panel in unique(data$PANEL)) {
    rows <- data[data$PANEL == panel, ]
    expect_equal(rows$xintercept, c(2, 4))
    expect_equal(as.character(rows$colour), c("red", "blue"))
  }
})

test_that("reference helper columns do not change facet panels", {
  helper_names <- paste0(".fmt_ref_", c("intercept", "group", "colour", "linetype",
                                       "linewidth", "alpha"))
  for (name in helper_names) {
    d <- data.frame(x = 1:6, y = 6:1)
    d[[name]] <- rep(c("A", "B"), 3)
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
    for (facet in list(ggplot2::facet_wrap(stats::reformulate(name)),
                       ggplot2::facet_grid(stats::reformulate(name)))) {
      input <- p + facet
      expected <- input + ggplot2::geom_vline(xintercept = 2, colour = "red",
                                               linetype = "dashed", linewidth = 0.5,
                                               alpha = 0.8) +
        ggplot2::geom_vline(xintercept = 4, colour = "blue", linetype = "dashed",
                            linewidth = 0.5, alpha = 0.8)
      expect_no_warning(result <- ggplot2::ggplot_build(
        fmt_ref(input, x = c(2, 4), color = c("red", "blue"))))
      native <- ggplot2::ggplot_build(expected)
      expect_equal(result$layout$layout, native$layout$layout, info = name)
      expect_equal(result$data, native$data, info = name)
    }
  }
  calls <- 0L
  p <- ggplot2::ggplot(mapping = ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(d) {
      calls <<- calls + 1L
      data.frame(x = 1:4, y = 4:1, .fmt_ref_group = c("A", "B", "A", "B"))
    }) + ggplot2::facet_wrap(ggplot2::vars(tolower(.data[[".fmt_ref_group"]])))
  result <- fmt_ref(list(single = p, nested = p | p), x = c(2, 3))
  expect_equal(calls, 0L)
  for (q in .to_plot_list(result, recurse = TRUE)$plots) {
    expect_no_warning(built <- ggplot2::ggplot_build(q))
    expect_equal(nrow(built$layout$layout), 2L)
  }
})

test_that("safe extra geom arguments retain batched native rendering", {
  skip_if_not_installed("ragg")
  capture_plot <- function(q) {
    capture <- ragg::agg_capture(width = 700, height = 480, res = 100)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(q)
    capture(native = TRUE)
  }
  p <- ggplot2::ggplot(data.frame(x = 1:6, y = 6:1, facet = rep(c("A", "B"), 3)),
                       ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(~facet)
  for (extra in list(list(na.rm = FALSE), list(na.rm = TRUE), list(lineend = "round"),
                     list(na.rm = TRUE, lineend = "square"))) {
    result <- do.call(fmt_ref, c(list(plot = p, x = c(2, 4), color = c("red", "blue"),
                                     linewidth = c(0.5, 1.5)), extra))
    expected <- p
    for (i in seq_len(2L)) {
      expected <- expected + do.call(ggplot2::geom_vline,
        c(list(xintercept = c(2, 4)[i], colour = c("red", "blue")[i],
               linetype = "dashed", linewidth = c(0.5, 1.5)[i], alpha = 0.8), extra))
    }
    expect_length(result$layers, 2L)
    data <- ggplot2::ggplot_build(result)$data[[2]]
    for (panel in unique(data$PANEL)) {
      rows <- data[data$PANEL == panel, ]
      expect_equal(rows$xintercept, c(2, 4))
      expect_equal(as.character(rows$colour), c("red", "blue"))
      expect_equal(as.numeric(rows$linewidth), c(0.5, 1.5))
    }
    expect_true(identical(capture_plot(result), capture_plot(expected)))
  }
  expect_warning(ggplot2::ggplotGrob(fmt_ref(p, x = c(2, NA), na.rm = FALSE)),
                 "Removed 2 rows")
  expect_no_warning(ggplot2::ggplotGrob(fmt_ref(p, x = c(2, NA), na.rm = TRUE)))
})

test_that("other geom arguments retain native per-line forwarding", {
  p <- ggplot2::ggplot(data.frame(x = 1:5, y = 5:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (extra in list(list(inherit.aes = FALSE), list(show.legend = TRUE),
                     list(lineend = c("round", "butt")))) {
    result <- do.call(fmt_ref, c(list(plot = p, x = c(2, 4)), extra))
    expected <- p
    for (x in c(2, 4)) {
      expected <- expected + do.call(ggplot2::geom_vline,
        c(list(xintercept = x, colour = "gray50", linetype = "dashed",
               linewidth = 0.5, alpha = 0.8), extra))
    }
    expect_length(result$layers, 3L)
    expect_equal(ggplot2::ggplot_build(result)$data,
                 ggplot2::ggplot_build(expected)$data)
  }
  expect_error(do.call(fmt_ref, c(list(plot = p, x = c(2, 4)),
                                list(na.rm = FALSE, na.rm = TRUE))),
               "matched by multiple actual arguments")
})

test_that("batched references render like native lines across plot layouts", {
  skip_if_not_installed("ragg")
  capture_plot <- function(q) {
    capture <- ragg::agg_capture(width = 700, height = 480, res = 100)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(q)
    capture(native = TRUE)
  }
  add_native <- function(q, x) {
    for (i in seq_along(x)) {
      q <- q + ggplot2::geom_vline(xintercept = x[i], colour = c("red", "blue", "red")[i],
                                   linetype = c("solid", "dashed", "solid")[i],
                                   linewidth = c(0.3, 0.8, 0.3)[i], alpha = c(0.4, 0.9, 0.4)[i])
    }
    q + ggplot2::geom_hline(yintercept = 3, colour = "red", linetype = "solid",
                             linewidth = 0.3, alpha = 0.4)
  }
  d <- data.frame(x = 1:6, y = 6:1, facet = rep(c("A", "B"), 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = facet)) + ggplot2::geom_point()
  fixtures <- list(single = p, facet = p + ggplot2::facet_wrap(~facet),
                   flipped = p + ggplot2::coord_flip(), duplicate = p,
                   continuous = ggplot2::ggplot(d, ggplot2::aes(x, y, colour = x)) +
                     ggplot2::geom_point(),
                   nested = (p | patchwork::plot_spacer()) / (p | p))
  for (name in names(fixtures)) {
    x <- if (name == "duplicate") c(3, 3, 3) else c(2, 3, 4)
    expected <- if (name == "nested") {
      (add_native(p, x) | patchwork::plot_spacer()) / (add_native(p, x) | add_native(p, x))
    } else add_native(fixtures[[name]], x)
    result <- fmt_ref(fixtures[[name]], x = x, y = 3, color = c("red", "blue"),
                      linetype = c("solid", "dashed"), linewidth = c(0.3, 0.8),
                      alpha = c(0.4, 0.9))
    expect_identical(capture_plot(result), capture_plot(expected), info = name)
  }
})

test_that("reference positions follow date datetime and discrete scales", {
  dates <- as.Date("2026-01-01") + 0:3
  times <- as.POSIXct("2026-01-01 12:00:00", tz = "UTC") + (0:3) * 3600
  categories <- factor(c("B", "A", "C", "B"), levels = c("C", "B", "A"))
  for (x in list(dates, times, categories, as.character(categories))) {
    p <- ggplot2::ggplot(data.frame(x = x, y = 1:4), ggplot2::aes(x, y)) +
      ggplot2::geom_point()
    values <- x[c(2, 3)]
    result <- ggplot2::ggplot_build(fmt_ref(p, x = values))
    expected <- ggplot2::ggplot_build(p + ggplot2::geom_vline(xintercept = values))
    expect_equal(result$data[[2]]$xintercept, expected$data[[2]]$xintercept)
    expect_equal(result$data[[1]], expected$data[[1]])
    expect_equal(result$layout$panel_params[[1]]$x.range,
                 expected$layout$panel_params[[1]]$x.range)
  }
})

test_that("reference positions follow transformed axes and coordinate limits", {
  p <- ggplot2::ggplot(data.frame(x = 1:6, y = 6:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  fixtures <- list(p + ggplot2::scale_x_log10() + ggplot2::scale_y_reverse(),
                   p + ggplot2::scale_y_log10() + ggplot2::coord_cartesian(xlim = c(2, 4)))
  for (input in fixtures) {
    result <- ggplot2::ggplot_build(fmt_ref(input, x = c(2, 5), y = c(2, 4)))
    expected <- ggplot2::ggplot_build(input + ggplot2::geom_vline(xintercept = c(2, 5)) +
                                       ggplot2::geom_hline(yintercept = c(2, 4)))
    expect_equal(result$data[[2]]$xintercept, expected$data[[2]]$xintercept)
    expect_equal(result$data[[3]]$yintercept, expected$data[[3]]$yintercept)
    expect_equal(result$layout$panel_params[[1]]$x.range,
                 expected$layout$panel_params[[1]]$x.range)
    expect_equal(result$layout$panel_params[[1]]$y.range,
                 expected$layout$panel_params[[1]]$y.range)
  }
})

test_that("infinite and missing positions retain native handling", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  result <- fmt_ref(p, x = c(-Inf, Inf, NA_real_))
  expect_equal(ggplot2::ggplot_build(result)$data[[2]]$xintercept, c(-Inf, Inf, NA_real_))
  expect_no_warning(ggplot2::ggplotGrob(fmt_ref(p, x = c(-Inf, Inf), y = c(-Inf, Inf))))
  expect_no_warning(ggplot2::ggplotGrob(fmt_ref(p, x = c(NA_real_, 2), na.rm = TRUE)))
})

test_that("nested containers retain names annotations placeholders and caller objects", {
  input <- local({
    d <- data.frame(x = 1:4, y = 4:1)
    p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
    nested <- ((p | patchwork::plot_spacer()) / (p | p)) +
      patchwork::plot_annotation(title = "Keep", caption = "Caption", tag_levels = "A")
    list(first = p, nested = nested, spacer = patchwork::plot_spacer(),
         guide = patchwork::guide_area(),
         wrapped = patchwork::wrap_elements(grid::textGrob("Wrapped")))
  }, envir = new.env(parent = baseenv()))
  nested <- input$nested
  # Warm native drawing-method caches before comparing serialized plot objects.
  invisible(patchwork::patchworkGrob(nested))
  before <- serialize(input, NULL)
  result <- fmt_ref(input, x = c(2, 3), y = 2)
  expect_identical(names(result), names(input))
  expect_identical(result$nested$patches$layout, nested$patches$layout)
  expect_identical(result$nested$patches$annotation, nested$patches$annotation)
  for (name in c("spacer", "guide", "wrapped")) expect_identical(result[[name]], input[[name]])
  plots <- .to_plot_list(result, recurse = TRUE)$plots
  expect_length(plots, 4L)
  expect_equal(vapply(plots, function(q) length(q$layers), integer(1)), rep(3L, 4L))
  expect_no_error(patchwork::patchworkGrob(result$nested))
  expect_true(identical(serialize(input, NULL), before))
})

test_that("inset overlays and freed patchwork alignment are preserved", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = 4:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  overlay <- (p | p) & ggplot2::labs(title = "Inset")
  input <- (p | p) + patchwork::inset_element(overlay, 0.6, 0.6, 1, 1)
  inputs <- list(input, patchwork::free(input, side = "l"))
  for (original in inputs) {
    result <- fmt_ref(original, x = 2)
    expect_length(.to_plot_list(result, recurse = TRUE)$plots, 2L)
    expect_identical(result$patches$layout, original$patches$layout)
    expect_identical(attr(result, "patchwork_free_settings"),
                     attr(original, "patchwork_free_settings"))
    expect_no_error(patchwork::patchworkGrob(result))
  }
})

test_that("reference construction preserves RNG and defers layer data callbacks", {
  calls <- 0L
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(d) {
      calls <<- calls + 1L
      d
    })
  set.seed(42)
  seed <- .Random.seed
  nested <- (p | patchwork::plot_spacer()) / (p | p)
  for (input in list(p, nested, list(A = p, B = p), list())) {
    expect_identical(fmt_ref(input), input)
    expect_identical(fmt_ref(input, x = numeric(), y = numeric()), input)
  }
  result <- fmt_ref(p, x = c(1, 2), y = 2)
  expect_equal(calls, 0L)
  expect_identical(.Random.seed, seed)
  expect_error(fmt_ref(1), "ggplot")
  expect_error(fmt_ref(list(p, "invalid")), "ggplot")
  expect_no_error(ggplot2::ggplot_build(result))
  expect_equal(calls, 1L)
})

test_that("new reference layers can be edited independently across subplots", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = 4:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (input in list(list(first = p, second = p), (p | patchwork::plot_spacer()) / p)) {
    for (extra in list(list(), list(inherit.aes = FALSE))) {
      result <- do.call(fmt_ref, c(list(plot = input, x = c(2, 3), y = c(2, 3),
                                       color = c("blue", "black")), extra))
      leaves <- .to_plot_list(result, recurse = TRUE)$plots
      first <- leaves[[1]]
      second <- leaves[[2]]
      before <- ggplot2::ggplot_build(second)$data
      for (i in seq.int(2L, length(first$layers))) {
        second_data <- second$layers[[i]]$data
        second_styles <- second$layers[[i]]$aes_params
        first$layers[[i]]$data[[1L]][1L] <- 99
        first$layers[[i]]$aes_params$colour <- "purple"
        expect_equal(second$layers[[i]]$data, second_data)
        expect_equal(second$layers[[i]]$aes_params, second_styles)
      }
      expect_equal(ggplot2::ggplot_build(second)$data, before)
      expect_length(p$layers, 1L)
    }
  }
})

test_that("repeated reference calls append lines without changing earlier plots", {
  p <- ggplot2::ggplot(data.frame(x = 1:4, y = 4:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  first <- fmt_ref(p, x = c(1, 3), color = "red")
  result <- fmt_ref(first, y = c(2, 4), color = "blue")
  data <- ggplot2::ggplot_build(result)$data
  expect_length(p$layers, 1L)
  expect_length(first$layers, 2L)
  expect_length(result$layers, 3L)
  expect_equal(data[[2]]$xintercept, c(1, 3))
  expect_equal(data[[3]]$yintercept, c(2, 4))
  expect_equal(as.character(data[[2]]$colour), rep("red", 2))
  expect_equal(as.character(data[[3]]$colour), rep("blue", 2))
})
