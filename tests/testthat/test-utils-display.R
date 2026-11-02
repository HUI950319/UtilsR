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
  expect_match(cli::ansi_strip(cli::cli_fmt(.cat_message(c("a", NA), style = "chip")))[2],
               "NA$")
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

test_that("show_color rejects unsupported colour storage before output", {
  withr::local_options(cli.num_colors = 0)
  bad <- list(NULL, NA, TRUE, 1:2, factor(c("red", "blue")),
              matrix("red"), array("red", c(1, 1, 1)), list("red"),
              data.frame(x = "red"), as.Date("2026-11-02"),
              as.POSIXct("2026-11-02", tz = "UTC"),
              as.difftime(1, units = "days"), 1 + 1i,
              structure(c(1, 2), class = "integer64"),
              structure("red", class = "haven_labelled"))
  for (x in bad) {
    out <- capture.output(error <- tryCatch(show_color(x), error = identity))
    expect_s3_class(error, "error")
    if (inherits(error, "error")) expect_match(conditionMessage(error), "`x`", fixed = TRUE)
    expect_identical(out, character())
  }
})

test_that("show_color identifies all invalid colours and numeric palette indices", {
  withr::local_options(cli.num_colors = 0)
  for (bad in c("2", "2.0", "2e0", "+2", " 2", "02", "0x2")) {
    out <- capture.output(error <- tryCatch(show_color(c("red", bad)), error = identity))
    expect_s3_class(error, "error")
    if (inherits(error, "error")) expect_match(conditionMessage(error), "2", fixed = TRUE)
    expect_identical(out, character())
  }
  error <- tryCatch(show_color(c("red", "notacolor", "blue", "2e0")), error = identity)
  expect_s3_class(error, "error")
  for (value in c("`x`", "2", "4", "notacolor", "2e0")) {
    expect_match(conditionMessage(error), value, fixed = TRUE)
  }
})

test_that("show_color reports repeated invalid colours at their original positions", {
  withr::local_options(cli.num_colors = 0, cli.width = 80)
  cols <- setNames(c("red", "notacolor", "red", "notacolor", "2e0", NA_character_),
                   letters[1:6])
  for (named in c(FALSE, TRUE)) {
    x <- if (named) cols else unname(cols)
    out <- capture.output(error <- tryCatch(show_color(x), error = identity))
    expect_s3_class(error, "error")
    text <- conditionMessage(error)
    for (value in c("2", "4", "5", "notacolor", "2e0")) {
      expect_match(text, value, fixed = TRUE)
    }
    expect_identical(out, character())
  }
})

test_that("show_color requires one non-missing logical reverse control", {
  withr::local_options(cli.num_colors = 0)
  for (bad in list(NULL, logical(), NA, 1, 0, "TRUE", c(TRUE, FALSE),
                   matrix(TRUE), structure(TRUE, class = "AsIs"))) {
    out <- capture.output(error <- tryCatch(show_color("red", rev = bad), error = identity))
    expect_s3_class(error, "error")
    if (inherits(error, "error")) expect_match(conditionMessage(error), "`rev`", fixed = TRUE)
    expect_identical(out, character())
  }
  cols <- c(first = "red", second = "blue", third = "#F008")
  out <- capture.output(value <- withVisible(show_color(cols, rev = TRUE)))
  expect_identical(value$value, rev(cols))
  expect_identical(value$visible, FALSE)
  swatches <- out[grepl("^ #", out)]
  expect_match(swatches[[1]], "#FF000088   #0000FF   #FF0000", fixed = TRUE)
})

test_that("show_color contrasts text against quantised terminal backgrounds", {
  withr::local_options(cli.num_colors = 256)
  out <- capture.output(value <- show_color("#008833"))
  expect_match(out[[1]], "\033[38;5;232m", fixed = TRUE)
  expect_match(out[[1]], "\033[48;5;35m", fixed = TRUE)
  expect_identical(value, "#008833")
  # xterm colour 35 is #00AF5F, where the dark text has higher contrast.
  contrast <- colorspace::contrast_ratio("#00AF5F", c("#080808", "#EEEEEE"))
  expect_gt(contrast[[1]], contrast[[2]])
  expect_gt(contrast[[1]], 4.5)
  for (depth in c(8, 16)) {
    options(cli.num_colors = depth)
    out <- capture.output(show_color("#008833"))
    expect_match(out[[1]], "\033[30m", fixed = TRUE)
    expect_match(out[[1]], "\033[42m", fixed = TRUE)
  }
  options(cli.num_colors = 16777216)
  out <- capture.output(show_color("#008833"))
  expect_match(out[[1]], "\033[38;2;255;255;255m", fixed = TRUE)
  expect_match(out[[1]], "\033[48;2;0;136;51m", fixed = TRUE)
})

test_that("show_color preserves missing values, transparency and copyable attributes", {
  withr::local_options(cli.num_colors = 0, cli.width = 40, width = 40)
  cols <- c(missing = NA_character_, literal = "NA", transparent = "transparent",
            alpha = "#FF000080", short = "#00F8", named = "light blue")
  attr(cols, "type") <- "custom"
  for (depth in c(0, 1, 8, 16, 256, 16777216)) {
    options(cli.num_colors = depth)
    out <- capture.output(value <- withVisible(show_color(cols)))
    plain <- cli::ansi_strip(out)
    swatches <- grepl("^ #", plain)
    labels <- unlist(regmatches(plain[swatches], gregexpr("#[0-9A-F]{8}|#[0-9A-F]{6}", plain[swatches])))
    expect_identical(unname(labels), c(rep("#FFFFFF00", 3), "#FF000080", "#0000FF88", "#ADD8E6"))
    expect_identical(value$value, cols)
    expect_identical(value$visible, FALSE)
    expect_identical(eval(parse(text = plain[!swatches])), cols)
    expect_lte(max(nchar(plain[swatches], type = "width")), 40L)
  }
})

