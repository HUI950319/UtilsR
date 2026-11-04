com_plot <- function(data = iris) {
  ggplot2::ggplot(data, ggplot2::aes(Species, Sepal.Length)) +
    ggplot2::geom_boxplot()
}

com_stat <- function(plot) {
  built <- ggplot2::ggplot_build(plot)
  unique(built$data[[length(built$data)]][, c("PANEL", "group1", "group2", "p", "p.adj", "label", "xmin", "xmax")])
}

test_that("comparisons resolve observed groups in displayed scale order", {
  p <- com_plot(subset(iris, Species != "versicolor"))
  expect_error(fmt_com(p, com_method = list(c("setosa", "versicolor"))),
               "observed")
  s <- com_stat(fmt_com(p, com_method = list(c("setosa", "virginica"))))
  expect_equal(as.numeric(s$xmin), 1)
  expect_equal(as.numeric(s$xmax), 2)

  p <- com_plot() + ggplot2::scale_x_discrete(
    limits = c("virginica", "setosa", "versicolor")
  )
  s <- com_stat(fmt_com(p, com_method = list(c("setosa", "versicolor"))))
  expect_equal(as.numeric(s$xmin), 2)
  expect_equal(as.numeric(s$xmax), 3)
  expected <- stats::wilcox.test(iris$Sepal.Length[iris$Species == "setosa"],
                                iris$Sepal.Length[iris$Species == "versicolor"])$p.value
  expect_equal(s$p, signif(expected, 3), tolerance = 0.01)
  s <- com_stat(fmt_com(p))
  expect_equal(as.numeric(s$xmin), c(1, 2))
  expect_equal(as.numeric(s$xmax), c(2, 3))
})

test_that("automatic comparisons use the groups available in each facet", {
  d <- rbind(transform(subset(iris, Species != "setosa"), panel = "A"),
             transform(subset(iris, Species != "versicolor"), panel = "B"))
  p <- com_plot(d) + ggplot2::facet_wrap(~panel, scales = "free_x")
  s <- com_stat(fmt_com(p))
  expect_equal(nrow(s), 2L)
  expect_equal(as.numeric(s$xmin), c(1, 1))
  expect_equal(as.numeric(s$xmax), c(2, 2))
})

test_that("adjusted labels and custom templates preserve the raw-label default", {
  set.seed(401)
  d <- data.frame(Species = rep(LETTERS[1:5], each = 20),
                  Sepal.Length = rnorm(100) + rep(seq(0, .8, length.out = 5), each = 20))
  p <- com_plot(d)
  s <- com_stat(fmt_com(p, com_method = "all", method = "t_test",
                       p.adjust.method = "bonferroni", label = "p.adj.signif"))
  changed <- s$p < .05 & s$p.adj >= .05
  expect_equal(sum(changed), 1L)
  expect_equal(s$label[changed], "ns")
  raw <- com_stat(fmt_com(p, com_method = "all", method = "t_test",
                         p.adjust.method = "bonferroni"))
  expect_equal(raw$label[changed], "*")
  formatted <- com_stat(fmt_com(p, label = "p.adj.format"))
  expect_type(formatted$label, "character")
  custom <- com_stat(fmt_com(p, label = "adjusted {p.adj.format}"))
  expect_equal(startsWith(custom$label, "adjusted "), rep(TRUE, nrow(custom)))
})

test_that("extra arguments override defaults without duplicate matching", {
  p <- com_plot()
  q <- fmt_com(p, method = "t_test", method.args = list(paired = TRUE),
               com_method = list(c("setosa", "versicolor")), fontface = "plain",
               symnum.args = list(cutpoints = c(0, .05, Inf), symbols = c("yes", "no")))
  s <- com_stat(q)
  expected <- stats::t.test(iris$Sepal.Length[iris$Species == "setosa"],
                           iris$Sepal.Length[iris$Species == "versicolor"], paired = TRUE)$p.value
  expect_equal(s$p, signif(expected, 3), tolerance = 0.01)
  expect_equal(s$label, "yes")
  expect_equal(q$layers[[2]]$aes_params$fontface, "plain")
  q <- fmt_com(p, method = "t_test", method.args = list(alternative = "greater"),
               com_method = list(c("setosa", "versicolor")))
  expect_equal(com_stat(q)$p, 1)
  expect_error(fmt_com(p, method.args = list(comparisons = list(c(1, 2)))),
               "com_method")
  expect_equal(length(p$layers), 1L)
})

test_that("explicit grouping controls retain the intended comparison variable", {
  d <- transform(ToothGrowth, dose = factor(dose))
  p <- ggplot2::ggplot(d, ggplot2::aes(dose, len, group = interaction(dose, supp))) +
    ggplot2::geom_boxplot()
  actual <- com_stat(fmt_com(p, group.by = "x.var", method = "t_test"))
  expected <- com_stat(p + ggpubr::geom_pwc(group.by = "x.var", method = "t_test"))
  expected_p <- vapply(split(d, d$dose), function(part) {
    stats::t.test(len ~ supp, data = part)$p.value
  }, numeric(1))
  expect_equal(actual$p, unname(signif(expected_p, 3)))
  expect_equal(as.numeric(actual$xmin), as.numeric(expected$xmin))
  expect_equal(as.numeric(actual$xmax), as.numeric(expected$xmax))

  p <- ggplot2::ggplot(d, ggplot2::aes(dose, len, fill = supp)) + ggplot2::geom_boxplot()
  s <- com_stat(fmt_com(p, group.by = "x.var", method = "t_test",
                       com_method = list(c("OJ", "VC"))))
  expect_equal(nrow(s), 3L)
  s <- com_stat(fmt_com(p, group.by = "legend.var", method = "t_test"))
  expect_equal(nrow(s), 4L)
  q <- fmt_com(p, mapping = ggplot2::aes(group = supp), method = "t_test")
  expect_equal(nrow(com_stat(q)), 3L)

  subjects <- transform(iris, subject = rep(seq_len(50), 3))
  trajectories <- com_plot(subjects) + ggplot2::aes(group = subject)
  mapping_before <- trajectories$mapping$group
  expect_equal(com_stat(fmt_com(trajectories))$p, com_stat(fmt_com(com_plot()))$p)
  expect_identical(trajectories$mapping$group, mapping_before)
})

