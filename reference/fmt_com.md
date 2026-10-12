# Add pairwise statistical comparisons

Uses
[`ggpubr::geom_pwc`](https://rpkgs.datanovia.com/ggpubr/reference/geom_pwc.html)
to overlay significance brackets. Comparisons follow displayed x-axis
order and use observed groups in each panel. Custom groups without
observations are rejected; pairs absent from an individual facet panel
are skipped.

## Usage

``` r
fmt_com(
  plot,
  com_method = "con",
  label.y = NULL,
  label.y.prop = NULL,
  label = c("p.signif", "{p.format}{p.signif}", "p.format"),
  tip.length = 0.025,
  step.increase = 0.05,
  size = 0.8,
  ...
)
```

## Arguments

- plot:

  A ggplot, nested patchwork, or list of ggplots/patchworks. Layouts,
  annotations and list names are retained. Spacers, guide areas, insets
  and frozen wrapped graphics are left unchanged.

- com_method:

  Comparison method: `"con"` (consecutive), `"all"` (all pairs), or a
  list of length-2 character vectors.

- label.y:

  Numeric bracket positions in original y-data units, before scale
  transformation. A scalar sets the first bracket; a vector sets
  individual positions. Default `NULL` lets ggpubr auto-calculate.

- label.y.prop:

  Numeric proportion (0-1) of each panel's transformed y-axis data range
  for the first bracket. E.g., `0.9` is 90% along the displayed range,
  including log scales and free-y facets. Ignored when `label.y` is
  provided. Explicit positions have no default nudge; `bracket.nudge.y`
  in `...` adds an optional offset.

- label:

  A ggpubr result column or glue template, such as `"p.signif"`,
  `"p.adj.signif"`, `"p.adj.format"`, or `"\{p.format\}\{p.signif\}"`.
  The default displays raw P-value stars; select an adjusted label to
  display multiplicity-adjusted results.

- tip.length:

  Length of the bracket tips. Default `0.025`.

- step.increase:

  Vertical step increase between brackets. Default `0.05`.

- size:

  Line width of the brackets. Default `0.8`.

- ...:

  Named arguments passed to
  [`ggpubr::geom_pwc`](https://rpkgs.datanovia.com/ggpubr/reference/geom_pwc.html),
  overriding formatting defaults. `method.args` may contain test options
  such as `paired` or `alternative`; select pairs with `com_method`, not
  `method.args$comparisons`. Pairing follows observation order within
  each comparison group, so align paired observations before plotting.
  By default, inherited trajectory grouping is ignored and x groups are
  compared. Set `group.by = "x.var"` to compare mapped groups within
  each x value, or `group.by = "legend.var"` to compare x values within
  each mapped group. An explicit `mapping = aes(group = ...)` also
  enables grouped comparisons. `com_method` selects the corresponding
  comparison variable, with consecutive pairs resolved within each
  subset. Dunn, Tukey and Games-Howell methods compute their full
  comparison family before display filtering, retaining that family's
  adjustment. Methods returning only adjusted P values use adjusted
  significance stars.

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
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
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()

# Consecutive comparisons (default)
fmt_com(p)


# All pairwise comparisons
fmt_com(p, com_method = "all")


# Custom comparisons
fmt_com(p, com_method = list(c("setosa", "virginica"), c("setosa", "versicolor")))


# Show p-value instead of stars
fmt_com(p, label = "p.format")


# Show both p-value and stars
fmt_com(p, label = "{p.format}{p.signif}")


# Adjust bracket y-position (absolute y-axis value, not proportion)
fmt_com(p, label.y = 8)

```
