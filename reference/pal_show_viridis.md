# Visualise Viridis Palettes

Display the eight viridis colour maps using the same ggplot or gt layout
as
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md).

## Usage

``` r
pal_show_viridis(
  palette = NULL,
  n = 8,
  begin = 0,
  end = 1,
  direction = 1,
  alpha = 1,
  pattern = NULL,
  index = NULL,
  max_colors = 20,
  output = c("gt", "gg", "console")
)
```

## Arguments

- palette:

  Character vector of palette names: `"magma"`, `"inferno"`, `"plasma"`,
  `"viridis"`, `"cividis"`, `"rocket"`, `"mako"`, or `"turbo"`. `NULL`
  shows all palettes.

- n:

  Number of colours in each requested palette. Default 8. With `n = 1`,
  the native generator uses `begin` when `direction = 1`, or `end` when
  `direction = -1`. Capped previews evaluate only the displayed
  positions and retain the requested total in the colour-count label.

- begin, end:

  Plain numeric scalars between 0 and 1, without classes or dimensions,
  defining the portion of each colour map to use.

- direction:

  Direction of the colour map, a plain numeric scalar equal to 1 or -1,
  without a class or dimensions.

- alpha:

  Opacity of the colours, a plain numeric scalar between 0 and 1 without
  a class or dimensions.

- pattern:

  Single non-missing regex string used to filter palette names.

- index:

  Non-empty vector of unique positive whole-number indices after
  filtering. Out-of-range values are ignored. An empty selection reports
  the argument and matched count before any palettes are drawn.

- max_colors:

  Positive whole number limiting displayed colours per palette, or `Inf`
  for no display cap. Default 20. With `max_colors = 1`, the middle of
  the `n` generated colours is shown (the lower middle for even `n`).
  This can differ from native `n = 1` generation.

- output:

  Output format: `"gt"` (default) for a gt table, `"gg"` for a ggplot,
  or `"console"` for terminal output. gt colour swatches use HTML.
  LaTeX, Word, RTF and other non-HTML tables show HEX text instead. Use
  `output = "gg"` for coloured figures in PDF or Word documents.

## Value

A ggplot or gt object returned visibly for automatic display. Console
output prints and invisibly returns the displayed palette list.

## Details

Explicit `palette` names take precedence over `pattern` and `type`
(where available). These filters are applied only when `palette = NULL`.
Unknown names are reported and skipped when at least one valid palette
remains.

## See also

Other colour palettes:
[`pal_bar`](https://hui950319.github.io/UtilsR/reference/pal_bar.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_heat`](https://hui950319.github.io/UtilsR/reference/pal_heat.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md),
[`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md),
[`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md),
[`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md)

## Examples

``` r
pal_show_viridis(c("viridis", "plasma"), n = 8, output = "gg")

pal_show_viridis(direction = -1, output = "gg")


# Native single-colour generation versus a capped preview
pal_show_viridis("viridis", n = 1, output = "gg")

pal_show_viridis("viridis", n = 8, max_colors = 1, output = "gg")

```
