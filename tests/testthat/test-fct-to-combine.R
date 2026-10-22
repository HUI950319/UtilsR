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

test_that("missing inputs propagate without consuming the literal NA category", {
  a <- factor(c(NA, "NA", "A", "A"), levels = c("NA", "A"))
  b <- c("X", "X", NA, "Y")
  expected <- factor(c(NA, "NA & X", NA, "A & Y"),
                     levels = c("NA & X", "A & Y"))
  expect_identical(fct_to_combine(a, b), expected)
  expect_identical(fct_to_combine(data.frame(a, b), c("a", "b"))$a_b, expected)
  expect_identical(is.na(fct_to_combine(c(1, NA, NaN), rep("X", 3))),
                   c(FALSE, TRUE, TRUE))
  expect_identical(fct_to_combine(c(NA, NA), c("A", "B")),
                   factor(c(NA_character_, NA_character_)))
})

test_that("SPSS missing codes and ranges propagate", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(c(1, 9, 90, 95, NA, NaN),
                           na_values = 9, na_range = c(90, 99))
  expect_identical(is.na(fct_to_combine(x, rep("X", 6))),
                   c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE))
  expect_identical(levels(fct_to_combine(x, rep("X", 6))), "1 & X")
  x <- haven::labelled(c(1, haven::tagged_na("a"), NA))
  expect_identical(is.na(fct_to_combine(x, rep("X", 3))), c(FALSE, TRUE, TRUE))
})

test_that("integer64 labels and missing values retain their meaning", {
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(c("9007199254740993", "9007199254740994", NA))
  expect_identical(as.character(fct_to_combine(x, rep("X", 3))),
                   c("9007199254740993 & X", "9007199254740994 & X", NA))
})

test_that("distinct tuples cannot silently share a label", {
  a <- c("A & B", "A")
  b <- c("C", "B & C")
  expect_error(fct_to_combine(a, b), "Distinct combinations.*same label")
  expect_error(fct_to_combine(data.frame(a, b), c("a", "b")),
               "Distinct combinations.*same label")
  expect_error(fct_to_combine(c("ab", "a"), c("c", "bc"), sep = ""),
               "Distinct combinations.*same label")
  expect_identical(as.character(fct_to_combine(a, b, sep = " / ")),
                   c("A & B / C", "A / B & C"))
  expect_identical(fct_to_combine(rep("A & B", 3), rep("C", 3)),
                   factor(rep("A & B & C", 3)))
})

test_that("observed combinations follow input level priority", {
  a <- ordered(c("B", "A", "B", "B"), levels = c("B", "unused", "A"))
  b <- factor(c("X", "Y", "Y", "X"), levels = c("Y", "unused", "X"))
  expected <- factor(c("B & X", "A & Y", "B & Y", "B & X"),
                     levels = c("B & Y", "B & X", "A & Y"))
  expect_identical(fct_to_combine(a, b), expected)
  expect_identical(fct_to_combine(a[4:1], b[4:1]), expected[4:1])
  expect_identical(fct_to_combine(a[0], b[0]), factor(character()))
  expect_identical(fct_to_combine(a[1], b[1]), factor("B & X"))
  names(a) <- letters[1:4]
  expect_identical(fct_to_combine(a, b), expected)
  expect_identical(fct_to_combine(a), factor(c("B", "A", "B", "B"),
                                           levels = c("B", "A")))
})

