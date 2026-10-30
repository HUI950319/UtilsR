# Saving of plt_cat() and plt_con(): the page each plot is laid out for.

cat_test_plot <- function(...) {
  p <- NULL
  invisible(utils::capture.output(p <- suppressMessages(plt_cat(...))))
  p
}

test_that("plt_cat area and trend retain zero frequencies for interpolation", {
  d <- data.frame(category = factor(c("A", "A", "A", "A", "B", "B", "B")),
                  group = factor(c("G1", "G1", "G3", "G3", "G1", "G2", "G3")))
  for (type in c("area", "trend")) {
    p <- cat_test_plot(d, "category", "group", type = type, label = TRUE)
    b <- ggplot2::ggplot_build(p)
    expect_lte(max(b$data[[1]]$ymax), 100 + 1e-8)
    expect_equal(p$data$n[p$data$stat_var == "A" & p$data$group_var == "G2"], 0L)
    expect_false("0.0%" %in% b$data[[length(b$data)]]$label)
  }
})

cat_con_data <- function() {
  set.seed(7)
  data.frame(
    stage = factor(sample(c("I", "II", "III", "IV"), 120, TRUE)),
    sex = factor(sample(c("Female", "Male"), 120, TRUE)),
    site = factor(sample(c("A", "B", "C"), 120, TRUE)),
    age = stats::rnorm(120, 60, 10),
    bmi = stats::rnorm(120, 25, 4)
  )
}

test_that("plt_cat rejects malformed selectors empty input and unused arguments", {
  d <- data.frame(A = c(TRUE, FALSE), B = c(FALSE, TRUE))
  expect_error(plt_cat(d, "A", linewidth = 5), "unused|must be empty")
  expect_error(plt_cat(d, "A", group.by = c("A", "B")), "group.by.*single")
  expect_error(plt_cat(d, c("A", "A"), type = "upset"), "unique")
  expect_error(plt_cat(d[FALSE, ], "A"), "observation")
  expect_error(plt_cat(data.frame(A = c(NA, NA)), "A"), "observation")
  expect_error(plt_cat(d, c("A", "B"), split.by = "A", type = "chord"), "split.by.*chord")
  expect_error(plt_cat(d, "A", NA_stat = NA), "NA_stat")
  bad <- data.frame(A = I(list(1, 2)))
  expect_error(plt_cat(bad, "A"), "one-dimensional")
})

test_that("plt_cat checks explicit positive level mappings", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, FALSE), B = c(FALSE, TRUE))
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = list(A = TRUE)), "stat_level.*B")
  expect_error(plt_cat(d, c("A", "B"), type = "upset", stat_level = c(TRUE, FALSE, TRUE)), "stat_level")
})

test_that("plt_cat dodge labels follow bar widths and overlay values", {
  d <- data.frame(category = c("A", "A", "B", "A", "A", "A", "B", "C"),
                  group = rep(c("G1", "G2"), c(3, 5)))
  for (type in c("bar", "rose", "trend", "ring")) {
    p <- cat_test_plot(d, "category", "group", type = type, stat = "count",
                      position = "dodge", label = TRUE)
    b <- ggplot2::ggplot_build(p)
    bar <- which(vapply(p$layers, function(l) inherits(l$geom, "GeomCol"), logical(1)))
    labs <- b$data[[length(b$data)]]
    expect_equal(as.numeric(labs$x), as.numeric(b$data[[bar]]$x))
    expect_equal(labs$y, b$data[[bar]]$ymax)
  }
  p <- cat_test_plot(d, "category", "group", type = "area", stat = "count",
                    position = "dodge", label = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$data[[length(b$data)]]$y, p$data$value)
})

test_that("plt_cat counts columns with non syntactic names directly", {
  for (name in c("Tumor stage", "a+b", "x`y", ".")) {
    d <- setNames(data.frame(category = c("I", "II", "I", "III"),
                             group = c("a", "a", "b", "b")), c(name, "Group name"))
    p <- cat_test_plot(d, name, "Group name")
    expect_equal(p$data$n, rep(1L, 4))
    expect_equal(p$data$value, rep(50, 4))
    expect_equal(names(p$data), c("stat_var", "group_var", "n", "value", "label_text"))
    expect_s3_class(p$data, "tbl_df")
    q <- cat_test_plot(d, name, stat = "count")
    expect_equal(q$data$n, c(2L, 1L, 1L))
  }
})

