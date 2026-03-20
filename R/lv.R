# ============================================================================
# lv.R -- Variable inspection S3 generic and methods
# ============================================================================

#' @title Variable Inspection Generic Function
#'
#' @description
#' Inspect variables in a data.frame or Seurat object, including frequency
#' counts, unique values, missing values and special values (e.g. "unknown",
#' "blank", "n/a"). Supports grouped summaries and multi-variable
#' cross-tabulation.
#'
#' @param data A data object: data.frame or Seurat object.
#' @param ... Variable selection using \code{dplyr::select} syntax.
#' @param pattern Optional regex pattern for matching variable names.
#' @param group Optional grouping variable. Supports NSE (bare name) or
#'   character string. For Seurat objects, set to \code{TRUE} to use current
#'   Ident.
#' @param count Optional variable(s) for cross-tabulation. Accepts a single
#'   variable name (NSE or string), multiple variable names via
#'   \code{c(var1, var2)} (NSE) or character vector
#'   \code{c("var1", "var2")}. Independent of \code{group}.
#'
#' @return Invisibly returns the input data.
#'
#' @examples
#' \dontrun{
#' # data.frame basic usage
#' lv(mtcars)
#' lv(mtcars, mpg, cyl, hp)
#' lv(mtcars, pattern = "mpg")
#'
#' # Grouped view (supports NSE)
#' lv(mtcars, mpg, hp, wt, group = cyl)
#' lv(mtcars, mpg, hp, wt, group = "cyl")
#'
#' # Cross-tabulation
#' lv(mtcars, count = cyl)
#' lv(mtcars, count = c(cyl, gear))
#' lv(mtcars, count = c("cyl", "gear"))
#'
#' # Seurat object
#' lv(seurat_obj)
#' lv(seurat_obj, group = TRUE)
#' lv(seurat_obj, count = c(seurat_clusters, Phase))
#' }
#'
#' @export
#' @family inspect
lv <- function(data, ...) {
  UseMethod("lv")
}

#' @rdname lv
#' @export
#' @family inspect
lv.default <- function(data, ..., pattern = NULL, group = NULL, count = NULL) {
  # Process group argument
  group_var <- NULL
  group_sub <- substitute(group)

  if (!is.null(group_sub) && !identical(group_sub, quote(NULL))) {
    if (is.character(group_sub)) {
      group_var <- group_sub
    } else if (is.symbol(group_sub)) {
      sym_name <- as.character(group_sub)
      caller_env <- parent.frame()
      if (exists(sym_name, envir = caller_env, inherits = FALSE)) {
        val <- get(sym_name, envir = caller_env, inherits = FALSE)
        if (is.character(val) && length(val) == 1) {
          group_var <- val
        }
      } else {
        group_var <- sym_name
      }
    }
  }

  # Process count argument
  count_vars <- NULL
  count_sub <- substitute(count)

  if (!is.null(count_sub) && !identical(count_sub, quote(NULL))) {
    if (is.character(count_sub)) {
      count_vars <- count_sub
    } else if (is.symbol(count_sub)) {
      sym_name <- as.character(count_sub)
      caller_env <- parent.frame()
      if (exists(sym_name, envir = caller_env, inherits = FALSE)) {
        val <- get(sym_name, envir = caller_env, inherits = FALSE)
        if (is.character(val)) {
          count_vars <- val
        }
      } else {
        count_vars <- sym_name
      }
    } else if (is.call(count_sub) && identical(count_sub[[1]], quote(c))) {
      args <- as.list(count_sub)[-1]
      if (length(args) > 0 && is.character(args[[1]])) {
        count_vars <- eval(count_sub, envir = parent.frame())
      } else {
        count_vars <- vapply(args, as.character, character(1))
      }
    }
  }

  lv.data.frame(as.data.frame(data), ..., pattern = pattern,
                group = group_var, count = count_vars)
}

