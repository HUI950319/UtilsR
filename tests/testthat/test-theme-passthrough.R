test_that("theme_sc preserves registered extension theme elements", {
  nest_line <- ggplot2::element_line(colour = "firebrick", linewidth = 2)
  thm <- theme_sc(ggh4x.facet.nestline = nest_line)
  expect_identical(thm[["ggh4x.facet.nestline"]], nest_line)

  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_s3_class(ggplot2::ggplotGrob(p + thm), "gtable")
})

test_that("theme_blank preserves registered elements with and without arrows", {
  nest_line <- ggplot2::element_line(colour = "navy", linewidth = 2)
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  for (add_coord in c(FALSE, TRUE)) {
    out <- p + theme_blank(add_coord = add_coord,
                           ggh4x.facet.nestline = nest_line)
    expect_identical(out$theme[["ggh4x.facet.nestline"]], nest_line)
    expect_s3_class(ggplot2::ggplotGrob(out), "gtable")
  }
})

test_that("theme_sc accepts dynamically supplied extension elements", {
  nest_line <- ggplot2::element_line(colour = "firebrick", linewidth = 2)
  theme_args <- list(ggh4x.facet.nestline = nest_line)
  element_name <- "ggh4x.facet.nestline"

  spliced <- theme_sc(NULL, 12, !!!theme_args)
  expect_identical(spliced[[element_name]], nest_line)
  named <- theme_sc(NULL, 12, !!element_name := nest_line)
  expect_identical(named[[element_name]], nest_line)
})

test_that("theme_blank accepts dynamically supplied extension elements", {
  nest_line <- ggplot2::element_line(colour = "navy", linewidth = 2)
  theme_args <- list(ggh4x.facet.nestline = nest_line)
  element_name <- "ggh4x.facet.nestline"
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  spliced <- p + theme_blank(FALSE, 0.15, 0.15, "", "", 12, !!!theme_args)
  expect_identical(spliced$theme[[element_name]], nest_line)
  named <- p + theme_blank(TRUE, 0.15, 0.15, "", "", 12,
                           !!element_name := nest_line)
  expect_identical(named$theme[[element_name]], nest_line)
})

test_that("theme_sc evaluates forwarded extension expressions once", {
  nest_line <- ggplot2::element_line(colour = "firebrick")
  calls <- 0L
  make_line <- function() {
    calls <<- calls + 1L
    nest_line
  }
  forward <- function(...) theme_sc(...)

  thm <- forward(ggh4x.facet.nestline = make_line())
  expect_identical(thm[["ggh4x.facet.nestline"]], nest_line)
  expect_identical(calls, 1L)
})

test_that("theme_blank evaluates forwarded extension expressions once", {
  nest_line <- ggplot2::element_line(colour = "navy")
  calls <- 0L
  make_line <- function() {
    calls <<- calls + 1L
    nest_line
  }
  forward <- function(...) theme_blank(add_coord = FALSE, ...)
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()

  out <- p + forward(ggh4x.facet.nestline = make_line())
  expect_identical(out$theme[["ggh4x.facet.nestline"]], nest_line)
  expect_identical(calls, 1L)
})

test_that("theme_sc preserves blank extension elements and default overrides", {
  blank <- ggplot2::element_blank()
  key_size <- grid::unit(4, "mm")
  thm <- theme_sc(ggh4x.facet.nestline = blank, axis.text = blank,
                  legend.key.size = key_size, legend.position = "bottom")

  expect_identical(thm[["ggh4x.facet.nestline"]], blank)
  expect_identical(thm$axis.text, blank)
  expect_identical(thm$legend.key.size, key_size)
  expect_identical(thm$legend.position, "bottom")
})

test_that("theme_blank preserves blank extension elements and default overrides", {
  blank <- ggplot2::element_blank()
  key_size <- grid::unit(4, "mm")
  plot_margin <- ggplot2::margin(1, 2, 3, 4)
  d <- data.frame(x = 1:3, y = 3:1)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  out <- p + theme_blank(ggh4x.facet.nestline = blank,
                         legend.key.size = key_size, plot.margin = plot_margin,
                         legend.position = "bottom")

  expect_identical(out$theme[["ggh4x.facet.nestline"]], blank)
  expect_identical(out$theme$legend.key.size, key_size)
  expect_identical(out$theme$plot.margin, plot_margin)
  expect_identical(out$theme$legend.position, "bottom")
})

theme_passthrough_nested_colours <- function(modifier) {
  d <- expand.grid(batch = c("A", "B"), group = c("C", "D"), x = 1:3)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, x)) + ggplot2::geom_point() +
    ggh4x::facet_nested(~ batch + group, nest_line = TRUE)
  collect_colours <- function(grob) {
    children <- c(grob$grobs, as.list(grob$children))
    c(grob$gp$col, unlist(lapply(children, collect_colours), use.names = FALSE))
  }
  collect_colours(ggplot2::ggplotGrob(p + modifier))
}

test_that("theme_sc extension elements control nested facet drawing", {
  colours <- theme_passthrough_nested_colours(
    theme_sc(ggh4x.facet.nestline = ggplot2::element_line(colour = "#AE12F4"))
  )
  expect_gt(sum(colours == "#AE12F4", na.rm = TRUE), 0)
})

test_that("theme_blank extension elements control nested facet drawing", {
  for (add_coord in c(FALSE, TRUE)) {
    colours <- theme_passthrough_nested_colours(
      theme_blank(add_coord = add_coord,
                  ggh4x.facet.nestline = ggplot2::element_line(colour = "#AE12F4"))
    )
    expect_gt(sum(colours == "#AE12F4", na.rm = TRUE), 0)
  }
})
