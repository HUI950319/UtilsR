alluvial_data <- function() {
  data.frame(
    category = c("B", "B", "A", "A", "B", "A", "A", "A"),
    group = c("G2", "G2", "G1", "G2", "G1", "G2", "G2", "G1"),
    panel = c("P1", "P1", "P1", "P1", "P2", "P2", "P2", "P2")
  )
}

test_that("alluvial style selectors reject scalar arrays before theme resolution", {
  skip_if_not_installed("ggalluvial")
  settings <- list(flow_args = list(curve_type = "linear"),
    stratum_args = list(color = "red"), label_args = list(style = "name", color = "black", fill = "white", box = TRUE),
    facet_args = list(scales = "fixed"), legend_args = list(position = "right"))
  for (arg in names(settings)) for (field in names(settings[[arg]])) {
    args <- list(data = alluvial_data(), cat_var = "category", group = "group", theme_use = quote(stop("theme evaluated")))
    args[[arg]] <- stats::setNames(list(matrix(settings[[arg]][[field]])), field)
    expect_error(do.call("plt_alluvial", args), arg)
  }
})

test_that("alluvial column selectors reject dimensions and ambiguous input names", {
  skip_if_not_installed("ggalluvial")
  d <- alluvial_data()
  for (arg in c("cat_var", "group", "facet")) {
    value <- c(cat_var = "category", group = "group", facet = "panel")[[arg]]
    args <- list(data = d, cat_var = "category", group = "group", theme_use = quote(stop("theme evaluated")))
    args[[arg]] <- matrix(value)
    expect_error(do.call("plt_alluvial", args), arg)
  }
  d[["duplicate"]] <- d[["group"]]
  names(d)[4] <- "group"
  expect_error(plt_alluvial(d, "category", "group"), "unique.*column names")
})

test_that("alluvial controls reject encoded and dimensional numeric settings", {
  skip_if_not_installed("ggalluvial")
  d <- data.frame(x = c("a", "b"), y = c("c", "d"))
  settings <- list(flow_args = list(alpha = 0.5),
    stratum_args = list(width = 0.5, linewidth = 0.3, gap = 0.01),
    label_args = list(min_pct = 0.1, size = 3, alpha = 1, pct_accuracy = 0.1),
    facet_args = list(nrow = 1, ncol = 1), legend_args = list(ncol = 1))
  for (arg in names(settings)) for (field in names(settings[[arg]]))
    for (shape in c("matrix", "encoded")) {
      value <- settings[[arg]][[field]]
      bad <- if (shape == "matrix") matrix(value) else structure(value, class = "encoded_number")
      args <- list(data = d, cat_var = "x", group = "y", theme_use = quote(stop("theme evaluated")))
      args[[arg]] <- stats::setNames(list(bad), field)
      expect_error(do.call("plt_alluvial", args), arg)
    }
})

test_that("plt_alluvial keeps the documented public argument order", {
  expect_identical(
    names(formals(plt_alluvial)),
    c(
      "data",
      "cat_var",
      "group",
      "facet",
      "y_type",
      "color",
      "flow_args",
      "stratum_args",
      "label_args",
      "facet_args",
      "legend_args",
      "fmt_text",
      "theme_use",
      "save"
    )
  )
})

test_that("plt_alluvial advertises semantic list defaults", {
  defaults <- lapply(
    c(
      "flow_args",
      "stratum_args",
      "label_args",
      "facet_args",
      "legend_args"
    ),
    \(argument) eval(formals(plt_alluvial)[[argument]])
  )

  expect_identical(
    defaults,
    list(
      list(alpha = 0.4, curve_type = "linear"),
      list(width = 0.5, color = "gray50", linewidth = 0.3, gap = 0.01),
      list(
        style = "count_percent",
        min_pct = 0,
        size = 3,
        color = "black",
        box = TRUE,
        fill = "white",
        alpha = 1,
        pct_accuracy = 0.1
      ),
      list(nrow = NULL, ncol = NULL, scales = "fixed"),
      list(ncol = 1, position = "right")
    )
  )
})

test_that("plt_alluvial returns a facet-aware ggplot", {
  skip_if_not_installed("ggalluvial")

  plot <- plt_alluvial(
    alluvial_data(),
    cat_var = "category",
    group = "group",
    facet = "panel"
  )

  expect_s3_class(plot, "ggplot")
  expect_equal(
    length(unique(ggplot2::ggplot_build(plot)$layout$layout$PANEL)),
    2L
  )

  real <- plot$data[!plot$data$.is_gap, ]
  totals <- stats::aggregate(
    real$percent,
    by = list(real$.facet, real$.cat_var),
    FUN = sum
  )
  expect_equal(totals$x, rep(1, nrow(totals)))
  built <- ggplot2::ggplot_build(plot)
  expect_equal(sum(!is.na(built$data[[3]]$label)), sum(real$count > 0))
  expect_setequal(as.character(built$layout$layout$.facet), c("P1", "P2"))
})

