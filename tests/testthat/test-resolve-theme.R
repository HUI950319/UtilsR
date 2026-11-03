test_that(".resolve_theme preserves valid themes and calls factories once", {
  thm <- ggplot2::theme(text = ggplot2::element_text(size = 17))
  expect_identical(.resolve_theme(thm), thm)
  expect_identical(.resolve_theme(NULL), theme_km)

  calls <- 0L
  make_theme <- function() {
    calls <<- calls + 1L
    thm
  }
  expect_identical(.resolve_theme(make_theme), thm)
  expect_identical(calls, 1L)
})

test_that(".resolve_theme rejects non-theme factory results", {
  invalid <- list(NULL, list(), 1, "theme_bw", ggplot2::geom_point(),
                  ggplot2::scale_y_reverse(), ggplot2::ggplot())
  for (value in invalid) {
    expect_error(.resolve_theme(function() value), "return.*theme")
  }
  expect_error(.resolve_theme("pal_lancet"), "theme_use.*must be")
})

test_that("fmt_plot_base rejects a factory returning a plot component", {
  d <- data.frame(x = 1:3, y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_error(fmt_plot_base(p, ggtheme = function() ggplot2::geom_point()),
               "return.*theme")
  expect_error(fmt_plot_base(p, ggtheme = function() ggplot2::scale_y_reverse()),
               "return.*theme")
  expect_length(p$layers, 1L)
})

test_that(".resolve_theme preserves a factory's original error", {
  expect_error(.resolve_theme(function() stop("theme factory failed")),
               "theme factory failed")
})
