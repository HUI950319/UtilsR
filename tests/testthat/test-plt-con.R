con_data <- function() {
  data.frame(
    x = c(1:6, 10:15), z = c(101:106, 110:115),
    g = factor(rep(c("A", "B"), each = 6)),
    batch = factor(rep(c("S1", "S2"), 6))
  )
}

con_plot <- function(data, stat.by = "x", group.by = "g", ...) {
  suppressMessages(plt_con(data, stat.by, group.by, combine = FALSE, ...))[[1L]]
}

test_that("con inputs exclude SPSS user missing values from each numeric feature", {
  skip_if_not_installed("haven")
  d <- data.frame(x = haven::labelled_spss(c(1, 99, 2), na_values = 99), g = "A")
  p <- con_plot(d, type = "bar")
  expect_equal(p$data$value, c(1, 2))
  expect_equal(ggplot2::ggplot_build(p)$data[[2L]]$y, 1.5)
  d$z <- haven::labelled_spss(c(3, 98, 4), na_range = c(97, 99))
  q <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE)
  expect_equal(q$data$value, c(1, 2, 3, 4))
  expect_equal(ggplot2::ggplot_build(q)$data[[2L]]$y, c(1.5, 3.5))
})

test_that("con inputs recognize SPSS missing grouping and splitting codes", {
  skip_if_not_installed("haven")
  d <- data.frame(x = 1:4, g = haven::labelled_spss(c(1, 99, 1, 2), na_values = 99))
  p <- con_plot(d, type = "bar")
  expect_false("99" %in% levels(p$data$group.by))
  expect_equal(sum(is.na(p$data$group.by)), 1L)
  d$batch <- haven::labelled_spss(c(1, 99, 1, 2), na_values = 99)
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "bar"))
  expect_length(out, 2L)
})

test_that("con inputs reject unsupported numeric storage and matrix columns", {
  skip_if_not_installed("bit64")
  d <- data.frame(x = bit64::as.integer64(c("9007199254740993", NA, "9007199254740994")), g = "A")
  expect_error(con_plot(d, type = "bar"), "integer64")
  d$x <- matrix(1:6, nrow = 3L)
  expect_error(con_plot(d, type = "box"), "one-dimensional")
  if (requireNamespace("lubridate", quietly = TRUE)) {
    d$x <- lubridate::seconds(1:3)
    expect_error(con_plot(d), "time-span")
  }
})

test_that("con inputs reject ambiguous columns and overlapping roles", {
  d <- data.frame(x = 1:3, z = 11:13, g = "A")
  names(d)[1:2] <- c("x", "x")
  expect_error(con_plot(d), "unique")
  d <- data.frame(x = rep(1:2, each = 3))
  expect_error(con_plot(d, group.by = "x"), "different|overlap")
  expect_error(con_plot(con_data(), group.by = c("g", "batch")), "group.by")
  expect_error(con_plot(con_data(), stat.by = NA_character_), "stat.by")
})

test_that("con inputs preserve a numeric variable named like the dummy group", {
  d <- data.frame(.all_groups = c(1, 2, 3))
  original <- d
  p <- con_plot(d, ".all_groups", group.by = NULL, type = "bar")
  expect_equal(p$data$value, 1:3)
  expect_equal(ggplot2::ggplot_build(p)$data[[2L]]$y, 2)
  expect_identical(d, original)
})

test_that("con bins draw constant dot data without losing counts", {
  d <- data.frame(x = rep(2, 6), z = rep(2, 6), g = "A")
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "dot", stack = stack)
    b <- ggplot2::ggplot_build(p)$data[[1L]]
    expect_equal(b$y, if (stack) c(2, 2) else 2)
    expect_equal(sum(p$layers[[1L]]$data$n), if (stack) 12L else 6L)
  }
})

