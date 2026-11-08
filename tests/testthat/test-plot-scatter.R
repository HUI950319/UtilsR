test_that("single scatter group orders require one-dimensional level vectors", {
  for (bad in list(matrix(c("a", "b")), list("a", "b")))
    expect_error(PlotScatter1(stop("data evaluated"), "x", "y", "g", group_levels = bad), "group_levels")
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  expect_s3_class(PlotScatter1(d, "x", "y", "g", group_levels = c("b", "a"), show_ellipse = FALSE), "wrapped_patch")
})

test_that("marginal scatter annotations expand native correlation method names", {
  d <- data.frame(x = 1:6, y = c(1, 3, 2, 4, 6, 5), g = rep(c("a", "b"), 3))
  text_labels <- function(g) {
    if (inherits(g, "text")) return(as.character(g$label))
    unlist(lapply(c(g$grobs, as.list(g$children)), text_labels), use.names = FALSE)
  }
  for (fun in list(PlotScatter1, PlotScatter2)) for (method in c("pearson", "spea", "kendall")) {
    canonical <- if (method == "spea") "spearman" else method
    ref <- stats::cor.test(d$x, d$y, method = canonical)
    expected <- sprintf("%s:\nr = %.3f\np = %s", tools::toTitleCase(canonical),
      ref$estimate, format(ref$p.value, digits = 3, scientific = TRUE))
    p <- fun(d, "x", "y", "g", show_ellipse = FALSE, show_cor = TRUE, cor_method = method)
    grob <- if (inherits(p, "wrapped_patch")) attr(p, "grobs")$full else patchwork::patchworkGrob(p)
    labels <- text_labels(grob)
    expect_identical(labels[grepl("\np = ", labels, fixed = TRUE)], expected)
  }
})

test_that("paired scatter correlation labels match canonical native methods", {
  d <- data.frame(Control = 1:6, Treat = c(1, 3, 2, 4, 6, 5), group = rep(c("a", "b"), 3))
  for (method in c("spea", "kendall")) {
    p <- PlotScatter3(d, test_method = "none", cor_method = method, theme_use = ggplot2::theme_classic)
    labels <- unlist(lapply(ggplot2::ggplot_build(p[[1]])$data, function(x) x$label))
    expect_match(labels, if (method == "spea") "^rho =" else "^tau =")
  }
  for (bad in list(NA_character_, character(), matrix("pearson"), c("pearson", "spearman")))
    expect_error(PlotScatter3(stop("data evaluated"), cor_method = bad), "cor_method")
})

test_that("dual scatter mappings reject ambiguous keys and dimensional containers", {
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3), h = rep(c("a", "b"), 3))
  for (arg in c("colors", "shapes", "fill_colors_shape")) {
    values <- if (arg == "shapes") c(16, 17, 15) else c("red", "blue", "green")
    for (bad in list(stats::setNames(values, c("a", "a", "b")), matrix(values))) {
      args <- c(list(data = d, x = "x", y = "y", group = "g", group2 = "h"), stats::setNames(list(bad), arg))
      expect_error(do.call("PlotScatter2", args), arg)
    }
  }
  expect_s3_class(PlotScatter2(d, "x", "y", "g", shapes = stop("inactive"),
                              fill_colors_shape = stop("inactive")), "patchwork")
})

test_that("paired scatter group levels require two distinct vector entries", {
  d <- data.frame(Control = 1:6, Treat = c(2, 2, 4, 5, 4, 7), group = rep(c("a", "b"), 3))
  for (bad in list(c("a", "b", "c"), c("a", "a"), c("a", NA),
                   matrix(c("a", "b")), list("a", "b")))
    expect_error(PlotScatter3(d, group_levels = bad, test_method = "none", cor_method = "none"), "group_levels")
  p <- PlotScatter3(d, group_levels = c("b", "a"), test_method = "none", cor_method = "none")
  expect_identical(levels(p[[1]][["data"]][["group"]]), c("b", "a"))
})

scatter_main_points <- function(grob) {
  if (inherits(grob, "points") && grepl("geom_point", grob$name)) {
    return(length(grob$x))
  }
  children <- c(grob$grobs, as.list(grob$children))
  sum(vapply(children, scatter_main_points, numeric(1L)))
}

scatter_grob_labels <- function(grob) {
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  children <- c(grob$grobs, as.list(grob$children))
  c(labels, unlist(lapply(children, scatter_grob_labels), use.names = FALSE))
}

scatter3_capture_inset <- function(...) {
  inset <- NULL
  plot <- testthat::with_mocked_bindings(
    PlotScatter3(..., theme_use = ggplot2::theme_classic),
    ggplotGrob = function(x, ...) {
      inset <<- x
      grid::nullGrob()
    }, .package = "ggplot2"
  )
  list(main = plot[[1]], inset = inset)
}

scatter3_integer_pairs <- function() {
  data.frame(
    Control = c(-2000000000L, -1999999998L, 2000000000L, 1999999998L,
                10L, 20L, 30L, 40L),
    Treat = c(2000000000L, 1999999995L, -1999999991L, -1999999990L,
              12L, 25L, 37L, 51L),
    group = rep(c("NS", "S"), 4)
  )
}

test_that("grouped scatter diagnoses empty and dimensional manual mappings", {
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- data.frame(x = 1:6, y = c(2, 1, 4, 3, 6, 5), g = rep(c("A", "B"), 3))
  for (bad in list(character(), matrix("red"), "not-a-colour"))
    expect_error(PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE, colors = bad), "colors")
  for (bad in list(numeric(), matrix(16)))
    expect_error(PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE, shapes = bad), "shapes")
  p <- PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE, box_jitter = FALSE,
                    colors = "red", shapes = 16)
  expect_equal(scatter_main_points(attr(p, "grobs")$full), nrow(d))
})

test_that("grouped scatter validates active raster resolution before reading data", {
  withr::local_options(lifecycle_verbosity = "quiet")
  for (bad in list(0, Inf, NA_real_, matrix(100), structure(100, class = "encoded"), 1.5))
    expect_error(PlotScatter1(stop("data evaluated"), "x", "y", "g",
      raster = TRUE, raster.dpi = bad), "raster.dpi")
  d <- data.frame(x = 1:8, y = c(3, 1, 2, 4, 8, 6, 7, 5), g = rep(c("A", "B"), 4))
  expect_s3_class(PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE,
    raster = FALSE, raster.dpi = stop("unused")), "ggplot")
})

test_that("grouped scatter styles fail before data and unused ellipse settings stay lazy", {
  for (arg in c("point_size", "point_alpha", "layout_ratio")) {
    args <- list(data = quote(stop("data evaluated")), x = "x", y = "y", group = "g")
    args[[arg]] <- if (arg == "layout_ratio") c(1, NA) else NA_real_
    expect_error(do.call("PlotScatter1", args), arg)
  }
  expect_error(PlotScatter1(stop("data evaluated"), "x", "y", "g", ellipse_level = 1), "ellipse_level")
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_no_warning(PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE,
    ellipse_level = stop("unused ellipse"), box_jitter = FALSE))
})

test_that("PlotScatter1 rejects ambiguous data-frame column names", {
  d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2), x = 5:8, check.names = FALSE)
  expect_error(PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE,
    theme_use = function() stop("theme evaluated")), "unique.*column names")
  for (bad in list(matrix(1:4, 2), list(x = 1:4, y = 4:1, g = letters[1:4])))
    expect_error(PlotScatter1(bad, "x", "y", "g"), "data.frame")
})

test_that("PlotScatter1 rejects non-vector axes before theme evaluation", {
  for (col in c("x", "y")) for (bad in list(1:4 + 1i, as.list(1:4), matrix(1:4, 4))) {
    d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2))
    d[[col]] <- bad
    expect_error(PlotScatter1(d, "x", "y", "g", show_ellipse = FALSE,
      theme_use = function() stop("theme evaluated")), "must contain a real vector")
  }
})

