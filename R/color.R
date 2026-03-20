# ============================================================================
# color.R -- Colour palettes with console swatch display
# ============================================================================

#' Create a colour palette object
#'
#' Wraps a character vector of colours into a \code{palette} class so that
#' printing in the console automatically shows coloured swatches.
#'
#' @param x Character vector of colours (hex codes or named R colours).
#' @return A character vector with class \code{"palette"}.
#'
#' @examples
#' p <- as_palette(c("#FF0000", "#00FF00", "#0000FF"))
#' p
#'
#' @export
#' @family colour palettes
as_palette <- function(x) {
  if (!is.character(x)) {
    cli::cli_abort("{.arg x} must be a character vector of colours, got {.cls {class(x)}}.")
  }
  structure(x, class = c("palette", "character"))
}

#' @export
#' @family colour palettes
print.palette <- function(x, ...) {
  show_color(x)
  invisible(x)
}

#' @export
#' @family colour palettes
`[.palette` <- function(x, i, ...) {
  as_palette(NextMethod())
}

#' @export
#' @family colour palettes
c.palette <- function(...) {
  as_palette(NextMethod())
}

#' Lancet Colour Palette
#'
#' A 15-colour palette inspired by \emph{The Lancet} journal style,
#' suitable for categorical data visualisation.
#'
#' @format A \code{palette} object (character vector of 15 hex colour codes).
#'   Printing in the console displays coloured swatches automatically.
#'
#' @examples
#' pal_lancet
#' pal_lancet[1:5]
#'
#' @export
#' @family colour palettes
pal_lancet <- as_palette(c(
  "#00468BFF", "#ED0000FF", "#42B540FF", "#0099B4FF", "#925E9FFF",
  "#FDAF91FF", "#AD002AFF", "#ADB6B6FF", "#1B1919FF", "#79AF97FF",
  "#DF8F44FF", "#6A6599FF", "#FCCDE5FF", "#80B1D3FF", "#0000FFFF"
))

