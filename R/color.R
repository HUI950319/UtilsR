# =============================================================================
# color.R -- Colour palettes with console / ggplot swatch display
# =============================================================================
#
# Architecture (3 layers):
#
#   L0  palette data (plain objects, not functions)
#         palette_list  -- 260 named palettes, each with a "type" attribute
#         pal_lancet / pal_bar / pal_paraSC / pal_other / pal_heat
#
#   L1  lookup + extraction                         -- public API
#         pal_list(pattern, type)   browse palette_list
#               +-- L2  .pal_match_pattern() validate and match name filters
#               +-- L2  .pal_print_heading() retain full console palette names
#         pal_get(palette, n, x, reverse, alpha)    NULL | name | colours -> hex
#               +-- L2  .pal_apply()    recycle / interpolate / alpha
#               +-- L2  .pal_use_unique()    estimate useful numeric repetition
#
#   L1  visual catalogues                           -- public API
#         pal_show_brewer / pal_show_hcl / pal_show_ggsci / pal_show_viridis
#               +-- pal_show(palette, n, pattern)   shared display backend
#               +-- L2  .pal_validate_palette() validate input storage/colours
#               +-- L2  .pal_validate_show() validate counts, indices and layout
#               +-- L2  .is_color_vector()   colours vs palette names
#                     +-- L3  .pal_are_colors() validate literal colours in bulk
#               +-- L2  .pal_resize()       sample only the displayed colours
#               +-- L2  .pal_preview_indices() select native preview positions
#               +-- L2  .pal_hcl_preview()  evaluate native HCL parameters
#               +-- L2  .pal_viridis_preview() evaluate the native colour spline
#               +-- L2  .pal_show_gg()      render catalogue in a small frame
#               +-- L2  .pal_format_preview() pass generated HTML through gt
#               +-- L2  .pal_show_colors()   render swatches (ggplot | gt)
#               +-- L2  .pal_hex()           normalize R colours for display
# =============================================================================

#' Built-in Palette Collection
#'
#' A named list of 260 colour palettes from RColorBrewer, ggsci, viridis,
#' rcartocolor, nord, dichromat, pals, colorspace, and UtilsR built-in.
#' Each element is a character vector of hex colours with a \code{"type"}
#' attribute (\code{"discrete"} or \code{"continuous"}).
#'
#' @format A named list of 260 character vectors.
#' @examples
#' length(palette_list)
#' names(palette_list)[1:10]
#' @name palette_list
NULL

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
pal_lancet <- c(
  "#00468BFF", "#ED0000FF", "#42B540FF", "#0099B4FF", "#925E9FFF",
  "#FDAF91FF", "#AD002AFF", "#ADB6B6FF", "#1B1919FF", "#79AF97FF",
  "#DF8F44FF", "#6A6599FF", "#FCCDE5FF", "#80B1D3FF", "#0000FFFF"
)

#' Bar Colour Palette
#'
#' A 10-colour palette for categorical bar and radial outer-layer
#' visualisations.
#'
#' @format A character vector of 10 hex colour codes.
#'
#' @examples
#' pal_bar
#' show_color(pal_bar)
#'
#' @export
#' @family colour palettes
pal_bar <- c(
  "#f76502", "#f41237", "#026026", "#2f0d06", "#0372e9",
  "#f00a0b", "#2e3426", "#dea34a", "#aa1f19", "#5728a0"
)

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
pal_paraSC <- c(
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
)

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
  igv = c(
    "#5050FF", "#CE3D32", "#749B58", "#F0E685", "#466983", "#BA6338",
    "#5DB1DD", "#802268", "#6BD76B", "#D595A7", "#924822", "#837B8D",
    "#C75127", "#D58F5C", "#7A65A5", "#E4AF69", "#3B1B53", "#CDDEB7",
    "#612A79", "#AE1F63", "#E7C76F", "#5A655E", "#CC9900", "#99CC00",
    "#33CC00", "#00CC33", "#00CC99", "#0099CC", "#0A47FF", "#4775FF",
    "#FFC20A", "#FFD147", "#990033", "#991A00", "#996600", "#809900",
    "#339900", "#00991A", "#009966", "#008099", "#003399", "#1A0099",
    "#660099", "#990080", "#D60047", "#FF1463", "#00D68F", "#14FFB1"
  ),
  ditto = c(
    "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
    "#CC79A7", "#666666", "#AD7700", "#1C91D4", "#007756", "#D5C711",
    "#005685", "#A04700", "#B14380", "#4D4D4D", "#FFBE2D", "#80C7EF",
    "#00F6B3", "#F4EB71", "#06A5FF", "#FF8320", "#D99BBD", "#8C8C8C",
    "#FFCB57", "#9AD2F2", "#2CFFC6", "#F6EF8E", "#38B7FF", "#FF9B4D",
    "#E0AFCA", "#A3A3A3", "#8A5F00", "#1674A9", "#005F45", "#AA9F0D",
    "#00446B", "#803800", "#8D3666", "#3D3D3D"
  ),
  polychrome = c(
    "#5A5156", "#E4E1E3", "#F6222E", "#FE00FA", "#16FF32", "#3283FE",
    "#FEAF16", "#B00068", "#1CFFCE", "#90AD1C", "#2ED9FF", "#DEA0FD",
    "#AA0DFE", "#F8A19F", "#325A9B", "#C4451C", "#1C8356", "#85660D",
    "#B10DA1", "#FBE426", "#1CBE4F", "#FA0087", "#FC1CBF", "#F7E1A0",
    "#C075A6", "#782AB6", "#AAF400", "#BDCDFF", "#822E1C", "#B5EFB5",
    "#7ED7D1", "#1C7F93", "#D85FF7", "#683B79", "#66B0FF", "#3B00FB"
  ),
  glasbey = c(
    "#0000FF", "#FF0000", "#00FF00", "#000033", "#FF00B6", "#005300",
    "#FFD300", "#009FFF", "#9A4D42", "#00FFBE", "#783FC1", "#1F9698",
    "#FFACFD", "#B1CC71", "#F1085C", "#FE8F42", "#DD00FF", "#201A01",
    "#720055", "#766C95", "#02AD24", "#C8FF00", "#886C00", "#FFB79F",
    "#858567", "#A10300", "#14F9FF", "#00469E", "#DC5E93", "#93D4FF",
    "#004CFF", "#F2F318"
  ),
  alphabet = c(
    "#F0A0FF", "#0075DC", "#993F00", "#4C005C", "#191919", "#005C31",
    "#2BCE48", "#FFCC99", "#808080", "#94FFB5", "#8F7C00", "#9DCC00",
    "#C20088", "#003380", "#FFA405", "#FFA8BB", "#426600", "#FF0010",
    "#5EF1F2", "#00998F", "#E0FF66", "#740AFF", "#990000", "#FFFF80",
    "#FFE100", "#FF5005"
  ),
  ucsc = c(
    "#FF0000", "#FF9900", "#FFCC00", "#00FF00", "#6699FF", "#CC33FF",
    "#99991E", "#999999", "#FF00CC", "#CC0000", "#FFCCCC", "#FFFF00",
    "#CCFF00", "#358000", "#0000CC", "#99CCFF", "#00FFFF", "#CCFFFF",
    "#9900CC", "#CC99FF", "#996600", "#666600", "#666666", "#CCCCCC",
    "#79CC3D", "#CCCC99"
  ),
  kelly = c(
    "#F2F3F4", "#222222", "#F3C300", "#875092", "#F38400", "#A1CAF1",
    "#BE0032", "#C2B280", "#848482", "#008856", "#E68FAC", "#0067A5",
    "#F99379", "#604E97", "#F6A600", "#B3286E", "#DCD300", "#882D17",
    "#8DB600", "#654321", "#E25822", "#2B3D26"
  ),
  d3 = c(
    "#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD", "#8C564B",
    "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF", "#AEC7E8", "#FFBB78",
    "#98DF8A", "#FF9896", "#C5B0D5", "#C49C94", "#F7B6D2", "#C7C7C7",
    "#DBDB8D", "#9EDAE5"
  ),
  simpsons = c(
    "#FED439", "#709AE1", "#8A9197", "#D2AF81", "#FD7446", "#D5E4A2",
    "#197EC0", "#F05C3B", "#46732E", "#71D0F5", "#370335", "#075149",
    "#C80813", "#91331F", "#1A9993", "#FD8CC1"
  ),
  trubetskoy = c(
    "#E6194B", "#3CB44B", "#FFE119", "#4363D8", "#F58231", "#911EB4",
    "#42D4F4", "#F032E6", "#BFEF45", "#FABED4", "#469990", "#DCBEFF",
    "#9A6324", "#FFFAC8", "#800000", "#AAFFC3", "#808000", "#FFD8B1",
    "#000075", "#A9A9A9"
  )
)

#' Diverging Heatmap Fill Palettes
#'
#' Eleven five-colour diverging gradients for correlation-style heatmaps,
#' each running from the most negative value through white to the most
#' positive. They are the fill combinations of a published correlation
#' heatmap figure; \code{blue_red} is ColorBrewer \code{RdBu} (7 classes,
#' reversed) with a pure white midpoint in place of its grey one, and the
#' others come from the Material Design, Tailwind and Flat UI colour systems.
#'
#' Unlike the categorical palettes here, these are meant to be interpolated:
#' pass one to \code{ggplot2::scale_fill_gradientn()} or
#' \code{grDevices::colorRampPalette()} rather than mapping the five colours
#' to five levels.
#'
#' @format A named list of 11 character vectors, 5 hex colours each, named by
#'   the two hues each gradient runs between:
#'   \describe{
#'     \item{blue_red}{blue to red (ColorBrewer RdBu)}
#'     \item{teal_pink}{deep teal to magenta}
#'     \item{slate_red}{midnight slate to dark red (Flat UI)}
#'     \item{purple_gold}{deep purple to bronze}
#'     \item{steel_rose}{steel blue to wine}
#'     \item{navy_scarlet}{navy to scarlet}
#'     \item{green_orange}{forest green to burnt orange}
#'     \item{purple_teal}{purple to teal (Material Design)}
#'     \item{olive_violet}{olive to indigo}
#'     \item{slate_crimson}{slate to crimson (Tailwind)}
#'     \item{indigo_gold}{indigo to gold}
#'   }
#'
#' @examples
#' names(pal_heat)
#' pal_heat$blue_red
#' show_color(pal_heat$purple_teal)
#'
#' # interpolated over a continuous fill scale
#' ggplot2::scale_fill_gradientn(colours = pal_heat$slate_crimson,
#'                               limits = c(-1, 1))
#'
#' @export
#' @family colour palettes
pal_heat <- list(
  blue_red      = c("#2166ac", "#67a9cf", "#ffffff", "#ef8a62", "#b2182b"),
  teal_pink     = c("#0c4b61", "#48b79d", "#ffffff", "#e888a4", "#9d2454"),
  slate_red     = c("#2c3d50", "#808c8d", "#ffffff", "#e74d3d", "#762820"),
  purple_gold   = c("#381a4e", "#744c8c", "#ffffff", "#deab5a", "#9c661a"),
  steel_rose    = c("#204053", "#3e6b7a", "#ffffff", "#df6376", "#8c104e"),
  navy_scarlet  = c("#1c3044", "#4189c5", "#ffffff", "#d00102", "#66010e"),
  green_orange  = c("#174e33", "#4bba79", "#ffffff", "#ed8a37", "#7f3621"),
  purple_teal   = c("#4a148c", "#8e25aa", "#ffffff", "#27a69a", "#004c3f"),
  olive_violet  = c("#566b31", "#90bc90", "#ffffff", "#ba56d3", "#4a0082"),
  slate_crimson = c("#1e293b", "#65758b", "#ffffff", "#f4405f", "#881337"),
  indigo_gold   = c("#1a1464", "#4a4590", "#ffffff", "#fbc532", "#e0b02c")
)