test_that("full-family methods filter requested pairs and display available P values", {
  p <- com_plot()
  pair <- list(c("setosa", "versicolor"))
  for (method in c("dunn_test", "tukey_hsd", "games_howell_test")) {
    s <- com_stat(fmt_com(p, method = method, com_method = pair))
    expect_equal(nrow(s), 1L, info = method)
    expect_equal(as.numeric(s$xmin), 1, info = method)
    expect_equal(as.numeric(s$xmax), 2, info = method)
    expect_equal(nzchar(s$label), TRUE, info = method)
    expect_equal(nrow(com_stat(fmt_com(p, method = method))), 2L, info = method)
    expect_equal(nrow(com_stat(fmt_com(p, method = method, com_method = "all"))), 3L,
                 info = method)
  }
  dunn <- rstatix::dunn_test(iris, Sepal.Length ~ Species)
  expected <- dunn$p.adj[dunn$group1 == "setosa" & dunn$group2 == "versicolor"]
  expect_equal(com_stat(fmt_com(p, method = "dunn_test", com_method = pair))$p.adj,
               expected)
})

test_that("nested containers retain layout, annotations and protected cells", {
  p <- com_plot()
  pw <- (p | p) / (p | p) + patchwork::plot_annotation(title = "Comparisons")
  q <- fmt_com(pw)
  counts <- function(x) {
    if (inherits(x, "patchwork")) {
      return(unlist(lapply(seq_along(x), function(i) counts(x[[i]]))))
    }
    length(x$layers)
  }
  expect_equal(counts(q), rep(2L, 4))
  expect_identical(q$patches$layout, pw$patches$layout)
  expect_identical(q$patches$annotation, pw$patches$annotation)
  grDevices::pdf(file = NULL)
  device <- grDevices::dev.cur()
  tryCatch(expect_s3_class(patchwork::patchworkGrob(q), "gtable"),
           finally = grDevices::dev.off(device))
  expect_equal(counts(pw), rep(1L, 4))
  expect_identical(pw[[1]][[1]]$data, iris)

  mixed <- p + patchwork::plot_spacer() + patchwork::guide_area() +
    patchwork::wrap_elements(full = p)
  q <- fmt_com(mixed)
  expect_equal(length(q[[1]]$layers), 2L)
  for (i in 2:4) expect_identical(q[[i]], mixed[[i]])
  inset <- p + patchwork::inset_element(p, .6, .6, 1, 1)
  q <- fmt_com(inset)
  expect_equal(length(q[[1]]$layers), 2L)
  expect_identical(q[[2]], inset[[2]])
  named <- list(first = p, second = pw)
  expect_equal(names(fmt_com(named)), names(named))
})

com_y <- function(plot) {
  b <- ggplot2::ggplot_build(plot)
  d <- b$data[[length(b$data)]]
  d[d$x != d$xend, c("PANEL", "y")]
}

test_that("bracket positions use data units and panel-local transformed ranges", {
  p <- com_plot()
  expect_equal(com_y(fmt_com(p, label.y = 8))$y[1], 8)
  expect_equal(com_y(fmt_com(p, label.y = 8, bracket.nudge.y = .1))$y[1], 8.36)
  q <- p + ggplot2::scale_y_log10()
  expect_equal(com_y(fmt_com(q, label.y = 8))$y[1], log10(8))
  limits <- range(log10(iris$Sepal.Length))
  expected <- limits[1] + .9 * diff(limits)
  expect_equal(com_y(fmt_com(q, label.y.prop = .9))$y[1], unname(expected))
  expect_equal(com_y(fmt_com(q, label.y = 8, label.y.prop = .2))$y[1], log10(8))

  d <- rbind(transform(iris, panel = "small"),
             transform(iris, Sepal.Length = Sepal.Length * 100, panel = "large"))
  q <- com_plot(d) + ggplot2::facet_wrap(~panel, scales = "free_y")
  y <- com_y(fmt_com(q, label.y.prop = .9))
  first <- y$y[!duplicated(y$PANEL)]
  expect_equal(first, c(754, 7.54))
})

test_that("invalid comparison and position arguments fail before drawing", {
  p <- com_plot()
  for (bad in list(list(), list(c("setosa", "setosa")), list(c("setosa", NA)),
                  list(c("setosa", "versicolor"), c("versicolor", "setosa")))) {
    expect_error(fmt_com(p, com_method = bad), "com_method")
  }
  for (bad in list(-.1, 2, NA_real_, c(.5, .9), "high")) {
    expect_error(fmt_com(p, label.y.prop = bad), "label.y.prop")
  }
  expect_error(fmt_com(p, label.y = Inf), "label.y")
  expect_error(fmt_com(p, tip.length = -.1), "tip.length")
  expect_error(fmt_com(p, step.increase = NA_real_), "step.increase")
  expect_error(fmt_com(p, size = -1), "size")
  expect_error(fmt_com(p, method.args = 1), "method.args")
  expect_error(fmt_com(p, method.args = list(TRUE)), "method.args")
  expect_error(fmt_com(p, method.args = list(paired = TRUE, paired = FALSE)), "method.args")
  expect_error(fmt_com(p, y.position = 8), "label.y")
  expect_error(fmt_com(com_plot(subset(iris, Species == "setosa"))), "two")
  expect_error(fmt_com(ggplot2::ggplot(iris, ggplot2::aes(Sepal.Width, Sepal.Length)) +
                         ggplot2::geom_point()), "categorical")
})