#' Additional Built-in Colour Palettes
#'
#' A named list of 10 discrete colour palettes suitable for single-cell
#' cluster visualisation. Access individual palettes via
#' \code{pal_other$igv}, \code{pal_other$ditto}, etc.
#'
#' @format A named list of \code{palette} objects:
#' \describe{
#'   \item{igv}{48 colours, IGV genome browser}
#'   \item{ditto}{40 colours, dittoSeq (scRNA-seq)}
#'   \item{polychrome}{36 colours, max perceptual distinctness}
#'   \item{glasbey}{32 colours, Glasbey algorithm}
#'   \item{alphabet}{26 colours, Green-Armytage A-Z}
#'   \item{ucsc}{26 colours, UCSC genome browser}
#'   \item{kelly}{22 colours, Kelly max contrast}
#'   \item{d3}{20 colours, D3.js Category20}
#'   \item{simpsons}{16 colours, ggsci Simpsons}
#'   \item{trubetskoy}{20 colours, Trubetskoy distinct}
#' }
#'
#' @examples
#' names(pal_other)
#' pal_other$ditto
#' pal_other$igv[1:10]
#' show_color(pal_other$polychrome)
#'
#' @export
#' @family colour palettes
pal_other <- list(
  igv = as_palette(c(
    "#5050FF", "#CE3D32", "#749B58", "#F0E685", "#466983", "#BA6338",
    "#5DB1DD", "#802268", "#6BD76B", "#D595A7", "#924822", "#837B8D",
    "#C75127", "#D58F5C", "#7A65A5", "#E4AF69", "#3B1B53", "#CDDEB7",
    "#612A79", "#AE1F63", "#E7C76F", "#5A655E", "#CC9900", "#99CC00",
    "#33CC00", "#00CC33", "#00CC99", "#0099CC", "#0A47FF", "#4775FF",
    "#FFC20A", "#FFD147", "#990033", "#991A00", "#996600", "#809900",
    "#339900", "#00991A", "#009966", "#008099", "#003399", "#1A0099",
    "#660099", "#990080", "#D60047", "#FF1463", "#00D68F", "#14FFB1"
  )),
  ditto = as_palette(c(
    "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
    "#CC79A7", "#666666", "#AD7700", "#1C91D4", "#007756", "#D5C711",
    "#005685", "#A04700", "#B14380", "#4D4D4D", "#FFBE2D", "#80C7EF",
    "#00F6B3", "#F4EB71", "#06A5FF", "#FF8320", "#D99BBD", "#8C8C8C",
    "#FFCB57", "#9AD2F2", "#2CFFC6", "#F6EF8E", "#38B7FF", "#FF9B4D",
    "#E0AFCA", "#A3A3A3", "#8A5F00", "#1674A9", "#005F45", "#AA9F0D",
    "#00446B", "#803800", "#8D3666", "#3D3D3D"
  )),
  polychrome = as_palette(c(
    "#5A5156", "#E4E1E3", "#F6222E", "#FE00FA", "#16FF32", "#3283FE",
    "#FEAF16", "#B00068", "#1CFFCE", "#90AD1C", "#2ED9FF", "#DEA0FD",
    "#AA0DFE", "#F8A19F", "#325A9B", "#C4451C", "#1C8356", "#85660D",
    "#B10DA1", "#FBE426", "#1CBE4F", "#FA0087", "#FC1CBF", "#F7E1A0",
    "#C075A6", "#782AB6", "#AAF400", "#BDCDFF", "#822E1C", "#B5EFB5",
    "#7ED7D1", "#1C7F93", "#D85FF7", "#683B79", "#66B0FF", "#3B00FB"
  )),
  glasbey = as_palette(c(
    "#0000FF", "#FF0000", "#00FF00", "#000033", "#FF00B6", "#005300",
    "#FFD300", "#009FFF", "#9A4D42", "#00FFBE", "#783FC1", "#1F9698",
    "#FFACFD", "#B1CC71", "#F1085C", "#FE8F42", "#DD00FF", "#201A01",
    "#720055", "#766C95", "#02AD24", "#C8FF00", "#886C00", "#FFB79F",
    "#858567", "#A10300", "#14F9FF", "#00469E", "#DC5E93", "#93D4FF",
    "#004CFF", "#F2F318"
  )),
  alphabet = as_palette(c(
    "#F0A0FF", "#0075DC", "#993F00", "#4C005C", "#191919", "#005C31",
    "#2BCE48", "#FFCC99", "#808080", "#94FFB5", "#8F7C00", "#9DCC00",
    "#C20088", "#003380", "#FFA405", "#FFA8BB", "#426600", "#FF0010",
    "#5EF1F2", "#00998F", "#E0FF66", "#740AFF", "#990000", "#FFFF80",
    "#FFE100", "#FF5005"
  )),
  ucsc = as_palette(c(
    "#FF0000", "#FF9900", "#FFCC00", "#00FF00", "#6699FF", "#CC33FF",
    "#99991E", "#999999", "#FF00CC", "#CC0000", "#FFCCCC", "#FFFF00",
    "#CCFF00", "#358000", "#0000CC", "#99CCFF", "#00FFFF", "#CCFFFF",
    "#9900CC", "#CC99FF", "#996600", "#666600", "#666666", "#CCCCCC",
    "#79CC3D", "#CCCC99"
  )),
  kelly = as_palette(c(
    "#F2F3F4", "#222222", "#F3C300", "#875092", "#F38400", "#A1CAF1",
    "#BE0032", "#C2B280", "#848482", "#008856", "#E68FAC", "#0067A5",
    "#F99379", "#604E97", "#F6A600", "#B3286E", "#DCD300", "#882D17",
    "#8DB600", "#654321", "#E25822", "#2B3D26"
  )),
  d3 = as_palette(c(
    "#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD", "#8C564B",
    "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF", "#AEC7E8", "#FFBB78",
    "#98DF8A", "#FF9896", "#C5B0D5", "#C49C94", "#F7B6D2", "#C7C7C7",
    "#DBDB8D", "#9EDAE5"
  )),
  simpsons = as_palette(c(
    "#FED439", "#709AE1", "#8A9197", "#D2AF81", "#FD7446", "#D5E4A2",
    "#197EC0", "#F05C3B", "#46732E", "#71D0F5", "#370335", "#075149",
    "#C80813", "#91331F", "#1A9993", "#FD8CC1"
  )),
  trubetskoy = as_palette(c(
    "#E6194B", "#3CB44B", "#FFE119", "#4363D8", "#F58231", "#911EB4",
    "#42D4F4", "#F032E6", "#BFEF45", "#FABED4", "#469990", "#DCBEFF",
    "#9A6324", "#FFFAC8", "#800000", "#AAFFC3", "#808000", "#FFD8B1",
    "#000075", "#A9A9A9"
  ))
)

