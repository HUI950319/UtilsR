# =============================================================================
# plt_cat.R -- Unified categorical variable plot (11 chart types)
# =============================================================================
#
# Architecture (4 layers):
#
#   L1  plt_cat(data, stat.by, group.by, split.by, type, ...)
#         |                                         -- public API
#         |   split.by splits the data and recombines the panels with
#         |   patchwork; only the final figure is measured and saved.
#         +-- L2  .plt_cat_single()     draw one normalized panel, without saving
#         |
#         +-- L3  set types (stat.by is a vector of >= 2 columns)
#         |     .resolve_stat_level()   pick the level defining membership
#         |     .build_set_list()       data + stat_level -> list of sets
#         |           +-- L4  .plt_cat_sankey / .plt_cat_chord /
#         |                   .plt_cat_venn   / .plt_cat_upset
#         |
#         +-- L3  standard types (stat.by is a single column)
#               .prepare_cat_data()     frequency table with the columns
#               |                       stat_var / group_var / value
#               +-- L4  .plt_cat_bar   / .plt_cat_rose  / .plt_cat_ring /
#               |       .plt_cat_pie   / .plt_cat_trend / .plt_cat_area /
#               |       .plt_cat_dot
#               +-- L4  .build_bg_layer()   alternating bands for dodge mode
#                         .GeomBg          follow trained discrete positions
#               +-- L4  .add_cat_labels()   ggrepel value labels
#
# The L4 renderers live in plt_cat_types.R; this file owns data preparation,
# palette / theme resolution, and the two switch() dispatch tables.
# =============================================================================

