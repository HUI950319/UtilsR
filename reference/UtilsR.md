# UtilsR: Utility Functions for Data Analysis and Visualisation

A toolkit for data exploration, factor manipulation, statistical
formatting, colour palettes, ggplot2 formatting, and console styling.

## Inspect

  - `lv`:
    
    Variable summary for data.frame / Seurat

  - `check_na`:
    
    Missing value and data quality analysis

  - `impute_na_knn`:
    
    Weighted KNN missing-value imputation with labelled-variable support

  - `plt_na`:
    
    Missing-value matrix and percentage plots

  - `check_system`:
    
    OS, R version, memory, CPU info

  - `check_size`:
    
    Object memory profiling

  - `count_packages_in_libpaths`:
    
    Count installed packages

## Factor

  - `fct_cat`:
    
    Recode, reorder, reverse, binary, group, combine factors

  - `fct_num`:
    
    Numeric to factor (cut points or quantile binning)

## Format

  - `stat_ci`:
    
    Build or reformat CI strings and mean(SD)

  - `stat_pval`:
    
    Format p-values or add significance stars

  - `stat_ci_parse`:
    
    Parse CI strings, compute p-values, adjust confidence levels

## Colour Palettes

  - `pal_lancet`:
    
    Lancet journal (15 colours)

  - `pal_other`:
    
    10 discrete palettes (igv, ditto, polychrome, etc.)

  - `show_color`:
    
    Display colour swatches in console

  - `pal_list`:
    
    Browse all built-in palettes

## Plot Functions

  - `plt_cat`:
    
    Unified categorical plot (bar, rose, ring, pie, trend, area, dot,
    sankey, chord, venn, upset)

  - `plt_dist`:
    
    Cross-distribution (stacked bar / tile heatmap, auto-selects by
    variable count)

  - `plt_cohen`:
    
    Cohen's d effect size Cleveland dot plot

  - `plt_radar`:
    
    Radar (spider) chart

  - `plt_sankey`:
    
    Sankey diagram for categorical flow

  - `plt_upset`:
    
    UpSet / Venn diagram for set intersections

## ggplot2 Formatting

  - `fmt_plot`:
    
    Master chaining function

  - `fmt_axis`:
    
    Hide/show axis elements

  - `fmt_tag`:
    
    Add panel labels (A, B, C...)

  - `fmt_legend`:
    
    Format legend position and style

  - `fmt_ref`:
    
    Add reference lines

  - `fmt_strip`:
    
    Format facet strip labels

  - `fmt_com`:
    
    Add pairwise statistical comparisons

  - `fmt_bg`:
    
    Add coloured background stripes

  - `fmt_his`:
    
    Add marginal histogram/density

  - `fmt_scale`:
    
    Set axis scales

  - `fmt_expand`:
    
    Set axis expansion

  - `fmt_boxplot`:
    
    Overlay boxplot layer

  - `flatten_patchwork`:
    
    Flatten nested patchwork objects

## ggplot2 Themes

  - `theme_my`:
    
    Clean general-purpose theme

  - `theme_km`:
    
    Kaplan-Meier survival curve theme

  - `theme_rcs`:
    
    Restricted cubic spline theme

## Console Display

  - `.cat_line`:
    
    Styled separator line

  - `.cat_box`:
    
    Styled message box

  - `.cat_message`:
    
    Timestamped log message

  - `.cat_formula`:
    
    Styled model formula

  - `.cat_tb`:
    
    Enhanced gt table with highlighting

## Operators

  - `%ni%`:
    
    Not-in operator

  - `%||%`:
    
    Default value operator

  - `%>%`:
    
    Pipe operator

  - `%<>%`:
    
    Compound assignment pipe
