# Add coloured background stripes

Inserts shaded rectangles behind the data layer, one per level of the
categorical axis variable.

## Usage

``` r
fmt_bg(
  plot,
  palette = NULL,
  palcolor = NULL,
  alpha = 0.3,
  bg_axis = c("x", "y")
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplots.

  - palette:
    
    Palette name passed to `plotthis::palette_this`.

  - palcolor:
    
    Manual colour vector (overrides palette).

  - alpha:
    
    Transparency of the background rectangles.

  - bg\_axis:
    
    Which axis holds the categorical variable: `"x"` or `"y"`.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
fmt_bg(p, alpha = 0.2)

```
