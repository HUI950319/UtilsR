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
  value_scale = c("none", "group", "top_n"),
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

  Scores must be one-dimensional real numeric values. Numeric haven
  labelled scores are supported, with class-defined missing values
  (including SPSS user missings) excluded before ranking. Matrix and
  list columns, integer64, time classes and complex scores are not
  supported; convert them explicitly after choosing units and checking
  precision.

- group_col:

  Column name for the grouping variable (e.g. cell type). Default
  `"cell_type"`. Ignored for vector / matrix input. Distinct grouping
  values must have unique character labels. Values with identical labels
  (for example, very close numeric values) are rejected; explicitly
  assign unique character labels before plotting.

- name_col:

  Column name for the feature names. Default `"gene"`. Ignored for
  vector / matrix input.

- value_col:

  Column name for the numeric scores. Default `"importance"`. Ignored
  for vector / matrix input.

- groups:

  Character vector of groups to plot (for matrix or data.frame input).
  `NULL` (default) = all groups. Groups without non-missing scores are
  skipped. An error is raised when no valid scores remain after group
  selection.

- group_levels:

  Character vector specifying display order. `NULL` = data appearance
  order or factor levels.

- top_n:

  Single finite non-negative integer. Number of top-ranked features to
  highlight per group. Default `5`; `0` highlights no features.
  Fractional values are rejected instead of truncated.

- max_show:

  Single finite positive integer. Maximum features to display per panel.
  Default `200`. Fractional values are rejected instead of truncated.

- value_scale:

  Per-group score scaling strategy. Three options:

  `"none"` (default)

  :   No scaling; raw scores are plotted as-is.

  `"group"`

  :   Scale each group independently to `[0, 1]` using the group's full
      value range from the **original** data (before `max_show`
      truncation). Useful when absolute score magnitudes differ greatly
      across groups.

  `"top_n"`

  :   Scale each group to `[0, 1]` using only the displayed
      (post-`max_show`) values. Stretches the visible range within each
      panel to maximise visual separation.

  Extreme finite ranges are rescaled before subtraction to avoid
  overflow.

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

  Single finite positive integer. Number of columns in faceted layout.
  Default `4`; `NULL` uses an automatic layout. Invalid values are
  rejected for both single-panel and faceted inputs. Must be within the
  faceting backend's supported whole-number range.

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

## See also

[`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md)
for comparing ranks from two methods.

Other plot:
[`PlotButterfly()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly.md),
[`PlotButterfly2()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly2.md),
[`PlotCircleLollipop()`](https://hui950319.github.io/UtilsR/reference/PlotCircleLollipop.md),
[`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md),
[`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md),
[`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md),
[`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md),
[`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md),
[`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)

## Examples

``` r
set.seed(42)
scores <- setNames(runif(12), paste0("Gene", seq_len(12)))

# Highlight three of the eight displayed features
rank_plot <- PlotRank(scores, top_n = 3, max_show = 8)
rank_plot


# Return ranked data without highlighting features
ranked_data <- PlotRank(scores, top_n = 0, max_show = 5, return_type = "data")
ranked_data
#>        Group Rank     Score  Label IsTop
#> Gene2    All    1 0.9370754  Gene2 FALSE
#> Gene1    All    2 0.9148060  Gene1 FALSE
#> Gene4    All    3 0.8304476  Gene4 FALSE
#> Gene7    All    4 0.7365883  Gene7 FALSE
#> Gene12   All    5 0.7191123 Gene12 FALSE

# Rank two groups with automatic faceting and full-range scaling
score_matrix <- matrix(runif(24), nrow = 12,
                       dimnames = list(names(scores), c("Group A", "Group B")))
ranked_groups <- PlotRank(score_matrix, top_n = 3, max_show = 8,
                         value_scale = "group", ncol = NULL,
                         return_type = "both")
ranked_groups$plot

head(ranked_groups$data)
#>          Group Rank     Score  Label IsTop
#> Gene9  Group A    1 1.0000000  Gene9  TRUE
#> Gene3  Group A    2 0.9882340  Gene3  TRUE
#> Gene10 Group A    3 0.9534191 Gene10  TRUE
#> Gene2  Group A    4 0.9460787  Gene2 FALSE
#> Gene7  Group A    5 0.9063821  Gene7 FALSE
#> Gene6  Group A    6 0.5272138  Gene6 FALSE
```
