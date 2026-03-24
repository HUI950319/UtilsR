# Changelog

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
- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  — Recursively flatten nested patchwork objects.
- [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)
  — Display colour swatches in RStudio console.
- [`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md)
  /
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
