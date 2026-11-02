# Visualise ggsci Palettes

Display the palettes provided by `ggsci` using the same ggplot or gt
layout as
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md).

## Usage

``` r
pal_show_ggsci(
  palette = NULL,
  n = NULL,
  alpha = 1,
  reverse = FALSE,
  pattern = NULL,
  index = NULL,
  max_colors = 20,
  output = c("gt", "gg", "console")
)
```

## Arguments

- palette:

  Character vector of palette names. Names use the form
  `"ggsci_npg_nrc"`; the `ggsci_` prefix may be omitted. `NULL` shows
  all palettes.

- n:

  Number of colours to retain, capped at each palette's native size.
  Continuous GSEA, Bootstrap 5, Material and Tailwind 3 palettes are
  sampled evenly across their full range; a single colour uses the
  middle. Discrete palettes retain their first colours. `NULL` uses each
  palette's native number of colours.

- alpha:

  Opacity of the colours, a plain numeric scalar between 0 and 1 without
  a class or dimensions.

- reverse:

  Logical scalar without a class or dimensions; if `TRUE`, reverse the
  final preview colours after applying `n` and `max_colors`, preserving
  the selected colour set.

- pattern:

  Single non-missing regex string used to filter palette names.

- index:

  Non-empty vector of unique positive whole-number indices after
  filtering. Out-of-range values are ignored. An empty selection reports
  the argument and matched count before any palettes are drawn.

- max_colors:

  Positive whole number limiting displayed colours per palette, or `Inf`
  for no display cap. Default 20.

- output:

  Output format: `"gt"` (default) for a gt table, `"gg"` for a ggplot,
  or `"console"` for terminal output.

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
[`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md),
[`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)

## Examples

``` r
if (requireNamespace("ggsci", quietly = TRUE)) {
  pal_show_ggsci(c("ggsci_npg_nrc", "ggsci_aaas_default"),
                 n = 5, output = "gg")
}

```
