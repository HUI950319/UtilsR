# RCS (Restricted Cubic Spline) Plot Theme

Preset theme for Restricted Cubic Spline plots (Cox HR / Logistic OR /
Poisson rate vs. a continuous exposure). Built from \[theme_my()\] with
thinner rectangle / line linewidths matching the FeatureAnalysis source
convention (\`base_rect_size = 0.6, base_line_size = 0.8\`), minor grid
lines removed, and bold left-aligned legend text.

## Usage

``` r
theme_rcs
```

## Details

Used as \`+ theme_rcs\` (no parentheses) – it is a pre-built ggplot2
theme object, populated lazily on package load.

## See also

Other ggplot2 themes:
[`leg1()`](https://hui950319.github.io/UtilsR/reference/leg1.md),
[`leg2()`](https://hui950319.github.io/UtilsR/reference/leg2.md),
[`theme_ROC()`](https://hui950319.github.io/UtilsR/reference/theme_ROC.md),
[`theme_alluvia()`](https://hui950319.github.io/UtilsR/reference/theme_alluvia.md),
[`theme_blank()`](https://hui950319.github.io/UtilsR/reference/theme_blank.md),
[`theme_heat()`](https://hui950319.github.io/UtilsR/reference/theme_heat.md),
[`theme_km`](https://hui950319.github.io/UtilsR/reference/theme_km.md),
[`theme_legend()`](https://hui950319.github.io/UtilsR/reference/theme_legend.md),
[`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md),
[`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
[`theme_sc()`](https://hui950319.github.io/UtilsR/reference/theme_sc.md),
[`theme_scatter`](https://hui950319.github.io/UtilsR/reference/theme_scatter.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  library(ggplot2)
  ggplot(mtcars, aes(mpg, disp)) + geom_point() + theme_rcs
} # }
```
