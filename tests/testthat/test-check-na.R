# Special-value counts of check_na() and lv(): whole-word patterns, each
# value counted once.

# The tables reach the console only as gt objects; record the data each
# gt::gt() call receives.
capture_gt_data <- function(expr) {
  seen <- list()
  gt_orig <- gt::gt
  testthat::local_mocked_bindings(
    gt = function(data, ...) {
      seen[[length(seen) + 1L]] <<- data
      gt_orig(data, ...)
    },
    .package = "gt"
  )
  invisible(utils::capture.output(suppressMessages(expr)))
  seen
}

# Source notes are added after all styles; retain the fully constructed table.
capture_gt_table <- function(expr) {
  seen <- NULL
  note_orig <- gt::tab_source_note
  testthat::local_mocked_bindings(
    tab_source_note = function(data, ...) {
      seen <<- note_orig(data, ...)
      seen
    },
    .package = "gt"
  )
  invisible(utils::capture.output(suppressMessages(expr)))
  seen
}

special_values_data <- function() {
  data.frame(
    region = c("Regional", "National", "Canada", "Local", "Distant", "Local"),
    status = c("NA", "n/a", "Unknown", "Alive", "Blank(s)", ""),
    combo = c("Unknown/NA", "Not available", "missing data", "ok", NA,
              "unknown / n/a"),
    stage = factor(c("I", "II", "Unknown", "Unknown", "II", "I"),
                   levels = c("I", "II", "Unknown", "NA's")),
    stringsAsFactors = FALSE
  )
}

expected_special <- c(region = 0, status = 5, combo = 4, stage = 2)

test_that("check_na counts special values as whole words, once per value", {
  seen <- capture_gt_data(check_na(special_values_data(), show_all = TRUE))
  tab <- seen[[1L]]
  counts <- stats::setNames(
    as.numeric(sub(" .*", "", tab$special_combined)), tab$variable
  )
  expect_equal(counts[names(expected_special)], expected_special)
})

test_that("lv counts special values as whole words, once per value", {
  seen <- capture_gt_data(lv(special_values_data()))
  tab <- Filter(function(x) "n_special" %in% names(x), seen)[[1L]]
  counts <- stats::setNames(as.numeric(tab$n_special), tab$vars)
  expect_equal(counts[names(expected_special)], expected_special)
})

test_that("check_na returns the complete input after inspecting selected columns", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  attr(data, "source") <- "original"
  seen <- capture_gt_data(result <- withVisible(check_na(data, a)))

  expect_identical(result$value, data)
  expect_false(result$visible)
  expect_identical(seen[[1L]]$variable, "a")
})

test_that("check_na preserves the input when selected columns have no issues", {
  data <- data.frame(a = c(1, NA), b = c("ok", "ok"))
  seen <- capture_gt_data(result <- withVisible(check_na(data, b)))

  expect_identical(result$value, data)
  expect_false(result$visible)
  expect_length(seen, 0L)
})

test_that("check_na inspects renamed selections without changing the input", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  seen <- capture_gt_data(result <- check_na(data, renamed = a))

  expect_identical(seen[[1L]]$variable, "renamed")
  expect_identical(seen[[1L]]$missing_combined, "1 (50.0%)")
  expect_identical(result, data)
})

test_that("check_na does not expand unmatched selections to every column", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  selected <- capture_gt_data(result <- check_na(data, dplyr::starts_with("absent")))
  patterned <- capture_gt_data(check_na(data, pattern = "^absent"))

  expect_length(selected, 0L)
  expect_length(patterned, 0L)
  expect_identical(result, data)
})

test_that("check_na selects grouped inputs across all rows", {
  data <- dplyr::group_by(data.frame(group = c("A", "B"), x = c(1, NA)), group)
  all <- capture_gt_data(result <- check_na(data, show_all = TRUE))
  selected <- capture_gt_data(check_na(data, x, show_all = TRUE))

  expect_setequal(all[[1L]]$variable, c("group", "x"))
  expect_identical(selected[[1L]]$variable, "x")
  expect_identical(selected[[1L]]$missing_combined, "1 (50.0%)")
  expect_identical(result, data)
})

test_that("check_na returns empty inputs without constructing percentages", {
  inputs <- list(data.frame(x = numeric()), data.frame(row.names = 1:2),
                 data.frame())
  for (data in inputs) {
    for (show_all in c(FALSE, TRUE)) {
      seen <- capture_gt_data(result <- withVisible(check_na(data, show_all = show_all)))
      expect_identical(result$value, data)
      expect_false(result$visible)
      expect_length(seen, 0L)
    }
  }
})

