# Data Inspection: lv, na, check_system

## `lv()` — Variable Summary

[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) provides a
quick overview of variables in a data frame (or Seurat object).

``` r
library(UtilsR)

# All variables
lv(iris)
#> 
#> ── ** summary for Sepal.Length (numeric) ** ────────────────────────────────────
#> ----1. Sepal.Length (numeric) count----------
#> # A tibble: 35 × 2
#>    Sepal.Length     n
#>           <dbl> <int>
#>  1          4.3     1
#>  2          4.4     3
#>  3          4.5     1
#>  4          4.6     4
#>  5          4.7     2
#>  6          4.8     5
#>  7          4.9     6
#>  8          5      10
#>  9          5.1     9
#> 10          5.2     4
#> # ℹ 25 more rows
#> ----2. Sepal.Length (numeric) unique----------
#> [1] .get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))
#> 
#> ── ** summary for Sepal.Width (numeric) ** ─────────────────────────────────────
#> ----1. Sepal.Width (numeric) count----------
#> # A tibble: 23 × 2
#>    Sepal.Width     n
#>          <dbl> <int>
#>  1         2       1
#>  2         2.2     3
#>  3         2.3     4
#>  4         2.4     3
#>  5         2.5     8
#>  6         2.6     5
#>  7         2.7     9
#>  8         2.8    14
#>  9         2.9    10
#> 10         3      26
#> # ℹ 13 more rows
#> ----2. Sepal.Width (numeric) unique----------
#> [1] .get.flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","..."))
#> 
#> ── ** summary for Petal.Length (numeric) ** ────────────────────────────────────
#> ----1. Petal.Length (numeric) count----------
#> # A tibble: 43 × 2
#>    Petal.Length     n
#>           <dbl> <int>
#>  1          1       1
#>  2          1.1     1
#>  3          1.2     2
#>  4          1.3     7
#>  5          1.4    13
#>  6          1.5    13
#>  7          1.6     7
#>  8          1.7     4
#>  9          1.9     2
#> 10          3       1
#> # ℹ 33 more rows
#> ----2. Petal.Length (numeric) unique----------
#> [1] .get.flt(Petal.Length %in% c("1.4","1.3","1.5","1.7","1.6","1.1","1.2","1","..."))
#> 
#> ── ** summary for Petal.Width (numeric) ** ─────────────────────────────────────
#> ----1. Petal.Width (numeric) count----------
#> # A tibble: 22 × 2
#>    Petal.Width     n
#>          <dbl> <int>
#>  1         0.1     5
#>  2         0.2    29
#>  3         0.3     7
#>  4         0.4     7
#>  5         0.5     1
#>  6         0.6     1
#>  7         1       7
#>  8         1.1     3
#>  9         1.2     5
#> 10         1.3    13
#> # ℹ 12 more rows
#> ----2. Petal.Width (numeric) unique----------
#> [1] .get.flt(Petal.Width %in% c("0.2","0.4","0.3","0.1","0.5","0.6","1.4","1.5","..."))
#> 
#> ── ** summary for Species (factor) ** ──────────────────────────────────────────
#> ----1. Species (factor) count----------
#> # A tibble: 3 × 2
#>   Species        n
#>   <fct>      <int>
#> 1 setosa        50
#> 2 versicolor    50
#> 3 virginica     50
#> ----2. Species (factor) Levels----------
#> [1] .get.flt(Species %in% c("setosa","versicolor","virginica"))
#> Setting theme "Compact"
#> ==================   ℹ ** Variable Counts (5 variables) ** ℹ   =================
#> # A tibble: 20 × 2
#>    `**Vars**`                     `**Summary**`    
#>    <chr>                          <chr>            
#>  1 __Sepal.Length (numeric, 35)__ NA               
#>  2 Min, Max                       4.30, 7.90       
#>  3 Median [Q1, Q3]                5.80 [5.10, 6.40]
#>  4 Mean (SD)                      5.84 (0.83)      
#>  5 __Sepal.Width (numeric, 23)__  NA               
#>  6 Min, Max                       2.00, 4.40       
#>  7 Median [Q1, Q3]                3.00 [2.80, 3.30]
#>  8 Mean (SD)                      3.06 (0.44)      
#>  9 __Petal.Length (numeric, 43)__ NA               
#> 10 Min, Max                       1.00, 6.90       
#> 11 Median [Q1, Q3]                4.35 [1.60, 5.10]
#> 12 Mean (SD)                      3.76 (1.77)      
#> 13 __Petal.Width (numeric, 22)__  NA               
#> 14 Min, Max                       0.10, 2.50       
#> 15 Median [Q1, Q3]                1.30 [0.30, 1.80]
#> 16 Mean (SD)                      1.20 (0.76)      
#> 17 __Species (factor, 3)__        NA               
#> 18 setosa                         50 (33%)         
#> 19 versicolor                     50 (33%)         
#> 20 virginica                      50 (33%)         
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
#>   font-size: 13px;
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
#>   background-color: #FFFFFF;
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
#>   background-color: #FFFFFF;
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
#>   background-color: #FFFFFF;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mwlefoodfi .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mwlefoodfi .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Vars</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Summary</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length (numeric, 35)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">4.30, 7.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">5.84 (0.83)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Width (numeric, 23)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">2.00, 4.40</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">3.00 [2.80, 3.30]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">3.06 (0.44)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Petal.Length (numeric, 43)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">1.00, 6.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">4.35 [1.60, 5.10]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">3.76 (1.77)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Petal.Width (numeric, 22)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">0.10, 2.50</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">1.30 [0.30, 1.80]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">1.20 (0.76)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Species (factor, 3)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    setosa</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    versicolor</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    virginica</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
#> =================   ✓ ** Variable Summary (5 variables) ** ✓   =================
#> # A tibble: 5 × 6
#>   vars         class   n_unique  n_na n_special unique                          
#>   <chr>        <chr>      <int> <int>     <dbl> <noquote>                       
#> 1 Sepal.Length numeric       35     0         0 .get.flt(Sepal.Length %in% c("5…
#> 2 Sepal.Width  numeric       23     0         0 .get.flt(Sepal.Width %in% c("3.…
#> 3 Petal.Length numeric       43     0         0 .get.flt(Petal.Length %in% c("1…
#> 4 Petal.Width  numeric       22     0         0 .get.flt(Petal.Width %in% c("0.…
#> 5 Species      factor         3     0         0 .get.flt(Species %in% c("setosa…
#> <div id="yorehalspk" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#yorehalspk table {
#>   font-family: Calibri, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
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
#>   font-size: 16px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: solid;
#>   border-left-width: 2px;
#>   border-left-color: #000000;
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
#>   border-bottom-color: #000000;
#> }
#> 
#> #yorehalspk .gt_col_headings {
#>   border-top-style: none;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
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
#>   font-size: 85%;
#>   font-weight: bold;
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
#>   font-size: 85%;
#>   font-weight: bold;
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
#>   border-bottom-color: #000000;
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
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
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
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
#>   border-right-color: #000000;
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
#>   background-color: #D3D3D3;
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
#>       <td colspan="6" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Variable Summary</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>150</em> observations, <em>5</em> variables, <em>0</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; font-weight: bold;" scope="col" id="vars">vars</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="class">class</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_unique">n_unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_na">n_na</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_special">n_special</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-right-width: 2px; border-right-style: solid; border-right-color: black; font-weight: bold;" scope="col" id="unique">unique</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Length</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">35</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Width</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">23</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Petal.Length</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">43</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Petal.Length %in% c("1.4","1.3","1.5","1.7","1.6","1.1","1.2","1","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Petal.Width</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">22</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Petal.Width %in% c("0.2","0.4","0.3","0.1","0.5","0.6","1.4","1.5","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">Species</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">factor</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">3</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Species %in% c("setosa","versicolor","virginica"))</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> <div id="jlmpgudacg" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jlmpgudacg table {
#>   font-family: Calibri, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jlmpgudacg thead, #jlmpgudacg tbody, #jlmpgudacg tfoot, #jlmpgudacg tr, #jlmpgudacg td, #jlmpgudacg th {
#>   border-style: none;
#> }
#> 
#> #jlmpgudacg p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jlmpgudacg .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 16px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: solid;
#>   border-left-width: 2px;
#>   border-left-color: #000000;
#> }
#> 
#> #jlmpgudacg .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jlmpgudacg .gt_title {
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
#> #jlmpgudacg .gt_subtitle {
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
#> #jlmpgudacg .gt_heading {
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
#> #jlmpgudacg .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#> }
#> 
#> #jlmpgudacg .gt_col_headings {
#>   border-top-style: none;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
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
#> #jlmpgudacg .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #jlmpgudacg .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jlmpgudacg .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jlmpgudacg .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #jlmpgudacg .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jlmpgudacg .gt_group_heading {
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #jlmpgudacg .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: middle;
#> }
#> 
#> #jlmpgudacg .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jlmpgudacg .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jlmpgudacg .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #jlmpgudacg .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jlmpgudacg .gt_stub_row_group {
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
#> #jlmpgudacg .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jlmpgudacg .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jlmpgudacg .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jlmpgudacg .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jlmpgudacg .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jlmpgudacg .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_striped {
#>   background-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jlmpgudacg .gt_footnotes {
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
#> #jlmpgudacg .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jlmpgudacg .gt_sourcenotes {
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
#> #jlmpgudacg .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jlmpgudacg .gt_left {
#>   text-align: left;
#> }
#> 
#> #jlmpgudacg .gt_center {
#>   text-align: center;
#> }
#> 
#> #jlmpgudacg .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jlmpgudacg .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jlmpgudacg .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jlmpgudacg .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jlmpgudacg .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jlmpgudacg .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jlmpgudacg .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jlmpgudacg .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jlmpgudacg .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jlmpgudacg .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jlmpgudacg .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jlmpgudacg .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jlmpgudacg .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jlmpgudacg div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Variable Summary</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>150</em> observations, <em>5</em> variables, <em>0</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; font-weight: bold;" scope="col" id="vars">vars</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="class">class</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_unique">n_unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_na">n_na</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_special">n_special</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-right-width: 2px; border-right-style: solid; border-right-color: black; font-weight: bold;" scope="col" id="unique">unique</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Length</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">35</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Width</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">23</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Petal.Length</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">43</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Petal.Length %in% c("1.4","1.3","1.5","1.7","1.6","1.1","1.2","1","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Petal.Width</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">22</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Petal.Width %in% c("0.2","0.4","0.3","0.1","0.5","0.6","1.4","1.5","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">Species</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">factor</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">3</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Species %in% c("setosa","versicolor","virginica"))</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> <div id="jcdmfnbyes" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jcdmfnbyes table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jcdmfnbyes thead, #jcdmfnbyes tbody, #jcdmfnbyes tfoot, #jcdmfnbyes tr, #jcdmfnbyes td, #jcdmfnbyes th {
#>   border-style: none;
#> }
#> 
#> #jcdmfnbyes p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jcdmfnbyes .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
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
#> #jcdmfnbyes .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jcdmfnbyes .gt_title {
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
#> #jcdmfnbyes .gt_subtitle {
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
#> #jcdmfnbyes .gt_heading {
#>   background-color: #FFFFFF;
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
#> #jcdmfnbyes .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcdmfnbyes .gt_col_headings {
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
#> #jcdmfnbyes .gt_col_heading {
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
#> #jcdmfnbyes .gt_column_spanner_outer {
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
#> #jcdmfnbyes .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jcdmfnbyes .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jcdmfnbyes .gt_column_spanner {
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
#> #jcdmfnbyes .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jcdmfnbyes .gt_group_heading {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #jcdmfnbyes .gt_empty_group_heading {
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
#> #jcdmfnbyes .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jcdmfnbyes .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jcdmfnbyes .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #jcdmfnbyes .gt_stub {
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
#> #jcdmfnbyes .gt_stub_row_group {
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
#> #jcdmfnbyes .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jcdmfnbyes .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jcdmfnbyes .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcdmfnbyes .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jcdmfnbyes .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jcdmfnbyes .gt_last_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcdmfnbyes .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcdmfnbyes .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jcdmfnbyes .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcdmfnbyes .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #jcdmfnbyes .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcdmfnbyes .gt_footnotes {
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
#> #jcdmfnbyes .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcdmfnbyes .gt_sourcenotes {
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
#> #jcdmfnbyes .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcdmfnbyes .gt_left {
#>   text-align: left;
#> }
#> 
#> #jcdmfnbyes .gt_center {
#>   text-align: center;
#> }
#> 
#> #jcdmfnbyes .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jcdmfnbyes .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jcdmfnbyes .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jcdmfnbyes .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jcdmfnbyes .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jcdmfnbyes .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jcdmfnbyes .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jcdmfnbyes .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jcdmfnbyes .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jcdmfnbyes .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jcdmfnbyes .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jcdmfnbyes .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jcdmfnbyes .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jcdmfnbyes div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Vars</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Summary</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length (numeric, 35)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">4.30, 7.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">5.84 (0.83)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Width (numeric, 23)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">2.00, 4.40</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">3.00 [2.80, 3.30]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">3.06 (0.44)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Petal.Length (numeric, 43)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">1.00, 6.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">4.35 [1.60, 5.10]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">3.76 (1.77)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Petal.Width (numeric, 22)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">0.10, 2.50</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">1.30 [0.30, 1.80]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">1.20 (0.76)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Species (factor, 3)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    setosa</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    versicolor</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    virginica</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```

