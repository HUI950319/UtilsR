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

Other colour palettes:
[`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)

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
```