test_that("plt_cat keeps unused category and group levels when requested", {
  d <- data.frame(category = factor(c("A", "B", "A"), levels = c("A", "B", "C")),
                  group = factor(c("G1", "G2", "G1"), levels = c("G1", "G2", "G3")))
  for (type in c("bar", "dot", "area", "trend")) {
    p <- cat_test_plot(d, "category", "group", type = type, stat = "count", keep_empty = TRUE)
    b <- ggplot2::ggplot_build(p)
    expect_equal(nrow(p$data), 9L)
    expect_equal(b$layout$panel_params[[1]]$x$get_labels(), c("G1", "G2", "G3"))
    expect_equal(b$plot$scales$get_scales("fill")$get_limits(), c("A", "B", "C"))
    expect_equal(sum(p$data$n), 3L)
  }
  q <- cat_test_plot(d, "category", "group", keep_empty = FALSE)
  expect_equal(ggplot2::ggplot_build(q)$layout$panel_params[[1]]$x$get_labels(), c("G1", "G2"))
})

test_that("plt_cat ignores set grouping during filtering and cardinality checks", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, TRUE, FALSE), B = c(TRUE, FALSE, TRUE),
                  group = c(NA, "G", "G"))
  p <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = "upset"))
  expect_warning(q <- cat_test_plot(d, c("A", "B"), "group", type = "upset"), "ignored")
  expect_equal(nrow(q$data), nrow(p$data))
  many <- data.frame(A = rep(TRUE, 101), B = rep(FALSE, 101), group = seq_len(101))
  expect_warning(q <- cat_test_plot(many, c("A", "B"), "group", type = "upset"), "ignored")
  expect_equal(nrow(q$data), 101L)
})

test_that("plt_cat includes missing split groups and preserves missing colours", {
  d <- data.frame(category = c("A", NA, "A", NA),
                  site = factor(c("one", "one", NA, NA), exclude = NULL))
  p <- cat_test_plot(d, "category", split.by = "site", stat = "count",
                    NA_stat = TRUE, NA_color = "grey80", palette = "red")
  expect_length(p, 2L)
  expect_equal(sum(vapply(seq_len(length(p)), function(i) sum(p[[i]]$data$n), 0)), 4)
  for (i in seq_len(length(p))) {
    expect_equal(sum(ggplot2::ggplot_build(p[[i]])$data[[1]]$fill == "grey80"), 1L)
  }
})

test_that("plt_cat distinguishes literal NA labels from missing observations", {
  d <- data.frame(category = factor(c("NA", "A", NA)))
  p <- cat_test_plot(d, "category", NA_stat = TRUE, stat = "count",
                    palette = c(A = "red", `NA` = "blue"), NA_color = "grey80")
  b <- ggplot2::ggplot_build(p)
  expect_equal(p$data$n, rep(1L, 3))
  expect_equal(length(unique(as.character(p$data$stat_var))), 3L)
  expect_equal(b$data[[1]]$fill[p$data$stat_var == "NA"], "blue")
  expect_equal(sum(b$data[[1]]$fill == "grey80"), 1L)
})

test_that("plt_cat handles explicit missing factor levels", {
  d <- data.frame(category = factor(c("A", NA), exclude = NULL))
  p <- cat_test_plot(d, "category", stat = "count")
  expect_equal(sum(p$data$n), 1L)
  q <- cat_test_plot(d, "category", stat = "count", NA_stat = TRUE)
  expect_equal(sum(q$data$n), 2L)
  expect_equal(sort(ggplot2::ggplot_build(q)$data[[1]]$fill), sort(c(pal_lancet[1], "grey80")))
})

test_that("plt_cat respects SPSS user missing values before factor conversion", {
  skip_if_not_installed("haven")
  d <- data.frame(category = haven::labelled_spss(c(1, 99, 1), na_values = 99))
  p <- cat_test_plot(d, "category", stat = "count")
  expect_equal(as.character(p$data$stat_var), "1")
  expect_equal(p$data$n, 2L)
  q <- cat_test_plot(d, "category", stat = "count", NA_stat = TRUE)
  expect_equal(sort(q$data$n), c(1L, 2L))
  expect_false("99" %in% as.character(q$data$stat_var))
})

