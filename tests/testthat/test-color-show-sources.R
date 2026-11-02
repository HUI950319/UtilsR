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

test_that("pal_get places a numeric x along the palette by value", {
  # Evenly along the palette; `n` alone takes the first colours of a long one.
  three <- grDevices::colorRampPalette(palette_list$viridis)(3)

  # Evenly spaced increasing values return what they did.
  expect_identical(pal_get("viridis", x = c(1, 2, 3)), three)
  expect_identical(pal_get("viridis", x = 1:3), three)

  # The values decide, not the positions.
  expect_identical(pal_get("viridis", x = c(3, 2, 1)), rev(three))
  skewed <- pal_get("viridis", x = c(1, 100, 2))
  expect_identical(skewed[[2L]], three[[3L]])
  expect_false(identical(skewed[[3L]], three[[2L]]))

  # No place, no colour; one value takes the middle.
  expect_identical(pal_get("viridis", x = c(1, NA, 3)), c(three[[1L]], NA, three[[3L]]))
  expect_identical(pal_get("viridis", x = c(1, Inf, 3)), c(three[[1L]], NA, three[[3L]]))
  expect_identical(pal_get("viridis", x = c(5, 5)), rep(three[[2L]], 2))
  expect_identical(pal_get("viridis", x = c(NA_real_, NA_real_)), rep(NA_character_, 2))
  expect_identical(pal_get("viridis", x = numeric(0)), character())

  # `reverse` flips the scale and leaves each element in its place.
  expect_identical(pal_get("viridis", x = c(1, NA, 3), reverse = TRUE),
                   c(three[[3L]], NA, three[[1L]]))
  expect_identical(pal_get("viridis", x = c(1, 2, 3), alpha = 0.5),
                   ggplot2::alpha(three, 0.5))
  expect_identical(pal_get(c("#FF000080", "#0000FF80"), x = c(1, 0)),
                   c("#0000FF80", "#FF000080"))
  expect_null(names(pal_get("viridis", x = c(a = 1, b = 2))))
})

test_that("pal_get interpolates every registered palette as colorRampPalette does", {
  for (nm in names(palette_list)) {
    cols <- palette_list[[nm]]
    k <- length(cols) + 3L
    expect_identical(pal_get(nm, n = k),
                     as.character(grDevices::colorRampPalette(cols)(k)), info = nm)
  }
})

test_that("pal_show preserves transparency in colour-vector previews", {
  cols <- c("#FF000080", "transparent", "#00000010")
  invisible(capture.output(p <- pal_show(cols, output = "gg")))
  layers <- ggplot2::ggplot_build(p)$data
  expect_identical(as.character(layers[[1]]$fill),
                   c("#FF000080", "#FFFFFF00", "#00000010"))
  expect_identical(as.character(layers[[2]]$label),
                   c("#FF000080", "#FFFFFF00", "#00000010"))
  expect_identical(layers[[2]]$colour, rep("#000000", 3L))

  invisible(capture.output(tbl <- pal_show(cols, output = "gt")))
  html <- gt::as_raw_html(tbl)
  expect_match(html, "background:\\s*#FF000080;")
  expect_match(html, "background:\\s*#FFFFFF00;")
  expect_match(html, "background:\\s*#00000010;\\s*color:\\s*#000000;")
})

test_that("palette gt previews normalize R colours for CSS", {
  invisible(capture.output(tbl <- pal_show("GdRd", output = "gt")))
  previews <- tbl[["_data"]][["preview"]]
  expect_match(previews, "background:#FFD700;", fixed = TRUE)
  expect_match(previews, "background:#CD0000;", fixed = TRUE)

  invisible(capture.output(custom <- pal_show(
    list(custom = c("light blue", "#F00", "#00000080")), output = "gt")))
  preview <- custom[["_data"]][["preview"]]
  expect_match(preview, "background:#ADD8E6;", fixed = TRUE)
  expect_match(preview, "background:#FF0000;", fixed = TRUE)
  expect_match(preview, "background:#00000080;", fixed = TRUE)
})

test_that("pal_show returns visible graphics without printing internally", {
  for (output in c("gt", "gg")) {
    printed <- capture.output(value <- withVisible(pal_show("Set1", output = output)))
    expect_identical(printed, character())
    expect_true(value$visible)
    printed <- capture.output(value <- withVisible(pal_show(c("red", "blue"), output = output)))
    expect_identical(printed, character())
    expect_true(value$visible)
  }
  printed <- capture.output(value <- withVisible(pal_show("Set1", output = "console")))
  expect_gt(length(printed), 0L)
  expect_false(value$visible)
})

test_that("pal_show renders gt objects in knitted documents", {
  skip_if_not_installed("knitr")
  for (palette in c('"Set1"', 'c("red", "#00000080")')) {
    markdown <- knitr::knit(text = c(
      "```{r, echo=FALSE}",
      sprintf('UtilsR::pal_show(%s, output = "gt")', palette),
      "```"), quiet = TRUE, envir = new.env(parent = globalenv()))
    expect_no_match(markdown, "## <(div|style)")
    expect_match(markdown, "<table", fixed = TRUE)
  }
})

test_that("pal_get validates every colour in a palette list", {
  for (n in list(NULL, 0, 1, 3)) {
    expect_error(pal_get(list(bad = c("red", "notacolor")), n = n),
                 "bad.*notacolor")
    expect_error(pal_get(list(bad = c("red", "2")), n = n), "bad.*2")
    expect_error(pal_get(list(bad = c("red", NA_character_)), n = n), "bad.*NA")
  }
  expect_error(pal_get(stats::setNames(list("red"), NA_character_)), "named")
  expect_error(pal_get(list(a = "red", a = "blue")), "unique")
  expect_identical(pal_get(list(a = c("transparent", "#F00", "light blue"))),
                   list(a = c("transparent", "#F00", "light blue")))
})

