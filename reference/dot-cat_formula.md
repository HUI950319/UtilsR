# Print model formula with styled header

Displays a model formula (Cox, CRR, or logistic) with a styled box and
separator. Automatically detects model type from the number of distinct
outcome levels and presence of a time variable.

## Usage

``` r
.cat_formula(
  data,
  co_var,
  time = "time",
  outcome = "DSS",
  type = c("info", "success", "warning", "error")
)
```

## Arguments

  - data:
    
    A data.frame containing the outcome column.

  - co\_var:
    
    Character vector of covariate names.

  - time:
    
    Character or `NULL`. Name of the time variable (`NULL` for logistic
    models).

  - outcome:
    
    Character. Name of the outcome variable (default `"DSS"`).

  - type:
    
    One of `"info"`, `"success"`, `"warning"`, `"error"`.

## Value

Invisibly returns `NULL` after printing the formula.

## See also

Other console display: `.cat_box()`, `.cat_line()`, `.cat_message()`,
`.cat_tb()`

## Examples

``` r
formula_data <- data.frame(
  DSS = c(0, 1, 1, 0),
  time = c(5, 8, 12, 15),
  age = c(45, 52, 61, 39)
)
.cat_formula(formula_data, co_var = "age")
#> 
#>                            ╭─────────────────────────╮
#>                            │                         │
#>                            │   ℹ unadj cox model ℹ   │
#>                            │                         │
#>                            ╰─────────────────────────╯
#> =========================   ℹ Surv(time, DSS) ~ age ℹ   ========================
#> 
#> 
```
