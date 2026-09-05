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

test_that("pal_show sizes the Colours column from the longest palette", {
  skip_if_not_installed("gt")

  # Set1 has 9 colours, Paired has 12; 20px per swatch plus the gt cell padding.
  invisible(capture.output(one <- pal_show("Set1", output = "gt")))
  invisible(capture.output(two <- pal_show(c("Set1", "Paired"), output = "gt")))

  expect_match(gt::as_raw_html(one), "width:190px")
  expect_match(gt::as_raw_html(two), "width:250px")
})

test_that("pal_show sizes the Colours column from the drawn swatches", {
  skip_if_not_installed("gt")

  invisible(capture.output(
    tbl <- pal_show("Paired", max_colors = 6, output = "gt")))

  expect_match(gt::as_raw_html(tbl), "width:130px")
})

test_that("pal_show keeps a fixed Colours swatch width", {
  skip_if_not_installed("gt")

  invisible(capture.output(tbl <- pal_show("Set1", output = "gt")))
  html <- gt::as_raw_html(tbl)

  expect_match(html, "display:inline-block;width:20px;")
})

test_that("pal_show resamples each palette to n colours", {
  # truncation and interpolation both follow pal_get()'s rules
  p3 <- pal_show(c("Set1", "lancet"), n = 3, output = "gg")
  expect_identical(nrow(p3$data), 6L)
  expect_identical(p3$data$color[seq_len(3)], pal_get("Set1", n = 3))

  # Set1 only has 9 colours, so 12 is interpolated
  p12 <- pal_show("Set1", n = 12, output = "gg")
  expect_identical(nrow(p12$data), 12L)
  expect_identical(p12$data$color, pal_get("Set1", n = 12))
})

test_that("pal_show keeps max_colors as a display cap on top of n", {
  skip_if_not_installed("gt")

  invisible(capture.output(
    tbl <- pal_show("Set1", n = 30, max_colors = 6, output = "gt")))
  html <- gt::as_raw_html(tbl)

  # six swatches drawn out of the thirty the resampling produced
  expect_match(html, "width:130px")
  expect_match(html, ">6 / 30</td>")
  # resampling must not lose the registry's palette type
  expect_match(html, ">discrete</td>")
})

test_that("pal_show applies n in colour vector mode too", {
  p <- pal_show(pal_paraSC, n = 4, output = "gg")

  expect_identical(nrow(p$data), 4L)
  expect_identical(p$data$color, unname(pal_paraSC[seq_len(4)]))
  # truncation keeps the names that pal_get() drops, so labels stay meaningful
  expect_identical(p$data$label, names(pal_paraSC)[seq_len(4)])
})

test_that("pal_show displays palettes in the console", {
  output <- capture.output(
    pal_show("Set1", max_colors = 3, output = "console")
  )

  expect_match(paste(output, collapse = "\n"),
               "=== Set1 \\(3 / 9 colours, discrete\\) ===")
})

test_that("pal_show reports drawn and available colours when it truncates", {
  skip_if_not_installed("gt")

  # pals_polychrome36 holds 36 colours, max_colors draws 20 of them
  invisible(capture.output(cut <- pal_show(pattern = "polychrome", output = "gt")))
  invisible(capture.output(whole <- pal_show("Set1", output = "gt")))

  expect_match(gt::as_raw_html(cut), ">20 / 36</td>")
  # an untruncated palette keeps the plain count
  expect_match(gt::as_raw_html(whole), ">9</td>")
})

test_that("pal_show rejects an index that selects nothing", {
  expect_error(pal_show(pattern = "^Set", index = 50), "index")
  expect_error(pal_show(pattern = "^Set", index = 50, output = "gg"), "index")
  expect_error(pal_show(pattern = "^Set", index = 50, output = "console"), "index")
})

test_that("pal_show warns about palette names it does not know", {
  invisible(capture.output(
    expect_warning(pal_show(c("Set1", "Blus"), output = "gt"), "Blus")))
  # nothing usable left is still an error
  expect_error(pal_show("Blus"), "No matching palettes")
})

test_that("pal_show lays colour vectors out on one row unless told otherwise", {
  invisible(capture.output(
    auto <- pal_show(grDevices::rainbow(30), output = "gg")))
  invisible(capture.output(
    wrapped <- pal_show(grDevices::rainbow(30), ncol = 5, output = "gg")))

  expect_length(unique(auto$data$row_idx), 1L)
  expect_length(unique(wrapped$data$row_idx), 4L)
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

test_that("pal_heat holds eleven five-colour diverging gradients", {
  expect_length(pal_heat, 11L)
  expect_true(all(vapply(pal_heat, length, integer(1)) == 5L))
  expect_true(all(grepl("^#[0-9a-fA-F]{6}$", unlist(pal_heat))))
  # every gradient turns over at white
  expect_true(all(vapply(pal_heat, function(p) p[3], character(1)) == "#ffffff"))

  # blue_red is RdBu at 7 classes, reversed, with white for its grey midpoint
  rdbu <- tolower(RColorBrewer::brewer.pal(7, "RdBu"))
  expect_identical(pal_heat$blue_red,
                   c(rdbu[7], rdbu[6], "#ffffff", rdbu[2], rdbu[1]))
})

test_that("pal_get takes a colour vector as well as a registered name", {
  cols <- c("#2166ac", "#ffffff", "#b2182b")

  expect_identical(pal_get(cols), cols)
  expect_length(pal_get(cols, n = 7), 7L)
  # interpolation keeps the two ends (colorRampPalette upper-cases its hex)
  expect_identical(tolower(pal_get(cols, n = 7)[c(1, 7)]), cols[c(1, 3)])
  expect_identical(pal_get(cols, reverse = TRUE), rev(cols))
  # `x` maps level by level (the names are dropped on the way out, as they
  # already are for a registered palette)
  expect_identical(pal_get(cols, x = c("a", "b", "c")), cols)

  # a single literal colour is taken as such, a typo still is not
  expect_identical(pal_get("red"), "red")
  expect_identical(pal_get("#FF0000"), "#FF0000")
  expect_error(pal_get("Blus"), "not found")
  # names that are not colours are rejected rather than passed to the ramp
  expect_error(pal_get(c("Paired", "Blues")), "colour")

  # the registry path is untouched
  expect_length(pal_get("Paired", n = 5), 5L)
})

test_that("pal_get maps over a list of palettes", {
  out <- pal_get(pal_heat, n = 3)

  expect_type(out, "list")
  expect_named(out, names(pal_heat))
  expect_true(all(vapply(out, length, integer(1)) == 3L))
  expect_identical(out$blue_red, pal_get(pal_heat$blue_red, n = 3))
  expect_identical(pal_get(pal_heat)$purple_teal, pal_heat$purple_teal)

  expect_error(pal_get(list(c("#000000", "#ffffff"))), "named")
  expect_error(pal_get(list(a = 1:3)), "character")
})
