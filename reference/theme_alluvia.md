# Alluvial / Sankey Plot Theme

A clean theme for alluvial and sankey plots. Based on
`thisplot::theme_alluvial()`, removes panel border, grid lines, axis
lines, and x-axis ticks for a minimal look.

## Usage

``` r
theme_alluvia(base_size = 14, base_family = "")
```

## Arguments

- base_size:

  Numeric. Base font size. Default 14.

- base_family:

  Character. Base font family. Default `""`.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes:
[`leg1()`](https://hui950319.github.io/UtilsR/reference/leg1.md),
[`leg2()`](https://hui950319.github.io/UtilsR/reference/leg2.md),
[`theme_ROC()`](https://hui950319.github.io/UtilsR/reference/theme_ROC.md),
[`theme_blank()`](https://hui950319.github.io/UtilsR/reference/theme_blank.md),
[`theme_heat()`](https://hui950319.github.io/UtilsR/reference/theme_heat.md),
[`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md),
[`theme_legend()`](https://hui950319.github.io/UtilsR/reference/theme_legend.md),
[`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md),
[`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
[`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md),
[`theme_sc()`](https://hui950319.github.io/UtilsR/reference/theme_sc.md),
[`theme_scatter`](https://hui950319.github.io/UtilsR/reference/theme_scatter.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
p + theme_alluvia()

```
