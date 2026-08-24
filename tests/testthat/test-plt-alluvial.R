alluvial_data <- function() {
  data.frame(
    category = c("B", "B", "A", "A", "B", "A", "A", "A"),
    group = c("G2", "G2", "G1", "G2", "G1", "G2", "G2", "G1"),
    panel = c("P1", "P1", "P1", "P1", "P2", "P2", "P2", "P2")
  )
}

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
      "theme_use",
      "save"
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
  expect_equal(nrow(plot$layers[[3]]$data), sum(real$count > 0))
  expect_setequal(as.character(plot$layers[[3]]$data$.facet), c("P1", "P2"))
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
  labels <- plot$layers[[3]]$data

  expect_setequal(
    unique(labels$.cat_var_chr[labels$.facet_chr == "P2"]),
    "A"
  )
})

test_that("plt_alluvial exposes the requested label styles", {
  skip_if_not_installed("ggalluvial")

  styles <- c("count_percent", "count", "percent", "name", "none")
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
  expect_equal(single_colors[single_colors != "transparent"], rep("red", 2))

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
  expect_snapshot(
    plot <- plt_alluvial(
      data,
      "category",
      "group",
      label_args = list(style = "none")
    )
  )
  expect_equal(sum(plot$data$count[!plot$data$.is_gap]), 7)
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
    label = "percent",
    gap = 0.02,
    curve_type = "cubic"
  )

  expect_equal(adapted$data, direct$data)
  expect_equal(
    length(unique(ggplot2::ggplot_build(adapted)$layout$layout$PANEL)),
    2L
  )
})