#' List All Available Palettes
#'
#' Browse palettes from the built-in collection (256 palettes from
#' RColorBrewer, ggsci, viridis, rcartocolor, nord, dichromat, pals,
#' colorspace, and UtilsR built-in). Use \code{pattern} to filter.
#'
#' @param pattern Regex pattern to filter palette names. Default \code{NULL}
#'   shows all.
#' @param type Filter by type: \code{"all"} (default), \code{"discrete"},
#'   or \code{"continuous"}.
#' @param show Logical, if \code{TRUE} (default) display colour swatches.
#' @return Invisibly returns a named list of matching palettes.
#'
#' @examples
#' pal_list(show = FALSE)
#' pal_list(pattern = "^Blues")
#' pal_list(type = "discrete", pattern = "nord")
#'
#' @export
#' @family colour palettes
pal_list <- function(pattern = NULL, type = c("all", "discrete", "continuous"),
                     show = TRUE) {
  type <- match.arg(type)
  pals <- palette_list
  # Filter by type
  if (type != "all") {
    pals <- pals[vapply(pals, function(x) identical(attr(x, "type"), type), logical(1))]
  }
  # Filter by pattern
  if (!is.null(pattern)) {
    pals <- pals[grep(pattern, names(pals), ignore.case = TRUE)]
  }
  if (length(pals) == 0) {
    cli::cli_inform("No palettes matched.")
    return(invisible(list()))
  }
  for (nm in names(pals)) {
    tp <- attr(pals[[nm]], "type") %||% "?"
    cat(sprintf("\n=== %s (%d colours, %s) ===\n", nm, length(pals[[nm]]), tp))
    if (show) show_color(pals[[nm]])
  }
  invisible(pals)
}

