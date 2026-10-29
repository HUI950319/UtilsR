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

# pr_tree() pads sibling names into a column; most tests read one space
squish <- function(x) gsub("(?<=\\S) {2,}(?=\\S)", " ", x, perl = TRUE)

test_that("pr_tree() shows the structure of a nested result list", {
  withr::local_options(cli.num_colors = 256)
  res <- structure(
    list(
      Overall = list(table = data.frame(a = 1:3, b = 4:6),
                     plot = structure(list(), class = c("gg", "ggplot"))),
      method = "cox",
      p = c(0.1, 0.2)
    ),
    class = c("eff_res", "list"), analysis = list(n = 10)
  )
  out <- utils::capture.output(lines <- pr_tree(res))
  expect_identical(out, as.character(lines))
  # drop the tree glyphs below the root, which depend on Unicode support
  plain <- cli::ansi_strip(out)
  plain[-1] <- squish(sub("^[^A-Za-z]*", "", plain[-1]))
  expect_identical(plain, c(
    " eff_res  <list 3>",
    "Overall <list 2>",
    "table <data.frame 3 x 2> a, b",
    "plot <gg>",
    "method <chr> \"cox\"",
    "p <dbl 2> 0.1, 0.2",
    "attr analysis <list 1> n = 10"
  ))
  expect_match(out[1], "\033[44m", fixed = TRUE)
  expect_match(out[7], "\033[36mattr", fixed = TRUE)
  # values in the text colour and NA in red, types grey, branches bold
  coloured <- utils::capture.output(pr_tree(list(p = c(0.1, NA), sub = list(a = 1))))
  expect_match(coloured[2], "\033[90m<dbl 2>\033[39m 0.1", fixed = TRUE)
  expect_match(coloured[2], "\033[31mNA\033[39m", fixed = TRUE)
  expect_match(coloured[3], "\033[1msub\033[22m", fixed = TRUE)

  expect_length(utils::capture.output(pr_tree(res, attrs = FALSE)), 6L)
  deep <- list(a = list(b = list(c = list(d = 1))))
  deep_out <- cli::ansi_strip(utils::capture.output(pr_tree(deep, max_depth = 2)))
  expect_identical(sub("^[^A-Za-z]*", "", deep_out[-1]),
                   c("a <list 1>", "b <list 1> c"))
  expect_identical(deep_out[1], "<list 1>")
  # the class chip is for a classed list; other roots do not repeat the class
  expect_identical(cli::ansi_strip(utils::capture.output(pr_tree(1:3))), "<int 3> 1, 2, 3")
  many <- cli::ansi_strip(utils::capture.output(pr_tree(as.list(1:30), max_items = 5)))
  expect_length(many, 7L)
  expect_match(many[7], "25 more", fixed = TRUE)
  # named elements left out are named, as far as the line goes
  named <- cli::ansi_strip(utils::capture.output(
    pr_tree(stats::setNames(as.list(1:30), paste0("e", 1:30)), max_items = 5)))
  expect_match(named[7], paste(cli::symbol$ellipsis, "25 more: e6, e7, e8, "), fixed = TRUE)
  # sibling names are padded into a column, up to 18 characters
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  aligned <- utils::capture.output(pr_tree(list(n = 1, outcome = "DSS")))
  expect_identical(aligned[2:3], c(paste0("\u251c\u2500n", strrep(" ", 7), "<dbl> 1"),
                                   "\u2514\u2500outcome <chr> \"DSS\""))
  capped <- utils::capture.output(pr_tree(list(n = 1, a_long_component_name_of_30_chr = 2)))
  expect_identical(capped[2], paste0("\u251c\u2500n", strrep(" ", 18), "<dbl> 1"))
})

test_that("pr_box() frames key-value lines under a header and footer", {
  withr::local_options(cli.num_colors = 256, cli.unicode = TRUE)
  x <- list(Outcome = "Surv(time, DSS)", N = "2,314", time = NULL)
  out <- utils::capture.output(lines <- pr_box(x, header = "Cox model", footer = "adjusted"))
  expect_identical(out, as.character(lines))
  plain <- cli::ansi_strip(out)
  expect_length(plain, 4L)
  expect_match(plain[1], "Cox model", fixed = TRUE)
  expect_false(grepl("  Cox model", plain[1], fixed = TRUE))
  expect_false(grepl("  adjusted", plain[4], fixed = TRUE))
  expect_match(plain[2], "Outcome  Surv(time, DSS)", fixed = TRUE)
  expect_match(plain[3], "N        2,314", fixed = TRUE)
  expect_match(plain[4], "adjusted", fixed = TRUE)
  expect_length(unique(cli::ansi_nchar(plain, type = "width")), 1L)
  expect_match(out[2], "\033[36m", fixed = TRUE)

  plain2 <- cli::ansi_strip(utils::capture.output(pr_box(c("line one", "line two"))))
  expect_length(plain2, 4L)
  expect_match(plain2[2], "line one", fixed = TRUE)
})

test_that("pr_box() prints nothing when there is nothing to frame", {
  expect_identical(utils::capture.output(pr_box(list())), character())
  expect_identical(utils::capture.output(pr_box(list(a = NULL), header = "Model")),
                   character())
  expect_identical(utils::capture.output(pr_box(character())), character())
})

test_that("pr_spark() prints one distribution line per column", {
  withr::local_options(cli.num_colors = 256, cli.unicode = TRUE)
  df <- data.frame(age = c(40, 50, 50, 60, 60, 60, 70, NA),
                   sex = factor(c("M", "F", "M", "M", "F", "M", "M", "F")))
  df$id <- I(as.list(1:8))
  out <- utils::capture.output(lines <- pr_spark(df, bins = 4))
  expect_identical(out, as.character(lines))
  plain <- cli::ansi_strip(out)
  expect_length(plain, 3L)
  n_bars <- function(x) lengths(regmatches(x, gregexpr("[\u2581-\u2588]", x)))

  expect_match(plain[1], "^  age ", perl = TRUE)
  expect_identical(n_bars(plain[1]), 4L)
  for (s in c("mean 55.7", "sd 9.76", "NA 12.5%")) expect_match(plain[1], s, fixed = TRUE)
  expect_match(out[1], "\033[36m", fixed = TRUE)

  expect_identical(n_bars(plain[2]), 2L)
  expect_match(plain[2], "2 levels \u00b7 top M (62.5%)", fixed = TRUE)
  expect_match(plain[2], "NA 0.0%", fixed = TRUE)
  expect_match(plain[3], "<AsIs>", fixed = TRUE)

  expect_length(utils::capture.output(pr_spark(df, vars = "sex")), 1L)
  even <- cli::ansi_strip(utils::capture.output(pr_spark(data.frame(x = c(2, 4, 6)))))
  expect_match(even, "mean 4.00  sd 2.00", fixed = TRUE)
  expect_error(pr_spark(df, vars = "stage"), "stage")
})

