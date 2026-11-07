sankey_data <- function() {
  data.frame(
    sex = factor(c("M", "M", "M", "F"), levels = c("M", "F")),
    stage = factor(c("I", "I", "II", "II"), levels = c("I", "II")),
    grade = factor(c("Low", "High", "Low", "Low"), levels = c("Low", "High"))
  )
}

sankey_payload_plot <- function(include_payload) {
  data <- data.frame(A = c("a", "a", "b", "b"), B = c("x", "y", "x", "y"))
  data$unused <- I(lapply(seq_len(4), function(i) as.raw((seq_len(250000) + i) %% 256)))
  sankey_plot(if (include_payload) data else data[c("A", "B")],
               vars = c("A", "B"), show_text = "name")
}

sankey_plot <- function(data = sankey_data(), vars = names(data), ...) {
  withr::local_options(lifecycle_verbosity = "quiet")
  withCallingHandlers(
    plt_sankey(data, vars = vars, ...),
    warning = function(w) {
      if (identical(conditionMessage(w),
                    "attributes are not identical across measure variables; they will be dropped")) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

test_that("sankey controls reject encoded and dimensional scalar storage", {
  skip_if_not_installed("ggsankey")
  defaults <- list(flow_args = list(alpha = 0.5, smooth = 8),
    node_args = list(width = 0.4, space = 0.1, linewidth = 0.2),
    label_args = list(size = 3, lineheight = 1.2, hjust = 0.5, alpha = 1,
                      min_pct = 0.1, pct_accuracy = 0.1))
  for (arg in names(defaults)) for (field in names(defaults[[arg]]))
    for (shape in c("matrix", "encoded")) {
      value <- defaults[[arg]][[field]]
      bad <- if (shape == "matrix") matrix(value) else structure(value, class = "encoded_number")
      args <- list(data = quote(stop("data evaluated")), vars = c("x", "y"))
      args[[arg]] <- stats::setNames(list(bad), field)
      expect_error(do.call("plt_sankey", args), arg)
    }
})

test_that("plt_sankey retains the default and existing label styles", {
  skip_if_not_installed("ggsankey")

  expected <- list(
    all = c("F (1, 25.0%)", "M (3, 75.0%)", "II (2, 50.0%)", "I (2, 50.0%)",
            "High (1, 25.0%)", "Low (3, 75.0%)"),
    n = c("F (1)", "M (3)", "II (2)", "I (2)", "High (1)", "Low (3)"),
    pct = c("F (25.0%)", "M (75.0%)", "II (50.0%)", "I (50.0%)",
            "High (25.0%)", "Low (75.0%)"),
    name = c("F", "M", "II", "I", "High", "Low")
  )
  expect_identical(levels(sankey_plot()$data$label), expected$all)
  for (style in names(expected)) {
    expect_identical(levels(sankey_plot(show_text = style)$data$label),
                     expected[[style]])
  }
})

test_that("plt_sankey places count and percentage together on the second line", {
  skip_if_not_installed("ggsankey")

  plot <- sankey_plot(show_text = "all_wrap")
  expected <- c(
    "F\n(1, 25.0%)", "M\n(3, 75.0%)", "II\n(2, 50.0%)", "I\n(2, 50.0%)",
    "High\n(1, 25.0%)", "Low\n(3, 75.0%)"
  )
  expect_s3_class(plot, "ggplot")
  expect_identical(levels(plot$data$label), expected)
  expect_setequal(as.character(ggplot2::ggplot_build(plot)$data[[3]]$label),
                  expected)
})

test_that("plt_sankey wrapping preserves flows, counts, ordering and colours", {
  skip_if_not_installed("ggsankey")

  data <- sankey_data()
  original <- data
  for (reverse in c(TRUE, FALSE)) {
    for (palette in list(NULL, c("#114477", "#77AADD"))) {
      single <- ggplot2::ggplot_build(sankey_plot(
        data, show_text = "all", reverse_levels = reverse,
        palette = palette, node_args = list(space = 0)
      ))$data
      wrapped <- ggplot2::ggplot_build(sankey_plot(
        data, show_text = "all_wrap", reverse_levels = reverse,
        palette = palette, node_args = list(space = 0)
      ))$data
      expect_length(wrapped, length(single))
      for (i in seq_along(wrapped)) {
        for (field in intersect(c("node", "label"), names(wrapped[[i]]))) {
          wrapped[[i]][[field]] <- gsub("\n", " ",
            as.character(wrapped[[i]][[field]]), fixed = TRUE)
          single[[i]][[field]] <- as.character(single[[i]][[field]])
        }
        expect_equal(wrapped[[i]], single[[i]])
      }
    }
  }
  expect_identical(data, original)
})

test_that("plt_sankey accepts variable-to-label maps without changing geometry", {
  skip_if_not_installed("ggsankey")

  name_map <- c(stage = "Disease\nstage", sex = "Sex", grade = "")
  plain <- sankey_plot(vars = names(name_map), show_text = "all_wrap")
  named <- sankey_plot(vars = name_map, show_text = "all_wrap")
  plain_build <- ggplot2::ggplot_build(plain)
  named_build <- ggplot2::ggplot_build(named)

  expect_identical(named$data, plain$data)
  expect_equal(named_build$data, plain_build$data)
  expect_identical(plain_build$layout$panel_scales_x[[1]]$get_labels(),
                   paste0(names(name_map), "_label"))
  expect_identical(as.character(named_build$layout$panel_scales_x[[1]]$get_labels()),
                   unname(name_map))
  reordered <- ggplot2::ggplot_build(suppressMessages(named + ggplot2::scale_x_discrete(
    limits = c("sex_label", "stage_label", "grade_label"),
    labels = named$scales$get_scales("x")$labels
  )))
  expect_identical(as.character(reordered$layout$panel_scales_x[[1]]$get_labels()),
                   unname(name_map[c("sex", "stage", "grade")]))
  label_index <- match(reordered$data[[3]]$label, reordered$data[[2]]$label)
  expect_equal(reordered$data[[3]]$x, reordered$data[[2]]$x[label_index])
})

test_that("plt_sankey validates named variable maps", {
  skip_if_not_installed("ggsankey")

  expect_error(sankey_plot(vars = c(sex = "Sex", "Stage")), "non-empty")
  expect_error(sankey_plot(vars = c(sex = "Sex", sex = "Stage")), "unique")
  expect_error(sankey_plot(vars = setNames(c("Sex", "Stage"), c("sex", NA))),
               "non-empty")
  expect_error(sankey_plot(vars = c(sex = "Sex", stage = NA_character_)),
               "non-missing")
  expect_error(sankey_plot(vars = c(sex = 1, stage = 2)), "character")
  expect_error(sankey_plot(vars = c(sex = "Sex", missing = "Stage")),
               "not found.*missing")
})

test_that("plt_sankey isolates counting and stage fields from input names", {
  skip_if_not_installed("ggsankey")
  data <- data.frame(A = c("a", "a", "b", "b"), B = c("x", "y", "x", "y"))
  reference <- ggplot2::ggplot_build(sankey_plot(data, reverse_levels = FALSE,
                                               show_text = "name"))$data
  for (columns in list(c("A", "A_label"), c(".n", "B"), c(".pct", "B"), c("..r", "B"))) {
    renamed <- data
    names(renamed) <- columns
    original <- renamed
    p <- sankey_plot(renamed, reverse_levels = FALSE, show_text = "name")
    paths <- paste(p$data$node[!is.na(p$data$next_x)],
                   p$data$next_node[!is.na(p$data$next_x)])
    expect_equal(length(unique(paths)), 4L)
    expect_equal(ggplot2::ggplot_build(p)$data, reference)
    expect_identical(as.character(ggplot2::ggplot_build(p)$layout$panel_scales_x[[1]]$get_labels()),
                     paste0(columns, "_label"))
    expect_identical(renamed, original)
  }
  data$..r <- seq_len(nrow(data))
  p <- sankey_plot(data, vars = c("A", "B"), reverse_levels = FALSE, show_text = "name")
  expect_equal(ggplot2::ggplot_build(p)$data, reference)
  named <- sankey_plot(stats::setNames(data[c("A", "B")], c("A", "A_label")),
                       vars = c(A = "First", A_label = "Second"), show_text = "name")
  expect_identical(as.character(ggplot2::ggplot_build(named)$layout$panel_scales_x[[1]]$get_labels()),
                   c("First", "Second"))
})

test_that("plt_sankey sizes default palettes to displayed nodes", {
  skip_if_not_installed("ggsankey")
  data <- data.frame(A = factor(c("a", NA, "a", NA), levels = c("a", "unused", "other")),
                     B = factor(c("x", "y", "x", "y")))
  original <- data
  for (reverse in c(FALSE, TRUE)) {
    p <- sankey_plot(data, reverse_levels = reverse)
    built <- ggplot2::ggplot_build(p)$data
    reference <- ggplot2::ggplot_build(sankey_plot(droplevels(data),
                                                   reverse_levels = reverse))$data
    expect_equal(built, reference)
    expect_setequal(as.character(built[[3]]$label),
                     c("a (2, 50.0%)", "NA (2, 50.0%)", "x (2, 50.0%)", "y (2, 50.0%)"))
    expect_equal(length(unique(built[[2]]$fill)), 4L)
  }
  expect_no_error(ggplot2::ggplot_build(sankey_plot(droplevels(data))))
  expect_identical(data, original)
})

test_that("plt_sankey treats SPSS user-missing codes as missing nodes", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("haven")

  data <- data.frame(
    a = haven::labelled_spss(c(1, 99, 2, 99, NA, 1),
                            labels = c(No = 1, Yes = 2, Missing = 99), na_values = 99),
    b = c("x", "x", "y", "y", "x", "y")
  )
  original <- data
  plot <- sankey_plot(data, reverse_levels = FALSE)
  built <- ggplot2::ggplot_build(plot)$data
  expect_setequal(as.character(built[[3]]$label),
                   c("1 (2, 33.3%)", "2 (1, 16.7%)", "NA (3, 50.0%)",
                     "x (3, 50.0%)", "y (3, 50.0%)"))
  expect_equal(built[[2]]$ymax - built[[2]]$ymin, c(2, 1, 3, 3, 3))
  expect_identical(data, original)
})

test_that("plt_sankey normalizes SPSS ranges and character missing codes", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("haven")

  values <- list(
    haven::labelled_spss(c(89, 90, 95, 99, 100, 777, NA, 89),
                         na_range = c(90, 99), na_values = 777),
    haven::labelled_spss(c("low", "missing", "high", "missing", NA, "low"),
                         na_values = "missing")
  )
  normalized <- list(c(89, NA, NA, NA, 100, NA, NA, 89),
                     c("low", NA, "high", NA, NA, "low"))
  for (i in seq_along(values)) {
    data <- data.frame(a = values[[i]], b = rep(c("x", "y"), length.out = length(values[[i]])))
    original <- data
    reference <- data
    reference$a <- normalized[[i]]
    for (reverse in c(FALSE, TRUE)) {
      plot <- sankey_plot(data, reverse_levels = reverse)
      expected <- sankey_plot(reference, reverse_levels = reverse)
      expect_equal(ggplot2::ggplot_build(plot)$data,
                   ggplot2::ggplot_build(expected)$data)
    }
    expect_identical(data, original)
  }
})

test_that("plt_sankey preserves missing nodes across label styles", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("haven")

  data <- data.frame(a = haven::labelled_spss(c(1, 99, NA, 1), na_values = 99),
                     b = c("x", "x", "y", "y"))
  baseline <- ggplot2::ggplot_build(sankey_plot(data))$data
  expect_equal(baseline[[2]]$ymax - baseline[[2]]$ymin, rep(2, 4))
  for (style in c("all_wrap", "n", "pct", "name", "none")) {
    built <- ggplot2::ggplot_build(sankey_plot(data, show_text = style))$data
    for (i in 1:2) {
      fields <- setdiff(names(baseline[[i]]), "label")
      expect_equal(built[[i]][fields], baseline[[i]][fields], info = style)
    }
    if (style == "name") expect_true("NA" %in% built[[3]]$label)
  }
})

