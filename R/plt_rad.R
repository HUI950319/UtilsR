# ============================================================================
# plt_rad.R -- Radar chart (base R or ggplot)
# ============================================================================

#' Radar Chart
#'
#' Visualise multivariate effect sizes (e.g. from \code{stat_cohen()}) as a
#' radar chart. Supports base R (\pkg{fmsb}) or ggplot (\pkg{ggiraphExtra})
#' output modes.
#'
#' @param res Data frame from \code{stat_cohen()}: first column is
#'   \code{Variable}, remaining columns are numeric values per group.
#' @param ref_group Character, reference group for sorting variables.
#'   Default \code{NULL} uses the first group column.
#' @param palette Colour palette. Character vector or palette name.
#'   Default uses \code{pal_lancet}.
#' @param output Output mode: \code{"base"} (default, uses fmsb) or
#'   \code{"gg"} (uses ggiraphExtra). The gg mode automatically facets
#'   by group.
#' @param facet Logical, facet each group separately (base mode only).
#'   Default \code{FALSE}.
#' @param min_max Numeric vector \code{c(min, max)} for axis limits.
#'   Default \code{NULL} auto-detects from data.
#' @param n_breaks Integer, number of axis breaks. Default 6.
#'
#' @return For \code{output = "gg"}, a ggplot object. For \code{output = "base"},
#'   returns \code{invisible(res)} after printing.
#'
#' @note Requires \pkg{fmsb} for base mode, \pkg{ggiraphExtra} + \pkg{ggh4x}
#'   for gg mode.
#'
#' @examples
#' # Using iris Cohen's d
#' res <- stat_cohen(iris, "Species",
#'                   c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width"))
#'
#' # Base radar chart
#' plt_rad(res)
#'
#' # Base radar, faceted per group
#' plt_rad(res, facet = TRUE)
#'
#' # ggplot radar: overlay (default, all groups on one chart)
#' plt_rad(res, output = "gg")
#'
#' # ggplot radar: faceted (one panel per group)
#' plt_rad(res, output = "gg", facet = TRUE)
#'
#' # ggplot radar with custom palette
#' plt_rad(res, output = "gg", palette = "Set2")
#'
#' # Custom axis range (base mode)
#' plt_rad(res, min_max = c(-1, 1))
#'
#' # Sort by specific group
#' plt_rad(res, ref_group = "versicolor")
#'
#' # Simulated data
#' df <- data.frame(
#'   group = factor(sample(c("A","B","C"), 120, TRUE)),
#'   v1 = rnorm(120), v2 = rnorm(120), v3 = rnorm(120),
#'   v4 = rnorm(120), v5 = rnorm(120)
#' )
#' res2 <- stat_cohen(df, "group", paste0("v", 1:5))
#' plt_rad(res2, output = "gg")                         # overlay
#' plt_rad(res2, output = "gg", facet = TRUE)            # faceted
#' plt_rad(res2, output = "gg", palette = "Paired")
#'
#' @export
#' @family plot formatting
plt_rad <- function(res,
                    ref_group = NULL,
                    palette = NULL,
                    output = c("base", "gg"),
                    facet = FALSE,
                    min_max = NULL,
                    n_breaks = 6) {

  output <- match.arg(output)
  names(res)[1] <- "Variable"
  group_cols <- names(res)[-1]

  if (is.null(ref_group)) ref_group <- group_cols[1]
  if (!ref_group %in% group_cols) {
    cli::cli_abort("{.val {ref_group}} not found. Available: {.val {group_cols}}")
  }

  n_groups <- length(group_cols)

  # Resolve colours
  if (is.null(palette)) {
    cols <- as.character(pal_lancet[seq_len(min(n_groups, length(pal_lancet)))])
  } else if (length(palette) == 1 && palette %in% names(palette_list)) {
    cols <- as.character(pal_get(palette, n = n_groups))
  } else {
    cols <- rep_len(as.character(palette), n_groups)
  }

  # --- ggplot mode (coord_radar approach, adapted from ggiraphExtra) ---
  if (output == "gg") {
    # coord_radar: like coord_polar but with is_linear=TRUE so geom_polygon
    # draws straight lines and auto-closes the shape
    coord_radar <- function(theta = "x", start = 0, direction = 1) {
      theta <- match.arg(theta, c("x", "y"))
      r <- if (theta == "x") "y" else "x"
      ggplot2::ggproto("CoordRadar", ggplot2::CoordPolar,
                       theta = theta, r = r, start = start,
                       direction = sign(direction),
                       is_linear = function(coord) TRUE)
    }

    # Long format: group mean per variable
    plotdata <- res %>%
      dplyr::arrange(dplyr::desc(.data[[ref_group]])) %>%
      tidyr::pivot_longer(cols = -1, names_to = "Group", values_to = "value") %>%
      dplyr::mutate(
        Group = factor(.data[["Group"]], levels = group_cols),
        Variable = factor(.data[["Variable"]], levels = unique(.data[["Variable"]]))
      )

    radar_theme <- theme_my() +
      ggplot2::theme(
        axis.text.y = ggplot2::element_text(size = 7),
        axis.text.x = ggplot2::element_text(size = 9),
        panel.grid.major = ggplot2::element_line(color = "grey85", linewidth = 0.3)
      )

    if (facet) {
      # Faceted: one panel per group via patchwork
      # (avoids facet_wrap + coord_polar bug in ggplot2 4.0+)
      plot_list <- lapply(seq_along(group_cols), function(i) {
        grp <- group_cols[i]
        sub <- plotdata[plotdata$Group == grp, ]
        ggplot2::ggplot(sub, ggplot2::aes(
          x = .data[["Variable"]], y = .data[["value"]], group = 1
        )) +
          ggplot2::geom_polygon(fill = cols[i], color = cols[i],
                                alpha = 0.15, linewidth = 0.8) +
          ggplot2::geom_point(color = cols[i], size = 2) +
          coord_radar() +
          ggplot2::labs(x = NULL, y = NULL, title = grp) +
          radar_theme +
          ggplot2::theme(plot.title = ggplot2::element_text(
            hjust = 0.5, size = 12, face = "bold", color = cols[i]
          ))
      })
      p <- patchwork::wrap_plots(plot_list, nrow = 1)
    } else {
      # Overlaid: all groups on one radar
      p <- ggplot2::ggplot(plotdata, ggplot2::aes(
        x = .data[["Variable"]], y = .data[["value"]],
        color = .data[["Group"]], fill = .data[["Group"]],
        group = .data[["Group"]]
      )) +
        ggplot2::geom_polygon(alpha = 0.15, linewidth = 0.8) +
        ggplot2::geom_point(size = 2) +
        coord_radar() +
        ggplot2::scale_color_manual(values = cols) +
        ggplot2::scale_fill_manual(values = cols) +
        ggplot2::labs(x = NULL, y = NULL) +
        radar_theme
    }

    return(p)
  }

  # --- base mode (fmsb) ---
  if (!requireNamespace("fmsb", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg fmsb} is required. Install with: {.code install.packages('fmsb')}")
  }

  # Sort by ref_group and transpose
  radar_data <- res %>%
    dplyr::arrange(.data[[ref_group]]) %>%
    tibble::column_to_rownames("Variable") %>%
    t() %>%
    as.data.frame()

  # Axis range
  num_min <- if (is.null(min_max)) floor(min(radar_data) * 100) / 100 else min_max[1]
  num_max <- if (is.null(min_max)) ceiling(max(radar_data) * 100) / 100 else min_max[2]
  breaks <- seq(num_min, num_max, length.out = n_breaks)

  # fmsb requires max/min rows on top
  radar_data <- rbind(
    rep(num_max, ncol(radar_data)),
    rep(num_min, ncol(radar_data)),
    radar_data
  )

  # Internal plot helper
  .draw_radar <- function(d, cols, title, show_legend) {
    fmsb::radarchart(
      df = d, axistype = 1, seg = length(breaks) - 1,
      caxislabels = round(breaks, 3), calcex = 0.8,
      pty = 16, pcol = scales::alpha(cols, 0.8), plwd = 2, plty = 1,
      pfcol = scales::alpha(cols, 0.2),
      cglty = 1, cglwd = 0.1, cglcol = "grey",
      axislabcol = "black", title = title, maxmin = TRUE,
      na.itp = FALSE, vlcex = 1
    )
    if (show_legend) {
      graphics::legend(
        x = 1.5, y = 0.5, legend = rownames(d)[-c(1:2)],
        bty = "n", pch = 20, col = scales::alpha(cols, 0.8),
        text.col = "black", cex = 1, pt.cex = 2
      )
    }
  }

  if (facet) {
    n_facets <- nrow(radar_data) - 2
    graphics::par(mar = c(1, 1.1, 1, 1.1), mfrow = c(ceiling(n_facets / 2), 2))
    for (i in seq_len(n_facets)) {
      sub_data <- radar_data[c(1, 2, i + 2), , drop = FALSE]
      .draw_radar(sub_data, cols[i], title = rownames(radar_data)[i + 2],
                  show_legend = FALSE)
    }
  } else {
    .draw_radar(radar_data, cols, title = NULL, show_legend = TRUE)
  }

  invisible(res)
}
