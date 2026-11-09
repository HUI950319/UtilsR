# Capture everything a display helper writes -- stdout and cli messages alike --
# with ANSI colour forced on, so styling can be asserted.
capture_display <- function(expr) {
  withr::local_options(cli.num_colors = 256)
  out <- character()
  msg <- cli::cli_fmt(out <- utils::capture.output(expr))
  c(out, msg)
}

test_that("table style selectors and captions fail before forcing input tables", {
  for (bad in list(1, NA_character_, matrix("x")))
    expect_error(.cat_tb(stop("table evaluated"), numeric_columns = bad), "numeric_columns")
  for (arg in c("titles", "subtitles", "captions", "footnotes")) {
    args <- list(quote(stop("table evaluated")))
    args[[arg]] <- matrix("text")
    expect_error(do.call(".cat_tb", args), arg)
  }
  expect_error(.cat_tb(stop("table evaluated"), highlight_pattern = "x", highlight_color = "bad-color"),
    "highlight_color")
})

test_that("saved-file notices diagnose non-scalar fields before printing", {
  for (arg in c("subject", "path", "size", "kind")) {
    args <- list(subject = "saved", path = "figure.pdf", size = "4x3 in", existed = FALSE, kind = "PDF")
    args[[arg]] <- c("one", "two")
    expect_error(do.call(".cat_saved", args), arg)
    args[[arg]] <- matrix("one")
    expect_error(do.call(".cat_saved", args), arg)
  }
})

test_that("console separator labels diagnose dimensional and repeated text", {
  for (bad in list(c("a", "b"), character(), matrix("a")))
    expect_error(.cat_line(bad), "text")
  expect_no_error(suppressMessages(.cat_line(42)))
})

test_that(".cat_line validates width and rule patterns before evaluating text", {
  for (bad in list(NULL, NA_real_, Inf, 0, -1, 1.5, matrix(40))) {
    expect_error(.cat_line(stop("text evaluated"), width = bad), "width")
  }
  for (bad in list(NULL, NA_character_, character(), c("-", "="), "", "\u0301")) {
    expect_error(.cat_line(stop("text evaluated"), line_char = bad), "line_char")
  }
})

test_that("numeric table gradients preserve positions across overflowing finite ranges", {
  values <- c(-1e308, 0, 1e308, NA_real_)
  expect_no_warning(actual <- .cat_tb(data.frame(value = values),
    numeric_columns = "value", theme = "none"))
  reference <- .cat_tb(data.frame(value = c(-1, 0, 1, NA_real_)),
    numeric_columns = "value", theme = "none")
  expect_identical(actual[["_styles"]], reference[["_styles"]])
  expect_identical(actual[["_data"]][["value"]], values)
})

test_that("numeric table colours use finite domains and preserve infinite values", {
  data <- data.frame(value = c(1, Inf, NA_real_, -Inf, 2))
  expect_no_warning(table <- .cat_tb(data, numeric_columns = "value", theme = "none"))
  expect_identical(table[["_data"]][["value"]], data$value)
  rows <- table[["_styles"]][["rownum"]]
  expect_setequal(rows[!is.na(rows)], c(1L, 3L, 5L))
  expect_no_warning(infinite <- .cat_tb(data.frame(value = c(Inf, -Inf)),
                                        numeric_columns = "value", theme = "none"))
  expect_identical(infinite[["_data"]][["value"]], c(Inf, -Inf))
})

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

test_that("boxed notices follow the suppressible message channel", {
  expect_identical(capture.output(suppressMessages(.cat_box("literal {x}"))), character())
  shown <- cli::cli_fmt(value <- withVisible(.cat_box("literal {x}")))
  expect_match(paste(cli::ansi_strip(shown), collapse = "\n"), "literal \\{x\\}")
  expect_false(value$visible)
  expect_message(.cat_box("boxed notice"), "boxed notice")
})

