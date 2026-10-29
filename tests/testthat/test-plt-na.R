oc_data <- function() {
  testthat::skip_if_not_installed("ToyData")
  ToyData::oc
}

oc_missing_levels <- function(decreasing = TRUE) {
  data <- oc_data()
  missing_rate <- colMeans(is.na(data))
  names(sort(missing_rate[missing_rate > 0], decreasing = decreasing))
}

oc_missing_rates <- function() {
  data <- oc_data()
  missing_rate <- colMeans(is.na(data))
  missing_rate[missing_rate > 0]
}

render_plot <- function(plot) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)

  if (inherits(plot, "patchwork")) {
    patchwork::patchworkGrob(plot)
  } else {
    ggplot2::ggplotGrob(plot)
  }
}

test_that("plt_na returns the standard combined plot by default", {
  name_map <- c(CYFRA21 = "CYFRA21 mapped", CA242 = "CA242 mapped")
  plot <- plt_na(
    oc_data(),
    name.map = name_map
  )

  expect_s3_class(plot, "patchwork")
  expect_s3_class(plot, "ggplot")
  expect_length(plot, 2)
  expect_equal(as.numeric(plot[[1]]$theme$plot.margin)[2], 2)
  expect_equal(as.numeric(plot[[2]]$theme$plot.margin)[4], 2)
  expected_levels <- oc_missing_levels()
  expected_levels[match(names(name_map), expected_levels)] <- name_map
  expect_setequal(levels(plot[[1]]$data$label), expected_levels)
  expect_equal(
    unique(ggplot2::ggplot_build(plot[[1]])$layout$layout$.strip_label.),
    "Distribution of Missing Values"
  )
  expect_equal(
    unique(ggplot2::ggplot_build(plot[[2]])$layout$layout$.strip_label.),
    "Percentage of Missing Values"
  )
  expect_silent(render_plot(plot))
})

test_that("plt_na returns the reversed combined plot", {
  plot <- plt_na(oc_data(), output = "both_reverse")

  expect_s3_class(plot, "patchwork")
  expect_length(plot, 2)
  expect_equal(as.numeric(plot[[1]]$theme$plot.margin)[2], 2)
  expect_equal(as.numeric(plot[[2]]$theme$plot.margin)[4], 2)
  expect_equal(plot[[1]]$scales$get_scales("y")$limits, c(-100, 0))
  expect_false(inherits(plot[[1]]$theme$axis.text.y, "element_blank"))
  expect_true(inherits(plot[[2]]$theme$axis.text.y, "element_blank"))
  expect_equal(
    unique(ggplot2::ggplot_build(plot[[1]])$layout$layout$.strip_label.),
    "Percentage of Missing Values"
  )
  expect_equal(
    unique(ggplot2::ggplot_build(plot[[2]])$layout$layout$.strip_label.),
    "Distribution of Missing Values"
  )
  expect_silent(render_plot(plot))
})

test_that("plt_na places combined legends at the top", {
  regular <- plt_na(oc_data(), output = "both")
  reversed <- plt_na(oc_data(), output = "both_reverse")

  expect_identical(regular[[2]]$theme$legend.position, "top")
  expect_identical(reversed[[1]]$theme$legend.position, "top")
})

test_that("plt_na returns one missingness matrix", {
  plot <- plt_na(oc_data(), output = "matrix")

  expect_s3_class(plot, "ggplot")
  expect_setequal(levels(plot$data$label), names(oc_missing_rates()))
  expect_silent(render_plot(plot))
})

test_that("plt_na returns one percentage plot", {
  plot <- plt_na(oc_data(), output = "percentage")

  expect_s3_class(plot, "ggplot")
  expect_equal(plot$scales$get_scales("y")$limits, c(0, 100))
  expect_equal(plot$scales$get_scales("y")$expand, c(0, 0))
  expect_silent(render_plot(plot))
})

