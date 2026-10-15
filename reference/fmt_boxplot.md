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

  Named list with unique, non-empty names, or `NULL`, of arguments
  passed to
  [`ggplot2::geom_boxplot`](https://ggplot2.tidyverse.org/reference/geom_boxplot.html).
  Defaults include `width = 0.3`, `alpha = 0.2`, `na.rm = TRUE` and
  `outlier.shape = NA`. An explicit `outlier.shape`, including `NULL`,
  is retained. A supplied `mapping` must be created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- inherit.aes:

  A single `TRUE` or `FALSE`: whether to inherit aesthetics from the
  parent plot. Takes precedence over the same argument inside
  `boxplot.args`.

## Value

Same type as input.

## Details

With `inherit.aes = FALSE`, explicit `data` and `mapping` in
`boxplot.args` are retained. Missing data and position mappings are
resolved from the parent plot, then the first suitable existing layer.
Single-axis boxplots are supported. Only x and y mappings are copied
automatically; other mappings must be supplied explicitly. Explicit
`x = NULL` or `y = NULL` mappings remain cleared. Automatic layer lookup
skips text, label, segment, curve and reference-line geoms. Supply
explicit data and mappings to use such sources. An unresolved source
raises an error without restoring aesthetic inheritance. Data functions
and formulas are evaluated only during normal plot building. Nested
patchworks are traversed recursively while preserving layouts,
annotations and plot-list names. Spacers, guide areas, wrapped grobs and
inset overlays are skipped.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
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
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_violin()
fmt_boxplot(p)

fmt_boxplot(p, boxplot.args = list(width = 0.2, alpha = 0.5))

```
