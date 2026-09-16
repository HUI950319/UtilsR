# Customizable Legend Theme

A flexible legend theme with sensible defaults. All parameters can be
overridden. \[theme\_legend1()\] is a convenience wrapper with fixed
compact styling; use `theme_legend()` when you need fine-grained
control.

## Usage

``` r
theme_legend(
  bg_fill = "white",
  bg_color = "grey",
  bg_linewidth = 0.8,
  key_fill = "white",
  key_color = NA,
  key_linewidth = 0.5,
  key_size = 1,
  text_size = 9,
  text_color = "black",
  text_face = "plain",
  title_size = 10,
  title_color = "black",
  title_face = "bold",
  show_title = TRUE,
  spacing = 0.2,
  margin = c(4, 4, 4, 4)
)
```

## Arguments

  - bg\_fill:
    
    Background fill color. Default `"white"`.

  - bg\_color:
    
    Background border color. Default `"grey"`.

  - bg\_linewidth:
    
    Background border width. Default `0.8`.

  - key\_fill:
    
    Key background fill. Default `"white"`.

  - key\_color:
    
    Key border color. Default `NA` (no border).

  - key\_linewidth:
    
    Key border width. Default `0.5`.

  - key\_size:
    
    Key size in lines. Default `1`.

  - text\_size:
    
    Legend text size. Default `9`.

  - text\_color:
    
    Legend text color. Default `"black"`.

  - text\_face:
    
    Legend text font face. Default `"plain"`.

  - title\_size:
    
    Legend title size. Default `10`.

  - title\_color:
    
    Legend title color. Default `"black"`.

  - title\_face:
    
    Legend title font face. Default `"bold"`.

  - show\_title:
    
    Logical. Show legend title? Default `TRUE`. If `FALSE`, title is set
    to `element_blank()`.

  - spacing:
    
    Spacing between legend and plot in cm. Default `0.2`.

  - margin:
    
    Margin around legend content (top, right, bottom, left) in pt.
    Default `c(4, 4, 4, 4)`.

## Value

A ggplot2 theme object.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_heat()`, `theme_km`,
`theme_legend1()`, `theme_my()`, `theme_rcs`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point()

# Default
p + theme_legend()


# No border, larger text
p + theme_legend(bg_color = NA, text_size = 11, title_size = 13)


# No title, no background border
p + theme_legend(show_title = FALSE, bg_color = NA)


# Transparent background
p + theme_legend(bg_fill = "transparent", bg_color = NA)

```