test_that("con bins use numeric boundaries at large and tiny scales", {
  for (offset in c(0, 1e15)) {
    d <- data.frame(x = offset + 1:10, z = offset + 21:30, g = "A")
    for (stack in c(FALSE, TRUE)) {
      p <- con_plot(d, if (stack) c("x", "z") else "x", type = "dot", stack = stack)
      bins <- p$layers[[1L]]$data
      expect_true(all(bins$bins >= min(p$data$value)))
      expect_true(all(bins$bins <= max(p$data$value)))
      expect_equal(sum(bins$n), nrow(d) * if (stack) 2L else 1L)
    }
  }
  d <- data.frame(x = (1:10) * 1e-10, g = "A")
  p <- con_plot(d, type = "dot")
  expected_breaks <- seq(min(d$x), max(d$x), length.out = 15)
  ids <- cut(d$x, expected_breaks, include.lowest = TRUE, labels = FALSE)
  mids <- expected_breaks[-15L] + diff(expected_breaks) / 2
  expect_equal(sort(p$layers[[1L]]$data$bins), sort(unique(mids[ids])))
})

test_that("con dot bins are independent of unrelated feature scales in stacked plots", {
  d <- data.frame(x = 1:8, z = 1e6 + 1:8, g = rep(c("A", "B"), 4))
  separate <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "dot", combine = FALSE))
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE, flip = flip)
    at <- p$layers[[1L]]$data
    for (feature in c("x", "z")) {
      expected <- separate[[feature]]$layers[[1L]]$data
      actual <- at[at$feature == feature, c("group.by", "bins", "n")]
      expect_equal(actual$bins, expected$bins)
      expect_equal(actual$n, expected$n)
      expect_equal(as.character(actual$group.by), as.character(expected$group.by))
    }
  }
})

test_that("con dot counts include observed missing grouping strata", {
  d <- data.frame(x = 1:4, z = 11:14, g = c("A", NA, "B", NA))
  for (stack in c(FALSE, TRUE)) for (fill in c("group", "feature")) {
    p <- con_plot(d, c("x", "z"), type = "dot", stack = stack, fill.by = fill)
    counts <- p$layers[[1L]]$data
    expect_equal(sum(counts$n), if (stack) 8L else 4L)
    expect_equal(sum(counts$n[is.na(counts$group.by)]), if (stack) 4L else 2L)
    expect_length(unique(ggplot2::ggplot_build(p)$data[[1L]]$x), 3L)
  }
  d$g <- NA_character_
  p <- con_plot(d, type = "dot")
  expect_equal(sum(p$layers[[1L]]$data$n), 4L)
})

test_that("con stacked comparisons test each feature separately", {
  d <- con_data()
  d$z <- c(1:6, (1:6) + 1.5)
  p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE,
               comparisons = list(c("A", "B")), multiplegroup_comparisons = TRUE)
  kinds <- vapply(p$layers, function(l) class(l$geom)[1L], character(1))
  expect_true("GeomSignif" %in% kinds)
  expect_true("GeomText" %in% kinds)
  b <- ggplot2::ggplot_build(p)$data
  bracket <- b[[which(kinds == "GeomSignif")]]
  global <- b[[which(kinds == "GeomText")]]
  expect_equal(as.character(tapply(bracket$annotation, bracket$PANEL, unique)), c("**", "ns"))
  expect_equal(as.character(global$label), c("**", "ns"))
})

test_that("con unavailable comparisons preserve valid tests in each feature", {
  d <- data.frame(x = 1:18, z = 51:68, g = factor(rep(c("A", "B", "C"), each = 6)))
  d$z[d$g == "C"] <- NA_real_
  pairs <- list(c("A", "B"), c("A", "C"))
  for (stack in c(FALSE, TRUE)) {
    expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
                       comparisons = pairs, stack = stack, combine = FALSE)), "Skipping.*z")
    p <- out[[if (stack) 1L else 2L]]
    expect_no_warning(b <- ggplot2::ggplot_build(p))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    if (stack) {
      expect_equal(as.integer(table(brackets$PANEL)), c(6L, 3L))
    } else {
      expect_equal(nrow(brackets), 3L)
    }
  }
})

test_that("con reference groups generate pairwise tests unless explicit pairs are supplied", {
  d <- data.frame(x = 1:18, z = 21:38, g = factor(rep(c("A", "B", "C"), each = 6)))
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack, ref_group = "B")
    q <- con_plot(d, c("x", "z"), type = "box", stack = stack,
                 comparisons = list(c("B", "A"), c("B", "C")))
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
  }
  p <- con_plot(d, type = "box", ref_group = "B", comparisons = list(c("A", "C")))
  q <- con_plot(d, type = "box", comparisons = list(c("A", "C")))
  expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
  expect_error(con_plot(d, type = "box", ref_group = "absent"), "ref_group")
})