#' Get Colours from a Named Palette
#'
#' Retrieve colours from the built-in palette collection (256 palettes).
#' Supports discrete mapping (factor/character input) and continuous
#' interpolation (numeric input or \code{n} parameter).
#'
#' @param palette Palette name (e.g. \code{"Paired"}, \code{"viridis"},
#'   \code{"lancet"}). Use \code{pal_list()} to see all available names.
#' @param n Number of colours to return. For discrete palettes, colours are
#'   recycled or interpolated as needed. Default \code{NULL} returns all
#'   colours in the palette.
#' @param x Optional vector to map colours to. If character/factor, returns
#'   a named colour vector. If numeric, interpolates along the palette.
#' @param reverse Logical, reverse colour order. Default \code{FALSE}.
#' @param alpha Numeric 0-1, colour transparency. Default 1 (opaque).
#'
#' @return A character vector of hex colours (named if \code{x} is provided).
#'
#' @examples
#' # Get 5 colours from Paired palette
#' pal_get("Paired", n = 5)
#'
#' # Map factor levels to colours
#' pal_get("lancet", x = c("A", "B", "C"))
#'
#' # Continuous interpolation
#' pal_get("viridis", n = 20)
#'
#' # Reverse and transparent
#' pal_get("Blues", n = 5, reverse = TRUE, alpha = 0.6)
#'
#' # Use in ggplot
#' # ggplot(df, aes(x, y, color = group)) +
#' #   scale_color_manual(values = pal_get("lancet", x = levels(df$group)))
#'
#' @export
#' @family colour palettes
pal_get <- function(palette = "Paired", n = NULL, x = NULL,
                    reverse = FALSE, alpha = 1) {
  pals <- palette_list
  if (!palette %in% names(pals)) {
    # Fuzzy match
    matches <- grep(palette, names(pals), ignore.case = TRUE, value = TRUE)
    if (length(matches) > 0) {
      cli::cli_inform("Palette {.val {palette}} not found. Did you mean: {.val {matches[1:min(5, length(matches))]}}")
    }
    cli::cli_abort("Palette {.val {palette}} not found. Use {.fn pal_list} to see available palettes.")
  }
  cols <- pals[[palette]]

  # --- Map to x (discrete) ---
  if (!is.null(x)) {
    if (is.numeric(x)) {
      # Continuous: interpolate
      ramp <- grDevices::colorRampPalette(cols)
      out <- ramp(length(x))
    } else {
      # Discrete: map levels
      lvs <- if (is.factor(x)) levels(x) else unique(x)
      n_lvs <- length(lvs)
      if (n_lvs <= length(cols)) {
        out <- stats::setNames(cols[seq_len(n_lvs)], lvs)
      } else {
        out <- stats::setNames(grDevices::colorRampPalette(cols)(n_lvs), lvs)
      }
    }
  } else if (!is.null(n)) {
    # --- Return n colours ---
    if (n <= length(cols)) {
      out <- cols[seq_len(n)]
    } else {
      out <- grDevices::colorRampPalette(cols)(n)
    }
  } else {
    out <- cols
  }

  # Reverse
  if (reverse) {
    if (!is.null(names(out))) {
      out <- stats::setNames(rev(out), names(out))
    } else {
      out <- rev(out)
    }
  }
  # Alpha
  if (alpha < 1) {
    out <- ggplot2::alpha(out, alpha)
  }

  as_palette(as.character(out))
}

