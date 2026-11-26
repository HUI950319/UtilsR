test_that("numeric binning rejects unsupported integer64 storage", {
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(c(1, 5, 9, NA))
  expect_error(fct_num(x, breaks = 5), "x.*integer64")
  expect_error(fct_num(x, nbins = 3), "x.*integer64")
  expect_error(fct_num(c(1, 5, 9), breaks = bit64::as.integer64(5)),
               "breaks.*integer64")
  for (type in c("quantile", "equal")) {
    expect_identical(fct_num(1:12, nbins = bit64::as.integer64(3), type = type),
                     fct_num(1:12, nbins = 3, type = type))
  }
})

test_that("numeric binning rejects SPSS user-missing storage", {
  x <- structure(c(1, 2, 99, NA_real_),
                 class = c("haven_labelled_spss", "haven_labelled", "vctrs_vctr", "double"),
                 na_values = 99)
  expect_error(fct_num(x, breaks = 2), "zap_missing")
  expect_error(fct_num(x, nbins = 2), "zap_missing")
  expect_error(fct_num(x, nbins = 2, type = "equal"), "zap_missing")
  expect_error(fct_num(1:4, breaks = x[1]), "breaks.*haven_labelled_spss")
})

test_that("numeric binning rejects time-span classes before using numeric storage", {
  for (cls in c("Duration", "Period", "Interval")) {
    x <- structure(c(60, 120, 180), class = cls)
    expect_error(fct_num(x, breaks = 120), "x.*time-span")
    expect_error(fct_num(x, nbins = 2), "x.*time-span")
    expect_error(fct_num(x, nbins = 2, type = "equal"), "x.*time-span")
    expect_error(fct_num(c(60, 120, 180), breaks = structure(120, class = cls)),
                 "breaks.*time-span")
  }
})

test_that("numeric binning rejects dimensional data instead of flattening it", {
  for (x in list(matrix(1:4, nrow = 2), array(1:8, dim = c(2, 2, 2)),
                 array(1:4, dim = 4))) {
    expect_error(fct_num(x, breaks = 2), "x.*vector.*dimension")
    expect_error(fct_num(x, nbins = 2), "x.*vector.*dimension")
    expect_error(fct_num(x, nbins = 2, type = "equal"), "x.*vector.*dimension")
  }
})

test_that("bin counts reject time-span classes before integer conversion", {
  for (cls in c("Duration", "Period", "Interval")) {
    for (type in c("quantile", "equal")) {
      expect_error(fct_num(1:12, nbins = structure(3, class = cls), type = type),
                   "nbins.*time-span")
    }
  }
})

test_that("numeric binning retains right-closed boundaries and missing values", {
  x <- c(-Inf, 49, 50, 51, Inf, NA, NaN)
  expect_identical(fct_num(x, breaks = 50),
                   factor(c("below_50", "below_50", "below_50",
                            "above_50", "above_50", NA, NA),
                          levels = c("below_50", "above_50")))
  expect_identical(fct_num(c(44, 45, 54, 55, NA), breaks = c(44, 54),
                           labels = c("<45", "45-54", ">=55")),
                   factor(c("<45", "45-54", "45-54", ">=55", NA),
                          levels = c("<45", "45-54", ">=55")))
})

test_that("fixed cuts with an observed endpoint skip whole-input missing checks", {
  x <- c(-Inf, rep(c(NA_real_, 0, NaN, 2), length.out = 998L), Inf)
  fn <- fct_num
  env <- new.env(parent = environment(fn))
  reject_full_scan <- function(check) {
    force(check)
    function(values) {
      if (length(values) == length(x)) stop("scanned all observations for missing values")
      check(values)
    }
  }
  env$anyNA <- reject_full_scan(base::anyNA)
  env$is.na <- reject_full_scan(base::is.na)
  environment(fn) <- env

  for (values in list(x, replace(x, 1L, NA_real_), replace(x, length(x), NaN))) {
    expect_identical(fn(values, breaks = 0), fct_num(values, breaks = 0))
  }
})

