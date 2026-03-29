# Rank Scatter Plot

Ranks features (genes, pathways, regulons, etc.) by their scores and
highlights the top-ranked ones with coloured points and text labels.
Designed for DNN model interpretation outputs (Integrated Gradients
importance scores) but works with any named score data.

## Usage

``` r
PlotRank(
  data,
  group_col = "cell_type",
  name_col = "gene",
  value_col = "importance",
  groups = NULL,
  group_levels = NULL,
  top_n = 5L,
  max_show = 200L,
  highlight_color = "#007D9B",
  base_color = "#BECEE3",
  label_size = 4,
  point_size = 3,
  title = NULL,
  ylab = "Importance",
  base_size = 12,
  ncol = 4L,
  clean_names = TRUE,
  return_type = c("plot", "data", "both"),
  filename = NULL,
  width = 12,
  height = 10,
  dpi = 300
)
```

## Arguments

- data:

  Input data in one of the following formats:

  data.frame

  :   Must contain columns specified by `name_col` and `value_col`. If
      `group_col` exists, a faceted multi-panel plot is produced.

  Named numeric vector

  :   Values are scores; names are feature labels. Produces a
      single-panel plot.

  Matrix

  :   Rows = features, columns = groups (e.g. cell types). Use `groups`
      to select specific columns.

- group_col:

  Column name for the grouping variable (e.g. cell type). Default
  `"cell_type"`. Ignored for vector / matrix input.

- name_col:

  Column name for the feature names. Default `"gene"`. Ignored for
  vector / matrix input.

- value_col:

  Column name for the numeric scores. Default `"importance"`. Ignored
  for vector / matrix input.

- groups:

  Character vector of groups to plot (for matrix or data.frame input).
  `NULL` (default) = all groups.

- group_levels:

  Character vector specifying display order. `NULL` = data appearance
  order or factor levels.

- top_n:

  Integer. Number of top-ranked features to highlight per group. Default
  `5`.

- max_show:

  Integer. Maximum features to display per panel. Default `200`.

- highlight_color:

  Colour for top-ranked points. Default `"#007D9B"`.

- base_color:

  Colour for remaining points. Default `"#BECEE3"`.

- label_size:

  Numeric. Text label size. Default `4`.

- point_size:

  Numeric. Point size. Default `3`.

- title:

  Character. Plot title. `NULL` = auto.

- ylab:

  Character. Y-axis label. Default `"Importance"`.

- base_size:

  Numeric. Base font size. Default `12`.

- ncol:

  Integer. Number of columns in faceted layout. Default `4`.

- clean_names:

  Logical. Strip common prefixes (`HALLMARK_`, `KEGG_`, etc.) and
  replace underscores with spaces. Default `TRUE`.

- return_type:

  What to return: `"plot"` (default), `"data"` (the ranked data.frame),
  or `"both"`.

- filename:

  Output file path. `NULL` = no save.

- width:

  Output width in inches. Default `12`.

- height:

  Output height in inches. Default `10`.

- dpi:

  Output resolution. Default `300`.

## Value

Depends on `return_type`:

- "plot":

  A `ggplot` object (default).

- "data":

  A data.frame with columns: Group, Rank, Score, Label, IsTop.

- "both":

  A list with elements `plot` and `data`.

## Examples

``` r
if (FALSE) { # \dontrun{
# 1) DNN per-class gene importance (data.frame, faceted)
PlotRank(pred$imp_per_class, top_n = 10, ncol = 4)

# 2) Single group from per-class data
PlotRank(pred$imp_per_class, groups = "Parathyroid cells", top_n = 15)

# 3) Global gene importance (data.frame, single panel)
PlotRank(pred$imp_global, name_col = "gene", value_col = "importance",
         top_n = 20, ylab = "Global IG Importance")

# 4) Pathway scores matrix
PlotRank(pred$pathway_scores, top_n = 10, ylab = "Pathway Score")

# 5) Named numeric vector
scores <- setNames(runif(100), paste0("Gene", 1:100))
PlotRank(scores, top_n = 10)

# 6) Save to file
PlotRank(pred$imp_per_class, top_n = 10,
         filename = "rank_scatter.pdf", width = 16, height = 12)
} # }
```
