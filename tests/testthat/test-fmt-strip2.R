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
})
