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
    "env <- new.env(parent = globalenv()); env[['%>%']] <- dplyr::`%>%`",
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

test_that("plt_upset preserves input row-index columns and element identities", {
  skip_if_not_installed("ggVennDiagram")
  data <- data.frame(A = c("Yes", "No", "Yes"), B = c("No", "Yes", "Yes"),
                     .row_id = c("keep1", "keep2", "keep3"))
  original <- data
  result <- plt_upset(data, c("A", "B"), output = "data")
  expect_identical(result[names(data)], data)
  expect_identical(data, original)
  result <- plt_upset(list(.element = c("gene1", "gene2"),
                           .element.1 = c("gene2", "gene3")), output = "data")
  expect_identical(result$.element.2, c("gene1", "gene2", "gene3"))
  expect_identical(result$.element, c("Yes", "Yes", "No"))
  expect_identical(result$.element.1, c("No", "Yes", "Yes"))
})

test_that("plt_upset distinguishes colliding set and intersection labels", {
  skip_if_not_installed("ggVennDiagram")
  result <- plt_upset(list(None = "x", B = "y"), output = "data")
  expect_identical(as.character(result$intersect_group), c("None", "B"))
  expect_identical(tail(levels(result$intersect_group), 1L), "None.1")
  result <- plt_upset(list(A = "x", B = "y", "A/B" = "z"), output = "data")
  expect_identical(as.character(result$intersect_group), c("A", "B", "A/B"))
  expect_identical(anyDuplicated(levels(result$intersect_group)), 0L)
  result <- plt_upset(list(A = "x", B = "y"), set.labels = c(A = "same", B = "same"), output = "data")
  expect_identical(as.character(result$intersect_group), c("same", "same.1"))
  plot <- suppressMessages(plt_upset(list(A = "x", B = "y"),
                                    set.labels = c(A = "same", B = "same"), output = "upset"))
  built <- ggplot2::ggplot_build(plot$plotlist[[1]])
  expect_identical(as.character(built$layout$panel_scales_y[[1]]$get_labels()), c("same", "same"))
  venn <- suppressMessages(plt_upset(list(A = "x", B = "y"),
                                    set.labels = c(A = "same", B = "same"), output = "venn"))
  expect_identical(ggplot2::ggplot_build(venn)$data[[3]]$label, c("same", "same"))
  ordinary <- plt_upset(list(B = c("x", "y"), A = c("y", "z")), output = "data")
  expect_identical(as.character(ordinary$intersect_group), c("B", "B/A", "A"))
})

test_that("plt_upset rejects ambiguous names and unsupported column shapes", {
  skip_if_not_installed("ggVennDiagram")
  data <- data.frame(A = c("Yes", "No"), B = c("No", "Yes"))
  expect_error(plt_upset(data, "A", output = "data"), "at least two")
  expect_error(plt_upset(data, c("A", "A"), output = "data"), "unique")
  expect_error(plt_upset(data, c("A", NA_character_), output = "data"), "non-missing")
  expect_error(plt_upset(setNames(list(1, 2), c("A", NA_character_))), "non-missing")
  expect_error(plt_upset(setNames(list(1, 2), c("A", "A"))), "unique")
  expect_error(plt_upset(setNames(list(1, 2), c("A", "\u00a0"))), "non-empty")
  expect_error(plt_upset(list(A = list(1, 2), B = 1:2)), "member vectors")
  expect_error(plt_upset(list(A = as.Date("2020-01-01"), B = as.Date("2020-01-02"))), "member vectors")
  data$A <- matrix("Yes", nrow = 2, ncol = 2)
  expect_error(plt_upset(data, c("A", "B"), output = "data"), "one-dimensional")
  data$A <- list("Yes", c("Yes", "No"))
  expect_error(plt_upset(data, c("A", "B"), output = "data"), "one-dimensional")
  data$A <- c("Yes", "No"); data$intersect_group <- c("keep1", "keep2")
  expect_error(plt_upset(data, c("A", "B"), output = "data"), "already contains.*intersect_group")
})

