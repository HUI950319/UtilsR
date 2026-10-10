# Add coloured background stripes

Inserts shaded rectangles behind the data layer, one per level of the
categorical axis variable, including in faceted and combined plots.

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
  values, with unmatched categories using the palette. Unnamed vectors
  are interpolated to the number of levels. A complete manual colour
  specification does not require plotthis.

- alpha:

  A finite numeric value from 0 to 1 giving the opacity of the
  background rectangles. Zero returns the input unchanged.

- bg_axis:

  Which axis holds the categorical variable: `"x"` or `"y"`.

## Value

Same type as input.

## Details

Factor, character and logical axes, categorical mapping expressions and
layer data supplied as data frames, functions or formulas are supported.
The first applicable categorical layer mapping is used; numeric
annotation positions are skipped. Continuous axes are skipped with a
warning. Mapping expressions, including
[`ggplot2::after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html),
and data callbacks are evaluated only by ggplot during rendering. For
these mappings, categorical-axis checks and palette resolution are
deferred until drawing.

Stripes follow the trained scale order, including unused categories and
the local categories of free-scale facets. Category colours are shared
across panels, including categories contributed by later layers. Missing
categories use `"grey80"`. Facet expressions, marginal panels, flipped
and polar coordinates, radial bands and log-scaled continuous axes are
supported. Backgrounds retain the plot's panel ranges, fill scales and
legends.

Nested data plots are formatted recursively. Patchwork layouts,
annotations and list names are retained; spacers, guide areas, inset
overlays and fixed wrapped graphics are left unchanged. Format the
original ggplot before wrapping it with
[`patchwork::wrap_elements()`](https://patchwork.data-imaginist.com/reference/wrap_elements.html).
Repeated calls replace this function's background layer while retaining
all other layers, so transparency does not accumulate. Direct column
mappings with empty or entirely missing categories are returned
unchanged; deferred mappings with no categories draw no background.

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
set.seed(123)
dat <- data.frame(category = factor(rep(c("A", "B", "C"), each = 8)),
                  value = rnorm(24))
p <- ggplot(dat, aes(category, value)) + geom_boxplot()
fmt_bg(p, alpha = 0.2)

fmt_bg(p + scale_x_discrete(limits = c("C", "B", "A")),
       palcolor = c(A = "#E64B35", B = "#4DBBD5", C = "#00A087"))

```