test_that("con failed pairwise tests preserve successful comparisons per feature", {
  d <- data.frame(x = 1:18, z = 51:68, g = factor(rep(c("A", "B", "C"), each = 6)))
  d$x[14:18] <- NA_real_
  pairs <- list(c("A", "B"), c("A", "C"))
  for (stack in c(FALSE, TRUE)) for (label in c("p.signif", "p.format")) {
    expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
      comparisons = pairs, pairwise_method = "t.test", sig_label = label,
      stack = stack, combine = FALSE)), "Skipping.*comparison.*x")
    p <- out[[1L]]
    expect_no_warning(b <- ggplot2::ggplot_build(p))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    expect_equal(as.integer(table(brackets$PANEL)), if (stack) c(3L, 6L) else 3L)
    q <- con_plot(d, type = "box", comparisons = pairs[1L], pairwise_method = "t.test", sig_label = label)
    expected <- tail(ggplot2::ggplot_build(q)$data, 1L)[[1L]]$annotation
    expect_identical(brackets$annotation[brackets$PANEL == 1L], expected)
  }
})

test_that("con global test labels fit inside normal and flipped panels", {
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = stack, flip = flip,
                 multiplegroup_comparisons = TRUE, sig_label = "p.format")
    g <- ggplot2::ggplotGrob(p)
    for (i in grep("^panel", g$layout$name)) {
      labels <- Filter(function(child) inherits(child, "text") && any(grepl("^p = ", child$label)),
                       g$grobs[[i]]$children)
      expect_length(labels, 1L)
      for (label in labels) {
        width <- grid::convertWidth(grid::grobWidth(label), "in", valueOnly = TRUE) / 3.5
        expect_lte(as.numeric(label$x) + (1 - label$hjust) * width, 1)
        expect_gte(as.numeric(label$x) - label$hjust * width, 0)
      }
    }
  }
})

test_that("con comparison axes reserve automatic space and retain explicit zoom bounds", {
  d <- data.frame(x = 1:18, z = 51:68, g = factor(rep(c("A", "B", "C"), each = 6)))
  pairs <- list(c("A", "B"), c("A", "C"), c("B", "C"))
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip,
                 same.y.lims = TRUE, comparisons = pairs)
    b <- ggplot2::ggplot_build(p)
    axis <- if (flip) "x.range" else "y.range"
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    brackets <- do.call(rbind, b$data[which(kinds == "GeomSignif")])
    limits <- lapply(b$layout$panel_params, `[[`, axis)
    expect_equal(limits[[1L]], limits[[2L]])
    expect_gt(limits[[1L]][2L], max(c(brackets$y, brackets$yend)))
    for (stack in c(FALSE, TRUE)) {
      q <- con_plot(d, c("x", "z"), type = "box", stack = stack, flip = flip,
                   y.min = 0, y.max = 120, comparisons = pairs, multiplegroup_comparisons = TRUE)
      expect_equal(q$coordinates$limits$y, c(0, 120))
    }
  }
  d$z[d$g == "C"] <- NA_real_
  expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
                   same.y.lims = TRUE, comparisons = pairs, combine = FALSE)), "Skipping.*z")
  expect_equal(out[[1L]]$coordinates$limits$y, out[[2L]]$coordinates$limits$y)
})

test_that("con stacked dot plots retain requested raw point overlays", {
  d <- con_data()
  p <- con_plot(d, c("x", "z"), type = "dot", stack = TRUE, add_point = TRUE)
  expect_length(p$layers, 2L)
  b <- ggplot2::ggplot_build(p)$data
  expect_equal(nrow(b[[2L]]), 2L * nrow(d))
})

test_that("con stacked points inherit a dodge aesthetic under either fill mode", {
  for (stack in c(FALSE, TRUE)) for (fill in c("group", "feature")) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = stack,
                 fill.by = fill, add_point = TRUE)
    b <- ggplot2::ggplot_build(p)$data
    points <- b[[length(b)]]
    expect_equal(nrow(points), if (stack) 24L else 12L)
    expect_true(all(points$x > 0.5 & points$x < 2.5))
  }
})