test_that("plt_alluvial supports count mode and preserves input order", {
  skip_if_not_installed("ggalluvial")

  data <- alluvial_data()
  data$group <- factor(data$group, levels = c("G1", "G2"))
  plot <- plt_alluvial(
    data,
    "category",
    "group",
    facet = "panel",
    y_type = "count"
  )
  real <- plot$data[!plot$data$.is_gap, ]

  expect_equal(levels(plot$data$.cat_var), c("B", "A"))
  expect_equal(unique(as.character(real$.group)), c("G1", "G2"))
  expect_equal(real$.y, real$count)
  expect_true(any(real$count == 0))
})

test_that("plt_alluvial distinguishes real group names from gap strata", {
  skip_if_not_installed("ggalluvial")

  for (gap in c(0, 0.01)) {
    data <- alluvial_data()
    data$group <- ifelse(data$group == "G1", ".gap_1", ".gap_clinical")
    plot <- plt_alluvial(data, "category", "group", stratum_args = list(gap = gap))
    real <- plot$data[!plot$data$.is_gap, ]
    expect_equal(sum(real$count), nrow(data))
    expect_setequal(
      stats::na.omit(as.character(unlist(lapply(
        ggplot2::ggplot_build(plot)$data, `[[`, "label"
      )))),
      real$.label[!is.na(real$.label)]
    )
    expect_length(intersect(
      as.character(plot$data$.group[plot$data$.is_gap]), data$group
    ), 0L)
  }
})

test_that("plt_alluvial inserts facet-specific gap space", {
  skip_if_not_installed("ggalluvial")

  percent <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    facet = "panel",
    stratum_args = list(gap = 0.05),
    label_args = list(style = "none")
  )
  percent_totals <- stats::aggregate(
    percent$data$.y,
    by = list(percent$data$.facet, percent$data$.cat_var),
    FUN = sum
  )
  expect_equal(percent_totals$x, rep(1, nrow(percent_totals)))
  expect_equal(unique(percent$data$.y[percent$data$.is_gap]), 0.05)

  count <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    facet = "panel",
    y_type = "count",
    stratum_args = list(gap = 0.1),
    label_args = list(style = "none")
  )
  expected_gap <- c(P1 = 0.2, P2 = 0.3)
  gap_rows <- count$data[count$data$.is_gap, ]
  expect_equal(
    unname(gap_rows$.y),
    unname(expected_gap[as.character(gap_rows$.facet)])
  )
})

test_that("plt_alluvial maps labels correctly with free x scales", {
  skip_if_not_installed("ggalluvial")

  data <- data.frame(
    category = c("B", "B", "A", "A", "A"),
    group = c("G1", "G2", "G1", "G1", "G2"),
    panel = c("P1", "P1", "P1", "P2", "P2")
  )
  plot <- plt_alluvial(
    data,
    "category",
    "group",
    facet = "panel",
    facet_args = list(scales = "free_x"),
    stratum_args = list(gap = 0)
  )
  built <- ggplot2::ggplot_build(plot)
  labels <- built$data[[3]]
  panel <- built$layout$layout$PANEL[built$layout$layout$.facet == "P2"]
  expect_setequal(
    labels$label[labels$PANEL == panel & !is.na(labels$label)],
    plot$data$.label[plot$data$.facet == "P2" & !is.na(plot$data$.label)]
  )
})

test_that("plt_alluvial labels follow final axis positions and stratum centers", {
  skip_if_not_installed("ggalluvial")

  data <- data.frame(
    category = rep(c("A", "B"), each = 4),
    group = c("F", "F", "F", "M", "F", "M", "M", "M")
  )
  for (box in c(TRUE, FALSE)) for (gap in c(0, 0.01)) {
    plot <- plt_alluvial(
      data, "category", "group", stratum_args = list(gap = gap),
      label_args = list(box = box)
    )
    real <- plot$data[!plot$data$.is_gap, ]
    built <- ggplot2::ggplot_build(plot + ggplot2::scale_x_discrete(limits = rev))
    labels <- built$data[[3]]
    labels <- labels[!is.na(labels$label), ]
    source <- real[match(labels$label, real$.label), ]
    expected_x <- match(as.character(source$.cat_var), c("B", "A"))
    expect_equal(as.numeric(labels$x), expected_x)
    strata <- built$data[[2]]
    index <- match(
      paste(expected_x, source$.group), paste(strata$x, strata$stratum)
    )
    expect_equal(labels$y, (strata$ymin[index] + strata$ymax[index]) / 2)
    expect_no_warning(ggplot2::ggplotGrob(plot))
  }
})

