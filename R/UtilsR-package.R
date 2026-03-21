#' @keywords internal
"_PACKAGE"

#' UtilsR: Utility Functions for Data Analysis and Visualisation
#'
#' @description
#' A toolkit for data exploration, factor manipulation, statistical formatting,
#' colour palettes, ggplot2 formatting, and console styling.
#'
#' @section Inspect:
#' \describe{
#'   \item{\code{\link{lv}}}{Variable summary for data.frame / Seurat}
#'   \item{\code{\link{check_na}}}{Missing value and data quality analysis}
#'   \item{\code{\link{check_system}}}{OS, R version, memory, CPU info}
#'   \item{\code{\link{check_size}}}{Object memory profiling}
#'   \item{\code{\link{count_packages_in_libpaths}}}{Count installed packages}
#' }
#'
#' @section Factor:
#' \describe{
#'   \item{\code{\link{fct_cat}}}{Recode, reorder, reverse, binary, group, combine factors}
#'   \item{\code{\link{fct_num}}}{Numeric to factor (cut points or quantile binning)}
#' }
#'
#' @section Format:
#' \describe{
#'   \item{\code{\link{stat_ci}}}{Build or reformat CI strings and mean(SD)}
#'   \item{\code{\link{stat_pval}}}{Format p-values or add significance stars}
#'   \item{\code{\link{stat_ci_parse}}}{Parse CI strings, compute p-values, adjust confidence levels}
#' }
#'
#' @section Colour Palettes:
#' \describe{
#'   \item{\code{\link{pal_lancet}}}{Lancet journal (15 colours)}
#'   \item{\code{\link{pal_other}}}{10 discrete palettes (igv, ditto, polychrome, etc.)}
#'   \item{\code{\link{show_color}}}{Display colour swatches in console}
#'   \item{\code{\link{as_palette}}}{Create custom palette object}
#'   \item{\code{\link{pal_list}}}{Browse all built-in palettes}
#' }
#'
#' @section Plot Functions:
#' \describe{
#'   \item{\code{\link{plt_cat}}}{Unified categorical plot (bar, rose, ring,
#'     pie, trend, area, dot, sankey, chord, venn, upset)}
#'   \item{\code{\link{plt_dist}}}{Cross-distribution (stacked bar / tile
#'     heatmap, auto-selects by variable count)}
#'   \item{\code{\link{plt_cohen}}}{Cohen's d effect size Cleveland dot plot}
#'   \item{\code{\link{plt_radar}}}{Radar (spider) chart}
#'   \item{\code{\link{plt_sankey}}}{Sankey diagram for categorical flow}
#'   \item{\code{\link{plt_upset}}}{UpSet / Venn diagram for set intersections}
#' }
#'
#' @section ggplot2 Formatting:
#' \describe{
#'   \item{\code{\link{fmt_plot}}}{Master chaining function}
#'   \item{\code{\link{fmt_axis}}}{Hide/show axis elements}
#'   \item{\code{\link{fmt_tag}}}{Add panel labels (A, B, C...)}
#'   \item{\code{\link{fmt_legend}}}{Format legend position and style}
#'   \item{\code{\link{fmt_ref}}}{Add reference lines}
#'   \item{\code{\link{fmt_strip}}}{Format facet strip labels}
#'   \item{\code{\link{fmt_com}}}{Add pairwise statistical comparisons}
#'   \item{\code{\link{fmt_bg}}}{Add coloured background stripes}
#'   \item{\code{\link{fmt_his}}}{Add marginal histogram/density}
#'   \item{\code{\link{fmt_scale}}}{Set axis scales}
#'   \item{\code{\link{fmt_expand}}}{Set axis expansion}
#'   \item{\code{\link{fmt_boxplot}}}{Overlay boxplot layer}
#'   \item{\code{\link{flatten_patchwork}}}{Flatten nested patchwork objects}
#' }
#'
#' @section ggplot2 Themes:
#' \describe{
#'   \item{\code{\link{theme_my}}}{Clean general-purpose theme}
#'   \item{\code{\link{theme_km}}}{Kaplan-Meier survival curve theme}
#'   \item{\code{\link{theme_rcs}}}{Restricted cubic spline theme}
#' }
#'
#' @section Console Display:
#' \describe{
#'   \item{\code{\link{.cat_line}}}{Styled separator line}
#'   \item{\code{\link{.cat_box}}}{Styled message box}
#'   \item{\code{\link{.cat_message}}}{Timestamped log message}
#'   \item{\code{\link{.cat_tb}}}{Enhanced gt table with highlighting}
#' }
#'
#' @section Operators:
#' \describe{
#'   \item{\code{\link{\%ni\%}}}{Not-in operator}
#'   \item{\code{\link{\%||\%}}}{Default value operator}
#'   \item{\code{\link{\%>\%}}}{Pipe operator}
#'   \item{\code{\link{\%<>\%}}}{Compound assignment pipe}
#' }
#'
#' @name UtilsR
NULL
