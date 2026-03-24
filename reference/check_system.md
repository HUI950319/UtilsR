# Check System Resources and Environment

Display system information including OS, R version, memory usage, and
CPU details with colored console output.

## Usage

``` r
check_system(return_result = FALSE, show_warnings = FALSE)
```

## Arguments

- return_result:

  Logical. If `TRUE`, return the result list visibly. Default `FALSE`.

- show_warnings:

  Logical. If `TRUE`, display memory warnings. Default `FALSE`.

## Value

A list (invisible by default) containing system_info, r_environment,
r_memory, system_memory, cpu, warnings, and timestamp.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_system()
res <- check_system(return_result = TRUE)
} # }
```
