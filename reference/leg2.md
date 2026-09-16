# Quick Legend Theme (no title)

Identical to \[leg1()\] / \[theme\_legend1()\] but with legend title
removed. White background, grey border, small text, no title.

## Usage

``` r
leg2()
```

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `theme_ROC()`, `theme_alluvia()`,
`theme_blank()`, `theme_heat()`, `theme_km`, `theme_legend()`,
`theme_legend1()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() + leg2()

```
