# Aligned key-value block for a print method

Print one `key value` line per element, keys in grey and aligned by
their display width, so Chinese or other wide-character keys line up.

## Usage

``` r
pr_kv(x, indent = 2)
```

## Arguments

- x:

  A named list or named vector. `NULL` elements are dropped, so optional
  settings can be passed as they are; atomic values are joined with
  `", "` (the first 20 items, then the count) and other objects are
  described by type and size, e.g. `<data.frame 6 x 11>` or `<lm>`. Long
  values wrap at the console width under the value column, as do the
  lines of a value that contains newlines.

- indent:

  Integer. Spaces before each key (default 2).

## Value

The printed lines, invisibly.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
pr_kv(list(treat = "Surgery", outcome = "Surv(time, DSS)",
           conf_level = 0.95, instrument = NULL))
#>   treat       Surgery
#>   outcome     Surv(time, DSS)
#>   conf_level  0.95
```
