# Add colored tiles between axis and labels

Insert colored tiles at the discrete axis or color its text labels.
Colors are matched to trained scale values, independently of displayed
labels. Scale order, selected breaks, dropped levels and missing
categories are respected. Data and statistics are evaluated only when
the plot is built. Two modes are available:

- `"tile"` (default) — draw a colored strip between the axis line and
  labels using the axis guide. Axis titles are retained.

- `"text"` — color individual axis labels without vectorized theme
  elements or a background tile.

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

  Named character vector of colors, where names match the discrete axis
  levels (e.g. `c(setosa = "red", virginica = "blue")`). Required; names
  must be unique and non-empty. Missing colors use `"grey70"` in tile
  mode or `text_color` in text mode.

- mode:

  `"tile"` (default) or `"text"`.

- axis:

  Which axis to apply to: `"x"` (default) or `"y"`.

- tile_height:

  Positive finite numeric. Relative height of the tile strip when
  `axis = "x"`, as a fraction of the main panel height. Default 0.06.

- tile_width:

  Positive finite numeric. Relative width of the tile strip when
  `axis = "y"`, as a fraction of the main panel width. Default 0.06.

- tile_border:

  Color of tile borders. Default `"white"`.

- tile_border_width:

  Non-negative finite line width of tile borders. Default 0.2.

- text_size:

  Positive finite size of axis text labels below/beside tiles. Default
  9.

- text_face:

  Font face name or number from 1 to 5. Default `"plain"`.

- text_angle:

  Rotation angle for axis text labels. Default `45` for x-axis, `0` for
  y-axis.

- text_color:

  Color of tile-mode labels and fallback for unmatched text-mode labels.
  Default `"black"`.

- show_text:

  Logical. Show text labels below/beside tiles? Default `TRUE`. Set
  `FALSE` to hide labels in either mode.

## Value

In tile mode, a single non-empty ggplot is wrapped in a patchwork;
patchworks retain their container and lists return lists of formatted
plots. Text mode retains the input container type. Empty data plots are
unchanged.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

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


# Y-axis tiles
p2 <- ggplot(iris, aes(Sepal.Length, Species)) + geom_boxplot()
fmt_axisTile(p2, colors = cols, axis = "y")

```
