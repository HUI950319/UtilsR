# Alluvial / Sankey Plot Theme

A clean theme for alluvial and sankey plots. Based on
`thisplot::theme_alluvial()`, removes panel border, grid lines, axis
lines, and x-axis ticks for a minimal look.

## Usage

``` r
theme_alluvia(base_size = 14, base_family = "")
```

## Arguments

  - base\_size:
    
    Numeric. Base font size. Default 14.

  - base\_family:
    
    Character. Base font family. Default `""`.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_blank()`, `theme_heat()`, `theme_km`, `theme_legend()`,
`theme_legend1()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
p + theme_alluvia()

```
