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
