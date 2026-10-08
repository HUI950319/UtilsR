# Add panel labels to plots

Add boxed labels to data plots using \[ggpp::geom_label_npc()\] inside
panels or \[patchwork::inset_element()\] at the corners of whole plots.
Nested plots are labelled in leaf order; spacers, guide areas and insets
are skipped. Fixed graphics created by \[patchwork::wrap_elements()\]
are skipped with a warning, without consuming labels.

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

  A ggplot, patchwork, or list of these objects.

- labels:

  Non-empty character vector without missing or blank labels. If
  \`NULL\` (default), uses A through Z, then AA, AB and so on. Short
  vectors are recycled with a warning; excess labels are ignored.

- label_position:

  Placement of the label. Accepts either:

  - Finite numeric length-2 vector \`c(x, y)\` in NPC, both values in
    \`\[0, 1\]\` — drawn inside the panel (default \`c(0.02, 0.98)\`).

  - Keyword for inside corners: \`"tl"\`, \`"tr"\`, \`"bl"\`, \`"br"\`.

  - Keyword for outside corners (a boxed label at the corner of the
    whole plot, drawn as a full-plot \[patchwork::inset_element()\]):
    \`"tl-out"\`, \`"tr-out"\`, \`"bl-out"\`, \`"br-out"\`. Underscore
    variants (\`"tl_out"\` etc.) are also accepted.

  Both placements use a box styled by \`label.size\`, \`label.padding\`
  and \`label.r\`; \`...\` only applies to inside placements. Inside
  positions refer to the displayed panel, including flipped and
  non-linear coordinates. Invalid positions raise an error.

- size:

  Positive finite numeric label sizes in points, recycled over data
  plots. Default 18.

- color:

  R colour specifications for text and borders, recycled over data
  plots. Numeric palette colours and \`NA\` are accepted. Default
  \`"black"\`.

- fontface:

  One font face: \`"plain"\`, \`"bold"\`, \`"italic"\`,
  \`"bold.italic"\`, \`"symbol"\`, or the corresponding number from 1
  to 5. Default \`"bold"\`.

- label.size:

  One finite non-negative border width in mm. Zero removes the border.
  Default 1.

- label.padding:

  Padding around the label text, a \[grid::unit()\] vector with finite
  non-negative values and length 1, 2 or 4. Values are recycled to top,
  right, bottom, left; two values set top/bottom and right/left
  respectively. Asymmetric padding is honoured in both modes. Default
  \`unit(c(0.2, 0.3, 0.2, 0.3), "lines")\`.

- label.r:

  One finite non-negative \[grid::unit()\] corner radius. Default
  \`unit(0.2, "lines")\`.

- ...:

  Additional inside-label arguments passed to
  \[ggpp::geom_label_npc()\], such as \`fill\`, \`alpha\`, \`family\` or
  \`parse\`. Ignored when an \`-out\` keyword is used.

## Value

Same type as input. With an \`-out\` keyword each ggplot carries the
label as a patchwork inset, so a single ggplot comes back as a
(single-plot) patchwork. Replacing an outside tag with an inside tag
removes a container created solely for the old tag.

## Details

Repeated calls replace only labels created by \`fmt_tag()\`, preserving
user annotations and insets. Inside labels repeat the same plot label in
each native facet; outside labels appear once per data plot. Containers
without data plots are returned unchanged without validating styling.
Axis, legend, reference-line and strip formatters operate on the data
plots without counting outside-label insets. Compound padding and radius
units are checked in both dimensions at the label font sizes on a 7 by 7
inch reference viewport. Simple units retain their usual relative
semantics without opening a device.

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
[`fmt_point`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
library(patchwork)
d <- data.frame(x = 1:5, y = c(2, 4, 3, 5, 6), z = c(5, 3, 4, 2, 1))
p1 <- ggplot(d, aes(x, y)) + geom_point()
p2 <- ggplot(d, aes(x, z)) + geom_point()

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

# Label nested data plots while skipping the spacer
nested <- (p1 | plot_spacer()) / (p2 | p1)
fmt_tag(nested)


# Replace an outside tag with an inside tag
outside <- fmt_tag(p1, "A", label_position = "tl-out",
                   label.padding = grid::unit(0.3, "lines"))
fmt_tag(outside, "B", label_position = "br")

```
