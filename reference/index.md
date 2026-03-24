# Package index

## Plot Functions

High-level plotting functions for categorical data visualization.

- [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md)
  : Unified Categorical Variable Plot
- [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  : Unified Continuous Variable Plot
- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  : Plot Categorical Variable Distribution
- [`plt_cohen()`](https://hui950319.github.io/UtilsR/reference/plt_cohen.md)
  : Plot Cohen's d Effect Sizes
- [`plt_radar()`](https://hui950319.github.io/UtilsR/reference/plt_radar.md)
  : Radar Chart
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
- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  : Check System Resources and Environment
- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  : Analyze Object Sizes in Global Environment
- [`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md)
  : Count Installed Packages in Each Library Path

## Factor Manipulation

Recode, reorder, and transform factor variables.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  : Unified Factor Manipulation
- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  : Convert Numeric to Factor

## Statistical Formatting

Format confidence intervals, p-values, and effect sizes.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  : Format Confidence Intervals or Mean (SD)
- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  : Format P-values, Numbers, or Add Stars to Any Value
- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  : Parse Confidence Interval Strings
- [`stat_cohen()`](https://hui950319.github.io/UtilsR/reference/stat_cohen.md)
  : Compute Cohen's d Effect Size by Group

## Colour Palettes

Built-in colour palettes and palette utilities.

- [`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md)
  : Lancet Colour Palette
- [`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md)
  : Additional Built-in Colour Palettes
- [`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md)
  : Get Colours from a Named Palette
- [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md)
  : List All Available Palettes
- [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)
  : Visualise Palettes
- [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
  : Display Colour Swatches in Console
- [`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md)
  : Create a colour palette object
- [`palette_list`](https://hui950319.github.io/UtilsR/reference/palette_list.md)
  : Built-in Palette Collection

## ggplot2 Formatting

Chain-able ggplot2 formatting helpers.

- [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  : Master plot formatting function
- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  : Hide or show axis elements for specific plots
- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  : Add panel labels to plots
- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  : Format legend position and style
- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  : Add reference lines to plots
- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  : Add facet strip labels to a plot
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
- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  : Flatten nested patchwork objects

## Themes

ggplot2 themes.

- [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md)
  : Custom ggplot2 Theme Based on ggprism
- [`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md)
  : Kaplan-Meier Plot Theme
- [`theme_rcs`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md)
  : RCS (Restricted Cubic Spline) Plot Theme
- [`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md)
  : Compact Legend Theme

## Console Display

Styled console output helpers.

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
