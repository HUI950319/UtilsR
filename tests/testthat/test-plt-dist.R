dist_test_plot <- function(...) {
  output <- utils::capture.output(p <- plt_dist(...))
  p
}

test_that("bar calculations do not overwrite selected input names", {
  data <- data.frame(x = c("A", "A", "B", "B"),
                     group = c("F", "M", "F", "M"))
  original <- data
  reference <- ggplot2::ggplot_build(
    dist_test_plot(data, c("x", "group"), type = "bar")
  )$data

  for (column in c("x", "group")) {
    for (name in c("n", "prop", ".lab")) {
      renamed <- data
      names(renamed)[names(renamed) == column] <- name
      variables <- if (column == "x") c(name, "group") else c("x", name)
      p <- dist_test_plot(renamed, variables, type = "bar")
      expect_identical(as.character(p$data[[name]]),
                       as.character(factor(data[[column]])))
      expect_equal(ggplot2::ggplot_build(p)$data, reference)
    }
  }
  expect_identical(data, original)
})

test_that("distribution counts ignore unrelated input grouping", {
  data <- data.frame(x = rep(c("A", "B"), each = 4),
                     group = rep(c("F", "M"), 4),
                     batch = rep(c("b1", "b1", "b2", "b2"), 2))
  data$tile <- paste(data$x, data$group)
  for (input in list(dplyr::group_by(data, batch), dplyr::rowwise(data))) {
    original <- input
    for (variables in list(c("x", "group"), c("x", "group", "tile"))) {
      p <- dist_test_plot(input, variables, type = "bar")
      reference <- dist_test_plot(data, variables, type = "bar")
      expect_equal(as.data.frame(p$data), as.data.frame(reference$data))
      expect_equal(ggplot2::ggplot_build(p)$data,
                   ggplot2::ggplot_build(reference)$data)
    }
    expect_identical(input, original)
  }
})