test_that("fixed cut points must be finite distinct numeric values", {
  for (breaks in list(numeric(), NA_real_, c(NA_real_, 5), NaN, Inf, -Inf,
                     c(5, Inf), c(5, 5), c("2", "10"), TRUE, list(5),
                     1 + 1i, matrix(c(2, 5), nrow = 1))) {
    expect_no_warning(expect_error(fct_num(c(1, 5, 9), breaks = breaks),
                                   "breaks.*(numeric|finite|distinct|value)"))
  }
  expect_identical(fct_num(c(1, 5, 9), breaks = c(7, 3)),
                   factor(c("below_3", "3-7", "above_7"),
                          levels = c("below_3", "3-7", "above_7")))
})

test_that("automatic labels keep nearby cut points in separate groups", {
  for (breaks in list(1 + c(0, 1e-15, 2e-15, 3e-15),
                     -1 + c(0, 1e-15, 2e-15, 3e-15),
                     1e12 + c(0, 0.001, 0.002, 0.003))) {
    result <- fct_num(c(breaks, Inf, NA), breaks = breaks)
    expect_identical(as.integer(result), c(1:5, NA_integer_))
    expect_length(levels(result), 5L)
    expect_identical(anyDuplicated(levels(result)), 0L)
  }
  expect_identical(levels(fct_num(1:10, breaks = c(2.5, 7.5))),
                   c("below_2.5", "2.5-7.5", "above_7.5"))
})

test_that("many fixed cut points retain interval order and labels", {
  result <- fct_num(c(-Inf, 1, 500, 1000, Inf, NA), breaks = 1:1000)
  expect_identical(as.integer(result), c(1L, 1L, 500L, 1000L, 1001L, NA_integer_))
  expect_length(levels(result), 1001L)
  expect_identical(anyDuplicated(levels(result)), 0L)
  expect_identical(levels(result)[c(1, 2, 500, 1000, 1001)],
                   c("below_1", "1-2", "499-500", "999-1000", "above_1000"))
})

test_that("automatic bin counts are validated before integer conversion", {
  for (nbins in list(2.9, "3", factor("3", levels = c("2", "3")),
                    integer(), c(2, 3), NA_real_, NaN, Inf, -Inf, 1, 0, -2,
                    TRUE, list(3), 2 + 1i, matrix(3), .Machine$integer.max, 1e20)) {
    expect_no_warning(expect_error(fct_num(1:10, nbins = nbins),
                                   "nbins.*single finite integer"))
  }
  expect_identical(fct_num(1:6, nbins = 3),
                   factor(c("low", "low", "middle", "middle", "high", "high"),
                          levels = c("low", "middle", "high")))
  expect_identical(fct_num(1:6, nbins = 3), fct_num(1:6, nbins = 3L))
})

test_that("automatic binning reports constant data before constructing groups", {
  for (type in c("quantile", "equal")) {
    for (x in list(5, rep(5, 4), c(0, 0, NA, NaN), c(-3, NA, -3))) {
      expect_no_warning(expect_error(fct_num(x, nbins = 3, type = type),
                                     "constant.*x"))
    }
  }
  expect_identical(fct_num(rep(5, 3), breaks = 5),
                   factor(rep("below_5", 3), levels = c("below_5", "above_5")))
  expect_warning(result <- fct_num(c(1, 1, 1, 2), nbins = 4),
                 "reduced 4 bins to 2")
  expect_identical(result,
                   factor(c("low", "low", "low", "high"), levels = c("low", "high")))
})

