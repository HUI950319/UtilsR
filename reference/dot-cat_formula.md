# Announce a model and its formula

One
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
line naming the model (Cox, CRR or logistic), whether it is adjusted,
and its formula, e.g. `Cox model, unadjusted: Surv(time, DSS) ~ Sex`.
The model type comes from the number of distinct non-missing outcome
values and whether there is a time variable.
[`suppressMessages()`](https://rdrr.io/r/base/message.html) silences it.

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

## Value

`NULL`, invisibly.

## See also

Other console display:
[`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md),
[`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
[`.cat_saved()`](https://hui950319.github.io/UtilsR/reference/dot-cat_saved.md),
[`.cat_step()`](https://hui950319.github.io/UtilsR/reference/dot-cat_step.md),
[`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)

## Examples

``` r
formula_data <- data.frame(
  DSS = c(0, 1, 1, 0),
  time = c(5, 8, 12, 15),
  age = c(45, 52, 61, 39)
)
.cat_formula(formula_data, co_var = "age")
#> [2026-10-29 23:27:46]  ℹ Cox model, unadjusted: Surv(time, DSS) ~ age 
```
