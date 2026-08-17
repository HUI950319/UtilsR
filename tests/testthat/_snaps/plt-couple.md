# plt_couple validates required inputs

    Code
      plt_couple(data, group = "missing")
    Condition
      Error in `plt_couple()`:
      ! Group column "missing" was not found in `data`.

---

    Code
      plt_couple(data, group = "group", vars = "group")
    Condition
      Error in `plt_couple()`:
      ! `vars` must contain at least two column names.

---

    Code
      plt_couple(data, group = "group")
    Condition
      Error in `plt_couple()`:
      ! `data` contains missing values in `group` or `vars`.

---

    Code
      plt_couple(data, group = "group")
    Condition
      Error in `plt_couple()`:
      ! `group` must contain at least two groups.

---

    Code
      plt_couple(couple_data(), group = "group", link_method = "importance", n_perm = 0L)
    Condition
      Error in `plt_couple()`:
      ! `n_perm` must be a positive integer.

# square geometry reports the ggplot2 compatibility requirement

    Code
      plt_couple(couple_data(), group = "group", geom_type = "square")
    Condition
      Error in `plt_couple()`:
      ! `geom_type = 'square'` requires ggplot2 older than version 4.0.0.

# plt_couple handles empty and invalid save arguments

    Code
      plt_couple(couple_data(), "group", save = "plot.pdf")
    Condition
      Error in `plt_couple()`:
      ! `save` must be `NULL` or a list.
