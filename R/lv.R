# =============================================================================
# lv.R -- Variable inspection S3 generic and methods
# =============================================================================
#
# Architecture (S3 generic, 2 layers):
#
#   L1  lv(data, ...)                               -- public generic
#         |   a missing `data` re-calls lv() on the default global data
#         +-- L2  lv.data.frame()   frequency / unique / NA / special-value
#         |                         summaries, grouped and cross-tabulated
#         +-- L2  lv.default()      single vector -> one-column data.frame,
#         |                         then lv.data.frame()
#         +-- L2  lv.Seurat()       @meta.data -> lv.data.frame()
#
#   L3  .lv_default_data()   locate the default data.frame in the caller
#       .lv_resolve_vars()  resolve column names and caller-supplied strings
#       .lv_print_report() emit native report tables while knitting
# =============================================================================

#' @title Variable Inspection Generic Function
#'
#' @description
#' Inspect variables in a data.frame or Seurat object, including frequency
#' counts, unique values, missing values and special values (e.g. "unknown",
#' "blank", "n/a"). Supports grouped summaries and multi-variable
#' cross-tabulation. Special-value matching uses Unicode-aware whole-word
#' markers and normalizes whitespace, including Unicode whitespace-only blanks.
#' Values recognized by \code{is.na()}, including SPSS user-missing codes,
#' are excluded from special-value counts.
#' Methods for serialized haven-labelled and integer64 columns are loaded
#' before inspection; integer64 columns require the optional \pkg{bit64} package.
#'
#' @param data A data object: data.frame or Seurat object. If omitted,
#'   \code{lv()} falls back to a global object named \code{data}, otherwise
#'   \code{data_all} (the first that is a data.frame / Seurat object).
#'   Empty data frames are returned unchanged with a message and no report.
#' @param ... Variable selection using \code{dplyr::select} syntax, including
#'   renamed selections. With no selection, all variables are inspected;
#'   an explicit empty selection returns the input without a report.
#' @param pattern Optional single regex pattern for matching variable names.
#'   Overrides \code{...} with a warning, without evaluating those selections.
#' @param group Optional grouping variable. Supports NSE (bare name) or
#'   character string. For Seurat objects, set to \code{TRUE} to use current
#'   Ident.
#'   Bare column names take precedence over caller objects;
#'   character names can also be supplied through variables or expressions.
#' @param count Optional variable(s) for cross-tabulation. Accepts a single
#'   variable name (NSE or string), multiple variable names via
#'   \code{c(var1, var2)} (NSE) or character vector
#'   \code{c("var1", "var2")}. Independent of \code{group}.
#'   Existing dplyr groups are ignored for this table. Generated frequency,
#'   percentage, and total column names receive numeric suffixes when needed
#'   to preserve input columns and category labels.
#'   Empty category labels are displayed as \code{(blank)} in wide tables.
#'   Names must be non-missing and distinct; invalid controls are errors.
#' @param cat_args Optional named list of extra arguments forwarded to
#'   \code{\link[RegR:get_gt_cat]{RegR::get_gt_cat()}} for an additional
#'   publication-ready categorical-summary table (with survival-outcome
#'   columns DSS/OS/status etc. auto-included). When non-empty, the
#'   internal call is essentially
#'   \code{do.call(RegR::get_gt_cat, c(list(data = data), cat_args))}.
#'   Typical contents: \code{list(cat_var = "Sex", com_var = c("Age","TNM"))}.
#'   The \code{data} argument is always taken from the \code{lv()}
#'   first argument; any \code{data} entry inside \code{cat_args} is
#'   overridden with a warning. Default \code{list()} = no extra call.
#'   Requires \pkg{RegR} (declared in Suggests).
#'
#' @return Invisibly returns the input data.
#'
#' @details In R Markdown or Quarto, use a code chunk with
#'   \code{results = "asis"} (and optionally \code{message = FALSE}). Reports
#'   are emitted through \code{knitr::knit_print()} in the document's native
#'   format, with dependencies retained. Console frequency listings are omitted
#'   while knitting, and each default summary table is included only once.
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
#' # cat_args: append a publication-ready table via RegR::get_gt_cat
#' # (requires RegR package; survival outcome cols DSS/OS/status auto-included)
#' library(dplyr)
#' df <- mtcars |>
#'   mutate(cyl_f = factor(cyl), am_f = factor(am, labels = c("auto","manual")))
#'
#' # 1) Default (empty list) -- no extra get_gt_cat call (backward-compatible)
#' lv(df, mpg, hp, cyl_f, am_f, cat_args = list())
#'
#' # 2) Minimal: cat_var only -- groups by 'am_f', auto-adds outcome cols if any
#' lv(df, mpg, hp, cyl_f, am_f,
#'    cat_args = list(cat_var = "am_f"))
#'
#' # 3) With explicit com_var (rows of the gt table)
#' lv(df, mpg, hp, cyl_f, am_f,
#'    cat_args = list(cat_var = "am_f", com_var = c("mpg", "hp", "cyl_f")))
#'
#' # 4) Stratified summary (separate table per strata level)
#' lv(df, mpg, hp,
#'    cat_args = list(strata_var = "cyl_f", cat_var = "am_f",
#'                    com_var = c("mpg", "hp")))
#'
#' # 5) Combine with group mode -- lv prints grouped summary,
#' #    then get_gt_cat prints the publication table
#' lv(df, mpg, hp, group = cyl_f,
#'    cat_args = list(cat_var = "am_f", com_var = c("mpg", "hp")))
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
  # (a) No first argument at all -> default global data, inspect all variables.
  #     Re-call with `data` supplied (reassigning a missing arg before
  #     UseMethod does NOT propagate the new value to the method).
  if (missing(data)) return(lv(.lv_default_data(), ...))

  # (b) First argument evaluates to a dataset -> normal S3 dispatch.
  is_dataset <- tryCatch(is.data.frame(data) || inherits(data, "Seurat"),
                         error = function(e) FALSE)
  if (isTRUE(is_dataset)) return(UseMethod("lv"))

  # (c) First argument is NOT a dataset -- it is a variable selection meant for
  #     the default global data (e.g. `lv(Sex)` = inspect column Sex of the
  #     global `data`). Re-invoke on the default data with that expression (and
  #     any further ... args) forwarded UNEVALUATED as the tidyselect selection.
  first_expr <- substitute(data)
  dots_expr  <- as.list(substitute(list(...)))[-1L]
  env <- new.env(parent = parent.frame())
  env[[".__lv_data__"]] <- .lv_default_data()
  eval(as.call(c(list(quote(lv), as.name(".__lv_data__"), first_expr), dots_expr)),
       envir = env)
}

