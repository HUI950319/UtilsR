# Check System Resources and Environment

Display system information including OS, R version, memory usage, and
CPU details with colored console output.

## Usage

``` r
check_system(return_result = FALSE, show_warnings = FALSE)
```

## Arguments

  - return\_result:
    
    Logical. If `TRUE`, return the result list visibly. Default `FALSE`.

  - show\_warnings:
    
    Logical. If `TRUE`, display memory warnings. Default `FALSE`.

## Value

A list (invisible by default) containing system\_info, r\_environment,
r\_memory, system\_memory, cpu, warnings, and timestamp.

## See also

Other inspect: `check_na()`, `check_size()`,
`count_packages_in_libpaths()`, `impute_na_knn()`, `lv()`, `plt_na()`

## Examples

``` r
if (FALSE) { # \dontrun{
check_system()
res <- check_system(return_result = TRUE)
} # }
```
