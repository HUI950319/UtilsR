# Visualise Palettes or Colour Vectors

Display palettes as horizontal colour bars (ggplot) or an interactive gt
table with colour swatches. Use `output = "gg"` for the Plots pane or
`output = "gt"` for the Viewer pane.

## Usage

``` r
pal_show(
  palette = NULL,
  pattern = NULL,
  type = c("all", "discrete", "continuous"),
  max_colors = 20,
  index = NULL,
  output = c("gt", "gg"),
  label = TRUE,
  label_size = 3,
  ncol = NULL
)
```

## Arguments

- palette:

  Character vector of palette names (e.g. `"lancet"`), a colour vector
  (hex codes or named colours), or `NULL` to show all palettes matching
  `pattern`/`type`. Named colour vectors (e.g. `pal_paraSC`) will use
  the names as labels.

- pattern:

  Regex pattern to filter palette names (e.g. `"^nord"`).

- type:

  Filter by type: `"all"`, `"discrete"`, or `"continuous"`.

- max_colors:

  Maximum colours to display per palette. Default 20.

- index:

  Integer vector of palette indices to show (after filtering).

- output:

  Output format: `"gg"` (default) for ggplot or `"gt"` for gt table.

- label:

  Logical. In colour vector mode, whether to show hex/name labels on
  tiles. Default `TRUE`.

- label_size:

  Numeric. Text size for labels in colour vector mode. Default 3.

- ncol:

  Integer. Number of columns for colour vector mode when displaying many
  colours. Default `NULL` (auto: single row if \\\le 20\\ colours,
  otherwise wrap).

## Value

A ggplot or gt object (also prints).

## Details

When `palette` is a character vector of valid colour specifications (hex
codes like `"#FF0000"` or named R colours like `"red"`) rather than
palette names, the function automatically switches to **colour vector
mode**: it displays the colours directly as a single-row colour bar
(ggplot) with hex labels, similar to
[`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
but as a publication-ready plot.

## See also

Other colour palettes:
[`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md)

## Examples

