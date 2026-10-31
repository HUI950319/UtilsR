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

  # a section rule per palette, no "===" banner
  rule <- strrep(cli::symbol$line, 2)
  expect_true(any(startsWith(output,
                             paste(rule, "Set1 (3 / 9 colours, discrete) "))))
  expect_false(any(grepl("===", output, fixed = TRUE)))
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
  expect_true(any(startsWith(output,
                             paste(strrep(cli::symbol$line, 2), "2 colours "))))
})

test_that("show_color follows the terminal's colour depth", {
  op <- options(cli.num_colors = 16777216)
  on.exit(options(op), add = TRUE)
  true_col <- capture.output(show_color("#2166AC"))

  options(cli.num_colors = 256)
  paletted <- capture.output(show_color("#2166AC"))

  # 24-bit terminals get the exact RGB triple, not a palette index
  expect_match(paste(true_col, collapse = ""), "48;2;33;102;172", fixed = TRUE)
  # 256-colour terminals keep the indexed escape they always had
  expect_match(paste(paletted, collapse = ""), "48;5;", fixed = TRUE)
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

  rule <- strrep(cli::symbol$line, 2)
  expect_true(any(startsWith(brewer_output, paste(rule, "Set1 ("))))
  expect_true(any(startsWith(hcl_output, paste(rule, "Dark 3 ("))))
  expect_true(any(startsWith(ggsci_output, paste(rule, "ggsci_npg_nrc ("))))
  expect_true(any(startsWith(viridis_output, paste(rule, "viridis ("))))
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
  # `x` maps level by level
  expect_identical(pal_get(cols, x = c("a", "b", "c")),
                   stats::setNames(cols, c("a", "b", "c")))

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

test_that("pal_get keeps transparency when it interpolates", {
  expect_identical(pal_get("#FF000080", n = 2), rep("#FF000080", 2))
  expect_identical(pal_get(c("#FF000080", "#0000FF80"), n = 3),
                   c("#FF000080", "#7F007F80", "#0000FF80"))
  expect_identical(unname(pal_get("#FF000080", x = c("a", "b", "c"))), rep("#FF000080", 3))

  # Opaque colours stay six digits, and `alpha` still overrides.
  expect_identical(pal_get("red", n = 2), rep("#FF0000", 2))
  expect_identical(nchar(pal_get("lancet", n = 20)), rep(7L, 20))
  expect_identical(pal_get("#FF000080", n = 2, alpha = 0.25), rep("#FF000040", 2))
})

test_that("pal_get takes NULL for the plot functions' default colours", {
  expect_identical(pal_get(NULL), as.character(pal_lancet))
  expect_identical(pal_get(NULL, n = 3), as.character(pal_lancet)[1:3])
  expect_identical(pal_get(NULL, n = 20), pal_get("lancet", n = 20))
  # Leaving the argument out keeps its own default.
  expect_identical(pal_get(n = 2), pal_get("Paired", n = 2))
})

test_that("pal_get accepts every colour R can draw", {
  expect_identical(pal_get("#F00"), "#F00")
  expect_identical(pal_get("transparent"), "transparent")
  expect_identical(pal_get("light blue", n = 2), rep("#ADD8E6", 2))
  expect_identical(pal_get(c("transparent", "#F00")), c("transparent", "#F00"))

  # Not a colour: a string of digits would be a position in palette().
  for (bad in c("2", "", "notacolor", NA_character_)) {
    expect_error(pal_get(bad), "not found")
  }
  expect_error(pal_get(c("red", "2")), "Not a colour")
})

test_that("pal_get explains an unknown name in one error", {
  expect_error(pal_get("lanct"), "Did you mean.*lancet")
  expect_error(pal_get("LANCET"), "Did you mean.*lancet")
  expect_error(pal_get("reds"), "Did you mean.*Reds")
  expect_error(pal_get("kelly"), "pal_other\\$kelly")
  expect_error(pal_get("blue_red"), "pal_heat\\$blue_red")

  # No separate message, and no regular expression behind the search.
  expect_no_message(tryCatch(pal_get("LANCET"), error = function(e) NULL))
  expect_no_warning(tryCatch(pal_get("("), error = function(e) NULL))
  expect_error(pal_get("("), "not found")

  # Nothing to suggest for these.
  for (bad in c("", NA_character_, "zzzzzzzzzz")) {
    msg <- tryCatch(pal_get(bad), error = conditionMessage)
    expect_match(msg, "not found")
    expect_no_match(msg, "Did you mean")
  }
})

test_that("pal_get checks n, reverse and alpha", {
  for (bad in list(2.5, -1, NA, c(1, 2), "2", Inf, TRUE)) {
    expect_error(pal_get("lancet", n = bad), "`n` must be")
  }
  for (bad in list(2, -1, NA, c(0.1, 0.2), "a")) {
    expect_error(pal_get("lancet", n = 2, alpha = bad), "`alpha` must be")
  }
  for (bad in list(NA, "yes", c(TRUE, FALSE))) {
    expect_error(pal_get("lancet", n = 2, reverse = bad), "`reverse` must be")
  }
  # The list form goes through the same checks.
  expect_error(pal_get(pal_heat, n = -1), "`n` must be")

  expect_identical(pal_get("lancet", n = 0), character())
  expect_identical(pal_get("lancet", n = 2L), as.character(pal_lancet)[1:2])
  expect_identical(pal_get("lancet", n = 1, alpha = 0), "#00468B00")
  expect_identical(pal_get("lancet", n = 1, alpha = 1), "#00468BFF")
})

test_that("pal_get names the colours it maps to a discrete x", {
  lancet <- as.character(pal_lancet)
  expect_identical(pal_get("lancet", x = c("A", "B", "C")),
                   stats::setNames(lancet[1:3], c("A", "B", "C")))

  # Order of appearance, factor levels with unused ones, no missing values.
  expect_named(pal_get("lancet", x = c("B", "A", "B")), c("B", "A"))
  expect_named(pal_get("lancet", x = c("A", NA, "B")), c("A", "B"))
  expect_named(pal_get("lancet", x = factor(c("b", NA), levels = c("b", "a", "c"))),
               c("b", "a", "c"))
  expect_named(pal_get("lancet", x = c(TRUE, FALSE)), c("TRUE", "FALSE"))
  expect_named(pal_get("lancet", x = paste0("L", 1:20)), paste0("L", 1:20))

  # Names survive `reverse` and `alpha`, and the list form.
  expect_identical(pal_get("lancet", x = c("A", "B"), reverse = TRUE),
                   stats::setNames(lancet[2:1], c("A", "B")))
  expect_named(pal_get("lancet", x = c("A", "B"), alpha = 0.5), c("A", "B"))
  expect_named(pal_get(pal_heat, x = c("A", "B"))$blue_red, c("A", "B"))

  # Without `x` the colours stay unnamed.
  expect_null(names(pal_get("paraSC", n = 2)))

  # The help page's use: each level gets the colour asked for.
  d <- data.frame(v = 1:2, g = factor(c("A", "B")))
  p <- ggplot2::ggplot(d, ggplot2::aes(v, v, colour = g)) +
    ggplot2::geom_point() +
    ggplot2::scale_colour_manual(values = pal_get(c("#111111", "#222222"), x = c("B", "A")))
  expect_identical(ggplot2::layer_data(p)$colour, c("#222222", "#111111"))
})
