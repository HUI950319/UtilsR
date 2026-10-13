# Set axis scales

Automatically detects discrete / continuous / date-time scale type from
existing scales or effective layer mappings and data, and applies
user-supplied arguments via `do.call`.

## Usage

``` r
fmt_scale(plot, x = NULL, y = NULL)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- x:

  Named list of arguments accepted by the selected ggplot2 x-axis scale
  function. Names must be unique, non-empty and non-missing; unambiguous
  partial names are matched to full argument names. Across repeated
  calls, the most recent value of a matched argument wins; `trans` and
  `transform` refer to the same setting. For example,
  `list(limits = c(4, 8), breaks = seq(4, 8, 1))`. `NULL` or
  [`list()`](https://rdrr.io/r/base/list.html) leaves the axis
  unchanged. Explicit `NULL` child values are passed to the scale
  constructor.

- y:

  Like `x`, for the y-axis scale function.

## Value

Same type as input.

## Details

When the axis already has a position scale, only the supplied settings
are updated: its limits, breaks, labels, transformation, expansion,
guide and secondary axis are kept unless named in the list. Continuous
limits are interpreted on the existing transformation; when only
`transform` is supplied, existing limits are re-expressed on the new
one. Without an existing scale, a new scale of the detected type is
added. Partially automatic limits retain the same observations when
changing between increasing and decreasing transformations.

Existing binned position scales accept their own controls, including
`right`, `nice.breaks` and `show.limits`. Nested patchworks are updated
recursively without changing their layout or annotations.

Function and formula layer data are resolved during normal plot
building; formatting does not execute the data function. Function-call
mappings and active or lazy mapping bindings are also evaluated during
normal building, preserving their evaluation order and random-number
state. Mapping errors are reported during building with their original
cause. Scale settings are then applied to the actual scale type. A scale
added explicitly afterward takes precedence over deferred settings.
Repeated calls reuse unchanged scales and retain custom scale classes
and clone behavior when settings change. When combined with
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
deferred settings are retained; the most recent explicit expansion
setting takes precedence. Axes computed by statistics, including
statistic default mappings, use their native scale type before
formatting settings are applied.

Scale construction errors keep their original cause and identify the
axis. Limits are scale limits and can remove out-of-range observations;
use
[`ggplot2::coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)
when only a visual zoom is needed.

## See also

Other plot formatting:
[`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md),
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
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_scale(p, x = list(limits = c(4, 8), breaks = seq(4, 8, 1)))

fmt_scale(p, y = list(labels = scales::label_percent()))


# Existing breaks and limits are kept when only labels change
p2 <- p + scale_x_continuous(limits = c(4, 8), breaks = 4:8)
fmt_scale(p2, x = list(labels = function(x) paste0(x, " cm")))

```
