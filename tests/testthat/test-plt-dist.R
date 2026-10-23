dist_test_plot <- function(...) {
  output <- utils::capture.output(p <- plt_dist(...))
  p
}

test_that("bar calculations do not overwrite selected input names", {
  data <- data.frame(x = c("A", "A", "B", "B"),
                     group = c("F", "M", "F", "M"))
  original <- data
  reference <- ggplot2::ggplot_build(
    dist_test_plot(data, c("x", "group"), type = "bar")
  )$data

  for (column in c("x", "group")) {
    for (name in c("n", "prop", ".lab")) {
      renamed <- data
      names(renamed)[names(renamed) == column] <- name
      variables <- if (column == "x") c(name, "group") else c("x", name)
      p <- dist_test_plot(renamed, variables, type = "bar")
      expect_identical(as.character(p$data[[name]]),
                       as.character(factor(data[[column]])))
      expect_equal(ggplot2::ggplot_build(p)$data, reference)
    }
  }
  expect_identical(data, original)
})

dist_label_data <- function() {
  data.frame(x = rep(c("A", "B"), c(1500, 3)),
             group = c(rep("F", 1499), "M", "F", "M", "M"))
}

test_that("plt_dist packs its plot settings into plt_alluvial-style lists", {
  expect_identical(
    names(formals(plt_dist)),
    c("data", "dis_vars", "type", "facet", "color", "alpha", "label_args",
      "flow_args", "stratum_args", "facet_args", "legend_args", "theme_use", "save")
  )
  defaults <- lapply(
    c("label_args", "flow_args", "stratum_args", "facet_args", "legend_args"),
    \(argument) eval(formals(plt_dist)[[argument]])
  )
  expect_identical(defaults, list(
    list(style = "count_percent", min_pct = 0, size = NULL, color = "black",
         box = TRUE, fill = "white", alpha = 1, pct_accuracy = 0.1),
    list(curve_type = "linear"),
    list(width = 0.5, color = "gray50", linewidth = 0.3, gap = 0.01),
    list(nrow = NULL, ncol = NULL, scales = "fixed"),
    list(position = NULL, ncol = 1)
  ))
  data <- data.frame(x = c("A", "B"), group = c("F", "M"))
  # `label` partially matches `label_args`, so an old string value is rejected there.
  expect_error(plt_dist(data, c("x", "group"), label = "none"), "label_args.*named list")
  expect_error(plt_dist(data, c("x", "group"), gap = 0), "unused argument")
  expect_error(plt_dist(data, c("x", "group"), curve_type = "linear"), "unused argument")
  for (argument in c("label_args", "flow_args", "stratum_args", "facet_args",
                     "legend_args")) {
    expect_error(rlang::exec(plt_dist, data, c("x", "group"), type = "bar",
                             !!!stats::setNames(list(list(unknown = 1)), argument)),
                 "unknown")
  }
  expect_error(plt_dist(data, c("x", "group"), type = "bar",
                        label_args = list(style = "name")), "label_args\\$style")
  expect_error(plt_dist(data, c("x", "group"), type = "bar",
                        label_args = list(pct_accuracy = 0)), "pct_accuracy")
  expect_error(plt_dist(data, c("x", "group"), type = "bar",
                        legend_args = list(position = "middle")), "position")
})

