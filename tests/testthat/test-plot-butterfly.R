butterfly_payload_plot <- function(include_payload, fill, type) {
  data <- data.frame(stat = "A", value = seq_len(12), group = rep(c("L", "R"), each = 6),
                     fill = rep(c("A", "B", "B", "C"), each = 3))
  if (include_payload) data$unused <- I(lapply(1:12, function(i) as.raw((seq_len(83334) + i) %% 256)))
  PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group", fill.by = fill, type = type)
}

butterfly_without_text_warning <- function(expr) {
  withCallingHandlers(expr, warning = function(warning) {
    if (startsWith(conditionMessage(warning), "Vectorized input to `element_text()`")) {
      invokeRestart("muffleWarning")
    }
  })
}

test_that("PlotButterfly2 plots release unselected input payloads in both paths", {
  skip_if_not_installed("ggbeeswarm")
  files <- c(withr::local_tempfile(), withr::local_tempfile())
  for (settings in list(list(fill = "fill", type = "box"), list(fill = NULL, type = "box"),
                        list(fill = "fill", type = "beeswarm_quasirandom"))) {
    full <- suppressMessages(butterfly_payload_plot(TRUE, settings$fill, settings$type))
    selected <- suppressMessages(butterfly_payload_plot(FALSE, settings$fill, settings$type))
    for (i in 1:2) {
      expect_identical(ggplot2::ggplot_build(full[[i]])$data, ggplot2::ggplot_build(selected[[i]])$data)
    }
    saveRDS(full, files[1], compress = FALSE)
    saveRDS(selected, files[2], compress = FALSE)
    expect_lt(abs(diff(file.info(files)$size)), 65536)
  }
})

test_that("PlotButterfly2 shares observed shape mappings across beeswarm panels", {
  skip_if_not_installed("ggbeeswarm")
  data <- data.frame(stat = "S", value = seq_len(12) / 10, group = rep(c("L", "R"), each = 6),
                     fill = factor(rep(c("A", "B", "B", "C"), each = 3), levels = c("A", "unused", "B", "C")))
  for (type in c("beeswarm", "beeswarm_quasirandom")) {
    plot <- suppressMessages(PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group",
      fill.by = "fill", type = type, color_by = "logFC"))
    for (i in 1:2) {
      built <- ggplot2::ggplot_build(plot[[i]])
      expect_identical(built$plot$scales$get_scales("shape")$map("B"), 17)
      expect_equal(sum(!is.na(built$data[[1]]$shape)), 6)
    }
  }
})

test_that("PlotButterfly2 diagnoses shape capacity using observed categories", {
  skip_if_not_installed("ggbeeswarm")
  data <- data.frame(stat = "S", value = seq_len(30) / 10, group = rep(c("L", "R"), each = 15),
                     fill = factor(rep(rep(LETTERS[1:5], each = 3), 2)))
  expect_error(PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group",
    fill.by = "fill", type = "beeswarm_quasirandom", color_by = "logFC"), "at most 4 observed")
  data <- data[data$fill != "D", ]
  plot <- suppressMessages(PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group",
    fill.by = "fill", type = "beeswarm_quasirandom", color_by = "logFC"))
  for (i in 1:2) {
    built <- ggplot2::ggplot_build(plot[[i]])
    expect_identical(built$plot$scales$get_scales("shape")$map("E"), 18)
    expect_equal(sum(!is.na(built$data[[1]]$shape)), 12)
  }
})

