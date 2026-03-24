# Add reference lines to plots

Add vertical and/or horizontal reference lines to one or more plots.
When multiple intercept values are provided with matching per-line
colors, each line is added individually so that colors are applied
correctly.

## Usage

``` r
fmt_ref(
  plot,
  x = NULL,
  y = NULL,
  linetype = "dashed",
  linewidth = 0.5,
  color = "gray50",
  alpha = 0.8,
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects.

- x:

  Numeric vector of x-intercept values for vertical lines, or \`NULL\`.

- y:

  Numeric vector of y-intercept values for horizontal lines, or
  \`NULL\`.

- linetype:

  Line type. Default \`"dashed"\`.

- linewidth:

  Line width. Default \`0.5\`.

- color:

  Line color(s). Recycled to match the number of intercepts. Default
  \`"gray50"\`.

- alpha:

  Line transparency. Default \`0.8\`.

- ...:

  Additional arguments passed to \[ggplot2::geom_vline()\] or
  \[ggplot2::geom_hline()\].

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_ref(p, x = 5.5, y = 3.0)

fmt_ref(p, x = c(5, 6), color = c("red", "blue"))

```