``` r
# Select specific variables
lv(iris, Species, Sepal.Length)
#> 
#> ── ** summary for Species (factor) ** ──────────────────────────────────────────
#> ----1. Species (factor) count----------
#> # A tibble: 3 × 2
#>   Species        n
#>   <fct>      <int>
#> 1 setosa        50
#> 2 versicolor    50
#> 3 virginica     50
#> ----2. Species (factor) Levels----------
#> [1] .get.flt(Species %in% c("setosa","versicolor","virginica"))
#> 
#> ── ** summary for Sepal.Length (numeric) ** ────────────────────────────────────
#> ----1. Sepal.Length (numeric) count----------
#> # A tibble: 35 × 2
#>    Sepal.Length     n
#>           <dbl> <int>
#>  1          4.3     1
#>  2          4.4     3
#>  3          4.5     1
#>  4          4.6     4
#>  5          4.7     2
#>  6          4.8     5
#>  7          4.9     6
#>  8          5      10
#>  9          5.1     9
#> 10          5.2     4
#> # ℹ 25 more rows
#> ----2. Sepal.Length (numeric) unique----------
#> [1] .get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))
#> Setting theme "Compact"
#> ==================   ℹ ** Variable Counts (2 variables) ** ℹ   =================
#> # A tibble: 8 × 2
#>   `**Vars**`                     `**Summary**`    
#>   <chr>                          <chr>            
#> 1 __Species (factor, 3)__        NA               
#> 2 setosa                         50 (33%)         
#> 3 versicolor                     50 (33%)         
#> 4 virginica                      50 (33%)         
#> 5 __Sepal.Length (numeric, 35)__ NA               
#> 6 Min, Max                       4.30, 7.90       
#> 7 Median [Q1, Q3]                5.80 [5.10, 6.40]
#> 8 Mean (SD)                      5.84 (0.83)      
#> <div id="apwoktayyj" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#apwoktayyj table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #apwoktayyj thead, #apwoktayyj tbody, #apwoktayyj tfoot, #apwoktayyj tr, #apwoktayyj td, #apwoktayyj th {
#>   border-style: none;
#> }
#> 
#> #apwoktayyj p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #apwoktayyj .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
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
#> #apwoktayyj .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #apwoktayyj .gt_title {
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
#> #apwoktayyj .gt_subtitle {
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
#> #apwoktayyj .gt_heading {
#>   background-color: #FFFFFF;
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
#> #apwoktayyj .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #apwoktayyj .gt_col_headings {
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
#> #apwoktayyj .gt_col_heading {
#>   color: #333333;
#>   background-color: #FFFFFF;
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
#> #apwoktayyj .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #apwoktayyj .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #apwoktayyj .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #apwoktayyj .gt_column_spanner {
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
#> #apwoktayyj .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #apwoktayyj .gt_group_heading {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #apwoktayyj .gt_empty_group_heading {
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
#> #apwoktayyj .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #apwoktayyj .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #apwoktayyj .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #apwoktayyj .gt_stub {
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
#> #apwoktayyj .gt_stub_row_group {
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
#> #apwoktayyj .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #apwoktayyj .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #apwoktayyj .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #apwoktayyj .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #apwoktayyj .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #apwoktayyj .gt_last_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #apwoktayyj .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #apwoktayyj .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #apwoktayyj .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #apwoktayyj .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #apwoktayyj .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #apwoktayyj .gt_footnotes {
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
#> #apwoktayyj .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #apwoktayyj .gt_sourcenotes {
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
#> #apwoktayyj .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #apwoktayyj .gt_left {
#>   text-align: left;
#> }
#> 
#> #apwoktayyj .gt_center {
#>   text-align: center;
#> }
#> 
#> #apwoktayyj .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #apwoktayyj .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #apwoktayyj .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #apwoktayyj .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #apwoktayyj .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #apwoktayyj .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #apwoktayyj .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #apwoktayyj .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #apwoktayyj .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #apwoktayyj .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #apwoktayyj .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #apwoktayyj .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #apwoktayyj .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #apwoktayyj div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Vars</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Summary</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Species (factor, 3)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    setosa</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    versicolor</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    virginica</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length (numeric, 35)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">4.30, 7.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">5.84 (0.83)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
#> =================   ✓ ** Variable Summary (2 variables) ** ✓   =================
#> # A tibble: 2 × 6
#>   vars         class   n_unique  n_na n_special unique                          
#>   <chr>        <chr>      <int> <int>     <dbl> <noquote>                       
#> 1 Species      factor         3     0         0 .get.flt(Species %in% c("setosa…
#> 2 Sepal.Length numeric       35     0         0 .get.flt(Sepal.Length %in% c("5…
#> <div id="aipjjkurjx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#aipjjkurjx table {
#>   font-family: Calibri, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #aipjjkurjx thead, #aipjjkurjx tbody, #aipjjkurjx tfoot, #aipjjkurjx tr, #aipjjkurjx td, #aipjjkurjx th {
#>   border-style: none;
#> }
#> 
#> #aipjjkurjx p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #aipjjkurjx .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 16px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: solid;
#>   border-left-width: 2px;
#>   border-left-color: #000000;
#> }
#> 
#> #aipjjkurjx .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #aipjjkurjx .gt_title {
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
#> #aipjjkurjx .gt_subtitle {
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
#> #aipjjkurjx .gt_heading {
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
#> #aipjjkurjx .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#> }
#> 
#> #aipjjkurjx .gt_col_headings {
#>   border-top-style: none;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
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
#> #aipjjkurjx .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #aipjjkurjx .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #aipjjkurjx .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #aipjjkurjx .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #aipjjkurjx .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #aipjjkurjx .gt_group_heading {
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #aipjjkurjx .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: middle;
#> }
#> 
#> #aipjjkurjx .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #aipjjkurjx .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #aipjjkurjx .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #aipjjkurjx .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aipjjkurjx .gt_stub_row_group {
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
#> #aipjjkurjx .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #aipjjkurjx .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #aipjjkurjx .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aipjjkurjx .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #aipjjkurjx .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aipjjkurjx .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_striped {
#>   background-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aipjjkurjx .gt_footnotes {
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
#> #aipjjkurjx .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aipjjkurjx .gt_sourcenotes {
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
#> #aipjjkurjx .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aipjjkurjx .gt_left {
#>   text-align: left;
#> }
#> 
#> #aipjjkurjx .gt_center {
#>   text-align: center;
#> }
#> 
#> #aipjjkurjx .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #aipjjkurjx .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #aipjjkurjx .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #aipjjkurjx .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #aipjjkurjx .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #aipjjkurjx .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #aipjjkurjx .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #aipjjkurjx .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #aipjjkurjx .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #aipjjkurjx .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #aipjjkurjx .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #aipjjkurjx .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #aipjjkurjx .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #aipjjkurjx div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Variable Summary</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>150</em> observations, <em>2</em> variables, <em>0</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; font-weight: bold;" scope="col" id="vars">vars</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="class">class</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_unique">n_unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_na">n_na</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_special">n_special</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-right-width: 2px; border-right-style: solid; border-right-color: black; font-weight: bold;" scope="col" id="unique">unique</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Species</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">factor</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">3</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Species %in% c("setosa","versicolor","virginica"))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Length</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">35</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> <div id="jgwtlmpwzb" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jgwtlmpwzb table {
#>   font-family: Calibri, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jgwtlmpwzb thead, #jgwtlmpwzb tbody, #jgwtlmpwzb tfoot, #jgwtlmpwzb tr, #jgwtlmpwzb td, #jgwtlmpwzb th {
#>   border-style: none;
#> }
#> 
#> #jgwtlmpwzb p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jgwtlmpwzb .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 16px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: solid;
#>   border-left-width: 2px;
#>   border-left-color: #000000;
#> }
#> 
#> #jgwtlmpwzb .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jgwtlmpwzb .gt_title {
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
#> #jgwtlmpwzb .gt_subtitle {
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
#> #jgwtlmpwzb .gt_heading {
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
#> #jgwtlmpwzb .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#> }
#> 
#> #jgwtlmpwzb .gt_col_headings {
#>   border-top-style: none;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
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
#> #jgwtlmpwzb .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #jgwtlmpwzb .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jgwtlmpwzb .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jgwtlmpwzb .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #jgwtlmpwzb .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jgwtlmpwzb .gt_group_heading {
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #jgwtlmpwzb .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: middle;
#> }
#> 
#> #jgwtlmpwzb .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jgwtlmpwzb .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jgwtlmpwzb .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #jgwtlmpwzb .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jgwtlmpwzb .gt_stub_row_group {
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
#> #jgwtlmpwzb .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jgwtlmpwzb .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jgwtlmpwzb .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jgwtlmpwzb .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jgwtlmpwzb .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jgwtlmpwzb .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_striped {
#>   background-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jgwtlmpwzb .gt_footnotes {
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
#> #jgwtlmpwzb .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jgwtlmpwzb .gt_sourcenotes {
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
#> #jgwtlmpwzb .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jgwtlmpwzb .gt_left {
#>   text-align: left;
#> }
#> 
#> #jgwtlmpwzb .gt_center {
#>   text-align: center;
#> }
#> 
#> #jgwtlmpwzb .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jgwtlmpwzb .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jgwtlmpwzb .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jgwtlmpwzb .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jgwtlmpwzb .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jgwtlmpwzb .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jgwtlmpwzb .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jgwtlmpwzb .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jgwtlmpwzb .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jgwtlmpwzb .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jgwtlmpwzb .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jgwtlmpwzb .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jgwtlmpwzb .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jgwtlmpwzb div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Variable Summary</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>150</em> observations, <em>2</em> variables, <em>0</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; font-weight: bold;" scope="col" id="vars">vars</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="class">class</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_unique">n_unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_na">n_na</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_special">n_special</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-right-width: 2px; border-right-style: solid; border-right-color: black; font-weight: bold;" scope="col" id="unique">unique</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Species</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">factor</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">3</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Species %in% c("setosa","versicolor","virginica"))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Length</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">35</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> <div id="ayrcpilmne" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#ayrcpilmne table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #ayrcpilmne thead, #ayrcpilmne tbody, #ayrcpilmne tfoot, #ayrcpilmne tr, #ayrcpilmne td, #ayrcpilmne th {
#>   border-style: none;
#> }
#> 
#> #ayrcpilmne p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #ayrcpilmne .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
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
#> #ayrcpilmne .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #ayrcpilmne .gt_title {
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
#> #ayrcpilmne .gt_subtitle {
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
#> #ayrcpilmne .gt_heading {
#>   background-color: #FFFFFF;
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
#> #ayrcpilmne .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ayrcpilmne .gt_col_headings {
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
#> #ayrcpilmne .gt_col_heading {
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
#> #ayrcpilmne .gt_column_spanner_outer {
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
#> #ayrcpilmne .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #ayrcpilmne .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #ayrcpilmne .gt_column_spanner {
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
#> #ayrcpilmne .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #ayrcpilmne .gt_group_heading {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #ayrcpilmne .gt_empty_group_heading {
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
#> #ayrcpilmne .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #ayrcpilmne .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #ayrcpilmne .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #ayrcpilmne .gt_stub {
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
#> #ayrcpilmne .gt_stub_row_group {
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
#> #ayrcpilmne .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #ayrcpilmne .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #ayrcpilmne .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ayrcpilmne .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ayrcpilmne .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #ayrcpilmne .gt_last_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ayrcpilmne .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ayrcpilmne .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ayrcpilmne .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ayrcpilmne .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #ayrcpilmne .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ayrcpilmne .gt_footnotes {
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
#> #ayrcpilmne .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ayrcpilmne .gt_sourcenotes {
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
#> #ayrcpilmne .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ayrcpilmne .gt_left {
#>   text-align: left;
#> }
#> 
#> #ayrcpilmne .gt_center {
#>   text-align: center;
#> }
#> 
#> #ayrcpilmne .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #ayrcpilmne .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #ayrcpilmne .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #ayrcpilmne .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #ayrcpilmne .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #ayrcpilmne .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #ayrcpilmne .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #ayrcpilmne .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #ayrcpilmne .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #ayrcpilmne .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #ayrcpilmne .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #ayrcpilmne .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #ayrcpilmne .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #ayrcpilmne div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Vars</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Summary</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Species (factor, 3)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    setosa</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    versicolor</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    virginica</td>
#> <td headers="stat_0" class="gt_row gt_center">50 (33%)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length (numeric, 35)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">4.30, 7.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">5.84 (0.83)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```

