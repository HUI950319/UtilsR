test_that("inset graphics validate before building the main plot", {
  for (bad in list(NULL, 1, "text", list(1)))
    expect_error(grob_insert(stop("plot evaluated"), bad), "inset")
  table <- gtable::gtable(widths = grid::unit(1, "cm"), heights = grid::unit(1, "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(), t = 1, l = 1, name = "panel")
  expect_s3_class(grob_insert(table, grid::textGrob("Inset")), "gtable")
})

test_that("inset controls fail before evaluating the main plot", {
  calls <- 0L
  plot <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point(data = function(data) {
      calls <<- calls + 1L
      data
    })
  for (arg in c("left", "right", "bottom", "top", "on_top", "clip")) {
    bad <- if (arg %in% c("on_top", "clip")) {
      list(NULL, NA, c(TRUE, FALSE), 1)
    } else list(NULL, c(.1, .2), matrix(.1), Inf, grid::unit(c(.1, .2), "npc"))
    for (value in bad) {
      calls <- 0L
      args <- list(plot = plot, inset = grid::rectGrob())
      args[arg] <- list(value)
      error <- tryCatch(do.call(grob_insert, args), error = identity)
      expect_s3_class(error, "error")
      if (inherits(error, "error")) expect_match(conditionMessage(error), arg)
      expect_identical(calls, 0L)
    }
  }
})

test_that("grob_insert() excludes panel annotations when standard panels exist", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "panel")

  for (name in c("annotation-for-panel", "side-panel-note", "main_panel_label",
                 "panel-note", "panel-1-note", "panelist")) {
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = 5, l = 1, r = 6, name = name)
    before <- annotated

    result <- grob_insert(annotated, grid::textGrob("Inset"))
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), c(2, 2, 4, 5))
    expect_identical(annotated, before)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() retains the custom panel-name fallback", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 7), "cm"),
                          heights = grid::unit(rep(1, 6), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 3, l = 2, r = 3, name = "central-panel-left")
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 4, b = 5, l = 5, r = 6, name = "central-panel-right")
  table <- gtable::gtable_add_grob(table, grid::textGrob("Title"),
    t = 1, l = 1, r = 7, name = "title")

  result <- grob_insert(table, grid::rectGrob())
  added <- result$layout[nrow(result$layout), , drop = FALSE]

  expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), c(2, 2, 5, 6))
  expect_no_error(grid::grid.draw(result))
})

test_that("grob_insert() reports a missing panel without range warnings", {
  table <- gtable::gtable(widths = grid::unit(rep(1, 3), "cm"),
                          heights = grid::unit(rep(1, 2), "cm"))
  annotated <- gtable::gtable_add_grob(table, grid::textGrob("Title"),
    t = 1, l = 1, r = 3, name = "title")

  for (input in list(table, annotated)) {
    expect_no_warning(expect_error(
      grob_insert(input, grid::rectGrob()),
      "Cannot find the panel area in 'plot'.", fixed = TRUE
    ))
  }
})

