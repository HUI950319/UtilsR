test_that("recoding into an unmatched level keeps every observation", {
  x <- factor(c("a", "b", "c", NA), levels = letters[1:4])
  expected <- factor(c("b", "b", "c", NA), levels = c("b", "c"))

  expect_identical(fct_cat(x, b = "a"), expected)
  expect_identical(fct_cat(x, b = 1L), expected)
  expect_identical(fct_cat(x, groups = list(b = 1L)), expected)
  expect_identical(fct_to_group(x, list(b = 1L)), expected)
  expect_identical(levels(x), letters[1:4])
  expect_identical(as.character(x), c("a", "b", "c", NA_character_))
})

test_that("recoding retains group-first ordering and drops unused levels", {
  x <- factor(c("a", "b", "c"), levels = letters[1:4])
  expect_identical(fct_cat(x, Z = "c"),
                   factor(c("a", "b", "Z"), levels = c("Z", "a", "b")))
})

test_that("binary reference labels cannot collide with the other group", {
  x <- factor(c("Oth", "a"), levels = c("Oth", "a"))
  expect_error(fct_cat(x, binary_ref = 1L), "conflicts with.*Oth")
  expect_identical(fct_cat(x, binary_ref = 2L),
                   factor(c("Oth", "a"), levels = c("a", "Oth")))
  expect_identical(fct_cat(factor("Oth"), binary_ref = 1L), factor("Oth"))
})

test_that("dots cannot be silently ignored by another factor mode", {
  x <- factor(letters[1:3])
  expect_error(fct_cat(x, A = "a", reverse = TRUE), "Only one mode")
  expect_error(fct_cat(x, "b", binary_ref = 1L), "Only one mode")
  expect_error(fct_cat(x, A = "a", groups = list(B = 2L)), "Only one mode")
  expect_error(fct_cat(x, A = "a", new_labels = LETTERS[1:3]), "Only one mode")
  expect_error(fct_cat(x, stop("dots must not be evaluated"), reverse = TRUE),
               "Only one mode")
  expect_identical(fct_cat(x, reverse = FALSE), x)
  expect_identical(fct_cat(x, A = "a", reverse = FALSE),
                   factor(c("A", "b", "c")))
})

test_that("factor modes validate logical flags and finite integer indices", {
  x <- factor(letters[1:3])
  for (flag in list(NA, NULL, 1, c(TRUE, FALSE))) {
    expect_error(fct_cat(x, reverse = flag), "single.*logical")
  }
  for (idx in list(NA_integer_, NaN, Inf, -Inf, 1.5, 1 + 1i)) {
    expect_no_warning(expect_error(fct_cat(x, binary_ref = idx), "finite integer"))
    expect_no_warning(expect_error(fct_cat(x, groups = list(A = idx)), "finite integer"))
    expect_no_warning(expect_error(fct_cat(x, idx), "finite integer"))
  }
  expect_no_warning(expect_error(fct_cat(x, 1e20), "between"))
  expect_error(fct_cat(x, "a", "a"), "duplicated")
  expect_error(fct_cat(x, groups = setNames(list(1L), "")), "non-empty names")
  expect_error(fct_cat(x, groups = setNames(list(1L), NA_character_)), "non-empty names")
})

test_that("recoding resolves each group's index or label before checking it", {
  x <- factor(c("a", "b", "c", NA))
  expect_identical(fct_cat(x, A = 1L, B = "b"),
                   factor(c("A", "B", "c", NA)))
  expect_error(fct_cat(x, A = "typo"), "not found.*typo")
  expect_error(fct_cat(x, A = 1L, B = "a"), "non-unique")
  expect_error(fct_cat(x, A = list("a")), "character.*integer")
  expect_identical(fct_cat(x, groups = list(A = 1L, A = 2L)),
                   factor(c("A", "A", "c", NA)))
})

