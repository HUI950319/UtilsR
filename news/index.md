# Changelog

## UtilsR 0.6.16

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  and root
  [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  displays treat POSIXlt date-times as vectors, consistently with
  POSIXct, instead of list-backed storage.

- Flipped stacked continuous panels free the displayed horizontal value
  scale, matching independent axes before coordinate flipping.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  describes packed data-frame columns by row, keeping the values from
  each row together instead of recycling column descriptions.

- Stacked
  [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  respects independent or shared feature axes in both orientations,
  while retaining explicit axis bounds.

- Stacked
  [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  panels retain pairwise/global comparisons per feature and requested
  raw-point overlays on dot plots.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  keeps explicit missing factor levels as `<NA>` without mistaking them
  for missing storage or failing during width calculation.

## UtilsR 0.6.15

- `plt_con(type = "dot")` uses numeric bin centres, including for
  constant columns and closely spaced values at large offsets.

- [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  respects SPSS user-missing codes and ranges, rejects ambiguous columns
  and unsupported numeric storage, and avoids dummy-group name clashes.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  and
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  gain `fmt_text`, a list of
  [`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)
  arguments applied before `save`, so the saved page carries new titles
  and is sized for them without a separate `RegR::save_plt()` call.

- Structure trees prepare names only for the visible items and
  omitted-name preview, retaining the exact omitted-line counts and
  printed output.

- Numeric distribution histograms skip unnecessary sorting and distinct
  value collection, retaining the same counts and printed summaries.

- Extreme-scale distribution summaries use compact scientific text and
  recover finite nonzero standard deviations through centering and
  scaling when the ordinary variance calculation overflows or
  underflows. Adjacent integer64 values above double precision retain
  their histogram categories and spread through translation before
  conversion.

- Whole-number display limits no longer trigger modulus warnings for
  large finite values.

- Console-table precision is checked against the formatter’s 324-digit
  limit instead of producing a backend warning or coercion failure.

- Tree class and attribute labels escape layout controls without
  changing the original metadata. A zero item budget still lists the
  omitted names.

- Narrow output accounts for uncoloured highlight markers, box padding
  and tree footers. Impossible indentation now identifies its argument
  instead of overflowing the console.

- Empty optional notes print nothing, while an explicit empty note
  retains its comment marker. Plain missing box contents display as NA,
  and badge fields and box borders escape layout controls.

- Text P-value significance is compared as decimal text, so underflow
  cannot turn a negative value into zero or erase a positive bound, and
  long decimal endpoints keep their position relative to a cut-off.

- POSIXlt distribution columns show their date-time range, histogram and
  missing share, as POSIXct columns do, without changing the input
  column.

- Metadata headers, key-value blocks and badges preserve SPSS
  user-missing values when converting them to text. Explicit missing
  factor levels remain visible categories in headers and key-value
  blocks.

- [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  inspects each default column by position, retaining distinct contents
  when names repeat or are missing. Missing table headings display as
  `<NA>` instead of stopping the print.

## UtilsR 0.6.14

- [`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md)
  also restores methods for stored classed values when a badge is the
  first print helper called in a fresh R process.

- Print helpers validate integer row, bin, depth, line, width, precision
  and indentation controls before formatting, rejecting fractional or
  missing inputs with the argument name. Unlimited row and tree limits
  continue to accept Inf.

- Print helpers respect narrow consoles: long keys and mandatory table
  headings are shortened, long unbroken text wraps by display width, and
  compact distribution lines retain the missing share when space is
  tight.

- Single-line table cells, headers, tree component names and
  distribution labels escape layout control characters such as newlines
  and tabs. Intentional multiline notes and key-value contents keep
  their line breaks.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  falls back to scientific notation for nonzero numbers that would still
  print as zero at six decimals and for numbers too wide for the
  available line.

- [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  distinguishes empty, entirely missing and non-finite columns without
  `NaN` percentages or an arbitrary top level. An explicit missing
  factor level is named `<NA>` when it is the most frequent level.

- [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  excludes SPSS user-missing codes and ranges before computing numeric
  summaries, using the same missing-value mask as its missing share.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  describes every component of a matrix or array column per row instead
  of silently showing only its first component.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  reads columns by position, preserving distinct contents when column
  names repeat or are empty.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  respects the direction of text P-value bounds, including Unicode
  comparisons and whitespace, and does not mark invalid numeric text as
  significant. Numeric P-values keep enough decimals below a cut-off and
  values below 0.001 print as `<0.001`.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  preserves integer64 digits and time-span components instead of
  formatting their underlying storage. Print helpers load the namespace
  supporting stored integer64, labelled and lubridate values when
  needed.

## UtilsR 0.6.13

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  works with panel sizes fixed through
  `theme(panel.widths, panel.heights)` (ggplot2 4.0). Fixing the size
  along the tiled axis stopped the plot with “Cannot create zero-length
  unit vector”, since ggplot2 counted the colour strip as a panel; the
  strip now keeps its `tile_height` / `tile_width` fraction of the fixed
  panel size. RegR’s `plt_screens()` needs it.

## UtilsR 0.6.12

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) prints
  each variable’s suggested `get_flt()` call on a light grey ground with
  black text, like inline code, where the console shows colour. Copied
  from the console it is plain text, and without colour (knitting, log
  files,
  [`capture.output()`](https://rdrr.io/r/utils/capture.output.html)) it
  prints plain.

- [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  summarizes integer64 and other classed numeric columns as plain
  numbers. The mean of an integer64 column is itself an integer64, which
  [`formatC()`](https://rdrr.io/r/base/formatc.html) wrote as its raw
  bits, a line of some 300 digits that pushed every other line’s missing
  share off the screen, and the sparkline came out flat.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)’s console
  report opens with a summary of the data set, as skimr’s Data Summary
  does: the number of rows and variables, the variables by type
  (`4 factor, 3 character, 3 numeric`), and those with missing or
  Unknown/Blank/N/A values. These had appeared only in the HTML table’s
  subtitle.

- A numeric variable with more than ten values is listed by its
  distribution at
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)’s
  console, as skimr gives it: a sparkline, the range, median \[Q1, Q3\]
  and mean (SD). Counts of its first values (ages 0, 1, 2, …) said
  little about it. Numeric codes with up to ten values keep their
  frequency table.

- At the console,
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) lists
  each variable in one block, set off by a blank line: a heading with
  its counts (`Grade (factor) · 5 levels · special 4,271 (93.9%)`), a
  frequency table of values with `n`, `pct` and cumulative `cum` shares
  of all rows, missing values last, and the suggested `get_flt()` call.
  Beyond 15 values the rest are summed in one `(k others)` row. Each
  variable had two headings (`count` and `unique values`) over a
  [`dplyr::count()`](https://dplyr.tidyverse.org/reference/count.html)
  tibble that hid missing values beyond its tenth row.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)’s
  variable summary gives each count of missing and of Unknown/Blank/N/A
  values with its share of the rows (`4,271 (93.9%)`), at the console in
  an aligned
  [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  rather than a tibble. In the HTML table those counts are shaded red
  and blue where there are any, as in the count table, a note names the
  shades and the type tints, and the suggested `get_flt()` call is
  left-aligned in monospace and shortened to one line (the console
  prints it whole); it had been centred and wrapped over up to four
  lines.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  no longer replaces the cells of a first column one to three characters
  wide with dots where the console has no Unicode: it cut every cell to
  the column width, and
  [`cli::ansi_strtrim()`](https://cli.r-lib.org/reference/ansi_strtrim.html)
  gives its `...` ellipsis cut to a width narrower than itself even for
  text that fits (`"A"` became `"."`). Only cells too wide for the
  column are cut.

- At the console,
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) gives one
  [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  line per variable under “Variable distributions”: a sparkline, the
  mean and SD or the levels and the most frequent one, and the share
  missing. It replaces the summary table printed as a tibble, whose
  cells carried the table’s markdown (`**Vars**`,
  `__Age (numeric, 91)__`) and `NA` for each variable row.

- `lv(count = c(a, b))` gives one two-way table, as janitor’s
  `adorn_totals()` + `adorn_percentages("row")` + `adorn_ns()` lay it
  out: each cell shows the count and the row percentage
  (`1,285 (64.8%)`), a Total row the column counts and their shares of
  all rows, and a Total column the row counts. It replaces the long
  list, the wide table and the row-percentage table that two variables
  used to print; in the HTML table the second variable names its columns
  as a spanner. Columns are sorted as factor levels or values.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) writes
  counts with thousands separators and shares with one decimal
  throughout. The cross-tabulation list printed `n`, `pct` and `n_pct`,
  the same share twice with two decimals that dropped trailing zeros
  (`1285 (28.25%)` beside `655 (14.4%)`); it now gives `n` and `pct`
  (`28.2%`) in an aligned console table. The wide table’s cells and the
  subtitles of both tables (`n = 4549`, `4549 observations`) take
  separators too.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)‘s count
  table gives each shade one meaning and names those it uses in a note
  under the table. Shares of rare categories darken in one hue, light
  orange for 5-10%, orange for 1-5% and dark orange below 1%; labels of
  missing rows are light red and of Unknown/Blank/N/A values light blue,
  as in
  [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md).
  Red had marked both missing rows and shares below 1%, yellow both
  special values and shares of 1-5%, green shares of 5-10%, all without
  a legend. Missing rows’ shares are no longer shaded as rare
  categories.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)’s
  suggested `get_flt()` filters print as plain lines, without
  [`print()`](https://rdrr.io/r/base/print.html)’s `[1]` prefix, so they
  copy as code, and list the values of character, numeric, logical and
  date columns sorted as the count listing above them sorts them, rather
  than in the order they occur (`c(66, 72, 70, ...)` for ages). Factors
  keep their level order.

- Outside interactive sessions, such as `Rscript` or an RStudio
  background job,
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) no longer
  prints its HTML tables, which arrived as HTML source (some 500 lines
  per table;
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) of a
  93-column data frame wrote 3,903 lines instead of 1,087). A message
  says the tables were not shown.

- `lv(group = )`’s table carries a caption naming the grouping and the
  number of rows, `Variable summary by Sex (n = 4,549)`, as the default
  summary table names its data.

- Knitted [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  reports no longer head each variable with a
  `** summary for x (class) **` message: the console listings it headed
  are left out of knitted documents, so each heading stood over nothing.

- The missing rows of
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)’s summary
  tables give their share of the rows beside the count, `418 (9.2%)`
  rather than `418`, in the default and the grouped table.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) no longer
  prints `Setting theme "Compact"` on every call; the compact gtsummary
  theme it sets for its own tables is set quietly.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) selects
  columns through a caller’s vector of names or positions,
  `lv(data, vars)` or `lv(vars)`, without tidyselect’s “Using an
  external vector in selections was deprecated” warning: such a vector,
  also inside [`c()`](https://rdrr.io/r/base/c.html), `-` or `!`, is
  wrapped in
  [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html).
  Column names still take precedence over caller objects of the same
  name.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  no longer keeps the plots it tags inside each in-panel label. The
  label layer was built in
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)’s
  own frame, which its mapping and geom kept, so every tagged plot
  carried all the others: the first of four tagged 1e5-point plots held
  the data of all four, and a `RegR::get_rcs_all()` composite saved with
  [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) took 11.9 MB
  instead of 9.5 MB. The labels draw as before.

- A
  [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  line still too wide for a narrow console, such as a data frame with an
  attribute tag, ends in an ellipsis;
  [`cli::tree()`](https://cli.r-lib.org/reference/tree.html) cut it off
  without one, leaving `term, HR [` at 40 columns.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  says what it left out: `... 25 more` goes on with the names of the
  elements it skipped (`... 25 more: e6, e7, e8, ...`), and the footer
  names the argument that cut the lines
  (`# ... 16 more lines (max_lines = 9)`).

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  pads the names of siblings to a common width, up to 18 characters, so
  their descriptions start in one column, as
  [`str()`](https://rdrr.io/r/utils/str.html) and
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  line them up.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  names the attributes a closed node carries at the end of its line,
  such as `[attr: model_info]` on a result table or `[attr: plot_size]`
  on a plot, leaving out those its type keeps for itself (factor levels,
  a time zone, value labels, ggplot2’s S7 properties). Only the
  attributes of open nodes were shown, so these went unseen.
  `attrs = FALSE` drops them.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  gives a factor’s number of levels, `<fct 100, 3 levels>`, as
  [`str()`](https://rdrr.io/r/utils/str.html) does.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  takes as many values as the line could hold and ends a vector it cut
  with an ellipsis: at a width of 100, `1:100` read `1, 2, ..., 10`, as
  if that were all.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  opens the object it is given: a model fit lists its components, a data
  frame its columns and an S4 object its slots (as `@name`), where each
  printed a single line such as `<lm>`. Inside a list they stay closed,
  as before.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  follows a data frame with its column names, as many as fit the line:
  `<tibble 12 x 5> term, HR, lower, upper, p`.

- A list
  [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  leaves closed, at `max_depth` or as an attribute, previews its names
  and the value of each single one:
  `attr analysis <list 2> n = 1000, outcome = "DSS"` read
  `attr analysis <list 2>`. An unnamed list keeps the ellipsis.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  names the element type of a matrix or table (`<int matrix 2 x 3>`) and
  the arguments of a function (`<fn(data, formula, ...)>`, the first
  four), which read `<matrix 2 x 3>` and `<fn>`.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  shows whole numbers as they are and decimals to three digits past
  their integer part: rounded to three significant digits, `123456L`
  read `123000` and `1234.5678` read `1230`.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  names classed vectors as vctrs does, such as `<drtn 2>` for a
  difftime, `<dbl+lbl 3>` for a labelled vector and `<int64>`, where
  they read `<dbl ...>`; a POSIXlt time shows as `<dttm>` with its value
  instead of `<POSIXlt>`.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  previews show the names of a named vector (`train = 800, test = 200`),
  the value labels of a labelled one (`1 [Male]`), factor levels without
  quotes, and formulas, calls and symbols as written
  (`<formula> Surv(time, DSS) ~ Age + Sex`), which read only
  `<formula>`.
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  describes formulas the same way.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  previews fill the line up to the console width and end in an ellipsis,
  where they stopped at 40 characters, or were cut off without one on a
  narrow console. Lengths and dimensions carry a thousands mark,
  `<int 1,000,000>` and `<data.frame 12,345 x 7>`, in
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  too.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  colours the parts of a line apart: the type and size stay grey, values
  take the console’s text colour with `NA` in red, and the names of
  elements that hold others are bold. The whole description, values
  included, used to be grey.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  starts with the class chip only for a classed list, the case it is
  meant for; a plain list, a vector or a data frame no longer repeats
  its class (`<list> <list 3>` now reads `<list 3>`).

- [`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md)
  no longer counts a missing outcome value as a level, so a binary
  outcome with `NA`s is announced as a Cox model, not a CRR one.

- [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  prints every element of a character vector, each on its own line; it
  showed only the first. A zero-length message prints nothing instead of
  failing with “subscript out of bounds”, and a missing one prints `NA`
  instead of failing with “missing value where TRUE/FALSE needed”.

- [`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md)
  prints nothing when there is nothing to frame, such as a list whose
  elements are all `NULL`, instead of failing with “a character vector
  argument expected”.

- `.cat_message(timestamp_format = NULL)` or `timestamp_format = ""`
  leaves the timestamp out. An empty format used to fall back to R’s
  default date-time format, so the timestamp stayed, without its
  brackets.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  stops describing nodes once it reaches `max_lines` and only counts the
  rest, so a large nested list prints its first lines at once: a 20 x 20
  x 20 list took 2.5 s to print 200 lines, now 0.07 s. The printed lines
  are unchanged.

- [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md) and
  [`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md)
  show numbers as [`print()`](https://rdrr.io/r/base/print.html) does,
  to `getOption("digits")` significant digits: `1/3` read
  `0.333333333333333`.
  [`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md)
  also shows a factor piece as its label and a date as a date, where it
  showed the factor code and the day count.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  shows a P value just under 0.05 or 0.01 with the decimals it needs,
  `0.0499*` rather than `0.050*`: rounded to three decimals it read as
  the cut-off, beside a `0.050` with no star.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  gains `rownames`: `TRUE` shows the row names as a first, unnamed
  column, such as the terms of a coefficient matrix turned data frame,
  which are otherwise not shown. It is off by default, since
  [`rbind()`](https://rdrr.io/r/base/cbind.html) of a named list also
  leaves row names (`cox.1`, `cox.2`).

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  cuts a first column too wide for the line with an ellipsis: long
  variable labels made the table overflow `width`, as the first and the
  P-value columns always show.

- [`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md)
  starts a new line at each `"\n"`, as
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  does; the lines of a note were joined with a space.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  describes the cells of a list column as
  [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  does, `<dbl 2> 1.1, 2.2`, where it printed the deparsed `c(1.1, 2.2)`.

- [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  shows a column whose values all differ, such as a patient identifier,
  as `<n> unique values` instead of tabulating it: 1e5 identifiers took
  0.1 s to draw a flat line of single counts.

- [`PlotButterfly()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly.md),
  [`PlotButterfly2()`](https://hui950319.github.io/UtilsR/reference/PlotButterfly2.md)
  and
  [`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md)
  announce a saved plot with
  [`.cat_saved()`](https://hui950319.github.io/UtilsR/reference/dot-cat_saved.md),
  as the other plotting functions do:
  `PlotRankCor: the plot has been saved to: <path> [7x5 in, new PDF]`,
  in place of `Plot saved to <path>`.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) prints
  its headings and facts at the console with
  [`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md)
  and
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md), on
  stdout beside the tables they head (cross-tabulation, wide and
  row-percentage tables, grouped summary, Seurat summary and cell
  statistics), so
  [`capture.output()`](https://rdrr.io/r/utils/capture.output.html) and
  Rscript logs keep them and
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) no longer
  strips them from the report. The banner above each variable, which the
  console listing already names, is left out there. Knitted reports keep
  the cli headers as before.

## UtilsR 0.6.11

- [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md)
  and
  [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  with `split.by` report the size of the split figure once again. Each
  panel’s own “plot laid out for” note was captured as printed output,
  which a
  [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  no longer is since it became a cli message, so a figure of three
  panels showed four notes.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  keeps gt tables, RegR pages and htmltools tag lists closed: they are
  lists underneath, and opening one listed some 20 internal fields, such
  as `_data` and `_styles`, in place of the result’s parts. R6 objects,
  such as mlr3 learners, show their class instead of `<env>`, in
  [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  and [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  alike.

- [`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md)
  announces a model in one
  [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  line, e.g. `Cox model, unadjusted: Surv(time, DSS) ~ Sex`, instead of
  a box and a rule, nine lines in all;
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) silences
  it.

- `.cat_message(wrap = FALSE)` keeps every line whole, for a line meant
  to be copied, such as a `save = list(...)` call.

- New
  [`.cat_saved()`](https://hui950319.github.io/UtilsR/reference/dot-cat_saved.md)
  announces a written file as `<subject>: <path> [<size>, new PDF]`, or
  `replaced the existing PDF` in red, as a
  [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md);
  it moves here from RegR.
  [`PlotCircleLollipop()`](https://hui950319.github.io/UtilsR/reference/PlotCircleLollipop.md),
  [`PlotDumbbell()`](https://hui950319.github.io/UtilsR/reference/PlotDumbbell.md),
  [`PlotHeatmapJaccard()`](https://hui950319.github.io/UtilsR/reference/PlotHeatmapJaccard.md),
  [`PlotRank()`](https://hui950319.github.io/UtilsR/reference/PlotRank.md)
  and
  [`PlotScatter1()`](https://hui950319.github.io/UtilsR/reference/PlotScatter1.md)
  to
  [`PlotScatter3()`](https://hui950319.github.io/UtilsR/reference/PlotScatter3.md)
  use it for their `filename`, with the function name and the page size,
  instead of `message("Plot saved to: ")`.

## UtilsR 0.6.10

- [`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md)
  prints its per-group correlations as a
  [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  with the P values coloured by significance. The coefficient column is
  `r` for `use_rank = FALSE`, as in the subtitle; the printed lines
  called a Pearson coefficient `rho`.

- [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md)
  and console
  [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)
  head each palette with a
  [`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md)
  rule, `"Set1 (9 colours, discrete)"`, instead of a `===` banner; so do
  the `pal_show_*()` wrappers.

- `check_system(show_warnings = TRUE)` emits one acquisition warning
  when a memory backend fails, preserving its cause without a duplicate
  warning.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  measures R heap bytes with `lobstr` or exact GC cell counts, removing
  the undeclared `pryr` dependency and rounded-MB fallback. Reports and
  warnings label binary memory units as GiB; existing `_gb` field names,
  thresholds and function arguments are retained.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  avoids repeated Windows CIM startup when `ps` can query live memory.
  Only static OS and CPU metadata are cached; memory is refreshed on
  every call, with fresh CIM queries retained if the native backend
  fails.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  obtains macOS memory through the optional `ps` backend, using
  available memory consistently instead of attempting Linux commands.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  fills missing Windows text fields independently, preserving valid CIM
  memory and metadata. A CPU query failure no longer discards OS
  information, and CSV parsing preserves version strings.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  handles unknown logical core counts while retaining known physical
  counts. On Linux, the optional `ps` backend distinguishes physical
  cores from hardware threads; without it the physical count is missing.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  validates memory totals and available memory on every backend,
  preventing negative, non-finite or out-of-range usage. Missing Linux
  cache fields use a conservative free-memory fallback.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  reports unavailable memory as scalar missing values when Windows
  queries return no results, while retaining the remaining diagnostics.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  matches complete Linux memory fields, so the fallback for missing
  `MemAvailable` does not mistake `SwapCached` for `Cached`.

- [`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md)
  reports library counts with
  [`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md),
  [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  and
  [`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md),
  highlighting the total and fitting long paths to the console. Table
  counts use comma thousands separators, matching the header. It returns
  the same data frame invisibly, retaining full paths and counts.

- The print helpers write no colour codes when standard output shows no
  colour, as when `Rscript x.R > log.txt` runs in a terminal.
  [`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md)
  and
  [`.cat_step()`](https://hui950319.github.io/UtilsR/reference/dot-cat_step.md)
  show text that cli cannot parse, such as data with braces, as written
  instead of failing. Without colour (knitted documents, log files)
  class labels read `<class>`, badges `[key: value]`, and
  [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  marks significance with stars, highlighted rows with `>` and missing
  text cells with `<NA>`.
  [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  shows an empty-string level as `""`.

- [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  gains `n` (20 rows by default, `NULL` for all) and `width` (the
  console width by default): it keeps the first and the P-value columns,
  adds the others while they fit, and counts the rows and names the
  columns left out in a grey footer. A column whose smallest non-zero
  value would round to zero gets enough decimals for two significant
  digits (`0.0003` printed as `0.00`).

- [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md) and
  [`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md)
  wrap long values at the console width under the value column, indent
  the lines of values with newlines the same way, and show at most 20
  items of a vector followed by its length.
  [`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md)
  wraps long notes with a `#` on every line, and
  [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  wraps long lines under the message text.
  [`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md)
  cuts a line longer than the console with an ellipsis, and
  [`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md)
  a title too long for its rule, which
  [`cli::rule()`](https://cli.r-lib.org/reference/rule.html) had cut
  without one.
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  describes object values by type and size, e.g. `<data.frame 6 x 11>`
  rather than `<data.frame>`.

- [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  previews the first values of atomic vectors
  (`<chr 3> "Age", "Sex", "Stage"`), marks a list left unopened at
  `max_depth` with an ellipsis, and gains `max_lines` (200 by default),
  past which a grey footer counts the rest.

- [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  gives few whole numbers one bar per value, so no empty bin falls
  between two values, and shows date and date-time columns as a
  histogram with their first and last dates instead of `<Date>`.

## UtilsR 0.6.9

- [`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md)
  collects counts before constructing its result, avoiding repeated
  data-frame copies while retaining library order and count semantics.

- [`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md)
  warns about missing, inaccessible or unreadable libraries and
  continues counting the others. Failed counts and the total are `NA`,
  so incomplete results cannot be mistaken for an empty library or a
  full total.

- `check_packages(refresh = TRUE)` reads installed-package counts from
  disk instead of cached metadata. The default keeps the existing cache
  behavior.

- [`check_packages()`](https://hui950319.github.io/UtilsR/reference/check_packages.md)
  replaces `count_packages_in_libpaths()` with the same per-library
  installed-package counts and total. The old name is removed.

- The report of
  [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  uses the print helpers: a class label with the time, one rule per
  group and the Chinese keys aligned by display width. It now goes to
  standard output, so
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) no longer
  hides it; wrap the call in
  [`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
  keep only the returned list.
  [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  with nothing selected says so in a grey note.
  [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  heads its table with a class label giving the variable count (green
  when nothing is missing) and reports empty input in grey notes. In the
  console, [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  heads each variable’s count and level listings and its overall tables
  with grey rules instead of `----` and `** **` lines; its cli headers,
  which knitr shows as messages, stay as they were.

- `fct_cat(ref_idx = 0)` is the same as `ref_idx = NULL`: nothing
  collapses, and another mode given alongside still runs. Only a single
  `0` means none; a `0` among indices is still out of range.

- New print helpers for S3 print methods.
  [`pr_head()`](https://hui950319.github.io/UtilsR/reference/pr_head.md)
  prints a class label on a solid background followed by a grey one-line
  summary.
  [`pr_kv()`](https://hui950319.github.io/UtilsR/reference/pr_kv.md)
  prints a key-value block, keys in grey and aligned by display width.
  [`pr_section()`](https://hui950319.github.io/UtilsR/reference/pr_section.md)
  prints a grey rule led by a bold title.
  [`pr_note()`](https://hui950319.github.io/UtilsR/reference/pr_note.md)
  prints a grey italic `# ...` line with cli inline markup, so
  `{.run pkg::fun(x)}` becomes a clickable link in consoles that support
  hyperlinks.
  [`pr_badge()`](https://hui950319.github.io/UtilsR/reference/pr_badge.md)
  returns two-part key-value badges (key on dark grey, value on a chosen
  colour) to combine on one line.
  [`pr_table()`](https://hui950319.github.io/UtilsR/reference/pr_table.md)
  prints a data frame as an aligned plain-text table: columns aligned by
  display width, P-value columns coloured by significance (bold red
  below 0.001, red below 0.05) and chosen rows highlighted.
  [`pr_tree()`](https://hui950319.github.io/UtilsR/reference/pr_tree.md)
  prints the structure of a nested result list as a tree with short grey
  descriptions such as `<tibble 12 x 7>`, listing extra attributes as
  well.
  [`pr_box()`](https://hui950319.github.io/UtilsR/reference/pr_box.md)
  frames key-value or plain lines in a rounded box with an optional
  header and footer in its border.
  [`pr_spark()`](https://hui950319.github.io/UtilsR/reference/pr_spark.md)
  prints one line per column: a sparkline of its distribution, a short
  summary and the missing share.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  takes its plot settings as
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)-style
  lists: `label_args`, `flow_args`, `stratum_args`, `facet_args` and
  `legend_args`. The standalone `label`, `gap` and `curve_type`
  arguments are removed; use `label_args$style`, `stratum_args$gap` and
  `flow_args$curve_type`. `label_args` also sets `min_pct` (leave small
  segments unlabelled), `pct_accuracy`, `size`, `color`, `box`, `fill`
  and `alpha`, and `style = "count_percent_wrap"` puts counts and
  percentages on separate lines.

- `plt_dist(type = "bar")` labels default to one line,
  `count (percent)`, in white boxes (previously `count\n(percent)` in
  boxes filled with the segment colour), and the y axis shows
  percentages. Bar and alluvial label counts use a comma as thousands
  separator.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  bar facets count only the facet values present in the data, so unused
  factor levels no longer stack the panels in one column. Alluvial label
  sizes scale with the base font size of `theme_use` like the bar and
  heatmap labels (unchanged at the default size 14).

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  gains `label_args$pct_accuracy`, accepts
  `label_args$style = "count_percent_wrap"` (group name above
  `count (percent)`), and writes counts with a comma as thousands
  separator.

- `plt_dist(type = "bar")` stacks the first fill category on top, in the
  order of the legend and of the alluvial strata (it was at the bottom).

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  converts labelled (`haven_labelled`) categories and facets with
  [`labelled::to_factor()`](https://larmarange.github.io/labelled/reference/to_factor.html),
  so plots, legends and named colours use the value labels instead of
  the numeric codes.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md),
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  and
  [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  share one internal helper for their list arguments, so a malformed
  list reports the plotting function (not `merge_args()`) as the source
  of the error, and
  [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  words a single unknown field in the singular.

## UtilsR 0.6.8

- New
  [`.cat_step()`](https://hui950319.github.io/UtilsR/reference/dot-cat_step.md)
  announces a numbered step (`[i/n]`) of a longer computation and marks
  it done with its elapsed time when the next step starts or the calling
  function returns. It wraps
  [`cli::cli_progress_step()`](https://cli.r-lib.org/reference/cli_progress_step.html)
  and honours `verbose`.

- [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  gains `style = "chip"`, which prints the timestamp in grey and colours
  only a short `INFO` / `DONE` / `WARN` / `FAIL` label, leaving the
  message text plain. The default `style = "full"` keeps the shaded
  line.

- [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  emits a cli message instead of
  [`cat()`](https://rdrr.io/r/base/cat.html) output, so
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) silences
  it (as it does
  [`set_wd()`](https://hui950319.github.io/UtilsR/reference/set_wd.md)’s
  notice). It still prints to standard output in interactive sessions
  and shows braces as typed.

- [`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
  [`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md)
  and
  [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md)
  print `type = "warning"` labels in black on the yellow background;
  white text had too little contrast there.

- `plt_dist(type = "alluvial")` removes categorical missing values
  before matching named colours, following the
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  missing-row rule.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  counts only observed facet/category combinations while preserving
  zero-count groups, avoiding the full cross-facet frequency table.

- The [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  variable summary tints rows by variable type: character, numeric or
  integer, and factor (including ordered) variables.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  retains only required input columns in its plot environment, keeping
  unused data out of serialized plot objects.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  rejects out-of-range facet and legend dimensions with a clear argument
  error before integer conversion.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  matches named colours to observed group names, ignoring unused names
  and rejecting incomplete or ambiguous named palettes.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  removes and reports rows with explicit NA factor levels or SPSS
  user-defined missing values in its required columns.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  treats plain numeric distribution and facet variables as categories in
  numeric ascending order in every plot mode. Existing factor orders,
  character ordering, named colours and missing-row rules are retained.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  calculates labels with the final stratum layout, so labels follow
  later axis changes. It no longer builds the plot in advance for
  labels.

- [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  keeps real groups named `.gap_1` or starting with `.gap_` distinct
  from its transparent gap strata, including their labels.

- When [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  finds no global `data` or `data_all`, its error names the data frames
  and Seurat objects in the global environment. Called without data, it
  reports that error directly again instead of as an unevaluable first
  argument.

- The [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  variable-summary subtitle says it counts variables with missing or
  Unknown/Blank/N/A values, rather than reading as a count of values.

- Seurat [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  cell statistics no longer list `orig.ident`, the sample identity, as a
  clustering.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) labels
  empty-string categories `(blank)` in its long count table and its
  default and grouped summaries, as its wide count table already did,
  unless a `(blank)` value exists and the two would merge.

- Two-variable `lv(count = )` tables skip the wide and row-percentage
  tables, with a message, when either variable has more than 100
  categories; a 5,000-category wide table previously took about 18
  seconds.

- `lv(group = )` rejects a grouping column with more than 100 distinct
  values or factor levels, pointing to `count` instead; a 5,000-value
  identifier used as the group previously took over a minute to
  tabulate.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  summarizes `POSIXlt` date-time columns in its frequency and grouped
  tables again instead of reporting them as list columns.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)’s
  `binary_ref` is renamed `ref_idx`, in the same place:
  `fct_cat(x, ref_idx = 1)` or `ref_idx = "No"`. `binary_ref` still
  works, with a deprecation warning, and giving both is an error.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  summarizes `difftime` columns as numbers in their own units and leaves
  list columns out of its frequency and grouped tables with a message;
  both previously made gtsummary fail.

- `count_packages_in_libpaths()` counts installed packages instead of
  all library subdirectories, excluding installation locks and unrelated
  folders.

- `lv(count = )` warns that it ignores selections in `...`, `pattern`
  and `group`, which it previously dropped silently.

- Suggested [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  filters write numbers and logicals as literals when their text reads
  back exactly, and mark truncation with a trailing comment instead of a
  literal `"..."` value. Factor value counts and filters omit unused
  levels, matching the frequency-table labels.

- Console [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  reports render the variable summary and frequency tables once, in
  their final group, instead of also rendering each beforehand; this
  saves about 40% of the printing time.

- [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md)
  queries Windows memory, OS, and CPU information with PowerShell CIM,
  retaining WMIC as a fallback for older environments.

- Grouped [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  summaries show missing group values as their own last group and
  include them in the overall column. They were previously dropped from
  both, while the reported group count still included them.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) inspects
  atomic vectors and matrices, returning them invisibly, instead of
  treating them as column selections of the global `data`, where
  `lv(1:2)` silently reported its first two columns. Bare column names
  and character vectors of column names still select from the default
  data, and an unevaluable first argument without default data reports
  its own error.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) leaves
  character and factor columns with more than 100 categories, such as
  identifiers, out of its frequency and grouped tables with a message;
  they stay in the variable summary. A 50,000-row identifier column
  previously took about four minutes to tabulate and now adds no table
  rows.

- [`PlotHeatmapJaccard()`](https://hui950319.github.io/UtilsR/reference/PlotHeatmapJaccard.md)
  excludes missing group labels and feature names from feature sets,
  preventing false overlaps, and reports missing groups clearly. Its
  default strip palette repeats beyond 16 groups instead of producing
  missing colours. Pairwise calculations reuse symmetry instead of
  computing both directions.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  highlights the category levels its special-value counts include, using
  the same whole-word rules, instead of separate substring matches that
  also coloured variable labels and missed markers such as “Not stated”.

- `fct_cat(binary_ref = )` also takes the reference levels by name:
  `fct_cat(x, binary_ref = "No")` keeps `"No"` and collapses the other
  levels to `"Oth"`, as `binary_ref = 2` does when `"No"` is the second
  level. An unknown name is an error. Integer indices work as before.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  summarizes entirely missing character columns in its default and
  grouped tables instead of failing in gtsummary formatting.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  summarizes date and date-time columns with more than ten distinct
  values instead of failing while truncating their suggested filter.

- [`PlotRankCor()`](https://hui950319.github.io/UtilsR/reference/PlotRankCor.md)
  keeps missing scores out of ranks and correlations, both in its
  default rank mode and when applying a rank transform to raw scores.
  Min-max and z-score scaling also retain missing values and handle
  sparse groups without failing or manufacturing complete observations.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  formats character intervals with vectorized dynamic precision,
  retaining detected precision and warnings while avoiding per-row
  templates.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  removes the minus sign from formatted zeros without changing other
  rounding or unparsed text. The mean/SD example now reflects its actual
  [`sprintf()`](https://rdrr.io/r/base/sprintf.html) rounding.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  preserves the names of `x` in numeric CI, mean/SD, and character
  modes, including missing observations and empty named vectors.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  leaves missing and whitespace-only strings unchanged without warning,
  including Unicode whitespace, while still reporting other text that
  cannot be parsed as an interval.

- Numeric
  [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  rows with missing components return genuine missing strings, including
  SPSS user-missing codes and entirely missing logical vectors, instead
  of embedding missing-value text or codes in the result.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  warns when reformatting drops trailing annotations such as a P-value.
  Ignoring trailing stars and a terminal period remains supported.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  returns `character(0)` for empty character input, matching its numeric
  modes and documented return type.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  rejects matrices, arrays, and unsupported numeric storage such as
  integer64 and time spans, avoiding silently flattened or misread
  values.

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  validates scalar integer precision before coercion or formatting in
  every mode and reports precision that exceeds the formatted-number
  limit.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) retains
  empty cross-tabulation categories in wide tables, displaying them as
  `(blank)` and disambiguating an existing category with that label.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  uses complete required rows in every mode and reports how many rows
  were removed. Unrelated missing columns are ignored; no usable rows
  produce an explicit error instead of an empty plot.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  consistently validates distinct column selectors, facets, and
  transparency across plot modes. Three-variable heatmaps now truly
  ignore `type`, as documented.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  shows a fill legend for unlabelled heatmaps and preserves custom
  visible legend positions; labelled tiles still hide the legend.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  maps named colours to categories in every mode, checks category
  coverage, and keeps unnamed palette positions for unused factor levels
  in bars and heatmaps. Shared colour resolvers are unchanged.

- Two-variable
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  cross-tabulations reuse one frequency table for the long counts, wide
  counts, and row percentages, retaining their output.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  rejects heatmap cells with multiple fill categories instead of hiding
  categories under overlapping tiles. Heatmap examples use one category
  per cell; repeated observations of that category remain valid.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  constructs suggested filters as R expressions, correctly escaping
  non-syntactic column names, quotes, backslashes, and line breaks in
  values.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  treats bar facet column names literally, including spaces, operators,
  and backticks, instead of parsing them as formula expressions.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  ignores unrelated dplyr groups and rowwise grouping when counting
  categories, so input grouping cannot split bars or labels.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) emits
  native knitr tables with their dependencies in documented
  `results = 'asis'` chunks, avoiding duplicated report tables and
  console listings while knitting. The data-inspection vignette uses
  that format.

- [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md)
  keeps bar counts, proportions, and labels separate from identically
  named input columns, preserving categories and plotted values.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) returns
  zero-row and zero-column inputs unchanged with a message, before
  report construction or temporary theme changes in every data-frame
  mode.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) supports
  renamed selections and keeps explicit empty selections empty,
  including selection of only the grouping column. Omitted selections
  still inspect all columns. Patterns are validated and warn when
  overriding unevaluated selections; input data and global-data
  shortcuts are preserved.

- Seurat [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  uses the same column-name resolution as data frames, including
  character variables and `group = TRUE`, and forwards resolved controls
  without collisions with metadata column names.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) resolves
  bare group/count columns before caller objects, accepts character
  names from enclosing functions, and rejects invalid or repeated names
  instead of silently switching to an ungrouped summary.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) restores
  the complete existing gtsummary theme after successful reports and
  after errors, instead of clearing it or leaving Compact active.

- [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) keeps
  cross-tabulation counts, percentages, and row totals separate from
  identically named input columns or categories, and counts only the
  requested variables when input carries dplyr grouping.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  excludes missing rows from combination grouping and returns
  immediately when every row is missing, retaining missing-value and
  observed-level semantics. Complete inputs keep their existing grouping
  path.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  documents group-wise factor-level merging in dplyr and shows how to
  retain a whole-data level order with the data-frame method.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  rejects matrix/array selectors and raw vectors explicitly rather than
  passing them to column indexing or factor conversion.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  recognizes an explicitly named data-frame `x` regardless of the order
  of named controls, while vector arguments retain their order.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  rejects ambiguous output names, including a default name matching
  several existing columns, before replacing any column.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  validates column-name shortcuts before selection and ignores names
  attached to selector vectors in both data-frame and data-mask calls,
  so duplicate columns cannot silently become a single input.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  copies data.table inputs before writing results and invalidates keys
  and indices affected by replacement, preventing incorrect grouping
  after a key column is overwritten.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  rejects impossible strict P-value bounds (`<0` and `>1`), including
  scientific notation, while retaining inclusive bounds and plain number
  formatting. Decimal text is checked before floating-point rounding can
  turn a tiny positive endpoint into zero or an endpoint below one into
  one.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  accepts Unicode whitespace around numeric text and after bound
  operators, including non-breaking and thin spaces copied from tables.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  avoids formatting missing values and existing bound labels, while
  retaining a direct path for complete numeric vectors.

- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  shares significance-map validation with
  [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md),
  including empty maps, empty symbols and duplicate thresholds; its
  default mapping continues to stop at `*` without a
  marginal-significance dot.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  checks decimal precision against the formatter’s output limit and
  returns empty vectors before allocating display thresholds.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  accepts entirely missing logical vectors in formatting and annotation
  paths, while continuing to reject observed logical values.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  displays signed zero like ordinary zero in P-value modes, retaining
  its significance symbol and the existing plain-number display.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  groups integer factor codes before sorting combinations and
  constructing labels, reducing repeated work when many rows share
  groups. Only observed combinations are retained, in the same
  factor-level order.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  errors when distinct input combinations produce the same label, rather
  than silently merging groups. Repeated identical combinations remain
  valid.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  propagates missing inputs to genuine missing results, including NaN
  and SPSS user-missing codes and ranges. The literal string `"NA"`
  remains a category. Class methods are registered for restored labelled
  and integer64 inputs before combining them.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  validates vector dimensions, separators, selected column names and
  output names. Unused arguments to the data-frame method now error
  instead of silently ignoring misspelled controls.

- [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md)
  ignores vector names when constructing labels and sorting levels,
  preventing columns such as `collapse` or `na.last` from changing the
  output length or level order in programmatic calls.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  matches significance thresholds across the vector rather than calling
  a function for each P-value, retaining all existing star cutoffs.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  preserves input names and returns character vectors for empty inputs
  in every mode. Matrix and array inputs now fail explicitly.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  validates significance maps consistently in formatting and annotation
  paths. Empty maps disable stars; empty symbols and first-match
  precedence for tied thresholds are retained.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  validates `digits` before integer conversion. Fractional, missing,
  nonfinite, non-scalar, and non-numeric values are rejected; zero
  decimal places are supported only in `plain` mode.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  rejects integer64, date, date-time, and time-span storage before
  formatting values or adding stars; convert these inputs explicitly.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  rejects nonfinite and out-of-range P-values in both formatting and
  annotation paths. Ordinary numbers in `plain` mode keep their range.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  retains missing values after appending stars, including missing text
  supplied with `add_star_p`. Missing P-values leave observed annotation
  text unchanged.

- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  preserves character P-value bounds without treating their endpoints as
  exact P-values or inferring significance stars. Malformed numeric
  strings now fail explicitly.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  shades size cells on a log scale of bytes, so objects ten or a hundred
  times smaller than the largest keep a visible color instead of
  appearing white. Size bars remain linear.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  warns when `pattern` overrides names or indices supplied in `...`,
  matching
  [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md).
  The ignored selection is still not evaluated.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  colors a single object, or several equally sized objects, in the full
  red of the largest size instead of the palette midpoint.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  gains `method = "lobstr"`, which sizes objects with
  `lobstr::obj_size()`: rows include captured environments and compact
  ALTREP sizes, and the total counts storage shared between objects
  once. The default `method = "object.size"` keeps the previous
  estimates. lobstr is suggested.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  gains `envir`, so objects in a function frame or any other environment
  can be inspected. It defaults to `.GlobalEnv`, keeping existing calls
  unchanged, and never searches parent environments.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  switches to the next unit when a label would round up to 1024, showing
  `1.00 MB` or `1.00 GB` instead of `1024.00 KB` or `1024.00 MB`.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  lists equally sized objects alphabetically for names and indices too,
  matching `pattern` and the default selection instead of following the
  order in which objects were supplied.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  adds a source note stating that sizes are
  [`object.size()`](https://rdrr.io/r/utils/object.size.html) estimates,
  so the table itself warns that totals can double-count shared storage
  and that environments and closures may be underestimated.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  renders its summary label as bold `TOTAL` instead of showing literal
  asterisks; the underlying data still label the row `**TOTAL**`.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  warns when a top-level call passes an unquoted numeric variable, which
  is used as object indices rather than as the variable’s name.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  includes each binding’s original error message in its combined
  read-failure warning without evaluating failed bindings again.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  uses a neutral white size gradient for all-zero estimates, avoiding
  the misleading midpoint color of a zero-width domain.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  sorts only names matched by `pattern`, avoiding a full global name
  sort while preserving alphabetical order among equally sized objects.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) also
  count “Blanks”, “Unknowns”, “Not applicable”, “Not stated”, “Not
  reported”, “NULL” and values made only of `?`, `-` or `.` as special
  values. The new `check_na(special = )` argument replaces the built-in
  markers with user-supplied regular expressions, and
  `special = character(0)` turns special-value counting off.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  returns its gt table visibly instead of printing it and returning the
  input data invisibly, so the table renders in R Markdown, Quarto and
  pkgdown and can be saved with
  [`gt::gtsave()`](https://gt.rstudio.com/reference/gtsave.html). Calls
  that produce no table return `NULL` invisibly. Code that piped the
  returned data onward needs updating.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  warns when `pattern` overrides a selection in `...`, and reports an
  invalid `pattern` regular expression with a clear error.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  adds a source note explaining its severity shading and documents the
  thresholds and the denominator of its summary percentages.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) count
  special values about three to five times faster on columns with many
  distinct values, normalizing only values that contain whitespace and
  matching markers caselessly. A dotted capital I (U+0130) no longer
  folds to `"i"` when matching markers.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  shades special-value cells from light to dark blue as their share
  rises, so the highest severity is no longer the palest.

- The package description now names the exported
  [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  function correctly.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  displays small positive proportions as `<0.1%` in cells and `<0.01%`
  in summaries, distinguishing them from exact zeros.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) skip
  unused factor levels when matching special-value markers, preserving
  counts and the original factor levels.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  avoids integer overflow in dataset-size calculations and count
  formatting, including summaries with more than 2^31 - 1 data points or
  issues.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  scales object bars to the largest individual estimate instead of the
  total, keeping large selections readable and capping the total bar.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) load
  missing-value methods for serialized labelled and integer64 columns,
  preventing session-dependent errors or missed NA values.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  skips global name enumeration for explicit character selectors, while
  retaining sorted numeric indices and pattern selection.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  identifies its summary by row position, so an object named `**TOTAL**`
  retains the normal object styles and size gradient.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  formats bars from raw sizes, respects later gt formatters, and keeps
  HTML bars out of LaTeX, RTF and Word output.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  documents the limits of summed object-size estimates and the
  evaluation of active bindings and promises, with self-contained
  examples.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  colors the visible size cells and uses consistent byte-to-GB labels in
  both the table and subtitle, keeping tiny objects distinct from zero.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  reads each selected binding once, so size and class describe the same
  value even when an active binding changes between reads.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  labels affected-variable counts explicitly in its subtitle,
  distinguishing them from the individual-value counts in the summary.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  consistently returns a renderable gt table for empty selections,
  reports unreadable objects, and counts only successfully inspected
  objects.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  validates `pattern` as `NULL` or one non-missing character string,
  with clear errors for invalid inputs. Empty patterns still match all
  columns.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  validates object names, indices and regular expressions, deduplicates
  selections, and never expands unmatched selections or searches parent
  environments for missing objects.

- [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)
  renders its size bars directly in HTML, avoiding per-object plots and
  temporary SVG files while handling zero-sized objects.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  rounds percentages only for display and uses unrounded values for
  severity colors, correcting double rounding and threshold
  misclassification.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  preserve class-specific missing-value semantics when counting special
  values, so SPSS user-missing codes are not counted twice.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) use
  Unicode-aware word boundaries and whitespace normalization, avoiding
  false matches within accented words and recognizing non-breaking
  spaces and other Unicode blanks.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  constructs its summary in one operation, reducing overhead on wide
  datasets while preserving counts, ordering, formatting and table
  styles.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)
  recognize whitespace-only blanks and markers with repeated spaces,
  tabs or newlines. Matching still runs on distinct values, counts each
  value once, and keeps actual `NA` values separate.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  rejects ambiguous column names, multidimensional selected columns, and
  invalid `show_all` values with informative errors, preventing
  duplicated counts and missingness percentages above 100% for matrix
  columns.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  returns empty inputs unchanged with an informational message, avoiding
  undefined percentages and empty-table errors.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  supports renamed selections, inspects all columns by default for
  grouped inputs, and no longer expands unmatched selections or patterns
  to the full dataset. Explicit selections inspect the chosen columns
  across all rows.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  preserves the complete input and its attributes when inspecting
  selected columns, including calls where the selected columns have no
  issues.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  documents and demonstrates reduced bin counts after quantile ties,
  merged factor levels from repeated labels, and the handling of
  infinite data in fixed-cut and automatic binning modes. These
  behaviors are unchanged.

- `fct_num(type = "equal")` computes plain numeric ranges without
  concatenating or filtering the full vector, reducing allocations while
  retaining cut points, missing values, and class-specific range
  methods.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  rejects time-span objects supplied as `nbins`, preventing their
  conversion to seconds from silently requesting a different number of
  bins. Valid numeric and `integer64` bin counts retain their existing
  behavior.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  documents that automatic fixed-cut labels follow numeric formatting
  options such as `scipen`, and shows explicit labels for stable factor
  levels.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  constructs fixed-cut interval labels in one vectorized operation,
  reducing overhead when many cut points are supplied while preserving
  labels and interval order.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  avoids full-vector missing-value masks and redundant filtering for
  ordinary complete numeric data, and skips unused quantile names.
  Classed-vector dispatch, missing values, and group boundaries are
  preserved.

- `fct_num(type = "equal")` reports when numeric precision produces
  repeated cut points, with guidance to reduce the bin count or supply
  explicit cut points. It does not merge bins or move their boundaries.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  rejects logical labels before computing cut points, so
  `labels = FALSE` cannot return integer codes when quantile ties leave
  one group.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  rejects matrices and arrays instead of silently flattening
  multidimensional data into a factor vector.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  rejects `Duration`, `Period`, and `Interval` data and cut points
  before using their numeric storage. Convert them to explicitly chosen
  numeric units first to avoid incorrect ranges or ignored time
  components.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  rejects SPSS user-missing data and cut points with a message to
  normalize them first, preventing missing codes from entering valid
  groups or influencing automatic cut points.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  reuses integer bin codes for ordinary numeric data and unique text
  labels, reducing factor-construction allocations. Classed inputs and
  nonstandard labels retain the existing
  [`cut()`](https://rdrr.io/r/base/cut.html) path and group semantics.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  reports constant data explicitly in both automatic binning modes,
  without misleading zero-bin warnings or label-length errors. Fixed-cut
  behavior and right-closed group boundaries are unchanged.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  validates `nbins` before conversion, rejecting fractional, missing,
  non-scalar, non-numeric, or overflowing counts without coercion
  warnings or silently changing the requested number of bins.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  increases automatic label precision only when cut-point text collides,
  preventing nearby numeric intervals from merging into one level.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  validates fixed cut points before sorting, rejecting missing,
  non-finite, duplicate, or non-numeric values instead of silently
  changing groups or assigning misleading labels.

- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  rejects unsupported `integer64` data and cut points instead of
  silently misclassifying their values or losing missing observations.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  reuses matched level positions when recoding and keeps unmatched
  levels in a vector, avoiding an intermediate list and repeated
  membership tables for factors with many levels.

- `fct_cat(new_labels = ...)` returns the original factor when
  normalized, non-missing labels are unchanged, avoiding an unnecessary
  observation copy.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  clears obsolete
  [`stats::reorder()`](https://rdrr.io/r/stats/reorder.factor.html)
  scores after changing levels or recode mappings. Operations that leave
  both unchanged retain the scores and other metadata.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  rejects reorder calls that mix character levels and numeric positions.
  Numeric arguments are normalized separately before combining,
  including calls that mix native numbers and classed numeric indices.

- [`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md)
  delegates index checks to
  [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md),
  avoiding a warning for empty groups and an unrelated `if` error for
  missing indices.

- `fct_cat(binary_ref = ...)` requires at least one reference index
  instead of silently putting every observed level into `"Oth"` for an
  empty input.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  validates replacement labels after character conversion. Classed
  character labels can no longer bypass merging or missing-label
  removal, and conversions that change the label count are rejected.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  ignores names attached to a reorder vector. A named vector that leaves
  the level order unchanged preserves the original contrasts and
  model-matrix encoding.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  normalizes numeric indices after validating their values and bounds.
  Classed indices such as
  [`bit64::integer64`](https://bit64.r-lib.org/reference/bit64-package.html)
  now select the intended levels in recoding, grouping, reordering and
  binary conversion.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  returns the original factor when reordering leaves its levels
  unchanged, avoiding a full-length allocation for an unchanged order,
  empty factors and one-level reversals.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  checks old recode levels in one batch instead of rebuilding a
  membership table for every group, reducing time and allocation when
  there are many levels and groups.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  determines used output groups from the original level counts and
  constructs recoded observations once, combining regrouping and
  unused-level removal without an intermediate full-length factor.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  indexes level maps with factor codes directly, removing an extra
  full-length integer copy during reordering and unused-level removal.

- `fct_cat(new_labels = ...)` and
  [`fct_label()`](https://hui950319.github.io/UtilsR/reference/fct_label.md)
  reject lists and other non-atomic label containers instead of
  interpreting them as grouping instructions. Atomic numeric labels
  remain supported.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  clears matrix-valued contrasts when the output levels change,
  preventing stale contrast rows and redundant model-matrix columns
  after regrouping. Names, labels and contrast function names remain
  preserved.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  remaps integer factor codes when changing level order or dropping
  unused levels, avoiding character conversion and rebuilding. Unique,
  non-missing replacement labels use a direct levels update; duplicate
  and missing labels retain their existing merging semantics.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  preserves factor names, class and metadata such as `label` across
  recoding and reordering. An explicit `NA` level remains distinct from
  missing codes; recoding still removes unused levels.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  validates scalar logical flags, finite integer indices, non-empty
  group names, duplicate reorder levels and unknown recode levels.
  Recode groups can mix index-based and label-based specifications; each
  group is resolved before checking for overlapping old levels.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  includes non-empty `...` in its mode exclusivity check, instead of
  silently ignoring recode or reorder arguments when another mode is
  active.

- `fct_cat(binary_ref = ...)` rejects a reference label of `"Oth"` when
  other levels remain, instead of silently merging both binary groups.

- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  and
  [`fct_to_group()`](https://hui950319.github.io/UtilsR/reference/fct_to_group.md)
  correctly merge into an existing, unmatched level; that level’s name
  no longer overwrites the mapping and turns the recoded observations
  into missing values.

- [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md),
  [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md),
  [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md),
  [`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)
  and
  [`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)
  gain `save`, and
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  and
  [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  stop saving at `RegR::save_plt()`’s generic 10 x 11 in: a `save` list
  that leaves out `width` or `height` writes the page the plot is laid
  out for, with room for its levels, variables or panels beside the
  measured axis text and legends. Every call prints that size with a
  pasteable `save` line and the plot carries it as
  `attr(p, "plot_size")`; a supplied dimension is kept. The size and the
  saving need RegR 0.1.3 or later. `plt_upset(output = "all")` saves the
  combined plot and `output = "data"` refuses a `save`;
  `plt_con(combine = FALSE)` refuses one too. A `split.by` figure of
  [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md)
  or
  [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)
  is reported once, not per panel.

- `fmt_axisTile(mode = "tile")` returns a ggplot for a ggplot, and a
  list of ggplots for a list of them; it wrapped each one in a
  patchwork, which drew the same color strip but changed the object’s
  class.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)’s
  `text_size`, `text_face`, `text_angle` and `text_color` default to
  `NULL`, which keeps the plot’s own axis text style. They were 9,
  `"plain"`, 45 degrees on the x axis and `"black"`, so even
  `mode = "text"`, meant only to color the labels, made them smaller,
  black and rotated. Pass `text_angle = 45` for the earlier rotated
  labels.

- [`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md)’s
  default `"ggrastr"` backend draws each raster after an empty opaque
  polygon, as the `"ragg"` and `"image"` backends do:
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) painted points drawn
  after a translucent grob, such as text with `alpha = 0.3`, with that
  transparency. A repeated call rasterizes a layer once, at the latest
  `dpi`.

- [`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md)
  applies `scale_y_list` and `scale_x_list` with
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md).
  Each panel keeps its scale type, so a discrete or date axis no longer
  fails with “Discrete value supplied to a continuous scale”, and an
  existing scale keeps the settings the list does not name: a
  [`scale_y_log10()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
  used to turn linear, with a “Scale for y is already present” message
  for every panel.

- [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  no longer has an unused `...`: a misspelled or unsupported argument,
  such as `fmt_strip_list`, is an “unused argument” error instead of
  being ignored without notice.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  warns when a plot’s coordinate system has `expand = FALSE`, which
  makes ggplot2 ignore the scale expansion it sets.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  labels use the font family of each plot’s theme (its `plot.tag`
  element), as patchwork tags do. Outside labels always used the device
  font, and inside labels did too with ggpp before 0.6.0 (Windows R has
  0.5.8.1), so a `theme_bw(base_family = "serif")` figure got sans-serif
  tags. A `family` passed in `...` still wins for inside labels.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  keeps a `legend.justification` or `legend.justification.inside` passed
  through `...`; the justification derived from `legend.position`
  replaced it (causalR’s balance plot set it again after the call).

- `fmt_legend(legend.position = c(x, y))` centres the legend on a
  coordinate of exactly 0.5: `c(0.5, 0.95)` put the legend’s left edge
  on the panel’s centre line, so a “top centre” legend sat right of
  centre. Other coordinates and the corner codes keep their
  justification.

- [`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)
  sets a patchwork’s `axis_titles` only when `xlab` or `ylab` is
  supplied. Changing only a title, a caption or text styles merged the
  axis titles too and replaced an existing `"keep"`. A misspelt
  `axis_titles` is still rejected.

- An empty string now removes a title without leaving space, as
  documented: `fmt_text(title = "", xlab = "", ...)` (also `ylab`,
  `subtitle` and `caption`) kept an empty title row of about 6 mm and an
  empty axis title row of about 5 mm, and `fmt_legend(title = "")` kept
  about 5.6 mm above the keys.

- `fmt_text(axis_title_size, axis_title_face, axis_title_color)` also
  reach axis title sides that set the same field themselves. A theme
  with an explicit `axis.title.x` size, as several RegR plots use, kept
  that size and ignored the requested one. Blank sides stay blank.

- [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  and
  [`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md)
  format each plot of a plain list and return the list. A list gave
  `NULL`, because patchwork’s `&` falls back to `+` for anything but a
  patchwork; a list holding a non-plot is an error.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  warns when `plot_dims` differs from the layout of a patchwork without
  nested patchworks. Such a patchwork’s own layout decides which axes
  are hidden, so `plot_dims = c(4, 1)` on a 2 x 2 grid was silently
  treated as `c(2, 2)`. The help also points to
  `patchwork::plot_layout(axes = "collect")`, which removes only
  identical axes.

- [`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)
  styles rich text elements in place: a title or axis title set with
  `ggtext::element_markdown()` in the plot or global theme keeps its
  class and settings, where styling it failed with “Only elements of the
  same class can be merged”.

- `fmt_text(legend_title = )` titles legends as `fmt_legend(title = )`
  does. A continuous colour bar stays a colour bar instead of becoming a
  key legend, guide settings such as `ncol` and `reverse` are kept,
  linewidth legends are titled too, a vector sets one title per plot
  instead of failing, and ggplot2 4.0 no longer reports unknown labels
  or duplicated aesthetics.

- [`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)
  formats the data plots of nested patchworks and skips spacers, guide
  areas and inset overlays, as the other formatters do. Per-plot labels
  no longer land on a spacer or the wrong plot, the first plot of a
  nested layout is no longer left out, and a title added after an
  outside
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  label is drawn once instead of twice (or not at all in a list).

- The help pages of
  [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  and
  [`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md)
  show links and code formatting instead of raw Markdown such as
  `[fmt_axis()]` and `**every**`.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  warns once, when the plot is drawn, if no name in `colors` matches the
  axis values; a misspelled or wrongly cased name gave grey tiles or
  plain labels without notice. Axes with free facet scales are not
  checked.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  gives an updated scale its own copy of the secondary axis. The copy
  shared the input plot’s axis, and ggplot2 fills a
  [`dup_axis()`](https://ggplot2.tidyverse.org/reference/sec_axis.html)’s
  derived breaks and labels when a plot is drawn: drawing the result
  gave the input plot’s secondary axis the result’s breaks.

- `fmt_raster(method = "ggrastr")`, the default, rasterizes only point
  and tile layers, as
  [`ggrastr::rasterise()`](https://rdrr.io/pkg/ggrastr/man/rasterise.html)
  does by default. Lines, bars and polygons stay vector: as images they
  made a PDF larger (a 6-facet scatter with a smooth and a reference
  line: 103 KB, now 31 KB; 13 KB as vectors). A plot without such layers
  no longer warns about disabled clipping.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  no longer keeps its call frame in the plots it returns. Each call on a
  faceted plot stored further copies of the input plots and their data:
  a 21 MB plot relabelled three times serialized to 90 MB, now 22 MB.
  [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  did the same for panels holding a native single-panel facet.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  keeps displayed grids visible. Without `grid_color`, a grid drawn in
  the panel background colour, such as
  [`theme_gray()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)’s
  white grid with `bg = "white"`, becomes `"grey70"`; before, only
  restored grids were checked. Grids restored under a blank root `line`
  ([`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html))
  are `"grey85"` instead of the root line’s black.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  with `label = NULL` keeps the labels of a faceted plot and changes
  only the strip style. It renamed every panel `Figure1`, so
  `fmt_strip(p, label_fill = "steelblue")` lost the facet levels.
  Unfaceted plots are still labelled `Figure1`, `Figure2`, etc.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  matches named labels of a faceted plot to its facet levels:
  `c("8" = "Eight", "4" = "Four")` labelled the 4-cylinder panel
  “Eight”. Unnamed levels keep their label. Unnamed labels whose number
  is neither one nor the number of levels, and names matching no level,
  now give a warning instead of being recycled or dropped silently.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  with `label_fill` keeps the theme’s strip border on faceted plots, as
  it already did on unfaceted ones; it drew a black border, so one
  figure could mix framed and unframed strips. On themes without a strip
  background, such as
  [`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
  neither draws a border.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)’s
  `label_color` defaults to `"auto"`: each header uses black or white
  text, whichever contrasts more with its fill. Black bold text on the
  darkest generated grey (`"#636363"`, used with one column or three or
  more) had a contrast of 3.5:1; it is now white. Pass
  `label_color = "black"` for the earlier text.

- `fmt_panel(grid = "keep")` leaves the grid lines as they are, so the
  border or background can be changed alone; any other call removed or
  reset the grid, as the default `grid = "none"` still does.

- [`fmt_flatten()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  given `axes` without `axis_titles` drops the input’s `axis_titles` as
  well, so axis titles follow `axes` as in
  [`wrap_plots()`](https://patchwork.data-imaginist.com/reference/wrap_plots.html)
  instead of staying collected.

- [`fmt_flatten()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  errors name
  [`fmt_flatten()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  (or
  [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md))
  rather than an internal helper and report the class of an unsupported
  element, without descending into list-based objects such as data
  frames or gt tables.

- [`fmt_flatten()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  is the new name of
  [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md),
  so it is found with the other `fmt_*` formatters.
  [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  remains as the same function without a deprecation warning.

- `fmt_raster(method = "image")` takes any figure that draws itself:
  grobs, recorded base plots (replayed) and classed objects with a print
  method, such as `RegR::plt_eff2()`’s forestplot, which it rejected as
  a list of non-ggplot objects. Only a plain list holds several plots.

- `fmt_raster(method = "ragg")` and `method = "image"` leave the random
  stream where it was: ragg before 1.5.1 drew from it to name each
  capture device, so a later random step gave other results than without
  the raster.

- `fmt_raster(method = "ragg")` and `method = "image"` rasters are drawn
  opaque by [`pdf()`](https://rdrr.io/r/grDevices/pdf.html), which
  painted a raster with the transparency of the translucent grob drawn
  before it.

- `fmt_raster(method = "ragg")` keeps the panel’s background grid and
  border vector and drops empty grobs, so they no longer add whole-panel
  images; a 200,000-point facetted plot written with
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) is about 40% smaller.

- `fmt_raster(method = "image")` has no plot margins, so at its own size
  the image is drawn pixel for pixel instead of shrunk to about 95%.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  releases temporary construction bindings after native layer creation,
  avoiding an extra serialized data copy while retaining deferred
  callbacks, formulas, position objects and symbolic constructor calls.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  combines source mappings with explicit fixed summary arguments when
  resolving independent identity overlays, including partial summaries
  and horizontal boxplots.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  retains precomputed outlier mappings for independent identity overlays
  when outlier shape is explicit, including an explicit NULL. Default
  suppression and explicit `outliers = FALSE` remain unchanged.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  snapshots inherited position settings as well as local settings, so
  edits to a supplied position or its parent do not alter overlays.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  retains raw source positions when staged mappings are nested inside
  arithmetic or function calls, preserving their environments and axes.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  constructs returned layers in an isolated environment and stores
  symbolic argument calls, avoiding retention of the source-resolution
  workspace and duplicate data in layer constructor calls.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  copies explicit position objects and their settings per plot leaf,
  preventing variable-width adjustment and later edits from changing the
  caller’s position, existing layers or sibling overlays.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  retains source notch boundaries and relative width mappings for
  independent identity-statistic overlays when those features are
  requested, including horizontal summaries and layer-level overrides.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  accepts anonymous and environment-selected function calls in automatic
  position mappings without failing during evaluation-stage lookup.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  formats plot leaves in one traversal and skips source lookup when
  independent data and complete mappings are explicit, preserving
  deferred callbacks, nested layouts and input validation.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  resolves complete vertical or horizontal summary mappings
  automatically for independent identity-statistic overlays, retaining
  source groups and deferred data callbacks while leaving explicit
  mappings unchanged.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  retains explicit `NULL` controls, including width and alpha, instead
  of replacing them with wrapper defaults. Omitted controls retain their
  existing defaults and explicit values follow native validation.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  copies raw positions from staged source mappings while omitting
  computed-statistic and after-scale positions in independent overlays.
  Explicit boxplot mappings keep their evaluation stages and
  environments.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  skips unused factor strata during sampling, avoiding empty per-group
  work and matrix-column subsets while retaining data factor levels,
  missing groups, sampling order and column attributes.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  normalizes `pch` and point/jitter `cex` aliases before applying
  omitted defaults. Explicit shape/size arguments retain priority, and
  beeswarm `cex` keeps its existing layout meaning and argument-list
  precedence.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  snapshots supplied position objects and inherited settings per plot
  leaf, isolating edits to sibling overlays and caller-owned positions.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  samples mappings with anonymous or dynamically selected functions
  without failing when the call has no static function name.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  accepts external factor levels and labels during sampling, including
  positional configuration arguments and ordered factors. External row
  vectors in the factor input still require columns in layer data.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  constructs point, beeswarm and rasterized layers in isolated
  environments, so extracted plot leaves do not retain unrelated input
  plots. Layer constructor calls keep symbolic arguments instead of
  embedding data.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  retains missing character shapes during white-border normalization
  instead of failing before ggplot2 handles missing points.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  samples indices before slicing matrix-column data, avoiding full-data
  group copies while retaining native binding and matrix attributes.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  samples joint discrete colour/fill strata and existing facets;
  explicit groups retain priority, and layers missing facet columns
  still replicate.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  respects explicit point/jitter positions supplied through `...`,
  including position objects and native position names.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  diagnoses fixed aesthetic vectors and external row-vector mappings
  before sampling, with instructions to map columns in layer data.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  uses exact parameter lookups, preventing ignored geom arguments from
  partially matching inheritance, shape, colour or fill controls.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  resolves dodge groups from built layer data, so continuous or NULL
  aesthetics retain plain jitter widths and data callbacks remain
  deferred.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  supports group-only jitter-dodge on ggplot2 3.5.x without adding
  visible aesthetics or changing ggplot2 4.x positioning.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  samples rows independently of hidden dplyr grouping attributes;
  rowwise and grouped inputs follow the same aesthetic-based sample
  limits.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  distinguishes ordinary columns named `stage`, `after_stat`,
  `after_scale` or `from_theme` from delayed aesthetic function calls.

- `fmt_point(white_border = TRUE)` keeps non-fillable symbols visible
  using a white underlay, and handles named shapes and an explicit NULL
  shape.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  uses the raw `start` expression of staged aesthetics for stratified
  sampling while retaining later colour transformations.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  samples row indices before slicing grouped data, reducing copying
  while preserving row order and random selections. Matrix columns
  retain the existing path; single-column data frames keep their
  dimensions.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  validates sample sizes, seeds and layout controls consistently,
  rejects malformed jitter options and incompatible grouping lengths,
  and accepts `NULL` jitter dimensions for ggplot2’s native defaults.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  forwards supported `beeswarm.args` options such as `priority` and
  `side`, and rejects unknown, duplicate or unnamed options.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  includes explicit and layer-local groups in automatic dodging and
  ignores parent mappings when `inherit.aes = FALSE`.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  respects layer-local mappings and `inherit.aes` when sampling and
  styling points. Explicit `shape`/`size` values override mappings,
  while omitted values retain the mapped aesthetics.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  supports sampling function/formula data after the callback runs at
  build time. Sampling callbacks do not capture unrelated plots or data.

- `fmt_point(white_border = TRUE)` retains scaled group colours and
  existing fills, treats `color` and `colour` consistently, and supports
  mapped shapes and shape 25 without replacing the original plot’s
  scales.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  adds independent point layers to every nested patchwork leaf while
  preserving layout, annotations, spacers and the original plots.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  samples expression-based groups, retains missing groups, and
  prioritizes explicit groups over discrete colour/fill mappings.
  Continuous colour/fill values no longer create one sampling group per
  distinct value.

- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  preserves the caller’s random-number state when sampling, including
  calls that keep all rows and sessions without an existing seed.

- [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  and [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) count
  a special value (“unknown”, “blank”, “n/a”, “na”, “missing”,
  “unspecified”, “not available” or an empty string) only as a whole
  word and once per value. “Regional”, “Canada”, “anaplastic” or “NACT”
  no longer count through “na”, and “Unknown/unstaged/unspecified”
  counts once instead of twice. Matching runs on the distinct values,
  which makes
  [`check_na()`](https://hui950319.github.io/UtilsR/reference/check_na.md)
  about ten times and
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md) about a
  third faster on a 257,000-row SEER table.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  keeps batching with scalar `na.rm` and `lineend` arguments while
  retaining native rendering, missing-value warnings and fallback for
  other args.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  creates separate reference layers for each subplot, so subsequent
  edits to one subplot’s reference data or styles do not alter its
  peers.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  uses native per-line layers when facet expressions reference its
  helper-column prefix, preserving panels without evaluating data
  callbacks.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  constructs self-contained reference mappings and layers, avoiding
  retention of peer plots and their data when a formatted subplot is
  extracted.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  uses factor color labels consistently in batched and native layers,
  preserving numeric palette indices, missing colors and encoded
  transparency.

- Dedicated
  [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  regression tests cover native rendering, transformed and non-numeric
  positions, nested containers, input preservation and deferred data.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  gives argument-specific errors for empty and non-vector line styles
  when positions are supplied. Unused styles, native missing-value
  semantics, date positions and discrete category labels are retained.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  rejects `colour` with a suggestion to use its `color` parameter,
  avoiding duplicate aesthetics and silently ignored colour requests.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  batches reference lines by direction, retaining per-line styles, facet
  replication and existing colour scales. Other geom arguments keep the
  native per-line path for compatibility.

- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  rejects geom intercept argument names with a clear suggestion to use
  `x` and `y`. The formatting vignette now uses those supported
  arguments.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  aligns independent overlays with scalar fixed source x or y positions
  by mapping those constants before computing statistics. Explicit
  boxplot positions and cleared mappings retain priority; fixed vectors
  are not copied and data callbacks remain deferred.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  tries range-only blank layers after ordinary sample layers, retaining
  blank-only sources and documenting explicit source selection when
  point annotations share a plot with sample points.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  supports independent vector mappings without an explicit data frame
  while retaining their environments and deferred evaluation.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  retains the first single-axis source instead of replacing it with
  later two-axis layers in independent overlays.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  preserves the mapping-source order when explicit data are supplied,
  avoiding unused parent columns in independent overlays.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  matches data, mapping and stat argument names exactly, preventing
  unrecognized names from changing samples or statistics while retaining
  native geom validation and warnings.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  preserves explicit summary mappings for identity statistics,
  supporting vertical and horizontal precomputed boxplots without
  injecting unrelated raw-data axes. Data callbacks remain deferred.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  selects data and position mappings actually used by existing layers
  before unused parent settings, avoiding incompatible or empty parent
  samples. Automatic empty data frames are skipped; explicit empty data
  and deferred callbacks retain their normal behaviour.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  skips text, label, segment, curve and reference-line layers when
  selecting samples automatically, preserving valid single-axis sources
  instead of replacing them with annotation coordinates.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  preserves explicitly cleared x or y mappings in independent overlays,
  including cleared mappings inherited from an existing source layer.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  rejects malformed argument lists, invalid inheritance flags,
  non-aesthetic mappings and non-plot gg components with clear input
  errors.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  honours explicitly supplied outlier shapes, including `NULL`, while
  retaining hidden outlier markers as the default.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  formats every leaf of nested patchworks while preserving layouts,
  annotations, plot-list names and non-plot placeholders or overlays.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  resolves independent overlays from existing layer data and position
  mappings, preserving deferred evaluation and single-axis boxplots.
  Missing sources now give a clear error instead of enabling
  inheritance.

- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  retains explicit data, mappings and deferred data callbacks in
  independent layers, filling only missing position mappings from the
  plot.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  lets restored grid placeholders inherit blank parent-grid settings
  during and after formatting, preserving explicit blank-inheritance
  overrides and the restoration of grids hidden by a blank root line.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  gives automatically restored grids contrasting colours when a blank
  root line hides them, including on dark panels with
  [`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
  while preserving explicit colours and transparent backgrounds.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  retains empty themes in its batch cache on older ggplot2 versions,
  keeping batch grid output identical to formatting plots individually.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  reuses a recent additional theme in batches, including after the
  four-theme cache stops scanning, avoiding repeated grid resolution
  when later plots share a theme.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  checks automatically restored grid contrast against the colour of
  transparent panel fills composited over a known opaque plot
  background, preserving background transparency and explicit grid
  colours.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  rejects themes, aesthetic mappings and other non-plot `gg` components
  instead of returning a theme or silently producing `NULL`.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  corrects matching background colours in automatically restored major,
  minor and axis-specific grids while preserving explicit plot styles.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  follows binned position mappings before and after statistics, matching
  native distribution counts and geometry while preserving original
  points, axes and unscaled mappings.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  delegates unscaled distributions without an x scale to native ggplot2
  statistics, retaining supported histograms instead of returning empty
  layers.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  preserves final
  [`after_scale()`](https://ggplot2.tidyverse.org/reference/aes_eval.html)
  x mappings without evaluating them again, keeping distribution
  positions aligned with native layers.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  normalizes time-difference samples to numeric positions while
  retaining their units, preventing empty histogram and density
  overlays.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  retains the original panel’s resolved x limits when computing
  distributions, including function, formula and partial limits.
  Automatic density grids also cover the original scale range,
  preserving visible tails for externally supplied samples without
  retraining the original axes.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  preserves unscaled [`I()`](https://rdrr.io/r/base/AsIs.html) x
  mappings, preventing repeated transformations and scale-limit
  censoring of their distribution samples.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  skips inapplicable layer data when resolving distribution samples,
  including annotations and data frames missing an explicit variable.
  Function and formula data retain their deferred evaluation.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  transforms continuous distribution samples once using each panel’s
  final x scale, avoiding redundant transformations while retaining
  original axes and externally supplied samples.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  rejects unsupported coordinates added after formatting during plot
  building, with the same clear error as coordinates supplied initially.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  documents standard facet matching for external data, including
  repeated samples and newly introduced panels, and adds a
  deferred-facet example.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  identifies its own distribution layers without reserving a mapped
  aesthetic name, preserving unrelated fields with matching names.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  evaluates each distribution layer’s x mapping once per build and
  reuses the evaluated values for its statistics.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  preserves individual facet scales, including scales added after
  formatting, and avoids applying their position transformations twice.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  anchors default overlays to the display bottom when Cartesian
  coordinates reverse the vertical direction.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  retains distribution layers and their individual settings when a facet
  is added or replaced after formatting.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  preserves the plot when a density panel has fewer than two samples or
  a distribution layer has no finite samples.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  defers overlay scaling to the normal plot build, avoiding an extra
  evaluation of original statistics and data callbacks. Overlay heights
  follow later axis changes and repeated calls keep their individual
  settings.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  validates overlay controls and documents their defaults, units,
  mode-specific effects and supported mappings with runnable simulated
  examples.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  resolves layer data and preserves x-mapping expressions and their
  environments, including `.data` and `.env` pronouns.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  traverses nested patchworks recursively while preserving layouts,
  annotations, spacers, wrapped grobs and plot-list names.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  uses independent distribution mappings, avoiding inherited groups,
  weights and missing aesthetics in externally supplied data.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  scales each facet independently and keeps distribution layers out of
  position-scale training, preserving original axes and externally
  supplied samples.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  preserves flipped and fixed-ratio Cartesian coordinates and correctly
  positions overlays on transformed axes without transforming limits
  twice.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  anchors histogram and density fills to the requested lower boundary,
  including negative y ranges and explicit `y_rescale` intervals.

- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  preserves histogram frequency and density ratios when every computed
  bin or density value is positive, including equally populated bins.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  reuses resolved settings for repeated themes within a batch, with a
  bounded cache that stops after consecutive theme mismatches.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  gives automatically restored grids a contrasting grey when their
  colour matches a known opaque background, preserving explicit grid
  colours.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  uses absolute millimetres for grid and border widths and rejects
  relative width objects before rendering.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  restores hidden grids without fixing inherited styles onto
  axis-specific elements, so later parent grid themes still take effect.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  builds shared panel settings once and avoids redundant plot copies
  when restoring grid lines.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  documents its grid-style fallback, protected cells and extra-theme
  overrides, with regressions for rendering, computed data and
  caller-owned plots.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  reports malformed border, colour, line-width and line-type arguments
  before rendering; transparent colours and zero widths remain valid.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  formats every ordinary leaf of nested patchworks and lists, preserving
  container layouts, annotations and list names.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  merges deferred argument abbreviations by their matched names in call
  order, including `trans` / `transform`; duplicates within one call
  remain errors and explicit `NULL` settings are retained.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  restores enabled grids when switching modes or formatting themes that
  previously hid their grids, retaining available inherited line
  styling.

- [`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md)
  consistently hides axis-specific grid lines and applies explicit grid
  styling to both axes.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  uses native scales for statistic-generated axes, including categorical
  [`after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html)
  values and implicit statistic default mappings.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  defers dynamic mapping evaluation to normal plot building, preserving
  function-call counts, lazy bindings and random-number state.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  retains the same observations for partially automatic limits when
  changing between increasing and decreasing transformations.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  leaves lazy mapping bindings unevaluated until plot building,
  retaining native mapping evaluation order and random-number state.

- Alternating
  [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  and
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  retains all deferred settings; the most recent formatter takes
  precedence when both set expansion.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  defers active bindings in mapping environments without evaluating them
  or changing the random-number state during formatting.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  retains native scales when axes are supplied by statistic default
  mappings, including categorical outputs from custom statistics.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  preserves observations when changing to or from a reversed
  transformation, including on the minimum supported ggplot2 version.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  formats all leaves of nested patchworks and applies settings to native
  scales for function and formula layer data without extra data calls.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  validates named axis lists, matches unambiguous argument abbreviations
  consistently, and retains the cause of scale construction errors.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  supports controls on existing binned position scales and reuses
  unchanged scales. Changed axes clone once per plot without retaining
  prior scale instances or bound callback histories.

- The formatting vignette uses the current `fmt_scale(x = ..., y = ...)`
  API.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  retains native scale inference for computed statistics, including
  categorical
  [`after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html)
  mappings.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  preserves native
  [`scale_type()`](https://ggplot2.tidyverse.org/reference/scale_type.html)
  dispatch for extension classes, including implicit binned position
  scales, without extra dispatch calls.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  defers function-call mappings to normal plot building, avoiding extra
  evaluations and preserving random mappings. Function errors are
  reported at build time with their original cause.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  keeps scale storage bounded when padding changes repeatedly, retaining
  custom scale classes, fields and clone behavior without chaining
  previous instances as parents.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  and
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  ignore empty position mappings when choosing a scale, so later
  non-empty layers retain their native scale type.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  retains native scales for function and formula layer data, resolving
  them during plot building without extra calls to the data function.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  and
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  infer only initial-stage mappings, keeping computed statistics
  separate from same-named source columns and accepting legacy statistic
  mappings.

- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  updates only the supplied settings of an existing position scale
  instead of replacing it, so limits, breaks, labels, transformation,
  expansion and secondary axes set earlier are kept. Continuous limits
  use the existing transformation.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  reuses unchanged scales and clones changed scales only once per plot,
  avoiding retained clone histories during repeated formatting.

- [`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)
  gains `axis_titles` (default `"collect"`), passed to
  [`patchwork::plot_layout()`](https://patchwork.data-imaginist.com/reference/plot_layout.html),
  so labels shared by all panels of a patchwork are drawn once. Use
  `axis_titles = NULL` to keep the previous layout.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  reports ordinary mapping errors with their original cause instead of
  silently substituting a continuous scale. Computed statistics remain
  deferred to ggplot2.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  validates scalar axis choices and finite padding values, with
  documented scalar/asymmetric expansion and temporal units.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  updates every nested patchwork leaf, retaining layouts, annotations,
  free settings, named containers, spacers and inset overlays.

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  resolves layer data, mapping overrides and captured variables when
  choosing new scales. Shared detection also supports
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md).

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  distinguishes dates, date-times and times, retaining sub-day
  resolution. Shared detection also accepts temporal controls in
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md).

- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  preserves existing position scales, including transformations, limits,
  custom labels, discrete ordering, binned scales and secondary axes.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  limits statistical closures to the current plot’s configuration, so
  extracting one formatted plot no longer retains other container plots
  and their data during serialization.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  validates layout-vector sizes and transformation domains, matches
  vectors to comparison identities across facet filtering, and supports
  symmetric or left/right tip lengths per comparison without recycling.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  fixes one-sided comparison direction to custom pair order, reference
  order, or original mapped group order for automatic pairs, keeping
  axis reordering from reversing the tested alternative.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  preserves paired observations through missing-value and scale
  filtering, with joint pair omission. `method.args$id` matches explicit
  subject IDs; ambiguous unequal-size row pairing is rejected.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  drops unused comparison levels within each grouped subset, retaining
  valid sparse legend comparisons and their original dodge positions.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  retains adjusted P values and labels when grouped subsets have
  different numbers of comparison levels, respecting group/panel
  adjustment.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  honors reference-group comparisons, including pooled references and
  named legend groups, and rejects conflicting custom comparison lists.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  rejects unknown, unnamed and duplicate layout controls, reporting
  misspelled arguments and misplaced extra graphics explicitly. Multiple
  graphics remain supported through the `plots` list input.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  binds insets before extracting hosts from plain or nested lists,
  retaining composite and grob hosts, their cell names and selection
  boundaries consistently with native patchwork inputs.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  emits ordinary inset hosts at the same layout level as their
  neighbours, retaining shared axis and axis-title collection. Selection
  and reordering still operate on complete host/inset cells; returned
  patchwork child indexing now includes inset objects. Composite inset
  hosts stay intact.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  validates comparisons, numeric positions and test-option names;
  resolves unambiguous layer data/mappings and explicit statistical
  overrides; and skips missing panel pairs without failed-test warnings.
  Retained unused axis categories no longer compress ordinary or grouped
  bracket positions.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  transforms absolute bracket positions from data units and resolves
  proportional positions within each panel’s trained y range. Explicit
  positions no longer receive an implicit nudge; a supplied bracket
  nudge remains supported.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  formats all ordinary leaves of nested patchworks and plot lists,
  retaining layout, annotations and names while skipping spacers, guide
  areas, insets and frozen wrapped graphics.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  supports pair selection for Dunn, Tukey and Games-Howell tests without
  passing unsupported comparison arguments. Their full-family adjustment
  is retained; adjusted-only methods display adjusted stars.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  honors explicit grouped comparisons and statistical mappings,
  resolving requested pairs within each subset and retaining native
  dodge positions. Default trajectory grouping remains ignored for x
  comparisons.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  merges named ggpubr arguments with defaults, allowing paired and
  one-sided test options, custom significance symbols and font overrides
  without duplicate arguments. Pair selection remains controlled by
  `com_method`.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  accepts adjusted P-value labels and custom ggpubr templates while
  retaining its default raw P-value stars.

- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  resolves comparisons from observed groups and trained axis positions,
  preventing missing factor levels from silently selecting another
  group. Consecutive and all-pairs comparisons respect panel-local scale
  order.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  documents collection scope changes after flattening, multiple
  guide-area behavior, and wrapped groups for retaining nested scopes.
  Examples cover composite inset hosts and protected guide groups.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  rejects duplicate cell names when a character design would merge them,
  preventing silent loss of repeated selections. Unnamed lists retain
  positional repetition in character designs.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  keeps cell names through nested lists without adding container-name
  prefixes, including named plots with insets in character layout
  designs.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  groups insets with their host before recursion, retaining a composite
  host as one selectable cell and preserving inset coordinates relative
  to that entire host.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  distinguishes a freed plot from its enclosing patchwork, allowing
  containers ending in
  [`free()`](https://patchwork.data-imaginist.com/reference/free.html)
  leaves to flatten, render and retain their overall annotations and
  collection settings.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  reports the index and original cause of unreadable patchwork children
  instead of silently removing them from the result.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  preserves top-level annotations and collection settings, accepts
  explicit layout overrides and keeps
  [`free()`](https://patchwork.data-imaginist.com/reference/free.html)
  containers intact. Grid geometry is rebuilt from the requested output
  layout.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  retains nested insets with their main plot during flattening,
  selection and reordering, preserving overlay placement.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  validates selection and row-interleaving indices before arranging
  plots, preventing fractional-index omissions and empty output. Integer
  exclusion, repetition and zero indices retain their existing meaning.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  accepts single plots and nested lists, retaining names for named
  layout designs and rejecting invalid list elements.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  reuses unchanged guide layouts and keeps a stable container parent for
  layout updates, preventing accumulated wrappers during repeated
  formatting while retaining later native guide edits.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  scales inherited legend text and title margins, leaving other plot
  text unchanged and retaining automatic margin adaptation.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  collects guides normally when inside plots only use
  [`I()`](https://rdrr.io/r/base/AsIs.html) mappings without explicit
  scale limits, retaining real guides and layer mapping overrides
  without evaluating data callbacks.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  preserves inside legends generated by fixed aesthetics, explicit scale
  limits and forced layer legend display during collection.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  retains key-size inheritance when resizing width or height, respecting
  local guide sizes, relative dimensions and colour-bar direction.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  composes existing glyph factors when a scaled guide is reused,
  preventing recursive guide callbacks while retaining layout and data.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  treats size factors of one as unchanged, returning the exact input for
  neutral-only calls and avoiding accumulated guide clones. Mixed calls
  still apply their other formatting controls and validate inputs.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  includes explicit legend, box, text and title margins in overall
  scaling, including local guides and collected guide boxes. Automatic
  text margins remain adaptive, and independent key sizing leaves
  margins alone.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  scales spacing in collected guide boxes at each patchwork level,
  including existing annotation themes, without rescaling legend keys.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  checks visible guides within each collection scope, respecting nested
  `keep` layouts, explicit guide positions and disabled guides instead
  of cancelling unrelated outer guide collection.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  retains automatic local guide dimensions and text margins, allowing
  scaled colour bars and legends to adapt when their position changes.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  respects later explicit guide layout definitions from
  [`guides()`](https://ggplot2.tidyverse.org/reference/guides.html) and
  scales while retaining deferred layout for default guides.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  scales legend glyphs with both ggplot2 3.5 and current guide
  callbacks, passing the theme only when the native method supports it.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  leaves explicit axis guides unchanged when positioning, styling or
  resizing legends, preventing misplaced axes and scaling errors.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  validates controls for empty lists, spacers, guide areas and wrapped
  graphics before returning containers without editable data plots.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  recognizes aesthetics renamed by `ggnewscale`, updating titles and
  guide styling across multiple colour and fill scales. `ggnewscale` is
  an optional suggested package used for compatibility tests.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  scales explicit global key spacing in both directions, matching
  guide-local spacing without changing native inherited defaults.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  hides explicit guides through the plot position without discarding
  their type, titles or settings, allowing later position changes to
  restore them while keeping intentionally disabled guides hidden.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  isolates guide and scale inheritance environments from working plots
  and avoids cloning empty guide containers for theme-only formatting,
  preventing excessive serialized-object growth after repeated calls.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  warns and keeps subplot guides when requested or existing collection
  layouts contain inside legends, preventing their silent loss.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  resolves local guide dimensions from the guide’s own position,
  retaining horizontal colour bars and legend title margins when scaling
  by one.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  returns the original object for calls with no formatting controls,
  retaining container validation while avoiding recursive traversal,
  theme construction and guide cloning.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  collects guides for a single plot with a guide area, warns when
  collection is requested for a list while retaining its return type,
  and synchronizes styling in existing nested collection layouts without
  replacing layouts, annotations or free settings. Identical guides are
  deduplicated; different guides remain separate.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  validates positions, directions, themes, titles, collection flags,
  scaling factors and layout dimensions before editing plots. Numeric
  positions and corner shortcuts use the current inside-position theme
  interface.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  merges local guide styling and retains guide order, reversal and
  aesthetic overrides when combining controls. Legend glyph sizes scale
  after native key construction, preserving mapped sizes and repeated
  scaling while leaving plotted data and caller-owned guide objects
  unchanged.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  scales each subplot from its own theme after applying new legend
  styling, retaining blank text and title elements and collected-guide
  scaling rather than copying the first subplot’s sizes.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  multiplies existing legend units and spacing without converting them
  to lines. A scale of one retains the rendered legend size; independent
  width and height factors combine with the overall scaling factor.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  retains continuous colour bars, binned colour steps and disabled
  guides when resizing or arranging legends, and defers guide resolution
  until normal plot building without evaluating layer data during
  formatting.

- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  renames default and layer-mapped legend titles, including explicit
  guide titles, without modifying shared input scales or guides.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  clips its background stripes to the panel when coordinate clipping is
  disabled, preserving foreground annotations outside the panel.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  respects explicit discrete position scales when layers supply numeric
  mapped or fixed positions, including flipped coordinates.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  checks complete named manual colours against displayed scale
  categories, allowing unused data categories to be excluded by scale
  limits without resolving an unnecessary palette.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  draws missing-category stripes in free-scale panels containing only
  missing values when other panels have valid categories, while plots
  with no non-missing categories still draw no background.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  background methods retain only axis and colour settings, preventing
  old plot objects from accumulating in closures and serialized plots
  after repeated formatting.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  resolves one category colour map for all panels and data layers,
  keeping unnamed and palette colours consistent across free-scale
  facets.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  defers mapping expressions and data callbacks to ggplot, supporting
  [`after_stat()`](https://ggplot2.tidyverse.org/reference/aes_eval.html)
  categories without changing random draws or executing callbacks twice.
  Axis and palette checks for deferred mappings occur during drawing.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  reads layer data generated by functions and formulas and selects
  categorical data mappings past numeric annotation layers.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  uses trained layout scales when drawing polar sectors and radial
  bands, fixing rendering failures with
  [`coord_polar()`](https://ggplot2.tidyverse.org/reference/coord_radial.html)
  and
  [`coord_radial()`](https://ggplot2.tidyverse.org/reference/coord_radial.html).

- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  adds `label_args$lineheight` to control multiline label spacing for
  boxed and plain text. The default 1.2 preserves the existing
  appearance.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  validates opacity, returns empty or entirely missing categories
  unchanged, and skips background construction when `alpha = 0`.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  replaces its own background layer on repeated calls, retaining other
  layers and avoiding accumulated transparency. New colors and opacity
  update the existing background without modifying the input plot.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  formats every data plot in nested patchworks and lists while retaining
  layouts, annotations, names and freed alignment. Spacers, guide areas,
  fixed wrapped graphics and inset overlays are left unchanged.

- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  groups styling in `flow_args`, `node_args` and `label_args`. This
  replaces the old top-level `alpha`, `width`, `space`, `label_size` and
  `label_hjust` arguments; migrate them to the corresponding list
  fields. It also supports label thresholds, plain text, percentage
  precision, `show_text = "none"`, custom themes and PDF output through
  `save`.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  creates background bounds after position-scale transformations,
  retaining stripes on log-scaled axes without warnings from infinite
  bounds.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  supports facet expressions and marginal panels, binds stripe colors
  during panel drawing, and retains the original fill scales and
  legends. It no longer expands all categories across the raw facet
  combinations.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  aligns stripes with trained category positions, scale limits, unused
  and missing categories, free-scale facets, and flipped coordinates.
  Background rectangles no longer expand the original panel ranges.

- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  keeps labels centered on their nodes when changing node spacing.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  supports character and logical categories, mapping expressions, and
  data and mappings supplied directly to a layer. Continuous axes are
  skipped with an informative warning.

- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  keeps nodes distinct across variables even when their labels match,
  and retains node colours when changing label styles.

- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md)
  honors manual colors without requiring `plotthis`, retains its default
  rainbow palette, and reports invalid colors and palette errors.

- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  accepts named `vars` vectors mapping column names to axis labels,
  including line breaks. Unnamed vectors retain their existing behavior.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  preserves native axis decorations when transforming category
  boundaries, including with ggplot2 3.5.0.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  makes panel-relative color strips follow their axis guides during
  patchwork axis collection. Different palettes retain separate guides,
  including color-only strips without text labels.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  retains rich text inherited from the global theme, including
  side-specific elements, guide formatting and repeated rotations.
  Complete plot themes retain precedence, and the global theme is not
  modified.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  retains plot-level rich text when updating guide rotations or local
  guide themes, including guides configured on scales. Inherited text
  properties, relative sizes and caller-owned guides are preserved.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  preserves rich-text axis element classes and layout settings, avoiding
  incompatible element merges. Text-mode colors follow each rich label’s
  axis position rather than its internal text fragment coordinates.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  help uses self-contained simulated examples and explains scale labels,
  physical axis selection, facets, nested containers and repeated calls.
  Other guide kinds retain their original plots instead of being
  replaced with a standard axis guide. Native guides avoid constructing
  a separate tile plot for every leaf; text colors use direct position
  matching, and later relative text sizes are resolved once.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  respects physical axis sides, retains scale-guide controls after
  coordinate flipping, leaves disabled guides and continuous labels
  intact, uses non-empty layer data even with an empty global data
  frame, and reports unsupported non-Cartesian coordinates explicitly.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  visits editable leaves in nested patchworks and named lists, retains
  layouts, annotations, freed alignment, fixed graphics and insets, and
  supports repeated calls and switching modes without nesting tile
  strips.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  colors trained axis values instead of raw data levels, respecting
  scale order, breaks, display labels, unused levels and NA values. Both
  modes use axis guides, retain axis titles and defer data/statistic
  evaluation until drawing. Text mode no longer uses vectorized theme
  elements. Tile thickness retains its main-panel proportions, and the
  existing patchwork/list return types are retained. The guide API
  requires ggplot2 \>= 3.5.0.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  returns its validated input unchanged for empty calls and avoids
  repeated empty-theme construction and element-tree lookups. Explicit
  additional theme fields retain precedence. Help and examples cover the
  updated behavior.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  validates scalar angles, justification, sizes, colors and font faces
  immediately with argument-specific errors. Relative sizes, transparent
  colors and justification outside 0–1 remain supported.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  computes automatic justification for each Cartesian axis side, handles
  full turns consistently and retains explicitly supplied justification.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  retains existing text element classes, including rich text, custom
  properties and blank parents, without reapplying relative font sizes.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  applies formatting through plot, scale and secondary-axis guides,
  including flipped and radial coordinates. Other guide settings and
  original objects are retained; justification alone keeps existing
  guide angles.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  updates explicitly styled primary, secondary and radial axis text
  elements while retaining blank sides and unrelated element properties.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  visits every data plot in nested patchworks and lists while retaining
  layouts, annotations, names, freed alignment and inset overlays.

- [`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md)
  applies explicit horizontal and vertical justification without
  requiring a rotation angle, retaining the existing angle and other
  styling.

- [`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md)
  validates named color maps and scalar styling arguments, uses the
  intended fallback colors for missing categories, honors `show_text` in
  both modes, and leaves empty data plots unchanged.

- [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md)
  supports `show_text = "all_wrap"` to place the node name on the first
  line and the count and percentage together on the second line. The
  default `"all"` and existing label styles retain their single-line
  output.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  hides explicitly styled radial text, major/minor ticks and tick
  lengths, including local guides and secondary axes. In radial plots,
  `x.axis` selects theta and `y.axis` selects r, following ggplot2 theme
  inheritance for either theta-variable mapping while retaining axis
  lines and plotted data.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  also hides elements styled by guide-local themes in
  [`guides()`](https://ggplot2.tidyverse.org/reference/guides.html),
  position scales and secondary axes. Other guide settings, unselected
  axes, legends and the caller’s original guide objects are retained.

- Automatic
  [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  selection on lists retains spacer, guide-area and fixed-graphic cells,
  as well as nested container layouts. Inferred dimensions and capacity
  checks use the list’s top-level grid entries.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  help and formatting examples explain single-plot hiding, recursive
  indices, layout precedence, secondary axes, fixed graphics and
  scale-sharing limits. The vignette now uses `x.axis = TRUE` to hide a
  single x-axis.

- Recursive formatters exclude inset overlays containing patchworks from
  the editable plot count. Axis indices and automatic layout selection
  address only the main grid, and inset axes remain intact.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  constructs only requested axis themes and merges x/y hiding before
  modifying each selected plot once. Combined and separate axis calls
  retain the same rendered pixels.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  returns unchanged inputs after validation when no axes are selected,
  avoiding recursive extraction, reconstruction and unused themes.
  Container types, names, deferred data evaluation and RNG state are
  retained.

- `plot_dims` consistently gives layout-based axis selection precedence
  over both manual selectors, including one-row, one-column and
  single-plot layouts.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  validates logical selectors and integer plot indices, rejects missing,
  fractional and out-of-range indices, and applies duplicate indices
  only once. Empty numeric selections and `NULL` retain the current
  axes.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  rejects invalid or undersized layout dimensions with explicit errors.
  Empty trailing rows retain the last occupied row’s x-axes.

- Automatic
  [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  selection follows patchwork cell positions, including column-major
  grids, spacers, guide areas, nested layouts and spanning designs.
  Existing layouts and annotations are retained and insets do not occupy
  cells.

- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  hides explicitly styled axis sides and secondary axes, including minor
  ticks where supported by ggplot2, without changing the plotted data.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  warns when the input already has automatic patchwork tag levels.
  User-owned automatic and manual tags are retained, while repeated
  calls still replace only
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  labels.

- Missing
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  colours are consistently transparent in both placement modes,
  including untyped `NA` and mixed numeric palette vectors. Infinite
  palette indices fail during argument validation.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  checks evaluated compound padding and radius units, rejecting negative
  or non-finite lengths before drawing while retaining valid unit
  arithmetic and restoring the caller’s graphics devices.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  skips fixed wrapped graphics with a warning, so invisible labels do
  not consume the numbering of editable data plots.

- Retagging plots retains patchwork’s freed alignment settings,
  including switches between inside and outside labels.

- Inside
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  positions remain fixed in displayed panel coordinates under flipped
  and non-linear coordinates, including free-scale facets.

- Outside
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  labels compose with axis, legend, reference-line and strip formatting.
  Formatters visit data-plot leaves and skip label insets while
  retaining nested layouts and annotations.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  and
  [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  help and formatting tutorials now document the supported arguments,
  replacement and facet behaviour with runnable examples. Regression
  tests cover rendered labels, nested containers, padding, validation,
  RNG preservation and deferred data evaluation.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  continues automatic lettering after Z as AA, AB and so on, and rejects
  blank labels, invalid NPC positions, colours, font faces, sizes and
  padding units before drawing. Custom label recycling remains
  supported.

- Repeated
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  calls replace only their own labels, including switches between inside
  and outside placement, while retaining user annotations and insets.
  Label insets do not receive patchwork’s automatic tags.
  [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  gives `fmt_tag_list` precedence over `tag_levels` with a warning.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  accepts one, two or four padding units in both placement modes.
  Outside boxes honour asymmetric padding and font-relative units, and a
  zero border width removes the border consistently.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  labels all leaf plots in nested containers in order, preserving
  layouts, annotations and list names. Spacers, guide areas and insets
  do not consume labels; containers without data plots are returned
  unchanged.

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  draws a single inside label per panel with four-sided padding,
  avoiding duplicated text and repeated alpha blending of label
  backgrounds.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  retains the inherited text face with `label_color = NULL` even when an
  explicit or transparent strip fill is supplied.

- Strip formatters reject frozen
  [`wrap_elements()`](https://patchwork.data-imaginist.com/reference/wrap_elements.html)
  panels explicitly instead of silently losing or retaining strips.
  Format the original ggplot before wrapping; inset overlays remain
  outside the formatting grid.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  inherits ggh4x themed strips’ text sizes, angles and colours,
  including hidden strips and repeated calls. Explicit colours retain
  precedence.

- Reapplying `fmt_strip(strip = FALSE)` or label-free
  [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  hides native strips after theme changes, retaining the saved
  restoration settings.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  excludes insets from grid dimensions and header positions, preserving
  user insets and outside
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  labels in nested containers.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  retains native single-panel facets’ shrink setting, preserving
  raw-data scale ranges when their headers are replaced.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  preserves custom row/column labellers, other variables’ mappings and
  combined single-line labels when replacing the first facet variable.
  Repeated relabelling reuses the original labeller rather than stacking
  wrappers.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  help now uses lightweight self-contained examples and documents
  supported grids, unchanged data, transparent colours and facet
  restrictions. Regression coverage includes real rendered headers, RNG
  state and data/statistic call counts in addition to palette checks.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  treats `NA` strip colours as transparent, generates palettes only for
  displayed header directions, and reuses identical palettes within a
  call. Calls without labels skip layout and palette work when hiding
  strips.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  validates positive integer grid dimensions, non-empty character
  labels, R colour specifications and one/two palette names before
  rendering, reporting the responsible argument instead of low-level
  graphics errors.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  restores strip settings hidden by
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  and draws new headers through blank strip themes without losing
  existing text sizes or angles. Explicit header colours still take
  precedence.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  handles aligned nested rectangular grids and preserves their layouts
  and annotations. Spacers and guide areas retain their grid positions
  without receiving facets; non-aligned nested grids are rejected
  explicitly.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  follows patchwork’s default grid dimensions and column-wise filling,
  labels the last occupied panel in incomplete rows, and rejects
  conflicting column counts or unsupported custom designs.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  uses constant header expressions without writing `.top.` or `.right.`
  columns, supporting empty plots, layer-only and function-valued data
  while preserving existing mappings and computed layer values.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  keeps native facet panels and statistics when hiding their strips, and
  rejects replacing multi-panel native facets before statistics are
  computed instead of silently combining data panels.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  validates non-empty character labels and R colour specifications
  before rendering, while retaining transparent fills, numeric palette
  colours and ignored styling arguments when hiding strips. Help now
  explains facet label order, inherited fills, nested containers and
  hide/show behaviour.

- `fmt_raster(method = "image")` renders the whole plot, text included,
  into one raster image of the given `width`/`height` (or the open
  device’s size). The other backends keep text as vectors, so a
  text-heavy figure such as a forest-plot table gained nothing from
  them; as an image it redraws in the RStudio Plots pane about 8x
  faster. It is meant for on-screen previews, not for publication
  export.

- `fmt_strip(strip = FALSE)` no longer builds plots or executes layer
  data functions and statistics. Only synthetic facets created by
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  are dropped; native facets, including currently single-panel facets,
  retain their structure and support later data changes with strips
  hidden.

- `fmt_strip(strip = TRUE)` restores strips hidden by an earlier call.
  Explicit colours override leaf theme and ggh4x strip elements without
  resetting text size or angle; `label_color = NULL` consistently
  inherits existing colours.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  labels all leaf plots in nested patchworks in order, skipping spacers
  and guide areas without consuming their labels. Nested layouts,
  annotations and named list containers are preserved.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  adds synthetic strips with a constant facet expression instead of
  overwriting a data column. Empty data, layer-only data and annotations
  are supported, and existing `.strip_label.` mappings remain unchanged.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  relabels named and computed facet expressions, supports
  function-valued layer data, and can be reapplied without parsing facet
  calls as variable names. Other facet variables retain their original
  labeller.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  keeps the complete label vector for a single faceted plot and recycles
  it across facet levels instead of repeating only its first label.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  preserves all facet variables, layout settings and extension classes
  when relabelling existing facets, keeping panel membership and
  computed statistics unchanged.

- [`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md)
  help now distinguishes deferred layer rasterization from immediate
  fixed-layout capture, documents complete output sizes and list
  returns, and guards examples with their optional dependencies.

- `fmt_raster(method = "ragg")` sets child names when rebuilding panels
  so captured geometry and retained text are actually drawn in the
  returned plot.

- `fmt_raster(method = "ragg")` captures native raster buffers in
  memory, avoiding temporary PNG encoding, disk I/O and decoding. This
  backend no longer requires the png package.

- `fmt_raster(method = "ragg")` detects text from grob classes and
  descendants, including custom names and mixed trees. Viewport geometry
  no longer bypasses rasterization merely because it has its own
  viewport.

- `fmt_raster(method = "ragg")` rejects conflicting dimensions in shared
  facet rows/columns and incompatible nested dimensions instead of
  overwriting earlier panel sizes. Automatic nested outputs retain their
  complete size.

- `fmt_raster(method = "ragg")` resolves automatic panel dimensions from
  the current device’s grid layout, retaining physical units, free-facet
  spacing and fixed aspect ratios instead of falling back to a literal
  size of 4.

- `fmt_raster(method = "ragg")` accepts named lists of plots, returns a
  corresponding list of wrapped gtables, and checks all elements before
  drawing.

- `fmt_raster(method = "ggrastr")` now rasterizes non-text line,
  polygon, column and other geom layers as well as points and tiles.
  Text, label and custom annotation layers remain vectors.

- `fmt_raster(method = "ggrastr")` recursively rasterizes every leaf
  plot in nested patchworks while retaining their original layout.

- [`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md)
  preserves unclipped geometry outside panels by retaining these panels
  as vectors and reporting the rasterization fallback.

- `fmt_raster(method = "ragg")` restores the active graphics device and
  closes its own devices after both successful rendering and draw
  errors. Conversion uses a private in-memory device for measurement.

- [`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md)
  rejects non-positive, non-finite and non-scalar resolutions before
  opening a raster device. The ragg backend also checks positive finite
  panel dimensions and rejects dimensions smaller than one output pixel.

- `fmt_raster(method = "ragg")` retains the original draw order between
  vector text and contiguous rasterized geometry runs.

- `fmt_raster(method = "ragg")` now preserves all panels, axes and
  labels in flat and nested patchworks instead of converting only the
  last plot.

## UtilsR 0.6.2

- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  outside placements (`"tl-out"`, `"tr-out"`, `"bl-out"`, `"br-out"`)
  now draw the label in the same box as inside placements, styled by
  `label.size`, `label.padding` and `label.r`. The label is a full-plot
  patchwork inset instead of a ggplot2 tag, so a single ggplot comes
  back as a single-plot patchwork.

- `stat_ci_parse(exp = "auto")` no longer reads a narrow ratio near 1 as
  a difference. `"0.98 (0.95, 1.01)"` gave p = 0 because rounding hid
  the log shape. Scale detection now allows for the printed digits. An
  interval that cannot be decided follows the decided intervals in `x`,
  and is read as a ratio with a warning otherwise. Intervals that are
  asymmetric on their scale get a warning; their p-value comes from the
  half facing the null, and `level` rescales each half (`level = 0.95`
  is now an identity). An estimate outside its bounds, zero width, or a
  bound \<= 0 under `exp = TRUE` now gives `NA` with a warning instead
  of a spurious p-value. Symmetric intervals with an explicit `exp` give
  the same results as before.

- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  parses the whole vector at once (about 10x faster) and reads more
  spellings: `;`, `~` and em dash separators, a negative upper bound
  after a hyphen (`"-0.50 (-0.80--0.20)"`), leading `+`, exponents,
  full-width punctuation and the Unicode minus. `NA` and `""` no longer
  warn. Text after the closing bracket is dropped with a warning instead
  of silently.
  [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  shares the parser.

- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  output fixes: `output = "ci_p"` writes `p<0.001` instead of
  `p=<0.001`; a bound that rounds to zero prints `0.00`, not `-0.00`;
  decimals follow the most precise of the three numbers, so
  `"1.2 (0.95, 1.59)"` is no longer rounded to `"1.2 (0.9, 1.6)"` and
  integers stay integers (at least one decimal with `level`, as before);
  names of `x` are kept; `character(0)` returns an empty character or
  numeric vector. An estimate equal to the null on a printed bound gets
  p = 1 instead of `NaN`. `level`, `digits` and `map_signif` are checked
  up front with a clear error.
  [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  shares the decimal rule.

- `stat_ci_parse(output = "p")` no longer returns exactly 0 for a very
  strong effect: `"5.00 (4.00, 6.25)"` gave 0 and now gives 2.3e-45, so
  `-log10(p)` stays finite. The two-sided tail is `2 * pnorm(-|z|)`;
  other p-values move by at most 1e-16 and no formatted output changes.

- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  and
  [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  read an en or em dash written as a minus sign, as Word and PDF tables
  often print it: `"–0.25 (–0.40, –0.10)"` failed to parse and now
  equals `"-0.25 (-0.40, -0.10)"`. A dash counts as a minus only before
  a number that opens the string or follows the bracket or a separator,
  so `"0.25 (0.10–0.40)"` keeps it as the separator.

- ggprism moved from Suggests to Imports:
  [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md)
  reads its palette from ggprism, so
  [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md),
  `theme_km`, `theme_rcs` and `theme_scatter` no longer fail or stay
  `NULL` when ggprism is not installed.

- Added
  [`plt_alluvial()`](https://hui950319.github.io/UtilsR/reference/plt_alluvial.md)
  for percentage or count alluvial distributions with native faceting
  and grouped flow, stratum, label, facet, and legend options;
  `plt_dist(type = "alluvial")` now uses it and supports `facet` without
  scMMR. Its five semantic list arguments now expose complete defaults
  in the public signature, with every supported child field documented
  individually.

- [`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md)
  and
  [`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md)
  now display RColorBrewer and base R HCL palette collections through
  [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md).

- [`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md)
  now handles HCL palettes outside the three named type groups when
  displaying the complete palette collection.

- Added
  [`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md)
  and
  [`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)
  for displaying dynamic ggsci and viridis palette collections through
  [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md).

- [`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md)
  and
  [`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)
  now support `output = "console"` consistently with
  [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md).

- [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md),
  [`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md),
  and
  [`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md)
  now support `output = "console"` through
  [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md).

- [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)
  now gives the `Colours` column a fixed width of `420px` in `gt`
  output.

- [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)
  now doubles the width of each colour swatch in `gt` output.

- [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
  now prints a [`dput()`](https://rdrr.io/r/base/dput.html)
  representation of the displayed colour vector for reuse in R.

- [`.cat_line()`](https://hui950319.github.io/UtilsR/reference/dot-cat_line.md),
  [`.cat_box()`](https://hui950319.github.io/UtilsR/reference/dot-cat_box.md),
  [`.cat_message()`](https://hui950319.github.io/UtilsR/reference/dot-cat_message.md),
  [`.cat_formula()`](https://hui950319.github.io/UtilsR/reference/dot-cat_formula.md),
  and
  [`.cat_tb()`](https://hui950319.github.io/UtilsR/reference/dot-cat_tb.md)
  are now exported for use by other R packages.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  now centers strip text horizontally and vertically.

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  gains `strip`. `strip = FALSE` removes every strip, including strips
  already on the plot; multi-panel facets keep their panels.

- [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md)
  now centers horizontal and vertical facet-strip text with symmetric
  margins.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  now accepts `top_right_fill` to generate get_facet-style sequential
  colour fills for top and right strips.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  now defaults `top_right_fill` to `c("Grays", "Greens")`.

- [`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md)
  now uses a lighter second strip colour when a palette is mapped to
  exactly two levels.

- [`impute_na_knn()`](https://hui950319.github.io/UtilsR/reference/impute_na_knn.md)
  adds weighted K-nearest-neighbour imputation for mixed data frames
  while preserving numeric and character value labels.

- [`plt_na()`](https://hui950319.github.io/UtilsR/reference/plt_na.md)
  adds missing-value matrix and percentage plots; `output` selects
  either combined layout or either standalone panel, and `sort` controls
  variable ordering by missing rate.

- [`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)
  now documents `levels = NA` for plotting missing-value intersections
  without modifying the input data.

## UtilsR 0.6.1

Patch release fixing
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
re-application failure.

### Bug fixes

- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  previously crashed with `Error: Can't convert a call to a string.`
  when applied to a plot whose first
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  pass had injected a synthetic `.strip_label.` facet. This happened
  because the no-facet branch wrote the facet quosure as
  `vars(.data[["..."]])` (a CALL), and the has-facet branch used
  [`rlang::as_name()`](https://rlang.r-lib.org/reference/as_name.html)
  which only accepts symbols.

  Two-layer fix:

  1.  **Source side** (no-facet branch): use
      `rlang::sym(".strip_label.")` to produce a bare symbol, so
      subsequent
      [`rlang::as_name()`](https://rlang.r-lib.org/reference/as_name.html)
      calls resolve cleanly.
  2.  **Recovery side** (has-facet branch): add a tolerant
      `.extract_var_name()` helper that tries `as_name()` first, falls
      back to parsing `.data[[...]]` calls (for backward compatibility
      with externally-built ggh4x facets), and drops unparseable
      entries.

  Reproducer: any patchwork composition where each sub-plot was passed
  through
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  once before being wrapped, then
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  is applied to the wrapped patchwork (e.g. MLR’s
  `.plt_vd.cat.group_sur` and `.plt_vd.cat.group` helpers).

  No public API change; behavior preserved for single-pass
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  usage. Fix verified end-to-end in MLR (`plt_vpd_log` cat-cat 2var path
  which previously crashed now passes).

## UtilsR 0.6.0

### New: `fct_to_group()`

- Companion to
  [`fct_to_combine()`](https://hui950319.github.io/UtilsR/reference/fct_to_combine.md).
  Collapses factor levels into new groups specified by integer indices,
  with auto-naming convention `g<i1>/<i2>/...` (common in clinical TNM /
  RPA staging).

- Vector API (no `data` parameter), parameter named `g_lis`:

  ``` r

  x <- factor(c("I","II","III","IV","V"))
  fct_to_group(x, list(c(1,3), c(2,4), 5))             # -> g1/3, g2/4, g5
  fct_to_group(x, list(early = 1:2, late = 3:5))       # user names win
  ```

### Breaking Change: `fct_to_combine()` signature

- **Removed** the `data` parameter. The function now takes vectors
  directly via `...`, aligning with
  [`forcats::fct_cross()`](https://forcats.tidyverse.org/reference/fct_cross.html)
  and [`base::interaction()`](https://rdrr.io/r/base/interaction.html).

- Migration:

  ``` r

  # Before (0.5.x and earlier)
  fct_to_combine(df, sex, age)
  fct_to_combine(df, c("sex", "age"))

  # After (0.6.0+)
  fct_to_combine(df$sex, df$age)
  df %>% mutate(g = fct_to_combine(sex, age))           # natural in mutate
  do.call(fct_to_combine, df[c("sex", "age")])           # programmatic
  rlang::exec(fct_to_combine, !!!df[c("sex", "age")])    # programmatic (rlang)
  ```

- Default separator (`&`) and factor-level-ordered output unchanged.

## UtilsR 0.3.0

### `plt_cat()` — Unified Categorical Plot

- Single entry point for **11 chart types**: bar, rose, ring, pie,
  trend, area, dot, sankey, chord, venn, and upset.
- 27+ parameters: grouping, splitting, dodge/stack, labels, background
  bands, NA handling, and more.
- UpSet: switched from `ggVennDiagram(force_upset)` to
  [`ggupset::scale_x_upset()`](https://rdrr.io/pkg/ggupset/man/scale_x_upset.html).
- Labels: switched from `geom_text` to
  [`ggrepel::geom_text_repel()`](https://ggrepel.slowkow.com/reference/geom_text_repel.html).
- Ring/Rose: support `position = "dodge"`.

### New Parameters

- `subtitle`, `legend.direction`, `aspect.ratio` — layout control.
- `NA_color`, `NA_stat` — explicit NA handling with configurable colour.
- `keep_empty` — preserve empty factor levels.
- `bg.by`, `bg_palette`, `bg_alpha` — background colour bands in dodge
  mode.
- `stat_level` — specify positive level for venn/upset.
- `facet_ncol`, `facet_byrow` — split panel layout.
- `force` — safety check for \> 100 levels.

### Bug Fixes

- alpha not passed to bar/rose/trend/pie
  [`geom_col()`](https://ggplot2.tidyverse.org/reference/geom_bar.html).
- No-group bar stacking at “all” instead of individual bars.
- Dodge labels using stack position.
- `keep_empty` filter logic inverted.
- Division by zero in percent mode with empty groups.
- Ring padding row polluting legend.
- Venn ignoring user palette.
- Trend mixed discrete/continuous x-axis conflict.
- Area type not rendering in dodge mode.

### Documentation

- pkgdown site: <https://hui950319.github.io/UtilsR/>
- Vignette: `plt_cat_guide` with all 11 types.
- Package docs: added Plot Functions section.

------------------------------------------------------------------------

## UtilsR 0.2.0

### New Functions

- [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md)
  — Build or reformat CI strings and mean(SD). Accepts both numeric and
  character input.
- [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md)
  — Format p-values with stars, threshold display, or add stars to any
  value.
- [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md)
  — Parse CI strings, auto-detect exp transformation, compute p-values,
  adjust confidence levels.
- [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)
  — Unified factor manipulation: recode, reorder, reverse, binary,
  group, combine.
- [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)
  — Numeric to factor via cut points or quantile/equal binning.
- [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md)
  — Master ggplot formatting function chaining axis, tag, legend, ref.
- [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md)
  — Hide/show axis elements for multi-plot layouts.
- [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  — Add panel labels (A, B, C…) to plots.
- [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md)
  — Format legend position, direction, merge across patchwork.
- [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md)
  — Add reference lines with per-line colors.
- [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  — Add coloured facet strip labels.
- [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  — Add pairwise statistical comparisons via ggpubr.
- [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md) —
  Add coloured background stripes.
- [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md)
  — Add marginal histogram/density overlay.
- [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  — Set axis scales with auto-detection.
- [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md)
  — Set axis expansion.
- [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md)
  — Overlay boxplot layer on violin/jitter plots.
- [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  — Unified point/jitter/beeswarm layer with auto-dodge and white
  border.
- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/fmt_flatten.md)
  — Recursively flatten nested patchwork objects.
- [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
  — Display colour swatches in RStudio console.
- `as_palette()` /
  [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md)
  — Create and browse colour palettes.
- [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md)
  /
  [`theme_km()`](https://hui950319.github.io/UtilsR/reference/theme_km.md)
  /
  [`theme_rcs()`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md)
  /
  [`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md)
  — ggplot2 themes.

### Colour Palettes

- 11 built-in palettes: `pal_lancet`, `pal_ditto`, `pal_igv`,
  `pal_polychrome`, `pal_glasbey`, `pal_alphabet`, `pal_ucsc`,
  `pal_kelly`, `pal_d3`, `pal_simpsons`, `pal_trubetskoy`.
- Auto-display swatches when printing in console via `palette` S3 class.

### Bug Fixes

- Fixed `.detect_scale_type()` accessing
  [`ggplot_build()`](https://ggplot2.tidyverse.org/reference/ggplot_build.html)
  data incorrectly — now reads from `plot$data` directly.
- Fixed
  [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md)
  crash when `plot$data` is NULL.
- Removed fragile
  [`ggplot2::.pt`](https://ggplot2.tidyverse.org/reference/graphical-units.html)
  usage in
  [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md)
  — now uses `size.unit = "pt"`.
- Fixed
  [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md)
  checking `"color"` in mapping names (ggplot2 uses `"colour"`).
- Removed silent `expand` injection in
  [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md)
  that overrode user intent.
- Fixed
  [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md)
  `label.y` default changed to `NULL` (auto-calculate, not 0.8).

## UtilsR 0.1.0

- Initial release with
  [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md), `na()`,
  [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md),
  [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md),
  operators, and console display utilities.
