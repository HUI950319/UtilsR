# =============================================================================
# fct_to_combine.R -- Combine several vectors / columns into one factor
# =============================================================================
#
# Architecture (S3 generic, 2 layers):
#
#   L1  fct_to_combine(...)                         -- public generic
#         |   pure-dots generic dispatching on named data.frame x or first input,
#         |   so do.call() / rlang::exec() over a named list still works
#         +-- L2  fct_to_combine.data.frame()   combine selected columns
#         +-- L2  fct_to_combine.default()      combine bare vectors
# =============================================================================

#' Combine Multiple Vectors / Columns into a Single Factor (generic)
#'
#' S3 generic that pastes several vectors cell-wise into one factor. Levels are
#' the unique combinations sorted by each input's factor-level order (preserving
#' meaningful orderings such as TNM stages or graded categories), not
#' alphabetic. Dispatches on an explicitly named data.frame \code{x}, or
#' otherwise on the first argument:
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
#' single factor (the dual operation), see \code{\link{fct_to_group}()}.
#'
#' A row is missing if any input is missing according to its \code{is.na()}
#' method, including \code{NaN} and SPSS user-missing values and ranges.
#' The literal string \code{"NA"} remains an ordinary category.
#' If distinct combinations produce the same label, the function errors;
#' choose a different \code{sep} or relabel the inputs to disambiguate them.
#'
#' Inside grouped or rowwise \code{dplyr::mutate()}, combinations are computed
#' separately for each group. When dplyr combines the results, their level
#' order may differ from whole-data ordering and change the first level used
#' as a model reference. To use one level order across the data, use the
#' data.frame method on the whole data frame; its grouping is retained.
#'
#' @param x First input. A factor / character / vector (vector method), OR a
#'   data.frame (data.frame method). A \pkg{data.table} input is copied before
#'   writing the result; keys and indices affected by replacement are cleared.
#' @param ... (vector method) One-dimensional atomic vectors of equal length
#'   to combine. Raw vectors must be converted explicitly before use.
#'   Must be empty for the data.frame method. A
#'   single character vector of column names (length >= 2) is resolved through
#'   \code{dplyr::pick(all_of(.))} when called inside a data-masking verb,
#'   enabling \code{mutate(g = fct_to_combine(c("sex", "age")))}.
#'   This shortcut always interprets a character vector of length >= 2 as
#'   column names; use \code{factor(x)} to combine a single character vector
#'   of values. Grouping columns are unavailable to \code{pick()}; pass such
#'   columns directly as vectors or use the data.frame method.
#'   Repeated, missing and empty column names are rejected. Names attached to
#'   a column-name vector are ignored.
#'   Vector names do not affect combinations. The name \code{sep} is reserved
#'   for the separator; combine a column named \code{sep} with the data.frame
#'   method, or remove column-list names before \code{do.call()}.
#' @param vars (data.frame method) One-dimensional character vector of >= 2
#'   column names to combine. Names must be unique, non-missing and non-empty, and identify
#'   unambiguous columns in the data frame.
#' @param var_name (data.frame method) Name of the new column. Default
#'   \code{NULL} = \code{paste(vars, collapse = "_")}. Otherwise a single
#'   non-missing, non-empty string. An existing column of this name is replaced.
#'   A name matching multiple existing columns is rejected.
#' @param sep A single non-missing string separating cell values. Default
#'   \code{" & "}; an empty string is allowed.
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
#' \donttest{
#' library(dplyr)
#' df %>% mutate(grp = fct_to_combine(sex, age))
#' df %>% mutate(grp = fct_to_combine(c("sex", "age")))
#' # pipe with the data.frame method
#' df |> fct_to_combine(c("sex", "age"), var_name = "group")
#' # One level order across the whole data, while retaining dplyr groups
#' df %>% group_by(age) %>%
#'   fct_to_combine(c("sex", "age"), var_name = "group")
#' }
#'
#' @export
#' @family factor tools
#' @seealso \code{\link{fct_to_group}()}, \code{\link{fct_cat}()},
#'   \code{\link{fct_label}()}
fct_to_combine <- function(...) {
  # Pure-`...` generic so that `do.call(fct_to_combine, df[vars])` and
  # `rlang::exec(fct_to_combine, !!!df[vars])` (which spread a *named* list of
  # column vectors) still work -- a named first formal `x` would be left
  # unbound by such calls. Named data-frame x may follow the method controls.
  dots <- list(...)
  obj  <- if (length(dots) >= 1L) dots[[1L]] else NULL
  if (is.data.frame(dots[["x"]])) obj <- dots[["x"]]
  UseMethod("fct_to_combine", obj)
}

