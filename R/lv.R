# =============================================================================
# lv.R -- Variable inspection S3 generic and methods
# =============================================================================
#
# Architecture (S3 generic, 2 layers):
#
#   L1  lv(data, ...)                               -- public generic
#         |   a missing `data`, or a selection of its columns, re-calls lv()
#         |   on the default global data
#         +-- L2  lv.data.frame()   frequency / unique / NA / special-value
#         |                         summaries, grouped and cross-tabulated
#         +-- L2  lv.default()      single vector -> one-column data.frame,
#         |                         then lv.data.frame()
#         +-- L2  lv.Seurat()       @meta.data -> lv.data.frame()
#
#   L3  .lv_default_data()   locate the default data.frame in the caller
#       .lv_dataset_hint()  name global datasets when no default is found
#       .lv_cli_text()      escape braces in text passed to cli messages
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
#' @param data A data object: data.frame or Seurat object. An atomic vector
#'   or matrix is inspected as a data frame of its columns. If omitted,
#'   \code{lv()} falls back to a global object named \code{data}, otherwise
#'   \code{data_all} (the first that is a data.frame / Seurat object).
#'   A first argument that is not a dataset selects variables of that default
#'   data when it is a bare column name, a character vector of column names,
#'   or an expression that cannot be evaluated, e.g. \code{lv(Sex)}; column
#'   names take precedence over caller objects of the same name.
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
#'   Missing group values form their own last group, labelled as missing, and
#'   are included in the overall column. A group with more than 100 distinct
#'   values (factor levels) is an error.
#' @param count Optional variable(s) for cross-tabulation. Accepts a single
#'   variable name (NSE or string), multiple variable names via
#'   \code{c(var1, var2)} (NSE) or character vector
#'   \code{c("var1", "var2")}. Selections in \code{...}, \code{pattern} and
#'   \code{group} are ignored in this mode, with a warning. Two-variable
#'   wide and row-percentage tables are skipped, with a message, when either
#'   variable has more than 100 categories.
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
#'   Character or factor columns with more than 100 categories, such as
#'   identifiers, and list columns are reported in the variable summary but
#'   left out of the frequency and grouped tables, with a message. Time spans
#'   (\code{difftime}) are summarized as numbers in their own units.
#'   Variable-summary rows are tinted by type: character, numeric or
#'   integer, and factor (including ordered) variables.
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
  #     Resolved first, so a missing default reports its own error rather
  #     than surfacing as an unevaluable first argument below.
  if (missing(data)) {
    default <- .lv_default_data()
    return(lv(default, ...))
  }

  # (b) First argument evaluates to a dataset -> normal S3 dispatch.
  value <- tryCatch(data, error = function(e) e)
  failed <- inherits(value, "error")
  if (!failed && (is.data.frame(value) || inherits(value, "Seurat"))) {
    return(UseMethod("lv"))
  }

  # (c) A vector or matrix is inspected itself (lv.default), unless it names
  #     columns of the default global data: as for `group`, column names win,
  #     so a bare column name or a character vector of column names is a
  #     selection, like an expression that cannot be evaluated (`lv(Sex)`).
  first_expr <- substitute(data)
  default <- tryCatch(.lv_default_data(), error = function(e) NULL)
  columns <- if (inherits(default, "Seurat")) names(default@meta.data) else names(default)
  selects <- failed || !is.atomic(value) ||
    (is.symbol(first_expr) && as.character(first_expr) %in% columns) ||
    (is.character(value) && length(value) > 0L && all(value %in% columns))
  if (!selects) return(UseMethod("lv"))
  if (is.null(default)) {
    if (failed) {
      cli::cli_abort(c("Cannot evaluate the first argument of {.fn lv}.",
                       "x" = .lv_cli_text(conditionMessage(value)),
                       "i" = "No global {.code data} or {.code data_all} to select it from.",
                       .lv_dataset_hint()))
    }
    .lv_default_data()
  }

  # Re-invoke on the default data with that expression (and any further ...
  # args) forwarded UNEVALUATED as the tidyselect selection.
  dots_expr  <- as.list(substitute(list(...)))[-1L]
  env <- new.env(parent = parent.frame())
  env[[".__lv_data__"]] <- default
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
  cli::cli_abort(c(
    "{.fn lv}: {.arg data} not supplied and no global {.code data} or {.code data_all} (data.frame / Seurat) found in the global environment.",
    .lv_dataset_hint()
  ), call = NULL)
}

