# UtilsR 0.6.8

* `check_size()` uses a neutral white size gradient for all-zero estimates,
  avoiding the misleading midpoint color of a zero-width domain.

* `check_size()` sorts only names matched by `pattern`, avoiding a full global
  name sort while preserving alphabetical order among equally sized objects.

* `check_na()` and `lv()` also count "Blanks", "Unknowns", "Not applicable",
  "Not stated", "Not reported", "NULL" and values made only of `?`, `-` or `.`
  as special values. The new `check_na(special = )` argument replaces the
  built-in markers with user-supplied regular expressions, and
  `special = character(0)` turns special-value counting off.

* `check_na()` returns its gt table visibly instead of printing it and
  returning the input data invisibly, so the table renders in R Markdown,
  Quarto and pkgdown and can be saved with `gt::gtsave()`. Calls that produce
  no table return `NULL` invisibly. Code that piped the returned data onward
  needs updating.

* `check_na()` warns when `pattern` overrides a selection in `...`, and
  reports an invalid `pattern` regular expression with a clear error.

* `check_na()` adds a source note explaining its severity shading and
  documents the thresholds and the denominator of its summary percentages.

* `check_na()` and `lv()` count special values about three to five times
  faster on columns with many distinct values, normalizing only values that
  contain whitespace and matching markers caselessly. A dotted capital I
  (U+0130) no longer folds to `"i"` when matching markers.

* `check_na()` shades special-value cells from light to dark blue as their
  share rises, so the highest severity is no longer the palest.

* The package description now names the exported `check_na()` function correctly.

* `check_na()` displays small positive proportions as `<0.1%` in cells and
  `<0.01%` in summaries, distinguishing them from exact zeros.

* `check_na()` and `lv()` skip unused factor levels when matching special-value
  markers, preserving counts and the original factor levels.

* `check_na()` avoids integer overflow in dataset-size calculations and count
  formatting, including summaries with more than 2^31 - 1 data points or issues.

* `check_size()` scales object bars to the largest individual estimate instead
  of the total, keeping large selections readable and capping the total bar.

* `check_na()` and `lv()` load missing-value methods for serialized labelled
  and integer64 columns, preventing session-dependent errors or missed NA values.

* `check_size()` skips global name enumeration for explicit character selectors,
  while retaining sorted numeric indices and pattern selection.

* `check_size()` identifies its summary by row position, so an object named
  `**TOTAL**` retains the normal object styles and size gradient.

* `check_size()` formats bars from raw sizes, respects later gt formatters,
  and keeps HTML bars out of LaTeX, RTF and Word output.

* `check_size()` documents the limits of summed object-size estimates and the
  evaluation of active bindings and promises, with self-contained examples.

* `check_size()` colors the visible size cells and uses consistent byte-to-GB
  labels in both the table and subtitle, keeping tiny objects distinct from zero.

* `check_size()` reads each selected binding once, so size and class describe
  the same value even when an active binding changes between reads.

* `check_na()` labels affected-variable counts explicitly in its subtitle,
  distinguishing them from the individual-value counts in the summary.

* `check_size()` consistently returns a renderable gt table for empty selections,
  reports unreadable objects, and counts only successfully inspected objects.

* `check_na()` validates `pattern` as `NULL` or one non-missing character string,
  with clear errors for invalid inputs. Empty patterns still match all columns.

* `check_size()` validates object names, indices and regular expressions,
  deduplicates selections, and never expands unmatched selections or searches
  parent environments for missing objects.

* `check_size()` renders its size bars directly in HTML, avoiding per-object
  plots and temporary SVG files while handling zero-sized objects.

* `check_na()` rounds percentages only for display and uses unrounded values
  for severity colors, correcting double rounding and threshold misclassification.

* `check_na()` and `lv()` preserve class-specific missing-value semantics when
  counting special values, so SPSS user-missing codes are not counted twice.

* `check_na()` and `lv()` use Unicode-aware word boundaries and whitespace
  normalization, avoiding false matches within accented words and recognizing
  non-breaking spaces and other Unicode blanks.

* `check_na()` constructs its summary in one operation, reducing overhead on
  wide datasets while preserving counts, ordering, formatting and table styles.

* `check_na()` and `lv()` recognize whitespace-only blanks and markers with
  repeated spaces, tabs or newlines. Matching still runs on distinct values,
  counts each value once, and keeps actual `NA` values separate.

* `check_na()` rejects ambiguous column names, multidimensional selected
  columns, and invalid `show_all` values with informative errors, preventing
  duplicated counts and missingness percentages above 100% for matrix columns.

* `check_na()` returns empty inputs unchanged with an informational message,
  avoiding undefined percentages and empty-table errors.

* `check_na()` supports renamed selections, inspects all columns by default for
  grouped inputs, and no longer expands unmatched selections or patterns to the
  full dataset. Explicit selections inspect the chosen columns across all rows.

* `check_na()` preserves the complete input and its attributes when inspecting
  selected columns, including calls where the selected columns have no issues.

* `fct_num()` documents and demonstrates reduced bin counts after quantile ties,
  merged factor levels from repeated labels, and the handling of infinite data
  in fixed-cut and automatic binning modes. These behaviors are unchanged.

* `fct_num(type = "equal")` computes plain numeric ranges without concatenating
  or filtering the full vector, reducing allocations while retaining cut points,
  missing values, and class-specific range methods.

* `fct_num()` rejects time-span objects supplied as `nbins`, preventing their
  conversion to seconds from silently requesting a different number of bins.
  Valid numeric and `integer64` bin counts retain their existing behavior.

* `fct_num()` documents that automatic fixed-cut labels follow numeric formatting
  options such as `scipen`, and shows explicit labels for stable factor levels.

* `fct_num()` constructs fixed-cut interval labels in one vectorized operation,
  reducing overhead when many cut points are supplied while preserving labels
  and interval order.

* `fct_num()` avoids full-vector missing-value masks and redundant filtering
  for ordinary complete numeric data, and skips unused quantile names.
  Classed-vector dispatch, missing values, and group boundaries are preserved.

* `fct_num(type = "equal")` reports when numeric precision produces repeated
  cut points, with guidance to reduce the bin count or supply explicit cut points.
  It does not merge bins or move their boundaries.

* `fct_num()` rejects logical labels before computing cut points, so
  `labels = FALSE` cannot return integer codes when quantile ties leave one group.

* `fct_num()` rejects matrices and arrays instead of silently flattening
  multidimensional data into a factor vector.

* `fct_num()` rejects `Duration`, `Period`, and `Interval` data and cut points
  before using their numeric storage. Convert them to explicitly chosen numeric
  units first to avoid incorrect ranges or ignored time components.

* `fct_num()` rejects SPSS user-missing data and cut points with a message
  to normalize them first, preventing missing codes from entering valid groups
  or influencing automatic cut points.

* `fct_num()` reuses integer bin codes for ordinary numeric data and unique
  text labels, reducing factor-construction allocations. Classed inputs and
  nonstandard labels retain the existing `cut()` path and group semantics.

* `fct_num()` reports constant data explicitly in both automatic binning
  modes, without misleading zero-bin warnings or label-length errors.
  Fixed-cut behavior and right-closed group boundaries are unchanged.

* `fct_num()` validates `nbins` before conversion, rejecting fractional,
  missing, non-scalar, non-numeric, or overflowing counts without coercion
  warnings or silently changing the requested number of bins.

* `fct_num()` increases automatic label precision only when cut-point text
  collides, preventing nearby numeric intervals from merging into one level.

* `fct_num()` validates fixed cut points before sorting, rejecting missing,
  non-finite, duplicate, or non-numeric values instead of silently changing
  groups or assigning misleading labels.

* `fct_num()` rejects unsupported `integer64` data and cut points instead
  of silently misclassifying their values or losing missing observations.

* `fct_cat()` reuses matched level positions when recoding and keeps
  unmatched levels in a vector, avoiding an intermediate list and repeated
  membership tables for factors with many levels.

