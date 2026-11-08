# =============================================================================
# PlotHeatmapJaccard.R -- Jaccard similarity heatmap for set overlaps
# =============================================================================

#' Jaccard Similarity Heatmap
#'
#' Computes pairwise Jaccard similarity between groups based on a set of named
#' variables (e.g. top genes, features), then draws a colour-coded heatmap with
#' optional numeric labels per cell and optional coloured axis strips.
#'
#' @param data A data.frame containing at least a group column and a name column.
#'   Rows with missing group labels or feature names do not contribute to sets.
#'   Labelled and \code{integer64} columns use their class-defined missing values,
#'   including SPSS user-missing codes, even in a fresh R session. Interpreting
#'   these classes requires \pkg{haven} and \pkg{bit64}, respectively.
#'   \code{Duration}, \code{Period} and \code{Interval} inputs require
#'   \pkg{lubridate}. Their complete value components are retained for grouping
#'   and feature matching.
#' @param group_col A single non-missing, non-empty grouping column name
#'   (e.g. cell type). Default \code{"cell_type"}. Its character representation
#'   supplies matrix and axis labels; the original values are retained for
#'   matching.
#' @param name_col A single non-missing, non-empty feature/gene column name used
#'   to compute Jaccard similarity. Default \code{"gene"}.
#' @param title Plot title. Default \code{"Jaccard Similarity"}.
#' @param group_levels Character vector specifying the display order of groups on
#'   both axes. Non-missing entries must have unique character representations;
#'   missing entries are ignored. Unobserved groups are retained as empty sets.
#'   \code{NULL} = factor levels (if factor) or data appearance order.
#'   Typed level vectors use class-defined missing values and the same package
#'   requirements as \code{data}.
#' @param midpoint Midpoint of the colour gradient. Default \code{0.1}.
#' @param text_size Size of the numeric labels inside each cell. Default \code{2.5}.
#'   Set to \code{0} to hide labels.
#' @param show_diag Logical. Whether to show diagonal values. Default \code{FALSE}
#'   (diagonal is set to \code{NA} and shown in grey).
#' @param low_color Low end of the fill gradient. Default \code{"white"}.
#' @param high_color High end of the fill gradient. Default \code{"#B2182B"}.
#' @param show_strip Logical. Whether to draw coloured annotation strips along
#'   the bottom (X axis) and left (Y axis) of the heatmap. Default \code{FALSE}.
#' @param strip_colors Character vector of colours for each group strip.
#'   \code{NULL} = auto palette (same order as \code{group_levels} / \code{ct_names}).
#'   The 16-colour auto palette repeats for additional groups, as do shorter
#'   custom palettes.
#' @param strip_size Numeric. Width/height of the colour strip in data units.
#'   Default \code{0.45}.
#' @param return_type What to return: \code{"plot"} (default, the ggplot object),
#'   \code{"data"} (the Jaccard similarity matrix), or \code{"both"}
#'   (a list with elements \code{plot} and \code{matrix}).
#'   Matrix-only output skips plotting when \code{filename = NULL}; a requested
#'   file is still drawn and saved.
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
#'   Empty sets have similarity \code{0} to every group, including themselves.
#'   Returned plots retain heatmap inputs rather than the original data frame.
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
  if (!is.null(filename)) .check_plot_filename(filename)
  # ---- Check dependencies ----
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.", call. = FALSE)
  return_type <- match.arg(return_type)
  if (!is.data.frame(data)) stop("'data' must be a data.frame.", call. = FALSE)

  # ---- Validate columns ----
  column_selectors <- list(group_col = group_col, name_col = name_col)
  for (argument in names(column_selectors)) {
    selector <- column_selectors[[argument]]
    if (!is.atomic(selector) || !is.null(dim(selector)) || length(selector) != 1L || anyNA(selector) ||
        (is.character(selector) && !nzchar(selector))) {
      stop(sprintf("'%s' must be a single non-missing, non-empty column selector.", argument),
           call. = FALSE)
    }
  }
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data)))
    stop("'data' must have unique, non-missing, non-empty column names.", call. = FALSE)
  for (col in c(group_col, name_col)) {
    if (!col %in% colnames(data))
      stop(sprintf("Column '%s' not found in data.", col), call. = FALSE)
    if (!is.null(dim(data[[col]])))
      stop(sprintf("Column '%s' must be one-dimensional.", col), call. = FALSE)
  }
  if (!is.null(dim(group_levels)))
    stop("'group_levels' must be a one-dimensional vector.", call. = FALSE)
  class_inputs <- list(data[[group_col]], data[[name_col]], group_levels)
  labelled <- vapply(class_inputs, inherits, logical(1), what = "haven_labelled")
  if (any(labelled) && !requireNamespace("haven", quietly = TRUE))
    stop("Interpreting labelled inputs requires package 'haven'.", call. = FALSE)
  integer64 <- vapply(class_inputs, inherits, logical(1), what = "integer64")
  if (any(integer64) && !requireNamespace("bit64", quietly = TRUE))
    stop("Interpreting integer64 inputs requires package 'bit64'.", call. = FALSE)
  time_classes <- c("Duration", "Period", "Interval")
  timespan <- vapply(class_inputs, inherits, logical(1), what = time_classes)
  if (any(timespan) && !requireNamespace("lubridate", quietly = TRUE))
    stop("Interpreting time span inputs requires package 'lubridate'.", call. = FALSE)

  # ---- 1. Group order (priority: group_levels > factor levels > data order) ----
  ct_names <- if (!is.null(group_levels)) {
    group_levels
  } else if (is.factor(data[[group_col]])) {
    levels(data[[group_col]])
  } else if (timespan[1L]) {
    vctrs::vec_unique(data[[group_col]])
  } else {
    unique(data[[group_col]])
  }
  ct_names <- ct_names[!is.na(ct_names)]
  # Keep typed group keys separate from their display labels.
  ct_labels <- as.character(ct_names)
  if (anyDuplicated(ct_labels))
    stop("'group_levels' must not contain duplicate non-missing groups.", call. = FALSE)
  n_ct <- length(ct_names)
  if (n_ct == 0L)
    stop("No non-missing groups available.", call. = FALSE)

  # ---- 2. Build per-group feature sets ----
  group_values <- data[[group_col]]
  non_missing <- !is.na(group_values) & !is.na(data[[name_col]])
  if (inherits(group_values, "haven_labelled"))
    group_values <- as.vector(group_values)
  # Cache equality proxies without repeatedly restoring S4 time span objects.
  feature_values <- if (timespan[2L]) {
    vctrs::vec_proxy_equal(data[[name_col]])
  } else {
    data[[name_col]]
  }
  ct_keys <- if (inherits(ct_names, time_classes)) {
    lapply(seq_len(n_ct), function(i) ct_names[i])
  } else {
    as.list(ct_names)
  }
  group_labels <- if (timespan[1L] && any(vapply(ct_keys, is.character, logical(1)))) {
    as.character(group_values)
  } else {
    NULL
  }
  top_sets <- lapply(
    stats::setNames(ct_keys, ct_labels),
    function(ct) {
      group_match <- if (timespan[1L] && is.character(ct)) {
        group_labels == ct
      } else if (is.character(group_values) && inherits(ct, time_classes)) {
        group_values == as.character(ct)
      } else if (timespan[1L] && inherits(ct, time_classes)) {
        vctrs::vec_equal(group_values, ct, na_equal = FALSE)
      } else {
        group_values == ct
      }
      rows <- which(group_match & non_missing)
      values <- if (timespan[2L]) vctrs::vec_slice(feature_values, rows) else feature_values[rows]
      if (timespan[2L]) vctrs::vec_unique(values) else unique(as.vector(values))
    }
  )
  set_sizes <- if (timespan[2L]) {
    as.double(vapply(top_sets, vctrs::vec_size, numeric(1)))
  } else {
    as.double(lengths(top_sets))
  }

  # ---- 3. Compute pairwise Jaccard similarity ----
  jmat <- matrix(0, nrow = n_ct, ncol = n_ct,
                 dimnames = list(ct_labels, ct_labels))
  for (i in seq_len(n_ct)) {
    for (j in seq_len(i)) {
      gi <- top_sets[[i]]
      gj <- top_sets[[j]]
      n_intersect <- if (timespan[2L]) sum(vctrs::vec_in(gi, gj)) else sum(gi %in% gj)
      n_union <- set_sizes[i] + set_sizes[j] - n_intersect
      jmat[i, j] <- if (n_union > 0) n_intersect / n_union else 0
      jmat[j, i] <- jmat[i, j]
    }
  }

  if (return_type == "data" && is.null(filename)) return(jmat)
  p <- .build_jaccard_plot(jmat, ct_labels, list(title = title, midpoint = midpoint,
    text_size = text_size, show_diag = show_diag, low_color = low_color, high_color = high_color,
    show_strip = show_strip, strip_colors = strip_colors, strip_size = strip_size))

  # ---- Save ----
  if (!is.null(filename)) {
    existed <- file.exists(filename)
    ggplot2::ggsave(filename, p, width = width, height = height, dpi = dpi, bg = "white")
    .cat_saved("PlotHeatmapJaccard: the plot has been saved to", filename,
               sprintf("%sx%s in", format(width), format(height)), existed,
               toupper(tools::file_ext(filename)))
  }
  switch(return_type, plot = p, data = jmat, both = list(plot = p, matrix = jmat))
}

