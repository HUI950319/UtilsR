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

test_that("pal_get rejects all numeric-string palette indices", {
  indices <- c("2", "02", "2.0", "2e0", "2.5", "1e+0")
  for (n in list(NULL, 0, 1, 3)) {
    for (s in indices) {
      expect_error(pal_get(s, n = n), "not found", info = s)
      expect_error(pal_get(c("red", s), n = n), "Not a colour", info = s)
      expect_error(pal_get(list(custom = c("red", s)), n = n),
                   "custom.*invalid colour", info = s)
    }
  }
  expect_identical(pal_get(c("#F00", "light blue", "transparent")),
                   c("#F00", "light blue", "transparent"))
})

test_that("pal_get maps extreme finite numeric ranges without overflow", {
  cols <- c("black", "white")
  expected <- c("#000000", "#7F7F7F", "#FFFFFF")
  for (limit in c(1e308, .Machine$double.xmax)) {
    x <- c(-limit, 0, limit)
    expect_identical(pal_get(cols, x = x), expected)
    expect_identical(pal_get(cols, x = x, reverse = TRUE), rev(expected))
    expect_identical(pal_get(cols, x = c(limit, NA, -limit, Inf)),
                     c("#FFFFFF", NA, "#000000", NA))
    expect_identical(pal_get(list(custom = cols), x = x, alpha = 0.5),
                     list(custom = c("#00000080", "#7F7F7F80", "#FFFFFF80")))
  }
  expect_identical(pal_get(cols, x = c(0, 5e-324, 1e-323)), expected)
})

test_that("pal_get preserves labelled numeric missing values", {
  skip_if_not_installed("haven")
  x <- haven::labelled_spss(c(1, 2, 90, 95, 99, NA),
                            na_values = 99, na_range = c(90, 95))
  expected <- c("#000000", "#FFFFFF", rep(NA_character_, 4))
  expect_identical(pal_get(c("black", "white"), x = x), expected)
  expect_identical(pal_get(list(custom = c("black", "white")), x = x),
                   list(custom = expected))
  tagged <- haven::labelled(c(1, haven::tagged_na("a"), 2),
                            labels = c(no = 1, yes = 2))
  expect_identical(pal_get(c("black", "white"), x = tagged),
                   c("#000000", NA, "#FFFFFF"))
  expect_identical(pal_get("red", x = haven::labelled_spss(c(99, NA), na_values = 99)),
                   c(NA_character_, NA_character_))
})

test_that("pal_get rejects integer64 mapping before double conversion", {
  # A stored object must be rejected even before bit64 registers its methods.
  stored <- structure(c(0, 0), class = "integer64")
  expect_error(pal_get("viridis", x = stored), "integer64")
  expect_error(pal_get(list(custom = c("black", "white")), x = stored), "integer64")
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(c("9007199254740992", "9007199254740993", NA))
  expect_error(pal_get("viridis", x = x), "integer64")
})

test_that("pal_get handles stored labelled and integer64 inputs in a fresh process", {
  skip_if_not_installed("haven")
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  fn <- pal_get
  apply <- .pal_apply
  env <- new.env(parent = asNamespace("stats"))
  environment(fn) <- env
  environment(apply) <- env
  env$.pal_apply <- apply
  saveRDS(list(fn = fn, libs = .libPaths(),
               x = haven::labelled_spss(c(1, 2, 99, NA), na_values = 99),
               integer64 = structure(c(0, 0), class = "integer64")), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)",
    "fixture <- readRDS(args[[1]])",
    ".libPaths(fixture[['libs']])",
    "stopifnot(!'haven' %in% loadedNamespaces(), !'bit64' %in% loadedNamespaces())",
    "before <- fixture[['x']]",
    "out <- fixture[['fn']](c('black', 'white'), x = before)",
    "integer64 <- tryCatch(fixture[['fn']]('red', x = fixture[['integer64']]), error = conditionMessage)",
    "saveRDS(list(out = out, unchanged = identical(before, fixture[['x']]), integer64 = integer64), args[[2]])"
  ), script)
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script), shQuote(fixture), shQuote(output)),
    stdout = TRUE, stderr = TRUE)
  expect_null(attr(status, "status"), info = paste(status, collapse = "\n"))
  if (is.null(attr(status, "status"))) {
    out <- readRDS(output)
    expect_identical(out$out, c("#000000", "#FFFFFF", NA, NA))
    expect_true(out$unchanged)
    expect_match(out$integer64, "integer64")
  }
})

test_that("pal_get excludes explicit missing factor levels", {
  x <- factor(c("b", NA, "a"), levels = c("b", "a", "unused", NA), exclude = NULL)
  expected <- c(b = "#00468BFF", a = "#ED0000FF", unused = "#42B540FF")
  before <- x
  expect_identical(pal_get("lancet", x = x), expected)
  expect_identical(pal_get("lancet", x = x, reverse = TRUE),
                   stats::setNames(rev(unname(expected)), names(expected)))
  expect_identical(pal_get(list(custom = pal_lancet), x = x), list(custom = expected))
  only_missing <- factor(NA, levels = NA_character_, exclude = NULL)
  expect_length(pal_get("lancet", x = only_missing), 0L)
  expect_identical(x, before)
  literal_na <- factor(c("NA", NA), levels = c("NA", NA), exclude = NULL)
  expect_named(pal_get("lancet", x = literal_na), "NA")
})

