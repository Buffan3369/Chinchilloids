################################################################################
# Name: Lifespans_hypso.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Taxon lifespans along with HI classes
################################################################################

## -------------------------------------------------------------------------- ##
#                     Species lifespans (PyRate sensu largo)                   #
## -------------------------------------------------------------------------- ##

library(tidyverse)
library(readxl)
library(rphylopic)

source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")

## Assign species names and family to TsTe estimates ---------------------------
TaxonList <- read.table("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_TaxonList.txt", header = T)
occdb <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")

TaxonList <- TaxonList %>% 
  mutate(Family = sapply(X = Species, 
                         FUN = function(x){
                           fam <- unique(occdb$family[which(occdb$accepted_name == x)])
                           return(fam)
                         }))
TaxonList$Family[1] <- "Dinomyidae" # "Telicomys"_amazonensis (quote issue)
TaxonList$Family[which(is.na(TaxonList$Family))] <- "Stem Chinchilloidea"
TaxonList$Family <- unlist(TaxonList$Family)

TsTe_tbl <- read.table("./Results/RJMCMC/species/1-Full/LTT/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est.txt", header = T)
TsTe_tbl <- TsTe_tbl %>%
  mutate(Family = TaxonList$Family,
         Species_name = TaxonList$Species)

# Compute mean Ts and Te
Ts_ttl <- TsTe_tbl %>% 
  select(matches("ts")) 
Te_ttl <- TsTe_tbl %>% 
  select(matches("te"))
TsTe_tbl <- TsTe_tbl %>% 
  mutate(mean_ts = rowMeans(Ts_ttl),
         mean_te = rowMeans(Te_ttl)) %>%
  select(Family, Species_name, mean_ts, mean_te) %>%
  rename(ts = "mean_ts", te = "mean_te")
rm(Ts_ttl, Te_ttl)
# Remove the only genus-level taxon (my bad)
TsTe_tbl$Family[which(TsTe_tbl$Species %in% c("Microscleromys_cribriphilus", 
                                              "Microscleromys_paradoxalis"))] <- "NA" # truandage
TsTe_tbl$Family <- factor(TsTe_tbl$Family, levels = rev(c("Chinchillidae", "Neoepiblemidae", "Dinomyidae", 
                                                          "?Heptaxodontidae", "\"Cephalomyidae\"", "NA", "Stem Chinchilloidea")))
# Rearrange
TsTe_tbl <- TsTe_tbl %>% arrange(Family, ts)

# Get the index corresponding to each family's species
# set extent of each class
MinMax <- data.frame("Stem Chinchilloidea" = c(0, which.max(which(TsTe_tbl$Family == "Stem Chinchilloidea"))+1))
for(fam in unique(TsTe_tbl$Family)[-1]){
  corr_idx <- which(TsTe_tbl$Family == fam)
  MinMax <- MinMax %>% add_column(fam = c(corr_idx[which.min(corr_idx)],
                                          corr_idx[which.max(corr_idx)]+1))
}
colnames(MinMax) <- unique(TsTe_tbl$Family)
TsTe_tbl$Family[which(TsTe_tbl$Species %in% c("Microscleromys_cribriphilus", 
                                              "Microscleromys_paradoxalis"))] <- NA
## Body mass categories --------------------------------------------------------
HI <- read_xlsx("./Data/Traits/Species_Lists/Chinchilloidea_Hypsodonty_SpeciesList.xlsx")
HI$Hypsodonty_category <- as.numeric(HI$Hypsodonty_category)

HI_palette <- c("#7fc97f", "#beaed4", "#ff7f00", "#f0027f")

TsTe_tbl <- TsTe_tbl %>% 
  mutate(HI_cat = sapply(X = Species_name,
                         FUN = function(x){
                           return(HI$Hypsodonty_category[which(HI$name == x)])
                         })) %>% 
  mutate(col_HI_cat = sapply(X = Species_name,
                             FUN = function(x){
                               if(x %in% HI$name){
                                 cat <- HI$Hypsodonty_category[which(HI$name == x)]
                                 if(is.na(cat) == F){
                                   return(HI_palette[cat+1])
                                 }
                                 else{
                                   return("grey50")
                                 }
                               }
                               else{
                                 return("grey50")
                               }
                             }))
