# Comprehensive Data Quality Analysis

Analyze missing values and special values (e.g. "unknown", "blank",
"n/a") for each variable. Outputs a styled `gt` table with conditional
formatting based on severity.

## Usage

``` r
check_na(data, ..., pattern = NULL, show_all = FALSE)
```

## Arguments

- data:

  A data.frame with unique, non-empty column names. Selected columns
  must be one-dimensional. Grouped inputs are inspected across all rows,
  preserving the grouping in the returned input.

- ...:

  Variable selection using
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  syntax. Omit to inspect all columns. Renaming changes only the
  displayed variable names.

- pattern:

  `NULL` or a single non-missing character string used as a regex
  pattern for matching variable names. Takes precedence over `...`. An
  empty string matches all columns. An unmatched pattern or selection
  inspects no columns and returns the input with an informational
  message.

- show_all:

  A single non-missing logical. If `FALSE` (default), only variables
  with issues are shown.

## Value

Invisibly returns the complete input data unchanged, including columns
that were not selected for inspection.

## Details

Inputs with zero rows or zero columns return unchanged with an
informational message and no table. Special-value counts apply to
character and factor columns. Matching is case-insensitive and uses
Unicode-aware whole-word markers after collapsing whitespace, including
Unicode spaces. Whitespace-only strings count as blank values. Each
value is counted once. Values recognized by
[`is.na()`](https://rdrr.io/r/base/NA.html), including SPSS user-missing
codes, count only as missing values. Inspection loads methods for
serialized haven-labelled and integer64 columns before counting missing
values. Integer64 columns require the optional bit64 package.
Dataset-size calculations use double precision, and counts are formatted
as whole numbers without a 32-bit integer limit. Severity colors use
unrounded percentages. Missing-value shading is yellow above 0%, orange
above 20% and red above 50%, and also tints the variable and type cells.
Special-value shading deepens from light to dark blue above 0%, 10% and
30%. A source note under the table repeats these thresholds. Percentages
are rounded only for display, to one decimal place in cells and two in
the summary. Positive percentages below these display resolutions appear
as `<0.1%` in cells and `<0.01%` in the summary; zeros retain their
usual numeric format. The subtitle counts variables containing issues;
the summary counts individual missing and special values across the
selected columns. Both summary percentages use every selected cell as
the denominator, including columns that cannot hold special values.

## See also

Other inspect:
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md),
[`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)

## Examples

``` r
# \donttest{
# Analyze all variables
check_na(airquality)
#> ======   ℹ Data quality analysis: 2 variables with data quality issues ℹ   =====
#> <div id="koubyfanpq" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#koubyfanpq table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #koubyfanpq thead, #koubyfanpq tbody, #koubyfanpq tfoot, #koubyfanpq tr, #koubyfanpq td, #koubyfanpq th {
#>   border-style: none;
#> }
#> 
#> #koubyfanpq p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #koubyfanpq .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 12px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #A8A8A8;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #A8A8A8;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #koubyfanpq .gt_title {
#>   color: #333333;
#>   font-size: 125%;
#>   font-weight: initial;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-color: #FFFFFF;
#>   border-bottom-width: 0;
#> }
#> 
#> #koubyfanpq .gt_subtitle {
#>   color: #333333;
#>   font-size: 85%;
#>   font-weight: initial;
#>   padding-top: 3px;
#>   padding-bottom: 5px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-color: #FFFFFF;
#>   border-top-width: 0;
#> }
#> 
#> #koubyfanpq .gt_heading {
#>   background-color: #F0F8FF;
#>   text-align: center;
#>   border-bottom-color: #FFFFFF;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_col_headings {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 6px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #koubyfanpq .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #koubyfanpq .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #koubyfanpq .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #koubyfanpq .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #koubyfanpq .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #koubyfanpq .gt_group_heading {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #koubyfanpq .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: middle;
#> }
#> 
#> #koubyfanpq .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #koubyfanpq .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #koubyfanpq .gt_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #koubyfanpq .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #koubyfanpq .gt_stub_row_group {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   vertical-align: top;
#> }
#> 
#> #koubyfanpq .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #koubyfanpq .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #koubyfanpq .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #koubyfanpq .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #koubyfanpq .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #koubyfanpq .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #koubyfanpq .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_footnotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #koubyfanpq .gt_sourcenotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #koubyfanpq .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #koubyfanpq .gt_left {
#>   text-align: left;
#> }
#> 
#> #koubyfanpq .gt_center {
#>   text-align: center;
#> }
#> 
#> #koubyfanpq .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #koubyfanpq .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #koubyfanpq .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #koubyfanpq .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #koubyfanpq .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #koubyfanpq .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #koubyfanpq .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #koubyfanpq .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #koubyfanpq .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #koubyfanpq .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #koubyfanpq .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #koubyfanpq .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #koubyfanpq .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #koubyfanpq div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Missing &amp; Special Value Analysis</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>153</em> observations, <em>6</em> variables, <em>2</em> variables with missing values, <em>0</em> variables with special values</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="variable"><span class='gt_from_md'><strong>Variable</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="missing_combined"><span class='gt_from_md'><strong>Missing</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="special_combined"><span class='gt_from_md'><strong>Unknown/Blank/N/A</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="data_type"><span class='gt_from_md'><strong>Data Type</strong></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FFF3E0;">Ozone</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFCC80;">37 (24.2%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FFF3E0;">integer</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FEF9E7;">Solar.R</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFF176;">7 (4.6%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FEF9E7;">integer</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Summary:</strong> 44 missing values (4.79%), 0 special values (0.00%) out of 918 total data points</span></td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Shading:</strong> missing values &gt;0-20% yellow, &gt;20-50% orange, &gt;50% red; special values &gt;0-10%, &gt;10-30%, &gt;30% light to dark blue</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

# Select specific columns
check_na(airquality, Ozone, Solar.R)
#> ======   ℹ Data quality analysis: 2 variables with data quality issues ℹ   =====
#> <div id="xftutkzana" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#xftutkzana table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #xftutkzana thead, #xftutkzana tbody, #xftutkzana tfoot, #xftutkzana tr, #xftutkzana td, #xftutkzana th {
#>   border-style: none;
#> }
#> 
#> #xftutkzana p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #xftutkzana .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 12px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #A8A8A8;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #A8A8A8;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #xftutkzana .gt_title {
#>   color: #333333;
#>   font-size: 125%;
#>   font-weight: initial;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-color: #FFFFFF;
#>   border-bottom-width: 0;
#> }
#> 
#> #xftutkzana .gt_subtitle {
#>   color: #333333;
#>   font-size: 85%;
#>   font-weight: initial;
#>   padding-top: 3px;
#>   padding-bottom: 5px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-color: #FFFFFF;
#>   border-top-width: 0;
#> }
#> 
#> #xftutkzana .gt_heading {
#>   background-color: #F0F8FF;
#>   text-align: center;
#>   border-bottom-color: #FFFFFF;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_col_headings {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 6px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #xftutkzana .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #xftutkzana .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #xftutkzana .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #xftutkzana .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #xftutkzana .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #xftutkzana .gt_group_heading {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #xftutkzana .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: middle;
#> }
#> 
#> #xftutkzana .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #xftutkzana .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #xftutkzana .gt_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #xftutkzana .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xftutkzana .gt_stub_row_group {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   vertical-align: top;
#> }
#> 
#> #xftutkzana .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #xftutkzana .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #xftutkzana .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xftutkzana .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #xftutkzana .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xftutkzana .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #xftutkzana .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_footnotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xftutkzana .gt_sourcenotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #xftutkzana .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xftutkzana .gt_left {
#>   text-align: left;
#> }
#> 
#> #xftutkzana .gt_center {
#>   text-align: center;
#> }
#> 
#> #xftutkzana .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #xftutkzana .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #xftutkzana .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #xftutkzana .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #xftutkzana .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #xftutkzana .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #xftutkzana .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #xftutkzana .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #xftutkzana .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #xftutkzana .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #xftutkzana .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #xftutkzana .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #xftutkzana .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #xftutkzana div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Missing &amp; Special Value Analysis</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>153</em> observations, <em>2</em> variables, <em>2</em> variables with missing values, <em>0</em> variables with special values</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="variable"><span class='gt_from_md'><strong>Variable</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="missing_combined"><span class='gt_from_md'><strong>Missing</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="special_combined"><span class='gt_from_md'><strong>Unknown/Blank/N/A</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="data_type"><span class='gt_from_md'><strong>Data Type</strong></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FFF3E0;">Ozone</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFCC80;">37 (24.2%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FFF3E0;">integer</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FEF9E7;">Solar.R</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFF176;">7 (4.6%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FEF9E7;">integer</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Summary:</strong> 44 missing values (14.38%), 0 special values (0.00%) out of 306 total data points</span></td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Shading:</strong> missing values &gt;0-20% yellow, &gt;20-50% orange, &gt;50% red; special values &gt;0-10%, &gt;10-30%, &gt;30% light to dark blue</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

# Show all variables including those without issues
check_na(airquality, show_all = TRUE)
#> ============   ℹ Data quality analysis: showing all 6 variables ℹ   ============
#> <div id="gantvslsfl" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#gantvslsfl table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #gantvslsfl thead, #gantvslsfl tbody, #gantvslsfl tfoot, #gantvslsfl tr, #gantvslsfl td, #gantvslsfl th {
#>   border-style: none;
#> }
#> 
#> #gantvslsfl p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #gantvslsfl .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 12px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #A8A8A8;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #A8A8A8;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #gantvslsfl .gt_title {
#>   color: #333333;
#>   font-size: 125%;
#>   font-weight: initial;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-color: #FFFFFF;
#>   border-bottom-width: 0;
#> }
#> 
#> #gantvslsfl .gt_subtitle {
#>   color: #333333;
#>   font-size: 85%;
#>   font-weight: initial;
#>   padding-top: 3px;
#>   padding-bottom: 5px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-color: #FFFFFF;
#>   border-top-width: 0;
#> }
#> 
#> #gantvslsfl .gt_heading {
#>   background-color: #F0F8FF;
#>   text-align: center;
#>   border-bottom-color: #FFFFFF;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_col_headings {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 6px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #gantvslsfl .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #gantvslsfl .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #gantvslsfl .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #gantvslsfl .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #gantvslsfl .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #gantvslsfl .gt_group_heading {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #gantvslsfl .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: middle;
#> }
#> 
#> #gantvslsfl .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #gantvslsfl .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #gantvslsfl .gt_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #gantvslsfl .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gantvslsfl .gt_stub_row_group {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   vertical-align: top;
#> }
#> 
#> #gantvslsfl .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #gantvslsfl .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #gantvslsfl .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gantvslsfl .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #gantvslsfl .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gantvslsfl .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #gantvslsfl .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_footnotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gantvslsfl .gt_sourcenotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #gantvslsfl .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gantvslsfl .gt_left {
#>   text-align: left;
#> }
#> 
#> #gantvslsfl .gt_center {
#>   text-align: center;
#> }
#> 
#> #gantvslsfl .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #gantvslsfl .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #gantvslsfl .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #gantvslsfl .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #gantvslsfl .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #gantvslsfl .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #gantvslsfl .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #gantvslsfl .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #gantvslsfl .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #gantvslsfl .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #gantvslsfl .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #gantvslsfl .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #gantvslsfl .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #gantvslsfl div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Missing &amp; Special Value Analysis</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>153</em> observations, <em>6</em> variables, <em>2</em> variables with missing values, <em>0</em> variables with special values</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="variable"><span class='gt_from_md'><strong>Variable</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="missing_combined"><span class='gt_from_md'><strong>Missing</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="special_combined"><span class='gt_from_md'><strong>Unknown/Blank/N/A</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="data_type"><span class='gt_from_md'><strong>Data Type</strong></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FFF3E0;">Ozone</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFCC80;">37 (24.2%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FFF3E0;">integer</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FEF9E7;">Solar.R</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFF176;">7 (4.6%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FEF9E7;">integer</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left">Wind</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left">numeric</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left">Temp</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left">integer</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left">Month</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left">integer</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left">Day</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left">integer</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Summary:</strong> 44 missing values (4.79%), 0 special values (0.00%) out of 918 total data points</span></td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Shading:</strong> missing values &gt;0-20% yellow, &gt;20-50% orange, &gt;50% red; special values &gt;0-10%, &gt;10-30%, &gt;30% light to dark blue</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
# }
```
