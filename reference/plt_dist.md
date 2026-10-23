# Plot Categorical Variable Distribution

Visualise the cross-distribution of categorical variables. With 2
variables the plot is an \*\*alluvial / Sankey flow\*\* (default) or a
\*\*stacked proportion bar\*\*, selected via `type`; with 3 variables it
is a \*\*tile heatmap\*\*. The alluvial mode uses \[plt_alluvial()\], so
it supports native faceting and only requires the suggested ggalluvial
package.

## Usage

``` r
plt_dist(
  data,
  dis_vars,
  type = c("alluvial", "bar"),
  facet = NULL,
  color = NULL,
  alpha = 0.7,
  label = c("count_percent", "count", "percent", "none"),
  gap = 0.01,
  curve_type = "linear",
  theme_use = theme_heat(14),
  save = list()
)
```

## Arguments

- data:

  A data frame. Existing dplyr grouping is ignored; counts use only the
  variables selected by `dis_vars` and `facet`. Rows missing any
  required value are removed with a message in every mode; unrelated
  columns do not affect inclusion. An error is raised if no complete
  rows remain. The heatmap ignores `facet`.

- dis_vars:

  Character vector of 2 or 3 distinct, non-empty column names. Plain
  integer and double columns are treated as categories in numeric
  ascending order in every mode; values are not binned. Existing factors
  keep their level order. Character columns retain their existing
  ordering: first appearance for alluvial plots, sorted for bar charts
  and heatmaps.

  - 2 variables: `c(x, fill)` \\\rightarrow\\ alluvial flow
    (`type = "alluvial"`, default) or stacked bar (`type = "bar"`).

  - 3 variables: `c(x, y, fill)` \\\rightarrow\\ tile heatmap (`type`
    ignored). Each observed `(x, y)` cell must have only one fill
    category; otherwise an error prevents overplotting.

- type:

  Plot type for the 2-variable case: `"alluvial"` (default) or `"bar"`
  (stacked proportion bar). Ignored when `dis_vars` has 3 variables.

- facet:

  Optional faceting variable name (string). Used by both 2-variable plot
  types and must differ from `dis_vars`; ignored for the 3-variable
  heatmap. Plain integer and double facet values use numeric ascending
  order; existing factors keep their level order.

- color:

  Colour specification, resolved by the internal colour resolver: `NULL`
  (default `pal_lancet`), a registered palette name (e.g. `"Paired"`), a
  single literal colour, or a vector of colours. In a named vector,
  names must be unique category labels and include every observed fill
  category. Unnamed vectors follow factor-level order (data order for
  character alluvial groups). Unused bar/heatmap factor levels retain
  their positions in an unnamed palette.

- alpha:

  One finite number between 0 and 1. Default 0.7. In alluvial mode this
  is the flow ribbon transparency (`flow.alpha`).

