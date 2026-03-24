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

  Fraction of the y-axis range used for the overlay height.

- data:

  Optional data frame. If `NULL`, uses the plot data.

- con_var:

  Variable name for the x-axis. If `NULL`, extracted from the plot
  mapping.

- ...:

  Additional arguments: `binwidth`, `adjust`, `his_color`, `his_alpha`,
  `y_rescale`, `ylim`.

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_his(p, type = "histogram", height_ratio = 0.3)
fmt_his(p, type = "density", height_ratio = 0.2)
} # }
```
