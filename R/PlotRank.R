# =============================================================================
# PlotRank.R -- Rank scatter plot for per-group ranked measurements
# =============================================================================
#
# Architecture (2 layers):
#
#   L1  PlotRank(data, group_col, name_col, value_col, ...)  -- public API
#         +-- L2  .pr_parse()    normalise input -> named numeric vectors
#         +-- L2  .pr_single()   single-panel rank scatter
#         +-- L2  .pr_facet()    faceted multi-panel rank scatter
# =============================================================================

#' Rank Scatter Plot
#'
#' Ranks features (genes, pathways, regulons, etc.) by their scores and
#' highlights the top-ranked ones with coloured points and text labels.
#' Designed for DNN model interpretation outputs (Integrated Gradients
#' importance scores) but works with any named score data.
#'
#' @param data Input data in one of the following formats:
#'   \describe{
#'     \item{data.frame}{Must contain columns specified by \code{name_col}
#'       and \code{value_col}.  If \code{group_col} exists, a faceted
#'       multi-panel plot is produced.}
#'     \item{Named numeric vector}{Values are scores; names are feature
#'       labels.  Produces a single-panel plot.}
#'     \item{Matrix}{Rows = features, columns = groups (e.g. cell types).
#'       Use \code{groups} to select specific columns.}
#'   }
#'   Scores must be one-dimensional real numeric values. Numeric haven
#'   labelled scores are supported, with class-defined missing values
#'   (including SPSS user missings) excluded before ranking. Matrix and list
#'   columns, integer64, time classes and complex scores are not supported;
#'   convert them explicitly after choosing units and checking precision.
#' @param group_col Column name for the grouping variable (e.g. cell type).
#'   Default \code{"cell_type"}.  Ignored for vector / matrix input.
#'   Distinct grouping values must have unique character labels. Values with
#'   identical labels (for example, very close numeric values) are rejected;
#'   explicitly assign unique character labels before plotting.
#' @param name_col Column name for the feature names.
#'   Default \code{"gene"}.  Ignored for vector / matrix input.
#' @param value_col Column name for the numeric scores.
#'   Default \code{"importance"}.  Ignored for vector / matrix input.
#' @param groups Character vector of groups to plot (for matrix or
#'   data.frame input).  \code{NULL} (default) = all groups.
#'   Groups without non-missing scores are skipped. An error is raised when
#'   no valid scores remain after group selection.
#' @param group_levels Character vector specifying display order.
#'   \code{NULL} = data appearance order or factor levels.
#' @param top_n Single finite non-negative integer. Number of top-ranked
#'   features to highlight per group. Default \code{5}; \code{0} highlights
#'   no features. Fractional values are rejected instead of truncated.
#' @param max_show Single finite positive integer. Maximum features to display
#'   per panel. Default \code{200}. Fractional values are rejected instead
#'   of truncated.
#' @param value_scale Per-group score scaling strategy. Three options:
#'   \describe{
#'     \item{\code{"none"} (default)}{No scaling; raw scores are plotted as-is.}
#'     \item{\code{"group"}}{Scale each group independently to \code{[0, 1]}
#'       using the group's full value range from the \strong{original} data
#'       (before \code{max_show} truncation). Useful when absolute score
#'       magnitudes differ greatly across groups.}
#'     \item{\code{"top_n"}}{Scale each group to \code{[0, 1]} using only the
#'       displayed (post-\code{max_show}) values. Stretches the visible range
#'       within each panel to maximise visual separation.}
#'   }
#'   Extreme finite ranges are rescaled before subtraction to avoid overflow.
#' @param highlight_color Colour for top-ranked points.
#'   Default \code{"#007D9B"}.
#' @param base_color Colour for remaining points.
#'   Default \code{"#BECEE3"}.
#' @param label_size Numeric. Text label size. Default \code{4}.
#' @param point_size Numeric. Point size. Default \code{3}.
#' @param title Character. Plot title. \code{NULL} = auto.
#' @param ylab Character. Y-axis label. Default \code{"Importance"}.
#' @param base_size Numeric. Base font size. Default \code{12}.
#' @param ncol Single finite positive integer. Number of columns in faceted
#'   layout. Default \code{4}; \code{NULL} uses an automatic layout.
#'   Invalid values are rejected for both single-panel and faceted inputs.
#'   Must be within the faceting backend's supported whole-number range.
#' @param clean_names Logical. Strip common prefixes (\code{HALLMARK_},
#'   \code{KEGG_}, etc.) and replace underscores with spaces.
#'   Default \code{TRUE}.
#' @param return_type What to return: \code{"plot"} (default),
#'   \code{"data"} (the ranked data.frame), or \code{"both"}.
#' @param filename Output file path. \code{NULL} = no save.
#' @param width Output width in inches. Default \code{12}.
#' @param height Output height in inches. Default \code{10}.
#' @param dpi Output resolution. Default \code{300}.
#'
#' @return Depends on \code{return_type}:
#'   \describe{
#'     \item{"plot"}{A \code{ggplot} object (default).}
#'     \item{"data"}{A data.frame with columns: Group, Rank, Score, Label, IsTop.}
#'     \item{"both"}{A list with elements \code{plot} and \code{data}.}
#'   }
#'
#' @examples
#' set.seed(42)
#' scores <- setNames(runif(12), paste0("Gene", seq_len(12)))
#'
#' # Highlight three of the eight displayed features
#' rank_plot <- PlotRank(scores, top_n = 3, max_show = 8)
#' rank_plot
#'
#' # Return ranked data without highlighting features
#' ranked_data <- PlotRank(scores, top_n = 0, max_show = 5, return_type = "data")
#' ranked_data
#'
#' # Rank two groups with automatic faceting and full-range scaling
#' score_matrix <- matrix(runif(24), nrow = 12,
#'                        dimnames = list(names(scores), c("Group A", "Group B")))
#' ranked_groups <- PlotRank(score_matrix, top_n = 3, max_show = 8,
#'                          value_scale = "group", ncol = NULL,
#'                          return_type = "both")
#' ranked_groups$plot
#' head(ranked_groups$data)
#'
#' @family plot
#' @seealso \code{\link{PlotRankCor}()} for comparing ranks from two methods.
#'
#' @export
PlotRank <- function(
    data,
    group_col       = "cell_type",
    name_col        = "gene",
    value_col       = "importance",
    groups          = NULL,
    group_levels    = NULL,
    top_n           = 5L,
    max_show        = 200L,
    value_scale     = c("none", "group", "top_n"),
    highlight_color = "#007D9B",
    base_color      = "#BECEE3",
    label_size      = 4,
    point_size      = 3,
    title           = NULL,
    ylab            = "Importance",
    base_size       = 12,
    ncol            = 4L,
    clean_names     = TRUE,
    return_type     = c("plot", "data", "both"),
    filename        = NULL,
    width           = 12,
    height          = 10,
    dpi             = 300
) {
  # ---- Check dependencies ----
  for (pkg in c("ggplot2", "ggrepel")) {
    if (!requireNamespace(pkg, quietly = TRUE))
      stop(sprintf("Package '%s' is required.", pkg), call. = FALSE)
  }
  return_type  <- match.arg(return_type)
  value_scale  <- match.arg(value_scale)

  validate_count <- function(value, name, minimum) {
    if (length(value) != 1L || !is.numeric(value) || is.object(value) ||
        is.complex(value) || !is.null(dim(value)) || !is.finite(value) ||
        value < minimum || value != trunc(value)) {
      requirement <- if (minimum == 0) "non-negative" else "positive"
      stop(sprintf("`%s` must be a single finite %s integer.", name, requirement),
           call. = FALSE)
    }
  }
  validate_count(top_n, "top_n", 0)
  validate_count(max_show, "max_show", 1)
  if (!is.null(ncol)) {
    validate_count(ncol, "ncol", 1)
    if (!rlang::is_scalar_integerish(ncol)) {
      stop("`ncol` is outside the supported whole-number range.", call. = FALSE)
    }
  }

  # ---- Parse input into named list of named numeric vectors ----
  score_list <- .pr_parse(data, group_col, name_col, value_col, groups)

  # ---- Group order ----
  if (!is.null(group_levels)) {
    score_list <- score_list[intersect(group_levels, names(score_list))]
  }
  score_list <- lapply(score_list, function(v) v[!is.na(v)])
  score_list <- score_list[lengths(score_list) > 0L]
  if (!length(score_list)) stop("No valid scores remain after group selection.", call. = FALSE)

  # ---- Keep original full ranges for "group" scaling ----
  if (value_scale == "group") {
    orig_ranges <- lapply(score_list, function(v) range(v, na.rm = TRUE))
  }

  # ---- Clean feature names ----
  if (clean_names) {
    score_list <- lapply(score_list, function(v) {
      nm <- names(v)
      nm <- sub("\\(\\+\\)$", "", nm)
      nm <- sub("\\(\\-\\)$", "", nm)
      nm <- sub("\\(\\d+g\\)$", "", nm)
      nm <- trimws(nm)
      nm <- sub("^HALLMARK_", "", nm)
      nm <- sub("^KEGG_",     "", nm)
      nm <- sub("^REACTOME_", "", nm)
      nm <- sub("^GOBP_",     "", nm)
      nm <- sub("^PROGENY_",  "", nm)
      nm <- sub("^WP_",       "", nm)
      nm <- sub("^PID_",      "", nm)
      nm <- sub("^BIOCARTA_", "", nm)
      nm <- gsub("_", " ", nm)
      names(v) <- nm
      v
    })
  }

  # ---- Build ranked data.frame ----
  all_df <- lapply(names(score_list), function(grp) {
    scores <- sort(score_list[[grp]], decreasing = TRUE)
    n      <- min(length(scores), max_show)
    data.frame(
      Group = grp,
      Rank  = seq_len(n),
      Score = scores[seq_len(n)],
      Label = names(scores)[seq_len(n)],
      IsTop = c(rep(TRUE,  min(top_n, n)),
                rep(FALSE, max(0L, n - top_n))),
      stringsAsFactors = FALSE
    )
  })
  plot_df <- do.call(rbind, all_df)

  # ---- Per-group value scaling (value_scale) ----
  scale_scores <- function(x, rng) {
    if (rng[2] == rng[1]) return(rep(0, length(x)))
    span <- rng[2] - rng[1]
    if (!is.finite(span) && all(is.finite(rng))) {
      magnitude <- max(abs(rng))
      return((x / magnitude - rng[1] / magnitude) /
               (rng[2] / magnitude - rng[1] / magnitude))
    }
    (x - rng[1]) / span
  }
  if (value_scale == "group") {
    # Scale using the FULL group range from original data (before max_show)
    if (is.object(plot_df$Score)) {
      plot_df$Score <- mapply(function(s, g) {
        scale_scores(s, orig_ranges[[as.character(g)]])
      }, plot_df$Score, as.character(plot_df$Group))
    } else {
      scaled <- numeric(nrow(plot_df))
      indices <- split(seq_len(nrow(plot_df)), plot_df$Group)
      for (grp in names(indices)) {
        idx <- indices[[grp]]
        scaled[idx] <- scale_scores(plot_df$Score[idx], orig_ranges[[as.character(grp)]])
      }
      plot_df$Score <- scaled
    }
  } else if (value_scale == "top_n") {
    # Scale using only the displayed values within each group
    for (grp in unique(plot_df$Group)) {
      idx <- plot_df$Group == grp
      vals <- plot_df$Score[idx]
      plot_df$Score[idx] <- scale_scores(vals, range(vals, na.rm = TRUE))
    }
  }

  # Enforce group order as factor
  grp_order <- if (!is.null(group_levels)) {
    intersect(group_levels, unique(plot_df$Group))
  } else {
    unique(plot_df$Group)
  }
  plot_df$Group <- factor(plot_df$Group, levels = grp_order)
  if (return_type == "data" && is.null(filename)) return(plot_df)

  # ---- Build plot ----
  is_single <- length(score_list) == 1L

  if (is_single) {
    p <- .pr_single(plot_df, highlight_color, base_color,
                    label_size, point_size,
                    if (!is.null(title)) title else grp_order[1],
                    ylab, base_size)
  } else {
    p <- .pr_facet(plot_df, highlight_color, base_color,
                   label_size, point_size, title,
                   ylab, base_size, ncol)
  }

  # ---- Save ----
  if (!is.null(filename)) {
    # measured before writing, which creates the file
    existed <- file.exists(filename)
    ggplot2::ggsave(filename, p,
                    width = width, height = height, dpi = dpi, bg = "white")
    .cat_saved("PlotRank: the plot has been saved to", filename,
               sprintf("%sx%s in", format(width), format(height)), existed,
               toupper(tools::file_ext(filename)))
  }

  # ---- Return ----
  switch(return_type,
    plot = p,
    data = plot_df,
    both = list(plot = p, data = plot_df)
  )
}