test_that("plt_alluvial exposes the requested label styles", {
  skip_if_not_installed("ggalluvial")

  styles <- c("count_percent", "count", "percent", "name", "none",
              "count_percent_wrap")
  plots <- lapply(styles, function(style) {
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      stratum_args = list(gap = 0),
      label_args = list(style = style)
    )
  })

  expect_match(plots[[1]]$data$.label[1], "G2.*2.*66\\.7%")
  expect_match(plots[[2]]$data$.label[1], "G2.*2")
  expect_match(plots[[3]]$data$.label[1], "66\\.7%")
  expect_identical(plots[[4]]$data$.label[1], "G2")
  expect_true(all(is.na(plots[[5]]$data$.label)))
  expect_identical(plots[[6]]$data$.label[1], "G2\n2 (66.7%)")
  expect_true("G2\n2 (66.7%)" %in% ggplot2::layer_data(plots[[6]], 3L)$label)
  rounded <- plt_alluvial(alluvial_data(), "category", "group",
                          label_args = list(pct_accuracy = 1))
  expect_identical(rounded$data$.label[1], "G2 (2, 67%)")
  expect_error(plt_alluvial(alluvial_data(), "category", "group",
                            label_args = list(pct_accuracy = -1)), "pct_accuracy")
})

test_that("plt_alluvial applies list overrides and colour resolution", {
  skip_if_not_installed("ggalluvial")

  plot <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    color = c("#112233", "#445566"),
    flow_args = list(alpha = 0.2, curve_type = "sigmoid"),
    stratum_args = list(width = 0.3, color = "red", linewidth = 0.8, gap = 0),
    label_args = list(
      min_pct = 0.1,
      size = 4,
      color = "blue",
      box = FALSE,
      fill = "yellow",
      alpha = 0.5
    ),
    facet = "panel",
    facet_args = list(nrow = 1, scales = "free_y"),
    legend_args = list(ncol = 2, position = "bottom")
  )

  scale <- plot$scales$get_scales("fill")
  expect_equal(unname(scale$palette(2)), c("#112233", "#445566"))
  expect_identical(plot$theme$legend.position, "bottom")
  expect_identical(plot$guides$guides$fill$params$ncol, 2L)
  expect_equal(plot$facet$params$nrow, 1)
  expect_true(plot$facet$params$free$y)
  expect_identical(plot$layers[[1]]$aes_params$alpha, 0.2)
  expect_identical(plot$layers[[1]]$geom_params$curve_type, "sigmoid")
  expect_identical(plot$layers[[1]]$geom_params$width, 0.3)
  expect_identical(plot$layers[[2]]$aes_params$colour, "red")
  expect_identical(plot$layers[[2]]$aes_params$linewidth, 0.8)
  expect_s3_class(plot$layers[[3]]$geom, "GeomText")
  expect_identical(plot$layers[[3]]$aes_params$size, 4)
  expect_identical(plot$layers[[3]]$aes_params$colour, "blue")
  expect_identical(plot$layers[[3]]$aes_params$alpha, 0.5)

  single <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    color = "red",
    label_args = list(style = "none")
  )
  single_colors <- unname(single$scales$get_scales("fill")$palette(2))
  expect_equal(
    grDevices::col2rgb(single_colors[single_colors != "transparent"]),
    grDevices::col2rgb(rep("red", 2))
  )

  registered <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    color = "lancet",
    label_args = list(style = "none")
  )
  registered_colors <- registered$scales$get_scales("fill")$palette(2)
  expect_length(registered_colors[registered_colors != "transparent"], 2L)
})

test_that("plt_alluvial removes incomplete required rows", {
  skip_if_not_installed("ggalluvial")

  data <- alluvial_data()
  data$group[1] <- NA
  expect_message(
    capture.output(plot <- plt_alluvial(
      data, "category", "group", label_args = list(style = "none")
    )),
    "Removed 1 row with missing values in required columns.",
    fixed = TRUE
  )
  expect_equal(sum(plot$data$count[!plot$data$.is_gap]), 7)
})