``` r
# Regex pattern matching
lv(iris, pattern = "Sepal")
#> 
#> ── ** summary for Sepal.Length (numeric) ** ────────────────────────────────────
#> ----1. Sepal.Length (numeric) count----------
#> # A tibble: 35 × 2
#>    Sepal.Length     n
#>           <dbl> <int>
#>  1          4.3     1
#>  2          4.4     3
#>  3          4.5     1
#>  4          4.6     4
#>  5          4.7     2
#>  6          4.8     5
#>  7          4.9     6
#>  8          5      10
#>  9          5.1     9
#> 10          5.2     4
#> # ℹ 25 more rows
#> ----2. Sepal.Length (numeric) unique----------
#> [1] .get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))
#> 
#> ── ** summary for Sepal.Width (numeric) ** ─────────────────────────────────────
#> ----1. Sepal.Width (numeric) count----------
#> # A tibble: 23 × 2
#>    Sepal.Width     n
#>          <dbl> <int>
#>  1         2       1
#>  2         2.2     3
#>  3         2.3     4
#>  4         2.4     3
#>  5         2.5     8
#>  6         2.6     5
#>  7         2.7     9
#>  8         2.8    14
#>  9         2.9    10
#> 10         3      26
#> # ℹ 13 more rows
#> ----2. Sepal.Width (numeric) unique----------
#> [1] .get.flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","..."))
#> Setting theme "Compact"
#> ==================   ℹ ** Variable Counts (2 variables) ** ℹ   =================
#> # A tibble: 8 × 2
#>   `**Vars**`                     `**Summary**`    
#>   <chr>                          <chr>            
#> 1 __Sepal.Length (numeric, 35)__ NA               
#> 2 Min, Max                       4.30, 7.90       
#> 3 Median [Q1, Q3]                5.80 [5.10, 6.40]
#> 4 Mean (SD)                      5.84 (0.83)      
#> 5 __Sepal.Width (numeric, 23)__  NA               
#> 6 Min, Max                       2.00, 4.40       
#> 7 Median [Q1, Q3]                3.00 [2.80, 3.30]
#> 8 Mean (SD)                      3.06 (0.44)      
#> <div id="frloeemaui" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#frloeemaui table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #frloeemaui thead, #frloeemaui tbody, #frloeemaui tfoot, #frloeemaui tr, #frloeemaui td, #frloeemaui th {
#>   border-style: none;
#> }
#> 
#> #frloeemaui p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #frloeemaui .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
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
#> #frloeemaui .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #frloeemaui .gt_title {
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
#> #frloeemaui .gt_subtitle {
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
#> #frloeemaui .gt_heading {
#>   background-color: #FFFFFF;
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
#> #frloeemaui .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #frloeemaui .gt_col_headings {
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
#> #frloeemaui .gt_col_heading {
#>   color: #333333;
#>   background-color: #FFFFFF;
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
#> #frloeemaui .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #frloeemaui .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #frloeemaui .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #frloeemaui .gt_column_spanner {
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
#> #frloeemaui .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #frloeemaui .gt_group_heading {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #frloeemaui .gt_empty_group_heading {
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
#> #frloeemaui .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #frloeemaui .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #frloeemaui .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #frloeemaui .gt_stub {
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
#> #frloeemaui .gt_stub_row_group {
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
#> #frloeemaui .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #frloeemaui .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #frloeemaui .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #frloeemaui .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #frloeemaui .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #frloeemaui .gt_last_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #frloeemaui .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #frloeemaui .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #frloeemaui .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #frloeemaui .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #frloeemaui .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #frloeemaui .gt_footnotes {
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
#> #frloeemaui .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #frloeemaui .gt_sourcenotes {
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
#> #frloeemaui .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #frloeemaui .gt_left {
#>   text-align: left;
#> }
#> 
#> #frloeemaui .gt_center {
#>   text-align: center;
#> }
#> 
#> #frloeemaui .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #frloeemaui .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #frloeemaui .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #frloeemaui .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #frloeemaui .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #frloeemaui .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #frloeemaui .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #frloeemaui .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #frloeemaui .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #frloeemaui .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #frloeemaui .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #frloeemaui .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #frloeemaui .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #frloeemaui div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Vars</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Summary</strong></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length (numeric, 35)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">4.30, 7.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">5.84 (0.83)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Width (numeric, 23)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">2.00, 4.40</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">3.00 [2.80, 3.30]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">3.06 (0.44)</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> =================   ✓ ** Variable Summary (2 variables) ** ✓   =================
#> # A tibble: 2 × 6
#>   vars         class   n_unique  n_na n_special unique                          
#>   <chr>        <chr>      <int> <int>     <int> <noquote>                       
#> 1 Sepal.Length numeric       35     0         0 .get.flt(Sepal.Length %in% c("5…
#> 2 Sepal.Width  numeric       23     0         0 .get.flt(Sepal.Width %in% c("3.…
#> <div id="zbmhjzpqdi" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#zbmhjzpqdi table {
#>   font-family: Calibri, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #zbmhjzpqdi thead, #zbmhjzpqdi tbody, #zbmhjzpqdi tfoot, #zbmhjzpqdi tr, #zbmhjzpqdi td, #zbmhjzpqdi th {
#>   border-style: none;
#> }
#> 
#> #zbmhjzpqdi p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #zbmhjzpqdi .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 16px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: solid;
#>   border-left-width: 2px;
#>   border-left-color: #000000;
#> }
#> 
#> #zbmhjzpqdi .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #zbmhjzpqdi .gt_title {
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
#> #zbmhjzpqdi .gt_subtitle {
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
#> #zbmhjzpqdi .gt_heading {
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
#> #zbmhjzpqdi .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#> }
#> 
#> #zbmhjzpqdi .gt_col_headings {
#>   border-top-style: none;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
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
#> #zbmhjzpqdi .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #zbmhjzpqdi .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #zbmhjzpqdi .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #zbmhjzpqdi .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #zbmhjzpqdi .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #zbmhjzpqdi .gt_group_heading {
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #zbmhjzpqdi .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: middle;
#> }
#> 
#> #zbmhjzpqdi .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #zbmhjzpqdi .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #zbmhjzpqdi .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #zbmhjzpqdi .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbmhjzpqdi .gt_stub_row_group {
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
#> #zbmhjzpqdi .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #zbmhjzpqdi .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #zbmhjzpqdi .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbmhjzpqdi .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #zbmhjzpqdi .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbmhjzpqdi .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_striped {
#>   background-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbmhjzpqdi .gt_footnotes {
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
#> #zbmhjzpqdi .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbmhjzpqdi .gt_sourcenotes {
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
#> #zbmhjzpqdi .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbmhjzpqdi .gt_left {
#>   text-align: left;
#> }
#> 
#> #zbmhjzpqdi .gt_center {
#>   text-align: center;
#> }
#> 
#> #zbmhjzpqdi .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #zbmhjzpqdi .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #zbmhjzpqdi .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #zbmhjzpqdi .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #zbmhjzpqdi .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #zbmhjzpqdi .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #zbmhjzpqdi .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #zbmhjzpqdi .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #zbmhjzpqdi .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #zbmhjzpqdi .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #zbmhjzpqdi .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #zbmhjzpqdi .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #zbmhjzpqdi .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #zbmhjzpqdi div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Variable Summary</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>150</em> observations, <em>2</em> variables, <em>0</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; font-weight: bold;" scope="col" id="vars">vars</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="class">class</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_unique">n_unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_na">n_na</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_special">n_special</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-right-width: 2px; border-right-style: solid; border-right-color: black; font-weight: bold;" scope="col" id="unique">unique</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Length</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">35</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Width</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">23</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","..."))</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> <div id="cdawauvzws" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#cdawauvzws table {
#>   font-family: Calibri, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #cdawauvzws thead, #cdawauvzws tbody, #cdawauvzws tfoot, #cdawauvzws tr, #cdawauvzws td, #cdawauvzws th {
#>   border-style: none;
#> }
#> 
#> #cdawauvzws p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #cdawauvzws .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 16px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: solid;
#>   border-left-width: 2px;
#>   border-left-color: #000000;
#> }
#> 
#> #cdawauvzws .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #cdawauvzws .gt_title {
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
#> #cdawauvzws .gt_subtitle {
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
#> #cdawauvzws .gt_heading {
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
#> #cdawauvzws .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#> }
#> 
#> #cdawauvzws .gt_col_headings {
#>   border-top-style: none;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_col_heading {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
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
#> #cdawauvzws .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #E8F4FD;
#>   font-size: 85%;
#>   font-weight: bold;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #cdawauvzws .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #cdawauvzws .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #cdawauvzws .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #cdawauvzws .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #cdawauvzws .gt_group_heading {
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
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #cdawauvzws .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #000000;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #000000;
#>   vertical-align: middle;
#> }
#> 
#> #cdawauvzws .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #cdawauvzws .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #cdawauvzws .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #000000;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #000000;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #000000;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #cdawauvzws .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #000000;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cdawauvzws .gt_stub_row_group {
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
#> #cdawauvzws .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #cdawauvzws .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #cdawauvzws .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cdawauvzws .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #cdawauvzws .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cdawauvzws .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_striped {
#>   background-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cdawauvzws .gt_footnotes {
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
#> #cdawauvzws .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cdawauvzws .gt_sourcenotes {
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
#> #cdawauvzws .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cdawauvzws .gt_left {
#>   text-align: left;
#> }
#> 
#> #cdawauvzws .gt_center {
#>   text-align: center;
#> }
#> 
#> #cdawauvzws .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #cdawauvzws .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #cdawauvzws .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #cdawauvzws .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #cdawauvzws .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #cdawauvzws .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #cdawauvzws .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #cdawauvzws .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #cdawauvzws .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #cdawauvzws .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #cdawauvzws .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #cdawauvzws .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #cdawauvzws .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #cdawauvzws div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Variable Summary</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="6" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>150</em> observations, <em>2</em> variables, <em>0</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; font-weight: bold;" scope="col" id="vars">vars</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="class">class</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_unique">n_unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_na">n_na</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n_special">n_special</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-right-width: 2px; border-right-style: solid; border-right-color: black; font-weight: bold;" scope="col" id="unique">unique</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="vars" class="gt_row gt_left" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Length</td>
#> <td headers="class" class="gt_row gt_left" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">35</td>
#> <td headers="n_na" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Length %in% c("5.1","4.9","4.7","4.6","5","5.4","4.4","4.8","..."))</td></tr>
#>     <tr><td headers="vars" class="gt_row gt_left gt_striped" style="border-left-width: 2px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">Sepal.Width</td>
#> <td headers="class" class="gt_row gt_left gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">numeric</td>
#> <td headers="n_unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">23</td>
#> <td headers="n_na" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="n_special" class="gt_row gt_right gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 1px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">0</td>
#> <td headers="unique" class="gt_row gt_center gt_striped" style="border-left-width: 1px; border-left-style: solid; border-left-color: black; border-right-width: 2px; border-right-style: solid; border-right-color: black; border-top-width: 1px; border-top-style: solid; border-top-color: black; border-bottom-width: 2px; border-bottom-style: solid; border-bottom-color: black;">.get.flt(Sepal.Width %in% c("3.5","3","3.2","3.1","3.6","3.9","3.4","2.9","..."))</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
#> <div id="hemwkarnih" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#hemwkarnih table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #hemwkarnih thead, #hemwkarnih tbody, #hemwkarnih tfoot, #hemwkarnih tr, #hemwkarnih td, #hemwkarnih th {
#>   border-style: none;
#> }
#> 
#> #hemwkarnih p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #hemwkarnih .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
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
#> #hemwkarnih .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #hemwkarnih .gt_title {
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
#> #hemwkarnih .gt_subtitle {
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
#> #hemwkarnih .gt_heading {
#>   background-color: #FFFFFF;
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
#> #hemwkarnih .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hemwkarnih .gt_col_headings {
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
#> #hemwkarnih .gt_col_heading {
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
#> #hemwkarnih .gt_column_spanner_outer {
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
#> #hemwkarnih .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #hemwkarnih .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #hemwkarnih .gt_column_spanner {
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
#> #hemwkarnih .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #hemwkarnih .gt_group_heading {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #hemwkarnih .gt_empty_group_heading {
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
#> #hemwkarnih .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #hemwkarnih .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #hemwkarnih .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #hemwkarnih .gt_stub {
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
#> #hemwkarnih .gt_stub_row_group {
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
#> #hemwkarnih .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #hemwkarnih .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #hemwkarnih .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hemwkarnih .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hemwkarnih .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #hemwkarnih .gt_last_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hemwkarnih .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hemwkarnih .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hemwkarnih .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hemwkarnih .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #hemwkarnih .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hemwkarnih .gt_footnotes {
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
#> #hemwkarnih .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hemwkarnih .gt_sourcenotes {
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
#> #hemwkarnih .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hemwkarnih .gt_left {
#>   text-align: left;
#> }
#> 
#> #hemwkarnih .gt_center {
#>   text-align: center;
#> }
#> 
#> #hemwkarnih .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #hemwkarnih .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #hemwkarnih .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #hemwkarnih .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #hemwkarnih .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #hemwkarnih .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #hemwkarnih .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #hemwkarnih .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #hemwkarnih .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #hemwkarnih .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #hemwkarnih .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #hemwkarnih .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #hemwkarnih .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #hemwkarnih div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Vars</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Summary</strong></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length (numeric, 35)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">4.30, 7.90</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">5.84 (0.83)</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Width (numeric, 23)</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Min, Max</td>
#> <td headers="stat_0" class="gt_row gt_center">2.00, 4.40</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">3.00 [2.80, 3.30]</td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Mean (SD)</td>
#> <td headers="stat_0" class="gt_row gt_center">3.06 (0.44)</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
```