test_that("bar labels, axis and label boxes follow label_args", {
  bar <- dist_test_plot(dist_label_data(), c("x", "group"), type = "bar")
  labels <- ggplot2::layer_data(bar, 2L)
  expect_identical(labels$label,
                   c("1,499 (99.9%)", "1 (0.1%)", "1 (33.3%)", "2 (66.7%)"))
  expect_true(all(labels$fill == "white"))
  expect_equal(unique(labels$size), (14 - 4) / ggplot2::.pt)
  bars <- ggplot2::layer_data(bar, 1L)
  expect_equal(labels$y, (bars$ymin + bars$ymax) / 2)
  built <- ggplot2::ggplot_build(bar)
  expect_identical(built$layout$panel_params[[1]]$y$get_labels(),
                   c("0%", "25%", "50%", "75%", "100%"))

  wrap <- dist_test_plot(dist_label_data(), c("x", "group"), type = "bar",
                         label_args = list(style = "count_percent_wrap",
                                           min_pct = 0.05, pct_accuracy = 1,
                                           size = 4, box = FALSE, color = "red"))
  expect_s3_class(wrap$layers[[2]]$geom, "GeomText")
  labels <- ggplot2::layer_data(wrap, 2L)
  expect_identical(labels$label[!is.na(labels$label)],
                   c("1,499\n100%", "1\n33%", "2\n67%"))
  expect_true(all(labels$colour == "red"))
  expect_equal(unique(labels$size), 4)

  heat <- data.frame(x = c("A", "B"), y = "C", group = c("F", "M"))
  tiles <- dist_test_plot(heat, c("x", "y", "group"),
                          label_args = list(style = "count_percent_wrap"))
  expect_identical(as.character(ggplot2::layer_data(tiles, 2L)$label), c("F", "M"))
  expect_equal(unique(ggplot2::layer_data(tiles, 2L)$size), (14 - 2) / ggplot2::.pt)
})

test_that("bar segments stack in legend order, like the alluvial strata", {
  data <- data.frame(x = rep(c("A", "B"), each = 6),
                     g = factor(rep(c("g1", "g2", "g3"), 4)))
  bar <- dist_test_plot(data, c("x", "g"), type = "bar")
  bars <- ggplot2::layer_data(bar, 1L)
  first <- bars[bars$x == 1, ]
  expect_identical(levels(data$g)[first$group[order(-first$ymax)]],
                   c("g1", "g2", "g3"))
  expect_equal(ggplot2::layer_data(bar, 2L)$y, (bars$ymin + bars$ymax) / 2)
})

test_that("labelled categories show their value labels in every mode", {
  data <- data.frame(x = rep(c("A", "B"), 3))
  data$sex <- labelled::labelled(rep(c(1, 2, 1), 2), c(Male = 1, Female = 2))
  for (type in c("bar", "alluvial")) {
    if (type == "alluvial" && !requireNamespace("ggalluvial", quietly = TRUE)) next
    p <- dist_test_plot(data, c("x", "sex"), type = type,
                        color = c(Female = "red", Male = "blue"))
    fill <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
    expect_equal(as.character(fill$get_breaks()), c("Male", "Female"))
  }
  heat <- data.frame(x = c("A", "B"), y = "C")
  heat$z <- labelled::labelled(c(1, 2), c(Low = 1, High = 2))
  tiles <- dist_test_plot(heat, c("x", "y", "z"))
  expect_identical(as.character(ggplot2::layer_data(tiles, 2L)$label),
                   c("Low", "High"))
})

test_that("bar facets use observed levels and the facet and legend lists", {
  data <- data.frame(
    x = factor(rep(c("A", "B"), 6), levels = c("A", "B", "Unused")),
    group = rep(c("F", "M"), each = 6),
    panel = factor(rep(c("P1", "P2", "P3"), 4),
                   levels = c("P1", "P2", "P3", "U1", "U2", "U3", "U4"))
  )
  p <- dist_test_plot(data, c("x", "group"), type = "bar", facet = "panel")
  layout <- ggplot2::ggplot_build(p)$layout$layout
  expect_identical(c(max(layout$ROW), max(layout$COL)), c(1L, 3L))
  custom <- dist_test_plot(data, c("x", "group"), type = "bar", facet = "panel",
                           facet_args = list(ncol = 1, scales = "free_x"),
                           legend_args = list(position = "bottom", ncol = 2))
  layout <- ggplot2::ggplot_build(custom)$layout$layout
  expect_identical(c(max(layout$ROW), max(layout$COL)), c(3L, 1L))
  expect_true(custom$facet$params$free$x)
  expect_identical(custom$theme$legend.position, "bottom")
  expect_identical(custom$guides$guides$fill$params$ncol, 2)
  skip_if_not_installed("RegR")
  plain <- dist_test_plot(droplevels(data), c("x", "group"), type = "bar",
                          facet = "panel")
  expect_equal(attr(p, "plot_size"), attr(plain, "plot_size"))
})

