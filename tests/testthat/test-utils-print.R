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
  plain[-1] <- sub("^[^A-Za-z]*", "", plain[-1])
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
  out <- utils::capture.output(pr_tree(x, max_depth = 1))
  expect_true(any(grepl('terms <chr 3> "Age", "Sex", "Stage"$', out)))
  expect_true(any(grepl("p <dbl 2> 0.1, 0.25$", out)))
  expect_true(any(grepl("deep <list 1> a$", out)))
  # a closed list previews its names and single values; unnamed, an ellipsis
  closed <- utils::capture.output(pr_tree(structure(
    list(inter = list(RERI = 0.42, S = NA, ci = c(1, 2)), u = list(1, 2)),
    analysis = list(n = 1000L, outcome = "DSS")), max_depth = 1))
  expect_true(any(grepl("inter <list 3> RERI = 0.42, S = NA, ci$", closed)))
  expect_true(any(grepl("u <list 2> \u2026$", closed)))
  expect_true(any(grepl('attr analysis <list 2> n = 1000, outcome = "DSS"$', closed)))
  # whole numbers as they are, decimals to three digits past the integer part
  nums <- utils::capture.output(pr_tree(list(n = 123456L, x = 1234.5678, small = 0.0000123)))
  expect_true(any(grepl("n <int> 123456$", nums)))
  expect_true(any(grepl("x <dbl> 1235$", nums)))
  expect_true(any(grepl("small <dbl> 1.23e-05$", nums)))
  # classed vectors are named as vctrs names them
  typed <- utils::capture.output(pr_tree(list(
    gap = as.difftime(c(1, 2), units = "days"),
    sex = labelled::labelled(c(1, 2), c(Male = 1, Female = 2)),
    when = as.POSIXlt("2026-10-25 12:00:00", tz = "UTC"),
    grade = factor("high", levels = c("low", "high"), ordered = TRUE))))
  expect_true(any(grepl("gap <drtn 2> 1 days, 2 days$", typed)))
  expect_true(any(grepl("sex <dbl\\+lbl 2> ", typed)))
  expect_true(any(grepl("when <dttm> 2026-10-25 12:00:00$", typed)))
  expect_true(any(grepl("grade <ord> ", typed)))
  # names, value labels and formulas in the preview; factor levels unquoted
  shown <- utils::capture.output(pr_tree(list(
    n = c(train = 800L, test = 200L),
    sex = labelled::labelled(c(1, 2), c(Male = 1, Female = 2)),
    grade = factor(c("low", NA)),
    model = Surv(time, DSS) ~ Age + Sex, call = quote(f(x)), var = quote(Age))))
  expect_true(any(grepl("n <int 2> train = 800, test = 200$", shown)))
  expect_true(any(grepl("sex <dbl\\+lbl 2> 1 \\[Male\\], 2 \\[Female\\]$", shown)))
  expect_true(any(grepl("grade <fct 2> low, NA$", shown)))
  expect_true(any(grepl("model <formula> Surv\\(time, DSS\\) ~ Age \\+ Sex$", shown)))
  expect_true(any(grepl("call <call> f\\(x\\)$", shown)))
  expect_true(any(grepl("var <sym> Age$", shown)))
  # the preview fills the line up to the console width; sizes get a thousands mark
  wide <- withr::with_options(list(width = 50, cli.width = 50), utils::capture.output(
    pr_tree(list(words = paste("word", 1:30), big = 1:1e6,
                 df = data.frame(a = seq_len(12345))))))
  expect_true(all(cli::ansi_nchar(wide, type = "width") <= 50))
  expect_match(wide[2], 'words <chr 30> "word 1", .*\u2026$')
  expect_true(any(grepl("big <int 1,000,000> 1, 2, 3", wide)))
  expect_true(any(grepl("df <data.frame 12,345 x 1>", wide)))
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
  expect_identical(cut[10], "# … 16 more lines")
})

test_that("pr_tree() opens the object it is given", {
  withr::local_options(cli.num_colors = 1, cli.unicode = TRUE)
  fit <- lm(mpg ~ wt, mtcars)
  out <- utils::capture.output(pr_tree(fit, max_depth = 1))
  expect_identical(out[1], "<lm> <list 12>")
  expect_true(any(grepl("coefficients <dbl 2> \\(Intercept\\) = 37.3, wt = -5.34$", out)))
  df <- utils::capture.output(pr_tree(data.frame(age = c(40L, 50L), sex = c("F", "M"))))
  expect_identical(df, c("<data.frame 2 x 2>", "\u251c\u2500age <int 2> 40, 50",
                         "\u2514\u2500sex <chr 2> \"F\", \"M\""))
  gen <- methods::setClass("PrTreeRes", representation(table = "data.frame", n = "numeric"),
                           where = new.env())
  s4 <- utils::capture.output(pr_tree(gen(table = data.frame(a = 1:2), n = 10)))
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
  out <- sub("^[^A-Za-z]*", "", out[-1])
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
