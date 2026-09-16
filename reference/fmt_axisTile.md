# Add colored tiles between axis and labels

Insert a strip of colored tiles between the plot area and the axis text
labels. Two modes are available:

  - `"tile"` (default) — insert a `geom_tile` color strip between the
    axis line and text labels via patchwork. Labels appear below
    (x-axis) or beside (y-axis) the tiles.

  - `"text"` — color the axis label text directly (no background tile),
    lightweight but uses unofficial vectorized `element_text`.

## Usage

``` r
fmt_axisTile(
  plot,
  colors,
  mode = c("tile", "text"),
  axis = c("x", "y"),
  tile_height = 0.06,
  tile_width = 0.06,
  tile_border = "white",
  tile_border_width = 0.2,
  text_size = 9,
  text_face = "plain",
  text_angle = NULL,
  text_color = "black",
  show_text = TRUE
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplot objects.

  - colors:
    
    Named character vector of colors, where names match the discrete
    axis levels (e.g. `c(setosa = "red", virginica = "blue")`).
    Required.

  - mode:
    
    `"tile"` (default) or `"text"`.

  - axis:
    
    Which axis to apply to: `"x"` (default) or `"y"`.

  - tile\_height:
    
    Numeric. Relative height of the tile strip when `axis = "x"`.
    Default 0.06.

  - tile\_width:
    
    Numeric. Relative width of the tile strip when `axis = "y"`. Default
    0.06.

  - tile\_border:
    
    Color of tile borders. Default `"white"`.

  - tile\_border\_width:
    
    Line width of tile borders. Default 0.2.

  - text\_size:
    
    Size of axis text labels below/beside tiles. Default 9.

  - text\_face:
    
    Font face of axis text labels. Default `"plain"`.

  - text\_angle:
    
    Rotation angle for axis text labels. Default `45` for x-axis, `0`
    for y-axis.

  - text\_color:
    
    Color of axis text labels. Default `"black"`.

  - show\_text:
    
    Logical. Show text labels below/beside tiles? Default `TRUE`. Set
    `FALSE` for color-only tiles.

## Value

A patchwork object (when `mode = "tile"`) or same type as input (when
`mode = "text"`).

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_bg()`,
`fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
cols <- c(setosa = "#E64B35", versicolor = "#4DBBD5", virginica = "#00A087")
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()

# Tile mode: color strip between axis and rotated labels
fmt_axisTile(p, colors = cols)


# Tile mode: no text labels, color-only strip
fmt_axisTile(p, colors = cols, show_text = FALSE)


# Text mode: colored axis labels (no tiles)
fmt_axisTile(p, colors = cols, mode = "text")
#> Warning: Vectorized input to `element_text()` is not officially supported.
#> ℹ Results may be unexpected or may change in future versions of ggplot2.


# Y-axis tiles
p2 <- ggplot(iris, aes(Sepal.Length, Species)) + geom_boxplot()
fmt_axisTile(p2, colors = cols, axis = "y")

```
