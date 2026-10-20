# =============================================================================
# fct_num.R -- Numeric to factor conversion: fct_num()
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  fct_num(x, breaks, labels, nbins, type)     -- public API
#         +-- L2  .make_break_labels()        labels from explicit breaks
#         +-- L2  .make_default_bin_labels()  labels for quantile/equal bins
# =============================================================================

#' Convert Numeric to Factor
#'
#' Cut a numeric vector into factor groups. Works on vectors (usable in
#' \code{mutate()}). Supports fixed cut points or automatic binning.
#'
#' @param x A numeric vector. Vectors with \code{integer64} storage are not supported.
#' @param breaks Numeric vector of finite, distinct cut points. E.g. \code{50} for binary,
#'   \code{c(20, 50)} for 3 groups. Mutually exclusive with \code{nbins}.
#'   Vectors with \code{integer64} storage are not supported.
#' @param labels Character vector of group labels. If \code{NULL}, labels
#'   are auto-generated (e.g. \code{"below_50"}, \code{"50-80"}, \code{"above_80"}).
#'   Additional digits distinguish cut points whose usual text representations coincide.
#' @param nbins Single finite integer number of bins, at least 2 and less than
#'   \code{.Machine$integer.max}. Mutually exclusive with \code{breaks}.
#' @param type Binning method when using \code{nbins}: \code{"quantile"}
#'   (default) or \code{"equal"} width.
#'
#' @return A factor.
#'
#' @examples
#' x <- c(10, 25, 40, 55, 70, 85, 100)
#'
#' # Fixed cut points
#' fct_num(x, breaks = 50)
#' fct_num(x, breaks = c(30, 70))
#' fct_num(x, breaks = c(30, 70), labels = c("Low", "Mid", "High"))
#'
#' # Automatic binning
#' fct_num(x, nbins = 3)
#' fct_num(x, nbins = 2, labels = c("Low", "High"))
#' fct_num(x, nbins = 4, type = "equal")
#'
#' # In mutate():
#' \dontrun{
#' df %>% mutate(age_grp = fct_num(age, breaks = c(40, 60)))
#' df %>% mutate(age_q4 = fct_num(age, nbins = 4))
#' }
#'
#' @export
#' @family factor tools
fct_num <- function(x, breaks = NULL, labels = NULL,
                    nbins = NULL, type = c("quantile", "equal")) {

  if (!is.numeric(x)) {
    cli::cli_abort("{.arg x} must be numeric, got {.cls {class(x)}}.")
  }
  if (inherits(x, "integer64")) {
    cli::cli_abort("{.arg x} with {.cls integer64} storage is not supported.")
  }
  if (all(is.na(x))) {
    cli::cli_abort("{.arg x} is all NA.")
  }

  if (!is.null(breaks) && !is.null(nbins)) {
    cli::cli_abort("Use {.arg breaks} or {.arg nbins}, not both.")
  }
  if (is.null(breaks) && is.null(nbins)) {
    cli::cli_abort("Provide {.arg breaks} (cut points) or {.arg nbins} (number of bins).")
  }

  type <- match.arg(type)

  # --- Mode 1: fixed cut points ---
  if (!is.null(breaks)) {
    if (inherits(breaks, "integer64")) {
      cli::cli_abort("{.arg breaks} with {.cls integer64} storage is not supported.")
    }
    if (length(breaks) == 0) {
      cli::cli_abort("{.arg breaks} must have at least one value.")
    }
    if (!is.numeric(breaks) || is.complex(breaks) || !is.null(dim(breaks))) {
      cli::cli_abort("{.arg breaks} must be a numeric vector of cut points.")
    }
    if (anyNA(breaks) || any(!is.finite(breaks))) {
      cli::cli_abort("{.arg breaks} must contain only finite, non-missing values.")
    }
    if (anyDuplicated(breaks)) {
      cli::cli_abort("{.arg breaks} must contain distinct values.")
    }
    breaks <- sort(breaks)
    full_breaks <- c(-Inf, breaks, Inf)

    if (is.null(labels)) {
      labels <- .make_break_labels(breaks)
    }

    if (length(labels) != length(full_breaks) - 1) {
      cli::cli_abort("{.arg labels} must have length {length(full_breaks) - 1} (number of groups), got {length(labels)}.")
    }

    return(cut(x, breaks = full_breaks, labels = labels, include.lowest = TRUE))
  }

  # --- Mode 2: automatic binning ---
  if (!is.numeric(nbins) || is.complex(nbins) || length(nbins) != 1L ||
      !is.null(dim(nbins)) || is.na(nbins) || !is.finite(nbins) ||
      nbins < 2 || nbins >= .Machine$integer.max || nbins != floor(nbins)) {
    cli::cli_abort("{.arg nbins} must be a single finite integer >= 2 and < {(.Machine$integer.max)}.")
  }
  nbins <- as.integer(nbins)

  if (type == "quantile") {
    probs <- seq(0, 1, length.out = nbins + 1L)
    bin_breaks <- stats::quantile(x, probs = probs, na.rm = TRUE)
    # Deduplicate (ties in quantiles)
    bin_breaks <- unique(bin_breaks)
    n_groups <- length(bin_breaks) - 1L
    if (n_groups < nbins) {
      cli::cli_warn("Ties in quantiles reduced {nbins} bins to {n_groups}.")
    }
  } else {
    rng <- range(x, na.rm = TRUE)
    bin_breaks <- seq(rng[1], rng[2], length.out = nbins + 1L)
    n_groups <- nbins
  }

  if (is.null(labels)) {
    labels <- .make_default_bin_labels(n_groups)
  }

  if (length(labels) != n_groups) {
    cli::cli_abort("{.arg labels} must have length {n_groups}, got {length(labels)}.")
  }

  cut(x, breaks = bin_breaks, labels = labels, include.lowest = TRUE)
}


# ---- Internal: auto-generate labels for fixed breaks ----
.make_break_labels <- function(breaks) {
  n <- length(breaks)
  break_text <- as.character(breaks)
  if (anyDuplicated(break_text)) {
    break_text <- sprintf("%.17g", breaks)
  }
  labs <- character(n + 1L)
  labs[1] <- paste0("below_", break_text[1])
  if (n >= 2) {
    for (i in seq_len(n - 1)) {
      labs[i + 1] <- paste0(break_text[i], "-", break_text[i + 1])
    }
  }
  labs[n + 1] <- paste0("above_", break_text[n])
  labs
}

# ---- Internal: auto-generate labels for nbins ----
.make_default_bin_labels <- function(n) {
  switch(as.character(n),
    "2" = c("low", "high"),
    "3" = c("low", "middle", "high"),
    "4" = c("low", "medium", "high", "very_high"),
    paste0("g", seq_len(n))
  )
}
