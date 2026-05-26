# ============================================================================
# fct_label.R -- Pipe-friendly factor relabelling generic: fct_label()
# ============================================================================

#' Relabel factor levels (generic: vector or data-frame column)
#'
#' S3 generic that renames the levels of a factor. Dispatches on the first
#' argument:
#' \itemize{
#'   \item \strong{vector / factor} -- \code{fct_label(x, labels)} relabels the
#'     vector directly (thin wrapper around [fct_cat()] with \code{new_labels}).
#'   \item \strong{data.frame} -- \code{fct_label(data, var, labels)} relabels a
#'     single column \strong{in place} and returns the whole data frame, so it
#'     chains in a \code{\%>\%} / \code{|>} pipeline. The column may be a bare
#'     name (NSE) or a character string.
#' }
#'
#' This is the packaged form of the legacy FeatureAnalysis helper
#' \code{.fct_label()}. For other single-vector factor operations (reorder,
#' binary, group), see [fct_cat()]; for numeric binning see [fct_num()].
#'
#' @param x A factor / character vector, or a data.frame.
#' @param var (data.frame method only) Column to relabel. Bare column name
#'   (NSE, e.g. \code{Sex}) or character string (e.g. \code{"Sex"}).
#' @param labels Character vector of new level labels, in current level order
#'   and the same length as the existing levels.
#' @param ... Passed to methods (currently unused).
#'
#' @return Same type as \code{x}: a factor for the vector method, or the input
#'   data frame (with \code{var} relabelled) for the data.frame method.
#'
#' @examples
#' # ---- vector method ----
#' g <- factor(c("I", "II", "III", "II", "I"))
#' fct_label(g, c("Low", "Mid", "High"))
#'
#' # ---- data.frame method ----
#' df <- data.frame(
#'   grade = factor(c("I", "II", "III", "II", "I")),
#'   sex   = factor(c("m", "f", "f", "m", "f"))
#' )
#' fct_label(df, grade, labels = c("Low", "Mid", "High"))   # bare name (NSE)
#' fct_label(df, "sex", labels = c("Female", "Male"))       # string
#'
#' # chains in a pipeline
#' \dontrun{
#' df |>
#'   fct_label(grade, c("Low", "Mid", "High")) |>
#'   fct_label(sex,   c("Female", "Male"))
#' }
#'
#' @export
#' @family factor tools
#' @seealso [fct_cat()], [fct_num()], [fct_to_combine()]
fct_label <- function(x, ...) {
  UseMethod("fct_label")
}

#' @rdname fct_label
#' @export
fct_label.data.frame <- function(x, var, labels, ...) {
  q <- rlang::enquo(var)
  v <- if (rlang::quo_is_symbol(q)) {
    rlang::as_name(rlang::quo_get_expr(q))
  } else {
    rlang::eval_tidy(q)
  }
  if (!v %in% names(x)) {
    cli::cli_abort("Column {.val {v}} not found in the data frame.")
  }
  x[[v]] <- fct_cat(x[[v]], new_labels = labels)
  x
}

#' @rdname fct_label
#' @export
fct_label.default <- function(x, labels, ...) {
  fct_cat(x, new_labels = labels)
}
