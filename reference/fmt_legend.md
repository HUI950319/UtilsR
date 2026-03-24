# Format legend position and style

Adjust legend position, direction, layout, and optionally merge legends
across a multi-plot patchwork.

## Usage

``` r
fmt_legend(
  plot,
  legend.position = NULL,
  legend.direction = NULL,
  merge_legends = FALSE,
  ncol = NULL,
  nrow = NULL,
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot objects.

- legend.position:

  Legend position. Either a character string (\`"top"\`, \`"bottom"\`,
  \`"left"\`, \`"right"\`, \`"none"\`) or a numeric vector of length 2
  for coordinates inside the plot. Default \`NULL\` (no change).

- legend.direction:

  \`"horizontal"\` or \`"vertical"\`. Default \`NULL\`.

- merge_legends:

  Logical. If \`TRUE\` and input has multiple plots, collect legends
  into a single shared legend via patchwork. Default \`FALSE\`.

- ncol:

  Number of columns in the legend layout.

- nrow:

  Number of rows in the legend layout.

- ...:

  Additional arguments passed to \[ggplot2::theme()\].

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()

fmt_legend(p, legend.position = "bottom", legend.direction = "horizontal")

fmt_legend(p, legend.position = "none")

```