``` r
# Show specific palettes (gt table, default)
pal_show(c("lancet", "Paired", "viridis"))
#> <div id="jxkovzhddv" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jxkovzhddv table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jxkovzhddv thead, #jxkovzhddv tbody, #jxkovzhddv tfoot, #jxkovzhddv tr, #jxkovzhddv td, #jxkovzhddv th {
#>   border-style: none;
#> }
#> 
#> #jxkovzhddv p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jxkovzhddv .gt_table {
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
#> #jxkovzhddv .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jxkovzhddv .gt_title {
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
#> #jxkovzhddv .gt_subtitle {
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
#> #jxkovzhddv .gt_heading {
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
#> #jxkovzhddv .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jxkovzhddv .gt_col_headings {
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
#> #jxkovzhddv .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #jxkovzhddv .gt_column_spanner_outer {
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
#> #jxkovzhddv .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jxkovzhddv .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jxkovzhddv .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #jxkovzhddv .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jxkovzhddv .gt_group_heading {
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
#> #jxkovzhddv .gt_empty_group_heading {
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
#> #jxkovzhddv .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jxkovzhddv .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jxkovzhddv .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #jxkovzhddv .gt_stub {
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
#> #jxkovzhddv .gt_stub_row_group {
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
#> #jxkovzhddv .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jxkovzhddv .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jxkovzhddv .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jxkovzhddv .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jxkovzhddv .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jxkovzhddv .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jxkovzhddv .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jxkovzhddv .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jxkovzhddv .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jxkovzhddv .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #jxkovzhddv .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jxkovzhddv .gt_footnotes {
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
#> #jxkovzhddv .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jxkovzhddv .gt_sourcenotes {
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
#> #jxkovzhddv .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jxkovzhddv .gt_left {
#>   text-align: left;
#> }
#> 
#> #jxkovzhddv .gt_center {
#>   text-align: center;
#> }
#> 
#> #jxkovzhddv .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jxkovzhddv .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jxkovzhddv .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jxkovzhddv .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jxkovzhddv .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jxkovzhddv .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jxkovzhddv .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jxkovzhddv .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jxkovzhddv .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jxkovzhddv .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jxkovzhddv .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jxkovzhddv .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jxkovzhddv .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jxkovzhddv div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>3 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">lancet</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">15</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00468BFF;color:#00468BFF;padding:0 3px;"> </span><span style="background:#ED0000FF;color:#ED0000FF;padding:0 3px;"> </span><span style="background:#42B540FF;color:#42B540FF;padding:0 3px;"> </span><span style="background:#0099B4FF;color:#0099B4FF;padding:0 3px;"> </span><span style="background:#925E9FFF;color:#925E9FFF;padding:0 3px;"> </span><span style="background:#FDAF91FF;color:#FDAF91FF;padding:0 3px;"> </span><span style="background:#AD002AFF;color:#AD002AFF;padding:0 3px;"> </span><span style="background:#ADB6B6FF;color:#ADB6B6FF;padding:0 3px;"> </span><span style="background:#1B1919FF;color:#1B1919FF;padding:0 3px;"> </span><span style="background:#79AF97FF;color:#79AF97FF;padding:0 3px;"> </span><span style="background:#DF8F44FF;color:#DF8F44FF;padding:0 3px;"> </span><span style="background:#6A6599FF;color:#6A6599FF;padding:0 3px;"> </span><span style="background:#FCCDE5FF;color:#FCCDE5FF;padding:0 3px;"> </span><span style="background:#80B1D3FF;color:#80B1D3FF;padding:0 3px;"> </span><span style="background:#0000FFFF;color:#0000FFFF;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Paired</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#A6CEE3;color:#A6CEE3;padding:0 3px;"> </span><span style="background:#1F78B4;color:#1F78B4;padding:0 3px;"> </span><span style="background:#B2DF8A;color:#B2DF8A;padding:0 3px;"> </span><span style="background:#33A02C;color:#33A02C;padding:0 3px;"> </span><span style="background:#FB9A99;color:#FB9A99;padding:0 3px;"> </span><span style="background:#E31A1C;color:#E31A1C;padding:0 3px;"> </span><span style="background:#FDBF6F;color:#FDBF6F;padding:0 3px;"> </span><span style="background:#FF7F00;color:#FF7F00;padding:0 3px;"> </span><span style="background:#CAB2D6;color:#CAB2D6;padding:0 3px;"> </span><span style="background:#6A3D9A;color:#6A3D9A;padding:0 3px;"> </span><span style="background:#FFFF99;color:#FFFF99;padding:0 3px;"> </span><span style="background:#B15928;color:#B15928;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">viridis</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">256</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#440154FF;color:#440154FF;padding:0 3px;"> </span><span style="background:#440256FF;color:#440256FF;padding:0 3px;"> </span><span style="background:#450457FF;color:#450457FF;padding:0 3px;"> </span><span style="background:#450559FF;color:#450559FF;padding:0 3px;"> </span><span style="background:#46075AFF;color:#46075AFF;padding:0 3px;"> </span><span style="background:#46085CFF;color:#46085CFF;padding:0 3px;"> </span><span style="background:#460A5DFF;color:#460A5DFF;padding:0 3px;"> </span><span style="background:#460B5EFF;color:#460B5EFF;padding:0 3px;"> </span><span style="background:#470D60FF;color:#470D60FF;padding:0 3px;"> </span><span style="background:#470E61FF;color:#470E61FF;padding:0 3px;"> </span><span style="background:#471063FF;color:#471063FF;padding:0 3px;"> </span><span style="background:#471164FF;color:#471164FF;padding:0 3px;"> </span><span style="background:#471365FF;color:#471365FF;padding:0 3px;"> </span><span style="background:#481467FF;color:#481467FF;padding:0 3px;"> </span><span style="background:#481668FF;color:#481668FF;padding:0 3px;"> </span><span style="background:#481769FF;color:#481769FF;padding:0 3px;"> </span><span style="background:#48186AFF;color:#48186AFF;padding:0 3px;"> </span><span style="background:#481A6CFF;color:#481A6CFF;padding:0 3px;"> </span><span style="background:#481B6DFF;color:#481B6DFF;padding:0 3px;"> </span><span style="background:#481C6EFF;color:#481C6EFF;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Filter by pattern
pal_show(pattern = "^nord")
#> <div id="kcpexnevbr" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#kcpexnevbr table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #kcpexnevbr thead, #kcpexnevbr tbody, #kcpexnevbr tfoot, #kcpexnevbr tr, #kcpexnevbr td, #kcpexnevbr th {
#>   border-style: none;
#> }
#> 
#> #kcpexnevbr p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #kcpexnevbr .gt_table {
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
#> #kcpexnevbr .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #kcpexnevbr .gt_title {
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
#> #kcpexnevbr .gt_subtitle {
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
#> #kcpexnevbr .gt_heading {
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
#> #kcpexnevbr .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpexnevbr .gt_col_headings {
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
#> #kcpexnevbr .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #kcpexnevbr .gt_column_spanner_outer {
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
#> #kcpexnevbr .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #kcpexnevbr .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #kcpexnevbr .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #kcpexnevbr .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #kcpexnevbr .gt_group_heading {
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
#> #kcpexnevbr .gt_empty_group_heading {
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
#> #kcpexnevbr .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #kcpexnevbr .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #kcpexnevbr .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #kcpexnevbr .gt_stub {
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
#> #kcpexnevbr .gt_stub_row_group {
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
#> #kcpexnevbr .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #kcpexnevbr .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #kcpexnevbr .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpexnevbr .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #kcpexnevbr .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #kcpexnevbr .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpexnevbr .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpexnevbr .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #kcpexnevbr .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpexnevbr .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #kcpexnevbr .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpexnevbr .gt_footnotes {
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
#> #kcpexnevbr .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpexnevbr .gt_sourcenotes {
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
#> #kcpexnevbr .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpexnevbr .gt_left {
#>   text-align: left;
#> }
#> 
#> #kcpexnevbr .gt_center {
#>   text-align: center;
#> }
#> 
#> #kcpexnevbr .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #kcpexnevbr .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #kcpexnevbr .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #kcpexnevbr .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #kcpexnevbr .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #kcpexnevbr .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #kcpexnevbr .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #kcpexnevbr .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #kcpexnevbr .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #kcpexnevbr .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #kcpexnevbr .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #kcpexnevbr .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #kcpexnevbr .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #kcpexnevbr div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>16 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">nord_polarnight</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">4</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2E3440;color:#2E3440;padding:0 3px;"> </span><span style="background:#3B4252;color:#3B4252;padding:0 3px;"> </span><span style="background:#434C5E;color:#434C5E;padding:0 3px;"> </span><span style="background:#4C566A;color:#4C566A;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_snowstorm</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">3</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#D8DEE9;color:#D8DEE9;padding:0 3px;"> </span><span style="background:#E5E9F0;color:#E5E9F0;padding:0 3px;"> </span><span style="background:#ECEFF4;color:#ECEFF4;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_frost</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">4</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8FBCBB;color:#8FBCBB;padding:0 3px;"> </span><span style="background:#88C0D0;color:#88C0D0;padding:0 3px;"> </span><span style="background:#81A1C1;color:#81A1C1;padding:0 3px;"> </span><span style="background:#5E81AC;color:#5E81AC;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_aurora</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#BF616A;color:#BF616A;padding:0 3px;"> </span><span style="background:#D08770;color:#D08770;padding:0 3px;"> </span><span style="background:#EBCB8B;color:#EBCB8B;padding:0 3px;"> </span><span style="background:#A3BE8C;color:#A3BE8C;padding:0 3px;"> </span><span style="background:#B48EAD;color:#B48EAD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_lumina</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#EDDAEB;color:#EDDAEB;padding:0 3px;"> </span><span style="background:#AD8CAE;color:#AD8CAE;padding:0 3px;"> </span><span style="background:#4F93B8;color:#4F93B8;padding:0 3px;"> </span><span style="background:#306489;color:#306489;padding:0 3px;"> </span><span style="background:#222B4C;color:#222B4C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_mountain_forms</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#184860;color:#184860;padding:0 3px;"> </span><span style="background:#486078;color:#486078;padding:0 3px;"> </span><span style="background:#d8d8d8;color:#d8d8d8;padding:0 3px;"> </span><span style="background:#484860;color:#484860;padding:0 3px;"> </span><span style="background:#181830;color:#181830;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_silver_mine</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4B644B;color:#4B644B;padding:0 3px;"> </span><span style="background:#647D4B;color:#647D4B;padding:0 3px;"> </span><span style="background:#E1E1E1;color:#E1E1E1;padding:0 3px;"> </span><span style="background:#7D96AF;color:#7D96AF;padding:0 3px;"> </span><span style="background:#647D96;color:#647D96;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_lake_superior</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7D4B19;color:#7D4B19;padding:0 3px;"> </span><span style="background:#C89664;color:#C89664;padding:0 3px;"> </span><span style="background:#C87d4B;color:#C87d4B;padding:0 3px;"> </span><span style="background:#4B647D;color:#4B647D;padding:0 3px;"> </span><span style="background:#324B64;color:#324B64;padding:0 3px;"> </span><span style="background:#19324B;color:#19324B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_victory_bonds</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#AF1900;color:#AF1900;padding:0 3px;"> </span><span style="background:#C83200;color:#C83200;padding:0 3px;"> </span><span style="background:#E19600;color:#E19600;padding:0 3px;"> </span><span style="background:#193264;color:#193264;padding:0 3px;"> </span><span style="background:#001964;color:#001964;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_halifax_harbor</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E1C8AF;color:#E1C8AF;padding:0 3px;"> </span><span style="background:#C8AF96;color:#C8AF96;padding:0 3px;"> </span><span style="background:#AF967D;color:#AF967D;padding:0 3px;"> </span><span style="background:#967D7D;color:#967D7D;padding:0 3px;"> </span><span style="background:#644B64;color:#644B64;padding:0 3px;"> </span><span style="background:#4B324b;color:#4B324b;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_moose_pond</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4B3232;color:#4B3232;padding:0 3px;"> </span><span style="background:#7D4B32;color:#7D4B32;padding:0 3px;"> </span><span style="background:#966432;color:#966432;padding:0 3px;"> </span><span style="background:#AF7D32;color:#AF7D32;padding:0 3px;"> </span><span style="background:#E19632;color:#E19632;padding:0 3px;"> </span><span style="background:#E1AF4B;color:#E1AF4B;padding:0 3px;"> </span><span style="background:#C8C896;color:#C8C896;padding:0 3px;"> </span><span style="background:#4B4B4B;color:#4B4B4B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_algoma_forest</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4B4B4B;color:#4B4B4B;padding:0 3px;"> </span><span style="background:#967D4B;color:#967D4B;padding:0 3px;"> </span><span style="background:#AFAF7D;color:#AFAF7D;padding:0 3px;"> </span><span style="background:#C89632;color:#C89632;padding:0 3px;"> </span><span style="background:#647D64;color:#647D64;padding:0 3px;"> </span><span style="background:#96AFAF;color:#96AFAF;padding:0 3px;"> </span><span style="background:#7D96AF;color:#7D96AF;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_rocky_mountain</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#BEBEBE;color:#BEBEBE;padding:0 3px;"> </span><span style="background:#C8C8C8;color:#C8C8C8;padding:0 3px;"> </span><span style="background:#DCD2C8;color:#DCD2C8;padding:0 3px;"> </span><span style="background:#D2C8C8;color:#D2C8C8;padding:0 3px;"> </span><span style="background:#BEBEC8;color:#BEBEC8;padding:0 3px;"> </span><span style="background:#B4B4BE;color:#B4B4BE;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_red_mountain</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7D3232;color:#7D3232;padding:0 3px;"> </span><span style="background:#7D4B4B;color:#7D4B4B;padding:0 3px;"> </span><span style="background:#7D6464;color:#7D6464;padding:0 3px;"> </span><span style="background:#AF967D;color:#AF967D;padding:0 3px;"> </span><span style="background:#FAC87D;color:#FAC87D;padding:0 3px;"> </span><span style="background:#E1AF64;color:#E1AF64;padding:0 3px;"> </span><span style="background:#C8964B;color:#C8964B;padding:0 3px;"> </span><span style="background:#32324B;color:#32324B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_baie_mouton</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#304890;color:#304890;padding:0 3px;"> </span><span style="background:#7890A8;color:#7890A8;padding:0 3px;"> </span><span style="background:#90A8C0;color:#90A8C0;padding:0 3px;"> </span><span style="background:#A8A8A8;color:#A8A8A8;padding:0 3px;"> </span><span style="background:#C0C0A8;color:#C0C0A8;padding:0 3px;"> </span><span style="background:#6A7E4F;color:#6A7E4F;padding:0 3px;"> </span><span style="background:#304848;color:#304848;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_afternoon_prarie</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#486090;color:#486090;padding:0 3px;"> </span><span style="background:#6078A8;color:#6078A8;padding:0 3px;"> </span><span style="background:#7890A8;color:#7890A8;padding:0 3px;"> </span><span style="background:#90A8C0;color:#90A8C0;padding:0 3px;"> </span><span style="background:#F0D8C0;color:#F0D8C0;padding:0 3px;"> </span><span style="background:#D6BBCF;color:#D6BBCF;padding:0 3px;"> </span><span style="background:#A8C0C0;color:#A8C0C0;padding:0 3px;"> </span><span style="background:#C0D8D8;color:#C0D8D8;padding:0 3px;"> </span><span style="background:#A8A890;color:#A8A890;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "ggsci")
#> <div id="taqabhpcem" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#taqabhpcem table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #taqabhpcem thead, #taqabhpcem tbody, #taqabhpcem tfoot, #taqabhpcem tr, #taqabhpcem td, #taqabhpcem th {
#>   border-style: none;
#> }
#> 
#> #taqabhpcem p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #taqabhpcem .gt_table {
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
#> #taqabhpcem .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #taqabhpcem .gt_title {
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
#> #taqabhpcem .gt_subtitle {
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
#> #taqabhpcem .gt_heading {
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
#> #taqabhpcem .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #taqabhpcem .gt_col_headings {
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
#> #taqabhpcem .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #taqabhpcem .gt_column_spanner_outer {
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
#> #taqabhpcem .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #taqabhpcem .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #taqabhpcem .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #taqabhpcem .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #taqabhpcem .gt_group_heading {
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
#> #taqabhpcem .gt_empty_group_heading {
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
#> #taqabhpcem .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #taqabhpcem .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #taqabhpcem .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #taqabhpcem .gt_stub {
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
#> #taqabhpcem .gt_stub_row_group {
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
#> #taqabhpcem .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #taqabhpcem .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #taqabhpcem .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #taqabhpcem .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #taqabhpcem .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #taqabhpcem .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #taqabhpcem .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #taqabhpcem .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #taqabhpcem .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #taqabhpcem .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #taqabhpcem .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #taqabhpcem .gt_footnotes {
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
#> #taqabhpcem .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #taqabhpcem .gt_sourcenotes {
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
#> #taqabhpcem .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #taqabhpcem .gt_left {
#>   text-align: left;
#> }
#> 
#> #taqabhpcem .gt_center {
#>   text-align: center;
#> }
#> 
#> #taqabhpcem .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #taqabhpcem .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #taqabhpcem .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #taqabhpcem .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #taqabhpcem .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #taqabhpcem .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #taqabhpcem .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #taqabhpcem .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #taqabhpcem .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #taqabhpcem .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #taqabhpcem .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #taqabhpcem .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #taqabhpcem .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #taqabhpcem div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>86 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_npg_nrc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E64B35;color:#E64B35;padding:0 3px;"> </span><span style="background:#4DBBD5;color:#4DBBD5;padding:0 3px;"> </span><span style="background:#00A087;color:#00A087;padding:0 3px;"> </span><span style="background:#3C5488;color:#3C5488;padding:0 3px;"> </span><span style="background:#F39B7F;color:#F39B7F;padding:0 3px;"> </span><span style="background:#8491B4;color:#8491B4;padding:0 3px;"> </span><span style="background:#91D1C2;color:#91D1C2;padding:0 3px;"> </span><span style="background:#DC0000;color:#DC0000;padding:0 3px;"> </span><span style="background:#7E6148;color:#7E6148;padding:0 3px;"> </span><span style="background:#B09C85;color:#B09C85;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_aaas_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#3B4992;color:#3B4992;padding:0 3px;"> </span><span style="background:#EE0000;color:#EE0000;padding:0 3px;"> </span><span style="background:#008B45;color:#008B45;padding:0 3px;"> </span><span style="background:#631879;color:#631879;padding:0 3px;"> </span><span style="background:#008280;color:#008280;padding:0 3px;"> </span><span style="background:#BB0021;color:#BB0021;padding:0 3px;"> </span><span style="background:#5F559B;color:#5F559B;padding:0 3px;"> </span><span style="background:#A20056;color:#A20056;padding:0 3px;"> </span><span style="background:#808180;color:#808180;padding:0 3px;"> </span><span style="background:#1B1919;color:#1B1919;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_nejm_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#BC3C29;color:#BC3C29;padding:0 3px;"> </span><span style="background:#0072B5;color:#0072B5;padding:0 3px;"> </span><span style="background:#E18727;color:#E18727;padding:0 3px;"> </span><span style="background:#20854E;color:#20854E;padding:0 3px;"> </span><span style="background:#7876B1;color:#7876B1;padding:0 3px;"> </span><span style="background:#6F99AD;color:#6F99AD;padding:0 3px;"> </span><span style="background:#FFDC91;color:#FFDC91;padding:0 3px;"> </span><span style="background:#EE4C97;color:#EE4C97;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_lancet_lanonc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00468B;color:#00468B;padding:0 3px;"> </span><span style="background:#ED0000;color:#ED0000;padding:0 3px;"> </span><span style="background:#42B540;color:#42B540;padding:0 3px;"> </span><span style="background:#0099B4;color:#0099B4;padding:0 3px;"> </span><span style="background:#925E9F;color:#925E9F;padding:0 3px;"> </span><span style="background:#FDAF91;color:#FDAF91;padding:0 3px;"> </span><span style="background:#AD002A;color:#AD002A;padding:0 3px;"> </span><span style="background:#ADB6B6;color:#ADB6B6;padding:0 3px;"> </span><span style="background:#1B1919;color:#1B1919;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_jama_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#374E55;color:#374E55;padding:0 3px;"> </span><span style="background:#DF8F44;color:#DF8F44;padding:0 3px;"> </span><span style="background:#00A1D5;color:#00A1D5;padding:0 3px;"> </span><span style="background:#B24745;color:#B24745;padding:0 3px;"> </span><span style="background:#79AF97;color:#79AF97;padding:0 3px;"> </span><span style="background:#6A6599;color:#6A6599;padding:0 3px;"> </span><span style="background:#80796B;color:#80796B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bmj_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2A6EBB;color:#2A6EBB;padding:0 3px;"> </span><span style="background:#F0AB00;color:#F0AB00;padding:0 3px;"> </span><span style="background:#C50084;color:#C50084;padding:0 3px;"> </span><span style="background:#7D5CC6;color:#7D5CC6;padding:0 3px;"> </span><span style="background:#E37222;color:#E37222;padding:0 3px;"> </span><span style="background:#69BE28;color:#69BE28;padding:0 3px;"> </span><span style="background:#00B2A9;color:#00B2A9;padding:0 3px;"> </span><span style="background:#CD202C;color:#CD202C;padding:0 3px;"> </span><span style="background:#747678;color:#747678;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_jco_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0073C2;color:#0073C2;padding:0 3px;"> </span><span style="background:#EFC000;color:#EFC000;padding:0 3px;"> </span><span style="background:#868686;color:#868686;padding:0 3px;"> </span><span style="background:#CD534C;color:#CD534C;padding:0 3px;"> </span><span style="background:#7AA6DC;color:#7AA6DC;padding:0 3px;"> </span><span style="background:#003C67;color:#003C67;padding:0 3px;"> </span><span style="background:#8F7700;color:#8F7700;padding:0 3px;"> </span><span style="background:#3B3B3B;color:#3B3B3B;padding:0 3px;"> </span><span style="background:#A73030;color:#A73030;padding:0 3px;"> </span><span style="background:#4A6990;color:#4A6990;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_ucscgb_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">26</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF0000;color:#FF0000;padding:0 3px;"> </span><span style="background:#FF9900;color:#FF9900;padding:0 3px;"> </span><span style="background:#FFCC00;color:#FFCC00;padding:0 3px;"> </span><span style="background:#00FF00;color:#00FF00;padding:0 3px;"> </span><span style="background:#6699FF;color:#6699FF;padding:0 3px;"> </span><span style="background:#CC33FF;color:#CC33FF;padding:0 3px;"> </span><span style="background:#99991E;color:#99991E;padding:0 3px;"> </span><span style="background:#999999;color:#999999;padding:0 3px;"> </span><span style="background:#FF00CC;color:#FF00CC;padding:0 3px;"> </span><span style="background:#CC0000;color:#CC0000;padding:0 3px;"> </span><span style="background:#FFCCCC;color:#FFCCCC;padding:0 3px;"> </span><span style="background:#FFFF00;color:#FFFF00;padding:0 3px;"> </span><span style="background:#CCFF00;color:#CCFF00;padding:0 3px;"> </span><span style="background:#358000;color:#358000;padding:0 3px;"> </span><span style="background:#0000CC;color:#0000CC;padding:0 3px;"> </span><span style="background:#99CCFF;color:#99CCFF;padding:0 3px;"> </span><span style="background:#00FFFF;color:#00FFFF;padding:0 3px;"> </span><span style="background:#CCFFFF;color:#CCFFFF;padding:0 3px;"> </span><span style="background:#9900CC;color:#9900CC;padding:0 3px;"> </span><span style="background:#CC99FF;color:#CC99FF;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category10</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1F77B4;color:#1F77B4;padding:0 3px;"> </span><span style="background:#FF7F0E;color:#FF7F0E;padding:0 3px;"> </span><span style="background:#2CA02C;color:#2CA02C;padding:0 3px;"> </span><span style="background:#D62728;color:#D62728;padding:0 3px;"> </span><span style="background:#9467BD;color:#9467BD;padding:0 3px;"> </span><span style="background:#8C564B;color:#8C564B;padding:0 3px;"> </span><span style="background:#E377C2;color:#E377C2;padding:0 3px;"> </span><span style="background:#7F7F7F;color:#7F7F7F;padding:0 3px;"> </span><span style="background:#BCBD22;color:#BCBD22;padding:0 3px;"> </span><span style="background:#17BECF;color:#17BECF;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category20</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1F77B4;color:#1F77B4;padding:0 3px;"> </span><span style="background:#FF7F0E;color:#FF7F0E;padding:0 3px;"> </span><span style="background:#2CA02C;color:#2CA02C;padding:0 3px;"> </span><span style="background:#D62728;color:#D62728;padding:0 3px;"> </span><span style="background:#9467BD;color:#9467BD;padding:0 3px;"> </span><span style="background:#8C564B;color:#8C564B;padding:0 3px;"> </span><span style="background:#E377C2;color:#E377C2;padding:0 3px;"> </span><span style="background:#7F7F7F;color:#7F7F7F;padding:0 3px;"> </span><span style="background:#BCBD22;color:#BCBD22;padding:0 3px;"> </span><span style="background:#17BECF;color:#17BECF;padding:0 3px;"> </span><span style="background:#AEC7E8;color:#AEC7E8;padding:0 3px;"> </span><span style="background:#FFBB78;color:#FFBB78;padding:0 3px;"> </span><span style="background:#98DF8A;color:#98DF8A;padding:0 3px;"> </span><span style="background:#FF9896;color:#FF9896;padding:0 3px;"> </span><span style="background:#C5B0D5;color:#C5B0D5;padding:0 3px;"> </span><span style="background:#C49C94;color:#C49C94;padding:0 3px;"> </span><span style="background:#F7B6D2;color:#F7B6D2;padding:0 3px;"> </span><span style="background:#C7C7C7;color:#C7C7C7;padding:0 3px;"> </span><span style="background:#DBDB8D;color:#DBDB8D;padding:0 3px;"> </span><span style="background:#9EDAE5;color:#9EDAE5;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category20b</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#393B79;color:#393B79;padding:0 3px;"> </span><span style="background:#637939;color:#637939;padding:0 3px;"> </span><span style="background:#8C6D31;color:#8C6D31;padding:0 3px;"> </span><span style="background:#843C39;color:#843C39;padding:0 3px;"> </span><span style="background:#7B4173;color:#7B4173;padding:0 3px;"> </span><span style="background:#5254A3;color:#5254A3;padding:0 3px;"> </span><span style="background:#8CA252;color:#8CA252;padding:0 3px;"> </span><span style="background:#BD9E39;color:#BD9E39;padding:0 3px;"> </span><span style="background:#AD494A;color:#AD494A;padding:0 3px;"> </span><span style="background:#A55194;color:#A55194;padding:0 3px;"> </span><span style="background:#6B6ECF;color:#6B6ECF;padding:0 3px;"> </span><span style="background:#B5CF6B;color:#B5CF6B;padding:0 3px;"> </span><span style="background:#E7BA52;color:#E7BA52;padding:0 3px;"> </span><span style="background:#D6616B;color:#D6616B;padding:0 3px;"> </span><span style="background:#CE6DBD;color:#CE6DBD;padding:0 3px;"> </span><span style="background:#9C9EDE;color:#9C9EDE;padding:0 3px;"> </span><span style="background:#CEDB9C;color:#CEDB9C;padding:0 3px;"> </span><span style="background:#E7CB94;color:#E7CB94;padding:0 3px;"> </span><span style="background:#E7969C;color:#E7969C;padding:0 3px;"> </span><span style="background:#DE9ED6;color:#DE9ED6;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category20c</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#3182BD;color:#3182BD;padding:0 3px;"> </span><span style="background:#E6550D;color:#E6550D;padding:0 3px;"> </span><span style="background:#31A354;color:#31A354;padding:0 3px;"> </span><span style="background:#756BB1;color:#756BB1;padding:0 3px;"> </span><span style="background:#636363;color:#636363;padding:0 3px;"> </span><span style="background:#6BAED6;color:#6BAED6;padding:0 3px;"> </span><span style="background:#FD8D3C;color:#FD8D3C;padding:0 3px;"> </span><span style="background:#74C476;color:#74C476;padding:0 3px;"> </span><span style="background:#9E9AC8;color:#9E9AC8;padding:0 3px;"> </span><span style="background:#969696;color:#969696;padding:0 3px;"> </span><span style="background:#9ECAE1;color:#9ECAE1;padding:0 3px;"> </span><span style="background:#FDAE6B;color:#FDAE6B;padding:0 3px;"> </span><span style="background:#A1D99B;color:#A1D99B;padding:0 3px;"> </span><span style="background:#BCBDDC;color:#BCBDDC;padding:0 3px;"> </span><span style="background:#BDBDBD;color:#BDBDBD;padding:0 3px;"> </span><span style="background:#C6DBEF;color:#C6DBEF;padding:0 3px;"> </span><span style="background:#FDD0A2;color:#FDD0A2;padding:0 3px;"> </span><span style="background:#C7E9C0;color:#C7E9C0;padding:0 3px;"> </span><span style="background:#DADAEB;color:#DADAEB;padding:0 3px;"> </span><span style="background:#D9D9D9;color:#D9D9D9;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_observable_observable10</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4269D0;color:#4269D0;padding:0 3px;"> </span><span style="background:#EFB118;color:#EFB118;padding:0 3px;"> </span><span style="background:#FF725C;color:#FF725C;padding:0 3px;"> </span><span style="background:#6CC5B0;color:#6CC5B0;padding:0 3px;"> </span><span style="background:#3CA951;color:#3CA951;padding:0 3px;"> </span><span style="background:#FF8AB7;color:#FF8AB7;padding:0 3px;"> </span><span style="background:#A463F2;color:#A463F2;padding:0 3px;"> </span><span style="background:#97BBF5;color:#97BBF5;padding:0 3px;"> </span><span style="background:#9C6B4E;color:#9C6B4E;padding:0 3px;"> </span><span style="background:#9498A0;color:#9498A0;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_primer_mark17</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#006EDB;color:#006EDB;padding:0 3px;"> </span><span style="background:#EB670F;color:#EB670F;padding:0 3px;"> </span><span style="background:#DF0C24;color:#DF0C24;padding:0 3px;"> </span><span style="background:#179B9B;color:#179B9B;padding:0 3px;"> </span><span style="background:#30A147;color:#30A147;padding:0 3px;"> </span><span style="background:#894CEB;color:#894CEB;padding:0 3px;"> </span><span style="background:#B88700;color:#B88700;padding:0 3px;"> </span><span style="background:#CE2C85;color:#CE2C85;padding:0 3px;"> </span><span style="background:#856D4C;color:#856D4C;padding:0 3px;"> </span><span style="background:#527A29;color:#527A29;padding:0 3px;"> </span><span style="background:#D43511;color:#D43511;padding:0 3px;"> </span><span style="background:#167E53;color:#167E53;padding:0 3px;"> </span><span style="background:#9D615C;color:#9D615C;padding:0 3px;"> </span><span style="background:#64762D;color:#64762D;padding:0 3px;"> </span><span style="background:#A830E8;color:#A830E8;padding:0 3px;"> </span><span style="background:#866E04;color:#866E04;padding:0 3px;"> </span><span style="background:#808FA3;color:#808FA3;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_atlassian_categorical8</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4688EC;color:#4688EC;padding:0 3px;"> </span><span style="background:#94C748;color:#94C748;padding:0 3px;"> </span><span style="background:#C97CF4;color:#C97CF4;padding:0 3px;"> </span><span style="background:#FCA700;color:#FCA700;padding:0 3px;"> </span><span style="background:#1558BC;color:#1558BC;padding:0 3px;"> </span><span style="background:#964AC0;color:#964AC0;padding:0 3px;"> </span><span style="background:#42B2D7;color:#42B2D7;padding:0 3px;"> </span><span style="background:#E06C00;color:#E06C00;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_igv_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">51</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#5050FF;color:#5050FF;padding:0 3px;"> </span><span style="background:#CE3D32;color:#CE3D32;padding:0 3px;"> </span><span style="background:#749B58;color:#749B58;padding:0 3px;"> </span><span style="background:#F0E685;color:#F0E685;padding:0 3px;"> </span><span style="background:#466983;color:#466983;padding:0 3px;"> </span><span style="background:#BA6338;color:#BA6338;padding:0 3px;"> </span><span style="background:#5DB1DD;color:#5DB1DD;padding:0 3px;"> </span><span style="background:#802268;color:#802268;padding:0 3px;"> </span><span style="background:#6BD76B;color:#6BD76B;padding:0 3px;"> </span><span style="background:#D595A7;color:#D595A7;padding:0 3px;"> </span><span style="background:#924822;color:#924822;padding:0 3px;"> </span><span style="background:#837B8D;color:#837B8D;padding:0 3px;"> </span><span style="background:#C75127;color:#C75127;padding:0 3px;"> </span><span style="background:#D58F5C;color:#D58F5C;padding:0 3px;"> </span><span style="background:#7A65A5;color:#7A65A5;padding:0 3px;"> </span><span style="background:#E4AF69;color:#E4AF69;padding:0 3px;"> </span><span style="background:#3B1B53;color:#3B1B53;padding:0 3px;"> </span><span style="background:#CDDEB7;color:#CDDEB7;padding:0 3px;"> </span><span style="background:#612A79;color:#612A79;padding:0 3px;"> </span><span style="background:#AE1F63;color:#AE1F63;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_igv_alternating</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">2</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#5773CC;color:#5773CC;padding:0 3px;"> </span><span style="background:#FFB900;color:#FFB900;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_locuszoom_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#D43F3A;color:#D43F3A;padding:0 3px;"> </span><span style="background:#EEA236;color:#EEA236;padding:0 3px;"> </span><span style="background:#5CB85C;color:#5CB85C;padding:0 3px;"> </span><span style="background:#46B8DA;color:#46B8DA;padding:0 3px;"> </span><span style="background:#357EBD;color:#357EBD;padding:0 3px;"> </span><span style="background:#9632B8;color:#9632B8;padding:0 3px;"> </span><span style="background:#B8B8B8;color:#B8B8B8;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_uchicago_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#800000;color:#800000;padding:0 3px;"> </span><span style="background:#767676;color:#767676;padding:0 3px;"> </span><span style="background:#FFA319;color:#FFA319;padding:0 3px;"> </span><span style="background:#8A9045;color:#8A9045;padding:0 3px;"> </span><span style="background:#155F83;color:#155F83;padding:0 3px;"> </span><span style="background:#C16622;color:#C16622;padding:0 3px;"> </span><span style="background:#8F3931;color:#8F3931;padding:0 3px;"> </span><span style="background:#58593F;color:#58593F;padding:0 3px;"> </span><span style="background:#350E20;color:#350E20;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_uchicago_light</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#800000;color:#800000;padding:0 3px;"> </span><span style="background:#D6D6CE;color:#D6D6CE;padding:0 3px;"> </span><span style="background:#FFB547;color:#FFB547;padding:0 3px;"> </span><span style="background:#ADB17D;color:#ADB17D;padding:0 3px;"> </span><span style="background:#5B8FA8;color:#5B8FA8;padding:0 3px;"> </span><span style="background:#D49464;color:#D49464;padding:0 3px;"> </span><span style="background:#B1746F;color:#B1746F;padding:0 3px;"> </span><span style="background:#8A8B79;color:#8A8B79;padding:0 3px;"> </span><span style="background:#725663;color:#725663;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_uchicago_dark</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#800000;color:#800000;padding:0 3px;"> </span><span style="background:#767676;color:#767676;padding:0 3px;"> </span><span style="background:#CC8214;color:#CC8214;padding:0 3px;"> </span><span style="background:#616530;color:#616530;padding:0 3px;"> </span><span style="background:#0F425C;color:#0F425C;padding:0 3px;"> </span><span style="background:#9A5324;color:#9A5324;padding:0 3px;"> </span><span style="background:#642822;color:#642822;padding:0 3px;"> </span><span style="background:#3E3E23;color:#3E3E23;padding:0 3px;"> </span><span style="background:#350E20;color:#350E20;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_cosmic_hallmarks_dark</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#171717;color:#171717;padding:0 3px;"> </span><span style="background:#7D0226;color:#7D0226;padding:0 3px;"> </span><span style="background:#300049;color:#300049;padding:0 3px;"> </span><span style="background:#165459;color:#165459;padding:0 3px;"> </span><span style="background:#3F2327;color:#3F2327;padding:0 3px;"> </span><span style="background:#0B1948;color:#0B1948;padding:0 3px;"> </span><span style="background:#E71012;color:#E71012;padding:0 3px;"> </span><span style="background:#555555;color:#555555;padding:0 3px;"> </span><span style="background:#193006;color:#193006;padding:0 3px;"> </span><span style="background:#A8450C;color:#A8450C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_cosmic_hallmarks_light</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2E2A2B;color:#2E2A2B;padding:0 3px;"> </span><span style="background:#CF4E9C;color:#CF4E9C;padding:0 3px;"> </span><span style="background:#8C57A2;color:#8C57A2;padding:0 3px;"> </span><span style="background:#358DB9;color:#358DB9;padding:0 3px;"> </span><span style="background:#82581F;color:#82581F;padding:0 3px;"> </span><span style="background:#2F509E;color:#2F509E;padding:0 3px;"> </span><span style="background:#E5614C;color:#E5614C;padding:0 3px;"> </span><span style="background:#97A1A7;color:#97A1A7;padding:0 3px;"> </span><span style="background:#3DA873;color:#3DA873;padding:0 3px;"> </span><span style="background:#DC9445;color:#DC9445;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_cosmic_signature_substitutions</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#5ABCEB;color:#5ABCEB;padding:0 3px;"> </span><span style="background:#050708;color:#050708;padding:0 3px;"> </span><span style="background:#D33C32;color:#D33C32;padding:0 3px;"> </span><span style="background:#CBCACB;color:#CBCACB;padding:0 3px;"> </span><span style="background:#ABCD72;color:#ABCD72;padding:0 3px;"> </span><span style="background:#E7C9C6;color:#E7C9C6;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_simpsons_springfield</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">16</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FED439;color:#FED439;padding:0 3px;"> </span><span style="background:#709AE1;color:#709AE1;padding:0 3px;"> </span><span style="background:#8A9197;color:#8A9197;padding:0 3px;"> </span><span style="background:#D2AF81;color:#D2AF81;padding:0 3px;"> </span><span style="background:#FD7446;color:#FD7446;padding:0 3px;"> </span><span style="background:#D5E4A2;color:#D5E4A2;padding:0 3px;"> </span><span style="background:#197EC0;color:#197EC0;padding:0 3px;"> </span><span style="background:#F05C3B;color:#F05C3B;padding:0 3px;"> </span><span style="background:#46732E;color:#46732E;padding:0 3px;"> </span><span style="background:#71D0F5;color:#71D0F5;padding:0 3px;"> </span><span style="background:#370335;color:#370335;padding:0 3px;"> </span><span style="background:#075149;color:#075149;padding:0 3px;"> </span><span style="background:#C80813;color:#C80813;padding:0 3px;"> </span><span style="background:#91331F;color:#91331F;padding:0 3px;"> </span><span style="background:#1A9993;color:#1A9993;padding:0 3px;"> </span><span style="background:#FD8CC1;color:#FD8CC1;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_futurama_planetexpress</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF6F00;color:#FF6F00;padding:0 3px;"> </span><span style="background:#C71000;color:#C71000;padding:0 3px;"> </span><span style="background:#008EA0;color:#008EA0;padding:0 3px;"> </span><span style="background:#8A4198;color:#8A4198;padding:0 3px;"> </span><span style="background:#5A9599;color:#5A9599;padding:0 3px;"> </span><span style="background:#FF6348;color:#FF6348;padding:0 3px;"> </span><span style="background:#84D7E1;color:#84D7E1;padding:0 3px;"> </span><span style="background:#FF95A8;color:#FF95A8;padding:0 3px;"> </span><span style="background:#3D3B25;color:#3D3B25;padding:0 3px;"> </span><span style="background:#ADE2D0;color:#ADE2D0;padding:0 3px;"> </span><span style="background:#1A5354;color:#1A5354;padding:0 3px;"> </span><span style="background:#3F4041;color:#3F4041;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_rickandmorty_schwifty</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FAFD7C;color:#FAFD7C;padding:0 3px;"> </span><span style="background:#82491E;color:#82491E;padding:0 3px;"> </span><span style="background:#24325F;color:#24325F;padding:0 3px;"> </span><span style="background:#B7E4F9;color:#B7E4F9;padding:0 3px;"> </span><span style="background:#FB6467;color:#FB6467;padding:0 3px;"> </span><span style="background:#526E2D;color:#526E2D;padding:0 3px;"> </span><span style="background:#E762D7;color:#E762D7;padding:0 3px;"> </span><span style="background:#E89242;color:#E89242;padding:0 3px;"> </span><span style="background:#FAE48B;color:#FAE48B;padding:0 3px;"> </span><span style="background:#A6EEE6;color:#A6EEE6;padding:0 3px;"> </span><span style="background:#917C5D;color:#917C5D;padding:0 3px;"> </span><span style="background:#69C8EC;color:#69C8EC;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_startrek_uniform</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#CC0C00;color:#CC0C00;padding:0 3px;"> </span><span style="background:#5C88DA;color:#5C88DA;padding:0 3px;"> </span><span style="background:#84BD00;color:#84BD00;padding:0 3px;"> </span><span style="background:#FFCD00;color:#FFCD00;padding:0 3px;"> </span><span style="background:#7C878E;color:#7C878E;padding:0 3px;"> </span><span style="background:#00B5E2;color:#00B5E2;padding:0 3px;"> </span><span style="background:#00AF66;color:#00AF66;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tron_legacy</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF410D;color:#FF410D;padding:0 3px;"> </span><span style="background:#6EE2FF;color:#6EE2FF;padding:0 3px;"> </span><span style="background:#F7C530;color:#F7C530;padding:0 3px;"> </span><span style="background:#95CC5E;color:#95CC5E;padding:0 3px;"> </span><span style="background:#D0DFE6;color:#D0DFE6;padding:0 3px;"> </span><span style="background:#F79D1E;color:#F79D1E;padding:0 3px;"> </span><span style="background:#748AA6;color:#748AA6;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_frontiers_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#D51317;color:#D51317;padding:0 3px;"> </span><span style="background:#F39200;color:#F39200;padding:0 3px;"> </span><span style="background:#EFD500;color:#EFD500;padding:0 3px;"> </span><span style="background:#95C11F;color:#95C11F;padding:0 3px;"> </span><span style="background:#007B3D;color:#007B3D;padding:0 3px;"> </span><span style="background:#31B7BC;color:#31B7BC;padding:0 3px;"> </span><span style="background:#0094CD;color:#0094CD;padding:0 3px;"> </span><span style="background:#164194;color:#164194;padding:0 3px;"> </span><span style="background:#6F286A;color:#6F286A;padding:0 3px;"> </span><span style="background:#706F6F;color:#706F6F;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_flatui_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#c0392b;color:#c0392b;padding:0 3px;"> </span><span style="background:#d35400;color:#d35400;padding:0 3px;"> </span><span style="background:#f39c12;color:#f39c12;padding:0 3px;"> </span><span style="background:#27ae60;color:#27ae60;padding:0 3px;"> </span><span style="background:#16a085;color:#16a085;padding:0 3px;"> </span><span style="background:#2980b9;color:#2980b9;padding:0 3px;"> </span><span style="background:#8e44ad;color:#8e44ad;padding:0 3px;"> </span><span style="background:#2c3e50;color:#2c3e50;padding:0 3px;"> </span><span style="background:#7f8c8d;color:#7f8c8d;padding:0 3px;"> </span><span style="background:#bdc3c7;color:#bdc3c7;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_flatui_flattastic</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#DA4453;color:#DA4453;padding:0 3px;"> </span><span style="background:#E95546;color:#E95546;padding:0 3px;"> </span><span style="background:#F6BA59;color:#F6BA59;padding:0 3px;"> </span><span style="background:#8BC163;color:#8BC163;padding:0 3px;"> </span><span style="background:#34BC9D;color:#34BC9D;padding:0 3px;"> </span><span style="background:#3BB0D6;color:#3BB0D6;padding:0 3px;"> </span><span style="background:#4B8AD6;color:#4B8AD6;padding:0 3px;"> </span><span style="background:#977BD5;color:#977BD5;padding:0 3px;"> </span><span style="background:#D870A9;color:#D870A9;padding:0 3px;"> </span><span style="background:#E6E9ED;color:#E6E9ED;padding:0 3px;"> </span><span style="background:#AAB2BC;color:#AAB2BC;padding:0 3px;"> </span><span style="background:#434A53;color:#434A53;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_flatui_aussie</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F9CA24;color:#F9CA24;padding:0 3px;"> </span><span style="background:#F0932B;color:#F0932B;padding:0 3px;"> </span><span style="background:#EB4D4B;color:#EB4D4B;padding:0 3px;"> </span><span style="background:#6AB04C;color:#6AB04C;padding:0 3px;"> </span><span style="background:#C7ECEE;color:#C7ECEE;padding:0 3px;"> </span><span style="background:#22A6B3;color:#22A6B3;padding:0 3px;"> </span><span style="background:#BE2EDD;color:#BE2EDD;padding:0 3px;"> </span><span style="background:#4834D4;color:#4834D4;padding:0 3px;"> </span><span style="background:#130F40;color:#130F40;padding:0 3px;"> </span><span style="background:#535C68;color:#535C68;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_gsea_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4500AD;color:#4500AD;padding:0 3px;"> </span><span style="background:#2700D1;color:#2700D1;padding:0 3px;"> </span><span style="background:#6B58EF;color:#6B58EF;padding:0 3px;"> </span><span style="background:#8888FF;color:#8888FF;padding:0 3px;"> </span><span style="background:#C7C1FF;color:#C7C1FF;padding:0 3px;"> </span><span style="background:#D5D5FF;color:#D5D5FF;padding:0 3px;"> </span><span style="background:#FFC0E5;color:#FFC0E5;padding:0 3px;"> </span><span style="background:#FF8989;color:#FF8989;padding:0 3px;"> </span><span style="background:#FF7080;color:#FF7080;padding:0 3px;"> </span><span style="background:#FF5A5A;color:#FF5A5A;padding:0 3px;"> </span><span style="background:#EF4040;color:#EF4040;padding:0 3px;"> </span><span style="background:#D60C00;color:#D60C00;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#cfe2ff;color:#cfe2ff;padding:0 3px;"> </span><span style="background:#9ec5fe;color:#9ec5fe;padding:0 3px;"> </span><span style="background:#6ea8fe;color:#6ea8fe;padding:0 3px;"> </span><span style="background:#3d8bfd;color:#3d8bfd;padding:0 3px;"> </span><span style="background:#0d6efd;color:#0d6efd;padding:0 3px;"> </span><span style="background:#0a58ca;color:#0a58ca;padding:0 3px;"> </span><span style="background:#084298;color:#084298;padding:0 3px;"> </span><span style="background:#052c65;color:#052c65;padding:0 3px;"> </span><span style="background:#031633;color:#031633;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_indigo</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#e0cffc;color:#e0cffc;padding:0 3px;"> </span><span style="background:#c29ffa;color:#c29ffa;padding:0 3px;"> </span><span style="background:#a370f7;color:#a370f7;padding:0 3px;"> </span><span style="background:#8540f5;color:#8540f5;padding:0 3px;"> </span><span style="background:#6610f2;color:#6610f2;padding:0 3px;"> </span><span style="background:#520dc2;color:#520dc2;padding:0 3px;"> </span><span style="background:#3d0a91;color:#3d0a91;padding:0 3px;"> </span><span style="background:#290661;color:#290661;padding:0 3px;"> </span><span style="background:#140330;color:#140330;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#e2d9f3;color:#e2d9f3;padding:0 3px;"> </span><span style="background:#c5b3e6;color:#c5b3e6;padding:0 3px;"> </span><span style="background:#a98eda;color:#a98eda;padding:0 3px;"> </span><span style="background:#8c68cd;color:#8c68cd;padding:0 3px;"> </span><span style="background:#6f42c1;color:#6f42c1;padding:0 3px;"> </span><span style="background:#59359a;color:#59359a;padding:0 3px;"> </span><span style="background:#432874;color:#432874;padding:0 3px;"> </span><span style="background:#2c1a4d;color:#2c1a4d;padding:0 3px;"> </span><span style="background:#160d27;color:#160d27;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_pink</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f7d6e6;color:#f7d6e6;padding:0 3px;"> </span><span style="background:#efadce;color:#efadce;padding:0 3px;"> </span><span style="background:#e685b5;color:#e685b5;padding:0 3px;"> </span><span style="background:#de5c9d;color:#de5c9d;padding:0 3px;"> </span><span style="background:#d63384;color:#d63384;padding:0 3px;"> </span><span style="background:#ab296a;color:#ab296a;padding:0 3px;"> </span><span style="background:#801f4f;color:#801f4f;padding:0 3px;"> </span><span style="background:#561435;color:#561435;padding:0 3px;"> </span><span style="background:#2b0a1a;color:#2b0a1a;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_red</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f8d7da;color:#f8d7da;padding:0 3px;"> </span><span style="background:#f1aeb5;color:#f1aeb5;padding:0 3px;"> </span><span style="background:#ea868f;color:#ea868f;padding:0 3px;"> </span><span style="background:#e35d6a;color:#e35d6a;padding:0 3px;"> </span><span style="background:#dc3545;color:#dc3545;padding:0 3px;"> </span><span style="background:#b02a37;color:#b02a37;padding:0 3px;"> </span><span style="background:#842029;color:#842029;padding:0 3px;"> </span><span style="background:#58151c;color:#58151c;padding:0 3px;"> </span><span style="background:#2c0b0e;color:#2c0b0e;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#ffe5d0;color:#ffe5d0;padding:0 3px;"> </span><span style="background:#fecba1;color:#fecba1;padding:0 3px;"> </span><span style="background:#feb272;color:#feb272;padding:0 3px;"> </span><span style="background:#fd9843;color:#fd9843;padding:0 3px;"> </span><span style="background:#fd7e14;color:#fd7e14;padding:0 3px;"> </span><span style="background:#ca6510;color:#ca6510;padding:0 3px;"> </span><span style="background:#984c0c;color:#984c0c;padding:0 3px;"> </span><span style="background:#653208;color:#653208;padding:0 3px;"> </span><span style="background:#331904;color:#331904;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_yellow</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fff3cd;color:#fff3cd;padding:0 3px;"> </span><span style="background:#ffe69c;color:#ffe69c;padding:0 3px;"> </span><span style="background:#ffda6a;color:#ffda6a;padding:0 3px;"> </span><span style="background:#ffcd39;color:#ffcd39;padding:0 3px;"> </span><span style="background:#ffc107;color:#ffc107;padding:0 3px;"> </span><span style="background:#cc9a06;color:#cc9a06;padding:0 3px;"> </span><span style="background:#997404;color:#997404;padding:0 3px;"> </span><span style="background:#664d03;color:#664d03;padding:0 3px;"> </span><span style="background:#332701;color:#332701;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#d1e7dd;color:#d1e7dd;padding:0 3px;"> </span><span style="background:#a3cfbb;color:#a3cfbb;padding:0 3px;"> </span><span style="background:#75b798;color:#75b798;padding:0 3px;"> </span><span style="background:#479f76;color:#479f76;padding:0 3px;"> </span><span style="background:#198754;color:#198754;padding:0 3px;"> </span><span style="background:#146c43;color:#146c43;padding:0 3px;"> </span><span style="background:#0f5132;color:#0f5132;padding:0 3px;"> </span><span style="background:#0a3622;color:#0a3622;padding:0 3px;"> </span><span style="background:#051b11;color:#051b11;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_teal</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#d2f4ea;color:#d2f4ea;padding:0 3px;"> </span><span style="background:#a6e9d5;color:#a6e9d5;padding:0 3px;"> </span><span style="background:#79dfc1;color:#79dfc1;padding:0 3px;"> </span><span style="background:#4dd4ac;color:#4dd4ac;padding:0 3px;"> </span><span style="background:#20c997;color:#20c997;padding:0 3px;"> </span><span style="background:#1aa179;color:#1aa179;padding:0 3px;"> </span><span style="background:#13795b;color:#13795b;padding:0 3px;"> </span><span style="background:#0d503c;color:#0d503c;padding:0 3px;"> </span><span style="background:#06281e;color:#06281e;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_cyan</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#cff4fc;color:#cff4fc;padding:0 3px;"> </span><span style="background:#9eeaf9;color:#9eeaf9;padding:0 3px;"> </span><span style="background:#6edff6;color:#6edff6;padding:0 3px;"> </span><span style="background:#3dd5f3;color:#3dd5f3;padding:0 3px;"> </span><span style="background:#0dcaf0;color:#0dcaf0;padding:0 3px;"> </span><span style="background:#0aa2c0;color:#0aa2c0;padding:0 3px;"> </span><span style="background:#087990;color:#087990;padding:0 3px;"> </span><span style="background:#055160;color:#055160;padding:0 3px;"> </span><span style="background:#032830;color:#032830;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_gray</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f8f9fa;color:#f8f9fa;padding:0 3px;"> </span><span style="background:#e9ecef;color:#e9ecef;padding:0 3px;"> </span><span style="background:#dee2e6;color:#dee2e6;padding:0 3px;"> </span><span style="background:#ced4da;color:#ced4da;padding:0 3px;"> </span><span style="background:#adb5bd;color:#adb5bd;padding:0 3px;"> </span><span style="background:#6c757d;color:#6c757d;padding:0 3px;"> </span><span style="background:#495057;color:#495057;padding:0 3px;"> </span><span style="background:#343a40;color:#343a40;padding:0 3px;"> </span><span style="background:#212529;color:#212529;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_red</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFEBEE;color:#FFEBEE;padding:0 3px;"> </span><span style="background:#FFCDD2;color:#FFCDD2;padding:0 3px;"> </span><span style="background:#EF9A9A;color:#EF9A9A;padding:0 3px;"> </span><span style="background:#E57373;color:#E57373;padding:0 3px;"> </span><span style="background:#EF5350;color:#EF5350;padding:0 3px;"> </span><span style="background:#F44336;color:#F44336;padding:0 3px;"> </span><span style="background:#E53935;color:#E53935;padding:0 3px;"> </span><span style="background:#D32F2F;color:#D32F2F;padding:0 3px;"> </span><span style="background:#C62828;color:#C62828;padding:0 3px;"> </span><span style="background:#B71C1C;color:#B71C1C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_pink</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FCE4EC;color:#FCE4EC;padding:0 3px;"> </span><span style="background:#F8BBD0;color:#F8BBD0;padding:0 3px;"> </span><span style="background:#F48FB1;color:#F48FB1;padding:0 3px;"> </span><span style="background:#F06292;color:#F06292;padding:0 3px;"> </span><span style="background:#EC407A;color:#EC407A;padding:0 3px;"> </span><span style="background:#E91E63;color:#E91E63;padding:0 3px;"> </span><span style="background:#D81B60;color:#D81B60;padding:0 3px;"> </span><span style="background:#C2185B;color:#C2185B;padding:0 3px;"> </span><span style="background:#AD1457;color:#AD1457;padding:0 3px;"> </span><span style="background:#880E4F;color:#880E4F;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F3E5F5;color:#F3E5F5;padding:0 3px;"> </span><span style="background:#E1BEE7;color:#E1BEE7;padding:0 3px;"> </span><span style="background:#CE93D8;color:#CE93D8;padding:0 3px;"> </span><span style="background:#BA68C8;color:#BA68C8;padding:0 3px;"> </span><span style="background:#AB47BC;color:#AB47BC;padding:0 3px;"> </span><span style="background:#9C27B0;color:#9C27B0;padding:0 3px;"> </span><span style="background:#8E24AA;color:#8E24AA;padding:0 3px;"> </span><span style="background:#7B1FA2;color:#7B1FA2;padding:0 3px;"> </span><span style="background:#6A1B9A;color:#6A1B9A;padding:0 3px;"> </span><span style="background:#4A148C;color:#4A148C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_deep-purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#EDE7F6;color:#EDE7F6;padding:0 3px;"> </span><span style="background:#D1C4E9;color:#D1C4E9;padding:0 3px;"> </span><span style="background:#B39DDB;color:#B39DDB;padding:0 3px;"> </span><span style="background:#9575CD;color:#9575CD;padding:0 3px;"> </span><span style="background:#7E57C2;color:#7E57C2;padding:0 3px;"> </span><span style="background:#673AB7;color:#673AB7;padding:0 3px;"> </span><span style="background:#5E35B1;color:#5E35B1;padding:0 3px;"> </span><span style="background:#512DA8;color:#512DA8;padding:0 3px;"> </span><span style="background:#4527A0;color:#4527A0;padding:0 3px;"> </span><span style="background:#311B92;color:#311B92;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_indigo</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E8EAF6;color:#E8EAF6;padding:0 3px;"> </span><span style="background:#C5CAE9;color:#C5CAE9;padding:0 3px;"> </span><span style="background:#9FA8DA;color:#9FA8DA;padding:0 3px;"> </span><span style="background:#7986CB;color:#7986CB;padding:0 3px;"> </span><span style="background:#5C6BC0;color:#5C6BC0;padding:0 3px;"> </span><span style="background:#3F51B5;color:#3F51B5;padding:0 3px;"> </span><span style="background:#3949AB;color:#3949AB;padding:0 3px;"> </span><span style="background:#303F9F;color:#303F9F;padding:0 3px;"> </span><span style="background:#283593;color:#283593;padding:0 3px;"> </span><span style="background:#1A237E;color:#1A237E;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E3F2FD;color:#E3F2FD;padding:0 3px;"> </span><span style="background:#BBDEFB;color:#BBDEFB;padding:0 3px;"> </span><span style="background:#90CAF9;color:#90CAF9;padding:0 3px;"> </span><span style="background:#64B5F6;color:#64B5F6;padding:0 3px;"> </span><span style="background:#42A5F5;color:#42A5F5;padding:0 3px;"> </span><span style="background:#2196F3;color:#2196F3;padding:0 3px;"> </span><span style="background:#1E88E5;color:#1E88E5;padding:0 3px;"> </span><span style="background:#1976D2;color:#1976D2;padding:0 3px;"> </span><span style="background:#1565C0;color:#1565C0;padding:0 3px;"> </span><span style="background:#0D47A1;color:#0D47A1;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_light-blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E1F5FE;color:#E1F5FE;padding:0 3px;"> </span><span style="background:#B3E5FC;color:#B3E5FC;padding:0 3px;"> </span><span style="background:#81D4FA;color:#81D4FA;padding:0 3px;"> </span><span style="background:#4FC3F7;color:#4FC3F7;padding:0 3px;"> </span><span style="background:#29B6F6;color:#29B6F6;padding:0 3px;"> </span><span style="background:#03A9F4;color:#03A9F4;padding:0 3px;"> </span><span style="background:#039BE5;color:#039BE5;padding:0 3px;"> </span><span style="background:#0288D1;color:#0288D1;padding:0 3px;"> </span><span style="background:#0277BD;color:#0277BD;padding:0 3px;"> </span><span style="background:#01579B;color:#01579B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_cyan</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E0F7FA;color:#E0F7FA;padding:0 3px;"> </span><span style="background:#B2EBF2;color:#B2EBF2;padding:0 3px;"> </span><span style="background:#80DEEA;color:#80DEEA;padding:0 3px;"> </span><span style="background:#4DD0E1;color:#4DD0E1;padding:0 3px;"> </span><span style="background:#26C6DA;color:#26C6DA;padding:0 3px;"> </span><span style="background:#00BCD4;color:#00BCD4;padding:0 3px;"> </span><span style="background:#00ACC1;color:#00ACC1;padding:0 3px;"> </span><span style="background:#0097A7;color:#0097A7;padding:0 3px;"> </span><span style="background:#00838F;color:#00838F;padding:0 3px;"> </span><span style="background:#006064;color:#006064;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_teal</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E0F2F1;color:#E0F2F1;padding:0 3px;"> </span><span style="background:#B2DFDB;color:#B2DFDB;padding:0 3px;"> </span><span style="background:#80CBC4;color:#80CBC4;padding:0 3px;"> </span><span style="background:#4DB6AC;color:#4DB6AC;padding:0 3px;"> </span><span style="background:#26A69A;color:#26A69A;padding:0 3px;"> </span><span style="background:#009688;color:#009688;padding:0 3px;"> </span><span style="background:#00897B;color:#00897B;padding:0 3px;"> </span><span style="background:#00796B;color:#00796B;padding:0 3px;"> </span><span style="background:#00695C;color:#00695C;padding:0 3px;"> </span><span style="background:#004D40;color:#004D40;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E8F5E9;color:#E8F5E9;padding:0 3px;"> </span><span style="background:#C8E6C9;color:#C8E6C9;padding:0 3px;"> </span><span style="background:#A5D6A7;color:#A5D6A7;padding:0 3px;"> </span><span style="background:#81C784;color:#81C784;padding:0 3px;"> </span><span style="background:#66BB6A;color:#66BB6A;padding:0 3px;"> </span><span style="background:#4CAF50;color:#4CAF50;padding:0 3px;"> </span><span style="background:#43A047;color:#43A047;padding:0 3px;"> </span><span style="background:#388E3C;color:#388E3C;padding:0 3px;"> </span><span style="background:#2E7D32;color:#2E7D32;padding:0 3px;"> </span><span style="background:#1B5E20;color:#1B5E20;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_light-green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F1F8E9;color:#F1F8E9;padding:0 3px;"> </span><span style="background:#DCEDC8;color:#DCEDC8;padding:0 3px;"> </span><span style="background:#C5E1A5;color:#C5E1A5;padding:0 3px;"> </span><span style="background:#AED581;color:#AED581;padding:0 3px;"> </span><span style="background:#9CCC65;color:#9CCC65;padding:0 3px;"> </span><span style="background:#8BC34A;color:#8BC34A;padding:0 3px;"> </span><span style="background:#7CB342;color:#7CB342;padding:0 3px;"> </span><span style="background:#689F38;color:#689F38;padding:0 3px;"> </span><span style="background:#558B2F;color:#558B2F;padding:0 3px;"> </span><span style="background:#33691E;color:#33691E;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_lime</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F9FBE7;color:#F9FBE7;padding:0 3px;"> </span><span style="background:#F0F4C3;color:#F0F4C3;padding:0 3px;"> </span><span style="background:#E6EE9C;color:#E6EE9C;padding:0 3px;"> </span><span style="background:#DCE775;color:#DCE775;padding:0 3px;"> </span><span style="background:#D4E157;color:#D4E157;padding:0 3px;"> </span><span style="background:#CDDC39;color:#CDDC39;padding:0 3px;"> </span><span style="background:#C0CA33;color:#C0CA33;padding:0 3px;"> </span><span style="background:#AFB42B;color:#AFB42B;padding:0 3px;"> </span><span style="background:#9E9D24;color:#9E9D24;padding:0 3px;"> </span><span style="background:#827717;color:#827717;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_yellow</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFFDE7;color:#FFFDE7;padding:0 3px;"> </span><span style="background:#FFF9C4;color:#FFF9C4;padding:0 3px;"> </span><span style="background:#FFF59D;color:#FFF59D;padding:0 3px;"> </span><span style="background:#FFF176;color:#FFF176;padding:0 3px;"> </span><span style="background:#FFEE58;color:#FFEE58;padding:0 3px;"> </span><span style="background:#FFEB3B;color:#FFEB3B;padding:0 3px;"> </span><span style="background:#FDD835;color:#FDD835;padding:0 3px;"> </span><span style="background:#FBC02D;color:#FBC02D;padding:0 3px;"> </span><span style="background:#F9A825;color:#F9A825;padding:0 3px;"> </span><span style="background:#F57F17;color:#F57F17;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_amber</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFF8E1;color:#FFF8E1;padding:0 3px;"> </span><span style="background:#FFECB3;color:#FFECB3;padding:0 3px;"> </span><span style="background:#FFE082;color:#FFE082;padding:0 3px;"> </span><span style="background:#FFD54F;color:#FFD54F;padding:0 3px;"> </span><span style="background:#FFCA28;color:#FFCA28;padding:0 3px;"> </span><span style="background:#FFC107;color:#FFC107;padding:0 3px;"> </span><span style="background:#FFB300;color:#FFB300;padding:0 3px;"> </span><span style="background:#FFA000;color:#FFA000;padding:0 3px;"> </span><span style="background:#FF8F00;color:#FF8F00;padding:0 3px;"> </span><span style="background:#FF6F00;color:#FF6F00;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFF3E0;color:#FFF3E0;padding:0 3px;"> </span><span style="background:#FFE0B2;color:#FFE0B2;padding:0 3px;"> </span><span style="background:#FFCC80;color:#FFCC80;padding:0 3px;"> </span><span style="background:#FFB74D;color:#FFB74D;padding:0 3px;"> </span><span style="background:#FFA726;color:#FFA726;padding:0 3px;"> </span><span style="background:#FF9800;color:#FF9800;padding:0 3px;"> </span><span style="background:#FB8C00;color:#FB8C00;padding:0 3px;"> </span><span style="background:#F57C00;color:#F57C00;padding:0 3px;"> </span><span style="background:#EF6C00;color:#EF6C00;padding:0 3px;"> </span><span style="background:#E65100;color:#E65100;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_deep-orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FBE9E7;color:#FBE9E7;padding:0 3px;"> </span><span style="background:#FFCCBC;color:#FFCCBC;padding:0 3px;"> </span><span style="background:#FFAB91;color:#FFAB91;padding:0 3px;"> </span><span style="background:#FF8A65;color:#FF8A65;padding:0 3px;"> </span><span style="background:#FF7043;color:#FF7043;padding:0 3px;"> </span><span style="background:#FF5722;color:#FF5722;padding:0 3px;"> </span><span style="background:#F4511E;color:#F4511E;padding:0 3px;"> </span><span style="background:#E64A19;color:#E64A19;padding:0 3px;"> </span><span style="background:#D84315;color:#D84315;padding:0 3px;"> </span><span style="background:#BF360C;color:#BF360C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_brown</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#EFEBE9;color:#EFEBE9;padding:0 3px;"> </span><span style="background:#D7CCC8;color:#D7CCC8;padding:0 3px;"> </span><span style="background:#BCAAA4;color:#BCAAA4;padding:0 3px;"> </span><span style="background:#A1887F;color:#A1887F;padding:0 3px;"> </span><span style="background:#8D6E63;color:#8D6E63;padding:0 3px;"> </span><span style="background:#795548;color:#795548;padding:0 3px;"> </span><span style="background:#6D4C41;color:#6D4C41;padding:0 3px;"> </span><span style="background:#5D4037;color:#5D4037;padding:0 3px;"> </span><span style="background:#4E342E;color:#4E342E;padding:0 3px;"> </span><span style="background:#3E2723;color:#3E2723;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_grey</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FAFAFA;color:#FAFAFA;padding:0 3px;"> </span><span style="background:#F5F5F5;color:#F5F5F5;padding:0 3px;"> </span><span style="background:#EEEEEE;color:#EEEEEE;padding:0 3px;"> </span><span style="background:#E0E0E0;color:#E0E0E0;padding:0 3px;"> </span><span style="background:#BDBDBD;color:#BDBDBD;padding:0 3px;"> </span><span style="background:#9E9E9E;color:#9E9E9E;padding:0 3px;"> </span><span style="background:#757575;color:#757575;padding:0 3px;"> </span><span style="background:#616161;color:#616161;padding:0 3px;"> </span><span style="background:#424242;color:#424242;padding:0 3px;"> </span><span style="background:#212121;color:#212121;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_blue-grey</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#ECEFF1;color:#ECEFF1;padding:0 3px;"> </span><span style="background:#CFD8DC;color:#CFD8DC;padding:0 3px;"> </span><span style="background:#B0BEC5;color:#B0BEC5;padding:0 3px;"> </span><span style="background:#90A4AE;color:#90A4AE;padding:0 3px;"> </span><span style="background:#78909C;color:#78909C;padding:0 3px;"> </span><span style="background:#607D8B;color:#607D8B;padding:0 3px;"> </span><span style="background:#546E7A;color:#546E7A;padding:0 3px;"> </span><span style="background:#455A64;color:#455A64;padding:0 3px;"> </span><span style="background:#37474F;color:#37474F;padding:0 3px;"> </span><span style="background:#263238;color:#263238;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_slate</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f8fafc;color:#f8fafc;padding:0 3px;"> </span><span style="background:#f1f5f9;color:#f1f5f9;padding:0 3px;"> </span><span style="background:#e2e8f0;color:#e2e8f0;padding:0 3px;"> </span><span style="background:#cbd5e1;color:#cbd5e1;padding:0 3px;"> </span><span style="background:#94a3b8;color:#94a3b8;padding:0 3px;"> </span><span style="background:#64748b;color:#64748b;padding:0 3px;"> </span><span style="background:#475569;color:#475569;padding:0 3px;"> </span><span style="background:#334155;color:#334155;padding:0 3px;"> </span><span style="background:#1e293b;color:#1e293b;padding:0 3px;"> </span><span style="background:#0f172a;color:#0f172a;padding:0 3px;"> </span><span style="background:#020617;color:#020617;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_gray</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f9fafb;color:#f9fafb;padding:0 3px;"> </span><span style="background:#f3f4f6;color:#f3f4f6;padding:0 3px;"> </span><span style="background:#e5e7eb;color:#e5e7eb;padding:0 3px;"> </span><span style="background:#d1d5db;color:#d1d5db;padding:0 3px;"> </span><span style="background:#9ca3af;color:#9ca3af;padding:0 3px;"> </span><span style="background:#6b7280;color:#6b7280;padding:0 3px;"> </span><span style="background:#4b5563;color:#4b5563;padding:0 3px;"> </span><span style="background:#374151;color:#374151;padding:0 3px;"> </span><span style="background:#1f2937;color:#1f2937;padding:0 3px;"> </span><span style="background:#111827;color:#111827;padding:0 3px;"> </span><span style="background:#030712;color:#030712;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_zinc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fafafa;color:#fafafa;padding:0 3px;"> </span><span style="background:#f4f4f5;color:#f4f4f5;padding:0 3px;"> </span><span style="background:#e4e4e7;color:#e4e4e7;padding:0 3px;"> </span><span style="background:#d4d4d8;color:#d4d4d8;padding:0 3px;"> </span><span style="background:#a1a1aa;color:#a1a1aa;padding:0 3px;"> </span><span style="background:#71717a;color:#71717a;padding:0 3px;"> </span><span style="background:#52525b;color:#52525b;padding:0 3px;"> </span><span style="background:#3f3f46;color:#3f3f46;padding:0 3px;"> </span><span style="background:#27272a;color:#27272a;padding:0 3px;"> </span><span style="background:#18181b;color:#18181b;padding:0 3px;"> </span><span style="background:#09090b;color:#09090b;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_neutral</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fafafa;color:#fafafa;padding:0 3px;"> </span><span style="background:#f5f5f5;color:#f5f5f5;padding:0 3px;"> </span><span style="background:#e5e5e5;color:#e5e5e5;padding:0 3px;"> </span><span style="background:#d4d4d4;color:#d4d4d4;padding:0 3px;"> </span><span style="background:#a3a3a3;color:#a3a3a3;padding:0 3px;"> </span><span style="background:#737373;color:#737373;padding:0 3px;"> </span><span style="background:#525252;color:#525252;padding:0 3px;"> </span><span style="background:#404040;color:#404040;padding:0 3px;"> </span><span style="background:#262626;color:#262626;padding:0 3px;"> </span><span style="background:#171717;color:#171717;padding:0 3px;"> </span><span style="background:#0a0a0a;color:#0a0a0a;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_stone</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fafaf9;color:#fafaf9;padding:0 3px;"> </span><span style="background:#f5f5f4;color:#f5f5f4;padding:0 3px;"> </span><span style="background:#e7e5e4;color:#e7e5e4;padding:0 3px;"> </span><span style="background:#d6d3d1;color:#d6d3d1;padding:0 3px;"> </span><span style="background:#a8a29e;color:#a8a29e;padding:0 3px;"> </span><span style="background:#78716c;color:#78716c;padding:0 3px;"> </span><span style="background:#57534e;color:#57534e;padding:0 3px;"> </span><span style="background:#44403c;color:#44403c;padding:0 3px;"> </span><span style="background:#292524;color:#292524;padding:0 3px;"> </span><span style="background:#1c1917;color:#1c1917;padding:0 3px;"> </span><span style="background:#0c0a09;color:#0c0a09;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_red</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fef2f2;color:#fef2f2;padding:0 3px;"> </span><span style="background:#fee2e2;color:#fee2e2;padding:0 3px;"> </span><span style="background:#fecaca;color:#fecaca;padding:0 3px;"> </span><span style="background:#fca5a5;color:#fca5a5;padding:0 3px;"> </span><span style="background:#f87171;color:#f87171;padding:0 3px;"> </span><span style="background:#ef4444;color:#ef4444;padding:0 3px;"> </span><span style="background:#dc2626;color:#dc2626;padding:0 3px;"> </span><span style="background:#b91c1c;color:#b91c1c;padding:0 3px;"> </span><span style="background:#991b1b;color:#991b1b;padding:0 3px;"> </span><span style="background:#7f1d1d;color:#7f1d1d;padding:0 3px;"> </span><span style="background:#450a0a;color:#450a0a;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fff7ed;color:#fff7ed;padding:0 3px;"> </span><span style="background:#ffedd5;color:#ffedd5;padding:0 3px;"> </span><span style="background:#fed7aa;color:#fed7aa;padding:0 3px;"> </span><span style="background:#fdba74;color:#fdba74;padding:0 3px;"> </span><span style="background:#fb923c;color:#fb923c;padding:0 3px;"> </span><span style="background:#f97316;color:#f97316;padding:0 3px;"> </span><span style="background:#ea580c;color:#ea580c;padding:0 3px;"> </span><span style="background:#c2410c;color:#c2410c;padding:0 3px;"> </span><span style="background:#9a3412;color:#9a3412;padding:0 3px;"> </span><span style="background:#7c2d12;color:#7c2d12;padding:0 3px;"> </span><span style="background:#431407;color:#431407;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_amber</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fffbeb;color:#fffbeb;padding:0 3px;"> </span><span style="background:#fef3c7;color:#fef3c7;padding:0 3px;"> </span><span style="background:#fde68a;color:#fde68a;padding:0 3px;"> </span><span style="background:#fcd34d;color:#fcd34d;padding:0 3px;"> </span><span style="background:#fbbf24;color:#fbbf24;padding:0 3px;"> </span><span style="background:#f59e0b;color:#f59e0b;padding:0 3px;"> </span><span style="background:#d97706;color:#d97706;padding:0 3px;"> </span><span style="background:#b45309;color:#b45309;padding:0 3px;"> </span><span style="background:#92400e;color:#92400e;padding:0 3px;"> </span><span style="background:#78350f;color:#78350f;padding:0 3px;"> </span><span style="background:#451a03;color:#451a03;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_yellow</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fefce8;color:#fefce8;padding:0 3px;"> </span><span style="background:#fef9c3;color:#fef9c3;padding:0 3px;"> </span><span style="background:#fef08a;color:#fef08a;padding:0 3px;"> </span><span style="background:#fde047;color:#fde047;padding:0 3px;"> </span><span style="background:#facc15;color:#facc15;padding:0 3px;"> </span><span style="background:#eab308;color:#eab308;padding:0 3px;"> </span><span style="background:#ca8a04;color:#ca8a04;padding:0 3px;"> </span><span style="background:#a16207;color:#a16207;padding:0 3px;"> </span><span style="background:#854d0e;color:#854d0e;padding:0 3px;"> </span><span style="background:#713f12;color:#713f12;padding:0 3px;"> </span><span style="background:#422006;color:#422006;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_lime</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f7fee7;color:#f7fee7;padding:0 3px;"> </span><span style="background:#ecfccb;color:#ecfccb;padding:0 3px;"> </span><span style="background:#d9f99d;color:#d9f99d;padding:0 3px;"> </span><span style="background:#bef264;color:#bef264;padding:0 3px;"> </span><span style="background:#a3e635;color:#a3e635;padding:0 3px;"> </span><span style="background:#84cc16;color:#84cc16;padding:0 3px;"> </span><span style="background:#65a30d;color:#65a30d;padding:0 3px;"> </span><span style="background:#4d7c0f;color:#4d7c0f;padding:0 3px;"> </span><span style="background:#3f6212;color:#3f6212;padding:0 3px;"> </span><span style="background:#365314;color:#365314;padding:0 3px;"> </span><span style="background:#1a2e05;color:#1a2e05;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f0fdf4;color:#f0fdf4;padding:0 3px;"> </span><span style="background:#dcfce7;color:#dcfce7;padding:0 3px;"> </span><span style="background:#bbf7d0;color:#bbf7d0;padding:0 3px;"> </span><span style="background:#86efac;color:#86efac;padding:0 3px;"> </span><span style="background:#4ade80;color:#4ade80;padding:0 3px;"> </span><span style="background:#22c55e;color:#22c55e;padding:0 3px;"> </span><span style="background:#16a34a;color:#16a34a;padding:0 3px;"> </span><span style="background:#15803d;color:#15803d;padding:0 3px;"> </span><span style="background:#166534;color:#166534;padding:0 3px;"> </span><span style="background:#14532d;color:#14532d;padding:0 3px;"> </span><span style="background:#052e16;color:#052e16;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_emerald</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#ecfdf5;color:#ecfdf5;padding:0 3px;"> </span><span style="background:#d1fae5;color:#d1fae5;padding:0 3px;"> </span><span style="background:#a7f3d0;color:#a7f3d0;padding:0 3px;"> </span><span style="background:#6ee7b7;color:#6ee7b7;padding:0 3px;"> </span><span style="background:#34d399;color:#34d399;padding:0 3px;"> </span><span style="background:#10b981;color:#10b981;padding:0 3px;"> </span><span style="background:#059669;color:#059669;padding:0 3px;"> </span><span style="background:#047857;color:#047857;padding:0 3px;"> </span><span style="background:#065f46;color:#065f46;padding:0 3px;"> </span><span style="background:#064e3b;color:#064e3b;padding:0 3px;"> </span><span style="background:#022c22;color:#022c22;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_teal</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f0fdfa;color:#f0fdfa;padding:0 3px;"> </span><span style="background:#ccfbf1;color:#ccfbf1;padding:0 3px;"> </span><span style="background:#99f6e4;color:#99f6e4;padding:0 3px;"> </span><span style="background:#5eead4;color:#5eead4;padding:0 3px;"> </span><span style="background:#2dd4bf;color:#2dd4bf;padding:0 3px;"> </span><span style="background:#14b8a6;color:#14b8a6;padding:0 3px;"> </span><span style="background:#0d9488;color:#0d9488;padding:0 3px;"> </span><span style="background:#0f766e;color:#0f766e;padding:0 3px;"> </span><span style="background:#115e59;color:#115e59;padding:0 3px;"> </span><span style="background:#134e4a;color:#134e4a;padding:0 3px;"> </span><span style="background:#042f2e;color:#042f2e;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_cyan</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#ecfeff;color:#ecfeff;padding:0 3px;"> </span><span style="background:#cffafe;color:#cffafe;padding:0 3px;"> </span><span style="background:#a5f3fc;color:#a5f3fc;padding:0 3px;"> </span><span style="background:#67e8f9;color:#67e8f9;padding:0 3px;"> </span><span style="background:#22d3ee;color:#22d3ee;padding:0 3px;"> </span><span style="background:#06b6d4;color:#06b6d4;padding:0 3px;"> </span><span style="background:#0891b2;color:#0891b2;padding:0 3px;"> </span><span style="background:#0e7490;color:#0e7490;padding:0 3px;"> </span><span style="background:#155e75;color:#155e75;padding:0 3px;"> </span><span style="background:#164e63;color:#164e63;padding:0 3px;"> </span><span style="background:#083344;color:#083344;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_sky</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f0f9ff;color:#f0f9ff;padding:0 3px;"> </span><span style="background:#e0f2fe;color:#e0f2fe;padding:0 3px;"> </span><span style="background:#bae6fd;color:#bae6fd;padding:0 3px;"> </span><span style="background:#7dd3fc;color:#7dd3fc;padding:0 3px;"> </span><span style="background:#38bdf8;color:#38bdf8;padding:0 3px;"> </span><span style="background:#0ea5e9;color:#0ea5e9;padding:0 3px;"> </span><span style="background:#0284c7;color:#0284c7;padding:0 3px;"> </span><span style="background:#0369a1;color:#0369a1;padding:0 3px;"> </span><span style="background:#075985;color:#075985;padding:0 3px;"> </span><span style="background:#0c4a6e;color:#0c4a6e;padding:0 3px;"> </span><span style="background:#082f49;color:#082f49;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#eff6ff;color:#eff6ff;padding:0 3px;"> </span><span style="background:#dbeafe;color:#dbeafe;padding:0 3px;"> </span><span style="background:#bfdbfe;color:#bfdbfe;padding:0 3px;"> </span><span style="background:#93c5fd;color:#93c5fd;padding:0 3px;"> </span><span style="background:#60a5fa;color:#60a5fa;padding:0 3px;"> </span><span style="background:#3b82f6;color:#3b82f6;padding:0 3px;"> </span><span style="background:#2563eb;color:#2563eb;padding:0 3px;"> </span><span style="background:#1d4ed8;color:#1d4ed8;padding:0 3px;"> </span><span style="background:#1e40af;color:#1e40af;padding:0 3px;"> </span><span style="background:#1e3a8a;color:#1e3a8a;padding:0 3px;"> </span><span style="background:#172554;color:#172554;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_indigo</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#eef2ff;color:#eef2ff;padding:0 3px;"> </span><span style="background:#e0e7ff;color:#e0e7ff;padding:0 3px;"> </span><span style="background:#c7d2fe;color:#c7d2fe;padding:0 3px;"> </span><span style="background:#a5b4fc;color:#a5b4fc;padding:0 3px;"> </span><span style="background:#818cf8;color:#818cf8;padding:0 3px;"> </span><span style="background:#6366f1;color:#6366f1;padding:0 3px;"> </span><span style="background:#4f46e5;color:#4f46e5;padding:0 3px;"> </span><span style="background:#4338ca;color:#4338ca;padding:0 3px;"> </span><span style="background:#3730a3;color:#3730a3;padding:0 3px;"> </span><span style="background:#312e81;color:#312e81;padding:0 3px;"> </span><span style="background:#1e1b4b;color:#1e1b4b;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_violet</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#f5f3ff;color:#f5f3ff;padding:0 3px;"> </span><span style="background:#ede9fe;color:#ede9fe;padding:0 3px;"> </span><span style="background:#ddd6fe;color:#ddd6fe;padding:0 3px;"> </span><span style="background:#c4b5fd;color:#c4b5fd;padding:0 3px;"> </span><span style="background:#a78bfa;color:#a78bfa;padding:0 3px;"> </span><span style="background:#8b5cf6;color:#8b5cf6;padding:0 3px;"> </span><span style="background:#7c3aed;color:#7c3aed;padding:0 3px;"> </span><span style="background:#6d28d9;color:#6d28d9;padding:0 3px;"> </span><span style="background:#5b21b6;color:#5b21b6;padding:0 3px;"> </span><span style="background:#4c1d95;color:#4c1d95;padding:0 3px;"> </span><span style="background:#2e1065;color:#2e1065;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#faf5ff;color:#faf5ff;padding:0 3px;"> </span><span style="background:#f3e8ff;color:#f3e8ff;padding:0 3px;"> </span><span style="background:#e9d5ff;color:#e9d5ff;padding:0 3px;"> </span><span style="background:#d8b4fe;color:#d8b4fe;padding:0 3px;"> </span><span style="background:#c084fc;color:#c084fc;padding:0 3px;"> </span><span style="background:#a855f7;color:#a855f7;padding:0 3px;"> </span><span style="background:#9333ea;color:#9333ea;padding:0 3px;"> </span><span style="background:#7e22ce;color:#7e22ce;padding:0 3px;"> </span><span style="background:#6b21a8;color:#6b21a8;padding:0 3px;"> </span><span style="background:#581c87;color:#581c87;padding:0 3px;"> </span><span style="background:#3b0764;color:#3b0764;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_fuchsia</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fdf4ff;color:#fdf4ff;padding:0 3px;"> </span><span style="background:#fae8ff;color:#fae8ff;padding:0 3px;"> </span><span style="background:#f5d0fe;color:#f5d0fe;padding:0 3px;"> </span><span style="background:#f0abfc;color:#f0abfc;padding:0 3px;"> </span><span style="background:#e879f9;color:#e879f9;padding:0 3px;"> </span><span style="background:#d946ef;color:#d946ef;padding:0 3px;"> </span><span style="background:#c026d3;color:#c026d3;padding:0 3px;"> </span><span style="background:#a21caf;color:#a21caf;padding:0 3px;"> </span><span style="background:#86198f;color:#86198f;padding:0 3px;"> </span><span style="background:#701a75;color:#701a75;padding:0 3px;"> </span><span style="background:#4a044e;color:#4a044e;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_pink</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fdf2f8;color:#fdf2f8;padding:0 3px;"> </span><span style="background:#fce7f3;color:#fce7f3;padding:0 3px;"> </span><span style="background:#fbcfe8;color:#fbcfe8;padding:0 3px;"> </span><span style="background:#f9a8d4;color:#f9a8d4;padding:0 3px;"> </span><span style="background:#f472b6;color:#f472b6;padding:0 3px;"> </span><span style="background:#ec4899;color:#ec4899;padding:0 3px;"> </span><span style="background:#db2777;color:#db2777;padding:0 3px;"> </span><span style="background:#be185d;color:#be185d;padding:0 3px;"> </span><span style="background:#9d174d;color:#9d174d;padding:0 3px;"> </span><span style="background:#831843;color:#831843;padding:0 3px;"> </span><span style="background:#500724;color:#500724;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_rose</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#fff1f2;color:#fff1f2;padding:0 3px;"> </span><span style="background:#ffe4e6;color:#ffe4e6;padding:0 3px;"> </span><span style="background:#fecdd3;color:#fecdd3;padding:0 3px;"> </span><span style="background:#fda4af;color:#fda4af;padding:0 3px;"> </span><span style="background:#fb7185;color:#fb7185;padding:0 3px;"> </span><span style="background:#f43f5e;color:#f43f5e;padding:0 3px;"> </span><span style="background:#e11d48;color:#e11d48;padding:0 3px;"> </span><span style="background:#be123c;color:#be123c;padding:0 3px;"> </span><span style="background:#9f1239;color:#9f1239;padding:0 3px;"> </span><span style="background:#881337;color:#881337;padding:0 3px;"> </span><span style="background:#4c0519;color:#4c0519;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "hcl")
#> <div id="cmsbveirad" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#cmsbveirad table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #cmsbveirad thead, #cmsbveirad tbody, #cmsbveirad tfoot, #cmsbveirad tr, #cmsbveirad td, #cmsbveirad th {
#>   border-style: none;
#> }
#> 
#> #cmsbveirad p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #cmsbveirad .gt_table {
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
#> #cmsbveirad .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #cmsbveirad .gt_title {
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
#> #cmsbveirad .gt_subtitle {
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
#> #cmsbveirad .gt_heading {
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
#> #cmsbveirad .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cmsbveirad .gt_col_headings {
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
#> #cmsbveirad .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #cmsbveirad .gt_column_spanner_outer {
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
#> #cmsbveirad .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #cmsbveirad .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #cmsbveirad .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #cmsbveirad .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #cmsbveirad .gt_group_heading {
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
#> #cmsbveirad .gt_empty_group_heading {
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
#> #cmsbveirad .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #cmsbveirad .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #cmsbveirad .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #cmsbveirad .gt_stub {
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
#> #cmsbveirad .gt_stub_row_group {
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
#> #cmsbveirad .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #cmsbveirad .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #cmsbveirad .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cmsbveirad .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #cmsbveirad .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #cmsbveirad .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cmsbveirad .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cmsbveirad .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #cmsbveirad .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cmsbveirad .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #cmsbveirad .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cmsbveirad .gt_footnotes {
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
#> #cmsbveirad .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cmsbveirad .gt_sourcenotes {
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
#> #cmsbveirad .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cmsbveirad .gt_left {
#>   text-align: left;
#> }
#> 
#> #cmsbveirad .gt_center {
#>   text-align: center;
#> }
#> 
#> #cmsbveirad .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #cmsbveirad .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #cmsbveirad .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #cmsbveirad .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #cmsbveirad .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #cmsbveirad .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #cmsbveirad .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #cmsbveirad .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #cmsbveirad .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #cmsbveirad .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #cmsbveirad .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #cmsbveirad .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #cmsbveirad .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #cmsbveirad div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>35 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Reds</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#6D0026;color:#6D0026;padding:0 3px;"> </span><span style="background:#700027;color:#700027;padding:0 3px;"> </span><span style="background:#740028;color:#740028;padding:0 3px;"> </span><span style="background:#78002A;color:#78002A;padding:0 3px;"> </span><span style="background:#7C002B;color:#7C002B;padding:0 3px;"> </span><span style="background:#80002C;color:#80002C;padding:0 3px;"> </span><span style="background:#83002D;color:#83002D;padding:0 3px;"> </span><span style="background:#87002E;color:#87002E;padding:0 3px;"> </span><span style="background:#8B002F;color:#8B002F;padding:0 3px;"> </span><span style="background:#8F0030;color:#8F0030;padding:0 3px;"> </span><span style="background:#930031;color:#930031;padding:0 3px;"> </span><span style="background:#970031;color:#970031;padding:0 3px;"> </span><span style="background:#9B0032;color:#9B0032;padding:0 3px;"> </span><span style="background:#9E0033;color:#9E0033;padding:0 3px;"> </span><span style="background:#A20034;color:#A20034;padding:0 3px;"> </span><span style="background:#A60134;color:#A60134;padding:0 3px;"> </span><span style="background:#AA0435;color:#AA0435;padding:0 3px;"> </span><span style="background:#AE0635;color:#AE0635;padding:0 3px;"> </span><span style="background:#B20936;color:#B20936;padding:0 3px;"> </span><span style="background:#B60C36;color:#B60C36;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Reds_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7F000D;color:#7F000D;padding:0 3px;"> </span><span style="background:#810012;color:#810012;padding:0 3px;"> </span><span style="background:#830717;color:#830717;padding:0 3px;"> </span><span style="background:#850E1B;color:#850E1B;padding:0 3px;"> </span><span style="background:#87131F;color:#87131F;padding:0 3px;"> </span><span style="background:#881822;color:#881822;padding:0 3px;"> </span><span style="background:#8A1D26;color:#8A1D26;padding:0 3px;"> </span><span style="background:#8C2129;color:#8C2129;padding:0 3px;"> </span><span style="background:#8E242C;color:#8E242C;padding:0 3px;"> </span><span style="background:#8F282F;color:#8F282F;padding:0 3px;"> </span><span style="background:#912B32;color:#912B32;padding:0 3px;"> </span><span style="background:#932F35;color:#932F35;padding:0 3px;"> </span><span style="background:#953238;color:#953238;padding:0 3px;"> </span><span style="background:#96353B;color:#96353B;padding:0 3px;"> </span><span style="background:#98383E;color:#98383E;padding:0 3px;"> </span><span style="background:#9A3B40;color:#9A3B40;padding:0 3px;"> </span><span style="background:#9B3E43;color:#9B3E43;padding:0 3px;"> </span><span style="background:#9D4146;color:#9D4146;padding:0 3px;"> </span><span style="background:#9E4449;color:#9E4449;padding:0 3px;"> </span><span style="background:#A0474B;color:#A0474B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Reds_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#69000C;color:#69000C;padding:0 3px;"> </span><span style="background:#6C000E;color:#6C000E;padding:0 3px;"> </span><span style="background:#700110;color:#700110;padding:0 3px;"> </span><span style="background:#740211;color:#740211;padding:0 3px;"> </span><span style="background:#780313;color:#780313;padding:0 3px;"> </span><span style="background:#7C0414;color:#7C0414;padding:0 3px;"> </span><span style="background:#800616;color:#800616;padding:0 3px;"> </span><span style="background:#840717;color:#840717;padding:0 3px;"> </span><span style="background:#880819;color:#880819;padding:0 3px;"> </span><span style="background:#8C091A;color:#8C091A;padding:0 3px;"> </span><span style="background:#900B1B;color:#900B1B;padding:0 3px;"> </span><span style="background:#940C1D;color:#940C1D;padding:0 3px;"> </span><span style="background:#980E1E;color:#980E1E;padding:0 3px;"> </span><span style="background:#9C0F20;color:#9C0F20;padding:0 3px;"> </span><span style="background:#A01021;color:#A01021;padding:0 3px;"> </span><span style="background:#A41122;color:#A41122;padding:0 3px;"> </span><span style="background:#A81324;color:#A81324;padding:0 3px;"> </span><span style="background:#AC1425;color:#AC1425;padding:0 3px;"> </span><span style="background:#B01526;color:#B01526;padding:0 3px;"> </span><span style="background:#B41628;color:#B41628;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#273871;color:#273871;padding:0 3px;"> </span><span style="background:#283A74;color:#283A74;padding:0 3px;"> </span><span style="background:#293C76;color:#293C76;padding:0 3px;"> </span><span style="background:#2A3F79;color:#2A3F79;padding:0 3px;"> </span><span style="background:#2B417C;color:#2B417C;padding:0 3px;"> </span><span style="background:#2C437F;color:#2C437F;padding:0 3px;"> </span><span style="background:#2D4682;color:#2D4682;padding:0 3px;"> </span><span style="background:#2D4885;color:#2D4885;padding:0 3px;"> </span><span style="background:#2E4B88;color:#2E4B88;padding:0 3px;"> </span><span style="background:#2F4D8B;color:#2F4D8B;padding:0 3px;"> </span><span style="background:#2F4F8F;color:#2F4F8F;padding:0 3px;"> </span><span style="background:#305292;color:#305292;padding:0 3px;"> </span><span style="background:#305495;color:#305495;padding:0 3px;"> </span><span style="background:#315798;color:#315798;padding:0 3px;"> </span><span style="background:#31599B;color:#31599B;padding:0 3px;"> </span><span style="background:#315B9E;color:#315B9E;padding:0 3px;"> </span><span style="background:#325EA1;color:#325EA1;padding:0 3px;"> </span><span style="background:#3260A4;color:#3260A4;padding:0 3px;"> </span><span style="background:#3263A7;color:#3263A7;padding:0 3px;"> </span><span style="background:#3265AA;color:#3265AA;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#023FA5;color:#023FA5;padding:0 3px;"> </span><span style="background:#1141A4;color:#1141A4;padding:0 3px;"> </span><span style="background:#1A44A4;color:#1A44A4;padding:0 3px;"> </span><span style="background:#2146A4;color:#2146A4;padding:0 3px;"> </span><span style="background:#2749A4;color:#2749A4;padding:0 3px;"> </span><span style="background:#2C4BA4;color:#2C4BA4;padding:0 3px;"> </span><span style="background:#314DA4;color:#314DA4;padding:0 3px;"> </span><span style="background:#3550A5;color:#3550A5;padding:0 3px;"> </span><span style="background:#3952A5;color:#3952A5;padding:0 3px;"> </span><span style="background:#3C54A6;color:#3C54A6;padding:0 3px;"> </span><span style="background:#4056A6;color:#4056A6;padding:0 3px;"> </span><span style="background:#4359A7;color:#4359A7;padding:0 3px;"> </span><span style="background:#465BA8;color:#465BA8;padding:0 3px;"> </span><span style="background:#4A5DA8;color:#4A5DA8;padding:0 3px;"> </span><span style="background:#4D5FA9;color:#4D5FA9;padding:0 3px;"> </span><span style="background:#5062AA;color:#5062AA;padding:0 3px;"> </span><span style="background:#5264AA;color:#5264AA;padding:0 3px;"> </span><span style="background:#5566AB;color:#5566AB;padding:0 3px;"> </span><span style="background:#5868AC;color:#5868AC;padding:0 3px;"> </span><span style="background:#5B6AAD;color:#5B6AAD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00366C;color:#00366C;padding:0 3px;"> </span><span style="background:#00386E;color:#00386E;padding:0 3px;"> </span><span style="background:#003A71;color:#003A71;padding:0 3px;"> </span><span style="background:#003D73;color:#003D73;padding:0 3px;"> </span><span style="background:#003F76;color:#003F76;padding:0 3px;"> </span><span style="background:#004178;color:#004178;padding:0 3px;"> </span><span style="background:#00447B;color:#00447B;padding:0 3px;"> </span><span style="background:#00467E;color:#00467E;padding:0 3px;"> </span><span style="background:#004981;color:#004981;padding:0 3px;"> </span><span style="background:#004B84;color:#004B84;padding:0 3px;"> </span><span style="background:#004D87;color:#004D87;padding:0 3px;"> </span><span style="background:#005089;color:#005089;padding:0 3px;"> </span><span style="background:#00528C;color:#00528C;padding:0 3px;"> </span><span style="background:#00558F;color:#00558F;padding:0 3px;"> </span><span style="background:#005793;color:#005793;padding:0 3px;"> </span><span style="background:#005A96;color:#005A96;padding:0 3px;"> </span><span style="background:#005C99;color:#005C99;padding:0 3px;"> </span><span style="background:#005F9C;color:#005F9C;padding:0 3px;"> </span><span style="background:#00619F;color:#00619F;padding:0 3px;"> </span><span style="background:#0064A2;color:#0064A2;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Greens</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#004616;color:#004616;padding:0 3px;"> </span><span style="background:#004918;color:#004918;padding:0 3px;"> </span><span style="background:#004C1A;color:#004C1A;padding:0 3px;"> </span><span style="background:#004E1C;color:#004E1C;padding:0 3px;"> </span><span style="background:#00511D;color:#00511D;padding:0 3px;"> </span><span style="background:#00541F;color:#00541F;padding:0 3px;"> </span><span style="background:#035721;color:#035721;padding:0 3px;"> </span><span style="background:#065922;color:#065922;padding:0 3px;"> </span><span style="background:#095C24;color:#095C24;padding:0 3px;"> </span><span style="background:#0C5F25;color:#0C5F25;padding:0 3px;"> </span><span style="background:#0F6227;color:#0F6227;padding:0 3px;"> </span><span style="background:#126429;color:#126429;padding:0 3px;"> </span><span style="background:#15672A;color:#15672A;padding:0 3px;"> </span><span style="background:#176A2B;color:#176A2B;padding:0 3px;"> </span><span style="background:#196C2D;color:#196C2D;padding:0 3px;"> </span><span style="background:#1C6F2E;color:#1C6F2E;padding:0 3px;"> </span><span style="background:#1E7230;color:#1E7230;padding:0 3px;"> </span><span style="background:#207431;color:#207431;padding:0 3px;"> </span><span style="background:#227732;color:#227732;padding:0 3px;"> </span><span style="background:#257A34;color:#257A34;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Greens_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#006027;color:#006027;padding:0 3px;"> </span><span style="background:#08622B;color:#08622B;padding:0 3px;"> </span><span style="background:#11632E;color:#11632E;padding:0 3px;"> </span><span style="background:#176531;color:#176531;padding:0 3px;"> </span><span style="background:#1C6733;color:#1C6733;padding:0 3px;"> </span><span style="background:#216936;color:#216936;padding:0 3px;"> </span><span style="background:#256A39;color:#256A39;padding:0 3px;"> </span><span style="background:#296C3C;color:#296C3C;padding:0 3px;"> </span><span style="background:#2C6E3E;color:#2C6E3E;padding:0 3px;"> </span><span style="background:#307041;color:#307041;padding:0 3px;"> </span><span style="background:#337144;color:#337144;padding:0 3px;"> </span><span style="background:#377346;color:#377346;padding:0 3px;"> </span><span style="background:#3A7549;color:#3A7549;padding:0 3px;"> </span><span style="background:#3D764B;color:#3D764B;padding:0 3px;"> </span><span style="background:#40784E;color:#40784E;padding:0 3px;"> </span><span style="background:#437A50;color:#437A50;padding:0 3px;"> </span><span style="background:#467C53;color:#467C53;padding:0 3px;"> </span><span style="background:#497D55;color:#497D55;padding:0 3px;"> </span><span style="background:#4C7F58;color:#4C7F58;padding:0 3px;"> </span><span style="background:#4F815A;color:#4F815A;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Greens_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#004616;color:#004616;padding:0 3px;"> </span><span style="background:#004918;color:#004918;padding:0 3px;"> </span><span style="background:#004C1A;color:#004C1A;padding:0 3px;"> </span><span style="background:#004F1C;color:#004F1C;padding:0 3px;"> </span><span style="background:#00511E;color:#00511E;padding:0 3px;"> </span><span style="background:#005420;color:#005420;padding:0 3px;"> </span><span style="background:#005722;color:#005722;padding:0 3px;"> </span><span style="background:#005A24;color:#005A24;padding:0 3px;"> </span><span style="background:#005C25;color:#005C25;padding:0 3px;"> </span><span style="background:#005F27;color:#005F27;padding:0 3px;"> </span><span style="background:#026229;color:#026229;padding:0 3px;"> </span><span style="background:#03652B;color:#03652B;padding:0 3px;"> </span><span style="background:#05672C;color:#05672C;padding:0 3px;"> </span><span style="background:#076A2E;color:#076A2E;padding:0 3px;"> </span><span style="background:#096D30;color:#096D30;padding:0 3px;"> </span><span style="background:#0B7032;color:#0B7032;padding:0 3px;"> </span><span style="background:#0C7333;color:#0C7333;padding:0 3px;"> </span><span style="background:#0E7535;color:#0E7535;padding:0 3px;"> </span><span style="background:#107837;color:#107837;padding:0 3px;"> </span><span style="background:#117B38;color:#117B38;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Oranges</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#802A07;color:#802A07;padding:0 3px;"> </span><span style="background:#832B04;color:#832B04;padding:0 3px;"> </span><span style="background:#872D00;color:#872D00;padding:0 3px;"> </span><span style="background:#8A2E00;color:#8A2E00;padding:0 3px;"> </span><span style="background:#8E2F00;color:#8E2F00;padding:0 3px;"> </span><span style="background:#913100;color:#913100;padding:0 3px;"> </span><span style="background:#953200;color:#953200;padding:0 3px;"> </span><span style="background:#983400;color:#983400;padding:0 3px;"> </span><span style="background:#9B3500;color:#9B3500;padding:0 3px;"> </span><span style="background:#9F3700;color:#9F3700;padding:0 3px;"> </span><span style="background:#A23800;color:#A23800;padding:0 3px;"> </span><span style="background:#A63A00;color:#A63A00;padding:0 3px;"> </span><span style="background:#A93B00;color:#A93B00;padding:0 3px;"> </span><span style="background:#AC3D00;color:#AC3D00;padding:0 3px;"> </span><span style="background:#B03E00;color:#B03E00;padding:0 3px;"> </span><span style="background:#B34000;color:#B34000;padding:0 3px;"> </span><span style="background:#B74200;color:#B74200;padding:0 3px;"> </span><span style="background:#BA4300;color:#BA4300;padding:0 3px;"> </span><span style="background:#BD4500;color:#BD4500;padding:0 3px;"> </span><span style="background:#C04600;color:#C04600;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purples</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#3D1778;color:#3D1778;padding:0 3px;"> </span><span style="background:#3F1B7A;color:#3F1B7A;padding:0 3px;"> </span><span style="background:#411E7C;color:#411E7C;padding:0 3px;"> </span><span style="background:#43217F;color:#43217F;padding:0 3px;"> </span><span style="background:#462481;color:#462481;padding:0 3px;"> </span><span style="background:#482784;color:#482784;padding:0 3px;"> </span><span style="background:#4A2A86;color:#4A2A86;padding:0 3px;"> </span><span style="background:#4C2C89;color:#4C2C89;padding:0 3px;"> </span><span style="background:#4E2F8C;color:#4E2F8C;padding:0 3px;"> </span><span style="background:#50318F;color:#50318F;padding:0 3px;"> </span><span style="background:#533492;color:#533492;padding:0 3px;"> </span><span style="background:#553695;color:#553695;padding:0 3px;"> </span><span style="background:#573998;color:#573998;padding:0 3px;"> </span><span style="background:#593B9B;color:#593B9B;padding:0 3px;"> </span><span style="background:#5C3E9E;color:#5C3E9E;padding:0 3px;"> </span><span style="background:#5E40A0;color:#5E40A0;padding:0 3px;"> </span><span style="background:#6043A1;color:#6043A1;padding:0 3px;"> </span><span style="background:#6147A2;color:#6147A2;padding:0 3px;"> </span><span style="background:#634AA3;color:#634AA3;padding:0 3px;"> </span><span style="background:#654DA4;color:#654DA4;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purples_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#3C2692;color:#3C2692;padding:0 3px;"> </span><span style="background:#3E2992;color:#3E2992;padding:0 3px;"> </span><span style="background:#402C91;color:#402C91;padding:0 3px;"> </span><span style="background:#423091;color:#423091;padding:0 3px;"> </span><span style="background:#443391;color:#443391;padding:0 3px;"> </span><span style="background:#463591;color:#463591;padding:0 3px;"> </span><span style="background:#483892;color:#483892;padding:0 3px;"> </span><span style="background:#4A3B92;color:#4A3B92;padding:0 3px;"> </span><span style="background:#4B3D93;color:#4B3D93;padding:0 3px;"> </span><span style="background:#4D4093;color:#4D4093;padding:0 3px;"> </span><span style="background:#4F4294;color:#4F4294;padding:0 3px;"> </span><span style="background:#514594;color:#514594;padding:0 3px;"> </span><span style="background:#534795;color:#534795;padding:0 3px;"> </span><span style="background:#554996;color:#554996;padding:0 3px;"> </span><span style="background:#574C97;color:#574C97;padding:0 3px;"> </span><span style="background:#594E98;color:#594E98;padding:0 3px;"> </span><span style="background:#5B5099;color:#5B5099;padding:0 3px;"> </span><span style="background:#5D539A;color:#5D539A;padding:0 3px;"> </span><span style="background:#5F559A;color:#5F559A;padding:0 3px;"> </span><span style="background:#61579B;color:#61579B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purples_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#312271;color:#312271;padding:0 3px;"> </span><span style="background:#332573;color:#332573;padding:0 3px;"> </span><span style="background:#362876;color:#362876;padding:0 3px;"> </span><span style="background:#382A78;color:#382A78;padding:0 3px;"> </span><span style="background:#3B2D7B;color:#3B2D7B;padding:0 3px;"> </span><span style="background:#3D307D;color:#3D307D;padding:0 3px;"> </span><span style="background:#3F3280;color:#3F3280;padding:0 3px;"> </span><span style="background:#423583;color:#423583;padding:0 3px;"> </span><span style="background:#443786;color:#443786;padding:0 3px;"> </span><span style="background:#473A89;color:#473A89;padding:0 3px;"> </span><span style="background:#493C8C;color:#493C8C;padding:0 3px;"> </span><span style="background:#4C3F8F;color:#4C3F8F;padding:0 3px;"> </span><span style="background:#4E4192;color:#4E4192;padding:0 3px;"> </span><span style="background:#514495;color:#514495;padding:0 3px;"> </span><span style="background:#534698;color:#534698;padding:0 3px;"> </span><span style="background:#55489C;color:#55489C;padding:0 3px;"> </span><span style="background:#584B9F;color:#584B9F;padding:0 3px;"> </span><span style="background:#5A4DA2;color:#5A4DA2;padding:0 3px;"> </span><span style="background:#5D50A5;color:#5D50A5;padding:0 3px;"> </span><span style="background:#5F52A8;color:#5F52A8;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Grays</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1B1B1B;color:#1B1B1B;padding:0 3px;"> </span><span style="background:#1E1E1E;color:#1E1E1E;padding:0 3px;"> </span><span style="background:#202020;color:#202020;padding:0 3px;"> </span><span style="background:#222222;color:#222222;padding:0 3px;"> </span><span style="background:#252525;color:#252525;padding:0 3px;"> </span><span style="background:#272727;color:#272727;padding:0 3px;"> </span><span style="background:#2A2A2A;color:#2A2A2A;padding:0 3px;"> </span><span style="background:#2C2C2C;color:#2C2C2C;padding:0 3px;"> </span><span style="background:#2E2E2E;color:#2E2E2E;padding:0 3px;"> </span><span style="background:#313131;color:#313131;padding:0 3px;"> </span><span style="background:#333333;color:#333333;padding:0 3px;"> </span><span style="background:#363636;color:#363636;padding:0 3px;"> </span><span style="background:#383838;color:#383838;padding:0 3px;"> </span><span style="background:#3B3B3B;color:#3B3B3B;padding:0 3px;"> </span><span style="background:#3D3D3D;color:#3D3D3D;padding:0 3px;"> </span><span style="background:#404040;color:#404040;padding:0 3px;"> </span><span style="background:#424242;color:#424242;padding:0 3px;"> </span><span style="background:#454545;color:#454545;padding:0 3px;"> </span><span style="background:#474747;color:#474747;padding:0 3px;"> </span><span style="background:#4A4A4A;color:#4A4A4A;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Light_Grays</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#474747;color:#474747;padding:0 3px;"> </span><span style="background:#494949;color:#494949;padding:0 3px;"> </span><span style="background:#4B4B4B;color:#4B4B4B;padding:0 3px;"> </span><span style="background:#4D4D4D;color:#4D4D4D;padding:0 3px;"> </span><span style="background:#4F4F4F;color:#4F4F4F;padding:0 3px;"> </span><span style="background:#515151;color:#515151;padding:0 3px;"> </span><span style="background:#535353;color:#535353;padding:0 3px;"> </span><span style="background:#555555;color:#555555;padding:0 3px;"> </span><span style="background:#575757;color:#575757;padding:0 3px;"> </span><span style="background:#595959;color:#595959;padding:0 3px;"> </span><span style="background:#5B5B5B;color:#5B5B5B;padding:0 3px;"> </span><span style="background:#5E5E5E;color:#5E5E5E;padding:0 3px;"> </span><span style="background:#606060;color:#606060;padding:0 3px;"> </span><span style="background:#626262;color:#626262;padding:0 3px;"> </span><span style="background:#646464;color:#646464;padding:0 3px;"> </span><span style="background:#666666;color:#666666;padding:0 3px;"> </span><span style="background:#686868;color:#686868;padding:0 3px;"> </span><span style="background:#6A6A6A;color:#6A6A6A;padding:0 3px;"> </span><span style="background:#6C6C6C;color:#6C6C6C;padding:0 3px;"> </span><span style="background:#6E6E6E;color:#6E6E6E;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_YlOrRd</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7D0025;color:#7D0025;padding:0 3px;"> </span><span style="background:#810024;color:#810024;padding:0 3px;"> </span><span style="background:#850023;color:#850023;padding:0 3px;"> </span><span style="background:#890021;color:#890021;padding:0 3px;"> </span><span style="background:#8E001F;color:#8E001F;padding:0 3px;"> </span><span style="background:#92001C;color:#92001C;padding:0 3px;"> </span><span style="background:#960119;color:#960119;padding:0 3px;"> </span><span style="background:#9A0315;color:#9A0315;padding:0 3px;"> </span><span style="background:#9E050F;color:#9E050F;padding:0 3px;"> </span><span style="background:#A20706;color:#A20706;padding:0 3px;"> </span><span style="background:#A60A00;color:#A60A00;padding:0 3px;"> </span><span style="background:#A90D00;color:#A90D00;padding:0 3px;"> </span><span style="background:#AD1000;color:#AD1000;padding:0 3px;"> </span><span style="background:#B11300;color:#B11300;padding:0 3px;"> </span><span style="background:#B51600;color:#B51600;padding:0 3px;"> </span><span style="background:#B81900;color:#B81900;padding:0 3px;"> </span><span style="background:#BC1C00;color:#BC1C00;padding:0 3px;"> </span><span style="background:#C01F00;color:#C01F00;padding:0 3px;"> </span><span style="background:#C32200;color:#C32200;padding:0 3px;"> </span><span style="background:#C72500;color:#C72500;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_YlOrBr</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#682714;color:#682714;padding:0 3px;"> </span><span style="background:#6C2812;color:#6C2812;padding:0 3px;"> </span><span style="background:#702A10;color:#702A10;padding:0 3px;"> </span><span style="background:#742C0E;color:#742C0E;padding:0 3px;"> </span><span style="background:#792E0A;color:#792E0A;padding:0 3px;"> </span><span style="background:#7D3005;color:#7D3005;padding:0 3px;"> </span><span style="background:#813200;color:#813200;padding:0 3px;"> </span><span style="background:#853400;color:#853400;padding:0 3px;"> </span><span style="background:#893600;color:#893600;padding:0 3px;"> </span><span style="background:#8D3800;color:#8D3800;padding:0 3px;"> </span><span style="background:#913A00;color:#913A00;padding:0 3px;"> </span><span style="background:#953C00;color:#953C00;padding:0 3px;"> </span><span style="background:#983E00;color:#983E00;padding:0 3px;"> </span><span style="background:#9C4100;color:#9C4100;padding:0 3px;"> </span><span style="background:#A04300;color:#A04300;padding:0 3px;"> </span><span style="background:#A44500;color:#A44500;padding:0 3px;"> </span><span style="background:#A84700;color:#A84700;padding:0 3px;"> </span><span style="background:#AB4A00;color:#AB4A00;padding:0 3px;"> </span><span style="background:#AF4C00;color:#AF4C00;padding:0 3px;"> </span><span style="background:#B34E00;color:#B34E00;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_YlGnBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#26185F;color:#26185F;padding:0 3px;"> </span><span style="background:#251C63;color:#251C63;padding:0 3px;"> </span><span style="background:#232167;color:#232167;padding:0 3px;"> </span><span style="background:#20256C;color:#20256C;padding:0 3px;"> </span><span style="background:#1C2970;color:#1C2970;padding:0 3px;"> </span><span style="background:#162D74;color:#162D74;padding:0 3px;"> </span><span style="background:#0D3178;color:#0D3178;padding:0 3px;"> </span><span style="background:#00357C;color:#00357C;padding:0 3px;"> </span><span style="background:#003A80;color:#003A80;padding:0 3px;"> </span><span style="background:#003E84;color:#003E84;padding:0 3px;"> </span><span style="background:#004288;color:#004288;padding:0 3px;"> </span><span style="background:#00468B;color:#00468B;padding:0 3px;"> </span><span style="background:#004A8F;color:#004A8F;padding:0 3px;"> </span><span style="background:#004E93;color:#004E93;padding:0 3px;"> </span><span style="background:#005296;color:#005296;padding:0 3px;"> </span><span style="background:#005699;color:#005699;padding:0 3px;"> </span><span style="background:#005A9D;color:#005A9D;padding:0 3px;"> </span><span style="background:#005FA0;color:#005FA0;padding:0 3px;"> </span><span style="background:#0063A3;color:#0063A3;padding:0 3px;"> </span><span style="background:#0067A6;color:#0067A6;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_BuGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1B4414;color:#1B4414;padding:0 3px;"> </span><span style="background:#1B4717;color:#1B4717;padding:0 3px;"> </span><span style="background:#1C4A19;color:#1C4A19;padding:0 3px;"> </span><span style="background:#1C4D1B;color:#1C4D1B;padding:0 3px;"> </span><span style="background:#1C501D;color:#1C501D;padding:0 3px;"> </span><span style="background:#1C531F;color:#1C531F;padding:0 3px;"> </span><span style="background:#1C5622;color:#1C5622;padding:0 3px;"> </span><span style="background:#1C5924;color:#1C5924;padding:0 3px;"> </span><span style="background:#1B5C26;color:#1B5C26;padding:0 3px;"> </span><span style="background:#1B5F29;color:#1B5F29;padding:0 3px;"> </span><span style="background:#1A632B;color:#1A632B;padding:0 3px;"> </span><span style="background:#19662E;color:#19662E;padding:0 3px;"> </span><span style="background:#186930;color:#186930;padding:0 3px;"> </span><span style="background:#166C33;color:#166C33;padding:0 3px;"> </span><span style="background:#146F35;color:#146F35;padding:0 3px;"> </span><span style="background:#117238;color:#117238;padding:0 3px;"> </span><span style="background:#0D753A;color:#0D753A;padding:0 3px;"> </span><span style="background:#08783D;color:#08783D;padding:0 3px;"> </span><span style="background:#027B40;color:#027B40;padding:0 3px;"> </span><span style="background:#007E42;color:#007E42;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_BuPu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#540046;color:#540046;padding:0 3px;"> </span><span style="background:#560049;color:#560049;padding:0 3px;"> </span><span style="background:#58004D;color:#58004D;padding:0 3px;"> </span><span style="background:#5A0050;color:#5A0050;padding:0 3px;"> </span><span style="background:#5C0053;color:#5C0053;padding:0 3px;"> </span><span style="background:#5E0157;color:#5E0157;padding:0 3px;"> </span><span style="background:#60065A;color:#60065A;padding:0 3px;"> </span><span style="background:#630B5E;color:#630B5E;padding:0 3px;"> </span><span style="background:#651061;color:#651061;padding:0 3px;"> </span><span style="background:#671465;color:#671465;padding:0 3px;"> </span><span style="background:#691869;color:#691869;padding:0 3px;"> </span><span style="background:#6B1B6C;color:#6B1B6C;padding:0 3px;"> </span><span style="background:#6D1F70;color:#6D1F70;padding:0 3px;"> </span><span style="background:#6F2274;color:#6F2274;padding:0 3px;"> </span><span style="background:#712578;color:#712578;padding:0 3px;"> </span><span style="background:#73287C;color:#73287C;padding:0 3px;"> </span><span style="background:#752B7F;color:#752B7F;padding:0 3px;"> </span><span style="background:#772F83;color:#772F83;padding:0 3px;"> </span><span style="background:#793287;color:#793287;padding:0 3px;"> </span><span style="background:#7A358B;color:#7A358B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_PuRd</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#611300;color:#611300;padding:0 3px;"> </span><span style="background:#661200;color:#661200;padding:0 3px;"> </span><span style="background:#6A1100;color:#6A1100;padding:0 3px;"> </span><span style="background:#6E1000;color:#6E1000;padding:0 3px;"> </span><span style="background:#730E00;color:#730E00;padding:0 3px;"> </span><span style="background:#770B00;color:#770B00;padding:0 3px;"> </span><span style="background:#7C0801;color:#7C0801;padding:0 3px;"> </span><span style="background:#800508;color:#800508;padding:0 3px;"> </span><span style="background:#85010F;color:#85010F;padding:0 3px;"> </span><span style="background:#890015;color:#890015;padding:0 3px;"> </span><span style="background:#8E001B;color:#8E001B;padding:0 3px;"> </span><span style="background:#930021;color:#930021;padding:0 3px;"> </span><span style="background:#970026;color:#970026;padding:0 3px;"> </span><span style="background:#9C002B;color:#9C002B;padding:0 3px;"> </span><span style="background:#A10030;color:#A10030;padding:0 3px;"> </span><span style="background:#A60035;color:#A60035;padding:0 3px;"> </span><span style="background:#AA003A;color:#AA003A;padding:0 3px;"> </span><span style="background:#AF0040;color:#AF0040;padding:0 3px;"> </span><span style="background:#B40045;color:#B40045;padding:0 3px;"> </span><span style="background:#B9004A;color:#B9004A;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_RdPu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#490062;color:#490062;padding:0 3px;"> </span><span style="background:#4C0064;color:#4C0064;padding:0 3px;"> </span><span style="background:#4F0065;color:#4F0065;padding:0 3px;"> </span><span style="background:#530067;color:#530067;padding:0 3px;"> </span><span style="background:#560069;color:#560069;padding:0 3px;"> </span><span style="background:#5A006C;color:#5A006C;padding:0 3px;"> </span><span style="background:#5D006E;color:#5D006E;padding:0 3px;"> </span><span style="background:#610070;color:#610070;padding:0 3px;"> </span><span style="background:#650072;color:#650072;padding:0 3px;"> </span><span style="background:#690075;color:#690075;padding:0 3px;"> </span><span style="background:#6D0277;color:#6D0277;padding:0 3px;"> </span><span style="background:#710479;color:#710479;padding:0 3px;"> </span><span style="background:#75067C;color:#75067C;padding:0 3px;"> </span><span style="background:#79087E;color:#79087E;padding:0 3px;"> </span><span style="background:#7D0A80;color:#7D0A80;padding:0 3px;"> </span><span style="background:#810C83;color:#810C83;padding:0 3px;"> </span><span style="background:#850E85;color:#850E85;padding:0 3px;"> </span><span style="background:#890F87;color:#890F87;padding:0 3px;"> </span><span style="background:#8D1189;color:#8D1189;padding:0 3px;"> </span><span style="background:#92138C;color:#92138C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_OrRd</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#88002D;color:#88002D;padding:0 3px;"> </span><span style="background:#8B002E;color:#8B002E;padding:0 3px;"> </span><span style="background:#8E002F;color:#8E002F;padding:0 3px;"> </span><span style="background:#920030;color:#920030;padding:0 3px;"> </span><span style="background:#950030;color:#950030;padding:0 3px;"> </span><span style="background:#990031;color:#990031;padding:0 3px;"> </span><span style="background:#9C0031;color:#9C0031;padding:0 3px;"> </span><span style="background:#A00032;color:#A00032;padding:0 3px;"> </span><span style="background:#A30032;color:#A30032;padding:0 3px;"> </span><span style="background:#A70032;color:#A70032;padding:0 3px;"> </span><span style="background:#AA0032;color:#AA0032;padding:0 3px;"> </span><span style="background:#AE0732;color:#AE0732;padding:0 3px;"> </span><span style="background:#B10D32;color:#B10D32;padding:0 3px;"> </span><span style="background:#B51332;color:#B51332;padding:0 3px;"> </span><span style="background:#B81732;color:#B81732;padding:0 3px;"> </span><span style="background:#BC1B31;color:#BC1B31;padding:0 3px;"> </span><span style="background:#BF1F31;color:#BF1F31;padding:0 3px;"> </span><span style="background:#C32330;color:#C32330;padding:0 3px;"> </span><span style="background:#C6262F;color:#C6262F;padding:0 3px;"> </span><span style="background:#CA2A2E;color:#CA2A2E;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_GnBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2F327D;color:#2F327D;padding:0 3px;"> </span><span style="background:#2D3781;color:#2D3781;padding:0 3px;"> </span><span style="background:#2A3B84;color:#2A3B84;padding:0 3px;"> </span><span style="background:#263F87;color:#263F87;padding:0 3px;"> </span><span style="background:#22438B;color:#22438B;padding:0 3px;"> </span><span style="background:#1C478E;color:#1C478E;padding:0 3px;"> </span><span style="background:#134B91;color:#134B91;padding:0 3px;"> </span><span style="background:#054F95;color:#054F95;padding:0 3px;"> </span><span style="background:#005398;color:#005398;padding:0 3px;"> </span><span style="background:#00579B;color:#00579B;padding:0 3px;"> </span><span style="background:#005B9E;color:#005B9E;padding:0 3px;"> </span><span style="background:#005EA1;color:#005EA1;padding:0 3px;"> </span><span style="background:#0062A4;color:#0062A4;padding:0 3px;"> </span><span style="background:#0066A7;color:#0066A7;padding:0 3px;"> </span><span style="background:#006AA9;color:#006AA9;padding:0 3px;"> </span><span style="background:#006EAC;color:#006EAC;padding:0 3px;"> </span><span style="background:#0072AF;color:#0072AF;padding:0 3px;"> </span><span style="background:#0075B1;color:#0075B1;padding:0 3px;"> </span><span style="background:#0079B4;color:#0079B4;padding:0 3px;"> </span><span style="background:#007DB6;color:#007DB6;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_PuBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0E3F5C;color:#0E3F5C;padding:0 3px;"> </span><span style="background:#0D415F;color:#0D415F;padding:0 3px;"> </span><span style="background:#0C4363;color:#0C4363;padding:0 3px;"> </span><span style="background:#0B4566;color:#0B4566;padding:0 3px;"> </span><span style="background:#0A476A;color:#0A476A;padding:0 3px;"> </span><span style="background:#09496D;color:#09496D;padding:0 3px;"> </span><span style="background:#084C71;color:#084C71;padding:0 3px;"> </span><span style="background:#074E74;color:#074E74;padding:0 3px;"> </span><span style="background:#075078;color:#075078;padding:0 3px;"> </span><span style="background:#06527B;color:#06527B;padding:0 3px;"> </span><span style="background:#06547E;color:#06547E;padding:0 3px;"> </span><span style="background:#055682;color:#055682;padding:0 3px;"> </span><span style="background:#055885;color:#055885;padding:0 3px;"> </span><span style="background:#055A89;color:#055A89;padding:0 3px;"> </span><span style="background:#055C8C;color:#055C8C;padding:0 3px;"> </span><span style="background:#055E90;color:#055E90;padding:0 3px;"> </span><span style="background:#056193;color:#056193;padding:0 3px;"> </span><span style="background:#066397;color:#066397;padding:0 3px;"> </span><span style="background:#06659A;color:#06659A;padding:0 3px;"> </span><span style="background:#07679E;color:#07679E;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_PuBuGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#004533;color:#004533;padding:0 3px;"> </span><span style="background:#004836;color:#004836;padding:0 3px;"> </span><span style="background:#004A38;color:#004A38;padding:0 3px;"> </span><span style="background:#004D3B;color:#004D3B;padding:0 3px;"> </span><span style="background:#004F3E;color:#004F3E;padding:0 3px;"> </span><span style="background:#005241;color:#005241;padding:0 3px;"> </span><span style="background:#005444;color:#005444;padding:0 3px;"> </span><span style="background:#005747;color:#005747;padding:0 3px;"> </span><span style="background:#005A4A;color:#005A4A;padding:0 3px;"> </span><span style="background:#005C4E;color:#005C4E;padding:0 3px;"> </span><span style="background:#005F51;color:#005F51;padding:0 3px;"> </span><span style="background:#006155;color:#006155;padding:0 3px;"> </span><span style="background:#006458;color:#006458;padding:0 3px;"> </span><span style="background:#00665C;color:#00665C;padding:0 3px;"> </span><span style="background:#00685F;color:#00685F;padding:0 3px;"> </span><span style="background:#006B63;color:#006B63;padding:0 3px;"> </span><span style="background:#006D67;color:#006D67;padding:0 3px;"> </span><span style="background:#00706B;color:#00706B;padding:0 3px;"> </span><span style="background:#00726F;color:#00726F;padding:0 3px;"> </span><span style="background:#007573;color:#007573;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blue_Red</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#023FA5;color:#023FA5;padding:0 3px;"> </span><span style="background:#1A44A4;color:#1A44A4;padding:0 3px;"> </span><span style="background:#2749A4;color:#2749A4;padding:0 3px;"> </span><span style="background:#314DA4;color:#314DA4;padding:0 3px;"> </span><span style="background:#3952A5;color:#3952A5;padding:0 3px;"> </span><span style="background:#4056A6;color:#4056A6;padding:0 3px;"> </span><span style="background:#465BA8;color:#465BA8;padding:0 3px;"> </span><span style="background:#4D5FA9;color:#4D5FA9;padding:0 3px;"> </span><span style="background:#5264AA;color:#5264AA;padding:0 3px;"> </span><span style="background:#5868AC;color:#5868AC;padding:0 3px;"> </span><span style="background:#5D6CAE;color:#5D6CAE;padding:0 3px;"> </span><span style="background:#6371AF;color:#6371AF;padding:0 3px;"> </span><span style="background:#6875B1;color:#6875B1;padding:0 3px;"> </span><span style="background:#6D79B3;color:#6D79B3;padding:0 3px;"> </span><span style="background:#727DB5;color:#727DB5;padding:0 3px;"> </span><span style="background:#7681B7;color:#7681B7;padding:0 3px;"> </span><span style="background:#7B85B8;color:#7B85B8;padding:0 3px;"> </span><span style="background:#8089BA;color:#8089BA;padding:0 3px;"> </span><span style="background:#848DBC;color:#848DBC;padding:0 3px;"> </span><span style="background:#8991BE;color:#8991BE;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blue_Yellow</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#4F53B7;color:#4F53B7;padding:0 3px;"> </span><span style="background:#5357B7;color:#5357B7;padding:0 3px;"> </span><span style="background:#575BB8;color:#575BB8;padding:0 3px;"> </span><span style="background:#5B5FB9;color:#5B5FB9;padding:0 3px;"> </span><span style="background:#5F62BA;color:#5F62BA;padding:0 3px;"> </span><span style="background:#6366BB;color:#6366BB;padding:0 3px;"> </span><span style="background:#676ABC;color:#676ABC;padding:0 3px;"> </span><span style="background:#6B6DBD;color:#6B6DBD;padding:0 3px;"> </span><span style="background:#6E71BE;color:#6E71BE;padding:0 3px;"> </span><span style="background:#7274BF;color:#7274BF;padding:0 3px;"> </span><span style="background:#7678C1;color:#7678C1;padding:0 3px;"> </span><span style="background:#797CC2;color:#797CC2;padding:0 3px;"> </span><span style="background:#7D7FC3;color:#7D7FC3;padding:0 3px;"> </span><span style="background:#8183C5;color:#8183C5;padding:0 3px;"> </span><span style="background:#8486C6;color:#8486C6;padding:0 3px;"> </span><span style="background:#888AC7;color:#888AC7;padding:0 3px;"> </span><span style="background:#8B8DC9;color:#8B8DC9;padding:0 3px;"> </span><span style="background:#8F90CA;color:#8F90CA;padding:0 3px;"> </span><span style="background:#9294CC;color:#9294CC;padding:0 3px;"> </span><span style="background:#9697CD;color:#9697CD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Green_Brown</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#004B40;color:#004B40;padding:0 3px;"> </span><span style="background:#005045;color:#005045;padding:0 3px;"> </span><span style="background:#00554A;color:#00554A;padding:0 3px;"> </span><span style="background:#005A4E;color:#005A4E;padding:0 3px;"> </span><span style="background:#005F53;color:#005F53;padding:0 3px;"> </span><span style="background:#006458;color:#006458;padding:0 3px;"> </span><span style="background:#00695D;color:#00695D;padding:0 3px;"> </span><span style="background:#006E61;color:#006E61;padding:0 3px;"> </span><span style="background:#007366;color:#007366;padding:0 3px;"> </span><span style="background:#00786B;color:#00786B;padding:0 3px;"> </span><span style="background:#007D70;color:#007D70;padding:0 3px;"> </span><span style="background:#008274;color:#008274;padding:0 3px;"> </span><span style="background:#008779;color:#008779;padding:0 3px;"> </span><span style="background:#008C7E;color:#008C7E;padding:0 3px;"> </span><span style="background:#009183;color:#009183;padding:0 3px;"> </span><span style="background:#009687;color:#009687;padding:0 3px;"> </span><span style="background:#009C8C;color:#009C8C;padding:0 3px;"> </span><span style="background:#00A090;color:#00A090;padding:0 3px;"> </span><span style="background:#00A495;color:#00A495;padding:0 3px;"> </span><span style="background:#00A899;color:#00A899;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purple_Green</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#492050;color:#492050;padding:0 3px;"> </span><span style="background:#4E2455;color:#4E2455;padding:0 3px;"> </span><span style="background:#54285B;color:#54285B;padding:0 3px;"> </span><span style="background:#592C61;color:#592C61;padding:0 3px;"> </span><span style="background:#5F3167;color:#5F3167;padding:0 3px;"> </span><span style="background:#65356D;color:#65356D;padding:0 3px;"> </span><span style="background:#6B3974;color:#6B3974;padding:0 3px;"> </span><span style="background:#713D7A;color:#713D7A;padding:0 3px;"> </span><span style="background:#774180;color:#774180;padding:0 3px;"> </span><span style="background:#7C4586;color:#7C4586;padding:0 3px;"> </span><span style="background:#82498D;color:#82498D;padding:0 3px;"> </span><span style="background:#884D93;color:#884D93;padding:0 3px;"> </span><span style="background:#8E5199;color:#8E5199;padding:0 3px;"> </span><span style="background:#9455A0;color:#9455A0;padding:0 3px;"> </span><span style="background:#9A59A6;color:#9A59A6;padding:0 3px;"> </span><span style="background:#A05DAC;color:#A05DAC;padding:0 3px;"> </span><span style="background:#A660B3;color:#A660B3;padding:0 3px;"> </span><span style="background:#AC64B9;color:#AC64B9;padding:0 3px;"> </span><span style="background:#B06ABD;color:#B06ABD;padding:0 3px;"> </span><span style="background:#B370C0;color:#B370C0;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Tropic</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#009B9F;color:#009B9F;padding:0 3px;"> </span><span style="background:#009DA1;color:#009DA1;padding:0 3px;"> </span><span style="background:#009EA2;color:#009EA2;padding:0 3px;"> </span><span style="background:#00A0A4;color:#00A0A4;padding:0 3px;"> </span><span style="background:#00A2A5;color:#00A2A5;padding:0 3px;"> </span><span style="background:#00A3A7;color:#00A3A7;padding:0 3px;"> </span><span style="background:#00A5A9;color:#00A5A9;padding:0 3px;"> </span><span style="background:#00A7AA;color:#00A7AA;padding:0 3px;"> </span><span style="background:#00A8AC;color:#00A8AC;padding:0 3px;"> </span><span style="background:#00AAAD;color:#00AAAD;padding:0 3px;"> </span><span style="background:#00ACAF;color:#00ACAF;padding:0 3px;"> </span><span style="background:#00ADB1;color:#00ADB1;padding:0 3px;"> </span><span style="background:#00AFB2;color:#00AFB2;padding:0 3px;"> </span><span style="background:#0CB1B4;color:#0CB1B4;padding:0 3px;"> </span><span style="background:#24B2B5;color:#24B2B5;padding:0 3px;"> </span><span style="background:#33B4B7;color:#33B4B7;padding:0 3px;"> </span><span style="background:#3EB6B9;color:#3EB6B9;padding:0 3px;"> </span><span style="background:#48B7BA;color:#48B7BA;padding:0 3px;"> </span><span style="background:#50B9BC;color:#50B9BC;padding:0 3px;"> </span><span style="background:#58BBBD;color:#58BBBD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Tofino</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#D6E0FF;color:#D6E0FF;padding:0 3px;"> </span><span style="background:#D1DBFF;color:#D1DBFF;padding:0 3px;"> </span><span style="background:#CCD6FF;color:#CCD6FF;padding:0 3px;"> </span><span style="background:#C7D1FF;color:#C7D1FF;padding:0 3px;"> </span><span style="background:#C2CCFF;color:#C2CCFF;padding:0 3px;"> </span><span style="background:#BDC7FF;color:#BDC7FF;padding:0 3px;"> </span><span style="background:#B7C3FE;color:#B7C3FE;padding:0 3px;"> </span><span style="background:#B2BEFB;color:#B2BEFB;padding:0 3px;"> </span><span style="background:#ADB9F7;color:#ADB9F7;padding:0 3px;"> </span><span style="background:#A8B4F3;color:#A8B4F3;padding:0 3px;"> </span><span style="background:#A3B0EE;color:#A3B0EE;padding:0 3px;"> </span><span style="background:#9FABE8;color:#9FABE8;padding:0 3px;"> </span><span style="background:#9BA6E2;color:#9BA6E2;padding:0 3px;"> </span><span style="background:#97A2DC;color:#97A2DC;padding:0 3px;"> </span><span style="background:#929DD7;color:#929DD7;padding:0 3px;"> </span><span style="background:#8E99D1;color:#8E99D1;padding:0 3px;"> </span><span style="background:#8A94CB;color:#8A94CB;padding:0 3px;"> </span><span style="background:#8690C5;color:#8690C5;padding:0 3px;"> </span><span style="background:#818CC0;color:#818CC0;padding:0 3px;"> </span><span style="background:#7D87BA;color:#7D87BA;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Berlin</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7FBFF5;color:#7FBFF5;padding:0 3px;"> </span><span style="background:#75B9F1;color:#75B9F1;padding:0 3px;"> </span><span style="background:#6AB4ED;color:#6AB4ED;padding:0 3px;"> </span><span style="background:#5FAFEA;color:#5FAFEA;padding:0 3px;"> </span><span style="background:#53AAE7;color:#53AAE7;padding:0 3px;"> </span><span style="background:#45A5E3;color:#45A5E3;padding:0 3px;"> </span><span style="background:#34A0E0;color:#34A0E0;padding:0 3px;"> </span><span style="background:#1C9BDD;color:#1C9BDD;padding:0 3px;"> </span><span style="background:#0096DA;color:#0096DA;padding:0 3px;"> </span><span style="background:#0091D5;color:#0091D5;padding:0 3px;"> </span><span style="background:#008CCE;color:#008CCE;padding:0 3px;"> </span><span style="background:#0087C7;color:#0087C7;padding:0 3px;"> </span><span style="background:#0082C0;color:#0082C0;padding:0 3px;"> </span><span style="background:#007DB9;color:#007DB9;padding:0 3px;"> </span><span style="background:#0078B2;color:#0078B2;padding:0 3px;"> </span><span style="background:#0074AC;color:#0074AC;padding:0 3px;"> </span><span style="background:#006FA6;color:#006FA6;padding:0 3px;"> </span><span style="background:#006B9F;color:#006B9F;padding:0 3px;"> </span><span style="background:#006699;color:#006699;padding:0 3px;"> </span><span style="background:#006293;color:#006293;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Lisbon</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E2FCFF;color:#E2FCFF;padding:0 3px;"> </span><span style="background:#DCF7FF;color:#DCF7FF;padding:0 3px;"> </span><span style="background:#D5F2FF;color:#D5F2FF;padding:0 3px;"> </span><span style="background:#CFEDFF;color:#CFEDFF;padding:0 3px;"> </span><span style="background:#C9E8FF;color:#C9E8FF;padding:0 3px;"> </span><span style="background:#C2E3FF;color:#C2E3FF;padding:0 3px;"> </span><span style="background:#BCDEFF;color:#BCDEFF;padding:0 3px;"> </span><span style="background:#B6D9FD;color:#B6D9FD;padding:0 3px;"> </span><span style="background:#AFD4F9;color:#AFD4F9;padding:0 3px;"> </span><span style="background:#A9CFF5;color:#A9CFF5;padding:0 3px;"> </span><span style="background:#A2CAF1;color:#A2CAF1;padding:0 3px;"> </span><span style="background:#9CC5ED;color:#9CC5ED;padding:0 3px;"> </span><span style="background:#95C0E9;color:#95C0E9;padding:0 3px;"> </span><span style="background:#91BBE4;color:#91BBE4;padding:0 3px;"> </span><span style="background:#8DB6DD;color:#8DB6DD;padding:0 3px;"> </span><span style="background:#89B1D7;color:#89B1D7;padding:0 3px;"> </span><span style="background:#85ACD1;color:#85ACD1;padding:0 3px;"> </span><span style="background:#81A7CB;color:#81A7CB;padding:0 3px;"> </span><span style="background:#7EA2C5;color:#7EA2C5;padding:0 3px;"> </span><span style="background:#7A9DBF;color:#7A9DBF;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Cork</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00294D;color:#00294D;padding:0 3px;"> </span><span style="background:#002D51;color:#002D51;padding:0 3px;"> </span><span style="background:#003055;color:#003055;padding:0 3px;"> </span><span style="background:#003459;color:#003459;padding:0 3px;"> </span><span style="background:#00385E;color:#00385E;padding:0 3px;"> </span><span style="background:#003C63;color:#003C63;padding:0 3px;"> </span><span style="background:#004068;color:#004068;padding:0 3px;"> </span><span style="background:#02446D;color:#02446D;padding:0 3px;"> </span><span style="background:#084872;color:#084872;padding:0 3px;"> </span><span style="background:#0F4C77;color:#0F4C77;padding:0 3px;"> </span><span style="background:#14507C;color:#14507C;padding:0 3px;"> </span><span style="background:#195481;color:#195481;padding:0 3px;"> </span><span style="background:#1D5887;color:#1D5887;padding:0 3px;"> </span><span style="background:#215D8C;color:#215D8C;padding:0 3px;"> </span><span style="background:#256192;color:#256192;padding:0 3px;"> </span><span style="background:#286597;color:#286597;padding:0 3px;"> </span><span style="background:#2C699D;color:#2C699D;padding:0 3px;"> </span><span style="background:#316EA2;color:#316EA2;padding:0 3px;"> </span><span style="background:#3A72A4;color:#3A72A4;padding:0 3px;"> </span><span style="background:#4276A7;color:#4276A7;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Filter by type
pal_show(type = "discrete", index = 1:10)
#> <div id="jcxytqrqjj" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jcxytqrqjj table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jcxytqrqjj thead, #jcxytqrqjj tbody, #jcxytqrqjj tfoot, #jcxytqrqjj tr, #jcxytqrqjj td, #jcxytqrqjj th {
#>   border-style: none;
#> }
#> 
#> #jcxytqrqjj p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jcxytqrqjj .gt_table {
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
#> #jcxytqrqjj .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jcxytqrqjj .gt_title {
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
#> #jcxytqrqjj .gt_subtitle {
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
#> #jcxytqrqjj .gt_heading {
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
#> #jcxytqrqjj .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcxytqrqjj .gt_col_headings {
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
#> #jcxytqrqjj .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #jcxytqrqjj .gt_column_spanner_outer {
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
#> #jcxytqrqjj .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jcxytqrqjj .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jcxytqrqjj .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #jcxytqrqjj .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jcxytqrqjj .gt_group_heading {
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
#> #jcxytqrqjj .gt_empty_group_heading {
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
#> #jcxytqrqjj .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jcxytqrqjj .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jcxytqrqjj .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #jcxytqrqjj .gt_stub {
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
#> #jcxytqrqjj .gt_stub_row_group {
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
#> #jcxytqrqjj .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jcxytqrqjj .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jcxytqrqjj .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcxytqrqjj .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jcxytqrqjj .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jcxytqrqjj .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcxytqrqjj .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcxytqrqjj .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jcxytqrqjj .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcxytqrqjj .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #jcxytqrqjj .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jcxytqrqjj .gt_footnotes {
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
#> #jcxytqrqjj .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcxytqrqjj .gt_sourcenotes {
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
#> #jcxytqrqjj .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jcxytqrqjj .gt_left {
#>   text-align: left;
#> }
#> 
#> #jcxytqrqjj .gt_center {
#>   text-align: center;
#> }
#> 
#> #jcxytqrqjj .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jcxytqrqjj .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jcxytqrqjj .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jcxytqrqjj .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jcxytqrqjj .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jcxytqrqjj .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jcxytqrqjj .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jcxytqrqjj .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jcxytqrqjj .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jcxytqrqjj .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jcxytqrqjj .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jcxytqrqjj .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jcxytqrqjj .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jcxytqrqjj div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>10 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">Accent</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7FC97F;color:#7FC97F;padding:0 3px;"> </span><span style="background:#BEAED4;color:#BEAED4;padding:0 3px;"> </span><span style="background:#FDC086;color:#FDC086;padding:0 3px;"> </span><span style="background:#FFFF99;color:#FFFF99;padding:0 3px;"> </span><span style="background:#386CB0;color:#386CB0;padding:0 3px;"> </span><span style="background:#F0027F;color:#F0027F;padding:0 3px;"> </span><span style="background:#BF5B17;color:#BF5B17;padding:0 3px;"> </span><span style="background:#666666;color:#666666;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Dark2</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1B9E77;color:#1B9E77;padding:0 3px;"> </span><span style="background:#D95F02;color:#D95F02;padding:0 3px;"> </span><span style="background:#7570B3;color:#7570B3;padding:0 3px;"> </span><span style="background:#E7298A;color:#E7298A;padding:0 3px;"> </span><span style="background:#66A61E;color:#66A61E;padding:0 3px;"> </span><span style="background:#E6AB02;color:#E6AB02;padding:0 3px;"> </span><span style="background:#A6761D;color:#A6761D;padding:0 3px;"> </span><span style="background:#666666;color:#666666;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Paired</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#A6CEE3;color:#A6CEE3;padding:0 3px;"> </span><span style="background:#1F78B4;color:#1F78B4;padding:0 3px;"> </span><span style="background:#B2DF8A;color:#B2DF8A;padding:0 3px;"> </span><span style="background:#33A02C;color:#33A02C;padding:0 3px;"> </span><span style="background:#FB9A99;color:#FB9A99;padding:0 3px;"> </span><span style="background:#E31A1C;color:#E31A1C;padding:0 3px;"> </span><span style="background:#FDBF6F;color:#FDBF6F;padding:0 3px;"> </span><span style="background:#FF7F00;color:#FF7F00;padding:0 3px;"> </span><span style="background:#CAB2D6;color:#CAB2D6;padding:0 3px;"> </span><span style="background:#6A3D9A;color:#6A3D9A;padding:0 3px;"> </span><span style="background:#FFFF99;color:#FFFF99;padding:0 3px;"> </span><span style="background:#B15928;color:#B15928;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Pastel1</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FBB4AE;color:#FBB4AE;padding:0 3px;"> </span><span style="background:#B3CDE3;color:#B3CDE3;padding:0 3px;"> </span><span style="background:#CCEBC5;color:#CCEBC5;padding:0 3px;"> </span><span style="background:#DECBE4;color:#DECBE4;padding:0 3px;"> </span><span style="background:#FED9A6;color:#FED9A6;padding:0 3px;"> </span><span style="background:#FFFFCC;color:#FFFFCC;padding:0 3px;"> </span><span style="background:#E5D8BD;color:#E5D8BD;padding:0 3px;"> </span><span style="background:#FDDAEC;color:#FDDAEC;padding:0 3px;"> </span><span style="background:#F2F2F2;color:#F2F2F2;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Pastel2</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#B3E2CD;color:#B3E2CD;padding:0 3px;"> </span><span style="background:#FDCDAC;color:#FDCDAC;padding:0 3px;"> </span><span style="background:#CBD5E8;color:#CBD5E8;padding:0 3px;"> </span><span style="background:#F4CAE4;color:#F4CAE4;padding:0 3px;"> </span><span style="background:#E6F5C9;color:#E6F5C9;padding:0 3px;"> </span><span style="background:#FFF2AE;color:#FFF2AE;padding:0 3px;"> </span><span style="background:#F1E2CC;color:#F1E2CC;padding:0 3px;"> </span><span style="background:#CCCCCC;color:#CCCCCC;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Set1</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E41A1C;color:#E41A1C;padding:0 3px;"> </span><span style="background:#377EB8;color:#377EB8;padding:0 3px;"> </span><span style="background:#4DAF4A;color:#4DAF4A;padding:0 3px;"> </span><span style="background:#984EA3;color:#984EA3;padding:0 3px;"> </span><span style="background:#FF7F00;color:#FF7F00;padding:0 3px;"> </span><span style="background:#FFFF33;color:#FFFF33;padding:0 3px;"> </span><span style="background:#A65628;color:#A65628;padding:0 3px;"> </span><span style="background:#F781BF;color:#F781BF;padding:0 3px;"> </span><span style="background:#999999;color:#999999;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Set2</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#66C2A5;color:#66C2A5;padding:0 3px;"> </span><span style="background:#FC8D62;color:#FC8D62;padding:0 3px;"> </span><span style="background:#8DA0CB;color:#8DA0CB;padding:0 3px;"> </span><span style="background:#E78AC3;color:#E78AC3;padding:0 3px;"> </span><span style="background:#A6D854;color:#A6D854;padding:0 3px;"> </span><span style="background:#FFD92F;color:#FFD92F;padding:0 3px;"> </span><span style="background:#E5C494;color:#E5C494;padding:0 3px;"> </span><span style="background:#B3B3B3;color:#B3B3B3;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Set3</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8DD3C7;color:#8DD3C7;padding:0 3px;"> </span><span style="background:#FFFFB3;color:#FFFFB3;padding:0 3px;"> </span><span style="background:#BEBADA;color:#BEBADA;padding:0 3px;"> </span><span style="background:#FB8072;color:#FB8072;padding:0 3px;"> </span><span style="background:#80B1D3;color:#80B1D3;padding:0 3px;"> </span><span style="background:#FDB462;color:#FDB462;padding:0 3px;"> </span><span style="background:#B3DE69;color:#B3DE69;padding:0 3px;"> </span><span style="background:#FCCDE5;color:#FCCDE5;padding:0 3px;"> </span><span style="background:#D9D9D9;color:#D9D9D9;padding:0 3px;"> </span><span style="background:#BC80BD;color:#BC80BD;padding:0 3px;"> </span><span style="background:#CCEBC5;color:#CCEBC5;padding:0 3px;"> </span><span style="background:#FFED6F;color:#FFED6F;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_npg_nrc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E64B35;color:#E64B35;padding:0 3px;"> </span><span style="background:#4DBBD5;color:#4DBBD5;padding:0 3px;"> </span><span style="background:#00A087;color:#00A087;padding:0 3px;"> </span><span style="background:#3C5488;color:#3C5488;padding:0 3px;"> </span><span style="background:#F39B7F;color:#F39B7F;padding:0 3px;"> </span><span style="background:#8491B4;color:#8491B4;padding:0 3px;"> </span><span style="background:#91D1C2;color:#91D1C2;padding:0 3px;"> </span><span style="background:#DC0000;color:#DC0000;padding:0 3px;"> </span><span style="background:#7E6148;color:#7E6148;padding:0 3px;"> </span><span style="background:#B09C85;color:#B09C85;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_aaas_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#3B4992;color:#3B4992;padding:0 3px;"> </span><span style="background:#EE0000;color:#EE0000;padding:0 3px;"> </span><span style="background:#008B45;color:#008B45;padding:0 3px;"> </span><span style="background:#631879;color:#631879;padding:0 3px;"> </span><span style="background:#008280;color:#008280;padding:0 3px;"> </span><span style="background:#BB0021;color:#BB0021;padding:0 3px;"> </span><span style="background:#5F559B;color:#5F559B;padding:0 3px;"> </span><span style="background:#A20056;color:#A20056;padding:0 3px;"> </span><span style="background:#808180;color:#808180;padding:0 3px;"> </span><span style="background:#1B1919;color:#1B1919;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(type = "continuous", index = 1:10)
#> <div id="swkvrtkjem" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#swkvrtkjem table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #swkvrtkjem thead, #swkvrtkjem tbody, #swkvrtkjem tfoot, #swkvrtkjem tr, #swkvrtkjem td, #swkvrtkjem th {
#>   border-style: none;
#> }
#> 
#> #swkvrtkjem p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #swkvrtkjem .gt_table {
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
#> #swkvrtkjem .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #swkvrtkjem .gt_title {
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
#> #swkvrtkjem .gt_subtitle {
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
#> #swkvrtkjem .gt_heading {
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
#> #swkvrtkjem .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #swkvrtkjem .gt_col_headings {
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
#> #swkvrtkjem .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #swkvrtkjem .gt_column_spanner_outer {
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
#> #swkvrtkjem .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #swkvrtkjem .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #swkvrtkjem .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #swkvrtkjem .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #swkvrtkjem .gt_group_heading {
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
#> #swkvrtkjem .gt_empty_group_heading {
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
#> #swkvrtkjem .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #swkvrtkjem .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #swkvrtkjem .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #swkvrtkjem .gt_stub {
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
#> #swkvrtkjem .gt_stub_row_group {
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
#> #swkvrtkjem .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #swkvrtkjem .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #swkvrtkjem .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #swkvrtkjem .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #swkvrtkjem .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #swkvrtkjem .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #swkvrtkjem .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #swkvrtkjem .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #swkvrtkjem .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #swkvrtkjem .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #swkvrtkjem .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #swkvrtkjem .gt_footnotes {
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
#> #swkvrtkjem .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #swkvrtkjem .gt_sourcenotes {
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
#> #swkvrtkjem .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #swkvrtkjem .gt_left {
#>   text-align: left;
#> }
#> 
#> #swkvrtkjem .gt_center {
#>   text-align: center;
#> }
#> 
#> #swkvrtkjem .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #swkvrtkjem .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #swkvrtkjem .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #swkvrtkjem .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #swkvrtkjem .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #swkvrtkjem .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #swkvrtkjem .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #swkvrtkjem .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #swkvrtkjem .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #swkvrtkjem .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #swkvrtkjem .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #swkvrtkjem .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #swkvrtkjem .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #swkvrtkjem div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>10 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">BrBG</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#543005;color:#543005;padding:0 3px;"> </span><span style="background:#8C510A;color:#8C510A;padding:0 3px;"> </span><span style="background:#BF812D;color:#BF812D;padding:0 3px;"> </span><span style="background:#DFC27D;color:#DFC27D;padding:0 3px;"> </span><span style="background:#F6E8C3;color:#F6E8C3;padding:0 3px;"> </span><span style="background:#F5F5F5;color:#F5F5F5;padding:0 3px;"> </span><span style="background:#C7EAE5;color:#C7EAE5;padding:0 3px;"> </span><span style="background:#80CDC1;color:#80CDC1;padding:0 3px;"> </span><span style="background:#35978F;color:#35978F;padding:0 3px;"> </span><span style="background:#01665E;color:#01665E;padding:0 3px;"> </span><span style="background:#003C30;color:#003C30;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">PiYG</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8E0152;color:#8E0152;padding:0 3px;"> </span><span style="background:#C51B7D;color:#C51B7D;padding:0 3px;"> </span><span style="background:#DE77AE;color:#DE77AE;padding:0 3px;"> </span><span style="background:#F1B6DA;color:#F1B6DA;padding:0 3px;"> </span><span style="background:#FDE0EF;color:#FDE0EF;padding:0 3px;"> </span><span style="background:#F7F7F7;color:#F7F7F7;padding:0 3px;"> </span><span style="background:#E6F5D0;color:#E6F5D0;padding:0 3px;"> </span><span style="background:#B8E186;color:#B8E186;padding:0 3px;"> </span><span style="background:#7FBC41;color:#7FBC41;padding:0 3px;"> </span><span style="background:#4D9221;color:#4D9221;padding:0 3px;"> </span><span style="background:#276419;color:#276419;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">PRGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#40004B;color:#40004B;padding:0 3px;"> </span><span style="background:#762A83;color:#762A83;padding:0 3px;"> </span><span style="background:#9970AB;color:#9970AB;padding:0 3px;"> </span><span style="background:#C2A5CF;color:#C2A5CF;padding:0 3px;"> </span><span style="background:#E7D4E8;color:#E7D4E8;padding:0 3px;"> </span><span style="background:#F7F7F7;color:#F7F7F7;padding:0 3px;"> </span><span style="background:#D9F0D3;color:#D9F0D3;padding:0 3px;"> </span><span style="background:#A6DBA0;color:#A6DBA0;padding:0 3px;"> </span><span style="background:#5AAE61;color:#5AAE61;padding:0 3px;"> </span><span style="background:#1B7837;color:#1B7837;padding:0 3px;"> </span><span style="background:#00441B;color:#00441B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">PuOr</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7F3B08;color:#7F3B08;padding:0 3px;"> </span><span style="background:#B35806;color:#B35806;padding:0 3px;"> </span><span style="background:#E08214;color:#E08214;padding:0 3px;"> </span><span style="background:#FDB863;color:#FDB863;padding:0 3px;"> </span><span style="background:#FEE0B6;color:#FEE0B6;padding:0 3px;"> </span><span style="background:#F7F7F7;color:#F7F7F7;padding:0 3px;"> </span><span style="background:#D8DAEB;color:#D8DAEB;padding:0 3px;"> </span><span style="background:#B2ABD2;color:#B2ABD2;padding:0 3px;"> </span><span style="background:#8073AC;color:#8073AC;padding:0 3px;"> </span><span style="background:#542788;color:#542788;padding:0 3px;"> </span><span style="background:#2D004B;color:#2D004B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#67001F;color:#67001F;padding:0 3px;"> </span><span style="background:#B2182B;color:#B2182B;padding:0 3px;"> </span><span style="background:#D6604D;color:#D6604D;padding:0 3px;"> </span><span style="background:#F4A582;color:#F4A582;padding:0 3px;"> </span><span style="background:#FDDBC7;color:#FDDBC7;padding:0 3px;"> </span><span style="background:#F7F7F7;color:#F7F7F7;padding:0 3px;"> </span><span style="background:#D1E5F0;color:#D1E5F0;padding:0 3px;"> </span><span style="background:#92C5DE;color:#92C5DE;padding:0 3px;"> </span><span style="background:#4393C3;color:#4393C3;padding:0 3px;"> </span><span style="background:#2166AC;color:#2166AC;padding:0 3px;"> </span><span style="background:#053061;color:#053061;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdGy</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#67001F;color:#67001F;padding:0 3px;"> </span><span style="background:#B2182B;color:#B2182B;padding:0 3px;"> </span><span style="background:#D6604D;color:#D6604D;padding:0 3px;"> </span><span style="background:#F4A582;color:#F4A582;padding:0 3px;"> </span><span style="background:#FDDBC7;color:#FDDBC7;padding:0 3px;"> </span><span style="background:#FFFFFF;color:#FFFFFF;padding:0 3px;"> </span><span style="background:#E0E0E0;color:#E0E0E0;padding:0 3px;"> </span><span style="background:#BABABA;color:#BABABA;padding:0 3px;"> </span><span style="background:#878787;color:#878787;padding:0 3px;"> </span><span style="background:#4D4D4D;color:#4D4D4D;padding:0 3px;"> </span><span style="background:#1A1A1A;color:#1A1A1A;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdYlBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#A50026;color:#A50026;padding:0 3px;"> </span><span style="background:#D73027;color:#D73027;padding:0 3px;"> </span><span style="background:#F46D43;color:#F46D43;padding:0 3px;"> </span><span style="background:#FDAE61;color:#FDAE61;padding:0 3px;"> </span><span style="background:#FEE090;color:#FEE090;padding:0 3px;"> </span><span style="background:#FFFFBF;color:#FFFFBF;padding:0 3px;"> </span><span style="background:#E0F3F8;color:#E0F3F8;padding:0 3px;"> </span><span style="background:#ABD9E9;color:#ABD9E9;padding:0 3px;"> </span><span style="background:#74ADD1;color:#74ADD1;padding:0 3px;"> </span><span style="background:#4575B4;color:#4575B4;padding:0 3px;"> </span><span style="background:#313695;color:#313695;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdYlGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#A50026;color:#A50026;padding:0 3px;"> </span><span style="background:#D73027;color:#D73027;padding:0 3px;"> </span><span style="background:#F46D43;color:#F46D43;padding:0 3px;"> </span><span style="background:#FDAE61;color:#FDAE61;padding:0 3px;"> </span><span style="background:#FEE08B;color:#FEE08B;padding:0 3px;"> </span><span style="background:#FFFFBF;color:#FFFFBF;padding:0 3px;"> </span><span style="background:#D9EF8B;color:#D9EF8B;padding:0 3px;"> </span><span style="background:#A6D96A;color:#A6D96A;padding:0 3px;"> </span><span style="background:#66BD63;color:#66BD63;padding:0 3px;"> </span><span style="background:#1A9850;color:#1A9850;padding:0 3px;"> </span><span style="background:#006837;color:#006837;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Spectral</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#9E0142;color:#9E0142;padding:0 3px;"> </span><span style="background:#D53E4F;color:#D53E4F;padding:0 3px;"> </span><span style="background:#F46D43;color:#F46D43;padding:0 3px;"> </span><span style="background:#FDAE61;color:#FDAE61;padding:0 3px;"> </span><span style="background:#FEE08B;color:#FEE08B;padding:0 3px;"> </span><span style="background:#FFFFBF;color:#FFFFBF;padding:0 3px;"> </span><span style="background:#E6F598;color:#E6F598;padding:0 3px;"> </span><span style="background:#ABDDA4;color:#ABDDA4;padding:0 3px;"> </span><span style="background:#66C2A5;color:#66C2A5;padding:0 3px;"> </span><span style="background:#3288BD;color:#3288BD;padding:0 3px;"> </span><span style="background:#5E4FA2;color:#5E4FA2;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F7FBFF;color:#F7FBFF;padding:0 3px;"> </span><span style="background:#DEEBF7;color:#DEEBF7;padding:0 3px;"> </span><span style="background:#C6DBEF;color:#C6DBEF;padding:0 3px;"> </span><span style="background:#9ECAE1;color:#9ECAE1;padding:0 3px;"> </span><span style="background:#6BAED6;color:#6BAED6;padding:0 3px;"> </span><span style="background:#4292C6;color:#4292C6;padding:0 3px;"> </span><span style="background:#2171B5;color:#2171B5;padding:0 3px;"> </span><span style="background:#08519C;color:#08519C;padding:0 3px;"> </span><span style="background:#08306B;color:#08306B;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Combine filters
pal_show(pattern = "Blues", type = "continuous")
#> <div id="oosmtwwycj" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#oosmtwwycj table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #oosmtwwycj thead, #oosmtwwycj tbody, #oosmtwwycj tfoot, #oosmtwwycj tr, #oosmtwwycj td, #oosmtwwycj th {
#>   border-style: none;
#> }
#> 
#> #oosmtwwycj p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #oosmtwwycj .gt_table {
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
#> #oosmtwwycj .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #oosmtwwycj .gt_title {
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
#> #oosmtwwycj .gt_subtitle {
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
#> #oosmtwwycj .gt_heading {
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
#> #oosmtwwycj .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #oosmtwwycj .gt_col_headings {
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
#> #oosmtwwycj .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #oosmtwwycj .gt_column_spanner_outer {
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
#> #oosmtwwycj .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #oosmtwwycj .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #oosmtwwycj .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #oosmtwwycj .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #oosmtwwycj .gt_group_heading {
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
#> #oosmtwwycj .gt_empty_group_heading {
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
#> #oosmtwwycj .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #oosmtwwycj .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #oosmtwwycj .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #oosmtwwycj .gt_stub {
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
#> #oosmtwwycj .gt_stub_row_group {
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
#> #oosmtwwycj .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #oosmtwwycj .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #oosmtwwycj .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #oosmtwwycj .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #oosmtwwycj .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #oosmtwwycj .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #oosmtwwycj .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #oosmtwwycj .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #oosmtwwycj .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #oosmtwwycj .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #oosmtwwycj .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #oosmtwwycj .gt_footnotes {
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
#> #oosmtwwycj .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #oosmtwwycj .gt_sourcenotes {
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
#> #oosmtwwycj .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #oosmtwwycj .gt_left {
#>   text-align: left;
#> }
#> 
#> #oosmtwwycj .gt_center {
#>   text-align: center;
#> }
#> 
#> #oosmtwwycj .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #oosmtwwycj .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #oosmtwwycj .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #oosmtwwycj .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #oosmtwwycj .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #oosmtwwycj .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #oosmtwwycj .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #oosmtwwycj .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #oosmtwwycj .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #oosmtwwycj .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #oosmtwwycj .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #oosmtwwycj .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #oosmtwwycj .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #oosmtwwycj div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>4 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F7FBFF;color:#F7FBFF;padding:0 3px;"> </span><span style="background:#DEEBF7;color:#DEEBF7;padding:0 3px;"> </span><span style="background:#C6DBEF;color:#C6DBEF;padding:0 3px;"> </span><span style="background:#9ECAE1;color:#9ECAE1;padding:0 3px;"> </span><span style="background:#6BAED6;color:#6BAED6;padding:0 3px;"> </span><span style="background:#4292C6;color:#4292C6;padding:0 3px;"> </span><span style="background:#2171B5;color:#2171B5;padding:0 3px;"> </span><span style="background:#08519C;color:#08519C;padding:0 3px;"> </span><span style="background:#08306B;color:#08306B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#273871;color:#273871;padding:0 3px;"> </span><span style="background:#283A74;color:#283A74;padding:0 3px;"> </span><span style="background:#293C76;color:#293C76;padding:0 3px;"> </span><span style="background:#2A3F79;color:#2A3F79;padding:0 3px;"> </span><span style="background:#2B417C;color:#2B417C;padding:0 3px;"> </span><span style="background:#2C437F;color:#2C437F;padding:0 3px;"> </span><span style="background:#2D4682;color:#2D4682;padding:0 3px;"> </span><span style="background:#2D4885;color:#2D4885;padding:0 3px;"> </span><span style="background:#2E4B88;color:#2E4B88;padding:0 3px;"> </span><span style="background:#2F4D8B;color:#2F4D8B;padding:0 3px;"> </span><span style="background:#2F4F8F;color:#2F4F8F;padding:0 3px;"> </span><span style="background:#305292;color:#305292;padding:0 3px;"> </span><span style="background:#305495;color:#305495;padding:0 3px;"> </span><span style="background:#315798;color:#315798;padding:0 3px;"> </span><span style="background:#31599B;color:#31599B;padding:0 3px;"> </span><span style="background:#315B9E;color:#315B9E;padding:0 3px;"> </span><span style="background:#325EA1;color:#325EA1;padding:0 3px;"> </span><span style="background:#3260A4;color:#3260A4;padding:0 3px;"> </span><span style="background:#3263A7;color:#3263A7;padding:0 3px;"> </span><span style="background:#3265AA;color:#3265AA;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#023FA5;color:#023FA5;padding:0 3px;"> </span><span style="background:#1141A4;color:#1141A4;padding:0 3px;"> </span><span style="background:#1A44A4;color:#1A44A4;padding:0 3px;"> </span><span style="background:#2146A4;color:#2146A4;padding:0 3px;"> </span><span style="background:#2749A4;color:#2749A4;padding:0 3px;"> </span><span style="background:#2C4BA4;color:#2C4BA4;padding:0 3px;"> </span><span style="background:#314DA4;color:#314DA4;padding:0 3px;"> </span><span style="background:#3550A5;color:#3550A5;padding:0 3px;"> </span><span style="background:#3952A5;color:#3952A5;padding:0 3px;"> </span><span style="background:#3C54A6;color:#3C54A6;padding:0 3px;"> </span><span style="background:#4056A6;color:#4056A6;padding:0 3px;"> </span><span style="background:#4359A7;color:#4359A7;padding:0 3px;"> </span><span style="background:#465BA8;color:#465BA8;padding:0 3px;"> </span><span style="background:#4A5DA8;color:#4A5DA8;padding:0 3px;"> </span><span style="background:#4D5FA9;color:#4D5FA9;padding:0 3px;"> </span><span style="background:#5062AA;color:#5062AA;padding:0 3px;"> </span><span style="background:#5264AA;color:#5264AA;padding:0 3px;"> </span><span style="background:#5566AB;color:#5566AB;padding:0 3px;"> </span><span style="background:#5868AC;color:#5868AC;padding:0 3px;"> </span><span style="background:#5B6AAD;color:#5B6AAD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00366C;color:#00366C;padding:0 3px;"> </span><span style="background:#00386E;color:#00386E;padding:0 3px;"> </span><span style="background:#003A71;color:#003A71;padding:0 3px;"> </span><span style="background:#003D73;color:#003D73;padding:0 3px;"> </span><span style="background:#003F76;color:#003F76;padding:0 3px;"> </span><span style="background:#004178;color:#004178;padding:0 3px;"> </span><span style="background:#00447B;color:#00447B;padding:0 3px;"> </span><span style="background:#00467E;color:#00467E;padding:0 3px;"> </span><span style="background:#004981;color:#004981;padding:0 3px;"> </span><span style="background:#004B84;color:#004B84;padding:0 3px;"> </span><span style="background:#004D87;color:#004D87;padding:0 3px;"> </span><span style="background:#005089;color:#005089;padding:0 3px;"> </span><span style="background:#00528C;color:#00528C;padding:0 3px;"> </span><span style="background:#00558F;color:#00558F;padding:0 3px;"> </span><span style="background:#005793;color:#005793;padding:0 3px;"> </span><span style="background:#005A96;color:#005A96;padding:0 3px;"> </span><span style="background:#005C99;color:#005C99;padding:0 3px;"> </span><span style="background:#005F9C;color:#005F9C;padding:0 3px;"> </span><span style="background:#00619F;color:#00619F;padding:0 3px;"> </span><span style="background:#0064A2;color:#0064A2;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "^carto", type = "discrete")
#> <div id="aotlopqqaq" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#aotlopqqaq table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #aotlopqqaq thead, #aotlopqqaq tbody, #aotlopqqaq tfoot, #aotlopqqaq tr, #aotlopqqaq td, #aotlopqqaq th {
#>   border-style: none;
#> }
#> 
#> #aotlopqqaq p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #aotlopqqaq .gt_table {
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
#> #aotlopqqaq .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #aotlopqqaq .gt_title {
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
#> #aotlopqqaq .gt_subtitle {
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
#> #aotlopqqaq .gt_heading {
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
#> #aotlopqqaq .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aotlopqqaq .gt_col_headings {
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
#> #aotlopqqaq .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #aotlopqqaq .gt_column_spanner_outer {
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
#> #aotlopqqaq .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #aotlopqqaq .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #aotlopqqaq .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #aotlopqqaq .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #aotlopqqaq .gt_group_heading {
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
#> #aotlopqqaq .gt_empty_group_heading {
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
#> #aotlopqqaq .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #aotlopqqaq .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #aotlopqqaq .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #aotlopqqaq .gt_stub {
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
#> #aotlopqqaq .gt_stub_row_group {
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
#> #aotlopqqaq .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #aotlopqqaq .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #aotlopqqaq .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aotlopqqaq .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #aotlopqqaq .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #aotlopqqaq .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aotlopqqaq .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aotlopqqaq .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #aotlopqqaq .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aotlopqqaq .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #aotlopqqaq .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #aotlopqqaq .gt_footnotes {
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
#> #aotlopqqaq .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aotlopqqaq .gt_sourcenotes {
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
#> #aotlopqqaq .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #aotlopqqaq .gt_left {
#>   text-align: left;
#> }
#> 
#> #aotlopqqaq .gt_center {
#>   text-align: center;
#> }
#> 
#> #aotlopqqaq .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #aotlopqqaq .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #aotlopqqaq .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #aotlopqqaq .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #aotlopqqaq .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #aotlopqqaq .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #aotlopqqaq .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #aotlopqqaq .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #aotlopqqaq .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #aotlopqqaq .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #aotlopqqaq .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #aotlopqqaq .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #aotlopqqaq .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #aotlopqqaq div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>6 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Antique</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#855C75;color:#855C75;padding:0 3px;"> </span><span style="background:#D9AF6B;color:#D9AF6B;padding:0 3px;"> </span><span style="background:#AF6458;color:#AF6458;padding:0 3px;"> </span><span style="background:#736F4C;color:#736F4C;padding:0 3px;"> </span><span style="background:#526A83;color:#526A83;padding:0 3px;"> </span><span style="background:#625377;color:#625377;padding:0 3px;"> </span><span style="background:#68855C;color:#68855C;padding:0 3px;"> </span><span style="background:#9C9C5E;color:#9C9C5E;padding:0 3px;"> </span><span style="background:#A06177;color:#A06177;padding:0 3px;"> </span><span style="background:#8C785D;color:#8C785D;padding:0 3px;"> </span><span style="background:#467378;color:#467378;padding:0 3px;"> </span><span style="background:#7C7C7C;color:#7C7C7C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Bold</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7F3C8D;color:#7F3C8D;padding:0 3px;"> </span><span style="background:#11A579;color:#11A579;padding:0 3px;"> </span><span style="background:#3969AC;color:#3969AC;padding:0 3px;"> </span><span style="background:#F2B701;color:#F2B701;padding:0 3px;"> </span><span style="background:#E73F74;color:#E73F74;padding:0 3px;"> </span><span style="background:#80BA5A;color:#80BA5A;padding:0 3px;"> </span><span style="background:#E68310;color:#E68310;padding:0 3px;"> </span><span style="background:#008695;color:#008695;padding:0 3px;"> </span><span style="background:#CF1C90;color:#CF1C90;padding:0 3px;"> </span><span style="background:#F97B72;color:#F97B72;padding:0 3px;"> </span><span style="background:#4B4B8F;color:#4B4B8F;padding:0 3px;"> </span><span style="background:#A5AA99;color:#A5AA99;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Pastel</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#66C5CC;color:#66C5CC;padding:0 3px;"> </span><span style="background:#F6CF71;color:#F6CF71;padding:0 3px;"> </span><span style="background:#F89C74;color:#F89C74;padding:0 3px;"> </span><span style="background:#DCB0F2;color:#DCB0F2;padding:0 3px;"> </span><span style="background:#87C55F;color:#87C55F;padding:0 3px;"> </span><span style="background:#9EB9F3;color:#9EB9F3;padding:0 3px;"> </span><span style="background:#FE88B1;color:#FE88B1;padding:0 3px;"> </span><span style="background:#C9DB74;color:#C9DB74;padding:0 3px;"> </span><span style="background:#8BE0A4;color:#8BE0A4;padding:0 3px;"> </span><span style="background:#B497E7;color:#B497E7;padding:0 3px;"> </span><span style="background:#D3B484;color:#D3B484;padding:0 3px;"> </span><span style="background:#B3B3B3;color:#B3B3B3;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Prism</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#5F4690;color:#5F4690;padding:0 3px;"> </span><span style="background:#1D6996;color:#1D6996;padding:0 3px;"> </span><span style="background:#38A6A5;color:#38A6A5;padding:0 3px;"> </span><span style="background:#0F8554;color:#0F8554;padding:0 3px;"> </span><span style="background:#73AF48;color:#73AF48;padding:0 3px;"> </span><span style="background:#EDAD08;color:#EDAD08;padding:0 3px;"> </span><span style="background:#E17C05;color:#E17C05;padding:0 3px;"> </span><span style="background:#CC503E;color:#CC503E;padding:0 3px;"> </span><span style="background:#94346E;color:#94346E;padding:0 3px;"> </span><span style="background:#6F4070;color:#6F4070;padding:0 3px;"> </span><span style="background:#994E95;color:#994E95;padding:0 3px;"> </span><span style="background:#666666;color:#666666;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Safe</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#88CCEE;color:#88CCEE;padding:0 3px;"> </span><span style="background:#CC6677;color:#CC6677;padding:0 3px;"> </span><span style="background:#DDCC77;color:#DDCC77;padding:0 3px;"> </span><span style="background:#117733;color:#117733;padding:0 3px;"> </span><span style="background:#332288;color:#332288;padding:0 3px;"> </span><span style="background:#AA4499;color:#AA4499;padding:0 3px;"> </span><span style="background:#44AA99;color:#44AA99;padding:0 3px;"> </span><span style="background:#999933;color:#999933;padding:0 3px;"> </span><span style="background:#882255;color:#882255;padding:0 3px;"> </span><span style="background:#661100;color:#661100;padding:0 3px;"> </span><span style="background:#6699CC;color:#6699CC;padding:0 3px;"> </span><span style="background:#888888;color:#888888;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Vivid</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E58606;color:#E58606;padding:0 3px;"> </span><span style="background:#5D69B1;color:#5D69B1;padding:0 3px;"> </span><span style="background:#52BCA3;color:#52BCA3;padding:0 3px;"> </span><span style="background:#99C945;color:#99C945;padding:0 3px;"> </span><span style="background:#CC61B0;color:#CC61B0;padding:0 3px;"> </span><span style="background:#24796C;color:#24796C;padding:0 3px;"> </span><span style="background:#DAA51B;color:#DAA51B;padding:0 3px;"> </span><span style="background:#2F8AC4;color:#2F8AC4;padding:0 3px;"> </span><span style="background:#764E9F;color:#764E9F;padding:0 3px;"> </span><span style="background:#ED645A;color:#ED645A;padding:0 3px;"> </span><span style="background:#CC3A8E;color:#CC3A8E;padding:0 3px;"> </span><span style="background:#A5AA99;color:#A5AA99;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# ggplot output (colour bars in Plots pane)
pal_show(c("lancet", "ditto", "polychrome", "igv"), output = "gg")

pal_show(pattern = "^viridis|^magma|^plasma", output = "gg")


# --- Colour vector mode ---
# Show a named colour vector (e.g. pal_paraSC)
pal_show(pal_paraSC)
#> <div id="wfjzfkajzc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#wfjzfkajzc table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #wfjzfkajzc thead, #wfjzfkajzc tbody, #wfjzfkajzc tfoot, #wfjzfkajzc tr, #wfjzfkajzc td, #wfjzfkajzc th {
#>   border-style: none;
#> }
#> 
#> #wfjzfkajzc p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #wfjzfkajzc .gt_table {
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
#> #wfjzfkajzc .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #wfjzfkajzc .gt_title {
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
#> #wfjzfkajzc .gt_subtitle {
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
#> #wfjzfkajzc .gt_heading {
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
#> #wfjzfkajzc .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #wfjzfkajzc .gt_col_headings {
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
#> #wfjzfkajzc .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #wfjzfkajzc .gt_column_spanner_outer {
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
#> #wfjzfkajzc .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #wfjzfkajzc .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #wfjzfkajzc .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #wfjzfkajzc .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #wfjzfkajzc .gt_group_heading {
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
#> #wfjzfkajzc .gt_empty_group_heading {
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
#> #wfjzfkajzc .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #wfjzfkajzc .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #wfjzfkajzc .gt_row {
#>   padding-top: 3px;
#>   padding-bottom: 3px;
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
#> #wfjzfkajzc .gt_stub {
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
#> #wfjzfkajzc .gt_stub_row_group {
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
#> #wfjzfkajzc .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #wfjzfkajzc .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #wfjzfkajzc .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #wfjzfkajzc .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #wfjzfkajzc .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #wfjzfkajzc .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #wfjzfkajzc .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #wfjzfkajzc .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #wfjzfkajzc .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #wfjzfkajzc .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #wfjzfkajzc .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #wfjzfkajzc .gt_footnotes {
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
#> #wfjzfkajzc .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #wfjzfkajzc .gt_sourcenotes {
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
#> #wfjzfkajzc .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #wfjzfkajzc .gt_left {
#>   text-align: left;
#> }
#> 
#> #wfjzfkajzc .gt_center {
#>   text-align: center;
#> }
#> 
#> #wfjzfkajzc .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #wfjzfkajzc .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #wfjzfkajzc .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #wfjzfkajzc .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #wfjzfkajzc .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #wfjzfkajzc .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #wfjzfkajzc .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #wfjzfkajzc .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #wfjzfkajzc .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #wfjzfkajzc .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #wfjzfkajzc .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #wfjzfkajzc .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #wfjzfkajzc .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #wfjzfkajzc div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>16 Colours</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="index">#</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="name">Name</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="hex">Hex</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Preview</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="index" class="gt_row gt_right">1</td>
#> <td headers="name" class="gt_row gt_left">Parathyroid cells</td>
#> <td headers="hex" class="gt_row gt_left">#8B1A1A</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8B1A1A;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#8B1A1A</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">2</td>
#> <td headers="name" class="gt_row gt_left">T cells</td>
#> <td headers="hex" class="gt_row gt_left">#56B4E9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#56B4E9;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#56B4E9</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">3</td>
#> <td headers="name" class="gt_row gt_left">Cycling T cells</td>
#> <td headers="hex" class="gt_row gt_left">#8B5E3C</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8B5E3C;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#8B5E3C</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">4</td>
#> <td headers="name" class="gt_row gt_left">NK cells</td>
#> <td headers="hex" class="gt_row gt_left">#2E8B45</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2E8B45;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#2E8B45</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">5</td>
#> <td headers="name" class="gt_row gt_left">B cells</td>
#> <td headers="hex" class="gt_row gt_left">#1A7B7B</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1A7B7B;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#1A7B7B</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">6</td>
#> <td headers="name" class="gt_row gt_left">Monocytes</td>
#> <td headers="hex" class="gt_row gt_left">#7B68AA</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#7B68AA;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#7B68AA</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">7</td>
#> <td headers="name" class="gt_row gt_left">M1-like Macrophages</td>
#> <td headers="hex" class="gt_row gt_left">#D4919A</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#D4919A;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#D4919A</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">8</td>
#> <td headers="name" class="gt_row gt_left">M2/M3-like Macrophages</td>
#> <td headers="hex" class="gt_row gt_left">#F0C8A0</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F0C8A0;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#F0C8A0</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">9</td>
#> <td headers="name" class="gt_row gt_left">Neutrophils</td>
#> <td headers="hex" class="gt_row gt_left">#C0C0C0</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#C0C0C0;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#C0C0C0</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">10</td>
#> <td headers="name" class="gt_row gt_left">cDC2s</td>
#> <td headers="hex" class="gt_row gt_left">#282828</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#282828;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#282828</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">11</td>
#> <td headers="name" class="gt_row gt_left">Mast cells</td>
#> <td headers="hex" class="gt_row gt_left">#F0E442</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F0E442;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#F0E442</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">12</td>
#> <td headers="name" class="gt_row gt_left">iTAFs</td>
#> <td headers="hex" class="gt_row gt_left">#9AB83C</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#9AB83C;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#9AB83C</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">13</td>
#> <td headers="name" class="gt_row gt_left">mTAFs</td>
#> <td headers="hex" class="gt_row gt_left">#E07B1A</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E07B1A;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#E07B1A</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">14</td>
#> <td headers="name" class="gt_row gt_left">Pericytes</td>
#> <td headers="hex" class="gt_row gt_left">#6B3FA0</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#6B3FA0;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#6B3FA0</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">15</td>
#> <td headers="name" class="gt_row gt_left">Capillary ECs</td>
#> <td headers="hex" class="gt_row gt_left">#D4C8E8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#D4C8E8;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#D4C8E8</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">16</td>
#> <td headers="name" class="gt_row gt_left">Venous ECs</td>
#> <td headers="hex" class="gt_row gt_left">#8AAAC8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8AAAC8;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#8AAAC8</span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Show any colour vector
pal_show(c("#FF0000", "#00FF00", "#0000FF"))
#> <div id="qglklkemuu" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#qglklkemuu table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #qglklkemuu thead, #qglklkemuu tbody, #qglklkemuu tfoot, #qglklkemuu tr, #qglklkemuu td, #qglklkemuu th {
#>   border-style: none;
#> }
#> 
#> #qglklkemuu p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #qglklkemuu .gt_table {
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
#> #qglklkemuu .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #qglklkemuu .gt_title {
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
#> #qglklkemuu .gt_subtitle {
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
#> #qglklkemuu .gt_heading {
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
#> #qglklkemuu .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qglklkemuu .gt_col_headings {
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
#> #qglklkemuu .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #qglklkemuu .gt_column_spanner_outer {
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
#> #qglklkemuu .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #qglklkemuu .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #qglklkemuu .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #qglklkemuu .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #qglklkemuu .gt_group_heading {
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
#> #qglklkemuu .gt_empty_group_heading {
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
#> #qglklkemuu .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #qglklkemuu .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #qglklkemuu .gt_row {
#>   padding-top: 3px;
#>   padding-bottom: 3px;
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
#> #qglklkemuu .gt_stub {
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
#> #qglklkemuu .gt_stub_row_group {
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
#> #qglklkemuu .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #qglklkemuu .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #qglklkemuu .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qglklkemuu .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qglklkemuu .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #qglklkemuu .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qglklkemuu .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qglklkemuu .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qglklkemuu .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qglklkemuu .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #qglklkemuu .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qglklkemuu .gt_footnotes {
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
#> #qglklkemuu .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qglklkemuu .gt_sourcenotes {
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
#> #qglklkemuu .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qglklkemuu .gt_left {
#>   text-align: left;
#> }
#> 
#> #qglklkemuu .gt_center {
#>   text-align: center;
#> }
#> 
#> #qglklkemuu .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #qglklkemuu .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #qglklkemuu .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #qglklkemuu .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #qglklkemuu .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #qglklkemuu .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #qglklkemuu .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #qglklkemuu .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #qglklkemuu .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #qglklkemuu .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #qglklkemuu .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #qglklkemuu .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #qglklkemuu .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #qglklkemuu div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="3" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>3 Colours</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="index">#</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="hex">Hex</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Preview</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="index" class="gt_row gt_right">1</td>
#> <td headers="hex" class="gt_row gt_left">#FF0000</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF0000;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FF0000</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">2</td>
#> <td headers="hex" class="gt_row gt_left">#00FF00</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00FF00;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#00FF00</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">3</td>
#> <td headers="hex" class="gt_row gt_left">#0000FF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0000FF;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#0000FF</span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(rainbow(12))
#> <div id="lygoibnulr" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#lygoibnulr table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #lygoibnulr thead, #lygoibnulr tbody, #lygoibnulr tfoot, #lygoibnulr tr, #lygoibnulr td, #lygoibnulr th {
#>   border-style: none;
#> }
#> 
#> #lygoibnulr p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #lygoibnulr .gt_table {
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
#> #lygoibnulr .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #lygoibnulr .gt_title {
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
#> #lygoibnulr .gt_subtitle {
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
#> #lygoibnulr .gt_heading {
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
#> #lygoibnulr .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #lygoibnulr .gt_col_headings {
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
#> #lygoibnulr .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #lygoibnulr .gt_column_spanner_outer {
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
#> #lygoibnulr .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #lygoibnulr .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #lygoibnulr .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #lygoibnulr .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #lygoibnulr .gt_group_heading {
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
#> #lygoibnulr .gt_empty_group_heading {
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
#> #lygoibnulr .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #lygoibnulr .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #lygoibnulr .gt_row {
#>   padding-top: 3px;
#>   padding-bottom: 3px;
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
#> #lygoibnulr .gt_stub {
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
#> #lygoibnulr .gt_stub_row_group {
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
#> #lygoibnulr .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #lygoibnulr .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #lygoibnulr .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #lygoibnulr .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #lygoibnulr .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #lygoibnulr .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #lygoibnulr .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #lygoibnulr .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #lygoibnulr .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #lygoibnulr .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #lygoibnulr .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #lygoibnulr .gt_footnotes {
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
#> #lygoibnulr .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #lygoibnulr .gt_sourcenotes {
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
#> #lygoibnulr .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #lygoibnulr .gt_left {
#>   text-align: left;
#> }
#> 
#> #lygoibnulr .gt_center {
#>   text-align: center;
#> }
#> 
#> #lygoibnulr .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #lygoibnulr .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #lygoibnulr .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #lygoibnulr .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #lygoibnulr .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #lygoibnulr .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #lygoibnulr .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #lygoibnulr .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #lygoibnulr .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #lygoibnulr .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #lygoibnulr .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #lygoibnulr .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #lygoibnulr .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #lygoibnulr div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="3" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>12 Colours</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="index">#</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="hex">Hex</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Preview</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="index" class="gt_row gt_right">1</td>
#> <td headers="hex" class="gt_row gt_left">#FF0000</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF0000;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FF0000</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">2</td>
#> <td headers="hex" class="gt_row gt_left">#FF8000</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF8000;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FF8000</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">3</td>
#> <td headers="hex" class="gt_row gt_left">#FFFF00</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFFF00;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FFFF00</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">4</td>
#> <td headers="hex" class="gt_row gt_left">#80FF00</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#80FF00;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#80FF00</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">5</td>
#> <td headers="hex" class="gt_row gt_left">#00FF00</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00FF00;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#00FF00</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">6</td>
#> <td headers="hex" class="gt_row gt_left">#00FF80</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00FF80;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#00FF80</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">7</td>
#> <td headers="hex" class="gt_row gt_left">#00FFFF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00FFFF;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#00FFFF</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">8</td>
#> <td headers="hex" class="gt_row gt_left">#0080FF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0080FF;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#0080FF</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">9</td>
#> <td headers="hex" class="gt_row gt_left">#0000FF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0000FF;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#0000FF</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">10</td>
#> <td headers="hex" class="gt_row gt_left">#8000FF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#8000FF;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#8000FF</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">11</td>
#> <td headers="hex" class="gt_row gt_left">#FF00FF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF00FF;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FF00FF</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">12</td>
#> <td headers="hex" class="gt_row gt_left">#FF0080</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FF0080;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FF0080</span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Without labels
pal_show(pal_lancet, label = FALSE)
#> <div id="eeshlbaslo" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#eeshlbaslo table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #eeshlbaslo thead, #eeshlbaslo tbody, #eeshlbaslo tfoot, #eeshlbaslo tr, #eeshlbaslo td, #eeshlbaslo th {
#>   border-style: none;
#> }
#> 
#> #eeshlbaslo p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #eeshlbaslo .gt_table {
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
#> #eeshlbaslo .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #eeshlbaslo .gt_title {
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
#> #eeshlbaslo .gt_subtitle {
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
#> #eeshlbaslo .gt_heading {
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
#> #eeshlbaslo .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eeshlbaslo .gt_col_headings {
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
#> #eeshlbaslo .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #eeshlbaslo .gt_column_spanner_outer {
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
#> #eeshlbaslo .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #eeshlbaslo .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #eeshlbaslo .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #eeshlbaslo .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #eeshlbaslo .gt_group_heading {
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
#> #eeshlbaslo .gt_empty_group_heading {
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
#> #eeshlbaslo .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #eeshlbaslo .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #eeshlbaslo .gt_row {
#>   padding-top: 3px;
#>   padding-bottom: 3px;
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
#> #eeshlbaslo .gt_stub {
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
#> #eeshlbaslo .gt_stub_row_group {
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
#> #eeshlbaslo .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #eeshlbaslo .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #eeshlbaslo .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eeshlbaslo .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #eeshlbaslo .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #eeshlbaslo .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eeshlbaslo .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eeshlbaslo .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #eeshlbaslo .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eeshlbaslo .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #eeshlbaslo .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eeshlbaslo .gt_footnotes {
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
#> #eeshlbaslo .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eeshlbaslo .gt_sourcenotes {
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
#> #eeshlbaslo .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eeshlbaslo .gt_left {
#>   text-align: left;
#> }
#> 
#> #eeshlbaslo .gt_center {
#>   text-align: center;
#> }
#> 
#> #eeshlbaslo .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #eeshlbaslo .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #eeshlbaslo .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #eeshlbaslo .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #eeshlbaslo .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #eeshlbaslo .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #eeshlbaslo .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #eeshlbaslo .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #eeshlbaslo .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #eeshlbaslo .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #eeshlbaslo .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #eeshlbaslo .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #eeshlbaslo .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #eeshlbaslo div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="3" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>15 Colours</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="index">#</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="hex">Hex</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Preview</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="index" class="gt_row gt_right">1</td>
#> <td headers="hex" class="gt_row gt_left">#00468B</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#00468B;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#00468B</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">2</td>
#> <td headers="hex" class="gt_row gt_left">#ED0000</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#ED0000;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#ED0000</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">3</td>
#> <td headers="hex" class="gt_row gt_left">#42B540</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#42B540;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#42B540</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">4</td>
#> <td headers="hex" class="gt_row gt_left">#0099B4</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0099B4;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#0099B4</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">5</td>
#> <td headers="hex" class="gt_row gt_left">#925E9F</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#925E9F;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#925E9F</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">6</td>
#> <td headers="hex" class="gt_row gt_left">#FDAF91</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FDAF91;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FDAF91</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">7</td>
#> <td headers="hex" class="gt_row gt_left">#AD002A</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#AD002A;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#AD002A</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">8</td>
#> <td headers="hex" class="gt_row gt_left">#ADB6B6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#ADB6B6;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#ADB6B6</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">9</td>
#> <td headers="hex" class="gt_row gt_left">#1B1919</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1B1919;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#1B1919</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">10</td>
#> <td headers="hex" class="gt_row gt_left">#79AF97</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#79AF97;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#79AF97</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">11</td>
#> <td headers="hex" class="gt_row gt_left">#DF8F44</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#DF8F44;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#DF8F44</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">12</td>
#> <td headers="hex" class="gt_row gt_left">#6A6599</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#6A6599;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#6A6599</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">13</td>
#> <td headers="hex" class="gt_row gt_left">#FCCDE5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FCCDE5;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#FCCDE5</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">14</td>
#> <td headers="hex" class="gt_row gt_left">#80B1D3</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#80B1D3;color:#000000;padding:2px 10px;border-radius:3px;font-weight:bold;">#80B1D3</span></span></td></tr>
#>     <tr><td headers="index" class="gt_row gt_right">15</td>
#> <td headers="hex" class="gt_row gt_left">#0000FF</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0000FF;color:#FFFFFF;padding:2px 10px;border-radius:3px;font-weight:bold;">#0000FF</span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Browse all palettes from a source
pal_show(pattern = "^dichromat")
#> <div id="qardxhjjbu" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#qardxhjjbu table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #qardxhjjbu thead, #qardxhjjbu tbody, #qardxhjjbu tfoot, #qardxhjjbu tr, #qardxhjjbu td, #qardxhjjbu th {
#>   border-style: none;
#> }
#> 
#> #qardxhjjbu p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #qardxhjjbu .gt_table {
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
#> #qardxhjjbu .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #qardxhjjbu .gt_title {
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
#> #qardxhjjbu .gt_subtitle {
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
#> #qardxhjjbu .gt_heading {
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
#> #qardxhjjbu .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qardxhjjbu .gt_col_headings {
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
#> #qardxhjjbu .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #qardxhjjbu .gt_column_spanner_outer {
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
#> #qardxhjjbu .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #qardxhjjbu .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #qardxhjjbu .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #qardxhjjbu .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #qardxhjjbu .gt_group_heading {
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
#> #qardxhjjbu .gt_empty_group_heading {
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
#> #qardxhjjbu .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #qardxhjjbu .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #qardxhjjbu .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #qardxhjjbu .gt_stub {
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
#> #qardxhjjbu .gt_stub_row_group {
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
#> #qardxhjjbu .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #qardxhjjbu .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #qardxhjjbu .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qardxhjjbu .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qardxhjjbu .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #qardxhjjbu .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qardxhjjbu .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qardxhjjbu .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qardxhjjbu .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qardxhjjbu .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #qardxhjjbu .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qardxhjjbu .gt_footnotes {
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
#> #qardxhjjbu .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qardxhjjbu .gt_sourcenotes {
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
#> #qardxhjjbu .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qardxhjjbu .gt_left {
#>   text-align: left;
#> }
#> 
#> #qardxhjjbu .gt_center {
#>   text-align: center;
#> }
#> 
#> #qardxhjjbu .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #qardxhjjbu .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #qardxhjjbu .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #qardxhjjbu .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #qardxhjjbu .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #qardxhjjbu .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #qardxhjjbu .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #qardxhjjbu .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #qardxhjjbu .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #qardxhjjbu .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #qardxhjjbu .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #qardxhjjbu .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #qardxhjjbu .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #qardxhjjbu div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>17 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BrowntoBlue.10</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#663000;color:#663000;padding:0 3px;"> </span><span style="background:#996136;color:#996136;padding:0 3px;"> </span><span style="background:#CC9B7A;color:#CC9B7A;padding:0 3px;"> </span><span style="background:#D9AF98;color:#D9AF98;padding:0 3px;"> </span><span style="background:#F2DACE;color:#F2DACE;padding:0 3px;"> </span><span style="background:#CCFDFF;color:#CCFDFF;padding:0 3px;"> </span><span style="background:#99F8FF;color:#99F8FF;padding:0 3px;"> </span><span style="background:#66F0FF;color:#66F0FF;padding:0 3px;"> </span><span style="background:#33E4FF;color:#33E4FF;padding:0 3px;"> </span><span style="background:#00AACC;color:#00AACC;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BrowntoBlue.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#331A00;color:#331A00;padding:0 3px;"> </span><span style="background:#663000;color:#663000;padding:0 3px;"> </span><span style="background:#996136;color:#996136;padding:0 3px;"> </span><span style="background:#CC9B7A;color:#CC9B7A;padding:0 3px;"> </span><span style="background:#D9AF98;color:#D9AF98;padding:0 3px;"> </span><span style="background:#F2DACE;color:#F2DACE;padding:0 3px;"> </span><span style="background:#CCFDFF;color:#CCFDFF;padding:0 3px;"> </span><span style="background:#99F8FF;color:#99F8FF;padding:0 3px;"> </span><span style="background:#66F0FF;color:#66F0FF;padding:0 3px;"> </span><span style="background:#33E4FF;color:#33E4FF;padding:0 3px;"> </span><span style="background:#00AACC;color:#00AACC;padding:0 3px;"> </span><span style="background:#007A99;color:#007A99;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoDarkOrange.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#1F8F99;color:#1F8F99;padding:0 3px;"> </span><span style="background:#52C4CC;color:#52C4CC;padding:0 3px;"> </span><span style="background:#99FAFF;color:#99FAFF;padding:0 3px;"> </span><span style="background:#B2FCFF;color:#B2FCFF;padding:0 3px;"> </span><span style="background:#CCFEFF;color:#CCFEFF;padding:0 3px;"> </span><span style="background:#E6FFFF;color:#E6FFFF;padding:0 3px;"> </span><span style="background:#FFE6CC;color:#FFE6CC;padding:0 3px;"> </span><span style="background:#FFCA99;color:#FFCA99;padding:0 3px;"> </span><span style="background:#FFAD66;color:#FFAD66;padding:0 3px;"> </span><span style="background:#FF8F33;color:#FF8F33;padding:0 3px;"> </span><span style="background:#CC5800;color:#CC5800;padding:0 3px;"> </span><span style="background:#994000;color:#994000;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoDarkOrange.18</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">18</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#006666;color:#006666;padding:0 3px;"> </span><span style="background:#009999;color:#009999;padding:0 3px;"> </span><span style="background:#00CCCC;color:#00CCCC;padding:0 3px;"> </span><span style="background:#00FFFF;color:#00FFFF;padding:0 3px;"> </span><span style="background:#33FFFF;color:#33FFFF;padding:0 3px;"> </span><span style="background:#66FFFF;color:#66FFFF;padding:0 3px;"> </span><span style="background:#99FFFF;color:#99FFFF;padding:0 3px;"> </span><span style="background:#B2FFFF;color:#B2FFFF;padding:0 3px;"> </span><span style="background:#CCFFFF;color:#CCFFFF;padding:0 3px;"> </span><span style="background:#E6FFFF;color:#E6FFFF;padding:0 3px;"> </span><span style="background:#FFE6CC;color:#FFE6CC;padding:0 3px;"> </span><span style="background:#FFCA99;color:#FFCA99;padding:0 3px;"> </span><span style="background:#FFAD66;color:#FFAD66;padding:0 3px;"> </span><span style="background:#FF8F33;color:#FF8F33;padding:0 3px;"> </span><span style="background:#FF6E00;color:#FF6E00;padding:0 3px;"> </span><span style="background:#CC5500;color:#CC5500;padding:0 3px;"> </span><span style="background:#993D00;color:#993D00;padding:0 3px;"> </span><span style="background:#662700;color:#662700;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_DarkRedtoBlue.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2A0BD9;color:#2A0BD9;padding:0 3px;"> </span><span style="background:#264EFF;color:#264EFF;padding:0 3px;"> </span><span style="background:#40A1FF;color:#40A1FF;padding:0 3px;"> </span><span style="background:#73DAFF;color:#73DAFF;padding:0 3px;"> </span><span style="background:#ABF8FF;color:#ABF8FF;padding:0 3px;"> </span><span style="background:#E0FFFF;color:#E0FFFF;padding:0 3px;"> </span><span style="background:#FFFFBF;color:#FFFFBF;padding:0 3px;"> </span><span style="background:#FFE099;color:#FFE099;padding:0 3px;"> </span><span style="background:#FFAD73;color:#FFAD73;padding:0 3px;"> </span><span style="background:#F76E5E;color:#F76E5E;padding:0 3px;"> </span><span style="background:#D92632;color:#D92632;padding:0 3px;"> </span><span style="background:#A60021;color:#A60021;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_DarkRedtoBlue.18</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">18</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2400D9;color:#2400D9;padding:0 3px;"> </span><span style="background:#191DF7;color:#191DF7;padding:0 3px;"> </span><span style="background:#2957FF;color:#2957FF;padding:0 3px;"> </span><span style="background:#3D87FF;color:#3D87FF;padding:0 3px;"> </span><span style="background:#57B0FF;color:#57B0FF;padding:0 3px;"> </span><span style="background:#75D3FF;color:#75D3FF;padding:0 3px;"> </span><span style="background:#99EBFF;color:#99EBFF;padding:0 3px;"> </span><span style="background:#BDF9FF;color:#BDF9FF;padding:0 3px;"> </span><span style="background:#EBFFFF;color:#EBFFFF;padding:0 3px;"> </span><span style="background:#FFFFEB;color:#FFFFEB;padding:0 3px;"> </span><span style="background:#FFF2BD;color:#FFF2BD;padding:0 3px;"> </span><span style="background:#FFD699;color:#FFD699;padding:0 3px;"> </span><span style="background:#FFAC75;color:#FFAC75;padding:0 3px;"> </span><span style="background:#FF7857;color:#FF7857;padding:0 3px;"> </span><span style="background:#FF3D3D;color:#FF3D3D;padding:0 3px;"> </span><span style="background:#F72836;color:#F72836;padding:0 3px;"> </span><span style="background:#D91630;color:#D91630;padding:0 3px;"> </span><span style="background:#A60021;color:#A60021;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoGreen.14</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">14</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0000FF;color:#0000FF;padding:0 3px;"> </span><span style="background:#3333FF;color:#3333FF;padding:0 3px;"> </span><span style="background:#6666FF;color:#6666FF;padding:0 3px;"> </span><span style="background:#9999FF;color:#9999FF;padding:0 3px;"> </span><span style="background:#B2B2FF;color:#B2B2FF;padding:0 3px;"> </span><span style="background:#CCCCFF;color:#CCCCFF;padding:0 3px;"> </span><span style="background:#E6E6FF;color:#E6E6FF;padding:0 3px;"> </span><span style="background:#E6FFE6;color:#E6FFE6;padding:0 3px;"> </span><span style="background:#CCFFCC;color:#CCFFCC;padding:0 3px;"> </span><span style="background:#B2FFB2;color:#B2FFB2;padding:0 3px;"> </span><span style="background:#99FF99;color:#99FF99;padding:0 3px;"> </span><span style="background:#66FF66;color:#66FF66;padding:0 3px;"> </span><span style="background:#33FF33;color:#33FF33;padding:0 3px;"> </span><span style="background:#00FF00;color:#00FF00;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoGray.8</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0099CC;color:#0099CC;padding:0 3px;"> </span><span style="background:#66E6FF;color:#66E6FF;padding:0 3px;"> </span><span style="background:#99FFFF;color:#99FFFF;padding:0 3px;"> </span><span style="background:#CCFFFF;color:#CCFFFF;padding:0 3px;"> </span><span style="background:#E6E6E6;color:#E6E6E6;padding:0 3px;"> </span><span style="background:#999999;color:#999999;padding:0 3px;"> </span><span style="background:#666666;color:#666666;padding:0 3px;"> </span><span style="background:#333333;color:#333333;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrangeRed.14</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">14</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#085AFF;color:#085AFF;padding:0 3px;"> </span><span style="background:#3377FF;color:#3377FF;padding:0 3px;"> </span><span style="background:#5991FF;color:#5991FF;padding:0 3px;"> </span><span style="background:#8CB2FF;color:#8CB2FF;padding:0 3px;"> </span><span style="background:#BFD4FF;color:#BFD4FF;padding:0 3px;"> </span><span style="background:#E6EEFF;color:#E6EEFF;padding:0 3px;"> </span><span style="background:#F7FAFF;color:#F7FAFF;padding:0 3px;"> </span><span style="background:#FFFFCC;color:#FFFFCC;padding:0 3px;"> </span><span style="background:#FFFF99;color:#FFFF99;padding:0 3px;"> </span><span style="background:#FFFF00;color:#FFFF00;padding:0 3px;"> </span><span style="background:#FFCC00;color:#FFCC00;padding:0 3px;"> </span><span style="background:#FF9900;color:#FF9900;padding:0 3px;"> </span><span style="background:#FF6600;color:#FF6600;padding:0 3px;"> </span><span style="background:#FF0000;color:#FF0000;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrange.10</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0055FF;color:#0055FF;padding:0 3px;"> </span><span style="background:#3399FF;color:#3399FF;padding:0 3px;"> </span><span style="background:#66CCFF;color:#66CCFF;padding:0 3px;"> </span><span style="background:#99EEFF;color:#99EEFF;padding:0 3px;"> </span><span style="background:#CCFFFF;color:#CCFFFF;padding:0 3px;"> </span><span style="background:#FFFFCC;color:#FFFFCC;padding:0 3px;"> </span><span style="background:#FFEE99;color:#FFEE99;padding:0 3px;"> </span><span style="background:#FFCC66;color:#FFCC66;padding:0 3px;"> </span><span style="background:#FF9933;color:#FF9933;padding:0 3px;"> </span><span style="background:#FF5500;color:#FF5500;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrange.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#002BFF;color:#002BFF;padding:0 3px;"> </span><span style="background:#1A66FF;color:#1A66FF;padding:0 3px;"> </span><span style="background:#3399FF;color:#3399FF;padding:0 3px;"> </span><span style="background:#66CCFF;color:#66CCFF;padding:0 3px;"> </span><span style="background:#99EEFF;color:#99EEFF;padding:0 3px;"> </span><span style="background:#CCFFFF;color:#CCFFFF;padding:0 3px;"> </span><span style="background:#FFFFCC;color:#FFFFCC;padding:0 3px;"> </span><span style="background:#FFEE99;color:#FFEE99;padding:0 3px;"> </span><span style="background:#FFCC66;color:#FFCC66;padding:0 3px;"> </span><span style="background:#FF9933;color:#FF9933;padding:0 3px;"> </span><span style="background:#FF661A;color:#FF661A;padding:0 3px;"> </span><span style="background:#FF2B00;color:#FF2B00;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrange.8</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#0080FF;color:#0080FF;padding:0 3px;"> </span><span style="background:#4CC4FF;color:#4CC4FF;padding:0 3px;"> </span><span style="background:#99EEFF;color:#99EEFF;padding:0 3px;"> </span><span style="background:#CCFFFF;color:#CCFFFF;padding:0 3px;"> </span><span style="background:#FFFFCC;color:#FFFFCC;padding:0 3px;"> </span><span style="background:#FFEE99;color:#FFEE99;padding:0 3px;"> </span><span style="background:#FFC44C;color:#FFC44C;padding:0 3px;"> </span><span style="background:#FF8000;color:#FF8000;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_LightBluetoDarkBlue.10</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#E6FFFF;color:#E6FFFF;padding:0 3px;"> </span><span style="background:#CCFBFF;color:#CCFBFF;padding:0 3px;"> </span><span style="background:#B2F2FF;color:#B2F2FF;padding:0 3px;"> </span><span style="background:#99E6FF;color:#99E6FF;padding:0 3px;"> </span><span style="background:#80D4FF;color:#80D4FF;padding:0 3px;"> </span><span style="background:#66BFFF;color:#66BFFF;padding:0 3px;"> </span><span style="background:#4CA6FF;color:#4CA6FF;padding:0 3px;"> </span><span style="background:#3388FF;color:#3388FF;padding:0 3px;"> </span><span style="background:#1A66FF;color:#1A66FF;padding:0 3px;"> </span><span style="background:#0040FF;color:#0040FF;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_LightBluetoDarkBlue.7</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFFFFF;color:#FFFFFF;padding:0 3px;"> </span><span style="background:#CCFDFF;color:#CCFDFF;padding:0 3px;"> </span><span style="background:#99F8FF;color:#99F8FF;padding:0 3px;"> </span><span style="background:#66F0FF;color:#66F0FF;padding:0 3px;"> </span><span style="background:#33E4FF;color:#33E4FF;padding:0 3px;"> </span><span style="background:#00AACC;color:#00AACC;padding:0 3px;"> </span><span style="background:#007A99;color:#007A99;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_Categorical.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFBF80;color:#FFBF80;padding:0 3px;"> </span><span style="background:#FF8000;color:#FF8000;padding:0 3px;"> </span><span style="background:#FFFF99;color:#FFFF99;padding:0 3px;"> </span><span style="background:#FFFF33;color:#FFFF33;padding:0 3px;"> </span><span style="background:#B2FF8C;color:#B2FF8C;padding:0 3px;"> </span><span style="background:#33FF00;color:#33FF00;padding:0 3px;"> </span><span style="background:#A6EDFF;color:#A6EDFF;padding:0 3px;"> </span><span style="background:#1AB2FF;color:#1AB2FF;padding:0 3px;"> </span><span style="background:#CCBFFF;color:#CCBFFF;padding:0 3px;"> </span><span style="background:#664CFF;color:#664CFF;padding:0 3px;"> </span><span style="background:#FF99BF;color:#FF99BF;padding:0 3px;"> </span><span style="background:#E61A33;color:#E61A33;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_GreentoMagenta.16</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">16</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#005100;color:#005100;padding:0 3px;"> </span><span style="background:#008600;color:#008600;padding:0 3px;"> </span><span style="background:#00BC00;color:#00BC00;padding:0 3px;"> </span><span style="background:#00F100;color:#00F100;padding:0 3px;"> </span><span style="background:#51FF51;color:#51FF51;padding:0 3px;"> </span><span style="background:#86FF86;color:#86FF86;padding:0 3px;"> </span><span style="background:#BCFFBC;color:#BCFFBC;padding:0 3px;"> </span><span style="background:#FFFFFF;color:#FFFFFF;padding:0 3px;"> </span><span style="background:#FFF1FF;color:#FFF1FF;padding:0 3px;"> </span><span style="background:#FFBCFF;color:#FFBCFF;padding:0 3px;"> </span><span style="background:#FF86FF;color:#FF86FF;padding:0 3px;"> </span><span style="background:#FF51FF;color:#FF51FF;padding:0 3px;"> </span><span style="background:#F100F1;color:#F100F1;padding:0 3px;"> </span><span style="background:#BC00BC;color:#BC00BC;padding:0 3px;"> </span><span style="background:#860086;color:#860086;padding:0 3px;"> </span><span style="background:#510051;color:#510051;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_SteppedSequential.5</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">25</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#990F0F;color:#990F0F;padding:0 3px;"> </span><span style="background:#B22D2D;color:#B22D2D;padding:0 3px;"> </span><span style="background:#CC5252;color:#CC5252;padding:0 3px;"> </span><span style="background:#E67E7E;color:#E67E7E;padding:0 3px;"> </span><span style="background:#FFB2B2;color:#FFB2B2;padding:0 3px;"> </span><span style="background:#99700F;color:#99700F;padding:0 3px;"> </span><span style="background:#B28B2D;color:#B28B2D;padding:0 3px;"> </span><span style="background:#CCA852;color:#CCA852;padding:0 3px;"> </span><span style="background:#E6C77E;color:#E6C77E;padding:0 3px;"> </span><span style="background:#FFE8B2;color:#FFE8B2;padding:0 3px;"> </span><span style="background:#1F990F;color:#1F990F;padding:0 3px;"> </span><span style="background:#3CB22D;color:#3CB22D;padding:0 3px;"> </span><span style="background:#60CC52;color:#60CC52;padding:0 3px;"> </span><span style="background:#8AE67E;color:#8AE67E;padding:0 3px;"> </span><span style="background:#BCFFB2;color:#BCFFB2;padding:0 3px;"> </span><span style="background:#710F99;color:#710F99;padding:0 3px;"> </span><span style="background:#8B2DB2;color:#8B2DB2;padding:0 3px;"> </span><span style="background:#A852CC;color:#A852CC;padding:0 3px;"> </span><span style="background:#C77EE6;color:#C77EE6;padding:0 3px;"> </span><span style="background:#E9B2FF;color:#E9B2FF;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "^pals")
#> <div id="bcxociitbf" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#bcxociitbf table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #bcxociitbf thead, #bcxociitbf tbody, #bcxociitbf tfoot, #bcxociitbf tr, #bcxociitbf td, #bcxociitbf th {
#>   border-style: none;
#> }
#> 
#> #bcxociitbf p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #bcxociitbf .gt_table {
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
#> #bcxociitbf .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #bcxociitbf .gt_title {
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
#> #bcxociitbf .gt_subtitle {
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
#> #bcxociitbf .gt_heading {
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
#> #bcxociitbf .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bcxociitbf .gt_col_headings {
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
#> #bcxociitbf .gt_col_heading {
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
#>   padding-top: 6px;
#>   padding-bottom: 7px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #bcxociitbf .gt_column_spanner_outer {
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
#> #bcxociitbf .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #bcxociitbf .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #bcxociitbf .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 6px;
#>   padding-bottom: 6px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #bcxociitbf .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #bcxociitbf .gt_group_heading {
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
#> #bcxociitbf .gt_empty_group_heading {
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
#> #bcxociitbf .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #bcxociitbf .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #bcxociitbf .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
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
#> #bcxociitbf .gt_stub {
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
#> #bcxociitbf .gt_stub_row_group {
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
#> #bcxociitbf .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #bcxociitbf .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #bcxociitbf .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bcxociitbf .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bcxociitbf .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #bcxociitbf .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bcxociitbf .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bcxociitbf .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bcxociitbf .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bcxociitbf .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #bcxociitbf .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bcxociitbf .gt_footnotes {
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
#> #bcxociitbf .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bcxociitbf .gt_sourcenotes {
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
#> #bcxociitbf .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bcxociitbf .gt_left {
#>   text-align: left;
#> }
#> 
#> #bcxociitbf .gt_center {
#>   text-align: center;
#> }
#> 
#> #bcxociitbf .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #bcxociitbf .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #bcxociitbf .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #bcxociitbf .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #bcxociitbf .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #bcxociitbf .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #bcxociitbf .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #bcxociitbf .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #bcxociitbf .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #bcxociitbf .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #bcxociitbf .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #bcxociitbf .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #bcxociitbf .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #bcxociitbf div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:40px;"/>
#>     <col style="width:400px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>18 Palettes</strong></span></td>
#>     </tr>
#>     
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="palette">Palette</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="n_colors">N</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold; background-color: #E8F4FD;" scope="col" id="preview">Colours</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.algae</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#122414;color:#122414;padding:0 3px;"> </span><span style="background:#193F29;color:#193F29;padding:0 3px;"> </span><span style="background:#185B3B;color:#185B3B;padding:0 3px;"> </span><span style="background:#0C7748;color:#0C7748;padding:0 3px;"> </span><span style="background:#129450;color:#129450;padding:0 3px;"> </span><span style="background:#50AD59;color:#50AD59;padding:0 3px;"> </span><span style="background:#84C47A;color:#84C47A;padding:0 3px;"> </span><span style="background:#AFDDA2;color:#AFDDA2;padding:0 3px;"> </span><span style="background:#D7F9D0;color:#D7F9D0;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.deep</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">13</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#281A2C;color:#281A2C;padding:0 3px;"> </span><span style="background:#352A4A;color:#352A4A;padding:0 3px;"> </span><span style="background:#3F396D;color:#3F396D;padding:0 3px;"> </span><span style="background:#404C8B;color:#404C8B;padding:0 3px;"> </span><span style="background:#3E6495;color:#3E6495;padding:0 3px;"> </span><span style="background:#427999;color:#427999;padding:0 3px;"> </span><span style="background:#488E9E;color:#488E9E;padding:0 3px;"> </span><span style="background:#50A3A2;color:#50A3A2;padding:0 3px;"> </span><span style="background:#5DBAA4;color:#5DBAA4;padding:0 3px;"> </span><span style="background:#78CEA3;color:#78CEA3;padding:0 3px;"> </span><span style="background:#A3DEA6;color:#A3DEA6;padding:0 3px;"> </span><span style="background:#D1EDB4;color:#D1EDB4;padding:0 3px;"> </span><span style="background:#FDFECC;color:#FDFECC;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.dense</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#360E24;color:#360E24;padding:0 3px;"> </span><span style="background:#5D1A58;color:#5D1A58;padding:0 3px;"> </span><span style="background:#723692;color:#723692;padding:0 3px;"> </span><span style="background:#795CC3;color:#795CC3;padding:0 3px;"> </span><span style="background:#7487E0;color:#7487E0;padding:0 3px;"> </span><span style="background:#7EB0E4;color:#7EB0E4;padding:0 3px;"> </span><span style="background:#AAD2E3;color:#AAD2E3;padding:0 3px;"> </span><span style="background:#E6F1F1;color:#E6F1F1;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.gray</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#000000;color:#000000;padding:0 3px;"> </span><span style="background:#363636;color:#363636;padding:0 3px;"> </span><span style="background:#717070;color:#717070;padding:0 3px;"> </span><span style="background:#B1B1B0;color:#B1B1B0;padding:0 3px;"> </span><span style="background:#FFFFFD;color:#FFFFFD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.haline</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">24</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2A186C;color:#2A186C;padding:0 3px;"> </span><span style="background:#2E1B87;color:#2E1B87;padding:0 3px;"> </span><span style="background:#2B229F;color:#2B229F;padding:0 3px;"> </span><span style="background:#1D35A1;color:#1D35A1;padding:0 3px;"> </span><span style="background:#11459A;color:#11459A;padding:0 3px;"> </span><span style="background:#0C5294;color:#0C5294;padding:0 3px;"> </span><span style="background:#115D8F;color:#115D8F;padding:0 3px;"> </span><span style="background:#19678C;color:#19678C;padding:0 3px;"> </span><span style="background:#22718A;color:#22718A;padding:0 3px;"> </span><span style="background:#2B7A89;color:#2B7A89;padding:0 3px;"> </span><span style="background:#328388;color:#328388;padding:0 3px;"> </span><span style="background:#388D88;color:#388D88;padding:0 3px;"> </span><span style="background:#3E9886;color:#3E9886;padding:0 3px;"> </span><span style="background:#44A284;color:#44A284;padding:0 3px;"> </span><span style="background:#4CAC80;color:#4CAC80;padding:0 3px;"> </span><span style="background:#55B67A;color:#55B67A;padding:0 3px;"> </span><span style="background:#62BF72;color:#62BF72;padding:0 3px;"> </span><span style="background:#73C869;color:#73C869;padding:0 3px;"> </span><span style="background:#8AD060;color:#8AD060;padding:0 3px;"> </span><span style="background:#A4D75C;color:#A4D75C;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.ice</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#040613;color:#040613;padding:0 3px;"> </span><span style="background:#1E1D3B;color:#1E1D3B;padding:0 3px;"> </span><span style="background:#333268;color:#333268;padding:0 3px;"> </span><span style="background:#3F4B96;color:#3F4B96;padding:0 3px;"> </span><span style="background:#3E6AB0;color:#3E6AB0;padding:0 3px;"> </span><span style="background:#4989BC;color:#4989BC;padding:0 3px;"> </span><span style="background:#61A8C7;color:#61A8C7;padding:0 3px;"> </span><span style="background:#83C5D3;color:#83C5D3;padding:0 3px;"> </span><span style="background:#B6E0E3;color:#B6E0E3;padding:0 3px;"> </span><span style="background:#EAFDFD;color:#EAFDFD;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.matter</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#2F0F3E;color:#2F0F3E;padding:0 3px;"> </span><span style="background:#581756;color:#581756;padding:0 3px;"> </span><span style="background:#831C63;color:#831C63;padding:0 3px;"> </span><span style="background:#AB2960;color:#AB2960;padding:0 3px;"> </span><span style="background:#CE4356;color:#CE4356;padding:0 3px;"> </span><span style="background:#E66A54;color:#E66A54;padding:0 3px;"> </span><span style="background:#F29567;color:#F29567;padding:0 3px;"> </span><span style="background:#F9C187;color:#F9C187;padding:0 3px;"> </span><span style="background:#FEEDB0;color:#FEEDB0;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.oxy</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#400505;color:#400505;padding:0 3px;"> </span><span style="background:#54070A;color:#54070A;padding:0 3px;"> </span><span style="background:#6A060F;color:#6A060F;padding:0 3px;"> </span><span style="background:#80060D;color:#80060D;padding:0 3px;"> </span><span style="background:#901A07;color:#901A07;padding:0 3px;"> </span><span style="background:#9C2E04;color:#9C2E04;padding:0 3px;"> </span><span style="background:#A84003;color:#A84003;padding:0 3px;"> </span><span style="background:#B25203;color:#B25203;padding:0 3px;"> </span><span style="background:#BC6404;color:#BC6404;padding:0 3px;"> </span><span style="background:#C57606;color:#C57606;padding:0 3px;"> </span><span style="background:#CE880B;color:#CE880B;padding:0 3px;"> </span><span style="background:#D59A12;color:#D59A12;padding:0 3px;"> </span><span style="background:#DCAE19;color:#DCAE19;padding:0 3px;"> </span><span style="background:#E2C221;color:#E2C221;padding:0 3px;"> </span><span style="background:#E7D72C;color:#E7D72C;padding:0 3px;"> </span><span style="background:#EAED3E;color:#EAED3E;padding:0 3px;"> </span><span style="background:#F8FE69;color:#F8FE69;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.phase</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#A8780D;color:#A8780D;padding:0 3px;"> </span><span style="background:#BD6827;color:#BD6827;padding:0 3px;"> </span><span style="background:#CE5642;color:#CE5642;padding:0 3px;"> </span><span style="background:#DA4065;color:#DA4065;padding:0 3px;"> </span><span style="background:#DF2A92;color:#DF2A92;padding:0 3px;"> </span><span style="background:#D528C3;color:#D528C3;padding:0 3px;"> </span><span style="background:#C040E4;color:#C040E4;padding:0 3px;"> </span><span style="background:#A25BF3;color:#A25BF3;padding:0 3px;"> </span><span style="background:#7E71F0;color:#7E71F0;padding:0 3px;"> </span><span style="background:#5384DD;color:#5384DD;padding:0 3px;"> </span><span style="background:#2D8FBD;color:#2D8FBD;padding:0 3px;"> </span><span style="background:#19959D;color:#19959D;padding:0 3px;"> </span><span style="background:#0C987D;color:#0C987D;padding:0 3px;"> </span><span style="background:#219A54;color:#219A54;padding:0 3px;"> </span><span style="background:#5A9422;color:#5A9422;padding:0 3px;"> </span><span style="background:#88860D;color:#88860D;padding:0 3px;"> </span><span style="background:#A8780D;color:#A8780D;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.solar</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#331418;color:#331418;padding:0 3px;"> </span><span style="background:#602124;color:#602124;padding:0 3px;"> </span><span style="background:#8B3120;color:#8B3120;padding:0 3px;"> </span><span style="background:#AA5116;color:#AA5116;padding:0 3px;"> </span><span style="background:#C07613;color:#C07613;padding:0 3px;"> </span><span style="background:#D0A01F;color:#D0A01F;padding:0 3px;"> </span><span style="background:#DBCC32;color:#DBCC32;padding:0 3px;"> </span><span style="background:#E1FD4B;color:#E1FD4B;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.thermal</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">22</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#042333;color:#042333;padding:0 3px;"> </span><span style="background:#072B4B;color:#072B4B;padding:0 3px;"> </span><span style="background:#0E3167;color:#0E3167;padding:0 3px;"> </span><span style="background:#1F3488;color:#1F3488;padding:0 3px;"> </span><span style="background:#3A339E;color:#3A339E;padding:0 3px;"> </span><span style="background:#51399D;color:#51399D;padding:0 3px;"> </span><span style="background:#624198;color:#624198;padding:0 3px;"> </span><span style="background:#744992;color:#744992;padding:0 3px;"> </span><span style="background:#84508E;color:#84508E;padding:0 3px;"> </span><span style="background:#95568A;color:#95568A;padding:0 3px;"> </span><span style="background:#A65C85;color:#A65C85;padding:0 3px;"> </span><span style="background:#B9627E;color:#B9627E;padding:0 3px;"> </span><span style="background:#CB6773;color:#CB6773;padding:0 3px;"> </span><span style="background:#DB6E66;color:#DB6E66;padding:0 3px;"> </span><span style="background:#EB7958;color:#EB7958;padding:0 3px;"> </span><span style="background:#F58649;color:#F58649;padding:0 3px;"> </span><span style="background:#FA963F;color:#FA963F;padding:0 3px;"> </span><span style="background:#FCA93C;color:#FCA93C;padding:0 3px;"> </span><span style="background:#FABD3E;color:#FABD3E;padding:0 3px;"> </span><span style="background:#F7D145;color:#F7D145;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.turbid</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#221F1B;color:#221F1B;padding:0 3px;"> </span><span style="background:#4D392D;color:#4D392D;padding:0 3px;"> </span><span style="background:#795338;color:#795338;padding:0 3px;"> </span><span style="background:#A1703B;color:#A1703B;padding:0 3px;"> </span><span style="background:#BF9747;color:#BF9747;padding:0 3px;"> </span><span style="background:#D3C56F;color:#D3C56F;padding:0 3px;"> </span><span style="background:#E9F6AB;color:#E9F6AB;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.balance</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">29</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#181C43;color:#181C43;padding:0 3px;"> </span><span style="background:#21295F;color:#21295F;padding:0 3px;"> </span><span style="background:#27347D;color:#27347D;padding:0 3px;"> </span><span style="background:#28409F;color:#28409F;padding:0 3px;"> </span><span style="background:#1950BA;color:#1950BA;padding:0 3px;"> </span><span style="background:#0A65BD;color:#0A65BD;padding:0 3px;"> </span><span style="background:#1F77BB;color:#1F77BB;padding:0 3px;"> </span><span style="background:#3787BA;color:#3787BA;padding:0 3px;"> </span><span style="background:#4F96BA;color:#4F96BA;padding:0 3px;"> </span><span style="background:#6AA4BC;color:#6AA4BC;padding:0 3px;"> </span><span style="background:#87B2C1;color:#87B2C1;padding:0 3px;"> </span><span style="background:#A3BFC9;color:#A3BFC9;padding:0 3px;"> </span><span style="background:#BECDD3;color:#BECDD3;padding:0 3px;"> </span><span style="background:#D8DCDE;color:#D8DCDE;padding:0 3px;"> </span><span style="background:#F0ECEB;color:#F0ECEB;padding:0 3px;"> </span><span style="background:#E8D7D2;color:#E8D7D2;padding:0 3px;"> </span><span style="background:#E1C1B8;color:#E1C1B8;padding:0 3px;"> </span><span style="background:#DAAD9E;color:#DAAD9E;padding:0 3px;"> </span><span style="background:#D49884;color:#D49884;padding:0 3px;"> </span><span style="background:#CD8369;color:#CD8369;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.curl</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#151D44;color:#151D44;padding:0 3px;"> </span><span style="background:#1B3B55;color:#1B3B55;padding:0 3px;"> </span><span style="background:#1B5867;color:#1B5867;padding:0 3px;"> </span><span style="background:#117676;color:#117676;padding:0 3px;"> </span><span style="background:#2B937F;color:#2B937F;padding:0 3px;"> </span><span style="background:#69AB89;color:#69AB89;padding:0 3px;"> </span><span style="background:#A1C1A1;color:#A1C1A1;padding:0 3px;"> </span><span style="background:#D2D9C6;color:#D2D9C6;padding:0 3px;"> </span><span style="background:#FDF5F3;color:#FDF5F3;padding:0 3px;"> </span><span style="background:#EDCEBF;color:#EDCEBF;padding:0 3px;"> </span><span style="background:#E2A78F;color:#E2A78F;padding:0 3px;"> </span><span style="background:#D67F6D;color:#D67F6D;padding:0 3px;"> </span><span style="background:#C35961;color:#C35961;padding:0 3px;"> </span><span style="background:#A73960;color:#A73960;padding:0 3px;"> </span><span style="background:#851F60;color:#851F60;padding:0 3px;"> </span><span style="background:#5C1453;color:#5C1453;padding:0 3px;"> </span><span style="background:#340D35;color:#340D35;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.delta</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">96</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#112040;color:#112040;padding:0 3px;"> </span><span style="background:#142348;color:#142348;padding:0 3px;"> </span><span style="background:#172650;color:#172650;padding:0 3px;"> </span><span style="background:#1B2A59;color:#1B2A59;padding:0 3px;"> </span><span style="background:#1E2D62;color:#1E2D62;padding:0 3px;"> </span><span style="background:#21316C;color:#21316C;padding:0 3px;"> </span><span style="background:#243576;color:#243576;padding:0 3px;"> </span><span style="background:#253781;color:#253781;padding:0 3px;"> </span><span style="background:#263B8A;color:#263B8A;padding:0 3px;"> </span><span style="background:#244094;color:#244094;padding:0 3px;"> </span><span style="background:#214599;color:#214599;padding:0 3px;"> </span><span style="background:#1E4C9B;color:#1E4C9B;padding:0 3px;"> </span><span style="background:#1C529D;color:#1C529D;padding:0 3px;"> </span><span style="background:#1B579D;color:#1B579D;padding:0 3px;"> </span><span style="background:#1B5D9E;color:#1B5D9E;padding:0 3px;"> </span><span style="background:#1B629F;color:#1B629F;padding:0 3px;"> </span><span style="background:#1C67A0;color:#1C67A0;padding:0 3px;"> </span><span style="background:#1E6DA1;color:#1E6DA1;padding:0 3px;"> </span><span style="background:#2072A2;color:#2072A2;padding:0 3px;"> </span><span style="background:#2277A3;color:#2277A3;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.amp</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#F1EDEC;color:#F1EDEC;padding:0 3px;"> </span><span style="background:#E5CEC8;color:#E5CEC8;padding:0 3px;"> </span><span style="background:#DCB1A3;color:#DCB1A3;padding:0 3px;"> </span><span style="background:#D3947E;color:#D3947E;padding:0 3px;"> </span><span style="background:#CA775B;color:#CA775B;padding:0 3px;"> </span><span style="background:#C0583B;color:#C0583B;padding:0 3px;"> </span><span style="background:#B23726;color:#B23726;padding:0 3px;"> </span><span style="background:#9D1926;color:#9D1926;padding:0 3px;"> </span><span style="background:#7F0E29;color:#7F0E29;padding:0 3px;"> </span><span style="background:#5C0E21;color:#5C0E21;padding:0 3px;"> </span><span style="background:#3C0912;color:#3C0912;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.speed</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFFDCD;color:#FFFDCD;padding:0 3px;"> </span><span style="background:#E9D889;color:#E9D889;padding:0 3px;"> </span><span style="background:#C9BA45;color:#C9BA45;padding:0 3px;"> </span><span style="background:#98A512;color:#98A512;padding:0 3px;"> </span><span style="background:#60920B;color:#60920B;padding:0 3px;"> </span><span style="background:#277B23;color:#277B23;padding:0 3px;"> </span><span style="background:#0B5F2D;color:#0B5F2D;padding:0 3px;"> </span><span style="background:#174026;color:#174026;padding:0 3px;"> </span><span style="background:#172313;color:#172313;padding:0 3px;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.tempo</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="background:#FFF6F4;color:#FFF6F4;padding:0 3px;"> </span><span style="background:#CBD5C0;color:#CBD5C0;padding:0 3px;"> </span><span style="background:#92BB99;color:#92BB99;padding:0 3px;"> </span><span style="background:#4FA183;color:#4FA183;padding:0 3px;"> </span><span style="background:#13847B;color:#13847B;padding:0 3px;"> </span><span style="background:#19616C;color:#19616C;padding:0 3px;"> </span><span style="background:#1C4058;color:#1C4058;padding:0 3px;"> </span><span style="background:#151D44;color:#151D44;padding:0 3px;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
```
