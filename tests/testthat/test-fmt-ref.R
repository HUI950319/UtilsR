test_that("reference positions reject geom intercept argument names", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()

  expect_error(fmt_ref(p, xintercept = 2), "xintercept")
  expect_error(fmt_ref(p, yintercept = 2), "yintercept")
  expect_error(fmt_ref(p, x = 2, xintercept = 3), "Use.*x")
  expect_error(fmt_plot(p, fmt_ref_list = list(yintercept = 2)), "yintercept")
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
