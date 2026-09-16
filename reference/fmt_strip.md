# Add facet strip labels to a plot

Wraps each plot in a single-panel `ggh4x::facet_wrap2` so that a
coloured strip label appears above the panel. Strip text is horizontally
and vertically centered.

## Usage

``` r
fmt_strip(plot, label = NULL, label_color = "black", label_fill = NULL)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplots.

  - label:
    
    Character vector of strip labels (recycled as needed).

  - label\_color:
    
    Text colour(s) for the strip label. Default `"black"`.

  - label\_fill:
    
    Background fill colour(s) for the strip. If `NULL`, strips use a
    transparent background.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_strip(p, label = "Iris Data", label_fill = "steelblue")

```
