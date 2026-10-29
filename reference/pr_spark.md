# One-line distribution of each column

Print one line per column: its name, a sparkline of its distribution, a
short summary and the share of missing values, for a quick look at a
data set before modelling.

## Usage

``` r
pr_spark(data, vars = NULL, bins = 12, indent = 2)
```

## Arguments

- data:

  A data frame (tibbles included).

- vars:

  Character. Columns to show; `NULL` (default) shows all.

- bins:

  Integer. Histogram bins, and the most levels drawn for a categorical
  column (default 12).

- indent:

  Integer. Spaces before each line (default 2).

## Value

The printed lines, invisibly.

## Details

Numeric columns show a histogram of `bins` equal-width bins over the
finite values, with their mean and SD (3 significant digits); whole
numbers with no more distinct values than `bins` get one bar per value,
so no empty bin falls between two values. Date and date-time columns
show the same histogram with their first and last dates. Factor,
character and logical columns show their level counts (in level order,
or the `bins` most frequent levels when there are more), the number of
levels and the most frequent one with its share of non-missing values;
one whose values all differ, such as an identifier, shows how many there
are. Other columns show their class only. SPSS user-missing values are
excluded from summaries and counted in the missing share, consistently
with ordinary missing values.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
set.seed(1)
df <- data.frame(age = rnorm(200, 56, 11),
                 stage = factor(sample(c("I", "II", "III"), 200, TRUE)),
                 size_mm = rlnorm(200, 2.6, 0.5))
pr_spark(df)
#>   age      ▁▂▃▄██▆▆▄▃▁▂  mean 56.4  sd 10.2        NA 0.0%
#>   stage    █▇▇           3 levels · top I (37.5%)  NA 0.0%
#>   size_mm  ▇█▅▃▂▁▁▁▁▁▁▁  mean 15.5  sd 9.00        NA 0.0%
```
