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

  Plot title. `NULL` = no change, `""` = remove. A vector sets different
  titles per plot.

- subtitle:

  Plot subtitle. `NULL` = no change. A vector sets different subtitles
  per plot.

- caption:

  Plot caption. `NULL` = no change. A vector sets different captions per
  plot.

- legend_title:

  Legend title. `NULL` = no change, `""` = remove.

- title_size:

  Numeric. Title font size. Default `NULL`.

- title_face:

  Character. Title font face. Default `NULL`.

- title_color:

  Character. Title color. Default `NULL`.

- title_hjust:

  Numeric. Title horizontal justification. Default `NULL`.

- subtitle_size:

  Numeric. Subtitle font size. Default `NULL`.

- subtitle_face:

  Character. Subtitle font face. Default `NULL`.

- subtitle_color:

  Character. Subtitle color. Default `NULL`.

- caption_size:

  Numeric. Caption font size. Default `NULL`.

- caption_face:

  Character. Caption font face. Default `NULL`.

- caption_color:

  Character. Caption color. Default `NULL`.

- axis_title_size:

  Numeric. Font size for both axis titles. Default `NULL`.

- axis_title_face:

  Character. Font face for both axis titles. Default `NULL`.

- axis_title_color:

  Character. Color for both axis titles. Default `NULL`.

- ...:

  Additional arguments passed to \[ggplot2::labs()\].

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
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)

## Examples

``` r
library(ggplot2)
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + geom_point()

# Set labels
fmt_text(p, title = "Iris", xlab = "Length", ylab = "Width")


# Per-plot labels (patchwork)
fmt_text(p + p, ylab = c("Width 1", "Width 2"))

```
