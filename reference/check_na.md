# Comprehensive Data Quality Analysis

Analyze missing values and special values (e.g. "unknown", "blank",
"n/a") for each variable. Returns a styled `gt` table with conditional
formatting based on severity.

## Usage

``` r
check_na(data, ..., pattern = NULL, show_all = FALSE)
```

## Arguments

- data:

  A data.frame with unique, non-empty column names. Selected columns
  must be one-dimensional. Grouped inputs are inspected across all rows.

- ...:

  Variable selection using
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  syntax. Omit to inspect all columns. Renaming changes only the
  displayed variable names.

- pattern:

  `NULL` or a single non-missing character string used as a regex
  pattern for matching variable names. Takes precedence over `...`, with
  a warning when both are supplied; an invalid regular expression is an
  error. An empty string matches all columns. An unmatched pattern or
  selection inspects no columns and returns `NULL` with an informational
  message.

- show_all:

  A single non-missing logical. If `FALSE` (default), only variables
  with issues are shown.

## Value

A `gt` table, returned visibly so that it prints in the console, renders
in R Markdown, Quarto and pkgdown, and can be saved with
[`gt::gtsave()`](https://gt.rstudio.com/reference/gtsave.html). `NULL`,
invisibly, when no table is produced: no selected columns, no rows, or
no issues with `show_all = FALSE`.

## Details

Inputs with zero rows or zero columns return `NULL` invisibly with an
informational message and no table. Special-value counts apply to
character and factor columns. Matching is case-insensitive and uses
Unicode-aware whole-word markers after collapsing whitespace, including
Unicode spaces. Whitespace-only strings count as blank values. Each
value is counted once. Values recognized by
[`is.na()`](https://rdrr.io/r/base/NA.html), including SPSS user-missing
codes, count only as missing values. Inspection loads methods for
serialized haven-labelled and integer64 columns before counting missing
values. Integer64 columns require the optional bit64 package.
Dataset-size calculations use double precision, and counts are formatted
as whole numbers without a 32-bit integer limit. Severity colors use
unrounded percentages. Missing-value shading is yellow above 0%, orange
above 20% and red above 50%, and also tints the variable and type cells.
Special-value shading deepens from light to dark blue above 0%, 10% and
30%. A source note under the table repeats these thresholds. Percentages
are rounded only for display, to one decimal place in cells and two in
the summary. Positive percentages below these display resolutions appear
as `<0.1%` in cells and `<0.01%` in the summary; zeros retain their
usual numeric format. The subtitle counts variables containing issues;
the summary counts individual missing and special values across the
selected columns. Both summary percentages use every selected cell as
the denominator, including columns that cannot hold special values.

## See also

Other inspect:
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

## Examples

``` r
# \donttest{
# Analyze all variables
check_na(airquality)
#> ======   ℹ Data quality analysis: 2 variables with data quality issues ℹ   =====


  


Missing & Special Value Analysis
```
