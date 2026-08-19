test_that("pal_show_brewer displays selected Brewer palettes", {
  p <- pal_show_brewer(
    palette = c("Set1", "Blues"),
    n = 5,
    output = "gg"
  )

  expect_s3_class(p, "ggplot")
  expect_identical(
    as.character(p$data$palette),
    c(rep("Set1", 5), rep("Blues", 5))
  )
  expect_identical(
    p$data$color[seq_len(5)],
    RColorBrewer::brewer.pal(5, "Set1")
  )
})

test_that("pal_show_hcl displays selected HCL palettes", {
  p <- pal_show_hcl(
    palette = c("Dark 3", "Viridis"),
    n = 5,
    output = "gg"
  )

  expect_s3_class(p, "ggplot")
  expect_identical(
    as.character(p$data$palette),
    c(rep("Dark 3", 5), rep("Viridis", 5))
  )
  expect_identical(
    p$data$color[seq_len(5)],
    grDevices::hcl.colors(5, "Dark 3")
  )
})

test_that("pal_show_hcl displays all HCL palettes by default", {
  p <- pal_show_hcl(output = "gg")

  expect_s3_class(p, "ggplot")
  expect_setequal(
    unique(as.character(p$data$palette)),
    grDevices::hcl.pals()
  )
})

test_that("pal_show_viridis displays selected viridis palettes", {
  p <- pal_show_viridis(
    palette = c("viridis", "plasma"),
    n = 5,
    output = "gg"
  )

  expect_s3_class(p, "ggplot")
  expect_identical(
    as.character(p$data$palette),
    c(rep("viridis", 5), rep("plasma", 5))
  )
  expect_identical(
    p$data$color[seq_len(5)],
    scales::viridis_pal(option = "viridis")(5)
  )
})

test_that("pal_show_ggsci displays selected ggsci palettes", {
  skip_if_not_installed("ggsci")

  p <- pal_show_ggsci(
    palette = c("ggsci_npg_nrc", "ggsci_aaas_default"),
    n = 5,
    output = "gg"
  )

  expect_s3_class(p, "ggplot")
  expect_identical(
    as.character(p$data$palette),
    c(rep("ggsci_npg_nrc", 5), rep("ggsci_aaas_default", 5))
  )
  expect_identical(
    p$data$color[seq_len(5)],
    substr(ggsci::pal_npg("nrc")(5), 1, 7)
  )
})

test_that("pal_show gives Colours a wider fixed column", {
  skip_if_not_installed("gt")

  invisible(capture.output(tbl <- pal_show("Set1", output = "gt")))
  html <- gt::as_raw_html(tbl)

  expect_match(html, "width:420px")
})

test_that("pal_show doubles the Colours swatch width", {
  skip_if_not_installed("gt")

  invisible(capture.output(tbl <- pal_show("Set1", output = "gt")))
  html <- gt::as_raw_html(tbl)

  expect_match(html, "padding:0 6px;")
})

test_that("pal_show displays palettes in the console", {
  output <- capture.output(
    pal_show("Set1", max_colors = 3, output = "console")
  )

  expect_match(paste(output, collapse = "\n"),
               "=== Set1 \\(3 colours, discrete\\) ===")
})

test_that("pal_show displays colour vectors in the console", {
  output <- capture.output(
    pal_show(c("#FF0000", "#00FF00"), output = "console")
  )

  expect_match(paste(output, collapse = "\n"), "#FF0000")
})

test_that("show_color prints an R expression for the displayed colours", {
  output <- capture.output(
    show_color(c("#FF0000", "#00FF00"))
  )

  expect_match(
    paste(output, collapse = "\n"),
    'c\\("#FF0000", "#00FF00"\\)'
  )
})

test_that("palette source wrappers support console output", {
  brewer_output <- capture.output(
    pal_show_brewer("Set1", n = 3, output = "console")
  )
  hcl_output <- capture.output(
    pal_show_hcl("Dark 3", n = 3, output = "console")
  )
  skip_if_not_installed("ggsci")
  ggsci_output <- capture.output(
    pal_show_ggsci("ggsci_npg_nrc", n = 3, output = "console")
  )
  viridis_output <- capture.output(
    pal_show_viridis("viridis", n = 3, output = "console")
  )

  expect_match(paste(brewer_output, collapse = "\n"), "=== Set1")
  expect_match(paste(hcl_output, collapse = "\n"), "=== Dark 3")
  expect_match(paste(ggsci_output, collapse = "\n"), "=== ggsci_npg_nrc")
  expect_match(paste(viridis_output, collapse = "\n"), "=== viridis")
})
