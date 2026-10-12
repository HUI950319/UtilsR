flatten_test_plot <- function(title) {
  ggplot2::ggplot(data.frame(x = 1:3, y = c(2, 1, 3)),
                   ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::labs(title = title, x = "Shared X", y = "Shared Y")
}

flatten_test_titles <- function(plot) {
  vapply(seq_along(plot), function(i) plot[[i]]$labels$title, character(1))
}

test_that("flattening accepts lists and preserves named design assignments", {
  p1 <- flatten_test_plot("First")
  p2 <- flatten_test_plot("Second")
  input <- list(B = p2, A = p1)
  output <- flatten_patchwork(input, design = "AB")
  expect_s3_class(output, "patchwork")
  expect_equal(flatten_test_titles(output), c("First", "Second"))
  expect_identical(input, list(B = p2, A = p1))

  nested <- list(p1 | p2, list(p1))
  expect_equal(flatten_test_titles(flatten_patchwork(nested)),
                 c("First", "Second", "First"))
  expect_equal(flatten_test_titles(flatten_patchwork(p1)), "First")
  expect_error(flatten_patchwork(list(p1, 42)), "ggplot|grob")
})