test_that("grob_insert() spans faceted panels without including annotations", {
  withr::local_pdf(NULL)
  data <- expand.grid(x = 1:3, row = c("Top", "Bottom"),
                       column = c("Left", "Right"))
  data$y <- rep(c(2, 1, 3), 4)
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(
    plot + ggplot2::facet_wrap(~row, ncol = 2, scales = "free"),
    plot + ggplot2::facet_grid(row ~ column, switch = "both")
  )

  for (i in seq_along(plots)) {
    table <- ggplot2::ggplotGrob(plots[[i]])
    panels <- table$layout[grepl("^panel", table$layout$name), , drop = FALSE]
    expect_equal(nrow(panels), c(2L, 4L)[i])
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = nrow(table), l = 1, r = ncol(table), name = "panel-1-note")
    before <- annotated

    result <- grob_insert(annotated, grid::rectGrob())
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])),
                 c(min(panels$t), min(panels$l), max(panels$b), max(panels$r)))
    expect_equal(dim(result), dim(annotated))
    expect_identical(annotated, before)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() uses the panel area of patchwork compositions", {
  withr::local_pdf(NULL, width = 7, height = 7)
  data <- expand.grid(x = 1:3, row = c("Top", "Bottom"),
                       column = c("Left", "Right"))
  data$y <- rep(c(2, 1, 3), 4)
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  plots <- list(
    patchwork::wrap_plots(plot, plot + ggplot2::coord_fixed()),
    patchwork::wrap_plots(patchwork::wrap_plots(plot, plot),
                          patchwork::wrap_plots(plot, plot), ncol = 1),
    patchwork::wrap_plots(plot + ggplot2::facet_grid(row ~ column), plot)
  )

  for (composition in plots) {
    table <- patchwork::patchworkGrob(composition)
    panel_area <- table$layout[table$layout$name == "panel-area", , drop = FALSE]
    expect_equal(nrow(panel_area), 1L)
    annotated <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
      t = 1, b = nrow(table), l = 1, r = ncol(table), name = "panel-note")

    for (input in list(composition, annotated)) {
      result <- grob_insert(input, grid::textGrob("Inset"))
      added <- result$layout[nrow(result$layout), , drop = FALSE]

      expect_equal(added[c("t", "l", "b", "r")],
                   panel_area[c("t", "l", "b", "r")], ignore_attr = TRUE)
      expect_equal(result$respect, table$respect)
      expect_equal(result$widths, table$widths)
      expect_equal(result$heights, table$heights)
      expect_no_error(grid::grid.draw(result))
    }
  }
})

test_that("grob_insert() keeps successive insets aligned to custom panels", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "custom-panel")

  result <- grob_insert(grob_insert(table, grid::rectGrob()),
                         grid::textGrob("Second inset"), left = 0.2, bottom = 0.2)
  insets <- result$layout[result$layout$name == "inset", , drop = FALSE]

  expect_equal(nrow(insets), 2L)
  expect_equal(insets$t, c(2, 2))
  expect_equal(insets$l, c(2, 2))
  expect_equal(insets$b, c(4, 4))
  expect_equal(insets$r, c(5, 5))
  expect_no_error(grid::grid.draw(result))
})

