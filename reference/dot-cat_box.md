# Styled info box

Print a rounded box with type-coloured border and background.

## Usage

``` r
.cat_box(cat_text, type = c("info", "success", "warning", "error"))
```

## Arguments

  - cat\_text:
    
    Character. Text to display.

  - type:
    
    One of `"info"`, `"success"`, `"warning"`, `"error"`.

## See also

Other console display: `.cat_formula()`, `.cat_line()`,
`.cat_message()`, `.cat_tb()`

## Examples

``` r
.cat_box("Completed", type = "success")
#>                               ╭───────────────────╮
#>                               │                   │
#>                               │   ✓ Completed ✓   │
#>                               │                   │
#>                               ╰───────────────────╯
```
