# =============================================================================
# fct_cat.R -- Unified factor utility: fct_cat()
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  fct_cat(x, ..., reverse, binary_ref, groups, new_labels)
#         |                                         -- public API
#         +-- L2  .as_factor()          coerce any vector -> factor
#         +-- L2  .recode_factor()      rename / reorder / group levels
#         |     +-- L3  .check_integer_index()   validate integer indices
#         +-- L2  .do_binary()          collapse to a two-level factor
#               +-- .recode_factor()
#         +-- L2  .relevel_factor()     preserve metadata and missing codes
#               +-- .factor_attributes() clear stale matrix contrasts
# =============================================================================

#' Unified Factor Manipulation
#'
#' One function for all single-vector factor operations. Auto-detects the
#' action from arguments. For combining multiple columns into one factor,
#' see [fct_to_combine()]. For grouping levels by integer indices with
#' auto-named groups (e.g. `g1/3`), see [fct_to_group()].
#'
#' @param x A factor or character vector.
#' @param ... For recode: named args (new = old). For reorder: level names
#'   or integer indices in desired order (unnamed). Must be ALL named or ALL
#'   unnamed. Each recode group may use character levels or finite,
#'   non-missing integer indices. Unknown levels are errors. Cannot be
#'   combined with another active mode.
#' @param reverse A single non-missing logical. Reverse all levels?
#'   Default \code{FALSE}.
#' @param binary_ref Finite, non-missing integer index(es) of reference level(s). Others
#'   collapse to \code{"Oth"}. The reference label must differ from
#'   \code{"Oth"} when other levels remain.
#' @param groups Named list of integer index vectors for custom grouping,
#'   e.g. \code{list(early = 1:2, late = 3:4)}. Names must be non-empty,
#'   and indices must be finite and non-missing.
#' @param new_labels Character vector to rename levels (same length as levels).
#'
#' @return A factor preserving names, class and other attributes. Reordering
#'   preserves all levels, including an explicit \code{NA} level. Recoding
#'   drops unused levels but preserves an explicit \code{NA} level when used.
#'   Matrix-valued contrasts are cleared when output levels differ from input
#'   levels; contrast function names are retained.
#'
#' @examples
#' x <- factor(letters[1:6])
#'
#' # Recode (named ...)
#' fct_cat(x, AB = c("a","b"), CD = c("c","d"))
#' fct_cat(x, g1 = 1:3, g2 = 4:6)
#'
#' # Reorder (unnamed ...): by level name or by integer index
#' fct_cat(factor(letters[1:4]), "c", "b")
#' fct_cat(factor(letters[1:4]), 3, 2)
#'
#' # Reverse
#' fct_cat(factor(letters[1:4]), reverse = TRUE)
#'
#' # Binary
#' fct_cat(factor(c("I","II","III","IV")), binary_ref = 1)
#'
#' # Group
#' fct_cat(factor(c("I","II","III","IV")), groups = list(early = 1:2, late = 3:4))
#'
#' # Relabel
#' fct_cat(factor(c("I","II","III","IV")), new_labels = c("One","Two","Three","Four"))
#'
#' # For combining multiple columns into one factor, use [fct_to_combine()]:
#' \dontrun{
#' df %>% mutate(grp = fct_to_combine(sex, age))
#' fct_to_combine(df$sex, df$age)
#' }
#'
#' @export
#' @family factor tools
fct_cat <- function(x, ...,
                    reverse = FALSE,
                    binary_ref = NULL,
                    groups = NULL,
                    new_labels = NULL) {

  if (!is.logical(reverse) || length(reverse) != 1L || is.na(reverse)) {
    cli::cli_abort("{.arg reverse} must be a single non-missing logical value.")
  }

  # --- Mutual exclusivity check ---
  n_modes <- sum(!is.null(binary_ref), !is.null(groups),
                 !is.null(new_labels), reverse, ...length() > 0L)
  if (n_modes > 1) {
    cli::cli_abort("Only one mode at a time: {.arg ...}, {.arg binary_ref}, {.arg groups}, {.arg new_labels}, or {.arg reverse}.")
  }

  x <- .as_factor(x)

  # 1. binary
  if (!is.null(binary_ref)) {
    .check_integer_index(binary_ref, "binary_ref")
    return(.do_binary(x, binary_ref))
  }

  # 2. groups
  if (!is.null(groups)) {
    if (!is.list(groups) || is.null(names(groups)) ||
        anyNA(names(groups)) || any(!nzchar(names(groups)))) {
      cli::cli_abort("{.arg groups} must be a named list with non-empty names, e.g. {.code list(early = 1:2, late = 3:4)}.")
    }
    for (i in seq_along(groups)) {
      .check_integer_index(groups[[i]], paste0("groups$", names(groups)[i]))
    }
    return(.recode_factor(x, groups))
  }

  # 3. new_labels
  if (!is.null(new_labels)) {
    old_levels <- levels(x)
    n_lvl <- length(old_levels)
    if (length(new_labels) != n_lvl) {
      cli::cli_abort("{.arg new_labels} must have length {n_lvl} (same as number of levels), got {length(new_labels)}.")
    }
    if (is.character(new_labels) && !anyNA(new_labels) &&
        !anyDuplicated(new_labels)) {
      attr(x, "levels") <- as.character(new_labels)
    } else {
      levels(x) <- new_labels
    }
    attributes(x) <- .factor_attributes(x, levels(x), old_levels)
    return(x)
  }

  # 4. reverse
  if (reverse) {
    return(.relevel_factor(x, rev(levels(x))))
  }

  # 5. ... — named = recode, unnamed = reorder
  dots <- list(...)
  if (length(dots) == 0) return(x)

  nms <- names(dots)
  # NB: for all-unnamed dots, names() is NULL -> use a length-matched FALSE
  # vector so all(has_names) is FALSE (reorder), not all(logical(0)) == TRUE.
  has_names <- if (is.null(nms)) logical(length(dots)) else nzchar(nms)
  if (any(has_names) && !all(has_names)) {
    cli::cli_abort("{.arg ...} must be ALL named (recode) or ALL unnamed (reorder). Mixed named/unnamed args are not allowed.")
  }

  if (all(has_names)) {
    return(.recode_factor(x, dots))
  } else {
    new_order <- c(...)
    cur <- levels(x)
    # Allow integer indices (1-based) in addition to level names.
    if (!is.character(new_order)) {
      .check_integer_index(new_order, "reorder index")
      oob <- new_order < 1 | new_order > length(cur)
      if (any(oob)) {
        cli::cli_abort("Indices must be between 1 and {length(cur)}, got: {.val {new_order[oob]}}.")
      }
      new_order <- cur[new_order]
    }
    bad <- setdiff(new_order, cur)
    if (length(bad) > 0) {
      cli::cli_abort("Level{?s} not found: {.val {bad}}.")
    }
    if (anyDuplicated(new_order)) {
      cli::cli_abort("Reorder levels must not be duplicated.")
    }
    return(.relevel_factor(x, c(new_order, setdiff(cur, new_order))))
  }
}


