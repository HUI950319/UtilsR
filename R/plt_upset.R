# ============================================================================
# plt_upset.R -- UpSet + Venn diagram for set intersections
# ============================================================================

#' UpSet and Venn Diagram for Set Intersections
#'
#' Visualise intersections of binary categorical variables using Venn diagrams
#' and UpSet plots. Returns both plots and a data frame with intersection
#' group assignments.
#'
#' @param data A data frame.
#' @param vars Character vector of binary variable names to intersect.
#' @param levels Character vector of values indicating membership
#'   (e.g. \code{c("Yes", "yes", "1")}). Default \code{c("Yes", "yes")}.
#' @param colors Character vector of 3 colours for
#'   \code{c(sets_bar, top_bar, matrix_dots)}. Default uses \code{pal_lancet}.
#' @param output What to return:
#'   \describe{
#'     \item{\code{"venn"}}{Venn diagram only (ggplot).}
#'     \item{\code{"upset"}}{UpSet plot only (non-zero intersections).}
#'     \item{\code{"both"}}{(default) Combined Venn + UpSet side by side.}
#'     \item{\code{"data"}}{Data frame with \code{intersect_group} column added.}
#'     \item{\code{"all"}}{Named list with all plots and data.}
#'   }
#'
#' @return Depends on \code{output}: a ggplot, a combined plot, a data frame,
#'   or a named list.
#'
#' @note Requires \pkg{ggVennDiagram} and optionally \pkg{aplot} (for combined
#'   layout). Install with \code{pak::pak(c("ggVennDiagram", "aplot"))}.
#'
#' @examples
#' df <- data.frame(
#'   A = sample(c("Yes","No"), 100, TRUE, c(0.3, 0.7)),
#'   B = sample(c("Yes","No"), 100, TRUE, c(0.4, 0.6)),
#'   C = sample(c("Yes","No"), 100, TRUE, c(0.5, 0.5)),
#'   D = sample(c("Yes","No"), 100, TRUE, c(0.2, 0.8))
#' )
#'
#' # Venn diagram
#' plt_upset(df, vars = c("A","B","C"), output = "venn")
#'
#' # UpSet plot
#' plt_upset(df, vars = c("A","B","C","D"), output = "upset")
#'
#' # Combined (default)
#' plt_upset(df, vars = c("A","B","C"))
#'
#' # Get data with intersection groups
#' result <- plt_upset(df, vars = c("A","B","C"), output = "data")
#' table(result$intersect_group)
#'
#' # Custom membership levels
#' df2 <- data.frame(
#'   x = sample(0:1, 100, TRUE),
#'   y = sample(0:1, 100, TRUE),
#'   z = sample(0:1, 100, TRUE)
#' )
#' plt_upset(df2, vars = c("x","y","z"), levels = c("1"))
#'
#' # All outputs
#' res <- plt_upset(df, vars = c("A","B","C","D"), output = "all")
#' names(res)
#'
#' @export
#' @family plot formatting
plt_upset <- function(data,
                      vars,
                      levels = c("Yes", "yes"),
                      colors = NULL,
                      output = c("both", "venn", "upset", "data", "all")) {

  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggVennDiagram} is required. Install with: {.code pak::pak('ggVennDiagram')}")
  }

  output <- match.arg(output)
  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  missing_vars <- vars[!vars %in% names(data)]
  if (length(missing_vars) > 0) cli::cli_abort("Variable{?s} not found: {.val {missing_vars}}")

  # Default colours
  if (is.null(colors)) colors <- as.character(pal_lancet[5:7])
  colors <- rep_len(colors, 3)

  # Build set lists
  set_list <- lapply(stats::setNames(vars, vars), function(v) {
    which(data[[v]] %in% levels)
  })

  # --- Venn ---
  p_venn <- ggVennDiagram::ggVennDiagram(set_list) +
    ggplot2::scale_fill_gradient(low = "grey90", high = "red")

  # --- UpSet helper: safely call ggVennDiagram with force_upset ---
  .safe_upset <- function(set_list, nintersects, colors) {
    tryCatch(
      ggVennDiagram::ggVennDiagram(
        set_list, force_upset = TRUE, nintersects = nintersects,
        relative_height = 2, relative_width = 0.3,
        sets.bar.show.numbers = TRUE,
        sets.bar.color = colors[1],
        top.bar.color = colors[2],
        intersection.matrix.color = colors[3]
      ),
      error = function(e) {
        cli::cli_warn("ggVennDiagram force_upset failed: {e$message}. Returning Venn only.")
        NULL
      }
    )
  }

  # --- UpSet (all intersections first, then filter non-zero) ---
  p_upset_all <- .safe_upset(set_list, NULL, colors)

  p_upset <- NULL
  upset_data <- NULL
  if (!is.null(p_upset_all)) {
    # Extract intersection data from aplot/upset_plot object
    # ggVennDiagram returns upset_plot/aplot with $plotlist[[2]]$data
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
      p_upset <- .safe_upset(set_list, n_nonzero, colors)
    } else {
      p_upset <- p_upset_all
    }
  }

  # --- Combined (print upset directly, it's already an aplot) ---
  p_combined <- NULL
  if (output %in% c("both", "all")) {
    # p_upset is already an aplot object from ggVennDiagram, just return it
    # Venn + UpSet side by side requires patchwork
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

  # --- Data with intersection groups ---
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

  # --- Return ---
  switch(output,
    venn = p_venn,
    upset = p_upset,
    both = p_combined,
    data = grp_data,
    all = list(venn = p_venn, upset = p_upset,
               combined = p_combined, data = grp_data)
  )
}
