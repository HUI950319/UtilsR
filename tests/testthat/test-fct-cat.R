test_that("factor dot selectors never flatten dimensional level arrays", {
  x <- factor(letters[1:3])
  expect_error(fct_cat(x, matrix(c("c", "a"))), "dimensions")
  expect_error(fct_cat(x, AB = matrix(c("a", "b"))), "dimensions")
  expect_identical(levels(fct_cat(x, c("c", "a"))), c("c", "a", "b"))
  expect_identical(as.character(fct_cat(x, AB = c("a", "b"))), c("AB", "AB", "c"))
})

test_that("factor modes reject dimensional switches references and labels", {
  x <- factor(c("a", "b", "c"))
  for (flag in c(TRUE, FALSE)) expect_error(fct_cat(x, reverse = matrix(flag)), "reverse")
  for (reference in list(matrix(0), matrix("a")))
    expect_error(fct_cat(x, ref_idx = reference), "ref_idx")
  expect_error(fct_cat(x, new_labels = matrix(LETTERS[1:3])), "new_labels")
  expect_identical(fct_cat(x, ref_idx = 0), x)
  expect_identical(levels(fct_cat(x, reverse = TRUE)), c("c", "b", "a"))
})

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
  expect_error(fct_cat(x, ref_idx = 1L), "conflicts with.*Oth")
  expect_identical(fct_cat(x, ref_idx = 2L),
                   factor(c("Oth", "a"), levels = c("a", "Oth")))
  expect_identical(fct_cat(factor("Oth"), ref_idx = 1L), factor("Oth"))
})

