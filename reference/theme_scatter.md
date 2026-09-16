# Scatter / Feature Plot Theme

A clean theme aligned with scMMR's PlotScatter, PlotDynamicFeatures, and
FeaturePlot3. Based on `theme_bw()` with: title 14pt bold centered, axis
title 12pt, axis text 10pt black, strip text 10pt, legend title 11pt
bold, no minor grid lines.

## Usage

``` r
theme_scatter
```

## Format

An object of class `theme` (inherits from `ggplot2::theme`, `gg`,
`S7_object`) of length 144.

## See also

Other ggplot2 themes: `leg1()`, `leg2()`, `theme_ROC()`,
`theme_alluvia()`, `theme_blank()`, `theme_heat()`, `theme_km`,
`theme_legend()`, `theme_legend1()`, `theme_my()`, `theme_rcs`,
`theme_sc()`

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
p + theme_scatter
} # }
```
