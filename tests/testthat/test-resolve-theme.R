test_that(".resolve_theme preserves valid themes and calls factories once", {
  thm <- ggplot2::theme(text = ggplot2::element_text(size = 17))
  expect_identical(.resolve_theme(thm), thm)
  expect_identical(.resolve_theme(NULL), theme_km)

  calls <- 0L
  make_theme <- function() {
    calls <<- calls + 1L
    thm
  }
  expect_identical(.resolve_theme(make_theme), thm)
  expect_identical(calls, 1L)
})

test_that(".resolve_theme rejects non-theme factory results", {
  invalid <- list(NULL, list(), 1, "theme_bw", ggplot2::geom_point(),
                  ggplot2::scale_y_reverse(), ggplot2::ggplot())
  for (value in invalid) {
    expect_error(.resolve_theme(function() value), "return.*theme")
  }
  expect_error(.resolve_theme("pal_lancet"), "theme_use.*must be")
})

test_that("fmt_plot_base rejects a factory returning a plot component", {
  d <- data.frame(x = 1:3, y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_error(fmt_plot_base(p, ggtheme = function() ggplot2::geom_point()),
               "return.*theme")
  expect_error(fmt_plot_base(p, ggtheme = function() ggplot2::scale_y_reverse()),
               "return.*theme")
  expect_length(p$layers, 1L)
})

test_that(".resolve_theme preserves a factory's original error", {
  expect_error(.resolve_theme(function() stop("theme factory failed")),
               "theme factory failed")
})

test_that(".resolve_theme finds exported themes without attached packages", {
  resolve <- function(name) UtilsR::.resolve_theme(name)
  environment(resolve) <- baseenv()
  thm <- resolve("theme_bw")
  expect_s3_class(thm, "theme")
  expect_equal(thm$text$size, 11)
  expect_identical(resolve("theme_km"), theme_km)
  expect_equal(resolve("theme_my")$text$size, 14)
})

test_that(".resolve_theme keeps visible custom factories and validates them", {
  custom_theme <- function() ggplot2::theme(text = ggplot2::element_text(size = 23))
  expect_equal(.resolve_theme("custom_theme")$text$size, 23)
  custom_bad_theme <- function() ggplot2::geom_point()
  expect_error(.resolve_theme("custom_bad_theme"), "return.*theme")
  expect_error(.resolve_theme("unknown_theme_for_test"), "not found")
})

test_that(".resolve_theme preserves active binding errors before export fallback", {
  failure <- simpleError("custom theme font configuration failed")
  calls <- 0L
  env <- new.env(parent = environment())
  makeActiveBinding("theme_bw", function() {
    calls <<- calls + 1L
    stop(failure)
  }, env)
  resolve <- function(name) .resolve_theme(name)
  environment(resolve) <- env

  expect_identical(tryCatch(resolve("theme_bw"), error = identity), failure)
  expect_identical(calls, 1L)
})

test_that(".resolve_theme preserves delayed binding errors before export fallback", {
  failure <- simpleError("custom theme initialization failed")
  env <- new.env(parent = environment())
  delayedAssign("theme_km", stop(failure), eval.env = environment(),
                assign.env = env)
  resolve <- function(name) .resolve_theme(name)
  environment(resolve) <- env

  expect_identical(tryCatch(resolve("theme_km"), error = identity), failure)
})

test_that(".resolve_theme skips non-functions when resolving visible names", {
  theme_bw <- 42
  expect_equal(.resolve_theme("theme_bw")$text$size, 11)
})

test_that(".resolve_theme rejects malformed theme names before lookup", {
  invalid <- list(character(), c("theme_bw", "theme_minimal"), NA_character_,
                  "", " \t\n", "\u00a0", "\u2003", matrix("theme_bw", 1L))
  for (value in invalid) {
    expect_error(.resolve_theme(value), "single.*non-missing.*non-empty")
  }
})

test_that("fmt_plot_base reports malformed theme names clearly", {
  d <- data.frame(x = 1:3, y = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_error(fmt_plot_base(p, ggtheme = character()),
               "single.*non-missing.*non-empty")
  expect_error(fmt_plot_base(p, ggtheme = NA_character_),
               "single.*non-missing.*non-empty")
})

test_that(".resolve_theme accepts named scalar theme names", {
  expect_equal(.resolve_theme(c(chosen = "theme_bw"))$text$size, 11)
  expect_identical(.resolve_theme(c(chosen = "theme_km")), theme_km)
})

test_that(".resolve_theme is available to importing packages", {
  expect_identical(getExportedValue("UtilsR", ".resolve_theme"), .resolve_theme)
})
