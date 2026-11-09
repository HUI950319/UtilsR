# Observe constructed reports without replacing their statistical calculations.
# As at an interactive console: lv() prints its HTML tables only there, and
# gtsummary builds the grouped table's gt object only when it is printed.
capture_lv <- function(expr) {
  withr::local_options(rlang_interactive = TRUE)
  tables <- list()
  original_gt <- gt::gt
  testthat::local_mocked_bindings(
    gt = function(data, ...) {
      tables[[length(tables) + 1L]] <<- data
      original_gt(data, ...)
    },
    .package = "gt"
  )
  output <- utils::capture.output(suppressMessages(value <- withVisible(expr)))
  list(tables = tables, output = output, value = value)
}

test_that("cross-tabulation separates original columns from frequency columns", {
  data <- data.frame(n = c(10, 90, 90), category = c("a", "b", "b"))
  single <- capture_lv(lv(data, count = n))
  text <- paste(single$output, collapse = "\n")
  expect_match(text, "33.3%", fixed = TRUE)
  expect_match(text, "66.7%", fixed = TRUE)
  expect_false(grepl("n_pct", text, fixed = TRUE))

  for (name in c("n", "pct", "n_pct")) {
    names(data)[1L] <- name
    vars <- c(name, "category")
    result <- capture_lv(lv(data, count = vars))
    wide <- result$tables[[1L]]
    expect_identical(wide[["a"]], c("1 (100.0%)", "0", "1 (33.3%)"))
    expect_identical(wide[["b"]], c("0", "2 (100.0%)", "2 (66.7%)"))
    expect_identical(wide[["Total"]], c("1", "2", "3"))
    expect_identical(result$value$value, data)
    expect_false(result$value$visible)
  }
})

test_that("a Total category is retained beside the separate row total", {
  data <- data.frame(g = c("A", "A", "B"), x = c("Total", "x", "Total"))
  result <- capture_lv(lv(data, count = c(g, x)))
  wide <- result$tables[[1L]]
  expect_identical(wide[["Total"]], c("1 (50.0%)", "1 (100.0%)", "2 (66.7%)"))
  expect_identical(wide[["Total_1"]], c("2", "1", "3"))
  expect_identical(names(wide), c("g", "Total", "x", "Total_1"))
})

test_that("cross-tabulation uses the requested variables on grouped input", {
  data <- data.frame(stratum = c("U", "V", "V"),
                     a = c("A", "A", "A"), b = c("X", "X", "Y"))
  grouped <- dplyr::group_by(data, stratum)
  result <- capture_lv(lv(grouped, count = c(a, b)))
  expect_identical(result$tables[[1L]][["X"]], c("2 (66.7%)", "2 (66.7%)"))
  expect_identical(result$tables[[1L]][["Y"]], c("1 (33.3%)", "1 (33.3%)"))
  expect_false("stratum" %in% names(result$tables[[1L]]))
  expect_identical(result$value$value, grouped)
})

test_that("lv preserves the caller's complete gtsummary theme", {
  original <- gtsummary::get_gtsummary_theme()
  withr::defer({
    gtsummary::reset_gtsummary_theme()
    suppressMessages(gtsummary::set_gtsummary_theme(original))
  })
  custom <- list("pkgwide-str:theme_name" = "caller theme",
                 "pkgwide-str:language" = "en")
  suppressMessages(gtsummary::set_gtsummary_theme(custom))
  before <- gtsummary::get_gtsummary_theme()
  data <- data.frame(g = c("A", "A", "B", "B"), x = 1:4)

  capture_lv(lv(data, x))
  expect_identical(gtsummary::get_gtsummary_theme(), before)
  capture_lv(lv(data, x, group = g))
  expect_identical(gtsummary::get_gtsummary_theme(), before)
  capture_lv(lv(data, count = g))
  expect_identical(gtsummary::get_gtsummary_theme(), before)

  # Setting the compact theme for its own tables is not announced.
  for (call in list(quote(lv(data, x)), quote(lv(data, x, group = g)))) {
    utils::capture.output(expect_no_message(eval(call), message = "Setting theme"))
  }

  # Explicit missing levels are adapted before reaching the table backend.
  invalid <- data.frame(x = factor(c("a", NA), exclude = NULL))
  capture_lv(lv(invalid))
  expect_identical(gtsummary::get_gtsummary_theme(), before)
})

test_that("group and count resolve column names before caller objects", {
  data <- data.frame(g = c("A", "A", "B", "B"), x = 1:4)
  g <- 99
  grouped <- capture_lv(lv(data, x, group = g))
  expect_true(any(vapply(grouped$tables, function(x) {
    all(c("stat_1", "stat_2") %in% names(x)) && !"stat_3" %in% names(x)
  }, logical(1))))
  counted <- capture_lv(lv(data, count = g))
  expect_match(paste(counted$output, collapse = "\n"), "A +2 +50\\.0%")

  column <- "g"
  wrapper <- function(input) capture_lv(lv(input, x, group = column))
  expect_true(any(vapply(wrapper(data)$tables, function(x) {
    all(c("stat_1", "stat_2") %in% names(x))
  }, logical(1))))
  vars <- c("g", "x")
  expect_identical(capture_lv(lv(data, count = vars))$value$value, data)
  expect_identical(capture_lv(lv(data, count = c(column, "x")))$value$value, data)
})

test_that("invalid group and count controls cannot silently disable a mode", {
  data <- data.frame(g = c("A", "A", "B", "B"), x = 1:4)
  for (bad in list(FALSE, TRUE, 1, character(), NA_character_, c("g", "x"),
                   matrix("g"), list("g"))) {
    expect_error(capture_lv(lv(data, group = bad)), "group")
  }
  for (bad in list(FALSE, 1, character(), NA_character_, c("g", "g"),
                   matrix("g"), list("g"))) {
    expect_error(capture_lv(lv(data, count = bad)), "count")
  }
  expect_error(capture_lv(lv(data, count = c(g, g))), "distinct")
  expect_error(capture_lv(lv(data, group = "absent")), "not found")
})

test_that("Seurat controls use the same name resolution and preserve the object", {
  skip_if_not_installed("SeuratObject")
  counts <- matrix(rep(1:5, 8), nrow = 5,
                   dimnames = list(paste0("f", 1:5), paste0("c", 1:8)))
  object <- SeuratObject::CreateSeuratObject(Matrix::Matrix(counts, sparse = TRUE))
  object[["batch"]] <- rep(c("A", "B"), each = 4)
  object[["score"]] <- seq_len(8)
  object[["group_var"]] <- rep(c("u", "v"), 4)
  object[["count_vars"]] <- rep(c("u", "v"), 4)
  SeuratObject::Idents(object) <- rep(c("I", "II"), each = 4)
  before <- object

  column <- "batch"
  literal <- capture_lv(lv(object, score, group = "batch", add_cell_stats = FALSE))
  external <- capture_lv(lv(object, score, group = column, add_cell_stats = FALSE))
  expected <- capture_lv(lv(object[[]], score, group = "batch"))
  expect_equal(literal$tables, expected$tables)
  expect_equal(external$tables, expected$tables)
  expect_identical(external$value$value, before)
  expect_false(external$value$visible)

  vars <- c("batch", "orig.ident")
  counted <- capture_lv(lv(object, count = vars, add_cell_stats = FALSE))
  expect_identical(counted$tables[[1L]][["SeuratProject"]],
                   c("4 (100.0%)", "4 (100.0%)", "8 (100.0%)"))
  identity <- TRUE
  by_ident <- capture_lv(lv(object, score, group = identity, add_cell_stats = FALSE))
  expect_equal(by_ident$tables,
               capture_lv(lv(object, score, group = TRUE,
                             add_cell_stats = FALSE))$tables)
  expect_identical(object, before)
})

test_that("column selection retains aliases without altering input", {
  data <- data.frame(g = c("A", "A", "B", "B"), x = 1:4, other = 5:8)
  attr(data, "source") <- "unchanged"
  before <- data
  result <- capture_lv(lv(data, renamed = x))
  summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  expect_identical(summary$vars, "renamed")
  expect_equal(summary$n_unique, 4)
  expect_identical(result$value$value, before)
  expect_identical(data, before)
  grouped <- capture_lv(lv(data, renamed = x, group = g))
  expect_true(any(vapply(grouped$tables, function(x) {
    "label" %in% names(x) && any(grepl("renamed", x$label))
  }, logical(1))))
})

test_that("explicit empty selections do not expand to all columns", {
  data <- data.frame(g = c("A", "A", "B", "B"), x = 1:4)
  empty <- list(
    capture_lv(lv(data, dplyr::starts_with("absent"))),
    capture_lv(lv(data, pattern = "^absent$")),
    capture_lv(lv(data, g, group = g))
  )
  for (result in empty) {
    expect_length(result$tables, 0L)
    expect_identical(result$value$value, data)
    expect_false(result$value$visible)
  }
  all <- capture_lv(lv(data))
  summary <- Filter(function(x) "n_special" %in% names(x), all$tables)[[1L]]
  expect_identical(summary$vars, names(data))
})

