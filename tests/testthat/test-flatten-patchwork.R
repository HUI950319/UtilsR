flatten_test_plot <- function(title) {
  ggplot2::ggplot(data.frame(x = 1:3, y = c(2, 1, 3)),
                   ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::labs(title = title, x = "Shared X", y = "Shared Y")
}

flatten_test_titles <- function(plot) {
  vapply(seq_along(plot), function(i) plot[[i]]$labels$title, character(1))
}

flatten_test_labels <- function(grob) {
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  children <- if (inherits(grob, "gtable")) grob$grobs else grob$children
  c(labels, unlist(lapply(children, flatten_test_labels), use.names = FALSE))
}

test_that("flattening accepts lists and preserves named design assignments", {
  p1 <- flatten_test_plot("First")
  p2 <- flatten_test_plot("Second")
  input <- list(B = p2, A = p1)
  output <- flatten_patchwork(input, design = "AB")
  expect_s3_class(output, "patchwork")
  expect_equal(flatten_test_titles(output), c("First", "Second"))
  expect_identical(input, list(B = p2, A = p1))

  nested <- list(p1 | p2, list(p1))
  expect_equal(flatten_test_titles(flatten_patchwork(nested)),
                 c("First", "Second", "First"))
  expect_equal(flatten_test_titles(flatten_patchwork(p1)), "First")
  expect_error(flatten_patchwork(list(p1, 42)), "ggplot|grob")
})

test_that("flattening validates indices without changing integer selection", {
  plots <- lapply(1:4, function(i) flatten_test_plot(paste0("P", i)))
  input <- patchwork::wrap_plots(plots)
  for (indices in list(1.9, NA_integer_, Inf, TRUE, "1", 1 + 1i,
                         matrix(1:2), c(1, 5), -5)) {
    expect_error(flatten_patchwork(input, select_inds = indices), "select_inds")
  }
  for (indices in list(integer(), 0L, -seq_len(4))) {
    expect_error(flatten_patchwork(input, select_inds = indices), "no plots")
  }
  expect_error(flatten_patchwork(input, select_inds = c(1, -2)), "select_inds")
  expect_error(flatten_patchwork(list()), "no plots")
  expect_equal(flatten_test_titles(flatten_patchwork(input, select_inds = c(3, 1, 1))),
                 c("P3", "P1", "P1"))
  expect_equal(flatten_test_titles(flatten_patchwork(input, select_inds = c(0, -2))),
                 c("P1", "P3", "P4"))
})

test_that("row interleaving rejects invalid counts and handles uneven grids", {
  plots <- lapply(1:5, function(i) flatten_test_plot(paste0("P", i)))
  input <- patchwork::wrap_plots(plots)
  for (rows in list(0, -1, 1.5, NA_integer_, Inf, TRUE, "2", 1 + 1i,
                      matrix(2), integer(), c(2, 3), 6)) {
    expect_error(flatten_patchwork(input, nrow_inds_order = rows), "nrow_inds_order")
  }
  expect_equal(flatten_test_titles(flatten_patchwork(input, nrow_inds_order = 2)),
                 c("P1", "P3", "P5", "P2", "P4"))
  expect_equal(flatten_test_titles(flatten_patchwork(input, select_inds = c(5, 3, 1),
                                                     nrow_inds_order = 2)),
                 c("P5", "P1", "P3"))
  expect_error(flatten_patchwork(input, select_inds = 1, nrow_inds_order = 2),
                 "nrow_inds_order")
})

test_that("flattening keeps nested insets with their main plot", {
  main <- flatten_test_plot("Main")
  overlay <- flatten_test_plot("Inset 1") | flatten_test_plot("Inset 2")
  input <- main + patchwork::inset_element(overlay, .5, .5, 1, 1)
  before <- serialize(input, NULL)
  output <- flatten_patchwork(input)
  expect_length(output, 1L)
  expect_identical(serialize(input, NULL), before)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(output[[1]])),
                 flatten_test_labels(patchwork::patchworkGrob(input)))
  expect_equal(patchwork::patchworkGrob(output[[1]])$layout,
                 patchwork::patchworkGrob(input)$layout)
  expect_identical(attr(output[[1]][[2]], "inset_settings"),
                     attr(input[[2]], "inset_settings"))

  double <- input + patchwork::inset_element(overlay, 0, 0, .4, .4, on_top = FALSE)
  cells <- flatten_patchwork(list(double, main))
  expect_length(cells, 2L)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(cells[[1]])),
                 flatten_test_labels(patchwork::patchworkGrob(double)))
  expect_equal(patchwork::patchworkGrob(cells[[1]])$layout,
                 patchwork::patchworkGrob(double)$layout)
  selected <- flatten_patchwork(list(main, double), select_inds = 2)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(selected[[1]])),
                 flatten_test_labels(patchwork::patchworkGrob(double)))
  reordered <- flatten_patchwork(list(double, main), select_inds = c(2, 1))
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(reordered[[2]])),
                 flatten_test_labels(patchwork::patchworkGrob(double)))
  expect_error(flatten_patchwork(patchwork::inset_element(overlay, .5, .5, 1, 1)),
                 "inset.*main plot")
})