test_that("PlotScatter1 validates selectors and logical controls before reading data", {
  for (arg in c("x", "y", "group")) {
    for (bad in list(NULL, character(), c("x", "y"), NA_character_, matrix("x"))) {
      args <- list(data = quote(stop("data evaluated")), x = "x", y = "y", group = "g")
      args[arg] <- list(bad)
      expect_error(do.call(PlotScatter1, args), arg)
    }
  }
  for (arg in c("show_ellipse", "show_refline", "show_regression", "show_cor",
                "box_jitter", "raster")) {
    for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
      args <- list(data = quote(stop("data evaluated")), x = "x", y = "y", group = "g")
      args[arg] <- list(bad)
      expect_error(do.call(PlotScatter1, args), arg)
    }
  }
})

test_that("dual-group scatter validates active annotation coordinates and sizes", {
  for (bad in list(1, c(1, NA), c(1, Inf), matrix(c(1, 2)), structure(c(1, 2), class = "encoded")))
    expect_error(PlotScatter2(stop("data evaluated"), "x", "y", "g",
      annot_text = "note", annot_pos = bad), "annot_pos")
  for (bad in list(-1, NA_real_, Inf, matrix(2)))
    expect_error(PlotScatter2(stop("data evaluated"), "x", "y", "g",
      annot_text = "note", annot_size = bad), "annot_size")
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("A", "B"), 3))
  withr::local_options(lifecycle_verbosity = "quiet")
  p <- PlotScatter2(d, "x", "y", "g", annot_text = "note", annot_pos = c(2, 4))
  expect_true("note" %in% scatter_grob_labels(patchwork::patchworkGrob(p)))
  expect_s3_class(PlotScatter2(d, "x", "y", "g", annot_pos = stop("unused"),
    annot_size = stop("unused")), "patchwork")
})

test_that("dual-group scatter styles reject invalid scalar and layout controls", {
  for (arg in c("point_size", "point_alpha", "box_width", "base_size", "layout_main", "layout_margin"))
    for (bad in list(NA_real_, Inf, matrix(1))) {
      args <- list(data = quote(stop("data evaluated")), x = "x", y = "y", group = "g")
      args[[arg]] <- bad
      expect_error(do.call("PlotScatter2", args), arg)
    }
  d <- data.frame(x = 1:6, y = 6:1, g = rep(c("a", "b"), 3))
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_s3_class(PlotScatter2(d, "x", "y", "g"), "patchwork")
})

test_that("PlotScatter2 rejects ambiguous data-frame column names", {
  d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2), x = 5:8, check.names = FALSE)
  expect_error(PlotScatter2(d, "x", "y", "g", legend_color_pos = stop("theme evaluated")),
    "unique.*column names")
  expect_error(PlotScatter2(list(x = 1:4, y = 4:1, g = letters[1:4]), "x", "y", "g"), "data.frame")
})

test_that("PlotScatter2 rejects non-vector axes before theme evaluation", {
  for (col in c("x", "y")) for (bad in list(1:4 + 1i, as.list(1:4), matrix(1:4, 4))) {
    d <- data.frame(x = 1:4, y = 4:1, g = rep(c("a", "b"), 2))
    d[[col]] <- bad
    expect_error(PlotScatter2(d, "x", "y", "g", legend_color_pos = stop("theme evaluated")),
      "must contain a real vector")
  }
})

test_that("PlotScatter2 validates selectors and logical controls before reading data", {
  for (arg in c("x", "y", "group", "group2")) {
    for (bad in list(character(), c("x", "y"), NA_character_, matrix("x"))) {
      args <- list(data = quote(stop("data evaluated")), x = "x", y = "y", group = "g")
      args[arg] <- list(bad)
      expect_error(do.call(PlotScatter2, args), arg)
    }
  }
  for (arg in c("show_ellipse", "show_regression", "show_cor", "x_top")) {
    for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
      args <- list(data = quote(stop("data evaluated")), x = "x", y = "y", group = "g")
      args[arg] <- list(bad)
      expect_error(do.call(PlotScatter2, args), arg)
    }
  }
})

test_that("paired scatter validates rendered dimensions before statistics", {
  for (arg in c("point_size", "point_stroke", "p_size", "cor_size", "median_label_size",
                "inset_angle", "inset_vp_width", "inset_vp_height")) {
    args <- list(data = quote(stop("data evaluated")))
    args[[arg]] <- NA_real_
    expect_error(do.call("PlotScatter3", args), arg)
  }
  for (bad in list(structure(30, class = "encoded_number"), 2^31))
    expect_error(PlotScatter3(stop("data evaluated"), hist_bins = bad), "hist_bins")
})

test_that("paired scatter rejects ambiguous input column names before tests", {
  d <- data.frame(Control = 1:8, Treat = 2:9, group = rep(c("NS", "S"), 4),
    Control = 11:18, check.names = FALSE)
  expect_error(PlotScatter3(d, theme_use = function() stop("theme evaluated")), "unique.*column names")
})

test_that("PlotScatter3 validates paired controls before evaluating data or devices", {
  for (arg in c("x", "y", "group")) {
    for (bad in list(NULL, character(), c("x", "y"), NA_character_, matrix("x"))) {
      args <- list(data = quote(stop("data evaluated")))
      args[arg] <- list(bad)
      expect_error(do.call(PlotScatter3, args), arg)
    }
  }
  for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
    expect_error(PlotScatter3(stop("data evaluated"), show_refline = bad), "show_refline")
  }
  for (bad in list(0, -1, 1.5, Inf, NA_real_, matrix(2))) {
    expect_error(PlotScatter3(stop("data evaluated"), hist_bins = bad), "hist_bins")
  }
  calls <- 0L
  testthat::local_mocked_bindings(pdf = function(...) {
    calls <<- calls + 1L
    stop("device opened")
  }, .package = "grDevices")
  for (bad in list(matrix(1:8, 8), 1:8 + 1i, as.list(1:8))) {
    data <- scatter3_integer_pairs()
    data$Control <- bad
    expect_no_warning(expect_error(PlotScatter3(data), "Control"))
  }
  expect_identical(calls, 0L)
})

test_that("PlotScatter3 retains differences beyond the integer range", {
  data <- scatter3_integer_pairs()
  before <- serialize(data, NULL)
  differences <- as.double(data$Treat) - as.double(data$Control)
  expect_no_warning(p <- scatter3_capture_inset(
    data, test_method = "none", cor_method = "none"
  ))
  built <- ggplot2::ggplot_build(p$inset)
  expect_equal(sum(built$data[[1]]$count), nrow(data))
  expect_equal(built$data[[2]]$x, stats::median(differences))
  expect_equal(rlang::eval_tidy(p$inset$mapping$x, data = p$inset$data), differences)
  expect_identical(serialize(data, NULL), before)

  for (direction in c(-1L, 1L)) {
    data$Control <- direction * (-2000000000L + 0:7)
    data$Treat <- direction * (2000000000L - 0:7)
    expect_no_warning(p <- scatter3_capture_inset(
      data, test_method = "none", cor_method = "none"
    ))
    built <- ggplot2::ggplot_build(p$inset)
    expect_equal(sum(built$data[[1]]$count), nrow(data))
    expect_equal(built$data[[2]]$x,
                 stats::median(as.double(data$Treat) - as.double(data$Control)))
  }
})

test_that("PlotScatter3 paired tests agree with double precision reference tests", {
  data <- scatter3_integer_pairs()
  for (method in c("wilcox", "t.test")) {
    test_fn <- if (method == "wilcox") stats::wilcox.test else stats::t.test
    expected <- test_fn(as.double(data$Control), as.double(data$Treat),
                        paired = TRUE, alternative = "two.sided")
    expect_no_warning(p <- scatter3_capture_inset(
      data, test_method = method, cor_method = "none", show_refline = FALSE
    ))
    label <- ggplot2::ggplot_build(p$main)$data[[2]]$label
    expect_equal(label, paste0("p = ", format.pval(expected$p.value, digits = 2)))
  }
})

