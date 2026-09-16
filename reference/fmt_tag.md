# Add panel labels to plots

Add text labels (e.g. A, B, C) to the corner of each plot panel using
\[ggpp::annotate()\] with NPC coordinates.

## Usage

``` r
fmt_tag(
  plot,
  labels = NULL,
  label_position = c(0.02, 0.98),
  size = 18,
  color = "black",
  fontface = "bold",
  label.size = 1,
  label.padding = grid::unit(c(0.2, 0.3, 0.2, 0.3), "lines"),
  label.r = grid::unit(0.2, "lines"),
  ...
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplot objects.

  - labels:
    
    Character vector of labels. If \`NULL\` (default), uses
    \`LETTERS\[1:n\]\`.

  - label\_position:
    
    Placement of the label. Accepts either:
    
      - Numeric length-2 vector \`c(x, y)\` in NPC — drawn inside the
        panel (default \`c(0.02, 0.98)\` = top-left inside).
    
      - Keyword for inside corners: \`"tl"\`, \`"tr"\`, \`"bl"\`,
        \`"br"\`.
    
      - Keyword for outside corners (rendered in the plot's margin
        region outside the panel via the ggplot2 tag mechanism):
        \`"tl-out"\`, \`"tr-out"\`, \`"bl-out"\`, \`"br-out"\`.
        Underscore variants (\`"tl\_out"\` etc.) are also accepted.
    
    When an \`-out\` keyword is used, \`label.size\` / \`label.padding\`
    / \`label.r\` are ignored (the outside label is plain text without a
    box).

  - size:
    
    Numeric label size in points. Default 18.

  - color:
    
    Label text color. Default \`"black"\`.

  - fontface:
    
    Font face for labels. Default \`"bold"\`.

  - label.size:
    
    Border line width of the label box in mm. Default 1. Only used for
    inside placements.

  - label.padding:
    
    Padding around the label text, a \[grid::unit()\] vector. Default
    \`unit(c(0.2, 0.3, 0.2, 0.3), "lines")\` (top, right, bottom, left).
    Only used for inside placements.

  - label.r:
    
    Corner radius of the label box, a \[grid::unit()\] value. Default
    \`unit(0.2, "lines")\`. Only used for inside placements.

  - ...:
    
    Additional arguments passed to \[ggpp::annotate()\] for inside
    placements (ignored when an \`-out\` keyword is used).

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()

# Auto-label A, B (inside panel, top-left)
fmt_tag(list(p1, p2))
#> [[1]]

#> 
#> [[2]]

#> 

# Custom labels
fmt_tag(list(p1, p2), labels = c("i", "ii"))
#> [[1]]

#> 
#> [[2]]

#> 

# Inside, top-right corner via keyword
fmt_tag(list(p1, p2), label_position = "tr")
#> [[1]]

#> 
#> [[2]]

#> 

# Outside the panel, top-left corner of the entire plot
fmt_tag(list(p1, p2), label_position = "tl-out")
#> [[1]]

#> 
#> [[2]]

#> 
```