test_that("pal_show checks colour counts and layout sizes", {
  for (arg in c("n", "max_colors", "ncol")) {
    bad_values <- list(0, -1, 1.5, NA_real_, TRUE, "2", c(1, 2), matrix(1))
    if (arg != "max_colors") bad_values <- c(bad_values, list(Inf))
    for (bad in bad_values) {
      args <- c(list(palette = c("red", "blue"), output = "console"),
                stats::setNames(list(bad), arg))
      expect_error(do.call(pal_show, args), paste0("`", arg, "`"))
    }
  }
  for (bad in list(NA, NULL, 1, "yes", c(TRUE, FALSE))) {
    expect_error(pal_show("Set1", label = bad, output = "console"), "`label`")
  }
  for (bad in list(0, -1, NA_real_, Inf, "3", TRUE, c(2, 3))) {
    expect_error(pal_show("Set1", label_size = bad, output = "console"), "`label_size`")
  }
  invisible(capture.output(all <- pal_show("Set1", max_colors = Inf, output = "console")))
  expect_length(all[[1]], 9L)
})

test_that("palette viewers reject invalid indices consistently", {
  viewers <- list(
    function(index) pal_show(c("Set1", "Set2"), index = index, output = "console"),
    function(index) pal_show_brewer("Set1", index = index, output = "console"),
    function(index) pal_show_hcl("Dark 3", index = index, output = "console"),
    function(index) pal_show_viridis("viridis", index = index, output = "console")
  )
  if (requireNamespace("ggsci", quietly = TRUE)) {
    viewers <- c(viewers, list(function(index) pal_show_ggsci("npg_nrc", index = index, output = "console")))
  }
  for (viewer in viewers) {
    for (bad in list(NA_real_, 1.5, c(1, 1), "1", TRUE, integer(), 0, -1, Inf)) {
      expect_error(viewer(bad), "`index`")
    }
  }
  invisible(capture.output(one <- pal_show(c("Set1", "Set2"), index = c(1L, 99L), output = "console")))
  expect_named(one, "Set1")
})

test_that("palette name filters reject missing or ambiguous patterns", {
  viewers <- list(
    function(pattern) pal_list(pattern = pattern, show = FALSE),
    function(pattern) pal_show(pattern = pattern, output = "console"),
    function(pattern) pal_show_brewer(pattern = pattern, output = "console"),
    function(pattern) pal_show_hcl(pattern = pattern, output = "console"),
    function(pattern) pal_show_viridis(pattern = pattern, output = "console")
  )
  if (requireNamespace("ggsci", quietly = TRUE)) {
    viewers <- c(viewers, list(function(pattern) {
      pal_show_ggsci(pattern = pattern, output = "console")
    }))
  }
  for (viewer in viewers) {
    for (bad in list(NA, NA_character_, character(), c("Blues", "Reds"),
                     2, list("Blues"), factor("Blues"), matrix("Blues"), "[")) {
      output <- capture.output(expect_error(viewer(bad), "`pattern`"))
      expect_identical(output, character())
    }
  }
})

test_that("pal_list preserves filtered palettes and invisible results", {
  output <- capture.output(result <- withVisible(
    pal_list(pattern = "^blues$", type = "continuous", show = FALSE)
  ))
  expect_identical(result$value, palette_list["Blues"])
  expect_false(result$visible)
  expect_match(paste(output, collapse = "\n"), "Blues")
  expect_message(empty <- withVisible(pal_list("^__none__$", show = FALSE)),
                 "No palettes matched")
  expect_identical(empty$value, list())
  expect_false(empty$visible)
})


test_that("pal_list validates show before matching or printing", {
  for (pattern in c("^Blues$", "^__none__$")) {
    for (bad in list(NA, NULL, logical(), c(TRUE, FALSE), 1, "TRUE",
                     factor("FALSE"), matrix(TRUE))) {
      output <- capture.output(expect_error(
        pal_list(pattern = pattern, show = bad), "`show`"
      ))
      expect_identical(output, character())
    }
  }
  output <- capture.output(result <- withVisible(pal_list("^Blues$", show = TRUE)))
  expect_identical(result$value, palette_list["Blues"])
  expect_false(result$visible)
  expect_match(paste(output, collapse = "\n"), "#F7FBFF", fixed = TRUE)
})

test_that("gradient palettes are discoverable through continuous filters", {
  wanted <- c("ggsci_gsea_default", paste0("ggsci_material_", c(
    "red", "pink", "purple", "deep-purple", "indigo", "blue", "light-blue",
    "cyan", "teal", "green", "light-green", "lime", "yellow", "amber",
    "orange", "deep-orange", "brown", "grey", "blue-grey"
  )))
  invisible(capture.output(pals <- pal_list(
    pattern = "^ggsci_(gsea|material)_", type = "continuous", show = FALSE
  )))
  expect_named(pals, wanted)
  expect_identical(unname(vapply(pals, attr, character(1), "type")),
                   rep("continuous", 20L))
  invisible(capture.output(shown <- pal_show(
    pattern = "^ggsci_(gsea|material)_", type = "continuous",
    output = "console", max_colors = 1
  )))
  expect_named(shown, wanted)
  if (requireNamespace("ggsci", quietly = TRUE)) {
    invisible(capture.output(source <- pal_show_ggsci(
      pattern = "^ggsci_(gsea|material)_", output = "console", max_colors = 1
    )))
    expect_true(all(vapply(source, function(p) identical(attr(p, "type"),
                                                       "continuous"), logical(1))))
  }
})
