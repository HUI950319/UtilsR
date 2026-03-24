# Format Confidence Intervals or Mean (SD)

Build CI strings from numeric vectors, or reformat existing CI strings
with different brackets and separators. Automatically detects CI mode (3
vectors) or SD mode (2 vectors) for numeric input.

## Usage

``` r
stat_ci(
  x,
  y = NULL,
  z = NULL,
  digits = NULL,
  bracket = c("(", "["),
  sep = c("–", ", ", " to ")
)
```

## Arguments

- x:

  Numeric vector (estimate/mean) or character vector (CI strings to
  reformat).

- y:

  Numeric vector: lower CI bound (CI mode) or SD (SD mode). Ignored when
  `x` is character.

- z:

  Numeric vector (optional): upper CI bound. If provided, CI mode is
  used; otherwise SD mode. Ignored when `x` is character.

- digits:

  Integer, number of decimal places (default: 2 for CI, 1 for SD). For
  character input, default is auto-detected from the string.

- bracket:

  Character, bracket type: `"("` (default) or `"["`.

- sep:

  Character, separator between CI bounds (default: en dash). Only used
  in CI mode. Common choices: `"\u2013"`, `", "`, `" to "`.

## Value

Character vector of formatted strings.

## See also

Other stat formatting:
[`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md),
[`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)

## Examples

``` r
# --- Numeric: CI mode (3 arguments) ---
stat_ci(1.23, 0.95, 1.51)
#> [1] "1.23 (0.95–1.51)"
# "1.23 (0.95\u20131.51)"

stat_ci(1.23, 0.95, 1.51, bracket = "[", sep = " to ")
#> [1] "1.23 [0.95 to 1.51]"
# "1.23 [0.95 to 1.51]"

# --- Numeric: SD mode (2 arguments) ---
stat_ci(1.23, 0.15)
#> [1] "1.2(0.1)"
# "1.2(0.2)"

# --- Character: reformat CI strings ---
stat_ci("1.23 (0.95, 1.59)", bracket = "[", sep = "\u2013")
#> [1] "1.23 [0.95–1.59]"
# "1.23 [0.95\u20131.59]"

stat_ci("1.23 [0.95\u20131.59]", sep = " to ", bracket = "(")
#> [1] "1.23 (0.95 to 1.59)"
# "1.23 (0.95 to 1.59)"

# --- In mutate() ---
# df %>% mutate(ci = stat_ci(est, ci_low, ci_high))
# df %>% mutate(ci_new = stat_ci(ci_old, bracket = "["))
```
