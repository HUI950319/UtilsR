# Plot Missing Values

Create a missing-value matrix, a missing-percentage bar chart, or one of
two combined layouts for a data frame or an \`mlr3::Task\`. Use
\[plt_upset()\] with \`levels = NA\` to visualise joint missing-value
patterns across selected variables.

## Usage

``` r
plt_na(
  data,
  name.map = NULL,
  miss_palette = as.character(pal_lancet[c(1, 2, 3)]),
  output = c("both", "both_reverse", "matrix", "percentage"),
  sort = c("desc", "asc"),
  save = list()
)
```

## Arguments

- data:

  A data frame, tibble, or object inheriting from \`Task\`. Missing
  values follow each original column's
  [`is.na()`](https://rdrr.io/r/base/NA.html) method, including SPSS
  user-missing codes and ranges. An explicit factor NA level remains a
  category. Methods for stored integer64 and time-span columns are
  loaded before inspection. Columns must be one-dimensional and have
  unique, non-missing, non-empty names; matrix and array columns are
  rejected.

- name.map:

  Optional named character vector used to replace variable names in the
  plot. Names must be the original variable names. Distinct variables
  may share a displayed label without being merged. Mapping keys must be
  unique, non-missing and non-empty.

- miss_palette:

  Character vector of at least three colours. The first colour
  represents present values, the second represents missing values, and
  the third colours the 30 colours of \[pal_lancet()\]. Names attached
  to the colours are ignored.

- output:

  Plot layout to return. One of \`"both"\` (missingness matrix on the
  left and percentages on the right), \`"both_reverse"\` (percentages on
  the left and matrix on the right), \`"matrix"\`, or \`"percentage"\`.

- sort:

  Variable order by missing rate: \`"desc"\` (default, largest to
  smallest) or \`"asc"\` (smallest to largest). Percentage labels below
  0.01% or above 99.99% use bounds so positive missingness does not
  display as zero or incomplete missingness as 100%.

- save:

  `NULL`, an empty list (default), or a named list forwarded to
  `RegR::save_plt()` for PDF output: `filename` and optionally `width`
  and `height`. A `width` or `height` left out defaults to the page the
  plot is laid out for – 0.3 in per variable (at least 3 in) tall, with
  a 5 in matrix panel and a 3.5 in percentage panel, beside the measured
  axis text, strips and legend – which every call prints with the
  matching `save` line; with no missing values there is no file. Saving,
  and the size note, need the RegR package.

## Value

A single ggplot-compatible object, carrying that page size as
`attr(p, "plot_size")`, `c(width, height)` in inches. Combined outputs
return a patchwork object, which inherits from ggplot. Returns \`NULL\`
with a warning when no missing values are found.

## See also

\[fmt_strip()\], \[plt_upset()\]

Other inspect:
[`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md),
[`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md),
[`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
[`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
[`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md),
[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)

## Examples

``` r
dat <- data.frame(age = c(30, NA, 50), marker = c(NA, 2, 3))
plt_na(dat, output = "percentage")


# \donttest{
if (requireNamespace("ToyData", quietly = TRUE)) {
  plt_na(ToyData::oc)
  plt_na(ToyData::oc, output = "both_reverse")
  plt_na(ToyData::oc, output = "matrix")
  plt_na(ToyData::oc, output = "percentage", sort = "asc")
}

if (requireNamespace("ToyData", quietly = TRUE) &&
    requireNamespace("ggVennDiagram", quietly = TRUE)) {
  plt_upset(
    ToyData::oc0,
    vars = c("BMI_1", "BMI_2", "BMI_3"),
    levels = NA,
    output = "upset"
  )
}
# }
```
