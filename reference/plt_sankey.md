# Sankey Diagram for Categorical Variables

Visualise the flow/proportion changes across multiple categorical
variables using a Sankey (alluvial) diagram. Each node label shows the
level name, count, and percentage.

## Usage

``` r
plt_sankey(
  data,
  vars,
  palette = NULL,
  reverse_levels = TRUE,
  show_text = c("all", "n", "pct", "name", "all_wrap", "none"),
  flow_args = list(alpha = 0.6, fill = "grey", color = "grey80", smooth = 8),
  node_args = list(width = 0.4, space = NULL, color = NA, linewidth = NULL),
  label_args = list(size = 3, hjust = 0.5, color = "black", box = TRUE, fill = "white",
    alpha = 1, min_pct = 0, pct_accuracy = 0.1),
  base_size = 14,
  theme_use = NULL,
  save = list()
)
```

## Arguments

- data:

  A data frame.

- vars:

  Character vector selecting at least two categorical variables,
  displayed left-to-right in the given order. An unnamed vector contains
  column names and retains the existing axis labels. A named vector maps
  column names to display labels, e.g.
  `c(sex = "Sex", stage = "Stage")`. All names must be non-empty, unique
  column names; partially named vectors are not supported. Labels must
  be non-missing strings. Empty strings hide individual labels, and line
  breaks are preserved.

- palette:

  Colour palette name from
  [`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
  or a character vector of colours. Default `NULL` auto-generates
  colours per variable using sequential HCL palettes.

- reverse_levels:

  Logical, reverse factor levels for display. Default `TRUE`.

- show_text:

  Single character string. Controls node label content:

  - `"all"` (default) — name + count + percentage, e.g.
    `"A (10, 30.3%)"`.

  - `"all_wrap"` — name on the first line, with count and percentage
    together on the second line, e.g. `"A"` above `"(10, 30.3%)"`.

  - `"n"` — name + count, e.g. `"A (10)"`.

  - `"pct"` — name + percentage, e.g. `"A (30.3%)"`.

  - `"name"` — name only, e.g. `"A"`.

  - `"none"` — hide labels without removing nodes or flows.

- flow_args:

  Named list controlling flow ribbons:

  `alpha`

  :   Numeric opacity in \[0, 1\]. Default 0.6.

  `fill`

  :   Single fill colour or `NA`. Default `"grey"`.

  `color`

  :   Single border colour or `NA`. Default `"grey80"`.

  `smooth`

  :   Positive finite numeric value controlling the sigmoid curve
      steepness in ggsankey. Default 8.

- node_args:

  Named list controlling nodes and flow endpoints:

  `width`

  :   Numeric width in (0, 1\], relative to adjacent x-axis positions.
      Default 0.4.

  `space`

  :   `NULL` for automatic spacing, or a non-negative gap in count
      units. Default `NULL`; 0 removes gaps. Labels use the resulting
      node centers.

  `color`

  :   Single border colour or `NA` for no border. Default `NA`. Node
      fills are controlled by `palette`.

  `linewidth`

  :   `NULL` to retain the backend default, or a non-negative border
      width in mm. Default `NULL`.

- label_args:

  Named list controlling node labels:

  `size`

  :   Positive text size in mm. Default 3.

  `hjust`

  :   Finite numeric horizontal justification: 0 is left, 0.5 is
      centered, and 1 is right. Default 0.5.

  `color`

  :   Single text colour or `NA`. Default `"black"`.

  `box`

  :   Logical; use boxed labels when `TRUE`, plain text when `FALSE`.
      Default `TRUE`.

  `fill`

  :   Single background colour or `NA`, used only when `box = TRUE`.
      Default `"white"`.

  `alpha`

  :   Numeric opacity in \[0, 1\]. Default 1.

  `min_pct`

  :   Numeric proportion in \[0, 1\]. Show labels only when the category
      count divided by the number of input rows meets this threshold.
      Default 0; nodes and flows are never filtered.

  `pct_accuracy`

  :   Positive rounding accuracy in percentage points, used by styles
      containing percentages. Default 0.1.

- base_size:

  Positive base font size in points for the default theme. Default 14;
  ignored when `theme_use` is supplied.

- theme_use:

  `NULL` for `ggsankey::theme_sankey(base_size)`, or a theme
  specification accepted by the internal `.resolve_theme()` resolver
  (theme object, function, or function name). Default `NULL`.

- save:

  `NULL`, an empty list, or a named list forwarded to
  `RegR::save_plt()`. Allowed fields are `filename` (required), `width`
  and `height` (in inches). Writes PDF only; the saver appends the
  extension and defaults to width 10 and height 11.

## Value

A ggplot object. A non-empty `save` also writes this plot to PDF.

## Details

Each configuration list supports partial overrides; unknown, duplicate,
and empty field names are rejected. The former top-level `alpha` is now
`flow_args$alpha`; `width` and `space` are now in `node_args`;
`label_size` and `label_hjust` are now `label_args$size` and
`label_args$hjust`.

## Note

Requires the ggsankey package (`pak::pak("davidsjoberg/ggsankey")`).

## See also

Other plot:
[`PlotButterfly()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly.md),
[`PlotButterfly2()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly2.md),
[`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md),
[`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md),
[`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md),
[`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md),
[`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)

## Examples

``` r
df <- data.frame(
  sex = factor(sample(c("M","F"), 200, TRUE)),
  stage = factor(sample(c("I","II","III"), 200, TRUE)),
  grade = factor(sample(c("Low","High"), 200, TRUE))
)

# Basic sankey
plt_sankey(df, vars = c("sex", "stage", "grade"))
#> Warning: attributes are not identical across measure variables; they will be dropped
#> Warning: The `size` argument of `element_rect()` is deprecated as of ggplot2 3.4.0.
#> ℹ Please use the `linewidth` argument instead.
#> ℹ The deprecated feature was likely used in the ggsankey package.
#>   Please report the issue at <https://github.com/davidsjoberg/ggsankey/issues>.


# Two variables
plt_sankey(df, vars = c("sex", "stage"))
#> Warning: attributes are not identical across measure variables; they will be dropped


# Map column names to axis labels
plt_sankey(df, vars = c(sex = "Sex", stage = "Disease\nstage"))
#> Warning: attributes are not identical across measure variables; they will be dropped


# Custom palette
plt_sankey(df, vars = c("sex", "stage"), palette = "Paired")
#> Warning: attributes are not identical across measure variables; they will be dropped


# Without counts in labels
plt_sankey(df, vars = c("sex", "stage", "grade"), show_text = "pct")
#> Warning: attributes are not identical across measure variables; they will be dropped


# Count and percentage on the second line
plt_sankey(df, vars = c("sex", "stage", "grade"), show_text = "all_wrap")
#> Warning: attributes are not identical across measure variables; they will be dropped


# Adjust appearance
plt_sankey(df, vars = c("sex", "stage"),
           flow_args = list(alpha = 0.4), node_args = list(width = 0.3),
           label_args = list(size = 4, box = FALSE, min_pct = 0.05))
#> Warning: attributes are not identical across measure variables; they will be dropped
```
