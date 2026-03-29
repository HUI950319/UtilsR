#' Jaccard Similarity Heatmap
#'
#' Computes pairwise Jaccard similarity between groups based on a set of named
#' variables (e.g. top genes, features), then draws a colour-coded heatmap with
#' optional numeric labels per cell and optional coloured axis strips.
#'
#' @param data A data.frame containing at least a group column and a name column.
#' @param group_col Column name for the grouping variable (e.g. cell type).
#'   Default \code{"cell_type"}.
#' @param name_col Column name for the feature/gene names used to compute
#'   Jaccard similarity. Default \code{"gene"}.
#' @param title Plot title. Default \code{"Jaccard Similarity"}.
#' @param group_levels Character vector specifying the display order of groups on
#'   both axes. \code{NULL} = factor levels (if factor) or data appearance order.
#' @param midpoint Midpoint of the colour gradient. Default \code{0.1}.
#' @param text_size Size of the numeric labels inside each cell. Default \code{2.5}.
#'   Set to \code{0} to hide labels.
#' @param show_diag Logical. Whether to show diagonal values. Default \code{FALSE}
#'   (diagonal is set to \code{NA} and shown in grey).
#' @param low_color Low end of the fill gradient. Default \code{"white"}.
#' @param high_color High end of the fill gradient. Default \code{"#B2182B"}.
#' @param show_strip Logical. Whether to draw coloured annotation strips along
#'   the top (X axis) and left (Y axis) of the heatmap. Default \code{FALSE}.
#' @param strip_colors Character vector of colours for each group strip.
#'   \code{NULL} = auto palette (same order as \code{group_levels} / \code{ct_names}).
#' @param strip_size Numeric. Width/height of the colour strip in data units.
#'   Default \code{0.45}.
#' @param return_type What to return: \code{"plot"} (default, the ggplot object),
#'   \code{"data"} (the Jaccard similarity matrix), or \code{"both"}
#'   (a list with elements \code{plot} and \code{matrix}).
#' @param filename Output file path. \code{NULL} = no save.
#' @param width Output width in inches. Default \code{10}.
#' @param height Output height in inches. Default \code{9}.
#' @param dpi Output resolution. Default \code{300}.
#'
#' @return Depends on \code{return_type}:
#'   \describe{
#'     \item{"plot"}{A \code{ggplot} object (default).}
#'     \item{"data"}{A numeric matrix of pairwise Jaccard similarities.}
#'     \item{"both"}{A list with elements \code{plot} and \code{matrix}.}
#'   }
#'
#' @examples
#' \dontrun{
#' library(ToyData)
#' data(Toy_gene_importance)
#'
#' # Basic Jaccard heatmap
#' PlotHeatmapJaccard(Toy_gene_importance, name_col = "gene")
#'
#' # With coloured axis strips
#' PlotHeatmapJaccard(Toy_gene_importance, name_col = "gene", show_strip = TRUE)
#'
#' # Custom title and return matrix
#' res <- PlotHeatmapJaccard(Toy_gene_importance, name_col = "gene",
#'                            title = "Gene Importance Jaccard",
#'                            return_type = "both")
#' res$matrix
#' }
#'
#' @export
PlotHeatmapJaccard <- function(
    data,
    group_col    = "cell_type",   # grouping column
    name_col     = "gene",        # feature/name column
    title        = "Jaccard Similarity",
    group_levels = NULL,          # display order for both axes (NULL = auto)
    midpoint     = 0.1,           # colour gradient midpoint
    text_size    = 2.5,           # cell label size (0 = hide)
    show_diag    = FALSE,         # show diagonal values
    low_color    = "white",       # gradient low colour
    high_color   = "#B2182B",     # gradient high colour
    show_strip   = FALSE,         # draw coloured axis strips
    strip_colors = NULL,          # colours for each group strip (NULL = auto)
    strip_size   = 0.45,          # strip width/height in data units
    return_type  = c("plot", "data", "both"),  # return plot / matrix / both
    filename     = NULL,          # output path (NULL = no save)
    width        = 10,
    height       = 9,
    dpi          = 300
) {
  # ---- Check dependencies ----
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.", call. = FALSE)
  return_type <- match.arg(return_type)

  # ---- Validate columns ----
  for (col in c(group_col, name_col)) {
    if (!col %in% colnames(data))
      stop(sprintf("Column '%s' not found in data.", col), call. = FALSE)
  }

  # ---- 1. Group order (priority: group_levels > factor levels > data order) ----
  ct_names <- if (!is.null(group_levels)) {
    group_levels
  } else if (is.factor(data[[group_col]])) {
    levels(data[[group_col]])
  } else {
    unique(data[[group_col]])
  }
  n_ct <- length(ct_names)

  # ---- 2. Build per-group feature sets ----
  top_sets <- lapply(
    stats::setNames(ct_names, ct_names),
    function(ct) data[[name_col]][data[[group_col]] == ct]
  )

  # ---- 3. Compute pairwise Jaccard similarity ----
  jmat <- matrix(0, nrow = n_ct, ncol = n_ct,
                 dimnames = list(ct_names, ct_names))
  for (i in seq_len(n_ct)) {
    for (j in seq_len(n_ct)) {
      gi <- top_sets[[i]]
      gj <- top_sets[[j]]
      n_union <- length(union(gi, gj))
      jmat[i, j] <- if (n_union > 0) length(intersect(gi, gj)) / n_union else 0
    }
  }

  # ---- 4. Prepare long data.frame ----
  plot_mat <- jmat
  if (!show_diag) diag(plot_mat) <- NA

  # Wide matrix → long (base R, no reshape2)
  df_long         <- as.data.frame(as.table(plot_mat))
  names(df_long)  <- c("Group1", "Group2", "Jaccard")
  df_long$Jaccard <- as.numeric(df_long$Jaccard)

  # Enforce axis order via factor levels
  df_long$Group1  <- factor(df_long$Group1, levels = ct_names)
  df_long$Group2  <- factor(df_long$Group2, levels = ct_names)

  # ---- 5. Default strip colours ----
  if (show_strip && is.null(strip_colors)) {
    default_cols <- c(
      "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00",
      "#A65628", "#F781BF", "#999999", "#66C2A5", "#FC8D62",
      "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3"
    )
    strip_colors <- default_cols[seq_len(n_ct)]
  }
  if (show_strip && length(strip_colors) < n_ct)
    strip_colors <- rep_len(strip_colors, n_ct)

  # ---- 6. Build heatmap ----
  p <- ggplot2::ggplot(df_long, ggplot2::aes(
    x = .data[["Group1"]], y = .data[["Group2"]], fill = .data[["Jaccard"]]
  )) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.3) +
    ggplot2::scale_fill_gradient2(
      low      = low_color,
      high     = high_color,
      midpoint = midpoint,
      limits   = c(0, 1),
      na.value = "grey95",
      name     = "Jaccard"
    ) +
    ggplot2::ggtitle(title) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      axis.text.x  = ggplot2::element_text(angle = 45, hjust = 1, size = 9),
      axis.text.y  = ggplot2::element_text(size = 9),
      axis.title   = ggplot2::element_blank(),
      panel.grid   = ggplot2::element_blank(),
      plot.title   = ggplot2::element_text(hjust = 0.5, face = "bold", size = 13)
    )

  # ---- 7. Optional cell labels ----
  if (text_size > 0) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(
          label = ifelse(is.na(.data[["Jaccard"]]), "",
                         sprintf("%.2f", .data[["Jaccard"]]))
        ),
        size  = text_size,
        color = "black"
      )
  }

  # ---- 8. Axis colour strips ----
  # Drawn outside the panel with coord_fixed(clip = "off").
  # X positions: integer 1..n_ct (left→right, matches Group1 factor levels).
  # Y positions: integer 1..n_ct (bottom→top, matches Group2 factor levels).
  # Bottom strip: below row 1  → ymin = 0.5 - strip_size, ymax = 0.5
  # Left   strip: left of col 1 → xmin = -0.5 - strip_size, xmax = -0.5
  if (show_strip) {
    idx <- seq_len(n_ct)

    # Bottom strip: ymax = 0.5 is the exact bottom edge of row-1 tiles
    bot_strip <- ggplot2::annotate("rect",
      xmin   = idx - 0.5,
      xmax   = idx + 0.5,
      ymin   = 0.5 - strip_size,
      ymax   = 0.5,
      fill   = strip_colors,
      colour = NA
    )

    # Left strip: xmax = 0.5 is the exact left edge of column-1 tiles
    # (previous xmax = -0.5 left a 1-unit gap → corrected to 0.5)
    left_strip <- ggplot2::annotate("rect",
      xmin   = 0.5 - strip_size,
      xmax   = 0.5,
      ymin   = idx - 0.5,
      ymax   = idx + 0.5,
      fill   = strip_colors,
      colour = NA
    )

    pad <- strip_size * 20 + 5   # points of extra margin
    p <- p +
      bot_strip + left_strip +
      ggplot2::coord_fixed(clip = "off") +
      ggplot2::theme(
        plot.margin = ggplot2::margin(t = 5, r = 5, b = pad, l = pad)
      )
  } else {
    p <- p + ggplot2::coord_fixed()
  }

  # ---- 9. Save ----
  if (!is.null(filename)) {
    ggplot2::ggsave(filename, p,
                    width = width, height = height, dpi = dpi, bg = "white")
    message(sprintf("Plot saved to: %s", filename))
  }

  # ---- 10. Return ----
  switch(return_type,
    plot   = p,
    data   = jmat,
    both   = list(plot = p, matrix = jmat)
  )
}
