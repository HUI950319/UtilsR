# Add facet-grid-style strips to a patchwork grid (top headers + side labels)

For an assembled patchwork laid out as an `nrow x ncol` grid, add shared
strips: column-header strips only on the **top row** and row-label
strips on the **right-most occupied panel** of each row (rotated). The
headers describe crossed dimensions, such as plot type across columns
and a stratifier down rows.

## Usage

``` r
fmt_strip2(
  plot,
  top_label = NULL,
  right_label = NULL,
  ncol = NULL,
  top_fill = NULL,
  right_fill = NULL,
  label_color = "black",
  top_right_fill = c("Grays", "Greens")
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplot panels filling an `nrow x ncol`
  grid. Row-wise and column-wise filling are supported; aligned nested
  rectangular grids retain their layout and annotations. Spacers and
  guide areas are skipped while retaining their positions. Custom
  `design` and non-aligned nested layouts are rejected.

- top_label:

  Non-empty character vector of column-header labels without missing
  values, recycled to `ncol`. Placed on the top-row panels only. `NULL`
  gives no top strips; `""` gives a blank label.

- right_label:

  Non-empty character vector of row labels without missing values,
  recycled to `nrow`. Placed on the right-most occupied panel of each
  row (rotated 90 degrees). `NULL` gives no right strips; `""` gives a
  blank label.

- ncol:

  Single positive integer giving the number of columns in the grid. If
  `NULL`, inferred from the patchwork layout, including dimensions
  implied by its widths/heights and aligned nested grids. Lists use
  patchwork's default grid dimensions. An explicit value must agree with
  a labelled patchwork's existing grid.

- top_fill, right_fill:

  Background fill colour(s) for the top / right strips (recycled to
  `ncol` / `nrow`). `NULL` = light grey when `top_right_fill = NULL`.
  Accepts R colour names, hexadecimal colours, numeric palette indices
  and `NA`; `NA` gives a transparent fill.

- label_color:

  Strip text colour. Default `"black"`. Accepts the same R colour
  specifications as `top_fill`; `NULL` inherits the text colour.

- top_right_fill:

  Character vector of one or two `colorspace` sequential HCL palette
  names used to generate the top and right fills. The first palette is
  used for top strips and the second for right strips; a single palette
  is reused for both directions. Defaults to `c("Grays", "Greens")`.
  Explicit `top_fill` and `right_fill` values take precedence. Palette
  lookup is skipped for unused header directions.

## Value

Same type as input: ggplot, patchwork, or list. Input plot and layer
data, mappings and nested container metadata are preserved.

## Details

Typical use: a `get_vpd(EXP.obj, c(stratifier, exposure))` result
flattened via
[`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
into a `4 x 2` grid (rows = stratifier levels, columns = Variable /
Partial dependence plot) – `fmt_strip2()` then labels the two columns on
top and the four rows on the right.

In RegR, `RegR::get_rcs_all()` uses this helper for its shared-strip 2 x
2 composites when `strip_style = "grid"`. Existing facets retain their
panels when no new header is assigned. A plot receiving a header must
have one panel; native facets with multiple panels are rejected during
plot building, before statistics are computed. New headers restore strip
settings hidden by
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
and override blank strip elements while retaining existing text sizes
and angles.

When both label arguments are `NULL`, existing strips are hidden through
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
without evaluating layer data or statistics. Styling and palette
arguments are ignored in that case.

## See also

[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
for per-plot strip labels; `RegR::get_rcs_all()` for the higher-level
RCS composite that uses this helper with `strip_style = "grid"`.

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
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
library(patchwork)
d <- data.frame(x = seq_len(6), y = c(2, 4, 3, 6, 5, 8))
points <- ggplot(d, aes(x, y)) + geom_point()
trend <- ggplot(d, aes(x, y)) + geom_line()
grid <- wrap_plots(points, trend, points, trend, ncol = 2)
labelled <- fmt_strip2(
  grid, top_label = c("Points", "Trend"), right_label = c("Row 1", "Row 2")
)
labelled



# Aligned nested grids retain their layout; NA gives transparent headers
nested <- (points | trend) / (points | trend)
transparent <- fmt_strip2(
  nested, top_label = c("Points", "Trend"), right_label = c("Row 1", "Row 2"),
  ncol = 2, top_fill = NA, right_fill = NA
)
transparent


```
