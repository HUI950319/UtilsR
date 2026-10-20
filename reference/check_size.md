# Analyze Object Sizes in Global Environment

Check memory usage of objects in `.GlobalEnv`. Outputs a styled `gt`
table with bar chart and color gradient.

## Usage

``` r
check_size(..., pattern = NULL)
```

## Arguments

- ...:

  Object names (character vectors) or plain numeric vectors of finite,
  positive integer indices into the alphabetically sorted names in
  `.GlobalEnv`, including hidden names. With no arguments, all objects
  are analyzed. Duplicate names are inspected once. Missing names are
  skipped with a warning; empty selections do not select all objects.

- pattern:

  Optional single, non-missing regular expression for matching object
  names. Takes precedence over `...`; no matches select no objects.

## Value

A `gt` table object.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_size()
check_size(1:5)
check_size("data", "result", "model")
check_size(pattern = "data")
} # }
```
