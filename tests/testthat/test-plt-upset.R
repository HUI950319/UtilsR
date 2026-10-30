bmi_missing_data <- function() {
  data.frame(
    BMI_1 = c(1, NA, 3, 4, NA, 6),
    BMI_2 = c(NA, 2, NA, 4, NA, 6),
    BMI_3 = c(1, 2, NA, NA, NA, 6),
    other = c(NA, 2, 3, 4, 5, 6)
  )
}

render_upset <- function(plot) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  print(plot)
}

test_that("plt_upset plots missing-value membership", {
  skip_if_not_installed("ggVennDiagram")

  plot <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "upset"
  )

  expect_s3_class(plot, "upset_plot")
  expect_silent(render_upset(plot))
})

test_that("plt_upset assigns the expected missing-value intersections", {
  skip_if_not_installed("ggVennDiagram")

  result <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "data"
  )

  expect_equal(
    as.character(result$intersect_group),
    c(
      "BMI_2",
      "BMI_1",
      "BMI_2/BMI_3",
      "BMI_3",
      "BMI_1/BMI_2/BMI_3",
      "None"
    )
  )
})

test_that("plt_upset limits missing-value intersections to vars", {
  skip_if_not_installed("ggVennDiagram")

  result <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2"),
    levels = NA,
    output = "data"
  )

  expect_identical(as.character(result$intersect_group[1]), "BMI_2")
  expect_length(
    grep("other", levels(result$intersect_group), fixed = TRUE),
    0L
  )
})

test_that("plt_upset supports missing values across column types", {
  skip_if_not_installed("ggVennDiagram")

  data <- data.frame(
    numeric = c(1, NA, 3, 4),
    character = c("a", "b", NA, "d"),
    factor = factor(c("x", "y", "z", NA))
  )
  original <- data

  result <- plt_upset(
    data,
    vars = names(data),
    levels = NA,
    output = "data"
  )

  expect_equal(
    as.character(result$intersect_group),
    c("None", "numeric", "character", "factor")
  )
  expect_identical(data, original)
})

test_that("plt_upset hides zero intersections and preserves value membership", {
  skip_if_not_installed("ggVennDiagram")

  missing_plot <- plt_upset(
    bmi_missing_data(),
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "upset"
  )
  intersections <- unique(missing_plot$plotlist[[2]]$data[c("name", "size")])

  expect_equal(nrow(intersections), 5L)
  expect_gt(min(intersections$size), 0L)

  binary <- data.frame(
    A = c("Yes", "No", "Yes"),
    B = c("No", "Yes", "Yes")
  )
  result <- plt_upset(binary, vars = c("A", "B"), output = "data")

  expect_equal(as.character(result$intersect_group), c("A", "B", "A/B"))
})

test_that("plt_upset saves its plot, the combined one for all, and nothing for data", {
  skip_if_not_installed("ggVennDiagram")
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_upset)), 1), "save")
  f <- withr::local_tempfile(fileext = ".pdf")
  for (output in c("venn", "upset", "both")) {
    out <- cli::cli_fmt(p <- suppressWarnings(plt_upset(
      bmi_missing_data(), vars = c("BMI_1", "BMI_2", "BMI_3"), levels = NA,
      output = output, save = list(filename = f))))
    expect_saved_at_plot_size(out, p)
  }
  out <- cli::cli_fmt(res <- suppressWarnings(plt_upset(
    bmi_missing_data(), vars = c("BMI_1", "BMI_2", "BMI_3"), levels = NA,
    output = "all", save = list(filename = f))))
  expect_saved_at_plot_size(out, res$combined)
  expect_error(plt_upset(bmi_missing_data(), vars = c("BMI_1", "BMI_2", "BMI_3"),
                         levels = NA, output = "data",
                         save = list(filename = f)), "no plot")
})

test_that("plt_upset recognizes original missing values without coercion", {
  skip_if_not_installed("ggVennDiagram")
  skip_if_not_installed("haven")
  columns <- list(
    numeric = c(1, NA_real_, NaN, 4),
    spss = haven::labelled_spss(c(1, 99, 98, NA), na_values = 99,
                               na_range = c(97, 98)),
    explicit_na = structure(c(1L, 2L, NA_integer_, 1L),
                            levels = c("x", NA_character_), class = "factor"),
    complex = c(1i, NA_complex_, NaN + 1i, 2i),
    time = as.POSIXlt(c("2026-01-01", NA, "2026-01-03", NA), tz = "UTC"),
    span = as.difftime(c(1, NA, 3, NA), units = "days")
  )
  for (column in columns) {
    data <- data.frame(B = rep("No", 4))
    data[["A"]] <- column
    original <- data
    result <- plt_upset(data, c("A", "B"), levels = NA, output = "data")
    expect_identical(as.character(result$intersect_group),
                     ifelse(is.na(column), "A", "None"))
    expect_identical(result$A, column)
    expect_identical(data, original)
  }
  mixed <- data.frame(A = c("Yes", NA, "No"), B = c("No", "Yes", NA))
  result <- plt_upset(mixed, c("A", "B"), levels = c("Yes", NA), output = "data")
  expect_identical(as.character(result$intersect_group), c("A", "A/B", "B"))
})

test_that("plt_upset restores serialized set-membership methods", {
  skip_if_not_installed("ggVennDiagram")
  skip_if_not_installed("bit64")
  skip_if_not_installed("haven")
  fixture <- withr::local_tempfile(fileext = ".rds")
  script <- withr::local_tempfile(fileext = ".R")
  saveRDS(list(
    integer64 = bit64::as.integer64(c("9007199254740993", NA, "9007199254740994")),
    spss = haven::labelled_spss(c(1, 99, NA_real_), na_values = 99)
  ), fixture)
  quote_r <- function(x) paste(deparse(x), collapse = "\n")
  writeLines(c(
    "options(device = function(...) grDevices::pdf(NULL, ...))",
    paste0(".libPaths(", quote_r(.libPaths()), ")"),
    "env <- new.env(parent = baseenv()); env[['%>%']] <- dplyr::`%>%`",
    paste0("sys.source(", quote_r(file.path(getNamespaceInfo(asNamespace("UtilsR"), "path"),
                                          "R/plt_upset.R")), ", envir = env)"),
    paste0("fixture <- readRDS(", quote_r(fixture), ")"),
    "stopifnot(!'bit64' %in% loadedNamespaces(), !'haven' %in% loadedNamespaces())",
    "for (key in names(fixture)) {",
    "  data <- data.frame(B = rep('No', 3)); data[['A']] <- fixture[[key]]",
    "  res <- env[['plt_upset']](data, c('A', 'B'), levels = NA, output = 'data', colors = 'red')",
    "  expected <- if (key == 'integer64') c('None', 'A', 'None') else c('None', 'A', 'A')",
    "  stopifnot(identical(as.character(res[['intersect_group']]), expected))",
    "}"
  ), script)
  output <- system2(file.path(R.home("bin"), "Rscript"),
                    c("--vanilla", shQuote(script)), stdout = TRUE, stderr = TRUE)
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
})
