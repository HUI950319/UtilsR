# List All Available Palettes

Browse palettes from the built-in collection (256 palettes from
RColorBrewer, ggsci, viridis, rcartocolor, nord, dichromat, pals,
colorspace, and UtilsR built-in). Use `pattern` to filter.

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

  Regex pattern to filter palette names. Default `NULL` shows all.

- type:

  Filter by type: `"all"` (default), `"discrete"`, or `"continuous"`.

- show:

  Logical, if `TRUE` (default) display colour swatches.

## Value

Invisibly returns a named list of matching palettes.

## See also

Other colour palettes:
[`as_palette()`](https://hui950319.github.io/UtilsR/reference/as_palette.md),
[`pal_get()`](https://hui950319.github.io/UtilsR/reference/pal_get.md),
[`pal_lancet`](https://hui950319.github.io/UtilsR/reference/pal_lancet.md),
[`pal_other`](https://hui950319.github.io/UtilsR/reference/pal_other.md),
[`pal_show()`](https://hui950319.github.io/UtilsR/reference/pal_show.md)

## Examples

``` r
pal_list(show = FALSE)
#> 
#> === BrBG (11 colours, continuous) ===
#> 
#> === PiYG (11 colours, continuous) ===
#> 
#> === PRGn (11 colours, continuous) ===
#> 
#> === PuOr (11 colours, continuous) ===
#> 
#> === RdBu (11 colours, continuous) ===
#> 
#> === RdGy (11 colours, continuous) ===
#> 
#> === RdYlBu (11 colours, continuous) ===
#> 
#> === RdYlGn (11 colours, continuous) ===
#> 
#> === Spectral (11 colours, continuous) ===
#> 
#> === Accent (8 colours, discrete) ===
#> 
#> === Dark2 (8 colours, discrete) ===
#> 
#> === Paired (12 colours, discrete) ===
#> 
#> === Pastel1 (9 colours, discrete) ===
#> 
#> === Pastel2 (8 colours, discrete) ===
#> 
#> === Set1 (9 colours, discrete) ===
#> 
#> === Set2 (8 colours, discrete) ===
#> 
#> === Set3 (12 colours, discrete) ===
#> 
#> === Blues (9 colours, continuous) ===
#> 
#> === BuGn (9 colours, continuous) ===
#> 
#> === BuPu (9 colours, continuous) ===
#> 
#> === GnBu (9 colours, continuous) ===
#> 
#> === Greens (9 colours, continuous) ===
#> 
#> === Greys (9 colours, continuous) ===
#> 
#> === Oranges (9 colours, continuous) ===
#> 
#> === OrRd (9 colours, continuous) ===
#> 
#> === PuBu (9 colours, continuous) ===
#> 
#> === PuBuGn (9 colours, continuous) ===
#> 
#> === PuRd (9 colours, continuous) ===
#> 
#> === Purples (9 colours, continuous) ===
#> 
#> === RdPu (9 colours, continuous) ===
#> 
#> === Reds (9 colours, continuous) ===
#> 
#> === YlGn (9 colours, continuous) ===
#> 
#> === YlGnBu (9 colours, continuous) ===
#> 
#> === YlOrBr (9 colours, continuous) ===
#> 
#> === YlOrRd (9 colours, continuous) ===
#> 
#> === ggsci_npg_nrc (10 colours, discrete) ===
#> 
#> === ggsci_aaas_default (10 colours, discrete) ===
#> 
#> === ggsci_nejm_default (8 colours, discrete) ===
#> 
#> === ggsci_lancet_lanonc (9 colours, discrete) ===
#> 
#> === ggsci_jama_default (7 colours, discrete) ===
#> 
#> === ggsci_bmj_default (9 colours, discrete) ===
#> 
#> === ggsci_jco_default (10 colours, discrete) ===
#> 
#> === ggsci_ucscgb_default (26 colours, discrete) ===
#> 
#> === ggsci_d3_category10 (10 colours, discrete) ===
#> 
#> === ggsci_d3_category20 (20 colours, discrete) ===
#> 
#> === ggsci_d3_category20b (20 colours, discrete) ===
#> 
#> === ggsci_d3_category20c (20 colours, discrete) ===
#> 
#> === ggsci_observable_observable10 (10 colours, discrete) ===
#> 
#> === ggsci_igv_default (51 colours, discrete) ===
#> 
#> === ggsci_igv_alternating (2 colours, discrete) ===
#> 
#> === ggsci_locuszoom_default (7 colours, discrete) ===
#> 
#> === ggsci_uchicago_default (9 colours, discrete) ===
#> 
#> === ggsci_uchicago_light (9 colours, discrete) ===
#> 
#> === ggsci_uchicago_dark (9 colours, discrete) ===
#> 
#> === ggsci_cosmic_hallmarks_dark (10 colours, discrete) ===
#> 
#> === ggsci_cosmic_hallmarks_light (10 colours, discrete) ===
#> 
#> === ggsci_cosmic_signature_substitutions (6 colours, discrete) ===
#> 
#> === ggsci_simpsons_springfield (16 colours, discrete) ===
#> 
#> === ggsci_futurama_planetexpress (12 colours, discrete) ===
#> 
#> === ggsci_rickandmorty_schwifty (12 colours, discrete) ===
#> 
#> === ggsci_startrek_uniform (7 colours, discrete) ===
#> 
#> === ggsci_tron_legacy (7 colours, discrete) ===
#> 
#> === ggsci_frontiers_default (10 colours, discrete) ===
#> 
#> === ggsci_flatui_default (10 colours, discrete) ===
#> 
#> === ggsci_flatui_flattastic (12 colours, discrete) ===
#> 
#> === ggsci_flatui_aussie (10 colours, discrete) ===
#> 
#> === ggsci_gsea_default (12 colours, discrete) ===
#> 
#> === ggsci_bs5_blue (9 colours, discrete) ===
#> 
#> === ggsci_bs5_indigo (9 colours, discrete) ===
#> 
#> === ggsci_bs5_purple (9 colours, discrete) ===
#> 
#> === ggsci_bs5_pink (9 colours, discrete) ===
#> 
#> === ggsci_bs5_red (9 colours, discrete) ===
#> 
#> === ggsci_bs5_orange (9 colours, discrete) ===
#> 
#> === ggsci_bs5_yellow (9 colours, discrete) ===
#> 
#> === ggsci_bs5_green (9 colours, discrete) ===
#> 
#> === ggsci_bs5_teal (9 colours, discrete) ===
#> 
#> === ggsci_bs5_cyan (9 colours, discrete) ===
#> 
#> === ggsci_bs5_gray (9 colours, discrete) ===
#> 
#> === ggsci_material_red (10 colours, discrete) ===
#> 
#> === ggsci_material_pink (10 colours, discrete) ===
#> 
#> === ggsci_material_purple (10 colours, discrete) ===
#> 
#> === ggsci_material_deep-purple (10 colours, discrete) ===
#> 
#> === ggsci_material_indigo (10 colours, discrete) ===
#> 
#> === ggsci_material_blue (10 colours, discrete) ===
#> 
#> === ggsci_material_light-blue (10 colours, discrete) ===
#> 
#> === ggsci_material_cyan (10 colours, discrete) ===
#> 
#> === ggsci_material_teal (10 colours, discrete) ===
#> 
#> === ggsci_material_green (10 colours, discrete) ===
#> 
#> === ggsci_material_light-green (10 colours, discrete) ===
#> 
#> === ggsci_material_lime (10 colours, discrete) ===
#> 
#> === ggsci_material_yellow (10 colours, discrete) ===
#> 
#> === ggsci_material_amber (10 colours, discrete) ===
#> 
#> === ggsci_material_orange (10 colours, discrete) ===
#> 
#> === ggsci_material_deep-orange (10 colours, discrete) ===
#> 
#> === ggsci_material_brown (10 colours, discrete) ===
#> 
#> === ggsci_material_grey (10 colours, discrete) ===
#> 
#> === ggsci_material_blue-grey (10 colours, discrete) ===
#> 
#> === ggsci_tw3_slate (11 colours, discrete) ===
#> 
#> === ggsci_tw3_gray (11 colours, discrete) ===
#> 
#> === ggsci_tw3_zinc (11 colours, discrete) ===
#> 
#> === ggsci_tw3_neutral (11 colours, discrete) ===
#> 
#> === ggsci_tw3_stone (11 colours, discrete) ===
#> 
#> === ggsci_tw3_red (11 colours, discrete) ===
#> 
#> === ggsci_tw3_orange (11 colours, discrete) ===
#> 
#> === ggsci_tw3_amber (11 colours, discrete) ===
#> 
#> === ggsci_tw3_yellow (11 colours, discrete) ===
#> 
#> === ggsci_tw3_lime (11 colours, discrete) ===
#> 
#> === ggsci_tw3_green (11 colours, discrete) ===
#> 
#> === ggsci_tw3_emerald (11 colours, discrete) ===
#> 
#> === ggsci_tw3_teal (11 colours, discrete) ===
#> 
#> === ggsci_tw3_cyan (11 colours, discrete) ===
#> 
#> === ggsci_tw3_sky (11 colours, discrete) ===
#> 
#> === ggsci_tw3_blue (11 colours, discrete) ===
#> 
#> === ggsci_tw3_indigo (11 colours, discrete) ===
#> 
#> === ggsci_tw3_violet (11 colours, discrete) ===
#> 
#> === ggsci_tw3_purple (11 colours, discrete) ===
#> 
#> === ggsci_tw3_fuchsia (11 colours, discrete) ===
#> 
#> === ggsci_tw3_pink (11 colours, discrete) ===
#> 
#> === ggsci_tw3_rose (11 colours, discrete) ===
#> 
#> === magma (256 colours, continuous) ===
#> 
#> === inferno (256 colours, continuous) ===
#> 
#> === plasma (256 colours, continuous) ===
#> 
#> === viridis (256 colours, continuous) ===
#> 
#> === cividis (256 colours, continuous) ===
#> 
#> === rocket (256 colours, continuous) ===
#> 
#> === mako (256 colours, continuous) ===
#> 
#> === turbo (256 colours, continuous) ===
#> 
#> === carto_ag_GrnYl (7 colours, continuous) ===
#> 
#> === carto_ag_Sunset (7 colours, continuous) ===
#> 
#> === carto_ArmyRose (7 colours, continuous) ===
#> 
#> === carto_Earth (7 colours, continuous) ===
#> 
#> === carto_Fall (7 colours, continuous) ===
#> 
#> === carto_Geyser (7 colours, continuous) ===
#> 
#> === carto_TealRose (7 colours, continuous) ===
#> 
#> === carto_Temps (7 colours, continuous) ===
#> 
#> === carto_Tropic (7 colours, continuous) ===
#> 
#> === carto_Antique (12 colours, discrete) ===
#> 
#> === carto_Bold (12 colours, discrete) ===
#> 
#> === carto_Pastel (12 colours, discrete) ===
#> 
#> === carto_Prism (12 colours, discrete) ===
#> 
#> === carto_Safe (12 colours, discrete) ===
#> 
#> === carto_Vivid (12 colours, discrete) ===
#> 
#> === carto_BluGrn (7 colours, continuous) ===
#> 
#> === carto_BluYl (7 colours, continuous) ===
#> 
#> === carto_BrwnYl (7 colours, continuous) ===
#> 
#> === carto_Burg (7 colours, continuous) ===
#> 
#> === carto_BurgYl (7 colours, continuous) ===
#> 
#> === carto_DarkMint (7 colours, continuous) ===
#> 
#> === carto_Emrld (7 colours, continuous) ===
#> 
#> === carto_Magenta (7 colours, continuous) ===
#> 
#> === carto_Mint (7 colours, continuous) ===
#> 
#> === carto_OrYel (7 colours, continuous) ===
#> 
#> === carto_Peach (7 colours, continuous) ===
#> 
#> === carto_PinkYl (7 colours, continuous) ===
#> 
#> === carto_Purp (7 colours, continuous) ===
#> 
#> === carto_PurpOr (7 colours, continuous) ===
#> 
#> === carto_RedOr (7 colours, continuous) ===
#> 
#> === carto_Sunset (7 colours, continuous) ===
#> 
#> === carto_SunsetDark (7 colours, continuous) ===
#> 
#> === carto_Teal (7 colours, continuous) ===
#> 
#> === carto_TealGrn (7 colours, continuous) ===
#> 
#> === nord_polarnight (4 colours, discrete) ===
#> 
#> === nord_snowstorm (3 colours, discrete) ===
#> 
#> === nord_frost (4 colours, discrete) ===
#> 
#> === nord_aurora (5 colours, discrete) ===
#> 
#> === nord_lumina (5 colours, discrete) ===
#> 
#> === nord_mountain_forms (5 colours, discrete) ===
#> 
#> === nord_silver_mine (5 colours, discrete) ===
#> 
#> === nord_lake_superior (6 colours, discrete) ===
#> 
#> === nord_victory_bonds (5 colours, discrete) ===
#> 
#> === nord_halifax_harbor (6 colours, discrete) ===
#> 
#> === nord_moose_pond (8 colours, discrete) ===
#> 
#> === nord_algoma_forest (7 colours, discrete) ===
#> 
#> === nord_rocky_mountain (6 colours, discrete) ===
#> 
#> === nord_red_mountain (8 colours, discrete) ===
#> 
#> === nord_baie_mouton (7 colours, discrete) ===
#> 
#> === nord_afternoon_prarie (9 colours, discrete) ===
#> 
#> === dichromat_BrowntoBlue.10 (10 colours, continuous) ===
#> 
#> === dichromat_BrowntoBlue.12 (12 colours, continuous) ===
#> 
#> === dichromat_BluetoDarkOrange.12 (12 colours, continuous) ===
#> 
#> === dichromat_BluetoDarkOrange.18 (18 colours, continuous) ===
#> 
#> === dichromat_DarkRedtoBlue.12 (12 colours, continuous) ===
#> 
#> === dichromat_DarkRedtoBlue.18 (18 colours, continuous) ===
#> 
#> === dichromat_BluetoGreen.14 (14 colours, continuous) ===
#> 
#> === dichromat_BluetoGray.8 (8 colours, continuous) ===
#> 
#> === dichromat_BluetoOrangeRed.14 (14 colours, continuous) ===
#> 
#> === dichromat_BluetoOrange.10 (10 colours, continuous) ===
#> 
#> === dichromat_BluetoOrange.12 (12 colours, continuous) ===
#> 
#> === dichromat_BluetoOrange.8 (8 colours, continuous) ===
#> 
#> === dichromat_LightBluetoDarkBlue.10 (10 colours, continuous) ===
#> 
#> === dichromat_LightBluetoDarkBlue.7 (7 colours, continuous) ===
#> 
#> === dichromat_Categorical.12 (12 colours, continuous) ===
#> 
#> === dichromat_GreentoMagenta.16 (16 colours, continuous) ===
#> 
#> === dichromat_SteppedSequential.5 (25 colours, continuous) ===
#> 
#> === pals_ocean.algae (9 colours, continuous) ===
#> 
#> === pals_ocean.deep (13 colours, continuous) ===
#> 
#> === pals_ocean.dense (8 colours, continuous) ===
#> 
#> === pals_ocean.gray (5 colours, continuous) ===
#> 
#> === pals_ocean.haline (24 colours, continuous) ===
#> 
#> === pals_ocean.ice (10 colours, continuous) ===
#> 
#> === pals_ocean.matter (9 colours, continuous) ===
#> 
#> === pals_ocean.oxy (17 colours, continuous) ===
#> 
#> === pals_ocean.phase (17 colours, continuous) ===
#> 
#> === pals_ocean.solar (8 colours, continuous) ===
#> 
#> === pals_ocean.thermal (22 colours, continuous) ===
#> 
#> === pals_ocean.turbid (7 colours, continuous) ===
#> 
#> === pals_ocean.balance (29 colours, continuous) ===
#> 
#> === pals_ocean.curl (17 colours, continuous) ===
#> 
#> === pals_ocean.delta (96 colours, continuous) ===
#> 
#> === pals_ocean.amp (11 colours, continuous) ===
#> 
#> === pals_ocean.speed (9 colours, continuous) ===
#> 
#> === pals_ocean.tempo (8 colours, continuous) ===
#> 
#> === hcl_Reds (100 colours, continuous) ===
#> 
#> === hcl_Reds_2 (100 colours, continuous) ===
#> 
#> === hcl_Reds_3 (100 colours, continuous) ===
#> 
#> === hcl_Blues (100 colours, continuous) ===
#> 
#> === hcl_Blues_2 (100 colours, continuous) ===
#> 
#> === hcl_Blues_3 (100 colours, continuous) ===
#> 
#> === hcl_Greens (100 colours, continuous) ===
#> 
#> === hcl_Greens_2 (100 colours, continuous) ===
#> 
#> === hcl_Greens_3 (100 colours, continuous) ===
#> 
#> === hcl_Oranges (100 colours, continuous) ===
#> 
#> === hcl_Purples (100 colours, continuous) ===
#> 
#> === hcl_Purples_2 (100 colours, continuous) ===
#> 
#> === hcl_Purples_3 (100 colours, continuous) ===
#> 
#> === hcl_Grays (100 colours, continuous) ===
#> 
#> === hcl_Light_Grays (100 colours, continuous) ===
#> 
#> === hcl_YlOrRd (100 colours, continuous) ===
#> 
#> === hcl_YlOrBr (100 colours, continuous) ===
#> 
#> === hcl_YlGnBu (100 colours, continuous) ===
#> 
#> === hcl_BuGn (100 colours, continuous) ===
#> 
#> === hcl_BuPu (100 colours, continuous) ===
#> 
#> === hcl_PuRd (100 colours, continuous) ===
#> 
#> === hcl_RdPu (100 colours, continuous) ===
#> 
#> === hcl_OrRd (100 colours, continuous) ===
#> 
#> === hcl_GnBu (100 colours, continuous) ===
#> 
#> === hcl_PuBu (100 colours, continuous) ===
#> 
#> === hcl_PuBuGn (100 colours, continuous) ===
#> 
#> === hcl_Blue_Red (100 colours, continuous) ===
#> 
#> === hcl_Blue_Yellow (100 colours, continuous) ===
#> 
#> === hcl_Green_Brown (100 colours, continuous) ===
#> 
#> === hcl_Purple_Green (100 colours, continuous) ===
#> 
#> === hcl_Tropic (100 colours, continuous) ===
#> 
#> === hcl_Tofino (100 colours, continuous) ===
#> 
#> === hcl_Berlin (100 colours, continuous) ===
#> 
#> === hcl_Lisbon (100 colours, continuous) ===
#> 
#> === hcl_Cork (100 colours, continuous) ===
#> 
#> === jet (100 colours, continuous) ===
#> 
#> === simspec (12 colours, discrete) ===
#> 
#> === GdRd (2 colours, continuous) ===
#> 
#> === lancet (15 colours, discrete) ===
#> 
#> === igv (48 colours, discrete) ===
#> 
#> === ditto (40 colours, discrete) ===
#> 
#> === polychrome (36 colours, discrete) ===
#> 
#> === glasbey (32 colours, discrete) ===
#> 
#> === d3 (20 colours, discrete) ===
pal_list(pattern = "^Blues")
#> 
#> === Blues (9 colours, continuous) ===
#>  #F7FBFF   #DEEBF7   #C6DBEF   #9ECAE1   #6BAED6   #4292C6   #2171B5   #08519C   #08306B  
pal_list(type = "discrete", pattern = "nord")
#> 
#> === nord_polarnight (4 colours, discrete) ===
#>  #2E3440   #3B4252   #434C5E   #4C566A  
#> 
#> === nord_snowstorm (3 colours, discrete) ===
#>  #D8DEE9   #E5E9F0   #ECEFF4  
#> 
#> === nord_frost (4 colours, discrete) ===
#>  #8FBCBB   #88C0D0   #81A1C1   #5E81AC  
#> 
#> === nord_aurora (5 colours, discrete) ===
#>  #BF616A   #D08770   #EBCB8B   #A3BE8C   #B48EAD  
#> 
#> === nord_lumina (5 colours, discrete) ===
#>  #EDDAEB   #AD8CAE   #4F93B8   #306489   #222B4C  
#> 
#> === nord_mountain_forms (5 colours, discrete) ===
#>  #184860   #486078   #D8D8D8   #484860   #181830  
#> 
#> === nord_silver_mine (5 colours, discrete) ===
#>  #4B644B   #647D4B   #E1E1E1   #7D96AF   #647D96  
#> 
#> === nord_lake_superior (6 colours, discrete) ===
#>  #7D4B19   #C89664   #C87D4B   #4B647D   #324B64   #19324B  
#> 
#> === nord_victory_bonds (5 colours, discrete) ===
#>  #AF1900   #C83200   #E19600   #193264   #001964  
#> 
#> === nord_halifax_harbor (6 colours, discrete) ===
#>  #E1C8AF   #C8AF96   #AF967D   #967D7D   #644B64   #4B324B  
#> 
#> === nord_moose_pond (8 colours, discrete) ===
#>  #4B3232   #7D4B32   #966432   #AF7D32   #E19632   #E1AF4B   #C8C896   #4B4B4B  
#> 
#> === nord_algoma_forest (7 colours, discrete) ===
#>  #4B4B4B   #967D4B   #AFAF7D   #C89632   #647D64   #96AFAF   #7D96AF  
#> 
#> === nord_rocky_mountain (6 colours, discrete) ===
#>  #BEBEBE   #C8C8C8   #DCD2C8   #D2C8C8   #BEBEC8   #B4B4BE  
#> 
#> === nord_red_mountain (8 colours, discrete) ===
#>  #7D3232   #7D4B4B   #7D6464   #AF967D   #FAC87D   #E1AF64   #C8964B   #32324B  
#> 
#> === nord_baie_mouton (7 colours, discrete) ===
#>  #304890   #7890A8   #90A8C0   #A8A8A8   #C0C0A8   #6A7E4F   #304848  
#> 
#> === nord_afternoon_prarie (9 colours, discrete) ===
#>  #486090   #6078A8   #7890A8   #90A8C0   #F0D8C0   #D6BBCF   #A8C0C0   #C0D8D8   #A8A890  
```