``` r
# Grouped summary
lv(iris, Sepal.Length, group = "Species")
#> 
#> ── Variable Summary by Species ─────────────────────────────────────────────────
#> ℹ Groups: 3
#> Setting theme "Compact"
#> <div id="qnkvjkybyi" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#qnkvjkybyi table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #qnkvjkybyi thead, #qnkvjkybyi tbody, #qnkvjkybyi tfoot, #qnkvjkybyi tr, #qnkvjkybyi td, #qnkvjkybyi th {
#>   border-style: none;
#> }
#> 
#> #qnkvjkybyi p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #qnkvjkybyi .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
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
#> #qnkvjkybyi .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #qnkvjkybyi .gt_title {
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
#> #qnkvjkybyi .gt_subtitle {
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
#> #qnkvjkybyi .gt_heading {
#>   background-color: #FFFFFF;
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
#> #qnkvjkybyi .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qnkvjkybyi .gt_col_headings {
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
#> #qnkvjkybyi .gt_col_heading {
#>   color: #333333;
#>   background-color: #FFFFFF;
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
#> #qnkvjkybyi .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #qnkvjkybyi .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #qnkvjkybyi .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #qnkvjkybyi .gt_column_spanner {
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
#> #qnkvjkybyi .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #qnkvjkybyi .gt_group_heading {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #qnkvjkybyi .gt_empty_group_heading {
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
#> #qnkvjkybyi .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #qnkvjkybyi .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #qnkvjkybyi .gt_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
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
#> #qnkvjkybyi .gt_stub {
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
#> #qnkvjkybyi .gt_stub_row_group {
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
#> #qnkvjkybyi .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #qnkvjkybyi .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #qnkvjkybyi .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qnkvjkybyi .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qnkvjkybyi .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #qnkvjkybyi .gt_last_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qnkvjkybyi .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qnkvjkybyi .gt_first_grand_summary_row {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qnkvjkybyi .gt_last_grand_summary_row_top {
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qnkvjkybyi .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #qnkvjkybyi .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qnkvjkybyi .gt_footnotes {
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
#> #qnkvjkybyi .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qnkvjkybyi .gt_sourcenotes {
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
#> #qnkvjkybyi .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 1px;
#>   padding-bottom: 1px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qnkvjkybyi .gt_left {
#>   text-align: left;
#> }
#> 
#> #qnkvjkybyi .gt_center {
#>   text-align: center;
#> }
#> 
#> #qnkvjkybyi .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #qnkvjkybyi .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #qnkvjkybyi .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #qnkvjkybyi .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #qnkvjkybyi .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #qnkvjkybyi .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #qnkvjkybyi .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #qnkvjkybyi .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #qnkvjkybyi .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #qnkvjkybyi .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #qnkvjkybyi .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #qnkvjkybyi .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #qnkvjkybyi .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #qnkvjkybyi div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_0"><span class='gt_from_md'><strong>Overall</strong><br />
#> N = 150</span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_1"><span class='gt_from_md'><strong>setosa</strong><br />
#> N = 50</span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_2"><span class='gt_from_md'><strong>versicolor</strong><br />
#> N = 50</span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="stat_3"><span class='gt_from_md'><strong>virginica</strong><br />
#> N = 50</span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">Sepal.Length</td>
#> <td headers="stat_0" class="gt_row gt_center"><br /></td>
#> <td headers="stat_1" class="gt_row gt_center"><br /></td>
#> <td headers="stat_2" class="gt_row gt_center"><br /></td>
#> <td headers="stat_3" class="gt_row gt_center"><br /></td></tr>
#>     <tr><td headers="label" class="gt_row gt_left">    Median [Q1, Q3]</td>
#> <td headers="stat_0" class="gt_row gt_center">5.80 [5.10, 6.40]</td>
#> <td headers="stat_1" class="gt_row gt_center">5.00 [4.80, 5.20]</td>
#> <td headers="stat_2" class="gt_row gt_center">5.90 [5.60, 6.30]</td>
#> <td headers="stat_3" class="gt_row gt_center">6.50 [6.20, 6.90]</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
```

