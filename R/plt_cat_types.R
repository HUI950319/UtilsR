# =============================================================================
# plt_cat_types.R -- Per-type renderers behind plt_cat()
# =============================================================================
#
# Architecture (1 layer). Each renderer returns a ggplot, except
# .plt_cat_chord which returns a recorded base plot.
#
#   L3  standard types -- take the plotdata frame built by
#       .prepare_cat_data(), with the columns stat_var / group_var / value
#         .plt_cat_bar    .plt_cat_rose   .plt_cat_ring   .plt_cat_pie
#         .plt_cat_trend  .plt_cat_area   .plt_cat_dot
#               +-- .cat_x_var()   choose the x aesthetic from group_var's
#                                  type (character "all" = no group.by,
#                                  factor = real grouping)
#
#   L3  set types -- take the set list built by .build_set_list()
#         .plt_cat_sankey  .plt_cat_chord  .plt_cat_venn  .plt_cat_upset
# =============================================================================

#' Determine x-axis variable based on grouping
#'
#' When group.by is NULL, .prepare_cat_data sets group_var as character "all".
#' When group.by is provided, group_var is a factor. We use this type difference
#' to safely distinguish the two cases (avoids collision if a real level is "all").
#' @noRd
.cat_x_var <- function(plotdata) {
  if (is.character(plotdata[["group_var"]])) "stat_var" else "group_var"
}

# Drop unused ordinary axis levels without converting each observation to text.
.cat_axis_factor <- function(value) {
  if ((identical(class(value), "factor") || identical(class(value), c("ordered", "factor"))) &&
      !anyNA(levels(value))) {
    tally <- .factor_tally(value)
    observed <- tally$codes
    labels <- levels(value)
    if (length(observed) == length(labels)) {
      if (all(names(attributes(value)) %in% c("levels", "class", "names"))) return(value)
      codes <- tally$row_codes
    } else {
      if (length(labels) <= length(value)) {
        positions <- rep.int(NA_integer_, length(labels))
        positions[observed] <- seq_along(observed)
        codes <- positions[tally$row_codes]
      } else if (length(observed) == 1L && tally$counts[[1L]] == length(value)) {
        codes <- rep.int(1L, length(value))
      } else {
        codes <- match(tally$row_codes, observed)
      }
      labels <- labels[observed]
    }
    names(codes) <- names(value)
    return(structure(codes, levels = labels, class = class(value)))
  }
  factor(value)
}

# ---------- 1. Bar ----------
#' @noRd
.plt_cat_bar <- function(plotdata, cols, alpha = 0.8, position = "stack",
                         keep_empty = FALSE, ...) {
  x_var <- .cat_x_var(plotdata)
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(
      width = 0.8, color = "black", alpha = alpha, position = pos
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = !keep_empty) +
    ggplot2::scale_x_discrete(drop = !keep_empty)
}

# ---------- 2. Rose ----------
#' @noRd
.plt_cat_rose <- function(plotdata, cols, alpha = 0.8, position = "stack",
                          keep_empty = FALSE, ...) {
  x_var <- .cat_x_var(plotdata)
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }
  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(
      width = 0.8, color = "black", alpha = alpha, position = pos
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = !keep_empty) +
    ggplot2::scale_x_discrete(drop = !keep_empty) +
    ggplot2::coord_polar(theta = "x")

  if (requireNamespace("geomtextpath", quietly = TRUE) && x_var == "group_var") {
    group_labels <- levels(plotdata[["group_var"]])
    positions <- which(!is.na(group_labels) & group_labels != "")
    group_levels <- group_labels[positions]
    if (length(group_levels) > 1) {
      values <- plotdata[["value"]]
      groups <- plotdata[["group_var"]]
      if (position != "stack" && !anyNA(groups) && !anyNA(group_labels) && length(values)) {
        radius <- max(values, na.rm = TRUE)
      } else if (position == "stack" && is.integer(values) && !is.object(values) &&
                 is.factor(groups) && !anyNA(groups) && !anyNA(group_labels)) {
        radius <- max(rowsum(as.double(values), groups, reorder = FALSE, na.rm = TRUE))
      } else {
        summary <- stats::aggregate(values, by = list(groups),
          FUN = if (position == "stack") sum else max, na.rm = TRUE)
        radius <- max(summary[[2L]], na.rm = TRUE)
      }
      y_outer <- radius * 1.15
      npt <- 40
      arcs <- vapply(positions, function(x) seq(x - 0.46, x + 0.46, length.out = npt),
                     numeric(npt))
      path_df <- data.frame(
        x = as.vector(arcs), y = y_outer,
        label = rep(group_levels, each = npt), group = rep(seq_along(positions), each = npt)
      )
      p <- p + geomtextpath::geom_textpath(
        ggplot2::aes(x = .data[["x"]], y = .data[["y"]],
                     label = .data[["label"]], group = .data[["group"]]),
        data = path_df, inherit.aes = FALSE,
        size = 3.5, linewidth = 0, upright = TRUE
      )
    }
  }
  p
}

