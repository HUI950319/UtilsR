# ============================================================================
# count_packages.R -- Count installed packages per library path
# ============================================================================

#' Count Installed Packages in Each Library Path
#'
#' Enumerate all \code{.libPaths()} and count the number of installed packages
#' in each directory.
#'
#' @return A data.frame with columns \code{Library_Path} and
#'   \code{Package_Count}, including a total row.
#'
#' @examples
#' \dontrun{
#' count_packages_in_libpaths()
#' }
#'
#' @export
count_packages_in_libpaths <- function() {

  lib_paths <- .libPaths()

  result <- data.frame(
    Library_Path = character(),
    Package_Count = integer(),
    stringsAsFactors = FALSE
  )

  for (path in lib_paths) {
    pkg_count <- length(list.dirs(path, full.names = FALSE, recursive = FALSE))
    result <- rbind(result, data.frame(
      Library_Path = path,
      Package_Count = pkg_count
    ))
  }

  total <- data.frame(
    Library_Path = "Total",
    Package_Count = sum(result$Package_Count)
  )
  result <- rbind(result, total)

  return(result)
}
