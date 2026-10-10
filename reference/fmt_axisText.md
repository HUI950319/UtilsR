# Format axis text rotation and style

Rotate and style axis tick labels for X and/or Y axes. Inspired by
Seurat's `RotatedAxis()` but with independent control over both axes,
rotation angle, and text appearance.

## Usage

``` r
fmt_axisText(
  plot,
  x = NULL,
  y = NULL,
  x_hjust = NULL,
  x_vjust = NULL,
  y_hjust = NULL,
  y_vjust = NULL,
  size = NULL,
  color = NULL,
  face = NULL,
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects.

- x:

  Numeric. Rotation angle (degrees) for X-axis text. Common values: `45`
  (diagonal), `90` (vertical). Default `NULL` (no change).

- y:

  Numeric. Rotation angle (degrees) for Y-axis text. Default `NULL` (no
  change).

- x_hjust:

  Numeric. Horizontal justification for X-axis text. Can be set without
  supplying `x`. Default `NULL` (auto: 1 when `x > 0`, 0 when `x < 0`,
  0.5 when `x = 0`).

- x_vjust:

  Numeric. Vertical justification for X-axis text. Can be set without
  supplying `x`. Default `NULL` (auto: 0.5 when `abs(x) >= 90`, 1
  otherwise).

- y_hjust:

  Numeric. Horizontal justification for Y-axis text. Can be set without
  supplying `y`. Default `NULL` (auto).

- y_vjust:

  Numeric. Vertical justification for Y-axis text. Can be set without
  supplying `y`. Default `NULL` (auto).

- size:

  Numeric. Text size for both axes. Default `NULL` (no change).

- color:

  Character. Text color for both axes. Default `NULL` (no change).

- face:

  Character. Font face (`"plain"`, `"bold"`, `"italic"`,
  `"bold.italic"`). Default `NULL` (no change).

- ...:

  Additional arguments passed to \[ggplot2::theme()\].

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
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
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()

# Rotate X-axis 45 degrees (like Seurat::RotatedAxis())
fmt_axisText(p, x = 45)


# Rotate X-axis 90 degrees (vertical)
fmt_axisText(p, x = 90)


# Rotate both axes
fmt_axisText(p, x = 45, y = -30)


# With custom size and bold
fmt_axisText(p, x = 45, size = 10, face = "bold")

```