test_that("plt_alluvial rejects matrix columns before counting rows", {
  skip_if_not_installed("ggalluvial")

  for (as_input in list(identity, tibble::as_tibble)) {
    for (column in c("category", "group", "panel")) {
      data <- alluvial_data()
      data[[column]] <- I(matrix(rep(c("A", "B"), 8), nrow = 8))
      result <- tryCatch(
        plt_alluvial(as_input(data), "category", "group", facet = "panel"),
        error = identity
      )
      expect_s3_class(result, "rlang_error")
      if (inherits(result, "error")) {
        expect_match(conditionMessage(result), "one-dimensional column")
      }
    }
  }
})

test_that("plt_alluvial rejects other dimensional columns", {
  skip_if_not_installed("ggalluvial")

  values <- list(
    matrix("A", nrow = 8, ncol = 1),
    matrix(character(), nrow = 8, ncol = 0),
    array("A", dim = c(8, 1, 2)),
    data.frame(value = rep("A", 8))
  )
  for (value in values) {
    data <- alluvial_data()
    data$category <- value
    result <- tryCatch(
      plt_alluvial(data, "category", "group"), error = identity
    )
    expect_s3_class(result, "rlang_error")
    if (inherits(result, "error")) {
      expect_match(conditionMessage(result), "one-dimensional column")
    }
  }
})

test_that("plt_alluvial keeps adjacent numeric values in separate categories", {
  skip_if_not_installed("ggalluvial")

  values <- c(1, 1 + .Machine$double.eps)
  columns <- c(category = ".cat_var", group = ".group", panel = ".facet")
  for (column in names(columns)) {
    data <- alluvial_data()
    index <- match(data[[column]], unique(data[[column]]))
    data[[column]] <- values[index]
    plot <- plt_alluvial(
      data, "category", "group", facet = "panel",
      stratum_args = list(gap = 0)
    )
    field <- columns[[column]]
    expect_equal(as.numeric(levels(plot$data[[field]])), values, tolerance = 0)
    totals <- tapply(plot$data$count, plot$data[[field]], sum)
    expect_equal(as.numeric(totals), tabulate(index, nbins = 2))
  }
})

test_that("plt_alluvial preserves distinct typed values with colliding labels", {
  skip_if_not_installed("ggalluvial")

  close <- c(1, 1 + .Machine$double.eps)
  values <- list(
    complex = complex(real = 1, imaginary = close),
    date = as.Date(close, origin = "1970-01-01"),
    time = as.POSIXct(c(0, 1e-9), origin = "1970-01-01", tz = "UTC"),
    duration = as.difftime(close, units = "secs")
  )
  for (value in values) {
    data <- alluvial_data()
    data$group <- value[c(1, 1, 2, 1, 2, 1, 1, 2)]
    plot <- plt_alluvial(data, "category", "group")
    real <- plot$data[!plot$data$.is_gap, ]
    expect_length(levels(droplevels(real$.group)), 2)
    expect_equal(
      as.numeric(tapply(real$count, droplevels(real$.group), sum)), c(5, 3)
    )
    built <- ggplot2::ggplot_build(plot)
    expect_setequal(
      built$data[[3]]$label[!is.na(built$data[[3]]$label)],
      real$.label[!is.na(real$.label)]
    )
  }
})

test_that("plt_alluvial removes labelled missing values before resolving precision", {
  skip_if_not_installed("ggalluvial")
  skip_if_not_installed("haven")

  data <- alluvial_data()
  data$group <- haven::labelled_spss(
    c(1, 1 + .Machine$double.eps, 99, NA, 1 + .Machine$double.eps, 1, 99, NaN),
    na_values = 99
  )
  expect_message(capture.output(plot <- plt_alluvial(
    data, "category", "group"
  )), "Removed 4 rows")
  real <- plot$data[!plot$data$.is_gap, ]
  expect_equal(
    as.numeric(levels(droplevels(real$.group))),
    c(1, 1 + .Machine$double.eps), tolerance = 0
  )
  expect_equal(as.numeric(tapply(real$count, droplevels(real$.group), sum)), c(2, 2))
})

