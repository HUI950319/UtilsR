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

  - base\_size:
    
    Numeric. Base font size (default 12).

  - ...:
    
    Arguments passed to `theme`.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_heat()`, `theme_km`,
`theme_legend()`, `theme_legend1()`, `theme_my()`, `theme_rcs`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
  geom_point()
p + theme_sc()

```
