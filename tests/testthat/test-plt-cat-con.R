# Saving of plt_cat() and plt_con(): the page each plot is laid out for.

cat_test_plot <- function(...) {
  p <- NULL
  invisible(utils::capture.output(p <- suppressMessages(plt_cat(...))))
  p
}

cat_test_text <- function(grob) {
  c(if (inherits(grob, "text")) as.character(grob$label),
    unlist(lapply(grob$grobs, cat_test_text), use.names = FALSE),
    unlist(lapply(grob$children, cat_test_text), use.names = FALSE))
}

test_that("plt_cat preserves time values and their original missingness", {
  skip_if_not_installed("lubridate")
  dates <- as.POSIXct(c("2020-01-01", "2020-01-02", NA), tz = "UTC")
  inputs <- list(dates, as.POSIXlt(dates), lubridate::dseconds(c(1, 2, NA)),
                 lubridate::seconds(c(1, 2, NA)),
                 lubridate::interval(dates, dates + c(3600, 7200, NA)))
  for (x in inputs) {
    d <- data.frame(group = c("one", "two", "three"))
    d[["category"]] <- x
    p <- cat_test_plot(d, "category", stat = "count")
    expect_equal(sum(p$data$n), 2L)
    expect_equal(as.character(p$data$stat_var), as.character(x[!is.na(x)]))
    q <- cat_test_plot(d, "category", stat = "count", NA_stat = TRUE)
    expect_equal(q$data$n, rep(1L, 3))
    expect_equal(sum(ggplot2::ggplot_build(q)$data[[1]]$fill == "grey80"), 1L)
  }
  d <- data.frame(category = c("A", "A", "B"), time = dates)
  p <- cat_test_plot(d, "category", split.by = "time", stat = "count", NA_stat = TRUE)
  expect_length(p, 3L)
  expect_equal(sum(vapply(seq_len(length(p)), function(i) sum(p[[i]]$data$n), 0)), 3)
})

test_that("plt_cat resolves positive membership before splitting", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(FALSE, FALSE, TRUE, TRUE), B = TRUE,
                  site = c("negative", "negative", "positive", "positive"))
  whole <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = "upset"))
  split <- cat_test_plot(d, c("A", "B"), type = "upset", split.by = "site")
  expect_equal(split[[1]]$data$intersection, whole$data$intersection[1:2])
  expect_equal(split[[1]]$data$intersection, list("B", "B"))
  expect_equal(split[[2]]$data$intersection, whole$data$intersection[3:4])
  explicit <- cat_test_plot(d, c("A", "B"), type = "upset", split.by = "site",
                           stat_level = list(A = FALSE, B = TRUE))
  expect_equal(explicit[[1]]$data$intersection, rep(list(c("A", "B")), 2))
  expect_equal(explicit[[2]]$data$intersection, list("B", "B"))
})

test_that("plt_cat chord records drawable output on a file device", {
  skip_if_not_installed("circlize")
  skip_if_not_installed("ragg")
  skip_if_not_installed("RegR")
  withr::local_pdf(NULL, width = 7, height = 7)
  device <- grDevices::dev.cur()
  output <- withr::local_tempfile(fileext = ".pdf")
  p <- cat_test_plot(data.frame(A = c("a", "b", "a"), B = c("x", "y", "y")),
                     c("A", "B"), type = "chord", save = list(filename = output))
  expect_s3_class(p, "recordedplot")
  expect_identical(grDevices::dev.cur(), device)
  expect_true(file.exists(output))
  pixels <- local({
    capture <- ragg::agg_capture(width = 300, height = 300, units = "px")
    on.exit(grDevices::dev.off())
    grDevices::replayPlot(p)
    capture()
  })
  expect_gt(length(unique(as.vector(pixels))), 1L)
})