test_that("grob_insert() keeps panel, plot and full reference areas distinct", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 2, b = 4, l = 2, r = 5, name = "background")
  table <- gtable::gtable_add_grob(table, grid::rectGrob(),
    t = 3, l = 3, r = 4, name = "panel")
  table <- gtable::gtable_add_grob(table, grid::textGrob("Panel note"),
    t = 1, b = 5, l = 1, r = 6, name = "annotation-for-panel")
  expected <- list(panel = c(3, 3, 3, 4), plot = c(2, 2, 4, 5),
                    full = c(1, 1, 5, 6))

  for (align_to in names(expected)) {
    result <- grob_insert(table, grid::rectGrob(), align_to = align_to)
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), expected[[align_to]])
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() supports plot and full alignment without panels", {
  withr::local_pdf(NULL)
  table <- gtable::gtable(widths = grid::unit(rep(1, 6), "cm"),
                          heights = grid::unit(rep(1, 5), "cm"))
  table <- gtable::gtable_add_grob(table, grid::textGrob("Title"),
    t = 1, l = 2, r = 5, name = "title")

  for (align_to in c("plot", "full")) {
    result <- grob_insert(table, grid::rectGrob(), align_to = align_to)
    added <- result$layout[nrow(result$layout), , drop = FALSE]

    expect_equal(unname(unlist(added[c("t", "l", "b", "r")])), c(1, 1, 5, 6))
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("grob_insert() preserves inset coordinates and drawing controls", {
  withr::local_pdf(NULL)
  data <- data.frame(x = 1:3, y = c(2, 1, 3))
  plot <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
  inset <- grid::gList(grid::rectGrob(), grid::textGrob("Inset"))
  table <- ggplot2::ggplotGrob(plot)

  for (on_top in c(TRUE, FALSE)) {
    result <- grob_insert(plot, inset, left = 0.2, bottom = 0.3,
                           right = 0.8, top = 0.7, on_top = on_top, clip = on_top)
    added <- result$layout[nrow(result$layout), , drop = FALSE]
    viewport <- result$grobs[[length(result$grobs)]]$vp

    expect_equal(as.numeric(viewport$x), 0.2)
    expect_equal(as.numeric(viewport$y), 0.3)
    expect_equal(as.numeric(viewport$width), 0.6)
    expect_equal(as.numeric(viewport$height), 0.4)
    expect_equal(grid::unitType(viewport$width), "npc")
    expect_identical(added$clip, if (on_top) "on" else "off")
    expect_equal(added$z, if (on_top) max(table$layout$z) + 1L else 0L)
    expect_no_error(grid::grid.draw(result))
  }

  result <- grob_insert(table, grid::rectGrob(),
                         left = grid::unit(2, "mm"), bottom = grid::unit(3, "mm"),
                         right = grid::unit(12, "mm"), top = grid::unit(13, "mm"))
  viewport <- result$grobs[[length(result$grobs)]]$vp
  expect_equal(grid::convertWidth(viewport$width, "mm", valueOnly = TRUE), 10)
  expect_equal(grid::convertHeight(viewport$height, "mm", valueOnly = TRUE), 10)
  expect_no_error(grid::grid.draw(result))
})

test_that("inset clipping limits pixels to the requested rectangle", {
  skip_if_not_installed("ragg")
  table <- gtable::gtable(widths = grid::unit(1, "npc"), heights = grid::unit(1, "npc"))
  table <- gtable::gtable_add_grob(table, grid::rectGrob(gp = grid::gpar(fill = "white", col = NA)), t = 1, l = 1, name = "panel")
  inset <- grid::rectGrob(width = grid::unit(3, "npc"), height = grid::unit(3, "npc"), gp = grid::gpar(fill = "red", col = NA))
  red_width <- function(clip) {
    capture <- ragg::agg_capture(width = 100, height = 100, units = "px", res = 96, background = "white")
    on.exit(grDevices::dev.off())
    grid::grid.draw(grob_insert(table, inset, left = .4, bottom = .4, right = .6, top = .6, clip = clip))
    img <- capture()
    at <- which(matrix(as.vector(img) %in% c("#FF0000", "#FF0000FF", "red"), nrow = 100L), arr.ind = TRUE)
    diff(range(at[, 2L])) + 1L
  }
  expect_equal(red_width(TRUE), 20L)
  expect_equal(red_width(FALSE), 60L)
})

test_that("inserting into an empty gtable assigns a finite drawing order", {
  gt <- gtable::gtable(grid::unit(1, "null"), grid::unit(1, "null"))
  for (alignment in c("plot", "full")) {
    expect_no_warning(result <- grob_insert(gt, grid::rectGrob(), align_to = alignment))
    expect_identical(result$layout$name, "inset")
    expect_equal(result$layout$z, 1)
    expect_length(gt$grobs, 0L)
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("behind-panel insets respect custom gtable drawing orders", {
  for (orders in list(c(-6, -5), c(5, 6))) {
    base <- gtable::gtable(widths = grid::unit(1, "null"), heights = grid::unit(1, "null"))
    base <- gtable::gtable_add_grob(base, list(grid::rectGrob(), grid::pointsGrob()),
      t = 1, l = 1, name = c("background", "panel"), z = orders)
    result <- grob_insert(base, grid::textGrob("Behind"), on_top = FALSE)
    z <- stats::setNames(result$layout$z, result$layout$name)
    expect_gte(unname(z["inset"]), unname(z["background"]))
    expect_lt(unname(z["inset"]), unname(z["panel"]))
    expect_no_error(grid::grid.draw(result))
  }
})

test_that("inset coordinates decode serialized integer64 values", {
  skip_if_not_installed("bit64")
  scratch <- withr::local_tempdir()
  input <- file.path(scratch, "input.rds")
  script <- file.path(scratch, "verify.R")
  path <- getNamespaceInfo(asNamespace("UtilsR"), "path")
  bounds <- stats::setNames(lapply(c(1, 2, 3, 5), bit64::as.integer64),
                            c("left", "bottom", "right", "top"))
  saveRDS(list(path = path, libs = .libPaths(), bounds = bounds), input)
  writeLines(c(sprintf("payload <- readRDS(%s)", deparse(input)),
    '.libPaths(payload[["libs"]])',
    'path <- payload[["path"]]',
    'if (file.exists(file.path(path, "Meta", "package.rds"))) {',
    '  library("UtilsR", lib.loc = dirname(path))',
    '} else pkgload::load_all(path, quiet = TRUE)',
    'stopifnot(!("bit64" %in% loadedNamespaces()))',
    'base <- gtable::gtable(widths = grid::unit(1, "cm"), heights = grid::unit(1, "cm"))',
    'out <- do.call(UtilsR::grob_insert, c(list(base, grid::rectGrob(), align_to = "full"), payload[["bounds"]]))',
    'stopifnot("bit64" %in% loadedNamespaces())',
    'vp <- out[["grobs"]][[1L]][["vp"]]',
    'stopifnot(identical(vapply(vp[c("x", "y", "width", "height")], as.numeric, 0),',
    '                    c(x = 1, y = 2, width = 2, height = 3)))',
    'cat("COLD_INSET_OK\\n")'), script)
  output <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script)), stdout = TRUE, stderr = TRUE))
  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
  expect_true("COLD_INSET_OK" %in% output)
})