test_that("print helpers write no ANSI codes when stdout shows no colour", {
  # stdout redirected to a file while stderr, cli's default stream, is a
  # terminal: styles use colour, stdout itself does not
  testthat::local_mocked_bindings(
    num_ansi_colors = function(stream = "auto") if (identical(stream, "auto")) 256L else 1L,
    .package = "cli"
  )
  out <- utils::capture.output(lines <- pr_section("Effect ranges", width = 30))
  expect_false(any(grepl("\033[", out, fixed = TRUE)))
  expect_identical(out, as.character(lines))
  expect_false(any(grepl("\033[", utils::capture.output(pr_kv(list(a = 1))),
                         fixed = TRUE)))
})

test_that("pr_note() prints text cli cannot parse as written", {
  out <- cli::ansi_strip(utils::capture.output(pr_note("Groups: ", "levels {I, II}")))
  expect_identical(out, "# Groups: levels {I, II}")
})

test_that("print helpers stay readable without colour", {
  withr::local_options(cli.num_colors = 1)
  expect_identical(utils::capture.output(pr_head("eff_res", "2 effect tables")),
                   "<eff_res> 2 effect tables")
  expect_identical(pr_badge(c("model", "PH"), c("cox", "violated")),
                   c("[model: cox]", "[PH: violated]"))
  out <- utils::capture.output(pr_table(
    data.frame(term = c("a", "b", NA), P = c(0.0001, 0.004, 0.3)),
    p_col = "P", highlight = 1))
  expect_match(out[3], "^> a +<0\\.001\\*\\*\\*$")
  expect_match(out[4], "^  b +0\\.004\\*\\*$")
  expect_match(out[5], "^  <NA> +0\\.300$")
  expect_match(utils::capture.output(pr_tree(list(a = 1)))[1], "^<list 1>$")
})

test_that("pr_spark() counts an identifier column instead of tabulating it", {
  withr::local_options(cli.num_colors = 1)
  ids <- data.frame(id = c(sprintf("P%03d", 1:50), NA), grp = rep(c("a", "b"), length.out = 51))
  out <- utils::capture.output(pr_spark(ids))
  expect_match(out[1], "50 unique values", fixed = TRUE)
  expect_match(out[1], "NA 2.0%", fixed = TRUE)
  expect_false(grepl("levels", out[1]))
  # a few distinct values still show their levels
  few <- utils::capture.output(pr_spark(data.frame(x = c("a", "b", "c"))))
  expect_match(few, "3 levels", fixed = TRUE)
})

test_that("pr_spark() names an empty-string level", {
  out <- cli::ansi_strip(utils::capture.output(
    pr_spark(data.frame(site = c("", "", "head", "tail")))))
  expect_match(out, 'top "" (50.0%)', fixed = TRUE)
})

test_that("pr_table() fits the line width and caps the rows", {
  withr::local_options(cli.num_colors = 1)
  wide <- as.data.frame(matrix(1:30 + 0.5, 3))
  names(wide) <- paste0("column_", 1:10)
  wide$P <- c(0.01, 0.2, 0.5)
  out <- utils::capture.output(pr_table(wide, p_col = "P", width = 50))
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 50))
  # the first and the P-value columns stay, the rest drop from the right
  expect_match(out[1], "^  column_1  column_2 .* +P$")
  expect_match(paste(out, collapse = " "), "more columns: column_[0-9]")

  rows <- utils::capture.output(pr_table(data.frame(i = 1:30), n = 5))
  expect_length(rows, 8L)
  expect_match(rows[8], "^  # .* 25 more rows$")
  expect_length(utils::capture.output(pr_table(data.frame(i = 1:30), n = NULL)), 32L)
})

test_that("pr_table() shows a P value just under a cut-off with the decimals it needs", {
  withr::local_options(cli.num_colors = 1)
  out <- utils::capture.output(pr_table(data.frame(
    P = c(0.0499, 0.05, 0.00999, 0.01, 0.04999, 0.21)), p_col = "P"))
  expect_identical(trimws(out[3:8]), c("0.0499*", "0.050", "0.00999**", "0.010*",
                                       "0.04999*", "0.210"))
})

test_that("pr_table(rownames = TRUE) shows the row names as the first column", {
  withr::local_options(cli.num_colors = 1)
  m <- matrix(c(1.85, 1.25, 0.0003, 0.012), 2,
              dimnames = list(c("Age >= 55", "Male"), c("HR", "P")))
  out <- sub(" +$", "", utils::capture.output(
    pr_table(as.data.frame(m), p_col = "P", rownames = TRUE)))
  expect_match(out[1], "^ +HR +P$")
  expect_match(out[3], "^  Age >= 55  1\\.85 +<0\\.001\\*\\*\\*$")
  expect_match(out[4], "^  Male +1\\.25 +0\\.012\\*$")
  # off by default: rbind() of a named list leaves row names such as "cox.1"
  expect_false(any(grepl("Age", utils::capture.output(pr_table(as.data.frame(m))))))
})

test_that("pr_table() cuts a first column too wide for the line", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  long <- data.frame(Variable = strrep("Very long covariate label ", 3), HR = 1.2,
                     P = 0.03)
  out <- utils::capture.output(pr_table(long, p_col = "P", width = 40))
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 40))
  expect_match(out[3], "\u2026  0\\.030\\*$")
  expect_match(out[length(out)], "1 more column: HR", fixed = TRUE)
})

