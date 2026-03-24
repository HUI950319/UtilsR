# Set axis expansion

Applies
[`ggplot2::expansion()`](https://ggplot2.tidyverse.org/reference/expansion.html)
to one or both axes, automatically detecting the correct scale type.

## Usage

``` r
fmt_expand(plot, mult = 0, add = c(0, 0), axis = NULL)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- mult:

  Multiplicative expansion factor.

- add:

  Additive expansion (length-2 vector for lower/upper).

- axis:

  `"x"`, `"y"`, or `NULL` (both).

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
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
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_expand(p, mult = 0.05)

fmt_expand(p, add = c(0.5, 0), axis = "x")

```