test_that("plt_cat upset handles one observation and singleton facets", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = TRUE, B = TRUE)
  p <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = "upset", stat_level = TRUE))
  expect_equal(p$data$intersection, list(c("A", "B")))
  expect_equal(sum(ggplot2::ggplot_build(p)$data[[1]]$count), 1)
  d <- data.frame(A = c(TRUE, FALSE), B = TRUE, site = c("one", "two"))
  p <- cat_test_plot(d, c("A", "B"), type = "upset", split.by = "site", stat_level = TRUE)
  expect_equal(p[[1]]$data$intersection, list(c("A", "B")))
  expect_equal(p[[2]]$data$intersection, list("B"))
  expect_equal(vapply(seq_len(length(p)), function(i) {
    sum(ggplot2::ggplot_build(p[[i]])$data[[1]]$count)
  }, 0), c(1, 1))
})

test_that("plt_cat upset applies alpha without changing intersection counts", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, FALSE, TRUE, FALSE), B = TRUE,
                  site = rep(c("one", "two"), each = 2))
  for (alpha in c(0, 0.35, 1)) {
    p <- cat_test_plot(d, c("A", "B"), type = "upset", alpha = alpha)
    bars <- ggplot2::ggplot_build(p)$data[[1]]
    expect_equal(bars$alpha, rep(alpha, 2))
    expect_equal(bars$count, c(2, 2))
  }
  p <- cat_test_plot(d, c("A", "B"), type = "upset", alpha = 0.35, split.by = "site")
  for (i in seq_len(length(p))) {
    bars <- ggplot2::ggplot_build(p[[i]])$data[[1]]
    expect_equal(bars$alpha, rep(0.35, 2))
    expect_equal(bars$count, c(1, 1))
  }
})

test_that("plt_cat excludes unused selectors before checking and filtering", {
  skip_if_not_installed("circlize")
  original <- getFromNamespace(".plt_cat_chord", "UtilsR")
  received <- NULL
  local_mocked_bindings(.plt_cat_chord = function(data, stat.by, ...) {
    received <<- list(n = nrow(data), columns = stat.by)
    original(data, stat.by, ...)
  }, .package = "UtilsR")
  d <- data.frame(A = c("a", "b", "a"), B = c("x", "x", "y"), extra = c("z", NA, "z"))
  expect_warning(p <- cat_test_plot(d, c("A", "B", "extra"), type = "chord"), "first 2")
  expect_s3_class(p, "recordedplot")
  expect_equal(received, list(n = 3L, columns = c("A", "B")))
  d <- data.frame(A = rep(c("a", "b"), 51), extra = seq_len(102))
  expect_warning(p <- cat_test_plot(d, c("A", "extra"), stat = "count"), "first element")
  expect_equal(sum(p$data$n), 102L)
  expect_warning(p <- cat_test_plot(d, c("A", "absent"), stat = "count"), "first element")
  expect_equal(sum(p$data$n), 102L)
})

test_that("plt_cat chord matches sector colours by name with unused levels", {
  skip_if_not_installed("circlize")
  d <- data.frame(A = factor(c("a", "b", "a"), levels = c("a", "unused", "b")),
                  B = c("x", "y", "x"))
  captured <- NULL
  original <- circlize::chordDiagram
  local_mocked_bindings(chordDiagram = function(x, grid.col, ...) {
    captured <<- grid.col
    original(x, grid.col = grid.col, ...)
  }, .package = "circlize")
  palette <- c(y = "orange", b = "blue", a = "red", x = "green")
  p <- cat_test_plot(d, c("A", "B"), type = "chord", palette = palette)
  expect_s3_class(p, "recordedplot")
  expect_identical(captured[names(palette)], palette)
  q <- cat_test_plot(d, c("A", "B"), type = "chord", palette = c("red", "blue", "green", "orange"))
  expect_identical(captured[c("a", "b", "x", "y")],
                   c(a = "red", b = "blue", x = "green", y = "orange"))
})

