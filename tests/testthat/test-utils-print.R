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

test_that("pr_table() aligns by display width and colours P values", {
  withr::local_options(cli.num_colors = 256, cli.unicode = TRUE)
  df <- data.frame(Variable = c("Age >= 55", "Male", "\u591a\u7076"),
                   HR = c(1.853, 1.25, NA), n = c(412, 87, 5),
                   P = c(0.0003, 0.012, 0.21))
  out <- utils::capture.output(lines <- pr_table(df, p_col = "P", highlight = 1))
  expect_identical(out, as.character(lines))
  expect_identical(cli::ansi_strip(out), c(
    "  Variable     HR    n       P",
    paste0("  ", strrep(cli::symbol$line, 28L)),
    "  Age >= 55  1.85  412  <0.001",
    "  Male       1.25   87   0.012",
    paste0("  \u591a\u7076", strrep(" ", 9L), "NA    5   0.210")
  ))
  expect_match(out[1], "\033[1m", fixed = TRUE)
  expect_match(out[3], "\033[48;5;229m", fixed = TRUE)
  expect_false(grepl("\033[31m", out[3], fixed = TRUE))
  expect_match(out[4], "\033[31m0.012", fixed = TRUE)
  expect_match(out[5], "\033[90m0.210", fixed = TRUE)
  expect_match(out[5], "\033[90mNA", fixed = TRUE)

  chr <- utils::capture.output(pr_table(data.frame(P = c("<0.001", "0.30")),
                                        p_col = "P"))
  expect_match(chr[3], "\033[1m", fixed = TRUE)
  expect_match(chr[3], "\033[31m", fixed = TRUE)
  expect_match(chr[4], "\033[90m", fixed = TRUE)

  logical_hl <- utils::capture.output(pr_table(df[1:2, ], highlight = c(FALSE, TRUE)))
  expect_match(logical_hl[4], "\033[48;5;229m", fixed = TRUE)
  expect_length(utils::capture.output(pr_table(df[0, ])), 2L)

  expect_error(pr_table(df, p_col = "p_value"), "p_value")
  expect_error(pr_table(as.list(df)), "data frame")
})
