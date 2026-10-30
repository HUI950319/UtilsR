# =============================================================================
# utils-resolve.R -- Shared input-resolution helpers
# =============================================================================
#
# Internal mirrors of RegR's `.resolve_*` family, kept here in UtilsR (the
# theme / palette home) so UtilsR's own plot helpers can use them without a
# circular dependency on RegR. Where RegR's versions reference `UtilsR::...`
# (RegR being external to UtilsR), these use UtilsR's own internal objects
# directly (`theme_km`, `pal_lancet`, `pal_get`, `palette_list`).
#
# Architecture (1 layer, no public API):
#
#   L2  .resolve_theme(theme_use)        NULL | name | function | theme
#                                        -> ggplot2 theme
#       .resolve_color(palette, n, ...)  NULL | name | colour(s)
#                                        -> colour vector
#       .save_sized(p, save, panel, ...) report the page size, save through
#                                        RegR::save_plt()
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
# internal `.resolve_color()`; registered names go through `pal_get()`, literal
# colours are checked and returned as given, and anything R cannot draw stops
# with an error. Returns an UNNAMED vector (callers add names via setNames()).
#
#   palette = NULL                          # default -> `default` (pal_lancet)
#   palette = "lancet" / "Reds"             # registered name -> pal_get
#   palette = "red"                         # literal single colour -> repeated
#   palette = c("#ff0000", "#0000ff", ...)  # literal colour vector  -> as-is

#' Resolve a colour specification to a colour vector
#'
#' @param palette NULL, a registered palette name (resolved via [pal_get()]), a
#'   single literal colour, or a character vector of colours.
#' @param n Optional integer size. Registered palettes use `pal_get(palette,
#'   n = n)` (interpolating when `n` is longer); literal vectors and `default`
#'   use [rep_len()], with a warning when several colours have to repeat. `NULL`
#'   (default) returns the palette at its natural length.
#' @param default Fallback colour vector when `palette = NULL`. Default
#'   [pal_lancet].
#' @return An unnamed character vector: hex colours from a registered palette,
#'   literal colours as given.
#' @keywords internal
#' @noRd
.resolve_color <- function(palette = NULL, n = NULL,
                           default = pal_lancet) {

  # One colour repeated is a choice; several repeated make groups share a colour.
  caller <- rlang::caller_env()
  sized <- function(x) {
    if (is.null(n)) return(x)
    if (length(x) > 1L && length(x) < n) {
      cli::cli_warn(c(
        "{length(x)} colours for {n} groups, so colours repeat.",
        "i" = "Supply more colours, or a palette name, which interpolates."
      ), call = caller)
    }
    rep_len(x, n)
  }

  # NULL -> default (optionally sized to n)
  if (is.null(palette)) return(sized(as.character(default)))

  if (!is.atomic(palette) || length(palette) == 0L) {
    cli::cli_abort(
      "Colours must be a palette name or a non-empty colour vector, not {.cls {class(palette)}}.",
      call = rlang::caller_env()
    )
  }

  # Single string: a registered palette name wins, anything else is a literal
  # colour. That is repeated directly: pal_get() would interpolate it through
  # colorRampPalette(), which drops an alpha channel.
  pl_names <- names(getExportedValue("UtilsR", "palette_list"))
  if (length(palette) == 1L && is.character(palette) && palette %in% pl_names) {
    return(as.character(pal_get(palette, n = n)))
  }

  # Literal colour(s): checked here, as a bad one otherwise only surfaces when
  # the plot is drawn, as "Problem while converting geom to grob".
  out <- as.character(palette)
  drawable <- vapply(out, function(v) {
    tryCatch({
      grDevices::col2rgb(v)
      TRUE
    }, error = function(e) FALSE)
  }, logical(1L), USE.NAMES = FALSE)
  if (!all(drawable)) {
    bad <- unique(out[!drawable])
    browse <- "Browse with {.code UtilsR::pal_list()} or visualise with {.code UtilsR::pal_show()}."
    if (length(out) > 1L) {
      cli::cli_abort(c("Not a valid colour: {.val {bad}}.", "*" = browse),
                     call = rlang::caller_env())
    }
    distance <- utils::adist(out, pl_names, ignore.case = TRUE)[1L, ]
    near <- pl_names[order(distance)][seq_len(min(3L, sum(distance <= 2L)))]
    cli::cli_abort(c(
      "{.val {bad}} is neither a registered palette nor a valid colour.",
      "i" = if (length(near) > 0L) "Did you mean {.val {near}}?",
      "*" = browse
    ), call = rlang::caller_env())
  }
  sized(out)
}


