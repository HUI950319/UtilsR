# Create a colour palette object

Returns a plain character vector of colours (no S3 class). Use
[`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
to display coloured swatches in the console.

## Usage

``` r
as_palette(x)
```

## Arguments

- x:

  Character vector of colours (hex codes or named R colours).

## Value

A character vector of colours.

## See also

Other colour palettes:
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)

## Examples

``` r
p <- as_palette(c("#FF0000", "#00FF00", "#0000FF"))
p
#> [1] "#FF0000" "#00FF00" "#0000FF"
show_color(p)
#>  #FF0000   #00FF00   #0000FF  
```