test_that("PlotScatter3 paired tests omit missing observations pairwise", {
  data <- data.frame(Control = c(1L, 2L, NA_integer_, 4L, 5L, 6L, 7L),
                     Treat = c(2L, 6L, 10L, NA_integer_, 10L, 12L, 20L),
                     group = rep(c("NS", "S"), length.out = 7))
  complete <- stats::complete.cases(data[c("Control", "Treat")])
  for (method in c("wilcox", "t.test")) {
    test_fn <- if (method == "wilcox") stats::wilcox.test else stats::t.test
    expected <- test_fn(data$Control[complete], data$Treat[complete], paired = TRUE)
    p <- scatter3_capture_inset(data, test_method = method, cor_method = "none",
                                show_refline = FALSE)
    label <- ggplot2::ggplot_build(p$main)$data[[2]]$label
    expect_equal(label, paste0("p = ", format.pval(expected$p.value, digits = 2)))
  }
})

test_that("PlotScatter3 draws every paired difference with coarse histogram bins", {
  data <- data.frame(
    Control = seq_len(8),
    Treat = seq_len(8) + c(-3, -2, -1, 0, 1, 2, 2.5, 4),
    group = rep(c("NS", "S"), 4)
  )
  for (bins in c(1L, 2L, 5L, 30L)) {
    p <- scatter3_capture_inset(data, test_method = "none", cor_method = "none",
                                hist_bins = bins)
    built <- ggplot2::ggplot_build(p$inset)
    histogram <- built$data[[1]]
    visible <- is.finite(histogram$xmin) & is.finite(histogram$xmax)
    expect_equal(sum(histogram$count[visible]), nrow(data))
    expect_equal(as.vector(tapply(histogram$count[visible], histogram$group[visible], sum)),
                 rep(4, 2))
    expect_equal(built$data[[2]]$x, 0.5)
    expect_equal(built$data[[3]]$label, 0.5)
    expect_no_warning(ggplot2::ggplotGrob(p$inset))
  }
})

test_that("PlotScatter3 draws rotated insets without clipping warnings", {
  grDevices::pdf(NULL)
  withr::defer(grDevices::dev.off())
  data <- data.frame(Control = -3:4, Treat = c(-2, 0, -0.5, 2, 4, 2.5, 6, 8),
                     group = rep(c("NS", "S"), 4))
  for (angle in c(0, -45, 30)) {
    expect_no_warning(p <- PlotScatter3(
      data, test_method = "none", cor_method = "none", inset_angle = angle,
      theme_use = ggplot2::theme_classic
    ))
    expect_no_warning(grid::grid.draw(patchwork::patchworkGrob(p)))
  }
})

test_that("PlotScatter3 preserves scale warnings and statistics when ranges exclude data", {
  grDevices::pdf(NULL)
  withr::defer(grDevices::dev.off())
  data <- data.frame(Control = -3:4, Treat = c(-2, 0, -0.5, 2, 4, 2.5, 6, 8),
                     group = rep(c("NS", "S"), 4))
  warnings <- character()
  withCallingHandlers({
    p <- PlotScatter3(data, test_method = "t.test", cor_method = "none",
                      show_refline = FALSE, axis_limits = c(-1, 1),
                      hist_x_limits = c(-1, 1), theme_use = ggplot2::theme_classic)
    grob <- patchwork::patchworkGrob(p)
    grid::grid.draw(grob)
  }, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  for (layer in c("stat_bin", "geom_point", "geom_segment", "geom_text")) {
    expect_match(paste(warnings, collapse = " "), layer)
  }
  expect_length(grep("cannot clip", warnings), 0L)
  expect_equal(scatter_main_points(grob), 1)
  expected <- stats::t.test(data$Control, data$Treat, paired = TRUE)
  label <- ggplot2::ggplot_build(p[[1]])$data[[2]]$label
  expect_equal(label, paste0("p = ", format.pval(expected$p.value, digits = 2)))
})

test_that("PlotScatter3 computed differences are independent of similarly named columns", {
  data <- scatter3_integer_pairs()
  data$diff_values <- NA_real_
  data$x_values <- 0
  data$y_values <- 1
  p <- scatter3_capture_inset(data, test_method = "none", cor_method = "none")
  differences <- as.double(data$Treat) - as.double(data$Control)
  expect_equal(rlang::eval_tidy(p$inset$mapping$x, data = p$inset$data), differences)
  expect_equal(sum(ggplot2::ggplot_build(p$inset)$data[[1]]$count), nrow(data))
})

test_that("PlotScatter3 derives automatic histogram limits from paired differences", {
  withr::local_options(lifecycle_verbosity = "quiet")
  inset <- NULL
  testthat::local_mocked_bindings(ggplotGrob = function(x, ...) {
    inset <<- x
    grid::nullGrob()
  }, .package = "ggplot2")
  for (offset in c(10, -20)) {
    data <- data.frame(Control = offset + 0:5,
                       Treat = offset + c(1, 3, 4, 4, 6, 8),
                       group = rep(c("NS", "S"), 3))
    PlotScatter3(data, test_method = "none", cor_method = "none")
    histogram <- ggplot2::ggplot_build(inset)$data[[1]]
    expect_equal(sum(histogram$count), 6)
    expect_lte(inset$scales$get_scales("x")$limits[1], 1)
    expect_gte(inset$scales$get_scales("x")$limits[2], 3)
  }
  data$Treat <- data$Control + 2
  PlotScatter3(data, test_method = "none", cor_method = "none")
  expect_equal(sum(ggplot2::ggplot_build(inset)$data[[1]]$count), 6)
  expect_gt(diff(inset$scales$get_scales("x")$limits), 0)
  data$Treat <- data$Control
  PlotScatter3(data, test_method = "none", cor_method = "none")
  expect_equal(sum(ggplot2::ggplot_build(inset)$data[[1]]$count), 6)
  expect_gt(diff(inset$scales$get_scales("x")$limits), 0)
  PlotScatter3(data, test_method = "none", cor_method = "none", hist_x_limits = c(-2, 4))
  expect_identical(inset$scales$get_scales("x")$limits, c(-2, 4))
})

test_that("PlotScatter3 preserves axes and statistics when grouping uses an axis", {
  data <- data.frame(Control = rep(c(10, 30), 6),
                     Treat = rep(c(100, 200), each = 6),
                     .scatter3_group = -seq_len(12), .scatter3_group.1 = seq_len(12))
  before <- serialize(data, NULL)
  cases <- list(
    list(x = "Control", y = "Treat", group = "Control"),
    list(x = "Control", y = "Treat", group = "Treat"),
    list(x = c(axis = "Control"), y = "Treat", group = "Control",
         group_levels = c(30, 10))
  )
  for (case in cases) {
    p <- do.call(scatter3_capture_inset, c(list(data = data), case,
      list(test_method = "t.test", show_refline = FALSE)))
    main <- ggplot2::ggplot_build(p$main)$data
    inset <- ggplot2::ggplot_build(p$inset)$data
    differences <- data$Treat - data$Control
    expected_test <- stats::t.test(data$Control, data$Treat, paired = TRUE)
    expected_cor <- stats::cor.test(data$Control, data$Treat)
    levels <- if (is.null(case$group_levels)) unique(data[[case$group]]) else case$group_levels
    expect_equal(main[[1]]$x, data$Control)
    expect_equal(main[[1]]$y, data$Treat)
    expect_identical(main[[1]]$fill,
                     c("#FFFFFF10", "#f71d53")[match(data[[case$group]], levels)])
    expect_equal(main[[2]]$label,
                 paste0("p = ", format.pval(expected_test$p.value, digits = 2)))
    expect_match(main[[3]]$label,
                 paste0("r = ", round(expected_cor$estimate, 3), ","), fixed = TRUE)
    expect_equal(rlang::eval_tidy(p$inset$mapping$x, data = p$inset$data), differences)
    expect_equal(sum(inset[[1]]$count), nrow(data))
    expect_equal(inset[[2]]$x, stats::median(differences))
    expect_identical(serialize(data, NULL), before)
  }
})

test_that("PlotScatter3 supports a column named .data in every plotting role", {
  data <- data.frame(Control = rep(c(10, 30), 6),
                     Treat = rep(c(100, 200), each = 6),
                     group = rep(c("NS", "S"), 6),
                     .scatter3_data = -seq_len(12), .scatter3_data.1 = seq_len(12))
  for (role in c("x", "y", "group")) {
    columns <- c(x = "Control", y = "Treat", group = "group")
    renamed <- data
    names(renamed)[match(columns[[role]], names(renamed))] <- ".data"
    columns[[role]] <- ".data"
    before <- serialize(renamed, NULL)
    p <- do.call(scatter3_capture_inset, c(list(data = renamed), as.list(columns),
      list(test_method = "t.test", show_refline = FALSE)))
    main <- ggplot2::ggplot_build(p$main)$data
    inset <- ggplot2::ggplot_build(p$inset)$data
    expected_test <- stats::t.test(data$Control, data$Treat, paired = TRUE)
    expect_equal(main[[1]]$x, data$Control)
    expect_equal(main[[1]]$y, data$Treat)
    expect_identical(main[[1]]$fill, rep(c("#FFFFFF10", "#f71d53"), 6))
    expect_equal(main[[2]]$label,
                 paste0("p = ", format.pval(expected_test$p.value, digits = 2)))
    expect_match(main[[3]]$label, "r = 0,", fixed = TRUE)
    expect_equal(sum(inset[[1]]$count), nrow(data))
    expect_equal(inset[[2]]$x, stats::median(data$Treat - data$Control))
    expect_identical(serialize(renamed, NULL), before)
  }
})

test_that("PlotScatter3 preserves a .data axis that is also its grouping column", {
  data <- data.frame(.data = rep(c(10, 30), 6),
                     Treat = rep(c(100, 200), each = 6),
                     .scatter3_data = -seq_len(12), .scatter3_data.1 = seq_len(12),
                     .scatter3_group = seq_len(12), .scatter3_group.1 = -seq_len(12))
  before <- serialize(data, NULL)
  for (y in c("Treat", ".data")) {
    p <- scatter3_capture_inset(data, ".data", y, ".data",
                                test_method = "none", show_refline = FALSE)
    main <- ggplot2::ggplot_build(p$main)$data
    inset <- ggplot2::ggplot_build(p$inset)$data
    expect_equal(main[[1]]$x, data[[".data"]])
    expect_equal(main[[1]]$y, data[[y]])
    expect_match(main[[2]]$label, if (y == ".data") "r = 1," else "r = 0,", fixed = TRUE)
    expect_equal(sum(inset[[1]]$count), nrow(data))
    expect_equal(inset[[2]]$x, stats::median(data[[y]] - data[[".data"]]))
    expect_identical(serialize(data, NULL), before)
  }
})

scatter1_capture_panels <- function(...) {
  panels <- list()
  ggplot_grob <- ggplot2::ggplotGrob
  plot <- testthat::with_mocked_bindings(
    PlotScatter1(...),
    ggplotGrob = function(x, ...) {
      panels[[length(panels) + 1L]] <<- x
      ggplot_grob(x, ...)
    }, .package = "ggplot2"
  )
  names(panels) <- c("top", "annotation", "main", "right")
  list(plot = plot, panels = panels)
}

test_that("custom scatter annotations skip unused correlation tests", {
  local_mocked_bindings(cor.test = function(...) stop("unused correlation"), .package = "stats")
  d <- data.frame(x = 1:8, y = (1:8)^2, g = rep(c("A", "B"), 4))
  withr::local_options(lifecycle_verbosity = "quiet")
  p <- scatter1_capture_panels(d, "x", "y", "g", show_cor = TRUE,
    annot_text = "Custom result", show_ellipse = FALSE, box_jitter = FALSE)
  expect_true(any(vapply(p$panels, function(x) any(vapply(x$layers, function(l)
    identical(l$aes_params$label, "Custom result"), logical(1))), logical(1))))
})

test_that("PlotScatter1 preserves numeric axes that are also grouping columns", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6))
  before <- serialize(data, NULL)
  cases <- list(
    list(x = "x", y = "y", group = "x"),
    list(x = "x", y = "y", group = "y"),
    list(x = "x", y = "x", group = "x"),
    list(x = c(axis = "x"), y = "y", group = "x")
  )
  for (case in cases) {
    p <- do.call(scatter1_capture_panels, c(list(data = data), case,
      list(show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE)))
    points <- ggplot2::ggplot_build(p$panels$main)$data[[1]]
    expect_equal(points$x, data[[case$x]])
    expect_equal(points$y, data[[case$y]])
    expect_equal(unname(p$panels$main$labels$x), unname(case$x))
    expect_equal(unname(p$panels$main$labels$y), unname(case$y))
    expect_identical(serialize(data, NULL), before)
    expect_s3_class(p$plot, "ggplot")
  }
})

