# UtilsR

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/HUI950319/UtilsR)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**UtilsR** — R utility toolkit for data exploration, factor manipulation, colour palettes, and console styling.

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
| | `fct_num()` | Numeric → factor (cut points or binning) |
| **Colour** | `pal_lancet`, `pal_ditto`, ... | 11 built-in colour palettes |
| | `show_color()` | Display colour swatches in console |
| | `list_palettes()` | Browse all palettes |
| **Display** | `.cat_line()` | Styled separator line |
| | `.cat_box()` | Styled message box |
| | `.cat_message()` | Timestamped log message |
| | `.cat_tb()` | Enhanced gt table with highlighting |
| **Theme** | `theme_clean()` | Clean ggplot2 theme |
| | `theme_km()` | Kaplan-Meier survival curve theme |
| | `theme_rcs()` | Restricted cubic spline theme |
| **Operators** | `%ni%` | Not in (`!%in%`) |
| | `%\|\|%` | Default value (`NULL %\|\|% 0` → `0`) |
| | `%>%`, `%<>%` | Pipe operators |

## Quick Start

### Variable Inspection

```r
library(UtilsR)

lv(iris)                              # all variables
lv(iris, Species, Sepal.Length)       # specific variables
lv(iris, pattern = "Sepal")          # regex match
lv(iris, Sepal.Length, group = "Species")  # grouped summary
```

### Factor Manipulation — `fct_cat()`

All factor operations in one function, works inside `mutate()`:

```r
x <- factor(c("I", "II", "III", "IV"))

# Recode (named args)
fct_cat(x, early = c("I","II"), late = c("III","IV"))
fct_cat(x, g1 = 1:2, g2 = 3:4)      # by index

# Reorder (unnamed args)
fct_cat(x, "III", "I")               # III first, then I, rest follow

# Reverse / Binary / Group / Relabel
fct_cat(x, reverse = TRUE)
fct_cat(x, binary_ref = 1)           # I vs Oth
fct_cat(x, groups = list(early = 1:2, late = 3:4))
fct_cat(x, new_labels = c("One","Two","Three","Four"))

# Combine columns in mutate()
df %>% mutate(grp = fct_cat(sex, combine = "age"))
df %>% mutate(grp = fct_cat(combine = c("sex", "age", "stage")))
```

### Numeric to Factor — `fct_num()`

```r
# Fixed cut points
df %>% mutate(age_grp = fct_num(age, breaks = 65))
df %>% mutate(age_grp = fct_num(age, breaks = c(40, 60)))

# Quantile binning
df %>% mutate(age_q4 = fct_num(age, nbins = 4))
df %>% mutate(age_q3 = fct_num(age, nbins = 3, type = "equal"))

# Custom labels
df %>% mutate(risk = fct_num(score, breaks = c(30, 70),
                             labels = c("Low", "Mid", "High")))
```

### Colour Palettes

11 built-in palettes (16–48 colours), auto-display swatches in RStudio:

```r
pal_lancet                    # 15 colours, Lancet journal style
pal_ditto                     # 40 colours, dittoSeq (scRNA-seq)
pal_igv                       # 48 colours, IGV genome browser
pal_polychrome                # 36 colours, max perceptual distinctness
pal_glasbey                   # 32 colours, Glasbey algorithm
pal_d3                        # 20 colours, D3.js Category20

# Browse all
list_palettes()

# Custom palette
my_pal <- as_palette(c("#FF6B6B", "#4ECDC4", "#45B7D1"))

# Use in ggplot
ggplot(data, aes(x, y, color = group)) +
  geom_point() +
  scale_color_manual(values = pal_lancet[1:3])
```

### Console Styling

```r
.cat_line("Processing started", type = "info")
.cat_line("Done", type = "success")
.cat_box("Important notice", type = "warning")
.cat_message("Loading data...", type = "info")
```

### Data Quality

```r
na(my_data)                   # missing value report
check_system()                # system diagnostics
check_size()                  # object memory usage
```

## License

MIT