test_that("dots cannot be silently ignored by another factor mode", {
  x <- factor(letters[1:3])
  expect_error(fct_cat(x, A = "a", reverse = TRUE), "Only one mode")
  expect_error(fct_cat(x, "b", ref_idx = 1L), "Only one mode")
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
    expect_no_warning(expect_error(fct_cat(x, ref_idx = idx), "finite integer"))
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
    binary = fct_cat(x, ref_idx = 1L),
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

test_that("rowwise relabelling rebuilds grouping keys", {
  data <- dplyr::rowwise(tibble::tibble(g = factor(c("a", "a", "b")), value = 1:3), g)
  original <- data
  result <- fct_label(data, g, c("A", "B"))
  expect_s3_class(result, "rowwise_df")
  expect_identical(dplyr::group_vars(result), "g")
  expect_identical(as.character(dplyr::group_keys(result)$g), c("A", "A", "B"))
  summary <- dplyr::summarise(result, total = sum(value), .groups = "drop")
  expect_identical(as.character(summary$g), c("A", "A", "B"))
  expect_identical(summary$total, 1:3)
  expect_identical(data, original)
})

test_that("fct_label rejects selectors that are not single column names", {
  data <- data.frame(first = factor(c("a", "b")),
                     grade = factor(c("a", "b")))
  original <- data
  for (selector in list(NULL, character(), NA_character_, "",
                        c("first", "grade"), c(grade = "grade", first = "first"),
                        2, TRUE, factor("grade"), list("grade"),
                        matrix("grade"), array("grade", c(1, 1, 1)))) {
    expect_error(fct_label(data, identity(selector), c("A", "B")),
                 "var.*single.*string", class = "rlang_error")
    expect_identical(data, original)
  }
  expect_error(fct_label(data, labels = c("A", "B")),
               "var.*single.*string", class = "rlang_error")
})

test_that("fct_label cannot use typed selectors as positional indices", {
  data <- data.frame(first = factor(c("a", "b")),
                     second = factor(c("a", "b")))
  for (case in list(list(names = c("2", "other"), selector = 2),
                    list(names = c("other", "TRUE"), selector = TRUE),
                    list(names = c("other", "grade"), selector = factor("grade")))) {
    names(data) <- case[["names"]]
    original <- data
    expect_error(fct_label(data, case[["selector"]], c("A", "B")),
                 "var.*single.*string", class = "rlang_error")
    expect_identical(data, original)
  }
})

test_that("fct_label rejects ambiguous duplicated column names", {
  data <- data.frame(first = factor(c("a", "b")),
                     second = factor(c("a", "b")))
  names(data) <- c("grade", "grade")
  original <- data
  expect_error(fct_label(data, grade, stop("labels must not be evaluated")),
               "grade.*more than once", class = "rlang_error")
  expect_error(fct_label(data, "grade", c("A", "B")),
               "grade.*more than once", class = "rlang_error")
  expect_identical(data, original)
})

test_that("fct_label keeps bare names separate from caller expressions", {
  data <- data.frame(first = factor(c("a", "b")),
                     grade = factor(c("a", "b")))
  expected <- data
  levels(expected[["grade"]]) <- c("A", "B")
  grade <- "first"
  selected <- "grade"
  expect_identical(fct_label(data, grade, c("A", "B")), expected)
  expect_identical(fct_label(data, "grade", c("A", "B")), expected)
  expect_identical(fct_label(data, identity(selected), c("A", "B")), expected)
  expect_identical(fct_label(data, !!selected, c("A", "B")), expected)
  column <- rlang::quo(grade)
  expect_identical(fct_label(data, !!column, c("A", "B")), expected)
  expect_identical(fct_label(data, setNames("grade", "ignored"), c("A", "B")),
                   expected)
  expect_error(fct_label(data, selected, stop("labels must not be evaluated")),
               "selected.*not found", class = "rlang_error")
  expect_error(fct_label(data, "gra", stop("labels must not be evaluated")),
               "gra.*not found", class = "rlang_error")
})

test_that("fct_label evaluates a selector expression only once", {
  data <- data.frame(grade = factor(c("a", "b")))
  calls <- 0L
  select_column <- function() {
    calls <<- calls + 1L
    "grade"
  }
  result <- fct_label(data, select_column(), c("A", "B"))
  expect_identical(calls, 1L)
  expect_identical(as.character(result[["grade"]]), c("A", "B"))
})

test_that("fct_label accepts exact nonstandard column names", {
  data <- data.frame(first = factor(c("a", "b")),
                     second = factor(c("a", "b")))
  for (name in c("2", "TRUE", "NA", "clinical grade", " grade ", " ",
                 "\u7b49\u7ea7")) {
    names(data) <- c("other", name)
    expected <- data
    levels(expected[[name]]) <- c("A", "B")
    expect_identical(fct_label(data, identity(name), c("A", "B")), expected)
    expect_identical(fct_label(data, !!rlang::sym(name), c("A", "B")), expected)
  }
  data <- data.frame(grade = factor(c("a", "b")), first = 1:2, second = 3:4)
  names(data) <- c("grade", "other", "other")
  expected <- data
  levels(expected[["grade"]]) <- c("A", "B")
  expect_identical(fct_label(data, grade, c("A", "B")), expected)
})

test_that("fct_label preserves frame classes and grouping metadata", {
  data <- tibble::tibble(grade = ordered(c("a", "b", "a")), value = 1:3)
  attr(data[["grade"]], "label") <- "Grade"
  expected <- data
  levels(expected[["grade"]]) <- c("A", "B")
  constructors <- list(as.data.frame, identity,
                       function(x) dplyr::group_by(x, grade, .drop = FALSE),
                       function(x) dplyr::rowwise(x, grade))
  for (construct in constructors) {
    frame <- construct(data)
    original <- frame
    result <- fct_label(frame, grade, c("A", "B"))
    expect_identical(result, construct(expected))
    expect_identical(fct_label(frame, "grade", c("A", "B")), result)
    expect_error(fct_label(frame, c("grade", "value"),
                           stop("labels must not be evaluated")),
                 "var.*single.*string", class = "rlang_error")
    expect_identical(frame, original)
  }
})

test_that("fct_label preserves empty and missing columns after selection", {
  for (values in list(factor(character()),
                      factor(character(), levels = c("a", "b")),
                      factor(rep(NA_character_, 3)),
                      factor(rep(NA_character_, 3), levels = c("a", "b")),
                      factor(c("a", NA), levels = c("a", NA), exclude = NULL))) {
    data <- data.frame(grade = values, id = seq_along(values))
    labels <- LETTERS[seq_len(nlevels(values))]
    expected <- data
    levels(expected[["grade"]]) <- labels
    expect_identical(fct_label(data, grade, labels), expected)
    expect_identical(fct_label(data, "grade", labels), expected)
  }
  expect_error(fct_label(data.frame(), "grade", c("A", "B")),
               "grade.*not found", class = "rlang_error")
})

test_that("fct_label does not mutate a data.table through selection", {
  skip_if_not_installed("data.table")
  data <- data.table::data.table(first = factor(c("a", "b")),
                                  grade = factor(c("a", "b")))
  original <- data.table::copy(data)
  expect_error(fct_label(data, factor("grade"),
                         stop("labels must not be evaluated")),
               "var.*single.*string", class = "rlang_error")
  result <- fct_label(data, grade, c("A", "B"))
  expect_identical(as.character(result[["grade"]]), c("A", "B"))
  expect_identical(result[["first"]], original[["first"]])
  expect_identical(class(result), class(data))
  expect_identical(data, original)
})

test_that("fct_label refreshes affected data.table keys and indices", {
  skip_if_not_installed("data.table")
  data <- data.table::data.table(grade = factor(letters[1:4]), value = 1:4)
  data.table::setkeyv(data, "grade")
  data.table::setindexv(data, c("grade", "value"))
  data.table::setindexv(data, "value")
  original <- data.table::copy(data)
  result <- fct_label(data, grade, c("A", "B", "A", "B"))
  expect_null(data.table::key(result))
  expect_identical(data.table::indices(result), "value")
  expect_identical(as.character(result[["grade"]]), c("A", "B", "A", "B"))
  expect_identical(data, original)
})

test_that("fct_to_group only evaluates naming controls for unnamed groups", {
  x <- factor(letters[1:3])
  expect_identical(fct_to_group(x, list(AB = 1:2, C = 3),
                                name_prefix = stop("prefix evaluated"),
                                name_sep = stop("separator evaluated")),
                   factor(c("AB", "AB", "C")))
  for (arg in c("name_prefix", "name_sep")) {
    for (bad in list(NULL, NA_character_, c("a", "b"), matrix("g"), 1)) {
      args <- list(x = x, g_lis = list(1:2))
      args[arg] <- list(bad)
      expect_error(do.call(fct_to_group, args), arg)
    }
  }
  result <- fct_to_group(x, list(AB = 1:2, 3), name_prefix = "G", name_sep = "+")
  expect_identical(as.character(result), c("AB", "AB", "G3"))
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
    fct_cat(x, AB = 1:2), fct_cat(x, ref_idx = 1L),
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
  expect_identical(fct_cat(x, ref_idx = idx),
                   factor(c("c_a", "Oth", "c_a", NA), levels = c("c_a", "Oth")))
  too_large <- bit64::as.integer64("9007199254740993")
  expect_no_warning(expect_error(fct_cat(x, ref_idx = too_large), "between"))
  expect_identical(as.character(x), c("a", "b", "c", NA_character_))
})

test_that("serialized integer64 factor arguments work in fresh R processes", {
  skip_if_not_installed("bit64")
  functions <- c("fct_cat", "fct_to_group", "fct_num", ".as_factor",
                 ".check_integer_index", ".recode_factor", ".do_binary",
                 ".relevel_factor", ".factor_attributes", ".register_integer64",
                 ".fct_num_cut", ".make_default_bin_labels", ".make_break_labels")
  ns <- environment(fct_cat)
  isolated <- new.env(parent = baseenv())
  for (name in functions[vapply(functions, exists, logical(1L), envir = ns)]) {
    fn <- get(name, envir = ns)
    environment(fn) <- isolated
    assign(name, fn, envir = isolated)
  }
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  saveRDS(list(functions = as.list(isolated), libs = .libPaths(),
               scalar = bit64::as.integer64(3), vector = bit64::as.integer64(c(3, 1)),
               labels = bit64::as.integer64(c(3, 1, 2))), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)",
    "fixture <- readRDS(args[[1]])",
    ".libPaths(fixture[['libs']])",
    "stopifnot(!'bit64' %in% loadedNamespaces())",
    "list2env(fixture[['functions']], .GlobalEnv)",
    "x <- factor(c('a', 'b', 'c', NA))",
    "result <- switch(args[[2]],",
    " ref = fct_cat(x, ref_idx = fixture[['scalar']]),",
    " reorder = fct_cat(x, fixture[['vector']]),",
    " named = fct_to_group(x, list(A = fixture[['vector']])),",
    " auto = fct_to_group(x, list(fixture[['vector']])),",
    " factor = fct_cat(fixture[['labels']], reverse = TRUE),",
    " labels = fct_cat(x, new_labels = fixture[['labels']]),",
    " quantile = fct_num(1:12, nbins = fixture[['scalar']]),",
    " equal = fct_num(1:12, nbins = fixture[['scalar']], type = 'equal'))",
    "saveRDS(result, args[[3]])"
  ), script)
  x <- factor(c("a", "b", "c", NA))
  expected <- list(ref = fct_cat(x, ref_idx = 3L), reorder = fct_cat(x, c(3L, 1L)),
                    named = fct_to_group(x, list(A = c(3L, 1L))),
                    auto = fct_to_group(x, list(c(3L, 1L))),
                    factor = factor(c("3", "1", "2"), levels = c("3", "2", "1")),
                    labels = fct_cat(x, new_labels = c("3", "1", "2")),
                    quantile = fct_num(1:12, nbins = 3),
                    equal = fct_num(1:12, nbins = 3, type = "equal"))
  for (mode in names(expected)) {
    status <- system2(file.path(R.home("bin"), "Rscript"),
                       c("--vanilla", shQuote(script), shQuote(fixture), mode, shQuote(output)),
                       stdout = TRUE, stderr = TRUE)
    expect_null(attr(status, "status"), info = paste(mode, paste(status, collapse = "\n")))
    if (is.null(attr(status, "status"))) expect_identical(readRDS(output), expected[[mode]])
  }
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
  expect_error(fct_cat(x, ref_idx = integer()), "at least one")
  expect_error(fct_cat(x, ref_idx = numeric()), "at least one")
  expect_error(fct_cat(factor(character()), ref_idx = integer()), "at least one")
  expect_identical(fct_cat(x, ref_idx = 1:2), factor(c("a_b", "a_b", NA)))
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

test_that("changed level mappings discard obsolete reorder scores", {
  x <- stats::reorder(factor(rep(letters[1:3], each = 2)), 1:6)
  attr(x, "label") <- "Grade"
  original <- x
  results <- list(fct_cat(x, reverse = TRUE), fct_cat(x, "c"),
                  fct_cat(x, AB = 1:2), fct_cat(x, ref_idx = 1L),
                  fct_to_group(x, list(AB = 1:2)),
                  fct_label(x, LETTERS[1:3]),
                  fct_cat(x, a = "b", b = "a"))
  for (result in results) {
    expect_null(attr(result, "scores"))
    expect_identical(attr(result, "label"), "Grade")
  }
  expect_identical(fct_cat(x, "a"), original)
  expect_identical(fct_cat(x, a = "a"), original)
  expect_identical(fct_cat(x, new_labels = levels(x)), original)
  expect_identical(x, original)
})

test_that("unchanged replacement labels retain base missing-label semantics", {
  x <- factor(c("a", NA), levels = c("a", NA), exclude = NULL)
  expected <- x
  levels(expected) <- levels(x)
  expect_identical(fct_cat(x, new_labels = levels(x)), expected)
  expect_identical(levels(x), c("a", NA_character_))
  empty <- factor(character())
  attr(empty, "label") <- "Empty"
  expect_identical(fct_cat(empty, new_labels = character()), empty)
})


test_that("ref_idx also takes the reference levels by name", {
  x <- factor(c("Yes", "No", "No", "Unknown", "Yes"),
              levels = c("Yes", "No", "Unknown"))
  expect_identical(fct_cat(x, ref_idx = "No"), fct_cat(x, ref_idx = 2L))
  expect_identical(fct_cat(x, ref_idx = c("Unknown", "Yes")),
                   fct_cat(x, ref_idx = c(3L, 1L)))
  expect_identical(levels(fct_cat(x, ref_idx = "No")), c("No", "Oth"))
  # A character vector is coerced to a factor first, as for indices.
  expect_identical(fct_cat(c("b", "a", "c"), ref_idx = "c"),
                   fct_cat(c("b", "a", "c"), ref_idx = 3L))
  expect_error(fct_cat(x, ref_idx = c("No", "Maybe")),
               "ref_idx.*not found.*Maybe")
  expect_error(fct_cat(x, ref_idx = NA_character_), "not found")
  expect_error(fct_cat(x, ref_idx = character()), "at least one")
})


test_that("binary_ref, the former name of ref_idx, still works with a warning", {
  x <- factor(c("a", "b", "c", "b"))
  expect_warning(old <- fct_cat(x, binary_ref = 2L),
                 "binary_ref.*deprecated.*ref_idx")
  expect_identical(old, fct_cat(x, ref_idx = 2L))
  expect_warning(expect_identical(fct_cat(x, binary_ref = "c"),
                                  fct_cat(x, ref_idx = 3L)), "deprecated")
  expect_error(fct_cat(x, ref_idx = 1L, binary_ref = 1L),
               "ref_idx.*only.*binary_ref")
  expect_identical(names(formals(fct_cat)),
                   c("x", "...", "reverse", "ref_idx", "groups",
                     "new_labels", "binary_ref"))
})


test_that("ref_idx = 0 is the same as NULL: nothing collapses", {
  x <- factor(c("a", "b", "c", "b"))
  expect_identical(fct_cat(x, ref_idx = 0), x)
  expect_identical(fct_cat(x, ref_idx = 0L), x)
  expect_identical(fct_cat(c("b", "a"), ref_idx = 0), factor(c("b", "a")))
  # It is not an active mode, so another mode still runs.
  expect_identical(fct_cat(x, "c", ref_idx = 0), fct_cat(x, "c"))
  expect_identical(fct_cat(x, reverse = TRUE, ref_idx = 0),
                   fct_cat(x, reverse = TRUE))
  # Only a single 0 means "none"; a 0 among indices is still out of range.
  expect_error(fct_cat(x, ref_idx = c(0, 1)), "between 1 and 3")
  expect_warning(expect_identical(fct_cat(x, binary_ref = 0), x), "deprecated")
})

test_that("group wrappers reject dimensional list containers", {
  x <- factor(c("a", "b", "c"))
  groups <- structure(list(1:2, 3L), dim = c(2L, 1L))
  expect_error(fct_to_group(x, groups), "g_lis.*list")
  expect_identical(levels(fct_to_group(x, list(1:2, 3L))), c("g1/2", "g3"))
})

test_that("plain integer selectors avoid redundant numeric conversion scans", {
  fn <- .check_integer_index
  e <- new.env(parent = environment(fn))
  examined <- 0L
  e$is.finite <- function(x) {
    examined <<- examined + length(x)
    base::is.finite(x)
  }
  e$trunc <- function(x) {
    examined <<- examined + length(x)
    base::trunc(x)
  }
  environment(fn) <- e
  x <- seq_len(100000)
  expect_identical(fn(x, "indices", length(x)), x)
  expect_identical(examined, 0L)
  expect_error(fn(c(1L, NA_integer_), "indices", 2), "finite integer")
  expect_error(fn(c(0L, 2L), "indices", 2), "between 1")
  expect_error(fn(c(1, 1.5), "indices", 2), "finite integer")
})

test_that("factor helpers preserve close numeric identities and numeric ordering", {
  x <- c(high = 10, near = 1 + .Machine$double.eps, low = 1, missing = NA_real_)
  actual <- fct_cat(x)
  expect_identical(as.integer(actual), c(3L, 2L, 1L, NA_integer_))
  expect_identical(as.numeric(levels(actual)), sort(unname(x), na.last = NA))
  expect_identical(names(actual), names(x))
  expect_identical(as.character(fct_to_group(x, list(small = 1:2))),
    c("10", "small", "small", NA_character_))
  ordinary <- c(y = 12.5, x = 2.5, z = NA_real_)
  expect_identical(fct_cat(ordinary), factor(ordinary))
})

test_that("factor grouping recodes each checked index once", {
  check <- .check_integer_index
  checks <- 0L
  testthat::local_mocked_bindings(.check_integer_index = function(...) {
    checks <<- checks + 1L
    check(...)
  }, .package = "UtilsR")
  values <- ordered(letters[1:4], levels = letters[1:5])
  groups <- list(early = c(1L, 3L), late = 2L)
  direct <- fct_cat(values, groups = groups)
  expect_identical(checks, 2L)
  checks <- 0L
  wrapped <- fct_to_group(values, groups)
  expect_identical(checks, 2L)
  expect_identical(direct, wrapped)
  expect_identical(as.character(direct), c("early", "late", "early", "d"))
  expect_true(is.ordered(direct))
})

test_that("factor grouping rejects shaped lists before inspecting values", {
  shaped <- structure(list(early = 1L, late = 2L), dim = c(1L, 2L))
  for (bad in list(shaped, data.frame(early = 1L, late = 2L))) {
    expect_error(fct_cat(stop("input inspected"), groups = bad), "groups.*named list")
  }
  expect_identical(as.character(fct_cat(factor(c("a", "b")), groups = list(first = 1L))),
                   c("first", "b"))
})

test_that("factor relabelling checks column names once", {
  d <- as.data.frame(setNames(rep(list(1:3), 128L), paste0("column", seq_len(128L))))
  d$grade <- factor(c("a", "b", "a"))
  fn <- fct_label.data.frame
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(x, table) {
    if (identical(table, names(d))) stop("searched column names twice")
    base::`%in%`(x, table)
  }
  environment(fn) <- env
  result <- fn(d, grade, c("A", "B"))
  expect_identical(levels(result$grade), c("A", "B"))
  expect_identical(result[names(d)[1:128]], d[names(d)[1:128]])
})

test_that("factor recoding compacts observed levels through their target positions", {
  x <- structure(c(3L, 1L, 4L, NA_integer_, 3L), names = letters[1:5],
    levels = c("a", "unused", "b", NA_character_, "other"),
    class = c("ordered", "factor"))
  changes <- list(b = "a", dropped = "unused")
  expected <- .recode_factor(x, changes)
  fn <- .recode_factor
  env <- new.env(parent = environment(fn))
  env[["%in%"]] <- function(...) stop("matched displayed labels again")
  environment(fn) <- env
  expect_identical(fn(x, changes), expected)
  expect_identical(levels(expected), c("b", NA_character_))
})

test_that("factor conversion retains calendar period components", {
  skip_if_not_installed("lubridate")
  p <- lubridate::period(months = c(3L, 1L, 2L, NA_integer_, 3L))
  expected <- factor(as.character(p))
  expect_identical(fct_cat(p), expected)
  expect_identical(fct_cat(p, reverse = TRUE), fct_cat(expected, reverse = TRUE))
})

test_that("time factor conversion preserves distinct instants with the same labels", {
  dates <- stats::setNames(as.Date(c(.75, .25, 1.25, NA), origin = "1970-01-01"), letters[1:4])
  timestamps <- as.POSIXct("2026-11-01 05:30:00", tz = "UTC") + c(3600, 0, 7200, NA)
  attr(timestamps, "tzone") <- "America/New_York"
  names(timestamps) <- names(dates)
  for (x in list(dates, timestamps, as.POSIXlt(timestamps))) {
    out <- .as_factor(x)
    expect_identical(as.integer(out), c(2L, 1L, 3L, NA_integer_))
    expect_identical(names(out), names(x))
  }
  ordinary <- as.Date(c("2020-01-03", "2020-01-01", NA))
  expect_identical(.as_factor(ordinary), factor(ordinary))
})
