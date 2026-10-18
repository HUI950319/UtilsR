flatten_test_plot <- function(title, colour = FALSE) {
  mapping <- if (colour) ggplot2::aes(x, y, colour = factor(x)) else ggplot2::aes(x, y)
  ggplot2::ggplot(data.frame(x = 1:3, y = c(2, 1, 3)),
                   mapping) + ggplot2::geom_point() +
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

test_that("fmt_flatten() is flatten_patchwork() under its fmt_* name", {
  expect_identical(flatten_patchwork, fmt_flatten)
  p1 <- flatten_test_plot("First")
  p2 <- flatten_test_plot("Second")
  expect_equal(flatten_test_titles(fmt_flatten((p1 | p2) / p1)),
               c("First", "Second", "First"))
})

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

test_that("flattening retains cell names through nested lists and insets", {
  first <- flatten_test_plot("First")
  second <- flatten_test_plot("Second")
  inset <- second + patchwork::inset_element(flatten_test_plot("Inset"), .5, .5, 1, 1)
  for (input in list(list(B = inset, A = first),
                    list(group = list(B = inset, A = first)),
                    list(group = list(B = inset), A = first))) {
    before <- serialize(input, NULL)
    output <- flatten_patchwork(input, design = "AB")
    expect_true(identical(serialize(input, NULL), before))
    expect_length(output, 3L)
    expect_identical(output[[1]]$labels$title, "First")
    selected <- flatten_patchwork(output, select_inds = 2)
    expect_equal(flatten_test_labels(patchwork::patchworkGrob(selected)),
      flatten_test_labels(patchwork::patchworkGrob(inset)))
  }
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

test_that("named character designs reject ambiguous duplicate cell names", {
  plots <- list(A = flatten_test_plot("First"), B = flatten_test_plot("Second"))
  expect_error(flatten_patchwork(plots, select_inds = c(1, 1, 2), design = "ABC"),
    "unique.*names|unnamed")
  expect_error(flatten_patchwork(list(A = plots[[1]], A = plots[[2]]), design = "AB"),
    "unique.*names|unnamed")
  repeated <- flatten_patchwork(unname(plots), select_inds = c(1, 1, 2), design = "ABC")
  expect_equal(flatten_test_titles(repeated), c("First", "First", "Second"))
  labels <- flatten_test_labels(patchwork::patchworkGrob(repeated))
  expect_equal(sum(labels == "First"), 2L)
  expect_equal(sum(labels == "Second"), 1L)
  expect_equal(flatten_test_titles(flatten_patchwork(plots, select_inds = c(1, 1, 2))),
    c("First", "First", "Second"))
  names(plots) <- c("X", "Y")
  expect_equal(flatten_test_titles(flatten_patchwork(plots, select_inds = c(1, 1, 2),
    design = "ABC")), c("First", "First", "Second"))
})

test_that("layout dots reject unknown, unnamed and duplicate arguments", {
  p <- flatten_test_plot("Data")
  expect_error(flatten_patchwork(p | p, ncols = 2), "ncols")
  expect_error(flatten_patchwork(p | p, guide = "collect"), "guide")
  expect_error(flatten_patchwork(p, p), "plots.*list|list.*plots")
  expect_error(flatten_patchwork(p, 2), "named")
  expect_error(flatten_patchwork(p, ncol = 1, ncol = 2), "unique")
  output <- flatten_patchwork(p | p, ncol = 2L, nrow = 1L, byrow = FALSE,
    widths = c(1, 2), heights = 1, guides = "collect", tag_level = "keep",
    design = NULL, axes = "collect", axis_titles = "collect")
  expect_identical(output$patches$layout$ncol, 2L)
  expect_s3_class(patchwork::patchworkGrob(output), "gtable")
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
  expect_length(output, 2L)
  expect_identical(serialize(input, NULL), before)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(output)),
                 flatten_test_labels(patchwork::patchworkGrob(input)))
  expect_equal(patchwork::patchworkGrob(output)$layout,
                 patchwork::patchworkGrob(input)$layout)
  expect_identical(attr(output[[2]], "inset_settings"),
                     attr(input[[2]], "inset_settings"))

  double <- input + patchwork::inset_element(overlay, 0, 0, .4, .4, on_top = FALSE)
  cells <- flatten_patchwork(list(double, main))
  expect_length(cells, 4L)
  first <- flatten_patchwork(cells, select_inds = 1)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(first)),
                 flatten_test_labels(patchwork::patchworkGrob(double)))
  expect_equal(patchwork::patchworkGrob(first)$layout,
                 patchwork::patchworkGrob(double)$layout)
  selected <- flatten_patchwork(list(main, double), select_inds = 2)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(selected)),
                 flatten_test_labels(patchwork::patchworkGrob(double)))
  reordered <- flatten_patchwork(list(double, main), select_inds = c(2, 1))
  second <- flatten_patchwork(reordered, select_inds = 2)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(second)),
                 flatten_test_labels(patchwork::patchworkGrob(double)))
  expect_error(flatten_patchwork(patchwork::inset_element(overlay, .5, .5, 1, 1)),
                 "inset.*main plot")
})

