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
  expect_identical(fills("special_medium", "special_combined"), "#BBDEFB")
  expect_identical(fills("special_high", "special_combined"), "#E3F2FD")
  expect_identical(fills("special_rare", "special_combined"), "#E1F5FE")
})