test_that("factor operations preserve explicit missing levels and metadata", {
  x <- factor(c("a", NA, "b", "a"),
              levels = c("a", "b", "unused", NA),
              exclude = NULL, ordered = TRUE)
  is.na(x) <- c(FALSE, FALSE, FALSE, TRUE)
  names(x) <- paste0("r", 1:4)
  attr(x, "label") <- "Clinical grade"
  original <- x

  results <- list(
    reverse = fct_cat(x, reverse = TRUE),
    reorder = fct_cat(x, "b"),
    recode = fct_cat(x, AB = c("a", "b")),
    group = fct_cat(x, groups = list(AB = 1:2)),
    wrapper = fct_to_group(x, list(AB = 1:2)),
    binary = fct_cat(x, binary_ref = 1L),
    relabel = fct_cat(x, new_labels = c("A", "B", "U", "Missing"))
  )
  for (result in results) {
    expect_identical(class(result), class(x))
    expect_identical(names(result), names(x))
    expect_identical(attr(result, "label"), "Clinical grade")
    expect_identical(is.na(as.integer(result)), c(FALSE, FALSE, FALSE, TRUE))
  }
  expect_identical(levels(results[["reverse"]]), rev(levels(x)))
  expect_identical(levels(results[["reorder"]]), c("b", "a", "unused", NA))
  expect_identical(levels(results[["recode"]]), c("AB", NA_character_))
  expect_identical(as.integer(results[["recode"]]), c(1L, 2L, 1L, NA_integer_))
  expect_identical(x, original)
})

test_that("relabelling preserves metadata and base merging semantics", {
  x <- factor(c("a", "b", "c", NA), levels = letters[1:4])
  attr(x, "label") <- "Grade"
  for (labels in list(LETTERS[1:4], c("A", "A", "C", "U"),
                     c("A", NA, "C", "U"), setNames(LETTERS[1:4], 1:4), 1:4)) {
    expected <- x
    levels(expected) <- labels
    expect_identical(fct_cat(x, new_labels = labels), expected)
    expect_identical(fct_label(x, labels), expected)
    df <- data.frame(grade = x, id = 1:4)
    result <- fct_label(df, grade, labels)
    expect_identical(result[["grade"]], expected)
    expect_identical(result[["id"]], df[["id"]])
  }
})

test_that("empty and entirely missing factors keep valid levels", {
  empty <- factor(character())
  expect_identical(fct_cat(empty, reverse = TRUE), empty)
  expect_identical(fct_cat(empty, new_labels = character()), empty)
  x <- factor(rep(NA_character_, 3), levels = letters[1:3])
  expect_identical(fct_cat(x, AB = 1:2), factor(rep(NA_character_, 3)))
  expect_identical(levels(fct_cat(x, reverse = TRUE)), rev(levels(x)))
})

test_that("changed levels discard matrix contrasts but retain other metadata", {
  x <- factor(rep(letters[1:3], 2))
  contrasts(x) <- contr.sum(3)
  attr(x, "label") <- "Grade"
  original <- x
  results <- list(
    fct_cat(x, reverse = TRUE), fct_cat(x, "c"),
    fct_cat(x, AB = 1:2), fct_cat(x, binary_ref = 1L),
    fct_to_group(x, list(AB = 1:2)),
    fct_cat(x, new_labels = LETTERS[1:3]),
    fct_cat(x, new_labels = c("A", "A", "C")),
    fct_label(x, LETTERS[1:3])
  )
  for (result in results) {
    expect_null(attr(result, "contrasts"))
    expect_identical(attr(result, "label"), "Grade")
  }
  grouped <- fct_cat(x, AB = 1:2)
  design <- model.matrix(~ grouped)
  expect_identical(ncol(design), 2L)
  expect_identical(qr(design)[["rank"]], 2L)
  expect_false(anyNA(coef(lm(seq_along(grouped) ~ grouped))))
  expect_identical(x, original)
  expect_identical(attr(fct_cat(x, "a"), "contrasts"), attr(x, "contrasts"))
  expect_identical(attr(fct_cat(x, a = "a"), "contrasts"), attr(x, "contrasts"))
  expect_identical(attr(fct_cat(x, new_labels = levels(x)), "contrasts"),
                   attr(x, "contrasts"))
})

