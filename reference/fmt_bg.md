# Add coloured background stripes

Inserts shaded rectangles behind the data layer, one per level of the
categorical axis variable.

## Usage

``` r
fmt_bg(
  plot,
  palette = NULL,
  palcolor = NULL,
  alpha = 0.3,
  bg_axis = c("x", "y")
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- palette:

  Palette name passed to
  [`plotthis::palette_this`](https://pwwang.github.io/plotthis/reference/palette_this.html).

- palcolor:

  Manual colour vector (overrides palette).

- alpha:

  Transparency of the background rectangles.

- bg_axis:

  Which axis holds the categorical variable: `"x"` or `"y"`.

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()
fmt_bg(p, alpha = 0.2)

```
