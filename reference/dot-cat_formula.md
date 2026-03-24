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

- co_var:

  Character vector of covariate names.

- time:

  Character or `NULL`. Name of the time variable (`NULL` for logistic
  models).

- outcome:

  Character. Name of the outcome variable (default `"DSS"`).

- type:

  One of `"info"`, `"success"`, `"warning"`, `"error"`.
