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

test_that("distribution palettes keep category names and unused-level positions", {
  data <- data.frame(x = c("A", "B"), y = "C", group = c("F", "M"))
  for (mode in c("bar", "alluvial", "heatmap")) {
    if (mode == "alluvial" && !requireNamespace("ggalluvial", quietly = TRUE)) next
    variables <- if (mode == "heatmap") c("x", "y", "group") else c("x", "group")
    type <- if (mode == "alluvial") "alluvial" else "bar"
    p <- dist_test_plot(data, variables, type = type, color = c(M = "red", F = "blue"))
    built <- ggplot2::ggplot_build(p)
    mapped <- built$plot$scales$get_scales("fill")$map(c("F", "M"))
    expect_equal(unname(grDevices::col2rgb(mapped)),
                 unname(grDevices::col2rgb(c("blue", "red"))))
    expect_error(plt_dist(data, variables, type = type, color = c(F = "blue")),
                 "every observed fill category")
  }
  data$group <- factor(data$group, levels = c("Unused", "F", "M"))
  p <- dist_test_plot(data, c("x", "group"), type = "bar",
                     color = c("red", "blue", "green"))
  mapped <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")$map(c("F", "M"))
  expect_equal(unname(grDevices::col2rgb(mapped)),
               unname(grDevices::col2rgb(c("blue", "green"))))
})

test_that("unlabelled heatmaps retain a visible category legend", {
  data <- data.frame(x = c("A", "B"), y = "C", group = c("F", "M"))
  for (theme in list(theme_heat(14), ggplot2::theme_bw() +
                     ggplot2::theme(legend.position = "bottom"))) {
    p <- dist_test_plot(data, c("x", "y", "group"), label = "none", theme_use = theme)
    expected <- if (identical(theme$legend.position, "none")) "right" else "bottom"
    expect_identical(p$theme$legend.position, expected)
    grob <- ggplot2::ggplotGrob(p)
    guides <- grob$grobs[grepl("^guide-box", grob$layout$name)]
    expect_true(any(vapply(guides, inherits, logical(1), what = "gtable")))
  }
  labelled <- dist_test_plot(data, c("x", "y", "group"))
  expect_identical(labelled$theme$legend.position, "none")
})

test_that("distribution selectors and transparency are validated consistently", {
  data <- data.frame(x = c("A", "B"), group = c("F", "M"), panel = c("P1", "P2"))
  for (type in c("bar", "alluvial")) {
    for (variables in list(c("x", "x"), c("x", NA_character_),
                           list("x", "group"), matrix(c("x", "group"), nrow = 1))) {
      expect_error(plt_dist(data, variables, type = type), "dis_vars")
    }
    for (facet in list(c("x", "panel"), NA_character_, 1, "", "absent", "x")) {
      expect_error(plt_dist(data, c("x", "group"), type = type, facet = facet),
                   "facet")
    }
    for (alpha in list(-0.1, 1.1, NA_real_, Inf, numeric(), c(0.2, 0.3), TRUE)) {
      expect_error(plt_dist(data, c("x", "group"), type = type, alpha = alpha),
                   "alpha")
    }
  }
  reference <- dist_test_plot(data, c("x", "panel", "group"))
  ignored <- dist_test_plot(data, c("x", "panel", "group"), type = "ignored")
  expect_equal(ggplot2::ggplot_build(ignored)$data,
               ggplot2::ggplot_build(reference)$data)
})