#' @rdname fct_to_combine
#' @export
fct_to_combine.data.frame <- function(x, vars, var_name = NULL, sep = " & ", ...) {
  rlang::check_dots_empty()
  if (missing(vars) || !is.character(vars) || !is.null(dim(vars)) ||
      length(vars) < 2L) {
    cli::cli_abort(c(
      "{.arg vars} must be a one-dimensional character vector of >= 2 column names.",
      "i" = "e.g. {.code fct_to_combine(df, c(\"sex\", \"age\"))}"
    ))
  }
  if (anyNA(vars) || any(!nzchar(vars)) || anyDuplicated(vars)) {
    cli::cli_abort("{.arg vars} must contain unique, non-missing, non-empty column names.")
  }
  vars <- unname(vars)
  if (!is.null(var_name) &&
      (!is.character(var_name) || length(var_name) != 1L ||
       is.na(var_name) || !nzchar(var_name))) {
    cli::cli_abort("{.arg var_name} must be NULL or a single non-missing, non-empty string.")
  }
  miss <- setdiff(vars, names(x))
  if (length(miss) > 0L) {
    cli::cli_abort("Column{?s} {.val {miss}} not found in the data frame.")
  }
  if (anyDuplicated(names(x)[names(x) %in% vars])) {
    cli::cli_abort("Selected column names must be unique in the data frame.")
  }
  new_var <- if (!is.null(var_name)) var_name else paste(vars, collapse = "_")
  if (sum(names(x) == new_var, na.rm = TRUE) > 1L) {
    cli::cli_abort("Output column name {.val {new_var}} is ambiguous in the data frame.")
  }
  combined <- do.call(fct_to_combine.default,
                      c(lapply(vars, function(nm) x[[nm]]), list(sep = sep)))
  if (inherits(x, "data.table")) {
    if (!requireNamespace("data.table", quietly = TRUE)) {
      cli::cli_abort("Combining data.table columns requires the {.pkg data.table} package.")
    }
    x <- data.table::copy(x)
    data.table::set(x, j = new_var, value = combined)
  } else {
    x[[new_var]] <- combined
  }
  x
}

#' @rdname fct_to_combine
#' @export
fct_to_combine.default <- function(..., sep = " & ") {
  if (!is.character(sep) || length(sep) != 1L || is.na(sep)) {
    cli::cli_abort("{.arg sep} must be a single non-missing string.")
  }
  args <- list(...)
  if (length(args) < 1L) {
    cli::cli_abort("Must supply at least one vector in {.arg ...}.")
  }

  # Single character vector of length >= 2 -> treat as column names and
  # resolve through dplyr::pick(all_of(.)) from the enclosing data mask
  # (mutate / summarise / filter). This enables:
  #   mutate(g = fct_to_combine(c("sex", "age")))
  #   exposure_names <- c("sex","age"); mutate(g = fct_to_combine(exposure_names))
  if (length(args) == 1L && is.character(args[[1L]]) && is.null(dim(args[[1L]])) &&
      length(args[[1L]]) >= 2L) {
    cols <- unname(args[[1L]])
    if (anyNA(cols) || any(!nzchar(cols)) || anyDuplicated(cols)) {
      cli::cli_abort("Column names must be unique, non-missing and non-empty.")
    }
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

  if (!all(vapply(args, function(v) is.atomic(v) && is.null(dim(v)), logical(1L)))) {
    cli::cli_abort("All inputs must be one-dimensional atomic vectors.")
  }
  if (any(vapply(args, is.raw, logical(1L)))) {
    cli::cli_abort("Raw vectors are not supported; convert them explicitly before combining.")
  }
  lens <- vapply(args, length, integer(1L))
  if (length(unique(lens)) != 1L) {
    cli::cli_abort(c(
      "All inputs must have the same length.",
      "i" = "Got lengths: {paste(lens, collapse = ', ')}."
    ))
  }

  ensure_factor <- function(v) {
    # Register class methods even when inputs were restored from an RDS file.
    if (inherits(v, "haven_labelled")) loadNamespace("labelled")
    if (inherits(v, "integer64") && !requireNamespace("bit64", quietly = TRUE)) {
      cli::cli_abort("Combining integer64 vectors requires the {.pkg bit64} package.")
    }
    if (is.factor(v)) v else factor(v)
  }
  fct_list <- unname(lapply(args, ensure_factor))
  missing_rows <- Reduce(`|`, lapply(args, is.na))

  complete_rows <- NULL
  n <- lens[[1L]]
  if (any(missing_rows)) {
    complete_rows <- which(!missing_rows)
    if (!length(complete_rows)) {
      return(structure(rep.int(NA_integer_, n), levels = character(), class = "factor"))
    }
  }

  # Group integer codes before building labels; repeated rows need no strings.
  codes <- lapply(fct_list, as.integer)
  if (!is.null(complete_rows)) {
    codes <- lapply(codes, function(v) v[complete_rows])
  }
  names(codes) <- paste0("v", seq_along(codes))
  group_n <- if (is.null(complete_rows)) n else length(complete_rows)
  ids <- vctrs::vec_group_id(vctrs::new_data_frame(codes, n = group_n))
  first <- match(seq_len(attr(ids, "n")), ids)
  ord <- do.call(order, unname(lapply(codes, function(v) v[first])))
  first <- first[ord]
  label_rows <- if (is.null(complete_rows)) first else complete_rows[first]
  lvls <- do.call(paste, c(lapply(fct_list, function(f) as.character(f[label_rows])),
                           list(sep = sep)))
  if (anyDuplicated(lvls)) {
    cli::cli_abort(c(
      "Distinct combinations produce the same label.",
      "i" = "Choose a different {.arg sep} or relabel the inputs."
    ))
  }

  if (!is.null(complete_rows)) {
    result <- rep.int(NA_integer_, n)
    result[complete_rows] <- match(ids, ids[first])
    return(structure(result, levels = lvls, class = "factor"))
  }
  structure(match(ids, ids[first]), levels = lvls, class = "factor")
}
