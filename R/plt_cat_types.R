# Internal plot-type functions for CatPlot
# Each function renders one plot_type and returns a ggplot (or recordPlot for chord).
# Standard plotdata columns: "stat_var", "group_var", "value"

# ---------- 1. Bar ----------
#' @noRd
.plt_cat_bar <- function(plotdata, cols, alpha = 0.8, position = "stack", ...) {
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(
      width = 0.8, color = "black", alpha = alpha, position = pos
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE)
}

# ---------- 2. Rose ----------
#' @noRd
.plt_cat_rose <- function(plotdata, cols, alpha = 0.8, position = "stack", ...) {
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }
  p <- ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(
      width = 0.8, color = "black", alpha = alpha, position = pos
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE) +
    ggplot2::coord_polar(theta = "x")

  # Outer group labels via geomtextpath if available
  if (requireNamespace("geomtextpath", quietly = TRUE)) {
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
.plt_cat_ring <- function(plotdata, cols, alpha = 0.8, ...) {
  pos <- ggplot2::position_stack(vjust = 0.5)
  # Add padding row for donut hole
  pad <- plotdata[1, , drop = FALSE]
  pad[["group_var"]] <- "   "
  pad[["value"]] <- NA
  plotdata[["group_var"]] <- factor(
    plotdata[["group_var"]],
    levels = c("   ", levels(plotdata[["group_var"]]))
  )
  plotdata <- rbind(pad, plotdata)

  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(width = 0.8, color = "black", alpha = alpha, position = pos) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::coord_polar(theta = "y")
}

# ---------- 4. Pie ----------
#' @noRd
.plt_cat_pie <- function(plotdata, cols, alpha = 0.8, ...) {
  pos <- ggplot2::position_stack(vjust = 0.5)
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_col(width = 0.8, color = "black", alpha = alpha, position = pos) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::coord_polar(theta = "y")
}

# ---------- 5. Trend (stepped area + bar) ----------
#' @noRd
.plt_cat_trend <- function(plotdata, cols, alpha = 0.8, position = "stack", ...) {
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "single")
  }
  # Create area data by doubling rows and offsetting x
  dat_area <- plotdata[rep(seq_len(nrow(plotdata)), each = 2), , drop = FALSE]
  dat_area[["group_var"]] <- as.numeric(dat_area[["group_var"]])
  odd <- seq(1, nrow(dat_area), 2)
  even <- seq(2, nrow(dat_area), 2)
  dat_area[["group_var"]][odd]  <- dat_area[["group_var"]][odd] - 0.3
  dat_area[["group_var"]][even] <- dat_area[["group_var"]][even] + 0.3

  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_area(
      data = dat_area,
      ggplot2::aes(x = .data[["group_var"]], y = .data[["value"]],
                   fill = .data[["stat_var"]]),
      alpha = alpha / 2, color = "grey50", position = pos
    ) +
    ggplot2::geom_col(
      width = 0.6, color = "black", alpha = alpha, position = pos
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE)
}

# ---------- 6. Area ----------
#' @noRd
.plt_cat_area <- function(plotdata, cols, alpha = 0.8, position = "stack", ...) {
  if (position == "stack") {
    pos <- ggplot2::position_stack(vjust = 0.5)
  } else {
    pos <- ggplot2::position_dodge2(width = 0.9, preserve = "total")
  }
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["value"]], fill = .data[["stat_var"]]
  )) +
    ggplot2::geom_area(color = "black", alpha = alpha, position = pos) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE)
}

# ---------- 7. Dot ----------
#' @noRd
.plt_cat_dot <- function(plotdata, cols, alpha = 0.8, ...) {
  ggplot2::ggplot(plotdata, ggplot2::aes(
    x = .data[["group_var"]], y = .data[["stat_var"]]
  )) +
    ggplot2::geom_point(
      ggplot2::aes(size = .data[["value"]], fill = .data[["stat_var"]]),
      shape = 21, color = "black", alpha = alpha
    ) +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_size_area(max_size = 12) +
    ggplot2::guides(size = ggplot2::guide_legend(
      override.aes = list(fill = "grey30")
    ))
}

# ---------- 8. Sankey ----------
#' @noRd
.plt_cat_sankey <- function(data, stat.by, cols, alpha = 0.8, ...) {
  if (!requireNamespace("ggsankey", quietly = TRUE)) {
    stop("Package 'ggsankey' is required for sankey plots.")
  }
  # Strip palette class that can cause tidyr issues
  for (s in stat.by) {
    if (is.factor(data[[s]])) {
      class(data[[s]]) <- "factor"
    }
  }
  dat_long <- suppressWarnings(
    ggsankey::make_long(data, dplyr::all_of(stat.by))
  )
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
  stopifnot(length(stat.by) >= 2)
  M <- table(data[[stat.by[1]]], data[[stat.by[2]]], useNA = "ifany")
  m <- matrix(M, ncol = ncol(M), dimnames = dimnames(M))
  colnames(m)[is.na(colnames(m))] <- "NA"
  rownames(m)[is.na(rownames(m))] <- "NA"

  # Build named color vector for all sectors
  all_sectors <- unique(c(rownames(m), colnames(m)))
  n_sectors <- length(all_sectors)
  sector_cols <- as.character(rep_len(cols, n_sectors))
  names(sector_cols) <- all_sectors

  # Open a null device to record the plot
  grDevices::pdf(NULL)
  grDevices::dev.control("enable")
  on.exit({ circlize::circos.clear(); grDevices::dev.off() }, add = TRUE)
  circlize::chordDiagram(
    m, grid.col = sector_cols, transparency = 1 - alpha,
    link.lwd = 1, link.lty = 1, link.border = 1
  )
  grDevices::recordPlot()
}

# ---------- 10. Venn ----------
#' @noRd
.plt_cat_venn <- function(data, stat.by, cols, ...) {
  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    stop("Package 'ggVennDiagram' is required for venn plots.")
  }
  # Build set list: for each stat.by col, rows where value is TRUE/Yes/1
  set_list <- stats::setNames(lapply(stat.by, function(s) {
    vals <- data[[s]]
    keep <- !is.na(vals) & (vals %in% c(TRUE, "TRUE", "Yes", "yes", 1, "1"))
    if (is.null(rownames(data))) {
      which(keep)
    } else {
      rownames(data)[keep]
    }
  }), stat.by)

  p <- ggVennDiagram::ggVennDiagram(set_list) +
    ggplot2::scale_fill_gradient(low = "white", high = "steelblue") +
    ggplot2::theme(
      plot.background = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank()
    )
  p
}

# ---------- 11. UpSet ----------
#' @noRd
.plt_cat_upset <- function(data, stat.by, cols, ...) {
  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    stop("Package 'ggVennDiagram' is required for upset plots.")
  }
  # Build set list (same as venn)
  set_list <- stats::setNames(lapply(stat.by, function(s) {
    vals <- data[[s]]
    keep <- !is.na(vals) & (vals %in% c(TRUE, "TRUE", "Yes", "yes", 1, "1"))
    if (is.null(rownames(data))) {
      which(keep)
    } else {
      rownames(data)[keep]
    }
  }), stat.by)

  p <- tryCatch({
    res <- ggVennDiagram::ggVennDiagram(set_list, force_upset = TRUE)
    # handle aplot return type
    if (inherits(res, "aplot")) {
      res <- patchwork::wrap_plots(res)
    }
    res
  }, error = function(e) {
    warning("UpSet plot failed: ", conditionMessage(e), ". Falling back to Venn.")
    .plt_cat_venn(data = data, stat.by = stat.by, cols = cols, ...)
  })
  p
}
