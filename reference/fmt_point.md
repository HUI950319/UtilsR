# Add Data Points to a Plot

Unified function to overlay data points on ggplot objects. Supports
plain points, jittered points, and beeswarm layout. Automatically
detects group aesthetics to apply dodge positioning.

## Usage

``` r
fmt_point(
  plot,
  type = c("point", "jitter", "beeswarm"),
  data = NULL,
  shape = 19,
  size = 1,
  white_border = FALSE,
  dodge.width = 0.8,
  jitter.args = list(width = 0.2, height = 0),
  beeswarm.args = list(cex = 3, corral = "wrap", corral.width = 0.5),
  sample_n = NULL,
  seed = 42,
  rasterize = FALSE,
  rasterize.dpi = 300,
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects.

- type:

  Point layout type: `"point"` (default), `"jitter"`, or `"beeswarm"`.

- data:

  Data for the point layer. Default `NULL` inherits from plot. Can be a
  data.frame or a function/formula applied to the plot data (e.g.
  `~ subset(.x, value > 10)`). Functions and formulas are evaluated at
  plot build time, before optional sampling.

- shape:

  Point shape. Default 19 (solid circle). Omitted values preserve mapped
  shapes; explicitly supplied values override mappings.

- size:

  Point size. Default 1. Omitted values preserve mapped sizes;
  explicitly supplied values override mappings.

- white_border:

  Logical. If `TRUE`, converts shapes to fillable versions (21-25) with
  white stroke, retaining scaled colours as fills. Other symbols retain
  their shape and colour over a white underlay. Default `FALSE`.

- dodge.width:

  Dodge width for grouped data. Default 0.8. Set to 0 to disable
  dodging.

- jitter.args:

  Named list of jitter arguments. Only used when `type = "jitter"`.
  Defaults: `list(width = 0.2, height = 0)`. Width and height must be
  non-negative numbers or `NULL` for native ggplot2 defaults.

- beeswarm.args:

  Named list of beeswarm arguments. Only used when `type = "beeswarm"`.
  Defaults: `list(cex = 3, corral = "wrap", corral.width = 0.5)`. Also
  accepts `method`, `side`, `priority`, `fast`, `orientation`,
  `groupOnX`, `preserve.data.axis`, and `beeswarmArgs` when supported by
  ggbeeswarm. Values override the same arguments in `...`; use
  `dodge.width` to control dodging.

- sample_n:

  Non-negative integer or `NULL`. When set, subsample data before
  plotting to reduce overplotting. An explicit `group` mapping takes
  priority over discrete color/fill mappings, including expressions.
  Sampling takes at most `sample_n` points **per group**; missing group
  values form a separate group. Continuous color/fill mappings do not
  define sampling groups. Sampling requires scalar fixed aesthetics; put
  external row vectors into `data` and map its columns instead. Default
  `NULL` (no sampling).

- seed:

  Random seed for reproducible sampling. Default 42. Sampling preserves
  the caller's random-number state.

- rasterize:

  Logical. If `TRUE`, rasterizes the point layer via
  [`ggrastr::rasterise`](https://rdrr.io/pkg/ggrastr/man/rasterise.html)
  for large datasets. Default `FALSE`.

- rasterize.dpi:

  Integer, DPI for rasterization. Default 300.

- ...:

  Additional arguments passed to `geom_point` or `geom_beeswarm`.

## Value

Same type as input (ggplot, patchwork, or list).

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

# Plain points
fmt_point(p, color = "steelblue", alpha = 0.5)


# Jittered points
fmt_point(p, type = "jitter", color = "red", alpha = 0.5)


# Custom jitter width
fmt_point(p, type = "jitter", jitter.args = list(width = 0.4), alpha = 0.5)


# Beeswarm
fmt_point(p, type = "beeswarm", color = "darkgreen", size = 1.2)


# White border effect
fmt_point(p, type = "jitter", fill = "purple",
          white_border = TRUE, size = 2)


# Grouped data (auto-dodge)
p2 <- ggplot(iris, aes(Species, Sepal.Length, color = Species)) +
  geom_boxplot()
fmt_point(p2, type = "jitter", alpha = 0.5)


# Subsample when too many points
fmt_point(p, type = "jitter", sample_n = 20, alpha = 0.5)


# Stratified sampling (per group)
fmt_point(p2, type = "jitter", sample_n = 10, alpha = 0.5)

```
