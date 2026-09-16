# Relabel factor levels (generic: vector or data-frame column)

S3 generic that renames the levels of a factor. Dispatches on the first
argument:

  - **vector / factor** – `fct_label(x, labels)` relabels the vector
    directly (thin wrapper around \[fct\_cat()\] with `new_labels`).

  - **data.frame** – `fct_label(data, var, labels)` relabels a single
    column **in place** and returns the whole data frame, so it chains
    in a `%>%` / `|>` pipeline. The column may be a bare name (NSE) or a
    character string.

## Usage

``` r
fct_label(x, ...)

# S3 method for class 'data.frame'
fct_label(x, var, labels, ...)

# Default S3 method
fct_label(x, labels, ...)
```

## Arguments

  - x:
    
    A factor / character vector, or a data.frame.

  - ...:
    
    Passed to methods (currently unused).

  - var:
    
    (data.frame method only) Column to relabel. Bare column name (NSE,
    e.g. `Sex`) or character string (e.g. `"Sex"`).

  - labels:
    
    Character vector of new level labels, in current level order and the
    same length as the existing levels.

## Value

Same type as `x`: a factor for the vector method, or the input data
frame (with `var` relabelled) for the data.frame method.

## Details

This is the packaged form of the legacy FeatureAnalysis helper
`.fct_label()`. For other single-vector factor operations (reorder,
binary, group), see \[fct\_cat()\]; for numeric binning see
\[fct\_num()\].

## See also

\[fct\_cat()\], \[fct\_num()\], \[fct\_to\_combine()\]

Other factor tools: `fct_cat()`, `fct_num()`, `fct_to_combine()`,
`fct_to_group()`

## Examples

``` r
# ---- vector method ----
g <- factor(c("I", "II", "III", "II", "I"))
fct_label(g, c("Low", "Mid", "High"))
#> [1] Low  Mid  High Mid  Low 
#> Levels: Low Mid High

# ---- data.frame method ----
df <- data.frame(
  grade = factor(c("I", "II", "III", "II", "I")),
  sex   = factor(c("m", "f", "f", "m", "f"))
)
fct_label(df, grade, labels = c("Low", "Mid", "High"))   # bare name (NSE)
#>   grade sex
#> 1   Low   m
#> 2   Mid   f
#> 3  High   f
#> 4   Mid   m
#> 5   Low   f
fct_label(df, "sex", labels = c("Female", "Male"))       # string
#>   grade    sex
#> 1     I   Male
#> 2    II Female
#> 3   III Female
#> 4    II   Male
#> 5     I Female

# chains in a pipeline
if (FALSE) { # \dontrun{
df |>
  fct_label(grade, c("Low", "Mid", "High")) |>
  fct_label(sex,   c("Female", "Male"))
} # }
```
