# Build palette_list.rda from all available palette sources
# Run this script to regenerate: Rscript data-raw/build_palette_list.R

palette_list <- list()

# --- 1. RColorBrewer ---
if (requireNamespace("RColorBrewer", quietly = TRUE)) {
  info <- RColorBrewer::brewer.pal.info
  for (nm in rownames(info)) {
    cols <- RColorBrewer::brewer.pal(info[nm, "maxcolors"], nm)
    tp <- if (info[nm, "category"] == "qual") "discrete" else "continuous"
    attr(cols, "type") <- tp
    palette_list[[nm]] <- cols
  }
  message("RColorBrewer: ", sum(grepl("^", names(palette_list))), " palettes")
}

# --- 2. ggsci ---
if (requireNamespace("ggsci", quietly = TRUE)) {
  ggsci_db <- tryCatch(
    utils::getFromNamespace("ggsci_db", "ggsci"),
    error = function(e) NULL
  )
  if (!is.null(ggsci_db)) {
    n_before <- length(palette_list)
    for (pkg_name in names(ggsci_db)) {
      sub_pals <- ggsci_db[[pkg_name]]
      for (sub_name in names(sub_pals)) {
        full_name <- paste0("ggsci_", pkg_name, "_", sub_name)
        cols <- unname(sub_pals[[sub_name]])
        attr(cols, "type") <- "discrete"
        palette_list[[full_name]] <- cols
      }
    }
    message("ggsci: ", length(palette_list) - n_before, " palettes")
  }
}

# --- 3. viridis ---
if (requireNamespace("viridis", quietly = TRUE)) {
  viridis_names <- c("magma", "inferno", "plasma", "viridis",
                     "cividis", "rocket", "mako", "turbo")
  for (vn in viridis_names) {
    cols <- viridis::viridis(256, option = vn)
    attr(cols, "type") <- "continuous"
    palette_list[[vn]] <- cols
  }
  message("viridis: 8 palettes")
}

# --- 4. rcartocolor ---
if (requireNamespace("rcartocolor", quietly = TRUE)) {
  n_before <- length(palette_list)
  meta <- rcartocolor::metacartocolors
  for (i in seq_len(nrow(meta))) {
    nm <- meta$Name[i]
    n_max <- meta$`Max_n`[i]
    if (is.na(n_max) || n_max < 2) next
    cols <- tryCatch(
      rcartocolor::carto_pal(n_max, nm),
      error = function(e) NULL
    )
    if (!is.null(cols)) {
      full_name <- paste0("carto_", nm)
      tp <- if (meta$Type[i] == "qualitative") "discrete" else "continuous"
      attr(cols, "type") <- tp
      palette_list[[full_name]] <- cols
    }
  }
  message("rcartocolor: ", length(palette_list) - n_before, " palettes")
}

# --- 5. nord ---
if (requireNamespace("nord", quietly = TRUE)) {
  n_before <- length(palette_list)
  for (nm in names(nord::nord_palettes)) {
    cols <- unname(nord::nord_palettes[[nm]])
    full_name <- paste0("nord_", nm)
    attr(cols, "type") <- "discrete"
    palette_list[[full_name]] <- cols
  }
  message("nord: ", length(palette_list) - n_before, " palettes")
}

# --- 6. dichromat ---
if (requireNamespace("dichromat", quietly = TRUE)) {
  n_before <- length(palette_list)
  for (nm in names(dichromat::colorschemes)) {
    cols <- dichromat::colorschemes[[nm]]
    full_name <- paste0("dichromat_", nm)
    attr(cols, "type") <- "continuous"
    palette_list[[full_name]] <- cols
  }
  message("dichromat: ", length(palette_list) - n_before, " palettes")
}

# --- 7. pals (ocean) ---
if (requireNamespace("pals", quietly = TRUE)) {
  n_before <- length(palette_list)
  syspals <- tryCatch(
    utils::getFromNamespace("syspals", "pals"),
    error = function(e) NULL
  )
  if (!is.null(syspals)) {
    ocean_names <- names(syspals)[grep("ocean", names(syspals))]
    for (nm in ocean_names) {
      cols <- syspals[[nm]]
      full_name <- paste0("pals_", nm)
      attr(cols, "type") <- "continuous"
      palette_list[[full_name]] <- cols
    }
  }
  message("pals: ", length(palette_list) - n_before, " palettes")
}

# --- 8. colorspace HCL sequential ---
if (requireNamespace("colorspace", quietly = TRUE)) {
  n_before <- length(palette_list)
  hcl_names <- c("Reds", "Reds 2", "Reds 3",
                  "Blues", "Blues 2", "Blues 3",
                  "Greens", "Greens 2", "Greens 3",
                  "Oranges", "Purples", "Purples 2", "Purples 3",
                  "Grays", "Light Grays",
                  "YlOrRd", "YlOrBr", "YlGnBu", "BuGn", "BuPu",
                  "PuRd", "RdPu", "OrRd", "GnBu", "PuBu", "PuBuGn")
  for (nm in hcl_names) {
    cols <- tryCatch(
      colorspace::sequential_hcl(100, palette = nm),
      error = function(e) NULL
    )
    if (!is.null(cols)) {
      full_name <- paste0("hcl_", gsub(" ", "_", nm))
      attr(cols, "type") <- "continuous"
      palette_list[[full_name]] <- cols
    }
  }
  # Diverging
  div_names <- c("Blue-Red", "Blue-Yellow", "Green-Brown", "Purple-Green",
                 "Tropic", "Tofino", "Berlin", "Lisbon", "Cork")
  for (nm in div_names) {
    cols <- tryCatch(
      colorspace::diverging_hcl(100, palette = nm),
      error = function(e) NULL
    )
    if (!is.null(cols)) {
      full_name <- paste0("hcl_", gsub("[- ]", "_", nm))
      attr(cols, "type") <- "continuous"
      palette_list[[full_name]] <- cols
    }
  }
  message("colorspace: ", length(palette_list) - n_before, " palettes")
}

