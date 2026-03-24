# Compute Cohen's d Effect Size by Group

Calculate Cohen's d for each variable across groups, comparing each
group to the overall sample. Supports continuous and categorical
(one-hot encoded) variables.

## Usage

``` r
stat_cohen(data, group, vars, onehot = TRUE, col_labels = NULL)
```

## Arguments

- data:

  A data frame.

- group:

  Character, name of the grouping variable (factor).

- vars:

  Character vector of variable names to compare.

- onehot:

  Logical. If `TRUE` (default), categorical variables are one-hot
  encoded before computing Cohen's d.

- col_labels:

  Optional named character vector for renaming variables in the output
  (e.g. `c(age = "Age (years)")`).

## Value

A data frame with columns: `Variable` and one column per group level,
containing Cohen's d values.

## Note

Requires the effsize package. For one-hot encoding, fastDummies is also
needed.

## Examples

``` r
# Basic: continuous variables
stat_cohen(iris, group = "Species",
           vars = c("Sepal.Length", "Sepal.Width"))
#>       Variable     setosa versicolor  virginica
#> 1 Sepal.Length -1.1324106  0.1214746  0.9487421
#> 2  Sepal.Width  0.8772742 -0.7024173 -0.2028886

# With column label mapping
stat_cohen(iris, group = "Species",
           vars = c("Sepal.Length", "Sepal.Width"),
           col_labels = c(Sepal.Length = "Sepal L.", Sepal.Width = "Sepal W."))
#>   Variable     setosa versicolor  virginica
#> 1 Sepal L. -1.1324106  0.1214746  0.9487421
#> 2 Sepal W.  0.8772742 -0.7024173 -0.2028886

# Mixed variables with one-hot encoding
df <- data.frame(
  group = factor(sample(c("A","B","C"), 100, TRUE)),
  age = rnorm(100, 50, 10),
  sex = factor(sample(c("M","F"), 100, TRUE)),
  stage = factor(sample(c("I","II","III"), 100, TRUE))
)
stat_cohen(df, group = "group", vars = c("age", "sex", "stage"))
#>    Variable            A           B           C
#> 1       age  0.152936711 -0.04949980 -0.03634952
#> 2     sex_M -0.009060075 -0.03737443  0.03041184
#> 3   stage_I  0.017522616  0.07194424 -0.05930769
#> 4  stage_II  0.007510451  0.03094770 -0.02524949
#> 5 stage_III -0.024969200 -0.10397398  0.08286605

# Without one-hot (numeric variables only)
stat_cohen(df, group = "group", vars = "age", onehot = FALSE)
#>   Variable         A          B           C
#> 1      age 0.1529367 -0.0494998 -0.03634952
```