test_that("check_na rejects ambiguous column names before pattern selection", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  for (bad_names in list(c("x", "x"), c("x", ""), c("x", NA_character_))) {
    names(data) <- bad_names
    expect_error(capture_gt_data(check_na(data, pattern = ".")),
                 "unique, non-empty column names")
  }
})

test_that("check_na rejects multidimensional selected columns", {
  data <- data.frame(good = c(1, NA), matrix = I(matrix(NA_real_, 2, 2)))
  expect_error(capture_gt_data(check_na(data, show_all = TRUE)), "one-dimensional")
  seen <- capture_gt_data(check_na(data, good))
  expect_identical(seen[[1L]]$missing_combined, "1 (50.0%)")
})

test_that("check_na validates show_all as a non-missing logical scalar", {
  for (value in list(NA, NULL, c(TRUE, FALSE), 1)) {
    expect_error(check_na(data.frame(x = 1), show_all = value),
                 "single non-missing logical")
  }
})

test_that("check_na counts whitespace-only and whitespace-normalized markers", {
  values <- c("", " ", "\t", "\r\n", "Not  available", "not\tavailable",
              "Unknown / N/A", "Canada", NA_character_)
  data <- data.frame(text = values, factor = factor(values))
  seen <- capture_gt_data(check_na(data, show_all = TRUE))

  expect_identical(seen[[1L]]$special_combined, rep("7 (77.8%)", 2L))
  expect_identical(seen[[1L]]$missing_combined, rep("1 (11.1%)", 2L))
})

test_that("lv uses the same whitespace-normalized special-value counts", {
  data <- data.frame(text = c(" ", "\t", "Not  available", "ok", NA_character_),
                     factor = factor(c("", "\r\n", "not\tavailable", "ok", NA)))
  seen <- capture_gt_data(lv(data))
  tab <- Filter(function(x) "n_special" %in% names(x), seen)[[1L]]

  expect_equal(as.numeric(tab$n_special), c(3, 3))
})

unicode_special_values_data <- function() {
  words <- c("na\u00efve", "NA\u00cfVE", "na\u00efve T cells", "Canada", "NACT",
             "Unknown", "N/A", "Blank(s)", "missing data")
  spaces <- c("\u00a0", "\u202f", "\u2007", "\u0085", "\u3000",
              "not\u00a0available", "ok", "ok", NA_character_)
  data.frame(words = words, word_factor = factor(words),
             spaces = spaces, space_factor = factor(spaces))
}

test_that("check_na respects Unicode words and whitespace", {
  seen <- capture_gt_data(check_na(unicode_special_values_data(), show_all = TRUE))
  tab <- seen[[1L]]
  counts <- stats::setNames(tab$special_combined, tab$variable)
  missing <- stats::setNames(tab$missing_combined, tab$variable)

  expect_identical(unname(counts[c("words", "word_factor")]), rep("4 (44.4%)", 2L))
  expect_identical(unname(counts[c("spaces", "space_factor")]), rep("6 (66.7%)", 2L))
  expect_identical(unname(missing[c("spaces", "space_factor")]), rep("1 (11.1%)", 2L))
})

test_that("lv uses the same Unicode special-value semantics", {
  seen <- capture_gt_data(lv(unicode_special_values_data()))
  tab <- Filter(function(x) "n_special" %in% names(x), seen)[[1L]]
  counts <- stats::setNames(as.numeric(tab$n_special), tab$vars)

  expect_equal(unname(counts[c("words", "word_factor")]), c(4, 4))
  expect_equal(unname(counts[c("spaces", "space_factor")]), c(6, 6))
})

spss_special_values_data <- function() {
  codes <- list(marker = "Unknown", blank = "", both = c("Unknown", ""))
  as.data.frame(lapply(codes, function(code) {
    structure(c("Unknown", "", NA_character_, "ok", "Unknown"),
              class = c("haven_labelled_spss", "haven_labelled", "vctrs_vctr",
                        "character"), na_values = code)
  }))
}

test_that("check_na counts SPSS user missings only as missing values", {
  data <- spss_special_values_data()
  expect_identical(unname(vapply(data, function(x) sum(is.na(x)), integer(1))),
                   c(3L, 2L, 4L))
  seen <- capture_gt_data(result <- check_na(data, show_all = TRUE))
  tab <- seen[[1L]]
  special <- stats::setNames(tab$special_combined, tab$variable)
  missing <- stats::setNames(tab$missing_combined, tab$variable)

  expect_identical(unname(special[names(data)]),
                   c("1 (20.0%)", "2 (40.0%)", "0 (0.0%)"))
  expect_identical(unname(missing[names(data)]),
                   c("3 (60.0%)", "2 (40.0%)", "4 (80.0%)"))
  expect_identical(result, data)
})

