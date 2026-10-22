test_that("named vectors cannot change paste or order controls", {
  a <- factor(c("M", "F", "M"), levels = c("M", "F"))
  b <- factor(c("old", "young", "young"), levels = c("young", "old"))
  expected <- factor(c("M & old", "F & young", "M & young"),
                     levels = c("M & young", "M & old", "F & young"))

  for (nm in c("collapse", "recycle0", "na.last", "decreasing", "method")) {
    inputs <- stats::setNames(list(a, b), c("a", nm))
    expect_identical(do.call(fct_to_combine, inputs), expected)
    expect_identical(rlang::exec(fct_to_combine, !!!inputs), expected)
    data <- as.data.frame(inputs)
    data[["combined"]] <- do.call(fct_to_combine, c(inputs, list(sep = " & ")))
    expect_identical(data[["combined"]], expected)
  }

  data <- data.frame(a = a, sep = b)
  expect_identical(fct_to_combine(data, c("a", "sep"))[["a_sep"]], expected)
})

test_that("combination controls are validated before changing data", {
  data <- data.frame(a = c("M", "F"), b = c("old", "young"))
  for (sep in list(NA_character_, c("/", "|"), character(), 1, list("/"))) {
    expect_error(fct_to_combine(data$a, data$b, sep = sep),
                 "sep.*single.*string")
  }
  for (nm in list("", NA_character_, c("x", "y"), 1, list("x"))) {
    expect_error(fct_to_combine(data, c("a", "b"), var_name = nm),
                 "var_name.*single.*non-empty")
  }
  for (vars in list(c("a", "a"), c("a", NA), c("a", ""))) {
    expect_error(fct_to_combine(data, vars), "vars.*unique.*non-empty")
  }
  expect_error(fct_to_combine(data, c("a", "b"), var_namx = "group"),
               "must be empty")
  duplicated_names <- data
  names(duplicated_names) <- c("a", "a")
  expect_error(fct_to_combine(duplicated_names, c("a", "b")), "not found")
  duplicated_names$c <- c("X", "Y")
  expect_error(fct_to_combine(duplicated_names, c("a", "c")), "unique.*data")
  expect_identical(as.character(fct_to_combine(data$a, data$b, sep = "")),
                   c("Mold", "Fyoung"))
  expect_identical(fct_to_combine(data, c("a", "b"), var_name = "a")$a,
                   fct_to_combine(data$a, data$b))
})

test_that("combination inputs are one-dimensional atomic vectors", {
  for (x in list(matrix(1:4, 2), array(1:4, c(2, 1, 2)), list(1, 2))) {
    expect_error(fct_to_combine(x, x), "one-dimensional atomic vectors")
  }
  expect_error(fct_to_combine(matrix(c("a", "b"), 1)),
               "one-dimensional atomic vectors")
  expect_error(fct_to_combine(1:2, 1:3), "same length")
  expect_identical(fct_to_combine(character(), character()), factor(character()))
  x <- as.Date(c("2020-01-01", "2020-01-02"))
  expect_identical(as.character(fct_to_combine(x, c("A", "B"))),
                   c("2020-01-01 & A", "2020-01-02 & B"))
})
