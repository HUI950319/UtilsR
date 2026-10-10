# Package index

## Advanced Plot Functions

Publication-ready scatter, heatmap and circular plots.

- [`PlotScatter1()`](https://hui950319.github.io/UtilsR/reference/PlotScatter1.md)
  : Grouped Scatter Plot with Marginal Boxplots
- [`PlotScatter2()`](https://hui950319.github.io/UtilsR/reference/PlotScatter2.md)
  : Dual-Group Scatter Plot with Multi-Variable Marginal Boxplots
- [`PlotScatter3()`](https://hui950319.github.io/UtilsR/reference/PlotScatter3.md)
  : Paired Scatter Plot with Rotated Histogram Inset
- [`PlotDumbbell()`](https://hui950319.github.io/UtilsR/reference/PlotDumbbell.md)
  : Dumbbell Chart for Paired Comparisons
- [`PlotHeatmapJaccard()`](https://hui950319.github.io/UtilsR/reference/PlotHeatmapJaccard.md)
  : Jaccard Similarity Heatmap
- [`PlotRank()`](https://hui950319.github.io/UtilsR/reference/PlotRank.md)
  : Rank Scatter Plot
- [`PlotCircleLollipop()`](https://hui950319.github.io/UtilsR/reference/PlotCircleLollipop.md)
  : Circular Lollipop Chart
- [`PlotButterfly()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly.md)
  : Butterfly Chart (Back-to-Back Symmetric Plot)
- [`PlotButterfly2()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly2.md)
  : Butterfly Plot from Long-Format Data
- [`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md)
  : Rank Correlation Scatter Plot

## Plot Functions

High-level plotting functions for categorical data visualization.

- [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md)
  : Unified Categorical Variable Plot
- [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  : Unified Continuous Variable Plot
- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  : Plot a Faceted Alluvial Distribution
- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  : Plot Categorical Variable Distribution
- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  : Sankey Diagram for Categorical Variables
- [`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)
  : UpSet and Venn Diagram for Set Intersections

## Data Inspection

Explore variables, missing values, and system resources.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) :
  Variable Inspection Generic Function
- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  : Comprehensive Data Quality Analysis
- [`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md)
  : Impute Missing Values with Weighted K-Nearest Neighbours
- [`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md) :
  Plot Missing Values
- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  : Check System Resources and Environment
- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  : Analyze Object Sizes in Global Environment
- [`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md)
  : Count Installed Packages in Each Library Path

## File System

Working-directory and path helpers.

- [`set_wd()`](https://hui950319.github.io/UtilsR/reference/set_wd.md) :
  Create a Directory (if Needed) and Set It as the Working Directory

## Factor Manipulation

Recode, reorder, and transform factor variables.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  : Unified Factor Manipulation
- [`fct_label()`](https://hui950319.github.io/UtilsR/reference/fct_label.md)
  : Relabel factor levels (generic: vector or data-frame column)
- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  : Convert Numeric to Factor
- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  : Combine Multiple Vectors / Columns into a Single Factor (generic)
- [`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md)
  : Group Factor Levels by Integer Indices

## Statistical Formatting

Format confidence intervals and p-values.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  : Format Confidence Intervals or Mean (SD)
- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  : Format P-values, Numbers, or Add Stars to Any Value
- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  : Parse Confidence Interval Strings

## Colour Palettes

Built-in colour palettes and palette utilities.

- [`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md)
  : Lancet Colour Palette
- [`pal_bar`](https://hui950319.github.io/UtilsR/reference/pal_bar.md) :
  Bar Colour Palette
- [`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md)
  : Additional Built-in Colour Palettes
- [`pal_heat`](https://hui950319.github.io/UtilsR/reference/pal_heat.md)
  : Diverging Heatmap Fill Palettes
- [`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md)
  : Parathyroid Single-Cell Colour Palette
- [`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md)
  : Get Colours from a Named Palette
- [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md)
  : List All Available Palettes
- [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)
  : Visualise Palettes or Colour Vectors
- [`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md)
  : Visualise RColorBrewer Palettes
- [`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md)
  : Visualise ggsci Palettes
- [`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md)
  : Visualise Base R HCL Palettes
- [`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)
  : Visualise Viridis Palettes
- [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
  : Display Colour Swatches in Console
- [`palette_list`](https://hui950319.github.io/UtilsR/reference/palette_list.md)
  : Built-in Palette Collection

## ggplot2 Formatting

Chain-able ggplot2 formatting helpers.

- [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  : Master plot formatting function
- [`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md)
  : Broadcast theme / labs / scales onto a patchwork via \`&\`
- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  : Hide axis elements for specific plots
- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  : Format axis text rotation and style
- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  : Color discrete axis tiles or text labels
- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  : Format panel appearance
- [`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)
  : Format plot labels and their text style
- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  : Add panel labels to plots
- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  : Format legend position and style
- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  : Add reference lines to plots
- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  : Add facet strip labels to a plot
- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  : Add facet-grid-style strips to a patchwork grid (top headers + side
  labels)
- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  : Add pairwise statistical comparisons
- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md) :
  Add coloured background stripes
- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  : Add marginal histogram or density overlay
- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  : Set axis scales
- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  : Set axis expansion
- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  : Overlay a boxplot layer
- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  : Add Data Points to a Plot
- [`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md)
  : Rasterize Plot Panels
- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  : Flatten nested patchwork objects

## Themes

ggplot2 themes.

- [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md)
  : Custom ggplot2 Theme Based on ggprism
- [`theme_heat()`](https://hui950319.github.io/UtilsR/reference/theme_heat.md)
  : Heatmap / Tile Plot Theme
- [`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md)
  : Kaplan-Meier Plot Theme
- [`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md)
  : RCS (Restricted Cubic Spline) Plot Theme
- [`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md)
  : Compact Legend Theme
- [`theme_blank()`](https://hui950319.github.io/UtilsR/reference/theme_blank.md)
  : Blank Theme with Coordinate Arrows
- [`theme_sc()`](https://hui950319.github.io/UtilsR/reference/theme_sc.md)
  : Single-Cell Style Theme
- [`theme_ROC()`](https://hui950319.github.io/UtilsR/reference/theme_ROC.md)
  : ROC / Calibration Plot Theme
- [`theme_legend()`](https://hui950319.github.io/UtilsR/reference/theme_legend.md)
  : Customizable Legend Theme
- [`theme_alluvia()`](https://hui950319.github.io/UtilsR/reference/theme_alluvia.md)
  : Alluvial / Sankey Plot Theme
- [`theme_scatter`](https://hui950319.github.io/UtilsR/reference/theme_scatter.md)
  : Scatter / Feature Plot Theme
- [`leg1()`](https://hui950319.github.io/UtilsR/reference/leg1.md) :
  Quick Legend Theme (with title)
- [`leg2()`](https://hui950319.github.io/UtilsR/reference/leg2.md) :
  Quick Legend Theme (no title)

## Grob Utilities

Helpers for manipulating ggplot2 grobs.

- [`grob_add()`](https://hui950319.github.io/UtilsR/reference/grob_add.md)
  : Add a Grob to a Gtable at a Specified Position
- [`grob_as()`](https://hui950319.github.io/UtilsR/reference/grob_as.md)
  : Convert a Plot Object to a Grob
- [`grob_insert()`](https://hui950319.github.io/UtilsR/reference/grob_insert.md)
  : Insert an Inset Plot Inside Another Plot
- [`grob_to_gg()`](https://hui950319.github.io/UtilsR/reference/grob_to_gg.md)
  : Convert a Grob or Gtable Back to a ggplot Object

## Console Display

Styled console output helpers.

- [`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md)
  : Styled info box
- [`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md)
  : Print model formula with styled header
- [`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md)
  : Styled separator line
- [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  : Styled log message with timestamp
- [`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)
  : Enhanced Table Display with Pattern Highlighting
- [`console_width()`](https://hui950319.github.io/UtilsR/reference/console_width.md)
  : Get console width

## Operators

Convenience operators.

- [`` `%<>%` ``](https://hui950319.github.io/UtilsR/reference/grapes-less-than-greater-than-grapes.md)
  : Compound assignment pipe operator
- [`` `%ni%` ``](https://hui950319.github.io/UtilsR/reference/grapes-ni-grapes.md)
  : Not-in operator
- [`%>%`](https://hui950319.github.io/UtilsR/reference/operators.md)
  [`%||%`](https://hui950319.github.io/UtilsR/reference/operators.md) :
  Pipe operator