#' Unified Categorical Variable Plot
#'
#' A single entry point for 11 categorical chart types: bar, rose, ring, pie,
#' trend, area, dot, sankey, chord, venn, and upset.
#'
#' @param data A data frame (or Seurat object metadata).
#' @param stat.by Character. Column name(s) for the categorical variable to
#'   summarise. For standard types (bar, rose, ring, pie, trend, area, dot) a
#'   single column name. For set types (sankey, chord, venn, upset) a character
#'   vector of >= 2 column names. Venn plots support at most seven columns;
#'   use \code{type = "upset"} for larger sets.
#'   Distinct numeric values with identical short text representations receive
#'   more precise labels, including AsIs, haven labelled, and complex values.
#'   Date, date-time, difftime, and lubridate values with identical display
#'   labels receive exact-value suffixes (calendar components for periods;
#'   start and length for intervals). This also applies to grouping, splitting,
#'   and background columns; other time labels retain their original text.
#' @param group.by Character. Optional grouping variable for standard types.
#'   Ignored for set types. Area plots require at least two displayed group
#'   levels in each panel.
#' @param split.by Character. Optional splitting variable. Splits data, creates
#'   one plot per level, and combines with \pkg{patchwork}. Not available for
#'   \code{type = "chord"}. UpSet panels without matching members are retained
#'   with a no-matching-members placeholder. Dot panels use one shared size
#'   scale so equal quantities have equal circle areas across panels. Venn
#'   panels likewise share one count-to-fill scale.
#' @param type Chart type. One of \code{"bar"}, \code{"rose"}, \code{"ring"},
#'   \code{"pie"}, \code{"trend"}, \code{"area"}, \code{"dot"}, \code{"sankey"},
#'   \code{"chord"}, \code{"venn"}, \code{"upset"}. UpSet plots show at most
#'   the 20 most frequent non-empty intersections per panel, with a warning
#'   reporting how many intersections are omitted when the limit is exceeded.
#'   Chord plots omit unused factor levels before constructing frequencies.
#'   Empty-string chord categories remain distinct from space-only categories.
#' @param stat Statistic for standard types: \code{"percent"} (default) or
#'   \code{"count"}.
#' @param position Bar position: \code{"stack"} (default) or \code{"dodge"}.
#' @param palette Colour palette. One of:
#'   \itemize{
#'     \item \code{NULL} (default): uses \code{pal_lancet}.
#'     \item A single string matching a name in \code{palette_list}: uses
#'       \code{pal_get()}.
#'     \item A character vector of colours: used in level order. A panel of
#'       \code{split.by} keeps the colours of the whole figure.
#'     \item A named character vector: mapped by level. It must cover every
#'       non-missing level; the generated missing level may be left out
#'       and then takes \code{NA_color}. An empty name matches an empty-string
#'       category when that category is present.
#'   }
#' @param alpha Numeric 0--1. Colour transparency. Default 0.8. For Venn plots,
#'   controls region fill transparency.
#' @param label Logical. Show value labels? Default \code{FALSE}. Set names
#'   and Sankey node names are independent of value labels.
#'   Venn plots without matching members show zero counts without percentages.
#' @param label.size Numeric. Label text size. Default 3.5.
#' @param label.fg Character. Label foreground colour. Default \code{"black"}.
#' @param label.bg Character. Label background colour. Default \code{"white"}.
#'   For Venn plots, the fill colour of the value-label box.
#' @param label.bg.r Numeric. Label background corner radius. Default 0.1.
#'   For Venn plots, the label-box corner radius in lines.
#' @param bg.by Character. Column name for background grouping in dodge mode
#'   for bar, trend and dot plots with \code{group.by}; ignored otherwise.
#'   Must be a superset of \code{group.by} (each group.by level belongs to
#'   exactly one bg.by level). Adds alternating background colour bands.
#'   Default \code{NULL} (no background).
#' @param bg_palette Character vector of background band colours.
#'   Default \code{NULL} uses alternating \code{c("grey85", "transparent")}.
#'   A named vector is matched to background category names. Split panels share
#'   one category-to-colour mapping.
#' @param bg_alpha Numeric 0--1. Background band transparency. Default 0.15.
#' @param flip Logical. Flip coordinates for bar type? Default \code{FALSE}.
#' @param NA_color Character. Colour for NA values. Default \code{"grey80"}.
#' @param NA_stat Logical. Include NA in the frequency table? Default
#'   \code{FALSE} (NAs are dropped). If \code{TRUE}, NAs are kept and shown
#'   with \code{NA_color}, including missing grouping and split values.
#'   Missing labels are distinct from literal "NA" values.
#' @param keep_empty Logical. Keep empty factor levels in plots?
#'   Default \code{FALSE}.
#' @param stat_level Vector or list. For venn/upset types, the value(s) in
#'   each \code{stat.by} column that count as "positive". Default \code{NULL}
#'   uses \code{TRUE} for logical columns and the declared positive level of
#'   No/Yes factors, even when no positive values occur. For other columns it
#'   auto-detects \code{TRUE}, \code{"Yes"}, \code{"yes"}, \code{1},
#'   \code{"TRUE"}, \code{"1"}, or uses the first factor level. An
#'   entirely missing column has no automatic positive level, even with
#'   \code{NA_stat = TRUE}. With \code{split.by}, membership values are
#'   resolved once for all panels.
#'   An unnamed vector supplies one shared value or one value per selected
#'   column in order. Named vectors and named lists match column names and
#'   must cover exactly the selected columns. Numeric and time values are
#'   matched before label formatting. Mixed \code{integer64} and numeric
#'   selections require lossless conversion. Supply time values in a list.
#' @param title Character. Plot title, or overall title for split figures.
#'   Default \code{NULL}.
#' @param subtitle Character. Plot subtitle, or overall subtitle for split
#'   figures. Default \code{NULL}.
#' @param xlab Character. X-axis label. Default \code{NULL}.
#' @param ylab Character. Y-axis label. Default \code{NULL} (auto-set based on
#'   \code{stat}).
#' @param legend.position Legend position: \code{"right"} (default),
#'   \code{"left"}, \code{"bottom"}, \code{"top"}, or \code{"none"}.
#' @param legend.direction Legend direction: \code{"vertical"} (default) or
#'   \code{"horizontal"}.
#' @param aspect.ratio Numeric. Panel aspect ratio. Default \code{NULL} (auto).
#'   Automatically set to 1 for rose, ring, and pie types.
#' @param facet_nrow Positive integer. Number of rows when combining split panels.
#'   Default \code{NULL} (auto).
#' @param facet_ncol Positive integer. Number of columns when combining split
#'   panels. Default \code{NULL} (auto). When both dimensions are supplied,
#'   their grid must accommodate all panels.
#' @param facet_byrow Logical. Fill split panels by row? Default \code{TRUE}.
#' @param base_size Numeric. Base font size for \code{theme_my()}.
#'   Default 14.
#' @param force Logical. Force plotting when variables have > 100 levels?
#'   Default \code{FALSE}. With \code{keep_empty = TRUE}, standard types count
#'   retained factor levels toward this limit. Frequency tables with
#'   \code{2^31} or more cells are always rejected before allocation.
#' @param ... Currently unused. Additional arguments are rejected.
#'
#' @param save \code{NULL}, an empty list (default), or a named list forwarded
#'   to \code{RegR::save_plt()} for PDF output: \code{filename} and optionally
#'   \code{width} and \code{height}. A \code{width} or \code{height} left out
#'   defaults to the page the plot is laid out for -- a 4.5 x 4 in panel, or
#'   3.5 x 3.5 in per panel of a split, beside the measured axis text and
#'   legend; 5 x 5 in for a Venn diagram, a 6 x 4.5 in UpSet panel, a 6 x 5 in
#'   Sankey panel and a 7 x 7 in chord diagram -- which every call prints with
#'   the matching \code{save} line. Saving, and the size note, need the
#'   \pkg{RegR} package.
#'
#' @return A ggplot object (or patchwork for split/set types; a recorded base
#'   plot for \code{"chord"}), carrying that page size as \code{attr(p,
#'   "plot_size")}, \code{c(width, height)} in inches.
#'
#' @note Set types require additional packages:
#'   \itemize{
#'     \item \code{sankey}: \pkg{ggsankey}
#'     \item \code{chord}: \pkg{circlize}
#'     \item \code{venn}: \pkg{ggVennDiagram}
#'     \item \code{upset}: \pkg{ggupset}
#'   }
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   Type  = factor(sample(c("A","B","C"), 200, TRUE)),
#'   Group = factor(sample(c("X","Y","Z"), 200, TRUE)),
#'   Batch = factor(sample(c("B1","B2"), 200, TRUE))
#' )
#' df$Region <- factor(ifelse(df$Group %in% c("X","Y"), "R1", "R2"))
#'
#' # ===== 1. Bar =====
#' plt_cat(df, "Type", "Group", type = "bar")                      # stacked %
#' plt_cat(df, "Type", "Group", type = "bar", stat = "count",
#'         position = "dodge")                                      # dodged count
#' plt_cat(df, "Type", "Group", type = "bar", flip = TRUE,
#'         label = TRUE)                                            # flipped + labels
#' plt_cat(df, "Type", "Group", type = "bar", position = "dodge",
#'         bg.by = "Region")                                        # background bands
#' plt_cat(df, "Type", "Group", type = "bar", position = "dodge",
#'         bg.by = "Region",
#'         bg_palette = c("lightblue", "lightyellow"))              # custom bg colors
#' plt_cat(df, "Type", type = "bar", stat = "count",
#'         label = TRUE, legend.position = "none")                  # no group
#'
#' # ===== 2. Rose =====
#' plt_cat(df, "Type", "Group", type = "rose")
#' plt_cat(df, "Type", "Group", type = "rose", stat = "count",
#'         position = "dodge")
#'
#' # ===== 3. Ring (donut) =====
#' plt_cat(df, "Type", type = "ring")
#' plt_cat(df, "Type", type = "ring", label = TRUE,
#'         palette = "Paired")
#' plt_cat(df, "Type", "Group", type = "ring", stat = "count",
#'         position = "dodge")
#'
#' # ===== 4. Pie =====
#' plt_cat(df, "Type", type = "pie", label = TRUE)
#' plt_cat(df, "Type", type = "pie", palette = "Paired",
#'         title = "Type Distribution", subtitle = "n = 200")
#' plt_cat(df, "Type", type = "pie", legend.position = "bottom",
#'         legend.direction = "horizontal")
#'
#' # ===== 5. Trend =====
#' plt_cat(df, "Type", "Group", type = "trend", stat = "count")
#' plt_cat(df, "Type", "Group", type = "trend", stat = "count",
#'         label = TRUE)
#'
#' # ===== 6. Area =====
#' plt_cat(df, "Type", "Group", type = "area", stat = "count")
#' plt_cat(df, "Type", "Group", type = "area", stat = "count",
#'         position = "dodge")
#'
#' # ===== 7. Dot =====
#' plt_cat(df, "Type", "Group", type = "dot")
#' plt_cat(df, "Type", "Group", type = "dot", label = TRUE,
#'         stat = "count")
#'
#' # ===== split.by / NA / keep_empty / aspect =====
#' plt_cat(df, "Type", "Group", split.by = "Batch", type = "bar")
#' plt_cat(df, "Type", split.by = "Batch", type = "pie",
#'         facet_ncol = 2)
#'
#' # NA handling
#' df_na <- df; df_na$Type[1:20] <- NA
#' plt_cat(df_na, "Type", "Group", type = "bar",
#'         NA_stat = TRUE, NA_color = "red")
#'
#' # keep_empty: preserve dropped levels
#' df2 <- df[df$Type != "C", ]
#' plt_cat(df2, "Type", "Group", type = "bar", keep_empty = TRUE)
#'
#' # aspect.ratio
#' plt_cat(df, "Type", "Group", type = "bar", aspect.ratio = 0.5)
#'
#' # ===== 8. Sankey =====
#' plt_cat(df, c("Type", "Group"), type = "sankey")
#' plt_cat(df, c("Type", "Group", "Batch"), type = "sankey")
#'
#' # ===== 9. Chord =====
#' plt_cat(df, c("Type", "Group"), type = "chord")
#'
#' # ===== 10. Venn =====
#' set.seed(42)
#' df_bin <- data.frame(
#'   A = sample(c("Yes","No"), 100, TRUE),
#'   B = sample(c("Yes","No"), 100, TRUE),
#'   C = sample(c("Yes","No"), 100, TRUE)
#' )
#' plt_cat(df_bin, c("A","B","C"), type = "venn")
#' plt_cat(df, c("Type","Group"), type = "venn", stat_level = c("A","X"))
#'
#' # ===== 11. UpSet =====
#' plt_cat(df_bin, c("A","B","C"), type = "upset")
#' plt_cat(df, c("Type","Group"), type = "upset", stat_level = c("A","X"))
#'
#' @export
#' @family plot
plt_cat <- function(data,
                    stat.by,
                    group.by = NULL,
                    split.by = NULL,
                    type = c("bar", "rose", "ring", "pie", "trend",
                             "area", "dot", "sankey", "chord",
                             "venn", "upset"),
                    stat = c("percent", "count"),
                    position = c("stack", "dodge"),
                    palette = NULL,
                    alpha = 0.8,
                    label = FALSE,
                    label.size = 3.5,
                    label.fg = "black",
                    label.bg = "white",
                    label.bg.r = 0.1,
                    bg.by = NULL,
                    bg_palette = NULL,
                    bg_alpha = 0.15,
                    flip = FALSE,
                    NA_color = "grey80",
                    NA_stat = FALSE,
                    keep_empty = FALSE,
                    stat_level = NULL,
                    title = NULL,
                    subtitle = NULL,
                    xlab = NULL,
                    ylab = NULL,
                    legend.position = "right",
                    legend.direction = "vertical",
                    aspect.ratio = NULL,
                    facet_nrow = NULL,
                    facet_ncol = NULL,
                    facet_byrow = TRUE,
                    base_size = 14,
                    force = FALSE,
                    ...,
                    save = list()) {
  finish <- function(p, panel = function(n_col, n_row) {
    if (n_col * n_row > 1) c(3.5, 3.5) else c(4.5, 4)
  }, size = NULL) {
    .save_sized(p, save, panel, size = size, lead = "plot laid out for",
                filename = "Figure X. Categorical distribution.pdf")
  }

  # --- Input validation -------------------------------------------------------
  rlang::check_dots_empty()
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.cls {class(data)}}.")
  }
  data <- as.data.frame(data)
  if (!nrow(data)) cli::cli_abort("{.arg data} must contain at least one observation.")
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data))) {
    cli::cli_abort("{.arg data} must have unique, non-empty column names.")
  }

  type     <- match.arg(type)
  stat     <- match.arg(stat)
  position <- match.arg(position)
  set_types <- c("sankey", "chord", "venn", "upset")
  std_types <- c("bar", "rose", "ring", "pie", "trend", "area", "dot")

  if (!is.character(stat.by) || length(stat.by) == 0 || !is.null(dim(stat.by)) ||
      anyNA(stat.by) || any(!nzchar(stat.by)) || anyDuplicated(stat.by)) {
    cli::cli_abort("{.arg stat.by} must contain unique, non-empty column names.")
  }
  selectors <- list(group.by = group.by, split.by = split.by, bg.by = bg.by)
  for (arg in names(selectors)) {
    value <- selectors[[arg]]
    if (!is.null(value) && (!is.character(value) || !is.null(dim(value)) || length(value) != 1L ||
                           is.na(value) || !nzchar(value))) {
      cli::cli_abort("{.arg {arg}} must be a single non-missing column name.")
    }
  }
  flags <- list(label = label, flip = flip, NA_stat = NA_stat,
                keep_empty = keep_empty, force = force, facet_byrow = facet_byrow)
  for (arg in names(flags)) {
    value <- flags[[arg]]
    if (!is.logical(value) || !is.null(dim(value)) || length(value) != 1L || is.na(value)) {
      cli::cli_abort("{.arg {arg}} must be TRUE or FALSE.")
    }
  }
  dimensions <- list(facet_nrow = facet_nrow, facet_ncol = facet_ncol)
  for (arg in names(dimensions)) {
    value <- dimensions[[arg]]
    if (!is.null(value) &&
        (!is.numeric(value) || is.object(value) || length(value) != 1L ||
         !is.null(dim(value)) || !is.finite(value) || value < 1 ||
         value > .Machine$integer.max || value != floor(value))) {
      cli::cli_abort("{.arg {arg}} must be a single positive integer or NULL.")
    }
  }
  if (type == "chord" && !is.null(split.by)) {
    cli::cli_abort("{.arg split.by} is not supported for {.code type = \"chord\"}; draw each chord plot separately.")
  }

  # Resolve the columns actually used before checking or filtering their values.
  if (type %in% set_types) {
    if (length(stat.by) < 2) {
      cli::cli_abort(
        "Type {.val {type}} requires {.arg stat.by} with >= 2 column names."
      )
    }
    if (type == "venn" && length(stat.by) > 7L) {
      cli::cli_abort("Venn plots support at most seven sets; use {.code type = \"upset\"} for larger inputs.")
    }
    if (!is.null(group.by)) {
      cli::cli_warn(
        "{.arg group.by} is ignored for set type {.val {type}}."
      )
      group.by <- NULL
      bg.by <- NULL
    }
    if (type == "chord" && length(stat.by) > 2) {
      cli::cli_warn("Chord uses only the first 2 elements of {.arg stat.by}.")
      stat.by <- stat.by[1:2]
    }
  } else if (length(stat.by) > 1) {
    cli::cli_warn(
      "Type {.val {type}} uses only the first element of {.arg stat.by}."
    )
    stat.by <- stat.by[1]
  }

  if (!is.null(bg.by) && (is.null(group.by) ||
      !type %in% c("bar", "trend", "dot") || position != "dodge")) {
    cli::cli_warn("{.arg bg.by} is ignored outside grouped bar, trend or dot plots in dodge mode.")
    bg.by <- NULL
  }

  missing_cols <- stat.by[!stat.by %in% names(data)]
  if (length(missing_cols) > 0) {
    cli::cli_abort("Column{?s} not found in {.arg data}: {.val {missing_cols}}")
  }
  if (!is.null(group.by) && !group.by %in% names(data)) {
    cli::cli_abort("Column {.val {group.by}} not found in {.arg data}.")
  }
  if (!is.null(split.by) && !split.by %in% names(data)) {
    cli::cli_abort("Column {.val {split.by}} not found in {.arg data}.")
  }
  if (!is.null(bg.by) && !bg.by %in% names(data)) {
    cli::cli_abort("Column {.val {bg.by}} not found in {.arg data}.")
  }

  # --- Safety check for high-cardinality columns ------------------------------
  selected <- unique(c(stat.by, group.by, split.by, bg.by))
  data <- data[, selected, drop = FALSE]
  for (col in selected) {
    x <- data[[col]]
    if (!is.null(dim(x)) || (is.list(x) && !inherits(x, "POSIXlt"))) {
      cli::cli_abort("Column {.val {col}} must be a one-dimensional vector, not a list or matrix column.")
    }
    .register_integer64(x)
  }
  if (!force) {
    all_cols <- unique(c(stat.by, if (!type %in% set_types) group.by, split.by))
    high_card <- vapply(all_cols, function(col) {
      x <- data[[col]]
      if (type %in% std_types && keep_empty && col %in% c(stat.by, group.by) && is.factor(x)) {
        nlevels(x)
      } else if (inherits(x, "haven_labelled_spss")) {
        if (!requireNamespace("haven", quietly = TRUE)) {
          cli::cli_abort("Inspecting {.cls {class(x)[1]}} columns requires package {.pkg haven}.")
        }
        missing <- is.na(x)
        length(unique(vctrs::vec_data(x)[!missing])) + as.integer(NA_stat && any(missing))
      } else if (inherits(x, "Period")) {
        if (!requireNamespace("lubridate", quietly = TRUE)) {
          cli::cli_abort("Inspecting {.cls Period} columns requires package {.pkg lubridate}.")
        }
        missing <- is.na(x)
        length(unique(.cat_time_key(x[!missing]))) + as.integer(NA_stat && any(missing))
      } else {
        length(unique(x))
      }
    }, integer(1))
    high_card <- high_card[high_card > 100]
    if (length(high_card) > 0) {
      cli::cli_abort(c(
        "Column{?s} with > 100 levels: {.val {names(high_card)}}.",
        "i" = "Set {.arg force = TRUE} to override."
      ))
    }
  }

  # --- Ensure factors ---------------------------------------------------------
  auto_levels <- list()
  if (is.null(stat_level) && type %in% c("venn", "upset")) {
    auto_levels <- lapply(data[stat.by], function(x) {
      if (is.logical(x)) return("TRUE")
      if (is.factor(x)) {
        labels <- levels(x)
        if (length(labels) == 2L && setequal(tolower(labels), c("no", "yes"))) {
          return(labels[tolower(labels) == "yes"])
        }
      }
      NULL
    })
  }
  numeric_labels <- list()
  for (col in unique(c(stat.by, group.by, split.by, bg.by))) {
    if (!is.null(col) && col %in% names(data) && !is.factor(data[[col]])) {
      x <- data[[col]]
      track_identity <- type %in% c("venn", "upset") && col %in% stat.by
      pkg <- if (inherits(x, "haven_labelled")) "haven" else
        if (inherits(x, "integer64")) "bit64" else
          if (inherits(x, c("Duration", "Period", "Interval"))) "lubridate" else NULL
      if (!is.null(pkg) && !requireNamespace(pkg, quietly = TRUE)) {
        cli::cli_abort("Inspecting {.cls {class(x)[1]}} columns requires package {.pkg {pkg}}.")
      }
      missing <- is.na(x)
      values <- as.character(x)
      time_key <- .cat_time_key(x)
      if (!is.null(time_key)) {
        distinct <- unique(time_key[!missing])
        labels <- values[match(distinct, time_key)]
        collision <- duplicated(labels) | duplicated(labels, fromLast = TRUE)
        if (any(collision)) {
          labels[collision] <- paste0(labels[collision], " [", distinct[collision], "]")
          values[!missing] <- labels[match(time_key[!missing], distinct)]
        }
        if (track_identity) {
          time_classes <- c("Period", "Interval", "difftime", "Date", "POSIXt", "Duration")
          time_class <- time_classes[inherits(x, time_classes, which = TRUE) > 0L][1L]
          numeric_labels[[col]] <- list(values = distinct, labels = labels,
                                        time = TRUE, class = time_class,
                                        units = attr(x, "units"))
        }
      } else if (track_identity && inherits(x, "integer64")) {
        numeric_labels[[col]] <- list(integer64 = TRUE)
      } else if ((is.double(x) || is.complex(x) || (track_identity && is.integer(x))) &&
          (!is.object(x) || identical(class(x), "AsIs") || inherits(x, "haven_labelled"))) {
        raw <- unclass(x)
        distinct <- unique(raw[!missing])
        labels <- as.character(distinct)
        collision <- duplicated(labels) | duplicated(labels, fromLast = TRUE)
        if (any(collision)) {
          labels[collision] <- if (is.complex(distinct)) {
            sprintf("%.17g%+.17gi", Re(distinct[collision]), Im(distinct[collision]))
          } else sprintf("%.17g", distinct[collision])
          values[!missing] <- labels[match(raw[!missing], distinct)]
        }
        if (track_identity) {
          numeric_labels[[col]] <- list(values = distinct, labels = labels)
        }
      }
      values[missing] <- NA_character_
      data[[col]] <- factor(values, levels = unique(values))
    }
  }

  # --- NA handling ------------------------------------------------------------
  na_levels <- character()
  if (!NA_stat) {
    cols_check <- unique(c(stat.by, group.by, split.by))
    n_before <- nrow(data)
    keep <- rep(TRUE, n_before)
    for (col in cols_check) {
      x <- data[[col]]
      ordinary_factor <- identical(class(x), "factor") || identical(class(x), c("ordered", "factor"))
      missing <- if (ordinary_factor && !anyNA(levels(x))) is.na(x) else is.na(as.character(x))
      keep <- keep & !missing
    }
    n_after <- sum(keep)
    if (n_after < n_before) data <- data[keep, , drop = FALSE]
    if (n_after < n_before) {
      cli::cli_inform(
        "Removed {n_before - n_after} row{?s} containing NA values."
      )
    }
  } else {
    na_cols <- unique(c(stat.by, group.by, split.by))
    used_levels <- unique(unlist(lapply(na_cols, function(col) levels(data[[col]]))))
    used_levels <- used_levels[!is.na(used_levels)]
    missing_level <- tail(make.unique(c(used_levels,
      if ("NA" %in% used_levels) "<NA>" else "NA")), 1L)
    for (col in na_cols) {
      values <- as.character(data[[col]])
      if (anyNA(values)) {
        lvls <- levels(data[[col]])
        lvls <- lvls[!is.na(lvls)]
        values[is.na(values)] <- missing_level
        data[[col]] <- factor(values, levels = c(lvls, missing_level))
        na_levels[col] <- missing_level
      }
    }
  }

  # --- Resolve colours (NO alpha baked in -- alpha applied only in geoms) -----
  if (!nrow(data)) cli::cli_abort("No observations remain after excluding missing values.")
  if (type %in% std_types && !keep_empty) {
    for (col in unique(c(stat.by, group.by))) {
      data[[col]] <- droplevels(data[[col]])
    }
  }
  # A named palette maps by level, as in plt_con(); an unnamed one by position.
  missing_levels <- unname(na_levels[intersect(names(na_levels), stat.by)])
  level_colors <- function(lvls) {
    if (is.null(names(palette))) {
      return(stats::setNames(.resolve_color(palette, n = length(lvls)), lvls))
    }
    required <- setdiff(lvls, missing_levels)
    if (!is.null(dim(palette))) cli::cli_abort("Named {.arg palette} must be one-dimensional.")
    if (!is.character(palette) || anyNA(names(palette)) ||
        (any(!nzchar(names(palette))) && !"" %in% lvls) ||
        anyDuplicated(names(palette)) ||
        !all(required %in% names(palette))) {
      cli::cli_abort("Named {.arg palette} must contain each level with unique names matching the categories.")
    }
    out <- stats::setNames(unname(palette[match(lvls, names(palette))]), lvls)
    out[lvls %in% missing_levels] <- NA_character_
    .resolve_color_values(out, "palette")
  }
  if (type %in% std_types) {
    stat_levels <- levels(data[[stat.by[1]]])
    colors <- level_colors(stat_levels)
  } else {
    all_levels <- unique(unlist(lapply(stat.by, function(s) levels(factor(data[[s]])))))
    colors <- level_colors(all_levels)
  }
  missing <- names(colors) %in% missing_levels
  if (any(missing)) colors[missing] <- .resolve_color_values(NA_color, "NA_color")

  # --- Auto aspect.ratio for polar types --------------------------------------
  if (is.null(aspect.ratio) && type %in% c("rose", "ring", "pie")) {
    aspect.ratio <- 1
  }

  if (type %in% c("venn", "upset")) {
    stat_level <- .resolve_stat_level(data, stat.by, stat_level, numeric_labels,
                                      na_levels, auto_levels)
  }

  draw_one <- function(panel_data, panel_title) {
    .plt_cat_single(panel_data, stat.by, group.by, type, stat, position,
      colors, alpha, label, label.size, label.fg, label.bg, label.bg.r,
      bg.by, bg_palette, bg_alpha, flip, NA_stat, keep_empty, stat_level,
      panel_title, if (is.null(split.by)) subtitle else NULL,
      xlab, ylab, legend.position, legend.direction,
      aspect.ratio, base_size, split_panel = !is.null(split.by))
  }

  # --- Handle split.by --------------------------------------------------------
  if (!is.null(split.by)) {
    panels <- factor(data[[split.by]])
    split_levels <- levels(panels)
    panel_rows <- split(seq_len(nrow(data)), panels)
    if (!is.null(facet_nrow) && !is.null(facet_ncol) &&
        facet_nrow < ceiling(length(split_levels) / facet_ncol)) {
      cli::cli_abort("{.arg facet_nrow} and {.arg facet_ncol} must accommodate all {length(split_levels)} panels.")
    }
    if (!is.null(bg.by) && is.null(names(bg_palette))) {
      bg_levels <- unique(as.character(data[[bg.by]])[order(as.integer(data[[group.by]]))])
      bg_levels <- bg_levels[!is.na(bg_levels)]
      bg_palette <- stats::setNames(rep_len(as.character(
        bg_palette %||% c("grey85", "transparent")), length(bg_levels)), bg_levels)
    }
    plot_list <- lapply(seq_along(panel_rows), function(i) {
      sub_data <- data[panel_rows[[i]], , drop = FALSE]
      # each panel is reported as part of the split figure, not on its own
      cli::cli_fmt(sub <- draw_one(sub_data, split_levels[i]))
      sub
    })
    if (type %in% c("dot", "venn")) {
      quantity_limits <- range(vapply(plot_list, function(panel) {
        range(if (type == "dot") panel$data$value else panel$layers[[1]]$data$count)
      }, c(0, 0)))
      # draw_one() constructs an independent scale for each panel.
      for (panel in plot_list) {
        scale <- panel$scales$get_scales(if (type == "dot") "size" else "fill")
        scale$limits <- quantity_limits
      }
    }
    p <- patchwork::wrap_plots(plot_list, nrow = facet_nrow, ncol = facet_ncol,
                              byrow = facet_byrow) +
      patchwork::plot_layout(guides = "collect")
    if (!is.null(title) || !is.null(subtitle)) {
      p <- p + patchwork::plot_annotation(title = title, subtitle = subtitle,
        theme = theme_my(base_size = base_size))
    }
    return(finish(p))
  }

  p <- draw_one(data, title)
  switch(type,
    chord = finish(p, size = c(7, 7)),
    venn = finish(p, c(5, 5)),
    upset = finish(p, c(6, 4.5)),
    sankey = finish(p, c(6, 5)),
    finish(p)
  )
}


