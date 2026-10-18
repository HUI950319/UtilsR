test_that("fmt_text() collects identical axis titles of a patchwork by default", {
  skip_if_not_installed("patchwork")
  d <- data.frame(x = 1:3, y = c(2, 1, 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  pw <- patchwork::wrap_plots(p, p, p, p, ncol = 2)

  out <- fmt_text(pw, xlab = "Days", ylab = "Survival")
  expect_identical(out$patches$layout$axis_titles, "collect")
  expect_identical(out$patches$plots[[1]]$labels$y, "Survival")

  # Partial collection and opting out
  out_y <- fmt_text(pw, ylab = "Survival", axis_titles = "collect_y")
  expect_identical(out_y$patches$layout$axis_titles, "collect_y")
  kept <- patchwork::wrap_plots(p, p, ncol = 2) +
    patchwork::plot_layout(axis_titles = "keep")
  expect_identical(
    fmt_text(kept, ylab = "Survival", axis_titles = NULL)$patches$layout$axis_titles,
    "keep"
  )
})

test_that("fmt_text() axis_titles leaves single plots and lists unchanged", {
  d <- data.frame(x = 1:3, y = c(2, 1, 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  single <- fmt_text(p, ylab = "Survival")
  expect_s3_class(single, "ggplot")
  expect_false(inherits(single, "patchwork"))
  expect_identical(single$labels$y, "Survival")

  lst <- fmt_text(list(p, p), ylab = c("A", "B"))
  expect_type(lst, "list")
  expect_identical(lst[[2]]$labels$y, "B")
})

text_test_count <- function(x, label) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  g <- if (inherits(x, "patchwork")) patchwork::patchworkGrob(x) else ggplot2::ggplotGrob(x)
  count <- 0L
  walk <- function(grob) {
    if (inherits(grob, "text") && identical(as.character(grob$label), label)) count <<- count + 1L
    for (child in c(grob$grobs, grob$children)) walk(child)
  }
  walk(g)
  count
}

test_that("fmt_text() formats nested data plots and skips spacers and inset tags", {
  skip_if_not_installed("patchwork")
  d <- data.frame(x = 1:3, y = c(2, 1, 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  leaf_titles <- function(x) {
    titles <- character()
    invisible(.map_plot_leaves(x, function(leaf) {
      titles <<- c(titles, leaf$labels$title %||% NA_character_)
      leaf
    }))
    titles
  }

  nested <- fmt_text((p | p) / p, title = c("A", "B", "C"), title_size = 20)
  expect_identical(leaf_titles(nested), c("A", "B", "C"))
  expect_identical(nested[[1]][[1]]$theme$plot.title$size, 20)

  spaced <- fmt_text(p + patchwork::plot_spacer() + p, title = c("A", "B"))
  expect_null(spaced[[2]]$labels$title)
  expect_identical(leaf_titles(spaced), c("A", "B"))

  # Outside fmt_tag() labels are insets: the title goes to the data plot once.
  tagged <- fmt_text(fmt_tag(p, "Z", label_position = "tl-out"), title = "Main")
  expect_identical(text_test_count(tagged, "Main"), 1L)
  listed <- fmt_text(fmt_tag(list(p, p), label_position = "tl-out"),
                     title = c("One", "Two"))
  expect_identical(c(text_test_count(listed[[1]], "One"),
                     text_test_count(listed[[2]], "Two")), c(1L, 1L))
})
