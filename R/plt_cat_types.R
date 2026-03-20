# Internal plot-type functions for CatPlot
# Each function renders one plot_type and returns a ggplot (or recordPlot for chord).
# Standard plotdata columns: "stat_var", "group_var", "value"
# When group.by is NULL, group_var == "all" (character, not factor).

#' Determine x-axis variable based on grouping
#'
#' When group.by is NULL, .prepare_cat_data sets group_var as character "all".
#' When group.by is provided, group_var is a factor. We use this type difference
#' to safely distinguish the two cases (avoids collision if a real level is "all").
#' @noRd
.cat_x_var <- function(plotdata) {
  if (is.character(plotdata[["group_var"]])) "stat_var" else "group_var"
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
    group_levels <- levels(plotdata[["group_var"]])
    group_levels <- group_levels[group_levels != "" & !is.na(group_levels)]
    if (length(group_levels) > 1) {
      if (position == "stack") {
        y_total <- stats::aggregate(plotdata[["value"]],
          by = list(plotdata[["group_var"]]), FUN = sum, na.rm = TRUE)
      } else {
        y_total <- stats::aggregate(plotdata[["value"]],
          by = list(plotdata[["group_var"]]), FUN = max, na.rm = TRUE)
      }
      y_outer <- max(y_total[[2]], na.rm = TRUE) * 1.15
      npt <- 40
      path_df <- do.call(rbind, lapply(seq_along(group_levels), function(idx) {
        x_idx <- which(levels(plotdata[["group_var"]]) == group_levels[idx])
        data.frame(
          x = seq(x_idx - 0.46, x_idx + 0.46, length.out = npt),
          y = y_outer, label = group_levels[idx], group = idx
        )
      }))
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
  x_var <- .cat_x_var(plotdata)
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }

  # Add padding row for donut hole
  pad <- plotdata[1, , drop = FALSE]
  pad[[x_var]] <- "   "
  pad[["value"]] <- NA
  pad[["stat_var"]] <- NA
  plotdata[[x_var]] <- factor(
    plotdata[[x_var]],
    levels = c("   ", levels(plotdata[[x_var]]))
  )
  plotdata <- rbind(pad, plotdata)

  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(width = 0.8, color = "black", alpha = alpha,
                      position = pos) +
    ggplot2::scale_fill_manual(values = cols, drop = !keep_empty,
                               na.value = "transparent") +
    ggplot2::coord_polar(theta = "y")
}

