# UtilsR 0.6.8

* Inside `fmt_tag()` positions remain fixed in displayed panel coordinates
  under flipped and non-linear coordinates, including free-scale facets.

* Outside `fmt_tag()` labels compose with axis, legend, reference-line and strip
  formatting. Formatters visit data-plot leaves and skip label insets while
  retaining nested layouts and annotations.

* `fmt_tag()` and `fmt_plot()` help and formatting tutorials now document the
  supported arguments, replacement and facet behaviour with runnable examples.
  Regression tests cover rendered labels, nested containers, padding, validation,
  RNG preservation and deferred data evaluation.

* `fmt_tag()` continues automatic lettering after Z as AA, AB and so on, and
  rejects blank labels, invalid NPC positions, colours, font faces, sizes and
  padding units before drawing. Custom label recycling remains supported.

* Repeated `fmt_tag()` calls replace only their own labels, including switches
  between inside and outside placement, while retaining user annotations and
  insets. Label insets do not receive patchwork's automatic tags. `fmt_plot()`
  gives `fmt_tag_list` precedence over `tag_levels` with a warning.

* `fmt_tag()` accepts one, two or four padding units in both placement modes.
  Outside boxes honour asymmetric padding and font-relative units, and a zero
  border width removes the border consistently.

* `fmt_tag()` labels all leaf plots in nested containers in order, preserving
  layouts, annotations and list names. Spacers, guide areas and insets do not
  consume labels; containers without data plots are returned unchanged.

* `fmt_tag()` draws a single inside label per panel with four-sided padding,
  avoiding duplicated text and repeated alpha blending of label backgrounds.

* `fmt_strip2()` help now uses lightweight self-contained examples and documents
  supported grids, unchanged data, transparent colours and facet restrictions.
  Regression coverage includes real rendered headers, RNG state and data/statistic
  call counts in addition to palette checks.

* `fmt_strip2()` treats `NA` strip colours as transparent, generates palettes
  only for displayed header directions, and reuses identical palettes within
  a call. Calls without labels skip layout and palette work when hiding strips.

* `fmt_strip2()` validates positive integer grid dimensions, non-empty character
  labels, R colour specifications and one/two palette names before rendering,
  reporting the responsible argument instead of low-level graphics errors.

* `fmt_strip2()` restores strip settings hidden by `fmt_strip()` and draws new
  headers through blank strip themes without losing existing text sizes or
  angles. Explicit header colours still take precedence.

* `fmt_strip2()` handles aligned nested rectangular grids and preserves their
  layouts and annotations. Spacers and guide areas retain their grid positions
  without receiving facets; non-aligned nested grids are rejected explicitly.

* `fmt_strip2()` follows patchwork's default grid dimensions and column-wise
  filling, labels the last occupied panel in incomplete rows, and rejects
  conflicting column counts or unsupported custom designs.

* `fmt_strip2()` uses constant header expressions without writing `.top.` or
  `.right.` columns, supporting empty plots, layer-only and function-valued
  data while preserving existing mappings and computed layer values.

* `fmt_strip2()` keeps native facet panels and statistics when hiding their
  strips, and rejects replacing multi-panel native facets before statistics
  are computed instead of silently combining data panels.

* `fmt_strip()` validates non-empty character labels and R colour specifications
  before rendering, while retaining transparent fills, numeric palette colours
  and ignored styling arguments when hiding strips. Help now explains facet
  label order, inherited fills, nested containers and hide/show behaviour.

