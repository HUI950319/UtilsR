# Numbered, timed progress step

Announce one step of a longer computation. The step is marked done, with
its elapsed time, when the next step starts or when the calling function
returns; an error marks it failed. A wrapper of
[`cli::cli_progress_step()`](https://cli.r-lib.org/reference/cli_progress_step.html)
that numbers steps and honours `verbose`.

## Usage

``` r
.cat_step(
  msg,
  i = NULL,
  n = NULL,
  msg_done = msg,
  verbose = TRUE,
  .envir = parent.frame()
)
```

## Arguments

- msg:

  Character. Step description. cli inline markup and glue interpolation
  are evaluated in `.envir`, so `"Fitting {n} models"` picks up `n` from
  the caller. Text that cli cannot parse, such as data that contains
  braces, is shown as written.

- i, n:

  Optional step number and total, shown as a grey `[i/n]` prefix (`[i]`
  when `n` is `NULL`).

- msg_done:

  Character. Text shown when the step completes; defaults to `msg`. It
  takes the same prefix.

- verbose:

  Logical. If `FALSE`, print nothing.

- .envir:

  Environment whose exit ends the step and in which `msg` is
  interpolated. Defaults to the caller of `.cat_step()`; a helper that
  calls `.cat_step()` for its own caller passes its
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html).

## Value

The cli progress bar id, invisibly (`NULL` when `verbose = FALSE`).

## See also

Other console display:
[`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md),
[`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md),
[`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
[`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
[`.cat_saved()`](https://hui950319.github.io/UtilsR/reference/dot-cat_saved.md),
[`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)

## Examples

``` r
fit_all <- function() {
  .cat_step("Fitting models", i = 1, n = 2)
  Sys.sleep(0.1)
  .cat_step("Drawing plot", i = 2, n = 2, msg_done = "Drew plot")
  invisible()
}
fit_all()
#> ℹ [1/2] Fitting models
#> ✔ [1/2] Fitting models [110ms]
#> 
#> ℹ [2/2] Drawing plot
#> ✔ [2/2] Drew plot [12ms]
#> 
```