#' List Registered Palettes
#'
#' Browse palettes from the built-in collection (260 palettes from
#' RColorBrewer, ggsci, viridis, rcartocolor, nord, dichromat, pals,
#' colorspace, and UtilsR built-in). Use \code{pattern} to filter.
#' Prints palette headings and optional swatches in the console. For a gt table
#' or ggplot preview, use \code{\link{pal_show}()}.
#'
#' @details Only palettes in \code{\link{palette_list}} are listed. Separate
#'   collections such as \code{\link{pal_heat}} and unregistered entries of
#'   \code{\link{pal_other}} are accessed directly rather than by registry name.
#'
#'   Palette names are kept in full on narrow consoles. Colour counts and types
#'   move to a separate line when they do not fit in a heading.
#'
#' @param pattern Single non-missing regex string to filter palette names,
#'   ignoring case. Default \code{NULL} shows all.
#' @param type Filter by type: \code{"all"} (default), \code{"discrete"},
#'   or \code{"continuous"}.
#' @param show Single non-missing logical; if \code{TRUE} (default) display
#'   colour swatches. \code{FALSE} prints palette headings only.
#' @return Invisibly returns a named list of matching palettes. If no palettes
#'   match, the function emits a message and returns an empty list invisibly.
#'
#' @examples
#' pal_list(pattern = "^Blues", show = FALSE)
#' pal_list(pattern = "^Blues")
#' pal_list(type = "discrete", pattern = "nord")
#'
#' @export
#' @family colour palettes
pal_list <- function(pattern = NULL, type = c("all", "discrete", "continuous"),
                     show = TRUE) {
  if ((!isTRUE(show) && !isFALSE(show)) || !is.null(dim(show))) {
    cli::cli_abort("{.arg show} must be a single non-missing logical value.")
  }
  type <- match.arg(type)
  # Explicit namespace lookup (LazyData not auto-loaded under `::`).
  pals <- getExportedValue("UtilsR", "palette_list")
  # Filter by pattern
  if (!is.null(pattern)) {
    pals <- pals[.pal_match_pattern(pattern, names(pals))]
  }
  # Filter by type
  if (type != "all") {
    pals <- pals[vapply(pals, function(x) identical(attr(x, "type"), type), logical(1))]
  }
  if (length(pals) == 0) {
    cli::cli_inform("No palettes matched.")
    return(invisible(list()))
  }
  for (nm in names(pals)) {
    tp <- attr(pals[[nm]], "type") %||% "?"
    cat("\n")
    .pal_print_heading(nm, length(pals[[nm]]), tp)
    if (show) show_color(pals[[nm]])
  }
  invisible(pals)
}

.pal_print_heading <- function(name, n, type) {
  title <- sprintf("%s (%s colours, %s)", name, n, type)
  if (nchar(._pr_escape(title), type = "width") <= min(console_width(), 80L) - 6L) {
    pr_section(title)
  } else {
    ._pr_out(._pr_escape(name))
    metadata <- sprintf("%s colours, %s", n, type)
    pr_note("{metadata}")
  }
}

.pal_match_pattern <- function(pattern, choices) {
  if (!is.character(pattern) || length(pattern) != 1L ||
      !is.null(dim(pattern)) || is.na(pattern)) {
    cli::cli_abort("{.arg pattern} must be a single non-missing regex string or {.code NULL}.")
  }
  tryCatch(
    suppressWarnings(grep(pattern, choices, ignore.case = TRUE)),
    error = function(err) {
      cli::cli_abort("{.arg pattern} must be a valid regular expression.", parent = err)
    }
  )
}

