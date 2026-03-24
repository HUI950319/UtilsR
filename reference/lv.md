# Variable Inspection Generic Function

Inspect variables in a data.frame or Seurat object, including frequency
counts, unique values, missing values and special values (e.g.
"unknown", "blank", "n/a"). Supports grouped summaries and
multi-variable cross-tabulation.

## Usage

``` r
lv(data, ...)

# Default S3 method
lv(data, ..., pattern = NULL, group = NULL, count = NULL)

# S3 method for class 'data.frame'
lv(data, ..., pattern = NULL, group = NULL, count = NULL)

# S3 method for class 'Seurat'
lv(
  data,
  ...,
  pattern = NULL,
  group = NULL,
  count = NULL,
  add_reductions = FALSE,
  add_cell_stats = TRUE
)
```

## Arguments

- data:

  A data object: data.frame or Seurat object.

- ...:

  Variable selection using
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  syntax.

- pattern:

  Optional regex pattern for matching variable names.

- group:

  Optional grouping variable. Supports NSE (bare name) or character
  string. For Seurat objects, set to `TRUE` to use current Ident.

- count:

  Optional variable(s) for cross-tabulation. Accepts a single variable
  name (NSE or string), multiple variable names via `c(var1, var2)`
  (NSE) or character vector `c("var1", "var2")`. Independent of `group`.

- add_reductions:

  Logical. Whether to add reduction coordinates. Default `FALSE`.

- add_cell_stats:

  Logical. Whether to show cell statistics. Default `TRUE`.

## Value

Invisibly returns the input data.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md)

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md)

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md)

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# data.frame basic usage
lv(mtcars)
lv(mtcars, mpg, cyl, hp)
lv(mtcars, pattern = "mpg")

# Grouped view (supports NSE)
lv(mtcars, mpg, hp, wt, group = cyl)
lv(mtcars, mpg, hp, wt, group = "cyl")

# Cross-tabulation
lv(mtcars, count = cyl)
lv(mtcars, count = c(cyl, gear))
lv(mtcars, count = c("cyl", "gear"))

# Seurat object
lv(seurat_obj)
lv(seurat_obj, group = TRUE)
lv(seurat_obj, count = c(seurat_clusters, Phase))
} # }
```
