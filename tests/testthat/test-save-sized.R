test_that("invalid save controls fail before plot or size evaluation", {
  skip_if_not_installed("RegR")
  path <- tempfile(fileext = ".pdf")
  on.exit(unlink(path), add = TRUE)
  calls <- 0L
  plot <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(data) {
      calls <<- calls + 1L
      data
    })
  bad <- list(
    list(path),
    stats::setNames(list(path), NA_character_),
    list(filename = path, filename = path),
    list(filename = path, unknown_field = TRUE),
    list(filename = path, plot = plot),
    list(width = 2),
    list(filename = NA_character_),
    list(filename = sub("pdf$", "png", path)),
    list(filename = path, width = -1),
    list(filename = path, height = NA_real_),
    list(filename = path, device = "unknown")
  )
  for (save in bad) {
    calls <- 0L
    size_calls <- 0L
    error <- tryCatch(suppressMessages(UtilsR:::.save_sized(
      plot, save, function(...) {
        size_calls <<- size_calls + 1L
        c(2, 2)
      }, "review ", "review.pdf"
    )), error = identity)
    expect_s3_class(error, "error")
    expect_identical(calls, 0L)
    expect_identical(size_calls, 0L)
    expect_false(file.exists(path))
    unlink(path)
  }
})

test_that("save validation does not force an invalid call's plot promise", {
  skip_if_not_installed("RegR")
  expect_error(UtilsR:::.save_sized(
    stop("plot was evaluated"), list(filename = "review.pdf", width = -1),
    c(2, 2), "review ", "review.pdf", size = c(2, 2)
  ), "width")
})

test_that("save dimensions and filenames reject dimensional or encoded storage", {
  skip_if_not_installed("RegR")
  for (field in c("width", "height")) {
    for (bad in list(matrix(2), structure(2, class = "integer64"))) {
      save <- list(filename = "review.pdf")
      save[field] <- list(bad)
      expect_error(UtilsR:::.save_sized(stop("plot evaluated"), save,
        c(2, 2), "review ", "review.pdf", size = c(2, 2)), field)
    }
  }
  expect_error(UtilsR:::.save_sized(stop("plot evaluated"), list(filename = matrix("review.pdf")),
    c(2, 2), "review ", "review.pdf", size = c(2, 2)), "filename")
})

test_that("valid save controls retain dimensions and write the plot", {
  skip_if_not_installed("RegR")
  plot <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  for (save in list(NULL, list())) {
    result <- suppressMessages(UtilsR:::.save_sized(
      plot, save, c(2, 3), "review ", "review.pdf", size = c(2, 3)
    ))
    expect_identical(attr(result, "plot_size"), c(2, 3))
    expect_identical(ggplot2::ggplot_build(result)$data,
                     ggplot2::ggplot_build(plot)$data)
  }
  path <- tempfile(fileext = ".pdf")
  on.exit(unlink(path), add = TRUE)
  result <- suppressMessages(UtilsR:::.save_sized(
    plot, list(filename = path, width = NULL, height = 3, device = "pdf"),
    c(2, 3), "review ", "review.pdf", size = c(2, 3)
  ))
  expect_identical(attr(result, "plot_size"), c(2, 3))
  expect_gt(file.size(path), 0)
})
