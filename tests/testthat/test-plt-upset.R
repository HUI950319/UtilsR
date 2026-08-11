bmi_missing_data <- function() {
  data.frame(
    BMI_1 = c(1, NA, 3, 4, NA, 6),
    BMI_2 = c(NA, 2, NA, 4, NA, 6),
    BMI_3 = c(1, 2, NA, NA, NA, 6),
    other = c(NA, 2, 3, 4, 5, 6)
  )
}

render_upset <- function(plot) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  print(plot)
}

test_that("plt_upset plots missing-value membership", {
  skip_if_not_installed("ggVennDiagram")

  plot <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "upset"
  )

  expect_s3_class(plot, "upset_plot")
  expect_silent(render_upset(plot))
})

test_that("plt_upset assigns the expected missing-value intersections", {
  skip_if_not_installed("ggVennDiagram")

  result <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "data"
  )

  expect_equal(
    as.character(result$intersect_group),
    c(
      "BMI_2",
      "BMI_1",
      "BMI_2/BMI_3",
      "BMI_3",
      "BMI_1/BMI_2/BMI_3",
      "None"
    )
  )
})

test_that("plt_upset limits missing-value intersections to vars", {
  skip_if_not_installed("ggVennDiagram")

  result <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2"),
    levels = NA,
    output = "data"
  )

  expect_identical(as.character(result$intersect_group[1]), "BMI_2")
  expect_length(
    grep("other", levels(result$intersect_group), fixed = TRUE),
    0L
  )
})

test_that("plt_upset supports missing values across column types", {
  skip_if_not_installed("ggVennDiagram")

  data <- data.frame(
    numeric = c(1, NA, 3, 4),
    character = c("a", "b", NA, "d"),
    factor = factor(c("x", "y", "z", NA))
  )
  original <- data

  result <- plt_upset(
    data,
    vars = names(data),
    levels = NA,
    output = "data"
  )

  expect_equal(
    as.character(result$intersect_group),
    c("None", "numeric", "character", "factor")
  )
  expect_identical(data, original)
})

test_that("plt_upset hides zero intersections and preserves value membership", {
  skip_if_not_installed("ggVennDiagram")

  missing_plot <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "upset"
  )
  intersections <- unique(missing_plot$plotlist[[2]]$data[c("name", "size")])

  expect_equal(nrow(intersections), 5L)
  expect_gt(min(intersections$size), 0L)

  binary <- data.frame(
    A = c("Yes", "No", "Yes"),
    B = c("No", "Yes", "Yes")
  )
  result <- plt_upset(binary, vars = c("A", "B"), output = "data")

  expect_equal(as.character(result$intersect_group), c("A", "B", "A/B"))
})
