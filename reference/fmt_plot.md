# Master plot formatting function

Convenience wrapper that chains \[fmt_axis()\], \[fmt_tag()\],
\[fmt_legend()\], and \[fmt_ref()\] in sequence. Each sub-formatter is
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

- fmt_axis_list:

  Named list of arguments for \[fmt_axis()\]. Set to \`NULL\` (default)
  to skip.

- fmt_tag_list:

  Named list of arguments for \[fmt_tag()\]. Set to \`NULL\` to skip.

- fmt_legend_list:

  Named list of arguments for \[fmt_legend()\]. Set to \`NULL\` to skip.

- fmt_ref_list:

  Named list of arguments for \[fmt_ref()\]. Set to \`NULL\` to skip.

- plot.margin:

  Numeric vector of length 1 or 4, or a \[ggplot2::margin()\] object.
  Applied to all plots via \`&\`.

- tag_levels:

  Character string for patchwork tag levels (e.g. \`"A"\`, \`"a"\`,
  \`"1"\`). Only used when input is a patchwork object. Ignored with a
  warning when \`fmt_tag_list\` supplies explicit labels.

- axis_titles:

  Passed to \[patchwork::plot_layout()\] \`axis_titles\` argument. Only
  used when input is a patchwork object.

- ...:

  Currently unused.

## Value

Same type as input.

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
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
library(patchwork)
d <- data.frame(x = 1:6, y = c(2, 4, 3, 5, 6, 4),
                group = rep(c("a", "b"), each = 3))
p1 <- ggplot(d, aes(x, y, colour = group)) + geom_point()
p2 <- ggplot(d, aes(y, x, colour = group)) + geom_point()

# Single plot with reference line and legend
single <- fmt_plot(p1, fmt_ref_list = list(x = 3),
                   fmt_legend_list = list(legend.position = "bottom"))
single


# Multi-plot with tags and merged legend
combined <- fmt_plot(p1 | p2, fmt_tag_list = list(),
                     fmt_legend_list = list(collect = TRUE))
#> Registered S3 methods overwritten by 'ggpp':
#>   method                  from   
#>   heightDetails.titleGrob ggplot2
#>   widthDetails.titleGrob  ggplot2
combined

```
