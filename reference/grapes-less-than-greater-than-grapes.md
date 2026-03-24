# Compound assignment pipe operator

Pipes `lhs` into `rhs`, then assigns the result back to `lhs`.
Equivalent to `lhs <- lhs %>% rhs`.

## Usage

``` r
lhs %<>% rhs
```

## Arguments

- lhs:

  A variable name (will be updated in the calling environment).

- rhs:

  A function or expression to pipe into.

## Value

Invisibly returns the new value of `lhs`.

## Examples

``` r
x <- c(1, 2, 3)
x %<>% sum()
x
#> [1] 6
# [1] 6
```