#' Draw one normalized categorical panel without measuring or saving it
#' @noRd
.plt_cat_single <- function(data, stat.by, group.by, type, stat, position,
                            colors, alpha, label, label.size, label.fg, label.bg,
                            label.bg.r, bg.by, bg_palette, bg_alpha, flip,
                            NA_stat, keep_empty, stat_level, title, subtitle,
                            xlab, ylab, legend.position, legend.direction,
                            aspect.ratio, base_size, split_panel = FALSE) {
  # Returned plot environments must not retain promises to the split caller.
  invisible(list(data, stat.by, group.by, type, stat, position, colors, alpha,
    label, label.size, label.fg, label.bg, label.bg.r, bg.by, bg_palette,
    bg_alpha, flip, NA_stat, keep_empty, stat_level, title, subtitle,
    xlab, ylab, legend.position, legend.direction, aspect.ratio, base_size,
    split_panel))

  # --- Dispatch to type-specific functions ------------------------------------
  if (type %in% c("sankey", "chord", "venn", "upset")) {
    p <- switch(type,
      sankey = .plt_cat_sankey(data = data, stat.by = stat.by, cols = colors,
                               alpha = alpha),
      chord  = .plt_cat_chord(data = data, stat.by = stat.by, cols = colors,
                               alpha = alpha),
      venn   = .plt_cat_venn(data = data, stat.by = stat.by, cols = colors,
                               stat_level = stat_level, label = label,
                               label.size = label.size, label.fg = label.fg,
                               alpha = alpha, label.bg = label.bg, label.bg.r = label.bg.r),
      upset  = .plt_cat_upset(data = data, stat.by = stat.by, cols = colors,
                               stat_level = stat_level, allow_empty = split_panel,
                               alpha = alpha, label = label,
                               label.fg = label.fg, label.size = label.size,
                               label.bg = label.bg, label.bg.r = label.bg.r)
    )
    if (inherits(p, "gg")) {
      if (!is.null(title) || !is.null(subtitle)) {
        p <- p + ggplot2::labs(title = title, subtitle = subtitle)
      }
      if (!is.null(xlab)) p <- p + ggplot2::labs(x = xlab)
      if (!is.null(ylab)) p <- p + ggplot2::labs(y = ylab)
      p <- p + ggplot2::theme(text = ggplot2::element_text(size = base_size),
                              legend.position = legend.position,
                              legend.direction = legend.direction)
      if (!is.null(aspect.ratio)) p <- p + ggplot2::theme(aspect.ratio = aspect.ratio)
    }
    return(p)
  }

  # --- Standard types: prepare data then plot ---------------------------------
  if (!keep_empty) {
    for (col in unique(c(stat.by, group.by))) data[[col]] <- droplevels(data[[col]])
  }
  plotdata <- .prepare_cat_data(data, stat.by, group.by, stat,
                                NA_stat = NA_stat,
                                keep_empty = keep_empty || type %in% c("area", "trend"))

  p <- switch(type,
    bar   = .plt_cat_bar(plotdata, cols = colors, alpha = alpha,
                          position = position, keep_empty = keep_empty),
    rose  = .plt_cat_rose(plotdata, cols = colors, alpha = alpha,
                           position = position, keep_empty = keep_empty),
    ring  = .plt_cat_ring(plotdata, cols = colors, alpha = alpha,
                          position = position, keep_empty = keep_empty),
    pie   = .plt_cat_pie(plotdata, cols = colors, alpha = alpha),
    trend = .plt_cat_trend(plotdata, cols = colors, alpha = alpha,
                            position = position, keep_empty = keep_empty),
    area  = .plt_cat_area(plotdata, cols = colors, alpha = alpha,
                           position = position, keep_empty = keep_empty),
    dot   = .plt_cat_dot(plotdata, cols = colors, alpha = alpha,
                          keep_empty = keep_empty)
  )

  if (split_panel) {
    # These scales and layers were independently constructed for this panel.
    # Identical fill keys let patchwork collect one guide without adding rows.
    fill_scale <- p$scales$get_scales("fill")
    fill_scale$limits <- names(colors)
    for (layer in p$layers) {
      if (!is.null(layer$mapping[["fill"]]) ||
          (isTRUE(layer$inherit.aes) && !is.null(p$mapping[["fill"]]))) {
        layer$show.legend <- c(fill = TRUE)
      }
    }
  }

  # --- Background bands (bg.by) -----------------------------------------------
  if (!is.null(bg.by) && !is.null(group.by) &&
      type %in% c("bar", "trend", "dot") && position == "dodge") {
    bg_layer <- .build_bg_layer(data, group.by, bg.by, bg_alpha, bg_palette,
                                axis_levels = levels(plotdata[["group_var"]]),
                                continuous = type == "trend")
    if (!is.null(bg_layer)) {
      p$layers <- c(list(bg_layer), p$layers)
    }
  }

  # --- Y-axis formatting ------------------------------------------------------
  if (!type %in% c("dot", "pie", "ring", "rose")) {
    if (stat == "percent") {
      percent_labels <- function(x) paste0(round(x, 1), "%")
      environment(percent_labels) <- baseenv()
      p <- p + ggplot2::scale_y_continuous(
        labels = percent_labels,
        expand = ggplot2::expansion(mult = c(0, 0.05))
      )
    } else {
      p <- p + ggplot2::scale_y_continuous(
        labels = scales::label_number(),
        expand = ggplot2::expansion(mult = c(0, 0.05))
      )
    }
  }

  # --- Labels -----------------------------------------------------------------
  if (label) {
    labeldata <- plotdata
    if (!keep_empty) labeldata$label_text[labeldata$n == 0] <- ""
    p <- .add_cat_labels(p, labeldata, stat, type, position, label.size,
                         label.fg, label.bg, label.bg.r)
  }

  # --- Flip -------------------------------------------------------------------
  if (flip && type == "bar") {
    p <- p + ggplot2::coord_flip()
  }

  # --- Theme ------------------------------------------------------------------
  p <- p + theme_my(base_size = base_size)

  # --- Labs -------------------------------------------------------------------
  auto_ylab <- if (stat == "percent") "Percentage" else "Count"
  p <- p + ggplot2::labs(
    title = title,
    subtitle = subtitle,
    x = xlab,
    y = ylab %||% auto_ylab
  )

  # --- Legend & aspect --------------------------------------------------------
  p <- p + ggplot2::theme(
    legend.position = legend.position,
    legend.direction = legend.direction,
    aspect.ratio = aspect.ratio
  )

  p
}


