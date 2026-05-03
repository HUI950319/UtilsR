# ============================================================================
# fct_to_group.R -- Group factor levels by integer indices with auto-naming
# ============================================================================

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

  if (!is.list(g_lis) || length(g_lis) == 0L) {
    cli::cli_abort("{.arg g_lis} must be a non-empty list of integer index vectors.")
  }

  if (!is.factor(x)) x <- factor(x)

  max_idx <- max(unlist(g_lis))
  if (max_idx > nlevels(x)) {
    cli::cli_abort(c(
      "Index out of range.",
      "i" = "Got max index {.val {max_idx}} but {.code nlevels(x)} = {.val {nlevels(x)}}."
    ))
  }

  # Auto-name unnamed elements; user names take precedence
  cur_names <- names(g_lis)
  if (is.null(cur_names)) cur_names <- rep("", length(g_lis))
  auto <- vapply(g_lis, function(idx)
    paste0(name_prefix, paste(idx, collapse = name_sep)),
    character(1L))
  final_names <- ifelse(is.na(cur_names) | cur_names == "", auto, cur_names)
  names(g_lis) <- final_names

  fct_cat(x, groups = g_lis)
}
