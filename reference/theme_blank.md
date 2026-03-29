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

- add_coord:

  Logical. Whether to add coordinate arrows. Default is `TRUE`.

- xlen_npc:

  Numeric. Length of the x-axis arrow in "npc" units.

- ylen_npc:

  Numeric. Length of the y-axis arrow in "npc" units.

- xlab:

  Character. Label for the x-axis arrow.

- ylab:

  Character. Label for the y-axis arrow.

- lab_size:

  Numeric. Font size of the axis labels.

- ...:

  Arguments passed to
  [`theme`](https://ggplot2.tidyverse.org/reference/theme.html).

## Value

A list of ggplot2 theme and annotation objects that can be added to a
ggplot with `+`.

## See also

Other ggplot2 themes:
[`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md),
[`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md),
[`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
[`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md),
[`theme_sc()`](https://hui950319.github.io/UtilsR/reference/theme_sc.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
  geom_point()
p + theme_blank()

p + theme_blank(xlab = "UMAP1", ylab = "UMAP2", lab_size = 14)

```