#' Get Colours from a Named Palette
#'
#' Retrieve colours from the built-in palette collection (260 palettes).
#' Supports discrete mapping (factor/character input) and continuous
#' interpolation (numeric input or \code{n} parameter).
#'
#' @param palette One of four things:
#'   \itemize{
#'     \item \code{NULL}: \code{pal_lancet}, the default colours of the plot
#'       functions;
#'     \item a palette name (e.g. \code{"Paired"}, \code{"viridis"},
#'       \code{"lancet"}); use \code{pal_list()} to see all available names;
#'     \item a colour vector, or a single literal colour (whatever R can draw,
#'       such as \code{"transparent"} or \code{"#F00"}), used as the palette
#'       itself -- a registered name always wins over a same-named colour, and
#'       a string that is neither still raises the usual "not found" error;
#'     \item a fully named list of colour vectors with unique names, such as
#'       \code{pal_heat}, mapped over one palette at a time.
#'   }
#'   Matrices, arrays and data frames are not supported. Colour vectors must
#'   have no dimensions.
#'   The literal string \code{"NA"} denotes R's transparent colour; actual
#'   missing colour values are not supported.
#' @param n Number of colours to return, a plain integer or double scalar with
#'   a whole-number value from zero to \code{.Machine$integer.max}, with no class
#'   or dimensions. Colours
#'   are taken from the front when \code{n} is at most the palette length and
#'   interpolated when it is longer. Default \code{NULL} returns all colours in
#'   the palette. When \code{x} is supplied, it determines the output and
#'   \code{n} is ignored after validation.
#' @param x Optional vector to map colours to. If character, factor or logical,
#'   returns a colour vector named by level: factor levels in their order, other
#'   values in order of appearance, missing values left out. If numeric, returns
#'   one colour per element, placed along the palette by its value between the
#'   finite extremes; missing and infinite values get \code{NA}, and a single
#'   distinct value takes the middle colour.
#'   \code{Date}, \code{POSIXct}, \code{POSIXlt} and \code{difftime} inputs
#'   use discrete character labels. For continuous time mapping, convert time
#'   values to a plain numeric vector explicitly. Other atomic types, such as
#'   complex and raw vectors, also use discrete labels.
#'   Distinct discrete values must produce unique character names; otherwise,
#'   convert them to explicit unique labels before mapping.
#'   Labelled vectors require \pkg{haven} to retain their missing values.
#'   \code{integer64} input is rejected to avoid loss of precision; recode it
#'   explicitly before mapping.
#'   Matrices, arrays, data frames, expressions, functions, environments and
#'   list containers other than \code{POSIXlt} timestamps are rejected.
#' @param reverse A logical scalar without a class or dimensions, reverse colour
#'   order. Default \code{FALSE}.
#' @param alpha A plain numeric scalar from 0 to 1 without a class or dimensions.
#'   Values below 1 replace existing transparency. Default 1 leaves colours as
#'   they are, keeping any transparency of their own.
#'
#' @return A character vector of R colours (hex codes or colour names), or --
#'   when \code{palette} is a list of palettes -- a list of such vectors under
#'   the same names. Literal colours retain their original spelling when no
#'   interpolation or alpha adjustment is needed.
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
#' pal_get("viridis", x = c(1, 100, 2))
#'
#' # Dates are discrete unless converted to numeric values explicitly
#' dates <- as.Date(c("2020-01-01", "2020-01-02"))
#' pal_get("lancet", x = dates)
#' pal_get("viridis", x = as.numeric(dates))
#'
#' # Reverse and transparent
#' pal_get("Blues", n = 5, reverse = TRUE, alpha = 0.6)
#' pal_get("NA", alpha = 0.5)
#'
#' # Colours of your own, and a whole list of palettes at once
#' pal_get(c("#2166ac", "#ffffff", "#b2182b"), n = 7)
#' pal_get(pal_heat$purple_teal, n = 7)
#' str(pal_get(pal_heat, n = 3))
#'
#' # Use in ggplot
#' # ggplot(df, aes(x, y, color = group)) +
#' #   scale_color_manual(values = pal_get("lancet", x = levels(df$group)))
#'
#' @export
#' @family colour palettes
pal_get <- function(palette = "Paired", n = NULL, x = NULL,
                    reverse = FALSE, alpha = 1) {
  if (!is.null(n) && !(is.numeric(n) && !is.complex(n) && !is.object(n) &&
                       is.null(dim(n)) && length(n) == 1L && is.finite(n) &&
                       n >= 0 && n <= .Machine$integer.max && n == floor(n))) {
    cli::cli_abort("{.arg n} must be a plain non-negative whole number in the supported integer range, or {.code NULL}.")
  }
  if (is.object(reverse) || !is.null(dim(reverse)) ||
      (!isTRUE(reverse) && !isFALSE(reverse))) {
    cli::cli_abort("{.arg reverse} must be {.code TRUE} or {.code FALSE}.")
  }
  if (!(is.numeric(alpha) && !is.complex(alpha) && !is.object(alpha) &&
        is.null(dim(alpha)) && length(alpha) == 1L && is.finite(alpha) &&
        alpha >= 0 && alpha <= 1)) {
    cli::cli_abort("{.arg alpha} must be a single number between 0 and 1.")
  }
  if (!is.null(x) && (!is.null(dim(x)) || is.expression(x) ||
      (!is.atomic(x) && !inherits(x, "POSIXlt")))) {
    cli::cli_abort("{.arg x} must be an atomic vector without dimensions or {.cls POSIXlt} timestamps; expressions and other containers are not supported.")
  }
  if (!is.null(dim(palette))) {
    cli::cli_abort("{.arg palette} must be a colour vector or a named list of colour vectors without dimensions.")
  }
  if (inherits(x, "integer64")) {
    cli::cli_abort("{.arg x} cannot be {.cls integer64}; recode it explicitly before mapping to avoid loss of precision.")
  }
  if (inherits(x, "haven_labelled") && !requireNamespace("haven", quietly = TRUE)) {
    cli::cli_abort("Interpreting labelled {.arg x} requires package {.pkg haven}.")
  }
  if (is.null(palette)) palette <- pal_lancet

  # Digit-leading strings (including decimals and exponents) can index palette().
  can_draw <- function(v) {
    tryCatch({
      grDevices::col2rgb(v)
      TRUE
    }, error = function(e) FALSE)
  }
  is_colour <- function(v) {
    input <- v
    if (!is.object(v) && length(v) > 1024L && .pal_use_unique(v)) {
      v <- unique(v)
    }
    drawable <- if (can_draw(v)) {
      rep(TRUE, length(v))
    } else {
      to_check <- if (is.object(v)) v else unique(v)
      if (is.object(to_check) || length(to_check) <= 256L) {
        valid <- vapply(to_check, can_draw, logical(1L), USE.NAMES = FALSE)
      } else {
        # Check individual colours only in blocks that fail to parse.
        valid <- logical(length(to_check))
        for (start in seq.int(1, length(to_check), by = 256L)) {
          indices <- seq.int(start, min(start + 255, length(to_check)))
          block <- to_check[indices]
          valid[indices] <- if (can_draw(block)) TRUE else {
            vapply(block, can_draw, logical(1L), USE.NAMES = FALSE)
          }
        }
      }
      if (is.object(v)) valid else valid[match(v, to_check)]
    }
    valid <- drawable & !is.na(v) & !grepl("^[0-9]", v)
    if (length(v) == length(input)) return(valid)
    if (all(valid)) return(rep(TRUE, length(input)))
    valid[match(input, v)]
  }

  # A list of palettes is mapped over, so `pal_heat` and friends get the same
  # n / x / reverse / alpha handling one palette at a time.
  if (is.list(palette)) {
    nms <- names(palette)
    if (length(palette) == 0L || is.null(nms) || anyNA(nms) ||
        any(!nzchar(nms)) || anyDuplicated(nms))
      cli::cli_abort(paste("A list of palettes must be non-empty and fully named,",
                           "with unique names."))
    if (!all(vapply(palette,
                    function(p) is.character(p) && is.null(dim(p)) && length(p) > 0L,
                    logical(1))))
      cli::cli_abort(paste("Every element of a palette list must be a",
                           "non-empty character vector of colours without dimensions."))
    for (i in seq_along(palette)) {
      bad <- palette[[i]][!is_colour(palette[[i]])]
      if (length(bad)) {
        cli::cli_abort("Palette {.val {nms[[i]]}} contains invalid colour{?s}: {.val {bad}}.")
      }
    }
    if (!is.object(x) && (is.character(x) || is.logical(x))) {
      lvs <- unique(x[!is.na(x)])
      x <- factor(lvs, levels = lvs)
    }
    if (!is.object(x) && is.numeric(x)) {
      if (.pal_use_unique(x)) {
        unique_x <- unique(x)
        positions <- match(x, unique_x)
        mapping <- .pal_numeric_positions(unique_x, reverse)
        return(lapply(palette, function(cols) {
          .pal_apply_positions(cols, mapping, alpha, size = length(x))[positions]
        }))
      }
      if (length(palette) > 1L) {
        mapping <- .pal_numeric_positions(x, reverse)
        return(lapply(palette, .pal_apply_positions, mapping = mapping, alpha = alpha))
      }
    }
    return(lapply(palette, .pal_apply,
                  n = n, x = x, reverse = reverse, alpha = alpha))
  }
  if (!is.character(palette) || length(palette) == 0L)
    cli::cli_abort(paste("{.arg palette} must be a palette name, a colour",
                         "vector, or a named list of colour vectors."))

  # Explicit namespace lookup so the function works when called as
  # `UtilsR::pal_get(...)` from another package without `library(UtilsR)`.
  # `LazyData` promises are not auto-evaluated by `::`, so a bare
  # `palette_list` reference errors with "object not found" in that path.
  pals <- getExportedValue("UtilsR", "palette_list")

  if (length(palette) == 1L && palette %in% names(pals)) {
    cols <- pals[[palette]]
  } else if (all(valid_colours <- is_colour(palette))) {
    # Literal colours. The registry is checked first, so a palette name is
    # never shadowed by an R colour name that happens to match.
    cols <- palette
  } else if (length(palette) > 1L) {
    bad <- palette[!valid_colours]
    cli::cli_abort(c(
      "{.arg palette} is neither a palette name nor a vector of colours.",
      "x" = "Not a colour: {.val {bad}}."
    ))
  } else {
    # The nearest names first: small edit distance, or containing the input.
    near <- character()
    if (!is.na(palette) && nzchar(palette)) {
      distance <- utils::adist(palette, names(pals), ignore.case = TRUE)[1L, ]
      contains <- grepl(tolower(palette), tolower(names(pals)), fixed = TRUE)
      keep <- which(distance <= 2L | contains)
      near <- utils::head(names(pals)[keep[order(distance[keep])]], 5L)
    }
    home <- if (palette %in% names(pal_other)) {
      paste0("pal_other$", palette)
    } else if (palette %in% names(pal_heat)) {
      paste0("pal_heat$", palette)
    }
    cli::cli_abort(c(
      "Palette {.val {palette}} not found.",
      "i" = if (!is.null(home)) "Pass {.code {home}}; that name is not in the registry.",
      "i" = if (length(near) > 0L) "Did you mean {.val {near}}?",
      "*" = "Use {.fn pal_list} to see available palettes."
    ))
  }

  .pal_apply(cols, n = n, x = x, reverse = reverse, alpha = alpha)
}

# Encode interpolated RGB and the final alpha channel in one pass.
#' @keywords internal
#' @noRd
.pal_ramp <- function(cols, at, alpha, size = length(at)) {
  # Keep the RGB spelling for opaque ramps and the source alpha when requested.
  has_alpha <- alpha == 1 && any(grDevices::col2rgb(cols, alpha = TRUE)["alpha", ] < 255)
  rgba <- grDevices::colorRamp(cols, alpha = has_alpha)(at)
  opacity <- if (has_alpha) {
    rgba[, 4L]
  } else if (alpha < 1) {
    # The template keeps the existing byte rounding and scalar/vector spelling.
    code <- ggplot2::alpha(rep.int("#000000", min(size, 2L)), alpha)[[1L]]
    if (nchar(code) == 9L) strtoi(substr(code, 8L, 9L), base = 16L)
  }
  if (is.null(opacity)) {
    grDevices::rgb(rgba[, 1L], rgba[, 2L], rgba[, 3L], maxColorValue = 255)
  } else {
    grDevices::rgb(rgba[, 1L], rgba[, 2L], rgba[, 3L], opacity, maxColorValue = 255)
  }
}

# Prepare the finite positions and optional lookup once for every palette.
#' @keywords internal
#' @noRd
.pal_numeric_positions <- function(x, reverse) {
  values <- as.numeric(x)
  values[is.na(x)] <- NA_real_
  placed <- is.finite(values)
  values <- values[placed]
  if (!length(values)) {
    return(list(placed = placed, at = numeric(), index = NULL))
  }

  ends <- range(values)
  at <- if (ends[[1L]] == ends[[2L]]) {
    rep(0.5, length(values))
  } else if (!is.finite(ends[[2L]] - ends[[1L]])) {
    # Halving finite endpoints keeps their span representable.
    (values / 2 - ends[[1L]] / 2) / (ends[[2L]] / 2 - ends[[1L]] / 2)
  } else {
    (values - ends[[1L]]) / (ends[[2L]] - ends[[1L]])
  }
  if (reverse) at <- 1 - at
  index <- NULL
  if (.pal_use_unique(at)) {
    unique_at <- unique(at)
    index <- match(at, unique_at)
    at <- unique_at
  }
  list(placed = placed, at = at, index = index)
}

#' @keywords internal
#' @noRd
.pal_apply_positions <- function(cols, mapping, alpha, size = length(mapping$placed)) {
  out <- rep(NA_character_, length(mapping$placed))
  if (length(mapping$at)) {
    colours <- .pal_ramp(cols, mapping$at, alpha, size)
    if (!is.null(mapping$index)) colours <- colours[mapping$index]
    out[mapping$placed] <- colours
  }
  out
}

# The n / x / reverse / alpha handling of `pal_get()`, split out so a list of
# palettes can be mapped over one element at a time.
#' @keywords internal
#' @noRd
.pal_apply <- function(cols, n = NULL, x = NULL, reverse = FALSE, alpha = 1) {
  if (!is.null(x) && is.numeric(x)) {
    return(.pal_apply_positions(cols, .pal_numeric_positions(x, reverse), alpha))
  }
  ramp <- function(k) .pal_ramp(cols, seq.int(0, 1, length.out = k), alpha)

  # --- Map to x (discrete) ---
  if (!is.null(x)) {
    lvs <- if (is.factor(x)) levels(x) else unique(x[!is.na(x)])
    lvs <- lvs[!is.na(lvs)]
    lvs <- as.character(lvs)
    if (anyDuplicated(lvs)) {
      cli::cli_abort(c(
        "Distinct values of {.arg x} produce the same discrete colour name.",
        "i" = "Convert {.arg x} to explicit unique labels before mapping."
      ))
    }
    n_lvs <- length(lvs)
    if (n_lvs <= length(cols)) {
      out <- stats::setNames(cols[seq_len(n_lvs)], lvs)
    } else {
      out <- stats::setNames(ramp(n_lvs), lvs)
      alpha <- 1
    }
  } else if (!is.null(n)) {
    # --- Return n colours ---
    if (n <= length(cols)) {
      out <- cols[seq_len(n)]
    } else {
      out <- ramp(n)
      alpha <- 1
    }
  } else {
    out <- cols
  }

  if (reverse) {
    if (!is.null(names(out))) {
      out <- stats::setNames(rev(out), names(out))
    } else {
      out <- rev(out)
    }
  }
  nms <- if (!is.null(x)) names(out)

  # Alpha
  if (alpha < 1) {
    # Unlike col2rgb(), farver interprets the literal "NA" as a missing value.
    out[out %in% "NA"] <- "#FFFFFF00"
    out <- ggplot2::alpha(out, alpha)
  }

  stats::setNames(as.character(out), nms)
}

