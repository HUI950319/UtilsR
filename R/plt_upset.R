# =============================================================================
# plt_upset.R -- UpSet and Venn diagrams for set intersections
# =============================================================================

#' UpSet and Venn Diagram for Set Intersections
#'
#' Visualise intersections using Venn diagrams and UpSet plots.
#' Accepts either a \strong{named list} of element vectors (e.g. gene names)
#' or a \strong{data.frame} with binary indicator columns.
#' For data frames, set \code{levels = NA} to visualise missing-value patterns
#' without modifying the input data.
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
#'   Select at least two sets, with unique, non-missing, non-blank names.
#'   List members must be one-dimensional atomic vectors; factors are accepted,
#'   while other classed member IDs must first be converted to stable identifiers.
#'   Selected data-frame columns cannot be matrix or list columns.
#' @param vars Character vector of column names to intersect.
#'   Required when \code{data} is a data.frame; ignored when \code{data}
#'   is a list.
#' @param levels Vector of values indicating membership
#'   (e.g. \code{c("Yes", "yes", "1")}). Use \code{NA} to treat missing
#'   values as set members. Default \code{c("Yes", "yes")}.
#'   Missingness follows \code{is.na()} on the original columns, including
#'   SPSS user-missing values; methods for serialized classed columns are loaded.
#'   Ignored when \code{data} is a list.
#' @param colors Character vector. For UpSet: 3 colours for
#'   \code{c(sets_bar, top_bar, matrix_dots)}.
#'   For Venn: colour(s) used in the fill gradient or as category colours
#'   (see \code{venn.fill}). Default uses \code{pal_lancet}.
#' @param output What to return:
#'   \describe{
#'     \item{\code{"venn"}}{Venn diagram only (ggplot).}
#'     \item{\code{"upset"}}{UpSet plot only (non-zero intersections).}
#'     \item{\code{"both"}}{(default) Combined Venn + UpSet side by side;
#'       returns only UpSet above seven sets.}
#'     \item{\code{"data"}}{Data frame with \code{intersect_group} column.}
#'     \item{\code{"all"}}{Named list with all plots and data;
#'       \code{venn} is \code{NULL} above seven sets.}
#'   }
#'   Plot outputs require at least one selected member. Empty selections
#'   remain valid for \code{"data"}, including zero-row inputs.
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
#'   \code{venn.fill = "category"}, between 0 and 1. Default \code{0.5}.
#' @param edge.color Color of the set boundary lines. Default \code{"grey30"}.
#' @param edge.size Line width of the set boundaries. Default \code{1}.
#' @param set.name.size Font size for set names around the Venn.
#'   Default \code{4}.
#' @param set.labels Named character vector to rename sets in the plot.
#'   Names = original set names, values = display labels.
#'   e.g. \code{c(TraceGene = "Trajectory", PropCor = "Proportion Cor")}.
#'   Unmatched names keep the original. Default \code{NULL} (no renaming).
#'   These labels also name returned intersection groups. Colliding group
#'   names receive numeric suffixes; repeated plot labels remain unchanged.
#'
#' @param save \code{NULL}, an empty list (default), or a named list forwarded
#'   to \code{RegR::save_plt()} for PDF output: \code{filename} and optionally
#'   \code{width} and \code{height}. A \code{width} or \code{height} left out
#'   defaults to the page the plot is laid out for -- 5 x 5 in for the Venn
#'   diagram, a 6 x 4.5 in panel for the UpSet plot, and 5 x 4.5 in per unit of
#'   their 0.4 : 1 widths side by side, beside the measured axis text -- which
#'   every call prints with the matching \code{save} line; \code{"all"} saves
#'   the combined plot and \code{"data"} draws none to save. Saving, and the
#'   size note, need the \pkg{RegR} package.
#'
#' @return Depends on \code{output}: a ggplot, a combined plot, a data frame,
#'   or a named list. List-input data retain member IDs in \code{.element},
#'   with a numeric suffix if that column name is already a set name.
#'   Existing input columns, including \code{.row_id}, are preserved.
#'   For \code{"data"} and \code{"all"}, an existing \code{intersect_group}
#'   column must be renamed first to avoid overwriting it.
#'   Plots carry their page size as
#'   \code{attr(p, "plot_size")}, the list of \code{"all"} on its
#'   \code{combined} element.
#'
#' @note Requires \pkg{ggVennDiagram}; UpSet and combined layouts use
#'   \pkg{aplot}. Install with \code{pak::pak(c("ggVennDiagram", "aplot"))}.
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
#' # ---- Missing-value UpSet plot ----
#' bmi <- data.frame(
#'   BMI_1 = c(22.1, NA, 24.3, 25.4, NA, 27.6),
#'   BMI_2 = c(NA, 23.2, NA, 25.4, NA, 27.6),
#'   BMI_3 = c(22.1, 23.2, NA, NA, NA, 27.6)
#' )
#' p_missing <- plt_upset(
#'   bmi,
#'   vars = c("BMI_1", "BMI_2", "BMI_3"),
#'   levels = NA,
#'   output = "upset"
#' )
#' p_missing
#'
#' # ---- ToyData clinical cohort ----
#' if (requireNamespace("ToyData", quietly = TRUE) &&
#'     requireNamespace("ggVennDiagram", quietly = TRUE)) {
#'   oc0 <- ToyData::oc0
#'   plt_upset(
#'     oc0,
#'     vars = c("BMI_1", "BMI_2", "BMI_3"),
#'     levels = NA,
#'     output = "upset"
#'   )
#' }
#'
#' \dontrun{
#' ggplot2::ggsave("bmi-missing-upset.pdf", p_missing,
#'                 width = 6.5, height = 4.5)
#' }
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
                      set.labels    = NULL,
                      save          = list()) {

  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggVennDiagram} is required. Install with: {.code pak::pak('ggVennDiagram')}")
  }

  output     <- match.arg(output)
  label      <- match.arg(label)
  label_geom <- match.arg(label_geom)
  venn.fill  <- match.arg(venn.fill)

  valid_names <- function(x) {
    !is.null(x) && !anyNA(x) && !anyDuplicated(x) &&
      all(grepl("[^\\s\\p{Z}]", x, perl = TRUE))
  }
  if (!is.null(set.labels) &&
      (!is.character(set.labels) || !is.null(dim(set.labels)) ||
       (length(set.labels) && (!valid_names(names(set.labels)) ||
        anyNA(set.labels) || any(!grepl("[^\\s\\p{Z}]", set.labels, perl = TRUE)))))) {
    cli::cli_abort("{.arg set.labels} must be a named character vector with unique, non-missing, non-empty keys and non-empty display labels.")
  }
  if (!is.numeric(venn.alpha) || length(venn.alpha) != 1L ||
      !is.finite(venn.alpha) || venn.alpha < 0 || venn.alpha > 1) {
    cli::cli_abort("{.arg venn.alpha} must be one finite number between 0 and 1.")
  }

  # ── Dispatch: list vs data.frame ─────────────────────────────────────────
  is_list_input <- is.list(data) && !is.data.frame(data)

  if (is_list_input) {
    # --- List of element vectors (gene names, etc.) ---
    if (!valid_names(names(data))) {
      cli::cli_abort("When {.arg data} is a list, set names must be unique, non-missing and non-empty.")
    }
    if (length(data) < 2L) cli::cli_abort("Select at least two sets.")
    supported <- vapply(data, function(x) {
      is.null(x) || (is.atomic(x) && is.null(dim(x)) && (!is.object(x) || is.factor(x)))
    }, logical(1))
    if (!all(supported)) {
      cli::cli_abort("List inputs require one-dimensional atomic member vectors; convert unsupported classed members to stable identifiers.")
    }
    if (output %in% c("data", "all") && "intersect_group" %in% names(data)) {
      cli::cli_abort("{.arg data} already contains {.field intersect_group}; rename it before requesting grouped data.")
    }
    # Use row indices as shared member identities for both input formats.
    all_elements <- unique(unlist(data))
    set_list <- lapply(data, function(x) which(all_elements %in% x))
    if (output %in% c("data", "all")) {
      df_bin <- data.frame(.element = all_elements, stringsAsFactors = FALSE)
      names(df_bin) <- tail(make.unique(c(names(data), ".element")), 1L)
      for (nm in names(data)) {
        df_bin[[nm]] <- ifelse(all_elements %in% data[[nm]], "Yes", "No")
      }
      data <- df_bin
    }

  } else if (is.data.frame(data)) {
    # --- Data frame with binary columns ---
    if (!is.atomic(levels) || !is.null(dim(levels))) {
      cli::cli_abort("{.arg levels} must be a one-dimensional atomic vector.")
    }
    if (is.null(vars)) {
      cli::cli_abort("{.arg vars} is required when {.arg data} is a data.frame.")
    }
    if (!valid_names(names(data))) {
      cli::cli_abort("{.arg data} must have unique, non-missing, non-empty column names.")
    }
    if (!is.character(vars) || !is.null(dim(vars)) || !valid_names(vars)) {
      cli::cli_abort("{.arg vars} must contain unique, non-missing, non-empty column names.")
    }
    if (length(vars) < 2L) cli::cli_abort("Select at least two sets.")
    missing_vars <- vars[!vars %in% names(data)]
    if (length(missing_vars) > 0) {
      cli::cli_abort("Variable{?s} not found: {.val {missing_vars}}")
    }
    supported <- vapply(data[vars], function(x) {
      is.null(dim(x)) && (!is.list(x) || inherits(x, "POSIXlt")) && !is.expression(x)
    }, logical(1))
    if (!all(supported)) {
      cli::cli_abort("Selected columns must be one-dimensional vectors; unsupported columns: {.val {vars[!supported]}}.")
    }
    if (output %in% c("data", "all") && "intersect_group" %in% names(data)) {
      cli::cli_abort("{.arg data} already contains {.field intersect_group}; rename it before requesting grouped data.")
    }
    set_list <- lapply(stats::setNames(vars, vars), function(v) {
      values <- data[[v]]
      pkg <- if (inherits(values, "integer64")) "bit64" else
        if (inherits(values, "haven_labelled")) "haven" else
          if (inherits(values, c("Duration", "Period", "Interval"))) "lubridate" else NULL
      if (!is.null(pkg) && !requireNamespace(pkg, quietly = TRUE)) {
        cli::cli_abort("Inspecting {.cls {class(values)[1]}} columns requires package {.pkg {pkg}}.")
      }
      member <- if (anyNA(levels)) is.na(values) else rep(FALSE, nrow(data))
      value_levels <- levels[!is.na(levels)]
      if (length(value_levels)) member <- member | (values %in% value_levels)
      which(member)
    })

  } else {
    cli::cli_abort("{.arg data} must be a named list or a data.frame.")
  }

  if (length(set_list) > 7L && output == "venn") {
    cli::cli_abort("Venn diagrams support 2 to 7 sets; use {.code output = 'upset'} for more sets.")
  }
  if (output != "data" && !any(lengths(set_list) > 0L)) {
    cli::cli_abort("No set members match the selection; use {.code output = 'data'} to return the groups.")
  }
  if (length(set_list) > 7L && output %in% c("both", "all")) {
    cli::cli_inform("Venn diagrams support 2 to 7 sets; returning the UpSet plot without a Venn panel.")
  }

  # Default colours
  if (is.null(colors)) colors <- as.character(pal_lancet[5:7])
  if (!is.character(colors) || !is.null(dim(colors)) || !length(colors) || anyNA(colors) ||
      !tryCatch({ grDevices::col2rgb(colors, alpha = TRUE); TRUE }, error = function(e) FALSE)) {
    cli::cli_abort("{.arg colors} must be a non-empty character vector of valid colours.")
  }
  colors <- unname(colors)

  # Keep unique internal set keys separate from labels used for display.
  display_names <- names(set_list)
  if (!is.null(set.labels)) {
    old_names <- display_names
    new_names <- ifelse(old_names %in% names(set.labels),
                        set.labels[old_names], old_names)
    display_names <- unname(new_names)
  }
  set_keys <- sprintf("set%0*d", nchar(length(set_list)),
                      rank(display_names, ties.method = "first"))
  names(set_list) <- set_keys
  set_labels <- stats::setNames(display_names, set_keys)

  # Statistics do not depend on the structure or success of a rendered plot.
  grp_info <- NULL
  if (output != "venn") {
    grp_info <- ggVennDiagram::process_region_data(ggVennDiagram::Venn(set_list))
    region_names <- vapply(strsplit(as.character(grp_info$id), "/", fixed = TRUE),
                           function(i) paste(display_names[as.integer(i)], collapse = "/"),
                           character(1))
    group_names <- make.unique(c(region_names, "None"))
    grp_info$name <- head(group_names, -1L)
    none_group <- tail(group_names, 1L)
    grp_info <- grp_info[order(-grp_info$count), ]
  }
  grp_data <- NULL
  if (output %in% c("data", "all")) {
    row_groups <- rep(none_group, nrow(data))
    for (i in which(grp_info$count > 0)) {
      row_groups[grp_info$item[[i]]] <- grp_info$name[[i]]
    }
    grp_data <- data
    grp_data$intersect_group <- factor(row_groups, levels = c(grp_info$name, none_group))
    if (output == "data") {
      if (length(save)) cli::cli_abort("{.code output = \"data\"} draws no plot to save.")
      return(grp_data)
    }
  }

  # ── Venn ─────────────────────────────────────────────────────────────────
  venn_label <- switch(label,
    both    = "both",
    count   = "count",
    percent = "percent",
    none    = "none"
  )

  p_venn <- NULL
  if (output %in% c("venn", "both", "all") && length(set_list) <= 7L) {
    p_venn <- ggVennDiagram::ggVennDiagram(
      set_list,
      label           = venn_label,
      label_geom      = label_geom,
      label_color     = label_color,
      label_size      = label_size,
      label_alpha     = label_alpha,
      edge_size       = edge.size,
      set_size        = set.name.size
    )
    p_venn <- .plt_upset_labels(p_venn, set_labels)
    p_venn <- .plt_upset_venn_fill(p_venn, venn.fill, colors, venn.alpha, edge.color)
  }

  # ── UpSet ────────────────────────────────────────────────────────────────
  upset_colors <- rep_len(colors, 3)

  .safe_upset <- function(set_list, nintersects, cols) {
    tryCatch(
      {
        p <- ggVennDiagram::ggVennDiagram(
          set_list, force_upset = TRUE, nintersects = nintersects,
          relative_height = 2, relative_width = 0.3,
          sets.bar.show.numbers = TRUE,
          sets.bar.color = cols[1],
          top.bar.color = cols[2],
          intersection.matrix.color = cols[3]
        )
        .plt_upset_labels(p, set_labels)
      },
      error = function(e) {
        if (is.null(p_venn)) {
          cli::cli_abort("Cannot construct the requested UpSet plot.", parent = e)
        }
        cli::cli_warn("ggVennDiagram force_upset failed: {e$message}. Returning the Venn plot.")
        NULL
      }
    )
  }

  p_upset <- NULL
  if (output %in% c("upset", "both", "all")) {
    p_upset <- .safe_upset(set_list, sum(grp_info$count > 0), upset_colors)
  }

  # ── Combined ─────────────────────────────────────────────────────────────
  p_combined <- NULL
  if (output %in% c("both", "all")) {
    if (!is.null(p_upset) && !is.null(p_venn)) {
      p_combined <- tryCatch({
        patchwork::wrap_plots(p_venn, aplot::as.patchwork(p_upset),
                              ncol = 2, widths = c(0.4, 1))
      }, error = function(e) {
        cli::cli_warn("Combined layout failed: {e$message}. Returning the UpSet plot.")
        p_upset
      })
    } else if (!is.null(p_upset)) {
      p_combined <- p_upset
    } else {
      p_combined <- p_venn
    }
  }

  # ── Return ───────────────────────────────────────────────────────────────
  finish <- function(p) {
    panel <- if (length(set_list) > 7L) c(6, 4.5) else
      switch(output, venn = c(5, 5), upset = c(6, 4.5), c(5, 4.5))
    .save_sized(p, save, panel, lead = "set plot laid out for",
                filename = "Figure X. Set overlaps.pdf")
  }
  switch(output,
    venn = finish(p_venn),
    upset = finish(p_upset),
    both = finish(p_combined),
    all = list(venn = p_venn, upset = p_upset,
               combined = finish(p_combined), data = grp_data)
  )
}