# ============================================================================
# Internal helpers
# ============================================================================

#' Prepare frequency table for categorical plots
#' @noRd
.prepare_cat_data <- function(data, stat.by, group.by, stat,
                              NA_stat = FALSE, keep_empty = FALSE) {
  if (!is.factor(data[[stat.by]])) data[[stat.by]] <- factor(data[[stat.by]])
  dimensions <- nlevels(data[[stat.by]])
  if (!is.null(group.by)) {
    if (!is.factor(data[[group.by]])) data[[group.by]] <- factor(data[[group.by]])
    dimensions <- c(dimensions, nlevels(data[[group.by]]))
  }
  if (!keep_empty && !is.null(group.by) &&
      !anyNA(levels(data[[stat.by]])) && !anyNA(levels(data[[group.by]])) &&
      !anyNA(data[[stat.by]]) && !anyNA(data[[group.by]])) {
    stat_code <- as.integer(data[[stat.by]])
    group_code <- as.integer(data[[group.by]])
    ids <- vctrs::vec_group_id(data.frame(stat_code, group_code))
    first <- !duplicated(ids)
    order_at <- order(group_code[first], stat_code[first])
    i <- stat_code[first][order_at]
    j <- group_code[first][order_at]
    df <- data.frame(
      stat_var = factor(levels(data[[stat.by]])[i], levels = levels(data[[stat.by]])),
      group_var = factor(levels(data[[group.by]])[j], levels = levels(data[[group.by]])),
      n = tabulate(ids, attr(ids, "n"))[order_at]
    )
    if (stat == "percent") {
      total <- ave(df$n, df$group_var, FUN = sum)
      df$value <- ifelse(total > 0, df$n / total * 100, 0)
      df$label_text <- sprintf("%.1f%%", df$value)
      return(dplyr::as_tibble(df))
    }
    row_id <- (as.double(j) - 1L) * dimensions[1L] + i
    rownames(df) <- if (all(row_id <= .Machine$integer.max)) as.integer(row_id) else
      format(row_id, scientific = FALSE, trim = TRUE)
    df$value <- df$n
    df$label_text <- as.character(df$n)
    return(df)
  }
  if (prod(as.double(dimensions)) >= 2^31) {
    cli::cli_abort("A categorical frequency table must contain fewer than 2^31 cells. Reduce factor levels or use {.arg keep_empty = FALSE}.")
  }

  if (!is.null(group.by)) {
    tbl <- table(data[[stat.by]], data[[group.by]],
                 useNA = if (NA_stat) "ifany" else "no")
    df <- as.data.frame(tbl, stringsAsFactors = FALSE)
    names(df) <- c("stat_var", "group_var", "n")
  } else {
    tbl <- table(data[[stat.by]], useNA = if (NA_stat) "ifany" else "no")
    df <- as.data.frame(tbl, stringsAsFactors = FALSE)
    names(df) <- c("stat_var", "n")
    df$group_var <- "all"
  }

  if (stat == "percent") {
    total <- ave(df$n, df$group_var, FUN = sum)
    df$value <- ifelse(total > 0, df$n / total * 100, 0)
    df$label_text <- sprintf("%.1f%%", df$value)
    df <- dplyr::as_tibble(df)
  } else {
    df$value <- df$n
    df$label_text <- as.character(df$n)
  }

  df$stat_var <- factor(df$stat_var, levels = levels(data[[stat.by]]))
  if (!is.null(group.by)) {
    df$group_var <- factor(df$group_var, levels = levels(data[[group.by]]))
  }

  # Drop empty factor combinations
  if (!keep_empty) {
    df <- df[df$n > 0, , drop = FALSE]
  }

  df
}


