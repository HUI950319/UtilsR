# ============================================================================
# color.R -- Colour palettes with console swatch display
# ============================================================================

#' Built-in Palette Collection
#'
#' A named list of 256 colour palettes from RColorBrewer, ggsci, viridis,
#' rcartocolor, nord, dichromat, pals, colorspace, and UtilsR built-in.
#' Each element is a character vector of hex colours with a \code{"type"}
#' attribute (\code{"discrete"} or \code{"continuous"}).
#'
#' @format A named list of 256 character vectors.
#' @examples
#' length(palette_list)
#' names(palette_list)[1:10]
#' @name palette_list
NULL

#' Create a colour palette object
#'
#' Returns a plain character vector of colours (no S3 class).
#' Use \code{show_color()} to display coloured swatches in the console.
#'
#' @param x Character vector of colours (hex codes or named R colours).
#' @return A character vector of colours.
#'
#' @examples
#' p <- as_palette(c("#FF0000", "#00FF00", "#0000FF"))
#' p
#' show_color(p)
#'
#' @export
#' @family colour palettes
as_palette <- function(x) {
  if (!is.character(x)) {
    cli::cli_abort("{.arg x} must be a character vector of colours, got {.cls {class(x)}}.")
  }
  nms <- names(x)
  out <- as.character(x)
  if (!is.null(nms)) names(out) <- nms
  out
}

# -- vctrs compatibility (ggplot2 uses vctrs internally) ----------------------
# Allow seamless conversion between palette and character so that
# scale_*_manual(values = pal_lancet) works without error.


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