test_that("plt_cat area rejects layouts without two displayed group positions", {
  d <- data.frame(category = c("A", "B", "A"), group = "one")
  expect_error(cat_test_plot(d, "category", type = "area"), "group.by.*two displayed")
  expect_error(cat_test_plot(d, "category", "group", type = "area"), "group.by.*two displayed")
  d$group <- factor(d$group, levels = c("one", "two"))
  p <- cat_test_plot(d, "category", "group", type = "area", keep_empty = TRUE)
  expect_gt(nrow(ggplot2::ggplot_build(p)$data[[1]]), 0L)
  d <- data.frame(category = rep(c("A", "B"), 2),
                  group = rep(c("one", "two"), each = 2), site = rep(c("x", "y"), each = 2))
  expect_error(cat_test_plot(d, "category", "group", type = "area", split.by = "site"),
               "group.by.*two displayed")
})

test_that("plt_cat serialized plots do not retain unrelated input columns", {
  make_plot <- function(extra, split) {
    set.seed(12)
    d <- data.frame(category = rep(c("A", "B"), 1000),
                    group = rep(c("one", "two"), each = 1000),
                    site = rep(c("x", "y"), each = 1000))
    if (extra) for (i in seq_len(25)) d[[paste0("unused", i)]] <- stats::rnorm(nrow(d))
    p <- NULL
    invisible(utils::capture.output(p <- suppressMessages(UtilsR::plt_cat(
      d, "category", "group", split.by = if (split) "site" else NULL))))
    p
  }
  environment(make_plot) <- globalenv()
  files <- c(withr::local_tempfile(), withr::local_tempfile())
  for (split in c(FALSE, TRUE)) {
    small <- make_plot(FALSE, split)
    large <- make_plot(TRUE, split)
    if (split) {
      for (i in seq_len(length(small))) {
        expect_equal(ggplot2::ggplot_build(small[[i]])$data,
                     ggplot2::ggplot_build(large[[i]])$data)
      }
    } else {
      expect_equal(ggplot2::ggplot_build(small)$data, ggplot2::ggplot_build(large)$data)
    }
    saveRDS(small, files[1], compress = FALSE)
    saveRDS(large, files[2], compress = FALSE)
    expect_lt(diff(file.info(files)$size), 32768)
  }
})

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

test_that("plt_cat area endpoint labels stay inside the rendered panel", {
  d <- data.frame(category = factor(c("A", "A", "A", "A", "B", "B", "B")),
                  group = factor(c("G1", "G1", "G3", "G3", "G1", "G2", "G3")))
  withr::local_pdf(NULL, width = 4, height = 4)
  grid::pushViewport(grid::viewport(width = grid::unit(3, "inches"),
                                    height = grid::unit(3, "inches")))
  withr::defer(grid::popViewport())
  for (position in c("stack", "dodge")) {
    p <- cat_test_plot(d, "category", "group", type = "area",
                      position = position, label = TRUE)
    g <- ggplot2::ggplotGrob(p)
    panel <- g$grobs[[which(g$layout$name == "panel")]]
    tree <- panel$children[[which(vapply(panel$children, inherits, logical(1), "textrepeltree"))]]
    labels <- grid::makeContent(tree)$children
    labels <- labels[grepl("^textrepelgrob", names(labels))]
    expect_gt(length(labels), 0L)
    bounds <- vapply(labels, function(x) {
      c(grid::convertX(grid::grobX(x, "west"), "npc", valueOnly = TRUE),
        grid::convertX(grid::grobX(x, "east"), "npc", valueOnly = TRUE))
    }, numeric(2))
    expect_gte(min(bounds[1, ]), 0)
    expect_lte(max(bounds[2, ]), 1)
  }
})

