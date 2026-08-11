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