# Numericise Data deficiency
for(i in 1:nrow(TsTe_tbl)){
  if(length(TsTe_tbl$HI_cat[[i]]) == 0){
    TsTe_tbl$HI_cat[[i]] <- 4
  }
}
for(i in 1:nrow(TsTe_tbl)){
  if(is.na(TsTe_tbl$HI_cat[[i]])){
    TsTe_tbl$HI_cat[[i]] <- 4
  }
}
TsTe_tbl$HI_cat <- unlist(TsTe_tbl$HI_cat)

# Barplot of distribution among categories
CountCat <- TsTe_tbl %>%
  count(HI_cat) %>% 
  mutate(HI_cat = as.factor(HI_cat)) %>% 
  mutate(CatName = c("Brachydont", "Mesodont", "Protohypsodont", "Euhypsodont", "No Data"))

count_plt <- CountCat %>%   
  ggplot(aes(x = HI_cat, y = n)) +
  geom_bar(stat = "identity", aes(fill = as.factor(HI_cat))) +
  scale_fill_manual(values = c(HI_palette, "grey50")) +
  geom_text(aes(label = n), vjust = -0.2, size = 1.5) +
  scale_x_discrete(breaks = 0:4,
                   label = c("Brachydont", "Mesodont", "Protohypsodont",
                             "Euhypsodont", "No Data")) +
  scale_y_continuous(expand = c(0, 7)) +
  theme(axis.line.y = element_blank(),
        axis.title = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(size = 4, face = "bold"),
        axis.text.y = element_blank(),
        plot.background = element_blank(),
        panel.background = element_rect(fill = "transparent", colour = "black"),
        panel.grid = element_blank(),
        legend.position = "none")

ggsave("./Figures/Supp/Lifespans_hypso/barplot_distrib_HI.pdf", 
       plot = count_plt, height = 30, width = 60, units = "mm")

## Plot ------------------------------------------------------------------------
# Remove underscore from species name
TsTe_tbl <- TsTe_tbl %>% 
  mutate(Species_name = sapply(X = Species_name, 
                               FUN = function(x){
                                 spl <- strsplit(x, split = "_")[[1]]
                                 return(paste0(spl[1], " ", spl[2]))
                               }))
# Images from Phylopic
lagidium_uuid <- get_uuid(name = "Lagidium peruanum")
lagidium_img <- get_phylopic(uuid = lagidium_uuid)

chinchilla_uuid <- get_uuid(name = "Chinchilla chinchilla")
chinchilla_img <- get_phylopic(uuid = chinchilla_uuid)

dinomys_uuid <- get_uuid(name = "Dinomys branickii")
dinomys_img <- get_phylopic(uuid = dinomys_uuid)

josephoartigasia_uuid <- get_uuid(name = "Josephoartigasia monesi")
josephoartigasia_img <- get_phylopic(uuid = josephoartigasia_uuid)


