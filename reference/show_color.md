# Display Colour Swatches in Console

Print colour hex codes as ANSI-coloured swatches with auto-contrasting
foreground text. Works in any terminal that supports ANSI true-colour
(24-bit) escape sequences. The displayed colour vector is also printed
with `dput()` so it can be copied back into R for assignment.

## Usage

``` r
show_color(x, rev = FALSE)
```

## Arguments

  - x:
    
    Character vector of colours (hex codes or named R colours).

  - rev:
    
    Logical. Reverse the order before display (default `FALSE`).

## Value

Invisibly returns `x`.

## Details

Swatches follow whatever colour depth the terminal reports through
`cli::num_ansi_colors()`. A terminal limited to 256 colours draws the
nearest palette entry instead of the exact hex, so a swatch can differ
from the code printed beside it. `options(cli.num_colors = 16777216)`
forces 24-bit output in a terminal that renders it without advertising
it.

## Examples

``` r
show_color(c("#FF0000", "#00FF00", "#0000FF"))
#>  #FF0000   #00FF00   #0000FF  
#> c("#FF0000", "#00FF00", "#0000FF")
show_color(rainbow(10))
#>  #FF0000   #FF9900   #CCFF00   #33FF00   #00FF66   #00FFFF   #0066FF   #3300FF   #CC00FF   #FF0099  
#> c("#FF0000", "#FF9900", "#CCFF00", "#33FF00", "#00FF66", "#00FFFF", 
#> "#0066FF", "#3300FF", "#CC00FF", "#FF0099")
show_color(c("steelblue", "tomato", "gold"), rev = TRUE)
#>  #FFD700   #FF6347   #4682B4  
#> c("gold", "tomato", "steelblue")
```
