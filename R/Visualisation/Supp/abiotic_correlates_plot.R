library(tidyverse)

source("./R/useful/load_GTS.R")

## GTS processing --------------------------------------------------------------
gsc1$max_age[nrow(gsc1)] <- 35
gsc1$name[which(gsc1$name == "Eocene")] <- ""
gsc1$name[which(gsc1$name == "Pliocene")] <- "Plio"
gsc1$name[which(gsc1$name == "Pleistocene")] <- "Ple"
gsc4 <- gsc4[-nrow(gsc4), ]
gsc4$max_age[nrow(gsc4)] <- 35

## Open variables --------------------------------------------------------------
temp <- read.table("./Data/MBD_predictors/1-Palaeotemperature_500ky_step_Tardif.txt", header = T)
upl <- read.table("./Data/MBD_predictors/2-Average_Andean_uplift_500ky_step.txt", header = T)
slvl <- read.table("./Data/MBD_predictors/3-Sea_level_500ky_step.txt", header = T)

df <- data.frame(time = rep(temp$Time, 3),
                 Predictor = c(rep("Regional Temperature (°C)", nrow(temp)),
                               rep("Andean Uplift (m)", nrow(upl)),
                               rep("Sea Level (m)", nrow(slvl))),
                 Value = c(temp$Temperature, upl$elev, slvl$Sea_level))
df <- df %>% filter(time <= 35)

## Plot ------------------------------------------------------------------------
env_plt <- df %>% ggplot(aes(x = time, y = Value)) +
  geom_line(linewidth = 1) +
  scale_x_reverse() +
  facet_wrap(.~Predictor, scales = "free_y") +
  xlab("Time (Ma)") +
  coord_geo(pos = list("bottom", "bottom"),
            dat = list(gsc4, gsc1),
            abbrv = list(T, F),
            lwd = 0.35,
            center_end_labels = TRUE,
            height = unit(0.75, "line"),
            size = "auto")
ggsave("./Figures/Supp/Abiotic_correlates.pdf", plot = env_plt,
       height = 110, width = 300, units = "mm")
