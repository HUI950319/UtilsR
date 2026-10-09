# Hide axis elements for specific plots

Selectively hide axis text, ticks, and titles for plots in a multi-plot
layout. Useful for removing redundant axes when plots share the same
scale.

## Usage

``` r
fmt_axis(plot, x.axis = FALSE, y.axis = FALSE, plot_dims = NULL)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects. Editable plots are
  numbered recursively in their input order. Spacers, guide areas, inset
  overlays and fixed wrapped graphics do not consume indices. Format the
  original ggplot before using
  [`patchwork::wrap_elements()`](https://patchwork.data-imaginist.com/reference/wrap_elements.html)
  to hide its axes.

- x.axis:

  Logical scalar or integer vector. \`FALSE\` (default) keeps the
  current x-axes; it does not restore previously hidden elements.
  \`TRUE\` hides the x-axis of a single plot, or all but the last
  editable plot in a container. An integer vector specifies which plot
  indices should have their x-axis hidden. Indices must be finite
  positive integers within the editable plot count; duplicates are
  applied once. \`NULL\` and an empty integer vector keep the current
  axes.

- y.axis:

  Logical scalar or integer vector. \`FALSE\` (default) keeps the
  current y-axes. \`TRUE\` hides the y-axis of a single plot, or all but
  the first editable plot in a container. An integer vector specifies
  which plot indices should have their y-axis hidden. Index validation
  and empty selections follow \`x.axis\`.

- plot_dims:

  Integer vector of length 1 or 2 giving \`c(nrow, ncol)\` of the
  layout. When provided, automatically determines which axes to hide:
  x-axes are hidden for all rows except the last, y-axes for all columns
  except the first. Patchwork positions follow the existing layout,
  including column-major filling, empty cells, nested grids and spanning
  design areas; \`plot_dims\` does not rearrange the plots. Insets do
  not occupy grid cells. Lists retain cells occupied by spacers, guide
  areas and fixed graphics, and nested containers retain their own
  layout. Dimensions must be finite positive integers with enough cells
  for the editable plots in a patchwork, or for the top-level grid
  entries in a list. A single value specifies the number of rows;
  columns are inferred. Empty trailing rows do not remove the x-axes of
  the last occupied row. When provided, layout-based selection overrides
  both \`x.axis\` and \`y.axis\`, including one-row and one-column
  layouts. Manual selectors are still validated.

## Value

Same type as input (ggplot, patchwork, or list), with list names,
patchwork layout and annotations retained. Empty selections return the
input.

## Details

Hiding applies to axis text, major/minor ticks and titles on both sides,
including secondary axes and guide-local themes. Guide settings
unrelated to hiding are retained, and input guide objects are not
modified. For
[`ggplot2::coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_radial.html),
\`x.axis\` controls the angular (theta) axis and \`y.axis\` the radius
(r) axis, following ggplot2 theme inheritance regardless of the variable
mapped to theta. Axis lines, data, scales, coordinates and facet
structure are retained. The function does not verify or synchronize
scales between plots; use automatic selection only for axes that can be
meaningfully shared. Selections operate on whole plots, including all
facets.

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
[`fmt_point`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
data <- data.frame(x = rep(1:5, 2), y = c(1, 3, 2, 4, 3, 2, 4, 3, 5, 4),
                   group = rep(c("A", "B"), each = 5))
p1 <- ggplot(data, aes(x, y, colour = group)) + geom_point()
p2 <- ggplot(data, aes(x, y, colour = group)) + geom_line()

# Hide the x-axis of a single plot
fmt_axis(p1, x.axis = TRUE)


# Hide x-axis on first plot
fmt_axis(list(p1, p2), x.axis = 1)
#> [[1]]

#> 
#> [[2]]

#> 

# Keep only the bottom row's x-axis in a two-row layout
fmt_axis(list(p1, p2), plot_dims = c(2, 1))
#> [[1]]

#> 
#> [[2]]

#> 

# Follow the actual column-major patchwork layout
combined <- patchwork::wrap_plots(p1, p2, p1, p2, nrow = 2, byrow = FALSE)
fmt_axis(combined, plot_dims = c(2, 2))

```
