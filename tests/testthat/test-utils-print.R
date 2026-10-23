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

test_that("pr_section() prints a grey rule with a bold title", {
  withr::local_options(cli.num_colors = 256, cli.unicode = TRUE)
  out <- utils::capture.output(pr_section("Effect ranges", width = 40))
  plain <- cli::ansi_strip(out)
  expect_identical(cli::ansi_nchar(plain, type = "width"), 40L)
  expect_identical(gsub(cli::symbol$line, "-", plain, fixed = TRUE),
                   paste0("-- Effect ranges ", strrep("-", 23L)))
  expect_match(out, "\033[1m", fixed = TRUE)
  expect_match(out, "\033[90m", fixed = TRUE)

  withr::local_options(cli.width = 200)
  wide <- cli::ansi_strip(utils::capture.output(pr_section("x")))
  expect_identical(cli::ansi_nchar(wide, type = "width"), 80L)
})

test_that("pr_note() prints a grey note with cli markup and caller values", {
  withr::local_options(cli.num_colors = 256)
  k <- 3
  out <- utils::capture.output(pr_note("Next: {.code plt_sens(res)} for {k} panel{?s}"))
  expect_identical(cli::ansi_strip(out), "# Next: `plt_sens(res)` for 3 panels")
  expect_match(out, "\033[90m", fixed = TRUE)
  expect_match(out, "\033[3m", fixed = TRUE)

  withr::local_options(cli.hyperlink = TRUE, cli.hyperlink_run = TRUE)
  link <- utils::capture.output(pr_note("Run {.run RegR::plt_eff(res)}"))
  expect_match(link, "x-r-run:RegR::plt_eff(res)", fixed = TRUE)
})

test_that("pr_badge() returns two-part badges without printing", {
  withr::local_options(cli.num_colors = 256)
  expect_silent(b <- pr_badge(c("model", "n"), c("cox", "2,314")))
  expect_identical(cli::ansi_strip(b), c(" model  cox ", " n  2,314 "))
  expect_match(b[1], "\033[44m", fixed = TRUE)

  ph <- pr_badge("PH", "violated", bg = "red")
  expect_match(ph, "\033[41m", fixed = TRUE)
  expect_identical(cli::ansi_strip(pr_badge("events", 412)), " events  412 ")
  expect_error(pr_badge(c("a", "b", "c"), c("x", "y")), "same length")
})
