test_that("missing group labels do not create groups or shared features", {
  dat <- data.frame(cell_type = c("A", "B", NA), gene = c("a", "b", "orphan"))
  result <- PlotHeatmapJaccard(dat, return_type = "both")
  expected <- diag(2)
  dimnames(expected) <- list(c("A", "B"), c("A", "B"))
  expect_identical(result$matrix, expected)
  expect_s3_class(ggplot2::ggplot_build(result$plot), "ggplot_built")
})

test_that("missing feature names do not count as a shared feature", {
  dat <- data.frame(cell_type = c("A", "A", "B", "B"),
                    gene = c("a", NA, "b", NA))
  result <- PlotHeatmapJaccard(dat, return_type = "data")
  expect_equal(result["A", "B"], 0)
  expect_equal(diag(result), c(A = 1, B = 1))
  dat$gene[dat$cell_type == "A"] <- NA_character_
  result <- PlotHeatmapJaccard(dat, return_type = "data")
  expect_equal(result["A", "A"], 0)
  expect_equal(result["A", "B"], 0)
})

test_that("group order, duplicate features, and empty-set convention are retained", {
  dat <- data.frame(cell_type = factor(c("A", "A", "A", "B"),
                                      levels = c("B", "A", "empty")),
                    gene = c("a", "b", "a", "b"))
  result <- PlotHeatmapJaccard(dat, return_type = "data")
  expect_identical(rownames(result), c("B", "A", "empty"))
  expect_equal(result["A", "B"], 0.5)
  expect_equal(result["empty", ], c(B = 0, A = 0, empty = 0))
  reversed <- PlotHeatmapJaccard(dat, group_levels = c("A", "B"), return_type = "data")
  expect_identical(rownames(reversed), c("A", "B"))
  expect_equal(unname(reversed), unname(result[c("A", "B"), c("A", "B")]))
})

test_that("data without non-missing groups fails clearly", {
  dat <- data.frame(cell_type = NA_character_, gene = "orphan")
  expect_error(PlotHeatmapJaccard(dat), "No non-missing groups")
  expect_error(PlotHeatmapJaccard(dat[FALSE, ]), "No non-missing groups")
})
