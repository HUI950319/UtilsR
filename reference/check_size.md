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
  Arguments are evaluated, so an unquoted numeric variable supplies
  indices, not its own name; a top-level call warns when this happens.

- pattern:

  Optional single, non-missing regular expression for matching object
  names. Takes precedence over `...`; no matches select no objects.

## Value

A `gt` table object, including a zero-row table when no objects can be
inspected. Objects that fail to load are skipped with a warning
identifying each binding and the underlying error message. Its
underlying data contain `Object`, `Class`, `Size`, `Size_fmt` and
`Size_bar`. Numeric sizes remain in MB (\\1024^2\\ bytes), with
automatic B, KB, MB or GB display labels. Size bars appear in HTML
output; other formats retain the size labels. Object bars are scaled to
the largest individual object; the total bar is capped at full width. A
source note states the limits of the estimates.

## Details

Sizes are estimates from
[`utils::object.size()`](https://rdrr.io/r/utils/object.size.html), not
process memory usage or the memory that would be freed by removing an
object. The total sums the individual estimates; shared storage can
therefore be counted more than once. Environments, closure environments,
external pointers and compact ALTREP representations are not fully
accounted for by this method. Each selected binding is read once.
Reading active bindings invokes their functions, and reading promises
evaluates them; inspection can therefore trigger user-defined
computations.

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
(function() {
  prefix <- basename(tempfile("check_size_example_"))
  object_names <- paste0(prefix, c("_small", "_large"))
  list2env(stats::setNames(list(1:10, raw(2048)), object_names), .GlobalEnv)
  on.exit(rm(list = object_names, envir = .GlobalEnv), add = TRUE)
  check_size(object_names)
  indices <- match(object_names, ls(envir = .GlobalEnv, all.names = TRUE))
  check_size(indices)
  check_size(pattern = paste0("^", prefix))
})()


  


Object Size Analysis
```