test_that("PlotButterfly2 keeps category colours consistent across panels", {
  data <- data.frame(stat = "A", value = seq_len(12), group = rep(c("L", "R"), each = 6),
                     fill = rep(c("A", "B", "B", "C"), each = 3))
  original <- data
  for (palette in list(c("red", "green", "blue"), c("red", "green", "blue", "orange"))) {
    plot <- PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group",
                           fill.by = "fill", type = "box", palette = palette)
    for (i in 1:2) {
      scale <- ggplot2::ggplot_build(plot[[i]])$plot$scales$get_scales("fill")
      expect_identical(scale$map("B"), "green")
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly2 shares the gradient range across panels", {
  skip_if_not_installed("ggbeeswarm")
  data <- data.frame(stat = "A", value = c(-1, -.5, 0, .3, .7, 1, -4, -2, 0, 1, 2, 4),
                     group = rep(c("L", "R"), each = 6))
  for (fill in list(NULL, "fill")) {
    data$fill <- rep(c("A", "B"), 6)
    plot <- suppressMessages(PlotButterfly2(data, stat.by = "stat", value.by = "value",
      group.by = "group", fill.by = fill, type = "beeswarm_quasirandom", color_by = "logFC"))
    scales <- lapply(1:2, function(i) ggplot2::ggplot_build(plot[[i]])$plot$scales$get_scales("colour"))
    expect_identical(scales[[1]]$map(1), scales[[2]]$map(1))
    expect_equal(scales[[1]]$get_limits(), c(-4, 4))
    expect_equal(scales[[2]]$get_limits(), c(-4, 4))
  }
})

test_that("PlotButterfly minmax scaling respects small and constant ranges", {
  for (values in list(c(1e-14, 2e-14, 3e-14), c(7, 7, 7), c(-1e308, 0, 1e308))) {
    data <- data.frame(stat = rep(letters[1:3], 2), fill = "F",
                       group = rep(c("L", "R"), each = 3), value = rep(values, 2))
    original <- data
    plot <- PlotButterfly(data, stat.by = "stat", fill.by = "fill", value.by = "value",
                          group.by = "group", minmax = TRUE)
    expected <- if (length(unique(values)) == 1) rep(0, 3) else c(0, 0.5, 1)
    for (i in 1:2) expect_equal(plot[[i]]$data$value, expected)
    expect_identical(data, original)
  }
})

test_that("PlotButterfly2 honours ungrouped chart type and violin scaling", {
  data <- data.frame(stat = "A", value = seq_len(12), group = rep(c("L", "R"), each = 6))
  expected <- list(box = "GeomBoxplot", violin = "GeomViolin",
                    violin_box = c("GeomViolin", "GeomBoxplot"))
  for (type in names(expected)) {
    plot <- PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group",
                           type = type, violin.scale = "count")
    for (i in 1:2) {
      layers <- plot[[i]]$layers
      expect_identical(unname(vapply(layers, function(layer) class(layer$geom)[1], "")), expected[[type]])
      for (layer in layers) {
        if (inherits(layer$geom, "GeomViolin")) expect_identical(layer$stat_params$scale, "count")
      }
    }
  }
})

test_that("PlotButterfly2 saves the requested ungrouped chart type", {
  data <- data.frame(stat = "A", value = seq_len(12), group = rep(c("L", "R"), each = 6))
  saved <- NULL
  calls <- 0L
  original <- ggplot2::ggsave
  testthat::local_mocked_bindings(ggsave = function(filename, plot, ...) {
    saved <<- plot
    calls <<- calls + 1L
    original(filename, plot, ...)
  }, .package = "ggplot2")
  file <- withr::local_tempfile(fileext = ".pdf")
  plot <- suppressMessages(PlotButterfly2(data, stat.by = "stat", value.by = "value",
    group.by = "group", type = "box", filename = file, width = 5, height = 4))
  expect_identical(calls, 1L)
  expect_gt(file.info(file)$size, 0)
  for (i in 1:2) {
    expect_identical(class(saved[[i]]$layers[[1]]$geom)[1], "GeomBoxplot")
    expect_identical(length(saved[[i]]$layers), length(plot[[i]]$layers))
  }
})

test_that("PlotButterfly preserves named bar palettes in both panels", {
  data <- expand.grid(stat = "S", fill = c("A", "B"), group = c("L", "R"))
  data$value <- seq_len(nrow(data))
  plot <- PlotButterfly(data, stat.by = "stat", fill.by = "fill",
    value.by = "value", group.by = "group", palette = c(B = "blue", A = "red"))
  for (i in 1:2) {
    built <- ggplot2::ggplot_build(plot[[i]])
    expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), c("red", "blue"))
    expect_identical(built$data[[1]]$fill, c("red", "blue"))
  }
})

