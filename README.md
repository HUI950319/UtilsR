# UtilsR

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/HUI950319/UtilsR)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**UtilsR** -- R utility toolkit for data exploration, statistical formatting, colour palettes, plot functions, and ggplot2 formatting.

## Installation

```r
pak::pak("HUI950319/UtilsR")

# or
devtools::install_github("HUI950319/UtilsR")
```

## Functions Overview

| Category | Function | Description |
|----------|----------|-------------|
| **Inspect** | `lv()` | Variable summary for data.frame / Seurat |
| | `na()` | Missing value & data quality analysis |
| | `check_system()` | OS, R version, memory, CPU info |
| | `check_size()` | Object memory profiling |
| **Factor** | `fct_cat()` | Recode, reorder, reverse, binary, group, combine |
| | `fct_num()` | Numeric to factor (cut points or binning) |
| **Format** | `stat_ci()` | Build or reformat CI strings and mean(SD) |
| | `stat_pval()` | Format p-values or add significance stars |
| | `stat_cohen()` | Cohen's d effect sizes with CI |
| **Plot** | `plt_cat()` | **11-type categorical plot** (bar, pie, ring, rose, dot, trend, area, sankey, chord, venn, upset) |
| | `plt_dist()` | Cross-distribution (stacked bar / tile heatmap) |
| | `plt_cohen()` | Cohen's d effect size Cleveland dot plot |
| | `plt_radar()` | Radar (spider) chart |
| | `plt_sankey()` | Sankey diagram for categorical flow |
| | `plt_upset()` | UpSet / Venn diagram for set intersections |
| **Colour** | `pal_lancet`, `pal_ditto`, ... | 11 built-in colour palettes (16-48 colours) |
| | `show_color()` | Display colour swatches in console |
| | `pal_list()` | Browse all palettes |
| **ggplot2** | `fmt_plot()` | Master chaining function for ggplot formatting |
| | `fmt_axis()`, `fmt_tag()`, `fmt_legend()` | Axis, tag, legend formatting |
| | `fmt_ref()`, `fmt_strip()`, `fmt_com()` | Reference lines, strips, comparisons |
| | `fmt_bg()`, `fmt_his()`, `fmt_scale()` | Background, histogram, scales |
| **Theme** | `theme_my()` | Clean general-purpose theme |
| | `theme_km()` | Kaplan-Meier survival curve theme |
| | `theme_rcs()` | Restricted cubic spline theme |
| **Display** | `.cat_line()`, `.cat_box()`, `.cat_message()` | Styled console output |
| | `.cat_tb()` | Enhanced gt table with highlighting |
| **Operators** | `%ni%`, `%\|\|%`, `%>%`, `%<>%` | Not-in, default value, pipe |

## Plot Functions

### `plt_cat()` -- Unified Categorical Plot

A single entry point for **11 chart types** with 27+ parameters. Supports grouping, splitting, dodge/stack, labels, background bands, NA handling, and more.

```r
library(UtilsR)

set.seed(1)
df <- data.frame(
  Type  = factor(sample(c("A","B","C"), 200, TRUE)),
  Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
  Batch = factor(sample(c("B1","B2"), 200, TRUE))
)

# Bar (stacked percent)
plt_cat(df, "Type", "Group", type = "bar")

# Bar (dodged count with labels)
plt_cat(df, "Type", "Group", type = "bar",
        stat = "count", position = "dodge", label = TRUE)

# Pie with title
plt_cat(df, "Type", type = "pie", label = TRUE,
        title = "Type Distribution", subtitle = "n = 200")

# Ring (donut) with dodge
plt_cat(df, "Type", "Group", type = "ring",
        stat = "count", position = "dodge")

# Rose, Dot, Trend, Area
plt_cat(df, "Type", "Group", type = "rose")
plt_cat(df, "Type", "Group", type = "dot")
plt_cat(df, "Type", "Group", type = "trend", stat = "count")
plt_cat(df, "Type", "Group", type = "area", stat = "count")

# Split by batch
plt_cat(df, "Type", "Group", split.by = "Batch", type = "bar")

# Background bands (dodge mode)
df$Region <- ifelse(df$Group %in% c("X","Y"), "R1", "R2")
plt_cat(df, "Type", "Group", type = "bar", position = "dodge",
        bg.by = "Region", bg_palette = c("lightblue", "lightyellow"))

# NA handling
df_na <- df; df_na$Type[1:20] <- NA
plt_cat(df_na, "Type", "Group", type = "bar", NA_stat = TRUE, NA_color = "red")

# Sankey, Chord, Venn, UpSet
plt_cat(df, c("Type", "Group"), type = "sankey")
plt_cat(df, c("Type", "Group"), type = "chord")
plt_cat(df, c("Type", "Group"), type = "venn", stat_level = c("A", "X"))
plt_cat(df, c("Type", "Group"), type = "upset", stat_level = c("A", "X"))
```

**Key parameters:**

| Group | Parameters |
|-------|-----------|
| Data | `stat.by`, `group.by`, `split.by` |
| Chart | `type` (11 types), `stat`, `position` |
| Colour | `palette`, `alpha`, `NA_color` |
| Labels | `label`, `label.size`, `label.fg`, `label.bg` |
| Background | `bg.by`, `bg_palette`, `bg_alpha` |
| NA/Empty | `NA_stat`, `keep_empty` |
| Layout | `title`, `subtitle`, `xlab`, `ylab`, `legend.position`, `legend.direction`, `aspect.ratio` |
| Split | `facet_nrow`, `facet_ncol`, `facet_byrow` |
| Set types | `stat_level` (venn/upset positive level) |

### Other Plot Functions

```r
# Distribution plot (auto stacked bar or heatmap)
plt_dist(df, "Type", "Group")

# Cohen's d effect size
plt_cohen(cohen_result, ref_group = "Control")

# Radar chart
plt_radar(result_df, group = "Group")

# Sankey diagram
plt_sankey(df, from = "Type", to = "Group")

# UpSet / Venn
plt_upset(df_binary, sets = c("A", "B", "C"))
```

## Quick Start

### Variable Inspection

```r
library(UtilsR)

lv(iris)                              # all variables
lv(iris, Species, Sepal.Length)       # specific variables
lv(iris, pattern = "Sepal")          # regex match
lv(iris, Sepal.Length, group = "Species")  # grouped summary
```

### Factor Manipulation

```r
x <- factor(c("I", "II", "III", "IV"))

fct_cat(x, early = c("I","II"), late = c("III","IV"))  # recode
fct_cat(x, "III", "I")               # reorder
fct_cat(x, reverse = TRUE)           # reverse
fct_cat(x, binary_ref = 1)           # binary (I vs Oth)

# Combine columns
df %>% mutate(grp = fct_cat(sex, combine = "age"))
```

### Colour Palettes

```r
pal_lancet                    # 15 colours, Lancet journal style
pal_ditto                     # 40 colours, dittoSeq (scRNA-seq)
pal_igv                       # 48 colours, IGV genome browser
pal_list()                    # browse all

# Use in ggplot
ggplot(data, aes(x, y, color = group)) +
  scale_color_manual(values = pal_lancet[1:3])
```

### ggplot2 Formatting

```r
p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point()

# Chain formatting
p |>
  fmt_plot(legend.position = "bottom") |>
  fmt_tag("A") |>
  fmt_ref(xintercept = 5.8)
```

## License

MIT