test_that("pattern validation and override do not evaluate ignored selections", {
  data <- data.frame(x = 1:4, y = 5:8)
  expect_warning(
    result <- capture_lv(lv(data, stop("ignored"), pattern = "^y$")),
    "overrides"
  )
  summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  expect_identical(summary$vars, "y")
  for (pattern in list(NA_character_, c("x", "y"), 1, list("x"), "[")) {
    expect_error(capture_lv(lv(data, pattern = pattern)), "pattern")
  }
})

test_that("global data shortcuts still inspect and return the original dataset", {
  data <- data.frame(x = 1:4, y = 5:8)
  rlang::local_bindings(data = data, .env = globalenv())
  result <- capture_lv(lv(x))
  summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  expect_identical(summary$vars, "x")
  expect_identical(result$value$value, data)
  expect_identical(get("data", envir = globalenv()), data)
})

test_that("empty datasets return unchanged without reports or theme changes", {
  zero_rows <- data.frame(g = character(), x = numeric())
  zero_cols <- data.frame(row.names = seq_len(2))
  before <- gtsummary::get_gtsummary_theme()
  results <- list(capture_lv(lv(zero_rows)),
                  capture_lv(lv(zero_rows, group = g)),
                  capture_lv(lv(zero_rows, count = c(g, x))),
                  capture_lv(lv(zero_cols)))
  for (i in seq_along(results)) {
    result <- results[[i]]
    expect_length(result$tables, 0L)
    expect_identical(result$value$value, if (i == 4L) zero_cols else zero_rows)
    expect_false(result$value$visible)
  }
  expect_identical(gtsummary::get_gtsummary_theme(), before)
})

test_that("knitr receives native tables once in an asis chunk", {
  skip_if_not_installed("knitr")
  previous <- knitr::opts_knit$get("rmarkdown.pandoc.to")
  withr::defer(knitr::opts_knit$set(rmarkdown.pandoc.to = previous))
  knitr::opts_knit$set(rmarkdown.pandoc.to = "html")
  markdown <- knitr::knit(text = c(
    "```{r, results='asis', echo=FALSE, message=FALSE}",
    "d <- data.frame(x=c('ok','unknown'))",
    "stopifnot(identical(lv(d), d))",
    "```"
  ), quiet = TRUE)
  tables <- gregexpr("<table ", markdown, fixed = TRUE)[[1L]]
  expect_length(tables, 2L)
  expect_false(grepl("## <div", markdown, fixed = TRUE))
  expect_false(grepl("# A tibble", markdown, fixed = TRUE))

  for (call in c("lv(d, count=c(g,x))", "lv(d, x, group=g)")) {
    document <- knitr::knit(text = c(
      "```{r, results='asis', echo=FALSE, message=FALSE}",
      "d <- data.frame(g=c('A','A','B','B'),x=c('a','b','a','b'))",
      call, "```"
    ), quiet = TRUE)
    expect_true(grepl("<table ", document, fixed = TRUE))
    expect_false(grepl("# A tibble", document, fixed = TRUE))
  }

  knitr::opts_knit$set(rmarkdown.pandoc.to = "latex")
  latex <- knitr::knit(text = c(
    "```{r, results='asis', echo=FALSE, message=FALSE}",
    "lv(data.frame(x=c('ok','unknown')))",
    "```"
  ), quiet = TRUE)
  expect_true(grepl("\\begin{table}", latex, fixed = TRUE))
  expect_false(grepl("<table", latex, fixed = TRUE))
})

test_that("knitted reports carry no per-variable headings without listings", {
  data <- data.frame(a = c("x", "y", "x"), b = 1:3)
  withr::local_options(knitr.in.progress = TRUE)
  testthat::local_mocked_bindings(.lv_print_report = function(x) invisible(x),
                                  .package = "UtilsR")
  utils::capture.output(expect_no_message(lv(data), message = "summary for"))
})

test_that("suggested filters escape column names and character values", {
  values <- c('a"b', "c\\d", "line\nbreak", "", "a'b")
  for (column in c("a b", "a`b")) {
    data <- stats::setNames(data.frame(values), column)
    result <- capture_lv(lv(data))
    summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
    expression <- parse(text = as.character(summary$unique))[[1L]]
    expect_identical(expression[[1L]], quote(get_flt))
    expect_identical(expression[[2L]][[2L]], as.name(column))
    expect_identical(eval(expression[[2L]][[3L]]), sort(values, method = "radix"))
    expect_true(all(eval(expression[[2L]], envir = data)))
    expect_identical(result$value$value, data)
  }
})

test_that("blank cross-tabulation categories remain distinct and renderable", {
  data <- data.frame(g = c("A", "A", "B"), x = c("", "", "(blank)"))
  result <- capture_lv(lv(data, count = c(g, x)))
  wide <- result$tables[[1L]]
  expect_identical(names(wide), c("g", "(blank)", "(blank)_1", "Total"))
  expect_identical(wide[["(blank)"]], c("2 (100.0%)", "0", "2 (66.7%)"))
  expect_identical(wide[["(blank)_1"]], c("0", "1 (100.0%)", "1 (33.3%)"))
  expect_identical(wide[["Total"]], c("2", "1", "3"))
  expect_identical(result$value$value, data)
})

test_that("date-time columns with more than ten values are summarized", {
  data <- data.frame(date = as.Date("2020-01-01") + 0:10,
                     time = as.POSIXct("2020-01-01", tz = "UTC") + 0:10 * 3600)
  result <- capture_lv(lv(data))
  summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  expect_identical(summary$vars, c("date", "time"))
  expect_equal(summary$n_unique, c(11, 11))
  expect_match(as.character(summary$unique[1L]), "2020-01-01", fixed = TRUE)
  expect_identical(result$value$value, data)
})

test_that("entirely missing character columns are summarized in every mode", {
  data <- data.frame(g = c("A", "A", "B", "B"), x = 1:4,
                     empty = rep(NA_character_, 4))
  default <- capture_lv(lv(data))
  summary <- Filter(function(x) "n_special" %in% names(x), default$tables)[[1L]]
  expect_equal(summary$n_na[summary$vars == "empty"], 4)
  expect_identical(default$value$value, data)
  grouped <- capture_lv(lv(data, x, empty, group = g))
  expect_true(any(vapply(grouped$tables, function(x) {
    "label" %in% names(x) && any(grepl("empty", x$label))
  }, logical(1))))
  expect_identical(grouped$value$value, data)
})

# Reports handed to knitr, including the styled frequency table.
capture_reports <- function(expr) {
  reports <- list()
  withr::local_options(knitr.in.progress = TRUE)
  testthat::local_mocked_bindings(
    .lv_print_report = function(x) {
      reports[[length(reports) + 1L]] <<- x
      invisible(x)
    },
    .package = "UtilsR"
  )
  utils::capture.output(suppressMessages(expr))
  reports
}

test_that("explicit factor NA levels stay distinct from missing groups", {
  missing_label <- "\u7f3a\u5931"
  for (classes in list("factor", c("ordered", "factor"))) {
    data <- data.frame(value = c("usual", "explicit", "missing", "literal",
                                 "literal_missing", "suffix", "usual"))
    data$group <- structure(c(1L, 2L, NA_integer_, 3L, 4L, 5L, 1L),
      levels = c("x", NA_character_, "<NA>", missing_label, "<NA>_1"),
      class = classes)
    before <- data
    reports <- capture_reports(lv(data, value, group = group))
    header <- reports[[1L]]$table_styling$header
    groups <- header[grepl("^stat_[1-9]", header$column), ]
    expect_identical(groups$modify_stat_level,
      c("x", "<NA>_2", "<NA>", missing_label, "<NA>_1",
        paste0(missing_label, "_1")))
    expect_equal(groups$modify_stat_n, c(2, 1, 1, 1, 1, 1))
    body <- reports[[1L]]$table_body
    expect_identical(body$stat_2[body$label == "explicit"], "1 (100%)")
    expect_identical(body$stat_6[body$label == "missing"], "1 (100%)")
    expect_identical(data, before)

    without_missing <- data[-3L, , drop = FALSE]
    reports <- capture_reports(lv(without_missing, value, group = group))
    header <- reports[[1L]]$table_styling$header
    groups <- header[grepl("^stat_[1-9]", header$column), ]
    expect_equal(sum(groups$modify_stat_n), 6)
    expect_equal(groups$modify_stat_n[groups$modify_stat_level == "<NA>_2"], 1)
  }
})

test_that("explicit factor NA levels remain distinct in summaries and filters", {
  data <- data.frame(group = structure(c(1L, 2L, NA_integer_, 1L),
    levels = c("x", NA_character_), class = "factor"))
  before <- data
  reports <- capture_reports(lv(data, group))
  summary <- reports[[1L]][["_data"]]
  expect_equal(summary$n_unique, 2)
  expect_equal(summary$n_na, 1)
  expr <- parse(text = as.character(summary$unique))[[1L]]
  expect_identical(eval(expr[[2L]], envir = data), c(TRUE, TRUE, FALSE, TRUE))
  body <- reports[[2L]][["_data"]]
  expect_true(any(body$label == "<NA>" & body$row_type == "level", na.rm = TRUE))
  expect_true(any(body$row_type == "missing"))
  expect_identical(data, before)
})

