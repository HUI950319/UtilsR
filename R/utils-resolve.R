# =============================================================================
# utils-resolve.R -- shared input-resolution helpers
# =============================================================================
#
# Internal helpers mirroring RegR's `.resolve_*` family, kept here in UtilsR
# (the theme / palette home) so UtilsR's own plot helpers can use them without
# a circular dependency on RegR. Where RegR's versions reference `UtilsR::...`
# (because RegR is external to UtilsR), these use UtilsR's own internal objects
# directly (`theme_km`, `pal_lancet`, `pal_get`, `palette_list`).
#
#   .resolve_theme(theme_use)        NULL / name / function / theme -> theme
#   .resolve_color(palette, n, ...)  NULL / name / colour(s)        -> hex vector
# =============================================================================


# ---- .resolve_theme --------------------------------------------------------

#' Resolve `theme_use` input to a ggplot2 theme object
#'
#' Accepts a theme object / theme function / function-name string and returns a
#' concrete `ggplot2::theme`. `NULL` -> UtilsR's default [theme_km] (falls back
#' to [ggplot2::theme_bw()]). Mirrors RegR's internal `.resolve_theme()`.
#'
#' @param theme_use NULL / character / function / theme object.
#' @return A `ggplot2::theme` object.
#' @keywords internal
#' @noRd
.resolve_theme <- function(theme_use) {
  if (is.null(theme_use)) {
    thm <- tryCatch(theme_km, error = function(e) NULL)
    if (!is.null(thm)) {
      if (inherits(thm, "theme")) return(thm)
      if (is.function(thm))       return(thm())
    }
    return(ggplot2::theme_bw())
  }
  if (is.character(theme_use)) {
    fn <- tryCatch(match.fun(theme_use), error = function(e) NULL)
    if (is.null(fn))
      fn <- tryCatch(getExportedValue("UtilsR", theme_use),
                     error = function(e) NULL)
    if (is.null(fn))
      stop(sprintf("Theme '%s' not found", theme_use), call. = FALSE)
    if (inherits(fn, "theme")) return(fn)
    return(fn())
  }
  if (inherits(theme_use, "theme")) return(theme_use)
  if (is.function(theme_use))       return(theme_use())
  stop("'theme_use' must be NULL, character, function, or theme object",
       call. = FALSE)
}


# ---- .resolve_color --------------------------------------------------------
#
# Centralises the "palette name OR colour vector" resolution. Mirrors RegR's
# internal `.resolve_color()`; built on `pal_get()` with a literal-colour
# fallback. Returns an UNNAMED hex vector (callers add names via setNames()).
#
#   palette = NULL                          # default -> `default` (pal_lancet)
#   palette = "lancet" / "Reds"             # registered name -> pal_get
#   palette = "red"                         # literal single colour -> recycled
#   palette = c("#ff0000", "#0000ff", ...)  # literal colour vector  -> as-is

#' Resolve a colour specification to a hex colour vector
#'
#' @param palette NULL, a registered palette name (resolved via [pal_get()]), a
#'   single literal colour, or a character vector of colours.
#' @param n Optional integer size. Registered palettes use `pal_get(palette,
#'   n = n)` (recycling / interpolation); literal vectors use [rep_len()].
#'   `NULL` (default) returns the palette at its natural length.
#' @param default Fallback colour vector when `palette = NULL`. Default
#'   [pal_lancet].
#' @return A character vector of hex colours (unnamed).
#' @keywords internal
#' @noRd
.resolve_color <- function(palette = NULL, n = NULL,
                           default = pal_lancet) {

  # NULL -> default (optionally sized to n)
  if (is.null(palette)) {
    out <- as.character(default)
    if (!is.null(n)) out <- rep_len(out, n)
    return(out)
  }

  # Single string: try registered palette, fall back to literal colour.
  if (length(palette) == 1L && is.character(palette)) {
    return(tryCatch(
      suppressMessages(as.character(pal_get(palette, n = n))),
      error = function(e) {
        is_hex   <- grepl("^#", palette)
        is_named <- tolower(palette) %in% tolower(grDevices::colors())
        if (!is_hex && !is_named) {
          pl_names <- tryCatch(names(palette_list),
                               error = function(e2) character(0))
          if (length(pl_names) > 0L) {
            cli::cli_inform(c(
              "i" = "Palette {.val {palette}} not in registry; using as literal colour.",
              "*" = "{length(pl_names)} palettes available. Examples: {.val {head(pl_names, 8)}}",
              "*" = "Browse with {.code UtilsR::pal_list()} or visualise with {.code UtilsR::pal_show()}."
            ))
          }
        }
        v <- as.character(palette)
        if (!is.null(n)) rep_len(v, n) else v
      }
    ))
  }

  # Multi-element vector: use as-is (sized to n if requested)
  out <- as.character(palette)
  if (!is.null(n)) out <- rep_len(out, n)
  out
}