# Fallback data source for `lv()` called without `data`: a global `data`, else
# a global `data_all` -- whichever exists first and is a data.frame / Seurat.
#' @keywords internal
#' @noRd
.lv_default_data <- function() {
  ge <- globalenv()
  is_dataset <- function(x) is.data.frame(x) || inherits(x, "Seurat")
  for (nm in c("data", "data_all")) {
    if (exists(nm, envir = ge, inherits = FALSE)) {
      obj <- get(nm, envir = ge, inherits = FALSE)
      if (is_dataset(obj)) return(obj)
    }
  }
  stop("lv(): `data` not supplied and no global `data` or `data_all` ",
       "(data.frame / Seurat) found in the global environment.", call. = FALSE)
}

#' @noRd
.lv_resolve_vars <- function(quo, data_names, arg, multiple = FALSE, ident = FALSE) {
  if (rlang::quo_is_null(quo)) return(NULL)
  # A data mask of names keeps bare columns ahead of caller variables without
  # evaluating a full data column merely to select it.
  mask <- stats::setNames(as.list(data_names), data_names)
  value <- tryCatch(rlang::eval_tidy(quo, data = mask), error = function(e) {
    cli::cli_abort(c("Cannot resolve {.arg {arg}}.", "x" = conditionMessage(e)))
  })
  if (is.null(value)) return(NULL)
  if (ident && isTRUE(value)) return(".ident")
  valid <- is.character(value) && is.null(dim(value)) && length(value) > 0L &&
    !anyNA(value) && all(nzchar(value)) && !anyDuplicated(value)
  if (!valid || (!multiple && length(value) != 1L)) {
    what <- if (multiple) "one or more distinct column names" else "one column name"
    cli::cli_abort("{.arg {arg}} must be NULL or {what}.")
  }
  missing <- setdiff(value, data_names)
  if (length(missing)) {
    cli::cli_abort("Columns {.val {missing}} in {.arg {arg}} not found in data.")
  }
  unname(value)
}

#' @noRd
.lv_print_report <- function(x) {
  if (isTRUE(getOption("knitr.in.progress")) &&
      requireNamespace("knitr", quietly = TRUE)) {
    rendered <- knitr::knit_print(x)
    meta <- attr(rendered, "knit_meta")
    if (length(meta)) knitr::knit_meta_add(meta)
    cat(as.character(rendered), "\n\n", sep = "")
  } else {
    print(x)
  }
  invisible(x)
}

