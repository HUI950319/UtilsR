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

  A data.frame.

- ...:

  Variable selection using
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  syntax.

- pattern:

  Optional regex pattern for matching variable names.

- show_all:

  Logical. If `FALSE` (default), only variables with issues are shown.

## Value

Invisibly returns the input data.

## See also

Other inspect:
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`count_packages_in_libpaths()`](https://hui950319.github.io/UtilsR/reference/count_packages_in_libpaths.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)

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
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>153</em> observations, <em>6</em> variables, <em>2</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
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
#>   </tfoot>
#> </table>
#> </div>

# Select specific columns
check_na(airquality, Ozone, Solar.R)
#> ======   ℹ Data quality analysis: 2 variables with data quality issues ℹ   =====
#> <div id="bnpdxuxftu" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#bnpdxuxftu table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #bnpdxuxftu thead, #bnpdxuxftu tbody, #bnpdxuxftu tfoot, #bnpdxuxftu tr, #bnpdxuxftu td, #bnpdxuxftu th {
#>   border-style: none;
#> }
#> 
#> #bnpdxuxftu p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #bnpdxuxftu .gt_table {
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
#> #bnpdxuxftu .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #bnpdxuxftu .gt_title {
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
#> #bnpdxuxftu .gt_subtitle {
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
#> #bnpdxuxftu .gt_heading {
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
#> #bnpdxuxftu .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bnpdxuxftu .gt_col_headings {
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
#> #bnpdxuxftu .gt_col_heading {
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
#> #bnpdxuxftu .gt_column_spanner_outer {
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
#> #bnpdxuxftu .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #bnpdxuxftu .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #bnpdxuxftu .gt_column_spanner {
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
#> #bnpdxuxftu .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #bnpdxuxftu .gt_group_heading {
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
#> #bnpdxuxftu .gt_empty_group_heading {
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
#> #bnpdxuxftu .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #bnpdxuxftu .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #bnpdxuxftu .gt_row {
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
#> #bnpdxuxftu .gt_stub {
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
#> #bnpdxuxftu .gt_stub_row_group {
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
#> #bnpdxuxftu .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #bnpdxuxftu .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #bnpdxuxftu .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bnpdxuxftu .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bnpdxuxftu .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #bnpdxuxftu .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bnpdxuxftu .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bnpdxuxftu .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bnpdxuxftu .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bnpdxuxftu .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #bnpdxuxftu .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bnpdxuxftu .gt_footnotes {
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
#> #bnpdxuxftu .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bnpdxuxftu .gt_sourcenotes {
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
#> #bnpdxuxftu .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bnpdxuxftu .gt_left {
#>   text-align: left;
#> }
#> 
#> #bnpdxuxftu .gt_center {
#>   text-align: center;
#> }
#> 
#> #bnpdxuxftu .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #bnpdxuxftu .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #bnpdxuxftu .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #bnpdxuxftu .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #bnpdxuxftu .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #bnpdxuxftu .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #bnpdxuxftu .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #bnpdxuxftu .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #bnpdxuxftu .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #bnpdxuxftu .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #bnpdxuxftu .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #bnpdxuxftu .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #bnpdxuxftu .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #bnpdxuxftu div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Missing &amp; Special Value Analysis</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>153</em> observations, <em>2</em> variables, <em>2</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
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
#>   </tfoot>
#> </table>
#> </div>

# Show all variables including those without issues
check_na(airquality, show_all = TRUE)
#> ============   ℹ Data quality analysis: showing all 6 variables ℹ   ============
#> <div id="rssjpbzdyz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#rssjpbzdyz table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #rssjpbzdyz thead, #rssjpbzdyz tbody, #rssjpbzdyz tfoot, #rssjpbzdyz tr, #rssjpbzdyz td, #rssjpbzdyz th {
#>   border-style: none;
#> }
#> 
#> #rssjpbzdyz p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #rssjpbzdyz .gt_table {
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
#> #rssjpbzdyz .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #rssjpbzdyz .gt_title {
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
#> #rssjpbzdyz .gt_subtitle {
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
#> #rssjpbzdyz .gt_heading {
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
#> #rssjpbzdyz .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rssjpbzdyz .gt_col_headings {
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
#> #rssjpbzdyz .gt_col_heading {
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
#> #rssjpbzdyz .gt_column_spanner_outer {
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
#> #rssjpbzdyz .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #rssjpbzdyz .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #rssjpbzdyz .gt_column_spanner {
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
#> #rssjpbzdyz .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #rssjpbzdyz .gt_group_heading {
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
#> #rssjpbzdyz .gt_empty_group_heading {
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
#> #rssjpbzdyz .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #rssjpbzdyz .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #rssjpbzdyz .gt_row {
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
#> #rssjpbzdyz .gt_stub {
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
#> #rssjpbzdyz .gt_stub_row_group {
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
#> #rssjpbzdyz .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #rssjpbzdyz .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #rssjpbzdyz .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rssjpbzdyz .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #rssjpbzdyz .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #rssjpbzdyz .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rssjpbzdyz .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rssjpbzdyz .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #rssjpbzdyz .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rssjpbzdyz .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #rssjpbzdyz .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rssjpbzdyz .gt_footnotes {
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
#> #rssjpbzdyz .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rssjpbzdyz .gt_sourcenotes {
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
#> #rssjpbzdyz .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rssjpbzdyz .gt_left {
#>   text-align: left;
#> }
#> 
#> #rssjpbzdyz .gt_center {
#>   text-align: center;
#> }
#> 
#> #rssjpbzdyz .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #rssjpbzdyz .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #rssjpbzdyz .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #rssjpbzdyz .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #rssjpbzdyz .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #rssjpbzdyz .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #rssjpbzdyz .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #rssjpbzdyz .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #rssjpbzdyz .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #rssjpbzdyz .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #rssjpbzdyz .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #rssjpbzdyz .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #rssjpbzdyz .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #rssjpbzdyz div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Missing &amp; Special Value Analysis</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>153</em> observations, <em>6</em> variables, <em>2</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
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
#>   </tfoot>
#> </table>
#> </div>
# }
```
