# Circular Lollipop Chart

Draws a polar (circular) lollipop chart using circlize, showing
per-group ranked feature scores (e.g. gene importance, pathway scores).
Features shared across multiple groups are highlighted and optionally
connected by inner arcs, reproducing the style of Fig. 4 in *The Lancet
Digital Health*.

## Usage

``` r
PlotCircleLollipop(
  data,
  group_col = "group",
  name_col = "name",
  value_col = "value",
  top_n = NULL,
  value_scale = c("none", "group", "top_n"),
  group_levels = NULL,
  common_color = "#4682B4",
  unique_color = "#FF7F50",
  color_col = NULL,
  show_links = TRUE,
  link_color = "#4e6a74",
  link_lwd = 0.5,
  link_h = 0.7,
  show_labels = TRUE,
  label_side = c("inside", "outside", "outer"),
  label_cex = 0.7,
  label_height = 4,
  point_cex = 0.8,
  line_lwd = 1,
  sector_bg = "grey90",
  sector_cex = 0.8,
  track_height = 0.37,
  gap_after = 20,
  gap_between = 2,
  start_degree = 90,
  show_yaxis = TRUE,
  yaxis_label = "Selection score",
  filename = NULL,
  width = 10,
  height = 10,
  dpi = 300
)
```

## Arguments

- data:

  A data.frame with at least three columns: group, feature name, and
  numeric value.

- group_col:

  Column name for the grouping variable. Default `"group"`.

- name_col:

  Column name for the feature names. Default `"name"`.

- value_col:

  Column name for the numeric scores. Default `"value"`.

- top_n:

  Integer. If not `NULL`, keep only the top `top_n` features per group
  ranked by `value_col` (descending). Applied before any plotting.
  `NULL` = use all rows as-is.

- value_scale:

  Per-group value scaling applied after `top_n` selection. Three
  options:

  `"none"` (default)

  :   No scaling; values are used as-is and normalised to `[0, 1]`
      globally only if they fall outside that range.

  `"group"`

  :   Scale each group independently to `[0, 1]` using the group's full
      value range from the **original** data (before `top_n` filtering).
      Max value in group = 1, min = 0. Preserves relative differences
      within each group across the whole feature set.

  `"top_n"`

  :   Scale each group independently to `[0, 1]` using only the
      displayed (post-`top_n`) values. Top displayed feature = 1, bottom
      displayed feature = 0. Maximises visual spread within each sector.

- group_levels:

  Character vector controlling the display order of groups. `NULL` =
  data appearance order (or factor levels if already a factor).

- common_color:

  Colour for features shared across \\\geq 2\\ groups. Default
  `"#4682B4"`.

- unique_color:

  Colour for group-unique features. Default `"#FF7F50"`.

- color_col:

  Optional column name supplying per-row colours. When provided,
  `common_color` / `unique_color` are ignored.

- show_links:

  Logical. Draw inner arcs connecting shared features across groups.
  Default `TRUE`.

- link_color:

  Colour of the inner arcs. Default `"#4e6a74"`.

- link_lwd:

  Line width of the arcs. Default `0.5`.

- link_h:

  Bezier height of the arcs (0–1). Default `0.7`.

- show_labels:

  Logical. Draw feature name labels. Default `TRUE`.

- label_side:

  Where to place feature labels relative to the sector ring. Three
  options:

  `"inside"` (default)

  :   Labels in the narrow band between the sector ring inner edge and
      the lollipop outer edge. Best for small datasets (few groups / few
      features per group).

  `"outside"`

  :   Labels inside the grey sector boxes, above the lollipop stems.
      Matches the style of Fig. 4 in *The Lancet Digital Health*.
      Recommended for 5–10 features per group.

  `"outer"`

  :   Labels placed beyond the outer boundary of the grey sector boxes,
      extending outward from the circle. Sector boxes move one ring
      inward. Recommended for large datasets (\> 10 features per group).

- label_cex:

  Text size of the labels. Default `0.7`.

- label_height:

  Height of the label connector lines in mm. Default `4`.

- point_cex:

  Size of the lollipop dots. Default `0.8`.

- line_lwd:

  Width of the lollipop stems. Default `1`.

- sector_bg:

  Background colour of the sector label track. Default `"grey90"`.

- sector_cex:

  Text size of the sector labels. Default `0.8`.

- track_height:

  Height of the lollipop track (0–1). Default `0.37`.

- gap_after:

  Gap angle (degrees) after the last sector. Default `20`.

- gap_between:

  Gap angle (degrees) between sectors. Default `2`.

- start_degree:

  Starting angle in degrees (90 = 12 o'clock). Default `90`.

- show_yaxis:

  Logical. Show a y-axis on the first sector. Default `TRUE`.

- yaxis_label:

  Y-axis title. Default `"Selection score"`.

- filename:

  Output file path (`".pdf"` or `".png"`). `NULL` = draw to the current
  device without saving.

- width:

  Output width in inches. Default `10`.

- height:

  Output height in inches. Default `10`.

- dpi:

  Resolution for PNG output. Default `300`.

## Value

`invisible(NULL)`. The plot is drawn as a side effect.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ToyData)
library(dplyr)

# Prepare top-10 genes per cell type
polar_df <- gene_pc |>
  group_by(cell_type) |>
  slice_max(importance, n = 10) |>
  transmute(group = cell_type, name = gene, value = importance) |>
  as.data.frame()

# Default: labels in the narrow band between sector ring and lollipop
PlotCircleLollipop(polar_df, yaxis_label = "Gene Importance (IG)")

# Lancet-style: labels inside the grey sector boxes (5-10 genes/group)
PlotCircleLollipop(polar_df, top_n = 5,
                   label_side = "outside",
                   yaxis_label = "Gene Importance (IG)")

# Labels beyond the grey sector boxes (recommended for many genes/groups)
PlotCircleLollipop(polar_df, top_n = 10,
                   label_side = "outer",
                   yaxis_label = "Gene Importance (IG)")

# Save to PDF
PlotCircleLollipop(polar_df,
                   label_side = "outer",
                   filename   = "circle_lollipop.pdf",
                   width = 12, height = 12)
} # }
```
