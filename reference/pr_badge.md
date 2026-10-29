# Two-part key-value badge

Build badges in the style of a status badge: the key on dark grey, the
value on a colour that can carry its meaning (e.g. red for a violated
assumption). Unlike the other print helpers, `pr_badge()` returns the
strings without printing them, so several badges can share a line.

## Usage

``` r
pr_badge(key, value, bg = "blue", fg = "br_white")
```

## Arguments

- key, value:

  Keys and values, recycled to a common length (equal lengths, or length
  1). Values are converted with
  [`as.character()`](https://rdrr.io/r/base/character.html); SPSS
  user-missing values display as `NA`. Layout controls in keys and
  values are escaped.

- bg, fg:

  Background and text colour of the value part: anything
  [`cli::make_ansi_style()`](https://cli.r-lib.org/reference/make_ansi_style.html)
  accepts, as in
  [`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md).

## Value

A character vector of badges, one per key; without colour they read
`[key: value]`.

## See also

Other print helpers:
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
cat(pr_badge("model", "cox"), pr_badge("n", "2,314", bg = "green"),
    pr_badge("PH", "violated", bg = "red"), "\n")
#>  model  cox   n  2,314   PH  violated  
```
