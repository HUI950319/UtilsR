# Unified Factor Manipulation

One function for all single-vector factor operations. Auto-detects the
action from arguments. For combining multiple columns into one factor,
see \[fct\_to\_combine()\]. For grouping levels by integer indices with
auto-named groups (e.g. \`g1/3\`), see \[fct\_to\_group()\].

## Usage

``` r
fct_cat(
  x,
  ...,
  reverse = FALSE,
  binary_ref = NULL,
  groups = NULL,
  new_labels = NULL
)
```

## Arguments

  - x:
    
    A factor or character vector.

  - ...:
    
    For recode: named args (new = old). For reorder: level names or
    integer indices in desired order (unnamed). Must be ALL named or ALL
    unnamed.

  - reverse:
    
    Logical. Reverse all levels? Default `FALSE`.

  - binary\_ref:
    
    Integer index(es) of reference level(s). Others collapse to `"Oth"`.

  - groups:
    
    Named list of integer index vectors for custom grouping, e.g.
    `list(early = 1:2, late = 3:4)`.

  - new\_labels:
    
    Character vector to rename levels (same length as levels).

## Value

A factor.

## See also

Other factor tools: `fct_label()`, `fct_num()`, `fct_to_combine()`,
`fct_to_group()`

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

# Reorder (unnamed ...): by level name or by integer index
fct_cat(factor(letters[1:4]), "c", "b")
#> [1] a b c d
#> Levels: c b a d
fct_cat(factor(letters[1:4]), 3, 2)
#> [1] a b c d
#> Levels: c b a d

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

# For combining multiple columns into one factor, use [fct_to_combine()]:
if (FALSE) { # \dontrun{
df %>% mutate(grp = fct_to_combine(sex, age))
fct_to_combine(df$sex, df$age)
} # }
```
