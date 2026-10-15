# Add reference lines to plots

Add vertical and/or horizontal reference lines to one or more plots.
Styles are recycled separately for each direction. Multiple lines share
a layer unless additional geom arguments require the original per-line
behaviour.

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

  Vector of x-intercept values compatible with the plot's x scale,
  including numeric values, dates or discrete category labels. `NULL` or
  an empty vector adds no vertical lines.

- y:

  Vector of y-intercept values compatible with the plot's y scale.
  `NULL` or an empty vector adds no horizontal lines.

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

  Additional arguments passed to
  [`geom_vline()`](https://ggplot2.tidyverse.org/reference/geom_abline.html)
  or
  [`geom_hline()`](https://ggplot2.tidyverse.org/reference/geom_abline.html).
  Supply positions with `x` and `y`; `xintercept` and `yintercept` are
  rejected. Use `color` for line colors; `colour` is rejected to prevent
  conflicting color settings.

## Value

Same type as input.

## Details

When positions are supplied, `linetype`, `linewidth`, `color` and
`alpha` must be non-empty vectors. Missing style values retain their
native ggplot2 meaning.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_ref(p, x = 5.5, y = 3.0)

fmt_ref(p, x = c(5, 6), color = c("red", "blue"))

```