test_that("cross-tabulations separate explicit factor NA levels and missing values", {
  missing_label <- "\u7f3a\u5931"
  data <- data.frame(value = c("usual", "explicit", "missing", "literal",
                               "literal_missing", "suffix", "usual"))
  data$group <- structure(c(1L, 2L, NA_integer_, 3L, 4L, 5L, 1L),
    levels = c("x", NA_character_, "<NA>", missing_label, "<NA>_1"),
    class = "factor")
  before <- data

  one <- capture_reports(lv(data, count = group))[[1L]][["_data"]]
  expect_equal(one$n[as.character(one$group) == "<NA>_2"], 1)
  expect_equal(one$n[as.character(one$group) == paste0(missing_label, "_1")], 1)

  wide <- capture_reports(lv(data, count = c(value, group)))[[1L]][["_data"]]
  expect_identical(wide[["<NA>_2"]][wide$value == "explicit"], "1 (100.0%)")
  expect_identical(wide[[paste0(missing_label, "_1")]][wide$value == "missing"],
                   "1 (100.0%)")
  reverse <- capture_reports(lv(data, count = c(group, value)))[[1L]][["_data"]]
  expect_identical(reverse$explicit[reverse$group == "<NA>_2"], "1 (100.0%)")
  expect_identical(reverse$missing[reverse$group == paste0(missing_label, "_1")],
                   "1 (100.0%)")
  expect_identical(data, before)
})

test_that("explicit factor NA levels preserve grouped input objects", {
  data <- data.frame(value = c("usual", "level", "missing", "usual"))
  data$group <- structure(c(1L, 2L, NA_integer_, 1L),
                          levels = c("x", NA_character_), class = "factor")
  inputs <- list(dplyr::group_by(data, value), dplyr::rowwise(data))
  if (requireNamespace("data.table", quietly = TRUE)) {
    inputs[[3L]] <- data.table::as.data.table(data)
  }
  for (input in inputs) {
    before <- if (inherits(input, "data.table")) data.table::copy(input) else input
    report <- capture_reports(lv(input, value, group = group))[[1L]]
    header <- report$table_styling$header
    groups <- header[grepl("^stat_[1-9]", header$column), ]
    expect_equal(groups$modify_stat_n, c(2, 1, 1))
    wide <- capture_reports(lv(input, count = c(value, group)))[[1L]][["_data"]]
    expect_identical(wide[["<NA>"]][wide$value == "level"], "1 (100.0%)")
    expect_identical(wide[["\u7f3a\u5931"]][wide$value == "missing"], "1 (100.0%)")
    expect_identical(input, before)
  }
})

test_that("a sole explicit NA level produces a usable filter", {
  data <- data.frame(group = structure(c(1L, NA_integer_, 1L),
    levels = NA_character_, class = "factor"))
  summary <- capture_reports(lv(data))[[1L]][["_data"]]
  expect_equal(summary$n_unique, 1)
  expect_equal(summary$n_na, 1)
  expr <- parse(text = as.character(summary$unique))[[1L]]
  expect_identical(eval(expr[[2L]], envir = data), c(TRUE, FALSE, TRUE))
})

filled_labels <- function(gt_tbl, color) {
  styles <- gt_tbl[["_styles"]]
  fill <- vapply(styles$styles, function(s) {
    colors <- unlist(lapply(s, function(x) x$color))
    if (length(colors)) colors[[1L]] else NA_character_
  }, character(1))
  rows <- styles$rownum[styles$colname == "label" & fill %in% color]
  as.character(gt_tbl[["_data"]]$label[sort(unique(rows))])
}

test_that("explicit factor NA levels do not acquire special-value highlighting", {
  data <- data.frame(group = structure(c(1L, 2L, 3L, NA_integer_),
    levels = c("x", NA_character_, "<NA>"), class = "factor"))
  reports <- capture_reports(lv(data))
  expect_equal(reports[[1L]][["_data"]]$n_special, 1)
  expect_identical(filled_labels(reports[[2L]], "#BBDEFB"), "<NA>")
})

test_that("special-value highlights follow the special-value counts", {
  data <- data.frame(
    v = c("Blanket", "Unknownness", "n/a", "Missing", "Not stated", "ok"),
    unknown_flag = c(1, 1, 2, 2, 3, 3)
  )
  reports <- capture_reports(lv(data))
  summary <- reports[[1L]][["_data"]]
  expect_equal(summary$n_special, c(3, 0))
  highlighted <- filled_labels(reports[[2L]], "#BBDEFB")
  expect_setequal(highlighted, c("n/a", "Missing", "Not stated"))
})

test_that("count shades mean one thing each and are named in a legend", {
  data <- data.frame(v = c(rep("a", 88), rep("b", 3), rep("c", 7), "Unknown", NA))
  styled <- capture_reports(lv(data))[[2L]]
  expect_identical(filled_labels(styled, "#FFCDD2"), "缺失")
  expect_identical(filled_labels(styled, "#BBDEFB"), "Unknown")
  styles <- styled[["_styles"]]
  fill <- vapply(styles$styles, function(s) {
    s[["cell_fill"]][["color"]] %||% NA_character_
  }, character(1))
  body <- styled[["_data"]]
  shaded <- function(color) {
    as.character(body$label[styles$rownum[styles$colname == "stat_0" & fill %in% color]])
  }
  expect_setequal(shaded("#FFB74D"), c("b", "Unknown"))
  expect_identical(shaded("#FFE0B2"), "c")
  # the missing row's share is not a category's
  missing_row <- which(body$row_type == "missing")
  expect_false(any(styles$rownum == missing_row & styles$colname == "stat_0" &
                     !is.na(fill)))
  note <- paste(unlist(styled[["_source_notes"]]), collapse = " ")
  expect_match(note, "shares 1-5% orange, 5-10% light orange", fixed = TRUE)
  expect_match(note, "missing rows red, Unknown/Blank/N/A values blue", fixed = TRUE)
  expect_false(grepl("below 1%", note, fixed = TRUE))
})

test_that("columns with more than 100 categories stay out of summary tables", {
  data <- data.frame(id = sprintf("P%03d", 1:150), x = rep(1:3, 50),
                     g = rep(c("A", "B"), 75),
                     f = factor(rep("a", 150), levels = as.character(1:101)))
  reports <- capture_reports(lv(data))
  expect_identical(reports[[1L]][["_data"]]$vars, c("id", "x", "g", "f"))
  expect_equal(reports[[1L]][["_data"]]$n_unique[1L], 150)
  expect_identical(unique(reports[[2L]][["_data"]]$variable), c("x", "g"))
  utils::capture.output(
    expect_message(lv(data), "more than 100 categories")
  )

  grouped <- capture_reports(lv(data, id, x, f, group = g))
  expect_identical(unique(grouped[[1L]]$table_body$variable), "x")
  only_id <- capture_reports(lv(data, id, group = g))
  expect_length(only_id, 0L)
  expect_length(capture_reports(lv(data, id)), 1L)
})

test_that("vectors and matrices are inspected; column names still select", {
  summary_of <- function(result) {
    Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  }
  data <- data.frame(a = 1:5, b = letters[1:5], c = 6:10)
  rlang::local_bindings(data = data, .env = globalenv())

  numbers <- capture_lv(lv(1:2))
  expect_equal(summary_of(numbers)$n_unique, 2)
  expect_false(any(c("a", "b") %in% summary_of(numbers)$vars))
  expect_identical(numbers$value$value, 1:2)
  expect_false(numbers$value$visible)
  letters_in <- capture_lv(lv(c("x", "y", "x")))
  expect_equal(summary_of(letters_in)$n_unique, 2)
  matrix_in <- as.matrix(data.frame(p = 1:3, q = 4:6))
  matrix_out <- capture_lv(lv(matrix_in))
  expect_identical(summary_of(matrix_out)$vars, c("p", "q"))
  expect_identical(matrix_out$value$value, matrix_in)

  expect_identical(summary_of(capture_lv(lv("b")))$vars, "b")
  columns <- c("a", "b")
  expect_identical(summary_of(capture_lv(lv(columns)))$vars, c("a", "b"))
  a <- 99
  by_name <- summary_of(capture_lv(lv(a)))
  expect_identical(by_name$vars, "a")
  expect_equal(by_name$n_unique, 5)
})