test_that("plt_na keeps the Present bar with floating-point percentages", {
  plot <- plt_na(
    data.frame(lab = c(rep(1, 365), rep(NA_real_, 10))),
    output = "percentage"
  )
  bars <- ggplot2::ggplot_build(plot)$data[[1]]

  expect_true(all(is.finite(bars$ymax)))
})

test_that("plt_na orders variables by missing rate", {
  descending <- plt_na(oc_data(), output = "percentage", sort = "desc")
  ascending <- plt_na(oc_data(), output = "matrix", sort = "asc")
  missing_rate <- oc_missing_rates()

  expect_equal(
    unname(missing_rate[levels(descending$data$label)]),
    sort(unname(missing_rate), decreasing = TRUE)
  )
  expect_equal(
    unname(missing_rate[levels(ascending$data$label)]),
    sort(unname(missing_rate), decreasing = FALSE)
  )
})

test_that("plt_na renders a variable with all values missing", {
  plot <- plt_na(
    data.frame(complete = 1:4, all_missing = rep(NA_real_, 4)),
    output = "percentage"
  )

  expect_silent(render_plot(plot))
})

test_that("plt_na applies the missing-value palette", {
  plot <- plt_na(
    oc_data(),
    output = "matrix",
    miss_palette = c("#111111", "#222222", "#333333")
  )
  fills <- unique(ggplot2::ggplot_build(plot)$data[[1]]$fill)

  expect_setequal(fills, c("#111111", "#222222"))
})

test_that("plt_na rejects an unsupported output", {
  expect_snapshot(error = TRUE, plt_na(oc_data(), output = "unsupported"))
})

test_that("plt_na warns and returns NULL when no values are missing", {
  expect_snapshot(
    result <- plt_na(data.frame(x = 1:3, y = letters[1:3]))
  )
  expect_null(result)
})

test_that("plt_na saves at a page that grows with its variables", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_na)), 1), "save")
  make <- function(k) {
    set.seed(1)
    out <- as.data.frame(matrix(stats::rnorm(40 * k), ncol = k))
    for (j in seq_len(k)) out[sample.int(40, j), j] <- NA
    out
  }
  f <- withr::local_tempfile(fileext = ".pdf")
  for (output in c("both", "matrix", "percentage")) {
    out <- cli::cli_fmt(p <- plt_na(make(4), output = output,
                                    save = list(filename = f)))
    expect_saved_at_plot_size(out, p)
  }
  utils::capture.output(short <- plt_na(make(4)))
  utils::capture.output(tall <- plt_na(make(16)))
  expect_gt(attr(tall, "plot_size")[[2]], attr(short, "plot_size")[[2]])
})

test_that("plt_na preserves original missing masks across column types", {
  skip_if_not_installed("haven")
  columns <- list(
    spss = haven::labelled_spss(c(1, 99, NA_real_), na_values = 99),
    spss_range = haven::labelled_spss(c(1, 98, 99), na_range = c(98, 99)),
    explicit_na = structure(c(1L, 2L, NA_integer_),
                            levels = c("A", NA_character_), class = "factor"),
    list = I(list(1, NA_real_, 3)),
    complex = c(1 + 0i, complex(real = NA, imaginary = 1), 3 + 0i),
    logical = c(TRUE, NA, FALSE),
    time = as.POSIXlt(c("2026-01-01", NA, "2026-01-03"), tz = "UTC"),
    span = as.difftime(c(1, NA, 3), units = "days")
  )
  for (column in columns) {
    data <- data.frame(helper = 1:3)
    data[["value"]] <- column
    original <- data
    percentage <- suppressMessages(plt_na(data, output = "percentage"))
    missing <- percentage$data[percentage$data$isna, ]
    expect_equal(missing$num, sum(is.na(column)))
    expect_equal(missing$pct, mean(is.na(column)) * 100)
    matrix <- suppressMessages(plt_na(data, output = "matrix"))
    expect_identical(matrix$data$isna, is.na(column))
    expect_identical(data, original)
  }
})