# Adapt upstream plot labels without retaining the caller's input data.
.plt_upset_labels <- function(p, set_labels) {
  force(p)
  force(set_labels)
  if (inherits(p, "aplot")) {
    for (i in c(1L, 3L)) {
      p$plotlist[[i]] <- suppressMessages(p$plotlist[[i]] +
        ggplot2::scale_y_discrete(labels = set_labels,
                                 position = if (i == 3L) "right" else "left"))
    }
  } else {
    p$layers[[3]]$data$name <- unname(set_labels[
      as.character(p$layers[[3]]$data$name)])
  }
  p
}

# Build Venn fill layers in a frame containing only the plot and style values.
.plt_upset_venn_fill <- function(p, fill, colors, alpha, edge_color) {
  force(p)
  force(fill)
  force(colors)
  force(alpha)
  force(edge_color)
  edge_layer <- p$layers[[2]]
  p$layers[[2]] <- ggplot2::ggproto(NULL, edge_layer)
  p$layers[[2]]$mapping$colour <- NULL
  p$layers[[2]]$aes_params$colour <- edge_color
  if (fill == "gradient") {
    p <- p + ggplot2::scale_fill_gradient(low = "grey90", high = colors[1])
  } else if (fill == "gradient_rev") {
    p <- p + ggplot2::scale_fill_gradient(low = colors[1], high = "grey90")
  } else if (fill == "category") {
    outline <- p$layers[[2]]$data
    set_ids <- unique(as.character(outline$id))
    p$layers[[1]] <- ggplot2::geom_polygon(
      data = outline,
      ggplot2::aes(x = .data[["X"]], y = .data[["Y"]],
                   group = .data[["id"]], fill = .data[["id"]]),
      alpha = alpha, colour = NA, inherit.aes = FALSE
    )
    p <- p + ggplot2::scale_fill_manual(
      values = stats::setNames(rep_len(colors, length(set_ids)), set_ids), guide = "none"
    )
  } else {
    p <- p + ggplot2::scale_fill_gradient(low = "transparent", high = "transparent", guide = "none")
  }
  p
}
