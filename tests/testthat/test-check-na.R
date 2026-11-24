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

test_that("check_na returns its gt table visibly after inspecting selected columns", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  attr(data, "source") <- "original"
  before <- data
  seen <- capture_gt_data(result <- withVisible(check_na(data, a)))

  expect_s3_class(result$value, "gt_tbl")
  expect_true(result$visible)
  expect_identical(result$value[["_data"]]$variable, "a")
  expect_identical(seen[[1L]]$variable, "a")
  expect_identical(data, before)
})

test_that("check_na returns NULL invisibly when selected columns have no issues", {
  data <- data.frame(a = c(1, NA), b = c("ok", "ok"))
  seen <- capture_gt_data(result <- withVisible(check_na(data, b)))

  expect_null(result$value)
  expect_false(result$visible)
  expect_length(seen, 0L)
})

test_that("check_na inspects renamed selections without changing the input", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  seen <- capture_gt_data(result <- check_na(data, renamed = a))

  expect_identical(seen[[1L]]$variable, "renamed")
  expect_identical(seen[[1L]]$missing_combined, "1 (50.0%)")
  expect_s3_class(result, "gt_tbl")
})

test_that("check_na does not expand unmatched selections to every column", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  selected <- capture_gt_data(result <- check_na(data, dplyr::starts_with("absent")))
  patterned <- capture_gt_data(check_na(data, pattern = "^absent"))

  expect_length(selected, 0L)
  expect_length(patterned, 0L)
  expect_null(result)
})

test_that("check_na selects grouped inputs across all rows", {
  data <- dplyr::group_by(data.frame(group = c("A", "B"), x = c(1, NA)), group)
  all <- capture_gt_data(result <- check_na(data, show_all = TRUE))
  selected <- capture_gt_data(check_na(data, x, show_all = TRUE))

  expect_setequal(all[[1L]]$variable, c("group", "x"))
  expect_identical(selected[[1L]]$variable, "x")
  expect_identical(selected[[1L]]$missing_combined, "1 (50.0%)")
  expect_s3_class(result, "gt_tbl")
})

