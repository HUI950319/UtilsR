# Set axis expansion

Applies
[`ggplot2::expansion()`](https://ggplot2.tidyverse.org/reference/expansion.html)
to one or both axes, automatically detecting the correct scale type.
Existing position scales retain their transformation, limits, breaks,
labels, guides and secondary axes. New scales are inferred from
effective layer mappings and their data, including variables captured in
the mapping environment. Function and formula layer data are resolved
during normal plot building, without executing the data function during
formatting. Function-call mappings are also deferred to plot building,
preserving random-number state and avoiding extra mapping calls. Their
errors are reported at build time with the original cause. Nested
patchworks are updated recursively without changing their layout.
Ordinary mapping evaluation errors retain their original cause. Computed
statistic mappings use continuous defaults unless a position scale is
supplied. Repeated calls with unchanged expansion reuse existing
position scales.

## Usage

``` r
fmt_expand(plot, mult = 0, add = c(0, 0), axis = NULL)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- mult:

  Finite numeric expansion factor of length one or two. A scalar applies
  to both ends; two values specify lower and upper expansion.

- add:

  Finite numeric additive expansion of length one or two, with the same
  lower/upper convention as `mult`. Units are days for dates, seconds
  for date-times and times, and transformed scale units for other axes.

- axis:

  A character scalar, `"x"` or `"y"`, or `NULL` for both axes.

## Value

Same type as input.

## See also

Other plot formatting:
[`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md),
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_expand(p, mult = 0.05)

fmt_expand(p, add = c(0.5, 0), axis = "x")

```
