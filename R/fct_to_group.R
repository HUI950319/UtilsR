# =============================================================================
# fct_to_group.R -- Group factor levels by integer indices with auto-naming
# =============================================================================

#' Group Factor Levels by Integer Indices
#'
#' Collapses factor levels into new groups specified by integer indices.
#' Companion to [fct_to_combine()]: where `fct_to_combine()` merges multiple
#' columns row-wise, `fct_to_group()` regroups levels of a single factor.
#'
#' Auto-names unnamed groups as `paste0(name_prefix, paste(idx, collapse = name_sep))`,
#' e.g. `g1/3`, `g2/4`, `g5`. User-supplied list names take precedence.
#'
#' @param x A factor or character vector. Character is auto-coerced via
#'   `factor(x)`.
#' @param g_lis A list of integer index vectors. Each element specifies the
#'   level positions to merge into one new group. Either fully named (user
#'   names used as new level names) or unnamed (auto-named via
#'   `name_prefix` + `name_sep`). Indices must be between 1 and `nlevels(x)`.
#'   Values must be finite and non-missing. Empty groups add no levels.
#'   Integer64 indices require \pkg{bit64}, which is loaded when needed.
#' @param name_prefix Prefix for auto-generated group names. Default `"g"`.
#' @param name_sep Separator for auto-generated group names. Default `"/"`.
#'
#' @return A factor with regrouped levels. Levels not covered by any group
#'   in `g_lis` are kept as-is (matching [fct_cat()]'s behavior).
#'
#' @examples
#' x <- factor(c("I","II","III","IV","V"))
#'
#' # Auto-named groups
#' fct_to_group(x, list(c(1,3), c(2,4), 5))
#' # -> levels: g1/3, g2/4, g5
#'
#' # User-named groups (names take precedence)
#' fct_to_group(x, list(early = 1:2, late = 3:5))
#' # -> levels: early, late
#'
#' # Custom prefix / separator
#' fct_to_group(x, list(c(1,3), c(2,4), 5),
#'              name_prefix = "G", name_sep = "+")
#' # -> levels: G1+3, G2+4, G5
#'
#' # In dplyr::mutate
#' \dontrun{
#' library(dplyr)
#' df %>% mutate(group1 = fct_to_group(group, list(c(1,3), c(2,4), 5)))
#' }
#'
#' @export
#' @family factor tools
fct_to_group <- function(x, g_lis,
                         name_prefix = "g",
                         name_sep    = "/") {

  if (!is.list(g_lis) || !is.null(dim(g_lis)) || length(g_lis) == 0L) {
    cli::cli_abort("{.arg g_lis} must be a non-empty list of integer index vectors.")
  }

  cur_names <- names(g_lis)
  unnamed <- if (is.null(cur_names)) seq_along(g_lis) else if (anyNA(cur_names) || "" %in% cur_names)
    which(cur_names %in% c("", NA_character_))
  if (length(unnamed)) {
    for (arg in c("name_prefix", "name_sep")) {
      value <- get(arg)
      if (!is.character(value) || !is.null(dim(value)) || length(value) != 1L || is.na(value))
        cli::cli_abort("{.arg {arg}} must be a single non-missing string.")
    }
  }
  x <- .as_factor(x)
  plain_singleton <- function(idx) is.integer(idx) && length(idx) == 1L && is.null(attributes(idx))
  singleton_indices <- NULL
  if (length(g_lis) >= 1024L && all(vapply(g_lis, plain_singleton, logical(1L)))) {
    # Integer scalars need no per-group coercion. Check their bounds together.
    singleton_indices <- .check_integer_index(unlist(g_lis, use.names = FALSE), "g_lis", nlevels(x))
  } else {
    g_lis <- lapply(g_lis, .check_integer_index, arg_name = "g_lis", n_levels = nlevels(x))
  }

  # Auto-name unnamed elements; user names take precedence
  if (length(unnamed) && !is.null(singleton_indices)) {
    cur_names[unnamed] <- paste0(name_prefix, singleton_indices[unnamed])
  } else if (length(unnamed)) {
    selected <- g_lis[unnamed]
    if (all(lengths(selected) == 1L)) {
      cur_names[unnamed] <- paste0(name_prefix, unlist(selected, use.names = FALSE))
    } else {
      cur_names[unnamed] <- vapply(selected, function(idx)
        paste0(name_prefix, paste(idx, collapse = name_sep)), character(1L))
    }
  }
  names(g_lis) <- cur_names

  .recode_factor(x, g_lis, checked_indices = TRUE)
}
