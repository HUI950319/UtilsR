#!/usr/bin/env Rscript
# Verify tools/mindmap/*.drawio still matches the package.
#
# The mindmap hard-codes the package version and the full export list, so it
# goes stale silently whenever an export is added, removed or renamed. Run this
# before a release:
#
#   Rscript tools/mindmap/check-mindmap-sync.R
#
# Exit status 0 = in sync, 1 = out of sync. Only ASCII patterns are matched, so
# the check is independent of the locale used to read the file.

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args)) args[[1]] else {
  here <- dirname(sub("^--file=", "",
                      grep("^--file=", commandArgs(), value = TRUE)[1]))
  if (is.na(here) || !nzchar(here)) "." else normalizePath(file.path(here, "..", ".."))
}

drawio <- Sys.glob(file.path(root, "tools", "mindmap", "*.drawio"))
if (!length(drawio)) stop("no .drawio under ", file.path(root, "tools", "mindmap"),
                          call. = FALSE)
if (length(drawio) > 1L) stop("expected one .drawio, found: ",
                              paste(basename(drawio), collapse = ", "), call. = FALSE)
for (f in c(file.path(root, "NAMESPACE"), file.path(root, "DESCRIPTION"), drawio)) {
  if (!file.exists(f)) stop("missing file: ", f, call. = FALSE)
}

xml <- readLines(drawio, warn = FALSE, encoding = "UTF-8")
problems <- character()
notes <- character()

grab <- function(pattern, x, group = 1L) {
  m <- regmatches(x, regexec(pattern, x, perl = TRUE))
  m <- m[lengths(m) > 0]
  vapply(m, `[[`, character(1), group + 1L)
}

unquote <- function(x) sub('^"(.*)"$', "\\1", x)

# -- 1. export list -----------------------------------------------------------
exports <- unquote(grab("^export\\((.+)\\)\\s*$",
                        readLines(file.path(root, "NAMESPACE"), warn = FALSE)))

rows <- grep('id="p2-card-[0-9]{2}-r[0-9]{2}-n"', xml, value = TRUE)
mapped <- sub("\\(\\)$", "", grab('-n" value="([^"]+)"', rows))
# the XML escapes the operator exports
mapped <- gsub("&gt;", ">", gsub("&lt;", "<", gsub("&amp;", "&", mapped)))

dups <- unique(mapped[duplicated(mapped)])
missing <- setdiff(exports, mapped)
extra <- setdiff(mapped, exports)

if (length(missing)) {
  problems <- c(problems, sprintf("exported but not on the mindmap (%d): %s",
                                  length(missing), paste(missing, collapse = ", ")))
}
if (length(extra)) {
  problems <- c(problems, sprintf("on the mindmap but not exported (%d): %s",
                                  length(extra), paste(extra, collapse = ", ")))
}
if (length(dups)) {
  problems <- c(problems, sprintf("listed twice on the mindmap: %s",
                                  paste(dups, collapse = ", ")))
}

# -- 2. version and total -----------------------------------------------------
desc_version <- as.character(read.dcf(file.path(root, "DESCRIPTION"), "Version"))
chip <- grep('id="p[0-9]-version"', xml, value = TRUE)[1]
map_version <- grab('value="[^"]*?v([0-9]+(?:\\.[0-9]+)+)', chip)
map_total <- grab('v[0-9.]+[^0-9]{1,12}([0-9]+)', chip)

if (!length(map_version) || !identical(map_version[[1]], desc_version)) {
  problems <- c(problems, sprintf("version chip says %s, DESCRIPTION says %s",
                                  if (length(map_version)) map_version[[1]] else "<none>",
                                  desc_version))
}
if (!length(map_total) || as.integer(map_total[[1]]) != length(exports)) {
  problems <- c(problems, sprintf("version chip says %s interfaces, NAMESPACE has %d",
                                  if (length(map_total)) map_total[[1]] else "<none>",
                                  length(exports)))
}

# -- 3. per-card counts (advisory) --------------------------------------------
card_of <- grab('id="p2-card-([0-9]{2})-r[0-9]{2}-n"', rows)
observed <- table(card_of)
for (line in grep('id="p2-card-[0-9]{2}-title"', xml, value = TRUE)) {
  key <- grab('id="p2-card-([0-9]{2})-title"', line)[[1]]
  stated <- suppressWarnings(as.integer(grab("/\\s*([0-9]+)\\s*&lt;", line)))
  stated <- stated[!is.na(stated)]
  have <- as.integer(observed[key])
  if (length(stated) && !identical(stated[[1]], have)) {
    notes <- c(notes, sprintf("card %s header says %d, holds %d rows",
                              key, stated[[1]], have))
  }
}

# -- report -------------------------------------------------------------------
cat(sprintf("mindmap : %s\n", drawio))
cat(sprintf("exports : %d in NAMESPACE, %d on the mindmap\n",
            length(exports), length(mapped)))
cat(sprintf("version : %s\n", desc_version))
for (n in notes) cat("note    : ", n, "\n", sep = "")

if (length(problems)) {
  cat("\nOUT OF SYNC\n")
  for (p in problems) cat("  - ", p, "\n", sep = "")
  quit(status = 1L)
}
cat("\nIN SYNC\n")