test_that("plt_upset validates display maps and style values", {
  skip_if_not_installed("ggVennDiagram")
  sets <- list(A = 1:2, B = 2:3)
  for (mapping in list(c("x", "y"), setNames(c("x", "y"), c("A", "A")),
                       c(A = NA_character_), c(A = "\u2003"))) {
    expect_error(plt_upset(sets, output = "data", set.labels = mapping), "set.labels")
  }
  for (palette in list(character(), NA_character_, "not-a-colour")) {
    expect_error(plt_upset(sets, output = "data", colors = palette), "colors")
  }
  for (alpha in list(NA_real_, -0.1, 1.1, c(0.2, 0.5))) {
    expect_error(plt_upset(sets, output = "data", venn.alpha = alpha), "venn.alpha")
  }
  expect_no_error(plt_upset(sets, output = "data", set.labels = character(), colors = c(red = "red")))
  expect_no_error(plt_upset(sets, output = "data", vars = list("ignored"), levels = list("ignored")))
  data <- data.frame(A = c("Yes", "No"), B = c("No", "Yes"))
  expect_error(plt_upset(data, c("A", "B"), levels = list("Yes"), output = "data"), "levels")
})

test_that("plt_upset combined outputs retain Venn and UpSet panels", {
  skip_if_not_installed("ggVennDiagram")
  sets <- list(A = 1:4, B = 3:6, C = c(2, 4, 7))
  for (output in c("both", "all")) {
    expect_no_warning(result <- suppressMessages(plt_upset(sets, output = output)))
    plot <- if (output == "all") result$combined else result
    expect_s3_class(plot, "patchwork")
    expect_no_warning(render_upset(plot))
    expect_gte(length(plot$patches$plots), 1L)
    if (output == "all") {
      expect_s3_class(result$venn, "ggplot")
      expect_s3_class(result$upset, "upset_plot")
      expect_equal(nrow(result$data), 7L)
    }
  }
})

test_that("plt_upset handles the Venn dimension limit explicitly", {
  skip_if_not_installed("ggVennDiagram")
  sets <- setNames(rep(list(1:2), 8), LETTERS[1:8])
  expect_error(plt_upset(sets, output = "venn"), "2 to 7")
  expect_no_warning(plot <- suppressMessages(plt_upset(sets, output = "upset")))
  expect_s3_class(plot, "upset_plot")
  expect_no_warning(render_upset(plot))
  expect_no_warning(result <- suppressMessages(plt_upset(sets, output = "all")))
  expect_null(result$venn)
  expect_s3_class(result$combined, "upset_plot")
  expect_equal(nrow(result$data), 2L)
})

test_that("plt_upset rejects plots without members but retains grouped data", {
  skip_if_not_installed("ggVennDiagram")
  empty <- list(A = character(), B = character())
  for (output in c("venn", "upset", "both", "all")) {
    expect_error(plt_upset(empty, output = output), "No set members")
  }
  expect_equal(nrow(plt_upset(empty, output = "data")), 0L)
  data <- data.frame(A = rep("No", 3), B = rep("No", 3))
  result <- plt_upset(data, c("A", "B"), output = "data")
  expect_identical(as.character(result$intersect_group), rep("None", 3))
})

test_that("plt_upset category fills use set colours and requested alpha", {
  skip_if_not_installed("ggVennDiagram")
  sets <- list(A = 1:4, B = 3:6, C = c(2, 4, 7))
  palette <- c("#FF0000", "#00FF00", "#0000FF")
  for (alpha in c(0.2, 0.8)) {
    plot <- suppressMessages(plt_upset(sets, output = "venn", venn.fill = "category",
                                      colors = palette, venn.alpha = alpha))
    regions <- ggplot2::ggplot_build(plot)$data[[1]]
    expect_setequal(regions$fill, palette)
    expect_identical(unique(regions$alpha), alpha)
    expect_equal(length(unique(regions$group)), 3L)
    expect_no_warning(render_upset(plot))
  }
})

test_that("plt_upset unfilled Venn regions are transparent", {
  skip_if_not_installed("ggVennDiagram")
  plot <- suppressMessages(plt_upset(list(A = 1:3, B = 2:4), output = "venn", venn.fill = "none"))
  fill <- unique(ggplot2::ggplot_build(plot)$data[[1]]$fill)
  expect_true(all(grDevices::col2rgb(fill, alpha = TRUE)[4, ] == 0))
  expect_no_warning(render_upset(plot))
})
