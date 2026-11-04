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
  numeric value. Missing group labels are rejected before drawing.
  Unused group levels are omitted from the chart.

- group_col:

  Column name for the grouping variable. Default `"group"`. Distinct
  values with coinciding character labels use higher precision and, if
  needed, numeric suffixes to keep sectors and scaling separate.

- name_col:

  Column name for the feature names. Default `"name"`.

- value_col:

  Column name for the numeric scores. Default `"value"`. Numeric
  character strings and factor labels (including ordered factors) are
  parsed before ranking or scaling. Invalid non-missing labels are
  rejected; existing missing scores are retained.

- top_n:

  A single non-negative whole number no greater than
  `.Machine$integer.max`, or `NULL`. Keep this many features per group
  ranked by the parsed numeric scores (descending), before plotting.
  Integers and whole-valued doubles are accepted; character, logical and
  factor counts, fractions, missing values and infinite values are
  rejected. `NULL` uses all rows as-is. Zero selects no rows and raises
  `"No observations to plot."`.

- value_scale:

  Per-group value scaling applied after `top_n` selection. Three
  options:

  `"none"` (default)

  :   No scaling; values are used as-is and normalised to `[0, 1]`
      globally only if they fall outside that range. A constant global
      range outside `[0, 1]` uses the minimum lollipop height of `0.05`.

  `"group"`

  :   Scale each group independently to `[0, 1]` using the group's full
      value range from the **original** data (before `top_n` filtering).
      Max value in group = 1, min = 0. Preserves relative differences
      within each group across the whole feature set.

  `"top_n"`

  :   Scale each group independently to `[0, 1]` using only the
      displayed (post-`top_n`) values. Top displayed feature = 1, bottom
      displayed feature = 0. Maximises visual spread within each sector.

  Extreme finite ranges are rescaled before subtraction to avoid
  overflow.

- group_levels:

  Character vector controlling the display order of groups. `NULL` =
  data appearance order (or factor levels if already a factor). Must
  include every observed group; unobserved levels are omitted. Use the
  displayed labels when group labels require higher precision.

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

`invisible(NULL)`. The plot is drawn as a side effect. Plot margins are
restored and the chart's circlize state is cleared even if drawing
fails. Saving closes its own device and restores the caller's current
device.

## See also

[`PlotRank()`](https://hui950319.github.io/UtilsR/reference/PlotRank.md),
[`PlotButterfly()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly.md)

## Examples

``` r
if (requireNamespace("circlize", quietly = TRUE)) {
  set.seed(42)
  example_data <- data.frame(
    group = rep(c("Group A", "Group B"), each = 5),
    name = rep(paste0("Feature", 1:5), 2),
    value = runif(10)
  )
  PlotCircleLollipop(example_data, top_n = 3, show_labels = FALSE,
                     show_yaxis = FALSE)

  # Factor labels are interpreted as scores, regardless of level order.
  example_data$value <- factor(format(example_data$value, digits = 3))
  PlotCircleLollipop(example_data, top_n = 3, value_scale = "group",
                     show_labels = FALSE, show_yaxis = FALSE)
}


```