test_that("PlotButterfly2 preserves named fill palettes in both panels", {
  data <- expand.grid(value = seq_len(4), fill = c("A", "B"), group = c("L", "R"))
  data$stat <- "S"
  plot <- PlotButterfly2(data, stat.by = "stat", fill.by = "fill",
    value.by = "value", group.by = "group", type = "box",
    palette = c(B = "blue", A = "red"))
  for (i in 1:2) {
    built <- ggplot2::ggplot_build(plot[[i]])
    expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), c("red", "blue"))
    expect_identical(built$data[[1]]$fill, c("red", "blue"))
  }
})

test_that("PlotButterfly keeps named violin colours when variables are reordered", {
  left <- data.frame(A = seq_len(6), B = 11:16)
  right <- left[, c("B", "A")]
  for (order in list(c("B", "A"), "up", "down")) {
    plot <- butterfly_without_text_warning(PlotButterfly(type = "violin",
      data.left = left, data.right = right, levels = order,
      palette = c(B = "blue", A = "red"), add_box = FALSE))
    for (i in 1:2) {
      built <- ggplot2::ggplot_build(plot[[i]])
      expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), c("red", "blue"))
      expected <- c(A = "red", B = "blue")[levels(plot[[i]]$data$Variable)]
      expect_identical(built$data[[1]]$fill, unname(expected[as.integer(built$data[[1]]$y)]))
    }
  }
})

test_that("PlotButterfly2 keeps named category colours in delegated chart types", {
  data <- expand.grid(value = seq_len(6), stat = c("A", "B"), group = c("L", "R"))
  data$value <- data$value + ifelse(data$stat == "B", 10, 0)
  for (type in c("violin", "violin_box", "box")) {
    plot <- butterfly_without_text_warning(PlotButterfly2(data, stat.by = "stat",
      value.by = "value", group.by = "group", type = type, levels = c("B", "A"),
      palette = c(B = "blue", A = "red")))
    for (i in 1:2) {
      built <- ggplot2::ggplot_build(plot[[i]])
      expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), c("red", "blue"))
      expected <- c("blue", "red")[as.integer(built$data[[1]]$y)]
      expect_identical(built$data[[1]]$fill, expected)
    }
  }
})

test_that("PlotButterfly keeps named bar colours after row and factor reordering", {
  data <- expand.grid(stat = "S", fill = c("A", "B", "C"), group = c("L", "R"))
  data$value <- seq_len(nrow(data))
  data$fill <- factor(data$fill, levels = c("C", "unused", "B", "A"))
  original <- data
  for (type in c("bar", "bar_dodge")) {
    for (rows in list(seq_len(nrow(data)), rev(seq_len(nrow(data))))) {
      plot <- PlotButterfly(data[rows, ], stat.by = "stat", fill.by = "fill",
        value.by = "value", group.by = "group", type = type,
        palette = c(C = "green", B = "blue", A = "red"))
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B", "C")), c("red", "blue", "green"))
        expect_setequal(built$data[[1]]$fill, c("red", "blue", "green"))
      }
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly2 keeps named fills stable with reordered and absent groups", {
  data <- expand.grid(value = seq_len(4), fill = c("A", "B", "C"), group = c("L", "R"))
  data$stat <- "S"
  data <- data[!(data$group == "L" & data$fill == "C") &
    !(data$group == "R" & data$fill == "A"), ]
  data$fill <- factor(data$fill, levels = c("C", "unused", "B", "A"))
  original <- data
  for (type in c("violin", "violin_box", "box")) {
    for (rows in list(seq_len(nrow(data)), rev(seq_len(nrow(data))))) {
      plot <- PlotButterfly2(data[rows, ], stat.by = "stat", fill.by = "fill",
        value.by = "value", group.by = "group", type = type,
        palette = c(C = "green", B = "blue", A = "red"))
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("fill")$map("B"), "blue")
        expected <- if (plot[[i]]$data$group[1] == "L") c("red", "blue") else c("blue", "green")
        expect_setequal(built$data[[1]]$fill, expected)
      }
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly matches partial and extended palettes by name", {
  data <- expand.grid(stat = "S", fill = c("A", "B"), group = c("L", "R"))
  data$value <- seq_len(nrow(data))
  wide <- data.frame(A = seq_len(6), B = 11:16)
  palettes <- list(c(unused = "orange", B = "blue", A = "red"), c(A = "red"))
  expected <- list(c("red", "blue"), c("red", "grey50"))
  for (type in c("bar", "bar_dodge", "violin")) {
    for (j in seq_along(palettes)) {
      plot <- butterfly_without_text_warning(PlotButterfly(data,
        stat.by = "stat", fill.by = "fill", value.by = "value", group.by = "group",
        type = type, data.left = wide, data.right = wide, palette = palettes[[j]],
        add_box = FALSE))
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), expected[[j]])
        expect_setequal(built$data[[1]]$fill, expected[[j]])
      }
    }
  }
})

