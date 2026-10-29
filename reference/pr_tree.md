# Structure tree of a nested result object

Print the elements of a list-based result as a tree, each with a short
description such as `<tibble 12 x 7>`, `<chr 3> "Age", "Sex", "Stage"`
or `<ggplot>`; clearer than [`str()`](https://rdrr.io/r/utils/str.html)
for the nested lists that analysis functions return. Atomic vectors show
their first values, as many as fit the console width, a data frame its
column names, and a list left closed at `max_depth` its names with the
value of each single one (an unnamed list an ellipsis). POSIXlt
date-times display as equivalent POSIXct vectors. Sibling names line up
in a column. Types and sizes are grey, values in the text colour with
`NA` in red, and the names of elements that hold others bold; a classed
list starts with its class as a chip. Closed previews restore methods
for stored classed values; SPSS user-missing values display as `NA`.

## Usage

``` r
pr_tree(x, max_depth = 3, max_items = 20, max_lines = 200, attrs = TRUE)
```

## Arguments

- x:

  A list or list-based object.

- max_depth:

  Non-negative integer, or `Inf`. Levels below the root to show (default
  3).

- max_items:

  Non-negative integer, or `Inf`. Elements per node before the rest are
  summarised as "... n more", with their names (default 20).

- max_lines:

  Non-negative integer, or `Inf`. Lines shown in all (default 200); a
  grey footer counts the rest.

- attrs:

  Logical. Show extra attributes (default `TRUE`).

## Value

The printed lines, invisibly.

## Details

The object passed in always opens: a model fit lists its components, a
data frame its columns and an S4 object its slots (as `@name`). Below it
the tree descends into plain lists and into classed objects that also
inherit from `"list"` (as `c("eff_res", "list")` does). Data frames,
plots and other objects are leaves, and so are gt tables, RegR pages and
htmltools tag lists, which are lists underneath; R6 and other classed
environments show their class. Attributes other than names, class,
dimensions, row names, srcref and those a type keeps for itself (factor
levels, a time zone, value labels) are listed under an open node, marked
`attr`, and named at the end of a closed node's line as `[attr: name]`.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)

## Examples

``` r
res <- structure(
  list(Overall = list(table = data.frame(term = "Age", HR = 1.8),
                      method = "cox"),
       Subgroup = data.frame(term = c("Male", "Female"), HR = c(1.2, 1.4))),
  class = c("eff_res", "list"),
  analysis = list(n = 120, outcome = "DSS")
)
pr_tree(res)
#>  eff_res  <list 2>
#> ├─Overall  <list 2>
#> │ ├─table  <data.frame 1 x 2> term, HR
#> │ └─method <chr> "cox"
#> ├─Subgroup <data.frame 2 x 2> term, HR
#> └─attr analysis <list 2> n = 120, outcome = "DSS"
```
