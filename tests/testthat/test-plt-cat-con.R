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
  d$group <- factor(d$group, levels = c("C", "unused", "B", "A"))
  for (keep in c(FALSE, TRUE)) {
    p <- suppressMessages(plt_cat(d, "category", "group", position = "dodge", bg.by = "region",
                                  bg_palette = c("red", "blue", "green"), keep_empty = keep))
    b <- ggplot2::ggplot_build(p)
    kinds <- vapply(p$layers, function(l) class(l$geom)[[1L]], "")
    rects <- b$data[[which(kinds == "GeomRect")]]
    position <- match("B", b$layout$panel_params[[1L]]$x$get_labels())
    expect_equal(as.character(rects$fill[rects$xmin <= position & rects$xmax >= position]), "blue")
    expect_equal(b$layout$panel_params[[1L]]$x$get_labels(), c("C", "B", "A"))
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