test_that("lv excludes SPSS user missings from special-value counts", {
  seen <- capture_gt_data(lv(spss_special_values_data()))
  tab <- Filter(function(x) "n_special" %in% names(x), seen)[[1L]]

  expect_equal(as.numeric(tab$n_special), c(1, 2, 0))
  expect_equal(as.numeric(tab$n_na), c(3, 2, 4))
})

test_that("check_na rounds percentages only when formatting them", {
  for (case in list(c(6L, 13L, "46.2"), c(1L, 26L, "3.8"))) {
    count <- as.integer(case[[1L]])
    n <- as.integer(case[[2L]])
    data <- data.frame(missing = c(rep(NA_real_, count), rep(1, n - count)),
                       special = c(rep("Unknown", count), rep("ok", n - count)))
    seen <- capture_gt_data(check_na(data))
    tab <- seen[[1L]]
    expected <- paste0(count, " (", case[[3L]], "%)")

    expect_identical(tab$missing_combined[tab$variable == "missing"], expected)
    expect_identical(tab$special_combined[tab$variable == "special"], expected)
  }
})

test_that("check_na assigns severity styles using unrounded proportions", {
  n <- 100000L
  data <- data.frame(
    missing_medium = c(rep(NA_real_, 20001L), rep(1, n - 20001L)),
    missing_high = c(rep(NA_real_, 50001L), rep(1, n - 50001L)),
    missing_rare = c(NA_real_, rep(1, n - 1L)),
    special_medium = c(rep("Unknown", 10001L), rep("ok", n - 10001L)),
    special_high = c(rep("Unknown", 30001L), rep("ok", n - 30001L)),
    special_rare = c("Unknown", rep("ok", n - 1L))
  )
  tab <- capture_gt_table(check_na(data))
  fills <- function(variable, column) {
    row <- match(variable, tab[["_data"]]$variable)
    styles <- tab[["_styles"]]
    cells <- styles$styles[styles$colname == column & styles$rownum == row]
    unlist(lapply(cells, function(x) x[["cell_fill"]][["color"]]),
           use.names = FALSE)
  }

  expect_identical(fills("missing_medium", "missing_combined"), "#FFCC80")
  expect_identical(fills("missing_high", "missing_combined"), "#FFCDD2")
  expect_identical(fills("missing_rare", "missing_combined"), "#FFF176")
  # Special-value fills darken with severity.
  expect_identical(fills("special_medium", "special_combined"), "#BBDEFB")
  expect_identical(fills("special_high", "special_combined"), "#90CAF9")
  expect_identical(fills("special_rare", "special_combined"), "#E3F2FD")
})

test_that("check_na validates pattern as NULL or one non-missing string", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  invalid <- list(NA_character_, character(), c("^a$", "^b$"), 1, TRUE,
                  factor("a"), list("a"))
  for (pattern in invalid) {
    expect_error(capture_gt_data(check_na(data, pattern = pattern)),
                 "single non-missing character string")
  }
})

test_that("check_na retains empty patterns and pattern precedence", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  all <- capture_gt_data(check_na(data, dplyr::starts_with("absent"), pattern = ""))
  selected <- capture_gt_data(result <- check_na(data, a, pattern = "^b$"))

  expect_setequal(all[[1L]]$variable, names(data))
  expect_identical(selected[[1L]]$variable, "b")
  expect_identical(result, data)
})

test_that("check_na distinguishes affected variables from missing cells", {
  data <- data.frame(missing = c(NA, NA, 3, 4),
                     special = c("Unknown", "Unknown", "ok", "ok"),
                     complete = 1:4)
  tab <- capture_gt_table(check_na(data))
  subtitle <- as.character(tab[["_heading"]][["subtitle"]])

  expect_match(subtitle, "*4* observations, *3* variables", fixed = TRUE)
  expect_match(subtitle, "*1* variables with missing values", fixed = TRUE)
  expect_match(subtitle, "*1* variables with special values", fixed = TRUE)
  html <- gt::as_raw_html(tab)
  expect_match(html, "2 missing values (16.67%)", fixed = TRUE)
  expect_match(html, "2 special values (16.67%)", fixed = TRUE)
})

