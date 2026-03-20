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

#' IGV Default Colour Palette
#'
#' A 48-colour palette from the Integrative Genomics Viewer (IGV).
#' The largest built-in palette, suitable for datasets with many clusters.
#'
#' @format A \code{palette} object (character vector of 48 hex colour codes).
#' @source \url{https://github.com/nanxstats/ggsci}
#' @examples
#' pal_igv
#' @export
#' @family colour palettes
pal_igv <- as_palette(c(
  "#5050FF", "#CE3D32", "#749B58", "#F0E685", "#466983", "#BA6338",
  "#5DB1DD", "#802268", "#6BD76B", "#D595A7", "#924822", "#837B8D",
  "#C75127", "#D58F5C", "#7A65A5", "#E4AF69", "#3B1B53", "#CDDEB7",
  "#612A79", "#AE1F63", "#E7C76F", "#5A655E", "#CC9900", "#99CC00",
  "#33CC00", "#00CC33", "#00CC99", "#0099CC", "#0A47FF", "#4775FF",
  "#FFC20A", "#FFD147", "#990033", "#991A00", "#996600", "#809900",
  "#339900", "#00991A", "#009966", "#008099", "#003399", "#1A0099",
  "#660099", "#990080", "#D60047", "#FF1463", "#00D68F", "#14FFB1"
))

#' dittoSeq Colour Palette
#'
#' A 40-colour palette from the dittoSeq package, widely used in
#' single-cell RNA-seq publications for cluster visualisation.
#'
#' @format A \code{palette} object (character vector of 40 hex colour codes).
#' @source \url{https://github.com/dtm2451/dittoSeq}
#' @examples
#' pal_ditto
#' @export
#' @family colour palettes
pal_ditto <- as_palette(c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
  "#CC79A7", "#666666", "#AD7700", "#1C91D4", "#007756", "#D5C711",
  "#005685", "#A04700", "#B14380", "#4D4D4D", "#FFBE2D", "#80C7EF",
  "#00F6B3", "#F4EB71", "#06A5FF", "#FF8320", "#D99BBD", "#8C8C8C",
  "#FFCB57", "#9AD2F2", "#2CFFC6", "#F6EF8E", "#38B7FF", "#FF9B4D",
  "#E0AFCA", "#A3A3A3", "#8A5F00", "#1674A9", "#005F45", "#AA9F0D",
  "#00446B", "#803800", "#8D3666", "#3D3D3D"
))

#' Polychrome Colour Palette
#'
#' A 36-colour palette designed for maximal perceptual distinctness
#' in CIE L*u*v* colour space. Excellent for single-cell cluster
#' visualisation with many subpopulations.
#'
#' @format A \code{palette} object (character vector of 36 hex colour codes).
#' @source \url{https://CRAN.R-project.org/package=pals}
#' @examples
#' pal_polychrome
#' @export
#' @family colour palettes
pal_polychrome <- as_palette(c(
  "#5A5156", "#E4E1E3", "#F6222E", "#FE00FA", "#16FF32", "#3283FE",
  "#FEAF16", "#B00068", "#1CFFCE", "#90AD1C", "#2ED9FF", "#DEA0FD",
  "#AA0DFE", "#F8A19F", "#325A9B", "#C4451C", "#1C8356", "#85660D",
  "#B10DA1", "#FBE426", "#1CBE4F", "#FA0087", "#FC1CBF", "#F7E1A0",
  "#C075A6", "#782AB6", "#AAF400", "#BDCDFF", "#822E1C", "#B5EFB5",
  "#7ED7D1", "#1C7F93", "#D85FF7", "#683B79", "#66B0FF", "#3B00FB"
))

#' Glasbey Colour Palette
#'
#' A 32-colour palette based on the Glasbey algorithm for maximally
#' distinct colours. Useful for datasets with many categorical groups.
#'
#' @format A \code{palette} object (character vector of 32 hex colour codes).
#' @source \url{https://CRAN.R-project.org/package=pals}
#' @examples
#' pal_glasbey
#' @export
#' @family colour palettes
pal_glasbey <- as_palette(c(
  "#0000FF", "#FF0000", "#00FF00", "#000033", "#FF00B6", "#005300",
  "#FFD300", "#009FFF", "#9A4D42", "#00FFBE", "#783FC1", "#1F9698",
  "#FFACFD", "#B1CC71", "#F1085C", "#FE8F42", "#DD00FF", "#201A01",
  "#720055", "#766C95", "#02AD24", "#C8FF00", "#886C00", "#FFB79F",
  "#858567", "#A10300", "#14F9FF", "#00469E", "#DC5E93", "#93D4FF",
  "#004CFF", "#F2F318"
))

