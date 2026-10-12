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
  non-empty list of length-2 category-value vectors. Pairs must contain
  distinct observed values; reversed duplicate pairs are rejected.
  Values select categories rather than numeric axis indices.

- label.y:

  Numeric bracket positions in original y-data units, before scale
  transformation. A scalar sets the first bracket; a vector sets
  individual positions in comparison-family order. Custom vectors follow
  `com_method` order within each mapped subset; automatic vectors follow
  displayed global pairs, appending extra sparse-panel pairs. Filtering
  a panel retains the matching entries. Default `NULL` uses automatic
  positions.

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

  Fraction of panel height for tips: a scalar, one value per comparison,
  or two values per comparison in left/right order. Default `0.025`.

- step.increase:

  Vertical step as a fraction of panel height: a scalar or one value per
  comparison. Default `0.05`. Not added to explicit position vectors.

- size:

  Line width of the brackets. Default `0.8`.

- ...:

  Named arguments passed to
  [`ggpubr::geom_pwc`](https://rpkgs.datanovia.com/ggpubr/reference/geom_pwc.html),
  overriding formatting defaults. `method.args` may contain test options
  such as `paired` or `alternative`; select pairs with `com_method`, not
  `method.args$comparisons`. Paired tests retain original observation
  order and jointly omit incomplete pairs. Original group sizes must
  match for order-based pairing. Supply
  `method.args = list(paired = TRUE, id = "subject")` to match a data
  column independently within each pair; IDs must be non-missing and
  unique within each comparison group/subset. One-sided custom pairs
  test the first group against the second. Reference comparisons test
  the reference against the other group; automatic pairs use the
  original mapped group order for direction, independently of axis
  display order. By default, inherited trajectory grouping is ignored
  and x groups are compared. Set `group.by = "x.var"` to compare mapped
  groups within each x value, or `group.by = "legend.var"` to compare x
  values within each mapped group. An explicit
  `mapping = aes(group = ...)` also enables grouped comparisons.
  `com_method` selects the corresponding comparison variable, with
  consecutive pairs resolved within each subset. When `ref.group` is
  supplied, it selects reference comparisons instead of automatic
  consecutive/all pairs; it cannot be combined with a custom
  `com_method` list. Names and displayed ranks are accepted, and
  `ref.group = "all"` compares each group against the pooled
  observations. Dunn, Tukey and Games-Howell methods compute their full
  comparison family before display filtering, retaining that family's
  adjustment. Methods returning only adjusted P values use adjusted
  significance stars.

## Value

Same type as input.

## Details

A categorical x axis and numeric y outcome are required. Statistical
data and mapping can be supplied explicitly through `...`; otherwise a
complete plot-level source is used, then an unambiguous layer-level
source. Multiple different layer sources require explicit `data` and
`mapping`. Statistical data must be a data frame; callbacks and
after-stat mappings are not supported. Missing panel-specific pairs are
skipped. The backend evaluates tests on the layer data during plot
building; scale transformations and scale limits affect the observations
it receives.

## See also

Other plot formatting:
[`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md),
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


# Display adjusted significance stars
fmt_com(p, label = "p.adj.signif", p.adjust.method = "bonferroni")


# Adjust bracket y-position (absolute y-axis value, not proportion)
fmt_com(p, label.y = 8)

fmt_com(p + scale_y_log10(), label.y = 8)

```