* `fmt_raster(method = "image")` renders the whole plot, text included, into
  one raster image of the given `width`/`height` (or the open device's size).
  The other backends keep text as vectors, so a text-heavy figure such as a
  forest-plot table gained nothing from them; as an image it redraws in the
  RStudio Plots pane about 8x faster. It is meant for on-screen previews, not
  for publication export.

* `fmt_strip(strip = FALSE)` no longer builds plots or executes layer data
  functions and statistics. Only synthetic facets created by `fmt_strip()`
  are dropped; native facets, including currently single-panel facets, retain
  their structure and support later data changes with strips hidden.

* `fmt_strip(strip = TRUE)` restores strips hidden by an earlier call. Explicit
  colours override leaf theme and ggh4x strip elements without resetting text
  size or angle; `label_color = NULL` consistently inherits existing colours.

* `fmt_strip()` labels all leaf plots in nested patchworks in order, skipping
  spacers and guide areas without consuming their labels. Nested layouts,
  annotations and named list containers are preserved.

* `fmt_strip()` adds synthetic strips with a constant facet expression instead
  of overwriting a data column. Empty data, layer-only data and annotations
  are supported, and existing `.strip_label.` mappings remain unchanged.

* `fmt_strip()` relabels named and computed facet expressions, supports
  function-valued layer data, and can be reapplied without parsing facet calls
  as variable names. Other facet variables retain their original labeller.

* `fmt_strip()` keeps the complete label vector for a single faceted plot and
  recycles it across facet levels instead of repeating only its first label.

* `fmt_strip()` preserves all facet variables, layout settings and extension
  classes when relabelling existing facets, keeping panel membership and
  computed statistics unchanged.

* `fmt_raster()` help now distinguishes deferred layer rasterization from
  immediate fixed-layout capture, documents complete output sizes and list
  returns, and guards examples with their optional dependencies.

* `fmt_raster(method = "ragg")` sets child names when rebuilding panels so
  captured geometry and retained text are actually drawn in the returned plot.

* `fmt_raster(method = "ragg")` captures native raster buffers in memory,
  avoiding temporary PNG encoding, disk I/O and decoding. This backend no
  longer requires the png package.

* `fmt_raster(method = "ragg")` detects text from grob classes and descendants,
  including custom names and mixed trees. Viewport geometry no longer bypasses
  rasterization merely because it has its own viewport.

* `fmt_raster(method = "ragg")` rejects conflicting dimensions in shared
  facet rows/columns and incompatible nested dimensions instead of overwriting
  earlier panel sizes. Automatic nested outputs retain their complete size.

* `fmt_raster(method = "ragg")` resolves automatic panel dimensions from the
  current device's grid layout, retaining physical units, free-facet spacing
  and fixed aspect ratios instead of falling back to a literal size of 4.

* `fmt_raster(method = "ragg")` accepts named lists of plots, returns a
  corresponding list of wrapped gtables, and checks all elements before drawing.

* `fmt_raster(method = "ggrastr")` now rasterizes non-text line, polygon,
  column and other geom layers as well as points and tiles. Text, label and
  custom annotation layers remain vectors.

* `fmt_raster(method = "ggrastr")` recursively rasterizes every leaf plot in
  nested patchworks while retaining their original layout.

* `fmt_raster()` preserves unclipped geometry outside panels by retaining
  these panels as vectors and reporting the rasterization fallback.

* `fmt_raster(method = "ragg")` restores the active graphics device and
  closes its own devices after both successful rendering and draw errors.
  Conversion uses a private in-memory device for measurement.

* `fmt_raster()` rejects non-positive, non-finite and non-scalar resolutions
  before opening a raster device. The ragg backend also checks positive finite
  panel dimensions and rejects dimensions smaller than one output pixel.

* `fmt_raster(method = "ragg")` retains the original draw order between
  vector text and contiguous rasterized geometry runs.

* `fmt_raster(method = "ragg")` now preserves all panels, axes and labels in
  flat and nested patchworks instead of converting only the last plot.

# UtilsR 0.6.2

* `fmt_tag()` outside placements (`"tl-out"`, `"tr-out"`, `"bl-out"`,
  `"br-out"`) now draw the label in the same box as inside placements,
  styled by `label.size`, `label.padding` and `label.r`. The label is a
  full-plot patchwork inset instead of a ggplot2 tag, so a single ggplot
  comes back as a single-plot patchwork.

* `stat_ci_parse(exp = "auto")` no longer reads a narrow ratio near 1 as a
  difference. `"0.98 (0.95, 1.01)"` gave p = 0 because rounding hid the log
  shape. Scale detection now allows for the printed digits. An interval that
  cannot be decided follows the decided intervals in `x`, and is read as a
  ratio with a warning otherwise. Intervals that are asymmetric on their
  scale get a warning; their p-value comes from the half facing the null,
  and `level` rescales each half (`level = 0.95` is now an identity). An
  estimate outside its bounds, zero width, or a bound <= 0 under
  `exp = TRUE` now gives `NA` with a warning instead of a spurious p-value.
  Symmetric intervals with an explicit `exp` give the same results as before.

* `stat_ci_parse()` parses the whole vector at once (about 10x faster) and
  reads more spellings: `;`, `~` and em dash separators, a negative upper
  bound after a hyphen (`"-0.50 (-0.80--0.20)"`), leading `+`, exponents,
  full-width punctuation and the Unicode minus. `NA` and `""` no longer
  warn. Text after the closing bracket is dropped with a warning instead of
  silently. `stat_ci()` shares the parser.

* `stat_ci_parse()` output fixes: `output = "ci_p"` writes `p<0.001`
  instead of `p=<0.001`; a bound that rounds to zero prints `0.00`, not
  `-0.00`; decimals follow the most precise of the three numbers, so
  `"1.2 (0.95, 1.59)"` is no longer rounded to `"1.2 (0.9, 1.6)"` and
  integers stay integers (at least one decimal with `level`, as before);
  names of `x` are kept; `character(0)` returns an empty character or
  numeric vector. An estimate equal to the null on a printed bound gets
  p = 1 instead of `NaN`. `level`, `digits` and `map_signif` are checked up
  front with a clear error. `stat_ci()` shares the decimal rule.

* `stat_ci_parse(output = "p")` no longer returns exactly 0 for a very
  strong effect: `"5.00 (4.00, 6.25)"` gave 0 and now gives 2.3e-45, so
  `-log10(p)` stays finite. The two-sided tail is `2 * pnorm(-|z|)`; other
  p-values move by at most 1e-16 and no formatted output changes.

* `stat_ci_parse()` and `stat_ci()` read an en or em dash written as a minus
  sign, as Word and PDF tables often print it: `"–0.25 (–0.40, –0.10)"`
  failed to parse and now equals `"-0.25 (-0.40, -0.10)"`. A dash counts as
  a minus only before a number that opens the string or follows the bracket
  or a separator, so `"0.25 (0.10–0.40)"` keeps it as the separator.

* ggprism moved from Suggests to Imports: `theme_my()` reads its palette
  from ggprism, so `theme_my()`, `theme_km`, `theme_rcs` and `theme_scatter`
  no longer fail or stay `NULL` when ggprism is not installed.

* Added `plt_alluvial()` for percentage or count alluvial distributions with
  native faceting and grouped flow, stratum, label, facet, and legend options;
  `plt_dist(type = "alluvial")` now uses it and supports `facet` without scMMR.
  Its five semantic list arguments now expose complete defaults in the public
  signature, with every supported child field documented individually.

* `pal_show_brewer()` and `pal_show_hcl()` now display RColorBrewer and base R
  HCL palette collections through `pal_show()`.

* `pal_show_hcl()` now handles HCL palettes outside the three named type
  groups when displaying the complete palette collection.

* Added `pal_show_ggsci()` and `pal_show_viridis()` for displaying dynamic
  ggsci and viridis palette collections through `pal_show()`.

* `pal_show_ggsci()` and `pal_show_viridis()` now support
  `output = "console"` consistently with `pal_show()`.

* `pal_show()`, `pal_show_brewer()`, and `pal_show_hcl()` now support
  `output = "console"` through `show_color()`.

* `pal_show()` now gives the `Colours` column a fixed width of `420px` in
  `gt` output.

* `pal_show()` now doubles the width of each colour swatch in `gt` output.

* `show_color()` now prints a `dput()` representation of the displayed colour
  vector for reuse in R.

* `.cat_line()`, `.cat_box()`, `.cat_message()`, `.cat_formula()`, and
  `.cat_tb()` are now exported for use by other R packages.

* `fmt_strip()` now centers strip text horizontally and vertically.

* `fmt_strip()` gains `strip`. `strip = FALSE` removes every strip, including
  strips already on the plot; multi-panel facets keep their panels.

* `theme_my()` now centers horizontal and vertical facet-strip text with
  symmetric margins.

* `fmt_strip2()` now accepts `top_right_fill` to generate get_facet-style
  sequential colour fills for top and right strips.

* `fmt_strip2()` now defaults `top_right_fill` to `c("Grays", "Greens")`.

* `fmt_strip2()` now uses a lighter second strip colour when a palette is
  mapped to exactly two levels.

* `impute_na_knn()` adds weighted K-nearest-neighbour imputation for mixed
  data frames while preserving numeric and character value labels.

* `plt_na()` adds missing-value matrix and percentage plots; `output` selects
  either combined layout or either standalone panel, and `sort` controls
  variable ordering by missing rate.

* `plt_upset()` now documents `levels = NA` for plotting missing-value
  intersections without modifying the input data.

# UtilsR 0.6.1

Patch release fixing `fmt_strip()` re-application failure.

## Bug fixes

* `fmt_strip()` previously crashed with
  `Error: Can't convert a call to a string.` when applied to a plot whose
  first `fmt_strip()` pass had injected a synthetic `.strip_label.` facet.
  This happened because the no-facet branch wrote the facet quosure as
  `vars(.data[["..."]])` (a CALL), and the has-facet branch used
  `rlang::as_name()` which only accepts symbols.

  Two-layer fix:
  1. **Source side** (no-facet branch): use `rlang::sym(".strip_label.")`
     to produce a bare symbol, so subsequent `rlang::as_name()` calls
     resolve cleanly.
  2. **Recovery side** (has-facet branch): add a tolerant
     `.extract_var_name()` helper that tries `as_name()` first, falls
     back to parsing `.data[[...]]` calls (for backward compatibility
     with externally-built ggh4x facets), and drops unparseable entries.

  Reproducer: any patchwork composition where each sub-plot was passed
  through `fmt_strip()` once before being wrapped, then `fmt_strip()` is
  applied to the wrapped patchwork (e.g. MLR's `.plt_vd.cat.group_sur` and
  `.plt_vd.cat.group` helpers).

  No public API change; behavior preserved for single-pass `fmt_strip()`
  usage. Fix verified end-to-end in MLR (`plt_vpd_log` cat-cat 2var
  path which previously crashed now passes).

# UtilsR 0.6.0

## New: `fct_to_group()`

* Companion to `fct_to_combine()`. Collapses factor levels into new groups
  specified by integer indices, with auto-naming convention `g<i1>/<i2>/...`
  (common in clinical TNM / RPA staging).
* Vector API (no `data` parameter), parameter named `g_lis`:
  ```r
  x <- factor(c("I","II","III","IV","V"))
  fct_to_group(x, list(c(1,3), c(2,4), 5))             # -> g1/3, g2/4, g5
  fct_to_group(x, list(early = 1:2, late = 3:5))       # user names win
  ```

## Breaking Change: `fct_to_combine()` signature

* **Removed** the `data` parameter. The function now takes vectors directly via
  `...`, aligning with `forcats::fct_cross()` and `base::interaction()`.
* Migration:
  ```r
  # Before (0.5.x and earlier)
  fct_to_combine(df, sex, age)
  fct_to_combine(df, c("sex", "age"))

  # After (0.6.0+)
  fct_to_combine(df$sex, df$age)
  df %>% mutate(g = fct_to_combine(sex, age))           # natural in mutate
  do.call(fct_to_combine, df[c("sex", "age")])           # programmatic
  rlang::exec(fct_to_combine, !!!df[c("sex", "age")])    # programmatic (rlang)
  ```
* Default separator (` & `) and factor-level-ordered output unchanged.

# UtilsR 0.3.0

## `plt_cat()` — Unified Categorical Plot

* Single entry point for **11 chart types**: bar, rose, ring, pie, trend, area,
  dot, sankey, chord, venn, and upset.
* 27+ parameters: grouping, splitting, dodge/stack, labels, background bands,
  NA handling, and more.
* UpSet: switched from `ggVennDiagram(force_upset)` to `ggupset::scale_x_upset()`.
* Labels: switched from `geom_text` to `ggrepel::geom_text_repel()`.
* Ring/Rose: support `position = "dodge"`.

## New Parameters

* `subtitle`, `legend.direction`, `aspect.ratio` — layout control.
* `NA_color`, `NA_stat` — explicit NA handling with configurable colour.
* `keep_empty` — preserve empty factor levels.
* `bg.by`, `bg_palette`, `bg_alpha` — background colour bands in dodge mode.
* `stat_level` — specify positive level for venn/upset.
* `facet_ncol`, `facet_byrow` — split panel layout.
* `force` — safety check for > 100 levels.

## Bug Fixes

* alpha not passed to bar/rose/trend/pie `geom_col()`.
* No-group bar stacking at "all" instead of individual bars.
* Dodge labels using stack position.
* `keep_empty` filter logic inverted.
* Division by zero in percent mode with empty groups.
* Ring padding row polluting legend.
* Venn ignoring user palette.
* Trend mixed discrete/continuous x-axis conflict.
* Area type not rendering in dodge mode.

## Documentation

* pkgdown site: https://hui950319.github.io/UtilsR/
* Vignette: `plt_cat_guide` with all 11 types.
* Package docs: added Plot Functions section.

---

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
