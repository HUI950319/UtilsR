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