test_that("named contrast functions remain usable after regrouping", {
  x <- factor(rep(letters[1:3], 2))
  contrasts(x) <- "contr.sum"
  result <- fct_cat(x, AB = 1:2)
  expect_identical(attr(result, "contrasts"), "contr.sum")
  expect_identical(dim(contrasts(result)), c(2L, 1L))
  expect_identical(ncol(model.matrix(~ result)), 2L)
})

test_that("changed levels also discard sparse contrast matrices", {
  skip_if_not_installed("Matrix")
  x <- factor(rep(letters[1:3], 2))
  contrasts(x) <- contr.treatment(3, sparse = TRUE)
  result <- fct_cat(x, AB = 1:2)
  expect_null(attr(result, "contrasts"))
  expect_identical(ncol(model.matrix(~ result)), 2L)
})

test_that("replacement labels cannot invoke list-based grouping", {
  x <- factor(c("a", "b"))
  data <- data.frame(grade = x, id = 1:2)
  original <- data
  for (labels in list(list("A", "B"),
                      list(A = c("a", "b"), B = character()),
                      data.frame(label = c("A", "B")),
                      expression(A, B))) {
    expect_error(fct_cat(x, new_labels = labels), "atomic vector")
    expect_error(fct_label(x, labels), "atomic vector")
    expect_error(fct_label(data, grade, labels), "atomic vector")
  }
  expect_identical(fct_cat(x, new_labels = 1:2), factor(c("1", "2")))
  expect_identical(data, original)
})

test_that("many recode groups validate all old levels together", {
  old <- sprintf("L%03d", 1:200)
  labels <- sprintf("G%02d", 1:40)
  x <- factor(c(old, NA), levels = old)
  recode <- split(old, rep(labels, each = 5))
  expected <- factor(c(rep(labels, each = 5), NA), levels = labels)
  expect_identical(do.call(fct_cat, c(list(x), recode)), expected)
  indices <- split(seq_along(old), rep(labels, each = 5))
  expect_identical(fct_cat(x, groups = indices), expected)
  recode[[40]] <- c(recode[[40]], "unknown")
  expect_error(do.call(fct_cat, c(list(x), recode)), "not found.*unknown")
  expect_error(fct_cat(x, missing = NA_character_), "not found")
})

test_that("unchanged ordering preserves complete factor attributes", {
  x <- ordered(c("a", NA, "b", "a"),
               levels = c("a", "b", NA), exclude = NULL)
  is.na(x) <- c(FALSE, FALSE, FALSE, TRUE)
  names(x) <- paste0("r", seq_along(x))
  attr(x, "label") <- "Grade"
  contrasts(x) <- contr.sum(3)
  original <- x
  expect_identical(fct_cat(x, 1L), original)
  expect_identical(fct_cat(x, seq_len(nlevels(x))), original)
  expect_identical(fct_cat(x, levels(x)), original)
  expect_identical(x, original)

  single <- ordered(c("a", NA))
  attr(single, "label") <- "Single level"
  expect_identical(fct_cat(single, reverse = TRUE), single)
  empty <- factor(character())
  expect_identical(fct_cat(empty, integer()), empty)
  expect_identical(fct_cat(empty, reverse = TRUE), empty)
})

test_that("integer64 indices use their values in every factor mode", {
  skip_if_not_installed("bit64")
  x <- factor(c("a", "b", "c", NA))
  idx <- bit64::as.integer64(c(3L, 1L))
  expected <- factor(c("CA", "b", "CA", NA), levels = c("CA", "b"))
  expect_identical(fct_cat(x, CA = idx), expected)
  expect_identical(fct_cat(x, groups = list(CA = idx)), expected)
  expect_identical(fct_to_group(x, list(CA = idx)), expected)
  expect_identical(fct_cat(x, idx),
                   factor(c("a", "b", "c", NA), levels = c("c", "a", "b")))
  expect_identical(fct_cat(x, binary_ref = idx),
                   factor(c("c_a", "Oth", "c_a", NA), levels = c("c_a", "Oth")))
  too_large <- bit64::as.integer64("9007199254740993")
  expect_no_warning(expect_error(fct_cat(x, binary_ref = too_large), "between"))
  expect_identical(as.character(x), c("a", "b", "c", NA_character_))
})

