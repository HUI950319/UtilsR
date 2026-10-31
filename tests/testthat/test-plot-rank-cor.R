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

test_that("the correlations print as a table named after the coefficient", {
  dat <- rank_cor_data()
  run <- function(...) utils::capture.output(p <- PlotRankCor(
    dat, stat.by = "item", value.by = "score", method.by = "method",
    show.label = FALSE, ...))
  out <- run()
  expect_true(any(grepl("^  group +rho +P$", out)))
  expect_false(any(grepl("rho =", out, fixed = TRUE)))
  # Pearson coefficients are r, as in the subtitle
  expect_true(any(grepl("^  group +r +P$", run(use_rank = FALSE))))
})

test_that("a saved rank correlation plot is announced with its size and the file state", {
  # no missing score, whose dropped point ggsave() would warn about
  dat <- rank_cor_data()
  dat$score[is.na(dat$score)] <- 1
  path <- withr::local_tempfile(fileext = ".pdf")
  saved <- function() {
    out <- cli::cli_fmt(utils::capture.output(PlotRankCor(
      dat, stat.by = "item", value.by = "score", method.by = "method",
      show.label = FALSE, filename = path, width = 6, height = 4)))
    gsub("\\s+", " ", paste(cli::ansi_strip(out), collapse = " "))
  }
  first <- saved()
  expect_match(first, "PlotRankCor: the plot has been saved to:", fixed = TRUE)
  expect_match(first, "[6x4 in, new PDF]", fixed = TRUE)
  expect_match(saved(), "[6x4 in, replaced the existing PDF]", fixed = TRUE)
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

test_that("rank-correlation working columns do not replace user identities", {
  data <- rank_cor_data()
  data$score[is.na(data$score)] <- 1
  original <- quiet_rank_cor(data)
  for (name in c(".group", ".plot_val", ".plot_val.item")) {
    x <- data; names(x)[names(x) == "item"] <- name
    invisible(capture.output(p <- PlotRankCor(x, name, "score", method.by = "method", show.label = FALSE)))
    expect_identical(sort(as.character(p$data[[name]])), letters[1:4])
    expect_equal(attr(p, "cor_results"), attr(original, "cor_results"))
  }
})

test_that("rank-correlation method names do not collide with id or size columns", {
  data <- rank_cor_data(); data$score[is.na(data$score)] <- 1
  reference <- quiet_rank_cor(data)
  data$method[data$method == "M1"] <- "item"
  p <- quiet_rank_cor(data)
  expect_identical(p$data$item, reference$data$item)
  expect_equal(attr(p, "cor_results"), attr(reference, "cor_results"))
  data <- rank_cor_data(); data$score[is.na(data$score)] <- 1
  data$M1 <- rep(10:13, 2)
  p <- quiet_rank_cor(data, size_by = "M1")
  expect_equal(attr(p, "cor_results"), attr(reference, "cor_results"))
  expect_equal(ggplot2::ggplot_build(p)$data[[1]]$x,
               ggplot2::ggplot_build(reference)$data[[1]]$x)
})

test_that("rank-correlation tuple keys keep separator-bearing identities distinct", {
  data <- expand.grid(item = letters[1:4], group = c("G", "H"), method = c("M1", "M2"))
  data$score <- rep(c(4, 1, 3, 2), 4)
  data$weight <- seq_len(nrow(data))
  reference <- quiet_rank_cor(data, group.by = "group", size_by = "weight")
  data$item <- as.character(data$item); data$group <- as.character(data$group)
  data$item[data$group == "G"] <- paste0("x|||", data$item[data$group == "G"])
  data$group[data$group == "H"] <- "x|||H"
  p <- quiet_rank_cor(data, group.by = "group", size_by = "weight")
  expect_equal(nrow(p$data), nrow(reference$data))
  expect_equal(sort(p$data$weight), sort(reference$data$weight))
  expect_equal(attr(p, "cor_results")$rho, attr(reference, "cor_results")$rho)

  # These two distinct tuples have identical pasted text keys.
  data <- data.frame(item = rep(c("a|||b", "a"), 2),
                     group = rep(c("c", "b|||c"), 2),
                     method = rep(c("M1", "M2"), each = 2), score = 1:4, weight = 1:4)
  p <- quiet_rank_cor(data, group.by = "group", size_by = "weight")
  expect_equal(nrow(p$data), 2L)
  expect_equal(sort(p$data$weight), c(2, 3))
})

test_that("rank-correlation tuple keys keep dotted ranks and pairings distinct", {
  data <- expand.grid(item = letters[1:3], group = c("g", "g.m"), method = c("m.x", "x"))
  data$score <- seq_len(nrow(data))
  p <- quiet_rank_cor(data, group.by = "group")
  expect_equal(nrow(p$data), 6L)
  expect_equal(sort(p$data[["m.x"]]), rep(1:3, each = 2))
  expect_equal(sort(p$data$x), rep(1:3, each = 2))
  data <- data.frame(item = rep(c("a.b", "a"), 2), group = rep(c("c", "b.c"), 2),
                     method = rep(c("M1", "M2"), each = 2), score = 1:4)
  p <- quiet_rank_cor(data, group.by = "group")
  expect_equal(nrow(p$data), 2L)
})

test_that("duplicate ranks and approximate Spearman tests retain their contract", {
  data <- data.frame(item = c("a", "a", "b", "c", "d", letters[1:4]),
                     method = rep(c("M1", "M2"), c(5, 4)),
                     score = c(100, 0, 49, 48, 47, 100, 49, 48, 47))
  p <- quiet_rank_cor(data)
  expect_equal(p$data$M1, c(3, 2, 3, 4))
  expected <- stats::cor.test(c(3, 2, 3, 4), 1:4, method = "spearman", exact = FALSE)
  expect_equal(attr(p, "cor_results")$rho, unname(expected$estimate))
  expect_equal(attr(p, "cor_results")$p.value, expected$p.value)
  data <- rank_cor_data(); data$score <- rep(4:1, 2)
  expect_equal(attr(quiet_rank_cor(data), "cor_results")$p.value, 0)
})

test_that("rank-correlation missing groups retain points and valid statistics", {
  data <- rank_cor_data(); data$score <- rep(4:1, 2)
  data$group <- NA_character_
  for (ranked in c(TRUE, FALSE)) {
    p <- quiet_rank_cor(data, group.by = "group", use_rank = ranked, scale_x = "minmax")
    expect_equal(nrow(p$data), 4L)
    expect_equal(attr(p, "cor_results")$rho, 1)
    expect_identical(unique(p$data$group), "<NA>")
  }
  data <- rbind(data, transform(data, group = "<NA>"), transform(data, group = "G"))
  p <- quiet_rank_cor(data, group.by = "group")
  expect_equal(nrow(p$data), 12L)
  expect_equal(length(unique(p$data$group)), 3L)
  expect_equal(attr(p, "cor_results")$rho, rep(1, 3))
  expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
})

test_that("rank-correlation handles explicit NA factor levels and rejects missing methods", {
  data <- rank_cor_data(); data$score <- rep(4:1, 2)
  data$group <- factor(rep(NA_character_, nrow(data)), exclude = NULL)
  p <- quiet_rank_cor(data, group.by = "group")
  expect_equal(attr(p, "cor_results")$rho, 1)
  data$method[1] <- NA_character_
  expect_error(quiet_rank_cor(data), "method.by.*missing|missing.*method.by")
})

test_that("rank-correlation labelled scores respect declared missing values", {
  skip_if_not_installed("haven")
  data <- rank_cor_data()
  data$score <- c(4, 3, 2, 99, 3, 1, 2, 4)
  data$score <- haven::labelled_spss(data$score, labels = c(missing = 99), na_values = 99)
  p <- quiet_rank_cor(data)
  expect_true(is.na(p$data$M1[p$data$item == "d"]))
  expect_equal(attr(p, "cor_results")$rho, 0.5)
  reference <- rank_cor_data()
  expect_equal(attr(p, "cor_results"), attr(quiet_rank_cor(reference), "cor_results"))
  p <- quiet_rank_cor(data, use_rank = FALSE)
  expect_true(is.na(p$data$M1[p$data$item == "d"]))
})

test_that("rank-correlation normalizes data-frame subclasses without changing inputs", {
  skip_if_not_installed("dplyr")
  data <- rank_cor_data()
  expected <- quiet_rank_cor(data)
  for (x in list(dplyr::group_by(data, method), dplyr::rowwise(data))) {
    before <- x
    p <- quiet_rank_cor(x)
    expect_equal(p$data, expected$data)
    expect_identical(x, before)
  }
})

test_that("rank-correlation integer64 scores keep missing values and close ranks", {
  skip_if_not_installed("bit64")
  data <- rank_cor_data()
  data$score <- bit64::as.integer64(c("9007199254740996", "9007199254740995", "9007199254740994", NA,
                                    "9007199254740995", "9007199254740993", "9007199254740994", "9007199254740996"))
  p <- quiet_rank_cor(data)
  expect_equal(p$data$M1, c(1, 2, 3, NaN))
  expect_equal(p$data$M2, c(2, 4, 3, 1))
  expect_equal(attr(p, "cor_results")$rho, 0.5)
  expect_error(quiet_rank_cor(data, use_rank = FALSE), "integer64.*precision|precision.*integer64")
})

test_that("rank-correlation validates data and scalar column selectors", {
  data <- rank_cor_data()
  expect_error(quiet_rank_cor(as.list(data)), "data.*data.frame")
  expect_error(quiet_rank_cor(data[FALSE, ]), "observation")
  names(data)[3] <- "item"
  expect_error(quiet_rank_cor(data), "unique.*column names")
  data <- rank_cor_data()
  for (arg in c("stat.by", "value.by", "method.by", "group.by", "size_by", "alpha_by")) {
    args <- list(data = data, stat.by = "item", value.by = "score", method.by = "method")
    for (bad in list(character(), c("item", "score"), NA_character_, "")) {
      args[[arg]] <- bad
      expect_error(do.call(PlotRankCor, args), paste0(arg, ".*single.*column name"))
    }
  }
})

test_that("rank-correlation rejects unsupported selected-column storage", {
  data <- rank_cor_data()
  for (bad in list(factor(data$score), as.character(data$score), as.list(data$score),
                  matrix(seq_len(16), nrow = 8), as.POSIXct(seq_len(8), origin = "1970-01-01"),
                  complex(real = seq_len(8)))) {
    data$score <- bad
    expect_error(quiet_rank_cor(data), "score.*numeric|one-dimensional")
  }
})

test_that("rank-correlation validates switches and numeric aesthetic controls", {
  data <- rank_cor_data()
  for (arg in c("use_rank", "show.label", "show.diag")) {
    for (bad in list(NA, 1, c(TRUE, FALSE))) {
      expect_error(do.call(PlotRankCor, c(list(data = data, stat.by = "item", value.by = "score", method.by = "method"),
                                         setNames(list(bad), arg))),
                   paste0(arg, ".*TRUE.*FALSE"))
    }
  }
  for (args in list(list(size_range = 1), list(size_range = c(-1, 2)), list(alpha_range = c(0, 2)),
                    list(alpha = NA_real_), list(pt.size = -1), list(max.overlaps = 1.5),
                    list(width = 0), list(filename = c("a.pdf", "b.pdf")),
                    list(use_rank = FALSE, scale_x = c("none", "rank")))) {
    expect_error(do.call(quiet_rank_cor, c(list(data = data), args)))
  }
  expect_s3_class(quiet_rank_cor(data, size_by = "score", size_range = c(6, 1)), "ggplot")
})

test_that("rank-correlation factor methods keep axes stable after row reordering", {
  data <- rank_cor_data(); data$score <- c(1, 2, 5, 10, 2, 3, 8, 9)
  data$method <- factor(data$method, levels = c("M1", "unused", "M2"))
  reference <- quiet_rank_cor(data, use_rank = FALSE, scale_x = "log1p")
  data <- data[c(5:8, 1:4), ]
  p <- quiet_rank_cor(data, use_rank = FALSE, scale_x = "log1p")
  expect_identical(p$labels$x, "M1 (log1p)")
  expect_identical(p$labels$y, "M2 (value)")
  expect_equal(p$data, reference$data)
  expect_equal(attr(p, "cor_results"), attr(reference, "cor_results"))
  data$method <- as.character(data$method)
  p <- quiet_rank_cor(data)
  expect_identical(p$labels$x, "M2 (rank)")
})

test_that("rank-correlation palette names determine group colours", {
  data <- expand.grid(item = letters[1:4], group = c("G", "H"), method = c("M1", "M2"))
  data$score <- rep(4:1, 4)
  palette <- c(H = "blue", G = "red")
  p <- quiet_rank_cor(data, group.by = "group", palette = palette)
  expect_equal(ggplot2::ggplot_build(p)$data[[1]]$colour, unname(palette[as.character(p$data$group)]))
  expect_error(quiet_rank_cor(data, group.by = "group", palette = c(G = "red")), "palette.*group|group.*palette")
  expect_error(quiet_rank_cor(data, group.by = "group", palette = c(G = "red", G = "blue")), "palette.*unique")
})

test_that("rank-correlation default palettes cover more than fifteen groups", {
  data <- expand.grid(item = letters[1:3], group = paste0("G", 1:16), method = c("M1", "M2"))
  data$score <- rep(3:1, 32)
  p <- quiet_rank_cor(data, group.by = "group")
  built <- ggplot2::ggplot_build(p)
  expect_length(unique(built$data[[1]]$colour), 16L)
  p <- quiet_rank_cor(data, group.by = "group", palette = "red")
  expect_identical(unique(ggplot2::ggplot_build(p)$data[[1]]$colour), "red")
})

test_that("rank-correlation facets accept non-syntactic column names", {
  for (name in c("group name", "g+1", "g`roup")) {
    data <- expand.grid(item = letters[1:4], group = c("G", "H"), method = c("M1", "M2"))
    data$score <- rep(4:1, 4)
    names(data)[names(data) == "group"] <- name
    p <- quiet_rank_cor(data, group.by = name)
    built <- ggplot2::ggplot_build(p)
    expect_equal(nrow(built$layout$layout), 2L)
    expect_equal(as.character(built$layout$layout[[name]]), c("G", "H"))
  }
})

test_that("rank-correlation scaling remains finite for extreme numeric values", {
  data <- rank_cor_data(); data$score <- rep(c(-1, 0, 1, 0.5) * 1e308, 2)
  p <- quiet_rank_cor(data, use_rank = FALSE, scale_x = "minmax", scale_y = "zscore")
  expect_equal(p$data$M1, c(0, 0.5, 1, 0.75))
  expect_equal(p$data$M2, as.numeric(scale(c(-1, 0, 1, 0.5))))
  expect_equal(attr(p, "cor_results")$rho, 1)
  data$score <- rep(c(-1, 0, 1, 0.5) * 1e-300, 2)
  p <- quiet_rank_cor(data, use_rank = FALSE, scale_x = "zscore")
  expect_equal(p$data$M1, as.numeric(scale(c(-1, 0, 1, 0.5))))
  expect_equal(attr(p, "cor_results")$rho, 1)
})

test_that("rank-correlation tests use finite nonconstant pairs without warnings", {
  data <- rank_cor_data(); data$score <- c(Inf, 4, 3, 2, 5, 4, 3, 1)
  expect_no_warning(p <- quiet_rank_cor(data, use_rank = FALSE))
  expected <- stats::cor.test(c(4, 3, 2), c(4, 3, 1))
  expect_equal(attr(p, "cor_results")$rho, unname(expected$estimate))
  expect_equal(attr(p, "cor_results")$p.value, expected$p.value)
  data$score <- rep(1, 8)
  expect_no_warning(p <- quiet_rank_cor(data, use_rank = FALSE))
  expect_true(is.na(attr(p, "cor_results")$rho))
  expect_true(is.na(attr(p, "cor_results")$p.value))
})

test_that("rank-correlation distinguishes omitted and explicit legend positions", {
  data <- rank_cor_data()
  for (mapping in c("size_by", "alpha_by")) {
    args <- setNames(list("score"), mapping)
    hidden <- do.call(quiet_rank_cor, c(list(data = data, legend.position = "none"), args))
    expect_identical(hidden$theme$legend.position, "none")
    automatic <- do.call(quiet_rank_cor, c(list(data = data), args))
    expect_false(identical(automatic$theme$legend.position, "none"))
    right <- do.call(quiet_rank_cor, c(list(data = data, legend.position = "right"), args))
    expect_identical(right$theme$legend.position, "right")
  }
})
