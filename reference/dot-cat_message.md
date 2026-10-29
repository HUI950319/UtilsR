# Styled log message with timestamp

Print a timestamped, type-coloured message. Supports multi-line messages
(split on `"\n"`); lines longer than the console wrap, the continuation
lines starting under the text, unless `wrap = FALSE`.

## Usage

``` r
.cat_message(
  message,
  type = c("info", "success", "warning", "error"),
  timestamp_format = "[%Y-%m-%d %H:%M:%S]",
  style = c("full", "chip"),
  wrap = TRUE,
  verbose = TRUE
)
```

## Arguments

- message:

  Character. The message text: each element starts a new line, as does
  each `"\n"`; a zero-length message prints nothing.

- type:

  One of `"info"`, `"success"`, `"warning"`, `"error"`.

- timestamp_format:

  `strftime` format string (default `"[%Y-%m-%d %H:%M:%S]"`); `NULL` or
  `""` leaves the timestamp out.

- style:

  `"full"` (default) shades the whole message in the type colour after a
  magenta timestamp. `"chip"` prints the timestamp in grey and colours
  only a short type label (`INFO`, `DONE`, `WARN`, `FAIL`), leaving the
  text plain.

- wrap:

  Logical. `FALSE` keeps every line whole, for a line meant to be
  copied, such as a call: wrapping would break it, or a string in it,
  across lines.

- verbose:

  Logical. If `FALSE`, suppress output.

## Details

The message is a cli message, like those of
[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html):
[`suppressMessages()`](https://rdrr.io/r/base/message.html) silences it,
and it is written to standard output in interactive sessions and to
standard error otherwise. The text is shown verbatim, so braces are not
interpolated.

## See also

Other console display:
[`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md),
[`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md),
[`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
[`.cat_saved()`](https://hui950319.github.io/UtilsR/reference/dot-cat_saved.md),
[`.cat_step()`](https://hui950319.github.io/UtilsR/reference/dot-cat_step.md),
[`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)

## Examples

``` r
.cat_message("Loading simulated data", verbose = FALSE)
.cat_message("Saved forest.pdf", type = "success", style = "chip")
#> [2026-10-29 22:43:08]  DONE  Saved forest.pdf
```