test_that("show_color retains an empty character vector and its public signature", {
  withr::local_options(cli.num_colors = 0)
  out <- capture.output(value <- withVisible(show_color(character())))
  expect_identical(value$value, character())
  expect_identical(value$visible, FALSE)
  expect_identical(tail(out, 1), "character(0)")
  expect_identical(names(formals(show_color)), c("x", "rev"))
  expect_identical(formals(show_color)[["rev"]], FALSE)
})

test_that("show_color round-trips numeric attributes without losing precision", {
  withr::local_options(cli.num_colors = 0, cli.width = 40, width = 40)
  cols <- structure(c(A = "red", B = "#FF000080"),
                    breaks = c(1 / 3, pi, 1e-100),
                    note = list(value = 1 / 3 + pi * 1i, count = 2L))
  for (depth in c(0, 1, 8, 16, 256, 16777216)) for (reverse in c(FALSE, TRUE)) {
    options(cli.num_colors = depth)
    out <- capture.output(value <- withVisible(show_color(cols, rev = reverse)))
    plain <- cli::ansi_strip(out)
    copy <- eval(parse(text = plain[!grepl("^ #", plain)]))
    expect_identical(copy, value$value)
    expect_identical(attributes(value$value)[-1], attributes(cols)[-1])
    expect_identical(value$visible, FALSE)
  }
})

test_that("show_color retains duplicate order and original colour spellings", {
  withr::local_options(cli.num_colors = 0, cli.width = 40, width = 40)
  cols <- setNames(c("red", "#F00", "blue", "red", "#F008", "#FF000088",
                     NA_character_, "transparent"), letters[1:8])
  expected <- c("#FF0000", "#FF0000", "#0000FF", "#FF0000", "#FF000088",
                "#FF000088", "#FFFFFF00", "#FFFFFF00")
  for (depth in c(0, 8, 256, 16777216)) for (reverse in c(FALSE, TRUE)) {
    options(cli.num_colors = depth)
    out <- capture.output(value <- withVisible(show_color(cols, rev = reverse)))
    plain <- cli::ansi_strip(out)
    swatches <- grepl("^ #", plain)
    labels <- unlist(regmatches(plain[swatches], gregexpr("#[0-9A-F]{8}|#[0-9A-F]{6}", plain[swatches])))
    expect_identical(unname(labels), if (reverse) rev(expected) else expected)
    expect_identical(value$value, if (reverse) rev(cols) else cols)
    expect_identical(eval(parse(text = plain[!swatches])), value$value)
  }
})

test_that("show_color keeps complete labels within narrow console widths", {
  withr::local_options(cli.num_colors = 0, cli.width = 40, width = 40)
  cols <- c("red", "blue", "#FF000080", NA_character_)
  expected <- c("#FF0000", "#0000FF", "#FF000080", "#FFFFFF00")
  for (depth in c(0, 8, 256, 16777216)) for (width in c(1, 7, 8, 9, 10, 11, 12, 19)) {
    options(cli.num_colors = depth, cli.width = width)
    out <- capture.output(value <- withVisible(show_color(cols)))
    plain <- cli::ansi_strip(out)
    swatches <- plain[grepl("^ *#", plain)]
    labels <- unlist(regmatches(swatches, gregexpr("#[0-9A-F]{8}|#[0-9A-F]{6}", swatches)))
    expect_identical(unname(labels), expected)
    expect_lte(max(nchar(swatches, type = "width")), max(width, 9))
    expect_identical(value$value, cols)
  }
  options(cli.num_colors = 0, cli.width = 19)
  out <- capture.output(show_color(c("red", "blue")))
  expect_identical(out[[1]], " #FF0000   #0000FF ")
})

test_that("show_color reverses names while retaining custom vector attributes", {
  withr::local_options(cli.num_colors = 0, cli.width = 40, width = 40)
  for (named in c(FALSE, TRUE)) {
    cols <- structure(c(A = "red", B = "blue", C = NA_character_, D = "#FF000080"),
                      type = "discrete", note = "metadata")
    expected <- structure(c(D = "#FF000080", C = NA_character_, B = "blue", A = "red"),
                          type = "discrete", note = "metadata")
    if (!named) {
      names(cols) <- NULL
      names(expected) <- NULL
    }
    for (depth in c(0, 1, 8, 16, 256, 16777216)) {
      options(cli.num_colors = depth)
      out <- capture.output(value <- withVisible(show_color(cols, rev = TRUE)))
      plain <- cli::ansi_strip(out)
      expect_identical(value$value, expected)
      expect_identical(value$visible, FALSE)
      expect_identical(eval(parse(text = plain[!grepl("^ #", plain)])), expected)
    }
  }
  empty <- structure(character(), type = "discrete")
  out <- capture.output(value <- show_color(empty, rev = TRUE))
  expect_identical(value, empty)
})

test_that("show_color respects the loaded cli renderer when true colour is requested", {
  withr::local_options(cli.num_colors = 16777216)
  out <- capture.output(value <- withVisible(show_color("#008833")))
  if (getNamespaceVersion("cli") < "3.1.0") {
    expect_match(out[[1]], "38;5;232", fixed = TRUE)
    expect_match(out[[1]], "48;5;35", fixed = TRUE)
  } else {
    expect_match(out[[1]], "38;2;255;255;255", fixed = TRUE)
    expect_match(out[[1]], "48;2;0;136;51", fixed = TRUE)
  }
  expect_identical(value$value, "#008833")
  expect_identical(value$visible, FALSE)
  expect_identical(getOption("cli.num_colors"), 16777216)
})
