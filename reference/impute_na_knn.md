# Impute Missing Values with Weighted K-Nearest Neighbours

Impute missing values in mixed-type data with `kNN`. Labelled variables
are temporarily converted to factors for distance calculation, then
restored with their original storage type, variable label, value labels,
and other attributes.

## Usage

``` r
impute_na_knn(data, k = 5, verbose = TRUE)
```

## Arguments

  - data:
    
    A data frame or tibble. Other data-frame subclasses are processed as
    plain data frames.

  - k:
    
    A positive integer giving the number of nearest neighbours. Defaults
    to `5`. It must not exceed the number of observed donors in any
    variable being imputed.

  - verbose:
    
    Logical. If `TRUE`, report the variables being imputed.

## Value

A data frame with missing values imputed where possible. A tibble is
returned when `data` is a tibble.

## See also

`check_na()`

Other inspect: `check_na()`, `check_size()`, `check_system()`,
`count_packages_in_libpaths()`, `lv()`, `plt_na()`

## Examples

``` r
dat <- data.frame(
  age = c(30, 40, NA, 60),
  group = factor(c("A", "B", "B", "A")),
  marker = c(1, 5, 5, 1)
)

if (requireNamespace("VIM", quietly = TRUE)) {
  impute_na_knn(dat, k = 1, verbose = FALSE)
}
#>   age group marker
#> 1  30     A      1
#> 2  40     B      5
#> 3  40     B      5
#> 4  60     A      1

if (requireNamespace("VIM", quietly = TRUE) &&
    requireNamespace("ToyData", quietly = TRUE)) {
  oc_imputed <- impute_na_knn(ToyData::oc, k = 5, verbose = FALSE)
  utils::head(oc_imputed[, c("age", "BMI", "CA125")])
}
#> # A tibble: 6 × 3
#>     age   BMI CA125
#>   <dbl> <dbl> <dbl>
#> 1    55  23.8  498.
#> 2    70  21.5  179.
#> 3    50  23.8  168.
#> 4    69  19.8 1510.
#> 5    54  23.1  653 
#> 6    66  24.5 2706 
```
