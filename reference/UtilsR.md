# UtilsR: Utility Functions for Data Analysis and Visualisation

A toolkit for data exploration, factor manipulation, statistical
formatting, colour palettes, ggplot2 formatting, and console styling.

## Inspect

- [`lv`](https://hui950319.github.io/UtilsR/reference/lv.md):

  Variable summary for data.frame / Seurat

- [`check_na`](https://hui950319.github.io/UtilsR/reference/check_na.md):

  Missing value and data quality analysis

- [`check_system`](https://hui950319.github.io/UtilsR/reference/check_system.md):

  OS, R version, memory, CPU info

- [`check_size`](https://hui950319.github.io/UtilsR/reference/check_size.md):

  Object memory profiling

- [`count_packages_in_libpaths`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md):

  Count installed packages

## Factor

- [`fct_cat`](https://hui950319.github.io/UtilsR/reference/fct_cat.md):

  Recode, reorder, reverse, binary, group, combine factors

- [`fct_num`](https://hui950319.github.io/UtilsR/reference/fct_num.md):

  Numeric to factor (cut points or quantile binning)

## Format

- [`stat_ci`](https://hui950319.github.io/UtilsR/reference/stat_ci.md):

  Build or reformat CI strings and mean(SD)

- [`stat_pval`](https://hui950319.github.io/UtilsR/reference/stat_pval.md):

  Format p-values or add significance stars

- [`stat_ci_parse`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md):

  Parse CI strings, compute p-values, adjust confidence levels

## Colour Palettes

- [`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md):

  Lancet journal (15 colours)

- [`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md):

  10 discrete palettes (igv, ditto, polychrome, etc.)

- [`show_color`](https://hui950319.github.io/UtilsR/reference/show_color.md):

  Display colour swatches in console

- [`as_palette`](https://hui950319.github.io/UtilsR/reference/as_palette.md):

  Create custom palette object

- [`pal_list`](https://hui950319.github.io/UtilsR/reference/pal_list.md):

  Browse all built-in palettes

## Plot Functions

- [`plt_cat`](https://hui950319.github.io/UtilsR/reference/plt_cat.md):

  Unified categorical plot (bar, rose, ring, pie, trend, area, dot,
  sankey, chord, venn, upset)

- [`plt_dist`](https://hui950319.github.io/UtilsR/reference/plt_dist.md):

  Cross-distribution (stacked bar / tile heatmap, auto-selects by
  variable count)

- [`plt_cohen`](https://hui950319.github.io/UtilsR/reference/plt_cohen.md):

  Cohen's d effect size Cleveland dot plot

- [`plt_radar`](https://hui950319.github.io/UtilsR/reference/plt_radar.md):

  Radar (spider) chart

- [`plt_sankey`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md):

  Sankey diagram for categorical flow

- [`plt_upset`](https://hui950319.github.io/UtilsR/reference/plt_upset.md):

  UpSet / Venn diagram for set intersections

## ggplot2 Formatting

- [`fmt_plot`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md):

  Master chaining function

- [`fmt_axis`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md):

  Hide/show axis elements

- [`fmt_tag`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md):

  Add panel labels (A, B, C...)

- [`fmt_legend`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md):

  Format legend position and style

- [`fmt_ref`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md):

  Add reference lines

- [`fmt_strip`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md):

  Format facet strip labels

- [`fmt_com`](https://hui950319.github.io/UtilsR/reference/fmt_com.md):

  Add pairwise statistical comparisons

- [`fmt_bg`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md):

  Add coloured background stripes

- [`fmt_his`](https://hui950319.github.io/UtilsR/reference/fmt_his.md):

  Add marginal histogram/density

- [`fmt_scale`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md):

  Set axis scales

- [`fmt_expand`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md):

  Set axis expansion

- [`fmt_boxplot`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md):

  Overlay boxplot layer

- [`flatten_patchwork`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md):

  Flatten nested patchwork objects

## ggplot2 Themes

- [`theme_my`](https://hui950319.github.io/UtilsR/reference/theme_my.md):

  Clean general-purpose theme

- [`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md):

  Kaplan-Meier survival curve theme

- [`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md):

  Restricted cubic spline theme

## Console Display

- [`.cat_line`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md):

  Styled separator line

- [`.cat_box`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md):

  Styled message box

- [`.cat_message`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md):

  Timestamped log message

- [`.cat_tb`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md):

  Enhanced gt table with highlighting

## Operators

- [`%ni%`](https://hui950319.github.io/UtilsR/reference/grapes-ni-grapes.md):

  Not-in operator

- [`%||%`](https://hui950319.github.io/UtilsR/reference/operators.md):

  Default value operator

- `%>%`:

  Pipe operator

- `%<>%`:

  Compound assignment pipe