* `fct_cat(new_labels = ...)` returns the original factor when normalized,
  non-missing labels are unchanged, avoiding an unnecessary observation copy.

* `fct_cat()` clears obsolete `stats::reorder()` scores after changing
  levels or recode mappings. Operations that leave both unchanged retain
  the scores and other metadata.

* `fct_cat()` rejects reorder calls that mix character levels and numeric
  positions. Numeric arguments are normalized separately before combining,
  including calls that mix native numbers and classed numeric indices.

* `fct_to_group()` delegates index checks to `fct_cat()`, avoiding a warning
  for empty groups and an unrelated `if` error for missing indices.

* `fct_cat(binary_ref = ...)` requires at least one reference index instead
  of silently putting every observed level into `"Oth"` for an empty input.

* `fct_cat()` validates replacement labels after character conversion.
  Classed character labels can no longer bypass merging or missing-label
  removal, and conversions that change the label count are rejected.

* `fct_cat()` ignores names attached to a reorder vector. A named vector
  that leaves the level order unchanged preserves the original contrasts
  and model-matrix encoding.

* `fct_cat()` normalizes numeric indices after validating their values and
  bounds. Classed indices such as `bit64::integer64` now select the intended
  levels in recoding, grouping, reordering and binary conversion.

* `fct_cat()` returns the original factor when reordering leaves its levels
  unchanged, avoiding a full-length allocation for an unchanged order,
  empty factors and one-level reversals.

* `fct_cat()` checks old recode levels in one batch instead of rebuilding
  a membership table for every group, reducing time and allocation when
  there are many levels and groups.

* `fct_cat()` determines used output groups from the original level counts
  and constructs recoded observations once, combining regrouping and
  unused-level removal without an intermediate full-length factor.

* `fct_cat()` indexes level maps with factor codes directly, removing an
  extra full-length integer copy during reordering and unused-level removal.

* `fct_cat(new_labels = ...)` and `fct_label()` reject lists and other
  non-atomic label containers instead of interpreting them as grouping
  instructions. Atomic numeric labels remain supported.

* `fct_cat()` clears matrix-valued contrasts when the output levels change,
  preventing stale contrast rows and redundant model-matrix columns after
  regrouping. Names, labels and contrast function names remain preserved.

* `fct_cat()` remaps integer factor codes when changing level order or
  dropping unused levels, avoiding character conversion and rebuilding.
  Unique, non-missing replacement labels use a direct levels update;
  duplicate and missing labels retain their existing merging semantics.

* `fct_cat()` preserves factor names, class and metadata such as `label`
  across recoding and reordering. An explicit `NA` level remains distinct
  from missing codes; recoding still removes unused levels.

* `fct_cat()` validates scalar logical flags, finite integer indices,
  non-empty group names, duplicate reorder levels and unknown recode levels.
  Recode groups can mix index-based and label-based specifications; each
  group is resolved before checking for overlapping old levels.

* `fct_cat()` includes non-empty `...` in its mode exclusivity check,
  instead of silently ignoring recode or reorder arguments when another
  mode is active.

* `fct_cat(binary_ref = ...)` rejects a reference label of `"Oth"` when
  other levels remain, instead of silently merging both binary groups.

* `fct_cat()` and `fct_to_group()` correctly merge into an existing,
  unmatched level; that level's name no longer overwrites the mapping and
  turns the recoded observations into missing values.

* `plt_cat()`, `plt_con()`, `plt_dist()`, `plt_na()` and `plt_upset()` gain
  `save`, and `plt_alluvial()` and `plt_sankey()` stop saving at
  `RegR::save_plt()`'s generic 10 x 11 in: a `save` list that leaves out
  `width` or `height` writes the page the plot is laid out for, with room for
  its levels, variables or panels beside the measured axis text and legends.
  Every call prints that size with a pasteable `save` line and the plot
  carries it as `attr(p, "plot_size")`; a supplied dimension is kept. The
  size and the saving need RegR 0.1.3 or later. `plt_upset(output = "all")`
  saves the combined plot and `output = "data"` refuses a `save`;
  `plt_con(combine = FALSE)` refuses one too. A `split.by` figure of
  `plt_cat()` or `plt_con()` is reported once, not per panel.

* `fmt_axisTile(mode = "tile")` returns a ggplot for a ggplot, and a list of
  ggplots for a list of them; it wrapped each one in a patchwork, which drew
  the same color strip but changed the object's class.

* `fmt_axisTile()`'s `text_size`, `text_face`, `text_angle` and `text_color`
  default to `NULL`, which keeps the plot's own axis text style. They were 9,
  `"plain"`, 45 degrees on the x axis and `"black"`, so even `mode = "text"`,
  meant only to color the labels, made them smaller, black and rotated. Pass
  `text_angle = 45` for the earlier rotated labels.

* `fmt_raster()`'s default `"ggrastr"` backend draws each raster after an
  empty opaque polygon, as the `"ragg"` and `"image"` backends do: `pdf()`
  painted points drawn after a translucent grob, such as text with
  `alpha = 0.3`, with that transparency. A repeated call rasterizes a layer
  once, at the latest `dpi`.

* `fmt_plot_base()` applies `scale_y_list` and `scale_x_list` with
  `fmt_scale()`. Each panel keeps its scale type, so a discrete or date axis
  no longer fails with "Discrete value supplied to a continuous scale", and an
  existing scale keeps the settings the list does not name: a
  `scale_y_log10()` used to turn linear, with a "Scale for y is already
  present" message for every panel.

* `fmt_plot()` no longer has an unused `...`: a misspelled or unsupported
  argument, such as `fmt_strip_list`, is an "unused argument" error instead
  of being ignored without notice.

* `fmt_expand()` warns when a plot's coordinate system has `expand = FALSE`,
  which makes ggplot2 ignore the scale expansion it sets.

* `fmt_tag()` labels use the font family of each plot's theme (its `plot.tag`
  element), as patchwork tags do. Outside labels always used the device font,
  and inside labels did too with ggpp before 0.6.0 (Windows R has 0.5.8.1),
  so a `theme_bw(base_family = "serif")` figure got sans-serif tags. A
  `family` passed in `...` still wins for inside labels.