# ============================================================================
# Internal helpers
# ============================================================================

#' Parse diverse inputs into a named list of named numeric vectors
#' @keywords internal
.pr_parse <- function(data, group_col, name_col, value_col, groups) {
  score_values <- function(x) {
    if (!is.object(x) && is.null(dim(x)) && is.logical(x) && all(is.na(x))) x <- as.double(x)
    if (inherits(x, "integer64")) {
      stop("Scores with integer64 storage are not supported; convert explicitly after checking precision.",
           call. = FALSE)
    }
    unsupported <- inherits(x, c("Date", "POSIXt", "difftime", "Duration", "Period", "Interval")) ||
      (is.object(x) && !inherits(x, c("haven_labelled", "AsIs")))
    if (unsupported || !is.numeric(x) || is.complex(x) || !is.null(dim(x))) {
      stop("Scores must contain one-dimensional real numeric values; convert unsupported storage explicitly.",
           call. = FALSE)
    }
    if (inherits(x, "haven_labelled")) {
      if (!requireNamespace("haven", quietly = TRUE)) {
        stop("Interpreting labelled scores requires package 'haven'.", call. = FALSE)
      }
      x[is.na(x)] <- NA
    }
    x
  }

  ## -- Named numeric vector --
  if (!is.data.frame(data) && !is.matrix(data)) {
    data <- score_values(data)
  }
  if (is.numeric(data) && is.null(dim(data)) && !is.null(names(data))) {
    lbl <- if (!is.null(groups)) groups[1] else "All"
    return(setNames(list(data), lbl))
  }

  ## -- Matrix (rows = features, columns = groups) --
  if (is.matrix(data)) {
    if (is.null(colnames(data)) || anyNA(colnames(data)) ||
        any(!nzchar(colnames(data))) || anyDuplicated(colnames(data)))
      stop("Matrix columns must have unique, non-missing, non-empty group names.", call. = FALSE)
    cols <- if (!is.null(groups)) {
      bad <- setdiff(groups, colnames(data))
      if (length(bad))
        stop("Groups not found in matrix columns: ",
             paste(bad, collapse = ", "), call. = FALSE)
      groups
    } else {
      colnames(data)
    }
    return(lapply(setNames(cols, cols), function(ct) {
      v <- score_values(data[, ct]); names(v) <- rownames(data); v
    }))
  }

  ## -- data.frame --
  if (is.data.frame(data)) {
    if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data)))
      stop("'data' must have unique, non-missing, non-empty column names.", call. = FALSE)
    for (arg in c("group_col", "name_col", "value_col")) {
      value <- get(arg)
      if (!is.character(value) || !is.null(dim(value)) || length(value) != 1L ||
          is.na(value) || !nzchar(value))
        stop("'", arg, "' must be one non-missing column name.", call. = FALSE)
    }
    for (col in c(name_col, value_col)) {
      if (!col %in% colnames(data))
        stop(sprintf("Column '%s' not found in data.", col), call. = FALSE)
    }
    scores <- score_values(data[[value_col]])

    # Has group column -> faceted
    if (group_col %in% colnames(data)) {
      grps <- if (is.factor(data[[group_col]])) levels(data[[group_col]])
        else unique(data[[group_col]])
      if (anyDuplicated(as.character(grps))) {
        stop("Distinct grouping values have identical character labels. ",
             "Convert the grouping column to unique character labels before plotting.",
             call. = FALSE)
      }
      if (!is.null(groups)) grps <- groups
      return(lapply(setNames(grps, grps), function(g) {
        index <- data[[group_col]] == g
        v <- scores[index]
        names(v) <- data[[name_col]][index]
        v
      }))
    }

    # No group column -> single panel
    v <- scores
    names(v) <- data[[name_col]]
    lbl <- if (!is.null(groups)) groups[1] else "All"
    return(setNames(list(v), lbl))
  }

  stop("Unsupported input type. ",
       "Provide a data.frame, named numeric vector, or matrix.",
       call. = FALSE)
}


