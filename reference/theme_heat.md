# Heatmap / Tile Plot Theme

A preset theme for categorical tile heatmaps – the look used by the
3-variable branch of \[plt_dist()\]. Built on \[theme_my()\] with the
legend, grid lines, axis ticks, and axis lines removed, leaving clean
bordered tiles. Extra arguments are forwarded to \[theme_my()\], so
palette, border, and `axis_text_angle` (handy for rotating crowded
category labels) remain adjustable.

## Usage

``` r
theme_heat(base_size = 14, ...)
```

## Arguments

- base_size:

  Numeric. Base font size (default 14).

- ...:

  Additional arguments passed on to \[theme_my()\] (e.g. `palette`,
  `border`, `axis_text_angle`). The legend, grid, ticks, and axis lines
  are always removed regardless of `...`.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes:
[`leg1()`](https://hui950319.github.io/UtilsR/reference/leg1.md),
[`leg2()`](https://hui950319.github.io/UtilsR/reference/leg2.md),
[`theme_ROC()`](https://hui950319.github.io/UtilsR/reference/theme_ROC.md),
[`theme_alluvia()`](https://hui950319.github.io/UtilsR/reference/theme_alluvia.md),
[`theme_blank()`](https://hui950319.github.io/UtilsR/reference/theme_blank.md),
[`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md),
[`theme_legend()`](https://hui950319.github.io/UtilsR/reference/theme_legend.md),
[`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md),
[`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
[`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md),
[`theme_sc()`](https://hui950319.github.io/UtilsR/reference/theme_sc.md),
[`theme_scatter`](https://hui950319.github.io/UtilsR/reference/theme_scatter.md)

## Examples

``` r
library(ggplot2)
set.seed(1)
df <- data.frame(
  x = factor(rep(c("A", "B", "C"), each = 3)),
  y = factor(rep(c("P", "Q", "R"), times = 3)),
  z = factor(sample(c("Low", "High"), 9, TRUE))
)
ggplot(df, aes(x, y, fill = z)) +
  geom_tile(color = "black", linewidth = 0.5) +
  geom_label(aes(label = z), show.legend = FALSE) +
  scale_x_discrete(position = "top") +
  scale_y_discrete(limits = rev) +
  labs(x = NULL, y = NULL) +
  theme_heat()

```