test_that("plt_sankey conserves SPSS flows and input-row denominators", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("haven")

  data <- data.frame(
    a = haven::labelled_spss(c(1, 1, 99, 99, 2, NA, 2, 99), na_values = 99),
    b = haven::labelled_spss(c(1, 99, 2, NA, 2, 2, 99, 1), na_values = 99),
    c = haven::labelled_spss(c(999, NA, 999, NA, 999, NA, 999, NA), na_values = 999)
  )
  built <- ggplot2::ggplot_build(sankey_plot(data))$data
  nodes <- built[[2]]
  expect_equal(as.numeric(tapply(nodes$ymax - nodes$ymin, nodes$x, sum)), rep(8, 3))
  expect_setequal(as.character(built[[3]]$label),
                   c("1 (2, 25.0%)", "2 (2, 25.0%)", "NA (4, 50.0%)",
                     "2 (3, 37.5%)", "NA (3, 37.5%)", "NA (8, 100.0%)"))
  flows <- unique(built[[1]][c("group", "xmax", "flow_start_ymin", "flow_start_ymax",
                                "flow_end_ymin", "flow_end_ymax")])
  counts <- flows$flow_start_ymax - flows$flow_start_ymin
  expect_equal(sort(counts), c(rep(1, 6), 2, 2, 3, 3))
  expect_equal(counts, flows$flow_end_ymax - flows$flow_end_ymin)
  expect_equal(as.numeric(tapply(counts, flows$xmax, sum)), c(8, 8))

  filtered <- ggplot2::ggplot_build(sankey_plot(data, label_args = list(min_pct = 0.5)))$data
  expect_equal(filtered[1:2], built[1:2])
  expect_setequal(as.character(filtered[[3]]$label), c("NA (4, 50.0%)", "NA (8, 100.0%)"))
})