# Proper plot
lifespans_plot <- TsTe_tbl %>% 
  mutate(HI_cat = as.character(HI_cat)) %>% 
  ggplot(aes(y = fct_inorder(Species_name), yend = fct_inorder(Species_name))) +
  # Grey ribbons for geological sub-epochs
  # annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  # annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  # annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  # annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  scale_y_discrete(position = "right") +
  labs(x = "Time (Ma)", y = NULL, color = NULL) +
  # Chinchillidae
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = MinMax$Chinchillidae[1]-0.5,
           ymax = MinMax$Chinchillidae[2], fill = "grey", alpha = 0.3) +
  annotate(geom = "text", x = 31.5, y = MinMax$Chinchillidae[1]+3, 
           label = "Chinchillidae", size = 2.8, fontface = 2) +
  add_phylopic(img = chinchilla_img, x = 32, y = MinMax$Chinchillidae[1]+20, height = 5) +
  add_phylopic(img = lagidium_img, x = 31.5, y = MinMax$Chinchillidae[1]+10, height = 7) +
  # Neoepiblemidae
  # annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = MinMax$Neoepiblemidae[1]-0.5,
  #          ymax = MinMax$Neoepiblemidae[2]-0.5, fill = "#beaed4", alpha = 0.3) +
  annotate(geom = "text", x = 31.2, y = MinMax$Neoepiblemidae[1]+11,
           label = "Neoepiblemidae", size = 2.8, fontface = 2) +
  # Dinomyidae
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = MinMax$Dinomyidae[1]-0.5,
           ymax = MinMax$Dinomyidae[2]-0.5, fill = "grey", alpha = 0.3) +
  annotate(geom = "text", x = 31.5, y = MinMax$Dinomyidae[1]+16, 
           label = "Dinomyidae", size = 2.8, fontface = 2) +
  add_phylopic(img = dinomys_img, x = 31.5, y = MinMax$Dinomyidae[1]+35, height = 4) +
  add_phylopic(img = josephoartigasia_img, x = 31, y = MinMax$Dinomyidae[1]+25, height = 8) +
  # ?Heptaxodontidae
  annotate(geom = "text", x = 31, y = MinMax$`?Heptaxodontidae`[1]+1.5,
           label = "?Heptaxodontidae", size = 2.8, fontface = 2) +
  # "Cephalomyidae"
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = MinMax$`"Cephalomyidae"`[1]-0.5,
           ymax = MinMax$`"Cephalomyidae"`[2]-0.5, fill = "grey", alpha = 0.3) +
  annotate(geom = "text", x = 31, y = MinMax$`"Cephalomyidae"`[1]+1, 
           label = "\"Cephalomyidae\"", size = 2.8, fontface = 2) +
  # Stem Chinchilloidea
  # annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = MinMax$`Stem Chinchilloidea`[1],
  #          ymax = MinMax$`Stem Chinchilloidea`[2]-0.5, fill = "#f0027f", alpha = 0.3) +
  annotate(geom = "text", x = 31.5, y = MinMax$`Stem Chinchilloidea`[1]+8, 
           label = "Stem \nChinchilloidea", size = 2.8, fontface = 2) +
  # Artificially extend plotting window
  annotate(geom = "text", x = 35, y = nrow(TsTe_tbl)+0.5, label = " ") +
  annotate(geom = "text", x = 35, y = 0.5, label = " ") +
  # Species lifespans
  geom_segment(aes(x = ts, xend = te, colour = HI_cat), linewidth = 0.8) +
  scale_colour_manual(labels = c("Brachydont", "Mesodont", "Protohypsodont", "Euhypsodont", "No Data"),
                      values = c("#7fc97f", "#beaed4", "#ff7f00", "#f0027f", "grey50")) +
  scale_x_reverse(breaks = seq(from = 0, to = 35, by = 5), 
                  labels = seq(from = 0, to = 35, by = 5),
                  expand = c(0, 0.1)) +
  # GTS
  coord_geo(pos = list("bottom", "bottom"),
            dat = list(gsc4, gsc1),
            abbrv = list(T, F),
            lwd = 0.35,
            center_end_labels = TRUE,
            height = unit(0.75, "line"),
            size = "auto",
            xlim = c(35, 0)) +
  # Theme
  theme(axis.text.x = element_text(size = 10),
        axis.text.y = element_text(face = "italic", size = 4.5, colour = TsTe_tbl$col_HI_cat),
        axis.title.x = element_text(size = 12),
        legend.position = "bottom",
        legend.key = element_rect(fill="white"),
        legend.key.height = unit(5, "mm"),
        legend.key.width = unit(7, "mm"),
        legend.text = element_text(size = 8, hjust = .5),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.background = element_rect(fill = "grey97"),
        plot.margin = unit(c(0.5, 2, 0.5, 0.5), "cm"))

ggsave("./Figures/Supp/Lifespans_hypso/Lifespans_HI_Chinchi.pdf", plot = lifespans_plot, height = 220, width = 180, units = "mm")