test_that("alluvial mode forwards the list settings to plt_alluvial", {
  skip_if_not_installed("ggalluvial")
  p <- dist_test_plot(dist_label_data(), c("x", "group"))
  expect_identical(p$data$.label[!is.na(p$data$.label)],
                   c("F (1,499, 99.9%)", "F (1, 33.3%)", "M (1, 0.1%)", "M (2, 66.7%)"))
  expect_equal(unique(ggplot2::layer_data(p, 3L)$size), 3)
  wrap <- dist_test_plot(
    dist_label_data(), c("x", "group"), theme_use = theme_my(base_size = 21),
    label_args = list(style = "count_percent_wrap", min_pct = 0.05, pct_accuracy = 1),
    flow_args = list(curve_type = "sigmoid"),
    stratum_args = list(width = 0.3, gap = 0),
    legend_args = list(position = "bottom")
  )
  expect_identical(wrap$data$.label[!is.na(wrap$data$.label)],
                   c("F\n1,499 (100%)", "F\n1 (33%)", "M\n2 (67%)"))
  expect_equal(unique(ggplot2::layer_data(wrap, 3L)$size), 3 * 21 / 14)
  expect_identical(wrap$layers[[1]]$geom_params$curve_type, "sigmoid")
  strata <- ggplot2::layer_data(wrap, 2L)
  expect_equal(unique(round(strata$xmax - strata$xmin, 6)), 0.3)
  expect_false(any(wrap$data$.is_gap))
  expect_identical(wrap$theme$legend.position, "bottom")
})

test_that("distribution counts ignore unrelated input grouping", {
  data <- data.frame(x = rep(c("A", "B"), each = 4),
                     group = rep(c("F", "M"), 4),
                     batch = rep(c("b1", "b1", "b2", "b2"), 2))
  data$tile <- paste(data$x, data$group)
  for (input in list(dplyr::group_by(data, batch), dplyr::rowwise(data))) {
    original <- input
    for (variables in list(c("x", "group"), c("x", "group", "tile"))) {
      p <- dist_test_plot(input, variables, type = "bar")
      reference <- dist_test_plot(data, variables, type = "bar")
      expect_equal(as.data.frame(p$data), as.data.frame(reference$data))
      expect_equal(ggplot2::ggplot_build(p)$data,
                   ggplot2::ggplot_build(reference)$data)
    }
    expect_identical(input, original)
  }
})

test_that("bar facets accept literal non-syntactic column names", {
  data <- data.frame(x = c("A", "A", "B", "B"),
                     group = c("F", "M", "F", "M"),
                     panel = c("P1", "P1", "P2", "P2"))
  reference <- ggplot2::ggplot_build(
    dist_test_plot(data, c("x", "group"), type = "bar", facet = "panel")
  )$data
  for (name in c("panel group", "panel+group", "panel`group")) {
    renamed <- data
    names(renamed)[3L] <- name
    p <- dist_test_plot(renamed, c("x", "group"), type = "bar", facet = name)
    expect_equal(ggplot2::ggplot_build(p)$data, reference)
    expect_identical(as.character(p$data[[name]]), data$panel)
  }
})

test_that("heatmaps reject cells containing more than one fill category", {
  conflicting <- data.frame(x = "A", y = "B", group = c("F", rep("M", 9)))
  for (label in c("count_percent", "none")) {
    expect_error(plt_dist(conflicting, c("x", "y", "group"),
                          label_args = list(style = label)),
                 "more than one.*category")
  }
  valid <- data.frame(x = c("A", "A", "B"), y = "C", group = c("F", "F", "M"))
  p <- dist_test_plot(valid, c("x", "y", "group"))
  expect_equal(p$data$n, c(2L, 1L))
  tiles <- ggplot2::ggplot_build(p)$data[[1L]]
  expect_equal(nrow(unique(tiles[c("x", "y")])), nrow(tiles))
})

