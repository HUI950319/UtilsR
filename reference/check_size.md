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

Other inspect: `check_na()`, `check_system()`,
`count_packages_in_libpaths()`, `impute_na_knn()`, `lv()`, `plt_na()`

## Examples

``` r
if (FALSE) { # \dontrun{
check_size()
check_size(1:5)
check_size("data", "result", "model")
check_size(pattern = "data")
} # }
```
