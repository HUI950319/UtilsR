# Styled separator line

Print a coloured rule with centred text and type-specific symbol.

## Usage

``` r
.cat_line(
  text,
  type = c("info", "success", "warning", "error"),
  line_char = "=",
  width = console_width()
)
```

## Arguments

- text:

  Character. Text to display.

- type:

  One of `"info"`, `"success"`, `"warning"`, `"error"`.

- line_char:

  Character used for the rule (default `"="`).

- width:

  Total width (default: console width).

## See also

Other console display:
[`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md),
[`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md),
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
[`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)

## Examples

``` r
.cat_line("Data summary", width = 40)
#> =========   ℹ Data summary ℹ   =========
```