test_that("plt_cat measures only the final split canvas", {
  skip_if_not_installed("RegR")
  original <- getFromNamespace(".save_sized", "UtilsR")
  calls <- 0L
  local_mocked_bindings(.save_sized = function(...) {
    calls <<- calls + 1L
    original(...)
  }, .package = "UtilsR")
  d <- data.frame(category = rep(c("A", "B"), 3), site = rep(c("x", "y", "z"), each = 2))
  p <- cat_test_plot(d, "category", split.by = "site")
  expect_equal(calls, 1L)
  expect_s3_class(p, "patchwork")
  expect_length(attr(p, "plot_size"), 2L)
  expect_equal(sum(vapply(seq_len(length(p)), function(i) sum(p[[i]]$data$n), 0)), 6)
})

test_that("plt_cat set plots honour labels titles and theme controls", {
  d <- data.frame(A = c(TRUE, TRUE, FALSE), B = c(TRUE, FALSE, TRUE))
  for (type in c("upset", "venn", "sankey")) {
    skip_if_not_installed(switch(type, upset = "ggupset", venn = "ggVennDiagram", sankey = "ggsankey"))
    p <- suppressWarnings(cat_test_plot(d, c("A", "B"), type = type, label = FALSE,
                      base_size = 20, legend.position = "none", xlab = "X", ylab = "Y"))
    labs <- if (exists("get_labs", asNamespace("ggplot2"))) ggplot2::get_labs(p) else p$labels
    expect_equal(labs$x, "X")
    expect_equal(labs$y, "Y")
    expect_equal(p$theme$text$size, 20)
    expect_equal(p$theme$legend.position, "none")
    if (type == "upset") {
      expect_false(any(vapply(p$layers, function(l) inherits(l$geom, "GeomTextRepel"), logical(1))))
      q <- cat_test_plot(d, c("A", "B"), type = type, label = TRUE, label.size = 5, label.fg = "brown")
      layer <- ggplot2::ggplot_build(q)$data[[2]]
      expect_equal(unique(layer$colour), "brown")
      expect_equal(unique(layer$size), 5)
    }
    if (type == "venn") {
      labels <- unlist(lapply(ggplot2::ggplot_build(p)$data, function(x) x$label))
      expect_false(any(grepl("[0-9]", labels)))
    }
  }
})

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

test_that("plt_cat trend dodge keeps areas within the category positions", {
  d <- data.frame(category = c("A", "B", "A", "B"),
                  group = c("G1", "G1", "G2", "G2"),
                  region = c("North", "North", "South", "South"))
  for (flip in c(FALSE, TRUE)) {
    p <- cat_test_plot(d, "category", "group", type = "trend", stat = "count",
                      position = "dodge", label = TRUE, flip = flip)
    b <- ggplot2::ggplot_build(p)
    expect_true(all(b$data[[1]]$x >= 0.69 & b$data[[1]]$x <= 2.31))
    expect_equal(range(b$data[[1]]$ymax), c(0, 1))
    expect_equal(as.numeric(b$data[[2]]$x), as.numeric(b$data[[3]]$x))
    q <- cat_test_plot(d, "category", "group", type = "trend", stat = "count",
                      position = "dodge", label = TRUE, flip = flip, bg.by = "region")
    expect_equal(ggplot2::ggplot_build(q)$data[-1], b$data)
  }
  stacked <- cat_test_plot(d, "category", "group", type = "trend", stat = "count")
  expect_equal(max(ggplot2::ggplot_build(stacked)$data[[1]]$ymax), 2)
})

test_that("plt_cat split figures show overall titles once", {
  d <- data.frame(category = c("A", "B", "A", "B"),
                  site = c("one", "one", "two", "two"))
  p <- cat_test_plot(d, "category", split.by = "site", title = "Overall title",
                    subtitle = "Overall subtitle", base_size = 20)
  labels <- cat_test_text(patchwork::patchworkGrob(p))
  expect_equal(sum(labels == "Overall title"), 1L)
  expect_equal(sum(labels == "Overall subtitle"), 1L)
  expect_true(all(c("one", "two") %in% labels))
  expect_equal(p$patches$annotation$theme$text$size, 20)
  single <- cat_test_plot(d, "category", title = "Single title", subtitle = "Single subtitle")
  labels <- cat_test_text(ggplot2::ggplotGrob(single))
  expect_true(all(c("Single title", "Single subtitle") %in% labels))
})

