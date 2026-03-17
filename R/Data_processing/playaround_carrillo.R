library(readxl)
library(tidyverse)
library(ggpubr)
source("./R/useful/load_GTS.R")

gsc1$max_age[nrow(gsc1)] <- 35
gsc1$name[which(gsc1$name == "Eocene")] <- ""
gsc1$name[which(gsc1$name == "Pliocene")] <- "Plio"
gsc1$name[which(gsc1$name == "Pleistocene")] <- "Ple"
gsc4 <- gsc4[-nrow(gsc4), ]
gsc4$max_age[nrow(gsc4)] <- 35

chinchi_sp <- read.table("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED.txt", header = T)
chinchi_sp$Study <- "This study"
chinchi_sp <- chinchi_sp %>% 
  mutate(FAD = sapply(X = chinchi_sp$Species,
                      FUN = function(x){
                        tmp <- chinchi_sp[which(chinchi_sp$Species == x), ]
                        return(max(tmp[, "max_age"]))
                      }),
         LAD = sapply(X = chinchi_sp$Species,
                      FUN = function(x){
                        tmp <- chinchi_sp[which(chinchi_sp$Species == x), ]
                        return(min(tmp[, "min_age"]))
                      })) %>% 
  distinct(Species, FAD, LAD, Study)

database_Carrillo <- read_xlsx("./Data/Data_from_Carrillo_et_al_Caviomorphs/Dataset S5 - Diversity through time/DeepDive diversity estimates/Chinchilloidea_dd.xlsx")
database_Carrillo <- database_Carrillo %>%
  mutate(FAD = sapply(X = database_Carrillo$species,
                      FUN = function(x){
                        tmp <- database_Carrillo[which(database_Carrillo$species == x), ]
                        return(max(tmp[, "max_ma"]))
                      }),
         LAD = sapply(X = database_Carrillo$species,
                      FUN = function(x){
                        tmp <- database_Carrillo[which(database_Carrillo$species == x), ]
                        return(min(tmp[, "min_ma"]))
                      }),
         Study = "Carrillo et al. (2026)") %>% 
  rename(Species = "species") %>% 
  distinct(Species, FAD, LAD, Study)

# Standardising species between studies
chinchi_sp <- chinchi_sp %>% 
  filter(Species %in% database_Carrillo$Species)
database_Carrillo <- database_Carrillo %>% 
  filter(Species %in% chinchi_sp$Species)

MERGE_DB <- rbind.data.frame(chinchi_sp, database_Carrillo)

# Plotting comparative FAD/LADs
rough_plot <- MERGE_DB %>% 
  # Remove underscore for species names
  mutate(Species = sapply(X = Species,
                          FUN = function(x){
                            spl <- strsplit(x, split = "_")[[1]]
                            return(paste0(spl[1], " ", spl[2]))
                            })) %>% 
  # Plot
  ggplot(aes(y = Species)) +
  scale_y_discrete(position = "right") +
  labs(x = "Time (Ma)", y = NULL, color = "Study") +
  geom_segment(aes(x = FAD, xend = LAD, colour = Study), position = position_dodge(-0.5)) +
  scale_x_reverse(breaks = seq(from = 0, to = 35, by = 5), 
                  labels = seq(from = 0, to = 35, by = 5)) +
  coord_geo(pos = list("bottom", "bottom"),
            dat = list(gsc4, gsc1),
            abbrv = list(T, F),
            lwd = 0.35,
            center_end_labels = TRUE,
            height = unit(0.75, "line"),
            size = "auto") +
  theme(axis.text.x = element_text(size = 10),
        axis.text.y = element_text(face = "italic", size = 5),
        axis.title.x = element_text(size = 12),
#        legend.position = "bottom",
        legend.key = element_rect(fill="white"),
        legend.key.height = unit(5, "mm"),
        legend.key.width = unit(7, "mm"),
        legend.text = element_text(size = 8, hjust = .5),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.background = element_rect(fill = "grey97"),
        plot.margin = unit(c(0.5, 2, 0.5, 0.5), "cm"))

ggsave("./Results/comparing_with_Carrillo/comparative_LAD_FAD.pdf", height = 200, 
       width = 250, plot = rough_plot, units = "mm")

# Persistence violin
MERGE_DB <- MERGE_DB %>% mutate(persistence = FAD - LAD)

persistence_plot <- MERGE_DB %>% 
  ggplot(aes(x = Study, y = persistence)) +
  stat_compare_means(method = "wilcox.test",
                     comparisons = list(c("Carrillo et al. (2026)",
                                          "This study")),
                     paired = T) +
  labs(y = "Persistence (Ma)") +
  geom_violin(draw_quantiles = c(0.5), aes(fill = Study)) +
  scale_fill_manual(values = c("#F8766D", "#619CFF")) +
  geom_point()

ggsave("./Results/comparing_with_Carrillo/persistence_violin.pdf", height = 150, 
       width = 150, plot = persistence_plot, units = "mm")
