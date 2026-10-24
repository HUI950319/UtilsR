# Check System Resources and Environment

Display system information including OS, R version, memory usage, and
CPU details with colored console output. Windows uses the optional `ps`
package for live memory queries and caches static OS and CPU details
obtained with PowerShell CIM. CIM and legacy WMIC remain fallbacks when
native memory queries are unavailable. Linux physical core counts use
the optional `ps` package and are reported as missing when it is
unavailable. On macOS, system memory is obtained through the optional
`ps` package.

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

## Details

R memory measures the heap managed by R, not the operating system's
resident process size (RSS). It uses `lobstr` when available, otherwise
exact [`gc()`](https://rdrr.io/r/base/gc.html) cell counts. Memory
fields ending in `_gb` retain their names and report gibibytes (GiB,
\\2^{30}\\ bytes). System `free_gb` represents available memory;
`used_gb` is the difference between total and available memory.
Unavailable measurements are returned as missing values.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_system()
res <- check_system(return_result = TRUE)
} # }
```
