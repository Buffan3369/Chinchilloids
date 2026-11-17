## Illustrate our virtual occurrence sampling scheme ---------------------------

library(tidyverse)
library(pammtools)

source("./R/useful/Poisson_sampling.R")

# Initial parameters
s_sp <- 24
meanQ_tbl <- read.table("./Results/RJMCMC/species/7-FossilOnly/Q_SHIFTS/Parsed_Q_rates.txt",
                        header = T)
q_distribs <- combine_q_distribs(MCMC_path = "./Results/RJMCMC/species/7-FossilOnly/pyrate_mcmc_logs/")

# Virtual occurrence sampling
events <- time_varying_sampling(s_sp = s_sp,
                                meanQ_tbl = meanQ_tbl,
                                q_distribs = q_distribs)

# Prepare plot datasets
point_df <- data.frame(time = events, y = 0)
q_df <- meanQ_tbl |> 
  filter(Age < max(events))
q_df <- q_df |> 
  add_row(Age = 0, mean_Q = q_df$mean_Q[nrow(q_df)], min_HPD = q_df$min_HPD[nrow(q_df)],
          max_HPD = q_df$max_HPD[nrow(q_df)], .after = nrow(q_df))

# Plot & save
sampling_plot <- ggplot() +
  annotate(geom = "rect", xmin = 0, xmax = q_df$Age[5], ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = q_df$Age[4], xmax = q_df$Age[3], ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = q_df$Age[2], xmax = q_df$Age[1], ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  geom_stepribbon(data = q_df, aes(x = Age, ymin = min_HPD, ymax = max_HPD), fill = "#810f7c", alpha = 0.2) +
  geom_step(data = q_df, aes(x = Age, y = mean_Q), colour = "#810f7c", linewidth = 1) +
  geom_point(data = point_df, aes(x = time, y = y), size = 0.75) +
  scale_x_reverse() +
  labs(x = "Time (Ma)", y = "Preservation rate") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(linewidth = .75, colour = "black", fill = NA),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 15))

ggsave("./Figures/Supp/ExtantSampling/sampling_plot.pdf", 
       plot = sampling_plot, height = 140, width = 180, units = "mm")
