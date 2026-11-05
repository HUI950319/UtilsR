# Display Colour Swatches in Console

Print colour hex codes as ANSI-coloured swatches with auto-contrasting
foreground text. Works in any terminal that supports ANSI true-colour
(24-bit) escape sequences. The displayed colour vector is also printed
with [`dput()`](https://rdrr.io/r/base/dput.html) so it can be copied
back into R for assignment. Swatches wrap to the console width without
truncating the colour vector. Decorative padding is reduced in narrow
consoles. Labels wider than the console remain intact on their own line.
Translucent swatches are composited onto white because ANSI backgrounds
cannot carry alpha. Their printed hex codes retain the original alpha.

## Usage

``` r
show_color(x, rev = FALSE)
```

## Arguments

- x:

  Character vector without a class or dimensions, containing hex codes
  or named R colours. Numeric palette indices are not accepted.

- rev:

  Single non-missing logical value without a class or dimensions.
  Reverse colours and their names before display, retaining other
  attributes (default `FALSE`).

## Value

Invisibly returns `x`.

## Details

Swatches follow whatever colour depth the terminal reports through
[`cli::num_ansi_colors()`](https://cli.r-lib.org/reference/num_ansi_colors.html).
A terminal limited to 256 colours draws the nearest palette entry
instead of the exact hex, so a swatch can differ from the code printed
beside it. `options(cli.num_colors = 16777216)` forces 24-bit output in
a terminal that renders it without advertising it. Colour depth is
detected for stdout, including when stderr is redirected. Versions of
cli before 3.1.0 support at most 256 colours, including when 24-bit
output is requested. On indexed terminals, text contrast uses the
emitted ANSI colours and the standard xterm palette. Custom terminal
colour themes can change the result.

Missing character values (`NA_character_`) and the literal colour `"NA"`
follow R's transparent-colour convention, so their swatches have the
same `#FFFFFF00` label as `"transparent"`. Their original values, names
and attributes are retained in the returned vector. The copyable
expression uses 17-digit precision for numeric attributes.
[`dput()`](https://rdrr.io/r/base/dput.html) cannot reconstruct every
object exactly, including environment attributes and names marked with
the `"bytes"` encoding. Use
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) on the returned
vector when exact object preservation is required. An empty character
vector is also accepted.

## Examples

``` r
show_color(c("#FF0000", "#00FF00", "#0000FF"))
#>  #FF0000   #00FF00   #0000FF 
#> c("#FF0000", "#00FF00", "#0000FF")
show_color(rainbow(10))
#>  #FF0000   #FF9900   #CCFF00   #33FF00   #00FF66   #00FFFF   #0066FF   #3300FF 
#>  #CC00FF   #FF0099 
#> c("#FF0000", "#FF9900", "#CCFF00", "#33FF00", "#00FF66", "#00FFFF", 
#> "#0066FF", "#3300FF", "#CC00FF", "#FF0099")
show_color(c("steelblue", "tomato", "gold"), rev = TRUE)
#>  #FFD700   #FF6347   #4682B4 
#> c("gold", "tomato", "steelblue")
```
