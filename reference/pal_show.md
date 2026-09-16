# Visualise Palettes or Colour Vectors

Display palettes as horizontal colour bars (ggplot) or an interactive gt
table with colour swatches. Use `output = "gg"` for the Plots pane or
`output = "gt"` for the Viewer pane.

## Usage

``` r
pal_show(
  palette = NULL,
  n = NULL,
  pattern = NULL,
  type = c("all", "discrete", "continuous"),
  max_colors = 20,
  index = NULL,
  output = c("gt", "gg", "console"),
  label = TRUE,
  label_size = 3,
  ncol = NULL
)
```

## Arguments

  - palette:
    
    Character vector of palette names (e.g. `"lancet"`), a colour vector
    (hex codes or named colours), or `NULL` to show all palettes
    matching `pattern`/`type`. Named colour vectors (e.g. `pal_paraSC`)
    will use the names as labels.

  - n:
    
    Number of colours to take from each palette, following the rules of
    `pal_get()`: colours are taken from the front when `n` is at most
    the palette length and interpolated when it is longer. `max_colors`
    still caps how many of them are drawn. Default `NULL` shows each
    palette as it is.

  - pattern:
    
    Regex pattern to filter palette names (e.g. `"^nord"`).

  - type:
    
    Filter by type: `"all"`, `"discrete"`, or `"continuous"`.

  - max\_colors:
    
    Maximum colours to display per palette. Default 20.

  - index:
    
    Integer vector of palette indices to show (after filtering).

  - output:
    
    Output format: `"gt"` (default) for a gt table, `"gg"` for a ggplot,
    or `"console"` for terminal output.

  - label:
    
    Logical. In colour vector mode, whether to show hex/name labels on
    tiles. Default `TRUE`.

  - label\_size:
    
    Numeric. Text size for labels in colour vector mode. Default 3.

  - ncol:
    
    Integer. Number of columns for colour vector mode. Default `NULL`
    puts every displayed colour on a single row.

## Value

A ggplot or gt object, or invisibly the displayed data for console
output (all outputs also print).

## Details

When `palette` is a character vector of valid colour specifications (hex
codes like `"#FF0000"` or named R colours like `"red"`) rather than
palette names, the function automatically switches to **colour vector
mode**: it displays the colours directly as a single-row colour bar
(ggplot) with hex labels, similar to `show_color()` but as a
publication-ready plot.

## See also

Other colour palettes: `pal_bar`, `pal_get()`, `pal_heat`, `pal_lancet`,
`pal_list()`, `pal_other`, `pal_paraSC`, `pal_show_brewer()`,
`pal_show_ggsci()`, `pal_show_hcl()`, `pal_show_viridis()`

## Examples