test_that("statistical sources resolve layer mappings and explicit overrides", {
  root <- com_plot()
  layer_only <- ggplot2::ggplot() +
    ggplot2::geom_boxplot(data = iris, ggplot2::aes(Species, Sepal.Length))
  expect_equal(com_stat(fmt_com(layer_only))$p, com_stat(fmt_com(root))$p)
  partial <- ggplot2::ggplot(iris, ggplot2::aes(Species)) +
    ggplot2::geom_boxplot(ggplot2::aes(y = Sepal.Length))
  expect_equal(com_stat(fmt_com(partial))$p, com_stat(fmt_com(root))$p)
  d <- subset(iris, Species != "versicolor")
  q <- fmt_com(root, data = d, com_method = list(c("setosa", "virginica")))
  expect_equal(com_stat(q)$p, com_stat(fmt_com(com_plot(d)))$p)
  expect_error(fmt_com(root, data = d, com_method = list(c("setosa", "versicolor"))), "observed")
  ambiguous <- layer_only + ggplot2::geom_point(data = d, ggplot2::aes(Species, Sepal.Length))
  expect_error(fmt_com(ambiguous), "ambiguous")
  expect_equal(com_stat(fmt_com(ambiguous, data = iris,
                               mapping = ggplot2::aes(Species, Sepal.Length)))$p,
               com_stat(fmt_com(root))$p)
  expect_error(fmt_com(root, data = function(d) d), "data.frame")
})

test_that("SPSS user-missing outcomes are omitted before statistical mapping", {
  skip_if_not_installed("haven")
  d <- data.frame(x = rep(c("A", "B"), each = 7),
                  y = c(1, 2, 3, 4, 5, 95, 99, 2, 3, 4, 7, 8, 9, 10))
  expected <- signif(stats::t.test(1:5, c(2, 3, 4, 7, 8, 9, 10))$p.value, 3)
  missing <- list(list(na_values = c(95, 99)), list(na_range = c(95, 99)),
                  list(na_values = 99, na_range = c(95, 98)))
  for (spec in missing) {
    data <- d
    data$y <- do.call(haven::labelled_spss, c(list(x = d$y), spec))
    p <- ggplot2::ggplot(data, ggplot2::aes(x, y * 2)) + ggplot2::geom_point()
    q <- fmt_com(p, method = "t_test", na.rm = TRUE)
    s <- unique(ggplot2::ggplot_build(q)$data[[2]][, c("n1", "n2", "p")])
    expect_equal(s$n1, 5L)
    expect_equal(s$n2, 7L)
    expect_equal(s$p, expected)
    expect_identical(p$data, data)
  }
})

