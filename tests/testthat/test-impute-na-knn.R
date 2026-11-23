test_that("KNN neighbour counts reject encoded scalar storage on the fast path", {
  d <- data.frame(value = 1:3)
  bad_values <- list(structure(1, class = "encoded_count"))
  if (requireNamespace("lubridate", quietly = TRUE)) bad_values[[2L]] <- lubridate::duration(1)
  for (bad in bad_values)
    expect_error(impute_na_knn(d, k = bad, verbose = FALSE), "k.*positive integer")
  expect_identical(impute_na_knn(d, k = 1L, verbose = FALSE), d)
})

test_that("impute_na_knn restores SPSS missingness before cold donor checks", {
  skip_if_not_installed("haven")
  skip_if_not_installed("VIM")
  fn <- impute_na_knn
  environment(fn) <- new.env(parent = asNamespace("stats"))
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  data <- data.frame(target = haven::labelled_spss(c(1, 3, 99), labels = c(Unknown = 99), na_values = 99),
                     predictor = c(0, 1, 0))
  saveRDS(list(fn = fn, data = data, libs = .libPaths()), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)",
    "fixture <- readRDS(args[[1]])",
    ".libPaths(fixture[['libs']])",
    "stopifnot(!'haven' %in% loadedNamespaces())",
    "data <- fixture[['data']]",
    "if (args[[3]] == 'donors') { data[['target']][c(2, 3)] <- 99; data[['predictor']][2] <- NA_real_ }",
    "before <- data",
    "out <- tryCatch(fixture[['fn']](data, k = if (args[[3]] == 'donors') 2 else 1, verbose = FALSE), error = conditionMessage)",
    "saveRDS(list(value = if (is.data.frame(out)) vctrs::vec_data(out[['target']]) else out, unchanged = identical(data, before), attrs = if (is.data.frame(out)) attributes(out[['target']]) else NULL), args[[2]])"
  ), script)
  for (mode in c("impute", "donors")) {
    status <- system2(file.path(R.home("bin"), "Rscript"),
      c("--vanilla", shQuote(script), shQuote(fixture), shQuote(output), mode), stdout = TRUE, stderr = TRUE)
    expect_null(attr(status, "status"), info = paste(status, collapse = "\n"))
    if (is.null(attr(status, "status"))) {
      out <- readRDS(output)
      expect_identical(out$unchanged, TRUE)
      if (mode == "impute") {
        expect_identical(out$value, c(1, 3, 1))
        expect_identical(out$attrs, attributes(data$target))
      } else {
        expect_type(out$value, "character")
        if (is.character(out$value)) expect_match(out$value, "Not enough observed donors")
      }
    }
  }
})

test_that("impute_na_knn performs weighted numeric imputation", {
  skip_if_not_installed("VIM")

  dat <- data.frame(
    value = c(0, 10, NA_real_),
    helper = c(0, 10, 2)
  )

  expect_no_warning(
    result <- impute_na_knn(dat, k = 2, verbose = FALSE)
  )

  expect_s3_class(result, "data.frame")
  expect_false(anyNA(result$value))
  expect_equal(result$value[[3]], 2)
  expect_identical(result$helper, dat$helper)
})

test_that("impute_na_knn keeps weighted means of finite large donors finite", {
  skip_if_not_installed("VIM")
  bound <- .Machine$double.xmax
  cases <- list(
    list(values = rep(bound, 3), expected = bound),
    list(values = rep(-bound, 3), expected = -bound),
    list(values = c(bound, bound / 2, bound), expected = 0.75 * bound)
  )
  for (case in cases) {
    dat <- data.frame(value = c(case$values, NA_real_), helper = c(0, 1, 2, 1))
    before <- dat
    expect_no_warning(result <- impute_na_knn(dat, k = 3, verbose = FALSE))
    expect_equal(result$value[4], case$expected)
    expect_identical(is.finite(result$value), rep(TRUE, 4))
    expect_identical(result$value[1:3], dat$value[1:3])
    expect_identical(result$helper, dat$helper)
    expect_identical(dat, before)
  }
})

test_that("impute_na_knn keeps equal-weight means of finite large donors finite", {
  skip_if_not_installed("VIM")
  for (sign in c(1, -1)) {
    dat <- data.frame(value = sign * c(1.2e308, 1.6e308, NA_real_),
                      helper = factor(c("A", "A", "B")))
    expect_no_warning(result <- impute_na_knn(dat, k = 2, verbose = FALSE))
    expect_equal(result$value[3], sign * 1.4e308)
    expect_identical(is.finite(result$value), rep(TRUE, 3))
    expect_identical(result$value[1:2], dat$value[1:2])
    expect_identical(result$helper, dat$helper)
  }
})

test_that("impute_na_knn handles overflowing mixed-sign donor sums", {
  skip_if_not_installed("VIM")
  for (sign in c(1, -1)) {
    bound <- .Machine$double.xmax
    dat <- data.frame(value = sign * c(bound, bound, bound, -bound, NA_real_),
                      helper = c(0, 1, 2, 3, 1))
    expect_no_warning(result <- impute_na_knn(dat, k = 4, verbose = FALSE))
    expect_equal(result$value[5], sign * (0.75 * bound))
    expect_identical(is.finite(result$value), rep(TRUE, 5))
    expect_identical(result$value[1:4], dat$value[1:4])
  }
})

