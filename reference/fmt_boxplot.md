# Overlay a boxplot layer

Adds `geom_boxplot` on top of existing layers (e.g. violin, jitter).
Outliers are suppressed by default.

## Usage

``` r
fmt_boxplot(plot, boxplot.args = list(), inherit.aes = TRUE)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplots.

  - boxplot.args:
    
    Named list of arguments passed to `ggplot2::geom_boxplot`. Defaults
    include `width = 0.3`, `alpha = 0.2`, `na.rm = TRUE`.

  - inherit.aes:
    
    Whether to inherit aesthetics from the parent plot.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`, `fmt_legend()`,
`fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`, `fmt_point()`,
`fmt_raster()`, `fmt_ref()`, `fmt_scale()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_violin()
fmt_boxplot(p)

fmt_boxplot(p, boxplot.args = list(width = 0.2, alpha = 0.5))

```