test_that("plt_alluvial preserves integer64 and explicit factor labels", {
  skip_if_not_installed("ggalluvial")

  data <- alluvial_data()
  labels <- c("1.0000000000000002", "1")
  data$group <- factor(
    data$group, levels = c("G1", "G2", "unused"),
    labels = c(labels, "unused"), ordered = TRUE
  )
  plot <- plt_alluvial(data, "category", "group")
  real <- plot$data[!plot$data$.is_gap, ]
  expect_identical(levels(droplevels(real$.group)), labels)
  expect_equal(as.numeric(tapply(real$count, droplevels(real$.group), sum)), c(3, 5))

  skip_if_not_installed("bit64")
  labels <- c("9007199254740992", "9007199254740993")
  data$group <- bit64::as.integer64(labels)[c(1, 1, 2, 1, 2, 1, 1, 2)]
  plot <- plt_alluvial(data, "category", "group")
  real <- plot$data[!plot$data$.is_gap, ]
  expect_identical(levels(droplevels(real$.group)), labels)
  expect_equal(as.numeric(tapply(real$count, droplevels(real$.group), sum)), c(5, 3))
})

test_that("plt_alluvial renders precise group labels with named colours", {
  skip_if_not_installed("ggalluvial")

  data <- alluvial_data()
  values <- c(1, 1 + .Machine$double.eps)
  data$group <- values[match(data$group, unique(data$group))]
  colors <- stats::setNames(c("#112233", "#445566"), format(values, digits = 17))
  plot <- plt_alluvial(data, "category", "group", facet = "panel", color = colors) +
    ggplot2::scale_x_discrete(limits = rev)
  built <- ggplot2::ggplot_build(plot)
  scale <- built$plot$scales$get_scales("fill")
  expect_identical(as.character(scale$get_breaks()), names(colors))
  expect_identical(unname(scale$map(names(colors))), unname(colors))
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("plt_alluvial matches named colours to observed groups", {
  skip_if_not_installed("ggalluvial")

  colors <- c(G1 = "blue", unused = "green", G2 = "red")
  plot <- plt_alluvial(alluvial_data(), "category", "group", color = colors)
  scale <- ggplot2::ggplot_build(plot)$plot$scales$get_scales("fill")
  expect_equal(
    grDevices::col2rgb(scale$map(c("G1", "G2"))),
    grDevices::col2rgb(unname(colors[c("G1", "G2")]))
  )
  expect_error(
    plt_alluvial(alluvial_data(), "category", "group", color = c(G1 = "blue")),
    "cover every observed group"
  )
  expect_error(
    plt_alluvial(alluvial_data(), "category", "group",
                 color = c(G1 = "blue", G1 = "red")),
    "unique, non-empty"
  )
})

test_that("plt_alluvial reports explicit NA levels and user-defined missing values", {
  skip_if_not_installed("ggalluvial")

  for (column in c("category", "group", "panel")) {
    data <- alluvial_data()
    data[[column]][1] <- NA
    data[[column]] <- factor(data[[column]], exclude = NULL)
    expect_message(capture.output(plot <- plt_alluvial(
      data, "category", "group", facet = "panel"
    )), "Removed 1 row")
    expect_equal(sum(plot$data$count), 7)
  }

  skip_if_not_installed("haven")
  data <- alluvial_data()
  data$group <- haven::labelled_spss(
    c(1, 2, 99, 1, 2, 97, 98, NA), na_values = 99, na_range = c(97, 98)
  )
  expect_message(capture.output(plot <- plt_alluvial(
    data, "category", "group", label_args = list(style = "none")
  )), "Removed 4 rows")
  expect_equal(sum(plot$data$count), 4)
  expect_setequal(as.character(plot$data$.group[!plot$data$.is_gap]), c("1", "2"))
})

test_that("plt_dist removes alluvial missing categories before matching named colours", {
  skip_if_not_installed("ggalluvial")

  data <- alluvial_data()
  data$group[1] <- NA
  data$group <- factor(data$group, exclude = NULL)
  expect_message(capture.output(plot <- plt_dist(
    data, c("category", "group"), color = c(G1 = "blue", G2 = "red")
  )), "Removed 1 row")
  expect_equal(sum(plot$data$count), 7)
})

test_that("plt_alluvial rejects invalid columns and overlapping roles", {
  skip_if_not_installed("ggalluvial")

  expect_snapshot(
    error = TRUE,
    plt_alluvial(alluvial_data(), "missing", "group")
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(alluvial_data(), "category", "category")
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(matrix(1:4, ncol = 2), "category", "group")
  )
})

test_that("plt_alluvial validates semantic list arguments", {
  skip_if_not_installed("ggalluvial")

  duplicate_alpha <- structure(
    list(0.2, 0.3),
    names = c("alpha", "alpha")
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      flow_args = list(foo = 1)
    )
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      flow_args = list(0.2)
    )
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      flow_args = duplicate_alpha
    )
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      flow_args = list(alpha = 2)
    )
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      stratum_args = list(width = 0)
    )
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      transform(alluvial_data(), group3 = rep(c("G1", "G2", "G3", "G1"), 2)),
      "category",
      "group3",
      stratum_args = list(gap = 0.5)
    )
  )
  expect_snapshot(
    error = TRUE,
    plt_alluvial(
      alluvial_data(),
      "category",
      "group",
      label_args = list(alpha = 2)
    )
  )
})

