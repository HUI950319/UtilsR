# Convert Numeric to Factor

Cut a numeric vector into factor groups. Works on vectors (usable in
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)).
Supports fixed cut points or automatic binning.

## Usage

``` r
fct_num(
  x,
  breaks = NULL,
  labels = NULL,
  nbins = NULL,
  type = c("quantile", "equal")
)
```

## Arguments

- x:

  A numeric vector.

- breaks:

  Numeric vector of cut points. E.g. `50` for binary, `c(20, 50)` for 3
  groups. Mutually exclusive with `nbins`.

- labels:

  Character vector of group labels. If `NULL`, labels are auto-generated
  (e.g. `"below_50"`, `"50-80"`, `"above_80"`).

- nbins:

  Integer number of bins for automatic binning. Mutually exclusive with
  `breaks`.

- type:

  Binning method when using `nbins`: `"quantile"` (default) or `"equal"`
  width.

## Value

A factor.

## See also

Other factor tools:
[`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)

## Examples

``` r
x <- c(10, 25, 40, 55, 70, 85, 100)

# Fixed cut points
fct_num(x, breaks = 50)
#> [1] below_50 below_50 below_50 above_50 above_50 above_50 above_50
#> Levels: below_50 above_50
fct_num(x, breaks = c(30, 70))
#> [1] below_30 below_30 30-70    30-70    30-70    above_70 above_70
#> Levels: below_30 30-70 above_70
fct_num(x, breaks = c(30, 70), labels = c("Low", "Mid", "High"))
#> [1] Low  Low  Mid  Mid  Mid  High High
#> Levels: Low Mid High

# Automatic binning
fct_num(x, nbins = 3)
#> [1] low    low    low    middle middle high   high  
#> Levels: low middle high
fct_num(x, nbins = 2, labels = c("Low", "High"))
#> [1] Low  Low  Low  Low  High High High
#> Levels: Low High
fct_num(x, nbins = 4, type = "equal")
#> [1] low       low       medium    medium    high      very_high very_high
#> Levels: low medium high very_high

# In mutate():
if (FALSE) { # \dontrun{
df %>% mutate(age_grp = fct_num(age, breaks = c(40, 60)))
df %>% mutate(age_q4 = fct_num(age, nbins = 4))
} # }
```
