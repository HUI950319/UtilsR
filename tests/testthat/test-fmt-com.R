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