# NOTE: colour resolution moved to utils-resolve.R as `.resolve_color()`
# (RegR-aligned signature `(palette, n, default)`, unnamed return). Callers
# wrap it in `setNames(.resolve_color(palette, n = length(levels)), levels)`.


#' Exact keys for time values whose display labels can coincide
#' @noRd
.cat_time_key <- function(x, units = NULL) {
  if (inherits(x, "Period")) {
    parts <- list(lubridate::year(x), lubridate::month(x), lubridate::day(x),
                  lubridate::hour(x), lubridate::minute(x), lubridate::second(x))
  } else if (inherits(x, "Interval")) {
    parts <- list(as.numeric(lubridate::int_start(x)), as.numeric(x))
  } else if (inherits(x, "difftime")) {
    parts <- list(as.numeric(x, units = units %||% attr(x, "units")))
  } else if (inherits(x, c("Date", "POSIXt", "Duration"))) {
    parts <- list(as.numeric(x))
  } else {
    return(NULL)
  }
  # Positive and negative zero represent the same time value.
  do.call(paste, c(lapply(parts, function(value) sprintf("%.17g", value + 0)), sep = "/"))
}


#' Resolve stat_level for venn/upset
#' @noRd
.resolve_stat_level <- function(data, stat.by, stat_level, numeric_labels = list(),
                                na_levels = character(), auto_levels = list()) {
  default_positive <- c(TRUE, "TRUE", "Yes", "yes", 1, "1")
  selectors <- if (is.list(stat_level)) stat_level else list(stat_level)
  if (any(vapply(selectors, inherits, logical(1L), "integer64")) &&
      !requireNamespace("bit64", quietly = TRUE)) {
    cli::cli_abort("Matching {.cls integer64} values in {.arg stat_level} requires package {.pkg bit64}.")
  }
  lossy_integer64 <- function(column) {
    cli::cli_abort("{.arg stat_level} for {.val {column}} cannot match {.cls integer64} without loss of precision.")
  }
  as_label <- function(values, column) {
    map <- numeric_labels[[column]]
    if (is.null(map)) return(as.character(values))
    numeric_selector <- (is.numeric(values) || is.complex(values)) &&
      (!is.object(values) || identical(class(values), "AsIs") || inherits(values, "haven_labelled"))
    if (isTRUE(map$integer64)) {
      if (!numeric_selector) return(as.character(values))
      if (is.complex(values)) lossy_integer64(column)
      key <- as.double(values)
      if (any(!is.finite(key) | key != trunc(key) | key <= -2^63 | key >= 2^63)) {
        lossy_integer64(column)
      }
      return(as.character(bit64::as.integer64(key)))
    }
    if (isTRUE(map$time) && inherits(values, map$class)) {
      key <- .cat_time_key(values, units = map$units)
    } else if (!isTRUE(map$time) && inherits(values, "integer64")) {
      key <- suppressWarnings(as.double(values))
      if (any(!is.finite(key) | key <= -2^63 | key >= 2^63) ||
          !identical(as.character(bit64::as.integer64(key)), as.character(values))) {
        lossy_integer64(column)
      }
    } else if (!isTRUE(map$time) && numeric_selector) {
      key <- unclass(values)
    } else {
      return(as.character(values))
    }
    map$labels[match(key, map$values, nomatch = 0L)]
  }
  if ((is.character(stat_level) || is.numeric(stat_level) || is.logical(stat_level)) &&
      !is.null(names(stat_level))) {
    if (!is.null(dim(stat_level))) {
      cli::cli_abort("{.arg stat_level} must be a one-dimensional vector or a named list.")
    }
    stat_level <- stats::setNames(lapply(seq_along(stat_level), function(i) {
      stat_level[i]
    }), names(stat_level))
  }

  if (is.null(stat_level)) {
    result <- stats::setNames(lapply(stat.by, function(s) {
      vals <- unique(data[[s]])
      if (!any(!is.na(vals) & !vals %in% na_levels[s])) return(character())
      if (!is.null(auto_levels[[s]])) return(auto_levels[[s]])
      map <- numeric_labels[[s]]
      positives <- if (!is.null(map) && !isTRUE(map$time) && !isTRUE(map$integer64)) {
        map$labels[map$values %in% 1]
      } else default_positive
      hits <- vals[vals %in% positives]
      if (length(hits) > 0) {
        as.character(hits)
      } else {
        lv <- if (is.factor(data[[s]])) levels(data[[s]])[1] else sort(unique(data[[s]]))[1]
        cli::cli_inform(
          "Column {.val {s}}: using {.val {lv}} as positive level."
        )
        as.character(lv)
      }
    }), stat.by)
  } else if (is.character(stat_level) || is.numeric(stat_level) || is.logical(stat_level)) {
    if (!length(stat_level) || !length(stat_level) %in% c(1L, length(stat.by)) ||
        anyNA(stat_level) || !is.null(dim(stat_level))) {
      cli::cli_abort("{.arg stat_level} must supply one non-missing value or one value per selected column.")
    }
    result <- stats::setNames(lapply(seq_along(stat.by), function(i) {
      at <- if (length(stat_level) == 1L) 1L else i
      as_label(stat_level[at], stat.by[[i]])
    }), stat.by)
  } else if (is.list(stat_level)) {
    if (is.null(names(stat_level))) {
      if (length(stat_level) != length(stat.by)) {
        cli::cli_abort("An unnamed {.arg stat_level} list must have one entry per selected column.")
      }
      names(stat_level) <- stat.by
    }
    if (anyNA(names(stat_level)) || any(!nzchar(names(stat_level))) || anyDuplicated(names(stat_level))) {
      cli::cli_abort("{.arg stat_level} must have unique, non-empty names.")
    }
    missing <- setdiff(stat.by, names(stat_level))
    if (length(missing)) cli::cli_abort("{.arg stat_level} is missing column{?s}: {.val {missing}}.")
    extra <- setdiff(names(stat_level), stat.by)
    if (length(extra)) cli::cli_abort("{.arg stat_level} has unknown column{?s}: {.val {extra}}.")
    if (any(vapply(stat_level, anyNA, logical(1)))) {
      cli::cli_abort("{.arg stat_level} must not contain missing values.")
    }
    result <- stats::setNames(lapply(names(stat_level), function(column) {
      as_label(stat_level[[column]], column)
    }), names(stat_level))
  } else {
    cli::cli_abort("{.arg stat_level} must be NULL, a character vector, or a named list.")
  }

  result
}


