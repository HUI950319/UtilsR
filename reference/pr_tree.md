# Structure tree of a nested result object

Print the elements of a list-based result as a tree, each with a short
grey description such as `<tibble 12 x 7>`, `<chr 3>` or `<ggplot>`;
clearer than [`str()`](https://rdrr.io/r/utils/str.html) for the nested
lists that analysis functions return.

## Usage

``` r
pr_tree(x, max_depth = 3, max_items = 20, attrs = TRUE)
```

## Arguments

- x:

  A list or list-based object.

- max_depth:

  Integer. Levels below the root to show (default 3).

- max_items:

  Integer. Elements shown per node before the rest are summarised as
  "... n more" (default 20).

- attrs:

  Logical. Show extra attributes (default `TRUE`).

## Value

The printed lines, invisibly.

## Details

The tree descends into plain lists and into classed objects that also
inherit from `"list"` (as `c("eff_res", "list")` does). Data frames,
plots and other objects are leaves. Attributes other than names, class,
dimensions, row names and srcref are listed under the node that carries
them, marked `attr`.

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
#> ├─Overall <list 2>
#> │ ├─table <data.frame 1 x 2>
#> │ └─method <chr> "cox"
#> ├─Subgroup <data.frame 2 x 2>
#> └─attr analysis <list 2>
```
