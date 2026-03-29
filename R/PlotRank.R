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
#' @param group_col Column name for the grouping variable (e.g. cell type).
#'   Default \code{"cell_type"}.  Ignored for vector / matrix input.
#' @param name_col Column name for the feature names.
#'   Default \code{"gene"}.  Ignored for vector / matrix input.
#' @param value_col Column name for the numeric scores.
#'   Default \code{"importance"}.  Ignored for vector / matrix input.
#' @param groups Character vector of groups to plot (for matrix or
#'   data.frame input).  \code{NULL} (default) = all groups.
#' @param group_levels Character vector specifying display order.
#'   \code{NULL} = data appearance order or factor levels.
#' @param top_n Integer. Number of top-ranked features to highlight
#'   per group. Default \code{5}.
#' @param max_show Integer. Maximum features to display per panel.
#'   Default \code{200}.
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
#' @param highlight_color Colour for top-ranked points.
#'   Default \code{"#007D9B"}.
#' @param base_color Colour for remaining points.
#'   Default \code{"#BECEE3"}.
#' @param label_size Numeric. Text label size. Default \code{4}.
#' @param point_size Numeric. Point size. Default \code{3}.
#' @param title Character. Plot title. \code{NULL} = auto.
#' @param ylab Character. Y-axis label. Default \code{"Importance"}.
#' @param base_size Numeric. Base font size. Default \code{12}.
#' @param ncol Integer. Number of columns in faceted layout. Default \code{4}.
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
#' \dontrun{
#' library(ToyData)
#' data(Toy_gene_importance)
#'
#' # Faceted rank scatter (all cell types)
#' PlotRank(Toy_gene_importance, top_n = 10, ncol = 4, ylab = "Gene Importance (IG)")
#'
#' # Single cell type
#' PlotRank(Toy_gene_importance, groups = "Parathyroid cells", top_n = 15)
#'
#' # With value scaling
#' PlotRank(Toy_gene_importance, top_n = 10, value_scale = "group")
#'
#' # Pathway scores matrix
#' PlotRank(pred$pathway_scores, top_n = 10, ylab = "Pathway Score")
#'
#' # Named numeric vector
#' scores <- setNames(runif(100), paste0("Gene", 1:100))
#' PlotRank(scores, top_n = 10)
#' }
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

  # ---- Parse input into named list of named numeric vectors ----
  score_list <- .pr_parse(data, group_col, name_col, value_col, groups)

  # ---- Keep original full ranges for "group" scaling ----
  if (value_scale == "group") {
    orig_ranges <- lapply(score_list, function(v) range(v, na.rm = TRUE))
  }

  # ---- Group order ----
  if (!is.null(group_levels)) {
    score_list <- score_list[intersect(group_levels, names(score_list))]
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
  if (value_scale == "group") {
    # Scale using the FULL group range from original data (before max_show)
    plot_df$Score <- mapply(function(s, g) {
      rng <- orig_ranges[[as.character(g)]]
      mn <- rng[1]; mx <- rng[2]
      if (mx == mn) 0 else (s - mn) / (mx - mn)
    }, plot_df$Score, as.character(plot_df$Group))
  } else if (value_scale == "top_n") {
    # Scale using only the displayed values within each group
    for (grp in unique(plot_df$Group)) {
      idx <- plot_df$Group == grp
      vals <- plot_df$Score[idx]
      mn <- min(vals, na.rm = TRUE)
      mx <- max(vals, na.rm = TRUE)
      plot_df$Score[idx] <- if (mx == mn) 0 else (vals - mn) / (mx - mn)
    }
  }

  # Enforce group order as factor
  grp_order <- if (!is.null(group_levels)) {
    intersect(group_levels, unique(plot_df$Group))
  } else {
    unique(plot_df$Group)
  }
  plot_df$Group <- factor(plot_df$Group, levels = grp_order)

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
    ggplot2::ggsave(filename, p,
                    width = width, height = height, dpi = dpi, bg = "white")
    message(sprintf("Plot saved to: %s", filename))
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

  ## -- Named numeric vector --
  if (is.numeric(data) && !is.null(names(data))) {
    lbl <- if (!is.null(groups)) groups[1] else "All"
    return(setNames(list(data), lbl))
  }

  ## -- Matrix (rows = features, columns = groups) --
  if (is.matrix(data)) {
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
      v <- data[, ct]; names(v) <- rownames(data); v
    }))
  }

  ## -- data.frame --
  if (is.data.frame(data)) {
    for (col in c(name_col, value_col)) {
      if (!col %in% colnames(data))
        stop(sprintf("Column '%s' not found in data.", col), call. = FALSE)
    }

    # Has group column -> faceted
    if (group_col %in% colnames(data)) {
      grps <- if (!is.null(groups)) groups else {
        if (is.factor(data[[group_col]])) levels(data[[group_col]])
        else unique(data[[group_col]])
      }
      return(lapply(setNames(grps, grps), function(g) {
        sub_df <- data[data[[group_col]] == g, ]
        v <- sub_df[[value_col]]
        names(v) <- sub_df[[name_col]]
        v
      }))
    }

    # No group column -> single panel
    v <- data[[value_col]]
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
