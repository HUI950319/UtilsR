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

  Additional arguments passed to conversion functions.

## Value

A grob or gtable object, or `NULL` with a warning if conversion is not
supported.

## See also

Other grob utilities:
[`grob_add()`](https://hui950319.github.io/UtilsR/reference/grob_add.md),
[`grob_insert()`](https://hui950319.github.io/UtilsR/reference/grob_insert.md),
[`grob_to_gg()`](https://hui950319.github.io/UtilsR/reference/grob_to_gg.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
g <- grob_as(p)
class(g)
#> [1] "gtable" "gTree"  "grob"   "gDesc" 
```