test_that("SPSS omissions apply to plot, layer and explicit statistical sources", {
  skip_if_not_installed("haven")
  d <- data.frame(x = rep(c("A", "B", "missing"), each = 6),
                  y = c(1, 2, 3, 5, 7, 9, 2, 3, 4, 7, 8, 10, rep(99, 6)))
  d$x <- haven::labelled_spss(d$x, na_values = "missing")
  d$y <- haven::labelled_spss(d$y, na_values = 99)
  p <- ggplot2::ggplot(d, ggplot2::aes(factor(x), y * 2)) + ggplot2::geom_point()
  layer <- ggplot2::ggplot() +
    ggplot2::geom_point(data = d, ggplot2::aes(factor(x), y * 2))
  expected <- signif(stats::t.test(c(1, 2, 3, 5, 7, 9), c(2, 3, 4, 7, 8, 10))$p.value, 3)
  plots <- list(fmt_com(p, method = "t_test", na.rm = TRUE),
                 fmt_com(layer, method = "t_test", na.rm = TRUE),
                 fmt_com(ggplot2::ggplot(), data = d,
                         mapping = ggplot2::aes(factor(x), y * 2),
                         method = "t_test", na.rm = TRUE))
  for (plot in plots) {
    s <- com_stat(plot)
    expect_equal(nrow(s), 1L)
    expect_equal(s$p, expected)
  }
  expect_identical(p$data, d)
  expect_identical(layer$layers[[1]]$data, d)
  expect_error(fmt_com(p, com_method = list(c("A", "missing"))), "observed")

  only_missing <- data.frame(x = rep(c("A", "B", "C"), each = 6), y = d$y)
  p <- ggplot2::ggplot(only_missing, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_error(fmt_com(p, com_method = list(c("A", "C"))), "observed")
  only_missing$y <- haven::labelled_spss(rep(99, nrow(only_missing)), na_values = 99)
  p$data <- only_missing
  expect_error(fmt_com(p), "finite numeric observations")
})

test_that("SPSS omissions retain row alignment for paired tests", {
  skip_if_not_installed("haven")
  d <- data.frame(id = rep(1:5, 2), x = rep(c("A", "B"), each = 5),
                  y = c(1, 2, 4, 8, 99, 99, 5, 5, 9, 16))
  d$y <- haven::labelled_spss(d$y, na_values = 99)
  expected <- signif(stats::t.test(c(2, 4, 8), c(5, 5, 9), paired = TRUE)$p.value, 3)
  for (id in list(NULL, "id")) {
    data <- if (is.null(id)) d else d[c(1:5, 10:6), ]
    p <- ggplot2::ggplot(data, ggplot2::aes(x, y)) + ggplot2::geom_point()
    q <- fmt_com(p, method = "t_test", method.args = list(paired = TRUE, id = id),
                 na.rm = TRUE)
    s <- unique(ggplot2::ggplot_build(q)$data[[2]][, c("n1", "n2", "p")])
    expect_equal(s$n1, 3L)
    expect_equal(s$n2, 3L)
    expect_equal(s$p, expected)
    expect_identical(p$data, data)
  }
})

test_that("SPSS outcome omissions preserve the original facet values", {
  skip_if_not_installed("haven")
  d <- data.frame(x = rep(rep(c("A", "B"), each = 6), 2),
                  y = rep(c(1, 2, 3, 4, 5, 99, 2, 3, 4, 7, 8, 9), 2),
                  panel = rep(c(1, 99), each = 12))
  d$y <- haven::labelled_spss(d$y, na_values = 99)
  d$panel <- haven::labelled_spss(d$panel, na_values = 99)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point() +
    ggplot2::facet_wrap(~panel)
  before <- ggplot2::ggplot_build(p)$layout$layout
  q <- fmt_com(p, method = "t_test", na.rm = TRUE)
  built <- ggplot2::ggplot_build(q)
  expect_identical(built$layout$layout, before)
  s <- unique(built$data[[2]][, c("PANEL", "n1", "n2", "p")])
  expected <- signif(stats::t.test(1:5, c(2, 3, 4, 7, 8, 9))$p.value, 3)
  expect_equal(s$n1, rep(5L, 2))
  expect_equal(s$n2, rep(6L, 2))
  expect_equal(s$p, rep(expected, 2))
  expect_identical(p$data, d)
})

test_that("SPSS outcomes mapped from an environment omit user-missing values", {
  skip_if_not_installed("haven")
  d <- data.frame(x = rep(c("A", "B"), each = 6),
                  .fmt_com_x = 1:12, .fmt_com_y = 12:1)
  outcome <- haven::labelled_spss(c(1, 2, 3, 4, 5, 99, 2, 3, 4, 7, 8, 9),
                                 na_values = 99)
  original <- outcome
  p <- ggplot2::ggplot(d, ggplot2::aes(x, .env$outcome)) + ggplot2::geom_point()
  q <- fmt_com(p, method = "t_test", na.rm = TRUE)
  s <- unique(ggplot2::ggplot_build(q)$data[[2]][, c("n1", "n2", "p")])
  expected <- signif(stats::t.test(1:5, c(2, 3, 4, 7, 8, 9))$p.value, 3)
  expect_equal(s$n1, 5L)
  expect_equal(s$n2, 6L)
  expect_equal(s$p, expected)
  expect_identical(p$data, d)
  expect_identical(outcome, original)
})

test_that("SPSS environment vectors are normalized before mapping transformations", {
  skip_if_not_installed("haven")
  d <- data.frame(x = rep(c("A", "B"), each = 6))
  outcome <- haven::labelled_spss(c(1, 2, 3, 4, 5, 99, 2, 3, 4, 7, 8, 9),
                                 na_values = 99)
  external <- data.frame(outcome = outcome)
  original <- outcome
  original_external <- external
  twice <- function(z) z * 2
  stage <- function(z) z * 2
  key <- "outcome"
  nested <- rlang::quo(.env$outcome)
  mappings <- list(ggplot2::aes(x, .env$outcome * 2),
                    ggplot2::aes(x, outcome * 2),
                    ggplot2::aes(x, .env[[key]] * 2),
                    ggplot2::aes(x, .env$external$outcome * 2),
                    ggplot2::aes(x, .env$external[, "outcome"] * 2),
                    ggplot2::aes(x, .env$twice(.env$outcome)),
                    ggplot2::aes(x, (function(z) z * 2)(.env$outcome)),
                    ggplot2::aes(x, 1 + stage(.env$outcome)),
                    ggplot2::aes(x, (!!nested) * 2),
                    ggplot2::aes(x, (!!outcome) * 2))
  expected <- signif(stats::t.test(1:5, c(2, 3, 4, 7, 8, 9))$p.value, 3)
  for (mapping in mappings) {
    p <- ggplot2::ggplot(d, mapping) + ggplot2::geom_point()
    q <- fmt_com(p, method = "t_test", na.rm = TRUE)
    s <- unique(ggplot2::ggplot_build(q)$data[[2]][, c("n1", "n2", "p")])
    expect_equal(s$n1, 5L)
    expect_equal(s$n2, 6L)
    expect_equal(s$p, expected)
    expect_identical(p$data, d)
  }
  p <- ggplot2::ggplot(d, ggplot2::aes(x, log(.env$outcome))) + ggplot2::geom_point()
  expected_log <- signif(stats::t.test(log(1:5), log(c(2, 3, 4, 7, 8, 9)))$p.value, 3)
  expect_equal(com_stat(fmt_com(p, method = "t_test", na.rm = TRUE))$p, expected_log)
  with_stage <- d
  with_stage$stage <- outcome
  p <- ggplot2::ggplot(with_stage, ggplot2::aes(x, 1 + stage * 2)) +
    ggplot2::geom_point()
  expect_equal(com_stat(fmt_com(p, method = "t_test", na.rm = TRUE))$p, expected)
  expect_identical(p$data, with_stage)
  shadowed <- d
  shadowed$outcome <- as.numeric(outcome)
  p <- ggplot2::ggplot(shadowed, ggplot2::aes(x, outcome * 2)) + ggplot2::geom_point()
  expected_plain <- signif(stats::t.test(outcome ~ x, data = shadowed)$p.value, 3)
  expect_equal(com_stat(fmt_com(p, method = "t_test", na.rm = TRUE))$p, expected_plain)
  expect_identical(outcome, original)
  expect_identical(external, original_external)
})

test_that("ordinary missing comparison subsets do not depend on SPSS columns", {
  d <- expand.grid(id = 1:5, g = c("A", "B", NA_character_),
                    x = c("left", "right"), KEEP.OUT.ATTRS = FALSE,
                    stringsAsFactors = FALSE)
  d$y <- d$id + ifelse(is.na(d$g), 3, ifelse(d$g == "B", 1, 0))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) + ggplot2::geom_point()
  actual <- com_stat(fmt_com(p, group.by = "legend.var", method = "t_test"))
  expected_data <- d[!is.na(d$g), ]
  clean <- ggplot2::ggplot(expected_data, ggplot2::aes(x, y, fill = g)) +
    ggplot2::geom_point()
  expected <- com_stat(fmt_com(clean, group.by = "legend.var", method = "t_test"))
  expect_equal(actual, expected)
  expect_identical(p$data, d)
  if (requireNamespace("haven", quietly = TRUE)) {
    unrelated <- p
    unrelated$data$unused <- haven::labelled_spss(rep(1, nrow(d)), na_values = 99)
    expect_equal(com_stat(fmt_com(unrelated, group.by = "legend.var", method = "t_test")),
                 expected)
  }
})