#' Single-panel rank scatter
#' @keywords internal
.pr_single <- function(df, hi_col, base_col,
                       lab_size, pt_size, title,
                       ylab, base_size) {

  label_df <- df[df$IsTop, ]

  ggplot2::ggplot(df, ggplot2::aes(
    x = .data[["Rank"]], y = .data[["Score"]]
  )) +
    ggplot2::geom_point(
      size  = pt_size,
      color = ifelse(df$IsTop, hi_col, base_col)
    ) +
    ggrepel::geom_text_repel(
      data = label_df,
      ggplot2::aes(
        x = .data[["Rank"]], y = .data[["Score"]],
        label = .data[["Label"]]
      ),
      size = lab_size, inherit.aes = FALSE,
      max.overlaps = 20
    ) +
    ggplot2::ggtitle(title) +
    ggplot2::ylab(ylab) +
    ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.line  = ggplot2::element_line(color = "black"),
      axis.ticks = ggplot2::element_line(color = "black"),
      axis.text  = ggplot2::element_text(color = "black"),
      plot.title = ggplot2::element_text(hjust = 0.5)
    )
}


#' Faceted multi-panel rank scatter
#' @keywords internal
.pr_facet <- function(df, hi_col, base_col,
                      lab_size, pt_size, title,
                      ylab, base_size, ncol) {

  df$TopGroup <- ifelse(df$IsTop, "top", "other")
  label_df    <- df[df$IsTop, ]

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[["Rank"]], y = .data[["Score"]],
      color = .data[["TopGroup"]]
    )
  ) +
    ggplot2::geom_point(size = pt_size) +
    ggplot2::scale_color_manual(
      values = c("top" = hi_col, "other" = base_col),
      guide  = "none"
    ) +
    ggrepel::geom_text_repel(
      data = label_df,
      ggplot2::aes(
        x = .data[["Rank"]], y = .data[["Score"]],
        label = .data[["Label"]]
      ),
      size = lab_size, color = "black", inherit.aes = FALSE,
      max.overlaps = 20
    ) +
    ggplot2::facet_wrap(~ Group, ncol = ncol, scales = "free") +
    ggplot2::ylab(ylab) +
    ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.line  = ggplot2::element_line(color = "black"),
      axis.ticks = ggplot2::element_line(color = "black"),
      axis.text  = ggplot2::element_text(color = "black"),
      strip.text = ggplot2::element_text(face = "bold"),
      plot.title = ggplot2::element_text(hjust = 0.5)
    )

  if (!is.null(title)) p <- p + ggplot2::ggtitle(title)
  p
}
