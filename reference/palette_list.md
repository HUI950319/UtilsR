# Built-in Palette Collection

A named list of 256 colour palettes from RColorBrewer, ggsci, viridis,
rcartocolor, nord, dichromat, pals, colorspace, and UtilsR built-in.
Each element is a character vector of hex colours with a `"type"`
attribute (`"discrete"` or `"continuous"`).

## Format

A named list of 256 character vectors.

## Examples

``` r
length(palette_list)
#> [1] 259
names(palette_list)[1:10]
#>  [1] "BrBG"     "PiYG"     "PRGn"     "PuOr"     "RdBu"     "RdGy"    
#>  [7] "RdYlBu"   "RdYlGn"   "Spectral" "Accent"  
```
