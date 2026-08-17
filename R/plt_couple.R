#' Correlation heatmap with group-to-variable links
#'
#' Draw an upper-triangle correlation heatmap and connect groups to numeric
#' variables with correlation, Mantel, or model-based importance links.
#'
#' @param data A data frame.
#' @param group A single character column name containing the groups.
#' @param vars Character vector of numeric variable names. If `NULL`, all
#'   numeric columns except `group` are used.
#' @param cor_method Correlation method for the heatmap and correlation or
#'   Mantel links: `"pearson"`, `"spearman"`, or `"kendall"`.
#' @param link_method Link calculation method: `"correlation"`, `"mantel"`,
#'   or `"importance"`.
#' @param model Importance model: `"randomForest"` or `"xgboost"`. Used only
#'   when `link_method = "importance"`.
#' @param n_perm Number of group-label permutations for importance p-values.
#'   Default is 100. Used only when `link_method = "importance"`.
#' @param seed Random seed for importance calculations. Used only when
#'   `link_method = "importance"`.
#' @param fill_colors Three colours for low, midpoint, and high heatmap
#'   correlations.
#' @param line_colors Three colours for low, midpoint, and high link values.
#' @param sig_breaks Increasing p-value thresholds used to classify link
#'   significance.
#' @param sig_sizes Line widths corresponding to the significance classes.
#'   Its length must be `length(sig_breaks) + 1`.
#' @param curvature Curvature passed to [linkET::geom_couple()].
#' @param nudge_x Horizontal link offset passed to
#'   [linkET::geom_couple()].
#' @param diag Logical; whether to display the correlation-matrix diagonal.
#' @param title Optional plot title.
#' @param axis_text_size Size of axis text.
#' @param axis_angle Angle of x-axis text.
#' @param legend_position Position of the legends.
#' @param fill_legend_title Optional heatmap fill legend title.
#' @param line_legend_title Optional link colour legend title.
#' @param sig_legend_title Link-width legend title.
#' @param show_sig_stars Logical; whether to show significance stars on the
#'   correlation heatmap.
#' @param star_size Size of heatmap significance stars.
#' @param star_color Colour of heatmap significance stars.
#' @param geom_type Heatmap geometry: `"shaping"` (default), `"mark"`, or
#'   `"square"`. The square geometry requires ggplot2 older than 4.0.0.
#' @param save Optional named list forwarded to [RegR::save_plt()] for PDF
#'   output. `NULL` or an empty list disables saving. The list can contain
#'   `filename`, `width`, and `height`.
#'
#' @return A ggplot object.
#'
#' @examplesIf requireNamespace("linkET", quietly = TRUE)
#' set.seed(1)
#' n_per_group <- 18L
#' example_group <- factor(
#'   rep(c("Control", "Treatment_1", "Treatment_2", "Treatment_3"),
#'     each = n_per_group
#'   )
#' )
#' group_signal <- rep(c(-1.2, -0.4, 0.4, 1.2), each = n_per_group)
#' n <- length(example_group)
#' latent_signal <- rnorm(n, mean = group_signal, sd = 0.75)
#' example_data <- data.frame(
#'   group = example_group,
#'   metabolite_1 = latent_signal + rnorm(n, sd = 0.35),
#'   metabolite_2 = 0.75 * latent_signal + rnorm(n, sd = 0.55),
#'   metabolite_3 = -0.60 * latent_signal + rnorm(n, sd = 0.65),
#'   cytokine_1 = latent_signal + rnorm(n, sd = 0.45),
#'   cytokine_2 = 0.50 * latent_signal + rnorm(n, sd = 0.80),
#'   cell_score_1 = -0.40 * latent_signal + rnorm(n, sd = 0.70),
#'   cell_score_2 = 0.80 * latent_signal + rnorm(n, sd = 0.50),
#'   phenotype_1 = 0.60 * latent_signal + rnorm(n, sd = 0.60),
#'   phenotype_2 = rnorm(n, mean = 0.30 * group_signal, sd = 0.90),
#'   outcome_score = 0.90 * latent_signal + rnorm(n, sd = 0.40)
#' )
#' plt_couple(
#'   example_data,
#'   group = "group",
#'   title = "Simulated multi-domain associations"
#' )
#'
#' # A clinical-style example adapted from `figure1b_reproduction.R`.
#' set.seed(2024)
#' n_total <- 2612L
#' n_A <- round(n_total * 0.141)
#' n_B <- round(n_total * 0.176)
#' n_C <- round(n_total * 0.270)
#' group_sizes <- c(
#'   A = n_A,
#'   B = n_B,
#'   C = n_C,
#'   D = n_total - n_A - n_B - n_C
#' )
#' phenotype <- factor(rep(names(group_sizes), group_sizes))
#' generate_phenotype_data <- function(means, sd_val) {
#'   unlist(
#'     Map(
#'       function(n, mean) rnorm(n, mean = mean, sd = sd_val),
#'       n = unname(group_sizes),
#'       mean = means
#'     ),
#'     use.names = FALSE
#'   )
#' }
#' clinical_data <- data.frame(
#'   phenotype = phenotype,
#'   HR = generate_phenotype_data(c(115, 95, 100, 85), sd_val = 15),
#'   RR = generate_phenotype_data(c(24, 20, 21, 18), sd_val = 4),
#'   SBP = generate_phenotype_data(c(125, 145, 105, 120), sd_val = 18),
#'   DBP = generate_phenotype_data(c(75, 90, 65, 72), sd_val = 12)
#' )
#' plt_couple(
#'   clinical_data,
#'   group = "phenotype",
#'   title = "Clinical variables across simulated subphenotypes"
#' )
#'
#' @export
#' @family plot
plt_couple <- function(
  data,
  group,
  vars = NULL,
  cor_method = c("pearson", "spearman", "kendall"),
  link_method = c("correlation", "mantel", "importance"),
  model = c("randomForest", "xgboost"),
  n_perm = 100L,
  seed = 2024L,
  fill_colors = c("#FDE725", "white", "#440154"),
  line_colors = c("#FDE725", "white", "#440154"),
  sig_breaks = c(0.001, 0.01, 0.05),
  sig_sizes = c(1.5, 1.0, 0.5, 0.15),
  curvature = 0.05,
  nudge_x = 0.2,
  diag = FALSE,
  title = NULL,
  axis_text_size = 10,
  axis_angle = 45,
  legend_position = "right",
  fill_legend_title = NULL,
  line_legend_title = NULL,
  sig_legend_title = "Significance",
  show_sig_stars = TRUE,
  star_size = 3.5,
  star_color = "black",
  geom_type = c("shaping", "mark", "square"),
  save = list()
) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  if (
    !is.character(group) ||
      length(group) != 1L ||
      is.na(group) ||
      !nzchar(group)
  ) {
    cli::cli_abort("{.arg group} must be one non-empty column name.")
  }
  if (!group %in% names(data)) {
    cli::cli_abort("Group column {.val {group}} was not found in {.arg data}.")
  }

  if (is.null(vars)) {
    vars <- names(data)[vapply(data, is.numeric, logical(1))]
    vars <- setdiff(vars, group)
  }
  if (
    !is.character(vars) ||
      length(vars) < 2L ||
      anyNA(vars) ||
      any(!nzchar(vars))
  ) {
    cli::cli_abort("{.arg vars} must contain at least two column names.")
  }
  if (anyDuplicated(vars)) {
    cli::cli_abort("{.arg vars} must not contain duplicated column names.")
  }
  missing_vars <- setdiff(vars, names(data))
  if (length(missing_vars) > 0L) {
    cli::cli_abort("Variables not found in {.arg data}: {.val {missing_vars}}")
  }
  is_numeric <- vapply(data[vars], is.numeric, logical(1))
  if (any(!is_numeric)) {
    cli::cli_abort("All variables in {.arg vars} must be numeric.")
  }

  selected <- data[c(group, vars)]
  if (anyNA(selected)) {
    cli::cli_abort(
      "{.arg data} contains missing values in {.arg group} or {.arg vars}."
    )
  }
  finite_numeric <- vapply(
    selected,
    function(x) !is.numeric(x) || all(is.finite(x)),
    logical(1)
  )
  if (any(!finite_numeric)) {
    cli::cli_abort(
      "Numeric group or analysis variables must contain finite values."
    )
  }
  variable_n_unique <- vapply(
    data[vars],
    function(x) length(unique(x)),
    integer(1)
  )
  if (any(variable_n_unique < 2L)) {
    cli::cli_abort(
      "Each variable in {.arg vars} must contain at least two values."
    )
  }

  if (is.factor(data[[group]])) {
    group_factor <- droplevels(data[[group]])
  } else {
    group_factor <- factor(as.character(data[[group]]))
  }
  group_levels <- levels(group_factor)
  if (length(group_levels) < 2L) {
    cli::cli_abort("{.arg group} must contain at least two groups.")
  }
  group_counts <- table(group_factor)
  if (any(group_counts < 2L)) {
    cli::cli_abort("Each group must contain at least two observations.")
  }

  cor_method <- match.arg(cor_method)
  link_method <- match.arg(link_method)
  geom_type <- match.arg(geom_type)

  if (
    !is.character(fill_colors) ||
      length(fill_colors) != 3L ||
      anyNA(fill_colors)
  ) {
    cli::cli_abort("{.arg fill_colors} must contain exactly three colours.")
  }
  if (
    !is.character(line_colors) ||
      length(line_colors) != 3L ||
      anyNA(line_colors)
  ) {
    cli::cli_abort("{.arg line_colors} must contain exactly three colours.")
  }
  if (
    !is.numeric(sig_breaks) ||
      length(sig_breaks) < 1L ||
      any(!is.finite(sig_breaks)) ||
      any(sig_breaks <= 0 | sig_breaks >= 1) ||
      any(diff(sig_breaks) <= 0)
  ) {
    cli::cli_abort(
      "{.arg sig_breaks} must be strictly increasing values between 0 and 1."
    )
  }
  if (
    !is.numeric(sig_sizes) ||
      length(sig_sizes) != length(sig_breaks) + 1L ||
      any(!is.finite(sig_sizes)) ||
      any(sig_sizes <= 0)
  ) {
    cli::cli_abort(
      "{.arg sig_sizes} must contain one positive value per significance class."
    )
  }
  if (
    !is.numeric(curvature) || length(curvature) != 1L || !is.finite(curvature)
  ) {
    cli::cli_abort("{.arg curvature} must be one finite numeric value.")
  }
  if (!is.numeric(nudge_x) || length(nudge_x) != 1L || !is.finite(nudge_x)) {
    cli::cli_abort("{.arg nudge_x} must be one finite numeric value.")
  }
  if (!is.null(save) && length(save) > 0L && !is.list(save)) {
    cli::cli_abort("{.arg save} must be `NULL` or a list.")
  }

  .plt_couple_require("linkET")
  if (link_method == "mantel") {
    .plt_couple_require("vegan")
  }
  if (link_method == "importance") {
    model <- match.arg(model)
    if (
      !is.numeric(n_perm) ||
        length(n_perm) != 1L ||
        !is.finite(n_perm) ||
        n_perm < 1 ||
        n_perm != as.integer(n_perm)
    ) {
      cli::cli_abort("{.arg n_perm} must be a positive integer.")
    }
    if (!is.numeric(seed) || length(seed) != 1L || !is.finite(seed)) {
      cli::cli_abort("{.arg seed} must be one finite numeric value.")
    }
    .plt_couple_require(model)
    .plt_couple_require("withr")
  }

  clinical_data <- data[vars]
  cor_matrix <- linkET::correlate(
    x = clinical_data,
    method = cor_method,
    use = "complete.obs"
  )

  if (link_method == "correlation") {
    link_df <- .plt_couple_correlation_links(
      clinical_data = clinical_data,
      group_factor = group_factor,
      group_levels = group_levels,
      vars = vars,
      cor_method = cor_method
    )
    link_value <- "r"
    link_label <- switch(
      cor_method,
      pearson = "Pearson's r",
      spearman = "Spearman's rho",
      kendall = "Kendall's tau"
    )
  } else if (link_method == "mantel") {
    link_df <- .plt_couple_mantel_links(
      clinical_data = clinical_data,
      group_factor = group_factor,
      group_levels = group_levels,
      vars = vars,
      cor_method = cor_method
    )
    link_value <- "r"
    link_label <- switch(
      cor_method,
      pearson = "Pearson's r",
      spearman = "Spearman's rho",
      kendall = "Kendall's tau"
    )
  } else {
    importance <- .plt_couple_importance(
      clinical_data = clinical_data,
      group_factor = group_factor,
      group_levels = group_levels,
      vars = vars,
      model = model,
      n_perm = as.integer(n_perm),
      seed = as.integer(seed)
    )
    link_df <- .plt_couple_importance_links(
      importance = importance,
      group_levels = group_levels,
      vars = vars
    )
    link_value <- "importance"
    link_label <- "Variable importance"
  }

  sig_labels <- c(
    paste0("p < ", sig_breaks),
    paste0("p >= ", sig_breaks[length(sig_breaks)])
  )
  link_df$sig_label <- cut(
    link_df$p.value,
    breaks = c(0, sig_breaks, 1),
    labels = sig_labels,
    include.lowest = TRUE
  )
  link_df$sig_label <- factor(link_df$sig_label, levels = sig_labels)
  class(link_df) <- c("mantel_tbl", class(link_df))
  names(sig_sizes) <- sig_labels

  if (
    geom_type == "square" &&
      utils::packageVersion("ggplot2") >= numeric_version("4.0.0")
  ) {
    cli::cli_abort(
      "{.arg geom_type = 'square'} requires ggplot2 older than version 4.0.0."
    )
  }
  geom_layer <- switch(
    geom_type,
    shaping = linkET::geom_shaping(marker = "square"),
    mark = linkET::geom_mark(size = 5),
    square = linkET::geom_square()
  )

  cor_label <- switch(
    cor_method,
    pearson = "Pearson's r",
    spearman = "Spearman's rho",
    kendall = "Kendall's tau"
  )
  if (is.null(fill_legend_title)) {
    fill_legend_title <- paste0(cor_label, "\n(variables)")
  }
  if (is.null(line_legend_title)) {
    line_legend_title <- if (link_method == "importance") {
      "Importance\n(groups)"
    } else {
      paste0(cor_label, "\n(groups)")
    }
  }

  p <- suppressWarnings(
    linkET::qcorrplot(cor_matrix, type = "upper", diag = diag) +
      geom_layer +
      linkET::geom_couple(
        data = link_df,
        mapping = ggplot2::aes(
          colour = .data[[link_value]],
          size = .data[["sig_label"]]
        ),
        curvature = curvature,
        nudge_x = nudge_x
      )
  )

  if (isTRUE(show_sig_stars)) {
    star_data <- .plt_couple_heatmap_stars(cor_matrix, vars)
    p <- p +
      ggplot2::geom_text(
        data = star_data,
        mapping = ggplot2::aes(x = x, y = y, label = label),
        inherit.aes = FALSE,
        size = star_size,
        colour = star_color
      )
  }

  p <- p +
    ggplot2::scale_fill_gradient2(
      name = fill_legend_title,
      low = fill_colors[1L],
      mid = fill_colors[2L],
      high = fill_colors[3L],
      midpoint = 0,
      limits = c(-1, 1)
    )

  if (link_method == "importance") {
    p <- p +
      ggplot2::scale_colour_gradientn(
        name = line_legend_title,
        colours = line_colors,
        values = c(0, 0.5, 1),
        limits = c(0, 1)
      )
  } else {
    p <- p +
      ggplot2::scale_colour_gradient2(
        name = line_legend_title,
        low = line_colors[1L],
        mid = line_colors[2L],
        high = line_colors[3L],
        midpoint = 0,
        limits = c(-1, 1)
      )
  }

  p <- p +
    ggplot2::scale_size_manual(
      name = sig_legend_title,
      values = sig_sizes,
      drop = FALSE
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = axis_angle,
        hjust = 1,
        size = axis_text_size,
        colour = "black"
      ),
      axis.text.y = ggplot2::element_text(
        size = axis_text_size,
        colour = "black"
      ),
      legend.position = legend_position,
      legend.title = ggplot2::element_text(size = 10, face = "bold"),
      legend.text = ggplot2::element_text(size = 9),
      panel.grid = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )

  if (!is.null(title)) {
    p <- p + ggplot2::labs(title = title)
  }

  if (!is.null(save) && length(save) > 0L) {
    .plt_couple_require("RegR")
    do.call(RegR::save_plt, c(list(plot = p), save))
  }

  p
}