test_that("plt_na restores serialized integer64 missing methods", {
  skip_if_not_installed("bit64")
  data <- data.frame(helper = 1:3)
  data[["value"]] <- bit64::as.integer64(c("9007199254740993", NA, "9007199254740994"))
  fixture <- withr::local_tempfile(fileext = ".rds")
  script <- withr::local_tempfile(fileext = ".R")
  saveRDS(data, fixture)
  quote_r <- function(x) paste(deparse(x), collapse = "\n")
  writeLines(c(
    "options(device = function(...) grDevices::pdf(NULL, ...))",
    paste0(".libPaths(", quote_r(.libPaths()), ")"),
    paste0("pkgload::load_all(", quote_r(getNamespaceInfo(asNamespace("UtilsR"), "path")),
           ", quiet = TRUE, export_all = FALSE, helpers = FALSE)"),
    paste0("data <- readRDS(", quote_r(fixture), ")"),
    "p <- suppressMessages(UtilsR::plt_na(data, output = 'percentage'))",
    "stopifnot(identical(as.character(p$data$name[p$data$isna]), 'value'))",
    "stopifnot(identical(p$data$num[p$data$isna], 1L))"
  ), script)
  output <- system2(file.path(R.home("bin"), "Rscript"),
                    c("--vanilla", shQuote(script)), stdout = TRUE, stderr = TRUE)
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
})

test_that("plt_na keeps missing id columns in every matrix layout", {
  data <- data.frame(id = c(1, NA, 3), marker = c(NA, 2, 3))
  for (output in c("matrix", "both", "both_reverse")) {
    plot <- suppressMessages(plt_na(data, output = output))
    matrix <- if (output == "matrix") plot else plot[[if (output == "both") 1L else 2L]]
    expect_setequal(unique(matrix$data$name), names(data))
    expect_equal(nrow(matrix$data), 6L)
    expect_identical(matrix$data$isna[matrix$data$name == "id"], c(FALSE, TRUE, FALSE))
  }
  plot <- suppressMessages(plt_na(data["id"], output = "matrix"))
  expect_identical(plot$data$isna, c(FALSE, TRUE, FALSE))
})

test_that("plt_na labels an all-missing legend as Missing in every layout", {
  for (output in c("matrix", "percentage", "both", "both_reverse")) {
    plot <- suppressMessages(plt_na(data.frame(value = rep(NA_real_, 3)), output = output))
    panels <- if (inherits(plot, "patchwork")) lapply(seq_along(plot), function(i) plot[[i]]) else list(plot)
    for (panel in panels) {
      built <- ggplot2::ggplot_build(panel)
      scale <- built$plot$scales$get_scales("fill")
      expect_identical(as.character(scale$get_labels()), "Missing")
      expect_identical(unique(built$data[[1L]]$fill), unname(as.character(pal_lancet[2L])))
    }
  }
})

test_that("plt_na accepts named missing-value palettes", {
  data <- data.frame(value = c(1, NA, 3))
  palette <- c(present = "blue", missing = "red", reference = "black")
  for (output in c("matrix", "percentage")) {
    expect_no_warning(plot <- suppressMessages(plt_na(data, output = output, miss_palette = palette)))
    built <- ggplot2::ggplot_build(plot)
    expect_setequal(unique(built$data[[1L]]$fill), c("blue", "red"))
    if (output == "percentage") expect_identical(built$data[[2L]]$colour, "black")
  }
})

test_that("plt_na keeps variables distinct when displayed labels coincide", {
  data <- data.frame(a = c(1, NA, 3), b = c(NA, NA, 3))
  for (map in list(c(a = "Marker", b = "Marker"), c(a = "b"))) {
    expect_no_error(plot <- suppressMessages(plt_na(data, name.map = map)))
    for (panel in lapply(seq_along(plot), function(i) plot[[i]])) {
      expect_equal(nlevels(panel$data$label), 2L)
      expect_setequal(unique(panel$data$name), names(data))
      scale <- ggplot2::ggplot_build(panel)$plot$scales$get_scales("x")
      expect_identical(as.character(scale$get_labels()), rep(unname(map[[1L]]), 2L))
    }
    summary <- plot[[2L]]$data
    expect_equal(summary$pct[summary$isna & summary$name == "a"], 100 / 3)
    expect_equal(summary$pct[summary$isna & summary$name == "b"], 200 / 3)
  }
})

