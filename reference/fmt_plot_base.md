# Broadcast theme / labs / scales onto every panel

Apply a theme, axis labels and axis-scale settings to **every** panel of
a patchwork in one call: the theme and labels with patchwork's `&`
operator, the scale settings with
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md).
This is the packaged form of the legacy FeatureAnalysis helper
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

  A ggplot, patchwork, or list of these. Each plot of a list is
  formatted on its own.

- ggtheme:

  Theme to broadcast. Polymorphic (resolved internally): a
  [`ggplot2::theme`](https://ggplot2.tidyverse.org/reference/theme.html)
  object, a theme **function** (e.g. `theme_my`), or a function-name
  **string** (e.g. `"theme_km"`). `NULL` (default) leaves the theme
  untouched.

- labs_list:

  Named list passed to
  [`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html),
  e.g. `list(x = "ETE", y = "SHAP value")`. `NULL` = no change.

- scale_y_list:

  Named list of y-axis scale arguments, applied to every panel with
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md):
  each panel keeps its scale type (continuous, discrete, date, ...), and
  an existing scale keeps the settings the list does not name, such as a
  log transformation. E.g.
  `list(limits = c(0, 1), breaks = seq(0, 1, 0.2))`. `NULL` = no change.

- scale_x_list:

  Like `scale_y_list`, for the x axis.

## Value

Same type as input, with the requested settings added to every plot.

## Details

Each argument is applied only when non-`NULL`, so a bare
`fmt_plot_base(p)` returns `p` unchanged.

## See also

[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_flatten()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

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