test_that("impute_na_knn preserves numeric and character value labels", {
  skip_if_not_installed("VIM")

  numeric_labelled <- structure(
    c(1, 2, NA_real_, 1),
    labels = c(No = 1, Yes = 2),
    label = "Outcome",
    class = c("haven_labelled", "vctrs_vctr", "double")
  )
  character_labelled <- structure(
    c("A", "B", NA_character_, "A"),
    labels = c(Group_A = "A", Group_B = "B"),
    label = "Group",
    class = c("haven_labelled", "vctrs_vctr", "character")
  )
  dat <- tibble::tibble(
    outcome = numeric_labelled,
    group = character_labelled,
    donor = c(0, 10, 10, 0)
  )

  result <- impute_na_knn(dat, k = 1, verbose = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_false(anyNA(result$outcome))
  expect_false(anyNA(result$group))
  expect_identical(typeof(result$outcome), "double")
  expect_identical(typeof(result$group), "character")
  expect_identical(attributes(result$outcome), attributes(numeric_labelled))
  expect_identical(attributes(result$group), attributes(character_labelled))
})

test_that("impute_na_knn does not alter observed labelled doubles", {
  skip_if_not_installed("VIM")

  precise <- structure(
    c(1, 1 + .Machine$double.eps, 2, 3),
    labels = c(One = 1, Two = 2),
    label = "Precise values",
    class = c("haven_labelled", "vctrs_vctr", "double")
  )
  dat <- data.frame(
    precise = precise,
    value = c(0, 10, NA_real_, 20),
    helper = c(0, 10, 10, 20)
  )

  result <- impute_na_knn(dat, k = 1, verbose = FALSE)

  expect_identical(as.double(result$precise), as.double(precise))
  expect_identical(attributes(result$precise), attributes(precise))
})

test_that("impute_na_knn rejects k when too few donors are available", {
  skip_if_not_installed("VIM")

  dat <- data.frame(value = c(1, NA_real_), helper = 1:2)

  expect_snapshot(
    impute_na_knn(dat, k = 5, verbose = FALSE),
    error = TRUE
  )
})

test_that("impute_na_knn accepts data-frame subclasses as plain data frames", {
  skip_if_not_installed("VIM")

  value <- structure(
    c(1, NA_real_, 3),
    labels = c(Low = 1, High = 3),
    label = "Value",
    class = c("haven_labelled", "vctrs_vctr", "double")
  )
  dat <- structure(data.frame(
    value = value,
    helper = c(1, 3, 3)
  ), class = c("custom_df", "data.frame"))

  result <- impute_na_knn(dat, k = 1, verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_false(anyNA(result$value))
  expect_identical(attributes(result$value), attributes(value))
})

test_that("impute_na_knn fills declared SPSS missing codes and retains labels", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  for (values in list(c(1, 2, 99), c(1, 2, 99, NA_real_))) {
    x <- haven::labelled_spss(values, labels = c(Unknown = 99), na_values = 99, label = "Outcome")
    dat <- data.frame(value = x, helper = c(0, rep(10, length(x) - 1)))
    before <- dat
    expect_no_warning(result <- impute_na_knn(dat, k = 1, verbose = FALSE))
    expect_identical(as.numeric(result$value), c(1, rep(2, length(x) - 1)))
    expect_identical(attributes(result$value), attributes(x))
    expect_identical(dat, before)
  }
})

test_that("impute_na_knn safely imputes and restores integer64 columns", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(c(0, 10, NA_real_))
  attr(x, "label") <- "Count"
  dat <- data.frame(value = x, helper = c(0, 10, 2.5))
  before <- dat
  expect_no_warning(result <- impute_na_knn(dat, k = 2, verbose = FALSE))
  expect_identical(as.character(result$value), c("0", "10", "2"))
  expect_identical(attributes(result$value), attributes(x))
  expect_identical(dat, before)
  dat <- data.frame(value = c(0, 10, NA_real_), helper = bit64::as.integer64(c(0, 10, 2)))
  result <- impute_na_knn(dat, k = 2, verbose = FALSE)
  expect_equal(result$value, c(0, 10, 2))
  expect_identical(result$helper, dat$helper)
  dat <- data.frame(value = bit64::as.integer64(c(0, 10, NA_real_)), helper = c(0, 10, 2))
  numeric_data <- dat; numeric_data$value <- as.double(dat$value)
  reference <- impute_na_knn(numeric_data, k = 2, verbose = FALSE)
  result <- impute_na_knn(dat, k = 2, verbose = FALSE)
  expect_identical(as.character(result$value), as.character(bit64::as.integer64(reference$value)))
})

test_that("impute_na_knn refuses integer64 precision loss only when imputation is needed", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("bit64")
  dat <- data.frame(value = bit64::as.integer64(c("9007199254740993", "9007199254740994", NA)), helper = 1:3)
  expect_error(impute_na_knn(dat, k = 1, verbose = FALSE), "integer64.*precision|precision.*integer64")
  dat <- dat[1:2, ]
  expect_identical(impute_na_knn(dat, verbose = FALSE), dat)
})

test_that("impute_na_knn keeps user field names independent of backend variables", {
  skip_if_not_installed("VIM")
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2.5), constant = rep(1L, 3))
  reference <- impute_na_knn(dat, k = 2, verbose = FALSE)
  for (name in c("variable", "j", "indexNA2s", "TF", ".knn_1", "group name")) {
    x <- dat; names(x)[3] <- name
    before <- x
    result <- impute_na_knn(x, k = 2, verbose = FALSE)
    expect_identical(names(result), names(x))
    expect_identical(result$value, reference$value)
    expect_identical(result[[name]], reference$constant)
    expect_identical(x, before)
  }
})

test_that("impute_na_knn handles equal zero similarity weights", {
  skip_if_not_installed("VIM")
  dat <- data.frame(value = c(0, 10, NA_real_), helper = factor(c("A", "A", "B")))
  expect_no_warning(result <- impute_na_knn(dat, k = 2, verbose = FALSE))
  expect_identical(result$value, c(0, 10, 5))
  expect_identical(result$helper, dat$helper)
})