test_that("pr_table() keeps a first column that fits whole without Unicode", {
  # cli::ansi_strtrim() returns its "..." cut to the width, even for a string
  # that fits, when the width is narrower than the ellipsis
  withr::local_options(cli.num_colors = 1, cli.unicode = FALSE)
  out <- utils::capture.output(pr_table(data.frame(g = c("A", "BC"), n = 1:2)))
  expect_identical(sub(" +$", "", out[3:4]), c("  A   1", "  BC  2"))
})

test_that("pr_spark() summarizes classed numbers as plain numbers", {
  skip_if_not_installed("bit64")
  withr::local_options(cli.num_colors = 1)
  data <- data.frame(id = 1:12)
  data$big <- bit64::as.integer64(seq(10, 120, by = 10))
  out <- utils::capture.output(pr_spark(data, "big"))
  expect_match(out, "mean 65.0  sd 36.1", fixed = TRUE)
  expect_lt(nchar(out), 60L)
})

test_that("pr_table() describes the cells of a list column", {
  withr::local_options(cli.num_colors = 1)
  df <- data.frame(term = c("a", "b"))
  df$ci <- list(c(1.1, 2.2), 3:5)
  out <- sub(" +$", "", utils::capture.output(pr_table(df)))
  expect_match(out[3], "^  a +<dbl 2> 1\\.1, 2\\.2$")
  expect_match(out[4], "^  b +<int 3> 3, 4, 5$")
})

test_that("pr_table() gives tiny values enough decimals", {
  withr::local_options(cli.num_colors = 1)
  out <- utils::capture.output(pr_table(data.frame(beta = c(0.0003, -1.234),
                                                   hr = c(1.5, 2.25))))
  expect_identical(trimws(out[3]), "0.00030  1.50")
  expect_identical(trimws(out[4]), "-1.23400  2.25")
})

test_that("pr_kv() and pr_box() wrap long values under the value column", {
  withr::local_options(cli.num_colors = 1, cli.width = 40)
  fml <- paste("y ~", paste0("x", 1:12, collapse = " + "))
  out <- utils::capture.output(pr_kv(list(formula = fml, note = "one\ntwo",
                                          lv = paste0("L", 1:25))))
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 40))
  expect_match(out[1], "^  formula  y ~ x1 ")
  expect_match(out[2], "^           x[0-9]")
  expect_true(any(out == "  note     one"))
  expect_true(any(out == "           two"))
  expect_true(any(grepl("L20, ", out, fixed = TRUE)))
  expect_false(any(grepl("L21", out, fixed = TRUE)))
  expect_true(any(grepl("(25)", out, fixed = TRUE)))

  box <- utils::capture.output(pr_box(list(formula = fml), header = "Model"))
  expect_true(all(cli::ansi_nchar(box, type = "width") <= 40))
  expect_gt(length(box), 3L)
})

test_that("pr_note() starts a new line at each newline", {
  withr::local_options(cli.num_colors = 1)
  k <- 2
  expect_identical(utils::capture.output(pr_note("first {k}\nsecond")),
                   c("# first 2", "# second"))
  expect_identical(utils::capture.output(pr_note("a {I}\nb")), c("# a {I}", "# b"))
})

test_that("pr_note() wraps long notes with a # on every line", {
  withr::local_options(cli.num_colors = 1, cli.width = 40)
  note <- paste(rep("A long caveat about the estimand.", 4), collapse = " ")
  out <- utils::capture.output(pr_note(note))
  expect_gt(length(out), 1L)
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 40))
  expect_true(all(startsWith(out, "# ")))
})

test_that("pr_head() and pr_section() trim long text with an ellipsis", {
  withr::local_options(cli.num_colors = 1, cli.width = 40, cli.unicode = TRUE)
  h <- utils::capture.output(pr_head("get_inter_abs", strrep("abc ", 20)))
  expect_lte(cli::ansi_nchar(h, type = "width"), 40L)
  expect_match(h, "\u2026$")
  s <- utils::capture.output(pr_section(strrep("long title ", 10), width = 40))
  expect_identical(cli::ansi_nchar(s, type = "width"), 40L)
  expect_match(s, "\u2026 \u2500+$")
})

test_that("pr_kv() describes object values by type and size", {
  withr::local_options(cli.num_colors = 1)
  out <- utils::capture.output(pr_kv(list(data = head(datasets::mtcars),
                                          grid = list(a = 1, b = 2))))
  expect_identical(out, c("  data  <data.frame 6 x 11>", "  grid  <list 2>"))
})

test_that("pr_kv() and pr_head() show numbers, factors and dates as print() does", {
  withr::local_options(cli.num_colors = 1, digits = 7)
  out <- utils::capture.output(pr_kv(list(alpha = 1/3, hr = exp(0.6), n = 2314L,
                                          conf = 0.95)))
  expect_identical(out, c("  alpha  0.3333333", "  hr     1.822119", "  n      2314",
                          "  conf   0.95"))
  head <- utils::capture.output(pr_head("x_res", 1/3, factor("cox"),
                                        as.Date("2026-10-25")))
  expect_identical(head, "<x_res> 0.3333333 \u00b7 cox \u00b7 2026-10-25")
})

