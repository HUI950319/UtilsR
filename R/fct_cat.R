# ============================================================================
# fct_cat.R -- Unified factor utility: fct_cat()
# ============================================================================

#' Unified Factor Manipulation
#'
#' One function for all factor operations. Works on vectors (usable in
#' \code{mutate()}) and auto-detects the action from arguments.
#'
#' @param x A factor or character vector. For \code{combine} mode this is
#'   optional -- if missing, all columns listed in \code{combine} are used.
#' @param ... For recode: named args (new = old). For reorder: level names
#'   in desired order (unnamed strings). Must be ALL named or ALL unnamed.
#' @param reverse Logical. Reverse all levels? Default \code{FALSE}.
#' @param binary_ref Integer index(es) of reference level(s). Others
#'   collapse to \code{"Oth"}.
#' @param groups Named list of integer index vectors for custom grouping,
#'   e.g. \code{list(early = 1:2, late = 3:4)}.
#' @param new_labels Character vector to rename levels (same length as levels).
#' @param combine Character vector of column names to combine. Works inside
#'   \code{mutate()}. If \code{x} is provided, it is combined with the
#'   listed columns. If \code{x} is missing, all listed columns are combined.
#' @param sep Separator for combine. Default \code{" & "}.
#'
#' @return A factor.
#'
#' @examples
#' x <- factor(letters[1:6])
#'
#' # Recode (named ...)
#' fct_cat(x, AB = c("a","b"), CD = c("c","d"))
#' fct_cat(x, g1 = 1:3, g2 = 4:6)
#'
#' # Reorder (unnamed ...)
#' fct_cat(factor(letters[1:4]), "c", "b")
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
#' # Combine in mutate():
#' \dontrun{
#' df %>% mutate(grp = fct_cat(sex, combine = "age"))
#' df %>% mutate(grp = fct_cat(sex, combine = c("age", "race")))
#' df %>% mutate(grp = fct_cat(combine = c("sex", "age")))
#' }
#'
#' @export
#' @family factor tools
fct_cat <- function(x, ...,
                    reverse = FALSE,
                    binary_ref = NULL,
                    groups = NULL,
                    new_labels = NULL,
                    combine = NULL,
                    sep = " & ") {

  # --- Mutual exclusivity check ---
  n_modes <- sum(!is.null(binary_ref), !is.null(groups),
                 !is.null(new_labels), !is.null(combine), reverse)
  if (n_modes > 1) {
    cli::cli_abort("Only one mode at a time: {.arg binary_ref}, {.arg groups}, {.arg new_labels}, {.arg combine}, or {.arg reverse}.")
  }

  # 1. combine (x is optional)
  if (!is.null(combine)) {
    if (!is.character(combine)) {
      cli::cli_abort("{.arg combine} must be a character vector of column names.")
    }
    if (missing(x)) {
      return(.do_combine(x_vals = NULL, combine = combine, sep = sep))
    } else {
      return(.do_combine(x_vals = x, combine = combine, sep = sep))
    }
  }

  # All other modes require x
  x <- .as_factor(x)

  # 2. binary
  if (!is.null(binary_ref)) {
    .check_integer_index(binary_ref, "binary_ref")
    return(.do_binary(x, binary_ref))
  }

  # 3. groups
  if (!is.null(groups)) {
    if (!is.list(groups) || is.null(names(groups))) {
      cli::cli_abort("{.arg groups} must be a named list, e.g. {.code list(early = 1:2, late = 3:4)}.")
    }
    for (nm in names(groups)) {
      .check_integer_index(groups[[nm]], paste0("groups$", nm))
    }
    return(.recode_factor(x, groups))
  }

  # 4. new_labels
  if (!is.null(new_labels)) {
    n_lvl <- nlevels(x)
    if (length(new_labels) != n_lvl) {
      cli::cli_abort("{.arg new_labels} must have length {n_lvl} (same as number of levels), got {length(new_labels)}.")
    }
    levels(x) <- new_labels
    return(x)
  }

  # 5. reverse
  if (reverse) {
    return(factor(x, levels = rev(levels(x))))
  }

  # 6. ... — named = recode, unnamed = reorder
  dots <- list(...)
  if (length(dots) == 0) return(x)

  nms <- names(dots)
  has_names <- !is.null(nms) & nzchar(nms)
  if (any(has_names) && !all(has_names)) {
    cli::cli_abort("{.arg ...} must be ALL named (recode) or ALL unnamed (reorder). Mixed named/unnamed args are not allowed.")
  }

  if (all(has_names)) {
    return(.recode_factor(x, dots))
  } else {
    new_order <- c(...)
    cur <- levels(x)
    bad <- setdiff(new_order, cur)
    if (length(bad) > 0) {
      cli::cli_abort("Level{?s} not found: {.val {bad}}.")
    }
    return(factor(x, levels = c(new_order, setdiff(cur, new_order))))
  }
}


