sankey_data <- function() {
  data.frame(
    sex = factor(c("M", "M", "M", "F"), levels = c("M", "F")),
    stage = factor(c("I", "I", "II", "II"), levels = c("I", "II")),
    grade = factor(c("Low", "High", "Low", "Low"), levels = c("Low", "High"))
  )
}

sankey_plot <- function(data = sankey_data(), vars = names(data), ...) {
  withr::local_options(lifecycle_verbosity = "quiet")
  withCallingHandlers(
    plt_sankey(data, vars = vars, ...),
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
  expect_identical(levels(sankey_plot()$data$label), expected$all)
  for (style in names(expected)) {
    expect_identical(levels(sankey_plot(show_text = style)$data$label),
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
  expect_identical(levels(plot$data$label), expected)
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

test_that("plt_sankey accepts variable-to-label maps without changing geometry", {
  skip_if_not_installed("ggsankey")

  name_map <- c(stage = "Disease\nstage", sex = "Sex", grade = "")
  plain <- sankey_plot(vars = names(name_map), show_text = "all_wrap")
  named <- sankey_plot(vars = name_map, show_text = "all_wrap")
  plain_build <- ggplot2::ggplot_build(plain)
  named_build <- ggplot2::ggplot_build(named)

  expect_identical(named$data, plain$data)
  expect_equal(named_build$data, plain_build$data)
  expect_identical(plain_build$layout$panel_scales_x[[1]]$get_labels(),
                   paste0(names(name_map), "_label"))
  expect_identical(as.character(named_build$layout$panel_scales_x[[1]]$get_labels()),
                   unname(name_map))
  reordered <- ggplot2::ggplot_build(suppressMessages(named + ggplot2::scale_x_discrete(
    limits = c("sex_label", "stage_label", "grade_label"),
    labels = named$scales$get_scales("x")$labels
  )))
  expect_identical(as.character(reordered$layout$panel_scales_x[[1]]$get_labels()),
                   unname(name_map[c("sex", "stage", "grade")]))
})

test_that("plt_sankey validates named variable maps", {
  skip_if_not_installed("ggsankey")

  expect_error(sankey_plot(vars = c(sex = "Sex", "Stage")), "non-empty")
  expect_error(sankey_plot(vars = c(sex = "Sex", sex = "Stage")), "unique")
  expect_error(sankey_plot(vars = setNames(c("Sex", "Stage"), c("sex", NA))),
               "non-empty")
  expect_error(sankey_plot(vars = c(sex = "Sex", stage = NA_character_)),
               "non-missing")
  expect_error(sankey_plot(vars = c(sex = 1, stage = 2)), "character")
  expect_error(sankey_plot(vars = c(sex = "Sex", missing = "Stage")),
               "not found.*missing")
})

test_that("plt_sankey keeps identical category labels distinct across variables", {
  skip_if_not_installed("ggsankey")

  data <- data.frame(a = c("No", "Yes", "No", "Yes"),
                     b = c("No", "Yes", "Yes", "No"))
  plain <- sankey_plot(data, show_text = "name")
  counts <- sankey_plot(data, show_text = "all_wrap")
  plain_build <- ggplot2::ggplot_build(plain)
  counts_build <- ggplot2::ggplot_build(counts)
  nodes <- plain_build$data[[2]]
  expect_equal(nrow(nodes), 4L)
  expect_equal(nodes$ymax - nodes$ymin, rep(2, 4))
  expect_equal(length(unique(nodes$node)), 4L)
  expect_equal(table(as.character(plain_build$data[[3]]$label)),
               table(c("No", "Yes", "No", "Yes")))
  expect_identical(plain$data$node, counts$data$node)
  expect_identical(nodes$fill, counts_build$data[[2]]$fill)
})