test_that("equal-width binning diagnoses insufficient numeric precision", {
  for (x in list(c(1, 1 + .Machine$double.eps),
                 c(-1, -1 + .Machine$double.eps),
                 c(1e12, 1e12 + 0.0001220703125))) {
    expect_error(fct_num(x, nbins = 4, type = "equal"), "numeric precision")
    expect_error(fct_num(x, nbins = 4, type = "equal", labels = letters[1:4]),
                 "numeric precision")
    expect_identical(as.integer(fct_num(x, breaks = x[1])), 1:2)
  }
})

test_that("equal-width ranges retain endpoints and class-specific methods", {
  x <- c(-4, -2, 0, 2, 4, NA, NaN)
  expect_identical(as.integer(fct_num(x, nbins = 4, type = "equal")),
                   c(1L, 1L, 2L, 3L, 4L, NA_integer_, NA_integer_))
  methods <- get(".__S3MethodsTable__.", envir = asNamespace("base"))
  rlang::local_bindings(range.fct_num_test_range = function(..., na.rm = FALSE) {
    c(-10, 20)
  }, .env = methods)
  x <- structure(c(1, 5.25, 10, NA), class = "fct_num_test_range")
  expect_identical(as.integer(fct_num(x, nbins = 2, type = "equal")),
                   c(1L, 2L, 2L, NA_integer_))
  expect_identical(as.integer(fct_num(as.numeric(x), nbins = 2, type = "equal")),
                   c(1L, 1L, 2L, NA_integer_))
})

test_that("numeric binning retains missing-data and classed-vector behavior", {
  for (x in list(numeric(), NA_real_, c(NA_real_, NaN))) {
    expect_error(fct_num(x, breaks = 2), "all NA")
    expect_error(fct_num(x, nbins = 2), "all NA")
  }
  expected <- factor(c("low", "low", "middle", "middle", "high", "high", NA, NA),
                     levels = c("low", "middle", "high"))
  expect_identical(fct_num(c(1:6, NA, NaN), nbins = 3), expected)
  expect_identical(fct_num(I(1:6), nbins = 3), fct_num(1:6, nbins = 3))
  expect_identical(fct_num(I(1:6), nbins = 3, type = "equal"),
                   fct_num(1:6, nbins = 3, type = "equal"))
})

test_that("logical labels cannot switch numeric binning to integer codes", {
  expect_error(fct_num(c(1, 1, 1, 2), nbins = 2, labels = FALSE), "labels.*logical")
  for (labels in list(FALSE, TRUE, NA, logical(), c(TRUE, FALSE))) {
    expect_error(fct_num(1:4, breaks = 2, labels = labels), "labels.*logical")
    expect_error(fct_num(1:4, nbins = 2, labels = labels), "labels.*logical")
    expect_error(fct_num(1:4, nbins = 2, type = "equal", labels = labels),
                 "labels.*logical")
  }
})

test_that("numeric binning preserves custom labels and unused groups", {
  x <- c(-Inf, 0, 1, 2, Inf, NA, NaN)
  for (labels in list(c("A", "B", "C"), c("A", "A", "C"),
                     c("A", NA, "C"), setNames(c("A", "B", "C"), letters[1:3]),
                     factor(c("A", "B", "C")), c(10, 20, 30), list("A", "B", "C"))) {
    expect_identical(fct_num(x, breaks = c(0, 1), labels = labels),
                     cut(x, c(-Inf, 0, 1, Inf), labels = labels, include.lowest = TRUE))
  }
  expect_identical(fct_num(c(0, 10, NA), nbins = 4, type = "equal"),
                   factor(c("low", "very_high", NA),
                          levels = c("low", "medium", "high", "very_high")))
  expect_identical(fct_num(setNames(1:4, letters[1:4]), breaks = 2),
                   fct_num(1:4, breaks = 2))
})

test_that("numeric bins reject complex data and dimensional labels before cutting", {
  expect_error(fct_num(1:3 + 1i, breaks = stop("breaks evaluated")), "x.*numeric")
  expect_error(fct_num(1:3, breaks = 2, labels = matrix(c("L", "H"))), "labels")
  expect_identical(fct_num(1:3, breaks = 2, labels = c("L", "H")),
                   factor(c("L", "L", "H"), levels = c("L", "H")))
})