test_that("plt_alluvial keeps save optional and preserves its return", {
  skip_if_not_installed("ggalluvial")

  plain <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    label_args = list(style = "none")
  )
  expect_s3_class(plain, "ggplot")

  skip_if_not_installed("RegR")
  output <- tempfile(fileext = ".pdf")
  on.exit(unlink(output), add = TRUE)
  saved <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    label_args = list(style = "none"),
    save = list(filename = output, width = 4, height = 3)
  )

  expect_true(file.exists(output))
  expect_s3_class(saved, "ggplot")
  expect_equal(saved$data, plain$data)
})

test_that("plt_alluvial does not retain unused input columns in serialized plots", {
  skip_if_not_installed("ggalluvial")

  make_plot <- function(payload) {
    data <- alluvial_data()
    if (payload) data$unused <- I(matrix(rep(as.double(1:8), 10000), nrow = 8))
    capture.output(plot <- plt_alluvial(data, "category", "group"))
    serialize(plot, NULL)
  }
  plain <- make_plot(FALSE)
  wide <- make_plot(TRUE)
  expect_lt(length(wide) - length(plain), 100000)
  plot <- unserialize(wide)
  expect_equal(sum(plot$data$count), 8)
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("plt_alluvial rejects layout integers outside the supported range", {
  skip_if_not_installed("ggalluvial")

  for (value in c(2^31, 1e50)) {
    for (field in c("nrow", "ncol")) {
      expect_error(plt_alluvial(
        alluvial_data(), "category", "group",
        facet_args = stats::setNames(list(value), field)
      ), "positive integer")
    }
    expect_error(plt_alluvial(
      alluvial_data(), "category", "group", legend_args = list(ncol = value)
    ), "positive integer")
  }
})

test_that("plt_dist alluvial mode delegates to plt_alluvial with facets", {
  skip_if_not_installed("ggalluvial")

  direct <- plt_alluvial(
    alluvial_data(),
    "category",
    "group",
    facet = "panel",
    color = c("#112233", "#445566"),
    flow_args = list(alpha = 0.6, curve_type = "cubic"),
    stratum_args = list(gap = 0.02),
    label_args = list(style = "percent"),
    theme_use = theme_alluvia(14)
  )
  adapted <- plt_dist(
    alluvial_data(),
    dis_vars = c("category", "group"),
    type = "alluvial",
    facet = "panel",
    color = c("#112233", "#445566"),
    alpha = 0.6,
    label_args = list(style = "percent"),
    flow_args = list(curve_type = "cubic"),
    stratum_args = list(gap = 0.02)
  )

  expect_equal(adapted$data, direct$data)
  expect_equal(
    length(unique(ggplot2::ggplot_build(adapted)$layout$layout$PANEL)),
    2L
  )
})

test_that("plt_alluvial and plt_dist save at the page their content is laid out for", {
  skip_if_not_installed("ggalluvial")
  skip_if_not_installed("RegR")
  capture_save_output <- function(expr) {
    printed <- capture.output(messages <- cli::cli_fmt(force(expr)))
    c(printed, messages)
  }
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_dist)), 1), "save")
  f <- withr::local_tempfile(fileext = ".pdf")
  out <- capture_save_output(p <- plt_alluvial(
    alluvial_data(), "category", "group", save = list(filename = f)
  ))
  expect_saved_at_plot_size(out, p)
  out <- capture_save_output(p <- plt_dist(
    alluvial_data(), dis_vars = c("category", "group"), save = list(filename = f)
  ))
  expect_saved_at_plot_size(out, p)
  out <- capture_save_output(p <- plt_dist(
    alluvial_data(), dis_vars = c("category", "group"),
    type = "bar", save = list(filename = f)
  ))
  expect_saved_at_plot_size(out, p)
  heat_data <- transform(alluvial_data(), tile = paste(category, group))
  out <- capture_save_output(p <- plt_dist(
    heat_data, dis_vars = c("category", "group", "tile"), save = list(filename = f)
  ))
  expect_saved_at_plot_size(out, p)
})

