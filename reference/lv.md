# Variable Inspection Generic Function

Inspect variables in a data.frame or Seurat object, including frequency
counts, unique values, missing values and special values (e.g.
"unknown", "blank", "n/a"). Supports grouped summaries and
multi-variable cross-tabulation. Special-value matching uses
Unicode-aware whole-word markers and normalizes whitespace, including
Unicode whitespace-only blanks. Values recognized by
[`is.na()`](https://rdrr.io/r/base/NA.html), including SPSS user-missing
codes, are excluded from special-value counts. Methods for serialized
haven-labelled and integer64 columns are loaded before inspection;
integer64 columns require the optional bit64 package.

## Usage

``` r
lv(data, ...)

# Default S3 method
lv(data, ..., pattern = NULL, group = NULL, count = NULL, cat_args = list())

# S3 method for class 'data.frame'
lv(data, ..., pattern = NULL, group = NULL, count = NULL, cat_args = list())

# S3 method for class 'Seurat'
lv(
  data,
  ...,
  pattern = NULL,
  group = NULL,
  count = NULL,
  cat_args = list(),
  add_reductions = FALSE,
  add_cell_stats = TRUE
)
```

## Arguments

- data:

  A data object: data.frame or Seurat object. If omitted, `lv()` falls
  back to a global object named `data`, otherwise `data_all` (the first
  that is a data.frame / Seurat object). Empty data frames are returned
  unchanged with a message and no report.

- ...:

  Variable selection using
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  syntax, including renamed selections. With no selection, all variables
  are inspected; an explicit empty selection returns the input without a
  report.

- pattern:

  Optional single regex pattern for matching variable names. Overrides
  `...` with a warning, without evaluating those selections.

- group:

  Optional grouping variable. Supports NSE (bare name) or character
  string. For Seurat objects, set to `TRUE` to use current Ident. Bare
  column names take precedence over caller objects; character names can
  also be supplied through variables or expressions.

- count:

  Optional variable(s) for cross-tabulation. Accepts a single variable
  name (NSE or string), multiple variable names via `c(var1, var2)`
  (NSE) or character vector `c("var1", "var2")`. Independent of `group`.
  Existing dplyr groups are ignored for this table. Generated frequency,
  percentage, and total column names receive numeric suffixes when
  needed to preserve input columns and category labels. Names must be
  non-missing and distinct; invalid controls are errors.

- cat_args:

  Optional named list of extra arguments forwarded to
  `RegR::get_gt_cat()` for an additional publication-ready
  categorical-summary table (with survival-outcome columns DSS/OS/status
  etc. auto-included). When non-empty, the internal call is essentially
  `do.call(RegR::get_gt_cat, c(list(data = data), cat_args))`. Typical
  contents: `list(cat_var = "Sex", com_var = c("Age","TNM"))`. The
  `data` argument is always taken from the `lv()` first argument; any
  `data` entry inside `cat_args` is overridden with a warning. Default
  [`list()`](https://rdrr.io/r/base/list.html) = no extra call. Requires
  RegR (declared in Suggests).

- add_reductions:

  Logical. Whether to add reduction coordinates. Default `FALSE`.

- add_cell_stats:

  Logical. Whether to show cell statistics. Default `TRUE`.

## Value

Invisibly returns the input data.

## Details

In R Markdown or Quarto, use a code chunk with `results = "asis"` (and
optionally `message = FALSE`). Reports are emitted through
[`knitr::knit_print()`](https://rdrr.io/pkg/knitr/man/knit_print.html)
in the document's native format, with dependencies retained. Console
frequency listings are omitted while knitting, and each default summary
table is included only once.

## See also

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

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

# cat_args: append a publication-ready table via RegR::get_gt_cat
# (requires RegR package; survival outcome cols DSS/OS/status auto-included)
library(dplyr)
df <- mtcars |>
  mutate(cyl_f = factor(cyl), am_f = factor(am, labels = c("auto","manual")))

# 1) Default (empty list) -- no extra get_gt_cat call (backward-compatible)
lv(df, mpg, hp, cyl_f, am_f, cat_args = list())

# 2) Minimal: cat_var only -- groups by 'am_f', auto-adds outcome cols if any
lv(df, mpg, hp, cyl_f, am_f,
   cat_args = list(cat_var = "am_f"))

# 3) With explicit com_var (rows of the gt table)
lv(df, mpg, hp, cyl_f, am_f,
   cat_args = list(cat_var = "am_f", com_var = c("mpg", "hp", "cyl_f")))

# 4) Stratified summary (separate table per strata level)
lv(df, mpg, hp,
   cat_args = list(strata_var = "cyl_f", cat_var = "am_f",
                   com_var = c("mpg", "hp")))

# 5) Combine with group mode -- lv prints grouped summary,
#    then get_gt_cat prints the publication table
lv(df, mpg, hp, group = cyl_f,
   cat_args = list(cat_var = "am_f", com_var = c("mpg", "hp")))

# Seurat object
lv(seurat_obj)
lv(seurat_obj, group = TRUE)
lv(seurat_obj, count = c(seurat_clusters, Phase))
} # }
```
