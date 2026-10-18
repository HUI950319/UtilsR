# Flatten nested patchwork objects

Recursively extract ordinary grid cells from nested patchwork objects
and arrange them in a new patchwork, optionally selecting or reordering
cells. `flatten_patchwork()` is the same function under its original
name, kept for existing code.

## Usage

``` r
fmt_flatten(plots, ..., select_inds = NULL, nrow_inds_order = NULL)

flatten_patchwork(plots, ..., select_inds = NULL, nrow_inds_order = NULL)
```

## Arguments

- plots:

  A ggplot, patchwork object, grob, or nested list of these objects.

- ...:

  Named layout arguments passed to
  [`patchwork::wrap_plots()`](https://patchwork.data-imaginist.com/reference/wrap_plots.html),
  such as `nrow`, `ncol`, `design`, `guides` and `axis_titles`. Unknown,
  unnamed and duplicate arguments are rejected. Supply additional
  graphics in `plots` as a list.

- select_inds:

  Integer indices applied after flattening. Positive indices select and
  may repeat plots; negative indices exclude plots. Zero is ignored.
  Missing, fractional, mixed-sign and out-of-range indices are rejected.
  Duplicate cell names matched by a character `design` are rejected; use
  an unnamed list to repeat cells by position in that design.

- nrow_inds_order:

  Single positive integer, at most the number of selected plots, to
  reorder them by interleaving rows. Applied after selection; it does
  not set the output layout's `nrow`. With
  `ceiling(n / nrow_inds_order)` output columns for `n` selected cells,
  plots take the positions that `byrow = FALSE` with
  `nrow = nrow_inds_order` would give them; unlike `byrow`, the cells
  themselves are reordered, so tags then run across rows instead of down
  columns.

## Value

A patchwork object with ordinary grid cells at one level. Insets and
their main plot stay together and count as one cell for
selection/reordering. Containers marked with
[`patchwork::free()`](https://patchwork.data-imaginist.com/reference/free.html)
also remain intact.

## Details

Top-level plot annotations and the `guides`, `axes`, `axis_titles` and
`tag_level` settings are retained for patchwork input. Explicit
arguments in `...` override inherited settings; an explicit `axes`
without `axis_titles` also drops the inherited `axis_titles`, which then
follows `axes` as in
[`wrap_plots()`](https://patchwork.data-imaginist.com/reference/wrap_plots.html).
Grid geometry (dimensions, widths, heights and design) is rebuilt using
`...`; nested annotation and tagging scopes are not promoted. Selection
indices refer to the extracted cells, including spacers, guide areas and
wrapped graphics. A main plot with its insets, or a protected
[`free()`](https://patchwork.data-imaginist.com/reference/free.html)
container, occupies one selection index. Named list entries that produce
one cell retain their name; names inside nested lists are retained
without container-name prefixes. These cell names can be matched to a
character layout design by
[`wrap_plots()`](https://patchwork.data-imaginist.com/reference/wrap_plots.html).

Tags from `plot_annotation(tag_levels)`, including custom tag vectors,
are assigned in output order, so they follow `select_inds` and
`nrow_inds_order` rather than the original positions.

Insets are emitted alongside ordinary hosts at the same layout level,
allowing shared axes and axis titles to be collected. Composite inset
hosts remain intact. The returned object's
[`length()`](https://rdrr.io/r/base/length.html) and `[[` follow native
patchwork child indexing and include inset objects; selection and row
interleaving use complete cells, including each host's insets. Nested
lists are unwrapped before binding each inset to its preceding host, so
list and patchwork inputs retain the same inset boundaries.

Flattening ordinary containers removes their nested collection scopes,
including inner `guides = "keep"` or `guides = "collect"` settings.
Collection is determined by the retained top-level settings and `...`.
Guide areas move to the same output level; when collecting guides,
patchwork uses only the first guide area if several are present. Use
`patchwork::wrap_elements(full = group)` to retain an entire group,
including its nested collection scopes, as one wrapped cell.

## See also

Other plot formatting:
[`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md),
[`fmt_axisText()`](https://hui950319.github.io/UtilsR/reference/fmt_axisText.md),
[`fmt_axisTile()`](https://hui950319.github.io/UtilsR/reference/fmt_axisTile.md),
[`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md),
[`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md),
[`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md),
[`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md),
[`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md),
[`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md),
[`fmt_panel()`](https://hui950319.github.io/UtilsR/reference/fmt_panel.md),
[`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md),
[`fmt_plot_base()`](https://hui950319.github.io/UtilsR/reference/fmt_plot_base.md),
[`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md),
[`fmt_raster()`](https://hui950319.github.io/UtilsR/reference/fmt_raster.md),
[`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md),
[`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md),
[`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md),
[`fmt_strip2()`](https://hui950319.github.io/UtilsR/reference/fmt_strip2.md),
[`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md),
[`fmt_text()`](https://hui950319.github.io/UtilsR/reference/fmt_text.md)

## Examples

``` r
library(ggplot2)
library(patchwork)
p1 <- ggplot(mtcars, aes(mpg, disp)) + geom_point()
p2 <- ggplot(mtcars, aes(gear, disp, group = gear)) + geom_boxplot()
p3 <- ggplot(mtcars, aes(factor(gear))) + geom_bar()
p4 <- ggplot(mtcars, aes(factor(cyl), mpg)) + geom_violin()

# \donttest{
# Flatten nested patchwork
nested <- (p1 | p2) / (p3 | p4)
fmt_flatten(nested, nrow = 1)


# Select specific sub-plots
fmt_flatten(nested, select_inds = c(1, 3))


# Interleave indices 1, 3, 2, 4, then arrange in two columns
fmt_flatten(nested, nrow_inds_order = 2, ncol = 2)


# Retain the overall title and collect matching axis titles
annotated <- nested + plot_annotation(title = "Example plots")
fmt_flatten(annotated, ncol = 2, axis_titles = "collect")


# Names determine placement in a character design
fmt_flatten(list(B = p2, A = p1), design = "AB")


# Keep a composite inset host together
inset_group <- wrap_plots(list(p1 | p2)) +
  inset_element(p3, .5, .5, 1, 1, align_to = "full")
fmt_flatten(list(inset_group, p4), ncol = 2)


# Retain a nested guide scope inside a wrapped cell
kept_group <- (p1 | p2) + plot_layout(guides = "keep")
fmt_flatten(list(wrap_elements(full = kept_group), p3), guides = "collect")

# }
```