test_that("check_na returns empty inputs without constructing percentages", {
  inputs <- list(data.frame(x = numeric()), data.frame(row.names = 1:2),
                 data.frame())
  for (data in inputs) {
    for (show_all in c(FALSE, TRUE)) {
      seen <- capture_gt_data(result <- withVisible(check_na(data, show_all = show_all)))
      expect_null(result$value)
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
  expect_s3_class(result, "gt_tbl")
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
  expect_warning(
    all <- capture_gt_data(check_na(data, dplyr::starts_with("absent"), pattern = "")),
    "selection in `...` is ignored"
  )
  expect_warning(
    selected <- capture_gt_data(result <- check_na(data, a, pattern = "^b$")),
    "selection in `...` is ignored"
  )

  expect_setequal(all[[1L]]$variable, names(data))
  expect_identical(selected[[1L]]$variable, "b")
  expect_s3_class(result, "gt_tbl")
  expect_no_warning(capture_gt_data(check_na(data, pattern = "^b$")))
})

test_that("check_na reports invalid pattern regular expressions", {
  data <- data.frame(a = c(1, NA), b = c("ok", "Unknown"))
  for (pattern in c("(", "a{2")) {
    expect_error(capture_gt_data(check_na(data, pattern = pattern)),
                 "must be a valid regular expression")
  }
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

test_that("check_na explains its severity shading under the table", {
  data <- data.frame(missing = c(NA, 2), special = c("Unknown", "ok"))
  tab <- capture_gt_table(check_na(data))
  note <- paste(unlist(tab[["_source_notes"]]), collapse = " ")

  expect_match(note, "missing values >0-20% yellow, >20-50% orange, >50% red",
               fixed = TRUE)
  expect_match(note, "special values >0-10%, >10-30%, >30% light to dark blue",
               fixed = TRUE)
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
      expect_s3_class(result$returned, "gt_tbl")
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
        expect_s3_class(result$returned, "gt_tbl")
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
  expect_s3_class(result, "gt_tbl")
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
  expect_s3_class(result, "gt_tbl")
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

extended_special_values_data <- function() {
  values <- c("Blanks", "Unknowns", "Not applicable", "not  stated",
              "Not reported", "NULL", "?", "-", "...", "None", "nullable",
              "3.5", "-1", "Unknown primary site", "ok", NA_character_)
  data.frame(text = values, factor = factor(values))
}

test_that("check_na recognizes plural and extended built-in markers", {
  seen <- capture_gt_data(check_na(extended_special_values_data(), show_all = TRUE))

  # Ten markers plus a category that contains "Unknown"; None, nullable,
  # numbers and NA are not special.
  expect_identical(seen[[1L]]$special_combined, rep("10 (62.5%)", 2L))
})

test_that("lv uses the extended built-in markers", {
  seen <- capture_gt_data(lv(extended_special_values_data()))
  tab <- Filter(function(x) "n_special" %in% names(x), seen)[[1L]]

  expect_equal(as.numeric(tab$n_special), c(10, 10))
})

test_that("check_na special replaces the built-in markers", {
  data <- data.frame(text = c("None", "NONE", "not  stated", "Unknown", "", "ok", NA),
                     stringsAsFactors = TRUE)
  count <- function(special) {
    seen <- capture_gt_data(check_na(data, special = special, show_all = TRUE))
    seen[[1L]]$special_combined
  }

  expect_identical(count(NULL), "3 (42.9%)")
  expect_identical(count("^none$"), "2 (28.6%)")
  expect_identical(count(c("^none$", "\\bnot stated\\b")), "3 (42.9%)")
  expect_identical(count(character()), "0 (0.0%)")
  expect_identical(count("^$"), "1 (14.3%)")
})

test_that("check_na matches custom regular expressions independently", {
  cases <- list(
    list(values = c("aa", "abab", "AA", "ab", "ok", NA_character_),
         special = c("^(a)\\1$", "^(ab)\\1$"), count = "3 (50.0%)"),
    list(values = c("aa", "bb", "AA", "ab", "ok", NA_character_),
         special = c("^(?<same>a)\\k<same>$", "^(?<same>b)\\k<same>$"),
         count = "3 (50.0%)"),
    list(values = c("beta", "BETA", "ok", "no", NA_character_),
         special = c("(*UTF)^beta$", "^ok$"), count = "3 (60.0%)"),
    list(values = c("aa", "AA", "beta", "no", NA_character_),
         special = c("(?x)^aa$ # trailing comment", "^beta$"),
         count = "3 (60.0%)"),
    list(values = c("aa", "AA", "b b", "bb", "ok", NA_character_),
         special = c("(?x-i)^a a$", "^b b$"), count = "2 (33.3%)"),
    list(values = c("na", "NA", "\u00e9na", "\u4e2dna", "ok", NA_character_),
         special = c("\\bna\\b", "^ok$"), count = "3 (50.0%)")
  )
  for (case in cases) {
    data <- data.frame(text = case$values, factor = factor(case$values))
    before <- data
    seen <- capture_gt_data(result <- check_na(
      data, special = case$special, show_all = TRUE
    ))

    expect_identical(seen[[1L]]$special_combined, rep(case$count, 2L))
    expect_s3_class(result, "gt_tbl")
    expect_identical(data, before)
  }
})

test_that("check_na counts overlapping custom matches once after normalization", {
  values <- c("Unknown / N/A", "Unknown / N/A", "not\tstated", "", "ok", NA)
  data <- data.frame(text = values, factor = factor(values))
  seen <- capture_gt_data(check_na(
    data, special = c("\\bunknown\\b", "\\bn/a\\b", "^not stated$", "^$"),
    show_all = TRUE
  ))

  expect_identical(seen[[1L]]$special_combined, rep("4 (66.7%)", 2L))
  expect_identical(seen[[1L]]$missing_combined, rep("1 (16.7%)", 2L))
})

test_that("check_na reports through the print helpers", {
  shown <- function(expr) cli::ansi_strip(utils::capture.output(expr))
  # assign the returned gt table, which capture.output() would otherwise print
  expect_identical(shown(res <- check_na(data.frame(a = c(1, NA), b = 1:2))),
                   "<check_na> 1 variables with data quality issues")
  expect_identical(shown(res <- check_na(data.frame(a = c(1, NA), b = 1:2),
                                         show_all = TRUE)),
                   "<check_na> showing all 2 variables")
  expect_identical(shown(check_na(data.frame(a = 1:3))),
                   "<check_na> no missing or special values found")
  expect_identical(shown(check_na(data.frame(a = 1)[0, , drop = FALSE])),
                   "# No observations available for data quality analysis.")
})

test_that("check_na validates special", {
  data <- data.frame(text = c("None", "ok"))
  for (special in list(NA_character_, c("a", NA), 1, TRUE, list("a"))) {
    expect_error(capture_gt_data(check_na(data, special = special)),
                 "NULL or a character vector")
  }
  expect_error(capture_gt_data(check_na(data, special = c("^none$", "("))),
               "valid regular expressions")
})

test_that("missing-value report controls reject arrays before column inspection", {
  d <- data.frame(x = c(1, NA))
  expect_error(check_na(d, show_all = matrix(TRUE)), "show_all")
  expect_error(check_na(d, pattern = matrix("x")), "pattern")
  expect_error(check_na(d, special = matrix("unknown")), "special")
})

test_that("complete inspection columns avoid allocating missing masks", {
  fn <- .count_missing_values
  e <- new.env(parent = environment(fn))
  examined <- 0L
  e$is.na <- function(x) {
    examined <<- examined + length(x)
    base::is.na(x)
  }
  environment(fn) <- e
  expect_identical(fn(seq_len(20000L)), 0L)
  expect_identical(fn(rep(c("yes", "no"), 10000L)), 0L)
  expect_equal(examined, 0L)
  expect_identical(fn(c(1, NaN, NA_real_, 3)), 2L)
  expect_identical(fn(factor(c("a", NA))), 1L)
})

test_that("quality reports format only displayed variables", {
  d <- as.data.frame(setNames(rep(list(1:4), 64L), paste0("complete", seq_len(64L))))
  d$missing <- c(1, 2, NA, 4)
  fn <- check_na
  env <- new.env(parent = environment(fn))
  formatted <- integer()
  env$sprintf <- function(fmt, ...) {
    if (identical(fmt, "%.0f (%s)")) formatted <<- c(formatted, length(list(...)[[1L]]))
    base::sprintf(fmt, ...)
  }
  environment(fn) <- env
  seen <- capture_gt_data(fn(d))
  expect_identical(formatted, c(1L, 1L))
  expect_identical(seen[[1L]]$missing_combined, "1 (25.0%)")
})

test_that("quality reports style only occupied severity ranges", {
  style_calls <- 0L
  native <- gt::tab_style
  local_mocked_bindings(tab_style = function(data, style, locations) {
    style_calls <<- style_calls + 1L
    native(data, style, locations)
  }, .package = "gt")
  quiet <- function(d) invisible(utils::capture.output(check_na(d, show_all = TRUE)))
  quiet(data.frame(a = 1:4))
  expect_identical(style_calls, 2L)
  style_calls <- 0L
  quiet(data.frame(a = c(1, 2, 3, NA)))
  expect_identical(style_calls, 4L)
})

test_that("clean character values avoid building special membership", {
  x <- rep(paste0("identifier", seq_len(500L)), 2L)
  fn <- .count_special_values
  env <- new.env(parent = environment(fn))
  env$match <- function(x, table, ...) {
    if (length(x) == 1000L) stop("full character membership")
    base::match(x, table, ...)
  }
  environment(fn) <- env
  expect_equal(fn(x), 0)
  with_markers <- c(x, "missing", "unknown", NA_character_, "n/a", "unknown")
  expect_equal(fn(with_markers), 4)
  expect_equal(fn(with_markers, c("^unknown$", "^missing$")), 3)
})

test_that("quality marker patterns skip matched values", {
  fn <- .is_special_value
  env <- new.env(parent = environment(fn))
  scanned <- integer()
  env$grepl <- function(pattern, x, ...) {
    if (startsWith(pattern, "(*UCP)")) scanned <<- c(scanned, length(x))
    base::grepl(pattern, x, ...)
  }
  environment(fn) <- env
  x <- c(paste0("missing", seq_len(40L)), "not available", "normal", NA_character_)
  hits <- fn(x, c("^missing[0-9]+$", "^not available$", "^normal$", "anything"))
  expect_identical(hits, c(rep(TRUE, 42L), FALSE))
  expect_identical(scanned, c(42L, 2L, 1L))
})

test_that("special marker checks rewrite only whitespace labels", {
  fn <- .is_special_value
  env <- new.env(parent = environment(fn))
  normalizations <- integer()
  env$gsub <- function(pattern, replacement, x, ...) {
    n <- length(x)
    normalizations <<- c(normalizations, n)
    base::gsub(pattern, replacement, x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(c("Unknown", "USA", "", NA_character_)), c(TRUE, FALSE, TRUE, FALSE))
  expect_identical(normalizations, integer())
  expect_identical(fn(c("not   available", "ok", "  ")), c(TRUE, FALSE, TRUE))
  expect_identical(normalizations, c(2L, 2L))
})

test_that("quality reports skip constructing clean variable rows", {
  d <- data.frame(clean = c(12, 13, 14), issue = c("A", "Unknown", NA))
  fn <- check_na
  env <- new.env(parent = environment(fn))
  env$class <- function(x) {
    if (identical(x, d$clean)) stop("classified a clean variable for display")
    base::class(x)
  }
  environment(fn) <- env
  expected <- check_na(d)
  result <- fn(d)
  expect_identical(result[["_data"]], expected[["_data"]])
  expect_identical(result[["_data"]]$variable, "issue")
  expect_identical(check_na(d, show_all = TRUE)[["_data"]]$variable, c("issue", "clean"))
})

test_that("data quality factor tallies reuse observed level counts", {
  f <- factor(c("ok", "Unknown", NA, NA, ""), levels = c("ok", "Unknown", "", NA), exclude = NULL)
  is.na(f)[4L] <- TRUE
  d <- data.frame(stage = f, other = 1:5)
  fn <- check_na
  env <- new.env(parent = environment(fn))
  env$.count_missing_values <- function(x) {
    if (is.factor(x)) stop("recounted factor missing values")
    .count_missing_values(x)
  }
  environment(fn) <- env
  for (special in list(NULL, "Unknown", character())) {
    actual <- capture_gt_data(fn(d, show_all = TRUE, special = special))[[1L]]
    expected <- capture_gt_data(check_na(d, show_all = TRUE, special = special))[[1L]]
    expect_identical(actual, expected)
    expect_identical(.count_missing_values(f), 1L)
  }
})

test_that("disabled special markers skip unused factor level tables", {
  values <- structure(c(1L, NA_integer_, 2L, 3L, 1L),
    levels = c("Unknown", NA, "present", paste0("unused", seq_len(20000L))),
    class = c("ordered", "factor"))
  d <- data.frame(values = values)
  expected <- capture_gt_data(check_na(d, special = character(), show_all = TRUE))[[1L]]
  fn <- check_na
  env <- new.env(parent = environment(fn))
  env$tabulate <- function(x, ...) {
    if (is.factor(x)) stop("tabulated factor levels with markers disabled")
    base::tabulate(x, ...)
  }
  environment(fn) <- env
  actual <- capture_gt_data(fn(d, special = character(), show_all = TRUE))[[1L]]
  expect_identical(actual, expected)
  expect_identical(.count_missing_values(values), 1L)
})

test_that("data quality tallies only observed sparse factor levels", {
  values <- structure(c(1L, NA_integer_, 2L, 3L, 1L, 4L),
    levels = c("Unknown", NA, "present", "", paste0("unused", seq_len(20000L))),
    class = c("ordered", "factor"))
  d <- data.frame(values = values)
  fn <- check_na
  env <- new.env(parent = environment(fn))
  env$tabulate <- function(bin, nbins = max(1L, bin, na.rm = TRUE)) {
    if (nbins > length(values)) stop("allocated tally bins for unused levels")
    base::tabulate(bin, nbins)
  }
  environment(fn) <- env
  for (special in list(NULL, "Unknown")) {
    expected <- capture_gt_data(check_na(d, special = special, show_all = TRUE))[[1L]]
    actual <- capture_gt_data(fn(d, special = special, show_all = TRUE))[[1L]]
    expect_identical(actual, expected)
  }
})

test_that("entirely special columns skip rescanning their marker membership", {
  x <- rep(c("Unknown", "", "Not Available"), 200L)
  fn <- .count_special_values
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(x, table) {
    if (length(x) == 600L) stop("rescanned entirely special values")
    base::'%in%'(x, table)
  }
  environment(fn) <- env
  expect_identical(fn(x), as.double(length(x)))
  expect_identical(fn(c("known", "Unknown", NA_character_)), 1)
})

test_that("quality displays construct only their four output columns", {
  d <- data.frame(a = c("unknown", "ok", NA), b = c(1L, NA_integer_, 3L))
  expected <- capture_gt_data(check_na(d))
  original <- dplyr::mutate
  local_mocked_bindings(mutate = function(.data, ...) {
    if (all(c("missing_count", "special_count", "missing_percentage") %in% names(.data)))
      stop("mutated the full quality summary")
    original(.data, ...)
  }, .package = "dplyr")
  expect_identical(capture_gt_data(check_na(d)), expected)
})

test_that("first custom marker scan keeps the supplied value vector", {
  x <- rep(c("A", "B", "C", "D"), 30L)
  patterns <- c("^a$", "^(B|C)$")
  fn <- .is_special_value
  env <- new.env(parent = environment(fn))
  env[["["]] <- function(x, i, ...) {
    if (identical(substitute(i), quote(remaining)) && identical(x, rep(c("A", "B", "C", "D"), 30L)) &&
        length(i) == length(x)) stop("copied all special-marker inputs")
    base::"["(x, i, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x, patterns), rep(c(TRUE, TRUE, TRUE, FALSE), 30L))
  expect_identical(fn(c("A", NA, "C", "D"), patterns), c(TRUE, FALSE, TRUE, FALSE))
})

test_that("missingness shading preserves threshold edges with a single partition", {
  rates <- c(0, 1, 10, 11, 20, 21, 30, 31, 50, 51)
  d <- as.data.frame(setNames(lapply(rates, function(n) c(rep(NA, n), rep(1, 100L - n))),
    paste0("x", rates)))
  for (n in rates) d[[paste0("s", n)]] <- c(rep("Unknown", n), rep("value", 100L - n))
  expected <- capture_gt_table(check_na(d, show_all = TRUE))
  fn <- check_na
  env <- new.env(parent = environment(fn))
  env[[">"]] <- function(e1, e2) {
    if (identical(substitute(e1), quote(res_na$missing_percentage)) ||
        identical(substitute(e1), quote(res_na$special_percentage))) {
      stop("rescanned missingness shading thresholds")
    }
    base::">"(e1, e2)
  }
  environment(fn) <- env
  actual <- capture_gt_table(fn(d, show_all = TRUE))
  expect_identical(actual[["_data"]], expected[["_data"]])
  expect_identical(actual[["_styles"]], expected[["_styles"]])
})

test_that("complete factors skip missing masks with marker detection disabled", {
  d <- data.frame(stage = ordered(rep(c("I", "II", "Unknown"), 70L)),
    incomplete = factor(rep(c("I", NA), 105L)))
  fn <- check_na
  env <- new.env(parent = environment(fn))
  env$is.na <- function(x) {
    if (identical(x, unclass(d$stage))) stop("allocated a complete factor missingness mask")
    base::is.na(x)
  }
  environment(fn) <- env
  args <- list(data = d, special = character(), show_all = TRUE)
  expected <- capture_gt_data(do.call(check_na, args))
  expect_identical(capture_gt_data(do.call(fn, args)), expected)
})

test_that("sparse factor tallies group codes once while preserving explicit NA levels", {
  values <- structure(rep(c(20L, 5L, 20L, NA_integer_, 5001L, 5L), 512L),
    levels = c(as.character(seq_len(5000L)), NA_character_), class = "factor")
  fn <- .factor_tally
  environment(fn) <- list2env(list(match = function(x, table, ...) {
    if (identical(substitute(x), quote(row_codes)) && length(x) > 1024L) stop("rematched sparse factor observations to their observed codes")
    base::match(x, table, ...)
  }), parent = environment(fn))
  expected <- list(codes = c(5L, 20L, 5001L), counts = c(1024L, 1024L, 512L),
    row_codes = as.integer(values))
  expect_identical(fn(values), expected)
  expect_identical(fn(values[0L]), .factor_tally(values[0L]))
})

test_that("quality reports collect both column metrics without a list of pairs", {
  data <- data.frame(f = factor(c("Unknown", NA, "ok")), value = c(1, NA, 2),
    text = c("", "plain", "N/A"))
  fn <- check_na
  environment(fn) <- list2env(list(lapply = function(X, FUN, ...) {
    if (identical(substitute(X), quote(data))) stop("allocated a result list for quality counts")
    base::lapply(X, FUN, ...)
  }), parent = environment(fn))
  for (d in list(data, data["f"])) {
    expect_identical(fn(d, show_all = TRUE)[["_data"]], check_na(d, show_all = TRUE)[["_data"]])
  }
})

test_that("complete factor tallies keep their existing count vector", {
  x <- factor(rep(c("c", "a", "b"), each = 4L))
  fn <- .factor_tally
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(counts)) && identical(i, seq_along(x)))
      stop("copied all observed factor counts")
    base::"["(x, i, ...)
  }), parent = environment(fn))
  expect_identical(fn(x), .factor_tally(x))
  x <- x[x != "a"]
  expect_identical(fn(x), .factor_tally(x))
  expect_identical(fn(factor(character())), .factor_tally(factor(character())))
})

test_that("complete quality summaries order their original count vectors", {
  d <- data.frame(a = c(1, NA, 3), b = c("ok", "N/A", ""), z = c(NA, NA, 3))
  fn <- check_na
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(missing_count)) &&
        identical(i, seq_along(x))) stop("sliced all quality counts before ordering")
    if (missing(i)) base::"["(x, , ...) else base::"["(x, i, ...)
  }), parent = environment(fn))
  expect_identical(capture_gt_data(fn(d, show_all = TRUE)),
                   capture_gt_data(check_na(d, show_all = TRUE)))
})