#' Build set list for venn/upset from data + stat_level
#' @noRd
.build_set_list <- function(data, stat.by, stat_level) {
  resolved <- .resolve_stat_level(data, stat.by, stat_level)
  stats::setNames(lapply(stat.by, function(s) {
    vals <- data[[s]]
    keep <- !is.na(vals) & (as.character(vals) %in% resolved[[s]])
    which(keep)
  }), stat.by)
}


.GeomBg <- ggplot2::ggproto(NULL, ggplot2::GeomRect,
  required_aes = c("x", "ymin", "ymax"),
  setup_data = function(data, params) {
    data <- data[is.finite(data$x), , drop = FALSE]
    data$xmin <- data$x - 0.5
    data$xmax <- data$x + 0.5
    data
  },
  draw_panel = function(data, panel_params, coord, ...) {
    axis <- if (inherits(coord, "CoordFlip")) panel_params$y else panel_params$x
    data$xmin[data$x == 1L] <- -Inf
    data$xmax[data$x == length(axis$get_limits())] <- Inf
    ggplot2::GeomRect$draw_panel(data, panel_params, coord, ...)
  }
)

#' Build background colour bands for dodge-mode plots
#' @noRd
.resolve_bg_palette <- function(bg_palette, bg_levels) {
  bg_palette <- bg_palette %||% c("grey85", "transparent")
  if (!is.null(dim(bg_palette))) {
    cli::cli_abort("{.arg bg_palette} must be one-dimensional.")
  }
  nm <- names(bg_palette)
  if (is.null(nm)) {
    idx <- rep_len(seq_along(bg_palette), length(bg_levels))
  } else {
    idx <- match(bg_levels, nm)
    if (!is.character(bg_palette) || anyNA(nm) || anyDuplicated(nm) ||
        any(!nzchar(nm) & !nm %in% bg_levels) || anyNA(idx)) {
      cli::cli_abort("Named {.arg bg_palette} must contain each background category with unique names matching their labels.")
    }
  }
  .resolve_color_values(stats::setNames(bg_palette[idx], bg_levels), "bg_palette")
}

