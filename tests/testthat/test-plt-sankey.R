sankey_data <- function() {
  data.frame(
    sex = factor(c("M", "M", "M", "F"), levels = c("M", "F")),
    stage = factor(c("I", "I", "II", "II"), levels = c("I", "II")),
    grade = factor(c("Low", "High", "Low", "Low"), levels = c("Low", "High"))
  )
}

sankey_plot <- function(data = sankey_data(), ...) {
  withr::local_options(lifecycle_verbosity = "quiet")
  withCallingHandlers(
    plt_sankey(data, vars = names(data), ...),
    warning = function(w) {
      if (identical(conditionMessage(w),
                    "attributes are not identical across measure variables; they will be dropped")) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

test_that("plt_sankey retains the default and existing label styles", {
  skip_if_not_installed("ggsankey")

  expected <- list(
    all = c("F (1, 25.0%)", "M (3, 75.0%)", "II (2, 50.0%)", "I (2, 50.0%)",
            "High (1, 25.0%)", "Low (3, 75.0%)"),
    n = c("F (1)", "M (3)", "II (2)", "I (2)", "High (1)", "Low (3)"),
    pct = c("F (25.0%)", "M (75.0%)", "II (50.0%)", "I (50.0%)",
            "High (25.0%)", "Low (75.0%)"),
    name = c("F", "M", "II", "I", "High", "Low")
  )
  expect_identical(levels(sankey_plot()$data$node), expected$all)
  for (style in names(expected)) {
    expect_identical(levels(sankey_plot(show_text = style)$data$node),
                     expected[[style]])
  }
})

test_that("plt_sankey places count and percentage together on the second line", {
  skip_if_not_installed("ggsankey")

  plot <- sankey_plot(show_text = "all_wrap")
  expected <- c(
    "F\n(1, 25.0%)", "M\n(3, 75.0%)", "II\n(2, 50.0%)", "I\n(2, 50.0%)",
    "High\n(1, 25.0%)", "Low\n(3, 75.0%)"
  )
  expect_s3_class(plot, "ggplot")
  expect_identical(levels(plot$data$node), expected)
  expect_setequal(as.character(ggplot2::ggplot_build(plot)$data[[3]]$label),
                  expected)
})

test_that("plt_sankey wrapping preserves flows, counts, ordering and colours", {
  skip_if_not_installed("ggsankey")

  data <- sankey_data()
  original <- data
  for (reverse in c(TRUE, FALSE)) {
    for (palette in list(NULL, c("#114477", "#77AADD"))) {
      single <- ggplot2::ggplot_build(sankey_plot(
        data, show_text = "all", reverse_levels = reverse,
        palette = palette, space = 0
      ))$data
      wrapped <- ggplot2::ggplot_build(sankey_plot(
        data, show_text = "all_wrap", reverse_levels = reverse,
        palette = palette, space = 0
      ))$data
      expect_length(wrapped, length(single))
      for (i in seq_along(wrapped)) {
        for (field in intersect(c("node", "label"), names(wrapped[[i]]))) {
          wrapped[[i]][[field]] <- gsub("\n", " ",
            as.character(wrapped[[i]][[field]]), fixed = TRUE)
          single[[i]][[field]] <- as.character(single[[i]][[field]])
        }
        expect_equal(wrapped[[i]], single[[i]])
      }
    }
  }
  expect_identical(data, original)
})
