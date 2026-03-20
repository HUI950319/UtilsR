# UtilsR 0.2.0

## New Functions

* `stat_ci()` — Build or reformat CI strings and mean(SD). Accepts both numeric and character input.
* `stat_pval()` — Format p-values with stars, threshold display, or add stars to any value.
* `stat_ci_parse()` — Parse CI strings, auto-detect exp transformation, compute p-values, adjust confidence levels.
* `fct_cat()` — Unified factor manipulation: recode, reorder, reverse, binary, group, combine.
* `fct_num()` — Numeric to factor via cut points or quantile/equal binning.
* `fmt_plot()` — Master ggplot formatting function chaining axis, tag, legend, ref.
* `fmt_axis()` — Hide/show axis elements for multi-plot layouts.
* `fmt_tag()` — Add panel labels (A, B, C...) to plots.
* `fmt_legend()` — Format legend position, direction, merge across patchwork.
* `fmt_ref()` — Add reference lines with per-line colors.
* `fmt_strip()` — Add coloured facet strip labels.
* `fmt_com()` — Add pairwise statistical comparisons via ggpubr.
* `fmt_bg()` — Add coloured background stripes.
* `fmt_his()` — Add marginal histogram/density overlay.
* `fmt_scale()` — Set axis scales with auto-detection.
* `fmt_expand()` — Set axis expansion.
* `fmt_boxplot()` — Overlay boxplot layer on violin/jitter plots.
* `fmt_point()` — Unified point/jitter/beeswarm layer with auto-dodge and white border.
* `flatten_patchwork()` — Recursively flatten nested patchwork objects.
* `show_color()` — Display colour swatches in RStudio console.
* `as_palette()` / `pal_list()` — Create and browse colour palettes.
* `theme_my()` / `theme_km()` / `theme_rcs()` / `theme_legend1()` — ggplot2 themes.

## Colour Palettes

* 11 built-in palettes: `pal_lancet`, `pal_ditto`, `pal_igv`, `pal_polychrome`, `pal_glasbey`, `pal_alphabet`, `pal_ucsc`, `pal_kelly`, `pal_d3`, `pal_simpsons`, `pal_trubetskoy`.
* Auto-display swatches when printing in console via `palette` S3 class.

## Bug Fixes

* Fixed `.detect_scale_type()` accessing `ggplot_build()` data incorrectly — now reads from `plot$data` directly.
* Fixed `fmt_strip()` crash when `plot$data` is NULL.
* Removed fragile `ggplot2::.pt` usage in `fmt_tag()` — now uses `size.unit = "pt"`.
* Fixed `fmt_point()` checking `"color"` in mapping names (ggplot2 uses `"colour"`).
* Removed silent `expand` injection in `fmt_scale()` that overrode user intent.
* Fixed `fmt_com()` `label.y` default changed to `NULL` (auto-calculate, not 0.8).

# UtilsR 0.1.0

* Initial release with `lv()`, `na()`, `check_system()`, `check_size()`, operators, and console display utilities.