.build_bg_layer <- function(data, group.by, bg.by, bg_alpha,
                            bg_palette = NULL, axis_levels = NULL, continuous = FALSE) {
  group_values <- as.character(data[[group.by]])
  if (is.null(axis_levels)) {
    axis_levels <- if (is.factor(data[[group.by]])) levels(data[[group.by]]) else levels(factor(data[[group.by]]))
    axis_levels <- axis_levels[!is.na(axis_levels)]
    if (anyNA(group_values)) axis_levels <- c(axis_levels, NA_character_)
  }
  group_codes <- match(group_values, axis_levels)
  group_ids <- sort(unique(group_codes))
  bg_map <- unname(vapply(split(as.character(data[[bg.by]]), group_codes), function(x) {
    ux <- unique(x)
    if (length(ux) != 1) return(NA_character_)
    ux
  }, character(1)))

  if (any(is.na(bg_map))) {
    cli::cli_warn(
      "{.arg bg.by} is not a strict superset of {.arg group.by}. Background disabled."
    )
    return(NULL)
  }

  group_levels <- axis_levels[group_ids]
  bg_levels <- unique(bg_map)

  bg_cols <- .resolve_bg_palette(bg_palette, bg_levels)

  bg_data <- data.frame(
    group = group_levels,
    x = factor(group_levels, levels = axis_levels, exclude = NULL),
    bg = bg_map,
    stringsAsFactors = FALSE
  )
  bg_data[["fill"]] <- bg_cols[match(bg_data[["bg"]], names(bg_cols))]

  if (isTRUE(continuous)) {
    bg_data[["xmin"]] <- group_ids - 0.5
    bg_data[["xmax"]] <- group_ids + 0.5
    bg_data[["xmin"]][group_ids == 1L] <- -Inf
    bg_data[["xmax"]][group_ids == length(axis_levels)] <- Inf
    return(ggplot2::geom_rect(data = bg_data,
      mapping = ggplot2::aes(xmin = .data[["xmin"]], xmax = .data[["xmax"]],
        ymin = -Inf, ymax = Inf, fill = I(.data[["fill"]])),
      alpha = bg_alpha, inherit.aes = FALSE, show.legend = FALSE))
  }

  ggplot2::layer(
    geom = .GeomBg, stat = "identity", position = "identity",
    data = bg_data,
    mapping = ggplot2::aes(
      x = .data[["x"]],
      ymin = -Inf, ymax = Inf, fill = I(.data[["fill"]])
    ),
    params = list(alpha = bg_alpha, na.rm = TRUE),
    inherit.aes = FALSE, show.legend = FALSE
  )
}


