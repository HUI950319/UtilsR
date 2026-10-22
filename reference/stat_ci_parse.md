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

  Character vector of CI strings (e.g. `"1.23 (0.95, 1.59)"`). Brackets
  `()` or `[]`; separators `,` `;` `-` `~` en/em dash or `to`; numbers
  may carry a sign or an exponent. Full-width punctuation, the Unicode
  minus and an en or em dash written as a minus sign before a number are
  accepted. Trailing stars are ignored, other trailing text is dropped
  with a warning, and `NA` / `""` pass through silently.

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

  Scale of the interval: `TRUE` for ratios (HR, OR, RR; null = 1, normal
  approximation on the log scale), `FALSE` for differences (null = 0),
  or `"auto"` (default) to infer it. Set it explicitly whenever the
  effect measure is known. See Details.

- digits:

  Integer, decimal places for output. Default: the most decimals among
  the estimate and its bounds, so `output = "ci"` without `level` does
  not round the input; at least one with `level`.

- map_signif:

  Named numeric vector for star thresholds. Only used when `output` is
  `"ci_star"` or `"p_star"`.

## Value

Character vector (for ci/ci_p/ci_star/p_star) or numeric vector (for p),
with the names of `x`.

## Details

The input is read as a 95% CI and the p-value is backed out with the
normal approximation of Altman & Bland (BMJ 2011;343:d2304): \\SE =
(hi - lo) / (2 \times 1.96)\\ on the working scale. An interval at
another level (e.g. a 90% CI) is still read as 95% and gives a wrong
p-value; convert it first.

**`exp = "auto"`.** An interval symmetric on the log scale is a ratio,
and one symmetric on the raw scale is a difference; bounds \\\le 0\\
rule out a ratio. The comparison allows for the rounding of the printed
digits, so a narrow interval such as `"0.98 (0.95, 1.01)"` fits both
scales. Such an interval takes the scale of the intervals in `x` that
can be decided, provided they all agree. Otherwise it is treated as a
ratio, with a warning.

**Asymmetric intervals.** An interval that stays clearly asymmetric on
its scale gets a warning (exact, profile-likelihood or bootstrap
intervals, or a typo). The threshold is \\\|hi + lo - 2 est\| / (hi -
lo) \> 0.2\\ after allowing for rounding. Its SE comes from the half of
the interval facing the null, so `p < 0.05` exactly when the interval
excludes the null. `level` rescales each half separately, so
`level = 0.95` returns the interval unchanged.

**Invalid intervals.** If the estimate lies outside its bounds, the
width is zero, or a bound is \\\le 0\\ under `exp = TRUE`, the string is
returned as-is and its p-value is `NA`, with a warning.

With `level`, the p-value is read off the re-levelled interval as if it
were a 95% CI. Its stars therefore agree with the interval shown and are
not the p-value of the original test.

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