test_that("flattening keeps an inset attached to its composite host", {
  host <- flatten_test_plot("Host 1") | flatten_test_plot("Host 2")
  overlay <- flatten_test_plot("Inset")
  other <- flatten_test_plot("Other")
  for (align_to in c("panel", "plot", "full")) {
    input <- patchwork::wrap_plots(list(host)) +
      patchwork::inset_element(overlay, .5, .5, 1, 1, align_to = align_to)
    before <- serialize(input, NULL)
    output <- flatten_patchwork(input)
    expect_true(identical(serialize(input, NULL), before))
    expect_length(output, 2L)
    expect_equal(flatten_test_labels(patchwork::patchworkGrob(output)),
      flatten_test_labels(patchwork::patchworkGrob(input)))
    expect_equal(patchwork::patchworkGrob(output)$layout,
      patchwork::patchworkGrob(input)$layout)
    selected <- flatten_patchwork(list(input, other), select_inds = c(2, 1))
    expect_length(selected, 3L)
    host_cell <- flatten_patchwork(selected, select_inds = 2)
    expect_equal(flatten_test_labels(patchwork::patchworkGrob(host_cell)),
      flatten_test_labels(patchwork::patchworkGrob(input)))
    repeated <- flatten_patchwork(output)
    expect_length(repeated, 2L)
    expect_equal(patchwork::patchworkGrob(repeated)$layout,
      patchwork::patchworkGrob(input)$layout)
  }
})

test_that("list inputs bind insets before flattening their hosts", {
  host <- flatten_test_plot("Host 1") | flatten_test_plot("Host 2")
  overlay <- patchwork::inset_element(grid::rectGrob(), .6, .6, .9, .9,
    align_to = "full")
  other <- flatten_test_plot("Other")
  for (input in list(list(host, overlay, other),
                    list(list(host), list(overlay), other),
                    list(list(host, overlay), other))) {
    before <- serialize(input, NULL)
    output <- flatten_patchwork(input, ncol = 2)
    expect_true(identical(serialize(input, NULL), before))
    native <- patchwork::wrap_plots(list(host, overlay, other), ncol = 2)
    expect_length(output, 3L)
    expect_equal(flatten_test_labels(patchwork::patchworkGrob(output)),
      flatten_test_labels(patchwork::patchworkGrob(native)))
    expect_equal(patchwork::patchworkGrob(output)$layout,
      patchwork::patchworkGrob(native)$layout)
    selected <- flatten_patchwork(input, select_inds = 1)
    expect_equal(flatten_test_labels(patchwork::patchworkGrob(selected)),
      flatten_test_labels(patchwork::patchworkGrob(patchwork::wrap_plots(list(host, overlay)))))
    expect_error(flatten_patchwork(input, select_inds = 3), "select_inds")
  }
  input <- list(B = host, overlay, A = other)
  output <- flatten_patchwork(input, design = "AB")
  expect_equal(output[[1]]$labels$title, "Other")
  selected <- flatten_patchwork(output, select_inds = 2)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(selected)),
    flatten_test_labels(patchwork::patchworkGrob(patchwork::wrap_plots(list(host, overlay)))))
  grob_input <- list(grid::textGrob("Host"), overlay)
  output <- flatten_patchwork(grob_input)
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(output)),
    flatten_test_labels(patchwork::patchworkGrob(patchwork::wrap_plots(grob_input))))
})