test_that("plt_sankey keeps serialized SPSS missingness and valid labelled codes", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("haven")

  data <- data.frame(
    a = haven::labelled_spss(c(1, 99, haven::tagged_na("a"), NA, 2, 1),
                            labels = c(No = 1, Yes = 2, Missing = 99), na_values = 99),
    b = haven::labelled(c(1, 1, 99, NA, 2, 2), labels = c(No = 1, Yes = 2, Valid = 99))
  )
  path <- withr::local_tempfile(fileext = ".rds")
  saveRDS(data, path)
  restored <- readRDS(path)
  reference <- data.frame(a = c(1, NA, NA, NA, 2, 1), b = c(1, 1, 99, NA, 2, 2))
  for (style in c("all", "name")) {
    plot <- sankey_plot(restored, show_text = style)
    expected <- sankey_plot(reference, show_text = style)
    expect_equal(ggplot2::ggplot_build(plot)$data,
                 ggplot2::ggplot_build(expected)$data)
  }
  expect_identical(restored, data)
})

test_that("plt_sankey does not retain unused payload in the returned plot", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("lobstr")
  skip_if_not_installed("ragg")
  full <- sankey_payload_plot(TRUE)
  selected <- sankey_payload_plot(FALSE)
  expect_lt(as.numeric(lobstr::obj_size(full)) - as.numeric(lobstr::obj_size(selected)), 50000)
  files <- c(withr::local_tempfile(), withr::local_tempfile())
  saveRDS(full, files[1], compress = FALSE)
  saveRDS(selected, files[2], compress = FALSE)
  expect_lt(abs(diff(file.info(files)$size)), 50000)
  expect_equal(ggplot2::ggplot_build(full)$data, ggplot2::ggplot_build(selected)$data)
  capture <- function(plot) {
    pixels <- ragg::agg_capture(width = 650, height = 450, units = "px")
    on.exit(grDevices::dev.off())
    print(plot)
    pixels()
  }
  expect_identical(capture(full), capture(selected))
})

