# Add pairwise statistical comparisons

Uses
[`ggpubr::geom_pwc`](https://rpkgs.datanovia.com/ggpubr/reference/geom_pwc.html)
to overlay significance brackets.

## Usage

``` r
fmt_com(
  plot,
  com_method = "con",
  label.y = NULL,
  label = c("p.signif", "{p.format}{p.signif}", "p.format"),
  ...
)
```

## Arguments

- plot:

  A ggplot, patchwork, or list of ggplots.

- com_method:

  Comparison method: `"con"` (consecutive), `"all"` (all pairs), or a
  list of length-2 character vectors.

- label.y:

  Numeric y-position for the first bracket (absolute y-axis value, not
  proportion). Default `NULL` lets ggpubr auto-calculate.

- label:

  Label type: `"p.signif"`, `"\{p.format\}\{p.signif\}"`, or
  `"p.format"`.

- ...:

  Additional arguments passed to
  [`ggpubr::geom_pwc`](https://rpkgs.datanovia.com/ggpubr/reference/geom_pwc.html).

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

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