test_that("complete ordinary factors short circuit missing-value counts", {
  x <- structure(c(1L, 2L, 1L), levels = c("observation", NA_character_), class = c("ordered", "factor"))
  fn <- .count_missing_values
  environment(fn) <- list2env(list(is.na = function(x) {
    if (is.factor(x) && !anyNA(unclass(x))) stop("allocated a complete factor missing mask")
    base::is.na(x)
  }), parent = environment(fn))
  expect_identical(fn(x), 0L)
  expect_identical(fn(c(x, NA)), 1L)
})

test_that("special-value factor counts reuse whole level names", {
  values <- c("unknown", "not applicable", "known", "Another", NA_character_)
  x <- structure(rep(1:5, 12L), levels = values, class = "factor")
  fn <- .count_special_values
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(levels(x)))) stop("copied a complete special factor dictionary")
    if (missing(i)) base::"["(x, , ...) else base::"["(x, i, ...)
  }), parent = environment(fn))
  expect_identical(fn(x), 24)
  expect_identical(fn(x, special = "known"), 24)
  expect_identical(fn(x, special = ".*"), 48)
})

test_that("unique character columns count special values without membership matching", {
  x <- c("UNKNOWN", paste0("identifier_", seq_len(600L)), "  ", NA_character_, "N/A")
  fn <- .count_special_values
  environment(fn) <- list2env(list("%in%" = function(x, table) {
    if (identical(substitute(table), quote(markers)) && !anyDuplicated(x)) stop("rematched unique observations to special values")
    base::"%in%"(x, table)
  }), parent = environment(fn))
  expect_identical(fn(x), 3)
  expect_identical(fn(x, special = "^identifier_10$"), 1)
  expect_identical(fn(c("N/A", "N/A", "test")), 2)
})

