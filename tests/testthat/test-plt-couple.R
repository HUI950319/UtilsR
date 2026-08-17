couple_data <- function(n = 60L) {
  set.seed(11)
  group <- factor(rep(c("A", "B", "C"), each = n / 3L))
  data.frame(
    group = group,
    x1 = rnorm(n, as.numeric(group) * 0.8),
    x2 = rnorm(n) + as.numeric(group) * 0.4,
    x3 = rnorm(n),
    stringsAsFactors = FALSE
  )
}

render_couple <- function(plot) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  suppressWarnings(print(plot))
}

couple_link_data <- function(plot) {
  layers <- Filter(
    function(layer) {
      inherits(layer$geom, "GeomCurve2")
    },
    plot$layers
  )
  expect_length(layers, 1L)
  layers[[1L]]$data
}

skip_if_linket_missing <- function() {
  if (!suppressWarnings(requireNamespace("linkET", quietly = TRUE))) {
    testthat::skip("linkET is not installed")
  }
}

test_that("plt_couple exposes the requested interface", {
  expect_true("group" %in% names(formals(plt_couple)))
  expect_true("save" %in% names(formals(plt_couple)))
  expect_false(any(
    c("group_col", "filename", "width", "height", "dpi") %in%
      names(formals(plt_couple))
  ))
})

test_that("plt_couple supports Pearson, Spearman, and Kendall links", {
  skip_if_linket_missing()
  data <- couple_data()

  for (method in c("pearson", "spearman", "kendall")) {
    plot <- plt_couple(
      data,
      group = "group",
      vars = c("x1", "x2"),
      cor_method = method,
      link_method = "correlation"
    )
    expect_s3_class(plot, "ggplot")
    expect_silent(render_couple(plot))
  }
})

test_that("plt_couple retains the Mantel link method", {
  skip_if_linket_missing()
  skip_if_not_installed("vegan")
  plot <- plt_couple(
    couple_data(),
    group = "group",
    vars = c("x1", "x2"),
    link_method = "mantel"
  )

  expect_s3_class(plot, "ggplot")
  expect_silent(render_couple(plot))
})

test_that("randomForest importance links are scaled and reproducible", {
  skip_if_linket_missing()
  skip_if_not_installed("randomForest")
  data <- couple_data()

  plot1 <- plt_couple(
    data,
    group = "group",
    vars = c("x1", "x2"),
    link_method = "importance",
    model = "randomForest",
    n_perm = 3L,
    seed = 21L
  )
  plot2 <- plt_couple(
    data,
    group = "group",
    vars = c("x1", "x2"),
    link_method = "importance",
    model = "randomForest",
    n_perm = 3L,
    seed = 21L
  )
  links1 <- couple_link_data(plot1)
  links2 <- couple_link_data(plot2)

  expect_s3_class(plot1, "ggplot")
  expect_equal(nrow(links1), 6L)
  expect_true(all(links1$importance >= 0 & links1$importance <= 1))
  expect_true(all(links1$p.value >= 0 & links1$p.value <= 1))
  expect_equal(
    links1[c("spec", "env", "importance", "p.value")],
    links2[c("spec", "env", "importance", "p.value")]
  )
  expect_silent(render_couple(plot1))
})

test_that("xgboost importance links are scaled", {
  skip_if_linket_missing()
  skip_if_not_installed("xgboost")
  plot <- plt_couple(
    couple_data(),
    group = "group",
    vars = c("x1", "x2"),
    link_method = "importance",
    model = "xgboost",
    n_perm = 2L,
    seed = 21L
  )
  links <- couple_link_data(plot)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(links), 6L)
  expect_true(all(links$importance >= 0 & links$importance <= 1))
  expect_true(all(links$p.value >= 0 & links$p.value <= 1))
  expect_silent(render_couple(plot))
})

test_that("plt_couple validates required inputs", {
  data <- couple_data()

  expect_snapshot(error = TRUE, plt_couple(data, group = "missing"))
  expect_snapshot(
    error = TRUE,
    plt_couple(data, group = "group", vars = "group")
  )
  data$x2[1L] <- NA_real_
  expect_snapshot(error = TRUE, plt_couple(data, group = "group"))
  data <- couple_data()
  data$group <- factor("A", levels = "A")
  expect_snapshot(error = TRUE, plt_couple(data, group = "group"))
  expect_snapshot(
    error = TRUE,
    plt_couple(
      couple_data(),
      group = "group",
      link_method = "importance",
      n_perm = 0L
    )
  )
})

test_that("square geometry reports the ggplot2 compatibility requirement", {
  skip_if_linket_missing()
  if (utils::packageVersion("ggplot2") < numeric_version("4.0.0")) {
    testthat::skip("ggplot2 square geometry is supported in this version")
  }
  expect_snapshot(
    error = TRUE,
    plt_couple(couple_data(), group = "group", geom_type = "square")
  )
})

test_that("plt_couple forwards PDF saving through save_plt", {
  skip_if_linket_missing()
  skip_if_not_installed("RegR")
  output <- tempfile("plt_couple_")

  plot <- plt_couple(
    couple_data(),
    group = "group",
    vars = c("x1", "x2"),
    save = list(filename = output, width = 4, height = 3)
  )

  saved <- paste0(output, ".pdf")
  expect_s3_class(plot, "ggplot")
  expect_true(file.exists(saved))
  expect_gt(file.info(saved)[["size"]], 0)
  expect_silent(render_couple(plot))
})

test_that("plt_couple handles empty and invalid save arguments", {
  skip_if_linket_missing()
  expect_s3_class(plt_couple(couple_data(), "group", save = NULL), "ggplot")
  expect_s3_class(plt_couple(couple_data(), "group", save = list()), "ggplot")
  expect_snapshot(
    error = TRUE,
    plt_couple(couple_data(), "group", save = "plot.pdf")
  )
})
