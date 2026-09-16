# Combine Multiple Vectors / Columns into a Single Factor (generic)

S3 generic that pastes several vectors cell-wise into one factor. Levels
are the unique combinations sorted by each input's factor-level order
(preserving meaningful orderings such as TNM stages or graded
categories), not alphabetic. Dispatches on the first argument:

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
    
    (vector method) Further vectors of equal length to combine. A single
    character vector of column names (length \>= 2) is resolved through
    `dplyr::pick(all_of(.))` when called inside a data-masking verb,
    enabling `mutate(g = fct_to_combine(c("sex", "age")))`.

  - x:
    
    First input. A factor / character / vector (vector method), OR a
    data.frame (data.frame method).

  - vars:
    
    (data.frame method) Character vector of \>= 2 column names to
    combine.

  - var\_name:
    
    (data.frame method) Name of the new column. Default `NULL` =
    `paste(vars, collapse = "_")`.

  - sep:
    
    Separator between cell values. Default `" & "`.

## Value

A factor (vector method) of length `length(..1)`; or the input data
frame with the combined column appended (data.frame method).

## Details

Conceptually similar to `forcats::fct_cross()` and
`base::interaction()`, but with a default separator (`" & "`) tuned for
clinical / epidemiological group labels. For regrouping levels of a
single factor (the dual operation), see \[fct\_to\_group()\].

## See also

\[fct\_to\_group()\], \[fct\_cat()\], \[fct\_label()\]

Other factor tools: `fct_cat()`, `fct_label()`, `fct_num()`,
`fct_to_group()`

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
if (FALSE) { # \dontrun{
library(dplyr)
df %>% mutate(grp = fct_to_combine(sex, age))
df %>% mutate(grp = fct_to_combine(c("sex", "age")))
# pipe with the data.frame method
df |> fct_to_combine(c("sex", "age"), var_name = "group")
} # }
```
