# Create a Directory (if Needed) and Set It as the Working Directory

Convenience wrapper for the common analysis-script preamble of "make an
output folder if it is not there yet, then `setwd()` into it". Unlike a
bare `dir.create()`, the directory is created recursively, so missing
intermediate parents are handled automatically.

## Usage

``` r
set_wd(path, create = TRUE, verbose = TRUE)
```

## Arguments

  - path:
    
    Character scalar. Target directory. Intermediate directories are
    created when `create = TRUE`.

  - create:
    
    Logical. Create `path` (recursively) when it does not exist. Default
    `TRUE`. When `FALSE`, a missing directory raises an error instead of
    being created.

  - verbose:
    
    Logical. Print the one-line notice described above. Default `TRUE`.
    The recursive scan behind the file count and total size runs only
    when this is `TRUE` *and* the directory already existed, so `verbose
    = FALSE` also skips walking a very large tree.

## Value

The previous working directory, returned invisibly (same convention as
`setwd`), so the original location can be restored.

## Details

With `verbose = TRUE` the destination is announced as a single
`.cat_message` line, in the same `... [<contents>, <status>]` shape the
RegR savers use for files:

  - a directory this call just created reports `empty` and a green `new
    directory` marker;

  - a directory that was already there reports its recursive file count
    and total size, and a red `existing directory` marker – the red
    flags that whatever the script writes next lands beside, or on top
    of, earlier output.

The contents are measured before `setwd()` moves in, because a relative
`path` stops resolving once the working directory has changed.

## See also

`setwd`, `dir.create`, `.cat_message`

## Examples

``` r
if (FALSE) { # \dontrun{
# Make the folder if needed and move into it
set_wd("results/NAT/1.NAT_Ext_DSS_T3_PDAC")
#> [2026-09-16 14:32:10] i working directory set to: ... [empty, new directory]

# Running the same script again finds the outputs from last time
set_wd("results/NAT/1.NAT_Ext_DSS_T3_PDAC")
#> [2026-09-16 15:04:22] i working directory set to: ... [42 files, 12.63 MB, existing directory]

# Capture the old location and restore it afterwards
old <- set_wd(tempfile("run_"))
setwd(old)
} # }
```
