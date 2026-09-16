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
    
    One of three things:
    
      - a palette name (e.g. `"Paired"`, `"viridis"`, `"lancet"`); use
        `pal_list()` to see all available names;
    
      - a colour vector, or a single literal colour, used as the palette
        itself – a registered name always wins over a same-named colour,
        and a string that is neither still raises the usual "not found"
        error;
    
      - a fully named list of colour vectors, such as `pal_heat`, which
        is mapped over one palette at a time.

  - n:
    
    Number of colours to return. For discrete palettes, colours are
    recycled or interpolated as needed. Default `NULL` returns all
    colours in the palette.

  - x:
    
    Optional vector to map colours to. If character/factor, returns a
    named colour vector. If numeric, interpolates along the palette.

  - reverse:
    
    Logical, reverse colour order. Default `FALSE`.

  - alpha:
    
    Numeric 0-1, colour transparency. Default 1 (opaque).

## Value

A character vector of hex colours, or – when `palette` is a list of
palettes – a list of such vectors under the same names.

## See also

Other colour palettes: `pal_bar`, `pal_heat`, `pal_lancet`,
`pal_list()`, `pal_other`, `pal_paraSC`, `pal_show()`,
`pal_show_brewer()`, `pal_show_ggsci()`, `pal_show_hcl()`,
`pal_show_viridis()`

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

# Colours of your own, and a whole list of palettes at once
pal_get(c("#2166ac", "#ffffff", "#b2182b"), n = 7)
#> [1] "#2166AC" "#6A99C7" "#B4CCE3" "#FFFFFF" "#E5B2B8" "#CB6571" "#B2182B"
pal_get(pal_heat$purple_teal, n = 7)
#> [1] "#4A148C" "#771FA0" "#B36DC6" "#FFFFFF" "#6FC3BB" "#1A887B" "#004C3F"
str(pal_get(pal_heat, n = 3))
#> List of 11
#>  $ blue_red     : chr [1:3] "#2166ac" "#67a9cf" "#ffffff"
#>  $ teal_pink    : chr [1:3] "#0c4b61" "#48b79d" "#ffffff"
#>  $ slate_red    : chr [1:3] "#2c3d50" "#808c8d" "#ffffff"
#>  $ purple_gold  : chr [1:3] "#381a4e" "#744c8c" "#ffffff"
#>  $ steel_rose   : chr [1:3] "#204053" "#3e6b7a" "#ffffff"
#>  $ navy_scarlet : chr [1:3] "#1c3044" "#4189c5" "#ffffff"
#>  $ green_orange : chr [1:3] "#174e33" "#4bba79" "#ffffff"
#>  $ purple_teal  : chr [1:3] "#4a148c" "#8e25aa" "#ffffff"
#>  $ olive_violet : chr [1:3] "#566b31" "#90bc90" "#ffffff"
#>  $ slate_crimson: chr [1:3] "#1e293b" "#65758b" "#ffffff"
#>  $ indigo_gold  : chr [1:3] "#1a1464" "#4a4590" "#ffffff"

# Use in ggplot
# ggplot(df, aes(x, y, color = group)) +
#   scale_color_manual(values = pal_get("lancet", x = levels(df$group)))
```
