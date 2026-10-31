# Impute Missing Values with Weighted K-Nearest Neighbours

Impute missing values in mixed-type data with
[`kNN`](https://rdrr.io/pkg/VIM/man/kNN.html). Labelled variables are
temporarily converted to factors for distance calculation, then restored
with their original storage type, variable label, value labels, and
other attributes. SPSS user-missing codes are treated as missing rather
than donor categories. Labelled donor values are restored through their
original category values, without parsing rounded printed numbers.
Stored integer64 columns require bit64. When imputation is needed, their
observed values must be within +/-`2^53` for exact numeric conversion.
Imputed values are converted back to integer64 storage, with fractional
parts truncated. Ordinary integer columns also retain truncation toward
zero when converting their weighted means back to integer storage. VIM's
distance weights and aggregation rules are retained. Degenerate weights
use equal weights for the selected neighbours. Wholly missing rows are
retained without imputation, and remaining missing values are reported.
Infinite numeric input is rejected when imputation is needed. Dates,
date-times, time differences and durations use numeric distances and
retain their original classes, time zones and units. Calendar periods
and intervals, complex vectors and raw vectors require explicit
conversion before imputation.

## Usage

``` r
impute_na_knn(data, k = 5, verbose = TRUE)
```

## Arguments

- data:

  A data frame or tibble. Other data-frame subclasses are processed as
  plain data frames. Columns must have unique, non-missing, non-empty
  names and one-dimensional atomic storage (date-time vectors may also
  use POSIXlt storage). At least one predictor column is needed for
  imputation.

- k:

  A positive integer giving the number of nearest neighbours. Defaults
  to `5`. It must not exceed the number of observed donors in any
  variable being imputed.

- verbose:

  Logical. If `TRUE`, report the variables being imputed.

## Value

A data frame with missing values imputed where possible. A tibble is
returned when `data` is a tibble. Observation order and data-frame row
names are retained.

## Details

Numeric variables use distance-weighted means. Labelled variables retain
categorical treatment, and VIM's categorical and ordered aggregators are
retained for ordinary finite weights. Previously imputed values
participate in subsequent distance calculations, so column order can
affect results. Categorical tie breaking uses R's random number
generator; call [`set.seed()`](https://rdrr.io/r/base/Random.html)
before imputation when needed.

## See also

[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
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