test_that("pal_get validates long colour vectors without changing diagnostics", {
  cols <- rep(c("ReD", "light blue", "#F00", "#00F8", "transparent"), 200L)
  expect_identical(pal_get(cols, n = 3), c("ReD", "light blue", "#F00"))
  expect_identical(pal_get(list(custom = cols), n = 3),
                   list(custom = c("ReD", "light blue", "#F00")))
  cols[c(2L, 1000L)] <- c("badfirst", "badlast")
  for (palette in list(cols, list(custom = cols))) {
    error <- tryCatch(pal_get(palette, n = 1), error = identity)
    expect_s3_class(error, "error")
    expect_match(conditionMessage(error), "badfirst")
    expect_match(conditionMessage(error), "badlast")
  }
})

test_that("pal_get accepts only plain scalar control values", {
  for (bad in list(matrix(2), array(2, c(1, 1, 1)), structure(2, class = "AsIs"),
                   structure(2, class = "integer64"), .Machine$integer.max + 1, 1e100)) {
    expect_error(pal_get("red", n = bad, x = "A"), "`n` must be")
  }
  for (bad in list(matrix(0.5), structure(0.5, class = "AsIs"),
                   structure(0.5, class = "integer64"))) {
    expect_error(pal_get("red", alpha = bad), "`alpha` must be")
  }
  for (bad in list(matrix(TRUE), structure(TRUE, class = "AsIs"))) {
    expect_error(pal_get(c("red", "blue"), reverse = bad), "`reverse` must be")
  }
  expect_identical(pal_get("red", n = c(count = 2)), c("#FF0000", "#FF0000"))
  expect_identical(pal_get("red", alpha = c(opacity = 0.5)), "#FF000080")
  expect_identical(pal_get(c("red", "blue"), reverse = c(flip = TRUE)), c("blue", "red"))
})

test_that("pal_get rejects stored scalar classes before their methods are loaded", {
  directory <- withr::local_tempdir()
  fixture <- file.path(directory, "fixture.rds")
  script <- file.path(directory, "cold.R")
  output <- file.path(directory, "result.rds")
  fn <- pal_get
  apply <- .pal_apply
  env <- new.env(parent = asNamespace("stats"))
  environment(fn) <- env
  environment(apply) <- env
  env$.pal_apply <- apply
  saveRDS(list(fn = fn, n = structure(2, class = "integer64"),
               alpha = structure(0.5, class = "integer64")), fixture)
  writeLines(c(
    "args <- commandArgs(TRUE)",
    "fixture <- readRDS(args[[1]])",
    "stopifnot(!'bit64' %in% loadedNamespaces())",
    "n <- tryCatch(fixture[['fn']]('red', n = fixture[['n']]), error = conditionMessage)",
    "alpha <- tryCatch(fixture[['fn']]('red', alpha = fixture[['alpha']]), error = conditionMessage)",
    "saveRDS(list(n = n, alpha = alpha), args[[2]])"
  ), script)
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script), shQuote(fixture), shQuote(output)), stdout = TRUE, stderr = TRUE)
  expect_null(attr(status, "status"), info = paste(status, collapse = "\n"))
  if (is.null(attr(status, "status"))) {
    out <- readRDS(output)
    expect_match(out$n, "`n` must be")
    expect_match(out$alpha, "`alpha` must be")
  }
})

test_that("pal_get rejects dimensional and list mapping containers", {
  bad_x <- list(matrix(1:4, 2), array(1:4, c(2, 1, 2)), data.frame(a = 1:3),
                 list("A", "B"), list(c("A", "B"), "C"))
  for (x in bad_x) {
    expect_error(pal_get("lancet", x = x), "`x` must be")
    expect_error(pal_get(pal_heat, x = x), "`x` must be")
  }
  for (palette in list(matrix(c("red", "blue"), 1), data.frame(a = c("red", "blue")),
                        array(list("red", "blue"), c(1, 2)))) {
    expect_error(pal_get(palette), "`palette` must be")
  }
  expect_error(pal_get(list(custom = matrix(c("red", "blue"), 1))), "without dimensions")
  expect_identical(pal_get(structure(c("red", "blue"), class = "AsIs")), c("red", "blue"))
})

test_that("pal_get retains existing date and duration mapping classes", {
  date <- as.Date(c("2020-01-01", "2020-01-02"))
  time <- as.POSIXlt(c("2020-01-01", "2020-01-02"), tz = "UTC")
  expected <- c("2020-01-01" = "red", "2020-01-02" = "blue")
  expect_identical(pal_get(c("red", "blue"), x = date), expected)
  expect_identical(pal_get(c("red", "blue"), x = time), expected)
  expect_identical(pal_get(c("red", "blue"), x = as.difftime(c(1, 2), units = "days")),
                   c("1" = "red", "2" = "blue"))
})