test_that("PlotScatter1 avoids collisions with internal grouping columns", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6),
                     .scatter1_group = -seq_len(12), .scatter1_group.1 = seq_len(12),
                     .scatter1_data = seq_len(12), .scatter1_data.1 = -seq_len(12))
  for (input in list(data, tibble::as_tibble(data))) {
    before <- serialize(input, NULL)
    for (group in c("x", "y")) {
      p <- scatter1_capture_panels(input, "x", "y", group,
        show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE)
      points <- ggplot2::ggplot_build(p$panels$main)$data[[1]]
      expect_equal(points$x, input$x)
      expect_equal(points$y, input$y)
      for (panel in p$panels[c("top", "main", "right")]) {
        for (col in names(input)) expect_identical(panel$data[[col]], input[[col]])
      }
      expect_identical(serialize(input, NULL), before)
    }
  }
})

test_that("PlotScatter1 supports a shared axis and group named .data", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6),
                     .scatter1_group = -seq_len(12), .scatter1_group.1 = seq_len(12),
                     .scatter1_data = seq_len(12), .scatter1_data.1 = -seq_len(12))
  for (axis in c("x", "y")) {
    input <- data
    names(input)[match(axis, names(input))] <- ".data"
    axes <- c(x = "x", y = "y")
    axes[[axis]] <- ".data"
    before <- serialize(input, NULL)
    p <- scatter1_capture_panels(input, axes[["x"]], axes[["y"]], ".data",
      show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE)
    points <- ggplot2::ggplot_build(p$panels$main)$data[[1]]
    expect_equal(points$x, data$x)
    expect_equal(points$y, data$y)
    expect_equal(p$panels$main$labels$x, axes[["x"]])
    expect_equal(p$panels$main$labels$y, axes[["y"]])
    expect_identical(serialize(input, NULL), before)
  }
})

test_that("PlotScatter1 respects group order and mappings on shared numeric axes", {
  data <- data.frame(x = rep(c(30, 10), 6), y = rep(c(100, 200), each = 6))
  cases <- list(
    list(group = "x", levels = NULL, order = c("30", "10")),
    list(group = "x", levels = c(10, 30), order = c("10", "30")),
    list(group = "y", levels = c(200, 100), order = c("200", "100")),
    list(group = "x", levels = c(10, 30), order = c("10", "30"), named = TRUE)
  )
  for (case in cases) {
    colors <- c("#112233", "#445566")
    shapes <- c(16, 17)
    if (isTRUE(case$named)) {
      names(colors) <- names(shapes) <- rev(case$order)
    }
    p <- scatter1_capture_panels(data, "x", "y", case$group,
      group_levels = case$levels, colors = colors, shapes = shapes,
      show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE,
      legend_theme = ggplot2::theme(legend.title = ggplot2::element_text()))
    main <- ggplot2::ggplot_build(p$panels$main)
    groups <- factor(data[[case$group]], levels = case$order)
    indices <- if (isTRUE(case$named)) match(as.character(groups), names(colors)) else
      as.integer(groups)
    expect_identical(main$data[[1]]$colour, unname(colors[indices]))
    expect_identical(main$data[[1]]$shape, unname(shapes[indices]))
    expect_equal(main$data[[1]]$x, data$x)
    expect_equal(main$data[[1]]$y, data$y)
    expect_equal(main$plot$scales$get_scales("colour")$get_labels(), case$order)
    expect_equal(p$panels$main$labels$colour, case$group)
    expect_equal(p$panels$main$labels$shape, case$group)
    for (panel in c("top", "right")) {
      boxes <- ggplot2::ggplot_build(p$panels[[panel]])$data[[1]]
      values <- if (panel == "top") data$x else data$y
      medians <- vapply(split(values, groups), stats::median, numeric(1L))
      expect_equal(boxes$middle, unname(medians))
      expect_identical(boxes$fill, unname(if (isTRUE(case$named))
        colors[match(case$order, names(colors))] else colors))
    }
  }
})

