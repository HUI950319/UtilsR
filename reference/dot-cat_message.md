# Styled log message with timestamp

Print a timestamped, type-coloured message. Supports multi-line messages
(split on `"\n"`).

## Usage

``` r
.cat_message(
  message,
  type = c("info", "success", "warning", "error"),
  timestamp_format = "[%Y-%m-%d %H:%M:%S]",
  verbose = TRUE
)
```

## Arguments

  - message:
    
    Character. The message text.

  - type:
    
    One of `"info"`, `"success"`, `"warning"`, `"error"`.

  - timestamp\_format:
    
    `strftime` format string (default `"[%Y-%m-%d %H:%M:%S]"`).

  - verbose:
    
    Logical. If `FALSE`, suppress output.

## See also

Other console display: `.cat_box()`, `.cat_formula()`, `.cat_line()`,
`.cat_tb()`

## Examples

``` r
.cat_message("Loading simulated data", verbose = FALSE)
```
