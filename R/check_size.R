# =============================================================================
# check_size.R -- Object size analysis in an environment
# =============================================================================

#' Analyze Object Sizes in an Environment
#'
#' Check memory usage of objects in an environment, \code{.GlobalEnv} by
#' default. Outputs a styled \code{gt} table with bar chart and color gradient.
#'
#' @param ... Object names (character vectors) or plain numeric vectors of
#'   finite, positive integer indices into the alphabetically sorted names in
#'   \code{envir}, including hidden names. With no arguments, all objects
#'   are analyzed. Duplicate names are inspected once. Missing names are
#'   skipped with a warning; empty selections do not select all objects.
#'   Arguments are evaluated, so an unquoted numeric variable supplies
#'   indices, not its own name; a call made from \code{envir} itself warns
#'   when this happens.
#' @param pattern Optional single, non-missing regular expression for matching
#'   object names. Takes precedence over \code{...}, with a warning when both
#'   are supplied; no matches select no objects.
#' @param envir Environment whose objects are inspected. Defaults to
#'   \code{.GlobalEnv}; parent environments are never searched.
#' @param method Size estimator: \code{"object.size"} (default) uses
#'   \code{utils::object.size()} and sums the rows for the total;
#'   \code{"lobstr"} uses \code{lobstr::obj_size()}, which requires the
#'   \pkg{lobstr} package and counts storage shared between objects once in
#'   the total.
#'
#' @return A \code{gt} table object, including a zero-row table when no objects
#'   can be inspected. Objects that fail to load are skipped with a warning
#'   identifying each binding and the underlying error message.
#'   Its underlying data contain \code{Object}, \code{Class}, \code{Size},
#'   \code{Size_fmt} and \code{Size_bar}. Objects are listed from largest to
#'   smallest, with equally sized objects in alphabetical order. Numeric
#'   sizes remain in MB (\eqn{1024^2} bytes), with automatic B, KB, MB or GB
#'   display labels.
#'   Size bars appear in HTML output; other formats retain the size labels.
#'   Object bars are scaled to the largest individual object; the total bar
#'   is capped at full width. A source note states the limits of the estimates.
#'
#' @details
#' By default, sizes are estimates from \code{utils::object.size()}, not
#' process memory usage or the memory that would be freed by removing an
#' object. The total sums the individual estimates; shared storage can
#' therefore be counted more than once. Environments, closure environments,
#' external pointers and compact ALTREP representations are not fully
#' accounted for by this method.
#' With \code{method = "lobstr"}, each row includes the environments an object
#' captures (except \code{envir} itself, the global and base environments and
#' namespaces), compact ALTREP vectors report their compact size, and the
#' total counts shared storage once, so it can be smaller than the sum of the
#' rows. It can be several times slower on deeply nested lists.
#' Each selected binding is read once. Reading active bindings invokes their
#' functions, and reading promises evaluates them; inspection can therefore
#' trigger user-defined computations.
#'
#' @examples
#' (function() {
#'   prefix <- basename(tempfile("check_size_example_"))
#'   object_names <- paste0(prefix, c("_small", "_large"))
#'   list2env(stats::setNames(list(1:10, raw(2048)), object_names), .GlobalEnv)
#'   on.exit(rm(list = object_names, envir = .GlobalEnv), add = TRUE)
#'   check_size(object_names)
#'   indices <- match(object_names, ls(envir = .GlobalEnv, all.names = TRUE))
#'   check_size(indices)
#'   check_size(pattern = paste0("^", prefix))
#' })()
#'
#' # Inspect a local environment instead of the global one
#' check_size(envir = list2env(list(small = 1:10, large = raw(2048))))
#'
#' # Count storage shared between objects once
#' if (requireNamespace("lobstr", quietly = TRUE)) {
#'   shared <- rnorm(1000)
#'   check_size(envir = list2env(list(x = shared, y = list(shared, shared))),
#'              method = "lobstr")
#' }
#'
#' @export
#' @family inspect
check_size <- function(..., pattern = NULL, envir = .GlobalEnv,
                       method = c("object.size", "lobstr")) {

  if (!is.environment(envir)) {
    stop("`envir` must be an environment.", call. = FALSE)
  }
  method <- match.arg(method)
  if (method == "lobstr" && !requireNamespace("lobstr", quietly = TRUE)) {
    stop("`method = \"lobstr\"` requires the lobstr package.", call. = FALSE)
  }
  all_objects <- NULL

  if (!is.null(pattern)) {
    if (!is.character(pattern) || length(pattern) != 1L || is.na(pattern)) {
      stop("`pattern` must be a single, non-missing character string.", call. = FALSE)
    }
    # Count the dots without evaluating them.
    if (...length() > 0L) {
      warning("`pattern` takes precedence; the selection in `...` is ignored.",
              call. = FALSE)
    }
    all_objects <- ls(envir = envir, all.names = TRUE, sorted = FALSE)
    matched <- tryCatch(suppressWarnings(grepl(pattern, all_objects)),
                        error = function(e) {
                          stop("Invalid `pattern`: ", conditionMessage(e), call. = FALSE)
                        })
    objects <- all_objects[matched]
  } else {
    selected_objects <- list(...)
    if (length(selected_objects) == 0) {
      objects <- ls(envir = envir, all.names = TRUE, sorted = FALSE)
    } else {
      objects <- character(0)
      # A bare symbol evaluated in `envir` is most likely the object the user
      # meant to inspect.
      selected_exprs <- as.list(substitute(list(...)))[-1L]
      called_from_envir <- identical(parent.frame(), envir)
      for (i in seq_along(selected_objects)) {
        obj <- selected_objects[[i]]
        if (is.object(obj) || !is.null(dim(obj))) {
          stop("Object names and indices must be plain vectors.", call. = FALSE)
        }
        if (is.character(obj)) {
          if (anyNA(obj) || any(!nzchar(obj))) {
            stop("Object names must be non-missing, non-empty strings.", call. = FALSE)
          }
          objects <- c(objects, obj)
        } else if (typeof(obj) %in% c("integer", "double")) {
          if (is.null(all_objects)) {
            all_objects <- ls(envir = envir, all.names = TRUE)
          }
          if (any(!is.finite(obj)) || any(obj != trunc(obj)) ||
              any(obj < 1 | obj > length(all_objects))) {
            stop("Object indices must be finite integers within the available names.",
                 call. = FALSE)
          }
          if (called_from_envir && is.symbol(selected_exprs[[i]])) {
            var_name <- as.character(selected_exprs[[i]])
            warning(sprintf(paste0("`%s` was used as object indices. To inspect the ",
                                   "variable itself, quote its name: check_size(\"%s\")."),
                            var_name, var_name), call. = FALSE)
          }
          objects <- c(objects, all_objects[as.integer(obj)])
        } else {
          stop("Object names must be character vectors or numeric indices.", call. = FALSE)
        }
      }
    }
  }

  # Sort once so equally sized objects keep alphabetical order for every selector.
  objects <- sort(unique(objects))
  found <- vapply(objects, exists, logical(1), envir = envir, inherits = FALSE)
  if (any(!found)) {
    warning("Objects not found in `envir`: ", paste(objects[!found], collapse = ", "),
            call. = FALSE)
    objects <- objects[found]
  }

  if (length(objects) == 0) {
    .cat_line("No objects selected in `envir`.", type = "info")
  }

  size_bytes <- if (method == "lobstr") {
    function(obj) as.numeric(lobstr::obj_size(obj, env = envir))
  } else {
    function(obj) as.numeric(utils::object.size(obj))
  }
  object_metrics <- pbapply::pblapply(objects, function(x) {
    tryCatch({
      obj <- get(x, envir = envir, inherits = FALSE)
      # lobstr needs the values again for a total that counts shared storage once.
      list(size = size_bytes(obj) / (1024^2),
           class = paste(class(obj), collapse = ", "),
           value = if (method == "lobstr") obj)
    }, error = function(e) {
      list(size = NA_real_, class = "Unknown", error = conditionMessage(e))
    })
  })

  object_info <- data.frame(
    Object = objects,
    Class = vapply(object_metrics, `[[`, character(1), "class"),
    Size = vapply(object_metrics, `[[`, numeric(1), "size"),
    stringsAsFactors = FALSE
  )

  failed <- is.na(object_info$Size)
  if (any(failed)) {
    reasons <- vapply(object_metrics[failed], `[[`, character(1), "error")
    warning("Could not inspect objects: ",
            paste0(object_info$Object[failed], " (", reasons, ")", collapse = ", "),
            call. = FALSE)
  }
  object_info <- object_info %>%
    dplyr::filter(!is.na(Size)) %>%
    dplyr::arrange(dplyr::desc(Size))
  object_count <- nrow(object_info)
  total_mb <- sum(object_info$Size)
  if (method == "lobstr" && object_count > 0) {
    values <- unname(lapply(object_metrics[!failed], `[[`, "value"))
    total_bytes <- do.call(lobstr::obj_size, c(values, list(env = envir)))
    total_mb <- as.numeric(total_bytes) / (1024^2)
  }
  source_note <- if (method == "lobstr") {
    paste("Sizes are lobstr::obj_size() estimates. The total counts shared storage",
          "once, so it can be smaller than the sum of the rows.")
  } else {
    paste("Sizes are utils::object.size() estimates. The total can count shared storage",
          "more than once; environments and closures may be underestimated.")
  }
  if (object_count > 0) {
    object_info <- tibble::add_row(object_info, Object = "**TOTAL**", Class = "Summary",
                                   Size = total_mb, .before = 1)
  }

  # Share display units between body cells and the total subtitle. Thresholds
  # sit where a two-decimal label would round up to 1024 of the smaller unit.
  format_size <- function(size_mb) {
    dplyr::case_when(
      size_mb >= 1023.995             ~ sprintf("%.2f GB", size_mb / 1024),
      size_mb >= 1023.995 / 1024      ~ sprintf("%.2f MB", size_mb),
      size_mb >= 1023.5 / 1024^2      ~ sprintf("%.2f KB", size_mb * 1024),
      TRUE                            ~ sprintf("%.0f B", size_mb * 1024^2)
    )
  }
  object_info <- object_info %>%
    dplyr::mutate(
      Size_fmt = format_size(Size),
      Size_bar = Size,
      .after = Size
    )

  # Total size string
  total_str <- format_size(total_mb)

  # Render simple bars directly in HTML, including an all-zero column.
  bar_html <- function(x) {
    largest <- max(x[-1L], 0, na.rm = TRUE)
    widths <- if (largest > 0) pmin(100, 100 * x / largest) else rep(0, length(x))
    sprintf(paste0('<div style="width:110px;height:18px;">',
                   '<div style="background-color:#4CAF50;width:%.4f%%;',
                   'height:18px;"></div></div>'), widths)
  }
  environment(bar_html) <- baseenv()
  bar_text <- function(x) rep("", length(x))
  environment(bar_text) <- baseenv()

  # A zero-width range would take the palette midpoint; anchor it at zero so
  # one object or equally sized objects read as the largest, while all-zero
  # sizes stay white.
  size_domain <- if (object_count > 0) range(object_info$Size[-1L]) else c(0, 1)
  if (size_domain[[1L]] == size_domain[[2L]]) {
    size_domain <- c(0, if (size_domain[[2L]] > 0) size_domain[[2L]] else 1)
  }

  gt_table <- object_info %>%
    gt::gt() %>%
    gt::fmt_markdown(
      columns = "Object",
      rows = seq_len(nrow(object_info)) == 1L
    ) %>%
    gt::fmt(
      columns = "Size_bar",
      fns = list(html = bar_html, default = bar_text)
    ) %>%
    gt::data_color(
      columns = "Size",
      target_columns = "Size_fmt",
      rows = seq_len(nrow(object_info)) > 1L,
      palette = c("#FFFFFF", "#FF0000"),
      domain = size_domain,
      na_color = "transparent"
    ) %>%
    gt::cols_hide("Size") %>%
    gt::tab_header(
      title = gt::md("**Object Size Analysis**"),
      subtitle = gt::md(sprintf(
        "Total objects: %d | Total size: %s",
        object_count,
        total_str
      ))
    ) %>%
    gt::tab_source_note(source_note) %>%
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) %>%
    gt::tab_style(
      style = gt::cell_text(weight = "bold", color = "#FF0000"),
      locations = gt::cells_body(
        rows = seq_len(nrow(object_info)) == 1L
      )
    ) %>%
    gt::opt_table_font(font = "Arial") %>%
    gt::tab_options(
      table.font.size = gt::px(12),
      column_labels.background.color = "#E8F4FD",
      table.border.top.color = "black",
      table.border.bottom.color = "black"
    ) %>%
    gt::cols_label(
      Object = "Object",
      Class = "Class",
      Size_fmt = "Size",
      Size_bar = "Size Chart"
    )

  return(gt_table)
}
