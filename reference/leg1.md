# Quick Legend Theme (with title)

Shorthand for \[theme_legend1()\]. Compact legend with white background,
grey border, small text, and bold title.

## Usage

``` r
leg1()
```

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes:
[`leg2()`](https://hui950319.github.io/UtilsR/reference/leg2.md),
[`theme_ROC()`](https://hui950319.github.io/UtilsR/reference/theme_ROC.md),
[`theme_alluvia()`](https://hui950319.github.io/UtilsR/reference/theme_alluvia.md),
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
ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() + leg1()

```
