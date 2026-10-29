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
