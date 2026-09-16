# Set axis expansion

Applies `ggplot2::expansion()` to one or both axes, automatically
detecting the correct scale type.

## Usage

``` r
fmt_expand(plot, mult = 0, add = c(0, 0), axis = NULL)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplots.

  - mult:
    
    Multiplicative expansion factor.

  - add:
    
    Additive expansion (length-2 vector for lower/upper).

  - axis:
    
    `"x"`, `"y"`, or `NULL` (both).

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_his()`, `fmt_legend()`,
`fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`, `fmt_point()`,
`fmt_raster()`, `fmt_ref()`, `fmt_scale()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_expand(p, mult = 0.05)

fmt_expand(p, add = c(0.5, 0), axis = "x")

```