test_that("pr_tree() previews vectors, marks collapsed nodes and caps lines", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  x <- list(terms = c("Age", "Sex", "Stage"), p = c(0.1, 0.25),
            deep = list(a = list(b = 1)))
  out <- squish(utils::capture.output(pr_tree(x, max_depth = 1)))
  expect_true(any(grepl('terms <chr 3> "Age", "Sex", "Stage"$', out)))
  expect_true(any(grepl("p <dbl 2> 0.1, 0.25$", out)))
  expect_true(any(grepl("deep <list 1> a$", out)))
  # a closed list previews its names and single values; unnamed, an ellipsis
  closed <- squish(utils::capture.output(pr_tree(structure(
    list(inter = list(RERI = 0.42, S = NA, ci = c(1, 2)), u = list(1, 2)),
    analysis = list(n = 1000L, outcome = "DSS")), max_depth = 1)))
  expect_true(any(grepl("inter <list 3> RERI = 0.42, S = NA, ci$", closed)))
  expect_true(any(grepl("u <list 2> \u2026$", closed)))
  expect_true(any(grepl('attr analysis <list 2> n = 1000, outcome = "DSS"$', closed)))
  # a line that still overflows a narrow console ends in an ellipsis
  narrow <- withr::with_options(list(width = 30, cli.width = 30), utils::capture.output(
    pr_tree(list(tab = structure(data.frame(term = "Age", HR = 1.8), model_info = "Cox")))))
  expect_true(all(cli::ansi_nchar(narrow, type = "width") <= 30))
  expect_match(narrow[2], "\u2026$")
  # a cut vector ends in an ellipsis, also when its first values fit the line
  cut <- withr::with_options(list(width = 100, cli.width = 100),
                             utils::capture.output(pr_tree(list(ids = 1:100))))
  expect_match(cut[2], "ids <int 100> 1, 2, 3, .*\u2026$")
  # a closed node names the attributes it carries beyond its type's own
  tagged <- list(tab = structure(data.frame(a = 1), model_info = "x"),
                 sex = structure(factor("M"), label = "Sex"),
                 when = as.POSIXct("2026-10-25", tz = "UTC"))
  tags <- squish(utils::capture.output(pr_tree(tagged)))
  expect_true(any(grepl("tab <data.frame 1 x 1> a \\[attr: model_info\\]$", tags)))
  expect_true(any(grepl("sex <fct, 1 level> M \\[attr: label\\]$", tags)))
  expect_false(any(grepl("[attr:", tags[grepl("when", tags)], fixed = TRUE)))
  expect_false(any(grepl("[attr:", utils::capture.output(pr_tree(tagged, attrs = FALSE)),
                         fixed = TRUE)))
  # a matrix names its element type, a function its arguments
  kinds <- squish(utils::capture.output(pr_tree(list(
    m = matrix(1:6, 2), tab = table(c("a", "b")), f = function(data, formula, ...) NULL,
    g = function(a, b, c, d, e) NULL, s = sum))))
  expect_true(any(grepl("m <int matrix 2 x 3>$", kinds)))
  expect_true(any(grepl("tab <int table 2>$", kinds)))
  expect_true(any(endsWith(kinds, "f <fn(data, formula, ...)>")))
  expect_true(any(endsWith(kinds, "g <fn(a, b, c, d, \u2026)>")))
  expect_true(any(endsWith(kinds, "s <fn(..., na.rm)>")))
  # whole numbers as they are, decimals to three digits past the integer part
  nums <- squish(utils::capture.output(pr_tree(list(n = 123456L, x = 1234.5678,
                                                     small = 0.0000123))))
  expect_true(any(grepl("n <int> 123456$", nums)))
  expect_true(any(grepl("x <dbl> 1235$", nums)))
  expect_true(any(grepl("small <dbl> 1.23e-05$", nums)))
  # classed vectors are named as vctrs names them
  typed <- squish(utils::capture.output(pr_tree(list(
    gap = as.difftime(c(1, 2), units = "days"),
    sex = labelled::labelled(c(1, 2), c(Male = 1, Female = 2)),
    when = as.POSIXlt("2026-10-25 12:00:00", tz = "UTC"),
    grade = factor("high", levels = c("low", "high"), ordered = TRUE)))))
  expect_true(any(grepl("gap <drtn 2> 1 days, 2 days$", typed)))
  expect_true(any(grepl("sex <dbl\\+lbl 2> ", typed)))
  expect_true(any(grepl("when <dttm> 2026-10-25 12:00:00$", typed)))
  expect_true(any(grepl("grade <ord, 2 levels> ", typed)))
  # names, value labels and formulas in the preview; factor levels unquoted
  shown <- squish(utils::capture.output(pr_tree(list(
    n = c(train = 800L, test = 200L),
    sex = labelled::labelled(c(1, 2), c(Male = 1, Female = 2)),
    grade = factor(c("low", NA)),
    model = Surv(time, DSS) ~ Age + Sex, call = quote(f(x)), var = quote(Age)))))
  expect_true(any(grepl("n <int 2> train = 800, test = 200$", shown)))
  expect_true(any(grepl("sex <dbl\\+lbl 2> 1 \\[Male\\], 2 \\[Female\\]$", shown)))
  expect_true(any(grepl("grade <fct 2, 1 level> low, NA$", shown)))
  expect_true(any(grepl("model <formula> Surv\\(time, DSS\\) ~ Age \\+ Sex$", shown)))
  expect_true(any(grepl("call <call> f\\(x\\)$", shown)))
  expect_true(any(grepl("var <sym> Age$", shown)))
  # the preview fills the line up to the console width; sizes get a thousands mark
  wide <- withr::with_options(list(width = 50, cli.width = 50), utils::capture.output(
    pr_tree(list(words = paste("word", 1:30), big = 1:1e6,
                 df = data.frame(a = seq_len(12345))))))
  expect_true(all(cli::ansi_nchar(wide, type = "width") <= 50))
  expect_match(squish(wide[2]), 'words <chr 30> "word 1", .*\u2026$')
  expect_true(any(grepl("big <int 1,000,000> 1, 2, 3", squish(wide))))
  expect_true(any(grepl("df <data.frame 12,345 x 1>", squish(wide))))
  # a data frame left closed lists its columns; pr_kv() keeps to the size
  cols <- utils::capture.output(pr_tree(list(tab = data.frame(term = "Age", HR = 1.8, p = 0.01))))
  expect_true(any(grepl("tab <data.frame 1 x 3> term, HR, p$", cols)))
  big <- utils::capture.output(pr_tree(rep(list(as.list(1:20)), 20), max_lines = 30))
  expect_length(big, 31L)
  expect_match(big[31], "more lines")

  # the lines kept at max_lines are those of the full tree, branch glyphs
  # included: the last kept line still shows siblings below it
  x <- rep(list(as.list(1:5)), 4)
  full <- utils::capture.output(pr_tree(x))
  cut  <- utils::capture.output(pr_tree(x, max_lines = 9))
  expect_identical(cut[1:9], full[1:9])
  expect_identical(cut[10], "# … 16 more lines (max_lines = 9)")
})

