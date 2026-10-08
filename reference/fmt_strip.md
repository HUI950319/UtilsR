# Add facet strip labels to a plot

Add a top strip to an unfaceted plot or update the labels and style of
an existing facet. Facet variables, layout, scales, statistics and
plot/layer data are preserved. Strip text is horizontally and vertically
centered. Set `strip = FALSE` to hide strips without building the plot.

## Usage

``` r
fmt_strip(
  plot,
  label = NULL,
  label_color = "black",
  label_fill = NULL,
  strip = TRUE
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of these. Nested patchworks retain their
  layout; spacers and guide areas are skipped.

- label:

  A non-empty character vector without missing values, or `NULL`. For
  one faceted plot, labels are recycled across the displayed levels of
  its first facet variable: the first wrap variable, or the first grid
  column variable (row variable when there are no columns). Other
  variables retain their labeller, including row/column labellers and
  single-line formatting. For multiple plots, labels are recycled across
  leaf plots in their existing order. `NULL` generates `Figure1`,
  `Figure2`, etc.; `""` gives a blank label.

- label_color:

  Text colour(s). Default `"black"` uses bold text. `NULL` inherits the
  existing text colour and face. Valid R colour names, hexadecimal
  colours, numeric palette indices and `NA` are accepted. Colours are
  recycled across leaf plots; one faceted plot uses the first.

- label_fill:

  Background fill colour(s), recycled across leaf plots. One faceted
  plot uses the first fill. `NULL` inherits the current theme or ggh4x
  strip background; use `NA` or `"transparent"` for a transparent fill.
  Accepts the same colour specifications as `label_color`.

- strip:

  Logical. `TRUE` (default) adds the strip labels. `FALSE` shows no
  strip at all and ignores `label`, `label_color` and `label_fill`:
  strips already on the plot, from an earlier `fmt_strip()` /
  [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  call or from its own facets, are removed. Synthetic facets created by
  this function are dropped; native facets keep their panels with strips
  hidden through the theme. Complete themes such as
  [`theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  can reveal native strips; reapply this formatter to hide them again. A
  later `strip = TRUE` call restores the hidden strip settings and
  applies its new labels and colours. Layer data functions and
  statistics are not evaluated by this formatter.

## Value

Same type as input.

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
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
d <- data.frame(
  x = rep(seq_len(5), 3), y = sin(seq_len(15) / 3),
  group = rep(c("A", "B", "C"), each = 5)
)
p <- ggplot(d, aes(x, y)) + geom_point()
fmt_strip(p, label = "Example", label_color = "white", label_fill = "steelblue")


# Rename facet levels without changing panel membership
p_facet <- p + facet_wrap(vars(group))
fmt_strip(p_facet, label = c("First", "Second", "Third"), label_fill = NA)


# Hide strips and restore them later
hidden <- fmt_strip(p_facet, strip = FALSE)
fmt_strip(hidden, label = c("First", "Second", "Third"))


# Nested layouts skip spacers when assigning labels
library(patchwork)
fmt_strip((p | plot_spacer() | p) / p, label = c("A", "B", "C"))

```