test_that("PlotScatter1 preserves factor ordering when grouping a separate column", {
  data <- data.frame(x = 1:12, y = 12:1,
                     g = factor(rep(c("a", "b"), 6), levels = c("b", "a")))
  before <- serialize(data, NULL)
  for (levels in list(NULL, c("a", "b"))) {
    p <- scatter1_capture_panels(data, "x", "y", "g", group_levels = levels,
      show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE)
    main <- ggplot2::ggplot_build(p$panels$main)
    expected <- if (is.null(levels)) c("b", "a") else levels
    expect_equal(main$plot$scales$get_scales("colour")$get_labels(), expected)
    expect_equal(main$data[[1]]$x, data$x)
    expect_equal(main$data[[1]]$y, data$y)
    expect_identical(serialize(data, NULL), before)
  }
})

test_that("PlotScatter1 uses original shared axis values for regression and correlation", {
  data <- data.frame(x = c(10, 11, 14, 17, 19, 21, 26, 31, 34, 38, 42, 50))
  data$y <- 3 * data$x + c(5, -4, 3, -2, 7, -1, 0, -5, 4, 2, 6, -3)
  before <- serialize(data, NULL)
  cases <- list(
    list(y = "y", group = "x", method = "pearson", regression = "lm"),
    list(y = "y", group = "y", method = "spearman", regression = "loess"),
    list(y = "x", group = "x", method = "pearson", regression = "lm")
  )
  for (case in cases) {
    p <- scatter1_capture_panels(data, "x", case$y, case$group,
      show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE,
      show_cor = TRUE, cor_method = case$method,
      show_regression = TRUE, reg_method = case$regression)
    main <- ggplot2::ggplot_build(p$panels$main)
    reference_data <- data.frame(x = data$x, y = data[[case$y]])
    reference <- ggplot2::ggplot_build(
      ggplot2::ggplot(reference_data, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_smooth(method = case$regression, formula = y ~ x, se = FALSE)
    )$data[[1]]
    expect_equal(main$data[[2]][c("x", "y")], reference[c("x", "y")])
    correlation <- stats::cor.test(data$x, data[[case$y]], method = case$method)
    expected <- sprintf("%s:\nr = %.3f\np = %s", tools::toTitleCase(case$method),
      correlation$estimate, format(correlation$p.value, digits = 3, scientific = TRUE))
    annotation <- ggplot2::ggplot_build(p$panels$annotation)$data[[1]]$label
    expect_equal(annotation, expected)
    expect_identical(serialize(data, NULL), before)
  }
})

test_that("PlotScatter1 uses numeric shared axes in every marginal geometry", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6))
  for (group in c("x", "y")) {
    reference_data <- data
    reference_data$g <- factor(data[[group]], levels = unique(data[[group]]))
    for (mtype in c("boxplot", "violin", "violin_box")) {
      p <- scatter1_capture_panels(data, "x", "y", group, marginal_type = mtype,
        show_ellipse = FALSE, show_refline = FALSE,
        xlim = c(5, 35), ylim = c(90, 210))
      main <- ggplot2::ggplot_build(p$panels$main)$layout$panel_params[[1]]
      top <- ggplot2::ggplot_build(p$panels$top)
      right <- ggplot2::ggplot_build(p$panels$right)
      expect_equal(main$x.range, c(5, 35))
      expect_equal(main$y.range, c(90, 210))
      expect_equal(top$layout$panel_params[[1]]$x.range, main$x.range)
      expect_equal(right$layout$panel_params[[1]]$y.range, main$y.range)
      for (panel in c("top", "right")) {
        values <- if (panel == "top") "x" else "y"
        reference <- ggplot2::ggplot(reference_data,
          ggplot2::aes(x = g, y = .data[[values]], fill = g))
        if (mtype == "boxplot") {
          reference <- reference + ggplot2::geom_boxplot()
          columns <- c("lower", "middle", "upper", "ymin", "ymax")
        } else {
          reference <- reference + ggplot2::geom_violin(trim = FALSE, scale = "width")
          columns <- c("y", "density", "scaled", "count")
        }
        expected <- ggplot2::ggplot_build(reference)$data[[1]]
        actual <- ggplot2::ggplot_build(p$panels[[panel]])$data[[1]]
        expect_equal(actual[columns], expected[columns])
      }
      expect_equal(scatter_main_points(attr(p$plot, "grobs")$full), 3 * nrow(data))
      expect_no_warning(grid::grid.draw(attr(p$plot, "grobs")$full))
    }
  }
})

test_that("PlotScatter1 raster backends preserve shared axis coordinates", {
  skip_if_not_installed("scattermore")
  skip_if_not_installed("ggrastr")
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6))
  for (method in c("scattermore", "ggrastr")) {
    p <- scatter1_capture_panels(data, "x", "y", "x", raster = TRUE,
      raster_method = method, raster.dpi = 64,
      show_ellipse = FALSE, show_refline = FALSE, box_jitter = FALSE)
    points <- ggplot2::ggplot_build(p$panels$main)$data[[1]]
    expect_equal(points$x, data$x)
    expect_equal(points$y, data$y)
    expect_no_warning(grid::grid.draw(attr(p$plot, "grobs")$full))
  }
})

test_that("PlotScatter1 requires explicit mappings beyond twelve groups", {
  data <- data.frame(x = 1:26, y = rep(1:2, 13), g = rep(letters[1:13], each = 2))
  draw <- function(...) PlotScatter1(data, "x", "y", "g", show_ellipse = FALSE,
                                     box_jitter = FALSE, ...)
  expect_error(draw(), "12.*colors.*shapes")
  expect_error(draw(colors = grDevices::hcl.colors(13)), "12.*shapes")
  expect_error(draw(shapes = rep(16, 13)), "12.*colors")
  p <- draw(colors = grDevices::hcl.colors(13), shapes = rep(16, 13))
  expect_equal(scatter_main_points(attr(p, "grobs")$full), 26)
  recycled <- draw(colors = "red", shapes = 16)
  expect_equal(scatter_main_points(attr(recycled, "grobs")$full), 26)
  boundary <- PlotScatter1(data[1:24, ], "x", "y", "g", show_ellipse = FALSE,
                           box_jitter = FALSE)
  expect_equal(scatter_main_points(attr(boundary, "grobs")$full), 24)
})

test_that("PlotScatter2 requires explicit mappings beyond its default capacities", {
  data <- data.frame(x = 1:26, y = rep(1:2, 13), g = rep(letters[1:13], each = 2))
  expect_error(PlotScatter2(data, "x", "y", "g"), "12.*colors")
  p <- PlotScatter2(data, "x", "y", "g", colors = grDevices::hcl.colors(13))
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(nrow(points), 26L)
  expect_false(anyNA(points$colour))

  data <- data.frame(x = 1:14, y = rep(1:2, 7), g = "a",
                     h = rep(letters[1:7], each = 2))
  draw <- function(...) PlotScatter2(data, "x", "y", "g", group2 = "h", ...)
  shapes <- stats::setNames(rep(16, 7), letters[1:7])
  fills <- stats::setNames(grDevices::hcl.colors(7), letters[1:7])
  expect_error(draw(), "6.*shapes.*fill_colors_shape")
  expect_error(draw(shapes = shapes), "6.*fill_colors_shape")
  expect_error(draw(fill_colors_shape = fills), "6.*shapes")
  p <- draw(shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(nrow(points), 14L)
  expect_false(anyNA(points$shape))
  boundary <- PlotScatter2(data[1:12, ], "x", "y", "g", group2 = "h")
  expect_false(anyNA(ggplot2::ggplot_build(boundary[[1]])$data[[1]]$shape))
})

test_that("PlotScatter2 rejects incomplete explicit mappings", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  draw <- function(...) PlotScatter2(data, "x", "y", "g", group2 = "h", ...)
  mappings <- list(
    colors = c(b = "red", c = "blue", unused = "black"),
    shapes = c(Y = 17, Z = 15, unused = 16),
    fill_colors_shape = c(Y = "gold", Z = "green", unused = "black")
  )
  missing <- c(colors = "a", shapes = "X", fill_colors_shape = "X")
  for (arg in names(mappings)) {
    message <- tryCatch({
      do.call(draw, stats::setNames(list(mappings[[arg]]), arg))
      NULL
    }, error = conditionMessage)
    expect_identical(message, sprintf("'%s' is missing mappings for: %s.",
                                      arg, missing[[arg]]))

    message <- tryCatch({
      do.call(draw, stats::setNames(list(unname(mappings[[arg]][1:2])), arg))
      NULL
    }, error = conditionMessage)
    expect_identical(message, sprintf(
      "'%s' must supply at least 3 values, one for each observed group level.", arg
    ))
  }
})

