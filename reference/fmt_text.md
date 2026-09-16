# Format plot labels and their text style

Set and style plot text elements (title, subtitle, caption, axis titles,
legend title) in one call. Supports per-plot labels when input is a
patchwork or list (pass a vector to `xlab`, `ylab`, etc.).

## Usage

``` r
fmt_text(
  plot,
  xlab = NULL,
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  legend_title = NULL,
  title_size = NULL,
  title_face = NULL,
  title_color = NULL,
  title_hjust = NULL,
  subtitle_size = NULL,
  subtitle_face = NULL,
  subtitle_color = NULL,
  caption_size = NULL,
  caption_face = NULL,
  caption_color = NULL,
  axis_title_size = NULL,
  axis_title_face = NULL,
  axis_title_color = NULL,
  ...
)
```

## Arguments

  - plot:
    
    A ggplot, patchwork, or list of ggplot objects.

  - xlab:
    
    X-axis title. `NULL` = no change, `""` = remove. A vector sets
    different labels per plot.

  - ylab:
    
    Y-axis title. `NULL` = no change, `""` = remove. A vector sets
    different labels per plot.

  - title:
    
    Plot title. `NULL` = no change, `""` = remove. A vector sets
    different titles per plot.

  - subtitle:
    
    Plot subtitle. `NULL` = no change. A vector sets different subtitles
    per plot.

  - caption:
    
    Plot caption. `NULL` = no change. A vector sets different captions
    per plot.

  - legend\_title:
    
    Legend title. `NULL` = no change, `""` = remove.

  - title\_size:
    
    Numeric. Title font size. Default `NULL`.

  - title\_face:
    
    Character. Title font face. Default `NULL`.

  - title\_color:
    
    Character. Title color. Default `NULL`.

  - title\_hjust:
    
    Numeric. Title horizontal justification. Default `NULL`.

  - subtitle\_size:
    
    Numeric. Subtitle font size. Default `NULL`.

  - subtitle\_face:
    
    Character. Subtitle font face. Default `NULL`.

  - subtitle\_color:
    
    Character. Subtitle color. Default `NULL`.

  - caption\_size:
    
    Numeric. Caption font size. Default `NULL`.

  - caption\_face:
    
    Character. Caption font face. Default `NULL`.

  - caption\_color:
    
    Character. Caption color. Default `NULL`.

  - axis\_title\_size:
    
    Numeric. Font size for both axis titles. Default `NULL`.

  - axis\_title\_face:
    
    Character. Font face for both axis titles. Default `NULL`.

  - axis\_title\_color:
    
    Character. Color for both axis titles. Default `NULL`.

  - ...:
    
    Additional arguments passed to \[ggplot2::labs()\].

## Value

Same type as input.

## See also

Other plot formatting: `fmt_axis()`, `fmt_axisText()`, `fmt_axisTile()`,
`fmt_bg()`, `fmt_boxplot()`, `fmt_com()`, `fmt_expand()`, `fmt_his()`,
`fmt_legend()`, `fmt_panel()`, `fmt_plot()`, `fmt_plot_base()`,
`fmt_point()`, `fmt_raster()`, `fmt_ref()`, `fmt_scale()`,
`fmt_strip()`, `fmt_strip2()`, `fmt_tag()`

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()

# Set labels
fmt_text(p, title = "Iris", xlab = "Length", ylab = "Width")


# Per-plot labels (patchwork)
fmt_text(p + p, ylab = c("Width 1", "Width 2"))

```