test_that("caller vectors select columns without tidyselect deprecation warnings", {
  withr::local_options(lifecycle_verbosity = "warning")
  summary_of <- function(result) {
    Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  }
  data <- data.frame(a = 1:5, b = letters[1:5], c = 6:10)
  rlang::local_bindings(data = data, .env = globalenv())
  vars <- c("a", "b")
  idx <- 3L
  expect_no_warning(selected <- capture_lv(lv(data, vars)))
  expect_identical(summary_of(selected)$vars, c("a", "b"))
  expect_no_warning(combined <- capture_lv(lv(data, c(idx, vars))))
  expect_identical(summary_of(combined)$vars, c("c", "a", "b"))
  expect_no_warning(dropped <- capture_lv(lv(data, -vars)))
  expect_identical(summary_of(dropped)$vars, "c")
  expect_no_warning(renamed <- capture_lv(lv(data, first = idx)))
  expect_identical(summary_of(renamed)$vars, "first")
  expect_no_warning(shortcut <- capture_lv(lv(vars)))
  expect_identical(summary_of(shortcut)$vars, c("a", "b"))
  # Column names still win over caller objects of the same name.
  a <- "c"
  expect_identical(summary_of(capture_lv(lv(data, a)))$vars, "a")
})

test_that("without default data, vectors are inspected and typos are named", {
  rlang::local_bindings(data = 1, data_all = 1, .env = globalenv())
  result <- capture_lv(lv(mtcars$cyl))
  summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
  expect_equal(summary$n_unique, 3)
  expect_error(capture_lv(lv(not_an_object)), "not_an_object")
})

test_that("missing group values form their own group in the grouped table", {
  data <- data.frame(g = c("A", "A", "B", NA, NA, NA), x = 1:6)
  reports <- capture_reports(lv(data, x, group = g))
  header <- reports[[1L]]$table_styling$header
  labels <- header$label[grepl("^stat_", header$column)]
  expect_length(labels, 4L)
  expect_true(any(grepl("Overall", labels) & grepl("N = 6", labels)))
  expect_true(any(grepl("\u7f3a\u5931", labels) & grepl("N = 3", labels)))

  factor_data <- data.frame(g = factor(c("B", NA, "A"), levels = c("B", "A")),
                            x = 1:3)
  reports <- capture_reports(lv(factor_data, x, group = g))
  header <- reports[[1L]]$table_styling$header
  labels <- header$label[grepl("^stat_[1-9]", header$column)]
  expect_true(all(mapply(grepl, c("**B**", "**A**", "\u7f3a\u5931"), labels, fixed = TRUE)))
  expect_identical(factor_data$g, factor(c("B", NA, "A"), levels = c("B", "A")))
})

test_that("missing groups stay separate from a literal missing label", {
  missing_label <- "\u7f3a\u5931"
  data <- data.frame(g = c(missing_label, missing_label, NA, "A"),
                     x = c("known", "known", "unrecorded", "known"))
  before <- data
  reports <- capture_reports(value <- withVisible(lv(data, x, group = g)))
  header <- reports[[1L]]$table_styling$header
  groups <- header[grepl("^stat_[1-9]", header$column), ]
  expect_identical(groups$modify_stat_level,
                   c("A", missing_label, paste0(missing_label, "_1")))
  expect_equal(groups$modify_stat_n, c(1, 2, 1))
  body <- reports[[1L]]$table_body
  expect_identical(unname(unlist(body[body$label == "unrecorded", groups$column])),
                   c("0 (0%)", "0 (0%)", "1 (100%)"))
  expect_identical(value$value, before)
  expect_identical(value$visible, FALSE)
  expect_identical(data, before)
})

test_that("missing-group labels avoid occupied suffixes and unused factor levels", {
  missing_label <- "\u7f3a\u5931"
  group_levels <- c("B", paste0(missing_label, "_1"), missing_label,
                    paste0(missing_label, "_2"), "A")
  for (make_factor in list(factor, ordered)) {
    data <- data.frame(
      g = make_factor(c("B", missing_label, NA, "A", NA), levels = group_levels),
      x = c("known", "known", "unrecorded", "known", "unrecorded")
    )
    before <- data
    reports <- capture_reports(lv(data, x, group = g))
    header <- reports[[1L]]$table_styling$header
    groups <- header[grepl("^stat_[1-9]", header$column), ]
    observed <- groups$modify_stat_n > 0
    expect_identical(groups$modify_stat_level[observed],
                     c("B", missing_label, "A", paste0(missing_label, "_3")))
    expect_equal(groups$modify_stat_n[observed], c(1, 1, 1, 2))
    expect_equal(sum(groups$modify_stat_n), nrow(data))
    missing_column <- groups$column[groups$modify_stat_level == paste0(missing_label, "_3")]
    body <- reports[[1L]]$table_body
    expect_identical(unname(unlist(body[body$label == "unrecorded", missing_column])),
                     "2 (100%)")
    expect_identical(data, before)
  }
})

test_that("the grouped table names its grouping and size", {
  data <- data.frame(g = rep(c("A", "B"), 600), x = seq_len(1200))
  grouped <- capture_reports(lv(data, x, group = g))
  expect_identical(as.character(grouped[[1L]]$table_styling$caption),
                   "**Variable summary by g** (n = 1,200)")
})

test_that("two-way counts give one table of counts with row shares", {
  data <- data.frame(a = c("x", "x", "y", NA), b = c("u", "v", "u", "u"))
  reports <- capture_reports(lv(data, count = c(a, b)))
  expect_length(reports, 1L)
  tab <- reports[[1L]][["_data"]]
  expect_identical(tab$a, c("x", "y", NA, "Total"))
  expect_identical(tab$u, c("1 (50.0%)", "1 (100.0%)", "1 (100.0%)", "3 (75.0%)"))
  expect_identical(tab$v, c("1 (50.0%)", "0", "0", "1 (25.0%)"))
  expect_identical(tab$Total, c("2", "1", "1", "4"))
  expect_identical(reports[[1L]][["_spanners"]]$spanner_label[[1L]], "b")
})

test_that("missing rows give their share of the rows", {
  data <- data.frame(g = c("A", "A", "B", "B", "B"), x = c(1, NA, NA, 4, 5))
  default <- capture_reports(lv(data, x))
  body <- default[[2L]][["_data"]]
  expect_identical(body$stat_0[body$row_type == "missing"], "2 (40%)")
  grouped <- capture_reports(lv(data, x, group = g))
  shown <- gtsummary::as_tibble(grouped[[1L]], col_labels = FALSE)
  expect_identical(shown$stat_0[shown$label == "\u7f3a\u5931"], "2 (40%)")
})

test_that("console reports render each default table once", {
  data <- data.frame(x = c("a", "b", "a"), y = 1:3)
  withr::local_options(rlang_interactive = TRUE)
  output <- utils::capture.output(suppressMessages(lv(data)))
  tables <- gregexpr("<table", paste(output, collapse = "\n"), fixed = TRUE)[[1L]]
  expect_length(tables, 2L)
  expect_false(any(grepl("# A tibble", output, fixed = TRUE)))
})

test_that("HTML tables are not printed as source outside interactive sessions", {
  data <- data.frame(g = c("A", "A", "B"), x = c("a", "b", "a"), y = 1:3)
  withr::local_options(rlang_interactive = FALSE)
  for (call in list(quote(lv(data)), quote(lv(data, y, group = g)),
                    quote(lv(data, count = c(g, x))))) {
    expect_message(output <- utils::capture.output(eval(call)), "interactive")
    expect_false(any(grepl("<table", output, fixed = TRUE)))
  }
})

test_that("suggested filters keep literals runnable and count observed levels", {
  data <- data.frame(num = c(1:12, 0.5), int = rep(1:2, length.out = 13),
                     flag = rep(c(TRUE, FALSE), length.out = 13),
                     f = factor(rep("a", 13), levels = c("a", "b", "c")),
                     float = rep(c(0.1 + 0.2, 1), length.out = 13))
  reports <- capture_reports(lv(data))
  summary <- reports[[1L]][["_data"]]
  filters <- stats::setNames(as.character(summary$unique), summary$vars)
  expect_identical(filters[["num"]],
                   "get_flt(num %in% c(0.5, 1, 2, 3, 4, 5, 6, 7))  # +5 more")
  expect_identical(filters[["int"]], "get_flt(int %in% c(1, 2))")
  expect_identical(filters[["flag"]], "get_flt(flag %in% c(FALSE, TRUE))")
  expect_identical(filters[["f"]], 'get_flt(f %in% c("a"))')
  expect_equal(summary$n_unique, c(13, 2, 2, 1, 2))
  for (v in c("int", "flag", "f", "float")) {
    call <- parse(text = filters[[v]])[[1L]]
    expect_true(all(eval(call[[2L]], envir = data)))
  }
  labels <- as.character(reports[[2L]][["_data"]]$label)
  expect_true("f (factor, 1)" %in% labels)
})

test_that("suggested filters print as plain, sorted lines", {
  data <- data.frame(s = c("b", "c", "a", "b"), n = c(3, 1, 2, 3))
  out <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(data))))
  expect_true('get_flt(s %in% c("a", "b", "c"))' %in% out)
  expect_true("get_flt(n %in% c(1, 2, 3))" %in% out)
  expect_false(any(grepl("[1] get_flt", out, fixed = TRUE)))
})

