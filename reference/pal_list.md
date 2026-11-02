# List Registered Palettes

Browse palettes from the built-in collection (260 palettes from
RColorBrewer, ggsci, viridis, rcartocolor, nord, dichromat, pals,
colorspace, and UtilsR built-in). Use `pattern` to filter. Prints
palette headings and optional swatches in the console. For a gt table or
ggplot preview, use
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md).

## Usage

``` r
pal_list(
  pattern = NULL,
  type = c("all", "discrete", "continuous"),
  show = TRUE
)
```

## Arguments

- pattern:

  Single non-missing regex string to filter palette names, ignoring
  case. Default `NULL` shows all.

- type:

  Filter by type: `"all"` (default), `"discrete"`, or `"continuous"`.

- show:

  Single non-missing logical; if `TRUE` (default) display colour
  swatches. `FALSE` prints palette headings only.

## Value

Invisibly returns a named list of matching palettes. If no palettes
match, the function emits a message and returns an empty list invisibly.

## Details

Only palettes in
[`palette_list`](https://hui950319.github.io/UtilsR/reference/palette_list.md)
are listed. Separate collections such as
[`pal_heat`](https://hui950319.github.io/UtilsR/reference/pal_heat.md)
and unregistered entries of
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md)
are accessed directly rather than by registry name.

Palette names are kept in full on narrow consoles. Colour counts and
types move to a separate line when they do not fit in a heading.

## See also

Other colour palettes:
[`pal_bar`](https://hui950319.github.io/UtilsR/reference/pal_bar.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_heat`](https://hui950319.github.io/UtilsR/reference/pal_heat.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_paraSC`](https://hui950319.github.io/UtilsR/reference/pal_paraSC.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md),
[`pal_show_brewer()`](https://hui950319.github.io/UtilsR/reference/pal_show_brewer.md),
[`pal_show_ggsci()`](https://hui950319.github.io/UtilsR/reference/pal_show_ggsci.md),
[`pal_show_hcl()`](https://hui950319.github.io/UtilsR/reference/pal_show_hcl.md),
[`pal_show_viridis()`](https://hui950319.github.io/UtilsR/reference/pal_show_viridis.md)

## Examples

``` r
pal_list(pattern = "^Blues", show = FALSE)
#> 
#> ── Blues (9 colours, continuous) ───────────────────────────────────────────────
pal_list(pattern = "^Blues")
#> 
#> ── Blues (9 colours, continuous) ───────────────────────────────────────────────
#>  #F7FBFF   #DEEBF7   #C6DBEF   #9ECAE1   #6BAED6   #4292C6   #2171B5   #08519C 
#>  #08306B 
#> structure(c("#F7FBFF", "#DEEBF7", "#C6DBEF", "#9ECAE1", "#6BAED6", 
#> "#4292C6", "#2171B5", "#08519C", "#08306B"), type = "continuous")
pal_list(type = "discrete", pattern = "nord")
#> 
#> ── nord_polarnight (4 colours, discrete) ───────────────────────────────────────
#>  #2E3440   #3B4252   #434C5E   #4C566A 
#> structure(c("#2E3440", "#3B4252", "#434C5E", "#4C566A"), type = "discrete")
#> 
#> ── nord_snowstorm (3 colours, discrete) ────────────────────────────────────────
#>  #D8DEE9   #E5E9F0   #ECEFF4 
#> structure(c("#D8DEE9", "#E5E9F0", "#ECEFF4"), type = "discrete")
#> 
#> ── nord_frost (4 colours, discrete) ────────────────────────────────────────────
#>  #8FBCBB   #88C0D0   #81A1C1   #5E81AC 
#> structure(c("#8FBCBB", "#88C0D0", "#81A1C1", "#5E81AC"), type = "discrete")
#> 
#> ── nord_aurora (5 colours, discrete) ───────────────────────────────────────────
#>  #BF616A   #D08770   #EBCB8B   #A3BE8C   #B48EAD 
#> structure(c("#BF616A", "#D08770", "#EBCB8B", "#A3BE8C", "#B48EAD"
#> ), type = "discrete")
#> 
#> ── nord_lumina (5 colours, discrete) ───────────────────────────────────────────
#>  #EDDAEB   #AD8CAE   #4F93B8   #306489   #222B4C 
#> structure(c("#EDDAEB", "#AD8CAE", "#4F93B8", "#306489", "#222B4C"
#> ), type = "discrete")
#> 
#> ── nord_mountain_forms (5 colours, discrete) ───────────────────────────────────
#>  #184860   #486078   #D8D8D8   #484860   #181830 
#> structure(c("#184860", "#486078", "#d8d8d8", "#484860", "#181830"
#> ), type = "discrete")
#> 
#> ── nord_silver_mine (5 colours, discrete) ──────────────────────────────────────
#>  #4B644B   #647D4B   #E1E1E1   #7D96AF   #647D96 
#> structure(c("#4B644B", "#647D4B", "#E1E1E1", "#7D96AF", "#647D96"
#> ), type = "discrete")
#> 
#> ── nord_lake_superior (6 colours, discrete) ────────────────────────────────────
#>  #7D4B19   #C89664   #C87D4B   #4B647D   #324B64   #19324B 
#> structure(c("#7D4B19", "#C89664", "#C87d4B", "#4B647D", "#324B64", 
#> "#19324B"), type = "discrete")
#> 
#> ── nord_victory_bonds (5 colours, discrete) ────────────────────────────────────
#>  #AF1900   #C83200   #E19600   #193264   #001964 
#> structure(c("#AF1900", "#C83200", "#E19600", "#193264", "#001964"
#> ), type = "discrete")
#> 
#> ── nord_halifax_harbor (6 colours, discrete) ───────────────────────────────────
#>  #E1C8AF   #C8AF96   #AF967D   #967D7D   #644B64   #4B324B 
#> structure(c("#E1C8AF", "#C8AF96", "#AF967D", "#967D7D", "#644B64", 
#> "#4B324b"), type = "discrete")
#> 
#> ── nord_moose_pond (8 colours, discrete) ───────────────────────────────────────
#>  #4B3232   #7D4B32   #966432   #AF7D32   #E19632   #E1AF4B   #C8C896   #4B4B4B 
#> structure(c("#4B3232", "#7D4B32", "#966432", "#AF7D32", "#E19632", 
#> "#E1AF4B", "#C8C896", "#4B4B4B"), type = "discrete")
#> 
#> ── nord_algoma_forest (7 colours, discrete) ────────────────────────────────────
#>  #4B4B4B   #967D4B   #AFAF7D   #C89632   #647D64   #96AFAF   #7D96AF 
#> structure(c("#4B4B4B", "#967D4B", "#AFAF7D", "#C89632", "#647D64", 
#> "#96AFAF", "#7D96AF"), type = "discrete")
#> 
#> ── nord_rocky_mountain (6 colours, discrete) ───────────────────────────────────
#>  #BEBEBE   #C8C8C8   #DCD2C8   #D2C8C8   #BEBEC8   #B4B4BE 
#> structure(c("#BEBEBE", "#C8C8C8", "#DCD2C8", "#D2C8C8", "#BEBEC8", 
#> "#B4B4BE"), type = "discrete")
#> 
#> ── nord_red_mountain (8 colours, discrete) ─────────────────────────────────────
#>  #7D3232   #7D4B4B   #7D6464   #AF967D   #FAC87D   #E1AF64   #C8964B   #32324B 
#> structure(c("#7D3232", "#7D4B4B", "#7D6464", "#AF967D", "#FAC87D", 
#> "#E1AF64", "#C8964B", "#32324B"), type = "discrete")
#> 
#> ── nord_baie_mouton (7 colours, discrete) ──────────────────────────────────────
#>  #304890   #7890A8   #90A8C0   #A8A8A8   #C0C0A8   #6A7E4F   #304848 
#> structure(c("#304890", "#7890A8", "#90A8C0", "#A8A8A8", "#C0C0A8", 
#> "#6A7E4F", "#304848"), type = "discrete")
#> 
#> ── nord_afternoon_prarie (9 colours, discrete) ─────────────────────────────────
#>  #486090   #6078A8   #7890A8   #90A8C0   #F0D8C0   #D6BBCF   #A8C0C0   #C0D8D8 
#>  #A8A890 
#> structure(c("#486090", "#6078A8", "#7890A8", "#90A8C0", "#F0D8C0", 
#> "#D6BBCF", "#A8C0C0", "#C0D8D8", "#A8A890"), type = "discrete")
```
