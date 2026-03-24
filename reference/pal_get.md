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
#>  #A6CEE3   #1F78B4   #B2DF8A   #33A02C   #FB9A99  

# Map factor levels to colours
pal_get("lancet", x = c("A", "B", "C"))
#>  #00468B   #ED0000   #42B540  

# Continuous interpolation
pal_get("viridis", n = 20)
#>  #440154   #440256   #450457   #450559   #46075A   #46085C   #460A5D   #460B5E   #470D60   #470E61   #471063   #471164   #471365   #481467   #481668   #481769   #48186A   #481A6C   #481B6D   #481C6E  

# Reverse and transparent
pal_get("Blues", n = 5, reverse = TRUE, alpha = 0.6)
#>  #6BAED6   #9ECAE1   #C6DBEF   #DEEBF7   #F7FBFF  

# Use in ggplot
# ggplot(df, aes(x, y, color = group)) +
#   scale_color_manual(values = pal_get("lancet", x = levels(df$group)))
```
