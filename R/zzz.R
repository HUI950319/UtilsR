# ============================================================================
# zzz.R -- Package initialization & re-exported operators
# ============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
#'
#' @importFrom dplyr %>%
#' @export
#' @name %>%
#' @rdname operators
NULL

#' Compound assignment pipe operator
#'
#' Pipes \code{lhs} into \code{rhs}, then assigns the result back to
#' \code{lhs}. Equivalent to \code{lhs <- lhs \%>\% rhs}.
#'
#' @param lhs A variable name (will be updated in the calling environment).
#' @param rhs A function or expression to pipe into.
#' @return Invisibly returns the new value of \code{lhs}.
#'
#' @examples
#' x <- c(1, 2, 3)
#' x %<>% sum()
#' x
#' # [1] 6
#'
#' @export
`%<>%` <- function(lhs, rhs) {
  lhs_name <- deparse(substitute(lhs))
  env <- parent.frame()
  result <- eval(substitute(lhs %>% rhs), envir = env)
  assign(lhs_name, result, envir = env)
  invisible(result)
}

#' Default value operator
#'
#' Return \code{lhs} if not \code{NULL}, otherwise \code{rhs}.
#'
#' @importFrom rlang %||%
#' @export
#' @name %||%
#' @rdname operators
NULL

#' Not-in operator
#'
#' Negation of \code{\%in\%}. Returns \code{TRUE} for elements of \code{x}
#' that are \emph{not} in \code{table}.
#'
#' @param x Vector of values to check.
#' @param table Vector of values to match against.
#' @return Logical vector.
#'
#' @examples
#' c(1, 2, 3) %ni% c(2, 4)
#' # [1]  TRUE FALSE  TRUE
#'
#' @export
`%ni%` <- function(x, table) !x %in% table

#' @importFrom rlang .data
#' @keywords internal
NULL

.onLoad <- function(libname, pkgname) {
  # Initialize preset theme objects (km_theme, rcs_theme)
  if (requireNamespace("ggprism", quietly = TRUE)) {
    tryCatch(.onLoad_theme(), error = function(e) NULL)
  }
  invisible()
}