test_that("plt_alluvial preserves the supplied axis element and keeps default styling", {
  skip_if_not_installed("ggtext")
  skip_if_not_installed("ggalluvial")
  data <- data.frame(x = rep(c("A", "B"), 4), y = rep(c("C", "D"), each = 4))
  thm <- ggplot2::theme(axis.text = ggtext::element_markdown(size = 16, colour = "red"))
  p <- suppressMessages(plt_alluvial(data, "x", "y", theme_use = thm))
  expect_s3_class(ggplot2::ggplotGrob(p), "gtable")
  expect_s3_class(p$theme$axis.text, "element_markdown")
  expect_identical(p$theme$axis.text$colour, "red")
  expect_s3_class(p$theme$axis.title, "element_blank")
  default <- suppressMessages(plt_alluvial(data, "x", "y"))
  expect_identical(default$theme$axis.text$colour, "black")
})

test_that("plt_alluvial draws legacy plot backgrounds", {
  skip_if_not_installed("ggalluvial")
  rect <- structure(list(fill = "gold", colour = "blue", linewidth = 2,
                         linetype = 3, inherit.blank = FALSE),
                    class = c("element_rect", "element"))
  legacy <- structure(list(plot.background = rect), class = c("theme", "gg"),
                      complete = FALSE, validate = TRUE)
  for (thm in list(legacy, suppressWarnings((ggplot2::theme() + legacy)))) {
    plot <- suppressWarnings(plt_alluvial(alluvial_data(), cat_var = "category",
                                          group = "group", theme_use = thm))
    g <- suppressWarnings(ggplot2::ggplotGrob(plot))
    i <- which(g$layout$name == "background")
    expect_length(i, 1L)
    if (length(i)) {
      expect_identical(g$grobs[[i]]$gp$fill, "gold")
      expect_identical(g$grobs[[i]]$gp$col, "blue")
      expect_equal(g$grobs[[i]]$gp$lwd, 2 * 72.27 / 25.4)
      expect_equal(g$grobs[[i]]$gp$lty, 3)
    }
  }
})

test_that("alluvial option merging rejects table and array containers", {
  d <- data.frame(cat = c("A", "B"), group = c("X", "Y"))
  for (bad in list(data.frame(alpha = .5),
                   structure(list(.5), dim = c(1L, 1L), names = "alpha")))
    expect_error(plt_alluvial(d, cat_var = "cat", group = "group", flow_args = bad), "flow_args")
  expect_identical(UtilsR:::.merge_args(list(alpha = .5), list(alpha = 1), "flow_args"), list(alpha = .5))
})

test_that("flow plots retain integer64 categories in cold processes", {
  skip_if_not_installed("bit64")
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "input.rds")
  script <- file.path(directory, "verify.R")
  d <- data.frame(cat = rep(c("u", "v"), 2L))
  d$g <- bit64::as.integer64(rep(c("-1", "-2"), each = 2L))
  saveRDS(list(data = d, functions = list(plt_alluvial = plt_alluvial, plt_sankey = plt_sankey, .butterfly_category_labels = .butterfly_category_labels)), fixture)
  for (mode in c("alluvial", "sankey")) {
    writeLines(c("options(device = function(...) grDevices::pdf(NULL, ...), lifecycle_verbosity = 'quiet')",
      sprintf("payload <- readRDS(%s)", deparse(fixture)),
      "stopifnot(!('bit64' %in% loadedNamespaces()))",
      "e <- new.env(parent = asNamespace('UtilsR')); for (name in names(payload$functions)) {fn <- payload$functions[[name]]; environment(fn) <- e; e[[name]] <- fn}",
      if (mode == "alluvial") "p <- suppressMessages(e$plt_alluvial(payload$data, 'cat', 'g')); counts <- tapply(p$data$count, p$data$.group, sum); stopifnot(all(counts[c('-1', '-2')] == 2))" else "p <- withCallingHandlers(suppressMessages(e$plt_sankey(payload$data, c('g', 'cat'), show_text = 'none')), warning = function(w) {if (identical(conditionMessage(w), 'attributes are not identical across measure variables; they will be dropped')) invokeRestart('muffleWarning') else stop(w)}); nodes <- unique(as.character(p$data$label[as.character(p$data$x) == 'g_label'])); stopifnot(length(nodes) == 2L, any(startsWith(nodes, '-1 ')), any(startsWith(nodes, '-2 ')))",
      "cat('COLD_FLOW_OK\n')"), script)
    output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
    expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
    expect_identical(tail(output, 1L), 'COLD_FLOW_OK')
  }
})

