# Quick Legend Theme (with title)

Shorthand for \[theme\_legend1()\]. Compact legend with white
background, grey border, small text, and bold title.

## Usage

``` r
leg1()
```

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg2()`, `theme_ROC()`, `theme_alluvia()`,
`theme_blank()`, `theme_heat()`, `theme_km`, `theme_legend()`,
`theme_legend1()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() + leg1()

```
