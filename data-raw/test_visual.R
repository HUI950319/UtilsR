library(UtilsR)
library(ggplot2)

set.seed(1)
df <- data.frame(
  Type = factor(sample(c("A","B","C"), 200, TRUE, c(0.5, 0.3, 0.2))),
  Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
  Batch = factor(sample(c("B1","B2"), 200, TRUE))
)
df$Region <- factor(ifelse(df$Group %in% c("X","Y"), "R1", "R2"))

df_bin <- data.frame(
  A = sample(c("Yes","No"), 200, TRUE),
  B = sample(c("Yes","No"), 200, TRUE),
  C = sample(c("Yes","No"), 200, TRUE)
)

df_na <- df
df_na$Type[1:20] <- NA

df_drop <- df[df$Type != "C", , drop = FALSE]

tests <- list(
  # ===== 1. Bar (8 variants) =====
  list(name="01_bar_stack_pct",   expr=quote(plt_cat(df, "Type", "Group", type="bar"))),
  list(name="02_bar_dodge_cnt",   expr=quote(plt_cat(df, "Type", "Group", type="bar",
    stat="count", position="dodge"))),
  list(name="03_bar_label",       expr=quote(plt_cat(df, "Type", "Group", type="bar",
    label=TRUE))),
  list(name="04_bar_flip",        expr=quote(plt_cat(df, "Type", "Group", type="bar",
    flip=TRUE, label=TRUE))),
  list(name="05_bar_bg",          expr=quote(plt_cat(df, "Type", "Group", type="bar",
    position="dodge", bg.by="Region"))),
  list(name="06_bar_bg_custom",   expr=quote(plt_cat(df, "Type", "Group", type="bar",
    position="dodge", bg.by="Region", bg_palette=c("lightblue","lightyellow")))),
  list(name="07_bar_nogroup",     expr=quote(plt_cat(df, "Type", type="bar", stat="count",
    label=TRUE, legend.position="none"))),
  list(name="08_bar_dodge_label", expr=quote(plt_cat(df, "Type", "Group", type="bar",
    stat="count", position="dodge", label=TRUE,
    label.fg="white", label.bg="black"))),

  # ===== 2. Rose (2) =====
  list(name="09_rose",            expr=quote(plt_cat(df, "Type", "Group", type="rose"))),
  list(name="10_rose_dodge_cnt",  expr=quote(plt_cat(df, "Type", "Group", type="rose",
    stat="count", position="dodge"))),

  # ===== 3. Ring (3) =====
  list(name="11_ring",            expr=quote(plt_cat(df, "Type", type="ring"))),
  list(name="12_ring_label",      expr=quote(plt_cat(df, "Type", type="ring",
    label=TRUE, palette="Paired"))),
  list(name="12b_ring_dodge",     expr=quote(plt_cat(df, "Type", "Group", type="ring",
    stat="count", position="dodge"))),

  # ===== 4. Pie (3) =====
  list(name="13_pie",             expr=quote(plt_cat(df, "Type", type="pie", label=TRUE))),
  list(name="14_pie_styled",      expr=quote(plt_cat(df, "Type", type="pie",
    palette="Paired", title="Type Distribution", subtitle="n = 200"))),
  list(name="15_pie_legend_h",    expr=quote(plt_cat(df, "Type", type="pie",
    legend.position="bottom", legend.direction="horizontal"))),

  # ===== 5. Trend (2) =====
  list(name="16_trend",           expr=quote(plt_cat(df, "Type", "Group", type="trend",
    stat="count"))),
  list(name="17_trend_label",     expr=quote(plt_cat(df, "Type", "Group", type="trend",
    stat="count", label=TRUE))),

  # ===== 6. Area (2) =====
  list(name="18_area",            expr=quote(plt_cat(df, "Type", "Group", type="area",
    stat="count"))),
  list(name="19_area_dodge",      expr=quote(plt_cat(df, "Type", "Group", type="area",
    stat="count", position="dodge"))),

  # ===== 7. Dot (2) =====
  list(name="20_dot",             expr=quote(plt_cat(df, "Type", "Group", type="dot"))),
  list(name="21_dot_label",       expr=quote(plt_cat(df, "Type", "Group", type="dot",
    label=TRUE, stat="count"))),

  # ===== 8. Sankey (2) =====
  list(name="22_sankey_2col",     expr=quote(plt_cat(df, c("Type","Group"), type="sankey"))),
  list(name="23_sankey_3col",     expr=quote(plt_cat(df, c("Type","Group","Batch"),
    type="sankey"))),

  # ===== 9. Chord (1) =====
  # (chord returns recordPlot, cannot ggsave — test exec only)
  list(name="24_chord",           expr=quote(plt_cat(df, c("Type","Group"), type="chord"))),

  # ===== 10. Venn (2) =====
  list(name="25_venn_binary",     expr=quote(plt_cat(df_bin, c("A","B","C"), type="venn"))),
  list(name="26_venn_stat_level", expr=quote(plt_cat(df, c("Type","Group"), type="venn",
    stat_level=c("A","X")))),

  # ===== 11. UpSet (2) =====
  list(name="27_upset_binary",    expr=quote(plt_cat(df_bin, c("A","B","C"), type="upset"))),
  list(name="28_upset_stat_level", expr=quote(plt_cat(df, c("Type","Group"), type="upset",
    stat_level=c("A","X")))),

  # ===== Cross-cutting features =====
  # split.by
  list(name="29_split_bar",       expr=quote(plt_cat(df, "Type", "Group",
    split.by="Batch", type="bar"))),
  list(name="30_split_pie_ncol",  expr=quote(plt_cat(df, "Type", split.by="Batch",
    type="pie", facet_ncol=2))),

  # title + subtitle + xlab + ylab
  list(name="31_bar_labs",        expr=quote(plt_cat(df, "Type", "Group", type="bar",
    title="Cell Composition", subtitle="n=200",
    xlab="Sample", ylab="Fraction (%)"))),

  # NA_stat + NA_color
  list(name="32_bar_NA",          expr=quote(plt_cat(df_na, "Type", "Group", type="bar",
    NA_stat=TRUE, NA_color="red"))),

  # keep_empty
  list(name="33_keep_empty",      expr=quote(plt_cat(df_drop, "Type", "Group", type="bar",
    keep_empty=TRUE))),

  # aspect.ratio
  list(name="34_aspect",          expr=quote(plt_cat(df, "Type", "Group", type="bar",
    aspect.ratio=0.5))),

  # legend.direction
  list(name="35_legend_dir",      expr=quote(plt_cat(df, "Type", "Group", type="bar",
    legend.position="bottom", legend.direction="horizontal")))
)

dir.create("/tmp/plt_cat_tests", showWarnings = FALSE)

pass <- 0L
fail <- 0L
for (t in tests) {
  tryCatch({
    p <- eval(t$expr)
    if (inherits(p, "gg") || inherits(p, "patchwork")) {
      ggsave(sprintf("/tmp/plt_cat_tests/%s.png", t$name), p, width=8, height=5)
    }
    message(t$name, ": OK")
    pass <- pass + 1L
  }, error = function(e) {
    message(t$name, " ERROR: ", e$message)
    fail <<- fail + 1L
  })
}
message(sprintf("\nDONE: %d passed, %d failed (total %d)", pass, fail, pass + fail))
