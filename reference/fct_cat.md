# Unified Factor Manipulation

One function for all factor operations. Works on vectors (usable in
`mutate()`) and auto-detects the action from arguments.

## Usage

``` r
fct_cat(
  x,
  ...,
  reverse = FALSE,
  binary_ref = NULL,
  groups = NULL,
  new_labels = NULL,
  combine = NULL,
  sep = " & "
)
```

## Arguments

- x:

  A factor or character vector. For `combine` mode this is optional – if
  missing, all columns listed in `combine` are used.

- ...:

  For recode: named args (new = old). For reorder: level names in
  desired order (unnamed strings). Must be ALL named or ALL unnamed.

- reverse:

  Logical. Reverse all levels? Default `FALSE`.

- binary_ref:

  Integer index(es) of reference level(s). Others collapse to `"Oth"`.

- groups:

  Named list of integer index vectors for custom grouping, e.g.
  `list(early = 1:2, late = 3:4)`.

- new_labels:

  Character vector to rename levels (same length as levels).

- combine:

  Character vector of column names to combine. Works inside `mutate()`.
  If `x` is provided, it is combined with the listed columns. If `x` is
  missing, all listed columns are combined.

- sep:

  Separator for combine. Default `" & "`.

## Value

A factor.

## See also

Other factor tools:
[`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)

## Examples

``` r
x <- factor(letters[1:6])

# Recode (named ...)
fct_cat(x, AB = c("a","b"), CD = c("c","d"))
#> [1] AB AB CD CD e  f 
#> Levels: AB CD e f
fct_cat(x, g1 = 1:3, g2 = 4:6)
#> [1] g1 g1 g1 g2 g2 g2
#> Levels: g1 g2

# Reorder (unnamed ...)
fct_cat(factor(letters[1:4]), "c", "b")
#> [1] a     d
#> Levels:  a d

# Reverse
fct_cat(factor(letters[1:4]), reverse = TRUE)
#> [1] a b c d
#> Levels: d c b a

# Binary
fct_cat(factor(c("I","II","III","IV")), binary_ref = 1)
#> [1] I   Oth Oth Oth
#> Levels: I Oth

# Group
fct_cat(factor(c("I","II","III","IV")), groups = list(early = 1:2, late = 3:4))
#> [1] early early late  late 
#> Levels: early late

# Relabel
fct_cat(factor(c("I","II","III","IV")), new_labels = c("One","Two","Three","Four"))
#> [1] One   Two   Three Four 
#> Levels: One Two Three Four

# Combine in mutate():
if (FALSE) { # \dontrun{
df %>% mutate(grp = fct_cat(sex, combine = "age"))
df %>% mutate(grp = fct_cat(sex, combine = c("age", "race")))
df %>% mutate(grp = fct_cat(combine = c("sex", "age")))
} # }
```
