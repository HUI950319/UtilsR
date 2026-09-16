# Compact Legend Theme

A minimal legend style with white background, small text, and reduced
spacing. Useful for plots where the legend should not dominate the
layout.

## Usage

``` r
theme_legend1()
```

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_heat()`, `theme_km`,
`theme_legend()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() +
  theme_legend1()

```