test_that("suggested filters print on a light ground where the console shows colour", {
  data <- data.frame(s = c("b", "a"))
  filter <- 'get_flt(s %in% c("a", "b"))'
  withr::local_options(cli.num_colors = 256)
  out <- utils::capture.output(suppressMessages(lv(data)))
  line <- out[cli::ansi_strip(out) == filter]
  expect_length(line, 1L)
  expect_true(cli::ansi_has_any(line))
  withr::local_options(cli.num_colors = 1)
  expect_true(filter %in% utils::capture.output(suppressMessages(lv(data))))
})

test_that("count warns that it ignores selections and group", {
  data <- data.frame(g = c("A", "A", "B"), x = c("p", "q", "p"), y = 1:3)
  for (call in list(quote(lv(data, y, count = c(g, x))),
                    quote(lv(data, count = g, group = x)),
                    quote(lv(data, pattern = "^y$", count = g)))) {
    expect_warning(capture_lv(eval(call)), "count")
  }
  expect_no_warning(capture_lv(lv(data, count = c(g, x))))
})

test_that("time spans are summarized and list columns stay out of tables", {
  data <- data.frame(g = rep(c("A", "B"), length.out = 5), x = 1:5,
                     span = as.difftime(c(1:4, NA), units = "days"))
  data$items <- list(1, 2:3, "a", NULL, 4)
  reports <- capture_reports(lv(data))
  expect_identical(reports[[1L]][["_data"]]$vars, c("g", "x", "span", "items"))
  expect_identical(unique(reports[[2L]][["_data"]]$variable), c("g", "x", "span"))
  utils::capture.output(expect_message(lv(data), "list column"))
  grouped <- capture_reports(lv(data, x, span, items, group = g))
  expect_identical(unique(grouped[[1L]]$table_body$variable), c("x", "span"))
})

test_that("POSIXlt columns are summarized rather than skipped as lists", {
  data <- data.frame(g = c("A", "B", "A"))
  data$when <- as.POSIXlt(c("2020-01-01", "2020-02-01", NA), tz = "UTC")
  utils::capture.output(expect_no_message(lv(data), message = "list column"))
  reports <- capture_reports(lv(data))
  expect_true("when" %in% reports[[2L]][["_data"]]$variable)
  grouped <- capture_reports(lv(data, when, group = g))
  expect_identical(unique(grouped[[1L]]$table_body$variable), "when")
})

test_that("group variables with more than 100 values are rejected", {
  data <- data.frame(id = sprintf("P%03d", 1:150), x = rnorm(150),
                     age = rep(20:79, length.out = 150))
  expect_error(capture_lv(lv(data, x, group = id)), "150 distinct values")
  data$f <- factor(rep("a", 150), levels = as.character(1:101))
  expect_error(capture_lv(lv(data, x, group = f)), "101")
  expect_no_error(capture_lv(lv(data, x, group = age)))
})

test_that("two-way counts with more than 100 categories skip the wide tables", {
  data <- data.frame(id = sprintf("P%03d", 1:150), g = rep(c("A", "B"), 75))
  for (vars in list(c("g", "id"), c("id", "g"))) {
    result <- capture_lv(lv(data, count = vars))
    expect_length(result$tables, 0L)
    expect_true(any(grepl("0.7%", result$output, fixed = TRUE)))
    utils::capture.output(expect_message(lv(data, count = vars), "more than 100"))
  }
})

test_that("empty categories display as (blank) in every table", {
  data <- data.frame(x = c("", "a", "a", ""), g = c("A", "B", "", "A"),
                     f = factor(c("", "u", "u", "u")))
  default <- capture_reports(lv(data))
  labels <- as.character(default[[2L]][["_data"]]$label)
  expect_equal(sum(labels == "(blank)"), 3)
  expect_equal(default[[1L]][["_data"]]$n_special, c(2, 1, 1))
  grouped <- capture_reports(lv(data, x, group = g))
  body <- grouped[[1L]]$table_body
  expect_true("(blank)" %in% body$label)
  header <- grouped[[1L]]$table_styling$header
  expect_true(any(grepl("(blank)", header$label, fixed = TRUE)))
  counted <- capture_reports(lv(data, count = c(x, g)))
  expect_true("(blank)" %in% counted[[1L]][["_data"]]$x)

  # A genuine "(blank)" value keeps both categories apart.
  clash <- data.frame(x = c("", "(blank)", "(blank)"))
  reports <- capture_reports(lv(clash))
  body <- reports[[2L]][["_data"]]
  expect_setequal(as.character(body$label[body$row_type == "level"]),
                  c("", "(blank)"))
})

test_that("Seurat cluster statistics leave out the sample identity", {
  skip_if_not_installed("SeuratObject")
  counts <- matrix(rep(1:5, 8), nrow = 5,
                   dimnames = list(paste0("f", 1:5), paste0("c", 1:8)))
  object <- SeuratObject::CreateSeuratObject(Matrix::Matrix(counts, sparse = TRUE))
  object[["seurat_clusters"]] <- factor(rep(0:1, 4))
  object[["score"]] <- seq_len(8)
  # the cell statistics print to stdout at the console
  out <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(object, score))))
  clusters <- grep("clusters", out, value = TRUE)
  expect_true(any(grepl("seurat_clusters", clusters)))
  expect_false(any(grepl("orig.ident", clusters)))
})

test_that("the summary subtitle counts variables with missing or special values", {
  data <- data.frame(x = c(1, NA, NA), y = c("unknown", "a", "b"), z = 1:3)
  reports <- capture_reports(lv(data))
  subtitle <- as.character(reports[[1L]][["_heading"]]$subtitle)
  expect_match(subtitle, "*1* with missing values", fixed = TRUE)
  expect_match(subtitle, "*1* with Unknown/Blank/N/A", fixed = TRUE)
})

test_that("counts take thousands separators and shares one decimal", {
  data <- data.frame(g = rep(c("A", "B"), c(1200, 300)))
  single <- capture_lv(lv(data, count = g))
  text <- paste(cli::ansi_strip(single$output), collapse = "\n")
  for (shown in c("1,200", "80.0%", "20.0%")) expect_match(text, shown, fixed = TRUE)
  reports <- capture_reports(lv(data))
  expect_match(as.character(reports[[1L]][["_heading"]]$subtitle),
               "*1,500* observations", fixed = TRUE)
})

test_that("the variable summary gives shares, shades counts and shortens calls", {
  data <- data.frame(x = c(1, NA, NA, 4), y = c("unknown", "a", "b", "c"),
                     z = strrep("abcdefghij", 1:4))
  summary <- capture_reports(lv(data))[[1L]]
  expect_equal(summary[["_data"]]$n_na, c(2, 0, 0))
  html <- as.character(gt::as_raw_html(summary, inline_css = FALSE))
  for (shown in c("2 (50.0%)", "1 (25.0%)", "\u2026")) expect_match(html, shown, fixed = TRUE)
  styles <- summary[["_styles"]]
  fill <- vapply(styles$styles, function(s) {
    s[["cell_fill"]][["color"]] %||% NA_character_
  }, character(1))
  shaded <- function(column, color) {
    summary[["_data"]]$vars[styles$rownum[styles$colname == column & fill %in% color]]
  }
  expect_identical(shaded("n_na", "#FFCDD2"), "x")
  expect_identical(shaded("n_special", "#BBDEFB"), "y")
  expect_match(paste(unlist(summary[["_source_notes"]]), collapse = " "),
               "counts shaded: missing red, Unknown/Blank/N/A blue", fixed = TRUE)
  out <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(lv(data)))))
  at <- grep("Variable summary (3 variables)", out, fixed = TRUE)
  expect_match(out[at + 3L], "^  x +numeric +2 +2 \\(50\\.0%\\) +0$")
})

test_that("missing default data errors name the global data frames", {
  rlang::local_bindings(data = 1, data_all = 1, lv_candidate = mtcars,
                        .env = globalenv())
  expect_error(capture_lv(lv()), "lv_candidate")
  direct <- tryCatch(capture_lv(lv()), error = conditionMessage)
  expect_false(grepl("Cannot evaluate", direct))
  expect_error(capture_lv(lv(not_an_object)), "not_an_object")
  expect_error(capture_lv(lv(not_an_object)), "lv_candidate")
  rlang::local_bindings(`odd{name}` = mtcars, .env = globalenv())
  expect_error(capture_lv(lv()), "odd{name}", fixed = TRUE)
})

