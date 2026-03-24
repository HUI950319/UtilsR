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

  Logical or integer vector. \`FALSE\` (default) keeps all x-axes.
  \`TRUE\` hides x-axis for all but the last plot. An integer vector
  specifies which plot indices should have their x-axis hidden.

- y.axis:

  Logical or integer vector. \`FALSE\` (default) keeps all y-axes.
  \`TRUE\` hides y-axis for all but the first plot. An integer vector
  specifies which plot indices should have their y-axis hidden.

- plot_dims:

  Integer vector of length 1 or 2 giving \`c(nrow, ncol)\` of the
  layout. When provided, automatically determines which axes to hide:
  x-axes are hidden for all rows except the last, y-axes for all columns
  except the first.

## Value

Same type as input (ggplot, patchwork, or list).

## See also

Other plot formatting:
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

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
