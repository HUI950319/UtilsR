# Resolve a colour specification to a colour vector

The colour handling shared by the plot functions of UtilsR and RegR,
exported for those packages. For colours in your own code use
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md).

## Usage

``` r
.resolve_color(palette = NULL, n = NULL, default = pal_lancet)
```

## Arguments

- palette:

  `NULL`, a registered palette name (resolved via
  [`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md)),
  a single literal colour, or a colour vector. Vectors must have no
  dimensions and contain plain character or numeric values, logical
  missing values, or factors (converted to character). Other classes,
  including labelled, integer64 and date-time vectors, are not
  supported; convert these explicitly before choosing colours. Numeric
  colour indices, including numeric strings, are resolved against the
  current
  [`grDevices::palette()`](https://rdrr.io/r/grDevices/palette.html) and
  returned as fixed RGBA hex colours. Indices must be finite and fit in
  an R integer after truncation. Other literal strings and missing
  colours are kept as given. Anything R cannot draw is an error naming
  the calling function.

- n:

  Optional plain integer or double scalar with a whole-number value from
  zero to `.Machine$integer.max`, without a class or dimensions.
  Registered palettes use `pal_get(palette, n = n)` (interpolating when
  `n` is longer); literal vectors and `default` use
  [`rep_len()`](https://rdrr.io/r/base/rep.html), with a warning when
  several colours have to repeat. `NULL` (default) returns the palette
  at its natural length.

- default:

  Fallback colour vector when `palette = NULL`. Default
  [`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md).
  Must be non-empty and contain valid literal colours; registered
  palette names are not expanded here.

## Value

An unnamed character vector: hex colours from a registered palette,
fixed RGBA hex colours for numeric indices, and other literal colours as
given.

## Examples

``` r
.resolve_color("lancet", n = 3)
#> [1] "#00468BFF" "#ED0000FF" "#42B540FF"
.resolve_color("#FF000080", n = 2)
#> [1] "#FF000080" "#FF000080"
.resolve_color(NULL, n = 2)
#> [1] "#00468BFF" "#ED0000FF"
```
