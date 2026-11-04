# Convert a Plot Object to a Grob

Convert various plot objects (ggplot, patchwork, gList, gtable) to a
grob (grid graphical object). This is a unified dispatcher that handles
different input types automatically.

## Usage

``` r
grob_as(plot, ...)
```

## Arguments

- plot:

  A plot object. Supported types: `gtable`, `grob`, `gList`,
  `patchwork`, or `ggplot`.

- ...:

  Currently unused; reserved for future extensions.

## Value

A grob or gtable object, or `NULL` with a warning if conversion is not
supported.

## Details

Patchwork objects are converted with
[`patchwork::patchworkGrob()`](https://patchwork.data-imaginist.com/reference/patchworkGrob.html),
preserving the complete layout, annotations, and collected guides.

Standalone patchwork wrappers created by
[`patchwork::wrap_elements()`](https://patchwork.data-imaginist.com/reference/wrap_elements.html)
or
[`patchwork::wrap_ggplot_grob()`](https://patchwork.data-imaginist.com/reference/wrap_ggplot_grob.html)
retain their wrapped graphics.

When no graphics device is open, conversion uses a temporary null PDF
device that is closed before returning. An already open device is
reused.

## See also

Other grob utilities:
[`grob_add()`](https://hui950319.github.io/UtilsR/reference/grob_add.md),
[`grob_insert()`](https://hui950319.github.io/UtilsR/reference/grob_insert.md),
[`grob_to_gg()`](https://hui950319.github.io/UtilsR/reference/grob_to_gg.md)

## Examples

``` r
library(ggplot2)
data <- data.frame(x = 1:6, y = c(2, 4, 1, 6, 3, 5))
p <- ggplot(data, aes(x, y)) + geom_point()
g <- grob_as(p)
class(g)
#> [1] "gtable" "gTree"  "grob"   "gDesc" 
combined <- patchwork::wrap_plots(p, p, ncol = 2) +
  patchwork::plot_annotation(title = "Combined plots")
grid::grid.draw(grob_as(combined))

```