test_that("SPSS missing comparison groups are omitted within grouped subsets", {
  skip_if_not_installed("haven")
  d <- expand.grid(subject = 1:6, g = c("A", "B", "missing"),
                    x = c("left", "right"), panel = c(1, 99),
                    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  d$y <- d$subject + ifelse(d$g == "B", c(1, 2, 1, 3, 2, 5)[d$subject], 0)
  d$y[d$g == "A" & d$subject == 6 | d$g == "B" & d$subject == 1] <- 99
  d$g <- haven::labelled_spss(d$g, na_values = "missing")
  d$y <- haven::labelled_spss(d$y, na_values = 99)
  d$panel <- haven::labelled_spss(d$panel, na_values = 99)
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = factor(g))) +
    ggplot2::geom_point() + ggplot2::facet_wrap(~panel)
  external_group <- d$g
  plain <- data.frame(x = d$x, y = as.numeric(haven::zap_missing(d$y)),
                       panel = as.numeric(d$panel))
  external <- ggplot2::ggplot(plain, ggplot2::aes(x, y)) +
    ggplot2::geom_point(na.rm = TRUE) + ggplot2::facet_wrap(~panel)
  plots <- list(fmt_com(p, group.by = "legend.var", method = "t_test", na.rm = TRUE),
                 fmt_com(external, group.by = "legend.var", method = "t_test",
                         mapping = ggplot2::aes(group = .env$external_group), na.rm = TRUE))
  for (plot in plots) {
    built <- ggplot2::ggplot_build(plot)$data[[2]]
    s <- unique(built[, c("PANEL", "xmin", "xmax", "n1", "n2")])
    expect_equal(nrow(s), 4L)
    expect_equal(s$n1, rep(5L, 4))
    expect_equal(s$n2, rep(5L, 4))
  }
  q <- fmt_com(p, group.by = "x.var", method = "t_test", na.rm = TRUE,
               method.args = list(paired = TRUE, id = "subject"), label.y = c(20, 30))
  built <- ggplot2::ggplot_build(q)
  expect_identical(built$layout$layout, ggplot2::ggplot_build(p)$layout$layout)
  s <- unique(built$data[[2]][, c("PANEL", "xmin", "xmax", "n1", "n2", "p")])
  expected <- signif(stats::t.test(2:5, c(4, 4, 7, 7), paired = TRUE)$p.value, 3)
  expect_equal(nrow(s), 4L)
  expect_equal(s$n1, rep(4L, 4))
  expect_equal(s$n2, rep(4L, 4))
  expect_equal(s$p, rep(expected, 4))
  expect_identical(p$data, d)
})

test_that("missing panel pairs are skipped and retained scale gaps stay aligned", {
  p <- com_plot(subset(iris, Species != "versicolor")) +
    ggplot2::scale_x_discrete(drop = FALSE)
  s <- com_stat(fmt_com(p))
  expect_equal(as.numeric(s$xmin), 1)
  expect_equal(as.numeric(s$xmax), 3)
  d <- rbind(transform(subset(iris, Species != "setosa"), panel = "A"),
             transform(subset(iris, Species != "versicolor"), panel = "B"))
  q <- com_plot(d) + ggplot2::facet_wrap(~panel)
  s <- com_stat(fmt_com(q, com_method = list(c("setosa", "virginica"))))
  expect_equal(nrow(s), 1L)
  expect_equal(as.character(s$PANEL), "2")

  d <- subset(transform(ToothGrowth, dose = factor(dose)), dose != "1")
  p <- ggplot2::ggplot(d, ggplot2::aes(dose, len, fill = supp)) +
    ggplot2::geom_boxplot() + ggplot2::scale_x_discrete(drop = FALSE)
  s <- com_stat(fmt_com(p, group.by = "x.var", method = "t_test"))
  expect_equal(as.numeric(s$xmin), c(.8, 2.8))
  expect_equal(as.numeric(s$xmax), c(1.2, 3.2))
  s <- com_stat(fmt_com(p, group.by = "legend.var", method = "t_test"))
  expect_equal(sort(as.numeric(s$xmin)), c(.8, 1.2))
  expect_equal(sort(as.numeric(s$xmax)), c(2.8, 3.2))
})