# ---- .save_sized -------------------------------------------------------------

# The save side effect of the plot functions: the page the plot is laid out
# for -- `panel` inches per panel, measured beside its axis text and legends by
# RegR's `.plot_canvas_size()`, or a given `size` (`panel` itself for an object
# ggplot2 cannot lay out, such as ggVennDiagram's UpSet plot) -- is printed
# with a pasteable `save` line, kept as `attr(p, "plot_size")` and handed to a
# `save` list that leaves the dimensions out. UtilsR only suggests RegR:
# without a RegR that provides these helpers the plot is returned as it is,
# and only a non-empty `save` is an error.
.save_sized <- function(p, save, panel, lead, filename, size = NULL) {
  if (!is.null(save) && !is.list(save)) {
    cli::cli_abort("{.arg save} must be NULL or a named list.")
  }
  regr <- requireNamespace("RegR", quietly = TRUE) &&
    exists(".save_sized", envir = asNamespace("RegR"), inherits = FALSE)
  if (!regr) {
    if (length(save)) {
      cli::cli_abort(paste("Package {.pkg RegR} (0.1.3 or later) is required",
                           "when {.arg save} is non-empty."))
    }
    return(p)
  }
  ns <- asNamespace("RegR")
  if (is.null(size)) {
    size <- if (inherits(p, c("ggplot", "patchwork", "gtable"))) {
      ns$.plot_canvas_size(p, panel)
    } else {
      panel
    }
  }
  ns$.save_sized(p, save, size, lead = lead, filename = filename)
}

# Apply a plot function's `fmt_text` list to the finished plot before
# `.save_sized()`, so the saved page and its measured size carry the new text.
# The values themselves are checked by fmt_text().
.apply_fmt_text <- function(p, value, call = rlang::caller_env()) {
  if (is.null(value)) return(p)
  if (!is.list(value)) {
    cli::cli_abort("{.arg fmt_text} must be NULL or a named list.", call = call)
  }
  if (length(value) == 0L) return(p)
  value_names <- names(value)
  if (is.null(value_names) || anyNA(value_names) || any(!nzchar(value_names)) ||
      anyDuplicated(value_names) || "plot" %in% value_names) {
    cli::cli_abort(paste("{.arg fmt_text} must have unique, non-empty names",
                         "of {.fn fmt_text} arguments other than {.arg plot}."),
                   call = call)
  }
  do.call(fmt_text, c(list(p), value))
}

# Merge a partial named-list argument (e.g. `label_args`) into its documented
# defaults, rejecting unnamed, duplicated or unknown fields. Errors name the
# plotting function that called it.
.merge_args <- function(value, defaults, arg, call = rlang::caller_env()) {
  if (!is.list(value)) {
    cli::cli_abort("{.arg {arg}} must be a named list.", call = call)
  }
  if (length(value) == 0L) return(defaults)
  value_names <- names(value)
  if (is.null(value_names) || anyNA(value_names) || any(!nzchar(value_names))) {
    cli::cli_abort("Every element of {.arg {arg}} must have a non-empty name.",
                   call = call)
  }
  if (anyDuplicated(value_names)) {
    cli::cli_abort("{.arg {arg}} must not contain duplicate names.", call = call)
  }
  unknown <- setdiff(value_names, names(defaults))
  if (length(unknown) > 0L) {
    cli::cli_abort("{.arg {arg}} has unknown field{?s}: {.val {unknown}}.",
                   call = call)
  }
  utils::modifyList(defaults, value, keep.null = TRUE)
}