``` r
# Show specific palettes (gt table, default)
pal_show(c("lancet", "Paired", "viridis"))
#> <div id="gqdnsotsva" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#gqdnsotsva table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #gqdnsotsva thead, #gqdnsotsva tbody, #gqdnsotsva tfoot, #gqdnsotsva tr, #gqdnsotsva td, #gqdnsotsva th {
#>   border-style: none;
#> }
#> 
#> #gqdnsotsva p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #gqdnsotsva .gt_table {
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
#> #gqdnsotsva .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #gqdnsotsva .gt_title {
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
#> #gqdnsotsva .gt_subtitle {
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
#> #gqdnsotsva .gt_heading {
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
#> #gqdnsotsva .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqdnsotsva .gt_col_headings {
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
#> #gqdnsotsva .gt_col_heading {
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
#> #gqdnsotsva .gt_column_spanner_outer {
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
#> #gqdnsotsva .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #gqdnsotsva .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #gqdnsotsva .gt_column_spanner {
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
#> #gqdnsotsva .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #gqdnsotsva .gt_group_heading {
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
#> #gqdnsotsva .gt_empty_group_heading {
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
#> #gqdnsotsva .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #gqdnsotsva .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #gqdnsotsva .gt_row {
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
#> #gqdnsotsva .gt_stub {
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
#> #gqdnsotsva .gt_stub_row_group {
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
#> #gqdnsotsva .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #gqdnsotsva .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #gqdnsotsva .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqdnsotsva .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #gqdnsotsva .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #gqdnsotsva .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqdnsotsva .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqdnsotsva .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #gqdnsotsva .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqdnsotsva .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #gqdnsotsva .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqdnsotsva .gt_footnotes {
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
#> #gqdnsotsva .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqdnsotsva .gt_sourcenotes {
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
#> #gqdnsotsva .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqdnsotsva .gt_left {
#>   text-align: left;
#> }
#> 
#> #gqdnsotsva .gt_center {
#>   text-align: center;
#> }
#> 
#> #gqdnsotsva .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #gqdnsotsva .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #gqdnsotsva .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #gqdnsotsva .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #gqdnsotsva .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #gqdnsotsva .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #gqdnsotsva .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #gqdnsotsva .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #gqdnsotsva .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #gqdnsotsva .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #gqdnsotsva .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #gqdnsotsva .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #gqdnsotsva .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #gqdnsotsva div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:410px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#00468BFF;color:#00468BFF;"> </span><span style="display:inline-block;width:20px;background:#ED0000FF;color:#ED0000FF;"> </span><span style="display:inline-block;width:20px;background:#42B540FF;color:#42B540FF;"> </span><span style="display:inline-block;width:20px;background:#0099B4FF;color:#0099B4FF;"> </span><span style="display:inline-block;width:20px;background:#925E9FFF;color:#925E9FFF;"> </span><span style="display:inline-block;width:20px;background:#FDAF91FF;color:#FDAF91FF;"> </span><span style="display:inline-block;width:20px;background:#AD002AFF;color:#AD002AFF;"> </span><span style="display:inline-block;width:20px;background:#ADB6B6FF;color:#ADB6B6FF;"> </span><span style="display:inline-block;width:20px;background:#1B1919FF;color:#1B1919FF;"> </span><span style="display:inline-block;width:20px;background:#79AF97FF;color:#79AF97FF;"> </span><span style="display:inline-block;width:20px;background:#DF8F44FF;color:#DF8F44FF;"> </span><span style="display:inline-block;width:20px;background:#6A6599FF;color:#6A6599FF;"> </span><span style="display:inline-block;width:20px;background:#FCCDE5FF;color:#FCCDE5FF;"> </span><span style="display:inline-block;width:20px;background:#80B1D3FF;color:#80B1D3FF;"> </span><span style="display:inline-block;width:20px;background:#0000FFFF;color:#0000FFFF;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Paired</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#A6CEE3;color:#A6CEE3;"> </span><span style="display:inline-block;width:20px;background:#1F78B4;color:#1F78B4;"> </span><span style="display:inline-block;width:20px;background:#B2DF8A;color:#B2DF8A;"> </span><span style="display:inline-block;width:20px;background:#33A02C;color:#33A02C;"> </span><span style="display:inline-block;width:20px;background:#FB9A99;color:#FB9A99;"> </span><span style="display:inline-block;width:20px;background:#E31A1C;color:#E31A1C;"> </span><span style="display:inline-block;width:20px;background:#FDBF6F;color:#FDBF6F;"> </span><span style="display:inline-block;width:20px;background:#FF7F00;color:#FF7F00;"> </span><span style="display:inline-block;width:20px;background:#CAB2D6;color:#CAB2D6;"> </span><span style="display:inline-block;width:20px;background:#6A3D9A;color:#6A3D9A;"> </span><span style="display:inline-block;width:20px;background:#FFFF99;color:#FFFF99;"> </span><span style="display:inline-block;width:20px;background:#B15928;color:#B15928;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">viridis</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 256</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#440154FF;color:#440154FF;"> </span><span style="display:inline-block;width:20px;background:#440256FF;color:#440256FF;"> </span><span style="display:inline-block;width:20px;background:#450457FF;color:#450457FF;"> </span><span style="display:inline-block;width:20px;background:#450559FF;color:#450559FF;"> </span><span style="display:inline-block;width:20px;background:#46075AFF;color:#46075AFF;"> </span><span style="display:inline-block;width:20px;background:#46085CFF;color:#46085CFF;"> </span><span style="display:inline-block;width:20px;background:#460A5DFF;color:#460A5DFF;"> </span><span style="display:inline-block;width:20px;background:#460B5EFF;color:#460B5EFF;"> </span><span style="display:inline-block;width:20px;background:#470D60FF;color:#470D60FF;"> </span><span style="display:inline-block;width:20px;background:#470E61FF;color:#470E61FF;"> </span><span style="display:inline-block;width:20px;background:#471063FF;color:#471063FF;"> </span><span style="display:inline-block;width:20px;background:#471164FF;color:#471164FF;"> </span><span style="display:inline-block;width:20px;background:#471365FF;color:#471365FF;"> </span><span style="display:inline-block;width:20px;background:#481467FF;color:#481467FF;"> </span><span style="display:inline-block;width:20px;background:#481668FF;color:#481668FF;"> </span><span style="display:inline-block;width:20px;background:#481769FF;color:#481769FF;"> </span><span style="display:inline-block;width:20px;background:#48186AFF;color:#48186AFF;"> </span><span style="display:inline-block;width:20px;background:#481A6CFF;color:#481A6CFF;"> </span><span style="display:inline-block;width:20px;background:#481B6DFF;color:#481B6DFF;"> </span><span style="display:inline-block;width:20px;background:#481C6EFF;color:#481C6EFF;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Filter by pattern
pal_show(pattern = "^nord")
#> <div id="ilyjzspnat" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#ilyjzspnat table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #ilyjzspnat thead, #ilyjzspnat tbody, #ilyjzspnat tfoot, #ilyjzspnat tr, #ilyjzspnat td, #ilyjzspnat th {
#>   border-style: none;
#> }
#> 
#> #ilyjzspnat p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #ilyjzspnat .gt_table {
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
#> #ilyjzspnat .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #ilyjzspnat .gt_title {
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
#> #ilyjzspnat .gt_subtitle {
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
#> #ilyjzspnat .gt_heading {
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
#> #ilyjzspnat .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ilyjzspnat .gt_col_headings {
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
#> #ilyjzspnat .gt_col_heading {
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
#> #ilyjzspnat .gt_column_spanner_outer {
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
#> #ilyjzspnat .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #ilyjzspnat .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #ilyjzspnat .gt_column_spanner {
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
#> #ilyjzspnat .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #ilyjzspnat .gt_group_heading {
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
#> #ilyjzspnat .gt_empty_group_heading {
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
#> #ilyjzspnat .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #ilyjzspnat .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #ilyjzspnat .gt_row {
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
#> #ilyjzspnat .gt_stub {
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
#> #ilyjzspnat .gt_stub_row_group {
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
#> #ilyjzspnat .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #ilyjzspnat .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #ilyjzspnat .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ilyjzspnat .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ilyjzspnat .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #ilyjzspnat .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ilyjzspnat .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ilyjzspnat .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ilyjzspnat .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ilyjzspnat .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #ilyjzspnat .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ilyjzspnat .gt_footnotes {
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
#> #ilyjzspnat .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ilyjzspnat .gt_sourcenotes {
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
#> #ilyjzspnat .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ilyjzspnat .gt_left {
#>   text-align: left;
#> }
#> 
#> #ilyjzspnat .gt_center {
#>   text-align: center;
#> }
#> 
#> #ilyjzspnat .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #ilyjzspnat .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #ilyjzspnat .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #ilyjzspnat .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #ilyjzspnat .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #ilyjzspnat .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #ilyjzspnat .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #ilyjzspnat .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #ilyjzspnat .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #ilyjzspnat .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #ilyjzspnat .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #ilyjzspnat .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #ilyjzspnat .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #ilyjzspnat div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:190px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2E3440;color:#2E3440;"> </span><span style="display:inline-block;width:20px;background:#3B4252;color:#3B4252;"> </span><span style="display:inline-block;width:20px;background:#434C5E;color:#434C5E;"> </span><span style="display:inline-block;width:20px;background:#4C566A;color:#4C566A;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_snowstorm</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">3</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#D8DEE9;color:#D8DEE9;"> </span><span style="display:inline-block;width:20px;background:#E5E9F0;color:#E5E9F0;"> </span><span style="display:inline-block;width:20px;background:#ECEFF4;color:#ECEFF4;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_frost</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">4</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#8FBCBB;color:#8FBCBB;"> </span><span style="display:inline-block;width:20px;background:#88C0D0;color:#88C0D0;"> </span><span style="display:inline-block;width:20px;background:#81A1C1;color:#81A1C1;"> </span><span style="display:inline-block;width:20px;background:#5E81AC;color:#5E81AC;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_aurora</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#BF616A;color:#BF616A;"> </span><span style="display:inline-block;width:20px;background:#D08770;color:#D08770;"> </span><span style="display:inline-block;width:20px;background:#EBCB8B;color:#EBCB8B;"> </span><span style="display:inline-block;width:20px;background:#A3BE8C;color:#A3BE8C;"> </span><span style="display:inline-block;width:20px;background:#B48EAD;color:#B48EAD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_lumina</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#EDDAEB;color:#EDDAEB;"> </span><span style="display:inline-block;width:20px;background:#AD8CAE;color:#AD8CAE;"> </span><span style="display:inline-block;width:20px;background:#4F93B8;color:#4F93B8;"> </span><span style="display:inline-block;width:20px;background:#306489;color:#306489;"> </span><span style="display:inline-block;width:20px;background:#222B4C;color:#222B4C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_mountain_forms</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#184860;color:#184860;"> </span><span style="display:inline-block;width:20px;background:#486078;color:#486078;"> </span><span style="display:inline-block;width:20px;background:#d8d8d8;color:#d8d8d8;"> </span><span style="display:inline-block;width:20px;background:#484860;color:#484860;"> </span><span style="display:inline-block;width:20px;background:#181830;color:#181830;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_silver_mine</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4B644B;color:#4B644B;"> </span><span style="display:inline-block;width:20px;background:#647D4B;color:#647D4B;"> </span><span style="display:inline-block;width:20px;background:#E1E1E1;color:#E1E1E1;"> </span><span style="display:inline-block;width:20px;background:#7D96AF;color:#7D96AF;"> </span><span style="display:inline-block;width:20px;background:#647D96;color:#647D96;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_lake_superior</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7D4B19;color:#7D4B19;"> </span><span style="display:inline-block;width:20px;background:#C89664;color:#C89664;"> </span><span style="display:inline-block;width:20px;background:#C87d4B;color:#C87d4B;"> </span><span style="display:inline-block;width:20px;background:#4B647D;color:#4B647D;"> </span><span style="display:inline-block;width:20px;background:#324B64;color:#324B64;"> </span><span style="display:inline-block;width:20px;background:#19324B;color:#19324B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_victory_bonds</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#AF1900;color:#AF1900;"> </span><span style="display:inline-block;width:20px;background:#C83200;color:#C83200;"> </span><span style="display:inline-block;width:20px;background:#E19600;color:#E19600;"> </span><span style="display:inline-block;width:20px;background:#193264;color:#193264;"> </span><span style="display:inline-block;width:20px;background:#001964;color:#001964;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_halifax_harbor</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E1C8AF;color:#E1C8AF;"> </span><span style="display:inline-block;width:20px;background:#C8AF96;color:#C8AF96;"> </span><span style="display:inline-block;width:20px;background:#AF967D;color:#AF967D;"> </span><span style="display:inline-block;width:20px;background:#967D7D;color:#967D7D;"> </span><span style="display:inline-block;width:20px;background:#644B64;color:#644B64;"> </span><span style="display:inline-block;width:20px;background:#4B324b;color:#4B324b;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_moose_pond</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4B3232;color:#4B3232;"> </span><span style="display:inline-block;width:20px;background:#7D4B32;color:#7D4B32;"> </span><span style="display:inline-block;width:20px;background:#966432;color:#966432;"> </span><span style="display:inline-block;width:20px;background:#AF7D32;color:#AF7D32;"> </span><span style="display:inline-block;width:20px;background:#E19632;color:#E19632;"> </span><span style="display:inline-block;width:20px;background:#E1AF4B;color:#E1AF4B;"> </span><span style="display:inline-block;width:20px;background:#C8C896;color:#C8C896;"> </span><span style="display:inline-block;width:20px;background:#4B4B4B;color:#4B4B4B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_algoma_forest</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4B4B4B;color:#4B4B4B;"> </span><span style="display:inline-block;width:20px;background:#967D4B;color:#967D4B;"> </span><span style="display:inline-block;width:20px;background:#AFAF7D;color:#AFAF7D;"> </span><span style="display:inline-block;width:20px;background:#C89632;color:#C89632;"> </span><span style="display:inline-block;width:20px;background:#647D64;color:#647D64;"> </span><span style="display:inline-block;width:20px;background:#96AFAF;color:#96AFAF;"> </span><span style="display:inline-block;width:20px;background:#7D96AF;color:#7D96AF;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_rocky_mountain</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#BEBEBE;color:#BEBEBE;"> </span><span style="display:inline-block;width:20px;background:#C8C8C8;color:#C8C8C8;"> </span><span style="display:inline-block;width:20px;background:#DCD2C8;color:#DCD2C8;"> </span><span style="display:inline-block;width:20px;background:#D2C8C8;color:#D2C8C8;"> </span><span style="display:inline-block;width:20px;background:#BEBEC8;color:#BEBEC8;"> </span><span style="display:inline-block;width:20px;background:#B4B4BE;color:#B4B4BE;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_red_mountain</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7D3232;color:#7D3232;"> </span><span style="display:inline-block;width:20px;background:#7D4B4B;color:#7D4B4B;"> </span><span style="display:inline-block;width:20px;background:#7D6464;color:#7D6464;"> </span><span style="display:inline-block;width:20px;background:#AF967D;color:#AF967D;"> </span><span style="display:inline-block;width:20px;background:#FAC87D;color:#FAC87D;"> </span><span style="display:inline-block;width:20px;background:#E1AF64;color:#E1AF64;"> </span><span style="display:inline-block;width:20px;background:#C8964B;color:#C8964B;"> </span><span style="display:inline-block;width:20px;background:#32324B;color:#32324B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_baie_mouton</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#304890;color:#304890;"> </span><span style="display:inline-block;width:20px;background:#7890A8;color:#7890A8;"> </span><span style="display:inline-block;width:20px;background:#90A8C0;color:#90A8C0;"> </span><span style="display:inline-block;width:20px;background:#A8A8A8;color:#A8A8A8;"> </span><span style="display:inline-block;width:20px;background:#C0C0A8;color:#C0C0A8;"> </span><span style="display:inline-block;width:20px;background:#6A7E4F;color:#6A7E4F;"> </span><span style="display:inline-block;width:20px;background:#304848;color:#304848;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">nord_afternoon_prarie</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#486090;color:#486090;"> </span><span style="display:inline-block;width:20px;background:#6078A8;color:#6078A8;"> </span><span style="display:inline-block;width:20px;background:#7890A8;color:#7890A8;"> </span><span style="display:inline-block;width:20px;background:#90A8C0;color:#90A8C0;"> </span><span style="display:inline-block;width:20px;background:#F0D8C0;color:#F0D8C0;"> </span><span style="display:inline-block;width:20px;background:#D6BBCF;color:#D6BBCF;"> </span><span style="display:inline-block;width:20px;background:#A8C0C0;color:#A8C0C0;"> </span><span style="display:inline-block;width:20px;background:#C0D8D8;color:#C0D8D8;"> </span><span style="display:inline-block;width:20px;background:#A8A890;color:#A8A890;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "ggsci")
#> <div id="zjuxmieduh" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#zjuxmieduh table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #zjuxmieduh thead, #zjuxmieduh tbody, #zjuxmieduh tfoot, #zjuxmieduh tr, #zjuxmieduh td, #zjuxmieduh th {
#>   border-style: none;
#> }
#> 
#> #zjuxmieduh p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #zjuxmieduh .gt_table {
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
#> #zjuxmieduh .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #zjuxmieduh .gt_title {
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
#> #zjuxmieduh .gt_subtitle {
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
#> #zjuxmieduh .gt_heading {
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
#> #zjuxmieduh .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zjuxmieduh .gt_col_headings {
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
#> #zjuxmieduh .gt_col_heading {
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
#> #zjuxmieduh .gt_column_spanner_outer {
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
#> #zjuxmieduh .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #zjuxmieduh .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #zjuxmieduh .gt_column_spanner {
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
#> #zjuxmieduh .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #zjuxmieduh .gt_group_heading {
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
#> #zjuxmieduh .gt_empty_group_heading {
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
#> #zjuxmieduh .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #zjuxmieduh .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #zjuxmieduh .gt_row {
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
#> #zjuxmieduh .gt_stub {
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
#> #zjuxmieduh .gt_stub_row_group {
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
#> #zjuxmieduh .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #zjuxmieduh .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #zjuxmieduh .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zjuxmieduh .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #zjuxmieduh .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #zjuxmieduh .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zjuxmieduh .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zjuxmieduh .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #zjuxmieduh .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zjuxmieduh .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #zjuxmieduh .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zjuxmieduh .gt_footnotes {
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
#> #zjuxmieduh .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zjuxmieduh .gt_sourcenotes {
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
#> #zjuxmieduh .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zjuxmieduh .gt_left {
#>   text-align: left;
#> }
#> 
#> #zjuxmieduh .gt_center {
#>   text-align: center;
#> }
#> 
#> #zjuxmieduh .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #zjuxmieduh .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #zjuxmieduh .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #zjuxmieduh .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #zjuxmieduh .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #zjuxmieduh .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #zjuxmieduh .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #zjuxmieduh .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #zjuxmieduh .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #zjuxmieduh .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #zjuxmieduh .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #zjuxmieduh .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #zjuxmieduh .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #zjuxmieduh div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:410px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E64B35;color:#E64B35;"> </span><span style="display:inline-block;width:20px;background:#4DBBD5;color:#4DBBD5;"> </span><span style="display:inline-block;width:20px;background:#00A087;color:#00A087;"> </span><span style="display:inline-block;width:20px;background:#3C5488;color:#3C5488;"> </span><span style="display:inline-block;width:20px;background:#F39B7F;color:#F39B7F;"> </span><span style="display:inline-block;width:20px;background:#8491B4;color:#8491B4;"> </span><span style="display:inline-block;width:20px;background:#91D1C2;color:#91D1C2;"> </span><span style="display:inline-block;width:20px;background:#DC0000;color:#DC0000;"> </span><span style="display:inline-block;width:20px;background:#7E6148;color:#7E6148;"> </span><span style="display:inline-block;width:20px;background:#B09C85;color:#B09C85;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_aaas_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#3B4992;color:#3B4992;"> </span><span style="display:inline-block;width:20px;background:#EE0000;color:#EE0000;"> </span><span style="display:inline-block;width:20px;background:#008B45;color:#008B45;"> </span><span style="display:inline-block;width:20px;background:#631879;color:#631879;"> </span><span style="display:inline-block;width:20px;background:#008280;color:#008280;"> </span><span style="display:inline-block;width:20px;background:#BB0021;color:#BB0021;"> </span><span style="display:inline-block;width:20px;background:#5F559B;color:#5F559B;"> </span><span style="display:inline-block;width:20px;background:#A20056;color:#A20056;"> </span><span style="display:inline-block;width:20px;background:#808180;color:#808180;"> </span><span style="display:inline-block;width:20px;background:#1B1919;color:#1B1919;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_nejm_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#BC3C29;color:#BC3C29;"> </span><span style="display:inline-block;width:20px;background:#0072B5;color:#0072B5;"> </span><span style="display:inline-block;width:20px;background:#E18727;color:#E18727;"> </span><span style="display:inline-block;width:20px;background:#20854E;color:#20854E;"> </span><span style="display:inline-block;width:20px;background:#7876B1;color:#7876B1;"> </span><span style="display:inline-block;width:20px;background:#6F99AD;color:#6F99AD;"> </span><span style="display:inline-block;width:20px;background:#FFDC91;color:#FFDC91;"> </span><span style="display:inline-block;width:20px;background:#EE4C97;color:#EE4C97;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_lancet_lanonc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#00468B;color:#00468B;"> </span><span style="display:inline-block;width:20px;background:#ED0000;color:#ED0000;"> </span><span style="display:inline-block;width:20px;background:#42B540;color:#42B540;"> </span><span style="display:inline-block;width:20px;background:#0099B4;color:#0099B4;"> </span><span style="display:inline-block;width:20px;background:#925E9F;color:#925E9F;"> </span><span style="display:inline-block;width:20px;background:#FDAF91;color:#FDAF91;"> </span><span style="display:inline-block;width:20px;background:#AD002A;color:#AD002A;"> </span><span style="display:inline-block;width:20px;background:#ADB6B6;color:#ADB6B6;"> </span><span style="display:inline-block;width:20px;background:#1B1919;color:#1B1919;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_jama_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#374E55;color:#374E55;"> </span><span style="display:inline-block;width:20px;background:#DF8F44;color:#DF8F44;"> </span><span style="display:inline-block;width:20px;background:#00A1D5;color:#00A1D5;"> </span><span style="display:inline-block;width:20px;background:#B24745;color:#B24745;"> </span><span style="display:inline-block;width:20px;background:#79AF97;color:#79AF97;"> </span><span style="display:inline-block;width:20px;background:#6A6599;color:#6A6599;"> </span><span style="display:inline-block;width:20px;background:#80796B;color:#80796B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bmj_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2A6EBB;color:#2A6EBB;"> </span><span style="display:inline-block;width:20px;background:#F0AB00;color:#F0AB00;"> </span><span style="display:inline-block;width:20px;background:#C50084;color:#C50084;"> </span><span style="display:inline-block;width:20px;background:#7D5CC6;color:#7D5CC6;"> </span><span style="display:inline-block;width:20px;background:#E37222;color:#E37222;"> </span><span style="display:inline-block;width:20px;background:#69BE28;color:#69BE28;"> </span><span style="display:inline-block;width:20px;background:#00B2A9;color:#00B2A9;"> </span><span style="display:inline-block;width:20px;background:#CD202C;color:#CD202C;"> </span><span style="display:inline-block;width:20px;background:#747678;color:#747678;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_jco_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#0073C2;color:#0073C2;"> </span><span style="display:inline-block;width:20px;background:#EFC000;color:#EFC000;"> </span><span style="display:inline-block;width:20px;background:#868686;color:#868686;"> </span><span style="display:inline-block;width:20px;background:#CD534C;color:#CD534C;"> </span><span style="display:inline-block;width:20px;background:#7AA6DC;color:#7AA6DC;"> </span><span style="display:inline-block;width:20px;background:#003C67;color:#003C67;"> </span><span style="display:inline-block;width:20px;background:#8F7700;color:#8F7700;"> </span><span style="display:inline-block;width:20px;background:#3B3B3B;color:#3B3B3B;"> </span><span style="display:inline-block;width:20px;background:#A73030;color:#A73030;"> </span><span style="display:inline-block;width:20px;background:#4A6990;color:#4A6990;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_ucscgb_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 26</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FF0000;color:#FF0000;"> </span><span style="display:inline-block;width:20px;background:#FF9900;color:#FF9900;"> </span><span style="display:inline-block;width:20px;background:#FFCC00;color:#FFCC00;"> </span><span style="display:inline-block;width:20px;background:#00FF00;color:#00FF00;"> </span><span style="display:inline-block;width:20px;background:#6699FF;color:#6699FF;"> </span><span style="display:inline-block;width:20px;background:#CC33FF;color:#CC33FF;"> </span><span style="display:inline-block;width:20px;background:#99991E;color:#99991E;"> </span><span style="display:inline-block;width:20px;background:#999999;color:#999999;"> </span><span style="display:inline-block;width:20px;background:#FF00CC;color:#FF00CC;"> </span><span style="display:inline-block;width:20px;background:#CC0000;color:#CC0000;"> </span><span style="display:inline-block;width:20px;background:#FFCCCC;color:#FFCCCC;"> </span><span style="display:inline-block;width:20px;background:#FFFF00;color:#FFFF00;"> </span><span style="display:inline-block;width:20px;background:#CCFF00;color:#CCFF00;"> </span><span style="display:inline-block;width:20px;background:#358000;color:#358000;"> </span><span style="display:inline-block;width:20px;background:#0000CC;color:#0000CC;"> </span><span style="display:inline-block;width:20px;background:#99CCFF;color:#99CCFF;"> </span><span style="display:inline-block;width:20px;background:#00FFFF;color:#00FFFF;"> </span><span style="display:inline-block;width:20px;background:#CCFFFF;color:#CCFFFF;"> </span><span style="display:inline-block;width:20px;background:#9900CC;color:#9900CC;"> </span><span style="display:inline-block;width:20px;background:#CC99FF;color:#CC99FF;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category10</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#1F77B4;color:#1F77B4;"> </span><span style="display:inline-block;width:20px;background:#FF7F0E;color:#FF7F0E;"> </span><span style="display:inline-block;width:20px;background:#2CA02C;color:#2CA02C;"> </span><span style="display:inline-block;width:20px;background:#D62728;color:#D62728;"> </span><span style="display:inline-block;width:20px;background:#9467BD;color:#9467BD;"> </span><span style="display:inline-block;width:20px;background:#8C564B;color:#8C564B;"> </span><span style="display:inline-block;width:20px;background:#E377C2;color:#E377C2;"> </span><span style="display:inline-block;width:20px;background:#7F7F7F;color:#7F7F7F;"> </span><span style="display:inline-block;width:20px;background:#BCBD22;color:#BCBD22;"> </span><span style="display:inline-block;width:20px;background:#17BECF;color:#17BECF;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category20</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#1F77B4;color:#1F77B4;"> </span><span style="display:inline-block;width:20px;background:#FF7F0E;color:#FF7F0E;"> </span><span style="display:inline-block;width:20px;background:#2CA02C;color:#2CA02C;"> </span><span style="display:inline-block;width:20px;background:#D62728;color:#D62728;"> </span><span style="display:inline-block;width:20px;background:#9467BD;color:#9467BD;"> </span><span style="display:inline-block;width:20px;background:#8C564B;color:#8C564B;"> </span><span style="display:inline-block;width:20px;background:#E377C2;color:#E377C2;"> </span><span style="display:inline-block;width:20px;background:#7F7F7F;color:#7F7F7F;"> </span><span style="display:inline-block;width:20px;background:#BCBD22;color:#BCBD22;"> </span><span style="display:inline-block;width:20px;background:#17BECF;color:#17BECF;"> </span><span style="display:inline-block;width:20px;background:#AEC7E8;color:#AEC7E8;"> </span><span style="display:inline-block;width:20px;background:#FFBB78;color:#FFBB78;"> </span><span style="display:inline-block;width:20px;background:#98DF8A;color:#98DF8A;"> </span><span style="display:inline-block;width:20px;background:#FF9896;color:#FF9896;"> </span><span style="display:inline-block;width:20px;background:#C5B0D5;color:#C5B0D5;"> </span><span style="display:inline-block;width:20px;background:#C49C94;color:#C49C94;"> </span><span style="display:inline-block;width:20px;background:#F7B6D2;color:#F7B6D2;"> </span><span style="display:inline-block;width:20px;background:#C7C7C7;color:#C7C7C7;"> </span><span style="display:inline-block;width:20px;background:#DBDB8D;color:#DBDB8D;"> </span><span style="display:inline-block;width:20px;background:#9EDAE5;color:#9EDAE5;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category20b</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#393B79;color:#393B79;"> </span><span style="display:inline-block;width:20px;background:#637939;color:#637939;"> </span><span style="display:inline-block;width:20px;background:#8C6D31;color:#8C6D31;"> </span><span style="display:inline-block;width:20px;background:#843C39;color:#843C39;"> </span><span style="display:inline-block;width:20px;background:#7B4173;color:#7B4173;"> </span><span style="display:inline-block;width:20px;background:#5254A3;color:#5254A3;"> </span><span style="display:inline-block;width:20px;background:#8CA252;color:#8CA252;"> </span><span style="display:inline-block;width:20px;background:#BD9E39;color:#BD9E39;"> </span><span style="display:inline-block;width:20px;background:#AD494A;color:#AD494A;"> </span><span style="display:inline-block;width:20px;background:#A55194;color:#A55194;"> </span><span style="display:inline-block;width:20px;background:#6B6ECF;color:#6B6ECF;"> </span><span style="display:inline-block;width:20px;background:#B5CF6B;color:#B5CF6B;"> </span><span style="display:inline-block;width:20px;background:#E7BA52;color:#E7BA52;"> </span><span style="display:inline-block;width:20px;background:#D6616B;color:#D6616B;"> </span><span style="display:inline-block;width:20px;background:#CE6DBD;color:#CE6DBD;"> </span><span style="display:inline-block;width:20px;background:#9C9EDE;color:#9C9EDE;"> </span><span style="display:inline-block;width:20px;background:#CEDB9C;color:#CEDB9C;"> </span><span style="display:inline-block;width:20px;background:#E7CB94;color:#E7CB94;"> </span><span style="display:inline-block;width:20px;background:#E7969C;color:#E7969C;"> </span><span style="display:inline-block;width:20px;background:#DE9ED6;color:#DE9ED6;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_d3_category20c</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#3182BD;color:#3182BD;"> </span><span style="display:inline-block;width:20px;background:#E6550D;color:#E6550D;"> </span><span style="display:inline-block;width:20px;background:#31A354;color:#31A354;"> </span><span style="display:inline-block;width:20px;background:#756BB1;color:#756BB1;"> </span><span style="display:inline-block;width:20px;background:#636363;color:#636363;"> </span><span style="display:inline-block;width:20px;background:#6BAED6;color:#6BAED6;"> </span><span style="display:inline-block;width:20px;background:#FD8D3C;color:#FD8D3C;"> </span><span style="display:inline-block;width:20px;background:#74C476;color:#74C476;"> </span><span style="display:inline-block;width:20px;background:#9E9AC8;color:#9E9AC8;"> </span><span style="display:inline-block;width:20px;background:#969696;color:#969696;"> </span><span style="display:inline-block;width:20px;background:#9ECAE1;color:#9ECAE1;"> </span><span style="display:inline-block;width:20px;background:#FDAE6B;color:#FDAE6B;"> </span><span style="display:inline-block;width:20px;background:#A1D99B;color:#A1D99B;"> </span><span style="display:inline-block;width:20px;background:#BCBDDC;color:#BCBDDC;"> </span><span style="display:inline-block;width:20px;background:#BDBDBD;color:#BDBDBD;"> </span><span style="display:inline-block;width:20px;background:#C6DBEF;color:#C6DBEF;"> </span><span style="display:inline-block;width:20px;background:#FDD0A2;color:#FDD0A2;"> </span><span style="display:inline-block;width:20px;background:#C7E9C0;color:#C7E9C0;"> </span><span style="display:inline-block;width:20px;background:#DADAEB;color:#DADAEB;"> </span><span style="display:inline-block;width:20px;background:#D9D9D9;color:#D9D9D9;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_observable_observable10</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4269D0;color:#4269D0;"> </span><span style="display:inline-block;width:20px;background:#EFB118;color:#EFB118;"> </span><span style="display:inline-block;width:20px;background:#FF725C;color:#FF725C;"> </span><span style="display:inline-block;width:20px;background:#6CC5B0;color:#6CC5B0;"> </span><span style="display:inline-block;width:20px;background:#3CA951;color:#3CA951;"> </span><span style="display:inline-block;width:20px;background:#FF8AB7;color:#FF8AB7;"> </span><span style="display:inline-block;width:20px;background:#A463F2;color:#A463F2;"> </span><span style="display:inline-block;width:20px;background:#97BBF5;color:#97BBF5;"> </span><span style="display:inline-block;width:20px;background:#9C6B4E;color:#9C6B4E;"> </span><span style="display:inline-block;width:20px;background:#9498A0;color:#9498A0;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_primer_mark17</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#006EDB;color:#006EDB;"> </span><span style="display:inline-block;width:20px;background:#EB670F;color:#EB670F;"> </span><span style="display:inline-block;width:20px;background:#DF0C24;color:#DF0C24;"> </span><span style="display:inline-block;width:20px;background:#179B9B;color:#179B9B;"> </span><span style="display:inline-block;width:20px;background:#30A147;color:#30A147;"> </span><span style="display:inline-block;width:20px;background:#894CEB;color:#894CEB;"> </span><span style="display:inline-block;width:20px;background:#B88700;color:#B88700;"> </span><span style="display:inline-block;width:20px;background:#CE2C85;color:#CE2C85;"> </span><span style="display:inline-block;width:20px;background:#856D4C;color:#856D4C;"> </span><span style="display:inline-block;width:20px;background:#527A29;color:#527A29;"> </span><span style="display:inline-block;width:20px;background:#D43511;color:#D43511;"> </span><span style="display:inline-block;width:20px;background:#167E53;color:#167E53;"> </span><span style="display:inline-block;width:20px;background:#9D615C;color:#9D615C;"> </span><span style="display:inline-block;width:20px;background:#64762D;color:#64762D;"> </span><span style="display:inline-block;width:20px;background:#A830E8;color:#A830E8;"> </span><span style="display:inline-block;width:20px;background:#866E04;color:#866E04;"> </span><span style="display:inline-block;width:20px;background:#808FA3;color:#808FA3;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_atlassian_categorical8</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4688EC;color:#4688EC;"> </span><span style="display:inline-block;width:20px;background:#94C748;color:#94C748;"> </span><span style="display:inline-block;width:20px;background:#C97CF4;color:#C97CF4;"> </span><span style="display:inline-block;width:20px;background:#FCA700;color:#FCA700;"> </span><span style="display:inline-block;width:20px;background:#1558BC;color:#1558BC;"> </span><span style="display:inline-block;width:20px;background:#964AC0;color:#964AC0;"> </span><span style="display:inline-block;width:20px;background:#42B2D7;color:#42B2D7;"> </span><span style="display:inline-block;width:20px;background:#E06C00;color:#E06C00;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_igv_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 51</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#5050FF;color:#5050FF;"> </span><span style="display:inline-block;width:20px;background:#CE3D32;color:#CE3D32;"> </span><span style="display:inline-block;width:20px;background:#749B58;color:#749B58;"> </span><span style="display:inline-block;width:20px;background:#F0E685;color:#F0E685;"> </span><span style="display:inline-block;width:20px;background:#466983;color:#466983;"> </span><span style="display:inline-block;width:20px;background:#BA6338;color:#BA6338;"> </span><span style="display:inline-block;width:20px;background:#5DB1DD;color:#5DB1DD;"> </span><span style="display:inline-block;width:20px;background:#802268;color:#802268;"> </span><span style="display:inline-block;width:20px;background:#6BD76B;color:#6BD76B;"> </span><span style="display:inline-block;width:20px;background:#D595A7;color:#D595A7;"> </span><span style="display:inline-block;width:20px;background:#924822;color:#924822;"> </span><span style="display:inline-block;width:20px;background:#837B8D;color:#837B8D;"> </span><span style="display:inline-block;width:20px;background:#C75127;color:#C75127;"> </span><span style="display:inline-block;width:20px;background:#D58F5C;color:#D58F5C;"> </span><span style="display:inline-block;width:20px;background:#7A65A5;color:#7A65A5;"> </span><span style="display:inline-block;width:20px;background:#E4AF69;color:#E4AF69;"> </span><span style="display:inline-block;width:20px;background:#3B1B53;color:#3B1B53;"> </span><span style="display:inline-block;width:20px;background:#CDDEB7;color:#CDDEB7;"> </span><span style="display:inline-block;width:20px;background:#612A79;color:#612A79;"> </span><span style="display:inline-block;width:20px;background:#AE1F63;color:#AE1F63;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_igv_alternating</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">2</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#5773CC;color:#5773CC;"> </span><span style="display:inline-block;width:20px;background:#FFB900;color:#FFB900;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_locuszoom_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#D43F3A;color:#D43F3A;"> </span><span style="display:inline-block;width:20px;background:#EEA236;color:#EEA236;"> </span><span style="display:inline-block;width:20px;background:#5CB85C;color:#5CB85C;"> </span><span style="display:inline-block;width:20px;background:#46B8DA;color:#46B8DA;"> </span><span style="display:inline-block;width:20px;background:#357EBD;color:#357EBD;"> </span><span style="display:inline-block;width:20px;background:#9632B8;color:#9632B8;"> </span><span style="display:inline-block;width:20px;background:#B8B8B8;color:#B8B8B8;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_uchicago_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#800000;color:#800000;"> </span><span style="display:inline-block;width:20px;background:#767676;color:#767676;"> </span><span style="display:inline-block;width:20px;background:#FFA319;color:#FFA319;"> </span><span style="display:inline-block;width:20px;background:#8A9045;color:#8A9045;"> </span><span style="display:inline-block;width:20px;background:#155F83;color:#155F83;"> </span><span style="display:inline-block;width:20px;background:#C16622;color:#C16622;"> </span><span style="display:inline-block;width:20px;background:#8F3931;color:#8F3931;"> </span><span style="display:inline-block;width:20px;background:#58593F;color:#58593F;"> </span><span style="display:inline-block;width:20px;background:#350E20;color:#350E20;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_uchicago_light</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#800000;color:#800000;"> </span><span style="display:inline-block;width:20px;background:#D6D6CE;color:#D6D6CE;"> </span><span style="display:inline-block;width:20px;background:#FFB547;color:#FFB547;"> </span><span style="display:inline-block;width:20px;background:#ADB17D;color:#ADB17D;"> </span><span style="display:inline-block;width:20px;background:#5B8FA8;color:#5B8FA8;"> </span><span style="display:inline-block;width:20px;background:#D49464;color:#D49464;"> </span><span style="display:inline-block;width:20px;background:#B1746F;color:#B1746F;"> </span><span style="display:inline-block;width:20px;background:#8A8B79;color:#8A8B79;"> </span><span style="display:inline-block;width:20px;background:#725663;color:#725663;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_uchicago_dark</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#800000;color:#800000;"> </span><span style="display:inline-block;width:20px;background:#767676;color:#767676;"> </span><span style="display:inline-block;width:20px;background:#CC8214;color:#CC8214;"> </span><span style="display:inline-block;width:20px;background:#616530;color:#616530;"> </span><span style="display:inline-block;width:20px;background:#0F425C;color:#0F425C;"> </span><span style="display:inline-block;width:20px;background:#9A5324;color:#9A5324;"> </span><span style="display:inline-block;width:20px;background:#642822;color:#642822;"> </span><span style="display:inline-block;width:20px;background:#3E3E23;color:#3E3E23;"> </span><span style="display:inline-block;width:20px;background:#350E20;color:#350E20;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_cosmic_hallmarks_dark</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#171717;color:#171717;"> </span><span style="display:inline-block;width:20px;background:#7D0226;color:#7D0226;"> </span><span style="display:inline-block;width:20px;background:#300049;color:#300049;"> </span><span style="display:inline-block;width:20px;background:#165459;color:#165459;"> </span><span style="display:inline-block;width:20px;background:#3F2327;color:#3F2327;"> </span><span style="display:inline-block;width:20px;background:#0B1948;color:#0B1948;"> </span><span style="display:inline-block;width:20px;background:#E71012;color:#E71012;"> </span><span style="display:inline-block;width:20px;background:#555555;color:#555555;"> </span><span style="display:inline-block;width:20px;background:#193006;color:#193006;"> </span><span style="display:inline-block;width:20px;background:#A8450C;color:#A8450C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_cosmic_hallmarks_light</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2E2A2B;color:#2E2A2B;"> </span><span style="display:inline-block;width:20px;background:#CF4E9C;color:#CF4E9C;"> </span><span style="display:inline-block;width:20px;background:#8C57A2;color:#8C57A2;"> </span><span style="display:inline-block;width:20px;background:#358DB9;color:#358DB9;"> </span><span style="display:inline-block;width:20px;background:#82581F;color:#82581F;"> </span><span style="display:inline-block;width:20px;background:#2F509E;color:#2F509E;"> </span><span style="display:inline-block;width:20px;background:#E5614C;color:#E5614C;"> </span><span style="display:inline-block;width:20px;background:#97A1A7;color:#97A1A7;"> </span><span style="display:inline-block;width:20px;background:#3DA873;color:#3DA873;"> </span><span style="display:inline-block;width:20px;background:#DC9445;color:#DC9445;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_cosmic_signature_substitutions</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">6</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#5ABCEB;color:#5ABCEB;"> </span><span style="display:inline-block;width:20px;background:#050708;color:#050708;"> </span><span style="display:inline-block;width:20px;background:#D33C32;color:#D33C32;"> </span><span style="display:inline-block;width:20px;background:#CBCACB;color:#CBCACB;"> </span><span style="display:inline-block;width:20px;background:#ABCD72;color:#ABCD72;"> </span><span style="display:inline-block;width:20px;background:#E7C9C6;color:#E7C9C6;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_simpsons_springfield</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">16</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FED439;color:#FED439;"> </span><span style="display:inline-block;width:20px;background:#709AE1;color:#709AE1;"> </span><span style="display:inline-block;width:20px;background:#8A9197;color:#8A9197;"> </span><span style="display:inline-block;width:20px;background:#D2AF81;color:#D2AF81;"> </span><span style="display:inline-block;width:20px;background:#FD7446;color:#FD7446;"> </span><span style="display:inline-block;width:20px;background:#D5E4A2;color:#D5E4A2;"> </span><span style="display:inline-block;width:20px;background:#197EC0;color:#197EC0;"> </span><span style="display:inline-block;width:20px;background:#F05C3B;color:#F05C3B;"> </span><span style="display:inline-block;width:20px;background:#46732E;color:#46732E;"> </span><span style="display:inline-block;width:20px;background:#71D0F5;color:#71D0F5;"> </span><span style="display:inline-block;width:20px;background:#370335;color:#370335;"> </span><span style="display:inline-block;width:20px;background:#075149;color:#075149;"> </span><span style="display:inline-block;width:20px;background:#C80813;color:#C80813;"> </span><span style="display:inline-block;width:20px;background:#91331F;color:#91331F;"> </span><span style="display:inline-block;width:20px;background:#1A9993;color:#1A9993;"> </span><span style="display:inline-block;width:20px;background:#FD8CC1;color:#FD8CC1;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_futurama_planetexpress</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FF6F00;color:#FF6F00;"> </span><span style="display:inline-block;width:20px;background:#C71000;color:#C71000;"> </span><span style="display:inline-block;width:20px;background:#008EA0;color:#008EA0;"> </span><span style="display:inline-block;width:20px;background:#8A4198;color:#8A4198;"> </span><span style="display:inline-block;width:20px;background:#5A9599;color:#5A9599;"> </span><span style="display:inline-block;width:20px;background:#FF6348;color:#FF6348;"> </span><span style="display:inline-block;width:20px;background:#84D7E1;color:#84D7E1;"> </span><span style="display:inline-block;width:20px;background:#FF95A8;color:#FF95A8;"> </span><span style="display:inline-block;width:20px;background:#3D3B25;color:#3D3B25;"> </span><span style="display:inline-block;width:20px;background:#ADE2D0;color:#ADE2D0;"> </span><span style="display:inline-block;width:20px;background:#1A5354;color:#1A5354;"> </span><span style="display:inline-block;width:20px;background:#3F4041;color:#3F4041;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_rickandmorty_schwifty</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FAFD7C;color:#FAFD7C;"> </span><span style="display:inline-block;width:20px;background:#82491E;color:#82491E;"> </span><span style="display:inline-block;width:20px;background:#24325F;color:#24325F;"> </span><span style="display:inline-block;width:20px;background:#B7E4F9;color:#B7E4F9;"> </span><span style="display:inline-block;width:20px;background:#FB6467;color:#FB6467;"> </span><span style="display:inline-block;width:20px;background:#526E2D;color:#526E2D;"> </span><span style="display:inline-block;width:20px;background:#E762D7;color:#E762D7;"> </span><span style="display:inline-block;width:20px;background:#E89242;color:#E89242;"> </span><span style="display:inline-block;width:20px;background:#FAE48B;color:#FAE48B;"> </span><span style="display:inline-block;width:20px;background:#A6EEE6;color:#A6EEE6;"> </span><span style="display:inline-block;width:20px;background:#917C5D;color:#917C5D;"> </span><span style="display:inline-block;width:20px;background:#69C8EC;color:#69C8EC;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_startrek_uniform</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#CC0C00;color:#CC0C00;"> </span><span style="display:inline-block;width:20px;background:#5C88DA;color:#5C88DA;"> </span><span style="display:inline-block;width:20px;background:#84BD00;color:#84BD00;"> </span><span style="display:inline-block;width:20px;background:#FFCD00;color:#FFCD00;"> </span><span style="display:inline-block;width:20px;background:#7C878E;color:#7C878E;"> </span><span style="display:inline-block;width:20px;background:#00B5E2;color:#00B5E2;"> </span><span style="display:inline-block;width:20px;background:#00AF66;color:#00AF66;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tron_legacy</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FF410D;color:#FF410D;"> </span><span style="display:inline-block;width:20px;background:#6EE2FF;color:#6EE2FF;"> </span><span style="display:inline-block;width:20px;background:#F7C530;color:#F7C530;"> </span><span style="display:inline-block;width:20px;background:#95CC5E;color:#95CC5E;"> </span><span style="display:inline-block;width:20px;background:#D0DFE6;color:#D0DFE6;"> </span><span style="display:inline-block;width:20px;background:#F79D1E;color:#F79D1E;"> </span><span style="display:inline-block;width:20px;background:#748AA6;color:#748AA6;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_frontiers_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#D51317;color:#D51317;"> </span><span style="display:inline-block;width:20px;background:#F39200;color:#F39200;"> </span><span style="display:inline-block;width:20px;background:#EFD500;color:#EFD500;"> </span><span style="display:inline-block;width:20px;background:#95C11F;color:#95C11F;"> </span><span style="display:inline-block;width:20px;background:#007B3D;color:#007B3D;"> </span><span style="display:inline-block;width:20px;background:#31B7BC;color:#31B7BC;"> </span><span style="display:inline-block;width:20px;background:#0094CD;color:#0094CD;"> </span><span style="display:inline-block;width:20px;background:#164194;color:#164194;"> </span><span style="display:inline-block;width:20px;background:#6F286A;color:#6F286A;"> </span><span style="display:inline-block;width:20px;background:#706F6F;color:#706F6F;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_flatui_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#c0392b;color:#c0392b;"> </span><span style="display:inline-block;width:20px;background:#d35400;color:#d35400;"> </span><span style="display:inline-block;width:20px;background:#f39c12;color:#f39c12;"> </span><span style="display:inline-block;width:20px;background:#27ae60;color:#27ae60;"> </span><span style="display:inline-block;width:20px;background:#16a085;color:#16a085;"> </span><span style="display:inline-block;width:20px;background:#2980b9;color:#2980b9;"> </span><span style="display:inline-block;width:20px;background:#8e44ad;color:#8e44ad;"> </span><span style="display:inline-block;width:20px;background:#2c3e50;color:#2c3e50;"> </span><span style="display:inline-block;width:20px;background:#7f8c8d;color:#7f8c8d;"> </span><span style="display:inline-block;width:20px;background:#bdc3c7;color:#bdc3c7;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_flatui_flattastic</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#DA4453;color:#DA4453;"> </span><span style="display:inline-block;width:20px;background:#E95546;color:#E95546;"> </span><span style="display:inline-block;width:20px;background:#F6BA59;color:#F6BA59;"> </span><span style="display:inline-block;width:20px;background:#8BC163;color:#8BC163;"> </span><span style="display:inline-block;width:20px;background:#34BC9D;color:#34BC9D;"> </span><span style="display:inline-block;width:20px;background:#3BB0D6;color:#3BB0D6;"> </span><span style="display:inline-block;width:20px;background:#4B8AD6;color:#4B8AD6;"> </span><span style="display:inline-block;width:20px;background:#977BD5;color:#977BD5;"> </span><span style="display:inline-block;width:20px;background:#D870A9;color:#D870A9;"> </span><span style="display:inline-block;width:20px;background:#E6E9ED;color:#E6E9ED;"> </span><span style="display:inline-block;width:20px;background:#AAB2BC;color:#AAB2BC;"> </span><span style="display:inline-block;width:20px;background:#434A53;color:#434A53;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_flatui_aussie</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F9CA24;color:#F9CA24;"> </span><span style="display:inline-block;width:20px;background:#F0932B;color:#F0932B;"> </span><span style="display:inline-block;width:20px;background:#EB4D4B;color:#EB4D4B;"> </span><span style="display:inline-block;width:20px;background:#6AB04C;color:#6AB04C;"> </span><span style="display:inline-block;width:20px;background:#C7ECEE;color:#C7ECEE;"> </span><span style="display:inline-block;width:20px;background:#22A6B3;color:#22A6B3;"> </span><span style="display:inline-block;width:20px;background:#BE2EDD;color:#BE2EDD;"> </span><span style="display:inline-block;width:20px;background:#4834D4;color:#4834D4;"> </span><span style="display:inline-block;width:20px;background:#130F40;color:#130F40;"> </span><span style="display:inline-block;width:20px;background:#535C68;color:#535C68;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_gsea_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4500AD;color:#4500AD;"> </span><span style="display:inline-block;width:20px;background:#2700D1;color:#2700D1;"> </span><span style="display:inline-block;width:20px;background:#6B58EF;color:#6B58EF;"> </span><span style="display:inline-block;width:20px;background:#8888FF;color:#8888FF;"> </span><span style="display:inline-block;width:20px;background:#C7C1FF;color:#C7C1FF;"> </span><span style="display:inline-block;width:20px;background:#D5D5FF;color:#D5D5FF;"> </span><span style="display:inline-block;width:20px;background:#FFC0E5;color:#FFC0E5;"> </span><span style="display:inline-block;width:20px;background:#FF8989;color:#FF8989;"> </span><span style="display:inline-block;width:20px;background:#FF7080;color:#FF7080;"> </span><span style="display:inline-block;width:20px;background:#FF5A5A;color:#FF5A5A;"> </span><span style="display:inline-block;width:20px;background:#EF4040;color:#EF4040;"> </span><span style="display:inline-block;width:20px;background:#D60C00;color:#D60C00;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#cfe2ff;color:#cfe2ff;"> </span><span style="display:inline-block;width:20px;background:#9ec5fe;color:#9ec5fe;"> </span><span style="display:inline-block;width:20px;background:#6ea8fe;color:#6ea8fe;"> </span><span style="display:inline-block;width:20px;background:#3d8bfd;color:#3d8bfd;"> </span><span style="display:inline-block;width:20px;background:#0d6efd;color:#0d6efd;"> </span><span style="display:inline-block;width:20px;background:#0a58ca;color:#0a58ca;"> </span><span style="display:inline-block;width:20px;background:#084298;color:#084298;"> </span><span style="display:inline-block;width:20px;background:#052c65;color:#052c65;"> </span><span style="display:inline-block;width:20px;background:#031633;color:#031633;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_indigo</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#e0cffc;color:#e0cffc;"> </span><span style="display:inline-block;width:20px;background:#c29ffa;color:#c29ffa;"> </span><span style="display:inline-block;width:20px;background:#a370f7;color:#a370f7;"> </span><span style="display:inline-block;width:20px;background:#8540f5;color:#8540f5;"> </span><span style="display:inline-block;width:20px;background:#6610f2;color:#6610f2;"> </span><span style="display:inline-block;width:20px;background:#520dc2;color:#520dc2;"> </span><span style="display:inline-block;width:20px;background:#3d0a91;color:#3d0a91;"> </span><span style="display:inline-block;width:20px;background:#290661;color:#290661;"> </span><span style="display:inline-block;width:20px;background:#140330;color:#140330;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#e2d9f3;color:#e2d9f3;"> </span><span style="display:inline-block;width:20px;background:#c5b3e6;color:#c5b3e6;"> </span><span style="display:inline-block;width:20px;background:#a98eda;color:#a98eda;"> </span><span style="display:inline-block;width:20px;background:#8c68cd;color:#8c68cd;"> </span><span style="display:inline-block;width:20px;background:#6f42c1;color:#6f42c1;"> </span><span style="display:inline-block;width:20px;background:#59359a;color:#59359a;"> </span><span style="display:inline-block;width:20px;background:#432874;color:#432874;"> </span><span style="display:inline-block;width:20px;background:#2c1a4d;color:#2c1a4d;"> </span><span style="display:inline-block;width:20px;background:#160d27;color:#160d27;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_pink</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f7d6e6;color:#f7d6e6;"> </span><span style="display:inline-block;width:20px;background:#efadce;color:#efadce;"> </span><span style="display:inline-block;width:20px;background:#e685b5;color:#e685b5;"> </span><span style="display:inline-block;width:20px;background:#de5c9d;color:#de5c9d;"> </span><span style="display:inline-block;width:20px;background:#d63384;color:#d63384;"> </span><span style="display:inline-block;width:20px;background:#ab296a;color:#ab296a;"> </span><span style="display:inline-block;width:20px;background:#801f4f;color:#801f4f;"> </span><span style="display:inline-block;width:20px;background:#561435;color:#561435;"> </span><span style="display:inline-block;width:20px;background:#2b0a1a;color:#2b0a1a;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_red</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f8d7da;color:#f8d7da;"> </span><span style="display:inline-block;width:20px;background:#f1aeb5;color:#f1aeb5;"> </span><span style="display:inline-block;width:20px;background:#ea868f;color:#ea868f;"> </span><span style="display:inline-block;width:20px;background:#e35d6a;color:#e35d6a;"> </span><span style="display:inline-block;width:20px;background:#dc3545;color:#dc3545;"> </span><span style="display:inline-block;width:20px;background:#b02a37;color:#b02a37;"> </span><span style="display:inline-block;width:20px;background:#842029;color:#842029;"> </span><span style="display:inline-block;width:20px;background:#58151c;color:#58151c;"> </span><span style="display:inline-block;width:20px;background:#2c0b0e;color:#2c0b0e;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#ffe5d0;color:#ffe5d0;"> </span><span style="display:inline-block;width:20px;background:#fecba1;color:#fecba1;"> </span><span style="display:inline-block;width:20px;background:#feb272;color:#feb272;"> </span><span style="display:inline-block;width:20px;background:#fd9843;color:#fd9843;"> </span><span style="display:inline-block;width:20px;background:#fd7e14;color:#fd7e14;"> </span><span style="display:inline-block;width:20px;background:#ca6510;color:#ca6510;"> </span><span style="display:inline-block;width:20px;background:#984c0c;color:#984c0c;"> </span><span style="display:inline-block;width:20px;background:#653208;color:#653208;"> </span><span style="display:inline-block;width:20px;background:#331904;color:#331904;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_yellow</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fff3cd;color:#fff3cd;"> </span><span style="display:inline-block;width:20px;background:#ffe69c;color:#ffe69c;"> </span><span style="display:inline-block;width:20px;background:#ffda6a;color:#ffda6a;"> </span><span style="display:inline-block;width:20px;background:#ffcd39;color:#ffcd39;"> </span><span style="display:inline-block;width:20px;background:#ffc107;color:#ffc107;"> </span><span style="display:inline-block;width:20px;background:#cc9a06;color:#cc9a06;"> </span><span style="display:inline-block;width:20px;background:#997404;color:#997404;"> </span><span style="display:inline-block;width:20px;background:#664d03;color:#664d03;"> </span><span style="display:inline-block;width:20px;background:#332701;color:#332701;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#d1e7dd;color:#d1e7dd;"> </span><span style="display:inline-block;width:20px;background:#a3cfbb;color:#a3cfbb;"> </span><span style="display:inline-block;width:20px;background:#75b798;color:#75b798;"> </span><span style="display:inline-block;width:20px;background:#479f76;color:#479f76;"> </span><span style="display:inline-block;width:20px;background:#198754;color:#198754;"> </span><span style="display:inline-block;width:20px;background:#146c43;color:#146c43;"> </span><span style="display:inline-block;width:20px;background:#0f5132;color:#0f5132;"> </span><span style="display:inline-block;width:20px;background:#0a3622;color:#0a3622;"> </span><span style="display:inline-block;width:20px;background:#051b11;color:#051b11;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_teal</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#d2f4ea;color:#d2f4ea;"> </span><span style="display:inline-block;width:20px;background:#a6e9d5;color:#a6e9d5;"> </span><span style="display:inline-block;width:20px;background:#79dfc1;color:#79dfc1;"> </span><span style="display:inline-block;width:20px;background:#4dd4ac;color:#4dd4ac;"> </span><span style="display:inline-block;width:20px;background:#20c997;color:#20c997;"> </span><span style="display:inline-block;width:20px;background:#1aa179;color:#1aa179;"> </span><span style="display:inline-block;width:20px;background:#13795b;color:#13795b;"> </span><span style="display:inline-block;width:20px;background:#0d503c;color:#0d503c;"> </span><span style="display:inline-block;width:20px;background:#06281e;color:#06281e;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_cyan</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#cff4fc;color:#cff4fc;"> </span><span style="display:inline-block;width:20px;background:#9eeaf9;color:#9eeaf9;"> </span><span style="display:inline-block;width:20px;background:#6edff6;color:#6edff6;"> </span><span style="display:inline-block;width:20px;background:#3dd5f3;color:#3dd5f3;"> </span><span style="display:inline-block;width:20px;background:#0dcaf0;color:#0dcaf0;"> </span><span style="display:inline-block;width:20px;background:#0aa2c0;color:#0aa2c0;"> </span><span style="display:inline-block;width:20px;background:#087990;color:#087990;"> </span><span style="display:inline-block;width:20px;background:#055160;color:#055160;"> </span><span style="display:inline-block;width:20px;background:#032830;color:#032830;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_bs5_gray</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f8f9fa;color:#f8f9fa;"> </span><span style="display:inline-block;width:20px;background:#e9ecef;color:#e9ecef;"> </span><span style="display:inline-block;width:20px;background:#dee2e6;color:#dee2e6;"> </span><span style="display:inline-block;width:20px;background:#ced4da;color:#ced4da;"> </span><span style="display:inline-block;width:20px;background:#adb5bd;color:#adb5bd;"> </span><span style="display:inline-block;width:20px;background:#6c757d;color:#6c757d;"> </span><span style="display:inline-block;width:20px;background:#495057;color:#495057;"> </span><span style="display:inline-block;width:20px;background:#343a40;color:#343a40;"> </span><span style="display:inline-block;width:20px;background:#212529;color:#212529;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_red</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFEBEE;color:#FFEBEE;"> </span><span style="display:inline-block;width:20px;background:#FFCDD2;color:#FFCDD2;"> </span><span style="display:inline-block;width:20px;background:#EF9A9A;color:#EF9A9A;"> </span><span style="display:inline-block;width:20px;background:#E57373;color:#E57373;"> </span><span style="display:inline-block;width:20px;background:#EF5350;color:#EF5350;"> </span><span style="display:inline-block;width:20px;background:#F44336;color:#F44336;"> </span><span style="display:inline-block;width:20px;background:#E53935;color:#E53935;"> </span><span style="display:inline-block;width:20px;background:#D32F2F;color:#D32F2F;"> </span><span style="display:inline-block;width:20px;background:#C62828;color:#C62828;"> </span><span style="display:inline-block;width:20px;background:#B71C1C;color:#B71C1C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_pink</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FCE4EC;color:#FCE4EC;"> </span><span style="display:inline-block;width:20px;background:#F8BBD0;color:#F8BBD0;"> </span><span style="display:inline-block;width:20px;background:#F48FB1;color:#F48FB1;"> </span><span style="display:inline-block;width:20px;background:#F06292;color:#F06292;"> </span><span style="display:inline-block;width:20px;background:#EC407A;color:#EC407A;"> </span><span style="display:inline-block;width:20px;background:#E91E63;color:#E91E63;"> </span><span style="display:inline-block;width:20px;background:#D81B60;color:#D81B60;"> </span><span style="display:inline-block;width:20px;background:#C2185B;color:#C2185B;"> </span><span style="display:inline-block;width:20px;background:#AD1457;color:#AD1457;"> </span><span style="display:inline-block;width:20px;background:#880E4F;color:#880E4F;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F3E5F5;color:#F3E5F5;"> </span><span style="display:inline-block;width:20px;background:#E1BEE7;color:#E1BEE7;"> </span><span style="display:inline-block;width:20px;background:#CE93D8;color:#CE93D8;"> </span><span style="display:inline-block;width:20px;background:#BA68C8;color:#BA68C8;"> </span><span style="display:inline-block;width:20px;background:#AB47BC;color:#AB47BC;"> </span><span style="display:inline-block;width:20px;background:#9C27B0;color:#9C27B0;"> </span><span style="display:inline-block;width:20px;background:#8E24AA;color:#8E24AA;"> </span><span style="display:inline-block;width:20px;background:#7B1FA2;color:#7B1FA2;"> </span><span style="display:inline-block;width:20px;background:#6A1B9A;color:#6A1B9A;"> </span><span style="display:inline-block;width:20px;background:#4A148C;color:#4A148C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_deep-purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#EDE7F6;color:#EDE7F6;"> </span><span style="display:inline-block;width:20px;background:#D1C4E9;color:#D1C4E9;"> </span><span style="display:inline-block;width:20px;background:#B39DDB;color:#B39DDB;"> </span><span style="display:inline-block;width:20px;background:#9575CD;color:#9575CD;"> </span><span style="display:inline-block;width:20px;background:#7E57C2;color:#7E57C2;"> </span><span style="display:inline-block;width:20px;background:#673AB7;color:#673AB7;"> </span><span style="display:inline-block;width:20px;background:#5E35B1;color:#5E35B1;"> </span><span style="display:inline-block;width:20px;background:#512DA8;color:#512DA8;"> </span><span style="display:inline-block;width:20px;background:#4527A0;color:#4527A0;"> </span><span style="display:inline-block;width:20px;background:#311B92;color:#311B92;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_indigo</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E8EAF6;color:#E8EAF6;"> </span><span style="display:inline-block;width:20px;background:#C5CAE9;color:#C5CAE9;"> </span><span style="display:inline-block;width:20px;background:#9FA8DA;color:#9FA8DA;"> </span><span style="display:inline-block;width:20px;background:#7986CB;color:#7986CB;"> </span><span style="display:inline-block;width:20px;background:#5C6BC0;color:#5C6BC0;"> </span><span style="display:inline-block;width:20px;background:#3F51B5;color:#3F51B5;"> </span><span style="display:inline-block;width:20px;background:#3949AB;color:#3949AB;"> </span><span style="display:inline-block;width:20px;background:#303F9F;color:#303F9F;"> </span><span style="display:inline-block;width:20px;background:#283593;color:#283593;"> </span><span style="display:inline-block;width:20px;background:#1A237E;color:#1A237E;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E3F2FD;color:#E3F2FD;"> </span><span style="display:inline-block;width:20px;background:#BBDEFB;color:#BBDEFB;"> </span><span style="display:inline-block;width:20px;background:#90CAF9;color:#90CAF9;"> </span><span style="display:inline-block;width:20px;background:#64B5F6;color:#64B5F6;"> </span><span style="display:inline-block;width:20px;background:#42A5F5;color:#42A5F5;"> </span><span style="display:inline-block;width:20px;background:#2196F3;color:#2196F3;"> </span><span style="display:inline-block;width:20px;background:#1E88E5;color:#1E88E5;"> </span><span style="display:inline-block;width:20px;background:#1976D2;color:#1976D2;"> </span><span style="display:inline-block;width:20px;background:#1565C0;color:#1565C0;"> </span><span style="display:inline-block;width:20px;background:#0D47A1;color:#0D47A1;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_light-blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E1F5FE;color:#E1F5FE;"> </span><span style="display:inline-block;width:20px;background:#B3E5FC;color:#B3E5FC;"> </span><span style="display:inline-block;width:20px;background:#81D4FA;color:#81D4FA;"> </span><span style="display:inline-block;width:20px;background:#4FC3F7;color:#4FC3F7;"> </span><span style="display:inline-block;width:20px;background:#29B6F6;color:#29B6F6;"> </span><span style="display:inline-block;width:20px;background:#03A9F4;color:#03A9F4;"> </span><span style="display:inline-block;width:20px;background:#039BE5;color:#039BE5;"> </span><span style="display:inline-block;width:20px;background:#0288D1;color:#0288D1;"> </span><span style="display:inline-block;width:20px;background:#0277BD;color:#0277BD;"> </span><span style="display:inline-block;width:20px;background:#01579B;color:#01579B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_cyan</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E0F7FA;color:#E0F7FA;"> </span><span style="display:inline-block;width:20px;background:#B2EBF2;color:#B2EBF2;"> </span><span style="display:inline-block;width:20px;background:#80DEEA;color:#80DEEA;"> </span><span style="display:inline-block;width:20px;background:#4DD0E1;color:#4DD0E1;"> </span><span style="display:inline-block;width:20px;background:#26C6DA;color:#26C6DA;"> </span><span style="display:inline-block;width:20px;background:#00BCD4;color:#00BCD4;"> </span><span style="display:inline-block;width:20px;background:#00ACC1;color:#00ACC1;"> </span><span style="display:inline-block;width:20px;background:#0097A7;color:#0097A7;"> </span><span style="display:inline-block;width:20px;background:#00838F;color:#00838F;"> </span><span style="display:inline-block;width:20px;background:#006064;color:#006064;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_teal</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E0F2F1;color:#E0F2F1;"> </span><span style="display:inline-block;width:20px;background:#B2DFDB;color:#B2DFDB;"> </span><span style="display:inline-block;width:20px;background:#80CBC4;color:#80CBC4;"> </span><span style="display:inline-block;width:20px;background:#4DB6AC;color:#4DB6AC;"> </span><span style="display:inline-block;width:20px;background:#26A69A;color:#26A69A;"> </span><span style="display:inline-block;width:20px;background:#009688;color:#009688;"> </span><span style="display:inline-block;width:20px;background:#00897B;color:#00897B;"> </span><span style="display:inline-block;width:20px;background:#00796B;color:#00796B;"> </span><span style="display:inline-block;width:20px;background:#00695C;color:#00695C;"> </span><span style="display:inline-block;width:20px;background:#004D40;color:#004D40;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E8F5E9;color:#E8F5E9;"> </span><span style="display:inline-block;width:20px;background:#C8E6C9;color:#C8E6C9;"> </span><span style="display:inline-block;width:20px;background:#A5D6A7;color:#A5D6A7;"> </span><span style="display:inline-block;width:20px;background:#81C784;color:#81C784;"> </span><span style="display:inline-block;width:20px;background:#66BB6A;color:#66BB6A;"> </span><span style="display:inline-block;width:20px;background:#4CAF50;color:#4CAF50;"> </span><span style="display:inline-block;width:20px;background:#43A047;color:#43A047;"> </span><span style="display:inline-block;width:20px;background:#388E3C;color:#388E3C;"> </span><span style="display:inline-block;width:20px;background:#2E7D32;color:#2E7D32;"> </span><span style="display:inline-block;width:20px;background:#1B5E20;color:#1B5E20;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_light-green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F1F8E9;color:#F1F8E9;"> </span><span style="display:inline-block;width:20px;background:#DCEDC8;color:#DCEDC8;"> </span><span style="display:inline-block;width:20px;background:#C5E1A5;color:#C5E1A5;"> </span><span style="display:inline-block;width:20px;background:#AED581;color:#AED581;"> </span><span style="display:inline-block;width:20px;background:#9CCC65;color:#9CCC65;"> </span><span style="display:inline-block;width:20px;background:#8BC34A;color:#8BC34A;"> </span><span style="display:inline-block;width:20px;background:#7CB342;color:#7CB342;"> </span><span style="display:inline-block;width:20px;background:#689F38;color:#689F38;"> </span><span style="display:inline-block;width:20px;background:#558B2F;color:#558B2F;"> </span><span style="display:inline-block;width:20px;background:#33691E;color:#33691E;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_lime</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F9FBE7;color:#F9FBE7;"> </span><span style="display:inline-block;width:20px;background:#F0F4C3;color:#F0F4C3;"> </span><span style="display:inline-block;width:20px;background:#E6EE9C;color:#E6EE9C;"> </span><span style="display:inline-block;width:20px;background:#DCE775;color:#DCE775;"> </span><span style="display:inline-block;width:20px;background:#D4E157;color:#D4E157;"> </span><span style="display:inline-block;width:20px;background:#CDDC39;color:#CDDC39;"> </span><span style="display:inline-block;width:20px;background:#C0CA33;color:#C0CA33;"> </span><span style="display:inline-block;width:20px;background:#AFB42B;color:#AFB42B;"> </span><span style="display:inline-block;width:20px;background:#9E9D24;color:#9E9D24;"> </span><span style="display:inline-block;width:20px;background:#827717;color:#827717;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_yellow</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFFDE7;color:#FFFDE7;"> </span><span style="display:inline-block;width:20px;background:#FFF9C4;color:#FFF9C4;"> </span><span style="display:inline-block;width:20px;background:#FFF59D;color:#FFF59D;"> </span><span style="display:inline-block;width:20px;background:#FFF176;color:#FFF176;"> </span><span style="display:inline-block;width:20px;background:#FFEE58;color:#FFEE58;"> </span><span style="display:inline-block;width:20px;background:#FFEB3B;color:#FFEB3B;"> </span><span style="display:inline-block;width:20px;background:#FDD835;color:#FDD835;"> </span><span style="display:inline-block;width:20px;background:#FBC02D;color:#FBC02D;"> </span><span style="display:inline-block;width:20px;background:#F9A825;color:#F9A825;"> </span><span style="display:inline-block;width:20px;background:#F57F17;color:#F57F17;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_amber</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFF8E1;color:#FFF8E1;"> </span><span style="display:inline-block;width:20px;background:#FFECB3;color:#FFECB3;"> </span><span style="display:inline-block;width:20px;background:#FFE082;color:#FFE082;"> </span><span style="display:inline-block;width:20px;background:#FFD54F;color:#FFD54F;"> </span><span style="display:inline-block;width:20px;background:#FFCA28;color:#FFCA28;"> </span><span style="display:inline-block;width:20px;background:#FFC107;color:#FFC107;"> </span><span style="display:inline-block;width:20px;background:#FFB300;color:#FFB300;"> </span><span style="display:inline-block;width:20px;background:#FFA000;color:#FFA000;"> </span><span style="display:inline-block;width:20px;background:#FF8F00;color:#FF8F00;"> </span><span style="display:inline-block;width:20px;background:#FF6F00;color:#FF6F00;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFF3E0;color:#FFF3E0;"> </span><span style="display:inline-block;width:20px;background:#FFE0B2;color:#FFE0B2;"> </span><span style="display:inline-block;width:20px;background:#FFCC80;color:#FFCC80;"> </span><span style="display:inline-block;width:20px;background:#FFB74D;color:#FFB74D;"> </span><span style="display:inline-block;width:20px;background:#FFA726;color:#FFA726;"> </span><span style="display:inline-block;width:20px;background:#FF9800;color:#FF9800;"> </span><span style="display:inline-block;width:20px;background:#FB8C00;color:#FB8C00;"> </span><span style="display:inline-block;width:20px;background:#F57C00;color:#F57C00;"> </span><span style="display:inline-block;width:20px;background:#EF6C00;color:#EF6C00;"> </span><span style="display:inline-block;width:20px;background:#E65100;color:#E65100;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_deep-orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FBE9E7;color:#FBE9E7;"> </span><span style="display:inline-block;width:20px;background:#FFCCBC;color:#FFCCBC;"> </span><span style="display:inline-block;width:20px;background:#FFAB91;color:#FFAB91;"> </span><span style="display:inline-block;width:20px;background:#FF8A65;color:#FF8A65;"> </span><span style="display:inline-block;width:20px;background:#FF7043;color:#FF7043;"> </span><span style="display:inline-block;width:20px;background:#FF5722;color:#FF5722;"> </span><span style="display:inline-block;width:20px;background:#F4511E;color:#F4511E;"> </span><span style="display:inline-block;width:20px;background:#E64A19;color:#E64A19;"> </span><span style="display:inline-block;width:20px;background:#D84315;color:#D84315;"> </span><span style="display:inline-block;width:20px;background:#BF360C;color:#BF360C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_brown</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#EFEBE9;color:#EFEBE9;"> </span><span style="display:inline-block;width:20px;background:#D7CCC8;color:#D7CCC8;"> </span><span style="display:inline-block;width:20px;background:#BCAAA4;color:#BCAAA4;"> </span><span style="display:inline-block;width:20px;background:#A1887F;color:#A1887F;"> </span><span style="display:inline-block;width:20px;background:#8D6E63;color:#8D6E63;"> </span><span style="display:inline-block;width:20px;background:#795548;color:#795548;"> </span><span style="display:inline-block;width:20px;background:#6D4C41;color:#6D4C41;"> </span><span style="display:inline-block;width:20px;background:#5D4037;color:#5D4037;"> </span><span style="display:inline-block;width:20px;background:#4E342E;color:#4E342E;"> </span><span style="display:inline-block;width:20px;background:#3E2723;color:#3E2723;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_grey</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FAFAFA;color:#FAFAFA;"> </span><span style="display:inline-block;width:20px;background:#F5F5F5;color:#F5F5F5;"> </span><span style="display:inline-block;width:20px;background:#EEEEEE;color:#EEEEEE;"> </span><span style="display:inline-block;width:20px;background:#E0E0E0;color:#E0E0E0;"> </span><span style="display:inline-block;width:20px;background:#BDBDBD;color:#BDBDBD;"> </span><span style="display:inline-block;width:20px;background:#9E9E9E;color:#9E9E9E;"> </span><span style="display:inline-block;width:20px;background:#757575;color:#757575;"> </span><span style="display:inline-block;width:20px;background:#616161;color:#616161;"> </span><span style="display:inline-block;width:20px;background:#424242;color:#424242;"> </span><span style="display:inline-block;width:20px;background:#212121;color:#212121;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_material_blue-grey</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#ECEFF1;color:#ECEFF1;"> </span><span style="display:inline-block;width:20px;background:#CFD8DC;color:#CFD8DC;"> </span><span style="display:inline-block;width:20px;background:#B0BEC5;color:#B0BEC5;"> </span><span style="display:inline-block;width:20px;background:#90A4AE;color:#90A4AE;"> </span><span style="display:inline-block;width:20px;background:#78909C;color:#78909C;"> </span><span style="display:inline-block;width:20px;background:#607D8B;color:#607D8B;"> </span><span style="display:inline-block;width:20px;background:#546E7A;color:#546E7A;"> </span><span style="display:inline-block;width:20px;background:#455A64;color:#455A64;"> </span><span style="display:inline-block;width:20px;background:#37474F;color:#37474F;"> </span><span style="display:inline-block;width:20px;background:#263238;color:#263238;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_slate</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f8fafc;color:#f8fafc;"> </span><span style="display:inline-block;width:20px;background:#f1f5f9;color:#f1f5f9;"> </span><span style="display:inline-block;width:20px;background:#e2e8f0;color:#e2e8f0;"> </span><span style="display:inline-block;width:20px;background:#cbd5e1;color:#cbd5e1;"> </span><span style="display:inline-block;width:20px;background:#94a3b8;color:#94a3b8;"> </span><span style="display:inline-block;width:20px;background:#64748b;color:#64748b;"> </span><span style="display:inline-block;width:20px;background:#475569;color:#475569;"> </span><span style="display:inline-block;width:20px;background:#334155;color:#334155;"> </span><span style="display:inline-block;width:20px;background:#1e293b;color:#1e293b;"> </span><span style="display:inline-block;width:20px;background:#0f172a;color:#0f172a;"> </span><span style="display:inline-block;width:20px;background:#020617;color:#020617;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_gray</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f9fafb;color:#f9fafb;"> </span><span style="display:inline-block;width:20px;background:#f3f4f6;color:#f3f4f6;"> </span><span style="display:inline-block;width:20px;background:#e5e7eb;color:#e5e7eb;"> </span><span style="display:inline-block;width:20px;background:#d1d5db;color:#d1d5db;"> </span><span style="display:inline-block;width:20px;background:#9ca3af;color:#9ca3af;"> </span><span style="display:inline-block;width:20px;background:#6b7280;color:#6b7280;"> </span><span style="display:inline-block;width:20px;background:#4b5563;color:#4b5563;"> </span><span style="display:inline-block;width:20px;background:#374151;color:#374151;"> </span><span style="display:inline-block;width:20px;background:#1f2937;color:#1f2937;"> </span><span style="display:inline-block;width:20px;background:#111827;color:#111827;"> </span><span style="display:inline-block;width:20px;background:#030712;color:#030712;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_zinc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fafafa;color:#fafafa;"> </span><span style="display:inline-block;width:20px;background:#f4f4f5;color:#f4f4f5;"> </span><span style="display:inline-block;width:20px;background:#e4e4e7;color:#e4e4e7;"> </span><span style="display:inline-block;width:20px;background:#d4d4d8;color:#d4d4d8;"> </span><span style="display:inline-block;width:20px;background:#a1a1aa;color:#a1a1aa;"> </span><span style="display:inline-block;width:20px;background:#71717a;color:#71717a;"> </span><span style="display:inline-block;width:20px;background:#52525b;color:#52525b;"> </span><span style="display:inline-block;width:20px;background:#3f3f46;color:#3f3f46;"> </span><span style="display:inline-block;width:20px;background:#27272a;color:#27272a;"> </span><span style="display:inline-block;width:20px;background:#18181b;color:#18181b;"> </span><span style="display:inline-block;width:20px;background:#09090b;color:#09090b;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_neutral</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fafafa;color:#fafafa;"> </span><span style="display:inline-block;width:20px;background:#f5f5f5;color:#f5f5f5;"> </span><span style="display:inline-block;width:20px;background:#e5e5e5;color:#e5e5e5;"> </span><span style="display:inline-block;width:20px;background:#d4d4d4;color:#d4d4d4;"> </span><span style="display:inline-block;width:20px;background:#a3a3a3;color:#a3a3a3;"> </span><span style="display:inline-block;width:20px;background:#737373;color:#737373;"> </span><span style="display:inline-block;width:20px;background:#525252;color:#525252;"> </span><span style="display:inline-block;width:20px;background:#404040;color:#404040;"> </span><span style="display:inline-block;width:20px;background:#262626;color:#262626;"> </span><span style="display:inline-block;width:20px;background:#171717;color:#171717;"> </span><span style="display:inline-block;width:20px;background:#0a0a0a;color:#0a0a0a;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_stone</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fafaf9;color:#fafaf9;"> </span><span style="display:inline-block;width:20px;background:#f5f5f4;color:#f5f5f4;"> </span><span style="display:inline-block;width:20px;background:#e7e5e4;color:#e7e5e4;"> </span><span style="display:inline-block;width:20px;background:#d6d3d1;color:#d6d3d1;"> </span><span style="display:inline-block;width:20px;background:#a8a29e;color:#a8a29e;"> </span><span style="display:inline-block;width:20px;background:#78716c;color:#78716c;"> </span><span style="display:inline-block;width:20px;background:#57534e;color:#57534e;"> </span><span style="display:inline-block;width:20px;background:#44403c;color:#44403c;"> </span><span style="display:inline-block;width:20px;background:#292524;color:#292524;"> </span><span style="display:inline-block;width:20px;background:#1c1917;color:#1c1917;"> </span><span style="display:inline-block;width:20px;background:#0c0a09;color:#0c0a09;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_red</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fef2f2;color:#fef2f2;"> </span><span style="display:inline-block;width:20px;background:#fee2e2;color:#fee2e2;"> </span><span style="display:inline-block;width:20px;background:#fecaca;color:#fecaca;"> </span><span style="display:inline-block;width:20px;background:#fca5a5;color:#fca5a5;"> </span><span style="display:inline-block;width:20px;background:#f87171;color:#f87171;"> </span><span style="display:inline-block;width:20px;background:#ef4444;color:#ef4444;"> </span><span style="display:inline-block;width:20px;background:#dc2626;color:#dc2626;"> </span><span style="display:inline-block;width:20px;background:#b91c1c;color:#b91c1c;"> </span><span style="display:inline-block;width:20px;background:#991b1b;color:#991b1b;"> </span><span style="display:inline-block;width:20px;background:#7f1d1d;color:#7f1d1d;"> </span><span style="display:inline-block;width:20px;background:#450a0a;color:#450a0a;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_orange</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fff7ed;color:#fff7ed;"> </span><span style="display:inline-block;width:20px;background:#ffedd5;color:#ffedd5;"> </span><span style="display:inline-block;width:20px;background:#fed7aa;color:#fed7aa;"> </span><span style="display:inline-block;width:20px;background:#fdba74;color:#fdba74;"> </span><span style="display:inline-block;width:20px;background:#fb923c;color:#fb923c;"> </span><span style="display:inline-block;width:20px;background:#f97316;color:#f97316;"> </span><span style="display:inline-block;width:20px;background:#ea580c;color:#ea580c;"> </span><span style="display:inline-block;width:20px;background:#c2410c;color:#c2410c;"> </span><span style="display:inline-block;width:20px;background:#9a3412;color:#9a3412;"> </span><span style="display:inline-block;width:20px;background:#7c2d12;color:#7c2d12;"> </span><span style="display:inline-block;width:20px;background:#431407;color:#431407;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_amber</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fffbeb;color:#fffbeb;"> </span><span style="display:inline-block;width:20px;background:#fef3c7;color:#fef3c7;"> </span><span style="display:inline-block;width:20px;background:#fde68a;color:#fde68a;"> </span><span style="display:inline-block;width:20px;background:#fcd34d;color:#fcd34d;"> </span><span style="display:inline-block;width:20px;background:#fbbf24;color:#fbbf24;"> </span><span style="display:inline-block;width:20px;background:#f59e0b;color:#f59e0b;"> </span><span style="display:inline-block;width:20px;background:#d97706;color:#d97706;"> </span><span style="display:inline-block;width:20px;background:#b45309;color:#b45309;"> </span><span style="display:inline-block;width:20px;background:#92400e;color:#92400e;"> </span><span style="display:inline-block;width:20px;background:#78350f;color:#78350f;"> </span><span style="display:inline-block;width:20px;background:#451a03;color:#451a03;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_yellow</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fefce8;color:#fefce8;"> </span><span style="display:inline-block;width:20px;background:#fef9c3;color:#fef9c3;"> </span><span style="display:inline-block;width:20px;background:#fef08a;color:#fef08a;"> </span><span style="display:inline-block;width:20px;background:#fde047;color:#fde047;"> </span><span style="display:inline-block;width:20px;background:#facc15;color:#facc15;"> </span><span style="display:inline-block;width:20px;background:#eab308;color:#eab308;"> </span><span style="display:inline-block;width:20px;background:#ca8a04;color:#ca8a04;"> </span><span style="display:inline-block;width:20px;background:#a16207;color:#a16207;"> </span><span style="display:inline-block;width:20px;background:#854d0e;color:#854d0e;"> </span><span style="display:inline-block;width:20px;background:#713f12;color:#713f12;"> </span><span style="display:inline-block;width:20px;background:#422006;color:#422006;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_lime</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f7fee7;color:#f7fee7;"> </span><span style="display:inline-block;width:20px;background:#ecfccb;color:#ecfccb;"> </span><span style="display:inline-block;width:20px;background:#d9f99d;color:#d9f99d;"> </span><span style="display:inline-block;width:20px;background:#bef264;color:#bef264;"> </span><span style="display:inline-block;width:20px;background:#a3e635;color:#a3e635;"> </span><span style="display:inline-block;width:20px;background:#84cc16;color:#84cc16;"> </span><span style="display:inline-block;width:20px;background:#65a30d;color:#65a30d;"> </span><span style="display:inline-block;width:20px;background:#4d7c0f;color:#4d7c0f;"> </span><span style="display:inline-block;width:20px;background:#3f6212;color:#3f6212;"> </span><span style="display:inline-block;width:20px;background:#365314;color:#365314;"> </span><span style="display:inline-block;width:20px;background:#1a2e05;color:#1a2e05;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_green</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f0fdf4;color:#f0fdf4;"> </span><span style="display:inline-block;width:20px;background:#dcfce7;color:#dcfce7;"> </span><span style="display:inline-block;width:20px;background:#bbf7d0;color:#bbf7d0;"> </span><span style="display:inline-block;width:20px;background:#86efac;color:#86efac;"> </span><span style="display:inline-block;width:20px;background:#4ade80;color:#4ade80;"> </span><span style="display:inline-block;width:20px;background:#22c55e;color:#22c55e;"> </span><span style="display:inline-block;width:20px;background:#16a34a;color:#16a34a;"> </span><span style="display:inline-block;width:20px;background:#15803d;color:#15803d;"> </span><span style="display:inline-block;width:20px;background:#166534;color:#166534;"> </span><span style="display:inline-block;width:20px;background:#14532d;color:#14532d;"> </span><span style="display:inline-block;width:20px;background:#052e16;color:#052e16;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_emerald</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#ecfdf5;color:#ecfdf5;"> </span><span style="display:inline-block;width:20px;background:#d1fae5;color:#d1fae5;"> </span><span style="display:inline-block;width:20px;background:#a7f3d0;color:#a7f3d0;"> </span><span style="display:inline-block;width:20px;background:#6ee7b7;color:#6ee7b7;"> </span><span style="display:inline-block;width:20px;background:#34d399;color:#34d399;"> </span><span style="display:inline-block;width:20px;background:#10b981;color:#10b981;"> </span><span style="display:inline-block;width:20px;background:#059669;color:#059669;"> </span><span style="display:inline-block;width:20px;background:#047857;color:#047857;"> </span><span style="display:inline-block;width:20px;background:#065f46;color:#065f46;"> </span><span style="display:inline-block;width:20px;background:#064e3b;color:#064e3b;"> </span><span style="display:inline-block;width:20px;background:#022c22;color:#022c22;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_teal</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f0fdfa;color:#f0fdfa;"> </span><span style="display:inline-block;width:20px;background:#ccfbf1;color:#ccfbf1;"> </span><span style="display:inline-block;width:20px;background:#99f6e4;color:#99f6e4;"> </span><span style="display:inline-block;width:20px;background:#5eead4;color:#5eead4;"> </span><span style="display:inline-block;width:20px;background:#2dd4bf;color:#2dd4bf;"> </span><span style="display:inline-block;width:20px;background:#14b8a6;color:#14b8a6;"> </span><span style="display:inline-block;width:20px;background:#0d9488;color:#0d9488;"> </span><span style="display:inline-block;width:20px;background:#0f766e;color:#0f766e;"> </span><span style="display:inline-block;width:20px;background:#115e59;color:#115e59;"> </span><span style="display:inline-block;width:20px;background:#134e4a;color:#134e4a;"> </span><span style="display:inline-block;width:20px;background:#042f2e;color:#042f2e;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_cyan</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#ecfeff;color:#ecfeff;"> </span><span style="display:inline-block;width:20px;background:#cffafe;color:#cffafe;"> </span><span style="display:inline-block;width:20px;background:#a5f3fc;color:#a5f3fc;"> </span><span style="display:inline-block;width:20px;background:#67e8f9;color:#67e8f9;"> </span><span style="display:inline-block;width:20px;background:#22d3ee;color:#22d3ee;"> </span><span style="display:inline-block;width:20px;background:#06b6d4;color:#06b6d4;"> </span><span style="display:inline-block;width:20px;background:#0891b2;color:#0891b2;"> </span><span style="display:inline-block;width:20px;background:#0e7490;color:#0e7490;"> </span><span style="display:inline-block;width:20px;background:#155e75;color:#155e75;"> </span><span style="display:inline-block;width:20px;background:#164e63;color:#164e63;"> </span><span style="display:inline-block;width:20px;background:#083344;color:#083344;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_sky</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f0f9ff;color:#f0f9ff;"> </span><span style="display:inline-block;width:20px;background:#e0f2fe;color:#e0f2fe;"> </span><span style="display:inline-block;width:20px;background:#bae6fd;color:#bae6fd;"> </span><span style="display:inline-block;width:20px;background:#7dd3fc;color:#7dd3fc;"> </span><span style="display:inline-block;width:20px;background:#38bdf8;color:#38bdf8;"> </span><span style="display:inline-block;width:20px;background:#0ea5e9;color:#0ea5e9;"> </span><span style="display:inline-block;width:20px;background:#0284c7;color:#0284c7;"> </span><span style="display:inline-block;width:20px;background:#0369a1;color:#0369a1;"> </span><span style="display:inline-block;width:20px;background:#075985;color:#075985;"> </span><span style="display:inline-block;width:20px;background:#0c4a6e;color:#0c4a6e;"> </span><span style="display:inline-block;width:20px;background:#082f49;color:#082f49;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_blue</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#eff6ff;color:#eff6ff;"> </span><span style="display:inline-block;width:20px;background:#dbeafe;color:#dbeafe;"> </span><span style="display:inline-block;width:20px;background:#bfdbfe;color:#bfdbfe;"> </span><span style="display:inline-block;width:20px;background:#93c5fd;color:#93c5fd;"> </span><span style="display:inline-block;width:20px;background:#60a5fa;color:#60a5fa;"> </span><span style="display:inline-block;width:20px;background:#3b82f6;color:#3b82f6;"> </span><span style="display:inline-block;width:20px;background:#2563eb;color:#2563eb;"> </span><span style="display:inline-block;width:20px;background:#1d4ed8;color:#1d4ed8;"> </span><span style="display:inline-block;width:20px;background:#1e40af;color:#1e40af;"> </span><span style="display:inline-block;width:20px;background:#1e3a8a;color:#1e3a8a;"> </span><span style="display:inline-block;width:20px;background:#172554;color:#172554;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_indigo</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#eef2ff;color:#eef2ff;"> </span><span style="display:inline-block;width:20px;background:#e0e7ff;color:#e0e7ff;"> </span><span style="display:inline-block;width:20px;background:#c7d2fe;color:#c7d2fe;"> </span><span style="display:inline-block;width:20px;background:#a5b4fc;color:#a5b4fc;"> </span><span style="display:inline-block;width:20px;background:#818cf8;color:#818cf8;"> </span><span style="display:inline-block;width:20px;background:#6366f1;color:#6366f1;"> </span><span style="display:inline-block;width:20px;background:#4f46e5;color:#4f46e5;"> </span><span style="display:inline-block;width:20px;background:#4338ca;color:#4338ca;"> </span><span style="display:inline-block;width:20px;background:#3730a3;color:#3730a3;"> </span><span style="display:inline-block;width:20px;background:#312e81;color:#312e81;"> </span><span style="display:inline-block;width:20px;background:#1e1b4b;color:#1e1b4b;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_violet</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#f5f3ff;color:#f5f3ff;"> </span><span style="display:inline-block;width:20px;background:#ede9fe;color:#ede9fe;"> </span><span style="display:inline-block;width:20px;background:#ddd6fe;color:#ddd6fe;"> </span><span style="display:inline-block;width:20px;background:#c4b5fd;color:#c4b5fd;"> </span><span style="display:inline-block;width:20px;background:#a78bfa;color:#a78bfa;"> </span><span style="display:inline-block;width:20px;background:#8b5cf6;color:#8b5cf6;"> </span><span style="display:inline-block;width:20px;background:#7c3aed;color:#7c3aed;"> </span><span style="display:inline-block;width:20px;background:#6d28d9;color:#6d28d9;"> </span><span style="display:inline-block;width:20px;background:#5b21b6;color:#5b21b6;"> </span><span style="display:inline-block;width:20px;background:#4c1d95;color:#4c1d95;"> </span><span style="display:inline-block;width:20px;background:#2e1065;color:#2e1065;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_purple</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#faf5ff;color:#faf5ff;"> </span><span style="display:inline-block;width:20px;background:#f3e8ff;color:#f3e8ff;"> </span><span style="display:inline-block;width:20px;background:#e9d5ff;color:#e9d5ff;"> </span><span style="display:inline-block;width:20px;background:#d8b4fe;color:#d8b4fe;"> </span><span style="display:inline-block;width:20px;background:#c084fc;color:#c084fc;"> </span><span style="display:inline-block;width:20px;background:#a855f7;color:#a855f7;"> </span><span style="display:inline-block;width:20px;background:#9333ea;color:#9333ea;"> </span><span style="display:inline-block;width:20px;background:#7e22ce;color:#7e22ce;"> </span><span style="display:inline-block;width:20px;background:#6b21a8;color:#6b21a8;"> </span><span style="display:inline-block;width:20px;background:#581c87;color:#581c87;"> </span><span style="display:inline-block;width:20px;background:#3b0764;color:#3b0764;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_fuchsia</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fdf4ff;color:#fdf4ff;"> </span><span style="display:inline-block;width:20px;background:#fae8ff;color:#fae8ff;"> </span><span style="display:inline-block;width:20px;background:#f5d0fe;color:#f5d0fe;"> </span><span style="display:inline-block;width:20px;background:#f0abfc;color:#f0abfc;"> </span><span style="display:inline-block;width:20px;background:#e879f9;color:#e879f9;"> </span><span style="display:inline-block;width:20px;background:#d946ef;color:#d946ef;"> </span><span style="display:inline-block;width:20px;background:#c026d3;color:#c026d3;"> </span><span style="display:inline-block;width:20px;background:#a21caf;color:#a21caf;"> </span><span style="display:inline-block;width:20px;background:#86198f;color:#86198f;"> </span><span style="display:inline-block;width:20px;background:#701a75;color:#701a75;"> </span><span style="display:inline-block;width:20px;background:#4a044e;color:#4a044e;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_pink</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fdf2f8;color:#fdf2f8;"> </span><span style="display:inline-block;width:20px;background:#fce7f3;color:#fce7f3;"> </span><span style="display:inline-block;width:20px;background:#fbcfe8;color:#fbcfe8;"> </span><span style="display:inline-block;width:20px;background:#f9a8d4;color:#f9a8d4;"> </span><span style="display:inline-block;width:20px;background:#f472b6;color:#f472b6;"> </span><span style="display:inline-block;width:20px;background:#ec4899;color:#ec4899;"> </span><span style="display:inline-block;width:20px;background:#db2777;color:#db2777;"> </span><span style="display:inline-block;width:20px;background:#be185d;color:#be185d;"> </span><span style="display:inline-block;width:20px;background:#9d174d;color:#9d174d;"> </span><span style="display:inline-block;width:20px;background:#831843;color:#831843;"> </span><span style="display:inline-block;width:20px;background:#500724;color:#500724;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_tw3_rose</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#fff1f2;color:#fff1f2;"> </span><span style="display:inline-block;width:20px;background:#ffe4e6;color:#ffe4e6;"> </span><span style="display:inline-block;width:20px;background:#fecdd3;color:#fecdd3;"> </span><span style="display:inline-block;width:20px;background:#fda4af;color:#fda4af;"> </span><span style="display:inline-block;width:20px;background:#fb7185;color:#fb7185;"> </span><span style="display:inline-block;width:20px;background:#f43f5e;color:#f43f5e;"> </span><span style="display:inline-block;width:20px;background:#e11d48;color:#e11d48;"> </span><span style="display:inline-block;width:20px;background:#be123c;color:#be123c;"> </span><span style="display:inline-block;width:20px;background:#9f1239;color:#9f1239;"> </span><span style="display:inline-block;width:20px;background:#881337;color:#881337;"> </span><span style="display:inline-block;width:20px;background:#4c0519;color:#4c0519;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "hcl")
#> <div id="xgbswfpseo" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#xgbswfpseo table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #xgbswfpseo thead, #xgbswfpseo tbody, #xgbswfpseo tfoot, #xgbswfpseo tr, #xgbswfpseo td, #xgbswfpseo th {
#>   border-style: none;
#> }
#> 
#> #xgbswfpseo p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #xgbswfpseo .gt_table {
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
#> #xgbswfpseo .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #xgbswfpseo .gt_title {
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
#> #xgbswfpseo .gt_subtitle {
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
#> #xgbswfpseo .gt_heading {
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
#> #xgbswfpseo .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xgbswfpseo .gt_col_headings {
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
#> #xgbswfpseo .gt_col_heading {
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
#> #xgbswfpseo .gt_column_spanner_outer {
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
#> #xgbswfpseo .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #xgbswfpseo .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #xgbswfpseo .gt_column_spanner {
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
#> #xgbswfpseo .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #xgbswfpseo .gt_group_heading {
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
#> #xgbswfpseo .gt_empty_group_heading {
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
#> #xgbswfpseo .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #xgbswfpseo .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #xgbswfpseo .gt_row {
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
#> #xgbswfpseo .gt_stub {
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
#> #xgbswfpseo .gt_stub_row_group {
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
#> #xgbswfpseo .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #xgbswfpseo .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #xgbswfpseo .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xgbswfpseo .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #xgbswfpseo .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #xgbswfpseo .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xgbswfpseo .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xgbswfpseo .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #xgbswfpseo .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xgbswfpseo .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #xgbswfpseo .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xgbswfpseo .gt_footnotes {
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
#> #xgbswfpseo .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xgbswfpseo .gt_sourcenotes {
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
#> #xgbswfpseo .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xgbswfpseo .gt_left {
#>   text-align: left;
#> }
#> 
#> #xgbswfpseo .gt_center {
#>   text-align: center;
#> }
#> 
#> #xgbswfpseo .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #xgbswfpseo .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #xgbswfpseo .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #xgbswfpseo .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #xgbswfpseo .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #xgbswfpseo .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #xgbswfpseo .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #xgbswfpseo .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #xgbswfpseo .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #xgbswfpseo .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #xgbswfpseo .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #xgbswfpseo .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #xgbswfpseo .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #xgbswfpseo div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:410px;"/>
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
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#6D0026;color:#6D0026;"> </span><span style="display:inline-block;width:20px;background:#700027;color:#700027;"> </span><span style="display:inline-block;width:20px;background:#740028;color:#740028;"> </span><span style="display:inline-block;width:20px;background:#78002A;color:#78002A;"> </span><span style="display:inline-block;width:20px;background:#7C002B;color:#7C002B;"> </span><span style="display:inline-block;width:20px;background:#80002C;color:#80002C;"> </span><span style="display:inline-block;width:20px;background:#83002D;color:#83002D;"> </span><span style="display:inline-block;width:20px;background:#87002E;color:#87002E;"> </span><span style="display:inline-block;width:20px;background:#8B002F;color:#8B002F;"> </span><span style="display:inline-block;width:20px;background:#8F0030;color:#8F0030;"> </span><span style="display:inline-block;width:20px;background:#930031;color:#930031;"> </span><span style="display:inline-block;width:20px;background:#970031;color:#970031;"> </span><span style="display:inline-block;width:20px;background:#9B0032;color:#9B0032;"> </span><span style="display:inline-block;width:20px;background:#9E0033;color:#9E0033;"> </span><span style="display:inline-block;width:20px;background:#A20034;color:#A20034;"> </span><span style="display:inline-block;width:20px;background:#A60134;color:#A60134;"> </span><span style="display:inline-block;width:20px;background:#AA0435;color:#AA0435;"> </span><span style="display:inline-block;width:20px;background:#AE0635;color:#AE0635;"> </span><span style="display:inline-block;width:20px;background:#B20936;color:#B20936;"> </span><span style="display:inline-block;width:20px;background:#B60C36;color:#B60C36;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Reds_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7F000D;color:#7F000D;"> </span><span style="display:inline-block;width:20px;background:#810012;color:#810012;"> </span><span style="display:inline-block;width:20px;background:#830717;color:#830717;"> </span><span style="display:inline-block;width:20px;background:#850E1B;color:#850E1B;"> </span><span style="display:inline-block;width:20px;background:#87131F;color:#87131F;"> </span><span style="display:inline-block;width:20px;background:#881822;color:#881822;"> </span><span style="display:inline-block;width:20px;background:#8A1D26;color:#8A1D26;"> </span><span style="display:inline-block;width:20px;background:#8C2129;color:#8C2129;"> </span><span style="display:inline-block;width:20px;background:#8E242C;color:#8E242C;"> </span><span style="display:inline-block;width:20px;background:#8F282F;color:#8F282F;"> </span><span style="display:inline-block;width:20px;background:#912B32;color:#912B32;"> </span><span style="display:inline-block;width:20px;background:#932F35;color:#932F35;"> </span><span style="display:inline-block;width:20px;background:#953238;color:#953238;"> </span><span style="display:inline-block;width:20px;background:#96353B;color:#96353B;"> </span><span style="display:inline-block;width:20px;background:#98383E;color:#98383E;"> </span><span style="display:inline-block;width:20px;background:#9A3B40;color:#9A3B40;"> </span><span style="display:inline-block;width:20px;background:#9B3E43;color:#9B3E43;"> </span><span style="display:inline-block;width:20px;background:#9D4146;color:#9D4146;"> </span><span style="display:inline-block;width:20px;background:#9E4449;color:#9E4449;"> </span><span style="display:inline-block;width:20px;background:#A0474B;color:#A0474B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Reds_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#69000C;color:#69000C;"> </span><span style="display:inline-block;width:20px;background:#6C000E;color:#6C000E;"> </span><span style="display:inline-block;width:20px;background:#700110;color:#700110;"> </span><span style="display:inline-block;width:20px;background:#740211;color:#740211;"> </span><span style="display:inline-block;width:20px;background:#780313;color:#780313;"> </span><span style="display:inline-block;width:20px;background:#7C0414;color:#7C0414;"> </span><span style="display:inline-block;width:20px;background:#800616;color:#800616;"> </span><span style="display:inline-block;width:20px;background:#840717;color:#840717;"> </span><span style="display:inline-block;width:20px;background:#880819;color:#880819;"> </span><span style="display:inline-block;width:20px;background:#8C091A;color:#8C091A;"> </span><span style="display:inline-block;width:20px;background:#900B1B;color:#900B1B;"> </span><span style="display:inline-block;width:20px;background:#940C1D;color:#940C1D;"> </span><span style="display:inline-block;width:20px;background:#980E1E;color:#980E1E;"> </span><span style="display:inline-block;width:20px;background:#9C0F20;color:#9C0F20;"> </span><span style="display:inline-block;width:20px;background:#A01021;color:#A01021;"> </span><span style="display:inline-block;width:20px;background:#A41122;color:#A41122;"> </span><span style="display:inline-block;width:20px;background:#A81324;color:#A81324;"> </span><span style="display:inline-block;width:20px;background:#AC1425;color:#AC1425;"> </span><span style="display:inline-block;width:20px;background:#B01526;color:#B01526;"> </span><span style="display:inline-block;width:20px;background:#B41628;color:#B41628;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#273871;color:#273871;"> </span><span style="display:inline-block;width:20px;background:#283A74;color:#283A74;"> </span><span style="display:inline-block;width:20px;background:#293C76;color:#293C76;"> </span><span style="display:inline-block;width:20px;background:#2A3F79;color:#2A3F79;"> </span><span style="display:inline-block;width:20px;background:#2B417C;color:#2B417C;"> </span><span style="display:inline-block;width:20px;background:#2C437F;color:#2C437F;"> </span><span style="display:inline-block;width:20px;background:#2D4682;color:#2D4682;"> </span><span style="display:inline-block;width:20px;background:#2D4885;color:#2D4885;"> </span><span style="display:inline-block;width:20px;background:#2E4B88;color:#2E4B88;"> </span><span style="display:inline-block;width:20px;background:#2F4D8B;color:#2F4D8B;"> </span><span style="display:inline-block;width:20px;background:#2F4F8F;color:#2F4F8F;"> </span><span style="display:inline-block;width:20px;background:#305292;color:#305292;"> </span><span style="display:inline-block;width:20px;background:#305495;color:#305495;"> </span><span style="display:inline-block;width:20px;background:#315798;color:#315798;"> </span><span style="display:inline-block;width:20px;background:#31599B;color:#31599B;"> </span><span style="display:inline-block;width:20px;background:#315B9E;color:#315B9E;"> </span><span style="display:inline-block;width:20px;background:#325EA1;color:#325EA1;"> </span><span style="display:inline-block;width:20px;background:#3260A4;color:#3260A4;"> </span><span style="display:inline-block;width:20px;background:#3263A7;color:#3263A7;"> </span><span style="display:inline-block;width:20px;background:#3265AA;color:#3265AA;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#023FA5;color:#023FA5;"> </span><span style="display:inline-block;width:20px;background:#1141A4;color:#1141A4;"> </span><span style="display:inline-block;width:20px;background:#1A44A4;color:#1A44A4;"> </span><span style="display:inline-block;width:20px;background:#2146A4;color:#2146A4;"> </span><span style="display:inline-block;width:20px;background:#2749A4;color:#2749A4;"> </span><span style="display:inline-block;width:20px;background:#2C4BA4;color:#2C4BA4;"> </span><span style="display:inline-block;width:20px;background:#314DA4;color:#314DA4;"> </span><span style="display:inline-block;width:20px;background:#3550A5;color:#3550A5;"> </span><span style="display:inline-block;width:20px;background:#3952A5;color:#3952A5;"> </span><span style="display:inline-block;width:20px;background:#3C54A6;color:#3C54A6;"> </span><span style="display:inline-block;width:20px;background:#4056A6;color:#4056A6;"> </span><span style="display:inline-block;width:20px;background:#4359A7;color:#4359A7;"> </span><span style="display:inline-block;width:20px;background:#465BA8;color:#465BA8;"> </span><span style="display:inline-block;width:20px;background:#4A5DA8;color:#4A5DA8;"> </span><span style="display:inline-block;width:20px;background:#4D5FA9;color:#4D5FA9;"> </span><span style="display:inline-block;width:20px;background:#5062AA;color:#5062AA;"> </span><span style="display:inline-block;width:20px;background:#5264AA;color:#5264AA;"> </span><span style="display:inline-block;width:20px;background:#5566AB;color:#5566AB;"> </span><span style="display:inline-block;width:20px;background:#5868AC;color:#5868AC;"> </span><span style="display:inline-block;width:20px;background:#5B6AAD;color:#5B6AAD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#00366C;color:#00366C;"> </span><span style="display:inline-block;width:20px;background:#00386E;color:#00386E;"> </span><span style="display:inline-block;width:20px;background:#003A71;color:#003A71;"> </span><span style="display:inline-block;width:20px;background:#003D73;color:#003D73;"> </span><span style="display:inline-block;width:20px;background:#003F76;color:#003F76;"> </span><span style="display:inline-block;width:20px;background:#004178;color:#004178;"> </span><span style="display:inline-block;width:20px;background:#00447B;color:#00447B;"> </span><span style="display:inline-block;width:20px;background:#00467E;color:#00467E;"> </span><span style="display:inline-block;width:20px;background:#004981;color:#004981;"> </span><span style="display:inline-block;width:20px;background:#004B84;color:#004B84;"> </span><span style="display:inline-block;width:20px;background:#004D87;color:#004D87;"> </span><span style="display:inline-block;width:20px;background:#005089;color:#005089;"> </span><span style="display:inline-block;width:20px;background:#00528C;color:#00528C;"> </span><span style="display:inline-block;width:20px;background:#00558F;color:#00558F;"> </span><span style="display:inline-block;width:20px;background:#005793;color:#005793;"> </span><span style="display:inline-block;width:20px;background:#005A96;color:#005A96;"> </span><span style="display:inline-block;width:20px;background:#005C99;color:#005C99;"> </span><span style="display:inline-block;width:20px;background:#005F9C;color:#005F9C;"> </span><span style="display:inline-block;width:20px;background:#00619F;color:#00619F;"> </span><span style="display:inline-block;width:20px;background:#0064A2;color:#0064A2;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Greens</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#004616;color:#004616;"> </span><span style="display:inline-block;width:20px;background:#004918;color:#004918;"> </span><span style="display:inline-block;width:20px;background:#004C1A;color:#004C1A;"> </span><span style="display:inline-block;width:20px;background:#004E1C;color:#004E1C;"> </span><span style="display:inline-block;width:20px;background:#00511D;color:#00511D;"> </span><span style="display:inline-block;width:20px;background:#00541F;color:#00541F;"> </span><span style="display:inline-block;width:20px;background:#035721;color:#035721;"> </span><span style="display:inline-block;width:20px;background:#065922;color:#065922;"> </span><span style="display:inline-block;width:20px;background:#095C24;color:#095C24;"> </span><span style="display:inline-block;width:20px;background:#0C5F25;color:#0C5F25;"> </span><span style="display:inline-block;width:20px;background:#0F6227;color:#0F6227;"> </span><span style="display:inline-block;width:20px;background:#126429;color:#126429;"> </span><span style="display:inline-block;width:20px;background:#15672A;color:#15672A;"> </span><span style="display:inline-block;width:20px;background:#176A2B;color:#176A2B;"> </span><span style="display:inline-block;width:20px;background:#196C2D;color:#196C2D;"> </span><span style="display:inline-block;width:20px;background:#1C6F2E;color:#1C6F2E;"> </span><span style="display:inline-block;width:20px;background:#1E7230;color:#1E7230;"> </span><span style="display:inline-block;width:20px;background:#207431;color:#207431;"> </span><span style="display:inline-block;width:20px;background:#227732;color:#227732;"> </span><span style="display:inline-block;width:20px;background:#257A34;color:#257A34;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Greens_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#006027;color:#006027;"> </span><span style="display:inline-block;width:20px;background:#08622B;color:#08622B;"> </span><span style="display:inline-block;width:20px;background:#11632E;color:#11632E;"> </span><span style="display:inline-block;width:20px;background:#176531;color:#176531;"> </span><span style="display:inline-block;width:20px;background:#1C6733;color:#1C6733;"> </span><span style="display:inline-block;width:20px;background:#216936;color:#216936;"> </span><span style="display:inline-block;width:20px;background:#256A39;color:#256A39;"> </span><span style="display:inline-block;width:20px;background:#296C3C;color:#296C3C;"> </span><span style="display:inline-block;width:20px;background:#2C6E3E;color:#2C6E3E;"> </span><span style="display:inline-block;width:20px;background:#307041;color:#307041;"> </span><span style="display:inline-block;width:20px;background:#337144;color:#337144;"> </span><span style="display:inline-block;width:20px;background:#377346;color:#377346;"> </span><span style="display:inline-block;width:20px;background:#3A7549;color:#3A7549;"> </span><span style="display:inline-block;width:20px;background:#3D764B;color:#3D764B;"> </span><span style="display:inline-block;width:20px;background:#40784E;color:#40784E;"> </span><span style="display:inline-block;width:20px;background:#437A50;color:#437A50;"> </span><span style="display:inline-block;width:20px;background:#467C53;color:#467C53;"> </span><span style="display:inline-block;width:20px;background:#497D55;color:#497D55;"> </span><span style="display:inline-block;width:20px;background:#4C7F58;color:#4C7F58;"> </span><span style="display:inline-block;width:20px;background:#4F815A;color:#4F815A;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Greens_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#004616;color:#004616;"> </span><span style="display:inline-block;width:20px;background:#004918;color:#004918;"> </span><span style="display:inline-block;width:20px;background:#004C1A;color:#004C1A;"> </span><span style="display:inline-block;width:20px;background:#004F1C;color:#004F1C;"> </span><span style="display:inline-block;width:20px;background:#00511E;color:#00511E;"> </span><span style="display:inline-block;width:20px;background:#005420;color:#005420;"> </span><span style="display:inline-block;width:20px;background:#005722;color:#005722;"> </span><span style="display:inline-block;width:20px;background:#005A24;color:#005A24;"> </span><span style="display:inline-block;width:20px;background:#005C25;color:#005C25;"> </span><span style="display:inline-block;width:20px;background:#005F27;color:#005F27;"> </span><span style="display:inline-block;width:20px;background:#026229;color:#026229;"> </span><span style="display:inline-block;width:20px;background:#03652B;color:#03652B;"> </span><span style="display:inline-block;width:20px;background:#05672C;color:#05672C;"> </span><span style="display:inline-block;width:20px;background:#076A2E;color:#076A2E;"> </span><span style="display:inline-block;width:20px;background:#096D30;color:#096D30;"> </span><span style="display:inline-block;width:20px;background:#0B7032;color:#0B7032;"> </span><span style="display:inline-block;width:20px;background:#0C7333;color:#0C7333;"> </span><span style="display:inline-block;width:20px;background:#0E7535;color:#0E7535;"> </span><span style="display:inline-block;width:20px;background:#107837;color:#107837;"> </span><span style="display:inline-block;width:20px;background:#117B38;color:#117B38;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Oranges</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#802A07;color:#802A07;"> </span><span style="display:inline-block;width:20px;background:#832B04;color:#832B04;"> </span><span style="display:inline-block;width:20px;background:#872D00;color:#872D00;"> </span><span style="display:inline-block;width:20px;background:#8A2E00;color:#8A2E00;"> </span><span style="display:inline-block;width:20px;background:#8E2F00;color:#8E2F00;"> </span><span style="display:inline-block;width:20px;background:#913100;color:#913100;"> </span><span style="display:inline-block;width:20px;background:#953200;color:#953200;"> </span><span style="display:inline-block;width:20px;background:#983400;color:#983400;"> </span><span style="display:inline-block;width:20px;background:#9B3500;color:#9B3500;"> </span><span style="display:inline-block;width:20px;background:#9F3700;color:#9F3700;"> </span><span style="display:inline-block;width:20px;background:#A23800;color:#A23800;"> </span><span style="display:inline-block;width:20px;background:#A63A00;color:#A63A00;"> </span><span style="display:inline-block;width:20px;background:#A93B00;color:#A93B00;"> </span><span style="display:inline-block;width:20px;background:#AC3D00;color:#AC3D00;"> </span><span style="display:inline-block;width:20px;background:#B03E00;color:#B03E00;"> </span><span style="display:inline-block;width:20px;background:#B34000;color:#B34000;"> </span><span style="display:inline-block;width:20px;background:#B74200;color:#B74200;"> </span><span style="display:inline-block;width:20px;background:#BA4300;color:#BA4300;"> </span><span style="display:inline-block;width:20px;background:#BD4500;color:#BD4500;"> </span><span style="display:inline-block;width:20px;background:#C04600;color:#C04600;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purples</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#3D1778;color:#3D1778;"> </span><span style="display:inline-block;width:20px;background:#3F1B7A;color:#3F1B7A;"> </span><span style="display:inline-block;width:20px;background:#411E7C;color:#411E7C;"> </span><span style="display:inline-block;width:20px;background:#43217F;color:#43217F;"> </span><span style="display:inline-block;width:20px;background:#462481;color:#462481;"> </span><span style="display:inline-block;width:20px;background:#482784;color:#482784;"> </span><span style="display:inline-block;width:20px;background:#4A2A86;color:#4A2A86;"> </span><span style="display:inline-block;width:20px;background:#4C2C89;color:#4C2C89;"> </span><span style="display:inline-block;width:20px;background:#4E2F8C;color:#4E2F8C;"> </span><span style="display:inline-block;width:20px;background:#50318F;color:#50318F;"> </span><span style="display:inline-block;width:20px;background:#533492;color:#533492;"> </span><span style="display:inline-block;width:20px;background:#553695;color:#553695;"> </span><span style="display:inline-block;width:20px;background:#573998;color:#573998;"> </span><span style="display:inline-block;width:20px;background:#593B9B;color:#593B9B;"> </span><span style="display:inline-block;width:20px;background:#5C3E9E;color:#5C3E9E;"> </span><span style="display:inline-block;width:20px;background:#5E40A0;color:#5E40A0;"> </span><span style="display:inline-block;width:20px;background:#6043A1;color:#6043A1;"> </span><span style="display:inline-block;width:20px;background:#6147A2;color:#6147A2;"> </span><span style="display:inline-block;width:20px;background:#634AA3;color:#634AA3;"> </span><span style="display:inline-block;width:20px;background:#654DA4;color:#654DA4;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purples_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#3C2692;color:#3C2692;"> </span><span style="display:inline-block;width:20px;background:#3E2992;color:#3E2992;"> </span><span style="display:inline-block;width:20px;background:#402C91;color:#402C91;"> </span><span style="display:inline-block;width:20px;background:#423091;color:#423091;"> </span><span style="display:inline-block;width:20px;background:#443391;color:#443391;"> </span><span style="display:inline-block;width:20px;background:#463591;color:#463591;"> </span><span style="display:inline-block;width:20px;background:#483892;color:#483892;"> </span><span style="display:inline-block;width:20px;background:#4A3B92;color:#4A3B92;"> </span><span style="display:inline-block;width:20px;background:#4B3D93;color:#4B3D93;"> </span><span style="display:inline-block;width:20px;background:#4D4093;color:#4D4093;"> </span><span style="display:inline-block;width:20px;background:#4F4294;color:#4F4294;"> </span><span style="display:inline-block;width:20px;background:#514594;color:#514594;"> </span><span style="display:inline-block;width:20px;background:#534795;color:#534795;"> </span><span style="display:inline-block;width:20px;background:#554996;color:#554996;"> </span><span style="display:inline-block;width:20px;background:#574C97;color:#574C97;"> </span><span style="display:inline-block;width:20px;background:#594E98;color:#594E98;"> </span><span style="display:inline-block;width:20px;background:#5B5099;color:#5B5099;"> </span><span style="display:inline-block;width:20px;background:#5D539A;color:#5D539A;"> </span><span style="display:inline-block;width:20px;background:#5F559A;color:#5F559A;"> </span><span style="display:inline-block;width:20px;background:#61579B;color:#61579B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purples_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#312271;color:#312271;"> </span><span style="display:inline-block;width:20px;background:#332573;color:#332573;"> </span><span style="display:inline-block;width:20px;background:#362876;color:#362876;"> </span><span style="display:inline-block;width:20px;background:#382A78;color:#382A78;"> </span><span style="display:inline-block;width:20px;background:#3B2D7B;color:#3B2D7B;"> </span><span style="display:inline-block;width:20px;background:#3D307D;color:#3D307D;"> </span><span style="display:inline-block;width:20px;background:#3F3280;color:#3F3280;"> </span><span style="display:inline-block;width:20px;background:#423583;color:#423583;"> </span><span style="display:inline-block;width:20px;background:#443786;color:#443786;"> </span><span style="display:inline-block;width:20px;background:#473A89;color:#473A89;"> </span><span style="display:inline-block;width:20px;background:#493C8C;color:#493C8C;"> </span><span style="display:inline-block;width:20px;background:#4C3F8F;color:#4C3F8F;"> </span><span style="display:inline-block;width:20px;background:#4E4192;color:#4E4192;"> </span><span style="display:inline-block;width:20px;background:#514495;color:#514495;"> </span><span style="display:inline-block;width:20px;background:#534698;color:#534698;"> </span><span style="display:inline-block;width:20px;background:#55489C;color:#55489C;"> </span><span style="display:inline-block;width:20px;background:#584B9F;color:#584B9F;"> </span><span style="display:inline-block;width:20px;background:#5A4DA2;color:#5A4DA2;"> </span><span style="display:inline-block;width:20px;background:#5D50A5;color:#5D50A5;"> </span><span style="display:inline-block;width:20px;background:#5F52A8;color:#5F52A8;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Grays</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#1B1B1B;color:#1B1B1B;"> </span><span style="display:inline-block;width:20px;background:#1E1E1E;color:#1E1E1E;"> </span><span style="display:inline-block;width:20px;background:#202020;color:#202020;"> </span><span style="display:inline-block;width:20px;background:#222222;color:#222222;"> </span><span style="display:inline-block;width:20px;background:#252525;color:#252525;"> </span><span style="display:inline-block;width:20px;background:#272727;color:#272727;"> </span><span style="display:inline-block;width:20px;background:#2A2A2A;color:#2A2A2A;"> </span><span style="display:inline-block;width:20px;background:#2C2C2C;color:#2C2C2C;"> </span><span style="display:inline-block;width:20px;background:#2E2E2E;color:#2E2E2E;"> </span><span style="display:inline-block;width:20px;background:#313131;color:#313131;"> </span><span style="display:inline-block;width:20px;background:#333333;color:#333333;"> </span><span style="display:inline-block;width:20px;background:#363636;color:#363636;"> </span><span style="display:inline-block;width:20px;background:#383838;color:#383838;"> </span><span style="display:inline-block;width:20px;background:#3B3B3B;color:#3B3B3B;"> </span><span style="display:inline-block;width:20px;background:#3D3D3D;color:#3D3D3D;"> </span><span style="display:inline-block;width:20px;background:#404040;color:#404040;"> </span><span style="display:inline-block;width:20px;background:#424242;color:#424242;"> </span><span style="display:inline-block;width:20px;background:#454545;color:#454545;"> </span><span style="display:inline-block;width:20px;background:#474747;color:#474747;"> </span><span style="display:inline-block;width:20px;background:#4A4A4A;color:#4A4A4A;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Light_Grays</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#474747;color:#474747;"> </span><span style="display:inline-block;width:20px;background:#494949;color:#494949;"> </span><span style="display:inline-block;width:20px;background:#4B4B4B;color:#4B4B4B;"> </span><span style="display:inline-block;width:20px;background:#4D4D4D;color:#4D4D4D;"> </span><span style="display:inline-block;width:20px;background:#4F4F4F;color:#4F4F4F;"> </span><span style="display:inline-block;width:20px;background:#515151;color:#515151;"> </span><span style="display:inline-block;width:20px;background:#535353;color:#535353;"> </span><span style="display:inline-block;width:20px;background:#555555;color:#555555;"> </span><span style="display:inline-block;width:20px;background:#575757;color:#575757;"> </span><span style="display:inline-block;width:20px;background:#595959;color:#595959;"> </span><span style="display:inline-block;width:20px;background:#5B5B5B;color:#5B5B5B;"> </span><span style="display:inline-block;width:20px;background:#5E5E5E;color:#5E5E5E;"> </span><span style="display:inline-block;width:20px;background:#606060;color:#606060;"> </span><span style="display:inline-block;width:20px;background:#626262;color:#626262;"> </span><span style="display:inline-block;width:20px;background:#646464;color:#646464;"> </span><span style="display:inline-block;width:20px;background:#666666;color:#666666;"> </span><span style="display:inline-block;width:20px;background:#686868;color:#686868;"> </span><span style="display:inline-block;width:20px;background:#6A6A6A;color:#6A6A6A;"> </span><span style="display:inline-block;width:20px;background:#6C6C6C;color:#6C6C6C;"> </span><span style="display:inline-block;width:20px;background:#6E6E6E;color:#6E6E6E;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_YlOrRd</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7D0025;color:#7D0025;"> </span><span style="display:inline-block;width:20px;background:#810024;color:#810024;"> </span><span style="display:inline-block;width:20px;background:#850023;color:#850023;"> </span><span style="display:inline-block;width:20px;background:#890021;color:#890021;"> </span><span style="display:inline-block;width:20px;background:#8E001F;color:#8E001F;"> </span><span style="display:inline-block;width:20px;background:#92001C;color:#92001C;"> </span><span style="display:inline-block;width:20px;background:#960119;color:#960119;"> </span><span style="display:inline-block;width:20px;background:#9A0315;color:#9A0315;"> </span><span style="display:inline-block;width:20px;background:#9E050F;color:#9E050F;"> </span><span style="display:inline-block;width:20px;background:#A20706;color:#A20706;"> </span><span style="display:inline-block;width:20px;background:#A60A00;color:#A60A00;"> </span><span style="display:inline-block;width:20px;background:#A90D00;color:#A90D00;"> </span><span style="display:inline-block;width:20px;background:#AD1000;color:#AD1000;"> </span><span style="display:inline-block;width:20px;background:#B11300;color:#B11300;"> </span><span style="display:inline-block;width:20px;background:#B51600;color:#B51600;"> </span><span style="display:inline-block;width:20px;background:#B81900;color:#B81900;"> </span><span style="display:inline-block;width:20px;background:#BC1C00;color:#BC1C00;"> </span><span style="display:inline-block;width:20px;background:#C01F00;color:#C01F00;"> </span><span style="display:inline-block;width:20px;background:#C32200;color:#C32200;"> </span><span style="display:inline-block;width:20px;background:#C72500;color:#C72500;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_YlOrBr</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#682714;color:#682714;"> </span><span style="display:inline-block;width:20px;background:#6C2812;color:#6C2812;"> </span><span style="display:inline-block;width:20px;background:#702A10;color:#702A10;"> </span><span style="display:inline-block;width:20px;background:#742C0E;color:#742C0E;"> </span><span style="display:inline-block;width:20px;background:#792E0A;color:#792E0A;"> </span><span style="display:inline-block;width:20px;background:#7D3005;color:#7D3005;"> </span><span style="display:inline-block;width:20px;background:#813200;color:#813200;"> </span><span style="display:inline-block;width:20px;background:#853400;color:#853400;"> </span><span style="display:inline-block;width:20px;background:#893600;color:#893600;"> </span><span style="display:inline-block;width:20px;background:#8D3800;color:#8D3800;"> </span><span style="display:inline-block;width:20px;background:#913A00;color:#913A00;"> </span><span style="display:inline-block;width:20px;background:#953C00;color:#953C00;"> </span><span style="display:inline-block;width:20px;background:#983E00;color:#983E00;"> </span><span style="display:inline-block;width:20px;background:#9C4100;color:#9C4100;"> </span><span style="display:inline-block;width:20px;background:#A04300;color:#A04300;"> </span><span style="display:inline-block;width:20px;background:#A44500;color:#A44500;"> </span><span style="display:inline-block;width:20px;background:#A84700;color:#A84700;"> </span><span style="display:inline-block;width:20px;background:#AB4A00;color:#AB4A00;"> </span><span style="display:inline-block;width:20px;background:#AF4C00;color:#AF4C00;"> </span><span style="display:inline-block;width:20px;background:#B34E00;color:#B34E00;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_YlGnBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#26185F;color:#26185F;"> </span><span style="display:inline-block;width:20px;background:#251C63;color:#251C63;"> </span><span style="display:inline-block;width:20px;background:#232167;color:#232167;"> </span><span style="display:inline-block;width:20px;background:#20256C;color:#20256C;"> </span><span style="display:inline-block;width:20px;background:#1C2970;color:#1C2970;"> </span><span style="display:inline-block;width:20px;background:#162D74;color:#162D74;"> </span><span style="display:inline-block;width:20px;background:#0D3178;color:#0D3178;"> </span><span style="display:inline-block;width:20px;background:#00357C;color:#00357C;"> </span><span style="display:inline-block;width:20px;background:#003A80;color:#003A80;"> </span><span style="display:inline-block;width:20px;background:#003E84;color:#003E84;"> </span><span style="display:inline-block;width:20px;background:#004288;color:#004288;"> </span><span style="display:inline-block;width:20px;background:#00468B;color:#00468B;"> </span><span style="display:inline-block;width:20px;background:#004A8F;color:#004A8F;"> </span><span style="display:inline-block;width:20px;background:#004E93;color:#004E93;"> </span><span style="display:inline-block;width:20px;background:#005296;color:#005296;"> </span><span style="display:inline-block;width:20px;background:#005699;color:#005699;"> </span><span style="display:inline-block;width:20px;background:#005A9D;color:#005A9D;"> </span><span style="display:inline-block;width:20px;background:#005FA0;color:#005FA0;"> </span><span style="display:inline-block;width:20px;background:#0063A3;color:#0063A3;"> </span><span style="display:inline-block;width:20px;background:#0067A6;color:#0067A6;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_BuGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#1B4414;color:#1B4414;"> </span><span style="display:inline-block;width:20px;background:#1B4717;color:#1B4717;"> </span><span style="display:inline-block;width:20px;background:#1C4A19;color:#1C4A19;"> </span><span style="display:inline-block;width:20px;background:#1C4D1B;color:#1C4D1B;"> </span><span style="display:inline-block;width:20px;background:#1C501D;color:#1C501D;"> </span><span style="display:inline-block;width:20px;background:#1C531F;color:#1C531F;"> </span><span style="display:inline-block;width:20px;background:#1C5622;color:#1C5622;"> </span><span style="display:inline-block;width:20px;background:#1C5924;color:#1C5924;"> </span><span style="display:inline-block;width:20px;background:#1B5C26;color:#1B5C26;"> </span><span style="display:inline-block;width:20px;background:#1B5F29;color:#1B5F29;"> </span><span style="display:inline-block;width:20px;background:#1A632B;color:#1A632B;"> </span><span style="display:inline-block;width:20px;background:#19662E;color:#19662E;"> </span><span style="display:inline-block;width:20px;background:#186930;color:#186930;"> </span><span style="display:inline-block;width:20px;background:#166C33;color:#166C33;"> </span><span style="display:inline-block;width:20px;background:#146F35;color:#146F35;"> </span><span style="display:inline-block;width:20px;background:#117238;color:#117238;"> </span><span style="display:inline-block;width:20px;background:#0D753A;color:#0D753A;"> </span><span style="display:inline-block;width:20px;background:#08783D;color:#08783D;"> </span><span style="display:inline-block;width:20px;background:#027B40;color:#027B40;"> </span><span style="display:inline-block;width:20px;background:#007E42;color:#007E42;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_BuPu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#540046;color:#540046;"> </span><span style="display:inline-block;width:20px;background:#560049;color:#560049;"> </span><span style="display:inline-block;width:20px;background:#58004D;color:#58004D;"> </span><span style="display:inline-block;width:20px;background:#5A0050;color:#5A0050;"> </span><span style="display:inline-block;width:20px;background:#5C0053;color:#5C0053;"> </span><span style="display:inline-block;width:20px;background:#5E0157;color:#5E0157;"> </span><span style="display:inline-block;width:20px;background:#60065A;color:#60065A;"> </span><span style="display:inline-block;width:20px;background:#630B5E;color:#630B5E;"> </span><span style="display:inline-block;width:20px;background:#651061;color:#651061;"> </span><span style="display:inline-block;width:20px;background:#671465;color:#671465;"> </span><span style="display:inline-block;width:20px;background:#691869;color:#691869;"> </span><span style="display:inline-block;width:20px;background:#6B1B6C;color:#6B1B6C;"> </span><span style="display:inline-block;width:20px;background:#6D1F70;color:#6D1F70;"> </span><span style="display:inline-block;width:20px;background:#6F2274;color:#6F2274;"> </span><span style="display:inline-block;width:20px;background:#712578;color:#712578;"> </span><span style="display:inline-block;width:20px;background:#73287C;color:#73287C;"> </span><span style="display:inline-block;width:20px;background:#752B7F;color:#752B7F;"> </span><span style="display:inline-block;width:20px;background:#772F83;color:#772F83;"> </span><span style="display:inline-block;width:20px;background:#793287;color:#793287;"> </span><span style="display:inline-block;width:20px;background:#7A358B;color:#7A358B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_PuRd</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#611300;color:#611300;"> </span><span style="display:inline-block;width:20px;background:#661200;color:#661200;"> </span><span style="display:inline-block;width:20px;background:#6A1100;color:#6A1100;"> </span><span style="display:inline-block;width:20px;background:#6E1000;color:#6E1000;"> </span><span style="display:inline-block;width:20px;background:#730E00;color:#730E00;"> </span><span style="display:inline-block;width:20px;background:#770B00;color:#770B00;"> </span><span style="display:inline-block;width:20px;background:#7C0801;color:#7C0801;"> </span><span style="display:inline-block;width:20px;background:#800508;color:#800508;"> </span><span style="display:inline-block;width:20px;background:#85010F;color:#85010F;"> </span><span style="display:inline-block;width:20px;background:#890015;color:#890015;"> </span><span style="display:inline-block;width:20px;background:#8E001B;color:#8E001B;"> </span><span style="display:inline-block;width:20px;background:#930021;color:#930021;"> </span><span style="display:inline-block;width:20px;background:#970026;color:#970026;"> </span><span style="display:inline-block;width:20px;background:#9C002B;color:#9C002B;"> </span><span style="display:inline-block;width:20px;background:#A10030;color:#A10030;"> </span><span style="display:inline-block;width:20px;background:#A60035;color:#A60035;"> </span><span style="display:inline-block;width:20px;background:#AA003A;color:#AA003A;"> </span><span style="display:inline-block;width:20px;background:#AF0040;color:#AF0040;"> </span><span style="display:inline-block;width:20px;background:#B40045;color:#B40045;"> </span><span style="display:inline-block;width:20px;background:#B9004A;color:#B9004A;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_RdPu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#490062;color:#490062;"> </span><span style="display:inline-block;width:20px;background:#4C0064;color:#4C0064;"> </span><span style="display:inline-block;width:20px;background:#4F0065;color:#4F0065;"> </span><span style="display:inline-block;width:20px;background:#530067;color:#530067;"> </span><span style="display:inline-block;width:20px;background:#560069;color:#560069;"> </span><span style="display:inline-block;width:20px;background:#5A006C;color:#5A006C;"> </span><span style="display:inline-block;width:20px;background:#5D006E;color:#5D006E;"> </span><span style="display:inline-block;width:20px;background:#610070;color:#610070;"> </span><span style="display:inline-block;width:20px;background:#650072;color:#650072;"> </span><span style="display:inline-block;width:20px;background:#690075;color:#690075;"> </span><span style="display:inline-block;width:20px;background:#6D0277;color:#6D0277;"> </span><span style="display:inline-block;width:20px;background:#710479;color:#710479;"> </span><span style="display:inline-block;width:20px;background:#75067C;color:#75067C;"> </span><span style="display:inline-block;width:20px;background:#79087E;color:#79087E;"> </span><span style="display:inline-block;width:20px;background:#7D0A80;color:#7D0A80;"> </span><span style="display:inline-block;width:20px;background:#810C83;color:#810C83;"> </span><span style="display:inline-block;width:20px;background:#850E85;color:#850E85;"> </span><span style="display:inline-block;width:20px;background:#890F87;color:#890F87;"> </span><span style="display:inline-block;width:20px;background:#8D1189;color:#8D1189;"> </span><span style="display:inline-block;width:20px;background:#92138C;color:#92138C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_OrRd</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#88002D;color:#88002D;"> </span><span style="display:inline-block;width:20px;background:#8B002E;color:#8B002E;"> </span><span style="display:inline-block;width:20px;background:#8E002F;color:#8E002F;"> </span><span style="display:inline-block;width:20px;background:#920030;color:#920030;"> </span><span style="display:inline-block;width:20px;background:#950030;color:#950030;"> </span><span style="display:inline-block;width:20px;background:#990031;color:#990031;"> </span><span style="display:inline-block;width:20px;background:#9C0031;color:#9C0031;"> </span><span style="display:inline-block;width:20px;background:#A00032;color:#A00032;"> </span><span style="display:inline-block;width:20px;background:#A30032;color:#A30032;"> </span><span style="display:inline-block;width:20px;background:#A70032;color:#A70032;"> </span><span style="display:inline-block;width:20px;background:#AA0032;color:#AA0032;"> </span><span style="display:inline-block;width:20px;background:#AE0732;color:#AE0732;"> </span><span style="display:inline-block;width:20px;background:#B10D32;color:#B10D32;"> </span><span style="display:inline-block;width:20px;background:#B51332;color:#B51332;"> </span><span style="display:inline-block;width:20px;background:#B81732;color:#B81732;"> </span><span style="display:inline-block;width:20px;background:#BC1B31;color:#BC1B31;"> </span><span style="display:inline-block;width:20px;background:#BF1F31;color:#BF1F31;"> </span><span style="display:inline-block;width:20px;background:#C32330;color:#C32330;"> </span><span style="display:inline-block;width:20px;background:#C6262F;color:#C6262F;"> </span><span style="display:inline-block;width:20px;background:#CA2A2E;color:#CA2A2E;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_GnBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2F327D;color:#2F327D;"> </span><span style="display:inline-block;width:20px;background:#2D3781;color:#2D3781;"> </span><span style="display:inline-block;width:20px;background:#2A3B84;color:#2A3B84;"> </span><span style="display:inline-block;width:20px;background:#263F87;color:#263F87;"> </span><span style="display:inline-block;width:20px;background:#22438B;color:#22438B;"> </span><span style="display:inline-block;width:20px;background:#1C478E;color:#1C478E;"> </span><span style="display:inline-block;width:20px;background:#134B91;color:#134B91;"> </span><span style="display:inline-block;width:20px;background:#054F95;color:#054F95;"> </span><span style="display:inline-block;width:20px;background:#005398;color:#005398;"> </span><span style="display:inline-block;width:20px;background:#00579B;color:#00579B;"> </span><span style="display:inline-block;width:20px;background:#005B9E;color:#005B9E;"> </span><span style="display:inline-block;width:20px;background:#005EA1;color:#005EA1;"> </span><span style="display:inline-block;width:20px;background:#0062A4;color:#0062A4;"> </span><span style="display:inline-block;width:20px;background:#0066A7;color:#0066A7;"> </span><span style="display:inline-block;width:20px;background:#006AA9;color:#006AA9;"> </span><span style="display:inline-block;width:20px;background:#006EAC;color:#006EAC;"> </span><span style="display:inline-block;width:20px;background:#0072AF;color:#0072AF;"> </span><span style="display:inline-block;width:20px;background:#0075B1;color:#0075B1;"> </span><span style="display:inline-block;width:20px;background:#0079B4;color:#0079B4;"> </span><span style="display:inline-block;width:20px;background:#007DB6;color:#007DB6;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_PuBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#0E3F5C;color:#0E3F5C;"> </span><span style="display:inline-block;width:20px;background:#0D415F;color:#0D415F;"> </span><span style="display:inline-block;width:20px;background:#0C4363;color:#0C4363;"> </span><span style="display:inline-block;width:20px;background:#0B4566;color:#0B4566;"> </span><span style="display:inline-block;width:20px;background:#0A476A;color:#0A476A;"> </span><span style="display:inline-block;width:20px;background:#09496D;color:#09496D;"> </span><span style="display:inline-block;width:20px;background:#084C71;color:#084C71;"> </span><span style="display:inline-block;width:20px;background:#074E74;color:#074E74;"> </span><span style="display:inline-block;width:20px;background:#075078;color:#075078;"> </span><span style="display:inline-block;width:20px;background:#06527B;color:#06527B;"> </span><span style="display:inline-block;width:20px;background:#06547E;color:#06547E;"> </span><span style="display:inline-block;width:20px;background:#055682;color:#055682;"> </span><span style="display:inline-block;width:20px;background:#055885;color:#055885;"> </span><span style="display:inline-block;width:20px;background:#055A89;color:#055A89;"> </span><span style="display:inline-block;width:20px;background:#055C8C;color:#055C8C;"> </span><span style="display:inline-block;width:20px;background:#055E90;color:#055E90;"> </span><span style="display:inline-block;width:20px;background:#056193;color:#056193;"> </span><span style="display:inline-block;width:20px;background:#066397;color:#066397;"> </span><span style="display:inline-block;width:20px;background:#06659A;color:#06659A;"> </span><span style="display:inline-block;width:20px;background:#07679E;color:#07679E;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_PuBuGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#004533;color:#004533;"> </span><span style="display:inline-block;width:20px;background:#004836;color:#004836;"> </span><span style="display:inline-block;width:20px;background:#004A38;color:#004A38;"> </span><span style="display:inline-block;width:20px;background:#004D3B;color:#004D3B;"> </span><span style="display:inline-block;width:20px;background:#004F3E;color:#004F3E;"> </span><span style="display:inline-block;width:20px;background:#005241;color:#005241;"> </span><span style="display:inline-block;width:20px;background:#005444;color:#005444;"> </span><span style="display:inline-block;width:20px;background:#005747;color:#005747;"> </span><span style="display:inline-block;width:20px;background:#005A4A;color:#005A4A;"> </span><span style="display:inline-block;width:20px;background:#005C4E;color:#005C4E;"> </span><span style="display:inline-block;width:20px;background:#005F51;color:#005F51;"> </span><span style="display:inline-block;width:20px;background:#006155;color:#006155;"> </span><span style="display:inline-block;width:20px;background:#006458;color:#006458;"> </span><span style="display:inline-block;width:20px;background:#00665C;color:#00665C;"> </span><span style="display:inline-block;width:20px;background:#00685F;color:#00685F;"> </span><span style="display:inline-block;width:20px;background:#006B63;color:#006B63;"> </span><span style="display:inline-block;width:20px;background:#006D67;color:#006D67;"> </span><span style="display:inline-block;width:20px;background:#00706B;color:#00706B;"> </span><span style="display:inline-block;width:20px;background:#00726F;color:#00726F;"> </span><span style="display:inline-block;width:20px;background:#007573;color:#007573;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blue_Red</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#023FA5;color:#023FA5;"> </span><span style="display:inline-block;width:20px;background:#1A44A4;color:#1A44A4;"> </span><span style="display:inline-block;width:20px;background:#2749A4;color:#2749A4;"> </span><span style="display:inline-block;width:20px;background:#314DA4;color:#314DA4;"> </span><span style="display:inline-block;width:20px;background:#3952A5;color:#3952A5;"> </span><span style="display:inline-block;width:20px;background:#4056A6;color:#4056A6;"> </span><span style="display:inline-block;width:20px;background:#465BA8;color:#465BA8;"> </span><span style="display:inline-block;width:20px;background:#4D5FA9;color:#4D5FA9;"> </span><span style="display:inline-block;width:20px;background:#5264AA;color:#5264AA;"> </span><span style="display:inline-block;width:20px;background:#5868AC;color:#5868AC;"> </span><span style="display:inline-block;width:20px;background:#5D6CAE;color:#5D6CAE;"> </span><span style="display:inline-block;width:20px;background:#6371AF;color:#6371AF;"> </span><span style="display:inline-block;width:20px;background:#6875B1;color:#6875B1;"> </span><span style="display:inline-block;width:20px;background:#6D79B3;color:#6D79B3;"> </span><span style="display:inline-block;width:20px;background:#727DB5;color:#727DB5;"> </span><span style="display:inline-block;width:20px;background:#7681B7;color:#7681B7;"> </span><span style="display:inline-block;width:20px;background:#7B85B8;color:#7B85B8;"> </span><span style="display:inline-block;width:20px;background:#8089BA;color:#8089BA;"> </span><span style="display:inline-block;width:20px;background:#848DBC;color:#848DBC;"> </span><span style="display:inline-block;width:20px;background:#8991BE;color:#8991BE;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blue_Yellow</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#4F53B7;color:#4F53B7;"> </span><span style="display:inline-block;width:20px;background:#5357B7;color:#5357B7;"> </span><span style="display:inline-block;width:20px;background:#575BB8;color:#575BB8;"> </span><span style="display:inline-block;width:20px;background:#5B5FB9;color:#5B5FB9;"> </span><span style="display:inline-block;width:20px;background:#5F62BA;color:#5F62BA;"> </span><span style="display:inline-block;width:20px;background:#6366BB;color:#6366BB;"> </span><span style="display:inline-block;width:20px;background:#676ABC;color:#676ABC;"> </span><span style="display:inline-block;width:20px;background:#6B6DBD;color:#6B6DBD;"> </span><span style="display:inline-block;width:20px;background:#6E71BE;color:#6E71BE;"> </span><span style="display:inline-block;width:20px;background:#7274BF;color:#7274BF;"> </span><span style="display:inline-block;width:20px;background:#7678C1;color:#7678C1;"> </span><span style="display:inline-block;width:20px;background:#797CC2;color:#797CC2;"> </span><span style="display:inline-block;width:20px;background:#7D7FC3;color:#7D7FC3;"> </span><span style="display:inline-block;width:20px;background:#8183C5;color:#8183C5;"> </span><span style="display:inline-block;width:20px;background:#8486C6;color:#8486C6;"> </span><span style="display:inline-block;width:20px;background:#888AC7;color:#888AC7;"> </span><span style="display:inline-block;width:20px;background:#8B8DC9;color:#8B8DC9;"> </span><span style="display:inline-block;width:20px;background:#8F90CA;color:#8F90CA;"> </span><span style="display:inline-block;width:20px;background:#9294CC;color:#9294CC;"> </span><span style="display:inline-block;width:20px;background:#9697CD;color:#9697CD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Green_Brown</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#004B40;color:#004B40;"> </span><span style="display:inline-block;width:20px;background:#005045;color:#005045;"> </span><span style="display:inline-block;width:20px;background:#00554A;color:#00554A;"> </span><span style="display:inline-block;width:20px;background:#005A4E;color:#005A4E;"> </span><span style="display:inline-block;width:20px;background:#005F53;color:#005F53;"> </span><span style="display:inline-block;width:20px;background:#006458;color:#006458;"> </span><span style="display:inline-block;width:20px;background:#00695D;color:#00695D;"> </span><span style="display:inline-block;width:20px;background:#006E61;color:#006E61;"> </span><span style="display:inline-block;width:20px;background:#007366;color:#007366;"> </span><span style="display:inline-block;width:20px;background:#00786B;color:#00786B;"> </span><span style="display:inline-block;width:20px;background:#007D70;color:#007D70;"> </span><span style="display:inline-block;width:20px;background:#008274;color:#008274;"> </span><span style="display:inline-block;width:20px;background:#008779;color:#008779;"> </span><span style="display:inline-block;width:20px;background:#008C7E;color:#008C7E;"> </span><span style="display:inline-block;width:20px;background:#009183;color:#009183;"> </span><span style="display:inline-block;width:20px;background:#009687;color:#009687;"> </span><span style="display:inline-block;width:20px;background:#009C8C;color:#009C8C;"> </span><span style="display:inline-block;width:20px;background:#00A090;color:#00A090;"> </span><span style="display:inline-block;width:20px;background:#00A495;color:#00A495;"> </span><span style="display:inline-block;width:20px;background:#00A899;color:#00A899;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Purple_Green</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#492050;color:#492050;"> </span><span style="display:inline-block;width:20px;background:#4E2455;color:#4E2455;"> </span><span style="display:inline-block;width:20px;background:#54285B;color:#54285B;"> </span><span style="display:inline-block;width:20px;background:#592C61;color:#592C61;"> </span><span style="display:inline-block;width:20px;background:#5F3167;color:#5F3167;"> </span><span style="display:inline-block;width:20px;background:#65356D;color:#65356D;"> </span><span style="display:inline-block;width:20px;background:#6B3974;color:#6B3974;"> </span><span style="display:inline-block;width:20px;background:#713D7A;color:#713D7A;"> </span><span style="display:inline-block;width:20px;background:#774180;color:#774180;"> </span><span style="display:inline-block;width:20px;background:#7C4586;color:#7C4586;"> </span><span style="display:inline-block;width:20px;background:#82498D;color:#82498D;"> </span><span style="display:inline-block;width:20px;background:#884D93;color:#884D93;"> </span><span style="display:inline-block;width:20px;background:#8E5199;color:#8E5199;"> </span><span style="display:inline-block;width:20px;background:#9455A0;color:#9455A0;"> </span><span style="display:inline-block;width:20px;background:#9A59A6;color:#9A59A6;"> </span><span style="display:inline-block;width:20px;background:#A05DAC;color:#A05DAC;"> </span><span style="display:inline-block;width:20px;background:#A660B3;color:#A660B3;"> </span><span style="display:inline-block;width:20px;background:#AC64B9;color:#AC64B9;"> </span><span style="display:inline-block;width:20px;background:#B06ABD;color:#B06ABD;"> </span><span style="display:inline-block;width:20px;background:#B370C0;color:#B370C0;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Tropic</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#009B9F;color:#009B9F;"> </span><span style="display:inline-block;width:20px;background:#009DA1;color:#009DA1;"> </span><span style="display:inline-block;width:20px;background:#009EA2;color:#009EA2;"> </span><span style="display:inline-block;width:20px;background:#00A0A4;color:#00A0A4;"> </span><span style="display:inline-block;width:20px;background:#00A2A5;color:#00A2A5;"> </span><span style="display:inline-block;width:20px;background:#00A3A7;color:#00A3A7;"> </span><span style="display:inline-block;width:20px;background:#00A5A9;color:#00A5A9;"> </span><span style="display:inline-block;width:20px;background:#00A7AA;color:#00A7AA;"> </span><span style="display:inline-block;width:20px;background:#00A8AC;color:#00A8AC;"> </span><span style="display:inline-block;width:20px;background:#00AAAD;color:#00AAAD;"> </span><span style="display:inline-block;width:20px;background:#00ACAF;color:#00ACAF;"> </span><span style="display:inline-block;width:20px;background:#00ADB1;color:#00ADB1;"> </span><span style="display:inline-block;width:20px;background:#00AFB2;color:#00AFB2;"> </span><span style="display:inline-block;width:20px;background:#0CB1B4;color:#0CB1B4;"> </span><span style="display:inline-block;width:20px;background:#24B2B5;color:#24B2B5;"> </span><span style="display:inline-block;width:20px;background:#33B4B7;color:#33B4B7;"> </span><span style="display:inline-block;width:20px;background:#3EB6B9;color:#3EB6B9;"> </span><span style="display:inline-block;width:20px;background:#48B7BA;color:#48B7BA;"> </span><span style="display:inline-block;width:20px;background:#50B9BC;color:#50B9BC;"> </span><span style="display:inline-block;width:20px;background:#58BBBD;color:#58BBBD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Tofino</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#D6E0FF;color:#D6E0FF;"> </span><span style="display:inline-block;width:20px;background:#D1DBFF;color:#D1DBFF;"> </span><span style="display:inline-block;width:20px;background:#CCD6FF;color:#CCD6FF;"> </span><span style="display:inline-block;width:20px;background:#C7D1FF;color:#C7D1FF;"> </span><span style="display:inline-block;width:20px;background:#C2CCFF;color:#C2CCFF;"> </span><span style="display:inline-block;width:20px;background:#BDC7FF;color:#BDC7FF;"> </span><span style="display:inline-block;width:20px;background:#B7C3FE;color:#B7C3FE;"> </span><span style="display:inline-block;width:20px;background:#B2BEFB;color:#B2BEFB;"> </span><span style="display:inline-block;width:20px;background:#ADB9F7;color:#ADB9F7;"> </span><span style="display:inline-block;width:20px;background:#A8B4F3;color:#A8B4F3;"> </span><span style="display:inline-block;width:20px;background:#A3B0EE;color:#A3B0EE;"> </span><span style="display:inline-block;width:20px;background:#9FABE8;color:#9FABE8;"> </span><span style="display:inline-block;width:20px;background:#9BA6E2;color:#9BA6E2;"> </span><span style="display:inline-block;width:20px;background:#97A2DC;color:#97A2DC;"> </span><span style="display:inline-block;width:20px;background:#929DD7;color:#929DD7;"> </span><span style="display:inline-block;width:20px;background:#8E99D1;color:#8E99D1;"> </span><span style="display:inline-block;width:20px;background:#8A94CB;color:#8A94CB;"> </span><span style="display:inline-block;width:20px;background:#8690C5;color:#8690C5;"> </span><span style="display:inline-block;width:20px;background:#818CC0;color:#818CC0;"> </span><span style="display:inline-block;width:20px;background:#7D87BA;color:#7D87BA;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Berlin</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7FBFF5;color:#7FBFF5;"> </span><span style="display:inline-block;width:20px;background:#75B9F1;color:#75B9F1;"> </span><span style="display:inline-block;width:20px;background:#6AB4ED;color:#6AB4ED;"> </span><span style="display:inline-block;width:20px;background:#5FAFEA;color:#5FAFEA;"> </span><span style="display:inline-block;width:20px;background:#53AAE7;color:#53AAE7;"> </span><span style="display:inline-block;width:20px;background:#45A5E3;color:#45A5E3;"> </span><span style="display:inline-block;width:20px;background:#34A0E0;color:#34A0E0;"> </span><span style="display:inline-block;width:20px;background:#1C9BDD;color:#1C9BDD;"> </span><span style="display:inline-block;width:20px;background:#0096DA;color:#0096DA;"> </span><span style="display:inline-block;width:20px;background:#0091D5;color:#0091D5;"> </span><span style="display:inline-block;width:20px;background:#008CCE;color:#008CCE;"> </span><span style="display:inline-block;width:20px;background:#0087C7;color:#0087C7;"> </span><span style="display:inline-block;width:20px;background:#0082C0;color:#0082C0;"> </span><span style="display:inline-block;width:20px;background:#007DB9;color:#007DB9;"> </span><span style="display:inline-block;width:20px;background:#0078B2;color:#0078B2;"> </span><span style="display:inline-block;width:20px;background:#0074AC;color:#0074AC;"> </span><span style="display:inline-block;width:20px;background:#006FA6;color:#006FA6;"> </span><span style="display:inline-block;width:20px;background:#006B9F;color:#006B9F;"> </span><span style="display:inline-block;width:20px;background:#006699;color:#006699;"> </span><span style="display:inline-block;width:20px;background:#006293;color:#006293;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Lisbon</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E2FCFF;color:#E2FCFF;"> </span><span style="display:inline-block;width:20px;background:#DCF7FF;color:#DCF7FF;"> </span><span style="display:inline-block;width:20px;background:#D5F2FF;color:#D5F2FF;"> </span><span style="display:inline-block;width:20px;background:#CFEDFF;color:#CFEDFF;"> </span><span style="display:inline-block;width:20px;background:#C9E8FF;color:#C9E8FF;"> </span><span style="display:inline-block;width:20px;background:#C2E3FF;color:#C2E3FF;"> </span><span style="display:inline-block;width:20px;background:#BCDEFF;color:#BCDEFF;"> </span><span style="display:inline-block;width:20px;background:#B6D9FD;color:#B6D9FD;"> </span><span style="display:inline-block;width:20px;background:#AFD4F9;color:#AFD4F9;"> </span><span style="display:inline-block;width:20px;background:#A9CFF5;color:#A9CFF5;"> </span><span style="display:inline-block;width:20px;background:#A2CAF1;color:#A2CAF1;"> </span><span style="display:inline-block;width:20px;background:#9CC5ED;color:#9CC5ED;"> </span><span style="display:inline-block;width:20px;background:#95C0E9;color:#95C0E9;"> </span><span style="display:inline-block;width:20px;background:#91BBE4;color:#91BBE4;"> </span><span style="display:inline-block;width:20px;background:#8DB6DD;color:#8DB6DD;"> </span><span style="display:inline-block;width:20px;background:#89B1D7;color:#89B1D7;"> </span><span style="display:inline-block;width:20px;background:#85ACD1;color:#85ACD1;"> </span><span style="display:inline-block;width:20px;background:#81A7CB;color:#81A7CB;"> </span><span style="display:inline-block;width:20px;background:#7EA2C5;color:#7EA2C5;"> </span><span style="display:inline-block;width:20px;background:#7A9DBF;color:#7A9DBF;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Cork</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#00294D;color:#00294D;"> </span><span style="display:inline-block;width:20px;background:#002D51;color:#002D51;"> </span><span style="display:inline-block;width:20px;background:#003055;color:#003055;"> </span><span style="display:inline-block;width:20px;background:#003459;color:#003459;"> </span><span style="display:inline-block;width:20px;background:#00385E;color:#00385E;"> </span><span style="display:inline-block;width:20px;background:#003C63;color:#003C63;"> </span><span style="display:inline-block;width:20px;background:#004068;color:#004068;"> </span><span style="display:inline-block;width:20px;background:#02446D;color:#02446D;"> </span><span style="display:inline-block;width:20px;background:#084872;color:#084872;"> </span><span style="display:inline-block;width:20px;background:#0F4C77;color:#0F4C77;"> </span><span style="display:inline-block;width:20px;background:#14507C;color:#14507C;"> </span><span style="display:inline-block;width:20px;background:#195481;color:#195481;"> </span><span style="display:inline-block;width:20px;background:#1D5887;color:#1D5887;"> </span><span style="display:inline-block;width:20px;background:#215D8C;color:#215D8C;"> </span><span style="display:inline-block;width:20px;background:#256192;color:#256192;"> </span><span style="display:inline-block;width:20px;background:#286597;color:#286597;"> </span><span style="display:inline-block;width:20px;background:#2C699D;color:#2C699D;"> </span><span style="display:inline-block;width:20px;background:#316EA2;color:#316EA2;"> </span><span style="display:inline-block;width:20px;background:#3A72A4;color:#3A72A4;"> </span><span style="display:inline-block;width:20px;background:#4276A7;color:#4276A7;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Filter by type
pal_show(type = "discrete", index = 1:10)
#> <div id="qsdthtvodc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#qsdthtvodc table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #qsdthtvodc thead, #qsdthtvodc tbody, #qsdthtvodc tfoot, #qsdthtvodc tr, #qsdthtvodc td, #qsdthtvodc th {
#>   border-style: none;
#> }
#> 
#> #qsdthtvodc p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #qsdthtvodc .gt_table {
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
#> #qsdthtvodc .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #qsdthtvodc .gt_title {
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
#> #qsdthtvodc .gt_subtitle {
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
#> #qsdthtvodc .gt_heading {
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
#> #qsdthtvodc .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qsdthtvodc .gt_col_headings {
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
#> #qsdthtvodc .gt_col_heading {
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
#> #qsdthtvodc .gt_column_spanner_outer {
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
#> #qsdthtvodc .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #qsdthtvodc .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #qsdthtvodc .gt_column_spanner {
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
#> #qsdthtvodc .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #qsdthtvodc .gt_group_heading {
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
#> #qsdthtvodc .gt_empty_group_heading {
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
#> #qsdthtvodc .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #qsdthtvodc .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #qsdthtvodc .gt_row {
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
#> #qsdthtvodc .gt_stub {
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
#> #qsdthtvodc .gt_stub_row_group {
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
#> #qsdthtvodc .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #qsdthtvodc .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #qsdthtvodc .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qsdthtvodc .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qsdthtvodc .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #qsdthtvodc .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qsdthtvodc .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qsdthtvodc .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qsdthtvodc .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qsdthtvodc .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #qsdthtvodc .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qsdthtvodc .gt_footnotes {
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
#> #qsdthtvodc .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qsdthtvodc .gt_sourcenotes {
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
#> #qsdthtvodc .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qsdthtvodc .gt_left {
#>   text-align: left;
#> }
#> 
#> #qsdthtvodc .gt_center {
#>   text-align: center;
#> }
#> 
#> #qsdthtvodc .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #qsdthtvodc .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #qsdthtvodc .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #qsdthtvodc .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #qsdthtvodc .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #qsdthtvodc .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #qsdthtvodc .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #qsdthtvodc .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #qsdthtvodc .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #qsdthtvodc .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #qsdthtvodc .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #qsdthtvodc .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #qsdthtvodc .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #qsdthtvodc div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:250px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7FC97F;color:#7FC97F;"> </span><span style="display:inline-block;width:20px;background:#BEAED4;color:#BEAED4;"> </span><span style="display:inline-block;width:20px;background:#FDC086;color:#FDC086;"> </span><span style="display:inline-block;width:20px;background:#FFFF99;color:#FFFF99;"> </span><span style="display:inline-block;width:20px;background:#386CB0;color:#386CB0;"> </span><span style="display:inline-block;width:20px;background:#F0027F;color:#F0027F;"> </span><span style="display:inline-block;width:20px;background:#BF5B17;color:#BF5B17;"> </span><span style="display:inline-block;width:20px;background:#666666;color:#666666;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Dark2</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#1B9E77;color:#1B9E77;"> </span><span style="display:inline-block;width:20px;background:#D95F02;color:#D95F02;"> </span><span style="display:inline-block;width:20px;background:#7570B3;color:#7570B3;"> </span><span style="display:inline-block;width:20px;background:#E7298A;color:#E7298A;"> </span><span style="display:inline-block;width:20px;background:#66A61E;color:#66A61E;"> </span><span style="display:inline-block;width:20px;background:#E6AB02;color:#E6AB02;"> </span><span style="display:inline-block;width:20px;background:#A6761D;color:#A6761D;"> </span><span style="display:inline-block;width:20px;background:#666666;color:#666666;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Paired</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#A6CEE3;color:#A6CEE3;"> </span><span style="display:inline-block;width:20px;background:#1F78B4;color:#1F78B4;"> </span><span style="display:inline-block;width:20px;background:#B2DF8A;color:#B2DF8A;"> </span><span style="display:inline-block;width:20px;background:#33A02C;color:#33A02C;"> </span><span style="display:inline-block;width:20px;background:#FB9A99;color:#FB9A99;"> </span><span style="display:inline-block;width:20px;background:#E31A1C;color:#E31A1C;"> </span><span style="display:inline-block;width:20px;background:#FDBF6F;color:#FDBF6F;"> </span><span style="display:inline-block;width:20px;background:#FF7F00;color:#FF7F00;"> </span><span style="display:inline-block;width:20px;background:#CAB2D6;color:#CAB2D6;"> </span><span style="display:inline-block;width:20px;background:#6A3D9A;color:#6A3D9A;"> </span><span style="display:inline-block;width:20px;background:#FFFF99;color:#FFFF99;"> </span><span style="display:inline-block;width:20px;background:#B15928;color:#B15928;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Pastel1</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FBB4AE;color:#FBB4AE;"> </span><span style="display:inline-block;width:20px;background:#B3CDE3;color:#B3CDE3;"> </span><span style="display:inline-block;width:20px;background:#CCEBC5;color:#CCEBC5;"> </span><span style="display:inline-block;width:20px;background:#DECBE4;color:#DECBE4;"> </span><span style="display:inline-block;width:20px;background:#FED9A6;color:#FED9A6;"> </span><span style="display:inline-block;width:20px;background:#FFFFCC;color:#FFFFCC;"> </span><span style="display:inline-block;width:20px;background:#E5D8BD;color:#E5D8BD;"> </span><span style="display:inline-block;width:20px;background:#FDDAEC;color:#FDDAEC;"> </span><span style="display:inline-block;width:20px;background:#F2F2F2;color:#F2F2F2;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Pastel2</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#B3E2CD;color:#B3E2CD;"> </span><span style="display:inline-block;width:20px;background:#FDCDAC;color:#FDCDAC;"> </span><span style="display:inline-block;width:20px;background:#CBD5E8;color:#CBD5E8;"> </span><span style="display:inline-block;width:20px;background:#F4CAE4;color:#F4CAE4;"> </span><span style="display:inline-block;width:20px;background:#E6F5C9;color:#E6F5C9;"> </span><span style="display:inline-block;width:20px;background:#FFF2AE;color:#FFF2AE;"> </span><span style="display:inline-block;width:20px;background:#F1E2CC;color:#F1E2CC;"> </span><span style="display:inline-block;width:20px;background:#CCCCCC;color:#CCCCCC;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Set1</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E41A1C;color:#E41A1C;"> </span><span style="display:inline-block;width:20px;background:#377EB8;color:#377EB8;"> </span><span style="display:inline-block;width:20px;background:#4DAF4A;color:#4DAF4A;"> </span><span style="display:inline-block;width:20px;background:#984EA3;color:#984EA3;"> </span><span style="display:inline-block;width:20px;background:#FF7F00;color:#FF7F00;"> </span><span style="display:inline-block;width:20px;background:#FFFF33;color:#FFFF33;"> </span><span style="display:inline-block;width:20px;background:#A65628;color:#A65628;"> </span><span style="display:inline-block;width:20px;background:#F781BF;color:#F781BF;"> </span><span style="display:inline-block;width:20px;background:#999999;color:#999999;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Set2</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#66C2A5;color:#66C2A5;"> </span><span style="display:inline-block;width:20px;background:#FC8D62;color:#FC8D62;"> </span><span style="display:inline-block;width:20px;background:#8DA0CB;color:#8DA0CB;"> </span><span style="display:inline-block;width:20px;background:#E78AC3;color:#E78AC3;"> </span><span style="display:inline-block;width:20px;background:#A6D854;color:#A6D854;"> </span><span style="display:inline-block;width:20px;background:#FFD92F;color:#FFD92F;"> </span><span style="display:inline-block;width:20px;background:#E5C494;color:#E5C494;"> </span><span style="display:inline-block;width:20px;background:#B3B3B3;color:#B3B3B3;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Set3</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#8DD3C7;color:#8DD3C7;"> </span><span style="display:inline-block;width:20px;background:#FFFFB3;color:#FFFFB3;"> </span><span style="display:inline-block;width:20px;background:#BEBADA;color:#BEBADA;"> </span><span style="display:inline-block;width:20px;background:#FB8072;color:#FB8072;"> </span><span style="display:inline-block;width:20px;background:#80B1D3;color:#80B1D3;"> </span><span style="display:inline-block;width:20px;background:#FDB462;color:#FDB462;"> </span><span style="display:inline-block;width:20px;background:#B3DE69;color:#B3DE69;"> </span><span style="display:inline-block;width:20px;background:#FCCDE5;color:#FCCDE5;"> </span><span style="display:inline-block;width:20px;background:#D9D9D9;color:#D9D9D9;"> </span><span style="display:inline-block;width:20px;background:#BC80BD;color:#BC80BD;"> </span><span style="display:inline-block;width:20px;background:#CCEBC5;color:#CCEBC5;"> </span><span style="display:inline-block;width:20px;background:#FFED6F;color:#FFED6F;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_npg_nrc</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E64B35;color:#E64B35;"> </span><span style="display:inline-block;width:20px;background:#4DBBD5;color:#4DBBD5;"> </span><span style="display:inline-block;width:20px;background:#00A087;color:#00A087;"> </span><span style="display:inline-block;width:20px;background:#3C5488;color:#3C5488;"> </span><span style="display:inline-block;width:20px;background:#F39B7F;color:#F39B7F;"> </span><span style="display:inline-block;width:20px;background:#8491B4;color:#8491B4;"> </span><span style="display:inline-block;width:20px;background:#91D1C2;color:#91D1C2;"> </span><span style="display:inline-block;width:20px;background:#DC0000;color:#DC0000;"> </span><span style="display:inline-block;width:20px;background:#7E6148;color:#7E6148;"> </span><span style="display:inline-block;width:20px;background:#B09C85;color:#B09C85;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">ggsci_aaas_default</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#3B4992;color:#3B4992;"> </span><span style="display:inline-block;width:20px;background:#EE0000;color:#EE0000;"> </span><span style="display:inline-block;width:20px;background:#008B45;color:#008B45;"> </span><span style="display:inline-block;width:20px;background:#631879;color:#631879;"> </span><span style="display:inline-block;width:20px;background:#008280;color:#008280;"> </span><span style="display:inline-block;width:20px;background:#BB0021;color:#BB0021;"> </span><span style="display:inline-block;width:20px;background:#5F559B;color:#5F559B;"> </span><span style="display:inline-block;width:20px;background:#A20056;color:#A20056;"> </span><span style="display:inline-block;width:20px;background:#808180;color:#808180;"> </span><span style="display:inline-block;width:20px;background:#1B1919;color:#1B1919;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(type = "continuous", index = 1:10)
#> <div id="bfylkoaumz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#bfylkoaumz table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #bfylkoaumz thead, #bfylkoaumz tbody, #bfylkoaumz tfoot, #bfylkoaumz tr, #bfylkoaumz td, #bfylkoaumz th {
#>   border-style: none;
#> }
#> 
#> #bfylkoaumz p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #bfylkoaumz .gt_table {
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
#> #bfylkoaumz .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #bfylkoaumz .gt_title {
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
#> #bfylkoaumz .gt_subtitle {
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
#> #bfylkoaumz .gt_heading {
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
#> #bfylkoaumz .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bfylkoaumz .gt_col_headings {
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
#> #bfylkoaumz .gt_col_heading {
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
#> #bfylkoaumz .gt_column_spanner_outer {
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
#> #bfylkoaumz .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #bfylkoaumz .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #bfylkoaumz .gt_column_spanner {
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
#> #bfylkoaumz .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #bfylkoaumz .gt_group_heading {
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
#> #bfylkoaumz .gt_empty_group_heading {
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
#> #bfylkoaumz .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #bfylkoaumz .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #bfylkoaumz .gt_row {
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
#> #bfylkoaumz .gt_stub {
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
#> #bfylkoaumz .gt_stub_row_group {
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
#> #bfylkoaumz .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #bfylkoaumz .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #bfylkoaumz .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bfylkoaumz .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bfylkoaumz .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #bfylkoaumz .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bfylkoaumz .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bfylkoaumz .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bfylkoaumz .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bfylkoaumz .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #bfylkoaumz .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bfylkoaumz .gt_footnotes {
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
#> #bfylkoaumz .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bfylkoaumz .gt_sourcenotes {
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
#> #bfylkoaumz .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bfylkoaumz .gt_left {
#>   text-align: left;
#> }
#> 
#> #bfylkoaumz .gt_center {
#>   text-align: center;
#> }
#> 
#> #bfylkoaumz .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #bfylkoaumz .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #bfylkoaumz .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #bfylkoaumz .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #bfylkoaumz .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #bfylkoaumz .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #bfylkoaumz .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #bfylkoaumz .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #bfylkoaumz .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #bfylkoaumz .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #bfylkoaumz .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #bfylkoaumz .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #bfylkoaumz .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #bfylkoaumz div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:230px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#543005;color:#543005;"> </span><span style="display:inline-block;width:20px;background:#8C510A;color:#8C510A;"> </span><span style="display:inline-block;width:20px;background:#BF812D;color:#BF812D;"> </span><span style="display:inline-block;width:20px;background:#DFC27D;color:#DFC27D;"> </span><span style="display:inline-block;width:20px;background:#F6E8C3;color:#F6E8C3;"> </span><span style="display:inline-block;width:20px;background:#F5F5F5;color:#F5F5F5;"> </span><span style="display:inline-block;width:20px;background:#C7EAE5;color:#C7EAE5;"> </span><span style="display:inline-block;width:20px;background:#80CDC1;color:#80CDC1;"> </span><span style="display:inline-block;width:20px;background:#35978F;color:#35978F;"> </span><span style="display:inline-block;width:20px;background:#01665E;color:#01665E;"> </span><span style="display:inline-block;width:20px;background:#003C30;color:#003C30;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">PiYG</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#8E0152;color:#8E0152;"> </span><span style="display:inline-block;width:20px;background:#C51B7D;color:#C51B7D;"> </span><span style="display:inline-block;width:20px;background:#DE77AE;color:#DE77AE;"> </span><span style="display:inline-block;width:20px;background:#F1B6DA;color:#F1B6DA;"> </span><span style="display:inline-block;width:20px;background:#FDE0EF;color:#FDE0EF;"> </span><span style="display:inline-block;width:20px;background:#F7F7F7;color:#F7F7F7;"> </span><span style="display:inline-block;width:20px;background:#E6F5D0;color:#E6F5D0;"> </span><span style="display:inline-block;width:20px;background:#B8E186;color:#B8E186;"> </span><span style="display:inline-block;width:20px;background:#7FBC41;color:#7FBC41;"> </span><span style="display:inline-block;width:20px;background:#4D9221;color:#4D9221;"> </span><span style="display:inline-block;width:20px;background:#276419;color:#276419;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">PRGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#40004B;color:#40004B;"> </span><span style="display:inline-block;width:20px;background:#762A83;color:#762A83;"> </span><span style="display:inline-block;width:20px;background:#9970AB;color:#9970AB;"> </span><span style="display:inline-block;width:20px;background:#C2A5CF;color:#C2A5CF;"> </span><span style="display:inline-block;width:20px;background:#E7D4E8;color:#E7D4E8;"> </span><span style="display:inline-block;width:20px;background:#F7F7F7;color:#F7F7F7;"> </span><span style="display:inline-block;width:20px;background:#D9F0D3;color:#D9F0D3;"> </span><span style="display:inline-block;width:20px;background:#A6DBA0;color:#A6DBA0;"> </span><span style="display:inline-block;width:20px;background:#5AAE61;color:#5AAE61;"> </span><span style="display:inline-block;width:20px;background:#1B7837;color:#1B7837;"> </span><span style="display:inline-block;width:20px;background:#00441B;color:#00441B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">PuOr</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7F3B08;color:#7F3B08;"> </span><span style="display:inline-block;width:20px;background:#B35806;color:#B35806;"> </span><span style="display:inline-block;width:20px;background:#E08214;color:#E08214;"> </span><span style="display:inline-block;width:20px;background:#FDB863;color:#FDB863;"> </span><span style="display:inline-block;width:20px;background:#FEE0B6;color:#FEE0B6;"> </span><span style="display:inline-block;width:20px;background:#F7F7F7;color:#F7F7F7;"> </span><span style="display:inline-block;width:20px;background:#D8DAEB;color:#D8DAEB;"> </span><span style="display:inline-block;width:20px;background:#B2ABD2;color:#B2ABD2;"> </span><span style="display:inline-block;width:20px;background:#8073AC;color:#8073AC;"> </span><span style="display:inline-block;width:20px;background:#542788;color:#542788;"> </span><span style="display:inline-block;width:20px;background:#2D004B;color:#2D004B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#67001F;color:#67001F;"> </span><span style="display:inline-block;width:20px;background:#B2182B;color:#B2182B;"> </span><span style="display:inline-block;width:20px;background:#D6604D;color:#D6604D;"> </span><span style="display:inline-block;width:20px;background:#F4A582;color:#F4A582;"> </span><span style="display:inline-block;width:20px;background:#FDDBC7;color:#FDDBC7;"> </span><span style="display:inline-block;width:20px;background:#F7F7F7;color:#F7F7F7;"> </span><span style="display:inline-block;width:20px;background:#D1E5F0;color:#D1E5F0;"> </span><span style="display:inline-block;width:20px;background:#92C5DE;color:#92C5DE;"> </span><span style="display:inline-block;width:20px;background:#4393C3;color:#4393C3;"> </span><span style="display:inline-block;width:20px;background:#2166AC;color:#2166AC;"> </span><span style="display:inline-block;width:20px;background:#053061;color:#053061;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdGy</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#67001F;color:#67001F;"> </span><span style="display:inline-block;width:20px;background:#B2182B;color:#B2182B;"> </span><span style="display:inline-block;width:20px;background:#D6604D;color:#D6604D;"> </span><span style="display:inline-block;width:20px;background:#F4A582;color:#F4A582;"> </span><span style="display:inline-block;width:20px;background:#FDDBC7;color:#FDDBC7;"> </span><span style="display:inline-block;width:20px;background:#FFFFFF;color:#FFFFFF;"> </span><span style="display:inline-block;width:20px;background:#E0E0E0;color:#E0E0E0;"> </span><span style="display:inline-block;width:20px;background:#BABABA;color:#BABABA;"> </span><span style="display:inline-block;width:20px;background:#878787;color:#878787;"> </span><span style="display:inline-block;width:20px;background:#4D4D4D;color:#4D4D4D;"> </span><span style="display:inline-block;width:20px;background:#1A1A1A;color:#1A1A1A;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdYlBu</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#A50026;color:#A50026;"> </span><span style="display:inline-block;width:20px;background:#D73027;color:#D73027;"> </span><span style="display:inline-block;width:20px;background:#F46D43;color:#F46D43;"> </span><span style="display:inline-block;width:20px;background:#FDAE61;color:#FDAE61;"> </span><span style="display:inline-block;width:20px;background:#FEE090;color:#FEE090;"> </span><span style="display:inline-block;width:20px;background:#FFFFBF;color:#FFFFBF;"> </span><span style="display:inline-block;width:20px;background:#E0F3F8;color:#E0F3F8;"> </span><span style="display:inline-block;width:20px;background:#ABD9E9;color:#ABD9E9;"> </span><span style="display:inline-block;width:20px;background:#74ADD1;color:#74ADD1;"> </span><span style="display:inline-block;width:20px;background:#4575B4;color:#4575B4;"> </span><span style="display:inline-block;width:20px;background:#313695;color:#313695;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">RdYlGn</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#A50026;color:#A50026;"> </span><span style="display:inline-block;width:20px;background:#D73027;color:#D73027;"> </span><span style="display:inline-block;width:20px;background:#F46D43;color:#F46D43;"> </span><span style="display:inline-block;width:20px;background:#FDAE61;color:#FDAE61;"> </span><span style="display:inline-block;width:20px;background:#FEE08B;color:#FEE08B;"> </span><span style="display:inline-block;width:20px;background:#FFFFBF;color:#FFFFBF;"> </span><span style="display:inline-block;width:20px;background:#D9EF8B;color:#D9EF8B;"> </span><span style="display:inline-block;width:20px;background:#A6D96A;color:#A6D96A;"> </span><span style="display:inline-block;width:20px;background:#66BD63;color:#66BD63;"> </span><span style="display:inline-block;width:20px;background:#1A9850;color:#1A9850;"> </span><span style="display:inline-block;width:20px;background:#006837;color:#006837;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Spectral</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#9E0142;color:#9E0142;"> </span><span style="display:inline-block;width:20px;background:#D53E4F;color:#D53E4F;"> </span><span style="display:inline-block;width:20px;background:#F46D43;color:#F46D43;"> </span><span style="display:inline-block;width:20px;background:#FDAE61;color:#FDAE61;"> </span><span style="display:inline-block;width:20px;background:#FEE08B;color:#FEE08B;"> </span><span style="display:inline-block;width:20px;background:#FFFFBF;color:#FFFFBF;"> </span><span style="display:inline-block;width:20px;background:#E6F598;color:#E6F598;"> </span><span style="display:inline-block;width:20px;background:#ABDDA4;color:#ABDDA4;"> </span><span style="display:inline-block;width:20px;background:#66C2A5;color:#66C2A5;"> </span><span style="display:inline-block;width:20px;background:#3288BD;color:#3288BD;"> </span><span style="display:inline-block;width:20px;background:#5E4FA2;color:#5E4FA2;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F7FBFF;color:#F7FBFF;"> </span><span style="display:inline-block;width:20px;background:#DEEBF7;color:#DEEBF7;"> </span><span style="display:inline-block;width:20px;background:#C6DBEF;color:#C6DBEF;"> </span><span style="display:inline-block;width:20px;background:#9ECAE1;color:#9ECAE1;"> </span><span style="display:inline-block;width:20px;background:#6BAED6;color:#6BAED6;"> </span><span style="display:inline-block;width:20px;background:#4292C6;color:#4292C6;"> </span><span style="display:inline-block;width:20px;background:#2171B5;color:#2171B5;"> </span><span style="display:inline-block;width:20px;background:#08519C;color:#08519C;"> </span><span style="display:inline-block;width:20px;background:#08306B;color:#08306B;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Combine filters
pal_show(pattern = "Blues", type = "continuous")
#> <div id="xcyahawjnt" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#xcyahawjnt table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #xcyahawjnt thead, #xcyahawjnt tbody, #xcyahawjnt tfoot, #xcyahawjnt tr, #xcyahawjnt td, #xcyahawjnt th {
#>   border-style: none;
#> }
#> 
#> #xcyahawjnt p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #xcyahawjnt .gt_table {
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
#> #xcyahawjnt .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #xcyahawjnt .gt_title {
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
#> #xcyahawjnt .gt_subtitle {
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
#> #xcyahawjnt .gt_heading {
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
#> #xcyahawjnt .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xcyahawjnt .gt_col_headings {
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
#> #xcyahawjnt .gt_col_heading {
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
#> #xcyahawjnt .gt_column_spanner_outer {
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
#> #xcyahawjnt .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #xcyahawjnt .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #xcyahawjnt .gt_column_spanner {
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
#> #xcyahawjnt .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #xcyahawjnt .gt_group_heading {
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
#> #xcyahawjnt .gt_empty_group_heading {
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
#> #xcyahawjnt .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #xcyahawjnt .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #xcyahawjnt .gt_row {
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
#> #xcyahawjnt .gt_stub {
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
#> #xcyahawjnt .gt_stub_row_group {
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
#> #xcyahawjnt .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #xcyahawjnt .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #xcyahawjnt .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xcyahawjnt .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #xcyahawjnt .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #xcyahawjnt .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xcyahawjnt .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xcyahawjnt .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #xcyahawjnt .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xcyahawjnt .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #xcyahawjnt .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #xcyahawjnt .gt_footnotes {
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
#> #xcyahawjnt .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xcyahawjnt .gt_sourcenotes {
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
#> #xcyahawjnt .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #xcyahawjnt .gt_left {
#>   text-align: left;
#> }
#> 
#> #xcyahawjnt .gt_center {
#>   text-align: center;
#> }
#> 
#> #xcyahawjnt .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #xcyahawjnt .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #xcyahawjnt .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #xcyahawjnt .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #xcyahawjnt .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #xcyahawjnt .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #xcyahawjnt .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #xcyahawjnt .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #xcyahawjnt .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #xcyahawjnt .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #xcyahawjnt .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #xcyahawjnt .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #xcyahawjnt .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #xcyahawjnt div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:410px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F7FBFF;color:#F7FBFF;"> </span><span style="display:inline-block;width:20px;background:#DEEBF7;color:#DEEBF7;"> </span><span style="display:inline-block;width:20px;background:#C6DBEF;color:#C6DBEF;"> </span><span style="display:inline-block;width:20px;background:#9ECAE1;color:#9ECAE1;"> </span><span style="display:inline-block;width:20px;background:#6BAED6;color:#6BAED6;"> </span><span style="display:inline-block;width:20px;background:#4292C6;color:#4292C6;"> </span><span style="display:inline-block;width:20px;background:#2171B5;color:#2171B5;"> </span><span style="display:inline-block;width:20px;background:#08519C;color:#08519C;"> </span><span style="display:inline-block;width:20px;background:#08306B;color:#08306B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#273871;color:#273871;"> </span><span style="display:inline-block;width:20px;background:#283A74;color:#283A74;"> </span><span style="display:inline-block;width:20px;background:#293C76;color:#293C76;"> </span><span style="display:inline-block;width:20px;background:#2A3F79;color:#2A3F79;"> </span><span style="display:inline-block;width:20px;background:#2B417C;color:#2B417C;"> </span><span style="display:inline-block;width:20px;background:#2C437F;color:#2C437F;"> </span><span style="display:inline-block;width:20px;background:#2D4682;color:#2D4682;"> </span><span style="display:inline-block;width:20px;background:#2D4885;color:#2D4885;"> </span><span style="display:inline-block;width:20px;background:#2E4B88;color:#2E4B88;"> </span><span style="display:inline-block;width:20px;background:#2F4D8B;color:#2F4D8B;"> </span><span style="display:inline-block;width:20px;background:#2F4F8F;color:#2F4F8F;"> </span><span style="display:inline-block;width:20px;background:#305292;color:#305292;"> </span><span style="display:inline-block;width:20px;background:#305495;color:#305495;"> </span><span style="display:inline-block;width:20px;background:#315798;color:#315798;"> </span><span style="display:inline-block;width:20px;background:#31599B;color:#31599B;"> </span><span style="display:inline-block;width:20px;background:#315B9E;color:#315B9E;"> </span><span style="display:inline-block;width:20px;background:#325EA1;color:#325EA1;"> </span><span style="display:inline-block;width:20px;background:#3260A4;color:#3260A4;"> </span><span style="display:inline-block;width:20px;background:#3263A7;color:#3263A7;"> </span><span style="display:inline-block;width:20px;background:#3265AA;color:#3265AA;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_2</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#023FA5;color:#023FA5;"> </span><span style="display:inline-block;width:20px;background:#1141A4;color:#1141A4;"> </span><span style="display:inline-block;width:20px;background:#1A44A4;color:#1A44A4;"> </span><span style="display:inline-block;width:20px;background:#2146A4;color:#2146A4;"> </span><span style="display:inline-block;width:20px;background:#2749A4;color:#2749A4;"> </span><span style="display:inline-block;width:20px;background:#2C4BA4;color:#2C4BA4;"> </span><span style="display:inline-block;width:20px;background:#314DA4;color:#314DA4;"> </span><span style="display:inline-block;width:20px;background:#3550A5;color:#3550A5;"> </span><span style="display:inline-block;width:20px;background:#3952A5;color:#3952A5;"> </span><span style="display:inline-block;width:20px;background:#3C54A6;color:#3C54A6;"> </span><span style="display:inline-block;width:20px;background:#4056A6;color:#4056A6;"> </span><span style="display:inline-block;width:20px;background:#4359A7;color:#4359A7;"> </span><span style="display:inline-block;width:20px;background:#465BA8;color:#465BA8;"> </span><span style="display:inline-block;width:20px;background:#4A5DA8;color:#4A5DA8;"> </span><span style="display:inline-block;width:20px;background:#4D5FA9;color:#4D5FA9;"> </span><span style="display:inline-block;width:20px;background:#5062AA;color:#5062AA;"> </span><span style="display:inline-block;width:20px;background:#5264AA;color:#5264AA;"> </span><span style="display:inline-block;width:20px;background:#5566AB;color:#5566AB;"> </span><span style="display:inline-block;width:20px;background:#5868AC;color:#5868AC;"> </span><span style="display:inline-block;width:20px;background:#5B6AAD;color:#5B6AAD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">hcl_Blues_3</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 100</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#00366C;color:#00366C;"> </span><span style="display:inline-block;width:20px;background:#00386E;color:#00386E;"> </span><span style="display:inline-block;width:20px;background:#003A71;color:#003A71;"> </span><span style="display:inline-block;width:20px;background:#003D73;color:#003D73;"> </span><span style="display:inline-block;width:20px;background:#003F76;color:#003F76;"> </span><span style="display:inline-block;width:20px;background:#004178;color:#004178;"> </span><span style="display:inline-block;width:20px;background:#00447B;color:#00447B;"> </span><span style="display:inline-block;width:20px;background:#00467E;color:#00467E;"> </span><span style="display:inline-block;width:20px;background:#004981;color:#004981;"> </span><span style="display:inline-block;width:20px;background:#004B84;color:#004B84;"> </span><span style="display:inline-block;width:20px;background:#004D87;color:#004D87;"> </span><span style="display:inline-block;width:20px;background:#005089;color:#005089;"> </span><span style="display:inline-block;width:20px;background:#00528C;color:#00528C;"> </span><span style="display:inline-block;width:20px;background:#00558F;color:#00558F;"> </span><span style="display:inline-block;width:20px;background:#005793;color:#005793;"> </span><span style="display:inline-block;width:20px;background:#005A96;color:#005A96;"> </span><span style="display:inline-block;width:20px;background:#005C99;color:#005C99;"> </span><span style="display:inline-block;width:20px;background:#005F9C;color:#005F9C;"> </span><span style="display:inline-block;width:20px;background:#00619F;color:#00619F;"> </span><span style="display:inline-block;width:20px;background:#0064A2;color:#0064A2;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "^carto", type = "discrete")
#> <div id="irhetginva" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#irhetginva table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #irhetginva thead, #irhetginva tbody, #irhetginva tfoot, #irhetginva tr, #irhetginva td, #irhetginva th {
#>   border-style: none;
#> }
#> 
#> #irhetginva p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #irhetginva .gt_table {
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
#> #irhetginva .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #irhetginva .gt_title {
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
#> #irhetginva .gt_subtitle {
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
#> #irhetginva .gt_heading {
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
#> #irhetginva .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #irhetginva .gt_col_headings {
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
#> #irhetginva .gt_col_heading {
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
#> #irhetginva .gt_column_spanner_outer {
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
#> #irhetginva .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #irhetginva .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #irhetginva .gt_column_spanner {
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
#> #irhetginva .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #irhetginva .gt_group_heading {
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
#> #irhetginva .gt_empty_group_heading {
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
#> #irhetginva .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #irhetginva .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #irhetginva .gt_row {
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
#> #irhetginva .gt_stub {
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
#> #irhetginva .gt_stub_row_group {
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
#> #irhetginva .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #irhetginva .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #irhetginva .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #irhetginva .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #irhetginva .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #irhetginva .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #irhetginva .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #irhetginva .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #irhetginva .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #irhetginva .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #irhetginva .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #irhetginva .gt_footnotes {
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
#> #irhetginva .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #irhetginva .gt_sourcenotes {
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
#> #irhetginva .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #irhetginva .gt_left {
#>   text-align: left;
#> }
#> 
#> #irhetginva .gt_center {
#>   text-align: center;
#> }
#> 
#> #irhetginva .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #irhetginva .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #irhetginva .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #irhetginva .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #irhetginva .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #irhetginva .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #irhetginva .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #irhetginva .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #irhetginva .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #irhetginva .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #irhetginva .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #irhetginva .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #irhetginva .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #irhetginva div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:250px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#855C75;color:#855C75;"> </span><span style="display:inline-block;width:20px;background:#D9AF6B;color:#D9AF6B;"> </span><span style="display:inline-block;width:20px;background:#AF6458;color:#AF6458;"> </span><span style="display:inline-block;width:20px;background:#736F4C;color:#736F4C;"> </span><span style="display:inline-block;width:20px;background:#526A83;color:#526A83;"> </span><span style="display:inline-block;width:20px;background:#625377;color:#625377;"> </span><span style="display:inline-block;width:20px;background:#68855C;color:#68855C;"> </span><span style="display:inline-block;width:20px;background:#9C9C5E;color:#9C9C5E;"> </span><span style="display:inline-block;width:20px;background:#A06177;color:#A06177;"> </span><span style="display:inline-block;width:20px;background:#8C785D;color:#8C785D;"> </span><span style="display:inline-block;width:20px;background:#467378;color:#467378;"> </span><span style="display:inline-block;width:20px;background:#7C7C7C;color:#7C7C7C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Bold</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#7F3C8D;color:#7F3C8D;"> </span><span style="display:inline-block;width:20px;background:#11A579;color:#11A579;"> </span><span style="display:inline-block;width:20px;background:#3969AC;color:#3969AC;"> </span><span style="display:inline-block;width:20px;background:#F2B701;color:#F2B701;"> </span><span style="display:inline-block;width:20px;background:#E73F74;color:#E73F74;"> </span><span style="display:inline-block;width:20px;background:#80BA5A;color:#80BA5A;"> </span><span style="display:inline-block;width:20px;background:#E68310;color:#E68310;"> </span><span style="display:inline-block;width:20px;background:#008695;color:#008695;"> </span><span style="display:inline-block;width:20px;background:#CF1C90;color:#CF1C90;"> </span><span style="display:inline-block;width:20px;background:#F97B72;color:#F97B72;"> </span><span style="display:inline-block;width:20px;background:#4B4B8F;color:#4B4B8F;"> </span><span style="display:inline-block;width:20px;background:#A5AA99;color:#A5AA99;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Pastel</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#66C5CC;color:#66C5CC;"> </span><span style="display:inline-block;width:20px;background:#F6CF71;color:#F6CF71;"> </span><span style="display:inline-block;width:20px;background:#F89C74;color:#F89C74;"> </span><span style="display:inline-block;width:20px;background:#DCB0F2;color:#DCB0F2;"> </span><span style="display:inline-block;width:20px;background:#87C55F;color:#87C55F;"> </span><span style="display:inline-block;width:20px;background:#9EB9F3;color:#9EB9F3;"> </span><span style="display:inline-block;width:20px;background:#FE88B1;color:#FE88B1;"> </span><span style="display:inline-block;width:20px;background:#C9DB74;color:#C9DB74;"> </span><span style="display:inline-block;width:20px;background:#8BE0A4;color:#8BE0A4;"> </span><span style="display:inline-block;width:20px;background:#B497E7;color:#B497E7;"> </span><span style="display:inline-block;width:20px;background:#D3B484;color:#D3B484;"> </span><span style="display:inline-block;width:20px;background:#B3B3B3;color:#B3B3B3;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Prism</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#5F4690;color:#5F4690;"> </span><span style="display:inline-block;width:20px;background:#1D6996;color:#1D6996;"> </span><span style="display:inline-block;width:20px;background:#38A6A5;color:#38A6A5;"> </span><span style="display:inline-block;width:20px;background:#0F8554;color:#0F8554;"> </span><span style="display:inline-block;width:20px;background:#73AF48;color:#73AF48;"> </span><span style="display:inline-block;width:20px;background:#EDAD08;color:#EDAD08;"> </span><span style="display:inline-block;width:20px;background:#E17C05;color:#E17C05;"> </span><span style="display:inline-block;width:20px;background:#CC503E;color:#CC503E;"> </span><span style="display:inline-block;width:20px;background:#94346E;color:#94346E;"> </span><span style="display:inline-block;width:20px;background:#6F4070;color:#6F4070;"> </span><span style="display:inline-block;width:20px;background:#994E95;color:#994E95;"> </span><span style="display:inline-block;width:20px;background:#666666;color:#666666;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Safe</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#88CCEE;color:#88CCEE;"> </span><span style="display:inline-block;width:20px;background:#CC6677;color:#CC6677;"> </span><span style="display:inline-block;width:20px;background:#DDCC77;color:#DDCC77;"> </span><span style="display:inline-block;width:20px;background:#117733;color:#117733;"> </span><span style="display:inline-block;width:20px;background:#332288;color:#332288;"> </span><span style="display:inline-block;width:20px;background:#AA4499;color:#AA4499;"> </span><span style="display:inline-block;width:20px;background:#44AA99;color:#44AA99;"> </span><span style="display:inline-block;width:20px;background:#999933;color:#999933;"> </span><span style="display:inline-block;width:20px;background:#882255;color:#882255;"> </span><span style="display:inline-block;width:20px;background:#661100;color:#661100;"> </span><span style="display:inline-block;width:20px;background:#6699CC;color:#6699CC;"> </span><span style="display:inline-block;width:20px;background:#888888;color:#888888;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">carto_Vivid</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E58606;color:#E58606;"> </span><span style="display:inline-block;width:20px;background:#5D69B1;color:#5D69B1;"> </span><span style="display:inline-block;width:20px;background:#52BCA3;color:#52BCA3;"> </span><span style="display:inline-block;width:20px;background:#99C945;color:#99C945;"> </span><span style="display:inline-block;width:20px;background:#CC61B0;color:#CC61B0;"> </span><span style="display:inline-block;width:20px;background:#24796C;color:#24796C;"> </span><span style="display:inline-block;width:20px;background:#DAA51B;color:#DAA51B;"> </span><span style="display:inline-block;width:20px;background:#2F8AC4;color:#2F8AC4;"> </span><span style="display:inline-block;width:20px;background:#764E9F;color:#764E9F;"> </span><span style="display:inline-block;width:20px;background:#ED645A;color:#ED645A;"> </span><span style="display:inline-block;width:20px;background:#CC3A8E;color:#CC3A8E;"> </span><span style="display:inline-block;width:20px;background:#A5AA99;color:#A5AA99;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>

# Take a fixed number of colours from each palette
pal_show(c("Set1", "lancet"), n = 3)
#> <div id="hddwzcdexm" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#hddwzcdexm table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #hddwzcdexm thead, #hddwzcdexm tbody, #hddwzcdexm tfoot, #hddwzcdexm tr, #hddwzcdexm td, #hddwzcdexm th {
#>   border-style: none;
#> }
#> 
#> #hddwzcdexm p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #hddwzcdexm .gt_table {
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
#> #hddwzcdexm .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #hddwzcdexm .gt_title {
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
#> #hddwzcdexm .gt_subtitle {
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
#> #hddwzcdexm .gt_heading {
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
#> #hddwzcdexm .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hddwzcdexm .gt_col_headings {
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
#> #hddwzcdexm .gt_col_heading {
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
#> #hddwzcdexm .gt_column_spanner_outer {
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
#> #hddwzcdexm .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #hddwzcdexm .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #hddwzcdexm .gt_column_spanner {
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
#> #hddwzcdexm .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #hddwzcdexm .gt_group_heading {
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
#> #hddwzcdexm .gt_empty_group_heading {
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
#> #hddwzcdexm .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #hddwzcdexm .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #hddwzcdexm .gt_row {
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
#> #hddwzcdexm .gt_stub {
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
#> #hddwzcdexm .gt_stub_row_group {
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
#> #hddwzcdexm .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #hddwzcdexm .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #hddwzcdexm .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hddwzcdexm .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hddwzcdexm .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #hddwzcdexm .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hddwzcdexm .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hddwzcdexm .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hddwzcdexm .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hddwzcdexm .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #hddwzcdexm .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hddwzcdexm .gt_footnotes {
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
#> #hddwzcdexm .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hddwzcdexm .gt_sourcenotes {
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
#> #hddwzcdexm .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hddwzcdexm .gt_left {
#>   text-align: left;
#> }
#> 
#> #hddwzcdexm .gt_center {
#>   text-align: center;
#> }
#> 
#> #hddwzcdexm .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #hddwzcdexm .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #hddwzcdexm .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #hddwzcdexm .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #hddwzcdexm .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #hddwzcdexm .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #hddwzcdexm .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #hddwzcdexm .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #hddwzcdexm .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #hddwzcdexm .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #hddwzcdexm .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #hddwzcdexm .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #hddwzcdexm .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #hddwzcdexm div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:90px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>2 Palettes</strong></span></td>
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
#>     <tr><td headers="palette" class="gt_row gt_left">Set1</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">3</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E41A1C;color:#E41A1C;"> </span><span style="display:inline-block;width:20px;background:#377EB8;color:#377EB8;"> </span><span style="display:inline-block;width:20px;background:#4DAF4A;color:#4DAF4A;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">lancet</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">3</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#00468BFF;color:#00468BFF;"> </span><span style="display:inline-block;width:20px;background:#ED0000FF;color:#ED0000FF;"> </span><span style="display:inline-block;width:20px;background:#42B540FF;color:#42B540FF;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show("Set1", n = 12)  # only 9 colours, so interpolated
#> <div id="ufnwnhniql" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#ufnwnhniql table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #ufnwnhniql thead, #ufnwnhniql tbody, #ufnwnhniql tfoot, #ufnwnhniql tr, #ufnwnhniql td, #ufnwnhniql th {
#>   border-style: none;
#> }
#> 
#> #ufnwnhniql p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #ufnwnhniql .gt_table {
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
#> #ufnwnhniql .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #ufnwnhniql .gt_title {
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
#> #ufnwnhniql .gt_subtitle {
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
#> #ufnwnhniql .gt_heading {
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
#> #ufnwnhniql .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ufnwnhniql .gt_col_headings {
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
#> #ufnwnhniql .gt_col_heading {
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
#> #ufnwnhniql .gt_column_spanner_outer {
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
#> #ufnwnhniql .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #ufnwnhniql .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #ufnwnhniql .gt_column_spanner {
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
#> #ufnwnhniql .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #ufnwnhniql .gt_group_heading {
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
#> #ufnwnhniql .gt_empty_group_heading {
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
#> #ufnwnhniql .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #ufnwnhniql .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #ufnwnhniql .gt_row {
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
#> #ufnwnhniql .gt_stub {
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
#> #ufnwnhniql .gt_stub_row_group {
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
#> #ufnwnhniql .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #ufnwnhniql .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #ufnwnhniql .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ufnwnhniql .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ufnwnhniql .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #ufnwnhniql .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ufnwnhniql .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ufnwnhniql .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ufnwnhniql .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ufnwnhniql .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #ufnwnhniql .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ufnwnhniql .gt_footnotes {
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
#> #ufnwnhniql .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ufnwnhniql .gt_sourcenotes {
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
#> #ufnwnhniql .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ufnwnhniql .gt_left {
#>   text-align: left;
#> }
#> 
#> #ufnwnhniql .gt_center {
#>   text-align: center;
#> }
#> 
#> #ufnwnhniql .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #ufnwnhniql .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #ufnwnhniql .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #ufnwnhniql .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #ufnwnhniql .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #ufnwnhniql .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #ufnwnhniql .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #ufnwnhniql .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #ufnwnhniql .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #ufnwnhniql .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #ufnwnhniql .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #ufnwnhniql .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #ufnwnhniql .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #ufnwnhniql div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:250px;"/>
#>   </colgroup>
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>1 Palettes</strong></span></td>
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
#>     <tr><td headers="palette" class="gt_row gt_left">Set1</td>
#> <td headers="type" class="gt_row gt_left">discrete</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E41A1C;color:#E41A1C;"> </span><span style="display:inline-block;width:20px;background:#66628D;color:#66628D;"> </span><span style="display:inline-block;width:20px;background:#419486;color:#419486;"> </span><span style="display:inline-block;width:20px;background:#5A9D5A;color:#5A9D5A;"> </span><span style="display:inline-block;width:20px;background:#91569A;color:#91569A;"> </span><span style="display:inline-block;width:20px;background:#D96D3B;color:#D96D3B;"> </span><span style="display:inline-block;width:20px;background:#FFAD12;color:#FFAD12;"> </span><span style="display:inline-block;width:20px;background:#F6EF32;color:#F6EF32;"> </span><span style="display:inline-block;width:20px;background:#B6742A;color:#B6742A;"> </span><span style="display:inline-block;width:20px;background:#D26D7A;color:#D26D7A;"> </span><span style="display:inline-block;width:20px;background:#DD87B4;color:#DD87B4;"> </span><span style="display:inline-block;width:20px;background:#999999;color:#999999;"> </span></span></td></tr>
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
#> <div id="tkwrfyepgo" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#tkwrfyepgo table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #tkwrfyepgo thead, #tkwrfyepgo tbody, #tkwrfyepgo tfoot, #tkwrfyepgo tr, #tkwrfyepgo td, #tkwrfyepgo th {
#>   border-style: none;
#> }
#> 
#> #tkwrfyepgo p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #tkwrfyepgo .gt_table {
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
#> #tkwrfyepgo .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #tkwrfyepgo .gt_title {
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
#> #tkwrfyepgo .gt_subtitle {
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
#> #tkwrfyepgo .gt_heading {
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
#> #tkwrfyepgo .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tkwrfyepgo .gt_col_headings {
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
#> #tkwrfyepgo .gt_col_heading {
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
#> #tkwrfyepgo .gt_column_spanner_outer {
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
#> #tkwrfyepgo .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #tkwrfyepgo .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #tkwrfyepgo .gt_column_spanner {
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
#> #tkwrfyepgo .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #tkwrfyepgo .gt_group_heading {
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
#> #tkwrfyepgo .gt_empty_group_heading {
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
#> #tkwrfyepgo .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #tkwrfyepgo .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #tkwrfyepgo .gt_row {
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
#> #tkwrfyepgo .gt_stub {
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
#> #tkwrfyepgo .gt_stub_row_group {
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
#> #tkwrfyepgo .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #tkwrfyepgo .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #tkwrfyepgo .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tkwrfyepgo .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #tkwrfyepgo .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #tkwrfyepgo .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tkwrfyepgo .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tkwrfyepgo .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #tkwrfyepgo .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tkwrfyepgo .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #tkwrfyepgo .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tkwrfyepgo .gt_footnotes {
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
#> #tkwrfyepgo .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tkwrfyepgo .gt_sourcenotes {
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
#> #tkwrfyepgo .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tkwrfyepgo .gt_left {
#>   text-align: left;
#> }
#> 
#> #tkwrfyepgo .gt_center {
#>   text-align: center;
#> }
#> 
#> #tkwrfyepgo .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #tkwrfyepgo .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #tkwrfyepgo .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #tkwrfyepgo .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #tkwrfyepgo .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #tkwrfyepgo .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #tkwrfyepgo .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #tkwrfyepgo .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #tkwrfyepgo .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #tkwrfyepgo .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #tkwrfyepgo .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #tkwrfyepgo .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #tkwrfyepgo .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #tkwrfyepgo div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
pal_show(pal_paraSC, n = 6)
#> <div id="rtgyfvghoc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#rtgyfvghoc table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #rtgyfvghoc thead, #rtgyfvghoc tbody, #rtgyfvghoc tfoot, #rtgyfvghoc tr, #rtgyfvghoc td, #rtgyfvghoc th {
#>   border-style: none;
#> }
#> 
#> #rtgyfvghoc p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #rtgyfvghoc .gt_table {
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
#> #rtgyfvghoc .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #rtgyfvghoc .gt_title {
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
#> #rtgyfvghoc .gt_subtitle {
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
#> #rtgyfvghoc .gt_heading {
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
#> #rtgyfvghoc .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rtgyfvghoc .gt_col_headings {
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
#> #rtgyfvghoc .gt_col_heading {
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
#> #rtgyfvghoc .gt_column_spanner_outer {
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
#> #rtgyfvghoc .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #rtgyfvghoc .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #rtgyfvghoc .gt_column_spanner {
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
#> #rtgyfvghoc .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #rtgyfvghoc .gt_group_heading {
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
#> #rtgyfvghoc .gt_empty_group_heading {
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
#> #rtgyfvghoc .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #rtgyfvghoc .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #rtgyfvghoc .gt_row {
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
#> #rtgyfvghoc .gt_stub {
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
#> #rtgyfvghoc .gt_stub_row_group {
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
#> #rtgyfvghoc .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #rtgyfvghoc .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #rtgyfvghoc .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rtgyfvghoc .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #rtgyfvghoc .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #rtgyfvghoc .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rtgyfvghoc .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rtgyfvghoc .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #rtgyfvghoc .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rtgyfvghoc .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #rtgyfvghoc .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rtgyfvghoc .gt_footnotes {
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
#> #rtgyfvghoc .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rtgyfvghoc .gt_sourcenotes {
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
#> #rtgyfvghoc .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rtgyfvghoc .gt_left {
#>   text-align: left;
#> }
#> 
#> #rtgyfvghoc .gt_center {
#>   text-align: center;
#> }
#> 
#> #rtgyfvghoc .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #rtgyfvghoc .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #rtgyfvghoc .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #rtgyfvghoc .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #rtgyfvghoc .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #rtgyfvghoc .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #rtgyfvghoc .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #rtgyfvghoc .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #rtgyfvghoc .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #rtgyfvghoc .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #rtgyfvghoc .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #rtgyfvghoc .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #rtgyfvghoc .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #rtgyfvghoc div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_heading">
#>       <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><span class='gt_from_md'><strong>6 Colours</strong></span></td>
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
#>   </tbody>
#>   
#> </table>
#> </div>

# Show any colour vector
pal_show(c("#FF0000", "#00FF00", "#0000FF"))
#> <div id="fxagltsyth" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#fxagltsyth table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #fxagltsyth thead, #fxagltsyth tbody, #fxagltsyth tfoot, #fxagltsyth tr, #fxagltsyth td, #fxagltsyth th {
#>   border-style: none;
#> }
#> 
#> #fxagltsyth p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #fxagltsyth .gt_table {
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
#> #fxagltsyth .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #fxagltsyth .gt_title {
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
#> #fxagltsyth .gt_subtitle {
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
#> #fxagltsyth .gt_heading {
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
#> #fxagltsyth .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fxagltsyth .gt_col_headings {
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
#> #fxagltsyth .gt_col_heading {
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
#> #fxagltsyth .gt_column_spanner_outer {
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
#> #fxagltsyth .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #fxagltsyth .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #fxagltsyth .gt_column_spanner {
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
#> #fxagltsyth .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #fxagltsyth .gt_group_heading {
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
#> #fxagltsyth .gt_empty_group_heading {
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
#> #fxagltsyth .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #fxagltsyth .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #fxagltsyth .gt_row {
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
#> #fxagltsyth .gt_stub {
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
#> #fxagltsyth .gt_stub_row_group {
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
#> #fxagltsyth .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #fxagltsyth .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #fxagltsyth .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fxagltsyth .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #fxagltsyth .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #fxagltsyth .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fxagltsyth .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fxagltsyth .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #fxagltsyth .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fxagltsyth .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #fxagltsyth .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fxagltsyth .gt_footnotes {
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
#> #fxagltsyth .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fxagltsyth .gt_sourcenotes {
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
#> #fxagltsyth .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fxagltsyth .gt_left {
#>   text-align: left;
#> }
#> 
#> #fxagltsyth .gt_center {
#>   text-align: center;
#> }
#> 
#> #fxagltsyth .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #fxagltsyth .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #fxagltsyth .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #fxagltsyth .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #fxagltsyth .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #fxagltsyth .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #fxagltsyth .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #fxagltsyth .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #fxagltsyth .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #fxagltsyth .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #fxagltsyth .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #fxagltsyth .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #fxagltsyth .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #fxagltsyth div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#> <div id="eizlxjofrv" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#eizlxjofrv table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #eizlxjofrv thead, #eizlxjofrv tbody, #eizlxjofrv tfoot, #eizlxjofrv tr, #eizlxjofrv td, #eizlxjofrv th {
#>   border-style: none;
#> }
#> 
#> #eizlxjofrv p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #eizlxjofrv .gt_table {
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
#> #eizlxjofrv .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #eizlxjofrv .gt_title {
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
#> #eizlxjofrv .gt_subtitle {
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
#> #eizlxjofrv .gt_heading {
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
#> #eizlxjofrv .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eizlxjofrv .gt_col_headings {
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
#> #eizlxjofrv .gt_col_heading {
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
#> #eizlxjofrv .gt_column_spanner_outer {
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
#> #eizlxjofrv .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #eizlxjofrv .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #eizlxjofrv .gt_column_spanner {
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
#> #eizlxjofrv .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #eizlxjofrv .gt_group_heading {
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
#> #eizlxjofrv .gt_empty_group_heading {
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
#> #eizlxjofrv .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #eizlxjofrv .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #eizlxjofrv .gt_row {
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
#> #eizlxjofrv .gt_stub {
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
#> #eizlxjofrv .gt_stub_row_group {
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
#> #eizlxjofrv .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #eizlxjofrv .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #eizlxjofrv .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eizlxjofrv .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #eizlxjofrv .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #eizlxjofrv .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eizlxjofrv .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eizlxjofrv .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #eizlxjofrv .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eizlxjofrv .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #eizlxjofrv .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #eizlxjofrv .gt_footnotes {
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
#> #eizlxjofrv .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eizlxjofrv .gt_sourcenotes {
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
#> #eizlxjofrv .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #eizlxjofrv .gt_left {
#>   text-align: left;
#> }
#> 
#> #eizlxjofrv .gt_center {
#>   text-align: center;
#> }
#> 
#> #eizlxjofrv .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #eizlxjofrv .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #eizlxjofrv .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #eizlxjofrv .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #eizlxjofrv .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #eizlxjofrv .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #eizlxjofrv .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #eizlxjofrv .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #eizlxjofrv .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #eizlxjofrv .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #eizlxjofrv .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #eizlxjofrv .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #eizlxjofrv .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #eizlxjofrv div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#> <div id="cbryymsmui" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#cbryymsmui table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #cbryymsmui thead, #cbryymsmui tbody, #cbryymsmui tfoot, #cbryymsmui tr, #cbryymsmui td, #cbryymsmui th {
#>   border-style: none;
#> }
#> 
#> #cbryymsmui p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #cbryymsmui .gt_table {
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
#> #cbryymsmui .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #cbryymsmui .gt_title {
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
#> #cbryymsmui .gt_subtitle {
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
#> #cbryymsmui .gt_heading {
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
#> #cbryymsmui .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cbryymsmui .gt_col_headings {
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
#> #cbryymsmui .gt_col_heading {
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
#> #cbryymsmui .gt_column_spanner_outer {
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
#> #cbryymsmui .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #cbryymsmui .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #cbryymsmui .gt_column_spanner {
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
#> #cbryymsmui .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #cbryymsmui .gt_group_heading {
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
#> #cbryymsmui .gt_empty_group_heading {
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
#> #cbryymsmui .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #cbryymsmui .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #cbryymsmui .gt_row {
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
#> #cbryymsmui .gt_stub {
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
#> #cbryymsmui .gt_stub_row_group {
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
#> #cbryymsmui .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #cbryymsmui .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #cbryymsmui .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cbryymsmui .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #cbryymsmui .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #cbryymsmui .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cbryymsmui .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cbryymsmui .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #cbryymsmui .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cbryymsmui .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #cbryymsmui .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #cbryymsmui .gt_footnotes {
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
#> #cbryymsmui .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cbryymsmui .gt_sourcenotes {
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
#> #cbryymsmui .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #cbryymsmui .gt_left {
#>   text-align: left;
#> }
#> 
#> #cbryymsmui .gt_center {
#>   text-align: center;
#> }
#> 
#> #cbryymsmui .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #cbryymsmui .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #cbryymsmui .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #cbryymsmui .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #cbryymsmui .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #cbryymsmui .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #cbryymsmui .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #cbryymsmui .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #cbryymsmui .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #cbryymsmui .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #cbryymsmui .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #cbryymsmui .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #cbryymsmui .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #cbryymsmui div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#> <div id="hipisdmxva" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#hipisdmxva table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #hipisdmxva thead, #hipisdmxva tbody, #hipisdmxva tfoot, #hipisdmxva tr, #hipisdmxva td, #hipisdmxva th {
#>   border-style: none;
#> }
#> 
#> #hipisdmxva p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #hipisdmxva .gt_table {
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
#> #hipisdmxva .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #hipisdmxva .gt_title {
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
#> #hipisdmxva .gt_subtitle {
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
#> #hipisdmxva .gt_heading {
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
#> #hipisdmxva .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hipisdmxva .gt_col_headings {
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
#> #hipisdmxva .gt_col_heading {
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
#> #hipisdmxva .gt_column_spanner_outer {
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
#> #hipisdmxva .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #hipisdmxva .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #hipisdmxva .gt_column_spanner {
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
#> #hipisdmxva .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #hipisdmxva .gt_group_heading {
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
#> #hipisdmxva .gt_empty_group_heading {
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
#> #hipisdmxva .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #hipisdmxva .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #hipisdmxva .gt_row {
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
#> #hipisdmxva .gt_stub {
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
#> #hipisdmxva .gt_stub_row_group {
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
#> #hipisdmxva .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #hipisdmxva .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #hipisdmxva .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hipisdmxva .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hipisdmxva .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #hipisdmxva .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hipisdmxva .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hipisdmxva .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #hipisdmxva .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hipisdmxva .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #hipisdmxva .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #hipisdmxva .gt_footnotes {
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
#> #hipisdmxva .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hipisdmxva .gt_sourcenotes {
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
#> #hipisdmxva .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #hipisdmxva .gt_left {
#>   text-align: left;
#> }
#> 
#> #hipisdmxva .gt_center {
#>   text-align: center;
#> }
#> 
#> #hipisdmxva .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #hipisdmxva .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #hipisdmxva .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #hipisdmxva .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #hipisdmxva .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #hipisdmxva .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #hipisdmxva .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #hipisdmxva .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #hipisdmxva .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #hipisdmxva .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #hipisdmxva .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #hipisdmxva .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #hipisdmxva .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #hipisdmxva div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:410px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#663000;color:#663000;"> </span><span style="display:inline-block;width:20px;background:#996136;color:#996136;"> </span><span style="display:inline-block;width:20px;background:#CC9B7A;color:#CC9B7A;"> </span><span style="display:inline-block;width:20px;background:#D9AF98;color:#D9AF98;"> </span><span style="display:inline-block;width:20px;background:#F2DACE;color:#F2DACE;"> </span><span style="display:inline-block;width:20px;background:#CCFDFF;color:#CCFDFF;"> </span><span style="display:inline-block;width:20px;background:#99F8FF;color:#99F8FF;"> </span><span style="display:inline-block;width:20px;background:#66F0FF;color:#66F0FF;"> </span><span style="display:inline-block;width:20px;background:#33E4FF;color:#33E4FF;"> </span><span style="display:inline-block;width:20px;background:#00AACC;color:#00AACC;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BrowntoBlue.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#331A00;color:#331A00;"> </span><span style="display:inline-block;width:20px;background:#663000;color:#663000;"> </span><span style="display:inline-block;width:20px;background:#996136;color:#996136;"> </span><span style="display:inline-block;width:20px;background:#CC9B7A;color:#CC9B7A;"> </span><span style="display:inline-block;width:20px;background:#D9AF98;color:#D9AF98;"> </span><span style="display:inline-block;width:20px;background:#F2DACE;color:#F2DACE;"> </span><span style="display:inline-block;width:20px;background:#CCFDFF;color:#CCFDFF;"> </span><span style="display:inline-block;width:20px;background:#99F8FF;color:#99F8FF;"> </span><span style="display:inline-block;width:20px;background:#66F0FF;color:#66F0FF;"> </span><span style="display:inline-block;width:20px;background:#33E4FF;color:#33E4FF;"> </span><span style="display:inline-block;width:20px;background:#00AACC;color:#00AACC;"> </span><span style="display:inline-block;width:20px;background:#007A99;color:#007A99;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoDarkOrange.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#1F8F99;color:#1F8F99;"> </span><span style="display:inline-block;width:20px;background:#52C4CC;color:#52C4CC;"> </span><span style="display:inline-block;width:20px;background:#99FAFF;color:#99FAFF;"> </span><span style="display:inline-block;width:20px;background:#B2FCFF;color:#B2FCFF;"> </span><span style="display:inline-block;width:20px;background:#CCFEFF;color:#CCFEFF;"> </span><span style="display:inline-block;width:20px;background:#E6FFFF;color:#E6FFFF;"> </span><span style="display:inline-block;width:20px;background:#FFE6CC;color:#FFE6CC;"> </span><span style="display:inline-block;width:20px;background:#FFCA99;color:#FFCA99;"> </span><span style="display:inline-block;width:20px;background:#FFAD66;color:#FFAD66;"> </span><span style="display:inline-block;width:20px;background:#FF8F33;color:#FF8F33;"> </span><span style="display:inline-block;width:20px;background:#CC5800;color:#CC5800;"> </span><span style="display:inline-block;width:20px;background:#994000;color:#994000;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoDarkOrange.18</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">18</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#006666;color:#006666;"> </span><span style="display:inline-block;width:20px;background:#009999;color:#009999;"> </span><span style="display:inline-block;width:20px;background:#00CCCC;color:#00CCCC;"> </span><span style="display:inline-block;width:20px;background:#00FFFF;color:#00FFFF;"> </span><span style="display:inline-block;width:20px;background:#33FFFF;color:#33FFFF;"> </span><span style="display:inline-block;width:20px;background:#66FFFF;color:#66FFFF;"> </span><span style="display:inline-block;width:20px;background:#99FFFF;color:#99FFFF;"> </span><span style="display:inline-block;width:20px;background:#B2FFFF;color:#B2FFFF;"> </span><span style="display:inline-block;width:20px;background:#CCFFFF;color:#CCFFFF;"> </span><span style="display:inline-block;width:20px;background:#E6FFFF;color:#E6FFFF;"> </span><span style="display:inline-block;width:20px;background:#FFE6CC;color:#FFE6CC;"> </span><span style="display:inline-block;width:20px;background:#FFCA99;color:#FFCA99;"> </span><span style="display:inline-block;width:20px;background:#FFAD66;color:#FFAD66;"> </span><span style="display:inline-block;width:20px;background:#FF8F33;color:#FF8F33;"> </span><span style="display:inline-block;width:20px;background:#FF6E00;color:#FF6E00;"> </span><span style="display:inline-block;width:20px;background:#CC5500;color:#CC5500;"> </span><span style="display:inline-block;width:20px;background:#993D00;color:#993D00;"> </span><span style="display:inline-block;width:20px;background:#662700;color:#662700;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_DarkRedtoBlue.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2A0BD9;color:#2A0BD9;"> </span><span style="display:inline-block;width:20px;background:#264EFF;color:#264EFF;"> </span><span style="display:inline-block;width:20px;background:#40A1FF;color:#40A1FF;"> </span><span style="display:inline-block;width:20px;background:#73DAFF;color:#73DAFF;"> </span><span style="display:inline-block;width:20px;background:#ABF8FF;color:#ABF8FF;"> </span><span style="display:inline-block;width:20px;background:#E0FFFF;color:#E0FFFF;"> </span><span style="display:inline-block;width:20px;background:#FFFFBF;color:#FFFFBF;"> </span><span style="display:inline-block;width:20px;background:#FFE099;color:#FFE099;"> </span><span style="display:inline-block;width:20px;background:#FFAD73;color:#FFAD73;"> </span><span style="display:inline-block;width:20px;background:#F76E5E;color:#F76E5E;"> </span><span style="display:inline-block;width:20px;background:#D92632;color:#D92632;"> </span><span style="display:inline-block;width:20px;background:#A60021;color:#A60021;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_DarkRedtoBlue.18</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">18</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2400D9;color:#2400D9;"> </span><span style="display:inline-block;width:20px;background:#191DF7;color:#191DF7;"> </span><span style="display:inline-block;width:20px;background:#2957FF;color:#2957FF;"> </span><span style="display:inline-block;width:20px;background:#3D87FF;color:#3D87FF;"> </span><span style="display:inline-block;width:20px;background:#57B0FF;color:#57B0FF;"> </span><span style="display:inline-block;width:20px;background:#75D3FF;color:#75D3FF;"> </span><span style="display:inline-block;width:20px;background:#99EBFF;color:#99EBFF;"> </span><span style="display:inline-block;width:20px;background:#BDF9FF;color:#BDF9FF;"> </span><span style="display:inline-block;width:20px;background:#EBFFFF;color:#EBFFFF;"> </span><span style="display:inline-block;width:20px;background:#FFFFEB;color:#FFFFEB;"> </span><span style="display:inline-block;width:20px;background:#FFF2BD;color:#FFF2BD;"> </span><span style="display:inline-block;width:20px;background:#FFD699;color:#FFD699;"> </span><span style="display:inline-block;width:20px;background:#FFAC75;color:#FFAC75;"> </span><span style="display:inline-block;width:20px;background:#FF7857;color:#FF7857;"> </span><span style="display:inline-block;width:20px;background:#FF3D3D;color:#FF3D3D;"> </span><span style="display:inline-block;width:20px;background:#F72836;color:#F72836;"> </span><span style="display:inline-block;width:20px;background:#D91630;color:#D91630;"> </span><span style="display:inline-block;width:20px;background:#A60021;color:#A60021;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoGreen.14</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">14</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#0000FF;color:#0000FF;"> </span><span style="display:inline-block;width:20px;background:#3333FF;color:#3333FF;"> </span><span style="display:inline-block;width:20px;background:#6666FF;color:#6666FF;"> </span><span style="display:inline-block;width:20px;background:#9999FF;color:#9999FF;"> </span><span style="display:inline-block;width:20px;background:#B2B2FF;color:#B2B2FF;"> </span><span style="display:inline-block;width:20px;background:#CCCCFF;color:#CCCCFF;"> </span><span style="display:inline-block;width:20px;background:#E6E6FF;color:#E6E6FF;"> </span><span style="display:inline-block;width:20px;background:#E6FFE6;color:#E6FFE6;"> </span><span style="display:inline-block;width:20px;background:#CCFFCC;color:#CCFFCC;"> </span><span style="display:inline-block;width:20px;background:#B2FFB2;color:#B2FFB2;"> </span><span style="display:inline-block;width:20px;background:#99FF99;color:#99FF99;"> </span><span style="display:inline-block;width:20px;background:#66FF66;color:#66FF66;"> </span><span style="display:inline-block;width:20px;background:#33FF33;color:#33FF33;"> </span><span style="display:inline-block;width:20px;background:#00FF00;color:#00FF00;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoGray.8</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#0099CC;color:#0099CC;"> </span><span style="display:inline-block;width:20px;background:#66E6FF;color:#66E6FF;"> </span><span style="display:inline-block;width:20px;background:#99FFFF;color:#99FFFF;"> </span><span style="display:inline-block;width:20px;background:#CCFFFF;color:#CCFFFF;"> </span><span style="display:inline-block;width:20px;background:#E6E6E6;color:#E6E6E6;"> </span><span style="display:inline-block;width:20px;background:#999999;color:#999999;"> </span><span style="display:inline-block;width:20px;background:#666666;color:#666666;"> </span><span style="display:inline-block;width:20px;background:#333333;color:#333333;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrangeRed.14</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">14</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#085AFF;color:#085AFF;"> </span><span style="display:inline-block;width:20px;background:#3377FF;color:#3377FF;"> </span><span style="display:inline-block;width:20px;background:#5991FF;color:#5991FF;"> </span><span style="display:inline-block;width:20px;background:#8CB2FF;color:#8CB2FF;"> </span><span style="display:inline-block;width:20px;background:#BFD4FF;color:#BFD4FF;"> </span><span style="display:inline-block;width:20px;background:#E6EEFF;color:#E6EEFF;"> </span><span style="display:inline-block;width:20px;background:#F7FAFF;color:#F7FAFF;"> </span><span style="display:inline-block;width:20px;background:#FFFFCC;color:#FFFFCC;"> </span><span style="display:inline-block;width:20px;background:#FFFF99;color:#FFFF99;"> </span><span style="display:inline-block;width:20px;background:#FFFF00;color:#FFFF00;"> </span><span style="display:inline-block;width:20px;background:#FFCC00;color:#FFCC00;"> </span><span style="display:inline-block;width:20px;background:#FF9900;color:#FF9900;"> </span><span style="display:inline-block;width:20px;background:#FF6600;color:#FF6600;"> </span><span style="display:inline-block;width:20px;background:#FF0000;color:#FF0000;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrange.10</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#0055FF;color:#0055FF;"> </span><span style="display:inline-block;width:20px;background:#3399FF;color:#3399FF;"> </span><span style="display:inline-block;width:20px;background:#66CCFF;color:#66CCFF;"> </span><span style="display:inline-block;width:20px;background:#99EEFF;color:#99EEFF;"> </span><span style="display:inline-block;width:20px;background:#CCFFFF;color:#CCFFFF;"> </span><span style="display:inline-block;width:20px;background:#FFFFCC;color:#FFFFCC;"> </span><span style="display:inline-block;width:20px;background:#FFEE99;color:#FFEE99;"> </span><span style="display:inline-block;width:20px;background:#FFCC66;color:#FFCC66;"> </span><span style="display:inline-block;width:20px;background:#FF9933;color:#FF9933;"> </span><span style="display:inline-block;width:20px;background:#FF5500;color:#FF5500;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrange.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#002BFF;color:#002BFF;"> </span><span style="display:inline-block;width:20px;background:#1A66FF;color:#1A66FF;"> </span><span style="display:inline-block;width:20px;background:#3399FF;color:#3399FF;"> </span><span style="display:inline-block;width:20px;background:#66CCFF;color:#66CCFF;"> </span><span style="display:inline-block;width:20px;background:#99EEFF;color:#99EEFF;"> </span><span style="display:inline-block;width:20px;background:#CCFFFF;color:#CCFFFF;"> </span><span style="display:inline-block;width:20px;background:#FFFFCC;color:#FFFFCC;"> </span><span style="display:inline-block;width:20px;background:#FFEE99;color:#FFEE99;"> </span><span style="display:inline-block;width:20px;background:#FFCC66;color:#FFCC66;"> </span><span style="display:inline-block;width:20px;background:#FF9933;color:#FF9933;"> </span><span style="display:inline-block;width:20px;background:#FF661A;color:#FF661A;"> </span><span style="display:inline-block;width:20px;background:#FF2B00;color:#FF2B00;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_BluetoOrange.8</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#0080FF;color:#0080FF;"> </span><span style="display:inline-block;width:20px;background:#4CC4FF;color:#4CC4FF;"> </span><span style="display:inline-block;width:20px;background:#99EEFF;color:#99EEFF;"> </span><span style="display:inline-block;width:20px;background:#CCFFFF;color:#CCFFFF;"> </span><span style="display:inline-block;width:20px;background:#FFFFCC;color:#FFFFCC;"> </span><span style="display:inline-block;width:20px;background:#FFEE99;color:#FFEE99;"> </span><span style="display:inline-block;width:20px;background:#FFC44C;color:#FFC44C;"> </span><span style="display:inline-block;width:20px;background:#FF8000;color:#FF8000;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_LightBluetoDarkBlue.10</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#E6FFFF;color:#E6FFFF;"> </span><span style="display:inline-block;width:20px;background:#CCFBFF;color:#CCFBFF;"> </span><span style="display:inline-block;width:20px;background:#B2F2FF;color:#B2F2FF;"> </span><span style="display:inline-block;width:20px;background:#99E6FF;color:#99E6FF;"> </span><span style="display:inline-block;width:20px;background:#80D4FF;color:#80D4FF;"> </span><span style="display:inline-block;width:20px;background:#66BFFF;color:#66BFFF;"> </span><span style="display:inline-block;width:20px;background:#4CA6FF;color:#4CA6FF;"> </span><span style="display:inline-block;width:20px;background:#3388FF;color:#3388FF;"> </span><span style="display:inline-block;width:20px;background:#1A66FF;color:#1A66FF;"> </span><span style="display:inline-block;width:20px;background:#0040FF;color:#0040FF;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_LightBluetoDarkBlue.7</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFFFFF;color:#FFFFFF;"> </span><span style="display:inline-block;width:20px;background:#CCFDFF;color:#CCFDFF;"> </span><span style="display:inline-block;width:20px;background:#99F8FF;color:#99F8FF;"> </span><span style="display:inline-block;width:20px;background:#66F0FF;color:#66F0FF;"> </span><span style="display:inline-block;width:20px;background:#33E4FF;color:#33E4FF;"> </span><span style="display:inline-block;width:20px;background:#00AACC;color:#00AACC;"> </span><span style="display:inline-block;width:20px;background:#007A99;color:#007A99;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_Categorical.12</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">12</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFBF80;color:#FFBF80;"> </span><span style="display:inline-block;width:20px;background:#FF8000;color:#FF8000;"> </span><span style="display:inline-block;width:20px;background:#FFFF99;color:#FFFF99;"> </span><span style="display:inline-block;width:20px;background:#FFFF33;color:#FFFF33;"> </span><span style="display:inline-block;width:20px;background:#B2FF8C;color:#B2FF8C;"> </span><span style="display:inline-block;width:20px;background:#33FF00;color:#33FF00;"> </span><span style="display:inline-block;width:20px;background:#A6EDFF;color:#A6EDFF;"> </span><span style="display:inline-block;width:20px;background:#1AB2FF;color:#1AB2FF;"> </span><span style="display:inline-block;width:20px;background:#CCBFFF;color:#CCBFFF;"> </span><span style="display:inline-block;width:20px;background:#664CFF;color:#664CFF;"> </span><span style="display:inline-block;width:20px;background:#FF99BF;color:#FF99BF;"> </span><span style="display:inline-block;width:20px;background:#E61A33;color:#E61A33;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_GreentoMagenta.16</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">16</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#005100;color:#005100;"> </span><span style="display:inline-block;width:20px;background:#008600;color:#008600;"> </span><span style="display:inline-block;width:20px;background:#00BC00;color:#00BC00;"> </span><span style="display:inline-block;width:20px;background:#00F100;color:#00F100;"> </span><span style="display:inline-block;width:20px;background:#51FF51;color:#51FF51;"> </span><span style="display:inline-block;width:20px;background:#86FF86;color:#86FF86;"> </span><span style="display:inline-block;width:20px;background:#BCFFBC;color:#BCFFBC;"> </span><span style="display:inline-block;width:20px;background:#FFFFFF;color:#FFFFFF;"> </span><span style="display:inline-block;width:20px;background:#FFF1FF;color:#FFF1FF;"> </span><span style="display:inline-block;width:20px;background:#FFBCFF;color:#FFBCFF;"> </span><span style="display:inline-block;width:20px;background:#FF86FF;color:#FF86FF;"> </span><span style="display:inline-block;width:20px;background:#FF51FF;color:#FF51FF;"> </span><span style="display:inline-block;width:20px;background:#F100F1;color:#F100F1;"> </span><span style="display:inline-block;width:20px;background:#BC00BC;color:#BC00BC;"> </span><span style="display:inline-block;width:20px;background:#860086;color:#860086;"> </span><span style="display:inline-block;width:20px;background:#510051;color:#510051;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">dichromat_SteppedSequential.5</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 25</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#990F0F;color:#990F0F;"> </span><span style="display:inline-block;width:20px;background:#B22D2D;color:#B22D2D;"> </span><span style="display:inline-block;width:20px;background:#CC5252;color:#CC5252;"> </span><span style="display:inline-block;width:20px;background:#E67E7E;color:#E67E7E;"> </span><span style="display:inline-block;width:20px;background:#FFB2B2;color:#FFB2B2;"> </span><span style="display:inline-block;width:20px;background:#99700F;color:#99700F;"> </span><span style="display:inline-block;width:20px;background:#B28B2D;color:#B28B2D;"> </span><span style="display:inline-block;width:20px;background:#CCA852;color:#CCA852;"> </span><span style="display:inline-block;width:20px;background:#E6C77E;color:#E6C77E;"> </span><span style="display:inline-block;width:20px;background:#FFE8B2;color:#FFE8B2;"> </span><span style="display:inline-block;width:20px;background:#1F990F;color:#1F990F;"> </span><span style="display:inline-block;width:20px;background:#3CB22D;color:#3CB22D;"> </span><span style="display:inline-block;width:20px;background:#60CC52;color:#60CC52;"> </span><span style="display:inline-block;width:20px;background:#8AE67E;color:#8AE67E;"> </span><span style="display:inline-block;width:20px;background:#BCFFB2;color:#BCFFB2;"> </span><span style="display:inline-block;width:20px;background:#710F99;color:#710F99;"> </span><span style="display:inline-block;width:20px;background:#8B2DB2;color:#8B2DB2;"> </span><span style="display:inline-block;width:20px;background:#A852CC;color:#A852CC;"> </span><span style="display:inline-block;width:20px;background:#C77EE6;color:#C77EE6;"> </span><span style="display:inline-block;width:20px;background:#E9B2FF;color:#E9B2FF;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
pal_show(pattern = "^pals")
#> <div id="tqrbhcwclr" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#tqrbhcwclr table {
#>   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #tqrbhcwclr thead, #tqrbhcwclr tbody, #tqrbhcwclr tfoot, #tqrbhcwclr tr, #tqrbhcwclr td, #tqrbhcwclr th {
#>   border-style: none;
#> }
#> 
#> #tqrbhcwclr p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #tqrbhcwclr .gt_table {
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
#> #tqrbhcwclr .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #tqrbhcwclr .gt_title {
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
#> #tqrbhcwclr .gt_subtitle {
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
#> #tqrbhcwclr .gt_heading {
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
#> #tqrbhcwclr .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tqrbhcwclr .gt_col_headings {
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
#> #tqrbhcwclr .gt_col_heading {
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
#> #tqrbhcwclr .gt_column_spanner_outer {
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
#> #tqrbhcwclr .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #tqrbhcwclr .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #tqrbhcwclr .gt_column_spanner {
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
#> #tqrbhcwclr .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #tqrbhcwclr .gt_group_heading {
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
#> #tqrbhcwclr .gt_empty_group_heading {
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
#> #tqrbhcwclr .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #tqrbhcwclr .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #tqrbhcwclr .gt_row {
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
#> #tqrbhcwclr .gt_stub {
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
#> #tqrbhcwclr .gt_stub_row_group {
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
#> #tqrbhcwclr .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #tqrbhcwclr .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #tqrbhcwclr .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tqrbhcwclr .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #tqrbhcwclr .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #tqrbhcwclr .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tqrbhcwclr .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tqrbhcwclr .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #tqrbhcwclr .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tqrbhcwclr .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #tqrbhcwclr .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #tqrbhcwclr .gt_footnotes {
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
#> #tqrbhcwclr .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tqrbhcwclr .gt_sourcenotes {
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
#> #tqrbhcwclr .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #tqrbhcwclr .gt_left {
#>   text-align: left;
#> }
#> 
#> #tqrbhcwclr .gt_center {
#>   text-align: center;
#> }
#> 
#> #tqrbhcwclr .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #tqrbhcwclr .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #tqrbhcwclr .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #tqrbhcwclr .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #tqrbhcwclr .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #tqrbhcwclr .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #tqrbhcwclr .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #tqrbhcwclr .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #tqrbhcwclr .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #tqrbhcwclr .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #tqrbhcwclr .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #tqrbhcwclr .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #tqrbhcwclr .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #tqrbhcwclr div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" style="table-layout:fixed;width:0px;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <colgroup>
#>     <col style="width:180px;"/>
#>     <col style="width:80px;"/>
#>     <col style="width:70px;"/>
#>     <col style="width:410px;"/>
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
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#122414;color:#122414;"> </span><span style="display:inline-block;width:20px;background:#193F29;color:#193F29;"> </span><span style="display:inline-block;width:20px;background:#185B3B;color:#185B3B;"> </span><span style="display:inline-block;width:20px;background:#0C7748;color:#0C7748;"> </span><span style="display:inline-block;width:20px;background:#129450;color:#129450;"> </span><span style="display:inline-block;width:20px;background:#50AD59;color:#50AD59;"> </span><span style="display:inline-block;width:20px;background:#84C47A;color:#84C47A;"> </span><span style="display:inline-block;width:20px;background:#AFDDA2;color:#AFDDA2;"> </span><span style="display:inline-block;width:20px;background:#D7F9D0;color:#D7F9D0;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.deep</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">13</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#281A2C;color:#281A2C;"> </span><span style="display:inline-block;width:20px;background:#352A4A;color:#352A4A;"> </span><span style="display:inline-block;width:20px;background:#3F396D;color:#3F396D;"> </span><span style="display:inline-block;width:20px;background:#404C8B;color:#404C8B;"> </span><span style="display:inline-block;width:20px;background:#3E6495;color:#3E6495;"> </span><span style="display:inline-block;width:20px;background:#427999;color:#427999;"> </span><span style="display:inline-block;width:20px;background:#488E9E;color:#488E9E;"> </span><span style="display:inline-block;width:20px;background:#50A3A2;color:#50A3A2;"> </span><span style="display:inline-block;width:20px;background:#5DBAA4;color:#5DBAA4;"> </span><span style="display:inline-block;width:20px;background:#78CEA3;color:#78CEA3;"> </span><span style="display:inline-block;width:20px;background:#A3DEA6;color:#A3DEA6;"> </span><span style="display:inline-block;width:20px;background:#D1EDB4;color:#D1EDB4;"> </span><span style="display:inline-block;width:20px;background:#FDFECC;color:#FDFECC;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.dense</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#360E24;color:#360E24;"> </span><span style="display:inline-block;width:20px;background:#5D1A58;color:#5D1A58;"> </span><span style="display:inline-block;width:20px;background:#723692;color:#723692;"> </span><span style="display:inline-block;width:20px;background:#795CC3;color:#795CC3;"> </span><span style="display:inline-block;width:20px;background:#7487E0;color:#7487E0;"> </span><span style="display:inline-block;width:20px;background:#7EB0E4;color:#7EB0E4;"> </span><span style="display:inline-block;width:20px;background:#AAD2E3;color:#AAD2E3;"> </span><span style="display:inline-block;width:20px;background:#E6F1F1;color:#E6F1F1;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.gray</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">5</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#000000;color:#000000;"> </span><span style="display:inline-block;width:20px;background:#363636;color:#363636;"> </span><span style="display:inline-block;width:20px;background:#717070;color:#717070;"> </span><span style="display:inline-block;width:20px;background:#B1B1B0;color:#B1B1B0;"> </span><span style="display:inline-block;width:20px;background:#FFFFFD;color:#FFFFFD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.haline</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 24</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2A186C;color:#2A186C;"> </span><span style="display:inline-block;width:20px;background:#2E1B87;color:#2E1B87;"> </span><span style="display:inline-block;width:20px;background:#2B229F;color:#2B229F;"> </span><span style="display:inline-block;width:20px;background:#1D35A1;color:#1D35A1;"> </span><span style="display:inline-block;width:20px;background:#11459A;color:#11459A;"> </span><span style="display:inline-block;width:20px;background:#0C5294;color:#0C5294;"> </span><span style="display:inline-block;width:20px;background:#115D8F;color:#115D8F;"> </span><span style="display:inline-block;width:20px;background:#19678C;color:#19678C;"> </span><span style="display:inline-block;width:20px;background:#22718A;color:#22718A;"> </span><span style="display:inline-block;width:20px;background:#2B7A89;color:#2B7A89;"> </span><span style="display:inline-block;width:20px;background:#328388;color:#328388;"> </span><span style="display:inline-block;width:20px;background:#388D88;color:#388D88;"> </span><span style="display:inline-block;width:20px;background:#3E9886;color:#3E9886;"> </span><span style="display:inline-block;width:20px;background:#44A284;color:#44A284;"> </span><span style="display:inline-block;width:20px;background:#4CAC80;color:#4CAC80;"> </span><span style="display:inline-block;width:20px;background:#55B67A;color:#55B67A;"> </span><span style="display:inline-block;width:20px;background:#62BF72;color:#62BF72;"> </span><span style="display:inline-block;width:20px;background:#73C869;color:#73C869;"> </span><span style="display:inline-block;width:20px;background:#8AD060;color:#8AD060;"> </span><span style="display:inline-block;width:20px;background:#A4D75C;color:#A4D75C;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.ice</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">10</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#040613;color:#040613;"> </span><span style="display:inline-block;width:20px;background:#1E1D3B;color:#1E1D3B;"> </span><span style="display:inline-block;width:20px;background:#333268;color:#333268;"> </span><span style="display:inline-block;width:20px;background:#3F4B96;color:#3F4B96;"> </span><span style="display:inline-block;width:20px;background:#3E6AB0;color:#3E6AB0;"> </span><span style="display:inline-block;width:20px;background:#4989BC;color:#4989BC;"> </span><span style="display:inline-block;width:20px;background:#61A8C7;color:#61A8C7;"> </span><span style="display:inline-block;width:20px;background:#83C5D3;color:#83C5D3;"> </span><span style="display:inline-block;width:20px;background:#B6E0E3;color:#B6E0E3;"> </span><span style="display:inline-block;width:20px;background:#EAFDFD;color:#EAFDFD;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.matter</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#2F0F3E;color:#2F0F3E;"> </span><span style="display:inline-block;width:20px;background:#581756;color:#581756;"> </span><span style="display:inline-block;width:20px;background:#831C63;color:#831C63;"> </span><span style="display:inline-block;width:20px;background:#AB2960;color:#AB2960;"> </span><span style="display:inline-block;width:20px;background:#CE4356;color:#CE4356;"> </span><span style="display:inline-block;width:20px;background:#E66A54;color:#E66A54;"> </span><span style="display:inline-block;width:20px;background:#F29567;color:#F29567;"> </span><span style="display:inline-block;width:20px;background:#F9C187;color:#F9C187;"> </span><span style="display:inline-block;width:20px;background:#FEEDB0;color:#FEEDB0;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.oxy</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#400505;color:#400505;"> </span><span style="display:inline-block;width:20px;background:#54070A;color:#54070A;"> </span><span style="display:inline-block;width:20px;background:#6A060F;color:#6A060F;"> </span><span style="display:inline-block;width:20px;background:#80060D;color:#80060D;"> </span><span style="display:inline-block;width:20px;background:#901A07;color:#901A07;"> </span><span style="display:inline-block;width:20px;background:#9C2E04;color:#9C2E04;"> </span><span style="display:inline-block;width:20px;background:#A84003;color:#A84003;"> </span><span style="display:inline-block;width:20px;background:#B25203;color:#B25203;"> </span><span style="display:inline-block;width:20px;background:#BC6404;color:#BC6404;"> </span><span style="display:inline-block;width:20px;background:#C57606;color:#C57606;"> </span><span style="display:inline-block;width:20px;background:#CE880B;color:#CE880B;"> </span><span style="display:inline-block;width:20px;background:#D59A12;color:#D59A12;"> </span><span style="display:inline-block;width:20px;background:#DCAE19;color:#DCAE19;"> </span><span style="display:inline-block;width:20px;background:#E2C221;color:#E2C221;"> </span><span style="display:inline-block;width:20px;background:#E7D72C;color:#E7D72C;"> </span><span style="display:inline-block;width:20px;background:#EAED3E;color:#EAED3E;"> </span><span style="display:inline-block;width:20px;background:#F8FE69;color:#F8FE69;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.phase</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#A8780D;color:#A8780D;"> </span><span style="display:inline-block;width:20px;background:#BD6827;color:#BD6827;"> </span><span style="display:inline-block;width:20px;background:#CE5642;color:#CE5642;"> </span><span style="display:inline-block;width:20px;background:#DA4065;color:#DA4065;"> </span><span style="display:inline-block;width:20px;background:#DF2A92;color:#DF2A92;"> </span><span style="display:inline-block;width:20px;background:#D528C3;color:#D528C3;"> </span><span style="display:inline-block;width:20px;background:#C040E4;color:#C040E4;"> </span><span style="display:inline-block;width:20px;background:#A25BF3;color:#A25BF3;"> </span><span style="display:inline-block;width:20px;background:#7E71F0;color:#7E71F0;"> </span><span style="display:inline-block;width:20px;background:#5384DD;color:#5384DD;"> </span><span style="display:inline-block;width:20px;background:#2D8FBD;color:#2D8FBD;"> </span><span style="display:inline-block;width:20px;background:#19959D;color:#19959D;"> </span><span style="display:inline-block;width:20px;background:#0C987D;color:#0C987D;"> </span><span style="display:inline-block;width:20px;background:#219A54;color:#219A54;"> </span><span style="display:inline-block;width:20px;background:#5A9422;color:#5A9422;"> </span><span style="display:inline-block;width:20px;background:#88860D;color:#88860D;"> </span><span style="display:inline-block;width:20px;background:#A8780D;color:#A8780D;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.solar</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#331418;color:#331418;"> </span><span style="display:inline-block;width:20px;background:#602124;color:#602124;"> </span><span style="display:inline-block;width:20px;background:#8B3120;color:#8B3120;"> </span><span style="display:inline-block;width:20px;background:#AA5116;color:#AA5116;"> </span><span style="display:inline-block;width:20px;background:#C07613;color:#C07613;"> </span><span style="display:inline-block;width:20px;background:#D0A01F;color:#D0A01F;"> </span><span style="display:inline-block;width:20px;background:#DBCC32;color:#DBCC32;"> </span><span style="display:inline-block;width:20px;background:#E1FD4B;color:#E1FD4B;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.thermal</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 22</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#042333;color:#042333;"> </span><span style="display:inline-block;width:20px;background:#072B4B;color:#072B4B;"> </span><span style="display:inline-block;width:20px;background:#0E3167;color:#0E3167;"> </span><span style="display:inline-block;width:20px;background:#1F3488;color:#1F3488;"> </span><span style="display:inline-block;width:20px;background:#3A339E;color:#3A339E;"> </span><span style="display:inline-block;width:20px;background:#51399D;color:#51399D;"> </span><span style="display:inline-block;width:20px;background:#624198;color:#624198;"> </span><span style="display:inline-block;width:20px;background:#744992;color:#744992;"> </span><span style="display:inline-block;width:20px;background:#84508E;color:#84508E;"> </span><span style="display:inline-block;width:20px;background:#95568A;color:#95568A;"> </span><span style="display:inline-block;width:20px;background:#A65C85;color:#A65C85;"> </span><span style="display:inline-block;width:20px;background:#B9627E;color:#B9627E;"> </span><span style="display:inline-block;width:20px;background:#CB6773;color:#CB6773;"> </span><span style="display:inline-block;width:20px;background:#DB6E66;color:#DB6E66;"> </span><span style="display:inline-block;width:20px;background:#EB7958;color:#EB7958;"> </span><span style="display:inline-block;width:20px;background:#F58649;color:#F58649;"> </span><span style="display:inline-block;width:20px;background:#FA963F;color:#FA963F;"> </span><span style="display:inline-block;width:20px;background:#FCA93C;color:#FCA93C;"> </span><span style="display:inline-block;width:20px;background:#FABD3E;color:#FABD3E;"> </span><span style="display:inline-block;width:20px;background:#F7D145;color:#F7D145;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.turbid</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">7</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#221F1B;color:#221F1B;"> </span><span style="display:inline-block;width:20px;background:#4D392D;color:#4D392D;"> </span><span style="display:inline-block;width:20px;background:#795338;color:#795338;"> </span><span style="display:inline-block;width:20px;background:#A1703B;color:#A1703B;"> </span><span style="display:inline-block;width:20px;background:#BF9747;color:#BF9747;"> </span><span style="display:inline-block;width:20px;background:#D3C56F;color:#D3C56F;"> </span><span style="display:inline-block;width:20px;background:#E9F6AB;color:#E9F6AB;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.balance</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 29</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#181C43;color:#181C43;"> </span><span style="display:inline-block;width:20px;background:#21295F;color:#21295F;"> </span><span style="display:inline-block;width:20px;background:#27347D;color:#27347D;"> </span><span style="display:inline-block;width:20px;background:#28409F;color:#28409F;"> </span><span style="display:inline-block;width:20px;background:#1950BA;color:#1950BA;"> </span><span style="display:inline-block;width:20px;background:#0A65BD;color:#0A65BD;"> </span><span style="display:inline-block;width:20px;background:#1F77BB;color:#1F77BB;"> </span><span style="display:inline-block;width:20px;background:#3787BA;color:#3787BA;"> </span><span style="display:inline-block;width:20px;background:#4F96BA;color:#4F96BA;"> </span><span style="display:inline-block;width:20px;background:#6AA4BC;color:#6AA4BC;"> </span><span style="display:inline-block;width:20px;background:#87B2C1;color:#87B2C1;"> </span><span style="display:inline-block;width:20px;background:#A3BFC9;color:#A3BFC9;"> </span><span style="display:inline-block;width:20px;background:#BECDD3;color:#BECDD3;"> </span><span style="display:inline-block;width:20px;background:#D8DCDE;color:#D8DCDE;"> </span><span style="display:inline-block;width:20px;background:#F0ECEB;color:#F0ECEB;"> </span><span style="display:inline-block;width:20px;background:#E8D7D2;color:#E8D7D2;"> </span><span style="display:inline-block;width:20px;background:#E1C1B8;color:#E1C1B8;"> </span><span style="display:inline-block;width:20px;background:#DAAD9E;color:#DAAD9E;"> </span><span style="display:inline-block;width:20px;background:#D49884;color:#D49884;"> </span><span style="display:inline-block;width:20px;background:#CD8369;color:#CD8369;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.curl</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">17</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#151D44;color:#151D44;"> </span><span style="display:inline-block;width:20px;background:#1B3B55;color:#1B3B55;"> </span><span style="display:inline-block;width:20px;background:#1B5867;color:#1B5867;"> </span><span style="display:inline-block;width:20px;background:#117676;color:#117676;"> </span><span style="display:inline-block;width:20px;background:#2B937F;color:#2B937F;"> </span><span style="display:inline-block;width:20px;background:#69AB89;color:#69AB89;"> </span><span style="display:inline-block;width:20px;background:#A1C1A1;color:#A1C1A1;"> </span><span style="display:inline-block;width:20px;background:#D2D9C6;color:#D2D9C6;"> </span><span style="display:inline-block;width:20px;background:#FDF5F3;color:#FDF5F3;"> </span><span style="display:inline-block;width:20px;background:#EDCEBF;color:#EDCEBF;"> </span><span style="display:inline-block;width:20px;background:#E2A78F;color:#E2A78F;"> </span><span style="display:inline-block;width:20px;background:#D67F6D;color:#D67F6D;"> </span><span style="display:inline-block;width:20px;background:#C35961;color:#C35961;"> </span><span style="display:inline-block;width:20px;background:#A73960;color:#A73960;"> </span><span style="display:inline-block;width:20px;background:#851F60;color:#851F60;"> </span><span style="display:inline-block;width:20px;background:#5C1453;color:#5C1453;"> </span><span style="display:inline-block;width:20px;background:#340D35;color:#340D35;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.delta</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">20 / 96</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#112040;color:#112040;"> </span><span style="display:inline-block;width:20px;background:#142348;color:#142348;"> </span><span style="display:inline-block;width:20px;background:#172650;color:#172650;"> </span><span style="display:inline-block;width:20px;background:#1B2A59;color:#1B2A59;"> </span><span style="display:inline-block;width:20px;background:#1E2D62;color:#1E2D62;"> </span><span style="display:inline-block;width:20px;background:#21316C;color:#21316C;"> </span><span style="display:inline-block;width:20px;background:#243576;color:#243576;"> </span><span style="display:inline-block;width:20px;background:#253781;color:#253781;"> </span><span style="display:inline-block;width:20px;background:#263B8A;color:#263B8A;"> </span><span style="display:inline-block;width:20px;background:#244094;color:#244094;"> </span><span style="display:inline-block;width:20px;background:#214599;color:#214599;"> </span><span style="display:inline-block;width:20px;background:#1E4C9B;color:#1E4C9B;"> </span><span style="display:inline-block;width:20px;background:#1C529D;color:#1C529D;"> </span><span style="display:inline-block;width:20px;background:#1B579D;color:#1B579D;"> </span><span style="display:inline-block;width:20px;background:#1B5D9E;color:#1B5D9E;"> </span><span style="display:inline-block;width:20px;background:#1B629F;color:#1B629F;"> </span><span style="display:inline-block;width:20px;background:#1C67A0;color:#1C67A0;"> </span><span style="display:inline-block;width:20px;background:#1E6DA1;color:#1E6DA1;"> </span><span style="display:inline-block;width:20px;background:#2072A2;color:#2072A2;"> </span><span style="display:inline-block;width:20px;background:#2277A3;color:#2277A3;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.amp</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">11</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#F1EDEC;color:#F1EDEC;"> </span><span style="display:inline-block;width:20px;background:#E5CEC8;color:#E5CEC8;"> </span><span style="display:inline-block;width:20px;background:#DCB1A3;color:#DCB1A3;"> </span><span style="display:inline-block;width:20px;background:#D3947E;color:#D3947E;"> </span><span style="display:inline-block;width:20px;background:#CA775B;color:#CA775B;"> </span><span style="display:inline-block;width:20px;background:#C0583B;color:#C0583B;"> </span><span style="display:inline-block;width:20px;background:#B23726;color:#B23726;"> </span><span style="display:inline-block;width:20px;background:#9D1926;color:#9D1926;"> </span><span style="display:inline-block;width:20px;background:#7F0E29;color:#7F0E29;"> </span><span style="display:inline-block;width:20px;background:#5C0E21;color:#5C0E21;"> </span><span style="display:inline-block;width:20px;background:#3C0912;color:#3C0912;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.speed</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">9</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFFDCD;color:#FFFDCD;"> </span><span style="display:inline-block;width:20px;background:#E9D889;color:#E9D889;"> </span><span style="display:inline-block;width:20px;background:#C9BA45;color:#C9BA45;"> </span><span style="display:inline-block;width:20px;background:#98A512;color:#98A512;"> </span><span style="display:inline-block;width:20px;background:#60920B;color:#60920B;"> </span><span style="display:inline-block;width:20px;background:#277B23;color:#277B23;"> </span><span style="display:inline-block;width:20px;background:#0B5F2D;color:#0B5F2D;"> </span><span style="display:inline-block;width:20px;background:#174026;color:#174026;"> </span><span style="display:inline-block;width:20px;background:#172313;color:#172313;"> </span></span></td></tr>
#>     <tr><td headers="palette" class="gt_row gt_left">pals_ocean.tempo</td>
#> <td headers="type" class="gt_row gt_left">continuous</td>
#> <td headers="n_colors" class="gt_row gt_right">8</td>
#> <td headers="preview" class="gt_row gt_left"><span class='gt_from_md'><span style="display:inline-block;width:20px;background:#FFF6F4;color:#FFF6F4;"> </span><span style="display:inline-block;width:20px;background:#CBD5C0;color:#CBD5C0;"> </span><span style="display:inline-block;width:20px;background:#92BB99;color:#92BB99;"> </span><span style="display:inline-block;width:20px;background:#4FA183;color:#4FA183;"> </span><span style="display:inline-block;width:20px;background:#13847B;color:#13847B;"> </span><span style="display:inline-block;width:20px;background:#19616C;color:#19616C;"> </span><span style="display:inline-block;width:20px;background:#1C4058;color:#1C4058;"> </span><span style="display:inline-block;width:20px;background:#151D44;color:#151D44;"> </span></span></td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
```