# Bounded, spread-out probes avoid a full hash pass for sparse repetitions.
#' @keywords internal
#' @noRd
.pal_use_unique <- function(values) {
  n <- length(values)
  probe <- if (n <= 1024L) values else {
    values[round(seq.int(1, n, length.out = 1024L))]
  }
  unique_probe <- unique(probe)
  if (length(unique_probe) * 2L < length(probe)) return(TRUE)
  if (n <= 1024L || length(unique_probe) == length(probe)) return(FALSE)

  # A few common values alone do not justify a larger probe.
  repeated <- tabulate(match(probe, unique_probe), nbins = length(unique_probe)) > 1L
  if (sum(repeated) < 8L) return(FALSE)
  probe <- if (n <= 16384L) values else {
    values[round(seq.int(1, n, length.out = 16384L))]
  }
  length(unique(probe)) * 2L < length(probe)
}

# `.pal_apply()` keeps names only for a discrete `x` and drops attributes, both
# of which a display function still needs: the names label a vector such as `pal_paraSC`,
# and the "type" attribute fills the Type column.
#' @keywords internal
#' @noRd
.pal_resize <- function(cols, n, total = n) {
  continuous <- isTRUE(attr(cols, "type") %in%
    c("continuous", "seq", "div", "sequential", "diverging", "divergingx"))
  if (continuous && total > length(cols)) {
    at <- if (n == 1L) 0.5 else seq.int(0, 1, length.out = n)
    out <- .pal_apply(cols, x = at)
  } else if (total <= length(cols)) {
    indices <- if (continuous) {
      if (n == 1L) ceiling(length(cols) / 2) else round(seq.int(1, length(cols), length.out = n))
    } else seq_len(n)
    out <- as.character(cols[indices])
    names(out) <- names(cols)[indices]
  } else {
    # Evaluate only the displayed prefix of the originally requested ramp.
    has_alpha <- any(grDevices::col2rgb(cols, alpha = TRUE)[4L, ] < 255)
    at <- (seq_len(n) - 1) * (1 / (total - 1))
    if (n == total) at[n] <- 1
    rgba <- grDevices::colorRamp(cols, alpha = has_alpha)(at)
    out <- grDevices::rgb(rgba[, 1L], rgba[, 2L], rgba[, 3L],
                         alpha = if (has_alpha) rgba[, 4L] else NULL,
                         maxColorValue = 255)
  }
  attr(out, "type") <- attr(cols, "type")
  out
}

.pal_preview_indices <- function(n, max_colors, continuous) {
  shown <- min(n, max_colors)
  if (!continuous) return(seq_len(shown))
  if (shown == 1L) ceiling(n / 2) else round(seq.int(1, n, length.out = shown))
}

# Evaluate the same HCL trajectories as grDevices::hcl.colors() at selected rows.
.pal_hcl_preview <- function(n, palette, index, parameters) {
  type <- as.character(parameters[palette, "type"])
  p <- unlist(parameters[palette, -1L, drop = TRUE])
  i <- 1 + (index - 1) * (-1 / (n - 1))
  i[index == n] <- 0
  if (type == "qualitative") {
    last <- p[["h2"]]
    if (is.na(last)) last <- p[["h1"]] + 360 * (n - 1L) / n
    return(grDevices::hcl(h = last - (last - p[["h1"]]) * i,
                          c = p[["c1"]], l = p[["l1"]], alpha = NULL))
  }
  if (is.na(p[["p2"]])) p[["p2"]] <- p[["p1"]]
  if (is.na(p[["p4"]])) p[["p4"]] <- p[["p2"]]
  if (type == "sequential") {
    h1 <- p[["h1"]]
    h2 <- if (is.na(p[["h2"]])) h1 else p[["h2"]]
    c1 <- p[["c1"]]
    c2 <- if (is.na(p[["c2"]])) 0 else p[["c2"]]
    l1 <- p[["l1"]]
    power_c <- p[["p1"]]
    power_l <- p[["p2"]]
    peak <- p[["cmax1"]]
  } else {
    right <- index > n %/% 2
    i <- 1 + ifelse(right, n - index, index - 1) * (-2 / (n - 1))
    extended <- type == "divergingx"
    h1 <- ifelse(right, p[[if (extended) "h3" else "h2"]], p[["h1"]])
    h2 <- if (extended && !is.na(p[["h2"]])) p[["h2"]] else h1
    c1 <- if (extended) ifelse(right, p[["c3"]], p[["c1"]]) else p[["c1"]]
    c2 <- if (extended) p[["c2"]] else 0
    l1 <- if (extended) ifelse(right, p[["l3"]], p[["l1"]]) else p[["l1"]]
    power_c <- if (extended) ifelse(right, p[["p3"]], p[["p1"]]) else p[["p1"]]
    power_l <- if (extended) ifelse(right, p[["p4"]], p[["p2"]]) else p[["p2"]]
    peak <- if (extended) ifelse(right, p[["cmax2"]], p[["cmax1"]]) else p[["cmax1"]]
  }
  fraction <- i^power_c
  cross <- rep_len(1 / (1 + abs(peak - c1) / abs(peak - c2)), length(i))
  chroma <- ifelse(is.na(cross) | cross <= 0 | cross >= 1,
    c2 - (c2 - c1) * fraction,
    ifelse(fraction <= cross, c2 - (c2 - peak) * fraction / cross,
           peak - (peak - c1) * abs((fraction - cross) / (1 - cross))))
  grDevices::hcl(h = h2 - (h2 - h1) * i, c = chroma,
                 l = p[["l2"]] - (p[["l2"]] - l1) * i^power_l, alpha = NULL)
}

.pal_viridis_preview <- function(n, palette, index, alpha, begin, end, direction) {
  option_codes <- c(magma = "A", inferno = "B", plasma = "C", viridis = "D",
               cividis = "E", rocket = "F", mako = "G", turbo = "H")
  map <- viridisLite::viridis.map
  map <- map[map$opt == option_codes[[palette]], ]
  ramp <- grDevices::colorRamp(grDevices::rgb(map$R, map$G, map$B),
                               space = "Lab", interpolate = "spline")
  from <- if (direction == 1) begin else end
  to <- if (direction == 1) end else begin
  at <- from + (index - 1) * ((to - from) / (n - 1))
  at[index == 1] <- from
  at[index == n] <- to
  rgb <- ramp(at) / 255
  grDevices::rgb(rgb[, 1L], rgb[, 2L], rgb[, 3L], alpha = alpha)
}

# Keep returned plot environments separate from the original palette input.
.pal_show_gg <- function(pals) {
  force(pals)
  plot_data <- do.call(rbind, lapply(seq_along(pals), function(i) {
    cols <- as.character(pals[[i]])
    data.frame(palette = names(pals)[i], color = cols,
               x = seq_along(cols), stringsAsFactors = FALSE)
  }))
  plot_data$palette <- factor(plot_data$palette, levels = rev(names(pals)))

  ggplot2::ggplot(plot_data, ggplot2::aes(
    x = .data[["x"]], y = .data[["palette"]], fill = I(.data[["color"]]))) +
    ggplot2::geom_tile(width = 1, height = 0.8, colour = "grey80", linewidth = 0.3) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0)) +
    ggplot2::labs(x = NULL, y = NULL, title = sprintf("%d palettes", length(pals))) +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5, size = 12)
    )
}

# Keep the callbacks outside the table's environment for serialization.
.pal_preview_formats <- local({
  hex <- function(x) {
    vapply(regmatches(x, gregexpr("background:#[A-Fa-f0-9]+", x)), function(cols) {
      paste(sub("background:", "", cols, fixed = TRUE), collapse = " ")
    }, character(1), USE.NAMES = FALSE)
  }
  list(html = identity,
       latex = function(x) gsub("#", "\\#", hex(x), fixed = TRUE),
       rtf = hex, word = hex, default = hex)
}, envir = new.env(parent = baseenv()))

.pal_format_preview <- function(data) {
  gt::fmt(data, columns = "preview", fns = .pal_preview_formats)
}

# Let LaTeX break compound names while gt handles escaping in other formats.
.pal_name_formats <- local(list(
  latex = function(x) {
    parts <- strsplit(x, "(?<=[_.-])|(?<=[a-z])(?=[A-Z])", perl = TRUE)
    vapply(parts, function(word) {
      paste(gt::escape_latex(word), collapse = "\\allowbreak{}")
    }, character(1), USE.NAMES = FALSE)
  },
  default = function(x) rep(NA_character_, length(x))
), envir = new.env(parent = baseenv()))

# Numeric strings refer to the mutable base palette rather than literal colours.
.pal_are_colors <- function(x) {
  if (length(x) > 1024L && .pal_use_unique(x)) x <- unique(x)
  if (anyNA(x) || any(grepl("^[0-9]", x))) return(FALSE)
  tryCatch({
    grDevices::col2rgb(x)
    TRUE
  }, error = function(e) FALSE)
}

# Validate palette storage before list indexing can interpret factors as integers.
.pal_validate_palette <- function(palette, allow_list = FALSE) {
  if (is.null(palette)) return(invisible(NULL))
  plain_vector <- function(x) {
    is.character(x) && !is.object(x) && is.null(dim(x)) &&
      length(x) > 0L && !anyNA(x)
  }
  if (allow_list && is.list(palette) && !is.object(palette) && is.null(dim(palette))) {
    nms <- names(palette)
    if (!length(palette) || is.null(nms) || anyNA(nms) ||
        any(!nzchar(nms)) || anyDuplicated(nms) ||
        !all(vapply(palette, plain_vector, logical(1)))) {
      cli::cli_abort("{.arg palette} lists must be non-empty, uniquely named lists of non-missing character vectors.")
    }
    for (i in seq_along(palette)) {
      if (!.pal_are_colors(palette[[i]])) {
        cli::cli_abort("Palette {.val {nms[[i]]}} in {.arg palette} contains invalid colours.")
      }
    }
  } else if (!plain_vector(palette)) {
    cli::cli_abort("{.arg palette} must be a non-empty, non-missing character vector without a class or dimensions.")
  }
  invisible(NULL)
}