#' @rdname lv
#' @export
#' @family inspect
lv.data.frame <- function(data, ..., pattern = NULL, group = NULL, count = NULL) {

  # Process group argument: support NSE and character string
  group_var <- NULL
  group_sub <- substitute(group)

  if (!is.null(group_sub) && !identical(group_sub, quote(NULL))) {
    if (is.character(group_sub)) {
      group_var <- group_sub
    } else if (is.symbol(group_sub)) {
      sym_name <- as.character(group_sub)
      caller_env <- parent.frame()
      if (exists(sym_name, envir = caller_env, inherits = FALSE)) {
        val <- get(sym_name, envir = caller_env, inherits = FALSE)
        if (is.character(val) && length(val) == 1) {
          group_var <- val
        }
      } else {
        group_var <- sym_name
      }
    }
  }

  # Process count argument
  count_vars <- NULL
  count_sub <- substitute(count)

  if (!is.null(count_sub) && !identical(count_sub, quote(NULL))) {
    if (is.character(count_sub)) {
      count_vars <- count_sub
    } else if (is.symbol(count_sub)) {
      sym_name <- as.character(count_sub)
      caller_env <- parent.frame()
      if (exists(sym_name, envir = caller_env, inherits = FALSE)) {
        val <- get(sym_name, envir = caller_env, inherits = FALSE)
        if (is.character(val)) {
          count_vars <- val
        }
      } else {
        count_vars <- sym_name
      }
    } else if (is.call(count_sub) && identical(count_sub[[1]], quote(c))) {
      args <- as.list(count_sub)[-1]
      if (length(args) > 0 && is.character(args[[1]])) {
        count_vars <- eval(count_sub, envir = parent.frame())
      } else {
        count_vars <- vapply(args, as.character, character(1))
      }
    }
  }

  # ==========================================================================
  # Internal helper functions
  # ==========================================================================

  .count_special_values <- function(x) {
    if (is.factor(x) || is.character(x)) {
      x_clean <- tolower(as.character(x))
      special_patterns <- c("unknown", "blank", "n/a", "na", "missing",
                            "unspecified", "not available")
      count <- 0
      for (p in special_patterns) {
        count <- count + sum(grepl(p, x_clean, fixed = TRUE), na.rm = TRUE)
      }
      count <- count + sum(x_clean == "", na.rm = TRUE)
      return(count)
    } else {
      return(0L)
    }
  }

  .get_levels <- function(x) {
    if (is.factor(x)) {
      levels(x)
    } else {
      unique(x[!is.na(x)])
    }
  }

  .lv_one <- function(data, var) {
    col_data <- data[[var]]
    var_class <- class(col_data)[1]

    cli::cli_h1(
      cli::col_br_white(
        cli::bg_cyan(
          sprintf("** summary for %s (%s) **", var, var_class)
        )
      )
    )

    cat(sprintf("----1. %s (%s) count----------\n", var, var_class))
    data %>%
      tibble::as_tibble() %>%
      dplyr::count(.data[[var]]) %>%
      print()

    cat(sprintf("----2. %s (%s) %s----------\n",
                var, var_class,
                if (is.factor(col_data)) "Levels" else "unique"))

    unique_values <- .get_levels(col_data)
    n_unique <- length(unique_values)
    n_na <- sum(is.na(col_data))

    display_values <- if (n_unique > 10) {
      c(head(unique_values, 8), "...")
    } else {
      unique_values
    }

    .get_flt_formula <- noquote(
      sprintf('.get.flt(%s %%in%% c("%s"))',
              var,
              paste(display_values, collapse = '","'))
    )
    print(.get_flt_formula)

    if (n_unique > 10) {
      unique_display <- paste(c(head(unique_values, 8), "..."), collapse = ", ")
    } else {
      unique_display <- paste(unique_values, collapse = ", ")
    }

    tibble::tibble(
      vars = var,
      class = var_class,
      n_unique = n_unique,
      n_na = n_na,
      n_special = .count_special_values(col_data),
      unique = .get_flt_formula
    )
  }

  .gt_highlight_low_percentage <- function(gt_tbl,
                                           color_lt10 = "lightgreen",
                                           color_lt5 = "#FFFF00",
                                           color_lt1 = "#FF4D4D",
                                           columns = NULL) {
    if (!inherits(gt_tbl, "gt_tbl") || is.null(gt_tbl$`_data`)) return(gt_tbl)

    df_data <- as.data.frame(gt_tbl$`_data`)
    col_names <- names(df_data)

    if (is.null(columns)) {
      target_cols <- col_names
    } else if (is.numeric(columns)) {
      target_cols <- col_names[columns[columns >= 1 & columns <= length(col_names)]]
    } else if (is.character(columns)) {
      target_cols <- intersect(columns, col_names)
    } else {
      target_cols <- col_names
    }

    for (j in seq_along(df_data)) {
      col_values <- df_data[[j]]
      if (!(col_names[j] %in% target_cols)) next
      if (is.character(col_values) || is.factor(col_values)) {
        col_chr <- as.character(col_values)
        has_pct <- grepl("%", col_chr, fixed = TRUE)
        if (any(has_pct, na.rm = TRUE)) {
          perc_str <- ifelse(
            grepl("\\([0-9.]+%\\)", col_chr),
            sub(".*\\(([0-9.]+)%\\).*", "\\1", col_chr),
            sub(".*?([0-9.]+)%.*", "\\1", col_chr)
          )
          perc_num <- suppressWarnings(as.numeric(perc_str))
          rows_lt1 <- which(!is.na(perc_num) & perc_num < 1)
          rows_lt5 <- which(!is.na(perc_num) & perc_num >= 1 & perc_num < 5)
          rows_lt10 <- which(!is.na(perc_num) & perc_num >= 5 & perc_num < 10)

          if (length(rows_lt1) > 0) {
            gt_tbl <- gt_tbl %>%
              gt::tab_style(
                style = gt::cell_fill(color = color_lt1),
                locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                           rows = rows_lt1)
              )
          }
          if (length(rows_lt5) > 0) {
            gt_tbl <- gt_tbl %>%
              gt::tab_style(
                style = gt::cell_fill(color = color_lt5),
                locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                           rows = rows_lt5)
              )
          }
          if (length(rows_lt10) > 0) {
            gt_tbl <- gt_tbl %>%
              gt::tab_style(
                style = gt::cell_fill(color = color_lt10),
                locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                           rows = rows_lt10)
              )
          }
        }
      }
    }
    gt_tbl
  }

  .gt_highlight_special_values <- function(gt_tbl,
                                           color_missing = "#FF4D4D",
                                           color_blank = "#FFFF00",
                                           color_unknown = "#FFFF00",
                                           color_na = "#FFFF00",
                                           columns = NULL) {
    if (!inherits(gt_tbl, "gt_tbl") || is.null(gt_tbl$`_data`)) return(gt_tbl)

    df_data <- as.data.frame(gt_tbl$`_data`)
    col_names <- names(df_data)

    if (is.null(columns)) {
      target_cols <- col_names
    } else if (is.numeric(columns)) {
      target_cols <- col_names[columns[columns >= 1 & columns <= length(col_names)]]
    } else if (is.character(columns)) {
      target_cols <- intersect(columns, col_names)
    } else {
      target_cols <- col_names
    }

    for (j in seq_along(df_data)) {
      col_values <- df_data[[j]]
      if (!(col_names[j] %in% target_cols)) next
      if (is.character(col_values) || is.factor(col_values)) {
        col_chr <- as.character(col_values)

        rows_missing <- which(grepl("\u7f3a\u5931", col_chr, fixed = TRUE))
        rows_blank <- which(grepl("blank", col_chr, ignore.case = TRUE))
        rows_unknown <- which(grepl("unknown", col_chr, ignore.case = TRUE))
        rows_na <- which(grepl("\\bn/?a\\b", col_chr, ignore.case = TRUE))

        if (length(rows_missing) > 0) {
          gt_tbl <- gt_tbl %>%
            gt::tab_style(
              style = gt::cell_fill(color = color_missing),
              locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                         rows = rows_missing)
            )
        }
        if (length(rows_blank) > 0) {
          gt_tbl <- gt_tbl %>%
            gt::tab_style(
              style = gt::cell_fill(color = color_blank),
              locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                         rows = rows_blank)
            )
        }
        if (length(rows_unknown) > 0) {
          gt_tbl <- gt_tbl %>%
            gt::tab_style(
              style = gt::cell_fill(color = color_unknown),
              locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                         rows = rows_unknown)
            )
        }
        if (length(rows_na) > 0) {
          gt_tbl <- gt_tbl %>%
            gt::tab_style(
              style = gt::cell_fill(color = color_na),
              locations = gt::cells_body(columns = dplyr::all_of(col_names[j]),
                                         rows = rows_na)
            )
        }
      }
    }
    gt_tbl
  }

  # ==========================================================================
  # Main logic
  # ==========================================================================

  # Variable selection
  if (!is.null(pattern)) {
    vars <- names(data)[grepl(pattern, names(data), ignore.case = TRUE)]
  } else {
    vars <- names(dplyr::select(data, ...))
  }

  if (length(vars) == 0) {
    if (!is.null(pattern)) {
      cli::cli_alert_warning(
        "\u672a\u627e\u5230\u5339\u914d\u6a21\u5f0f '{pattern}' \u7684\u53d8\u91cf\uff0c\u5c06\u5206\u6790\u6240\u6709\u53d8\u91cf"
      )
    }
    vars <- names(data)
  }

  # ==========================================================================
  # Count mode
  # ==========================================================================
  if (!is.null(count_vars)) {
    missing_vars <- setdiff(count_vars, names(data))
    if (length(missing_vars) > 0) {
      cli::cli_abort("\u53d8\u91cf {.var {missing_vars}} \u4e0d\u5b58\u5728\u4e8e\u6570\u636e\u4e2d")
    }

    count_title <- paste(count_vars, collapse = " \u00d7 ")
    cli::cli_h1(cli::col_cyan(glue::glue("Cross-tabulation: {count_title}")))
    cli::cli_alert_info("Variables: {.val {paste(count_vars, collapse = ', ')}}")

    cross_count <- data %>%
      dplyr::count(dplyr::across(dplyr::all_of(count_vars))) %>%
      dplyr::arrange(dplyr::across(dplyr::all_of(count_vars)))

    cross_count <- cross_count %>%
      dplyr::mutate(
        pct = round(n / sum(n) * 100, 2),
        n_pct = glue::glue("{n} ({pct}%)")
      )

    print(tibble::as_tibble(cross_count))

    if (length(count_vars) == 2) {
      cli::cli_h2(cli::col_yellow("Wide Format Table"))

      cross_wide <- data %>%
        dplyr::count(dplyr::across(dplyr::all_of(count_vars))) %>%
        tidyr::pivot_wider(
          names_from = dplyr::all_of(count_vars[2]),
          values_from = "n",
          values_fill = 0
        )

      cross_wide <- cross_wide %>%
        dplyr::mutate(Total = rowSums(dplyr::pick(-1)))

      print(tibble::as_tibble(cross_wide))

      cross_gt <- cross_wide %>%
        gt::gt(rowname_col = count_vars[1]) %>%
        gt::tab_header(
          title = gt::md(glue::glue("**{count_vars[1]} \u00d7 {count_vars[2]}**")),
          subtitle = gt::md(glue::glue("Cross-tabulation (n = {nrow(data)})"))
        ) %>%
        gt::tab_stubhead(label = gt::md(glue::glue("**{count_vars[1]}**"))) %>%
        gt::grand_summary_rows(
          columns = where(is.numeric),
          fns = list(Total = ~ sum(.)),
          fmt = ~ gt::fmt_integer(.)
        ) %>%
        gtExtras::gt_theme_excel() %>%
        gt::tab_options(
          column_labels.background.color = "#E8F4FD",
          heading.background.color = "#F0F8FF",
          stub.background.color = "#F5F5F5"
        )

      print(cross_gt)

      cli::cli_h3(cli::col_yellow("Row Percentages (%)"))

      cross_pct <- data %>%
        dplyr::count(dplyr::across(dplyr::all_of(count_vars))) %>%
        dplyr::group_by(.data[[count_vars[1]]]) %>%
        dplyr::mutate(pct = round(n / sum(n) * 100, 1)) %>%
        dplyr::ungroup() %>%
        dplyr::select(-"n") %>%
        tidyr::pivot_wider(
          names_from = dplyr::all_of(count_vars[2]),
          values_from = "pct",
          values_fill = 0
        )

      print(tibble::as_tibble(cross_pct))
    }

    cli::cli_rule()
    return(invisible(data))
  }

  # ==========================================================================
  # Grouped mode
  # ==========================================================================
  if (!is.null(group_var)) {
    if (!group_var %in% names(data)) {
      cli::cli_abort("\u53d8\u91cf {.var {group_var}} \u4e0d\u5b58\u5728\u4e8e\u6570\u636e\u4e2d")
    }

    vars <- setdiff(vars, group_var)
    if (length(vars) == 0) {
      vars <- setdiff(names(data), group_var)
    }

    cli::cli_h1(cli::col_magenta(glue::glue("Variable Summary by {group_var}")))

    n_groups <- length(unique(data[[group_var]]))
    cli::cli_alert_info("Groups: {.val {n_groups}}")

    gtsummary::theme_gtsummary_compact()

    res_grouped <-
      tibble::as_tibble(data)[, c(group_var, vars), drop = FALSE] %>%
      gtsummary::tbl_summary(
        by = dplyr::all_of(group_var),
        type = list(
          gtsummary::all_continuous() ~ "continuous2",
          gtsummary::all_categorical() ~ "categorical"
        ),
        statistic = list(
          gtsummary::all_continuous() ~ c("{median} [{p25}, {p75}]"),
          gtsummary::all_categorical() ~ "{n} ({p}%)"
        ),
        missing_text = "\u7f3a\u5931"
      ) %>%
      gtsummary::bold_labels() %>%
      gtsummary::add_overall()

    print(res_grouped)

    gtsummary::reset_gtsummary_theme()

    return(invisible(data))
  }

  # ==========================================================================
  # Default mode (no group, no count)
  # ==========================================================================

  result <- purrr::map_dfr(vars, ~ .lv_one(data, .x))

  gtsummary::theme_gtsummary_compact()

  res_count <-
    tibble::as_tibble(data)[, vars, drop = FALSE] %>%
    labelled::set_variable_labels(
      .labels = setNames(
        paste0(
          vars, " (",
          vapply(data[vars], function(x) class(x)[1], character(1)), ", ",
          vapply(data[vars], function(x) length(unique(x[!is.na(x)])), integer(1)),
          ")"
        ),
        vars
      )
    ) %>%
    gtsummary::tbl_summary(
      type = list(
        gtsummary::all_continuous() ~ "continuous2",
        gtsummary::all_categorical() ~ "categorical"
      ),
      statistic = list(
        gtsummary::all_continuous() ~ c("{min}, {max}",
                                        "{median} [{p25}, {p75}]",
                                        "{mean} ({sd})"),
        gtsummary::all_categorical() ~ "{n} ({p}%)"
      ),
      missing_text = "\u7f3a\u5931"
    ) %>%
    gtsummary::bold_labels() %>%
    gtsummary::modify_header(label = "**Vars**", stat_0 = "**Summary**")

  .cat_line(sprintf("** Variable Counts (%d variables) **", length(vars)),
            type = "info")
  print(tibble::as_tibble(res_count))
  print(res_count)

  .cat_line(sprintf("** Variable Summary (%d variables) **", length(vars)),
            type = "success")
  print(result)

  res_summary <-
    gt::gt(result) %>%
    gt::tab_header(
      title = gt::md("**Variable Summary**"),
      subtitle = gt::md(sprintf(
        "Dataset: *%d* observations, *%d* variables, *%d* missing, *%d* Unknown/Blank/N/A",
        nrow(data),
        nrow(result),
        sum(result$n_na > 0, na.rm = TRUE),
        sum(result$n_special > 0, na.rm = TRUE)
      ))
    ) %>%
    gtExtras::gt_theme_excel() %>%
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) %>%
    gt::cols_align(align = "center", columns = c("n_unique", "n_na")) %>%
    gt::tab_options(
      column_labels.background.color = "#E8F4FD",
      heading.background.color = "#F0F8FF",
      heading.align = "center"
    )

  print(res_summary)

  print(
    gt::gt_group(
      res_summary,
      gtsummary::as_gt(res_count) %>%
        .gt_highlight_low_percentage() %>%
        .gt_highlight_special_values() %>%
        gt::tab_options(column_labels.background.color = "#E8F4FD")
    )
  )

  gtsummary::reset_gtsummary_theme()

  return(invisible(data))
}


