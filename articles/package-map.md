# Package Map

UtilsR exports 92 functions, grouped into **12 modules**. The three maps
below answer three different questions: what the package can do, which
function covers a given job, and what each tool hands to the next one.

The maps are labelled in Chinese, matching the source `.drawio` file.
They are full-resolution images – **click any of them to open it in a
new tab**.

## 01 Overview

The 12 modules and a representative function from each. Numbering runs
down the left column first (01–06), then down the right column (07–12).
The overview lists only representative functions; the complete set is in
the next map.

[![UtilsR overview: 12 modules and their representative
functions](utilsr-package-mindmap-p1.png)](https://hui950319.github.io/UtilsR/articles/utilsr-package-mindmap-p1.png)

## 02 Complete function index

All 92 exports grouped by module, each with a one-line description of
what it does. The prefixes are consistent: `lv` / `check_*` / `fct_*` /
`stat_*` inspect and reshape data; `Plot*` / `plt_*` / `fmt_*` /
`theme_*` / `pal_*` / `grob_*` produce and style graphics; `.cat_*`
writes to the console; and four `%...%` operators round out the set.

[![UtilsR function index: all 92 exports grouped by
module](utilsr-package-mindmap-p2.png)](https://hui950319.github.io/UtilsR/articles/utilsr-package-mindmap-p2.png)

## 03 Processing chain

UtilsR is a toolbox rather than an analysis pipeline, so the third map
does not show “which analysis step comes first”. It shows **each tool,
what it returns, and what you can do with that next**. Data goes through
module 03 for inspection and 05 for tidying, then out through 01 / 02 as
a plot, into the `fmt_*` chain in module 08, and – when the layout needs
it – down to the grob level in module 10.

The dashed boxes mark interchangeable outputs: modules 01 and 02 both
return ggplot / patchwork objects, so every `fmt_*` and `theme_*` call
downstream treats them identically.

[![UtilsR processing chain: each module's entry points, return objects
and follow-up
functions](utilsr-package-mindmap-p3.png)](https://hui950319.github.io/UtilsR/articles/utilsr-package-mindmap-p3.png)

Modules 07 (palettes) and 09 (themes) do not appear as steps in that
chain because they are the styling layer underneath it: `theme_my()` and
`pal_lancet()` are called internally by the plotting functions in 01 /
02 and by `fmt_plot()`, so the house style applies without you passing
anything.

## How this maps onto the reference

The [reference
index](https://hui950319.github.io/UtilsR/reference/index.md) is ordered
to match the 12 modules one for one; only the headings differ, since
they are in English (`01 专用图形 Plot*` is Advanced Plot Functions, `08
ggplot2 格式化` is ggplot2 Formatting, and so on). Locate a module on the
map first, then look up that module’s section in the reference for
arguments and examples.

The two counts differ slightly: the maps count `export()` entries in
`NAMESPACE`, while the reference index additionally lists `palette_list`
and `console_width`, which have help pages but are not exported.

The source is a draw.io file
(`tools/mindmap/utilsr-package-mindmap.drawio`, whose three pages are
the three images above; `tools/mindmap/check-mindmap-sync.R` checks it
against `NAMESPACE`). The function list comes from `NAMESPACE`, the
descriptions from the R sources and the man pages.
