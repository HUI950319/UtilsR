# =============================================================================
# utils-resolve.R -- Shared input-resolution helpers
# =============================================================================
#
# The `.resolve_*` helpers UtilsR's own plot functions need, kept here (the theme
# / palette home) without a circular dependency on RegR. `.resolve_theme()` and
# `.resolve_color()` live only here: they are exported, as the `.cat_*` helpers
# are, and RegR imports them.
#
# Architecture (1 layer; the two resolvers are exported for RegR):
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
#' The theme resolver shared by plotting functions in UtilsR and RegR. Accepts
#' a theme object, a function returning a theme, or a function-name string.
#' \code{NULL} uses \code{\link{theme_km}}, with \code{ggplot2::theme_bw()}
#' as the fallback.
#' Names are looked up as functions visible to the immediate caller, then as
#' UtilsR exports, then as ggplot2 exports. Pass a function or theme object for
#' a local custom theme used through a plotting wrapper.
#' Errors evaluating a visible binding or calling a theme function are preserved.
#' Theme functions are called without arguments by default. Supply settings in
#' a closure or pass them through \code{...}.
#'
#' @param theme_use \code{NULL}, a single non-missing, non-empty theme name, a function
#'   returning a theme, or a theme object.
#' @param ... Arguments forwarded to the theme function when one is used.
#'   Ignored when the specification resolves to a theme object.
#' @return A ggplot2 theme object.
#'
#' @examples
#' .resolve_theme("theme_bw")
#' .resolve_theme("theme_km")
#' .resolve_theme(ggplot2::theme_bw(base_size = 12))
#' .resolve_theme(function() ggplot2::theme_bw(base_size = 16))
#'
#' @family ggplot2 themes
#' @keywords internal
#' @export
.resolve_theme <- function(theme_use, ...) {
  theme_name <- NULL
  if (is.null(theme_use)) {
    thm <- tryCatch(theme_km, error = function(e) NULL)
    theme_use <- if (inherits(thm, "theme") || is.function(thm)) thm
                 else ggplot2::theme_bw()
  }
  if (is.character(theme_use)) {
    if (length(theme_use) != 1L || !is.null(dim(theme_use)) ||
        anyNA(theme_use) || !nzchar(trimws(theme_use, whitespace = "[\\h\\v]")))
      stop("'theme_use' must be a single non-missing, non-empty theme name",
           call. = FALSE)
    theme_name <- theme_use
    fn <- get0(theme_use, envir = parent.frame(), mode = "function")
    if (is.null(fn) && theme_use %in% getNamespaceExports("UtilsR"))
      fn <- getExportedValue("UtilsR", theme_use)
    if (is.null(fn) && theme_use %in% getNamespaceExports("ggplot2"))
      fn <- getExportedValue("ggplot2", theme_use)
    if (is.null(fn))
      stop(sprintf("Theme '%s' not found", theme_use), call. = FALSE)
    theme_use <- fn
  }
  if (inherits(theme_use, "theme")) return(theme_use)
  if (is.function(theme_use)) {
    thm <- theme_use(...)
    if (!inherits(thm, "theme"))
      stop(sprintf("'theme_use'%s must return a ggplot2 theme object; got <%s>",
                   if (is.null(theme_name)) "" else sprintf(" (factory '%s')", theme_name),
                   class(thm)[1L]), call. = FALSE)
    return(thm)
  }
  stop("'theme_use' must be NULL, character, function, or theme object",
       call. = FALSE)
}


# ---- .resolve_color --------------------------------------------------------
#
# Centralises the "palette name OR colour vector" resolution of the plot
# functions here and in RegR. Registered names go through `pal_get()`, literal
# colours are checked (numeric indices are fixed to hex), and invalid input stops
# with an error. Returns an UNNAMED vector (callers add names via setNames()).
#
#   palette = NULL                          # default -> `default` (pal_lancet)
#   palette = "lancet" / "Reds"             # registered name -> pal_get
#   palette = "red"                         # literal single colour -> repeated
#   palette = c("#ff0000", "#0000ff", ...)  # literal colour vector  -> as-is