test_that("reference groups control the comparison family", {
  p <- com_plot()
  s <- com_stat(fmt_com(p, ref.group = 1))
  expect_equal(as.numeric(s$xmin), c(1, 1))
  expect_equal(as.numeric(s$xmax), c(2, 3))
  expected <- com_stat(p + ggpubr::geom_pwc(ref.group = "all"))
  actual <- com_stat(fmt_com(p, ref.group = "all"))
  expect_equal(actual$p, expected$p)
  expect_equal(as.numeric(actual$xmin), c(1, 2, 3))
  expect_equal(as.numeric(actual$xmax), c(1, 2, 3))
  d <- transform(ToothGrowth, dose = factor(dose))
  grouped <- ggplot2::ggplot(d, ggplot2::aes(supp, len, fill = dose)) +
    ggplot2::geom_boxplot()
  s <- com_stat(fmt_com(grouped, group.by = "x.var", ref.group = "0.5"))
  expect_equal(nrow(s), 4L)
  expect_error(fmt_com(p, ref.group = 1, com_method = list(c("setosa", "versicolor"))),
               "ref.group")
})

test_that("numeric reference ranks must select observed displayed groups", {
  p <- com_plot()
  for (rank in c(4, 2^31)) expect_error(fmt_com(p, ref.group = rank), "ref.group.*rank")
  expect_error(fmt_com(p, ref.group = matrix(1)), "ref.group")
  shifted <- p + ggplot2::scale_x_discrete(limits = c("missing", levels(iris$Species)))
  expect_error(fmt_com(shifted, ref.group = 1), "ref.group.*rank")
  expect_equal(com_stat(fmt_com(shifted, ref.group = 4)),
               com_stat(fmt_com(shifted, ref.group = "virginica")))
  sparse <- com_plot(subset(iris, Species != "versicolor")) +
    ggplot2::scale_x_discrete(drop = FALSE)
  expect_error(fmt_com(sparse, ref.group = 2), "ref.group.*rank")
  expect_equal(com_stat(fmt_com(sparse, ref.group = 3)),
               com_stat(fmt_com(sparse, ref.group = "virginica")))
  source <- subset(iris, Species != "versicolor")
  expect_error(fmt_com(p, data = source, ref.group = 2), "ref.group.*rank")
  expect_equal(com_stat(fmt_com(p, data = source, ref.group = 3)),
               com_stat(fmt_com(p, data = source, ref.group = "virginica")))
  missing <- iris
  missing$Sepal.Length[missing$Species == "versicolor"] <- NA_real_
  points <- ggplot2::ggplot(missing, ggplot2::aes(Species, Sepal.Length)) +
    ggplot2::geom_point()
  expect_error(fmt_com(points, ref.group = 2), "ref.group.*rank")
  explicit <- fmt_com(ggplot2::ggplot(), data = iris,
                       mapping = ggplot2::aes(Species, Sepal.Length), ref.group = 2)
  expect_equal(com_stat(explicit), com_stat(fmt_com(p, ref.group = 2)))

  d <- transform(ToothGrowth, dose = factor(dose))
  d$len[d$dose == "1"] <- NA_real_
  grouped <- ggplot2::ggplot(d, ggplot2::aes(supp, len, fill = dose)) +
    ggplot2::geom_point()
  expect_error(fmt_com(grouped, group.by = "x.var", ref.group = 2), "ref.group.*rank")
  expect_error(fmt_com(grouped, group.by = "x.var", ref.group = 4), "ref.group.*rank")
})

test_that("numeric reference ranks retain panel-local free-axis ordering", {
  d <- rbind(transform(subset(iris, Species != "setosa"), panel = "A"),
               transform(subset(iris, Species != "versicolor"), panel = "B"))
  p <- com_plot(d) + ggplot2::facet_wrap(~panel, scales = "free_x")
  expect_equal(com_stat(fmt_com(p, ref.group = 2)),
               com_stat(fmt_com(p, ref.group = "virginica")))
  expect_error(fmt_com(p, ref.group = 3), "ref.group.*rank")
  d <- rbind(transform(iris, panel = "A"),
               transform(subset(iris, Species != "versicolor"), panel = "B"))
  p <- com_plot(d) + ggplot2::facet_wrap(~panel, scales = "free_x")
  actual <- com_stat(fmt_com(p, ref.group = 3))
  expect_equal(nrow(actual), 2L)
  expect_equal(as.character(actual$PANEL), rep("1", 2))
})

test_that("numeric reference layout vectors retain unobserved scale positions", {
  d <- data.frame(x = rep(LETTERS[1:4], each = 6),
                  y = c(1, 2, 3, 4, 5, 6, 2, 3, 5, 7, 9, 10,
                        3, 4, 5, 8, 10, 12, 4, 6, 8, 10, 13, 15))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  source <- d[d$x != "B", ]
  q <- fmt_com(p, data = source, ref.group = 3, method = "t_test",
               label.y = c(20, 30), tip.length = c(.01, .02))
  built <- ggplot2::ggplot_build(q)$data[[2]]
  expect_equal(nrow(built), 6L)
  if (nrow(built)) {
    horizontal <- unique(built[built$y == built$yend, c("group1", "group2", "y")])
    expect_equal(horizontal$y, c(20, 30))
    expected <- com_stat(fmt_com(p, data = source, ref.group = "C", method = "t_test"))
    expect_equal(com_stat(q), expected)
    expected_p <- vapply(c("A", "D"), function(group) {
      signif(stats::t.test(source$y[source$x == "C"], source$y[source$x == group])$p.value, 3)
    }, numeric(1))
    # Match the backend's reported precision after the independent tests.
    expect_equal(com_stat(q)$p, rstatix::p_round(unname(expected_p)))
    expect_equal(as.numeric(expected$xmin), rep(3, 2))
    expect_equal(as.numeric(expected$xmax), c(1, 4))
    expect_equal(built$yend[1:2] - built$y[1:2], c(.14, .28))
  }
  expect_identical(p$data, d)
})