# Validate viewers before source palettes are generated or any output is drawn.
.pal_validate_show <- function(n, max_colors, index, label = TRUE,
                               label_size = 3, ncol = NULL, n_required = FALSE) {
  size_ok <- function(x, nullable = FALSE, unlimited = FALSE) {
    if (is.null(x)) return(nullable)
    is.numeric(x) && !is.complex(x) && !is.object(x) &&
      length(x) == 1L && is.null(dim(x)) && !is.na(x) &&
      ((unlimited && x == Inf) ||
       (is.finite(x) && x >= 1 && x <= .Machine$integer.max && x == floor(x)))
  }
  if (!size_ok(n, nullable = !n_required)) {
    cli::cli_abort("{.arg n} must be a positive whole number in the supported integer range.")
  }
  if (!size_ok(max_colors, unlimited = TRUE)) {
    cli::cli_abort("{.arg max_colors} must be a positive whole number or {.code Inf}.")
  }
  if (!size_ok(ncol, nullable = TRUE)) {
    cli::cli_abort("{.arg ncol} must be a positive whole number or {.code NULL}.")
  }
  if (!isTRUE(label) && !isFALSE(label)) {
    cli::cli_abort("{.arg label} must be {.code TRUE} or {.code FALSE}.")
  }
  if (!(is.numeric(label_size) && !is.complex(label_size) &&
        !is.object(label_size) && length(label_size) == 1L &&
        is.null(dim(label_size)) && is.finite(label_size) && label_size > 0)) {
    cli::cli_abort("{.arg label_size} must be a single positive finite number.")
  }
  if (!is.null(index) &&
      !(is.numeric(index) && !is.complex(index) && !is.object(index) &&
        is.null(dim(index)) && length(index) > 0L && all(is.finite(index)) &&
        all(index >= 1 & index <= .Machine$integer.max & index == floor(index)) &&
        !anyDuplicated(index))) {
    cli::cli_abort("{.arg index} must contain unique positive whole numbers without missing values.")
  }
  invisible(NULL)
}

