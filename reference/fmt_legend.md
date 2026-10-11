# Format legend position and style

Adjust legend position, direction, layout, scaling, and optionally
collect legends across a multi-plot patchwork.

## Usage

``` r
fmt_legend(
  plot,
  legend.position = NULL,
  legend.direction = NULL,
  legend_theme = NULL,
  collect = FALSE,
  title = NULL,
  scale = NULL,
  scale_width = NULL,
  scale_height = NULL,
  ncol = NULL,
  nrow = NULL,
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects.

- legend.position:

  Legend position. Accepts:

  - Character: \`"top"\`, \`"bottom"\`, \`"left"\`, \`"right"\`,
    \`"none"\`, \`"inside"\`.

  - Shorthand corner codes: \`"br"\`, \`"bl"\`, \`"tr"\`, \`"tl"\`
    (inside plot corners).

  - Numeric vector of length 2: \`c(x, y)\` coordinates (0-1) for
    inside-plot positioning.

  Default \`NULL\` (no change).

- legend.direction:

  \`"horizontal"\` or \`"vertical"\`. Default \`NULL\`.

- legend_theme:

  A ggplot2 theme object for legend styling, e.g., \[theme_legend1()\].
  Applied after position/direction settings so it can override them.
  Existing guide-local styling is merged with the requested legend
  styling. Default \`NULL\` (no extra styling).

- collect:

  Logical. If \`TRUE\` and input has multiple plots, collect legends
  into a single shared legend via patchwork. Default \`FALSE\`.

- title:

  Character vector of legend titles, one per subplot. Recycled to match
  the number of subplots. Automatically detects which aesthetics
  (colour, fill, shape, etc.) are mapped and renames their legend
  titles. Default \`NULL\` (no change).

- scale:

  One finite positive number. Proportionally scale the legend. `0.8` =
  shrink to 80%, `1.2` = enlarge to 120%. Adjusts key size, text size,
  title size, point size, and spacing together. Each subplot uses its
  own theme after applying new legend styling. Blank text and title
  elements remain blank, and grid units are retained. Default `NULL` (no
  scaling).

- scale_width:

  One finite positive number. Scale legend key width independently.
  Multiplies the overall factor when \`scale\` is supplied. Default
  `NULL` (no change).

- scale_height:

  One finite positive number. Scale legend key height independently.
  Multiplies the overall factor when \`scale\` is supplied. Default
  `NULL` (no change).

- ncol:

  One finite positive integer giving the columns in the legend layout
  (passed to \[ggplot2::guide_legend()\]).

- nrow:

  One finite positive integer giving the rows in the legend layout
  (passed to \[ggplot2::guide_legend()\]).

- ...:

  Additional arguments passed to \[ggplot2::theme()\], e.g.,
  \`legend.text\`, \`legend.key.size\`, \`legend.background\`.

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
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
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()

fmt_legend(p, legend.position = "bottom", legend.direction = "horizontal")

fmt_legend(p, legend.position = "none")

fmt_legend(p, legend.position = "br")

fmt_legend(p, legend.position = c(0.9, 0.2))

fmt_legend(p, legend.position = "br", legend_theme = theme_legend1())


# Scale legend to 80% of current size
fmt_legend(p, scale = 0.8)


# Scale width and height independently
fmt_legend(p, scale_width = 1.5, scale_height = 0.5)

```