test_that("plt_cat split figures collect partially overlapping fill legends", {
  d <- data.frame(category = factor(c("A", "B", "A", "C"),
                                   levels = c("C", "B", "A", "unused")),
                  site = c("one", "one", "two", "two"))
  for (type in c("bar", "pie", "ring", "trend", "dot")) {
    p <- cat_test_plot(d, "category", split.by = "site", type = type,
                      palette = c(C = "red", B = "blue", A = "green"))
    g <- patchwork::patchworkGrob(p)
    guide <- g$grobs[[which(g$layout$name == "guide-box")]]
    labels <- cat_test_text(guide)
    expect_equal(labels[labels %in% c("A", "B", "C", "unused")], c("C", "B", "A"))
    expect_equal(nrow(p[[1]]$data), 2L)
    expect_equal(as.character(p[[1]]$data$stat_var), c("B", "A"))
    expect_equal(ggplot2::ggplot_build(p[[2]])$plot$scales$get_scales("fill")$map(c("C", "A")),
                 c("red", "green"))
  }
})

test_that("plt_cat rejects Venn inputs beyond seven sets clearly", {
  d <- as.data.frame(setNames(rep(list(c(TRUE, FALSE, TRUE)), 8), LETTERS[1:8]))
  expect_error(plt_cat(d, names(d), type = "venn"), "seven.*upset")
  skip_if_not_installed("ggVennDiagram")
  p <- suppressMessages(cat_test_plot(d, names(d)[1:7], type = "venn"))
  expect_s3_class(p, "ggplot")
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
})

test_that("plt_cat Sankey stages accept backend reserved column names", {
  skip_if_not_installed("ggsankey")
  d <- data.frame(first = c("a", "b", "a"), second = c("x", "y", "x"))
  baseline <- suppressWarnings(cat_test_plot(d, names(d), type = "sankey"))
  expected <- ggplot2::ggplot_build(baseline)$data
  # Stage labels differ by design; compare next-stage positions numerically.
  for (i in seq_along(expected)) {
    if (is.factor(expected[[i]]$next_x)) expected[[i]]$next_x <- as.numeric(expected[[i]]$next_x)
  }
  for (stage_names in list(c("..r", "second"), c("node", "value"), c(".stage1", "Tumor stage"))) {
    names(d) <- stage_names
    original <- d
    p <- suppressWarnings(cat_test_plot(d, names(d), type = "sankey"))
    b <- ggplot2::ggplot_build(p)
    for (i in seq_along(b$data)) {
      if (is.factor(b$data[[i]]$next_x)) b$data[[i]]$next_x <- as.numeric(b$data[[i]]$next_x)
    }
    expect_equal(b$data, expected)
    expect_equal(b$layout$panel_params[[1]]$x$get_labels(), stage_names)
    expect_identical(d, original)
  }
})

test_that("plt_cat named palettes map empty string categories", {
  d <- data.frame(category = c("", "A", "", NA), site = c("one", "one", "two", "two"))
  colors <- setNames(c("red", "blue"), c("", "A"))
  p <- cat_test_plot(d, "category", stat = "count", palette = colors, NA_stat = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$data[[1]]$fill[as.character(p$data$stat_var) == ""], "red")
  expect_equal(b$data[[1]]$fill[as.character(p$data$stat_var) == "A"], "blue")
  expect_equal(sum(p$data$n), 4L)
  expect_equal(sum(b$data[[1]]$fill == "grey80"), 1L)
  q <- cat_test_plot(d, "category", split.by = "site", palette = colors, NA_stat = TRUE)
  expect_equal(ggplot2::ggplot_build(q[[2]])$data[[1]]$fill, c("red", "grey80"))
  expect_error(plt_cat(d, "category", palette = setNames(c("red", "blue"), c("", ""))), "unique")
})

