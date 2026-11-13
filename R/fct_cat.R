# =============================================================================
# fct_cat.R -- Unified factor utility: fct_cat()
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  fct_cat(x, ..., reverse, ref_idx, groups, new_labels, binary_ref)
#         |                                         -- public API
#         +-- L2  .as_factor()          coerce any vector -> factor
#         +-- L2  .register_integer64() register serialized integer64 methods
#         +-- L2  .recode_factor()      rename / reorder / group levels
#         |     +-- L3  .check_integer_index()   validate / normalize indices
#         +-- L2  .do_binary()          collapse to a two-level factor
#               +-- .recode_factor()
#         +-- L2  .relevel_factor()     preserve metadata and missing codes
#               +-- .factor_attributes() clear stale level attributes
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
#'   combined with another active mode. Unnamed reorder arguments must all
#'   use character levels or all use numeric indices; they cannot mix the two.
#' @param reverse A single non-missing logical. Reverse all levels?
#'   Default \code{FALSE}.
#' @param ref_idx The reference levels, as one or more finite, non-missing
#'   integer indices or as level names (\code{ref_idx = "No"}). They form
#'   one group, named by joining them with \code{"_"}; the other levels
#'   collapse to \code{"Oth"}. An unknown name is an error. The reference
#'   label must differ from \code{"Oth"} when other levels remain. A single
#'   \code{0} is the same as \code{NULL}: nothing collapses.
#' @param groups Named list of integer index vectors for custom grouping,
#'   e.g. \code{list(early = 1:2, late = 3:4)}. Names must be non-empty,
#'   and indices must be finite and non-missing.
#' @param new_labels Character vector to rename levels (same length as levels).
#'   Other atomic vectors are coerced to character for compatibility;
#'   lists and other non-atomic objects are not accepted. Length is checked
#'   again after conversion. Duplicate and missing labels retain base
#'   merging and removal semantics.
#' @param binary_ref Deprecated former name of \code{ref_idx}, still accepted
#'   with a warning. Giving both is an error.
#'
#' @return A factor preserving names, class and other attributes. Reordering
#'   preserves all levels, including an explicit \code{NA} level. Recoding
#'   drops unused levels but preserves an explicit \code{NA} level when used.
#'   Matrix-valued contrasts are cleared when output levels differ from input
#'   levels; contrast function names are retained. The \code{scores} attribute
#'   from \code{stats::reorder()} is cleared when levels or their mapping change.
#'
#' @details Numeric indices are converted to native integers after their
#'   values and bounds have been checked, including classed numeric vectors.
#'   Integer64 values require \pkg{bit64}; its methods are loaded when needed,
#'   including for objects restored from serialized files.
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
#' # Binary: by index or by level name
#' fct_cat(factor(c("I","II","III","IV")), ref_idx = 1)
#' fct_cat(factor(c("I","II","III","IV")), ref_idx = c("I", "II"))
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
                    ref_idx = NULL,
                    groups = NULL,
                    new_labels = NULL,
                    binary_ref = NULL) {

  if (!is.logical(reverse) || !is.null(dim(reverse)) || length(reverse) != 1L || is.na(reverse)) {
    cli::cli_abort("{.arg reverse} must be a single non-missing logical value.")
  }

  # `binary_ref`, the former name of `ref_idx`, still works with a warning.
  if (!is.null(binary_ref)) {
    if (!is.null(ref_idx)) {
      cli::cli_abort("Give {.arg ref_idx} only; {.arg binary_ref} is its former name.")
    }
    cli::cli_warn("{.arg binary_ref} of {.fn fct_cat} is deprecated; use {.arg ref_idx}.")
    ref_idx <- binary_ref
  }
  # A single 0 is the same as NULL (no binary collapse), not an active mode.
  if (!is.null(dim(ref_idx)))
    cli::cli_abort("{.arg ref_idx} must be a vector without dimensions.")
  .register_integer64(ref_idx)
  if (is.numeric(ref_idx) && length(ref_idx) == 1L && !is.na(ref_idx) &&
      ref_idx == 0) {
    ref_idx <- NULL
  }

  # --- Mutual exclusivity check ---
  n_modes <- sum(!is.null(ref_idx), !is.null(groups),
                 !is.null(new_labels), reverse, ...length() > 0L)
  if (n_modes > 1) {
    cli::cli_abort("Only one mode at a time: {.arg ...}, {.arg ref_idx}, {.arg groups}, {.arg new_labels}, or {.arg reverse}.")
  }

  if (!is.null(groups) &&
      (!is.list(groups) || !is.null(dim(groups)) || is.null(names(groups)) ||
       anyNA(names(groups)) || any(!nzchar(names(groups))))) {
    cli::cli_abort("{.arg groups} must be a named list with non-empty names, e.g. {.code list(early = 1:2, late = 3:4)}.")
  }
  x <- .as_factor(x)

  # 1. binary -- reference levels by index or by name
  if (!is.null(ref_idx)) {
    if (is.character(ref_idx)) {
      pos <- match(ref_idx, levels(x))
      if (anyNA(pos)) {
        cli::cli_abort("{.arg ref_idx} level{?s} not found: {.val {ref_idx[is.na(pos)]}}.")
      }
      ref_idx <- pos
    } else {
      ref_idx <- .check_integer_index(ref_idx, "ref_idx", nlevels(x))
    }
    return(.do_binary(x, ref_idx))
  }

  # 2. groups
  if (!is.null(groups)) {
    n_levels <- nlevels(x)
    for (i in seq_along(groups)) {
      groups[[i]] <- .check_integer_index(groups[[i]], paste0("groups$", names(groups)[i]), n_levels)
    }
    return(.recode_factor(x, groups, checked_indices = TRUE))
  }

  # 3. new_labels
  if (!is.null(new_labels)) {
    if (!is.atomic(new_labels) || !is.null(dim(new_labels))) {
      cli::cli_abort("{.arg new_labels} must be an atomic vector of labels, not a list or another non-atomic object.")
    }
    old_levels <- levels(x)
    n_lvl <- length(old_levels)
    if (length(new_labels) != n_lvl) {
      cli::cli_abort("{.arg new_labels} must have length {n_lvl} (same as number of levels), got {length(new_labels)}.")
    }
    .register_integer64(new_labels)
    new_labels <- as.character(new_labels)
    if (!is.character(new_labels) || length(new_labels) != n_lvl) {
      cli::cli_abort("After conversion to character, {.arg new_labels} must be a character vector of length {n_lvl}.")
    }
    if (!anyNA(new_labels) && !anyDuplicated(new_labels)) {
      if (identical(old_levels, new_labels)) return(x)
      attr(x, "levels") <- new_labels
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
  if (any(vapply(dots, function(value) !is.null(dim(value)), logical(1))))
    cli::cli_abort("Factor dot arguments must be vectors without dimensions.")

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
    cur <- levels(x)
    is_character <- vapply(dots, is.character, logical(1L))
    if (any(is_character) && !all(is_character)) {
      cli::cli_abort("Reorder arguments cannot mix character levels with numeric or other index types.")
    }
    if (all(is_character)) {
      new_order <- unname(c(...))
    } else {
      indices <- lapply(dots, .check_integer_index,
                        arg_name = "reorder index", n_levels = length(cur))
      new_order <- cur[unlist(indices, use.names = FALSE)]
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
.recode_factor <- function(x, newlevels, checked_indices = FALSE) {
  if (length(newlevels) == 0) return(x)

  lvls <- levels(x)
  if (checked_indices) {
    pos <- unlist(newlevels, use.names = FALSE)
  } else {
    positions <- lapply(newlevels, function(i) {
      if (is.numeric(i) || is.complex(i)) {
        return(.check_integer_index(i, "recode index", length(lvls)))
      }
      if (!is.character(i)) {
        cli::cli_abort("Recode values must be character levels or integer indices.")
      }
      match(i, lvls)
    })
    pos <- unlist(positions, use.names = FALSE)
    if (anyNA(pos)) {
      bad <- unique(unlist(Map(function(i, at) i[is.na(at)], newlevels, positions), use.names = FALSE))
      cli::cli_abort("Level{?s} not found: {.val {bad}}.")
    }
   }
  if (anyDuplicated(pos)) {
    cli::cli_abort("New levels contain non-unique values: {.val {lvls[pos[duplicated(pos)]]}}.")
  }

  mapped <- rep(names(newlevels), lengths(newlevels))
  target <- lvls
  target[pos] <- mapped
  seen <- rep(FALSE, length(lvls))
  seen[pos] <- TRUE
  new_levels <- unique(c(mapped, unname(lvls[!seen])))
  target_id <- match(target, new_levels)
  used <- logical(length(new_levels))
  used[target_id[tabulate(x, nbins = length(lvls)) > 0L]] <- TRUE
  out <- cumsum(used)[target_id][x]
  new_levels <- new_levels[used]
  attributes(out) <- .factor_attributes(x, new_levels,
                                         drop_scores = !identical(target, lvls))
  out
}


# ---- Internal: binary ----
.do_binary <- function(x, ref_idx) {
  if (length(ref_idx) == 0L) {
    cli::cli_abort("{.arg ref_idx} must contain at least one reference index.")
  }
  n_lvl <- nlevels(x)
  lvls <- levels(x)

  ref_name <- paste(lvls[ref_idx], collapse = "_")
  other <- setdiff(seq_len(n_lvl), ref_idx)
  if (identical(ref_name, "Oth") && length(other) > 0L) {
    cli::cli_abort("The reference label conflicts with {.val Oth}, the label for other levels.")
  }
  g <- stats::setNames(
    list(ref_idx, other),
    c(ref_name, "Oth")
  )
  .recode_factor(x, g)
}


# ---- Shared helpers ----
.relevel_factor <- function(x, new_levels) {
  if (identical(levels(x), new_levels)) return(x)
  out <- match(levels(x), new_levels)[x]
  attributes(out) <- .factor_attributes(x, new_levels)
  out
}

.factor_attributes <- function(x, new_levels, old_levels = levels(x),
                                drop_scores = FALSE) {
  at <- attributes(x)
  changed <- !identical(old_levels, new_levels)
  ctr <- at[["contrasts"]]
  if ((is.matrix(ctr) || inherits(ctr, "Matrix")) && changed) {
    at[["contrasts"]] <- NULL
  }
  if (changed || drop_scores) at[["scores"]] <- NULL
  at[["levels"]] <- new_levels
  at
}

.as_factor <- function(x) {
  .register_integer64(x)
  if (is.factor(x)) return(x)
  if (inherits(x, "Period")) {
    labels <- as.character(.butterfly_category_labels(x))
    names(labels) <- names(x)
    return(factor(labels))
  }
  if (inherits(x, c("Date", "POSIXt"))) {
    labels <- .butterfly_category_labels(x)
    if (!identical(labels, x)) {
      names(labels) <- names(x)
      return(factor(labels, levels = unique(labels[order(x, na.last = NA)])))
    }
  }
  if (inherits(x, "haven_labelled")) x <- vctrs::vec_data(.scatter_axis_values(x))
  if (is.double(x) && identical(class(x), "AsIs") && is.null(dim(x))) x <- unclass(x)
  if (is.double(x) && !is.object(x) && is.null(dim(x))) {
    distinct <- sort(unique(x), na.last = NA)
    labels <- as.character(distinct)
    if (anyDuplicated(labels)) labels <- sprintf("%.17g", distinct)
    return(structure(match(x, distinct), names = names(x), levels = labels, class = "factor"))
  }
  factor(x)
}

.register_integer64 <- function(x) {
  if (inherits(x, "integer64") && !requireNamespace("bit64", quietly = TRUE)) {
    cli::cli_abort("Interpreting integer64 values requires the {.pkg bit64} package.")
  }
}

.check_integer_index <- function(x, arg_name, n_levels) {
  .register_integer64(x)
  if (!is.numeric(x) || is.complex(x) || !is.null(dim(x)) || anyNA(x) ||
      ((!is.integer(x) || is.object(x)) &&
       (any(!is.finite(x)) || any(x != trunc(x))))) {
    cli::cli_abort("{.arg {arg_name}} must contain finite integer values, got: {.val {x}}.")
  }
  oob <- x < 1 | x > n_levels
  if (any(oob)) {
    cli::cli_abort("{.arg {arg_name}} must be between 1 and {n_levels}, got: {.val {x[oob]}}.")
  }
  as.integer(x)
}