test_that("the variable summary tints rows by variable type", {
  data <- data.frame(chr = c("a", "b", "a"), num = c(1.5, 2, 3), int = 1:3,
                     fac = factor(c("x", "y", "x")),
                     ord = factor(c("lo", "hi", "lo"), c("lo", "hi"), ordered = TRUE),
                     flag = c(TRUE, FALSE, TRUE))
  summary <- capture_reports(lv(data))[[1L]]
  styles <- summary[["_styles"]]
  fill <- vapply(styles$styles, function(s) {
    color <- s[["cell_fill"]][["color"]]
    if (is.null(color)) NA_character_ else color
  }, character(1))
  filled <- unique(data.frame(var = summary[["_data"]]$vars[styles$rownum],
                              col = styles$colname, fill = fill)[!is.na(fill), ])
  expect_setequal(filled$fill[filled$var == "chr"], "#FDF0E6")
  expect_setequal(filled$fill[filled$var %in% c("num", "int")], "#E9F2FB")
  expect_setequal(filled$fill[filled$var %in% c("fac", "ord")], "#EAF5E4")
  columns <- c("vars", "class", "n_unique", "n_na", "n_special", "unique")
  for (v in c("chr", "num", "int", "fac", "ord")) {
    expect_setequal(filled$col[filled$var == v], columns)
  }
  expect_false("flag" %in% filled$var)
})

test_that("lv() prints its headings with the tables at the console, as messages when knitting", {
  data <- data.frame(a = c("x", "y", "x"), b = c("u", "u", "v"))
  cross <- cli::ansi_strip(utils::capture.output(suppressMessages(
    lv(data, count = c("a", "b")))))
  expect_true(any(grepl("Cross-tabulation: a \u00d7 b", cross, fixed = TRUE)))
  expect_true(any(grepl("Variables  a, b", cross, fixed = TRUE)))
  expect_false(any(grepl("Row Percentages", cross, fixed = TRUE)))
  expect_true(any(grepl("Cells give n (row %)", cross, fixed = TRUE)))
  grouped <- cli::ansi_strip(utils::capture.output(suppressMessages(
    lv(data, a, group = "b"))))
  expect_true(any(grepl("Variable Summary by b", grouped, fixed = TRUE)))
  expect_true(any(grepl("Groups  2", grouped, fixed = TRUE)))
  expect_false(any(grepl("summary for", utils::capture.output(suppressMessages(lv(data))),
                         fixed = TRUE)))

  withr::local_options(knitr.in.progress = TRUE)
  expect_message(utils::capture.output(lv(data, count = c("a", "b"))), "Cross-tabulation")
})

test_that("each variable lists its counts, shares and filter in one block", {
  data <- data.frame(
    stage = factor(c("I", "II", "II", NA, "Unknown"), levels = c("I", "II", "Unknown")),
    id = sprintf("P%02d", 1:5)
  )
  many <- data.frame(id = sprintf("P%02d", 1:20))
  out <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(lv(data)))))
  head <- grep("stage (factor)", out, fixed = TRUE)
  expect_length(head, 1L)
  expect_match(out[head], "3 levels \u00b7 NA 1 \\(20\\.0%\\) \u00b7 special 1 \\(20\\.0%\\)")
  expect_match(out[head + 1L], "^  stage +n +pct +cum$")
  expect_identical(out[head + 3:6], c("  I        1  20.0%  20.0%",
                                      "  II       2  40.0%  60.0%",
                                      "  Unknown  1  20.0%  80.0%",
                                      "  <NA>     1  20.0%"))
  expect_identical(out[head + 7L], 'get_flt(stage %in% c("I", "II", "Unknown"))')
  expect_identical(out[head + 8L], "")
  ids <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(lv(many)))))
  expect_true("  (6 others)  6  30.0%  100.0%" %in% ids)
})

test_that("the console report opens with a summary of the data set", {
  data <- data.frame(x = c(1, NA, 3), y = c("unknown", "a", "b"),
                     z = factor(c("p", "q", "p")))
  out <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(lv(data)))))
  expect_identical(out[1L], "<lv> 3 rows · 3 variables")
  expect_match(out[2L], "^  Types +1 character, 1 factor, 1 numeric$")
  expect_match(out[3L], "^  Missing values +x$")
  expect_match(out[4L], "^  Unknown/Blank/N/A +y$")
  expect_identical(out[5L], "")
  clean <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(
    lv(data.frame(a = 1:3))))))
  expect_identical(clean[1L], "<lv> 3 rows · 1 variable")
  expect_match(clean[3L], "^  Missing values +none$")
})

test_that("frequency tables give times in full and spans unpadded", {
  data <- data.frame(span = as.difftime(c(1, 10, 10), units = "hours"))
  data$when <- as.POSIXct("2020-01-01", tz = "UTC") + c(0, 3600, 3600)
  out <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(lv(data)))))
  expect_true(any(startsWith(out, "  1 hours ")))
  expect_true(any(startsWith(out, "  2020-01-01 00:00:00 ")))
  at <- grep("Variable distributions", out, fixed = TRUE)
  expect_identical(out[at - 1L], "")
})

test_that("numeric variables with many values list their distribution", {
  data <- data.frame(age = c(seq(10, 110, by = 10), NA), dss = c(0, 1, NA, rep(1, 9)))
  out <- sub(" +$", "", cli::ansi_strip(utils::capture.output(suppressMessages(lv(data)))))
  head <- grep("age (numeric)", out, fixed = TRUE)
  expect_match(out[head], "11 values · NA 1 \\(8\\.3%\\)")
  expect_match(out[head + 1L], "^  Distribution  ")
  expect_identical(out[head + 2:4], c("  Range            10 to 110",
                                      "  Median [Q1, Q3]  60 [35, 85]",
                                      "  Mean (SD)        60 (33.2)"))
  expect_match(out[head + 5L], "^get_flt\\(age %in% c\\(10, 20, ")
  # a code with few values keeps its frequency table
  dss <- grep("dss (numeric)", out, fixed = TRUE)
  expect_match(out[dss + 1L], "^  dss +n +pct +cum$")
})

test_that("the console overview gives one distribution line per variable", {
  data <- data.frame(age = c(40, 50, 60), sex = c("M", "F", "M"))
  out <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(data))))
  expect_false(any(grepl("**Vars**", out, fixed = TRUE)))
  expect_false(any(grepl("__age", out, fixed = TRUE)))
  at <- grep("Variable distributions (2 variables)", out, fixed = TRUE)
  expect_length(at, 1L)
  expect_match(out[at + 1L], "^  age .*mean 50\\.0")
  expect_match(out[at + 2L], "^  sex .*2 levels")
})

test_that("lv prints its console sections with pr_section()", {
  data <- data.frame(age = c(40, 50, 50), sex = c("M", "F", "M"))
  out <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(data))))
  rules <- gsub(cli::symbol$line, "-", out[grepl(cli::symbol$line, out, fixed = TRUE)],
                fixed = TRUE)
  expect_true(any(grepl("^-- age \\(numeric\\) \u00b7 2 values -+$", rules)))
  expect_true(any(grepl("^-- sex \\(character\\) \u00b7 2 values -+$", rules)))
  expect_false(any(grepl("unique values", rules, fixed = TRUE)))
  expect_true(any(grepl("^-- Variable summary \\(2 variables\\) -+$", rules)))
  expect_false(any(grepl("----1.", out, fixed = TRUE)))
})

test_that("SPSS user-missing codes stay out of continuous statistics", {
  skip_if_not_installed("haven")
  data <- data.frame(x = haven::labelled_spss(c(1:11, 98, 99, 100, NA),
                                             na_values = 100, na_range = c(98, 99)))
  before <- data
  clean <- data.frame(x = as.numeric(data$x))
  clean$x[is.na(data$x)] <- NA
  reports <- capture_reports(lv(data))
  summary <- reports[[1L]][["_data"]]
  expect_equal(summary$n_na, 4)
  expect_equal(summary$n_unique, 11)
  body <- reports[[2L]][["_data"]]
  expected <- capture_reports(lv(clean))[[2L]][["_data"]]
  expect_identical(body$stat_0, expected$stat_0)

  output <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(data))))
  expect_match(paste(output, collapse = "\n"), "Range +1 to 11")
  expect_match(paste(output, collapse = "\n"), "Mean \\(SD\\) +6 \\(3\\.32\\)")
  expect_identical(data, before)
})

test_that("SPSS user-missing character values stay out of category totals", {
  skip_if_not_installed("haven")
  data <- data.frame(g = c("A", "A", "B", "B"),
                     x = haven::labelled_spss(c("known", "known", "missing", NA),
                                              na_values = "missing"))
  before <- data
  reports <- capture_reports(lv(data, x))
  expect_equal(reports[[1L]][["_data"]]$n_na, 2)
  body <- reports[[2L]][["_data"]]
  expect_identical(body$label[body$row_type == "level"], "known")
  expect_identical(body$stat_0[body$row_type == "level"], "2 (100%)")
  grouped <- capture_reports(lv(data, x, group = g))[[1L]]$table_body
  expect_identical(grouped$stat_0[grouped$row_type == "level"], "2 (100%)")
  expect_identical(grouped$stat_2[grouped$row_type == "missing"], "2 (100%)")
  empty <- data[3:4, , drop = FALSE]
  empty_body <- capture_reports(lv(empty, x))[[2L]][["_data"]]
  expect_identical(empty_body$stat_0[empty_body$row_type == "missing"], "2 (100%)")
  expect_identical(data, before)
})