test_that("alluvial missing checks avoid extra text conversions of ordinary columns", {
  d <- data.frame(stage = rep(c(1, 2), 100L), group = rep(c("A", "B"), each = 100L))
  fn <- plt_alluvial
  env <- new.env(parent = environment(fn))
  conversions <- 0L
  env$as.character <- function(x, ...) {
    if (is.double(x) && length(x) == nrow(d)) conversions <<- conversions + 1L
    base::as.character(x, ...)
  }
  environment(fn) <- env
  p <- fn(d, cat_var = "stage", group = "group")
  expect_identical(conversions, 1L)
  expect_equal(sum(p$data$count), nrow(d))
  expect_identical(levels(p$data$.cat_var), c("1", "2"))
})

test_that("alluvial count gaps retain empty facet labels", {
  d <- data.frame(stage = rep(c("a", "b"), each = 4L), group = rep(c("g1", "g2"), 4L),
    facet = rep(c("", "Other"), each = 4L))
  p <- plt_alluvial(d, cat_var = "stage", group = "group", facet = "facet",
    y_type = "count", stratum_args = list(gap = .05))
  gap <- p$data[p$data$.is_gap, , drop = FALSE]
  expect_length(gap$.y, 2L)
  expect_equal(gap$.y, c(.2, .2))
  expect_true("" %in% as.character(gap$.facet))
  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("alluvial labels call only their formatters", {
  skip_if_not_installed("ggalluvial")
  comma <- scales::comma
  percent <- scales::percent
  calls <- character()
  testthat::local_mocked_bindings(
    comma = function(...) {
      calls <<- c(calls, "comma")
      comma(...)
    },
    percent = function(...) {
      calls <<- c(calls, "percent")
      percent(...)
    },
    .package = "scales"
  )

  expected <- list(name = character(), count = "comma", percent = "percent",
                   count_percent = c("comma", "percent"))
  labels <- c(name = "G2", count = "G2 (2)", percent = "G2 66.7%",
              count_percent = "G2 (2, 66.7%)")
  for (style in names(expected)) {
    calls <- character()
    plot <- plt_alluvial(alluvial_data(), "category", "group",
                         stratum_args = list(gap = 0), label_args = list(style = style))
    expect_identical(calls, expected[[style]])
    expect_identical(plot$data$.label[[1L]], labels[[style]])
  }
})

test_that("alluvial stratum counts keep observed pairs and empty groups", {
  skip_if_not_installed("ggalluvial")
  data <- alluvial_data()
  data <- data[!(data$panel == "P2" & data$category == "B"), ]
  data$panel <- ordered(data$panel, levels = c("P2", "P1", "unused"))
  data$category <- ordered(data$category, levels = c("A", "B", "unused"))
  plot_without_split <- plt_alluvial
  environment(plot_without_split) <- list2env(
    list(split = function(...) stop("unexpected panel split")),
    parent = environment(plt_alluvial)
  )

  plot <- plot_without_split(data, "category", "group", facet = "panel",
                             stratum_args = list(gap = 0))
  expect_identical(as.character(plot$data$.facet), rep(c("P2", "P1", "P1"), 2L))
  expect_identical(as.character(plot$data$.cat_var), rep(c("A", "A", "B"), 2L))
  expect_identical(as.character(plot$data$.group), rep(c("G2", "G1"), each = 3L))
  expect_identical(plot$data$count, c(2L, 1L, 2L, 1L, 1L, 0L))
  expect_identical(plot$data$group_total, rep(c(3L, 2L, 2L), 2L))
  expect_false(is.ordered(plot$data$.facet))
  expect_false(is.ordered(plot$data$.cat_var))
})

test_that("alluvial gaps reuse one row for each observed pair", {
  skip_if_not_installed("ggalluvial")
  format <- plt_alluvial
  environment(format) <- list2env(list(unique = function(x, ...) {
    if (is.data.frame(x) && identical(names(x), c(".facet", ".cat_var", "group_total"))) {
      stop("recounted the observed facet pairs")
    }
    base::unique(x, ...)
  }), parent = environment(format))
  args <- list(data = alluvial_data(), cat_var = "category", group = "group",
               facet = "panel", y_type = "count", stratum_args = list(gap = .1))
  p <- suppressMessages(do.call(format, args))
  reference <- suppressMessages(do.call(plt_alluvial, args))
  expect_identical(p$data, reference$data)
  expect_equal(sort(p$data$.y[p$data$.is_gap]), c(.2, .2, .3, .3))
})