test_that("impute_na_knn retains wholly missing observations without invented predictors", {
  skip_if_not_installed("VIM")
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, NA_real_))
  expect_warning(result <- impute_na_knn(dat, k = 2, verbose = FALSE), "left.*missing")
  expect_identical(result, dat)
  expect_false(any(vapply(result, function(x) any(is.nan(x)), logical(1))))
})

test_that("impute_na_knn rejects infinite numeric distance inputs", {
  skip_if_not_installed("VIM")
  for (col in c("value", "helper")) {
    dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2))
    dat[[col]][2] <- Inf
    expect_error(impute_na_knn(dat, k = 2, verbose = FALSE), "finite.*numeric|infinite")
  }
})

test_that("impute_na_knn restores labelled donor values without decimal rounding", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  for (values in list(c(1, 1 + .Machine$double.eps, NA_real_),
                      c(1.234567890123456, 2.345678901234567, NA_real_))) {
    x <- haven::labelled(values, labels = c(First = values[1]), label = "Precise")
    dat <- data.frame(value = x, helper = c(0, 10, 10))
    result <- impute_na_knn(dat, k = 1, verbose = FALSE)
    expect_identical(as.double(result$value), c(values[1:2], values[2]))
    expect_identical(attributes(result$value), attributes(x))
    expect_identical(dat$value, x)
  }
})

test_that("impute_na_knn keeps integer truncation explicit without assignment warnings", {
  skip_if_not_installed("VIM")
  for (values in list(c(0L, 10L, NA_integer_), c(0L, -10L, NA_integer_))) {
    dat <- data.frame(value = values, helper = c(0, 10, 2.9))
    numeric_data <- dat; numeric_data$value <- as.double(values)
    reference <- impute_na_knn(numeric_data, k = 2, verbose = FALSE)
    expect_no_warning(result <- impute_na_knn(dat, k = 2, verbose = FALSE))
    expect_identical(result$value, as.integer(reference$value))
    expect_type(result$value, "integer")
    expect_identical(result$helper, dat$helper)
  }
})

test_that("impute_na_knn validates column identities and storage shapes", {
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2))
  for (names in list(c("x", "x"), c("", "helper"), c(NA_character_, "helper"))) {
    x <- dat; names(x) <- names
    expect_error(impute_na_knn(x, k = 2, verbose = FALSE), "unique.*column names")
  }
  for (value in list(matrix(1:6, nrow = 3), list(0, 10, NA_real_), expression(0, 10, NA))) {
    x <- dat; x$value <- value
    expect_error(impute_na_knn(x, k = 2, verbose = FALSE), "one-dimensional|atomic")
  }
  expect_error(impute_na_knn(dat["value"], k = 2, verbose = FALSE), "predictor")
  expect_identical(impute_na_knn(dat[FALSE, ], verbose = FALSE), dat[FALSE, ])
})

test_that("impute_na_knn requires scalar imputation controls", {
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2))
  for (k in list(matrix(1), c(1, 2), NA_real_, 0, 1.5, Inf)) {
    expect_error(impute_na_knn(dat, k = k, verbose = FALSE), "k.*single positive integer")
  }
  for (verbose in list(matrix(TRUE), c(TRUE, FALSE), NA, "TRUE")) {
    expect_error(impute_na_knn(dat, k = 1, verbose = verbose), "verbose.*TRUE.*FALSE")
  }
})

test_that("impute_na_knn preserves patient row identities and order", {
  skip_if_not_installed("VIM")
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2.5),
                    row.names = c("patient-C", "patient-A", "patient-B"))
  before <- dat
  result <- impute_na_knn(dat, k = 2, verbose = FALSE)
  expect_identical(rownames(result), rownames(dat))
  expect_identical(result$helper, dat$helper)
  expect_identical(result$value[1:2], dat$value[1:2])
  expect_identical(dat, before)
})

test_that("impute_na_knn retains automatic row-name storage for ordinary data frames", {
  skip_if_not_installed("VIM")
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2.5))
  result <- impute_na_knn(dat, k = 2, verbose = FALSE)
  expect_identical(attr(result, "row.names"), attr(dat, "row.names"))
})

knn_time_vectors <- function(values) {
  out <- list(date = as.Date(values, origin = "1970-01-01"),
              datetime = as.POSIXct(values, origin = "1970-01-01", tz = "UTC"),
              datetime_list = as.POSIXlt(values, origin = "1970-01-01", tz = "UTC"),
              elapsed = as.difftime(values, units = "days"))
  if (requireNamespace("lubridate", quietly = TRUE)) out$duration <- lubridate::duration(values)
  out
}

test_that("impute_na_knn uses time vectors consistently as distance predictors", {
  skip_if_not_installed("VIM")
  for (helper in knn_time_vectors(c(0, 10, 8))) {
    dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 8)); dat$helper <- helper
    before <- unserialize(serialize(dat, NULL))
    result <- impute_na_knn(dat, k = 2, verbose = FALSE)
    expect_equal(result$value, c(0, 10, 8))
    expect_identical(result$helper, helper)
    expect_identical(dat, before)
  }
})

test_that("impute_na_knn restores time targets without changing observed values or attributes", {
  skip_if_not_installed("VIM")
  for (value in knn_time_vectors(c(0, 10, NA_real_))) {
    dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2.5)); dat$value <- value
    before <- unserialize(serialize(dat, NULL))
    result <- impute_na_knn(dat, k = 2, verbose = FALSE)
    expect_equal(as.numeric(result$value), c(0, 10, 2.5))
    expect_identical(result$value[1:2], value[1:2])
    expect_identical(attributes(result$value), attributes(value))
    expect_identical(dat, before)
  }
})