test_that("message controls fail before forcing message text", {
  for (arg in c("verbose", "wrap")) for (bad in list(NA, 1, c(TRUE, FALSE), matrix(TRUE))) {
    args <- list(message = quote(stop("text evaluated")))
    args[[arg]] <- bad
    expect_error(do.call(.cat_message, args), arg)
  }
  for (bad in list(NA_character_, character(), c("a", "b"), matrix(""), 1))
    expect_error(.cat_message(stop("text evaluated"), timestamp_format = bad), "timestamp_format")
  expect_invisible(.cat_message(stop("text evaluated"), verbose = FALSE,
    wrap = stop("wrap evaluated"), timestamp_format = stop("stamp evaluated")))
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

test_that("progress step counts retain whole values beyond integer range", {
  run <- function() .cat_step("Large step", i = 3e9, n = 4e9)
  expect_no_warning(out <- cli::ansi_strip(cli::cli_fmt(run())))
  expect_true(any(grepl("[3000000000/4000000000]", out, fixed = TRUE)))
})

test_that("progress controls fail before evaluating message promises", {
  for (arg in c("i", "n", "verbose", ".envir")) {
    bad <- switch(arg,
      i = list(NA, 1.5, Inf, c(1, 2), matrix(1)),
      n = list(NA, 1.5, Inf, c(1, 2), matrix(1)),
      verbose = list(NA, 1, c(TRUE, FALSE), matrix(TRUE)),
      .envir = list(NULL, "globalenv", list()))
    for (value in bad) {
      args <- list(msg = quote(stop("message was evaluated")),
                   msg_done = quote(stop("done message was evaluated")))
      args[arg] <- list(value)
      expect_error(do.call(.cat_step, args), arg, fixed = TRUE)
    }
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

test_that("message wrapping uses timestamp display width on narrow consoles", {
  withr::local_options(cli.width = 25)
  for (style in c("chip", "full")) {
    out <- cli::ansi_strip(cli::cli_fmt(.cat_message(
      "alpha beta gamma delta epsilon zeta eta theta",
      timestamp_format = "\u65f6\u95f4", style = style
    )))
    expect_gt(length(out), 1L)
    expect_true(all(cli::ansi_nchar(out, type = "width") <= 25))
    indent <- if (style == "chip") 12L else 8L
    expect_true(all(startsWith(out[-1L], strrep(" ", indent))))
  }
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

test_that("save notices reject unknown replacement status before emitting text", {
  for (bad in list(NA, 1, logical(), c(TRUE, FALSE), matrix(TRUE)))
    expect_error(.cat_saved(stop("subject evaluated"), "x.pdf", "1x1 in", bad, "PDF"), "existed")
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

test_that("formula notices validate column names before accessing outcomes", {
  for (arg in c("time", "outcome"))
    for (bad in list(NA_character_, character(), c("a", "b"), "", matrix("x"), 1)) {
      args <- list(data = quote(stop("data evaluated")), co_var = "x")
      args[[arg]] <- bad
      expect_error(do.call(".cat_formula", args), arg)
    }
  for (bad in list(NA_character_, matrix("x"), c("x", ""), 1))
    expect_error(.cat_formula(stop("data evaluated"), bad), "co_var")
})

test_that("intercept-only model notices contain a usable unadjusted formula", {
  data <- data.frame(time = 1:3, DSS = c(0, 1, 0))
  for (co_var in list(NULL, character())) for (time in list(NULL, "time")) {
    shown <- cli::ansi_strip(cli::cli_fmt(.cat_formula(data, co_var, time = time)))
    expect_true(any(grepl("unadjusted:", shown, fixed = TRUE)))
    formula <- sub("^.*: ", "", shown)
    parsed <- parse(text = formula)[[1L]]
    expect_identical(parsed[[3L]], 1)
  }
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

test_that(".cat_formula() excludes SPSS user-missing outcome codes", {
  skip_if_not_installed("haven")
  withr::local_options(cli.width = 200)
  outcomes <- list(
    haven::labelled_spss(c(0, 1, 99, NA), na_values = 99),
    haven::labelled_spss(c(0, 1, 2, 99, NA), na_values = 99),
    haven::labelled_spss(c(0, 1, 8, 9, NA), na_values = c(8, 9))
  )
  models <- c("Cox", "CRR", "Cox")
  for (i in seq_along(outcomes)) {
    d <- data.frame(time = seq_along(outcomes[[i]]))
    d$DSS <- outcomes[[i]]
    before <- serialize(d, NULL)
    shown <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(d, "age"))))
    expect_length(shown, 1L)
    expect_match(shown, paste0(models[[i]], " model, unadjusted:"), fixed = TRUE)
    expect_identical(serialize(d, NULL), before)
  }
})

test_that(".cat_formula() excludes SPSS missing ranges and combined codes", {
  skip_if_not_installed("haven")
  withr::local_options(cli.width = 200)
  outcomes <- list(
    haven::labelled_spss(c(0, 1, 8, 8.5, 9, NA), na_range = c(8, 9)),
    haven::labelled_spss(c(0, 1, 2, 8, 8.5, 9), na_range = c(8, 9)),
    haven::labelled_spss(c(0, 1, 2, 8, 8.5, 9, 99, NA),
                         na_values = 99, na_range = c(8, 9))
  )
  for (i in seq_along(outcomes)) {
    d <- data.frame(time = seq_along(outcomes[[i]]))
    d$DSS <- outcomes[[i]]
    before <- serialize(d, NULL)
    shown <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(d, "age"))))
    expect_match(shown, paste0(c("Cox", "CRR", "CRR")[[i]], " model,"),
                 fixed = TRUE)
    expect_identical(serialize(d, NULL), before)
  }
})

test_that(".cat_formula() quotes non-syntactic survival column names", {
  withr::local_options(cli.width = 240)
  d <- data.frame(time = 1:4, DSS = c(0, 1, 0, 1), age = 4:7, x = 8:11)
  names(d) <- c("follow up", "event status", "age group", "x+y")
  shown <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(
    d, c("age group", "x+y"), time = "follow up", outcome = "event status"))))
  expected <- "Surv(`follow up`, `event status`) ~ `age group` + `x+y`"
  expect_length(shown, 1L)
  expect_identical(endsWith(shown, expected), TRUE)
  formula <- sub("^.*?adjusted: ", "", shown, perl = TRUE)
  expect_identical(all.vars(stats::as.formula(formula)), names(d))
})

test_that(".cat_formula() quotes logistic columns and reserved words", {
  withr::local_options(cli.width = 200)
  d <- data.frame(DSS = c(0, 1, 0, 1), age = 4:7, x = 8:11)
  names(d) <- c("if", "TRUE", "1st")
  shown <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(
    d, c("TRUE", "1st"), time = NULL, outcome = "if"))))
  expect_identical(endsWith(shown, "`if` ~ `TRUE` + `1st`"), TRUE)
  formula <- sub("^.*?adjusted: ", "", shown, perl = TRUE)
  expect_identical(all.vars(stats::as.formula(formula)), names(d))
})