#' Visualise Palettes
#'
#' Display palettes as horizontal colour bars (ggplot) or an interactive
#' gt table with colour swatches. Use \code{output = "gg"} for the Plots
#' pane or \code{output = "gt"} for the Viewer pane.
#'
#' @param palette Character vector of palette names, or \code{NULL} to show
#'   all palettes matching \code{pattern}/\code{type}.
#' @param pattern Regex pattern to filter palette names (e.g. \code{"^nord"}).
#' @param type Filter by type: \code{"all"}, \code{"discrete"}, or
#'   \code{"continuous"}.
#' @param max_colors Maximum colours to display per palette. Default 20.
#' @param index Integer vector of palette indices to show (after filtering).
#' @param output Output format: \code{"gg"} (default) for ggplot or
#'   \code{"gt"} for gt table.
#'
#' @return A ggplot or gt object (also prints).
#'
#' @examples
#' # Show specific palettes (gt table, default)
#' pal_show(c("lancet", "Paired", "viridis"))
#'
#' # Filter by pattern
#' pal_show(pattern = "^nord")
#' pal_show(pattern = "ggsci")
#' pal_show(pattern = "hcl")
#'
#' # Filter by type
#' pal_show(type = "discrete", index = 1:10)
#' pal_show(type = "continuous", index = 1:10)
#'
#' # Combine filters
#' pal_show(pattern = "Blues", type = "continuous")
#' pal_show(pattern = "^carto", type = "discrete")
#'
#' # ggplot output (colour bars in Plots pane)
#' pal_show(c("lancet", "ditto", "polychrome", "igv"), output = "gg")
#' pal_show(pattern = "^viridis|^magma|^plasma", output = "gg")
#'
#' # Browse all palettes from a source
#' pal_show(pattern = "^dichromat")
#' pal_show(pattern = "^pals")
#'
#' @export
#' @family colour palettes
pal_show <- function(palette = NULL, pattern = NULL,
                     type = c("all", "discrete", "continuous"),
                     max_colors = 20, index = NULL,
                     output = c("gt", "gg")) {
  type <- match.arg(type)
  output <- match.arg(output)
  pals <- palette_list

  # --- Filter palettes ---
  if (!is.null(palette)) {
    valid <- palette[palette %in% names(pals)]
    if (length(valid) == 0) cli::cli_abort("No matching palettes found.")
    pals <- pals[valid]
  } else {
    if (type != "all") {
      pals <- pals[vapply(pals, function(x) identical(attr(x, "type"), type), logical(1))]
    }
    if (!is.null(pattern)) {
      pals <- pals[grep(pattern, names(pals), ignore.case = TRUE)]
    }
  }
  if (length(pals) == 0) cli::cli_abort("No palettes matched the filters.")

  # Apply index
  if (!is.null(index)) {
    index <- index[index <= length(pals) & index >= 1]
    pals <- pals[index]
  }

  # --- ggplot output ---
  if (output == "gg") {
    plot_data <- do.call(rbind, lapply(seq_along(pals), function(i) {
      nm <- names(pals)[i]
      cols <- pals[[nm]]
      n <- min(length(cols), max_colors)
      cols <- cols[seq_len(n)]
      data.frame(palette = nm, color = cols, x = seq_len(n),
                 stringsAsFactors = FALSE)
    }))
    plot_data$palette <- factor(plot_data$palette, levels = rev(names(pals)))

    p <- ggplot2::ggplot(plot_data, ggplot2::aes(
      x = .data[["x"]], y = .data[["palette"]], fill = I(.data[["color"]]))) +
      ggplot2::geom_tile(width = 1, height = 0.8) +
      ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0)) +
      ggplot2::labs(x = NULL, y = NULL, title = sprintf("%d palettes", length(pals))) +
      ggplot2::theme_minimal(base_size = 10) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        panel.grid = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(hjust = 0.5, size = 12)
      )
    print(p)
    return(invisible(p))
  }

  # --- gt table output ---
  tbl_data <- data.frame(
    palette = names(pals),
    type = vapply(pals, function(x) attr(x, "type") %||% "?", character(1)),
    n_colors = vapply(pals, length, integer(1)),
    preview = vapply(pals, function(cols) {
      n <- min(length(cols), max_colors)
      cols <- cols[seq_len(n)]
      spans <- vapply(cols, function(c) {
        sprintf('<span style="background:%s;color:%s;padding:0 3px;">&nbsp;</span>', c, c)
      }, character(1))
      paste(spans, collapse = "")
    }, character(1)),
    stringsAsFactors = FALSE
  )

  tbl <- gt::gt(tbl_data) %>%
    gt::cols_label(
      palette = "Palette",
      type = "Type",
      n_colors = "N",
      preview = "Colours"
    ) %>%
    gt::fmt_markdown(columns = "preview") %>%
    gt::tab_header(
      title = gt::md(sprintf("**%d Palettes**", length(pals)))
    ) %>%
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) %>%
    gt::tab_style(
      style = gt::cell_fill(color = "#E8F4FD"),
      locations = gt::cells_column_labels()
    ) %>%
    gt::tab_options(
      table.font.size = gt::px(13),
      data_row.padding = gt::px(4),
      column_labels.padding = gt::px(6)
    ) %>%
    gt::cols_width(
      palette ~ gt::px(180),
      type ~ gt::px(80),
      n_colors ~ gt::px(40),
      preview ~ gt::px(400)
    )

  print(tbl)
  invisible(tbl)
}
