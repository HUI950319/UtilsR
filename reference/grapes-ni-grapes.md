# Not-in operator

Negation of `%in%`. Returns `TRUE` for elements of `x` that are *not* in
`table`.

## Usage

``` r
x %ni% table
```

## Arguments

- x:

  Vector of values to check.

- table:

  Vector of values to match against.

## Value

Logical vector.

## Examples

``` r
c(1, 2, 3) %ni% c(2, 4)
#> [1]  TRUE FALSE  TRUE
# [1]  TRUE FALSE  TRUE
```