test_that("distribution palettes keep category names and unused-level positions", {
  data <- data.frame(x = c("A", "B"), y = "C", group = c("F", "M"))
  for (mode in c("bar", "alluvial", "heatmap")) {
    if (mode == "alluvial" && !requireNamespace("ggalluvial", quietly = TRUE)) next
    variables <- if (mode == "heatmap") c("x", "y", "group") else c("x", "group")
    type <- if (mode == "alluvial") "alluvial" else "bar"
    p <- dist_test_plot(data, variables, type = type, color = c(M = "red", F = "blue"))
    built <- ggplot2::ggplot_build(p)
    mapped <- built$plot$scales$get_scales("fill")$map(c("F", "M"))
    expect_equal(unname(grDevices::col2rgb(mapped)),
                 unname(grDevices::col2rgb(c("blue", "red"))))
    expect_error(plt_dist(data, variables, type = type, color = c(F = "blue")),
                 "every observed fill category")
  }
  data$group <- factor(data$group, levels = c("Unused", "F", "M"))
  p <- dist_test_plot(data, c("x", "group"), type = "bar",
                     color = c("red", "blue", "green"))
  mapped <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")$map(c("F", "M"))
  expect_equal(unname(grDevices::col2rgb(mapped)),
               unname(grDevices::col2rgb(c("blue", "green"))))
})

test_that("unlabelled heatmaps retain a visible category legend", {
  data <- data.frame(x = c("A", "B"), y = "C", group = c("F", "M"))
  for (theme in list(theme_heat(14), ggplot2::theme_bw() +
                     ggplot2::theme(legend.position = "bottom"))) {
    p <- dist_test_plot(data, c("x", "y", "group"), label_args = list(style = "none"),
                        theme_use = theme)
    expected <- if (identical(theme$legend.position, "none")) "right" else "bottom"
    expect_identical(p$theme$legend.position, expected)
    grob <- ggplot2::ggplotGrob(p)
    guides <- grob$grobs[grepl("^guide-box", grob$layout$name)]
    expect_true(any(vapply(guides, inherits, logical(1), what = "gtable")))
  }
  labelled <- dist_test_plot(data, c("x", "y", "group"))
  expect_identical(labelled$theme$legend.position, "none")
})

test_that("distribution selectors and transparency are validated consistently", {
  data <- data.frame(x = c("A", "B"), group = c("F", "M"), panel = c("P1", "P2"))
  for (type in c("bar", "alluvial")) {
    for (variables in list(c("x", "x"), c("x", NA_character_),
                           list("x", "group"), matrix(c("x", "group"), nrow = 1))) {
      expect_error(plt_dist(data, variables, type = type), "dis_vars")
    }
    for (facet in list(c("x", "panel"), NA_character_, 1, "", "absent", "x")) {
      expect_error(plt_dist(data, c("x", "group"), type = type, facet = facet),
                   "facet")
    }
    for (alpha in list(-0.1, 1.1, NA_real_, Inf, numeric(), c(0.2, 0.3), TRUE)) {
      expect_error(plt_dist(data, c("x", "group"), type = type, alpha = alpha),
                   "alpha")
    }
  }
  reference <- dist_test_plot(data, c("x", "panel", "group"))
  ignored <- dist_test_plot(data, c("x", "panel", "group"), type = "ignored")
  expect_equal(ggplot2::ggplot_build(ignored)$data,
               ggplot2::ggplot_build(reference)$data)
})

test_that("all distribution modes use complete required rows and report removals", {
  data <- data.frame(x = c("A", "A", "A", "B"),
                     group = c("F", "M", NA, "M"),
                     panel = c("P1", "P1", "P1", NA), unrelated = NA_real_)
  for (type in c("bar", "alluvial")) {
    if (type == "alluvial" && !requireNamespace("ggalluvial", quietly = TRUE)) next
    expect_message(output <- utils::capture.output(
      p <- plt_dist(data, c("x", "group"), type = type, facet = "panel")
    ), "Removed 2 rows")
    if (type == "bar") {
      expect_equal(p$data$n, c(1L, 1L))
      expect_equal(p$data$prop, c(0.5, 0.5))
    } else {
      expect_equal(sum(p$data$count), 2)
      expect_equal(p$data$percent[!p$data$.is_gap], c(0.5, 0.5))
    }
    expect_error(plt_dist(data[FALSE, ], c("x", "group"), type = type),
                 "No complete rows")
    expect_error(plt_dist(data.frame(x = NA_character_, group = "F"),
                          c("x", "group"), type = type), "No complete rows")
  }
  heat <- data.frame(x = LETTERS[1:4], y = c("Y", "Y", NA, "Y"),
                     group = c("F", "M", "F", NA), unrelated = NA_real_)
  expect_message(output <- utils::capture.output(
    p <- plt_dist(heat, c("x", "y", "group"), facet = "ignored")
  ), "Removed 2 rows")
  expect_equal(nrow(p$data), 2L)
  expect_identical(as.character(p$data$x), c("A", "B"))
})

