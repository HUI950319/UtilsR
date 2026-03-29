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

## See also

Other grob utilities:
[`grob_as()`](https://hui950319.github.io/UtilsR/reference/grob_as.md),
[`grob_insert()`](https://hui950319.github.io/UtilsR/reference/grob_insert.md),
[`grob_to_gg()`](https://hui950319.github.io/UtilsR/reference/grob_to_gg.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
main <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
side <- ggplot(mtcars, aes(x = wt)) + geom_density()
gt <- grob_add(main, grob_as(side), position = "top")
grid::grid.draw(gt)
} # }
```
