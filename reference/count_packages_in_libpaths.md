# Count Installed Packages in Each Library Path

Enumerate all [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) and
count the number of installed packages in each directory.

## Usage

``` r
count_packages_in_libpaths()
```

## Value

A data.frame with columns `Library_Path` and `Package_Count`, including
a total row.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

## Examples

``` r
if (FALSE) { # \dontrun{
count_packages_in_libpaths()
} # }
```
