# =============================================================================
# check_size.R -- Object size analysis in the global environment
# =============================================================================

#' Analyze Object Sizes in Global Environment
#'
#' Check memory usage of objects in \code{.GlobalEnv}. Outputs a styled
#' \code{gt} table with bar chart and color gradient.
#'
#' @param ... Object names (character vectors) or plain numeric vectors of
#'   finite, positive integer indices into the alphabetically sorted names in
#'   \code{.GlobalEnv}, including hidden names. With no arguments, all objects
#'   are analyzed. Duplicate names are inspected once. Missing names are
#'   skipped with a warning; empty selections do not select all objects.
#' @param pattern Optional single, non-missing regular expression for matching
#'   object names. Takes precedence over \code{...}; no matches select no objects.
#'
#' @return A \code{gt} table object, including a zero-row table when no objects
#'   can be inspected. Objects that fail to load are skipped with a warning.
#'
#' @examples
#' \dontrun{
#' check_size()
#' check_size(1:5)
#' check_size("data", "result", "model")
#' check_size(pattern = "data")
#' }
#'
#' @export
#' @family inspect
check_size <- function(..., pattern = NULL) {

  all_objects <- ls(envir = .GlobalEnv, all.names = TRUE)

  if (!is.null(pattern)) {
    if (!is.character(pattern) || length(pattern) != 1L || is.na(pattern)) {
      stop("`pattern` must be a single, non-missing character string.", call. = FALSE)
    }
    matched <- tryCatch(suppressWarnings(grepl(pattern, all_objects)),
                        error = function(e) {
                          stop("Invalid `pattern`: ", conditionMessage(e), call. = FALSE)
                        })
    objects <- all_objects[matched]
  } else {
    selected_objects <- list(...)
    if (length(selected_objects) == 0) {
      objects <- all_objects
    } else {
      objects <- character(0)
      for (obj in selected_objects) {
        if (is.object(obj) || !is.null(dim(obj))) {
          stop("Object names and indices must be plain vectors.", call. = FALSE)
        }
        if (is.character(obj)) {
          if (anyNA(obj) || any(!nzchar(obj))) {
            stop("Object names must be non-missing, non-empty strings.", call. = FALSE)
          }
          objects <- c(objects, obj)
        } else if (typeof(obj) %in% c("integer", "double")) {
          if (any(!is.finite(obj)) || any(obj != trunc(obj)) ||
              any(obj < 1 | obj > length(all_objects))) {
            stop("Object indices must be finite integers within the available names.",
                 call. = FALSE)
          }
          objects <- c(objects, all_objects[as.integer(obj)])
        } else {
          stop("Object names must be character vectors or numeric indices.", call. = FALSE)
        }
      }
    }
  }

  objects <- unique(objects)
  found <- vapply(objects, exists, logical(1), envir = .GlobalEnv, inherits = FALSE)
  if (any(!found)) {
    warning("Objects not found in `.GlobalEnv`: ", paste(objects[!found], collapse = ", "),
            call. = FALSE)
    objects <- objects[found]
  }

  if (length(objects) == 0) {
    .cat_line("No objects selected in the global environment.", type = "info")
  }

  object_metrics <- pbapply::pblapply(objects, function(x) {
    tryCatch({
      obj <- get(x, envir = .GlobalEnv, inherits = FALSE)
      list(size = as.numeric(utils::object.size(obj)) / (1024^2),
           class = paste(class(obj), collapse = ", "))
    }, error = function(e) {
      list(size = NA_real_, class = "Unknown")
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
    warning("Could not inspect objects: ", paste(object_info$Object[failed], collapse = ", "),
            call. = FALSE)
  }
  object_info <- object_info %>%
    dplyr::filter(!is.na(Size)) %>%
    dplyr::arrange(dplyr::desc(Size))
  object_count <- nrow(object_info)
  total_mb <- sum(object_info$Size)
  if (object_count > 0) {
    object_info <- tibble::add_row(object_info, Object = "**TOTAL**", Class = "Summary",
                                   Size = total_mb, .before = 1)
  }

  # Format size with auto unit (KB / MB / GB)
  object_info <- object_info %>%
    dplyr::mutate(
      Size_fmt = dplyr::case_when(
        Size >= 1024   ~ sprintf("%.2f GB", Size / 1024),
        Size >= 1      ~ sprintf("%.2f MB", Size),
        Size >= 1/1024 ~ sprintf("%.2f KB", Size * 1024),
        TRUE           ~ sprintf("%.4f MB", Size)
      ),
      Size_bar = Size,
      .after = Size
    )

  # Total size string
  total_str <- if (total_mb >= 1024) sprintf("%.2f GB", total_mb / 1024) else sprintf("%.2f MB", total_mb)

  # Render simple bars directly in HTML, including an all-zero column.
  bar_html <- function(x) {
    values <- as.numeric(x)
    largest <- max(values, 0, na.rm = TRUE)
    widths <- if (largest > 0) 100 * values / largest else rep(0, length(values))
    sprintf(paste0('<div style="width:110px;height:18px;">',
                   '<div style="background-color:#4CAF50;width:%.4f%%;',
                   'height:18px;"></div></div>'), widths)
  }
  environment(bar_html) <- baseenv()

  gt_table <- object_info %>%
    gt::gt() %>%
    gt::text_transform(
      locations = gt::cells_body(columns = "Size_bar"),
      fn = bar_html
    ) %>%
    gt::data_color(
      columns = "Size",
      rows = object_info$Object != "**TOTAL**",
      palette = c("#FFFFFF", "#FF0000"),
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
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) %>%
    gt::tab_style(
      style = gt::cell_text(weight = "bold", color = "#FF0000"),
      locations = gt::cells_body(
        rows = object_info$Object == "**TOTAL**"
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
