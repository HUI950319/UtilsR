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