test_that("PlotScatter2 matches complete named mappings by level", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = factor(rep(c("b", "a", "c"), each = 3),
                                levels = c("unused", "c", "a", "b")),
                     h = rep(c("Y", "X", "Z"), each = 3))
  colors <- c(c = "#336699", a = "#993333", b = "#339933", extra = "black")
  shapes <- c(Z = 15, X = 18, Y = 17, extra = 16)
  fills <- c(X = "#999933", Z = "#993399", Y = "#339999", extra = "white")
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h", colors = colors,
                    shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_identical(points$colour, unname(colors[as.character(data$g)]))
  expect_identical(points$shape, unname(shapes[data$h]))
  for (panel in c(2, 4)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, unname(colors[c("b", "a", "c")]))
  }
  for (panel in c(3, 5)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, unname(fills[c("Y", "X", "Z")]))
  }
})

test_that("PlotScatter2 matches unnamed mappings in order of first appearance", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  colors <- c("#336699", "#993333", "#339933", "black")
  shapes <- c(17, 18, 15, 16)
  fills <- c("#999933", "#993399", "#339999", "white")
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h", colors = colors,
                    shapes = shapes, fill_colors_shape = fills)
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_identical(points$colour, rep(colors[1:3], each = 3))
  expect_identical(points$shape, rep(shapes[1:3], each = 3))
  for (panel in c(2, 4)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, colors[1:3])
  }
  for (panel in c(3, 5)) {
    boxes <- ggplot2::ggplot_build(p[[panel]])$data[[1]]
    expect_identical(boxes$fill, fills[1:3])
  }
})

test_that("PlotScatter2 labels shape fills from unnamed mappings", {
  data <- data.frame(x = 1:9, y = 9:1,
                     g = rep(c("b", "a", "c"), each = 3),
                     h = rep(c("Y", "X", "Z"), each = 3))
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h",
                    fill_colors_shape = c("gold", "green", "blue"))
  labels <- scatter_grob_labels(ggplot2::ggplotGrob(p[[6]]))
  expect_setequal(intersect(labels, c("Y", "X", "Z")), c("Y", "X", "Z"))
})

test_that("PlotScatter2 honors colour legend positions with and without shapes", {
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6),
                     h = rep(c("X", "Y"), each = 6))
  cases <- list(
    list(group2 = NULL, color = "right", shape = "none"),
    list(group2 = NULL, color = "bottom", shape = "none"),
    list(group2 = "h", color = "right", shape = c(0.15, 0.15)),
    list(group2 = "h", color = "left", shape = "none"),
    list(group2 = "h", color = "top", shape = "bottom"),
    list(group2 = "h", color = "none", shape = "right")
  )
  for (case in cases) {
    p <- PlotScatter2(data, "x", "y", "g", group2 = case$group2,
                      legend_color_pos = case$color, legend_shape_pos = case$shape)
    grob <- ggplot2::ggplotGrob(p[[1]])
    if (case$color != "none") {
      color_box <- grob$grobs[[which(grob$layout$name ==
                                      paste0("guide-box-", case$color))]]
      expect_setequal(intersect(scatter_grob_labels(color_box), c("g", "h")), "g")
    } else {
      expect_equal(sum(scatter_grob_labels(grob) == "g"), 0L)
    }
    if (!is.null(case$group2) && !identical(case$shape, "none")) {
      shape_position <- if (is.numeric(case$shape)) "inside" else case$shape
      shape_box <- grob$grobs[[which(grob$layout$name ==
                                      paste0("guide-box-", shape_position))]]
      expect_setequal(intersect(scatter_grob_labels(shape_box), c("g", "h")), "h")
    } else {
      expect_equal(sum(scatter_grob_labels(grob) == "h"), 0L)
    }
  }
})

test_that("PlotScatter2 retains both fill legends without gridExtra", {
  no_grid_env <- new.env(parent = environment(PlotScatter2))
  no_grid_env$requireNamespace <- function(package, ...) {
    if (identical(package, "gridExtra")) FALSE else base::requireNamespace(package, ...)
  }
  draw <- PlotScatter2
  environment(draw) <- no_grid_env
  legend <- .make_scatter2_legend
  environment(legend) <- no_grid_env
  no_grid_env$.make_scatter2_legend <- legend
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6),
                     h = rep(c("X", "Y"), each = 6))
  p <- draw(data, "x", "y", "g", group2 = "h")
  legend_grob <- ggplot2::ggplotGrob(p[[6]])
  expected <- c("g", "h", "a", "b", "X", "Y")
  expect_setequal(intersect(scatter_grob_labels(legend_grob), expected), expected)
  grid::grid.draw(legend_grob)
})

test_that("PlotScatter2 groups ellipses by colour independently of point shapes", {
  set.seed(42)
  data <- data.frame(x = rnorm(40), y = rnorm(40),
                     g = rep(c("a", "b"), each = 20), h = rep(c("X", "Y"), 20))
  single <- PlotScatter2(data, "x", "y", "g", show_ellipse = TRUE)
  dual <- PlotScatter2(data, "x", "y", "g", group2 = "h", show_ellipse = TRUE)
  single_ellipse <- ggplot2::ggplot_build(single[[1]])$data[[2]]
  dual_ellipse <- ggplot2::ggplot_build(dual[[1]])$data[[2]]
  expect_length(unique(dual_ellipse$group), 2L)
  expect_equal(dual_ellipse[c("x", "y", "colour")],
               single_ellipse[c("x", "y", "colour")])
})

test_that("PlotScatter2 aligns marginal numeric ranges with the main panel", {
  set.seed(42)
  data <- data.frame(x = rnorm(40), y = rnorm(40),
                     g = rep(c("a", "b"), each = 20), h = rep(c("X", "Y"), 20))
  cases <- list(
    list(),
    list(group2 = "h", show_ellipse = TRUE, x_top = FALSE),
    list(group2 = "h", annot_text = "Note", annot_pos = c(8, -8))
  )
  for (mtype in c("boxplot", "violin", "violin_box")) {
    for (case in cases) {
      p <- do.call(PlotScatter2, c(list(data, "x", "y", "g", marginal_type = mtype),
                                  case))
      main <- ggplot2::ggplot_build(p[[1]])$layout$panel_params[[1]]
      n_groups <- if (is.null(case$group2)) 1L else 2L
      for (i in seq_len(n_groups)) {
        right <- ggplot2::ggplot_build(p[[i + 1L]])$layout$panel_params[[1]]
        bottom <- ggplot2::ggplot_build(p[[i + n_groups + 1L]])$layout$panel_params[[1]]
        expect_equal(right$y.range, main$y.range)
        expect_equal(bottom$x.range, main$x.range)
      }
    }
  }
})

test_that("PlotScatter2 defers ellipse notices until the main plot is drawn", {
  data <- data.frame(x = 1:6, y = c(3, 1, 4, 1, 5, 9),
                     g = rep(c("a", "b"), each = 3))
  get_messages <- function(code) {
    messages <- character()
    withCallingHandlers(force(code), message = function(m) {
      messages <<- c(messages, conditionMessage(m))
      invokeRestart("muffleMessage")
    })
    messages
  }
  expect_length(get_messages(
    p <- PlotScatter2(data, "x", "y", "g", show_ellipse = TRUE)
  ), 0L)
  draw_messages <- get_messages(ggplot2::ggplot_build(p[[1]]))
  expect_match(paste(draw_messages, collapse = " "), "Too few points")
})