test_that("con scales honor shared and independent stacked axes in both orientations", {
  for (flip in c(FALSE, TRUE)) {
    p <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE, flip = flip)
    b <- ggplot2::ggplot_build(p)
    axis <- if (flip) "x.range" else "y.range"
    independent <- lapply(b$layout$panel_params, `[[`, axis)
    expect_lt(independent[[1L]][2L], independent[[2L]][1L])
    q <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE,
                  same.y.lims = TRUE, flip = flip)
    shared <- lapply(ggplot2::ggplot_build(q)$layout$panel_params, `[[`, axis)
    expect_equal(shared[[1L]], shared[[2L]])
    expect_true(shared[[1L]][1L] <= 1 && shared[[1L]][2L] >= 115)
    explicit <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE,
                         y.min = 0, y.max = 200, flip = flip)
    limits <- lapply(ggplot2::ggplot_build(explicit)$layout$panel_params, `[[`, axis)
    expect_equal(limits[[1L]], limits[[2L]])
    expect_true(limits[[1L]][1L] <= 0 && limits[[1L]][2L] >= 200)
  }
})

test_that("con split panels retain group colours when local ordering changes", {
  d <- con_data()
  d$x <- c(1, 10, 2, 11, 3, 12, 13, 4, 14, 5, 15, 6)
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "bar",
                                  sort = TRUE, palette = c("red", "blue")))
  maps <- lapply(seq_len(length(out)), function(i) {
    p <- out[[i]]
    scale <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
    scale$map(c("A", "B"))
  })
  expect_identical(maps[[1L]], maps[[2L]])
  expect_setequal(maps[[1L]], c("red", "blue"))
})

test_that("con split palettes retain explicit missing factor levels", {
  d <- data.frame(x = 1:12, z = 21:32,
                  g = factor(rep(c("A", NA), 6), exclude = NULL),
                  batch = rep(c("S1", "S2"), each = 6))
  for (stack in c(FALSE, TRUE)) for (type in c("box", "bar", "dot")) {
    baseline <- con_plot(d, c("x", "z"), type = type, stack = stack)
    expected <- ggplot2::ggplot_build(baseline)$plot$scales$get_scales("fill")$map(c("A", NA))
    out <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch",
                                    type = type, stack = stack, combine = FALSE))
    expect_named(out, c("S1", "S2"))
    for (p in out) {
      expect_equal(nrow(p$data), if (stack) 12L else 6L)
      expect_equal(sum(is.na(as.character(p$data$group.by))), if (stack) 6L else 3L)
      b <- ggplot2::ggplot_build(p)
      expect_equal(b$plot$scales$get_scales("fill")$map(c("A", NA)), expected)
    }
  }
  d$g <- factor(rep(NA_character_, 12), exclude = NULL)
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "bar", combine = FALSE))
  expect_equal(vapply(out, function(p) nrow(p$data), 1L), c(S1 = 6L, S2 = 6L))
  expect_equal(ggplot2::ggplot_build(out[[1L]])$data[[2L]]$y, 3.5)
})

test_that("con group sorting uses finite observations without losing unranked groups", {
  d <- data.frame(x = c(1, Inf, Inf, 2, 3, 4), z = 11:16, g = rep(c("A", "B"), each = 3))
  p <- con_plot(d, type = "box", sort = TRUE)
  expect_identical(levels(p$data$group.by), c("B", "A"))
  p <- con_plot(d, type = "box", sort = "increasing")
  expect_identical(levels(p$data$group.by), c("A", "B"))
  d$x[1:3] <- Inf
  p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, sort = TRUE)
  expect_identical(levels(p$data$group.by), c("B", "A"))
  expect_equal(sum(p$data$feature == "z" & p$data$group.by == "A"), 3L)
})

test_that("con axis limit validation rejects malformed or non-scalar bounds early", {
  d <- con_data()
  invalid <- list("95", "q-1", "q1.5", "q101", "x", NA_real_, Inf,
                  numeric(), c(1, 2), matrix(1, 1, 1), TRUE)
  for (arg in c("y.min", "y.max")) for (value in invalid) {
    args <- list(data = d, type = "box")
    args[[arg]] <- value
    expect_error(do.call(con_plot, args), arg)
  }
  p <- con_plot(d, type = "box", y.min = "q0", y.max = "q100")
  expect_equal(unname(p$coordinates$limits$y), range(d$x))
})