# ---------- 3. Ring (donut) ----------
#' @noRd
.plt_cat_ring <- function(plotdata, cols, alpha = 0.8, position = "stack",
                         keep_empty = FALSE, ...) {
  has_group <- !is.character(plotdata[["group_var"]])
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }

  plotdata[["radius"]] <- if (has_group) as.numeric(plotdata[["group_var"]]) + 1 else 2

  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["radius"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(width = 0.8, color = "black", alpha = alpha,
                      position = pos) +
    ggplot2::scale_fill_manual(values = cols, drop = !keep_empty,
                               na.value = "transparent") +
    ggplot2::scale_x_continuous(limits = c(0.5, max(plotdata[["radius"]]) + 0.5),
                               breaks = NULL, expand = c(0, 0)) +
    ggplot2::coord_polar(theta = "y")
}

# ---------- 4. Pie ----------
#' @noRd
.plt_cat_pie <- function(plotdata, cols, alpha = 0.8, ...) {
  has_group <- !is.character(plotdata[["group_var"]])
  pos <- ggplot2::position_stack(vjust = 0.5)
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = if (has_group) .data[["group_var"]] else "",
    y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(width = 0.8, color = "black", alpha = alpha,
                      position = pos) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::coord_polar(theta = "y")
}

# ---------- 5. Trend (stepped area + bar) ----------
#' @noRd
.plt_cat_trend <- function(plotdata, cols, alpha = 0.8, position = "stack",
                           keep_empty = FALSE, ...) {
  x_var <- .cat_x_var(plotdata)
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }

  # Convert x to numeric for consistent geom_area + geom_col rendering
  x_factor <- .cat_axis_factor(plotdata[[x_var]])
  x_levels <- levels(x_factor)
  plotdata[["x_num"]] <- as.numeric(x_factor)

  # Area background: double rows and offset for stepped appearance
  dat_area <- plotdata[rep(seq_len(nrow(plotdata)), each = 2), , drop = FALSE]
  dat_area[["x_num"]] <- dat_area[["x_num"]] + c(-0.3, 0.3)

  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["x_num"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_area(
      data = dat_area,
      ggplot2::aes(x = .data[["x_num"]], y = .data[["value"]],
                   fill = .data[["stat_var"]]),
      alpha = alpha * 0.5, color = "grey50",
      position = if (position == "stack") pos else "identity"
    ) +
    ggplot2::geom_col(
      width = 0.6, color = "black", alpha = alpha, position = pos
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = !keep_empty) +
    ggplot2::scale_x_continuous(
      breaks = seq_along(x_levels),
      labels = x_levels,
      expand = ggplot2::expansion(mult = c(0.05, 0.05))
    )
}