------------------------------------------------------------------------

## `na()` — Missing Value Analysis

``` r
# Create data with NAs
df <- data.frame(
  x = c(1, NA, 3, NA, 5),
  y = c("a", "b", NA, "d", "e"),
  z = 1:5
)
check_na(df)
#> ======   ℹ Data quality analysis: 2 variables with data quality issues ℹ   =====
#> <div id="dagadocnxb" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#dagadocnxb table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #dagadocnxb thead, #dagadocnxb tbody, #dagadocnxb tfoot, #dagadocnxb tr, #dagadocnxb td, #dagadocnxb th {
#>   border-style: none;
#> }
#> 
#> #dagadocnxb p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #dagadocnxb .gt_table {
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
#> #dagadocnxb .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #dagadocnxb .gt_title {
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
#> #dagadocnxb .gt_subtitle {
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
#> #dagadocnxb .gt_heading {
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
#> #dagadocnxb .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dagadocnxb .gt_col_headings {
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
#> #dagadocnxb .gt_col_heading {
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
#> #dagadocnxb .gt_column_spanner_outer {
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
#> #dagadocnxb .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #dagadocnxb .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #dagadocnxb .gt_column_spanner {
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
#> #dagadocnxb .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #dagadocnxb .gt_group_heading {
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
#> #dagadocnxb .gt_empty_group_heading {
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
#> #dagadocnxb .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #dagadocnxb .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #dagadocnxb .gt_row {
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
#> #dagadocnxb .gt_stub {
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
#> #dagadocnxb .gt_stub_row_group {
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
#> #dagadocnxb .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #dagadocnxb .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #dagadocnxb .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dagadocnxb .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #dagadocnxb .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #dagadocnxb .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dagadocnxb .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dagadocnxb .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #dagadocnxb .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dagadocnxb .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #dagadocnxb .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dagadocnxb .gt_footnotes {
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
#> #dagadocnxb .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dagadocnxb .gt_sourcenotes {
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
#> #dagadocnxb .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dagadocnxb .gt_left {
#>   text-align: left;
#> }
#> 
#> #dagadocnxb .gt_center {
#>   text-align: center;
#> }
#> 
#> #dagadocnxb .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #dagadocnxb .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #dagadocnxb .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #dagadocnxb .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #dagadocnxb .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #dagadocnxb .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #dagadocnxb .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #dagadocnxb .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #dagadocnxb .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #dagadocnxb .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #dagadocnxb .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #dagadocnxb .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #dagadocnxb .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #dagadocnxb div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal" style><span class='gt_from_md'><strong>Missing &amp; Special Value Analysis</strong></span></td>
#>     </tr>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style><span class='gt_from_md'>Dataset: <em>5</em> observations, <em>3</em> variables, <em>2</em> missing, <em>0</em> Unknown/Blank/N/A</span></td>
#>     </tr>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="variable"><span class='gt_from_md'><strong>Variable</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="missing_combined"><span class='gt_from_md'><strong>Missing</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="special_combined"><span class='gt_from_md'><strong>Unknown/Blank/N/A</strong></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="data_type"><span class='gt_from_md'><strong>Data Type</strong></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FFF3E0;">x</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFCC80;">2 (40.0%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FFF3E0;">numeric</td></tr>
#>     <tr><td headers="variable" class="gt_row gt_left" style="background-color: #FEF9E7;">y</td>
#> <td headers="missing_combined" class="gt_row gt_right" style="text-align: center; background-color: #FFF176;">1 (20.0%)</td>
#> <td headers="special_combined" class="gt_row gt_right" style="text-align: center;">0 (0.0%)</td>
#> <td headers="data_type" class="gt_row gt_left" style="background-color: #FEF9E7;">character</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4"><span class='gt_from_md'><strong>Summary:</strong> 3 missing values (20.00%), 0 special values (0.00%) out of 15 total data points</span></td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```

------------------------------------------------------------------------

## `check_system()` — System Diagnostics

``` r
check_system()
```

Reports OS, R version, memory, CPU info, and loaded packages.

## `check_size()` — Object Memory Profiling

``` r
check_size()
```

Shows memory usage of all objects in the current environment.
