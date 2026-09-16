# Visualise ggsci Palettes

Display the palettes provided by `ggsci` using the same ggplot or gt
layout as `pal_show()`.

## Usage

``` r
pal_show_ggsci(
  palette = NULL,
  n = NULL,
  alpha = 1,
  reverse = FALSE,
  pattern = NULL,
  index = NULL,
  max_colors = 20,
  output = c("gt", "gg", "console")
)
```

## Arguments

  - palette:
    
    Character vector of palette names. Names use the form
    `"ggsci_npg_nrc"`; the `ggsci_` prefix may be omitted. `NULL` shows
    all palettes.

  - n:
    
    Number of colours to retain from each palette. `NULL` uses each
    palette's native number of colours.

  - alpha:
    
    Opacity of the colours, a number between 0 and 1.

  - reverse:
    
    Logical; if `TRUE`, reverse the colour order.

  - pattern:
    
    Regex pattern used to filter palette names.

  - index:
    
    Integer vector of palette indices to display after filtering.

  - max\_colors:
    
    Maximum colours to display per palette. Default 20.

  - output:
    
    Output format: `"gt"` (default) for a gt table, `"gg"` for a ggplot,
    or `"console"` for terminal output.

## Value

A ggplot or gt object (also prints).

## See also

Other colour palettes: `pal_bar`, `pal_get()`, `pal_heat`, `pal_lancet`,
`pal_list()`, `pal_other`, `pal_paraSC`, `pal_show()`,
`pal_show_brewer()`, `pal_show_hcl()`, `pal_show_viridis()`

## Examples

``` r
if (requireNamespace("ggsci", quietly = TRUE)) {
  pal_show_ggsci(c("ggsci_npg_nrc", "ggsci_aaas_default"),
                 n = 5, output = "gg")
}

```