test_that("automatic numeric bins retain membership on subnormal coordinates", {
  unit <- .Machine$double.xmin * .Machine$double.eps
  for (n in c(4, 12, 20)) for (sign in c(-1, 1)) {
    x <- c(sign * seq_len(n), NA_real_)
    for (type in c("quantile", "equal")) {
      expected <- fct_num(x, nbins = 2, type = type)
      expect_identical(fct_num(x * unit, nbins = 2, type = type), expected)
    }
  }
  x <- c(1, 2, 2, 3, 4, NA_real_)
  expect_identical(fct_num(x * unit, nbins = 2, labels = c("L", "H")),
                   fct_num(x, nbins = 2, labels = c("L", "H")))
})

test_that("automatic bins retain subnormal spread above a normal offset", {
  tiny <- .Machine$double.xmin * .Machine$double.eps
  for (sign in c(-1, 1)) {
    x <- sign * (.Machine$double.xmin + (0:19) * tiny)
    for (type in c("equal", "quantile")) {
      actual <- fct_num(c(x, NA_real_), nbins = 4L, type = type)
      reference <- fct_num(c(sign * (0:19), NA_real_), nbins = 4L, type = type)
      expect_identical(actual, reference)
    }
  }
})

test_that("wrapped numeric values retain subnormal bin membership", {
  skip_if_not_installed("haven")
  u <- .Machine$double.xmin * .Machine$double.eps
  for (offset in c(0, .Machine$double.xmin)) {
    x <- c(offset, offset + u, NA_real_)
    for (values in list(I(x), haven::labelled(x, label = "Measure"))) {
      for (type in c("equal", "quantile")) {
        expect_no_warning(result <- fct_num(values, nbins = 2L, type = type))
        expect_identical(result, factor(c("low", "high", NA), levels = c("low", "high")))
      }
    }
  }
})

test_that("equal-width bins reuse the validated plain range", {
  fn <- fct_num
  env <- new.env(parent = environment(fn))
  calls <- c(min = 0L, max = 0L)
  observe <- function(name, extreme) function(x, ...) {
    if (length(x) == 500L) calls[[name]] <<- calls[[name]] + 1L
    extreme(x, ...)
  }
  env$min <- observe("min", base::min)
  env$max <- observe("max", base::max)
  environment(fn) <- env
  values <- seq(0, 5, length.out = 500)
  for (input in list(values, c(values[-1L], NA))) {
    expected <- fct_num(input, nbins = 5, type = "equal")
    calls[] <- 0L
    expect_identical(fn(input, nbins = 5, type = "equal"), expected)
    expect_identical(calls, c(min = 1L, max = 1L))
  }
})

