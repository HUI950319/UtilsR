# Insert an Inset Plot Inside Another Plot

Place a smaller plot (inset) at a specified position within the panel
area of a main plot, similar to
[`patchwork::inset_element()`](https://patchwork.data-imaginist.com/reference/inset_element.html).
Coordinates use normalized panel coordinates (0-1) by default.

## Usage

``` r
grob_insert(
  plot,
  inset,
  left = 0.6,
  bottom = 0.6,
  right = 1,
  top = 1,
  align_to = c("panel", "plot", "full"),
  on_top = TRUE,
  clip = TRUE
)
```

## Arguments

- plot:

  A `ggplot` or `patchwork` object serving as the main plot.

- inset:

  A `ggplot`, `grob`, or other plot object to insert.

- left:

  Left boundary of the inset (0 = panel left edge, 1 = right edge).
  Default is `0.6`.

- bottom:

  Bottom boundary of the inset (0 = panel bottom, 1 = top). Default is
  `0.6`.

- right:

  Right boundary of the inset. Default is `1`.

- top:

  Top boundary of the inset. Default is `1`.

- align_to:

  Reference area for positioning. One of `"panel"` (default), `"plot"`,
  or `"full"`.

- on_top:

  Logical. Whether the inset is drawn on top of the main plot. Default
  is `TRUE`.

- clip:

  Logical. Whether to clip the inset to the specified boundaries.
  Default is `TRUE`.

## Value

A gtable object with the inset placed inside the main plot.

## Details

Unlike
[`patchwork::inset_element()`](https://patchwork.data-imaginist.com/reference/inset_element.html),
this function returns a ready-to-draw `gtable` object (use
[`grid::grid.draw()`](https://rdrr.io/r/grid/grid.draw.html) to render).
It does not require patchwork and works with any grob-convertible plot
object.

## See also

Other grob utilities:
[`grob_add()`](https://hui950319.github.io/UtilsR/reference/grob_add.md),
[`grob_as()`](https://hui950319.github.io/UtilsR/reference/grob_as.md),
[`grob_to_gg()`](https://hui950319.github.io/UtilsR/reference/grob_to_gg.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
main <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
inset <- ggplot(mtcars, aes(factor(cyl))) + geom_bar() +
  theme_void() + theme(plot.background = element_rect(fill = "white"))
gt <- grob_insert(main, inset,
  left = 0.6, bottom = 0.6, right = 1, top = 1
)
grid::grid.draw(gt)
} # }
```