#' Parathyroid Single-Cell Colour Palette
#'
#' A 16-colour named palette for parathyroid single-cell atlas cell types,
#' including immune, stromal, and endothelial lineages.
#'
#' @format A named character vector of 16 hex colour codes.
#'
#' @examples
#' pal_paraSC
#' show_color(pal_paraSC)
#'
#' @export
#' @family colour palettes
pal_paraSC <- as_palette(c(
  "Parathyroid cells"      = "#8B1A1A",
  "T cells"                = "#56B4E9FF",
  "Cycling T cells"        = "#8B5E3C",
  "NK cells"               = "#2E8B45",
  "B cells"                = "#1A7B7B",
  "Monocytes"              = "#7B68AA",
  "M1-like Macrophages"    = "#D4919A",
  "M2/M3-like Macrophages" = "#F0C8A0",
  "Neutrophils"            = "#C0C0C0",
  "cDC2s"                  = "#282828",
  "Mast cells"             = "#F0E442FF",
  "iTAFs"                  = "#9AB83C",
  "mTAFs"                  = "#E07B1A",
  "Pericytes"              = "#6B3FA0",
  "Capillary ECs"          = "#D4C8E8",
  "Venous ECs"             = "#8AAAC8"
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

#' Visualise Palettes or Colour Vectors
#'
#' Display palettes as horizontal colour bars (ggplot) or an interactive
#' gt table with colour swatches. Use \code{output = "gg"} for the Plots
#' pane or \code{output = "gt"} for the Viewer pane.
#'
#' When \code{palette} is a character vector of valid colour specifications
#' (hex codes like \code{"#FF0000"} or named R colours like \code{"red"})
#' rather than palette names, the function automatically switches to
#' \strong{colour vector mode}: it displays the colours directly as a
#' single-row colour bar (ggplot) with hex labels, similar to
#' \code{show_color()} but as a publication-ready plot.
#'
#' @param palette Character vector of palette names (e.g. \code{"lancet"}),
#'   a colour vector (hex codes or named colours), or \code{NULL} to show
#'   all palettes matching \code{pattern}/\code{type}. Named colour vectors
#'   (e.g. \code{pal_paraSC}) will use the names as labels.
#' @param pattern Regex pattern to filter palette names (e.g. \code{"^nord"}).
#' @param type Filter by type: \code{"all"}, \code{"discrete"}, or
#'   \code{"continuous"}.
#' @param max_colors Maximum colours to display per palette. Default 20.
#' @param index Integer vector of palette indices to show (after filtering).
#' @param output Output format: \code{"gg"} (default) for ggplot or
#'   \code{"gt"} for gt table.
#' @param label Logical. In colour vector mode, whether to show hex/name
#'   labels on tiles. Default \code{TRUE}.
#' @param label_size Numeric. Text size for labels in colour vector mode.
#'   Default 3.
#' @param ncol Integer. Number of columns for colour vector mode when
#'   displaying many colours. Default \code{NULL} (auto: single row if
#'   \eqn{\le 20}{<= 20} colours, otherwise wrap).
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
#' # --- Colour vector mode ---
#' # Show a named colour vector (e.g. pal_paraSC)
#' pal_show(pal_paraSC)
#'
#' # Show any colour vector
#' pal_show(c("#FF0000", "#00FF00", "#0000FF"))
#' pal_show(rainbow(12))
#'
#' # Without labels
#' pal_show(pal_lancet, label = FALSE)
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
                     output = c("gt", "gg"),
                     label = TRUE, label_size = 3, ncol = NULL) {
  type <- match.arg(type)
  output <- match.arg(output)

  # --- Detect colour vector mode ---
  # If palette is a character vector and looks like colours (not palette names),

  # switch to colour vector display mode.
  if (!is.null(palette) && is.character(palette) && length(palette) > 0) {
    is_color_vec <- .is_color_vector(palette)
    if (is_color_vec) {
      return(.pal_show_colors(palette, label = label,
                              label_size = label_size, ncol = ncol,
                              output = output, max_colors = max_colors))
    }
  }

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

# ------------- Internal helpers for pal_show colour vector mode ---------------

#' Check if a character vector looks like colours (not palette names)
#' @keywords internal
#' @noRd
.is_color_vector <- function(x) {
  if (length(x) == 0) return(FALSE)
  # Check: are these valid R colours? (hex codes or named colours)
  # First check if ANY of them are palette names
  n_palette_match <- sum(x %in% names(palette_list))
  # If most entries match palette names, treat as palette name mode
  if (n_palette_match > length(x) / 2) return(FALSE)
  # Try to parse as colours
  valid <- vapply(x, function(cc) {
    tryCatch({
      grDevices::col2rgb(cc)
      TRUE
    }, error = function(e) FALSE)
  }, logical(1), USE.NAMES = FALSE)
  # If all are valid colours and none are palette names, it's a colour vector
  all(valid) && n_palette_match == 0
}

#' Display a colour vector as ggplot or gt (internal)
#' @keywords internal
#' @noRd
.pal_show_colors <- function(colors, label = TRUE, label_size = 3,
                             ncol = NULL, output = "gg",
                             max_colors = 50) {
  n <- length(colors)
  # Truncate if too many
  if (n > max_colors) {
    cli::cli_inform("Showing first {max_colors} of {n} colours.")
    colors <- colors[seq_len(max_colors)]
    n <- max_colors
  }

  # Get labels: use names if available, otherwise hex codes
  color_names <- names(colors)
  hex <- vapply(colors, function(cc) {
    rgb_mat <- grDevices::col2rgb(cc)
    grDevices::rgb(rgb_mat[1], rgb_mat[2], rgb_mat[3], maxColorValue = 255)
  }, character(1), USE.NAMES = FALSE)

  if (!is.null(color_names) && all(nzchar(color_names))) {
    labels <- color_names
  } else {
    labels <- hex
  }

  # Compute luminance for text contrast
  .luminance <- function(hex_col) {
    r <- strtoi(substr(hex_col, 2, 3), 16L) / 255
    g <- strtoi(substr(hex_col, 4, 5), 16L) / 255
    b <- strtoi(substr(hex_col, 6, 7), 16L) / 255
    lin <- function(v) ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
  }
  fg_colors <- ifelse(vapply(hex, .luminance, numeric(1)) > 0.179,
                       "#000000", "#FFFFFF")

  # --- ggplot output ---
  if (output == "gg") {
    # Determine grid layout
    if (is.null(ncol)) {
      ncol <- if (n <= 20) n else ceiling(sqrt(n * 2))
    }
    nrow <- ceiling(n / ncol)

    plot_data <- data.frame(
      color = as.character(colors),
      hex = hex,
      label = labels,
      fg = fg_colors,
      col_idx = ((seq_len(n) - 1) %% ncol) + 1,
      row_idx = -((seq_len(n) - 1) %/% ncol),
      stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(plot_data, ggplot2::aes(
      x = .data[["col_idx"]], y = .data[["row_idx"]])) +
      ggplot2::geom_tile(ggplot2::aes(fill = I(.data[["hex"]])),
                         width = 0.95, height = 0.85,
                         color = "grey80", linewidth = 0.3) +
      ggplot2::scale_x_continuous(
        expand = ggplot2::expansion(mult = 0.02)) +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = 0.05)) +
      ggplot2::labs(x = NULL, y = NULL,
                    title = sprintf("%d colours", n)) +
      ggplot2::theme_void(base_size = 10) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(hjust = 0.5, size = 12,
                                           margin = ggplot2::margin(b = 8)),
        plot.margin = ggplot2::margin(10, 10, 10, 10)
      )

    if (label) {
      # Show name/hex on top, hex on bottom (if named)
      if (!is.null(color_names) && all(nzchar(color_names))) {
        p <- p +
          ggplot2::geom_text(ggplot2::aes(label = .data[["label"]]),
                             color = fg_colors, size = label_size,
                             fontface = "bold", vjust = -0.3) +
          ggplot2::geom_text(ggplot2::aes(label = .data[["hex"]]),
                             color = fg_colors, size = label_size * 0.75,
                             vjust = 1.2)
      } else {
        p <- p +
          ggplot2::geom_text(ggplot2::aes(label = .data[["label"]]),
                             color = fg_colors, size = label_size,
                             fontface = "bold")
      }
    }

    print(p)
    return(invisible(p))
  }

  # --- gt table output ---
  tbl_data <- data.frame(
    index = seq_len(n),
    name = labels,
    hex = hex,
    preview = vapply(hex, function(h) {
      fg <- if (.luminance(h) > 0.179) "#000000" else "#FFFFFF"
      sprintf('<span style="background:%s;color:%s;padding:2px 10px;border-radius:3px;font-weight:bold;">%s</span>',
              h, fg, h)
    }, character(1), USE.NAMES = FALSE),
    stringsAsFactors = FALSE
  )

  # If no names, drop the name column
  if (is.null(color_names) || !all(nzchar(color_names))) {
    tbl_data$name <- NULL
    tbl <- gt::gt(tbl_data) %>%
      gt::cols_label(index = "#", hex = "Hex", preview = "Preview")
  } else {
    tbl <- gt::gt(tbl_data) %>%
      gt::cols_label(index = "#", name = "Name", hex = "Hex", preview = "Preview")
  }

  tbl <- tbl %>%
    gt::fmt_markdown(columns = "preview") %>%
    gt::tab_header(title = gt::md(sprintf("**%d Colours**", n))) %>%
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
      data_row.padding = gt::px(3),
      column_labels.padding = gt::px(6)
    )

  print(tbl)
  invisible(tbl)
}
