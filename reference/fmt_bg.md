# Add coloured background stripes

Inserts shaded rectangles behind the data layer, one per level of the
categorical axis variable. Factor, character and logical axes,
categorical mapping expressions and data supplied directly to a layer
are supported. Stripes follow the trained scale order, including unused
and missing categories and the local categories of free-scale facets.
Facet expressions and marginal panels are supported without changing the
plot's fill scales or legends. Background bounds are created during
drawing, after position-scale transformations, so log-scaled continuous
axes retain their stripes.

## Usage

``` r
fmt_bg(
  plot,
  palette = NULL,
  palcolor = NULL,
  alpha = 0.3,
  bg_axis = c("x", "y")
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- palette:

  Palette name passed to
  [`plotthis::palette_this`](https://pwwang.github.io/plotthis/reference/palette_this.html).
  Requires plotthis only when palette colours are needed. `NULL` retains
  the default rainbow colours.

- palcolor:

  Manual colour vector (overrides palette). Named vectors match category
  values; unnamed vectors are interpolated to the number of levels. A
  complete manual colour specification does not require plotthis.

- alpha:

  Transparency of the background rectangles.

- bg_axis:

  Which axis holds the categorical variable: `"x"` or `"y"`.

## Value

Same type as input.

## Details

Nested data plots are formatted recursively. Patchwork layouts,
annotations and list names are retained; spacers, guide areas, inset
overlays and fixed wrapped graphics are left unchanged. Format the
original ggplot before wrapping it with
[`patchwork::wrap_elements()`](https://patchwork.data-imaginist.com/reference/wrap_elements.html).

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
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
fmt_bg(p, alpha = 0.2)

```