test_that(".cat_formula() preserves column whitespace in a narrow console", {
  withr::local_options(cli.width = 42)
  co_var <- paste(rep("long predictor", 6), collapse = "  ")
  d <- data.frame(time = 1:4, DSS = c(0, 1, 0, 1), x = 4:7)
  names(d) <- c("follow  up", "event  status", co_var)
  shown <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(
    d, co_var, time = "follow  up", outcome = "event  status"))))
  expected <- paste0("Surv(`follow  up`, `event  status`) ~ `", co_var, "`")
  expect_length(shown, 1L)
  expect_identical(endsWith(shown, expected), TRUE)
  formula <- sub("^.*?adjusted: ", "", shown, perl = TRUE)
  expect_identical(all.vars(stats::as.formula(formula)), names(d))
})

test_that(".cat_formula() escapes literal column names without interpreting them", {
  withr::local_options(cli.width = 400)
  co_var <- c("a`b", "a\\b", "line\nbreak", "tab\tname", "{label}",
              "x;stop('bad')", "  padded  ", "percent%field", "x#y")
  d <- data.frame(time = 1:4, DSS = c(0, 1, 0, 1))
  for (nm in co_var) d[[nm]] <- 4:7
  before <- serialize(d, NULL)
  shown <- trimws(cli::ansi_strip(cli::cli_fmt(.cat_formula(d, co_var))))
  expect_length(shown, 1L)
  formula <- sub("^.*?adjusted: ", "", shown, perl = TRUE)
  expect_identical(all.vars(stats::as.formula(formula)), names(d))
  expect_identical(serialize(d, NULL), before)
})

test_that(".cat_formula() preserves ordinary outcome classification", {
  withr::local_options(cli.width = 200)
  outcomes <- list(
    c(0, 1, NA), c(0, 1, 2, NA), c(FALSE, TRUE, NA),
    c("alive", "dead", NA),
    factor(c("alive", "dead", NA), levels = c("alive", "dead", "unused")),
    c(NA_real_, NaN), numeric(), c(0, 1, 1 + 1e-12)
  )
  models <- c("Cox", "CRR", "Cox", "Cox", "Cox", "Cox", "Cox", "CRR")
  for (i in seq_along(outcomes)) {
    d <- data.frame(time = seq_along(outcomes[[i]]))
    d$DSS <- outcomes[[i]]
    shown <- cli::ansi_strip(cli::cli_fmt(.cat_formula(d, "age")))
    expect_match(shown, paste0(models[[i]], " model,"), fixed = TRUE)
  }
})

