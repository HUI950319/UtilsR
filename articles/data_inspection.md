# Data Inspection: lv, na, check_system

## `lv()` — Variable Summary

[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) provides a
quick overview of variables in a data frame (or Seurat object). It
invisibly returns the original data. In a knitted document, use
`results = "asis"` so the native report tables render directly.

``` r

library(UtilsR)

# All variables
lv(iris)
```

| **Variable Summary** |  |  |  |  |  |
|----|----|----|----|----|----|
| Dataset: *150* observations, *5* variables, *0* missing, *0* Unknown/Blank/N/A |  |  |  |  |  |
| vars | class | n_unique | n_na | n_special | unique |
| Sepal.Length | numeric | 35 | 0 | 0 | get_flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","...")) |
| Sepal.Width | numeric | 23 | 0 | 0 | get_flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","...")) |
| Petal.Length | numeric | 43 | 0 | 0 | get_flt(Petal.Length %in% c("1.4","1.3","1.5","1.7","1.6","1.1","1.2","1","...")) |
| Petal.Width | numeric | 22 | 0 | 0 | get_flt(Petal.Width %in% c("0.2","0.4","0.3","0.1","0.5","0.6","1.4","1.5","...")) |
| Species | factor | 3 | 0 | 0 | get_flt(Species %in% c("setosa","versicolor","virginica")) |

[TABLE]

``` r

# Select specific variables
lv(iris, Species, Sepal.Length)
```

| **Variable Summary** |  |  |  |  |  |
|----|----|----|----|----|----|
| Dataset: *150* observations, *2* variables, *0* missing, *0* Unknown/Blank/N/A |  |  |  |  |  |
| vars | class | n_unique | n_na | n_special | unique |
| Species | factor | 3 | 0 | 0 | get_flt(Species %in% c("setosa","versicolor","virginica")) |
| Sepal.Length | numeric | 35 | 0 | 0 | get_flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","...")) |

[TABLE]

``` r

# Regex pattern matching
lv(iris, pattern = "Sepal")
```

| **Variable Summary** |  |  |  |  |  |
|----|----|----|----|----|----|
| Dataset: *150* observations, *2* variables, *0* missing, *0* Unknown/Blank/N/A |  |  |  |  |  |
| vars | class | n_unique | n_na | n_special | unique |
| Sepal.Length | numeric | 35 | 0 | 0 | get_flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","...")) |
| Sepal.Width | numeric | 23 | 0 | 0 | get_flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","...")) |

[TABLE]

``` r

# Grouped summary
lv(iris, Sepal.Length, group = "Species")
```

[TABLE]

------------------------------------------------------------------------

## `na()` — Missing Value Analysis

``` r

# Create data with NAs
df <- data.frame(
  x = c(1, NA, 3, NA, 5),
  y = c("a", "b", NA, "d", "e"),
  z = 1:5
)
check_na(df)
#> ======   ℹ Data quality analysis: 2 variables with data quality issues ℹ   =====
```

| **Missing & Special Value Analysis** |  |  |  |
|----|:--:|:--:|----|
| Dataset: *5* observations, *3* variables, *2* variables with missing values, *0* variables with special values |  |  |  |
| **Variable** | **Missing** | **Unknown/Blank/N/A** | **Data Type** |
| x | 2 (40.0%) | 0 (0.0%) | numeric |
| y | 1 (20.0%) | 0 (0.0%) | character |
| **Summary:** 3 missing values (20.00%), 0 special values (0.00%) out of 15 total data points |  |  |  |
| **Shading:** missing values \>0-20% yellow, \>20-50% orange, \>50% red; special values \>0-10%, \>10-30%, \>30% light to dark blue |  |  |  |

------------------------------------------------------------------------

## `check_system()` — System Diagnostics

``` r

check_system()
```

Reports OS, R version, memory, CPU info, and loaded packages.

## `check_size()` — Object Memory Profiling

``` r

check_size()
```

Shows memory usage of all objects in the global environment, even when
called inside a function. Pass `envir = environment()` to inspect the
calling function’s objects instead, and `method = "lobstr"` for a total
that counts storage shared between objects once.