test_that("pal_get shares discrete list mappings without changing level order", {
  palettes <- list(warm = c("red", "blue"), cool = c("black", "white"))
  x <- rep(c("B", NA, "A", "B"), 2500L)
  before <- x
  expect_identical(pal_get(palettes, n = 0, x = x, reverse = TRUE, alpha = 0.5),
                   list(warm = c(B = "#0000FF80", A = "#FF000080"),
                        cool = c(B = "#FFFFFF80", A = "#00000080")))
  expect_identical(x, before)
  empty <- stats::setNames(character(), character())
  expect_identical(pal_get(palettes, x = character()), list(warm = empty, cool = empty))
  expect_identical(pal_get(palettes, x = c(NA, NA)), list(warm = empty, cool = empty))
  expect_identical(pal_get(palettes, x = c(FALSE, TRUE, FALSE, NA)),
                   list(warm = c("FALSE" = "red", "TRUE" = "blue"),
                        cool = c("FALSE" = "black", "TRUE" = "white")))
  factor_x <- factor("B", levels = c("A", "B", "unused", NA), exclude = NULL)
  expect_identical(pal_get(palettes, x = factor_x),
                   list(warm = c(A = "#FF0000", B = "#7F007F", unused = "#0000FF"),
                        cool = c(A = "#000000", B = "#7F7F7F", unused = "#FFFFFF")))
})

