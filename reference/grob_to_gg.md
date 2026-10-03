# Convert a Grob or Gtable Back to a ggplot Object

Wrap a grob, gtable, or grid object into a `ggplot` object so that it
can be further manipulated with ggplot2 operators (`+`), saved with
[`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html), or
combined in `patchwork` layouts.

## Usage

``` r
grob_to_gg(grob, ...)
```

## Arguments

- grob:

  A grob, gtable, gList, or any object accepted by
  [`grob_as`](https://hui950319.github.io/UtilsR/reference/grob_as.md).

- ...:

  Currently unused; reserved for future extensions.

## Value

A `ggplot` object that draws the grob when printed or saved.

## Details

This is the reverse operation of
[`grob_as`](https://hui950319.github.io/UtilsR/reference/grob_as.md) and
is especially useful after
[`grob_add`](https://hui950319.github.io/UtilsR/reference/grob_add.md)
or
[`grob_insert`](https://hui950319.github.io/UtilsR/reference/grob_insert.md),
which return gtable objects.

## See also

Other grob utilities:
[`grob_add()`](https://hui950319.github.io/UtilsR/reference/grob_add.md),
[`grob_as()`](https://hui950319.github.io/UtilsR/reference/grob_as.md),
[`grob_insert()`](https://hui950319.github.io/UtilsR/reference/grob_insert.md)

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
