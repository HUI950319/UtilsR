# Parathyroid Single-Cell Colour Palette

A 16-colour named palette for parathyroid single-cell atlas cell types,
including immune, stromal, and endothelial lineages.

## Usage

``` r
pal_paraSC
```

## Format

A named character vector of 16 hex colour codes.

## See also

Other colour palettes: `pal_bar`, `pal_get()`, `pal_heat`, `pal_lancet`,
`pal_list()`, `pal_other`, `pal_show()`, `pal_show_brewer()`,
`pal_show_ggsci()`, `pal_show_hcl()`, `pal_show_viridis()`

## Examples

``` r
pal_paraSC
#>      Parathyroid cells                T cells        Cycling T cells 
#>              "#8B1A1A"            "#56B4E9FF"              "#8B5E3C" 
#>               NK cells                B cells              Monocytes 
#>              "#2E8B45"              "#1A7B7B"              "#7B68AA" 
#>    M1-like Macrophages M2/M3-like Macrophages            Neutrophils 
#>              "#D4919A"              "#F0C8A0"              "#C0C0C0" 
#>                  cDC2s             Mast cells                  iTAFs 
#>              "#282828"            "#F0E442FF"              "#9AB83C" 
#>                  mTAFs              Pericytes          Capillary ECs 
#>              "#E07B1A"              "#6B3FA0"              "#D4C8E8" 
#>             Venous ECs 
#>              "#8AAAC8" 
show_color(pal_paraSC)
#>  #8B1A1A   #56B4E9   #8B5E3C   #2E8B45   #1A7B7B   #7B68AA   #D4919A   #F0C8A0   #C0C0C0   #282828   #F0E442   #9AB83C   #E07B1A   #6B3FA0   #D4C8E8   #8AAAC8  
#> c(`Parathyroid cells` = "#8B1A1A", `T cells` = "#56B4E9FF", `Cycling T cells` = "#8B5E3C", 
#> `NK cells` = "#2E8B45", `B cells` = "#1A7B7B", Monocytes = "#7B68AA", 
#> `M1-like Macrophages` = "#D4919A", `M2/M3-like Macrophages` = "#F0C8A0", 
#> Neutrophils = "#C0C0C0", cDC2s = "#282828", `Mast cells` = "#F0E442FF", 
#> iTAFs = "#9AB83C", mTAFs = "#E07B1A", Pericytes = "#6B3FA0", 
#> `Capillary ECs` = "#D4C8E8", `Venous ECs` = "#8AAAC8")
```
