# Jaccard Similarity Heatmap

Computes pairwise Jaccard similarity between groups based on a set of
named variables (e.g. top genes, features), then draws a colour-coded
heatmap with optional numeric labels per cell and optional coloured axis
strips.

## Usage

``` r
PlotHeatmapJaccard(
  data,
  group_col = "cell_type",
  name_col = "gene",
  title = "Jaccard Similarity",
  group_levels = NULL,
  midpoint = 0.1,
  text_size = 2.5,
  show_diag = FALSE,
  low_color = "white",
  high_color = "#B2182B",
  show_strip = FALSE,
  strip_colors = NULL,
  strip_size = 0.45,
  return_type = c("plot", "data", "both"),
  filename = NULL,
  width = 10,
  height = 9,
  dpi = 300
)
```

## Arguments

- data:

  A data.frame containing at least a group column and a name column.
  Rows with missing group labels or feature names do not contribute to
  sets. Labelled and `integer64` columns use their class-defined missing
  values, including SPSS user-missing codes, even in a fresh R session.
  Interpreting these classes requires haven and bit64, respectively.
  `Duration`, `Period` and `Interval` inputs require lubridate. Their
  complete value components are retained for grouping and feature
  matching.

- group_col:

  A single non-missing, non-empty grouping column name (e.g. cell type).
  Default `"cell_type"`. Its character representation supplies matrix
  and axis labels; the original values are retained for matching.

- name_col:

  A single non-missing, non-empty feature/gene column name used to
  compute Jaccard similarity. Default `"gene"`.

- title:

  Plot title. Default `"Jaccard Similarity"`.

- group_levels:

  Character vector specifying the display order of groups on both axes.
  Non-missing entries must have unique character representations;
  missing entries are ignored. Unobserved groups are retained as empty
  sets. `NULL` = factor levels (if factor) or data appearance order.
  Typed level vectors use class-defined missing values and the same
  package requirements as `data`.

- midpoint:

  Midpoint of the colour gradient. Default `0.1`.

- text_size:

  Size of the numeric labels inside each cell. Default `2.5`. Set to `0`
  to hide labels.

- show_diag:

  Logical. Whether to show diagonal values. Default `FALSE` (diagonal is
  set to `NA` and shown in grey).

- low_color:

  Low end of the fill gradient. Default `"white"`.

- high_color:

  High end of the fill gradient. Default `"#B2182B"`.

- show_strip:

  Logical. Whether to draw coloured annotation strips along the bottom
  (X axis) and left (Y axis) of the heatmap. Default `FALSE`.

- strip_colors:

  Character vector of colours for each group strip. `NULL` = auto
  palette (same order as `group_levels` / `ct_names`). The 16-colour
  auto palette repeats for additional groups, as do shorter custom
  palettes.

- strip_size:

  Numeric. Width/height of the colour strip in data units. Default
  `0.45`.

- return_type:

  What to return: `"plot"` (default, the ggplot object), `"data"` (the
  Jaccard similarity matrix), or `"both"` (a list with elements `plot`
  and `matrix`). Matrix-only output skips plotting when
  `filename = NULL`; a requested file is still drawn and saved.

- filename:

  Output file path. `NULL` = no save.

- width:

  Output width in inches. Default `10`.

- height:

  Output height in inches. Default `9`.

- dpi:

  Output resolution. Default `300`.

## Value

Depends on `return_type`:

- "plot":

  A `ggplot` object (default).

- "data":

  A numeric matrix of pairwise Jaccard similarities.

- "both":

  A list with elements `plot` and `matrix`.

Empty sets have similarity `0` to every group, including themselves.
Returned plots retain heatmap inputs rather than the original data
frame.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ToyData)
data(Toy_gene_importance)

# Basic Jaccard heatmap
PlotHeatmapJaccard(Toy_gene_importance, name_col = "gene")

# With coloured axis strips
PlotHeatmapJaccard(Toy_gene_importance, name_col = "gene", show_strip = TRUE)

# Custom title and return matrix
res <- PlotHeatmapJaccard(Toy_gene_importance, name_col = "gene",
                           title = "Gene Importance Jaccard",
                           return_type = "both")
res$matrix
} # }
```
