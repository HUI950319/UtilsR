# Factor Manipulation: fct_cat, fct_num

``` r
library(UtilsR)
```

## `fct_cat()` — Unified Factor Operations

All factor operations in one function. Works inside
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html).

### Recode (named arguments)

``` r
x <- factor(c("I", "II", "III", "IV"))

# Recode by name
fct_cat(x, early = c("I", "II"), late = c("III", "IV"))
#> [1] early early late  late 
#> Levels: early late

# Recode by position
fct_cat(x, g1 = 1:2, g2 = 3:4)
#> [1] g1 g1 g2 g2
#> Levels: g1 g2
```

### Reorder (unnamed arguments)

``` r
# Move specific levels to front
fct_cat(x, "III", "I")
#> [1]    II    IV
#> Levels:  II IV
```

### Reverse

``` r
fct_cat(x, reverse = TRUE)
#> [1] I   II  III IV 
#> Levels: IV III II I
```

### Binary

``` r
# Binary: reference level vs "Oth" (by position index)
fct_cat(x, binary_ref = 1)   # I vs Oth
#> [1] I   Oth Oth Oth
#> Levels: I Oth
fct_cat(x, binary_ref = 3)   # III vs Oth
#> [1] Oth Oth III Oth
#> Levels: III Oth
```

### Group

``` r
fct_cat(x, groups = list(early = 1:2, late = 3:4))
#> [1] early early late  late 
#> Levels: early late
```

### Relabel

``` r
fct_cat(x, new_labels = c("One", "Two", "Three", "Four"))
#> [1] One   Two   Three Four 
#> Levels: One Two Three Four
```

### Combine columns

``` r
# Inside mutate()
df %>% mutate(grp = fct_cat(sex, combine = "age"))
df %>% mutate(grp = fct_cat(combine = c("sex", "age", "stage")))
```

------------------------------------------------------------------------

## `fct_num()` — Numeric to Factor

### Fixed cut points

``` r
ages <- c(25, 35, 45, 55, 65, 75)

# Single break
fct_num(ages, breaks = 50)
#> [1] below_50 below_50 below_50 above_50 above_50 above_50
#> Levels: below_50 above_50

# Multiple breaks
fct_num(ages, breaks = c(40, 60))
#> [1] below_40 below_40 40-60    40-60    above_60 above_60
#> Levels: below_40 40-60 above_60
```

### Quantile binning

``` r
set.seed(1)
scores <- rnorm(100, 50, 15)

# Quartiles
fct_num(scores, nbins = 4)
#>   [1] low       high      low       very_high high      low       high     
#>   [8] very_high high      medium    very_high high      low       low      
#>  [15] very_high medium    medium    very_high very_high high      very_high
#>  [22] very_high medium    low       high      medium    medium    low      
#>  [29] medium    high      very_high medium    high      medium    low      
#>  [36] medium    medium    medium    very_high very_high medium    medium   
#>  [43] very_high high      low       low       high      very_high medium   
#>  [50] very_high high      low       high      low       very_high very_high
#>  [57] medium    low       high      medium    very_high medium    high     
#>  [64] medium    low       high      low       very_high high      very_high
#>  [71] high      low       high      low       low       high      medium   
#>  [78] medium    medium    low       low       medium    very_high low      
#>  [85] high      high      very_high medium    high      high      low      
#>  [92] very_high very_high very_high very_high high      low       low      
#>  [99] low       medium   
#> Levels: low medium high very_high

# Equal-width bins
fct_num(scores, nbins = 3, type = "equal")
#>   [1] middle middle low    high   middle low    middle middle middle middle
#>  [11] high   middle middle low    high   middle middle high   middle middle
#>  [21] high   middle middle low    middle middle middle low    middle middle
#>  [31] high   middle middle middle low    middle middle middle high   middle
#>  [41] middle middle middle middle low    low    middle middle middle high  
#>  [51] middle middle middle low    high   high   middle low    middle middle
#>  [61] high   middle middle middle low    middle low    high   middle high  
#>  [71] middle low    middle low    low    middle middle middle middle middle
#>  [81] middle middle high   low    middle middle high   middle middle middle
#>  [91] middle high   high   middle high   middle low    middle low    middle
#> Levels: low middle high
```

### Custom labels

``` r
fct_num(ages, breaks = c(40, 60),
        labels = c("Young", "Middle", "Senior"))
#> [1] Young  Young  Middle Middle Senior Senior
#> Levels: Young Middle Senior
```