test_that("pr_tree() opens the object it is given", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  fit <- lm(mpg ~ wt, mtcars)
  out <- squish(utils::capture.output(pr_tree(fit, max_depth = 1)))
  expect_identical(out[1], "<lm> <list 12>")
  expect_true(any(grepl("coefficients <dbl 2> \\(Intercept\\) = 37.3, wt = -5.34$", out)))
  df <- utils::capture.output(pr_tree(data.frame(age = c(40L, 50L), sex = c("F", "M"))))
  expect_identical(df, c("<data.frame 2 x 2>", "\u251c\u2500age <int 2> 40, 50",
                         "\u2514\u2500sex <chr 2> \"F\", \"M\""))
  gen <- methods::setClass("PrTreeRes", representation(table = "data.frame", n = "numeric"),
                           where = new.env())
  s4 <- squish(utils::capture.output(pr_tree(gen(table = data.frame(a = 1:2), n = 10))))
  expect_identical(s4[1], "<PrTreeRes> <S4 2>")
  expect_true(any(grepl("@table <data.frame 2 x 1>", s4, fixed = TRUE)))
  expect_true(any(grepl("@n <dbl> 10$", s4)))
  # inside a list, a model fit stays closed
  inner <- utils::capture.output(pr_tree(list(fit = fit)))
  expect_identical(sub("^[^A-Za-z]*", "", inner[2]), "fit <lm>")
})

test_that("pr_tree() keeps rendered objects closed and names R6 objects", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  # a gt table, a RegR page and an htmltools tag list are lists underneath
  gt <- structure(list(`_data` = data.frame(a = 1:2), `_boxhead` = list()),
                  class = c("gt_tbl", "list"))
  page <- structure(list(list(), NULL), class = c("fmt_page", "list"))
  tags <- structure(list(list()), class = c("shiny.tag.list", "list"))
  learner <- structure(new.env(), class = c("LearnerSurvRanger", "Learner", "R6"))
  out <- utils::capture.output(pr_tree(list(gt = gt, view = page, tags = tags,
                                           learner = learner, env = new.env())))
  out <- squish(sub("^[^A-Za-z]*", "", out[-1]))
  expect_identical(out, c("gt <gt_tbl>", "view <fmt_page>", "tags <shiny.tag.list>",
                          "learner <LearnerSurvRanger>", "env <env>"))
  expect_identical(utils::capture.output(pr_kv(list(learner = learner))),
                   "  learner  <LearnerSurvRanger>")
})

test_that("pr_spark() bars few whole numbers per value and spans dates", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  n_bars <- function(x) lengths(regmatches(x, gregexpr("[\u2581-\u2588]", x)))
  stage <- utils::capture.output(pr_spark(data.frame(stage = c(1, 2, 2, 3, 3, 3, 4, 4, 10))))
  expect_identical(n_bars(stage), 5L)
  when <- utils::capture.output(pr_spark(data.frame(
    when = as.Date("2026-01-01") + c(0, 10, 20, 30, 200, NA))))
  expect_identical(n_bars(when), 5L)
  expect_match(when, "2026-01-01 to 2026-07-20", fixed = TRUE)
  expect_match(when, "NA 16.7%", fixed = TRUE)
})

test_that("pr_table() preserves integer64 values without converting their storage", {
  skip_if_not_installed("bit64")
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(n = bit64::as.integer64(c("2314", "9007199254740993", NA)))
  out <- trimws(utils::capture.output(pr_table(x)))
  expect_identical(out[3:5], c("2314", "9007199254740993", "NA"))
})

test_that("pr_table() keeps the units and components of classed numbers", {
  skip_if_not_installed("lubridate")
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(span = lubridate::days(c(1, 2, NA)))
  expect_identical(trimws(utils::capture.output(pr_table(x)))[3:5],
                   c("1d 0H 0M 0S", "2d 0H 0M 0S", "NA"))
  gap <- data.frame(span = as.difftime(c(1, 2), units = "days"))
  expect_identical(trimws(utils::capture.output(pr_table(gap)))[3:4], c("1 days", "2 days"))
})

test_that("pr_table() infers significance only when a text bound guarantees it", {
  withr::local_options(cli.num_colors = 1)
  p <- c(">0.001", ">=0.001", "<=0.05", "\u22640.05", "<0.05", "\u22640.01",
         "0.01", "-0.1", "Inf", "0.0001", "<0", ">1", "not available",
         "\u00a0<\u00a00.05\u00a0")
  out <- trimws(utils::capture.output(pr_table(data.frame(P = p), p_col = "P")))
  expect_identical(out[-c(1, 2)], c(">0.001", ">=0.001", "<=0.05", "\u22640.05", "<0.05*",
    "\u22640.01*", "0.01*", "-0.1", "Inf", "0.0001***", "<0", ">1", "not available", "<\u00a00.05*"))
  withr::local_options(cli.num_colors = 256)
  colour <- utils::capture.output(pr_table(data.frame(P = c(">0.001", "<0.05")), p_col = "P"))
  expect_false(grepl("\033[31m", colour[3], fixed = TRUE))
  expect_match(colour[4], "\033[31m", fixed = TRUE)
})

test_that("pr_table() does not round a significant P value onto its cut-off", {
  withr::local_options(cli.num_colors = 1)
  p <- c(0.049999999, 0.0099999999, 0.0009999999, 0.05, 0.01, 0.001)
  out <- trimws(utils::capture.output(pr_table(data.frame(P = p), p_col = "P")))
  expect_identical(out[-c(1, 2)], c("0.049999999*", "0.0099999999**", "<0.001***",
                                    "0.050", "0.010*", "0.001**"))
})

test_that("pr_table() reads repeated and empty column names by position", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(a = "first", b = "second", check.names = FALSE)
  names(x) <- c("x", "x")
  expect_match(utils::capture.output(pr_table(x))[3], "^ +first +second$")
  names(x) <- c("", "")
  expect_match(utils::capture.output(pr_table(x))[3], "^ +first +second$")
})