test_that("plot-aligned ggplot insets exclude outer margin cells", {
  withr::local_pdf(NULL)
  plot <- ggplot2::ggplot(data.frame(x = 1:3), ggplot2::aes(x, x)) +
    ggplot2::geom_point() + ggplot2::theme(plot.margin = ggplot2::margin(20, 30, 40, 50))
  full <- grob_insert(plot, grid::rectGrob(), align_to = "full")
  inner <- grob_insert(plot, grid::rectGrob(), align_to = "plot")
  row <- inner$layout[nrow(inner$layout), ]
  expect_equal(c(row$t, row$l, row$b, row$r), c(2, 2, nrow(inner) - 1, ncol(inner) - 1))
  outer <- full$layout[nrow(full$layout), ]
  expect_equal(c(outer$t, outer$l, outer$b, outer$r), c(1, 1, nrow(full), ncol(full)))
  expect_no_error(grid::grid.draw(inner))
})

test_that("plot-aligned insets locate the actual named background", {
  table <- gtable::gtable(widths = grid::unit(rep(1, 4), "cm"),
                          heights = grid::unit(rep(1, 4), "cm"))
  table <- gtable::gtable_add_grob(table, list(grid::nullGrob(), grid::rectGrob()),
    t = c(1L, 2L), b = c(4L, 3L), l = c(1L, 2L), r = c(4L, 3L),
    name = c(NA_character_, "background"))
  result <- grob_insert(table, grid::textGrob("inset"), align_to = "plot")
  expect_equal(unname(unlist(tail(result$layout, 1L)[c("t", "b", "l", "r")])), c(2, 3, 2, 3))
})

test_that("behind insets account for overlapping grobs with missing names", {
  gt <- gtable::gtable(grid::unit(rep(1, 3L), "cm"), grid::unit(rep(1, 3L), "cm"))
  gt <- gtable::gtable_add_grob(gt,
    list(grid::rectGrob(), grid::rectGrob(), grid::rectGrob()),
    t = c(1, 2, 2), b = c(3, 2, 2), l = c(1, 2, 2), r = c(3, 2, 2),
    name = c("background", NA, "panel"), z = c(-50, -10, 1))
  result <- grob_insert(gt, grid::rectGrob(), on_top = FALSE)
  expect_equal(tail(result$layout$z, 1L), -11)
})

test_that("plot alignment matches for ggplots and their rendered gtables", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point() +
    ggplot2::theme(plot.margin = ggplot2::margin(7, 11, 13, 17))
  bounds <- function(x, align) {
    row <- tail(grob_insert(x, grid::rectGrob(), align_to = align)$layout, 1L)
    unname(unlist(row[c("t", "l", "b", "r")]))
  }
  for (plot in list(p, p + ggplot2::facet_wrap(ggplot2::vars(cyl)))) {
    gt <- grob_as(plot)
    expect_equal(bounds(gt, "plot"), bounds(plot, "plot"))
    expect_equal(bounds(gt, "full"), bounds(plot, "full"))
  }
})
