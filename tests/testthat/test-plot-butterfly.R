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

test_that("split butterfly fill mappings reject ambiguous keys and invalid colours", {
  d <- data.frame(stat = "A", value = 1:12, group = rep(c("L", "R"), each = 6), fill = rep(c("X", "Y"), 6))
  draw <- function(palette) butterfly_without_text_warning(PlotButterfly2(d,
    stat.by = "stat", value.by = "value", group.by = "group", fill.by = "fill", type = "box", palette = palette))
  for (bad in list(matrix(c("red", "blue")), c(X = "red", X = "blue", Y = "green"), "invalid-colour"))
    expect_error(draw(bad), "palette")
  colours <- c(Y = "#33669980", X = "red")
  p <- draw(colours)
  expect_setequal(ggplot2::ggplot_build(p[[1]])$data[[1]]$fill, unname(colours))
})

test_that("split butterfly point sizes and opacities validate only when drawn", {
  for (type in c("violin_box", "beeswarm_quasirandom"))
    for (arg in c("pt.size", "pt.alpha"))
      for (bad in list(-1, Inf, matrix(.5), structure(.5, class = "encoded"))) {
        args <- list(data = quote(stop("data evaluated")), type = type, add_point = TRUE,
                     stat.by = "stat", value.by = "value", group.by = "group")
        args[[arg]] <- bad
        expect_error(do.call("PlotButterfly2", args), arg, fixed = TRUE)
      }
  expect_error(PlotButterfly2(stop("data evaluated"), type = "violin", add_point = FALSE,
    stat.by = "stat", value.by = "value", group.by = "group",
    pt.size = stop("inactive"), pt.alpha = stop("inactive")), "data evaluated")
})

test_that("bar butterflies diagnose unsupported score-column storage", {
  for (bad in list(matrix(1:4, 4), as.list(1:4), 1:4 + 1i)) {
    d <- data.frame(stat = "A", fill = "F", group = rep(c("L", "R"), each = 2))
    d$value <- bad
    expect_error(PlotButterfly(d, stat.by = "stat", fill.by = "fill", value.by = "value",
      group.by = "group", base_size = stop("theme evaluated")), "value.*real vector")
  }
})

test_that("bar butterflies reject ambiguous data-frame columns", {
  d <- data.frame(stat = "A", fill = "F", value = 1:2, group = c("L", "R"),
    value = 3:4, check.names = FALSE)
  expect_error(PlotButterfly(d, stat.by = "stat", fill.by = "fill", value.by = "value",
    group.by = "group"), "unique.*column names")
})

test_that("PlotButterfly validates switches before reading input data", {
  for (arg in c("minmax", "add_box", "add_point"))
    for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
      args <- list(data = quote(stop("data evaluated")))
      args[[arg]] <- bad
      expect_error(do.call("PlotButterfly", args), arg)
    }
})

test_that("PlotButterfly validates required bar selectors individually", {
  data <- data.frame(stat = c("A", "A"), fill = "F", value = 1:2, group = c("L", "R"))
  for (arg in c("stat.by", "fill.by", "value.by", "group.by")) {
    for (bad in list(NULL, character(), c("stat", "fill"), NA_character_, matrix("stat"))) {
      args <- list(data = data, stat.by = "stat", fill.by = "fill", value.by = "value", group.by = "group")
      args[arg] <- list(bad)
      expect_error(do.call(PlotButterfly, args), arg)
    }
  }
})

test_that("PlotButterfly minmax retains entirely missing blocks without range warnings", {
  data <- data.frame(stat = rep(c("A", "B"), 2), fill = "F",
                     value = c(NA_real_, NA_real_, 1, 2), group = rep(c("L", "R"), each = 2))
  expect_no_warning(plot <- butterfly_without_text_warning(PlotButterfly(
    data, stat.by = "stat", fill.by = "fill", value.by = "value", group.by = "group", minmax = TRUE)))
  left <- ggplot2::ggplot_build(plot[[1]])$data[[1]]
  right <- ggplot2::ggplot_build(plot[[2]])$data[[1]]
  expect_equal(left$x, c(0, 0))
  expect_equal(sort(right$x), c(0, 1))
})

