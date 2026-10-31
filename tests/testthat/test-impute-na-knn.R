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