test_that("impute_na_knn diagnoses calendar spans and unsupported atomic storage", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("lubridate")
  for (value in list(lubridate::seconds(c(0, 10, NA_real_)),
                     lubridate::period(c(0, 10, NA_real_), units = "month"),
                     lubridate::interval(as.POSIXct(c(0, 10, NA_real_), origin = "1970-01-01", tz = "UTC"),
                                         as.POSIXct(c(1, 20, NA_real_), origin = "1970-01-01", tz = "UTC")),
                     c(0+0i, 10+1i, NA_complex_), as.raw(1:3))) {
    dat <- data.frame(value = c(0, 10, 5), helper = c(0, 10, NA_real_)); dat$value <- value
    expect_error(impute_na_knn(dat, k = 2, verbose = FALSE), "unsupported|convert")
  }
})

test_that("impute_na_knn accepts backends with the legacy public argument set", {
  skip_if_not_installed("VIM")
  current <- VIM::kNN
  legacy <- function(data, variable, k, numFun, catFun, weightDist, useImputedDist, imp_var, trace) {
    current(data = data, variable = variable, k = k, numFun = numFun, catFun = catFun,
            weightDist = weightDist, useImputedDist = useImputedDist, imp_var = imp_var, trace = trace)
  }
  testthat::local_mocked_bindings(kNN = legacy, .package = "VIM")
  dat <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 10, 2.5))
  result <- impute_na_knn(dat, k = 2, verbose = FALSE)
  expect_equal(result$value, c(0, 10, 2.5))
  expect_identical(result$helper, dat$helper)
})

test_that("weighted KNN means preserve subnormal donor scales", {
  skip_if_not_installed("VIM")
  d <- data.frame(value = c(1, 2, NA_real_), helper = c(1 - .Machine$double.eps, 1, 0))
  reference <- impute_na_knn(d, k = 2, verbose = FALSE)[["value"]]
  for (scale in c(1e-320, -1e-320)) {
    tiny <- d
    tiny[["value"]] <- tiny[["value"]] * scale
    result <- impute_na_knn(tiny, k = 2, verbose = FALSE)[["value"]]
    expect_equal(result / scale, reference, tolerance = .001)
    expect_identical(result[1:2], tiny[["value"]][1:2])
  }
})

test_that("KNN donor selection preserves extreme finite predictor ranges", {
  skip_if_not_installed("VIM")
  d <- data.frame(value = c(1, 9, NA_real_), helper = c(-1, 1, .5))
  expected <- impute_na_knn(d, k = 1, verbose = FALSE)
  d[["helper"]] <- d[["helper"]] * 1e308
  actual <- impute_na_knn(d, k = 1, verbose = FALSE)
  expect_identical(actual[["value"]], expected[["value"]])
  expect_identical(actual[["helper"]], d[["helper"]])
  d[["value"]] <- c(-1e308, 1e308, NA_real_)
  actual <- impute_na_knn(d, k = 1, verbose = FALSE)
  expect_identical(actual[["value"]], c(-1e308, 1e308, 1e308))
})

test_that("KNN distances preserve large common numeric offsets", {
  skip_if_not_installed("VIM")
  d <- data.frame(value = c(0, 10, NA_real_), helper = c(0, 6, 2))
  reference <- impute_na_knn(d, k = 2, verbose = FALSE)[["value"]]
  for (offset in c(1e16, -1e16)) {
    shifted <- d
    shifted[["helper"]] <- shifted[["helper"]] + offset
    result <- impute_na_knn(shifted, k = 2, verbose = FALSE)
    expect_equal(result[["value"]], reference, tolerance = 1e-12)
    expect_identical(result[["helper"]], shifted[["helper"]])
  }
  d[["value"]] <- c(0, 6, NA_real_) + 1e16
  result <- impute_na_knn(d, k = 2, verbose = FALSE)
  expect_identical(result[["value"]], c(0, 6, 2) + 1e16)
})

test_that("KNN complete columns avoid a whole data missingness mask", {
  skip_if_not_installed("VIM")
  fn <- impute_na_knn
  e <- new.env(parent = environment(fn))
  examined <- 0L
  e$is.na <- function(x) {
    if (is.data.frame(x)) examined <<- examined + nrow(x) * ncol(x)
    base::is.na(x)
  }
  environment(fn) <- e
  d <- data.frame(value = c(1, NA_real_, 3, 4), id = c(0, .9, 1, 2),
                  row.names = paste0("patient_", 1:4))
  actual <- fn(d, k = 1, verbose = FALSE)
  expect_identical(examined, 0L)
  expect_identical(actual$value, c(1, 3, 3, 4))
  expect_identical(rownames(actual), rownames(d))
  expect_identical(actual$id, d$id)
  d$id[3L] <- NA_real_
  examined <- 0L
  expect_no_warning(fn(d, k = 1, verbose = FALSE))
  expect_identical(examined, 0L)
  d$id[2L] <- NA_real_
  expect_warning(actual <- fn(d, k = 1, verbose = FALSE), "KNN left")
  expect_true(all(is.na(actual[2L, ])))
})