test_that("split butterfly geometry controls fail before data", {
  for (arg in c("alpha", "box.width", "dodge.width")) {
    args <- list(data = quote(stop("data evaluated")), stat.by = "stat", value.by = "value", group.by = "group")
    args[[arg]] <- NA_real_
    expect_error(do.call("PlotButterfly2", args), arg)
  }
  expect_error(PlotButterfly2(stop("data evaluated"), type = "beeswarm", cex = Inf,
    stat.by = "stat", value.by = "value", group.by = "group"), "cex")
})

test_that("split butterflies reject ambiguous source column names", {
  d <- data.frame(stat = "A", value = 1:4, group = rep(c("L", "R"), each = 2),
    value = 5:8, check.names = FALSE)
  expect_error(PlotButterfly2(d, stat.by = "stat", value.by = "value", group.by = "group"),
    "unique.*column names")
})

test_that("PlotButterfly2 validates used point overlays before reading data", {
  for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE)))
    expect_error(PlotButterfly2(stop("data evaluated"), stat.by = "stat", value.by = "value",
      group.by = "group", add_point = bad), "add_point")
})

test_that("beeswarm butterflies do not force unused overlay controls", {
  skip_if_not_installed("ggbeeswarm")
  d <- data.frame(stat = "A", value = 1:12, group = rep(c("L", "R"), each = 6), fill = "F")
  butterfly_without_text_warning(p <- PlotButterfly2(d, stat.by = "stat", value.by = "value",
    group.by = "group", fill.by = "fill", type = "beeswarm_quasirandom",
    add_point = stop("unused overlay evaluated")))
  expect_s3_class(p, "patchwork")
  expect_length(p, 2L)
})

test_that("PlotButterfly2 rejects malformed selectors and score storage before plotting", {
  for (arg in c("stat.by", "value.by", "group.by", "fill.by")) {
    for (bad in list(character(), c("stat", "fill"), NA_character_, matrix("stat"))) {
      args <- list(data = data.frame(stat = "A", value = 1:2, group = c("L", "R"), fill = "F"),
                   stat.by = "stat", value.by = "value", group.by = "group")
      args[arg] <- list(bad)
      expect_error(do.call(PlotButterfly2, args), arg)
    }
  }
  for (bad in list(matrix(1:4, 4), 1:4 + 1i, as.list(1:4))) {
    data <- data.frame(stat = "A", value = 1:4, group = rep(c("L", "R"), each = 2))
    data$value <- bad
    expect_error(PlotButterfly2(data, stat.by = "stat", value.by = "value", group.by = "group"), "value")
  }
})

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
      expect_warning(plot <- butterfly_without_text_warning(PlotButterfly(data,
        stat.by = "stat", fill.by = "fill", value.by = "value", group.by = "group",
        type = type, data.left = wide, data.right = wide, palette = palettes[[j]],
        add_box = FALSE)), if (j == 2L) "palette.*missing.*B" else NA)
      for (i in 1:2) {
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_identical(built$plot$scales$get_scales("fill")$map(c("A", "B")), expected[[j]])
        expect_setequal(built$data[[1]]$fill, expected[[j]])
      }
    }
  }
})

test_that("PlotButterfly rejects ambiguous palette names and invalid colours", {
  data <- expand.grid(stat = "S", fill = c("A", "B"), group = c("L", "R"))
  data$value <- seq_len(nrow(data))
  draw <- function(palette) PlotButterfly(data, stat.by = "stat", fill.by = "fill",
    value.by = "value", group.by = "group", palette = palette)
  expect_error(draw(c(A = "red", A = "green", B = "blue")), "duplicate.*A")
  expect_error(draw(c(A = "lancet")), "palette.*invalid colours")
  expect_error(draw(character()), "non-empty[[:space:]]+colour[[:space:]]+vector")
  expect_identical(ggplot2::ggplot_build(draw("lancet")[[1]])$data[[1]]$fill,
                   pal_get("lancet", n = 2L))
})