test_that("blank markers share the standard marker scan", {
  fn <- .is_special_value
  environment(fn) <- list2env(list(`%in%` = function(x, table) {
    if (identical(table, "")) stop("matched normalized blanks a second time")
    base::`%in%`(x, table)
  }), parent = environment(fn))
  x <- c("", " ", "\u2009\t", NA, "Canada", "Unknown case", "n/a", "--", "null")
  expect_identical(fn(x), c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE))
  expect_identical(fn(x, "^unknown"), c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE))
})

test_that("disabled special markers leave label text unscanned", {
  fn <- .is_special_value
  environment(fn) <- list2env(list(grepl = function(...) {
    stop("normalized labels for disabled special markers")
  }), parent = environment(fn))
  expect_identical(fn(c(" ", "Not available", NA), character()), rep(FALSE, 3L))
  expect_identical(fn(character()), logical())
})

test_that("ordinary factor labels skip empty tally slices", {
  x <- factor(c("local", "regional", NA, "local"), levels = c("local", "regional", "unknown"))
  tally <- .factor_tally(x)
  fn <- .count_special_values
  environment(fn) <- list2env(list(`[` = function(x, i, ...) {
    if (identical(substitute(x), quote(n)) && identical(substitute(i), quote(hit)) &&
        !any(i)) stop("subset a factor tally using all false markers")
    base::`[`(x, i, ...)
  }), parent = environment(fn))
  expect_identical(fn(x, tally = tally), 0)
  expect_identical(fn(x, "local", tally = tally), 2)
})

