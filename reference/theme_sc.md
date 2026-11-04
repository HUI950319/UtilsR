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
  [`theme`](https://ggplot2.tidyverse.org/reference/theme.html),
  including registered extension theme elements. Named elements override
  the defaults supplied by this function. Arguments in `...` support
  dynamic dots.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes:
[`leg1()`](https://hui950319.github.io/UtilsR/reference/leg1.md),
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
[`theme_scatter`](https://hui950319.github.io/UtilsR/reference/theme_scatter.md)

## Examples

``` r
library(ggplot2)
set.seed(1)
d <- data.frame(x = rnorm(40), y = rnorm(40),
                batch = rep(c("A", "B"), each = 20),
                group = rep(c("C", "D"), 20))
p <- ggplot(d, aes(x, y, colour = group)) +
  geom_point()
p + theme_sc()

p + ggh4x::facet_nested(~ batch + group, nest_line = TRUE) +
  theme_sc(ggh4x.facet.nestline = element_line(colour = "steelblue"))

```
