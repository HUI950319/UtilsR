# Boxed summary for a print method

Print a rounded box around key-value lines (as in
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)) or
plain lines, with an optional bold header in the top border and a grey
footer in the bottom one; suits a model specification such as outcome,
exposure, covariates and sample size.

## Usage

``` r
pr_box(x, header = NULL, footer = NULL, col = "cyan")
```

## Arguments

- x:

  A named list or named vector, shown as aligned key-value lines with
  `NULL` elements dropped, or an unnamed character vector, shown line by
  line.

- header, footer:

  Character, or `NULL` for none. Text set into the top and bottom
  border.

- col:

  Border colour: anything
  [`cli::make_ansi_style()`](https://cli.r-lib.org/reference/make_ansi_style.html)
  accepts (default `"cyan"`).

## Value

The printed lines, invisibly. Nothing prints when `x` has no lines, e.g.
when every element is `NULL`.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
pr_box(list(Outcome = "Surv(time, DSS)", Exposure = "Surgery (Yes vs No)",
            Adjust = "Age + Sex + Stage", N = "2,314 (412 events)"),
       header = "Cox model", footer = "adjusted")
#> ╭ Cox model ──────────────────────╮
#> │  Outcome   Surv(time, DSS)      │
#> │  Exposure  Surgery (Yes vs No)  │
#> │  Adjust    Age + Sex + Stage    │
#> │  N         2,314 (412 events)   │
#> ╰─────────────────────── adjusted ╯
```
