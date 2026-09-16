# Enhanced Table Display with Pattern Highlighting

Render one or more data objects (data.frame, gt, gtsummary) as styled
`gt` tables.

## Usage

``` r
.cat_tb(
  ...,
  highlight_pattern = NULL,
  highlight_color = "lightcoral",
  numeric_columns = NULL,
  numeric_color = c("white", "blue"),
  theme = c("excel", "gt", "none"),
  titles = NULL,
  subtitles = NULL,
  captions = NULL,
  footnotes = NULL
)
```

## Arguments

  - ...:
    
    Data objects to render (data.frame, gt, or gtsummary). A single
    unnamed list is also accepted.

  - highlight\_pattern:
    
    Regex pattern. Matching cells get `highlight_color` fill.

  - highlight\_color:
    
    Fill colour for highlighted cells (default `"lightcoral"`).

  - numeric\_columns:
    
    Character vector of column names to apply colour mapping. If `NULL`,
    numeric columns are formatted (2 decimals) but *not* colour-mapped.

  - numeric\_color:
    
    Length-2 colour palette for colour mapping (low, high). Default
    `c("white", "blue")`.

  - theme:
    
    One of `"excel"`, `"gt"`, `"none"`.

  - titles, subtitles, captions, footnotes:
    
    Character vectors aligned with the data objects.

## Value

A `gt` table or `gt_group` object (invisible when printed by RStudio
viewer).

## See also

Other console display: `.cat_box()`, `.cat_formula()`, `.cat_line()`,
`.cat_message()`

## Examples

``` r
table_data <- data.frame(
  group = c("A", "B"),
  value = c(1.25, 2.50)
)
.cat_tb(table_data, theme = "none")


  

group
```

value

A

1.25

B

2.50
