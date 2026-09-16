# Format axis text rotation and style

Rotate and style axis tick labels for X and/or Y axes. Inspired by
Seurat's `RotatedAxis()` but with independent control over both axes,
rotation angle, and text appearance.

## Usage

``` r
fmt_axisText(
  plot,
  x = NULL,
  y = NULL,
  x_hjust = NULL,
  x_vjust = NULL,
  y_hjust = NULL,
  y_vjust = NULL,
  size = NULL,
  color = NULL,
  face = NULL,
  ...
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplot objects.

  - x:
    
    Numeric. Rotation angle (degrees) for X-axis text. Common values:
    `45` (diagonal), `90` (vertical). Default `NULL` (no change).

  - y:
    
    Numeric. Rotation angle (degrees) for Y-axis text. Default `NULL`
    (no change).

  - x\_hjust:
    
    Numeric. Horizontal justification for X-axis text. Default `NULL`
    (auto: 1 when `x > 0`, 0 when `x < 0`, 0.5 when `x = 0`).

  - x\_vjust:
    
    Numeric. Vertical justification for X-axis text. Default `NULL`
    (auto: 0.5 when `abs(x) >= 90`, 1 otherwise).

  - y\_hjust:
    
    Numeric. Horizontal justification for Y-axis text. Default `NULL`
    (auto).

  - y\_vjust:
    
    Numeric. Vertical justification for Y-axis text. Default `NULL`
    (auto).

  - size:
    
    Numeric. Text size for both axes. Default `NULL` (no change).

  - color:
    
    Character. Text color for both axes. Default `NULL` (no change).

  - face:
    
    Character. Font face (`"plain"`, `"bold"`, `"italic"`,
    `"bold.italic"`). Default `NULL` (no change).

  - ...:
    
    Additional arguments passed to \[ggplot2::theme()\].

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisTile()`, `fmt_bg()`,
`fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()

# Rotate X-axis 45 degrees (like Seurat::RotatedAxis())
fmt_axisText(p, x = 45)


# Rotate X-axis 90 degrees (vertical)
fmt_axisText(p, x = 90)


# Rotate both axes
fmt_axisText(p, x = 45, y = -30)


# With custom size and bold
fmt_axisText(p, x = 45, size = 10, face = "bold")

```
