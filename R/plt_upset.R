# ============================================================================
# plt_upset.R -- UpSet + Venn diagram for set intersections
# ============================================================================

#' UpSet and Venn Diagram for Set Intersections
#'
#' Visualise intersections using Venn diagrams and UpSet plots.
#' Accepts either a \strong{named list} of element vectors (e.g. gene names)
#' or a \strong{data.frame} with binary indicator columns.
#'
#' @param data Input data in one of two formats:
#'   \describe{
#'     \item{\strong{Named list}}{Each element is a character/numeric vector
#'       of set members (e.g. gene names). Names become set labels.
#'       Example: \code{list(TraceGene = c("A","B"), DE = c("B","C"))}.
#'       When a list is provided, \code{vars} and \code{levels} are ignored.}
#'     \item{\strong{Data frame}}{A data.frame with binary indicator columns
#'       specified by \code{vars}. Membership is determined by \code{levels}.}
#'   }
#' @param vars Character vector of column names to intersect.
#'   Required when \code{data} is a data.frame; ignored when \code{data}
#'   is a list.
#' @param levels Character vector of values indicating membership
#'   (e.g. \code{c("Yes", "yes", "1")}). Default \code{c("Yes", "yes")}.
#'   Ignored when \code{data} is a list.
#' @param colors Character vector. For UpSet: 3 colours for
#'   \code{c(sets_bar, top_bar, matrix_dots)}.
#'   For Venn: colour(s) used in the fill gradient or as category colours
#'   (see \code{venn.fill}). Default uses \code{pal_lancet}.
#' @param output What to return:
#'   \describe{
#'     \item{\code{"venn"}}{Venn diagram only (ggplot).}
#'     \item{\code{"upset"}}{UpSet plot only (non-zero intersections).}
#'     \item{\code{"both"}}{(default) Combined Venn + UpSet side by side.}
#'     \item{\code{"data"}}{Data frame with \code{intersect_group} column.}
#'     \item{\code{"all"}}{Named list with all plots and data.}
#'   }
#' @param label What to show inside each region of the Venn diagram:
#'   \code{"both"} (count + percent, default), \code{"count"},
#'   \code{"percent"}, or \code{"none"}.
#' @param label_geom Geom for labels: \code{"label"} (with background box,
#'   default) or \code{"text"} (plain text).
#' @param label_color Color of the label text. Default \code{"black"}.
#' @param label_size Font size of the labels. Default \code{3.5}.
#' @param label_alpha Alpha of the label background (only for
#'   \code{label_geom = "label"}). Default \code{0.6}.
#' @param venn.fill How to fill the Venn regions. One of:
#'   \describe{
#'     \item{\code{"gradient"}}{(default) Continuous fill by count,
#'       gradient from grey90 to \code{colors[1]}.}
#'     \item{\code{"gradient_rev"}}{Reversed continuous fill by count,
#'       gradient from \code{colors[1]} to grey90 (large overlaps appear lighter).}
#'     \item{\code{"category"}}{Each set gets a distinct fill colour from
#'       \code{colors}; region alpha encodes overlap.}
#'     \item{\code{"none"}}{No fill (transparent).}
#'   }
#' @param venn.alpha Alpha for the set regions when
#'   \code{venn.fill = "category"}. Default \code{0.5}.
#' @param edge.color Color of the set boundary lines. Default \code{"grey30"}.
#' @param edge.size Line width of the set boundaries. Default \code{1}.
#' @param set.name.size Font size for set names around the Venn.
#'   Default \code{4}.
#' @param set.labels Named character vector to rename sets in the plot.
#'   Names = original set names, values = display labels.
#'   e.g. \code{c(TraceGene = "Trajectory", PropCor = "Proportion Cor")}.
#'   Unmatched names keep the original. Default \code{NULL} (no renaming).
#'
#' @return Depends on \code{output}: a ggplot, a combined plot, a data frame,
#'   or a named list.
#'
#' @note Requires \pkg{ggVennDiagram} and optionally \pkg{aplot} (for combined
#'   layout). Install with \code{pak::pak(c("ggVennDiagram", "aplot"))}.
#'
#' @examples
#' # ---- List input (most convenient) ----
#' gene_sets <- list(
#'   TraceGene = c("TP53","MDM2","EGFR","BRCA1","MYC"),
#'   DE        = c("EGFR","BRCA1","KRAS","PIK3CA"),
#'   PropCor   = c("BRCA1","MYC","APC","PTEN")
#' )
#' plt_upset(gene_sets, output = "venn")
#' plt_upset(gene_sets, output = "venn",
#'           set.labels = c(TraceGene = "Trajectory", PropCor = "Prop. Cor"),
#'           label = "count", colors = "#E64B35")
#'
#' # ---- Data frame input ----
#' df <- data.frame(
#'   A = sample(c("Yes","No"), 100, TRUE, c(0.3, 0.7)),
#'   B = sample(c("Yes","No"), 100, TRUE, c(0.4, 0.6)),
#'   C = sample(c("Yes","No"), 100, TRUE, c(0.5, 0.5))
#' )
#' plt_upset(df, vars = c("A","B","C"), output = "venn",
#'           label = "count", label_geom = "text")
#'
#' @export
#' @family plot
plt_upset <- function(data,
                      vars          = NULL,
                      levels        = c("Yes", "yes"),
                      colors        = NULL,
                      output        = c("both", "venn", "upset", "data", "all"),
                      label         = c("both", "count", "percent", "none"),
                      label_geom    = c("label", "text"),
                      label_color   = "black",
                      label_size    = 3.5,
                      label_alpha   = 0.6,
                      venn.fill     = c("gradient", "gradient_rev", "category", "none"),
                      venn.alpha    = 0.5,
                      edge.color    = "grey30",
                      edge.size     = 1,
                      set.name.size = 4,
                      set.labels    = NULL) {

  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggVennDiagram} is required. Install with: {.code pak::pak('ggVennDiagram')}")
  }

  output     <- match.arg(output)
  label      <- match.arg(label)
  label_geom <- match.arg(label_geom)
  venn.fill  <- match.arg(venn.fill)

  # ── Dispatch: list vs data.frame ─────────────────────────────────────────
  is_list_input <- is.list(data) && !is.data.frame(data)

  if (is_list_input) {
    # --- List of element vectors (gene names, etc.) ---
    if (is.null(names(data)) || any(names(data) == "")) {
      cli::cli_abort("When {.arg data} is a list, all elements must be named.")
    }
    # Convert to data.frame + set_list simultaneously
    all_elements <- unique(unlist(data))
    df_bin <- data.frame(.element = all_elements, stringsAsFactors = FALSE)
    for (nm in names(data)) {
      df_bin[[nm]] <- ifelse(all_elements %in% data[[nm]], "Yes", "No")
    }
    vars   <- names(data)
    levels <- c("Yes", "yes")
    # Keep df_bin for potential "data" output
    data <- df_bin

    # set_list uses element values directly (for ggVennDiagram)
    set_list <- data[names(data)]  # named list of vectors
    set_list <- lapply(stats::setNames(vars, vars), function(v) {
      which(data[[v]] %in% levels)
    })

  } else if (is.data.frame(data)) {
    # --- Data frame with binary columns ---
    if (is.null(vars)) {
      cli::cli_abort("{.arg vars} is required when {.arg data} is a data.frame.")
    }
    missing_vars <- vars[!vars %in% names(data)]
    if (length(missing_vars) > 0) {
      cli::cli_abort("Variable{?s} not found: {.val {missing_vars}}")
    }
    set_list <- lapply(stats::setNames(vars, vars), function(v) {
      which(data[[v]] %in% levels)
    })

  } else {
    cli::cli_abort("{.arg data} must be a named list or a data.frame.")
  }

  # Default colours
  if (is.null(colors)) colors <- as.character(pal_lancet[5:7])

  # Rename sets if set.labels provided
  if (!is.null(set.labels)) {
    old_names <- names(set_list)
    new_names <- ifelse(old_names %in% names(set.labels),
                        set.labels[old_names], old_names)
    names(set_list) <- new_names
  }

  # ── Venn ─────────────────────────────────────────────────────────────────
  venn_label <- switch(label,
    both    = "both",
    count   = "count",
    percent = "percent",
    none    = "none"
  )

  p_venn <- ggVennDiagram::ggVennDiagram(
    set_list,
    label           = venn_label,
    label_geom      = label_geom,
    label_color     = label_color,
    label_size      = label_size,
    label_alpha     = label_alpha,
    edge_color      = edge.color,
    edge_size       = edge.size,
    set_size        = set.name.size
  )

  # Apply fill style
  if (venn.fill == "gradient") {
    grad_high <- colors[1]
    p_venn <- p_venn +
      ggplot2::scale_fill_gradient(low = "grey90", high = grad_high)
  } else if (venn.fill == "gradient_rev") {
    grad_high <- colors[1]
    p_venn <- p_venn +
      ggplot2::scale_fill_gradient(low = grad_high, high = "grey90")
  } else if (venn.fill == "category") {
    n_sets <- length(vars)
    cat_colors <- rep_len(colors, n_sets)
    p_venn <- p_venn +
      ggplot2::scale_fill_distiller(palette = "RdBu")
    p_venn <- p_venn +
      ggplot2::scale_color_manual(values = cat_colors, guide = "none")
  } else {
    # venn.fill == "none"
    p_venn <- p_venn +
      ggplot2::scale_fill_gradient(low = "white", high = "white")
  }

  # ── UpSet ────────────────────────────────────────────────────────────────
  upset_colors <- rep_len(colors, 3)

  .safe_upset <- function(set_list, nintersects, cols) {
    tryCatch(
      ggVennDiagram::ggVennDiagram(
        set_list, force_upset = TRUE, nintersects = nintersects,
        relative_height = 2, relative_width = 0.3,
        sets.bar.show.numbers = TRUE,
        sets.bar.color = cols[1],
        top.bar.color = cols[2],
        intersection.matrix.color = cols[3]
      ),
      error = function(e) {
        cli::cli_warn("ggVennDiagram force_upset failed: {e$message}. Returning Venn only.")
        NULL
      }
    )
  }

  p_upset_all <- .safe_upset(set_list, NULL, upset_colors)

  p_upset <- NULL
  upset_data <- NULL
  if (!is.null(p_upset_all)) {
    upset_data <- tryCatch({
      if (!is.null(p_upset_all$plotlist)) {
        p_upset_all$plotlist[[2]]$data
      } else if (is.list(p_upset_all) && "results" %in% names(p_upset_all)) {
        p_upset_all$results
      } else {
        NULL
      }
    }, error = function(e) NULL)

    if (!is.null(upset_data) && "size" %in% names(upset_data)) {
      n_nonzero <- sum(upset_data$size > 0)
      p_upset <- .safe_upset(set_list, n_nonzero, upset_colors)
    } else {
      p_upset <- p_upset_all
    }
  }

  # ── Combined ─────────────────────────────────────────────────────────────
  p_combined <- NULL
  if (output %in% c("both", "all")) {
    if (!is.null(p_upset)) {
      p_combined <- tryCatch({
        patchwork::wrap_plots(p_venn, p_upset, ncol = 2, widths = c(0.4, 1))
      }, error = function(e) {
        cli::cli_warn("Combined layout failed: {e$message}. Returning plots separately.")
        p_upset
      })
    } else {
      p_combined <- p_venn
    }
  }

  # ── Data with intersection groups ────────────────────────────────────────
  grp_data <- NULL
  if (output %in% c("data", "all")) {
    if (is.null(upset_data) || !"item" %in% names(upset_data)) {
      cli::cli_warn("Cannot extract intersection groups. Returning data without groups.")
      grp_data <- data
      grp_data$intersect_group <- NA_character_
    } else {
      grp_info <- upset_data %>% dplyr::arrange(dplyr::desc(.data[["size"]]))
      grp_rows <- stats::setNames(grp_info$item, grp_info$name)

      grp_data <- data
      grp_data$.row_id <- seq_len(nrow(data))
      grp_data$intersect_group <- vapply(grp_data$.row_id, function(rid) {
        hit <- names(grp_rows)[vapply(grp_rows, function(rows) rid %in% rows, logical(1))]
        if (length(hit) > 0) hit[1] else "None"
      }, character(1))
      grp_data$.row_id <- NULL
      all_levels <- c(grp_info$name, "None")
      grp_data$intersect_group <- factor(grp_data$intersect_group, levels = all_levels)
    }
  }

  # ── Return ───────────────────────────────────────────────────────────────
  switch(output,
    venn = p_venn,
    upset = p_upset,
    both = p_combined,
    data = grp_data,
    all = list(venn = p_venn, upset = p_upset,
               combined = p_combined, data = grp_data)
  )
}