test_that("con split combine FALSE returns named plots and rejects saving a list", {
  d <- con_data()
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box", combine = FALSE))
  expect_type(out, "list")
  expect_false(inherits(out, "patchwork"))
  expect_named(out, c("S1", "S2"))
  expect_true(all(vapply(out, inherits, logical(1), "ggplot")))
  expect_error(plt_con(d, "x", "g", split.by = "batch", combine = FALSE,
                       save = list(filename = tempfile(fileext = ".pdf"))), "combine = FALSE")
})

test_that("con missing split labels remain distinct from literal level names", {
  d <- data.frame(x = 1:18, g = rep(c("A", "B"), 9),
    batch = factor(rep(c("<NA>", "<NA>.1", NA), each = 6), exclude = NULL))
  for (missing_first in c(FALSE, TRUE)) {
    if (missing_first) d$batch <- factor(d$batch, levels = c(NA, "<NA>", "<NA>.1"), exclude = NULL)
    out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box", combine = FALSE))
    expect_setequal(names(out), c("<NA>", "<NA>.1", "<NA>.2"))
    expect_identical(anyDuplicated(names(out)), 0L)
    expect_equal(out[["<NA>"]]$data$value, 1:6)
    expect_equal(out[["<NA>.1"]]$data$value, 7:12)
    expect_equal(out[["<NA>.2"]]$data$value, 13:18)
    labels <- vapply(out, function(p) {
      if (exists("get_labs", envir = asNamespace("ggplot2"), inherits = FALSE)) {
        ggplot2::get_labs(p)$title
      } else p$labels$title
    }, "")
    expect_identical(unname(labels), names(out))
  }
})

test_that("con empty inputs fail clearly while usable features remain available", {
  d <- con_data()
  expect_error(con_plot(d[FALSE, ], type = "box"), "at least one observation")
  expect_error(con_plot(d[FALSE, ], group.by = NULL), "at least one observation")
  d$x <- NA_real_
  expect_warning(out <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box",
                                                 combine = FALSE)), "No finite values.*x")
  expect_named(out, "z")
  expect_s3_class(out[[1L]], "ggplot")
  expect_error(con_plot(d, type = "box"), "No finite values remain")
  d$z <- Inf
  expect_error(con_plot(d, c("x", "z"), stack = TRUE), "No finite values remain")
})

test_that("con empty split levels are omitted without losing populated panels", {
  d <- con_data()
  d$batch <- factor(d$batch, levels = c("S1", "S2", "unused"))
  out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box", combine = FALSE))
  expect_named(out, c("S1", "S2"))
  d$x[d$batch == "S1"] <- NA_real_
  expect_warning(out <- suppressMessages(plt_con(d, "x", "g", split.by = "batch", type = "box",
                                                 combine = FALSE)), "S1.*no finite|no finite.*S1")
  expect_named(out, "S2")
})

test_that("con errorbar limits contain full SD intervals and the zero baseline", {
  for (sign in c(1, -1)) for (stack in c(FALSE, TRUE)) for (shared in c(FALSE, TRUE)) {
    d <- data.frame(x = sign * c(1, 100), z = sign * c(2, 200), g = "A")
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "bar", stack = stack,
                 same.y.lims = shared)
    b <- ggplot2::ggplot_build(p)
    intervals <- b$data[[3L]]
    for (i in seq_along(b$layout$panel_params)) {
      at <- intervals[as.integer(intervals$PANEL) == i, ]
      limits <- b$layout$panel_params[[i]]$y.range
      expect_lte(limits[1L], min(c(0, at$ymin), na.rm = TRUE))
      expect_gte(limits[2L], max(c(0, at$ymax), na.rm = TRUE))
    }
  }
})

test_that("con errorbar explicit zoom limits retain their requested bounds", {
  d <- data.frame(x = c(1, 100), z = c(2, 200), g = "A")
  for (stack in c(FALSE, TRUE)) {
    p <- con_plot(d, if (stack) c("x", "z") else "x", type = "bar", stack = stack,
                 y.min = 10, y.max = 80)
    expect_equal(p$coordinates$limits$y, c(10, 80))
  }
})

test_that("con shared bar quantile limits use the original observations", {
  d <- data.frame(x = c(1, 2, 3, 100), z = c(4, 5, 6, 200), g = "A")
  expected <- unname(stats::quantile(c(d$x, d$z), c(0.05, 0.95)))
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) {
    p <- con_plot(d, c("x", "z"), type = "bar", stack = stack, flip = flip,
                 same.y.lims = TRUE, y.min = "q5", y.max = "q95")
    expect_equal(unname(p$coordinates$limits$y), expected)
  }
})

