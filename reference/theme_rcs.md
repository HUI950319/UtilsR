# RCS (Restricted Cubic Spline) Plot Theme

Preset theme for Restricted Cubic Spline plots (Cox HR / Logistic OR /
Poisson rate vs. a continuous exposure). Built from \[theme\_my()\] with
thinner rectangle / line linewidths matching the FeatureAnalysis source
convention (\`base\_rect\_size = 0.6, base\_line\_size = 0.8\`), minor
grid lines removed, and bold left-aligned legend text.

## Usage

``` r
theme_rcs
```

## Format

An object of class `theme` (inherits from `ggplot2::theme`, `gg`,
`S7_object`) of length 68.

## Details

Used as \`+ theme\_rcs\` (no parentheses) – it is a pre-built ggplot2
theme object, populated lazily on package load.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_heat()`, `theme_km`,
`theme_legend()`, `theme_legend1()`, `theme_my()`, `theme_sc()`,
`theme_scatter`

## Examples

``` r
if (FALSE) { # \dontrun{
  library(ggplot2)
  ggplot(mtcars, aes(mpg, disp)) + geom_point() + theme_rcs
} # }
```
