# Header line for a print method

Print a class label on a solid background followed by a grey one-line
summary: the first line of an S3 print method.

## Usage

``` r
pr_head(class, ..., bg = "blue", fg = "br_white")
```

## Arguments

- class:

  Character. Label shown on the chip, usually `class(x)[1]`.

- ...:

  Pieces of the summary, joined by a middle dot. `NULL`, `NA` and empty
  strings are dropped, so optional pieces can be passed as
  `if (cond) "text"`. Numbers show as
  [`print()`](https://rdrr.io/r/base/print.html) shows them, factors and
  dates as their labels.

- bg, fg:

  Background and text colour of the chip: anything
  [`cli::make_ansi_style()`](https://cli.r-lib.org/reference/make_ansi_style.html)
  accepts, i.e. an ANSI colour name such as `"blue"` or `"br_white"`, an
  R colour name or a hex code. Without colour (knitted documents, log
  files) the label prints as `<class>`.

## Value

The printed line, invisibly.

## Details

A line longer than the console is cut with an ellipsis.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
pr_head("sens_res", 'method = "cox"', "tipr 1.0.2", "n = 2,314")
#>  sens_res  method = "cox" · tipr 1.0.2 · n = 2,314
```