# Load only the inspection sources in a fresh process: load_all() would preload
# Imports and hide missing S3 registrations. Installed checks use the namespace.
inspect_in_fresh_r <- function(data, entry = "check_na") {
  files <- c(script = tempfile(fileext = ".R"), input = tempfile(fileext = ".rds"),
             output = tempfile(fileext = ".rds"))
  on.exit(unlink(files), add = TRUE)
  saveRDS(data, files[["input"]])
  writeLines(c(
    "local({",
    "  args <- commandArgs(TRUE)",
    "  .libPaths(strsplit(args[[5L]], .Platform[['path.sep']], fixed = TRUE)[[1L]])",
    "  ns <- asNamespace('UtilsR')",
    "  e <- ns",
    "  if (file.exists(args[[1L]])) {",
    "    e <- new.env(parent = ns)",
    "    sys.source(args[[1L]], e)",
    "    if (args[[4L]] == 'lv') {",
    "      sys.source(file.path(dirname(args[[1L]]), 'lv.R'), e)",
    "      registerS3method('lv', 'data.frame', e[['lv.data.frame']], envir = ns)",
    "    }",
    "  }",
    "  seen <- list()",
    "  original <- gt::gt",
    "  testthat::local_mocked_bindings(gt = function(data, ...) {",
    "    seen[[length(seen) + 1L]] <<- data",
    "    original(data, ...)",
    "  }, .package = 'gt')",
    "  before <- c(haven = 'haven' %in% loadedNamespaces(),",
    "              bit64 = 'bit64' %in% loadedNamespaces())",
    "  available <- length(find.package('bit64', quiet = TRUE)) > 0L",
    "  data <- readRDS(args[[2L]])",
    "  f <- if (args[[4L]] == 'lv') getExportedValue('UtilsR', 'lv') else e[['check_na']]",
    "  error <- NULL",
    "  returned <- NULL",
    "  output <- capture.output(tryCatch(suppressMessages({",
    "    returned <- if (args[[4L]] == 'lv') f(data) else f(data, show_all = TRUE)",
    "  }), error = function(cnd) { error <<- conditionMessage(cnd) }))",
    "  saveRDS(list(before = before, available = available, error = error,",
    "               tables = seen, returned = returned), args[[3L]])",
    "})"
  ), files[["script"]])
  source <- normalizePath(testthat::test_path("..", "..", "R", "na.R"),
                          winslash = "/", mustWork = FALSE)
  executable <- file.path(R.home("bin"), if (.Platform$OS.type == "windows")
    "Rscript.exe" else "Rscript")
  previous_tests <- Sys.getenv("R_TESTS", unset = NA_character_)
  Sys.unsetenv("R_TESTS")
  on.exit(if (is.na(previous_tests)) Sys.unsetenv("R_TESTS") else
    Sys.setenv(R_TESTS = previous_tests), add = TRUE)
  output <- system2(executable,
    c("--vanilla", shQuote(files[["script"]]), shQuote(source),
      shQuote(files[["input"]]), shQuote(files[["output"]]), entry,
      shQuote(paste(.libPaths(), collapse = .Platform$path.sep))),
    stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(output, "status")) || !file.exists(files[["output"]])) {
    stop(paste(output, collapse = "\n"))
  }
  readRDS(files[["output"]])
}

test_that("inspection registers SPSS methods in a fresh R process", {
  data <- spss_special_values_data()
  data$numeric <- structure(c(1, 9, NA_real_, 1, 1),
    class = c("haven_labelled_spss", "haven_labelled", "vctrs_vctr", "double"),
    na_values = 9)
  for (entry in c("check_na", "lv")) {
    result <- inspect_in_fresh_r(data, entry)
    expect_false(result$before[["haven"]])
    expect_null(result$error)
    if (!is.null(result$error)) next
    if (entry == "check_na") {
      tab <- result$tables[[1L]]
      counts <- stats::setNames(tab$missing_combined, tab$variable)
      expect_identical(unname(counts[names(data)]),
                       c("3 (60.0%)", "2 (40.0%)", "4 (80.0%)", "2 (40.0%)"))
      expect_identical(result$returned, data)
    } else {
      tab <- Filter(function(x) "n_na" %in% names(x), result$tables)[[1L]]
      expect_equal(as.numeric(tab$n_na), c(3, 2, 4, 2))
      expect_equal(as.numeric(tab$n_special), c(1, 2, 0, 0))
    }
  }
})