test_that("KNN keeps explicit NA levels distinct from missing factor codes", {
  skip_if_not_installed("VIM")
  for (ordered in c(FALSE, TRUE)) {
    x <- structure(c(2L, 1L, 3L, 4L, NA_integer_, NA_integer_),
                   levels = c("b", NA_character_, ".knn_level_1", "NA's", "unused"),
                   class = if (ordered) c("ordered", "factor") else "factor",
                   label = "Original categories")
    data <- data.frame(target = x, predictor = c(0, 10, 20, 30, .1, 19.9))
    before <- data
    expect_no_warning(result <- impute_na_knn(data, k = 1, verbose = FALSE))
    expect_identical(as.integer(result$target), c(2L, 1L, 3L, 4L, 2L, 3L))
    expect_identical(attributes(result$target), attributes(x))
    expect_false(anyNA(result$target))
    expect_identical(result$predictor, data$predictor)
    expect_identical(data, before)
  }
})

test_that("KNN backend reuses columns when every row has a predictor", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("lobstr")
  data <- data.frame(observed = as.double(seq_len(40L)), target = c(NA_real_, 2:40))
  original <- VIM::kNN
  backend_address <- NULL
  testthat::local_mocked_bindings(kNN = function(data, ...) {
    backend_address <<- lobstr::obj_addr(data[[1L]])
    original(data, ...)
  }, .package = "VIM")
  result <- impute_na_knn(data, k = 1L, verbose = FALSE)
  expect_identical(backend_address, lobstr::obj_addr(data$observed))
  expect_identical(result$observed, data$observed)
  expect_equal(result$target[1L], 2)
})

test_that("KNN time restoration converts only imputed dates", {
  skip_if_not_installed("VIM")
  fn <- impute_na_knn
  converted <- integer()
  environment(fn) <- list2env(list(as.Date = function(x, ...) {
    converted <<- c(converted, length(x))
    base::as.Date(x, ...)
  }), parent = environment(fn))
  dates <- as.Date("2026-01-01") + seq_len(400)
  data <- data.frame(predictor = c(1:399, 399.25), date = dates, complete_date = dates)
  data$date[400L] <- NA
  result <- fn(data, k = 1L, verbose = FALSE)
  expect_identical(converted, 1L)
  expect_identical(result$date, c(dates[1:399], dates[399L]))
  expect_identical(result$complete_date, dates)
})

test_that("KNN observes rows without allocating a frame-wide missing mask", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(1, 2, NA, 4, NA), y = c(NA, 2, 3, 4, NA),
                  z = c(1, NA, 3, 4, NA))
  reference <- suppressWarnings(impute_na_knn(d, k = 1, verbose = FALSE))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$is.na <- function(x) {
    if (is.data.frame(x)) stop("constructed a full missingness matrix")
    base::is.na(x)
  }
  environment(fn) <- env
  expect_warning(result <- fn(d, k = 1, verbose = FALSE), "KNN left")
  expect_identical(result, reference)
  expect_true(all(is.na(result[5L, ])))
})

test_that("ordinary KNN donor means skip the magnitude pass", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(11, 19, NA, 25), y = c(1, 3, 2, 4))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$max <- function(..., na.rm = FALSE) {
    values <- list(...)
    if (length(values) == 1L && identical(sort(values[[1L]]), c(11, 19))) {
      stop("rescanned ordinary donors")
    }
    base::max(..., na.rm = na.rm)
  }
  environment(fn) <- env
  local_mocked_bindings(kNN = function(data, variable, k, numFun, ...) {
    data[[variable]][3L] <- numFun(c(11, 19), weights = c(.25, .75))
    data
  }, .package = "VIM")
  expect_identical(fn(d, k = 2, verbose = FALSE)$x, c(11, 19, 17, 25))
})

test_that("complete data table imputation returns without copying the frame", {
  skip_if_not_installed("data.table")
  d <- data.table::data.table(a = rep(1:20, 20L), b = rep(20:1, 20L))
  data.table::setkeyv(d, "a")
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$as.data.frame <- function(x, ...) {
    if (inherits(x, "data.table") && !anyNA(x$a)) stop("copied a complete data table")
    base::as.data.frame(x, ...)
  }
  environment(fn) <- env
  before <- data.table::copy(d)
  expect_identical(fn(d, verbose = FALSE), before)
  expect_identical(d, before)
})

test_that("KNN restores explicit missing factor levels only for imputed rows", {
  skip_if_not_installed("VIM")
  scores <- c(seq_len(100L), 1.01)
  f <- structure(c(2L, rep(c(1L, 3L), length.out = 99L), NA_integer_),
    levels = c("a", NA, "b"), class = c("ordered", "factor"))
  d <- data.frame(f = f, score = scores)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$as.character <- function(x, ...) {
    if (is.factor(x) && length(x) == nrow(d)) stop("decoded every imputed factor row")
    base::as.character(x, ...)
  }
  environment(fn) <- env
  result <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(result, impute_na_knn(d, k = 1L, verbose = FALSE))
  expect_identical(as.integer(tail(result$f, 1L)), 2L)
  expect_identical(attributes(result$f), attributes(f))
})

test_that("KNN labelled restoration leaves complete predictors on their original storage", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  n <- 120L
  d <- data.frame(x = c(NA, 2:n),
    group = haven::labelled(rep(c("alpha", "beta"), length.out = n), c(A = "alpha")))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$as.integer <- function(x, ...) {
    if (is.factor(x) && length(x) == n &&
        any(vapply(sys.calls(), function(call) grepl("^as.integer\\(values\\)", deparse1(call)),
                   logical(1)))) stop("decoded complete labelled predictions")
    base::as.integer(x, ...)
  }
  environment(fn) <- env
  result <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(result, impute_na_knn(d, k = 1L, verbose = FALSE))
  expect_identical(result$group, d$group)
  expect_false(anyNA(result$x))
})