test_that("PlotButterfly2 matches named point palettes in both beeswarm types", {
  skip_if_not_installed("ggbeeswarm")
  data <- expand.grid(value = seq_len(4), fill = c("A", "B", "C"), group = c("L", "R"))
  data$stat <- "S"
  data <- data[!(data$group == "L" & data$fill == "C") &
    !(data$group == "R" & data$fill == "A"), ]
  data <- data[rev(seq_len(nrow(data))), ]
  data$fill <- factor(data$fill, levels = c("C", "unused", "B", "A"))
  palettes <- list(c(unused = "orange", C = "green", B = "blue", A = "red"), c(B = "blue"))
  for (type in c("beeswarm", "beeswarm_quasirandom")) {
    for (j in seq_along(palettes)) {
      plot <- suppressMessages(PlotButterfly2(data, stat.by = "stat", fill.by = "fill",
        value.by = "value", group.by = "group", type = type, palette = palettes[[j]]))
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("colour")$map("B"), "blue")
        expected <- if (j == 2L) c("grey50", "blue") else if (plot[[i]]$data$group[1] == "L") c("red", "blue") else c("blue", "green")
        expect_setequal(built$data[[1]]$colour, expected)
      }
    }
  }
})

test_that("PlotButterfly retains positional palette recycling and truncation", {
  data <- expand.grid(stat = "S", fill = c("A", "B"), group = c("L", "R"))
  data$value <- seq_len(nrow(data))
  wide <- data.frame(A = seq_len(6), B = 11:16)
  palettes <- list("red", c("red", "blue", "green"))
  expected <- list(c("red", "red"), c("red", "blue"))
  for (type in c("bar", "bar_dodge", "violin")) {
    for (j in seq_along(palettes)) {
      plot <- butterfly_without_text_warning(PlotButterfly(data,
        stat.by = "stat", fill.by = "fill", value.by = "value", group.by = "group",
        type = type, data.left = wide, data.right = wide, palette = palettes[[j]],
        add_box = FALSE))
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), expected[[j]])
        expect_setequal(built$data[[1]]$fill, expected[[j]])
      }
    }
  }
})

test_that("PlotButterfly2 retains positional fill palettes across factor levels", {
  data <- expand.grid(value = seq_len(4), fill = c("A", "B", "C"), group = c("L", "R"))
  data$stat <- "S"
  data$fill <- factor(data$fill, levels = c("C", "B", "A"))
  palettes <- list(c("red", "blue"), c("red", "blue", "green", "orange"))
  expected <- list(c("red", "blue", "red"), c("red", "blue", "green"))
  for (type in c("violin", "violin_box", "box")) {
    for (j in seq_along(palettes)) {
      plot <- PlotButterfly2(data, stat.by = "stat", fill.by = "fill",
        value.by = "value", group.by = "group", type = type, palette = palettes[[j]])
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("fill")$map(c("C", "B", "A")), expected[[j]])
        expect_setequal(built$data[[1]]$fill, expected[[j]])
      }
    }
  }
})