# ---------- 6. Area ----------
#' @noRd
.plt_cat_area <- function(plotdata, cols, alpha = 0.8, position = "stack",
                          keep_empty = FALSE, ...) {
  x_var <- .cat_x_var(plotdata)
  group_factor <- .cat_axis_factor(plotdata[[x_var]])
  group_levels <- levels(group_factor)
  if (x_var != "group_var" || length(group_levels) < 2L) {
    cli::cli_abort("{.arg group.by} must provide at least two displayed levels for {.code type = \"area\"}.")
  }
  plotdata[["x_num"]] <- as.numeric(group_factor)

  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_identity()
  }

  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["x_num"]], y = .data[["value"]],
    fill = .data[["stat_var"]], group = .data[["stat_var"]]
  ))

  if (position == "stack") {
    p <- p + ggplot2::geom_area(color = "black", alpha = alpha, position = pos)
  } else {
    p <- p + ggplot2::geom_area(color = "black", alpha = alpha * 0.6,
                                 position = pos)
  }

  p + ggplot2::scale_fill_manual(values = cols, drop = !keep_empty) +
    ggplot2::scale_x_continuous(
      breaks = seq_along(group_levels),
      labels = group_levels,
      expand = ggplot2::expansion(mult = c(0.02, 0.02))
    )
}

# ---------- 7. Dot ----------
#' @noRd
.plt_cat_dot <- function(plotdata, cols, alpha = 0.8, keep_empty = FALSE, ...) {
  x_var <- .cat_x_var(plotdata)
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[["stat_var"]]
  )) +
    ggplot2::geom_point(
      ggplot2::aes(size = .data[["value"]], fill = .data[["stat_var"]]),
      shape = 21, color = "black", alpha = alpha
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = !keep_empty) +
    ggplot2::scale_x_discrete(drop = !keep_empty) +
    ggplot2::scale_size_area(max_size = 12) +
    ggplot2::guides(size = ggplot2::guide_legend(
      override.aes = list(fill = "grey30")
    ))
}

