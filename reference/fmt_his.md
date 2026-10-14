# Add marginal histogram or density overlay

Overlays a rescaled histogram or density curve on the existing plot,
using the x-axis variable (or a user-supplied variable).

## Usage

``` r
fmt_his(
  plot,
  type = c("histogram", "density", "h", "d"),
  height_ratio = 0.3,
  data = NULL,
  con_var = NULL,
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- type:

  `"histogram"` (or `"h"`) or `"density"` (or `"d"`).

- height_ratio:

  Finite number from 0 to 1 giving the fraction of each visible panel's
  y-axis range used for the overlay height. Default: 0.3.

- data:

  Optional data frame, layer data function or formula. If `NULL`, uses
  the plot data or the first applicable layer's data. With standard
  ggplot2 facets, missing facet columns repeat samples across applicable
  panels; new facet values can add panels, as for other layers.

- con_var:

  Optional single column name overriding the x mapping. If `NULL`,
  retains the plot's x-mapping expression, falling back to the first
  applicable layer mapping.

- ...:

  Named overlay controls. Unknown, unnamed or duplicate arguments are
  rejected. `NULL` retains the default for each control.

  `binwidth`

  :   Positive finite bin width or a function, as in
      [`ggplot2::geom_histogram()`](https://ggplot2.tidyverse.org/reference/geom_histogram.html).
      Default: 3. Histogram only; measured after the x-scale
      transformation.

  `adjust`

  :   Positive finite density bandwidth multiplier. Default: 3. Density
      only.

  `his_color`

  :   Single colour or `NA`. Default: `"gray85"`.

  `his_alpha`

  :   Finite opacity from 0 to 1. Default: 0.5.

  `y_rescale`

  :   Two finite values giving the baseline and peak in original y-data
      units. Default: the panel bottom and `height_ratio` above it in
      transformed display coordinates.

  `ylim`

  :   Two y-coordinate limits in original data units. `NA` endpoints
      remain automatic. Default: original limits; original coordinate
      type, expansion, clipping and aspect ratio are retained.

## Value

Same type as input.

## Details

Counts and densities are scaled from statistical zero, preserving their
relative heights. The fill starts at the requested baseline. Each facet
is scaled independently; distribution layers do not retrain the original
position scales or inherit grouping, weights or legends. Cartesian
coordinates, including flipped and fixed-ratio coordinates, are
supported. Other coordinate systems are rejected, including when added
after formatting. The default baseline follows the display bottom under
coordinate reversal; explicit `y_rescale` retains its endpoint order.
Nested patchwork layouts and annotations are preserved; spacers, wrapped
grobs and inset overlays are skipped. Repeated calls add additional
distribution layers. Mapping expressions and data callbacks are
evaluated during the normal plot build; formatting does not build or
refit the original plot. Each distribution layer evaluates its x mapping
once per build. Facets and individual facet position scales can be added
after formatting. Density panels with fewer than two finite samples
retain ggplot2's warning and are omitted; empty distribution layers
leave the original plot intact.

## See also

Other plot formatting:
[`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md),
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
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
set.seed(1)
d <- data.frame(x = rnorm(100), y = rnorm(100))
p <- ggplot(d, aes(x, y)) + geom_point()
fmt_his(p, type = "histogram", height_ratio = 0.3, binwidth = 0.5)

fmt_his(p, type = "density", height_ratio = 0.2, adjust = 1)

d$panel <- rep(c("A", "B"), each = 50)
p <- ggplot(d, aes(x, y)) + geom_point()
fmt_his(p, type = "density", adjust = 1) + facet_wrap(~panel, scales = "free")

```