test_that("wide sparse factor counts use the observed code dictionary", {
  row_codes <- rep(c(4L, 9000L, NA_integer_, 9000L), 260L)
  x <- structure(row_codes, levels = c(as.character(seq_len(8999L)), NA_character_),
                 class = "factor")
  fn <- .factor_tally
  environment(fn) <- list2env(list(duplicated = function(x, ...) {
    if (length(x) == length(row_codes)) stop("built a sparse factor row mask")
    base::duplicated(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(x), list(codes = c(4L, 9000L), counts = c(260L, 520L), row_codes = row_codes))
  expect_identical(fn(rep(x[1L], 1040L))$counts, 1040L)
})

test_that("special marker counts reuse the predicate's missing handling", {
  fn <- .count_special_values
  environment(fn) <- list2env(list(is.na = function(x) {
    if (identical(substitute(x), quote(u))) stop("remasked missing special-value labels")
    base::is.na(x)
  }), parent = environment(fn))
  x <- c("NA", NA_character_, "?", "valid", "NA")
  expect_identical(fn(x), 3)
  expect_identical(fn(addNA(x)), 3)
  expect_identical(fn(x, "^[?]$"), 1)
  expect_identical(fn(addNA(x), "^[?]$"), 1)
})

test_that("known zero percentages skip small positive flags", {
  f <- check_na
  environment(f) <- list2env(list(">" = function(e1, e2) {
    if (length(e1) > 1L && e2 == 0 && identical(substitute(e1), quote(x)) && all(e1 == 0))
      stop("built small-percent flags for zero missingness")
    base::">"(e1, e2)
  }), parent = environment(f))
  d <- data.frame(a = rep("normal", 2000L), b = rep("?", 2000L))
  out <- suppressMessages(f(d, show_all = TRUE))[["_data"]]
  expect_identical(out$missing_combined, rep("0 (0.0%)", 2L))
  d$a[1L] <- NA_character_
  expect_match(suppressMessages(f(d))[["_data"]]$missing_combined[1L], "<0.1%", fixed = TRUE)
})

test_that("columns without missingness skip computing shading bands", {
  f <- check_na
  environment(f) <- list2env(list(findInterval = function(x, ...) {
    if (length(x) && all(x == 0)) stop("built shade bands for unshaded rows")
    base::findInterval(x, ...)
  }), parent = environment(f))
  d <- data.frame(a = c("x", "?"), b = c("x", "y"))
  out <- f(d, show_all = TRUE)
  expect_s3_class(out, "gt_tbl")
  expect_identical(out[["_data"]]$special_combined, c("1 (50.0%)", "0 (0.0%)"))
})

test_that("empty special marker matches do not copy the category dictionary", {
  fn <- .count_special_values
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(u)) && is.logical(i) && !any(i)) stop("unnecessary [ in .count_special_values")
    base::"["(x, i, ...)
  }), parent = environment(fn))
  x <- rep(c("stable", "visible", NA_character_), 500L)
  expect_identical(fn(x), 0)
  expect_identical(fn(x, "^[s]"), 500)
  expect_identical(fn(c(NA, "??", "Unknown", "ok"), NULL), 2)
})

