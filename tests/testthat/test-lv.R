# Observe constructed reports without replacing their statistical calculations.
capture_lv <- function(expr) {
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
  expect_match(text, "33.33", fixed = TRUE)
  expect_match(text, "66.67", fixed = TRUE)
  expect_match(text, "1 (33.33%)", fixed = TRUE)
  expect_match(text, "2 (66.67%)", fixed = TRUE)

  for (name in c("n", "pct", "n_pct")) {
    names(data)[1L] <- name
    vars <- c(name, "category")
    result <- capture_lv(lv(data, count = vars))
    wide <- result$tables[[1L]]
    expect_equal(wide[["a"]], c(1, 0))
    expect_equal(wide[["b"]], c(0, 2))
    expect_equal(wide[["Total"]], c(1, 2))
    expect_identical(result$value$value, data)
    expect_false(result$value$visible)
  }
})

test_that("a Total category is retained beside the separate row total", {
  data <- data.frame(g = c("A", "A", "B"), x = c("Total", "x", "Total"))
  result <- capture_lv(lv(data, count = c(g, x)))
  wide <- result$tables[[1L]]
  expect_equal(wide[["Total"]], c(1, 1))
  expect_equal(wide[["Total_1"]], c(2, 1))
  expect_identical(names(wide), c("g", "Total", "x", "Total_1"))
})

test_that("cross-tabulation uses the requested variables on grouped input", {
  data <- data.frame(stratum = c("U", "V", "V"),
                     a = c("A", "A", "A"), b = c("X", "X", "Y"))
  grouped <- dplyr::group_by(data, stratum)
  result <- capture_lv(lv(grouped, count = c(a, b)))
  expect_equal(result$tables[[1L]][["X"]], 2)
  expect_equal(result$tables[[1L]][["Y"]], 1)
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

  # This remains an upstream unsupported input, and must still restore state.
  invalid <- data.frame(x = factor(c("a", NA), exclude = NULL))
  expect_error(capture_lv(lv(invalid)), "Factors with NA levels")
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
  expect_match(paste(counted$output, collapse = "\n"), "2 (50%)", fixed = TRUE)

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
  expect_equal(counted$tables[[1L]][["SeuratProject"]], c(4, 4))
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

test_that("suggested filters escape column names and character values", {
  values <- c('a"b', "c\\d", "line\nbreak", "", "a'b")
  for (column in c("a b", "a`b")) {
    data <- stats::setNames(data.frame(values), column)
    result <- capture_lv(lv(data))
    summary <- Filter(function(x) "n_special" %in% names(x), result$tables)[[1L]]
    expression <- parse(text = as.character(summary$unique))[[1L]]
    expect_identical(expression[[1L]], quote(get_flt))
    expect_identical(expression[[2L]][[2L]], as.name(column))
    expect_identical(eval(expression[[2L]][[3L]]), values)
    expect_true(all(eval(expression[[2L]], envir = data)))
    expect_identical(result$value$value, data)
  }
})

test_that("blank cross-tabulation categories remain distinct and renderable", {
  data <- data.frame(g = c("A", "A", "B"), x = c("", "", "(blank)"))
  result <- capture_lv(lv(data, count = c(g, x)))
  wide <- result$tables[[1L]]
  expect_identical(names(wide), c("g", "(blank)", "(blank)_1", "Total"))
  expect_equal(wide[["(blank)"]], c(2, 0))
  expect_equal(wide[["(blank)_1"]], c(0, 1))
  expect_equal(wide[["Total"]], c(2, 1))
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

filled_labels <- function(gt_tbl, color) {
  styles <- gt_tbl[["_styles"]]
  fill <- vapply(styles$styles, function(s) {
    colors <- unlist(lapply(s, function(x) x$color))
    if (length(colors)) colors[[1L]] else NA_character_
  }, character(1))
  rows <- styles$rownum[styles$colname == "label" & fill %in% color]
  as.character(gt_tbl[["_data"]]$label[sort(unique(rows))])
}

test_that("special-value highlights follow the special-value counts", {
  data <- data.frame(
    v = c("Blanket", "Unknownness", "n/a", "Missing", "Not stated", "ok"),
    unknown_flag = c(1, 1, 2, 2, 3, 3)
  )
  reports <- capture_reports(lv(data))
  summary <- reports[[1L]][["_data"]]
  expect_equal(summary$n_special, c(3, 0))
  highlighted <- filled_labels(reports[[2L]], "#FFFF00")
  expect_setequal(highlighted, c("n/a", "Missing", "Not stated"))
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

test_that("console reports render each default table once", {
  data <- data.frame(x = c("a", "b", "a"), y = 1:3)
  output <- utils::capture.output(suppressMessages(lv(data)))
  tables <- gregexpr("<table", paste(output, collapse = "\n"), fixed = TRUE)[[1L]]
  expect_length(tables, 2L)
  expect_true(any(grepl("# A tibble", output, fixed = TRUE)))
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
                   "get_flt(num %in% c(1, 2, 3, 4, 5, 6, 7, 8))  # +5 more")
  expect_identical(filters[["int"]], "get_flt(int %in% c(1, 2))")
  expect_identical(filters[["flag"]], "get_flt(flag %in% c(TRUE, FALSE))")
  expect_identical(filters[["f"]], 'get_flt(f %in% c("a"))')
  expect_equal(summary$n_unique, c(13, 2, 2, 1, 2))
  for (v in c("int", "flag", "f", "float")) {
    call <- parse(text = filters[[v]])[[1L]]
    expect_true(all(eval(call[[2L]], envir = data)))
  }
  labels <- as.character(reports[[2L]][["_data"]]$label)
  expect_true("f (factor, 1)" %in% labels)
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
    expect_true(any(grepl("1 (0.67%)", result$output, fixed = TRUE)))
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
  seen <- character()
  utils::capture.output(withCallingHandlers(
    lv(object, score),
    message = function(m) {
      seen <<- c(seen, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  ))
  clusters <- grep("clusters", seen, value = TRUE)
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

test_that("lv prints its console sections with pr_section()", {
  data <- data.frame(age = c(40, 50, 50), sex = c("M", "F", "M"))
  out <- cli::ansi_strip(utils::capture.output(suppressMessages(lv(data))))
  rules <- gsub(cli::symbol$line, "-", out[grepl(cli::symbol$line, out, fixed = TRUE)],
                fixed = TRUE)
  expect_true(any(grepl("^-- age \\(numeric\\): count -+$", rules)))
  expect_true(any(grepl("^-- sex \\(character\\): unique values -+$", rules)))
  expect_true(any(grepl("^-- Variable summary \\(2 variables\\) -+$", rules)))
  expect_false(any(grepl("----1.", out, fixed = TRUE)))
})
