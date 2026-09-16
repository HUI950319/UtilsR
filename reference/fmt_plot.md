# Master plot formatting function

Convenience wrapper that chains \[fmt\_axis()\], \[fmt\_tag()\],
\[fmt\_legend()\], and \[fmt\_ref()\] in sequence. Each sub-formatter is
applied only when its corresponding \`\*\_list\` argument is non-NULL.

## Usage

``` r
fmt_plot(
  plot,
  fmt_axis_list = NULL,
  fmt_tag_list = NULL,
  fmt_legend_list = NULL,
  fmt_ref_list = NULL,
  plot.margin = NULL,
  tag_levels = NULL,
  axis_titles = NULL,
  ...
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplot objects.

  - fmt\_axis\_list:
    
    Named list of arguments for \[fmt\_axis()\]. Set to \`NULL\`
    (default) to skip.

  - fmt\_tag\_list:
    
    Named list of arguments for \[fmt\_tag()\]. Set to \`NULL\` to skip.

  - fmt\_legend\_list:
    
    Named list of arguments for \[fmt\_legend()\]. Set to \`NULL\` to
    skip.

  - fmt\_ref\_list:
    
    Named list of arguments for \[fmt\_ref()\]. Set to \`NULL\` to skip.

  - plot.margin:
    
    Numeric vector of length 1 or 4, or a \[ggplot2::margin()\] object.
    Applied to all plots via \`&\`.

  - tag\_levels:
    
    Character string for patchwork tag levels (e.g. \`"A"\`, \`"a"\`,
    \`"1"\`). Only used when input is a patchwork object.

  - axis\_titles:
    
    Passed to \[patchwork::plot\_layout()\] \`axis\_titles\` argument.
    Only used when input is a patchwork object.

  - ...:
    
    Currently unused.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot_base()`, `fmt_point()`,
`fmt_raster()`, `fmt_ref()`, `fmt_scale()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()
p2 <- ggplot(iris, aes(Petal.Length, Petal.Width, color = Species)) + geom_point()

# Single plot with reference line and legend
fmt_plot(p1, ref_x = 5.5, legend.position = "bottom")


# Multi-plot with tags and merged legend
fmt_plot(list(p1, p2), tag = TRUE, collect = TRUE)
#> [[1]]

#> 
#> [[2]]

#> 
```