test_that("PlotButterfly checks empty named palettes and reports no matches once", {
  data <- expand.grid(stat = "S", fill = c("A", "B"), group = c("L", "R"))
  data$value <- seq_len(nrow(data))
  draw <- function(palette) PlotButterfly(data, stat.by = "stat", fill.by = "fill",
    value.by = "value", group.by = "group", palette = palette)
  expect_error(draw(setNames(character(), character())), "non-empty")
  expect_error(draw(setNames(list(), character())), "non-empty")
  expect_warning(plot <- draw(c(Z = "red")), "palette.*missing.*A.*B")
  for (i in 1:2) {
    expect_warning(built <- ggplot2::ggplot_build(plot[[i]]), NA)
    expect_identical(built$data[[1]]$fill, rep("grey50", 2))
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

test_that("butterfly panels distinguish nearby numeric group values", {
  values <- c(1, 1 + 1e-15)
  data <- data.frame(stat = "S", fill = "F", value = 1:8,
                     group = rep(values, each = 4))
  original <- data
  for (fun in list(PlotButterfly, PlotButterfly2)) {
    plot <- fun(data, stat.by = "stat", value.by = "value",
                group.by = "group", fill.by = "fill")
    for (i in 1:2) {
      expect_identical(as.double(unique(as.character(plot[[i]]$data$group))), values[i])
      expect_equal(sort(plot[[i]]$data$value), (1:4) + (i - 1) * 4)
      expect_equal(length(unique(ggplot2::ggplot_build(plot[[i]])$data[[1]]$group)), 1)
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly completes bars using precise numeric category keys", {
  values <- c(1, 1 + 1e-15)
  for (axis in c("stat", "fill")) {
    data <- expand.grid(stat = c("A", "B"), fill = c("F", "G"),
                         group = c("L", "R"), stringsAsFactors = FALSE)
    data[[axis]] <- values[match(data[[axis]], unique(data[[axis]]))]
    data$value <- seq_len(nrow(data))
    data <- data[-nrow(data), ]
    original <- data
    for (type in c("bar", "bar_dodge")) {
      plot <- PlotButterfly(data, stat.by = "stat", value.by = "value",
                            group.by = "group", fill.by = "fill", type = type)
      for (i in 1:2) {
        expect_identical(as.double(levels(plot[[i]]$data[[axis]])), values)
        expect_equal(nrow(plot[[i]]$data), 4)
        expected <- if (i == 1) 1:4 else c(0, 5:7)
        expect_equal(sort(plot[[i]]$data$value), expected)
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_equal(length(unique(round(built$data[[1]]$y))), 2)
        expect_equal(length(unique(built$data[[1]]$fill)), 2)
      }
    }
    expect_identical(data, original)
  }
})

test_that("PlotButterfly2 preserves precise categories in direct plot types", {
  values <- c(1, 1 + 1e-15)
  data <- expand.grid(value = seq_len(4), stat = values, fill = values,
                       group = c("L", "R"))
  original <- data
  for (type in c("violin", "violin_box", "box")) {
    plot <- butterfly_without_text_warning(suppressMessages(PlotButterfly2(data,
      stat.by = "stat", value.by = "value", group.by = "group",
      fill.by = "fill", type = type)))
    for (i in 1:2) {
      expect_identical(as.double(levels(plot[[i]]$data$stat)), values)
      expect_identical(as.double(levels(plot[[i]]$data$fill)), values)
      expect_equal(nrow(plot[[i]]$data), 16)
      built <- ggplot2::ggplot_build(plot[[i]])
      expect_equal(length(unique(built$data[[1]]$group)), 4)
      expect_equal(length(unique(built$data[[1]]$fill)), 2)
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly2 keeps precise categories when converting to wide data", {
  values <- c(1, 1 + 1e-15)
  data <- expand.grid(value = seq_len(4), stat = values, group = c("L", "R"))
  data$value <- data$value + rep(c(0, 10), each = 4, times = 2)
  original <- data
  for (type in c("violin", "violin_box", "box")) {
    plot <- butterfly_without_text_warning(PlotButterfly2(data,
      stat.by = "stat", value.by = "value", group.by = "group", type = type))
    for (i in 1:2) {
      expect_identical(as.double(levels(plot[[i]]$data$Variable)), values)
      expect_equal(sort(plot[[i]]$data$Value), c(1:4, 11:14))
      built <- ggplot2::ggplot_build(plot[[i]])
      expect_equal(length(unique(built$data[[1]]$group)), 2)
    }
  }
  expect_identical(data, original)
})

test_that("PlotButterfly minmax scaling separates precise numeric groups and fills", {
  values <- c(1, 1 + 1e-15)
  data <- expand.grid(stat = LETTERS[1:3], fill = values, group = values)
  data$value <- c(10, 20, 30, 7, 7, 7, 30, 60, 90, 1e-14, 2e-14, 3e-14)
  original <- data
  plot <- PlotButterfly(data, stat.by = "stat", value.by = "value",
                        group.by = "group", fill.by = "fill", minmax = TRUE)
  for (i in 1:2) {
    panel <- plot[[i]]$data
    expect_identical(as.double(unique(panel$group)), values[i])
    for (j in 1:2) {
      selected <- panel[as.double(as.character(panel$fill)) == values[j], ]
      expected <- if (i == 1 && j == 2) c(0, 0, 0) else c(0, 0.5, 1)
      expect_equal(selected$value[order(selected$stat)], expected)
    }
    expect_equal(nrow(ggplot2::ggplot_build(plot[[i]])$data[[1]]), 6)
  }
  expect_identical(data, original)
})

test_that("butterfly sorting and named palettes retain precise numeric categories", {
  values <- c(1, 1 + 1e-15)
  labels <- c("1", "1.0000000000000011")
  data <- expand.grid(value = seq_len(4), stat = values, fill = values,
                       group = c("L", "R"))
  data$value <- data$value + ifelse(data$stat == values[2], 10, 0)
  palette <- stats::setNames(c("red", "blue"), labels)
  for (fun in list(PlotButterfly, PlotButterfly2)) {
    for (rows in list(seq_len(nrow(data)), rev(seq_len(nrow(data))))) {
      for (order in list("up", "down", rev(labels))) {
        plot <- butterfly_without_text_warning(fun(data[rows, ],
          stat.by = "stat", value.by = "value", group.by = "group",
          fill.by = "fill", levels = order, palette = palette))
        expected <- if (identical(order, "up")) values else rev(values)
        for (i in 1:2) {
          expect_identical(as.double(levels(plot[[i]]$data$stat)), expected)
          built <- ggplot2::ggplot_build(plot[[i]])
          expect_identical(built$plot$scales$get_scales("fill")$map(labels), c("red", "blue"))
          expect_setequal(built$data[[1]]$fill, c("red", "blue"))
        }
      }
    }
  }
})

test_that("PlotButterfly2 maps precise numeric beeswarm categories in both panels", {
  skip_if_not_installed("ggbeeswarm")
  values <- 1 + c(0, 1e-15, 2e-15, 3e-15)
  labels <- c("1", "1.0000000000000011", "1.000000000000002", "1.0000000000000031")
  data <- expand.grid(value = seq_len(3), stat = values[1:2],
                       fill = values, group = 2 + c(0, 1e-15))
  palette <- stats::setNames(c("red", "blue", "green", "orange"), labels)
  for (type in c("beeswarm", "beeswarm_quasirandom")) {
    for (color_by in c("fixed", "logFC")) {
      plot <- butterfly_without_text_warning(suppressMessages(PlotButterfly2(data,
        stat.by = "stat", value.by = "value", group.by = "group",
        fill.by = "fill", type = type, color_by = color_by, palette = palette)))
      for (i in 1:2) {
        expect_equal(nrow(plot[[i]]$data), 24)
        built <- ggplot2::ggplot_build(plot[[i]])
        expect_equal(length(unique(built$data[[1]]$group)), 8)
        if (color_by == "logFC") {
          expect_identical(built$plot$scales$get_scales("shape")$map(labels), c(16, 17, 15, 18))
          expect_setequal(built$data[[1]]$shape, c(16, 17, 15, 18))
        } else {
          expect_identical(built$plot$scales$get_scales("colour")$map(labels), unname(palette))
          expect_setequal(built$data[[1]]$colour, unname(palette))
        }
      }
    }
  }
  data <- expand.grid(value = seq_len(3), stat = "S", fill = 1 + (0:4) * 1e-15,
                       group = c("L", "R"))
  expect_error(PlotButterfly2(data, stat.by = "stat", value.by = "value",
    group.by = "group", fill.by = "fill", type = "beeswarm_quasirandom",
    color_by = "logFC"), "at most 4 observed")
})

test_that("butterfly group validation counts original numeric identities", {
  data <- data.frame(stat = "S", fill = "F", value = 1:12,
                     group = rep(1 + c(0, 1e-15, 2e-15), each = 4))
  for (fun in list(PlotButterfly, PlotButterfly2)) {
    expect_error(fun(data, stat.by = "stat", value.by = "value",
      group.by = "group", fill.by = "fill"), "exactly 2 levels, got 3")
  }
})

test_that("PlotButterfly2 intersects numeric categories before rounding", {
  values <- 1 + c(0, 1e-15, 2e-15)
  disjoint <- data.frame(stat = rep(values[1:2], each = 4), value = 1:8,
                         group = rep(c("L", "R"), each = 4))
  expect_error(PlotButterfly2(disjoint, stat.by = "stat", value.by = "value",
    group.by = "group", type = "box"), "No common")
  data <- data.frame(stat = rep(values[c(1, 2, 2, 3)], each = 4),
                     value = c(1:4, 11:14, 21:24, 31:34),
                     group = rep(c("L", "R"), each = 8))
  original <- data
  plot <- PlotButterfly2(data, stat.by = "stat", value.by = "value",
                         group.by = "group", type = "box")
  for (i in 1:2) {
    expect_identical(as.double(levels(plot[[i]]$data$Variable)), values[2])
    expect_equal(plot[[i]]$data$Value, (1:4) + i * 10)
    expect_equal(nrow(ggplot2::ggplot_build(plot[[i]])$data[[1]]), 1)
  }
  expect_identical(data, original)
})

test_that("butterfly numeric identities survive magnitude and display options", {
  withr::local_options(list(digits = 3, scipen = 999, OutDec = ","))
  categories <- list(1e15 + c(0, 1), -rev(1e15 + c(0, 1)),
                      1e-300 + c(0, 1e-315), 1e308 + c(0, 2e292))
  for (values in categories) {
    data <- expand.grid(value = seq_len(4), stat = values, fill = values,
                         group = values)
    original <- data
    for (fun in list(PlotButterfly, PlotButterfly2)) {
      plot <- butterfly_without_text_warning(fun(data, stat.by = "stat",
        value.by = "value", group.by = "group", fill.by = "fill"))
      for (i in 1:2) {
        expect_identical(as.double(unique(as.character(plot[[i]]$data$group))), values[i])
        expect_setequal(as.double(levels(plot[[i]]$data$stat)), values)
        expect_setequal(as.double(levels(plot[[i]]$data$fill)), values)
        expect_equal(nrow(plot[[i]]$data), 16)
        expect_equal(length(unique(ggplot2::ggplot_build(plot[[i]])$data[[1]]$group)), 4)
      }
    }
    expect_identical(data, original)
  }
})

test_that("butterfly minmax scaling keeps category tuples distinct", {
  d <- data.frame(s = c("u", "v", "u", "v"), g = c("a.b", "a.b", "a", "a"), f = c("c", "c", "b.c", "b.c"), v = c(0, 10, 100, 200))
  p <- PlotButterfly(d, stat.by = "s", fill.by = "f", value.by = "v", group.by = "g", minmax = TRUE)
  for (i in seq_len(length(p))) {
    data <- p[[i]]$data
    fill <- if (as.character(data$g[[1L]]) == "a.b") "c" else "b.c"
    expect_identical(sort(data$v[as.character(data$f) == fill]), c(0, 1))
  }
})

test_that("butterfly bars allow shared category columns", {
  d <- data.frame(s = c("u", "v", "u", "v"), g = rep(c("a", "b"), each = 2L), v = 1:4)
  for (fill in c("s", "g")) {
    d[["f"]] <- d[[fill]]
    actual <- PlotButterfly(d, stat.by = "s", fill.by = fill, value.by = "v", group.by = "g")
    expected <- PlotButterfly(d, stat.by = "s", fill.by = "f", value.by = "v", group.by = "g")
    for (i in seq_len(length(actual))) {
      active <- function(p) {
        layer <- ggplot2::ggplot_build(p)$data[[1L]]
        layer$length <- abs(layer$xmax - layer$xmin)
        layer <- layer[layer$length > 0, , drop = FALSE]
        list(length = sort(layer$length), fill = layer$fill[order(layer$length)])
      }
      expect_identical(active(actual[[i]]), active(expected[[i]]))
    }
  }
})

test_that("butterfly grouping restores integer64 categories in cold processes", {
  skip_if_not_installed("bit64")
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "input.rds")
  script <- file.path(directory, "verify.R")
  d <- data.frame(cat = rep(c("u", "v"), 2L), fill = "x", value = 1:4)
  d$group <- bit64::as.integer64(rep(c("-1", "-2"), each = 2L))
  d2 <- d
  d2$cat <- bit64::as.integer64(rep(c("-1", "-2"), 2L))
  d2$group <- rep(c("A", "B"), each = 2L)
  saveRDS(list(data = d, data2 = d2, functions = list(PlotButterfly = PlotButterfly, PlotButterfly2 = PlotButterfly2, .butterfly_category_labels = .butterfly_category_labels)), fixture)
  for (i in 1:2) {
    writeLines(c(sprintf("payload <- readRDS(%s)", deparse(fixture)),
      "stopifnot(!('bit64' %in% loadedNamespaces()))",
      "e <- new.env(parent = asNamespace('UtilsR')); for (name in names(payload$functions)) {fn <- payload$functions[[name]]; environment(fn) <- e; e[[name]] <- fn}",
      if (i == 1L) "p <- e$PlotButterfly(payload$data, stat.by = 'cat', fill.by = 'fill', value.by = 'value', group.by = 'group'); expected <- c('-1', '-2'); field <- 'subtitle'" else "p <- e$PlotButterfly2(payload$data2, stat.by = 'cat', value.by = 'value', group.by = 'group', text.colors = 'black'); expected <- c('A', 'B'); field <- 'title'",
      "stopifnot(length(p) == 2L, identical(vapply(seq_along(p), function(i) as.character(p[[i]]$labels[[field]]), character(1)), expected))",
      "cat('COLD_BUTTERFLY_OK\n')"), script)
    output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
    expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
    expect_identical(tail(output, 1L), 'COLD_BUTTERFLY_OK')
  }
})

test_that("butterfly wide conversion groups each side in one pass", {
  levels <- paste0("kind", seq_len(30L))
  cats <- c(rev(levels), levels[1L])
  d <- data.frame(kind = factor(rep(cats, 2L), levels = levels),
    value = seq_len(2L * length(cats)), side = rep(c("L", "R"), each = length(cats)))
  fn <- PlotButterfly2
  env <- new.env(parent = environment(fn))
  scans <- 0L
  env[["=="]] <- function(x, y) {
    if (is.character(x) && length(x) == length(cats) && length(y) == 1L) scans <<- scans + 1L
    base::`==`(x, y)
  }
  original <- NULL
  env$PlotButterfly <- function(data.left, data.right, ...) {
    original <<- list(data.left, data.right)
    list()
  }
  environment(fn) <- env
  fn(d, stat.by = "kind", value.by = "value", group.by = "side", type = "box")
  expect_identical(scans, 0L)
  expect_identical(names(original[[1L]]), rev(levels))
  expect_identical(original[[1L]][[levels[1L]]], c(30L, 31L))
  expect_identical(original[[2L]][[levels[30L]]], c(32L, NA_integer_))
})

test_that("uniform butterfly label colours use a scalar theme style", {
  left <- data.frame(A = c(1, 2, 3), B = c(2, 4, 6))
  right <- data.frame(A = c(2, 3, 5), B = c(1, 3, 5))
  for (cols in list(NULL, "purple", rep("purple", 2L))) {
    color <- if (is.null(cols)) "black" else "purple"
    expect_no_warning(p <- PlotButterfly(type = "violin", data.left = left,
      data.right = right, text.colors = cols))
    expect_identical(p[[2L]]$theme$axis.text.y$colour, color)
    d <- data.frame(category = rep(c("A", "B"), each = 3L, times = 2L),
      value = c(unlist(left, use.names = FALSE), unlist(right, use.names = FALSE)),
      side = rep(c("left", "right"), each = 6L), fill = "Group")
    expect_no_warning(p <- PlotButterfly2(d, "category", "value", "side",
      fill.by = "fill", type = "box", text.colors = cols))
    expect_identical(p[[2L]]$theme$axis.text.y$colour, color)
  }
})

test_that("missing butterfly category codes do not create placeholder rows", {
  d <- data.frame(category = factor(rep(c("A", "B", NA), 4L), exclude = NULL),
    value = 1:12, side = rep(c("left", "right"), each = 6L), fill = "F")
  ordinary <- d[!is.na(as.character(d$category)), , drop = FALSE]
  ordinary$category <- droplevels(ordinary$category)
  for (fill in list(NULL, "fill")) {
    draw <- function(x) PlotButterfly2(x, "category", "value", "side", fill.by = fill, type = "box")
    control <- draw(ordinary)
    actual <- draw(d)
    for (i in 1:2) {
      expect_equal(ggplot2::ggplot_build(actual[[i]])$data,
                   ggplot2::ggplot_build(control[[i]])$data)
    }
  }
})
