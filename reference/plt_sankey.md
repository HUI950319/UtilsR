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
  show_text = c("all", "n", "pct", "name"),
  width = 0.4,
  space = NULL,
  label_size = 3,
  label_hjust = 0.5,
  alpha = 0.6,
  base_size = 14
)
```

## Arguments

  - data:
    
    A data frame.

  - vars:
    
    Character vector of categorical variable names (\>= 2). Variables
    are displayed left-to-right in the given order.

  - palette:
    
    Colour palette name from `pal_get()`, or a character vector of
    colours. Default `NULL` auto-generates colours per variable using
    sequential HCL palettes.

  - reverse\_levels:
    
    Logical, reverse factor levels for display. Default `TRUE`.

  - show\_text:
    
    Character. Controls node label content:
    
      - `"all"` (default) — name + count + percentage, e.g. `"A
        (10, 30.3%)"`.
    
      - `"n"` — name + count, e.g. `"A (10)"`.
    
      - `"pct"` — name + percentage, e.g. `"A (30.3%)"`.
    
      - `"name"` — name only, e.g. `"A"`.

  - width:
    
    Sankey node width. Default 0.4.

  - space:
    
    Numeric. Gap between nodes within each column. Default `NULL`
    (ggsankey auto-calculates). Set `0` for no gaps (consistent total
    height across columns).

  - label\_size:
    
    Label text size. Default 3.

  - label\_hjust:
    
    Label horizontal justification. Default 0.5.

  - alpha:
    
    Flow transparency. Default 0.6.

  - base\_size:
    
    Base font size. Default 14.

## Value

A ggplot object.

## Note

Requires the ggsankey package (`pak::pak("davidsjoberg/ggsankey")`).

## See also

Other plot: `PlotButterfly()`, `PlotButterfly2()`, `PlotRankCor()`,
`plt_cat()`, `plt_con()`, `plt_dist()`, `plt_upset()`

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


# Custom palette
plt_sankey(df, vars = c("sex", "stage"), palette = "Paired")
#> Warning: attributes are not identical across measure variables; they will be dropped


# Without counts in labels
plt_sankey(df, vars = c("sex", "stage", "grade"), show_n = FALSE)
#> Error in plt_sankey(df, vars = c("sex", "stage", "grade"), show_n = FALSE): unused argument (show_n = FALSE)

# Adjust appearance
plt_sankey(df, vars = c("sex", "stage"),
           width = 0.3, label_size = 4, alpha = 0.4)
#> Warning: attributes are not identical across measure variables; they will be dropped

```
