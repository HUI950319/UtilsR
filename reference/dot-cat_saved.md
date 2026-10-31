# Announce a saved file with its size and whether it replaced one

One notice for every function that writes a file, in the shape
`<subject>: <path> [<size>, new <kind>]`, or
`<subject>: <path> [<size>, replaced the existing <kind>]` with the
replacement marker in red. Measure `existed` before the file is written,
since writing creates it. The notice is a
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
so [`suppressMessages()`](https://rdrr.io/r/base/message.html) silences
it.

## Usage

``` r
.cat_saved(subject, path, size, existed, kind)
```

## Arguments

- subject:

  Character. Leading clause, starting with the function name, e.g.
  `"PlotRank: the plot has been saved to"`.

- path:

  Character. Output file path, printed verbatim.

- size:

  Character. Size with its unit, e.g. `"12x10 in"` or `"12x5 cells"`.

- existed:

  Logical. `TRUE` when a file already occupied `path`.

- kind:

  Character. Output format shown in the marker, e.g. `"PDF"` or
  `"DOCX"`.

## See also

Other console display:
[`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md),
[`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md),
[`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
[`.cat_step()`](https://hui950319.github.io/UtilsR/reference/dot-cat_step.md),
[`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)

## Examples

``` r
path <- tempfile(fileext = ".pdf")
.cat_saved("the plot has been saved to", path, "7x5 in",
           file.exists(path), "PDF")
#> [2026-10-31 00:01:04]  ℹ the plot has been saved to: 
#>                          /tmp/RtmpVudOVs/file19f74b8989c8.pdf [7x5 in, new 
#>                          PDF] 
```
