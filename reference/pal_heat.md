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

- blue_red:

  blue to red (ColorBrewer RdBu)

- teal_pink:

  deep teal to magenta

- slate_red:

  midnight slate to dark red (Flat UI)

- purple_gold:

  deep purple to bronze

- steel_rose:

  steel blue to wine

- navy_scarlet:

  navy to scarlet

- green_orange:

  forest green to burnt orange

- purple_teal:

  purple to teal (Material Design)

- olive_violet:

  olive to indigo

- slate_crimson:

  slate to crimson (Tailwind)

- indigo_gold:

  indigo to gold

## Details

Unlike the categorical palettes here, these are meant to be
interpolated: pass one to
[`ggplot2::scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
or
[`grDevices::colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html)
rather than mapping the five colours to five levels.

## See also

Other colour palettes:
[`pal_bar`](https://hui950319.github.io/UtilsR/reference/pal_bar.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md),
[`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md),
[`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md),
[`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md),
[`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)

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