#' @rdname lv
#' @param add_reductions Logical. Whether to add reduction coordinates. Default
#'   \code{FALSE}.
#' @param add_cell_stats Logical. Whether to show cell statistics. Default
#'   \code{TRUE}.
#' @export
#' @family inspect
lv.Seurat <- function(data, ...,
                      pattern = NULL,
                      group = NULL,
                      count = NULL,
                      add_reductions = FALSE,
                      add_cell_stats = TRUE) {

  if (!requireNamespace("SeuratObject", quietly = TRUE)) {
    cli::cli_abort(c(
      "x" = "\u9700\u8981\u5b89\u88c5 {.pkg SeuratObject} \u5305\u624d\u80fd\u5904\u7406 Seurat \u5bf9\u8c61",
      "i" = "\u8bf7\u8fd0\u884c: {.code install.packages('SeuratObject')}"
    ))
  }

  # Process group argument: NSE, character string, and TRUE
  group_quo <- rlang::enquo(group)
  group_var <- NULL

  if (!rlang::quo_is_null(group_quo)) {
    group_expr <- rlang::quo_get_expr(group_quo)

    if (isTRUE(group_expr)) {
      group_var <- ".ident"
    } else if (is.character(group_expr)) {
      group_var <- group_expr
    } else if (is.symbol(group_expr)) {
      group_var <- rlang::as_name(group_quo)
    }
  }

  # Process count argument
  count_sub <- substitute(count)
  count_vars <- NULL

  if (!is.null(count_sub) && !identical(count_sub, quote(NULL))) {
    if (is.character(count_sub)) {
      count_vars <- count_sub
    } else if (is.symbol(count_sub)) {
      count_vars <- as.character(count_sub)
    } else if (is.call(count_sub) && identical(count_sub[[1]], quote(c))) {
      args <- as.list(count_sub)[-1]
      if (length(args) > 0 && is.character(args[[1]])) {
        count_vars <- eval(count_sub, envir = parent.frame())
      } else {
        count_vars <- vapply(args, as.character, character(1))
      }
    }
  }

  # Print Seurat object basic info
  cli::cli_h1(cli::col_magenta("Seurat Object Summary"))

  n_cells <- ncol(data)
  n_features <- nrow(data)

  cli::cli_alert_info("Cells: {.val {n_cells}}")
  cli::cli_alert_info("Features: {.val {n_features}}")

  assays <- SeuratObject::Assays(data)
  cli::cli_alert_info("Assays: {.val {paste(assays, collapse = ', ')}}")

  reductions <- SeuratObject::Reductions(data)
  if (length(reductions) > 0) {
    cli::cli_alert_info("Reductions: {.val {paste(reductions, collapse = ', ')}}")
  }

  meta_data <- data@meta.data

  if (!is.null(group_var) && group_var == ".ident") {
    meta_data$`.ident` <- SeuratObject::Idents(data)
  }

  if (add_reductions && length(reductions) > 0) {
    cli::cli_alert_info("Adding reduction coordinates to display...")
    for (red in reductions) {
      red_coords <- SeuratObject::Embeddings(data, reduction = red)
      n_dims <- min(2, ncol(red_coords))
      for (i in seq_len(n_dims)) {
        col_name <- paste0(toupper(red), "_", i)
        meta_data[[col_name]] <- red_coords[, i]
      }
    }
  }

  if (add_cell_stats) {
    cli::cli_rule(cli::col_cyan("Cell Statistics"))

    qc_cols <- c("nCount_RNA", "nFeature_RNA", "percent.mt", "percent.ribo",
                 "nCount_SCT", "nFeature_SCT", "S.Score", "G2M.Score", "Phase")
    available_qc <- intersect(qc_cols, names(meta_data))

    if (length(available_qc) > 0) {
      cli::cli_alert_success(
        "Available QC metrics: {.val {paste(available_qc, collapse = ', ')}}"
      )
    }

    cluster_cols <- grep("cluster|seurat_cluster|ident", names(meta_data),
                         ignore.case = TRUE, value = TRUE)
    if (length(cluster_cols) > 0) {
      for (cc in cluster_cols) {
        n_clusters <- length(unique(meta_data[[cc]]))
        cli::cli_alert_success("{.field {cc}}: {.val {n_clusters}} clusters")
      }
    }
  }

  cli::cli_rule()

  lv.data.frame(meta_data, ..., pattern = pattern,
                group = group_var, count = count_vars)

  return(invisible(data))
}
