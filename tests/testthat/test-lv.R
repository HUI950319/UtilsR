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
