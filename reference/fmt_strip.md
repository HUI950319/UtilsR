# Add facet strip labels to a plot

Wraps each plot in a single-panel
[`ggh4x::facet_wrap2`](https://teunbrand.github.io/ggh4x/reference/facet_wrap2.html)
so that a coloured strip label appears above the panel. Strip text is
horizontally and vertically centered. Set `strip = FALSE` to remove
every strip instead.

## Usage

``` r
fmt_strip(
  plot,
  label = NULL,
  label_color = "black",
  label_fill = NULL,
  strip = TRUE
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- label:

  Character vector of strip labels. For one faceted plot, labels are
  recycled across levels of its first facet variable. For multiple
  plots, labels are recycled across plots. `NULL` generates `Figure1`,
  `Figure2`, etc.

- label_color:

  Text colour(s) for the strip label. Default `"black"`.

- label_fill:

  Background fill colour(s) for the strip. If `NULL`, strips use a
  transparent background.

- strip:

  Logical. `TRUE` (default) adds the strip labels. `FALSE` shows no
  strip at all and ignores `label`, `label_color` and `label_fill`:
  strips already on the plot, from an earlier `fmt_strip()` /
  [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  call or from its own facets, are removed. Synthetic facets created by
  this function are dropped; native facets keep their panels with strips
  hidden through the theme, so add complete themes such as
  [`theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  before this call. Nested patchworks are handled recursively.

## Value

Same type as input.

## See also

Other plot formatting:
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
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_strip(p, label = "Iris Data", label_fill = "steelblue")


# strip = FALSE removes every strip but keeps the facet panels
p_facet <- p + facet_wrap(vars(Species))
fmt_strip(p_facet, strip = FALSE)

```