test_that("plt_sankey keeps identical category labels distinct across variables", {
  skip_if_not_installed("ggsankey")

  data <- data.frame(a = c("No", "Yes", "No", "Yes"),
                     b = c("No", "Yes", "Yes", "No"))
  plain <- sankey_plot(data, show_text = "name")
  counts <- sankey_plot(data, show_text = "all_wrap")
  plain_build <- ggplot2::ggplot_build(plain)
  counts_build <- ggplot2::ggplot_build(counts)
  nodes <- plain_build$data[[2]]
  expect_equal(nrow(nodes), 4L)
  expect_equal(nodes$ymax - nodes$ymin, rep(2, 4))
  expect_equal(length(unique(nodes$node)), 4L)
  expect_equal(table(as.character(plain_build$data[[3]]$label)),
               table(c("No", "Yes", "No", "Yes")))
  expect_identical(plain$data$node, counts$data$node)
  expect_identical(nodes$fill, counts_build$data[[2]]$fill)
})

test_that("plt_sankey labels follow custom node spacing", {
  skip_if_not_installed("ggsankey")

  for (space in list(NULL, 0, 2)) {
    plot <- sankey_plot(node_args = list(space = space, width = 0.7))
    built <- ggplot2::ggplot_build(plot)
    nodes <- built$data[[2]]
    labels <- built$data[[3]]
    node_labels <- plot$data$label[match(nodes$node, plot$data$node)]
    index <- match(paste(labels$x, labels$label), paste(nodes$x, node_labels))
    expect_false(anyNA(index))
    expect_equal(labels$y, (nodes$ymin[index] + nodes$ymax[index]) / 2)
  }
})

