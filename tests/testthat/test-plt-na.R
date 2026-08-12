oc_data <- function() {
  testthat::skip_if_not_installed("ToyData")
  ToyData::oc
}

oc_missing_levels <- function(decreasing = TRUE) {
  data <- oc_data()
  missing_rate <- colMeans(is.na(data))
  names(sort(missing_rate[missing_rate > 0], decreasing = decreasing))
}

oc_missing_rates <- function() {
  data <- oc_data()
  missing_rate <- colMeans(is.na(data))
  missing_rate[missing_rate > 0]
}

render_plot <- function(plot) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)

  if (inherits(plot, "patchwork")) {
    patchwork::patchworkGrob(plot)
  } else {
    ggplot2::ggplotGrob(plot)
  }
}

test_that("plt_na returns the standard combined plot by default", {
  name_map <- c(CYFRA21 = "CYFRA21 mapped", CA242 = "CA242 mapped")
  plot <- plt_na(
    oc_data(),
    name.map = name_map
  )

  expect_s3_class(plot, "patchwork")
  expect_s3_class(plot, "ggplot")
  expect_length(plot, 2)
  expect_equal(as.numeric(plot[[1]]$theme$plot.margin)[2], 2)
  expect_equal(as.numeric(plot[[2]]$theme$plot.margin)[4], 2)
  expected_levels <- oc_missing_levels()
  expected_levels[match(names(name_map), expected_levels)] <- name_map
  expect_setequal(levels(plot[[1]]$data$label), expected_levels)
  expect_equal(
    unique(plot[[1]]$data$.strip_label.),
    "Distribution of Missing Values"
  )
  expect_equal(
    unique(plot[[2]]$data$.strip_label.),
    "Percentage of Missing Values"
  )
  expect_silent(render_plot(plot))
})

test_that("plt_na returns the reversed combined plot", {
  plot <- plt_na(oc_data(), output = "both_reverse")

  expect_s3_class(plot, "patchwork")
  expect_length(plot, 2)
  expect_equal(as.numeric(plot[[1]]$theme$plot.margin)[2], 2)
  expect_equal(as.numeric(plot[[2]]$theme$plot.margin)[4], 2)
  expect_equal(plot[[1]]$scales$get_scales("y")$limits, c(-100, 0))
  expect_false(inherits(plot[[1]]$theme$axis.text.y, "element_blank"))
  expect_true(inherits(plot[[2]]$theme$axis.text.y, "element_blank"))
  expect_equal(
    unique(plot[[1]]$data$.strip_label.),
    "Percentage of Missing Values"
  )
  expect_equal(
    unique(plot[[2]]$data$.strip_label.),
    "Distribution of Missing Values"
  )
  expect_silent(render_plot(plot))
})

test_that("plt_na places combined legends at the top", {
  regular <- plt_na(oc_data(), output = "both")
  reversed <- plt_na(oc_data(), output = "both_reverse")

  expect_identical(regular[[2]]$theme$legend.position, "top")
  expect_identical(reversed[[1]]$theme$legend.position, "top")
})

test_that("plt_na returns one missingness matrix", {
  plot <- plt_na(oc_data(), output = "matrix")

  expect_s3_class(plot, "ggplot")
  expect_setequal(levels(plot$data$label), names(oc_missing_rates()))
  expect_silent(render_plot(plot))
})

test_that("plt_na returns one percentage plot", {
  plot <- plt_na(oc_data(), output = "percentage")

  expect_s3_class(plot, "ggplot")
  expect_equal(plot$scales$get_scales("y")$limits, c(0, 100))
  expect_equal(plot$scales$get_scales("y")$expand, c(0, 0))
  expect_silent(render_plot(plot))
})

test_that("plt_na keeps the Present bar with floating-point percentages", {
  plot <- plt_na(
    data.frame(lab = c(rep(1, 365), rep(NA_real_, 10))),
    output = "percentage"
  )
  bars <- ggplot2::ggplot_build(plot)$data[[1]]

  expect_true(all(is.finite(bars$ymax)))
})

test_that("plt_na orders variables by missing rate", {
  descending <- plt_na(oc_data(), output = "percentage", sort = "desc")
  ascending <- plt_na(oc_data(), output = "matrix", sort = "asc")
  missing_rate <- oc_missing_rates()

  expect_equal(
    unname(missing_rate[levels(descending$data$label)]),
    sort(unname(missing_rate), decreasing = TRUE)
  )
  expect_equal(
    unname(missing_rate[levels(ascending$data$label)]),
    sort(unname(missing_rate), decreasing = FALSE)
  )
})

test_that("plt_na renders a variable with all values missing", {
  plot <- plt_na(
    data.frame(complete = 1:4, all_missing = rep(NA_real_, 4)),
    output = "percentage"
  )

  expect_silent(render_plot(plot))
})

test_that("plt_na applies the missing-value palette", {
  plot <- plt_na(
    oc_data(),
    output = "matrix",
    miss_palette = c("#111111", "#222222", "#333333")
  )
  fills <- unique(ggplot2::ggplot_build(plot)$data[[1]]$fill)

  expect_setequal(fills, c("#111111", "#222222"))
})

test_that("plt_na rejects an unsupported output", {
  expect_snapshot(error = TRUE, plt_na(oc_data(), output = "unsupported"))
})

test_that("plt_na warns and returns NULL when no values are missing", {
  expect_snapshot(
    result <- plt_na(data.frame(x = 1:3, y = letters[1:3]))
  )
  expect_null(result)
})
