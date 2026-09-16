#!/usr/bin/env Rscript
# Build the pkgdown site, and optionally publish it to gh-pages.
#
#   Rscript tools/build-site.R            # rebuild docs/
#   Rscript tools/build-site.R --deploy   # rebuild docs/, then push it live
#
# The site used to be built by .github/workflows/pkgdown.yaml. That workflow is
# switched off: `needs: website` makes pak resolve Suggests, and two of them --
# RegR and ToyData -- are private repositories that the default GITHUB_TOKEN
# cannot read, so every run since 2026-03 died in setup-r-dependencies with
# "Can't find package called RegR, ToyData" and the published site sat six
# months behind the code. Building here instead.
#
# Exit status 0 = built (and pushed, with --deploy).

args <- commandArgs(trailingOnly = TRUE)
deploy <- "--deploy" %in% args
unknown <- setdiff(args, "--deploy")
if (length(unknown)) {
  stop("unknown argument(s): ", paste(unknown, collapse = ", "), call. = FALSE)
}

here <- dirname(sub("^--file=", "",
                    grep("^--file=", commandArgs(), value = TRUE)[1]))
root <- normalizePath(file.path(here, ".."))

# pkgdown 2.2 writes a .md beside every page plus llms.txt, and the published
# site carries both. An older pkgdown drops them without saying anything, so a
# rebuild would quietly strip the site of files it currently serves.
if (utils::packageVersion("pkgdown") < "2.2.0") {
  stop("pkgdown >= 2.2.0 required, found ", utils::packageVersion("pkgdown"),
       ".\n  install.packages(\"pkgdown\")\n",
       "  On this machine that also needs ragg >= 1.4.0, which wants system\n",
       "  headers apt cannot install here; take the Ubuntu binary instead:\n",
       "  install.packages(c(\"ragg\", \"pkgdown\"), repos = ",
       "\"https://packagemanager.posit.co/cran/__linux__/jammy/latest\")",
       call. = FALSE)
}

# init_site() calls build_favicons() whenever the package has a logo and no
# pkgdown/favicon/, which uploads logo.png to realfavicongenerator.net. That
# host is not reachable from here and the whole build aborts on the SSL error.
# An empty directory is all has_favicons() looks for, and since git does not
# track empty directories this leaves nothing behind; .Rbuildignore keeps
# pkgdown/ out of the tarball should real favicons ever land there.
dir.create(file.path(root, "pkgdown", "favicon"),
           recursive = TRUE, showWarnings = FALSE)

# Clean first: docs/ is generated and git-ignored, and without this a page for
# a function that has since been removed survives into the deploy.
pkgdown::clean_site(root)
pkgdown::build_site(root, preview = FALSE)

site <- file.path(root, "docs")

# AGENTS.md is instructions for coding agents, not documentation, but pkgdown
# renders every .md in the package root and does not consult .Rbuildignore when
# it does. Drop the page and every reference to it.
for (nm in c("AGENTS.html", "AGENTS.md")) {
  f <- file.path(site, nm)
  if (file.exists(f)) file.remove(f)
}
sm <- file.path(site, "sitemap.xml")
if (file.exists(sm)) {
  x <- paste(readLines(sm, warn = FALSE), collapse = "\n")
  writeLines(gsub("[[:space:]]*<url>(?:(?!</url>).)*AGENTS[.]html(?:(?!</url>).)*</url>",
                  "", x, perl = TRUE), sm)
}
sj <- file.path(site, "search.json")
if (file.exists(sj)) {
  idx <- jsonlite::fromJSON(sj, simplifyVector = FALSE)
  # Not every entry carries a path, so the predicate has to tolerate NULL.
  keep <- !vapply(idx, function(e) {
    p <- e[["path"]]
    length(p) == 1L && grepl("AGENTS[.]html", p)
  }, logical(1))
  writeLines(jsonlite::toJSON(idx[keep], auto_unbox = TRUE, null = "null"), sj)
}

cat("\nbuilt ", site, " (", length(list.files(site, recursive = TRUE)),
    " files)\n", sep = "")

if (!deploy) {
  cat("open  ", file.path(site, "index.html"),
      "\ndeploy with  Rscript tools/build-site.R --deploy\n", sep = "")
  quit(save = "no", status = 0)
}

git <- function(..., dir = root) {
  status <- system2("git", c("-C", shQuote(dir), ...))
  if (status != 0L) stop("git ", paste(..., collapse = " "), " failed",
                         call. = FALSE)
}

remote <- system2("git", c("-C", shQuote(root), "remote", "get-url", "origin"),
                  stdout = TRUE)
work <- file.path(tempdir(), "gh-pages")
unlink(work, recursive = TRUE)
# Clone rather than force-push a fresh branch: gh-pages carries the deploy
# history the workflow left behind, and that is worth keeping.
git("clone", "--quiet", "--branch", "gh-pages", "--single-branch", "--depth",
    "1", shQuote(remote), shQuote(work), dir = root)
git("config", "core.autocrlf", "false", dir = work)

keep <- file.path(work, ".git")
unlink(setdiff(list.files(work, all.files = TRUE, full.names = TRUE,
                          no.. = TRUE), keep), recursive = TRUE)
# copy.mode = FALSE on purpose: docs/ lives on a Windows drive, where every
# file reads back as 0777, and copying that through would commit the whole site
# as executable -- and flip it all back the day someone builds on a Linux
# filesystem. Plain 644 either way.
invisible(file.copy(
  list.files(site, all.files = TRUE, full.names = TRUE, no.. = TRUE),
  work, recursive = TRUE, copy.mode = FALSE))
# build_site() does not write this; only build_site_github_pages() does, and
# without it GitHub Pages runs Jekyll and hides every deps/ directory.
invisible(file.create(file.path(work, ".nojekyll")))

git("add", "-A", dir = work)
staged <- system2("git", c("-C", shQuote(work), "diff", "--cached", "--name-only"),
                  stdout = TRUE)
if (!length(staged)) {
  cat("gh-pages already matches this build; nothing to push\n")
  quit(save = "no", status = 0)
}
dcf <- read.dcf(file.path(root, "DESCRIPTION"), c("Package", "Version"))
git("commit", "--quiet", "-m",
    shQuote(sprintf("Build pkgdown site for %s %s", dcf[, "Package"],
                    dcf[, "Version"])),
    dir = work)
git("push", "--quiet", "origin", "gh-pages", dir = work)
cat("pushed gh-pages (", length(staged), " files changed)\n", sep = "")
