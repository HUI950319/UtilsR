# The page size save_plt() reports for the PDF it wrote, in inches: Cairo
# keeps /MediaBox in a compressed object stream, so the file is not read.
saved_page_in <- function(output) {
  hit <- regmatches(output, regexpr("[0-9.]+x[0-9.]+ in", output))
  as.numeric(strsplit(sub(" in$", "", hit[[length(hit)]]), "x")[[1]])
}

# A plot saved with `save = list(filename = )` alone printed its size note
# and wrote the page it carries in attr(p, "plot_size").
expect_saved_at_plot_size <- function(output, p) {
  size <- attr(p, "plot_size")
  testthat::expect_length(size, 2L)
  testthat::expect_true(any(grepl("save = list(filename = ", output, fixed = TRUE)))
  testthat::expect_equal(saved_page_in(output), unname(ceiling(size * 10) / 10))
}
