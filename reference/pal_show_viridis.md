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

  Number of colours to generate for each palette. Default 8.

- begin, end:

  Numeric values between 0 and 1 defining the portion of each colour map
  to use.

- direction:

  Direction of the colour map, either 1 or -1.

- alpha:

  Opacity of the colours, a number between 0 and 1.

- pattern:

  Regex pattern used to filter palette names.

- index:

  Integer vector of palette indices to display after filtering.

- max_colors:

  Maximum colours to display per palette. Default 20.

- output:

  Output format: `"gt"` (default) for a gt table, `"gg"` for a ggplot,
  or `"console"` for terminal output.

## Value

A ggplot or gt object (also prints).

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

```
