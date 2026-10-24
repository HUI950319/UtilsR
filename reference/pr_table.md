# Console table for a print method

Print a data frame as an aligned plain-text table: a bold header, a grey
rule, then one line per row. Columns are aligned by display width, so
Chinese text lines up; P-value columns are coloured by significance, and
chosen rows can be highlighted.

## Usage

``` r
pr_table(
  data,
  p_col = NULL,
  highlight = NULL,
  align = NULL,
  digits = 2,
  indent = 2
)
```

## Arguments

- data:

  A data frame (tibbles included).

- p_col:

  Character. Names of the P-value columns, or `NULL`.

- highlight:

  Rows to highlight in black on light yellow: integer row numbers or a
  logical vector. Highlighted rows drop their other colours.

- align:

  Column alignment, recycled: `"left"`, `"right"` or `"center"`. `NULL`
  (default) right-aligns numeric and P-value columns and left-aligns the
  rest.

- digits:

  Integer. Decimals for double columns (default 2).

- indent:

  Integer. Spaces before each line (default 2).

## Value

The printed lines, invisibly.

## Details

Cells are formatted as follows. P-value columns: numbers take the
[`stat_pval`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)`(mode = "pvalue")`
wording (`"<0.001"`), text is kept as written, and values print bold red
below 0.001, red below 0.05 and grey otherwise. Other double columns are
rounded to `digits` decimals, or none when every value is whole. Missing
values print as a grey `NA`. Everything else uses
[`as.character()`](https://rdrr.io/r/base/character.html).

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
res <- data.frame(
  Variable = c("Age >= 55", "Male", "Multifocal"),
  HR = c(1.85, 1.25, 1.08),
  P = c(0.0003, 0.012, 0.21)
)
pr_table(res, p_col = "P", highlight = 1)
#>   Variable      HR       P
#>   ────────────────────────
#>   Age >= 55   1.85  <0.001
#>   Male        1.25   0.012
#>   Multifocal  1.08   0.210
```
