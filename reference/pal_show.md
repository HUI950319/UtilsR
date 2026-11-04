# Visualise Palettes or Colour Vectors

Display palettes as horizontal colour bars (ggplot) or a gt table with
colour swatches. Use `output = "gg"` for the Plots pane or
`output = "gt"` for the Viewer pane.

## Usage

``` r
pal_show(
  palette = NULL,
  n = NULL,
  pattern = NULL,
  type = c("all", "discrete", "continuous"),
  max_colors = 20,
  index = NULL,
  output = c("gt", "gg", "console"),
  label = TRUE,
  label_size = 3,
  ncol = NULL
)
```

## Arguments

- palette:

  Character vector of palette names (e.g. `"lancet"`), a colour vector
  (hex codes or named colours), or `NULL` to show all palettes matching
  `pattern`/`type`. Named colour vectors (e.g. `pal_paraSC`) use valid
  names as labels and hex codes for missing or whitespace-only names
  when selecting existing colours. When `n` exceeds the vector length,
  the generated preview uses HEX labels. Repeated palette names are
  displayed once, in first-occurrence order; repeated literal colours
  are preserved. Factors, classed vectors, matrices and data frames are
  not supported.

- n:

  Positive whole number of colours to preview from each palette.
  Continuous palettes are sampled evenly across their full range; a
  single colour uses the middle of the palette. Discrete palettes and
  untyped colour vectors take colours from the front and interpolate
  when more are requested than are available. `max_colors` caps how many
  are drawn. Default `NULL` uses the native colour count before the
  display cap.

- pattern:

  Single non-missing regex string to filter catalogue names (e.g.
  `"^nord"`). Default `NULL` does not filter by name.

- type:

  Catalogue type filter: `"all"`, `"discrete"`, or `"continuous"`.

- max_colors:

  Positive whole number limiting displayed colours per palette, or `Inf`
  for no display cap. Default 20.

- index:

  Non-empty vector of unique positive whole-number catalogue indices
  after name selection or filtering. Out-of-range indices are ignored.
  An empty catalogue selection is an error.

- output:

  Output format: `"gt"` (default) for a gt table, `"gg"` for a ggplot,
  or `"console"` for terminal output. gt colour swatches use HTML.
  LaTeX, Word, RTF and other non-HTML tables show HEX text instead. Use
  `output = "gg"` for coloured figures in PDF or Word documents.

- label:

  Logical. For `output = "gg"` in colour vector mode, whether to show
  hex/name labels on tiles. Default `TRUE`. Does not change gt tables or
  console output. Label contrast is calculated on white. Use a white
  plot panel when showing translucent swatches on a dark page.

- label_size:

  Positive finite number. Tile-label text size for `output = "gg"` in
  colour vector mode. Default 3.

- ncol:

  Positive whole number of columns for `output = "gg"` in colour vector
  mode. Default `NULL` puts every displayed colour on a single row.

## Value

A ggplot or gt object returned visibly for automatic display. Console
output prints and invisibly returns the displayed data.

## Details

When `palette` is a character vector of valid colour specifications (hex
codes like `"#FF0000"` or named R colours like `"red"`) rather than
palette names, the function automatically switches to **colour vector
mode**: it displays the colours directly as tiles (ggplot), a table, or
console swatches.

Catalogue swatches use thin grey outlines in ggplot and HTML output. The
outlines remain visible for fully transparent fills.

In gt catalogue output, long palette names wrap within the name column.
Each swatch exposes its hexadecimal colour value as a hover title and an
accessible label. LaTeX catalogue tables use the available text width
and repeat column headings when the table spans pages in a single-column
document. For a short table in a two-column LaTeX document, turn off
both `latex.use_longtable` and `latex.header_repeat` on the returned
table with
[`gt::tab_options()`](https://gt.rstudio.com/reference/tab_options.html).
Adjust the column proportions to fit the document's column width.

For readable ggplot labels on a small figure, use `ncol` to place a
colour vector in several rows. Use `pattern` or `index` to limit how
many palettes appear in a catalogue plot.

Explicit palette names take precedence over `pattern` and `type`. These
filters apply when browsing with `palette = NULL`. In colour vector
mode, `pattern`, `type` and `index` do not select colours. Subset the
colour vector before calling the function to select individual colours.

## See also

Other colour palettes:
[`pal_bar`](https://hui950319.github.io/UtilsR/reference/pal_bar.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_heat`](https://hui950319.github.io/UtilsR/reference/pal_heat.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md),
[`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md),
[`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md),
[`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md),
[`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)

## Examples

``` r
# Show specific palettes (gt table, default)
pal_show(c("lancet", "Paired", "viridis"))


  








3 Palettes
```