test_that("plt_cat validates split layout dimensions before plotting", {
  d <- data.frame(category = c("A", "B", "A"), site = c("one", "two", "three"))
  for (arg in c("facet_nrow", "facet_ncol")) {
    for (value in list(0, -1, 1.5, NA_real_, Inf, TRUE, "2", c(1, 2), matrix(1))) {
      args <- list(data = d, stat.by = "category", split.by = "site")
      args[[arg]] <- value
      expect_error(do.call(plt_cat, args), paste0(arg, ".*positive integer"))
    }
  }
  expect_error(plt_cat(d, "category", split.by = "site", facet_nrow = 1, facet_ncol = 2),
               "facet_nrow.*facet_ncol.*panels")
  p <- cat_test_plot(d, "category", split.by = "site", facet_nrow = 1, facet_ncol = 3)
  expect_length(p, 3L)
  expect_s3_class(patchwork::patchworkGrob(p), "gtable")
})

test_that("plt_cat excludes ignored background columns before validation", {
  skip_if_not_installed("ggupset")
  d <- data.frame(A = c(TRUE, FALSE, TRUE), B = c(TRUE, TRUE, FALSE),
                  group = c("one", "two", "one"))
  for (args in list(list(stat.by = "A", position = "dodge"),
                   list(stat.by = "A", group.by = "group"),
                   list(stat.by = "A", group.by = "group", type = "pie"),
                   list(stat.by = c("A", "B"), type = "upset"))) {
    baseline <- do.call(cat_test_plot, c(list(data = d), args))
    expect_warning(p <- do.call(cat_test_plot, c(list(data = d, bg.by = "absent"), args)),
                   "bg.by.*[Ii]gnored")
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(baseline)$data)
  }
  expect_error(plt_cat(d, "A", "group", position = "dodge", bg.by = "absent"), "absent.*not found")
})

test_that("plt_cat Sankey compresses repeated paths without changing flows", {
  skip_if_not_installed("ggsankey")
  d <- data.frame(A = factor(c("a", "b", "a", "a", NA), levels = c("b", "a", "unused")),
                  B = c("x", "y", "x", "x", "x"), C = c("u", "v", "u", "u", "v"))
  for (keep_na in c(FALSE, TRUE)) {
    p <- suppressWarnings(cat_test_plot(d, names(d), type = "sankey", NA_stat = keep_na))
    expect_equal(nrow(p$data), if (keep_na) 9L else 6L)
    expect_equal(sum(p$data$value[p$data$x == "A"]), if (keep_na) 5 else 4)
    expect_equal(sort(p$data$value[p$data$x == "A"]), if (keep_na) c(1, 1, 3) else c(1, 3))
    expanded <- p
    expanded$data <- p$data[rep(seq_len(nrow(p$data)), p$data$value), , drop = FALSE]
    expanded$data$value <- 1L
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(expanded)$data)
  }
})

test_that("plt_cat warns when UpSet hides intersections beyond twenty", {
  skip_if_not_installed("ggupset")
  withr::local_options(lifecycle_verbosity = "quiet")
  d <- expand.grid(A = c(FALSE, TRUE), B = c(FALSE, TRUE), C = c(FALSE, TRUE),
                   D = c(FALSE, TRUE), E = c(FALSE, TRUE))[-1, ]
  expect_warning(p <- cat_test_plot(d, names(d), type = "upset", stat_level = TRUE,
                                   label = TRUE), "20.*31")
  expect_warning(b <- ggplot2::ggplot_build(p), NA)
  expect_equal(nrow(b$data[[1]]), 20L)
  expect_equal(sum(b$data[[1]]$count), 20L)
  expect_equal(nrow(b$data[[2]]), 20L)
  expect_warning(q <- cat_test_plot(d[1:4, ], names(d), type = "upset", stat_level = TRUE), NA)
  expect_equal(sum(ggplot2::ggplot_build(q)$data[[1]]$count), 4L)
})
