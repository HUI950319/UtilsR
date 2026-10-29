# Section rule for a print method

Print a thin grey rule led by a bold title, to separate the blocks of a
print method.

## Usage

``` r
pr_section(title, width = NULL)
```

## Arguments

- title:

  Character. Section title.

- width:

  Positive integer. Rule width in characters; `NULL` uses the console
  width, capped at 80 so the rule does not stretch across wide consoles.
  A title too long for the rule is cut with an ellipsis.

## Value

The printed line, invisibly.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
pr_section("Effect ranges")
#> ── Effect ranges ───────────────────────────────────────────────────────────────
```
