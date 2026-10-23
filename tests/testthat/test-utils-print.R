test_that("pr_head() prints a class chip and a grey summary line", {
  withr::local_options(cli.num_colors = 256)
  out <- utils::capture.output(
    line <- pr_head("sens_res", 'method = "cox"', NULL, NA, "", "n = 12")
  )
  expect_identical(cli::ansi_strip(out), ' sens_res  method = "cox" \u00b7 n = 12')
  expect_identical(out, as.character(line))
  expect_match(out, "\033[44m", fixed = TRUE)
  expect_match(out, "\033[90m", fixed = TRUE)

  expect_identical(cli::ansi_strip(utils::capture.output(pr_head("eff_res"))), " eff_res ")
  hex <- utils::capture.output(pr_head("x", bg = "#5F5FAF"))
  expect_match(hex, "\033[48;5;104m", fixed = TRUE)
})

test_that("pr_kv() aligns grey keys by display width and drops NULL values", {
  withr::local_options(cli.num_colors = 256)
  fit <- stats::lm(dist ~ speed, data = datasets::cars)
  x <- list(treat = "Surgery", time = NULL, conf_level = 0.95,
            levels = c("I", "II"), "\u5206\u7ec4" = "Stage", fit = fit)
  out <- utils::capture.output(lines <- pr_kv(x))

  expect_identical(cli::ansi_strip(out), c(
    "  treat       Surgery",
    "  conf_level  0.95",
    "  levels      I, II",
    paste0("  \u5206\u7ec4", strrep(" ", 8L), "Stage"),
    "  fit         <lm>"
  ))
  expect_identical(out, as.character(lines))
  expect_match(out[1], "\033[90m", fixed = TRUE)

  expect_error(pr_kv(list(1, a = 2)), "must be named")
  expect_identical(utils::capture.output(pr_kv(list(a = NULL))), character())
})
