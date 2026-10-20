# Convert Numeric to Factor

Cut a numeric vector into factor groups. Works on vectors (usable in
`mutate()`). Supports fixed cut points or automatic binning.

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

  A numeric vector without dimensions; matrices and arrays are not
  supported. Vectors with `integer64` storage are not supported. SPSS
  user-missing vectors must first be normalized with
  [`haven::zap_missing()`](https://haven.tidyverse.org/reference/zap_missing.html).
  Time-span classes `Duration`, `Period`, and `Interval` are not
  supported; choose a time unit and convert to numeric values before
  binning.

- breaks:

  Numeric vector of finite, distinct cut points. E.g. `50` for binary,
  `c(20, 50)` for 3 groups. Mutually exclusive with `nbins`. Vectors
  with `integer64` storage are not supported. SPSS user-missing vectors
  must first be normalized with
  [`haven::zap_missing()`](https://haven.tidyverse.org/reference/zap_missing.html).
  Time-span classes must be converted to numeric cut points in the same
  unit as `x`.

- labels:

  Character vector of group labels. If `NULL`, labels are auto-generated
  (e.g. `"below_50"`, `"50-80"`, `"above_80"`). Additional digits
  distinguish cut points whose usual text representations coincide.
  Logical labels, including `FALSE`, are not supported; the result is
  always a factor.

- nbins:

  Single finite integer number of bins, at least 2 and less than
  `.Machine$integer.max`. Mutually exclusive with `breaks`.

- type:

  Binning method when using `nbins`: `"quantile"` (default) or `"equal"`
  width. Constant non-missing data cannot be automatically split into
  multiple groups and produce an error. Equal-width binning also errors
  when numeric precision cannot represent distinct cut points.

## Value

A factor.

## Details

Intervals are right-closed: each cut point belongs to the lower group.
The lowest endpoint is included. Thus `"below_50"` includes 50.

Automatic labels for fixed cut points follow the current numeric
formatting, including `getOption("scipen")`. Supply `labels` when factor
level names must remain stable across sessions or display settings.

## See also

Other factor tools:
[`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md),
[`fct_label()`](https://hui950319.github.io/UtilsR/reference/fct_label.md),
[`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md),
[`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md)

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

# Explicit labels stay stable across numeric formatting settings
fct_num(c(50000, 150000), breaks = 100000, labels = c("Lower", "Higher"))
#> [1] Lower  Higher
#> Levels: Lower Higher

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
