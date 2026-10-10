# Color discrete axis tiles or text labels

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

  Physical axis to apply to: `"x"` (horizontal, default) or `"y"`
  (vertical), including after
  [`coord_flip()`](https://ggplot2.tidyverse.org/reference/coord_flip.html).

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

In tile mode, a formatted standalone ggplot is wrapped in a patchwork;
patchworks retain their container and lists return lists of formatted
plots. Text mode retains the input container type. Empty-data and
disabled-guide plots are unchanged.

## Details

Only Cartesian coordinates, including
[`coord_flip()`](https://ggplot2.tidyverse.org/reference/coord_flip.html),
are supported. Continuous axes and disabled axis guides retain their
displayed appearance. Other guide kinds are left unchanged; coloring
adapts `GuideAxis` objects and the default `"axis"` guide. Tile
positions follow each panel's trained scale and expansion, including
free facets. Existing guide settings, axis titles and scale labels are
retained. Rich-text axis elements retain their class, markup and layout
properties. Editable leaves in nested patchworks and named lists are
formatted while layouts, annotations, fixed graphics and inset overlays
are preserved. Repeated calls update the formatting and can switch
between modes. Subsequent calls to
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
or
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
can hide or restyle the guides.

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
dat <- data.frame(
  category = factor(rep(c("A", "B", "C"), each = 4)),
  value = c(2, 3, 4, 5, 4, 5, 7, 8, 1, 2, 3, 4)
)
cols <- c(A = "#E64B35", B = "#4DBBD5", C = "#00A087")
p <- ggplot(dat, aes(category, value)) + geom_boxplot()

# Tile mode: color strip between axis and rotated labels
fmt_axisTile(p, colors = cols)


# Tile mode: no text labels, color-only strip
fmt_axisTile(p, colors = cols, show_text = FALSE)


# Text mode: colored axis labels (no tiles)
fmt_axisTile(p, colors = cols, mode = "text")


# Y-axis tiles
p2 <- ggplot(dat, aes(value, category)) + geom_boxplot()
fmt_axisTile(p2, colors = cols, axis = "y")


# Match colors to scale values rather than their display labels
p3 <- p + scale_x_discrete(limits = c("C", "B", "A"),
                         labels = c(C = "Gamma", B = "Beta", A = "Alpha"))
fmt_axisTile(p3, colors = cols)


# Select the physical vertical axis after flipping
fmt_axisTile(p + coord_flip(), colors = cols, axis = "y")

```
