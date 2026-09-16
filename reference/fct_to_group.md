# Group Factor Levels by Integer Indices

Collapses factor levels into new groups specified by integer indices.
Companion to \[fct\_to\_combine()\]: where \`fct\_to\_combine()\` merges
multiple columns row-wise, \`fct\_to\_group()\` regroups levels of a
single factor.

## Usage

``` r
fct_to_group(x, g_lis, name_prefix = "g", name_sep = "/")
```

## Arguments

  - x:
    
    A factor or character vector. Character is auto-coerced via
    \`factor(x)\`.

  - g\_lis:
    
    A list of integer index vectors. Each element specifies the level
    positions to merge into one new group. Either fully named (user
    names used as new level names) or unnamed (auto-named via
    \`name\_prefix\` + \`name\_sep\`). Indices must be between 1 and
    \`nlevels(x)\`.

  - name\_prefix:
    
    Prefix for auto-generated group names. Default \`"g"\`.

  - name\_sep:
    
    Separator for auto-generated group names. Default \`"/"\`.

## Value

A factor with regrouped levels. Levels not covered by any group in
\`g\_lis\` are kept as-is (matching \[fct\_cat()\]'s behavior).

## Details

Auto-names unnamed groups as \`paste0(name\_prefix, paste(idx, collapse
= name\_sep))\`, e.g. \`g1/3\`, \`g2/4\`, \`g5\`. User-supplied list
names take precedence.

## See also

Other factor tools: `fct_cat()`, `fct_label()`, `fct_num()`,
`fct_to_combine()`

## Examples

``` r
x <- factor(c("I","II","III","IV","V"))

# Auto-named groups
fct_to_group(x, list(c(1,3), c(2,4), 5))
#> [1] g1/3 g2/4 g1/3 g2/4 g5  
#> Levels: g1/3 g2/4 g5
# -> levels: g1/3, g2/4, g5

# User-named groups (names take precedence)
fct_to_group(x, list(early = 1:2, late = 3:5))
#> [1] early early late  late  late 
#> Levels: early late
# -> levels: early, late

# Custom prefix / separator
fct_to_group(x, list(c(1,3), c(2,4), 5),
             name_prefix = "G", name_sep = "+")
#> [1] G1+3 G2+4 G1+3 G2+4 G5  
#> Levels: G1+3 G2+4 G5
# -> levels: G1+3, G2+4, G5

# In dplyr::mutate
if (FALSE) { # \dontrun{
library(dplyr)
df %>% mutate(group1 = fct_to_group(group, list(c(1,3), c(2,4), 5)))
} # }
```