#' @rdname lv
#' @export
lv.default <- function(data, ..., pattern = NULL, group = NULL, count = NULL,
                       cat_args = list()) {
  input <- as.data.frame(data)
  group_var <- .lv_resolve_vars(rlang::enquo(group), names(input), "group")
  count_vars <- .lv_resolve_vars(rlang::enquo(count), names(input), "count",
                                  multiple = TRUE)
  rlang::inject(lv.data.frame(input, ..., pattern = pattern,
                             group = !!group_var, count = !!count_vars,
                             cat_args = cat_args))
}

#' @rdname lv
#' @export
lv.data.frame <- function(data, ..., pattern = NULL, group = NULL, count = NULL,
                          cat_args = list()) {

  group_var <- .lv_resolve_vars(rlang::enquo(group), names(data), "group")
  count_vars <- .lv_resolve_vars(rlang::enquo(count), names(data), "count",
                                  multiple = TRUE)
  knitting <- isTRUE(getOption("knitr.in.progress")) &&
    requireNamespace("knitr", quietly = TRUE)

  # ==========================================================================
  # Internal helper functions
  # ==========================================================================

  .get_levels <- function(x) {
    if (is.factor(x)) {
      levels(x)
    } else {
      unique(x[!is.na(x)])
    }
  }

  .lv_one <- function(data, var) {
    col_data <- data[[var]]
    n_na <- .count_missing_values(col_data)
    var_class <- class(col_data)[1]

    cli::cli_h1(
      cli::col_br_white(
        cli::bg_cyan(
          sprintf("** summary for %s (%s) **", var, var_class)
        )
      )
    )

    if (!knitting) {
      cat(sprintf("----1. %s (%s) count----------\n", var, var_class))
      data %>%
        tibble::as_tibble() %>%
        dplyr::count(.data[[var]]) %>%
        print()

      cat(sprintf("----2. %s (%s) %s----------\n",
                  var, var_class,
                  if (is.factor(col_data)) "Levels" else "unique"))
    }

    unique_values <- .get_levels(col_data)
    n_unique <- length(unique_values)

    # Convert before appending the marker: c() on dates would parse "...".
    display_values <- if (n_unique > 10) {
      c(as.character(head(unique_values, 8)), "...")
    } else {
      unique_values
    }

    values_expr <- as.call(c(list(quote(c)), as.list(as.character(display_values))))
    filter_expr <- substitute(get_flt(VAR %in% VALUES),
                              list(VAR = as.name(var), VALUES = values_expr))
    .get_flt_formula <- noquote(paste(deparse(filter_expr, width.cutoff = 500L),
                                     collapse = " "))
    if (!knitting) print(.get_flt_formula)

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

  # Optional RegR::get_gt_cat hook (called once at end of each mode)
  .run_cat_args <- function() {
    if (length(cat_args) == 0L) return(invisible(NULL))
    if (!requireNamespace("RegR", quietly = TRUE)) {
      cli::cli_warn(c(
        "{.arg cat_args} provided but {.pkg RegR} is not installed.",
        "i" = "Install RegR to enable the categorical summary table:",
        "*" = "{.code remotes::install_github(\"HUI950319/RegR\")}"
      ))
      return(invisible(NULL))
    }
    if ("data" %in% names(cat_args)) {
      cli::cli_warn("{.arg data} inside {.arg cat_args} is ignored; using {.code lv()}'s data argument.")
      cat_args$data <- NULL
    }
    cli::cli_h1(cli::col_cyan("Categorical summary (RegR::get_gt_cat)"))
    tryCatch(
      do.call(RegR::get_gt_cat, c(list(data = data), cat_args)),
      error = function(e) {
        cli::cli_warn(c(
          "{.fn RegR::get_gt_cat} failed: {conditionMessage(e)}",
          "i" = "Continuing with {.code lv()} output."
        ))
      }
    )
    invisible(NULL)
  }

  # ==========================================================================
  # Main logic
  # ==========================================================================

  # Variable selection
  analysis_data <- dplyr::ungroup(data)
  n_selections <- length(rlang::enquos(...))
  if (!is.null(pattern)) {
    if (!is.character(pattern) || !is.null(dim(pattern)) ||
        length(pattern) != 1L || is.na(pattern)) {
      cli::cli_abort("{.arg pattern} must be NULL or a single regular expression.")
    }
    matched <- tryCatch(
      grepl(pattern, names(data), ignore.case = TRUE),
      error = function(e) cli::cli_abort("{.arg pattern} must be a valid regular expression."),
      warning = function(w) cli::cli_abort("{.arg pattern} must be a valid regular expression.")
    )
    if (n_selections) {
      cli::cli_warn("{.arg pattern} overrides selections in {.code ...}; they were not evaluated.")
    }
    analysis_data <- analysis_data[, matched, drop = FALSE]
  } else if (n_selections) {
    analysis_data <- dplyr::select(analysis_data, ...)
  }
  vars <- names(analysis_data)
  if (!nrow(data) || !ncol(data)) {
    cli::cli_inform("Input has no rows or columns; returning input without a report.")
    return(invisible(data))
  }
  if (!length(vars) && is.null(count_vars)) {
    cli::cli_inform("No variables selected; returning input without a report.")
    return(invisible(data))
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

    # Keep generated fields separate from the variables being inspected.
    count_names <- tail(make.unique(c(count_vars, "n", "pct", "n_pct"),
                                    sep = "_"), 3L)
    n_name <- count_names[1L]
    pct_name <- count_names[2L]
    label_name <- count_names[3L]
    count_data <- dplyr::ungroup(data)
    count_base <- count_data %>%
      dplyr::count(dplyr::across(dplyr::all_of(count_vars)), name = n_name)
    cross_count <- count_base %>%
      dplyr::arrange(dplyr::across(dplyr::all_of(count_vars)))

    cross_count <- cross_count %>%
      dplyr::mutate(
        "{pct_name}" := round(.data[[n_name]] / sum(.data[[n_name]]) * 100, 2),
        "{label_name}" := glue::glue("{.data[[n_name]]} ({.data[[pct_name]]}%)")
      )

    if (knitting) .lv_print_report(gt::gt(cross_count))
    else print(tibble::as_tibble(cross_count))

    if (length(count_vars) == 2) {
      cli::cli_h2(cli::col_yellow("Wide Format Table"))

      cross_wide <- count_base %>%
        tidyr::pivot_wider(
          names_from = dplyr::all_of(count_vars[2]),
          values_from = dplyr::all_of(n_name),
          values_fill = 0,
          names_prefix = ".lv_",
          names_repair = "minimal"
        )
      names(cross_wide)[-1L] <- substring(names(cross_wide)[-1L], 5L)
      names(cross_wide)[names(cross_wide) == ""] <- "(blank)"
      names(cross_wide) <- make.unique(names(cross_wide), sep = "_")
      total_name <- tail(make.unique(c(names(cross_wide), "Total"), sep = "_"), 1L)

      cross_wide <- cross_wide %>%
        dplyr::mutate("{total_name}" := rowSums(dplyr::pick(-1)))

      if (!knitting) print(tibble::as_tibble(cross_wide))

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

      .lv_print_report(cross_gt)

      cli::cli_h3(cli::col_yellow("Row Percentages (%)"))

      cross_pct <- count_base %>%
        dplyr::group_by(.data[[count_vars[1]]]) %>%
        dplyr::mutate("{pct_name}" :=
                        round(.data[[n_name]] / sum(.data[[n_name]]) * 100, 1)) %>%
        dplyr::ungroup() %>%
        dplyr::select(-dplyr::all_of(n_name)) %>%
        tidyr::pivot_wider(
          names_from = dplyr::all_of(count_vars[2]),
          values_from = dplyr::all_of(pct_name),
          values_fill = 0,
          names_prefix = ".lv_",
          names_repair = "minimal"
        )
      names(cross_pct)[-1L] <- substring(names(cross_pct)[-1L], 5L)
      names(cross_pct)[names(cross_pct) == ""] <- "(blank)"
      names(cross_pct) <- make.unique(names(cross_pct), sep = "_")

      if (knitting) .lv_print_report(gt::gt(cross_pct))
      else print(tibble::as_tibble(cross_pct))
    }

    cli::cli_rule()
    .run_cat_args()
    return(invisible(data))
  }

  # ==========================================================================
  # Grouped mode
  # ==========================================================================
  original_theme <- gtsummary::get_gtsummary_theme()
  restore_theme <- function() {
    gtsummary::reset_gtsummary_theme()
    suppressMessages(gtsummary::set_gtsummary_theme(original_theme))
  }
  on.exit(restore_theme(), add = TRUE)
  gtsummary::theme_gtsummary_compact()

  if (!is.null(group_var)) {
    if (!group_var %in% names(data)) {
      cli::cli_abort("\u53d8\u91cf {.var {group_var}} \u4e0d\u5b58\u5728\u4e8e\u6570\u636e\u4e2d")
    }

    if (group_var %in% vars &&
        !identical(analysis_data[[group_var]], data[[group_var]])) {
      cli::cli_abort("A selected column name conflicts with {.arg group}; use another alias.")
    }
    vars <- setdiff(vars, group_var)
    if (length(vars) == 0) {
      cli::cli_inform("No variables selected apart from the group; returning input.")
      return(invisible(data))
    }

    cli::cli_h1(cli::col_magenta(glue::glue("Variable Summary by {group_var}")))

    n_groups <- length(unique(data[[group_var]]))
    cli::cli_alert_info("Groups: {.val {n_groups}}")

    grouped_data <- tibble::as_tibble(analysis_data)[, vars, drop = FALSE]
    grouped_data[[group_var]] <- data[[group_var]]
    res_grouped <-
      grouped_data[, c(group_var, vars), drop = FALSE] %>%
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

    .lv_print_report(res_grouped)

    restore_theme()
    .run_cat_args()
    return(invisible(data))
  }

  # ==========================================================================
  # Default mode (no group, no count)
  # ==========================================================================

  result <- purrr::map_dfr(vars, ~ .lv_one(analysis_data, .x))

  res_count <-
    tibble::as_tibble(analysis_data)[, vars, drop = FALSE] %>%
    labelled::set_variable_labels(
      .labels = setNames(
        paste0(
          vars, " (",
          vapply(analysis_data[vars], function(x) class(x)[1], character(1)), ", ",
          # Observed values: .lv_one() already counted them for non-factors;
          # its factor count includes unused levels, so tabulate the codes.
          vapply(vars, function(v) {
            x <- analysis_data[[v]]
            if (is.factor(x)) sum(tabulate(as.integer(x), nlevels(x)) > 0L)
            else as.integer(result$n_unique[match(v, result$vars)])
          }, integer(1)),
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

  if (!knitting) {
    .cat_line(sprintf("** Variable Counts (%d variables) **", length(vars)),
              type = "info")
    print(tibble::as_tibble(res_count))
    print(res_count)

    .cat_line(sprintf("** Variable Summary (%d variables) **", length(vars)),
              type = "success")
    print(result)
  }

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

  if (!knitting) print(res_summary)

  styled_count <- gtsummary::as_gt(res_count) %>%
    .gt_highlight_low_percentage() %>%
    .gt_highlight_special_values() %>%
    gt::tab_options(column_labels.background.color = "#E8F4FD")
  if (knitting) {
    .lv_print_report(res_summary)
    .lv_print_report(styled_count)
  } else {
    print(gt::gt_group(res_summary, styled_count))
  }

  restore_theme()
  .run_cat_args()
  return(invisible(data))
}


#' @rdname lv
#' @param add_reductions Logical. Whether to add reduction coordinates. Default
#'   \code{FALSE}.
#' @param add_cell_stats Logical. Whether to show cell statistics. Default
#'   \code{TRUE}.
#' @export
lv.Seurat <- function(data, ...,
                      pattern = NULL,
                      group = NULL,
                      count = NULL,
                      cat_args = list(),
                      add_reductions = FALSE,
                      add_cell_stats = TRUE) {

  if (!requireNamespace("SeuratObject", quietly = TRUE)) {
    cli::cli_abort(c(
      "x" = "\u9700\u8981\u5b89\u88c5 {.pkg SeuratObject} \u5305\u624d\u80fd\u5904\u7406 Seurat \u5bf9\u8c61",
      "i" = "\u8bf7\u8fd0\u884c: {.code install.packages('SeuratObject')}"
    ))
  }

  meta_data <- data@meta.data
  group_var <- .lv_resolve_vars(rlang::enquo(group), c(names(meta_data), ".ident"),
                                 "group", ident = TRUE)
  if (identical(group_var, ".ident")) {
    meta_data[[".ident"]] <- SeuratObject::Idents(data)
  }
  count_vars <- .lv_resolve_vars(rlang::enquo(count), names(meta_data), "count",
                                  multiple = TRUE)

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

  rlang::inject(lv.data.frame(meta_data, ..., pattern = pattern,
                             group = !!group_var, count = !!count_vars,
                             cat_args = cat_args))

  return(invisible(data))
}
