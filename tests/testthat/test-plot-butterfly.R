test_that("PlotButterfly2 keeps category colours consistent across panels", {
  data <- data.frame(stat = "A", value = seq_len(12), group = rep(c("L", "R"), each = 6),
                     fill = rep(c("A", "B", "B", "C"), each = 3))
  original <- data
  for (palette in list(c("red", "green", "blue"), c("red", "green", "blue", "orange"))) {
    plot <- PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group",
                           fill.by = "fill", type = "box", palette = palette)
    for (i in 1:2) {
      scale <- ggplot2::ggplot_build(plot[[i]])$plot$scales$get_scales("fill")
      expect_identical(scale$map("B"), "green")
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly2 shares the gradient range across panels", {
  skip_if_not_installed("ggbeeswarm")
  data <- data.frame(stat = "A", value = c(-1, -.5, 0, .3, .7, 1, -4, -2, 0, 1, 2, 4),
                     group = rep(c("L", "R"), each = 6))
  for (fill in list(NULL, "fill")) {
    data$fill <- rep(c("A", "B"), 6)
    plot <- suppressMessages(PlotButterfly2(data, stat.by = "stat", value.by = "value",
      group.by = "group", fill.by = fill, type = "beeswarm_quasirandom", color_by = "logFC"))
    scales <- lapply(1:2, function(i) ggplot2::ggplot_build(plot[[i]])$plot$scales$get_scales("colour"))
    expect_identical(scales[[1]]$map(1), scales[[2]]$map(1))
    expect_equal(scales[[1]]$get_limits(), c(-4, 4))
    expect_equal(scales[[2]]$get_limits(), c(-4, 4))
  }
})