# ---------- 8. Sankey ----------
#' @noRd
.plt_cat_sankey <- function(data, stat.by, cols, alpha = 0.8, ...) {
  if (!requireNamespace("ggsankey", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggsankey} is required. Install with: {.code devtools::install_github('davidsjoberg/ggsankey')}")
  }
  # Reconstruct plain factors (strip subclasses that cause tidyr issues)
  for (s in stat.by) {
    if (is.factor(data[[s]])) {
      data[[s]] <- .cat_axis_factor(data[[s]])
    }
  }
  # Keep backend-reserved names separate from the displayed stage names.
  data <- data[, stat.by, drop = FALSE]
  stage_names <- paste0(".stage", seq_along(stat.by))
  names(data) <- stage_names
  data <- dplyr::count(data, dplyr::across(dplyr::all_of(stage_names)), name = ".count")
  dat_long <- .sankey_path_rows(data, stage_names)
  dat_long[["value"]] <- rep(data[[".count"]], each = length(stage_names))
  for (axis in c("x", "next_x")) {
    dat_long[[axis]] <- structure(as.integer(dat_long[[axis]]), levels = stat.by, class = "factor")
  }
  dat_long[["node"]] <- factor(dat_long[["node"]], levels = rev(names(cols)))

  ggplot2::ggplot(dat_long, ggplot2::aes(
    x = .data[["x"]], next_x = .data[["next_x"]],
    node = .data[["node"]], next_node = .data[["next_node"]],
    fill = .data[["node"]], value = .data[["value"]]
  )) +
    ggsankey::geom_sankey(
      color = "black", flow.alpha = alpha, show.legend = FALSE, na.rm = FALSE
    ) +
    ggsankey::geom_sankey_label(
      ggplot2::aes(label = .data[["node"]]),
      size = 3, color = "black", fill = "white"
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_x_discrete(expand = c(0, 0.2)) +
    ggplot2::theme_void() +
    ggplot2::theme(axis.text.x = ggplot2::element_text())
}

# ---------- 9. Chord ----------
#' @noRd
.plt_cat_chord <- function(data, stat.by, cols, alpha = 0.8, ...) {
  if (!requireNamespace("circlize", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg circlize} is required. Install with: {.code install.packages('circlize')}")
  }
  from <- data[[stat.by[1]]]
  to <- data[[stat.by[2]]]
  ordinary <- function(x) {
    (identical(class(x), "factor") || identical(class(x), c("ordered", "factor"))) &&
      !anyNA(levels(x)) && !anyNA(x)
  }
  direct <- ordinary(from) && ordinary(to)
  from <- if (direct) .cat_axis_factor(from) else droplevels(from)
  to <- if (direct) .cat_axis_factor(to) else droplevels(to)
  n_from <- nlevels(from)
  n_to <- nlevels(to)
  n_cells <- as.double(n_from) * n_to
  if (n_cells >= 2^31) {
    cli::cli_abort("A chord frequency table must contain fewer than 2^31 cells. Reduce the number of categories.")
  }
  m <- if (direct) {
    cells <- if (n_from == 1L) as.integer(to) else if (n_to == 1L) as.integer(from) else
      as.integer(from) + (as.integer(to) - 1L) * n_from
    matrix(tabulate(cells, n_cells), nrow = n_from, ncol = n_to,
      dimnames = list(from = levels(from), to = levels(to)))
  } else {
    counts <- table(from, to, useNA = "ifany")
    matrix(counts, ncol = ncol(counts), dimnames = dimnames(counts))
  }
  if (anyNA(colnames(m))) colnames(m)[is.na(colnames(m))] <- "NA"
  if (anyNA(rownames(m))) rownames(m)[is.na(rownames(m))] <- "NA"

  all_sectors <- unique(c(rownames(m), colnames(m)))
  sector_cols <- stats::setNames(cols[match(all_sectors, names(cols))], all_sectors)
  if ("" %in% all_sectors) {
    blank <- " "
    while (blank %in% all_sectors) blank <- paste0(blank, " ")
    rownames(m)[rownames(m) == ""] <- blank
    colnames(m)[colnames(m) == ""] <- blank
    names(sector_cols)[names(sector_cols) == ""] <- blank
  }

  # Note: chord returns recordPlot (base graphics), not ggplot.
  # Cannot be used with ggsave(); use png()/pdf() + replayPlot() instead.
  if (grDevices::dev.cur() == 1L) grDevices::dev.new()
  grDevices::dev.control(displaylist = "enable")
  on.exit(circlize::circos.clear(), add = TRUE)
  circlize::chordDiagram(
    m, grid.col = sector_cols, transparency = 1 - alpha,
    link.lwd = 1, link.lty = 1, link.border = 1
  )
  p <- grDevices::recordPlot()
  p
}

# ---------- 10. Venn ----------
#' @noRd
.plt_cat_venn <- function(data, stat.by, cols, stat_level = NULL, label = FALSE,
                          label.size = 3.5, label.fg = "black", alpha = 0.8,
                          label.bg = "white", label.bg.r = 0.1, ...) {
  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggVennDiagram} is required. Install with: {.code install.packages('ggVennDiagram')}")
  }
  set_list <- .build_set_list(data, stat.by, stat_level)
  value_label <- if (!label) "none" else if (any(lengths(set_list) > 0L)) "both" else "count"

  fill_high <- if (length(cols) > 0) cols[1] else "steelblue"

  p <- ggVennDiagram::ggVennDiagram(set_list, label = value_label,
                                   label_size = label.size, label_color = label.fg) +
    ggplot2::scale_fill_gradient(low = "white", high = fill_high) +
    ggplot2::theme(
      plot.background = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank()
    )
  # The backend constructs fresh region and label layers for each call.
  for (layer in p$layers) {
    if (inherits(layer$geom, "GeomPolygon")) layer$aes_params$alpha <- alpha
    if (inherits(layer$geom, "GeomLabel")) {
      layer$aes_params$fill <- label.bg
      layer$geom_params$label.r <- grid::unit(label.bg.r, "lines")
    }
  }
  p
}

