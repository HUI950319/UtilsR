# Changelog

## UtilsR 0.6.8

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

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  rejects unknown, unnamed and duplicate layout controls, reporting
  misspelled arguments and misplaced extra graphics explicitly. Multiple
  graphics remain supported through the `plots` list input.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  binds insets before extracting hosts from plain or nested lists,
  retaining composite and grob hosts, their cell names and selection
  boundaries consistently with native patchwork inputs.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
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

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  documents collection scope changes after flattening, multiple
  guide-area behavior, and wrapped groups for retaining nested scopes.
  Examples cover composite inset hosts and protected guide groups.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  rejects duplicate cell names when a character design would merge them,
  preventing silent loss of repeated selections. Unnamed lists retain
  positional repetition in character designs.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  keeps cell names through nested lists without adding container-name
  prefixes, including named plots with insets in character layout
  designs.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  groups insets with their host before recursion, retaining a composite
  host as one selectable cell and preserving inset coordinates relative
  to that entire host.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  distinguishes a freed plot from its enclosing patchwork, allowing
  containers ending in
  [`free()`](https://patchwork.data-imaginist.com/reference/free.html)
  leaves to flatten, render and retain their overall annotations and
  collection settings.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  reports the index and original cause of unreadable patchwork children
  instead of silently removing them from the result.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  preserves top-level annotations and collection settings, accepts
  explicit layout overrides and keeps
  [`free()`](https://patchwork.data-imaginist.com/reference/free.html)
  containers intact. Grid geometry is rebuilt from the requested output
  layout.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  retains nested insets with their main plot during flattening,
  selection and reordering, preserving overlay placement.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
  validates selection and row-interleaving indices before arranging
  plots, preventing fractional-index omissions and empty output. Integer
  exclusion, repetition and zero indices retain their existing meaning.

- [`flatten_patchwork()`](https://hui950319.github.io/UtilsR/reference/flatten_patchwork.md)
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