# ---- Internal: recode ----
.recode_factor <- function(x, newlevels) {
  if (length(newlevels) == 0) return(x)

  all_vals <- unlist(newlevels)
  if (anyDuplicated(all_vals)) {
    cli::cli_abort("New levels contain non-unique values: {.val {all_vals[duplicated(all_vals)]}}.")
  }

  lvls <- levels(x)
  if (all(vapply(newlevels, is.numeric, logical(1)))) {
    newlevels <- lapply(newlevels, function(i) {
      .check_integer_index(i, "recode index")
      if (any(i < 1 | i > length(lvls))) {
        cli::cli_abort("Indices must be between 1 and {length(lvls)}, got: {.val {i[i < 1 | i > length(lvls)]}}.")
      }
      lvls[i]
    })
  }

  # Keep unmatched levels as-is
  matched <- unlist(newlevels)
  for (u in setdiff(lvls, matched)) newlevels[[u]] <- u

  levels(x) <- newlevels
  factor(x)
}


# ---- Internal: binary ----
.do_binary <- function(x, binary_ref) {
  n_lvl <- nlevels(x)
  lvls <- levels(x)

  if (any(binary_ref < 1 | binary_ref > n_lvl)) {
    cli::cli_abort("{.arg binary_ref} must be between 1 and {n_lvl}.")
  }

  ref_name <- paste(lvls[binary_ref], collapse = "_")
  g <- stats::setNames(
    list(binary_ref, setdiff(seq_len(n_lvl), binary_ref)),
    c(ref_name, "Oth")
  )
  .recode_factor(x, g)
}


# ---- Internal: combine ----
.do_combine <- function(x_vals = NULL, combine, sep) {
  # Get data context — only works inside mutate()
  data <- tryCatch(
    dplyr::pick(dplyr::everything()),
    error = function(e) {
      cli::cli_abort("{.arg combine} only works inside {.fn dplyr::mutate}.")
    }
  )

  # Validate columns
  bad_cols <- setdiff(combine, names(data))
  if (length(bad_cols) > 0) {
    cli::cli_abort("Column{?s} not found: {.val {bad_cols}}.")
  }

  # Build list of value vectors to paste
  if (is.null(x_vals)) {
    col_names <- combine
    val_list <- lapply(combine, function(col) as.character(data[[col]]))
  } else {
    col_names <- c("x", combine)
    val_list <- c(
      list(as.character(x_vals)),
      lapply(combine, function(col) as.character(data[[col]]))
    )
  }

  # Paste
  all_vals <- do.call(paste, c(val_list, list(sep = sep)))

  # Build ordered levels from unique combos
  combo_df <- stats::setNames(
    as.data.frame(val_list, stringsAsFactors = FALSE),
    col_names
  )
  combos <- dplyr::distinct(combo_df)
  combos <- dplyr::arrange(combos, dplyr::across(dplyr::everything()))
  lvls <- apply(combos, 1, paste, collapse = sep)

  factor(all_vals, levels = lvls)
}


# ---- Shared helpers ----
.as_factor <- function(x) {
  if (is.factor(x)) x else factor(x)
}

.check_integer_index <- function(x, arg_name) {
  if (!is.numeric(x) || any(x != as.integer(x), na.rm = TRUE)) {
    cli::cli_abort("{.arg {arg_name}} must be integer values, got: {.val {x}}.")
  }
}