# ---------- 11. UpSet (ggupset) ----------
#' @noRd
.plt_cat_upset <- function(data, stat.by, cols, stat_level = NULL,
                           alpha = 0.8, label = FALSE,
                           label.fg = "black", label.size = 3.5,
                           label.bg = "white", label.bg.r = 0.1,
                           allow_empty = FALSE, ...) {
  if (!requireNamespace("ggupset", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggupset} is required. Install with: {.code install.packages('ggupset')}")
  }

  resolved <- .resolve_stat_level(data, stat.by, stat_level)

  membership <- function(s) .cat_set_members(data[[s]], resolved[[s]])
  if (length(stat.by) <= 31L) {
    sets <- lapply(stat.by, function(s) which(membership(s)))
    codes <- .upset_row_codes(sets, nrow(data))
    groups <- vctrs::vec_group_id(codes)
    bits <- bitwShiftL(1L, seq_along(stat.by) - 1L)
    n_keys <- attr(groups, "n")
    observed <- if (n_keys == length(codes)) codes else if (n_keys == 1L) codes[1L] else
      codes[!duplicated(groups, nmax = n_keys)]
    combinations <- lapply(observed, function(code) stat.by[bitwAnd(code, bits) != 0L])
  } else {
    bool_mat <- vapply(stat.by, membership, logical(nrow(data)))
    dim(bool_mat) <- c(nrow(data), length(stat.by))
    groups <- vctrs::vec_group_id(as.data.frame(bool_mat))
    n_keys <- attr(groups, "n")
    first <- if (n_keys == nrow(data)) seq_len(n_keys) else
      if (n_keys == 1L) 1L else which(!duplicated(groups, nmax = n_keys))
    combinations <- lapply(first, function(i) stat.by[bool_mat[i, ]])
  }

  intersection_col <- utils::tail(make.unique(c(names(data), "intersection")), 1L)
  nonempty <- lengths(combinations) > 0L
  data[[intersection_col]] <- combinations[groups]
  if (!all(nonempty)) data <- data[nonempty[groups], , drop = FALSE]

  if (nrow(data) == 0) {
    if (allow_empty) {
      return(ggplot2::ggplot(data) +
        ggplot2::annotate("text", x = 0, y = 0,
          label = "\u65e0\u5339\u914d\u6210\u5458", size = label.size, colour = label.fg) +
        ggplot2::scale_x_continuous(breaks = NULL) +
        ggplot2::scale_y_continuous(breaks = NULL) +
        theme_my() + ggplot2::theme(panel.border = ggplot2::element_blank()))
    }
    cli::cli_abort("No rows match {.arg stat_level}. Cannot create UpSet plot.")
  }

  n_intersections <- sum(nonempty)
  if (n_intersections > 20L) {
    cli::cli_warn("Only the 20 most frequent of {n_intersections} UpSet intersections are shown; {n_intersections - 20L} are omitted.")
  }

  separator <- "-__-__-_-"
  if (any(grepl(separator, stat.by, fixed = TRUE))) {
    # Use the public merge-list adapter with a separator absent from set names.
    while (any(grepl(separator, stat.by, fixed = TRUE))) separator <- paste0(separator, "_")
    keys <- vapply(combinations[nonempty], function(x) {
      paste(sort(x), collapse = separator)
    }, character(1))
    counts <- tabulate(groups, nbins = length(combinations))[nonempty]
    limits <- keys[utils::head(order(-counts, keys), 20L)]
    x_scale <- list(
      ggupset::scale_x_mergelist(sep = separator, limits = limits),
      ggupset::axis_combmatrix(sep = separator, levels = stat.by)
    )
  } else {
    x_scale <- ggupset::scale_x_upset(sets = stat.by, n_intersections = 20)
  }

  fill_low  <- if (length(cols) > 0) cols[1] else "steelblue"
  fill_high <- if (length(cols) > 1) cols[2] else "darkblue"

  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[intersection_col]])) +
    ggplot2::geom_bar(
      ggplot2::aes(fill = ggplot2::after_stat(.data[["count"]])),
      color = "black", alpha = alpha, width = 0.5, show.legend = FALSE, na.rm = TRUE
    ) +
    (if (label) ggrepel::geom_text_repel(
      ggplot2::aes(label = ggplot2::after_stat(.data[["count"]])),
      stat = "count", na.rm = TRUE,
      colour = label.fg, size = label.size,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      force = 0, min.segment.length = 0
    )) +
    ggplot2::labs(y = "Intersection size") +
    x_scale +
    ggplot2::scale_fill_gradient(low = fill_low, high = fill_high) +
    theme_my() +
    ggupset::theme_combmatrix(
      combmatrix.label.text = ggplot2::element_text(size = 12, color = "black"),
      combmatrix.label.extra_spacing = 6
    )

  p
}
