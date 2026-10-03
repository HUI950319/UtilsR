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

  A ggplot, patchwork, or list of ggplot objects.

- method:

  Rasterization backend: `"ggrastr"` (default, simple layer-level) or
  `"ragg"` (panel-level, also fixes panel size).

- dpi:

  Integer. Rasterization resolution. Default 300.

- width, height:

  Panel width and height for `method = "ragg"`. Ignored when
  `method = "ggrastr"`. If `NULL` (default), the current device size is
  used.

- units:

  Units for `width`/`height`: `"in"` (default), `"cm"`, or `"mm"`.

- dev:

  Character. Graphics device for
  [`ggrastr::rasterise()`](https://rdrr.io/pkg/ggrastr/man/rasterise.html).
  Default `"ragg"` (high-quality anti-aliasing). Only used when
  `method = "ggrastr"`.

- bg:

  Character. Background colour for panel rendering. Default
  `"transparent"`.

## Value

Same type as input: a ggplot, patchwork, or list of ggplot objects. When
`method = "ragg"`, returns a patchwork-wrapped gtable with a `size`
attribute (list of width, height, units).

## Details

Two backends are available:

- `"ggrastr"`:

  Wraps the plot with
  [`ggrastr::rasterise()`](https://rdrr.io/pkg/ggrastr/man/rasterise.html),
  which marks all geom layers for rasterization at render time. Simple
  and fast. Text and theme elements are always preserved as vectors.

- `"ragg"`:

  Renders each panel to a temporary PNG via
  [`ragg::agg_png()`](https://ragg.r-lib.org/reference/agg_png.html),
  then reads it back as a `rasterGrob`. Text/label grobs inside the
  panel are automatically detected and kept as vectors. Requires `width`
  and `height` to be specified (the panel rendering size). This method
  also fixes the panel size.

### How `"ragg"` preserves text

The function inspects each grob child inside a panel. Children whose
name or class matches `text`, `label`, `segments`, or `legend` are kept
as vector grobs. All other children (points, lines, polygons, raster,
etc.) are rendered into a single PNG and read back as a `rasterGrob`.
The two sets are then recombined, so the final output has crisp vector
text on top of a rasterized geometric layer.

## See also

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
fmt_raster(p)

fmt_raster(p, dpi = 150)


# ragg backend (panel-level, also fixes panel size)
fmt_raster(p, method = "ragg", width = 4, height = 4)


# \donttest{
# Works with patchwork
library(patchwork)
p2 <- ggplot(df, aes(x)) + geom_histogram()
fmt_raster(p | p2, method = "ggrastr", dpi = 300)
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

# }
```