test_that("pr_table() retains every component of matrix and array cells", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(id = c("a", "b"))
  x$values <- matrix(1:4, nrow = 2)
  out <- utils::capture.output(pr_table(x))
  expect_match(out[3], "<int 2> 1, 3", fixed = TRUE)
  expect_match(out[4], "<int 2> 2, 4", fixed = TRUE)
  x$values <- array(1:8, dim = c(2, 2, 2))
  out <- utils::capture.output(pr_table(x))
  expect_match(out[3], "<int 4> 1, 3, 5, 7", fixed = TRUE)
  expect_match(out[4], "<int 4> 2, 4, 6, 8", fixed = TRUE)
  expect_length(utils::capture.output(pr_table(x[0, ])), 2L)
})

test_that("pr_spark() excludes SPSS user-missing values from numeric summaries", {
  skip_if_not_installed("haven")
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(v = haven::labelled_spss(c(1, 99, NA), na_values = 99))
  out <- utils::capture.output(pr_spark(x))
  expect_match(out, "mean 1.00  sd NA", fixed = TRUE)
  expect_match(out, "NA 66.7%", fixed = TRUE)
  x <- data.frame(v = haven::labelled_spss(c(1, 8, 9, NA), na_range = c(8, 9)))
  out <- utils::capture.output(pr_spark(x))
  expect_match(out, "mean 1.00  sd NA", fixed = TRUE)
  expect_match(out, "NA 75.0%", fixed = TRUE)
})

test_that("pr_spark() distinguishes empty, missing and non-finite columns", {
  withr::local_options(cli.num_colors = 1)
  out <- utils::capture.output(pr_spark(data.frame(v = numeric())))
  expect_match(out, "empty", fixed = TRUE)
  expect_match(out, "NA n/a", fixed = TRUE)
  out <- utils::capture.output(pr_spark(data.frame(v = factor(c(NA, NA), levels = c("a", "b")))))
  expect_match(out, "all missing", fixed = TRUE)
  expect_match(out, "NA 100.0%", fixed = TRUE)
  expect_false(grepl("top|NaN", out))
  out <- utils::capture.output(pr_spark(data.frame(v = c(Inf, -Inf))))
  expect_match(out, "no finite values", fixed = TRUE)
  expect_match(out, "NA 0.0%", fixed = TRUE)
  out <- utils::capture.output(pr_spark(data.frame(v = factor(c(NA, NA, "a"), exclude = NULL))))
  expect_match(out, "top <NA> (66.7%)", fixed = TRUE)
})

test_that("pr_table() keeps tiny nonzero and oversized numbers legible", {
  withr::local_options(cli.num_colors = 1, cli.width = 80)
  out <- trimws(utils::capture.output(pr_table(data.frame(v = c(1e-10, -1e-10, 1e-7, 0.1)))))
  expect_identical(out[3:5], c("1.00e-10", "-1.00e-10", "1.00e-07"))
  expect_identical(out[6], "0.100000")
  out <- trimws(utils::capture.output(pr_table(data.frame(v = c(1e100, -1e100, 2)))))
  expect_identical(out[3:5], c("1.00e+100", "-1.00e+100", "2"))
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 80))
})

test_that("single-line print fields escape embedded control characters", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(term = c("a\nb", "c\td"), P = c(0.1, 0.2))
  names(x)[1] <- "te\rrm"
  out <- utils::capture.output(pr_table(x, p_col = "P"))
  expect_length(out, 4L)
  expect_match(out[1], "te\\rrm", fixed = TRUE)
  expect_match(out[3], "a\\nb", fixed = TRUE)
  expect_match(out[4], "c\\td", fixed = TRUE)
  out <- utils::capture.output(pr_head("x", "a\nb"))
  expect_identical(out, "<x> a\\nb")
  x <- setNames(list("value"), "a\nb")
  expect_length(utils::capture.output(pr_tree(x)), 2L)
  expect_match(utils::capture.output(pr_tree(x))[2], "a\\nb", fixed = TRUE)
  x <- setNames(data.frame(v = c("a\nb", "a\nb")), "v\tx")
  out <- utils::capture.output(pr_spark(x))
  expect_length(out, 1L)
  expect_match(out, "v\\tx", fixed = TRUE)
  expect_match(out, "top a\\nb", fixed = TRUE)
})

test_that("print helpers keep long fields inside narrow console widths", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  for (w in c(20, 30, 40)) {
    withr::local_options(cli.width = w, width = w)
    kv <- utils::capture.output(pr_kv(list(a_long_setting_key = "some text some text")))
    box <- utils::capture.output(pr_box(list(a_long_setting_key = "some text"), header = "Model"))
    note <- utils::capture.output(pr_note(strrep("\u4e2d\u6587", 20)))
    table <- utils::capture.output(pr_table(data.frame(term = "first", P_value_one = 0.03,
      P_value_two = 0.03), p_col = c("P_value_one", "P_value_two"), width = w))
    spark <- utils::capture.output(pr_spark(data.frame(a_long_variable_name = rep("a very long category name", 2))))
    expect_true(all(cli::ansi_nchar(c(kv, box, note, table, spark), type = "width") <= w))
    expect_identical(paste0(sub("^# ", "", note), collapse = ""), strrep("\u4e2d\u6587", 20))
    expect_match(table[3], "0.030*", fixed = TRUE)
    expect_match(spark, "NA 0.0%$", perl = TRUE)
  }
})

test_that("print helpers validate integer controls before formatting", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(v = c(1.2, 3.4, 5.6))
  for (bad in list(-1, NA_real_, 1.5, Inf, numeric(), c(1, 2), "2", TRUE)) {
    expect_error(pr_spark(x, bins = bad), "bins.*whole number")
    expect_error(pr_table(x, digits = bad), "digits.*whole number")
    expect_error(pr_kv(list(a = 1), indent = bad), "indent.*whole number")
  }
  for (bad in list(0, -1, NA_real_, 1.5, Inf)) {
    expect_error(pr_table(x, width = bad), "width.*whole number")
    expect_error(pr_section("x", width = bad), "width.*whole number")
  }
  for (bad in list(-1, NA_real_, 1.5)) {
    expect_error(pr_table(x, n = bad), "n.*whole number")
    expect_error(pr_tree(list(a = 1), max_depth = bad), "max_depth.*whole number")
    expect_error(pr_tree(list(a = 1), max_items = bad), "max_items.*whole number")
    expect_error(pr_tree(list(a = 1), max_lines = bad), "max_lines.*whole number")
  }
  expect_error(pr_spark(x, bins = 0), "bins.*whole number")
  expect_length(utils::capture.output(pr_table(x, n = Inf)), 5L)
  expect_length(utils::capture.output(pr_tree(list(a = 1), max_depth = Inf, max_items = Inf, max_lines = Inf)), 2L)
})

