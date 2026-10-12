# Flatten nested patchwork objects

Recursively flatten nested patchwork objects into a single-level
patchwork.

## Usage

``` r
flatten_patchwork(plots, ..., select_inds = NULL, nrow_inds_order = NULL)
```

## Arguments

- plots:

  A ggplot, patchwork object, grob, or nested list of these objects.

- ...:

  Arguments passed to \[patchwork::wrap_plots()\], e.g. \`nrow\`,
  \`ncol\`.

- select_inds:

  Integer indices applied after flattening. Positive indices select and
  may repeat plots; negative indices exclude plots. Zero is ignored.
  Missing, fractional, mixed-sign and out-of-range indices are rejected.

- nrow_inds_order:

  Single positive integer, at most the number of selected plots, to
  reorder them by interleaving rows. Applied after selection; it does
  not set the output layout's `nrow`.

## Value

A patchwork object with ordinary grid cells at one level. Insets and
their main plot stay together and count as one cell for
selection/reordering.

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