test_that("flattening retains top annotations and collection with explicit overrides", {
  p <- flatten_test_plot("Data", colour = TRUE)
  input <- ((p | p) / (p | p)) +
    patchwork::plot_layout(guides = "collect", axis_titles = "collect") +
    patchwork::plot_annotation(title = "Overall title", subtitle = "Overall subtitle",
      caption = "Overall caption", tag_levels = "A", tag_prefix = "Tag ",
      theme = ggplot2::theme(plot.background = ggplot2::element_rect(fill = "pink")))
  before <- serialize(input, NULL)
  output <- flatten_patchwork(input, ncol = 2)
  expect_identical(output$patches$annotation, input$patches$annotation)
  expect_identical(output$patches$layout$guides, "collect")
  expect_identical(output$patches$layout$axis_titles, "collect")
  overridden <- flatten_patchwork(input, ncol = 2, guides = "keep", axis_titles = "keep")
  expect_identical(overridden$patches$layout$guides, "keep")
  expect_identical(overridden$patches$layout$axis_titles, "keep")
  expect_true(identical(serialize(input, NULL), before))
  labels <- flatten_test_labels(patchwork::patchworkGrob(output))
  for (label in c("Overall title", "Overall subtitle", "Overall caption",
                    "Shared X", "Shared Y", paste0("Tag ", LETTERS[1:4]))) {
    expect_equal(sum(labels == label), 1L)
  }
})

test_that("ordinary inset hosts retain shared axis collection", {
  first <- flatten_test_plot("First")
  second <- flatten_test_plot("Second")
  overlay <- patchwork::inset_element(grid::rectGrob(), .6, .6, .9, .9)
  input <- first + overlay + second +
    patchwork::plot_layout(ncol = 2, axes = "collect", axis_titles = "collect")
  before <- serialize(input, NULL)
  output <- flatten_patchwork(input, ncol = 2)
  expect_true(identical(serialize(input, NULL), before))
  labels <- flatten_test_labels(patchwork::patchworkGrob(output))
  expect_equal(sum(labels == "Shared X"), 1L)
  expect_equal(sum(labels == "Shared Y"), 1L)
  expect_equal(patchwork::patchworkGrob(output)$layout,
    patchwork::patchworkGrob(input)$layout)
  reordered <- flatten_patchwork(input, select_inds = c(2, 1), ncol = 2)
  expect_equal(reordered[[1]]$labels$title, "Second")
  expect_equal(reordered[[2]]$labels$title, "First")
  expect_s3_class(reordered[[3]], "inset_patch")
  repeated <- flatten_patchwork(output, ncol = 2)
  expect_equal(patchwork::patchworkGrob(repeated)$layout,
    patchwork::patchworkGrob(output)$layout)
})

test_that("flattening documents collection scope changes and wrapped protection", {
  p <- flatten_test_plot("Data", colour = TRUE)
  input <- ((p | p) + patchwork::plot_layout(guides = "keep")) / p +
    patchwork::plot_layout(guides = "collect")
  label <- "factor(x)"
  expect_equal(sum(flatten_test_labels(patchwork::patchworkGrob(input)) == label), 3L)
  output <- flatten_patchwork(input)
  expect_equal(sum(flatten_test_labels(patchwork::patchworkGrob(output)) == label), 1L)
  kept <- flatten_patchwork(input, guides = "keep")
  expect_equal(sum(flatten_test_labels(patchwork::patchworkGrob(kept)) == label), 3L)
  wrapped <- flatten_patchwork(patchwork::wrap_elements(full = input), guides = "collect")
  expect_length(wrapped, 1L)
  expect_equal(sum(flatten_test_labels(patchwork::patchworkGrob(wrapped)) == label), 3L)
  areas <- ((p | patchwork::guide_area()) + patchwork::plot_layout(guides = "collect")) /
    ((p | patchwork::guide_area()) + patchwork::plot_layout(guides = "collect"))
  collected <- flatten_patchwork(areas, guides = "collect")
  expect_warning(grob <- patchwork::patchworkGrob(collected), "first guide area")
  expect_equal(sum(flatten_test_labels(grob) == label), 1L)
})