test_that("SPSS user-missing groups and count categories are consolidated", {
  skip_if_not_installed("haven")
  for (group in list(
    haven::labelled_spss(c(1, 1, 98, 99, NA), na_range = c(98, 99)),
    haven::labelled_spss(c("A", "A", "missing", "missing", NA), na_values = "missing")
  )) {
    data <- data.frame(g = group, x = c("known", "known", rep("unrecorded", 3)))
    before <- data
    reports <- capture_reports(value <- withVisible(lv(data, x, group = g)))
    header <- reports[[1L]]$table_styling$header
    groups <- header[grepl("^stat_[1-9]", header$column), ]
    expect_equal(groups$modify_stat_n, c(2, 3))
    expect_identical(tail(groups$modify_stat_level, 1L), "\u7f3a\u5931")
    expect_identical(value$value, before)
    expect_identical(value$visible, FALSE)

    counts <- capture_reports(lv(data, count = g))[[1L]][["_data"]]
    expect_identical(counts$n, c(2L, 3L))
    expect_identical(counts$pct, c("40.0%", "60.0%"))
    expect_equal(sum(is.na(counts$g)), 1)
    wide <- capture_reports(lv(data, count = c(x, g)))[[1L]][["_data"]]
    expect_identical(wide[["NA"]], c("0", "3 (100.0%)", "3 (60.0%)"))
    expect_identical(data, before)
  }
})

test_that("suggested filters retain exact double values after truncation", {
  skip_if_not_installed("haven")
  data <- data.frame(
    close = c(0.123456789012345 + seq(0, 1e-15, length.out = 11), NA),
    large = c(1e20 + seq(0, 2e5, length.out = 11), NA),
    tiny = c(1e-200 * seq(1, 2, length.out = 11), NA)
  )
  data$labelled <- haven::labelled_spss(replace(data$close, 12L, 99), na_values = 99)
  before <- data
  summary <- capture_reports(lv(data))[[1L]][["_data"]]
  expect_equal(summary$n_unique, rep(11, 4))
  for (i in seq_len(nrow(summary))) {
    values <- data[[summary$vars[i]]]
    expected <- head(sort(as.numeric(values[!is.na(values)])), 8)
    code <- as.character(summary$unique[i])
    call <- parse(text = code)[[1L]]
    expect_identical(eval(call[[2L]][[3L]]), expected)
    expect_identical(eval(call[[2L]], envir = data), as.numeric(values) %in% expected)
    expect_equal(sum(eval(call[[2L]], envir = data)), 8)
    expect_match(code, "# +3 more", fixed = TRUE)
  }
  expect_identical(data, before)
})

test_that("suggested date-time filters preserve exact instants and time zones", {
  withr::local_options(digits.secs = 0)
  origin <- as.POSIXct("2020-11-01 04:59:59", tz = "UTC")
  offsets <- c(0, 0.1, 0.2, 1:8, NA_real_)
  for (zone in c("UTC", "Asia/Shanghai", "America/New_York")) {
    time <- structure(as.numeric(origin + offsets),
                      class = c("POSIXct", "POSIXt"), tzone = zone)
    data <- data.frame(instant = time)
    data$broken_down <- as.POSIXlt(time)
    before <- data
    summary <- capture_reports(lv(data))[[1L]][["_data"]]
    expect_equal(summary$n_unique, c(11, 11))
    for (i in seq_len(nrow(summary))) {
      expr <- parse(text = as.character(summary$unique[i]))[[1L]]
      condition <- expr[[2L]]
      expect_identical(eval(condition, envir = data), c(rep(TRUE, 8), rep(FALSE, 4)))
      values <- eval(condition[[3L]])
      expect_s3_class(values, "POSIXct")
      expect_identical(as.numeric(values), as.numeric(time[1:8]))
      expect_identical(attr(values, "tzone"), zone)
      expect_match(as.character(summary$unique[i]), "# +3 more", fixed = TRUE)
    }
    expect_identical(data, before)
  }
})

test_that("all-missing date-time columns produce empty usable filters", {
  time <- as.POSIXct(c(NA, NA), origin = "1970-01-01", tz = "UTC")
  data <- data.frame(instant = time)
  data$broken_down <- as.POSIXlt(time)
  before <- data
  summary <- capture_reports(lv(data))[[1L]][["_data"]]
  expect_equal(summary$n_unique, c(0, 0))
  expect_equal(summary$n_na, c(2, 2))
  for (i in seq_len(nrow(summary))) {
    expr <- parse(text = as.character(summary$unique[i]))[[1L]]
    expect_identical(eval(expr[[2L]], envir = data), c(FALSE, FALSE))
  }
  expect_identical(data, before)
})

test_that("date-time filters distinguish repeated daylight-saving clock times", {
  origin <- as.POSIXct("2020-11-01 05:30:00", tz = "UTC")
  time <- structure(as.numeric(origin + c(0:7, 3600:3602)),
                    class = c("POSIXct", "POSIXt"), tzone = "America/New_York")
  data <- data.frame(instant = time)
  data$broken_down <- as.POSIXlt(time)
  summary <- capture_reports(lv(data))[[1L]][["_data"]]
  for (i in seq_len(nrow(summary))) {
    expr <- parse(text = as.character(summary$unique[i]))[[1L]]
    expect_identical(eval(expr[[2L]], envir = data), c(rep(TRUE, 8), rep(FALSE, 3)))
  }
})

test_that("date-time filters retain an absent or local time zone", {
  for (zone in list(NULL, "")) {
    time <- structure(c(0, 0.1, NA_real_),
                      class = c("POSIXct", "POSIXt"), tzone = zone)
    data <- data.frame(instant = time)
    summary <- capture_reports(lv(data))[[1L]][["_data"]]
    expr <- parse(text = as.character(summary$unique))[[1L]]
    expect_identical(eval(expr[[2L]], envir = data), c(TRUE, TRUE, FALSE))
    expect_identical(attr(eval(expr[[2L]][[3L]]), "tzone"), zone)
  }
})

test_that("date-time filters work with the real RegR filtering entry point", {
  skip_if_not_installed("RegR")
  time <- as.POSIXct("2020-01-01 12:00:00", tz = "UTC") + c(0, 0.1, 0.2, NA)
  data <- data.frame(id = 1:4)
  data[["time value"]] <- as.POSIXlt(time)
  summary <- capture_reports(lv(data, `time value`))[[1L]][["_data"]]
  expr <- parse(text = as.character(summary$unique))[[1L]]
  call <- as.call(list(quote(RegR::get_flt), quote(data), expr[[2L]]))
  invisible(utils::capture.output(result <- eval(call)))
  expect_identical(result$id, 1:3)
})

test_that("standard deviations stay finite across finite numeric scales", {
  read_sd <- function(text) {
    as.numeric(gsub(",", "", sub(".*\\(([^()]*)\\)$", "\\1", trimws(text)), fixed = TRUE))
  }
  expected <- stats::sd(seq(-1, 1, length.out = 11))
  for (scale in c(1e200, 1e308, 1e-200)) {
    data <- data.frame(x = c(seq(-1, 1, length.out = 11) * scale, NA))
    before <- data
    output <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(data))))
    line <- grep("^  Mean \\(SD\\)", output, value = TRUE)
    expect_length(line, 1L)
    expect_equal(read_sd(line) / scale, expected, tolerance = 0.001)
    if (scale > 1) {
      body <- capture_reports(lv(data))[[2L]][["_data"]]
      mean_sd <- body$stat_0[body$label == "Mean (SD)"]
      expect_length(mean_sd, 1L)
      expect_equal(read_sd(mean_sd) / scale, expected, tolerance = 1e-12)
    }
    expect_identical(data, before)
  }
})

test_that("dataset hints survive unreadable global bindings", {
  good <- "utilsr_hint_dataset_fixture"
  bad <- "utilsr_hint_unreadable_fixture"
  rlang::local_bindings(!!!stats::setNames(list(data.frame(x = 1:2)), good), .env = .GlobalEnv)
  makeActiveBinding(bad, function(value) stop("binding unavailable"), .GlobalEnv)
  withr::defer(rm(list = bad, envir = .GlobalEnv))
  expect_no_error(hint <- .lv_dataset_hint())
  expect_true(any(grepl(good, hint, fixed = TRUE)))
})

test_that("time filter suggestions distinguish values with identical printed labels", {
  inputs <- list(as.difftime(1 + (0:10) * .Machine$double.eps, units = "days"), as.Date(1 + (0:10) / 100, origin = "1970-01-01"))
  for (x in inputs) {
    d <- data.frame(x = x)
    summary <- capture_reports(lv(d))[[1L]][["_data"]]
    expect_equal(summary$n_unique, 11L)
    expression <- parse(text = as.character(summary$unique))[[1L]]
    expect_identical(eval(expression[[2L]], envir = d), c(rep(TRUE, 8L), rep(FALSE, 3L)))
    expect_identical(d[["x"]], x)
  }
})

