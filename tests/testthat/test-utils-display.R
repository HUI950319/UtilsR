# Capture everything a display helper writes -- stdout and cli messages alike --
# with ANSI colour forced on, so styling can be asserted.
capture_display <- function(expr) {
  withr::local_options(cli.num_colors = 256)
  out <- character()
  msg <- cli::cli_fmt(out <- utils::capture.output(expr))
  c(out, msg)
}

test_that("warning labels use black text on the yellow background", {
  shown <- list(
    line    = function() .cat_line("Sparse levels", type = "warning", width = 40),
    box     = function() .cat_box("Sparse levels", type = "warning"),
    message = function() .cat_message("Sparse levels", type = "warning")
  )
  for (nm in names(shown)) {
    out <- paste(capture_display(shown[[nm]]()), collapse = "\n")
    expect_match(out, "\033[30m", fixed = TRUE, info = nm)
    expect_false(grepl("\033[97m", out, fixed = TRUE), info = nm)
  }

  info <- paste(capture_display(.cat_message("Loaded", type = "info")), collapse = "\n")
  expect_match(info, "\033[97m", fixed = TRUE)
})

test_that(".cat_message() emits a message that suppressMessages() silences", {
  expect_identical(
    utils::capture.output(suppressMessages(.cat_message("Loaded"))),
    character()
  )

  shown <- cli::ansi_strip(cli::cli_fmt(.cat_message("Loaded {n} rows\nsecond line")))
  expect_length(shown, 2L)
  expect_match(shown[1], "Loaded {n} rows", fixed = TRUE)
  expect_match(shown[2], "second line", fixed = TRUE)

  expect_identical(cli::cli_fmt(.cat_message("Loaded", verbose = FALSE)), character())
})

test_that(".cat_message(style = \"chip\") colours only a short type label", {
  out <- capture_display(.cat_message("Loading\nsecond line", type = "warning",
                                      timestamp_format = "%H:%M", style = "chip"))
  plain <- cli::ansi_strip(out)
  expect_match(plain[1], "^[0-9]{2}:[0-9]{2}  WARN  Loading$")
  expect_identical(plain[2], paste0(strrep(" ", 13L), "second line"))
  # the background closes before the message text, which stays unstyled
  expect_match(out[1], "WARN .*\033\\[49m.*Loading$")

  chips <- c(info = " INFO ", success = " DONE ", error = " FAIL ")
  for (type in names(chips)) {
    shown <- cli::ansi_strip(capture_display(.cat_message("x", type = type, style = "chip")))
    expect_match(shown, chips[[type]], fixed = TRUE, info = type)
  }
})
