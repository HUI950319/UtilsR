# Analyze Object Sizes in Global Environment

Check memory usage of objects in `.GlobalEnv`. Outputs a styled `gt`
table with bar chart and color gradient.

## Usage

``` r
check_size(..., pattern = NULL)
```

## Arguments

- ...:

  Object names (character strings) or numeric indices. If empty, all
  objects are analyzed.

- pattern:

  Optional regex pattern for matching object names.

## Value

A `gt` table object.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_size()
check_size(1:5)
check_size("data", "result", "model")
check_size(pattern = "data")
} # }
```