test_that("grouped inspection restores cold integer64 grouping labels", {
  skip_if_not_installed("bit64")
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "input.rds")
  script <- file.path(directory, "verify.R")
  d <- data.frame(y = 1:6)
  d[["g"]] <- bit64::as.integer64(c("-1", "-1", "-2", "-2", NA, NA))
  saveRDS(list(fn = lv.data.frame, data = d, libs = .libPaths()), fixture)
  writeLines(c(sprintf("fixture <- readRDS(%s)", deparse(fixture)),
    ".libPaths(fixture[['libs']])",
    "stopifnot(!('bit64' %in% loadedNamespaces()))",
    "fn <- fixture[['fn']]; e <- new.env(parent = environment(fn)); environment(fn) <- e",
    "reports <- list(); e$.lv_print_report <- function(x) reports[[length(reports) + 1L]] <<- x",
    "invisible(capture.output(suppressMessages(fn(fixture[['data']], pattern = '^y$', group = 'g'))))",
    "header <- reports[[1L]]$table_styling$header",
    "labels <- header$label[grepl('^stat_[1-3]$', header$column)]",
    "stopifnot(length(labels) == 3L, any(grepl('-1', labels, fixed = TRUE)), any(grepl('-2', labels, fixed = TRUE)), all(grepl('N = 2', labels, fixed = TRUE)))",
    "cat('COLD_INSPECTION_OK\n')"), script)
  output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
  expect_identical(tail(output, 1L), 'COLD_INSPECTION_OK')
})

test_that('tiny nonzero standard deviations survive partial variance underflow', {
  for (offset in c(0, 1e-150)) {
    x <- offset + c(0, 2.5e-162)
    text <- cli::ansi_strip(utils::capture.output(pr_spark(data.frame(x = x))))
    expect_match(paste(text, collapse = ' '), 'sd 1.77e-162', fixed = TRUE)
    interval <- .con_mean_sd(x)
    expect_equal((interval$ymax - interval$ymin) / diff(x), sqrt(2), tolerance = 0.001)
  }
  d <- data.frame(x = (0:11) * 5e-163)
  output <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(d))))
  line <- grep('^  Mean [(]SD[)]', output, value = TRUE)
  expect_length(line, 1L)
  spread <- as.numeric(sub('[)]$', '', tail(strsplit(trimws(line), '(', fixed = TRUE)[[1L]], 1L)))
  expect_equal(spread / 5e-163, stats::sd(0:11), tolerance = .003)
})

test_that("count priority does not evaluate ignored inspection controls", {
  d <- data.frame(g = c("A", "A", "B"), x = 1:3)
  for (data in list(d, as.matrix(d))) {
    reference <- capture_reports(lv(data, count = g))[[1L]][["_data"]]
    calls <- list(quote(lv(data, stop("UNUSED SELECTION"), count = g)),
      quote(lv(data, count = g, group = stop("UNUSED GROUP"))),
      quote(lv(data, count = g, pattern = stop("UNUSED PATTERN"))),
      quote(lv(data, count = g, pattern = "[")))
    for (call in calls) {
      expect_warning(actual <- capture_reports(eval(call)), "count")
      expect_identical(actual[[1L]][["_data"]], reference)
    }
  }
})

test_that("Seurat count priority does not evaluate ignored inspection controls", {
  skip_if_not_installed("SeuratObject")
  counts <- matrix(rep(1:5, 4), nrow = 5,
    dimnames = list(paste0("gene", 1:5), paste0("cell", 1:4)))
  object <- SeuratObject::CreateSeuratObject(Matrix::Matrix(counts, sparse = TRUE))
  object$g <- c("A", "A", "B", "B")
  reference <- capture_reports(lv(object, count = g, add_cell_stats = FALSE))[[1L]][["_data"]]
  expect_warning(actual <- capture_reports(lv(object, stop("UNUSED SELECTION"), count = g,
    group = stop("UNUSED GROUP"), pattern = stop("UNUSED PATTERN"), add_cell_stats = FALSE)), "count")
  expect_identical(actual[[1L]][["_data"]], reference)
})

test_that("inspection reports distinguish typed category labels", {
  inputs <- list(c(1, 1 + .Machine$double.eps),
    as.Date(c(1, 1.5), origin = "1970-01-01"),
    complex(real = 1, imaginary = c(1, 1 + .Machine$double.eps)))
  for (value in inputs) {
    d <- data.frame(g = c("A", "A", "B", "B"))
    d$x <- value[c(1, 2, 1, 2)]
    before <- serialize(d, NULL)
    count <- capture_reports(lv(d, count = c(g, x)))[[1L]][["_data"]]
    expect_equal(ncol(count), 4L)
    expect_identical(unname(unlist(count[1L, 2:3])), c("1 (50.0%)", "1 (50.0%)"))
    expect_length(unique(names(count)[2:3]), 2L)
    by <- data.frame(y = c("a", "a", "b", "b"))
    by$g <- rep(value, each = 2)
    grouped <- capture_reports(lv(by, y, group = g))[[1L]]
    header <- grouped$table_styling$header
    labels <- header$label[header$column %in% c("stat_1", "stat_2")]
    expect_length(unique(labels), 2L)
    if (inherits(value, "Date")) expect_true(all(grepl("1970-01-02", labels, fixed = TRUE)))
    if (!is.complex(value)) {
      shown <- list()
      local({
        local_mocked_bindings(pr_table = function(data, ...) {
          if (all(c("pct", "cum") %in% names(data))) shown[[length(shown) + 1L]] <<- data
          invisible(character())
        })
        withr::local_options(knitr.in.progress = FALSE)
        invisible(utils::capture.output(suppressMessages(lv(d, x))))
      })
      expect_length(shown, 1L)
      expect_length(unique(shown[[1L]]$x), 2L)
    }
    expect_identical(serialize(d, NULL), before)
  }
})

test_that("inspection column limits use a bounded cardinality proof", {
  fn <- lv.data.frame
  e <- new.env(parent = environment(fn))
  examined <- 0L
  reports <- list()
  e$unique <- function(x, ...) {
    if (is.character(x) && length(x) && all(startsWith(x[!is.na(x)], "PATIENT_"))) {
      examined <<- examined + length(x)
    }
    base::unique(x, ...)
  }
  e$.lv_print_report <- function(x) reports[[length(reports) + 1L]] <<- x
  environment(fn) <- e
  d <- data.frame(g = rep(c("A", "B"), each = 1000), id = sprintf("PATIENT_%04d", 1:2000), y = 1:2000)
  invisible(utils::capture.output(suppressMessages(fn(d, group = "g"))))
  expect_lte(examined, 101L)
  expect_false("id" %in% reports[[1L]]$table_body$variable)
  for (prefix in list(rep("PATIENT_repeat", 101), c(NA_character_, sprintf("PATIENT_%04d", 2:101)))) {
    d$id[1:101] <- prefix
    examined <- 0L
    reports <- list()
    invisible(utils::capture.output(suppressMessages(fn(d, group = "g"))))
    expect_gte(examined, nrow(d) - 1L)
    expect_false("id" %in% reports[[1L]]$table_body$variable)
  }
})

test_that("complex columns retain exact categories through summary tables", {
  x <- c(1 + 2i, 1 + 2i + 1e-14, 1 + 2i, NA_complex_)
  data <- data.frame(x = x, g = c("a", "b", "b", "a"))
  for (grouped in c(FALSE, TRUE)) {
    result <- if (grouped) capture_lv(lv(data, x, group = g)) else capture_lv(lv(data, x))
    expect_identical(result$value$value, data)
    tables <- Filter(function(t) all(c("row_type", "label") %in% names(t)), result$tables)
    expect_true(length(tables) > 0L)
    levels <- tables[[1L]]$label[tables[[1L]]$row_type == "level"]
    expect_length(levels, 2L)
    expect_identical(anyDuplicated(levels), 0L)
    expect_true(any(tables[[1L]]$row_type == "missing"))
  }
  missing <- data.frame(x = rep(NA_complex_, 3))
  result <- capture_lv(lv(missing))
  expect_identical(result$value$value, missing)
  large <- data.frame(x = as.complex(seq_len(101)))
  expect_message(result <- capture_lv(lv(large)), NA)
  expect_identical(result$value$value, large)
})

test_that("suggested complex filters select exact literals after truncation", {
  data <- data.frame(z = c(1 + 2i + seq(0, 1e-14, length.out = 11), NA_complex_))
  before <- data
  summary <- capture_reports(lv(data))[[1L]][["_data"]]
  call <- parse(text = as.character(summary$unique))[[1L]]
  expected <- head(unique(data$z[!is.na(data$z)]), 8)
  expect_identical(eval(call[[2L]][[3L]]), expected)
  expect_identical(eval(call[[2L]], envir = data), data$z %in% expected)
  expect_equal(sum(eval(call[[2L]], envir = data)), 8)
  expect_match(as.character(summary$unique), "# +3 more", fixed = TRUE)
  expect_identical(data, before)
})
