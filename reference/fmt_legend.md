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
        \`"none"\`.
    
      - Shorthand corner codes: \`"br"\`, \`"bl"\`, \`"tr"\`, \`"tl"\`
        (inside plot corners).
    
      - Numeric vector of length 2: \`c(x, y)\` coordinates (0-1) for
        inside-plot positioning.
    
    Default \`NULL\` (no change).

  - legend.direction:
    
    \`"horizontal"\` or \`"vertical"\`. Default \`NULL\`.

  - legend\_theme:
    
    A ggplot2 theme object for legend styling, e.g.,
    \[theme\_legend1()\]. Applied after position/direction settings so
    it can override them. Default \`NULL\` (no extra styling).

  - collect:
    
    Logical. If \`TRUE\` and input has multiple plots, collect legends
    into a single shared legend via patchwork. Default \`FALSE\`.

  - title:
    
    Character vector of legend titles, one per subplot. Recycled to
    match the number of subplots. Automatically detects which aesthetics
    (colour, fill, shape, etc.) are mapped and renames their legend
    titles. Default \`NULL\` (no change).

  - scale:
    
    Numeric. Proportionally scale the entire legend. `0.8` = shrink to
    80%, `1.2` = enlarge to 120%. Adjusts key size, text size, title
    size, point size, and spacing together. Default `NULL` (no scaling).

  - scale\_width:
    
    Numeric. Scale legend key width independently. Default `NULL` (no
    change).

  - scale\_height:
    
    Numeric. Scale legend key height independently. Default `NULL` (no
    change).

  - ncol:
    
    Number of columns in the legend layout (passed to
    \[ggplot2::guide\_legend()\]).

  - nrow:
    
    Number of rows in the legend layout (passed to
    \[ggplot2::guide\_legend()\]).

  - ...:
    
    Additional arguments passed to \[ggplot2::theme()\], e.g.,
    \`legend.text\`, \`legend.key.size\`, \`legend.background\`.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`, `fmt_point()`,
`fmt_raster()`, `fmt_ref()`, `fmt_scale()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

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
#> Warning: `guide_colourbar()` needs continuous scales.

```