test_that(".cat_formula() handles SPSS outcome storage and all-missing values", {
  skip_if_not_installed("haven")
  withr::local_options(cli.width = 200)
  outcomes <- list(
    haven::labelled_spss(c(0L, 1L, 99L, NA_integer_), na_values = 99L),
    haven::labelled_spss(c("alive", "dead", "missing", NA), na_values = "missing"),
    haven::labelled_spss(c("alive", "disease", "other", "missing"), na_values = "missing"),
    haven::labelled_spss(c(8, 9, 99, NA), na_range = c(8, 9), na_values = 99),
    haven::labelled(c(0, 1, haven::tagged_na("a"), NA),
                    labels = c(no = 0, yes = 1, unused = 2))
  )
  for (i in seq_along(outcomes)) {
    d <- data.frame(time = seq_along(outcomes[[i]]))
    d$DSS <- outcomes[[i]]
    before <- serialize(d, NULL)
    shown <- cli::ansi_strip(cli::cli_fmt(.cat_formula(d, "age")))
    expect_match(shown, paste0(c("Cox", "Cox", "CRR", "Cox", "Cox")[[i]],
                               " model,"), fixed = TRUE)
    expect_identical(serialize(d, NULL), before)
  }
})

test_that(".cat_formula() reports a missing SPSS dependency only when needed", {
  d <- data.frame(time = 1:4)
  d$DSS <- structure(c(0, 1, 99, NA), na_values = 99,
                     class = c("haven_labelled_spss", "haven_labelled", "vctrs_vctr"))
  fn <- .cat_formula
  isolated <- new.env(parent = environment(fn))
  isolated$requireNamespace <- function(package, quietly = FALSE) FALSE
  environment(fn) <- isolated
  shown <- cli::cli_fmt(error <- tryCatch(fn(d, "age"), error = identity))
  expect_s3_class(error, "error")
  expect_match(conditionMessage(error), "requires package.*haven")
  expect_identical(shown, character())
  expect_match(cli::ansi_strip(cli::cli_fmt(fn(d, "age", time = NULL))),
               "Logistic model,", fixed = TRUE)
  d$DSS <- c(0, 1, 0, 1)
  expect_match(cli::ansi_strip(cli::cli_fmt(fn(d, "age"))), "Cox model,", fixed = TRUE)
})

test_that(".cat_formula() retains message, return, and suppression contracts", {
  withr::local_options(cli.width = 200)
  d <- data.frame(time = 1:4, DSS = c(0, 1, 0, 1))
  for (type in c("info", "success", "warning", "error")) {
    shown <- cli::cli_fmt(returned <- withVisible(.cat_formula(d, "age", type = type)))
    expect_length(shown, 1L)
    expect_null(returned$value)
    expect_identical(returned$visible, FALSE)
  }
  messages <- character()
  withCallingHandlers(suppressMessages(.cat_formula(d, "age")),
    message = function(c) messages <<- c(messages, conditionMessage(c)))
  expect_identical(messages, character())
  expect_identical(capture.output(suppressMessages(.cat_formula(d, "age"))), character())
})