test_that("pr_badge() restores integer64 methods when it is the first print call", {
  skip_if_not_installed("bit64")
  value_file <- tempfile(fileext = ".rds")
  script <- tempfile(fileext = ".R")
  saveRDS(bit64::as.integer64("2314"), value_file)
  dump(c("pr_badge", "._pr_restore", "._pr_escape", "._pr_colour", "._chip"), file = script,
       envir = environment(pr_badge))
  cat('\noptions(cli.num_colors = 1)\ncat(pr_badge("n", readRDS(commandArgs(TRUE)[[1]])))\n',
      file = script, append = TRUE)
  out <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script), shQuote(value_file)), stdout = TRUE, stderr = TRUE)
  expect_identical(out, "[n: 2314]")
})

test_that("pr_spark() inspects each default column despite repeated or missing names", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(a = c(1, 2), b = c(10, 20))
  names(x) <- c("x", "x")
  out <- utils::capture.output(pr_spark(x))
  expect_match(out[1], "mean 1.50", fixed = TRUE)
  expect_match(out[2], "mean 15.0", fixed = TRUE)
  names(x) <- c(NA, "")
  out <- utils::capture.output(pr_spark(x))
  expect_match(out[1], "<NA>", fixed = TRUE)
  expect_match(out[1], "mean 1.50", fixed = TRUE)
  expect_match(out[2], '""', fixed = TRUE)
  expect_match(out[2], "mean 15.0", fixed = TRUE)
  expect_match(utils::capture.output(pr_spark(x, vars = "")), "mean 15.0", fixed = TRUE)
})

test_that("pr_table() displays missing column headings without losing their data", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(a = 1, b = 10)
  names(x) <- c(NA, "")
  out <- utils::capture.output(pr_table(x))
  expect_match(out[1], "<NA>", fixed = TRUE)
  expect_match(out[3], "^ +1 +10$")
})

test_that("metadata print helpers preserve SPSS missingness during text conversion", {
  skip_if_not_installed("haven")
  withr::local_options(cli.num_colors = 1)
  v <- haven::labelled_spss(c(1, 99, NA), na_values = 99)
  expect_identical(utils::capture.output(pr_head("x", v)), "<x> 1")
  expect_identical(trimws(utils::capture.output(pr_kv(list(v = v)))), "v  1, NA, NA")
  expect_identical(pr_badge("v", v), c("[v: 1]", "[v: NA]", "[v: NA]"))
  expect_identical(as.numeric(v), c(1, 99, NA_real_))
})

test_that("pr_head() retains an explicit missing factor level as a category", {
  withr::local_options(cli.num_colors = 1)
  v <- factor(c("observed", NA), exclude = NULL)
  expect_identical(utils::capture.output(pr_head("x", v)), "<x> observed \u00b7 <NA>")
  expect_identical(trimws(utils::capture.output(pr_kv(list(v = v)))), "v  observed, <NA>")
})

test_that("pr_spark() summarizes POSIXlt columns as date-times", {
  withr::local_options(cli.num_colors = 1, cli.width = 100)
  v <- as.POSIXlt(c("2026-01-01", "2026-01-03", NA), tz = "UTC")
  x <- structure(list(time = v), class = "data.frame", row.names = 1:3)
  out <- utils::capture.output(pr_spark(x))
  expect_match(out, "2026-01-01 to 2026-01-03", fixed = TRUE)
  expect_match(out, "NA 33.3%", fixed = TRUE)
  expect_s3_class(x$time, "POSIXlt")
})

test_that("text P-value comparisons survive double underflow and rounded endpoints", {
  withr::local_options(cli.num_colors = 1, cli.width = 100)
  p <- c("-1e-999", "1e-999", "<1e-999", "<=1e-999",
    "0.049999999999999999999", "0.050000000000000000001",
    "0.009999999999999999999", "0.000999999999999999999",
    "1.000000000000000000001", "000.0000", "05e-2", "<5e-2", "<=5e-2", NA)
  out <- trimws(utils::capture.output(pr_table(data.frame(P = p), p_col = "P")))
  expect_identical(out[-c(1, 2)], c("-1e-999", "1e-999***", "<1e-999***", "<=1e-999***",
    "0.049999999999999999999*", "0.050000000000000000001",
    "0.009999999999999999999**", "0.000999999999999999999***",
    "1.000000000000000000001", "000.0000***", "05e-2", "<5e-2*", "<=5e-2", "NA"))
  withr::local_options(cli.num_colors = 256)
  out <- utils::capture.output(pr_table(data.frame(P = c("-1e-999", "<1e-999")), p_col = "P"))
  expect_false(grepl("\033[31m", out[3], fixed = TRUE))
  expect_match(out[4], "\033[31m", fixed = TRUE)
})

test_that("empty optional notes emit no line and missing boxed text stays printable", {
  withr::local_options(cli.num_colors = 1)
  expect_identical(utils::capture.output(pr_note()), character())
  expect_identical(utils::capture.output(pr_note(NULL)), character())
  expect_identical(utils::capture.output(pr_note(character())), character())
  expect_identical(utils::capture.output(pr_note("")), "# ")
  out <- utils::capture.output(pr_box(c("first", NA_character_, "last")))
  expect_length(out, 5L)
  expect_match(out[3], "NA", fixed = TRUE)
})

test_that("badges and box borders escape single-line layout controls", {
  withr::local_options(cli.num_colors = 1)
  expect_identical(pr_badge("a\nb", "v\tx"), "[a\\nb: v\\tx]")
  out <- utils::capture.output(pr_box("text", header = "a\nb", footer = "c\td"))
  expect_length(out, 3L)
  expect_match(out[1], "a\\nb", fixed = TRUE)
  expect_match(out[3], "c\\td", fixed = TRUE)
})

