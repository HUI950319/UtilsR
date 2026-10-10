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

  Finite numeric scalar. Rotation angle (degrees) for X-axis text.
  Common values: `45` (diagonal), `90` (vertical). Default `NULL` (no
  change).

- y:

  Finite numeric scalar. Rotation angle (degrees) for Y-axis text.
  Default `NULL` (no change).

- x_hjust:

  Finite numeric scalar. Horizontal justification for X-axis text. Can
  be set without supplying `x`. Default `NULL`: automatic alignment
  follows the bottom or top axis side when `x` is supplied; otherwise
  the existing alignment is retained.

- x_vjust:

  Finite numeric scalar. Vertical justification for X-axis text. Can be
  set without supplying `x`. Default `NULL`: automatic alignment follows
  the bottom or top axis side when `x` is supplied; otherwise the
  existing alignment is retained.

- y_hjust:

  Finite numeric scalar. Horizontal justification for Y-axis text. Can
  be set without supplying `y`. Default `NULL`: automatic alignment
  follows the left or right axis side when `y` is supplied; otherwise
  the existing alignment is retained.

- y_vjust:

  Finite numeric scalar. Vertical justification for Y-axis text. Can be
  set without supplying `y`. Default `NULL`: automatic alignment follows
  the left or right axis side when `y` is supplied; otherwise the
  existing alignment is retained.

- size:

  Non-negative finite numeric scalar. Text size in points for both axes,
  or
  [`ggplot2::rel()`](https://ggplot2.tidyverse.org/reference/element.html)
  relative to the parent axis text size. Default `NULL` (no change).

- color:

  One valid R color or numeric palette index for both axes. `NA` makes
  text transparent. Default `NULL` (no change).

- face:

  Character. Font face (`"plain"`, `"bold"`, `"italic"`, `"oblique"`,
  `"bold.italic"`). Default `NULL` (no change).

- ...:

  Additional arguments passed to
  [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html),
  applied after the generated formatting. Explicit axis text fields in
  these arguments take precedence; side-specific fields take precedence
  over their parent.

## Value

Same type as input.

## Details

Data plots are edited recursively within nested patchworks and lists.
Layouts, annotations, list names and freed alignment are retained.
Spacers, guide areas, fixed wrapped graphics and inset overlays are not
edited. Styling also updates explicitly styled axis sides and radial
text elements. Explicitly blank side elements are retained. Guide-local
themes and rotation settings are updated without modifying the original
guides or their other settings. With justification alone, an existing
guide rotation is retained. Guide formatting retains text classes
inherited from the plot theme. Existing text element classes, including
rich text elements, are retained. Text inherited from the global theme
is retained unless a complete plot theme overrides it. Automatic
Cartesian alignment follows each rendered axis side and treats full
turns periodically. Explicit justification takes precedence.
Justification values may lie outside the usual 0–1 interval. When every
formatting argument is `NULL` and `...` is empty, the validated input
object is returned unchanged without evaluating plot data.

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
dat <- data.frame(
  category = factor(rep(c("Alpha", "Beta", "Gamma"), each = 3)),
  value = c(2, 3, 4, 4, 5, 6, 1, 2, 3)
)
p <- ggplot(dat, aes(category, value)) + geom_boxplot()

# Rotate X-axis 45 degrees (like Seurat::RotatedAxis())
fmt_axisText(p, x = 45)


# Rotate X-axis 90 degrees (vertical)
fmt_axisText(p, x = 90)


# Rotate both axes
fmt_axisText(p, x = 45, y = -30)


# With custom size and bold
fmt_axisText(p, x = 45, size = 10, face = "bold")


# Adjust justification while retaining the existing angle
fmt_axisText(p, x_hjust = 0.2)


# Preserve a nested layout and named list
nested <- patchwork::wrap_plots(p, p, nrow = 1)
fmt_axisText(list(main = nested, detail = p), x = 45)
#> $main

#> 
#> $detail

#> 
```
