# Display Colour Swatches in Console

Print colour hex codes as ANSI-coloured swatches with auto-contrasting
foreground text. Works in any terminal that supports ANSI true-colour
(24-bit) escape sequences.

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

## Examples

``` r
show_color(c("#FF0000", "#00FF00", "#0000FF"))
#>  #FF0000   #00FF00   #0000FF  
show_color(rainbow(10))
#>  #FF0000   #FF9900   #CCFF00   #33FF00   #00FF66   #00FFFF   #0066FF   #3300FF   #CC00FF   #FF0099  
show_color(c("steelblue", "tomato", "gold"), rev = TRUE)
#>  #FFD700   #FF6347   #4682B4  
```