test_that("con independent stacked quantile zoom uses each feature without filtering statistics", {
  d <- data.frame(x = 1:20, z = 100 + 1:20, g = rep(c("A", "B"), each = 10))
  for (flip in c(FALSE, TRUE)) {
    separate <- suppressMessages(plt_con(d, c("x", "z"), "g", type = "box", flip = flip,
                     y.min = "q5", y.max = "q95", add_point = TRUE, combine = FALSE))
    p <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip,
                 y.min = "q5", y.max = "q95", add_point = TRUE)
    baseline <- con_plot(d, c("x", "z"), type = "box", stack = TRUE, flip = flip, add_point = TRUE)
    b <- ggplot2::ggplot_build(p)
    axis <- if (flip) "x.range" else "y.range"
    for (i in 1:2) {
      expect_equal(unname(b$layout$panel_params[[i]][[axis]]),
                   unname(ggplot2::ggplot_build(separate[[i]])$layout$panel_params[[1L]][[axis]]))
    }
    expect_equal(b$data[[1L]][c("lower", "middle", "upper", "ymin", "ymax")],
                 ggplot2::ggplot_build(baseline)$data[[1L]][c("lower", "middle", "upper", "ymin", "ymax")])
    expect_equal(sort(b$data[[3L]]$y), sort(c(d$x, d$z)))
    bar <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, flip = flip, y.max = "q95")
    expected_bar <- con_plot(d, c("x", "z"), type = "bar", stack = TRUE, flip = flip)
    expect_equal(ggplot2::ggplot_build(bar)$data[[2L]]$y,
                 ggplot2::ggplot_build(expected_bar)$data[[2L]]$y)
  }
})

test_that("con singleton violin groups retain raw points and summary overlays", {
  d <- data.frame(x = c(1:4, 10), g = c(rep("A", 4), "B"))
  expect_warning(p <- con_plot(d, type = "violin", add_point = TRUE, add_trend = TRUE),
                 "violin|density")
  expect_equal(nrow(p$data), 5L)
  expect_setequal(as.character(p$data$group.by), c("A", "B"))
  b <- ggplot2::ggplot_build(p)$data
  expect_equal(nrow(b[[2L]]), 5L)
  expect_equal(nrow(b[[3L]]), 2L)
  expect_equal(sort(b[[4L]]$y), c(2.5, 10))
})

test_that("con backgrounds align to displayed groups in single and stacked plots", {
  d <- data.frame(x = 1:9, z = 11:19,
                  g = factor(rep(c("A", "B", "C"), each = 3), levels = c("A", "unused", "B", "C")),
                  region = rep(c("R1", "R2", "R3"), each = 3))
  for (stack in c(FALSE, TRUE)) for (flip in c(FALSE, TRUE)) for (type in c("box", "dot")) {
    p <- con_plot(d, c("x", "z"), type = type, stack = stack, flip = flip,
                 bg.by = "region", bg_palette = c("red", "blue", "green"))
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    expect_true("GeomRect" %in% kinds)
    if (!"GeomRect" %in% kinds) next
    rects <- ggplot2::ggplot_build(p)$data[[which(kinds == "GeomRect")]]
    at <- rects$xmin <= 3 & rects$xmax >= 3
    expect_equal(as.character(rects$fill[at]), rep("blue", if (stack) 2L else 1L))
  }
})

test_that("con jitter defaults preserve numeric values and the random state", {
  expect_identical(formals(plt_con)$jitter.height, 0)
  d <- con_data()
  d$x <- d$x * 1e-10
  d$z <- d$z * 1e-10
  for (stack in c(FALSE, TRUE)) {
    set.seed(73)
    before <- .Random.seed
    p <- con_plot(d, c("x", "z"), type = "box", stack = stack, add_point = TRUE)
    b <- ggplot2::ggplot_build(p)$data
    points <- b[[length(b)]]
    expect_equal(sort(points$y), sort(if (stack) c(d$x, d$z) else d$x))
    expect_identical(before, .Random.seed)
    expect_identical(points$x, ggplot2::ggplot_build(p)$data[[length(b)]]$x)
  }
})

