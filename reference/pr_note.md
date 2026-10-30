# Grey note line for a print method

Print a grey italic `# ...` line for caveats and next steps, such as the
plotting call that suits the printed result.

## Usage

``` r
pr_note(..., .envir = parent.frame())
```

## Arguments

- ...:

  Character pieces of the note, pasted together.

- .envir:

  Environment in which [`{}`](https://rdrr.io/r/base/Paren.html)
  expressions are evaluated; defaults to the caller.

## Value

The printed line, invisibly.

## Details

The text goes through
[`cli::format_inline()`](https://cli.r-lib.org/reference/format_inline.html):
`{x}` is interpolated from `.envir`, inline markup such as `{.code ...}`
and `{.fn ...}` is styled, and in consoles that support hyperlinks
(recent RStudio versions) `{.run pkg::fun(x)}` and `{.help pkg::fun}`
become clickable links. Double literal braces, as in `"{{x}}"`. Text
that cli cannot parse, such as data that contains braces, is printed as
written instead of failing the print. Long notes wrap at the console
width, every line starting with `#`; a `"\n"` starts a new line.
Unbroken text also wraps by display width. Combining marks and
multi-code-point emoji stay together during wrapping. No supplied pieces
print nothing; an explicit empty string prints only the comment marker.

## See also

Other print helpers:
[`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md),
[`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md),
[`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
[`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md),
[`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md),
[`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md),
[`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md),
[`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)

## Examples

``` r
n_panel <- 2
pr_note("RV / xRV are partial R2; E-values are risk-ratio multipliers.")
#> # RV / xRV are partial R2; E-values are risk-ratio multipliers.
pr_note("Plot with {.run causalR::plt_sens(res)} ({n_panel} panels)")
#> # Plot with `causalR::plt_sens(res)` (2 panels)
```
