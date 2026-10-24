# =============================================================================
# count_packages.R -- Count installed packages per library path
# =============================================================================

#' Count Installed Packages in Each Library Path
#'
#' Enumerate all \code{.libPaths()} and count the number of installed packages
#' in each directory using \code{utils::installed.packages()}. Unrelated
#' directories and installation locks are excluded. The total counts installed
#' copies across libraries, including packages installed in more than one library.
#'
#' @return A data.frame with columns \code{Library_Path} and
#'   \code{Package_Count}, including a total row.
#'
#' @examples
#' \dontrun{
#' check_packages()
#' }
#'
#' @export
#' @family inspect
check_packages <- function() {

  lib_paths <- .libPaths()

  result <- data.frame(
    Library_Path = character(),
    Package_Count = integer(),
    stringsAsFactors = FALSE
  )

  for (path in lib_paths) {
    pkg_count <- nrow(utils::installed.packages(lib.loc = path))
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