#' Resolve a colour specification to a colour vector
#'
#' The colour handling shared by the plot functions of UtilsR and RegR, exported
#' for those packages. For colours in your own code use \code{\link{pal_get}()}.
#'
#' @param palette \code{NULL}, a registered palette name (resolved via
#'   \code{\link{pal_get}()}), a single literal colour, or a colour vector.
#'   Vectors must have no dimensions and contain plain character or numeric
#'   values, logical missing values, or factors (converted to character).
#'   Other classes, including labelled, integer64 and date-time vectors, are
#'   not supported; convert these explicitly before choosing colours.
#'   Numeric colour indices, including numeric strings, are resolved against
#'   the current \code{grDevices::palette()} and returned as fixed RGBA hex
#'   colours. Indices must be finite and fit in an R integer after truncation.
#'   Other literal strings and missing colours are kept as given.
#'   Anything R cannot draw is an error naming the calling function.
#' @param n Optional plain integer or double scalar with a whole-number value
#'   from zero to \code{.Machine$integer.max}, without a class or dimensions.
#'   Registered palettes use
#'   \code{pal_get(palette, n = n)} (interpolating when \code{n} is longer);
#'   literal vectors and \code{default} use \code{\link{rep_len}()}, with a
#'   warning when several colours have to repeat. \code{NULL} (default) returns
#'   the palette at its natural length.
#' @param default Fallback colour vector when \code{palette = NULL}. Default
#'   \code{\link{pal_lancet}}. Must be non-empty and contain valid literal
#'   colours; registered palette names are not expanded here.
#' @return An unnamed character vector: hex colours from a registered palette,
#'   fixed RGBA hex colours for numeric indices, and other literal colours as
#'   given.
#'
#' @examples
#' .resolve_color("lancet", n = 3)
#' .resolve_color("#FF000080", n = 2)
#' .resolve_color(NULL, n = 2)
#'
#' @export
.resolve_color <- function(palette = NULL, n = NULL,
                           default = pal_lancet) {

  # One colour repeated is a choice; several repeated make groups share a colour.
  caller <- rlang::caller_env()
  if (!is.null(n) && !(is.numeric(n) && !is.complex(n) && !is.object(n) &&
                       is.null(dim(n)) && length(n) == 1L && is.finite(n) &&
                       n >= 0 && n <= .Machine$integer.max && n == floor(n))) {
    cli::cli_abort("{.arg n} must be a plain non-negative whole number in the supported integer range, or {.code NULL}.",
                   call = caller)
  }
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

  # Defaults follow the literal-colour checks, without palette-name dispatch.
  using_default <- is.null(palette)
  if (using_default) palette <- default
  color_arg <- if (using_default) "default" else "palette"

  if (!is.atomic(palette) || length(palette) == 0L) {
    cli::cli_abort(
      "Colours in {.arg {color_arg}} must be a palette name or a non-empty colour vector, not {.cls {class(palette)}}.",
      call = rlang::caller_env()
    )
  }
  if (is.factor(palette) && is.null(dim(palette))) palette <- as.character(palette)
  if (!is.null(dim(palette)) || is.object(palette) ||
      !(is.character(palette) || (is.numeric(palette) && !is.complex(palette)) ||
        (is.logical(palette) && all(is.na(palette))))) {
    cli::cli_abort(
      "{.arg {color_arg}} must be a one-dimensional, plain colour vector (character, numeric, logical NA, or factor), not {.cls {class(palette)}}.",
      call = caller
    )
  }

  # Single string: a registered palette name wins, anything else is a literal
  # colour, repeated as given.
  pl_names <- names(getExportedValue("UtilsR", "palette_list"))
  if (!using_default && length(palette) == 1L && is.character(palette) && palette %in% pl_names) {
    return(as.character(pal_get(palette, n = n)))
  }

  # Literal colour(s): checked here, as a bad one otherwise only surfaces when
  # the plot is drawn, as "Problem while converting geom to grob".
  out <- as.character(palette)
  numeric_input <- is.numeric(palette)
  draw_input <- if (numeric_input) unname(palette) else out
  numeric_colour <- if (numeric_input) !is.na(palette) | is.nan(palette) else grepl("^[0-9]", out)
  bad_index <- integer()
  if (any(numeric_colour)) {
    index <- if (numeric_input) draw_input[numeric_colour] else {
      suppressWarnings(as.numeric(out[numeric_colour]))
    }
    safe <- is.finite(index) & index >= 0 & trunc(index) <= .Machine$integer.max
    if (numeric_input) safe <- safe & index > 0
    bad_index <- which(numeric_colour)[!safe]
    # Keep bad tokens for diagnostics, but never pass them to the native cast.
    if (length(bad_index)) draw_input[bad_index] <- NA
  }
  drawable <- tryCatch({
    check <- if (length(draw_input) > 1024L && .pal_use_unique(draw_input)) {
      unique(draw_input)
    } else {
      draw_input
    }
    grDevices::col2rgb(check)
    rep(TRUE, length(out))
  }, error = function(e) {
    # Find every bad value only when parsing the whole vector fails.
    candidates <- unique(draw_input)
    valid <- vapply(candidates, function(v) {
      tryCatch({
        grDevices::col2rgb(v)
        TRUE
      }, error = function(e) FALSE)
    }, logical(1L), USE.NAMES = FALSE)
    valid[match(draw_input, candidates)]
  })
  drawable[bad_index] <- FALSE
  if (!all(drawable)) {
    bad <- unique(out[!drawable])
    browse <- "Browse with {.code UtilsR::pal_list()} or visualise with {.code UtilsR::pal_show()}."
    if (using_default || length(out) > 1L || length(bad_index)) {
      cli::cli_abort(c("Not a valid colour in {.arg {color_arg}}: {.val {bad}}.",
                       "i" = if (length(bad_index)) "A numeric colour index must be finite and in the supported integer range after truncation.",
                       "*" = browse),
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
  if (any(numeric_colour)) {
    rgba <- grDevices::col2rgb(draw_input[numeric_colour], alpha = TRUE)
    out[numeric_colour] <- grDevices::rgb(rgba[1L, ], rgba[2L, ], rgba[3L, ],
                                        rgba[4L, ], maxColorValue = 255)
  }
  sized(out)
}

# Resolve already-matched named values as literals, including a single value.
.resolve_color_values <- function(colors, arg) {
  if (!length(colors)) return(colors)
  caller <- rlang::caller_env()
  resolved <- tryCatch(.resolve_color(NULL, default = unname(colors)),
    error = function(e) {
      cli::cli_abort("{.arg {arg}} contains invalid colours.", parent = e,
                     call = caller)
    })
  stats::setNames(resolved, names(colors))
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
