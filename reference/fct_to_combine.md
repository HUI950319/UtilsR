# Combine Multiple Vectors / Columns into a Single Factor (generic)

S3 generic that pastes several vectors cell-wise into one factor. Levels
are the unique combinations sorted by each input's factor-level order
(preserving meaningful orderings such as TNM stages or graded
categories), not alphabetic. Dispatches on an explicitly named
data.frame `x`, or otherwise on the first argument:

- **vectors** – `fct_to_combine(v1, v2, ...)` returns the combined
  factor directly (also resolves a single character vector of column
  names inside a dplyr data mask).

- **data.frame** – `fct_to_combine(data, vars, var_name)` combines the
  named columns, appends the result as a new column, and returns the
  whole data frame (pipe-friendly).

## Usage

``` r
fct_to_combine(...)

# S3 method for class 'data.frame'
fct_to_combine(x, vars, var_name = NULL, sep = " & ", ...)

# Default S3 method
fct_to_combine(..., sep = " & ")
```

## Arguments

- ...:

  (vector method) One-dimensional atomic vectors of equal length to
  combine. Raw vectors must be converted explicitly before use. Must be
  empty for the data.frame method. A single character vector of column
  names (length \>= 2) is resolved through `dplyr::pick(all_of(.))` when
  called inside a data-masking verb, enabling
  `mutate(g = fct_to_combine(c("sex", "age")))`. This shortcut always
  interprets a character vector of length \>= 2 as column names; use
  `factor(x)` to combine a single character vector of values. Grouping
  columns are unavailable to
  [`pick()`](https://dplyr.tidyverse.org/reference/pick.html); pass such
  columns directly as vectors or use the data.frame method. Repeated,
  missing and empty column names are rejected. Names attached to a
  column-name vector are ignored. Vector names do not affect
  combinations. The name `sep` is reserved for the separator; combine a
  column named `sep` with the data.frame method, or remove column-list
  names before [`do.call()`](https://rdrr.io/r/base/do.call.html).

- x:

  First input. A factor / character / vector (vector method), OR a
  data.frame (data.frame method). A data.table input is copied before
  writing the result; keys and indices affected by replacement are
  cleared.

- vars:

  (data.frame method) One-dimensional character vector of \>= 2 column
  names to combine. Names must be unique, non-missing and non-empty, and
  identify unambiguous columns in the data frame.

- var_name:

  (data.frame method) Name of the new column. Default `NULL` =
  `paste(vars, collapse = "_")`. Otherwise a single non-missing,
  non-empty string. An existing column of this name is replaced. A name
  matching multiple existing columns is rejected.

- sep:

  A single non-missing string separating cell values. Default `" & "`;
  an empty string is allowed.

## Value

A factor (vector method) of length `length(..1)`; or the input data
frame with the combined column appended (data.frame method).

## Details

Conceptually similar to
[`forcats::fct_cross()`](https://forcats.tidyverse.org/reference/fct_cross.html)
and [`base::interaction()`](https://rdrr.io/r/base/interaction.html),
but with a default separator (`" & "`) tuned for clinical /
epidemiological group labels. For regrouping levels of a single factor
(the dual operation), see
[`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md).

A row is missing if any input is missing according to its
[`is.na()`](https://rdrr.io/r/base/NA.html) method, including `NaN` and
SPSS user-missing values and ranges. The literal string `"NA"` remains
an ordinary category. If distinct combinations produce the same label,
the function errors; choose a different `sep` or relabel the inputs to
disambiguate them.

## See also

[`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md),
[`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md),
[`fct_label()`](https://hui950319.github.io/UtilsR/reference/fct_label.md)

Other factor tools:
[`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md),
[`fct_label()`](https://hui950319.github.io/UtilsR/reference/fct_label.md),
[`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md),
[`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md)

## Examples

``` r
df <- data.frame(
  sex = factor(rep(c("F", "M"), each = 3)),
  age = factor(rep(c("young", "mid", "old"), 2),
               levels = c("young", "mid", "old"))
)

# ---- vector method ----
fct_to_combine(df$sex, df$age)
#> [1] F & young F & mid   F & old   M & young M & mid   M & old  
#> Levels: F & young F & mid F & old M & young M & mid M & old
fct_to_combine(df$sex, df$age, sep = "_")
#> [1] F_young F_mid   F_old   M_young M_mid   M_old  
#> Levels: F_young F_mid F_old M_young M_mid M_old

# ---- data.frame method (appends a column, pipe-friendly) ----
fct_to_combine(df, c("sex", "age"))                       # new col "sex_age"
#>   sex   age   sex_age
#> 1   F young F & young
#> 2   F   mid   F & mid
#> 3   F   old   F & old
#> 4   M young M & young
#> 5   M   mid   M & mid
#> 6   M   old   M & old
fct_to_combine(df, c("sex", "age"), var_name = "group")   # new col "group"
#>   sex   age     group
#> 1   F young F & young
#> 2   F   mid   F & mid
#> 3   F   old   F & old
#> 4   M young M & young
#> 5   M   mid   M & mid
#> 6   M   old   M & old

# Inside mutate (vector method, most natural usage)
# \donttest{
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
df %>% mutate(grp = fct_to_combine(sex, age))
#>   sex   age       grp
#> 1   F young F & young
#> 2   F   mid   F & mid
#> 3   F   old   F & old
#> 4   M young M & young
#> 5   M   mid   M & mid
#> 6   M   old   M & old
df %>% mutate(grp = fct_to_combine(c("sex", "age")))
#>   sex   age       grp
#> 1   F young F & young
#> 2   F   mid   F & mid
#> 3   F   old   F & old
#> 4   M young M & young
#> 5   M   mid   M & mid
#> 6   M   old   M & old
# pipe with the data.frame method
df |> fct_to_combine(c("sex", "age"), var_name = "group")
#>   sex   age     group
#> 1   F young F & young
#> 2   F   mid   F & mid
#> 3   F   old   F & old
#> 4   M young M & young
#> 5   M   mid   M & mid
#> 6   M   old   M & old
# }
```
