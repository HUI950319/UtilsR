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

test_that(".cat_message() prints every element of a vector and nothing for none", {
  out <- cli::ansi_strip(cli::cli_fmt(.cat_message(c("first", "second\nthird"),
                                                   timestamp_format = "%H:%M",
                                                   style = "chip")))
  expect_length(out, 3L)
  expect_match(out[1], "INFO  first$")
  expect_identical(trimws(out[2:3]), c("second", "third"))
  expect_identical(cli::cli_fmt(.cat_message(character())), character())
})

test_that(".cat_message() leaves the timestamp out for NULL or an empty format", {
  for (fmt in list(NULL, "")) {
    chip <- cli::ansi_strip(cli::cli_fmt(.cat_message("Loading\nsecond", style = "chip",
                                                      timestamp_format = fmt)))
    expect_identical(chip, c(" INFO  Loading", paste0(strrep(" ", 7L), "second")))
    full <- sub(" +$", "", cli::ansi_strip(cli::cli_fmt(
      .cat_message("Loading\nsecond", timestamp_format = fmt))))
    expect_identical(full, c(" ℹ Loading", "   second"))
  }
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

test_that(".cat_step() numbers steps and ends each in the caller's frame", {
  run <- function() {
    nm <- "Cox"
    .cat_step("Fitting {nm} models", i = 1, n = 2)
    Sys.sleep(0.25)
    .cat_step("Drawing plot", i = 2, n = 2, msg_done = "Drew plot")
    invisible()
  }
  out <- cli::ansi_strip(cli::cli_fmt(run()))

  # the first step stays open across the sleep, so its time includes it
  done1 <- grep("[1/2] Fitting Cox models [", out, fixed = TRUE, value = TRUE)
  expect_length(done1, 1L)
  expect_match(done1, "\\[(2[0-9]{2}|[3-9][0-9]{2})ms\\]$|\\[[0-9.]+s\\]$")
  expect_true(any(grepl("[2/2] Drew plot [", out, fixed = TRUE)))
  expect_false(any(grepl("[1/2] [1/2]", out, fixed = TRUE)))

  quiet <- function() .cat_step("Fitting", verbose = FALSE)
  expect_identical(cli::cli_fmt(quiet()), character())
})

test_that(".cat_step() shows text cli cannot parse as written", {
  run <- function() .cat_step("Fitting {I, II} models", msg_done = "Fitted {I, II}")
  out <- cli::ansi_strip(cli::cli_fmt(run()))
  expect_true(any(grepl("Fitting {I, II} models", out, fixed = TRUE)))
  expect_true(any(grepl("Fitted {I, II} [", out, fixed = TRUE)))
})

test_that(".cat_message() wraps long lines under the message text", {
  withr::local_options(cli.width = 50)
  msg <- paste(rep("Fitting the multivariable Cox model.", 4), collapse = " ")
  out <- cli::ansi_strip(cli::cli_fmt(.cat_message(msg, timestamp_format = "%H:%M",
                                                   style = "chip")))
  expect_gt(length(out), 1L)
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 50))
  expect_true(all(startsWith(out[-1], strrep(" ", 13L))))
  full <- cli::ansi_strip(cli::cli_fmt(.cat_message(msg, timestamp_format = "%H:%M")))
  expect_gt(length(full), 1L)
  expect_true(all(cli::ansi_nchar(full, type = "width") <= 50))
})

test_that(".cat_saved() reports the path, size and a replaced file", {
  saved <- function(existed) {
    out <- cli::cli_fmt(.cat_saved("the plot has been saved to", "fig.pdf",
                                   "7x5 in", existed, "PDF"))
    gsub("\\s+", " ", paste(cli::ansi_strip(out), collapse = " "))
  }
  expect_match(saved(FALSE), "the plot has been saved to: fig.pdf [7x5 in, new PDF]",
               fixed = TRUE)
  expect_match(saved(TRUE), "[7x5 in, replaced the existing PDF]", fixed = TRUE)
  expect_message(.cat_saved("saved to", "a.docx", "2x3 cells", FALSE, "DOCX"))
})

test_that(".cat_message(wrap = FALSE) keeps a line meant to be copied whole", {
  withr::local_options(cli.width = 50)
  call <- 'save = list(filename = "Figure 1. A long figure title.pdf", width = 7)'
  out <- cli::ansi_strip(cli::cli_fmt(.cat_message(paste0("Laid out\n", call),
                                                   wrap = FALSE)))
  expect_length(out, 2L)
  expect_true(endsWith(trimws(out[2]), call))
})

test_that(".cat_formula() announces a model in one notice line", {
  d <- data.frame(time = 1:4, DSS = c(0, 1, 0, 1), event = c(0, 1, 2, 1))
  one <- function(...) {
    out <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(d, ...))))
    expect_length(out, 1L)
    out
  }
  expect_true(endsWith(one("Sex"), "Cox model, unadjusted: Surv(time, DSS) ~ Sex"))
  expect_true(endsWith(one(c("Sex", "Age"), outcome = "event"),
                       "CRR model, adjusted: Surv(time, event) ~ Sex + Age"))
  expect_true(endsWith(one("Sex", time = NULL),
                       "Logistic model, unadjusted: DSS ~ Sex"))
  expect_message(.cat_formula(d, "Sex"))

  # a missing outcome is not a third level
  d$DSS[2] <- NA
  expect_true(endsWith(one("Sex"), "Cox model, unadjusted: Surv(time, DSS) ~ Sex"))
})