test_that("KNN checks category collisions only for labelled doubles", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  d <- data.frame(score = c(NA, 2:60),
    a = haven::labelled_spss(rep(1:3, 20L), na_values = 99L),
    b = haven::labelled(rep(c("low", "high"), 30L)))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$unique <- function(x, ...) {
    if (length(x) == nrow(d) && (is.integer(x) || is.character(x))) {
      stop("scanned raw labels for integer and character values")
    }
    base::unique(x, ...)
  }
  environment(fn) <- env
  result <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(result, impute_na_knn(d, k = 1L, verbose = FALSE))
  expect_identical(result$a, d$a)
  expect_identical(result$b, d$b)
})

test_that("KNN wholly missing rows avoid preparing a backend", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  d <- data.frame(value = c(seq_len(500L), NA_real_),
    time = as.Date("2026-01-01") + c(seq_len(500L), NA_integer_),
    category = haven::labelled_spss(c(rep(1:2, 250L), 99L), na_values = 99L),
    row.names = paste0("patient-", seq_len(501L)))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$range <- function(x, ...) {
    if (identical(x, d$value[-501L])) stop("prepared an unused KNN backend")
    base::range(x, ...)
  }
  environment(fn) <- env
  expect_warning(result <- fn(d, k = 2L, verbose = FALSE), "left 3 missing")
  expect_warning(expected <- impute_na_knn(d, k = 2L, verbose = FALSE), "left 3 missing")
  expect_identical(result, expected)
  expect_identical(result$value, d$value)
  expect_identical(result$time, d$time)
  expect_identical(result$category[-501L], d$category[-501L])
  expect_true(is.na(result$category[501L]))
  expect_identical(rownames(result), rownames(d))
})

test_that("KNN complete integer64 predictors need no reconstruction", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("bit64")
  d <- data.frame(value = c(1, NA, 3, 4),
    id = bit64::as.integer64(c("9007199254740989", "9007199254740990",
                               "9007199254740991", "9007199254740992")))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  restore <- bit64::as.integer64
  local_mocked_bindings(as.integer64 = function(x, ...) {
    if (is.double(x) && !length(x)) stop("reconstructed a complete integer64 predictor")
    restore(x, ...)
  }, .package = "bit64")
  actual <- impute_na_knn(d, k = 1L, verbose = FALSE)
  expect_identical(actual, expected)
  expect_identical(actual$id, d$id)
  expect_false(anyNA(actual$value))
})

test_that("complete explicit NA factor predictors need no KNN recoding", {
  skip_if_not_installed("VIM")
  f <- structure(rep(c(1L, 2L, 3L), 4L), levels = c("a", NA, "b"),
                 class = c("ordered", "factor"))
  d <- data.frame(x = c(1, NA, 3:12), marker = seq_len(12L), category = f)
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$as.integer <- function(x, ...) {
    if (identical(x, f)) stop("recoded a complete factor predictor")
    base::as.integer(x, ...)
  }
  environment(fn) <- env
  actual <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(actual, expected)
  expect_identical(actual$category, f)
  expect_false(anyNA(actual$x))
})

test_that("KNN complete predictors do not allocate a full true row mask", {
  skip_if_not_installed("VIM")
  d <- data.frame(value = c(NA_integer_, 2:30), predictor = 1:30)
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$rep <- function(x, times, ...) {
    if (identical(x, TRUE) && identical(times, nrow(d))) stop("allocated all KNN row flags")
    base::rep(x, times, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), expected)
})

test_that("KNN prepares ordinary backend columns without a second missingness scan", {
  skip_if_not_installed("VIM")
  d <- data.frame(a = c(NA_integer_, 2:27), x = 1:27, z = rep(c(TRUE, FALSE, TRUE), 9L))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$vapply <- function(X, FUN, FUN.VALUE, ...) {
    if (identical(substitute(X), quote(backend_data)) && identical(FUN, base::anyNA)) {
      stop("rescanned ordinary KNN backend columns")
    }
    base::vapply(X, FUN, FUN.VALUE, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), expected)
})

test_that("complete labelled and time predictors need no restoration masks", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  d <- data.frame(y = c(NA_integer_, 2:27), x = 1:27, time = as.Date("2026-01-01") + 1:27,
    label = haven::labelled(rep(1:3, 9L), c(A = 1L, B = 2L, C = 3L)))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$is.na <- function(x) {
    if (identical(substitute(x), quote(original)) &&
        (inherits(x, "Date") || inherits(x, "haven_labelled"))) {
      stop("allocated a complete predictor restoration mask")
    }
    base::is.na(x)
  }
  environment(fn) <- env
  actual <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(actual, expected)
  expect_identical(actual[c("time", "label")], d[c("time", "label")])
})

test_that("KNN infinity checks avoid finite and missing masks on ordinary columns", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(1, NA, 3:30), y = as.double(1:30))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$is.finite <- function(x) {
    if (length(x) == nrow(d)) stop("allocated a full KNN finite-value vector")
    base::is.finite(x)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
  d$y[2L] <- Inf
  expect_error(fn(d, k = 1L, verbose = FALSE), "infinite values")
})

test_that("complete labelled KNN lookups skip their missingness vector", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  d <- data.frame(x = c(NA, 2:30), y = haven::labelled(rep(c(1, 1 + .Machine$double.eps, 2), 10L)))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$is.na <- function(x) {
    if (identical(substitute(x), quote(original)) && inherits(x, "haven_labelled"))
      stop("allocated a complete labelled lookup mask")
    base::is.na(x)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), expected)
})

