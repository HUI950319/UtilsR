# Convert a Grob or Gtable Back to a ggplot Object

Wrap a grob, gtable, or grid object into a `ggplot` object so that it
can be further manipulated with ggplot2 operators (`+`), saved with
`ggsave()`, or combined in `patchwork` layouts.

## Usage

``` r
grob_to_gg(grob, ...)
```

## Arguments

  - grob:
    
    A grob, gtable, gList, or any object accepted by `grob_as`.

  - ...:
    
    Currently unused; reserved for future extensions.

## Value

A `ggplot` object that draws the grob when printed or saved.

## Details

This is the reverse operation of `grob_as` and is especially useful
after `grob_add` or `grob_insert`, which return gtable objects.

## See also

Other grob utilities: `grob_add()`, `grob_as()`, `grob_insert()`

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)

# Build a composite layout with grob_add
main <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
side <- ggplot(mtcars, aes(x = wt)) + geom_density()
gt <- grob_add(main, grob_as(side), position = "top")

# Convert back to ggplot -- now supports ggsave, patchwork, etc.
p <- grob_to_gg(gt)
ggsave("composite.pdf", p, width = 8, height = 6)

# Use in patchwork
library(patchwork)
p1 <- ggplot(mtcars, aes(hp, mpg)) + geom_point()
p1 + p  # patchwork layout

# Inset example
inset_gt <- grob_insert(main, side, left = 0.6, bottom = 0.6)
grob_to_gg(inset_gt)
} # }
```
