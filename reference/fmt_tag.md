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

- label_position:

  Placement of the label. Accepts either:

  - Numeric length-2 vector \`c(x, y)\` in NPC — drawn inside the panel
    (default \`c(0.02, 0.98)\` = top-left inside).

  - Keyword for inside corners: \`"tl"\`, \`"tr"\`, \`"bl"\`, \`"br"\`.

  - Keyword for outside corners (a boxed label at the corner of the
    whole plot, in the margin region outside the panel, drawn as a
    full-plot \[patchwork::inset_element()\]): \`"tl-out"\`,
    \`"tr-out"\`, \`"bl-out"\`, \`"br-out"\`. Underscore variants
    (\`"tl_out"\` etc.) are also accepted.

  Both placements draw the same box, styled by \`label.size\`,
  \`label.padding\` and \`label.r\`; \`...\` only applies to inside
  placements.

- size:

  Numeric label size in points. Default 18.

- color:

  Label text color. Default \`"black"\`.

- fontface:

  Font face for labels. Default \`"bold"\`.

- label.size:

  Border line width of the label box in mm. Default 1.

- label.padding:

  Padding around the label text, a \[grid::unit()\] vector. Default
  \`unit(c(0.2, 0.3, 0.2, 0.3), "lines")\` (top, right, bottom, left).

- label.r:

  Corner radius of the label box, a \[grid::unit()\] value. Default
  \`unit(0.2, "lines")\`.

- ...:

  Additional arguments passed to \[ggpp::annotate()\] for inside
  placements (ignored when an \`-out\` keyword is used).

## Value

Same type as input. With an \`-out\` keyword each ggplot carries the
label as a patchwork inset, so a single ggplot comes back as a
(single-plot) patchwork.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()

# Auto-label A, B (inside panel, top-left)
fmt_tag(list(p1, p2))
#> Registered S3 methods overwritten by 'ggpp':
#>   method                  from   
#>   heightDetails.titleGrob ggplot2
#>   widthDetails.titleGrob  ggplot2
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
