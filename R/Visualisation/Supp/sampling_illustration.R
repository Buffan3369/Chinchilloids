## Illustrate our virtual occurrence sampling scheme ---------------------------

library(tidyverse)
source("./R/useful/Poisson_sampling.R")
source("./R/useful/helper_functions.R")

set.seed(17112026)

# Initial parameters
q_table <- read.table("./Results/RJMCMC/species/7-FossilOnly/Q_SHIFTS/Parsed_Q_rates.txt",
                      header = T)
s_sp <- 24

# Virtual occurrence sampling
events <- time_varying_sampling(s_sp = s_sp,
                                q_tbl = q_table)

# Prepare plot datasets
point_df <- data.frame(time = events, y = 0)
q_df <- q_table |> 
  filter(Age < max(events))
q_df <- q_df |> 
  add_row(Age = 0, mean_Q = q_df$mean_Q[nrow(q_df)], min_HPD = q_df$min_HPD[nrow(q_df)],
          max_HPD = q_df$max_HPD[nrow(q_df)], .after = nrow(q_df))

# Plot & save
sampling_plot <- ggplot() +
  geom_step(data = q_df, aes(x = Age, y = mean_Q), colour = "#810f7c", linewidth = 1) +
  geom_point(data = point_df, aes(x = time, y = y), size = 0.5) +
  scale_x_reverse() +
  labs(x = "Time (Ma)", y = "Preservation rate") +
  annotate(geom = "rect", xmin = 0, xmax = q_df$Age[5], ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = q_df$Age[4], xmax = q_df$Age[3], ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = q_df$Age[2], xmax = q_df$Age[1], ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  theme_lucas()

ggsave("./Figures/Supp/ExtantSampling/sampling_plot.pdf", 
       plot = sampling_plot, height = 140, width = 180, units = "mm")