test_that("flattening protects free containers and retains ordinary layout cells", {
  p <- flatten_test_plot("Data")
  free_group <- patchwork::free((p | p) / p, side = "l")
  output <- flatten_patchwork(list(free_group, p))
  expect_length(output, 2L)
  preserved <- patchwork::wrap_plots(list(output[[1]]))
  expect_equal(flatten_test_labels(patchwork::patchworkGrob(preserved)),
                 flatten_test_labels(patchwork::patchworkGrob(free_group)))
  expect_equal(patchwork::patchworkGrob(preserved)$layout,
                 patchwork::patchworkGrob(free_group)$layout)
  fixed <- patchwork::wrap_elements(full = grid::textGrob("Wrapped"))
  special <- flatten_patchwork((p | patchwork::plot_spacer()) /
                                (patchwork::guide_area() | fixed), ncol = 2)
  expect_length(special, 4L)
  expect_s3_class(special[[2]], "spacer")
  expect_s3_class(special[[3]], "guide_area")
  expect_s3_class(special[[4]], "wrapped_patch")
  expect_equal(sum(flatten_test_labels(patchwork::patchworkGrob(special)) == "Wrapped"), 1L)
})

test_that("flattening distinguishes free leaves from free containers", {
  plots <- lapply(1:3, function(i) flatten_test_plot(paste0("P", i)))
  for (type in c("panel", "label", "space")) {
    input <- ((plots[[1]] | plots[[2]]) /
      patchwork::free(plots[[3]], type = type, side = "l")) +
      patchwork::plot_layout(guides = "collect") +
      patchwork::plot_annotation(title = "Overall title")
    before <- serialize(input, NULL)
    output <- flatten_patchwork(input, ncol = 3)
    expect_true(identical(serialize(input, NULL), before))
    expect_length(output, 3L)
    expect_equal(flatten_test_titles(output), paste0("P", 1:3))
    expect_s3_class(output[[3]], "free_plot")
    expect_identical(attr(output[[3]], "free_settings"),
      attr(input[[2]], "free_settings"))
    expect_identical(output$patches$annotation, input$patches$annotation)
    expect_identical(output$patches$layout$guides, "collect")
    expect_s3_class(patchwork::patchworkGrob(output), "gtable")
    selected <- flatten_patchwork(input, select_inds = c(3, 1))
    expect_equal(flatten_test_titles(selected), c("P3", "P1"))
    expect_s3_class(patchwork::patchworkGrob(selected), "gtable")
  }
})

test_that("flattening reports unreadable children instead of omitting them", {
  rlang::local_bindings(`[[.flatten_bad_patchwork` = function(x, ...) {
    if (list(...)[[1]] == 2L) stop("Broken child")
    NextMethod()
  }, .env = .GlobalEnv)
  p <- flatten_test_plot("Data")
  input <- p | p | p
  class(input) <- c("flatten_bad_patchwork", class(input))
  expect_error(flatten_patchwork(input), "child 2")
  error <- tryCatch(flatten_patchwork(input), error = identity)
  expect_s3_class(error, "rlang_error")
  expect_match(conditionMessage(error$parent), "Broken child")
})

test_that("flattening keeps plot data and accepts standalone grobs", {
  plots <- lapply(1:4, function(i) flatten_test_plot(paste0("P", i)))
  input <- (plots[[1]] | plots[[2]]) / (plots[[3]] | plots[[4]])
  before <- serialize(input, NULL)
  output <- flatten_patchwork(input, select_inds = c(4, 2, 1), ncol = 3)
  expect_true(identical(serialize(input, NULL), before))
  for (i in seq_len(3)) {
    original <- plots[[c(4, 2, 1)[i]]]
    expect_equal(ggplot2::ggplot_build(output[[i]])$data,
                   ggplot2::ggplot_build(original)$data)
  }
  grob <- grid::textGrob("Standalone")
  output <- flatten_patchwork(grob)
  expect_s3_class(output, "patchwork")
  expect_equal(sum(flatten_test_labels(patchwork::patchworkGrob(output)) == "Standalone"), 1L)
})