test_that("pal_get rejects distinct discrete values with colliding names", {
  xs <- list(
    structure(c(0.1, 0.2), class = "Date"),
    as.POSIXct("2020-01-01", tz = "UTC") + c(1, 1.00000025),
    as.difftime(c(1, 1 + .Machine$double.eps), units = "days")
  )
  for (x in xs) {
    for (palette in list(c("red", "blue"), list(custom = c("red", "blue")))) {
      expect_error(pal_get(palette, x = x), "same discrete colour name")
    }
  }
  date <- as.Date("2020-01-01")
  expect_identical(pal_get(c("red", "blue"), x = rep(date, 2)),
                   c("2020-01-01" = "red"))
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

test_that("console swatches wrap without losing colours or copyable values", {
  cols <- stats::setNames(grDevices::rainbow(11), letters[1:11])
  attr(cols, "type") <- "discrete"
  withr::local_options(list(width = 40, cli.width = 40, cli.num_colors = 0))
  for (depth in c(0, 256, 16777216)) {
    options(cli.num_colors = depth)
    output <- capture.output(result <- withVisible(show_color(cols)))
    plain <- cli::ansi_strip(output)
    swatches <- grepl("^ #[0-9A-F]{6}", plain)
    expect_true(sum(swatches) > 1L)
    expect_true(all(nchar(plain[swatches], type = "width") <= 40L))
    displayed <- unlist(regmatches(plain[swatches],
                                   gregexpr("#[0-9A-F]{6}", plain[swatches])))
    expect_identical(unname(displayed), toupper(unname(as.character(cols))))
    expect_identical(eval(parse(text = plain[!swatches])), cols)
    expect_identical(result$value, cols)
    expect_false(result$visible)
  }
})

test_that("palette rebuilds stop before saving when source packages are absent", {
  script <- normalizePath(test_path("..", "..", "data-raw", "build_palette_list.R"),
                          mustWork = FALSE)
  skip_if_not(file.exists(script))
  work <- withr::local_tempdir()
  writeLines("Package: UtilsR", file.path(work, "DESCRIPTION"))
  withr::local_dir(work)
  isolated <- new.env(parent = globalenv())
  isolated$requireNamespace <- function(...) FALSE
  isolated$save <- function(...) stop("Unexpected attempt to replace palette data")
  expect_error(suppressMessages(sys.source(script, envir = isolated)),
               "Missing palette source packages")
})

test_that("palette rebuilds preserve existing data if registered names disappear", {
  script <- normalizePath(test_path("..", "..", "data-raw", "build_palette_list.R"),
                          mustWork = FALSE)
  skip_if_not(file.exists(script))
  packages <- c("RColorBrewer", "ggsci", "viridis", "rcartocolor", "nord",
                "dichromat", "pals", "colorspace")
  for (pkg in packages) skip_if_not_installed(pkg)
  work <- withr::local_tempdir()
  writeLines("Package: UtilsR", file.path(work, "DESCRIPTION"))
  dir.create(file.path(work, "data"))
  withr::local_dir(work)
  palette_list <- list(required_but_missing = structure(c("red", "blue"),
                                                        type = "discrete"))
  save(palette_list, file = "data/palette_list.rda")
  before <- readBin("data/palette_list.rda", "raw", file.info("data/palette_list.rda")$size)
  expect_error(suppressMessages(sys.source(script, envir = new.env())),
               "Rebuild would remove registered palettes")
  after <- readBin("data/palette_list.rda", "raw", file.info("data/palette_list.rda")$size)
  expect_identical(after, before)
})

test_that("palette rebuilds validate the package root before touching data", {
  script <- normalizePath(test_path("..", "..", "data-raw", "build_palette_list.R"),
                          mustWork = FALSE)
  skip_if_not(file.exists(script))
  work <- withr::local_tempdir()
  dir.create(file.path(work, "data"))
  withr::local_dir(work)
  foreign_payload <- "unrelated existing data"
  target <- "data/palette_list.rda"
  save(foreign_payload, file = target)
  before <- readBin(target, "raw", file.info(target)$size)
  for (description in list(NULL, "Package: AnotherPackage", "Title: No package name",
                            "malformed description")) {
    if (!is.null(description)) writeLines(description, "DESCRIPTION")
    isolated <- new.env(parent = globalenv())
    isolated$requireNamespace <- function(...) stop("Palette generation started")
    expect_error(suppressMessages(sys.source(script, envir = isolated)),
                 "Run this script from the UtilsR package root", fixed = TRUE)
    expect_identical(readBin(target, "raw", file.info(target)$size), before)
  }
})

test_that("palette rebuilds reject invalid existing data before generating palettes", {
  script <- normalizePath(test_path("..", "..", "data-raw", "build_palette_list.R"),
                          mustWork = FALSE)
  skip_if_not(file.exists(script))
  work <- withr::local_tempdir()
  writeLines("Package: UtilsR", file.path(work, "DESCRIPTION"))
  dir.create(file.path(work, "data"))
  withr::local_dir(work)
  target <- "data/palette_list.rda"
  malformed <- list(
    list(foreign_payload = "unrelated existing data"),
    list(foreign_payload = "unrelated existing data",
         palette_list = list(Set1 = structure("red", type = "discrete"))),
    list(palette_list = c("red", "blue")),
    list(palette_list = list()),
    list(palette_list = list(c("red", "blue"))),
    list(palette_list = setNames(list("red", "blue"), c("same", "same"))),
    list(palette_list = list(Set1 = c("red", "blue"))),
    list(palette_list = list(Set1 = structure("invalid-colour", type = "discrete")))
  )
  for (objects in malformed) {
    save(list = names(objects), envir = list2env(objects, parent = emptyenv()),
         file = target)
    before <- readBin(target, "raw", file.info(target)$size)
    isolated <- new.env(parent = globalenv())
    isolated$requireNamespace <- function(...) stop("Palette generation started")
    expect_error(suppressMessages(sys.source(script, envir = isolated)),
                 "[Ee]xisting palette data")
    expect_identical(readBin(target, "raw", file.info(target)$size), before)
  }
})

test_that("palette rebuilds stop when an individual CARTO palette fails", {
  script <- normalizePath(test_path("..", "..", "data-raw", "build_palette_list.R"),
                          mustWork = FALSE)
  skip_if_not(file.exists(script))
  registry <- normalizePath(test_path("..", "..", "data", "palette_list.rda"))
  packages <- c("RColorBrewer", "ggsci", "viridis", "rcartocolor", "nord",
                "dichromat", "pals", "colorspace")
  for (pkg in packages) skip_if_not_installed(pkg)
  original <- rcartocolor::carto_pal
  testthat::local_mocked_bindings(carto_pal = function(n, name, ...) {
    if (name == "Bold") stop("simulated CARTO failure")
    original(n, name, ...)
  }, .package = "rcartocolor")
  for (existing in c(FALSE, TRUE)) {
    local({
      work <- withr::local_tempdir()
      writeLines("Package: UtilsR", file.path(work, "DESCRIPTION"))
      dir.create(file.path(work, "data"))
      withr::local_dir(work)
      target <- "data/palette_list.rda"
      if (existing) file.copy(registry, target)
      before <- if (existing) readBin(target, "raw", file.info(target)$size) else NULL
      expect_error(suppressMessages(sys.source(script, envir = new.env())),
                   "Failed to generate rcartocolor palette 'Bold': simulated CARTO failure")
      if (existing) {
        expect_identical(readBin(target, "raw", file.info(target)$size), before)
      } else {
        expect_false(file.exists(target))
      }
    })
  }
})

test_that("palette preview allocation is bounded by the display cap", {
  skip_if_not(capabilities("profmem"))
  invisible(pal_show("Set1", n = 20, output = "gg"))
  profile <- withr::local_tempfile()
  Rprofmem(profile)
  value <- tryCatch(pal_show("Set1", n = 200000, max_colors = 20, output = "gg"),
                    finally = Rprofmem(NULL))
  allocations <- suppressWarnings(as.numeric(sub(" .*", "", readLines(profile, warn = FALSE))))
  expect_lt(sum(allocations, na.rm = TRUE), 5 * 1024^2)
  expect_equal(nrow(value$data), 20L)
  for (cols in list(palette_list$Set1, c("#FF000080", "#0000FF80"))) {
    original <- grDevices::colorRampPalette(cols, alpha = any(grDevices::col2rgb(cols, alpha = TRUE)[4L, ] < 255))(1003)
    invisible(capture.output(actual <- pal_show(cols, n = 1003, max_colors = 6, output = "console")))
    expect_identical(as.character(actual), original[1:6])
  }
  continuous <- pal_show("viridis", n = 200000, max_colors = 6, output = "gg")
  expect_identical(grDevices::col2rgb(continuous$data$color[c(1, 6)]),
                   grDevices::col2rgb(palette_list$viridis[c(1, 256)]))
})

test_that("continuous palette previews cover the full range in every output", {
  full <- palette_list[["viridis"]]
  ends <- grDevices::col2rgb(full[c(1L, length(full))], alpha = TRUE)
  for (settings in list(list(n = NULL, cap = 20), list(n = 8, cap = 20),
                       list(n = 40, cap = 6))) {
    for (output in c("gg", "console")) {
      invisible(capture.output(value <- pal_show("viridis", n = settings$n,
                                                 max_colors = settings$cap, output = output)))
      cols <- if (output == "gg") value$data$color else value[[1L]]
      expect_identical(grDevices::col2rgb(cols[c(1L, length(cols))], alpha = TRUE), ends)
    }
    tbl <- pal_show("viridis", n = settings$n, max_colors = settings$cap)
    expect_match(tbl[["_data"]]$preview, "background:#440154;", fixed = TRUE)
    expect_match(tbl[["_data"]]$preview, "background:#FDE725;", fixed = TRUE)
  }
  p <- pal_show(full, max_colors = 6, output = "gg")
  expect_identical(grDevices::col2rgb(p$data$hex[c(1L, 6L)], alpha = TRUE), ends)
  one <- pal_show("viridis", n = 1, output = "gg")
  expect_identical(one$data$color, as.character(full[ceiling(length(full) / 2)]))
  brewer <- pal_show_brewer("Blues", max_colors = 3, output = "gg")
  expect_identical(brewer$data$color, RColorBrewer::brewer.pal(9, "Blues")[c(1, 5, 9)])
})

test_that("console palette previews preserve alpha labels and the original vector", {
  withr::local_options(cli.num_colors = 0)
  cols <- c("#FF000080", "transparent", "blue")
  out <- capture.output(value <- pal_show(cols, output = "console"))
  swatches <- out[grepl("^ #", out)]
  expect_match(swatches[[1]], "#FF000080", fixed = TRUE)
  expect_match(swatches[[1]], "#FFFFFF00", fixed = TRUE)
  expect_identical(value, cols)
  out <- capture.output(pal_list(pattern = "^Set1$", show = TRUE))
  expect_match(paste(out, collapse = "\n"), "#E41A1C", fixed = TRUE)
  withr::local_options(cli.num_colors = 16777216)
  out <- capture.output(show_color("#FF000080"))
  expect_match(out[[1]], "48;2;255;127;127", fixed = TRUE)
  expect_match(cli::ansi_strip(out[[1]]), "#FF000080", fixed = TRUE)
})

test_that("palette previews retain partial names and replace missing labels individually", {
  cols <- stats::setNames(c("red", "blue", "black"), c("A", "", NA_character_))
  expected <- c("A", "#0000FF", "#000000")
  p <- pal_show(cols, output = "gg")
  expect_identical(p$data$label, expected)
  expect_no_warning(ggplot2::ggplotGrob(p))
  expect_identical(pal_show(cols, output = "gt")[["_data"]]$name, expected)
  blank <- stats::setNames(c("red", "blue", "black"), c("A", "\t", "\u3000"))
  expect_identical(pal_show(blank, output = "gg")$data$label, expected)
  expect_equal(length(pal_show(cols, label = FALSE, output = "gg")$layers), 1L)
})

test_that("palette previews reject numeric colour indices in vectors and lists", {
  for (bad in c("2", "2.0", "2e0")) {
    for (output in c("gg", "gt", "console")) {
      expect_error(pal_show(c("red", bad), output = output))
      expect_error(pal_show(list(custom = c("red", bad)), output = output), "custom")
    }
  }
  for (output in c("gg", "gt", "console")) {
    expect_error(pal_show(list(custom = c("red", "notacolor")), output = output), "custom")
  }
  expect_equal(nrow(pal_show(c("transparent", "#F00", "light blue"), output = "gg")$data), 3L)
})

test_that("palette viewers deduplicate palette names without removing colour repeats", {
  viewers <- list(
    list(fun = pal_show, palette = "Set1"),
    list(fun = pal_show_brewer, palette = "Set1"),
    list(fun = pal_show_hcl, palette = "Viridis"),
    list(fun = pal_show_viridis, palette = "viridis")
  )
  if (requireNamespace("ggsci", quietly = TRUE)) {
    viewers <- c(viewers, list(list(fun = pal_show_ggsci, palette = "ggsci_npg_nrc")))
  }
  for (viewer in viewers) {
    for (output in c("gg", "gt", "console")) {
      invisible(capture.output(value <- viewer$fun(rep(viewer$palette, 2), output = output)))
      count <- if (output == "gg") length(unique(value$data$palette)) else if (output == "gt") {
        nrow(value[["_data"]])
      } else length(value)
      expect_equal(count, 1L)
    }
  }
  expect_equal(nrow(pal_show(c("red", "red", "blue"), output = "gg")$data), 3L)
})

test_that("palette viewers reject unsupported palette input types", {
  viewers <- list(pal_show, pal_show_brewer, pal_show_hcl, pal_show_viridis)
  if (requireNamespace("ggsci", quietly = TRUE)) viewers <- c(viewers, list(pal_show_ggsci))
  for (viewer in viewers) {
    for (bad in list(factor("viridis"), matrix("Set1"), data.frame(a = "red"),
                     as.Date("2026-11-02"), 1, character(), NA_character_)) {
      expect_error(viewer(palette = bad, output = "gg"), "`palette`")
    }
  }
  for (bad in list(list(a = character()), list(a = 1:2), list(a = matrix("red")))) {
    expect_error(pal_show(bad, output = "gg"), "`palette`")
  }
})

test_that("palette catalogue types match sequential and categorical sources", {
  wanted <- names(palette_list)[grepl("^ggsci_(bs5|tw3)_", names(palette_list))]
  expect_length(wanted, 33L)
  invisible(capture.output(found <- pal_list(
    pattern = "^ggsci_(bs5|tw3)_", type = "continuous", show = FALSE
  )))
  expect_named(found, wanted)
  expect_true(all(vapply(found, function(p) identical(attr(p, "type"),
                                                     "continuous"), logical(1))))
  invisible(capture.output(categorical <- pal_list(
    pattern = "^dichromat_Categorical[.]12$", type = "discrete", show = FALSE
  )))
  expect_named(categorical, "dichromat_Categorical.12")
  if (requireNamespace("ggsci", quietly = TRUE)) {
    invisible(capture.output(source <- pal_show_ggsci(
      pattern = "^ggsci_(bs5_blue|tw3_slate)$", output = "console"
    )))
    expect_named(source, c("ggsci_bs5_blue", "ggsci_tw3_slate"))
    expect_identical(unname(vapply(source, attr, character(1), "type")),
                     c("continuous", "continuous"))
  }
})

test_that("console palettes follow stdout when stderr is not coloured", {
  withr::local_options(cli.num_colors = NULL)
  testthat::local_mocked_bindings(num_ansi_colors = function(stream = "auto") {
    forced <- getOption("cli.num_colors")
    if (!is.null(forced)) return(as.integer(forced))
    if (identical(stream, stdout())) 16777216L else 1L
  }, .package = "cli")
  output <- capture.output(result <- withVisible(show_color("#2166AC")))
  expect_match(paste(output, collapse = ""), "48;2;33;102;172", fixed = TRUE)
  expect_identical(result$value, "#2166AC")
  expect_false(result$visible)
  expect_null(getOption("cli.num_colors"))
  testthat::local_mocked_bindings(make_ansi_style = function(...) {
    stop("style failure")
  }, .package = "cli")
  expect_error(show_color("#2166AC"), "style failure")
  expect_null(getOption("cli.num_colors"))
})

test_that("palette rebuilds reject unreadable or empty source collections", {
  script <- normalizePath(test_path("..", "..", "data-raw", "build_palette_list.R"),
                          mustWork = FALSE)
  skip_if_not(file.exists(script))
  packages <- c("RColorBrewer", "ggsci", "viridis", "rcartocolor", "nord",
                "dichromat", "pals", "colorspace")
  for (pkg in packages) skip_if_not_installed(pkg)
  work <- withr::local_tempdir()
  writeLines("Package: UtilsR", file.path(work, "DESCRIPTION"))
  withr::local_dir(work)
  original <- utils::getFromNamespace
  for (source in c("ggsci", "pals")) {
    for (database in list(NULL, list(), list(unrelated = character()))) {
      local({
        testthat::local_mocked_bindings(getFromNamespace = function(x, ns, ...) {
          if ((source == "ggsci" && ns == "ggsci" && x == "ggsci_db") ||
              (source == "pals" && ns == "pals" && x == "syspals")) return(database)
          original(x, ns, ...)
        }, .package = "utils")
        isolated <- new.env(parent = globalenv())
        isolated$save <- function(...) stop("Unexpected save of incomplete palettes")
        expect_error(suppressMessages(sys.source(script, envir = isolated)),
                     paste0("Missing palette source collections: ", source))
      })
    }
  }
  expect_false(file.exists("data/palette_list.rda"))
  dir.create("data")
  suppressMessages(sys.source(script, envir = new.env(parent = globalenv())))
  rebuilt <- new.env(parent = emptyenv())
  load("data/palette_list.rda", envir = rebuilt)
  keys <- c("viridis", "ggsci_bs5_blue", "ggsci_tw3_slate", "dichromat_Categorical.12",
             "carto_Bold")
  expect_true(all(keys %in% names(rebuilt$palette_list)))
  expect_identical(unname(vapply(rebuilt$palette_list[keys], attr, character(1), "type")),
                   c("continuous", "continuous", "continuous", "discrete", "discrete"))
})

test_that("palette console headings retain complete names in narrow terminals", {
  withr::local_options(list(cli.num_colors = 0, cli.width = 80, width = 80))
  keys <- c("ggsci_material_deep-purple", "ggsci_material_deep-orange",
            "ggsci_cosmic_signature_substitutions")
  pattern <- "^ggsci_(material_deep-(purple|orange)|cosmic_signature_substitutions)$"
  viewers <- list(
    function() pal_list(pattern = pattern, show = FALSE),
    function() pal_show(keys, output = "console", max_colors = 1)
  )
  for (width in c(20L, 40L)) {
    options(cli.width = width, width = width)
    for (viewer in viewers) {
      output <- capture.output(result <- withVisible(viewer()))
      for (key in keys) expect_true(any(grepl(key, output, fixed = TRUE)))
      expect_true(any(grepl("colours", output)))
      expect_true(any(grepl("continuous|discrete", output)))
      expect_setequal(names(result$value), keys)
      expect_false(result$visible)
    }
  }
  options(cli.width = 80, width = 80)
  output <- capture.output(result <- pal_list("^ggsci_material_deep-purple$", show = FALSE))
  expect_length(output[nzchar(output)], 1L)
  expect_match(paste(output, collapse = ""),
               "ggsci_material_deep-purple (10 colours, continuous)", fixed = TRUE)
  expect_identical(result, palette_list["ggsci_material_deep-purple"])
})

test_that("HCL viewers preserve divergingx categories and both colour ends", {
  choices <- grDevices::hcl.pals("divergingx")
  p <- pal_show_hcl(type = "divergingx", n = 3, output = "gg")
  expect_identical(unique(as.character(p$data$palette)), choices)
  native <- grDevices::hcl.colors(40, "RdBu")
  shown <- pal_show_hcl("RdBu", n = 40, max_colors = 3, output = "gg")
  expect_identical(shown$data$color, native[c(1L, 20L, 40L)])
  tbl <- pal_show_hcl("RdBu", output = "gt")
  expect_identical(tbl[["_data"]]$type, "divergingx")
  invisible(capture.output(console <- pal_show_hcl(
    "RdBu", n = 40, max_colors = 3, output = "console"
  )))
  expect_identical(as.character(console[[1L]]), native[c(1L, 20L, 40L)])
})

test_that("ggsci continuous previews sample the entire native colour range", {
  skip_if_not_installed("ggsci")
  db <- utils::getFromNamespace("ggsci_db", "ggsci")
  for (family in c("gsea", "material", "bs5", "tw3")) {
    sub <- names(db[[family]])[[1L]]
    name <- paste0(family, "_", sub)
    native <- unname(db[[family]][[sub]])
    expected <- native[round(seq.int(1, length(native), length.out = 3))]
    p <- pal_show_ggsci(name, n = 3, output = "gg")
    expect_identical(p$data$color, expected)
    invisible(capture.output(console <- pal_show_ggsci(name, n = 3, output = "console")))
    expect_identical(as.character(console[[1L]]), expected)
    tbl <- pal_show_ggsci(name, n = 3, output = "gt")
    for (colour in expected) {
      expect_match(tbl[["_data"]]$preview, toupper(colour), fixed = TRUE)
    }
    capped <- pal_show_ggsci(name, n = length(native), max_colors = 3, output = "gg")
    expect_identical(capped$data$color, expected)
    reversed <- pal_show_ggsci(name, n = 3, reverse = TRUE, output = "gg")
    expect_identical(reversed$data$color[c(1L, 3L)], rev(native)[c(1L, length(native))])
  }
  discrete <- unname(db$npg$nrc)
  expect_identical(pal_show_ggsci("npg_nrc", n = 3, output = "gg")$data$color,
                   discrete[1:3])
})

test_that("source palette controls reject classed and dimensional scalars", {
  viewers <- list(
    list(fun = pal_show_viridis, palette = "viridis", args = c("alpha", "begin", "end", "direction"))
  )
  if (requireNamespace("ggsci", quietly = TRUE)) {
    viewers <- c(viewers, list(list(fun = pal_show_ggsci, palette = "npg_nrc", args = "alpha")))
  }
  for (viewer in viewers) {
    for (arg in viewer$args) {
      value <- if (arg == "direction") 1 else 0.5
      for (bad in list(matrix(value), array(value, c(1, 1, 1)),
                       structure(value, class = "stored_numeric"),
                       structure(value, class = "integer64"))) {
        args <- list(palette = viewer$palette, output = "gg")
        args[arg] <- list(bad)
        expect_error(do.call(viewer$fun, args), paste0("`", arg, "`"))
      }
    }
  }
  if (requireNamespace("ggsci", quietly = TRUE)) {
    for (bad in list(matrix(TRUE), array(FALSE, c(1, 1, 1)), structure(TRUE, class = "flag"))) {
      expect_error(pal_show_ggsci("npg_nrc", reverse = bad, output = "gg"), "`reverse`")
    }
  }
  transparent <- pal_show_viridis("viridis", n = 3, alpha = 0, output = "gg")
  expect_identical(unname(grDevices::col2rgb(transparent$data$color, alpha = TRUE)[4, ]), rep(0L, 3))
})

test_that("source palette viewers report unknown names without losing valid selections", {
  viewers <- list(
    list(fun = pal_show_brewer, palette = "Set1"),
    list(fun = pal_show_hcl, palette = "Viridis"),
    list(fun = pal_show_viridis, palette = "viridis")
  )
  if (requireNamespace("ggsci", quietly = TRUE)) {
    viewers <- c(viewers, list(list(fun = pal_show_ggsci, palette = "npg_nrc")))
  }
  for (viewer in viewers) {
    for (output in c("gg", "gt", "console")) {
      args <- list(palette = c(viewer$palette, "__typo__", "__typo__"), output = output)
      invisible(capture.output(expect_warning(value <- do.call(viewer$fun, args), "__typo__")))
      count <- if (output == "gg") length(unique(value$data$palette)) else if (output == "gt") {
        nrow(value[["_data"]])
      } else length(value)
      expect_equal(count, 1L)
    }
    expect_error(viewer$fun("__typo__", output = "gg"), "No matching")
  }
})

test_that("source palette filters preserve explicit name precedence", {
  viewers <- list(
    list(fun = pal_show_brewer, palette = "Set1", type = "seq", name = "Set1"),
    list(fun = pal_show_hcl, palette = "Viridis", type = "qualitative", name = "Viridis"),
    list(fun = pal_show_viridis, palette = "viridis", name = "viridis")
  )
  if (requireNamespace("ggsci", quietly = TRUE)) {
    viewers <- c(viewers, list(list(fun = pal_show_ggsci, palette = "npg_nrc", name = "ggsci_npg_nrc")))
  }
  for (viewer in viewers) {
    for (pattern in c("__none__", "[")) {
      args <- list(palette = viewer$palette, pattern = pattern, output = "gg")
      if (!is.null(viewer$type)) args$type <- viewer$type
      p <- do.call(viewer$fun, args)
      expect_identical(unique(as.character(p$data$palette)), viewer$name)
    }
  }
})

test_that("source palette names follow native HCL matching", {
  requested <- c("viridis", "dark3", "Dark-3", "Dark 3")
  expected <- c("Viridis", "Dark 3")
  p <- pal_show_hcl(requested, n = 3, output = "gg")
  expect_identical(unique(as.character(p$data$palette)), expected)
  expect_identical(p$data$color[1:3], grDevices::hcl.colors(3, "viridis"))
  expect_identical(p$data$color[4:6], grDevices::hcl.colors(3, "Dark-3"))
  expect_no_warning(pal_show_hcl(requested, n = 3, output = "gt"))
  invisible(capture.output(value <- pal_show_hcl(requested, n = 3, output = "console")))
  expect_named(value, expected)
  expect_error(pal_show_hcl(c("Viridis", "Dark"), output = "gg"), "ambiguous.*Dark")
  expect_warning(known <- pal_show_hcl(c("viridis", "__typo__"), output = "gg"), "__typo__")
  expect_identical(unique(as.character(known$data$palette)), "Viridis")
})

test_that("Brewer previews report adjusted colour counts once per call", {
  messages <- character()
  p <- withCallingHandlers(pal_show_brewer(c("Set1", "Paired"), n = 30, output = "gg"),
    message = function(m) {
      messages <<- c(messages, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  expect_length(messages, 1L)
  expect_match(paste(messages, collapse = "\n"), "Set1=9", fixed = TRUE)
  expect_match(paste(messages, collapse = "\n"), "Paired=12", fixed = TRUE)
  expect_identical(as.integer(table(as.character(p$data$palette))), c(12L, 9L))
  expect_message(small <- pal_show_brewer("Set1", n = 1, output = "gt"), "Set1=3")
  expect_identical(small[["_data"]]$n_colors, "3")
  messages <- character()
  for (n in list(NULL, 3, 8)) {
    withCallingHandlers(pal_show_brewer("Set1", n = n, output = "gg"),
      message = function(m) {
        messages <<- c(messages, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    )
  }
  expect_length(messages, 0L)
})

test_that("palette interpolation preserves exact endpoints in complete previews", {
  for (cols in list(palette_list[["Set1"]], c("#FF000080", "#0000FF40"))) {
    alpha <- any(grDevices::col2rgb(cols, alpha = TRUE)[4L, ] < 255)
    for (n in c(50L, 99L, 104L, 108L, 1003L)) {
      expected <- grDevices::colorRampPalette(cols, alpha = alpha)(n)
      invisible(capture.output(actual <- pal_show(
        cols, n = n, max_colors = Inf, output = "console"
      )))
      expect_identical(as.character(actual), expected)
      invisible(capture.output(prefix <- pal_show(
        cols, n = n, max_colors = 6, output = "console"
      )))
      expect_identical(as.character(prefix), expected[1:6])
    }
  }
  expected <- grDevices::colorRampPalette(palette_list[["Set1"]])(50)
  p <- pal_show("Set1", n = 50, max_colors = Inf, output = "gg")
  expect_identical(p$data$color, expected)
  tbl <- pal_show("Set1", n = 50, max_colors = Inf, output = "gt")
  expect_match(tbl[["_data"]]$preview, "background:#999999;", fixed = TRUE)
})

test_that("colour vector plot labels follow replaced data", {
  replace_data <- if (utils::packageVersion("ggplot2") < "4.0.0") {
    ggplot2::`%+%`
  } else function(p, data) p + data
  for (named in c(FALSE, TRUE)) {
    cols <- c("#000000", "#FFFFFF")
    if (named) names(cols) <- c("Dark", "")
    p <- pal_show(cols, output = "gg")
    replacement <- p$data[2:1, ]
    layers <- ggplot2::ggplot_build(replace_data(p, replacement))$data
    expect_identical(as.character(layers[[2L]]$colour), replacement$fg)
    expect_identical(layers[[2L]]$label, replacement$label)
    if (named) {
      expect_identical(layers[[2L]]$vjust, c(0.5, -0.3))
      expect_identical(layers[[3L]]$label, c("", "#000000"))
      expect_identical(as.character(layers[[3L]]$colour), replacement$fg)
    }
    selected <- p$data[1L, , drop = FALSE]
    layers <- ggplot2::ggplot_build(replace_data(p, selected))$data
    expect_identical(as.character(layers[[2L]]$colour), selected$fg)
    expect_identical(layers[[2L]]$label, selected$label)
    if (named) expect_identical(layers[[3L]]$label, "#000000")
  }
})

test_that("palette plot objects do not retain hidden input vectors", {
  make <- function(n, registry, label) {
    cols <- if (registry) rep("Set1", n) else sprintf("#%06X", seq_len(n))
    suppressMessages(UtilsR::pal_show(cols, output = "gg", label = label))
  }
  environment(make) <- globalenv()
  target <- withr::local_tempfile(fileext = ".rds")
  size <- function(p) {
    saveRDS(p, target, compress = FALSE)
    file.info(target)$size
  }
  for (registry in c(FALSE, TRUE)) {
    for (label in c(FALSE, TRUE)) {
      invisible(make(20L, registry, label))
      small <- make(20L, registry, label)
      large <- make(20000L, registry, label)
      expect_equal(nrow(large$data), if (registry) 9L else 20L)
      expect_lt(size(large) - size(small), 50000)
    }
  }
})