# Construct plot mappings outside the analysis frame to release input data.
.build_jaccard_plot <- function(jmat, ct_names, style) {
  force(jmat)
  force(ct_names)
  force(style)
  n_ct <- length(ct_names)
  title <- style$title
  midpoint <- style$midpoint
  text_size <- style$text_size
  show_diag <- style$show_diag
  low_color <- style$low_color
  high_color <- style$high_color
  show_strip <- style$show_strip
  strip_colors <- style$strip_colors
  strip_size <- style$strip_size
  for (arg in c("show_diag", "show_strip")) {
    value <- get(arg)
    if (!is.logical(value) || !is.null(dim(value)) || length(value) != 1L || is.na(value))
      stop("'", arg, "' must be TRUE or FALSE.", call. = FALSE)
  }
  for (arg in c("midpoint", "text_size", if (show_strip) "strip_size")) {
    value <- get(arg)
    if (!is.numeric(value) || is.object(value) || !is.null(dim(value)) ||
        length(value) != 1L || !is.finite(value))
      stop("'", arg, "' must be a single finite number.", call. = FALSE)
  }
  for (arg in c("low_color", "high_color", if (show_strip && !is.null(strip_colors)) "strip_colors")) {
    value <- get(arg)
    if (!is.atomic(value) || !is.null(dim(value)) || !length(value) ||
        (arg != "strip_colors" && length(value) != 1L))
      stop("'", arg, "' must contain valid R colours.", call. = FALSE)
    tryCatch(grDevices::col2rgb(value, alpha = TRUE), error = function(e) {
      stop("'", arg, "' must contain valid R colours.", call. = FALSE)
    })
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
    strip_colors <- rep_len(default_cols, n_ct)
  }
  if (show_strip && length(strip_colors) != n_ct)
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

  p
}