# --- 9. Custom palettes ---
palette_list[["jet"]] <- tryCatch(
  oompaBase::jetColors(N = 100),
  error = function(e) {
    colorRampPalette(c("#00008F", "#0000FF", "#00FFFF", "#FFFF00",
                       "#FF0000", "#8F0000"))(100)
  }
)
attr(palette_list[["jet"]], "type") <- "continuous"

palette_list[["simspec"]] <- c(
  "#c22b86", "#f769a1", "#fcc5c1", "#253777", "#1d92c0", "#9ec9e1",
  "#015b33", "#42aa5e", "#d9f0a2", "#E66F00", "#f18c28", "#FFBB61"
)
attr(palette_list[["simspec"]], "type") <- "discrete"

palette_list[["GdRd"]] <- c("gold", "red3")
attr(palette_list[["GdRd"]], "type") <- "continuous"

# --- 10. UtilsR built-in palettes ---
builtin <- list(
  lancet = c("#00468BFF","#ED0000FF","#42B540FF","#0099B4FF","#925E9FFF",
             "#FDAF91FF","#AD002AFF","#ADB6B6FF","#1B1919FF","#79AF97FF",
             "#DF8F44FF","#6A6599FF","#FCCDE5FF","#80B1D3FF","#0000FFFF"),
  igv = c("#5050FF","#CE3D32","#749B58","#F0E685","#466983","#BA6338",
          "#5DB1DD","#802268","#6BD76B","#D595A7","#924822","#837B8D",
          "#C75127","#D58F5C","#7A65A5","#E4AF69","#3B1B53","#CDDEB7",
          "#612A79","#AE1F63","#E7C76F","#5A655E","#CC9900","#99CC00",
          "#33CC00","#00CC33","#00CC99","#0099CC","#0A47FF","#4775FF",
          "#FFC20A","#FFD147","#990033","#991A00","#996600","#809900",
          "#339900","#00991A","#009966","#008099","#003399","#1A0099",
          "#660099","#990080","#D60047","#FF1463","#00D68F","#14FFB1"),
  ditto = c("#E69F00","#56B4E9","#009E73","#F0E442","#0072B2","#D55E00",
            "#CC79A7","#666666","#AD7700","#1C91D4","#007756","#D5C711",
            "#005685","#A04700","#B14380","#4D4D4D","#FFBE2D","#80C7EF",
            "#00F6B3","#F4EB71","#06A5FF","#FF8320","#D99BBD","#8C8C8C",
            "#FFCB57","#9AD2F2","#2CFFC6","#F6EF8E","#38B7FF","#FF9B4D",
            "#E0AFCA","#A3A3A3","#8A5F00","#1674A9","#005F45","#AA9F0D",
            "#00446B","#803800","#8D3666","#3D3D3D"),
  polychrome = c("#5A5156","#E4E1E3","#F6222E","#FE00FA","#16FF32","#3283FE",
                 "#FEAF16","#B00068","#1CFFCE","#90AD1C","#2ED9FF","#DEA0FD",
                 "#AA0DFE","#F8A19F","#325A9B","#C4451C","#1C8356","#85660D",
                 "#B10DA1","#FBE426","#1CBE4F","#FA0087","#FC1CBF","#F7E1A0",
                 "#C075A6","#782AB6","#AAF400","#BDCDFF","#822E1C","#B5EFB5",
                 "#7ED7D1","#1C7F93","#D85FF7","#683B79","#66B0FF","#3B00FB"),
  glasbey = c("#0000FF","#FF0000","#00FF00","#000033","#FF00B6","#005300",
              "#FFD300","#009FFF","#9A4D42","#00FFBE","#783FC1","#1F9698",
              "#FFACFD","#B1CC71","#F1085C","#FE8F42","#DD00FF","#201A01",
              "#720055","#766C95","#02AD24","#C8FF00","#886C00","#FFB79F",
              "#858567","#A10300","#14F9FF","#00469E","#DC5E93","#93D4FF",
              "#004CFF","#F2F318"),
  d3 = c("#1F77B4","#FF7F0E","#2CA02C","#D62728","#9467BD","#8C564B",
         "#E377C2","#7F7F7F","#BCBD22","#17BECF","#AEC7E8","#FFBB78",
         "#98DF8A","#FF9896","#C5B0D5","#C49C94","#F7B6D2","#C7C7C7",
         "#DBDB8D","#9EDAE5"),
  paraSC = c("#8B1A1A","#56B4E9FF","#8B5E3C","#2E8B45","#1A7B7B",
             "#7B68AA","#D4919A","#F0C8A0","#C0C0C0","#282828",
             "#F0E442FF","#9AB83C","#E07B1A","#6B3FA0","#D4C8E8",
             "#8AAAC8")
)
for (nm in names(builtin)) {
  attr(builtin[[nm]], "type") <- "discrete"
  palette_list[[nm]] <- builtin[[nm]]
}

# --- Summary ---
message("\nTotal palettes: ", length(palette_list))
message("Discrete: ", sum(sapply(palette_list, function(x) attr(x, "type") == "discrete")))
message("Continuous: ", sum(sapply(palette_list, function(x) attr(x, "type") == "continuous")))

# --- Save ---
save(palette_list, file = "data/palette_list.rda", compress = "xz")
message("Saved to data/palette_list.rda")
