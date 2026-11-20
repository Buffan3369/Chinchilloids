################################################################################
# Name: 0-Extract_95pct_HPD-Phylo.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Extract 95% HPD interval of node ages from phylogenies of 
#              Upham et al. (2019) and Carrillo et al. (2026).
################################################################################

library(treeio)
library(tidyverse)
library(paleotree)
library(ggtree)
library(deeptime)
library(tidytree)
library(hash)

source("./R/useful/helper_functions.R")

## Upham et al. (2019) ---------------------------------------------------------
cavio_tree <- read.mega("./Data/Phylogeny/chinchi_consensus.tree")

chinchi_sp <- c("Chinchilla_chinchilla", "Chinchilla_lanigera", "Lagidium_peruanum",
                "Lagidium_ahuacaense", "Lagidium_viscacia", "Lagidium_wolffsohni",
                "Lagostomus_maximus", "Dinomys_branickii")

chinchi_tree_upham <- tidytree::keep.tip(cavio_tree, tip = chinchi_sp)

# Get the boundaries of the 95%HPD of Ts distribs for species lacking fossil record
dinomys_hpd <- chinchi_tree_upham@data$CAheight_0.95_HPD[[9]]
chinchilla_hpd <- chinchi_tree_upham@data$CAheight_0.95_HPD[[12]]
ahuacaense_hpd <- chinchi_tree_upham@data$CAheight_0.95_HPD[[13]]
peruanum_hpd <- chinchi_tree_upham@data$CAheight_0.95_HPD[[14]]
viscacia_hpd <- chinchi_tree_upham@data$CAheight_0.95_HPD[[15]]

# Create dictionnary
dict_hpd_upham <- hash("Dinomys_branickii" = dinomys_hpd,
                       "Chinchilla_chinchilla" = chinchilla_hpd,
                       "Chinchilla_lanigera" = chinchilla_hpd,
                       "Lagidium_ahuacaense" = ahuacaense_hpd,
                       "Lagidium_peruanum" = peruanum_hpd,
                       "Lagidium_viscacia" = viscacia_hpd,
                       "Lagidium_wolffsohni" = viscacia_hpd)

# Save 95% HPD table
df_hpd_upham <- data.frame(values(dict_hpd_upham))
write.table.lucas(df_hpd_upham, "./Data/supp_tbl/95pct_HPD_tbl-UPHAM2019.txt")
saveRDS(dict_hpd_upham, "./Data/supp_tbl/95pct_HPD_tbl-UPHAM2019.RDS")


rm(chinchi_tree_upham, df_hpd_upham, dict_hpd_upham)


## Carrillo et al. (2026) ------------------------------------------------------
extant_chinchi <- c("Chinchilla_lanigera", "Lagidium_peruanum", "Lagidium_viscacia",
                    "Lagidium_wolffsohni", "Lagostomus_maximus", "Dinomys_branickii")

MCC_Carrillo <- treeio::read.beast("./Data/Data_from_Carrillo_et_al_Caviomorphs/Dataset S3 - Phylogenetic analyses data and code/Time-calibrated phylogeny/MCC_tree_290824.tree")
chinchi_tree_carrillo <- tidytree::keep.tip(MCC_Carrillo, tip = extant_chinchi)

# Get the boundaries of the 95%HPD of Ts distribs of extant species (lacking fossil record)
dinomys_hpd <- chinchi_tree_carrillo@data$height_0.95_HPD[[7]]
chinchilla_hpd <- chinchi_tree_carrillo@data$height_0.95_HPD[[9]]
wolffsohni_hpd <- chinchi_tree_carrillo@data$height_0.95_HPD[[10]]
peruanum_hpd <- chinchi_tree_carrillo@data$height_0.95_HPD[[11]]

# Create dictionnary
dict_hpd_carrillo <- hash("Dinomys_branickii" = dinomys_hpd,
                          "Chinchilla_lanigera" = chinchilla_hpd,
                          "Lagidium_peruanum" = peruanum_hpd,
                          "Lagidium_viscacia" = peruanum_hpd,
                          "Lagidium_wolffsohni" = wolffsohni_hpd)

# Save 95% HPD table
df_hpd_carrillo <- data.frame(values(dict_hpd_carrillo))
write.table.lucas(df_hpd_carrillo, "./Data/supp_tbl/95pct_HPD_tbl-CARRILLO2026.txt")



## Comparative plot ------------------------------------------------------------

# Plot the tree with the 95% HPD
ggtree(chinchi_tree_carrillo) + 
  geom_tiplab(fontface=3) + 
  geom_range("height_0.95_HPD", color="lightblue",size=1, alpha=.5)

# Get node numbers
ggtree(tree) + geom_text(aes(label=node), hjust=-.3)
# Chinchilloidea = node 373
# Octodontoidea = node 203

# Plot with time scale and tip labels

p <- ggtree(chinchi_tree_carrillo) + 
  geom_tiplab(fontface=3) + # add tip labels
  geom_range("height_0.95_HPD", color="purple",size=1.5, alpha=.5) + # add 95% HPD bars

  # coord_geo(xlim = c(-50,20),
  #           dat = list("epochs", "periods"),
  #           neg = TRUE, abbrv = TRUE) + # change limits to show tip labels
  theme_tree2()

revts(p)

# Export and save figure (it doesnt work with DeepTime)
#ggsave("Fig S3.tiff", plot= revts(p), width=30, height=50, units = "cm", dpi=300)
ggsave("Fig S3_290824.tiff", plot= revts(p), width=30, height=50, units = "cm", dpi=300)