#' Add value labels to categorical plots (using ggrepel)
#' @noRd
.add_cat_labels <- function(p, plotdata, stat, type, position = "stack",
                            label.size = 3.5,
                            label.fg = "black", label.bg = "white",
                            label.bg.r = 0.1) {
  has_group <- !is.character(plotdata[["group_var"]])
  x_var <- if (has_group) "group_var" else "stat_var"

  # Match position to what the plot uses
  if (position == "dodge" && type %in% c("bar", "trend", "rose", "ring")) {
    pos <- ggplot2::position_dodge2(width = if (type == "trend") 0.6 else 0.8,
                                   preserve = "single")
  } else if (position == "dodge" && type == "area") {
    pos <- ggplot2::position_identity()
  } else {
    pos <- ggplot2::position_stack(vjust = 0.5)
  }

  # For trend/area: x-axis is continuous (x_num), not discrete
  if (type %in% c("trend", "area")) {
    plotdata[["x_num"]] <- as.numeric(factor(plotdata[[x_var]],
                                             levels = levels(factor(plotdata[[x_var]]))))
    x_aes <- "x_num"
  } else {
    x_aes <- x_var
  }

  if (type == "dot") {
    p <- p + ggrepel::geom_text_repel(
      data = plotdata,
      ggplot2::aes(
        x = .data[[x_aes]],
        y = .data[["stat_var"]],
        label = .data[["label_text"]]
      ),
      size = label.size, colour = label.fg,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      nudge_y = 0.15, direction = "x",
      show.legend = FALSE
    )
  } else if (type %in% c("pie", "ring")) {
    if (type == "ring") {
      plotdata[["radius"]] <- if (has_group) as.numeric(plotdata[["group_var"]]) + 1 else 2
    }
    p <- p + ggrepel::geom_text_repel(
      data = plotdata,
      ggplot2::aes(
        x = if (type == "ring") .data[["radius"]] else if (has_group) .data[["group_var"]] else "",
        y = .data[["value"]],
        label = .data[["label_text"]]
      ),
      position = pos,
      size = label.size, colour = label.fg,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      force = 0, min.segment.length = 0,
      show.legend = FALSE
    )
  } else {
    # bar, trend, area, rose
    plotdata[["label_hjust"]] <- 0.5
    if (type == "area" && length(unique(plotdata[[x_aes]])) > 1L) {
      plotdata[["label_hjust"]][plotdata[[x_aes]] == min(plotdata[[x_aes]])] <- 0
      plotdata[["label_hjust"]][plotdata[[x_aes]] == max(plotdata[[x_aes]])] <- 1
    }
    p <- p + ggrepel::geom_text_repel(
      data = plotdata,
      ggplot2::aes(
        x = .data[[x_aes]],
        y = .data[["value"]],
        label = .data[["label_text"]],
        group = .data[["stat_var"]],
        hjust = .data[["label_hjust"]]
      ),
      position = pos,
      size = label.size, colour = label.fg,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100,
      force = 0, min.segment.length = 0,
      show.legend = FALSE
    )
  }

  p
}
