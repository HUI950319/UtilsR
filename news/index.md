# Changelog

## UtilsR 0.6.8

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
  errors. Headless conversion uses a temporary in-memory PDF device for
  measurement.

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
- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
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