test_that("PlotScatter2 builds fill legends independently of global legend visibility", {
  original_theme <- ggplot2::theme_get()
  withr::defer(ggplot2::theme_set(original_theme))
  ggplot2::theme_set(ggplot2::theme_void() + ggplot2::theme(legend.position = "none"))
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6),
                     h = rep(c("X", "Y"), each = 6))
  p <- PlotScatter2(data, "x", "y", "g", group2 = "h")
  labels <- scatter_grob_labels(ggplot2::ggplotGrob(p[[6]]))
  expected <- c("g", "h", "a", "b", "X", "Y")
  expect_setequal(intersect(labels, expected), expected)
})

test_that("PlotScatter2 keeps automatic annotation coordinates finite", {
  data <- data.frame(x = 1:12, y = 12:1, g = rep(c("a", "b"), 6))
  cases <- list(
    list(data = data, want = c(1.22, 11.78)),
    list(data = transform(data, x = replace(x, 1, Inf)), want = c(2.2, 11.78)),
    list(data = transform(data, y = replace(y, 1, Inf)), want = c(1.22, 10.8)),
    list(data = transform(data, y = NA_real_), want = c(1.22, 0.98)),
    list(data = data[FALSE, ], want = c(0.02, 0.98)),
    list(data = transform(data, y = replace(y, 1, Inf)),
         pos = c(-2, 5), want = c(-2, 5))
  )
  for (case in cases) {
    p <- suppressWarnings(PlotScatter2(case$data, "x", "y", "g",
                                       annot_text = "Annotation", annot_pos = case$pos))
    text <- ggplot2::ggplot_build(p[[1]])$data[[2]]
    expect_equal(c(text$x, text$y), case$want)
    grob <- suppressWarnings(ggplot2::ggplotGrob(p[[1]]))
    expect_equal(sum(scatter_grob_labels(grob) == "Annotation"), 1L)
  }
})

test_that("PlotScatter2 preserves numeric axes that are also grouping columns", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6),
                     g = rep(c("b", "a"), 6), h = rep(c("Y", "X"), each = 6),
                     .scatter2_axis = -seq_len(12), .scatter2_axis.1 = seq_len(12))
  before <- serialize(data, NULL)
  cases <- list(
    list(x = "x", y = "y", group = "x"),
    list(x = "x", y = "y", group = "x", group2 = "h", x_top = FALSE,
         show_cor = TRUE, show_regression = TRUE),
    list(x = "x", y = "y", group = "y"),
    list(x = "x", y = "y", group = "g", group2 = "x"),
    list(x = "x", y = "y", group = "g", group2 = "y"),
    list(x = "x", y = "y", group = "x", group2 = "y"),
    list(x = "x", y = "x", group = "x"),
    list(x = c(axis = "x"), y = "y", group = "x", x_top = FALSE)
  )
  for (case in cases) {
    p <- do.call(PlotScatter2, c(list(data = data), case))
    built <- ggplot2::ggplot_build(p[[1]])
    expect_equal(built$data[[1]]$x, data[[case$x]])
    expect_equal(built$data[[1]]$y, data[[case$y]])
    expect_equal(unname(p[[1]]$labels$x), unname(case$x))
    expect_equal(unname(p[[1]]$labels$y), unname(case$y))
    expect_identical(serialize(data, NULL), before)
    if (isTRUE(case$show_cor)) {
      expect_match(built$data[[3]]$label, "r = 0.000", fixed = TRUE)
      expect_equal(built$data[[2]]$y, rep(150, nrow(built$data[[2]])))
    }
    grid::grid.draw(patchwork::patchworkGrob(p))
  }
})

test_that("PlotScatter2 supports a column named .data in each plotting role", {
  data <- data.frame(x = rep(c(10, 30), 6), y = rep(c(100, 200), each = 6),
                     g = rep(c("b", "a"), 6), h = rep(c("Y", "X"), each = 6),
                     .scatter2_data = -seq_len(12), .scatter2_data.1 = seq_len(12))
  for (role in c("x", "y", "group", "group2")) {
    columns <- c(x = "x", y = "y", group = "g", group2 = "h")
    renamed <- data
    names(renamed)[match(columns[[role]], names(renamed))] <- ".data"
    columns[[role]] <- ".data"
    before <- serialize(renamed, NULL)
    p <- do.call(PlotScatter2, c(list(data = renamed), as.list(columns),
      list(colors = c(b = "#112233", a = "#445566"),
           shapes = c(Y = 16, X = 17))))
    points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
    expect_equal(points$x, data$x)
    expect_equal(points$y, data$y)
    expect_identical(points$colour, rep(c("#112233", "#445566"), 6))
    expect_identical(points$shape, rep(c(16, 17), each = 6))
    expect_equal(p[[1]]$labels$x, columns[["x"]])
    expect_equal(p[[1]]$labels$y, columns[["y"]])
    labels <- scatter_grob_labels(ggplot2::ggplotGrob(p[[6]]))
    expected <- unname(columns[c("group", "group2")])
    expect_setequal(intersect(labels, expected), expected)
    expect_identical(serialize(renamed, NULL), before)
    grid::grid.draw(patchwork::patchworkGrob(p))
  }
  names(data)[1] <- ".data"
  p <- PlotScatter2(data, ".data", "y", ".data", group2 = "h")
  points <- ggplot2::ggplot_build(p[[1]])$data[[1]]
  expect_equal(points$x, data[[".data"]])
  expect_equal(points$y, data$y)
  grid::grid.draw(patchwork::patchworkGrob(p))
})

test_that("PlotScatter2 preserves integer64 group identifiers in a fresh process", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  source_file <- file.path(scratch, "scatter2.R")
  input_file <- file.path(scratch, "groups.rds")
  script_file <- file.path(scratch, "verify.R")
  dump(c("PlotScatter2", ".make_scatter2_legend"), file = source_file,
       envir = environment(PlotScatter2))
  data <- data.frame(x = 1:12, y = 12:1)
  data$g <- bit64::as.integer64(rep(c("9007199254740993", "9007199254740995"), 6))
  data$h <- bit64::as.integer64(rep(c("9007199254741001", "9007199254741003"), each = 6))
  saveRDS(data, input_file)
  writeLines(c(
    "options(device = function(...) grDevices::pdf(NULL, ...), lifecycle_verbosity = 'quiet')",
    sprintf("sys.source(%s, envir = globalenv())", deparse(source_file)),
    sprintf("data <- readRDS(%s)", deparse(input_file)),
    "stopifnot(!('bit64' %in% loadedNamespaces()))",
    "colors <- c('9007199254740993' = '#112233', '9007199254740995' = '#445566')",
    "shapes <- c('9007199254741001' = 16, '9007199254741003' = 17)",
    "fills <- c('9007199254741001' = '#3377AA', '9007199254741003' = '#AA7733')",
    "p <- PlotScatter2(data, 'x', 'y', 'g', group2 = 'h', colors = colors,",
    "                  shapes = shapes, fill_colors_shape = fills)",
    "stopifnot(identical(levels(p[[1]]$data$g), names(colors)),",
    "          identical(levels(p[[1]]$data$h), names(shapes)))",
    "grid::grid.draw(patchwork::patchworkGrob(p))",
    "cat('INTEGER64_GROUPS_OK\\n')"
  ), script_file)
  output <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script_file)), stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  expect_identical(status, 0L, info = paste(output, collapse = "\n"))
  expect_identical(tail(output, 1L), "INTEGER64_GROUPS_OK")
})

test_that("PlotScatter2 reports the missing integer64 grouping dependency", {
  skip_if_not_installed("bit64")
  no_bit64_env <- new.env(parent = environment(PlotScatter2))
  no_bit64_env$requireNamespace <- function(package, ...) {
    if (identical(package, "bit64")) FALSE else base::requireNamespace(package, ...)
  }
  draw <- PlotScatter2
  environment(draw) <- no_bit64_env
  data <- data.frame(x = 1:4, y = 4:1)
  data$g <- bit64::as.integer64(c("9007199254740993", "9007199254740995", NA, NA))
  message <- tryCatch({
    draw(data, "x", "y", "g")
    NULL
  }, error = conditionMessage)
  expect_identical(message, "Package 'bit64' is required for integer64 grouping columns.")
})

