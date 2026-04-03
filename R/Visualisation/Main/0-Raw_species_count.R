library(readxl)
library(tidyverse)
library(tidytree)
library(pammtools)
library(ggtree)
library(palaeoverse)
library(treeio)

source("./R/useful/helper_functions.R")

## Caviomorph tree from VertLife -----------------------------------------------
cavio_tree <- read.mega("./Data/Phylogeny/chinchi_consensus.tree")


cavio_tree_plt <- cavio_tree %>% ggtree(layout = "circular")
ggsave("./Figures/Main/Figure_set_the_scene/Cavio_full_tree.pdf", plot = cavio_tree_plt,
       height = 5, width = 5, units = "cm")

chinchi_sp <- c("Chinchilla_chinchilla", "Chinchilla_lanigera", "Lagidium_peruanum",
                "Lagidium_ahuacaense", "Lagidium_viscacia", "Lagidium_wolffsohni",
                "Lagostomus_maximus", "Dinomys_branickii")

chinchi_tree <- keep.tip(cavio_tree, tip = chinchi_sp)

# Plot & save
pdf("./Figures/Main/Figure_set_the_scene/Chinchilloidea_consensus_tree.pdf", height = 8, width = 9)
plot(chinchi_tree@phylo)
dev.off()

## Load GTS --------------------------------------------------------------------
source("./R/useful/load_GTS.R")
gsc1$max_age[nrow(gsc1)] <- 35
gsc1$name[which(gsc1$name == "Eocene")] <- ""
gsc1$name[which(gsc1$name == "Pliocene")] <- "Plio"
gsc1$name[which(gsc1$name == "Pleistocene")] <- "Ple"
gsc4 <- gsc4[-nrow(gsc4), ]
gsc4$max_age[nrow(gsc4)] <- 35

## Load database and filter our species-level occurrences ----------------------
occdb <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")
occdb <- occdb %>% 
  mutate(min_ma = as.numeric(min_ma), max_ma = as.numeric(max_ma)) %>%
  select(accepted_name, sp_lvl_status, min_ma, max_ma) %>%
  filter(!is.na(sp_lvl_status))

true_sp <- sapply(X = occdb$accepted_name,
                  FUN = open_checkR)
occdb <- occdb[true_sp, ]

## Raw fossil species count across time ----------------------------------------
get_FAD_LAD <- function(species_name,
                        what = c("FAD", "LAD")){
  tmp <- occdb %>% filter(accepted_name == species_name)
  if(what == "FAD"){
    target <- max(tmp$max_ma)
  }
  else if(what == "LAD"){
    target <- min(tmp$min_ma)
  }
  return(target)
}

# 119 taxa as almost all extant species are missing
final_ds <- data.frame(species = unique(occdb$accepted_name),
                       max_ma = sapply(X = unique(occdb$accepted_name), FUN = get_FAD_LAD, what = "FAD"),
                       min_ma = sapply(X = unique(occdb$accepted_name), FUN = get_FAD_LAD, what = "LAD"))

# Bin 

bins <- data.frame(bin = 1:14,
                   name = paste0("bin", 1:14),
                   rank = rep("stage", 14),
                   max_ma = seq(35, 2.5, -2.5),
                   mid_ma = seq(33.75, 1.25, -2.5),
                   min_ma = seq(32.5, 0, -2.5),
                   duration_myr = rep(2.5, 14),
                   abbr = paste0("bin", 1:14))

binned_occ <- bin_time(occdf = final_ds,
                       bins = bins,
                       method = "all")
ct <- binned_occ %>% count(bin_assignment)
ct[nrow(ct)+1,] <- c(15, 8)
ct$time <- seq(35, 0, -2.5)

raw_count_plot <- ct %>% 
  ggplot(aes(x = time, y = n)) +
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  geom_step(lwd = .5, linetype = "dashed") +
  geom_stepribbon(aes(ymin = 0, ymax = n), fill = "#41ab5d", alpha = 0.35) +
  scale_x_reverse(limits = c(35, -0.1)) +
  scale_y_continuous(breaks = seq(0, 35, 5),
                     limits = c(0, 39)) +
  labs(x = "Time (Ma)", y = "Fossil species (raw counts)") +
  theme(axis.line.y = element_line(colour = "black"), 
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 6),
        panel.background = element_blank()) +
  coord_geo(pos = list("bottom", "bottom"),
            dat = list(gsc4, gsc1),
            abbrv = list(TRUE, FALSE),
            lwd = 0.1,
            size = list(1, 2),
            height = unit(0.5, "line"),
            center_end_labels = T)

ggsave("./Figures/Main/Figure_set_the_scene/raw_species_count.pdf", plot = raw_count_plot, 
       height = 10, width = 16, units = "cm")
