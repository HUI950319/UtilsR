# ============================================================================
# fct_to_combine.R -- Combine multiple factor/character vectors into one factor
# ============================================================================

#' Combine Multiple Vectors / Columns into a Single Factor (generic)
#'
#' S3 generic that pastes several vectors cell-wise into one factor. Levels are
#' the unique combinations sorted by each input's factor-level order (preserving
#' meaningful orderings such as TNM stages or graded categories), not
#' alphabetic. Dispatches on the first argument:
#' \itemize{
#'   \item \strong{vectors} -- \code{fct_to_combine(v1, v2, ...)} returns the
#'     combined factor directly (also resolves a single character vector of
#'     column names inside a \pkg{dplyr} data mask).
#'   \item \strong{data.frame} -- \code{fct_to_combine(data, vars, var_name)}
#'     combines the named columns, appends the result as a new column, and
#'     returns the whole data frame (pipe-friendly).
#' }
#'
#' Conceptually similar to \code{forcats::fct_cross()} and
#' \code{base::interaction()}, but with a default separator (\code{" & "}) tuned
#' for clinical / epidemiological group labels. For regrouping levels of a
#' single factor (the dual operation), see [fct_to_group()].
#'
#' @param x First input. A factor / character / vector (vector method), OR a
#'   data.frame (data.frame method).
#' @param ... (vector method) Further vectors of equal length to combine. A
#'   single character vector of column names (length >= 2) is resolved through
#'   \code{dplyr::pick(all_of(.))} when called inside a data-masking verb,
#'   enabling \code{mutate(g = fct_to_combine(c("sex", "age")))}.
#' @param vars (data.frame method) Character vector of >= 2 column names to
#'   combine.
#' @param var_name (data.frame method) Name of the new column. Default
#'   \code{NULL} = \code{paste(vars, collapse = "_")}.
#' @param sep Separator between cell values. Default \code{" & "}.
#'
#' @return A factor (vector method) of length \code{length(..1)}; or the input
#'   data frame with the combined column appended (data.frame method).
#'
#' @examples
#' df <- data.frame(
#'   sex = factor(rep(c("F", "M"), each = 3)),
#'   age = factor(rep(c("young", "mid", "old"), 2),
#'                levels = c("young", "mid", "old"))
#' )
#'
#' # ---- vector method ----
#' fct_to_combine(df$sex, df$age)
#' fct_to_combine(df$sex, df$age, sep = "_")
#'
#' # ---- data.frame method (appends a column, pipe-friendly) ----
#' fct_to_combine(df, c("sex", "age"))                       # new col "sex_age"
#' fct_to_combine(df, c("sex", "age"), var_name = "group")   # new col "group"
#'
#' # Inside mutate (vector method, most natural usage)
#' \dontrun{
#' library(dplyr)
#' df %>% mutate(grp = fct_to_combine(sex, age))
#' df %>% mutate(grp = fct_to_combine(c("sex", "age")))
#' # pipe with the data.frame method
#' df |> fct_to_combine(c("sex", "age"), var_name = "group")
#' }
#'
#' @export
#' @family factor tools
#' @seealso [fct_to_group()], [fct_cat()], [fct_label()]
fct_to_combine <- function(...) {
  # Pure-`...` generic so that `do.call(fct_to_combine, df[vars])` and
  # `rlang::exec(fct_to_combine, !!!df[vars])` (which spread a *named* list of
  # column vectors) still work -- a named first formal `x` would be left
  # unbound by such calls. Dispatch explicitly on the first element's class.
  dots <- list(...)
  obj  <- if (length(dots) >= 1L) dots[[1L]] else NULL
  UseMethod("fct_to_combine", obj)
}

#' @rdname fct_to_combine
#' @export
fct_to_combine.data.frame <- function(x, vars, var_name = NULL, sep = " & ", ...) {
  if (missing(vars) || !is.character(vars) || length(vars) < 2L) {
    cli::cli_abort(c(
      "{.arg vars} must be a character vector of >= 2 column names.",
      "i" = "e.g. {.code fct_to_combine(df, c(\"sex\", \"age\"))}"
    ))
  }
  miss <- setdiff(vars, names(x))
  if (length(miss) > 0L) {
    cli::cli_abort("Column{?s} {.val {miss}} not found in the data frame.")
  }
  combined <- do.call(fct_to_combine.default,
                      c(unname(as.list(x[vars])), list(sep = sep)))
  new_var <- if (!is.null(var_name)) var_name else paste(vars, collapse = "_")
  x[[new_var]] <- combined
  x
}

#' @rdname fct_to_combine
#' @export
fct_to_combine.default <- function(..., sep = " & ") {

  args <- list(...)
  if (length(args) < 1L) {
    cli::cli_abort("Must supply at least one vector in {.arg ...}.")
  }

  # Single character vector of length >= 2 -> treat as column names and
  # resolve through dplyr::pick(all_of(.)) from the enclosing data mask
  # (mutate / summarise / filter). This enables:
  #   mutate(g = fct_to_combine(c("sex", "age")))
  #   exposure_names <- c("sex","age"); mutate(g = fct_to_combine(exposure_names))
  if (length(args) == 1L && is.character(args[[1L]]) &&
      length(args[[1L]]) >= 2L) {
    cols <- args[[1L]]
    args <- tryCatch(
      as.list(dplyr::pick(dplyr::all_of(cols))),
      error = function(e) {
        cli::cli_abort(c(
          "Cannot resolve column names {.val {cols}}.",
          "i" = "Call inside {.fn dplyr::mutate} / {.fn dplyr::summarise}, pass column vectors directly via {.code !!!df[cols]}, or use the data.frame method {.code fct_to_combine(df, cols)}.",
          "x" = conditionMessage(e)
        ), call = NULL)
      }
    )
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