test_that("KNN donor counts use direct missing totals", {
  d <- data.frame(x = c(1, NA, 3, 4), y = 4:1)
  expected <- impute_na_knn(d, k = 1, verbose = FALSE)
  fn <- impute_na_knn
  guard <- function(x) {
    if (identical(substitute(x), quote(is.na(x)))) stop("inverted KNN donor mask")
    base::`!`(x)
  }
  environment(fn) <- list2env(stats::setNames(list(guard), "!"), parent = environment(fn))
  expect_identical(fn(d, k = 1, verbose = FALSE), expected)
  expect_error(fn(d, k = 4, verbose = FALSE), "Insufficient donors")
})

test_that("scaled complete KNN predictors skip observation restoration masks", {
  d <- data.frame(x = c(1, NA, 3, 4), y = 1e15 + c(1, 2, 3, 4))
  expected <- impute_na_knn(d, k = 1, verbose = FALSE)
  fn <- impute_na_knn
  environment(fn) <- list2env(list(is.na = function(x) {
    if (identical(substitute(x), quote(original)) && identical(x, d$y))
      stop("complete predictor missingness rescanned")
    base::is.na(x)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1, verbose = FALSE), expected)
})

test_that("KNN integer extremes retain integer storage without overflow warnings", {
  d <- data.frame(x = c(-2147483647L, NA_integer_, 2147483647L, 0L), y = c(0, 1, 100, 200))
  expect_no_warning(out <- impute_na_knn(d, k = 1, verbose = FALSE))
  expect_identical(out$x, c(-2147483647L, -2147483647L, 2147483647L, 0L))
})

test_that("ordinary integer KNN columns require no infinity scan", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(1, NA_real_, 3:15), predictor = seq_len(15L))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$is.infinite <- function(x) {
    if (identical(x, d$predictor)) stop("looked for infinities in an integer column")
    base::is.infinite(x)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), expected)
})

test_that("sparse nominal KNN factors compact coded missing levels", {
  skip_if_not_installed("VIM")
  x <- structure(c(81L, 2L, 12L, 12L, NA_integer_), levels = c(
    "a", "b", paste0("unused", seq_len(78L)), NA_character_), class = "factor")
  d <- data.frame(group = x, predictor = c(1, 10, 20, 21, 1.01))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$paste0 <- function(...) {
    args <- list(...)
    if (length(args) == 2L && identical(args[[1L]], ".knn_level_") && length(args[[2L]]) > 5L)
      stop("sent unused nominal KNN levels to the backend")
    base::paste0(...)
  }
  environment(fn) <- env
  actual <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(actual, expected)
  expect_identical(as.integer(actual$group[5L]), 81L)
})

test_that("scaled KNN columns do not slice fully observed row sets", {
  skip_if_not_installed("VIM")
  m <- .Machine$double.xmax
  d <- data.frame(y = c(1, 2, NA, 4, 5), predictor = c(-m, m, -m, m, 0))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env[["["]] <- function(x, i, ...) {
    if (identical(substitute(i), quote(observed_rows)) && isTRUE(i) && identical(x, d$predictor))
      stop("copied a full scaled KNN column")
    base::"["(x, i, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), expected)
})

test_that("explicit missing KNN factor restoration reuses backend codes", {
  skip_if_not_installed("VIM")
  f <- structure(c(2L, 1L, 1L, 3L, NA_integer_), levels = c("A", NA_character_, "B"),
    class = "factor")
  d <- data.frame(f = f, near = c(1, 10, 15, 23, 1.01))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$as.character <- function(x, ...) {
    if (is.factor(x) && any(startsWith(levels(x), ".knn_level_")))
      stop("decoded predicted factor text before restoration")
    base::as.character(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), expected)
})

test_that("KNN integer64 preflight reads extrema while enforcing both precision limits", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("bit64")
  d <- data.frame(score = c(1, NA, 3, 4), id = bit64::as.integer64(c(-3, 2, 4, 6)))
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env[["|"]] <- function(e1, e2) {
    if (identical(substitute(e1), quote(x > limit))) stop("allocated both integer64 precision masks")
    base::"|"(e1, e2)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
  for (value in c("9007199254740993", "-9007199254740993")) {
    d$id[1L] <- bit64::as.integer64(value)
    expect_error(fn(d, k = 1L, verbose = FALSE), "exact double precision")
  }
})

test_that("complete ordinary KNN predictors avoid a second missingness probe", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(1, 3, NA, 4), helper = 1:4)
  fn <- impute_na_knn
  env <- new.env(parent = environment(fn))
  env$anyNA <- function(x, ...) {
    if (identical(substitute(x), quote(data_for_impute[[complete_columns[[1L]]]])))
      stop("rechecked a complete ordinary KNN predictor")
    base::anyNA(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
})

