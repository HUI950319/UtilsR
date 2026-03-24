# Add panel labels to plots

Add text labels (e.g. A, B, C) to the corner of each plot panel using
\[ggpp::annotate()\] with NPC coordinates.

## Usage

``` r
fmt_tag(
  plot,
  labels = NULL,
  label_position = c(0.02, 0.98),
  size = 16,
  color = "black",
  fontface = "bold",
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

  Numeric vector of length 2 giving NPC coordinates \`c(x, y)\` for
  label placement. Default \`c(0.02, 0.98)\` is top-left.

- size:

  Numeric label size in points. Default 16.

- color:

  Label text color. Default \`"black"\`.

- fontface:

  Font face for labels. Default \`"bold"\`.

- ...:

  Additional arguments passed to \[ggpp::annotate()\].

## Value

Same type as input.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)

## Examples

``` r
library(ggplot2)
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
p2 <- ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point()

# Auto-label A, B
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
```