test_that("plt_na preserves nonzero and incomplete percentage labels", {
  for (i in seq_along(counts <- c(1L, 99999L, 100000L))) {
    data <- data.frame(value = rep(1, 100000L))
    data$value[seq_len(counts[[i]])] <- NA_real_
    plot <- suppressMessages(plt_na(data, output = "percentage"))
    built <- ggplot2::ggplot_build(plot)
    expect_identical(as.character(built$data[[3L]]$label), c("<0.01%", ">99.99%", "100%")[[i]])
    expect_equal(plot$data$pct[plot$data$isna], counts[[i]] / 1000)
  }
})

test_that("plt_na rejects ambiguous names and multidimensional columns clearly", {
  data <- data.frame(helper = c(1, 2, NA))
  data[["packed"]] <- matrix(1:6, nrow = 3)
  expect_error(plt_na(data), "one-dimensional.*packed")
  data[["packed"]] <- array(1:12, dim = c(3, 2, 2))
  expect_error(plt_na(data), "one-dimensional.*packed")
  data <- data.frame(a = c(1, NA, 3), b = c(NA, 2, 3))
  names(data) <- c("x", "x")
  expect_error(plt_na(data), "unique.*column names")
  names(data) <- c("", "x")
  expect_error(plt_na(data), "non-empty.*column names")
  names(data) <- c(NA_character_, "x")
  expect_error(plt_na(data), "non-missing.*column names")
  data <- data.frame(x = c(1, NA, 3))
  expect_error(plt_na(data, name.map = c(x = "A", x = "B")), "name.map.*unique")
  expect_error(plt_na(data, name.map = stats::setNames("A", "")), "name.map.*non-empty")
  expect_error(plt_na(data, name.map = stats::setNames("A", NA_character_)), "name.map.*non-missing")
})

test_that("plt_na percentage summaries avoid cell-sized allocations", {
  skip_if_not(capabilities("profmem"))
  data <- as.data.frame(matrix(1, nrow = 10000L, ncol = 20L))
  data[1L, ] <- NA_real_
  suppressMessages(plt_na(data[1:3, ], output = "percentage"))
  profile <- withr::local_tempfile()
  threshold <- nrow(data) * ncol(data) * 2
  utils::Rprofmem(profile, threshold = threshold)
  withr::defer(utils::Rprofmem(NULL))
  plot <- suppressMessages(plt_na(data, output = "percentage"))
  utils::Rprofmem(NULL)
  sizes <- suppressWarnings(as.numeric(sub(" .*", "", readLines(profile))))
  expect_length(sizes[!is.na(sizes) & sizes > threshold], 0L)
  expect_equal(nrow(plot$data), 40L)
  expect_equal(plot$data$num[plot$data$isna], rep(1L, 20L))
})

test_that("plt_na returned plots do not retain unused input payloads", {
  withr::local_seed(1)
  make <- function(n = 20L, extra = FALSE, output = "percentage") {
    data <- data.frame(value = rep(c(NA_real_, 1:19), length.out = n))
    if (extra) attr(data, "unused_payload") <- stats::runif(50000L)
    suppressMessages(UtilsR::plt_na(data, output = output))
  }
  environment(make) <- globalenv()
  bytes <- function(plot) {
    path <- withr::local_tempfile(fileext = ".rds")
    saveRDS(plot, path, compress = FALSE)
    file.info(path)$size
  }
  for (output in c("percentage", "matrix", "both", "both_reverse")) {
    small <- make(output = output)
    payload <- make(extra = TRUE, output = output)
    expect_lt(abs(bytes(payload) - bytes(small)), 20000)
  }
  expect_lt(abs(bytes(make(20000L)) - bytes(make(20L))), 20000)
})
