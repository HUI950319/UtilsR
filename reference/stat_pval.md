# Format P-values, Numbers, or Add Stars to Any Value

Unified formatting for p-values and plain numbers. When `x` is provided
alone, formats p-values. When `add_star_p` is also provided, appends
significance stars to `x` based on `add_star_p`.

## Usage

``` r
stat_pval(
  x,
  add_star_p = NULL,
  digits = NULL,
  mode = c("stars", "pvalue", "plain"),
  map_signif = c(`***` = 0.001, `**` = 0.01, `*` = 0.05, . = 0.1)
)
```

## Arguments

- x:

  Numeric/character vector of p-values (when `add_star_p` is NULL), or
  any value to annotate with stars (when `add_star_p` is provided).
  Numeric strings may use scientific notation. Strings beginning with
  `<`, `<=`, `>`, `>=`, or their Unicode equivalents are returned with
  outer whitespace removed, without inferring stars. ASCII and Unicode
  whitespace is accepted around numbers and after a bound operator;
  whitespace within a number is not accepted. Other non-numeric strings
  are rejected. In P-value modes, observed values and numeric bound
  endpoints must be finite and between 0 and 1. Strict bounds `<0` and
  `>1` are rejected because they cannot describe a possible P-value.
  Ordinary numbers in `plain` mode are not restricted to that range.
  Numeric input must not use `integer64`, date, date-time, or time-span
  storage; convert such values explicitly before formatting. Matrix and
  array inputs are not supported. A logical vector is accepted only when
  all its elements are missing.

- add_star_p:

  Numeric vector of p-values for star annotation. When provided, stars
  are appended to `x` based on these p-values. Missing values in `x`
  remain missing; a missing P-value leaves non-missing text unchanged.
  Observed P-values must be finite and between 0 and 1. Matrix and array
  inputs are not supported. An entirely missing logical vector is also
  accepted.

- digits:

  Single integer, decimal places (default: 3 for stars/pvalue, 2 for
  plain). Must be at least 1 for P-value modes or 0 for `plain`. At most
  8190; a sign or a longer integer part can lower this limit to keep
  each formatted number within the 8192-byte limit of `sprintf`. Ignored
  when `add_star_p` is provided.

- mode:

  Formatting mode (ignored when `add_star_p` is provided):

  `"stars"`

  :   (default) P-value with significance stars.

  `"pvalue"`

  :   P-value with `"<0.001"` for small values.

  `"plain"`

  :   Plain number formatting.

- map_signif:

  Named numeric vector of significance thresholds. Default:
  `c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)`. Thresholds
  must be finite, non-missing values between 0 and 1, with non-missing
  names. Empty symbols are allowed; an empty numeric vector disables
  stars. For repeated thresholds, the first symbol is used. The smallest
  threshold greater than or equal to the unrounded P-value determines
  its symbol. Ignored in `pvalue` and `plain` modes when `add_star_p` is
  NULL.

## Value

Character vector of formatted values, preserving the names of `x`. Empty
input returns a zero-length character vector.

## See also

Other stat formatting:
[`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md),
[`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)

## Examples

``` r
# --- Format p-values (x only) ---
stat_pval(c(0.0003, 0.005, 0.03, 0.08, 0.5))
#> [1] "<0.001***" "0.005**"   "0.030*"    "0.080."    "0.500"    
# "<0.001***" "0.005**"   "0.030*"    "0.080."    "0.500"

stat_pval(c(0.0003, 0.05), mode = "pvalue")
#> [1] "<0.001" "0.050" 
# "<0.001" "0.050"

stat_pval(1.2345, digits = 2, mode = "plain")
#> [1] "1.23"
# "1.23"

# --- Add stars to any value (x + add_star_p) ---
stat_pval(c(1.85, 0.72, 1.25), add_star_p = c(0.001, 0.05, 0.5))
#> [1] "1.85***" "0.72*"   "1.25"   
# "1.85***" "0.72*"   "1.25"

# With stat_ci output
# df %>% mutate(hr_ci = stat_pval(stat_ci(hr, lo, hi), add_star_p = pvalue))
```
