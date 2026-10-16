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
