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

Other ggplot2 themes:
[`theme_blank()`](https://hui950319.github.io/UtilsR/reference/theme_blank.md),
[`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md),
[`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
[`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md),
[`theme_sc()`](https://hui950319.github.io/UtilsR/reference/theme_sc.md)

## Examples

``` r
library(ggplot2)
ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() +
  theme_legend1()

```