# ---------- 4. Pie ----------
#' @noRd
.plt_cat_pie <- function(plotdata, cols, alpha = 0.8, ...) {
  x_var <- .cat_x_var(plotdata)
  pos <- ggplot2::position_stack(vjust = 0.5)
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[[x_var]], y = .data[["value"]], fill = .data[["stat_var"]]
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
  x_levels <- levels(factor(plotdata[[x_var]]))
  plotdata[["x_num"]] <- as.numeric(factor(plotdata[[x_var]], levels = x_levels))

  # Area background: double rows and offset for stepped appearance
  dat_area <- plotdata[rep(seq_len(nrow(plotdata)), each = 2), , drop = FALSE]
  dat_area[["x_num"]] <- rep(plotdata[["x_num"]], each = 2)
  odd <- seq(1, nrow(dat_area), 2)
  even <- seq(2, nrow(dat_area), 2)
  dat_area[["x_num"]][odd]  <- dat_area[["x_num"]][odd] - 0.3
  dat_area[["x_num"]][even] <- dat_area[["x_num"]][even] + 0.3

  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["x_num"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_area(
      data = dat_area,
      ggplot2::aes(x = .data[["x_num"]], y = .data[["value"]],
                   fill = .data[["stat_var"]]),
      alpha = alpha * 0.5, color = "grey50", position = pos
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
  group_levels <- levels(factor(plotdata[[x_var]]))
  plotdata[["x_num"]] <- as.numeric(factor(plotdata[[x_var]], levels = group_levels))

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
      data[[s]] <- factor(data[[s]])
    }
  }
  dat_long <- ggsankey::make_long(data, dplyr::all_of(stat.by))
  dat_long[["node"]] <- factor(dat_long[["node"]], levels = rev(names(cols)))

  ggplot2::ggplot(dat_long, ggplot2::aes(
    x = .data[["x"]], next_x = .data[["next_x"]],
    node = .data[["node"]], next_node = .data[["next_node"]],
    fill = .data[["node"]]
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
  if (length(stat.by) > 2) {
    cli::cli_warn("Chord uses only the first 2 elements of {.arg stat.by}.")
  }
  M <- table(data[[stat.by[1]]], data[[stat.by[2]]], useNA = "ifany")
  m <- matrix(M, ncol = ncol(M), dimnames = dimnames(M))
  colnames(m)[is.na(colnames(m))] <- "NA"
  rownames(m)[is.na(rownames(m))] <- "NA"

  all_sectors <- unique(c(rownames(m), colnames(m)))
  n_sectors <- length(all_sectors)
  sector_cols <- as.character(rep_len(cols, n_sectors))
  names(sector_cols) <- all_sectors

  # Note: chord returns recordPlot (base graphics), not ggplot.
  # Cannot be used with ggsave(); use png()/pdf() + replayPlot() instead.
  circlize::chordDiagram(
    m, grid.col = sector_cols, transparency = 1 - alpha,
    link.lwd = 1, link.lty = 1, link.border = 1
  )
  p <- grDevices::recordPlot()
  circlize::circos.clear()
  p
}

# ---------- 10. Venn ----------
#' @noRd
.plt_cat_venn <- function(data, stat.by, cols, stat_level = NULL, ...) {
  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggVennDiagram} is required. Install with: {.code install.packages('ggVennDiagram')}")
  }
  set_list <- .build_set_list(data, stat.by, stat_level)

  fill_high <- if (length(cols) > 0) cols[1] else "steelblue"

  p <- ggVennDiagram::ggVennDiagram(set_list) +
    ggplot2::scale_fill_gradient(low = "white", high = fill_high) +
    ggplot2::theme(
      plot.background = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank()
    )
  p
}

# ---------- 11. UpSet (ggupset) ----------
#' @noRd
.plt_cat_upset <- function(data, stat.by, cols, stat_level = NULL,
                           label.fg = "black", label.size = 3.5,
                           label.bg = "white", label.bg.r = 0.1, ...) {
  if (!requireNamespace("ggupset", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggupset} is required. Install with: {.code install.packages('ggupset')}")
  }

  resolved <- .resolve_stat_level(data, stat.by, stat_level)

  # Build boolean matrix and compute intersections (vectorized)
  bool_mat <- vapply(stat.by, function(s) {
    as.character(data[[s]]) %in% resolved[[s]]
  }, logical(nrow(data)))

  data[["intersection"]] <- apply(bool_mat, 1, function(row) {
    stat.by[row]
  }, simplify = FALSE)

  data <- data[vapply(data[["intersection"]], length, integer(1)) > 0, ,
               drop = FALSE]

  if (nrow(data) == 0) {
    cli::cli_abort("No rows match {.arg stat_level}. Cannot create UpSet plot.")
  }

  fill_low  <- if (length(cols) > 0) cols[1] else "steelblue"
  fill_high <- if (length(cols) > 1) cols[2] else "darkblue"

  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data[["intersection"]])) +
    ggplot2::geom_bar(
      ggplot2::aes(fill = ggplot2::after_stat(.data[["count"]])),
      color = "black", width = 0.5, show.legend = FALSE
    ) +
    ggrepel::geom_text_repel(
      ggplot2::aes(label = ggplot2::after_stat(.data[["count"]])),
      stat = "count",
      colour = label.fg, size = label.size,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      force = 0, min.segment.length = 0
    ) +
    ggplot2::labs(y = "Intersection size") +
    ggupset::scale_x_upset(sets = stat.by, n_intersections = 20) +
    ggplot2::scale_fill_gradient(low = fill_low, high = fill_high) +
    theme_my() +
    ggupset::theme_combmatrix(
      combmatrix.label.text = ggplot2::element_text(size = 12, color = "black"),
      combmatrix.label.extra_spacing = 6
    )

  p
}
