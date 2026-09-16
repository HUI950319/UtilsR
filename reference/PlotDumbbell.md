# Dumbbell Chart for Paired Comparisons

Create a horizontal dumbbell chart showing paired values (e.g.,
before/after, control/treatment) for each category. Supports
auto-sorting, mean reference lines, delta labels, and an optional inset
plot via patchwork.

## Usage

``` r
PlotDumbbell(
  data,
  x_col = "start",
  xend_col = "end",
  y_col = "category",
  sort_by = "end",
  sort_descending = FALSE,
  top_n = NULL,
  color_x = "#00468BFF",
  color_xend = "#ED0000FF",
  label_x = NULL,
  label_xend = NULL,
  seg_color = "grey60",
  seg_size = 0.8,
  point_size = 3,
  point_shape = 19,
  show_delta = FALSE,
  delta_size = 3,
  delta_digits = 2,
  delta_color = "grey30",
  show_zero_line = TRUE,
  zero_line_color = "grey30",
  zero_line_width = 0.3,
  show_mean_lines = FALSE,
  mean_line_width = 0.3,
  dot_guide = FALSE,
  dot_guide_color = "grey80",
  dot_guide_size = 0.15,
  x_label = NULL,
  y_label = NULL,
  title = NULL,
  legend_pos = "auto",
  legend_theme = NULL,
  theme_use = theme_my,
  inset_plot = NULL,
  inset_type = "boxplot",
  inset_test = "t.test",
  inset_paired_line = TRUE,
  inset_jitter = TRUE,
  inset_theme_use = NULL,
  inset_left = 0.04,
  inset_bottom = 0.68,
  inset_right = 0.35,
  inset_top = 0.94,
  filename = NULL,
  width = 8,
  height = 6,
  dpi = 300,
  bg = "white"
)
```

## Arguments

  - data:
    
    A data.frame containing category, start, and end columns.

  - x\_col:
    
    Column name for the start (left) values. Default `"start"`.

  - xend\_col:
    
    Column name for the end (right) values. Default `"end"`.

  - y\_col:
    
    Column name for the category labels (Y axis). Default `"category"`.

  - sort\_by:
    
    How to sort categories: `"end"` (by xend\_col), `"start"` (by
    x\_col), `"delta"` (by difference), `"none"` (original order).
    Default `"end"`.

  - sort\_descending:
    
    Logical. Sort in descending order? Default `FALSE` (ascending,
    smallest at bottom).

  - top\_n:
    
    Integer. Show only top N categories after sorting. Default `NULL`
    (show all).

  - color\_x:
    
    Colour for start (x) points. Default `"#00468BFF"`.

  - color\_xend:
    
    Colour for end (xend) points. Default `"#ED0000FF"`.

  - label\_x:
    
    Label for start points (used in legend and auto inset). Default
    `NULL` (column name).

  - label\_xend:
    
    Label for end points (used in legend and auto inset). Default `NULL`
    (column name).

  - seg\_color:
    
    Segment line colour. Default `"grey60"`.

  - seg\_size:
    
    Segment line width. Default 0.8.

  - point\_size:
    
    Point size. Default 3.

  - point\_shape:
    
    Point shape. Default 19 (filled circle).

  - show\_delta:
    
    Logical. Show delta (difference) labels at the end of each segment?
    Default `FALSE`.

  - delta\_size:
    
    Text size for delta labels. Default 3.

  - delta\_digits:
    
    Number of decimal places for delta labels. Default 2.

  - delta\_color:
    
    Colour for delta labels. Default `"grey30"`.

  - show\_zero\_line:
    
    Logical. Show a vertical line at x = 0? Default `TRUE`.

  - zero\_line\_color:
    
    Colour for zero line. Default `"grey30"`.

  - zero\_line\_width:
    
    Width for zero line. Default 0.3.

  - show\_mean\_lines:
    
    Logical. Show vertical dashed lines at the mean of x and xend
    values? Default `FALSE`.

  - mean\_line\_width:
    
    Width for mean lines. Default 0.3.

  - dot\_guide:
    
    Logical. Show faint horizontal guide lines from each point to the Y
    axis? Default `FALSE`.

  - dot\_guide\_color:
    
    Colour for dot guide lines. Default `"grey80"`.

  - dot\_guide\_size:
    
    Width for dot guide lines. Default 0.15.

  - x\_label:
    
    X axis label. Default `NULL` (no label).

  - y\_label:
    
    Y axis label. Default `NULL` (no label).

  - title:
    
    Plot title. Default `NULL`.

  - legend\_pos:
    
    Legend position. Accepts:
    
      - `"none"` — hide legend.
    
      - `"auto"` — inside bottom-right (default).
    
      - `"br"`, `"bl"`, `"tr"`, `"tl"` — inside corners.
    
      - `"bottom"`, `"top"`, `"left"`, `"right"` — outside (standard
        ggplot2 positions).

  - legend\_theme:
    
    A ggplot2 theme object for legend styling, e.g., `theme_legend1()`.
    Default `NULL` (no extra legend styling).

  - theme\_use:
    
    Theme function, string, or theme object. Default `theme_my`.
    Controls axis text/title/line styling.

  - inset\_plot:
    
    Inset plot specification. One of:
    
      - `NULL` — no inset (default).
    
      - `"auto"` — auto-generate a paired boxplot from the dumbbell
        data, with paired lines, jitter points, and a significance
        bracket.
    
      - A `ggplot` object — embed a custom inset plot.

  - inset\_type:
    
    Type of auto-generated inset: `"boxplot"` (default) or `"violin"`.
    Only used when `inset_plot = "auto"`.

  - inset\_test:
    
    Paired test for auto inset significance bracket: `"t.test"`,
    `"wilcox"`, or `"none"`. Default `"t.test"`. Only used when
    `inset_plot = "auto"`.

  - inset\_paired\_line:
    
    Logical. Show paired connecting lines in auto inset? Default `TRUE`.

  - inset\_jitter:
    
    Logical. Show jitter points in auto inset? Default `TRUE`.

  - inset\_theme\_use:
    
    Theme for auto inset. Default `NULL` (uses the same `theme_use` as
    the main plot with compact styling).

  - inset\_left, inset\_bottom, inset\_right, inset\_top:
    
    Inset boundaries (patchwork panel coordinates). Default 0.04, 0.68,
    0.35, 0.94.

  - filename:
    
    Output file path. Default `NULL` (no save, print only).

  - width, height:
    
    Output dimensions in inches. Default 8 / 6.

  - dpi:
    
    Output resolution. Default 300.

  - bg:
    
    Output background colour. Default `"white"`.

## Value

A ggplot (or patchwork) object (returned invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
  cell_type = paste0("Type", 1:10),
  sil_ref   = runif(10, -0.2, 0.5),
  sil_emb   = runif(10, 0, 0.8)
)
# Basic dumbbell
PlotDumbbell(df, x_col = "sil_ref", xend_col = "sil_emb",
             y_col = "cell_type", label_x = "PCA", label_xend = "scMMR")

# Auto inset paired boxplot
PlotDumbbell(df, x_col = "sil_ref", xend_col = "sil_emb",
             y_col = "cell_type", label_x = "PCA", label_xend = "scMMR",
             inset_plot = "auto", inset_test = "t.test")

# Custom inset
my_inset <- ggplot2::ggplot(df, ggplot2::aes(sil_ref, sil_emb)) +
  ggplot2::geom_point()
PlotDumbbell(df, x_col = "sil_ref", xend_col = "sil_emb",
             y_col = "cell_type", inset_plot = my_inset)
} # }
```
