# Package index

## Advanced Plot Functions

Publication-ready scatter, heatmap and circular plots.

<!-- end list -->

  - `PlotScatter1()` : Grouped Scatter Plot with Marginal Boxplots
  - `PlotScatter2()` : Dual-Group Scatter Plot with Multi-Variable
    Marginal Boxplots
  - `PlotScatter3()` : Paired Scatter Plot with Rotated Histogram Inset
  - `PlotDumbbell()` : Dumbbell Chart for Paired Comparisons
  - `PlotHeatmapJaccard()` : Jaccard Similarity Heatmap
  - `PlotRank()` : Rank Scatter Plot
  - `PlotCircleLollipop()` : Circular Lollipop Chart
  - `PlotButterfly()` : Butterfly Chart (Back-to-Back Symmetric Plot)
  - `PlotButterfly2()` : Butterfly Plot from Long-Format Data
  - `PlotRankCor()` : Rank Correlation Scatter Plot

## Plot Functions

High-level plotting functions for categorical data visualization.

<!-- end list -->

  - `plt_cat()` : Unified Categorical Variable Plot
  - `plt_con()` : Unified Continuous Variable Plot
  - `plt_alluvial()` : Plot a Faceted Alluvial Distribution
  - `plt_dist()` : Plot Categorical Variable Distribution
  - `plt_sankey()` : Sankey Diagram for Categorical Variables
  - `plt_upset()` : UpSet and Venn Diagram for Set Intersections

## Data Inspection

Explore variables, missing values, and system resources.

<!-- end list -->

  - `lv()` : Variable Inspection Generic Function
  - `check_na()` : Comprehensive Data Quality Analysis
  - `impute_na_knn()` : Impute Missing Values with Weighted K-Nearest
    Neighbours
  - `plt_na()` : Plot Missing Values
  - `check_system()` : Check System Resources and Environment
  - `check_size()` : Analyze Object Sizes in Global Environment
  - `count_packages_in_libpaths()` : Count Installed Packages in Each
    Library Path

## File System

Working-directory and path helpers.

<!-- end list -->

  - `set_wd()` : Create a Directory (if Needed) and Set It as the
    Working Directory

## Factor Manipulation

Recode, reorder, and transform factor variables.

<!-- end list -->

  - `fct_cat()` : Unified Factor Manipulation
  - `fct_label()` : Relabel factor levels (generic: vector or data-frame
    column)
  - `fct_num()` : Convert Numeric to Factor
  - `fct_to_combine()` : Combine Multiple Vectors / Columns into a
    Single Factor (generic)
  - `fct_to_group()` : Group Factor Levels by Integer Indices

## Statistical Formatting

Format confidence intervals and p-values.

<!-- end list -->

  - `stat_ci()` : Format Confidence Intervals or Mean (SD)
  - `stat_pval()` : Format P-values, Numbers, or Add Stars to Any Value
  - `stat_ci_parse()` : Parse Confidence Interval Strings

## Colour Palettes

Built-in colour palettes and palette utilities.

<!-- end list -->

  - `pal_lancet` : Lancet Colour Palette
  - `pal_bar` : Bar Colour Palette
  - `pal_other` : Additional Built-in Colour Palettes
  - `pal_heat` : Diverging Heatmap Fill Palettes
  - `pal_paraSC` : Parathyroid Single-Cell Colour Palette
  - `pal_get()` : Get Colours from a Named Palette
  - `pal_list()` : List All Available Palettes
  - `pal_show()` : Visualise Palettes or Colour Vectors
  - `pal_show_brewer()` : Visualise RColorBrewer Palettes
  - `pal_show_ggsci()` : Visualise ggsci Palettes
  - `pal_show_hcl()` : Visualise Base R HCL Palettes
  - `pal_show_viridis()` : Visualise Viridis Palettes
  - `show_color()` : Display Colour Swatches in Console
  - `palette_list` : Built-in Palette Collection

## ggplot2 Formatting

Chain-able ggplot2 formatting helpers.

<!-- end list -->

  - `fmt_plot()` : Master plot formatting function
  - `fmt_plot_base()` : Broadcast theme / labs / scales onto a patchwork
    via \`&\`
  - `fmt_axis()` : Hide or show axis elements for specific plots
  - `fmt_axisText()` : Format axis text rotation and style
  - `fmt_axisTile()` : Add colored tiles between axis and labels
  - `fmt_panel()` : Format panel appearance
  - `fmt_text()` : Format plot labels and their text style
  - `fmt_tag()` : Add panel labels to plots
  - `fmt_legend()` : Format legend position and style
  - `fmt_ref()` : Add reference lines to plots
  - `fmt_strip()` : Add facet strip labels to a plot
  - `fmt_strip2()` : Add facet-grid-style strips to a patchwork grid
    (top headers + side labels)
  - `fmt_com()` : Add pairwise statistical comparisons
  - `fmt_bg()` : Add coloured background stripes
  - `fmt_his()` : Add marginal histogram or density overlay
  - `fmt_scale()` : Set axis scales
  - `fmt_expand()` : Set axis expansion
  - `fmt_boxplot()` : Overlay a boxplot layer
  - `fmt_point()` : Add Data Points to a Plot
  - `fmt_raster()` : Rasterize Plot Panels
  - `flatten_patchwork()` : Flatten nested patchwork objects

## Themes

ggplot2 themes.

<!-- end list -->

  - `theme_my()` : Custom ggplot2 Theme Based on ggprism
  - `theme_heat()` : Heatmap / Tile Plot Theme
  - `theme_km` : Kaplan-Meier Plot Theme
  - `theme_rcs` : RCS (Restricted Cubic Spline) Plot Theme
  - `theme_legend1()` : Compact Legend Theme
  - `theme_blank()` : Blank Theme with Coordinate Arrows
  - `theme_sc()` : Single-Cell Style Theme
  - `theme_ROC()` : ROC / Calibration Plot Theme
  - `theme_legend()` : Customizable Legend Theme
  - `theme_alluvia()` : Alluvial / Sankey Plot Theme
  - `theme_scatter` : Scatter / Feature Plot Theme
  - `leg1()` : Quick Legend Theme (with title)
  - `leg2()` : Quick Legend Theme (no title)

## Grob Utilities

Helpers for manipulating ggplot2 grobs.

<!-- end list -->

  - `grob_add()` : Add a Grob to a Gtable at a Specified Position
  - `grob_as()` : Convert a Plot Object to a Grob
  - `grob_insert()` : Insert an Inset Plot Inside Another Plot
  - `grob_to_gg()` : Convert a Grob or Gtable Back to a ggplot Object

## Console Display

Styled console output helpers.

<!-- end list -->

  - `.cat_box()` : Styled info box
  - `.cat_formula()` : Print model formula with styled header
  - `.cat_line()` : Styled separator line
  - `.cat_message()` : Styled log message with timestamp
  - `.cat_tb()` : Enhanced Table Display with Pattern Highlighting
  - `console_width()` : Get console width

## Operators

Convenience operators.

<!-- end list -->

  - `` `%<>%` `` : Compound assignment pipe operator
  - `` `%ni%` `` : Not-in operator
  - `%>%` `%||%` : Pipe operator
