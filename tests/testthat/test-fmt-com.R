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
