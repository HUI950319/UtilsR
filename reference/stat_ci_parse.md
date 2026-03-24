# Parse Confidence Interval Strings

Extract components from CI strings like `"1.23 (0.95, 1.59)"`, compute
p-values, adjust confidence levels, and optionally add stars.

## Usage

``` r
stat_ci_parse(
  x,
  output = c("ci", "p", "ci_p", "ci_star", "p_star"),
  level = NULL,
  exp = "auto",
  digits = NULL,
  map_signif = c(`***` = 0.001, `**` = 0.01, `*` = 0.05)
)
```

## Arguments

- x:

  Character vector of CI strings (e.g. `"1.23 (0.95, 1.59)"`).

- output:

  What to return:

  `"ci"`

  :   (default) CI string (adjusted if `level` is set).

  `"p"`

  :   Numeric p-value vector.

  `"ci_p"`

  :   CI string with p-value appended.

  `"ci_star"`

  :   CI string with significance stars.

  `"p_star"`

  :   Formatted p-value with stars.

- level:

  Target confidence level for CI adjustment (e.g. `0.90`). Default
  `NULL` keeps original 95% CI.

- exp:

  Exp-transformation detection: `"auto"` (default), `TRUE`, or `FALSE`.

- digits:

  Integer, decimal places for output. Default: auto-detect from input.

- map_signif:

  Named numeric vector for star thresholds. Only used when `output` is
  `"ci_star"` or `"p_star"`.

## Value

Character vector (for ci/ci_p/ci_star/p_star) or numeric vector (for p).

## See also

Other stat formatting:
[`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md),
[`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)

## Examples

``` r
# Basic: return CI as-is
stat_ci_parse("1.23 (0.95, 1.59)")
#> [1] "1.23 (0.95, 1.59)"

# Extract p-value
stat_ci_parse("2.45 (1.20, 4.80)", output = "p")
#> [1] 0.01128313

# CI with stars
stat_ci_parse(c("2.45 (1.20, 4.80)", "1.23 (0.95, 1.59)"), output = "ci_star")
#> [1] "2.45 (1.20, 4.80)*" "1.23 (0.95, 1.59)" 

# CI with p-value
stat_ci_parse("2.45 (1.20, 4.80)", output = "ci_p")
#> [1] "2.45 (1.20, 4.80), p=0.011"

# Adjust confidence level
stat_ci_parse("1.23 (0.95, 1.59)", level = 0.90)
#> [1] "1.23 (0.99, 1.53)"

# In mutate()
# df %>% mutate(p = stat_ci_parse(hr_ci, output = "p"))
# df %>% mutate(hr_star = stat_ci_parse(hr_ci, output = "ci_star"))
```
