# Add pairwise statistical comparisons

Uses `ggpubr::geom_pwc` to overlay significance brackets.

## Usage

``` r
fmt_com(
  plot,
  com_method = "con",
  label.y = NULL,
  label.y.prop = NULL,
  label = c("p.signif", "{p.format}{p.signif}", "p.format"),
  tip.length = 0.025,
  step.increase = 0.05,
  size = 0.8,
  ...
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplots.

  - com\_method:
    
    Comparison method: `"con"` (consecutive), `"all"` (all pairs), or a
    list of length-2 character vectors.

  - label.y:
    
    Numeric y-position for the first bracket (absolute y-axis value).
    Default `NULL` lets ggpubr auto-calculate.

  - label.y.prop:
    
    Numeric proportion (0-1) of the y-axis data range for the first
    bracket position. E.g., `0.9` = 90% of data range. Ignored when
    `label.y` is provided. Default `NULL`.

  - label:
    
    Label type: `"p.signif"`, `"\{p.format\}\{p.signif\}"`, or
    `"p.format"`.

  - tip.length:
    
    Length of the bracket tips. Default `0.025`.

  - step.increase:
    
    Vertical step increase between brackets. Default `0.05`.

  - size:
    
    Line width of the brackets. Default `0.8`.

  - ...:
    
    Additional arguments passed to `ggpubr::geom_pwc`.

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()

# Consecutive comparisons (default)
fmt_com(p)


# All pairwise comparisons
fmt_com(p, com_method = "all")


# Custom comparisons
fmt_com(p, com_method = list(c("setosa", "virginica"), c("setosa", "versicolor")))


# Show p-value instead of stars
fmt_com(p, label = "p.format")


# Show both p-value and stars
fmt_com(p, label = "{p.format}{p.signif}")


# Adjust bracket y-position (absolute y-axis value, not proportion)
fmt_com(p, label.y = 8)

```
