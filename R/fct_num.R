# ============================================================================
# fct_num.R -- Numeric to factor conversion: fct_num()
# ============================================================================

#' Convert Numeric to Factor
#'
#' Cut a numeric vector into factor groups. Works on vectors (usable in
#' \code{mutate()}). Supports fixed cut points or automatic binning.
#'
#' @param x A numeric vector.
#' @param breaks Numeric vector of cut points. E.g. \code{50} for binary,
#'   \code{c(20, 50)} for 3 groups. Mutually exclusive with \code{nbins}.
#' @param labels Character vector of group labels. If \code{NULL}, labels
#'   are auto-generated (e.g. \code{"below_50"}, \code{"50-80"}, \code{"above_80"}).
#' @param nbins Integer number of bins for automatic binning. Mutually
#'   exclusive with \code{breaks}.
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
    if (length(breaks) == 0) {
      cli::cli_abort("{.arg breaks} must have at least one value.")
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
  if (!is.integer(nbins)) nbins <- as.integer(nbins)
  if (nbins < 2L) {
    cli::cli_abort("{.arg nbins} must be >= 2, got {nbins}.")
  }

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
  labs <- character(n + 1L)
  labs[1] <- paste0("below_", breaks[1])
  if (n >= 2) {
    for (i in seq_len(n - 1)) {
      labs[i + 1] <- paste0(breaks[i], "-", breaks[i + 1])
    }
  }
  labs[n + 1] <- paste0("above_", breaks[n])
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
