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

- add_star_p:

  Numeric vector of p-values for star annotation. When provided, stars
  are appended to `x` based on these p-values.

- digits:

  Integer, decimal places (default: 3 for stars/pvalue, 2 for plain).
  Ignored when `add_star_p` is provided.

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
  `c("***" = 0.001, "**" = 0.01, "*" = 0.05, "." = 0.1)`.

## Value

Character vector of formatted values.

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