test_that("inspection registers integer64 methods in a fresh R process", {
  # IEEE negative zero is bit64's NA sentinel; ordinary zero is integer64 zero.
  data <- structure(list(x = structure(c(0, -0.0, 0), class = "integer64")),
                    class = "data.frame", row.names = c(NA_integer_, -3L))
  for (entry in c("check_na", "lv")) {
    result <- inspect_in_fresh_r(data, entry)
    expect_false(result$before[["bit64"]])
    if (!result$available) {
      expect_match(result$error, "bit64")
    } else {
      expect_null(result$error)
      if (!is.null(result$error)) next
      if (entry == "check_na") {
        expect_identical(result$tables[[1L]]$missing_combined, "1 (33.3%)")
        expect_identical(result$returned, data)
      } else {
        tab <- Filter(function(x) "n_na" %in% names(x), result$tables)[[1L]]
        expect_equal(as.numeric(tab$n_na), 1)
      }
    }
  }
})

test_that("check_na handles totals above the integer limit", {
  # Shared column storage keeps this valid 2.2-billion-cell fixture compact.
  n <- 2000000L
  p <- 1100L
  data <- structure(stats::setNames(rep(list(rep(NA_real_, n)), p),
                                    paste0("V", seq_len(p))),
                    class = "data.frame", row.names = c(NA_integer_, -n))
  tab <- capture_gt_table(check_na(data))
  note <- paste(unlist(tab[["_source_notes"]]), collapse = " ")

  expect_identical(tab[["_data"]]$missing_combined[[1L]], "2000000 (100.0%)")
  expect_match(note, "2200000000 missing values (100.00%)", fixed = TRUE)
  expect_match(note, "0 special values (0.00%)", fixed = TRUE)
  expect_match(note, "out of 2200000000 total data points", fixed = TRUE)
})

test_that("inspection preserves factors with unused and missing levels", {
  data <- data.frame(
    ordered = ordered(c("ok", "Unknown", NA, "Unknown"),
                      levels = c("ok", "Unknown", "", "unused")),
    na_level = factor(c("ok", NA, "ok", NA),
                      levels = c("ok", NA, "Unknown"), exclude = NULL)
  )
  before <- data
  seen <- capture_gt_data(result <- check_na(data, show_all = TRUE))
  counts <- stats::setNames(seen[[1L]]$special_combined, seen[[1L]]$variable)

  expect_identical(unname(counts[names(data)]), c("2 (50.0%)", "0 (0.0%)"))
  expect_identical(result, before)
  expect_identical(data, before)
  tab <- Filter(function(x) "n_special" %in% names(x),
                capture_gt_data(lv(data["ordered"])))[[1L]]
  expect_equal(as.numeric(tab$n_special), 2)
  expect_identical(data, before)
})

test_that("check_na distinguishes small positive percentages from zero", {
  n <- 20000L
  data <- data.frame(
    missing_rare = c(NA, rep("ok", n - 1L)),
    missing_near = c(rep(NA, 19L), rep("ok", n - 19L)),
    missing_at = c(rep(NA, 20L), rep("ok", n - 20L)),
    special_rare = c("Unknown", rep("ok", n - 1L)),
    special_near = c(rep("Unknown", 19L), rep("ok", n - 19L)),
    special_at = c(rep("Unknown", 20L), rep("ok", n - 20L)),
    clean = rep("ok", n)
  )
  tab <- capture_gt_table(result <- check_na(data, show_all = TRUE))
  missing <- stats::setNames(tab[["_data"]]$missing_combined, tab[["_data"]]$variable)
  special <- stats::setNames(tab[["_data"]]$special_combined, tab[["_data"]]$variable)
  expected <- c("1 (<0.1%)", "19 (<0.1%)", "20 (0.1%)", "0 (0.0%)")

  expect_identical(unname(missing[c("missing_rare", "missing_near", "missing_at", "clean")]),
                   expected)
  expect_identical(unname(special[c("special_rare", "special_near", "special_at", "clean")]),
                   expected)
  expect_identical(result, data)
  expect_true(grepl("1 (&lt;0.1%)", gt::as_raw_html(tab), fixed = TRUE))
})

test_that("check_na formats tiny summary proportions and their boundaries", {
  n <- 100000L
  for (marker in c(NA_character_, "Unknown")) {
    kind <- if (is.na(marker)) "missing" else "special"
    for (count in c(0L, 1L, 6L, 10L)) {
      data <- data.frame(x = c(rep(marker, count), rep("ok", n - count)))
      tab <- capture_gt_table(check_na(data, show_all = TRUE))
      note <- paste(unlist(tab[["_source_notes"]]), collapse = " ")
      pct <- if (count == 0L) "0.00%" else if (count < 10L) "<0.01%" else "0.01%"
      expected <- sprintf("%d %s values (%s)", count, kind, pct)

      expect_match(note, expected, fixed = TRUE)
      expect_true(grepl(sub("<", "&lt;", expected, fixed = TRUE),
                        gt::as_raw_html(tab), fixed = TRUE))
    }
  }
})
