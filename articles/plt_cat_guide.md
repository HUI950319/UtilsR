# plt_cat: Unified Categorical Plot Guide

[`plt_cat()`](https://hui950319.github.io/UtilsR/reference/plt_cat.md)
is a single entry point for **11 categorical chart types** with 27+
parameters. It handles grouping, splitting, dodge/stack, labels,
background bands, NA handling, and more.

## Sample Data

``` r
library(UtilsR)
library(ggplot2)

set.seed(1)
df <- data.frame(
  Type  = factor(sample(c("A","B","C"), 200, TRUE, c(0.5, 0.3, 0.2))),
  Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
  Batch = factor(sample(c("B1","B2"), 200, TRUE))
)
df$Region <- factor(ifelse(df$Group %in% c("X","Y"), "R1", "R2"))
head(df)
#>   Type Group Batch Region
#> 1    A     Y    B2     R1
#> 2    A     X    B2     R1
#> 3    B     Y    B1     R1
#> 4    C     Y    B1     R1
#> 5    A     Y    B1     R1
#> 6    C     Z    B1     R2
```

------------------------------------------------------------------------

## 1. Bar Chart

The most common type. Supports `stat = "percent"` (default) or
`"count"`, and `position = "stack"` (default) or `"dodge"`.

``` r
plt_cat(df, "Type", "Group", type = "bar")
```

![](plt_cat_guide_files/figure-html/bar-stack-1.png)

``` r
plt_cat(df, "Type", "Group", type = "bar",
        stat = "count", position = "dodge", label = TRUE)
```

![](plt_cat_guide_files/figure-html/bar-dodge-1.png)

``` r
plt_cat(df, "Type", "Group", type = "bar",
        flip = TRUE, label = TRUE)
```

![](plt_cat_guide_files/figure-html/bar-flip-1.png)

### No group (single variable)

When `group.by` is omitted, each stat.by level becomes its own bar:

``` r
plt_cat(df, "Type", type = "bar", stat = "count",
        label = TRUE, legend.position = "none")
```

![](plt_cat_guide_files/figure-html/bar-nogroup-1.png)

### Background bands

Use `bg.by` in dodge mode to add alternating background colour bands.
`bg.by` must be a superset of `group.by` (each group belongs to exactly
one bg level).

``` r
plt_cat(df, "Type", "Group", type = "bar",
        position = "dodge", bg.by = "Region")
```

![](plt_cat_guide_files/figure-html/bar-bg-1.png)

``` r
plt_cat(df, "Type", "Group", type = "bar",
        position = "dodge", bg.by = "Region",
        bg_palette = c("lightblue", "lightyellow"),
        title = "Custom Background Colors")
```

![](plt_cat_guide_files/figure-html/bar-bg-custom-1.png)

------------------------------------------------------------------------

## 2. Rose Chart

A bar chart in polar coordinates (`theta = "x"`). Good for cyclical
data.

``` r
plt_cat(df, "Type", "Group", type = "rose")
```

![](plt_cat_guide_files/figure-html/rose-1.png)

``` r
plt_cat(df, "Type", "Group", type = "rose",
        stat = "count", position = "dodge")
```

![](plt_cat_guide_files/figure-html/rose-dodge-1.png)

------------------------------------------------------------------------

## 3. Ring (Donut) Chart

A pie chart with a hole in the center. Supports dodge for grouped spiral
display.

``` r
plt_cat(df, "Type", type = "ring", label = TRUE)
```

![](plt_cat_guide_files/figure-html/ring-1.png)

``` r
plt_cat(df, "Type", "Group", type = "ring",
        stat = "count", position = "dodge")
```

![](plt_cat_guide_files/figure-html/ring-dodge-1.png)

------------------------------------------------------------------------

## 4. Pie Chart

``` r
plt_cat(df, "Type", type = "pie", label = TRUE)
```

![](plt_cat_guide_files/figure-html/pie-1.png)

``` r
plt_cat(df, "Type", type = "pie",
        palette = "Paired",
        title = "Type Distribution",
        subtitle = "n = 200",
        legend.position = "bottom",
        legend.direction = "horizontal")
```

![](plt_cat_guide_files/figure-html/pie-styled-1.png)

------------------------------------------------------------------------

## 5. Trend Chart

Combines stepped area background with bar overlay. Best for showing
trends across ordered groups.

``` r
plt_cat(df, "Type", "Group", type = "trend", stat = "count")
```

![](plt_cat_guide_files/figure-html/trend-1.png)

``` r
plt_cat(df, "Type", "Group", type = "trend",
        stat = "count", label = TRUE)
```

![](plt_cat_guide_files/figure-html/trend-label-1.png)

------------------------------------------------------------------------

## 6. Area Chart

Stacked area chart. Uses continuous x-axis internally.

``` r
plt_cat(df, "Type", "Group", type = "area", stat = "count")
```

![](plt_cat_guide_files/figure-html/area-1.png)

``` r
plt_cat(df, "Type", "Group", type = "area",
        stat = "count", position = "dodge")
```

![](plt_cat_guide_files/figure-html/area-dodge-1.png)

------------------------------------------------------------------------

## 7. Dot Plot

Bubble-style dot plot where size encodes value.

``` r
plt_cat(df, "Type", "Group", type = "dot")
```

![](plt_cat_guide_files/figure-html/dot-1.png)

``` r
plt_cat(df, "Type", "Group", type = "dot",
        label = TRUE, stat = "count")
```

![](plt_cat_guide_files/figure-html/dot-label-1.png)

------------------------------------------------------------------------

## 8. Sankey Diagram

Requires `stat.by` with \>= 2 column names. Shows flow between
categories.

``` r
plt_cat(df, c("Type", "Group"), type = "sankey")
```

![](plt_cat_guide_files/figure-html/sankey-1.png)

``` r
plt_cat(df, c("Type", "Group", "Batch"), type = "sankey")
```

![](plt_cat_guide_files/figure-html/sankey-3-1.png)

------------------------------------------------------------------------

## 9. Chord Diagram

Shows pairwise connections between two categorical variables. Returns
base R graphics (not ggplot).

``` r
plt_cat(df, c("Type", "Group"), type = "chord")
```

![](plt_cat_guide_files/figure-html/chord-1.png)![](plt_cat_guide_files/figure-html/chord-2.png)

------------------------------------------------------------------------

## 10. Venn Diagram

Shows set intersections. Use `stat_level` to specify which level counts
as “positive”.

``` r
set.seed(42)
df_bin <- data.frame(
  A = sample(c("Yes","No"), 200, TRUE),
  B = sample(c("Yes","No"), 200, TRUE),
  C = sample(c("Yes","No"), 200, TRUE)
)
plt_cat(df_bin, c("A","B","C"), type = "venn")
```

![](plt_cat_guide_files/figure-html/venn-binary-1.png)

``` r
plt_cat(df, c("Type", "Group"), type = "venn",
        stat_level = c("A", "X"))
```

![](plt_cat_guide_files/figure-html/venn-stat-level-1.png)

------------------------------------------------------------------------

## 11. UpSet Plot

A scalable alternative to Venn diagrams for showing set intersections.

``` r
plt_cat(df_bin, c("A","B","C"), type = "upset")
```

![](plt_cat_guide_files/figure-html/upset-binary-1.png)

``` r
plt_cat(df, c("Type", "Group"), type = "upset",
        stat_level = c("A", "X"))
```

![](plt_cat_guide_files/figure-html/upset-stat-level-1.png)

------------------------------------------------------------------------

## Cross-cutting Features

### split.by

Split data by a variable and create one panel per level:

``` r
plt_cat(df, "Type", "Group", split.by = "Batch", type = "bar")
```

![](plt_cat_guide_files/figure-html/split-bar-1.png)

``` r
plt_cat(df, "Type", split.by = "Batch", type = "pie",
        facet_ncol = 2)
```

![](plt_cat_guide_files/figure-html/split-pie-1.png)

### NA Handling

Include NA values in the plot with `NA_stat = TRUE`:

``` r
df_na <- df
df_na$Type[1:20] <- NA
plt_cat(df_na, "Type", "Group", type = "bar",
        NA_stat = TRUE, NA_color = "red")
```

![](plt_cat_guide_files/figure-html/na-stat-1.png)

### keep_empty

Preserve dropped factor levels as empty bars:

``` r
df2 <- df[df$Type != "C", , drop = FALSE]
plt_cat(df2, "Type", "Group", type = "bar", keep_empty = TRUE)
```

![](plt_cat_guide_files/figure-html/keep-empty-1.png)

### Label Styling

Customise label appearance with `label.fg`, `label.bg`, and
`label.bg.r`:

``` r
plt_cat(df, "Type", "Group", type = "bar",
        stat = "count", position = "dodge",
        label = TRUE, label.fg = "white", label.bg = "black")
```

![](plt_cat_guide_files/figure-html/label-style-1.png)

### aspect.ratio

Control panel aspect ratio (auto-set to 1 for polar types):

``` r
plt_cat(df, "Type", "Group", type = "bar", aspect.ratio = 0.5)
```

![](plt_cat_guide_files/figure-html/aspect-1.png)

### Custom Palette

``` r
plt_cat(df, "Type", type = "pie",
        palette = c("#FF6B6B", "#4ECDC4", "#45B7D1"),
        label = TRUE)
```

![](plt_cat_guide_files/figure-html/palette-1.png)

------------------------------------------------------------------------

## Parameter Reference

| Group          | Parameters                                                  |
|----------------|-------------------------------------------------------------|
| **Data**       | `stat.by`, `group.by`, `split.by`                           |
| **Chart**      | `type` (11 types), `stat`, `position`                       |
| **Colour**     | `palette`, `alpha`, `NA_color`                              |
| **Labels**     | `label`, `label.size`, `label.fg`, `label.bg`, `label.bg.r` |
| **Background** | `bg.by`, `bg_palette`, `bg_alpha`                           |
| **NA/Empty**   | `NA_stat`, `keep_empty`                                     |
| **Layout**     | `title`, `subtitle`, `xlab`, `ylab`                         |
| **Legend**     | `legend.position`, `legend.direction`                       |
| **Aspect**     | `aspect.ratio`                                              |
| **Split**      | `facet_nrow`, `facet_ncol`, `facet_byrow`                   |
| **Set types**  | `stat_level`                                                |
| **Safety**     | `force`                                                     |
