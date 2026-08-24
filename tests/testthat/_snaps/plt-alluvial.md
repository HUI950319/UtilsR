# plt_alluvial removes incomplete required rows

    Code
      plot <- plt_alluvial(data, "category", "group", label_args = list(style = "none"))
    Message
      i Removed 1 row with missing values in required columns.

# plt_alluvial rejects invalid columns and overlapping roles

    Code
      plt_alluvial(alluvial_data(), "missing", "group")
    Condition
      Error in `check_column()`:
      ! Column "missing" supplied to `cat_var` was not found.

---

    Code
      plt_alluvial(alluvial_data(), "category", "category")
    Condition
      Error in `plt_alluvial()`:
      ! `cat_var`, `group`, and `facet` must name different columns.

---

    Code
      plt_alluvial(matrix(1:4, ncol = 2), "category", "group")
    Condition
      Error in `plt_alluvial()`:
      ! `data` must be a data frame.

# plt_alluvial validates semantic list arguments

    Code
      plt_alluvial(alluvial_data(), "category", "group", flow_args = list(foo = 1))
    Condition
      Error in `merge_args()`:
      ! `flow_args` has unknown field: "foo".

---

    Code
      plt_alluvial(alluvial_data(), "category", "group", flow_args = list(0.2))
    Condition
      Error in `merge_args()`:
      ! Every element of `flow_args` must have a non-empty name.

---

    Code
      plt_alluvial(alluvial_data(), "category", "group", flow_args = duplicate_alpha)
    Condition
      Error in `merge_args()`:
      ! `flow_args` must not contain duplicate names.

---

    Code
      plt_alluvial(alluvial_data(), "category", "group", flow_args = list(alpha = 2))
    Condition
      Error in `plt_alluvial()`:
      ! `flow_args$alpha` must be between 0 and 1.

---

    Code
      plt_alluvial(alluvial_data(), "category", "group", stratum_args = list(width = 0))
    Condition
      Error in `plt_alluvial()`:
      ! `stratum_args$width` must be greater than 0 and at most 1.

---

    Code
      plt_alluvial(transform(alluvial_data(), group3 = rep(c("G1", "G2", "G3", "G1"),
      2)), "category", "group3", stratum_args = list(gap = 0.5))
    Condition
      Error in `plt_alluvial()`:
      ! The total `stratum_args$gap` space must be less than 1 in percent mode.

---

    Code
      plt_alluvial(alluvial_data(), "category", "group", label_args = list(alpha = 2))
    Condition
      Error in `plt_alluvial()`:
      ! `label_args$alpha` must be between 0 and 1.