.plt_couple_require <- function(package) {
  if (!suppressWarnings(requireNamespace(package, quietly = TRUE))) {
    cli::cli_abort(
      "Package {.pkg {package}} is required for {.arg plt_couple()}.",
      i = "Install it before using this plotting mode."
    )
  }
}

.plt_couple_correlation_links <- function(
  clinical_data,
  group_factor,
  group_levels,
  vars,
  cor_method
) {
  link_list <- vector("list", length(group_levels) * length(vars))
  index <- 0L
  for (group_index in seq_along(group_levels)) {
    group_indicator <- as.integer(group_factor == group_levels[group_index])
    for (variable_index in seq_along(vars)) {
      index <- index + 1L
      result <- suppressWarnings(stats::cor.test(
        group_indicator,
        clinical_data[[vars[variable_index]]],
        method = cor_method,
        exact = FALSE
      ))
      link_list[[index]] <- data.frame(
        spec = group_levels[group_index],
        env = vars[variable_index],
        r = unname(as.numeric(result$estimate)),
        p.value = result$p.value,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, link_list)
}

.plt_couple_mantel_links <- function(
  clinical_data,
  group_factor,
  group_levels,
  vars,
  cor_method
) {
  link_list <- vector("list", length(group_levels) * length(vars))
  index <- 0L
  for (group_index in seq_along(group_levels)) {
    group_distance <- stats::dist(
      as.integer(group_factor == group_levels[group_index])
    )
    for (variable_index in seq_along(vars)) {
      index <- index + 1L
      variable_distance <- stats::dist(
        clinical_data[[vars[variable_index]]]
      )
      result <- vegan::mantel(
        group_distance,
        variable_distance,
        method = cor_method,
        permutations = 999
      )
      link_list[[index]] <- data.frame(
        spec = group_levels[group_index],
        env = vars[variable_index],
        r = unname(as.numeric(result$statistic)),
        p.value = result$signif,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, link_list)
}

.plt_couple_fit_random_forest <- function(
  clinical_data,
  group_factor,
  group_levels,
  vars
) {
  fit <- randomForest::randomForest(
    x = clinical_data,
    y = group_factor,
    ntree = 500L,
    importance = TRUE,
    localImp = TRUE
  )
  local_importance <- fit$localImportance
  if (is.null(local_importance) || is.null(rownames(local_importance))) {
    cli::cli_abort("Random Forest did not return local variable importance.")
  }
  if (!all(vars %in% rownames(local_importance))) {
    cli::cli_abort("Random Forest returned incomplete variable importance.")
  }
  local_importance <- local_importance[vars, , drop = FALSE]
  result <- matrix(
    0,
    nrow = length(group_levels),
    ncol = length(vars),
    dimnames = list(group_levels, vars)
  )
  for (group_index in seq_along(group_levels)) {
    columns <- group_factor == group_levels[group_index]
    result[group_index, ] <- rowMeans(
      local_importance[, columns, drop = FALSE],
      na.rm = TRUE
    )
  }
  result[!is.finite(result)] <- 0
  result
}

.plt_couple_fit_xgboost <- function(
  clinical_data,
  group_factor,
  group_levels,
  vars
) {
  x_matrix <- as.matrix(clinical_data)
  result <- matrix(
    0,
    nrow = length(group_levels),
    ncol = length(vars),
    dimnames = list(group_levels, vars)
  )
  params <- list(
    objective = "binary:logistic",
    eval_metric = "auc",
    max_depth = 4L,
    eta = 0.1,
    nthread = 1L,
    verbosity = 0L
  )
  for (group_index in seq_along(group_levels)) {
    label <- as.integer(group_factor == group_levels[group_index])
    training_data <- xgboost::xgb.DMatrix(data = x_matrix, label = label)
    fit <- xgboost::xgb.train(
      params = params,
      data = training_data,
      nrounds = 100L,
      verbose = 0L
    )
    importance <- xgboost::xgb.importance(
      model = fit,
      feature_names = vars
    )
    if (nrow(importance) > 0L) {
      feature_column <- if ("Features" %in% names(importance)) {
        "Features"
      } else {
        "Feature"
      }
      positions <- match(importance[[feature_column]], vars)
      valid <- !is.na(positions)
      result[group_index, positions[valid]] <- importance[["Gain"]][valid]
    }
  }
  result[!is.finite(result)] <- 0
  result
}

.plt_couple_importance <- function(
  clinical_data,
  group_factor,
  group_levels,
  vars,
  model,
  n_perm,
  seed
) {
  fit_once <- switch(
    model,
    randomForest = function(groups) {
      .plt_couple_fit_random_forest(
        clinical_data = clinical_data,
        group_factor = groups,
        group_levels = group_levels,
        vars = vars
      )
    },
    xgboost = function(groups) {
      .plt_couple_fit_xgboost(
        clinical_data = clinical_data,
        group_factor = groups,
        group_levels = group_levels,
        vars = vars
      )
    }
  )

  withr::with_seed(seed, {
    observed <- fit_once(group_factor)
    null_importance <- array(
      0,
      dim = c(n_perm, length(group_levels), length(vars))
    )
    for (permutation in seq_len(n_perm)) {
      shuffled_groups <- group_factor[sample.int(length(group_factor))]
      null_importance[permutation, , ] <- fit_once(shuffled_groups)
    }

    p_values <- matrix(
      1,
      nrow = length(group_levels),
      ncol = length(vars),
      dimnames = list(group_levels, vars)
    )
    for (group_index in seq_along(group_levels)) {
      for (variable_index in seq_along(vars)) {
        observed_value <- observed[group_index, variable_index]
        null_values <- null_importance[, group_index, variable_index]
        p_values[group_index, variable_index] <- (1 +
          sum(null_values >= observed_value)) /
          (n_perm + 1)
      }
    }

    scaled <- observed
    for (group_index in seq_along(group_levels)) {
      values <- observed[group_index, ]
      value_range <- range(values)
      if (diff(value_range) <= .Machine$double.eps) {
        scaled[group_index, ] <- 0
      } else {
        scaled[group_index, ] <- (values - value_range[1L]) / diff(value_range)
      }
    }

    list(raw = observed, scaled = scaled, p.value = p_values)
  })
}

.plt_couple_importance_links <- function(importance, group_levels, vars) {
  data.frame(
    spec = rep(group_levels, each = length(vars)),
    env = rep(vars, times = length(group_levels)),
    importance = as.vector(t(importance$scaled)),
    p.value = as.vector(t(importance$p.value)),
    stringsAsFactors = FALSE
  )
}

.plt_couple_heatmap_stars <- function(cor_matrix, vars) {
  p_values <- cor_matrix[["p"]]
  if (is.null(p_values)) {
    return(data.frame(x = numeric(), y = numeric(), label = character()))
  }
  pairs <- expand.grid(
    row = seq_along(vars),
    col = seq_along(vars),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  pairs <- pairs[pairs$col > pairs$row, , drop = FALSE]
  pairs$p.value <- mapply(
    function(row, col) p_values[row, col],
    pairs$row,
    pairs$col
  )
  pairs$label <- ifelse(
    pairs$p.value <= 0.001,
    "***",
    ifelse(pairs$p.value <= 0.01, "**", ifelse(pairs$p.value <= 0.05, "*", ""))
  )
  pairs <- pairs[nzchar(pairs$label), , drop = FALSE]
  data.frame(
    x = pairs$col,
    y = length(vars) - pairs$row + 1L,
    label = pairs$label,
    stringsAsFactors = FALSE
  )
}
