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