#' Alphabet Colour Palette
#'
#' A 26-colour palette (Green-Armytage, A-Z) designed for
#' maximal visual distinctness.
#'
#' @format A \code{palette} object (character vector of 26 hex colour codes).
#' @source \url{https://CRAN.R-project.org/package=pals}
#' @examples
#' pal_alphabet
#' @export
#' @family colour palettes
pal_alphabet <- as_palette(c(
  "#F0A0FF", "#0075DC", "#993F00", "#4C005C", "#191919", "#005C31",
  "#2BCE48", "#FFCC99", "#808080", "#94FFB5", "#8F7C00", "#9DCC00",
  "#C20088", "#003380", "#FFA405", "#FFA8BB", "#426600", "#FF0010",
  "#5EF1F2", "#00998F", "#E0FF66", "#740AFF", "#990000", "#FFFF80",
  "#FFE100", "#FF5005"
))

#' UCSC Genome Browser Colour Palette
#'
#' A 26-colour palette from the UCSC Genome Browser.
#'
#' @format A \code{palette} object (character vector of 26 hex colour codes).
#' @source \url{https://github.com/nanxstats/ggsci}
#' @examples
#' pal_ucsc
#' @export
#' @family colour palettes
pal_ucsc <- as_palette(c(
  "#FF0000", "#FF9900", "#FFCC00", "#00FF00", "#6699FF", "#CC33FF",
  "#99991E", "#999999", "#FF00CC", "#CC0000", "#FFCCCC", "#FFFF00",
  "#CCFF00", "#358000", "#0000CC", "#99CCFF", "#00FFFF", "#CCFFFF",
  "#9900CC", "#CC99FF", "#996600", "#666600", "#666666", "#CCCCCC",
  "#79CC3D", "#CCCC99"
))

#' Kelly Colour Palette
#'
#' Kelly's 22 maximally contrasting colours.
#'
#' @format A \code{palette} object (character vector of 22 hex colour codes).
#' @source Kelly, K.L. (1965) Twenty-two colors of maximum contrast.
#' @examples
#' pal_kelly
#' @export
#' @family colour palettes
pal_kelly <- as_palette(c(
  "#F2F3F4", "#222222", "#F3C300", "#875092", "#F38400", "#A1CAF1",
  "#BE0032", "#C2B280", "#848482", "#008856", "#E68FAC", "#0067A5",
  "#F99379", "#604E97", "#F6A600", "#B3286E", "#DCD300", "#882D17",
  "#8DB600", "#654321", "#E25822", "#2B3D26"
))

#' D3 Category20 Colour Palette
#'
#' A 20-colour palette from D3.js, widely used in data visualisation.
#'
#' @format A \code{palette} object (character vector of 20 hex colour codes).
#' @source \url{https://github.com/d3/d3-scale-chromatic}
#' @examples
#' pal_d3
#' @export
#' @family colour palettes
pal_d3 <- as_palette(c(
  "#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD", "#8C564B",
  "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF", "#AEC7E8", "#FFBB78",
  "#98DF8A", "#FF9896", "#C5B0D5", "#C49C94", "#F7B6D2", "#C7C7C7",
  "#DBDB8D", "#9EDAE5"
))

#' Simpsons Colour Palette
#'
#' A 16-colour palette inspired by \emph{The Simpsons} (ggsci).
#'
#' @format A \code{palette} object (character vector of 16 hex colour codes).
#' @source \url{https://github.com/nanxstats/ggsci}
#' @examples
#' pal_simpsons
#' @export
#' @family colour palettes
pal_simpsons <- as_palette(c(
  "#FED439", "#709AE1", "#8A9197", "#D2AF81", "#FD7446", "#D5E4A2",
  "#197EC0", "#F05C3B", "#46732E", "#71D0F5", "#370335", "#075149",
  "#C80813", "#91331F", "#1A9993", "#FD8CC1"
))

#' Trubetskoy Colour Palette
#'
#' A 20-colour palette by Sascha Trubetskoy for distinct categorical
#' data visualisation (black and white excluded).
#'
#' @format A \code{palette} object (character vector of 20 hex colour codes).
#' @examples
#' pal_trubetskoy
#' @export
#' @family colour palettes
pal_trubetskoy <- as_palette(c(
  "#E6194B", "#3CB44B", "#FFE119", "#4363D8", "#F58231", "#911EB4",
  "#42D4F4", "#F032E6", "#BFEF45", "#FABED4", "#469990", "#DCBEFF",
  "#9A6324", "#FFFAC8", "#800000", "#AAFFC3", "#808000", "#FFD8B1",
  "#000075", "#A9A9A9"
))

#' List All Available Palettes
#'
#' Print all built-in palette names and their colour counts.
#'
#' @param show Logical, if \code{TRUE} (default) also display colour swatches.
#' @return Invisibly returns a named list of all palettes.
#'
#' @examples
#' pal_list(show = FALSE)
#'
#' @export
#' @family colour palettes
pal_list <- function(show = TRUE) {
  ns <- asNamespace("UtilsR")
  all_names <- sort(ls(ns, pattern = "^pal_"))
  pals <- mget(all_names, envir = ns)
  for (nm in names(pals)) {
    cat(sprintf("\n=== %s (%d colours) ===\n", nm, length(pals[[nm]])))
    if (show) show_color(pals[[nm]])
  }
  invisible(pals)
}
