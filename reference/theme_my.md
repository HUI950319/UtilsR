# Custom ggplot2 Theme Based on ggprism

A customizable ggplot2 theme built on top of `ggprism` palettes, with
additional control over grid lines, panel spacing, plot margins, and
axis text angle.

## Usage

``` r
theme_my(
  palette = "black_and_white",
  base_size = 14,
  base_family = "sans",
  base_fontface = "bold",
  base_line_size = base_size/14,
  base_rect_size = base_size/14,
  axis_text_angle = 0,
  border = TRUE,
  legend.position = "right",
  panel.grid = element_line(color = "lightgray", linetype = "dashed", linewidth = 0.1),
  panel.grid.minor = element_line(color = "lightgray", linetype = "dashed", linewidth =
    0.1),
  panel.spacing = unit(0, "pt"),
  plot.margin = NULL
)
```

## Arguments

  - palette:
    
    Character. A valid ggprism palette name (e.g. `"black_and_white"`,
    `"office"`). See `names(ggprism::ggprism_data$themes)`.

  - base\_size:
    
    Numeric. Base font size (default 14).

  - base\_family:
    
    Character. Base font family (default `"sans"`).

  - base\_fontface:
    
    Character. Base font face (default `"bold"`).

  - base\_line\_size:
    
    Numeric. Base line size.

  - base\_rect\_size:
    
    Numeric. Base rect size.

  - axis\_text\_angle:
    
    Numeric. Axis text rotation angle. Must be one of 0, 45, 90, 270.

  - border:
    
    Logical. Whether to draw panel border (default `TRUE`).

  - legend.position:
    
    Legend position (default `"right"`).

  - panel.grid:
    
    A `ggplot2::element_line` for major grid lines.

  - panel.grid.minor:
    
    A `ggplot2::element_line` for minor grid lines.

  - panel.spacing:
    
    Panel spacing. Accepts numeric (converted to pt), `grid::unit`
    object, or `NULL` (default: 0 pt).

  - plot.margin:
    
    Plot margin. Accepts `NULL` (auto), a single numeric, or a length-4
    numeric vector (top, right, bottom, left).

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_heat()`, `theme_km`,
`theme_legend()`, `theme_legend1()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
ggplot(iris, aes(Petal.Length, Petal.Width)) +
  geom_point() +
  theme_my()

ggplot(iris, aes(Petal.Length, Petal.Width)) +
  geom_point() +
  facet_wrap(~Species) +
  theme_my(panel.spacing = unit(0, "pt"))
} # }
```
