# Variable Inspection Generic Function

Inspect variables in a data.frame or Seurat object, including frequency
counts, unique values, missing values and special values (e.g.
"unknown", "blank", "n/a"). Supports grouped summaries and
multi-variable cross-tabulation.

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
    back to a global object named `data`, otherwise `data_all` (the
    first that is a data.frame / Seurat object).

  - ...:
    
    Variable selection using `dplyr::select` syntax.

  - pattern:
    
    Optional regex pattern for matching variable names.

  - group:
    
    Optional grouping variable. Supports NSE (bare name) or character
    string. For Seurat objects, set to `TRUE` to use current Ident.

  - count:
    
    Optional variable(s) for cross-tabulation. Accepts a single variable
    name (NSE or string), multiple variable names via `c(var1, var2)`
    (NSE) or character vector `c("var1", "var2")`. Independent of
    `group`.

  - cat\_args:
    
    Optional named list of extra arguments forwarded to
    `RegR::get_gt_cat()` for an additional publication-ready
    categorical-summary table (with survival-outcome columns
    DSS/OS/status etc. auto-included). When non-empty, the internal call
    is essentially `do.call(RegR::get_gt_cat, c(list(data = data),
    cat_args))`. Typical contents: `list(cat_var = "Sex", com_var =
    c("Age","TNM"))`. The `data` argument is always taken from the
    `lv()` first argument; any `data` entry inside `cat_args` is
    overridden with a warning. Default `list()` = no extra call.
    Requires RegR (declared in Suggests).

  - add\_reductions:
    
    Logical. Whether to add reduction coordinates. Default `FALSE`.

  - add\_cell\_stats:
    
    Logical. Whether to show cell statistics. Default `TRUE`.

## Value

Invisibly returns the input data.

## See also

Other inspect: `check_na()`, `check_size()`, `check_system()`,
`count_packages_in_libpaths()`, `impute_na_knn()`, `plt_na()`

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