test_that("reorder vector names do not change levels or contrasts", {
  x <- factor(rep(letters[1:3], each = 2))
  contrasts(x) <- contr.sum(3)
  names(x) <- paste0("r", seq_along(x))
  original <- x
  result <- fct_cat(x, c(first = "a"))
  expect_identical(result, original)
  expect_identical(model.matrix(~ grade, data.frame(grade = result)),
                   model.matrix(~ grade, data.frame(grade = original)))
  expect_identical(fct_cat(x, c(first = "c", second = "b")),
                   fct_cat(x, "c", "b"))
  expect_identical(x, original)
})

test_that("converted replacement labels are checked before updating levels", {
  methods <- get(".__S3MethodsTable__.", envir = asNamespace("base"))
  rlang::local_bindings(as.character.fct_cat_labels = function(x, ...) {
    attr(x, "converted")
  }, .env = methods)
  x <- factor(c("a", "b"))
  labels <- structure(c("A", "B"), class = "fct_cat_labels",
                      converted = c("X", "X"))
  expected <- factor(c("X", "X"))
  expect_identical(fct_cat(x, new_labels = labels), expected)
  expect_identical(fct_label(x, labels), expected)
  data <- data.frame(grade = x)
  expect_identical(fct_label(data, grade, labels)[["grade"]], expected)
  attr(labels, "converted") <- c("X", NA_character_)
  expect_identical(fct_cat(x, new_labels = labels), factor(c("X", NA)))
  attr(labels, "converted") <- "X"
  expect_error(fct_cat(x, new_labels = labels), "After conversion.*length")
  expect_error(fct_label(data, grade, labels), "After conversion.*length")
  expect_identical(data[["grade"]], x)
})

test_that("binary conversion requires at least one reference index", {
  x <- factor(c("a", "b", NA))
  expect_error(fct_cat(x, binary_ref = integer()), "at least one")
  expect_error(fct_cat(x, binary_ref = numeric()), "at least one")
  expect_error(fct_cat(factor(character()), binary_ref = integer()), "at least one")
  expect_identical(fct_cat(x, binary_ref = 1:2), factor(c("a_b", "a_b", NA)))
})

test_that("grouping wrappers use core validation without max warnings", {
  x <- factor(c("a", "b", NA), levels = letters[1:3])
  expect_no_warning(expect_identical(fct_to_group(x, list(A = integer())),
                                      factor(c("a", "b", NA))))
  for (idx in list(NA_integer_, Inf, 1.5, 1 + 1i)) {
    expect_no_warning(expect_error(fct_to_group(x, list(A = idx)), "finite integer"))
  }
  expect_no_warning(expect_error(fct_to_group(x, list(A = 4L)), "between"))
  expect_identical(fct_to_group(x, list(2L, 1L)),
                   factor(c("g1", "g2", NA), levels = c("g2", "g1")))
})

test_that("reordering cannot mix labels and positions", {
  x <- factor(c("b", "1", "2"), levels = c("b", "1", "2"))
  expect_error(fct_cat(x, 1L, "b"), "cannot mix")
  expect_error(fct_cat(x, "b", 1L), "cannot mix")
  expect_identical(fct_cat(x, "1", "2"),
                   factor(c("b", "1", "2"), levels = c("1", "2", "b")))
})

test_that("reordering normalizes each numeric argument before combining", {
  skip_if_not_installed("bit64")
  x <- factor(letters[1:3])
  expect_identical(fct_cat(x, 1L, bit64::as.integer64(3L)),
                   factor(letters[1:3], levels = c("a", "c", "b")))
})
