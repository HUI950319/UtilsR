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

test_that("the complete similarity matrix retains symmetric and empty-set results", {
  groups <- c("A", "B", "C", "empty")
  dat <- data.frame(cell_type = factor(c("A", "A", "B", "B", "C"), levels = groups),
                    gene = c("g1", "g2", "g2", "g3", "g4"))
  expected <- rbind(c(1, 1/3, 0, 0), c(1/3, 1, 0, 0), c(0, 0, 1, 0), c(0, 0, 0, 0))
  dimnames(expected) <- list(groups, groups)
  result <- PlotHeatmapJaccard(dat, return_type = "both")
  expect_identical(result$matrix, expected)
  expect_true(all(is.na(result$plot$data$Jaccard[result$plot$data$Group1 ==
                                                result$plot$data$Group2])))
})

test_that("axis strips keep valid colours beyond the default palette length", {
  dat <- data.frame(cell_type = sprintf("G%02d", 1:17), gene = paste0("gene", 1:17))
  plot <- PlotHeatmapJaccard(dat, show_strip = TRUE, text_size = 0)
  layers <- ggplot2::ggplot_build(plot)$data
  bottom <- layers[[2L]]$fill
  left <- layers[[3L]]$fill
  expect_length(bottom, 17)
  expect_false(anyNA(bottom))
  expect_identical(left, bottom)
  expect_identical(bottom[c(1L, 16L)], c("#E41A1C", "#B3B3B3"))
  expect_identical(bottom[17L], bottom[1L])
  expect_s3_class(ggplot2::ggplotGrob(plot), "gtable")

  custom <- PlotHeatmapJaccard(dat, show_strip = TRUE, text_size = 0,
                              strip_colors = c("red", "blue"))
  expect_identical(ggplot2::ggplot_build(custom)$data[[2L]]$fill,
                   rep_len(c("red", "blue"), 17))
})
