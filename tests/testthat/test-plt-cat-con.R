# Saving of plt_cat() and plt_con(): the page each plot is laid out for.

cat_con_data <- function() {
  set.seed(7)
  data.frame(
    stage = factor(sample(c("I", "II", "III", "IV"), 120, TRUE)),
    sex = factor(sample(c("Female", "Male"), 120, TRUE)),
    site = factor(sample(c("A", "B", "C"), 120, TRUE)),
    age = stats::rnorm(120, 60, 10),
    bmi = stats::rnorm(120, 25, 4)
  )
}

test_that("plt_cat saves at its page size and reports a split figure once", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_cat)), 1), "save")
  d <- cat_con_data()
  f <- withr::local_tempfile(fileext = ".pdf")
  for (type in c("bar", "pie")) {
    out <- utils::capture.output(p <- suppressMessages(plt_cat(
      d, stat.by = "stage", group.by = "sex", type = type, save = list(filename = f))))
    expect_saved_at_plot_size(out, p)
  }
  out <- utils::capture.output(p <- suppressMessages(plt_cat(
    d, stat.by = "stage", group.by = "sex", split.by = "site",
    save = list(filename = f))))
  expect_equal(sum(grepl("laid out for", out)), 1L)
  expect_saved_at_plot_size(out, p)
  utils::capture.output(one <- suppressMessages(plt_cat(d, stat.by = "stage",
                                                        group.by = "sex")))
  expect_gt(attr(p, "plot_size")[[1]], attr(one, "plot_size")[[1]])
})

test_that("plt_con saves at its page size and refuses a list of plots", {
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  expect_identical(tail(names(formals(plt_con)), 1), "save")
  d <- cat_con_data()
  f <- withr::local_tempfile(fileext = ".pdf")
  out <- utils::capture.output(p <- suppressMessages(suppressWarnings(plt_con(
    d, stat.by = "age", group.by = "stage", save = list(filename = f)))))
  expect_saved_at_plot_size(out, p)
  out <- utils::capture.output(p <- suppressMessages(suppressWarnings(plt_con(
    d, stat.by = c("age", "bmi"), group.by = "stage", split.by = "sex",
    save = list(filename = f)))))
  expect_equal(sum(grepl("laid out for", out)), 1L)
  expect_saved_at_plot_size(out, p)
  expect_error(suppressMessages(suppressWarnings(plt_con(
    d, stat.by = c("age", "bmi"), group.by = "stage", combine = FALSE,
    save = list(filename = f)))), "list of plots")
})
