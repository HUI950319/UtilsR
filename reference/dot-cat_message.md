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

- timestamp_format:

  `strftime` format string (default `"[%Y-%m-%d %H:%M:%S]"`).

- verbose:

  Logical. If `FALSE`, suppress output.