test_that("data-frame and data-mask paths retain their documented contracts", {
  data <- tibble::tibble(a = factor(c("B", "A", "B"), levels = c("B", "A")),
                         b = factor(c("X", "Y", "Y")))
  expected <- fct_to_combine(data$a, data$b)
  expect_identical(class(fct_to_combine(data, c("a", "b"))), class(data))
  expect_identical(fct_to_combine(data[0, ], c("a", "b"))$a_b, factor(character()))
  expect_identical(dplyr::mutate(data, g = fct_to_combine(a, b))$g, expected)
  cols <- c("a", "b")
  expect_identical(dplyr::mutate(data, g = fct_to_combine(cols))$g, expected)
  grouped <- dplyr::group_by(data, a)
  combined <- fct_to_combine(grouped, cols)
  expect_identical(class(combined), class(grouped))
  expect_identical(dplyr::group_vars(combined), "a")
  expect_identical(combined$a_b, expected)
  expect_identical(as.character(dplyr::mutate(grouped, g = fct_to_combine(a, b))$g),
                   as.character(expected))
  expect_error(dplyr::mutate(grouped, g = fct_to_combine(cols)), "Cannot resolve")
  expect_error(fct_to_combine(c("A", "B")), "Cannot resolve")
})

test_that("data.table writes invalidate changed keys and indices without modifying input", {
  skip_if_not_installed("data.table")
  data <- data.table::data.table(a = c("a", "a", "a", "a", "b"),
                                b = c("Y", "X", "Y", "X", "Z"))
  data.table::setkeyv(data, "a")
  data.table::setindexv(data, "b")
  before <- data.table::copy(data)

  result <- fct_to_combine(data, c("a", "b"), var_name = "a")
  expect_null(data.table::key(result))
  expect_identical(as.character(result$a),
                   c("a & Y", "a & X", "a & Y", "a & X", "b & Z"))
  expect_identical(as.integer(table(result$a)), c(2L, 2L, 1L))
  expect_identical(data, before)
  expect_identical(class(result), class(data))

  result <- fct_to_combine(data, c("a", "b"), var_name = "b")
  expect_false("b" %in% data.table::indices(result))
  expect_identical(data, before)

  result <- fct_to_combine(data, c("a", "b"), var_name = "group")
  expect_identical(data.table::key(result), "a")
  expect_identical(data.table::indices(result), "b")
  expect_identical(as.character(result$group),
                   c("a & Y", "a & X", "a & Y", "a & X", "b & Z"))
  expect_identical(data, before)
})

test_that("column-name shortcuts share data-frame selector validation", {
  data <- data.frame(a = c("B", "A"), b = c("X", "Y"))
  for (cols in list(c("a", "a"), c("a", NA), c("a", ""))) {
    expect_error(dplyr::mutate(data, g = fct_to_combine(cols)),
                 "unique.*non-empty")
  }
  cols <- c(sep = "a", collapse = "b")
  expected <- fct_to_combine(data$a, data$b)
  expect_identical(dplyr::mutate(data, g = fct_to_combine(cols))$g, expected)
  expect_identical(fct_to_combine(data, cols, var_name = "g")$g, expected)
})

test_that("output names must identify an unambiguous column", {
  data <- data.frame(a = c("A", "B"), b = c("X", "Y"),
                     g = 1:2, g = 3:4, check.names = FALSE)
  before <- data
  expect_error(fct_to_combine(data, c("a", "b"), var_name = "g"),
               "Output column name.*ambiguous")
  expect_identical(data, before)
  names(data)[3:4] <- c("a_b", "a_b")
  expect_error(fct_to_combine(data, c("a", "b")),
               "Output column name.*ambiguous")

  result <- fct_to_combine(data, c("a", "b"), var_name = "group")
  expect_identical(result$group, fct_to_combine(data$a, data$b))
  expect_identical(names(result)[c(1, 2, 5)], c("a", "b", "group"))
})

test_that("a named data-frame x dispatches independently of control order", {
  data <- data.frame(a = c("A", "B"), b = c("X", "Y"))
  expected <- fct_to_combine(data, c("a", "b"), var_name = "g", sep = "/")
  controls <- list(vars = c("a", "b"), var_name = "g", sep = "/")
  for (i in 0:3) {
    call <- append(controls, list(x = data), after = i)
    expect_identical(do.call(fct_to_combine, call), expected)
    expect_identical(rlang::exec(fct_to_combine, !!!call), expected)
  }
  expect_identical(fct_to_combine(b = data$b, x = data$a),
                   fct_to_combine(data$b, data$a))
})
