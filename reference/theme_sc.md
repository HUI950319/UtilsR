# Single-Cell Style Theme

A clean ggplot2 theme designed for single-cell analysis plots. Based on
`thisplot::theme_this` from the scop ecosystem, renamed to `theme_sc`.

## Usage

``` r
theme_sc(aspect.ratio = NULL, base_size = 12, ...)
```

## Arguments

- aspect.ratio:

  Aspect ratio of the panel. Default is `NULL`.

- base_size:

  Numeric. Base font size (default 12).

- ...:

  Arguments passed to
  [`theme`](https://ggplot2.tidyverse.org/reference/theme.html).

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes:
[`theme_blank()`](https://hui950319.github.io/UtilsR/reference/theme_blank.md),
[`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md),
[`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md),
[`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
[`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
  geom_point()
p + theme_sc()

```
