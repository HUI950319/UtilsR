# ============================================================================
# check_size.R -- Object size analysis in global environment
# ============================================================================

#' Analyze Object Sizes in Global Environment
#'
#' Check memory usage of objects in \code{.GlobalEnv}. Outputs a styled
#' \code{gt} table with bar chart and color gradient.
#'
#' @param ... Object names (character strings) or numeric indices. If empty,
#'   all objects are analyzed.
#' @param pattern Optional regex pattern for matching object names.
#'
#' @return A \code{gt} table object.
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
check_size <- function(..., pattern = NULL) {

  all_objects <- ls(envir = .GlobalEnv, all.names = TRUE)

  if (!is.null(pattern)) {
    objects <- all_objects[grepl(pattern, all_objects)]
  } else {
    selected_objects <- list(...)
    if (length(selected_objects) == 0) {
      objects <- all_objects
    } else {
      objects <- character(0)
      for (obj in selected_objects) {
        if (is.character(obj)) {
          objects <- c(objects, obj)
        } else if (is.numeric(obj)) {
          valid_indices <- obj[obj >= 1 & obj <= length(all_objects)]
          objects <- c(objects, all_objects[valid_indices])
        }
      }
    }
  }

  if (length(objects) == 0) {
    if (!is.null(pattern)) {
      .cat_line(
        sprintf("\u672a\u627e\u5230\u5339\u914d\u6a21\u5f0f: %s, \u5c06\u5206\u6790\u6240\u6709\u5bf9\u8c61",
                pattern),
        type = "error"
      )
    }
    .cat_line("Analysis all objects in the environment", type = "warning")
    objects <- all_objects
  }

  if (length(objects) == 0) {
    .cat_line("No objects found in the environment.", type = "error")
    return(data.frame(Object = character(), Class = character(),
                      Size = numeric(), stringsAsFactors = FALSE))
  }

  object_sizes <- pbapply::pblapply(objects, function(x) {
    tryCatch({
      utils::object.size(get(x, envir = .GlobalEnv)) / (1024^2)
    }, error = function(e) {
      NA_real_
    })
  })

  object_classes <- pbapply::pblapply(objects, function(x) {
    tryCatch({
      obj <- get(x, envir = .GlobalEnv)
      paste(class(obj), collapse = ", ")
    }, error = function(e) {
      "Unknown"
    })
  })

  object_info <- data.frame(
    Object = objects,
    Class = unlist(object_classes),
    Size = unlist(object_sizes),
    stringsAsFactors = FALSE
  )

  object_info <- object_info %>%
    dplyr::filter(!is.na(Size)) %>%
    dplyr::arrange(dplyr::desc(Size)) %>%
    {
      if (nrow(.) > 0) {
        tibble::add_row(., Object = "**TOTAL**", Class = "Summary",
                        Size = sum(.$Size, na.rm = TRUE), .before = 1)
      } else {
        .
      }
    }

  # Format size with auto unit (KB / MB / GB)
  object_info <- object_info %>%
    dplyr::mutate(
      Size_bar = Size,
      Size_fmt = dplyr::case_when(
        Size >= 1024   ~ sprintf("%.2f GB", Size / 1024),
        Size >= 1      ~ sprintf("%.2f MB", Size),
        Size >= 1/1024 ~ sprintf("%.2f KB", Size * 1024),
        TRUE           ~ sprintf("%.4f MB", Size)
      ),
      .after = Size
    )

  # Total size string
  total_mb <- sum(object_info$Size[object_info$Object != "**TOTAL**"], na.rm = TRUE)
  total_str <- if (total_mb >= 1024) sprintf("%.2f GB", total_mb / 1024) else sprintf("%.2f MB", total_mb)

  gt_table <- object_info %>%
    gt::gt() %>%
    gtExtras::gt_plt_bar(
      column = Size_bar,
      keep_column = FALSE,
      color = "#4CAF50",
      scale_type = "number",
      width = 30
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
        nrow(object_info) - 1,
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