- label:

  Label content, one of `"count_percent"` (default), `"count"`,
  `"percent"`, `"none"`. For the \*\*bar chart\*\* this selects the
  count / percentage text on each segment. For the \*\*heatmap\*\* any
  value other than `"none"` prints the third variable's category in each
  tile; `"none"` hides the labels and shows a fill legend. For the
  \*\*alluvial\*\* plot it maps to \`label_args\$style\` in
  \[plt_alluvial()\]: `"count_percent"` \\\rightarrow\\ name + count +
  percent, `"count"` \\\rightarrow\\ name + count, `"percent"`
  \\\rightarrow\\ name + percent, `"none"` \\\rightarrow\\ no labels.

- gap:

  Alluvial only. Gap between strata as a fraction of total height,
  forwarded to \[plt_alluvial()\]. Default 0.01; set 0 for no gaps.

- curve_type:

  Alluvial only. Flow ribbon curve type forwarded to \[plt_alluvial()\].
  Default `"linear"`; other options include `"sigmoid"`, `"cubic"`,
  `"xspline"`.

- theme_use:

  Theme specification, resolved by \[.resolve_theme()\]. Default
  \[theme_heat\]`(14)` (clean look). Also accepts a
  [`ggplot2::theme`](https://ggplot2.tidyverse.org/reference/theme.html)
  object, a theme function, a function-name string (e.g. `"theme_my"`),
  or `NULL` (\\\rightarrow\\ \[theme_km\]). In-plot label sizes scale
  with the theme's base size, so control sizing through the theme
  itself, e.g. `theme_use = theme_my(base_size = 16)`. Note on the
  legend: the \*\*bar chart\*\* always shows the fill legend (it is
  re-enabled when the theme – such as the default
  [`theme_heat()`](https://hui950319.github.io/UtilsR/reference/theme_heat.md)
  – would otherwise hide it, but a custom theme's legend placement is
  kept); the \*\*heatmap\*\* hides it when tiles are labelled and shows
  it when `label = "none"`, retaining a custom theme's visible
  placement. In \*\*alluvial\*\* mode only the base font size is taken
  from `theme_use`; \[theme_alluvia()\] supplies the plot's remaining
  theme settings.

- save:

  `NULL`, an empty list (default), or a named list forwarded to
  `RegR::save_plt()` for PDF output: `filename` and optionally `width`
  and `height`. A `width` or `height` left out defaults to the page the
  plot is laid out for – for the alluvial plot see
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md);
  0.9 in per x level (at least 3 in) by 4 in per facet for the bar
  chart, and 1.1 in per column by 0.6 in per row of cells for the
  heatmap, beside the measured axis text and legend – which every call
  prints with the matching `save` line. Saving, and the size note, need
  the RegR package.

## Value

A ggplot object carrying that page size as `attr(p, "plot_size")`,
`c(width, height)` in inches.

## See also

Other plot:
[`PlotButterfly()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly.md),
[`PlotButterfly2()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly2.md),
[`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md),
[`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md),
[`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md),
[`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md),
[`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)

## Examples

``` r
set.seed(1)
df <- data.frame(
  stage = factor(sample(c("I","II","III","IV"), 200, TRUE)),
  sex   = factor(sample(c("M","F"), 200, TRUE)),
  race  = factor(sample(c("White","Black","Asian"), 200, TRUE)),
  grade = factor(sample(c("Low","Mid","High"), 200, TRUE))
)

# --- Stacked bar (type = "bar") -------------------------------------------
# Count + percent labels
plt_dist(df, dis_vars = c("stage", "sex"), type = "bar")


# Percent-only labels, with facet
plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
         facet = "race", label = "percent")


# No labels
plt_dist(df, dis_vars = c("stage", "sex"), type = "bar", label = "none")


# Registered palette name / literal colour vector
plt_dist(df, dis_vars = c("stage", "sex"), type = "bar", color = "Paired")

plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
         color = c("steelblue", "tomato"))


# Theme + size carried by theme_use
plt_dist(df, dis_vars = c("stage", "sex"), type = "bar",
         theme_use = theme_my(base_size = 16))


# --- Tile heatmap (3 variables; type ignored) -----------------------------
heat_data <- expand.grid(stage = c("I", "II", "III", "IV"),
                         grade = c("Low", "Mid", "High"))
heat_data$category <- factor(rep(c("A", "B"), 6))
plt_dist(heat_data, dis_vars = c("stage", "grade", "category"))

plt_dist(heat_data, dis_vars = c("stage", "grade", "category"), label = "none")


# --- Alluvial flow (default; needs ggalluvial) ----------------------------
if (requireNamespace("ggalluvial", quietly = TRUE)) {
  plt_dist(df, dis_vars = c("stage", "sex"))
  plt_dist(df, dis_vars = c("stage", "sex"), facet = "race")
  plt_dist(df, dis_vars = c("stage", "sex"), gap = 0.02)
  plt_dist(df, dis_vars = c("stage", "sex"), curve_type = "sigmoid")
  plt_dist(df, dis_vars = c("stage", "sex"), label = "percent")
}

```
