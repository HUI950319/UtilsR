# UtilsR [![](reference/figures/logo.png)](https://hui950319.github.io/UtilsR/)

**UtilsR** is an R utility toolkit for everyday data work: variable
inspection, statistical formatting, 256 colour palettes, 11-type
categorical plotting, unified continuous variable plotting, and a
chainable ggplot2 formatting system.

**Documentation**: <https://hui950319.github.io/UtilsR/>

## Installation

``` r
pak::pak("HUI950319/UtilsR")

# or
devtools::install_github("HUI950319/UtilsR")
```

Optional dependencies for special chart types

``` r
# Sankey
pak::pak("davidsjoberg/ggsankey")

# Chord, Venn, UpSet
install.packages(c("circlize", "ggVennDiagram", "ggupset"))
```

## Feature Highlights

- **[`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md)**
  – One function, 11 chart types (bar, pie, ring, rose, dot, trend,
  area, sankey, chord, venn, upset), 27+ parameters
- **[`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md)**
  – One function, 4 chart types (violin, box, bar, dot) with statistical
  comparisons, overlays, split/stack layout
- **[`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md)** –
  Instant variable summary for data.frame and Seurat objects with
  grouping and cross-tabulation
- **`fmt_*()`** – Chainable ggplot2 formatting: axes, tags, legends,
  reference lines, strips, comparisons, backgrounds, scales, and more
- **256 built-in palettes** via
  [`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md)
  /
  [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md),
  plus 11 hand-picked palettes (`pal_lancet`, `pal_ditto`, `pal_igv`, …)