test_that("plt_sankey exposes grouped styling and rejects legacy arguments", {
  skip_if_not_installed("ggsankey")

  defaults <- formals(plt_sankey)
  expect_identical(eval(defaults$flow_args),
                   list(alpha = 0.6, fill = "grey", color = "grey80", smooth = 8))
  expect_identical(eval(defaults$node_args),
                   list(width = 0.4, space = NULL, color = NA, linewidth = NULL))
  expect_identical(eval(defaults$label_args),
                   list(size = 3, lineheight = 1.2, hjust = 0.5, color = "black", box = TRUE,
                        fill = "white", alpha = 1, min_pct = 0, pct_accuracy = 0.1))
  expect_identical(tail(names(defaults), 1), "save")
  for (arg in c("width", "space", "alpha", "label_size", "label_hjust")) {
    expect_error(do.call(sankey_plot, stats::setNames(list(0.5), arg)),
                 "unused argument")
  }
})

test_that("plt_sankey grouped styles reach the rendered layers", {
  skip_if_not_installed("ggsankey")

  plot <- sankey_plot(
    flow_args = list(alpha = 0.25, fill = "red", color = "blue", smooth = 3),
    node_args = list(width = 0.6, space = 0, color = "black", linewidth = 0.8),
    label_args = list(size = 4, hjust = 0, color = "navy", box = FALSE, alpha = 0.7)
  )
  built <- ggplot2::ggplot_build(plot)$data
  expect_identical(unique(built[[1]]$fill), "red")
  expect_identical(unique(built[[1]]$colour), "blue")
  expect_equal(unique(built[[1]]$alpha), 0.25)
  expect_equal(as.numeric(built[[2]]$xmax - built[[2]]$xmin), rep(0.6, nrow(built[[2]])))
  expect_identical(unique(built[[2]]$colour), "black")
  expect_equal(unique(built[[2]]$linewidth), 0.8)
  expect_s3_class(plot$layers[[3]]$geom, "GeomText")
  expect_equal(unique(built[[3]]$size), 4)
  expect_equal(unique(built[[3]]$hjust), 0)
  expect_identical(unique(built[[3]]$colour), "navy")
  expect_equal(unique(built[[3]]$alpha), 0.7)
  # get_labs() exists only from ggplot2 4.0; 3.5.0 keeps labels in `$labels`.
  labels <- if (exists("get_labs", envir = asNamespace("ggplot2"), inherits = FALSE)) {
    ggplot2::get_labs(plot)
  } else {
    plot$labels
  }
  expect_null(labels$y)
})

test_that("plt_sankey controls multiline spacing for boxed and plain labels", {
  skip_if_not_installed("ggsankey")

  for (box in c(TRUE, FALSE)) {
    baseline <- ggplot2::ggplot_build(sankey_plot(
      show_text = "all_wrap", label_args = list(box = box)))$data
    compact <- ggplot2::ggplot_build(sankey_plot(
      show_text = "all_wrap", label_args = list(box = box, lineheight = 0.8)))$data
    expect_equal(unique(baseline[[3]]$lineheight), 1.2)
    expect_equal(unique(compact[[3]]$lineheight), 0.8)
    expect_equal(compact[1:2], baseline[1:2])
    fields <- setdiff(names(baseline[[3]]), "lineheight")
    expect_equal(compact[[3]][fields], baseline[[3]][fields])
  }
  for (bad in list(0, -1, NA_real_, Inf, "1", c(1, 2), NULL)) {
    expect_error(sankey_plot(label_args = list(lineheight = bad)),
                 "lineheight.*positive and finite")
  }
})

test_that("plt_sankey hides labels without changing nodes or flows", {
  skip_if_not_installed("ggsankey")

  visible <- ggplot2::ggplot_build(sankey_plot())
  filtered <- ggplot2::ggplot_build(sankey_plot(label_args = list(min_pct = 0.5)))
  hidden <- ggplot2::ggplot_build(sankey_plot(show_text = "none"))
  expect_equal(nrow(filtered$data[[3]]), 4L)
  expect_length(hidden$data, 2L)
  expect_equal(filtered$data[1:2], visible$data[1:2])
  for (i in 1:2) {
    cols <- setdiff(names(visible$data[[i]]), "label")
    expect_equal(hidden$data[[i]][cols], visible$data[[i]][cols])
  }
  thirds <- data.frame(a = c("a", "b", "b"), b = c("x", "x", "y"))
  labels <- ggplot2::ggplot_build(sankey_plot(thirds,
    label_args = list(pct_accuracy = 1)))$data[[3]]$label
  expect_true(any(grepl("33%", labels, fixed = TRUE)))
})