test_that("con dispatch builds only the requested stacked plot", {
  original <- getFromNamespace(".plt_con_single", "UtilsR")
  separate_calls <- 0L
  local_mocked_bindings(.plt_con_single = function(...) {
    separate_calls <<- separate_calls + 1L
    original(...)
  }, .package = "UtilsR")
  p <- con_plot(con_data(), c("x", "z"), type = "box", stack = TRUE)
  expect_equal(nrow(p$data), 24L)
  expect_equal(length(ggplot2::ggplot_build(p)$layout$panel_params), 2L)
  expect_equal(separate_calls, 0L)
})

test_that("con split figures measure the final canvas once and retain list sizes", {
  skip_if_not_installed("RegR")
  original <- getFromNamespace(".save_sized", "UtilsR")
  measured <- 0L
  local_mocked_bindings(.save_sized = function(...) {
    measured <<- measured + 1L
    original(...)
  }, .package = "UtilsR")
  d <- con_data()
  p <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch", type = "box"))
  expect_equal(measured, 1L)
  expect_length(attr(p, "plot_size"), 2L)
  measured <- 0L
  out <- suppressMessages(plt_con(d, c("x", "z"), "g", split.by = "batch",
                                  type = "box", combine = FALSE))
  expect_equal(measured, 2L)
  expect_named(out, c("S1", "S2"))
  expect_true(all(vapply(out, function(child) length(attr(child, "plot_size")) == 2L, logical(1))))
})

test_that("con memory does not retain unused input through plot environments", {
  skip_if_not_installed("lobstr")
  make <- function(extra, mode) {
    set.seed(20261030)
    d <- data.frame(x = rnorm(40), z = rnorm(40), g = rep(c("A", "B"), each = 20))
    if (extra) d$unused <- I(matrix(rnorm(40L * 5000L), nrow = 40L))
    suppressMessages(UtilsR::plt_con(d, if (mode == "stack") c("x", "z") else "x", "g",
                                   type = if (mode == "dot") "dot" else "box",
                                   stack = mode == "stack", add_point = TRUE, add_trend = mode == "box",
                                   combine = FALSE))[[1L]]
  }
  environment(make) <- globalenv()
  for (mode in c("box", "dot", "stack")) {
    invisible(make(FALSE, mode))
    small <- make(FALSE, mode)
    extra <- make(TRUE, mode)
    expect_lt(as.numeric(lobstr::obj_size(extra)) - as.numeric(lobstr::obj_size(small)), 100000)
    a <- withr::local_tempfile(fileext = ".rds")
    b <- withr::local_tempfile(fileext = ".rds")
    saveRDS(small, a)
    saveRDS(extra, b)
    expect_lt(file.info(b)$size - file.info(a)$size, 100000)
    expect_equal(ggplot2::ggplot_build(small)$data, ggplot2::ggplot_build(extra)$data)
  }
})

test_that("con single plot size is independent of sibling feature plots", {
  skip_if_not_installed("lobstr")
  make <- function(extra, type, background) {
    set.seed(215)
    d <- data.frame(x = rnorm(400), g = factor(rep(c("A", "B"), 200)), bg = rep(c("R1", "R2"), 200))
    features <- "x"
    if (extra) {
      for (i in 1:4) d[[paste0("z", i)]] <- rnorm(400)
      features <- c(features, paste0("z", 1:4))
    }
    suppressMessages(UtilsR::plt_con(d, features, "g", type = type,
      bg.by = if (background) "bg" else NULL, add_point = TRUE,
      add_box = type == "violin", add_trend = type == "bar", combine = FALSE))[[1L]]
  }
  environment(make) <- globalenv()
  for (type in c("violin", "box", "bar", "dot")) for (background in c(FALSE, TRUE)) {
    invisible(make(FALSE, type, background))
    a <- make(FALSE, type, background)
    b <- make(TRUE, type, background)
    expect_lt(as.numeric(lobstr::obj_size(b)) - as.numeric(lobstr::obj_size(a)), 100000)
    first <- withr::local_tempfile(fileext = ".rds")
    second <- withr::local_tempfile(fileext = ".rds")
    saveRDS(a, first)
    saveRDS(b, second)
    expect_lt(file.info(second)$size - file.info(first)$size, 100000)
    expect_identical(ggplot2::ggplot_build(a)$data, ggplot2::ggplot_build(b)$data)
  }
})
