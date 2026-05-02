# ============================================================================
# fct_to_combine.R -- Combine multiple factor/character columns into one factor
# ============================================================================

#' Combine Multiple Columns into a Single Factor
#'
#' Pastes the columns named in \code{...} cell-wise into a single factor.
#' Levels are taken from unique combinations sorted by each input column's
#' factor level order (preserving meaningful orderings such as TNM stages
#' or graded categories), not alphabetic. This is a drop-in replacement
#' for the legacy \code{.com_factor()} pattern (FeatureAnalysis).
#'
#' @param data A data.frame (required).
#' @param ... Columns to combine. Accepts unquoted bare names, character
#'   vectors, or multiple character args -- e.g. all of these are
#'   equivalent: \code{fct_to_combine(d, Sex, Race)},
#'   \code{fct_to_combine(d, "Sex", "Race")},
#'   \code{fct_to_combine(d, c("Sex", "Race"))}.
#' @param sep Separator between cell values. Default \code{" & "}.
#'
#' @return A factor of length \code{nrow(data)} with levels equal to the
#'   sorted unique combinations.
#'
#' @examples
#' df <- data.frame(
#'   sex = factor(rep(c("F", "M"), each = 3)),
#'   age = factor(rep(c("young", "mid", "old"), 2),
#'                levels = c("young", "mid", "old"))
#' )
#'
#' # Bare names
#' fct_to_combine(df, sex, age)
#'
#' # Character args
#' fct_to_combine(df, "sex", "age")
#'
#' # Single character vector (typical for programmatic callers)
#' fct_to_combine(df, c("sex", "age"))
#'
#' # Custom separator
#' fct_to_combine(df, sex, age, sep = "_")
#'
#' @export
#' @family factor tools
fct_to_combine <- function(data, ..., sep = " & ") {

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data.frame.")
  }

  # Collect column names from ... (accepts bare names + character).
  # Resolution rule per arg:
  #   1. Literal character expression -> use directly
  #   2. Bare symbol matching a column in data -> use as column name
  #   3. Otherwise try eval_tidy in caller env -> must yield character vec
  dots <- rlang::enquos(...)
  if (length(dots) == 0L) {
    cli::cli_abort("Must supply at least one column name in {.arg ...}.")
  }
  vars <- unlist(lapply(dots, function(q) {
    expr <- rlang::quo_get_expr(q)
    if (is.character(expr)) return(expr)
    if (is.symbol(expr)) {
      nm <- rlang::as_name(q)
      if (nm %in% names(data)) return(nm)
    }
    val <- tryCatch(rlang::eval_tidy(q), error = function(e) NULL)
    if (is.character(val)) return(val)
    cli::cli_abort(c(
      "x" = "Cannot resolve {.code {rlang::expr_text(expr)}} as a column name or character vector."
    ))
  }), use.names = FALSE)

  if (!is.character(vars)) {
    cli::cli_abort("Column names must be character.")
  }
  bad <- setdiff(vars, names(data))
  if (length(bad) > 0L) {
    cli::cli_abort("Column{?s} not found: {.val {bad}}.")
  }

  # Coerce to factor (preserve existing level order; alphabetic for new)
  ensure_factor <- function(v) if (is.factor(v)) v else factor(v)
  fct_list <- lapply(vars, function(col) ensure_factor(data[[col]]))

  # Cell-wise paste
  val_list <- lapply(fct_list, as.character)
  all_vals <- do.call(paste, c(val_list, list(sep = sep)))

  # Build ordered levels: arrange on FACTOR columns preserves level order
  combo_df <- stats::setNames(
    as.data.frame(fct_list, stringsAsFactors = FALSE),
    vars
  )
  combos <- dplyr::distinct(combo_df)
  combos <- dplyr::arrange(combos, dplyr::across(dplyr::everything()))
  lvls <- vapply(seq_len(nrow(combos)),
                 function(i) paste(vapply(combos[i, ], as.character, character(1)),
                                   collapse = sep),
                 character(1))

  factor(all_vals, levels = lvls)
}