test_that("special patterns without matches retain their remaining row indices", {
  fn <- .is_special_value
  environment(fn) <- list2env(list("[" = function(x, i, ...) {
    if (identical(substitute(x), quote(remaining)) && is.logical(i) &&
        identical(substitute(i), quote(!matched)) && all(i)) stop("unnecessary [ in .is_special_value")
    base::"["(x, i, ...)
  }), parent = environment(fn))
  expect_identical(fn(c("abc", "def", "ghi", NA), c("abc", "not here", "ghi")), c(TRUE, FALSE, TRUE, FALSE))
  expect_identical(fn(c("A A", "B"), c("never", "\\bB\\b")), c(FALSE, TRUE))
})

test_that("one sparse factor code shares its count across all rows", {
  fn <- .factor_tally
  environment(fn) <- list2env(list("tabulate" = function(bin, ...) {
    if (length(bin) >= 1024L && identical(attr(bin, "n"), 1L)) stop("unnecessary tabulate in .factor_tally")
    base::tabulate(bin, ...)
  }), parent = environment(fn))
  labels <- paste0("level", 1:3000)
  d <- factor(rep("level4", 1600L), levels = labels)
  expect_identical(fn(d), list(codes = 4L, counts = 1600L, row_codes = rep(4L, 1600L)))
  d[1:1600] <- NA
  expect_identical(fn(d), list(codes = integer(), counts = integer(), row_codes = rep(NA_integer_, 1600L)))
})

test_that("one instance of every factor level takes its ordered count directly", {
  fn <- .factor_tally
  environment(fn) <- list2env(list("tabulate" = function(bin, nbins = max(1L, bin, na.rm = TRUE)) {
    if (length(bin) == 250L && identical(bin, seq_len(250L))) stop("unexpected tabulate in .factor_tally")
    base::tabulate(bin, nbins = nbins)
  }), parent = environment(fn))
  x <- factor(sprintf("%03d", seq_len(250L)))
  expect_identical(fn(x), list(codes = 1:250, counts = rep.int(1L, 250L), row_codes = 1:250))
  x <- x[c(1:249, NA_integer_)]
  expect_identical(fn(x), .factor_tally(x))
})
