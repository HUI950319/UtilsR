# ============================================================================
# fct_to_combine.R -- Combine multiple factor/character vectors into one factor
# ============================================================================

#' Combine Multiple Vectors into a Single Factor
#'
#' Pastes the vectors in \code{...} cell-wise into a single factor.
#' Levels are taken from unique combinations sorted by each input vector's
#' factor level order (preserving meaningful orderings such as TNM stages
#' or graded categories), not alphabetic.
#'
#' Conceptually similar to \code{forcats::fct_cross()} and
#' \code{base::interaction()}, but with a default separator (\code{" & "})
#' tuned for clinical / epidemiological group labels. For regrouping levels
#' of a single factor (the dual operation), see [fct_to_group()].
#'
#' @param ... Two or more factor / character / vector inputs of equal length.
#'   Inside \code{dplyr::mutate()} pass bare column names (e.g.
#'   \code{mutate(g = fct_to_combine(sex, age))}). For programmatic use,
#'   splice a data subset with \code{!!!} or \code{do.call()}.
#' @param sep Separator between cell values. Default \code{" & "}.
#'
#' @return A factor of length \code{length(..1)} with levels equal to the
#'   sorted unique combinations.
#'
#' @examples
#' df <- data.frame(
#'   sex = factor(rep(c("F", "M"), each = 3)),
#'   age = factor(rep(c("young", "mid", "old"), 2),
#'                levels = c("young", "mid", "old"))
#' )
#'
#' # Direct vectors
#' fct_to_combine(df$sex, df$age)
#'
#' # Inside mutate (most natural usage)
#' \dontrun{
#' library(dplyr)
#' df %>% mutate(grp = fct_to_combine(sex, age))
#' }
#'
#' # Programmatic (character vector of column names)
#' vars <- c("sex", "age")
#' do.call(fct_to_combine, df[vars])
#' rlang::exec(fct_to_combine, !!!df[vars])
#'
#' # Custom separator
#' fct_to_combine(df$sex, df$age, sep = "_")
#'
#' @export
#' @family factor tools
fct_to_combine <- function(..., sep = " & ") {

  args <- list(...)
  if (length(args) < 1L) {
    cli::cli_abort("Must supply at least one vector in {.arg ...}.")
  }

  lens <- vapply(args, length, integer(1L))
  if (length(unique(lens)) != 1L) {
    cli::cli_abort(c(
      "All inputs must have the same length.",
      "i" = "Got lengths: {paste(lens, collapse = ', ')}."
    ))
  }

  ensure_factor <- function(v) if (is.factor(v)) v else factor(v)
  fct_list <- lapply(args, ensure_factor)

  val_list <- lapply(fct_list, as.character)
  all_vals <- do.call(paste, c(val_list, list(sep = sep)))

  # Build ordered levels: do.call(order, fct_list) sorts rows by each
  # factor's internal level order (stable, no alphabetic coercion).
  ord <- do.call(order, fct_list)
  ordered_keys <- all_vals[ord]
  lvls <- ordered_keys[!duplicated(ordered_keys)]

  factor(all_vals, levels = lvls)
}
