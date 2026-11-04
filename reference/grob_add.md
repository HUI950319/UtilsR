# Add a Grob to a Gtable at a Specified Position

Add a grob or gtable to the margin of an existing gtable, aligned to the
panel area. Useful for appending side plots (e.g., density plots, bar
charts) around a main plot panel.

## Usage

``` r
grob_add(
  plot,
  grob,
  position = c("top", "bottom", "left", "right", "none"),
  space = NULL,
  clip = "on"
)
```

## Arguments

- plot:

  A `ggplot`, `patchwork`, or `gtable` object to serve as the main plot.

- grob:

  A grob, gtable, or ggplot object to add.

- position:

  Where to place the grob. One of `"top"`, `"bottom"`, `"left"`,
  `"right"`, or `"none"`.

- space:

  Space to allocate for the added grob. If `NULL` (default), calculated
  automatically from the grob dimensions.

- clip:

  Clipping mode. Default is `"on"`.

## Value

A gtable object with the grob added at the specified position.

## Details

Top and bottom additions span the full width of the panel area; left and
right additions span its full height, including all facets. The main
gtable must contain a panel area unless `position = "none"` or `grob` is
`NULL`.

Successive additions remain aligned to the main panel area.

Panel names beginning with `"panel"` are preferred. For custom gtables
without this prefix, names containing `"panel"` are used.

Fixed aspect ratio constraints in the main gtable are retained when
margin rows or columns are added.

## See also

Other grob utilities:
[`grob_as()`](https://hui950319.github.io/UtilsR/reference/grob_as.md),
[`grob_insert()`](https://hui950319.github.io/UtilsR/reference/grob_insert.md),
[`grob_to_gg()`](https://hui950319.github.io/UtilsR/reference/grob_to_gg.md)

## Examples

``` r
library(ggplot2)
data <- data.frame(x = 1:12, y = rep(c(2, 4, 1, 6, 3, 5), 2),
                   group = rep(c("A", "B"), each = 6))
main <- ggplot(data, aes(x, y)) + geom_point() + facet_wrap(~group)
side <- ggplot(data, aes(x)) + geom_density()
gt <- grob_add(main, grob_as(side), position = "top")
grid::grid.draw(gt)

```
