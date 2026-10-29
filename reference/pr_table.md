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
  rownames = FALSE,
  n = 20,
  align = NULL,
  digits = 2,
  width = NULL,
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

- rownames:

  Logical. Show the row names as a first, unnamed column, e.g. the terms
  of `as.data.frame(coef(summary(fit)))`, which are otherwise not shown
  (default `FALSE`).

- n:

  Integer. Rows to show (default 20); the rest are counted in a grey
  footer. `NULL` shows every row.

- align:

  Column alignment, recycled: `"left"`, `"right"` or `"center"`. `NULL`
  (default) right-aligns numeric and P-value columns and left-aligns the
  rest.

- digits:

  Integer. Decimals for double columns (default 2).

- width:

  Integer. Line width the table must fit; `NULL` (default) uses the
  console width. The first column and the P-value columns always show, a
  first column too wide for the line cut with an ellipsis; the other
  columns follow in order while they fit, and the footer names those
  left out.

- indent:

  Integer. Spaces before each line (default 2).

## Value

The printed lines, invisibly.

## Details

Cells are formatted as follows. P-value columns: numbers take the
[`stat_pval`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)`(mode = "pvalue")`
wording (`"<0.001"`), a number just under 0.05 or 0.01 that this wording
would round up to the cut-off taking the decimals it needs (`0.0499`,
not `0.050`), text is kept as written, and values print bold red below
0.001, red below 0.05 and grey otherwise. Text bounds receive
significance styling only when their comparison guarantees a value below
the cut-off; lower bounds and invalid numeric text receive none. Other
double columns are rounded to `digits` decimals, or none when every
value is whole; a column whose smallest non-zero value would round to
zero gets enough decimals for two significant digits, at most six.
Nonzero values still rounded to zero, and numbers wider than the
available line, use scientific notation. Missing values print as a grey
`NA`. Matrix and array columns are described one row at a time,
retaining all components. List-column cells are described as in
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md),
e.g. `<dbl 2> 1.1, 2.2`. Everything else uses
[`as.character()`](https://rdrr.io/r/base/character.html). Classed
numeric and time-span columns use their format methods, retaining
integer64 digits and time units. The optional packages bit64, haven and
lubridate are loaded by namespace when their stored types are
encountered. Without colour (knitted documents, log files), P values
carry stars (`***` below 0.001, `**` below 0.01, `*` below 0.05),
highlighted rows start with `>` and missing text cells read `<NA>`.

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
