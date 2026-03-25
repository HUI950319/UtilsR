# Additional Built-in Colour Palettes

A named list of 10 discrete colour palettes suitable for single-cell
cluster visualisation. Access individual palettes via `pal_other$igv`,
`pal_other$ditto`, etc.

## Usage

``` r
pal_other
```

## Format

A named list of `palette` objects:

- igv:

  48 colours, IGV genome browser

- ditto:

  40 colours, dittoSeq (scRNA-seq)

- polychrome:

  36 colours, max perceptual distinctness

- glasbey:

  32 colours, Glasbey algorithm

- alphabet:

  26 colours, Green-Armytage A-Z

- ucsc:

  26 colours, UCSC genome browser

- kelly:

  22 colours, Kelly max contrast

- d3:

  20 colours, D3.js Category20

- simpsons:

  16 colours, ggsci Simpsons

- trubetskoy:

  20 colours, Trubetskoy distinct

## See also

Other colour palettes:
[`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)

## Examples

``` r
names(pal_other)
#>  [1] "igv"        "ditto"      "polychrome" "glasbey"    "alphabet"  
#>  [6] "ucsc"       "kelly"      "d3"         "simpsons"   "trubetskoy"
pal_other$ditto
#>  [1] "#E69F00" "#56B4E9" "#009E73" "#F0E442" "#0072B2" "#D55E00" "#CC79A7"
#>  [8] "#666666" "#AD7700" "#1C91D4" "#007756" "#D5C711" "#005685" "#A04700"
#> [15] "#B14380" "#4D4D4D" "#FFBE2D" "#80C7EF" "#00F6B3" "#F4EB71" "#06A5FF"
#> [22] "#FF8320" "#D99BBD" "#8C8C8C" "#FFCB57" "#9AD2F2" "#2CFFC6" "#F6EF8E"
#> [29] "#38B7FF" "#FF9B4D" "#E0AFCA" "#A3A3A3" "#8A5F00" "#1674A9" "#005F45"
#> [36] "#AA9F0D" "#00446B" "#803800" "#8D3666" "#3D3D3D"
pal_other$igv[1:10]
#>  [1] "#5050FF" "#CE3D32" "#749B58" "#F0E685" "#466983" "#BA6338" "#5DB1DD"
#>  [8] "#802268" "#6BD76B" "#D595A7"
show_color(pal_other$polychrome)
#>  #5A5156   #E4E1E3   #F6222E   #FE00FA   #16FF32   #3283FE   #FEAF16   #B00068   #1CFFCE   #90AD1C   #2ED9FF   #DEA0FD   #AA0DFE   #F8A19F   #325A9B   #C4451C   #1C8356   #85660D   #B10DA1   #FBE426   #1CBE4F   #FA0087   #FC1CBF   #F7E1A0   #C075A6   #782AB6   #AAF400   #BDCDFF   #822E1C   #B5EFB5   #7ED7D1   #1C7F93   #D85FF7   #683B79   #66B0FF   #3B00FB  
```
