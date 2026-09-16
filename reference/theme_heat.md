# Heatmap / Tile Plot Theme

A preset theme for categorical tile heatmaps – the look used by the
3-variable branch of \[plt\_dist()\]. Built on \[theme\_my()\] with the
legend, grid lines, axis ticks, and axis lines removed, leaving clean
bordered tiles. Extra arguments are forwarded to \[theme\_my()\], so
palette, border, and `axis_text_angle` (handy for rotating crowded
category labels) remain adjustable.

## Usage

``` r
theme_heat(base_size = 14, ...)
```

## Arguments

  - base\_size:
    
    Numeric. Base font size (default 14).

  - ...:
    
    Additional arguments passed on to \[theme\_my()\] (e.g. `palette`,
    `border`, `axis_text_angle`). The legend, grid, ticks, and axis
    lines are always removed regardless of `...`.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_km`, `theme_legend()`,
`theme_legend1()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

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