test_that("ordered fixed cut points skip the extra sort", {
  breaks <- seq_len(2000L)
  input <- c(-Inf, 1, 1.5, 1999, 2000.5, Inf, NA_real_)
  expected <- fct_num(input, breaks)
  fn <- fct_num
  env <- new.env(parent = environment(fn))
  env$sort <- function(x, ...) {
    if (identical(x, breaks)) stop("sorted already ordered cut points")
    base::sort(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(input, breaks), expected)
  expect_identical(fn(input, rev(breaks)), expected)
  expect_error(fn(input, c(1L, 2L, 1L)), "distinct values")
})

test_that("complex observations fail before numeric bins are constructed", {
  for (x in list(1 + 2i, c(NA_complex_, 1 + 0i))) {
    expect_error(fct_num(x, breaks = stop("breaks evaluated")), "real numeric")
    expect_error(fct_num(x, nbins = 2), "real numeric")
  }
})

test_that("constant plain quantile inputs skip allocating probabilities", {
  fn <- fct_num
  env <- new.env(parent = environment(fn))
  env$seq <- function(...) stop("allocated quantile probabilities for constant values")
  environment(fn) <- env
  for (x in list(rep(6L, 3L), c(6, NA, 6), rep(0, 3L))) {
    expect_error(fn(x, nbins = 5000L), "Cannot split constant")
  }
  expect_identical(fn(c(1, NA, 6), breaks = 3), fct_num(c(1, NA, 6), breaks = 3))
})

test_that("ordered fixed numeric breaks do not require a duplicate index", {
  x <- c(-Inf, 1, 3, 10, Inf, NA)
  breaks <- as.double(seq_len(900L))
  labels <- paste0("bin", seq_len(length(breaks) + 1L))
  expected <- fct_num(x, breaks, labels)
  fn <- .fct_num_cut
  env <- new.env(parent = environment(fn))
  env$anyDuplicated <- function(x, ...) {
    if (is.numeric(x)) stop("searched sorted break values for duplicates")
    base::anyDuplicated(x, ...)
  }
  environment(fn) <- env
  expect_identical(fn(x, c(-Inf, breaks, Inf), labels), expected)
  expect_identical(fn(x, c(-Inf, NA, Inf), "all"),
                   base::cut(x, c(-Inf, NA, Inf), labels = "all", include.lowest = TRUE))
})

test_that("unbounded equal-width data receive a finite endpoint diagnostic", {
  for (x in list(c(-Inf, 1, 2), c(1, 2, Inf), c(-Inf, Inf))) {
    expect_error(fct_num(x, nbins = 4L, type = "equal"), "finite endpoints.*x|x.*finite endpoints")
    expect_identical(as.integer(fct_num(x, breaks = 0)), ifelse(x > 0, 2L, 1L))
  }
})

test_that("constant classed quantile inputs do not allocate probabilities", {
  skip_if_not_installed("haven")
  fn <- fct_num
  env <- new.env(parent = environment(fn))
  env$seq <- function(...) stop("allocated probabilities for a constant classed input")
  environment(fn) <- env
  for (input in list(I(c(NA, 2, 2)), haven::labelled(c(3, 3, NA), c(High = 3)),
                     I(rep(.Machine$double.xmin / 8, 3)))) {
    expect_error(fn(input, nbins = 10000L), "Cannot split constant")
  }
})

test_that("AsIs numeric cuts use bin codes without factor rematching", {
  values <- I(c(-1, 0, 1, 2, NA, Inf))
  expected <- fct_num(values, breaks = c(0, 1))
  fn <- .fct_num_cut
  env <- new.env(parent = environment(fn))
  env$cut <- function(...) stop("rematched AsIs cut codes through factor construction")
  environment(fn) <- env
  local_mocked_bindings(.fct_num_cut = fn)
  expect_identical(fct_num(values, breaks = c(0, 1)), expected)
})

test_that("opposite infinite quantiles explain their undefined cut points", {
  expect_error(fct_num(c(-Inf, Inf), nbins = 2L), "Quantile cut points.*undefined")
  expect_identical(as.integer(fct_num(c(-Inf, Inf), breaks = 0)), c(1L, 2L))
})

test_that("valid integer cut points need no second finiteness mask", {
  fn <- fct_num
  env <- new.env(parent = environment(fn))
  env$is.finite <- function(x) {
    if (identical(substitute(x), quote(breaks)) && is.integer(x))
      stop("checked finite integer cut points twice")
    base::is.finite(x)
  }
  environment(fn) <- env
  x <- c(-Inf, 1, 200, 400, Inf, NA)
  expect_identical(fn(x, breaks = 1:400), fct_num(x, breaks = 1:400))
  expect_error(fn(x, breaks = c(NA_integer_, 1L)), "finite")
  expect_error(fn(x, breaks = c(1, Inf)), "finite")
})

test_that("repeated interval labels reuse checked bin codes", {
  x <- setNames(c(-Inf, -1, 0, 1, 2, Inf, NA, NaN), letters[1:8])
  fn <- .fct_num_cut
  environment(fn) <- list2env(list(cut = function(...) stop("re-binned validated intervals")),
    parent = environment(fn))
  breaks <- c(-Inf, 0, 1, Inf)
  for (labels in list(c("A", "A", "B"), c(NA_character_, "B", "A"), c("", "a", ""))) {
    expect_identical(fn(x, breaks, labels), cut(x, breaks, labels, include.lowest = TRUE))
  }
})

test_that("fixed break labels assemble without assigning a full placeholder vector", {
  fn <- .make_break_labels
  env <- new.env(parent = environment(fn))
  env$character <- function(length = 0L) {
    if (length > 1L) stop("allocated placeholder interval labels")
    base::character(length)
  }
  environment(fn) <- env
  expect_identical(fn(c(-5, 2, 10)), c("below_-5", "-5-2", "2-10", "above_10"))
  expect_identical(fn(3), c("below_3", "above_3"))
  x <- 1 + c(0, .Machine$double.eps, 5 * .Machine$double.eps)
  expect_identical(fn(x), .make_break_labels(x))
})

test_that("plain numeric bin labels reuse bin codes and keep merged levels", {
  x <- c(-Inf, -3, -1, 0, 1, 3, Inf, NA)
  knots <- c(-Inf, -1, 0, 1, Inf)
  fn <- .fct_num_cut
  environment(fn) <- list2env(list(cut = function(...) {
    stop("rebuilt cuts for ordinary numeric bin labels")
  }), parent = environment(fn))
  for (labels in list(c(1L, 3L, NA_integer_, 1L), c(-0, 1.5, Inf, NaN), c(1, 2, 3, 4))) {
    expect_identical(fn(x, knots, labels), cut(x, knots, labels = labels, include.lowest = TRUE))
  }
})

test_that("automatic factor bins use numeric endpoint summaries", {
  d <- c(-8.1, 4.4, NA_real_, 0, 15)
  f <- fct_num
  environment(f) <- list2env(list(range = function(x, ...) {
    if (identical(substitute(x), quote(numeric_x))) stop("rebuilt the full range of automatic bin values")
    base::range(x, ...)
  }), parent = environment(f))
  expect_identical(f(d, nbins = 2L, type = "equal"), fct_num(d, nbins = 2L, type = "equal"))
  expect_identical(f(d, nbins = 2L), fct_num(d, nbins = 2L))
  expect_identical(f(1:12, nbins = 3L), fct_num(1:12, nbins = 3L))
})

test_that("quantile bins keep distinct breakpoints without deduplication", {
  fn <- fct_num
  environment(fn) <- list2env(list(unique = function(x, ...) {
    if (identical(substitute(x), quote(bin_breaks)) && !anyDuplicated(x))
      stop("deduplicated distinct quantile breakpoints")
    base::unique(x, ...)
  }), parent = environment(fn))
  values <- c(seq_len(120L), NA_integer_)
  expect_identical(fn(values, nbins = 10L), fct_num(values, nbins = 10L))
  tied <- c(rep(0, 100), rep(1, 20), 2)
  expect_warning(observed <- fn(tied, nbins = 5L), "Ties in quantiles")
  expect_identical(observed, suppressWarnings(fct_num(tied, nbins = 5L)))
})

test_that("fixed ordinary bin thresholds avoid full comparison masks", {
  breaks <- seq(0.5, 70.5, length.out = 71L)
  fn <- fct_num
  environment(fn) <- list2env(list(is.finite = function(x) {
    if (identical(substitute(x), quote(breaks)) && length(x) == 71L)
      stop("built finiteness flags for ordinary cut points")
    base::is.finite(x)
  }), parent = environment(fn))
  expect_identical(fn(1:90, breaks = breaks), fct_num(1:90, breaks = breaks))
  expect_error(fn(1:90, breaks = c(breaks, Inf)), "finite, non-missing")
})

test_that("plain integer quantile bins do not precompute numeric bounds", {
  x <- c(1:100, NA_integer_)
  fn <- fct_num
  environment(fn) <- list2env(list(min = function(x, ...) {
    if (is.integer(x) && length(x) == 101L) stop("measured integer endpoints before calculating quantiles")
    base::min(x, ...)
  }), parent = environment(fn))
  expect_identical(fn(x, nbins = 4), fct_num(x, nbins = 4))
  expect_identical(fn(x[-length(x)], nbins = 4), fct_num(x[-length(x)], nbins = 4))
  expect_error(fn(rep(3L, 101L), nbins = 4), "constant")
})

test_that("plain bin labels enter the factor dictionary without coercion", {
  fn <- .fct_num_cut
  environment(fn) <- list2env(list("as.character" = function(x, ...) {
    if (identical(substitute(x), quote(labels)) && is.null(attributes(x)) && is.character(x)) stop("unnecessary as.character in .fct_num_cut")
    base::as.character(x, ...)
  }), parent = environment(fn))
  x <- c(0, 1, 1.5, 2, 3, NA)
  breaks <- c(0, 1, 2, 3)
  expect_identical(fn(x, breaks, c("low", "mid", "high")), cut(x, breaks, c("low", "mid", "high"), include.lowest = TRUE))
  expect_identical(fn(x, breaks, c(a = "first", b = "second", c = "third")),
                   cut(x, breaks, c("first", "second", "third"), include.lowest = TRUE))
  expect_identical(levels(fn(x, breaks, c(1L, 2L, 1L))), c("1", "2"))
})

test_that("distinct equal-width bin boundaries do not need a duplicate search", {
  fn <- fct_num
  environment(fn) <- list2env(list("anyDuplicated" = function(x, ...) {
    if (identical(substitute(x), quote(bin_breaks)) && !is.unsorted(x, strictly = TRUE)) stop("unexpected anyDuplicated in fct_num")
    base::anyDuplicated(x, ...)
  }), parent = environment(fn))
  x <- 1:1000
  labels <- paste0("g", 1:50)
  expect_identical(fn(x, nbins = 50L, labels = labels, type = "equal"),
    cut(x, breaks = seq(1, 1000, length.out = 51L), labels = labels, include.lowest = TRUE))
  expect_error(fn(c(1, 1 + .Machine$double.eps), nbins = 5L, type = "equal"), "numeric precision")
})

test_that("strictly increasing quantile boundaries skip duplicate hashing", {
  fn <- fct_num
  environment(fn) <- list2env(list("anyDuplicated" = function(x, ...) {
    if (identical(substitute(x), quote(bin_breaks)) && !is.unsorted(x, strictly = TRUE)) stop("unexpected anyDuplicated in fct_num")
    base::anyDuplicated(x, ...)
  }), parent = environment(fn))
  x <- 1:1024
  expect_identical(fn(x, nbins = 16L),
    cut(x, breaks = stats::quantile(x, probs = (0:16) / 16), labels = paste0("g", 1:16), include.lowest = TRUE))
  expect_warning(out <- fn(rep(1:2, each = 5L), nbins = 6L), "Ties in quantiles")
  expect_length(out, 10L)
})

test_that("a single unbounded split preserves base-cut endpoint behavior", {
  x <- setNames(c(-Inf, -2, 0, 1, 1 + .Machine$double.eps, Inf, NA, NaN),
                letters[1:8])
  for (labels in list(c("low", "high"), c("same", "same"), c(NA, "kept"))) {
    expect_identical(fct_num(x, breaks = 1, labels = labels),
                     cut(x, c(-Inf, 1, Inf), labels = labels, include.lowest = TRUE))
  }
})
