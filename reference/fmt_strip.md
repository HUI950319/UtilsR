# Add facet strip labels to a plot

Wraps each plot in a single-panel
[`ggh4x::facet_wrap2`](https://teunbrand.github.io/ggh4x/reference/facet_wrap2.html)
so that a coloured strip label appears above the panel.

## Usage

``` r
fmt_strip(plot, label = NULL, label_color = "white", label_fill = NULL)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- label:

  Character vector of strip labels (recycled as needed).

- label_color:

  Text colour(s) for the strip label. Default `"white"`.

- label_fill:

  Background fill colour(s) for the strip. If `NULL`, strips use a
  transparent background.

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
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_strip(p, label = "Iris Data", label_fill = "steelblue")

```
