library(tidyverse)
source("./R/useful/helper_functions.R")

## Environment variable plot for SI Appendix ---------------------------------
# Temperature
temp_tardif <- read.table("./Data/MBD_predictors/SA_regional_temperatures_Tardif_2025.txt", header = T)
temp_tardif %>% 
  filter(Time < 38) %>% 
  ggplot(aes(x = Time, y = SAMMAT)) +
  geom_line(linewidth = 1.5, colour = "#d95f0e") +
  labs(x = "Time (Ma)", y = "Temperature (°C)") +
  ggtitle("Paleotemperature") +
  scale_x_reverse(breaks = seq(0, 35, 5)) +
  scale_y_continuous(breaks = seq(20, 30, 5),
                     limits = c(18, 31)) +
  theme_lucas() +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "purple") +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2)

# Andean uplift
upl <- Andes %>% 
  filter(Age < 56 & Age > 24) %>% 
  ggplot(aes(x = Age, y = Altitude)) +
  geom_line(linewidth = 1.5, colour = "purple3") +
  labs(x = "Time (Ma)", y = "Elevation (m)") +
  ggtitle("Average andean uplift") +
  scale_x_reverse(breaks = seq(25, 55, 5)) +
  scale_y_continuous(breaks = seq(500, 1000, 100),
                     limits = c(450, 1050)) +
  theme_lucas() +
  coord_geo(dat = "epochs", abbrv = FALSE, size = 2.5, height = unit(1, "line")) +
  annotate(geom = "rect", xmin = 47.8, xmax = Inf, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 33.9, xmax = 37.71, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = -Inf, xmax = 27.8, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)

# Sea level
slv <- slvl %>% 
  filter(Age < 56 & Age > 24) %>% 
  ggplot(aes(x = Age, y = Sea_level)) +
  geom_line(linewidth = 1.5, colour = "skyblue3") +
  labs(x = "Time (Ma)", y = "Sea level (m)") +
  ggtitle("Eustatic variations") +
  scale_x_reverse(breaks = seq(25, 55, 5)) +
  scale_y_continuous(breaks = seq(-25, 75, 25),
                     limits = c(-50, 80)) +
  theme_lucas() +
  coord_geo(dat = "epochs", abbrv = FALSE, size = 2.5, height = unit(1, "line")) +
  annotate(geom = "rect", xmin = 47.8, xmax = Inf, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 33.9, xmax = 37.71, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = -Inf, xmax = 27.8, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)

# Plants
plants <- plant_processed %>% 
  filter(Age < 56 & Age > 24) %>% 
  ggplot(aes(x = Age, y = Plant_diversity)) +
  geom_line(linewidth = 1.5, colour = "#238b45") +
  labs(x = "Time (Ma)", y = "Number of taxa") +
  ggtitle("Neotropical Plant Diversity") +
  scale_x_reverse(breaks = seq(25, 55, 5)) +
  scale_y_continuous(breaks = seq(200, 350, 30),
                     limits = c(215, 360)) +
  theme_lucas() +
  coord_geo(dat = "epochs", abbrv = FALSE, size = 2.5, height = unit(1, "line")) +
  annotate(geom = "rect", xmin = 47.8, xmax = Inf, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 33.9, xmax = 37.71, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = -Inf, xmax = 27.8, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)

# Temporal patterns of open habitats
h_op <- p_op_int %>% 
  filter(Age < 56 & Age > 24) %>% 
  ggplot(aes(x = Age, y = P_open)) +
  geom_line(linewidth = 1.5, colour = "grey40") +
  labs(x = "Time (Ma)", y = "Nb. grassland taxa") +
  ggtitle("Patterns of hab. openness") +
  scale_x_reverse(breaks = seq(25, 55, 5)) +
  theme_lucas() +
  coord_geo(dat = "epochs", abbrv = FALSE, size = 2.5, height = unit(1, "line")) +
  annotate(geom = "rect", xmin = 47.8, xmax = Inf, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 33.9, xmax = 37.71, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = -Inf, xmax = 27.8, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)

# Relative leaf area index
rlai_p <- rlai_int %>% 
  filter(Age < 56 & Age > 24) %>% 
  ggplot(aes(x = Age, y = rLAI)) +
  geom_line(linewidth = 1.5, colour = "darkred") +
  labs(x = "Time (Ma)", y = "rLAI") +
  ggtitle("Relative leaf area index") +
  scale_x_reverse(breaks = seq(25, 55, 5)) +
  scale_y_continuous(breaks = seq(0, 3, 0.5),
                     limits = c(0, 3)) +
  theme_lucas() +
  coord_geo(dat = "epochs", abbrv = FALSE, size = 2.5, height = unit(1, "line")) +
  annotate(geom = "rect", xmin = 47.8, xmax = Inf, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 33.9, xmax = 37.71, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = -Inf, xmax = 27.8, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)

# Assemble and plot
tot_plot <- ggarrange(temp, upl, slv,
                      plants, h_op, rlai_p,
                      nrow = 2,
                      ncol = 3,
                      labels = c("(A)", "(B)", "(C)", "(D)", "(E)", "(F)"))
ggsave("./figures/supp_figs/evt_vbl_plot.pdf",
       plot = tot_plot,
       height = 150,
       width = 210,
       units = "mm")