# ---- Internal: recode ----
.recode_factor <- function(x, newlevels) {
  if (length(newlevels) == 0) return(x)

  lvls <- levels(x)
  newlevels <- lapply(newlevels, function(i) {
    if (is.numeric(i) || is.complex(i)) {
      .check_integer_index(i, "recode index")
      if (any(i < 1 | i > length(lvls))) {
        cli::cli_abort("Indices must be between 1 and {length(lvls)}, got: {.val {i[i < 1 | i > length(lvls)]}}.")
      }
      return(lvls[i])
    }
    if (!is.character(i)) {
      cli::cli_abort("Recode values must be character levels or integer indices.")
    }
    bad <- setdiff(i, lvls)
    if (length(bad) > 0L) {
      cli::cli_abort("Level{?s} not found: {.val {bad}}.")
    }
    i
  })

  all_vals <- unlist(newlevels, use.names = FALSE)
  if (anyDuplicated(all_vals)) {
    cli::cli_abort("New levels contain non-unique values: {.val {all_vals[duplicated(all_vals)]}}.")
  }

  # Keep unmatched levels as-is
  matched <- unlist(newlevels)
  unmatched <- setdiff(lvls, matched)
  newlevels <- c(newlevels, stats::setNames(as.list(unmatched), unmatched))

  levels(x) <- newlevels
  .relevel_factor(x, levels(x)[tabulate(x, nbins = nlevels(x)) > 0L],
                  old_levels = lvls)
}


# ---- Internal: binary ----
.do_binary <- function(x, binary_ref) {
  n_lvl <- nlevels(x)
  lvls <- levels(x)

  if (any(binary_ref < 1 | binary_ref > n_lvl)) {
    cli::cli_abort("{.arg binary_ref} must be between 1 and {n_lvl}.")
  }

  ref_name <- paste(lvls[binary_ref], collapse = "_")
  other <- setdiff(seq_len(n_lvl), binary_ref)
  if (identical(ref_name, "Oth") && length(other) > 0L) {
    cli::cli_abort("The reference label conflicts with {.val Oth}, the label for other levels.")
  }
  g <- stats::setNames(
    list(binary_ref, other),
    c(ref_name, "Oth")
  )
  .recode_factor(x, g)
}


# ---- Shared helpers ----
.relevel_factor <- function(x, new_levels, old_levels = levels(x)) {
  out <- match(levels(x), new_levels)[as.integer(x)]
  attributes(out) <- .factor_attributes(x, new_levels, old_levels)
  out
}

.factor_attributes <- function(x, new_levels, old_levels = levels(x)) {
  at <- attributes(x)
  ctr <- at[["contrasts"]]
  if ((is.matrix(ctr) || inherits(ctr, "Matrix")) &&
      !identical(old_levels, new_levels)) {
    at[["contrasts"]] <- NULL
  }
  at[["levels"]] <- new_levels
  at
}

.as_factor <- function(x) {
  if (is.factor(x)) x else factor(x)
}

.check_integer_index <- function(x, arg_name) {
  if (!is.numeric(x) || is.complex(x) || !is.null(dim(x)) || anyNA(x) ||
      any(!is.finite(x)) || any(x != trunc(x))) {
    cli::cli_abort("{.arg {arg_name}} must contain finite integer values, got: {.val {x}}.")
  }
}