# Hint naming the datasets in the global environment that could be passed.
#' @keywords internal
#' @noRd
.lv_dataset_hint <- function() {
  ge <- globalenv()
  found <- Filter(function(nm) {
    obj <- get(nm, envir = ge, inherits = FALSE)
    is.data.frame(obj) || inherits(obj, "Seurat")
  }, ls(ge))
  if (!length(found)) return(character())
  # Formatted here: the caller's cli_abort() interpolates in its own frame.
  shown <- head(found, 5)
  more <- if (length(found) > 5) ", ..." else ""
  hint <- cli::format_inline(
    "Global datasets: {.val {shown}}{more}; pass one as {.code lv(<name>, ...)}."
  )
  c("i" = .lv_cli_text(hint))
}

# Literal text for a cli message: cli_abort() interpolates every element, so
# braces from object names or other messages are doubled.
#' @keywords internal
#' @noRd
.lv_cli_text <- function(x) {
  gsub("}", "}}", gsub("{", "{{", x, fixed = TRUE), fixed = TRUE)
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
  invisible(data)
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

  # Observed values; a factor keeps its level order without unused levels.
  .get_levels <- function(x) {
    if (is.factor(x)) {
      levels(x)[tabulate(as.integer(x), nlevels(x)) > 0L]
    } else {
      unique(x[!is.na(x)])
    }
  }

  .lv_one <- function(data, var) {
    col_data <- data[[var]]
    n_na <- .count_missing_values(col_data)
    var_class <- class(col_data)[1]

    # at the console the sections below name the variable; the cli header,
    # a message, heads it only while knitting
    if (knitting) {
      cli::cli_h1(
        cli::col_br_white(
          cli::bg_cyan(
            sprintf("** summary for %s (%s) **", var, var_class)
          )
        )
      )
    }

    if (!knitting) {
      pr_section(sprintf("%s (%s): count", var, var_class))
      data %>%
        tibble::as_tibble() %>%
        dplyr::count(.data[[var]]) %>%
        print()

      pr_section(sprintf("%s (%s): %s", var, var_class,
                         if (is.factor(col_data)) "levels" else "unique values"))
    }

    unique_values <- .get_levels(col_data)
    n_unique <- length(unique_values)

    display_values <- if (n_unique > 10) head(unique_values, 8) else unique_values

    # Numbers stay literal when their text reads back exactly, logicals stay
    # logical; other values (dates, imprecise doubles) match through text.
    display_text <- as.character(display_values)
    values <- if (is.logical(display_values)) {
      as.list(display_values)
    } else if (is.numeric(display_values) && !is.object(display_values) &&
               identical(as.numeric(display_text), as.numeric(display_values))) {
      as.list(as.numeric(display_text))
    } else {
      as.list(display_text)
    }
    values_expr <- as.call(c(list(quote(c)), values))
    filter_expr <- substitute(get_flt(VAR %in% VALUES),
                              list(VAR = as.name(var), VALUES = values_expr))
    .get_flt_formula <- paste(deparse(filter_expr, width.cutoff = 500L),
                              collapse = " ")
    # A comment marks truncation, so the code still runs as written.
    if (n_unique > 10) {
      .get_flt_formula <- sprintf("%s  # +%d more", .get_flt_formula, n_unique - 8L)
    }
    .get_flt_formula <- noquote(.get_flt_formula)
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
                                           color_lt1 = "#FF4D4D") {
    if (!inherits(gt_tbl, "gt_tbl") || is.null(gt_tbl$`_data`)) return(gt_tbl)

    df_data <- as.data.frame(gt_tbl$`_data`)
    col_names <- names(df_data)

    for (j in seq_along(df_data)) {
      col_values <- df_data[[j]]
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

  # Highlight missing rows and the category levels that the n_special counts
  # treat as special; variable labels and statistics are left plain.
  .gt_highlight_special_values <- function(gt_tbl,
                                           color_missing = "#FF4D4D",
                                           color_special = "#FFFF00") {
    if (!inherits(gt_tbl, "gt_tbl") || is.null(gt_tbl$`_data`)) return(gt_tbl)

    body <- gt_tbl$`_data`
    rows_missing <- which(body$row_type == "missing")
    rows_special <- which(body$row_type == "level" &
                            .is_special_value(as.character(body$label)))

    if (length(rows_missing) > 0) {
      gt_tbl <- gt_tbl %>%
        gt::tab_style(
          style = gt::cell_fill(color = color_missing),
          locations = gt::cells_body(columns = "label", rows = rows_missing)
        )
    }
    if (length(rows_special) > 0) {
      gt_tbl <- gt_tbl %>%
        gt::tab_style(
          style = gt::cell_fill(color = color_special),
          locations = gt::cells_body(columns = "label", rows = rows_special)
        )
    }
    gt_tbl
  }

  # gtsummary treats an entirely missing character column as continuous and
  # fails formatting it (and rejects a level-less factor); a missing logical
  # reports the same missing count. It cannot tabulate time spans either, so
  # they are summarized as numbers in their own units.
  .tbl_input <- function(df) {
    empty_chr <- vapply(df, function(x) is.character(x) && all(is.na(x)),
                        logical(1))
    df[empty_chr] <- lapply(df[empty_chr], as.logical)
    spans <- vapply(df, inherits, logical(1), what = "difftime")
    df[spans] <- lapply(df[spans], as.numeric)
    lt <- vapply(df, inherits, logical(1), what = "POSIXlt")
    df[lt] <- lapply(df[lt], as.POSIXct)
    df[] <- lapply(df, .label_blank)
    df
  }

  # Empty categories display as "(blank)", as in the wide count table,
  # unless that label is itself a value and the two would merge.
  .label_blank <- function(x) {
    if (is.factor(x)) {
      # Reassigning levels would also drop an NA level, so only touch "".
      blank <- levels(x) %in% ""
      if (any(blank) && !"(blank)" %in% levels(x)) levels(x)[blank] <- "(blank)"
    } else if (is.character(x) && !"(blank)" %in% x) {
      x[x %in% ""] <- "(blank)"
    }
    x
  }

  # A character or factor column with more than 100 categories (an
  # identifier, free text) adds a table row per value, and tbl_summary() and
  # gt then take minutes; such columns, like list columns that gtsummary
  # cannot tabulate, stay in the variable summary only.
  .tbl_vars <- function(vars) {
    many <- vapply(analysis_data[vars], function(x) {
      if (is.factor(x)) nlevels(x) > 100L
      else is.character(x) && length(unique(x[!is.na(x)])) > 100L
    }, logical(1))
    # POSIXlt is stored as a list but summarized as a date-time.
    lists <- vapply(analysis_data[vars], function(x) {
      is.list(x) && !inherits(x, "POSIXlt")
    }, logical(1))
    if (any(many)) {
      cli::cli_inform(c("i" = paste(
        "{.var {vars[many]}} ha{?s/ve} more than 100 categories and",
        "{?is/are} left out of the summary table."
      )))
    }
    if (any(lists)) {
      cli::cli_inform(c("i" = paste(
        "{.var {vars[lists]}} {?is a list column/are list columns} and",
        "{?is/are} left out of the summary table."
      )))
    }
    vars[!many & !lists]
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
    if (knitting) cli::cli_h1(cli::col_cyan("Categorical summary (RegR::get_gt_cat)"))
    else pr_section("Categorical summary (RegR::get_gt_cat)")
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
  selections <- rlang::enquos(...)
  n_selections <- length(selections)
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
    # A caller's vector of names or positions, `lv(data, vars)`, is wrapped in
    # all_of(): tidyselect 1.1.0 deprecated bare external vectors. Column
    # names still win over caller objects of the same name.
    wrap_external <- function(expr, env) {
      if (is.symbol(expr)) {
        name <- as.character(expr)
        if (!nzchar(name) || name %in% names(analysis_data)) return(expr)
        value <- tryCatch(eval(expr, env), error = function(e) NULL)
        if (is.character(value) || is.numeric(value)) {
          expr <- as.call(list(quote(dplyr::all_of), value))
        }
      } else if (is.call(expr) && is.symbol(expr[[1L]]) &&
                 as.character(expr[[1L]]) %in% c("c", "-", "!", "(", "&", "|")) {
        expr[-1L] <- lapply(as.list(expr)[-1L], wrap_external, env = env)
      }
      expr
    }
    selections <- lapply(selections, function(quo) {
      rlang::quo_set_expr(quo, wrap_external(rlang::quo_get_expr(quo),
                                             rlang::quo_get_env(quo)))
    })
    analysis_data <- dplyr::select(analysis_data, !!!selections)
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
    if (n_selections || !is.null(pattern) || !is.null(group_var)) {
      cli::cli_warn(paste(
        "{.arg count} tabulates only its own variables; selections in",
        "{.code ...}, {.arg pattern} and {.arg group} were ignored."
      ))
    }
    count_title <- paste(count_vars, collapse = " \u00d7 ")
    # Headings and facts print to stdout at the console, with the tables they
    # head, so capture.output() and Rscript logs keep them and
    # suppressMessages() leaves them; while knitting they stay cli messages,
    # so knitted reports are as they were (57ad289 kept them for that).
    if (knitting) {
      cli::cli_h1(cli::col_cyan(glue::glue("Cross-tabulation: {count_title}")))
      cli::cli_alert_info("Variables: {.val {paste(count_vars, collapse = ', ')}}")
    } else {
      pr_section(paste("Cross-tabulation:", count_title))
      pr_kv(list(Variables = toString(count_vars)))
    }

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
      dplyr::mutate(
        "{pct_name}" := round(.data[[n_name]] / sum(.data[[n_name]]) * 100, 2),
        "{label_name}" := glue::glue("{.data[[n_name]]} ({.data[[pct_name]]}%)")
      )
    cross_count[count_vars] <- lapply(cross_count[count_vars], .label_blank)

    if (knitting) .lv_print_report(gt::gt(cross_count))
    else print(tibble::as_tibble(cross_count))

    # A wide table gets one column per category of the second variable and
    # one row per category of the first; beyond 100 it is unreadable and
    # slow (5,000 columns took 18 s), so only the long table is shown.
    two_way <- length(count_vars) == 2
    if (two_way) {
      n_cat <- vapply(count_vars, function(v) dplyr::n_distinct(count_base[[v]]),
                      integer(1))
      if (any(n_cat > 100L)) {
        cli::cli_inform(c("i" = paste(
          "{.var {count_vars[n_cat > 100L]}} ha{?s/ve} more than 100",
          "categories; the wide and row-percentage tables are skipped."
        )))
        two_way <- FALSE
      }
    }
    if (two_way) {
      if (knitting) cli::cli_h2(cli::col_yellow("Wide Format Table"))
      else pr_section("Wide Format Table")

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

      if (knitting) cli::cli_h3(cli::col_yellow("Row Percentages (%)"))
      else pr_section("Row Percentages (%)")

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

    if (knitting) cli::cli_rule()
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
  # gtsummary announces each theme it sets; the caller asked for no theme
  suppressMessages(gtsummary::theme_gtsummary_compact())

  if (!is.null(group_var)) {
    # One table column per group (every factor level): an identifier as the
    # group took over a minute for 5,000 values.
    by_values <- data[[group_var]]
    n_by <- if (is.factor(by_values)) nlevels(by_values) else
      length(unique(by_values[!is.na(by_values)]))
    if (n_by > 100L) {
      cli::cli_abort(c(
        "{.arg group} column {.var {group_var}} has {n_by} distinct values; grouped summaries take at most 100.",
        "i" = "Use {.arg count} for its frequencies, or group a binned version."
      ))
    }
    if (group_var %in% vars &&
        !identical(analysis_data[[group_var]], data[[group_var]])) {
      cli::cli_abort("A selected column name conflicts with {.arg group}; use another alias.")
    }
    vars <- .tbl_vars(setdiff(vars, group_var))
    if (length(vars) == 0) {
      cli::cli_inform("No variables to summarize apart from the group; returning input.")
      return(invisible(data))
    }

    n_groups <- length(unique(data[[group_var]]))
    if (knitting) {
      cli::cli_h1(cli::col_magenta(glue::glue("Variable Summary by {group_var}")))
      cli::cli_alert_info("Groups: {.val {n_groups}}")
    } else {
      pr_section(paste("Variable Summary by", group_var))
      pr_kv(list(Groups = n_groups))
    }

    grouped_data <- .tbl_input(tibble::as_tibble(analysis_data)[, vars, drop = FALSE])
    # Missing group values form their own last group, so the groups match the
    # count above and the overall column covers every row; tbl_summary()
    # would otherwise drop those rows.
    by <- data[[group_var]]
    if (anyNA(by)) {
      by <- as.factor(by)
      if (!"\u7f3a\u5931" %in% levels(by)) levels(by) <- c(levels(by), "\u7f3a\u5931")
      by[is.na(by)] <- "\u7f3a\u5931"
    }
    grouped_data[[group_var]] <- .label_blank(by)
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
        missing_text = "\u7f3a\u5931",
        missing_stat = "{N_miss} ({p_miss}%)"
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

  table_vars <- .tbl_vars(vars)
  res_count <- if (length(table_vars)) {
    .tbl_input(tibble::as_tibble(analysis_data)[, table_vars, drop = FALSE]) %>%
    labelled::set_variable_labels(
      .labels = setNames(
        paste0(
          table_vars, " (",
          vapply(analysis_data[table_vars], function(x) class(x)[1], character(1)), ", ",
          # Observed values, as counted by .lv_one().
          as.integer(result$n_unique[match(table_vars, result$vars)]),
          ")"
        ),
        table_vars
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
      missing_text = "\u7f3a\u5931",
      missing_stat = "{N_miss} ({p_miss}%)"
    ) %>%
    gtsummary::bold_labels() %>%
    gtsummary::modify_header(label = "**Vars**", stat_0 = "**Summary**")
  }

  if (!knitting) {
    if (!is.null(res_count)) {
      pr_section(sprintf("Variable counts (%d variables)", length(table_vars)))
      print(tibble::as_tibble(res_count))
    }

    pr_section(sprintf("Variable summary (%d variables)", length(vars)))
    print(result)
  }

  res_summary <-
    gt::gt(result) %>%
    gt::tab_header(
      title = gt::md("**Variable Summary**"),
      subtitle = gt::md(sprintf(
        "Dataset: *%d* observations, *%d* variables; *%d* with missing values, *%d* with Unknown/Blank/N/A",
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
    # Tint whole rows by variable type: character, numeric and factor.
    gt::tab_style(
      style = gt::cell_fill(color = "#FDF0E6"),
      locations = gt::cells_body(rows = class == "character")
    ) %>%
    gt::tab_style(
      style = gt::cell_fill(color = "#E9F2FB"),
      locations = gt::cells_body(rows = class %in% c("numeric", "integer"))
    ) %>%
    gt::tab_style(
      style = gt::cell_fill(color = "#EAF5E4"),
      locations = gt::cells_body(rows = class %in% c("factor", "ordered"))
    ) %>%
    gt::tab_options(
      column_labels.background.color = "#E8F4FD",
      heading.background.color = "#F0F8FF",
      heading.align = "center"
    )

  # The console shows both HTML tables once, in one group, after the text.
  styled_count <- if (!is.null(res_count)) {
    gtsummary::as_gt(res_count) %>%
      .gt_highlight_low_percentage() %>%
      .gt_highlight_special_values() %>%
      gt::tab_options(column_labels.background.color = "#E8F4FD")
  }
  if (knitting) {
    .lv_print_report(res_summary)
    if (!is.null(styled_count)) .lv_print_report(styled_count)
  } else if (is.null(styled_count)) {
    print(res_summary)
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

  # Print Seurat object basic info: to stdout at the console, as cli
  # messages while knitting (see lv.data.frame())
  knitting <- isTRUE(getOption("knitr.in.progress")) &&
    requireNamespace("knitr", quietly = TRUE)
  n_cells <- ncol(data)
  n_features <- nrow(data)
  assays <- SeuratObject::Assays(data)
  reductions <- SeuratObject::Reductions(data)
  if (knitting) {
    cli::cli_h1(cli::col_magenta("Seurat Object Summary"))
    cli::cli_alert_info("Cells: {.val {n_cells}}")
    cli::cli_alert_info("Features: {.val {n_features}}")
    cli::cli_alert_info("Assays: {.val {paste(assays, collapse = ', ')}}")
    if (length(reductions) > 0) {
      cli::cli_alert_info("Reductions: {.val {paste(reductions, collapse = ', ')}}")
    }
  } else {
    pr_section("Seurat Object Summary")
    pr_kv(list(Cells = n_cells, Features = n_features, Assays = toString(assays),
               Reductions = if (length(reductions)) toString(reductions)))
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
    qc_cols <- c("nCount_RNA", "nFeature_RNA", "percent.mt", "percent.ribo",
                 "nCount_SCT", "nFeature_SCT", "S.Score", "G2M.Score", "Phase")
    available_qc <- intersect(qc_cols, names(meta_data))

    # orig.ident names the sample each cell came from, not a clustering.
    cluster_cols <- setdiff(grep("cluster|seurat_cluster|ident", names(meta_data),
                                 ignore.case = TRUE, value = TRUE), "orig.ident")
    n_clusters <- vapply(cluster_cols, function(cc) length(unique(meta_data[[cc]])),
                         integer(1))
    if (knitting) {
      cli::cli_rule(cli::col_cyan("Cell Statistics"))
      if (length(available_qc) > 0) {
        cli::cli_alert_success(
          "Available QC metrics: {.val {paste(available_qc, collapse = ', ')}}"
        )
      }
      for (cc in cluster_cols) {
        cli::cli_alert_success("{.field {cc}}: {.val {n_clusters[[cc]]}} clusters")
      }
    } else {
      pr_section("Cell Statistics")
      pr_kv(c(list(`Available QC metrics` = if (length(available_qc)) toString(available_qc)),
              as.list(stats::setNames(sprintf("%d clusters", n_clusters), cluster_cols))))
    }
  }

  if (knitting) cli::cli_rule()

  rlang::inject(lv.data.frame(meta_data, ..., pattern = pattern,
                             group = !!group_var, count = !!count_vars,
                             cat_args = cat_args))

  return(invisible(data))
}
