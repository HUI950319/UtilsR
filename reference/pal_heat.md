# Diverging Heatmap Fill Palettes

Eleven five-colour diverging gradients for correlation-style heatmaps,
each running from the most negative value through white to the most
positive. They are the fill combinations of a published correlation
heatmap figure; `blue_red` is ColorBrewer `RdBu` (7 classes, reversed)
with a pure white midpoint in place of its grey one, and the others come
from the Material Design, Tailwind and Flat UI colour systems.

## Usage

``` r
pal_heat
```

## Format

A named list of 11 character vectors, 5 hex colours each, named by the
two hues each gradient runs between:

  - blue\_red:
    
    blue to red (ColorBrewer RdBu)

  - teal\_pink:
    
    deep teal to magenta

  - slate\_red:
    
    midnight slate to dark red (Flat UI)

  - purple\_gold:
    
    deep purple to bronze

  - steel\_rose:
    
    steel blue to wine

  - navy\_scarlet:
    
    navy to scarlet

  - green\_orange:
    
    forest green to burnt orange

  - purple\_teal:
    
    purple to teal (Material Design)

  - olive\_violet:
    
    olive to indigo

  - slate\_crimson:
    
    slate to crimson (Tailwind)

  - indigo\_gold:
    
    indigo to gold

## Details

Unlike the categorical palettes here, these are meant to be
interpolated: pass one to `ggplot2::scale_fill_gradientn()` or
`grDevices::colorRampPalette()` rather than mapping the five colours to
five levels.

## See also

Other colour palettes: `pal_bar`, `pal_get()`, `pal_lancet`,
`pal_list()`, `pal_other`, `pal_paraSC`, `pal_show()`,
`pal_show_brewer()`, `pal_show_ggsci()`, `pal_show_hcl()`,
`pal_show_viridis()`

## Examples

``` r
names(pal_heat)
#>  [1] "blue_red"      "teal_pink"     "slate_red"     "purple_gold"  
#>  [5] "steel_rose"    "navy_scarlet"  "green_orange"  "purple_teal"  
#>  [9] "olive_violet"  "slate_crimson" "indigo_gold"  
pal_heat$blue_red
#> [1] "#2166ac" "#67a9cf" "#ffffff" "#ef8a62" "#b2182b"
show_color(pal_heat$purple_teal)
#>  #4A148C   #8E25AA   #FFFFFF   #27A69A   #004C3F  
#> c("#4a148c", "#8e25aa", "#ffffff", "#27a69a", "#004c3f")

# interpolated over a continuous fill scale
ggplot2::scale_fill_gradientn(colours = pal_heat$slate_crimson,
                              limits = c(-1, 1))
#> <ScaleContinuous>
#>  Range:  
#>  Limits:   -1 --    1
```
