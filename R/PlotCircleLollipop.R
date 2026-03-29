#' Circular Lollipop Chart
#'
#' Draws a polar (circular) lollipop chart using \pkg{circlize}, showing
#' per-group ranked feature scores (e.g. gene importance, pathway scores).
#' Features shared across multiple groups are highlighted and optionally
#' connected by inner arcs, reproducing the style of Fig. 4 in
#' \emph{The Lancet Digital Health}.
#'
#' @param data A data.frame with at least three columns: group, feature name,
#'   and numeric value.
#' @param group_col Column name for the grouping variable. Default \code{"group"}.
#' @param name_col Column name for the feature names. Default \code{"name"}.
#' @param value_col Column name for the numeric scores. Default \code{"value"}.
#' @param top_n Integer. If not \code{NULL}, keep only the top \code{top_n}
#'   features per group ranked by \code{value_col} (descending). Applied before
#'   any plotting. \code{NULL} = use all rows as-is.
#' @param value_scale Per-group value scaling applied after \code{top_n}
#'   selection. Three options:
#'   \describe{
#'     \item{\code{"none"} (default)}{No scaling; values are used as-is and
#'       normalised to \code{[0, 1]} globally only if they fall outside that
#'       range.}
#'     \item{\code{"group"}}{Scale each group independently to \code{[0, 1]}
#'       using the group's full value range from the \strong{original} data
#'       (before \code{top_n} filtering). Max value in group = 1, min = 0.
#'       Preserves relative differences within each group across the whole
#'       feature set.}
#'     \item{\code{"top_n"}}{Scale each group independently to \code{[0, 1]}
#'       using only the displayed (post-\code{top_n}) values. Top displayed
#'       feature = 1, bottom displayed feature = 0. Maximises visual spread
#'       within each sector.}
#'   }
#' @param group_levels Character vector controlling the display order of groups.
#'   \code{NULL} = data appearance order (or factor levels if already a factor).
#' @param common_color Colour for features shared across \eqn{\geq 2} groups.
#'   Default \code{"#4682B4"}.
#' @param unique_color Colour for group-unique features. Default \code{"#FF7F50"}.
#' @param color_col Optional column name supplying per-row colours. When
#'   provided, \code{common_color} / \code{unique_color} are ignored.
#' @param show_links Logical. Draw inner arcs connecting shared features across
#'   groups. Default \code{TRUE}.
#' @param link_color Colour of the inner arcs. Default \code{"#4e6a74"}.
#' @param link_lwd Line width of the arcs. Default \code{0.5}.
#' @param link_h Bezier height of the arcs (0–1). Default \code{0.7}.
#' @param show_labels Logical. Draw feature name labels. Default \code{TRUE}.
#' @param label_side Where to place feature labels relative to the sector ring.
#'   Three options:
#'   \describe{
#'     \item{\code{"inside"} (default)}{Labels in the narrow band between the
#'       sector ring inner edge and the lollipop outer edge. Best for small
#'       datasets (few groups / few features per group).}
#'     \item{\code{"outside"}}{Labels inside the grey sector boxes, above the
#'       lollipop stems. Matches the style of Fig. 4 in \emph{The Lancet
#'       Digital Health}. Recommended for 5–10 features per group.}
#'     \item{\code{"outer"}}{Labels placed beyond the outer boundary of the
#'       grey sector boxes, extending outward from the circle. Sector boxes
#'       move one ring inward. Recommended for large datasets
#'       (> 10 features per group).}
#'   }
#' @param label_cex Text size of the labels. Default \code{0.7}.
#' @param label_height Height of the label connector lines in mm. Default \code{4}.
#' @param point_cex Size of the lollipop dots. Default \code{0.8}.
#' @param line_lwd Width of the lollipop stems. Default \code{1}.
#' @param sector_bg Background colour of the sector label track. Default
#'   \code{"grey90"}.
#' @param sector_cex Text size of the sector labels. Default \code{0.8}.
#' @param track_height Height of the lollipop track (0–1). Default \code{0.37}.
#' @param gap_after Gap angle (degrees) after the last sector. Default \code{20}.
#' @param gap_between Gap angle (degrees) between sectors. Default \code{2}.
#' @param start_degree Starting angle in degrees (90 = 12 o'clock). Default \code{90}.
#' @param show_yaxis Logical. Show a y-axis on the first sector. Default \code{TRUE}.
#' @param yaxis_label Y-axis title. Default \code{"Selection score"}.
#' @param filename Output file path (\code{".pdf"} or \code{".png"}).
#'   \code{NULL} = draw to the current device without saving.
#' @param width Output width in inches. Default \code{10}.
#' @param height Output height in inches. Default \code{10}.
#' @param dpi Resolution for PNG output. Default \code{300}.
#'
#' @return \code{invisible(NULL)}. The plot is drawn as a side effect.
#'
#' @examples
#' \dontrun{
#' library(ToyData)
#' library(dplyr)
#'
#' # Prepare top-10 genes per cell type
#' polar_df <- gene_pc |>
#'   group_by(cell_type) |>
#'   slice_max(importance, n = 10) |>
#'   transmute(group = cell_type, name = gene, value = importance) |>
#'   as.data.frame()
#'
#' # Default: labels in the narrow band between sector ring and lollipop
#' PlotCircleLollipop(polar_df, yaxis_label = "Gene Importance (IG)")
#'
#' # Lancet-style: labels inside the grey sector boxes (5-10 genes/group)
#' PlotCircleLollipop(polar_df, top_n = 5,
#'                    label_side = "outside",
#'                    yaxis_label = "Gene Importance (IG)")
#'
#' # Labels beyond the grey sector boxes (recommended for many genes/groups)
#' PlotCircleLollipop(polar_df, top_n = 10,
#'                    label_side = "outer",
#'                    yaxis_label = "Gene Importance (IG)")
#'
#' # Save to PDF
#' PlotCircleLollipop(polar_df,
#'                    label_side = "outer",
#'                    filename   = "circle_lollipop.pdf",
#'                    width = 12, height = 12)
#' }
#'
#' @export
PlotCircleLollipop <- function(
    data,
    group_col    = "group",          # grouping column
    name_col     = "name",           # feature name column
    value_col    = "value",          # numeric score column
    top_n        = NULL,             # keep top-N features per group (NULL = all)
    value_scale  = c("none", "group", "top_n"), # per-group value scaling strategy
    group_levels = NULL,             # display order of groups
    common_color = "#4682B4",        # colour for cross-group shared features
    unique_color = "#FF7F50",        # colour for group-unique features
    color_col    = NULL,             # optional per-row colour column
    show_links   = TRUE,             # draw inner arcs for shared features
    link_color   = "#4e6a74",        # arc colour
    link_lwd     = 0.5,              # arc line width
    link_h       = 0.7,              # arc Bezier height (0-1)
    show_labels  = TRUE,             # draw feature labels
    label_side   = c("inside", "outside", "outer"), # label position relative to sector ring
    label_cex    = 0.7,              # label text size
    label_height = 4,                # label connector height (mm)
    point_cex    = 0.8,              # lollipop dot size
    line_lwd     = 1,                # lollipop stem width
    sector_bg    = "grey90",         # sector label background
    sector_cex   = 0.8,              # sector label text size
    track_height = 0.37,             # lollipop track height
    gap_after    = 20,               # gap after last sector (degrees)
    gap_between  = 2,                # gap between sectors (degrees)
    start_degree = 90,               # start angle (90 = 12 o'clock)
    show_yaxis   = TRUE,             # show y-axis on first sector
    yaxis_label  = "Selection score",# y-axis title
    filename     = NULL,             # output path (NULL = no save)
    width        = 10,
    height       = 10,
    dpi          = 300
) {
  label_side  <- match.arg(label_side)
  value_scale <- match.arg(value_scale)

  # ---- Check dependencies ----
  for (pkg in c("circlize", "dplyr")) {
    if (!requireNamespace(pkg, quietly = TRUE))
      stop(sprintf("Package '%s' is required.", pkg), call. = FALSE)
  }

  # ---- Validate columns ----
  for (col in c(group_col, name_col, value_col)) {
    if (!col %in% colnames(data))
      stop(sprintf("Column '%s' not found in data.", col), call. = FALSE)
  }

  # ---- Keep original data for group-level scaling (before top_n) ----
  data_orig <- data

  # ---- top_n: keep top-N rows per group by value (descending) ----
  if (!is.null(top_n)) {
    top_n <- as.integer(top_n)
    data <- data |>
      dplyr::group_by(.data[[group_col]]) |>
      dplyr::slice_max(order_by = .data[[value_col]], n = top_n,
                       with_ties = FALSE) |>
      dplyr::ungroup() |>
      as.data.frame()
  }

  # ---- Normalise to standard column names ----
  df <- data.frame(
    group = as.character(data[[group_col]]),
    name  = as.character(data[[name_col]]),
    value = as.numeric(data[[value_col]]),
    stringsAsFactors = FALSE
  )

  # ---- Group order ----
  if (!is.null(group_levels)) {
    df$group <- factor(df$group, levels = group_levels)
  } else if (is.factor(data[[group_col]])) {
    df$group <- factor(df$group, levels = levels(data[[group_col]]))
  } else {
    df$group <- factor(df$group, levels = unique(df$group))
  }

  # ---- Per-group x positions (uniform spacing within each sector) ----
  df <- df |>
    dplyr::group_by(group) |>
    dplyr::mutate(
      n_in_group = dplyr::n(),
      idx        = dplyr::row_number(),
      x_pos      = (idx - 0.5) / n_in_group
    ) |>
    dplyr::ungroup()

  # ---- Per-group value scaling (value_scale) ----
  if (value_scale == "group") {
    # Scale using the FULL group range from original data (before top_n)
    orig_grp <- as.character(data_orig[[group_col]])
    orig_val <- as.numeric(data_orig[[value_col]])
    grp_min  <- tapply(orig_val, orig_grp, min, na.rm = TRUE)
    grp_max  <- tapply(orig_val, orig_grp, max, na.rm = TRUE)
    df$value <- mapply(function(v, g) {
      mn <- grp_min[[as.character(g)]]
      mx <- grp_max[[as.character(g)]]
      if (mx == mn) 0 else (v - mn) / (mx - mn)
    }, df$value, as.character(df$group))

  } else if (value_scale == "top_n") {
    # Scale using only the displayed (post-top_n) values within each group
    df <- df |>
      dplyr::group_by(group) |>
      dplyr::mutate(value = {
        mn <- min(value, na.rm = TRUE)
        mx <- max(value, na.rm = TRUE)
        if (mx == mn) rep(0, dplyr::n()) else (value - mn) / (mx - mn)
      }) |>
      dplyr::ungroup() |>
      as.data.frame()
  }

  # ---- Normalise values to [0, 1] if still outside range ----
  val_range <- range(df$value, na.rm = TRUE)
  if (val_range[1] < 0 || val_range[2] > 1) {
    df$y_pos <- (df$value - val_range[1]) / (val_range[2] - val_range[1])
    df$y_pos <- pmax(0.05, df$y_pos)
  } else {
    df$y_pos <- df$value
  }

  # ---- Assign colours ----
  if (!is.null(color_col) && color_col %in% colnames(data)) {
    df$color <- as.character(data[[color_col]])
  } else {
    common_names <- df |>
      dplyr::group_by(name) |>
      dplyr::summarise(n_groups = dplyr::n_distinct(group), .groups = "drop") |>
      dplyr::filter(n_groups > 1) |>
      dplyr::pull(name)
    df$color <- ifelse(df$name %in% common_names, common_color, unique_color)
  }

  # ---- Shared-feature data for inner arcs ----
  common_genes <- df |>
    dplyr::group_by(name) |>
    dplyr::filter(dplyr::n_distinct(group) > 1) |>
    dplyr::ungroup()

  # ---- Label data for circos.genomicLabels ----
  label_data <- data.frame(
    chr   = as.character(df$group),
    start = df$x_pos - 0.001,
    end   = df$x_pos + 0.001,
    label = df$name,
    color = df$color,
    stringsAsFactors = FALSE
  )

  # ---- Core drawing function ----
  .draw <- function() {
    circlize::circos.clear()
    graphics::par(mar = c(1, 1, 1, 1))
    graphics::plot.new()

    n_groups <- nlevels(df$group)
    circlize::circos.par(
      start.degree = start_degree,
      gap.after    = c(rep(gap_between, n_groups - 1), gap_after),
      track.margin = c(0, 0.01),
      cell.padding = c(0, 0, 0, 0)
    )

    circlize::circos.initialize(factors = df$group, xlim = c(0, 1))

    # When values are scaled to [0,1], extend ylim slightly so top dots are
    # not clipped at the track boundary
    ylim_max  <- if (value_scale != "none") 1.02 else 1
    grp_levels <- levels(df$group)

    # ---- Track builder: sector label ring ----
    .draw_sector_track <- function() {
      circlize::circos.track(
        factors      = df$group,
        ylim         = c(0, 1),
        track.height = 0.08,
        bg.col       = sector_bg,
        panel.fun = function(x, y) {
          circlize::circos.text(
            circlize::CELL_META$xcenter,
            circlize::CELL_META$ylim[2] - 0.7,
            circlize::CELL_META$sector.index,
            facing = "bending.inside",
            cex    = sector_cex,
            adj    = c(0.5, 0)
          )
        }
      )
    }

    # ---- Track builder: lollipop data track ----
    .draw_lollipop_track <- function() {
      circlize::circos.trackPlotRegion(
        factors      = df$group,
        ylim         = c(0, ylim_max),
        track.height = track_height,
        panel.fun = function(x, y) {
          sector_data <- df[df$group == circlize::CELL_META$sector.index, ]

          for (i in seq_len(nrow(sector_data))) {
            xp <- sector_data$x_pos[i]
            yp <- sector_data$y_pos[i]
            cl <- sector_data$color[i]
            circlize::circos.lines(c(xp, xp), c(0, yp), col = cl, lwd = line_lwd)
            circlize::circos.points(xp, yp, pch = 16, col = cl, cex = point_cex)
          }

          # Y-axis on the first sector only
          if (show_yaxis &&
              circlize::CELL_META$sector.index == grp_levels[1]) {
            circlize::circos.yaxis(
              side         = "left",
              at           = seq(0, 1, by = 0.2),
              labels.cex   = 0.8,
              tick.length  = circlize::convert_length(2, "mm")
            )
            circlize::circos.text(
              circlize::CELL_META$cell.xlim[1] -
                circlize::convert_x(10, "mm"),
              0.5,
              yaxis_label,
              facing     = "reverse.clockwise",
              niceFacing = TRUE,
              adj        = c(0.5, 0.5),
              cex        = 0.8
            )
          }
        }
      )
    }

    # ---- Draw tracks + labels in the right interleaved order ----
    #
    # circos.genomicLabels(side = "outside") inserts a label track just outside
    # whichever track was drawn most recently.  Three modes:
    #
    #   "inside"  – sector → lollipop → genomicLabels
    #               labels in the narrow band between two tracks
    #
    #   "outside" – sector → genomicLabels → lollipop
    #               labels fill the grey sector-box area (Lancet Fig.4 style)
    #
    #   "outer"   – genomicLabels → sector → lollipop
    #               labels beyond the outer boundary of the grey sector boxes
    #
    .label_call <- function() {
      circlize::circos.genomicLabels(
        label_data,
        labels.column     = 4,
        facing            = "reverse.clockwise",
        side              = "outside",
        cex               = label_cex,
        col               = label_data$color,
        connection_height = circlize::convert_height(label_height, "mm"),
        line_lwd          = 0.5
      )
    }

    if (label_side == "outer") {
      # genomicLabels BEFORE all tracks → label track is outermost
      if (show_labels) .label_call()
      .draw_sector_track()
      .draw_lollipop_track()
    } else if (label_side == "outside") {
      # genomicLabels BETWEEN sector and lollipop → labels in grey-box area
      .draw_sector_track()
      if (show_labels) .label_call()
      .draw_lollipop_track()
    } else {
      # "inside": genomicLabels AFTER both tracks → labels in narrow inner band
      .draw_sector_track()
      .draw_lollipop_track()
      if (show_labels) .label_call()
    }

    # ---- Inner arcs for shared features ----
    if (show_links && nrow(common_genes) > 0) {
      for (gene_name in unique(common_genes$name)) {
        gd <- common_genes[common_genes$name == gene_name, ]
        if (nrow(gd) > 1) {
          for (i in seq_len(nrow(gd) - 1)) {
            for (j in seq(i + 1, nrow(gd))) {
              circlize::circos.link(
                as.character(gd$group[i]), gd$x_pos[i],
                as.character(gd$group[j]), gd$x_pos[j],
                col = link_color, lwd = link_lwd, h = link_h
              )
            }
          }
        }
      }
    }

    circlize::circos.clear()
  }

  # ---- Save or draw ----
  if (!is.null(filename)) {
    ext <- tolower(tools::file_ext(filename))
    if (ext == "pdf") {
      grDevices::pdf(filename, width = width, height = height)
    } else {
      grDevices::png(filename, width = width, height = height,
                     units = "in", res = dpi)
    }
    .draw()
    grDevices::dev.off()
    message(sprintf("Plot saved to: %s", filename))
  } else {
    .draw()
  }

  invisible(NULL)
}
