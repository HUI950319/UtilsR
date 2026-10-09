# Hide or show axis elements for specific plots

Selectively hide axis text, ticks, and titles for plots in a multi-plot
layout. Useful for removing redundant axes when plots share the same
scale.

## Usage

``` r
fmt_axis(plot, x.axis = FALSE, y.axis = FALSE, plot_dims = NULL)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects.

- x.axis:

  Logical scalar or integer vector. \`FALSE\` (default) keeps all
  x-axes. \`TRUE\` hides x-axis for all but the last plot. An integer
  vector specifies which plot indices should have their x-axis hidden.
  Indices must be finite positive integers within the editable plot
  count; duplicates are applied once. \`NULL\` and an empty integer
  vector keep the current axes.

- y.axis:

  Logical scalar or integer vector. \`FALSE\` (default) keeps all
  y-axes. \`TRUE\` hides y-axis for all but the first plot. An integer
  vector specifies which plot indices should have their y-axis hidden.
  Index validation and empty selections follow \`x.axis\`.

- plot_dims:

  Integer vector of length 1 or 2 giving \`c(nrow, ncol)\` of the
  layout. When provided, automatically determines which axes to hide:
  x-axes are hidden for all rows except the last, y-axes for all columns
  except the first. Patchwork positions follow the existing layout,
  including column-major filling, empty cells, nested grids and spanning
  design areas; \`plot_dims\` does not rearrange the plots. Insets do
  not occupy grid cells. Dimensions must be finite positive integers
  with enough cells for the plots. A single value specifies the number
  of rows; columns are inferred. Empty trailing rows do not remove the
  x-axes of the last occupied row. When provided, layout-based selection
  overrides both \`x.axis\` and \`y.axis\`, including one-row and
  one-column layouts. Manual selectors are still validated.

## Value

Same type as input (ggplot, patchwork, or list).

## See also

Other plot formatting:
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
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()

# Hide x-axis on first plot
fmt_axis(list(p1, p2), x.axis = 1)
#> [[1]]

#> 
#> [[2]]

#> 

# Auto-detect 2x1 grid layout
fmt_axis(list(p1, p2), plot_dims = c(2, 1))
#> [[1]]

#> 
#> [[2]]

#> 
```
