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

  - height\_ratio:
    
    Fraction of the y-axis range used for the overlay height.

  - data:
    
    Optional data frame. If `NULL`, uses the plot data.

  - con\_var:
    
    Variable name for the x-axis. If `NULL`, extracted from the plot
    mapping.

  - ...:
    
    Additional arguments: `binwidth`, `adjust`, `his_color`,
    `his_alpha`, `y_rescale`, `ylim`.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
fmt_his(p, type = "histogram", height_ratio = 0.3)
fmt_his(p, type = "density", height_ratio = 0.2)
} # }
```