test_that("complete KNN results do not allocate a final missing mask", {
  skip_if_not_installed("VIM")
  d <- data.frame(value = c(4, 7, NA, 2, 8), partner = c(1, 2, 2, 4, 5))
  expected <- impute_na_knn(d, k = 1, verbose = FALSE)
  fn <- impute_na_knn
  environment(fn) <- list2env(list(is.na = function(x) {
    if (identical(x, expected$value)) stop("scanned every row of a complete KNN result")
    base::is.na(x)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1, verbose = FALSE), expected)
})

test_that("integer KNN predictors skip numeric range stabilisation work", {
  skip_if_not_installed("VIM")
  d <- data.frame(query = c(-1, 0, 1, NA, 4), predictor = c(0L, 4L, 9L, 10L, 20L))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(range = function(x, ...) {
    if (identical(x, d[["predictor"]])) stop("measured a range for an ordinary integer KNN predictor")
    base::range(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
})

test_that("KNN checks double infinities with scalar extrema", {
  value <- c(0, 2, NA_real_, 3, 5)
  d <- data.frame(value = value, aux = c(0, 1, 2, 3, 4))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(is.infinite = function(x) {
    if (identical(x, value)) stop("allocated a KNN infinity mask for plain values")
    base::is.infinite(x)
  }), parent = environment(fn))
  skip_if_not_installed("VIM")
  expect_identical(fn(d, k = 1L), impute_na_knn(d, k = 1L))
  d$value[1L] <- Inf
  expect_error(fn(d, k = 1L), "finite numeric observations")
  d$value[1L] <- -Inf
  expect_error(fn(d, k = 1L), "finite numeric observations")
})

test_that("KNN backend preparation reuses validated numeric extrema", {
  skip_if_not_installed("VIM")
  d <- data.frame(target = c(2, 4, NA_real_, 9), depth = c(0.3, 0.4, 0.9, 1.1))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(range = function(x, ...) {
    if (identical(substitute(x), quote(values)) && is.double(x) && !is.object(x))
      stop("recomputed a validated KNN double range")
    base::range(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
  d$depth <- d$depth + 1e10
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
})

test_that("KNN integer64 precision bounds are reused across columns", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("bit64")
  d <- data.frame(x = c(1, NA, 4, 2, 3), id = bit64::as.integer64(1:5),
    other = bit64::as.integer64(c(2, 12, 7, 0, 1)))
  expected <- impute_na_knn(d, k = 1L, verbose = FALSE)
  convert <- bit64::as.integer64
  calls <- 0L
  local_mocked_bindings(as.integer64 = function(x, ...) {
    if (identical(x, "9007199254740992")) {
      calls <<- calls + 1L
      if (calls > 1L) stop("converted the exact integer64 limit twice")
    }
    convert(x, ...)
  }, .package = "bit64")
  expect_identical(impute_na_knn(d, k = 1L, verbose = FALSE), expected)
  expect_identical(calls, 1L)
})

test_that("complete labelled predictors do not build a restoration lookup", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  d <- data.frame(x = c(NA_real_, 2, 3, 4), complete = haven::labelled(c(1, 2, 1, 2)),
                  target = haven::labelled(c(8, NA_real_, 8, 9)))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(match = function(x, table, ...) {
    if (identical(substitute(x), quote(seq_len(nlevels(categories)))) &&
        identical(get("var_name", envir = parent.frame()), "complete"))
      stop("built a restoration lookup for a complete KNN label")
    base::match(x, table, ...)
  }), parent = environment(fn))
  result <- fn(d, k = 1L, verbose = FALSE)
  expect_identical(result, impute_na_knn(d, k = 1L, verbose = FALSE))
  expect_identical(result$complete, d$complete)
  expect_identical(attributes(result$target), attributes(d$target))
})

test_that("ordinary KNN keeps initial missing column positions", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(NA, 2L, 3L, 4L), keep = 1:4, y = c(0, NA, 0, 1))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(match = function(x, table, ...) {
    if (identical(substitute(x), quote(vars_with_missing)))
      stop("rematched KNN column names after missingness classification")
    base::match(x, table, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
})

test_that("ordinary KNN weights retain existing weighted and fallback means", {
  skip_if_not_installed("VIM")
  fn <- impute_na_knn
  environment(fn) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(weights))) stop("allocated a donor weight finiteness mask")
    base::is.finite(x)
  }), parent = environment(fn))
  local_mocked_bindings(kNN = function(data, variable, k, numFun, ...) {
    x <- c(2, 4, 8)
    expect_equal(numFun(x, weights = c(0.5, 0, 1)), 6)
    expect_equal(numFun(x, weights = c(NA, 0, 1)), mean(x))
    expect_equal(numFun(x, weights = c(0, 0, 0)), mean(x))
    data[[variable]][1L] <- numFun(x, weights = c(0.5, 0, 1))
    data
  }, .package = "VIM")
  d <- data.frame(x = c(NA, 2, 4, 8), y = 1:4)
  expect_equal(fn(d, k = 1L, verbose = FALSE)$x, c(6, 2, 4, 8))
})

test_that("complete labelled integer predictors skip restoration code conversion", {
  skip_if_not_installed("VIM")
  skip_if_not_installed("haven")
  d <- data.frame(x = c(0, 1, NA_real_, 2), g = haven::labelled(c(1L, 2L, 1L, 2L)))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(as.integer = function(x, ...) {
    if (identical(substitute(x), quote(categories))) stop("converted unused restoration codes for a complete KNN predictor")
    base::as.integer(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
})

test_that("ordinary KNN data bypass empty labelled conversion", {
  skip_if_not_installed("VIM")
  d <- data.frame(x = c(1, 2, 3, NA), group = factor(c("a", "a", "b", "b")))
  fn <- impute_na_knn
  environment(fn) <- list2env(list("[<-" = function(x, i, ..., value) {
    if (identical(substitute(i), quote(labelled_cols)) && !any(i))
      stop("replaced an empty KNN labelled selection")
    base::"[<-"(x, i, ..., value = value)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1L, verbose = FALSE), impute_na_knn(d, k = 1L, verbose = FALSE))
})

test_that("KNN starts observed rows from the first column mask", {
  skip_if_not_installed("VIM")
  d <- data.frame(a = c(1, NA, 3, 4, 8, 9), b = c(1, 2, NA, 4, 8, 9))
  fn <- impute_na_knn
  environment(fn) <- list2env(list(rep = function(x, ...) {
    if (isFALSE(x) && identical(substitute(list(...))[[2L]], quote(nrow(data_for_impute))))
      stop("allocated an empty KNN eligibility mask")
    base::rep(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(d, k = 1L, verbose = FALSE),
                   impute_na_knn(d, k = 1L, verbose = FALSE))
})
