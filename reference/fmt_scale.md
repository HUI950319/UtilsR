# Set axis scales

Automatically detects discrete / continuous / date scale type and
applies user-supplied arguments via `do.call`.

## Usage

``` r
fmt_scale(plot, x = NULL, y = NULL)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplots.

  - x:
    
    Named list of arguments for the x-axis scale function. E.g.
    `list(limits = c(4, 8), breaks = seq(4, 8, 1))`.

  - y:
    
    Named list of arguments for the y-axis scale function.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_scale(p, x = list(limits = c(4, 8), breaks = seq(4, 8, 1)))

fmt_scale(p, y = list(labels = scales::label_percent()))

```
