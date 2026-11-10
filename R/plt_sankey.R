# =============================================================================
# plt_sankey.R -- Sankey diagram for categorical variable flows
# =============================================================================

#' Sankey Diagram for Categorical Variables
#'
#' Visualise the flow/proportion changes across multiple categorical variables
#' using a Sankey (alluvial) diagram. Each node label shows the level name,
#' count, and percentage.
#'
#' @param data A data frame. Only selected columns are retained in the plot's
#'   working data; unrelated columns do not increase the returned plot size.
#'   Missing values form separate nodes; all input rows contribute to flows
#'   and percentage denominators. SPSS user-missing codes and ranges are
#'   converted to \code{NA} before categorization, requiring \pkg{haven}.
#' @param vars Character vector selecting at least two categorical variables,
#'   displayed left-to-right in the given order. An unnamed vector contains
#'   column names and retains the existing axis labels. A named vector maps
#'   column names to display labels, e.g. \code{c(sex = "Sex", stage = "Stage")}.
#'   All names must be non-empty, unique column names; partially named vectors
#'   are not supported. Labels must be non-missing strings. Empty strings hide
#'   individual labels, and line breaks are preserved.
#'   Input names such as \code{.n}, \code{.pct}, and names ending in
#'   \code{_label} are kept separate from generated fields.
#' @param palette Colour palette name from \code{pal_get()}, or a character
#'   vector of colours. Default \code{NULL} auto-generates colours per variable
#'   using sequential HCL palettes sized to the displayed nodes, including
#'   displayed missing-value nodes and excluding unused factor levels.
#' @param reverse_levels Logical, reverse factor levels for display.
#'   Default \code{TRUE}.
#' @param show_text Single character string. Controls node label content:
#'   \itemize{
#'     \item \code{"all"} (default) — name + count + percentage, e.g.
#'       \code{"A (10, 30.3\%)"}.
#'     \item \code{"all_wrap"} — name on the first line, with count and
#'       percentage together on the second line, e.g. \code{"A"} above
#'       \code{"(10, 30.3\%)"}.
#'     \item \code{"n"} — name + count, e.g. \code{"A (10)"}.
#'     \item \code{"pct"} — name + percentage, e.g. \code{"A (30.3\%)"}.
#'     \item \code{"name"} — name only, e.g. \code{"A"}.
#'     \item \code{"none"} — hide labels without removing nodes or flows.
#'   }
#' @param flow_args Named list controlling flow ribbons:
#'   \describe{
#'     \item{\code{alpha}}{Numeric opacity in [0, 1]. Default 0.6.}
#'     \item{\code{fill}}{Single fill colour or \code{NA}. Default \code{"grey"}.}
#'     \item{\code{color}}{Single border colour or \code{NA}. Default \code{"grey80"}.}
#'     \item{\code{smooth}}{Positive finite numeric value controlling the
#'       sigmoid curve steepness in ggsankey. Default 8.}
#'   }
#' @param node_args Named list controlling nodes and flow endpoints:
#'   \describe{
#'     \item{\code{width}}{Numeric width in (0, 1], relative to adjacent
#'       x-axis positions. Default 0.4.}
#'     \item{\code{space}}{\code{NULL} for automatic spacing, or a non-negative
#'       gap in count units. Default \code{NULL}; 0 removes gaps. Labels use
#'       the resulting node centers.}
#'     \item{\code{color}}{Single border colour or \code{NA} for no border.
#'       Default \code{NA}. Node fills are controlled by \code{palette}.}
#'     \item{\code{linewidth}}{\code{NULL} to retain the backend default,
#'       or a non-negative border width in mm. Default \code{NULL}.}
#'   }
#' @param label_args Named list controlling node labels:
#'   \describe{
#'     \item{\code{size}}{Positive text size in mm. Default 3.}
#'     \item{\code{lineheight}}{Positive finite line spacing multiplier relative
#'       to text size. Default 1.2; smaller values make multiline labels more
#'       compact. Applies to boxed and plain labels, including \code{all_wrap}
#'       and category names containing line breaks. Does not set box padding.}
#'     \item{\code{hjust}}{Finite numeric horizontal justification: 0 is left,
#'       0.5 is centered, and 1 is right. Default 0.5.}
#'     \item{\code{color}}{Single text colour or \code{NA}. Default \code{"black"}.}
#'     \item{\code{box}}{Logical; use boxed labels when \code{TRUE}, plain text
#'       when \code{FALSE}. Default \code{TRUE}.}
#'     \item{\code{fill}}{Single background colour or \code{NA}, used only
#'       when \code{box = TRUE}. Default \code{"white"}.}
#'     \item{\code{alpha}}{Numeric opacity in [0, 1]. Default 1.}
#'     \item{\code{min_pct}}{Numeric proportion in [0, 1]. Show labels only
#'       when the category count divided by the number of input rows meets
#'       this threshold. Default 0; nodes and flows are never filtered.}
#'     \item{\code{pct_accuracy}}{Positive rounding accuracy in percentage
#'       points, used by styles containing percentages. Default 0.1.}
#'   }
#' @param base_size Positive base font size in points for the default theme.
#'   Default 14; ignored when \code{theme_use} is supplied.
#' @param theme_use \code{NULL} for \code{ggsankey::theme_sankey(base_size)},
#'   or a theme specification accepted by the internal \code{.resolve_theme()}
#'   resolver (theme object, function, or function name). Default \code{NULL}.
#' @param save \code{NULL}, an empty list, or a named list forwarded to
#'   \code{RegR::save_plt()}. Allowed fields are \code{filename} (required),
#'   \code{width} and \code{height} (in inches). Writes PDF only; the saver
#'   appends the extension. A \code{width} or \code{height} left out defaults
#'   to the page the plot is laid out for -- 2 in per variable and 0.5 in per
#'   level of the variable with most levels, at least 4 x 4 in, beside the
#'   measured axis text -- which every call prints with the matching
#'   \code{save} line. Saving, and the size note, need the \pkg{RegR} package.
#'
#' @return A ggplot object carrying that page size as \code{attr(p,
#'   "plot_size")}, \code{c(width, height)} in inches. A non-empty \code{save}
#'   also writes this plot to PDF.
#'
#' @details Each configuration list supports partial overrides; unknown,
#'   duplicate, and empty field names are rejected. The former top-level
#'   \code{alpha} is now \code{flow_args$alpha}; \code{width} and \code{space}
#'   are now in \code{node_args}; \code{label_size} and \code{label_hjust}
#'   are now \code{label_args$size} and \code{label_args$hjust}.
#'
#' @note Requires the \pkg{ggsankey} package
#'   (\code{pak::pak("davidsjoberg/ggsankey")}).
#'
#' @examplesIf requireNamespace("ggsankey", quietly = TRUE)
#' df <- data.frame(
#'   sex = factor(sample(c("M","F"), 200, TRUE)),
#'   stage = factor(sample(c("I","II","III"), 200, TRUE)),
#'   grade = factor(sample(c("Low","High"), 200, TRUE))
#' )
#'
#' # Basic sankey
#' plt_sankey(df, vars = c("sex", "stage", "grade"))
#'
#' # Two variables
#' plt_sankey(df, vars = c("sex", "stage"))
#'
#' # Map column names to axis labels
#' plt_sankey(df, vars = c(sex = "Sex", stage = "Disease\nstage"))
#'
#' # Custom palette
#' plt_sankey(df, vars = c("sex", "stage"), palette = "Paired")
#'
#' # Without counts in labels
#' plt_sankey(df, vars = c("sex", "stage", "grade"), show_text = "pct")
#'
#' # Count and percentage on the second line, with compact line spacing
#' plt_sankey(df, vars = c("sex", "stage", "grade"), show_text = "all_wrap",
#'            label_args = list(lineheight = 1))
#'
#' # Adjust appearance
#' plt_sankey(df, vars = c("sex", "stage"),
#'            flow_args = list(alpha = 0.4), node_args = list(width = 0.3),
#'            label_args = list(size = 4, box = FALSE, min_pct = 0.05))
#'
#' @export
#' @family plot
plt_sankey <- function(data,
                       vars,
                       palette = NULL,
                       reverse_levels = TRUE,
                       show_text = c("all", "n", "pct", "name", "all_wrap", "none"),
                       flow_args = list(alpha = 0.6, fill = "grey", color = "grey80", smooth = 8),
                       node_args = list(width = 0.4, space = NULL, color = NA, linewidth = NULL),
                       label_args = list(size = 3, lineheight = 1.2, hjust = 0.5, color = "black", box = TRUE,
                                         fill = "white", alpha = 1, min_pct = 0, pct_accuracy = 0.1),
                       base_size = 14,
                       theme_use = NULL,
                       save = list()) {

  show_text <- match.arg(show_text)

  if (!requireNamespace("ggsankey", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggsankey} is required. Install with: {.code pak::pak('davidsjoberg/ggsankey')}")
  }

  flow_args <- .merge_args(flow_args,
    list(alpha = 0.6, fill = "grey", color = "grey80", smooth = 8), "flow_args")
  node_args <- .merge_args(node_args,
    list(width = 0.4, space = NULL, color = NA, linewidth = NULL), "node_args")
  label_args <- .merge_args(label_args,
    list(size = 3, lineheight = 1.2, hjust = 0.5, color = "black", box = TRUE,
         fill = "white", alpha = 1, min_pct = 0, pct_accuracy = 0.1), "label_args")

  is_number <- function(value, lower = -Inf, upper = Inf, positive = FALSE) {
    is.numeric(value) && !is.object(value) && is.null(dim(value)) &&
      length(value) == 1L && !is.na(value) &&
      is.finite(value) && value >= lower && value <= upper && (!positive || value > 0)
  }
  if (!is_number(flow_args$alpha, 0, 1)) cli::cli_abort("{.arg flow_args$alpha} must be in [0, 1].")
  if (!is_number(flow_args$smooth, positive = TRUE)) cli::cli_abort("{.arg flow_args$smooth} must be positive and finite.")
  if (!is_number(node_args$width, 0, 1, positive = TRUE)) cli::cli_abort("{.arg node_args$width} must be in (0, 1].")
  if (!is.null(node_args$space) && !is_number(node_args$space, 0)) cli::cli_abort("{.arg node_args$space} must be NULL or non-negative and finite.")
  if (!is.null(node_args$linewidth) && !is_number(node_args$linewidth, 0)) cli::cli_abort("{.arg node_args$linewidth} must be NULL or non-negative and finite.")
  if (!is_number(label_args$size, positive = TRUE)) cli::cli_abort("{.arg label_args$size} must be positive and finite.")
  if (!is_number(label_args$lineheight, positive = TRUE)) cli::cli_abort("{.arg label_args$lineheight} must be positive and finite.")
  if (!is_number(label_args$hjust)) cli::cli_abort("{.arg label_args$hjust} must be finite numeric.")
  if (!is_number(label_args$alpha, 0, 1)) cli::cli_abort("{.arg label_args$alpha} must be in [0, 1].")
  if (!is_number(label_args$min_pct, 0, 1)) cli::cli_abort("{.arg label_args$min_pct} must be in [0, 1].")
  if (!is_number(label_args$pct_accuracy, positive = TRUE)) cli::cli_abort("{.arg label_args$pct_accuracy} must be positive and finite.")
  if (!is.logical(label_args$box) || !is.null(dim(label_args$box)) ||
      length(label_args$box) != 1L || is.na(label_args$box)) {
    cli::cli_abort("{.arg label_args$box} must be TRUE or FALSE.")
  }
  styles <- list(flow_args = flow_args, node_args = node_args, label_args = label_args)
  for (arg in names(styles)) {
    for (field in intersect(c("color", "fill"), names(styles[[arg]]))) {
      value <- styles[[arg]][[field]]
      if (length(value) != 1L || !is.null(dim(value)) || !(is.character(value) || identical(value, NA)) ||
          inherits(try(grDevices::col2rgb(value), silent = TRUE), "try-error")) {
        cli::cli_abort("{.arg {arg}} field {.val {field}} must be one colour or NA.")
      }
    }
  }
  if (!is_number(base_size, positive = TRUE)) cli::cli_abort("{.arg base_size} must be positive and finite.")
  if (!is.logical(reverse_levels) || !is.null(dim(reverse_levels)) || length(reverse_levels) != 1L || is.na(reverse_levels)) {
    cli::cli_abort("{.arg reverse_levels} must be TRUE or FALSE.")
  }
  if (!is.null(save)) {
    if (!is.list(save)) cli::cli_abort("{.arg save} must be NULL or a named list.")
    if (length(save)) {
      save_names <- names(save)
      if (is.null(save_names) || anyNA(save_names) || any(!nzchar(save_names)) || anyDuplicated(save_names)) {
        cli::cli_abort("{.arg save} must have non-empty, unique field names.")
      }
      if (length(setdiff(save_names, c("filename", "width", "height")))) {
        cli::cli_abort("{.arg save} only accepts filename, width and height.")
      }
    }
  }

  if (!is.data.frame(data)) cli::cli_abort("{.arg data} must be a data frame.")
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data)))
    cli::cli_abort("{.arg data} must have unique, non-missing, non-empty column names.")
  if (!is.character(vars) || !is.null(dim(vars)) || anyNA(vars))
    cli::cli_abort("{.arg vars} must be a character vector of non-missing values.")
  if (length(vars) < 2) cli::cli_abort("{.arg vars} must have at least 2 variables.")
  if (is.null(names(vars)) && (any(!nzchar(vars)) || anyDuplicated(vars)))
    cli::cli_abort("{.arg vars} must contain unique, non-empty column names.")
  var_labels <- NULL
  if (!is.null(names(vars))) {
    if (!is.character(vars) || anyNA(vars)) {
      cli::cli_abort("Named {.arg vars} must contain non-missing character labels.")
    }
    if (anyNA(names(vars)) || any(names(vars) == "") || anyDuplicated(names(vars))) {
      cli::cli_abort("Named {.arg vars} must have non-empty, unique column names.")
    }
    var_labels <- stats::setNames(unname(vars), paste0(names(vars), "_label"))
    vars <- names(vars)
  }
  missing_vars <- vars[!vars %in% names(data)]
  if (length(missing_vars) > 0) cli::cli_abort("Variable{?s} not found: {.val {missing_vars}}")
  data <- as.data.frame(data)[vars]
  dimensional <- vapply(data, function(x) !is.null(dim(x)), logical(1))
  if (any(dimensional)) {
    cli::cli_abort("Selected columns {.val {vars[dimensional]}} must be one-dimensional.")
  }

  # Ensure factors
  for (v in vars) {
    if (inherits(data[[v]], "haven_labelled_spss")) {
      if (!requireNamespace("haven", quietly = TRUE)) {
        cli::cli_abort("Interpreting SPSS user-missing values requires package {.pkg haven}.")
      }
      data[[v]] <- haven::zap_missing(data[[v]])
    }
    if (!is.factor(data[[v]])) {
      values <- data[[v]]
      labels <- .butterfly_category_labels(values)
      data[[v]] <- if (identical(values, labels)) factor(values) else
        factor(labels, levels = unique(labels[order(values, na.last = NA)]))
    }
  }

  # Reverse levels if requested
  if (reverse_levels) {
    for (v in vars) data[[v]] <- forcats::fct_rev(data[[v]])
  }

  # Add count + percentage labels to each variable
  label_vars <- utils::tail(make.unique(c(names(data), paste0(vars, "_label"))), length(vars))
  if (!is.null(var_labels)) {
    names(var_labels) <- label_vars
  } else if (any(label_vars != paste0(vars, "_label"))) {
    var_labels <- stats::setNames(paste0(vars, "_label"), label_vars)
  }
  node_labels <- node_pct <- vector("list", length(vars))
  observed_levels <- integer(length(vars))
  total <- nrow(data)
  label_style <- if (show_text == "none") "all" else show_text
  for (i in seq_along(vars)) {
    value <- data[[vars[i]]]
    codes <- as.integer(value)
    counts <- tabulate(codes, nbins = nlevels(value))
    observed <- which(counts > 0L)
    counts <- counts[observed]
    missing <- sum(is.na(codes))
    if (missing) {
      observed <- c(observed, NA_integer_)
      counts <- c(counts, missing)
    }
    # Work with codes so an explicit NA level remains separate from missing rows.
    names_at <- levels(value)[observed]
    observed_levels[i] <- sum(!is.na(names_at))
    proportion <- counts / total
    pct <- if (label_style %in% c("all", "all_wrap", "pct")) {
      scales::percent(proportion, accuracy = label_args$pct_accuracy)
    }
    labels <- switch(label_style,
      "all"  = sprintf("%s (%s, %s)", names_at, counts, pct),
      "all_wrap" = sprintf("%s\n(%s, %s)", names_at, counts, pct),
      "n"    = sprintf("%s (%s)", names_at, counts),
      "pct"  = sprintf("%s (%s)", names_at, pct),
      "name" = sprintf("%s", names_at)
    )
    node_levels <- if (length(observed)) paste0(".sankey_", i, "_", seq_along(observed)) else character()
    node_labels[[i]] <- stats::setNames(labels, node_levels)
    node_pct[[i]] <- stats::setNames(proportion, node_levels)
    data[[label_vars[i]]] <- node_levels[match(codes, observed)]
  }
  node_counts <- lengths(node_labels)
  node_labels <- unlist(node_labels)
  node_pct <- unlist(node_pct)

  # Reshape plain keys, then restore their order in the shared node column.
  all_levels <- names(node_labels)
  stage <- rep.int(seq_along(label_vars), nrow(data))
  stage_levels <- if (nrow(data)) label_vars else character()
  nodes <- as.character(do.call(rbind, unname(as.list(data[label_vars]))))
  next_stage <- factor(label_vars[stage + 1L], levels = stage_levels)
  next_node <- dplyr::lead(nodes)
  next_node[is.na(next_stage)] <- NA_character_
  plot_data <- tibble::tibble(
    x = factor(label_vars[stage], levels = stage_levels), node = nodes,
    next_x = next_stage, next_node = next_node
  )

  # Set node factor levels
  plot_data$node <- factor(plot_data$node, levels = all_levels)
  plot_data$label <- factor(unname(node_labels[as.character(plot_data$node)]),
                            levels = unique(unname(node_labels)))

  # Generate colours (always as plain character, not palette class)
  if (is.null(palette)) {
    hcl_pals <- c("Blues", "Oranges", "Greens", "Purples", "Reds", "Grays")
    col_list <- lapply(seq_along(vars), function(i) {
      pal_name <- hcl_pals[((i - 1) %% length(hcl_pals)) + 1]
      n_lvs <- node_counts[i]
      grDevices::colorRampPalette(
        as.character(pal_get(paste0("hcl_", pal_name), n = 5))[2:4]
      )(n_lvs)
    })
    mycol <- unlist(col_list)
  } else if (length(palette) == 1 && palette %in% names(palette_list)) {
    mycol <- as.character(pal_get(palette, n = length(all_levels)))
  } else {
    mycol <- rep_len(as.character(palette), length(all_levels))
  }

  # Plot
  geom_args <- list(
    flow.alpha = flow_args$alpha, flow.fill = flow_args$fill,
    flow.color = flow_args$color, smooth = flow_args$smooth,
    width = node_args$width, space = node_args$space, node.color = node_args$color
  )
  if (!is.null(node_args$linewidth)) geom_args$node.linewidth <- node_args$linewidth
  plot <- ggplot2::ggplot(plot_data, ggplot2::aes(
    x = .data[["x"]], next_x = .data[["next_x"]],
    node = .data[["node"]], next_node = .data[["next_node"]],
    fill = factor(.data[["node"]]),
    label = .data[["label"]]
  )) +
    do.call(ggsankey::geom_sankey, geom_args) +
    ggplot2::scale_fill_manual(values = mycol) +
    (if (is.null(theme_use)) ggsankey::theme_sankey(base_size = base_size) else .resolve_theme(theme_use)) +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme(legend.position = "none")

  if (!is.null(var_labels)) {
    plot <- plot + ggplot2::scale_x_discrete(labels = var_labels)
  }

  if (show_text != "none" && any(node_pct >= label_args$min_pct)) {
    # Filter labels only after node positions have been computed from all rows.
    nodes <- plot
    nodes$layers <- plot$layers[2L]
    label_data <- ggplot2::ggplot_build(nodes)$data[[1L]]
    ids <- as.character(label_data$node)
    label_data$x <- plot_data$x[match(ids, as.character(plot_data$node))]
    label_data$label <- unname(node_labels[ids])
    label_data$y <- (label_data$ymin + label_data$ymax) / 2
    keep <- !is.na(label_data$label) & !is.na(node_pct[ids]) &
      node_pct[ids] >= label_args$min_pct
    label_data <- label_data[keep, , drop = FALSE]
    if (nrow(label_data)) {
      label_geom <- if (label_args$box) ggplot2::geom_label else ggplot2::geom_text
      label_params <- list(
        data = label_data,
        mapping = ggplot2::aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
        inherit.aes = FALSE, size = label_args$size, lineheight = label_args$lineheight,
        hjust = label_args$hjust,
        color = label_args$color, alpha = label_args$alpha
      )
      if (label_args$box) label_params$fill <- label_args$fill
      plot <- plot + do.call(label_geom, label_params)
    }
  }
  n_level <- max(observed_levels)
  .save_sized(plot, save, c(max(4, 2 * length(vars)), max(4, 0.5 * n_level)),
              lead = "Sankey diagram laid out for",
              filename = "Figure X. Sankey diagram.pdf")
}