test_that("plt_cat pie and ring use shared radii and stable angular totals", {
  d <- data.frame(category = factor(c("A", "A", "B")))
  for (type in c("pie", "ring")) {
    builds <- lapply(c(FALSE, TRUE), function(label) {
      p <- cat_test_plot(d, "category", type = type, stat = "count", label = label)
      expect_warning(g <- ggplot2::ggplotGrob(p), NA)
      b <- ggplot2::ggplot_build(p)
      expect_length(unique(b$data[[1]]$x), 1L)
      expect_equal(sort(b$data[[1]]$ymax - b$data[[1]]$ymin), c(1, 2))
      expect_equal(b$layout$panel_params[[1]]$theta.range, c(0, 3))
      expect_false(anyNA(b$plot$scales$get_scales("fill")$get_limits()))
      b
    })
    expect_equal(builds[[1]]$data[[1]], builds[[2]]$data[[1]])
    labels <- builds[[2]]$data[[2]]
    expect_equal(as.numeric(labels$x), as.numeric(builds[[2]]$data[[1]]$x))
    expect_equal(labels$y, (builds[[2]]$data[[1]]$ymin + builds[[2]]$data[[1]]$ymax) / 2)
  }
})

test_that("plt_cat background helper preserves displayed group order", {
  d <- data.frame(category = factor(rep(c("Yes", "No", "Yes"), 3)),
                  group = factor(rep(c("C", "B", "A"), each = 3), levels = c("C", "B", "A")),
                  region = rep(c("R3", "R2", "R1"), each = 3))
  d$group <- factor(d$group, levels = c("left", "C", "unused", "B", "A", "right"))
  for (keep in c(FALSE, TRUE)) {
    p <- suppressMessages(plt_cat(d, "category", "group", position = "dodge", bg.by = "region",
                                  bg_palette = c("red", "blue", "green"), keep_empty = keep))
    b <- ggplot2::ggplot_build(p)
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    rects <- b$data[[which(kinds == "GeomRect")]]
    position <- match("B", b$layout$panel_params[[1L]]$x$get_labels())
    expect_equal(as.character(rects$fill[rects$xmin <= position & rects$xmax >= position]), "blue")
    expect_equal(b$layout$panel_params[[1L]]$x$get_labels(),
                 if (keep) c("left", "C", "unused", "B", "A", "right") else c("C", "B", "A"))
    if (keep) {
      expect_false(any(rects$xmin <= 1 & rects$xmax >= 1))
      expect_false(any(rects$xmin <= 6 & rects$xmax >= 6))
    }
  }
})

test_that("plt_cat saves at its page size and reports a split figure once", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_cat)), 1), "save")
  d <- cat_con_data()
  f <- withr::local_tempfile(fileext = ".pdf")
  for (type in c("bar", "pie")) {
    out <- cli::cli_fmt(p <- suppressMessages(plt_cat(
      d, stat.by = "stage", group.by = "sex", type = type, save = list(filename = f))))
    expect_saved_at_plot_size(out, p)
  }
  out <- cli::cli_fmt(p <- suppressMessages(plt_cat(
    d, stat.by = "stage", group.by = "sex", split.by = "site",
    save = list(filename = f))))
  expect_equal(sum(grepl("laid out for", out)), 1L)
  expect_saved_at_plot_size(out, p)
  utils::capture.output(one <- suppressMessages(plt_cat(d, stat.by = "stage",
                                                        group.by = "sex")))
  expect_gt(attr(p, "plot_size")[[1]], attr(one, "plot_size")[[1]])
})

test_that("plt_con saves at its page size and refuses a list of plots", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_con)), 1), "save")
  d <- cat_con_data()
  f <- withr::local_tempfile(fileext = ".pdf")
  out <- cli::cli_fmt(p <- suppressMessages(suppressWarnings(plt_con(
    d, stat.by = "age", group.by = "stage", save = list(filename = f)))))
  expect_saved_at_plot_size(out, p)
  out <- cli::cli_fmt(p <- suppressMessages(suppressWarnings(plt_con(
    d, stat.by = c("age", "bmi"), group.by = "stage", split.by = "sex",
    save = list(filename = f)))))
  expect_equal(sum(grepl("laid out for", out)), 1L)
  expect_saved_at_plot_size(out, p)
  expect_error(suppressMessages(suppressWarnings(plt_con(
    d, stat.by = c("age", "bmi"), group.by = "stage", combine = FALSE,
    save = list(filename = f)))), "list of plots")
})
