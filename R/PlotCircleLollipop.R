# =============================================================================
# PlotCircleLollipop.R -- Circular lollipop chart
# =============================================================================

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
#'   Missing group labels are rejected before drawing. Unused group levels
#'   are omitted from the chart.
#' @param group_col Column name for the grouping variable. Default \code{"group"}.
#'   Distinct values with coinciding character labels use higher precision
#'   and, if needed, numeric suffixes to keep sectors and scaling separate.
#' @param name_col Column name for the feature names. Default \code{"name"}.
#' @param value_col Column name for the numeric scores. Default \code{"value"}.
#'   Numeric character strings and factor labels (including ordered factors)
#'   are parsed before ranking or scaling. Invalid non-missing labels are
#'   rejected; existing missing scores are retained.
#' @param top_n A single non-negative whole number no greater than
#'   \code{.Machine$integer.max}, or \code{NULL}. Keep this many features per
#'   group ranked by the parsed numeric scores (descending), before plotting.
#'   Integers and whole-valued doubles are accepted; character, logical and
#'   factor counts, fractions, missing values and infinite values are rejected.
#'   \code{NULL} uses all rows as-is. Zero selects no rows and raises
#'   \code{"No observations to plot."}.
#' @param value_scale Per-group value scaling applied after \code{top_n}
#'   selection. Three options:
#'   \describe{
#'     \item{\code{"none"} (default)}{No scaling; values are used as-is and
#'       normalised to \code{[0, 1]} globally only if they fall outside that
#'       range. A constant global range outside \code{[0, 1]} uses the
#'       minimum lollipop height of \code{0.05}.}
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
#'   Extreme finite ranges are rescaled before subtraction to avoid overflow.
#' @param group_levels Character vector controlling the display order of groups.
#'   \code{NULL} = data appearance order (or factor levels if already a factor).
#'   Must include every observed group; unobserved levels are omitted.
#'   Use the displayed labels when group labels require higher precision.
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
#'   Plot margins are restored and the chart's circlize state is cleared
#'   even if drawing fails. Saving closes its own device and restores the
#'   caller's current device.
#'
#' @family plot
#' @seealso \code{\link{PlotRank}()}, \code{\link{PlotButterfly}()}
#'
#' @examples
#' if (requireNamespace("circlize", quietly = TRUE)) {
#'   set.seed(42)
#'   example_data <- data.frame(
#'     group = rep(c("Group A", "Group B"), each = 5),
#'     name = rep(paste0("Feature", 1:5), 2),
#'     value = runif(10)
#'   )
#'   PlotCircleLollipop(example_data, top_n = 3, show_labels = FALSE,
#'                      show_yaxis = FALSE)
#'
#'   # Factor labels are interpreted as scores, regardless of level order.
#'   example_data$value <- factor(format(example_data$value, digits = 3))
#'   PlotCircleLollipop(example_data, top_n = 3, value_scale = "group",
#'                      show_labels = FALSE, show_yaxis = FALSE)
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
  if (!is.null(filename)) .check_plot_filename(filename)
  label_side  <- match.arg(label_side)
  value_scale <- match.arg(value_scale)
  for (arg in c("show_links", "show_labels", "show_yaxis")) {
    value <- get(arg)
    if (!is.logical(value) || !is.null(dim(value)) || length(value) != 1L || is.na(value))
      stop("'", arg, "' must be TRUE or FALSE.", call. = FALSE)
  }

  # ---- Check dependencies ----
  for (arg in c("track_height", "gap_after", "gap_between", "start_degree", "point_cex",
                "line_lwd", "sector_cex", if (show_links) c("link_lwd", "link_h"),
                if (show_labels) c("label_cex", "label_height"))) {
    value <- get(arg)
    if (!is.numeric(value) || is.object(value) || !is.null(dim(value)) || length(value) != 1L ||
        !is.finite(value) || (arg != "start_degree" && value < 0) ||
        (arg == "track_height" && (value <= 0 || value >= 1)) || (arg == "link_h" && value > 1))
      stop("'", arg, "' must be a finite scalar in its allowed range.", call. = FALSE)
  }
  for (pkg in c("circlize", "dplyr")) {
    if (!requireNamespace(pkg, quietly = TRUE))
      stop(sprintf("Package '%s' is required.", pkg), call. = FALSE)
  }

  # ---- Validate columns ----
  for (arg in c("group_col", "name_col", "value_col", if (!is.null(color_col)) "color_col")) {
    value <- get(arg)
    if (!is.character(value) || !is.null(dim(value)) || length(value) != 1L ||
        is.na(value) || !nzchar(value))
      stop("'", arg, "' must be one non-missing column name.", call. = FALSE)
  }
  if (!is.null(group_levels) && (!is.null(dim(group_levels)) ||
      (!is.atomic(group_levels) && !inherits(group_levels, "POSIXlt"))))
    stop("'group_levels' must be a one-dimensional vector.", call. = FALSE)
  .register_integer64(group_levels)
  if (!is.data.frame(data)) stop("'data' must be a data.frame.", call. = FALSE)
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data)))
    stop("'data' must have unique, non-missing, non-empty column names.", call. = FALSE)
  for (col in c(group_col, name_col, value_col)) {
    if (!col %in% colnames(data))
      stop(sprintf("Column '%s' not found in data.", col), call. = FALSE)
    .register_integer64(data[[col]])
  }

  # ---- Parse scores before ranking or scaling ----
  parse_scores <- function(values) {
    if (is.complex(values) || is.list(values) || is.expression(values) ||
        !is.null(dim(values))) {
      stop(sprintf("Column '%s' must contain one-dimensional real numeric scores.", value_col),
           call. = FALSE)
    }
    if (inherits(values, "haven_labelled_spss")) values <- .scatter_axis_values(values)
    if (is.factor(values)) values <- as.character(values)
    numeric_values <- suppressWarnings(as.numeric(values))
    if (any(!is.na(values) & is.na(numeric_values))) {
      stop(sprintf("Column '%s' must contain numeric scores or missing values.", value_col),
           call. = FALSE)
    }
    if (any(is.infinite(numeric_values))) {
      stop(sprintf("Column '%s' must contain finite scores or missing values.", value_col),
           call. = FALSE)
    }
    numeric_values
  }
  numeric_values <- parse_scores(data[[value_col]])
  integer64_scores <- inherits(data[[value_col]], "integer64")
  if (nrow(data) > 0L && !any(is.finite(numeric_values))) {
    stop(sprintf("Column '%s' must contain at least one finite score.", value_col),
         call. = FALSE)
  }

  # ---- Preserve group identity when character labels coincide ----
  group_input <- data[[group_col]]
  duration_groups <- inherits(group_input, "Duration")
  group_values <- vctrs::vec_unique(group_input)
  group_keys <- if (duration_groups) vctrs::vec_proxy_equal(group_values) else group_values
  if (duration_groups) group_input <- vctrs::vec_proxy_equal(group_input)
  group_ids <- vctrs::vec_match(group_input, group_keys)
  group_labels <- as.character(group_values)
  collision <- duplicated(group_labels) | duplicated(group_labels, fromLast = TRUE)
  if (any(collision)) {
    group_labels[collision] <- format(group_values[collision], digits = 17, trim = TRUE)
    group_labels <- make.unique(group_labels)
  }

  # ---- Keep original data for group-level scaling (before top_n) ----
  data_orig <- data
  selected <- seq_len(nrow(data))

  # ---- top_n: keep top-N rows per group by value (descending) ----
  if (!is.null(top_n)) {
    if (length(top_n) != 1L || !is.numeric(top_n) || is.object(top_n) ||
        !is.null(dim(top_n)) || is.complex(top_n) ||
        !is.finite(top_n) || top_n < 0 || top_n > .Machine$integer.max ||
        top_n != floor(top_n)) {
      stop("'top_n' must be NULL or a single non-negative integer no greater than .Machine$integer.max.",
           call. = FALSE)
    }
    top_n <- as.integer(top_n)
    ranking <- tibble::tibble(
      group = group_input,
      score = if (integer64_scores) data[[value_col]] else numeric_values,
      row_id = selected
    )
    selected <- ranking |>
      dplyr::group_by(.data[["group"]]) |>
      dplyr::slice_max(order_by = .data[["score"]], n = top_n, with_ties = FALSE) |>
      dplyr::pull("row_id")
    columns <- unique(c(group_col, name_col, value_col, intersect(color_col, names(data))))
    data <- as.data.frame(data)[selected, columns, drop = FALSE]
  }

  # ---- Normalise to standard column names ----
  df <- data.frame(
    group = group_labels[group_ids[selected]],
    name  = as.character(.butterfly_category_labels(data[[name_col]])),
    value = numeric_values[selected],
    stringsAsFactors = FALSE
  )
  if (!nrow(df)) stop("No observations to plot.", call. = FALSE)

  # ---- Group order ----
  if (!is.null(group_levels)) {
    if (any(collision) && !is.character(group_levels) &&
        identical(class(group_levels), class(group_values))) {
      level_keys <- if (duration_groups) vctrs::vec_proxy_equal(group_levels) else group_levels
      ids <- vctrs::vec_match(level_keys, group_keys)
      group_levels <- as.character(group_levels)
      group_levels[!is.na(ids)] <- group_labels[ids[!is.na(ids)]]
    }
    df$group <- factor(df$group, levels = group_levels)
  } else if (is.factor(data[[group_col]])) {
    df$group <- factor(df$group, levels = levels(data[[group_col]]))
  } else {
    df$group <- factor(df$group, levels = group_labels[!is.na(group_labels)])
  }
  if (anyNA(df$group))
    stop("Group labels must not be missing or excluded by group_levels.", call. = FALSE)
  df$group <- droplevels(df$group)
  sector_labels <- levels(df$group)
  sector_factors <- df$group
  if ("" %in% sector_labels) {
    keys <- sector_labels
    keys[!nzchar(keys)] <- utils::tail(make.unique(c(keys, ".circle_group")), 1L)
    levels(sector_factors) <- keys
  }
  sector_keys <- levels(sector_factors)
  total_gap <- (nlevels(df$group) - 1L) * gap_between + gap_after
  if (!is.finite(total_gap) || total_gap >= 360)
    stop("'gap_after' and 'gap_between' must leave a positive angular span for sectors.", call. = FALSE)

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
  scale_values <- function(x, mn, mx) {
    if (anyNA(c(mn, mx))) return(rep(NA_real_, length(x)))
    if (mx == mn) return(x - mn)
    span <- mx - mn
    if (!is.finite(span) && all(is.finite(c(mn, mx)))) {
      magnitude <- max(abs(c(mn, mx)))
      return((x / magnitude - mn / magnitude) / (mx / magnitude - mn / magnitude))
    }
    (x - mn) / span
  }
  score_extreme <- function(x, fun) {
    if (all(is.na(x))) NA_real_ else fun(x, na.rm = TRUE)
  }
  scale_integer64 <- function(x, reference = x) {
    if (all(is.na(reference))) return(rep(NA_real_, length(x)))
    lo <- min(reference, na.rm = TRUE)
    hi <- max(reference, na.rm = TRUE)
    if (hi == lo) return(as.numeric(x - lo))
    maximum <- bit64::as.integer64("9223372036854775807")
    if (lo >= 0 || hi <= 0 || hi <= maximum + lo) {
      shifted <- x - lo
      span <- hi - lo
      return(suppressWarnings(as.numeric(shifted) / as.numeric(span)))
    }
    # A range wider than integer64 is scaled in halves. Subtract negative
    # endpoints before conversion to retain small differences near the minimum.
    negative <- !is.na(x) & x < 0
    positive <- !is.na(x) & !negative
    shifted <- x[negative] - lo
    out <- rep(NA_real_, length(x))
    out[negative] <- suppressWarnings(as.numeric(shifted)) / 2
    out[positive] <- suppressWarnings(as.numeric(x[positive])) / 2 -
      suppressWarnings(as.numeric(lo)) / 2
    out / (suppressWarnings(as.numeric(hi)) / 2 - suppressWarnings(as.numeric(lo)) / 2)
  }
  if (integer64_scores && value_scale %in% c("group", "top_n")) {
    scores <- data[[value_col]]
    original_rows <- if (value_scale == "group") {
      split(seq_len(nrow(data_orig)), group_labels[group_ids])
    }
    indices <- split(seq_len(nrow(df)), df$group)
    for (i in seq_along(indices)) {
      idx <- indices[[i]]
      reference <- if (value_scale == "group") {
        data_orig[[value_col]][original_rows[[match(names(indices)[i], names(original_rows))]]]
      } else scores[idx]
      df$value[idx] <- scale_integer64(scores[idx], reference)
    }
    if (value_scale == "top_n") df <- as.data.frame(df)
  } else if (value_scale == "group") {
    # Scale using the FULL group range from original data (before top_n)
    orig_grp <- group_labels[group_ids]
    orig_val <- numeric_values
    grp_min  <- tapply(orig_val, orig_grp, score_extreme, fun = min)
    grp_max  <- tapply(orig_val, orig_grp, score_extreme, fun = max)
    scaled <- numeric(nrow(df))
    indices <- split(seq_len(nrow(df)), df$group)
    bounds <- match(names(indices), names(grp_min))
    for (i in seq_along(indices)) {
      idx <- indices[[i]]
      scaled[idx] <- scale_values(df$value[idx], grp_min[[bounds[i]]], grp_max[[bounds[i]]])
    }
    df$value <- scaled

  } else if (value_scale == "top_n") {
    # Scale using only the displayed (post-top_n) values within each group
    df <- df |>
      dplyr::group_by(group) |>
      dplyr::mutate(value = {
        mn <- score_extreme(value, min)
        mx <- score_extreme(value, max)
        scale_values(value, mn, mx)
      }) |>
      dplyr::ungroup() |>
      as.data.frame()
  }

  # ---- Normalise values to [0, 1] if still outside range ----
  val_range <- range(df$value, na.rm = TRUE)
  if (integer64_scores && value_scale == "none" &&
      any(data[[value_col]] < 0 | data[[value_col]] > 1, na.rm = TRUE)) {
    df$y_pos <- pmax(0.05, scale_integer64(data[[value_col]]))
  } else if (val_range[1] < 0 || val_range[2] > 1) {
    df$y_pos <- if (is.finite(val_range[1]) && val_range[1] == val_range[2]) {
      df$value - val_range[1]
    } else {
      scale_values(df$value, val_range[1], val_range[2])
    }
    df$y_pos <- pmax(0.05, df$y_pos)
  } else {
    df$y_pos <- df$value
  }

  # ---- Shared features for automatic colours and inner arcs ----
  custom_colors <- !is.null(color_col) && color_col %in% colnames(data)
  if (!custom_colors || show_links) {
    common_names <- df |>
      dplyr::filter(!is.na(name)) |>
      dplyr::group_by(name) |>
      dplyr::summarise(n_groups = dplyr::n_distinct(group), .groups = "drop") |>
      dplyr::filter(n_groups > 1) |>
      dplyr::pull(name)
    shared <- df$name %in% common_names
  }

  if (custom_colors) {
    df$color <- as.character(data[[color_col]])
  } else {
    df$color <- ifelse(shared,
      if (is.factor(common_color)) as.character(common_color) else common_color,
      if (is.factor(unique_color)) as.character(unique_color) else unique_color)
  }
  if (show_links) common_genes <- df[shared, , drop = FALSE]

  # ---- Label data for circos.genomicLabels ----
  label_data <- if (show_labels) data.frame(
    chr   = as.character(sector_factors),
    start = df$x_pos - 0.001,
    end   = df$x_pos + 0.001,
    label = df$name,
    color = df$color,
    stringsAsFactors = FALSE
  )

  # ---- Core drawing function ----
  .draw <- function() {
    old_mar <- graphics::par("mar")
    on.exit({
      circlize::circos.clear()
      graphics::par(mar = old_mar)
    }, add = TRUE)
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

    circlize::circos.initialize(factors = sector_factors, xlim = c(0, 1))

    # When values are scaled to [0,1], extend ylim slightly so top dots are
    # not clipped at the track boundary
    ylim_max  <- if (value_scale != "none") 1.02 else 1
    grp_levels <- sector_keys

    # ---- Track builder: sector label ring ----
    .draw_sector_track <- function() {
      circlize::circos.track(
        factors      = sector_factors,
        ylim         = c(0, 1),
        track.height = 0.08,
        bg.col       = sector_bg,
        panel.fun = function(x, y) {
          circlize::circos.text(
            circlize::CELL_META$xcenter,
            circlize::CELL_META$ylim[2] - 0.7,
            sector_labels[match(circlize::CELL_META$sector.index, sector_keys)],
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
        factors      = sector_factors,
        ylim         = c(0, ylim_max),
        track.height = track_height,
        panel.fun = function(x, y) {
          sector_id <- match(circlize::CELL_META$sector.index, sector_keys)
          sector_data <- df[as.integer(df$group) == sector_id, ]

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
      feature_rows <- split(seq_len(nrow(common_genes)),
                            match(common_genes$name, unique(common_genes$name)))
      for (rows in feature_rows) {
        gd <- common_genes[rows, , drop = FALSE]
        if (nrow(gd) > 1L) {
          sectors <- sector_keys[as.integer(gd$group)]
          for (i in seq_len(nrow(gd) - 1L)) {
            later <- seq.int(i + 1L, nrow(gd))
            for (j in later[sectors[later] != sectors[i]]) {
              circlize::circos.link(
                sectors[i], gd$x_pos[i],
                sectors[j], gd$x_pos[j],
                col = link_color, lwd = link_lwd, h = link_h
              )
            }
          }
        }
      }
    }

  }

  # ---- Save or draw ----
  if (!is.null(filename)) {
    # measured before writing, which creates the file
    existed <- file.exists(filename)
    ext <- tolower(tools::file_ext(filename))
    previous_device <- grDevices::dev.cur()
    if (ext == "pdf") {
      grDevices::pdf(filename, width = width, height = height)
    } else {
      grDevices::png(filename, width = width, height = height,
                     units = "in", res = dpi)
    }
    owned_device <- grDevices::dev.cur()
    on.exit({
      if (owned_device %in% grDevices::dev.list()) grDevices::dev.off(owned_device)
      if (previous_device %in% grDevices::dev.list()) grDevices::dev.set(previous_device)
    }, add = TRUE)
    .draw()
    grDevices::dev.off(owned_device)
    .cat_saved("PlotCircleLollipop: the plot has been saved to", filename,
               sprintf("%sx%s in", format(width), format(height)), existed,
               toupper(tools::file_ext(filename)))
  } else {
    .draw()
  }

  invisible(NULL)
}
