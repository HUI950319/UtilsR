# Format panel appearance

Control panel grid lines, border, and background in one call. Inspired
by Seurat's `NoGrid()` but with fine-grained control over each panel
element.

## Usage

``` r
fmt_panel(
  plot,
  grid = c("none", "major", "minor", "both", "x", "y"),
  grid_color = NULL,
  grid_linewidth = NULL,
  grid_linetype = NULL,
  border = NULL,
  border_linewidth = 0.5,
  bg = NULL,
  ...
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplot objects.

  - grid:
    
    Which grid lines to display.
    
      - `"none"` — remove all grid lines (default).
    
      - `"major"` — show only major grid lines.
    
      - `"minor"` — show only minor grid lines.
    
      - `"both"` — show both major and minor grid lines.
    
      - `"x"` — show only vertical (x-axis) major grid lines.
    
      - `"y"` — show only horizontal (y-axis) major grid lines.

  - grid\_color:
    
    Color of retained grid lines. Default `NULL` (inherit from current
    theme).

  - grid\_linewidth:
    
    Numeric. Line width of retained grid lines. Default `NULL` (inherit
    from current theme).

  - grid\_linetype:
    
    Linetype of retained grid lines (e.g. `"solid"`, `"dashed"`,
    `"dotted"`). Default `NULL` (inherit from current theme).

  - border:
    
    Logical or character.
    
      - `TRUE` — draw a black rectangle border around the panel.
    
      - `FALSE` — remove the panel border.
    
      - A color string (e.g. `"grey50"`) — draw border in that color.
    
      - `NULL` (default) — no change.

  - border\_linewidth:
    
    Numeric. Border line width. Default 0.5.

  - bg:
    
    Panel background color. `NULL` (default) = no change, `"white"`,
    `"transparent"`, or any valid color string.

  - ...:
    
    Additional arguments passed to \[ggplot2::theme()\].

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_plot()`, `fmt_plot_base()`, `fmt_point()`,
`fmt_raster()`, `fmt_ref()`, `fmt_scale()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point()

# Remove all grid lines (most common usage, like Seurat::NoGrid())
fmt_panel(p)


# Keep only major grid lines
fmt_panel(p, grid = "major")


# Keep only horizontal (y-axis) grid lines
fmt_panel(p, grid = "y")


# Add border + white background + no grid
fmt_panel(p, grid = "none", border = TRUE, bg = "white")


# Custom border color
fmt_panel(p, border = "grey40", border_linewidth = 1)


# Dashed grey grid lines
fmt_panel(p, grid = "major", grid_color = "grey80",
          grid_linewidth = 0.3, grid_linetype = "dashed")


# Dotted y-axis grid only
fmt_panel(p, grid = "y", grid_linetype = "dotted", grid_color = "grey70")

```
