# Get Colours from a Named Palette

Retrieve colours from the built-in palette collection (256 palettes).
Supports discrete mapping (factor/character input) and continuous
interpolation (numeric input or `n` parameter).

## Usage

``` r
pal_get(palette = "Paired", n = NULL, x = NULL, reverse = FALSE, alpha = 1)
```

## Arguments

- palette:

  Palette name (e.g. `"Paired"`, `"viridis"`, `"lancet"`). Use
  [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md)
  to see all available names.

- n:

  Number of colours to return. For discrete palettes, colours are
  recycled or interpolated as needed. Default `NULL` returns all colours
  in the palette.

- x:

  Optional vector to map colours to. If character/factor, returns a
  named colour vector. If numeric, interpolates along the palette.

- reverse:

  Logical, reverse colour order. Default `FALSE`.

- alpha:

  Numeric 0-1, colour transparency. Default 1 (opaque).

## Value

A character vector of hex colours (named if `x` is provided).

## See also

Other colour palettes:
[`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)

## Examples

``` r
# Get 5 colours from Paired palette
pal_get("Paired", n = 5)
#> [1] "#A6CEE3" "#1F78B4" "#B2DF8A" "#33A02C" "#FB9A99"

# Map factor levels to colours
pal_get("lancet", x = c("A", "B", "C"))
#> [1] "#00468BFF" "#ED0000FF" "#42B540FF"

# Continuous interpolation
pal_get("viridis", n = 20)
#>  [1] "#440154FF" "#440256FF" "#450457FF" "#450559FF" "#46075AFF" "#46085CFF"
#>  [7] "#460A5DFF" "#460B5EFF" "#470D60FF" "#470E61FF" "#471063FF" "#471164FF"
#> [13] "#471365FF" "#481467FF" "#481668FF" "#481769FF" "#48186AFF" "#481A6CFF"
#> [19] "#481B6DFF" "#481C6EFF"

# Reverse and transparent
pal_get("Blues", n = 5, reverse = TRUE, alpha = 0.6)
#> [1] "#6BAED699" "#9ECAE199" "#C6DBEF99" "#DEEBF799" "#F7FBFF99"

# Use in ggplot
# ggplot(df, aes(x, y, color = group)) +
#   scale_color_manual(values = pal_get("lancet", x = levels(df$group)))
```
