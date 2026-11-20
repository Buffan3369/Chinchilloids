################################################################################
# Name: 2c-Exclude_Car.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Exclude Caribbean taxa from combined PyRate input.
################################################################################

full_input <- readLines("./Data/PyRate_inputs/Species/Combined/Chinchilloidea_sp_lvl_COMBINED_CARRILLO2026_occ_PyRate.py")

## Extract name vectors for fossil and extant taxa -----------------------------
# FOSSIL
idx_taxlist <- grep("^taxa_names\\s*=", full_input)
toks <- regmatches(full_input[idx_taxlist],
                   gregexpr("'[^']*'", full_input[idx_taxlist]))[[1]]
names_vec <- gsub('[\']', "", toks)

## Find position of Caribbean taxa within name vector --------------------------
car_names <- c("Amblyrhiza_inundata", "Elasmodontomys_obliquus",
               "Quemisia_gravis", "Clidomys_osborni", "Borikenomys_praecursor")
car_pos <- which(names_vec %in% car_names)

ends <- which(full_input == "]")

## Write combined file ---------------------------------------------------------
outfile <- "./Data/PyRate_inputs/Species/Combined/Chinchilloidea_sp_lvl_COMBINED_CARRILLO2026_NoCar_occ_PyRate.py"
cat("#!/usr/bin/env python", "from numpy import * ", "", "",  file=outfile, sep="\n")

datasets <- c()
names <- c()

for(i in 1:length(ends)){
  
  datasets <- c(datasets, paste0("data_", i))
  names <- c(names, paste0("Chinchilloidea_sp_lvl_COMBINED_CARRILLO2026_NoCar_occ_", i))
  
  pattern <- paste0("data_", i, "\\s*=")
  end <- ends[i]
  
  ds <- full_input[grep(pattern, full_input):(end-1)]
  ds <- ds[-car_pos]
  
  cat(noquote(paste(ds, collapse = "\n")), "]", "", "",
      file = outfile, append=TRUE, sep="\n")
}

# Closing words
cat(paste0("\nd=[", noquote(paste(datasets, collapse = ", ")), "]"),
    paste0("names=['", paste(names, collapse = "', '"), "']"),
    "def get_data(i): return d[i]", "def get_out_name(i): return  names[i]", 
    file=outfile, append=TRUE, sep="\n")

cat(paste0("taxa_names=['", paste(names_vec[-car_pos], collapse = "', '"), "']"), 
    "def get_taxa_names(): return taxa_names",
    file=outfile, append=TRUE, sep="\n")


## Write TaxonList file
extantnames_vec <- c("Chinchilla_lanigera", "Lagidium_viscacia", "Lagidium_peruanum", "Lagidium_wolffsohni",
                     "Lagostomus_maximus", "Dinomys_branickii")

TL <- paste0("./Data/PyRate_inputs/Species/Combined/Chinchilloidea_sp_lvl_COMBINED_CARRILLO2026_NoCar_occ_TaxonList.txt")
TL_df <- data.frame(Species = names_vec[-car_pos],
                    Status = sapply(X = names_vec[-car_pos],
                                    FUN = function(x){ifelse(x %in% extantnames_vec, "extant", "extinct")}))
write.table(TL_df, file = TL, quote = F, row.names = F, sep = "\t")

