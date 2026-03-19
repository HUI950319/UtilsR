# UtilsR <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/HUI950319/UtilsR)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**UtilsR** 是一个 R 工具包，提供交互式数据探索、变量检查、缺失值分析、系统诊断和美化输出等实用函数。

## 安装

```r
# 从 GitHub 安装
pak::pak("HUI950319/UtilsR")

# 或使用 devtools
devtools::install_github("HUI950319/UtilsR")
```

## 核心功能

### `lv()` — 变量快速检查

支持 `data.frame` 和 `Seurat` 对象，显示频率、唯一值、缺失值等信息。

```r
library(UtilsR)

# 查看所有变量
lv(iris)

# 选择特定变量
lv(iris, Species, Sepal.Length)

# 正则匹配变量名
lv(iris, pattern = "Sepal")

# 分组统计
lv(iris, Sepal.Length, group = "Species")

# 交叉表
lv(iris, Species, count = Sepal.Length)
```

### `na()` — 数据质量分析

检测缺失值和特殊值（如 `"unknown"`, `"N/A"`, 空字符串等），输出 gt 表格。

```r
na(my_data)

# 显示所有变量（包括无问题的）
na(my_data, show_all = TRUE)
```

### `check_system()` — 系统诊断

显示操作系统、R 版本、内存用量、CPU 信息。

```r
check_system()
```

### `check_size()` — 对象内存分析

查看全局环境中对象的内存占用，以 gt 表格展示（含柱状图和颜色映射）。

```r
check_size()

# 查看特定对象
check_size("my_data", "model")

# 正则匹配
check_size(pattern = "^df")
```

## 美化输出

### 控制台样式

```r
# 分隔线（info / success / warning / error）
.cat_line("处理开始", type = "info")
.cat_line("操作完成", type = "success")

# 信息框
.cat_box("重要提示", type = "warning")

# 带时间戳的日志
.cat_message("数据加载中...", type = "info")
.cat_message("发现问题", type = "error")
```

### `.cat_tb()` — 增强表格显示

基于 `gt`，支持多表合并、模式高亮、数值颜色映射。

```r
.cat_tb(
  df1, df2,
  titles = c("模型 1", "模型 2"),
  highlight_pattern = "\\*+",
  highlight_color = "lightcoral",
  numeric_columns = c("estimate", "p_value"),
  theme = "excel"
)
```

## 调色板

```r
# Lancet 配色方案（15色），控制台直接显示色块
lancet_palette

# 子集保持颜色显示
lancet_palette[1:5]

# 自定义调色板
my_pal <- as_palette(c("#FF6B6B", "#4ECDC4", "#45B7D1"))
my_pal

# 反转顺序显示
show_color(lancet_palette, rev = TRUE)
```

## ggplot2 主题

```r
library(ggplot2)

ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() +
  my_theme()

# 预设主题
# km_theme  — Kaplan-Meier 生存曲线
# rcs_theme — 限制性立方样条图
```

## 操作符

| 操作符 | 用途 | 示例 |
|--------|------|------|
| `%>%` | 管道 | `x %>% mean()` |
| `%<>%` | 管道赋值 | `x %<>% sort()` |
| `%\|\|%` | 默认值 | `NULL %\|\|% 0` → `0` |
| `%ni%` | 不在其中 | `3 %ni% c(1,2)` → `TRUE` |

## 依赖

- **核心**: cli, dplyr, ggplot2, gt, gtExtras, rlang
- **可选**: Seurat, SeuratObject（用于 `lv.Seurat`）

## License

MIT
