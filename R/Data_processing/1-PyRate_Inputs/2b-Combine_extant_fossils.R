################################################################################
# Name: 2b-Combine_extant_fossils.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Combine simulated occurrences for extant taxa generated in 
#              `2a-Extant_sampling.R` with occurrence sampled from our fossil 
#              record (`1-PyRate_inputs.R`).
################################################################################

## Occurrences sampled ages ----------------------------------------------------
fossilAges <- readLines("./Data/PyRate_inputs/Species/2-Chinchilloidea_sp_lvl_occ_FossilOnly_PyRate.py")
extantAges <- readLines("./Data/PyRate_inputs/Species/Combined/Chinchilloidea_sp_lvl_Extant_simulated_occ_PyRate.py")

## Extract name vectors for fossil and extant taxa -----------------------------
  # FOSSIL
idx_Fossil_taxlist <- grep("^taxa_names\\s*=", fossilAges)
toks <- regmatches(fossilAges[idx_Fossil_taxlist],
                   gregexpr("'[^']*'", fossilAges[idx_Fossil_taxlist]))[[1]] # all elements delimited by single quotes
fossilnames_vec <- gsub('[\']', "", toks)
  # EXTANT
idx_Extant_taxlist <- grep("^taxa_names\\s*=", extantAges)
toks <- regmatches(extantAges[idx_Extant_taxlist],
                   gregexpr("'[^']*'", extantAges[idx_Extant_taxlist]))[[1]]
extantnames_vec <- gsub('[\']', "", toks)

## Find extant taxa's position within the combined name vector -----------------
combined_names <- sort(c(extantnames_vec, fossilnames_vec))
pos_extant <- which(combined_names %in% extantnames_vec)

ends_f <- which(fossilAges == "]") # ends of fossil age samples
ends_e <- which(extantAges == "]") # ends of extant age samples

## Write combined file ---------------------------------------------------------
outfile <- "./Data/PyRate_inputs/Species/Combined/Chinchilloidea_sp_lvl_COMBINED_occ_PyRate.py"
cat("#!/usr/bin/env python", "from numpy import * ", "", "",  file=outfile, sep="\n")

datasets <- c()
names <- c()

for(i in 1:length(ends_f)){
  
  datasets <- c(datasets, paste0("data_", i))
  names <- c(names, paste0("Chinchilloidea_sp_lvl_COMBINED_occ_", i))
  
  pattern <- paste0("data_", i, "\\s*=")
  end_e <- ends_e[i]
  end_f <- ends_f[i]

  ds_fos <- fossilAges[grep(pattern, fossilAges):(end_f-1)]
  ds_ext <- extantAges[grep(pattern, extantAges):(end_e-1)]

  ds_combined <- ds_fos
  for(pos in rev(pos_extant)){
    to_insert <- ds_ext[which(pos_extant == pos)]
    if(length(grep(paste0("data_", i, "\\s*="), to_insert)) > 0){
      to_insert <- gsub(paste0("data_", i, "\\s*="), "", to_insert)
      to_insert <- paste0("array", strsplit(to_insert, split="\\[array")[[1]][2]) # trailing opening bracket removal
    }
    dsF_bf <- ds_combined[1:(pos-1)]
    dsF_af <- ds_combined[pos:length(ds_combined)]
    ds_combined <- c(dsF_bf, to_insert, dsF_af)
  }

  cat(noquote(paste(ds_combined, collapse = "\n")), "]", "", "",
      file = outfile, append=TRUE, sep="\n")
}

# Closing words
cat(paste0("\nd=[", noquote(paste(datasets, collapse = ", ")), "]"),
    paste0("names=['", paste(names, collapse = "', '"), "']"),
    "def get_data(i): return d[i]", "def get_out_name(i): return  names[i]", 
    file=outfile, append=TRUE, sep="\n")

cat(paste0("taxa_names=['", paste(sort(c(extantnames_vec, fossilnames_vec)), collapse = "', '"), "']"), 
    "def get_taxa_names(): return taxa_names",
    file=outfile, append=TRUE, sep="\n")
  

## Write TaxonList file
TL <- "./Data/PyRate_inputs/Species/Combined/Chinchilloidea_sp_lvl_COMBINED_occ_TaxonList.txt"
TL_df <- data.frame(Species = sort(c(extantnames_vec, fossilnames_vec)),
                    Status = sapply(X = sort(c(extantnames_vec, fossilnames_vec)),
                                    FUN = function(x){ifelse(x %in% extantnames_vec, "extant", "extinct")}))
write.table(TL_df, file = TL, quote = F, row.names = F, sep = "\t")