test_that("numeric reference layout vectors follow unique free-panel pairs", {
  d <- rbind(transform(subset(iris, Species != "setosa"), panel = "A"),
               transform(subset(iris, Species != "versicolor"), panel = "B"))
  p <- com_plot(d) + ggplot2::facet_wrap(~panel, scales = "free_x")
  q <- fmt_com(p, ref.group = 2, method = "t_test", label.y = c(8, 9))
  built <- ggplot2::ggplot_build(q)$data[[2]]
  expect_equal(nrow(built), 6L)
  horizontal <- unique(built[built$y == built$yend, c("PANEL", "y")])
  expect_equal(horizontal$y, c(8, 9))
  expect_equal(com_stat(q), com_stat(fmt_com(p, ref.group = "virginica", method = "t_test")))
  expected_p <- vapply(c("versicolor", "setosa"), function(group) {
    signif(stats::t.test(iris$Sepal.Length[iris$Species == "virginica"],
                        iris$Sepal.Length[iris$Species == group])$p.value, 3)
  }, numeric(1))
  expect_equal(com_stat(q)$p, unname(expected_p))

  repeated <- rbind(d, transform(subset(d, panel == "A"), panel = "C"))
  p <- com_plot(repeated[rev(seq_len(nrow(repeated))), ]) +
    ggplot2::facet_wrap(~panel, scales = "free_x")
  q <- fmt_com(p, ref.group = 2, label.y = c(8, 9))
  built <- ggplot2::ggplot_build(q)$data[[2]]
  expect_equal(nrow(built), 9L)
  horizontal <- unique(built[built$y == built$yend, c("PANEL", "y")])
  expect_equal(horizontal$y, c(8, 9, 8))

  grouped <- rbind(transform(d, g = "G1"), transform(d, g = "G2"))
  p <- ggplot2::ggplot(grouped, ggplot2::aes(Species, Sepal.Length, fill = g)) +
    ggplot2::geom_boxplot() + ggplot2::facet_wrap(~panel, scales = "free_x")
  q <- fmt_com(p, group.by = "legend.var", ref.group = 2, label.y = c(8, 9, 10, 11))
  built <- ggplot2::ggplot_build(q)$data[[2]]
  expect_equal(nrow(built), 12L)
  horizontal <- unique(built[built$y == built$yend, c("PANEL", "xmin", "y")])
  expect_equal(horizontal$y, c(8, 10, 9, 11))
  expect_identical(p$data, grouped)
})

test_that("mixed subgroup sizes retain adjusted values and labels", {
  set.seed(201)
  d <- data.frame(x = c(rep("A", 30), rep("B", 20)),
                  g = c(rep(c("G1", "G2", "G3"), each = 10), rep(c("G1", "G2"), each = 10)),
                  y = rnorm(50) + c(rep(c(0, 1, 2), each = 10), rep(c(0, 1), each = 10)))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) + ggplot2::geom_boxplot()
  s <- com_stat(fmt_com(p, group.by = "x.var", label = "p.adj.signif"))
  expect_equal(is.na(s$p.adj), rep(FALSE, 3L))
  expect_equal(s$p.adj[as.numeric(s$xmin) > 1.5], s$p[as.numeric(s$xmin) > 1.5])
  expect_equal(s$label[as.numeric(s$xmin) > 1.5], "*")
  panel <- com_stat(fmt_com(p, group.by = "x.var", p.adjust.by = "panel",
                            p.adjust.method = "bonferroni"))
  expect_equal(panel$p.adj, stats::p.adjust(panel$p, "bonferroni"))
})

test_that("sparse legend subsets use their observed factor levels", {
  d <- subset(ToothGrowth, !(supp == "VC" & dose == .5))
  d$dose <- factor(d$dose)
  p <- ggplot2::ggplot(d, ggplot2::aes(dose, len, fill = supp)) +
    ggplot2::geom_boxplot(position = ggplot2::position_dodge(.8))
  s <- com_stat(fmt_com(p, group.by = "legend.var"))
  expect_equal(nrow(s), 3L)
  expected <- stats::wilcox.test(len ~ dose, data = droplevels(subset(d, supp == "VC")), exact = FALSE)$p.value
  expect_equal(s$p[as.numeric(s$xmin) > 2], signif(expected, 3), tolerance = .01)
  expect_equal(sort(as.numeric(s$xmin)), c(1, 1.8, 2.2))
  expect_equal(sort(as.numeric(s$xmax)), c(1.8, 2.8, 3.2))
})

