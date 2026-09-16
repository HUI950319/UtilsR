# Broadcast theme / labs / scales onto a patchwork via \`&\`

Apply a theme, axis labels, and continuous y/x scales to \*\*every\*\*
panel of a patchwork in one call, using patchwork's `&` operator. This
is the packaged form of the legacy FeatureAnalysis helper
`.fmt_plot.base()`: a list-driven wrapper that is handy when assembling
multi-panel figures.

## Usage

``` r
fmt_plot_base(
  plot,
  ggtheme = NULL,
  labs_list = NULL,
  scale_y_list = NULL,
  scale_x_list = NULL
)
```

## Arguments

  - plot:
    
    A patchwork (or ggplot) object.

  - ggtheme:
    
    Theme to broadcast. Polymorphic (resolved internally): a
    `ggplot2::theme` object, a theme \*\*function\*\* (e.g. `theme_my`),
    or a function-name \*\*string\*\* (e.g. `"theme_km"`). `NULL`
    (default) leaves the theme untouched.

  - labs\_list:
    
    Named list passed to `ggplot2::labs()`, e.g. `list(x = "ETE", y =
    "SHAP value")`. `NULL` = no change.

  - scale\_y\_list:
    
    Named list passed to `ggplot2::scale_y_continuous()`, e.g.
    `list(limits = c(0, 1), breaks = seq(0, 1, 0.2))`. `NULL` = no
    change.

  - scale\_x\_list:
    
    Named list passed to `ggplot2::scale_x_continuous()`. `NULL` = no
    change.

## Value

The input plot with the requested layers broadcast via `&`.

## Details

Each argument is applied only when non-`NULL`, so a bare
`fmt_plot_base(p)` returns `p` unchanged.

## See also

\[fmt\_plot()\]

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_point()`,
`fmt_raster()`, `fmt_ref()`, `fmt_scale()`, `fmt_strip()`,
`fmt_strip2()`, `fmt_tag()`, `fmt_text()`

## Examples

``` r
library(ggplot2); library(patchwork)
p <- (ggplot(mtcars, aes(wt, mpg)) + geom_point()) +
     (ggplot(mtcars, aes(hp, mpg)) + geom_point())

# theme object / labs / y-scale broadcast to both panels
fmt_plot_base(p,
              ggtheme      = theme_my(base_size = 12),
              labs_list    = list(y = "Miles per gallon"),
              scale_y_list = list(limits = c(10, 35)))


# ggtheme also accepts a function or a string
if (FALSE) { # \dontrun{
fmt_plot_base(p, ggtheme = theme_km)     # function
fmt_plot_base(p, ggtheme = "theme_km")   # string
} # }
```
