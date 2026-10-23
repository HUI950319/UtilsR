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

test_that("bar facets accept literal non-syntactic column names", {
  data <- data.frame(x = c("A", "A", "B", "B"),
                     group = c("F", "M", "F", "M"),
                     panel = c("P1", "P1", "P2", "P2"))
  reference <- ggplot2::ggplot_build(
    dist_test_plot(data, c("x", "group"), type = "bar", facet = "panel")
  )$data
  for (name in c("panel group", "panel+group", "panel`group")) {
    renamed <- data
    names(renamed)[3L] <- name
    p <- dist_test_plot(renamed, c("x", "group"), type = "bar", facet = name)
    expect_equal(ggplot2::ggplot_build(p)$data, reference)
    expect_identical(as.character(p$data[[name]]), data$panel)
  }
})

test_that("heatmaps reject cells containing more than one fill category", {
  conflicting <- data.frame(x = "A", y = "B", group = c("F", rep("M", 9)))
  for (label in c("count_percent", "none")) {
    expect_error(plt_dist(conflicting, c("x", "y", "group"), label = label),
                 "more than one.*category")
  }
  valid <- data.frame(x = c("A", "A", "B"), y = "C", group = c("F", "F", "M"))
  p <- dist_test_plot(valid, c("x", "y", "group"))
  expect_equal(p$data$n, c(2L, 1L))
  tiles <- ggplot2::ggplot_build(p)$data[[1L]]
  expect_equal(nrow(unique(tiles[c("x", "y")])), nrow(tiles))
})
