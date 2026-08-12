# plt_na rejects an unsupported output

    Code
      plt_na(oc_data(), output = "unsupported")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "both", "both_reverse", "matrix", "percentage"

# plt_na warns and returns NULL when no values are missing

    Code
      result <- plt_na(data.frame(x = 1:3, y = letters[1:3]))
    Condition
      Warning:
      No missing values found in the dataset.