#' Visualise Palettes or Colour Vectors
#'
#' Display palettes as horizontal colour bars (ggplot) or a
#' gt table with colour swatches. Use \code{output = "gg"} for the Plots
#' pane or \code{output = "gt"} for the Viewer pane.
#'
#' When \code{palette} is a character vector of valid colour specifications
#' (hex codes like \code{"#FF0000"} or named R colours like \code{"red"})
#' rather than palette names, the function automatically switches to
#' \strong{colour vector mode}: it displays the colours directly as tiles
#' (ggplot), a table, or console swatches.
#'
#' @details Catalogue swatches use thin grey outlines in ggplot and HTML output.
#'   The outlines remain visible for fully transparent fills.
#'
#'   In gt catalogue output, long palette names wrap within the name column.
#'   Each swatch exposes its hexadecimal colour value as a hover title and an
#'   accessible label.
#'   LaTeX catalogue tables use the available text width and repeat column
#'   headings when the table spans pages.
#'
#'   For readable ggplot labels on a small figure, use \code{ncol} to place
#'   a colour vector in several rows. Use \code{pattern} or \code{index} to
#'   limit how many palettes appear in a catalogue plot.
#'
#'   Explicit palette names take precedence over \code{pattern} and
#'   \code{type}. These filters apply when browsing with \code{palette = NULL}.
#'   In colour vector mode, \code{pattern}, \code{type} and \code{index} do
#'   not select colours. Subset the colour vector before calling the function
#'   to select individual colours.
#'
#' @param palette Character vector of palette names (e.g. \code{"lancet"}),
#'   a colour vector (hex codes or named colours), or \code{NULL} to show
#'   all palettes matching \code{pattern}/\code{type}. Named colour vectors
#'   (e.g. \code{pal_paraSC}) use valid names as labels and hex codes for missing
#'   or whitespace-only names. Repeated palette names are displayed once, in
#'   first-occurrence order; repeated literal colours are preserved. Factors,
#'   classed vectors, matrices and data frames are not supported.
#' @param n Positive whole number of colours to preview from each palette.
#'   Continuous palettes are sampled evenly across their full range; a single
#'   colour uses the middle of the palette. Discrete palettes and untyped colour
#'   vectors take colours from the front and interpolate when more are requested
#'   than are available. \code{max_colors} caps how many are drawn.
#'   Default \code{NULL} uses the native colour count before the display cap.
#' @param pattern Single non-missing regex string to filter catalogue names
#'   (e.g. \code{"^nord"}). Default \code{NULL} does not filter by name.
#' @param type Catalogue type filter: \code{"all"}, \code{"discrete"}, or
#'   \code{"continuous"}.
#' @param max_colors Positive whole number limiting displayed colours per palette,
#'   or \code{Inf} for no display cap. Default 20.
#' @param index Non-empty vector of unique positive whole-number catalogue
#'   indices after name selection or filtering. Out-of-range indices are
#'   ignored. An empty catalogue selection is an error.
#' @param output Output format: \code{"gt"} (default) for a gt table,
#'   \code{"gg"} for a ggplot, or \code{"console"} for terminal output.
#'   gt colour swatches use HTML. LaTeX, Word, RTF and other non-HTML
#'   tables show HEX text instead. Use \code{output = "gg"} for coloured
#'   figures in PDF or Word documents.
#' @param label Logical. For \code{output = "gg"} in colour vector mode,
#'   whether to show hex/name labels on tiles. Default \code{TRUE}. Does not
#'   change gt tables or console output.
#' @param label_size Positive finite number. Tile-label text size for
#'   \code{output = "gg"} in colour vector mode. Default 3.
#' @param ncol Positive whole number of columns for \code{output = "gg"} in
#'   colour vector mode. Default \code{NULL} puts every displayed colour on a
#'   single row.
#'
#' @return A ggplot or gt object returned visibly for automatic display.
#'   Console output prints and invisibly returns the displayed data.
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
#' # Take a fixed number of colours from each palette
#' pal_show(c("Set1", "lancet"), n = 3)
#' pal_show("Set1", n = 12)  # only 9 colours, so interpolated
#'
#' # ggplot output (colour bars in Plots pane)
#' pal_show(c("lancet", "ditto", "polychrome", "igv"), output = "gg")
#' pal_show(pattern = "^viridis|^magma|^plasma", output = "gg")
#' pal_show(type = "continuous", index = 1:10, output = "gg")
#'
#' # --- Colour vector mode ---
#' # Show a named colour vector (e.g. pal_paraSC)
#' pal_show(pal_paraSC)
#' pal_show(pal_paraSC, n = 6)
#' pal_show(pal_paraSC, ncol = 3, output = "gg")
#'
#' # Show any colour vector
#' pal_show(c("#FF0000", "#00FF00", "#0000FF"))
#' pal_show(rainbow(12), ncol = 4, output = "gg")
#'
#' # Without labels
#' pal_show(pal_lancet, label = FALSE, output = "gg")
#'
#' # Browse all palettes from a source
#' pal_show(pattern = "^dichromat")
#' pal_show(pattern = "^pals")
#'
#' @export
#' @family colour palettes
pal_show <- function(palette = NULL, n = NULL, pattern = NULL,
                     type = c("all", "discrete", "continuous"),
                     max_colors = 20, index = NULL,
                     output = c("gt", "gg", "console"),
                     label = TRUE, label_size = 3, ncol = NULL) {
  type <- match.arg(type)
  output <- match.arg(output)
  .pal_validate_show(n, max_colors, index, label, label_size, ncol)
  .pal_validate_palette(palette, allow_list = TRUE)

  # --- Detect colour vector mode ---
  # If palette is a character vector and looks like colours (not palette
  # names), switch to colour vector display mode.
  if (!is.null(palette) && is.character(palette) && length(palette) > 0) {
    is_color_vec <- .is_color_vector(palette)
    if (is_color_vec) {
      return(.pal_show_colors(palette, label = label,
                              label_size = label_size, ncol = ncol,
                              output = output, max_colors = max_colors, n = n))
    }
  }

  # A named list is accepted internally by the source-specific wrappers below.
  if (!is.null(palette) && is.list(palette)) {
    pals <- palette
    palette <- NULL
  } else {
    # Explicit namespace lookup (LazyData not auto-loaded under `::`).
    pals <- getExportedValue("UtilsR", "palette_list")
  }

  # --- Filter palettes ---
  if (!is.null(palette)) {
    valid <- unique(palette[palette %in% names(pals)])
    if (length(valid) == 0) cli::cli_abort("No matching palettes found.")
    unknown <- setdiff(palette, names(pals))
    if (length(unknown) > 0) {
      cli::cli_warn("Skipping palette{?s} not in the registry: {.val {unknown}}.")
    }
    pals <- pals[valid]
  } else {
    if (type != "all") {
      pals <- pals[vapply(pals, function(x) identical(attr(x, "type"), type), logical(1))]
    }
    if (!is.null(pattern)) {
      pals <- pals[.pal_match_pattern(pattern, names(pals))]
    }
  }
  if (length(pals) == 0) cli::cli_abort("No palettes matched the filters.")

  # Apply index
  if (!is.null(index)) {
    keep <- index[index >= 1 & index <= length(pals)]
    if (length(keep) == 0) {
      cli::cli_abort(c(
        "{.arg index} selected no palettes.",
        "i" = "Only {length(pals)} palette{?s} matched the filters."
      ))
    }
    pals <- pals[keep]
  }

  # Generate only the drawn colours, retaining the requested total for labels.
  requested_total <- attr(pals, "n_total", exact = TRUE)
  n_total <- lengths(pals)
  if (!is.null(n)) n_total[] <- n
  pals <- Map(.pal_resize, pals, pmin(n_total, max_colors), n_total)
  if (is.null(n) && !is.null(requested_total)) n_total[] <- requested_total
  n_shown <- lengths(pals)
  n_label <- ifelse(n_shown < n_total,
                    sprintf("%d / %d", n_shown, n_total),
                    as.character(n_total))

  # --- Console output ---
  if (output == "console") {
    for (nm in names(pals)) {
      tp <- attr(pals[[nm]], "type") %||% "?"
      cat("\n")
      .pal_print_heading(nm, n_label[[nm]], tp)
      show_color(pals[[nm]])
    }
    return(invisible(pals))
  }

  # --- ggplot output ---
  if (output == "gg") {
    return(.pal_show_gg(pals))
  }

  # --- gt table output ---
  # Each swatch is a fixed 20px block, so the Colours column only has to be as
  # wide as the longest palette actually drawn (plus the 2 x 5px gt cell
  # padding), floored so the column label still fits.
  swatch_px <- 20
  preview_px <- max(swatch_px * max(n_shown) + 10, 90)
  html_widths <- c(palette = 180, type = 80, n_colors = 70, preview = preview_px)

  tbl_data <- data.frame(
    palette = names(pals),
    type = vapply(pals, function(x) attr(x, "type") %||% "?", character(1)),
    n_colors = n_label,
    preview = vapply(pals, function(cols) {
      spans <- vapply(.pal_hex(cols), function(c) {
        sprintf(paste0('<span role="img" title="%s" aria-label="%s" ',
                       'style="display:inline-block;width:%dpx;',
                       'background:%s;color:%s;box-shadow:inset 0 0 0 1px #CCCCCC;">&nbsp;</span>'),
                c, c, swatch_px, c, c)
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
    .pal_format_preview() %>%
    gt::fmt(columns = "palette", fns = .pal_name_formats) %>%
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
      column_labels.padding = gt::px(6),
      table.layout = "auto",
      container.width = sprintf("min(100%%, %dpx)", sum(html_widths)),
      latex.use_longtable = TRUE,
      latex.header_repeat = TRUE
    ) %>%
    gt::cols_width(
      palette ~ gt::pct(28),
      type ~ gt::pct(18),
      n_colors ~ gt::pct(18),
      preview ~ gt::pct(36)
    )

  # HTML uses pixel widths, including the 5px padding on each side of a cell.
  for (column in names(html_widths)) {
    width <- gt::px(html_widths[[column]] - 10)
    wrap <- column == "palette"
    tbl <- gt::tab_style(
      tbl, gt::css("min-width" = width, "width" = width,
                  "overflow-wrap" = if (wrap) "anywhere"),
      locations = list(gt::cells_column_labels(columns = column),
                       gt::cells_body(columns = column,
                                      rows = if (wrap) seq_len(nrow(tbl_data)) else 1L))
    )
  }

  tbl
}

#' Visualise RColorBrewer Palettes
#'
#' Display palettes generated by \code{RColorBrewer::brewer.pal()} using the
#' same ggplot or gt layout as \code{\link{pal_show}()}.
#'
#' @details Explicit \code{palette} names take precedence over \code{pattern}
#'   and \code{type} (where available). These filters are applied only when
#'   \code{palette = NULL}. Unknown names are reported and skipped when at
#'   least one valid palette remains.
#'
#' @param palette Character vector of RColorBrewer palette names. \code{NULL}
#'   shows all palettes matching \code{type} and \code{pattern}.
#' @param n Number of colours to generate for each palette. \code{NULL} uses
#'   each palette's maximum supported size; other values are clamped to the
#'   supported range, with a minimum of 3. Thus \code{n = 1} still generates
#'   3 colours. A single message reports adjusted sizes.
#' @param type Brewer palette category: \code{"all"}, \code{"qual"},
#'   \code{"seq"}, or \code{"div"}.
#' @param pattern Single non-missing regex string used to filter palette names.
#' @param index Non-empty vector of unique positive whole-number indices after
#'   filtering. Out-of-range values are ignored. An empty selection reports
#'   the argument and matched count before any palettes are drawn.
#' @param max_colors Positive whole number limiting displayed colours per palette,
#'   or \code{Inf} for no display cap. Default 20. Applied after native size
#'   adjustment. With \code{max_colors = 1}, \code{"qual"} palettes show
#'   their first colour; \code{"seq"} and \code{"div"} palettes show the
#'   middle colour of the adjusted native sequence (the lower middle for an
#'   even sequence size).
#' @param output Output format: \code{"gt"} (default) for a gt table,
#'   \code{"gg"} for a ggplot, or \code{"console"} for terminal output.
#'   gt colour swatches use HTML. LaTeX, Word, RTF and other non-HTML
#'   tables show HEX text instead. Use \code{output = "gg"} for coloured
#'   figures in PDF or Word documents.
#'
#' @return A ggplot or gt object returned visibly for automatic display.
#'   Console output prints and invisibly returns the displayed palette list.
#'
#' @examples
#' pal_show_brewer(c("Set1", "Blues"), n = 8, output = "gg")
#' pal_show_brewer(type = "qual", output = "gg")
#'
#' # First qualitative colour versus the lower middle of eight sequential colours
#' pal_show_brewer("Set1", n = 8, max_colors = 1, output = "gg")
#' pal_show_brewer("Blues", n = 8, max_colors = 1, output = "gg")
#'
#' @export
#' @family colour palettes
pal_show_brewer <- function(palette = NULL, n = NULL,
                            type = c("all", "qual", "seq", "div"),
                            pattern = NULL, index = NULL, max_colors = 20,
                            output = c("gt", "gg", "console")) {
  if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg RColorBrewer} is required for {.fn pal_show_brewer}.")
  }

  type <- match.arg(type)
  output <- match.arg(output)
  .pal_validate_show(n, max_colors, index)
  .pal_validate_palette(palette)

  info <- RColorBrewer::brewer.pal.info
  pal_names <- rownames(info)
  if (!is.null(palette)) {
    valid <- unique(palette[palette %in% pal_names])
    if (length(valid) == 0L) {
      cli::cli_abort("No matching RColorBrewer palettes found.")
    }
    unknown <- setdiff(palette, pal_names)
    if (length(unknown)) {
      cli::cli_warn("Skipping unknown RColorBrewer palette{?s}: {.val {unknown}}.")
    }
    pal_names <- valid
  } else {
    if (type != "all") {
      pal_names <- pal_names[info[pal_names, "category"] == type]
    }
    if (!is.null(pattern)) {
      pal_names <- pal_names[.pal_match_pattern(pattern, pal_names)]
    }
  }
  if (length(pal_names) == 0L) {
    cli::cli_abort("No RColorBrewer palettes matched the filters.")
  }
  if (!is.null(index)) {
    keep <- index[index <= length(pal_names) & index >= 1]
    if (!length(keep)) {
      cli::cli_abort(c(
        "{.arg index} selected no palettes.",
        "i" = "Only {length(pal_names)} palette{?s} matched the filters."
      ))
    }
    pal_names <- pal_names[keep]
  }

  max_n <- info[pal_names, "maxcolors"]
  n_use <- stats::setNames(
    if (is.null(n)) max_n else pmin(pmax(3L, as.integer(n)), max_n),
    pal_names
  )
  adjusted <- if (is.null(n)) character() else pal_names[n_use != n]
  if (length(adjusted)) {
    sizes <- paste0(adjusted, "=", n_use[adjusted])
    cli::cli_inform("Adjusting {.arg n} = {n} to supported palette sizes: {.val {sizes}}.")
  }
  pals <- lapply(pal_names, function(nm) {
    cols <- RColorBrewer::brewer.pal(n_use[[nm]], nm)
    attr(cols, "type") <- info[nm, "category"]
    cols
  })
  names(pals) <- pal_names

  pal_show(pals, max_colors = max_colors, output = output)
}

#' Visualise Base R HCL Palettes
#'
#' Display palettes generated by \code{grDevices::hcl.colors()} for the
#' palettes listed by \code{grDevices::hcl.pals()}, using the same ggplot or
#' gt layout as \code{\link{pal_show}()}.
#'
#' @details Explicit \code{palette} names take precedence over \code{pattern}
#'   and \code{type} (where available). These filters are applied only when
#'   \code{palette = NULL}. Unknown names are reported and skipped when at
#'   least one valid palette remains.
#'
#' @param palette Character vector of HCL palette names. \code{NULL} shows all
#'   palettes matching \code{type} and \code{pattern}. Matching follows native HCL
#'   rules: case and separators are ignored, unique abbreviations are accepted,
#'   and ambiguous names are rejected. Returned names use canonical spelling.
#' @param n Number of colours in each requested palette. Default 8. With
#'   \code{n = 1}, native HCL rules use the starting colour for qualitative
#'   and sequential palettes, and the central colour for diverging and
#'   divergingx palettes. Capped previews evaluate only the displayed positions
#'   and retain the requested total in the colour-count label.
#' @param type HCL palette category: \code{"all"}, \code{"qualitative"},
#'   \code{"sequential"}, \code{"diverging"}, or \code{"divergingx"}.
#' @param pattern Single non-missing regex string used to filter palette names.
#' @param index Non-empty vector of unique positive whole-number indices after
#'   filtering. Out-of-range values are ignored. An empty selection reports
#'   the argument and matched count before any palettes are drawn.
#' @param max_colors Positive whole number limiting displayed colours per palette,
#'   or \code{Inf} for no display cap. Default 20. With \code{max_colors = 1},
#'   qualitative palettes show the first colour; continuous HCL palettes show
#'   the middle of the \code{n} generated colours (the lower middle for even
#'   \code{n}). This can differ from native \code{n = 1} generation.
#' @param output Output format: \code{"gt"} (default) for a gt table,
#'   \code{"gg"} for a ggplot, or \code{"console"} for terminal output.
#'   gt colour swatches use HTML. LaTeX, Word, RTF and other non-HTML
#'   tables show HEX text instead. Use \code{output = "gg"} for coloured
#'   figures in PDF or Word documents.
#'
#' @return A ggplot or gt object returned visibly for automatic display.
#'   Console output prints and invisibly returns the displayed palette list.
#'
#' @examples
#' pal_show_hcl(c("Dark 3", "Viridis"), n = 8, output = "gg")
#' pal_show_hcl(type = "qualitative", output = "gg")
#'
#' # Native single-colour generation versus a capped preview
#' pal_show_hcl("Viridis", n = 1, output = "gg")
#' pal_show_hcl("Viridis", n = 8, max_colors = 1, output = "gg")
#'
#' @export
#' @family colour palettes
pal_show_hcl <- function(palette = NULL, n = 8,
                         type = c("all", "qualitative", "sequential", "diverging", "divergingx"),
                         pattern = NULL, index = NULL, max_colors = 20,
                         output = c("gt", "gg", "console")) {
  type <- match.arg(type)
  output <- match.arg(output)
  .pal_validate_show(n, max_colors, index, n_required = TRUE)
  .pal_validate_palette(palette)

  hcl_types <- c("qualitative", "sequential", "diverging", "divergingx")
  all_names <- grDevices::hcl.pals()
  type_names <- stats::setNames(
    lapply(hcl_types, grDevices::hcl.pals),
    hcl_types
  )
  type_lookup <- stats::setNames(
    rep(names(type_names), lengths(type_names)),
    unlist(type_names, use.names = FALSE)
  )
  other_names <- setdiff(all_names, names(type_lookup))
  if (length(other_names) > 0L) {
    type_lookup[other_names] <- "other"
  }

  pal_names <- all_names
  if (!is.null(palette)) {
    normalise <- function(x) tolower(gsub("[-_,(). ]", "", x))
    matched <- charmatch(normalise(palette), normalise(pal_names))
    if (any(matched == 0L, na.rm = TRUE)) {
      ambiguous <- unique(palette[which(matched == 0L)])
      cli::cli_abort("{.arg palette} contains ambiguous HCL names: {.val {ambiguous}}.")
    }
    valid <- unique(pal_names[matched[!is.na(matched)]])
    if (length(valid) == 0L) {
      cli::cli_abort("No matching HCL palettes found.")
    }
    unknown <- unique(palette[is.na(matched)])
    if (length(unknown)) {
      cli::cli_warn("Skipping unknown HCL palette{?s}: {.val {unknown}}.")
    }
    pal_names <- valid
  } else {
    if (type != "all") {
      pal_names <- type_names[[type]]
    }
    if (!is.null(pattern)) {
      pal_names <- pal_names[.pal_match_pattern(pattern, pal_names)]
    }
  }
  if (length(pal_names) == 0L) {
    cli::cli_abort("No HCL palettes matched the filters.")
  }
  if (!is.null(index)) {
    keep <- index[index <= length(pal_names) & index >= 1]
    if (!length(keep)) {
      cli::cli_abort(c(
        "{.arg index} selected no palettes.",
        "i" = "Only {length(pal_names)} palette{?s} matched the filters."
      ))
    }
    pal_names <- pal_names[keep]
  }

  parameters <- if (n > max_colors) {
    utils::getFromNamespace(".hcl_colors_parameters", "grDevices")
  }
  pals <- lapply(pal_names, function(nm) {
    cols <- if (n > max_colors) {
      index <- .pal_preview_indices(n, max_colors, type_lookup[[nm]] != "qualitative")
      .pal_hcl_preview(n, nm, index, parameters)
    } else grDevices::hcl.colors(as.integer(n), palette = nm)
    attr(cols, "type") <- unname(type_lookup[[nm]])
    cols
  })
  names(pals) <- pal_names
  attr(pals, "n_total") <- n

  pal_show(pals, max_colors = max_colors, output = output)
}

#' Visualise ggsci Palettes
#'
#' Display the fixed colour palettes in the standard \code{ggsci} catalogue
#' using the same ggplot or gt layout as \code{\link{pal_show}()}.
#'
#' @details Explicit \code{palette} names take precedence over \code{pattern}
#'   and \code{type} (where available). These filters are applied only when
#'   \code{palette = NULL}. Unknown names are reported and skipped when at
#'   least one valid palette remains.
#'
#'   This catalogue excludes iTerm terminal themes and Gephi generative
#'   palettes. Use \code{ggsci::iterm_palettes()} and \code{ggsci::pal_iterm()}
#'   for iTerm themes, or \code{ggsci::pal_gephi()} for Gephi generators, in
#'   versions of \code{ggsci} that provide these interfaces.
#'
#'   Gephi presets in newer \code{ggsci} databases are excluded before
#'   indexing and colour processing. Explicitly selecting only Gephi presets
#'   is an error; mixed selections warn and retain the fixed palettes.
#'   Generators are never evaluated, so previews do not change the random
#'   number state.
#'
#' @param palette Character vector of fixed palette names. Names use the form
#'   \code{"ggsci_npg_nrc"}; the \code{ggsci_} prefix may be omitted.
#'   \code{NULL} shows all fixed palettes matching \code{pattern}.
#' @param n Number of colours to retain, capped at each palette's native size.
#'   Continuous GSEA, Bootstrap 5, Material and Tailwind 3 palettes are sampled
#'   evenly across their full range; \code{n = 1} uses the native middle colour
#'   (the lower middle for an even native size). Discrete palettes retain their
#'   first colours. \code{NULL} uses each palette's native number of colours.
#' @param alpha Opacity of the colours, a plain numeric scalar between 0 and 1
#'   without a class or dimensions.
#' @param reverse Logical scalar without a class or dimensions; if \code{TRUE},
#'   reverse the final preview colours after applying \code{n} and
#'   \code{max_colors}, preserving the selected colour set.
#' @param pattern Single non-missing regex string used to filter palette names.
#' @param index Non-empty vector of unique positive whole-number indices after
#'   filtering. Out-of-range values are ignored. An empty selection reports
#'   the argument and matched count before any palettes are drawn.
#' @param max_colors Positive whole number limiting displayed colours per palette,
#'   or \code{Inf} for no display cap. Default 20. Applied after \code{n}
#'   selection. With \code{max_colors = 1}, continuous palettes show the middle
#'   of the retained colours (the lower middle for an even retained size),
#'   and discrete palettes show the first retained colour.
#' @param output Output format: \code{"gt"} (default) for a gt table,
#'   \code{"gg"} for a ggplot, or \code{"console"} for terminal output.
#'   gt colour swatches use HTML. LaTeX, Word, RTF and other non-HTML
#'   tables show HEX text instead. Use \code{output = "gg"} for coloured
#'   figures in PDF or Word documents.
#'
#' @return A ggplot or gt object returned visibly for automatic display.
#'   Console output prints and invisibly returns the displayed palette list.
#'
#' @examples
#' if (requireNamespace("ggsci", quietly = TRUE)) {
#'   pal_show_ggsci(c("ggsci_npg_nrc", "ggsci_aaas_default"),
#'                  n = 5, output = "gg")
#'
#'   # The display cap follows native colour selection
#'   pal_show_ggsci("gsea_default", n = 1, output = "gg")
#'   pal_show_ggsci("gsea_default", n = 4, max_colors = 1, output = "gg")
#' }
#'
#' @export
#' @family colour palettes
pal_show_ggsci <- function(palette = NULL, n = NULL, alpha = 1,
                           reverse = FALSE, pattern = NULL, index = NULL,
                           max_colors = 20,
                           output = c("gt", "gg", "console")) {
  if (!requireNamespace("ggsci", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggsci} is required for {.fn pal_show_ggsci}.")
  }

  output <- match.arg(output)
  .pal_validate_show(n, max_colors, index)
  .pal_validate_palette(palette)
  if (!is.numeric(alpha) || is.complex(alpha) || is.object(alpha) ||
      !is.null(dim(alpha)) || length(alpha) != 1L || !is.finite(alpha) ||
      alpha < 0 || alpha > 1) {
    cli::cli_abort("Argument {.arg alpha} must be a number between 0 and 1.")
  }
  if (!is.logical(reverse) || is.object(reverse) || !is.null(dim(reverse)) ||
      length(reverse) != 1L || is.na(reverse)) {
    cli::cli_abort("Argument {.arg reverse} must be a single TRUE or FALSE.")
  }

  ggsci_db <- tryCatch(
    utils::getFromNamespace("ggsci_db", "ggsci"),
    error = function(e) NULL
  )
  if (is.null(ggsci_db) || !is.list(ggsci_db)) {
    cli::cli_abort("Could not read the palette database from {.pkg ggsci}.")
  }

  generator_names <- names(ggsci_db[["gephi"]])
  if (length(generator_names)) generator_names <- paste0("ggsci_gephi_", generator_names)
  pals <- list()
  for (pkg_name in setdiff(names(ggsci_db), "gephi")) {
    sub_pals <- ggsci_db[[pkg_name]]
    for (sub_name in names(sub_pals)) {
      full_name <- paste0("ggsci_", pkg_name, "_", sub_name)
      cols <- unname(sub_pals[[sub_name]])
      attr(cols, "type") <- if (pkg_name %in% c("gsea", "bs5", "material", "tw3")) {
        "continuous"
      } else "discrete"
      pals[[full_name]] <- cols
    }
  }

  if (!is.null(palette)) {
    requested <- ifelse(
      palette %in% c(names(pals), generator_names), palette, paste0("ggsci_", palette)
    )
    valid <- unique(requested[requested %in% names(pals)])
    generators <- unique(palette[requested %in% generator_names])
    if (length(valid) == 0L) {
      if (length(generators)) {
        cli::cli_abort("Gephi generator{?s} {.val {generators}} cannot be previewed as fixed colours. Use {.fn ggsci::pal_gephi} to generate them.")
      }
      cli::cli_abort("No matching ggsci palettes found.")
    }
    if (length(generators)) {
      cli::cli_warn("Skipping Gephi generator{?s}: {.val {generators}}. Use {.fn ggsci::pal_gephi} to generate them.")
    }
    unknown <- unique(palette[!requested %in% c(names(pals), generator_names)])
    if (length(unknown)) {
      cli::cli_warn("Skipping unknown ggsci palette{?s}: {.val {unknown}}.")
    }
    pals <- pals[valid]
  } else if (!is.null(pattern)) {
    pals <- pals[.pal_match_pattern(pattern, names(pals))]
  }
  if (length(pals) == 0L) {
    cli::cli_abort("No ggsci palettes matched the filters.")
  }
  if (!is.null(index)) {
    keep <- index[index <= length(pals) & index >= 1]
    if (!length(keep)) {
      cli::cli_abort(c(
        "{.arg index} selected no palettes.",
        "i" = "Only {length(pals)} palette{?s} matched the filters."
      ))
    }
    pals <- pals[keep]
  }

  preview_total <- lengths(pals)
  if (!is.null(n)) preview_total <- pmin(preview_total, as.integer(n))
  pals <- lapply(pals, function(cols) {
    type <- attr(cols, "type")
    if (!is.null(n)) cols <- .pal_resize(cols, min(n, length(cols)))
    cols <- .pal_resize(cols, min(length(cols), max_colors))
    if (isTRUE(reverse)) cols <- rev(cols)
    if (alpha < 1) cols <- scales::alpha(cols, alpha)
    attr(cols, "type") <- type
    cols
  })
  attr(pals, "n_total") <- preview_total[names(pals)]
  pal_show(pals, max_colors = max_colors, output = output)
}

#' Visualise Viridis Palettes
#'
#' Display the eight viridis colour maps using the same ggplot or gt layout as
#' \code{\link{pal_show}()}.
#'
#' @details Explicit \code{palette} names take precedence over \code{pattern}
#'   and \code{type} (where available). These filters are applied only when
#'   \code{palette = NULL}. Unknown names are reported and skipped when at
#'   least one valid palette remains.
#'
#' @param palette Character vector of palette names: \code{"magma"},
#'   \code{"inferno"}, \code{"plasma"}, \code{"viridis"},
#'   \code{"cividis"}, \code{"rocket"}, \code{"mako"}, or \code{"turbo"}.
#'   \code{NULL} shows all palettes.
#' @param n Number of colours in each requested palette. Default 8. With
#'   \code{n = 1}, the native generator uses \code{begin} when
#'   \code{direction = 1}, or \code{end} when \code{direction = -1}.
#'   Capped previews evaluate only the displayed positions and retain the
#'   requested total in the colour-count label.
#' @param begin,end Plain numeric scalars between 0 and 1, without classes or
#'   dimensions, defining the portion of each colour map to use.
#' @param direction Direction of the colour map, a plain numeric scalar equal
#'   to 1 or -1, without a class or dimensions.
#' @param alpha Opacity of the colours, a plain numeric scalar between 0 and 1
#'   without a class or dimensions.
#' @param pattern Single non-missing regex string used to filter palette names.
#' @param index Non-empty vector of unique positive whole-number indices after
#'   filtering. Out-of-range values are ignored. An empty selection reports
#'   the argument and matched count before any palettes are drawn.
#' @param max_colors Positive whole number limiting displayed colours per palette,
#'   or \code{Inf} for no display cap. Default 20. With \code{max_colors = 1},
#'   the middle of the \code{n} generated colours is shown (the lower middle
#'   for even \code{n}). This can differ from native \code{n = 1} generation.
#' @param output Output format: \code{"gt"} (default) for a gt table,
#'   \code{"gg"} for a ggplot, or \code{"console"} for terminal output.
#'   gt colour swatches use HTML. LaTeX, Word, RTF and other non-HTML
#'   tables show HEX text instead. Use \code{output = "gg"} for coloured
#'   figures in PDF or Word documents.
#'
#' @return A ggplot or gt object returned visibly for automatic display.
#'   Console output prints and invisibly returns the displayed palette list.
#'
#' @examples
#' pal_show_viridis(c("viridis", "plasma"), n = 8, output = "gg")
#' pal_show_viridis(direction = -1, output = "gg")
#'
#' # Native single-colour generation versus a capped preview
#' pal_show_viridis("viridis", n = 1, output = "gg")
#' pal_show_viridis("viridis", n = 8, max_colors = 1, output = "gg")
#'
#' @export
#' @family colour palettes
pal_show_viridis <- function(palette = NULL, n = 8, begin = 0, end = 1,
                             direction = 1, alpha = 1, pattern = NULL,
                             index = NULL, max_colors = 20,
                             output = c("gt", "gg", "console")) {
  output <- match.arg(output)
  .pal_validate_show(n, max_colors, index, n_required = TRUE)
  .pal_validate_palette(palette)
  if (!is.numeric(begin) || is.complex(begin) || is.object(begin) ||
      !is.null(dim(begin)) || length(begin) != 1L || !is.finite(begin) ||
      begin < 0 || begin > 1) {
    cli::cli_abort("Argument {.arg begin} must be a number between 0 and 1.")
  }
  if (!is.numeric(end) || is.complex(end) || is.object(end) ||
      !is.null(dim(end)) || length(end) != 1L || !is.finite(end) ||
      end < 0 || end > 1) {
    cli::cli_abort("Argument {.arg end} must be a number between 0 and 1.")
  }
  if (!is.numeric(direction) || is.complex(direction) || is.object(direction) ||
      !is.null(dim(direction)) || length(direction) != 1L ||
      !is.finite(direction) || !direction %in% c(-1, 1)) {
    cli::cli_abort("Argument {.arg direction} must be either 1 or -1.")
  }
  if (!is.numeric(alpha) || is.complex(alpha) || is.object(alpha) ||
      !is.null(dim(alpha)) || length(alpha) != 1L || !is.finite(alpha) ||
      alpha < 0 || alpha > 1) {
    cli::cli_abort("Argument {.arg alpha} must be a number between 0 and 1.")
  }

  viridis_names <- c(
    "magma", "inferno", "plasma", "viridis",
    "cividis", "rocket", "mako", "turbo"
  )
  pal_names <- viridis_names
  if (!is.null(palette)) {
    valid <- unique(palette[palette %in% pal_names])
    if (length(valid) == 0L) {
      cli::cli_abort("No matching viridis palettes found.")
    }
    unknown <- setdiff(palette, pal_names)
    if (length(unknown)) {
      cli::cli_warn("Skipping unknown viridis palette{?s}: {.val {unknown}}.")
    }
    pal_names <- valid
  } else if (!is.null(pattern)) {
    pal_names <- pal_names[.pal_match_pattern(pattern, pal_names)]
  }
  if (length(pal_names) == 0L) {
    cli::cli_abort("No viridis palettes matched the filters.")
  }
  if (!is.null(index)) {
    keep <- index[index <= length(pal_names) & index >= 1]
    if (!length(keep)) {
      cli::cli_abort(c(
        "{.arg index} selected no palettes.",
        "i" = "Only {length(pal_names)} palette{?s} matched the filters."
      ))
    }
    pal_names <- pal_names[keep]
  }

  pals <- lapply(pal_names, function(nm) {
    cols <- if (n > max_colors) {
      index <- .pal_preview_indices(n, max_colors, TRUE)
      .pal_viridis_preview(n, nm, index, alpha, begin, end, direction)
    } else scales::viridis_pal(
      alpha = alpha,
      begin = begin,
      end = end,
      direction = direction,
      option = nm
    )(n)
    attr(cols, "type") <- "continuous"
    cols
  })
  names(pals) <- pal_names
  attr(pals, "n_total") <- n

  pal_show(pals, max_colors = max_colors, output = output)
}

# ------------- Internal helpers for pal_show colour vector mode ---------------

#' Check if a character vector looks like colours (not palette names)
#' @keywords internal
#' @noRd
.is_color_vector <- function(x) {
  if (length(x) == 0) return(FALSE)
  # Registered names take priority over literal colours.
  pl <- getExportedValue("UtilsR", "palette_list")
  !any(x %in% names(pl)) && .pal_are_colors(x)
}

# R colour names need conversion before use in CSS; keep non-opaque alpha.
.pal_hex <- function(colors) {
  rgba <- grDevices::col2rgb(colors, alpha = TRUE)
  out <- grDevices::rgb(rgba[1L, ], rgba[2L, ], rgba[3L, ], rgba[4L, ],
                       maxColorValue = 255)
  opaque <- rgba[4L, ] == 255
  out[opaque] <- substr(out[opaque], 1L, 7L)
  out
}

#' Display a colour vector as ggplot or gt (internal)
#' @keywords internal
#' @noRd
.pal_show_colors <- function(colors, label = TRUE, label_size = 3,
                             ncol = NULL, output = "gg",
                             max_colors, n = NULL) {
  force(colors)
  force(label)
  force(label_size)
  force(ncol)
  force(output)
  force(max_colors)
  force(n)
  n_total <- if (is.null(n)) length(colors) else n
  n <- min(n_total, max_colors)
  if (n < n_total) {
    cli::cli_inform("Showing {n} of {n_total} colours.")
  }
  colors <- .pal_resize(colors, n, total = n_total)

  # Get labels: use names if available, otherwise hex codes
  color_names <- names(colors)
  hex <- .pal_hex(colors)

  has_name <- rep(FALSE, n)
  if (!is.null(color_names)) {
    has_name <- !is.na(color_names) &
      nzchar(trimws(color_names, whitespace = "[\\h\\v]"))
  }
  labels <- hex
  labels[has_name] <- color_names[has_name]

  # Compute luminance for text contrast
  .luminance <- function(hex_col) {
    r <- strtoi(substr(hex_col, 2, 3), 16L) / 255
    g <- strtoi(substr(hex_col, 4, 5), 16L) / 255
    b <- strtoi(substr(hex_col, 6, 7), 16L) / 255
    # Preview tiles are drawn on white; contrast uses the composited colour.
    if (nchar(hex_col) == 9L) {
      a <- strtoi(substr(hex_col, 8, 9), 16L) / 255
      r <- r * a + 1 - a
      g <- g * a + 1 - a
      b <- b * a + 1 - a
    }
    lin <- function(v) ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
  }
  fg_colors <- ifelse(vapply(hex, .luminance, numeric(1)) > 0.179,
                       "#000000", "#FFFFFF")

  # --- ggplot output ---
  if (output == "gg") {
    # Determine grid layout
    if (is.null(ncol)) ncol <- n
    nrow <- ceiling(n / ncol)

    plot_data <- data.frame(
      color = as.character(colors),
      hex = hex,
      label = labels,
      fg = fg_colors,
      has_name = has_name,
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
      p <- p + ggplot2::scale_colour_identity()
      # Show name/hex on top, hex on bottom (if named)
      if (any(has_name)) {
        p <- p +
          ggplot2::geom_text(ggplot2::aes(label = .data[["label"]],
                             color = .data[["fg"]],
                             vjust = ifelse(.data[["has_name"]], -0.3, 0.5)),
                             size = label_size, fontface = "bold") +
          ggplot2::geom_text(ggplot2::aes(
                             label = ifelse(.data[["has_name"]], .data[["hex"]], ""),
                             color = .data[["fg"]]), size = label_size * 0.75,
                             vjust = 1.2)
      } else {
        p <- p +
          ggplot2::geom_text(ggplot2::aes(label = .data[["label"]],
                             color = .data[["fg"]]), size = label_size,
                             fontface = "bold")
      }
    }

    return(p)
  }

  # --- Console output ---
  if (output == "console") {
    cat("\n")
    pr_section(sprintf("%d colours", n))
    show_color(colors)
    return(invisible(colors))
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
  if (!any(has_name)) {
    tbl_data$name <- NULL
    tbl <- gt::gt(tbl_data) %>%
      gt::cols_label(index = "#", hex = "Hex", preview = "Preview")
  } else {
    tbl <- gt::gt(tbl_data) %>%
      gt::cols_label(index = "#", name = "Name", hex = "Hex", preview = "Preview")
  }

  tbl <- tbl %>%
    .pal_format_preview() %>%
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

  tbl
}