test_that(".cat_formula() handles serialized SPSS outcomes before haven is loaded", {
  skip_if_not_installed("haven")
  files <- c(script = tempfile(fileext = ".R"), input = tempfile(fileext = ".rds"),
             output = tempfile(fileext = ".rds"))
  on.exit(unlink(files), add = TRUE)
  isolated <- new.env(parent = baseenv())
  helpers <- c(".cat_formula", ".cat_message", "._type_cfg", "._cli_bg", "._cli_fg",
               "._chip", "console_width")
  for (nm in helpers) {
    fn <- get(nm, envir = environment(.cat_formula), inherits = TRUE)
    environment(fn) <- isolated
    assign(nm, fn, envir = isolated)
  }
  d <- data.frame(time = 1:5, age = 4:8)
  names(d) <- c("follow  up", "age`group")
  d[["event status"]] <- haven::labelled_spss(c(0, 1, 99, NA, 0), na_values = 99)
  competing <- d
  competing[["event status"]] <- haven::labelled_spss(c(0, 1, 2, 8, 9), na_range = c(8, 9))
  saveRDS(list(fn = isolated$.cat_formula, data = list(d, competing), libs = .libPaths()),
          files[["input"]])
  writeLines(c(
    "options(device = function(...) grDevices::pdf(NULL, ...), cli.width = 42)",
    "local({",
    "  args <- commandArgs(TRUE)",
    "  fixture <- readRDS(args[[1L]])",
    "  .libPaths(fixture[['libs']])",
    "  loaded_before <- 'haven' %in% loadedNamespaces()",
    "  before <- serialize(fixture[['data']], NULL)",
    "  shown <- lapply(fixture[['data']], function(d) {",
    "    out <- cli::cli_fmt(fixture[['fn']](d, 'age`group',",
    "      time = 'follow  up', outcome = 'event status'))",
    "    trimws(cli::ansi_strip(out))",
    "  })",
    "  saveRDS(list(loaded_before = loaded_before, shown = shown,",
    "    loaded_after = 'haven' %in% loadedNamespaces(),",
    "    unchanged = identical(before, serialize(fixture[['data']], NULL))), args[[2L]])",
    "})"
  ), files[["script"]])
  withr::local_envvar(R_TESTS = NA_character_)
  executable <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  output <- system2(executable,
                    c("--vanilla", shQuote(files[["script"]]), shQuote(files[["input"]]),
                      shQuote(files[["output"]])), stdout = TRUE, stderr = TRUE)
  expect_null(attr(output, "status"))
  expect_identical(file.exists(files[["output"]]), TRUE)
  if (!file.exists(files[["output"]])) stop(paste(output, collapse = "\n"))
  result <- readRDS(files[["output"]])
  expect_identical(result$loaded_before, FALSE)
  expect_identical(result$loaded_after, TRUE)
  expect_identical(result$unchanged, TRUE)
  for (i in seq_along(result$shown)) {
    shown <- result$shown[[i]]
    expect_length(shown, 1L)
    expect_match(shown, paste0(c("Cox", "CRR")[[i]], " model,"), fixed = TRUE)
    formula <- sub("^.*?adjusted: ", "", shown, perl = TRUE)
    expect_identical(all.vars(stats::as.formula(formula)),
                     c("follow  up", "event status", "age`group"))
  }
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

test_that("show_color batches large colour diagnostics and retains duplicate positions", {
  withr::local_options(cli.num_colors = 0, cli.width = 80)
  native_col2rgb <- grDevices::col2rgb
  calls <- integer()
  testthat::local_mocked_bindings(
    col2rgb = function(col, ...) {
      calls <<- c(calls, length(col))
      native_col2rgb(col, ...)
    },
    .package = "grDevices"
  )
  cols <- setNames(sprintf("#%06X", seq_len(2048L)), paste0("c", seq_len(2048L)))
  cols[c(256L, 257L, 513L, 2048L)] <- c("not_a_colour", "not_a_colour", "2e0", "unknown_colour")
  out <- capture.output(error <- tryCatch(show_color(cols), error = identity))
  expect_s3_class(error, "error")
  for (value in c("256", "257", "513", "2048", "not_a_colour", "2e0", "unknown_colour")) {
    expect_match(conditionMessage(error), value, fixed = TRUE)
  }
  expect_identical(out, character())
  expect_lt(sum(calls == 1L), length(cols) * 3 / 4)
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

test_that("show_color retains swatches at the maximum console width", {
  withr::local_options(cli.num_colors = 0, cli.width = .Machine$integer.max,
                      width = 80, warn = 2)
  cols <- c(A = "red", B = "#F008", C = NA_character_, D = "blue")
  expected <- c("#FF0000", "#FF000088", "#FFFFFF00", "#0000FF")
  for (depth in c(0, 1, 8, 16, 256, 16777216)) for (reverse in c(FALSE, TRUE)) {
    options(cli.num_colors = depth)
    out <- capture.output(value <- withVisible(show_color(cols, rev = reverse)))
    plain <- cli::ansi_strip(out)
    swatches <- grepl("^ *#", plain)
    labels <- unlist(regmatches(plain[swatches], gregexpr("#[0-9A-F]{8}|#[0-9A-F]{6}", plain[swatches])))
    expect_identical(unname(labels), if (reverse) rev(expected) else expected)
    expect_identical(value$value, if (reverse) rev(cols) else cols)
    expect_identical(eval(parse(text = plain[!swatches])), value$value)
    expect_identical(value$visible, FALSE)
  }
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

test_that("show_color preserves interleaved foreground and background styles", {
  withr::local_options(cli.num_colors = 16777216, cli.width = 80, width = 80)
  cols <- structure(c(dark = "#000001", light = "#FFFFFE", again = "#000001",
                      alpha = "#00000080", cyan = "#00FFFF"),
                    note = list(precision = 1 / 3))
  backgrounds <- c("#000001", "#FFFFFE", "#000001", "#7F7F7F", "#00FFFF")
  foregrounds <- c("#FFFFFF", "#000000", "#FFFFFF", "#000000", "#000000")
  for (depth in c(8, 256, 16777216)) {
    options(cli.num_colors = depth)
    expected_foregrounds <- foregrounds
    if (depth < 256) expected_foregrounds[[4L]] <- "#FFFFFF"
    reference <- vapply(seq_along(cols), function(i) {
      cli::combine_ansi_styles(cli::make_ansi_style(expected_foregrounds[[i]]),
        cli::make_ansi_style(backgrounds[[i]], bg = TRUE, grey = FALSE))(
          paste0(" ", cols[[i]], " "))
    }, character(1))
    before <- getOption("cli.num_colors")
    output <- capture.output(value <- withVisible(show_color(cols)))
    expect_identical(output[[1L]], paste(reference, collapse = " "))
    expect_identical(value$value, cols)
    expect_false(value$visible)
    expect_identical(getOption("cli.num_colors"), before)
    expect_identical(eval(parse(text = output[-1L])), cols)
  }
})

test_that("show_color preserves distinct labels on shared composited backgrounds", {
  withr::local_options(cli.num_colors = 0, cli.width = 80, width = 80)
  cols <- structure(c(A = "#00000000", B = "#FF000000", C = "#00FF0000",
                      D = "#0000FF00", E = "#000000", F = "#FFFFFF",
                      G = "#00000000", H = "#FF000001"),
                    note = list(precision = pi))
  backgrounds <- c(rep("#FFFFFF", 4L), "#000000", "#FFFFFF", "#FFFFFF", "#FFFEFE")
  foregrounds <- c(rep("#000000", 4L), "#FFFFFF", rep("#000000", 3L))
  for (depth in c(0, 8, 256, 16777216)) for (reverse in c(FALSE, TRUE)) {
    options(cli.num_colors = depth)
    order <- if (reverse) rev(seq_along(cols)) else seq_along(cols)
    expected <- cols
    expected[] <- cols[order]
    names(expected) <- names(cols)[order]
    reference <- vapply(order, function(i) {
      label <- paste0(" ", cols[[i]], " ")
      if (depth == 0) return(label)
      cli::combine_ansi_styles(cli::make_ansi_style(foregrounds[[i]]),
        cli::make_ansi_style(backgrounds[[i]], bg = TRUE, grey = FALSE))(label)
    }, character(1))
    for (width in c(20, 80)) {
      options(cli.width = width)
      output <- capture.output(value <- withVisible(show_color(cols, rev = reverse)))
      swatches <- grepl("^ *#", cli::ansi_strip(output))
      rows <- if (width == 20) reference else c(paste(reference[1:6], collapse = " "),
                                                paste(reference[7:8], collapse = " "))
      expect_identical(output[swatches], unname(rows))
      expect_identical(value$value, expected)
      expect_false(value$visible)
      expect_identical(eval(parse(text = output[!swatches])), expected)
      expect_identical(getOption("cli.num_colors"), depth)
    }
  }
})

test_that("show_color retains indexed contrast across the standard xterm palette", {
  withr::local_options(cli.num_colors = 256, cli.width = 4096, width = 80)
  base <- c("#000000", "#CD0000", "#00CD00", "#CDCD00", "#0000EE", "#CD00CD", "#00CDCD", "#E5E5E5",
            "#7F7F7F", "#FF0000", "#00FF00", "#FFFF00", "#5C5CFF", "#FF00FF", "#00FFFF", "#FFFFFF")
  index <- 0:215
  levels <- c(0, 95, 135, 175, 215, 255)
  cube <- rbind(levels[index %/% 36L + 1L], levels[index %/% 6L %% 6L + 1L],
                levels[index %% 6L + 1L])
  rgb <- cbind(grDevices::col2rgb(base), cube,
               matrix(rep(8L + 10L * (0:23), each = 3L), 3L))
  cols <- grDevices::rgb(rgb[1L, ], rgb[2L, ], rgb[3L, ], maxColorValue = 255)
  emitted_colour <- function(style) {
    shown <- style(" ")
    tag <- regmatches(shown, regexpr("\\[[0-9;]+m", shown))
    code <- as.integer(strsplit(substr(tag, 2L, nchar(tag) - 1L), ";", fixed = TRUE)[[1L]])
    index <- if (length(code) == 3L) code[[3L]] else {
      code[[1L]] %% 10L + if (code[[1L]] >= 90L) 8L else 0L
    }
    cols[[index + 1L]]
  }
  for (depth in c(8, 16, 256)) {
    options(cli.num_colors = depth)
    foreground <- lapply(c("#000000", "#FFFFFF"), cli::make_ansi_style)
    actual_foreground <- vapply(foreground, emitted_colour, character(1))
    reference <- vapply(cols, function(col) {
      background <- cli::make_ansi_style(col, bg = TRUE, grey = FALSE)
      ratios <- colorspace::contrast_ratio(emitted_colour(background), actual_foreground)
      cli::combine_ansi_styles(foreground[[which.max(ratios)]], background)(paste0(" ", col, " "))
    }, character(1), USE.NAMES = FALSE)
    output <- capture.output(value <- withVisible(show_color(cols)))
    expect_identical(output[[1L]], paste(reference, collapse = " "))
    expect_identical(value$value, cols)
    expect_false(value$visible)
    expect_identical(getOption("cli.num_colors"), depth)
  }
})

test_that("show_color retains empty expressions and validation at every colour depth", {
  withr::local_options(cli.num_colors = 0, cli.width = 80, width = 80)
  inputs <- list(character(), structure(character(), type = "discrete",
                                       note = list(precision = c(pi, 1 / 3))))
  for (cols in inputs) {
    expected <- c("", capture.output(dput(cols, control = c(
      "keepNA", "keepInteger", "niceNames", "showAttributes", "digits17"))))
    for (depth in c(0, 1, 8, 16, 256, 16777216)) for (reverse in c(FALSE, TRUE)) {
      options(cli.num_colors = depth)
      output <- capture.output(value <- withVisible(show_color(cols, rev = reverse)))
      expect_identical(output, expected)
      expect_identical(value$value, cols)
      expect_false(value$visible)
      expect_identical(eval(parse(text = output[-1L])), cols)
      expect_identical(getOption("cli.num_colors"), depth)
    }
  }
  for (bad in list(NULL, NA, 1, matrix(TRUE))) {
    output <- capture.output(expect_error(show_color(character(), rev = bad), "`rev`"))
    expect_identical(output, character())
  }
  for (bad in list(NULL, logical(), list(), matrix(character(), nrow = 0L))) {
    output <- capture.output(expect_error(show_color(bad), "`x`"))
    expect_identical(output, character())
  }
})

test_that("table highlight patterns are validated before forcing table inputs", {
  for (pattern in list(NA_character_, character(), c("a", "b"),
                        matrix("a"), 1, "[")) {
    expect_error(.cat_tb(stop("table input was evaluated"),
                         highlight_pattern = pattern, theme = "none"),
                 "highlight_pattern")
  }
})

test_that("table highlighting keeps style updates bounded as matching rows grow", {
  original <- gt::tab_style
  calls <- 0L
  local_mocked_bindings(tab_style = function(...) {
    calls <<- calls + 1L
    original(...)
  }, .package = "gt")
  counts <- vapply(c(4L, 20L), function(n) {
    calls <<- 0L
    .cat_tb(data.frame(a = rep("hit", n), b = factor(rep("HIT", n))),
            highlight_pattern = "hit", theme = "none")
    calls
  }, integer(1))
  expect_equal(counts[[2L]], counts[[1L]])
})

test_that("table highlighting preserves matched cells and missing values", {
  data <- data.frame(text = c("hit", NA, "other", "HIT"),
                     category = factor(c("other", "hit", NA, "hit")),
                     value = c(1, 2, 3, NA))
  result <- .cat_tb(data, highlight_pattern = "hit", theme = "none")
  styles <- result[["_styles"]]
  body <- styles[!is.na(styles[["rownum"]]), , drop = FALSE]
  expect_identical(sort(paste(body[["colname"]], body[["rownum"]], sep = ":")),
                   c("category:2", "category:4", "text:1", "text:4"))
  expect_identical(result[["_data"]], tibble::as_tibble(data))
  expect_error(.cat_tb(data, highlight_pattern = NA, theme = "none"),
               "highlight_pattern")

  empty <- .cat_tb(data[FALSE, ], highlight_pattern = "hit", theme = "none")
  expect_equal(sum(!is.na(empty[["_styles"]][["rownum"]])), 0L)
})

test_that("messages retain explicit trailing blank lines", {
  for (style in c("full", "chip")) {
    out <- cli::ansi_strip(cli::cli_fmt(.cat_message(c("first\n", "second\n\n"), style = style, timestamp_format = NULL)))
    expect_length(out, 5L)
    expect_identical(trimws(out[c(2L, 4L, 5L)]), rep("", 3L))
    expect_match(out[[3L]], "second", fixed = TRUE)
  }
})

test_that("console tables restore cold integer64 numeric columns", {
  skip_if_not_installed("bit64")
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "input.rds")
  script <- file.path(directory, "verify.R")
  d <- data.frame(x = bit64::as.integer64(c(-1, -2, -3)))
  saveRDS(list(fn = .cat_tb, data = d), fixture)
  writeLines(c(sprintf("payload <- readRDS(%s)", deparse(fixture)),
    "stopifnot(!('bit64' %in% loadedNamespaces()))",
    "tb <- payload$fn(payload$data, numeric_columns = 'x', theme = 'none')",
    "html <- gt::as_raw_html(tb)",
    "stopifnot(!grepl('NaN', html, fixed = TRUE), all(vapply(c('1.00', '2.00', '3.00'), grepl, logical(1), x = html, fixed = TRUE)))",
    "fills <- unlist(lapply(tb[['_styles']][['styles']], function(s) s[['cell_fill']][['color']]), use.names = FALSE)",
    "stopifnot(length(unique(fills)) == 3L)",
    "cat('COLD_TABLE_OK\n')"), script)
  output <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'), c('--vanilla', shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, 'status'), info = paste(output, collapse = '\n'))
  expect_identical(tail(output, 1L), 'COLD_TABLE_OK')
})

test_that("console table gradients retain exact integer64 offsets", {
  skip_if_not_installed("bit64")
  fills <- function(table) unlist(lapply(table[["_styles"]][["styles"]], function(s) s[["cell_fill"]][["color"]]), use.names = FALSE)
  d <- data.frame(x = bit64::as.integer64(c("9007199254740993", "9007199254740994", "9007199254740995")))
  reference <- .cat_tb(data.frame(x = 1:3), numeric_columns = "x", theme = "none")
  expect_warning(actual <- .cat_tb(d, numeric_columns = "x", theme = "none"), NA)
  expect_identical(fills(actual), fills(reference))
  expect_identical(actual[["_data"]]$x, d$x)
  wide <- data.frame(x = bit64::as.integer64(c("-9223372036854775807", "0", "9223372036854775807")))
  expect_warning(actual <- .cat_tb(wide, numeric_columns = "x", theme = "none"), NA)
  expect_identical(fills(actual), fills(reference))
})

test_that("console tables exclude SPSS user missing codes from display and gradients", {
  skip_if_not_installed("haven")
  d <- data.frame(x = haven::labelled_spss(c(1, 2, 97, 99), na_values = 99, na_range = c(97, 98)))
  before <- serialize(d, NULL)
  fills <- function(table) unlist(lapply(table[["_styles"]][["styles"]], function(s) s[["cell_fill"]][["color"]]), use.names = FALSE)
  reference <- .cat_tb(data.frame(x = c(1, 2, NA_real_, NA_real_)), numeric_columns = "x", theme = "none")
  for (input in list(d, gt::gt(d))) {
    plain <- .cat_tb(input, theme = "none")
    expect_identical(as.numeric(plain[["_data"]]$x), c(1, 2, NA_real_, NA_real_))
    expect_false(grepl("99.00", gt::as_raw_html(plain), fixed = TRUE))
    actual <- .cat_tb(input, numeric_columns = "x", theme = "none")
    expect_identical(fills(actual), fills(reference))
    expect_identical(as.numeric(actual[["_data"]]$x), c(1, 2, NA_real_, NA_real_))
    expect_false(grepl("99.00", gt::as_raw_html(actual), fixed = TRUE))
  }
  expect_identical(serialize(d, NULL), before)
})

test_that("boxed notices retain complete borders for embedded newlines", {
  withr::local_options(cli.num_colors = 1L, cli.width = 60L)
  box <- function(text) cli::ansi_strip(cli::cli_fmt(.cat_box(text)))
  expect_identical(box("a\nb"), box(c("a", "b")))
  expect_identical(box("a\nb\n"), box(c("a", "b", "")))
  expect_identical(box(42), box("42"))
  expect_identical(utils::capture.output(suppressMessages(.cat_box("a\nb"))), character())
})

test_that("labelled table values share native numeric formatting", {
  skip_if_not_installed("haven")
  cells <- function(table) {
    html <- gt::as_raw_html(table)
    values <- regmatches(html, gregexpr("<td[^>]*>[^<]*</td>", html))[[1L]]
    gsub("<[^>]*>", "", values)
  }
  plain <- data.frame(x = c(1234.5678, -2.34567, NA_real_, Inf))
  d <- data.frame(x = haven::labelled(plain$x, label = "measurement"))
  before <- serialize(d, NULL)
  for (locale in c("en", "de")) {
    for (cols in list(NULL, "x")) {
      input <- gt::gt(d, locale = locale)
      reference <- .cat_tb(gt::gt(plain, locale = locale), numeric_columns = cols, theme = "none")
      actual <- .cat_tb(input, numeric_columns = cols, theme = "none")
      expect_identical(cells(actual), cells(reference))
      expect_identical(actual[["_data"]]$x, d$x)
    }
  }
  text <- data.frame(x = haven::labelled(c("A", "B")))
  expect_identical(cells(.cat_tb(text, numeric_columns = "x", theme = "none")), c("A", "B"))
  expect_identical(serialize(d, NULL), before)
})