test_that("plt_sankey validates grouped arguments before rendering", {
  skip_if_not_installed("ggsankey")

  for (arg in c("flow_args", "node_args", "label_args")) {
    for (bad in list(1, list(1), list(unknown = 1),
                    structure(list(1, 2), names = c("alpha", "alpha")))) {
      expect_error(do.call(sankey_plot, stats::setNames(list(bad), arg)), arg)
    }
  }
  expect_error(sankey_plot(flow_args = list(alpha = 2)), "alpha")
  expect_error(sankey_plot(flow_args = list(smooth = 0)), "smooth")
  expect_error(sankey_plot(flow_args = list(fill = "not-a-colour")), "fill")
  expect_error(sankey_plot(node_args = list(width = 0)), "width")
  expect_error(sankey_plot(node_args = list(space = -1)), "space")
  expect_error(sankey_plot(node_args = list(linewidth = Inf)), "linewidth")
  expect_error(sankey_plot(label_args = list(size = 0)), "size")
  expect_error(sankey_plot(label_args = list(hjust = NA)), "hjust")
  expect_error(sankey_plot(label_args = list(alpha = -1)), "alpha")
  expect_error(sankey_plot(label_args = list(box = NA)), "box")
  expect_error(sankey_plot(label_args = list(min_pct = 1.1)), "min_pct")
  expect_error(sankey_plot(label_args = list(pct_accuracy = 0)), "pct_accuracy")
  expect_error(sankey_plot(base_size = 0), "base_size")
  expect_error(sankey_plot(reverse_levels = NA), "reverse_levels")
  default <- ggplot2::ggplot_build(sankey_plot())$data
  empty <- ggplot2::ggplot_build(sankey_plot(
    flow_args = list(), node_args = list(), label_args = list()))$data
  expect_equal(empty, default)
})

test_that("plt_sankey applies custom themes and saves the final plot", {
  skip_if_not_installed("ggsankey")

  theme <- ggplot2::theme_minimal(base_size = 17)
  plot <- sankey_plot(theme_use = theme, base_size = 9)
  expect_equal(plot$theme$text$size, 17)
  expect_equal(sankey_plot(base_size = 19)$theme$text$size, 19)
  for (bad in list(1, list("file"), list(plot = "file"),
                  list(filename = "a", filename = "b"))) {
    expect_error(sankey_plot(save = bad), "save")
  }
  directory <- withr::local_tempdir()
  expect_s3_class(sankey_plot(save = NULL), "ggplot")
  expect_s3_class(sankey_plot(save = list()), "ggplot")
  expect_length(list.files(directory), 0L)
  skip_if_not_installed("RegR")
  path <- file.path(directory, "sankey")
  saved <- sankey_plot(theme_use = theme,
    save = list(filename = path, width = 6, height = 4))
  expect_true(file.exists(paste0(path, ".pdf")))
  expect_gt(file.info(paste0(path, ".pdf"))$size, 0)
  expect_equal(ggplot2::ggplot_build(saved)$data, ggplot2::ggplot_build(plot)$data)
  expect_error(sankey_plot(save = list(filename = paste0(path, ".png"))), "PDF|pdf")
  expect_error(sankey_plot(save = list(filename = path, width = 0)), "width")
  expect_error(sankey_plot(save = list(width = 6)), "filename")
})

test_that("plt_sankey saves at the page its variables and levels are laid out for", {
  skip_if_not_installed("ggsankey")
  skip_if_not_installed("RegR")
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  f <- withr::local_tempfile(fileext = ".pdf")
  # Older RegR builds write to stdout; current builds emit cli messages.
  out <- utils::capture.output(
    cli_out <- cli::cli_fmt(p <- sankey_plot(save = list(filename = f)))
  )
  expect_saved_at_plot_size(c(out, cli_out), p)
  expect_true(file.exists(f))
  expect_gt(file.info(f)$size, 0)
})