test_that("numeric distribution categories and facets use numeric order", {
  skip_if_not_installed("ggalluvial")
  expected <- c("1", "2", "10")
  colors <- c("10" = "red", "1" = "blue", "2" = "green")
  for (values in list(c(10L, 2L, 1L), c(10, 2, 1))) {
    data <- expand.grid(x = values, group = values, panel = values)
    data$unrelated <- seq_len(nrow(data))
    original <- data
    for (type in c("bar", "alluvial")) {
      p <- dist_test_plot(data, c("x", "group"), type = type,
                          facet = "panel", color = colors)
      built <- ggplot2::ggplot_build(p)
      expect_identical(built$layout$panel_params[[1]]$x$get_labels(), expected)
      fill <- built$plot$scales$get_scales("fill")
      expect_equal(as.character(fill$get_breaks()), expected)
      expect_equal(unname(grDevices::col2rgb(fill$map(expected))),
                   unname(grDevices::col2rgb(colors[expected])))
      facet_column <- if (type == "bar") "panel" else ".facet"
      expect_identical(as.character(built$layout$layout[[facet_column]]), expected)
      expect_identical(data, original)
    }
    heat <- expand.grid(x = values, y = values)
    heat$group <- rep(values, 3)
    built <- ggplot2::ggplot_build(
      dist_test_plot(heat, c("x", "y", "group"), color = colors)
    )
    expect_identical(built$layout$panel_params[[1]]$x$get_labels(), expected)
    expect_identical(built$layout$panel_params[[1]]$y$get_labels(), rev(expected))
    expect_equal(as.character(built$plot$scales$get_scales("fill")$get_breaks()),
                 expected)
  }
})

test_that("distribution normalization preserves factors and character order", {
  skip_if_not_installed("ggalluvial")
  values <- c("10", "2", "1")
  for (factor_input in c(FALSE, TRUE)) {
    data <- expand.grid(x = values, group = values, panel = values,
                        stringsAsFactors = FALSE)
    if (factor_input) {
      data[] <- lapply(data, ordered, levels = c("2", "10", "1", "unused"))
    }
    original <- data
    for (type in c("bar", "alluvial")) {
      p <- dist_test_plot(data, c("x", "group"), type = type, facet = "panel")
      built <- ggplot2::ggplot_build(p)
      expected <- if (factor_input) c("2", "10", "1") else
        if (type == "bar") sort(values) else values
      expect_identical(built$layout$panel_params[[1]]$x$get_labels(), expected)
      expect_equal(as.character(built$plot$scales$get_scales("fill")$get_breaks()),
                   expected)
      expect_identical(data, original)
    }
  }
})

test_that("numeric distribution normalization keeps missing-value rules", {
  skip_if_not_installed("ggalluvial")
  data <- data.frame(x = c(10, 2, 1, NA, 2, 1),
                     group = c(2, 1, 2, 1, NaN, 2),
                     panel = c(10, 2, 1, 1, 2, NA), unrelated = NA_real_)
  for (type in c("bar", "alluvial")) {
    expect_message(output <- utils::capture.output(
      p <- plt_dist(data, c("x", "group"), type = type, facet = "panel")
    ), "Removed 3 rows")
    count <- if (type == "bar") p$data$n else p$data$count[!p$data$.is_gap]
    expect_equal(sum(count), 3)
    columns <- if (type == "bar") c("x", "group", "panel") else
      c(".cat_var", ".group", ".facet")
    expect_false(anyNA(p$data[columns]))
  }
})
