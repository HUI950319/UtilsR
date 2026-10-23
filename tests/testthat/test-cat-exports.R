test_that("console display helpers are exported", {
  helpers <- c(
    ".cat_line",
    ".cat_box",
    ".cat_message",
    ".cat_formula",
    ".cat_tb",
    ".cat_step"
  )

  expect_setequal(helpers, intersect(helpers, getNamespaceExports("UtilsR")))
})