* `fmt_legend()` keeps a `legend.justification` or `legend.justification.inside`
  passed through `...`; the justification derived from `legend.position`
  replaced it (causalR's balance plot set it again after the call).

* `fmt_legend(legend.position = c(x, y))` centres the legend on a coordinate
  of exactly 0.5: `c(0.5, 0.95)` put the legend's left edge on the panel's
  centre line, so a "top centre" legend sat right of centre. Other coordinates
  and the corner codes keep their justification.

* `fmt_text()` sets a patchwork's `axis_titles` only when `xlab` or `ylab` is
  supplied. Changing only a title, a caption or text styles merged the axis
  titles too and replaced an existing `"keep"`. A misspelt `axis_titles` is
  still rejected.

* An empty string now removes a title without leaving space, as documented:
  `fmt_text(title = "", xlab = "", ...)` (also `ylab`, `subtitle` and
  `caption`) kept an empty title row of about 6 mm and an empty axis title row
  of about 5 mm, and `fmt_legend(title = "")` kept about 5.6 mm above the keys.

* `fmt_text(axis_title_size, axis_title_face, axis_title_color)` also reach
  axis title sides that set the same field themselves. A theme with an
  explicit `axis.title.x` size, as several RegR plots use, kept that size and
  ignored the requested one. Blank sides stay blank.

* `fmt_plot()` and `fmt_plot_base()` format each plot of a plain list and
  return the list. A list gave `NULL`, because patchwork's `&` falls back to
  `+` for anything but a patchwork; a list holding a non-plot is an error.

* `fmt_axis()` warns when `plot_dims` differs from the layout of a patchwork
  without nested patchworks. Such a patchwork's own layout decides which axes
  are hidden, so `plot_dims = c(4, 1)` on a 2 x 2 grid was silently treated
  as `c(2, 2)`. The help also points to `patchwork::plot_layout(axes =
  "collect")`, which removes only identical axes.

* `fmt_text()` styles rich text elements in place: a title or axis title set
  with `ggtext::element_markdown()` in the plot or global theme keeps its class
  and settings, where styling it failed with "Only elements of the same class
  can be merged".

* `fmt_text(legend_title = )` titles legends as `fmt_legend(title = )` does.
  A continuous colour bar stays a colour bar instead of becoming a key
  legend, guide settings such as `ncol` and `reverse` are kept, linewidth
  legends are titled too, a vector sets one title per plot instead of failing,
  and ggplot2 4.0 no longer reports unknown labels or duplicated aesthetics.

* `fmt_text()` formats the data plots of nested patchworks and skips spacers,
  guide areas and inset overlays, as the other formatters do. Per-plot labels
  no longer land on a spacer or the wrong plot, the first plot of a nested
  layout is no longer left out, and a title added after an outside
  `fmt_tag()` label is drawn once instead of twice (or not at all in a list).

* The help pages of `fmt_plot()` and `fmt_plot_base()` show links and code
  formatting instead of raw Markdown such as `[fmt_axis()]` and `**every**`.

* `fmt_axisTile()` warns once, when the plot is drawn, if no name in `colors`
  matches the axis values; a misspelled or wrongly cased name gave grey tiles
  or plain labels without notice. Axes with free facet scales are not checked.

* `fmt_scale()` gives an updated scale its own copy of the secondary axis.
  The copy shared the input plot's axis, and ggplot2 fills a `dup_axis()`'s
  derived breaks and labels when a plot is drawn: drawing the result gave the
  input plot's secondary axis the result's breaks.

* `fmt_raster(method = "ggrastr")`, the default, rasterizes only point and
  tile layers, as `ggrastr::rasterise()` does by default. Lines, bars and
  polygons stay vector: as images they made a PDF larger (a 6-facet scatter
  with a smooth and a reference line: 103 KB, now 31 KB; 13 KB as vectors).
  A plot without such layers no longer warns about disabled clipping.

* `fmt_strip()` no longer keeps its call frame in the plots it returns. Each
  call on a faceted plot stored further copies of the input plots and their
  data: a 21 MB plot relabelled three times serialized to 90 MB, now 22 MB.
  `fmt_strip2()` did the same for panels holding a native single-panel facet.

* `fmt_panel()` keeps displayed grids visible. Without `grid_color`, a grid
  drawn in the panel background colour, such as `theme_gray()`'s white grid
  with `bg = "white"`, becomes `"grey70"`; before, only restored grids were
  checked. Grids restored under a blank root `line` (`theme_void()`) are
  `"grey85"` instead of the root line's black.

* `fmt_strip()` with `label = NULL` keeps the labels of a faceted plot and
  changes only the strip style. It renamed every panel `Figure1`, so
  `fmt_strip(p, label_fill = "steelblue")` lost the facet levels. Unfaceted
  plots are still labelled `Figure1`, `Figure2`, etc.

* `fmt_strip()` matches named labels of a faceted plot to its facet levels:
  `c("8" = "Eight", "4" = "Four")` labelled the 4-cylinder panel "Eight".
  Unnamed levels keep their label. Unnamed labels whose number is neither one
  nor the number of levels, and names matching no level, now give a warning
  instead of being recycled or dropped silently.

* `fmt_strip()` with `label_fill` keeps the theme's strip border on faceted
  plots, as it already did on unfaceted ones; it drew a black border, so one
  figure could mix framed and unframed strips. On themes without a strip
  background, such as `theme_minimal()`, neither draws a border.

* `fmt_strip2()`'s `label_color` defaults to `"auto"`: each header uses black
  or white text, whichever contrasts more with its fill. Black bold text on
  the darkest generated grey (`"#636363"`, used with one column or three or
  more) had a contrast of 3.5:1; it is now white. Pass `label_color =
  "black"` for the earlier text.

* `fmt_panel(grid = "keep")` leaves the grid lines as they are, so the border
  or background can be changed alone; any other call removed or reset the
  grid, as the default `grid = "none"` still does.

* `fmt_flatten()` given `axes` without `axis_titles` drops the input's
  `axis_titles` as well, so axis titles follow `axes` as in `wrap_plots()`
  instead of staying collected.

* `fmt_flatten()` errors name `fmt_flatten()` (or `flatten_patchwork()`)
  rather than an internal helper and report the class of an unsupported
  element, without descending into list-based objects such as data frames
  or gt tables.

* `fmt_flatten()` is the new name of `flatten_patchwork()`, so it is found
  with the other `fmt_*` formatters. `flatten_patchwork()` remains as the
  same function without a deprecation warning.

* `fmt_raster(method = "image")` takes any figure that draws itself: grobs,
  recorded base plots (replayed) and classed objects with a print method,
  such as `RegR::plt_eff2()`'s forestplot, which it rejected as a list of
  non-ggplot objects. Only a plain list holds several plots.

* `fmt_raster(method = "ragg")` and `method = "image"` leave the random
  stream where it was: ragg before 1.5.1 drew from it to name each capture
  device, so a later random step gave other results than without the raster.

* `fmt_raster(method = "ragg")` and `method = "image"` rasters are drawn
  opaque by `pdf()`, which painted a raster with the transparency of the
  translucent grob drawn before it.

* `fmt_raster(method = "ragg")` keeps the panel's background grid and border
  vector and drops empty grobs, so they no longer add whole-panel images;
  a 200,000-point facetted plot written with `pdf()` is about 40% smaller.

* `fmt_raster(method = "image")` has no plot margins, so at its own size the
  image is drawn pixel for pixel instead of shrunk to about 95%.

* `fmt_boxplot()` releases temporary construction bindings after native layer
  creation, avoiding an extra serialized data copy while retaining deferred
  callbacks, formulas, position objects and symbolic constructor calls.

* `fmt_boxplot()` combines source mappings with explicit fixed summary
  arguments when resolving independent identity overlays, including
  partial summaries and horizontal boxplots.

* `fmt_boxplot()` retains precomputed outlier mappings for independent
  identity overlays when outlier shape is explicit, including an explicit NULL.
  Default suppression and explicit `outliers = FALSE` remain unchanged.

* `fmt_boxplot()` snapshots inherited position settings as well as local
  settings, so edits to a supplied position or its parent do not alter overlays.

* `fmt_boxplot()` retains raw source positions when staged mappings are nested
  inside arithmetic or function calls, preserving their environments and axes.

* `fmt_boxplot()` constructs returned layers in an isolated environment and
  stores symbolic argument calls, avoiding retention of the source-resolution
  workspace and duplicate data in layer constructor calls.

* `fmt_boxplot()` copies explicit position objects and their settings per plot
  leaf, preventing variable-width adjustment and later edits from changing the
  caller's position, existing layers or sibling overlays.

* `fmt_boxplot()` retains source notch boundaries and relative width mappings
  for independent identity-statistic overlays when those features are requested,
  including horizontal summaries and layer-level overrides.

* `fmt_boxplot()` accepts anonymous and environment-selected function calls in
  automatic position mappings without failing during evaluation-stage lookup.

* `fmt_boxplot()` formats plot leaves in one traversal and skips source lookup
  when independent data and complete mappings are explicit, preserving deferred
  callbacks, nested layouts and input validation.

* `fmt_boxplot()` resolves complete vertical or horizontal summary mappings
  automatically for independent identity-statistic overlays, retaining source
  groups and deferred data callbacks while leaving explicit mappings unchanged.

* `fmt_boxplot()` retains explicit `NULL` controls, including width and alpha,
  instead of replacing them with wrapper defaults. Omitted controls retain
  their existing defaults and explicit values follow native validation.

* `fmt_boxplot()` copies raw positions from staged source mappings while
  omitting computed-statistic and after-scale positions in independent overlays.
  Explicit boxplot mappings keep their evaluation stages and environments.

* `fmt_point()` skips unused factor strata during sampling, avoiding empty
  per-group work and matrix-column subsets while retaining data factor levels,
  missing groups, sampling order and column attributes.

* `fmt_point()` normalizes `pch` and point/jitter `cex` aliases before applying
  omitted defaults. Explicit shape/size arguments retain priority, and beeswarm
  `cex` keeps its existing layout meaning and argument-list precedence.

* `fmt_point()` snapshots supplied position objects and inherited settings
  per plot leaf, isolating edits to sibling overlays and caller-owned positions.

* `fmt_point()` samples mappings with anonymous or dynamically selected
  functions without failing when the call has no static function name.

* `fmt_point()` accepts external factor levels and labels during sampling,
  including positional configuration arguments and ordered factors. External
  row vectors in the factor input still require columns in layer data.

* `fmt_point()` constructs point, beeswarm and rasterized layers in isolated
  environments, so extracted plot leaves do not retain unrelated input plots.
  Layer constructor calls keep symbolic arguments instead of embedding data.

* `fmt_point()` retains missing character shapes during white-border
  normalization instead of failing before ggplot2 handles missing points.

* `fmt_point()` samples indices before slicing matrix-column data, avoiding
  full-data group copies while retaining native binding and matrix attributes.

* `fmt_point()` samples joint discrete colour/fill strata and existing facets;
  explicit groups retain priority, and layers missing facet columns still replicate.

* `fmt_point()` respects explicit point/jitter positions supplied through
  `...`, including position objects and native position names.

* `fmt_point()` diagnoses fixed aesthetic vectors and external row-vector
  mappings before sampling, with instructions to map columns in layer data.

* `fmt_point()` uses exact parameter lookups, preventing ignored geom arguments
  from partially matching inheritance, shape, colour or fill controls.

* `fmt_point()` resolves dodge groups from built layer data, so continuous or
  NULL aesthetics retain plain jitter widths and data callbacks remain deferred.

* `fmt_point()` supports group-only jitter-dodge on ggplot2 3.5.x without
  adding visible aesthetics or changing ggplot2 4.x positioning.

* `fmt_point()` samples rows independently of hidden dplyr grouping attributes;
  rowwise and grouped inputs follow the same aesthetic-based sample limits.

* `fmt_point()` distinguishes ordinary columns named `stage`, `after_stat`,
  `after_scale` or `from_theme` from delayed aesthetic function calls.

* `fmt_point(white_border = TRUE)` keeps non-fillable symbols visible using a
  white underlay, and handles named shapes and an explicit NULL shape.

* `fmt_point()` uses the raw `start` expression of staged aesthetics for
  stratified sampling while retaining later colour transformations.

* `fmt_point()` samples row indices before slicing grouped data, reducing
  copying while preserving row order and random selections. Matrix columns
  retain the existing path; single-column data frames keep their dimensions.

* `fmt_point()` validates sample sizes, seeds and layout controls consistently,
  rejects malformed jitter options and incompatible grouping lengths, and
  accepts `NULL` jitter dimensions for ggplot2's native defaults.

* `fmt_point()` forwards supported `beeswarm.args` options such as `priority`
  and `side`, and rejects unknown, duplicate or unnamed options.

* `fmt_point()` includes explicit and layer-local groups in automatic dodging
  and ignores parent mappings when `inherit.aes = FALSE`.

* `fmt_point()` respects layer-local mappings and `inherit.aes` when sampling
  and styling points. Explicit `shape`/`size` values override mappings, while
  omitted values retain the mapped aesthetics.

* `fmt_point()` supports sampling function/formula data after the callback runs
  at build time. Sampling callbacks do not capture unrelated plots or data.

* `fmt_point(white_border = TRUE)` retains scaled group colours and existing
  fills, treats `color` and `colour` consistently, and supports mapped shapes
  and shape 25 without replacing the original plot's scales.

* `fmt_point()` adds independent point layers to every nested patchwork leaf
  while preserving layout, annotations, spacers and the original plots.

* `fmt_point()` samples expression-based groups, retains missing groups, and
  prioritizes explicit groups over discrete colour/fill mappings. Continuous
  colour/fill values no longer create one sampling group per distinct value.

* `fmt_point()` preserves the caller's random-number state when sampling,
  including calls that keep all rows and sessions without an existing seed.

* `check_na()` and `lv()` count a special value ("unknown", "blank", "n/a",
  "na", "missing", "unspecified", "not available" or an empty string) only as
  a whole word and once per value. "Regional", "Canada", "anaplastic" or
  "NACT" no longer count through "na", and "Unknown/unstaged/unspecified"
  counts once instead of twice. Matching runs on the distinct values, which
  makes `check_na()` about ten times and `lv()` about a third faster on a
  257,000-row SEER table.

* `fmt_ref()` keeps batching with scalar `na.rm` and `lineend` arguments while
  retaining native rendering, missing-value warnings and fallback for other args.

* `fmt_ref()` creates separate reference layers for each subplot, so subsequent
  edits to one subplot's reference data or styles do not alter its peers.

* `fmt_ref()` uses native per-line layers when facet expressions reference its
  helper-column prefix, preserving panels without evaluating data callbacks.

* `fmt_ref()` constructs self-contained reference mappings and layers, avoiding
  retention of peer plots and their data when a formatted subplot is extracted.

* `fmt_ref()` uses factor color labels consistently in batched and native layers,
  preserving numeric palette indices, missing colors and encoded transparency.

* Dedicated `fmt_ref()` regression tests cover native rendering, transformed and
  non-numeric positions, nested containers, input preservation and deferred data.

* `fmt_ref()` gives argument-specific errors for empty and non-vector line styles
  when positions are supplied. Unused styles, native missing-value semantics,
  date positions and discrete category labels are retained.

* `fmt_ref()` rejects `colour` with a suggestion to use its `color` parameter,
  avoiding duplicate aesthetics and silently ignored colour requests.

* `fmt_ref()` batches reference lines by direction, retaining per-line styles,
  facet replication and existing colour scales.
  Other geom arguments keep the native per-line path for compatibility.

* `fmt_ref()` rejects geom intercept argument names with a clear suggestion to
  use `x` and `y`. The formatting vignette now uses those supported arguments.

* `fmt_boxplot()` aligns independent overlays with scalar fixed source x or y
  positions by mapping those constants before computing statistics. Explicit
  boxplot positions and cleared mappings retain priority; fixed vectors are
  not copied and data callbacks remain deferred.

* `fmt_boxplot()` tries range-only blank layers after ordinary sample layers,
  retaining blank-only sources and documenting explicit source selection when
  point annotations share a plot with sample points.

* `fmt_boxplot()` supports independent vector mappings without an explicit
  data frame while retaining their environments and deferred evaluation.

* `fmt_boxplot()` retains the first single-axis source instead of replacing it
  with later two-axis layers in independent overlays.

* `fmt_boxplot()` preserves the mapping-source order when explicit data are
  supplied, avoiding unused parent columns in independent overlays.

* `fmt_boxplot()` matches data, mapping and stat argument names exactly,
  preventing unrecognized names from changing samples or statistics while
  retaining native geom validation and warnings.

* `fmt_boxplot()` preserves explicit summary mappings for identity statistics,
  supporting vertical and horizontal precomputed boxplots without injecting
  unrelated raw-data axes. Data callbacks remain deferred.

* `fmt_boxplot()` selects data and position mappings actually used by existing
  layers before unused parent settings, avoiding incompatible or empty parent
  samples. Automatic empty data frames are skipped; explicit empty data and
  deferred callbacks retain their normal behaviour.

* `fmt_boxplot()` skips text, label, segment, curve and reference-line layers
  when selecting samples automatically, preserving valid single-axis sources
  instead of replacing them with annotation coordinates.

* `fmt_boxplot()` preserves explicitly cleared x or y mappings in independent
  overlays, including cleared mappings inherited from an existing source layer.

* `fmt_boxplot()` rejects malformed argument lists, invalid inheritance flags,
  non-aesthetic mappings and non-plot gg components with clear input errors.

* `fmt_boxplot()` honours explicitly supplied outlier shapes, including `NULL`,
  while retaining hidden outlier markers as the default.

* `fmt_boxplot()` formats every leaf of nested patchworks while preserving
  layouts, annotations, plot-list names and non-plot placeholders or overlays.

* `fmt_boxplot()` resolves independent overlays from existing layer data and
  position mappings, preserving deferred evaluation and single-axis boxplots.
  Missing sources now give a clear error instead of enabling inheritance.

* `fmt_boxplot()` retains explicit data, mappings and deferred data callbacks
  in independent layers, filling only missing position mappings from the plot.

* `fmt_panel()` lets restored grid placeholders inherit blank parent-grid
  settings during and after formatting, preserving explicit blank-inheritance
  overrides and the restoration of grids hidden by a blank root line.

* `fmt_panel()` gives automatically restored grids contrasting colours when
  a blank root line hides them, including on dark panels with `theme_void()`,
  while preserving explicit colours and transparent backgrounds.

* `fmt_panel()` retains empty themes in its batch cache on older ggplot2
  versions, keeping batch grid output identical to formatting plots individually.

* `fmt_panel()` reuses a recent additional theme in batches, including after
  the four-theme cache stops scanning, avoiding repeated grid resolution when
  later plots share a theme.

* `fmt_panel()` checks automatically restored grid contrast against the colour
  of transparent panel fills composited over a known opaque plot background,
  preserving background transparency and explicit grid colours.

* `fmt_panel()` rejects themes, aesthetic mappings and other non-plot `gg`
  components instead of returning a theme or silently producing `NULL`.

* `fmt_panel()` corrects matching background colours in automatically restored
  major, minor and axis-specific grids while preserving explicit plot styles.

* `fmt_his()` follows binned position mappings before and after statistics,
  matching native distribution counts and geometry while preserving original
  points, axes and unscaled mappings.

* `fmt_his()` delegates unscaled distributions without an x scale to native
  ggplot2 statistics, retaining supported histograms instead of returning empty layers.

* `fmt_his()` preserves final `after_scale()` x mappings without evaluating
  them again, keeping distribution positions aligned with native layers.

* `fmt_his()` normalizes time-difference samples to numeric positions while
  retaining their units, preventing empty histogram and density overlays.

* `fmt_his()` retains the original panel's resolved x limits when computing
  distributions, including function, formula and partial limits. Automatic
  density grids also cover the original scale range, preserving visible tails
  for externally supplied samples without retraining the original axes.

* `fmt_his()` preserves unscaled `I()` x mappings, preventing repeated
  transformations and scale-limit censoring of their distribution samples.

* `fmt_his()` skips inapplicable layer data when resolving distribution
  samples, including annotations and data frames missing an explicit variable.
  Function and formula data retain their deferred evaluation.

* `fmt_his()` transforms continuous distribution samples once using each
  panel's final x scale, avoiding redundant transformations while retaining
  original axes and externally supplied samples.

* `fmt_his()` rejects unsupported coordinates added after formatting during
  plot building, with the same clear error as coordinates supplied initially.

* `fmt_his()` documents standard facet matching for external data, including
  repeated samples and newly introduced panels, and adds a deferred-facet example.

* `fmt_his()` identifies its own distribution layers without reserving a
  mapped aesthetic name, preserving unrelated fields with matching names.

* `fmt_his()` evaluates each distribution layer's x mapping once per build
  and reuses the evaluated values for its statistics.

* `fmt_his()` preserves individual facet scales, including scales added after
  formatting, and avoids applying their position transformations twice.

* `fmt_his()` anchors default overlays to the display bottom when Cartesian
  coordinates reverse the vertical direction.

* `fmt_his()` retains distribution layers and their individual settings when
  a facet is added or replaced after formatting.

* `fmt_his()` preserves the plot when a density panel has fewer than two
  samples or a distribution layer has no finite samples.

* `fmt_his()` defers overlay scaling to the normal plot build, avoiding an
  extra evaluation of original statistics and data callbacks. Overlay heights
  follow later axis changes and repeated calls keep their individual settings.

* `fmt_his()` validates overlay controls and documents their defaults, units,
  mode-specific effects and supported mappings with runnable simulated examples.

* `fmt_his()` resolves layer data and preserves x-mapping expressions and
  their environments, including `.data` and `.env` pronouns.

* `fmt_his()` traverses nested patchworks recursively while preserving layouts,
  annotations, spacers, wrapped grobs and plot-list names.

* `fmt_his()` uses independent distribution mappings, avoiding inherited
  groups, weights and missing aesthetics in externally supplied data.

* `fmt_his()` scales each facet independently and keeps distribution layers out
  of position-scale training, preserving original axes and externally supplied samples.

* `fmt_his()` preserves flipped and fixed-ratio Cartesian coordinates and
  correctly positions overlays on transformed axes without transforming limits twice.

* `fmt_his()` anchors histogram and density fills to the requested lower
  boundary, including negative y ranges and explicit `y_rescale` intervals.

* `fmt_his()` preserves histogram frequency and density ratios when every
  computed bin or density value is positive, including equally populated bins.

* `fmt_panel()` reuses resolved settings for repeated themes within a batch,
  with a bounded cache that stops after consecutive theme mismatches.

* `fmt_panel()` gives automatically restored grids a contrasting grey when their
  colour matches a known opaque background, preserving explicit grid colours.

* `fmt_panel()` uses absolute millimetres for grid and border widths and rejects
  relative width objects before rendering.

* `fmt_panel()` restores hidden grids without fixing inherited styles onto
  axis-specific elements, so later parent grid themes still take effect.

* `fmt_panel()` builds shared panel settings once and avoids redundant plot copies
  when restoring grid lines.

* `fmt_panel()` documents its grid-style fallback, protected cells and extra-theme
  overrides, with regressions for rendering, computed data and caller-owned plots.

* `fmt_panel()` reports malformed border, colour, line-width and line-type
  arguments before rendering; transparent colours and zero widths remain valid.

* `fmt_panel()` formats every ordinary leaf of nested patchworks and lists,
  preserving container layouts, annotations and list names.

* `fmt_scale()` merges deferred argument abbreviations by their matched names
  in call order, including `trans` / `transform`; duplicates within one call
  remain errors and explicit `NULL` settings are retained.

* `fmt_panel()` restores enabled grids when switching modes or formatting themes
  that previously hid their grids, retaining available inherited line styling.

* `fmt_panel()` consistently hides axis-specific grid lines and applies explicit
  grid styling to both axes.

* `fmt_scale()` uses native scales for statistic-generated axes, including
  categorical `after_stat()` values and implicit statistic default mappings.

* `fmt_scale()` defers dynamic mapping evaluation to normal plot building,
  preserving function-call counts, lazy bindings and random-number state.

* `fmt_scale()` retains the same observations for partially automatic limits
  when changing between increasing and decreasing transformations.

* `fmt_expand()` leaves lazy mapping bindings unevaluated until plot building,
  retaining native mapping evaluation order and random-number state.

* Alternating `fmt_expand()` and `fmt_scale()` retains all deferred settings;
  the most recent formatter takes precedence when both set expansion.

* `fmt_expand()` defers active bindings in mapping environments without
  evaluating them or changing the random-number state during formatting.

* `fmt_expand()` retains native scales when axes are supplied by statistic
  default mappings, including categorical outputs from custom statistics.

* `fmt_scale()` preserves observations when changing to or from a reversed
  transformation, including on the minimum supported ggplot2 version.
* `fmt_scale()` formats all leaves of nested patchworks and applies settings
  to native scales for function and formula layer data without extra data calls.
* `fmt_scale()` validates named axis lists, matches unambiguous argument
  abbreviations consistently, and retains the cause of scale construction errors.
* `fmt_scale()` supports controls on existing binned position scales and reuses
  unchanged scales. Changed axes clone once per plot without retaining prior
  scale instances or bound callback histories.
* The formatting vignette uses the current `fmt_scale(x = ..., y = ...)` API.

* `fmt_expand()` retains native scale inference for computed statistics,
  including categorical `after_stat()` mappings.

* `fmt_expand()` preserves native `scale_type()` dispatch for extension classes,
  including implicit binned position scales, without extra dispatch calls.

* `fmt_expand()` defers function-call mappings to normal plot building,
  avoiding extra evaluations and preserving random mappings. Function errors
  are reported at build time with their original cause.

* `fmt_expand()` keeps scale storage bounded when padding changes repeatedly,
  retaining custom scale classes, fields and clone behavior without chaining
  previous instances as parents.

* `fmt_expand()` and `fmt_scale()` ignore empty position mappings when
  choosing a scale, so later non-empty layers retain their native scale type.

* `fmt_expand()` retains native scales for function and formula layer data,
  resolving them during plot building without extra calls to the data function.

* `fmt_expand()` and `fmt_scale()` infer only initial-stage mappings, keeping
  computed statistics separate from same-named source columns and accepting
  legacy statistic mappings.

* `fmt_scale()` updates only the supplied settings of an existing position
  scale instead of replacing it, so limits, breaks, labels, transformation,
  expansion and secondary axes set earlier are kept. Continuous limits use the
  existing transformation.

* `fmt_expand()` reuses unchanged scales and clones changed scales only once
  per plot, avoiding retained clone histories during repeated formatting.

* `fmt_text()` gains `axis_titles` (default `"collect"`), passed to
  `patchwork::plot_layout()`, so labels shared by all panels of a patchwork
  are drawn once. Use `axis_titles = NULL` to keep the previous layout.

* `fmt_expand()` reports ordinary mapping errors with their original cause
  instead of silently substituting a continuous scale. Computed statistics
  remain deferred to ggplot2.

* `fmt_expand()` validates scalar axis choices and finite padding values,
  with documented scalar/asymmetric expansion and temporal units.

* `fmt_expand()` updates every nested patchwork leaf, retaining layouts,
  annotations, free settings, named containers, spacers and inset overlays.

* `fmt_expand()` resolves layer data, mapping overrides and captured variables
  when choosing new scales. Shared detection also supports `fmt_scale()`.

* `fmt_expand()` distinguishes dates, date-times and times, retaining sub-day
  resolution. Shared detection also accepts temporal controls in `fmt_scale()`.

* `fmt_expand()` preserves existing position scales, including transformations,
  limits, custom labels, discrete ordering, binned scales and secondary axes.

* `fmt_com()` limits statistical closures to the current plot's configuration,
  so extracting one formatted plot no longer retains other container plots
  and their data during serialization.

* `fmt_com()` validates layout-vector sizes and transformation domains, matches
  vectors to comparison identities across facet filtering, and supports
  symmetric or left/right tip lengths per comparison without recycling.

* `fmt_com()` fixes one-sided comparison direction to custom pair order,
  reference order, or original mapped group order for automatic pairs, keeping
  axis reordering from reversing the tested alternative.

* `fmt_com()` preserves paired observations through missing-value and scale
  filtering, with joint pair omission. `method.args$id` matches explicit
  subject IDs; ambiguous unequal-size row pairing is rejected.

* `fmt_com()` drops unused comparison levels within each grouped subset,
  retaining valid sparse legend comparisons and their original dodge positions.

* `fmt_com()` retains adjusted P values and labels when grouped subsets have
  different numbers of comparison levels, respecting group/panel adjustment.

* `fmt_com()` honors reference-group comparisons, including pooled references
  and named legend groups, and rejects conflicting custom comparison lists.

* `flatten_patchwork()` rejects unknown, unnamed and duplicate layout controls,
  reporting misspelled arguments and misplaced extra graphics explicitly.
  Multiple graphics remain supported through the `plots` list input.

* `flatten_patchwork()` binds insets before extracting hosts from plain or nested
  lists, retaining composite and grob hosts, their cell names and selection
  boundaries consistently with native patchwork inputs.

* `flatten_patchwork()` emits ordinary inset hosts at the same layout level as
  their neighbours, retaining shared axis and axis-title collection. Selection
  and reordering still operate on complete host/inset cells; returned patchwork
  child indexing now includes inset objects. Composite inset hosts stay intact.

* `fmt_com()` validates comparisons, numeric positions and test-option names;
  resolves unambiguous layer data/mappings and explicit statistical overrides;
  and skips missing panel pairs without failed-test warnings. Retained unused
  axis categories no longer compress ordinary or grouped bracket positions.

* `fmt_com()` transforms absolute bracket positions from data units and resolves
  proportional positions within each panel's trained y range. Explicit positions
  no longer receive an implicit nudge; a supplied bracket nudge remains supported.

* `fmt_com()` formats all ordinary leaves of nested patchworks and plot lists,
  retaining layout, annotations and names while skipping spacers, guide areas,
  insets and frozen wrapped graphics.

* `fmt_com()` supports pair selection for Dunn, Tukey and Games-Howell tests
  without passing unsupported comparison arguments. Their full-family
  adjustment is retained; adjusted-only methods display adjusted stars.

* `fmt_com()` honors explicit grouped comparisons and statistical mappings,
  resolving requested pairs within each subset and retaining native dodge
  positions. Default trajectory grouping remains ignored for x comparisons.

* `fmt_com()` merges named ggpubr arguments with defaults, allowing paired and
  one-sided test options, custom significance symbols and font overrides without
  duplicate arguments. Pair selection remains controlled by `com_method`.

* `fmt_com()` accepts adjusted P-value labels and custom ggpubr templates while
  retaining its default raw P-value stars.

* `fmt_com()` resolves comparisons from observed groups and trained axis
  positions, preventing missing factor levels from silently selecting another
  group. Consecutive and all-pairs comparisons respect panel-local scale order.

* `flatten_patchwork()` documents collection scope changes after flattening,
  multiple guide-area behavior, and wrapped groups for retaining nested scopes.
  Examples cover composite inset hosts and protected guide groups.

* `flatten_patchwork()` rejects duplicate cell names when a character design
  would merge them, preventing silent loss of repeated selections. Unnamed
  lists retain positional repetition in character designs.

* `flatten_patchwork()` keeps cell names through nested lists without adding
  container-name prefixes, including named plots with insets in character
  layout designs.

* `flatten_patchwork()` groups insets with their host before recursion, retaining
  a composite host as one selectable cell and preserving inset coordinates
  relative to that entire host.

* `flatten_patchwork()` distinguishes a freed plot from its enclosing patchwork,
  allowing containers ending in `free()` leaves to flatten, render and retain
  their overall annotations and collection settings.

* `flatten_patchwork()` reports the index and original cause of unreadable
  patchwork children instead of silently removing them from the result.

* `flatten_patchwork()` preserves top-level annotations and collection settings,
  accepts explicit layout overrides and keeps `free()` containers intact.
  Grid geometry is rebuilt from the requested output layout.

* `flatten_patchwork()` retains nested insets with their main plot during
  flattening, selection and reordering, preserving overlay placement.

* `flatten_patchwork()` validates selection and row-interleaving indices before
  arranging plots, preventing fractional-index omissions and empty output.
  Integer exclusion, repetition and zero indices retain their existing meaning.

* `flatten_patchwork()` accepts single plots and nested lists, retaining names
  for named layout designs and rejecting invalid list elements.

* `fmt_legend()` reuses unchanged guide layouts and keeps a stable container
  parent for layout updates, preventing accumulated wrappers during repeated
  formatting while retaining later native guide edits.

* `fmt_legend()` scales inherited legend text and title margins, leaving other
  plot text unchanged and retaining automatic margin adaptation.

* `fmt_legend()` collects guides normally when inside plots only use `I()`
  mappings without explicit scale limits, retaining real guides and layer
  mapping overrides without evaluating data callbacks.

* `fmt_legend()` preserves inside legends generated by fixed aesthetics,
  explicit scale limits and forced layer legend display during collection.

* `fmt_legend()` retains key-size inheritance when resizing width or height,
  respecting local guide sizes, relative dimensions and colour-bar direction.

* `fmt_legend()` composes existing glyph factors when a scaled guide is reused,
  preventing recursive guide callbacks while retaining layout and data.

* `fmt_legend()` treats size factors of one as unchanged, returning the exact
  input for neutral-only calls and avoiding accumulated guide clones. Mixed
  calls still apply their other formatting controls and validate inputs.

* `fmt_legend()` includes explicit legend, box, text and title margins in
  overall scaling, including local guides and collected guide boxes. Automatic
  text margins remain adaptive, and independent key sizing leaves margins alone.

* `fmt_legend()` scales spacing in collected guide boxes at each patchwork
  level, including existing annotation themes, without rescaling legend keys.

* `fmt_legend()` checks visible guides within each collection scope, respecting
  nested `keep` layouts, explicit guide positions and disabled guides instead
  of cancelling unrelated outer guide collection.

* `fmt_legend()` retains automatic local guide dimensions and text margins,
  allowing scaled colour bars and legends to adapt when their position changes.

* `fmt_legend()` respects later explicit guide layout definitions from
  `guides()` and scales while retaining deferred layout for default guides.

* `fmt_legend()` scales legend glyphs with both ggplot2 3.5 and current guide
  callbacks, passing the theme only when the native method supports it.

* `fmt_legend()` leaves explicit axis guides unchanged when positioning,
  styling or resizing legends, preventing misplaced axes and scaling errors.

* `fmt_legend()` validates controls for empty lists, spacers, guide areas and
  wrapped graphics before returning containers without editable data plots.

* `fmt_legend()` recognizes aesthetics renamed by `ggnewscale`, updating titles
  and guide styling across multiple colour and fill scales. `ggnewscale` is an
  optional suggested package used for compatibility tests.

* `fmt_legend()` scales explicit global key spacing in both directions,
  matching guide-local spacing without changing native inherited defaults.

* `fmt_legend()` hides explicit guides through the plot position without
  discarding their type, titles or settings, allowing later position changes to
  restore them while keeping intentionally disabled guides hidden.

* `fmt_legend()` isolates guide and scale inheritance environments from working
  plots and avoids cloning empty guide containers for theme-only formatting,
  preventing excessive serialized-object growth after repeated calls.

* `fmt_legend()` warns and keeps subplot guides when requested or existing
  collection layouts contain inside legends, preventing their silent loss.

* `fmt_legend()` resolves local guide dimensions from the guide's own position,
  retaining horizontal colour bars and legend title margins when scaling by one.

* `fmt_legend()` returns the original object for calls with no formatting
  controls, retaining container validation while avoiding recursive traversal,
  theme construction and guide cloning.

* `fmt_legend()` collects guides for a single plot with a guide area, warns when
  collection is requested for a list while retaining its return type, and
  synchronizes styling in existing nested collection layouts without replacing
  layouts, annotations or free settings. Identical guides are deduplicated;
  different guides remain separate.

* `fmt_legend()` validates positions, directions, themes, titles, collection flags,
  scaling factors and layout dimensions before editing plots. Numeric positions
  and corner shortcuts use the current inside-position theme interface.

* `fmt_legend()` merges local guide styling and retains guide order, reversal and
  aesthetic overrides when combining controls. Legend glyph sizes scale after
  native key construction, preserving mapped sizes and repeated scaling while
  leaving plotted data and caller-owned guide objects unchanged.

* `fmt_legend()` scales each subplot from its own theme after applying new
  legend styling, retaining blank text and title elements and collected-guide
  scaling rather than copying the first subplot's sizes.

* `fmt_legend()` multiplies existing legend units and spacing without converting
  them to lines. A scale of one retains the rendered legend size; independent
  width and height factors combine with the overall scaling factor.

* `fmt_legend()` retains continuous colour bars, binned colour steps and disabled
  guides when resizing or arranging legends, and defers guide resolution until
  normal plot building without evaluating layer data during formatting.

* `fmt_legend()` renames default and layer-mapped legend titles, including
  explicit guide titles, without modifying shared input scales or guides.

* `fmt_bg()` clips its background stripes to the panel when coordinate
  clipping is disabled, preserving foreground annotations outside the panel.

* `fmt_bg()` respects explicit discrete position scales when layers supply
  numeric mapped or fixed positions, including flipped coordinates.

* `fmt_bg()` checks complete named manual colours against displayed scale
  categories, allowing unused data categories to be excluded by scale limits
  without resolving an unnecessary palette.

* `fmt_bg()` draws missing-category stripes in free-scale panels containing
  only missing values when other panels have valid categories, while plots
  with no non-missing categories still draw no background.

* `fmt_bg()` background methods retain only axis and colour settings, preventing
  old plot objects from accumulating in closures and serialized plots after
  repeated formatting.

* `fmt_bg()` resolves one category colour map for all panels and data layers,
  keeping unnamed and palette colours consistent across free-scale facets.

* `fmt_bg()` defers mapping expressions and data callbacks to ggplot, supporting
  `after_stat()` categories without changing random draws or executing callbacks
  twice. Axis and palette checks for deferred mappings occur during drawing.

* `fmt_bg()` reads layer data generated by functions and formulas and selects
  categorical data mappings past numeric annotation layers.

* `fmt_bg()` uses trained layout scales when drawing polar sectors and radial
  bands, fixing rendering failures with `coord_polar()` and `coord_radial()`.

* `plt_sankey()` adds `label_args$lineheight` to control multiline label spacing
  for boxed and plain text. The default 1.2 preserves the existing appearance.

* `fmt_bg()` validates opacity, returns empty or entirely missing categories
  unchanged, and skips background construction when `alpha = 0`.

* `fmt_bg()` replaces its own background layer on repeated calls, retaining
  other layers and avoiding accumulated transparency. New colors and opacity
  update the existing background without modifying the input plot.

* `fmt_bg()` formats every data plot in nested patchworks and lists while
  retaining layouts, annotations, names and freed alignment. Spacers, guide
  areas, fixed wrapped graphics and inset overlays are left unchanged.

* `plt_sankey()` groups styling in `flow_args`, `node_args` and `label_args`.
  This replaces the old top-level `alpha`, `width`, `space`, `label_size` and
  `label_hjust` arguments; migrate them to the corresponding list fields.
  It also supports label thresholds, plain text, percentage precision,
  `show_text = "none"`, custom themes and PDF output through `save`.

* `fmt_bg()` creates background bounds after position-scale transformations,
  retaining stripes on log-scaled axes without warnings from infinite bounds.

* `fmt_bg()` supports facet expressions and marginal panels, binds stripe colors
  during panel drawing, and retains the original fill scales and legends.
  It no longer expands all categories across the raw facet combinations.

* `fmt_bg()` aligns stripes with trained category positions, scale limits,
  unused and missing categories, free-scale facets, and flipped coordinates.
  Background rectangles no longer expand the original panel ranges.

* `plt_sankey()` keeps labels centered on their nodes when changing node spacing.

* `fmt_bg()` supports character and logical categories, mapping expressions,
  and data and mappings supplied directly to a layer. Continuous axes are
  skipped with an informative warning.

* `plt_sankey()` keeps nodes distinct across variables even when their labels
  match, and retains node colours when changing label styles.

* `fmt_bg()` honors manual colors without requiring `plotthis`, retains its
  default rainbow palette, and reports invalid colors and palette errors.

* `plt_sankey()` accepts named `vars` vectors mapping column names to axis
  labels, including line breaks. Unnamed vectors retain their existing behavior.

* `fmt_axisTile()` preserves native axis decorations when transforming category
  boundaries, including with ggplot2 3.5.0.

* `fmt_axisTile()` makes panel-relative color strips follow their axis guides
  during patchwork axis collection. Different palettes retain separate guides,
  including color-only strips without text labels.

* `fmt_axisText()` retains rich text inherited from the global theme, including
  side-specific elements, guide formatting and repeated rotations. Complete
  plot themes retain precedence, and the global theme is not modified.

* `fmt_axisText()` retains plot-level rich text when updating guide rotations
  or local guide themes, including guides configured on scales. Inherited
  text properties, relative sizes and caller-owned guides are preserved.

* `fmt_axisTile()` preserves rich-text axis element classes and layout settings,
  avoiding incompatible element merges. Text-mode colors follow each rich label's
  axis position rather than its internal text fragment coordinates.

* `fmt_axisTile()` help uses self-contained simulated examples and explains
  scale labels, physical axis selection, facets, nested containers and repeated
  calls. Other guide kinds retain their original plots instead of being replaced
  with a standard axis guide. Native guides avoid constructing a separate tile
  plot for every leaf; text colors use direct position matching, and later
  relative text sizes are resolved once.

* `fmt_axisTile()` respects physical axis sides, retains scale-guide controls
  after coordinate flipping, leaves disabled guides and continuous labels intact,
  uses non-empty layer data even with an empty global data frame, and reports
  unsupported non-Cartesian coordinates explicitly.

* `fmt_axisTile()` visits editable leaves in nested patchworks and named lists,
  retains layouts, annotations, freed alignment, fixed graphics and insets,
  and supports repeated calls and switching modes without nesting tile strips.

* `fmt_axisTile()` colors trained axis values instead of raw data levels,
  respecting scale order, breaks, display labels, unused levels and NA values.
  Both modes use axis guides, retain axis titles and defer data/statistic
  evaluation until drawing. Text mode no longer uses vectorized theme elements.
  Tile thickness retains its main-panel proportions, and the existing
  patchwork/list return types are retained. The guide API requires ggplot2 >= 3.5.0.

* `fmt_axisText()` returns its validated input unchanged for empty calls and
  avoids repeated empty-theme construction and element-tree lookups. Explicit
  additional theme fields retain precedence. Help and examples cover the
  updated behavior.

* `fmt_axisText()` validates scalar angles, justification, sizes, colors and
  font faces immediately with argument-specific errors. Relative sizes,
  transparent colors and justification outside 0--1 remain supported.

* `fmt_axisText()` computes automatic justification for each Cartesian axis side,
  handles full turns consistently and retains explicitly supplied justification.

* `fmt_axisText()` retains existing text element classes, including rich text,
  custom properties and blank parents, without reapplying relative font sizes.

* `fmt_axisText()` applies formatting through plot, scale and secondary-axis
  guides, including flipped and radial coordinates. Other guide settings and
  original objects are retained; justification alone keeps existing guide angles.

* `fmt_axisText()` updates explicitly styled primary, secondary and radial axis
  text elements while retaining blank sides and unrelated element properties.

* `fmt_axisText()` visits every data plot in nested patchworks and lists while
  retaining layouts, annotations, names, freed alignment and inset overlays.

* `fmt_axisText()` applies explicit horizontal and vertical justification without
  requiring a rotation angle, retaining the existing angle and other styling.

* `fmt_axisTile()` validates named color maps and scalar styling arguments,
  uses the intended fallback colors for missing categories, honors `show_text`
  in both modes, and leaves empty data plots unchanged.

* `plt_sankey()` supports `show_text = "all_wrap"` to place the node name
  on the first line and the count and percentage together on the second line.
  The default `"all"` and existing label styles retain their single-line output.

* `fmt_axis()` hides explicitly styled radial text, major/minor ticks and tick
  lengths, including local guides and secondary axes. In radial plots, `x.axis`
  selects theta and `y.axis` selects r, following ggplot2 theme inheritance for
  either theta-variable mapping while retaining axis lines and plotted data.

* `fmt_axis()` also hides elements styled by guide-local themes in `guides()`,
  position scales and secondary axes. Other guide settings, unselected axes,
  legends and the caller's original guide objects are retained.

* Automatic `fmt_axis()` selection on lists retains spacer, guide-area and
  fixed-graphic cells, as well as nested container layouts. Inferred dimensions
  and capacity checks use the list's top-level grid entries.

* `fmt_axis()` help and formatting examples explain single-plot hiding, recursive
  indices, layout precedence, secondary axes, fixed graphics and scale-sharing
  limits. The vignette now uses `x.axis = TRUE` to hide a single x-axis.

* Recursive formatters exclude inset overlays containing patchworks from the
  editable plot count. Axis indices and automatic layout selection address
  only the main grid, and inset axes remain intact.

* `fmt_axis()` constructs only requested axis themes and merges x/y hiding
  before modifying each selected plot once. Combined and separate axis calls
  retain the same rendered pixels.

* `fmt_axis()` returns unchanged inputs after validation when no axes are
  selected, avoiding recursive extraction, reconstruction and unused themes.
  Container types, names, deferred data evaluation and RNG state are retained.

* `plot_dims` consistently gives layout-based axis selection precedence over
  both manual selectors, including one-row, one-column and single-plot layouts.

* `fmt_axis()` validates logical selectors and integer plot indices, rejects
  missing, fractional and out-of-range indices, and applies duplicate indices
  only once. Empty numeric selections and `NULL` retain the current axes.

* `fmt_axis()` rejects invalid or undersized layout dimensions with explicit
  errors. Empty trailing rows retain the last occupied row's x-axes.

* Automatic `fmt_axis()` selection follows patchwork cell positions, including
  column-major grids, spacers, guide areas, nested layouts and spanning designs.
  Existing layouts and annotations are retained and insets do not occupy cells.

* `fmt_axis()` hides explicitly styled axis sides and secondary axes, including
  minor ticks where supported by ggplot2, without changing the plotted data.

* `fmt_tag()` warns when the input already has automatic patchwork tag levels.
  User-owned automatic and manual tags are retained, while repeated calls
  still replace only `fmt_tag()` labels.

* Missing `fmt_tag()` colours are consistently transparent in both placement
  modes, including untyped `NA` and mixed numeric palette vectors. Infinite
  palette indices fail during argument validation.

* `fmt_tag()` checks evaluated compound padding and radius units, rejecting
  negative or non-finite lengths before drawing while retaining valid unit
  arithmetic and restoring the caller's graphics devices.

* `fmt_tag()` skips fixed wrapped graphics with a warning, so invisible labels
  do not consume the numbering of editable data plots.

* Retagging plots retains patchwork's freed alignment settings, including
  switches between inside and outside labels.

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

* `fmt_strip()` retains the inherited text face with `label_color = NULL` even
  when an explicit or transparent strip fill is supplied.

* Strip formatters reject frozen `wrap_elements()` panels explicitly instead of
  silently losing or retaining strips. Format the original ggplot before wrapping;
  inset overlays remain outside the formatting grid.

* `fmt_strip2()` inherits ggh4x themed strips' text sizes, angles and colours,
  including hidden strips and repeated calls. Explicit colours retain precedence.

* Reapplying `fmt_strip(strip = FALSE)` or label-free `fmt_strip2()` hides native
  strips after theme changes, retaining the saved restoration settings.

* `fmt_strip2()` excludes insets from grid dimensions and header positions,
  preserving user insets and outside `fmt_tag()` labels in nested containers.

* `fmt_strip2()` retains native single-panel facets' shrink setting, preserving
  raw-data scale ranges when their headers are replaced.

* `fmt_strip()` preserves custom row/column labellers, other variables' mappings
  and combined single-line labels when replacing the first facet variable.
  Repeated relabelling reuses the original labeller rather than stacking wrappers.

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
