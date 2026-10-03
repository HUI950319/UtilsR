# Styled info box

Print a rounded box with type-coloured border and background.

## Usage

``` r
.cat_box(cat_text, type = c("info", "success", "warning", "error"))
```

## Arguments

- cat_text:

  Character. Text to display.

- type:

  One of `"info"`, `"success"`, `"warning"`, `"error"`.

## See also

Other console display:
[`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md),
[`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
[`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)

## Examples

``` r
.cat_box("Completed", type = "success")
#>                               ╭───────────────────╮
#>                               │                   │
#>                               │   ✓ Completed ✓   │
#>                               │                   │
#>                               ╰───────────────────╯
```
