# Blank Theme with Coordinate Arrows

A minimalist ggplot2 theme that removes all panel elements and
optionally adds coordinate arrows in the bottom-left corner. Ideal for
UMAP / t-SNE embedding plots. Ported from `thisplot::theme_blank`.

## Usage

``` r
theme_blank(
  add_coord = TRUE,
  xlen_npc = 0.15,
  ylen_npc = 0.15,
  xlab = "",
  ylab = "",
  lab_size = 12,
  ...
)
```

## Arguments

  - add\_coord:
    
    Logical. Whether to add coordinate arrows. Default is `TRUE`.

  - xlen\_npc:
    
    Numeric. Length of the x-axis arrow in "npc" units.

  - ylen\_npc:
    
    Numeric. Length of the y-axis arrow in "npc" units.

  - xlab:
    
    Character. Label for the x-axis arrow.

  - ylab:
    
    Character. Label for the y-axis arrow.

  - lab\_size:
    
    Numeric. Font size of the axis labels.

  - ...:
    
    Arguments passed to `theme`.

## Value

A list of ggplot2 theme and annotation objects that can be added to a
ggplot with `+`.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_heat()`, `theme_km`, `theme_legend()`,
`theme_legend1()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
  geom_point()
p + theme_blank()

p + theme_blank(xlab = "UMAP1", ylab = "UMAP2", lab_size = 14)

```
