# Rasterize Plot Panels

Rasterize geometric layers (points, lines, polygons) in ggplot panels to
reduce PDF/SVG file size, while keeping text, axes, and legends as
vectors.

## Usage

``` r
fmt_raster(
  plot,
  method = c("ggrastr", "ragg"),
  dpi = 300,
  width = NULL,
  height = NULL,
  units = c("in", "cm", "mm"),
  dev = "ragg",
  bg = "transparent"
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list containing either type.

- method:

  Rasterization backend: `"ggrastr"` (default, simple layer-level) or
  `"ragg"` (panel-level, also fixes panel size).

- dpi:

  Positive finite numeric scalar. Rasterization resolution in dots per
  inch. Default 300.

- width, height:

  Panel width and height for `method = "ragg"`. Positive finite numeric
  scalar, or one value per panel in depth-first gtable order
  (column-major for grid facets). Panels sharing layout cells must have
  consistent dimensions, and nested plots must fit their layout. Ignored
  when `method = "ggrastr"`. If `NULL` (default), panel dimensions are
  resolved from the current device's grid layout. With no open device,
  the width and height from
  [`grDevices::pdf.options()`](https://rdrr.io/r/grDevices/pdf.options.html)
  are used as the available plot size.

- units:

  Units for `width`/`height`: `"in"` (default), `"cm"`, or `"mm"`.

- dev:

  Character. Graphics device for
  [`ggrastr::rasterise()`](https://rdrr.io/pkg/ggrastr/man/rasterise.html).
  Default `"ragg"` (high-quality anti-aliasing). Only used when
  `method = "ggrastr"`.

- bg:

  Character. Background colour for panel rendering. Default
  `"transparent"`. Only used when `method = "ragg"`.

## Value

The `"ggrastr"` backend preserves the input type. The `"ragg"` backend
returns a patchwork-wrapped gtable with a `size` attribute: a list with
`width`, `height`, and `units` describing the complete fixed plot
dimensions. For list inputs, returns a corresponding list and preserves
its names.

## Details

Two backends are available:

- `"ggrastr"`:

  Wraps the plot with
  [`ggrastr::rasterise()`](https://rdrr.io/pkg/ggrastr/man/rasterise.html),
  which marks non-text geom layers for rasterization at render time.
  Text/label layers, custom annotations, and theme elements remain
  vectors.

- `"ragg"`:

  Captures panel geometry in memory via
  [`ragg::agg_capture()`](https://ragg.r-lib.org/reference/agg_capture.html)
  and inserts it as a `rasterGrob`. Text/label grobs inside the panel
  are automatically detected and kept as vectors. Uses the specified
  panel dimensions or the current device's grid layout when dimensions
  are `NULL`, then fixes the panel size.

The `"ragg"` backend renders geometry immediately. Apply data, scale,
theme, and layer changes before calling this function. For export, use
the dimensions in the returned `size` attribute to retain the fixed
layout. The `"ggrastr"` backend rasterizes when the plot is drawn and
continues to use the output device's layout.

Panels with clipping disabled are kept as vectors, with a warning, to
preserve geometry drawn outside the panel. They do not receive the
file-size benefit of rasterization.

### How `"ragg"` preserves text

The function inspects each grob child inside a panel. Children whose own
name or class identifies text/labels, or whose descendants contain text,
are kept as vectors. Mixed text/geometry trees are retained together to
preserve their internal layout. A viewport alone does not prevent
rasterization. Other children (points, lines, polygons, raster, etc.)
are captured in contiguous runs and inserted as `rasterGrob` objects.
Vector text and rasterized geometry retain their original draw order,
including text covered by a later geometric layer.

## See also

[`grob_as()`](https://hui950319.github.io/UtilsR/reference/grob_as.md),
[`ggrastr::rasterise()`](https://rdrr.io/pkg/ggrastr/man/rasterise.html)

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
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)

set.seed(42)
df <- data.frame(x = rnorm(5000), y = rnorm(5000))
p <- ggplot(df, aes(x, y)) + geom_point(alpha = 0.3) + ggtitle("Demo")

# ggrastr backend (simple)
p_ggrastr <- fmt_raster(p, dpi = 150)
p_ggrastr


# ragg backend (panel-level, also fixes panel size)
p_ragg <- fmt_raster(p, method = "ragg", width = 4, height = 3)
p_ragg


# \donttest{
# Works with patchwork
library(patchwork)
p2 <- ggplot(df, aes(x)) + geom_histogram(bins = 30)
p_nested <- fmt_raster((p | p2) / p, method = "ragg", dpi = 150)
p_nested

# }
```