- **[`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md)**
  – Recode, reorder, reverse, binarise, group, and combine factors in
  one call

## Functions at a Glance

| Category      | Functions                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | Purpose                                                                                       |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| **Inspect**   | [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md), `na()`, [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md), [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Variable summary, missing values, system & memory info                                        |
| **Factor**    | [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md), [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Recode / reorder / binarise; numeric binning                                                  |
| **Format**    | [`stat_ci()`](https://hui950319.github.io/UtilsR/reference/stat_ci.md), [`stat_pval()`](https://hui950319.github.io/UtilsR/reference/stat_pval.md), [`stat_ci_parse()`](https://hui950319.github.io/UtilsR/reference/stat_ci_parse.md), [`stat_cohen()`](https://hui950319.github.io/UtilsR/reference/stat_cohen.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | CI strings, p-values, effect sizes                                                            |
| **Plot**      | [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md), [`plt_con()`](https://hui950319.github.io/UtilsR/reference/plt_con.md), [`plt_dist()`](https://hui950319.github.io/UtilsR/reference/plt_dist.md), [`plt_cohen()`](https://hui950319.github.io/UtilsR/reference/plt_cohen.md), [`plt_radar()`](https://hui950319.github.io/UtilsR/reference/plt_radar.md), [`plt_sankey()`](https://hui950319.github.io/UtilsR/reference/plt_sankey.md), [`plt_upset()`](https://hui950319.github.io/UtilsR/reference/plt_upset.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Categorical (11 types), continuous (4 types), distribution, effect size, radar, sankey, upset |
| **Colour**    | [`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md), [`pal_list()`](https://hui950319.github.io/UtilsR/reference/pal_list.md), [`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md), [`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md), [`show_color()`](https://hui950319.github.io/UtilsR/reference/show_color.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | 256 palettes, custom palette creation, console swatches                                       |
| **ggplot2**   | [`fmt_plot()`](https://hui950319.github.io/UtilsR/reference/fmt_plot.md), [`fmt_axis()`](https://hui950319.github.io/UtilsR/reference/fmt_axis.md), [`fmt_tag()`](https://hui950319.github.io/UtilsR/reference/fmt_tag.md), [`fmt_legend()`](https://hui950319.github.io/UtilsR/reference/fmt_legend.md), [`fmt_ref()`](https://hui950319.github.io/UtilsR/reference/fmt_ref.md), [`fmt_strip()`](https://hui950319.github.io/UtilsR/reference/fmt_strip.md), [`fmt_com()`](https://hui950319.github.io/UtilsR/reference/fmt_com.md), [`fmt_bg()`](https://hui950319.github.io/UtilsR/reference/fmt_bg.md), [`fmt_his()`](https://hui950319.github.io/UtilsR/reference/fmt_his.md), [`fmt_scale()`](https://hui950319.github.io/UtilsR/reference/fmt_scale.md), [`fmt_expand()`](https://hui950319.github.io/UtilsR/reference/fmt_expand.md), [`fmt_boxplot()`](https://hui950319.github.io/UtilsR/reference/fmt_boxplot.md), [`fmt_point()`](https://hui950319.github.io/UtilsR/reference/fmt_point.md) | Chainable ggplot2 formatting                                                                  |
| **Theme**     | [`theme_my()`](https://hui950319.github.io/UtilsR/reference/theme_my.md), [`theme_km()`](https://hui950319.github.io/UtilsR/reference/theme_km.md), [`theme_rcs()`](https://hui950319.github.io/UtilsR/reference/theme_rcs.md), [`theme_legend1()`](https://hui950319.github.io/UtilsR/reference/theme_legend1.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Publication-ready themes                                                                      |
| **Operators** | `%ni%`, `%\|\|%`, `%>%`, `%<>%`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Not-in, null default, pipes                                                                   |

## Quick Examples

### `plt_cat()` – 11-Type Categorical Plot

``` r
library(UtilsR)

set.seed(1)
df <- data.frame(
  Type  = factor(sample(c("A","B","C"), 200, TRUE)),
  Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
  Batch = factor(sample(c("B1","B2"), 200, TRUE))
)

plt_cat(df, "Type", "Group", type = "bar")                           # stacked percent
plt_cat(df, "Type", "Group", type = "bar",
        stat = "count", position = "dodge", label = TRUE)            # dodged count
plt_cat(df, "Type", type = "pie", label = TRUE)                     # pie chart
plt_cat(df, "Type", "Group", type = "ring",
        stat = "count", position = "dodge")                          # donut chart
plt_cat(df, "Type", "Group", type = "rose")                         # rose (wind rose)
plt_cat(df, "Type", "Group", type = "dot")                          # Cleveland dot
plt_cat(df, "Type", "Group", type = "trend", stat = "count")        # trend line
plt_cat(df, "Type", "Group", type = "area", stat = "count")         # area chart

# Multi-variable: sankey, chord, venn, upset
plt_cat(df, c("Type", "Group"), type = "sankey")
plt_cat(df, c("Type", "Group"), type = "chord")
plt_cat(df, c("Type", "Group"), type = "venn", stat_level = c("A", "X"))
plt_cat(df, c("Type", "Group"), type = "upset", stat_level = c("A", "X"))

# Split by facet + background bands
plt_cat(df, "Type", "Group", split.by = "Batch", type = "bar")
```

`plt_cat()` parameter reference

| Group      | Parameters                                                                                 |
|------------|--------------------------------------------------------------------------------------------|
| Data       | `stat.by`, `group.by`, `split.by`                                                          |
| Chart      | `type` (11 types), `stat`, `position`                                                      |
| Colour     | `palette`, `alpha`, `NA_color`                                                             |
| Labels     | `label`, `label.size`, `label.fg`, `label.bg`                                              |
| Background | `bg.by`, `bg_palette`, `bg_alpha`                                                          |
| NA/Empty   | `NA_stat`, `keep_empty`                                                                    |
| Layout     | `title`, `subtitle`, `xlab`, `ylab`, `legend.position`, `legend.direction`, `aspect.ratio` |
| Split      | `facet_nrow`, `facet_ncol`, `facet_byrow`                                                  |
| Set types  | `stat_level` (venn/upset positive level)                                                   |

### `plt_con()` – Unified Continuous Variable Plot

``` r
set.seed(1)
df2 <- data.frame(
  value = rnorm(200),
  score = rnorm(200, mean = 2),
  group = factor(sample(c("A", "B", "C"), 200, TRUE)),
  batch = factor(sample(c("B1", "B2"), 200, TRUE))
)

# Basic types
plt_con(df2, "value", "group")                          # violin (default)
plt_con(df2, "value", "group", type = "box")            # boxplot
plt_con(df2, "value", "group", type = "bar")            # mean +/- SD
plt_con(df2, "value", "group", type = "dot")            # bubble dot plot

# Overlays
plt_con(df2, "value", "group", add_box = TRUE, add_point = TRUE)

# Statistical comparisons
plt_con(df2, "value", "group",
        comparisons = list(c("A", "B"), c("A", "C")))

# Multiple features + stack
plt_con(df2, c("value", "score"), "group", stack = TRUE)

# Split by batch
plt_con(df2, "value", "group", split.by = "batch")
```

`plt_con()` parameter reference

| Group      | Parameters                                                                                                 |
|------------|------------------------------------------------------------------------------------------------------------|
| Data       | `stat.by`, `group.by`, `split.by`, `bg.by`                                                                 |
| Chart      | `type` (violin/box/bar/dot), `fill.by` (group/feature)                                                     |
| Colour     | `palette`, `alpha`                                                                                         |
| Overlays   | `add_box`, `add_point`, `add_trend` + styling params                                                       |
| Statistics | `comparisons`, `ref_group`, `pairwise_method`, `multiplegroup_comparisons`, `multiple_method`, `sig_label` |
| Y-axis     | `y.min`, `y.max` (numeric or “qN” quantile), `y.nbreaks`, `same.y.lims`                                    |
| Layout     | `sort`, `stack`, `flip`, `title`, `subtitle`, `xlab`, `ylab`, `legend.*`, `aspect.ratio`                   |
| Split      | `facet_nrow`, `facet_ncol`, `combine`                                                                      |

### Variable Inspection

``` r
lv(iris)                                        # all variables
lv(iris, Species, Sepal.Length)                  # specific columns
lv(iris, pattern = "Sepal")                     # regex match
lv(iris, Sepal.Length, group = "Species")        # grouped summary
lv(iris, count = c(Species))                    # cross-tabulation
```

### Factor Manipulation

``` r
x <- factor(c("I", "II", "III", "IV"))

fct_cat(x, early = c("I","II"), late = c("III","IV"))   # recode
fct_cat(x, "III", "I")                                   # reorder
fct_cat(x, reverse = TRUE)                                # reverse
fct_cat(x, binary_ref = 1)                                # binarise (I vs Others)

df |> mutate(grp = fct_cat(sex, combine = "age"))        # combine columns
```

### Colour Palettes

``` r
pal_lancet                        # 15 colours, Lancet journal style
pal_ditto                         # 40 colours, dittoSeq (scRNA-seq)
pal_igv                           # 48 colours, IGV genome browser
pal_list()                        # browse all 256 palettes
pal_get("lancet", n = 5)          # extract 5 colours

ggplot(data, aes(x, y, color = group)) +
  scale_color_manual(values = pal_lancet[1:3])
```

### Chainable ggplot2 Formatting

``` r
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point()

p |>
  fmt_plot(legend.position = "bottom") |>
  fmt_tag("A") |>
  fmt_ref(xintercept = 5.8) |>
  fmt_point(shape = 21)
```

## Vignettes

| Vignette                                                                                    | Topic                                                                                                                                                                                                                                |
|---------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Categorical Plots](https://hui950319.github.io/UtilsR/articles/plt_cat_guide.html)         | Complete [`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md) guide with all 11 chart types                                                                                                                        |
| [Data Inspection](https://hui950319.github.io/UtilsR/articles/data_inspection.html)         | [`lv()`](https://hui950319.github.io/UtilsR/reference/lv.md), `na()`, [`check_system()`](https://hui950319.github.io/UtilsR/reference/check_system.md), [`check_size()`](https://hui950319.github.io/UtilsR/reference/check_size.md) |
| [Factor Manipulation](https://hui950319.github.io/UtilsR/articles/factor_manipulation.html) | [`fct_cat()`](https://hui950319.github.io/UtilsR/reference/fct_cat.md) and [`fct_num()`](https://hui950319.github.io/UtilsR/reference/fct_num.md)                                                                                    |
| [ggplot2 Formatting](https://hui950319.github.io/UtilsR/articles/ggplot2_formatting.html)   | `fmt_*()` formatting system                                                                                                                                                                                                          |
| [Colour Palettes](https://hui950319.github.io/UtilsR/articles/colour_palettes.html)         | 256 palettes, custom palettes                                                                                                                                                                                                        |

## License

MIT
