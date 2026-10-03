# Impute Missing Values with Weighted K-Nearest Neighbours

Impute missing values in mixed-type data with
[`kNN`](https://rdrr.io/pkg/VIM/man/kNN.html). Labelled variables are
temporarily converted to factors for distance calculation, then restored
with their original storage type, variable label, value labels, and
other attributes.

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

[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

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
```