test_that("paired tests retain row alignment and support explicit subject IDs", {
  d <- data.frame(id = rep(1:5, 2), x = rep(c("A", "B"), each = 5),
                  y = c(1, 2, 4, 8, NA, NA, 5, 5, 9, 16))
  p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) + ggplot2::geom_point()
  expected <- stats::t.test(c(2, 4, 8), c(5, 5, 9), paired = TRUE)$p.value
  s <- suppressWarnings(com_stat(fmt_com(p, method = "t_test", method.args = list(paired = TRUE))))
  expect_equal(s$p, signif(expected, 3))
  reordered <- d[c(1:5, 10:6), ]
  p <- ggplot2::ggplot(reordered, ggplot2::aes(x, y)) + ggplot2::geom_point()
  s <- suppressWarnings(com_stat(fmt_com(p, method = "t_test", method.args = list(paired = TRUE, id = "id"))))
  expect_equal(s$p, signif(expected, 3))
  expect_identical(p$data, reordered)
  expect_error(fmt_com(p, method.args = list(paired = TRUE, id = "missing")), "id")
  unbalanced <- p
  unbalanced$data <- reordered[-1, ]
  expect_error(fmt_com(unbalanced, method.args = list(paired = TRUE)), "id")
  faceted <- rbind(transform(d, panel = "one"), transform(d, panel = "two", y = y + 2))
  p <- ggplot2::ggplot(faceted, ggplot2::aes("all", y, fill = x)) +
    ggplot2::geom_boxplot() + ggplot2::facet_wrap(~panel)
  s <- suppressWarnings(com_stat(fmt_com(p, group.by = "x.var", method = "t_test",
                                         method.args = list(paired = TRUE, id = "id"))))
  expect_equal(s$p, rep(signif(expected, 3), 2L))
  faceted$id[2] <- faceted$id[1]
  p$data <- faceted
  expect_error(fmt_com(p, group.by = "x.var", method.args = list(paired = TRUE, id = "id")), "unique")
})

test_that("one-sided custom comparisons preserve requested direction", {
  p <- com_plot()
  pair <- list(c("virginica", "setosa"))
  args <- list(alternative = "greater")
  expected <- stats::t.test(iris$Sepal.Length[iris$Species == "virginica"],
                            iris$Sepal.Length[iris$Species == "setosa"], alternative = "greater")$p.value
  s <- com_stat(fmt_com(p, method = "t_test", com_method = pair, method.args = args))
  expect_equal(s$p, signif(expected, 3))
  q <- p + ggplot2::scale_x_discrete(limits = c("virginica", "versicolor", "setosa"))
  expect_equal(com_stat(fmt_com(q, method = "t_test", com_method = pair, method.args = args))$p, s$p)
  expect_equal(com_stat(fmt_com(p, method = "t_test", com_method = pair,
                               method.args = list(alternative = "less")))$p, 1)
  all <- com_stat(fmt_com(p, method = "t_test", com_method = "all", method.args = args))
  reversed <- com_stat(fmt_com(q, method = "t_test", com_method = "all", method.args = args))
  expect_equal(sort(reversed$p), sort(all$p))
})

test_that("layout vectors match comparisons and remain aligned after facet filtering", {
  p <- com_plot()
  expect_error(fmt_com(p, com_method = "all", label.y = c(8, 9)), "label.y")
  expect_error(fmt_com(p, com_method = "all", step.increase = c(.01, .02)), "step.increase")
  q <- fmt_com(p, com_method = "all", label.y = c(8, 9, 10), tip.length = c(.01, .02, .03))
  b <- ggplot2::ggplot_build(q)$data[[2]]
  expect_equal(b$yend[1:3] - b$y[1:3], c(.036, .072, .108))
  expect_equal(b$y[7:9] - b$yend[7:9], c(.036, .072, .108))
  d <- rbind(transform(subset(iris, Species != "setosa"), panel = "A"),
             transform(subset(iris, Species != "versicolor"), panel = "B"))
  p <- com_plot(d) + ggplot2::facet_wrap(~panel)
  pairs <- list(c("setosa", "versicolor"), c("setosa", "virginica"), c("versicolor", "virginica"))
  y <- com_y(fmt_com(p, com_method = pairs, label.y = c(8, 9, 10)))
  expect_equal(y$y, c(10, 9))
  expect_error(fmt_com(com_plot() + ggplot2::scale_y_log10(), label.y = -1), "label.y")
  q <- fmt_com(com_plot(), com_method = "all", label.y = c(8, 9, 10),
               tip.length = c(.01, .02, .03, .04, .05, .06))
  b <- ggplot2::ggplot_build(q)$data[[2]]
  expect_equal(b$yend[1:3] - b$y[1:3], c(.036, .108, .18))
  expect_equal(b$y[7:9] - b$yend[7:9], c(.072, .144, .216))
  d <- transform(ToothGrowth, dose = factor(dose))
  grouped <- ggplot2::ggplot(d, ggplot2::aes(dose, len, fill = supp)) + ggplot2::geom_boxplot()
  expect_equal(com_y(fmt_com(grouped, group.by = "x.var", label.y = c(40, 50, 60)))$y, c(40, 50, 60))
  pairs <- list(c("versicolor", "virginica"), c("setosa", "virginica"))
  expect_equal(com_y(fmt_com(com_plot(), method = "dunn_test", com_method = pairs, label.y = c(8, 9)))$y, c(9, 8))
})

test_that("extracted plots do not retain unrelated container data", {
  p <- evalq(ggplot2::ggplot(iris, ggplot2::aes(Species, Sepal.Length)) +
               ggplot2::geom_boxplot(), envir = .GlobalEnv)
  large <- p
  large$data <- iris[rep(seq_len(nrow(iris)), 200), ]
  single <- fmt_com(p)
  extracted <- fmt_com(list(p, large))[[1]]
  expect_lt(length(serialize(extracted, NULL)), 1.1 * length(serialize(single, NULL)))
  expect_equal(com_stat(extracted), com_stat(single))
  expect_identical(p$data, iris)
})
