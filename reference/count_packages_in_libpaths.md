# Count Installed Packages in Each Library Path

Enumerate all `.libPaths()` and count the number of installed packages
in each directory.

## Usage

``` r
count_packages_in_libpaths()
```

## Value

A data.frame with columns `Library_Path` and `Package_Count`, including
a total row.

## See also

Other inspect: `check_na()`, `check_size()`, `check_system()`,
`impute_na_knn()`, `lv()`, `plt_na()`

## Examples

``` r
if (FALSE) { # \dontrun{
count_packages_in_libpaths()
} # }
```
