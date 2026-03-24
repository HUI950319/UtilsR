# Flatten nested patchwork objects

Recursively flatten nested patchwork objects into a single-level
patchwork.

## Usage

``` r
flatten_patchwork(plots, ..., select_inds = NULL, nrow_inds_order = NULL)
```

## Arguments

- plots:

  A patchwork object (possibly nested) or a list of ggplot objects.

- ...:

  Arguments passed to \[patchwork::wrap_plots()\], e.g. \`nrow\`,
  \`ncol\`.

- select_inds:

  Integer vector of indices to keep after flattening.

- nrow_inds_order:

  Single integer to reorder plots by interleaving rows.

## Value

A patchwork object with all sub-plots at one level.

## Examples

``` r
library(ggplot2)
library(patchwork)
p1 <- ggplot(mtcars, aes(mpg, disp)) + geom_point()
p2 <- ggplot(mtcars, aes(gear, disp, group = gear)) + geom_boxplot()
p3 <- ggplot(mtcars, aes(factor(gear))) + geom_bar()
p4 <- ggplot(mtcars, aes(factor(cyl), mpg)) + geom_violin()

# \donttest{
# Flatten nested patchwork
nested <- (p1 | p2) / (p3 | p4)
flatten_patchwork(nested, nrow = 1)


# Select specific sub-plots
flatten_patchwork(nested, select_inds = c(1, 3))

# }

# Reorder by rows (column-first -> row-first)
nested2 <- (p1 | p2) / (p3 | p4)
flatten_patchwork(nested2, nrow_inds_order = 2, ncol = 2)
```
