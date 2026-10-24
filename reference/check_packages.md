# Count Installed Packages in Each Library Path

Enumerate all [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) and
count the number of installed packages in each directory using
[`utils::installed.packages()`](https://rdrr.io/r/utils/installed.packages.html).
Unrelated directories and installation locks are excluded. The total
counts installed copies across libraries, including packages installed
in more than one library.

## Usage

``` r
check_packages(refresh = FALSE)
```

## Arguments

- refresh:

  Logical scalar. If `TRUE`, bypass the installed-package cache and read
  package metadata from disk. Defaults to `FALSE`.

## Value

Invisibly, a data.frame with columns `Library_Path` and `Package_Count`,
including a total row. Failed libraries and the total have `NA` counts
if any library cannot be read.

## Details

A warning identifies each library that cannot be read. Counts for
readable libraries are still returned; the total is not a partial sum. A
formatted report is written to standard output. Long library paths may
be shortened in the report; the returned data frame keeps full paths.
Counts use comma thousands separators in the report; returned counts
remain numeric.

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
check_packages()
check_packages(refresh = TRUE)
} # }
```