test_that("print helpers account for indentation markers borders and footers", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE, cli.width = 20)
  expect_error(pr_kv(list(a = "text"), indent = 20), "indent")
  expect_error(pr_spark(data.frame(v = 1:3), indent = 20), "indent")
  out <- utils::capture.output(pr_table(data.frame(v = strrep("a", 20)),
    width = 20, indent = 0, highlight = 1))
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 20))
  expect_match(out[3], "^> ")
  for (w in c(5, 10, 20)) {
    withr::local_options(cli.width = w)
    out <- utils::capture.output(pr_box("some text"))
    expect_true(all(cli::ansi_nchar(out, type = "width") <= w))
    out <- utils::capture.output(pr_tree(as.list(1:30), max_lines = 2))
    expect_true(all(cli::ansi_nchar(out, type = "width") <= w))
    expect_match(paste(out[-c(1, 2)], collapse = " "), "20 more lines", fixed = TRUE)
  }
  withr::local_options(cli.width = 5)
  out <- utils::capture.output(pr_box("a", header = "Model", footer = "done"))
  expect_length(out, 3L)
  expect_true(all(cli::ansi_nchar(out, type = "width") <= 5))
})

test_that("pr_tree() keeps class and attribute names within their metadata lines", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  x <- structure(list(a = 1), class = c("a\nb", "list"))
  out <- utils::capture.output(pr_tree(list(x = x)))
  expect_length(out, 3L)
  expect_match(out[2], "<a\\nb 1>", fixed = TRUE)
  x <- structure(list(a = 1), attr_value = 2)
  names(attributes(x))[names(attributes(x)) == "attr_value"] <- "a\nb"
  out <- utils::capture.output(pr_tree(x))
  expect_length(out, 3L)
  expect_match(out[3], "attr a\\nb", fixed = TRUE)
  out <- utils::capture.output(pr_tree(list(x = x), max_depth = 1))
  expect_length(out, 2L)
  expect_match(out[2], "[attr: a\\nb]", fixed = TRUE)
  out <- utils::capture.output(pr_tree(list(first = 1, second = 2), max_items = 0))
  expect_match(out[2], "2 more: first, second", fixed = TRUE)
})

test_that("pr_table() rejects precision beyond the formatter limit", {
  withr::local_options(cli.num_colors = 1)
  x <- data.frame(v = c(1.25, 2.5))
  for (d in c(325, 8191, 1e100)) {
    expect_error(pr_table(x, digits = d), "digits.*324")
  }
  expect_warning(utils::capture.output(pr_table(x, digits = 324)), NA)
})

test_that("large whole-number display limits do not warn during validation", {
  withr::local_options(cli.num_colors = 1)
  expect_warning(utils::capture.output(pr_table(data.frame(v = 1:3), n = 1e100)), NA)
  expect_warning(utils::capture.output(pr_tree(list(a = 1), max_lines = 1e100)), NA)
})

test_that("pr_spark() retains finite spread and compact text at extreme scales", {
  withr::local_options(cli.num_colors = 1, cli.width = 100)
  out <- utils::capture.output(pr_spark(data.frame(v = c(1e155, 2e155))))
  expect_match(out, "mean 1.50e+155  sd 7.07e+154", fixed = TRUE)
  out <- utils::capture.output(pr_spark(data.frame(v = c(1e-200, 2e-200))))
  expect_match(out, "mean 1.50e-200  sd 7.07e-201", fixed = TRUE)
  out <- utils::capture.output(pr_spark(data.frame(v = c(1e308, -1e308))))
  expect_match(out, "mean 0  sd 1.41e+308", fixed = TRUE)
  expect_match(out, "NA 0.0%", fixed = TRUE)
})

test_that("pr_spark() retains adjacent integer64 values above double precision", {
  skip_if_not_installed("bit64")
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  v <- bit64::as.integer64(c("9007199254740992", "9007199254740993"))
  out <- utils::capture.output(pr_spark(data.frame(v = v)))
  expect_match(out, "mean 9.01e+15  sd 0.707", fixed = TRUE)
  bars <- regmatches(out, gregexpr("[\u2581-\u2588]", out))[[1]]
  expect_length(bars, 2L)
})

test_that("pr_table() distinguishes an explicit NA factor level from missing storage", {
  withr::local_options(cli.num_colors = 1)
  f <- structure(c(1L, 2L, NA_integer_), levels = c("a", NA_character_), class = "factor")
  x <- data.frame(v = f)
  expect_identical(trimws(utils::capture.output(pr_table(x)))[3:5], c("a", "<NA>", "<NA>"))
  withr::local_options(cli.num_colors = 256)
  expect_identical(trimws(cli::ansi_strip(utils::capture.output(pr_table(x))))[3:5],
                   c("a", "<NA>", "NA"))
  expect_identical(x$v, f)
})

test_that("pr_table() describes packed data-frame columns one row at a time", {
  withr::local_options(cli.num_colors = 1, cli.width = 120)
  x <- data.frame(id = letters[1:3])
  x$packed <- data.frame(a = 1:3, b = c("first", "second", "third"))
  out <- utils::capture.output(pr_table(x))
  expect_match(out[3], 'a = 1, b = "first"', fixed = TRUE)
  expect_match(out[4], 'a = 2, b = "second"', fixed = TRUE)
  expect_match(out[5], 'a = 3, b = "third"', fixed = TRUE)
  expect_length(out, 5L)
  expect_length(utils::capture.output(pr_table(x[0, , drop = FALSE])), 2L)
})

test_that("tables and root trees treat POSIXlt as date-time vectors", {
  withr::local_options(cli.num_colors = 1)
  time <- as.POSIXlt(c("2026-01-01 01:02:03", "2026-01-03 04:05:06", NA), tz = "UTC")
  x <- structure(list(time = time), class = "data.frame", row.names = 1:3)
  y <- structure(list(time = as.POSIXct(time)), class = "data.frame", row.names = 1:3)
  expect_identical(utils::capture.output(pr_table(x)), utils::capture.output(pr_table(y)))
  expect_identical(utils::capture.output(pr_tree(time)), utils::capture.output(pr_tree(as.POSIXct(time))))
  expect_s3_class(x$time, "POSIXlt")
})
