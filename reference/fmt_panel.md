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

  A ggplot, patchwork, or nested list of these objects.

- grid:

  Which grid lines to display.

  - `"none"` — remove all grid lines (default).

  - `"major"` — show only major grid lines.

  - `"minor"` — show only minor grid lines.

  - `"both"` — show both major and minor grid lines.

  - `"x"` — show only vertical (x-axis) major grid lines.

  - `"y"` — show only horizontal (y-axis) major grid lines.

- grid_color:

  A single color string, or `NA` for transparent grid lines. Default
  `NULL` (inherit from the current theme).

- grid_linewidth:

  A single finite, non-negative absolute width in millimetres. Relative
  widths created by
  [`ggplot2::rel()`](https://ggplot2.tidyverse.org/reference/element.html)
  are not accepted. Line width of retained grid lines. Default `NULL`
  (inherit from current theme).

- grid_linetype:

  A single named line type (e.g. `"solid"`, `"dashed"`, `"dotted"`), an
  integer from 0 to 6, or a pattern of 2, 4, 6 or 8 hexadecimal digits
  without zeroes (e.g. `"22"`). Default `NULL` (inherit from current
  theme).

- border:

  A single non-missing logical value or color string.

  - `TRUE` — draw a black rectangle border around the panel.

  - `FALSE` — remove the panel border.

  - A color string (e.g. `"grey50"`) — draw border in that color.

  - `NULL` (default) — no change.

- border_linewidth:

  A single finite, non-negative absolute width in millimetres. Relative
  widths created by
  [`ggplot2::rel()`](https://ggplot2.tidyverse.org/reference/element.html)
  are not accepted. Border line width, used only when `border` is `TRUE`
  or a color string. Default 0.5.

- bg:

  A single panel background color string, or `NA` for a transparent
  background. `NULL` (default) leaves the background unchanged.

- ...:

  Additional arguments passed to
  [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html),
  applied after panel settings.

## Value

Same type as input.

## Details

Grid modes control visibility even when the original theme hides grid
lines. Retained grids keep available inherited styling. When enabling a
blank grid element, blank entries in its inheritance chain are replaced
with entries from the current global theme, falling back to
[`ggplot2::theme_gray()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
when those entries are also blank. Styles overwritten by earlier
formatting cannot be recovered. Restored grids continue to inherit
parent grid-theme changes. Grid lines still require corresponding scale
breaks.

If an automatically restored grid color matches the known opaque
background, it becomes `"grey70"` (or `"grey30"` on a `"grey70"`
background). Available plot styles and explicit grid colors, including
those in `...`, retain their normal priority. Transparent or unknown
backgrounds are unchanged.

Ordinary plot leaves are formatted recursively. Layouts, annotations and
list names are retained. Spacers, guide areas, frozen
[`wrap_elements()`](https://patchwork.data-imaginist.com/reference/wrap_elements.html)
cells and inset overlays are returned unchanged; format their plots
before wrapping or adding them as insets.

Extra theme arguments follow normal ggplot2 theme inheritance. To
override a grid mode through `...`, set the corresponding axis-specific
elements, such as `panel.grid.major.x`. The `bg` argument changes only
the panel background; use `plot.background` in `...` for the full plot.

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
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
d <- data.frame(x = 1:20, y = sin((1:20) / 3) + (1:20) / 10,
                group = rep(c("A", "B"), each = 10))
p <- ggplot(d, aes(x, y, color = group)) +
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
