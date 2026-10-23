rank_cor_data <- function() {
  data.frame(item = rep(letters[1:4], 2), method = rep(c("M1", "M2"), each = 4),
             score = c(4, 3, 2, NA, 3, 1, 2, 4))
}

quiet_rank_cor <- function(data, ...) {
  invisible(utils::capture.output(p <- PlotRankCor(
    data, stat.by = "item", value.by = "score", method.by = "method",
    show.label = FALSE, ...)))
  p
}

test_that("missing scores do not acquire ranks or enter correlations", {
  dat <- rank_cor_data()
  p <- quiet_rank_cor(dat)
  expect_true(is.na(p$data$M1[p$data$item == "d"]))
  expected <- stats::cor.test(c(1, 2, 3), c(2, 4, 3), method = "spearman",
                              exact = FALSE)
  expect_equal(attr(p, "cor_results")$rho, unname(expected$estimate))
  expect_equal(attr(p, "cor_results")$p.value, expected$p.value)
  points <- ggplot2::ggplot_build(p)$data[[1L]]
  expect_equal(sum(stats::complete.cases(points[, c("x", "y")])), 3)

  raw <- quiet_rank_cor(dat, use_rank = FALSE, scale_x = "rank")
  expect_true(is.na(raw$data$M1[raw$data$item == "d"]))
  dat$score[dat$method == "M1"] <- NA_real_
  empty <- quiet_rank_cor(dat)
  expect_true(all(is.na(empty$data$M1)))
  expect_true(is.na(attr(empty, "cor_results")$rho))
  expect_true(is.na(attr(empty, "cor_results")$p.value))
})

test_that("minmax scaling preserves missing values and handles empty ranges", {
  dat <- rank_cor_data()
  dat$score[dat$method == "M1"] <- c(5, 5, NA, NA)
  p <- quiet_rank_cor(dat, use_rank = FALSE, scale_x = "minmax")
  expect_equal(p$data$M1[match(letters[1:4], p$data$item)], c(0, 0, NA, NA))
  dat$score[dat$method == "M1"] <- NA_real_
  expect_warning(p <- quiet_rank_cor(dat, use_rank = FALSE, scale_x = "minmax"), NA)
  expect_true(all(is.na(p$data$M1)))
})

test_that("zscore scaling handles sparse values on either axis", {
  for (axis in c("x", "y")) {
    method <- if (axis == "x") "M1" else "M2"
    scaling <- stats::setNames(list("zscore"), paste0("scale_", axis))
    for (values in list(rep(NA_real_, 4), c(5, NA, NA, NA))) {
      dat <- rank_cor_data()
      dat$score[dat$method == method] <- values
      p <- do.call(quiet_rank_cor, c(list(data = dat, use_rank = FALSE), scaling))
      expect_true(all(is.na(p$data[[method]])))
      expect_true(is.na(attr(p, "cor_results")$rho))
    }
    dat$score[dat$method == method] <- c(5, 5, NA, NA)
    p <- do.call(quiet_rank_cor, c(list(data = dat, use_rank = FALSE), scaling))
    expect_equal(p$data[[method]][match(letters[1:4], p$data$item)], c(0, 0, NA, NA))
  }
})

test_that("ordinary scaling still uses the observed range and sample sd", {
  dat <- rank_cor_data()
  p <- quiet_rank_cor(dat, use_rank = FALSE, scale_x = "minmax", scale_y = "zscore")
  expect_equal(p$data$M1[match(letters[1:4], p$data$item)], c(1, 0.5, 0, NA))
  expect_equal(p$data$M2[match(letters[1:4], p$data$item)], as.numeric(scale(c(3, 1, 2, 4))))
  expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
})
