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
#> <div id="mwlefoodfi" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#mwlefoodfi table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #mwlefoodfi thead, #mwlefoodfi tbody, #mwlefoodfi tfoot, #mwlefoodfi tr, #mwlefoodfi td, #mwlefoodfi th {
#>   border-style: none;
#> }
#> 
#> #mwlefoodfi p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #mwlefoodfi .gt_table {
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
#> #mwlefoodfi .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #mwlefoodfi .gt_title {
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
#> #mwlefoodfi .gt_subtitle {
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
#> #mwlefoodfi .gt_heading {
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
#> #mwlefoodfi .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_col_headings {
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
#> #mwlefoodfi .gt_col_heading {
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
#> #mwlefoodfi .gt_column_spanner_outer {
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
#> #mwlefoodfi .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #mwlefoodfi .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #mwlefoodfi .gt_column_spanner {
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
#> #mwlefoodfi .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #mwlefoodfi .gt_group_heading {
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
#> #mwlefoodfi .gt_empty_group_heading {
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
#> #mwlefoodfi .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #mwlefoodfi .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #mwlefoodfi .gt_row {
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
#> #mwlefoodfi .gt_stub {
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
#> #mwlefoodfi .gt_stub_row_group {
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
#> #mwlefoodfi .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #mwlefoodfi .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #mwlefoodfi .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mwlefoodfi .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #mwlefoodfi .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mwlefoodfi .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #mwlefoodfi .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_footnotes {
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
#> #mwlefoodfi .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mwlefoodfi .gt_sourcenotes {
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
#> #mwlefoodfi .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mwlefoodfi .gt_left {
#>   text-align: left;
#> }
#> 
#> #mwlefoodfi .gt_center {
#>   text-align: center;
#> }
#> 
#> #mwlefoodfi .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #mwlefoodfi .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #mwlefoodfi .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #mwlefoodfi .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #mwlefoodfi .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #mwlefoodfi .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #mwlefoodfi .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #mwlefoodfi .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #mwlefoodfi .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #mwlefoodfi .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #mwlefoodfi .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #mwlefoodfi .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #mwlefoodfi .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #mwlefoodfi div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#> <div id="yorehalspk" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#yorehalspk table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #yorehalspk thead, #yorehalspk tbody, #yorehalspk tfoot, #yorehalspk tr, #yorehalspk td, #yorehalspk th {
#>   border-style: none;
#> }
#> 
#> #yorehalspk p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #yorehalspk .gt_table {
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
#> #yorehalspk .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #yorehalspk .gt_title {
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
#> #yorehalspk .gt_subtitle {
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
#> #yorehalspk .gt_heading {
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
#> #yorehalspk .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yorehalspk .gt_col_headings {
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
#> #yorehalspk .gt_col_heading {
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
#> #yorehalspk .gt_column_spanner_outer {
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
#> #yorehalspk .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #yorehalspk .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #yorehalspk .gt_column_spanner {
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
#> #yorehalspk .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #yorehalspk .gt_group_heading {
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
#> #yorehalspk .gt_empty_group_heading {
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
#> #yorehalspk .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #yorehalspk .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #yorehalspk .gt_row {
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
#> #yorehalspk .gt_stub {
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
#> #yorehalspk .gt_stub_row_group {
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
#> #yorehalspk .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #yorehalspk .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #yorehalspk .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yorehalspk .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #yorehalspk .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #yorehalspk .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yorehalspk .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yorehalspk .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #yorehalspk .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yorehalspk .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #yorehalspk .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yorehalspk .gt_footnotes {
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
#> #yorehalspk .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yorehalspk .gt_sourcenotes {
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
#> #yorehalspk .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yorehalspk .gt_left {
#>   text-align: left;
#> }
#> 
#> #yorehalspk .gt_center {
#>   text-align: center;
#> }
#> 
#> #yorehalspk .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #yorehalspk .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #yorehalspk .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #yorehalspk .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #yorehalspk .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #yorehalspk .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #yorehalspk .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #yorehalspk .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #yorehalspk .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #yorehalspk .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #yorehalspk .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #yorehalspk .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #yorehalspk .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #yorehalspk div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#> <div id="hisifmmyuc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#hisifmmyuc table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #hisifmmyuc thead, #hisifmmyuc tbody, #hisifmmyuc tfoot, #hisifmmyuc tr, #hisifmmyuc td, #hisifmmyuc th {
#>   border-style: none;
#> }
#> 
#> #hisifmmyuc p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #hisifmmyuc .gt_table {
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
#> #hisifmmyuc .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #hisifmmyuc .gt_title {
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
#> #hisifmmyuc .gt_subtitle {
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
#> #hisifmmyuc .gt_heading {
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
#> #hisifmmyuc .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hisifmmyuc .gt_col_headings {
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
#> #hisifmmyuc .gt_col_heading {
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
#> #hisifmmyuc .gt_column_spanner_outer {
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
#> #hisifmmyuc .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #hisifmmyuc .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #hisifmmyuc .gt_column_spanner {
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
#> #hisifmmyuc .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #hisifmmyuc .gt_group_heading {
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
#> #hisifmmyuc .gt_empty_group_heading {
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
#> #hisifmmyuc .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #hisifmmyuc .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #hisifmmyuc .gt_row {
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
#> #hisifmmyuc .gt_stub {
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
#> #hisifmmyuc .gt_stub_row_group {
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
#> #hisifmmyuc .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #hisifmmyuc .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #hisifmmyuc .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hisifmmyuc .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hisifmmyuc .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #hisifmmyuc .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hisifmmyuc .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hisifmmyuc .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hisifmmyuc .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hisifmmyuc .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #hisifmmyuc .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hisifmmyuc .gt_footnotes {
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
#> #hisifmmyuc .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hisifmmyuc .gt_sourcenotes {
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
#> #hisifmmyuc .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hisifmmyuc .gt_left {
#>   text-align: left;
#> }
#> 
#> #hisifmmyuc .gt_center {
#>   text-align: center;
#> }
#> 
#> #hisifmmyuc .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #hisifmmyuc .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #hisifmmyuc .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #hisifmmyuc .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #hisifmmyuc .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #hisifmmyuc .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #hisifmmyuc .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #hisifmmyuc .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #hisifmmyuc .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #hisifmmyuc .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #hisifmmyuc .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #hisifmmyuc .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #hisifmmyuc .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #hisifmmyuc div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