test_that("PlotScatter3 shares theme validation and keeps its NULL theme", {
  data <- data.frame(Control = 1:8, Treat = c(1.2, 1.8, 3.5, 4.2, 5, 7, 7.3, 8),
                     group = rep(c("NS", "S"), 4))
  plot <- function(theme_use) {
    PlotScatter3(data, test_method = "none", cor_method = "none", theme_use = theme_use)
  }
  expect_error(plot("theme_mimimal"), "Theme 'theme_mimimal' not found")
  expect_error(plot(function() ggplot2::geom_point()), "must return a ggplot2 theme")
  expect_equal(plot("theme_minimal")[[1L]]$theme, plot(ggplot2::theme_minimal())[[1L]]$theme)
  expect_equal(plot(NULL)[[1L]]$theme, plot(ggplot2::theme_classic())[[1L]]$theme)
})

test_that("PlotScatter1 resolves the main theme without accepting plot components", {
  data <- data.frame(x = 1:8, y = c(1, 5, 2, 6, 3, 7, 4, 8),
                     g = rep(c("A", "B"), each = 4))
  draw <- function(theme_use) {
    scatter1_capture_panels(
      data, "x", "y", "g", show_ellipse = FALSE, show_refline = FALSE,
      box_jitter = FALSE, legend_pos = "none", theme_use = theme_use
    )$panels$main
  }

  expect_equal(draw("theme_minimal")$theme$text$size, 11)
  expect_equal(draw(function() ggplot2::theme_bw(base_size = 23))$theme$text$size, 23)
  expect_error(draw(function() ggplot2::geom_point()), "must return a ggplot2 theme")
  expect_length(draw(NULL)$layers, 1L)
})

test_that("PlotScatter1 honours the supplied main-panel styles and keeps layout", {
  skip_if_not_installed("ggtext")
  data <- data.frame(x = 1:8, y = c(1, 5, 2, 6, 3, 7, 4, 8),
                     g = rep(c("A", "B"), each = 4))
  draw <- function(th) scatter1_capture_panels(
    data, "x", "y", "g", show_ellipse = FALSE, show_refline = FALSE,
    box_jitter = FALSE, legend_pos = "none", theme_use = th
  )$panels$main

  styled <- draw(ggplot2::theme_bw() + ggplot2::theme(
    axis.title = ggplot2::element_text(size = 24, colour = "red"),
    panel.background = ggplot2::element_rect(fill = "#DDDABC"),
    legend.position = "right"
  ))
  expect_equal(styled$theme$axis.title$size, 24)
  expect_identical(styled$theme$axis.title$colour, "red")
  expect_identical(styled$theme$panel.background$fill, "#DDDABC")
  expect_identical(styled$theme$legend.position, "none")
  expect_s3_class(draw(ggplot2::theme(axis.title = ggplot2::element_blank()))$theme$axis.title,
                  "element_blank")
  md <- draw(ggplot2::theme(axis.title = ggtext::element_markdown(size = 21)))
  expect_s3_class(md$theme$axis.title, "element_markdown")
  expect_equal(draw(NULL)$theme$axis.title$size, 14)
})

test_that("scatter and rank groups decode integer64 storage in cold processes", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  source_file <- file.path(scratch, "functions.R")
  input_file <- file.path(scratch, "input.rds")
  script_file <- file.path(scratch, "verify.R")
  dump(c("PlotScatter1", "PlotScatter3", "PlotRank", ".pr_parse", ".resolve_theme"), source_file, envir = environment(PlotScatter1))
  labels <- c("9007199254740993", "9007199254740995")
  d <- data.frame(x = 1:8, y = c(2, 4, 3, 5, 7, 6, 9, 8), gene = letters[1:8])
  d[["g"]] <- bit64::as.integer64(rep(labels, 4L))
  saveRDS(d, input_file)
  calls <- c(
    "p <- PlotScatter1(d, 'x', 'y', 'g', show_ellipse = FALSE, box_jitter = FALSE); walk <- function(g) {if (inherits(g, 'text')) return(as.character(g$label)); unlist(lapply(c(g$grobs, as.list(g$children)), walk), use.names = FALSE)}; result <- walk(attr(p, 'grobs')$full)",
    "p <- PlotScatter3(d, 'x', 'y', 'g', test_method = 'none', cor_method = 'none', theme_use = ggplot2::theme_classic); result <- levels(p[[1]]$data$g)",
    "p <- PlotRank(d, group_col = 'g', name_col = 'gene', value_col = 'y', return_type = 'data'); result <- levels(p$Group)")
  for (call in calls) {
    writeLines(c(
      "options(device = function(...) grDevices::pdf(NULL, ...), lifecycle_verbosity = 'quiet')",
      sprintf("source(%s)", deparse(source_file)),
      "`%||%` <- rlang::`%||%`",
      sprintf("d <- readRDS(%s)", deparse(input_file)),
      "stopifnot(!('bit64' %in% loadedNamespaces()))", call,
      "stopifnot(all(c('9007199254740993', '9007199254740995') %in% result))",
      "cat('COLD_GROUPS_OK\n')"), script_file)
    output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script_file)), stdout = TRUE, stderr = TRUE))
    expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
    expect_identical(tail(output, 1L), 'COLD_GROUPS_OK')
  }
})

test_that("scatter statistics exclude SPSS user missing axis values", {
  skip_if_not_installed("haven")
  d <- data.frame(Control = 1:8, Treat = c(2, 4, 3, 5, 7, 6, 9, 99), group = rep(c("a", "b"), 4L))
  d[["Treat"]] <- haven::labelled_spss(d[["Treat"]], na_values = 99)
  normalized <- haven::zap_missing(d)
  before <- serialize(d, NULL)
  expect_identical(.scatter_cor_label(d[["Control"]], d[["Treat"]], "pearson"),
                   .scatter_cor_label(normalized[["Control"]], normalized[["Treat"]], "pearson"))
  draw <- function(data) withCallingHandlers(
    PlotScatter3(data, test_method = "t.test", cor_method = "none", theme_use = ggplot2::theme_classic),
    warning = function(w) {
      if (grepl("^Removed 1 row containing non-finite", conditionMessage(w)) &&
          grepl("stat_bin", conditionMessage(w), fixed = TRUE)) invokeRestart("muffleWarning")
    })
  p <- draw(d)
  q <- draw(normalized)
  labels <- function(plot) lapply(plot[[1L]]$layers, function(layer) layer$aes_params$label)
  expect_identical(labels(p), labels(q))
  expect_identical(is.na(as.double(p[[1L]]$data$Treat)), c(rep(FALSE, 7L), TRUE))
  p2 <- PlotScatter2(d, "Control", "Treat", "group")
  expect_identical(is.na(as.double(p2[[1L]]$data$Treat)), c(rep(FALSE, 7L), TRUE))
  expect_identical(serialize(d, NULL), before)
})

test_that("paired scatter annotation coordinates remain finite on wide axes", {
  d <- data.frame(Control = 1:8, Treat = c(2, 4, 3, 5, 7, 6, 9, 8), group = rep(c("a", "b"), 4L))
  p <- PlotScatter3(d, test_method = "t.test", cor_method = "pearson", axis_limits = c(-1e308, 1e308), axis_breaks = 0, hist_x_limits = c(-5, 5), hist_x_breaks = c(-5, 0, 5), theme_use = ggplot2::theme_classic)
  layers <- Filter(function(layer) inherits(layer$geom, "GeomText"), p[[1L]]$layers)
  expect_length(layers, 2L)
  expect_equal(vapply(layers, function(layer) layer$data$x / 1e308, numeric(1)), c(-.9, .9), ignore_attr = TRUE)
  expect_equal(vapply(layers, function(layer) layer$data$y / 1e308, numeric(1)), c(.96, -.84), ignore_attr = TRUE)
})
