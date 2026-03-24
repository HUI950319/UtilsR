# Overlay a boxplot layer

Adds `geom_boxplot` on top of existing layers (e.g. violin, jitter).
Outliers are suppressed by default.

## Usage

``` r
fmt_boxplot(plot, boxplot.args = list(), inherit.aes = TRUE)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- boxplot.args:

  Named list of arguments passed to
  [`ggplot2::geom_boxplot`](https://ggplot2.tidyverse.org/reference/geom_boxplot.html).
  Defaults include `width = 0.3`, `alpha = 0.2`, `na.rm = TRUE`.

- inherit.aes:

  Whether to inherit aesthetics from the parent plot.

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
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
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_violin()
fmt_boxplot(p)

fmt_boxplot(p, boxplot.args = list(width = 0.2, alpha = 0.5))

```
